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
alias deletemebranches="git branch --merged >/tmp/merged-branches && \
  nvim /tmp/merged-branches && xargs git branch -d </tmp/merged-branches"

alias mkdir="mkdir -pv"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias tmux="tmux -2"
alias tg="terragrunt"
alias tf="opentofu"


alias yesyaml='for f in *; do [[ "$f" != *.* ]] && mv -- "$f" "$f.yaml"; done'
alias noyaml='for f in *.yaml; do mv -- "$f" "${f%.yaml}"; done'

alias k="kubectl"
alias deletenotready='kubectl delete pods --all-namespaces --field-selector spec.nodeName=$(kubectl get nodes | grep NotReady | awk '\''{print $1}'\'') --force --grace-period=0'


# distant.nvim
dist() {
    ssh "$@" 'curl -L https://sh.distant.dev | sh -s -- --on-conflict overwrite'
}

