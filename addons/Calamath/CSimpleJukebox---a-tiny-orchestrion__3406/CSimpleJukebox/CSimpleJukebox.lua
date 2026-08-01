--
-- Calamath's Simple Jukebox [CSJ]
--
-- Copyright (c) 2022 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--
-- Note :
-- This addon works that uses the library LibAddonMenu-2.0 by sirinsidiator, Seerah, released under the Artistic License 2.0
-- This addon works that uses the library LibCPieMenu by Calamath, released under the Artistic License 2.0
-- You will need to obtain the above add-on separately.
--

-- ---------------------------------------------------------------------------------------
-- CT_MinimalAddonFramework: Minimal Add-on Framework Template Class            rel.1.1.12
-- ---------------------------------------------------------------------------------------
local CT_MinimalAddonFramework = ZO_Object:Subclass()
function CT_MinimalAddonFramework:New(...)
	local newObject = setmetatable({}, self)
	newObject:Initialize(...)
	newObject:ConfigDebug()
	newObject:OnInitialized(...)
	return newObject
end
function CT_MinimalAddonFramework:Initialize(name, attributes)
	if type(name) ~= "string" or name == "" then return end
	self._name = name
	self._isInitialized = false
	if type(attributes) == "table" then
		for k, v in pairs(attributes) do
			if self[k] == nil then
				self[k] = v
			end
		end
	end
	self._external = {
		name = self.name or self._name, 
		version = self.version, 
		author = self.author, 
	}
	assert(not _G[name], name .. " is already loaded.")
	_G[name] = self._external
	EVENT_MANAGER:RegisterForEvent(self._name, EVENT_ADD_ON_LOADED, function(event, addonName)
		if addonName ~= self._name then return end
		EVENT_MANAGER:UnregisterForEvent(self._name, EVENT_ADD_ON_LOADED)
		self:OnAddOnLoaded(event, addonName)
		self._isInitialized = true
	end)
end
function CT_MinimalAddonFramework:ConfigDebug()
	local Dummy = function() end
	self.LDL = { Verbose = Dummy, Debug = Dummy, Info = Dummy, Warn = Dummy, Error = Dummy, }
	self._isDebugMode = false
end
function CT_MinimalAddonFramework:OnInitialized(name, attributes)
--  Available when overridden in an inherited class
end
function CT_MinimalAddonFramework:OnAddOnLoaded(event, addonName)
--  Should be Overridden
end


