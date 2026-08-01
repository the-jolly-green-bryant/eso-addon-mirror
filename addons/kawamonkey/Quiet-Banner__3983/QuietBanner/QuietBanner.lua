local abilityIds = {
	217704, -- Sundering Banner
	217705, -- Magical Banner
	217706, -- Shocking Banner
--	227003, -- Fiery Banner
	227004, -- Shattering Banner
	227007, -- Restorative Banner
	227008, -- Fortifying Banner
	227009, -- Binding Banner
}

local lastVolume

local function OnEffectChanged(_, changeType, _, _, unitTag)
	if changeType == EFFECT_RESULT_GAINED then
		if unitTag == "player" then
			if lastVolume ~= nil then
				EVENT_MANAGER:UnregisterForUpdate("QuietBanner")
				SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, lastVolume)
				lastVolume = nil
			end
		else
			currentVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME))

			if currentVolume ~= 0 then
				lastVolume = currentVolume
				SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, 0)
			end

			EVENT_MANAGER:RegisterForUpdate(
				"QuietBanner",
				1,
				function()
					EVENT_MANAGER:UnregisterForUpdate("QuietBanner")
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, lastVolume)
					lastVolume = nil
				end
			)
		end
	end
end

for _, abilityId in ipairs(abilityIds) do
	EVENT_MANAGER:RegisterForEvent("QuietBanner"..abilityId, EVENT_EFFECT_CHANGED, OnEffectChanged)
	EVENT_MANAGER:AddFilterForEvent("QuietBanner"..abilityId, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	EVENT_MANAGER:AddFilterForEvent("QuietBanner"..abilityId, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
end


-- workaround for Fiery Banner ignoring SFX volume controls

local lastFieryVolume

local function OnFieryEffectChanged(_, changeType, _, _, unitTag)
	if changeType == EFFECT_RESULT_GAINED then
		if unitTag == "player" then
			if lastFieryVolume ~= nil then
				EVENT_MANAGER:UnregisterForUpdate("FieryQuietBanner")
				SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, lastFieryVolume)
				lastFieryVolume = nil
			end
		else
			currentVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME))

			if currentVolume ~= 0 then
				lastFieryVolume = currentVolume
				SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, 0)
			end

			EVENT_MANAGER:RegisterForUpdate(
				"FieryQuietBanner",
				1,
				function()
					EVENT_MANAGER:UnregisterForUpdate("FieryQuietBanner")
					SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, lastFieryVolume)
					lastFieryVolume = nil
				end
			)
		end
	end
end

EVENT_MANAGER:RegisterForEvent("FieryQuietBanner", EVENT_EFFECT_CHANGED, OnFieryEffectChanged)
EVENT_MANAGER:AddFilterForEvent("FieryQuietBanner", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
EVENT_MANAGER:AddFilterForEvent("FieryQuietBanner", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 227003)