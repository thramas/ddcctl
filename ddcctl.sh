#!/bin/bash
#tweak OSX display monitors' brightness to a given scheme, increment, or based on the current local time

#dell="./ddcctl -d 1"
#len="./ddcctl -d 2"
# TODO : Automate night and day figures based on sunrise and sunset time https://api.sunrise-sunset.org/json?lat=36.7201600&lng=-4.4203400

dim() {
	./ddcctl -d 1 -b 10 -c 10
}

bright() {
	./ddcctl -d 1 -b 50 -c 50
}

up() {
	./ddcctl -d 1 -b 20+ -c 12+
}

down() {
	./ddcctl -d 1 -b 20- -c 12-
}

case "$1" in
	dim|bright|up|down) $1;;
	*)	#no scheme given, match local Hour of Day
		#HoD=$(date +%k) #hour of day
                HM=$(date +"%H:%M")
                HoD=$(echo $HM) | cut -d':' -f1
                MoH=$(echo $HM) | cut -d':' -f2
		let "night = (( $HoD < 7 || $HoD > 18 ))" #daytime is 7a-7p
		(($night)) && dim || bright
		;;
esac
