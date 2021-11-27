#!/usr/bin/env -S bash -e

# Cleaning the TTY.
clear

# Pretty print (function).
print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}

# chroot into /mnt
arch-chroot /mnt /bin/bash

# Install NVIDIA proprietary driver if necessary
read -r -p "Do you want to install nvidia proprietary driver? [y/N]? " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
    print "Installing nvidia driver."
    pacman -Sy --noconfirm nvidia
    echo "MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" >> /etc/mkinitcpio.conf
    
    print "Configuring pacman initramfs rebuild on nvidia driver update"
    cat > /etc/pacman.d/hooks/60-nvidia.hook <<EOF
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
# Change the linux part above and in the Exec line if a different kernel is used

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF
fi

# Install base packages
pacman -Sy git neovim zsh plasma-meta firefox rustup libvirt qemu qemu-arch-extra virt-manager vagrant tmux fzf fd x264 steam ripgrep python python-pip mgba-qt ktorrent guitarix ppsspp pcsx2

# change user and install AUR packages
# Setting username.
read -r -p "Please enter name to chroot into and install packages: " username
su - $username
rustup default stable

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# install paru with paru and install additional aur packages
paru -S paru
paru -S nerd-fonts-fira-code 1password 1password-cli
exit

# Exit chroot
exit
