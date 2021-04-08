function exit_if_aborted() {
  if [[ -e "${PIDDIR}/$$" ]]; then
    message "ERROR:" "${@}"
    exit "$(cat "${PIDDIR}/$$")"
  fi
}


####
# Used when a condition is not met and a program should NOT go on.
function abort() {
  local _exit_code=1
  print_stacktrace "ERROR:" "${@}"
  echo "${_exit_code}" >"${PIDDIR}/$$"
  exit "${_exit_code}"
}

PIDDIR="/tmp/bud/${BUD_APP_NAME}/pid"
export PIDDIR
mkdir -p "${PIDDIR}"
