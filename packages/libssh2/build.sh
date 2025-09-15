#!/usr/bin/env bash
set -euo pipefail

NAME="libssh2"
VERSION="${VERSION:-1.9.1}"  # Use environment variable or default to 1.9.1
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

echo "Building $NAME version $VERSION for $OS/$ARCH"



HW_CONCURRENCY=$(nproc --all)


WORKDIR=$(pwd)
mkdir -p "$WORKDIR/out"
OUT="$WORKDIR/out"

curl -L "https://www.libssh2.org/download/libssh2-${VERSION}.tar.gz" | tar xz 

cd "libssh2-$VERSION"

./configure --prefix="$OUT" \
            --with-openssl \
            --with-libz \
            --disable-examples-build

make --jobs "$HW_CONCURRENCY" install


echo $WORKDIR

# tar -czf $WORKDIR/${NAME}_${VERSION}_${OS}_${ARCH}.tar.gz -C $OUT .

tar -czf $WORKDIR/release.tar.gz -C $OUT .


echo " (*) Done."