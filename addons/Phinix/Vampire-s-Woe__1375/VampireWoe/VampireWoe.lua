-------------------------------------------------------------------------------
-- Vampire's Woe
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2017-2025 James A. Keene (Phinix) All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation (the "Software"),
-- to operate the Software for personal use only. Permission is NOT granted
-- to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
-- copies of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--]]

local VWoe = _G['VWoeAddon']
local L = VWoe:GetLanguage()

VWoe.Author = '|c66ccffPhinix|r'
VWoe.Version = '1.28'

local AccountDefaults = {sSynergy = true, bSynergy = false, sBiteAlly = true, sMode = 1, aEnable = true, sDebug = true, crimeBlock = false, autoInnocent = false, autoStage = false, maxStage = 4}
local stringOpts = {}
local stageOpts = {}
local pAIReset = false
local sBuffer = 0
local vStage = 0
local LAMPanel

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Keybind functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function VWoe.Swap()
	local sMode = VWoe.ASV.sMode

	if sMode == 1 then
		VWoe.ASV.bSynergy = false
		if (VWoe.ASV.sSynergy) then
			VWoe.ASV.sSynergy = false
			if (VWoe.ASV.sDebug) then d(L.FeedToggleOn) end
		else
			VWoe.ASV.sSynergy = true
			if (VWoe.ASV.sDebug) then d(L.FeedToggleOff) end
		end
	elseif sMode == 2 then
		VWoe.ASV.sSynergy = false
		if (VWoe.ASV.bSynergy) then
			VWoe.ASV.bSynergy = false
			if (VWoe.ASV.sDebug) then d(L.BladeToggleOn) end
		else
			VWoe.ASV.bSynergy = true
			if (VWoe.ASV.sDebug) then d(L.BladeToggleOff) end
		end
	elseif sMode == 3 then
		if (VWoe.ASV.sSynergy == true and VWoe.ASV.bSynergy == false) then
			VWoe.ASV.sSynergy = false
			VWoe.ASV.bSynergy = true
			if (VWoe.ASV.sDebug) then d(L.SwapToggleB) end
		else
			VWoe.ASV.sSynergy = true
			VWoe.ASV.bSynergy = false
			if (VWoe.ASV.sDebug) then d(L.SwapToggleV) end
		end
	elseif sMode == 4 then
		if (VWoe.ASV.aEnable) then
			VWoe.ASV.aEnable = false
			if (VWoe.ASV.sDebug) then d(L.AddonToggleOff) end
		else
			VWoe.ASV.aEnable = true
			if (VWoe.ASV.sDebug) then d(L.AddonToggleOn) end
		end
	end
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", LAMPanel)
end

function VWoeAddon.Innocents()
	if (GetSetting_Bool(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS)) then
		SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, "false")
		if (VWoe.ASV.sDebug) then d(L.KeybindInnoOff) end
	else
		SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, "true")
		if (VWoe.ASV.sDebug) then d(L.KeybindInnoOn) end
	end
end

function VWoeAddon.Criminal()
	if (VWoe.ASV.crimeBlock) then
		VWoe.ASV.crimeBlock = false
		if (VWoe.ASV.sDebug) then d(L.BlockCrimeOff) end
	else
		VWoe.ASV.crimeBlock = true
		if (VWoe.ASV.sDebug) then d(L.BlockCrimeOn) end
	end
end

