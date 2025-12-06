function fish_user_key_bindings
    # Alt+I/O 后退/前进一个 bigword
    bind $argv alt-i backward-bigword
    bind $argv alt-o forward-bigword
    # 绑定 tab 为自动补全
    bind tab complete-and-search
end
