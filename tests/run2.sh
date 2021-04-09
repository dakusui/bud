source "$(dirname "$(dirname "${BASH_SOURCE[0]}")")/lib/bud.rc"

set -eu -o pipefail
shopt -s inherit_errexit nullglob compat"${BASH_COMPAT=42}"

export BUD_DEBUG=disabled

message "hi1"
_test_json="$(jq -rcM . "$(dirname "${BASH_SOURCE[0]}")"/example.json)"
message "hi2"
execute_test_json "${_test_json}"