-- ---------------------------------------------------------------------------------------
-- CSimpleJukebox
-- ---------------------------------------------------------------------------------------
local CSJ = CT_MinimalAddonFramework:New("CSimpleJukebox", {
	name = "CSimpleJukebox", 
	version = "1.5.4", 
	author = "Calamath", 
	savedVars = "CSimpleJukeboxSV", 
	savedVarsVersion = 1, 
	authority = {2973583419,210970542}, 
})
-- ---------------------------------------------------------------------------------------
local LAM = LibAddonMenu2
local LCPM = LibCPieMenu
local L = GetString
-- In the seasonal model, new chapters don't seem to have their own intro music.
local EXEMPT_CHAPTERS = {
	[9]		= true, -- 2025 content pass
}
local ChapterId_To_CollectibleId = {
	[0]		= 0, 
	[1]		= 593, 
	[2]		= 5107, 
	[3]		= 5843, 
	[4]		= 7466, 
	[5]		= 8659, 
	[6]		= 10053, 
	[7]		= 10475, 
	[8]		= 11871, 
	[9]		= 13439, 
}
local ParentZoneId_To_ChapterId = {	-- this is subset list.
	[3]		= 0, 
	[19]	= 0, 
	[20]	= 0, 
	[41]	= 0, 
	[57]	= 0, 
	[58]	= 0, 
	[92]	= 0, 
	[101]	= 0, 
	[103]	= 0, 
	[104]	= 0, 
	[108]	= 0, 
	[117]	= 0, 
	[181]	= 0, 
	[267]	= 0, 
	[280]	= 0, 
	[281]	= 0, 
	[347]	= 0, 
	[381]	= 0, 
	[382]	= 0, 
	[383]	= 0, 
	[534]	= 0, 
	[535]	= 0, 
	[537]	= 0, 
	[572]	= 0, 
	[584]	= 0, 
	[586]	= 0, 
	[642]	= 0, 
	[684]	= 0, 
	[726]	= 0, 
	[816]	= 0, 
	[823]	= 0, 
	[849]	= 1, 
	[888]	= 0, 
	[980]	= 0, 
	[1011]	= 2, 
	[1086]	= 3, 
	[1133]	= 3, 
	[1142]	= 3, 
	[1144]	= 3, 
	[1160]	= 4, 
	[1161]	= 4, 
	[1207]	= 4, 
	[1208]	= 4, 
	[1261]	= 5, 
	[1282]	= 5, 
	[1286]	= 5, 
	[1318]	= 6, 
	[1383]	= 6, 
	[1414]	= 7, 
	[1429]	= 0, 
	[1443]	= 8, 
	[1460]	= 8, 
	[1463]	= 8, 
	[1502]	= 9, 
}
local CSJ_SV_DEFAULT = {
	accountWide = true, 
	chapterMusic = {
		[0] = { "0", 0 }, 
		[1] = { "1", 0 }, 
		[2] = { "2", 0 }, 
		[3] = { "3", 0 }, 
		[4] = { "4", 0 }, 
		[5] = { "5", 0 }, 
		[6] = { "6", 0 }, 
		[7] = { "7", 0 }, 
		[8] = { "8", 0 }, 
		[9] = { "0", 0 }, 
	}, 
	overrideCombatMusic = false, 
}

function CSJ:OnAddOnLoaded()
	self.isFirstTimePlayerActivated = true

	self.lut = {}
	self.lut.ChapterId_To_CollectibleId = ChapterId_To_CollectibleId
	self.lut.ParentZoneId_To_ChapterId = ParentZoneId_To_ChapterId

	-- CSimpleJukebox Config
	self.svCurrent = {}
	self.svAccount = ZO_SavedVars:NewAccountWide(self.savedVars, 1, nil, CSJ_SV_DEFAULT, GetWorldName())
	self:ValidateConfigDataSV(self.svAccount)
	if self.svAccount.accountWide then
		self.svCurrent = self.svAccount
	else
		self.svCharacter = ZO_SavedVars:NewCharacterIdSettings(self.savedVars, 1, nil, CSJ_SV_DEFAULT, GetWorldName())
		self:ValidateConfigDataSV(self.svCharacter)
		self.svCurrent = self.svCharacter
	end

	self.isInternalSetting = false
	self.savedIntroMusicSetting = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_INTRO_MUSIC)
	self.previousOverrideMusicMode = OVERRIDE_MUSIC_MODE_NONE

	self:RegisterEvents()
	self:PieMenuIntegration()
end

function CSJ:ValidateConfigDataSV(sv)
	for chapterId = CHAPTER_ITERATION_BEGIN, CHAPTER_ITERATION_END do
		if sv.chapterMusic[chapterId] == nil then
			if CSJ_SV_DEFAULT.chapterMusic[chapterId] then
				sv.chapterMusic[chapterId] = ZO_ShallowTableCopy(CSJ_SV_DEFAULT.chapterMusic[chapterId])
			else
				sv.chapterMusic[chapterId] = ZO_ShallowTableCopy(CSJ_SV_DEFAULT.chapterMusic[0])
			end
		end
	end
	if sv.overrideCombatMusic == nil							then sv.overrideCombatMusic								= CSJ_SV_DEFAULT.overrideCombatMusic										end
end

