

source "$(dirname "$(dirname "${BASH_SOURCE[0]}")")/lib/bud.rc"


_test_json="$(jq -rcM . "$(dirname "${BASH_SOURCE[0]}")"/example.json)"
execute_test_json "${_test_json}"