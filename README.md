# Setup WSL 2 — Ubuntu 26.04

Configuração de máquina com [mise](https://mise.jdx.dev/). O `install.sh` instala o mise, aponta `~/.config/mise` para este repositório e roda `mise bootstrap`.

| Ferramenta | Origem | Versão |
| --- | --- | --- |
| Git | PPA [git-core](https://launchpad.net/~git-core/+archive/ubuntu/ppa) | estável atual do Ubuntu 26.04 (2.55 no momento) |
| Java | mise, Eclipse Temurin | 25 (LTS atual) |
| Go | mise | 1.27 |
| Node.js | mise | 24 (LTS) |
| Bun | mise | 1.4 |
| uv | mise | latest |
| GitLab CLI (glab), ripgrep, fd, jq, bat, eza, delta, fzf, zoxide | mise | latest |
| Starship, fastfetch | mise | latest |
| curl, unzip, build-essential, pkg-config | apt | latest |
| zsh, wget, zip, htop, tree, lsb-release | apt | latest |

O Git entra pelo apt, não pelo mise, para o `/usr/bin/git` já ser o atual mesmo fora de um shell com o mise ativo. No Ubuntu 26.04 amd64 o índice `amd64v3` desse PPA vem vazio; o script prende a fonte em `amd64`, senão o apt fica no Git do arquivo oficial.

## Uso

No Ubuntu 26.04, com sudo:

```bash
git clone <url-deste-repo> ~/setup-wsl
~/setup-wsl/install.sh
```

O script recusa continuar se `~/.config/mise` já existir e não for este repositório. O bootstrap grava a ativação do mise em `~/.bashrc`, copia `zsh/.zshrc` e `zsh/.zprofile` para a home, copia `starship/starship.toml` para `~/.config/starship.toml` e troca o shell da conta para o zsh. Abra um terminal novo.

```bash
mise run check
```

Para aplicar de novo depois de um `git pull` (também recopia o zsh, o Starship e o `wsl.conf` dentro do WSL):

```bash
mise bootstrap --yes --update
```

`mise bootstrap packages upgrade` sobe os pacotes apt declarados. `mise upgrade` sobe as ferramentas do mise dentro do pedido de versão.
## Versões

Os pedidos ficam em `config.toml`. O setup não instala Python: só o `uv`, que baixa o interpretador quando um projeto pedir (`.python-version` e `uv sync`).

Um projeto pode pedir outro Go, Java, Node ou Bun com `mise.toml` ou com `.go-version` / `go.mod`, `.java-version`, `.nvmrc` / `.node-version` e `.bun-version`.

## WSL

Limites de RAM, CPU, rede e disco da VM ficam no Windows, em [`wsl/.wslconfig`](wsl/.wslconfig). O passo a passo está em [docs/wsl-performance.md](docs/wsl-performance.md).

Dentro do WSL, o bootstrap copia [`wsl/wsl.conf`](wsl/wsl.conf) para `/etc/wsl.conf`: systemd ligado, `appendWindowsPath=false` e hostname `dev-wsl`. Isso só passa a valer depois de `wsl.exe --shutdown` no PowerShell.

O zsh é o shell da conta. O `zsh/.zshrc` carrega o Zinit (autosuggestions, syntax highlighting, completions e fzf-tab), ativa o mise, liga o fzf e o zoxide, troca `ls` por `eza` e `cat` por `bat`, e abre o prompt do Starship. Node e Bun não usam nvm: ficam no mise. O `zsh/.zprofile` lê o `~/.profile` no login, que também coloca `~/.local/bin` no `PATH`. O código fica em `~/dev`, no ext4 da distro.

O Git ganha, em `~/.gitconfig`, o pager `delta`, `core.autocrlf=false`, branch padrão `main`, `pull.rebase` e os aliases `st` e `lg`. Nome e e-mail ficam de fora: rode `git config --global user.name` e `user.email` na máquina. A chave SSH também é local (`ssh-keygen -t ed25519`); o `clip.exe` cola a pública no GitHub.

O `docker` da distro é o cliente que o Docker Desktop injeta. Com o Docker Desktop aberto no Windows: Settings → Resources → WSL Integration → ligue a distro Ubuntu → Apply & Restart. O alias `dc` é `docker compose`.

No Windows Terminal, o perfil padrão é a distro Ubuntu. O Starship usa ícones da [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip). No VS Code do Windows, a extensão WSL abre a pasta atual com `code .`. Como o `appendWindowsPath=false` tira o `PATH` do Windows, o `zsh/.zshrc` acrescenta ao `PATH` só `/mnt/c/Users/danunes/AppData/Local/Programs/Microsoft VS Code/bin`. Se o usuário do Windows ou o local da instalação for outro, ajuste essa linha.

Se `git --version` mostrar o Git do Windows, o `PATH` do Windows está na frente de `/usr/bin`. O Git deste setup é o pacote Linux em `/usr/bin/git`.
