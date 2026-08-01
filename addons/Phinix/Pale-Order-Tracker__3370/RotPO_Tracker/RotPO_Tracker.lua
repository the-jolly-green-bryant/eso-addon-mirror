-------------------------------------------------------------------------------
-- Pale Order Tracker
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2022 James A. Keene (Phinix) All rights reserved.
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

local RPOTracker = _G['RPOTracker']
local L = RPOTracker:GetLanguage()
local version = "1.00"
local groupDelay = false
local settingsOpen = false
local RotPOPanel

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- anchor tracker icons to group/raid frames and display based on options
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function ProcessFrameIcons(parent, unitTag, groupSlot, groupSize, cPos, rPos, x, y)-- set icon size & texture and anchor to the group frames
	local function AddRingIndicator(iconFile) -- show/hide and resize tracker icon based on settings.
		local gXO = RPOTracker.ASV.gXO
		local gYO = RPOTracker.ASV.gYO
		local rXO = RPOTracker.ASV.rXO
		local rYO = RPOTracker.ASV.rYO
		local function OnMouseEnter(aura)
			InitializeTooltip(InformationTooltip, aura, TOPRIGHT, 0, - 2, BOTTOMLEFT)
			InformationTooltip:SetAbilityId(147414)
		end
		local function OnMouseExit()
			ClearTooltip(InformationTooltip)
		end
		local control = GetControl('RPOTracker_GroupControl'..groupSlot)
		control:ClearAnchors()
		control:SetTexture(iconFile)
		control:SetHandler('OnMouseEnter', OnMouseEnter)
		control:SetHandler('OnMouseExit', OnMouseExit)
		control:SetMouseEnabled(true)

		if groupSize <= 4 and RPOTracker.ASV.showGroup then
			control:SetDimensions(RPOTracker.ASV.groupSize, RPOTracker.ASV.groupSize)
			control:SetAnchor(cPos, parent, rPos, x + gXO, y + gYO)
			control:SetHidden(false)
		elseif groupSize >= 5 and RPOTracker.ASV.showRaid then
			control:SetDimensions(RPOTracker.ASV.raidSize, RPOTracker.ASV.raidSize)
			control:SetAnchor(cPos, parent, rPos, x + rXO, y + rYO)
			control:SetHidden(false)
		end
	end
	if not IsUnitDead(unitTag) and IsUnitOnline(unitTag) then
		local hasBuff = RPOTracker.ASV.groupTable[unitTag]
		if (hasBuff == nil) or (hasBuff == false) then
			local control = GetControl('RPOTracker_GroupControl'..groupSlot)
			control:SetHidden(true)
		elseif (hasBuff) then
			AddRingIndicator('/esoui/art/icons/antiquities_ornate_ring_4.dds')
		end
	end
end

