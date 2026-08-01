EldenRingUI = EldenRingUI or {}
local ERUI = EldenRingUI
ERUI.name = "EldenRingUI"
ERUI.dummyMode = false
ERUI.currentMutualMax = 0

local function FormatHealth(value)
    if value >= 1000000 then
        return string.format("%.1fm  ", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.0fk  ", value / 1000)
	elseif value == 0 then
        return string.format("0  ")	
    end
    return tostring(value)
end

local function IsBossInvulnerable(unitTag)
    if not DoesUnitExist(unitTag) then return false end
    
    local _, invulnMax = GetUnitAttributeVisualizerEffectInfo(
        unitTag, 
        ATTRIBUTE_VISUAL_UNWAVERING_POWER, 
        STAT_MITIGATION, 
        ATTRIBUTE_HEALTH, 
        COMBAT_MECHANIC_FLAGS_HEALTH
    )
   
    return invulnMax ~= nil
end

local RefreshBars

local function UpdateBarVisuals(index, powerValue, powerMax, isInvulnerable)
    local bar = ERUI_Container:GetNamedChild("Bar" .. index)
    if bar and powerMax > 0 then
        ZO_StatusBar_SmoothTransition(bar, powerValue, powerMax)
        
        local percent = math.floor(powerValue * 100 / powerMax)
        bar:GetNamedChild("Percent"):SetText(percent .. "%")
        bar:GetNamedChild("HealthValue"):SetText(FormatHealth(powerValue))
        
        if isInvulnerable then
            bar:SetColor(0.74, 0.73, 0.40, 1) 
        else
            bar:SetColor(0.63, 0.10, 0.05, 1) 
        end
        
        if powerValue <= 0 then
            RefreshBars()
        end
    end
end

local function GetMutualEncounterName()
    local bossNames = {}
    local seenNames = {}
    local totalUnits = 0
    local isReefGuardianEncounter = false

    for i = 1, 6 do
        if DoesUnitExist("boss" .. i) then
            local name = GetUnitName("boss" .. i)
            
            if name and name ~= "" and name ~= "Defense Prism" and not seenNames[name] then
                totalUnits = totalUnits + 1
                table.insert(bossNames, name)
                seenNames[name] = true

                if name == "Reef Guardian" then
                    isReefGuardianEncounter = true
                end
            end
        end
    end

    if isReefGuardianEncounter or totalUnits > 2 then 
        return table.concat(bossNames, ", ") 
    end
    
    return nil
end

local function OnPowerUpdate(_, unitTag, _, _, powerValue, powerMax)
    if GetMutualEncounterName() then
        RefreshBars()
        return
    end

    if unitTag:sub(1, 4) == "boss" then
        if GetUnitName(unitTag) == "Defense Prism" then return end
        
        local index = tonumber(unitTag:sub(5, 5))
        UpdateBarVisuals(index, powerValue, powerMax, IsBossInvulnerable(unitTag))
    elseif ERUI.dummyMode and unitTag == "reticleover" then
        if powerMax >= 20000000 then
            UpdateBarVisuals(1, powerValue, powerMax, IsBossInvulnerable("reticleover"))
        end
    end
end

local function GetOrCreateBar(index)
    local bar = ERUI_Container:GetNamedChild("Bar" .. index)
    if not bar then
        bar = CreateControlFromVirtual("$(parent)Bar" .. index, ERUI_Container, "ERUI_BarTemplate")
        bar:SetAnchor(BOTTOMLEFT, ERUI_Container, BOTTOMLEFT, 0, 0)
        bar:SetTexture("EldenRingUI/Textures/grainy.dds")
        
        local yellowLine = WINDOW_MANAGER:CreateControl(bar:GetName() .. "YellowLine", bar, CT_TEXTURE)
        yellowLine:SetTexture("EldenRingUI/Textures/lowline.dds") 
        yellowLine:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, 0)
        yellowLine:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, 0, 0)
        yellowLine:SetHeight(12)
        yellowLine:SetDrawLayer(DL_CONTROLS)
        yellowLine:SetDrawLevel(2)

        local currentHPIcon = bar:GetNamedChild("CurrentHPIcon")
        if currentHPIcon then
            bar:SetHandler("OnUpdate", function(self)
                local _, max = self:GetMinMax()
                if max and max > 0 then
                    local currentVisualValue = self:GetValue()
                    local percent = currentVisualValue / max
                    local barWidth = self:GetWidth()    
                    currentHPIcon:ClearAnchors()
                    currentHPIcon:SetAnchor(CENTER, self, LEFT, barWidth * percent - 15, -2)
                end
            end)
        end
    end
    return bar
end

