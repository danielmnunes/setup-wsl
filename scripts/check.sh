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
uv python find "$version"

if [[ ! -x "$default_python" ]]; then
  echo "Não encontrei ${default_python}. Rode mise run bootstrap de novo." >&2
  exit 1
fi

"$default_python" --version
