source "${BUD_LIB}/bud.rc"

export BUD_DEBUG=enabled

_test_json="$(jq -rcM . "$(dirname "${BASH_SOURCE[0]}")"/data/passing.json)"
_result_json=$(precheck_test_json "${_test_json}")

_precheck=$(echo "${_result_json}" | jq -crM .report.result.precheck)
if [[ "${_precheck}" == true ]]; then
  exit 0
else
  exit 1
fi
