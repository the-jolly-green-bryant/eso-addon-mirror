-----------------
---- Globals ----
-----------------
HowToKyne = HowToKyne or {}
local HowToKyne = HowToKyne

HowToKyne.name = "HowToKyne"
HowToKyne.version = "1.1"

local sV
---------------------------
---- Variables Default ----
---------------------------
HowToKyne.Default = {
    OffsetX = {
        Fog = 0,
    },
    OffsetY = {
        Fog = 0,
    },
    Enable = {
        Chorus = true,
        Gargoyle = true,
        Fog = true,
        Prisoner = true,
        BloodCleave = true,
        BlockCast = true,
        Kite = true,
        TorturerLA = true,
    }
}

-------------------------
---- TRACK MECHANICS ----
-------------------------
local fogTime
local realFog
local increaseFog
function HowToKyne.FrigidFog(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
    if sV.Enable.Fog ~= true or result ~= ACTION_RESULT_BEGIN then return end

    fogTime = GetGameTimeMilliseconds() + hitValue
    realFog = true
    HowToKyne.FogTimerUI()
    Htk_Fog:SetHidden(false)
    PlaySound(SOUNDS.DUEL_START)
    PlaySound(SOUNDS.DUEL_START)
    PlaySound(SOUNDS.DUEL_START)
    PlaySound(SOUNDS.DUEL_START)
    PlaySound(SOUNDS.DUEL_START)

    EVENT_MANAGER:UnregisterForUpdate(HowToKyne.name .. "FogTimer")
    EVENT_MANAGER:RegisterForUpdate(HowToKyne.name .. "FogTimer", 100, HowToKyne.FogTimerUI)
end

function HowToKyne.IncreaseFogTimer(_, result, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId, _)
    if sV.Enable.Fog ~= true or result ~= ACTION_RESULT_BEGIN then return end

    increaseFog = increaseFog + 1
    if increaseFog == 3 then
        increaseFog = 0
        fogTime = fogTime + 9 * 1000
    end
end

function HowToKyne.FogTimerUI()
    local currentTime = GetGameTimeMilliseconds()
    local timer = (fogTime - currentTime) / 1000

    if timer >= 0 then 
        if realFog then
            Htk_Fog_Label:SetText("|c33ccffFOG:|r |cff0000" .. tostring(string.format("%.1f", timer)) .. "|r")
        else
            Htk_Fog_Label:SetText("|c33ccffFOG:|r " .. tostring(string.format("%.0f", timer)))
        end
    elseif realFog == false then
        Htk_Fog_Label:SetText("|c33ccffFOG:|r SOON")
    else
        EVENT_MANAGER:UnregisterForUpdate(HowToKyne.name .. "FogTimer")
        Htk_Fog:SetHidden(true)
    end
end

function HowToKyne.PrisonerDodge(_, result, _, _, _, _, sourceName, _, _, _, _, _, _, _, _, _, abilityId, _)
    if sV.Enable.Prisoner ~= true or result ~= ACTION_RESULT_BEGIN then return end

    local opt = {-3, 0, false, {0, 0, 0.7, 0.4}, {0, 0, 0.7, 0.8}}
    zo_callLater(function()
        CombatAlerts.AlertCast(abilityId, sourceName, 7500, opt)
        zo_callLater(function() PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED) end, 7500 - 300)
    end, 1000 * 25)
end

local cancelChorus
function HowToKyne.RerunChorus()
    if cancelChorus == false then
        d("Poison RerunChorus() : true")
    else
        d("Poison RerunChorus() : false")
    end

    local opt = {-3, 0, false, {0, 0.7, 0, 0.4}, {0, 0.7, 0, 0.8}}    
    CombatAlerts.AlertCast(133559, "Chorus Totem", 5500, opt)
    zo_callLater(function() PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED) end, 5500 - 300)
end

function HowToKyne.ChorusTotem(_, result, _, _, _, _, sourceName, _, _, _, _, _, _, _, _, _, abilityId, _)
    if sV.Enable.Chorus ~= true or result ~= ACTION_RESULT_BEGIN then return end

    local opt = {-3, 0, false, {0, 0.7, 0, 0.4}, {0, 0.7, 0, 0.8}}    
    CombatAlerts.AlertCast(133559, sourceName, 4500, opt)
    zo_callLater(function() PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED) end, 4500 - 300)
    cancelChorus = false

    EVENT_MANAGER:RegisterForUpdate(HowToKyne.name .. "RerunChorus", 30 * 1000, HowToKyne.RerunChorus)
end

