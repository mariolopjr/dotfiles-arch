# Mario's dotfiles repo
My personal dotfile repo (in case you were wondering). Can completely bootstrap an Arch Linux workstation (currently, only my desktop workstation, but when I get a non-mac laptop that will be added as well). With the `bootstrap.sh` script, the system is bootstrapped with packages and then [chezmoi](https://www.chezmoi.io/) is initiliazed, getting my dotfiles in order.

### Bootstrap Arch Linux
Ensure you have network connectivity, then run this `bash <(curl -sL git.io/JMnGu)` script to bootstrap the system and get dotfiles installed.

### After login
Run `chezmoi init --apply mariolopjr` which will configure dotfiles and install the rest of the packages
