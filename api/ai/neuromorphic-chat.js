// Vercel Serverless Function — AI chat proxy
// Routes to NVIDIA NIM, Anthropic, Gemini, or OpenAI using server-side keys.

const NVDIA_API_KEY = process.env.NVIDIA_API_KEY;
const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const NVDIA_MODEL = process.env.NVIDIA_MODEL || 'meta/llama-3.3-70b-instruct';
const OPENAI_MODEL = process.env.OPENAI_MODEL || 'gpt-4o-mini';

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') { res.status(200).end(); return; }
  if (req.method !== 'POST') { res.status(405).json({ error: 'Method not allowed' }); return; }

  try {
    const { provider, system, messages, maxTokens, temperature } = req.body;
    if (!messages) { res.status(400).json({ error: 'Missing required field: messages' }); return; }

    const result = await routeToProvider(provider || 'auto', system, messages, maxTokens, temperature);
    res.status(200).json({ content: result });
  } catch (err) {
    console.error('Chat proxy error:', err);
    res.status(500).json({ error: err.message || 'Internal server error' });
  }
};

async function routeToProvider(preferred, system, messages, maxTokens, temperature) {
  const providers = [];
  if (preferred === 'nvidia' || preferred === 'auto') providers.push(callNvidia);
  if (preferred === 'anthropic' || preferred === 'auto') providers.push(callAnthropic);
  if (preferred === 'gemini' || preferred === 'auto') providers.push(callGemini);
  if (preferred === 'openai' || preferred === 'auto') providers.push(callOpenAi);

  const errors = [];
  for (const callFn of providers) {
    try { return await callFn(system, messages, maxTokens, temperature); }
    catch (e) { errors.push(`${callFn.name.replace('call','')}: ${e.message}`); }
  }
  throw new Error(`All AI providers failed.\n${errors.join('\n')}`);
}

// ── NVIDIA NIM (OpenAI-compatible) ─────────────────────────────────────────

async function callNvidia(system, messages, maxTokens, temperature) {
  const body = [];
  if (system) body.push({ role: 'system', content: system });
  for (const m of messages) body.push({ role: m.role, content: m.content });

  const res = await fetch('https://integrate.api.nvidia.com/v1/chat/completions', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${NVDIA_API_KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model: NVDIA_MODEL,
      messages: body,
      max_tokens: maxTokens || 1024,
      temperature: temperature || 0.85,
    }),
  });

  if (!res.ok) { const err = await res.text(); throw new Error(`NVIDIA error (${res.status}): ${err}`); }
  const data = await res.json();
  return data.choices[0].message.content;
}

// ── Anthropic Claude ────────────────────────────────────────────────────────

async function callAnthropic(system, messages, maxTokens, temperature) {
  if (!ANTHROPIC_API_KEY) throw new Error('Anthropic API key not configured');
  const res = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: { 'x-api-key': ANTHROPIC_API_KEY, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' },
    body: JSON.stringify({
      model: 'claude-sonnet-4-20250514', max_tokens: maxTokens || 1024, temperature: temperature || 0.85,
      system, messages: messages.map(m => ({ role: m.role, content: m.content })),
    }),
  });
  if (!res.ok) { const err = await res.text(); throw new Error(`Anthropic error (${res.status}): ${err}`); }
  const data = await res.json();
  return data.content[0].text;
}

// ── Google Gemini ───────────────────────────────────────────────────────────

async function callGemini(system, messages, maxTokens, temperature) {
  if (!GEMINI_API_KEY) throw new Error('Gemini API key not configured');
  const contents = [];
  let firstUserIdx = messages.findIndex(m => m.role === 'user');
  for (let i = 0; i < messages.length; i++) {
    const m = messages[i];
    let text = m.content;
    if (i === firstUserIdx) text = `${system}\n\n${text}`;
    contents.push({ role: m.role === 'assistant' ? 'model' : 'user', parts: [{ text }] });
  }
  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`,
    { method: 'POST', headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ contents, generationConfig: { maxOutputTokens: maxTokens || 1024, temperature: temperature || 0.85 } }) }
  );
  if (!res.ok) { const err = await res.text(); throw new Error(`Gemini error (${res.status}): ${err}`); }
  const data = await res.json();
  return data.candidates[0].content.parts[0].text;
}

// ── OpenAI GPT ──────────────────────────────────────────────────────────────

async function callOpenAi(system, messages, maxTokens, temperature) {
  const body = [];
  if (system) body.push({ role: 'system', content: system });
  for (const m of messages) body.push({ role: m.role, content: m.content });

  const res = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${OPENAI_API_KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model: OPENAI_MODEL, messages: body, max_tokens: maxTokens || 1024, temperature: temperature || 0.85,
    }),
  });
  if (!res.ok) { const err = await res.text(); throw new Error(`OpenAI error (${res.status}): ${err}`); }
  const data = await res.json();
  return data.choices[0].message.content;
}
