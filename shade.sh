#!/bin/bash
# DDC Brightness control for display panels without a backlight.
# Autostart without args & use DE to set appropriate up/dn keybinds.

SHADE="/var/tmp/shade"

notify(){
    # Update rather then spam successive notifications by capturing their ID.
    if [[ -z $NID ]]; then
        NID=$(notify-send "Brightness changed to ${1}%" -p --expire-time=3000)
    else
        notify-send -r $NID "Brightness changed to ${1}%" --expire-time=3000
    fi
    echo -e "BRIGHTNESS=${1}\nNID=${NID}" > $SHADE
}

setvcp(){
    # Change the brightness
    [[ $1 -lt 0 ]] && set -- 0
    ddcutil setvcp 10 $1
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
        BRIGHTNESS=$(ddcutil getvcp 10 | awk '{print $9}' | sed 's/[^0-9]*//g')
        BRIGHTNESS=$(round10 $BRIGHTNESS)
        echo "BRIGHTNESS=${BRIGHTNESS}" > $SHADE
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
