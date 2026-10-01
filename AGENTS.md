# Setup WSL 2 — Ubuntu 26.04 no Windows 11, com mise

O `install.sh` instala o mise, aponta `~/.config/mise` para este clone e roda `mise bootstrap`. Versões ficam em `config.toml`. Documentação em português.

## O que entra

- Git pelo apt, PPA git-core (`scripts/apt-git-ppa.sh`). No amd64 a fonte fica presa em `amd64`, porque o índice `amd64v3` desse PPA vem vazio.
- Java Temurin 25, Go 1.27, Node 24, Bun 1.4 e uv (latest) pelo mise. O setup não instala Python; o uv baixa um quando um projeto pedir.
- Shell: zsh, Zinit e Starship. `zsh/.zshrc`, `zsh/.zprofile` e `starship/starship.toml` são a fonte. O hook `post-tools` chama `scripts/shell-setup.sh`, que copia esses arquivos e, só dentro do WSL, grava `wsl/wsl.conf` em `/etc/wsl.conf`.
- `wsl/.wslconfig` é modelo para `%UserProfile%\.wslconfig` no Windows. O install não grava esse arquivo.

## O que fica de fora

Não instale Neovim, tmux, AWS CLI, dnsutils nem net-tools. Não use pyenv, nvm nem Oh My Zsh. Não grave `user.name`, `user.email` nem chave SSH.

## Conferir

Num container `ubuntu:26.04`, com sudo sem senha:

```bash
~/setup-wsl/install.sh
mise run check
```

`mise bootstrap --yes --update` reaplica pacotes, ferramentas, zsh, Starship e, no WSL, o `wsl.conf`.
