#!/bin/bash
echo "Installing Electric Sheep Compilation Dependencies..."

# Update package lists
sudo apt-get update

# Install GCC/G++ and CMake (if needed)
sudo apt-get install -y build-essential cmake

# Install Dependencies
# wxWidgets (GTK3), CURL, Lua 5.4, TinyXML, Boost
sudo apt-get install -y \
    libwxgtk3.2-dev \
    libcurl4-openssl-dev \
    liblua5.4-dev \
    libtinyxml-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libswresample-dev \
    libboost-all-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libx11-dev \
    libxt-dev \
    freeglut3-dev \
    libxrender-dev \
    libpng-dev \
    libgtop2-dev

echo "Dependencies installed. Please try the build again."
