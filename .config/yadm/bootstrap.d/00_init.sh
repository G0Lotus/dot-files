#!/bin/bash

function update_pacman() {
	sudo sed -i "s/^NoProgressBar/#NoProgressBar/g" /etc/pacman.conf
	sudo sed -i "s/.*ParallelDownloads.*/ParallelDownloads = $(nproc)/g" /etc/pacman.conf
	sudo pacman-key --init
	sudo pacman-key --populate
	sudo pacman -S --noconfirm --needed archlinux-keyring reflector
	sudo reflector --latest 20 --fastest 20 --threads 20 --sort rate --protocol https -c China --save /etc/pacman.d/mirrorlist
	sudo pacman -Syyu --noconfirm
}

# install paru
function install_paru() {
	pkg="paru-bin"
	if ! which paru >/dev/null 2>&1; then
		aur_url="https://aur.archlinux.org/${pkg}.git"
		git clone "$aur_url"
		cd "$pkg" || return
		if ! makepkg -si --noconfirm; then
			echo "${pkg} install failed, exit!"
			exit
		fi
		cd - && rm -rf "$pkg"
	else
		echo "${pkg} already installed"
	fi
}

function install_nvim() {
	pkgs="neovim lua unzip nodejs npm ripgrep fd fzf"
	echo "$pkgs" | xargs paru -S --noconfirm --needed >/dev/null
}

function install_fish() {
	paru -S --noconfirm --needed fish >/dev/null
	if [ "$SHELL" != "/usr/bin/fish" ]; then
		sudo chsh -s /usr/bin/fish "$USER"
	fi
}

function install_python() {
	pkgs="python python-pip python-pipx rye uv ruff ruff-lsp"
	echo "$pkgs" | xargs paru -S --noconfirm --needed >/dev/null
}

# update_pacman
install_paru
install_nvim
install_fish
install_python

if [ ! -f "$HOME/.ssh/id_rsa" ]; then
	yadm decrypt
fi

if [[ "$(yadm remote get-url origin)" =~ "https" ]]; then
	yadm remote set-url origin "git@github.com:G0Lotus/dot-files.git"
fi
