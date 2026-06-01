import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
const SYSTEM_PROMPT = `You are Primax AI — an intelligent assistant embedded in the Primax platform.
You help users understand their subscription entitlements, project analytics, and usage insights.
You are precise, concise, and always ground your answers in the data provided.
Never fabricate data. If information is missing, say so clearly.`;
function selectBackend() {
  const nimKey = Deno.env.get("NIM_API_KEY");
  const nimUrl = Deno.env.get("NIM_BASE_URL") ?? "https://integrate.api.nvidia.com/v1";
  const nimModel = Deno.env.get("NIM_MODEL") ?? "meta/llama-3.1-8b-instruct";
  if (nimKey) return {
    baseUrl: nimUrl,
    apiKey: nimKey,
    model: nimModel
  };
  const geminiKey = Deno.env.get("GEMINI_API_KEY");
  if (geminiKey) return {
    baseUrl: "https://generativelanguage.googleapis.com/v1beta/openai",
    apiKey: geminiKey,
    model: "gemini-2.0-flash"
  };
  const openaiKey = Deno.env.get("OPENAI_API_KEY");
  if (openaiKey) return {
    baseUrl: "https://api.openai.com/v1",
    apiKey: openaiKey,
    model: "gpt-4o-mini"
  };
  return null;
}
Deno.serve(async (req)=>{
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, content-type"
      }
    });
  }
  // Auth
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({
      error: "Unauthorized"
    }, 401);
  }
  const supabase = createClient(Deno.env.get("SUPABASE_URL"), Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"));
  const { data: { user }, error: authError } = await supabase.auth.getUser(authHeader.replace("Bearer ", ""));
  if (authError || !user) {
    return json({
      error: "Unauthorized"
    }, 401);
  }
  // Parse request
  let body;
  try {
    body = await req.json();
  } catch  {
    return json({
      error: "Invalid JSON body"
    }, 400);
  }
  if (!body.prompt?.trim()) {
    return json({
      error: "prompt is required"
    }, 400);
  }
  // Optionally enrich context from DB
  let dbContext = body.context ?? "";
  if (body.projectId) {
    const { data: project } = await supabase.from("projects").select("name, slug, status, metadata").eq("id", body.projectId).single();
    if (project) {
      dbContext += `\n\nProject context: ${JSON.stringify(project)}`;
    }
  }
  // Select LLM backend
  const backend = selectBackend();
  if (!backend) {
    return json({
      error: "No LLM backend configured. Set NIM_API_KEY, GEMINI_API_KEY, or OPENAI_API_KEY."
    }, 503);
  }
  const messages = [
    ...dbContext ? [
      {
        role: "user",
        content: `Context:\n${dbContext}`
      },
      {
        role: "assistant",
        content: "Understood. Ready to help."
      }
    ] : [],
    {
      role: "user",
      content: body.prompt
    }
  ];
  const t0 = performance.now();
  let llmRes;
  try {
    llmRes = await fetch(`${backend.baseUrl}/chat/completions`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${backend.apiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: backend.model,
        messages: [
          {
            role: "system",
            content: SYSTEM_PROMPT
          },
          ...messages
        ],
        max_tokens: 1024
      })
    });
  } catch (err) {
    return json({
      error: "LLM request failed",
      detail: err.message
    }, 502);
  }
  const latencyMs = Math.round(performance.now() - t0);
  if (!llmRes.ok) {
    const errText = await llmRes.text();
    return json({
      error: "LLM error",
      detail: errText,
      status: llmRes.status
    }, 502);
  }
  const llmData = await llmRes.json();
  const answer = llmData.choices?.[0]?.message?.content ?? "";
  // Log the run
  await supabase.from("agent_runs").insert({
    agent_name: "primax-ai",
    task_type: "chat",
    input: {
      prompt: body.prompt,
      projectId: body.projectId ?? null
    },
    output: {
      answer
    },
    user_id: user.id,
    meta_json: {
      model: backend.model,
      latency_ms: latencyMs
    }
  }).then(({ error })=>{
    if (error) console.warn("agent_runs insert failed:", error.message);
  });
  return json({
    answer,
    model: backend.model,
    latency_ms: latencyMs
  });
});
function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*"
    }
  });
}
