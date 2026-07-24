function ll --description 'List files in long format'
    if command -sq eza
        command eza -al $argv
    else
        command ls -al $argv
    end
end
