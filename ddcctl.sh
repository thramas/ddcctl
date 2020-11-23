#!/bin/bash
#tweak OSX display monitors' brightness to a given scheme, increment, or based on the current local time

#TODO: toggle for overriding timeline behaviour, stop using fixed coordinates

#base url for api
BASE_URL="https://api.sunrise-sunset.org/json?"
#default contrast settings
VL_C=5
L_C=10
M_C=25
H_C=40
VH_C=60

#default brigthness settings
VL_B=5
L_B=10
M_B=25
H_B=40
VH_B=60

#default sunsrise and sunset values
SUNR=5
SUNS=17

#confirming jq installation
jq_path=$(which jq)
if [ -z "$jq_path" ]
then
    brew install jq
else
    echo "jq already present at: ${jq_path}"
fi

#confirming awk installation
awk_path=$(which awk)
if [ -z "$awk_path" ]
then
    brew install awk
else
    echo "awk already present at: ${awk_path}"
fi

#latitude and longitude
LAT=36.721600
LNG=-4.4203400
DAYLIGHT_API="${BASE_URL}lat=${LAT}&lng=${LNG}"

#default values for sunset and sunrise
sunrise=$((SUNR))
sunset=$((SUNS))

# API CALL FOR SUNRISE AND SUNSET TIMINGS
sdata=$(curl -s $DAYLIGHT_API)
sts=$(echo $(echo $sdata | jq '.status') | awk '{print substr($0,2,2);}')
echo $sts
if [ "$sts" = "OK" ];
then
    echo "received 200OK for api:${DAYLIGHT_API}"
    sunrise=$(echo $sdata | jq '.results.sunrise')
    sunset=$(echo $sdata | jq '.results.sunset')
    tzsr=$(echo $(echo ${sunrise} | awk -F: '{print $3}') | awk '{print substr($0, 4,2);}')
    tzss=$(echo $(echo ${sunset} | awk -F: '{print $3}') | awk '{print substr($0, 4,2);}')
    sunrise=$(echo $(echo ${sunrise} | awk -F: '{print $1}') | awk '{print substr($0, 2);}')
    sunset=$(echo $(echo ${sunset} | awk -F: '{print $1}') | awk '{print substr($0, 2);}')
    sunrise=$(($sunrise))

    #ADJUSTING FOR AM/PM BULLSHIT IN THE RESPONSE
    if [ $tzsr == "PM" ];
    then
        sunrise=$((($sunrise+12)%24))
    fi
    
    if [ $tzss == "PM" ];
    then
        sunset=$((($sunset+12)%24))
    fi
else
    echo "Using default values"
fi

#echo ${sunrise}
#echo ${sunset}
#exit 1

#hour settings based upon api data
DAY=$(($sunrise))
NIGHT=$(($sunset))
MID=$(($DAY + ($NIGHT-$DAY)/2))
POST_NIGHT=$(($sunset+4))

echo "day: $DAY"
echo "mid: $MID"
echo "night: $NIGHT"
echo "pnight: $POST_NIGHT"

dim() {
	./ddcctl -d 1 -b $L_B -c $L_C
}

bright() {
	./ddcctl -d 1 -b $M_B -c $M_C
}

vbright() {
        ./ddcctl -d 1 -b $H_B -c $H_C
}

up() {
	./ddcctl -d 1 -b 20+ -c 12+
}

down() {
	./ddcctl -d 1 -b 20- -c 12-
}

full() {
        ./ddcctl -d 1 -b $VH_B -c $VH_C
}

dark() {
        ./ddcctl -d 1 -b $VL_B -c $VL_C
}


HM=$(date +"%H:%M")
HoD=$(echo $(echo $HM) | cut -d':' -f1)
MoH=$(echo $(echo $HM) | cut -d':' -f2) 

#echo $HoD
if [ $HoD -lt $DAY ]
then
   dark
elif [ $HoD -ge $DAY ] && [ $HoD -lt $MID ]
then
   vbright
elif [ $HoD -ge $MID ]  && [ $HoD -lt $NIGHT ]
then
   bright
elif [ $HoD -ge $NIGHT ] && [ $HoD -lt $POST_NIGHT ]
then
   dim
else
   dark
fi
