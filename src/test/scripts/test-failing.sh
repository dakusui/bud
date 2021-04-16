source "${BUD_LIB}/bud.rc"

export BUD_DEBUG=enabled

_test_json="$(jq -rcM . "$(dirname "${BASH_SOURCE[0]}")"/data/failing.json)"

echo "RUN TEST (EXECUTION ONLY)"
_result_json=$(execute_test_json "${_test_json}")
echo "CHECK TEST RESULT"
_success=$(echo "${_result_json}" | jq -crM .report.result.success)
if [[ "${_success}" == false ]]; then
  exit 0
else
  exit 1
fi
echo "DONE"