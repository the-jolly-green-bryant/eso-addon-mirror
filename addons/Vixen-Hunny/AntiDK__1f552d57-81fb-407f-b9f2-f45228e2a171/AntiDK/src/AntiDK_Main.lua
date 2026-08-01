AntiDK = AntiDK or {}
local EM = EVENT_MANAGER

function AntiDK:Initialize()
    AntiDK.settings = ZO_SavedVars:NewAccountWide("AntiDK_Settings", 3, nil, AntiDK.Defaults)
    if AntiDK.settings.autoHideDelay == nil or AntiDK.settings.autoHideDelay == 8 then
        AntiDK.settings.autoHideDelay = AntiDK.Defaults.autoHideDelay
    end
    AntiDK:CreateUI()
    AntiDK:CreateSettings()

    EM:RegisterForEvent("AntiDK_TargetablePlayers", EVENT_RETICLE_TARGET_CHANGED, function(_, unitTag)
        if AntiDK.RefreshObservedTargetablePlayers then
            AntiDK:RefreshObservedTargetablePlayers()
        elseif AntiDK.RememberTargetablePlayer then
            AntiDK:RememberTargetablePlayer(unitTag)
        end
    end)
    if AntiDK.RefreshObservedTargetablePlayers then
        AntiDK:RefreshObservedTargetablePlayers()
    elseif AntiDK.RememberTargetablePlayer then
        AntiDK:RememberTargetablePlayer("reticleover")
    end
    
    -- Register for combat events to track DK abilities
    EM:RegisterForEvent("AntiDK_Combat", EVENT_COMBAT_EVENT, function(event, result, isError, abilityName, abilityGraphic, 
        abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, 
        sourceCharacterName, targetCharacterName, abilityId) 
        local trackedSourceName = sourceName
        if AntiDK.ResolveCombatSourceName then
            trackedSourceName = AntiDK:ResolveCombatSourceName(sourceName, sourceCharacterName, sourceType)
        elseif not AntiDK.ShouldTrackCombatSource or not AntiDK:ShouldTrackCombatSource(sourceName, sourceCharacterName, sourceType) then
            trackedSourceName = nil
        end

        if not trackedSourceName or trackedSourceName == "" then
            return
        end
        
        if abilityId == 34117 then -- Power Lash
            AntiDK:TrackPowerLash(trackedSourceName, 1, 20)
        elseif abilityId == 29474 then -- Molten Whip
            AntiDK:TrackMoltenWhip(trackedSourceName, 1, 10)
        elseif abilityId == 32685 then -- Fossilize
            AntiDK:TrackFossilize(trackedSourceName, 1)
        elseif abilityId == 32678 then -- Shattering Rocks
            AntiDK:TrackShatteringRocks(trackedSourceName, 1)
        elseif abilityId == 17878 then -- Corrosive Armor
            -- Only track if it doesn't already exist (avoid multiple events)
            if not AntiDK.ActiveAbilities[trackedSourceName] or not AntiDK.ActiveAbilities[trackedSourceName].CorrosiveArmor then
                AntiDK:TrackCorrosiveArmor(trackedSourceName, 10)
            end
        end

        if (abilityId == 32678 or abilityId == 32685 or abilityId == 22633)
            and AntiDK.IsCurrentPlayerTarget
            and AntiDK:IsCurrentPlayerTarget(nil, targetName, targetCharacterName)
            and AntiDK.TrackPlayerDebuff then
            AntiDK:TrackPlayerDebuff(abilityId, trackedSourceName, 1)
        end
    end)
    
    -- Register for effect changes (for tracking active effects)
    EM:RegisterForEvent("AntiDK_Effects", EVENT_EFFECT_CHANGED, function(eventCode, changeType, effectSlot, 
        effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, 
        statusEffectType, unitName, unitId, abilityId, sourceType)
        if (abilityId == 32678 or abilityId == 32685 or abilityId == 22633)
            and AntiDK.IsCurrentPlayerTarget
            and AntiDK:IsCurrentPlayerTarget(unitTag, unitName, nil) then
            if changeType == EFFECT_RESULT_FADED or changeType == EFFECT_RESULT_REMOVED then
                if AntiDK.RemovePlayerDebuffById then
                    AntiDK:RemovePlayerDebuffById(abilityId)
                end
            elseif AntiDK.TrackPlayerDebuff then
                local debuffDuration = 1
                if type(beginTime) == "number" and type(endTime) == "number" then
                    debuffDuration = math.max(0.5, endTime - beginTime)
                end
                AntiDK:TrackPlayerDebuff(abilityId, nil, debuffDuration)
            end
        end

        if changeType == EFFECT_RESULT_FADED or changeType == EFFECT_RESULT_REMOVED then
            local trackedName = unitName
            local playerUnitTag = unitTag
            if AntiDK.ResolveEffectTarget then
                trackedName, playerUnitTag = AntiDK:ResolveEffectTarget(unitTag, unitName)
            elseif not trackedName or trackedName == "" then
                trackedName = GetUnitName(unitTag)
            end

            if trackedName and trackedName ~= "" and AntiDK.RemoveAbilityByEvent then
                AntiDK:RemoveAbilityByEvent(trackedName, abilityId, effectName, playerUnitTag)
            end
        end
    end)
    
    -- Register update timer for ability expiration (50ms for smooth real-time display)
    EM:RegisterForUpdate("AntiDK_Update", 50, function()
        AntiDK:UpdateUI()
    end)
    
    d("|cFFDD99AntiDK loaded|r - tracking DK abilities (Power Lash, Molten Whip, Shattering Rocks)")
end

