# vm-dotfiles

Linux-first dotfiles for a headless VM workflow.

This repo is intended to be cloned to `~/.dotfiles` and treated as the source of
truth for the shell, tmux, prompt, AstroNvim, and supporting CLI tooling on an
Ubuntu/Debian VM.

## What the installer does

The root [`install.sh`](./install.sh) script bootstraps the
same setup configured on this machine:

- Installs the required Ubuntu packages with `apt`
- Upgrades already-installed `apt` packages conservatively with `apt-get upgrade`
- Installs Neovim `0.10.4` from the official release tarball
- Installs `oh-my-zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, TPM,
  and `pyenv`
- Initializes `rustup` and installs `just`, `eza`, `macchina`, and `starship`
- Installs the Node globals used by this setup, including `@openai/codex`,
  `typescript`, `neovim`, `pnpm`, and `yarn`
- Creates the Linux symlinks from this repo into `$HOME`
- Exposes Ubuntu's `fdfind` and `batcat` binaries as `fd` and `bat`
- Switches the login shell to `zsh`
- Bootstraps tmux plugins and the AstroNvim config

## Usage

Clone the repo to `~/.dotfiles`, then run the installer from inside the repo:

```bash
git clone https://vm-dotfiles.int.exe.xyz/Skarian/vm-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

After the script finishes, open a new shell session or log in again to pick up
the default `zsh` shell cleanly.

## Notes

- `pyenv` is installed from its upstream Git repository because Ubuntu 24.04
  does not ship a `pyenv` package through `apt`.
- Neovim is pinned to `0.10.4` for AstroNvim compatibility instead of using the
  older Ubuntu package.
- The installer upgrades normal `apt` packages, but keeps repo-pinned tools on
  the versions defined by this repo.
- The installer is idempotent for normal re-runs: it only clones missing
  third-party repos and backs up conflicting live files before replacing them
  with symlinks.
- AstroNvim plugin bootstrap is automated. If Mason-managed tools are still
  downloading when the headless bootstrap exits, run
  `NVIM_APPNAME=astronvim_v4 nvim` once interactively to finish them.
