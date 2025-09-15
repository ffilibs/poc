# ffilibs

[![License](https://img.shields.io/github/license/ffilibs/poc)](LICENSE)

> Pre-compiled static builds of popular open source libraries for Node.js and Bun

## 🎯 Project Goal

**ffilibs** provides pre-compiled static versions of popular open source libraries, packaged for easy distribution via npm. This eliminates the need to compile native dependencies from source, making it faster and easier to use powerful libraries like `libgit2`, `libssh2`, and others in your JavaScript/TypeScript projects.

### Why ffilibs?

- ⚡ **Fast Installation**: No more waiting for native compilation
- 🔧 **Zero Dependencies**: Static builds with no external library requirements  
- 🌍 **Cross-Platform**: Support for macOS, Windows, and Linux on both x64 and ARM architectures
- 📦 **npm Ready**: Simple `npm install` - no build tools required
- 🦀 **Bun Optimized**: Works seamlessly with Bun's FFI capabilities

## 🚀 Quick Start

### Installation

```bash
npm install @ffilibs/libgit2-beta
```

### Usage with Bun

Bun makes it incredibly easy to call into these native libraries:

```javascript
import { dlopen, ptr, CString } from 'bun:ffi';
import path from 'path';

// Load the library
const lib = dlopen(path.join(process.cwd(), 'node_modules/@ffilibs/libgit2-beta/prebuilds/linux/arm/lib/libgit2.a'), {
  git_libgit2_init: {
    args: [],
    returns: 'int',
  },
  git_libgit2_shutdown: {
    args: [],
    returns: 'int',
  },
  // Add more functions as needed
});

// Initialize libgit2
lib.symbols.git_libgit2_init();

// Your code here...

// Cleanup
lib.symbols.git_libgit2_shutdown();
```

## 📚 Available Libraries

| Library | Version | Description | Package |
|---------|---------|-------------|---------|
| **libgit2** | 1.9.1 | Git implementation library | `@ffilibs/libgit2-beta` |

## 🏗️ Supported Platforms

| Platform | x64 | ARM64 |
|----------|-----|-------|
| **macOS** | ✅ | ✅ |
| **Linux** | ✅ | ✅ |
| **Windows** | ❌ | ❌ |

## 🛠️ Build Process

Each library is built with optimized settings:

- **Static linking**: No external dependencies
- **Release mode**: Optimized for performance  
- **Cross-platform**: Built on GitHub Actions for all supported platforms
- **Consistent configuration**: SSH support enabled where applicable

### Local Building

To build a library locally:

```bash
cd packages/libgit2
./build.sh
```

The build script will:
1. Download the source code
2. Configure with appropriate flags
3. Compile with all CPU cores
4. Package into `release.tar.gz`

## 🤝 Background

This project is inspired by [a tweet from @thdxr](https://x.com/thdxr/status/1962686350357942315):

> "there needs to be a project that provides static builds of common libraries (libgit2, treesitter, yoga, etc) for x64 + ARM + mac/windows/linux and publishes them to npm
> 
> bun makes it stupid easy to call into these, it's just the packaging that is annoying"

## 🔄 Contributing

We welcome contributions! Here's how you can help:

- 🐛 **Report Issues**: Found a bug? [Create an issue](https://github.com/ffilibs/poc/issues)
- 📦 **Request Libraries**: Need another library? Open a feature request
- 🔧 **Improve Builds**: Help optimize build scripts and configurations  
- 📖 **Documentation**: Help improve docs and examples
- 🎃 **Hacktoberfest**: This project participates in Hacktoberfest!

### Adding a New Library

1. Create a new directory in `packages/`
2. Add `build.sh` and `build.ps1` scripts
3. Configure static build with appropriate flags
4. Test on all supported platforms
5. Submit a pull request

### Contact

- **GitHub**: [Create an issue](https://github.com/ffilibs/poc/issues) or pull request
- **X/Twitter**: [@bascodes](https://x.com/bascodes)

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">
  <sub>Built with ❤️ for the JavaScript and Bun community</sub>
</div>
