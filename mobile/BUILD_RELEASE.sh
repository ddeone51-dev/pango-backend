#!/bin/bash

# Build Release Script for Homia
# This script helps build release versions for Play Store

echo "🏗️  Building Homia Release..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

# Get current version
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
echo "📱 Current version: $VERSION"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run tests (optional, uncomment if you have tests)
# echo "🧪 Running tests..."
# flutter test

# Build app bundle for Play Store
echo "📦 Building Android App Bundle (AAB)..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📁 AAB location: build/app/outputs/bundle/release/app-release.aab"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Upload app-release.aab to Google Play Console"
    echo "2. Add release notes"
    echo "3. Review and publish"
else
    echo "❌ Build failed!"
    exit 1
fi

