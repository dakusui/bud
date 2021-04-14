source "$(dirname "$(dirname "${BASH_SOURCE[0]}")")/testenvvars.rc"
source "${LIBDIR}/bud.rc"

export BUD_DEBUG=enabled

_test_json="$(jq -rcM . "$(dirname ${BASH_SOURCE[0]})/data/passing.json")"
__bud__execute_test_json "${_test_json}" | jq .
