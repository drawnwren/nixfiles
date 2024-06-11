setopt shwordsplit  

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="cypher"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.  DISABLE_AUTO_UPDATE="true" Uncomment the following line to change how often to auto-update (in days).  export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

#python

pyclean () {
    find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
}
#[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh


export DOPPLER_ENV_LOGGING=1
#pyenv and poetry (poetry sources from .local/bin)
#export PYENV_ROOT="$HOME/.pyenv"
#command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$(pyenv root)/shims:$HOME/.local/bin:$PATH"
#eval "$(pyenv init -)"


# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="$HOME/.ssh/"
export EDITOR=nvim


# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

unalias gc
function gc
{
   git add --all
   git commit -m "$1"
   git push
}

function gcx
{
   git add --all
   git commit -m "x"
   git push
}

alias glumr="git pull upstream master --rebase"
alias vim="nvim"
alias v="nvim"
alias cat="bat"
alias yeet="paru -Rcs"
alias deletemebranches="git branch --merged >/tmp/merged-branches && \
  nvim /tmp/merged-branches && xargs git branch -d </tmp/merged-branches"

alias vimrc="vim ~/.vimrc"
alias zshrc="vim ~/.zshrc"
alias bspwmrc="vim ~/.config/bspwm/bspwmrc"
alias sxhkdrc="vim ~/.config/sxhkd/sxhkdrc"

alias mkdir="mkdir -pv"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias nvidia="optimus-manager --switch nvidia --no-confirm"
alias hybrid="optimus-manager --switch hybrid --no-confirm"
alias integrated="optimus-manager --switch integrated --no-confirm"
alias gm="rustup update && foundryup --version nightly && pyenv update"
alias tmux="tmux -2"
alias tg="terragrunt"

alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'

alias ma='mamba deactivate && mamba activate'
alias maa='mamba deactivate && mamba activate base'

alias yesyaml='for f in *; do [[ "$f" != *.* ]] && mv -- "$f" "$f.yaml"; done'
alias noyaml='for f in *.yaml; do mv -- "$f" "${f%.yaml}"; done'

alias k="kubectl"
alias p="poetry"


# distant.nvim
dist() {
    ssh "$@" 'curl -L https://sh.distant.dev | sh -s -- --on-conflict overwrite'
}

autoload -Uz compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc
