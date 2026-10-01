#!/usr/bin/env bash
# Grava o shell, o prompt e, dentro do WSL, o /etc/wsl.conf.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
user="${USER:-$(id -un)}"
zsh_bin="$(command -v zsh || true)"

if [[ -z "$zsh_bin" ]]; then
  echo "O zsh não está instalado." >&2
  exit 1
fi

if [[ ! -f "$zinit_home/zinit.zsh" ]]; then
  mkdir -p "$(dirname "$zinit_home")"
  git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$zinit_home"
fi

mkdir -p "$HOME/.zsh/completions" "$config_home" "$HOME/dev"
cp "$repo/zsh/.zshrc" "$HOME/.zshrc"
cp "$repo/zsh/.zprofile" "$HOME/.zprofile"
cp "$repo/starship/starship.toml" "$config_home/starship.toml"

login_shell="$(getent passwd "$user" | cut -d: -f7)"
if [[ "$login_shell" != "$zsh_bin" ]]; then
  if ! sudo -n chsh -s "$zsh_bin" "$user"; then
    echo "Não consegui trocar o shell para zsh. Rode: sudo chsh -s ${zsh_bin} ${user}" >&2
    exit 1
  fi
fi

if [[ -n "${WSL_DISTRO_NAME:-}" ]] || { [[ -d /mnt/c/Windows ]] && [[ -e /proc/sys/fs/binfmt_misc/WSLInterop ]]; }; then
  sudo cp "$repo/wsl/wsl.conf" /etc/wsl.conf
  echo "wsl.conf aplicado. No PowerShell, rode wsl.exe --shutdown para valer."
fi

# O primeiro zsh baixa os plugins do zinit. Sem TTY o git não pode pedir senha.
# exit 0: no primeiro arranque o zinit deixa status 1, e um exit sem
# argumento repete esse status.
export GIT_TERMINAL_PROMPT=0
if [[ -z "${TERM:-}" || "${TERM}" == "dumb" ]]; then
  export TERM=xterm-256color
fi
zsh -ic 'exit 0'
