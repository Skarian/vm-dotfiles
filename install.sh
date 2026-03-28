#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN_DIR="${HOME}/.local/bin"
NODE_GLOBAL_PREFIX="${HOME}/node"
OH_MY_ZSH_DIR="${HOME}/.oh-my-zsh"
OH_MY_ZSH_CUSTOM="${OH_MY_ZSH_DIR}/custom"
TPM_DIR="${HOME}/.tmux/plugins/tpm"
PYENV_DIR="${HOME}/.pyenv"
NEOVIM_VERSION="0.10.4"
NEOVIM_PARENT_DIR="${HOME}/.local/opt"
NEOVIM_INSTALL_DIR="${NEOVIM_PARENT_DIR}/nvim-linux-x86_64-${NEOVIM_VERSION}"
NEOVIM_CACHE_DIR="${HOME}/.cache/vm-dotfiles"
NEOVIM_TARBALL="${NEOVIM_CACHE_DIR}/nvim-linux-x86_64-${NEOVIM_VERSION}.tar.gz"
NEOVIM_ARCHIVE_URL="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz"

APT_PACKAGES=(
  build-essential
  curl
  zsh
  git
  tmux
  ripgrep
  fd-find
  fzf
  jq
  direnv
  bat
  nodejs
  npm
  python3
  pipx
  rustup
  golang-go
  btop
)

CARGO_PACKAGES=(
  just
  eza
  macchina
  starship
)

NPM_GLOBALS=(
  @openai/codex
  typescript
  neovim
  pnpm
  yarn
)

log() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

have() {
  command -v "$1" >/dev/null 2>&1
}

require_user_context() {
  if [ "${EUID}" -eq 0 ]; then
    die "run this script as your normal user, not as root"
  fi
}

require_apt() {
  have apt-get || die "this installer currently supports apt-based Linux systems"
  have sudo || die "sudo is required to install system packages"
}

clone_if_missing() {
  local repo_url="$1"
  local target_dir="$2"

  if [ -d "${target_dir}/.git" ]; then
    log "Keeping existing checkout at ${target_dir}"
    return
  fi

  if [ -e "${target_dir}" ]; then
    die "refusing to clone into existing non-git path: ${target_dir}"
  fi

  git clone "${repo_url}" "${target_dir}"
}

backup_and_link() {
  local source_path="$1"
  local target_path="$2"
  local backup_path
  local source_real
  local target_real

  mkdir -p "$(dirname "${target_path}")"

  if [ -L "${target_path}" ] || [ -e "${target_path}" ]; then
    source_real="$(readlink -f "${source_path}")"
    target_real="$(readlink -f "${target_path}" 2>/dev/null || true)"

    if [ -n "${target_real}" ] && [ "${target_real}" = "${source_real}" ]; then
      return
    fi

    backup_path="${target_path}.bak.$(date +%Y%m%d%H%M%S)"
    mv "${target_path}" "${backup_path}"
    log "Backed up ${target_path} -> ${backup_path}"
  fi

  ln -s "${source_path}" "${target_path}"
}

install_apt_packages() {
  log "Refreshing apt metadata"
  sudo apt-get update

  # Keep apt-managed packages current, but avoid a more aggressive dist/full
  # upgrade. Repo-pinned tools such as Neovim are managed separately below.
  log "Upgrading installed apt packages"
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

  log "Installing apt packages"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${APT_PACKAGES[@]}"
}

install_neovim() {
  local extracted_dir

  mkdir -p "${LOCAL_BIN_DIR}" "${NEOVIM_PARENT_DIR}" "${NEOVIM_CACHE_DIR}"
  extracted_dir="${NEOVIM_PARENT_DIR}/nvim-linux-x86_64"

  if [ ! -x "${NEOVIM_INSTALL_DIR}/bin/nvim" ]; then
    log "Installing Neovim ${NEOVIM_VERSION}"
    curl -fL "${NEOVIM_ARCHIVE_URL}" -o "${NEOVIM_TARBALL}"
    rm -rf "${extracted_dir}"
    tar -xzf "${NEOVIM_TARBALL}" -C "${NEOVIM_PARENT_DIR}"
    mv "${extracted_dir}" "${NEOVIM_INSTALL_DIR}"
  else
    log "Keeping existing Neovim ${NEOVIM_VERSION} install"
  fi

  ln -sfn "${NEOVIM_INSTALL_DIR}/bin/nvim" "${LOCAL_BIN_DIR}/nvim"
}

