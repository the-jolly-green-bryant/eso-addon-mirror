-- Mighty Experience Bar
-- The MIT License © 2024 Andy Whiteman

MightyExperienceBar = {}
MightyExperienceBar.name = "MightyExperienceBar"

local savedVariables


-- Show or hide the XP progress Bar and keep it updated
local function SetMightyXpBarVisibility(showBar)
    if showBar then
        MightyExperienceBarLabel:SetHidden(false)
        HUD_SCENE:AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
        HUD_UI_SCENE:AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
    else
        MightyExperienceBarLabel:SetHidden(true)
        HUD_SCENE:RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
        HUD_UI_SCENE:RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
    end
end


-- Display and update the XP progress text on the XP progress bar
local function UpdateMightyXpBarText()
    local barTypeInfo = PLAYER_PROGRESS_BAR:GetBarTypeInfo()
    local level = 0
    local currentXP = 0
    local nextLevelXP = 0
    
    -- Check if we have Info data
    if barTypeInfo then
        level = barTypeInfo:GetLevel()
        currentXP = barTypeInfo:GetCurrent()
        nextLevelXP = barTypeInfo:GetLevelSize(level)
    
        -- Check if players current XP is less than XP to the next Level
        if currentXP < nextLevelXP then            
            -- Work out the percentage
            local percentageXP = zo_floor(currentXP / nextLevelXP * 100)
            -- Display/Update the GUI text
            MightyExperienceBarLabel:SetText(zo_strformat(barTypeInfo.tooltipCurrentMaxFormat, ZO_CommaDelimitNumber(currentXP), ZO_CommaDelimitNumber(nextLevelXP), percentageXP))
        end
    end
end


-- Get and Set the Font Sizes
local function GetFontSize()
    return savedVariables.fontSize
end
local function SetFontSize(newSize)
    MightyExperienceBarLabel:SetFont("$(" .. savedVariables.font .. ")|$(KB_" .. newSize .. ")|soft-shadow-thick")
    savedVariables.fontSize = newSize
end

-- Get and Set the Fonts
local function GetFont()
    return savedVariables.font
end
local function SetFont(newFont)
    MightyExperienceBarLabel:SetFont("$("..newFont..")|$(KB_" .. GetFontSize() .. ")|soft-shadow-thick")
    savedVariables.font = newFont
end

-- Get and Set the Font Colour
local function GetFontColour()
    return savedVariables.fontColour.r,savedVariables.fontColour.g,savedVariables.fontColour.b,savedVariables.fontColour.a
end
local function SetFontColour(newR,newG,newB,newA)
    MightyExperienceBarLabel:SetColor(newR,newG,newB,newA)
    savedVariables.fontColour.r = newR
    savedVariables.fontColour.g = newG
    savedVariables.fontColour.b = newB
    savedVariables.fontColour.a = newA
end


--Initialise settings
local function InitMightyExperienceBar()
    
    SetMightyXpBarVisibility(savedVariables.visible)
    SetFont(savedVariables.font)
    SetFontSize(savedVariables.fontSize)
    SetFontColour(savedVariables.fontColour.r,savedVariables.fontColour.g,savedVariables.fontColour.b,savedVariables.fontColour.a)

    -- Init LibAddonMenu2 addon for options screen
    local LAM = LibAddonMenu2
    local panelName = "Mighty Experience Bar Options"
    
    local panelData = {
        type = "panel",
        name = "Mighty Experience Bar",
        author = "@MightyWrath",
        version = "1.1.0"
    }
    
    -- Setup the available LAM options
    local optionsData = {
        [1] = {
            type = "checkbox",
            name = "Show Mighty XP Bar",
            tooltip = "Enables or disables the Mighty Experiance Bar.",
            getFunc = function() return savedVariables.visible end,
            setFunc = function(value) SetMightyXpBarVisibility(value) end
        },
        [2] = {
            type = "dropdown",
            name = "Font",
            tooltip = "The font to use for text on the XP progress bar.",
            choices = {
                "MEDIUM_FONT",
                "BOLD_FONT",
                "CHAT_FONT",
                "GAMEPAD_LIGHT_FONT",
                "GAMEPAD_MEDIUM_FONT",
                "GAMEPAD_BOLD_FONT",
                "ANTIQUE_FONT",
                "HANDWRITTEN_FONT",
                "STONE_TABLET_FONT"
            },
            getFunc = function() return GetFont() end,
            setFunc = function(value) SetFont(value) end
        },
        [3] = {
            type = "slider",
            name = "Font Size",
            tooltip = "Set the size of the font.",
            getFunc = function() return GetFontSize() end,
            setFunc = function(value) SetFontSize(value) end,
            min = 8,
            max = 26
        },
        [4] = {
            type = "colorpicker",
            name = "Font Colour",
            tooltip = "Choose the colour of the font.",
            getFunc = function() return GetFontColour() end,
            setFunc = function(r,g,b,a) SetFontColour(r,g,b,a) end
        }
    }
    
    -- Register to LAM
    local panel = LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsData)
end


-- Initialises when the MightyExperienceBar AddOn is first loaded
function MightyExperienceBar.OnAddOnLoaded(event, name)
    -- Make sure we are ONLY dealing with the MightyExperienceBar AddOn
    if name ~= "MightyExperienceBar" then return end
    -- We no longer need to listen for the AddOnLoaded Event
    EVENT_MANAGER:UnregisterForEvent("MightyExperienceBar", EVENT_ADD_ON_LOADED)
    
    -- Setup default variables
    local defaultVars = {
        fontSize = 16,
        font = "GAMEPAD_LIGHT_FONT",
        fontColour = {
            r = 255,
            g = 255,
            b = 255,
            a = 255
        },
        visible = true
    }
    
    -- Setup saved variables
    savedVariables = ZO_SavedVars:NewAccountWide('MightyExperienceBarVars', 1, nil, defaultVars)
    
    -- Call to initialise all settings
    InitMightyExperienceBar()
    
    
    -- NOTE: We need to check other XP bar code to see how else I can do this, maybe using an EVENT?
    -- Hook into the method that updates the label with the level so it also updates the progression label.
    local setLevelLabelText = PLAYER_PROGRESS_BAR.SetLevelLabelText
    function PLAYER_PROGRESS_BAR:SetLevelLabelText(...)
        setLevelLabelText(self, ...)
        UpdateMightyXpBarText()
    end
end

-- EVENT : When player XP is updated
function MightyExperienceBar.OnXpUpdate(event, name)
    -- Make sure we are ONLY dealing with the MightyExperienceBar AddOn
    if name ~= "MightyExperienceBar" then return end
    
    UpdateMightyXpBarText()
end

EVENT_MANAGER:RegisterForEvent(MightyExperienceBar.name, EVENT_ADD_ON_LOADED, MightyExperienceBar.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(MightyExperienceBar.name, EVENT_EXPERIENCE_UPDATE, MightyExperienceBar.OnXpUpdate)