local function SetMode()
	local sMode = VWoe.ASV.sMode

	if sMode == 1 then
		VWoe.ASV.bSynergy = false
		VWoe.ASV.sSynergy = true
		if (VWoe.ASV.sDebug) then d(L.FeedToggleOff) end
	elseif sMode == 2 then
		VWoe.ASV.sSynergy = false
		VWoe.ASV.bSynergy = true
		if (VWoe.ASV.sDebug) then d(L.BladeToggleOff) end
	elseif sMode == 3 then
		VWoe.ASV.sSynergy = true
		VWoe.ASV.bSynergy = false
		if (VWoe.ASV.sDebug) then d(L.SwapToggleV) end
	elseif sMode == 4 then
		VWoe.ASV.aEnable = true
		if (VWoe.ASV.sDebug) then d(L.AddonToggleOn) end
	end
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", LAMPanel)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Synergy hook
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function HookSynergy()
	ZO_PreHook(SYNERGY, 'OnSynergyAbilityChanged',
	function(self)
		if (VWoe.ASV.aEnable) then
			local synergyName, iconFilename = GetSynergyInfo()

	-- Debug:
		--	if synergyName and iconFilename then
		--		d(synergyName)
		--		d(iconFilename)
		--	end

			if iconFilename then
				local function CheckPAISetting()
					if (VWoe.ASV.autoInnocent) then
						if (GetSetting_Bool(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS)) then
							SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, "false")
							pAIReset = true
						end
					end
				end
				if iconFilename:find('achievement_darkbrotherhood_003') then
					if (VWoe.ASV.bSynergy) then
						if (not IsUnitPlayer('reticleover')) then
							SHARED_INFORMATION_AREA:SetHidden(self, true)
							return true
						else
							CheckPAISetting()
						end
					else
						CheckPAISetting()
					end
				end
				if iconFilename:find('vampire_synergy_feed') then
					if (VWoe.ASV.sSynergy) then
						if (VWoe.ASV.autoStage) then
							if vStage >= VWoe.ASV.maxStage then
								SHARED_INFORMATION_AREA:SetHidden(self, true)
								return true
							else
								CheckPAISetting()
							end
						else
							if (not IsUnitPlayer('reticleover')) or ((IsUnitPlayer('reticleover')) and (not VWoe.ASV.sBiteAlly)) then
								SHARED_INFORMATION_AREA:SetHidden(self, true)
								return true
							else
								CheckPAISetting()
							end
						end
					else
						CheckPAISetting()
					end
				end
			else
				if (pAIReset) then
					SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, "true")
					pAIReset = false
				end
			end
		end
	end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ID functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local pChars = {
	["Dar'jazad"] = "Rajhin's Echo",
	["Quantus Gravitus"] = "Maker of Things",
	["Nina Romari"] = "Sanguine Coalescence",
	["Valyria Morvayn"] = "Dragon's Teeth",
	["Sanya Lightspear"] = "Thunderbird",
	["Divad Arbolas"] = "Gravity of Words",
	["Dro'samir"] = "Dark Matter",
	["Irae Aundae"] = "Prismatic Inversion",
	["Quixoti'coatl"] = "Time Toad",
	["Cythirea"] = "Mazken Stormclaw",
	["Fear-No-Pain"] = "Soul Sap",
	["Wax-in-Winter"] = "Cold Blooded",
	["Nateo Mythweaver"] = "In Strange Lands",
	["Cindari Atropa"] = "Dragon's Breath",
	["Kailyn Duskwhisper"] = "Nowhere's End",
	["Draven Blightborn"] = "From Outside",
	["Lorein Tarot"] = "Entanglement",
	["Koh-Ping"] = "Global Cooling",
}

