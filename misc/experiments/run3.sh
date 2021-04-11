source "$(dirname "$(dirname "${BASH_SOURCE[0]}")")/lib/bud.rc"

cat -n < <(bud_trap && cat notFound)
