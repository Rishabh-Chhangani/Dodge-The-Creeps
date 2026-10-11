# Mission: Dodge the Creeps! — Repository Audit and Engineering Plan

## Role

Act as a senior Godot game developer, software architect, QA engineer, UI/UX designer, DevOps engineer, and release engineer.

Your task is to thoroughly inspect the existing Dodge the Creeps! repository and create a comprehensive, evidence-based engineering plan to turn it into a polished, tested, maintainable, and release-ready game.

This project is based on the official Godot documentation tutorial, *Your first 2D game*. The game is already considered functionally complete by its developer, but it needs proper polishing, technical verification, mobile adaptation, testing, build automation, and release preparation.

The developer is still learning this particular codebase and wants to understand its existing architecture and implementation before making changes.

**This is a planning and documentation-only task. Do not implement any game improvements yet.**

---

# 1. Absolute restrictions

These restrictions take precedence over all other instructions.

- Do not modify existing game code.
- Do not modify existing scenes, resources, assets, project settings, or configuration files.
- Do not create or modify GitHub Actions workflows.
- Do not install software, packages, plugins, or dependencies.
- Do not upgrade, downgrade, or migrate the Godot project.
- Do not run formatters, automatic fixes, migration tools, or generators that modify existing project files.
- Do not delete, rename, move, overwrite, or reset any existing files.
- Do not discard or overwrite the developer's uncommitted changes.
- Do not commit, push, tag, or publish anything.
- Do not change Git remotes, branches, repository settings, or export settings.
- Do not start implementation merely because you discover an obvious defect.

You are authorized to create a new `docs/` directory and the Markdown planning documents specified below. If a target document already exists, preserve it and report the conflict instead of overwriting it.

All project inspection must be read-only. Prefer Git inspection commands, source-code reading, and non-mutating analysis. If a command could modify project files, imported resources, caches, or configuration, do not run it without explicit approval.

Before starting, inspect `git status --short` and record the existing working-tree changes. Preserve them exactly.

If any restriction prevents a useful inspection, document the limitation instead of bypassing it.

---

# 2. Project context

Use the following information as initial context, not as proof of implementation details.

- Project: Dodge the Creeps!
- Engine: Godot
- Project-declared feature version: Godot 4.4
- Installed development version: Godot 4.5
- Repository branch previously observed: `main`
- Development environment: Windows 10, Git Bash, and a Dell Inspiron 5520
- Hardware: Intel Core i7-3632QM, 16 GB RAM, Intel HD Graphics 4000, SSD
- Existing game: Based on the official Godot first 2D game tutorial
- Intended improvement: A polished 2D survival game suitable for Windows distribution and Android mobile play
- Mobile direction: Portrait orientation, responsive layouts, and touch controls
- Desktop direction: Preserve keyboard controls and produce a standalone Windows release
- Quality goals: Correct gameplay, clean UI, maintainable implementation, automated testing, CI/CD, reproducible builds, and proper release documentation

Do not assume that the installed Godot version is the same as the version originally used to create the project. Do not assume the current project is already compatible with Android or that all tutorial features are implemented correctly.

---

# 3. Repository inspection

Inspect the complete repository structure and relevant file contents before writing conclusions.

Examine the following where present:

## Git and repository state
- Git working-tree status
- Current branch and tracking branch
- Configured remotes
- Recent commit history
- Existing tags and release conventions
- Tracked and untracked project files
- Existing documentation and planning files
- `.gitignore` and other repository configuration

Do not expose credentials or private information found in configuration files.

## Godot project configuration
- `project.godot`
- Declared feature versions
- Main scene and project entry point
- Display/window configuration
- Viewport dimensions and stretch settings
- Rendering method and renderer compatibility
- Input actions
- Autoloads and global state
- Physics settings
- Application metadata and version information
- Export presets, if present

Distinguish between configuration values found in files and settings inferred from the installed editor.

## Scenes and resources
Inspect all relevant `.tscn`, `.tres`, `.res`, and other Godot resources.

Identify:
- Scene hierarchy
- Root node types
- Child nodes and their responsibilities
- Scene instancing and dependencies
- Signals and connections
- Resource references
- Animation players and sprite animation resources
- Collision shapes and collision layers
- Timers and spawning mechanisms
- UI controls and layout anchors
- Missing or suspicious resource references

## Scripts and implementation
Inspect all relevant GDScript files.

Identify:
- Classes and inheritance
- Script-to-scene relationships
- Responsibilities of each script
- Node references and dependency assumptions
- Signals and event flow
- Player input and movement
- Enemy spawning, movement, collision, and cleanup
- Game-state transitions
- Score calculation and presentation
- Start, pause, game-over, and restart flows
- Animation and audio logic
- Error handling
- Duplicated or tightly coupled logic
- Potential lifecycle and memory-management issues
- Untyped or unclear code where typing would provide a real benefit