function CSJ:RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(event, initial)
		if self.isFirstTimePlayerActivated then
			self.isFirstTimePlayerActivated = false
			self:CreateSettingPanel()
			self:OverrideMusicDice()
		else
			if initial then
				self:OverrideMusicDice()
			end
		end
	end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(event, inCombat)
		if self.svCurrent.overrideCombatMusic then return end
		if inCombat then
			self:StoreOverrideMusicMode()
			self:SetCombatMusic()
		else
			self:RestoreOverrideMusicMode()
		end
	end)
	CHAMPION_UI_MUSIC_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			self:StoreOverrideMusicMode()
		elseif newState == SCENE_FRAGMENT_HIDDEN then
			self:RestoreOverrideMusicMode()
		end
	end)
	TRIBUTE_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			self:StoreOverrideMusicMode()
		elseif newState == SCENE_FRAGMENT_HIDDEN then
			self:RestoreOverrideMusicMode()
		end
	end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DUEL_INVITE_RECEIVED, function(event)
		self:StoreOverrideMusicMode()
	end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DUEL_INVITE_SENT, function(event)
		self:StoreOverrideMusicMode()
	end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DUEL_FINISHED, function(event)
		self:RestoreOverrideMusicMode()
	end)
	SecurePostHook("SetSetting", function(settingSystemType, settingId, value, setOptions)
		if settingSystemType == SETTING_TYPE_AUDIO and settingId == AUDIO_SETTING_INTRO_MUSIC then
			if not self.isInternalSetting then
				self.savedIntroMusicSetting = value
				self:RestoreMusicToDefault()
			end
			self.isInternalSetting = false
		end
	end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_DEACTIVATED, function(event)
		self:SafeSetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_INTRO_MUSIC, self.savedIntroMusicSetting, SETTINGS_SET_OPTION_DO_NOT_SAVE_TO_PERSISTED_DATA)
	end)
end

function CSJ:SafeSetSetting(system, settingId, value, setOptions)
	self.isInternalSetting = true
	SetSetting(system, settingId, value, setOptions)
end

function CSJ:GetCurrentOverriddenMusic()
	if GetOverrideMusicMode() == OVERRIDE_MUSIC_MODE_CREDITS then
		return tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_INTRO_MUSIC))
	end
end

function CSJ:IsChapterOwned(chapterId)
	local collectibleId = self.lut.ChapterId_To_CollectibleId[chapterId]
	return chapterId == 0 or (collectibleId and IsCollectibleUnlocked(collectibleId) or false)
end

function CSJ:GetChapterIdByZoneId(zoneId)
	return self.lut.ParentZoneId_To_ChapterId[GetParentZoneId(zoneId)]
end

function CSJ:OverrideMusic(dice)
	local dice = dice or 0	-- nil should be 100% regardless of user settings.
	local chapterId = self:GetChapterIdByZoneId(GetUnitWorldPosition("player"))
	if chapterId and self:IsChapterOwned(chapterId) and GetCurrentZoneHouseId() == 0 then
		local desiredIntroMusicSetting = self.svCurrent.chapterMusic[chapterId][1]
		if desiredIntroMusicSetting and dice <= self.svCurrent.chapterMusic[chapterId][2] then
			self:SafeSetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_INTRO_MUSIC, desiredIntroMusicSetting, SETTINGS_SET_OPTION_DO_NOT_SAVE_TO_PERSISTED_DATA)
			SetOverrideMusicMode(OVERRIDE_MUSIC_MODE_CREDITS)
			return true
		end
	end
	self:RestoreMusicToDefault()
end

function CSJ:OverrideMusicDice()
	self:OverrideMusic(zo_random(1, 100))
end

function CSJ:RestoreMusicToDefault()
	self.previousOverrideMusicMode = OVERRIDE_MUSIC_MODE_NONE
	SetOverrideMusicMode(OVERRIDE_MUSIC_MODE_NONE)
end

function CSJ:SetCombatMusic()
	SetOverrideMusicMode(OVERRIDE_MUSIC_MODE_NONE)
end

function CSJ:StoreOverrideMusicMode()
	self.previousOverrideMusicMode = GetOverrideMusicMode()
end

function CSJ:RestoreOverrideMusicMode()
	SetOverrideMusicMode(self.previousOverrideMusicMode)
