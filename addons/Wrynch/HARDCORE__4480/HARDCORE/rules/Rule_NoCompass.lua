local HARDCORE = HARDCORE

local Rule = {
    id = "NoCompass",
    title = "No compass",
    icon = "/esoui/art/addons/gamepad/gp_mod_listing_category_mapandcompass.dds",
    defaultEnabled = true,
}

-- Internal state
Rule.active = false
Rule._eventsRegistered = false

-- Helpers -------------------------------------------------------------

local function SetCompassHidden(hidden)
    if COMPASS_FRAME and COMPASS_FRAME.SetCompassHidden then
        COMPASS_FRAME:SetCompassHidden(hidden)
    end
end

local function ApplyHidden()
    if not Rule.active then
        return
    end
    SetCompassHidden(true)
end

local function ApplyHiddenDeferred()
    ApplyHidden()
    zo_callLater(ApplyHidden, 100)
    zo_callLater(ApplyHidden, 500)
end

local function RegisterEvents()
    if Rule._eventsRegistered then
        return
    end
    EVENT_MANAGER:RegisterForEvent("HARDCORE_NoCompass_Activated", EVENT_PLAYER_ACTIVATED, ApplyHiddenDeferred)
    EVENT_MANAGER:RegisterForEvent("HARDCORE_NoCompass_Alive", EVENT_PLAYER_ALIVE, ApplyHiddenDeferred)
    Rule._eventsRegistered = true
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent("HARDCORE_NoCompass_Activated", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent("HARDCORE_NoCompass_Alive", EVENT_PLAYER_ALIVE)
    Rule._eventsRegistered = false
end

function Rule:OnEnable()
    self.active = true
    RegisterEvents()
    SetCompassHidden(true)
    ApplyHiddenDeferred()
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
    SetCompassHidden(false)
end

HARDCORE.RuleManager:RegisterRule(Rule)

return Rule
