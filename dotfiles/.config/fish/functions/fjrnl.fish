function fjrnl --description 'Open jrnl entry selected with fzf'
    set -l line (jrnl --short | fzf --ansi --tac --no-sort)

    if test -n "$line"
        set -l date (echo $line | awk '{print $1, $2, $3}')
        jrnl -on "$date" $argv
    end
end
