#!/usr/bin/env bash
PLUGIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

main() {
  local theme_cache_dir selected_theme_file

  get-tmux-option() {
    local option value default
    option="$1"
    default="$2"
    value="$(tmux show-option -gqv "$option")"

    if [ -n "$value" ]; then
      echo "$value"
    else
      echo "$default"
    fi
  }

  set() {
    local option=$1
    local value=$2
    tmux set-option -gq "$option" "$value"
  }

  setw() {
    local option=$1
    local value=$2
    tmux set-window-option -gq "$option" "$value"
  }

  local theme
  theme="$(get-tmux-option "@catppuccin_flavour" "mocha")"
  theme_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/tmux"
  selected_theme_file="${theme_cache_dir}/catppuccin-selected-theme.tmuxtheme"
  mkdir -p "${theme_cache_dir}"

  # NOTE: Pulling in the selected theme by the theme that's being set as local
  # variables.
  sed -E 's/^(.+=)/local \1/' \
      > "${selected_theme_file}" \
      < "${PLUGIN_DIR}/catppuccin-${theme}.tmuxtheme"

  source "${selected_theme_file}"

# status
  set status "on"
  set status-interval 2
  set status-bg "${thm_bg}"
  set status-justify "center"
  set status-left-length "100"
  set status-right-length "100"

  set message-style "fg=${thm_blue},bg=${thm_bg},align=centre"
  set message-command-style "fg=${thm_cyan},bg=${thm_gray},align=centre"

  set pane-border-style "fg=${thm_gray}"
  set pane-active-border-style "fg=${thm_blue}"

  setw window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
  setw window-status-separator ""
  setw window-status-style "fg=${thm_fg},bg=${thm_bg},none"

  # --------=== Statusline

  # NOTE: Checking for the value of @catppuccin_window_tabs_enabled
  wt_enabled="$(get-tmux-option "@catppuccin_window_tabs_enabled" "off")"
  readonly wt_enabled

  # These variables are the defaults so that the setw and set calls are easier to parse.
  readonly show_directory_in_window_status="#[fg=$thm_bg,bg=$thm_blue]#I #[fg=$thm_blue,bg=$thm_gray] #{b:pane_current_path}"
  readonly show_directory_in_window_status_current="#[fg=$thm_bg,bg=$thm_orange] #I #[fg=$thm_fg,bg=$thm_bg] #{b:pane_current_path}"
  readonly show_window_in_window_status="#[fg=$thm_orange,bg=$thm_bg]#[fg=$thm_black4,bg=$thm_orange]#{b:pane_current_path} #[fg=$thm_black4,bg=$thm_orange] #I#[fg=$thm_orange,bg=$thm_bg]#[fg=$thm_orange,bg=$thm_bg] "
  readonly show_tmux_logo="#[fg=$thm_orange,bg=$thm_gray]#[fg=$thm_yellow,bg=$thm_orange] #[fg=$thm_yellow,bg=$thm_orange] #[fg=$thm_orange,bg=$thm_bg]#[fg=$thm_orange,bg=$thm_bg] "
  readonly show_tmux_name="#[fg=$thm_blue,bg=$thm_bg]#[fg=$thm_blue,bg=$thm_bg]"
  readonly show_window_in_window_status_current="#[fg=$thm_blue,bg=$thm_bg]#[fg=$thm_bg,bg=$thm_blue]#{b:pane_current_path} #[fg=$thm_bg,bg=$thm_blue] #I#[fg=$thm_blue,bg=$thm_bg]#[fg=$thm_blue,bg=$thm_bg] "

  # Right column 1 by default shows the Window name.
  local right_column1=$show_window

  # Right column 2 by default shows the current Session name.
  local right_column2=$show_session

  local left_column1=$show_tmux_logo
  local left_column2=$show_tmux_name

  # Window status by default shows the current directory basename.
  local window_status_format="#[fg=$thm_orange,bg=$thm_bg]#[fg=$thm_black4,bg=$thm_orange]#I #[fg=$thm_black4,bg=$thm_orange]#W#[fg=$thm_orange,bg=$thm_bg]#[fg=$thm_orange,bg=$thm_bg] "
  local window_status_current_format="#[fg=$thm_blue,bg=$thm_bg]#[fg=$thm_bg,bg=$thm_blue]#I #[fg=$thm_bg,bg=$thm_blue]#W#[fg=$thm_blue,bg=$thm_bg]#[fg=$thm_blue,bg=$thm_bg] "

  # NOTE: With the @catppuccin_window_tabs_enabled set to on, we're going to
  # update the right_column1 and the window_status_* variables.
  if [[ "${wt_enabled}" == "on" ]]; then
    right_column1=$show_directory
    window_status_format=$show_window_in_window_status
    window_status_current_format=$show_window_in_window_status_current
  fi

  set status-left "${show_tmux_name}"
  set status-right "${right_column1}"

  setw window-status-format "${window_status_format}"
  setw window-status-current-format "${window_status_current_format}"

  # --------=== Modes
  #
  setw clock-mode-colour "${thm_blue}"
  setw mode-style "fg=${thm_pink} bg=${thm_black4} bold"
}

main "$@"
