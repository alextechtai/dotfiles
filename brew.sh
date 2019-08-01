###############################################################################
# File: brew.sh
# Author: Alex Tai
# Description: Installing apps
###############################################################################

#!/usr/bin/env bash

set +e
set -x

# Check if Homebrew is installed
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi


echo "Installing applications ..."
