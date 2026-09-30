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
pkg-config --version
gcc --version
zsh --version

zsh_root="${HOME}/.local/share/zsh"
for repo in ohmyzsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search fzf-tab; do
  if [[ ! -d "${zsh_root}/${repo}/.git" ]]; then
    echo "Repositório ausente: ${zsh_root}/${repo}" >&2
    exit 1
  fi
done
uv python find "$version"

if [[ ! -x "$default_python" ]]; then
  echo "Não encontrei ${default_python}. Rode mise run bootstrap de novo." >&2
  exit 1
fi

"$default_python" --version
