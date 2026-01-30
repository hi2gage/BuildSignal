# BuildSignal

A macOS developer tool for analyzing and managing Xcode build warnings and deprecations.

## Features

- 📊 **Visual Build Analysis** - Parse Xcode build logs and visualize warnings
- 🔍 **Smart Filtering** - Filter warnings by category, file, or scope
- ⚠️ **Deprecation Tracking** - Track and manage deprecated API usage
- 📁 **Project Organization** - Browse warnings by directory structure
- ⭐ **Favorites & Hidden** - Mark important warnings or hide resolved issues
- 🎯 **Category Management** - Create custom warning categories with regex patterns

## Installation

### Homebrew (Recommended)

```bash
brew install hi2gage/hi2gage/buildsignal
```

### Manual Download

Download the latest release from [GitHub Releases](https://github.com/hi2gage/BuildSignal/releases)

## Usage

1. **Open BuildSignal**
2. **Browse DerivedData** or drag a build log JSON file
3. **Analyze warnings** by category, file, or custom filters
4. **Manage technical debt** by favoriting or hiding issues

## Requirements

- macOS 15.0 or later
- Xcode (for build log generation)

## Development

Built with:
- Swift 6.0
- SwiftUI
- XCLogParser

### Building from Source

```bash
git clone https://github.com/hi2gage/BuildSignal.git
cd BuildSignal
open BuildSignal.xcodeproj
```

Configuration uses `.xcconfig` files. Copy `Config/Secrets.xcconfig.template` to `Config/Secrets.xcconfig` and add your Team ID.

## License

[Add your license here - MIT recommended]

## Author

Gage Halverson ([@hi2gage](https://github.com/hi2gage))
