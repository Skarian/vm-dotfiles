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
- Agent CLIs: `codex`, `claude`, `gemini`
- Python tooling: `python3`, `pipx`, `pyenv`
- Rust tooling: `rustup`, `cargo`, `just`, `eza`, `macchina`, `starship`
- Go: `go`
- Neovim: pinned to `0.10.4`

## Setup Behavior

- Upgrades distro-managed packages conservatively with `apt-get upgrade`
- Installs `oh-my-zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and TPM
- Installs the managed global Node packages for this setup, including the agent CLIs
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

## Notes

- `pyenv` is installed from its upstream Git repository because Ubuntu 24.04
  does not ship a `pyenv` package through `apt`.
- Node.js is installed at a version new enough for the managed agent CLIs.
- Neovim is pinned to `0.10.4` for AstroNvim compatibility instead of using the
  older Ubuntu package.
- The installer is safe to rerun: it only clones missing third-party repos and
  backs up conflicting live files before replacing them with symlinks.