function HowToKyne.CombatEventDied(_, result, _, _, _, _, sourceName, _, targetName, _, _, _, _, _, _, targetUnitId, _, _)
	if targetUnitId == nil or targetUnitId == 0 or (result ~= ACTION_RESULT_DIED and result ~= ACTION_RESULT_DIED_XP) then return end
    if string.find(string.lower(sourceName), "chaurus") or string.find(string.lower(targetName), "chaurus") or string.find(string.lower(sourceName), "chorus") or string.find(string.lower(targetName), "chorus") then
        cancelChorus = true
        d("Cancel RerunChorus()")
    end
end

function HowToKyne.GargoyleTotem(_, result, _, _, _, _, sourceName, _, _, _, hitValue, _, _, _, _, _, abilityId, _)
    if sV.Enable.Gargoyle ~= true or result ~= ACTION_RESULT_BEGIN then return end

    local opt = {-3, 0, false, {0.7, 0.7, 0.7, 0.4}, {0.7, 0.7, 0.7, 0.8}}
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, opt)
    zo_callLater(function() PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED) end, hitValue - 300)
end

function HowToKyne.BloodCleave(_, result, _, _, _, _, sourceName, _, _, _, hitValue, _, _, _, _, _, abilityId, _)
    if sV.Enable.BloodCleave ~= true or result ~= ACTION_RESULT_BEGIN then return end

    local opt = {-3, 0, false, {1, 0, 0.6, 0.4}, {1, 0, 0.6, 0.8}}
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, opt)
    zo_callLater(function() PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED) end, hitValue - 300)
end

function HowToKyne.BlockCast(_, result, _, _, _, _, sourceName, _, _, _, hitValue, _, _, _, _, _, abilityId, _)
    if sV.Enable.BlockCast ~= true or result ~= ACTION_RESULT_BEGIN then return end

    CombatAlerts.Alert(zo_strformat(SI_ABILITY_NAME,GetAbilityName(abilityId)), "Mini is jumping", 0xFF0000FF, 3000)
    PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
    CombatAlerts.CastAlertsStart(137499, "Bloody Frenzy", 6500, 6500, {1, 0.7, 0, 0.5}, {6500, "Block cast", 0.8, 0, 0, 0.9, nil})
end

function HowToKyne.SanguineGrasp(_, result, _, _, _, _, sourceName, _, _, _, hitValue, _, _, _, _, _, abilityId, _)
    if sV.Enable.Kite ~= true or result ~= ACTION_RESULT_BEGIN or hitValue < 4000 then return end
    
    CombatAlerts.Alert(zo_strformat(SI_ABILITY_NAME,GetAbilityName(abilityId)), "Start kiting", 0xFF0000FF, 3000)
    PlaySound(SOUNDS.DUEL_START)
    PlaySound(SOUNDS.DUEL_START)
    PlaySound(SOUNDS.DUEL_START)
    CombatAlerts.CastAlertsStart(136996, zo_strformat(SI_ABILITY_NAME,GetAbilityName(136996)), 8000, 8000, {1, 0.7, 0, 0.5}, {8000, "Kite now", 0.8, 0, 0, 0.9, nil})
end

function HowToKyne.QuickStrike(_, result, _, _, _, _, sourceName, _, _, targetType, hitValue, _, _, _, _, _, abilityId, _)
    if sV.Enable.TorturerLA ~= true or targetType ~= COMBAT_UNIT_TYPE_PLAYER or result ~= ACTION_RESULT_BEGIN or GetSelectedLFGRole() == LFG_ROLE_TANK then return end
    
    CombatAlerts.Alert("Torturer LAs", "DODGE !", 0xFF0000FF, 1000)
    PlaySound(SOUNDS.DUEL_START)
    PlaySound(SOUNDS.DUEL_START)
    PlaySound(SOUNDS.DUEL_START)
    PlaySound(SOUNDS.DUEL_START)
    PlaySound(SOUNDS.DUEL_START)
end

function HowToKyne.CombatState()
    if IsUnitInCombat("player") then
        if string.find(string.lower(GetUnitName("boss1")), "vrol") then
            fogTime = GetGameTimeMilliseconds() + 30 * 1000
            HowToKyne.FogTimerUI()
            Htk_Fog:SetHidden(false)

            EVENT_MANAGER:UnregisterForUpdate(HowToKyne.name .. "FogTimer")
            EVENT_MANAGER:RegisterForUpdate(HowToKyne.name .. "FogTimer", 1000, HowToKyne.FogTimerUI)
        elseif string.find(string.lower(GetUnitName("boss1")), "yandir") then 
            EVENT_MANAGER:RegisterForEvent(HowToKyne.name .. "CombatEventDied1", EVENT_COMBAT_EVENT, HowToKyne.CombatEventDied)
            EVENT_MANAGER:AddFilterForEvent(HowToKyne.name .. "CombatEventDied1", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_EVENT, ACTION_RESULT_DIED, REGISTER_FILTER_IS_ERROR, false)
    
            EVENT_MANAGER:RegisterForEvent(HowToKyne.name .. "CombatEventDied2", EVENT_COMBAT_EVENT, HowToKyne.CombatEventDied)
            EVENT_MANAGER:AddFilterForEvent(HowToKyne.name .. "CombatEventDied2", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_EVENT, ACTION_RESULT_DIED_XP, REGISTER_FILTER_IS_ERROR, false)
        end
    else
        HowToKyne.ResetAll()
    end
