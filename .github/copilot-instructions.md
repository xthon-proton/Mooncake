# Copilot Instructions for Mooncake

This repository is the serving platform for Kimi (Moonshot AI). It is primarily C++ and Python.

## Available Skills

| Skill | Auto-Activates On | Load Manually |
|---|---|---|
| draw.io Diagrams | `*.drawio`, `*.drawio.svg`, `*.drawio.png` | Load `.github/skills/draw-io/SKILL.md` |

## General Notes

- For draw.io diagram tasks, always load `.github/skills/draw-io/SKILL.md` first for the full workflow, XML recipes, and troubleshooting.
- Validate all diagrams before committing: `python .github/skills/draw-io/scripts/validate-drawio.py <file>`.
- Architecture diagrams belong in `docs/` or `architecture/` directories.
