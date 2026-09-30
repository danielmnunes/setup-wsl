#!/usr/bin/env bash
# Publica o PPA git-core e instala o Git estável mais recente.
# No Ubuntu 26.04 amd64 o índice amd64v3 desse PPA vem vazio; o apt
# então ignora o Git do PPA. A fonte fica presa em amd64.
set -euo pipefail

# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "26.04" ]]; then
  echo "O PPA do Git deste setup é para Ubuntu 26.04. Encontrado: ${PRETTY_NAME:-desconhecido}." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg software-properties-common

if ! grep -Rqs "git-core/ppa" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
  sudo add-apt-repository -y ppa:git-core/ppa
fi

arch="$(dpkg --print-architecture)"
if [[ "$arch" == "amd64" ]]; then
  shopt -s nullglob
  for sources in /etc/apt/sources.list.d/*git-core*; do
    case "$sources" in
      *.sources)
        # O campo tem que ficar na mesma stanza de Types. Uma linha no
        # fim do arquivo, depois do Signed-By, vira outra stanza e o apt
        # recusa o arquivo (falta Types).
        sudo sed -i \
          -e '/^Architectures:/d' \
          -e '/^Types: /a Architectures: amd64' \
          "$sources"
        ;;
      *.list)
        if grep -q '^deb https://ppa.launchpadcontent.net/git-core/ppa/ubuntu' "$sources" \
          && ! grep -q 'arch=amd64' "$sources"; then
          sudo sed -i 's|^deb https://ppa.launchpadcontent.net/git-core/ppa/ubuntu|deb [arch=amd64] https://ppa.launchpadcontent.net/git-core/ppa/ubuntu|' "$sources"
        fi
        ;;
    esac
  done
  shopt -u nullglob
fi

sudo apt-get update
sudo apt-get install -y git

installed="$(dpkg-query -W -f='${Version}' git)"
case "$installed" in
  *ppa*) ;;
  *)
    echo "O git instalado (${installed}) não veio do PPA git-core." >&2
    apt-cache policy git >&2 || true
    exit 1
    ;;
esac

echo "git ${installed}"