local function GetFrameControls(groupSize, s, unitTag) -- get the group frame control to anchor to, supports various addons
	local groupMode = RPOTracker.ASV.groupMode
	local raidMode = RPOTracker.ASV.raidMode
	local function defaultGroup() ---------------------------------------------------------------------- Default group frame configuration
		local groupSlot = tonumber(tostring(unitTag:gsub("%a",'')))
		local control = GetControl('ZO_GroupUnitFramegroup'..groupSlot..'Name')
		ProcessFrameIcons(control, unitTag, groupSlot, groupSize, RIGHT, LEFT, -34, 8)
		return
	end
	local function defaultRaid() ----------------------------------------------------------------------- Default raid frame configuration
		local groupSlot = tonumber(tostring(unitTag:gsub("%a",'')))
		local control = GetControl('ZO_RaidUnitFramegroup'..groupSlot)
		ProcessFrameIcons(control, unitTag, groupSlot, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
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
					ProcessFrameIcons(control, unitTag, s, groupSize, TOPLEFT, TOPRIGHT, 4, -25)
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
						ProcessFrameIcons(control, unitTag, frame, groupSize, TOPLEFT, TOPRIGHT, 4, -28)
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
					ProcessFrameIcons(control, unitTag, groupSlot, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
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
					ProcessFrameIcons(control, unitTag, groupSlot, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
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
					ProcessFrameIcons(control, unitTag, s, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
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
						ProcessFrameIcons(control, unitTag, frame, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
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
					ProcessFrameIcons(control, unitTag, groupSlot, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
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
					ProcessFrameIcons(control, unitTag, raidSlot, groupSize, TOPRIGHT, TOPLEFT, 0, 0)
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

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- configure and refresh tracker display based on various conditions
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RPOTracker:ResetGroup(refresh) -- re-process tracker icons when group size changes
	RPOTracker:ConfigureTrackerIcon(2)
	if (refresh) then
		for g = 1, 24 do
			local control = GetControl('RPOTracker_GroupControl'..g)
			if control then control:SetHidden(true) end
		end
		self:OnGroupChanged()
	else
		if not groupDelay then
			groupDelay = true
			for g = 1, 24 do
				local gtag = 'group'..tostring(g)
				local control = GetControl('RPOTracker_GroupControl'..g)
				if control then control:SetHidden(true) end
				RPOTracker.ASV.groupTable[gtag] = false
			end
			zo_callLater(function() groupDelay = false end, 100)
		end
	end
end

function RPOTracker:OnGroupChanged()
	if SCENE_MANAGER.scenes.hud.state ~= "hidden" then
		if IsUnitGrouped("player") then
			local groupSize = GetGroupSize()
			for s = 1, groupSize do
				local unitTag = GetGroupUnitTagByIndex(s)
				if (DoesUnitExist(unitTag)) then
					GetFrameControls(groupSize, s, unitTag)
				else
					RPOTracker.ASV.groupTable[unitTag] = false
				end
			end
		end
	end
end

function RPOTracker:ConfigureTrackerIcon(option)
	local function GetAnchorRelativeToScreen(frame)
		local left, top		= frame:GetLeft(), frame:GetTop()
		local right, bottom	= frame:GetRight(), frame:GetBottom()
		local rootW, rootH	= GuiRoot:GetWidth(), GuiRoot:GetHeight()
		local point			= 0
		local x, y

		if (left < (rootW - right) and left < math.abs((left + right) / 2 - rootW / 2)) then
			x, point = left, 2 -- 'LEFT'
		elseif ((rootW - right) < math.abs((left + right) / 2 - rootW / 2)) then
			x, point = right - rootW, 8 -- 'RIGHT'
		else
			x, point = (left + right) / 2 - rootW / 2, 0
		end

		if (bottom < (rootH - top) and bottom < math.abs((bottom + top) / 2 - rootH / 2)) then
			y, point = top, point + 1 -- 'TOP|TOPLEFT|TOPRIGHT'
		elseif ((rootH - top) < math.abs((bottom + top) / 2 - rootH / 2)) then
			y, point = bottom - rootH, point + 4 -- 'BOTTOM|BOTTOMLEFT|BOTTOMRIGHT'
		else
			y = (bottom + top) / 2 - rootH / 2
		end

		point = (point == 0) and 128 or point -- 'CENTER'

		return point, x, y
	end
	local function OnMouseEnter(aura)
		InitializeTooltip(InformationTooltip, aura, TOPRIGHT, 0, - 2, BOTTOMLEFT)
		InformationTooltip:SetAbilityId(147414)
	end
	local function OnMouseExit()
		ClearTooltip(InformationTooltip)
	end
	local function OnMoveStop(frame)
		local point, x, y = GetAnchorRelativeToScreen(frame)
		RPOTracker.ASV.trackerPoint = point
		RPOTracker.ASV.trackerX = x
		RPOTracker.ASV.trackerY = y
	end
	local function GetLabelText()
		local ringStages = {
			[1] = {color = 'a5ff00', value = 16},
			[2] = {color = 'ffff00', value = 12},
			[3] = {color = 'ffba00', value = 8},
			[4] = {color = 'ff5d00', value = 4},
		}
		local groupSize = GetGroupSize() - 1
		if not IsUnitGrouped('player') or groupSize == 0 then
			return '|c00ff00'..tostring(20)..'%|r'
		elseif groupSize >= 5 then
			return '|cff0000'..tostring(0)..'%|r'
		else
			return '|c'..ringStages[groupSize].color..tostring(ringStages[groupSize].value)..'%|r'
		end
	end

	local tracker = GetControl('RPOTracker_Control')
	local label = GetControl('RPOTracker_Label')

	if option == 1 then -- initialize
		tracker:SetDimensions(64, 64)
		label:SetText(GetLabelText())
		tracker:ClearAnchors()
		tracker:SetAnchor(RPOTracker.ASV.trackerPoint, GuiRoot, RPOTracker.ASV.trackerPoint, RPOTracker.ASV.trackerX, RPOTracker.ASV.trackerY)
		label:ClearAnchors()
		label:SetAnchor(TOP, tracker, BOTTOM, 0 + RPOTracker.ASV.labelX, 0 + RPOTracker.ASV.labelY)
		tracker:SetHandler('OnMouseEnter', OnMouseEnter)
		tracker:SetHandler('OnMouseExit', OnMouseExit)
		tracker:SetHandler('OnMoveStop', OnMoveStop)
		tracker:SetMouseEnabled(true)
		RPOTracker:ConfigureTrackerIcon(3)
	elseif option == 2 then -- update label when group changes
		label:SetText(GetLabelText())
	elseif option == 3 then -- update general display settings
		tracker:SetMovable(not RPOTracker.ASV.trackerLock)
		tracker:SetTexture((RPOTracker.ASV.showBG) and '/RotPO_Tracker/bin/RotPO_BG.dds' or '/esoui/art/icons/antiquities_ornate_ring_4.dds')
		tracker:SetScale(RPOTracker.ASV.trackerScale)
		label:SetScale(RPOTracker.ASV.labelScale)

		if not RPOTracker_Check.hasRotPO then tracker:SetHidden(true) label:SetHidden(true) return end

		if RPOTracker.ASV.showTracker then
			if IsUnitGrouped('player') then
				if RPOTracker.ASV.showGrouped then
					tracker:SetHidden(false)
					if RPOTracker.ASV.showLabel then label:SetHidden(false) else label:SetHidden(true) end
				else
					tracker:SetHidden(true)
					label:SetHidden(true)
				end
			else
				tracker:SetHidden(false)
				if RPOTracker.ASV.showLabel then label:SetHidden(false) else label:SetHidden(true) end
			end
		else
			tracker:SetHidden(true)
			label:SetHidden(true)
		end
	elseif option == 4 then -- re-anchor the tracker label
		label:ClearAnchors()
		label:SetAnchor(TOP, tracker, BOTTOM, 0 + RPOTracker.ASV.labelX, 0 + RPOTracker.ASV.labelY)
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- global tracker library - register update if conditions are met
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function InitRotPOTracker() -- main function set up to be included in addons like a library and self-overwrite
	if (_G['RPOTracker_Check'] == nil) or (RPOTracker_Check.version < 1.0) then
		RPOTracker_Check = {}
		RPOTracker_Check.pingAdded = (SOUNDS.MAP_PING ~= "No_Sound") and SOUNDS.MAP_PING or "Map_Ping"
		RPOTracker_Check.pingRemoved = (SOUNDS.MAP_PING_REMOVE ~= "No_Sound") and SOUNDS.MAP_PING_REMOVE or "Map_Ping_Remove"
		RPOTracker_Check.version			= 1.0
		RPOTracker_Check.RotPOsId			= 575
		RPOTracker_Check.initialized		= false
		RPOTracker_Check.pingRegistered		= false
		RPOTracker_Check.gearSwapDelay		= false
		RPOTracker_Check.groupDelay			= false
		RPOTracker_Check.pingDelay			= false
		RPOTracker_Check.hasRotPO			= false

		function RPOTracker_Check:OnPingReceived(pingEventType, pingType, pingTag, offsetX, offsetY, isOwner)
			if (RPOTracker ~= nil) then
				local x = string.sub(tostring(offsetX), 3, 4)
				local y = string.sub(tostring(offsetY), 3, 4)
				local check = tonumber(x..y)
				if (check == 1979 or check == 7919) then
					if check == 1979 then
						RPOTracker.ASV.groupTable[pingTag] = true
					elseif check == 7919 then
						RPOTracker.ASV.groupTable[pingTag] = false
					end
					if (self.pingDelay == false) then
						self.pingDelay = true
						zo_callLater(function()
							self.pingDelay = false
							RPOTracker:OnGroupChanged() -- buffer rebuilding group only once after updates are received
						end, 1000)
					end
				end
			end
		end

		function RPOTracker_Check:PingHasRotPO(status)
			SOUNDS.MAP_PING = "No_Sound"
			SOUNDS.MAP_PING_REMOVE = "No_Sound"
			if (status) then
				PingMap(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, 0.1944, 0.7944)
			else
				PingMap(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, 0.7944, 0.1944)
			end
			self.groupDelay = false
			zo_callLater(function() 
				SOUNDS.MAP_PING = self.pingAdded -- maintain custom sounds if configured
				SOUNDS.MAP_PING_REMOVE = self.pingRemoved
			end, 6000)
		end

		function RPOTracker_Check:OnGroupChanged()
			if (IsUnitGrouped('player')) then
				if (self.hasRotPO) then
					if (self.groupDelay == false) then
						self.groupDelay = true
						zo_callLater(function() self:PingHasRotPO(true) end, 400)
					end
				end
			end
		end

		function RPOTracker_Check:CheckRPOTracker()
			if (RPOTracker ~= nil) then
				if RPOTracker.initialized then
					RPOTracker:ConfigureTrackerIcon(3)
				else
					zo_callLater(function() RPOTracker_Check:CheckRPOTracker() end, 1000)
				end
			end
		end

		function RPOTracker_Check:HasRotPOEquipped(delayed)
			if (delayed) or (self.gearSwapDelay == false) then
				self.gearSwapDelay = true
				self.hasRotPO = false
				for i = 0, 21 do -- iterate through available gear slots
					local itemLink = GetItemLink(BAG_WORN, i)
					if itemLink ~= "" then
						local hasSet, setName, _, _, maxEquipped, setId = GetItemLinkSetInfo(itemLink, true)
						if setId == self.RotPOsId then
							self.hasRotPO = true
							break
						end
					end
				end
				self.initialized = true

				if (RPOTracker ~= nil) then
					if not self.pingRegistered then
						EVENT_MANAGER:RegisterForEvent('RPOTracker_Check', EVENT_MAP_PING, function(_,...) RPOTracker_Check:OnPingReceived(...) end)
						self.pingRegistered = true
					end
					if RPOTracker.initialized then
						RPOTracker:ConfigureTrackerIcon(3)
					else
						zo_callLater(function() RPOTracker_Check:CheckRPOTracker() end, 1000)
					end
				else
					if self.pingRegistered then
						EVENT_MANAGER:UnregisterForEvent('RPOTracker_Check', EVENT_MAP_PING)
						self.pingRegistered = false
					end
				end

				if (delayed) then
					if (RPOTracker ~= nil) then
						if (IsUnitGrouped('player')) then self:PingHasRotPO(self.hasRotPO) end
					end
					self.gearSwapDelay = false -- reset spam control
					return
				else
					zo_callLater( function() self:HasRotPOEquipped(true) end, 2000 + GetLatency() )
				end
			end
		end

		EVENT_MANAGER:RegisterForEvent(		'RPOTracker_Check',		EVENT_ARMORY_BUILD_RESTORE_RESPONSE,	function() RPOTracker_Check:HasRotPOEquipped() end							)
		EVENT_MANAGER:RegisterForEvent(		'RPOTracker_Check',		EVENT_INVENTORY_SINGLE_SLOT_UPDATE,		function() RPOTracker_Check:HasRotPOEquipped() end							)
		EVENT_MANAGER:AddFilterForEvent(	'RPOTracker_Check',		EVENT_INVENTORY_SINGLE_SLOT_UPDATE,		REGISTER_FILTER_BAG_ID, BAG_WORN											)
		EVENT_MANAGER:AddFilterForEvent(	'RPOTracker_Check',		EVENT_INVENTORY_SINGLE_SLOT_UPDATE,		REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT	)
		EVENT_MANAGER:RegisterForEvent(		'RPOTracker_Check',		EVENT_GROUP_TYPE_CHANGED, 				function() RPOTracker_Check:OnGroupChanged() end							)
		EVENT_MANAGER:RegisterForEvent(		'RPOTracker_Check',		EVENT_GROUP_MEMBER_JOINED, 				function() RPOTracker_Check:OnGroupChanged() end							)
		EVENT_MANAGER:RegisterForEvent(		'RPOTracker_Check',		EVENT_GROUP_MEMBER_LEFT, 				function() RPOTracker_Check:OnGroupChanged() end							)
		EVENT_MANAGER:RegisterForEvent(		'RPOTracker_Check',		EVENT_GROUP_UPDATE, 					function() RPOTracker_Check:OnGroupChanged() end							)
		EVENT_MANAGER:RegisterForEvent(		'RPOTracker_Check',		EVENT_PLAYER_ALIVE, 					function() RPOTracker_Check:OnGroupChanged() end							)
		EVENT_MANAGER:RegisterForEvent(		'RPOTracker_Check',		EVENT_PLAYER_DEAD, 						function() RPOTracker_Check:OnGroupChanged() end							)
	end
	RPOTracker_Check:HasRotPOEquipped(true)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize the addon & settings panel and start the buff tracker.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow(addonName) -- setup the addon settings panel
	local panelData = {
		type					= "panel",
		name					= L.RPOTRACK_Title,
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize(L.RPOTRACK_Title),
		author					= "|c66ccffPhinix|r",
		version					= version,
		registerForRefresh		= true,
		registerForDefaults		= true,
	}
	local optionsData = {
		{
			type = 'submenu',
			name = L.RPOTRACK_SOpts,
			tooltip = '',
			controls = {
				[1] = {
					type			= 'checkbox',
					name			= L.RPOTRACK_Show,
					tooltip			= L.RPOTRACK_ShowD,
					getFunc			= function() return RPOTracker.ASV.showTracker end,
					setFunc			= function(value)
										RPOTracker.ASV.showTracker = value
										RPOTracker:ConfigureTrackerIcon(3)
									end,
					default			= RPOTracker.AccountDefaults.showTracker,
				},
				[2] = {
					type			= 'checkbox',
					name			= L.RPOTRACK_Lock,
					tooltip			= L.RPOTRACK_LockD,
					getFunc			= function() return RPOTracker.ASV.trackerLock end,
					setFunc			= function(value)
										RPOTracker.ASV.trackerLock = value
										RPOTracker:ConfigureTrackerIcon(3)
									end,
					default			= RPOTracker.AccountDefaults.trackerLock,
				},
				[3] = {
					type			= 'checkbox',
					name			= L.RPOTRACK_ShowG,
					tooltip			= L.RPOTRACK_ShowGD,
					getFunc			= function() return RPOTracker.ASV.showGrouped end,
					setFunc			= function(value)
										RPOTracker.ASV.showGrouped = value
										RPOTracker:ConfigureTrackerIcon(3)
									end,
					default			= RPOTracker.AccountDefaults.showGrouped,
				},
				[4] = {
					type			= 'checkbox',
					name			= L.RPOTRACK_ShowBG,
					tooltip			= L.RPOTRACK_ShowBGD,
					getFunc			= function() return RPOTracker.ASV.showBG end,
					setFunc			= function(value)
										RPOTracker.ASV.showBG = value
										RPOTracker:ConfigureTrackerIcon(3)
									end,
					default			= RPOTracker.AccountDefaults.showBG,
				},
				[5] = {
					type			= 'checkbox',
					name			= L.RPOTRACK_Label,
					tooltip			= L.RPOTRACK_LabelD,
					getFunc			= function() return RPOTracker.ASV.showLabel end,
					setFunc			= function(value)
										RPOTracker.ASV.showLabel = value
										RPOTracker:ConfigureTrackerIcon(3)
									end,
					default			= RPOTracker.AccountDefaults.showLabel,
				},
				[6] = {
					type			= 'slider',
					name			= L.RPOTRACK_TScale,
					tooltip			= L.RPOTRACK_TScaleD,
					min				= 0.25,
					max				= 1,
					step			= .25,
					getFunc			= function() return RPOTracker.ASV.trackerScale end,
					setFunc			= function(value)
										RPOTracker.ASV.trackerScale = value
										RPOTracker:ConfigureTrackerIcon(3)
									end,
					default			= RPOTracker.AccountDefaults.trackerScale,
				},
				[7] = {
					type			= 'slider',
					name			= L.RPOTRACK_LScale,
					tooltip			= L.RPOTRACK_LScaleD,
					min				= 0.25,
					max				= 1.5,
					step			= .25,
					getFunc			= function() return RPOTracker.ASV.labelScale end,
					setFunc			= function(value)
										RPOTracker.ASV.labelScale = value
										RPOTracker:ConfigureTrackerIcon(3)
									end,
					default			= RPOTracker.AccountDefaults.labelScale,
				},
				[8] = {
					type			= 'slider',
					name			= L.RPOTRACK_LabelX,
					tooltip			= L.RPOTRACK_LabelXD,
					min				= -64,
					max				= 64,
					step			= 1,
					getFunc			= function() return RPOTracker.ASV.labelX end,
					setFunc			= function(value)
										RPOTracker.ASV.labelX = value
										RPOTracker:ConfigureTrackerIcon(4)
									end,
					default			= RPOTracker.AccountDefaults.labelX,
				},
				[9] = {
					type			= 'slider',
					name			= L.RPOTRACK_LabelY,
					tooltip			= L.RPOTRACK_LabelYD,
					min				= -128,
					max				= 32,
					step			= 1,
					getFunc			= function() return RPOTracker.ASV.labelY end,
					setFunc			= function(value)
										RPOTracker.ASV.labelY = value
										RPOTracker:ConfigureTrackerIcon(4)
									end,
					default			= RPOTracker.AccountDefaults.labelY,
				},
			},
		},
		{
			type = 'submenu',
			name = L.RPOTRACK_GOpts,
			tooltip = '',
			controls = {
				[1] = {
					type			= 'checkbox',
					name			= L.RPOTRACK_SGF,
					tooltip			= L.RPOTRACK_SGFD,
					getFunc			= function() return RPOTracker.ASV.showGroup end,
					setFunc			= function(value)
										RPOTracker.ASV.showGroup = value
										RPOTracker:ResetGroup(true)
									end,
					default			= RPOTracker.AccountDefaults.showGroup,
				},
				[2] = {
					type			= 'checkbox',
					name			= L.RPOTRACK_SRF,
					tooltip			= L.RPOTRACK_SRFD,
					getFunc			= function() return RPOTracker.ASV.showRaid end,
					setFunc			= function(value)
										RPOTracker.ASV.showRaid = value
										RPOTracker:ResetGroup(true)
									end,
					default			= RPOTracker.AccountDefaults.showRaid,
				},
				[3] = {
					type			= 'dropdown',
					name			= L.RPOTRACK_GIS,
					tooltip			= L.RPOTRACK_GISD,
					choices			= { 8 , 16 , 24 , 32 },
					getFunc			= function() return RPOTracker.ASV.groupSize end,
					setFunc			= function(v)
										RPOTracker.ASV.groupSize = v
										RPOTracker:ResetGroup(true)
									end,
				--	scrollable		= 7,
					default			= RPOTracker.AccountDefaults.groupSize,
				},
				[4] = {
					type			= 'dropdown',
					name			= L.RPOTRACK_RIS,
					tooltip			= L.RPOTRACK_RISD,
					choices			= { 8 , 16 , 24 , 32 },
					getFunc			= function() return RPOTracker.ASV.raidSize end,
					setFunc			= function(v)
										RPOTracker.ASV.raidSize = v
										RPOTracker:ResetGroup(true)
									end,
				--	scrollable		= 7,
					default			= RPOTracker.AccountDefaults.raidSize,
				},
				[5] = {
					type			= 'slider',
					name			= L.RPOTRACK_GXIO,
					tooltip			= L.RPOTRACK_GXIOD,
					min				= -512,
					max				= 512,
					step			= 1,
					getFunc			= function() return RPOTracker.ASV.gXO end,
					setFunc			= function(value)
										RPOTracker.ASV.gXO = value
										RPOTracker:ResetGroup(true)
									end,
					default			= RPOTracker.AccountDefaults.gXO,
				},
				[6] = {
					type			= 'slider',
					name			= L.RPOTRACK_GYIO,
					tooltip			= L.RPOTRACK_GYIOD,
					min				= -64,
					max				= 64,
					step			= 1,
					getFunc			= function() return RPOTracker.ASV.gYO end,
					setFunc			= function(value)
										RPOTracker.ASV.gYO = value
										RPOTracker:ResetGroup(true)
									end,
					default			= RPOTracker.AccountDefaults.gYO,
				},
				[7] = {
					type			= 'slider',
					name			= L.RPOTRACK_RXIO,
					tooltip			= L.RPOTRACK_RXIOD,
					min				= -128,
					max				= 256,
					step			= 1,
					getFunc			= function() return RPOTracker.ASV.rXO end,
					setFunc			= function(value)
										RPOTracker.ASV.rXO = value
										RPOTracker:ResetGroup(true)
									end,
					default			= RPOTracker.AccountDefaults.rXO,
				},
				[8] = {
					type			= 'slider',
					name			= L.RPOTRACK_RYIO,
					tooltip			= L.RPOTRACK_RYIOD,
					min				= -32,
					max				= 64,
					step			= 1,
					getFunc			= function() return RPOTracker.ASV.rYO end,
					setFunc			= function(value)
										RPOTracker.ASV.rYO = value
										RPOTracker:ResetGroup(true)
									end,
					default			= RPOTracker.AccountDefaults.rYO,
				},
			},
		},
	}

	local LAM = LibAddonMenu2
	local CBM = CALLBACK_MANAGER
	RotPOPanel = LAM:RegisterAddonPanel("RPOTRACK_Panel", panelData)
	LAM:RegisterOptionControls("RPOTRACK_Panel", optionsData)

	CBM:RegisterCallback('LAM-PanelOpened', function(panel)
		if (panel ~= RotPOPanel) then return end
		settingsOpen = true
		RPOTracker:ConfigureTrackerIcon(3)
	end)

	CBM:RegisterCallback('LAM-PanelClosed', function(panel)
		if (panel ~= RotPOPanel) then return end
		settingsOpen = false
	end)
end

local function InitCallbacks() -- setup hiding icons with the hud and responding to various events

	-- Properly initialize the group and raid frame icons for the enabled type
	RPOTracker.ASV.groupMode = 1
	RPOTracker.ASV.raidMode = 1
	if BUI_VARS then
		local EnableFrames = BUI.Vars.RaidFrames
		if EnableFrames == true then
			RPOTracker.ASV.groupMode = 4
			RPOTracker.ASV.raidMode = 4
		end
	end
	if LUIESV then
		local EnableFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames_Enabled
		local GroupFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames.CustomFramesGroup
		local RaidFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames.CustomFramesRaid
		if (EnableFrames == true and GroupFrames == true) then
			RPOTracker.ASV.groupMode = 3
		end
		if (EnableFrames == true and RaidFrames == true) then
			RPOTracker.ASV.raidMode = 3
		end
	end
	if FTC_VARS then
		local EnableFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].EnableFrames
		local GroupFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].GroupFrames
		local RaidFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].RaidFrames
		if (EnableFrames == true and GroupFrames == true) then
			RPOTracker.ASV.groupMode = 2
		end
		if (EnableFrames == true and RaidFrames == true) then
			RPOTracker.ASV.raidMode = 2
		end
	end
	if AUI_Main then
		local EnableFrames = AUI_Main.Default[GetDisplayName()]["$AccountWide"].modul_unit_frames_enabled
		local GroupFrames = (AUI_Attributes) and AUI_Attributes.Default[GetDisplayName()]["$AccountWide"].group_unit_frames_enabled or false
		local RaidFrames = (AUI_Attributes) and AUI_Attributes.Default[GetDisplayName()]["$AccountWide"].raid_unit_frames_enabled or false
		if (EnableFrames) and (GroupFrames) then
			RPOTracker.ASV.groupMode = 5
		end
		if (EnableFrames) and (RaidFrames) then
			RPOTracker.ASV.raidMode = 5
		end
	end

	-- Setup callbacks and events
	local hudScene = SCENE_MANAGER:GetScene("hud")
	hudScene:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
			local tracker = GetControl('RPOTracker_Control')
			local label = GetControl('RPOTracker_Label')
			if not settingsOpen then
				tracker:SetHidden(true)
				label:SetHidden(true)
			end
			for i = 1, 24 do
				local control = GetControl('RPOTracker_GroupControl'..i)
				if control then
					control:SetHidden(true)
				end
			end
		end
		if newState == SCENE_SHOWN then
			RPOTracker:ConfigureTrackerIcon(3)
			RPOTracker:ResetGroup(true)
		end
	end)

	EVENT_MANAGER:RegisterForEvent('RotPO_Tracker', EVENT_GROUP_TYPE_CHANGED, function() RPOTracker:ResetGroup() end)
	EVENT_MANAGER:RegisterForEvent('RotPO_Tracker', EVENT_GROUP_MEMBER_JOINED, function() RPOTracker:ResetGroup() end)
	EVENT_MANAGER:RegisterForEvent('RotPO_Tracker', EVENT_GROUP_MEMBER_LEFT, function() RPOTracker:ResetGroup() end)
	EVENT_MANAGER:RegisterForEvent('RotPO_Tracker', EVENT_GROUP_UPDATE, function() RPOTracker:ResetGroup() end)
	EVENT_MANAGER:RegisterForEvent('RotPO_Tracker', EVENT_PLAYER_ALIVE, function() RPOTracker:ResetGroup() end)
	EVENT_MANAGER:RegisterForEvent('RotPO_Tracker', EVENT_PLAYER_DEAD, function() RPOTracker:ResetGroup() end)
end

local function Init3PFrames() -- initialize 3rd party group and raid frame auras as the enabled type
	RPOTracker.ASV.groupMode = 1
	RPOTracker.ASV.raidMode = 1
	if BUI_VARS then
		local EnableFrames = BUI.Vars.RaidFrames
		if EnableFrames == true then
			RPOTracker.ASV.groupMode = 4
			RPOTracker.ASV.raidMode = 4
		end
	end
	if LUIESV then
		local EnableFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames_Enabled
		local GroupFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames.CustomFramesGroup
		local RaidFrames = LUIESV.Default[GetDisplayName()]["$AccountWide"].UnitFrames.CustomFramesRaid
		if (EnableFrames == true and GroupFrames == true) then
			RPOTracker.ASV.groupMode = 3
		end
		if (EnableFrames == true and RaidFrames == true) then
			RPOTracker.ASV.raidMode = 3
		end
	end
	if FTC_VARS then
		local EnableFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].EnableFrames
		local GroupFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].GroupFrames
		local RaidFrames = FTC_VARS.Default[GetDisplayName()]["$AccountWide"].RaidFrames
		if (EnableFrames == true and GroupFrames == true) then
			RPOTracker.ASV.groupMode = 2
		end
		if (EnableFrames == true and RaidFrames == true) then
			RPOTracker.ASV.raidMode = 2
		end
	end
	if AUI_Main then
		local EnableFrames = AUI_Main.Default[GetDisplayName()]["$AccountWide"].modul_unit_frames_enabled
		local GroupFrames = (AUI_Attributes) and AUI_Attributes.Default[GetDisplayName()]["$AccountWide"].group_unit_frames_enabled or false
		local RaidFrames = (AUI_Attributes) and AUI_Attributes.Default[GetDisplayName()]["$AccountWide"].raid_unit_frames_enabled or false
		if (EnableFrames) and (GroupFrames) then
			RPOTracker.ASV.groupMode = 5
		end
		if (EnableFrames == true and RaidFrames == true) then
			RPOTracker.ASV.raidMode = 5
		end
	end
end

local function OnAddonLoaded(event, addonName) -- main addon initialization
	if addonName ~= 'RotPO_Tracker' then return end
	EVENT_MANAGER:UnregisterForEvent('RotPO_Tracker', EVENT_ADD_ON_LOADED)
	RPOTracker.ASV = ZO_SavedVars:NewAccountWide('RotPO_Tracker', 1.0, 'AccountSettings', RPOTracker.AccountDefaults)

	for g = 1, 24 do -- initialize group table preserving status through reloads
		local gtag = 'group'..tostring(g)
		if RPOTracker.ASV.groupTable[gtag] == nil then
			RPOTracker.ASV.groupTable[gtag] = false
		end
	end
	InitRotPOTracker()
	Init3PFrames()
	InitCallbacks()
	RPOTracker:ConfigureTrackerIcon(1)
	CreateSettingsWindow(addonName)
	RPOTracker.initialized = true
end

EVENT_MANAGER:RegisterForEvent('RotPO_Tracker', EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent('RotPO_Tracker',	EVENT_PLAYER_ACTIVATED, function() zo_callLater(function() RPOTracker:ResetGroup(true) end, 2000) end)
