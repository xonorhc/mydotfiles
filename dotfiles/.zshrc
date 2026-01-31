#   _____ _____ _____ _____ _____
#  |__   |   __|  |  | __  |     |
#  |   __|__   |     |    -|   --|
#  |_____|_____|__|__|__|__|_____|
#
#  by Bina

# -- $PATH variable --
export PATH=$HOME/bin:/usr/bin:/usr/local/bin:$PATH

# -- oh-my-zsh --
# https://github.com/ohmyzsh
export ZSH=$HOME/.oh-my-zsh
# decide on a theme (or create your own)
ZSH_THEME="robbyrussell"
plugins=(
	git
	zsh-autosuggestions
	zsh-autocomplete
	zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# -- general settings --
CASE_SENSITIVE="true"
ENABLE_CORRECTION="true"

# -- xcursor --
export XCURSOR_PATH=${XCURSOR_PATH}:~/.local/share/icons

# -- aliases --
alias c="clear"
alias vd="vim diff"
alias gcl="git clone"
alias gs="git status"
alias gi="git init"
alias ga="git add"
alias gm="git commit -m"
alias gp="git push"
alias gb="git branch"
alias gc="git checkout"
alias gcb="git checkout -B"
alias gcm="git checkout master"
alias gpu="git pull"
alias gpo="git pull origin"
alias gl="git log"
alias gd="git diff"
alias gra="git remote add"
alias grr="git remote rm"
alias gsh="git stash"
alias ff='fastfetch'
alias shutdown='systemctl poweroff'
alias v='$EDITOR'
alias vim='$EDITOR'
alias wifi='nmtui'
alias clock='tty-clock'

# -- enviroments variables --
export EDITOR=nvim
