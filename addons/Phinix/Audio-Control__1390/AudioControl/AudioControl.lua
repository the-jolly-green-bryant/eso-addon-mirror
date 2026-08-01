-------------------------------------------------------------------------------
-- ESO Audio Toggle
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

local EACAddon = _G['EACAddon']
local L = EACAddon:GetLanguage()
local version = "1.18"

local sVars
local defaults = {
--	SETTING_PANEL_AUDIO = 0
--	SETTING_TYPE_AUDIO = 11
--	ZO_SharedOptions_SettingsData[SETTING_PANEL_AUDIO][SETTING_TYPE_AUDIO]:
--	AUDIO_SETTING_AUDIO_VOLUME = 1
--	AUDIO_SETTING_MUSIC_ENABLED = 2
--	AUDIO_SETTING_MUSIC_VOLUME = 3
--	AUDIO_SETTING_SOUND_ENABLED = 16
--	AUDIO_SETTING_AMBIENT_VOLUME = 7
--	AUDIO_SETTING_SFX_VOLUME = 5
--	AUDIO_SETTING_FOOTSTEPS_VOLUME = 15
--	AUDIO_SETTING_VO_VOLUME = 11
--	AUDIO_SETTING_UI_VOLUME = 9
--	AUDIO_SETTING_VIDEO_VOLUME = 19
--	AUDIO_SETTING_COMBAT_MUSIC_MODE = 20
--		[1] = 0,	-- All Combat Music
--		[2] = 1,	-- No Combat Music
--		[3] = 2,	-- Boss Music Only
--	AUDIO_SETTING_BACKGROUND_AUDIO = 12

--	main (example):
--	GetSetting_Bool(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED)
--	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, "true")
--	GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME)
--	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, 70)

	masterOn = true,			-- AUDIO_SETTING_AUDIO_ENABLED
	masterLevel = 100,			-- AUDIO_SETTING_AUDIO_VOLUME
	musicOn = true,				-- AUDIO_SETTING_MUSIC_ENABLED
	musicLevel = 70,			-- AUDIO_SETTING_MUSIC_VOLUME
	combatMode = 0,				-- AUDIO_SETTING_COMBAT_MUSIC_MODE
	backgroundOn = false,		-- AUDIO_SETTING_BACKGROUND_AUDIO
	allSoundOn = true,			-- AUDIO_SETTING_SOUND_ENABLED
	ambientOn = true,			-- AUDIO_SETTING_AMBIENT_ENABLED
	ambientLevel = 70,			-- AUDIO_SETTING_AMBIENT_VOLUME
	effectsOn = true,			-- AUDIO_SETTING_SFX_ENABLED
	effectsLevel = 70,			-- AUDIO_SETTING_SFX_VOLUME
	footstepsOn = true,			-- AUDIO_SETTING_FOOTSTEPS_ENABLED
	footstepsLevel = 70,		-- AUDIO_SETTING_FOOTSTEPS_VOLUME
	dialogueOn = true,			-- AUDIO_SETTING_VO_ENABLED
	dialogueLevel = 70,			-- AUDIO_SETTING_VO_VOLUME
	interfaceOn = true,			-- AUDIO_SETTING_UI_ENABLED
	interfaceLevel = 70,		-- AUDIO_SETTING_UI_VOLUME
	cinematicsOn = true,		-- AUDIO_SETTING_VIDEO_ENABLED
	cinematicsLevel = 100,		-- AUDIO_SETTING_VIDEO_VOLUME
	combatToggle = 0,			
	firstRun = true,
}

