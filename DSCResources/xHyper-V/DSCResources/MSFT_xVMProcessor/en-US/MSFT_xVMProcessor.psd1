ConvertFrom-StringData @'
    QueryingVMProcessor          = Querying VM '{0}' processor(s).
    PropertyMismatch             = Property '{0}' mismatch; expected value '{1}', but was '{2}'.
    VMProcessorInDesiredState    = VM '{0}' processor(s) in desired state.
    VMProcessorNotInDesiredState = VM '{0}' processor(s) not in desired state.
    UpdatingVMProperties         = Updating VM '{0}' properties..
    VMPropertiesUpdated          = VM '{0}' properties have been updated.

    VMNotFoundError              = VM '{0}' was not found.
    UnsupportedSystemError       = Parameter '{0}' is not supported on operating system builds earlier than '{1}'.
    CannotUpdateVmOnlineError    = Cannot change online property '{0}' unless 'RestartIfNeeded' is set to true.
'@
