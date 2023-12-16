# just manual: https://github.com/casey/just

_default:
	@just --list
	
# Install Iosevka font via GitHub release
iosevka:
	#!/usr/bin/env bash
	set -euxo pipefail
	curl -s https://api.github.com/repos/be5invis/Iosevka/releases/latest | rg -N "browser_download_url" | rg -N --color never "SuperTTC-Iosevka-\d+\.\d+\.\d+\.zip" | sd '"' "'" | choose 1 | xargs -I % xh -F -o /tmp/iosevka.zip GET %
	unzip /tmp/iosevka.zip -d ~/.fonts/
	rm /tmp/iosevka.zip
	sudo fc-cache -f -v

# Install rust toolchain
rust:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install Zola from GitHub release
zola:
	#!/usr/bin/env bash
	set -euxo pipefail
	curl -s https://api.github.com/repos/getzola/zola/releases/latest | rg -N "browser_download_url" | rg -N --color never "zola.*linux-gnu.tar.gz" | sd '"' "'" | choose 1 | xargs -I % xh -F -o /tmp/zola.tar.gz GET %
	mkdir -p /tmp/zola
	tar xf /tmp/zola.tar.gz -C /tmp/zola
	install -m755 /tmp/zola/zola ~/.cargo/bin
	rm -rf /tmp/zola /tmp/zola.tar.gz

# Install git-sizer from GitHub release
git-sizer:
	#!/usr/bin/env bash
	set -euxo pipefail
	curl --proto '=https' --tlsv1.2 -sSLO https://github.com/github/git-sizer/releases/download/v1.5.0/git-sizer-1.5.0-linux-amd64.zip
	unzip -o git-sizer-1.5.0-linux-amd64.zip -d tmp-git-sizer
	install -m755 tmp-git-sizer/git-sizer ~/.local/bin/
	rm -r git-sizer-1.5.0-linux-amd64.zip tmp-git-sizer

# Install GDB Dashboard
gdb-dashboard:
	curl --proto '=https' --tlsv1.2 -sSLf https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/master/.gdbinit -o ~/.gdbinit

# Install nice rust utilities
rust-utilities:
	cargo install \
		bat \
		cargo-audit \
		cargo-bloat \
		cargo-edit \
		cargo-geiger \
		cargo-update \
		choose \
		du-dust \
		eva \
		eza \
		fd-find \
		flamegraph \
		git-delta \
		hexyl \
		hyperfine \
		ripgrep \
		sd \
		starship \
		tealdeer \
		tectonic \
		titlecase \
		tokei \
		xh \
		xsv
	cargo install --git https://github.com/lukehsiao/tool.git

# Install eisvogel pandoc template
eisvogel:
	#!/usr/bin/env bash
	set -euxo pipefail
	curl -s https://api.github.com/repos/Wandmalfarbe/pandoc-latex-template/releases/latest | rg -N "browser_download_url" | rg -N --color never "Eisvogel.tar.gz" | sd '"' "'" | choose 1 | xargs -I % xh -F -o /tmp/eisvogel.tar.gz GET %
	mkdir -p /tmp/eisvogel
	tar xf /tmp/eisvogel.tar.gz -C /tmp/eisvogel
	install -m644 /tmp/eisvogel/eisvogel.latex ~/.pandoc/templates/eisvogel.latex
	rm -rf /tmp/eisvogel /tmp/eisvogel.tar.gz

