#!/usr/bin/env bash
set -euo pipefail

LOCAL_BIN_DIR="${HOME}/.local/bin"
NPM_GLOBAL_PREFIX="${HOME}/.local"
LEGACY_NPM_GLOBAL_PREFIX="${HOME}/node"
CODEX_INSTALLER_URL="https://chatgpt.com/codex/install.sh"

NPM_GLOBALS=(
  @anthropic-ai/claude-code
  @google/gemini-cli
  typescript
  neovim
  pnpm
  yarn
)

NPM_INSTALL_SCRIPT_ALLOWLIST=(
  @anthropic-ai/claude-code
  yarn
  @github/keytar
  node-pty
)

LEGACY_NPM_GLOBALS=(
  @openai/codex
  "${NPM_GLOBALS[@]}"
)

LEGACY_SHIMS=(
  codex
  claude
  gemini
  pnpm
  tsc
  tsserver
  neovim-node-host
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

require_tooling() {
  have curl || die "curl is required to install Codex"
  have node || die "Node.js is required; run ./install.sh first"
  have npm || die "npm is required; run ./install.sh first"
}

remove_legacy_shims() {
  local link_path
  local legacy_target
  local tool

  for tool in "${LEGACY_SHIMS[@]}"; do
    link_path="${LOCAL_BIN_DIR}/${tool}"
    legacy_target="${LEGACY_NPM_GLOBAL_PREFIX}/bin/${tool}"

    if [ -L "${link_path}" ] && [ "$(readlink "${link_path}")" = "${legacy_target}" ]; then
      unlink "${link_path}"
      log "Removed legacy shim ${link_path}"
    fi
  done
}

configure_npm_prefix() {
  local configured_prefix

  log "Configuring user-owned npm globals in ${NPM_GLOBAL_PREFIX}"
  mkdir -p "${NPM_GLOBAL_PREFIX}"
  npm config set prefix "${NPM_GLOBAL_PREFIX}" --location=user
  configured_prefix="$(npm config get prefix)"

  if [ "${configured_prefix}" != "${NPM_GLOBAL_PREFIX}" ]; then
    die "npm global prefix is ${configured_prefix}, expected ${NPM_GLOBAL_PREFIX}"
  fi

  export PATH="${LOCAL_BIN_DIR}:${PATH}"
  hash -r
}

configure_npm_install_scripts() {
  local current_allowlist
  local merged_allowlist
  local npmrc
  local package
  local tmp_file

  npmrc="$(npm config get userconfig)"
  mkdir -p "$(dirname "${npmrc}")"
  touch "${npmrc}"

  current_allowlist="$(sed -n 's/^[[:space:]]*allow-scripts[[:space:]]*=[[:space:]]*//p' "${npmrc}" | tail -n 1)"
  merged_allowlist="${current_allowlist}"

  for package in "${NPM_INSTALL_SCRIPT_ALLOWLIST[@]}"; do
    case ",${merged_allowlist}," in
      *",${package},"*) ;;
      *)
        if [ -n "${merged_allowlist}" ]; then
          merged_allowlist="${merged_allowlist},${package}"
        else
          merged_allowlist="${package}"
        fi
        ;;
    esac
  done

  if [ "${merged_allowlist}" = "${current_allowlist}" ]; then
    return
  fi

  tmp_file="$(mktemp "${npmrc}.tmp.XXXXXX")"
  awk '!/^[[:space:]]*allow-scripts[[:space:]]*=/' "${npmrc}" >"${tmp_file}"
  printf 'allow-scripts=%s\n' "${merged_allowlist}" >>"${tmp_file}"
  mv "${tmp_file}" "${npmrc}"
  log "Approved install scripts required by the managed global packages"
}

install_npm_globals() {
  log "Installing npm-managed CLI tools"

  # Codex is managed by its standalone installer, not npm. Removing an older
  # npm-managed copy prevents the two installation methods from competing for
  # ~/.local/bin/codex.
  if npm list -g --depth=0 @openai/codex >/dev/null 2>&1; then
    npm uninstall -g @openai/codex
  fi
  npm install -g "${NPM_GLOBALS[@]}"
}

install_codex() {
  local codex_path
  local codex_real

  log "Installing or updating Codex with the official standalone installer"
  # Keep host-provided Codex binaries out of the installer's discovery path.
  # Otherwise it may append a second PATH block to our symlinked shell config
  # while resolving a legacy installation conflict.
  curl -fsSL "${CODEX_INSTALLER_URL}" | env \
    PATH="${LOCAL_BIN_DIR}:/usr/bin:/bin" \
    CODEX_NON_INTERACTIVE=1 \
    sh
  hash -r

  codex_path="$(command -v codex || true)"
  if [ "${codex_path}" != "${LOCAL_BIN_DIR}/codex" ]; then
    die "active Codex is ${codex_path:-missing}, expected ${LOCAL_BIN_DIR}/codex"
  fi

  codex_real="$(readlink -f "${codex_path}")"
  case "${codex_real}" in
    "${HOME}/.codex/packages/standalone/"*) ;;
    *) die "Codex resolves outside the standalone install: ${codex_real}" ;;
  esac
}

remove_legacy_npm_globals() {
  if [ ! -d "${LEGACY_NPM_GLOBAL_PREFIX}/lib/node_modules" ]; then
    return
  fi

  log "Removing repo-managed packages from legacy prefix ${LEGACY_NPM_GLOBAL_PREFIX}"
  npm uninstall -g --prefix "${LEGACY_NPM_GLOBAL_PREFIX}" "${LEGACY_NPM_GLOBALS[@]}"
}

validate_cli_tools() {
  local claude_version
  local gemini_version
  local tool
  local tool_path

  for tool in claude gemini pnpm yarn tsc neovim-node-host; do
    tool_path="$(command -v "${tool}" || true)"
    case "${tool_path}" in
      "${LOCAL_BIN_DIR}/"*) ;;
      *) die "${tool} resolves to ${tool_path:-missing}, expected ${LOCAL_BIN_DIR}" ;;
    esac
  done

  claude_version="$(claude --version 2>&1)"
  case "${claude_version}" in
    *"Claude Code"*) ;;
    *) die "Claude failed its version check: ${claude_version}" ;;
  esac

  gemini_version="$(gemini --version 2>&1)"
  case "${gemini_version}" in
    [0-9]*.[0-9]*.[0-9]*) ;;
    *) die "Gemini failed its version check: ${gemini_version}" ;;
  esac

  log "CLI tool versions"
  codex --version
  printf '%s\n' "${claude_version}"
  printf '%s\n' "${gemini_version}"
  node --version
  npm --version
  pnpm --version
  yarn --version
}

main() {
  require_user_context
  require_tooling
  mkdir -p "${LOCAL_BIN_DIR}"
  remove_legacy_shims
  configure_npm_prefix
  configure_npm_install_scripts
  install_npm_globals
  install_codex
  remove_legacy_npm_globals
  validate_cli_tools
}

main "$@"
