#!/bin/bash

# получаем переменные
NAME=$1
DOMAIN=$2
SERVER=$3
PORT=$4
TYPE=$5

if [[ $NAME = "" ]] || [[ $DOMAIN = "" ]]; then
    echo "{ \"data\": [ {\"error\": \"No domain\"} ] }"
    exit
fi

if [[ $SERVER = "" ]]; then SERVER=$DOMAIN; fi
if [[ $PORT = "" ]]; then PORT="443"; fi
if [[ $TYPE = "" ]]; then TYPE="web"; fi

# Подержка Internationalized Domain Names (IDN)
# apt install idn

DOMAIN=`echo $DOMAIN | idn`
SERVER=`echo $SERVER | idn`

# получение SSL
case $TYPE  in
    "ftp")
    SSL=`echo | openssl s_client -servername $DOMAIN -connect $SERVER:$PORT -tls1_2 -starttls ftp 2>/dev/null | openssl x509 -issuer -dates -subject -email -serial -fingerprint -noout -text 2>/dev/null`
    ;;
	"smtp")
    SSL=`echo | openssl s_client -servername $DOMAIN -connect $SERVER:$PORT -tls1_2 -starttls smtp 2>/dev/null | openssl x509 -issuer -dates -subject -email -serial -fingerprint -noout -text 2>/dev/null`
    ;;
    *)
    SSL=`echo | openssl s_client -servername $DOMAIN -connect $SERVER:$PORT 2>/dev/null | openssl x509 -issuer -dates -subject -email -serial -fingerprint -noout -text 2>/dev/null`
    ;;
esac
#echo "$SSL"

# парсинг данных
if [[ $SSL = "" ]]; then
    echo "{ \"data\": [ {\"error\": \"No SSL response\"} ] }"
    exit
else
    CURRENTDATE=`LANG=en_EN TZ=GMT date +"%b %d %R:%S %Y %Z"`
    ISSUER=`echo "$SSL" | grep "issuer=" | cut -b 8- | sed 's/"/\\\"/g'`
    NOTBEFORE=`echo "$SSL" | grep "notBefore=" | cut -b 11-`
    NOTAFTER=`echo "$SSL" | grep "notAfter=" | cut -b 10-`
    VALIDNOTAFTER=`LANG=en_EN TZ=GMT date -d "$NOTAFTER" > /dev/null 2>&1; echo $?`
    DIFFDAYS=-1
    if [[ $VALIDNOTAFTER == 0 ]]; then DIFFDAYS=`LANG=en_EN TZ=GMT echo $(( ($(date -d "$NOTAFTER" +"%s")-$(date -d "$CURRENTDATE" +"%s"))/86400 ))`; fi
    SUBJECT=`echo "$SSL" | grep "subject=" | cut -b 9-`
    EMAIL=`echo "$SSL" | grep "email=" | cut -b 7-`
    SERIAL=`echo "$SSL" | grep "serial=" | cut -b 8-`
    FINGERPRINT=`echo "$SSL" | grep "SHA1 Fingerprint=" | cut -b 18-`
    VER=`echo "$SSL" | grep "Version: " | sed -e 's/^[ \t]*//' | cut -b 10-`
    ALGORITHM=`echo "$SSL" | grep -m 1 "Signature Algorithm: " | sed -e 's/^[ \t]*//' | cut -b 22-`
    PUBALGORITHM=`echo "$SSL" | grep "Public Key Algorithm: " | sed -e 's/^[ \t]*//' | cut -b 23-`
    ALT=`echo "$SSL" | grep -A 1 "Subject Alternative Name" | grep -v "Subject Alternative Name" | sed -e 's/^[ \t]*//'`
fi

# вывод данных
echo "{ \"data\": [ { "
echo "  \"name\": \"$NAME\","
echo "  \"domain\": \"$DOMAIN\","
echo "  \"server\": \"$SERVER\","
echo "  \"port\": \"$PORT\","
echo "  \"type\": \"$TYPE\","
echo "  \"issuer\": \"$ISSUER\","
echo "  \"notBefore\": \"$NOTBEFORE\","
echo "  \"notAfter\": \"$NOTAFTER\","
echo "  \"subject\": \"$SUBJECT\","
echo "  \"email\": \"$EMAIL\","
echo "  \"serial\": \"$SERIAL\","
echo "  \"fingerprint\": \"$FINGERPRINT\","
echo "  \"version\": \"$VER\","
echo "  \"signature algorithm\": \"$ALGORITHM\","
echo "  \"public key algorithm\": \"$PUBALGORITHM\","
echo "  \"alternative name\": \"$ALT\","
echo "  \"days\": \"$DIFFDAYS\""
echo "} ] }"
