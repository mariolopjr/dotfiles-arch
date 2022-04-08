# Mario's dotfiles repo
My personal dotfile repo (in case you were wondering). Can completely bootstrap a Fedora Kinoite workstation with the included [kickstart](https://docs.fedoraproject.org/en-US/fedora/latest/install-guide/appendixes/Kickstart_Syntax_Reference/) files (currently, only my desktop workstation, but when I get a non-mac laptop that will be added as well). With the `bootstrap.sh` script, the system is bootstrapped with OS-level packages and then [chezmoi](https://www.chezmoi.io/) is initiliazed, getting my dotfiles in order.

### Kickstart system
* Clone and enter this repository with (likely not necessary if using an existing system):
  * `git clone https://github.com/mariolopjr/dotfiles`.
  * `cd dotfiles`
* You may want to change some hardcoded values if using the included kickstart:
  * `sed -i 's/monolith/YOUR_HOSTNAME/' kickstarts/monolith.ks`
  * `sed -i 's/mario/YOUR_ACCOUNT_NAME/' kickstarts/monolith.ks`
  * `sed -i 's/Mario Lopez/YOUR_NAME/' kickstarts/monolith.ks`
  * `sed -i 's/^timezone/timezone YourCountry\/YourCity/' kickstarts/monolith.ks`
* Run the kickstart.go script which will launch an HTTP server:
  * `go run .\kickstart.go -fdepass test -userpass test`
* NOTE: at the moment, the kickstart will contain an unencrypted value for the user profile
* Install Fedora Server netinst to a usb with `dd if=netinst.iso of=/dev/sdx bs=1M oflag=sync status=progress`
* Boot Fedora Server netinst on the target install machine
* At the boot screen, press UP to select the "install without verify" option and then 'e'
* Insert the kickstart directive into the the boot string **before** the `quiet` directive:
  * `inst.ks=http://<WEB_SERVER_IP>:<PORT>/workstation.ks`
* Hit Ctrl-x. Install will begin and complete without any further prompt

### Bootstrap system
One the system reboots, unlock the FDE with the fde password supplied, then log in as with the user and password. Hit Ctrl+Alt+T to launch Konsole, then run this `bash <(curl -sL git.io/JMnGu)` to bootstrap the system and get dotfiles installed.
