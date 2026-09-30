# Setup WSL 2 — Ubuntu 26.04

Configuração de máquina com [mise](https://mise.jdx.dev/). O `install.sh` instala o mise, aponta `~/.config/mise` para este repositório e roda `mise bootstrap`.

| Ferramenta | Origem | Versão |
| --- | --- | --- |
| Git | PPA [git-core](https://launchpad.net/~git-core/+archive/ubuntu/ppa) | estável atual do Ubuntu 26.04 (2.55 no momento) |
| Java | mise, Eclipse Temurin | 25 (LTS atual) |
| Go | mise | 1.26 |
| Node.js | mise | 24 (LTS) |
| Bun | mise | 1.4 |
| Python | [uv](https://docs.astral.sh/uv/concepts/python-versions/) | 3.14, com `python` em `~/.local/bin` |
| uv | mise | latest |
| GitLab CLI (glab), ripgrep, fd, jq, bat, eza, delta, fzf, zoxide | mise | latest |
| curl, unzip, build-essential, pkg-config | apt | latest |

O Git entra pelo apt, não pelo mise, para o `/usr/bin/git` já ser o atual mesmo fora de um shell com o mise ativo. No Ubuntu 26.04 amd64 o índice `amd64v3` desse PPA vem vazio; o script prende a fonte em `amd64`, senão o apt fica no Git do arquivo oficial.

## Uso

No Ubuntu 26.04, com sudo:

```bash
git clone <url-deste-repo> ~/setup-wsl
~/setup-wsl/install.sh
```

O script recusa continuar se `~/.config/mise` já existir e não for este repositório. Ele copia `zsh/.zshrc` para `~/.zshrc` e `zsh/.zprofile` para `~/.zprofile`. O bootstrap grava a ativação do mise em `~/.bashrc`. Abra um terminal novo.

```bash
mise run check
```

Para aplicar de novo depois de um `git pull`:

```bash
mise bootstrap --yes --update
```

`mise bootstrap packages upgrade` sobe os pacotes apt declarados. `mise upgrade` sobe as ferramentas do mise dentro do pedido de versão. `uv python upgrade 3.14` sobe o patch do Python.

## Versões

Os pedidos ficam em `config.toml`. `PYTHON_VERSION` é o que o uv instala e fixa com `uv python pin --global`. O arquivo `uv/uv.toml` só é copiado para `~/.config/uv/uv.toml` se esse arquivo ainda não existir; ele manda o uv preferir o Python que ele instalou.

Um projeto pode pedir outro Go, Java, Node ou Bun com `mise.toml` ou com `.go-version` / `go.mod`, `.java-version`, `.nvmrc` / `.node-version` e `.bun-version`. O Python do projeto continua com o uv (`.python-version` e `uv sync`).

## WSL

Limites de RAM, CPU, rede e disco da VM ficam no Windows. O passo a passo está em [docs/wsl-performance.md](docs/wsl-performance.md).

O zsh e o Oh My Zsh já estão instalados, e o zsh é o shell da conta. O `zsh/.zshrc` ativa o mise, liga o fzf, define `z` via zoxide, troca `ls` por `eza` e `cat` por `bat`, e coloca `~/.local/bin` no `PATH`. O `zsh/.zprofile` lê o `~/.profile` no login, que também coloca `~/.local/bin` no `PATH`, onde o `uv python install --default` deixa o `python`. O `install.sh` copia os dois para a home.

O `delta` vira o pager do Git num bloco de `~/.gitconfig`.

Se `git --version` mostrar o Git do Windows, o `PATH` do Windows está na frente de `/usr/bin`. O Git deste setup é o pacote Linux em `/usr/bin/git`.
