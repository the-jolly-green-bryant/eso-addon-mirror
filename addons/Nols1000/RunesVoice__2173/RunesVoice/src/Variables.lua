-- Initalize RunesVoice to use as Table to store
-- the Addon in it.
if RunesVoice == nil then RunesVoice = {} end

-- Addons Variables
RunesVoice.variables = {
  version = 5,
  defaults = {
    debug_enable = true,
    debug_enable_info = false,
    debug_enable_warning = false,
    debug_enable_error = true,
    rach_enable = false
  },
  saved = {}
}
