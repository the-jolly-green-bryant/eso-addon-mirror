--[[
    BlockPooky Stamina Low Warning - Stamina Depletion Alert
    
    Displays a fullscreen overlay warning when stamina drops below a configured threshold.
    Uses the staminawarn.dds texture as a visual indicator.
    Similar to stamina warnings in immersive overlays.
    
    Features:
    - Shows overlay when stamina < threshold (default 5000)
    - Configurable min/max opacity for the fade effect
    - Can be disabled entirely
--]]

--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky


--[[ Registration/Unregistration --------------------------------------------------------------------------------------]]

function BlockPooky.SetStaminaLowTexture()
    if BlockPookyStaminaLowOverlayTexture then
        -- Set dimensions to screen size
        local screenWidth, screenHeight = GuiRoot:GetDimensions()
        BlockPookyStaminaLowOverlay:SetDimensions(screenWidth, screenHeight)
        BlockPookyStaminaLowOverlayTexture:SetDimensions(screenWidth, screenHeight)
        
        -- Set texture from config
        local textureFile = BlockPooky.config.staminalow.texture or "staminawarn.dds"
        local texturePath = "BlockPooky/textures/" .. textureFile
        BlockPookyStaminaLowOverlayTexture:SetTexture(texturePath)
        
        -- Ensure overlay starts hidden
        BlockPookyStaminaLowOverlay:SetAlpha(0.0)
        BlockPookyStaminaLowOverlayTexture:SetAlpha(0.0)
    else
        d("ERROR: BlockPookyStaminaLowOverlayTexture not found!")
    end
end

function BlockPooky.RegisterStaminaLow()
    EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "StaminaLow", EVENT_POWER_UPDATE, function(...) BlockPooky.OnStaminaUpdate(...) end)
    EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "StaminaLow", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
end

function BlockPooky.UnRegisterStaminaLow()
    EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "StaminaLow", EVENT_POWER_UPDATE)
end

function BlockPooky.InitStaminaLow()
    if BlockPooky.config.staminalow.show then
        BlockPooky.RegisterStaminaLow()
    end
end

function BlockPooky.ResetStaminaLowDefaults()
    BlockPooky.config.staminalow.threshold = 5000
    BlockPooky.config.staminalow.minAlpha = 0.3
    BlockPooky.config.staminalow.maxAlpha = 0.72
    BlockPooky.config.staminalow.texture = "staminawarn.dds"
    BlockPooky.config.staminalow.show = false
    BlockPooky.UnRegisterStaminaLow()
    if BlockPookyStaminaLowOverlay then
        BlockPookyStaminaLowOverlay:SetAlpha(0.0)
        BlockPookyStaminaLowOverlayTexture:SetAlpha(0.0)
    end
    d("Stamina Low warning reset to defaults.")
end


--[[ event handling -------------------------------------------------------------------------------------------------]]

function BlockPooky.OnStaminaUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEType)
    -- Only process stamina updates for player
    if powerType ~= POWERTYPE_STAMINA or unitTag ~= "player" then
        return
    end
    
    -- Hide on death
    if IsUnitDeadOrReincarnating("player") then
        if BlockPookyStaminaLowOverlay then
            BlockPookyStaminaLowOverlay:SetAlpha(0.0)
            BlockPookyStaminaLowOverlayTexture:SetAlpha(0.0)
        end
        return
    end
    
    -- Get threshold and opacity bounds from config
    local threshold = BlockPooky.config.staminalow.threshold or 5000
    local minAlpha = BlockPooky.config.staminalow.minAlpha or 0.3
    local maxAlpha = BlockPooky.config.staminalow.maxAlpha or 0.72
    
    -- Calculate opacity: fade from minAlpha at threshold to maxAlpha at 0 stamina
    if powerValue <= threshold then
        local percentBelowThreshold = 1.0 - (powerValue / threshold)
        local alphaRange = maxAlpha - minAlpha
        local calculatedAlpha = minAlpha + (alphaRange * percentBelowThreshold)
        if BlockPookyStaminaLowOverlay then
            -- Ensure overlay has screen dimensions (resets after /reloadui)
            local width, height = BlockPookyStaminaLowOverlay:GetDimensions()
            if width == 0 or height == 0 then
                BlockPooky.SetStaminaLowTexture()
            end
            BlockPookyStaminaLowOverlay:SetAlpha(calculatedAlpha)
            BlockPookyStaminaLowOverlayTexture:SetAlpha(calculatedAlpha)
        end
    else
        if BlockPookyStaminaLowOverlay then
            BlockPookyStaminaLowOverlay:SetAlpha(0.0)
            BlockPookyStaminaLowOverlayTexture:SetAlpha(0.0)
        end
    end
end
