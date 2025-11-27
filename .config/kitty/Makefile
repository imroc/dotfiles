update-default-config:
	kitty +runpy 'from kitty.config import *; print(commented_out_default_config())' > kitty.default.conf
update-theme:
	wget -O theme-tokyonight-night https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/kitty/tokyonight_night.conf
update: udpate-default-config update-theme
