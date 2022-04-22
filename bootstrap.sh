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
	e2fsprogs exfat-utils dosfstools f2fs-tools ddrescue fwupd openssh \
	git git-delta jq ddrescue bottom ctop man xdg-desktop-portal-wlr \
	podman podman-dnsname buildah dnsmasq cifs-utils pipewire-media-session \
	qemu qemu-arch-extra virt-install virt-viewer vagrant flatpak xdg-desktop-portal \
	clang go nodejs iwd dhcpcd \
	sway swaylock swayidle rofi xorg-xwayland mako udiskie \
	nnn firefox bitwarden bitwarden-cli mopidy ncmpcpp zathura zathura-cb zathura-pdf-mupdf \
	papirus-icon-theme rng-tools \
	redshift pipewire scrot arandr x264 x265 \
	steam

# Install AUR packages
arch-chroot /mnt sudo -H -u "$username" bash -c "
	rm -rf /home/$username/paru

	sudo flatpak install -y flathub net.pcsx2.PCSX2 org.ppsspp.PPSSPP io.mgba.mGBA  org.citra_emu.citra org.yuzu_emu.yuzu net.rpcs3.RPCS3 dev.bsnes.bsnes net.kuribo64.melonDS \
		com.github.tchx84.Flatseal net.davidotek.pupgui2 org.kde.digikam com.discordapp.Discord com.spotify.Client org.libreoffice.LibreOffice org.kde.krdc
    paru -S --noconfirm opensnitch bitwig-studio nerd-fonts-victor-mono nerd-fonts-noto protonup-git greetd greetd-wlgreet swaynagmode refind-theme-nord nordic-theme-git macchina \
		papirus-folders-git papirus-nord nordzy-cursors mopidy-subidy mopidy-mpd

	sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply mariolopjr
"

cat > /mnt/etc/mopidy/mopidy.conf <<EOF
[core]
cache_dir = /var/cache/mopidy
config_dir = /etc/mopidy
data_dir = /var/lib/mopidy

[logging]
config_file = /etc/mopidy/logging.conf
debug_file = /var/log/mopidy/mopidy-debug.log

[local]
data_dir = /home/mario/.local/mopidy/local
media_dir = /home/mario/media/music

[m3u]
playlists_dir = /home/mario/media/playlists

[mpd]
hostname = ::
connection_timeout = 300

[audio]
output = tee name=t t. ! queue ! autoaudiosink t. ! queue ! audioresample ! audioconvert ! audio/x-raw,rate=44100,channels=2,format=S16LE ! wavenc ! filesink location=/tmp/mpd.fifo
## TODO: following will make localhost:5555 
## available as a source of data for the 
## stereo visualizer without the fifo hack.
# output = tee name=t ! queue ! autoaudiosink t.  ! queue ! audio/x-raw,rate=44100,channels=2,format=S16LE ! udpsink host=localhost port=6600
mixer_volume = 70

[file]
media_dirs = /home/mario/media/music
# follow_symlinks = false
# metadata_timeout = 1000

[podcast]
enabled = true
browse_root = /home/mario/media/podcasts.opml

[subidy]
url=https://musl.home.techmunchies.net
username=mario
password=edit_me

# [youtube]
# enabled = true
# musicapi_enabled = true

# [ytmusic]
# enabled = true

# [scrobbler]
# enabled = true
# username = *******
# password = *******************

# [soundcloud]
# enabled = true
# explore_songs = 45
# auth_token = ********************
EOF

cat > /mnt/etc/greetd/config.toml <<EOF
[terminal]
vt = 1

[default_session]
command = "sway --config /etc/greetd/sway-wlgreet.conf"
user = "greeter"
EOF

cat > /mnt/etc/greetd/wlgreet.toml <<EOF
outputMode = "active"
scale = 1

[background]
red = 0
green = 0
blue = 0
opacity = 0.7
EOF

cat > /mnt/etc/greetd/sway-wlgreet.conf <<'EOF'
# 
# Settings
#

# Cursor hide delay (in ms)
#set $cursor-delay "100"

# Display sleep idle time
#set $dispsleep-time "10"

# Display sleep and wake commands
#set $dispsleep 'swaymsg "output * dpms off"'
#set $dispwake 'swaymsg "output * dpms on"'

# The input devices worth paying attention to
#set $touchpad "2:7:SynPS/2_Synaptics_Touchpad"

# wlgreet config location
set $wlgreet-config /etc/greetd/wlgreet.toml

# wlgreet command
set $wlgreet-command sway

# waybar config location
#set $waybar-config /etc/greetd/waybar.conf
#set $waybar-css /etc/greetd/waybar.css

# 
# Setup
#

# Exit on Mod4+Shift+R, effectively restarting the greeter
bindsym Mod4+Shift+r exit

# Set wallpaper
output * bg /usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill

# Touchpad options
# input $touchpad {
# 	pointer_accel 0.5
# }

# Disable Trackpoint
#input $trackpoint events disabled

# Hide cursor after delay
#seat * hide_cursor $cursor-delay

# Display sleep setup
#exec swayidle timeout $dispsleep-time $dispsleep resume $dispwake

# Start waybar
#exec "waybar --config $waybar-config --style $waybar-css"

# The greeter itself
exec "wlgreet --command $wlgreet-command --config $wlgreet-config; swaymsg exit"
EOF

# Enable services
systemctl enable sshd greetd iwd dhcpcd mopidy --root=/mnt &>/dev/null
