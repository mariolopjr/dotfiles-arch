# Disable fish greeting
set -g fish_greeting

if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
else if type -q vim
    set -gx EDITOR vim
    set -gx VISUAL vim
else
    set -gx EDITOR vi
    set -gx VISUAL vi
end

# Termite tmux SSH error workaround
if test $TERM = xterm-termite
    set -gx TERM xterm-256color
end

# Alacritty SSH error workaround
if test $TERM = alacritty
    set -gx TERM xterm-256color
end
