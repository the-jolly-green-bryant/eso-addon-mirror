local C = EOTU_Config or { ADDON_NAME = "Eyes Of The Undaunted", NAME_SHORT = "EOTU" }
local EyesOfTheUndaunted = ZO_InitializingObject:Subclass()

EyesOfTheUndaunted.addOnName = C.ADDON_NAME
EyesOfTheUndaunted.addOnDisplayName = "Eyes of the Undaunted"
EyesOfTheUndaunted.APIVersion = GetAPIVersion()
EyesOfTheUndaunted.internal = {}

local function GetAddOnInfos()
    local addOnManager = GetAddOnManager()
    for i = 1, addOnManager:GetNumAddOns() do
        local name, _, author = addOnManager:GetAddOnInfo(i)
        if name == EyesOfTheUndaunted.addOnName then
            return author, addOnManager:GetAddOnVersion(i)
        end
    end
end
EyesOfTheUndaunted.author, EyesOfTheUndaunted.version = GetAddOnInfos()

local previous = _G[C.NAME_SHORT] or EOTU
if type(previous) == "table" then
    setmetatable(EyesOfTheUndaunted, { __index = previous })
end
_G[C.NAME_SHORT] = EyesOfTheUndaunted
if _G[C.NAME_SHORT].dbg then
    _G[C.NAME_SHORT].dbg("Startup completed. Version " .. tostring(_G[C.NAME_SHORT].version))
end
