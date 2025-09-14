# split trace string -> array, if present
if .context? and (.context.trace?|type=="string")
    then .context.trace |= split("\n")
    else .
end
