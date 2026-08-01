
-- Addon
DPSMeterFix = {
    ['Name'] = "DPSMeterFix",
    ['Author'] = "voidbiscuit",
    ['Version'] = "0.1.1",
    ['VariableVersion'] = 1,
    ['APIVersion'] = "101034",
}
local DPSMeterFix = DPSMeterFix
DPSMeterFix.values = {}
--

-- Saved Variables
DPSMeterFix.saved_variables = {};
DPSMeterFix.default_saved_variables = {
    settings = {
        debug = false
    }
}
--

-- Debug
function DPSMeterFix:Debug(message, ...)
    if type(message) == type("") then
      message = string.format(message, ...);
      d(string.format("|cFFA500[%s]|r %s", self.Name, message))
    else
      self:Error("message must be a string, not %s", type(message))
    end
  end

--


-- Values
--[[
damageResultCategory, copied from Combat Metrics
More information about ActionResults:
 - https://wiki.esoui.com/Globals#ActionResult
 - https://wiki.esoui.com/Constant_Values#ACTION_RESULT_DAMAGE
]]
DPSMeterFix.values.damageResultCategory = {
    [ACTION_RESULT_DAMAGE] = true, -- "Normal",
    [ACTION_RESULT_DOT_TICK] = true, -- "Normal",
    [ACTION_RESULT_CRITICAL_DAMAGE] = true, -- "Critical",
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true, -- "Critical",
    [ACTION_RESULT_BLOCKED_DAMAGE] = true, -- "Blocked",
    [ACTION_RESULT_DAMAGE_SHIELDED] = true, -- "Shielded",
}
-- Local
local damageResultCategory = DPSMeterFix.values.damageResultCategory;
--

-- Functions
--[[
Some more info, I think my explanation is accurate although feel free to correct it if I'm wrong.

The original function, ZO_TargetDummyLog_Manager:HandleCombatEvent (found in esoui/esoui/ingame/combatlogs/targetdummylog.lua) determines two values when logging combat events:

local isFromMe = sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET
local isDPSEvent = hitValue > 0 and powerType ~= COMBAT_MECHANIC_FLAGS_INVALID

If a combat event results in damage being done, the `hitValue` parameter should contain a number greater than 0 representing the amount of damage done (insight from someone: "hitValue is the ever-flexible parameter. It contains duration in ms for things that last, or number of stacks when gaining a stacking debuff"). In ZOS's implementation of the function, they do not check whether an ability should be doing damage, and only check the `hitValue` parameter, resulting in extra values being used when calculating DPS.

If the `actionResult` of an combat event is one of the following, then the combat event may be treated as a damage combat event.

- ACTION_RESULT_DAMAGE
- ACTION_RESULT_DOT_TICK
- ACTION_RESULT_CRITICAL_DAMAGE
- ACTION_RESULT_DOT_TICK_CRITICAL
- ACTION_RESULT_BLOCKED_DAMAGE
- ACTION_RESULT_DAMAGE_SHIELDED

Combat Metrics seems to be aware if a combat event should be doing damage; ZOS's DPS Meter does not.

Oneliner
/script damageActionResults={[1]=0,[2]=0,[2151]=0,[2460]=0,[1073741825]=0,[1073741826]=0}; ZO_PreHook(ZO_TargetDummyLog_Manager,"HandleCombatEvent", function(_,actionResult) if damageActionResults[actionResult]==nil then return true end end);
]]

-- Original function
local ZO_TargetDummyLog_Manager_HandleCombatEvent = ZO_TargetDummyLog_Manager.HandleCombatEvent;
-- Patched function
function DPSMeterFix:HandleCombatEvent(actionResult, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, shouldLog, sourceUnitId, targetUnitId, abilityId)
    -- Patch
    -- If the action is not a damage action, then no damage should be registered
    if damageResultCategory[actionResult] == nil then
        -- Set the hit value to 0
        hitValue = 0
    end
    -- Debug
    if DPSMeterFix.saved_variables.settings.debug == true then
        -- Message and colour
        local message = string.format("[%s] hit for [%s]", abilityName, hitValue)
        local message_colour = 0 < hitValue and "|c00AA00" or "|cAA0000"
        -- Print
        DPSMeterFix:Debug(message_colour .. message .. "|r")
    end
    -- Call the original function
    ZO_TargetDummyLog_Manager_HandleCombatEvent(self, actionResult, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, shouldLog, sourceUnitId, targetUnitId, abilityId)
    -- Done
end
-- Overwrite function
ZO_TargetDummyLog_Manager.HandleCombatEvent = DPSMeterFix.HandleCombatEvent
--

-- Saved Variables
function DPSMeterFix:SavedVariables()
    self.saved_variables = ZO_SavedVars:NewAccountWide(self.Name.."SavedVariables", self.VariableVersion, nil, self.default_saved_variables, GetWorldName());
end
--

-- Menu
function DPSMeterFix:AddonMenu()
    -- LAM
    local LAM = LibAddonMenu2
    -- Create Panel
    local panel_name = self.Name.."SettingsPanel"
    local panel_data = {
        type = "panel",
        name = self.Name,
        author = self.Author
    }
    local panel = LAM:RegisterAddonPanel(panel_name, panel_data)
    -- Settings
    local options_data = {
        -- # General
        {
            type = "header",
            name = "Settings"
        },
        {
          type = "checkbox",
          name = "Debug",
          getFunc = function() return self.saved_variables.settings.debug end,
          setFunc = function(value) self.saved_variables.settings.debug = value end,
          default = self.default_saved_variables.settings.debug
        },
    }
    LAM:RegisterOptionControls(panel_name, options_data)
end
--


-- Addon Load
function DPSMeterFix:Initialize()
    -- Unregister addon load
    EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_ADD_ON_LOADED);
    -- Init
    self:SavedVariables();
    self:AddonMenu();
end

function DPSMeterFix.OnAddOnLoaded(event, addonName)
    if addonName == DPSMeterFix.Name then
        DPSMeterFix:Initialize()
    end
end

-- Register addon load
EVENT_MANAGER:RegisterForEvent(DPSMeterFix.Name, EVENT_ADD_ON_LOADED, DPSMeterFix.OnAddOnLoaded)
--