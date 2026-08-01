local CB = CarrionBlocker

function CB.Enable()
	SYNERGY.control:UnregisterForEvent(EVENT_SYNERGY_ABILITY_CHANGED)
	EVENT_MANAGER:RegisterForEvent(CB.name, EVENT_SYNERGY_ABILITY_CHANGED, CB.synergyChanged)
	EVENT_MANAGER:RegisterForEvent(CB.name, EVENT_EFFECT_CHANGED, CB.effectChanged)
	EVENT_MANAGER:RegisterForEvent(CB.name, EVENT_PLAYER_ACTIVATED, CB.playerActivated)
	CB.synergyChanged()
	CB.isLoaded = true
end

function CB.Disable()
	EVENT_MANAGER:UnregisterForEvent(CB.name, EVENT_SYNERGY_ABILITY_CHANGED)
	SYNERGY.control:RegisterForEvent(EVENT_SYNERGY_ABILITY_CHANGED, SYNERGY.OnSynergyAbilityChanged)
	EVENT_MANAGER:UnregisterForEvent(CB.name, EVENT_EFFECT_CHANGED)
	SYNERGY:OnSynergyAbilityChanged()
	CB.isLoaded = false
end

function CB.hexToRgba(hex)
	local R = math.floor(hex / 16777216) % 256
	local G = math.floor(hex / 65536) % 256
	local B = math.floor(hex / 256) % 256
	local A = hex % 256
	return R/255, G/255, B/255, A/255
end

function CB.rgbaToHex(r, g, b, a)
	local R = math.floor(r * 255 + 0.5)
	local G = math.floor(g * 255 + 0.5)
	local B = math.floor(b * 255 + 0.5)
	local A = math.floor(a * 255 + 0.5)
	return R * 16777216 + G * 65536 + B * 256 + A
end

function CB.effectChanged(event, changeType, slot, name, unitTag, beginTime, endTime, count, icon, buffType, effectType, abilityType, statusType, unitName, unitId, abilityId)
	if unitTag ~= "player" then return end
	if abilityId == CB.CAUSTIC_CARRION_ABILITY_ID_1 or abilityId == CB.CAUSTIC_CARRION_ABILITY_ID_2 then
		if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
			if count > CB.playerStacks then
				if CB.sVar.isEnabledChat == true then
					if count <= CB.sVar.threshold - 4 then
						d("|cff7f00[CB]|r |c00ff00Stacks of Caustic Carrion: " .. tostring(count) .. " / " .. tostring(CB.sVar.threshold) .. "|r")
					elseif count <= CB.sVar.threshold - 3 then
						d("|cff7f00[CB]|r |c7fff00Stacks of Caustic Carrion: " .. tostring(count) .. " / " .. tostring(CB.sVar.threshold) .. "|r")
					elseif count <= CB.sVar.threshold - 2 then
						d("|cff7f00[CB]|r |cffff00Stacks of Caustic Carrion: " .. tostring(count) .. " / " .. tostring(CB.sVar.threshold) .. "|r")
					elseif count <= CB.sVar.threshold - 1 then
						d("|cff7f00[CB]|r |cff7f00Stacks of Caustic Carrion: " .. tostring(count) .. " / " .. tostring(CB.sVar.threshold) .. "|r")
					else
						d("|cff7f00[CB]|r |cff0000Stacks of Caustic Carrion: " .. tostring(count) .. " / " .. tostring(CB.sVar.threshold) .. " Cleanse Now!|r")
					end
				end
				if CB.sVar.isShowBorderColor == true then
					if count <= CB.sVar.threshold - 4 then
						CB.hideNotification()
						local string = "Stacks of Caustic Carrion: " .. tostring(count)
						CB.showNotification(CB.colorHex0, 2500, string)
					elseif count <= CB.sVar.threshold - 3 then
						CB.hideNotification()
						local string = "Stacks of Caustic Carrion: " .. tostring(count)
						CB.showNotification(CB.colorHex25, 2500, string)
					elseif count <= CB.sVar.threshold - 2 then
						CB.hideNotification()
						local string = "Stacks of Caustic Carrion: " .. tostring(count)
						CB.showNotification(CB.colorHex50, 2500, string)
					elseif count <= CB.sVar.threshold - 1 then
						CB.hideNotification()
						local string = "Stacks of Caustic Carrion: " .. tostring(count)
						CB.showNotification(CB.colorHex75, 2500, string)
					else
						CB.hideNotification()
						local string = "Stacks of Caustic Carrion: " .. tostring(count)
						CB.showNotification(CB.colorHex100, 2500, string)
					end
				end
				CB.playerStacks = count
			end
		elseif changeType == EFFECT_RESULT_FADED then
			if CB.sVar.isEnabledChat == true then
				d("|cff7f00[CB]|r |c00ff00Cleansed!|r")
			end
			if CB.sVar.isShowBorderColor == true then
				CB.hideNotification()
				local string = "Cleansed!"
				CB.showNotification(CB.colorHex, 1000, string)
			end
			CB.playerStacks = 0
			zo_callLater(function()
				CB.hideNotification()
			end, 1000)
		end
	end
end

function CB.canUseSynergy(synergyName)
	CB.isCarrionShield = false
	for lang, name in pairs(CB.synergyNames) do
		if synergyName == name then
			CB.isCarrionShield = true
			break
		end
	end
	if CB.isCarrionShield == true then
		if CB.playerStacks < CB.sVar.threshold then
			return false
		end
	end

	return true
end

function CB.synergyChanged()
	local hasSynergy, synergyName, icon, prompt = GetCurrentSynergyInfo()
	if hasSynergy == true then
		synergyName = zo_strformat("<<1>>", synergyName)
		if CB.canUseSynergy(synergyName) then
			SYNERGY.icon:SetTexture(icon)
			SYNERGY.action:SetText(prompt)
			SHARED_INFORMATION_AREA:SetHidden(SYNERGY, false)
		else
			SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
		end
	else
		SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
	end
end

function CB.playerActivated()
	if GetZoneId(GetUnitZoneIndex("player")) ~= CB.osseinCageId or not CB.sVar.isEnabled then
    	CB.hideNotification()
		CB.Disable()
		return
	elseif not CB.isLoaded then CB.Enable() end
	CB.playerStacks = 0
	for i = 1, GetNumBuffs("player") do
		local _, _, _, _, count, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
		if abilityId == CB.CAUSTIC_CARRION_ABILITY_ID_1 or abilityId == CB.CAUSTIC_CARRION_ABILITY_ID_2 then
			CB.playerStacks = count
			break
		end
	end
	CB.synergyChanged()
end