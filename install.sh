#!/usr/bin/env bash
# Instala o mise e aplica esta configuração como config global.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/mise"

if [[ ! -r /etc/os-release ]]; then
  echo "Não encontrei /etc/os-release." >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "26.04" ]]; then
  echo "Este setup é para Ubuntu 26.04. Encontrado: ${PRETTY_NAME:-desconhecido}." >&2
  exit 1
fi

if ! sudo -v; then
  echo "É preciso sudo para instalar pacotes e o Git do PPA." >&2
  exit 1
fi

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl

if [[ ! -x "${HOME}/.local/bin/mise" ]] && ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.run | MISE_INSTALL_SKIP_IF_EXISTS=1 sh
fi

if [[ -x "${HOME}/.local/bin/mise" ]]; then
  sudo mkdir -p /usr/local/bin
  sudo ln -sfn "${HOME}/.local/bin/mise" /usr/local/bin/mise
fi

export PATH="${HOME}/.local/bin:/usr/local/bin:${PATH}"
hash -r

if ! command -v mise >/dev/null 2>&1; then
  echo "O mise não ficou disponível no PATH." >&2
  exit 1
fi

mkdir -p "$(dirname "$config_dir")"

current="$(readlink -f "$config_dir" 2>/dev/null || true)"
if [[ -e "$config_dir" && "$current" != "$repo" ]]; then
  echo "Já existe ${config_dir} e ele não aponta para este repositório." >&2
  echo "Mova essa configuração antes de rodar o install de novo." >&2
  exit 1
fi

ln -sfn "$repo" "$config_dir"
export MISE_YES=1
mise trust "$config_dir/config.toml"
mise bootstrap --yes --update
cp "$repo/zsh/.zshrc" "$HOME/.zshrc"
cp "$repo/zsh/.zprofile" "$HOME/.zprofile"

echo
echo "Setup aplicado. Abra um terminal novo e rode: mise run check"
