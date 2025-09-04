# github.com/lukehsiao/dotfiles

Dotfiles managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

Intended to get a fresh install of [Omarchy](https://omarchy.org/) fully configured quickly.

Install from fresh with:

```
yay -S chezmoi just
chezmoi init https://github.com/lukehsiao/dotfiles.git
chezmoi apply
just install-core
just import-gpg
```
