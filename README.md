<h1 align="center">
    ⚙️<br>
    Luke's Dotfiles
</h1>
<div align="center">
    <strong>Personal configs for my computers.</strong>
</div>
<br>

This is my opinionated developer setup.
This is not intended for general use; many things are hardcoded for me, specifically.

Dotfiles are managed with [`chezmoi`](https://github.com/twpayne/chezmoi).
On first run, `chezmoi init` prompts for a `distro` choice (`omarchy` or `macos`) that gates platform-specific files and templates.

## Omarchy (Arch Linux)
Install from a fresh [Omarchy](https://omarchy.org/) setup:

```
# Make an SSH key and add to GitHub
ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)"

# Grab prereqs
yay -S \
    age-plugin-yubikey \
    chezmoi \
    just \
    pcsclite \
    pcsc-tools \
    rage-encryption \
    yubikey-manager
sudo systemctl enable pcscd
sudo systemctl start pcscd

git clone git@github.com:lukehsiao/passage.git ~/.passage/store
age-plugin-yubikey --identity >> $HOME/.passage/identities
chezmoi init git@github.com:lukehsiao/dotfiles.git
# Awkwardly requires bootstrapping from a configured computer for passphrase...
chezmoi apply

just install-core
just use-bbr  # optional

atuin login

# [optional] Configure styles for zen browser
# [optional] set up display-switch
just setup-display-switch
```

### Printer
Note to self on printers on linux: use [IPP Everywhere](https://wiki.archlinux.org/title/CUPS).

## macOS
Install from a fresh macOS setup:

```
# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Make an SSH key and add to GitHub
ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)"

# Grab prereqs
brew install \
    age-plugin-yubikey \
    chezmoi \
    just
chezmoi init git@github.com:lukehsiao/dotfiles.git
# Awkwardly requires bootstrapping from a configured computer for passphrase...
chezmoi apply

just install-core

atuin login

# [optional] set up display-switch
just setup-display-switch

# copy fonts from ~/.local/share/fonts to FontBook

# Fix Flameshot permissions in settings

# Install Inkscape manually

# Install Slack manually

# Install OBS manually, set up scenes and audio filters

# Configure keyboard shortcut CapsLock -> Ctrl

# Configure Audio to use USB Audio Interface

# Configure dock to auto-hide

# Configure workspaces to not change position ("Automatically rearrange Spaces based on most recent use")

# Remove "Quick Note" hot corner

# Remove 1password keyboard shortcuts (collide with Slack's)

# Install MOTU-M2 drivers for MacOS

# Enable Slack/Chrome/Ghostty notifications in MacOS settings
```
