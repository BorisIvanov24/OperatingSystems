#!/bin/bash

if [[ "${#}" -ne 1 ]]; then

    echo "Expected 1 argument"
    exit 1
fi

if [[ ! -d "${1}" ]]; then

    echo "Expected a dir"
    exit 2
fi

authFile="${1}/foo.pwd"
confFile="${1}/foo.conf"

if [[ ! -f "${authFile}" ]]; then

    echo "authFile not found"
    exit 3
fi

if [[ ! -f "${confFile}" ]]; then

    echo "confFile not found"
    exit 4
fi

confDir="${1}/cfg"

if [[ ! -d "${confDir}" ]]; then

    echo "dir bot found"
    exit 5
fi

validate="${1}/validate.sh"

if [[ ! -f "${validate}" ]]; then

    echo "validate.sh not found"
    exit 6
fi

files=$(mktemp)
newFoo=$(mktemp)
errors=$(mktemp)

find "${confDir}" -type f 2>/dev/null | grep -E "\.cfg$" >> $files

while read file; do

    "${validate}" "${file}" > "${errors}"

    if [[ "${?}" -eq "2" ]]; then

        echo "validate.sh error"
        exit 7
    fi

    if [[ "${?}" -eq "1" ]]; then

        cat "${errors}" | sed -E "s/^.*$/${file}: & /" 1>&2
        continue
    fi

    username=$(basename "${file}" .cfg)

    if ! grep -q -E "^${username}:.*$" "${authFile}" ; then

        newPass=$(pwgen 16 1)
        hash=$(mkpasswd "${newPass}")

        echo "${username}:${newPass}"

        echo "${username}:${hash}" >> "${authFile}"
    fi

    cat "${file}" >> "${newFoo}"

done< <(cat "${files}")

cat "${newFoo}" > "${confFile}"

rm "${files}" "${newFoo}" "${errors}"