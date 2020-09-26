#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode
set -euo pipefail
IFS=$'\n\t'

mkdir /tmp

# rclone stuff
RCI_SCRIPT="rclone_installer_script.sh"
RCI_URI="https://rclone.org/install.sh"

# aria2 stuff
ARI_SCRIPT="aria2_installer_script.sh"
ARI_URI="https://raw.githubusercontent.com/P3TERX/aria2-builder/master/aria2-install.sh"

# installing rclone 
RCLONE() {
	curl -fsSLo $RCI_SCRIPT $RCI_URI
	chmod +x $RCI_SCRIPT
	echo "Installing rclone..."
	./$RCI_SCRIPT &>/dev/null
	echo "Done! Installed $(rclone version | head -n 1)"
}

# installing aria2
# https://github.com/P3TERX/aria2-builder
ARIA2() {
	curl -fsSLo $ARI_SCRIPT $ARI_URI
	chmod +x $ARI_SCRIPT
	echo "Installing aria2..."
	./$ARI_SCRIPT &>/dev/null
	echo "Done! Installed $(aria2c --version | head -n 1 | cut -d " " -f1,3)"
}

# install pip packages
PIP() {
	echo "Installing pip packages..."
	pip3 install -q --no-cache-dir -r requirements.txt
	echo "Done! Installed packages are.."
	pip3 freeze
}

# cleanup
CLEAN() {
	echo "Cleaning external scripts..."
	rm -rf $RCI_SCRIPT $ARI_SCRIPT /tmp/
	echo "Done! Cleaned all"
}

RCLONE
ARIA2
PIP
CLEAN
