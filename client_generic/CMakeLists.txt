# -----------------------------------------------------------------------------
# Electric Sheep Client - CMake Configuration
# -----------------------------------------------------------------------------
# This file manages the build process for the Electric Sheep client.
# It uses vcpkg for dependency management and supports modern C++17.
# -----------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.20)
project(ElectricSheep VERSION 2.7.33)

# --- Global Settings ---
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Force static runtime for compatibility with static vcpkg triplets (x64-windows-static)
if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

# --- Dependency Management ---

# Boost: Core utility library
find_package(Boost REQUIRED COMPONENTS thread filesystem system)

# wxWidgets: Cross-platform GUI framework
find_package(wxWidgets REQUIRED COMPONENTS core base richtext)

# CURL: Networking library for sheep downloads/uploads
find_package(CURL REQUIRED)

# Threads: Standard threading support
find_package(Threads REQUIRED)


# OpenGL: Required for Linux rendering
if(UNIX AND NOT APPLE)
    find_package(OpenGL REQUIRED)
    find_package(X11 REQUIRED)
    if(NOT X11_Xrender_FOUND)
         find_library(X11_Xrender_LIB Xrender)
    endif()
    link_libraries(${X11_LIBRARIES} ${X11_Xrender_LIB})
endif()

# DirectX: Required for Windows rendering
if(WIN32)
    # Legacy D3DX9 support via vcpkg dxsdk-d3dx
    find_package(dxsdk-d3dx CONFIG REQUIRED)
endif()

