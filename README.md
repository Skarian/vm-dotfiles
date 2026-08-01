# vm-dotfiles

Linux-first dotfiles for a headless VM workflow.

This repo is intended to be cloned to `~/.dotfiles` and treated as the source of
truth for the shell, tmux, prompt, AstroNvim, and supporting CLI tooling on an
Ubuntu/Debian VM.

## Tooling

The root [`install.sh`](./install.sh) script installs and configures:

- Shell and CLI tools: `zsh`, `git`, `tmux`, `ripgrep`, `fd`, `fzf`, `jq`,
  `direnv`, `bat`, `bubblewrap`, `btop`
- Node tooling: `node`, `npm`, `pnpm`, `yarn`
- Agent CLIs: standalone `codex`; npm-managed `claude` and `gemini`
- Python tooling: `python3`, `pipx`, `pyenv`, `uv`
- Rust tooling: `rustup`, `cargo`, `just`, `eza`, `macchina`, `starship`
- Go: `go`
- Neovim: pinned to `0.10.4`

## Setup Behavior

- Upgrades distro-managed packages conservatively with `apt-get upgrade`
- Installs `oh-my-zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and TPM
- Installs `uv` into `~/.local/bin` without modifying shell profiles
- Installs Codex with OpenAI's standalone installer into `~/.local/bin`
- Configures npm's user-level global prefix as `~/.local` and installs the
  remaining managed Node packages there
- Creates the repo-managed symlinks into `$HOME`
- Exposes Ubuntu's `fdfind` and `batcat` binaries as `fd` and `bat`
- Switches the login shell to `zsh`
- Bootstraps tmux plugins

## Usage

Clone the repo to `~/.dotfiles`, navigate into it, and run the installer:

```bash
git clone https://vm-dotfiles.int.exe.xyz/Skarian/vm-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

After the installer finishes, open a new shell session. Then use the agent for
follow-up setup, including Git identity configuration, validation, or
machine-specific tweaks.

## Updating Installed Tools

Update Codex and the npm-managed CLI tools without rerunning the full VM
bootstrap:

```bash
cd ~/.dotfiles
./update-cli-tools.sh
```

Codex follows OpenAI's standalone layout: `~/.local/bin/codex` points into
`~/.codex/packages/standalone`. The updater leaves an exe.dev-provided
`/usr/local/bin/codex` untouched as a lower-priority system fallback.
You can also update Codex by itself with `codex update`.

The other Node-based tools use npm's persisted `~/.local` global prefix, so
ordinary commands such as `npm update -g` and package-specific
`npm install -g <package>@latest` update the active binaries.
If npm itself offers an update, `npm install -g npm@latest` installs the new npm
under the same user-owned prefix and makes `~/.local/bin/npm` active.
The updater also maintains a narrow npm lifecycle-script allowlist for the
managed packages that require one, so accepting an npm 12+ update does not
silently leave Claude or Gemini dependencies incomplete.

Every other installed tool keeps the updater associated with its installation
method:

| Tools | Owner and update route |
| --- | --- |
| Ubuntu packages, Node.js, and the `rustup` executable | Root-owned and updated with `sudo apt update && sudo apt upgrade` |
| Rust toolchain | `rustup update`; Ubuntu intentionally disables `rustup self update` for its packaged executable |
| `uv` | User-owned `~/.local/bin/uv`; update with `uv self update` |
| `just`, `eza`, `macchina`, `starship` | User-owned Cargo binaries; rerun `cargo install --locked just eza macchina starship` |
| Oh My Zsh | User-owned Git checkout; update with `omz update` |
| zsh plugins and `pyenv` | User-owned Git checkouts; update with `git -C <checkout> pull --ff-only` |
| tmux plugins | User-owned TPM checkouts; press prefix + <kbd>U</kbd>, or run `~/.tmux/plugins/tpm/bin/update_plugins all` |
| AstroNvim plugins and Mason packages | User-owned Neovim data; run `:AstroUpdate` |
| pipx applications | Run `pipx upgrade-all`; the bootstrap does not currently install any pipx applications |
| Neovim itself | Repo-pinned tarball under `~/.local/opt`; change the pin in `install.sh` and rerun the installer |

Tools in the first row do not self-replace. If they report that a newer release
exists, keep using apt so their root-owned files remain package-managed. The
remaining native update commands all write only to paths owned by the VM user.

## Notes

- `pyenv` is installed from its upstream Git repository because Ubuntu 24.04
  does not ship a `pyenv` package through `apt`.
- Node.js is installed at a version new enough for the managed agent CLIs.
- Existing installs from the repo's former `~/node` prefix are migrated without
  deleting unrelated packages or the legacy directory itself.
- Neovim is pinned to `0.10.4` for AstroNvim compatibility instead of using the
  older Ubuntu package.
- The installer is safe to rerun: it only clones missing third-party repos and
  backs up conflicting live files before replacing them with symlinks.
