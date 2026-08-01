EAA = EAA or {}
local EAA = EAA

EAA.name = "EndlessArchiveAssistant"
EAA.version = "0.1"
local LAM2 = LibAddonMenu2
local zone = 1436
local duration = 0

function EAA.Contains(tbl, x)
    found = false
    for _, v in pairs(tbl) do
        if v == x then 
            found = true 
        end
    end
    return found
end

function EAA.EffectChangedEvent(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	
	local nullpain_ready = true
	
	local Reset = function()
		nullpain_ready = true
	end
	
	--Mirror Shard
	if abilityId == 211802 and (unitTag == "player" or unitTag == "group2") then
		if endTime - beginTime > 9.5 then
			CombatAlerts.AlertCast(192030, unitName, 4500, {-2,2})
		end
	--Glass Sky
	elseif abilityId == 208124 and unitTag == "player" then
		if endTime - beginTime > 4.5 then
			CombatAlerts.AlertCast(193281, unitName, 4500, {-2,2})
		end
	--Null Pain
	elseif abilityId == 212002 and unitTag == "player" and nullpain_ready == true then
		CombatAlerts.AlertCast(212002, unitName, 0, {-2,2})
		nullpain_ready = false
		zo_callLater(Reset, 2000)
	end

end

function EAA.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	
	--Seeking Spheres (Blob interrupt)
	if (result == ACTION_RESULT_BEGIN and abilityId == 192517) then
		CombatAlerts.Alert("Interrupt", GetFormattedAbilityName(192517), 0x00FF00FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
	--Inferno (Flameshaper interrupt)
	elseif (result == ACTION_RESULT_BEGIN and abilityId == 210483) then
		CombatAlerts.Alert("Interrupt", GetFormattedAbilityName(210483), 0xFF0000FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
	--Infuse (Infuser Interrupt)
	elseif (result == ACTION_RESULT_BEGIN and abilityId == 210833) then
		CombatAlerts.Alert("Interrupt", GetFormattedAbilityName(210833), 0x0000FFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
	--Negate Warning
	elseif (result == ACTION_RESULT_BEGIN and abilityId == 196806) then
		CombatAlerts.Alert("Incoming", GetFormattedAbilityName(196806), 0xFF00FFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
	--Spellthief Void Warning (not currently working)
	--elseif (result == ACTION_RESULT_BEGIN and abilityId == 14370) then
	--	CombatAlerts.Alert("Incoming", GetFormattedAbilityName(14370), 0xFF00FFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
	end
	
	--Notification for Heavy Attacks
	if (result == ACTION_RESULT_BEGIN and EAA.Contains(EAA.data.heavyList, abilityId) and string.find(targetName, GetUnitName("player")) and EAA.SV.HeavyAttackNotifications) then
		CombatAlerts.AlertCast(abilityId, targetName, hitValue, {-2,2})
	end
	
	--Notification for Projectiles
	if (result == ACTION_RESULT_BEGIN and EAA.Contains(EAA.data.projectileList, abilityId) and string.find(targetName, GetUnitName("player")) and EAA.SV.ProjectileNotifications) then
		CombatAlerts.AlertCast(abilityId, targetName, hitValue, {-3,2})
	end
end

function EAA.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Daedric's Endless Archive Assistant",
		displayName = "Daedric's Endless Archive Assistant",
		author = "DaedricDoge",
		version = "0.1",
		slashCommand = "/deaa",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local controlOptionPanel = LAM2:RegisterAddonPanel("EndlessArchiveAssistantPanel", panelData)
	
	local optionsData = {
		[1] = {
			type = "description",
			text = "General settings for the addon"
		},
		[2] = {
			type = "checkbox",
			name = "Enable Heavy Attack Notifications",
			getFunc = function() return EAA.SV.HeavyAttackNotifications end,
			setFunc = function(value) EAA.SV.HeavyAttackNotifications = value end,
			default = false,
		},
		[3] = {
			type = "checkbox",
			name = "Enable Projectile Notifications",
			getFunc = function() return EAA.SV.ProjectileNotifications end,
			setFunc = function(value) EAA.SV.ProjectileNotifications = value end,
			default = false,
		}
	}
	
	LAM2:RegisterOptionControls("EndlessArchiveAssistantPanel", optionsData)
end

function EAA.PlayerActivated()

	if GetZoneId(GetUnitZoneIndex("player")) ~= zone then
		return
	end
	
	--d("checking")
	
	EVENT_MANAGER:UnregisterForEvent(EAA.name .. "EffectChangedEvent", EVENT_EFFECT_CHANGED )
	EVENT_MANAGER:RegisterForEvent(EAA.name .. "EffectChangedEvent", EVENT_EFFECT_CHANGED, EAA.EffectChangedEvent)
	
	EVENT_MANAGER:UnregisterForEvent(EAA.name .. "CombatEvent", EVENT_COMBAT_EVENT )
	EVENT_MANAGER:RegisterForEvent(EAA.name .. "CombatEvent", EVENT_COMBAT_EVENT, EAA.CombatEvent)
end

function EAA.OnAddonLoaded(event, addonName)
    if EAA.name ~= addonName then return end
	
	EVENT_MANAGER:UnregisterForEvent(EAA.name, EVENT_ADD_ON_LOADED )
	EVENT_MANAGER:RegisterForEvent(EAA.name .. "PlayerActive", EVENT_PLAYER_ACTIVATED, EAA.PlayerActivated)
	
	EAA.CreateSettingsWindow()
	
	EAA.Default = {
		HeavyAttackNotifications = true,
		ProjectileNotifications = true
	}
	
	EAA.SV = ZO_SavedVars:NewAccountWide("EndlessArchiveAssistantVars", "1.0", nil, EAA.Default)
end

EVENT_MANAGER:RegisterForEvent(EAA.name, EVENT_ADD_ON_LOADED, EAA.OnAddonLoaded)