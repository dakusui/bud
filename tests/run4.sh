source "$(dirname "$(dirname "${BASH_SOURCE[0]}")")/lib/opts.rc"

cat -n < <(bud_trap && cat notFound)
