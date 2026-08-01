AutoRoll = AutoRoll or {}
AutoRoll.name = "AutoRoll"
AutoRoll.version = "1.0.0"
AutoRoll.settings = AutoRoll.settings or {}
AutoRoll.onCooldown = false
LAM = LibAddonMenu2 or {}
AutoRoll.defaults_DB = {
    enabled = true,
    primColor = "ffffff",
    secColor = "ffffff"
}
local function TriggerBlockAlert(abilityName, str, priority, ICON)
    -- 1. Play the Sound
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.STEALTH_DETECTED)
                params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
                params:SetText("|c"..AutoRoll.settings.primColor..str.."|r", "|c"..AutoRoll.settings.secColor.."Predicted: " .. abilityName.."|r")
                params:SetIconData(ICON, "/esoui/art/actionbar/passiveabilityframe_round_up.dds")
                params:GetShowImmediately()
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
                CENTER_SCREEN_ANNOUNCE:DisplayMessage(params)
end
function AutoRoll:CreateSettingsMenu() 
    if LAM == {} then
        return
    end
    local panelData = {
        type = "panel",
        name = "Bugfix",
        displayName = "|cff00ccBugfix|r",
        registerForRefresh = true,
        registerForDefaults = true,
        author = "?"
    }
    local optionsData = {
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return AutoRoll.settings.enabled end,
            setFunc = function(v) AutoRoll.settings.enabled = v end
        },
        {
            type = "editbox",
            name = "Primary Color",
            getFunc = function () return AutoRoll.settings.primColor end,
            setFunc = function(v) AutoRoll.settings.primColor = v end
        },
        {
            type = "editbox",
            name = "Secondary Color",
            getFunc = function() return AutoRoll.settings.secColor end,
            setFunc = function(v) AutoRoll.settings.secColor = v end
        }
    }
    LAM:RegisterAddonPanel(AutoRoll.name.."_AddonPanel", panelData)
    LAM:RegisterOptionControls(AutoRoll.name.."_AddonPanel", optionsData)


end
function AutoRoll:OnUpdate(displayName, effectName, endTime, str, priority, ICON)
    local seconds = GetGameTimeSeconds()
    local now = endTime - seconds
    if now <= 0 then
        EVENT_MANAGER:UnregisterForUpdate(effectName.."_"..AutoRoll.name)
        TriggerBlockAlert(effectName, displayName.." "..str, priority, ICON)
    end
end
function AutoRoll:OnEffectCalled()
    EVENT_MANAGER:UnregisterForUpdate(AutoRoll.name.."_Cooldown")
    AutoRoll.onCooldown = false
