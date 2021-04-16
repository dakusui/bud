source "${BUD_LIB}/bud.rc"

export BUD_DEBUG=enabled

_test_json="$(jq -rcM . "$(dirname ${BASH_SOURCE[0]})/data/passing.json")"
execute_test_json "${_test_json}" | jq .
