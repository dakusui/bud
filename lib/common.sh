"${__BUD__COMMON_SH:-false}" && return 0
readonly __BUD__COMMON_SH=true

source "$(dirname "${BASH_SOURCE[0]}")/envvars.sh"

function join_by() {
  local d=${1-} f=${2-}
  if shift 2; then printf %s "$f" "${@/#/$d}"; fi
}

function urlencode() {
  local _data="${1}"
  jq -rn --arg x "${_data}" '$x|@uri'
}

function urldecode() {
  : "${*//+/ }"
  echo -e "${_//%/\\x}"
}

function quote() {
  local _v="${1}"
  echo -n "'""${_v/\'/\'\"\'\"\'}""'"
}

function app_name() {
  local _ret
  _ret="$(basename "${0}")"
  echo "${_ret%.*}"
}

function _escape_single_quote() {
  echo -n "${1}" | sed -r s/\'/\'\"\'\"\'/g
}

function to_json_array() {
  local _i
  jq -ncRM < <(for _i in "${@}"; do echo "${_i}"; done)
}

function json_value_at() {
  local _path="${1}" _json="${2}"
  echo "${_json}" | jq -crM "${_path}" || abort "Something went wrong _path:'${_path}' _json='${_json}'"
}

function json_type_of() {
  local _path="${1}" _json="${2}"
  echo "${_json}" | jq -crM "${_path}|type" || abort "Something went wrong _path:'${_path}' _json='${_json}'"
}

function bug_temp_file() {
  mktemp -p "${TEMP:-/tmp}/bud/${BUD_APP_NAME}"
}

function is_void_value() {
  [[ ${1} == "${BUD_VOID}" ]]
}

function void_value() {
  echo "${BUD_VOID}"
}

function json_value_at_or_else() {
  local _path="${1}" _json="${2}" _default_value="${3}"
  local _is_null
  # If you check the value using the function 'json_value_at', you cannot tell
  # the value is string "null" or a JSON's null node.
  # Note that we are still unable to tell the absence of an attribute and
  # an actual null node. (This is a limitation of this function)
  _is_null="$(echo "${_json}" | jq -crM "${_path} == null")" ||
    abort "Something went wrong: _path:'${_path}' _json:'${_json}' _default_value:'${_default_value}'"
  if [[ "${_is_null}" == true ]]; then
    echo "${_default_value}"
  else
    json_value_at "${_path}" "${_json}"
  fi
}

function json_has() {
  local _key="${1}" _json="${2}"
  local _v
  _v="$(echo "${_json}" | jq -crM 'has("'"${_key}"'")')"
  exit_if_aborted "Failed to check key:'${_key}' in json:'${_json}'"
  if [[ "${_v}" == true ]]; then
    return 0
  fi
  return 1
}

function json_has_non_null_value_at() {
  local _path="${1}" _json="${2}"
  local _v
  _v="$(echo "${_json}" | jq -crM "getpath(path(${_path})) != null")" || abort "Something went wrong _path:'${_path}' _json='${_json}'"
  if [[ "${_v}" == true ]]; then
    return 0
  fi
  return 1
}

# If it is not present, nothing will be written.
function json_value_if_non_null_value_is_present_at() {
  local _path="${1}" _json="${2}"
  if json_has_non_null_value_at "${_path%[]}" "${_json}"; then
    json_value_at "${_path}" "${_json}"
  fi
}

function json_object_merge() {
  local _v="${1}" _w="${2}"
  jq -nrcM --argjson v "${_v}" --argjson w "${_w}" '$v * $w' ||
    abort "Failed to merge objects _v:'${_v}' _w:'${_w}'"
}

function json_array_append() {
  local _v="${1}" _w="${2}"
  jq -ncrM --argjson v "${_v}" --argjson w "${_w}" '$v + $w' ||
    abort "Failed to append arrays _v:'${_v}' _w:'${_w}'"
}

function array_contains() {
  local _word="${1}" && shift
  printf '%s\n' "${@}" | grep -q -E '^'"${_word}"'$'
}

function message() {
  echo "${@}" >&2
}

function trace() {
  if [[ "${BUD_TRACE:-disabled}" == "enabled" ]]; then
    local _caller
    _caller="$(caller 0)"
    _caller="$(__bud__format_caller ${_caller})"
    message "TRACE: ${_caller}:" "${@}"
    if [[ "${BUD_LOG_FILE}" != "" ]]; then
      message "TRACE: ${_caller}: " "${@}" 2>>"${BUD_LOG_FILE}"
    fi
  fi
}

function debug() {
  if [[ "${BUD_DEBUG:-disabled}" == "enabled" ]]; then
    local _caller
    _caller="$(caller 0)"
    _caller="$(__bud__format_caller ${_caller})"
    message "DEBUG: ${_caller}:" "${@}"
    if [[ "${BUD_LOG_FILE}" != "" ]]; then
      message "DEBUG: ${_caller}: " "${@}" 2>>"${BUD_LOG_FILE}"
    fi
  fi
}

function error() {
  if [[ "${BUD_ERROR:-enabled}" == "enabled" ]]; then
    local _caller
    _caller="$(caller 0)"
    # shellcheck disable=SC2086
    _caller="$(__bud__format_caller ${_caller})"
    message "ERROR: ${_caller}: " "${@}"
    if [[ "${BUD_LOG_FILE}" != "" ]]; then
      message "ERROR: ${_caller}: " "${@}" 2>>"${BUD_LOG_FILE}"
    fi
  fi
}

function __bud__format_caller() {
  local _line="${1:-???}" _function="${2:-unknown}" _file="${3:-unknown file}"
  echo "${_file}:${_line} (${_function})"
}

####
# Used when a condition is not met and a program should NOT go on.
function abort() {
  local _exit_code=1
  print_stacktrace "ERROR:" "${@}"
  echo "${_exit_code}" >"${PIDDIR}/$$"
  exit "${_exit_code}"
}

function assert_that() {
  local _message="${1}"
  shift
  if ! eval "${@}"; then
    abort "$(printf "Condition was not satisfied:\n  Condition: %s\n  Detail: %s" "${_message}" "${*}")"
  fi
}

function exit_if_aborted() {
  if [[ -e "${PIDDIR}/$$" ]]; then
    message "ERROR:" "${@}"
    exit "$(cat "${PIDDIR}/$$")"
  fi
}

function print_stacktrace() {
  local _message="${1}"
  shift
  message "${_message}" "${@}"
  local _i=0
  local _e
  while _e="$(caller $_i)"; do
    # shellcheck disable=SC2086
    _e="$(__bud__format_caller ${_e})"
    message "  at ${_e}"
    _i=$((_i + 1))
  done
}

export BUD_APP_NAME
BUD_APP_NAME="$(app_name)"
export PIDDIR
PIDDIR="/tmp/bud/${BUD_APP_NAME}/pid"
mkdir -p "${PIDDIR}"

trap abort ERR