local toggleBlocks = {
	[AUDIO_SETTING_AMBIENT_ENABLED] = true,
	[AUDIO_SETTING_SFX_ENABLED] = true,
	[AUDIO_SETTING_FOOTSTEPS_ENABLED] = true,
	[AUDIO_SETTING_VO_ENABLED] = true,
	[AUDIO_SETTING_UI_ENABLED] = true,
	[AUDIO_SETTING_VIDEO_ENABLED] = true,
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon Settings panel
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow()
	local combatMusic = {[1] = GetString(SI_COMBATMUSICMODESETTING0),[2] = GetString(SI_COMBATMUSICMODESETTING1),[3] = GetString(SI_COMBATMUSICMODESETTING2)}
	local combatMusicStringValue = {[GetString(SI_COMBATMUSICMODESETTING0)] = 0,[GetString(SI_COMBATMUSICMODESETTING1)] = 1,[GetString(SI_COMBATMUSICMODESETTING2)] = 2}

	local panelData = {
		type					= "panel",
		name					= L.EAC_MenuTitle,
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize(L.EAC_MenuTitle),
		author					= "|c66ccffPhinix|r",
		version					= version,
		registerForRefresh		= true,
		registerForDefaults		= true
	}

	local optionsData = {
	[1] = {
		type			= 'header',
		name			= L.EAC_MenuGlobalOpts,
	},
	[2] = {
		type			= "checkbox",
		name			= L.EAC_MenuMaster,
		tooltip			= L.EAC_MenuMasterTip,
		getFunc			= function() return sVars.masterOn end,
		setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, tostring(value)) end,
		width			= "half",
		default			= defaults.masterOn,
	},
	[3] = {
		type			= 'slider',
		name			= GetString(SI_AUDIO_OPTIONS_MASTER_VOLUME),
		tooltip			= GetString(SI_AUDIO_OPTIONS_MASTER_VOLUME_TOOLTIP),
		min				= 0,
		max				= 100,
		step			= 1,
		getFunc			= function() return sVars.masterLevel end,
		setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, value) end,
		default			= defaults.masterLevel,
		width			= "half",
		disabled		= function() return not sVars.masterOn end,
	},
	[4] = {
		type			= "checkbox",
		name			= GetString(SI_AUDIO_OPTIONS_MUSIC_ENABLED),
		tooltip			= GetString(SI_AUDIO_OPTIONS_MUSIC_ENABLED_TOOLTIP),
		getFunc			= function() return sVars.musicOn end,
		setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED, tostring(value)) end,
		default			= defaults.musicOn,
		width			= "half",
		disabled		= function() return not sVars.masterOn end,
	},
	[5] = {
		type			= 'slider',
		name			= GetString(SI_AUDIO_OPTIONS_MUSIC_VOLUME),
		tooltip			= GetString(SI_AUDIO_OPTIONS_MUSIC_VOLUME_TOOLTIP),
		min				= 0,
		max				= 100,
		step			= 1,
		getFunc			= function() return sVars.musicLevel end,
		setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME, value) end,
		default			= defaults.musicLevel,
		width			= "half",
		disabled		= function() return not sVars.masterOn or not sVars.musicOn end,
	},
	[6] = {
		type			= 'dropdown',
		name			= GetString(SI_AUDIO_OPTIONS_COMBAT_MUSIC),
		tooltip			= GetString(SI_AUDIO_OPTIONS_COMBAT_MUSIC_TOOLTIP),
		choices			= combatMusic,
		getFunc			= function() 
							for k, v in pairs(combatMusic) do
								if combatMusicStringValue[v] == sVars.combatMode then return combatMusic[k] end
							end
						end,
		setFunc			= function(selected) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_COMBAT_MUSIC_MODE, combatMusicStringValue[selected]) end,
		default			= defaults.combatMode,
		disabled		= function() return not sVars.masterOn end,
	},
	[7] = {
		type			= "checkbox",
		name			= GetString(SI_AUDIO_OPTIONS_BACKGROUND_AUDIO),
		tooltip			= GetString(SI_AUDIO_OPTIONS_BACKGROUND_AUDIO_TOOLTIP),
		getFunc			= function() return sVars.backgroundOn end,
		setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_BACKGROUND_AUDIO, tostring(value)) end,
		default			= defaults.backgroundOn,
		disabled		= function() return not sVars.masterOn end,
	},
	[8] = {
		type			= "checkbox",
		name			= L.EAC_MenuSounds,
		tooltip			= L.EAC_MenuSoundsTip,
		getFunc			= function() return sVars.allSoundOn end,
		setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SOUND_ENABLED, tostring(value)) end,
		default			= defaults.allSoundOn,
		disabled		= function() return not sVars.masterOn end,
	},
	[9] = {
		type			= 'submenu',
		name			= L.EAC_MenuIndividual,
		tooltip			= L.EAC_MenuIndividualTip,
		controls		= {
						[1] = {
							type			= "checkbox",
							name			= L.EAC_MenuAmbient,
							tooltip			= L.EAC_MenuAmbientTip,
							getFunc			= function() return sVars.ambientOn end,
							setFunc			= function(value)
												sVars.ambientOn = value
												toggleBlocks[AUDIO_SETTING_AMBIENT_ENABLED] = false
												SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_ENABLED, tostring(value))
											end,
							default			= defaults.ambientOn,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn end,
						},
						[2] = {
							type			= 'slider',
							name			= GetString(SI_AUDIO_OPTIONS_AMBIENT_VOLUME),
							tooltip			= GetString(SI_AUDIO_OPTIONS_AMBIENT_VOLUME_TOOLTIP),
							min				= 0,
							max				= 100,
							step			= 1,
							getFunc			= function() return sVars.ambientLevel end,
							setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME, value) end,
							default			= defaults.ambientLevel,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn or not sVars.ambientOn end,
						},
						[3] = {
							type			= "checkbox",
							name			= L.EAC_MenuEffects,
							tooltip			= L.EAC_MenuEffectsTip,
							getFunc			= function() return sVars.effectsOn end,
							setFunc			= function(value)
												sVars.effectsOn = value
												toggleBlocks[AUDIO_SETTING_SFX_ENABLED] = false
												SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_ENABLED, tostring(value))
											end,
							default			= defaults.effectsOn,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn end,
						},
						[4] = {
							type			= 'slider',
							name			= GetString(SI_AUDIO_OPTIONS_SFX_VOLUME),
							tooltip			= GetString(SI_AUDIO_OPTIONS_SFX_VOLUME_TOOLTIP),
							min				= 0,
							max				= 100,
							step			= 1,
							getFunc			= function() return sVars.effectsLevel end,
							setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, value) end,
							default			= defaults.effectsLevel,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn or not sVars.effectsOn end,
						},
						[5] = {
							type			= "checkbox",
							name			= L.EAC_MenuFootstep,
							tooltip			= L.EAC_MenuFootstepTip,
							getFunc			= function() return sVars.footstepsOn end,
							setFunc			= function(value)
												sVars.footstepsOn = value
												toggleBlocks[AUDIO_SETTING_FOOTSTEPS_ENABLED] = false
												SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_ENABLED, tostring(value))
											end,
							default			= defaults.footstepsOn,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn end,
						},
						[6] = {
							type			= 'slider',
							name			= GetString(SI_AUDIO_OPTIONS_FOOTSTEPS_VOLUME),
							tooltip			= GetString(SI_AUDIO_OPTIONS_FOOTSTEPS_VOLUME_TOOLTIP),
							min				= 0,
							max				= 100,
							step			= 1,
							getFunc			= function() return sVars.footstepsLevel end,
							setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME, value) end,
							default			= defaults.footstepsLevel,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn or not sVars.footstepsOn end,
						},
						[7] = {
							type			= "checkbox",
							name			= L.EAC_MenuDialogue,
							tooltip			= L.EAC_MenuDialogueTip,
							getFunc			= function() return sVars.dialogueOn end,
							setFunc			= function(value)
												sVars.dialogueOn = value
												toggleBlocks[AUDIO_SETTING_VO_ENABLED] = false
												SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_ENABLED, tostring(value))
											end,
							default			= defaults.dialogueOn,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn end,
						},
						[8] = {
							type			= 'slider',
							name			= GetString(SI_AUDIO_OPTIONS_VO_VOLUME),
							tooltip			= GetString(SI_AUDIO_OPTIONS_VO_VOLUME_TOOLTIP),
							min				= 0,
							max				= 100,
							step			= 1,
							getFunc			= function() return sVars.dialogueLevel end,
							setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, value) end,
							default			= defaults.dialogueLevel,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn or not sVars.dialogueOn end,
						},
						[9] = {
							type			= "checkbox",
							name			= L.EAC_MenuInterface,
							tooltip			= L.EAC_MenuInterfaceTip,
							getFunc			= function() return sVars.interfaceOn end,
							setFunc			= function(value)
												sVars.interfaceOn = value
												toggleBlocks[AUDIO_SETTING_UI_ENABLED] = false
												SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_ENABLED, tostring(value))
											end,
							default			= defaults.interfaceOn,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn end,
						},
						[10] = {
							type			= 'slider',
							name			= GetString(SI_AUDIO_OPTIONS_UI_VOLUME),
							tooltip			= GetString(SI_AUDIO_OPTIONS_UI_VOLUME_TOOLTIP),
							min				= 0,
							max				= 100,
							step			= 1,
							getFunc			= function() return sVars.interfaceLevel end,
							setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, value) end,
							default			= defaults.interfaceLevel,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn or not sVars.interfaceOn end,
						},
						[11] = {
							type			= "checkbox",
							name			= L.EAC_MenuCinematic,
							tooltip			= L.EAC_MenuCinematicTip,
							getFunc			= function() return sVars.cinematicsOn end,
							setFunc			= function(value)
												sVars.cinematicsOn = value
												toggleBlocks[AUDIO_SETTING_VIDEO_ENABLED] = false
												SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VIDEO_ENABLED, tostring(value))
											end,
							default			= defaults.cinematicsOn,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn end,
						},
						[12] = {
							type			= 'slider',
							name			= GetString(SI_AUDIO_OPTIONS_VIDEO_VOLUME),
							tooltip			= GetString(SI_AUDIO_OPTIONS_VIDEO_VOLUME_TOOLTIP),
							min				= 0,
							max				= 100,
							step			= 1,
							getFunc			= function() return sVars.cinematicsLevel end,
							setFunc			= function(value) SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VIDEO_VOLUME, value) end,
							default			= defaults.cinematicsLevel,
							width			= "half",
							disabled		= function() return not sVars.masterOn or not sVars.allSoundOn or not sVars.cinematicsOn end,
						},
					},
	},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("EACAddon_Panel", panelData)
	LAM:RegisterOptionControls("EACAddon_Panel", optionsData)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ID Functions
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
-- Init and XML handler
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EACAddon.Bindings(option)
	local toggleOption = {
		[1] = AUDIO_SETTING_AUDIO_ENABLED,
		[2] = AUDIO_SETTING_SOUND_ENABLED,
		[3] = AUDIO_SETTING_MUSIC_ENABLED,
		[4] = AUDIO_SETTING_AMBIENT_ENABLED,
		[5] = AUDIO_SETTING_SFX_ENABLED,
		[6] = AUDIO_SETTING_FOOTSTEPS_ENABLED,
		[7] = AUDIO_SETTING_VO_ENABLED,
		[8] = AUDIO_SETTING_UI_ENABLED,
		[9] = AUDIO_SETTING_VIDEO_ENABLED,
		[10] = AUDIO_SETTING_COMBAT_MUSIC_MODE,
	}
	local tValue
	if option < 10 then
		tValue = not GetSetting_Bool(SETTING_TYPE_AUDIO, toggleOption[option])
	else
		tValue = (tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_COMBAT_MUSIC_MODE)) ~= 1) and 1 or (sVars.combatToggle ~= 1) and sVars.combatToggle or 0
	end

	if option > 3 and option < 10 then toggleBlocks[toggleOption[option]] = false end
	SetSetting(SETTING_TYPE_AUDIO, toggleOption[option], tostring(tValue))

	if option == 1 then sVars.masterOn = tValue d((tValue) and L.EAC_AllOn or L.EAC_AllOff)
	elseif option == 2 then sVars.allSoundOn = tValue d((tValue) and L.EAC_SoundOn or L.EAC_SoundOff)
	elseif option == 3 then sVars.musicOn = tValue d((tValue) and L.EAC_MusicOn or L.EAC_MusicOff)
	elseif option == 4 then sVars.ambientOn = tValue d((tValue) and L.EAC_AmbientOn or L.EAC_AmbientOff)
	elseif option == 5 then sVars.effectsOn = tValue d((tValue) and L.EAC_EffectsOn or L.EAC_EffectsOff)
	elseif option == 6 then sVars.footstepsOn = tValue d((tValue) and L.EAC_FootstepsOn or L.EAC_FootstepsOff)
	elseif option == 7 then sVars.dialogueOn = tValue d((tValue) and L.EAC_DialogueOn or L.EAC_DialogueOff)
	elseif option == 8 then sVars.interfaceOn = tValue d((tValue) and L.EAC_InterfaceOn or L.EAC_InterfaceOff)
	elseif option == 9 then sVars.cinematicsOn = tValue d((tValue) and L.EAC_CinematicOn or L.EAC_CinematicOff)
	elseif option == 10 then sVars.combatMode = tValue d((tValue == 1) and L.EAC_CombatAllOff or (tValue == 0) and L.EAC_CombatAllOn or L.EAC_CombatBossOn) end
