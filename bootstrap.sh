#!/usr/bin/env -S bash -e

# Cleaning the TTY.
clear

# Pretty print (function).
print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}

# Prepare system for install
bash <(curl -sL git.io/JMnfF)

# Enable multilib repo
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /mnt/etc/pacman.conf

# Install NVIDIA proprietary driver if necessary
read -r -p "Do you want to install nvidia proprietary driver? [y/N]? " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
    print "Installing nvidia driver."
    pacstrap /mnt nvidia nvidia-utils
    echo "MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" >> /mnt/etc/mkinitcpio.conf

    print "Rebuilding initramfs"
    arch-chroot /mnt mkinitcpio -P &>/dev/null
    
    print "Configuring pacman initramfs rebuild on nvidia driver update"
    cat > /mnt/etc/pacman.d/hooks/60-nvidia.hook <<EOF
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

# General packages
pacstrap /mnt zsh starship ripgrep exa fd wget fzf unzip zip dialog \
	pacman-contrib bat ncdu pv zsh-completions watchexec tmux \
	# Debugging tools
	lsof bind-tools mtr socat htop iotop openbsd-netcat strace tcpdump whois \
	# Filesystems
	e2fsprogs exfat-utils dosfstools f2fs-tools \
	# Other tools
	git jq ddrescue shellcheck \
	# Docker
	podman podman-dnsname buildah dnsmasq \
	# Virtualization
	qemu qemu-arch-extra virt-manager vagrant \
	# Languages
	rustup clang go \
	# Python tools
	python-black python-pycodestyle python-pylint flake8 python-pip \
	# Node tools
	nodejs prettier \
	# Text
	vale \
	# KDE
	plasma-meta breeze breeze-grub kcmutils konsole kdeplasma-addons \
	quota-tools sddm rng-tools archlinux-themes-sddm \
	# Applications
	firefox discord ktorrent guitarix kate \
	# Utilities
	redshift python-gobject pipewire scrot arandr x264 \
	# Fonts
	noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
	# Gaming
	steam mgba-qt ppsspp pcsx2

# Enable SDDM
systemctl enable sddm --root=/mnt &>/dev/null
