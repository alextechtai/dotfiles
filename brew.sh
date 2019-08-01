###############################################################################
# File: brew.sh
# Author: Alex Tai
# Description: Installing apps
###############################################################################

#!/usr/bin/env bash

set +e
set -x

###############################################################################
# Pregame!!!
###############################################################################

pre_casks=(
  google-chrome
  dropbox
  spotify
  slack
)

brews=(
  git
  python
  python3
  tree
)

casks=(
  geekbench
  google-backup-and-sync
  handbrake
  transmission
  skype
  atom
  sketch
  1password
  gitkraken
  appcleaner
  iterm2
)

###############################################################################
# Start brewing
###############################################################################

function install {
  cmd=$1
  shift
  for pkg in "$@";
  do
    exec="$cmd $pkg"
    #prompt "Execute: $exec"
    if ${exec} ; then
      echo "Installed $pkg"
    else
      echo "Failed to execute: $exec"
      if [[ ! -z "${CI}" ]]; then
        exit 1
      fi
    fi
  done
}

function brew_install_or_upgrade {
  if brew ls --versions "$1" >/dev/null; then
    if (brew outdated | grep "$1" > /dev/null); then
      echo "Upgrading already installed package $1 ..."
      brew upgrade "$1"
    else
      echo "Latest $1 is already installed"
    fi
  else
    brew install "$1"
  fi
}

if [[ -z "${CI}" ]]; then
  # Ask for the administrator password upfront
  sudo -v
  # Keep-alive: update existing `sudo` time stamp until script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

if test ! "$(command -v brew)"; then
  prompt "Install Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  if [[ -z "${CI}" ]]; then
    prompt "Update Homebrew"
    brew update
    brew upgrade
    brew doctor
  fi
fi
export HOMEBREW_NO_AUTO_UPDATE=1

echo "Install important software ..."
brew tap caskroom/versions
install 'brew cask install' "${pre_casks[@]}"

prompt "Install packages"
install 'brew_install_or_upgrade' "${brews[@]}"
brew link --overwrite ruby

prompt "Install software"
install 'brew cask install' "${casks[@]}"

if [[ -z "${CI}" ]]; then
  prompt "Install software from App Store"
  mas list
fi

prompt "Cleanup"
brew cleanup
brew cask cleanup

echo "Done!"
