#!/bin/sh -eu

echo 'Testing connectivity'

echo 'Installing bind-tools'
apk add --no-cache --update bind-tools 1>/dev/null

EXIT_CODE=0

testQuery () {
    _RESULT="$(dig "$1" +noall +answer +short "@${DNS_SERVER}")"
    if [ -n "$_RESULT" ]; then
        echo "SUCCESS for $1"
        return;
    fi
    # Set exit code from second arg or use 1
    EXIT_CODE="${2:-1}"
    echo "FAILURE for $1"
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
    # Using docker server
    testQuery 'dns-server' 1 127.0.0.11

    echo 'Ended'
}

testServer 'dns-server-recursive'
testServer 'dns-server-forwarding'

exit ${EXIT_CODE}
