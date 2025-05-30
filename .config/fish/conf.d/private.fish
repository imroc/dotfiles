set -l private_path ~/.config/private

if not test -d $private_path; and not test -L $private_path
    return
end

set fish_complete_path $fish_complete_path[1] $private_path/completions $fish_complete_path[2..]
set fish_function_path $fish_function_path[1] $private_path/functions $fish_function_path[2..]

for file in $private_path/conf.d/*.fish
    source $file 2>/dev/null
end
