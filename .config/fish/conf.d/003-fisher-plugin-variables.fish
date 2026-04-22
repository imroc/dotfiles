set -U _fisher_plugins jorgebucaran/autopair.fish patrickf1/fzf.fish jorgebucaran/fisher jhillyerd/plugin-git

if not set -q _fisher_jorgebucaran_2F_autopair_2E_fish_files
    set -U _fisher_jorgebucaran_2F_autopair_2E_fish_files "~/.config/fish/plugins/functions/_autopair_backspace.fish" "~/.config/fish/plugins/functions/_autopair_insert_left.fish" "~/.config/fish/plugins/functions/_autopair_insert_right.fish" "~/.config/fish/plugins/functions/_autopair_insert_same.fish" "~/.config/fish/plugins/functions/_autopair_tab.fish" "~/.config/fish/plugins/conf.d/autopair.fish"
end

if not set -q _fisher_patrickf1_2F_fzf_2E_fish_files
    set -U _fisher_patrickf1_2F_fzf_2E_fish_files "~/.config/fish/plugins/functions/_fzf_configure_bindings_help.fish" "~/.config/fish/plugins/functions/_fzf_extract_var_info.fish" "~/.config/fish/plugins/functions/_fzf_preview_changed_file.fish" "~/.config/fish/plugins/functions/_fzf_preview_file.fish" "~/.config/fish/plugins/functions/_fzf_report_diff_type.fish" "~/.config/fish/plugins/functions/_fzf_report_file_type.fish" "~/.config/fish/plugins/functions/_fzf_search_directory.fish" "~/.config/fish/plugins/functions/_fzf_search_git_log.fish" "~/.config/fish/plugins/functions/_fzf_search_git_status.fish" "~/.config/fish/plugins/functions/_fzf_search_history.fish" "~/.config/fish/plugins/functions/_fzf_search_processes.fish" "~/.config/fish/plugins/functions/_fzf_search_variables.fish" "~/.config/fish/plugins/functions/_fzf_wrapper.fish" "~/.config/fish/plugins/functions/fzf_configure_bindings.fish" "~/.config/fish/plugins/conf.d/fzf.fish" "~/.config/fish/plugins/completions/fzf_configure_bindings.fish"
end

if not set -q _fisher_jorgebucaran_2F_fisher_files
    set -U _fisher_jorgebucaran_2F_fisher_files "~/.config/fish/plugins/functions/fisher.fish" "~/.config/fish/plugins/completions/fisher.fish"
end

if not set -q _fisher_jhillyerd_2F_plugin_2D_git_files
    set -U _fisher_jhillyerd_2F_plugin_2D_git_files "~/.config/fish/plugins/functions/__git.branch_has_wip.fish" "~/.config/fish/plugins/functions/__git.current_branch.fish" "~/.config/fish/plugins/functions/__git.default_branch.fish" "~/.config/fish/plugins/functions/__git.destroy.fish" "~/.config/fish/plugins/functions/__git.init.fish" "~/.config/fish/plugins/functions/gbage.fish" "~/.config/fish/plugins/functions/gbda.fish" "~/.config/fish/plugins/functions/gdv.fish" "~/.config/fish/plugins/functions/gignored.fish" "~/.config/fish/plugins/functions/glp.fish" "~/.config/fish/plugins/functions/grename.fish" "~/.config/fish/plugins/functions/grt.fish" "~/.config/fish/plugins/functions/gtest.fish" "~/.config/fish/plugins/functions/gtl.fish" "~/.config/fish/plugins/functions/gunwip.fish" "~/.config/fish/plugins/functions/gwip.fish" "~/.config/fish/plugins/conf.d/git.fish"
end
