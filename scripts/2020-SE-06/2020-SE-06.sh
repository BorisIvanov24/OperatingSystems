#!/bin/bash

if [[ "${#}" -ne 3 ]]; then

    echo "Expected 3 arguments!"
    exit 1
fi

if [[ ! -f "${1}" ]]; then

    echo "File doesn't exist!"
    exit 2
fi

key="${2}"
value="${3}"
newFile=$(mktemp)

regex="^([[:space:]]*${key}[[:space:]]*=[[:space:]]*([0-9a-zA-Z_]+).*)$"

line=$(cat "${1}" | grep -E "${regex}")

oldValue=$(echo "${line}" | sed -E "s/${regex}/\2/")

#echo "old: ${oldValue} new: ${value}"

if [[ "${oldValue}" == "${value}" ]]; then

    rm "${newFile}"
    exit 0
fi

date=$(date)
user=$(whoami)

cat "${1}" | sed -E "s/${regex}/#\1# edited at ${date} by ${user}\n${key} = ${value} # added at ${date} by ${user}/" >> "${newFile}"

if ! cat "${1}" | grep -q -E "${regex}" ; then

    echo "${key} = ${value} # added at ${date} by ${user}" >> "${newFile}"
fi

cat "${newFile}" > "${1}"

rm "${newFile}"