end


function CSJ:CreateSettingPanel()
	local panelData = {
		type = "panel", 
		name = "CSimpleJukebox", 
		displayName = "Calamath's Simple Jukebox", 
		author = self.author, 
		version = self.version, 
		website = "https://www.esoui.com/downloads/info3406-CalamathsSimpleJukebox.html", 
		feedback = "https://www.esoui.com/downloads/info3406-CalamathsSimpleJukebox.html#comments", 
		donation = "https://www.esoui.com/downloads/info3406-CalamathsSimpleJukebox.html#donate", 
		slashCommand = "/csimplejukebox", 
		registerForRefresh = true, 
		registerForDefaults = true, 
	}
	self.settingPanel = LAM:RegisterAddonPanel("CSimpleJukebox_Options", panelData)

	local optionsData = {}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CSJ_UI_PANEL_HEADER1_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CSJ_UI_ACCOUNT_WIDE_OP_NAME), 
		getFunc = function() return self.svAccount.accountWide end, 
		setFunc = function(newValue) self.svAccount.accountWide = newValue end, 
		tooltip = L(SI_CSJ_UI_ACCOUNT_WIDE_OP_TIPS), 
		width = "full", 
		requiresReload = true, 
		default = CSJ_SV_DEFAULT.accountWide, 
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = L(SI_CSJ_UI_OVERRIDE_COMBAT_MUSIC_NAME), 
		getFunc = function() return self.svCurrent.overrideCombatMusic end, 
		setFunc = function(newValue) self.svCurrent.overrideCombatMusic = newValue end, 
		tooltip = L(SI_CSJ_UI_OVERRIDE_COMBAT_MUSIC_TIPS), 
		width = "full", 
		default = CSJ_SV_DEFAULT.overrideCombatMusic, 
	}
	optionsData[#optionsData + 1] = {
		type = "header", 
		name = "Favorite Music Theme", 
	}
	local chapterThemeChoices, chapterThemeChoicesValues = {}, {}
	for chapterId in pairs(CSJ_SV_DEFAULT.chapterMusic) do
		if not EXEMPT_CHAPTERS[chapterId] and self:IsChapterOwned(chapterId) then
			table.insert(chapterThemeChoicesValues, tostring(chapterId))
			table.insert(chapterThemeChoices, L("SI_CHAPTER", chapterId))
		end
	end

	for chapterId = CHAPTER_ITERATION_BEGIN, CHAPTER_ITERATION_END do
		local isOwned = self:IsChapterOwned(chapterId)
		optionsData[#optionsData + 1] = {
			type = "description", 
			title = "", 
			text = L("SI_CHAPTER", chapterId), 
			width = "full", 
		}
		optionsData[#optionsData + 1] = {
			type = "dropdown", 
			name = "|u25:0::|uFavorite Theme", 
--			tooltip = "", 
			choices = chapterThemeChoices, 
			choicesValues = chapterThemeChoicesValues, 
			getFunc = function() return self.svCurrent.chapterMusic[chapterId][1] end, 
			setFunc = function(newValue) self.svCurrent.chapterMusic[chapterId][1] = newValue end, 
			disabled = not isOwned, 
			width = "full", 
			default = CSJ_SV_DEFAULT.chapterMusic[chapterId][1], 
		}
		optionsData[#optionsData + 1] = {
			type = "slider", 
			name = "|u25:0::|uPercentage to insert favorite music", 
			tooltip = "", 
			getFunc = function() return self.svCurrent.chapterMusic[chapterId][2] end, 
			setFunc = function(newValue) self.svCurrent.chapterMusic[chapterId][2] = newValue end, 
			min = 0.0, 
			max = 100.0, 
			step = 5, 
			disabled = not isOwned, 
			width = "full", 
			default = CSJ_SV_DEFAULT.chapterMusic[chapterId][2], 
		}
	end
	LAM:RegisterOptionControls("CSimpleJukebox_Options", optionsData)
