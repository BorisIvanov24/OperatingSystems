#!/bin/bash

if [[ "${UID}" -ne 0 ]]; then
    echo "You need to be root to run this script!"
    exit 1
fi

users=$(mktemp)
files=$(mktemp)

cat "/etc/passwd" | cut -d ':' -f 1,6 > "${users}"

while read user; do

    name=$(echo "${user}" | cut -d ':' -f 1)
    homeDir=$(echo "${user}" | cut -d ':' -f 2)

    if [[ ! -d "${homeDir}" ]]; then
        continue
    fi

    fileName=$(find "${homeDir}" -type f -printf "%p:%T@\n" 2>/dev/null | sort -                                                                                                                                  t ':' -k 2 | tail -n 1)

    echo "${name}:${fileName}" >> "${files}"

done < <(cat "${users}")

cat "${files}" | sort -t ':' -n -k 3 | cut -d ':' -f 1,2 | tail -n 1

rm "${users}" "${files}"
