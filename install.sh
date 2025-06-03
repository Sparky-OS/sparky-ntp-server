#!/bin/sh
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation; either version 2 of the
#  License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA

detect_cc() {
    tz=$(timedatectl show --value -p Timezone 2>/dev/null || cat /etc/timezone 2>/dev/null)
    [ -z "$tz" ] && return
    grep -F "${tz}" /usr/share/zoneinfo/zone.tab 2>/dev/null | awk 'NR==1{print tolower($1)}'
}

generate_servers() {
    cc="$1"
    if [ "$cc" = "br" ]; then
        cat <<EOF
server a.st1.ntp.br    iburst prefer
server b.st1.ntp.br    iburst
server c.st1.ntp.br    iburst
EOF
    else
        prefix="${cc:+$cc.}"
        cat <<EOF
server 0.${prefix}pool.ntp.org    iburst
server 1.${prefix}pool.ntp.org    iburst
server 2.${prefix}pool.ntp.org    iburst
server 3.${prefix}pool.ntp.org    iburst
EOF
    fi
}

install_conf() {
    cc=$(detect_cc)
    servers=$(generate_servers "$cc")
    dest=/etc/sparky-ntp.conf
    {
        while IFS= read -r line; do
            case "$line" in
                *'@NTP_SERVERS@'*) printf '%s\n' "$servers" ;;
                *) printf '%s\n' "$line" ;;
            esac
        done < etc/sparky-ntp.conf
    } > "$dest"
}

if [ "$1" = "uninstall" ]; then
        rm -f /etc/sparky-ntp.conf
else
        install_conf
fi
