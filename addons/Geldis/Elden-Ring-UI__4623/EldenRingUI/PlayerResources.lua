local PLAYER_RESOURCES = {
    [POWERTYPE_HEALTH] = { name = "Health", color = {0.63, 0.10, 0.05, 1}, width = 300 },
    [POWERTYPE_MAGICKA] = { name = "Magicka", color = {0.08, 0.61, 0.67, 1}, width = 300 },
    [POWERTYPE_STAMINA] = { name = "Stamina", color = {0.15, 0.47, 0.22, 1}, width = 300 },
}

local WIDTH_SCALE_FACTOR = 65 -- 55
local SHIELD_BAR_COLOR = {0.85, 0.32, 0.18, 0.85} 

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
        local calculatedShieldWidth = shieldMax / WIDTH_SCALE_FACTOR
        local finalShieldWidth = math.min(calculatedShieldWidth, healthBarWidth)
        
        shieldBar:SetWidth(finalShieldWidth)
        shieldBar:SetHidden(false)
        
        ZO_StatusBar_SmoothTransition(shieldBar, shieldValue, shieldMax)
    else
        shieldBar:SetHidden(true)
    end
end

local function UpdatePlayerPower(_, unitTag, _, powerType, powerValue, powerMax)
    if unitTag ~= "player" or not PLAYER_RESOURCES[powerType] then return end
    
    local bar = PlayerResourceContainer:GetNamedChild(PLAYER_RESOURCES[powerType].name)
    if bar and powerMax > 0 then
        local newWidth = powerMax / WIDTH_SCALE_FACTOR
        bar:SetWidth(newWidth)

        ZO_StatusBar_SmoothTransition(bar, powerValue, powerMax)
        bar:GetNamedChild("PercentLabel"):SetText(math.floor(powerValue * 100 / powerMax) .. "%")
        bar:GetNamedChild("ValueLabel"):SetText(FormatResource(powerValue))

        if powerType == POWERTYPE_HEALTH then
            UpdatePlayerShieldVisuals()
        end
    end
end

local function ApplyResourceStyle(bar)
    bar:SetTexture("EldenRingUI/Textures/grainy.dds")
    
    bar:SetDrawLayer(DL_CONTROLS)
    bar:SetDrawLevel(1)
    
    local yellowLine = WINDOW_MANAGER:CreateControl(bar:GetName() .. "YellowLine", bar, CT_TEXTURE)
    yellowLine:SetTexture("EldenRingUI/Textures/lowline.dds")
    yellowLine:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, 0)
    yellowLine:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, 0, 0)
    yellowLine:SetHeight(12)
    yellowLine:SetDrawLayer(DL_CONTROLS)
    yellowLine:SetDrawLevel(4) 
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
        
        bar:SetColor(unpack(data.color))
        bar:GetNamedChild("NameLabel"):SetText(data.name)
        ApplyResourceStyle(bar)

        local icon = bar:GetNamedChild("Icon")
        if icon then
            icon:SetDrawLayer(DL_CONTROLS)
            icon:SetDrawLevel(5)
        end

        local icon2 = bar:GetNamedChild("Icon2")
        if icon2 then
            icon2:SetDrawLayer(DL_CONTROLS)
            icon2:SetDrawLevel(5)
        end

		local currentValueIcon = bar:GetNamedChild("CurrentValueIcon")
        if currentValueIcon then
            currentValueIcon:SetDrawLayer(DL_CONTROLS)
            currentValueIcon:SetDrawLevel(6) 

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
                        currentValueIcon:SetAnchor(CENTER, self, LEFT, barWidth * percent - 15, -2)
                        
                        lastPercent = percent
                        lastWidth = barWidth
                    end
                end
            end)
        end
        if pType == POWERTYPE_HEALTH then
            local shieldBar = WINDOW_MANAGER:CreateControl("$(parent)ShieldOverlay", bar, CT_STATUSBAR)
            shieldBar:SetMinMax(0, 1)
            shieldBar:SetOrientation(ORIENTATION_HORIZONTAL)
            shieldBar:SetTexture("EldenRingUI/Textures/grainy.dds")
            shieldBar:SetColor(unpack(SHIELD_BAR_COLOR))
            
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