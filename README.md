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
yay -S chezmoi just
chezmoi init https://github.com/lukehsiao/dotfiles.git
chezmoi apply
just import-gpg
just install-core
just use-bbr  # optional
```
