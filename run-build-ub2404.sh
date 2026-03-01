#!/bin/bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -e
cd "$(dirname "$0")"
systemctl start docker
sleep 5
echo
cat /proc/cpuinfo
echo
if [ "$(cat /proc/cpuinfo | grep -i '^processor' | wc -l)" -gt 1 ]; then
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name ub2404 -itd ubuntu:24.04 bash
else
    docker run --rm --name ub2404 -itd ubuntu:24.04 bash
fi
sleep 2
docker exec ub2404 apt update -y -qqq
docker exec ub2404 apt install -y -qqq wget bash gcc g++ cmake m4 pkg-config libc6-dev git curl openssl libssl-dev clang llvm
docker exec ub2404 apt install -y -qqq coreutils binutils findutils util-linux sed gawk tar xz-utils gzip bzip2 file
docker exec ub2404 /bin/bash -c 'ln -svf bash /bin/sh'
docker exec ub2404 apt upgrade -fy -qqq
docker exec ub2404 /bin/bash -c 'rm -fr /tmp/*'
docker cp ub2404 ub2404:/home/
docker exec ub2404 /bin/bash /home/ub2404/rust.sh
mkdir -p /tmp/_output_assets
docker cp ub2404:/tmp/_output /tmp/_output_assets/

exit
