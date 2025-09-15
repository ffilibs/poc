#!/usr/bin/env bash

set -euo pipefail

NAME="${NAME:-libgit2}"
VERSION="${VERSION:-1.0.0}"
PACKAGE_VERSION="${PACKAGE_VERSION:-0}"

echo "Starting publish process for $NAME version $VERSION..."

# Create temporary work directory
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# Create package.json with proper name and version
echo "Creating package.json..."
cat > "$TEMP_DIR/package.json" << EOF
{
  "name": "@ffilibs/$NAME-beta",
  "version": "$VERSION-$PACKAGE_VERSION",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "files": [
    "prebuilds/**"
  ]
}
EOF

echo "Package.json created:"
cat "$TEMP_DIR/package.json"

# Create prebuilds directory in temp dir
mkdir -p "$TEMP_DIR/prebuilds"

# Extract the final-release artifact to prebuilds/
echo "Extracting $NAME-final-release.tar.gz to prebuilds/..."
if [ -f "final-release.tar.gz" ]; then
    # First extract to a temp location
    EXTRACT_TEMP=$(mktemp -d)
    tar -xzf "final-release.tar.gz" -C "$EXTRACT_TEMP"
    
    # Move the contents of final-artifacts directly to prebuilds
    if [ -d "$EXTRACT_TEMP/final-artifacts" ]; then
        mv "$EXTRACT_TEMP/final-artifacts"/* "$TEMP_DIR/prebuilds/"
    else
        echo "Warning: Expected final-artifacts directory not found"
        # Fallback: move everything from extract temp
        mv "$EXTRACT_TEMP"/* "$TEMP_DIR/prebuilds/"
    fi
    
    # Cleanup extract temp
    rm -rf "$EXTRACT_TEMP"
    
    echo "Extraction completed."
    
    # Show structure
    echo "Directory structure in temp dir:"
    find "$TEMP_DIR" -type f | head -20 2>/dev/null || true
    echo "..."
    find "$TEMP_DIR" -type d | sort
else
    echo "Error: final-release.tar.gz not found!"
    exit 1
fi

# Create the final npm package tar.gz
echo "Creating npm package archive..."
ORIGINAL_DIR=$(pwd)
cd "$TEMP_DIR"
tar -czf "$ORIGINAL_DIR/npm-package.tar.gz" .
cd "$ORIGINAL_DIR"

# Cleanup temp directory
rm -rf "$TEMP_DIR"

echo "NPM package created successfully: npm-package.tar.gz"
ls -lah npm-package.tar.gz

echo "Package contents:"
tar -tzf npm-package.tar.gz | head -20 2>/dev/null || true

