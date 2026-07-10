<h1 align="center">
    ⚙️<br>
    Luke's Dotfiles
</h1>
<div align="center">
    <strong>Personal configs for my computers.</strong>
</div>
<br>
<div align="center">
  <a href="https://github.com/lukehsiao/dotfiles/blob/main/LICENSE.md">
    <img src="https://img.shields.io/badge/license-Blue--Oak--1.0.0-blue" alt="License">
  </a>
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

## Licensing

Original content in this repository is licensed under the [Blue Oak Model License 1.0.0](LICENSE.md).
Vendored third-party content is not covered by that license; it retains its upstream license, and where that license requires it, a copy of the license text lives in the vendored directory.

| Path | Upstream | License |
| --- | --- | --- |
| `dot_claude/skills/a-philosophy-of-software-design-skills/` | [markduan/a-philosophy-of-software-design-skills](https://github.com/markduan/a-philosophy-of-software-design-skills) | MIT per SKILL.md frontmatter; no LICENSE file upstream |
| `dot_claude/skills/code-reviewer/` | [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) | Apache-2.0 |
| `dot_claude/skills/hegel/` | [hegeldev/hegel-skill](https://github.com/hegeldev/hegel-skill) | MIT |
| `dot_claude/skills/jujutsu/` | [factorial-io/skills](https://github.com/factorial-io/skills) | none granted |
| `dot_claude/skills/just/` | [seckatie/katies-ai-skills](https://github.com/seckatie/katies-ai-skills) | CC0-1.0 (bundled `just` docs); repo itself unlicensed |
| `dot_claude/skills/nullables/` | [lexler/skill-factory](https://github.com/lexler/skill-factory) | Apache-2.0 |
| `dot_claude/skills/property-based-testing/` | [trailofbits/skills](https://github.com/trailofbits/skills) | CC-BY-SA-4.0 |
| `dot_claude/skills/ripgrep/` | [ratacat/claude-skills](https://github.com/ratacat/claude-skills) | none granted |
| `dot_claude/skills/rust-best-practices/` | [apollographql/skills](https://github.com/apollographql/skills) | MIT |
| `dot_claude/skills/wide-events-logging/` | [jonmumm/skills](https://github.com/jonmumm/skills) | none granted |
| `dot_claude/skills/writing-documentation-with-diataxis/` | [sammcj/agentic-coding](https://github.com/sammcj/agentic-coding) | Apache-2.0 |
| `dot_local/share/omarchy/` (modified scripts and hyprland config) | [basecamp/omarchy](https://github.com/basecamp/omarchy) | [MIT](LICENSES/omarchy-MIT.txt) |

"None granted" means the upstream repo publishes no license, so the default of all rights reserved applies; those copies are kept here with attribution only.
The property-based-testing skill is CC-BY-SA-4.0, so that directory stays share-alike rather than Blue Oak.
