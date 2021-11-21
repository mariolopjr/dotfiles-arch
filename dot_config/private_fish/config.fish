# Source custom configs
for file in $__fish_config_dir/custom.d/*.fish
    source $file
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# User specific environment
fish_add_path ~/.local/bin
fish_add_path ~/bin

# Launch Starship prompt
if type -q starship
    starship init fish | source
end

# Launch The Fuck
if type -q thefuck
    thefuck --alias | source
end
