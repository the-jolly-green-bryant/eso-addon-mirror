local TauntIndicator = {}
TauntIndicator.name = "TauntIndicator"

TauntIndicator.TauntDebuffIDs = {
    [38254] = true, [38250] = true, [38256] = true, [38264] = true, 
    [42056] = true, [42049] = true, [42054] = true, [42058] = true, 
    [119541] = true, [119536] = true, 
}

TauntIndicator.activeTaunts = {}
TauntIndicator.dots = {}
TauntIndicator.maxDots = 10 
TauntIndicator.isTestMode = false

TauntIndicator.defaultSettings = {
    offsetX = 800,
    offsetY = 600
}

function TauntIndicator.InitializeUI()
    TauntIndicator.control = WINDOW_MANAGER:CreateTopLevelWindow("TauntIndicatorWindow")
    TauntIndicator.control:SetDimensions(32, 32) 
    TauntIndicator.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TauntIndicator.savedVars.offsetX, TauntIndicator.savedVars.offsetY)
    
    -- MAUS UND BEWEGEN BLEIBEN AKTIVIERT (kein Klickschutz)
    TauntIndicator.control:SetMouseEnabled(true)
    TauntIndicator.control:SetMovable(true)
    TauntIndicator.control:SetClampedToScreen(true)
    
    TauntIndicator.control:SetHandler("OnMoveStop", function(control)
        TauntIndicator.savedVars.offsetX = control:GetLeft()
        TauntIndicator.savedVars.offsetY = control:GetTop()
    end)
    
    TauntIndicator.control:SetDrawTier(DT_HIGH)
    TauntIndicator.control:SetDrawLayer(DL_OVERLAY)
    TauntIndicator.control:SetDrawLevel(5)

    TauntIndicator.bg = WINDOW_MANAGER:CreateControl("TauntIndicatorBg", TauntIndicator.control, CT_BACKDROP)
    TauntIndicator.bg:SetAnchorFill()
    TauntIndicator.bg:SetCenterColor(0, 0, 0, 0.6) 
    TauntIndicator.bg:SetEdgeColor(0, 0, 0, 0.9)
    TauntIndicator.bg:SetEdgeTexture("", 1, 1, 1)
    TauntIndicator.bg:SetDrawLevel(1) 
    TauntIndicator.bg:SetHidden(true) -- Standardmäßig unsichtbar im Ruhezustand

    for i = 1, TauntIndicator.maxDots do
        local dot = WINDOW_MANAGER:CreateControl("TauntIndicatorDot" .. i, TauntIndicator.control, CT_BACKDROP)
        dot:SetDimensions(16, 16) 
        dot:SetAnchor(LEFT, TauntIndicator.control, LEFT, 8 + (i - 1) * 24, 0)
        dot:SetCenterColor(1, 0.1, 0.1, 1) 
        dot:SetEdgeColor(0, 0, 0, 1) 
        dot:SetEdgeTexture("", 1, 1, 1)
        dot:SetDrawLevel(2)
        dot:SetHidden(true)
        
        TauntIndicator.dots[i] = dot
    end
    
    local fragment = ZO_HUDFadeSceneFragment:New(TauntIndicator.control)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
end

function TauntIndicator.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if TauntIndicator.isTestMode then return end 

    if result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        if sourceType == COMBAT_UNIT_TYPE_PLAYER and TauntIndicator.TauntDebuffIDs[abilityId] then
            TauntIndicator.activeTaunts[targetUnitId] = GetFrameTimeSeconds() + 15
            TauntIndicator.UpdateUI()
        end
    elseif result == ACTION_RESULT_EFFECT_FADED then
        if TauntIndicator.TauntDebuffIDs[abilityId] then
            if TauntIndicator.activeTaunts[targetUnitId] then
                TauntIndicator.activeTaunts[targetUnitId] = nil
                TauntIndicator.UpdateUI()
            end
        end
    elseif result == ACTION_RESULT_DIED then
        if TauntIndicator.activeTaunts[targetUnitId] then
            TauntIndicator.activeTaunts[targetUnitId] = nil
            TauntIndicator.UpdateUI()
        end
    end
end

