#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export HOME=/config

trap "exit" TERM QUIT INT
trap "kill_thunar" EXIT

log() {
    echo "[thunarsupervisor] $*"
}

getpid_thunar() {
    PID=UNSET
    if [ -f /config/thunar.pid ]; then
        PID="$(cat /config/thunar.pid)"
        # Make sure the saved PID is still running and is associated to
        # thunar.
        if [ ! -f /proc/$PID/cmdline ] || ! cat /proc/$PID/cmdline | grep -qw "thunar"; then
            PID=UNSET
        fi
    fi
    if [ "$PID" = "UNSET" ]; then
        PID="$(ps -o pid,args | grep -w "thunar" | grep -vw grep | tr -s ' ' | cut -d' ' -f2)"
    fi
    echo "${PID:-UNSET}"
}

is_thunar_running() {
    [ "$(getpid_thunar)" != "UNSET" ]
}

start_thunar() {
        dbus-uuidgen 
        export TERMINAL=xterm
	/usr/bin/thunar > /config/log/output.log 2>&1 & 
}

kill_thunar() {
    PID="$(getpid_thunar)"
    if [ "$PID" != "UNSET" ]; then
        log "Terminating thunar..."
        kill $PID
        wait $PID
    fi
}

if ! is_thunar_running; then
    log "thunar not started yet.  Proceeding..."
    start_thunar
fi

thunar_NOT_RUNNING=0
while [ "$thunar_NOT_RUNNING" -lt 5 ]
do
    if is_thunar_running; then
        thunar_NOT_RUNNING=0
    else
        thunar_NOT_RUNNING="$(expr $thunar_NOT_RUNNING + 1)"
    fi
    sleep 1
done

log "thunar no longer running.  Exiting..."