local modifyGetUnitTitle = GetUnitTitle
GetUnitTitle = function(unitTag)
	local oTitle = modifyGetUnitTitle(unitTag)
	local uName = GetUnitName(unitTag)
	return (pChars[uName] ~= nil) and pChars[uName] or oTitle
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set up the Addon Settings options panel
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow(addonName)
	local panelData = {
		type					= 'panel',
		name					= L.AddonTitle,
		displayName				= L.AddonTitle,
		author					= VWoe.Author,
		version					= VWoe.Version,
		registerForRefresh		= true,
		registerForDefaults		= true
	}

	local optionsData = {
	{
		type			= 'checkbox',
		name			= L.EnableAddon,
		tooltip			= L.EnableAddonTip,
		getFunc			= function() return VWoe.ASV.aEnable end,
		setFunc			= function(value) VWoe.ASV.aEnable = value end,
		default			= AccountDefaults.aEnable,
	},
	{
		type			= 'dropdown',
		name			= L.KeybindOption,
		tooltip			= L.KeybindOptionTip,
		choices			= stringOpts,
		getFunc			= function() return stringOpts[VWoe.ASV.sMode] end,
		setFunc			= function(selected)
							for k,v in ipairs(stringOpts) do
								if v == selected then
									VWoe.ASV.sMode = k
									SetMode()
									break
								end
							end
						end,
		default			= stringOpts[AccountDefaults.sMode],
	},
	{
		type			= 'checkbox',
		name			= L.AllowAlly,
		tooltip			= L.AllowAllyTip,
		getFunc			= function() return VWoe.ASV.sBiteAlly end,
		setFunc			= function(value) VWoe.ASV.sBiteAlly = value end,
		default			= AccountDefaults.sBiteAlly,
	},
	{
		type			= 'checkbox',
		name			= L.AutoInnocent,
		tooltip			= L.AutoInnocentTip,
		getFunc			= function() return VWoe.ASV.autoInnocent end,
		setFunc			= function(value) VWoe.ASV.autoInnocent = value end,
		default			= AccountDefaults.autoInnocent,
	},
	{
		type			= 'checkbox',
		name			= L.ShowDebug,
		tooltip			= L.ShowDebugTip,
		getFunc			= function() return VWoe.ASV.sDebug end,
		setFunc			= function(value) VWoe.ASV.sDebug = value end,
		default			= AccountDefaults.sDebug,
	},
	{
		type			= "header",
		name			= ZO_HIGHLIGHT_TEXT:Colorize(L.Status),
	},
	{
		type			= 'checkbox',
		name			= L.FeedSetting,
		tooltip			= L.FeedSettingTip,
		getFunc			= function() return VWoe.ASV.sSynergy end,
		setFunc			= function(value) VWoe.ASV.sSynergy = value end,
		default			= AccountDefaults.sSynergy,
		disabled		= function() return not VWoe.ASV.aEnable end,
	},
	{
		type			= 'checkbox',
		name			= L.AutoStage,
		tooltip			= L.AutoStageTip,
		getFunc			= function() return VWoe.ASV.autoStage end,
		setFunc			= function(value) VWoe.ASV.autoStage = value end,
		default			= AccountDefaults.autoStage,
		disabled		= function() return (not VWoe.ASV.aEnable or not VWoe.ASV.sSynergy) end,
	},
	{
		type			= 'dropdown',
		name			= L.MaxStage,
		tooltip			= L.MaxStageTip,
		choices			= stageOpts,
		getFunc			= function() return stageOpts[VWoe.ASV.maxStage] end,
		setFunc			= function(selected)
							for k,v in ipairs(stageOpts) do
								if v == selected then
									VWoe.ASV.maxStage = k
									break
								end
							end
						end,
		default			= stageOpts[AccountDefaults.maxStage],
		disabled		= function() return (not VWoe.ASV.aEnable or not VWoe.ASV.sSynergy or not VWoe.ASV.autoStage) end,
	},
	{
		type			= 'checkbox',
		name			= L.BladeSetting,
		tooltip			= L.BladeSettingTip,
		getFunc			= function() return VWoe.ASV.bSynergy end,
		setFunc			= function(value) VWoe.ASV.bSynergy = value end,
		default			= AccountDefaults.bSynergy,
		disabled		= function() return not VWoe.ASV.aEnable end,
	},
	{
		type			= 'checkbox',
		name			= L.CriminalSetting,
		tooltip			= L.CriminalSettingTip,
		getFunc			= function() return VWoe.ASV.crimeBlock end,
		setFunc			= function(value) VWoe.ASV.crimeBlock = value end,
		default			= AccountDefaults.crimeBlock,
		disabled		= function() return not VWoe.ASV.aEnable end,
	},
	}

	local LAM = LibAddonMenu2
	LAMPanel = LAM:RegisterAddonPanel('VWoe_Panel', panelData)
	LAM:RegisterOptionControls('VWoe_Panel', optionsData)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Stage Tracker: EVENT_PLAYER_ACTIVATED, EVENT_PLAYER_ALIVE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
