# My dotfiles

## Installation

### Manual installation with stow

Install GNU Stow:

```sh
sudo pacman -S stow

```

Clone the repository:

```sh
mkdir -p ~/Templates
cd ~/Templates
git clone --depth 1 https://github.com/xonorhc/mydotfiles.git --branch rose-pine-moon

```

Create symlinks:

```sh
cd ~/Templates/mydotfiles
stow --verbose --target=$HOME --dir=$HOME/Templates/mydotfiles/dotfiles --restow .

```

Restart your system.

## Uninstall

### Delete symlinks

Remove all symlinks:

```sh
cd ~/Templates/mydotfiles
stow --verbose --target=$HOME --delete .

```