end

local function SetupHooks()
	ZO_PreHook("SetSetting", function(sType, sSetting, sValue)
		if sType == SETTING_TYPE_AUDIO then
			if sSetting == AUDIO_SETTING_AMBIENT_ENABLED then
				if not toggleBlocks[AUDIO_SETTING_AMBIENT_ENABLED] then toggleBlocks[AUDIO_SETTING_AMBIENT_ENABLED] = true else return true end
			elseif sSetting == AUDIO_SETTING_SFX_ENABLED then
				if not toggleBlocks[AUDIO_SETTING_SFX_ENABLED] then toggleBlocks[AUDIO_SETTING_SFX_ENABLED] = true else return true end
			elseif sSetting == AUDIO_SETTING_FOOTSTEPS_ENABLED then
				if not toggleBlocks[AUDIO_SETTING_FOOTSTEPS_ENABLED] then toggleBlocks[AUDIO_SETTING_FOOTSTEPS_ENABLED] = true else return true end
			elseif sSetting == AUDIO_SETTING_VO_ENABLED then
				if not toggleBlocks[AUDIO_SETTING_VO_ENABLED] then toggleBlocks[AUDIO_SETTING_VO_ENABLED] = true else return true end
			elseif sSetting == AUDIO_SETTING_UI_ENABLED then
				if not toggleBlocks[AUDIO_SETTING_UI_ENABLED] then toggleBlocks[AUDIO_SETTING_UI_ENABLED] = true else return true end
			elseif sSetting == AUDIO_SETTING_VIDEO_ENABLED then
				if not toggleBlocks[AUDIO_SETTING_VIDEO_ENABLED] then toggleBlocks[AUDIO_SETTING_VIDEO_ENABLED] = true else return true end
			end
		end
	end)
	SecurePostHook("SetSetting", function(sType, sSetting, sValue)
		if sType == SETTING_TYPE_AUDIO then
			local string2boolean = {["true"]=true,["false"]=false}
			if sSetting == AUDIO_SETTING_AUDIO_ENABLED then
				sVars.masterOn = string2boolean[sValue]
			elseif sSetting == AUDIO_SETTING_AUDIO_VOLUME then
				sVars.masterLevel = sValue
			elseif sSetting == AUDIO_SETTING_MUSIC_ENABLED then
				sVars.musicOn = string2boolean[sValue]
			elseif sSetting == AUDIO_SETTING_MUSIC_VOLUME then
				sVars.musicLevel = sValue
			elseif sSetting == AUDIO_SETTING_SOUND_ENABLED then
				sVars.allSoundOn = string2boolean[sValue]
				if string2boolean[sValue] == true then
				--	the game turns individual sound types back on when toggling master sound from off to on so reset them to saved state
					toggleBlocks[AUDIO_SETTING_AMBIENT_ENABLED] = false
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_ENABLED, tostring(sVars.ambientOn))
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME, sVars.ambientLevel)
					toggleBlocks[AUDIO_SETTING_SFX_ENABLED] = false
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_ENABLED, tostring(sVars.effectsOn))
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, sVars.effectsLevel)
					toggleBlocks[AUDIO_SETTING_FOOTSTEPS_ENABLED] = false
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_ENABLED, tostring(sVars.footstepsOn))
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME, sVars.footstepsLevel)
					toggleBlocks[AUDIO_SETTING_VO_ENABLED] = false
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_ENABLED, tostring(sVars.dialogueOn))
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, sVars.dialogueLevel)
					toggleBlocks[AUDIO_SETTING_UI_ENABLED] = false
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_ENABLED, tostring(sVars.interfaceOn))
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, sVars.interfaceLevel)
					toggleBlocks[AUDIO_SETTING_VIDEO_ENABLED] = false
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VIDEO_ENABLED, tostring(sVars.cinematicsOn))
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VIDEO_VOLUME, sVars.cinematicsLevel)
				end
			elseif sSetting == AUDIO_SETTING_AMBIENT_VOLUME then
				sVars.ambientLevel = sValue
			elseif sSetting == AUDIO_SETTING_SFX_VOLUME then
				sVars.effectsLevel = sValue
			elseif sSetting == AUDIO_SETTING_FOOTSTEPS_VOLUME then
				sVars.footstepsLevel = sValue
			elseif sSetting == AUDIO_SETTING_VO_VOLUME then
				sVars.dialogueLevel = sValue
			elseif sSetting == AUDIO_SETTING_UI_VOLUME then
				sVars.interfaceLevel = sValue
			elseif sSetting == AUDIO_SETTING_VIDEO_VOLUME then
				sVars.cinematicsLevel = sValue
			elseif sSetting == AUDIO_SETTING_COMBAT_MUSIC_MODE then
				sVars.combatMode = tonumber(sValue)
				sVars.combatToggle = tonumber(sValue)
			elseif sSetting == AUDIO_SETTING_BACKGROUND_AUDIO then
				sVars.backgroundOn = string2boolean[sValue]
			end
		end
	end)
