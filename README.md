<h1 align="center">
    ⚙️<br>
    Luke's Linux Setup
</h1>
<div align="center">
    <strong>Configuration and customization scripts on top of <a href="https://omarchy.org/">Omarchy</a>.</strong>
</div>
<br>

This is my omakase developer setup on top of [Omarchy](https://omarchy.org/).
Unlike Omarchy, this is not intended for general use, this configuration is specifically mine, with many me-specific hardcoded values.

Dotfiles are managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

Intended to get a fresh install of Omarchy fully configured quickly.

Install from fresh with:

```
# Make an SSH key and add to GitHub
ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)"
# Grab pass
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
```
