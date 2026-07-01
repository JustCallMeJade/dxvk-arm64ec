#!/bin/bash -e

workdir="$(pwd)/dxvk-workdir"
install_dir="$workdir/install"
VERSION="3.0"

rm -rf "$workdir"
mkdir -p "$workdir"
cd "$workdir"

sudo apt update && sudo apt upgrade -y -qq

sudo apt install build-essential cmake wget unzip tar meson ninja-build glslang-tools git zip -y -qq

echo "installing mingw cross compilers"

wget https://github.com/mstorsjo/llvm-mingw/releases/download/20260616/llvm-mingw-20260616-ucrt-ubuntu-22.04-aarch64.tar.xz -qnv

tar -xf llvm-mingw-20260616-ucrt-ubuntu-22.04-aarch64.tar.xz

sudo export PATH="$PATH:$workdir/llvm-mingw-20260616-ucrt-ubuntu-22.04-aarch64/bin"

echo "cloning dxvk"

git clone --recursive --depth=1 https://github.com/doitsujin/DXVK

cd DXVK

sudo rm -f build-win64

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

meson setup dxvk-arm64ec -Dbuildtype=release -Dstrip=true --prefix="$install_dir" --cross-file build-win64.txt

ninja -C dxvk-arm64ec install

cd "$install_dir"

mv bin system32

cat > profile.json << 'EOF'
{
  "type": "DXVK",
  "versionName": "dxvk-$VERSION-arm64ec",
  "versionCode": 1,
  "description": "dxvk-$VERSION-arm64ec compiled by source + arm64ec",
  "files": [
    {
      "source": "system32/d3d8.dll",
      "target": "${system32}/d3d8.dll"
    },
    {
      "source": "system32/d3d9.dll",
      "target": "${system32}/d3d9.dll"
    },
    {
      "source": "system32/d3d10core.dll",
      "target": "${system32}/d3d10core.dll"
    },
    {
      "source": "system32/d3d11.dll",
      "target": "${system32}/d3d11.dll"
    },
    {
      "source": "system32/dxgi.dll",
      "target": "${system32}/dxgi.dll"
    }
  ]
}
EOF

tar -cJf dxvk-$VERSION-arm64ec.tar.xz system32 profile.json

mv dxvk-$VERSION-arm64ec.tar.xz dxvk-$VERSION-arm64ec.wcp

cd

exit 0