function AntiDK:OnAddonLoaded(event, addonName)
    if addonName ~= "AntiDK" then return end
    EM:UnregisterForEvent("AntiDK", EVENT_ADD_ON_LOADED)
    AntiDK:Initialize()
end

function AntiDK:ClearTrackedData()
    AntiDK.ActiveAbilities = {}
    AntiDK.Players = {}
    AntiDK.TargetablePlayers = {}
    AntiDK.PlayerDebuffs = {}

    if AntiDK.UpdateUI then
        AntiDK:UpdateUI()
    end
end

function AntiDK:LoadEnemyTestData()
    AntiDK:TrackPowerLash("Enemy DK 1", 2, 8)
    AntiDK:TrackMoltenWhip("Enemy DK 1", 3, 15)
    AntiDK:TrackFossilize("Enemy DK 1", 1)

    AntiDK:TrackShatteringRocks("Enemy DK 2", 0)
    AntiDK:TrackCorrosiveArmor("Enemy DK 2", 20)
    AntiDK:TrackPowerLash("Enemy DK 2", 1, 8)

    AntiDK:TrackMoltenWhip("Enemy DK 3", 2, 15)
    AntiDK:TrackFossilize("Enemy DK 3", 1)
    AntiDK:TrackCorrosiveArmor("Enemy DK 3", 20)
end

function AntiDK:LoadPlayerDebuffTestData()
    if not AntiDK.TrackPlayerDebuff then
        return
    end

    local now = GetGameTimeSeconds()

    AntiDK:TrackPlayerDebuff(32678, "Enemy DK 2", 1.2)
    if AntiDK.PlayerDebuffs and AntiDK.PlayerDebuffs.ShatteringRocks then
        local shatteringDebuff = AntiDK.PlayerDebuffs.ShatteringRocks
        shatteringDebuff.sourceName = "Enemy DK 2"
        shatteringDebuff.applyTime = now - 0.65
        shatteringDebuff.rollReadyTime = now - 0.15
        shatteringDebuff.endTime = now + 0.55
        shatteringDebuff.duration = 1.2
    end

    AntiDK:TrackPlayerDebuff(32685, "Enemy DK 1", 1.1)
    if AntiDK.PlayerDebuffs and AntiDK.PlayerDebuffs.Fossilize then
        local fossilizeDebuff = AntiDK.PlayerDebuffs.Fossilize
        fossilizeDebuff.sourceName = "Enemy DK 1"
        fossilizeDebuff.applyTime = now - 0.20
        fossilizeDebuff.rollReadyTime = now + 0.30
        fossilizeDebuff.endTime = now + 0.90
        fossilizeDebuff.duration = 1.1
    end

    if AntiDK.UpdateUI then
        AntiDK:UpdateUI()
    end
end

function AntiDK:LoadAllTestData()
    AntiDK:ClearTrackedData()
    AntiDK:LoadEnemyTestData()
    AntiDK:LoadPlayerDebuffTestData()

    if AntiDK.UpdateUI then
        AntiDK:UpdateUI()
    end
end

-- Slash command handler
SLASH_COMMANDS["/antidk"] = function(args)
    args = args:lower():gsub("^%s+", ""):gsub("%s+$", "")
    
    if args == "" or args == "toggle" then
        if AntiDK.UIWindow then
            AntiDK.UIWindow:SetHidden(not AntiDK.UIWindow:IsHidden())
            d(AntiDK.UIWindow:IsHidden() and "|cFFDD99AntiDK hidden|r" or "|cFFDD99AntiDK shown|r")
        end
    elseif args == "clear" then
        AntiDK:ClearTrackedData()
        d("|cFFDD99AntiDK cleared all tracked data|r")
    elseif args == "reset" then
        if AntiDK.settings then
            AntiDK.settings.posX = AntiDK.Defaults.posX
            AntiDK.settings.posY = AntiDK.Defaults.posY
        end
        if AntiDK.CenterWindow then
            AntiDK.CenterWindow:ClearAnchors()
            AntiDK.CenterWindow:SetAnchor(CENTER, GuiRoot, CENTER, AntiDK.settings.posX, AntiDK.settings.posY)
            AntiDK.CenterWindow:SetHidden(false)
        elseif AntiDK.CreateUI then
            AntiDK:CreateUI()
        end
        d("|cFFDD99AntiDK window position reset|r")
    elseif args == "test" or args == "test all" then
        AntiDK:LoadAllTestData()
        d("|cFFDD99AntiDK test mode activated|r - enemy auras plus self debuff roll prompts loaded")
    elseif args == "testself" or args == "test self" then
        AntiDK:ClearTrackedData()
        AntiDK:LoadPlayerDebuffTestData()
        d("|cFFDD99AntiDK self test activated|r - Shattering Rocks and Fossilize loaded on you")
    elseif args == "testenemy" or args == "test enemy" then
        AntiDK:ClearTrackedData()
        AntiDK:LoadEnemyTestData()
        d("|cFFDD99AntiDK enemy test activated|r - enemy DK aura bars loaded")
    else
        d("|cFFDD99AntiDK v1.0 - DK Ability Tracker|r")
        d("  Drag UI with left mouse button")
        d("  /antidk toggle - Toggle UI visibility")
        d("  /antidk clear  - Clear all tracked abilities")
        d("  /antidk reset  - Reset window position")
        d("  /antidk test       - Load enemy plus self debuff test data")
        d("  /antidk test self  - Load only self debuff roll-prompt test data")
        d("  /antidk test enemy - Load only enemy DK aura test data")
    end
end

EM:RegisterForEvent("AntiDK", EVENT_ADD_ON_LOADED, function(...) AntiDK:OnAddonLoaded(...) end)