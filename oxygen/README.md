# Oxygen 08

* User: Felix
* Machine: Huawei Matebook 16

## Home Configuration

There is `dotfiles` folder contains additional config files:

* `aliases.bash` - additional shell aliases
* `inputrc` - readline config
* `neovim.lua` - neovim config
* `vscode.json` - VS Code settings

## Custom Keyboard Layout

see https://nixos.org/manual/nixos/stable/#custom-xkb-layouts

### Key Maps

* <kbd>Caps Lock</kbd> -> <kbd>Escape</kbd>
* <kbd>Left Alt</kbd> -> <kbd>Level 3 Shift</kbd>
* <kbd>ISO &gt;&lt;</kbd> -> <kbd>Shift</kbd>

### Level 3 Layout

* <kbd>h</kbd> <kbd>j</kbd> <kbd>k</kbd> <kbd>l</kbd> -> <kbd>←</kbd> <kbd>↓</kbd> <kbd>↑</kbd> <kbd>→</kbd>
* <kbd>w</kbd> <kbd>a</kbd> <kbd>s</kbd> <kbd>d</kbd> -> <kbd>↑</kbd> <kbd>←</kbd> <kbd>↓</kbd> <kbd>→</kbd>
* <kbd>q</kbd> <kbd>e</kbd> -> <kbd>Home</kbd> <kbd>End</kbd>
* <kbd>r</kbd> -> <kbd>Delete</kbd>
* <kbd>f</kbd> -> <kbd>Backspace</kbd>
* <kbd>v</kbd> -> <kbd>Enter</kbd>

### Test

Test keyboard layout with with (xkb symbols file must be in `xkb/symbols` folder):

```
nix shell nixpkgs#xorg.xkbcomp
setxkbmap -I/home/felix/.dotfiles/xkb keyboard-layout -print | xkbcomp -I/home/felix/.dotfiles/xkb - $DISPLAY
```

> there must be NO space between `-I` and the path

### Setup

Make sure the special character key is also set to <kbd>Alt</kbd><kbd>Left</kbd> in GNOME settings:

```
Settings > Keyboard > Alternate Characters Key
```

dconf Path:

```
/org/gnome/desktop/input-sources/xkb-options
/org/gnome/desktop/input-sources/sources
```
