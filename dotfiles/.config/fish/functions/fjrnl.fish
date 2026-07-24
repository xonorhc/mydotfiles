function fjrnl --description 'Open jrnl entry selected with fzf'
    set -l title (jrnl --short | fzf --tac --no-sort)
    if test -n "$title"
        jrnl -on (echo $title | cut -c 1-16) $argv
    end
end
