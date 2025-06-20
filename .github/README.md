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

## Tools

These tools are used in my daily work:

- [Neovim](https://github.com/neovim/neovim)
- [Wezterm](https://wezfurl.org/)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar)
- [AeroSpace](https://github.com/nikitabobko/AeroSpace)
- [JankyBorders](https://github.com/FelixKratz/JankyBorders)
- [Zellij](https://github.com/zellij-org/zellij)
- [fish](https://github.com/fish-shell/fish-shell)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd)
- [bat](https://github.com/sharkdp/bat)
- [eza](https://github.com/eza-community/eza)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [k9s](https://kubernetes.io/docs/reference/kubectl/)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [yazi](https://github.com/sxyazi/yazi)
- [Snipaste](https://www.snipaste.com/)

## Screenshoots

Work efficiently with tab and pane for `Aerospace` (macOS tiling window manager), `Wezterm` (terminal emulator) and `Zellij` (terminal multiplexers):

https://github.com/user-attachments/assets/dc5237ac-339d-45d8-a3a0-b6da8696cf72

https://github.com/user-attachments/assets/b49c14dd-944a-45e4-9108-d0d1ba2e571f

https://github.com/user-attachments/assets/442e8751-ae56-44b2-b2a6-2877238289e0

### Others TODO

- neovim
- fish
- kubernetes workflow
