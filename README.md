# My dotfiles
So many people provided inspiration, I wouldn't even know where to begin. Just know that I'm good at copy/paste and most of the stuff in here came from someone smarter than me.

## Note
Don't blindly run the install.sh file. Geek out and learn how it all works.

## install.sh
You can run this and it will show you usage info. It can be run fully automated, or just in portions.

## etc/Brewfile
In the etc folder there's a Brewfile. Open this up. After brew is installed you could run this whole thing by being in that directory and running "brew bundle" – it will automatically install all that stuff. Or you can manually run "brew install vim". One thing to note is that "brew install" will install cli binary type things (vim, curl, etc).  Cask installs applications. So for firefox, you'd run "brew cask install firefox"

## home/.dotfiles
In the "home" directory of the repo is where the .bash_profile etc are. My install script symlinks all these files to $HOME so that you can keep everything source controlled. 

Start with .bash_profile and start working your way down - you'll see that it includes some other dotfiles (.path, .bash_prompt, etc). Explore each one to see aliases, functions, etc.

## etc/macos.sh
This is kind of a geeky power user thing. Here I set a bunch of settings for the Mac that I prefer. Most of these can be done through the GUI as well, but I stumbled across this on another person's site and was hooked.
