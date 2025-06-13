#!/bin/bash

if [[ "${USER}" != "oracle" && "${USER}" != "grid" ]]; then

    echo "You can't run this script!"
    exit 1
fi

if [[ -z "${ORACLE_HOME}" ]]; then

    echo "ORACLE_HOME not found!"
    exit 2
fi

adrci="${ORACLE_HOME}/bin/adrci"

if [[ ! -f "${adrci}" ]]; then

    echo "Executable file not found!"
    exit 3
fi

diag_dest="/u01/app/${USER}"

adrHomes=$("${adrci}" exec="show homes")

if [[ "${adrHomes}" =~ ^No ADR homes are set$ ]]; then

    echo "No ADR homes found!"
    exit 4
fi

adrHomes=$(echo "${adrHomes}" | tail -n +2)

while read home; do

    home=$(echo "${home}" | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+$//')

    path="${diag_dest}/${home}"

    bytes=$(du -sb "${path}" | cut -f1)
    mb=$((bytes / 1024 / 1024))
    echo "${mb} ${path}"

done< <(echo "${adrHomes}")