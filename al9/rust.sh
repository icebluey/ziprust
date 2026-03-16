#!/bin/bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
CC=gcc
export CC
CXX=g++
export CXX
/sbin/ldconfig

set -euo pipefail

rm -fr /usr/local/rust
mkdir /usr/local/rust

export CARGO_HOME=/usr/local/rust
export RUSTUP_HOME=/usr/local/rust

cd /tmp
rm -fr /tmp/*
_stable_ver="$(wget -qO- 'https://forge.rust-lang.org/infra/other-installation-methods.html' | grep -i x86_64-unknown-linux-gnu | sed 's|"|\n|g' | grep -ivE 'alpha|beta|night' | grep -i "https://.*x86_64-unknown-linux-gnu" | sed 's|.*rust-||g; s|-x86.*||g' | sort -V | tail -n 1)"
curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs -o install_rust.sh
bash install_rust.sh -v --default-host x86_64-unknown-linux-gnu --default-toolchain ${_stable_ver} --profile default -y
echo ""
ls -lah /usr/local/rust
echo ""
. /usr/local/rust/env
cargo install cargo-download
cargo install cargo-outdated
cargo install cargo-edit
rustup target add x86_64-pc-windows-msvc
cargo install cargo-xwin
find /usr/local/rust -mindepth 1 -maxdepth 1 -name '.*' ! -name '.' ! -name '..' -exec rm -rf -- {} +
rm -fr /usr/local/rust/registry
rm -fr /usr/local/rust/downloads /usr/local/rust/tmp
mkdir /usr/local/rust/downloads /usr/local/rust/tmp
find /usr/local/rust/bin/ -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[[:space:]]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' strip '{}'
find /usr/local/rust/toolchains/*linux-gnu/bin/ -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[[:space:]]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' strip '{}'
echo ""
ls -lah /usr/local/rust
echo ""
sed "/export PATH=/a\        export CARGO_HOME='.cargo'" -i /usr/local/rust/env
sed "/export PATH=/a\        export RUSTUP_HOME='/usr/local/rust'" -i /usr/local/rust/env
cat /usr/local/rust/env
cd /usr/local
_rust_ver="$(./rust/bin/rustc --version | awk '{print $2}')"
tar -cf "rust-v${_rust_ver}-stable-x86_64-el9.tar" rust
sleep 2
rm -fr rust
xz -f -z -9 -k -T$(($(nproc) - 1)) "rust-v${_rust_ver}-stable-x86_64-el9.tar"
sleep 2
sha256sum -b "rust-v${_rust_ver}-stable-x86_64-el9.tar".xz > "rust-v${_rust_ver}-stable-x86_64-el9.tar".xz.sha256
rm -f "rust-v${_rust_ver}-stable-x86_64-el9.tar"

rm -fr /tmp/_output
mkdir /tmp/_output
mv -v "rust-v${_rust_ver}-stable-x86_64-el9.tar".xz* /tmp/_output/

echo ""
echo ' done'
echo ""
exit

