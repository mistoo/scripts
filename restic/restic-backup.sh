#!/bin/sh

PATH=$HOME/bin:$PATH

exit1() {
    local msg=$1
    echo $1 >&2
    exit 1
}

ensure_commands_exist() {
    while [ -n "$1" ]; do
        command -v $1 >/dev/null 2>/dev/null || exit1 "$1: command not found"
        shift
    done
}

getattr() {
    local index=$1
    local name=$2
    local relax=$3
    local value=$(jq -er ".[$index].$name$relax" $JOBS)
    [ $? -eq 0 ] || exit1 ".[$index].$name: no such attribute"
    [ -z "$relax" ] && [ -z "$value" -o "$value" == "null" ] && exit1 "$JOBS#index: $name: no such attribute"
    [ "$value" == "null" ] && value=""
    echo $value
}

ensure_commands_exist "jq" "curl"

JOBS=$1
[ -z "$JOBS" ] && JOBS="$HOME/.restic-jobs.json"
[ ! -f $JOBS ] && exit1 "Usage: $0 JOBSFILEPATH"


N=$(jq '. | length' $JOBS)
do_prune=""
for i in $(seq 0 $(expr $N - 1)); do
    path=$(getattr $i "path")
    [ $? -eq 0 ] || continue
    tag=$(getattr $i "tag")
    [ $? -eq 0 ] || continue

    hchk_id=$(getattr $i "hchk_id" "?")
    [ $? -eq 0 ] || continue

    retention=$(getattr $i "retention_days" "?")
    [ $? -eq 0 ] || continue
    [ -z "$retention" ] && retention="14"

    echo "* executing #$i: backup of $path with retention $retention days"

    restic.sh backup $path -q --tag $tag
    if [ $? -eq 0 ]; then
        [ -n "$hchk_id" ] && curl -fsS --retry 3 https://hchk.io/$hchk_id > /dev/null
        sleep 1
        restic.sh -q forget --tag $tag --keep-daily $retention || exit 1
        do_prune=1
    fi
done

if [ -n "$do_prune" ]; then
    echo "* pruning"
    restic.sh -q prune || exit 1
fi
echo "* backup done"
