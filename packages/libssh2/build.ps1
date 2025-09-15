# PowerShell build script for Windows
param(
    [string]$Version
)

$ErrorActionPreference = "Stop"

# Use environment variable or default if Version parameter is not provided
if (-not $Version) {
    $Version = if ($env:VERSION) { $env:VERSION } else { "1.9.1" }
}

$NAME = "libgit2"
$OS = "windows"
$ARCH = $env:PROCESSOR_ARCHITECTURE.ToLower()
if ($ARCH -eq "amd64") { $ARCH = "x64" }

Write-Host "Building $NAME version $Version for $OS/$ARCH"

# Get number of processors for parallel builds
$HW_CONCURRENCY = $env:NUMBER_OF_PROCESSORS

$WORKDIR = Get-Location
$OUT = Join-Path $WORKDIR "out"
New-Item -ItemType Directory -Force -Path $OUT | Out-Null

Write-Host "Downloading libgit2 v$Version..."
$downloadUrl = "https://github.com/libgit2/libgit2/archive/v$Version.tar.gz"
$tarFile = "libgit2-$Version.tar.gz"

# Download using Invoke-WebRequest
Invoke-WebRequest -Uri $downloadUrl -OutFile $tarFile

# Extract using tar (available in Windows 10+)
Write-Host "Extracting..."
tar -xzf $tarFile
Remove-Item $tarFile

# Enter the extracted directory
Set-Location "libgit2-$Version"

# Create build directory
New-Item -ItemType Directory -Force -Path "build" | Out-Null
Set-Location "build"

Write-Host "Configuring with CMake..."
cmake .. -DBUILD_EXAMPLES=OFF `
         -DBUILD_TESTS=OFF `
         -DUSE_SSH=OFF `
         -DUSE_HTTPS=Schannel `
         -DBUILD_SHARED_LIBS=ON `
         -DCMAKE_INSTALL_PREFIX="$OUT" `
         -DCMAKE_BUILD_TYPE=Release `
         -G "Visual Studio 17 2022" `
         -A x64

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: CMake configuration failed!"
    exit 1
}

Write-Host "Building with MSBuild..."
cmake --build . --config Release --target install --parallel $HW_CONCURRENCY

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed!"
    exit 1
}

Write-Host "Build completed. Checking output in: $OUT"
if (Test-Path $OUT) {
    Write-Host "Contents of output directory:"
    Get-ChildItem $OUT -Recurse | ForEach-Object { Write-Host $_.FullName }
} else {
    Write-Host "ERROR: Output directory does not exist!"
    exit 1
}

# Return to work directory
Set-Location $WORKDIR

# Create release archive
Write-Host "Creating release.tar.gz..."
if (Test-Path $OUT) {
    $items = Get-ChildItem $OUT
    if ($items.Count -gt 0) {
        Set-Location $OUT
        tar -czf "$WORKDIR/release.tar.gz" *
        Set-Location $WORKDIR
        Write-Host "Archive created. Size:"
        if (Test-Path "release.tar.gz") {
            $size = (Get-Item "release.tar.gz").Length
            Write-Host "$size bytes"
        }
    } else {
        Write-Host "ERROR: Output directory is empty!"
        exit 1
    }
} else {
    Write-Host "ERROR: Output directory does not exist!"
    exit 1
}

Write-Host "(*) Done. Created release.tar.gz"