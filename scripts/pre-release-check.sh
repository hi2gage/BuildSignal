#!/bin/bash

# BuildSignal Pre-Release Checklist
# Run this before releasing to make sure everything is ready

echo "🔍 BuildSignal Pre-Release Checklist"
echo ""

ERRORS=0
WARNINGS=0

# Check if README exists
if [ -f "README.md" ]; then
    echo "✅ README.md exists"
else
    echo "❌ README.md missing"
    ((ERRORS++))
fi

# Check if LICENSE exists
if [ -f "LICENSE" ]; then
    echo "✅ LICENSE exists"
else
    echo "⚠️  LICENSE missing (recommended for open source)"
    ((WARNINGS++))
fi

# Check if app icon is set
if [ -f "BuildSignal/Assets.xcassets/AppIcon.appiconset/Contents.json" ]; then
    ICON_COUNT=$(grep -c "filename" BuildSignal/Assets.xcassets/AppIcon.appiconset/Contents.json || echo "0")
    if [ "$ICON_COUNT" -gt 0 ]; then
        echo "✅ App icon configured"
    else
        echo "❌ App icon not set"
        ((ERRORS++))
    fi
else
    echo "❌ App icon asset missing"
    ((ERRORS++))
fi

# Check if Secrets.xcconfig exists
if [ -f "Config/Secrets.xcconfig" ]; then
    echo "✅ Config/Secrets.xcconfig exists"
else
    echo "❌ Config/Secrets.xcconfig missing"
    ((ERRORS++))
fi

# Check if all commits are pushed
if git diff origin/main..HEAD --quiet 2>/dev/null; then
    echo "✅ All commits pushed to origin"
else
    echo "⚠️  Unpushed commits exist"
    ((WARNINGS++))
fi

# Check GitHub secrets (can't verify remotely, just remind)
echo "⚠️  Reminder: Verify GitHub secrets are configured:"
echo "   - APPLE_CERTIFICATE_BASE64"
echo "   - APPLE_CERTIFICATE_PASSWORD"
echo "   - APPLE_ID"
echo "   - APPLE_ID_PASSWORD"
echo "   - APPLE_TEAM_ID"
echo "   - HOMEBREW_TAP_TOKEN"

echo ""
echo "📊 Summary:"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ All checks passed! Ready to release."
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  $WARNINGS warning(s) - you can proceed but consider fixing"
    exit 0
else
    echo "❌ $ERRORS error(s) found - fix these before releasing"
    exit 1
fi
