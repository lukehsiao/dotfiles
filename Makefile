SHELL := /bin/bash

all: update

update:
	chezmoi apply

ubuntu-install-packages:
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
		vim-gnome \
		pass \
		mosh \
		tmux \
		htop \
		gnupg2

ubuntu-install-rust:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source $$HOME/.cargo/env

ubuntu-install-diff-so-fancy:
	curl -sSO https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy	
	chmod +x diff-so-fancy
	mv diff-so-fancy ~/.local/bin/

ubuntu-install-plug.vim:
	curl -s -L https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim > $$(chezmoi source-path ~/.vim/autoload/plug.vim)

ubuntu-install-prettyping:
	curl -sSO https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping	
	chmod +x prettyping
	mv prettyping ~/.local/bin/

ubuntu-install-zola:
	curl -sSLO https://github.com/getzola/zola/releases/download/v0.7.0/zola-v0.7.0-x86_64-unknown-linux-gnu.tar.gz
	tar xf zola-v0.7.0-x86_64-unknown-linux-gnu.tar.gz
	mv zola ~/.cargo/bin/
	rm zola-v0.7.0-x86_64-unknown-linux-gnu.tar.gz

ubuntu-install-latex:
	sudo apt-get install -y texlive-full latexmk

ubuntu-install-gdb-dashboard:
	curl -sSL git.io/.gdbinit -o ~/.gdbinit

ubuntu-install-rust-utilities:
	cargo install \
		ripgrep \
		exa \
		fd-find \
		hexyl \
		tealdeer \
		tokei \
		xsv \
		flamegraph \
		bat \
		cargo-bloat \
		cargo-update \
		hyperfine

ubuntu-install-mendeley:
	curl -sSL https://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest -o mendeley.deb
	sudo dpkg -i mendeley.deb
	rm mendeley.deb

ubuntu-install-alacritty:
	curl -sSL https://github.com/jwilm/alacritty/releases/download/v0.3.2/Alacritty-v0.3.2-ubuntu_18_04_amd64.deb -o alacritty.deb
	sudo dpkg -i alacritty.deb
	rm alacritty.deb

ubuntu-install-google-chrome:
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
	sudo apt-get update
	sudo apt-get install google-chrome-stable
