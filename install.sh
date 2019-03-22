#!/usr/bin/env bash

# Set your locations
dev="$HOME/dev"
dotfiles="$dev/dotfiles"
editor=$EDITOR; editor="code" # doing it this way because I need the reminder that $EDITOR is a thing that people might like


help () {
  cat << HELP
  USAGE: $(basename $0) [OPTIONS]..

  OPTIONS:
     --symlink|-s   Only symlink files
        --brew|-b   Only run brew setup
        --full|-f   Full install, symlink files, brew setup, etc
        --open|-o   Open the dotfiles folder for editing
HELP
}

do_symlinks () {  
  if [[ -d "$dotfiles" ]]; then
    echo "Symlinking dotfiles from $dotfiles"
  else
    echo "$dotfiles does not exist"
    exit 1
  fi

  link() {
    from="$1"
    to="$2"
    echo "Linking '$from' to '$to'"
    rm -f "$to"
    ln -s "$from" "$to"
  }

  for location in $(find $dotfiles/home -maxdepth 1 -name '.*'); do
    file="${location##*/}"
    file="${file%.sh}"
    link "$location" "$HOME/$file"
  done

  #link ".ssh/config" "$HOME/.ssh/config"

  echo ""
  echo "Done symlinking"
  echo ""
}

do_brew () {
  # Ask for the administrator password upfront
  sudo -v

  # sudo keep-alive
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


  ### BEGIN BREW SETUP ######################################################

  # Install Homebrew if not installed
  if ! which brew > /dev/null; then /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; fi;

  # Exit if it failed to install
  [[ ! "$(type -P brew)" ]] && e_error "Homebrew failed to install." && return 1

  # Disable Brew analytics
  brew analytics off

  # Homebrew now includes cask, so let's get rid of the old version
  brew uninstall --force brew-cask

  # brew update -- updates local base of available packages and versions, to know what is updateable
  brew update

  # brew upgrade -- actually installs new versions of outdated packages
  brew upgrade

  # Save Homebrew’s installed location
  BREW_PREFIX=$(brew --prefix)


  ### END BREW SETUP ########################################################

  # Install from Brewfile
  brew bundle --file=$dotfiles/etc/Brewfile

  # Switch to using brew-installed bash as default shell
  BREW_PREFIX=$(brew --prefix); if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells; chsh -s "${BREW_PREFIX}/bin/bash"; fi;

  # Use brewed git
  brew link git --overwrite

  # Config git (get osxkeychain credential)
  curl -s -O https://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain; chmod u+x git-credential-osxkeychain; sudo mv git-credential-osxkeychain "$(dirname $(which git))/git-credential-osxkeychain"; git config --global credential.helper osxkeychain

  # Check for SSH key, generate if not exist
  # - command: pub=$HOME/.ssh/id_rsa.pub; if [ ! -f $pub ] ; then ssh-keygen -t rsa; echo 'Copying public key to clipboard. Paste it into your Github account...'; cat $pub | pbcopy; open 'https://github.com/account/ssh'; fi
  #   description: Checking for SSH key, generating one if it does not exist...

  # Pip installs
  #pip install requests python-openstackclient pygments pydf

  # brew cleanup -s -- by default, brew keeps all versions of the software. This keeps only linked versions (by default, the last)
  brew cleanup -s

  # brew doctor -- check systems for potential problems
  # - [ brew doctor, Doctoring Brew ]

  # brew missing -- check all installed brews for missing dependencies
  brew missing

  echo ""
  echo "Done brewing"
  echo ""
}

do_full () {
  do_symlinks
  do_brew
  echo ""
  echo "Full setup complete!"
  echo ""
}

error () {
  printf "$(tput setab 1; tput setaf 7)[!] %b$(tput sgr0)\n" "$@" 1>&2
}

confirm () {
  while true; do
    read -p "$(tput setab 6; tput setaf 7)[?]$(tput sgr0) $@ Continue? [y/N] " reply
    if [ -z $reply ]; then
      reply="no"
    fi

    case "$reply" in
      Y|y|YES|yes|Yes)
        return 0
      ;;
      *)
        return 1
      ;;
    esac
    unset reply
  done
}

open_it() {
  $editor "$dotfiles"
}

check_arg() {
  if [ -z "$1" ]; then
    error "$2 expected value"
    exit 1
  fi

  if [[ "$1" =~ ^- ]]; then
    error "$2 expected value"
    exit 1
  fi
}

parse_args () {
  while [ ! -z "$1" ]; do
    case "$1" in

      --symlink|-s )
        symlink=1
        shift
      ;;

      --brew|-b )
        brew=1
        shift
      ;;

      --full|-f )
        full=1
        shift
      ;;

      --open|-o )
        open=1
        shift
      ;;

      * )
        error "$1 not recognized as a command"
        exit 1
      ;;

    esac
  done

  if [ ! -z $symlink ] && [ $symlink -eq 1 ]; then
    if confirm "Ready to create symlinks..."; then
      do_symlinks
    else
      printf "\nYeah, that's right. Run away puny mortal.\n\n"
    fi
    exit 0
  fi

  if [ ! -z $brew ] && [ $brew -eq 1 ]; then
    if confirm "Ready to run brew commands..."; then
      do_brew
    else
      printf "\nYeah, that's right. Run away puny mortal.\n\n"
    fi
    exit 0
  fi

  if [ ! -z $full ] && [ $full -eq 1 ]; then
    if confirm "Ready to create symlinks and run brew commands..."; then
      do_full
    else
      printf "\nYeah, that's right. Run away puny mortal.\n\n"
    fi
    exit 0
  fi

  if [ ! -z $open ] && [ $open -eq 1 ]; then
    open_it
    exit 0
  fi


}

main () {
  if [ -z $1 ] || [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    help
    exit 1
  fi

  parse_args "$@"
}

main "$@"


