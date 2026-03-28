# AGENTS.md

This repository is the source of truth for a headless Linux VM setup.

## Scope

- Target platform: Ubuntu/Debian-style headless Linux VM
- Canonical clone location: `~/.dotfiles`
- Do not treat macOS or GUI tooling as in-scope for this repo

## Setup Contract

When an agent is asked to set up a VM with this repo, assume the repository has
been cloned to `~/.dotfiles`:

1. Treat files inside `~/.dotfiles` as the only source of truth
2. Run [`install.sh`](./install.sh) from the repo root
3. Prefer repo-managed edits over one-off fixes in `$HOME`
4. Do not add automatic headless AstroNvim bootstrap into the installer; Neovim
   initialization should be run manually after setup

If a live config file under `$HOME` needs to change, update the repo file first
and then symlink it into place.

During setup, upgrade normal distro-managed packages conservatively. Do not
override versions for tools that this repo intentionally pins outside the distro
package manager, such as Neovim `0.10.4`.

## Required Git Identity Setup

Git identity is a required part of VM setup.

- During setup, ask the user what `git user.name` should be for this VM
- During setup, ask the user whether they want to configure a `git user.email`,
  and if so, what it should be
- Configure the chosen Git identity explicitly instead of relying on the VM's
  fallback identity
- Do this as part of the initial machine setup, before making commits from the
  VM

## Managed Symlinks

The intended live links are:

- `~/.dotfiles/zsh/.zshrc` -> `~/.zshrc`
- `~/.dotfiles/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh` -> `~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh`
- `~/.dotfiles/tmux/.tmux.conf` -> `~/.tmux.conf`
- `~/.dotfiles/starship/starship.toml` -> `~/.config/starship.toml`
- `~/.dotfiles/astronvim_v4` -> `~/.config/astronvim_v4`
- `~/.dotfiles/macchina` -> `~/.config/macchina`
- `~/.dotfiles/btop` -> `~/.config/btop`

## Tooling Expectations

The VM bootstrap is expected to install:

- `zsh`, `git`, `tmux`, `ripgrep`, `fd`, `fzf`, `jq`, `direnv`, `bat`
- `node`, `npm`, `pnpm`, `yarn`
- `python3`, `pipx`, `pyenv`
- `rustup`, `cargo`, `just`, `eza`, `macchina`, `starship`
- `go`
- `btop`

## Neovim Requirement

Neovim is pinned to `0.10.4`.

- Do not rely on the distro `neovim` package version
- Use the repo bootstrap, which installs the official `0.10.4` Linux tarball
- AstroNvim in this repo should be tested against `NVIM_APPNAME=astronvim_v4 nvim`

## Shell and Tmux Notes

- `zsh` is the default shell
- `oh-my-zsh` is expected
- Installed zsh plugins:
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`
- TPM is expected for tmux plugins
- TPM plugin installation may be bootstrapped by the installer
- AstroNvim should initialize on first interactive `NVIM_APPNAME=astronvim_v4 nvim`
  launch, not during headless install

## Agent Rules

- Keep the repo Linux-safe and VM-focused
- Do not reintroduce machine-specific paths like `/Users/...`, `~/scripts`, or other host-only aliases
- Do not add macOS-only, Homebrew-only, or GUI-only configuration back into the repo
- Prefer changing repo files over mutating generated or cached state under `~/.local/share`
- If plugin lockfiles change because of an intentional bootstrap or plugin sync, keep them in the repo if they reflect the desired state

## Validation

After changes that affect setup, validate at least:

- `zsh`
- `tmux`
- `nvim`
- `rg`
- `fd`
- `bat`
- `node`
- `npm`
- `pnpm`
- `yarn`
- `python3`
- `pipx`
- `pyenv`
- `rustup`
- `just`
- `eza`
- `macchina`
- `starship`

If AstroNvim boots but Mason-managed tools are still installing, that is not the
same as a broken Neovim config. Confirm startup separately from optional package
downloads, and do it interactively rather than by adding headless AstroNvim
bootstrap to the installer.
