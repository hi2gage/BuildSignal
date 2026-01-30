# Xcode Configuration Files

This directory contains `.xcconfig` files for managing build settings in plain text.

## ⚠️ First-Time Setup

**Before building this project, you must create your secrets file:**

```bash
cd Config
cp Secrets.xcconfig.template Secrets.xcconfig
```

Then edit `Secrets.xcconfig` and replace:
- `YOUR_TEAM_ID` with your Apple Developer Team ID
- `com.yourcompany.BuildSignal` with your bundle identifier

## File Structure

```
Config/
├── Debug.xcconfig              # Debug configuration (committed)
├── Release.xcconfig            # Release configuration (committed)
├── Shared.xcconfig             # Shared settings (committed)
├── Secrets.xcconfig            # YOUR secrets (gitignored, NOT committed)
├── Secrets.xcconfig.template   # Template for creating Secrets.xcconfig
└── Local.xcconfig.template     # Optional local overrides template
```

### Include Chain

```
Debug.xcconfig
    └─> Shared.xcconfig
            └─> Secrets.xcconfig (your personal Team ID & Bundle ID)

Release.xcconfig
    └─> Shared.xcconfig
            └─> Secrets.xcconfig (your personal Team ID & Bundle ID)
```

## What's Safe to Commit?

✅ **Commit these:**
- `Debug.xcconfig` - Debug configuration
- `Release.xcconfig` - Release configuration
- `Shared.xcconfig` - Shared settings
- `Secrets.xcconfig.template` - Template for secrets
- `Local.xcconfig.template` - Template for local overrides

🔒 **Never commit:**
- `Secrets.xcconfig` - Contains your personal Team ID and Bundle ID

## Setup in Xcode

### 1. Create Secrets File

Follow the "First-Time Setup" instructions above first.

### 2. Add Config Files to Xcode Project

1. Open `BuildSignal.xcodeproj` in Xcode
2. Right-click on the project root in the navigator
3. Select "Add Files to BuildSignal..."
4. Navigate to the `Config` folder
5. Select `Debug.xcconfig`, `Release.xcconfig`, `Shared.xcconfig`, and `Secrets.xcconfig`
6. **IMPORTANT**: Uncheck "Copy items if needed" and "Add to targets"
7. Click "Add"

### 3. Apply Configurations to Project

1. Select the **BuildSignal project** in the navigator (blue icon)
2. Select the **BuildSignal project** under PROJECT (not the target)
3. Go to the **Info** tab
4. Under "Configurations", set:
   - **Debug** → `Debug.xcconfig`
   - **Release** → `Release.xcconfig`

### 4. Using Variables

Reference variables anywhere in your project:

```
$(PRODUCT_BUNDLE_IDENTIFIER)
$(MARKETING_VERSION)
$(DEVELOPMENT_TEAM)
$(PRODUCT_NAME)
```

## Local Overrides (Optional)

For machine-specific settings that override even secrets:

1. Copy `Local.xcconfig.template` to `Local.xcconfig`
2. Edit with your custom settings
3. Add to the top of `Shared.xcconfig`:
   ```
   #include? "Local.xcconfig"
   ```
   (The `?` makes it optional)

## Common Variables

```
// From Secrets.xcconfig
DEVELOPMENT_TEAM
PRODUCT_BUNDLE_IDENTIFIER

// From Shared.xcconfig
PRODUCT_NAME
MARKETING_VERSION
CURRENT_PROJECT_VERSION
MACOSX_DEPLOYMENT_TARGET
SWIFT_VERSION

// From Debug.xcconfig / Release.xcconfig
CODE_SIGN_IDENTITY
CODE_SIGN_STYLE
SWIFT_OPTIMIZATION_LEVEL
```

## For Contributors

If you're contributing to this open source project:

1. **Never commit** your `Secrets.xcconfig` file
2. Only commit changes to the main config files (Debug, Release, Shared) if they affect everyone
3. Keep your Team ID and bundle identifier private

## Benefits

✅ Version control friendly - all configs except secrets are committed
✅ Easy to see what changed in diffs
✅ Share team settings in git
✅ Keep personal credentials private
✅ Simple include hierarchy
✅ No merge conflicts on personal settings
