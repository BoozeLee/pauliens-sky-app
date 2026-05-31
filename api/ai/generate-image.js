// Vercel Serverless Function — AI art generation
// Uses NVIDIA NIM FLUX-1-schnell for high-quality image generation.

const NVDIA_API_KEY = process.env.NVIDIA_API_KEY;
const FLUX_ID = '105fe02c-924b-4dfa-9797-92d89c3936ad';

const STYLE_PROMPTS = {
  astrological: 'Celestial astrological art, mystical atmosphere, starry cosmos, glowing planetary orbs, sacred geometry, zodiac symbolism, ethereal, deep purples and golds,',
  traditional: 'Ancient illuminated manuscript style, rich deep blues and golds, intricate geometric borders, astronomical chart elements, vellum-toned, medieval astronomical art,',
  abstract: 'Abstract cosmic energy, swirling nebulae, vibrant color splashes, dynamic fluid shapes, emotional celestial palette, expressionist cosmic art,',
  minimalist: 'Clean minimalist astrological diagram, thin elegant lines, dark muted palette with selective bright accent colors, zen-like cosmic minimalism, modern celestial,',
  watercolor: 'Soft watercolor wash, bleeding edges, translucent planetary spheres, dreamy atmospheric diffusion, paper texture, ethereal gradient wash, delicate celestial watercolor,',
};

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') { res.status(200).end(); return; }
  if (req.method !== 'POST') { res.status(405).json({ error: 'Method not allowed' }); return; }

  try {
    const { prompt, style } = req.body;
    if (!prompt) { res.status(400).json({ error: 'Missing required field: prompt' }); return; }

    const stylePrefix = STYLE_PROMPTS[style] || STYLE_PROMPTS.astrological;
    const fullPrompt = `${stylePrefix} ${prompt}, highly detailed, masterpiece, sharp focus`.trim();

    const response = await fetch(`https://api.nvcf.nvidia.com/v2/nvcf/pexec/functions/${FLUX_ID}`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${NVDIA_API_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        prompt: fullPrompt,
        width: 1024,
        height: 1024,
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`FLUX error (${response.status}): ${err}`);
    }

    const data = await response.json();
    const artifact = data.artifacts?.[0];
    if (!artifact?.base64) {
      throw new Error('FLUX returned no image data');
    }

    res.status(200).json({
      image: artifact.base64,
      revisedPrompt: fullPrompt,
    });
  } catch (err) {
    console.error('Art generation error:', err);
    res.status(500).json({ error: err.message || 'Internal server error' });
  }
};
