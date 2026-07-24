function venv --description 'Activate or create local Python virtual environment'
    if test -d .venv
        source .venv/bin/activate.fish
    else
        python3 -m venv .venv
        source .venv/bin/activate.fish
    end
end
