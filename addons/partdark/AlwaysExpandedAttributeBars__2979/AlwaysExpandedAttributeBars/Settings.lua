local AEAB = AEAB or {}
AEAB.name = "AlwaysExpandedAttributeBars"
AEAB.version = "2.6a u46"

-- Default settings with standard ESO colors
AEAB.defaults = {
    healthColor = {0.901, 0.196, 0.164, 1},     -- Standard ESO health red
    magickaColor = {0.176, 0.568, 0.929, 1},    -- Standard ESO magicka blue
    staminaColor = {0.513, 0.772, 0.254, 1},    -- Standard ESO stamina green
    shieldColor = {0.368, 0.439, 0.909, 1},     -- Standard ESO shield blue
    useCustomHealthColor = false,  -- Use custom color for health bar
    useCustomMagickaColor = false, -- Use custom color for magicka bar
    useCustomStaminaColor = false, -- Use custom color for stamina bar
    useCustomShieldColor = false,  -- Use custom color for shield
    
    -- Font settings
    fontFace = "$(MEDIUM_FONT)",   -- Default font face
    fontSize = 16,                 -- Default font size
    
    -- Visual effects settings
    disableMaxResourceChangeEffects = false  -- Disable visual effects when max resource changes
}



-- Initialize settings
function AEAB:Initialize()
    -- Load saved variables
    self.savedVars = ZO_SavedVars:NewAccountWide("AEABSavedVars", 1, nil, self.defaults)
    
    -- Apply settings on load
    self:ApplySettings()
    
    -- Create settings menu
    self:CreateSettingsMenu()
    
    -- Отключаем эффекты при изменении максимального ресурса
    -- Регистрируем событие для отключения эффектов после полной загрузки UI
    EVENT_MANAGER:RegisterForEvent(self.name.."_UILoaded", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            -- Проверяем настройки и отключаем эффекты если нужно
            if AEAB.savedVars and AEAB.savedVars.disableMaxResourceChangeEffects then
                AEAB.DisableResourceChangeEffects()
            end
        end, 1000)
    end)
end

-- Apply settings to attribute bars
function AEAB:ApplySettings()
    local fontString = self.savedVars.fontFace .. "|" .. self.savedVars.fontSize .. "|soft-shadow-thin"
    
    -- Apply settings to all attribute bars
    local function ApplyBarSettings(barControl, useCustomColor, colorTable, isHealth)
        if not barControl then return end
        
        -- Apply font
        local resourceNumbers = barControl:GetNamedChild("ResourceNumbers")
        if resourceNumbers then
            resourceNumbers:SetFont(fontString)
        end
        
        -- Apply color only if custom colors are enabled
        if useCustomColor then
            if isHealth then
                -- Health bar has two parts
                local barLeft = barControl:GetNamedChild("BarLeft")
                local barRight = barControl:GetNamedChild("BarRight")
                if barLeft and barRight then
                    barLeft:SetColor(unpack(colorTable))
                    barRight:SetColor(unpack(colorTable))
                end
            else
                -- Magicka and Stamina have single bar
                local bar = barControl:GetNamedChild("Bar")
                if bar then
                    bar:SetColor(unpack(colorTable))
                end
            end
        end
    end
    
    -- Apply settings to each bar
    ApplyBarSettings(ZO_PlayerAttributeHealth, self.savedVars.useCustomHealthColor, self.savedVars.healthColor, true)
    ApplyBarSettings(ZO_PlayerAttributeMagicka, self.savedVars.useCustomMagickaColor, self.savedVars.magickaColor, false)
    ApplyBarSettings(ZO_PlayerAttributeStamina, self.savedVars.useCustomStaminaColor, self.savedVars.staminaColor, false)
    
    -- Применяем отключение эффектов, если включено
    if self.savedVars.disableMaxResourceChangeEffects and AEAB.DisableResourceChangeEffects then
        AEAB.DisableResourceChangeEffects()
    end
end

