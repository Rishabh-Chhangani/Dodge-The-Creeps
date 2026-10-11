# Dodge the Creeps! - Engineering Plan

This repository contains an audit and engineering plan for the "Dodge the Creeps!" Godot game. The game is based on the official Godot "Your first 2D game" tutorial and requires architectural refinement, testing, mobile optimization, and build automation before it can be considered a release-ready title for Desktop and Android.

> **Note:** The documents in this folder represent plans, findings, and analysis. They do not represent completed implementation. No game source code, configuration, or assets were modified during this inspection.

## Current Known Status

The game is functionally complete as a baseline tutorial project, supporting basic gameplay, scoring, enemy spawning, and keyboard input. It uses Godot 4.5. However, it lacks test coverage, automated CI/CD pipelines, proper portrait mobile touch adaptations, and finalized export templates.

## Documentation Index

Please read the following documents in order to understand the current state and the planned engineering work:

1. [Architecture (`architecture.md`)](./architecture.md) - Analysis of the existing scene structures, scripts, signals, and game lifecycle.
2. [Audit Report (`audit-report.md`)](./audit-report.md) - Findings on bugs, technical risks, readiness, and limitations of the current codebase.
3. [Improvement Roadmap (`improvement-roadmap.md`)](./improvement-roadmap.md) - Prioritized engineering tasks for gameplay, UI/UX, mobile adaptation, and automation.
4. [Testing Strategy (`testing-strategy.md`)](./testing-strategy.md) - Quality assurance gates, including unit/integration testing and manual playtesting.
5. [Release Plan (`release-plan.md`)](./release-plan.md) - CI/CD pipeline design, GitHub Actions architecture, and release criteria for Windows and Android.
6. [Architectural Solutions (`architectural-solutions.md`)](./architectural-solutions.md) - Comprehensive solutions, Mermaid architecture blueprint, code patterns, and refactoring roadmap for 10 identified architectural flaws.

## Audit Limitations
- **Unverified Export Success:** Godot export to Windows and Android has not been verified manually during this read-only inspection.
- **Hardware/Device Testing:** Performance on Intel HD 4000 and actual Android touch devices remains unverified.
- **Test Execution:** No existing unit or integration tests were found; therefore, no test execution could be performed.
