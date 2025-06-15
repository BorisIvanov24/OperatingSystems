#!/bin/bash

if [[ "${USER}" != "oracle" && "${USER}" != "grid" ]]; then

    echo "Expected user oracle or grid"
    exit 1
fi

if [[ "${#}" -ne 1 ]]; then

    echo "Expected 1 argument"
    exit 2
fi

regexNumber="(0|[1-9][0-9]*)"

if [[ ! "${1}" =~ ^${regexNumber}$ ]]; then

    echo "Expected a number"
    exit 3
fi

if [[ -z "${ORACLE_BASE}" ]]; then

    echo "ORACLE_BASE not found"
    exit 4
fi

if [[ -z "${ORACLE_HOME}" ]]; then

    echo "ORACLE_HOME not found"
    exit 5
fi

if [[ -z "${ORACLE_SID}" ]]; then

    echo "ORACLE_SID not found"
    exit 6
fi

sqlplus="${ORACLE_HOME}/bin/sqlplus"

if [[ ! -f "${sqlplus}" ]]; then

    echo "sqlplus not found"
    exit 7
fi

role=""

if [[ "${USER}" == "oracle" ]]; then

    role="SYSDBA"
else

    role="SYSASM"
fi

foo=$(mktemp)

echo "SELECT value FROM v\$parameter WHERE name = 'diagnostic_dest';" >> "${foo}"

diagnostic_dest=$(${sqlplus} -SL "/ as ${role}" ${foo} | tail -n +4 | head -n 1)

diag_base="${diagnostic_dest}"

if [[ -z ${diagnostic_dest} ]]; then

    diag_base="${ORACLE_HOME}"
fi

diag_dir="${diag_base}/diag"

if [[ ! -d "${diag_dir}" ]]; then

    echo "diag_dir not found"
    exit 8
fi

machine=$(hostname -s)

if [[ "${USER}" == "grid" ]]; then

    #crs
    dirCRS="${diag_dir}/crs/$machine/crs/trace"

    if [[ ! -d "${dirCRS}" ]]; then

        echo "crs dir not found"
        exit 9
    fi

    sumCRS="0"
    while read file; do

        sumCRS=$(( ${sumCRS} + $(du -k ${file} | cut -f1) ))

    done< <(find "${dirCRS}" -type f -mtime "+${1}" | grep -E "_${regexNumber}\.(trc|trm)$")

    echo "crs: ${sumCRS}"

    #tnslsnr
    dirTNSLSNR="${diag_dir}/tnslsnr/${machine}"

    if [[ ! -d "${dirTNSLSNR}" ]]; then

        echo "tnslsnr dir not found"
        exit 10
    fi

    sumTNSLSNR="0"
    while read file; do

        sumTNSLSNR=$(( ${sumTNSLSNR} + $(du -k ${file} | cut -f1) ))

    done< <(find "${dirTNSLSNR}" -mindepth 2 -maxdepth 2 -mtime "+${1}" | grep -E "(alert/[^/]*_${regexNumber}\.xml)|(trace/[^/]*_${regexNumber}\.log)$")

    echo "tnslsnr: ${sumTNSLSNR}"
else

    #rdbms
    dirRDBMS="${diag_dir}/rdbms"

    if [[ ! -d ${dirRDBMS} ]]; then

        echo "rdbms dir not found"
        exit 11
    fi

    sumRDBMS="0"

    while read file; do

        sumRDBMS=$(( ${sumRDBMS} + $(du -k ${file} | cut -f1) ))

    done< <(find "${dirRDBMS}" -mindepth 2 -maxdepth 2 -mtime "+${1}" | grep -E "_${regexNumber}\.(trc|trm)$" )

    echo "rdbms: ${sumRDBMS}"
fi

rm "${foo}"
