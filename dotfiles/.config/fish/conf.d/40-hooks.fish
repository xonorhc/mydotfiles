# -----------------------------------------------------
# Hooks
# -----------------------------------------------------
set -l cache_dir "$HOME/.cache/fish"
test -d "$cache_dir"; or mkdir -p "$cache_dir"

# direnv
if command -sq direnv
    set -l direnv_bin (command -s direnv)
    set -l direnv_cache "$cache_dir/direnv.hook.fish"

    if not test -s "$direnv_cache"; or test "$direnv_bin" -nt "$direnv_cache"
        "$direnv_bin" hook fish > "$direnv_cache"
    end

    source "$direnv_cache"
end

# zoxide
if command -sq zoxide
    set -l zoxide_bin (command -s zoxide)
    set -l zoxide_cache "$cache_dir/zoxide.init.fish"

    if not test -s "$zoxide_cache"; or test "$zoxide_bin" -nt "$zoxide_cache"
        "$zoxide_bin" init fish > "$zoxide_cache"
    end

    source "$zoxide_cache"
end
