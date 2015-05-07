#!/bin/bash
# Source: http://unix.stackexchange.com/questions/4489/a-tool-for-automatically-applying-randr-configuration-when-external-display-is-p

# Second monitor
INTERNAL="LVDS1"
EXTERNAL="VGA1"

# Current monitor
MONITOR=$INTERNAL

# Creating mode
# if ! xrandr | grep "1920x1080" && ! xrandr | grep "1080p21"; then
if ! xrandr | grep "1080p21" && ! xrandr | grep "1080p21"; then
    xrandr --newmode "1080p21" 178.72 1920 2040 2248 2576  1080 1081 1084 1119  -HSync +Vsync
    xrandr --addmode $EXTERNAL "1080p21"
fi


# functions to switch from LVDS1 to VGA and vice versa
function ActivateVGA {
    echo "Switching to EXTERNAL"
    # xrandr --output $EXTERNAL --mode 1920x1080 --dpi 160 --output $INTERNAL --off
    xrandr --output $EXTERNAL --mode 1080p21 --dpi 160 --output $INTERNAL --off
    # xrandr --output $INTERNAL --pos 0x0 --output $EXTERNAL --mode 1080p21 --pos 1280x0 --primary
    MONITOR=$EXTERNAL
}
function DeactivateVGA {
    echo "Switching to INTERNAL"
    # switching monitor
    xrandr --output $EXTERNAL --off --output $INTERNAL --auto
    # starting touchegg if needed
    test `ps x | grep touchegg | wc -l` == 1 && touchegg-wrapper &
    MONITOR=$INTERNAL
}

# functions to check if VGA is connected and in use
function VGAActive {
    test $MONITOR == $EXTERNAL
}
function VGAConnected {
    ! xrandr | grep "^$EXTERNAL" | grep disconnected
}


# Running in loop to catch connections
while true; do
    if ! VGAActive && VGAConnected; then
        ActivateVGA
    fi

    if VGAActive && ! VGAConnected; then
        DeactivateVGA
    fi

    sleep 1s
done
