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
curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs -o install_rust.sh
bash install_rust.sh -v --default-host x86_64-unknown-linux-gnu --default-toolchain stable --profile default -y
echo ""
ls -lah /usr/local/rust
echo ""
. /usr/local/rust/env
cargo install cargo-download
cargo install cargo-outdated
rustup target add x86_64-pc-windows-msvc
cargo install cargo-xwin
find /usr/local/rust -mindepth 1 -maxdepth 1 -name '.*' ! -name '.' ! -name '..' -exec rm -rf -- {} +
rm -fr /usr/local/rust/registry
rm -fr /usr/local/rust/downloads/*
rm -fr /usr/local/rust/tmp/*
find /usr/local/rust/bin/ -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[[:space:]]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' strip '{}'
find /usr/local/rust/toolchains/stable-x86_64-unknown-linux-gnu/bin/ -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[[:space:]]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' strip '{}'
echo ""
ls -lah /usr/local/rust
echo ""
cd /usr/local
_rust_ver="$(./rust/bin/rustc --version | awk '{print $2}')"
tar -cf "rust-v${_rust_ver}-stable-x86_64-ub2204.tar" rust
sleep 2
rm -fr rust
xz -f -z -9 -k -T$(($(nproc) - 1)) "rust-v${_rust_ver}-stable-x86_64-ub2204.tar"
sleep 2
sha256sum -b "rust-v${_rust_ver}-stable-x86_64-ub2204.tar".xz > "rust-v${_rust_ver}-stable-x86_64-ub2204.tar".xz.sha256
rm -f "rust-v${_rust_ver}-stable-x86_64-ub2204.tar"

rm -fr /tmp/_output
mkdir /tmp/_output
mv -v "rust-v${_rust_ver}-stable-x86_64-ub2204.tar".xz* /tmp/_output/

echo ""
echo ' done'
echo ""
exit

