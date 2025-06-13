#!/bin/bash

if [[ "${USER}" != "oracle" && "${USER}" != "grid" ]]; then

    echo "Expected oracle or grid user"
    exit 1
fi

if [[ "${#}" -ne 1 ]]; then

    echo "Expected one argument"
    exit 2
fi

if [[ ! "${1}" =~ ^(0|[1-9][0-9]*)$ ]]; then

    echo "Expected a number"
    exit 6
fi

if [[ "${1}" -lt "2" ]]; then

    echo "Expected minimum amount 2"
    exit 3
fi

diag_dest="/u01/app/${USER}"

if [[ ! -d "${ORACLE_HOME}" ]]; then

    echo "ORACLE_HOME not found"
    exit 4
fi

adrci="${ORACLE_HOME}/bin/adrci"
minutes=$((${1} * 60))

if [[ ! -f "${adrci}" ]]; then

    echo "adrci not found"
    exit 5
fi

adrHomes=$("${adrci}" exec="SET BASE ${diag_dest}; SHOW HOMES")

if [[ "${adrHomes}" == "No ADR homes are set" ]]; then

    echo "No ADR homes are set!"
    exit 7
fi

adrHomes=$(echo "${adrHomes}" | grep -E '^[^/]+/(crs|tnslsnr|kfod|asm|rdbms)(/[^/]+)*$')

while read home; do

    "${adrci}" exec="SET BASE ${diag_dest}; SET HOMEPATH ${home}; PURGE -AGE ${minutes}"
done< <(echo "${adrHomes}")