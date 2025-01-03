#!/bin/bash
# Script: update_ovh_dynhost.sh
# Author: Hoang Thanh VO

readonly DYNHOST_API_URL="https://dns.eu.ovhapis.com/nic/update?system=dyndns"
readonly DYNHOST_HOSTNAME="$(printenv OVH_DYNHOST_HOSTNAME)"
readonly DYNHOST_USERNAME="$(printenv OVH_DYNHOST_USERNAME)"
readonly DYNHOST_PASSWORD="$(printenv OVH_DYNHOST_PASSWORD)"

get_current_public_ip() {
    local domain_name="$1"
    local current_public_ip

    if [[ "$#" -ne 1 ]]
    then
        echo "ERROR (func::get_current_public_ip): Missing argument..."
        exit 1
    fi

    current_public_ip="$(dig +short "${domain_name}" @9.9.9.9)"

    if [[ -n "${current_public_ip}" ]]
    then
        echo "${current_public_ip}"
    else
        echo "ERROR (func::get_current_public_ip): The dig command returns an empty string..."
        exit 1
    fi
}

get_new_public_ip() {
    local new_public_ip
    local status_code

    status_code="$(curl --silent --write-out '%{http_code}' --output /dev/null https://ifconfig.me)"

    if [[ "${status_code}" == "200" ]]
    then
        new_public_ip="$(curl --silent --ipv4 https://ifconfig.me/ip)"
        echo "${new_public_ip}"
    fi
}

update_ovh_dynhost() (
    local api_url="$1"
    local hostname="$2"
    local username="$3"
    local password="$4"
    local public_ip="$5"

    if [[ "$#" -ne 5 ]]
    then
        echo "ERROR (func::update_ovh_dynhost): Missing arguments..."
        exit 1
    fi

    api_url="$(printf '%s&hostname=%s&myip=%s' "${api_url}" "${hostname}" "${public_ip}")"
    
    response=$(curl --user "${username}:${password}" "${api_url}")

    echo "${response}"
)

current_public_ip="$(get_current_public_ip "${DYNHOST_HOSTNAME}")"
new_public_ip="$(get_new_public_ip)"

if [[ "${current_public_ip}" != "${new_public_ip}" ]]
then
    update_ovh_dynhost \
        "${DYNHOST_API_URL}" \
        "${DYNHOST_HOSTNAME}" \
        "${DYNHOST_USERNAME}" \
        "${DYNHOST_PASSWORD}" \
        "${new_public_ip}"
else
    echo "INFO: DynHost target does not required an update."
fi