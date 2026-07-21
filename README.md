# ziprust

```
_install_rust() {
    set -e
    cd /tmp
    rm -fr ~/.cargo ~/.rustup
    rm -fr /root/.cargo /root/.rustup
    rm -fr /usr/local/rust
    mkdir /usr/local/rust
    export CARGO_HOME=/usr/local/rust
    export RUSTUP_HOME=/usr/local/rust
    _stable_ver="$(wget -qO- 'https://forge.rust-lang.org/infra/other-installation-methods.html' | grep -i x86_64-unknown-linux-gnu | sed 's|"|\n|g' | grep -ivE 'alpha|beta|night' | grep -i "https://.*x86_64-unknown-linux-gnu" | sed 's|.*rust-||g; s|-x86.*||g' | sort -V | tail -n 1)"
    rm -fr /tmp/.install_rust.sh
    curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs -o /tmp/.install_rust.sh
    bash /tmp/.install_rust.sh -v --default-host x86_64-unknown-linux-gnu --default-toolchain ${_stable_ver} --profile default -y
    sed "/export PATH=/a\        export CARGO_HOME='.cargo'" -i /usr/local/rust/env
    sed "/export PATH=/a\        export RUSTUP_HOME='/usr/local/rust'" -i /usr/local/rust/env
    source "/usr/local/rust/env"
    cargo --version
    rm -f /tmp/.install_rust.sh
}
```
