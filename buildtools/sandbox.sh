function parseopt() {
  # Call getopt to validate the provided input.
  local _options _ret='{}'
  _options=$(getopt \
    -o ho: \
    --long help,output: -- "$@") || {
    usage
    abort "Failed to  parse command line: '$*'"
  }
  if [[ $# -gt 0 ]]; then
    eval set -- "${_options}"
    while true; do
      case "${1}" in
      -h | --help)
        usage
        exit 0
        ;;
      -o | --output)
        local _key="${1#--}"
        local _value="$2"
        local _cur='[]' _has_key

        _has_key="$(echo "${_ret}" | jq -ncr 'has("output")')"
        if [[ "${_has_key}" == true ]]; then
          _cur="$(echo "${_ret}" | jq -ncr '.output')"
        fi
        echo "_cur: '${_cur}'" >&2
        echo "_key: '${_key}'" >&2
        echo "_value: '${_value}'" >&2
        # shellcheck disable=SC2154
        _cur="$(jq -ncrM --argjson v "${_cur}" --arg w "${2}" '$v + [$w]')"
        _ret="$(echo "${_ret}" | jq -crM --argjson v "${_cur}" '. * {"output":$v}')"
        shift
        shift
        ;;
      --)
        shift
        break
        ;;
      *)
        abort "Internal error!"
        ;;
      esac
    done
  fi
  echo "${_ret}"
}

function abort() {
  echo "ABORT: ${*}" >&2
  exit 1
}
parseopt "${@}"