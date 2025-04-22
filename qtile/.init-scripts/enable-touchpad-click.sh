# !/bin/bash

deviceId=$(xinput | grep ^.*Touchpad | sed 's/.+id=//' | awk '{print $4, $5}' | sed 's/[a-zA-Z=\ \[]//g')
clickPropId=$(xinput list-props $deviceId | grep Tapping\ Enabled\ \( | cut -d '(' -f 2 | cut -d ')' -f 1)
xinput set-prop $deviceId $clickPropId 1
