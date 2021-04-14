source "$(dirname "$(dirname "${BASH_SOURCE[0]}")")/lib/bud.rc"

export BUD_DEBUG=enabled

_test_json="$(jq -rcM . "$(dirname "${BASH_SOURCE[0]}")"/example-passing.json)"
run_test_json "${_test_json}"