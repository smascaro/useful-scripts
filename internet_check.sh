#!/bin/bash

connection_ok=true
if ! $connection_ok; then
	echo "Jackpot!"
fi

while true ; do

	ping=NOK ; debug= ; 
	value=9.9.9.9 ; 
	if ping -q -c 1 -W 2000 $value > /dev/null 2>&1; then ping=OK ; else ping=NOK ; fi
		if ping=="NOK" ;then
			value=8.8.8.8 ; 
			if ping -q -c 1 -W 2000 $value > /dev/null 2>&1; then ping=OK ; else ping=NOK ; fi
		fi


	if [ "$ping" != "OK" ]; then 
		if ! $connection_ok ; then
			echo "Still no internet at $(date +%T)"
		else 
			echo "No internet !!! Connection broke at $(date +%T)"; 
		fi
		connection_ok=false
	else 
		if ! $connection_ok ; then
			echo "Internet connection RESTORED at $(date +%T)" ; 
		else
			echo "Internet connection is $ping (result given by $value DNS server)." ; 
		fi
		connection_ok=true
	fi
	sleep 1
done
