update-default-config: update-default-rc update-default-plugins

update-default-rc:
	cp $(shell brew --prefix)/share/sketchybar/examples/sketchybarrc default/sketchybarrc
update-default-plugins:
	rm -rf default/plugins
	cp -r $(shell brew --prefix)/share/sketchybar/examples/plugins default/plugins
