function gcs --description "Git clone shallowlly (with --depth=1 --shallow-submodules --recurse-submodules)"
    git clone --depth=1 --shallow-submodules --recurse-submodules $argv
end
