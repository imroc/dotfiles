set -gx EDITOR nvim

abbr --add ys "kubectl neat > $HOME/tmp/kube.yaml; and nvim $HOME/tmp/kube.yaml"
abbr --add yy "cat > $HOME/tmp/kube.yaml; and nvim $HOME/tmp/kube.yaml"
abbr --add y 'nvim -c "set filetype=yaml"'
