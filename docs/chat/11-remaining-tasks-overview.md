# Session 11: Overview of Remaining Work (Excluding Testing)

**Date:** 2026-10-11  

---

### User

Except test ing what all is remaining

### Assistant

I audited the repository, release plans, and architectural status to outline all remaining engineering, packaging, and gameplay tasks outside of testing:

1. **Platform Export & Presets**:
   - Complete missing Windows Desktop preset in `export_presets.cfg`.
   - Finalize Android preset: real package ID (`com.forge.dodgethecreeps`), versioning (`1.0.0`), and adaptive app icons.
   - Configure screen orientation lock (`portrait`) in `project.godot`.
2. **CI/CD Automation (GitHub Actions)**:
   - Create `.github/workflows/build-and-release.yml` for automated multi-platform headless exporting (Windows ZIP and Android APK).
   - Setup GitHub release publishing on semver git tags.
3. **Audio & UI Settings**:
   - Add Audio volume sliders (Master, Music, SFX) in Pause / Title menu connected to `AudioServer` and our new `default_bus_layout.tres`.
4. **Gameplay & Juice Enhancements (Beyond Tutorial)**:
   - Differentiated mob behaviors (variable speed/steering per type rather than purely cosmetic animations).
   - Power-ups/pickups (speed boost, shield, score multiplier).
   - Squash & stretch animations and movement particle trails.
5. **Git & Repository Hygiene**:
   - Review and commit worktree changes.
   - Add open-source `LICENSE` and player-facing installation notes.
