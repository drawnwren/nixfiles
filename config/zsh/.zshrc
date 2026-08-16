setopt shwordsplit  
bindkey -v

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

#python
pyclean () {
    find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
}


export DOPPLER_ENV_LOGGING=1


# Compilation flags

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

alias vim="nvim"
alias v="nvim"
alias cat="bat"

alias mkdir="mkdir -pv"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias tmux="tmux -2"
alias tg="terragrunt"
alias tf="opentofu"



alias k="kubectl"

# distant.nvim
dist() {
    ssh "$@" 'curl -L https://sh.distant.dev | sh -s -- --on-conflict overwrite'
}

# nix develop, but drop into zsh instead of bash
nd() {
    nix develop "$@" --command zsh
}
