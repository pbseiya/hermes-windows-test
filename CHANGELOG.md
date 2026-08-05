# Changelog

All notable changes to Hermes Windows Installer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-08-05

### Added
- Auto-query models from LiteLLM proxy (`/v1/models` endpoint)
- 20 models support (qwen3.7-plus, glm-5, kimi-k2.5, MiniMax-M2.5, + anthropic variants)
- Full UI installation (Dashboard, Desktop, TUI)
- Telegram Gateway integration with auto-start
- Task Scheduler auto-start (Gateway 30s, Dashboard 60s after login)
- Startup Folder fallback if Task Scheduler fails
- Antivirus-friendly npm install (5 retries with increasing delays)
- Robocopy trick for fast node_modules deletion (uninstall ~2 min)
- DPAPI workaround for Electron on managed computers
- LiteLLM Proxy configuration (Course 0)
- One-line install command (`irm ... | iex`)
- One-line uninstall command
- Complete documentation (INSTALLATION_GUIDE.md, TESTING_GUIDE.md, ONE_LINE_COMMANDS.md)

### Changed
- Web workspace installs WITHOUT `--ignore-scripts` for proper symlinks
- Configured npm for corporate environments (maxsockets, retries, timeouts)
- Gateway uses venv Python (not embeddable Python)

### Fixed
- Git extraction argument format
- Python venv creation (use `python -m venv` instead of uv)
- PATH refresh after Git install
- Dashboard readiness check (looks for vite package)
- Telegram Gateway auto-start after installation

### Security
- No credentials in code (all via stdin prompts)
- `.env` and `config.yaml` in `.gitignore`
- Secret redaction configurable

### Known Issues
- Antivirus blocks npm install in workspaces → script retries 5x
- If antivirus NOT disabled during install, Dashboard/Desktop need manual rebuild
- Desktop shows benign warnings on first launch (registry, WSL, session 404s)

---

## [Unreleased]

_(Add future changes here)_
