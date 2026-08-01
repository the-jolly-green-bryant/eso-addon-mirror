local addon = {
	name = "VotansMapPinColorsSlim",
	accountDefaults =
	{
		showPlayerPin = true,
		vibratePlayerPin = false,
		questColor = "b76f6f",
		questAssistedColor = "6fb76f",
		playerColor = "6bf5f4",
		questRepeatableColor = "6fb0b8",
		questAssisted = "FFFFFF",
		preferAssisted = false,
	},
}

local am = GetAnimationManager()
local em = GetEventManager()

function addon:ApplySettings()
	local settings = self.account

	if not self.VotansGroupPins then
		ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_PLAYER].tint = self.playerColor
		local pin = ZO_WorldMap_GetPinManager():GetPlayerPin()
		pin:SetData(pin:GetPinTypeAndTag())
	else
		settings.playerColor = VOTANS_GROUPPINS.account.simplePlayerColor
	end
end

do
	local updateIdentifier = "VOTANS_MAP_PIN_UPDATE"
	local function DelayedUpdate()
		em:UnregisterForUpdate(updateIdentifier)
		addon:ApplySettings()
	end

	function addon:InitDelayedUpdate()
		em:UnregisterForUpdate(updateIdentifier)
		em:RegisterForUpdate(updateIdentifier, 100, DelayedUpdate)
	end
end
function addon:UpdatePlayerPinAlpha()
	self.playerColor:SetAlpha(self.account.showPlayerPin and 1 or 0)
end

function addon:InitializePlayerPin()
	local pin = ZO_WorldMap_GetPinManager():GetPlayerPin()

	local function createAnim()
		local control = pin:GetControl()
		local anim = am:CreateTimelineFromVirtual("ZO_RadialCountdownTimerPulse", control)
		pin.votanPulseTimeline = anim
		anim:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, 5)
		anim:GetAnimation(1):SetEndScale(1.8)
		anim:GetAnimation(2):SetStartScale(1.8)
		return anim
	end
	local function playPulse()
		if self.account.showPlayerPin and self.account.vibratePlayerPin then
			(pin.votanPulseTimeline or createAnim()):PlayFromStart()
		end
	end
	local function WorldMapStateChanged(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWN then
			playPulse()
		end
	end
	WORLD_MAP_SCENE:RegisterCallback("StateChange", WorldMapStateChanged)
	GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", WorldMapStateChanged)
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
		if ZO_WorldMap_IsWorldMapShowing() then
			playPulse()
		end
	end )
end

function addon:Initialize()
	local function GetColor(c)
		local r = ZO_ColorDef:New(c)
		r:SetAlpha(1)
		return r
	end
	self.account = ZO_SavedVars:NewAccountWide("VotansMapPinColors_Data", 1, nil, self.accountDefaults)

	self.questColor = GetColor(self.account.questColor)
	self.questRepeatableColor = GetColor(self.account.questRepeatableColor)
	self.questAssistedColor = GetColor(self.account.questAssistedColor)

	-- HookGroupManager()

	if not addon.VotansGroupPins then
		self.playerColor = GetColor(self.account.playerColor)
		ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_PLAYER].texture = "VotansMapPinColorsSlim/art/Pointer1.dds"
	else
		self.account.playerColor = VOTANS_GROUPPINS.account.simplePlayerColor
		self.playerColor = GetColor(self.account.playerColor)
		VOTANS_GROUPPINS.simplePlayerColor = self.playerColor
		local orgInitDelayedUpdate = VOTANS_GROUPPINS.InitDelayedUpdate
		function VOTANS_GROUPPINS.InitDelayedUpdate(...)
			self.playerColor = VOTANS_GROUPPINS.simplePlayerColor
			self:UpdatePlayerPinAlpha()
			return orgInitDelayedUpdate(...)
		end
	end
	self:UpdatePlayerPinAlpha()

	self:SetQuestColor()
	self:SetQuestRepeatableColor()
	self:SetQuestAssistedRepeatableColor()
	self:SetAssistedQuestColor()
	self:InitializePlayerPin()
	self:ApplySettings()

end


