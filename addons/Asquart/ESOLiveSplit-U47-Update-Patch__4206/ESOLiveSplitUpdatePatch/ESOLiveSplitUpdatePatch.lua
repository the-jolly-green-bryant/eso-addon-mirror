ESLUP = ESLUP or {}
local ESLUP = ESLUP

ESLUP.name     = "ESOLiveSplitUpdatePatch"
ESLUP.version  = "1.1"
ESLUP.author   = "|c24abfe@Asquart|r"

ESLUP.splitsToRegister = {}

local SplitManagerFound = false

function RegisterPatchSplits()
    for registrationName, registrationFunc in pairs(ESLUP.splitsToRegister) do
        if registrationFunc ~= nil then
            registrationFunc()
        end
    end
end

function ESLUP.OnAddonLoaded(_, addonName)
	if addonName ~= ESLUP.name then
		return
	end

    if SPLIT_MANAGER ~= nil then
        RegisterPatchSplits()
            zo_callLater(function()
                d("SplitManager found")
            end, 10000)
    else
        zo_callLater(function()
            d("SplitManager not found")
        end, 10000)
    end

	EVENT_MANAGER:UnregisterForEvent(ESLUP.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ESLUP.name, EVENT_ADD_ON_LOADED, ESLUP.OnAddonLoaded)