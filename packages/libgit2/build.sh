#!/usr/bin/env bash
set -euo pipefail

NAME="libgit2"
VERSION="${VERSION:-1.9.1}"  # Use environment variable or default to 1.9.1
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

echo "Building $NAME version $VERSION for $OS/$ARCH"



HW_CONCURRENCY=$(nproc --all)


WORKDIR=$(pwd)
mkdir -p "$WORKDIR/out"
OUT="$WORKDIR/out"

curl -L "https://github.com/libgit2/libgit2/archive/v$VERSION.tar.gz" | tar xz 

cd "libgit2-$VERSION"

mkdir -p build
cd build

cmake .. -DBUILD_EXAMPLES=OFF \
      -DBUILD_TESTS=OFF \
      -DUSE_SSH=ON \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_INSTALL_PREFIX="$OUT" \
      -DCMAKE_BUILD_TYPE=Release

make --jobs "$HW_CONCURRENCY" install


echo $WORKDIR

# tar -czf $WORKDIR/${NAME}_${VERSION}_${OS}_${ARCH}.tar.gz -C $OUT .

tar -czf $WORKDIR/release.tar.gz -C $OUT .


echo " (*) Done."