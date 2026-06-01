# pauliens_sky

A new Flutter project.

This project is a starting point for a Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment Variables for Deployment

To deploy this application fully, the following environment variables must be set:

### For Vercel Deployment (API Proxy Functions):
- `NVIDIA_API_KEY` - Key for accessing NVIDIA NIM (LLM chat) and NVCF (image generation)
- `PAULIENS_SKY_AI_PROXY_URL` - Set this in the Flutter app to point to your deployed Vercel AI proxy (e.g., https://your-app.vercel.app/api/ai/neuromorphic-chat)
- `PAULIENS_SKY_APP_URL` - Base URL of your deployed Flutter web app (used by art generation service to construct absolute URLs)

### For Local Development:
These can be set in `.env.client.local` (not committed to git) or via system environment:
- `PAULIENS_SKY_APP_URL` - During development, can be left empty or set to local test URL
- `PAULIENS_SKY_AI_PROXY_URL` - During development, points to local proxy or deployed service

### AI Service Configuration:
The application will attempt to use AI services in this order:
1. Proxy service (if `PAULIENS_SKY_AI_PROXY_URL` is configured)
2. Direct Anthropic API (if `ANTHROPIC_API_KEY` is set)
3. Direct Gemini API (if `GEMINI_API_KEY` is set)
4. Direct OpenAI API (if `OPENAI_API_KEY` is set)
5. Fallback to AETHER offline engine (always available for core astrology features)

# Trigger CI
# Trigger CI again
# Fix CI
# Fix Planet import
# CI Trigger
# Trigger CI build after fixes
# Trigger CI
# Trigger CI again
# Fix CI
# Fix Planet import
# CI Trigger
# Trigger CI build after fixes
# Trigger CI