end
function AutoRoll:OnEffectChanged(ec, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, depBuffType, buffType, abilityType, unitName, unitId, abilityId, sourceType )
    if AutoRoll.settings.enabled then
        local display = GetUnitDisplayName(unitTag)
        local effect11
        --if unitTag == "reticleoverplayer" or unitTag == "reticleover" then
        --    local effect11 = effectName:sub(-11)
        --    d(string.format("UnitDisplay: %s UnitTag: %s Player: %s Attackable: %s Reaction: %s IsUnitPvPFlagged: %s effectName: %s Last11: %s", GetUnitDisplayName(unitTag), unitTag, tostring(IsUnitPlayer(unitTag)), tostring(IsUnitAttackable(unitTag)), tostring(GetUnitReaction(unitTag)), tostring(IsUnitPvPFlagged(unitTag)), effectName, effect11))
        --end
        if #effectName >= 11 then

            effect11 = effectName:sub(-11)
        else
            effect11 = effectName:sub(-1)
        end
        local units = unitTag:sub(5)
        local _buffType = GetAbilityBuffType(abilityId)
        local in_scope = false
        if effectName == "Incapacitating Strike" and changeType == EFFECT_RESULT_GAINED and unitTag == "player" and IsUnitPvPFlagged(unitTag) then
            EVENT_MANAGER:RegisterForUpdate(effectName.."_"..AutoRoll.name, 100, function ()
                AutoRoll:OnUpdate(display,effectName, endTime, " Burst faded!!", 0, iconName)
                
            end)
            in_scope = true
        elseif effectName == "Major Breach" and changeType == EFFECT_RESULT_GAINED and unitTag == "player" and IsUnitPvPFlagged(unitTag) then
            EVENT_MANAGER:RegisterForUpdate(effectName.."_"..AutoRoll.name, 100, function ()
                AutoRoll:OnUpdate(display,effectName, endTime, " Major Breach Gained!! Play Defensive!", 0, iconName)
                
            end)
            in_scope = true
        
        elseif _buffType == BUFF_TYPE_MAJOR_VULNERABILITY and changeType == EFFECT_RESULT_FADED and unitTag == "player" and IsUnitPvPFlagged(unitTag) then
            EVENT_MANAGER:RegisterForUpdate(effectName.."_"..AutoRoll.name, 100, function ()
                AutoRoll:OnUpdate(display,effectName, endTime, " Major Vulnerability faded!!", 0, iconName)
                
            end)
            in_scope = true
        elseif changeType == EFFECT_RESULT_GAINED and unitTag ~= "player" and AutoRoll.onCooldown == false and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and unitTag == "reticleover" and IsUnitPvPFlagged(unitTag) then
            if effect11 == "Contingency" and buffType == BUFF_EFFECT_TYPE_BUFF then
                AutoRoll.onCooldown = true
                TriggerBlockAlert(effectName, display.." Block now!!", 20 , iconName)
                in_scope = true
            end
        elseif changeType == EFFECT_RESULT_GAINED and unitTag ~= "player" and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and unitTag == "reticleover" and stackCount == 3 and IsUnitPvPFlagged(unitTag) then
            local null = effectName:sub(6)
            if null == "Sliver" then
                AutoRoll.onCooldown = true
                EVENT_MANAGER:RegisterForUpdate(AutoRoll.name.."_Cooldown", 3000, function() AutoRoll:OnEffectCalled() end)
                TriggerBlockAlert("Null Arca", display.." Null Arca ready! Roll soon!", 20, iconName)
                in_scope = true
            end
        elseif effectName == "Deep Fissure" and changeType == EFFECT_RESULT_GAINED and AutoRoll.onCooldown == false and unitTag == "reticleoverplayer" and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and IsUnitPvPFlagged(unitTag) then
            AutoRoll.onCooldown = true
            EVENT_MANAGER:UnregisterForUpdate(effectName.."_"..AutoRoll.name)
            EVENT_MANAGER:RegisterForUpdate(effectName.."_"..AutoRoll.name, 100, function ()
                AutoRoll:OnUpdate(display,effectName, endTime, " second beetles procced!", 20, iconName)
                
            end)
            in_scope = true
        elseif effectName == "Merciless Resolve" and changeType == EFFECT_RESULT_GAINED and AutoRoll.onCooldown == false and unitTag == "reticleoverplayer" and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and stackCount == 5 and IsUnitPvPFlagged(unitTag) then
            AutoRoll.onCooldown = true
            TriggerBlockAlert(effectName, display.." Merciless Resolve at 5 stacks!", 20, iconName)
            in_scope = true
        elseif effectName == "Merciless Resolve" and changeType == EFFECT_RESULT_GAINED and AutoRoll.onCooldown == false and unitTag == "reticleoverplayer" and IsUnitPlayer(unitTag) and IsUnitPvPFlagged(unitTag) and stackCount == 10  and IsUnitPvPFlagged(unitTag) then
            AutoRoll.onCooldown = true
            TriggerBlockAlert(effectName, display.. " Merciless Resolve at 10 stacks!", 20, iconName)
            in_scope = true
        elseif effectName == "Siphoning Attacks" and changeType == EFFECT_RESULT_GAINED and unitTag == "reticleoverplayer" and IsUnitPvPFlagged(unitTag) and IsUnitAttackable(unitTag) and IsUnitPvPFlagged(unitTag) then
            TriggerBlockAlert(effectName, display.." Regaining resources!", 20, iconName)
        elseif changeType == EFFECT_RESULT_GAINED and unitTag ~= "player" and AutoRoll.onCooldown == false and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and unitTag == "reticleoverplayer" and IsUnitPvPFlagged(unitTag) then
            if effect11 == "Contingency" and buffType == BUFF_EFFECT_TYPE_BUFF then
                AutoRoll.onCooldown = true
                TriggerBlockAlert(effectName, display.." Prepare Defense!!", 20, iconName)
                in_scope = true
            end
        elseif effectName == "Merciless Resolve" and changeType == EFFECT_RESULT_GAINED and AutoRoll.onCooldown == false and unitTag == "reticleover" and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and stackCount == 5 and IsUnitPvPFlagged(unitTag) then
            AutoRoll.onCooldown = true
            TriggerBlockAlert(effectName, display.." Merciless Resolve at 5 stacks!", 20, iconName)
            in_scope = true
        elseif effectName == "Merciless Resolve" and changeType == EFFECT_RESULT_GAINED and AutoRoll.onCooldown == false and unitTag == "reticleover" and IsUnitPlayer(unitTag) and IsUnitPvPFlagged(unitTag) and stackCount == 10 and IsUnitPvPFlagged(unitTag) then
            AutoRoll.onCooldown = true
            TriggerBlockAlert(effectName, display.. " Merciless Resolve at 10 stacks!", 20, iconName)
            in_scope = true
        elseif effectName == "Deep Fissure" and changeType == EFFECT_RESULT_FADED and unitTag == "reticleover" and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and IsUnitPvPFlagged(unitTag)  then
            AutoRoll.onCooldown = true
            EVENT_MANAGER:UnregisterForUpdate(effectName.."_"..AutoRoll.name)
            EVENT_MANAGER:RegisterForUpdate(effectName.."_"..AutoRoll.name, 100, function ()
                AutoRoll:OnUpdate(display,effectName, endTime, " second Beetles procced!", 20, iconName)
                
            end)
            in_scope = true
        
        elseif effectName == "Siphoning Attacks" and changeType == EFFECT_RESULT_GAINED and AutoRoll.onCooldown == false and unitTag == "reticleover" and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and IsUnitPvPFlagged(unitTag)  then
            AutoRoll.onCooldown = true
            TriggerBlockAlert(effectName, display.." Regaining resources!", 20, iconName)
            in_scope = true
        elseif effectName == "Major Resolve" and changeType == EFFECT_RESULT_GAINED and unitTag == "reticleoverplayer" and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and IsUnitPvPFlagged(unitTag) then
            local display = GetUnitDisplayName(unitTag)
            EVENT_MANAGER:UnregisterForUpdate(effectName.."_"..AutoRoll.name)
            EVENT_MANAGER:RegisterForUpdate(effectName.."_"..AutoRoll.name, 100, function ()
                AutoRoll:OnUpdate(display,effectName, endTime, " DOWN!! BURST NOW!", 20, iconName)
                
            end)
            in_scope = true
        elseif effectName == "Major Resolve" and changeType == EFFECT_RESULT_GAINED and unitTag == "reticleover" and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and IsUnitPvPFlagged(unitTag) then
            local display = GetUnitDisplayName(unitTag)
            EVENT_MANAGER:UnregisterForUpdate(effectName.."_"..AutoRoll.name)
            EVENT_MANAGER:RegisterForUpdate(effectName.."_"..AutoRoll.name, 100, function ()
                AutoRoll:OnUpdate(display,effectName, endTime, " DOWN!! BURST NOW!", 20, iconName)
                
            end)
            in_scope = true
        elseif effectName == "Major Brutality" and changeType == EFFECT_RESULT_GAINED and unitTag == "reticleoverplayer" and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and IsUnitPvPFlagged(unitTag) then
            local display = GetUnitDisplayName(unitTag)
            EVENT_MANAGER:UnregisterForUpdate(effectName.."_"..AutoRoll.name)
            EVENT_MANAGER:RegisterForUpdate(effectName.."_"..AutoRoll.name, 100, function ()
                AutoRoll:OnUpdate(display,effectName, endTime, " DOWN!! BURST NOW!", 20, iconName)
                
            end)
            in_scope = true
        elseif effectName == "Major Brutality" and changeType == EFFECT_RESULT_GAINED and unitTag == "reticleover" and IsUnitPlayer(unitTag) and IsUnitAttackable(unitTag) and IsUnitPvPFlagged(unitTag) then
            local display = GetUnitDisplayName(unitTag)
            EVENT_MANAGER:UnregisterForUpdate(effectName.."_"..AutoRoll.name)
            EVENT_MANAGER:RegisterForUpdate(effectName.."_"..AutoRoll.name, 100, function ()
                AutoRoll:OnUpdate(display,effectName, endTime, " DOWN!! BURST NOW!", 20, iconName)
                
            end)
            in_scope = true
        end
        if in_scope == true then
            EVENT_MANAGER:RegisterForUpdate(AutoRoll.name.."_Cooldown", 3000, function() AutoRoll:OnEffectCalled() end)
        end
    end
