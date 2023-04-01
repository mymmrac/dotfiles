#!/usr/bin/bash

set -eu

echo -e "==== Start: Touchpad Setting ====\n"

sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf >/dev/null <<EOM
Section "InputClass"
    Identifier "Touchpads"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
EndSection
EOM

echo -e "\n==== End: Touchpad Setting ===="
