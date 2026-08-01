-- TTDungeon_Settings.lua
-- Settings menu integration using LibAddonMenu-2.0

-- ================================================================================
-- Settings Menu Initialization
-- ================================================================================

-- Initialize the settings menu for TTDungeon addon
function TTDungeon:InitSettingsMenu()
    -- Debug logging function for settings-specific messages
    local function SettingsDebug(msg)
        if TTDungeon.savedVars and TTDungeon.savedVars.debugEnabled then
            d("[TTD Settings] " .. tostring(msg))
        end
    end

    -- ============================================================================
    -- Panel Configuration
    -- ============================================================================
    
    -- Define the main settings panel metadata
    local panelData = {
        type = "panel",
        name = "TTDungeon",
        displayName = "|cFFD700TT|rDungeon",
        author = "|cFFD700Koro|r.Sensei",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    -- Create shortcut reference to saved variables for cleaner code
    local sv = self.savedVars

    -- ============================================================================
    -- Setting Update Functions
    -- ============================================================================
    
    -- Update the UI background transparency
    local function UpdateAlpha(value)
        sv.backgroundAlpha = value
        -- Apply immediately if UI exists
        if TTDungeon.bg then
            TTDungeon.bg:SetCenterColor(0, 0, 0, value)
        end
    end

    -- Update when the UI should be displayed
    local function UpdateDisplayMode(mode)
        sv.displayMode = mode
        TTDungeon.UpdateUIVisibility()
        TTDungeon.UpdateUIContent()
    end

    -- Toggle the UI visibility immediately
    local function ShowUIManual()
        TTDungeon.ToggleUI()
    end

    -- Update whether the UI can be dragged
    local function UpdateLockUI(value)
        sv.lockUI = value
        TTDungeon.HandleLockUI(value)
    end

    -- Update the overall UI scale
    local function UpdateUIScale(value)
        sv.uiScale = value
        TTDungeon.UpdateScale(value)
    end

    -- Update the interface language
    local function UpdateLanguage(value)
        SettingsDebug(string.format("Settings: UpdateLanguage called with value: '%s'", tostring(value)))
        sv.language = value
        TTDungeon.SetLanguageData()
        TTDungeon.UpdateUIContent()
    end

    -- ============================================================================
    -- Settings Options Definition
    -- ============================================================================
    
    local optionsTable = {
        -- ========================================
        -- General
        -- ========================================
        {
            type = "header",
            name = "|cFFD700General|r",
            width = "full",
        },
        
        -- Window visibility control
        {
            type = "dropdown",
            name = "Window Visibility",
            tooltip = "When should the addon window be shown?",
            choices = { 
                "Always Visible", 
                "Only in Dungeons", 
                "Manual Control" 
            },
            choicesValues = { 
                "Always", 
                "OnlyInDungeon", 
                "Manual" 
            },
            getFunc = function() 
                local mode = sv.displayMode
                if mode == "Always" then return "Always"
                elseif mode == "OnlyInDungeon" then return "OnlyInDungeon"
                else return "Manual" end
            end,
            setFunc = function(val) UpdateDisplayMode(val) end,
            default = "Always",
            width = "full",
        },
        
        -- Background transparency slider
        {
            type = "slider",
            name = "Background Opacity",
            tooltip = "How transparent should the window background be?",
            min = 0,
            max = 100,
            step = 10,
            getFunc = function() return math.floor(sv.backgroundAlpha * 100) end,
            setFunc = function(value) UpdateAlpha(value / 100) end,
            default = 50,
            width = "full",
            clampInput = true,
            decimals = 0,
        },
        
        -- Manual toggle button
        {
            type = "button",
            name = "Show/Hide Window",
            tooltip = "Toggle the window visibility right now",
            func = function() ShowUIManual() end,
            width = "half",
            isDangerous = false,
            warning = "You can also use /ttd",
        },
        
        -- Spacing
        {
            type = "divider",
            width = "full",
            height = 10,
            alpha = 0,
        },
        
        -- ========================================
        -- Window
        -- ========================================
        {
            type = "header",
            name = "|cFFD700Window|r",
            width = "full",
        },
        
        -- Window scale slider
        {
            type = "slider",
            name = "Window Size",
            tooltip = "Scale the entire addon window",
            min = 50,
            max = 150,
            step = 10,
            getFunc = function() return math.floor(sv.uiScale * 100) end,
            setFunc = function(value) UpdateUIScale(value / 100) end,
            default = 100,
            width = "full",
            clampInput = true,
            decimals = 0,
        },
        
        -- Lock position checkbox
        {
            type = "checkbox",
            name = "Lock Window Position",
            tooltip = "Prevents the window from being dragged",
            getFunc = function() return sv.lockUI end,
            setFunc = function(value) UpdateLockUI(value) end,
            default = false,
            width = "half",
        },
        
        -- Invert scroll direction
        {
            type = "checkbox",
            name = "Invert Mouse Scroll",
            tooltip = "Reverses scroll wheel direction",
            getFunc = function() return sv.invertScroll end,
            setFunc = function(value) sv.invertScroll = value end,
            default = true,
            width = "half",
        },
        
        -- Spacing
        {
            type = "divider",
            width = "full",
            height = 10,
            alpha = 0,
        },
        
        -- ========================================
        -- Language & Debug
        -- ========================================
        {
            type = "header",
            name = "|cFFD700Language & Debug|r",
            width = "full",
        },
        
        -- Language selection
        {
            type = "dropdown",
            name = "Language",
            tooltip = "Choose language for dungeon mechanics",
            choices = { 
                "English", 
                "German" 
            },
            choicesValues = { 
                "en", 
                "de" 
            },
            getFunc = function() 
                return sv.language == "de" and "de" or "en"
            end,
            setFunc = function(val) UpdateLanguage(val) end,
            default = "en",
            width = "half",
            warning = "Requires /reloadui",
        },
        
        -- Debug mode toggle
        {
            type = "checkbox",
            name = "Debug Messages",
            tooltip = "Shows technical info in chat",
            getFunc = function() return sv.debugEnabled end,
            setFunc = function(value) sv.debugEnabled = value end,
            default = false,
            width = "half",
            warning = "For troubleshooting only",
        },
        
        -- ========================================
        -- Information
        -- ========================================
        {
            type = "divider",
            width = "full",
            height = 10,
            alpha = 0.5,
        },
        
        {
            type = "description",
            text = "|c808080Note: Mechanics are AI-summarized. Accuracy may vary. Please report any issues on ESOUI.|r",
            width = "full",
        },
    }

    -- ============================================================================
    -- Register Settings Panel
    -- ============================================================================
    
    -- Register the panel with LibAddonMenu
    LibAddonMenu2:RegisterAddonPanel("TTDungeonSettingsPanel", panelData)
    
    -- Register all option controls
    LibAddonMenu2:RegisterOptionControls("TTDungeonSettingsPanel", optionsTable)

    SettingsDebug("Settings menu initialized")
end