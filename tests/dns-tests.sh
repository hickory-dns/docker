#!/bin/sh -eu

echo 'Testing connectivity'

echo 'Installing bind-tools'
apk add --no-cache --update bind-tools 1>/dev/null

EXIT_CODE=0

# Arguments
# - The name to query
# - The exit code (default: 1)
# - Some more options (default: none)
#
testQuery () {
    _RESULT="$(dig ${3:-} "$1" +noall +answer +short "@${DNS_SERVER}")"
    if [ -n "$_RESULT" ]; then
        echo "SUCCESS for $1 ($_RESULT)"
        return;
    fi
    # Set exit code from second arg or use 1
    EXIT_CODE="${2:-1}"
    if [ "${2:-1}" = "0" ]; then
        echo "SUCCESS (successfully failed) for $1"
    else
        echo "FAILURE for $1"
    fi
}

testServer() {
    DNS_SERVER="${1}"
    echo 'Testing server'
    # Wait for 2 replies
    ping -c 2 $DNS_SERVER

    testQuery 'non-existing-name' 0
    # Server uses Internet to answer
    testQuery 'google.com'
    testQuery 'hickory-dns.org'
    # A query that only the server can answer
    testQuery 'test-domain.custom'
    testQuery 'dns-server.custom'
    testQuery '127.0.0.11' 0 '-x'
    testQuery '8.8.8.8' 0 '-x'
    testQuery '1.1.1.1' 0 '-x'

    DNS_SERVER="127.0.0.11"
    # Using docker server
    testQuery "${1}"
    DNS_SERVER="${1}"

    echo 'Ended'
}

testServer 'dns-server-recursive'
testServer 'dns-server-forwarding'

exit ${EXIT_CODE}
