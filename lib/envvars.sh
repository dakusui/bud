"${__BUD__ENVVARS_SH:-false}" && return 0
readonly __BUD__ENVVARS_SH=true

####
# A value to specify the parameter is absent in a request.
# This variable is useful for a non-mandatory parameter.
BUD_VOID="BUD_VOID:$(echo -n BUD_VOID | md5sum | cut -d ' ' -f 1)"

export BUD_DEBUG="${BUD_DEBUG:-disabled}"
export BUD_ERROR="${BUD_ERROR:-enabled}"
export BUD_VOID
export BUD_LOG_FILE=${BUD_LOG_FILE:-""}
