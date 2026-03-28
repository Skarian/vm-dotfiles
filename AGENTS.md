# AGENTS.md

This repository is the source of truth for a headless Linux VM setup.

## Scope

- Target platform: Ubuntu/Debian-style headless Linux VM
- Canonical clone location: `~/.dotfiles`

## Initial Bootstrap

Assume the user has already completed the manual bootstrap flow:

1. Cloned this repo to `~/.dotfiles`
2. Ran [`install.sh`](./install.sh) from the repo root

## Agent Follow-Up

After bootstrap, when an agent is asked to continue setup with this repo, assume
the repository is already present at `~/.dotfiles`:

1. Treat files inside `~/.dotfiles` as the only source of truth
2. Prefer repo-managed edits over one-off fixes in `$HOME`
3. Ask the user what `git user.name` should be for this VM
4. Ask whether they want to configure `git user.email`, and if so, what it
   should be
5. Configure the chosen Git identity explicitly instead of relying on the VM's
   fallback identity before making commits from the VM

If a live config file under `$HOME` needs to change, update the repo file first
and then symlink it into place.

During setup, upgrade normal distro-managed packages conservatively. Do not
override versions for tools that this repo intentionally pins outside the distro
package manager, such as Neovim `0.10.4`.

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
- `Node.js 20+`, `npm`, `pnpm`, `yarn`
- `codex`, `claude`, `gemini`
- `python3`, `pipx`, `pyenv`
- `rustup`, `cargo`, `just`, `eza`, `macchina`, `starship`
- `go`
- `btop`

## Neovim Requirement

Neovim is pinned to `0.10.4`.

- Do not rely on the distro `neovim` package version
- Use the repo bootstrap, which installs the official `0.10.4` Linux tarball
- Do not add automatic headless AstroNvim bootstrap into the installer

## Shell and Tmux Notes

- `zsh` is the default shell
- `oh-my-zsh` is expected
- Installed zsh plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`
- TPM is expected for tmux plugins
- TPM plugin installation may be bootstrapped by the installer

## Agent Rules

- Keep the repo Linux-safe and VM-focused
- Avoid machine-specific paths and host-only aliases
- Prefer changing repo files over mutating generated or cached state under `~/.local/share`
- If plugin lockfiles change because of an intentional bootstrap or plugin sync, keep them in the repo if they reflect the desired state

## Change Workflow

- The user may request changes to the repo-managed configuration after bootstrap.
- Make the requested changes in the repo, then validate them before asking the
  user to approve the result.
- Do not commit changes until the user has validated the result and explicitly
  approved committing them.
- When committing approved changes, use a branch named `agent/<topic>`.
- After committing, the agent may open a pull request targeting the long-running
  base branch for the user's review and approval on GitHub.

## Validation

After changes that affect setup, validate command availability and basic health
for at least:

- Core shell and CLI tools: `git`, `zsh`, `tmux`, `rg`, `fd`, `bat`, `jq`, `direnv`
- Node and agent CLIs: `node`, `npm`, `pnpm`, `yarn`, `codex`, `claude`, `gemini`
- Python tooling: `python3`, `pipx`, `pyenv`
- Rust tooling: `rustup`, `cargo`, `just`, `eza`, `macchina`, `starship`
- Other tools: `nvim`, `go`, `btop`
