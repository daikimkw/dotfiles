# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **chezmoi**-managed dotfiles repository. The source directory (this repo) is `~/.local/share/chezmoi`, and chezmoi renders/copies files from here into `$HOME`. Files are **not** edited in place at their destination — edit the source here, then apply.

## Core workflow

```sh
chezmoi diff              # preview what would change in $HOME
chezmoi apply -v          # render templates + scripts and write to $HOME
chezmoi apply -v ~/.zshrc # apply a single target
chezmoi edit ~/.zshrc     # edit the source file for a given target
chezmoi cd                # cd into this source directory
chezmoi execute-template < dot_zshrc.tmpl  # test template rendering in isolation
```

Secret scanning (run before pushing; secretlint is the only "lint" here):

```sh
pnpm install                          # first-time: installs secretlint
pnpm exec secretlint "**/*"           # scan repo for leaked secrets
```

## chezmoi naming conventions (critical to understand)

Filenames encode metadata via prefixes; the rendered target name has them stripped:

- `dot_zshrc.tmpl` → `~/.zshrc`, rendered as a Go template.
- `executable_notify.sh` → adds the executable bit.
- `private_config.local` → tightened (0600) permissions.
- `symlink_settings.json.tmpl` → the file's *contents* are a path; chezmoi creates a symlink to it.
- `.tmpl` suffix → processed as a Go text/template with chezmoi's `.chezmoi.*` variables.

When adding a new dotfile, place it here with the correct prefix — do not create it directly in `$HOME`.

## Templating & host targeting

Templates branch on machine identity. The primary personal/work machine is hostname **`daikimkw-pc-1`**; guards like the following gate machine- or OS-specific config:

```
{{ if and (eq .chezmoi.os "darwin") (eq .chezmoi.hostname "daikimkw-pc-1") }}...{{ end }}
```

This pattern appears across `dot_Brewfile.tmpl` (extra casks/CLIs), `dot_zshrc.tmpl` (Homebrew prefix), and the scripts. When adding config, decide whether it is universal or host/OS-scoped and wrap accordingly.

## Scripts (`.chezmoiscripts/`)

chezmoi runs these automatically during `apply`, ordered and gated by filename:

- `run_once_install-homebrew.sh` — runs once per machine; bootstraps Homebrew.
- `run_onchange_after_install-packages.sh.tmpl` — re-runs whenever its rendered content changes. It embeds `{{ include "dot_Brewfile.tmpl" | sha256sum }}`, so **editing the Brewfile changes the hash and retriggers `brew bundle`**. Also installs VSCode extensions into Cursor.
- `run_onchange_after_macos-defaults.sh.tmpl` — applies macOS `defaults write` settings.

`run_once_` = execute a single time; `run_onchange_` = re-execute when content changes; `after_` = run after files are written.

## Package management

`dot_Brewfile.tmpl` → `~/.Brewfile` is the single source of truth for Homebrew formulae, casks, and VSCode extensions (`vscode "..."` lines). To add a tool, edit this file; `chezmoi apply` will detect the hash change and run `brew bundle`.

## VSCode config duplication

VSCode settings live in `dot_config/Code/User/` (the XDG-style path). On macOS, the `private_Library/.../Code/User/symlink_*.json.tmpl` files symlink the actual macOS app path (`~/Library/Application Support/Code/User/`) back to `~/.config/Code/User/`, keeping a single canonical copy. Edit the files under `dot_config/Code/User/`.

## Conventions

- Write code/config comments in English (see repo memory). User-facing chat is Japanese.
- Work-specific configs must be chezmoi-deployed but git-ignored, never committed/pushed (e.g. `dot_ssh/private_config.local`, `*.pub` — see `.gitignore`).
- `.chezmoiignore` excludes repo-meta files (`README.md`, `package.json`, `node_modules`, etc.) from being applied to `$HOME`.
