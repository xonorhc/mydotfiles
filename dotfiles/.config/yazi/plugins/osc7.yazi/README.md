# 🚀 osc7.yazi

A lightweight [Yazi](https://github.com/sxyazi/yazi) plugin that synchronizes your terminal's working directory using the **OSC 7** escape sequence.

## Why use this?

Most modern terminal emulators can track the shell's current directory, but they lose track when you're inside a TUI application like Yazi. This plugin restores that link, enabling features like:

- **Dynamic Window Titles:** Your terminal tab/window title updates as you navigate.
- **Smart "New Tab" Behavior:** Opening a new tab or terminal window will automatically start in your current Yazi directory.
- **Shell Integration:** Better synergy with terminal multiplexers and sophisticated prompts.

> [!IMPORTANT]
> Your terminal emulator must support the [OSC 7 protocol](https://michaelrommel.com/create/2024-11-19-osc7-and-why-you-might-need-it). Supported terminals include **Alacritty, Kitty, WezTerm, iTerm2, and Foot.**

---

## 🛠️ Installation

Use the Yazi package manager:

``` bash
ya pkg add coder0x6675/osc7
```

Or install it manually:

```bash
# Create the plugins directory if it doesn't exist
mkdir -p ~/.config/yazi/plugins

# Clone the plugin
git clone 'https://github.com/coder0x6675/osc7.yazi.git' ~/.config/yazi/plugins/osc7.yazi

# Enable the plugin
echo 'require("osc7"):setup()' >> ~/.config/yazi/init.lua
```

---

## ⚙️ How it Works

The plugin listens for directory change events within Yazi and emits a specific operating system command (OSC) sequence:
`\033]7;file://HOSTNAME/CURRENT_DIR\007`

No further configuration is required. Once enabled, the PWD will update automatically as you browse.

## 🤝 Contributing

If you find a terminal where this doesn't behave as expected, feel free to open an issue or submit a PR.