install_shell_tooling() {
  log "Installing oh-my-zsh and plugin repositories"
  clone_if_missing "https://github.com/ohmyzsh/ohmyzsh.git" "${OH_MY_ZSH_DIR}"
  mkdir -p "${OH_MY_ZSH_CUSTOM}/plugins"
  clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions" \
    "${OH_MY_ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  clone_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "${OH_MY_ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"

  log "Installing tmux plugin manager"
  mkdir -p "$(dirname "${TPM_DIR}")"
  clone_if_missing "https://github.com/tmux-plugins/tpm" "${TPM_DIR}"

  log "Installing pyenv from upstream"
  clone_if_missing "https://github.com/pyenv/pyenv.git" "${PYENV_DIR}"
}

install_rust_tools() {
  log "Initializing rustup toolchain"
  export PATH="${HOME}/.cargo/bin:${PATH}"
  rustup default stable

  log "Installing cargo packages"
  cargo install --locked "${CARGO_PACKAGES[@]}"
}

install_node_globals() {
  log "Installing global Node packages into ${NODE_GLOBAL_PREFIX}"
  mkdir -p "${NODE_GLOBAL_PREFIX}"
  export PATH="${NODE_GLOBAL_PREFIX}/bin:${PATH}"
  npm install -g --prefix "${NODE_GLOBAL_PREFIX}" "${NPM_GLOBALS[@]}"
}

create_linux_shims() {
  log "Creating Linux command shims"
  mkdir -p "${LOCAL_BIN_DIR}"

  if have fdfind; then
    ln -sfn "$(command -v fdfind)" "${LOCAL_BIN_DIR}/fd"
  fi

  if have batcat; then
    ln -sfn "$(command -v batcat)" "${LOCAL_BIN_DIR}/bat"
  fi

  for tool in codex pnpm tsc tsserver neovim-node-host; do
    if [ -e "${NODE_GLOBAL_PREFIX}/bin/${tool}" ]; then
      ln -sfn "${NODE_GLOBAL_PREFIX}/bin/${tool}" "${LOCAL_BIN_DIR}/${tool}"
    fi
  done
}

setup_symlinks() {
  log "Linking repo-managed configs into ${HOME}"

  mkdir -p "${HOME}/.zsh"

  backup_and_link "${DOTFILES_DIR}/zsh/.zshrc" "${HOME}/.zshrc"
  backup_and_link \
    "${DOTFILES_DIR}/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh" \
    "${HOME}/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh"
  backup_and_link "${DOTFILES_DIR}/tmux/.tmux.conf" "${HOME}/.tmux.conf"
  backup_and_link "${DOTFILES_DIR}/starship/starship.toml" "${HOME}/.config/starship.toml"
  backup_and_link "${DOTFILES_DIR}/astronvim_v4" "${HOME}/.config/astronvim_v4"
  backup_and_link "${DOTFILES_DIR}/macchina" "${HOME}/.config/macchina"

  if [ -d "${DOTFILES_DIR}/btop" ]; then
    backup_and_link "${DOTFILES_DIR}/btop" "${HOME}/.config/btop"
  fi
}

set_default_shell() {
  local zsh_path
  local current_shell

  zsh_path="$(command -v zsh)"
  current_shell="$(getent passwd "${USER}" | cut -d: -f7)"

  if [ "${current_shell}" = "${zsh_path}" ]; then
    log "Default shell is already ${zsh_path}"
    return
  fi

  log "Setting default shell to ${zsh_path}"
  sudo usermod -s "${zsh_path}" "${USER}"
}

bootstrap_tmux() {
  log "Bootstrapping tmux plugins"
  tmux start-server || true
  tmux new-session -d -s bootstrap >/dev/null 2>&1 || true
  "${TPM_DIR}/bin/install_plugins"
  tmux kill-session -t bootstrap >/dev/null 2>&1 || true
}

main() {
  require_user_context
  require_apt

  install_apt_packages
  install_neovim
  install_shell_tooling
  install_rust_tools
  install_node_globals
  create_linux_shims
  setup_symlinks
  set_default_shell
  bootstrap_tmux

  log "Done. Open a new shell session to pick up the default zsh login shell."
  log "Then bootstrap manually:"
  log "  NVIM_APPNAME=astronvim_v4 nvim"
}

main "$@"
