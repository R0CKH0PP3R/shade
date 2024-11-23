#!/bin/bash
# DDC Brightness control for display panels without a backlight.
# Autostart without args & use DE to set appropriate up/dn keybinds.

SHADE="/var/tmp/shade"
XT=3000 # milliseconds
NOW=$(date +%s%3N)

notify(){
    # Update rather then spam successive notifications by capturing their ID.
    if [[ -z $TIME ]] || [[ $TIME -lt $(($NOW-$XT)) ]]; then
        NID=$(notify-send "Brightness changed to ${1}%" -p --expire-time=${XT})
    else
        notify-send -r $NID "Brightness changed to ${1}%" --expire-time=${XT}
    fi
    echo -e "BUS=${BUS}\nBRIGHTNESS=${1}\nNID=${NID}\nTIME=${NOW}" > $SHADE
}

setvcp(){
    # Change the brightness
    [[ $1 -lt 0 ]] && set -- 0
    [[ $1 -gt 100 ]] && set -- 100
    # Everything after $1 is monitor/performance specific & totally optional.
    ddcutil setvcp 10 $1 --bus $BUS --skip-ddc-checks --noverify
    [[ $? -eq 0 ]] && notify $1
}

round10(){
    # Round number to nearest 10
    echo $(( ((${1%.*}+5)/10)*10 ))
}

init(){
    # Get/set current brightness
    if [[ -f $SHADE ]]; then
        source $SHADE
    else 
        BUS=$(ddcutil detect | grep bus | cut -d '-' -f 2)
        BRIGHTNESS=$(ddcutil getvcp 10 | awk '{print $9}' | sed 's/[^0-9]*//g')
        BRIGHTNESS=$(round10 $BRIGHTNESS)
    fi
}

# If no args, get current brightness & write to tmp.
# If up/dn, then adjust accordingly. If a number, then set that number.
if [[ "$#" -ne 1 ]]; then 
    init && echo "Brightness initialised."
else
    if [[ "$1" == "up" ]]; then init && setvcp $((BRIGHTNESS+10))
    elif [[ "$1" == "dn" ]]; then init && setvcp $((BRIGHTNESS-10))
    elif [[ "$1" == "$1" ]]; then init && setvcp $1
    fi
fi

exit 0
