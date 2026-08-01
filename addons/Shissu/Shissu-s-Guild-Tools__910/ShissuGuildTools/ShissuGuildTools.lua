-- Shissu GuildTools 3
----------------------
-- Version: v3.5.18
-- Last Update: 19.12.2020
-- Written by Christian Flory (@Shissu) - esoui@flory.one                                                 
-- Distribution without license is prohibited!

local _addon = {}
_addon.Name = "ShissuGuildTools"
_addon.Version = "3.5.18"
_addon.formattedName	= "|c82FA58Shissu|ceeeeee's Guild Tools"

function _addon.EVENT_ADD_ON_LOADED(_, addonName)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)