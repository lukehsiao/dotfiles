# github.com/lukehsiao/dotfiles

:warning: Most my configuration now lives in https://github.com/lukehsiao/omakase-blue :warning:

Dotfiles managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

Install with:

```
yay -S chezmoi just
chezmoi init https://github.com/lukehsiao/dotfiles.git
chezmoi apply
just install-core
just import-gpg
```
