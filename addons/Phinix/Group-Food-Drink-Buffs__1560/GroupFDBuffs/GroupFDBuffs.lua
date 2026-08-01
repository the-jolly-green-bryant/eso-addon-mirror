-------------------------------------------------------------------------------
-- Group Food & Drink Buffs
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2015-2022 James A. Keene (Phinix) All rights reserved.
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

local GroupFDB = _G['GroupFDB']
local L = GroupFDB:GetLanguage()
local version = "1.21"

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Check for group food or drink buffs and display on group frames.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function ProcessFrameIcons(parent, numAuras, unitTag, groupSlot, groupSize, cPos, rPos, x, y)-- set icon size & texture and anchor to the group frames
	local function AddFoodBuffIndicator(iconFile, bID) -- show/hide and resize food & drink icon based on settings.
		local gXO = GroupFDB.ASV.gXO
		local gYO = GroupFDB.ASV.gYO
		local rXO = GroupFDB.ASV.rXO
		local rYO = GroupFDB.ASV.rYO
		local function OnMouseEnter(aura)
			InitializeTooltip(InformationTooltip, aura, TOPRIGHT, 0, - 2, BOTTOMLEFT)
			local abilityDescription = ""
			if GroupFDB.fdbDB[bID].itemID ~= 0 then
				_, _, abilityDescription = GetItemLinkOnUseAbilityInfo("|H1:item:"..tostring(GroupFDB.fdbDB[bID].itemID)..":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
			end
			if abilityDescription ~= "" then
				SetTooltipText(InformationTooltip, abilityDescription)
			else
				InformationTooltip:SetAbilityId(bID)
			end
		end
		local function OnMouseExit()
			ClearTooltip(InformationTooltip)
		end
		local control = GetControl('GroupFDB_FoodBuffControl'..groupSlot)
		control:ClearAnchors()
		control:SetTexture(iconFile)
		control:SetHandler('OnMouseEnter', OnMouseEnter)
		control:SetHandler('OnMouseExit', OnMouseExit)
		control:SetMouseEnabled(true)

		if groupSize <= 4 and GroupFDB.ASV.showGroup then
			control:SetDimensions(GroupFDB.ASV.groupSize, GroupFDB.ASV.groupSize)
			control:SetAnchor(cPos, parent, rPos, x + gXO, y + gYO)
			control:SetHidden(false)
		elseif groupSize >= 5 and GroupFDB.ASV.showRaid then
			control:SetDimensions(GroupFDB.ASV.raidSize, GroupFDB.ASV.raidSize)
			control:SetAnchor(cPos, parent, rPos, x + rXO, y + rYO)
			control:SetHidden(false)
		end
	end
	if not IsUnitDead(unitTag) and IsUnitOnline(unitTag) then
		local hasBuff = 0
		if numAuras > 0 then
			for i = 1, numAuras do
				local _, _, _, _, _, iconFile, _, _, _, _, bID = GetUnitBuffInfo(unitTag, i)
				if GroupFDB.fdbDB[bID] ~= nil then
					if GroupFDB.fdbDB[bID].buffType == 1 and GroupFDB.ASV.showJunk then -- Junk Food
						AddFoodBuffIndicator('/GroupFDBuffs/bin/junk_food.dds', bID)
					elseif GroupFDB.fdbDB[bID].buffType == 2 and GroupFDB.ASV.showJunk then -- Junk Drink
						AddFoodBuffIndicator('/GroupFDBuffs/bin/junk_drink.dds', bID)
					elseif GroupFDB.ASV.showActive then
						AddFoodBuffIndicator(iconFile, bID)
					end
					hasBuff = hasBuff + 1
				end
			end
		end
		if hasBuff == 0 then
			if GroupFDB.ASV.showNone then
				AddFoodBuffIndicator('/GroupFDBuffs/bin/no_food.dds', bID)
			end
		end
	end
end

local function GetFrameControls(groupSize, s, numAuras, unitTag) -- get the group frame control to anchor to, supports various addons
	local groupMode = GroupFDB.ASV.groupMode
	local raidMode = GroupFDB.ASV.raidMode
	local function defaultGroup() ---------------------------------------------------------------------- Default group frame configuration
		local groupSlot = tonumber(tostring(unitTag:gsub("%a",'')))
		local control = GetControl('ZO_GroupUnitFramegroup'..groupSlot..'Name')
		ProcessFrameIcons(control, numAuras, unitTag, groupSlot, groupSize, RIGHT, LEFT, -34, 8)
		return
	end
	local function defaultRaid() ----------------------------------------------------------------------- Default raid frame configuration
		local groupSlot = tonumber(tostring(unitTag:gsub("%a",'')))
		local control = GetControl('ZO_RaidUnitFramegroup'..groupSlot)
		ProcessFrameIcons(control, numAuras, unitTag, groupSlot, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
		return
	end

	if groupSize <= 4 then
		if groupMode == 1 then
			defaultGroup()
		elseif groupMode == 2 then --------------------------------------------------------------------- Group frame support for Foundry Tactical Combat
			if FTC_VARS then
				local EnableFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].EnableFrames
				local GroupFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].GroupFrames
				if (EnableFrames == true and GroupFrames == true) then
					local control = GetControl('FTC_GroupFrame'..s..'_Health')
					ProcessFrameIcons(control, numAuras, unitTag, s, groupSize, TOPLEFT, TOPRIGHT, 4, -25)
					return
				else
					defaultGroup()
				end
			else
				defaultGroup()
			end
		elseif groupMode == 3 then --------------------------------------------------------------------- Group frame support for Lui Extended
			if LUIESV then
				local EnableFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames_Enabled
				local GroupFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames.CustomFramesGroup
				if (EnableFrames == true and GroupFrames == true) then
					local function getLUIframe()
						for i = 1, 4 do
							local frame = 'SmallGroup'..i
							local uT = LUIE.UnitFrames.CustomFrames[frame].unitTag
							if uT == unitTag then
								return i
							end
						end
						return 0
					end
					local frame = getLUIframe()
					if frame ~= 0 then
						local control = LUIE.UnitFrames.CustomFrames['SmallGroup'..frame].control
						ProcessFrameIcons(control, numAuras, unitTag, frame, groupSize, TOPLEFT, TOPRIGHT, 4, -28)
					end
					return
				else
					defaultGroup()
				end
			else
				defaultGroup()
			end
		elseif groupMode == 4 then --------------------------------------------------------------------- Group frame support for Bandits User Interface 
			if BUI_VARS then
				local EnableFrames = BUI.Vars.RaidFrames
				if EnableFrames == true then
					local groupSlot = tonumber(tostring(unitTag:gsub("%a",'')))
					local control = GetControl('BUI_RaidFrame'..s)
					ProcessFrameIcons(control, numAuras, unitTag, groupSlot, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
					return
				else
					defaultGroup()
				end
			else
				defaultGroup()
			end
		elseif groupMode == 5 then --------------------------------------------------------------------- Group frame support for AUI
			if AUI_Main then
				local EnableFrames = AUI_Main.Default[GetDisplayName()]["$AccountWide"].modul_unit_frames_enabled
				local EnableGroup = (AUI_Attributes) and AUI_Attributes.Default[GetDisplayName()]["$AccountWide"].group_unit_frames_enabled or false
				if (EnableFrames) and (EnableGroup) then
					local groupSlot = tostring(unitTag:gsub("%a",''))
					local gTemplate = AUI_Templates.Default[GetDisplayName()]["$AccountWide"]["Attributes"]["Group"]
					local gFrame = ""
					if gTemplate == "AUI" then
						gFrame = "AUI_GroupFrame"
					elseif gTemplate == "AUI_TESO" then
						gFrame = "TESO_GroupFrame"
					elseif gTemplate == "AUI_Tactical" then
						gFrame = "AUI_Tactical_GroupFrame"
					end
					local control = GetControl(gFrame..groupSlot)
					ProcessFrameIcons(control, numAuras, unitTag, groupSlot, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
					return
				else
					defaultGroup()
				end
			else
				defaultGroup()
			end
		end
	elseif groupSize >= 5 then
		if raidMode == 1 then
			defaultRaid()
		elseif raidMode == 2 then ---------------------------------------------------------------------- Raid frame support for Foundry Tactical Combat
			if FTC_VARS then
				local EnableFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].EnableFrames
				local RaidFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].RaidFrames
				if (EnableFrames == true and RaidFrames == true) then
					local control = GetControl('FTC_RaidFrame'..s)
					ProcessFrameIcons(control, numAuras, unitTag, s, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
					return
				else
					defaultRaid()
				end
			else
				defaultRaid()
			end
		elseif raidMode == 3 then ---------------------------------------------------------------------- Raid frame support for Lui Extended
			if LUIESV then
				local EnableFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames_Enabled
				local RaidFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames.CustomFramesRaid
				if (EnableFrames == true and RaidFrames == true) then
					local function getLUIframe()
						for i = 1, 24 do
							local frame = 'RaidGroup'..i
							if LUIE.UnitFrames.CustomFrames[frame] then
								local uT = LUIE.UnitFrames.CustomFrames[frame].unitTag
								if uT == unitTag then
									return i
								end
							end
						end
						return 0
					end
					local frame = getLUIframe()
					if frame ~= 0 then
						local control = LUIE.UnitFrames.CustomFrames['RaidGroup'..frame].control
						ProcessFrameIcons(control, numAuras, unitTag, frame, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
					end
					return
				else
					defaultRaid()
				end
			else
				defaultRaid()
			end
		elseif raidMode == 4 then ---------------------------------------------------------------------- Raid frame support for Bandits User Interface 
			if BUI_VARS then
				local EnableFrames = BUI.Vars.RaidFrames
				if EnableFrames == true then
					local groupSlot = tonumber(tostring(unitTag:gsub("%a",'')))
					local control = GetControl('BUI_RaidFrame'..s)
					ProcessFrameIcons(control, numAuras, unitTag, groupSlot, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
					return
				else
					defaultRaid()
				end
			else
				defaultRaid()
			end
		elseif raidAuraMode == 5 then ------------------------------------------------------------------ Raid frame support for AUI
			if AUI_Main then
				local EnableFrames = AUI_Main.Default[GetDisplayName()]["$AccountWide"].modul_unit_frames_enabled
				local EnableRaid = (AUI_Attributes) and AUI_Attributes.Default[GetDisplayName()]["$AccountWide"].raid_unit_frames_enabled or false
				if (EnableFrames) and (EnableRaid) then
					local raidSlot = tonumber(tostring(unitTag:gsub("%a",'')))
					local rTemplate = AUI_Templates.Default[GetDisplayName()]["$AccountWide"]["Attributes"]["Raid"]
					local rFrame = ""
					if rTemplate == "AUI" then
						rFrame = "AUI_RaidFramegroup"
					elseif rTemplate == "AUI_Tactical" then
						rFrame = "AUI_Tactical_RaidFramegroup"
					end
					local control = GetControl(rFrame..raidSlot)
					ProcessFrameIcons(control, numAuras, unitTag, raidSlot, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
					return
				else
					defaultRaid()
				end
			else
				defaultRaid()
			end
		end
	end
end

local function OnGroupChanged() -- re-process food & drink icons when group size changes
	for g = 1, 24 do
		local control = GetControl('GroupFDB_FoodBuffControl'..g)
		if control then
			control:SetHidden(true)
		end
	end
	if IsUnitGrouped("player") then
		local groupSize = GetGroupSize()
		for s = 1, groupSize do
			local unitTag = GetGroupUnitTagByIndex(s)
			if (DoesUnitExist(unitTag)) then
				local numAuras = GetNumBuffs(unitTag)
				GetFrameControls(groupSize, s, numAuras, unitTag)
			end
		end
	end
end

local function OnEffectChanged() -- detect food or drink buff gained or lost
	OnGroupChanged()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize the addon and start the buff tracker.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow(addonName) -- setup the addon settings panel
	local dropGroupMode = {L.GroupFDB_Mode1, L.GroupFDB_Mode2, L.GroupFDB_Mode3, L.GroupFDB_Mode4, L.GroupFDB_Mode5}
	local dropGroupModeValues = {[L.GroupFDB_Mode1]=1, [L.GroupFDB_Mode2]=2, [L.GroupFDB_Mode3]=3, [L.GroupFDB_Mode4]=4, [L.GroupFDB_Mode5]=5}

	local panelData = {
		type					= "panel",
		name					= L.GroupFDB_Title,
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize(L.GroupFDB_Title),
		author					= "|c66ccffPhinix|r",
		version					= version,
		registerForRefresh		= true,
		registerForDefaults		= true,
	}

	local optionsData = {
	{
		type = "header",
		name = ZO_HIGHLIGHT_TEXT:Colorize(L.GroupFDB_GOpts),
	},
	{
		type			= 'checkbox',
		name			= L.GroupFDB_SGF,
		tooltip			= L.GroupFDB_SGFD,
		getFunc			= function() return GroupFDB.ASV.showGroup end,
		setFunc			= function(value)
							GroupFDB.ASV.showGroup = value
							OnGroupChanged()
						end,
		default			= GroupFDB.AccountDefaults.showGroup,
	},
	{
		type			= 'checkbox',
		name			= L.GroupFDB_SRF,
		tooltip			= L.GroupFDB_SRFD,
		getFunc			= function() return GroupFDB.ASV.showRaid end,
		setFunc			= function(value)
							GroupFDB.ASV.showRaid = value
							OnGroupChanged()
						end,
		default			= GroupFDB.AccountDefaults.showRaid,
	},
	{
		type			= 'checkbox',
		name			= L.GroupFDB_SAB,
		tooltip			= L.GroupFDB_SABD,
		getFunc			= function() return GroupFDB.ASV.showActive end,
		setFunc			= function(value)
							GroupFDB.ASV.showActive = value
							OnGroupChanged()
						end,
		default			= GroupFDB.AccountDefaults.showActive,
	},
	{
		type			= 'checkbox',
		name			= L.GroupFDB_SJB,
		tooltip			= L.GroupFDB_SJBD,
		getFunc			= function() return GroupFDB.ASV.showJunk end,
		setFunc			= function(value)
							GroupFDB.ASV.showJunk = value
							OnGroupChanged()
						end,
		default			= GroupFDB.AccountDefaults.showJunk,
	},
	{
		type			= 'checkbox',
		name			= L.GroupFDB_SNB,
		tooltip			= L.GroupFDB_SNBD,
		getFunc			= function() return GroupFDB.ASV.showNone end,
		setFunc			= function(value)
							GroupFDB.ASV.showNone = value
							OnGroupChanged()
						end,
		default			= GroupFDB.AccountDefaults.showNone,
	},
	{
		type			= 'dropdown',
		name			= L.GroupFDB_GMode,
		tooltip			= L.GroupFDB_GModeD,
		choices			= dropGroupMode,
		getFunc			= function()
							for k, v in pairs(dropGroupModeValues) do
								if v == GroupFDB.ASV.groupMode then
									return k
								end
							end
						end,
		setFunc			= function(v)
							local sVal = dropGroupModeValues[v]
							GroupFDB.ASV.groupMode = sVal
							OnGroupChanged()
						end,
	--	scrollable		= 7,
		default			= GroupFDB.AccountDefaults.groupMode,
	},
	{
		type			= 'dropdown',
		name			= L.GroupFDB_RMode,
		tooltip			= L.GroupFDB_RModeD,
		choices			= dropGroupMode,
		getFunc			= function()
							for k, v in pairs(dropGroupModeValues) do
								if v == GroupFDB.ASV.raidMode then
									return k
								end
							end
						end,
		setFunc			= function(v)
							local sVal = dropGroupModeValues[v]
							GroupFDB.ASV.raidMode = sVal
							OnGroupChanged()
						end,
	--	scrollable		= 7,
		default			= GroupFDB.AccountDefaults.raidMode,
	},
	{
		type			= 'dropdown',
		name			= L.GroupFDB_GIS,
		tooltip			= L.GroupFDB_GISD,
		choices			= { 8 , 16 , 24 , 32 },
		getFunc			= function() return GroupFDB.ASV.groupSize end,
		setFunc			= function(v)
							GroupFDB.ASV.groupSize = v
							OnGroupChanged()
						end,
	--	scrollable		= 7,
		default			= GroupFDB.AccountDefaults.groupSize,
	},
	{
		type			= 'dropdown',
		name			= L.GroupFDB_RIS,
		tooltip			= L.GroupFDB_RISD,
		choices			= { 8 , 16 , 24 , 32 },
		getFunc			= function() return GroupFDB.ASV.raidSize end,
		setFunc			= function(v)
							GroupFDB.ASV.raidSize = v
							OnGroupChanged()
						end,
	--	scrollable		= 7,
		default			= GroupFDB.AccountDefaults.raidSize,
	},
	{
		type			= 'slider',
		name			= L.GroupFDB_GXIO,
		tooltip			= L.GroupFDB_GXIOD,
		min				= -512,
		max				= 512,
		step			= 1,
		getFunc			= function() return GroupFDB.ASV.gXO end,
		setFunc			= function(value)
							GroupFDB.ASV.gXO = value
							OnGroupChanged()
						end,
		default			= GroupFDB.AccountDefaults.gXO,
	},
	{
		type			= 'slider',
		name			= L.GroupFDB_GYIO,
		tooltip			= L.GroupFDB_GYIOD,
		min				= -64,
		max				= 64,
		step			= 1,
		getFunc			= function() return GroupFDB.ASV.gYO end,
		setFunc			= function(value)
							GroupFDB.ASV.gYO = value
							OnGroupChanged()
						end,
		default			= GroupFDB.AccountDefaults.gYO,
	},
	{
		type			= 'slider',
		name			= L.GroupFDB_RXIO,
		tooltip			= L.GroupFDB_RXIOD,
		min				= -128,
		max				= 256,
		step			= 1,
		getFunc			= function() return GroupFDB.ASV.rXO end,
		setFunc			= function(value)
							GroupFDB.ASV.rXO = value
							OnGroupChanged()
						end,
		default			= GroupFDB.AccountDefaults.rXO,
	},
	{
		type			= 'slider',
		name			= L.GroupFDB_RYIO,
		tooltip			= L.GroupFDB_RYIOD,
		min				= -32,
		max				= 64,
		step			= 1,
		getFunc			= function() return GroupFDB.ASV.rYO end,
		setFunc			= function(value)
							GroupFDB.ASV.rYO = value
							OnGroupChanged()
						end,
		default			= GroupFDB.AccountDefaults.rYO,
	},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("GroupFDB_Panel", panelData)
	LAM:RegisterOptionControls("GroupFDB_Panel", optionsData)
end

local function ReadyCheck() -- Sends a ready check to the group
	ZO_SendReadyCheck()
end

local function InitCallbacks() -- setup hiding icons with the hud and responding to various events

	-- Properly initialize the group and raid frame icons for the enabled type
	GroupFDB.ASV.groupMode = 1
	GroupFDB.ASV.raidMode = 1
	if BUI_VARS then
		local EnableFrames = BUI.Vars.RaidFrames
		if EnableFrames == true then
			GroupFDB.ASV.groupMode = 4
			GroupFDB.ASV.raidMode = 4
		end
	end
	if LUIESV then
		local EnableFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames_Enabled
		local GroupFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames.CustomFramesGroup
		local RaidFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames.CustomFramesRaid
		if (EnableFrames == true and GroupFrames == true) then
			GroupFDB.ASV.groupMode = 3
		end
		if (EnableFrames == true and RaidFrames == true) then
			GroupFDB.ASV.raidMode = 3
		end
	end
	if FTC_VARS then
		local EnableFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].EnableFrames
		local GroupFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].GroupFrames
		local RaidFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].RaidFrames
		if (EnableFrames == true and GroupFrames == true) then
			GroupFDB.ASV.groupMode = 2
		end
		if (EnableFrames == true and RaidFrames == true) then
			GroupFDB.ASV.raidMode = 2
		end
	end
	if AUI_Main then
		local EnableFrames = AUI_Main.Default[GetDisplayName()]["$AccountWide"].modul_unit_frames_enabled
		local GroupFrames = (AUI_Attributes) and AUI_Attributes.Default[GetDisplayName()]["$AccountWide"].group_unit_frames_enabled or false
		local RaidFrames = (AUI_Attributes) and AUI_Attributes.Default[GetDisplayName()]["$AccountWide"].raid_unit_frames_enabled or false
		if (EnableFrames) and (GroupFrames) then
			GroupFDB.ASV.groupMode = 5
		end
		if (EnableFrames) and (RaidFrames) then
			GroupFDB.ASV.raidMode = 5
		end
	end
	OnGroupChanged()

	-- Setup callbacks and events
	local hudScene = SCENE_MANAGER:GetScene("hud")
	hudScene:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_HIDDEN then
			if SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
				for i = 1, 24 do
					local control = GetControl('GroupFDB_FoodBuffControl'..i)
					if control then
						control:SetHidden(true)
					end
				end
			end
		end
		if newState == SCENE_SHOWN then
			OnGroupChanged()
		end
	end)

	EVENT_MANAGER:RegisterForEvent('GroupFDBuffs', EVENT_GROUP_TYPE_CHANGED, OnGroupChanged)
	EVENT_MANAGER:RegisterForEvent('GroupFDBuffs', EVENT_GROUP_MEMBER_JOINED, OnGroupChanged)
	EVENT_MANAGER:RegisterForEvent('GroupFDBuffs', EVENT_GROUP_MEMBER_LEFT, OnGroupChanged)
	EVENT_MANAGER:RegisterForEvent('GroupFDBuffs', EVENT_GROUP_UPDATE, OnGroupChanged)
	EVENT_MANAGER:RegisterForEvent('GroupFDBuffs', EVENT_PLAYER_ALIVE, OnGroupChanged)
	EVENT_MANAGER:RegisterForEvent('GroupFDBuffs', EVENT_PLAYER_DEAD, OnGroupChanged)

	--OnEffectChanged triggers too often. For performance only listen for abilityID of food/drink effects in the GroupFDB.fdbDB table
	for abilityID, _ in pairs(GroupFDB.fdbDB) do
		EVENT_MANAGER:RegisterForEvent('GroupFDBuffs_' ..tostring(abilityID), EVENT_EFFECT_CHANGED, OnEffectChanged)
		EVENT_MANAGER:AddFilterForEvent('GroupFDBuffs_' ..tostring(abilityID), EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityID)
	end
end

local function OnAddonLoaded(event, addonName) -- main addon initialization
	if addonName ~= 'GroupFDBuffs' then return end
	EVENT_MANAGER:UnregisterForEvent('GroupFDBuffs', EVENT_ADD_ON_LOADED)
	GroupFDB.ASV = ZO_SavedVars:NewAccountWide('GroupFDBuffs', 1.0, 'AccountSettings', GroupFDB.AccountDefaults)
	InitCallbacks()
	CreateSettingsWindow(addonName)
end

SLASH_COMMANDS['/ready'] = ReadyCheck
EVENT_MANAGER:RegisterForEvent('GroupFDBuffs', EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent('GroupFDBuffs', EVENT_PLAYER_ACTIVATED, OnGroupChanged)
