#!/bin/bash

# --------------------------------------------------------------------
#
# A Simple Post Installation Script for Ubuntu 14.04 "Trusty Tahr"
#
# Author: Thomas Frei
# E-mail: thomast.frei@gmail.com
#
# This script is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; version 2.
#
# This script is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <https://www.gnu.org/licenses/gpl-2.0.txt>
#
# --------------------------------------------------------------------


# Tab width
tabs 4
clear

# Variable Declaration
FULL_PATH="$(readlink -f "$0")"
USER_HOME=$(eval echo ~${SUDO_USER})
DIR="$(dirname $FULL_PATH)"
USERNAME=$(whoami)

UNINSTALL="$DIR/data/uninstall.list"
INSTALL="$DIR/data/install.list"

# Functions
notify-colored() {
    echo -e "\033[1;31m$@\033[m" 1>&2
}

echo "#-------------------------------------------#"
echo "#                                           #"
echo "#               Post-Install                #"
echo "#     For Ubuntu 14.04 Trusty Tahr          #"
echo "#                                           #"
echo "#-------------------------------------------#"
echo ""

# Update & Upgrade
notify-send  -i $DIR/data/images/notify-icon.svg -t 50 "Ubuntu Post Install" "Updating and Upgrading Your System"
notify-colored 'Requires root privileges: '
sudo apt-get update
sudo apt-get dist-upgrade -y
echo 'Performing system update...'
notify-colored 'Done.'

# Restore Privacy
notify-send -i $DIR/data/images/notify-icon.svg -t 50  "Ubuntu Post Install" "Restoring Privacy" 
echo 'Restoring Privacy'
wget -q -O - https://fixubuntu.com/fixubuntu.sh | bash 
notify-colored 'Done.'

# Remove unused Software
notify-send -i $DIR/data/images/notify-icon.svg -t 50  "Ubuntu Post Install" "Uninstalling Unneeded Packages" 
echo 'Uninstalling Crap'
sudo apt-get purge -y $(cat $UNINSTALL)
notify-colored 'Done.'

# Add PPA's
sudo add-apt-repository ppa:numix/ppa -y
sudo add-apt-repository ppa:moka/stable -y
sudo add-apt-repository ppa:webupd8team/brackets -y
sudo add-apt-repository ppa:webupd8team/sublime-text-3 -y

sudo apt-get update

# Install Software
notify-send -i $DIR/data/images/notify-icon.svg -t 50  "Ubuntu Post Install" "Installing Packages" 
sudo apt-get install -y $(cat $INSTALL)
notify-colored 'Done.'

notify-send -i $DIR/data/images/notify-icon.svg -t 50  "Ubuntu Post Install" "Installing Google Chrome" 
if [ $(uname -i) = 'i386' ]; then
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
elif [ $(uname -i) = 'x86_64' ]; then
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
fi
sudo dpkg -i google*.deb
rm google*.deb
notify-colored 'Done.'

sudo npm install bower
sudo gem install compass
sudo gem install sass

sudo rm -f -R node_modules

sudo chown -R $USERNAME:www-data /var/www/
sudo chmod -R 705 /var/www/

notify-send -i $DIR/data/images/notify-icon.svg -t 50  "Ubuntu Post Install" "Installing Numix Theme" 
sudo apt-get install -y numix-gtk-theme
notify-colored 'Done.'

notify-send -i $DIR/data/images/notify-icon.svg -t 50  "Ubuntu Post Install" "Installing Moka Icons" 
sudo apt-get install -y moka-icon-theme
notify-colored 'Done.'

notify-send -i $DIR/data/images/notify-icon.svg -t 50  "Ubuntu Post Install" "Installing Solarized Terminal" 
cd 
wget --no-check-certificate https://raw.github.com/seebi/dircolors-solarized/master/dircolors.ansi-dark
sudo mv dircolors.ansi-dark .dircolors
eval `dircolors ~/.dircolors`
git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized
./set_dark.sh
cd && rm -rf gnome-terminal-colors-solarized
wget --no-check-certificate https://raw.github.com/mukashi/solarized/master/gedit-colors-solarized/solarized_dark.xml
sudo mv solarized_dark.xml /usr/share/gtksourceview-3.0/styles/
notify-colored 'Done.'

# Move Wallpaper to User Home
sudo mkdir $USER_HOME/Pictures/Wallpapers
sudo mv $DIR/data/images/Wallpaper.jpg $USER_HOME/Pictures/Wallpapers

# Settings
gsettings set org.gnome.desktop.interface gtk-theme "Numix Daily"
gsettings set org.gnome.desktop.wm.preferences theme "Numix Daily"
gsettings set org.gnome.desktop.interface icon-theme "Moka"
gsettings set org.gnome.gedit.preferences.editor scheme 'solarized_dark'
gsettings set org.gnome.gedit.preferences.editor scheme 'solarized_dark'
gsettings set org.gnome.desktop.background picture-uri "file:///${USER_HOME}/Pictures/Wallpapers/wallpaper.jpg"
gsettings set com.canonical.unity-greeter background "file:///${USER_HOME}/Pictures/Wallpapers/wallpaper.jpg"
gsettings set org.gnome.desktop.interface text-scaling-factor 0.875
org.gnome.desktop.interface cursor-size 21

notify-send -i $DIR/data/images/notify-icon.svg -t 50 "Ubuntu Post Install" "Changing applications on Unity launcher..."
gsettings set com.canonical.Unity.Launcher favorites "['application://firefox.desktop','application://google-chrome.desktop','application://brackets.desktop','application://sublime-text.desktop','application://gedit.desktop','application://filezilla.desktop','application://vlc.desktop','application://deluge.desktop','application://nautilus.desktop','application://gnome-terminal.desktop','application://google-chrome.desktop','application://unity-control-center.desktop','unity://running-apps','unity://expo-icon','unity://devices']"

notify-send -i $DIR/data/images/notify-icon.svg -t 50 "Ubuntu Post Install" "Cleaning up.."
sudo apt-get autoremove -y
sudo apt-get clean -y
sudo apt-get purge -y

read -p "Press [Enter] key to reboot your system..."
notify-send -i $DIR/data/images/notify-icon.svg -t 50  "Ubuntu Post Install" "May the Force be with you..."
sleep 2
sudo reboot
