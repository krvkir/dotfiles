#!/bin/sh
# setkeycodes e006 185
# setkeycodes e007 186

[ -f /etc/xprofile ] && source /etc/xprofile
[ -f ~/.xprofile ] && source ~/.xprofile
[ -f ~/.Xresources ] && xrdb ~/.Xresources

session=${1:-i3}

case $session in
    gnome) exec gnome-shell;;
    e17) exec enlightenment_start;;
    unity) exec unity --verbose;;
    i3)
	xbindkeys
    	autocutsel -fork &
    	autocutsel -selection PRIMARY -fork &
	#exec udiskie & fbxkb & i3-gnome
	exec udiskie & i3
	;;
    *) exec $1;;
esac    

