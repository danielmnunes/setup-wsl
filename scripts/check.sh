#!/usr/bin/env bash
set -euo pipefail

version="${PYTHON_VERSION:-3.14}"
default_python="${HOME}/.local/bin/python"

git --version
curl --version
dpkg-query -W unzip
java -version
go version
node --version
bun --version
uv --version
glab version
rg --version
fd --version
jq --version
bat --version
eza --version
delta --version
fzf --version
zoxide --version
starship --version
fastfetch --version
pkg-config --version
gcc --version
dpkg-query -W zsh wget zip htop tree lsb-release
uv python find "$version"

if [[ ! -x "$default_python" ]]; then
  echo "Não encontrei ${default_python}. Rode mise run bootstrap de novo." >&2
  exit 1
fi

"$default_python" --version

login_shell="$(getent passwd "${USER:-$(id -un)}" | cut -d: -f7)"
case "$login_shell" in
  */zsh) ;;
  *)
    echo "O shell da conta é ${login_shell}. O esperado é o zsh." >&2
    exit 1
    ;;
esac

if [[ ! -d "${HOME}/dev" ]]; then
  echo "Não encontrei ${HOME}/dev." >&2
  exit 1
fi

starship_config="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
if ! grep -q '^scan_timeout = 30$' "$starship_config"; then
  echo "O Starship em ${starship_config} não é o deste setup." >&2
  exit 1
fi

expect_git() {
  local key="$1" want="$2" got
  got="$(git config --global --get "$key" || true)"
  if [[ "$got" != "$want" ]]; then
    echo "git config ${key} = '${got}'. O esperado é '${want}'." >&2
    exit 1
  fi
}

expect_git init.defaultBranch main
expect_git pull.rebase true
expect_git core.autocrlf false
expect_git core.pager delta
expect_git core.fsmonitor true
expect_git core.untrackedCache true
expect_git alias.st "status -sb"
expect_git alias.lg "log --oneline --graph --decorate --all"

if [[ -n "${WSL_DISTRO_NAME:-}" ]] || { [[ -d /mnt/c/Windows ]] && [[ -e /proc/sys/fs/binfmt_misc/WSLInterop ]]; }; then
  grep -q '^systemd=true$' /etc/wsl.conf
  grep -q '^appendWindowsPath=false$' /etc/wsl.conf
  grep -q '^hostname=dev-wsl$' /etc/wsl.conf
fi

if [[ -z "${TERM:-}" || "${TERM}" == "dumb" ]]; then
  export TERM=xterm-256color
fi
GIT_TERMINAL_PROMPT=0 zsh -ic 'set -e
zmodload zsh/parameter
(( ${+widgets[autosuggest-accept]} ))
(( ${+functions[fzf-tab-complete]} ))
(( ${+widgets[fzf-history-widget]} ))
[[ -n ${ZSH_HIGHLIGHT_VERSION:-} ]]
whence -w z >/dev/null
whence -w prompt_starship_precmd >/dev/null
'
