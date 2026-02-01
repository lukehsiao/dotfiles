<h1 align="center">
    ⚙️<br>
    Luke's MacOS Setup
</h1>
<div align="center">
    <strong>Hacky port of my configs for bootstrapping MacOS.</strong>
</div>
<br>

Dotfiles are managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

Intended to get a fresh install of MacOS fully configured quickly.

Install from fresh with:

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
