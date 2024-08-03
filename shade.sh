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
    echo -e "BRIGHTNESS=${1}\nNID=${NID}\nTIME=${NOW}" > $SHADE
}

setvcp(){
    # Change the brightness
    [[ $1 -lt 0 ]] && set -- 0
    [[ $1 -gt 100 ]] && set -- 100
    # Everything after $1 is monitor/performance speciffic & totally optional.
    ddcutil setvcp 10 $1 --bus 8 --sleep-multiplier 0.1 --skip-ddc-checks --noverify
    [[ $? -eq 0 ]] && notify $1
}

round10(){
    # Round number to nearest 10
    echo $(( ((${1%.*}+5)/10)*10 ))
}

init(){
    # Get/set current brightness
    # TODO? Could get I2C bus w/ 'ddcutil detect' here...
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
