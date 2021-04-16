source "${BUD_LIB}/bud.rc"

export BUD_DEBUG=enabled

_test_json="$(jq -rcM . "$(dirname "${BASH_SOURCE[0]}")"/data/ignored.json)"
run_test_json "${_test_json}"