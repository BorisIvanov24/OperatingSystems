#!/bin/bash

if [[ "${#}" -eq 0 ]]; then

    echo "Expected arguments!"
    exit 1
fi

FQDN="([a-z0-9]+\.)+"
numsRegex="([0-9]{10})([[:space:]]+[0-9]+){4}"

regex="^${FQDN}[[:space:]]+([0-9]+[[:space:]]+)?[[:space:]]+IN[[:space:]]+(SOA|NS|A|AAAA)[[:space:]]+${FQDN}[[:space:]]+${FQDN}[[:space:]]+(\(|${numsRegex})$"

while read file; do

    if [[ ! -f "${file}" ]]; then

        echo "Not a file: ${file}!" >&2
        continue
    fi

    line=$(cat "${file}" | grep -E "${regex}")

    if [[ -z "${line}" ]]; then

        echo "Invalid SOA file: ${file}!" >&2
        continue
    fi

    lastChar=$(echo "${line}" | sed -E 's/^.+(.)$/\1/')

    serial=""

    if [[ "${lastChar}" != "(" ]]; then

        serial=$(echo "${line}" | sed -E "s/^.+${numsRegex}$/\1/")
    else
        serial=$(cat "${file}" | grep -E "^[[:space:]]*([0-9]{10})[[:space:]]*;[[:space:]]*serial[[:space:]]*$" | cut -d ';' -f1 | sed -E -e 's/^[[:space:]]+//g' -e 's/[[:space:]]+$//g')
    fi

    newSerial=""
    serialDate=$(echo "${serial}" | cut -c1-8)
    num=$(echo "${serial}" | cut -c9-10)
    todayDate=$(date "+%Y%m%d")

    if [[ "${todayDate}" -gt "${serialDate}" ]]; then

        newSerial="${todayDate}00"
    else
        num=$(printf "%02d" $((num+1)))
        newSerial="${serialDate}${num}"
    fi

    sed -E -i "s/${serial}/${newSerial}/" "${file}"

done< <(printf "%s\n" "${@}")
