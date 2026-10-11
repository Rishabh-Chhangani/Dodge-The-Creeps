# Chat Archive

This folder stores individual records of developer conversations and assistant sessions for the **Dodge the Creeps!** Godot project.

## Sessions Index

1. [Session 1: Godot Language Server Troubleshooting](./01-lsp-troubleshooting.md)  
   Resolution of GDScript LSP connection errors (`127.0.0.1:6005`), VS Code Godot Tools extension configuration, and initial project setup.
2. [Session 2: Repository Audit & Engineering Plan](./02-audit-and-planning.md)  
   Read-only repository inspection, generation of 6 engineering planning documents in `docs/` (`README.md`, `architecture.md`, `audit-report.md`, `improvement-roadmap.md`, `testing-strategy.md`, `release-plan.md`), and game design critique.
3. [Session 3: Game Dev Skills Added](./03-skills-added.md)  
   Detection and indexing of 28 game dev & Godot skills configured in `.agents/skills/` and `skills-lock.json`.
4. [Session 4: Implementation of Task T-02 (GDScript Static Typing)](./04-task-t02-gdscript-static-typing.md)  
   Application of explicit type annotations across player, mob, hud, and main scripts, followed by headless functional verification.
5. [Session 5: Implementation of Phase 2 (T-03) & Phase 3 (T-04)](./05-phase2-and-phase3-implementation.md)  
   Implementation of mobile touch/drag controls, death particles, camera trauma shake, instruction labels, and game over score display.
6. [Session 6: Architectural Inspection & Flaws Analysis](./06-architectural-inspection-and-flaws.md)  
   Deep structural audit identifying 10 critical flaws across coupling, scene hierarchy, audio routing, spawn math, and state persistence.
7. [Session 7: Architectural Solutions & Refactoring Blueprint](./07-architectural-solutions.md)  
   Creation of `docs/architectural-solutions.md` detailing architecture diagrams, concrete GDScript patterns, and a 5-phase refactoring roadmap.
8. [Session 8: Architectural Solutions Implementation](./08-architectural-implementation.md)  
   Application and headless verification of all 10 architectural solutions: audio bus layout, collision layers, SaveManager, MobContainer, unified GameOver, difficulty scaling, spawn angle fix, @onready caching, and mobile pause menu.
9. [Session 9: Test Location & Execution Clarification](./09-test-location-clarification.md)  
   Clarification that headless verification ran via `scratch/test_architectural_solutions.gd` to keep Phase 4 (GUT in `tests/`) on hold until approved.
10. [Session 10: How to Create Tests in Godot 4](./10-how-to-create-tests.md)  
    Comprehensive architectural guide explaining SceneTree test runners, GUT framework testing, signal assertions, lifecycle simulation, and CI integration without creating files yet.
11. [Session 11: Overview of Remaining Work (Excluding Testing)](./11-remaining-tasks-overview.md)  
    Comprehensive audit of remaining production tasks: Windows/Android export presets, CI/CD build pipelines, volume controls, gameplay variety, and release packaging.

---
*A unified log is also maintained in [`docs/CHAT STORE.md`](../CHAT%20STORE.md) and [`docs/chat.md`](../chat.md).*
