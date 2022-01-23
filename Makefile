SHELL := /bin/bash

all: update

update:
	chezmoi apply

basic:
	sudo apt-get update
	sudo apt-get install -y \
		curl \
		build-essential \
		automake \
		autoconf \
		checkinstall \
		cmake \
		git \
		git-lfs \
		unattended-upgrades \
		units \
		vim-gtk3 \
		pass \
		mosh \
		tmux \
		htop \
		gnupg2

chezmoi:
	curl --proto '=https' --tlsv1.2 -sSLO https://github.com/twpayne/chezmoi/releases/download/v1.7.15/chezmoi_1.7.15_linux_amd64.deb
	sudo dpkg -i chezmoi_1.7.15_linux_amd64.deb
	sudo apt-get install -f
	rm chezmoi_1.7.15_linux_amd64.deb

rust:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source $$HOME/.cargo/env

keybase:
	curl --proto '=https' --tlsv1.2 -sSO https://prerelease.keybase.io/keybase_amd64.deb
	# if you see an error about missing `libappindicator1` from the next
	# command, you can ignore it, as the subsequent command corrects it
	sudo dpkg -i keybase_amd64.deb
	sudo apt-get install -f
	rm keybase_amd64.deb

plug.vim:
	curl --proto '=https' --tlsv1.2 -sSLf https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim > $$(chezmoi source-path ~/.vim/autoload/plug.vim)

prettyping:
	curl --proto '=https' --tlsv1.2 -sSO https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
	install	-m755 prettyping ~/.local/bin/
	rm prettyping

zola:
	curl --proto '=https' --tlsv1.2 -sSLO https://github.com/getzola/zola/releases/download/v0.15.3/zola-v0.15.3-x86_64-unknown-linux-gnu.tar.gz
	tar xf zola-v0.15.3-x86_64-unknown-linux-gnu.tar.gz
	install -m755 zola ~/.cargo/bin
	rm zola-v0.15.3-x86_64-unknown-linux-gnu.tar.gz zola

git-sizer:
	curl --proto '=https' --tlsv1.2 -sSLO https://github.com/github/git-sizer/releases/download/v1.5.0/git-sizer-1.5.0-linux-amd64.zip
	unzip -o git-sizer-1.5.0-linux-amd64.zip -d tmp-git-sizer
	install -m755 tmp-git-sizer/git-sizer ~/.local/bin/
	rm -r git-sizer-1.5.0-linux-amd64.zip tmp-git-sizer

latex:
	sudo apt-get install -y texlive-full latexmk

gdb-dashboard:
	curl --proto '=https' --tlsv1.2 -sSLf https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/master/.gdbinit -o ~/.gdbinit

rust-utilities:
	cargo install \
		alacritty \
		bat \
		cargo-audit \
		cargo-bloat \
		cargo-edit \
		cargo-geiger \
		cargo-update \
		du-dust \
		eva \
		exa \
		fd-find \
		flamegraph \
		git-delta \
		hexyl \
		hyperfine \
		ripgrep \
		svgcleaner \
		tealdeer \
		tectonic \
		titlecase \
		tokei \
		xsv

google-chrome:
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
	sudo apt-get update
	sudo apt-get install google-chrome-stable

eisvogel:
	curl --proto '=https' --tlsv1.2 -sSL https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download/v2.0.0/Eisvogel-2.0.0.tar.gz -o /tmp/eisvogel.tar.gz
	mkdir -p /tmp/eisvogel
	tar xf /tmp/eisvogel.tar.gz -C /tmp/eisvogel
	install -m644 /tmp/eisvogel/eisvogel.latex ~/.pandoc/templates/eisvogel.latex
	rm -rf /tmp/eisvogel /tmp/eisvogel.tar.gz


.PHONY: alacritty basic chezmoi eisvogel gdb-dashboard git-sizer google-chrome keybase latex plug.vim prettyping rust rust-utilities update zola
