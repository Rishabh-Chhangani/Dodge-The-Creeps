# Release Plan

This document defines the path from the source repository to reproducible, shippable builds for Windows and Android.

## Release Objectives
Produce a standalone Windows executable (ZIP) and a signed Android release (APK/AAB) via an automated GitHub Actions pipeline.

## Godot Version Recommendation
- **Current Version**: Godot 4.5 with `gl_compatibility` renderer.
- **Recommendation**: Maintain Godot 4.5 and the GL Compatibility renderer. This ensures the best fallback support for older hardware (like Intel HD Graphics 4000) and smooth Android compatibility.

## CI/CD Workflow Architecture (GitHub Actions)

We propose a three-stage GitHub Actions pipeline:

### 1. Pull Request Validation (CI)
- **Triggers**: On pull requests to `main`.
- **Actions**:
  - Headless Godot project import check.
  - Execute GUT tests.
- **Failure Behavior**: Blocks merging if import or tests fail.

### 2. Build and Export (CD - Push)
- **Triggers**: On push to `main`.
- **Actions**:
  - Setup Godot 4.5 environment and export templates.
  - Export Windows Desktop (`.exe` and `.pck`).
  - Export Android Debug (`.apk`).
- **Artifacts**: Upload builds as workflow artifacts for immediate manual QA.

### 3. Tagged Release Creation
- **Triggers**: On pushing a semver tag (e.g., `v1.0.0`).
- **Actions**:
  - Perform the Build and Export step.
  - For Android, use securely stored keystore secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`) to sign the APK/AAB.
  - Package Windows files into a ZIP archive (`DodgeTheCreeps-v1.0.0-Windows.zip`).
  - Publish a GitHub Release attaching the ZIP and APK/AAB along with an automated changelog.

## Distribution Layout (Windows)
The Windows release ZIP must contain:
- `DodgeTheCreeps.exe` (The executable)
- `DodgeTheCreeps.pck` (If not embedded)
- `README.md` (Player instructions)
- `LICENSE` (If applicable)

## Acceptance Criteria for Release
- Automated tests pass 100%.
- Windows executable runs natively on an Intel HD 4000 machine without crashing.
- Android APK installs and runs on a standard Android 10+ device with functional touch controls.
