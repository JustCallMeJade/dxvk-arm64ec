#!/bin/bash -e

workdir="$(pwd)/dxvk-workdir"
install_dir="$workdir/install"

mkdir -p "$workdir"

cd workdir

apt update && apt upgrade -y -qq

apt install build-essential cmake wget unzip tar meson ninja-build glslang-tools git -y -qq

wget https://github.com/mstorsjo/llvm-mingw/releases/download/20260616/llvm-mingw-20260616-ucrt-ubuntu-22.04-aarch64.tar.xz -qnv

tar -xf llvm-mingw-20260616-ucrt-ubuntu-22.04-aarch64.tar.xz 

export PATH="$PATH:$workdir/llvm-mingw-20260616-ucrt-ubuntu-22.04-aarch64/bin"

git clone --recursive --depth=1 https://github.com/doitsujin/DXVK

cd DXVK
