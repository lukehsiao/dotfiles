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
		vim-gtk3 \
		pass \
		mosh \
		tmux \
		htop \
		gnupg2

ubuntu-install-chezmoi:
	curl --proto '=https' --tlsv1.2 -sSLO https://github.com/twpayne/chezmoi/releases/download/v1.7.15/chezmoi_1.7.15_linux_amd64.deb
	sudo dpkg -i chezmoi_1.7.15_linux_amd64.deb
	sudo apt-get install -f
	rm chezmoi_1.7.15_linux_amd64.deb

ubuntu-install-rust:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source $$HOME/.cargo/env

ubuntu-install-keybase:
	curl --proto '=https' --tlsv1.2 -sSO https://prerelease.keybase.io/keybase_amd64.deb
	# if you see an error about missing `libappindicator1` from the next
	# command, you can ignore it, as the subsequent command corrects it
	sudo dpkg -i keybase_amd64.deb
	sudo apt-get install -f
	rm keybase_amd64.deb	

ubuntu-install-plug.vim:
	curl --proto '=https' --tlsv1.2 -sSLf https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim > $$(chezmoi source-path ~/.vim/autoload/plug.vim)

ubuntu-install-prettyping:
	curl --proto '=https' --tlsv1.2 -sSO https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping	
	install	-m755 prettyping ~/.local/bin/
	rm prettyping

ubuntu-install-zola:
	curl --proto '=https' --tlsv1.2 -sSLO https://github.com/getzola/zola/releases/download/v0.10.1/zola-v0.10.1-x86_64-unknown-linux-gnu.tar.gz
	tar xf zola-v0.10.1-x86_64-unknown-linux-gnu.tar.gz
	install -m755 zola ~/.cargo/bin
	rm zola-v0.10.1-x86_64-unknown-linux-gnu.tar.gz zola

ubuntu-install-git-sizer:
	curl --proto '=https' --tlsv1.2 -sSLO https://github.com/github/git-sizer/releases/download/v1.3.0/git-sizer-1.3.0-linux-amd64.zip
	unzip -o git-sizer-1.3.0-linux-amd64.zip -d tmp-git-sizer
	install -m755 tmp-git-sizer/git-sizer ~/.local/bin/
	rm -r git-sizer-1.3.0-linux-amd64.zip tmp-git-sizer

ubuntu-install-latex:
	sudo apt-get install -y texlive-full latexmk

ubuntu-install-gdb-dashboard:
	curl --proto '=https' --tlsv1.2 -sSLf https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/master/.gdbinit -o ~/.gdbinit

ubuntu-install-rust-utilities:
	cargo install \
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

ubuntu-install-mendeley:
	curl --proto '=https' --tlsv1.2 -sSL https://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest -o mendeley.deb
	sudo dpkg -i mendeley.deb
	rm mendeley.deb

ubuntu-install-alacritty:
	curl --proto '=https' --tlsv1.2 -sSL https://github.com/jwilm/alacritty/releases/download/v0.4.2/Alacritty-v0.4.2-ubuntu_18_04_amd64.deb -o alacritty.deb
	sudo dpkg -i alacritty.deb
	rm alacritty.deb

ubuntu-install-google-chrome:
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
	sudo apt-get update
	sudo apt-get install google-chrome-stable

ubuntu-install-eisvogel:
	curl --proto '=https' --tlsv1.2 -sSL https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download/v1.4.0/Eisvogel-1.4.0.tar.gz -o /tmp/eisvogel.tar.gz
	mkdir -p /tmp/eisvogel
	tar xf /tmp/eisvogel.tar.gz -C /tmp/eisvogel
	install -m644 /tmp/eisvogel/eisvogel.tex ~/.pandoc/templates/eisvogel.latex
	rm -rf /tmp/eisvogel /tmp/eisvogel.tar.gz
