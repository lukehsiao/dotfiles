#!/usr/bin/env bash
# One-shot migration: remove the pacman/AUR, brew, and cargo copies of tools
# that are now managed by mise (see _mise-tools in the justfile). Run after
# `just install-core` on each machine, then delete this file (and its
# .chezmoiignore entry) once every machine has been migrated.
#
# Safe to run while `just install-core` is still going: cargo uninstalls run
# first (no root, cargo's own file lock serializes), and the pacman removal
# waits for /var/lib/pacman/db.lck instead of dying mid-transaction.
#
# Deliberately untouched: packages dropped from the justfile but not migrated
# to mise (prettier, sccache, tree, units, vim, pacman bacon). Remove those by
# hand if you want them gone.
set -uo pipefail

# Crates whose binaries moved from cargo binstall to mise. `choose` and
# `openring` are strays from older justfile revisions.
cargo_crates=(
    cargo-deny
    cargo-leptos
    cargo-llvm-cov
    cargo-mutants
    cargo-nextest
    cargo-semver-checks
    choose
    git-stats
    leptosfmt
    openring
    wasm-bindgen-cli
)

# Superset of repo/AUR names (including -bin/-cli variants) so drifted
# machines still match; only installed ones are removed.
pacman_pkgs=(
    b3sum bottom caligula caligula-bin
    cargo-deny cargo-leptos cargo-llvm-cov cargo-mutants
    cargo-nextest cargo-semver-checks
    choose codebook codebook-lsp croc d2 difftastic
    dprint dprint-bin duf
    git-absorb git-cliff git-delta git-grab git-sizer git-stats
    glow gping helm hexyl hl hyperfine jaq jless jujutsu
    k9s kubectl leptosfmt ltex-ls-plus ltex-ls-plus-bin lychee
    marksman marksman-bin oha onefetch openring-rs-bin oxipng
    pandoc pandoc-bin pandoc-cli pastel pdfcpu pdfcpu-bin
    presenterm presenterm-bin ruff samply samply-bin sd
    shellcheck shellcheck-bin shfmt svgcleaner tailspin
    tealdeer tealdeer-bin tectonic texlab tinymist tinymist-bin
    tombi tombi-bin ty typos typos-lsp typos-lsp-bin typst
    wasm-bindgen watchexec xh xh-bin xsv zizmor zola zola-bin
)

brew_pkgs=(
    b3sum bottom codebook-lsp croc difftastic duf
    git-absorb git-delta git-grab git-sizer glow gping
    hexyl hl jaq jj jless onefetch oxipng pandoc pastel
    pdfcpu presenterm ruff samply sd shellcheck shfmt
    tealdeer tectonic typos-lsp xh xsv
)

if command -v cargo >/dev/null; then
    installed_crates=$(cargo install --list 2>/dev/null | awk '/^[a-zA-Z0-9_-]+ v[0-9]/ {print $1}')
    to_uninstall=()
    for crate in "${cargo_crates[@]}"; do
        if printf '%s\n' "$installed_crates" | grep -qx "$crate"; then
            to_uninstall+=("$crate")
        fi
    done
    if [ ${#to_uninstall[@]} -gt 0 ]; then
        echo "==> cargo uninstall: ${to_uninstall[*]}"
        cargo uninstall "${to_uninstall[@]}"
    else
        echo "==> cargo: nothing to remove"
    fi
else
    echo "==> cargo not found; skipping crate removal"
fi

if command -v pacman >/dev/null; then
    to_remove=()
    for pkg in "${pacman_pkgs[@]}"; do
        pacman -Qq "$pkg" >/dev/null 2>&1 && to_remove+=("$pkg")
    done
    if [ ${#to_remove[@]} -gt 0 ]; then
        echo "==> pacman -Rns: ${to_remove[*]}"
        # install-core grabs the DB lock repeatedly (yay -S, _install-dictd);
        # wait it out and retry rather than failing at a random point. The
        # sleep-to-pacman gap is racy, hence the retry loop.
        for attempt in 1 2 3; do
            while [ -e /var/lib/pacman/db.lck ]; do
                echo "pacman db locked (install-core still running?); waiting 10s..." >&2
                sleep 10
            done
            sudo pacman -Rns --noconfirm "${to_remove[@]}" && break
            if [ "$attempt" -eq 3 ]; then
                echo "ERROR: pacman removal failed after 3 attempts" >&2
                exit 1
            fi
            echo "pacman failed (lock race?); retrying..." >&2
            sleep 5
        done
    else
        echo "==> pacman: nothing to remove"
    fi
elif command -v brew >/dev/null; then
    installed_formulas=$(brew list --formula)
    to_remove=()
    for pkg in "${brew_pkgs[@]}"; do
        if printf '%s\n' "$installed_formulas" | grep -qx "$pkg"; then
            to_remove+=("$pkg")
        fi
    done
    if [ ${#to_remove[@]} -gt 0 ]; then
        echo "==> brew uninstall: ${to_remove[*]}"
        brew uninstall "${to_remove[@]}"
    else
        echo "==> brew: nothing to remove"
    fi
fi

echo "==> done. Verify with: mise ls --global"
