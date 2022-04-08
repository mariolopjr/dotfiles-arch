{{define "kickstart"}}
# Fedora Kickstart for Anaconda, automating initial system setup
cmdline

%post --erroronfail
cp /etc/skel/.bash* /root
%end

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Firewall configuration
firewall --use-system-defaults

# OSTree setup
ostreesetup --osname="fedora" --remote="fedora" --url="file:///ostree/repo" --ref="fedora/35/x86_64/kinoite"

# Run the Setup Agent on first boot
firstboot --enable

# Generated using Blivet version 3.4.2
ignoredisk --only-use=sda

# Partition clearing information
clearpart --none --initlabel

# Disk partitioning information
part /boot/efi --fstype="efi" --ondisk=sda --size=512 --fsoptions="umask=0077,shortname=winnt" --label=ESP
part /boot --fstype="ext4" --ondisk=sda --size=1024
part btrfs --fstype="btrfs" --ondisk=sda --size=128510 --encrypted --luks-version=luks2 --passphrase={{ .FdePassword }}
btrfs none btrfs
btrfs / --subvol --name=root --fsoptions="subvol=root,ssd,compress=zstd,discard=async,x-systemd.device-timeout=0"
btrfs /home --subvol --name=home --fsoptions="subvol=home,ssd,compress=zstd,discard=async,x-systemd.device-timeout=0"
btrfs /var/lib/machines --subvol --name=var_lib_machines --fsoptions="subvol=var_lib_machines,ssd,compress=zstd,discard=async,x-systemd.device-timeout=0"
btrfs /var/log --subvol --name=var_log --fsoptions="subvol=var_log,ssd,compress=zstd,discard=async,x-systemd.device-timeout=0"

# System timezone
timezone America/New_York --utc

# Network configuration
network --onboot=yes --bootproto=dhcp --device=link --hostname=monolith

# Accounts
rootpw --lock
user --groups=wheel --name=mario --password={{ .UserPassword }} --gecos="Mario Lopez"

# Reboot After Installation
reboot --eject
{{end}}