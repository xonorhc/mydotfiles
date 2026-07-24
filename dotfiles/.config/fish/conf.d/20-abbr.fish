# -----------------------------------------------------
# Abbreviations - General
# -----------------------------------------------------
abbr -a .. 'cd ..'
abbr -a c clear
abbr -a ff fastfetch
abbr -a v $EDITOR
abbr -a vim $EDITOR
abbr -a clock peaclock
abbr -a zj zellij

# -----------------------------------------------------
# Aliases - General
# -----------------------------------------------------
alias shutdown='systemctl poweroff'
alias wifi='nmtui'

# Safer interactive defaults
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# -----------------------------------------------------
# Abbreviations - Git
# -----------------------------------------------------
abbr -a gs 'git status'
abbr -a ga 'git add'
abbr -a gp 'git push'
abbr -a gpl 'git pull'
abbr -a gst 'git stash'
abbr -a gfo 'git fetch origin'
abbr -a gcheck 'git checkout'
abbr -a gco 'git checkout'
abbr -a gsw 'git switch'
abbr -a gc 'git commit -m'
abbr -a gl 'git log --oneline --graph --decorate'

# -----------------------------------------------------
# Abbreviations - Docker
# -----------------------------------------------------
abbr -a dc 'docker compose'
abbr -a dps 'docker ps'
abbr -a dex 'docker exec -it'

# -----------------------------------------------------
# Aliases - Docker
# -----------------------------------------------------
alias dcom='docker compose'
alias dclean='docker system prune --volumes'

# -----------------------------------------------------
# Aliases - GDAL
# -----------------------------------------------------
abbr -a ginfo 'gdalinfo -stats'
abbr -a oinfo 'ogrinfo -so -al'
