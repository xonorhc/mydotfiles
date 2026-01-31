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

# -- yazi --
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd <"$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

if [[ -n "$YAZI_ID" ]]; then
	function _yazi_cd() {
		ya emit cd "$PWD"
	}
	add-zsh-hook zshexit _yazi_cd
fi

# -- fastfetch --
if [[ $(tty) == *"pts"* ]]; then
	fastfetch
else
	echo
	if [ -f /bin/hyprctl ]; then
		echo "Start Hyprland with command Hyprland"
	fi
fi

# -- postgres --
export PGHOST='localhost'
export PGPORT='5432'
export PGDATABASE='postgres'
export PGUSER='postgres'
export DATABASE_URL="postgres://$PGUSER:@$PGHOST:$PGPORT/$PGDATABASE"
export PSQL_PAGER="pspg"
