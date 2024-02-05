#!/usr/bin/env bash

# SOCKS5 Proxy Scraper
# Author: Ömer ŞAYAK
# Github Username: https://github.com/omersayak
# Description: This script downloads and tests SOCKS5 proxies from various sources.
# Usage: Run with --timeout to set connection timeout and --target to set the target URL for testing proxies.


set -e

echo.Cyan() {
    echo -e "\\033[36m$*\\033[m"
}

echo.Red() {
    echo -e "\\033[31m$*\\033[m"
}

echo.Green() {
    echo -e "\\033[32m$*\\033[m"
}

echo.Yellow() {
    echo -e "\\033[33m$*\\033[m"
}

error() {
    echo.Red >&2 "$@"
    exit 1
}

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --timeout <seconds>    Set the connection timeout for testing proxies."
    echo "  --target <URL>         Set the target URL to test the proxies against."
    echo "  -h, --help             Show this help message and exit."
    exit 1
}

for cmd in wc curl flock mktemp mv dos2unix sort uniq xargs; do
    if ! command -v $cmd &> /dev/null; then
        error "command: $cmd not found!"
    fi
done

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  --timeout )
    shift; PROXY_TIMEOUT=$1
    ;;
  --target )
    shift; TEST_TARGET_HOST=$1
    ;;
  -h | --help )
    usage
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi

SOCKS5_PROXY_SOURCE=(
    "https://api.proxyscrape.com/v2/?request=getproxies&protocol=socks5&timeout=10000&country=all"
    "https://api.proxyscrape.com/v2/?request=displayproxies&protocol=socks5"
    "https://www.proxy-list.download/api/v1/get?type=socks5"
    "https://api.openproxylist.xyz/socks4.txt"
    "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/socks4.txt"
    "https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/socks5.txt"
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
    "https://raw.githubusercontent.com/jetkai/proxy-list/main/online-proxies/txt/proxies.txt"
    "https://raw.githubusercontent.com/manuGMG/proxy-365/main/SOCKS5.txt"
    "https://raw.githubusercontent.com/monosans/proxy-list/main/proxies/socks5.txt"
    "https://raw.githubusercontent.com/roosterkid/openproxylist/main/SOCKS5_RAW.txt"
    "https://raw.githubusercontent.com/prxchk/proxy-list/main/socks5.txt"
)

SOCKS5_PROXY_LIST="socks5_proxy_list.txt"

echo > "$SOCKS5_PROXY_LIST"
for URL in "${SOCKS5_PROXY_SOURCE[@]}"; do
    TEMP="$(mktemp -u -t ProxyScrape-XXXXXX.txt)"
    if curl -sSL --fail "$URL" -o "$TEMP"; then
        echo.Green "Proxy list downloaded from $URL"
        dos2unix -q "$TEMP"
        cat "$TEMP" >> "$SOCKS5_PROXY_LIST"
        rm "$TEMP"
    fi
done

echo.Cyan "Deduplicating proxy hosts..."
SOCKS5_PROXY_LIST_COUNT_OLD="$(wc -l < "$SOCKS5_PROXY_LIST")"
sort "$SOCKS5_PROXY_LIST" | uniq > "$TEMP"
mv "$TEMP" "$SOCKS5_PROXY_LIST"
SOCKS5_PROXY_LIST_COUNT_NEW="$(wc -l < "$SOCKS5_PROXY_LIST")"
SOCKS5_PROXY_LIST_COUNT_DIFF="$((SOCKS5_PROXY_LIST_COUNT_OLD - SOCKS5_PROXY_LIST_COUNT_NEW))"
echo.Cyan "Deduplicated proxy hosts from $SOCKS5_PROXY_LIST_COUNT_OLD to $SOCKS5_PROXY_LIST_COUNT_NEW, $SOCKS5_PROXY_LIST_COUNT_DIFF removed"

echo.Cyan "Whole list saved to $SOCKS5_PROXY_LIST"

echo.Cyan "Testing proxy hosts with target host - $TEST_TARGET_HOST ..."

while IFS= read -r PROXY; do
    (
        sleep "$(( RANDOM % 10 ))"
        if timeout 10 curl -s --connect-timeout "${PROXY_TIMEOUT:-3}" --retry 0 --fail --socks5-hostname "$PROXY" "$TEST_TARGET_HOST" --compressed > /dev/null; then
            echo "$PROXY" >> "$TEMP"
        fi
    ) &
done < "$SOCKS5_PROXY_LIST"

echo.Cyan "Waiting for proxy test result..."

wait

if [ ! -r "$TEMP" ]; then
    echo.Yellow "None of the proxies received proper response from target $TEST_TARGET_HOST, you may need another \$TEST_TARGET_HOST to test the proxies."
    echo.Yellow "Proxy list saved to $SOCKS5_PROXY_LIST"
    error "Proxy scrape failed!!"
fi

mv "$TEMP" "$SOCKS5_PROXY_LIST"
echo.Green "SOCKS5_PROXY_LIST filtered, $(wc -l < "$SOCKS5_PROXY_LIST") proxy found!"