## Assets and project content
Inspect the available assets and determine how they are used.

Identify:
- Player and enemy sprites
- Backgrounds
- Animation frames
- Fonts
- Audio files
- Icons and other visual resources
- Asset organization and naming
- Unused assets, where this can be established reliably
- Potential licensing or attribution information available in the repository

Do not assume an asset is unused merely because its reference is not immediately obvious.

---

# 4. Required architecture documentation

Document the architecture that actually exists today.

Do not substitute a generic Godot architecture for the repository's real structure.

Create a clear architecture inventory that includes:

1. Repository directory tree, excluding irrelevant generated caches and oversized binary listings.
2. Scene inventory.
3. Script inventory.
4. Asset and resource organization.
5. Scene hierarchy for the main gameplay scene and other important scenes.
6. Responsibilities of each important script.
7. Dependencies between scripts and scenes.
8. Signal connections and event flow.
9. Gameplay lifecycle from application startup to game over and restart.
10. Input flow from keyboard or other input sources to player movement.
11. Enemy lifecycle from spawning to removal.
12. Score calculation and UI update flow.
13. Resource-loading and asset-reference strategy.
14. Existing separation, or lack of separation, between gameplay logic, presentation, and UI.
15. Architectural strengths, weaknesses, risks, and technical debt.

Use Mermaid diagrams where helpful.

At minimum, include:

- A current scene/component relationship diagram.
- A gameplay lifecycle diagram.
- A signal or event flow diagram when supported by the source code.

Clearly label each diagram as current-state architecture, not a proposed future design.

If an important behavior cannot be established from static inspection, label it as unverified instead of inventing a runtime explanation.

---

# 5. Evidence and accuracy requirements

Every important finding must be traceable to the repository.

When practical, reference:
- File paths
- Scene names
- Script names
- Relevant function names
- Line numbers or configuration keys
- Existing tests and workflow files

For every significant issue, distinguish between:

- **Verified:** Directly supported by inspected source or configuration.
- **Likely:** A reasonable concern supported by evidence but requiring further validation.
- **Unverified:** Requires runtime testing, device testing, or an unavailable environment.

Do not claim that gameplay works merely because its scripts exist.

Do not claim that tests pass unless they have actually been executed in a safe, non-mutating manner and their results are available.

Do not claim that the game exports successfully unless this has been verified.

Do not assume unit testing, CI/CD, Windows exports, or Android exports already exist. Inspect first.

---

# 6. Create the following Markdown documents

Create a new `docs/` directory at the repository root.

Write the following six documents:

## Document 1: `docs/README.md`

Purpose: Entry point for all project planning and engineering documentation.

Include:
- Project overview
- Current known status
- Links to all five other documents
- Recommended reading order
- Planning and implementation workflow
- Explicit statement that these documents describe plans and findings, not completed implementation
- Current audit limitations and verification status

## Document 2: `docs/architecture.md`

Purpose: Record the current implementation and architecture.

Include:
- Current repository structure
- Main scenes and scene hierarchy
- Script and resource inventory
- Responsibilities of each major component
- Script and scene dependencies
- Signal connections and data flow
- Startup, gameplay, game-over, and restart lifecycle
- Player movement and input flow
- Enemy spawning and lifecycle
- Scoring and UI flow
- Current configuration and rendering setup
- Existing architectural strengths
- Technical debt and architectural risks
- Areas requiring runtime verification
- Mermaid diagrams grounded in the actual source

Separate the current architecture from any future architectural recommendations.

## Document 3: `docs/audit-report.md`

Purpose: Record the current state of the game and repository.

Include:
- Repository and Git status
- Existing uncommitted changes observed before inspection
- Project configuration findings
- Installed and declared Godot version distinctions
- Verified existing features
- Incomplete features, if established
- Potential bugs and technical risks
- UI/UX and visual polish assessment
- Gameplay and balance assessment
- Performance and hardware compatibility assessment
- Desktop readiness
- Mobile readiness
- Existing test coverage and validation tooling
- Existing CI/CD and build automation
- Existing documentation and release readiness
- Missing information and unverified behavior

Do not label a feature incomplete simply because its implementation is unfamiliar or unconventional.

## Document 4: `docs/improvement-roadmap.md`

Purpose: Define the prioritized engineering work required to improve the game.

Cover all the following areas.

### Gameplay and logic
- Player movement and input responsiveness
- Enemy spawning and spawn positions
- Collision handling
- Scoring and score persistence where appropriate
- Difficulty and pacing
- Game states
- Start, pause, resume, game over, and restart behavior
- Edge cases and regression prevention