function TauntIndicator.UpdateUI()
    local currentTime = GetFrameTimeSeconds()
    local sortedTaunts = {}

    for targetId, expireTime in pairs(TauntIndicator.activeTaunts) do
        if expireTime > currentTime then
            table.insert(sortedTaunts, {id = targetId, expireTime = expireTime})
        else
            TauntIndicator.activeTaunts[targetId] = nil
        end
    end

    table.sort(sortedTaunts, function(a, b) return a.expireTime < b.expireTime end)

    local count = #sortedTaunts
    if count > TauntIndicator.maxDots then count = TauntIndicator.maxDots end

    -- Komplett ausblenden, wenn niemand gespottet ist
    if count == 0 and not TauntIndicator.isTestMode then
        TauntIndicator.bg:SetHidden(true)
        -- Macht das unsichtbare Kästchen nicht-klickbar, damit es im normalen Spiel nicht stört
        TauntIndicator.control:SetMouseEnabled(false) 
    else
        TauntIndicator.bg:SetHidden(false)
        -- Sobald es sichtbar ist, kannst du es jederzeit wieder greifen
        TauntIndicator.control:SetMouseEnabled(true) 
    end

    local reticleExpireTime = nil
    if DoesUnitExist("reticleover") and not IsUnitPlayer("reticleover") then
        local numBuffs = GetNumBuffs("reticleover")
        for i = 1, numBuffs do
            local _, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("reticleover", i)
            if TauntIndicator.TauntDebuffIDs[abilityId] then
                reticleExpireTime = timeEnding
                break
            end
        end
    end

    local matchedIndex = -1
    if TauntIndicator.isTestMode and count >= 2 then
        matchedIndex = 2
    elseif reticleExpireTime then
        local smallestDiff = 999
        for i = 1, count do
            local diff = math.abs(sortedTaunts[i].expireTime - reticleExpireTime)
            if diff < 2.0 and diff < smallestDiff then 
                smallestDiff = diff
                matchedIndex = i
            end
        end
    end

    for i = 1, TauntIndicator.maxDots do
        local dot = TauntIndicator.dots[i]
        
        if i <= count then
            dot:SetHidden(false)
            
            local timeLeft = sortedTaunts[i].expireTime - currentTime
            
            -- DIE WARN-FARBE: Orange bei weniger als 3 Sekunden, sonst Rot
            if timeLeft <= 3.0 then
                dot:SetCenterColor(1, 0.5, 0, 1) -- Orange
            else
                dot:SetCenterColor(1, 0.1, 0.1, 1) -- Rot
            end
            
            -- DER STROKE-FOKUS FÜRS FADENKREUZ (weißer Rand)
            if i == matchedIndex then
                dot:SetEdgeColor(1, 1, 1, 1) 
                dot:SetDrawLevel(3)
            else
                dot:SetEdgeColor(0, 0, 0, 1) 
                dot:SetDrawLevel(2)
            end
        else
            dot:SetHidden(true)
        end
    end
    
    local newWidth = 32 
    if count > 0 then
        newWidth = 8 + (count * 24)
    end
    
    local left = TauntIndicator.control:GetLeft()
    local top = TauntIndicator.control:GetTop()
    TauntIndicator.control:ClearAnchors()
    TauntIndicator.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    TauntIndicator.control:SetDimensions(newWidth, 32)
end

function TauntIndicator.ToggleTestMode()
    TauntIndicator.isTestMode = not TauntIndicator.isTestMode
    
    if TauntIndicator.isTestMode then
        local t = GetFrameTimeSeconds()
        TauntIndicator.activeTaunts["test1"] = t + 2.5 -- Wird sofort orange
        TauntIndicator.activeTaunts["test2"] = t + 10  -- Weißer Rahmen (Scanner-Simulation)
        TauntIndicator.activeTaunts["test3"] = t + 15
        
        TauntIndicator.UpdateUI()
        d("Taunt Indicator: Testmodus AN. Leiste ist sichtbar und du kannst sie frei verschieben.")
    else
        TauntIndicator.activeTaunts["test1"] = nil
        TauntIndicator.activeTaunts["test2"] = nil
        TauntIndicator.activeTaunts["test3"] = nil
        
        TauntIndicator.UpdateUI()
        d("Taunt Indicator: Testmodus AUS. Leiste blendet sich aus, bis du spottest.")
    end
end

function TauntIndicator.OnAddOnLoaded(event, addonName)
    if addonName ~= TauntIndicator.name then return end
    EVENT_MANAGER:UnregisterForEvent(TauntIndicator.name, EVENT_ADD_ON_LOADED)

    TauntIndicator.savedVars = ZO_SavedVars:New("TauntIndicator_SavedVariables", 1, nil, TauntIndicator.defaultSettings)

    TauntIndicator.InitializeUI()

    EVENT_MANAGER:RegisterForEvent(TauntIndicator.name .. "Gained", EVENT_COMBAT_EVENT, TauntIndicator.OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(TauntIndicator.name .. "Gained", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    
    EVENT_MANAGER:RegisterForEvent(TauntIndicator.name .. "GainedDur", EVENT_COMBAT_EVENT, TauntIndicator.OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(TauntIndicator.name .. "GainedDur", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)

    EVENT_MANAGER:RegisterForEvent(TauntIndicator.name .. "Faded", EVENT_COMBAT_EVENT, TauntIndicator.OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(TauntIndicator.name .. "Faded", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)

    EVENT_MANAGER:RegisterForEvent(TauntIndicator.name .. "Died", EVENT_COMBAT_EVENT, TauntIndicator.OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(TauntIndicator.name .. "Died", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)

    EVENT_MANAGER:RegisterForUpdate(TauntIndicator.name .. "Update", 100, TauntIndicator.UpdateUI)
    EVENT_MANAGER:RegisterForEvent(TauntIndicator.name .. "Reticle", EVENT_RETICLE_TARGET_CHANGED, TauntIndicator.UpdateUI)
    
    SLASH_COMMANDS["/testtaunt"] = TauntIndicator.ToggleTestMode
end

EVENT_MANAGER:RegisterForEvent(TauntIndicator.name, EVENT_ADD_ON_LOADED, TauntIndicator.OnAddOnLoaded)