local function SetQuestPinTint(pin, color)
	-- local pinType = pin:GetPinTypeAndTag()
	-- local r, g, b = color:UnpackRGB()
	-- local questIndex, stepIndex, conditionIndex = pin:GetQuestData()
	-- SetPinTint(pinType, r, g, b, questIndex, stepIndex, conditionIndex)
	-- SetPinTint(MAP_PIN_TYPE_QUEST_INTERACT, r, g, b, questIndex, stepIndex, conditionIndex)
	-- local container = COMPASS.container
	-- local value = container:GetMinVisibleAlpha(pinType)
	-- container:SetMinVisibleAlpha(pinType, value - 0.01)
	-- container:SetMinVisibleAlpha(pinType, value)
end

function addon:SetQuestColor()
	local function GetQuestPinTint(pin)
		SetQuestPinTint(pin, self.questColor)
		return self.questColor
	end

	if MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_CONDITION then
		ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_CONDITION].tint = GetQuestPinTint
		ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_OPTIONAL_CONDITION].tint = GetQuestPinTint
		ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_ENDING].tint = GetQuestPinTint
	end

	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_TRACKED_QUEST_ENDING].tint = GetQuestPinTint

	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_QUEST_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_QUEST_ENDING].tint = GetQuestPinTint
end

function addon:SetQuestRepeatableColor()
	local function GetQuestPinTint(pin)
		SetQuestPinTint(pin, self.questRepeatableColor)
		return self.questRepeatableColor
	end

	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING].tint = GetQuestPinTint

	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING].tint = GetQuestPinTint
end

function addon:SetQuestAssistedRepeatableColor()
	local function GetQuestPinTint(pin)
		if self.account.preferAssisted then
			SetQuestPinTint(pin, self.questAssistedColor)
			return self.questAssistedColor
		else
			SetQuestPinTint(pin, self.questRepeatableColor)
			return self.questRepeatableColor
		end
	end

	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING].tint = GetQuestPinTint

end

function addon:SetAssistedQuestColor()
	local function GetQuestPinTint(pin)
		SetQuestPinTint(pin, self.questAssistedColor)
		return self.questAssistedColor
	end

	if MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION then
		ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION].tint = GetQuestPinTint
		ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION].tint = GetQuestPinTint
		ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING].tint = GetQuestPinTint
	end

	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION].tint = GetQuestPinTint
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING].tint = GetQuestPinTint
end

