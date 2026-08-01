if EzStalking == nil then EzStalking = { } end
local EzStalking = _G['EzStalking']
local L = { }

-- [[ Menu ]]
L.menu = { }
L.menu.header                           = "Settings"
local substring_description1            = "Select if and where you want Encounter Logging to automatically start."
local substring_description2            = "Please note: If enabled, it automatically disables logging outside of specified places."
L.menu.description                      = substring_description1 .. "\n" .. substring_description2 -- do not edit

L.menu.accountwide                      = "Accountwide settings"
L.menu.accountwide_tooltip              = "Share settings across all characters."

L.menu.logging_enabled                  = "Automatic logging"
L.menu.logging_enabled_tooltip          = "Enable automatic encounter logging"

L.menu.normal_difficulty                = "Log normal runs (w/ confirmation)"
L.menu.normal_difficulty_tooltip        = "Asks you on every normal instance you join if you want to log the run."

L.menu.use_dialog                       = "Confirmation dialog"
L.menu.use_dialog_tooltip               = "Asks if you want to log a run instead of automatically logging."

L.menu.remember_zone                    = "Remember Zone"
L.menu.remember_zone_tooltip            = "Remember your decision for instanced zone so it will not ask again until you enter another instanced zone."

L.menu.location = { }                   -- [[ Location Menu]]
L.menu.location.header                  = "Locations"
local substring_housing                 = "Player Housing"
L.menu.location.housing_tooltip         = "Enable automatic logging in player houses."
L.menu.location.housing                 = substring_housing -- do not edit

local substring_arenas                  = "Arenas"
L.menu.location.arenas_tooltip          = "Enable automatic logging in solo and group arenas."
L.menu.location.arenas                  = substring_arenas -- do not edit

local substring_dungeons                = "Dungeons"
L.menu.location.dungeons_tooltip        = "Enable automatic logging in dungeons."
L.menu.location.dungeons                = substring_dungeons -- do not edit

local substring_endless                 = "Endless"
L.menu.location.endless_tooltip         = "Enable automatic logging in endless dungeons."
L.menu.location.endless                 = substring_endless -- do not edit

local substring_trials                  = "Trials"
L.menu.location.trials_tooltip          = "Enable automatic logging in trials."
L.menu.location.trials                  = substring_trials -- do not edit

local substring_battlegrounds           = "Battlegrounds"
L.menu.location.battlegrounds_tooltip   = "Enable automatic logging in battlegrounds."
L.menu.location.battlegrounds           = substring_battlegrounds -- do not edit

local substring_imperial_city           = "Imperial City"
L.menu.location.imperial_city_tooltip   = "Enable automatic logging in the Imperial City"
L.menu.location.imperial_city           = substring_imperial_city -- do not edit

local substring_cyrodiil                = "Cyrodiil"
L.menu.location.cyrodiil_tooltip        = "Enable automatic logging in Cyrodil"
L.menu.location.cyrodiil                = substring_cyrodiil -- do not edit

L.menu.indicator = { }                  -- [[ Indicator Menu ]]
L.menu.indicator.header                 = "Indicator"
local substring_enabled                 = "Enabled"
L.menu.indicator.enabled_tooltip        = "Shows a small on-screen indcator whether logging is currently enabled or not."
L.menu.indicator.enabled                = substring_enabled -- do not edit

local substring_locked                  = "Lock"
L.menu.indicator.locked_tooltip         = "Locks indicator in place. While unlocked, indicator color is inverted."
L.menu.indicator.locked                 = substring_locked -- do not edit

local substring_color                   = "Color"
L.menu.indicator.color_tooltip          = "Select the color for the indicator."
L.menu.indicator.color                  = substring_color -- do not edit

-- [[ Dialogs ]]
L.dialog = { }
L.dialog.logging = { }                  -- [[ Logging Dialog ]]
L.dialog.logging.title                  = "Encounterlog"
L.dialog.logging.text                   = "Do you want to start logging this run?"

-- [[ Slash Command Arguments ]]
L.slash_command = { }                   -- [[ Slash Command Arguments]]
L.slash_command.lock                    = "lock"
L.slash_command.unlock                  = "unlock"
L.slash_command.anonymous               = "anonymous"
L.slash_command.named                   = "named"
L.slash_command.combat_only             = "combatonly"

-- [[ Messages ]]
L.message = { }
L.message.logging = { }                 -- [[ Logging Messages ]]
L.message.logging.enabled               = GetString(SI_ENCOUNTER_LOG_ENABLED_ALERT) -- do not edit
L.message.logging.disabled              = GetString(SI_ENCOUNTER_LOG_DISABLED_ALERT) -- do not edit

L.message.anonymity = { }               -- [[ Anonimity Messages ]]
L.message.anonymity.preamble            = "You will now"
L.message.anonymity.anonymous           = "appear anonymous."
L.message.anonymity.named               = "share your character name."

L.message.indicator = { }               -- [[ Indicator Messages ]]
local substring_warn_unlocked           = "WARNING: on-screen indicator is unlocked!"
L.message.indicator.warn_unlocked       = "|cff0000" .. substring_warn_unlocked .. "|r" -- do not edit

local substring_or                      = "or"
local substring_lock                    = "lock on-screen indicator."
local substring_unlock                  = "unlock on-screen indicator."
local substring_anonymous               = "set yourself to appear anonymous in encounter logs"
local substring_named                   = "share your character name in encouter logs."
local substring_note                    = "NOTE: Logs in progress will not update your anonymity setting."
local substring_empty                   = "nothing"
local substring_toggle                  = "toggle encounter logging."
local substring_combat_only             = "encounterlog is only turned on when you are in combat."

L.message.slash_command = { }           -- [[ Slash Command Messages]]
L.message.slash_command.options         = "Options are:"
L.message.slash_command.combat_only_info= "Combat only mode is: "
--[[
        Do not edit the following lines!
        They will be properly translated if you have translated everything above.
--]]
L.message.slash_command.lock            = "|cab7337" .. L.slash_command.lock .. "|r - " .. substring_lock
L.message.slash_command.unlock          = "|cab7337" .. L.slash_command.unlock .. "|r - " .. substring_unlock
L.message.slash_command.anonymous       = "|cab7337" .. L.slash_command.anonymous .. "|r " .. substring_or .. " |cab7337" .. zo_strsub(L.slash_command.anonymous, 1, 1) .. "|r - " .. substring_anonymous
L.message.slash_command.named           = "|cab7337" .. L.slash_command.named .. "|r " .. substring_or .. " |cab7337" .. zo_strsub(L.slash_command.named, 1, 1) .. "|r - " .. substring_named
L.message.slash_command.combat_only     = "|cab7337" .. L.slash_command.combat_only .. "|r " .. substring_combat_only
L.message.slash_command.note            = "|cff3737" .. substring_note .. "|r"
L.message.slash_command.toggle          = "|cab7337<" .. substring_empty .. ">|r - " .. substring_toggle
-- [[ continue editing below ]]

-- [[ Keybindings ]]
local kb = { }
kb.SI_BINDING_NAME_EZSTALKING_TOGGLE_LOGGING = "Toggle Encounterlog"

for i, v in pairs(kb) do
    ZO_CreateStringId(i, v)
end

function EzStalking:GetLocale()
    return L
end