### UI/UX and visual polish
- Title screen
- Instructions and controls
- HUD and score display
- Game-over presentation
- Restart and navigation flow
- Typography, spacing, alignment, contrast, and readability
- Animation and visual feedback
- Audio balancing and feedback
- Appropriate visual polish without unnecessary effects

### Mobile adaptation
- Portrait orientation
- Logical viewport and scaling
- Responsive screen handling
- Safe areas and display cutouts
- Touch controls
- Touch responsiveness and accidental input prevention
- Enemy spawning across supported aspect ratios
- UI anchors and layout adaptation
- Android lifecycle, pause/resume, and back-button behavior where applicable
- Performance and usability on actual devices

### Code quality and architecture
- GDScript style and typing
- Responsibilities and coupling
- Signal usage
- Scene dependencies
- Reusable components where justified
- Error handling and lifecycle management
- Maintainability and debugging
- Learning-oriented explanations for significant changes

### Performance and compatibility
- Modest hardware compatibility
- Rendering compatibility
- CPU and memory considerations
- Avoidable per-frame work
- Resource lifecycle
- Frame pacing
- Performance measurements rather than unsupported assumptions

### Testing and QA
- Unit tests for suitable isolated logic
- Integration tests
- Gameplay state-transition tests
- Player movement and boundary tests
- Enemy spawn and cleanup tests
- Scoring and restart tests
- Resource validation
- Regression tests
- Exported-build smoke tests
- Manual playtesting and visual checks

### CI/CD
- Headless project validation
- Resource import and scene validation
- Automated tests
- Static checks
- Test reporting
- Windows export
- Android export
- Artifact retention
- Release creation
- Version tagging
- Failure handling and release gates

### Build and distribution
- Windows executable and associated data files
- Windows ZIP package
- Clean distribution directory
- Standalone launch verification
- Android debug APK
- Signed Android release APK and/or AAB
- Export templates and SDK dependencies
- Secure signing configuration
- Versioning and changelog
- Release notes and screenshots

### Portfolio and documentation
- Professional README
- Controls and gameplay instructions
- Development and build setup
- Testing instructions
- Known issues
- Screenshots
- Versioned releases
- Itch.io or other appropriate distribution options

Organize the roadmap into phases and priorities.

For each implementation task, provide:
- Task ID
- Title
- Priority: P0, P1, P2, or P3
- Evidence-based problem statement
- Proposed solution
- Files or components likely to be affected
- Dependencies
- Acceptance criteria
- Automated tests required
- Manual verification required
- Risks and rollback considerations

Priority definitions:

- P0: Critical launch failures, severe defects, or risks to project integrity.
- P1: Essential gameplay, mobile usability, automated validation, or release blockers.
- P2: Important polish, maintainability, and workflow improvements.
- P3: Optional enhancements that can be deferred.

Clearly distinguish release requirements from optional enhancements. Avoid feature creep.

## Document 5: `docs/testing-strategy.md`

Purpose: Define a realistic quality assurance strategy.

Include:
- Testing objectives and quality gates
- Existing tests and tools discovered during inspection
- Proposed test framework and compatibility considerations
- Unit-testing scope
- Integration-testing scope
- Regression-testing scope
- Scene and resource validation
- Static analysis and linting
- Headless validation
- Windows executable smoke testing
- Android build and device testing
- Manual gameplay checklist
- Test result reporting
- Failure diagnosis and remediation
- Criteria for accepting a test run
- Definition of done for automated and manual testing

Evaluate a suitable framework such as GUT if appropriate for the project's Godot version and GDScript structure.

Do not force every gameplay behavior into a unit test. Use integration and manual tests where they are more appropriate.

Identify which tests can run safely in CI and which require a real device, graphics environment, or manual review.

## Document 6: `docs/release-plan.md`

Purpose: Define the path from the existing repository to reproducible, shippable builds.

Include:
- Release objectives
- Supported platforms
- Recommended engine and renderer, supported by compatibility findings
- Versioning strategy
- Development, testing, and release stages
- Windows export requirements
- Required executable companion files and resource packaging
- Distribution ZIP layout
- Windows standalone smoke testing
- Android export requirements
- APK versus AAB considerations
- Android SDK, JDK, export template, and signing requirements
- Secure credential handling
- GitHub Actions architecture
- Build artifact naming
- Artifact retention
- Version-tagged release creation
- Changelog and release notes
- Rollback and recovery
- Release acceptance checklist
- Definition of done for each target

Propose workflows and their responsibilities, but do not create workflow files yet.

