/// aether_llm.cpp — thin C++ wrapper over llama.cpp for Paulien's Sky AETHER

#include "aether_llm.h"
#include "llama.cpp/include/llama.h"
#include "llama.cpp/ggml/include/ggml.h"

#include <string>
#include <vector>
#include <cstring>
#include <cstdlib>
#include <ctime>
#include <chrono>
#include <thread>

struct AetherContext {
    llama_model*   model   = nullptr;
    llama_context* ctx     = nullptr;
    llama_sampler* sampler = nullptr;
    int n_threads;
    int n_ctx;
    std::string model_name;
    float last_toks_per_sec = 0.f;
};

// ── Lifecycle ──────────────────────────────────────────────────────────────

AetherContext* aether_load(const char* model_path,
                            int n_threads,
                            int n_ctx,
                            int n_gpu_layers) {
    llama_backend_init();

    llama_model_params mp = llama_model_default_params();
    mp.n_gpu_layers = n_gpu_layers;

    llama_model* model = llama_model_load_from_file(model_path, mp);
    if (!model) return nullptr;

    llama_context_params cp = llama_context_default_params();
    cp.n_ctx      = (n_ctx > 0) ? n_ctx : 4096;
    cp.n_threads  = (n_threads > 0) ? n_threads
                                     : (int)std::thread::hardware_concurrency() / 2;
    cp.n_threads_batch = cp.n_threads;

    llama_context* ctx = llama_init_from_model(model, cp);
    if (!ctx) {
        llama_model_free(model);
        return nullptr;
    }

    // Default sampler chain: top-p + temperature + greedy
    llama_sampler* sampler = llama_sampler_chain_init(
        llama_sampler_chain_default_params());
    llama_sampler_chain_add(sampler,
        llama_sampler_init_top_p(0.9f, 1));
    llama_sampler_chain_add(sampler,
        llama_sampler_init_temp(0.8f));
    llama_sampler_chain_add(sampler,
        llama_sampler_init_greedy());

    auto* ac = new AetherContext;
    ac->model      = model;
    ac->ctx        = ctx;
    ac->sampler    = sampler;
    ac->n_threads  = cp.n_threads;
    ac->n_ctx      = cp.n_ctx;
    ac->model_name = std::string(model_path);
    // Trim to basename
    auto slash = ac->model_name.rfind('/');
    if (slash != std::string::npos)
        ac->model_name = ac->model_name.substr(slash + 1);

    return ac;
}

void aether_free(AetherContext* ac) {
    if (!ac) return;
    if (ac->sampler) llama_sampler_free(ac->sampler);
    if (ac->ctx)     llama_free(ac->ctx);
    if (ac->model)   llama_model_free(ac->model);
    llama_backend_free();
    delete ac;
}

// ── Tokenization helpers ────────────────────────────────────────────────────

static std::vector<llama_token> tokenize(const llama_vocab* vocab,
                                          const std::string& text,
                                          bool add_bos) {
    const int n = -llama_tokenize(vocab,
                                   text.c_str(), (int)text.size(),
                                   nullptr, 0, add_bos, true);
    std::vector<llama_token> toks(n);
    llama_tokenize(vocab, text.c_str(), (int)text.size(),
                   toks.data(), (int)toks.size(), add_bos, true);
    return toks;
}

// ── Core inference ──────────────────────────────────────────────────────────

static std::string _infer_impl(AetherContext* ac,
                                const std::string& prompt,
                                int max_tokens,
                                float temperature,
                                float top_p,
                                AetherTokenCallback cb,
                                void* user_data) {
    if (!ac) return "";

    // Re-configure sampler with caller params
    llama_sampler_free(ac->sampler);
    ac->sampler = llama_sampler_chain_init(
        llama_sampler_chain_default_params());
    llama_sampler_chain_add(ac->sampler,
        llama_sampler_init_top_p(top_p > 0 ? top_p : 0.9f, 1));
    llama_sampler_chain_add(ac->sampler,
        llama_sampler_init_temp(temperature > 0 ? temperature : 0.8f));
    llama_sampler_chain_add(ac->sampler,
        llama_sampler_init_greedy());

    llama_memory_clear(llama_get_memory(ac->ctx), true);

    const llama_vocab* vocab = llama_model_get_vocab(ac->model);
    auto prompt_tokens = tokenize(vocab, prompt, true);
    if ((int)prompt_tokens.size() >= ac->n_ctx) {
        // Truncate to fit context
        prompt_tokens.erase(prompt_tokens.begin(),
            prompt_tokens.begin() +
            ((int)prompt_tokens.size() - ac->n_ctx + 128));
    }

    // Evaluate prompt in one batch
    llama_batch batch = llama_batch_get_one(
        prompt_tokens.data(), (int)prompt_tokens.size());
    if (llama_decode(ac->ctx, batch)) return "";

    const int         max_gen = (max_tokens > 0) ? max_tokens : 512;
    const llama_token eos     = llama_vocab_eos(vocab);
    (void)llama_vocab_n_tokens(vocab); // available if needed for future sampling

    std::string output;
    auto t0 = std::chrono::high_resolution_clock::now();
    int n_gen = 0;

    while (n_gen < max_gen) {
        llama_token tok = llama_sampler_sample(ac->sampler, ac->ctx, -1);
        if (tok == eos) break;

        char buf[256] = {};
        int len = llama_token_to_piece(vocab, tok, buf, sizeof(buf)-1, 0, true);
        if (len < 0) break;
        buf[len] = '\0';

        output += buf;
        n_gen++;

        if (cb) {
            if (!cb(buf, user_data)) break;
        }

        // Feed single token for next step
        llama_batch next = llama_batch_get_one(&tok, 1);
        if (llama_decode(ac->ctx, next)) break;
    }

    auto t1 = std::chrono::high_resolution_clock::now();
    double elapsed = std::chrono::duration<double>(t1 - t0).count();
    ac->last_toks_per_sec = (elapsed > 0) ? (float)(n_gen / elapsed) : 0;

    return output;
}

// ── Public API ──────────────────────────────────────────────────────────────

char* aether_infer(AetherContext* ctx,
                   const char* prompt,
                   int max_tokens,
                   float temperature,
                   float top_p,
                   int /*repeat_penalty_last_n*/) {
    auto result = _infer_impl(ctx, prompt, max_tokens,
                               temperature, top_p, nullptr, nullptr);
    char* out = (char*)malloc(result.size() + 1);
    if (out) {
        memcpy(out, result.c_str(), result.size() + 1);
    }
    return out;
}

void aether_free_string(char* str) { free(str); }

void aether_infer_stream(AetherContext* ctx,
                         const char* prompt,
                         int max_tokens,
                         float temperature,
                         float top_p,
                         AetherTokenCallback callback,
                         void* user_data) {
    _infer_impl(ctx, prompt, max_tokens, temperature, top_p,
                callback, user_data);
}

const char* aether_model_name(AetherContext* ac) {
    if (!ac) return "";
    return ac->model_name.c_str();
}

float aether_last_toks_per_sec(AetherContext* ac) {
    if (!ac) return 0.f;
    return ac->last_toks_per_sec;
}
