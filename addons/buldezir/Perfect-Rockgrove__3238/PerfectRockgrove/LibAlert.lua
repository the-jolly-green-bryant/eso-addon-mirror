
local function bool2str(boolval)
    return boolval and "true" or "false"
end

-------------------------------------
--Base--
-------------------------------------
LibAlertBase = ZO_Object:Subclass()
function LibAlertBase:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end
function LibAlertBase:Initialize()
end