# FFmpeg: Multimedia decoding
# NOTE: vcpkg FFmpeg build may fail on some systems due to MSYS2 constraints.
# If vcpkg fails, manually download the FFmpeg SDK and extract to 'ffmpeg_sdk'.
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg_sdk")
    message(STATUS "Using manual FFmpeg SDK from ${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg_sdk")
    set(FFMPEG_FOUND TRUE)
    set(FFMPEG_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg_sdk/include")
    set(FFMPEG_LIBRARIES 
        "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg_sdk/lib/avcodec.lib"
        "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg_sdk/lib/avformat.lib"
        "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg_sdk/lib/avutil.lib"
        "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg_sdk/lib/swscale.lib"
        "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg_sdk/lib/swresample.lib"
    )
else()
    # Attempt to find via standard path or vcpkg
    if(WIN32)
        find_package(FFmpeg COMPONENTS avcodec avformat swscale avutil swresample)
    elseif(UNIX)
        find_package(PkgConfig REQUIRED)
        pkg_check_modules(FFMPEG REQUIRED libavcodec libavformat libavutil libswscale libswresample)
        # pkg-config returns FFMPEG_LIBRARIES and FFMPEG_INCLUDE_DIRS which works with the existing include_directories calls
        # We might need to handle individual targets if the link step is granular, but the existing code uses ${FFMPEG_LIBRARIES}
    endif()
endif()

# Lua: Scripting engine (vcpkg provides Lua 5.4)
find_package(Lua REQUIRED)

# ZLIB: Required for decompression
find_package(ZLIB REQUIRED)
include_directories(${ZLIB_INCLUDE_DIRS})
link_libraries(${ZLIB_LIBRARIES})

# PNG: Required for LoadPNG
find_package(PNG REQUIRED)
include_directories(${PNG_INCLUDE_DIRS})
link_libraries(${PNG_LIBRARIES})

# GLUT: Required for glutInit
find_package(GLUT REQUIRED)
include_directories(${GLUT_INCLUDE_DIR})
link_libraries(${GLUT_LIBRARIES})

# GTop: Required for Linux CPU usage
if(UNIX AND NOT APPLE)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(LIBGTOP REQUIRED libgtop-2.0)
    include_directories(${LIBGTOP_INCLUDE_DIRS})
    link_directories(${LIBGTOP_LIBRARY_DIRS})
    link_libraries(${LIBGTOP_LIBRARIES})
endif()

# TinyXML: XML parsing
if(WIN32)
    find_package(tinyxml CONFIG REQUIRED)
elseif(UNIX)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(TINYXML REQUIRED tinyxml)
    
    # Create an alias library to match the vcpkg target name
    add_library(unofficial-tinyxml::unofficial-tinyxml INTERFACE IMPORTED)
    target_link_libraries(unofficial-tinyxml::unofficial-tinyxml INTERFACE ${TINYXML_LIBRARIES})
    target_include_directories(unofficial-tinyxml::unofficial-tinyxml INTERFACE ${TINYXML_INCLUDE_DIRS})
endif()

# --- Source File Definitions ---

set(COMMON_SRCS
    Common/AlignedBuffer.cpp
    Common/Common.cpp
    Common/Exception.cpp
    Common/Log.cpp
    Common/LuaState.cpp
    Common/luaxml.cpp
    Common/md5.c
    Common/pool.cpp
    Common/isaac.cpp
    Common/Math/Rect.cpp
)

set(DISPLAY_SRCS
    DisplayOutput/DisplayOutput.cpp
    DisplayOutput/Image.cpp
    DisplayOutput/LoadDDS.cpp
    DisplayOutput/LoadPNG.cpp
    DisplayOutput/Renderer/Font.cpp
    DisplayOutput/Renderer/Renderer.cpp
    DisplayOutput/Renderer/Shader.cpp
    DisplayOutput/Renderer/Texture.cpp
    DisplayOutput/Renderer/TextureFlat.cpp
)

if(WIN32)
    list(APPEND DISPLAY_SRCS
        DisplayOutput/DirectX/DisplayDX.cpp
        DisplayOutput/DirectX/FontDX.cpp
        DisplayOutput/DirectX/RendererDX.cpp
        DisplayOutput/DirectX/ShaderDX.cpp
        DisplayOutput/DirectX/TextureFlatDX.cpp
    )
elseif(UNIX AND NOT APPLE)
    list(APPEND DISPLAY_SRCS
        DisplayOutput/OpenGL/glx.cpp
        DisplayOutput/OpenGL/RendererGL.cpp
        DisplayOutput/OpenGL/FontGL.cpp
        DisplayOutput/OpenGL/TextureFlatGL.cpp
        DisplayOutput/OpenGL/ShaderGL.cpp
        DisplayOutput/OpenGL/GLee.c
    )
endif()

set(DECODER_SRCS
    ContentDecoder/ContentDecoder.cpp
)

set(DOWNLOADER_SRCS
    ContentDownloader/ContentDownloader.cpp
    ContentDownloader/Sheep.cpp
    ContentDownloader/SheepDownloader.cpp
    ContentDownloader/SheepGenerator.cpp
    ContentDownloader/SheepUploader.cpp
    ContentDownloader/Shepherd.cpp
)

set(NETWORKING_SRCS
    Networking/Download.cpp
    Networking/Networking.cpp
    Networking/Upload.cpp
)

set(STORAGE_SRCS
    TupleStorage/diriterator.cpp
    TupleStorage/luastorage.cpp
    TupleStorage/storage.cpp
)

set(CLIENT_SRCS
    Client/Hud.cpp
    Client/main.cpp
    Client/Player.cpp
    Client/Voting.cpp
)

# --- Target Definition ---

add_executable(electricsheep WIN32
    ${COMMON_SRCS}
    ${DISPLAY_SRCS}
    ${DECODER_SRCS}
    ${DOWNLOADER_SRCS}
    ${NETWORKING_SRCS}
    ${STORAGE_SRCS}
    ${CLIENT_SRCS}
)

# --- Include Directories ---

target_include_directories(electricsheep PRIVATE
    .
    Common
    Common/Math
    ContentDecoder
    ContentDownloader
    Networking
    TupleStorage
    Client
    DisplayOutput
    DisplayOutput/Renderer
    msvc
    ${Boost_INCLUDE_DIRS}
    ${wxWidgets_INCLUDE_DIRS}
    ${CURL_INCLUDE_DIRS}
    ${FFMPEG_INCLUDE_DIRS}
    ${LUA_INCLUDE_DIR}
)

if(WIN32)
    target_include_directories(electricsheep PRIVATE DisplayOutput/DirectX)
    # Compatibility path for vcpkg's dxsdk-d3dx header structure
    target_include_directories(electricsheep PRIVATE ${CMAKE_BINARY_DIR}/vcpkg_installed/x64-windows-static/include/dxsdk-d3dx)
elseif(UNIX AND NOT APPLE)
    target_include_directories(electricsheep PRIVATE DisplayOutput/OpenGL)
endif()

# --- Link Libraries ---

target_link_libraries(electricsheep
    PRIVATE
    ${Boost_LIBRARIES}
    ${wxWidgets_LIBRARIES}
    CURL::libcurl
    ${FFMPEG_LIBRARIES}
    ${LUA_LIBRARIES}
    unofficial-tinyxml::unofficial-tinyxml
    Threads::Threads
)

if(WIN32)
    # Define TIXML_USE_STL for TinyXML compatibility
    target_compile_definitions(electricsheep PRIVATE WIN32 _WINDOWS NOMINMAX TIXML_USE_STL)
    
    # System Libraries and DirectX targets
    target_link_libraries(electricsheep PRIVATE 
        ws2_32 wldap32 shlwapi psapi d3d9 d3d11 dxgi
        Microsoft::D3DX9
    )
elseif(UNIX AND NOT APPLE)
     if(NOT DEFINED SHAREDIR)
        set(SHAREDIR "/usr/share/electricsheep/")
     endif()
     target_compile_definitions(electricsheep PRIVATE LINUX LINUX_GNU TIXML_USE_STL SHAREDIR="${SHAREDIR}" GL_GLEXT_LEGACY GLX_GLXEXT_LEGACY)
     target_link_libraries(electricsheep PRIVATE
        OpenGL::GL
        X11::X11
        ${CMAKE_DL_LIBS}
     )
endif()

# --- Post-Build Steps (Optional) ---
# Add resource files or manifest embedding here if needed.
