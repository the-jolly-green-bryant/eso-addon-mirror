MCAT = {}

--#region[purple] Modules and locals
local Abilities = MCAT_Abilities
local Utils = MCAT_Utils
local Settings = MCAT_Settings
local Tracker = MCAT_Tracker
local Interface = MCAT_Interface
local EM = EVENT_MANAGER
--#endregion

-- Addon data
MCAT.name = "MultiClassAbilityTracker"
MCAT.version = "0.1.0"

-- Addon state
MCAT.isInitialized = false

-- Visible requires being slotted, enabled in settings, and (in combat or Debug Mode is
-- on) (MCAT.InCombat, set by MCAT_Tracker's EVENT_PLAYER_COMBAT_STATE handler) so a bar
-- swap out of combat can't reveal a counter early; this is the one place that rule is computed.
function MCAT.ActionBarUpdated()
    for mechanicKey, def in pairs(MCAT_Definitions) do
        local slotted
        if def.skillMap then
            slotted = Abilities.IsAbilitySlotted(def.skillMap)
        else
            -- Crux has no skillMap (skill-line-wide, not tied to one hotbar-slotted skill id)
            slotted = Abilities.CruxGenerationKnown()
        end
        local tracked = slotted and MCAT_Settings.IsEnabled(mechanicKey)
        MCAT.State[mechanicKey].visible = tracked and (MCAT.InCombat or MCAT_Settings.IsDebugEnabled())
        Utils.LogDebug(mechanicKey .. " would track in combat: " .. tostring(tracked))
    end
    Interface.Update()
end

--#region[yellow] Init
function MCAT.Initialize()

    Settings.Initialize() -- must exist before Interface reads scale/spacing, and before Tracker's first ActionBarUpdated() call
    Interface.Initialize()
    Tracker.Initialize() -- seeds the initial ActionBarUpdated() call itself, once MCAT.InCombat is known

    EM:RegisterForEvent(MCAT.name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, MCAT.ActionBarUpdated)

    MCAT.isInitialized = true
    Utils.LogDebug("Initialized")

end

function MCAT.OnAddonLoaded(eventCode, addonName)
    if addonName ~= MCAT.name then return end

    MCAT.Initialize()

    EM:UnregisterForEvent(MCAT.name, EVENT_ADD_ON_LOADED)
end
--#endregion

EM:RegisterForEvent(MCAT.name, EVENT_ADD_ON_LOADED, MCAT.OnAddonLoaded)