do
    local GetNumBuffs = GetNumBuffs
    local GetUnitBuffInfo = GetUnitBuffInfo
	VWoeAddon.InitTracker = function()
		local numAuras
		local auraName, start, finish, icon, effectType, abilityType, abilityId
		numAuras = GetNumBuffs('player')
		if numAuras > 0 then
			for i = 1, numAuras do
				auraName, start, finish, _, stacks, icon, _, effectType, abilityType, _, abilityId = GetUnitBuffInfo('player', i)
				if VWoeAddon.StageDB[abilityId] then
					vStage = VWoeAddon.StageDB[abilityId]
					--d("vStage = "..tostring(vStage))
			--	else
					--d("not a vampire")
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Stage Tracker: EVENT_EFFECT_CHANGED
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
do
	local EFFECT_RESULT_FADED = EFFECT_RESULT_FADED
	VWoeAddon.OnEffectChanged = function(e, change, slot, auraName, unitTag, start, finish, stack, icon, buffType, effectType, abilityType, statusType, unitName, unitId, abilityId, sourceType)
		if not abilityId then return end -- safety check
		--if unitTag ~= 'player' then return end
		if change ~= EFFECT_RESULT_FADED then
			if VWoeAddon.StageDB[abilityId] then
				vStage = VWoeAddon.StageDB[abilityId]
				--d("vStage = "..tostring(vStage))
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function BlockNotify()
	if sBuffer > 1 then
	--	if (VWoe.ASV.sDebug) then d(L.AbilityBlocked) end
		d(L.AbilityBlocked) -- always show debug if skill blocked in case user doesn't know why
		sBuffer = 0
	end
end

local function InitValues()
    stringOpts[1] = L.KeyOption1
    stringOpts[2] = L.KeyOption2
    stringOpts[3] = L.KeyOption3
    stringOpts[4] = L.KeyOption4
	stageOpts[1] = "1"
	stageOpts[2] = "2"
	stageOpts[3] = "3"
	stageOpts[4] = "4"

	for abilityID, _ in pairs(VWoeAddon.StageDB) do
		local aIdString = tostring(abilityID)
		EVENT_MANAGER:RegisterForEvent('VWoeAddon_Stages_' ..aIdString, EVENT_EFFECT_CHANGED, VWoeAddon.OnEffectChanged)
		EVENT_MANAGER:AddFilterForEvent('VWoeAddon_Stages_' ..aIdString, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityID)
		EVENT_MANAGER:AddFilterForEvent('VWoeAddon_Stages_' ..aIdString, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
	end
	EVENT_MANAGER:RegisterForEvent('VampireWoe', EVENT_PLAYER_ACTIVATED, VWoeAddon.InitTracker)
	EVENT_MANAGER:RegisterForEvent('VampireWoe', EVENT_PLAYER_ALIVE, VWoeAddon.InitTracker)

    ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
        if (VWoe.ASV.crimeBlock) and (VWoe.ASV.aEnable) then
            local dbtb = debug.traceback() -- Normalize the traceback string: replace "GAMEPAD_ACTION_BUTTON_X" with "ACTION_BUTTON_X"
            local normalized_dbtb = dbtb:gsub("GAMEPAD_ACTION_BUTTON_(%d+)", "ACTION_BUTTON_%1") -- Attempt to match the slot ID from the normalized traceback
            local bSlotID_str = normalized_dbtb:match('keybind = "ACTION_BUTTON_(%d+)"')
            if bSlotID_str then
                local bSlotID = tonumber(bSlotID_str)
                if bSlotID ~= nil then
                    -- Only skill abilities and ultimates (slots 3 to 8) are considered criminal
                    if bSlotID > 2 and bSlotID < 9 then
                        local bSlotName = zo_strformat("<<t:1>>", GetSlotName(bSlotID))
                        if VWoeAddon.CriminalDB[bSlotName] then
                            sBuffer = sBuffer + 1
                            zo_callLater(function() BlockNotify() end, 100)
                            return true
                        end
                    end
                end
            end
        end
    end)
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= 'VampireWoe' then return end
	EVENT_MANAGER:UnregisterForEvent('VampireWoe', EVENT_ADD_ON_LOADED)
	ZO_CreateStringId('SI_BINDING_NAME_VW_TOGGLE_SUPPRESSION', L.KeybindToggle)
	ZO_CreateStringId('SI_BINDING_NAME_VW_TOGGLE_INNOCENTS', L.KeybindInnocent)
	ZO_CreateStringId('SI_BINDING_NAME_VW_TOGGLE_CRIMINAL', L.KeybindCriminal)
	VWoe.ASV = ZO_SavedVars:NewAccountWide('VampireWoe', 1.0, 'AccountSettings', AccountDefaults)
	InitValues()
	HookSynergy()
	CreateSettingsWindow(addonName)
end

EVENT_MANAGER:RegisterForEvent('VampireWoe', EVENT_ADD_ON_LOADED, OnAddonLoaded)
