#!/bin/sh
# 
# fw port knocking client

KNOCK_PORTS="17000 18000 19000"
HOST=$1

if [ -z "$HOST" ]; then 
    echo "Usage: $0 host ssh-args"
    exit 1
fi

echo -n " * knocking $HOST:"
for i in $KNOCK_PORTS; do
    echo -n "*" | nc -w1 $HOST $i
    echo -n " $i"
done
echo 
echo  " * executing ssh $@"
exec ssh $@
