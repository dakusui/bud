set -eu
set -o pipefail
set -o errtrace
shopt -s inherit_errexit nullglob

function message() {
    echo "$*" >> log.txt
}

function abort() {
    local _exit_code=$?
    local _parent_pid
    local _my_pid
    trap
    _my_pid=$BASHPID
    _parent_pid="$(ps -o ppid= $_my_pid)"
    printf "abort: main pid: $$, bashpid: $BASHPID, parent=$_parent_pid, ppid: $PPID, exitcode: $_exit_code\n"
    if [[ $BASHPID != "$$" ]]; then
	message "killing: $_parent_pid"
	trap abort ABRT
	kill -9 "$_parent_pid"
    fi
    exit $_exit_code
}

function e() {
    local _parent_pid
    local _my_pid
    _my_pid=$BASHPID
    _parent_pid="$(ps -o ppid= $_my_pid)"
    message "e:     main pid: $$, bashpid: $BASHPID, parent=$_parent_pid, ppid: $PPID"
    trap
    cat notFound
    local _exit_code=$?
    message "e: shouldn't be executed:$_exit_code"
    return $_exit_code
}

function f() {
    local _parent_pid
    local _my_pid
    _my_pid=$BASHPID
    _parent_pid="$(ps -o ppid= $_my_pid)"
    message "f:     main pid: $$, bashpid: $BASHPID, parent=$_parent_pid, ppid: $PPID"
    message "$(g)"
}

function g() {
    local _parent_pid
    local _my_pid
    _my_pid=$BASHPID
    _parent_pid="$(ps -o ppid= $_my_pid)"
    message "g:     main pid: $$, bashpid: $BASHPID, parent=$_parent_pid, ppid: $PPID"
    message "$(e)"
}



trap abort ERR
trap abort ABRT
trap abort TRAP

trap
message "let's begin"
message "main:  main pid: $$, bashpid: $BASHPID, ppid: $PPID"

# cat -n <(cat notFound) <(echo Hello)
message "$(f)"
message "shouldn't be executed: $?"
trap
