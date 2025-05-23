# Minimal Rose Pine zshrc

# Enable starship prompt
eval "$(starship init zsh)"

# Enable completion and history
autoload -Uz compinit && compinit
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Syntax highlighting and autosuggestions (if installed)
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Set Rose Pine colors for LS_COLORS (optional, fallback to default if not present)
if [ -f ~/.config/zsh/rosepine-lscolors.zsh ]; then
  source ~/.config/zsh/rosepine-lscolors.zsh
fi

# Aliases
alias ls='eza --icons'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'

# Editor
export EDITOR="nvim"

# Prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
