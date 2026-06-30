#!/bin/bash -e

workdir="$(pwd)/dxvk-workdir"
install_dir="$workdir/install"

rm -rf "$workdir"
mkdir -p "$workdir"
cd "$workdir"

apt update && apt upgrade -y -qq

apt install build-essential cmake wget unzip tar meson ninja-build glslang-tools git -y -qq

echo "installing mingw cross compilers"

wget https://github.com/mstorsjo/llvm-mingw/releases/download/20260616/llvm-mingw-20260616-ucrt-ubuntu-22.04-aarch64.tar.xz -qnv

tar -xf llvm-mingw-20260616-ucrt-ubuntu-22.04-aarch64.tar.xz

export PATH="$PATH:$workdir/llvm-mingw-20260616-ucrt-ubuntu-22.04-aarch64/bin"

echo "cloning dxvk"

git clone --recursive --depth=1 https://github.com/doitsujin/DXVK

cd DXVK

rm -f build-win64

cat << 'EOF' > build-win64.txt
[binaries]
c = 'arm64ec-w64-mingw32-gcc'
cpp = 'arm64ec-w64-mingw32-g++'
ar = 'arm64ec-w64-mingw32-ar'
strip = 'arm64ec-w64-mingw32-strip'
windres = 'arm64ec-w64-mingw32-windres'

[properties]
needs_exe_wrapper = true

[host_machine]
system = 'windows'
cpu_family = 'aarch64'
cpu = 'armv8'
endian = 'little'
EOF

echo "configuring and compiling"

meson setup dxvk-arm64ec -Dbuildtype=release -Dstrip=enabled -Denable_d3d8=false --prefix="$install_dir" --cross-file build-win64.txt

ninja -C dxvk-arm64ec install

cd "$install_dir"

mv bin system32

zip -r "$workdir/dxvk-arm64ec.zip" system32

cd

exit 0
