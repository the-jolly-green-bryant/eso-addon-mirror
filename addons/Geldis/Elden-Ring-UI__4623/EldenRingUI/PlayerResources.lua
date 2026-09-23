local PLAYER_RESOURCES = {
    [POWERTYPE_HEALTH]  = { name = "Health",  texture = "EldenRingUI/Textures/ERHealthBar.dds", width = 300, scaleFactor = 45 },
    [POWERTYPE_MAGICKA] = { name = "Magicka", texture = "EldenRingUI/Textures/ERMagickaBar.dds", width = 300, scaleFactor = 75 },
    [POWERTYPE_STAMINA] = { name = "Stamina", texture = "EldenRingUI/Textures/ERStaminaBar.dds", width = 300, scaleFactor = 75 },
}

local SHIELD_BAR_TEXTURE = "EldenRingUI/Textures/ERShieldBar.dds"

local function FormatResource(value)
    if value >= 1000000 then
        return string.format("%.1fm", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.0fk", value / 1000)
    end
    return tostring(value)
end

local function UpdatePlayerShieldVisuals()
    local healthBar = PlayerResourceContainer:GetNamedChild("Health")
    if not healthBar then return end

    local shieldBar = healthBar:GetNamedChild("ShieldOverlay")
    if not shieldBar then return end

    local shieldValue, shieldMax = GetUnitAttributeVisualizerEffectInfo(
        "player", 
        ATTRIBUTE_VISUAL_POWER_SHIELDING, 
        STAT_MITIGATION, 
        ATTRIBUTE_HEALTH, 
        COMBAT_MECHANIC_FLAGS_HEALTH
    )

    if shieldMax and shieldMax > 0 and shieldValue > 0 then
        local healthBarWidth = healthBar:GetWidth()
        local healthScaleFactor = PLAYER_RESOURCES[POWERTYPE_HEALTH].scaleFactor

        local currentShieldWidth = shieldValue / healthScaleFactor
        local finalShieldWidth = math.min(currentShieldWidth, healthBarWidth)
        
        shieldBar:SetWidth(finalShieldWidth)

        local shieldTexRight = finalShieldWidth / 2048
        shieldBar:SetTextureCoords(0, shieldTexRight, 0, 1)

        shieldBar:SetHidden(false)
    else
        shieldBar:SetHidden(true)
    end
end

local function UpdatePlayerPower(_, unitTag, _, powerType, powerValue, powerMax)
    local resourceData = PLAYER_RESOURCES[powerType]
    if unitTag ~= "player" or not resourceData then return end
    
    local bar = PlayerResourceContainer:GetNamedChild(resourceData.name)
    if bar and powerMax > 0 then
        
        local newWidth = powerMax / resourceData.scaleFactor
        
        if resourceData.lastMax ~= powerMax then
            bar:SetWidth(newWidth)
            local texRight = newWidth / 2048

            local yellowLine = bar:GetNamedChild("YellowLine")
            if yellowLine then yellowLine:SetTextureCoords(0, texRight, 0, 1) end

            local backdrop = bar:GetNamedChild("Backdrop")
            if backdrop then backdrop:SetTextureCoords(0, texRight, 0, 1) end
            
            resourceData.lastMax = powerMax
        end
		
        if not resourceData.lastValue then resourceData.lastValue = powerValue end
        
        local delayedBar = bar:GetNamedChild("DelayedBar")
        if delayedBar then
            if powerValue < resourceData.lastValue then
                local dropPercent = (resourceData.lastValue - powerValue) / powerMax
                
                if dropPercent >= 0.05 then
                    local barWidth = bar:GetWidth()
                    local delayWidth = (resourceData.lastValue / powerMax) * barWidth
                    delayedBar:SetWidth(delayWidth)
                    delayedBar:SetTextureCoords(0, delayWidth / 2048, 0, 1)
                    delayedBar:SetHidden(false)              
                    delayedBar:SetHandler("OnUpdate", nil)
                    delayedBar.lastTime = nil
                    
                    local timerName = "ERUI_Delay_" .. powerType
                    EVENT_MANAGER:UnregisterForUpdate(timerName)
                    EVENT_MANAGER:RegisterForUpdate(timerName, 1000, function()
                        EVENT_MANAGER:UnregisterForUpdate(timerName)
                        
                        delayedBar:SetHandler("OnUpdate", function(self, time)
                            local dt = self.lastTime and (time - self.lastTime) or 0
                            self.lastTime = time
                            if dt == 0 then return end
                            
                            local curVal = GetUnitPower("player", powerType)
                            local targetW = (curVal / resourceData.lastMax) * barWidth
                            local currentW = self:GetWidth()
                            local shrinkSpeed = 300 
                            local nextW = currentW - (shrinkSpeed * dt)
                            
                            if nextW <= targetW then
                                self:SetHidden(true)
                                self:SetHandler("OnUpdate", nil)
                                self.lastTime = nil
                            else
                                self:SetWidth(nextW)
                                self:SetTextureCoords(0, nextW / 2048, 0, 1)
                            end
                        end)
                    end)
                end
            end
        end

        resourceData.lastValue = powerValue

        ZO_StatusBar_SmoothTransition(bar, powerValue, powerMax)
        bar:GetNamedChild("PercentLabel"):SetText(math.floor(powerValue * 100 / powerMax) .. "%")
        bar:GetNamedChild("ValueLabel"):SetText(FormatResource(powerValue))

        if powerType == POWERTYPE_HEALTH then
            UpdatePlayerShieldVisuals()
        end
    end
end

local function ApplyResourceStyle(bar)
    bar:SetDrawTier(DT_MEDIUM)
    bar:SetDrawLayer(DL_CONTROLS)
    local backdrop = bar:GetNamedChild("Backdrop")
    if backdrop then
        backdrop:SetDrawTier(DT_LOW)
        backdrop:SetDrawLayer(DL_BACKGROUND)
        backdrop:SetDrawLevel(0)
    end
    
    local delayedBar = WINDOW_MANAGER:CreateControl(bar:GetName() .. "DelayedBar", bar, CT_TEXTURE)
    delayedBar:SetTexture("EldenRingUI/Textures/DelayedBar.dds") 
    delayedBar:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
    delayedBar:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, 0)
    delayedBar:SetDrawTier(DT_LOW)
    delayedBar:SetDrawLayer(DL_BACKGROUND)
    delayedBar:SetDrawLevel(1) 
    delayedBar:SetHidden(true)

    local yellowLine = WINDOW_MANAGER:CreateControl(bar:GetName() .. "YellowLine", bar, CT_TEXTURE)
    yellowLine:SetTexture("EldenRingUI/Textures/lowline.dds")
    yellowLine:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, 0)
    yellowLine:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, 0, 0)
    yellowLine:SetHeight(12)
    yellowLine:SetDrawTier(DT_MEDIUM)
    yellowLine:SetDrawLayer(DL_CONTROLS)
    yellowLine:SetDrawLevel(3) 
