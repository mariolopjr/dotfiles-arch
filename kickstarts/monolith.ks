{{define "kickstart"}}
# Fedora Kickstart for Anaconda, automating initial system setup
text

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
# TODO: Fix, needs to install from network
ostreesetup --osname="fedora" --remote="fedora" --url="file:///ostree/repo" --ref="fedora/35/x86_64/kinoite"

# Run the Setup Agent on first boot
firstboot --enable

# Generated using Blivet version 3.4.2
ignoredisk --only-use=sda

# Partition clearing information
# TODO: Fix for nvme
clearpart --drives=sda --all

# Disk partitioning information
part /boot/efi --fstype="efi" --ondisk=sda --size=512 --fsoptions="umask=0077,shortname=winnt" --label=ESP
part /boot --fstype="ext4" --ondisk=sda --size=1024
part btrfs.01 --fstype="btrfs" --ondisk=sda --size=128510 --encrypted --luks-version=luks2 --passphrase={{ .FdePassword }}
btrfs none --label btrfs01 btrfs.01
btrfs / --subvol --name=root btrfs01
btrfs /home --subvol --name=home btrfs01
btrfs /var/lib/machines --subvol --name=var_lib_machines btrfs01
btrfs /var/log --subvol --name=var_log btrfs01

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