-- Shissu GuildTools 3
----------------------
-- File: SGT.lua
-- Version: v3.4.0
-- Last Update: 24.05.2019
-- Written by Christian Flory (@Shissu) - esoui@flory.one                                                 
-- Distribution without license is prohibited!

local _addon = {}
_addon.Name	= "ShissuGuildTools"
_addon.Version = "3.4.0"
_addon.formattedName	= "|c82FA58Shissu|ceeeeee's Guild Tools"

function _addon.EVENT_ADD_ON_LOADED()
  d(_addon.formattedName .. " " .. _addon.Version)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)