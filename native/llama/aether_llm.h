/// aether_llm.h — simplified llama.cpp wrapper for Paulien's Sky
/// Exposes a minimal API that Dart FFI can bind to cleanly.

#pragma once
#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

typedef struct AetherContext AetherContext;

/// Load a GGUF model from disk. Returns NULL on failure.
/// n_threads: CPU threads to use (0 = auto, uses half of logical cores)
/// n_ctx: context window in tokens (2048 for mobile, 4096 for desktop)
AetherContext* aether_load(const char* model_path,
                            int n_threads,
                            int n_ctx,
                            int n_gpu_layers);

/// Free a loaded model context.
void aether_free(AetherContext* ctx);

/// Synchronous inference. Returns a heap-allocated C string.
/// Caller must free with aether_free_string().
/// max_tokens: maximum tokens to generate (-1 = use model default 512)
char* aether_infer(AetherContext* ctx,
                   const char* prompt,
                   int max_tokens,
                   float temperature,
                   float top_p,
                   int repeat_penalty_last_n);

/// Free string returned by aether_infer().
void aether_free_string(char* str);

/// Streaming inference: calls [callback] once per token.
/// callback(token_text, user_data) — return 0 to stop, 1 to continue.
typedef int (*AetherTokenCallback)(const char* token, void* user_data);

void aether_infer_stream(AetherContext* ctx,
                         const char* prompt,
                         int max_tokens,
                         float temperature,
                         float top_p,
                         AetherTokenCallback callback,
                         void* user_data);

/// Returns the model filename that was loaded (for display).
const char* aether_model_name(AetherContext* ctx);

/// Estimated tokens/sec from last inference (0 if not yet run).
float aether_last_toks_per_sec(AetherContext* ctx);

#ifdef __cplusplus
}
#endif
