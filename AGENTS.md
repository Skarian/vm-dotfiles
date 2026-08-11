# AGENTS.md

This repository is the source of truth for a headless Linux VM setup.

## Scope

- Target platform: Ubuntu/Debian-style headless Linux VM
- Canonical clone location: `~/.dotfiles`

## Initial Bootstrap

Assume the user has already cloned this repo to `~/.dotfiles` and run
[`install.sh`](./install.sh) from the repo root.

## Agent Follow-Up

After bootstrap, when an agent is asked to continue setup with this repo, assume
the repository is already present at `~/.dotfiles`:

1. Treat files inside `~/.dotfiles` as the only source of truth
2. Prefer repo-managed edits over one-off fixes in `$HOME`
3. Before making commits from the VM, verify whether `git user.name` and
   `git user.email` are already explicitly configured
4. Ask the user for Git identity values only if they are missing, ambiguous, or
   the user wants to change them
5. Configure any missing or updated Git identity explicitly instead of relying
   on the VM's fallback identity before making commits from the VM

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

- `zsh`, `git`, `tmux`, `ripgrep`, `fd`, `fzf`, `jq`, `direnv`, `bat`,
  `bubblewrap`
- `Node.js 20+`, `npm`, `pnpm`, `yarn`
- standalone `codex`; npm-managed `claude`, `gemini`
- `python3`, `pipx`, `pyenv`, `uv`
- `rustup`, `cargo`, `just`, `eza`, `macchina`, `starship`
- `go`
- `btop`

## Neovim Requirement

Neovim is pinned to `0.10.4`.

- Do not rely on the distro `neovim` package version
- Use the repo bootstrap, which installs the official `0.10.4` Linux tarball
- The installer must finish the headless AstroNvim bootstrap, including the
  locked Lazy plugin set, configured Treesitter parsers, and Mason-managed tools

## Shell and Tmux Notes

- `zsh` is the default shell
- `oh-my-zsh` is expected
- Installed zsh plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`
- TPM is expected for tmux plugins
- TPM plugin installation may be bootstrapped by the installer

## CLI Tool Ownership

- Codex is installed and updated with OpenAI's standalone installer
- The active Codex path is `~/.local/bin/codex`, resolving into
  `~/.codex/packages/standalone`
- Do not install Codex with npm or replace the exe.dev-provided
  `/usr/local/bin/codex`
- npm's user-level global prefix is `~/.local`
- Keep npm's global lifecycle-script allowlist limited to reviewed dependencies;
  do not enable all install scripts globally
- Run `./update-cli-tools.sh` to update Codex and the npm-managed CLI tools
- The legacy `~/node` prefix is not part of `PATH`

Other updater ownership must remain consistent with the installation method:

- apt owns the distro packages, Node.js, and the `rustup` executable
- `rustup update` owns the user toolchain; distro rustup may reject
  `rustup self update` and direct the user back to apt
- uv owns `~/.local/bin/uv` and supports `uv self update`
- Cargo owns `just`, `eza`, `macchina`, and `starship` under `~/.cargo/bin`
- Oh My Zsh, its external zsh plugins, TPM, TPM plugins, and pyenv are
  user-owned Git checkouts
- AstroNvim's Lazy and Mason data is user-owned; the Neovim executable remains
  repo-pinned under `~/.local/opt`
- Do not add a second package manager for one of these tools merely to provide
  a different update command

## Agent Rules

- Keep the repo Linux-safe and VM-focused
- Avoid machine-specific paths and host-only aliases
- Prefer changing repo files over mutating generated or cached state under `~/.local/share`
- If plugin lockfiles change because of an intentional bootstrap or plugin sync, keep them in the repo if they reflect the desired state

## Continuity

- Use a local gitignored file named `.continuity.yml` to track branch and pull
  request continuity across turns and sessions.
- Treat GitHub as the source of truth for PR state, and `.continuity.yml` as the
  local record of the current line of work.
- Before doing branch or PR workflow, read `.continuity.yml` if it exists, check
  the current git branch, and reconcile that state with GitHub.
- Keep only one active line of work in `.continuity.yml` at a time. Record older
  completed or abandoned lines of work in the history section if needed.

## Change Workflow

- The user may request changes to the repo-managed configuration after bootstrap.
- Make the requested changes in the repo, then validate them before asking the
  user to approve the result.
- Do not commit changes until the user has validated the result and explicitly
  approved committing them.
- When committing approved changes, use a branch named `agent/<topic>`.
- Use Conventional Commit messages for agent-created commits, such as
  `feat: ...`, `fix: ...`, `docs: ...`, or `chore: ...`.
- Record the active branch, topic, and PR metadata in `.continuity.yml`.
- If the user requests several follow-up changes in the same line of work, keep
  using the same `agent/<topic>` branch and add additional approved commits to
  it until the user wants a pull request opened.
- If there is already an open PR for the active `agent/<topic>` branch and the
  new request is part of the same line of work, continue on that branch and push
  additional approved commits to it.
- If there is already an open PR for the active `agent/<topic>` branch and the
  new request is unrelated, do not silently stack it onto that branch; ask
  whether to continue the open branch or start a new one.
- Do not open a pull request until the user has approved the current branch
  state for review.
- When requested, open a pull request from `agent/<topic>` into `main` for the
  user's review and approval on GitHub.
- Do not treat `gh` authentication as a required precondition for branch or PR
  workflow if `git push` and the GitHub connector are sufficient. Prefer using
  `git` for branch and push operations, and use the GitHub connector to inspect
  or open pull requests. Use `gh` only when the connector cannot complete the
  required GitHub operation.
- After opening a pull request, record the PR number and URL in
  `.continuity.yml`.
- On later turns, if the current branch is an `agent/<topic>` branch, check the
  GitHub PR state for that branch before continuing work or cleanup.
- If that PR is merged and the working tree is clean, switch the local repo back
  to `main` so the working tree reflects the long-running base branch again, and
  update `.continuity.yml` to clear the active line of work.
- If that PR is merged but the working tree is not clean, do not switch branches
  until the agent has resolved or confirmed what to do with the local changes.
- If `.continuity.yml` is missing or stale, reconstruct the current state from
  the active branch and GitHub before continuing.

## Validation

After changes that affect setup, validate command availability and basic health
for at least:

- Core shell and CLI tools: `git`, `zsh`, `tmux`, `rg`, `fd`, `bat`, `jq`,
  `direnv`, `bwrap`
- Node and agent CLIs: `node`, `npm`, `pnpm`, `yarn`, `codex`, `claude`, `gemini`
- Python tooling: `python3`, `pipx`, `pyenv`, `uv`
- Rust tooling: `rustup`, `cargo`, `just`, `eza`, `macchina`, `starship`
- Other tools: `nvim`, `go`, `btop`

Also verify CLI ownership and update routing:

- `npm config get prefix` reports `~/.local`
- `~/.local/bin/codex` resolves into `~/.codex/packages/standalone`
- npm-managed CLI binaries resolve from `~/.local/bin`
- Any exe.dev-provided `/usr/local/bin/codex` remains lower priority
- `uv self update`, `rustup update`, `omz update`, TPM's plugin updater, and
  `:AstroUpdate` can complete from a normal user session
- Cargo-installed binaries resolve from `~/.cargo/bin` and remain user-owned
- distro-installed executables remain root-owned and apt-managed
