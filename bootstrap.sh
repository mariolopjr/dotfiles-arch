#!/bin/bash

# Add non-free repo
sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Add global packages (creates a ostree layer)
sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia steam python-pip virt-manager virt-viewer virt-top libvirt zsh vagrant neovim tmux bat fzf ripgrep fd-find mozilla-openh264

# Disallow nouveau driver from loading
sudo rpm-ostree kargs --append=modprobe.blacklist=nouveau

# Create default toolbox
toolbox create
