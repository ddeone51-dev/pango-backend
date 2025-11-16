@echo off
REM Build Release Script for Homia (Windows)
REM This script helps build release versions for Play Store

echo 🏗️  Building Homia Release...

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter is not installed or not in PATH
    exit /b 1
)

REM Get current version
for /f "tokens=2" %%a in ('findstr /C:"version:" pubspec.yaml') do set VERSION=%%a
echo 📱 Current version: %VERSION%

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Build app bundle for Play Store
echo 📦 Building Android App Bundle (AAB)...
flutter build appbundle --release

if %ERRORLEVEL% EQU 0 (
    echo ✅ Build successful!
    echo 📁 AAB location: build\app\outputs\bundle\release\app-release.aab
    echo.
    echo 🚀 Next steps:
    echo 1. Upload app-release.aab to Google Play Console
    echo 2. Add release notes
    echo 3. Review and publish
) else (
    echo ❌ Build failed!
    exit /b 1
)

pause

