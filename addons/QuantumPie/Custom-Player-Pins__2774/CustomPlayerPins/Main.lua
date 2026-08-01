local addon = {
	name = "CustomPlayerPins",
	settingsName = "CustomPlayerPinsSettings",
	accountDefaults =
	{
		name = {},
		pinnedPlayers = {}
	},
	icons = 
	{
		mundus = "/esoui/art/zonestories/completiontypeicon_mundusstone.dds",
		skyshard = "/esoui/art/zonestories/completiontypeicon_skyshard.dds",
		dolmen = "/esoui/art/zonestories/completiontypeicon_worldevents.dds",
		boss = "/esoui/art/zonestories/completiontypeicon_groupboss.dds",
		delve = "/esoui/art/zonestories/completiontypeicon_delve.dds",
		quest = "/esoui/art/zonestories/completiontypeicon_priorityquest.dds",
		champion = "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_champion.dds"
	},
	colors = 
	{
		red = ZO_ColorDef:New(1, 0, 0, 1),
		green = ZO_ColorDef:New(0, 1, 0, 1),
		blue = ZO_ColorDef:New(0, 0, 1, 1),
		white = ZO_ColorDef:New(1, 1, 1, 1)
	},
	group = {},
	groupMembers = {},
	settingsSelection = {},
	controls = {
		playerDropdown = nil
	}
}

local LAM = LibAddonMenu2
local LMP = LibMapPins
local em = GetEventManager()

local g_activeGroupPins = { }
do
	local orgZO_WorldMap_RefreshGroupPins = ZO_WorldMap_RefreshGroupPins
	function ZO_WorldMap_RefreshGroupPins(...)
		ZO_ClearTable(g_activeGroupPins)
		-- COMPASS_PINS.pinManager:RemovePins(addon.compassPinType)
		return orgZO_WorldMap_RefreshGroupPins(...)
	end
end

local function GetUnitTag(pin)
	local unitTag = pin:GetUnitTag()
	if unitTag then g_activeGroupPins[unitTag] = pin end
	return unitTag
end

local function GetColor(c)
	local r = ZO_ColorDef:New(c)
	r:SetAlpha(1)
	return r
end

local iconLeader = "EsoUI/Art/Compass/groupLeader.dds"
local iconMember = "EsoUI/Art/MapPins/UI-WorldMapGroupPip.dds"
local iconFriend = "EsoUI/Art/MapPins/UI-WorldMapGroupPip.dds"
addon.IconLeaderSimple = function(pin) GetUnitTag(pin) return iconLeader end
addon.IconMemberSimple = function(pin) GetUnitTag(pin) return iconMember end

local function AddOverlayIcon(pin, unitTag)
	local labelControl = pin.m_Control:GetNamedChild("Label")
	local isLeader = IsUnitGroupLeader(unitTag)
	-- local isFriend = addon.account.showFriendMarker and IsUnitFriend(unitTag)

	if isLeader then
		if labelControl:IsHidden() then
			labelControl:ClearAnchors()
			labelControl:SetAnchor(TOP, nil, TOP, 0, -3)
			labelControl:SetPixelRoundingEnabled(true)
			labelControl:SetHidden(false)
		end
		if isLeader then
			labelControl:SetText(addon:GetColoredLeaderIcon(pin))
		else
			labelControl:SetText(addon:GetColoredFriendIcon(pin))
		end
	else
		labelControl:SetPixelRoundingEnabled(false)
		labelControl:SetHidden(true)
	end
end

function addon.IconFromName(pin)
	addon.pinData = pin
	if not pin then return "" end
	local unitTag = GetUnitTag(pin)
	if not unitTag then return "" end

	AddOverlayIcon(pin, unitTag)
	local name = GetUnitDisplayName(unitTag)
	local info = addon.account.name[name]
	if info ~= nil then
		return info.icon
	end
    return "/esoui/art/mappins/ui-worldmapgrouppip.dds"
end

