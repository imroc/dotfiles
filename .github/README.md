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

### Wezterm

<details>
<summary>Tab Management</summary>
  
Create, close, navigate, rename, move and toggle hide tabs:

https://github.com/user-attachments/assets/0dc0fa56-60bb-4ce8-b0a3-f9b949ee459d

</details>

<details>
<summary>Pane Management</summary>

Split, navigate and resize panes:

https://github.com/user-attachments/assets/f51889ce-59c3-41b6-b044-930f13a1f33b

</details>

### Others TODO

- neovim
- zellij
- aerospace
- fish
- kubernetes workflow
