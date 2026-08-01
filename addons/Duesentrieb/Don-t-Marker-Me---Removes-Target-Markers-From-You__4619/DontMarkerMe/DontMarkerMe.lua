DontMarkerMe = {
    NAME = "DontMarkerMe",
    AUTHOR = "@Duesentrieb",
    VERSION = "20260609-0001",
    CHAT = "|cFF7F00[Don't Marker Me]|r",

    playerName = "",

	Default = {
		enableAddon = true, -- /dontmarkerme
        enableDebug = false, --/script DontMarkerMe.SV.enableDebug = true / false
	},

    SV = {},
    SVVersion = 1,
    SVName = "DontMarkerMeVariables",
}

local DMM = DontMarkerMe

function DMM.OnTargetMarkerUpdate()
	local playerMarker = GetUnitTargetMarkerType("player")
	if not playerMarker or playerMarker == "" or playerMarker == 0 then return end

	local reticleoverName = GetUnitName("reticleover")
	if not reticleoverName or reticleoverName == "" then reticleoverName = DMM.playerName end

	if reticleoverName == DMM.playerName then
		AssignTargetMarkerToReticleTarget(playerMarker)
        if DMM.SV.enableDebug then
            d(DMM.CHAT .. " |cFFFFFFMarker (ID: " .. tostring(playerMarker) .. ") removed!")
        end
        EVENT_MANAGER:UnregisterForEvent(DMM.NAME .. "EVENT_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED)
	else
        EVENT_MANAGER:RegisterForEvent(DMM.NAME .. "EVENT_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED, DMM.OnTargetMarkerUpdate)
    end
end

function DMM.Enable()
    DMM.playerName = GetUnitName("player")
    EVENT_MANAGER:RegisterForEvent(DMM.NAME .. "EVENT_TARGET_MARKER_UPDATE", EVENT_TARGET_MARKER_UPDATE, DMM.OnTargetMarkerUpdate)
end

function DMM.Disable()
	EVENT_MANAGER:UnregisterForEvent(DMM.NAME .. "EVENT_TARGET_MARKER_UPDATE", EVENT_TARGET_MARKER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(DMM.NAME .. "EVENT_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED)
end

function DMM.Initialize()
    DMM.SV = ZO_SavedVars:NewAccountWide(DMM.SVName, DMM.SVVersion, GetWorldName(), DMM.Default)
	if DMM.SV.enableAddon then
		DMM.Enable()
	end
end

SLASH_COMMANDS["/dontmarkerme"] = function()
    DMM.SV.enableAddon = not DMM.SV.enableAddon
    if DMM.SV.enableAddon then
		DMM.Enable()
        d(DMM.CHAT .. " |c00FF00Enabled!")
    else
		DMM.Disable()
        d(DMM.CHAT .. " |cFF0000Disabled!")
    end
end

EVENT_MANAGER:RegisterForEvent(DMM.NAME, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == DMM.NAME then
        DMM.Initialize()
        EVENT_MANAGER:UnregisterForEvent(DMM.NAME, EVENT_ADD_ON_LOADED)
    end
end)