function addon.TintFromName(pin)
	
	local unitTag = GetUnitTag(pin)
	local name = GetUnitDisplayName(unitTag)

	AddOverlayIcon(pin, unitTag)
	local info = addon.account.name[name]
	if info ~= nil then
		return GetColor(info.color)
	end
	return GetColor(addon.colors.white)
end

function addon.LevelFromName(pin)
	addon.levelData = pin
	local unitTag = GetUnitTag(pin)
	local name = GetUnitDisplayName(unitTag)

	AddOverlayIcon(pin, unitTag)
	local info = addon.account.name[name]
	if info ~= nil then
		return 152
	end
	return 150
end

local function IsPlayerInGroup()
	return IsUnitGrouped("player")
end

local function OnPowerUpdate(event, unitTag)
	local pin = g_activeGroupPins[unitTag]
	if pin and pin.normalizedX and pin.normalizedY then
		pin:SetData(pin:GetPinTypeAndTag())
	end
end

function addon:ColorUpdate(enabled)
	if not enabled or not IsPlayerInGroup() then
		em:UnregisterForEvent(addon.name, EVENT_POWER_UPDATE)
		return
	end
	em:UnregisterForEvent(addon.name, EVENT_POWER_UPDATE)
	em:RegisterForEvent(addon.name, EVENT_POWER_UPDATE, OnPowerUpdate)
	em:AddFilterForEvent(addon.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
end

do
	local sizeCacheLeader = { }
	local zo_iconFormatInheritColor = zo_iconFormatInheritColor
	local function GetNewIconLeader(size)
		local icon = GetColor(addon.colors.white):Colorize(zo_iconFormatInheritColor(iconLeader, size, size))
		sizeCacheLeader[size] = icon
		return icon
	end
	function addon:GetColoredLeaderIcon(pin)
		local size = math.floor(pin.m_Control:GetWidth())
		return sizeCacheLeader[size] or GetNewIconLeader(size)
	end
	local sizeCacheFriend = { }
	local function GetNewIconFriend(size)
		local size2 = math.max(16, size * 0.75)
		local icon = GetColor(addon.colors.white):Colorize(zo_iconFormatInheritColor(iconFriend, size2, size2))
		sizeCacheFriend[size] = icon
		return icon
	end
	function addon:GetColoredFriendIcon(pin)
		local size = math.floor(pin.m_Control:GetWidth())
		return sizeCacheFriend[size] or GetNewIconFriend(size)
	end
	function addon:ClearSizeCache()
		ZO_ClearTable(sizeCacheLeader)
		ZO_ClearTable(sizeCacheFriend)
	end
end

function addon:ApplySettings()
	local leader = ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_GROUP_LEADER]
	local group = ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_GROUP]

	leader.texture = addon.IconFromName
	group.texture = addon.IconFromName
	leader.tint = addon.TintFromName
	group.tint = addon.TintFromName
	group.level = addon.LevelFromName
	-- leader.size = addon.SizeFromName


	-- ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_PLAYER].tint = addon.simplePlayerColor
	-- local pin = ZO_WorldMap_GetPinManager():GetPlayerPin()
	-- pin:SetData(pin:GetPinTypeAndTag())
	-- g_activeGroupPins["player"] = pin

	self:ColorUpdate(true)
end

function addon.PlayerDeactivated()
	addon:ColorUpdate(false)
end


do
	local updateIdentifier = "CUSTOM_PLAYER_PINS_UPDATE"
	local function DelayedUpdate()
		em:UnregisterForUpdate(updateIdentifier)
		addon:ApplySettings()
		ZO_WorldMap_RefreshGroupPins()
	end

	function addon:InitDelayedUpdate()
		em:UnregisterForUpdate(updateIdentifier)
		em:RegisterForUpdate(updateIdentifier, 100, DelayedUpdate)
	end
end

local function GroupUpdate()
	addon:InitDelayedUpdate()
end