function addon:InitSettings()
	local LibHarvensAddonSettings = LibHarvensAddonSettings or LibStub("LibHarvensAddonSettings-1.0")

	local settings = LibHarvensAddonSettings:AddAddon("Votan's Map Pin Colors Slim")
	if not settings then return end
	addon.settingsControls = settings
	settings.version = "1.1.1"
	settings.allowDefaults = true
	settings.website = "http://www.esoui.com/downloads/info1843-VotansMapPinColors.html"

	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = GetString(SI_VOTANS_MAPPIN_COLORS_SHOW_PLAYER_PIN),
		tooltip = GetString(SI_VOTANS_MAPPIN_COLORS_SHOW_PLAYER_PIN_TOOLTIP),
		default = true,
		getFunction = function() return self.account.showPlayerPin end,
		setFunction = function(value)
			self.account.showPlayerPin = value
			self:UpdatePlayerPinAlpha()
			self:InitDelayedUpdate()
		end,
	}
	if not self.VotansGroupPins then
		settings:AddSetting {
			type = LibHarvensAddonSettings.ST_COLOR,
			label = " |u12:0::|u" .. GetString(SI_PLAYER_MENU_PLAYER),
			getFunction = function()
				return self.playerColor:UnpackRGB()
			end,
			setFunction = function(newR, newG, newB, newA)
				self.playerColor = ZO_ColorDef:New(newR, newG, newB, 1)
				self:UpdatePlayerPinAlpha()
				self.account.playerColor = self.playerColor:ToHex()
				self:InitDelayedUpdate()
			end,
			default = { ZO_ColorDef:New(self.accountDefaults.playerColor):UnpackRGB() },
		}
	else
		settings:AddSetting {
			type = LibHarvensAddonSettings.ST_COLOR,
			label = " |u12:0::|u" .. GetString(SI_PLAYER_MENU_PLAYER),
			getFunction = function()
				self.account.playerColor = VOTANS_GROUPPINS.account.simplePlayerColor
				return VOTANS_GROUPPINS.simplePlayerColor:UnpackRGB()
			end,
			setFunction = function(newR, newG, newB, newA)
				self.playerColor = ZO_ColorDef:New(newR, newG, newB, 1)
				self.account.playerColor = self.playerColor:ToHex()
				self:UpdatePlayerPinAlpha()
				VOTANS_GROUPPINS.account.simplePlayerColor = self.account.playerColor
				VOTANS_GROUPPINS.simplePlayerColor = self.playerColor
				VOTANS_GROUPPINS:InitDelayedUpdate()
			end,
			default = { ZO_ColorDef:New(VOTANS_GROUPPINS.account.simplePlayerColor):UnpackRGB() },
		}
	end
	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = " |u12:0::|u" .. GetString(SI_VOTANS_MAPPIN_COLORS_PLAYER_PIN_VIBRATION),
		tooltip = GetString(SI_VOTANS_MAPPIN_COLORS_PLAYER_PIN_VIBRATION_TOOLTIP),
		default = false,
		getFunction = function() return self.account.vibratePlayerPin end,
		setFunction = function(value)
			self.account.vibratePlayerPin = value
		end,
	}



	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_SECTION,
		label = GetString(SI_MAP_INFO_MODE_QUESTS),
	}
	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_COLOR,
		label = GetString(SI_COMPASSACTIVEQUESTSCHOICE2),
		getFunction = function()
			return addon.questAssistedColor:UnpackRGB()
		end,
		setFunction = function(newR, newG, newB, newA)
			addon.questAssistedColor = ZO_ColorDef:New(newR, newG, newB, 1)
			addon.account.questAssistedColor = addon.questAssistedColor:ToHex()
			self:InitDelayedUpdate()
		end,
		default = { ZO_ColorDef:New(self.accountDefaults.questAssistedColor):UnpackRGB() },
	}

	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_COLOR,
		label = GetString(SI_FURNITURETHEMETYPE1),
		getFunction = function()
			return addon.questColor:UnpackRGB()
		end,
		setFunction = function(newR, newG, newB, newA)
			addon.questColor = ZO_ColorDef:New(newR, newG, newB, 1)
			addon.account.questColor = addon.questColor:ToHex()
			self:InitDelayedUpdate()
		end,
		default = { ZO_ColorDef:New(self.accountDefaults.questColor):UnpackRGB() },
	}

	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_COLOR,
		label = GetString(SI_QUEST_JOURNAL_REPEATABLE_TEXT),
		getFunction = function()
			return addon.questRepeatableColor:UnpackRGB()
		end,
		setFunction = function(newR, newG, newB, newA)
			addon.questRepeatableColor = ZO_ColorDef:New(newR, newG, newB, 1)
			addon.account.questRepeatableColor = addon.questRepeatableColor:ToHex()
			self:InitDelayedUpdate()
		end,
		default = { ZO_ColorDef:New(self.accountDefaults.questRepeatableColor):UnpackRGB() },
	}
	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = GetString(SI_VOTANS_MAPPIN_COLORS_PREFER_ASSISTED),
		tooltip = GetString(SI_VOTANS_MAPPIN_COLORS_PREFER_ASSISTED_TOOLTIP),
		default = false,
		getFunction = function() return self.account.preferAssisted end,
		setFunction = function(value)
			self.account.preferAssisted = value
		end,
	}
end


-- do
-- local function UpdateControls()
-- 	if addon.settingsControls.selected then
-- 		addon.settingsControls:UpdateControls()
-- 	end
-- end
-- function addon.ToggleShowHUD()
-- 	local self = addon
-- 	self.account.showHUD = not self.account.showHUD
-- 	self:UpdateVisibility()
-- 	UpdateControls()
-- end
-- function addon.ToggleShowCombat()
-- 	local self = addon
-- 	self.account.showCombat = not self.account.showCombat
-- 	self:UpdateVisibility()
-- 	UpdateControls()
-- end
-- end

local function OnAddonLoaded(event, name)
	if name == "VotansGroupPinsSlim" then addon.VotansGroupPins = true end
	if name ~= addon.name then return end
	em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
	addon:Initialize()
	addon:InitSettings()
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

VOTANS_MAP_PIN_COLORS = addon
