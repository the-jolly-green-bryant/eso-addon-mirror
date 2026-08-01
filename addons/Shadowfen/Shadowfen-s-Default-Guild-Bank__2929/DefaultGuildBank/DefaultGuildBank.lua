--[[
Copyright (c) 2021 Dolores Scott
All rights reserved.
See LICENSE file for terms.
]]

local SF = LibSFUtils
local LL = LibLanguage
local color = SF.hex

local SGB = DefaultGuildBank

-------------------------------
-- saved variable defaults for both aw and toon
SGB.Defaults = {
	dgb_enabled = true,
}
-- saved variable tables
local toon = {}
local saved = {}

local function isValidGuildId(id)
	for i,v in ipairs(SF.GetActiveGuildIds()) do
		if v == id then
		    return true
		end
	end
	return false
end

local gbsession = false

-- onGuildBankSelected
function SGB.onGuildBankSelected(_, guildId)
	
	if SGB.saved.dgb_enabled == false then return end
	if gbsession == true then return end
	--d("opening id 2: "..tostring(SGB.saved.defaultGuildId))
	
	local defaultGuildId
	if SGB.saved.defaultGuildId == nil then 
		defaultGuildId = GetGuildId(1) 
	else
		defaultGuildId = SGB.saved.defaultGuildId
	end	
	
	if gbsession == false then
		gbsession = true
		dGuildId = defaultGuildId
	else
		dGuildId = guildId
	end
	SGB.restoreLast(dGuildId)
	zo_callLater(function()
		ZO_SharedInventory_SelectAccessibleGuildBank(dGuildId)
	end, 100)
end

-- onCloseGuildBank
function SGB.onCloseGuildBank()
	gbsession = false
	if SGB.saved.dgb_enabled == true and isValidGuildId(SGB.saved.defaultGuildId) == true then
		SGB.restoreLast(SGB.saved.defaultGuildId)
	end
--	if SGB.saved.dgb_enabled == false then return end
end

function SGB.isAccountWide()
	return toon.accountWide
end


function SGB.setCurrentSV(newval)
    SGB.saved = SF.currentSavedVars(SGB.aw, SGB.toon, newval)
end

local pending = false
function SGB.restoreLast(lastid)
    if pending == false then
		pending = true
		ZO_SharedInventory_SelectAccessibleGuildBank(lastid)
		--zo_callLater(function()
		--	PLAYER_INVENTORY.lastSuccessfulGuildBankId = lastid
		--	pending = false
		--end, 2000)
	end
end

function SGB.enabled() 
	if SGB.saved.dgb_enabled == false then return end
	if isValidGuildId(SGB.saved.defaultGuildId) == true then
		SGB.restoreLast(SGB.saved.defaultGuildId)
	end
	EVENT_MANAGER:RegisterForEvent(SGB.name, EVENT_GUILD_BANK_SELECTED, SGB.onGuildBankSelected)
	EVENT_MANAGER:RegisterForEvent(SGB.name, EVENT_CLOSE_GUILD_BANK, SGB.onCloseGuildBank)
end

function SGB.disabled() 
	EVENT_MANAGER:UnregisterForEvent(SGB.name, EVENT_GUILD_BANK_SELECTED)
	EVENT_MANAGER:UnregisterForEvent(SGB.name, EVENT_CLOSE_GUILD_BANK)
	SGB.restoreLast(SGB.origLast)
end

local function onPlayerActivated(ev, init)

	SGB.origLast = PLAYER_INVENTORY.lastSuccessfulGuildBankId
	if isValidGuildId(SGB.origLast) == false then
		SGB.origLast = SF.GetActiveGuildIds()[1]
	end
	if SGB.saved.dgb_enabled == true and isValidGuildId(SGB.saved.defaultGuildId) == true then
		SGB.restoreLast(SGB.saved.defaultGuildId)
	else
		SGB.restoreLast(SGB.origLast)
	end
	SGB.enabled()
end


local function onAddonLoaded(ev, addonName)
	if addonName ~= SGB.name then return end
	
	EVENT_MANAGER:UnregisterForEvent(SGB.name, EVENT_ADD_ON_LOADED)

	-- manage saved variables
    SGB.aw, SGB.toon = SF.getAllSavedVars("DefaultGuildBankVars", 1, SGB.Defaults)
    toon = SGB.toon
	
	SGB.setCurrentSV()
	saved = SGB.saved
	
	-- settings page
	SGB.RegisterSettings()

	EVENT_MANAGER:RegisterForEvent(SGB.name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(SGB.name, EVENT_ADD_ON_LOADED, onAddonLoaded)

