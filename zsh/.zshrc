# zsh e Oh My Zsh já estão instalados. Este arquivo é copiado para ~/.zshrc.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
# No WSL o compinit para numa pergunta sobre diretórios inseguros.
ZSH_DISABLE_COMPFIX=true
plugins=(git)

if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

source "$ZSH/oh-my-zsh.sh"

# mise antes de fzf, zoxide, eza e bat: eles ficam no toolchain dele.
eval "$(mise activate zsh)"
source <(fzf --zsh)
eval "$(zoxide init zsh)"

alias cat='bat --paging=never'
alias ls='eza --group-directories-first'
alias ll='eza -l --group-directories-first'
alias la='eza -la --group-directories-first'
