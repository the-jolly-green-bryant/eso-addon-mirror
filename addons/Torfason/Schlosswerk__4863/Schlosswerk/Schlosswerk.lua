local SW = Schlosswerk

function SW:RegisterSlashCommands()
    SLASH_COMMANDS["/schlosswerk"] = function(text)
        local command = string.lower((text or ""):gsub("^%s+", ""):gsub("%s+$", ""))

        if command == "" then
            SW:OpenSettings()
            return
        end

        if command == "status" then
            local modeName = SW.db.selectionMode == "random" and SW:L("MODE_RANDOM") or SW:L("MODE_FIXED")
            local pinLights = SW.db.pinLights and SW:L("CHAT_ON") or SW:L("CHAT_OFF")
            local avoidRepeat = SW.db.avoidImmediateRepeat and SW:L("CHAT_ON") or SW:L("CHAT_OFF")
            SW:Print(string.format(
                SW:L("CHAT_STATUS"),
                SW.version,
                modeName,
                SW:GetStyleName(SW.db.fixedStyle),
                pinLights,
                avoidRepeat
            ))
            return
        end

        if command == "help" or command == "hilfe" then
            SW:Print(SW:L("CHAT_HELP"))
            return
        end

        SW:Print(SW:L("CHAT_HELP"))
    end
end

function SW:Initialize()
    self.db = ZO_SavedVars:NewAccountWide(
        self.savedVariablesName,
        self.savedVariablesVersion,
        GetWorldName(),
        self.defaultSettings
    )

    self:SanitizeSettings()
    self:RegisterSettings()
    self:InstallPinLightingHooks()
    self:RegisterSlashCommands()

    EVENT_MANAGER:RegisterForEvent(self.name .. "_BeginLockpick", EVENT_BEGIN_LOCKPICK, function()
        SW:OnBeginLockpick()
    end)
end

local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= SW.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(SW.name, EVENT_ADD_ON_LOADED)
    SW:Initialize()
end

EVENT_MANAGER:RegisterForEvent(SW.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
