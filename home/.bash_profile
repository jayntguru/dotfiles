#!/usr/bin/env bash

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
source "$HOME/.path"
source "$HOME/.bash_prompt"
source "$HOME/.exports"
source "$HOME/.aliases"
source "$HOME/.functions"
source "$HOME/.hstr"
source "$HOME/.oclogins"

## Load z if installed
#if [ -e /usr/local/etc/profile.d/z.sh ]; then source /usr/local/etc/profile.d/z.sh; fi

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
  source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion;
fi;

# Add docker bash completion if Docker.app is installed
if [ -d "/Applications/Docker.app" ]; then
  ln -sfn /Applications/Docker.app/Contents/Resources/etc/docker.bash-completion $(brew --prefix)/etc/bash_completion.d/docker
  ln -sfn /Applications/Docker.app/Contents/Resources/etc/docker-machine.bash-completion $(brew --prefix)/etc/bash_completion.d/docker-machine
  ln -sfn /Applications/Docker.app/Contents/Resources/etc/docker-compose.bash-completion $(brew --prefix)/etc/bash_completion.d/docker-compose
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Default to TMUX config - uncomment this line to always start in tmux
(tmux ls | grep -vq attached && tmux at) || tmux

