#!/bin/sh

RESTIC_VERSION=$1
[ -z "$RESTIC_VERSION" ] && RESTIC_VERSION="0.8.1"

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

ensure_commands_exist "getgid" "groupadd" "id" "chmod" "chown" "setcap" "install" "jq" "wget" "wget" "openssl" "curl"

getgid restic >/dev/null 2>/dev/null || groupadd restic || exit 1
id -u restic >/dev/null 2>/dev/null || useradd restic -m -d /home/services/restic -g restic || exit 1
mkdir -p ~restic/bin || exit 1

RESTIC_BIN=~restic/bin/restic
if [ ! -f $RESTIC_BIN ]; then
    echo "* installing restic"
    arch="386"
    if [ "$(uname)" == "x86_64" ]; then
        arch="amd64"
    fi
    url="https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_${arch}.bz2"
    rm -f ~restic/bin/*.bz2
    wget -q $url -O ~restic/bin/restic.bz2 && bunzip2 -c ~restic/bin/restic.bz2 > $RESTIC_BIN || exit 1
    rm -f ~restic/bin/*.bz2
fi

if [ -f $RESTIC_BIN ]; then
    echo "* setting $RESTIC_BIN permissions"
    chmod 750 $RESTIC_BIN || exit 1
    chown root:restic ~restic/bin/restic ||  exit 1
    setcap cap_dac_read_search=+ep ~restic/bin/restic || exit 1
fi
echo "* installing scripts"
install -m 750 -g restic -o root restic.sh restic-backup.sh ~restic/bin/ || exit 1

[ -f ~restic/jobs.json ] || install -o restic -g restic -m 600 jobs.json ~restic
[ -f ~restic/.restic.env ] || install -o restic -g restic -m 600 restic.env ~restic/.restic.env

if [ ! -f /etc/cron.d/restic-backup ]; then
    echo "* installing crontab"
    install -m 640 crontab /etc/cron.d/restic-backup
fi

RESTIC_PASSWORD_FILE=~restic/.restic.key
if [ ! -f $RESTIC_PASSWORD_FILE ]; then
    echo "* generating repo key $RESTIC_PASSWORD_FILE"
    openssl rand -base64 24 > $RESTIC_PASSWORD_FILE
    chown root:restic $RESTIC_PASSWORD_FILE
    chmod 640 $RESTIC_PASSWORD_FILE
fi

echo "* installation complete"
