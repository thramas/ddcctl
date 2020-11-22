#!/bin/bash
#tweak OSX display monitors' brightness to a given scheme, increment, or based on the current local time

#dell="./ddcctl -d 1"
#len="./ddcctl -d 2"
# TODO : Automate night and day figures based on sunrise and sunset time https://api.sunrise-sunset.org/json?lat=36.7201600&lng=-4.4203400
#TODO: Enable boolean toggle on/off for settings

dim() {
	./ddcctl -d 1 -b 10 -c 10
}

bright() {
	./ddcctl -d 1 -b 40 -c 40
}

up() {
	./ddcctl -d 1 -b 20+ -c 12+
}

down() {
	./ddcctl -d 1 -b 20- -c 12-
}

full() {
        ./ddcctl -d 1 -b 50 -c 50
}

DAY=6
MID=12
NIGHT=18

HM=$(date +"%H:%M")
HoD=$(echo $(echo $HM) | cut -d':' -f1)
MoH=$(echo $(echo $HM) | cut -d':' -f2) 

echo $HoD
if [ $HoD -lt $DAY ]
then
   dim
elif [ $HoD -ge $DAY ] && [ $HoD -lt $MID ]
then
   full
elif [ $HoD -ge $MID ]  && [ $HoD -lt $NIGHT ]
then
   bright
else
   dim
fi