The Windows build must be treated as a first-class deliverable, comparable to a standalone executable distribution workflow for a Pygame project.

Android is an additional target. Do not consider a Windows release successful merely because an Android build exists, or vice versa.

---

# 7. Recommended implementation planning structure

The roadmap should consider this general sequence, adjusting it to actual audit findings:

1. Baseline and critical defect resolution
2. Gameplay correctness and regression coverage
3. UI/UX and visual polish
4. Responsive portrait layout and mobile controls
5. Code quality and architecture improvements
6. Automated tests and quality gates
7. Windows export and standalone verification
8. Android export and device testing
9. GitHub Actions automation
10. Documentation, versioning, and release preparation

Do not automatically follow this order if repository evidence demonstrates a better dependency sequence. Explain significant deviations.

Before an implementation task is approved, its acceptance criteria must be clear enough to verify.

---

# 8. Godot version and renderer assessment

Compare the declared Godot feature version with the installed editor version.

Recommend whether to:
- Keep Godot 4.5
- Use a compatible 4.4 installation
- Consider another version only if supported by concrete compatibility evidence

Consider:
- Existing project compatibility
- GDScript and resource migration risks
- Testing framework compatibility
- Export template availability
- Windows and Android export support
- Intel HD Graphics 4000 compatibility
- Performance requirements of the actual game

Do not downgrade or upgrade the project. This section is analysis and recommendation only.

Explain that the declared feature version does not necessarily identify the exact editor patch version originally used.

---

# 9. GitHub Actions design

Describe the proposed CI/CD workflow architecture in `docs/release-plan.md` and the associated validation strategy in `docs/testing-strategy.md`.

Consider separate responsibilities for:

- Pull request validation
- Push validation
- Headless import and project checks
- Automated tests
- Windows build and packaging
- Android build
- Tagged release creation

Specify:
- Trigger conditions
- Runner requirements
- Tool and dependency versioning
- Export-template requirements
- Required environment variables
- Secrets, if needed
- Artifacts produced
- Test reports
- Failure behavior
- Release gates

Do not create `.github/workflows/` files during this task.

Do not claim that Godot editor validation, automated tests, or exported builds are equivalent. They verify different things and should have separate, explicit responsibilities.

---

# 10. Quality standards for the documents

The documentation must be useful to a developer who has not independently studied the existing codebase.

Use clear technical English, meaningful headings, concise explanations, tables where useful, and Mermaid diagrams where they clarify architecture.

Avoid generic advice that could apply to any game without reference to this repository.

Do not fill the documents with invented features, hypothetical file paths presented as existing files, unsupported performance claims, or empty checklists.

Use repository paths and names exactly as they exist.

Clearly label future proposals as proposed work.

If a planned document cannot be completed because required information is unavailable, document the limitation instead of inventing the missing information.

Cross-link related documents using relative Markdown links.

Keep the documentation consistent across all six files.

---

# 11. Execution procedure

Follow this sequence exactly:

### Step A: Read-only inspection
Inspect the Git state and project structure. Read the relevant source, scenes, assets, configuration, and existing documentation.

### Step B: Build the evidence inventory
Identify the actual architecture, current functionality, risks, missing information, and existing automation.

### Step C: Develop the plan
Prioritize improvements, define acceptance criteria, design the testing strategy, and outline the release pipeline.

### Step D: Create documentation
Create `docs/` and write the six Markdown documents.

If any file already exists, do not overwrite it. Report the conflict and leave it untouched.

### Step E: Validate the documentation
Verify that:
- All six required documents exist.
- Relative links point to the correct documents.
- Referenced project files actually exist.
- Architecture diagrams match inspected code.
- Existing uncommitted changes have been preserved.
- No game source, scene, asset, project configuration, dependency, or workflow was modified.
- No implementation task was performed.

Only perform read-only validation of the new documentation. Do not run automatic formatters or tools that rewrite files.

### Step F: Report the outcome
Provide a concise summary containing:
- Documents created
- Current architecture findings
- Most important verified issues
- Unverified assumptions and environmental limitations
- Recommended implementation order
- Recommended Godot version and renderer
- Proposed Windows and Android release outputs
- Proposed testing and CI/CD design
- The first five prioritized implementation tasks
- Confirmation of whether any existing files were changed

Do not begin implementation after generating the documents.

---

# Final instruction

**Create the six planning documents in `docs/` and stop.**

Do not fix bugs, polish the UI, change scripts, edit scenes, configure Android, create CI workflows, or build the game.

The only permitted repository modifications are the creation of the new `docs/` directory and its six requested Markdown files, provided those paths do not already contain files that would be overwritten.

Wait for my explicit approval before proceeding to any implementation phase.