#!/usr/bin/env bash

lock=" Lock"
suspend=" Suspend"
logout=" Logout"
reboot=" Reboot"
shutdown=" Shutdown"

selection=$(printf "$lock\\n$suspend\\n$logout\\n$reboot\\n$shutdown" | fuzzel --dmenu -p "Power: ")

case "$selection" in
	"$lock") swaylock ;;
	"$suspend") systemctl suspend ;;
	"$logout") niri msg action quit ;;
	"$reboot") systemctl reboot ;;
	"$shutdown") systemctl poweroff ;;
esac