-- Legacy function name for compatibility
function AEAB:ApplyColors()
    self:ApplySettings()
end

-- Create settings menu using LibAddonMenu-2.0
function AEAB:CreateSettingsMenu()
    -- Check if LibAddonMenu exists
    if not LibAddonMenu2 then return end
    
    local panelData = {
        type = "panel",
        name = "Always Expanded Attribute Bars",
        displayName = "Always Expanded Attribute Bars",
        author = "|cFF0000partdark|r, |c0099ffhex|r",
        version = self.version,
        slashCommand = "/aeab",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local optionsPanel = LibAddonMenu2:RegisterAddonPanel(self.name, panelData)
    
    local optionsData = {
        {
            type = "header",
            name = "Health Bar Colors",
        },
        {
            type = "checkbox",
            name = "Use Custom Health Color",
            tooltip = "When enabled, custom colors will be used for the health bar",
            getFunc = function() return self.savedVars.useCustomHealthColor end,
            setFunc = function(value) 
                self.savedVars.useCustomHealthColor = value
                -- Update color immediately
                local healthBar = ZO_PlayerAttributeHealth
                if healthBar then
                    local barLeft = healthBar:GetNamedChild("BarLeft")
                    local barRight = healthBar:GetNamedChild("BarRight")
                    if barLeft and barRight then
                        if value then
                            barLeft:SetColor(unpack(self.savedVars.healthColor))
                            barRight:SetColor(unpack(self.savedVars.healthColor))
                        end
                    end
                end
                self:ApplySettings()
            end,
            requiresReload = true,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Health Color",
            tooltip = "Set the color of the health bar",
            getFunc = function() return unpack(self.savedVars.healthColor) end,
            setFunc = function(r, g, b, a) 
                self.savedVars.healthColor = {r, g, b, a}
                self:ApplySettings()
            end,
            width = "full",
            disabled = function() return not self.savedVars.useCustomHealthColor end,
        },
        {
            type = "header",
            name = "Magicka Bar Colors",
        },
        {
            type = "checkbox",
            name = "Use Custom Magicka Color",
            tooltip = "When enabled, custom colors will be used for the magicka bar",
            getFunc = function() return self.savedVars.useCustomMagickaColor end,
            setFunc = function(value) 
                self.savedVars.useCustomMagickaColor = value
                -- Update color immediately
                local magickaBar = ZO_PlayerAttributeMagicka
                if magickaBar then
                    local bar = magickaBar:GetNamedChild("Bar")
                    if bar then
                        if value then
                            bar:SetColor(unpack(self.savedVars.magickaColor))
                        end
                    end
                end
                self:ApplySettings()
            end,
            requiresReload = true,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Magicka Color",
            tooltip = "Set the color of the magicka bar",
            getFunc = function() return unpack(self.savedVars.magickaColor) end,
            setFunc = function(r, g, b, a) 
                self.savedVars.magickaColor = {r, g, b, a}
                self:ApplySettings()
            end,
            width = "full",
            disabled = function() return not self.savedVars.useCustomMagickaColor end,
        },
        {
            type = "header",
            name = "Stamina Bar Colors",
        },
        {
            type = "checkbox",
            name = "Use Custom Stamina Color",
            tooltip = "When enabled, custom colors will be used for the stamina bar",
            getFunc = function() return self.savedVars.useCustomStaminaColor end,
            setFunc = function(value) 
                self.savedVars.useCustomStaminaColor = value
                -- Update color immediately
                local staminaBar = ZO_PlayerAttributeStamina
                if staminaBar then
                    local bar = staminaBar:GetNamedChild("Bar")
                    if bar then
                        if value then
                            bar:SetColor(unpack(self.savedVars.staminaColor))
                        end
                    end
                end
                self:ApplySettings()
            end,
            requiresReload = true,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Stamina Color",
            tooltip = "Set the color of the stamina bar",
            getFunc = function() return unpack(self.savedVars.staminaColor) end,
            setFunc = function(r, g, b, a) 
                self.savedVars.staminaColor = {r, g, b, a}
                self:ApplySettings()
            end,
            width = "full",
            disabled = function() return not self.savedVars.useCustomStaminaColor end,
        },
        {
            type = "header",
            name = "Shield Color",
        },
        {
            type = "checkbox",
            name = "Use Custom Shield Color",
            tooltip = "When enabled, custom color will be used for the shield overlay",
            getFunc = function() return self.savedVars.useCustomShieldColor end,
            setFunc = function(value) 
                self.savedVars.useCustomShieldColor = value
                self:ApplySettings()
            end,
            requiresReload = true,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Shield Color",
            tooltip = "Set the color of the shield overlay",
            getFunc = function() return unpack(self.savedVars.shieldColor) end,
            setFunc = function(r, g, b, a) 
                self.savedVars.shieldColor = {r, g, b, a}
                self:ApplySettings()
            end,
            width = "full",
            disabled = function() return not self.savedVars.useCustomShieldColor end,
        },
        {
            type = "header",
            name = "Font Settings",
        },
        {
            type = "dropdown",
            name = "Font Face",
            tooltip = "Select the font face for attribute bar numbers",
            choices = {"$(MEDIUM_FONT)", "$(BOLD_FONT)", "$(ANTIQUE_FONT)", "$(HANDWRITTEN_FONT)", "$(CHAT_FONT)"},
            getFunc = function() return self.savedVars.fontFace end,
            setFunc = function(value) 
                self.savedVars.fontFace = value
                self:ApplySettings()
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Font Size",
            tooltip = "Set the font size for attribute bar numbers",
            min = 10,
            max = 24,
            step = 1,
            getFunc = function() return self.savedVars.fontSize end,
            setFunc = function(value) 
                self.savedVars.fontSize = value
                self:ApplySettings()
            end,
            width = "full",
        },
        {
            type = "header",
            name = "Visual Effects",
        },
        {
            type = "checkbox",
            name = "Disable Max Resource Change Effects",
            tooltip = "When enabled, visual effects that appear when maximum resource values change will be disabled",
            getFunc = function() return self.savedVars.disableMaxResourceChangeEffects end,
            setFunc = function(value) 
                self.savedVars.disableMaxResourceChangeEffects = value
                self:ApplySettings()
            end,
            requiresReload = true,
            width = "full",
        },
        {
            type = "button",
            name = "Reset All Settings",
            tooltip = "Reset all settings to default",
            func = function()
                self.savedVars.healthColor = ZO_DeepTableCopy(self.defaults.healthColor)
                self.savedVars.magickaColor = ZO_DeepTableCopy(self.defaults.magickaColor)
                self.savedVars.staminaColor = ZO_DeepTableCopy(self.defaults.staminaColor)
                self.savedVars.shieldColor = ZO_DeepTableCopy(self.defaults.shieldColor)
                self.savedVars.useCustomHealthColor = false
                self.savedVars.useCustomMagickaColor = false
                self.savedVars.useCustomStaminaColor = false
                self.savedVars.useCustomShieldColor = false
                self.savedVars.fontFace = "$(MEDIUM_FONT)"
                self.savedVars.fontSize = 16
                self.savedVars.disableMaxResourceChangeEffects = false
                self:ApplySettings()
            end,
            requiresReload = true,
            width = "full",
        },
    }
    
    LibAddonMenu2:RegisterOptionControls(self.name, optionsData)
end

-- Initialize when addon loads
function AEAB.OnAddOnLoaded(event, addonName)
    if addonName ~= AEAB.name then return end
    EVENT_MANAGER:UnregisterForEvent(AEAB.name, EVENT_ADD_ON_LOADED)
    AEAB:Initialize()
end

EVENT_MANAGER:RegisterForEvent(AEAB.name, EVENT_ADD_ON_LOADED, AEAB.OnAddOnLoaded)

-- Make AEAB accessible globally
_G["AEAB"] = AEAB