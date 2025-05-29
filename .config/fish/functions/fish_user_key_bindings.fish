function fish_user_key_bindings
    # Alt+I/O 后退/前进一个 bigword
    bind --user $argv alt-i backward-bigword
    bind --user $argv alt-o forward-bigword
    # 绑定 Alt+Space 为自动补全
    bind --user \e\  complete-and-search
end
