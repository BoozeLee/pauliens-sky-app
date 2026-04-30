cmake_minimum_required(VERSION 3.16)
project(aether_llm CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# ── Build options ─────────────────────────────────────────────────────────
option(LLAMA_CURL "Enable libcurl" OFF)
option(GGML_CUDA  "Enable CUDA"   OFF)
option(GGML_METAL "Enable Metal"  OFF)
option(GGML_VULKAN "Enable Vulkan" OFF)
option(BUILD_SHARED_LIBS "Build shared libs" ON)

set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE   "-O3 -DNDEBUG -march=native")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -march=native")

# ── llama.cpp (headers + core objects only) ────────────────────────────────
set(LLAMA_DIR ${CMAKE_CURRENT_SOURCE_DIR}/llama.cpp)

# Build llama.cpp as a static lib embedded into our shared lib
add_subdirectory(${LLAMA_DIR} llama_build EXCLUDE_FROM_ALL)

# ── Our thin wrapper ───────────────────────────────────────────────────────
add_library(aether_llm SHARED
    ${CMAKE_CURRENT_SOURCE_DIR}/aether_llm.cpp
)

target_include_directories(aether_llm PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${LLAMA_DIR}/include
    ${LLAMA_DIR}/ggml/include
)

target_link_libraries(aether_llm PRIVATE
    llama
    ggml
)

# Output to Flutter's linux/libs directory
set_target_properties(aether_llm PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}/../../linux/libs
    OUTPUT_NAME aether_llm
)

install(TARGETS aether_llm
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)
