# Version Management Guide

## Current Version: 1.0.0+1

## Version Format

The version in `pubspec.yaml` follows this format:
```yaml
version: X.Y.Z+BUILD_NUMBER
```

- **X.Y.Z** = Version Name (shown to users in Play Store)
  - X = Major version (breaking changes)
  - Y = Minor version (new features)
  - Z = Patch version (bug fixes)
- **BUILD_NUMBER** = Version Code (must always increase for Play Store)

## Version Update Examples

### Bug Fix Release
```yaml
# Before: 1.0.0+1
# After:  1.0.1+2
version: 1.0.1+2
```

### Feature Release
```yaml
# Before: 1.0.1+2
# After:  1.1.0+3
version: 1.1.0+3
```

### Major Release
```yaml
# Before: 1.1.0+3
# After:  2.0.0+4
version: 2.0.0+4
```

## Quick Update Checklist

Before each Play Store release:

1. ✅ Update version in `pubspec.yaml`
2. ✅ Test the app thoroughly
3. ✅ Update CHANGELOG.md (if you have one)
4. ✅ Build release bundle: `flutter build appbundle --release`
5. ✅ Test the release build
6. ✅ Upload to Play Store Console
7. ✅ Add release notes

## Version History

| Version | Build | Date | Changes |
|---------|-------|------|---------|
| 1.0.0 | 1 | 2024 | Initial Play Store release |

---

**Remember:** The build number (version code) must ALWAYS increase for each Play Store upload!

