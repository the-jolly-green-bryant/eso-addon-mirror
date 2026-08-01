-- ============================================================================
-- AKsAttributeBars - Settings Menu Module
-- ============================================================================
-- Creates and manages the LibAddonMenu2 settings panel

local AKB = AKsAttributeBars

-- Create menu namespace
AKB.Menu = AKB.Menu or {}

-- Initialize settings menu
function AKB.Menu.Initialize()
    -- Only create settings menu if LibAddonMenu2 is available
    if not LibAddonMenu2 then 
        return 
    end
    
    AKB.Menu.CreateSettingsPanel()
end

-- Create the settings panel
function AKB.Menu.CreateSettingsPanel()
    -- Panel data
    local panelData = {
        type = "panel",
        name = "AKsAttributeBars",
        displayName = "AKs Attribute Bars",
        author = "AKs",
        version = AKB.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    -- Register the panel
    LibAddonMenu2:RegisterAddonPanel("AKsAttributeBarsPanel", panelData)
    
    -- Options data
    local optionsData = AKB.Menu.CreateOptionsData()
    
    -- Register the options
    LibAddonMenu2:RegisterOptionControls("AKsAttributeBarsPanel", optionsData)
end

-- Create the options data structure
function AKB.Menu.CreateOptionsData()
    return {
        {
            type = "checkbox",
            name = "Show Alignment Gridlines",
            tooltip = "Show alignment gridlines to help position UI elements precisely. Useful for arranging custom bars and other addons.",
            getFunc = function() return AKB.Settings.Get("showGridlines") end,
            setFunc = function(value) 
                AKB.Settings.Save("showGridlines", value)
                
                if AKB.Gridlines then
                    if value then
                        if AKB.Gridlines.Show then 
                            AKB.Gridlines.Show() 
                        end
                    else
                        if AKB.Gridlines.Hide then 
                            AKB.Gridlines.Hide() 
                        end
                    end
                end
            end,
            width = "full",
            default = false,
        },
        {
            type = "divider",
        },
        {
            type = "checkbox",
            name = "Show Custom Attribute Bars",
            tooltip = "Show or hide the custom attribute bars. When enabled, default ESO attribute bars will be hidden automatically.",
            getFunc = function() return AKB.Settings.Get("showBars") end,
            setFunc = function(value) 
                AKB.Settings.Save("showBars", value)
                if value then
                    AKB.UI.CreatePlayerAttributeBars()
                    AKB.Events.RegisterAttributeEvents()
                    AKB.DefaultBars.SetVisibility(false)
                else
                    AKB.UI.DestroyPlayerAttributeBars()
                    AKB.DefaultBars.SetVisibility(true)
                end
            end,
            width = "full",
            default = false,
        },
        {
            type = "divider",
        },
        {
            type = "header",
            name = "Default Attribute Bar Settings",
        },
        {
            type = "slider",
            name = "Default Attribute Bars Y Position",
            tooltip = "Adjust the vertical position of the default ESO attribute bars. Positive values move bars up, negative values move bars down.",
            min = -1000,
            max = 1000,
            step = 1,
            getFunc = function() return AKB.Settings.Get("defaultBarsYPosition") end,
            setFunc = function(value) 
                AKB.Settings.Save("defaultBarsYPosition", value)
                AKB.DefaultBars.ApplyPositioning()
            end,
            width = "full",
            default = 0,
        },
        {
            type = "slider", 
            name = "Default Attribute Bars Proximity",
            tooltip = "Control the horizontal spacing between attribute bars. Negative values spread magicka (left) and stamina (right) bars away from health bar. Positive values bring them closer to the center.",
            min = -250,
            max = 250,
            step = 2,
            getFunc = function() return AKB.Settings.Get("defaultBarsProximity") end,
            setFunc = function(value) 
                AKB.Settings.Save("defaultBarsProximity", value)
                AKB.DefaultBars.ApplyPositioning()
            end,
            width = "full",
            default = 0,
        },
        {
            type = "divider",
        },
        {
            type = "header",
            name = "Custom Attribute Bar Settings",
        },
        {
            type = "dropdown",
            name = "Custom Bar Layout",
            tooltip = "Choose the arrangement of custom attribute bars. Stacked places all bars vertically. Pyramid places Health at top with Magicka and Stamina below in a triangular pattern.",
            choices = {"Stacked", "Pyramid"},
            getFunc = function() 
                local layout = AKB.Settings.Get("customBarLayout")
                return layout == 2 and "Pyramid" or "Stacked"
            end,
            setFunc = function(value) 
                local layoutValue = value == "Pyramid" and 2 or 1
                AKB.Settings.Save("customBarLayout", layoutValue)
                if AKB.Settings.Get("showBars") then
                    AKB.UI.CreatePlayerAttributeBars()
                end
            end,
            width = "full",
            default = "Stacked",
        },
        {
            type = "dropdown",
            name = "Custom Bar Type",
            tooltip = "Choose the style of custom attribute bars. Expanded shows text above bars. Compact shows text overlaid on bars for a smaller profile.",
            choices = {"Expanded", "Compact"},
            getFunc = function() 
                local barType = AKB.Settings.Get("customBarType")
                return barType == 2 and "Compact" or "Expanded"
            end,
            setFunc = function(value) 
                local typeValue = value == "Compact" and 2 or 1
                AKB.Settings.Save("customBarType", typeValue)
                if AKB.Settings.Get("showBars") then
                    AKB.UI.CreatePlayerAttributeBars()
                end
            end,
            width = "full",
            default = "Expanded",
        },
        {
            type = "slider",
            name = "Custom Bars X Position",
            tooltip = "Horizontal position of custom attribute bars on screen.",
            min = -1000,
            max = 2000,
            step = 10,
            getFunc = function() return AKB.Settings.Get("customBarsXPosition") end,
            setFunc = function(value) 
                AKB.Settings.Save("customBarsXPosition", value)
                if AKB.Settings.Get("showBars") then
                    AKB.UI.CreatePlayerAttributeBars()
                end
            end,
            width = "full",
            default = 600,
        },
        {
            type = "slider",
            name = "Custom Bars Y Position", 
            tooltip = "Vertical position of custom attribute bars on screen.",
            min = -1000,
            max = 1200,
            step = 10,
            getFunc = function() return AKB.Settings.Get("customBarsYPosition") end,
            setFunc = function(value) 
                AKB.Settings.Save("customBarsYPosition", value)
                if AKB.Settings.Get("showBars") then
                    AKB.UI.CreatePlayerAttributeBars()
                end
            end,
            width = "full",
            default = 450,
        },
        {
            type = "checkbox",
            name = "Auto-Hide When Full and Out of Combat",
            tooltip = "Hide custom bars when all attributes are at full and you are not in combat. Bars will reappear when attributes drop or combat starts.",
            getFunc = function() return AKB.Settings.Get("hideWhenFullAndOutOfCombat") end,
            setFunc = function(value) 
                AKB.Settings.Save("hideWhenFullAndOutOfCombat", value)
                -- Force update visibility
                if AKB.Settings.Get("showBars") then
                    AKB.UI.UpdateBarVisibility()
                end
            end,
            width = "full",
            default = false,
        },
        {
            type = "checkbox",
            name = "Show Player Name",
            tooltip = "Display the player name above the attribute bars.",
            getFunc = function() return AKB.Settings.Get("showPlayerName") end,
            setFunc = function(value) 
                AKB.Settings.Save("showPlayerName", value)
                if AKB.Settings.Get("showBars") then
                    AKB.UI.CreatePlayerAttributeBars()
                end
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = "Show Player Level",
            tooltip = "Display the player level and champion points (if applicable) next to the player name.",
            getFunc = function() return AKB.Settings.Get("showPlayerLevel") end,
            setFunc = function(value) 
                AKB.Settings.Save("showPlayerLevel", value)
                if AKB.Settings.Get("showBars") then
                    AKB.UI.CreatePlayerAttributeBars()
                end
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = "Show Class Icon",
            tooltip = "Display the class icon next to the player name.",
            getFunc = function() return AKB.Settings.Get("showClassIcon") end,
            setFunc = function(value) 
                AKB.Settings.Save("showClassIcon", value)
                if AKB.Settings.Get("showBars") then
                    AKB.UI.CreatePlayerAttributeBars()
                end
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = "Food/Drink Buff Reminder",
            tooltip = "Show a small bread icon next to the bars when you have no active food or drink buff.",
            getFunc = function() return AKB.Settings.Get("showFoodDrinkReminder") end,
            setFunc = function(value)
                AKB.Settings.Save("showFoodDrinkReminder", value)
                -- Recreate/Destroy the indicator depending on state
                if value then
                    if AKB.Settings.Get("showBars") and AKB.FoodIndicator and AKB.FoodIndicator.CreateFoodIndicator then
                        AKB.FoodIndicator.CreateFoodIndicator(true)
                    end
                else
                    if AKB.FoodIndicator and AKB.FoodIndicator.DestroyFoodIndicator then
                        AKB.FoodIndicator.DestroyFoodIndicator()
                    end
                end
            end,
            width = "full",
            default = true,
        },
        {
            type = "divider",
        },
        {
            type = "header",
            name = "Player Bars Text Settings",
        },
        {
            type = "dropdown",
            name = "Number Format",
            tooltip = "Choose how numbers are displayed on the bars.",
            choices = {"Full (10,000)", "Short (10k)", "Decimal (10.5k)"},
            getFunc = function() 
                local format = AKB.Settings.Get("textFormatType")
                if format == 2 then return "Short (10k)"
                elseif format == 3 then return "Decimal (10.5k)"
                else return "Full (10,000)" end
            end,
            setFunc = function(value) 
                local formatValue = 1
                if value == "Short (10k)" then formatValue = 2
                elseif value == "Decimal (10.5k)" then formatValue = 3 end
                AKB.Settings.Save("textFormatType", formatValue)
                AKB.UI.UpdateAllBars()
            end,
            width = "full",
            default = "Full (10,000)",
        },
        {
            type = "checkbox",
            name = "Hide Percentage",
            tooltip = "Hide the percentage display on attribute bars.",
            getFunc = function() return AKB.Settings.Get("hidePercentage") end,
            setFunc = function(value) 
                AKB.Settings.Save("hidePercentage", value)
                AKB.UI.UpdateAllBars()
            end,
            width = "full",
            default = false,
        },
        {
            type = "colorpicker",
            name = "Text Color",
            tooltip = "Color for all text on the attribute bars.",
            getFunc = function() 
                local color = AKB.Settings.Get("textColor")
                return color.r, color.g, color.b, 1
            end,
            setFunc = function(r, g, b, a) 
                AKB.Settings.Save("textColor", {r = r, g = g, b = b})
                AKB.UI.UpdateAllBars()
            end,
            width = "full",
            default = {r = 1, g = 1, b = 1},
        },
        {
            type = "divider",
        },
        {
            type = "header",
            name = "Bar Colors",
        },
        {
            type = "colorpicker",
            name = "Health Bar Color",
            tooltip = "Color for the health attribute bar.",
            getFunc = function() 
                local color = AKB.Settings.Get("healthBarColor")
                return color.r, color.g, color.b, 1
            end,
            setFunc = function(r, g, b, a) 
                AKB.Settings.Save("healthBarColor", {r = r, g = g, b = b})
                AKB.UI.UpdateBarColors()
            end,
            width = "full",
            default = {r = 1, g = 0, b = 0},
        },
        {
            type = "colorpicker",
            name = "Magicka Bar Color",
            tooltip = "Color for the magicka attribute bar.",
            getFunc = function() 
                local color = AKB.Settings.Get("magickaBarColor")
                return color.r, color.g, color.b, 1
            end,
            setFunc = function(r, g, b, a) 
                AKB.Settings.Save("magickaBarColor", {r = r, g = g, b = b})
                AKB.UI.UpdateBarColors()
            end,
            width = "full",
            default = {r = 0, g = 0, b = 1},
        },
        {
            type = "colorpicker",
            name = "Stamina Bar Color",
            tooltip = "Color for the stamina attribute bar.",
            getFunc = function() 
                local color = AKB.Settings.Get("staminaBarColor")
                return color.r, color.g, color.b, 1
            end,
            setFunc = function(r, g, b, a) 
                AKB.Settings.Save("staminaBarColor", {r = r, g = g, b = b})
                AKB.UI.UpdateBarColors()
            end,
            width = "full",
            default = {r = 0, g = 1, b = 0},
        },
        {
            type = "checkbox",
            name = "Show Mount Stamina Bar",
            tooltip = "Show a thinner mount stamina bar below the stamina bar when custom bars are enabled.",
            getFunc = function() return AKB.Settings.Get("showMountStamina") end,
            setFunc = function(value) 
                AKB.Settings.Save("showMountStamina", value)
                if AKB.Settings.Get("showBars") then
                    AKB.UI.CreatePlayerAttributeBars()
                end
            end,
            width = "full",
            default = true,
        },
        {
            type = "colorpicker",
            name = "Mount Stamina Bar Color",
            tooltip = "Color for the mount stamina bar.",
            getFunc = function() 
                local color = AKB.Settings.Get("mountStaminaBarColor")
                return color.r, color.g, color.b, 1
            end,
            setFunc = function(r, g, b, a) 
                AKB.Settings.Save("mountStaminaBarColor", {r = r, g = g, b = b})
                AKB.UI.UpdateBarColors()
            end,
            width = "full",
            default = {r = 0, g = 0.8, b = 0},
            disabled = function() return not AKB.Settings.Get("showMountStamina") end,
        },
        {
            type = "slider",
            name = "Mount Stamina Bar Height",
            tooltip = "Height of the mount stamina bar in pixels. This creates a thinner bar compared to the main attribute bars.",
            min = 8,
            max = 20,
            step = 1,
            getFunc = function() return AKB.Settings.Get("mountStaminaHeight") end,
            setFunc = function(value) 
                AKB.Settings.Save("mountStaminaHeight", value)
                if AKB.Settings.Get("showBars") then
                    AKB.UI.CreatePlayerAttributeBars()
                end
            end,
            width = "full",
            default = 12,
            disabled = function() return not AKB.Settings.Get("showMountStamina") end,
        },
        {
            type = "slider",
            name = "Bar Transparency",
            tooltip = "Transparency level for attribute bars. 0 = fully transparent, 100 = fully opaque.",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return math.floor(AKB.Settings.Get("barTransparency") * 100) end,
            setFunc = function(value) 
                AKB.Settings.Save("barTransparency", value / 100)
                AKB.UI.UpdateAllBars()
            end,
            width = "full",
            default = 100,
        },
        {
            type = "divider",
        },
        {
            type = "header",
            name = "Enemy Health Bar Settings",
        },
        {
            type = "checkbox",
            name = "Show Enemy Health Bars",
            tooltip = "Display health bars for targeted enemies. Only shows for hostile targets (attackable NPCs and players).",
            getFunc = function() return AKB.Settings.Get("showEnemyBars") end,
            setFunc = function(value) 
                AKB.Settings.Save("showEnemyBars", value)
                if value and AKB.EnemyBars then
                    AKB.EnemyBars.OnTargetChanged() -- Check current target
                elseif AKB.EnemyBars then
                    AKB.EnemyBars.HideEnemyBar()
                end
            end,
            width = "full",
            default = true,
        },
        {
            type = "slider",
            name = "Enemy Bar X Position",
            tooltip = "Horizontal position of enemy health bars. 0 = center of screen, positive = right, negative = left.",
            min = -1000,
            max = 2000,
            step = 10,
            getFunc = function() return AKB.Settings.Get("enemyBarXPosition") end,
            setFunc = function(value) 
                AKB.Settings.Save("enemyBarXPosition", value)
                if AKB.EnemyBars then
                    AKB.EnemyBars.ApplySettings()
                end
            end,
            width = "full",
            default = 0,
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "slider",
            name = "Enemy Bar Y Position",
            tooltip = "Vertical position of enemy health bars. 0 = center of screen, negative = up, positive = down.",
            min = -1000,
            max = 1200,
            step = 10,
            getFunc = function() return AKB.Settings.Get("enemyBarYPosition") end,
            setFunc = function(value) 
                AKB.Settings.Save("enemyBarYPosition", value)
                if AKB.EnemyBars then
                    AKB.EnemyBars.ApplySettings()
                end
            end,
            width = "full",
            default = -150,
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "slider",
            name = "Enemy Bar Width",
            tooltip = "Width of enemy health bars in pixels.",
            min = 200,
            max = 500,
            step = 10,
            getFunc = function() return AKB.Settings.Get("enemyBarWidth") end,
            setFunc = function(value) 
                AKB.Settings.Save("enemyBarWidth", value)
                if AKB.EnemyBars then
                    AKB.EnemyBars.ApplySettings()
                end
            end,
            width = "full",
            default = 300,
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "slider",
            name = "Enemy Bar Height",
            tooltip = "Height of enemy health bars in pixels.",
            min = 15,
            max = 40,
            step = 1,
            getFunc = function() return AKB.Settings.Get("enemyBarHeight") end,
            setFunc = function(value) 
                AKB.Settings.Save("enemyBarHeight", value)
                if AKB.EnemyBars then
                    AKB.EnemyBars.ApplySettings()
                end
            end,
            width = "full",
            default = 20,
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "checkbox",
            name = "Show Enemy Name",
            tooltip = "Display the enemy name above the health bar.",
            getFunc = function() return AKB.Settings.Get("showEnemyName") end,
            setFunc = function(value) 
                AKB.Settings.Save("showEnemyName", value)
                if AKB.EnemyBars then
                    AKB.EnemyBars.UpdateEnemyInfo()
                end
            end,
            width = "full",
            default = true,
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "checkbox",
            name = "Show Enemy Level",
            tooltip = "Display the enemy level next to the enemy name.",
            getFunc = function() return AKB.Settings.Get("showEnemyLevel") end,
            setFunc = function(value) 
                AKB.Settings.Save("showEnemyLevel", value)
                if AKB.EnemyBars then
                    AKB.EnemyBars.UpdateEnemyInfo()
                end
            end,
            width = "full",
            default = true,
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "dropdown",
            name = "Enemy Name Type",
            tooltip = "Choose whether to display character names or usernames (@AccountName) for players.",
            choices = AKB.Settings.GetEnemyNameChoices(),
            choicesValues = {1, 2},
            getFunc = function() return AKB.Settings.Get("enemyNameType") end,
            setFunc = function(value) 
                AKB.Settings.Save("enemyNameType", value)
                if AKB.EnemyBars then
                    AKB.EnemyBars.UpdateEnemyInfo()
                end
            end,
            width = "full",
            default = 1,
            disabled = function() return not AKB.Settings.Get("showEnemyBars") or not AKB.Settings.Get("showEnemyName") end,
        },
        {
            type = "colorpicker",
            name = "Enemy Health Color",
            tooltip = "Color for the health bar of hostile targets (enemies, attackable NPCs).",
            getFunc = function() 
                local color = AKB.Settings.Get("enemyHealthColor")
                return color.r, color.g, color.b, 1
            end,
            setFunc = function(r, g, b, a) 
                AKB.Settings.Save("enemyHealthColor", {r = r, g = g, b = b})
                if AKB.EnemyBars then
                    AKB.EnemyBars.ApplySettings()
                end
            end,
            width = "full",
            default = {r = 0.8, g = 0.2, b = 0.2},
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "colorpicker",
            name = "Target Ally Health Color",
            tooltip = "Color for the health bar of friendly and neutral targets (allied players, non-hostile NPCs).",
            getFunc = function() 
                local color = AKB.Settings.Get("targetAllyHealthColor")
                return color.r, color.g, color.b, 1
            end,
            setFunc = function(r, g, b, a) 
                AKB.Settings.Save("targetAllyHealthColor", {r = r, g = g, b = b})
                if AKB.EnemyBars then
                    AKB.EnemyBars.ApplySettings()
                end
            end,
            width = "full",
            default = {r = 0.2, g = 0.8, b = 0.2},
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "slider",
            name = "Enemy Bar Transparency",
            tooltip = "Transparency level for enemy health bars. 0 = fully transparent, 100 = fully opaque.",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return math.floor(AKB.Settings.Get("enemyBarTransparency") * 100) end,
            setFunc = function(value) 
                AKB.Settings.Save("enemyBarTransparency", value / 100)
                if AKB.EnemyBars then
                    AKB.EnemyBars.ApplySettings()
                end
            end,
            width = "full",
            default = 100,
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "divider",
        },
        {
            type = "header",
            name = "Enemy Text Settings",
        },
        {
            type = "dropdown",
            name = "Enemy Number Format",
            tooltip = "Choose how numbers are displayed on enemy health bars. Full shows complete numbers with commas. Short shows abbreviated format. Decimal shows abbreviated with one decimal place.",
            choices = {"Full (10,000)", "Short (10k)", "Decimal (10.5k)"},
            getFunc = function() 
                local formatType = AKB.Settings.Get("enemyTextFormatType")
                if formatType == 2 then return "Short (10k)"
                elseif formatType == 3 then return "Decimal (10.5k)"
                else return "Full (10,000)" end
            end,
            setFunc = function(value) 
                local typeValue = 1
                if value == "Short (10k)" then typeValue = 2
                elseif value == "Decimal (10.5k)" then typeValue = 3 end
                AKB.Settings.Save("enemyTextFormatType", typeValue)
                if AKB.EnemyBars then
                    AKB.EnemyBars.ApplySettings()
                end
            end,
            width = "full",
            default = "Full (10,000)",
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "checkbox",
            name = "Hide Enemy Percentage",
            tooltip = "Hide the percentage display on enemy health bars. Only health numbers will be shown.",
            getFunc = function() return AKB.Settings.Get("enemyHidePercentage") end,
            setFunc = function(value) 
                AKB.Settings.Save("enemyHidePercentage", value)
                if AKB.EnemyBars then
                    AKB.EnemyBars.ApplySettings()
                end
            end,
            width = "full",
            default = false,
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "colorpicker",
            name = "Enemy Text Color",
            tooltip = "Color for enemy health bar text.",
            getFunc = function() 
                local color = AKB.Settings.Get("enemyTextColor")
                return color.r, color.g, color.b, 1
            end,
            setFunc = function(r, g, b, a) 
                AKB.Settings.Save("enemyTextColor", {r = r, g = g, b = b})
                if AKB.EnemyBars then
                    AKB.EnemyBars.ApplySettings()
                end
            end,
            width = "full",
            default = {r = 1.0, g = 1.0, b = 1.0},
            disabled = function() return not AKB.Settings.Get("showEnemyBars") end,
        },
        {
            type = "divider",
        },
        {
            type = "header",
            name = "Chat Box Settings",
        },
        {
            type = "checkbox",
            name = "Enable Chat Box Customization",
            tooltip = "Enable or disable chat box positioning and resizing features.",
            getFunc = function() return AKB.Settings.Get("enableChatBoxCustomization") end,
            setFunc = function(value) 
                AKB.Settings.Save("enableChatBoxCustomization", value)
                if value then
                    AKB.Chat.ApplyChatBoxCustomization()
                else
                    AKB.Chat.ResetToOriginal()
                end
            end,
            width = "full",
            default = false,
        },
        {
            type = "slider",
            name = "Chat Box X Position",
            tooltip = "Horizontal offset for chat box position. Positive values move right, negative values move left.",
            min = -2000,
            max = 2000,
            step = 5,
            getFunc = function() return AKB.Settings.Get("chatBoxXPosition") end,
            setFunc = function(value) 
                AKB.Settings.Save("chatBoxXPosition", value)
                if AKB.Settings.Get("enableChatBoxCustomization") then
                    AKB.Chat.ApplyChatBoxCustomization()
                end
            end,
            width = "full",
            default = 0,
        },
        {
            type = "slider",
            name = "Chat Box Y Position",
            tooltip = "Vertical offset for chat box position. Positive values move up, negative values move down.",
            min = -1500,
            max = 1500,
            step = 5,
            getFunc = function() return AKB.Settings.Get("chatBoxYPosition") end,
            setFunc = function(value) 
                AKB.Settings.Save("chatBoxYPosition", value)
                if AKB.Settings.Get("enableChatBoxCustomization") then
                    AKB.Chat.ApplyChatBoxCustomization()
                end
            end,
            width = "full",
            default = 0,
        },
        {
            type = "slider",
            name = "Chat Box Width",
            tooltip = "Width adjustment for chat box. Positive values make it wider, negative values make it narrower.",
            min = -200,
            max = 1000,
            step = 10,
            getFunc = function() return AKB.Settings.Get("chatBoxWidth") end,
            setFunc = function(value) 
                AKB.Settings.Save("chatBoxWidth", value)
                if AKB.Settings.Get("enableChatBoxCustomization") then
                    AKB.Chat.ApplyChatBoxCustomization()
                end
            end,
            width = "full",
            default = 0,
        },
        {
            type = "slider",
            name = "Chat Box Height",
            tooltip = "Height adjustment for chat box. Positive values make it taller, negative values make it shorter.",
            min = -100,
            max = 1000,
            step = 10,
            getFunc = function() return AKB.Settings.Get("chatBoxHeight") end,
            setFunc = function(value) 
                AKB.Settings.Save("chatBoxHeight", value)
                if AKB.Settings.Get("enableChatBoxCustomization") then
                    AKB.Chat.ApplyChatBoxCustomization()
                end
            end,
            width = "full",
            default = 0,
        },
        {
            type = "divider",
        },
        {
            type = "header",
            name = "Stat Windows",
        },
        {
            type = "description",
            text = "Configure up to 3 custom stat windows. Each window can display 1 or 2 stats with customizable positioning.",
        },
        {
            type = "submenu",
            name = "Stat Window 1",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable Stat Window 1",
                    tooltip = "Show or hide the first custom stat window.",
                    getFunc = function() return AKB.Settings.Get("statWindow1Enabled") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow1Enabled", value)
                        AKB.UI.StatWindows.CreateAllWindows()
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "dropdown",
                    name = "First Stat",
                    tooltip = "Choose the primary stat to display in this window.",
                    choices = AKB.Settings.GetStatChoices(false), -- No "None" option for first stat
                    choicesValues = (function()
                        local _, values = AKB.Settings.GetStatChoicesWithValues(false)
                        return values
                    end)(),
                    getFunc = function() return AKB.Settings.Get("statWindow1Stat1") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow1Stat1", value)
                        if AKB.Settings.Get("statWindow1Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 1, -- Physical Resistance
                    disabled = function() return not AKB.Settings.Get("statWindow1Enabled") end,
                },
                {
                    type = "dropdown",
                    name = "Second Stat (Optional)",
                    tooltip = "Choose a second stat to display alongside the first, or select 'None' for a single stat display.",
                    choices = AKB.Settings.GetStatChoices(true), -- Include "None" option
                    choicesValues = (function()
                        local _, values = AKB.Settings.GetStatChoicesWithValues(true)
                        return values
                    end)(),
                    getFunc = function() return AKB.Settings.Get("statWindow1Stat2") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow1Stat2", value)
                        if AKB.Settings.Get("statWindow1Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 0, -- None
                    disabled = function() return not AKB.Settings.Get("statWindow1Enabled") end,
                },
                {
                    type = "slider",
                    name = "Window 1 X Position",
                    tooltip = "Horizontal offset from the custom bars position. Positive values move right, negative values move left.",
                    min = -1000,
                    max = 2000,
                    step = 10,
                    getFunc = function() return AKB.Settings.Get("statWindow1XPosition") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow1XPosition", value)
                        if AKB.Settings.Get("statWindow1Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 100,
                    disabled = function() return not AKB.Settings.Get("statWindow1Enabled") end,
                },
                {
                    type = "slider",
                    name = "Window 1 Y Position",
                    tooltip = "Vertical offset from the custom bars position. Positive values move down, negative values move up.",
                    min = -1000,
                    max = 1200,
                    step = 10,
                    getFunc = function() return AKB.Settings.Get("statWindow1YPosition") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow1YPosition", value)
                        if AKB.Settings.Get("statWindow1Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 200,
                    disabled = function() return not AKB.Settings.Get("statWindow1Enabled") end,
                },
            },
        },
        {
            type = "submenu",
            name = "Stat Window 2",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable Stat Window 2",
                    tooltip = "Show or hide the second custom stat window.",
                    getFunc = function() return AKB.Settings.Get("statWindow2Enabled") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow2Enabled", value)
                        AKB.UI.StatWindows.CreateAllWindows()
                    end,
                    width = "full",
                    default = false,
                },
                {
                    type = "dropdown",
                    name = "First Stat",
                    tooltip = "Choose the primary stat to display in this window.",
                    choices = AKB.Settings.GetStatChoices(false),
                    choicesValues = (function()
                        local _, values = AKB.Settings.GetStatChoicesWithValues(false)
                        return values
                    end)(),
                    getFunc = function() return AKB.Settings.Get("statWindow2Stat1") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow2Stat1", value)
                        if AKB.Settings.Get("statWindow2Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 3, -- Weapon Damage
                    disabled = function() return not AKB.Settings.Get("statWindow2Enabled") end,
                },
                {
                    type = "dropdown",
                    name = "Second Stat (Optional)",
                    tooltip = "Choose a second stat to display alongside the first, or select 'None' for a single stat display.",
                    choices = AKB.Settings.GetStatChoices(true),
                    choicesValues = (function()
                        local _, values = AKB.Settings.GetStatChoicesWithValues(true)
                        return values
                    end)(),
                    getFunc = function() return AKB.Settings.Get("statWindow2Stat2") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow2Stat2", value)
                        if AKB.Settings.Get("statWindow2Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 4, -- Spell Damage
                    disabled = function() return not AKB.Settings.Get("statWindow2Enabled") end,
                },
                {
                    type = "slider",
                    name = "Window 2 X Position",
                    tooltip = "Horizontal offset from the custom bars position. Positive values move right, negative values move left.",
                    min = -1000,
                    max = 2000,
                    step = 10,
                    getFunc = function() return AKB.Settings.Get("statWindow2XPosition") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow2XPosition", value)
                        if AKB.Settings.Get("statWindow2Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 300,
                    disabled = function() return not AKB.Settings.Get("statWindow2Enabled") end,
                },
                {
                    type = "slider",
                    name = "Window 2 Y Position",
                    tooltip = "Vertical offset from the custom bars position. Positive values move down, negative values move up.",
                    min = -1000,
                    max = 1200,
                    step = 10,
                    getFunc = function() return AKB.Settings.Get("statWindow2YPosition") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow2YPosition", value)
                        if AKB.Settings.Get("statWindow2Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 200,
                    disabled = function() return not AKB.Settings.Get("statWindow2Enabled") end,
                },
            },
        },
        {
            type = "submenu",
            name = "Stat Window 3",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable Stat Window 3",
                    tooltip = "Show or hide the third custom stat window.",
                    getFunc = function() return AKB.Settings.Get("statWindow3Enabled") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow3Enabled", value)
                        AKB.UI.StatWindows.CreateAllWindows()
                    end,
                    width = "full",
                    default = false,
                },
                {
                    type = "dropdown",
                    name = "First Stat",
                    tooltip = "Choose the primary stat to display in this window.",
                    choices = AKB.Settings.GetStatChoices(false),
                    choicesValues = (function()
                        local _, values = AKB.Settings.GetStatChoicesWithValues(false)
                        return values
                    end)(),
                    getFunc = function() return AKB.Settings.Get("statWindow3Stat1") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow3Stat1", value)
                        if AKB.Settings.Get("statWindow3Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 7, -- Critical Chance
                    disabled = function() return not AKB.Settings.Get("statWindow3Enabled") end,
                },
                {
                    type = "dropdown",
                    name = "Second Stat (Optional)",
                    tooltip = "Choose a second stat to display alongside the first, or select 'None' for a single stat display.",
                    choices = AKB.Settings.GetStatChoices(true),
                    choicesValues = (function()
                        local _, values = AKB.Settings.GetStatChoicesWithValues(true)
                        return values
                    end)(),
                    getFunc = function() return AKB.Settings.Get("statWindow3Stat2") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow3Stat2", value)
                        if AKB.Settings.Get("statWindow3Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 8, -- Critical Resist
                    disabled = function() return not AKB.Settings.Get("statWindow3Enabled") end,
                },
                {
                    type = "slider",
                    name = "Window 3 X Position",
                    tooltip = "Horizontal offset from the custom bars position. Positive values move right, negative values move left.",
                    min = -1000,
                    max = 2000,
                    step = 10,
                    getFunc = function() return AKB.Settings.Get("statWindow3XPosition") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow3XPosition", value)
                        if AKB.Settings.Get("statWindow3Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 500,
                    disabled = function() return not AKB.Settings.Get("statWindow3Enabled") end,
                },
                {
                    type = "slider",
                    name = "Window 3 Y Position",
                    tooltip = "Vertical offset from the custom bars position. Positive values move down, negative values move up.",
                    min = -1000,
                    max = 1200,
                    step = 10,
                    getFunc = function() return AKB.Settings.Get("statWindow3YPosition") end,
                    setFunc = function(value) 
                        AKB.Settings.Save("statWindow3YPosition", value)
                        if AKB.Settings.Get("statWindow3Enabled") then
                            AKB.UI.StatWindows.CreateAllWindows()
                        end
                    end,
                    width = "full",
                    default = 200,
                    disabled = function() return not AKB.Settings.Get("statWindow3Enabled") end,
                },
            },
        },
    }
end
