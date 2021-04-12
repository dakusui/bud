function f1() {
    echo "f1: pid: $$, bashpid: $BASHPID, PPID: $PPID"
    echo
    echo $(f2)
}

function f2() {
    echo "f2: pid: $$, bashpid: $BASHPID, PPID: $PPID"
    echo
    echo $(f3)
}

function f3() {
    echo "f3: pid: $$, bashpid: $BASHPID, PPID: $PPID"
    echo
}


echo "main: pid: $$, bashpid: $BASHPID, PPID: $PPID"
f1
