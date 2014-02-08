#!/bin/sh
# setkeycodes e006 185
# setkeycodes e007 186
setkeycodes e006 104
setkeycodes e007 109

setxkbmap -layout "us,ru" -option "grp:lwin_toggle,grp_led:num,caps:hyper"
xrdb ~/.Xresources

session=${1:-i3}

case $session in
    gnome) exec gnome-shell;;
    e17) exec enlightenment_start;;
    i3)
	xbindkeys
    	autocutsel -fork &
    	autocutsel -selection PRIMARY -fork &
	exec udiskie & fbxkb & i3-gnome
	#exec udiskie & i3
	;;
    *) exec $1;;
esac    

