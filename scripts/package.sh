#!/usr/bin/env bash

set -euo pipefail

VERSION="${VERSION:-unknown}"  # Use environment variable or default

echo "Starting packaging process for version $VERSION..."
echo "Current working directory: $(pwd)"
echo "Contents of current directory:"
ls -la

echo "Contents of artifacts directory:"
ls -la artifacts/ || echo "No artifacts directory found"

# Create the final artifacts directory
mkdir -p final-artifacts

# Process each artifact directory
for artifact_dir in artifacts/*/; do
    if [ -d "$artifact_dir" ]; then
        artifact_name=$(basename "$artifact_dir")
        echo "Processing artifact: $artifact_name"
        echo "Contents of $artifact_dir:"
        ls -la "$artifact_dir"
        
        # Parse the artifact name to extract OS and arch
        # Expected format: libgit2-{platform}-{arch}
        if [[ $artifact_name =~ libgit2-([^-]+)-([^-]+) ]]; then
            os="${BASH_REMATCH[1]}"
            arch="${BASH_REMATCH[2]}"
            
            echo "  OS: $os, Arch: $arch"
            
            # Create directory structure
            mkdir -p "final-artifacts/$os/$arch"
            
            # Extract the release.tar.gz to the appropriate directory
            if [ -f "$artifact_dir/release.tar.gz" ]; then
                echo "  Extracting to final-artifacts/$os/$arch/"
                tar -xzf "$artifact_dir/release.tar.gz" -C "final-artifacts/$os/$arch/"
                echo "  Extraction complete. Contents:"
                ls -la "final-artifacts/$os/$arch/"
            else
                echo "  Warning: No release.tar.gz found in $artifact_dir"
            fi
        else
            echo "  Warning: Could not parse artifact name format: $artifact_name"
        fi
    fi
done

# Show the final directory structure
echo "Final artifacts structure:"
find final-artifacts -type f | head -20 2>/dev/null || true
echo "..."
echo "Directory structure:"
find final-artifacts -type d | sort

# Create the final release tarball
echo "Creating final-release.tar.gz..."
tar -czf final-release.tar.gz final-artifacts/

echo "Packaging complete. Created final-release.tar.gz"
ls -lah final-release.tar.gz