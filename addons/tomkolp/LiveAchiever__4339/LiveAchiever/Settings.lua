if not LiveAchiever then return end
local LA = LiveAchiever
local LHAS = LibHarvensAddonSettings

function LA.CreateSettingsMenu()
    if not LHAS then return end
    local settings = LHAS:AddAddon("Live Achiever", { allowDefaults = true })
    if not settings then return end

    -- --- SEKCJA POWIADOMIENIA ---
    settings:AddSetting({
        type = LHAS.ST_SECTION,
        label = LA.strings.Settings_Section_Notify,
    })

    local timeOptions = {
        {name = LA.strings.Time_Opt_1, data = 3000},
        {name = LA.strings.Time_Opt_2, data = 10000},
        {name = LA.strings.Time_Opt_3, data = 60000},
        {name = LA.strings.Time_Opt_4, data = 120000},
        {name = LA.strings.Time_Opt_5, data = 300000},
        {name = LA.strings.Time_Opt_6, data = 600000},
        {name = LA.strings.Time_Opt_7, data = 1200000},
        {name = LA.strings.Time_Opt_8, data = 1800000},
        {name = LA.strings.Time_Opt_9, data = 3600000},
        {name = LA.strings.Time_Opt_10, data = 7200000},
    }

    settings:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = LA.strings.Settings_Time_Label,
        tooltip = LA.strings.Settings_Time_Tooltip,
        items = timeOptions,
        default = LA.strings.Time_Opt_1,
        
        getFunction = function()
            local currentVal = LA.savedVars.notificationDuration
            
            if type(currentVal) == "table" and currentVal.data then currentVal = currentVal.data end
            if type(currentVal) ~= "number" then currentVal = 3000 end

            for _, option in ipairs(timeOptions) do
                if option.data == currentVal then
                    return option.name
                end
            end
            return LA.strings.Time_Opt_1
        end,
        
        setFunction = function(combobox, itemName, itemData)
            local val = itemData
            if type(itemData) == "table" and itemData.data then val = itemData.data end
            
            LA.savedVars.notificationDuration = val
            local msg = zo_strformat(LA.strings.Msg_Time_Set, itemName)
            d("|c00FF00" .. msg .. "|r")
            
            LA.accumulatedDiffs = {}
            LA.timerInfos = {}
            if LA.savedVars.accumulations then LA.savedVars.accumulations = {} end
            if LA.UpdateTrackerUI then LA.UpdateTrackerUI() end
        end,
    })

    -- --- SEKCJA ZARZĄDZANIE ---
    settings:AddSetting({
        type = LHAS.ST_SECTION,
        label = LA.strings.Settings_Section_Manage,
    })

    -- NOWOŚĆ: Checkbox Ukryj w walce
    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = LA.strings.Settings_Hide_Combat_Label,
        tooltip = LA.strings.Settings_Hide_Combat_Tooltip,
        default = true,
        getFunction = function() return LA.savedVars.hideInCombat end,
        setFunction = function(value)
            LA.savedVars.hideInCombat = value
            -- Odśwież widoczność natychmiast
            if LA.uiContainer then
                if value and IsUnitInCombat("player") then
                    LA.uiContainer:SetHidden(true)
                else
                    LA.uiContainer:SetHidden(false)
                end
            end
        end,
    })

    -- [NOWE] Checkbox do włączania podglądu w menu (Tryb pozycjonowania)
    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = LA.strings.Settings_Unlock_Label or "Unlock Window (Positioning)",
        tooltip = LA.strings.Settings_Unlock_Tooltip or "Shows the tracker in menus so you can adjust its position.",
        default = false,
        getFunction = function() 
            return LA.isPositioning 
        end,
        setFunction = function(value)
            if LA.SetPositioningMode then
                LA.SetPositioningMode(value)
            end
        end,
    })

    -- Suwak Pozycji X
    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = LA.strings.Settings_Slider_X_Label,
        tooltip = LA.strings.Settings_Slider_X_Tooltip,
        min = 0,
        max = GuiRoot:GetWidth(),
        step = 10,
        getFunction = function() return LA.savedVars.left or 20 end,
        setFunction = function(value)
            LA.savedVars.left = value
            if LA.uiContainer then
                LA.uiContainer:ClearAnchors()
                LA.uiContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LA.savedVars.left, LA.savedVars.top)
            end
        end,
    })

    -- Suwak Pozycji Y
    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = LA.strings.Settings_Slider_Y_Label,
        tooltip = LA.strings.Settings_Slider_Y_Tooltip,
        min = 0,
        max = GuiRoot:GetHeight(),
        step = 10,
        getFunction = function() return LA.savedVars.top or 600 end,
        setFunction = function(value)
            LA.savedVars.top = value
            if LA.uiContainer then
                LA.uiContainer:ClearAnchors()
                LA.uiContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LA.savedVars.left, LA.savedVars.top)
            end
        end,
    })
	