end

local function OnPlayerVisualChanged(_, unitTag, unitAttributeVisual)
    if unitTag == "player" and unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        UpdatePlayerShieldVisuals()
    end
end

local function InitializePlayerModule()
    ZO_PlayerAttributeHealth:SetHidden(true)
    ZO_PlayerAttributeMagicka:SetHidden(true)
    ZO_PlayerAttributeStamina:SetHidden(true)

    local playerFragment = ZO_SimpleSceneFragment:New(PlayerResourceContainer)
    HUD_SCENE:AddFragment(playerFragment)
    HUD_UI_SCENE:AddFragment(playerFragment)

    for pType, data in pairs(PLAYER_RESOURCES) do
        local bar = CreateControlFromVirtual("$(parent)" .. data.name, PlayerResourceContainer, "ERUI_PlayerBarTemplate")
        
        local yOffset = (pType == POWERTYPE_HEALTH) and 0 or (pType == POWERTYPE_MAGICKA and 18 or 36)
        bar:SetAnchor(TOPLEFT, PlayerResourceContainer, TOPLEFT, 0, yOffset)
        
        bar:SetTexture(data.texture)
        bar:GetNamedChild("NameLabel"):SetText(data.name)
        ApplyResourceStyle(bar)

        local icon = bar:GetNamedChild("Icon")
        if icon then
            icon:SetDrawLayer(DL_CONTROLS)
            icon:SetDrawLevel(4)
        end

        -- local icon2 = bar:GetNamedChild("Icon2")
        -- if icon2 then
            -- icon2:SetDrawLayer(DL_CONTROLS)
            -- icon2:SetDrawLevel(4)
        -- end

        local currentValueIcon = bar:GetNamedChild("CurrentValueIcon")
        if currentValueIcon then
            currentValueIcon:SetDrawLayer(DL_CONTROLS)
            currentValueIcon:SetDrawLevel(2) 

            local lastPercent = -1 
            local lastWidth = -1 
            
            bar:SetHandler("OnUpdate", function(self)
                local _, max = self:GetMinMax()
                if max and max > 0 then
                    local currentVisualValue = self:GetValue()
                    local percent = currentVisualValue / max
                    local barWidth = self:GetWidth()    
                    
                    if percent ~= lastPercent or barWidth ~= lastWidth then
                        currentValueIcon:ClearAnchors()
                        currentValueIcon:SetAnchor(CENTER, self, LEFT, barWidth * percent - 13, -1)
                        
                        lastPercent = percent
                        lastWidth = barWidth
                    end
                end
            end)
        end
        if pType == POWERTYPE_HEALTH then
			local shieldBar = WINDOW_MANAGER:CreateControl("$(parent)ShieldOverlay", bar, CT_TEXTURE)
			
			shieldBar:SetTexture(SHIELD_BAR_TEXTURE)
			
			shieldBar:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
			shieldBar:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, 0)
			shieldBar:SetDrawLayer(DL_CONTROLS)
			shieldBar:SetDrawLevel(2) 
			
			shieldBar:SetHidden(true)
		end

        local cur, max = GetUnitPower("player", pType)
        UpdatePlayerPower(nil, "player", nil, pType, cur, max)
    end

    EVENT_MANAGER:RegisterForEvent("ERUI_PlayerResources", EVENT_POWER_UPDATE, UpdatePlayerPower)
    EVENT_MANAGER:AddFilterForEvent("ERUI_PlayerResources", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent("ERUI_ShieldAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnPlayerVisualChanged)
    EVENT_MANAGER:AddFilterForEvent("ERUI_ShieldAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent("ERUI_ShieldRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnPlayerVisualChanged)
    EVENT_MANAGER:AddFilterForEvent("ERUI_ShieldRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent("ERUI_ShieldUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnPlayerVisualChanged)
    EVENT_MANAGER:AddFilterForEvent("ERUI_ShieldUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, "player")

    UpdatePlayerShieldVisuals()
end

EVENT_MANAGER:RegisterForEvent("ERUI_PlayerInit", EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == "EldenRingUI" then
        EVENT_MANAGER:UnregisterForEvent("ERUI_PlayerInit", EVENT_ADD_ON_LOADED)
        InitializePlayerModule()
    end
end)