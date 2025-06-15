#!/bin/bash

if [[ "${#}" -ne 1 ]]; then

    echo "Expected 1 argument"
    exit 1
fi

if [[ ! "${1}" =~ ^[A-Z0-9]{1,4}$ ]]; then

    echo "Invalid device name"
    exit 2
fi

device="${1}"
file="/proc/acpi/wakeup"
regex="^${device}[[:space:]]+[A-S0-9]+[[:space:]]+\*(enabled|disabled)[[:space:]]+.*$"

deviceLine=$(grep -E "${device}" "${file}")

if [[ -z "${deviceLine}" ]]; then

    echo "Device not found!"
    exit 3
fi

if [[ $(echo "${deviceLine}" | sed -E "s/${regex}/\1/") == "disabled" ]]; then

    echo "Device already disabled!"
    exit 4
fi

echo "${device}" > "${file}"