end

function HowToKyne.DeathJoke(_, unitTag, isDead)
    if isDead == true and GetUnitDisplayName(unitTag) == "@Freezedm" and GetUnitDisplayName("player") ~= "@Freezedm" then
        d("|cff00ffOh ti es fada ti es mort (on parle de freez) !|r")
    end
    if isDead == true and GetUnitDisplayName(unitTag) == "@onidalton" and GetUnitDisplayName("player") ~= "@onidalton" then
        d("|cff0000Le papy est mort (on parle d'oni) !|r")
    end
end

--------------
---- INIT ----
--------------
function HowToKyne.ResetAll()
    fogTime = 0
    realFog = false
    increaseFog = 0
    cancelChorus = true

    Htk_Fog:SetHidden(true)

    EVENT_MANAGER:UnregisterForUpdate(HowToKyne.name .. "FogTimer")
    EVENT_MANAGER:UnregisterForEvent(HowToKyne.name .. "CombatEventDied1", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(HowToKyne.name .. "CombatEventDied2", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForUpdate(HowToKyne.name .. "RerunChorus")
end

function HowToKyne.InitUI()
    --heavy attacks
    Htk_Fog:SetHidden(true)
	Htk_Fog:ClearAnchors()
    if (sV.OffsetX.Fog ~= HowToKyne.Default.OffsetX.Fog) and (sV.OffsetY.Fog ~= HowToKyne.Default.OffsetY.Fog) then 
        --recover last position
		Htk_Fog:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX.Fog, sV.OffsetY.Fog)
    else 
        --initial position (center)
		Htk_Fog:SetAnchor(CENTER, GuiRoot, CENTER, sV.OffsetX.Fog, sV.OffsetY.Fog)
    end

end

function HowToKyne.OnPlayerActivated()
    
    if GetZoneId(GetUnitZoneIndex("player")) == 1196 then --in Kyne Aegis
        for k, v in pairs(HowToKyne.AbilitiesToTrack) do --Register for abilities in the other lua file
            EVENT_MANAGER:RegisterForEvent(HowToKyne.name .. "Ability" .. k, EVENT_COMBAT_EVENT, v)
            EVENT_MANAGER:AddFilterForEvent(HowToKyne.name .. "Ability" .. k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
        end
        EVENT_MANAGER:RegisterForEvent(HowToKyne.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, HowToKyne.CombatState)

        EVENT_MANAGER:RegisterForEvent(HowToKyne.name .. "DeathJoke", EVENT_UNIT_DEATH_STATE_CHANGED, HowToKyne.DeathJoke)
    else
        for k, v in pairs(HowToKyne.AbilitiesToTrack) do --Unregister for all abilities
            EVENT_MANAGER:UnregisterForEvent(HowToKyne.name .. "Ability" .. k, EVENT_COMBAT_EVENT)
        end
        EVENT_MANAGER:UnregisterForEvent(HowToKyne.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE)
        
        EVENT_MANAGER:UnregisterForEvent(HowToKyne.name .. "DeathJoke", EVENT_UNIT_DEATH_STATE_CHANGED)
    end

end


function HowToKyne:Initialize()
	--Saved Variables
    HowToKyne.savedVariables = ZO_SavedVars:NewAccountWide("HowToKyneVariables", 1, nil, HowToKyne.Default)
    sV = HowToKyne.savedVariables
	--Settings
	HowToKyne.CreateSettingsWindow()
	--UI
    HowToKyne.InitUI()
    
    --Events
    EVENT_MANAGER:RegisterForEvent(HowToKyne.name .. "Activated", EVENT_PLAYER_ACTIVATED, HowToKyne.OnPlayerActivated)

	EVENT_MANAGER:UnregisterForEvent(HowToKyne.name, EVENT_ADD_ON_LOADED)
end

function HowToKyne.SaveLoc_Fog()
	sV.OffsetX.Fog = Htk_Fog:GetLeft()
	sV.OffsetY.Fog = Htk_Fog:GetTop()
end

function HowToKyne.OnAddOnLoaded(event, addonName)
	if addonName ~= HowToKyne.name then return end
        HowToKyne:Initialize()
end

EVENT_MANAGER:RegisterForEvent(HowToKyne.name, EVENT_ADD_ON_LOADED, HowToKyne.OnAddOnLoaded)