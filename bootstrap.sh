#!/usr/bin/env -S bash -e

# Cleaning the TTY.
clear

# Pretty print (function).
print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}

get_username () {
    read -r -p "Please enter name for a user account: " username
    if [ -z "$username" ]; then
        print "You need to enter a valid username in order to continue."
        get_username
    fi
}

# Prepare system for install
bash <(curl -sL git.io/JMnfF)

# Enable multilib repo
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /mnt/etc/pacman.conf

get_username

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

# Install packages
pacstrap /mnt \
	kitty kitty-shell-integration kitty-terminfo zsh starship \
	neovim bat ripgrep exa fd wget fzf unzip zip dialog ddcutil \
	pacman-contrib bat ncdu pv zsh-completions watchexec tmux xclip \
	lsof bind-tools mtr socat htop iotop openbsd-netcat strace whois \
	e2fsprogs exfat-utils dosfstools f2fs-tools ddrescue \
	git git-delta jq ddrescue  \
	podman podman-dnsname buildah dnsmasq \
	qemu qemu-arch-extra virt-manager vagrant \
	clang go nodejs \
	plasma-desktop plasma-wayland-session kde-system-meta \
	kdeconnect kdenetwork-filesharing kget kio-extras kio-gdrive krdc krfb ktorrent zeroconf-ioslave \
	kleopatra kcmutils dolphin-plugins kdeplasma-addons \
    ark filelight kcalc kcharselect kdebugsettings kdf kdialog kfind kgpg kwrite kdiff markdownpart print-manager \
	quota-tools sddm rng-tools \
	firefox discord guitarix bitwarden bitwarden-cli \
	redshift pipewire scrot arandr x264 x265 \
	steam mgba-qt ppsspp pcsx2

# Install AUR packages
arch-chroot /mnt sudo -H -u "$username" bash -c "
	sudo systemctl enable sshd
	rm -rf /home/$username/paru

    paru -S --noconfirm opensnitch bitwig-studio citra-git rpcs3-git bsnes-qt5 nerd-fonts-fira-code protonup-git protonup-qt plymouth-git plymouth-theme-arch-logo-new refind-theme-nord nordic-kde-git kvantum-theme-nordic-git nordic-theme-git sddm-nordic-theme-git macchina

	sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply mariolopjr
"

# Enable SDDM
systemctl enable sddm --root=/mnt &>/dev/null
