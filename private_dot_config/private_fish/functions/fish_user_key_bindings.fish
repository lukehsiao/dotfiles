function fish_user_key_bindings
    fzf --fish | source

    # Let Atuin control Ctrl+R
    set -gx ATUIN_NOBIND "true"
    atuin init fish | source
    # bind to ctrl-r in normal and insert mode, add any other bindings you want here too
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search
end
