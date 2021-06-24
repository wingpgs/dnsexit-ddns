#!/bin/bash
set -u

# dnsexit ddns rewrite
# APIKEY and DOMAIN should change for yours.

APIKEY="<your apikey>"
DOMAIN="<your domain>"
GET_IP_URL="https://api.ipify.org/"
timestamp=`date +%Y-%m-%d\(%H:%M:%S\)`

# location of .sh file
DIR="$( cd "$( dirname "$0" )" && pwd -P )"

# get current ip address
current_ip="$(curl -s "$GET_IP_URL")"

if [ -z "$current_ip" ]; then
    echo "Could not get current IP address." 1>&2
    exit 1
fi

# delete if update.json file exists.
if [ -e "$DIR"/update.json ]; then
    rm -rf "$DIR"/update.json
fi

echo "{">"$DIR"/update.json
echo "   \"apikey\": \"$APIKEY\",">>"$DIR"/update.json
echo "   \"domain\": \"$DOMAIN\",">>"$DIR"/update.json
echo "   \"update\": {">>"$DIR"/update.json
echo "      \"type\": \"A\",">>"$DIR"/update.json
echo "      \"name\": \"$DOMAIN\",">>"$DIR"/update.json
echo "      \"content\": \"$current_ip\",">>"$DIR"/update.json
echo "      \"ttl\": 2">>"$DIR"/update.json
echo "   }">>"$DIR"/update.json
echo "}">>"$DIR"/update.json


echo "Update $current_ip to domain($DOMAIN)"
updateResult=$(curl -H "Content-Type: application/json" \
                    --data @"$DIR"/update.json \
                    https://api.dnsexit.com/dns/ 2>&1)


if ! echo "$updateResult" | grep -q "\"message\":\"Success\""; then
    echo "Update failed." 1>&2
    echo "$timestamp Update failed." >> "$DIR"/logs
    exit 1
else
    echo "Update Success."
    echo "$timestamp Update Success." >> "$DIR"/logs
    exit 0
fi
