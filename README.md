# My dotfiles

## Installation

### Manual installation with stow

Install GNU Stow:

```sh
sudo pacman -S stow

```

Clone the repository:

```sh
mkdir -p ~/.mydotfiles
cd ~/.mydotfiles
git clone --depth 1 https://github.com/xonorhc/mydotfiles.git

```

Create symlinks:

```sh
cd ~/.mydotfiles
stow --verbose --target=$HOME --dir=$HOME/.mydotfiles/dotfiles --restow .

```

Restart your system.

## Uninstall

### Delete symlinks

Remove all symlinks:

```sh
cd ~/.mydotfiles
stow --verbose --target=$HOME --delete .

```

## Credits

Learned/Copied a lot from these projects:

- [LierB/dotfiles](https://github.com/LierB/dotfiles)
- [mylinuxforwork/dotfiles](https://github.com/mylinuxforwork/dotfiles)
- [HyDE-Project/HyDE](https://github.com/HyDE-Project/HyDE)
