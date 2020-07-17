#!/bin/env bash
set -eo pipefail
shopt -s nullglob

[ -z ${KRB5_REALM} ] && echo "missing KRB5_REALM" && exit 1

cat <<EOF > /etc/krb5.conf
[libdefaults]
    default_realm = ${KRB5_REALM}
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    rdns = false

[realms]
    ${KRB5_REALM} = {
        kdc = localhost
        admin_server = localhost
    }
EOF

cat <<EOF > /var/kerberos/krb5kdc/kdc.conf
default_realm = ${KRB5_REALM}

[logging]
    default = CONSOLE

[kdcdefaults]
    kdc_ports = 88
    kdc_tcp_ports = 88

[realms]
    ${KRB5_REALM} = {
        master_key_type = aes256-cts
        acl_file = /var/kerberos/krb5kdc/kadm5.acl
        admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
        key_stash_file = /var/kerberos/krb5kdc/stash
        supported_enctypes = aes256-cts:normal
    }
EOF

cat <<EOF > /var/kerberos/krb5kdc/kadm5.acl
*/admin@${KRB5_REALM}	*
EOF

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

kdb5_util -r ${KRB5_REALM} -P password create -s

# check dir permissions
ls /docker-entrypoint-init.d/ > /dev/null

process_init_files /docker-entrypoint-init.d/*

# if command starts with an option, prepend krb5kdc
if [ "${1:0:1}" = '-' ]; then
    set -- krb5kdc "$@"
fi

exec "$@"