-- --- SEKCJA WYGLĄD ---
    settings:AddSetting({
        type = LHAS.ST_SECTION,
        label = LA.strings.Settings_Section_Appearance or "Appearance",
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = LA.strings.Settings_Font_Label or "Font Size",
        -- Dynamiczny tooltip informujący, który tryb edytujemy
        tooltip = function()
            local mode = IsInGamepadPreferredMode() and "Gamepad" or "PC"
            return string.format("%s (%s Mode). Range: 6-28.", LA.strings.Settings_Font_Tooltip or "Adjust text size", mode)
        end,
        min = 6,
        max = 28,
        step = 1,
        default = 16, -- Wartość domyślna dla przycisku "Reset" w menu (mniej istotna, bo mamy defaultsVars)
        
        getFunction = function() 
            if IsInGamepadPreferredMode() then
                return LA.savedVars.fontSizeGamepad or 16
            else
                return LA.savedVars.fontSizePC or 12
            end
        end,
        
        setFunction = function(value)
            if IsInGamepadPreferredMode() then
                LA.savedVars.fontSizeGamepad = value
            else
                LA.savedVars.fontSizePC = value
            end
            
            -- Odświeżamy wygląd natychmiast
            if LA.ApplyAppearance then
                LA.ApplyAppearance()
            end
        end,
    })
	
	-- Suwak Przezroczystości
    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = LA.strings.Settings_Alpha_Label or "Background Opacity",
        tooltip = LA.strings.Settings_Alpha_Tooltip or "Adjust the background transparency (0-100%).",
        min = 0,
        max = 100,
        step = 1,
        default = 60,
        
        getFunction = function() 
            return LA.savedVars.backgroundAlpha or 60 
        end,
        
        setFunction = function(value)
            LA.savedVars.backgroundAlpha = value
            -- Natychmiastowa aktualizacja wyglądu
            if LA.UpdateBackgroundAlpha then
                LA.UpdateBackgroundAlpha()
            end
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_BUTTON,
        label = LA.strings.Settings_Reset_Pos,
        buttonText = LA.strings.Settings_Reset_Pos_Btn,
        clickHandler = function()
            local newLeft, newTop = 20, 600
            LA.savedVars.left = newLeft
            LA.savedVars.top = newTop
            
            if LA.uiContainer then
                LA.uiContainer:ClearAnchors()
                LA.uiContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, newLeft, newTop)
            end
            d(LA.strings.Msg_Pos_Reset)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_BUTTON,
        label = LA.strings.Settings_Clear_List,
        buttonText = LA.strings.Settings_Clear_List_Btn,
        clickHandler = function()
            LA.savedVars.trackedAchievements = {}
            LA.savedVars.expandedStates = {}
            LA.progressCache = {}
            LA.accumulatedDiffs = {}
            LA.timerInfos = {}
            LA.savedVars.recentHistory = {} -- Czyścimy też historię przy czyszczeniu wszystkiego
            
            if LA.savedVars.accumulations then LA.savedVars.accumulations = {} end
            
            if LA.UpdateTrackerUI then LA.UpdateTrackerUI() end
            if ACHIEVEMENTS and ACHIEVEMENTS.RefreshVisible then ACHIEVEMENTS:RefreshVisible() end
            
            if IsInGamepadPreferredMode() and KEYBIND_STRIP and LA.gamepadKeybindStrip then
                 KEYBIND_STRIP:UpdateKeybindButtonGroup(LA.gamepadKeybindStrip)
            end
            d(LA.strings.Msg_List_Cleared)
        end,
    })
end