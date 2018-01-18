#!/bin/sh

exit1() {
    local msg=$1
    echo $1 >&2
    exit 1
}

if [ -f $HOME/.restic.env ]; then
    source $HOME/.restic.env
    chmod 600 $HOME/.restic.env
fi

if [ -z "$RESTIC_REPOSITORY" ]; then
    RESTIC_REPOSITORY="b2:${B2_PREFIX}$(hostname)-backup:/"
fi

if [ -z "$RESTIC_PASSWORD_FILE" ]; then
    RESTIC_PASSWORD_FILE="$HOME/.restic.key"
fi

if [ "$1" == "init" -a ! -f $RESTIC_PASSWORD_FILE ]; then
    openssl rand -base64 24 > $RESTIC_PASSWORD_FILE
    chmod 600 $RESTIC_PASSWORD_FILE
    echo "* generated repo key $RESTIC_PASSWORD_FILE"
fi

[ -z "$B2_ACCOUNT_ID" ] && exit1 "empty B2_ACCOUNT_ID"
[ -z "$B2_ACCOUNT_KEY" ] && exit1 "empty B2_ACCOUNT_KEY"
[ -z "$RESTIC_REPOSITORY" ] && exit1 "empty RESTIC_REPOSITORY"
[ -z "$RESTIC_PASSWORD_FILE" ] && exit1 "empty RESTIC_PASSWORD_FILE"

echo "* executing restic $@ ($RESTIC_REPOSITORY repo)"
export B2_ACCOUNT_ID B2_ACCOUNT_KEY RESTIC_REPOSITORY RESTIC_PASSWORD_FILE

if [ "$1" == "backup" ]; then
    exec restic "$@" --exclude=*~ --exclude=tmp --exclude=cache --exclude={.cache,/dev,/media,/mnt,/proc,/run,/sys,/tmp,var/tmp/*,var/log/archive/*.gz,var/lock/subsys/*} --exclude=*.sav --exclude=shared/log --exclude=backup --one-file-system
else
    exec restic "$@"
fi
