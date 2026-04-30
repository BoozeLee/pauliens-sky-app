#!/usr/bin/env bash
# Build libaether_llm.so for Linux x64
# Run from repo root: bash scripts/build_llama.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
NATIVE_DIR="$REPO_ROOT/native/llama"
BUILD_DIR="$NATIVE_DIR/build"
OUT_DIR="$REPO_ROOT/linux/libs"

echo "═══ AETHER LLM Build ═══"
echo "Repo: $REPO_ROOT"

# ── Ensure llama.cpp is present ────────────────────────────────────────────
if [ ! -d "$NATIVE_DIR/llama.cpp" ]; then
    echo "Cloning llama.cpp..."
    git clone --depth=1 https://github.com/ggml-org/llama.cpp.git \
        "$NATIVE_DIR/llama.cpp"
fi

# ── Create output directory ────────────────────────────────────────────────
mkdir -p "$OUT_DIR"
mkdir -p "$BUILD_DIR"

# ── CMake configure ────────────────────────────────────────────────────────
cmake -S "$NATIVE_DIR" -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DLLAMA_CURL=OFF \
    -DGGML_CUDA=OFF \
    -DGGML_METAL=OFF \
    -DGGML_VULKAN=OFF \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_SERVER=OFF \
    -GNinja

# ── Build ──────────────────────────────────────────────────────────────────
cmake --build "$BUILD_DIR" --target aether_llm -j$(nproc)

# ── Copy output ────────────────────────────────────────────────────────────
SO=$(find "$BUILD_DIR" -name "libaether_llm.so" | head -1)
if [ -z "$SO" ]; then
    SO=$(find "$OUT_DIR" -name "libaether_llm.so" | head -1)
fi

if [ -n "$SO" ]; then
    cp "$SO" "$OUT_DIR/libaether_llm.so"
    echo "✓ Built: $OUT_DIR/libaether_llm.so"
    ls -lh "$OUT_DIR/libaether_llm.so"
else
    echo "✗ Build succeeded but .so not found in expected location"
    find "$BUILD_DIR" -name "*.so" 2>/dev/null | head -10
    exit 1
fi

echo ""
echo "═══ Next steps ═══"
echo "1. Download a model GGUF file:"
echo "   bash scripts/download_model.sh phi3-mini"
echo ""
echo "2. Run the app:"
echo "   flutter run -d linux"
