# -----------------------------------------------------
# Zellij autostart
# -----------------------------------------------------
# Disable with:
# set -Ux DISABLE_ZELLIJ 1

if not set -q ZELLIJ
    and not set -q DISABLE_ZELLIJ
    and isatty stdout
    and command -sq zellij
    exec zellij
end