end

function CSJ:PieMenuIntegration()
	if not LCPM then return end
	local presetId = "CSimpleJukebox_pie"
	local numExemptChapters = 0
	for chapterId = CHAPTER_ITERATION_BEGIN, CHAPTER_ITERATION_END do
		if EXEMPT_CHAPTERS[chapterId] then
			numExemptChapters = numExemptChapters + 1
		end
	end
	local jukeboxPieMenu = {
		id = presetId, 
		name = "Simple Jukebox", 
		menuItemsCount = (CHAPTER_ITERATION_END - CHAPTER_ITERATION_BEGIN + 1) - numExemptChapters + 1, -- (numChapters) - numExemptChapters + (turn off)
		tooltip = "This is a simple jukebox playing chapter themed music.", 
		icon = "EsoUI/Art/Icons/housing_uni_inc_musicboxeso001.dds", 
		visual = {
			showIconFrame = true, 
			showSlotLabel = true, 
			showPresetName = true, 
			style = "gamepad", 
			size = 350, 
		}, 
		slot = {}, 
		suppressCancelSlot = true, 
		hidden = false, 
	}
	for chapterId = CHAPTER_ITERATION_END, CHAPTER_ITERATION_BEGIN, -1 do
		if not EXEMPT_CHAPTERS[chapterId] then
			local chapterCollectibleId = self.lut.ChapterId_To_CollectibleId[chapterId]
			local data = {
				type = "shortcut", 
				category = "CSimpleJukebox", 
				name = string.format("%s Music", GetCollectibleName(chapterCollectibleId)), 
				nameColor = function()
					if self:GetCurrentOverriddenMusic() == chapterId then
						return { 0.6, 1, 0, }
					end
				end, 
				icon = GetCollectibleIcon(chapterCollectibleId), 
				showGlow = function()
					return self:GetCurrentOverriddenMusic() == chapterId
				end, 
				callback = function(data)
					local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.NONE)
					messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
					messageParams:SetText("Play " .. data.name)
					CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)

					self:SafeSetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_INTRO_MUSIC, tostring(chapterId), SETTINGS_SET_OPTION_DO_NOT_SAVE_TO_PERSISTED_DATA)
					SetOverrideMusicMode(OVERRIDE_MUSIC_MODE_CREDITS)
				end, 
			}
			table.insert(jukeboxPieMenu.slot, data)
		end
	end
	jukeboxPieMenu.slot[#jukeboxPieMenu.slot].name = string.format("%s Music", L("SI_CHAPTER", 0))	-- Override for Base Game Music slot
	jukeboxPieMenu.slot[#jukeboxPieMenu.slot].icon = "EsoUI/Art/Icons/store_icdlc_collectable.dds"	-- Override for Base Game Music slot
	table.insert(jukeboxPieMenu.slot, {
		type = "shortcut", 
		category = "CSimpleJukebox", 
		name = "Turn Off", 
		icon = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds", 
		callback = function(data)
			local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.NONE)
			messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
			messageParams:SetText("The jukebox was turned off.")
			CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)
			self:RestoreMusicToDefault()
		end, 
	})
	LCPM:RegisterPieMenu(presetId, jukeboxPieMenu)
end


-- ------------------------------------------------
SLASH_COMMANDS["/csimplejukebox.debug"] = function(arg) if arg ~= "" then CSJ:ConfigDebug({tonumber(arg)}) end end

SLASH_COMMANDS["/csimplejukebox.test"] = function(arg)
--	for chapterUpgradeId = 1, GetCurrentChapterUpgradeId() do
	for chapterUpgradeId = 1, 1000 do
		local chapterId = GetChapterEnumFromUpgradeId(chapterUpgradeId)
		local collectibleId = GetChapterCollectibleId(chapterUpgradeId)
		if chapterId and chapterId ~= 0 then
			df("%s -> %s: collectibleId = %s", tostring(chapterUpgradeId), tostring(chapterId), tostring(collectibleId))
		end
	end
end