function addon.UpdateGroupMembers()
	local names = {} 
	for k, v in pairs(addon.group) do
		names[#names + 1] = v.name
	end
	addon.groupMembers = names

	if addon.controls.playerDropdown ~= nil then
		addon.controls.playerDropdown:UpdateChoices(addon.groupMembers)
	end
end

function addon.OnMemberJoined(_, _, displayName, _)
	addon.group[displayName] = {name = displayName}
	addon.UpdateGroupMembers()
end

function addon.OnMemberLeft(_, _, _, _, _, displayName, _)
	addon.group[displayName] = nil
	addon.UpdateGroupMembers()
end

function addon.OnPlayerActivated(_, _)
	if IsUnitGrouped('player') then
		for i=1, GetGroupSize() do
			local displayName = GetUnitDisplayName(GetGroupUnitTagByIndex(i))
			if addon.group[displayName] == nil then addon.group[displayName] = {name = displayName} end
		end
		addon.UpdateGroupMembers()
	end
	addon:ApplySettings()
end

function addon.OnPanelCreation(panel)
	if panel:GetName() ~= addon.settingsName then return end
	-- addon.controls.panel = panel
	addon.controls.playerDropdown = WINDOW_MANAGER:GetControlByName("CustomPlayerPinsMenu_PlayerDropdown")
	addon.controls.playerDropdown:UpdateChoices(addon.groupMembers)
	
	addon.controls.removeDropdown = WINDOW_MANAGER:GetControlByName("CustomPlayerPinsMenu_RemoveDropdown")
	addon.controls.removeDropdown:UpdateChoices(addon.account.pinnedPlayers)

	addon.controls.pinList = WINDOW_MANAGER:GetControlByName("CustomPlayerPinsMenu_PinList")
	local updatedText = ""
	for k, v in pairs(addon.account.name) do
		updatedText = updatedText .. v.name .. " - " .. v.iconName .. " - " .. v.colorName .. "\n"
	end
	addon.controls.pinList.data.text = updatedText
	addon.controls.pinList:UpdateValue()
end

function addon:HookPOIPins()
	local function HookPinSize(data)
		addon.hookData = data
		local orgMetaTable = getmetatable(data)
		local orgSize = data.size or 32
		local orgLevel = data.level or 150
		data.size = nil -- Force to ask the metatable
		-- data.level = nil

		local newMetaTable = {}
		setmetatable(newMetaTable, orgMetaTable)
		local alter = {}

		alter.size = function(pin)
			-- d(pin)
			-- local unitTag = GetUnitTag(pin)
			-- d(unitTag)
			-- if not unitTag then return "" end

			-- AddOverlayIcon(pin, unitTag)
			-- local name = GetUnitDisplayName(unitTag)
			-- local info = addon.account.name[name]
			-- if info ~= nil then
			if nil then
				return 60
			end
			-- return "/esoui/art/mappins/ui-worldmapgrouppip.dds"
			return orgSize
		end

		-- alter.level = function()
		-- end
				-- more alternates here
 
		newMetaTable.__index = function(data, key)
			return alter[key] and alter[key](data) or newMetaTable[key] -- if alternate exists, call it
		end
		
		-- newMetaTable.__newindex = function(data, key, value)
		-- 	if key == "size" then
		-- 		orgSize = value
		-- 		return -- Do not set value within table to keep using metatable
		-- 	end
		-- 	return rawset(data, key, value)
		-- end


		setmetatable(data, newMetaTable)
	end

	-- HookPinSize(ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_GROUP_LEADER])
	HookPinSize(ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_GROUP])
	addon.groupPin = ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_GROUP]
	addon.leaderPin = ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_GROUP_LEADER]
	-- HookPinSize(ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_PLAYER])
end

function addon:Initialize()
	self.account = ZO_SavedVars:NewAccountWide("CustomPlayerPins_Data", 3, nil, self.accountDefaults)

	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function(navigateIn) self:ApplySettings() end)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GROUP_UPDATE, GroupUpdate)
	-- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.PlayerActivated)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_DEACTIVATED, self.PlayerDeactivated)
	

	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_JOINED, self.OnMemberJoined)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_LEFT, self.OnMemberLeft)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.OnPlayerActivated)

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", self.OnPanelCreation)

	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_PLAYER].texture = "/esoui/art/mappins/ui-worldmapplayerpip.dds"
	self:HookPOIPins()
