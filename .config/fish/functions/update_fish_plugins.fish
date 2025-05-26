function update_fish_plugins --description "Update fish plugins"
    function generate_variable_code
        set -l var_name $argv[1]
        set -l values
        for value in $$var_name
            set -a values "\"$value\""
        end
        echo "
if not set -q $var_name
    set -U $var_name $values
end"
    end
    function generate_fish_plugins
        # 获取当前所有已安装的 fish 插件列表
        set plugins (cat ~/.config/fish/fish_plugins)

        # 生成 fish 代码
        echo "set -U _fisher_plugins $(echo -n $plugins | tr '\n' ' ')"

        for plugin in $plugins
            set plugin_files_var _fisher_(string escape --style=var -- $plugin)_files
            generate_variable_code $plugin_files_var
        end
    end

    generate_fish_plugins >~/.config/fish/conf.d/003-fisher-plugin-variables.fish
end
