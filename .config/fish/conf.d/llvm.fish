# fish_add_path -m /opt/homebrew/opt/llvm/bin

if test -d /opt/homebrew/opt/llvm
    set -gx LDFLAGS -L/opt/homebrew/opt/llvm/lib
    set -gx CPPFLAGS -I/opt/homebrew/opt/llvm/include
end

if test -e /opt/homebrew/bin/lld
    set -gx LD /opt/homebrew/bin/lld
end