end

function addon:InitializeSettings()
	local panelData = {
		type = "panel",
		name = "Custom Player Pins",
		author = "@QuantumPie"
	}
	local panel = LAM:RegisterAddonPanel(self.settingsName, panelData)

	local optionsAddSubmenu = {
		{
			type = "dropdown",
			name = "Player",
			choices = self.groupMembers,
			getFunc = function() return self.settingsSelection.displayName end,
			setFunc = function(value) self.settingsSelection.displayName = value end,
			reference = "CustomPlayerPinsMenu_PlayerDropdown"
		},
		{
			type = "dropdown",
			name = "Icon",
			choices = (function() 
				local icons = {}
				for k, v in pairs(self.icons) do icons[#icons + 1] = k end
				return icons
			end)(),
			getFunc = function() return self.settingsSelection.icon end,
			setFunc = function(value) self.settingsSelection.icon = value end,
			reference = "CustomPlayerPinsMenu_IconDropdown"
		},
		{
			type = "dropdown",
			name = "Color",
			choices = (function() 
				local icons = {}
				for k, v in pairs(self.colors) do icons[#icons + 1] = k end
				return icons
			end)(),
			getFunc = function() return self.settingsSelection.color end,
			setFunc = function(value) self.settingsSelection.color = value end,
			reference = "CustomPlayerPinsMenu_ColorDropdown"
		},
		{
			type = "button",
			name = "Add",
			func = function()
				self.account.name[self.settingsSelection.displayName] = {
					name = self.settingsSelection.displayName, 
					icon = self.icons[self.settingsSelection.icon], 
					iconName = self.settingsSelection.icon,
					color = self.colors[self.settingsSelection.color],
					colorName = self.settingsSelection.color
				}
				self.account.pinnedPlayers = {}
				for k, v in pairs(self.account.name) do
					self.account.pinnedPlayers[#self.account.pinnedPlayers + 1] = v.name
				end
				local updatedText = ""
				for k, v in pairs(self.account.name) do
					updatedText = updatedText .. v.name .. " - " .. v.iconName .. " - " .. v.colorName .. "\n"
				end

				self.controls.removeDropdown:UpdateChoices(self.account.pinnedPlayers)
				self.controls.pinList.data.text = updatedText
				self.controls.pinList:UpdateValue()
			end
		},
	}

	local optionsRemoveSubmenu = {
		{
			type = "dropdown",
			name = "Player",
			choices = self.groupMembers,
			getFunc = function() return self.settingsSelection.removeName end,
			setFunc = function(value) self.settingsSelection.removeName = value end,
			reference = "CustomPlayerPinsMenu_RemoveDropdown"
		},
		{
			type = "button",
			name = "Remove",
			func = function()
				self.account.name[self.settingsSelection.removeName] = nil
				self.account.pinnedPlayers = {}
				for k, v in pairs(self.account.name) do
					self.account.pinnedPlayers[#self.account.pinnedPlayers + 1] = v.name
				end

				local updatedText = ""
				for k, v in pairs(self.account.name) do
					updatedText = updatedText .. v.name .. " - " .. v.iconName .. " - " .. v.colorName .. "\n"
				end

				self.controls.removeDropdown:UpdateChoices(self.account.pinnedPlayers)
				self.controls.pinList.data.text = updatedText
				self.controls.pinList:UpdateValue()
			end
		}
	}

	local optionsData = {
		{
			type = "submenu",
			name = "Add",
			controls = optionsAddSubmenu
		},
		{
			type = "submenu",
			name = "Remove",
			controls = optionsRemoveSubmenu
		},
		{
			type = "description",
			text = "",
			reference = "CustomPlayerPinsMenu_PinList"
	   }
	}
	LAM:RegisterOptionControls(addon.settingsName, optionsData)
end

local function OnAddonLoaded(event, name)
	if name ~= addon.name then return end
	em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
	addon:Initialize()
	addon:InitializeSettings()
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

CUSTOM_PLAYER_PINS = addon
