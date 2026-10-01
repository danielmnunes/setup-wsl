# Copiado para ~/.zshrc. Node, Bun e Python vêm do mise e do uv.
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# ── Zinit ──────────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "$ZINIT_HOME/zinit.zsh"

zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# ── History ────────────────────────────────────────────────────────────
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt HIST_VERIFY

# ── Completion ─────────────────────────────────────────────────────────
# No WSL o compinit para numa pergunta sobre diretórios inseguros.
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit -u

# Depois do compinit, como o fzf-tab pede.
zinit light Aloxaf/fzf-tab

# ── Aliases ────────────────────────────────────────────────────────────
alias ls='eza --group-directories-first'
alias ll='eza -l --group-directories-first'
alias la='eza -la --group-directories-first'
alias cat='bat --paging=never'
alias dc='docker compose'
alias ..='cd ..'
alias ...='cd ../..'
alias wsl-restart='wsl.exe --shutdown'

# ── mise, fzf, zoxide ──────────────────────────────────────────────────
eval "$(mise activate zsh)"
source <(fzf --zsh)
eval "$(zoxide init zsh)"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# ── Smart home: só sai de um caminho de sistema do Windows ─────────────
if [[ "$PWD" == /mnt/c/Windows* ]] || [[ "$PWD" == /mnt/c/Users/*/AppData* ]]; then
  cd ~
fi

# ── Starship ───────────────────────────────────────────────────────────
eval "$(starship init zsh)"
if [[ -t 1 ]]; then
  fastfetch
fi
