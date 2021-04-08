"${__BUD__EXEC_SH:-false}" && return 0
readonly __BUD__EXEC_SH=true

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

function __bud__get_description_from_json_object() {
  local _json_object="${1}"
  json_value_at ".description[]" "${_json_object}"
}

function __bud__get_stdin_from_json_object() {
  local _json_object="${1}"
  json_value_at ".stdin[]" "${_json_object}"
}

function __bud__get_shell_name_from_json_object() {
  local _json_object="${1}"
  json_value_at ".shell.name" "${_json_object}"
}

function __bud__get_shell_options_from_json_object() {
  local _json_object="${1}"
  json_value_at ".shell.options[]" "${_json_object}"
}

function __bud__compose_shell_from_json_object() {
  local _json_object="${1}"
  printf "%s %s" "$(__bud__get_shell_name_from_json_object "${_json_object}")" "$(__bud__get_shell_options_from_json_object "${_json_object}")"
}

function __bud__get_source_from_json_object() {
  local _json_object="${1}"
  json_value_at ".source[]" "${_json_object}"
}

function __bud__get_command_name_from_json_object() {
  local _json_object="${1}"
  json_value_at ".cmd" "${_json_object}"
}

function __bud__get_args_from_json_object() {
  local _json_object="${1}"
  json_value_at ".args[]" "${_json_object}"
}

function __bud__compose_commandline_from_json_object() {
  local _json_object="${1}"
  local _ret _args _i

  _ret="$(__bud__get_command_name_from_json_object "${_json_object}")"
  mapfile -t _args < <(__bud__get_args_from_json_object "${_json_object}")
  for _i in "${_args[@]}"; do
    _ret="${_ret} $(quote "${_i}")"
  done

  echo "${_ret}"
}

function __bud__compose_script_from_json_object() {
  local _json_object="${1}"
  local _i _description _source_files

  # Print description of the command line to be run.
  mapfile -t _description < <(__bud__get_description_from_json_object "${_json_object}")
  for _i in "${_description[@]}"; do
    echo "# ${_i}"
  done

  # Print an empty line for readability
  echo

  # Print source directives to "include" files
  mapfile -t _source_files < <(__bud__get_source_from_json_object "${_json_object}")
  for _i in "${_source_files[@]}"; do
    echo "source " "$(quote "${_i}")"
  done

  # Print an empty line for readability
  echo

  # Print the command line
  __bud__compose_commandline_from_json_object "${_json_object}"
}

function __bud__file_for_stdout() {
  echo "$(__bud__directory_for_output)/stdout.txt"
}

function __bud__file_for_stderr() {
  echo "$(__bud__directory_for_output)/stderr.txt"
}

function __bud__file_for_exit_code() {
  echo "$(__bud__directory_for_output)/exit_code.txt"
}

function __bud__file_for_script() {
  echo "$(__bud__directory_for_output)/script.txt"
}

function __bud__directory_for_output() {
  echo "out"
}

function run_json_object() {
  local _json_object="${1}"
  local _stdin _shell _script _i
  mapfile -t _stdin < <(__bud__get_stdin_from_json_object "${_json_object}")
  mapfile -t _script < <(__bud__compose_script_from_json_object "${_json_object}")
  _shell="$(__bud__compose_shell_from_json_object "${_json_object}")"

  mkdir -p "$(__bud__directory_for_output)"
  local _i _exit_code
  for _i in "${_stdin[@]}"; do
    echo "${_i}"
  done | ${_shell} <(for _i in "${_script[@]}"; do
    echo "${_i}"
  done | tee "$(__bud__file_for_script)") >"$(__bud__file_for_stdout)" 2>"$(__bud__file_for_stderr)" &&
    _exit_code=$? ||
    _exit_code=$?
  message "exit_code:'${_exit_code}'"
  echo "${_exit_code}" >"$(__bud__file_for_exit_code)"
}

run_json_object "$(jq '.run' "tests/example.json")"
