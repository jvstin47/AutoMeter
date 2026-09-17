#!/usr/bin/env bash
set -e

# ==============================================================================
# AutoMeter — Automated Release APK Builder
# Builds the Flutter release APK and names it AutoMeter-v<version>.apk
# ==============================================================================

# Determine project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Extract version from pubspec.yaml (e.g., version: 1.0.0+1 -> 1.0.0)
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f1 | tr -d ' ')
BUILD_NUMBER=$(grep '^version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f2 | tr -d ' ')

if [ -z "$BUILD_NUMBER" ]; then
    BUILD_NUMBER="1"
fi

# Check if user specified a version bump argument: patch | minor | major | explicit version
if [ "$1" == "patch" ]; then
    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
    PATCH=$((PATCH + 1))
    BUILD_NUMBER=$((BUILD_NUMBER + 1))
    NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
elif [ "$1" == "minor" ]; then
    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
    MINOR=$((MINOR + 1))
    PATCH=0
    BUILD_NUMBER=$((BUILD_NUMBER + 1))
    NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
elif [ "$1" == "major" ]; then
    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    BUILD_NUMBER=$((BUILD_NUMBER + 1))
    NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
elif [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    NEW_VERSION="$1"
    BUILD_NUMBER=$((BUILD_NUMBER + 1))
elif [ -n "$1" ]; then
    echo "❌ Unknown version argument: $1"
    echo "Usage: ./scripts/build_release_apk.sh [patch | minor | major | X.Y.Z]"
    exit 1
else
    NEW_VERSION="$CURRENT_VERSION"
fi

if [ "$NEW_VERSION" != "$CURRENT_VERSION" ]; then
    echo "📌 Bumping version: v${CURRENT_VERSION} -> v${NEW_VERSION}+${BUILD_NUMBER} in pubspec.yaml..."
    # macOS-compatible sed
    sed -i '' "s/^version: .*/version: ${NEW_VERSION}+${BUILD_NUMBER}/" pubspec.yaml
fi

APK_VERSION_NAME="AutoMeter-v${NEW_VERSION}.apk"
echo "🚀 Building Release APK for AutoMeter (v${NEW_VERSION}, build ${BUILD_NUMBER})..."

flutter clean
flutter pub get
flutter build apk --release --build-name="$NEW_VERSION" --build-number="$BUILD_NUMBER"

RELEASE_DIR="$PROJECT_ROOT/build/app/outputs/flutter-apk"
ORIGINAL_APK="$RELEASE_DIR/app-release.apk"
TARGET_APK="$RELEASE_DIR/$APK_VERSION_NAME"

if [ -f "$ORIGINAL_APK" ]; then
    cp "$ORIGINAL_APK" "$TARGET_APK"
    mkdir -p "$PROJECT_ROOT/dist"
    cp "$ORIGINAL_APK" "$PROJECT_ROOT/dist/$APK_VERSION_NAME"
    echo "✅ Success! Release APK created at:"
    echo "   📍 $PROJECT_ROOT/dist/$APK_VERSION_NAME"
    echo "   📍 $TARGET_APK"
    echo ""
    echo "📦 File Size: $(du -h "$PROJECT_ROOT/dist/$APK_VERSION_NAME" | cut -f1)"
else
    echo "❌ Error: Could not find generated release APK at $ORIGINAL_APK"
    exit 1
fi

echo "🎉 Build finished for v${NEW_VERSION}!"