RefreshBars = function()
    local mutualName = GetMutualEncounterName()
    
    if mutualName then
        local totalCur = 0
        local totalMax = 0
        local allInvulnerable = true
        local hasActiveBoss = false
        
        for i = 1, 6 do
            if DoesUnitExist("boss" .. i) and GetUnitName("boss" .. i) ~= "Defense Prism" then
                local cur, max = GetUnitPower("boss" .. i, COMBAT_MECHANIC_FLAGS_HEALTH)
                totalCur = totalCur + cur
                totalMax = totalMax + max
                hasActiveBoss = true
                
                if not IsBossInvulnerable("boss" .. i) then
                    allInvulnerable = false
                end
            end
        end
        if not hasActiveBoss then allInvulnerable = false end
        
        if totalMax > ERUI.currentMutualMax then
            ERUI.currentMutualMax = totalMax
        end

        local bar = GetOrCreateBar(1)
        bar:ClearAnchors()
        bar:SetAnchor(BOTTOMLEFT, ERUI_Container, BOTTOMLEFT, 0, 0)
        
        if totalCur > 0 then
            bar:SetHidden(false)
            bar:GetNamedChild("BossName"):SetText(mutualName)
            UpdateBarVisuals(1, totalCur, ERUI.currentMutualMax, allInvulnerable)
        else
            bar:SetHidden(true)
            ERUI.currentMutualMax = 0
        end
        
        for i = 2, 6 do
            local otherBar = ERUI_Container:GetNamedChild("Bar" .. i)
            if otherBar then otherBar:SetHidden(true) end
        end
    else
        ERUI.currentMutualMax = 0
	
        local visibleCount = 0
        for i = 1, 6 do
            local unitTag = "boss" .. i
            local bar = GetOrCreateBar(i)
            
            local isDummy = (i == 1 and ERUI.dummyMode and DoesUnitExist("reticleover"))
            local effectiveTag = isDummy and "reticleover" or unitTag

            local shouldShow = DoesUnitExist(effectiveTag)
            local curHealth, maxHealth = GetUnitPower(effectiveTag, COMBAT_MECHANIC_FLAGS_HEALTH)
            local bossName = GetUnitName(effectiveTag)

            if curHealth <= 1 or (isDummy and maxHealth < 20000000) or bossName == "Defense Prism" then
                shouldShow = false
            end

            if shouldShow then
                bar:ClearAnchors()
                bar:SetAnchor(BOTTOMLEFT, ERUI_Container, BOTTOMLEFT, 0, -(visibleCount * 40))
                visibleCount = visibleCount + 1
                
                bar:SetHidden(false)
                bar:GetNamedChild("BossName"):SetText(bossName)
                UpdateBarVisuals(i, curHealth, maxHealth, IsBossInvulnerable(effectiveTag))
            else
                bar:SetHidden(true)
            end
        end
    end
end

local function OnVisualChanged(_, unitTag, unitAttributeVisual)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER then
        RefreshBars()
    end
end

SLASH_COMMANDS["/dummyboss"] = function()
    ERUI.dummyMode = not ERUI.dummyMode
    local state = ERUI.dummyMode and "|c00FF00Enabled|r" or "|cFF0000Disabled|r"
    d("Elden Ring Boss Bar: Dummy Mode is now " .. state)
    
    if ERUI.dummyMode then
        EVENT_MANAGER:RegisterForEvent(ERUI.name .. "Reticle", EVENT_POWER_UPDATE, OnPowerUpdate)
        EVENT_MANAGER:AddFilterForEvent(ERUI.name .. "Reticle", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")
    else
        EVENT_MANAGER:UnregisterForEvent(ERUI.name .. "Reticle", EVENT_POWER_UPDATE)
    end
    
    RefreshBars()
end

local function OnAddOnLoaded(_, addonName)
    if addonName == ERUI.name then
        EVENT_MANAGER:UnregisterForEvent(ERUI.name, EVENT_ADD_ON_LOADED)
		
        local bossFragment = ZO_SimpleSceneFragment:New(ERUI_Container)
        HUD_SCENE:AddFragment(bossFragment)
        HUD_UI_SCENE:AddFragment(bossFragment)

		ZO_TargetUnitFramereticleover:SetHidden(true)
		ZO_PreHookHandler(ZO_TargetUnitFramereticleover, "OnShow", function() 
            ZO_TargetUnitFramereticleover:SetHidden(true)
            return true 
        end)
		
        EVENT_MANAGER:RegisterForEvent(ERUI.name .. "Reset", EVENT_PLAYER_ACTIVATED, function() RefreshBars() end)
		
		EVENT_MANAGER:RegisterForEvent(ERUI.name .. "Power", EVENT_POWER_UPDATE, OnPowerUpdate)
		EVENT_MANAGER:AddFilterForEvent(ERUI.name .. "Power", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss", REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
        
        EVENT_MANAGER:RegisterForEvent(ERUI.name .. "Bosses", EVENT_BOSSES_CHANGED, function() RefreshBars() end)
        
        EVENT_MANAGER:RegisterForEvent(ERUI.name .. "ReticleTarget", EVENT_RETICLE_TARGET_CHANGED, function() 
            if ERUI.dummyMode then RefreshBars() end
        end)

        EVENT_MANAGER:RegisterForEvent(ERUI.name .. "VisualAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnVisualChanged)
        EVENT_MANAGER:AddFilterForEvent(ERUI.name .. "VisualAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")

        EVENT_MANAGER:RegisterForEvent(ERUI.name .. "VisualRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnVisualChanged)
        EVENT_MANAGER:AddFilterForEvent(ERUI.name .. "VisualRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")

        EVENT_MANAGER:RegisterForEvent(ERUI.name .. "VisualUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnVisualChanged)
        EVENT_MANAGER:AddFilterForEvent(ERUI.name .. "VisualUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")

        RefreshBars()
    end
end

EVENT_MANAGER:RegisterForEvent(ERUI.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)