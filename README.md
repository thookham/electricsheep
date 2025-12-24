# 🌌 Electric Sheep Modernized

![Electric Sheep Logo](https://raw.githubusercontent.com/scottdraves/electricsheep/master/client_generic/Client/res/sheep_icon.ico)

**Electric Sheep** is a collaborative abstract art project. It's a cyborg mind that harnesses the collective power of thousands of computers and people to evolve organic, infinite animations known as "sheep."

This fork modernizes the build system and codebase for the modern era.

## ✨ Modernization Features

- 🛠️ **CMake Build System**: Replaced legacy Visual Studio solutions with a clean, cross-platform CMake system.
- 📦 **vcpkg Integration**: Hassle-free dependency management for Boost, wxWidgets, CURL, Lua, and TinyXML.
- 🚀 **C++17 Standards**: Updated the codebase to use modern C++17 features and conventions.
- 📂 **Legacy Consolidation**: Merged `dankamongmen` standalone client code into `legacy_standalone/`.
- 🌕 **Lua 5.4**: Upgraded the internal scripting engine from legacy Lua to the latest 5.4 release.
- 📂 **Boost 1.8x**: Refactored filesystem and threading logic to work with modern Boost APIs.
- 🖥️ **Win32 Modernization**: Fixed Unicode/ANSI character set mismatches and optimized for 64-bit Windows.

## 🛠️ Build Instructions

### Prerequisites

1. **Visual Studio 2022** with C++ Desktop Development.
2. **vcpkg**: Installed and available in your path.
3. **CMake** 3.20 or newer.

### Getting Dependencies

The build uses `vcpkg` in manifest mode. Most dependencies will be downloaded and built automatically.

```bash
cd client_generic
vcpkg install --triplet x64-windows-static
```

> [!IMPORTANT]
> **FFmpeg Note**: Due to MSYS2 build constraints on some Windows systems, `vcpkg` might fail to build FFmpeg. If this happens, download the [BtbN FFmpeg SDK](https://github.com/BtbN/FFmpeg-Builds/releases) and extract it to `client_generic/ffmpeg_sdk`.

### Compilation

```bash
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=[PATH_TO_VCPKG]/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static
cmake --build . --config Release
```bash
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=[PATH_TO_VCPKG]/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static
cmake --build . --config Release
```

### Linux / WSL Build

For Debian/Ubuntu-based systems (including WSL/WSL2):

1. **Install Dependencies**:
   Run the helper script to install build tools and libraries (wxWidgets, FFmpeg, GLee deps, etc.):
   ```bash
   cd client_generic
   sudo ./install_deps_linux.sh
   ```

2. **Compilation**:
   ```bash
   mkdir -p build && cd build
   cmake ..
   make -j$(nproc)
   ```

3. **Run**:
   Ensure you have an X server running (for WSL), then execute:
   ```bash
   ./electricsheep
   ```

## 🗺️ Roadmap

- [ ] **GPU Acceleration**: Implement Vulkan/D3D11 rendering paths for sheep animations.
- [ ] **Modern UI**: Update the wxWidgets interface with a more contemporary aesthetic.
- [ ] **Cross-Platform**: Full support for macOS and Linux using the new CMake system.
- [ ] **CI/CD**: Automate builds and releases using GitHub Actions.

## 📜 License

Electric Sheep is licensed under the **GPLv2**.
Original Creator: [Scott Draves](http://scottdraves.com)
Official Website: [electricsheep.org](http://electricsheep.org)

---
*Built with ❤️ by the persistence of collective dreams.*
