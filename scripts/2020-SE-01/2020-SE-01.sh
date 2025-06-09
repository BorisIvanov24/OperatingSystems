#!/bin/bash

if [[ "${#}" -ne 2 ]]; then

    echo "Arguments must be 2!"
    exit 1
fi

if [[ -f "${1}" ]]; then

    echo "File must not exist!"
    exit 2
fi

if [[ ! -d "${2}" ]]; then

    echo "Second argument must be a directory!"
    exit 3
fi

table=$(mktemp)

echo "hostname,phy,vlans,hosts,failover,VPN-3DES-AES,peers,VLAN Trunk Ports,license,SN,key" >> "${table}"

regex1="^[^:]*: (.*)$"
regex2="^This platform has (a|an)( .*) license.$"

while read file; do

    basename "${file}" | sed -E "s/^(.*).log$/\1/g" | xargs echo -n >> "${table}"

    while read line; do

        if [[ "${line}" =~ ${regex1} ]]; then

            echo -n "," >> "${table}"
            echo "${line}" | sed -E "s/${regex1}/\1/g" | xargs echo -n >> "${table}"
        fi

        if [[ "${line}" =~ ${regex2} ]]; then

            echo -n "," >> "${table}"
            echo "${line}" | sed -E "s/${regex2}/\2/g" | xargs echo -n >> "${table}"
        fi

    done< <(cat "${file}")

    echo >> "${table}"

done< <(find "${2}" | grep -E '^.*\.log$')

touch "${1}"

cat "${table}" >> "${1}"

rm "${table}"