# Performance do WSL 2

Passos para deixar o Ubuntu no WSL 2 rápido em 2026. O `install.sh` deste repositório configura as ferramentas dentro da distro. Os limites da máquina virtual ficam no Windows, em `%UserProfile%\.wslconfig`.

Fontes: [configuração avançada do WSL](https://learn.microsoft.com/en-us/windows/wsl/wsl-config), [ambiente de desenvolvimento](https://learn.microsoft.com/en-us/windows/wsl/setup/environment), [WSL em empresa](https://learn.microsoft.com/en-us/windows/wsl/enterprise) e [boas práticas de WSL da Docker](https://docs.docker.com/desktop/features/wsl/best-practices/).

## Antes de editar

No PowerShell:

```powershell
wsl --version
wsl --update
wsl -l -v
```

Use uma distro em WSL 2, no Windows 11 22H2 ou mais novo, com o WSL da Microsoft Store. Anote o nome da distro (`Ubuntu`, `Ubuntu-26.04`, etc.). Ele entra no comando de disco esparso mais abaixo.

Uma alteração em `.wslconfig` ou em `/etc/wsl.conf` só passa a valer depois que a VM para. Feche os terminais da distro e rode:

```powershell
wsl --shutdown
```

## 1. Deixe o código no sistema de arquivos Linux

Este é o passo que mais muda git, npm, cargo, go e builds em geral.

Clone e compile em casa, por exemplo `~/dev`. O disco da distro é ext4, dentro de um VHD. A Microsoft e a Docker recomendam esse caminho quando as ferramentas rodam no Linux.

`/mnt/c` é o disco do Windows visto de dentro da distro. Cada `git status` ou instalação de dependências atravessa essa fronteira. `node_modules`, `.git`, `target`, `__pycache__`, `.venv`, `build` e `dist` ficam em `~/dev`.

Confira onde você está:

```bash
pwd
df -T ~
```

`df` deve mostrar `ext4` em `/`. Um caminho que começa com `/mnt/` está no disco do Windows.

Se um projeto já está em `/mnt/c`, copie para a distro e passe a trabalhar na cópia:

```bash
mkdir -p ~/dev
cp -a /mnt/c/Users/voce/projetos/meu-repo ~/dev/
```

O acesso a arquivos do Windows ficou mais rápido com o virtiofs, ainda experimental e desligado por padrão (`virtiofs=false` em `[wsl2]`). Ele ajuda quem precisa ler o disco do Windows. O caminho rápido para o dia a dia continua sendo o ext4.

## 2. Limite memória, CPU e swap

O arquivo global é `%UserProfile%\.wslconfig` (`C:\Users\<voce>\.wslconfig`). Ele vale para todas as distros WSL 2. Crie se não existir.

O padrão da Microsoft é 50% da RAM do Windows, todos os processadores lógicos e swap de 25% da RAM, arredondado para cima. Um teto explícito deixa RAM e núcleos para o browser e para o editor no Windows.

| RAM do Windows | `memory` | `swap` | `processors` |
| --- | --- | --- | --- |
| 16 GB | `8GB` | `4GB` | lógicos − 2 |
| 32 GB | `16GB` | `8GB` | lógicos − 2 |
| 64 GB | `24GB` a `32GB` | `8GB` | lógicos − 2 |

Conte os processadores lógicos no Gerenciador de Tarefas. Se o servidor do editor roda dentro do WSL, pode entregar mais núcleos à VM. Swap grande empurra falta de RAM para o disco virtual.

O arquivo de exemplo deste repositório é [`wsl/.wslconfig`](../wsl/.wslconfig). Ele começa com 8 GB, 4 processadores e 4 GB de swap. Numa máquina maior, troque esses três valores pela linha da tabela antes de copiar para `%UserProfile%\.wslconfig`.

```ini
[wsl2]
memory=8GB
processors=4
swap=4GB

# Windows 11 22H2 ou mais novo.
# localhost nos dois sentidos, IPv6 e VPN.
networkingMode=mirrored
dnsTunneling=true
firewall=true

[experimental]
# O padrão atual da Microsoft é dropCache, que devolve a RAM na hora.
# gradual devolve aos poucos e preserva o cache de página do Linux
# entre um comando e outro (git status, rebuild).
autoMemoryReclaim=gradual

# VHD esparso para distros criadas depois desta mudança.
sparseVhd=true
```

`dnsTunneling=true` já é o padrão. A Microsoft recomenda `networkingMode=mirrored` quando há VPN ou firewall mais rígido. O modo padrão continua sendo NAT.

`sparseVhd=true` marca VHDs novos. Ele devolve espaço em disco ao Windows. Numa distro que já existe, no PowerShell, com o nome visto em `wsl -l -v`:

```powershell
wsl --manage Ubuntu-26.04 --set-sparse true
```

A interface WSL Settings, no menu Iniciar, grava o mesmo arquivo. Os dois caminhos funcionam. Depois de salvar, rode `wsl --shutdown` e abra a distro de novo.

## 3. wsl.conf da distro

No WSL, o `install.sh` copia [`wsl/wsl.conf`](../wsl/wsl.conf) para `/etc/wsl.conf`.

```ini
[boot]
systemd=true

[automount]
enabled=true
root=/mnt/
options="metadata,umask=22,fmask=11"
mountFsTab=true

[network]
generateHosts=true
generateResolvConf=true
hostname=dev-wsl

[interop]
enabled=true
appendWindowsPath=false
```

`appendWindowsPath=false` sobe o shell sem dezenas de diretórios do Windows no `PATH`. `git` e `node` resolvem para os binários Linux. O Git deste setup é `/usr/bin/git`. `explorer.exe` e outros programas do Windows continuam chamáveis pelo caminho completo. `enabled=true` mantém a interoperabilidade.

`systemd=true` liga o systemd, como numa instalação Ubuntu normal. Serviço e o Docker Desktop dependem disso. O boot fica um pouco mais longo.

`metadata` no automount grava permissão Linux nos arquivos de `/mnt`. É configuração de permissão. O caminho rápido para o código continua sendo o ext4, em `~/dev`.

`hostname=dev-wsl` fixa o nome da distro. `generateHosts` e `generateResolvConf` deixam o WSL gerar `/etc/hosts` e `/etc/resolv.conf`.

Aplique com `wsl --shutdown` no PowerShell e abra um terminal novo. Confira:

```bash
git --version
command -v git
systemctl --version
hostname
```

A saída esperada é o Git do Linux, em `/usr/bin/git`, o systemd respondendo e o hostname `dev-wsl`.

## 4. Repositórios grandes

Com o repositório já no ext4, o monitor de arquivos do Git (desde o 2.37; este setup instala o 2.55) reduz o custo de `git status`. O bootstrap grava `core.fsmonitor=true` e `core.untrackedCache=true` em `~/.gitconfig`.

## 5. Confira

Depois do `wsl --shutdown` e de um terminal novo:

```bash
nproc
free -h
df -T ~
command -v git
```

`nproc` deve bater com `processors`. O total de `free -h` fica perto de `memory`. `df -T ~` mostra `ext4`. `command -v git` mostra `/usr/bin/git`.

Com DNS tunneling, o nameserver em `/etc/resolv.conf` aponta para `10.255.255.254`.

## O que deixar quieto

WSL 2 é o modo deste setup. WSL 1 só entra em cena quando as ferramentas Linux precisam ler o tempo todo um projeto que mora em `C:`.

`autoMemoryReclaim=disabled` segura a RAM no processo da VM e aperta o Windows. `dropCache`, o padrão, devolve na hora e esfria o cache de página. `gradual` é o meio-termo deste tutorial.

Excluir o `.vhdx` do antivírus aparece em guias como atalho de I/O. A Microsoft, no mesmo período, indica o plugin do Defender para WSL. Se um `git status` em `~/dev` continuar lento com o projeto no ext4, meça o antivírus antes de abrir uma exclusão de disco virtual.
