#!/usr/bin/bash
git clone https://github.com/Pear-Project/pearOS-Default-Launchpad
cd pearOS-Default-Launchpad
/usr/bin/mkdir -p /usr/share/plasma/plasmoids/pearOSLaunchpad
/usr/bin/cp -r ./ /usr/share/plasma/plasmoids/pearOSLaunchpad/
