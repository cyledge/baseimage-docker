#!/bin/bash
set -o pipefail

red='\e[1;31m' # Red
green='\e[0;32m' # Green
reset='\e[0m'    # Text Reset

services_okay=0
for s in /etc/service/*; do

  service_name=$(basename $s)
  service_status=$(sv status $s)
  result=$?
  if [[ "$result" != 0 || "$service_status" = "" || "$service_status" =~ down ]]; then
	  echo -e "     Service $service_name: ${red}FAIL${reset}"
	  services_okay=1
  else
	  echo -e "     Service $service_name: ${green}OKAY${reset}"
  fi
  
done
if [ "$services_okay" != "0" ]; then
  exit 1
fi
