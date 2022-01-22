#!/usr/bin/env sh

echo 'Making directories'
mkdir -p $HOME/.config/nvim $HOME/.local/share/nvim
cp -r ./* $HOME/.config/nvim

echo 'Bootstraping Doom'
nvim --headless -E -c 'q'

mkdir /tmp/doc

echo 'Writing binds'
nvim --headless --cmd 'lua vim.g.doom_write_binds = true' -E  -c 'q'

echo 'Writing modules'
MODULES=$(find lua/doom/modules/ -mindepth 1 -maxdepth 1 -type d | cut -d'/' -f4-)
mkdir /tmp/doc/modules
for module in $MODULES; do
    echo "Writing module $module"
    mkdir /tmp/doc/modules/$module
    pandoc -r lua/doom-tools/docs/doom_pandoc_reader.lua -t markdown lua/doom/modules/$module/init.lua -o /tmp/doc/modules/$module/init.md
    pandoc -r lua/doom-tools/docs/doom_pandoc_reader.lua -t markdown lua/doom/modules/$module/packages.lua -o /tmp/doc/modules/$module/packages.md
done