end
---------------------------------------------------------------------------------------------------------
function AutoRoll:GetCombatState(eventCode, isCombat)
    if isCombat ~= false and AutoRoll.settings.enabled then
        EVENT_MANAGER:RegisterForEvent(AutoRoll.name.."CombatEvent", EVENT_EFFECT_CHANGED, function (...)
            AutoRoll:OnEffectChanged(...)
            
        end)
    else
        EVENT_MANAGER:UnregisterForEvent(AutoRoll.name.."CombatEvent")
    end
end
function AutoRoll:Initialize()
    EVENT_MANAGER:UnregisterForEvent(AutoRoll.name.."AddonLoaded")
    local user = false
    for index, value in ipairs(AutoRoll.AUTH) do
        if GetDisplayName() == AutoRoll.AUTH[index] then
            user = true 
            break
        end
    end
    if user == false then
            return
        end
    d("User Allowed")
    AutoRoll.settings = ZO_SavedVars:New("AutoRollSettings", 1, nil, AutoRoll.defaults_DB)
    AutoRoll:CreateSettingsMenu()
    EVENT_MANAGER:RegisterForEvent(AutoRoll.name.."CombatState", EVENT_PLAYER_COMBAT_STATE, function(...) AutoRoll:GetCombatState(...) end)
end
function AutoRoll:AddonLoaded(eventCode, addonName) 
    if addonName == AutoRoll.name then
    AutoRoll:Initialize()
    end
end
EVENT_MANAGER:RegisterForEvent(AutoRoll.name.."AddonLoaded", EVENT_ADD_ON_LOADED, function(...) AutoRoll:AddonLoaded(...) end)