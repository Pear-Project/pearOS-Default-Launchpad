# Default pearOS Launchpad Menu
Features macOS style of Launchpad, easy way to open and launch your favourite apps.

## Screenshots
<i>comin' soon</i>

## Features
* macOS Style launchpad
* cool icon (thanks to [pearOS Icon Pack](github.com/Pear-Project/pearOS-Default-Icons))
* works pretty well

## Cons
* the launchpad is OVER the latte-dock (meaning that the dock is <b><i>not</i></b> visible while Launchpad is opened

## How to install
* automated way:
```sh
git clone https://github.com/Pear-Project/pearOS-Default-Launchpad
cd pearOS-Default-Launchpad
./install.sh
```

* manual way:
```sh
#!/usr/bin/bash
git clone https://github.com/Pear-Project/pearOS-Default-Launchpad
cd pearOS-Default-Launchpad
mkdir -p ~/.local/share/plasma/plasmoids/pearOSLaunchpad
cp -r ./* ~/.local/share/plasma/plasmoids/pearOSLaunchpad/
```

## Copyright
* Original code is by [adhec](https://github.com/adhec), released under the GNU General Public License V2+
* Modified code, as well as the installer script, together forming the pearOS-Default-Launchpad package, is released under the GNU General Public License V3.
* Install script by Alexandru Balan, designed for pearOS, part of the Pear-Project (c) 2019-2021
