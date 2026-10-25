fzf_theme_opts="\
--color=bg+:#44475a
--color=bg:#282a36
--color=spinner:#f8f8f2
--color=hl:#ff5555
--color=fg:#f8f8f2
--color=header:#ff5555
--color=info:#bd93f9
--color=pointer:#f8f8f2
--color=marker:#d6d8e0
--color=fg+:#f8f8f2
--color=prompt:#bd93f9
--color=hl+:#ff5555
--color=selected-bg:#21222c
--color=border:#44475a
--color=label:#f8f8f2"

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS
}$fzf_theme_opts"
