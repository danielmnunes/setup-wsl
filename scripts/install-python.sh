#!/usr/bin/env bash
# Instala o CPython com uv e deixa python/python3 em ~/.local/bin.
set -euo pipefail

version="${PYTHON_VERSION:-3.14}"
uv_dir="${XDG_CONFIG_HOME:-$HOME/.config}/uv"
uv_config="${uv_dir}/uv.toml"
template="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/uv/uv.toml"

mkdir -p "$uv_dir"
if [[ ! -f "$uv_config" ]]; then
  cp "$template" "$uv_config"
fi

uv python install "$version" --default --preview-features python-install-default
uv python pin --global "$version"

default_python="${HOME}/.local/bin/python"
if [[ ! -x "$default_python" ]]; then
  echo "uv não criou ${default_python}." >&2
  exit 1
fi

echo "Python ${version} via uv: $("$default_python" --version)"
