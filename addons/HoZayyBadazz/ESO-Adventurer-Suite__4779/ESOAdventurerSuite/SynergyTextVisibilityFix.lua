-- ESO Adventurer Suite
-- v0.29.511 - restore native synergy action text when the icon/key remain visible.
-- ESO only refreshes the action label when the synergy name changes; this
-- additive fix reasserts the current native prompt without replacing ESO handlers.

local EPC = ESOProgressionCoach
if not EPC then return end

EPC.SynergyTextVisibilityFix = EPC.SynergyTextVisibilityFix or {}
local F = EPC.SynergyTextVisibilityFix

local EVENT_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_SynergyText029511"

local function BuildCurrentPrompt()
    if type(GetCurrentSynergyInfo) ~= "function" then return false, "" end

    local ok, hasSynergy, synergyName, _, prompt = pcall(GetCurrentSynergyInfo)
    if not ok or hasSynergy ~= true then return false, "" end

    prompt = tostring(prompt or "")
    synergyName = tostring(synergyName or "")

    if prompt == "" and synergyName ~= "" then
        if rawget(_G, "SI_USE_SYNERGY") and type(zo_strformat) == "function" then
            local formatOk, formatted = pcall(zo_strformat, SI_USE_SYNERGY, synergyName)
            if formatOk and type(formatted) == "string" and formatted ~= "" then
                prompt = formatted
            end
        end
        if prompt == "" then prompt = synergyName end
    end

    return true, prompt
end

function F:RestoreLiveText()
    local synergy = rawget(_G, "SYNERGY")
    if type(synergy) ~= "table" or not synergy.action then return false end

    local hasSynergy, prompt = BuildCurrentPrompt()
    if not hasSynergy then return false end

    local action = synergy.action
    if prompt ~= "" and type(action.SetText) == "function" then
        pcall(action.SetText, action, prompt)
    end
    if type(action.SetHidden) == "function" then
        pcall(action.SetHidden, action, false)
    end
    if type(action.SetAlpha) == "function" then
        pcall(action.SetAlpha, action, 1)
    end

    -- Keep ESO's own stock prompt control visible. Do not touch shared-information
    -- logical availability; only repair the visual label when a real synergy exists.
    if synergy.control and type(synergy.control.SetHidden) == "function" then
        pcall(synergy.control.SetHidden, synergy.control, false)
    end

    return true
end

function F:InstallHook()
    local synergy = rawget(_G, "SYNERGY")
    if type(synergy) ~= "table" then return false end
    if self.hooked then return true end

    if type(SecurePostHook) == "function" and type(synergy.OnSynergyAbilityChanged) == "function" then
        SecurePostHook(synergy, "OnSynergyAbilityChanged", function()
            local fix = EPC.SynergyTextVisibilityFix
            if fix then fix:RestoreLiveText() end
        end)
    end

    self.hooked = true
    self:RestoreLiveText()
    return true
end

local function RefreshAfterEvent()
    F:InstallHook()
    F:RestoreLiveText()
    if type(zo_callLater) == "function" then
        -- Some UI/scene state changes finish just after the native event.
        zo_callLater(function() F:RestoreLiveText() end, 25)
        zo_callLater(function() F:RestoreLiveText() end, 100)
    end
end

if EVENT_SYNERGY_ABILITY_CHANGED then
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX, EVENT_SYNERGY_ABILITY_CHANGED, RefreshAfterEvent)
end
if EVENT_PLAYER_ACTIVATED then
    EVENT_MANAGER:RegisterForEvent(EVENT_PREFIX .. "_Activated", EVENT_PLAYER_ACTIVATED, RefreshAfterEvent)
end

if type(zo_callLater) == "function" then
    zo_callLater(RefreshAfterEvent, 500)
    zo_callLater(RefreshAfterEvent, 1500)
else
    RefreshAfterEvent()
end
