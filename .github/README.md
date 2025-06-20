# Dotfiles

My personal dotfiles managed by [yadm](https://github.com/yadm-dev/yadm).

## Install YADM

Before using this dotfiles, you first need to install yadm, checkout the official yadm [installation](https://yadm.io/docs/install) instructions.

The most common way is to download the yadm script directly and install it to `PATH` (without relying on any package manager):

```bash
curl -fLo /usr/local/bin/yadm https://github.com/yadm-dev/yadm/raw/master/yadm && chmod a+x /usr/local/bin/yadm
```

> Assuming you have git and curl installed.

## Clone Dotfiles Repository

Clone the dotfiles repository using `yadm`:

```bash
yadm clone https://github.com/imroc/dotfiles.git
yadm status
```

And you can force overwrite of local dotfiles:

```bash
yadm reset --hard HEAD
yadm pull
```

## Screenshoots

Work efficiently with tab and pane for aerospace (tiling window manager for macOS), wezterm (terminal emulator) and zellij (terminal multiplexers):

https://github.com/user-attachments/assets/dc5237ac-339d-45d8-a3a0-b6da8696cf72

https://github.com/user-attachments/assets/b49c14dd-944a-45e4-9108-d0d1ba2e571f

https://github.com/user-attachments/assets/442e8751-ae56-44b2-b2a6-2877238289e0

### Others TODO

- neovim
- zellij
- aerospace
- fish
- kubernetes workflow
