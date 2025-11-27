update-default-config:
	kitty +runpy 'from kitty.config import *; print(commented_out_default_config())' > kitty.default.conf
update-theme:
	wget -O theme-tokyonight-night.conf https://raw.githubusercontent.com/kovidgoyal/kitty-themes/refs/heads/master/themes/tokyo_night_night.conf
update: update-default-config update-theme
