#!/usr/bin/env bash
set -e

# Print a help message.
usage() { 
  printf "%s\n Usage: $0 [ -s SERVICE (mandatory) ] [ -i IMAGE (mandatory) ] [ -p PORT (mandatory) ] [ -h HOST (interpreted from service if not provided) ] [ -d DOMAIN ] %s\n\n" 1>&2 
}

# Function: Exit with error.
exit_abnormal() {
    usage
    exit 1
}

[[ $1 == "--help" || $1 == "help" || ! $1 ]] && usage && exit 0
if [[ "$*" != *"-s"* || "$*" != *"-i"* || "$*" != *"-p"* ]]; then
      exit_abnormal
fi

while getopts "s:i:h:p:d:" opt
do
    case ${opt} in
	# Service Flag
	s)
	  mkdir /etc/traefik/"${OPTARG}"
	  WORKDIR="/etc/traefik/${OPTARG}"
	  cp /etc/traefik/bootstrap/.env "$WORKDIR/.env"
	  cp /etc/traefik/bootstrap/dc-template.yml "$WORKDIR/docker-compose.yml"
	  sed -i "s/svc/${OPTARG}/g" "$WORKDIR/.env"
	  [[ "$*" != *"-h"* ]] && sed -i "s/hst/${OPTARG}/g" "$WORKDIR/.env"
	  sed -i "s/replaceme/${OPTARG}/g" "$WORKDIR/docker-compose.yml"
	;;
	# Image Flag
	i)
	  sed -i "s|img|$OPTARG|g" "$WORKDIR/.env"
	;;
    	# Host Flag
	h)
	  sed -i "s|hst|${OPTARG}|g" "$WORKDIR/.env"
	;;
    	# Port Flag
	p)
	  sed -i "s|prt|${OPTARG}|g" "$WORKDIR/.env"
	;;
	# Domain Flag
	d)
	  sed -i "s|\"'$(dnsdomainname)'\"|${OPTARG}|g" "$WORKDIR/.env"
	;;
	:)
          echo "Error: -${OPTARG} requires an argument."
          exit_abnormal
        ;;
        *)
          exit_abnormal
        ;;
    esac
done

printf "%s\n Manually add: %s\n - any necessary non-GUI ports > $WORKDIR/docker-compose.yml %s\n - any environment variables > $WORKDIR/.env %s\n - IP & url to local DNS Records %s\n\n"
