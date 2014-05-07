#!/bin/sh
#
# Generate iptables based port knocking rules
# 
# Usage: 
#  1) change KNOCK_PORTS to sth non obvious sequence
#  2) sh knocking-rules.sh > rules.sh


KNOCK_PORTS="18000 19000 20000"
PORTS_TO_OPEN="22"

create_iptables_table() {
    echo iptables -N $1
}


add_iptables_rule() {
    echo iptables -A $@
}

n=0
for port in $KNOCK_PORTS; do
    table="STATE${n}"
    knock="KNOCK${n}"

    echo "# port $port"
    create_iptables_table $table
    if [ "$n" -gt 0 ]; then
       prevKNOCK="KNOCK$(expr $n - 1)"
       add_iptables_rule $table -m recent --name $prevKNOCK --remove
       add_iptables_rule INPUT  -m recent --name $prevKNOCK --rcheck -j $table
    fi

    add_iptables_rule $table -p tcp -m state --state NEW --dport $port -m recent --name $knock --set -j REJECT
    if [ "$n" -eq 0 ]; then
        add_iptables_rule $table -j REJECT
    else
        add_iptables_rule $table -j STATE0
    fi
    n=$(expr $n + 1)
done
echo 
table="STATE${n}"
prevKNOCK="KNOCK$(expr $n - 1)"

create_iptables_table $table
add_iptables_rule $table -m recent --name $prevKNOCK --remove

for port in $PORTS_TO_OPEN; do
    add_iptables_rule $table -p tcp --dport $port -j LOG --log-prefix="KNOCK "
    add_iptables_rule $table -p tcp --dport $port -j ACCEPT 
done
add_iptables_rule $table -j STATE0
add_iptables_rule INPUT -j STATE0

