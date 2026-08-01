function CF.OnAddonLoaded(_, addonName)
    if (addonName == "LibDebugLogger") then
        CF.Logger = _G.LibDebugLogger(CF.Name)
    end

    -- only execute the rest of the code for this addon
    if (addonName ~= CF.Name) then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(CF.Name, EVENT_ADD_ON_LOADED)

    -- saved variables
    CF.Vars =
        _G.LibSavedVars:NewAccountWide("CompanionFrameSavedVars", "Account", CF.Defaults):AddCharacterSettingsToggle(
        "CompanionFrameSavedVars",
        "Characters"
    )

    -- get current language
    CF.Language = GetCVar("language.2")

    CF.Initialise()
end

function CF.Initialise()
    CF.GetCompanionInfo()
    CF.CreateCompanionFrame()
    CF.RegisterEvents()
    CF.RegisterSettings()
    _G.SLASH_COMMANDS["/cfset"] = CF.SlashCommand
end

function CF.RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(CF.Name, EVENT_ACTIVE_COMPANION_STATE_CHANGED, CF.OnCompanionStateChanged)
    EVENT_MANAGER:RegisterForEvent(CF.Name, EVENT_COMPANION_EXPERIENCE_GAIN, CF.OnCompanionExperienceUpdate)
    EVENT_MANAGER:RegisterForEvent(CF.Name, EVENT_COMPANION_RAPPORT_UPDATE, CF.OnCompanionRapportUpdate)
    EVENT_MANAGER:RegisterForEvent(CF.Name, EVENT_PLAYER_ACTIVATED, CF.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(CF.Name, EVENT_POWER_UPDATE, CF.OnPowerUpdate)
    EVENT_MANAGER:RegisterForEvent(CF.Name, EVENT_UNIT_CREATED, CF.OnUnitCreated)
    EVENT_MANAGER:RegisterForEvent(
        CF.Name,
        EVENT_ZONE_CHANGED,
        function()
            zo_callLater(
                function()
                    CF.OnZoneChange()
                end,
                1000
            )
        end
    )
end

-- helper function for logging. If LibDebugLogger is not present, nothing will happen
function CF.Log(message, severity)
    if (CF.Logger) then
        if (severity == "info") then
            CF.Logger:Info(message)
        elseif (severity == "warn") then
            CF.Logger:Warn(message)
        elseif (severity == "debug") then
            CF.Logger:Debug(message)
        end
    end
end

CF.Necrom = GetCompanionCollectibleId(8) ~= 0

local companions = {
    [9245] = "BASTIAN",
    [9353] = "MIRRI",
    [9911] = "EMBER",
    [9912] = "ISOBEL",
}

if (CF.Necrom) then
    companions[11113] = "SHARPASNIGHT"
    companions[11114] = "AZANDER"
end

function CF.GetCompanionInfo()
    for id, companion in pairs(companions) do
        local name, _, icon = GetCollectibleInfo(id)

        CF[companion] = { CollectibleId = id}
        CF[companion].Name = name
        CF[companion].Icon = icon
    end
end

EVENT_MANAGER:RegisterForEvent(CF.Name, EVENT_ADD_ON_LOADED, CF.OnAddonLoaded)
