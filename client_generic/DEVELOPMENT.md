# Electric Sheep - Internal Development Guide

This document provides technical details for developers working on the Electric Sheep client.

## Architecture Overview

The client is responsible for:

1. **Downloading Sheep**: Communicating with the server to download flame fractal frames.
2. **Decoding**: Using FFmpeg to decode the downloaded sheep animations.
3. **Rendering**: Using DirectX (currently) or OpenGL to display the animations as a screen saver or standalone app.
4. **Generating**: Periodically using the `flam3` engine to generate new sheep frames (if configured).
5. **Voting**: Handling user interaction to vote for preferred sheep.

## Recent Modernization Changes

### Lua 5.4 Migration

The codebase was updated from an ancient Lua version to Lua 5.4. Key changes include:

- Replaced `lua_cpcall` with `lua_pcall`.
- Replaced `luaL_register` with `luaL_setfuncs`.
- Replaced `luaL_checkint` with `luaL_checkinteger`.
- Fixed `LUA_GLOBALSINDEX` usage by using `lua_setglobal` and `lua_getglobal`.
- Updated `luaxml.cpp` and `LuaState.cpp` to handle the new Lua stack and API.

### Boost.Filesystem 1.8x

Refactored usage of `boost::filesystem` to match modern APIs:

- Replaced `initial_path()` with `current_path()`.
- Replaced `leaf()` with `filename()`.
- Fully qualified all `boost::filesystem` types to avoid namespace conflicts.
- Fixed deprecated header includes.

### Windows API & Unicode

- Standardized on ANSI (`A` suffix) Windows API calls where necessary to match the codebase's string handling.
- Optimized window creation in `DisplayDX.cpp` for modern Windows versions.
- Added `COMPILE_MULTIMON_STUBS` to resolve multi-monitor API linking issues.

### FFmpeg Integration

The client now links against FFmpeg 7.1. The interface logic in `ContentDecoder` has been adjusted for modern FFmpeg header layouts.

## GPU Acceleration Path

The next priority is moving rendering from legacy DirectX 9 to a modern GPU API.
The abstraction layer in `DisplayOutput/Renderer` should be extended to support:

- **DirectX 11/12**: Best for Windows compatibility.
- **Vulkan**: Best for cross-platform support.

## Troubleshooting

- **Library Mismatch**: If you see `LNK2038` errors, ensure you are using the `x64-windows-static` triplet in vcpkg and that `CMAKE_MSVC_RUNTIME_LIBRARY` is set to `MultiThreaded`.
- **TinyXML**: The project uses the STL version of TinyXML. Ensure `TIXML_USE_STL` is defined (handled by CMake).
