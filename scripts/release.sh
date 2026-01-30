#!/bin/bash
set -e

# BuildSignal Release Script
# Usage: ./scripts/release.sh [version]
# Example: ./scripts/release.sh 0.0.2

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "❌ Error: Version required"
    echo "Usage: ./scripts/release.sh <version>"
    echo "Example: ./scripts/release.sh 0.0.2"
    exit 1
fi

echo "🚀 BuildSignal Release Script"
echo "Version: $VERSION"
echo ""

# Validate version format
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Error: Version must be in format X.Y.Z (e.g., 0.0.2)"
    exit 1
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  Warning: Not on main branch (currently on $CURRENT_BRANCH)"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "❌ Error: You have uncommitted changes"
    echo "Please commit or stash your changes first"
    exit 1
fi

# Check if tag already exists
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
    echo "❌ Error: Tag v$VERSION already exists"
    exit 1
fi

echo "✅ Pre-flight checks passed"
echo ""

# Update version in Config/Shared.xcconfig
echo "📝 Updating version in Config/Shared.xcconfig..."
sed -i '' "s/MARKETING_VERSION = .*/MARKETING_VERSION = $VERSION/" Config/Shared.xcconfig

# Commit version bump
echo "💾 Committing version bump..."
git add Config/Shared.xcconfig
git commit -m "Bump version to $VERSION"

# Create and push tag
echo "🏷️  Creating tag v$VERSION..."
git tag -a "v$VERSION" -m "Release $VERSION"

echo ""
echo "📋 Summary:"
echo "  - Updated version to $VERSION"
echo "  - Created tag v$VERSION"
echo ""
echo "Ready to push?"
echo "This will trigger the release workflow (build, sign, notarize, publish)"
echo ""
read -p "Push to origin? (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Pushing to origin..."
    git push origin main
    git push origin "v$VERSION"

    echo ""
    echo "✅ Release initiated!"
    echo "📦 GitHub Actions will now:"
    echo "   1. Build the app"
    echo "   2. Sign with Developer ID"
    echo "   3. Notarize with Apple"
    echo "   4. Create GitHub Release"
    echo "   5. Update Homebrew cask"
    echo ""
    echo "🔗 Watch progress: https://github.com/hi2gage/BuildSignal/actions"
else
    echo ""
    echo "❌ Release cancelled"
    echo "To push manually later:"
    echo "  git push origin main"
    echo "  git push origin v$VERSION"
    exit 1
fi
