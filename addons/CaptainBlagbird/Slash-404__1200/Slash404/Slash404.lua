--[[

Slash 404
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Replace ZO_Alert function
local func_orig = ZO_Alert
ZO_Alert = function(category, soundId, message, ...)
    if (category == UI_ALERT_CATEGORY_ALERT) and (message == SI_ERROR_INVALID_COMMAND) then
        d(zo_strformat(message, ...))
    end
    return func_orig(category, soundId, message, ...)
end