end

local function OnPlayerLoaded(_, initial)
	if sVars.firstRun then
		sVars.masterOn = GetSetting_Bool(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED)
		sVars.masterLevel = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME)
		sVars.musicOn = GetSetting_Bool(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED)
		sVars.musicLevel = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME)
		sVars.allSoundOn = GetSetting_Bool(SETTING_TYPE_AUDIO, AUDIO_SETTING_SOUND_ENABLED)
		sVars.ambientOn = GetSetting_Bool(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_ENABLED)
		sVars.ambientLevel = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME)
		sVars.effectsOn = GetSetting_Bool(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_ENABLED)
		sVars.effectsLevel = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME)
		sVars.footstepsOn = GetSetting_Bool(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_ENABLED)
		sVars.footstepsLevel = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME)
		sVars.dialogueOn = GetSetting_Bool(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_ENABLED)
		sVars.dialogueLevel = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME)
		sVars.interfaceOn = GetSetting_Bool(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_ENABLED)
		sVars.interfaceLevel = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME)
		sVars.cinematicsOn = GetSetting_Bool(SETTING_TYPE_AUDIO, AUDIO_SETTING_VIDEO_ENABLED)
		sVars.cinematicsLevel = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VIDEO_VOLUME)
		sVars.combatMode = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_COMBAT_MUSIC_MODE))
		sVars.combatToggle = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_COMBAT_MUSIC_MODE))
		sVars.backgroundOn = GetSetting_Bool(SETTING_TYPE_AUDIO, AUDIO_SETTING_BACKGROUND_AUDIO)
		sVars.firstRun = false
	else
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, tostring(sVars.masterOn))
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, sVars.masterLevel)
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED, tostring(sVars.musicOn))
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME, sVars.musicLevel)
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SOUND_ENABLED, tostring(sVars.allSoundOn))
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_ENABLED, tostring(sVars.ambientOn))
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME, sVars.ambientLevel)
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_ENABLED, tostring(sVars.effectsOn))
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, sVars.effectsLevel)
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_ENABLED, tostring(sVars.footstepsOn))
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME, sVars.footstepsLevel)
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_ENABLED, tostring(sVars.dialogueOn))
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, sVars.dialogueLevel)
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_ENABLED, tostring(sVars.interfaceOn))
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, sVars.interfaceLevel)
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VIDEO_ENABLED, tostring(sVars.cinematicsOn))
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VIDEO_VOLUME, sVars.cinematicsLevel)
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_COMBAT_MUSIC_MODE, sVars.combatMode)
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_BACKGROUND_AUDIO, tostring(sVars.backgroundOn))
	end
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= "AudioControl" then return end
	EVENT_MANAGER:UnregisterForEvent("AudioControl", EVENT_ADD_ON_LOADED)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ALL", L.EAC_ToggleAll)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ALL_SOUNDS", L.EAC_ToggleSounds)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_MUSIC", L.EAC_ToggleMusic)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_AMBIENT", L.EAC_ToggleAmbient)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_EFFECTS", L.EAC_ToggleEffects)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_FOOTSTEPS", L.EAC_ToggleFootsteps)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_DIALOGUE", L.EAC_ToggleDialogue)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_INTERFACE", L.EAC_ToggleInterface)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_CINEMATICS", L.EAC_ToggleCinematic)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_COMBAT", L.EAC_ToggleCombat)

	sVars = ZO_SavedVars:NewAccountWide('AudioControl', 1.14, nil, defaults, GetWorldName())

	CreateSettingsWindow()
	SetupHooks()
end

SLASH_COMMANDS['/acall'] = function() EACAddon.Bindings(1) end
SLASH_COMMANDS['/acsound'] = function() EACAddon.Bindings(2) end
SLASH_COMMANDS['/acmusic'] = function() EACAddon.Bindings(3) end
SLASH_COMMANDS['/acambient'] = function() EACAddon.Bindings(4) end
SLASH_COMMANDS['/aceffects'] = function() EACAddon.Bindings(5) end
SLASH_COMMANDS['/acfootsteps'] = function() EACAddon.Bindings(6) end
SLASH_COMMANDS['/acdialogue'] = function() EACAddon.Bindings(7) end
SLASH_COMMANDS['/acinterface'] = function() EACAddon.Bindings(8) end
SLASH_COMMANDS['/accinematics'] = function() EACAddon.Bindings(9) end
SLASH_COMMANDS['/accombat'] = function() EACAddon.Bindings(10) end

EVENT_MANAGER:RegisterForEvent("AudioControl", EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent("AudioControl", EVENT_PLAYER_ACTIVATED, OnPlayerLoaded)
