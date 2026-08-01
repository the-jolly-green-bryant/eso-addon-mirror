local HarvensInCombatAudioVolume = {}

function HarvensInCombatAudioVolume:SetupOptions()
	local settings = LibHarvensAddonSettings:AddAddon("Harven's In-Combat Audio Volume")
	if not settings then return end
	
	local music = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(SI_AUDIO_OPTIONS_MUSIC_VOLUME),
		min = 0,
		max = 100,
		step = 1,
		format = "%d",
		getFunction = function() return self.sv.music end,
		setFunction = function(value) self.sv.music = value end,
	}
	
	local ambience = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(SI_AUDIO_OPTIONS_AMBIENT_VOLUME),
		min = 0,
		max = 100,
		step = 1,
		format = "%d",
		getFunction = function() return self.sv.ambience end,
		setFunction = function(value) self.sv.ambience = value end,
	}
	
	local effects = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(SI_AUDIO_OPTIONS_SFX_VOLUME),
		min = 0,
		max = 100,
		step = 1,
		format = "%d",
		getFunction = function() return self.sv.effects end,
		setFunction = function(value) self.sv.effects = value end,
	}
	
	local footsteps = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(SI_AUDIO_OPTIONS_FOOTSTEPS_VOLUME),
		min = 0,
		max = 100,
		step = 1,
		format = "%d",
		getFunction = function() return self.sv.footsteps end,
		setFunction = function(value) self.sv.footsteps = value end,
	}
	
	local dialogue = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(SI_AUDIO_OPTIONS_VO_VOLUME),
		min = 0,
		max = 100,
		step = 1,
		format = "%d",
		getFunction = function() return self.sv.dialogue end,
		setFunction = function(value) self.sv.dialogue = value end,
	}

	local interface = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(SI_AUDIO_OPTIONS_UI_VOLUME),
		min = 0,
		max = 100,
		step = 1,
		format = "%d",
		getFunction = function() return self.sv.interface end,
		setFunction = function(value) self.sv.interface = value end,
	}

	settings:AddSettings({music, ambience, effects, footsteps, dialogue, interface})
end

function HarvensInCombatAudioVolume:CombatState(inCombat)
	--d("Combat state: "..tostring(inCombat))
	if self.sv.music ~= self.outOfCombat.music then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME, inCombat and self.sv.music or self.outOfCombat.music)
	end
	if self.sv.ambience ~= self.outOfCombat.ambience then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME, inCombat and self.sv.ambience or self.outOfCombat.ambience)
	end
	if self.sv.effects ~= self.outOfCombat.effects then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, inCombat and self.sv.effects or self.outOfCombat.effects)
	end
	if self.sv.footsteps ~= self.outOfCombat.footsteps then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME, inCombat and self.sv.footsteps or self.outOfCombat.footsteps)
	end
	if self.sv.dialogue ~= self.outOfCombat.dialogue then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, inCombat and self.sv.dialogue or self.outOfCombat.dialogue)
	end
	if self.sv.interface ~= self.outOfCombat.interface then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, inCombat and self.sv.interface or self.outOfCombat.interface)
	end
	EVENT_MANAGER:UnregisterForUpdate("HarvensInCombatAudioVolumeDelay")
end

local function HarvensInCombatAudioVolume_CombatState(eventType, inCombat)
	if inCombat then
		HarvensInCombatAudioVolume:CombatState(inCombat)
	else
		EVENT_MANAGER:RegisterForUpdate("HarvensInCombatAudioVolumeDelay", 1500, function() HarvensInCombatAudioVolume:CombatState(false) end)
	end
end

function HarvensInCombatAudioVolume:Initialize()
	self.sv = {}
	self.outOfCombat = { music = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME)), 
						ambience = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME)), 
						effects = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME)), 
						footsteps = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME)),
						dialogue = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME)),
						interface = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME)), }
	
	local defaults = { music = self.outOfCombat.music, 
						ambience = self.outOfCombat.ambience, 
						effects = self.outOfCombat.effects, 
						footsteps = self.outOfCombat.footsteps,
						dialogue = self.outOfCombat.dialogue,
						interface = self.outOfCombat.interface }

	self.sv = ZO_SavedVars:New("HarvensInCombatAudioVolume_SavedVariables", 1, nil, defaults)
	
	HarvensInCombatAudioVolume:SetupOptions()
	
	self.musicOnReleasedHandler = Options_Audio_MusicVolume.onReleasedHandler
	Options_Audio_MusicVolume.onReleasedHandler = function(...)
		self.musicOnReleasedHandler(...)
		self.outOfCombat.music = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME))
	end
	
	self.ambientOnReleasedHandler = Options_Audio_AmbientVolume.onReleasedHandler
	Options_Audio_AmbientVolume.onReleasedHandler = function(...)
		self.ambientOnReleasedHandler(...)
		self.outOfCombat.ambient = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME))
	end
	
	self.SFXOnReleasedHandler = Options_Audio_SFXVolume.onReleasedHandler
	Options_Audio_SFXVolume.onReleasedHandler = function(...)
		self.SFXOnReleasedHandler(...)
		self.outOfCombat.effects = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME))
	end
	
	self.footstepsOnReleasedHandler = Options_Audio_FootstepsVolume.onReleasedHandler
	Options_Audio_FootstepsVolume.onReleasedHandler = function(...)
		self.footstepsOnReleasedHandler(...)
		self.outOfCombat.footsteps = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME))
	end
	
	self.VOOnReleasedHandler = Options_Audio_VOVolume.onReleasedHandler
	Options_Audio_VOVolume.onReleasedHandler = function(...)
		self.VOOnReleasedHandler(...)
		self.outOfCombat.dialogue = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME))
	end
	
	self.UISoundOnReleasedHandler = Options_Audio_UISoundVolume.onReleasedHandler
	Options_Audio_UISoundVolume.onReleasedHandler = function(...)
		self.UISoundOnReleasedHandler(...)
		self.outOfCombat.interface = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME))
	end
end

local function HarvensInCombatAudioVolume_Initialize(eventType, addonName)
	if addonName ~= "HarvensInCombatAudioVolume" then return end
	
	HarvensInCombatAudioVolume:Initialize()
	EVENT_MANAGER:RegisterForEvent("HarvensInCombatAudioVolumeCombatState", EVENT_PLAYER_COMBAT_STATE, HarvensInCombatAudioVolume_CombatState )
end

EVENT_MANAGER:RegisterForEvent("HarvensInCombatAudioVolumeInitialize", EVENT_ADD_ON_LOADED, HarvensInCombatAudioVolume_Initialize)