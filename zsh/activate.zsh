eval "$(mise activate zsh)"

export ZSH="$HOME/.local/share/zsh/ohmyzsh"
export ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
mkdir -p "$ZSH_CACHE_DIR"
zstyle ':omz:update' mode disabled

fpath=("$HOME/.local/share/zsh/zsh-completions/src" $fpath)
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

source "$HOME/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOME/.local/share/zsh/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

source <(fzf --zsh)
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
source "$HOME/.local/share/zsh/fzf-tab/fzf-tab.plugin.zsh"

eval "$(zoxide init zsh)"

alias cat='bat --paging=never'
alias ls='eza --group-directories-first'
alias ll='eza -l --group-directories-first'
alias la='eza -la --group-directories-first'

source "$HOME/.local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
