function ls --description 'List files'
    if command -sq eza
        command eza -a $argv
    else
        command ls $argv
    end
end
