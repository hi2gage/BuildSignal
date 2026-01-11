#!/bin/bash
set -e

# This script runs after Xcode Cloud builds the app
# It creates a GitHub release and updates the Homebrew tap

# Only run for archive actions on tags
if [[ "$CI_XCODEBUILD_ACTION" != "archive" ]]; then
    echo "Not an archive action, skipping release"
    exit 0
fi

# Check if this is a tag build
if [[ -z "$CI_TAG" ]]; then
    echo "Not a tag build, skipping release"
    exit 0
fi

VERSION="${CI_TAG#v}"
echo "Creating release for version: $VERSION"

# Find the exported app
APP_PATH=$(find "$CI_ARCHIVE_PATH/Products/Applications" -name "*.app" -type d | head -1)
if [[ -z "$APP_PATH" ]]; then
    echo "Error: Could not find app in archive"
    exit 1
fi

APP_NAME=$(basename "$APP_PATH" .app)
echo "Found app: $APP_NAME at $APP_PATH"

# Create release directory
RELEASE_DIR="$CI_PRIMARY_REPOSITORY_PATH/release"
mkdir -p "$RELEASE_DIR"

# Copy and zip the app
cp -R "$APP_PATH" "$RELEASE_DIR/"
cd "$RELEASE_DIR"
zip -r "${APP_NAME}-${VERSION}.zip" "${APP_NAME}.app"

# Calculate SHA256
SHA256=$(shasum -a 256 "${APP_NAME}-${VERSION}.zip" | awk '{print $1}')
echo "SHA256: $SHA256"

# Create GitHub release using gh CLI (pre-installed on Xcode Cloud)
# Note: You need to add GITHUB_TOKEN as an environment variable in Xcode Cloud
if [[ -n "$GITHUB_TOKEN" ]]; then
    echo "Creating GitHub release..."

    gh release create "$CI_TAG" \
        "${APP_NAME}-${VERSION}.zip" \
        --repo "hi2gage/${APP_NAME}" \
        --title "${APP_NAME} ${CI_TAG}" \
        --generate-notes

    echo "Release created successfully"

    # Update Homebrew tap
    if [[ -n "$HOMEBREW_TAP_TOKEN" ]]; then
        echo "Triggering Homebrew tap update..."

        curl -X POST \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer $HOMEBREW_TAP_TOKEN" \
            "https://api.github.com/repos/hi2gage/homebrew-hi2gage/dispatches" \
            -d "{\"event_type\":\"update-cask\",\"client_payload\":{\"cask\":\"buildsignal\",\"version\":\"$VERSION\",\"sha256\":\"$SHA256\"}}"

        echo "Homebrew tap update triggered"
    fi
else
    echo "GITHUB_TOKEN not set, skipping GitHub release"
    echo "Add GITHUB_TOKEN as a secret environment variable in Xcode Cloud"
fi
