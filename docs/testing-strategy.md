# Testing Strategy

This document outlines the Quality Assurance approach for Dodge the Creeps.

## Testing Objectives
- Ensure regressions are caught early through automated tests.
- Verify scene instancing and references automatically.
- Validate desktop and mobile builds reliably before release.

## Proposed Test Framework
- **GUT (Godot Unit Test)**: Recommended for unit and integration testing. It integrates well with Godot 4.5 and can be executed via the command line in CI/CD pipelines.

## Scope of Testing

### 1. Static Analysis and Headless Validation
- Run Godot in headless mode (`--headless --check-only`) to verify that all scenes and resources can be imported without errors.

### 2. Unit Testing Scope
- **Score Calculation**: Verify that the score increments correctly when the `ScoreTimer` times out.
- **Velocity Normalization**: Verify that diagonal inputs do not result in faster speed vectors in `player.gd`.

### 3. Integration Testing Scope
- **Player Death**: Simulate a mob colliding with the player area and verify that the `hit` signal is emitted and the player is hidden.
- **Game State Transitions**: Ensure the `new_game` function correctly resets the score and player position.

### 4. Manual Gameplay Checklist
Since not all features can be cleanly unit-tested, releases must pass a manual smoke test:
- Application launches without crashing on Windows.
- Application installs and launches on an Android test device.
- Audio (BGM and SFX) plays correctly.
- Player movement is responsive.
- "Start" button responds to clicks/touches.

## Failure Diagnosis and Remediation
Any failure in automated tests during CI will block the release pipeline. Developers must replicate the failure locally using GUT before attempting a fix.
