#!/bin/env bash
set -eo pipefail
shopt -s nullglob

process_init_files() {
    local f
    for f; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    printf '%s [INFO] [Entrypoint]: %s\n' "$(date --rfc-3339=seconds)" "$0: running $f"
                    "$f"
                else
                    printf '%s [INFO] [Entrypoint]: %s\n' "$(date --rfc-3339=seconds)" "$0: sourcing $f"
                    . "$f"
                fi
                ;;
            *)
                printf '%s [INFO] [Entrypoint]: %s\n' "$(date --rfc-3339=seconds)" "$0: adding principals from $f"
                awk '{ print "ank -pw", $2, $1 }' < "$f" | kadmin.local
                ;;
        esac
        echo
    done
}

# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
    set -- krb5kdc "$@"
fi

# check dir permissions
ls /docker-entrypoint-init.d/ > /dev/null

process_init_files /docker-entrypoint-init.d/*

exec "$@"