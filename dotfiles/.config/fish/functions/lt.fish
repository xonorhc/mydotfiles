function lt --description 'List files as tree'
    if command -sq eza
        command eza -a --tree --level=1 $argv
    else
        command ls -al $argv
    end
end
