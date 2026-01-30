# Xcode Configuration Files

This directory contains `.xcconfig` template files for managing build settings in plain text.

## ⚠️ First-Time Setup

**Before using this project, you must create your local config files:**

```bash
cd Config
cp Shared.xcconfig.template Shared.xcconfig
cp Debug.xcconfig.template Debug.xcconfig
cp Release.xcconfig.template Release.xcconfig
```

Then edit `Shared.xcconfig` and replace:
- `YOUR_TEAM_ID` with your Apple Developer Team ID
- `com.yourcompany.BuildSignal` with your bundle identifier

## Files

- **\*.xcconfig.template** - Template files (committed to git)
- **\*.xcconfig** - Your personal config files (gitignored, NOT committed)

The actual `.xcconfig` files are gitignored to keep personal Team IDs and bundle identifiers private.

## Setup in Xcode

### 1. Add Config Files to Xcode Project

1. Open `BuildSignal.xcodeproj` in Xcode
2. Right-click on the project root in the navigator
3. Select "Add Files to BuildSignal..."
4. Navigate to the `Config` folder
5. Select `Debug.xcconfig`, `Release.xcconfig`, and `Shared.xcconfig` (NOT the templates)
6. **IMPORTANT**: Uncheck "Copy items if needed" and "Add to targets"
7. Click "Add"

### 2. Apply Configurations to Project

1. Select the **BuildSignal project** in the navigator (blue icon)
2. Select the **BuildSignal project** under PROJECT (not the target)
3. Go to the **Info** tab
4. Under "Configurations", expand Debug and Release
5. For **Debug** configuration:
   - Set project configuration to `Debug`
   - Set target configuration to `Debug`
6. For **Release** configuration:
   - Set project configuration to `Release`
   - Set target configuration to `Release`

### 3. Using Variables

Once configured, you can reference variables in your project:

```swift
// In Info.plist or build settings, reference like:
$(PRODUCT_BUNDLE_IDENTIFIER)
$(MARKETING_VERSION)
$(CURRENT_PROJECT_VERSION)
$(DEVELOPMENT_TEAM)
```

### 4. Local Overrides (Optional)

For machine-specific settings:

1. Copy `Local.xcconfig.template` to `Local.xcconfig`
2. Edit with your custom settings
3. Update Debug.xcconfig and Release.xcconfig to include:
   ```
   #include? "Local.xcconfig"
   ```

## Common Variables

```
// Product Info
PRODUCT_NAME
PRODUCT_BUNDLE_IDENTIFIER
MARKETING_VERSION
CURRENT_PROJECT_VERSION

// Team & Signing
DEVELOPMENT_TEAM
CODE_SIGN_IDENTITY
CODE_SIGN_STYLE

// Deployment
MACOSX_DEPLOYMENT_TARGET

// Swift
SWIFT_VERSION
SWIFT_OPTIMIZATION_LEVEL
```

## For Contributors

If you're contributing to this project:

1. Never commit your personal `.xcconfig` files (they're gitignored)
2. Only commit changes to `.xcconfig.template` files if updating shared settings
3. Keep your Team ID and personal bundle identifiers private

## Benefits

✅ Version control friendly (plain text)
✅ Easy to see what changed in diffs
✅ Share settings across team members
✅ Keep personal Team IDs private
✅ Override settings per-machine without conflicts
