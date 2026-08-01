local ADDON_NAME = "ChampionXPBar"
local frame, xpLabel
local SV -- SavedVars reference

-------------------------------------------------
-- Default settings
-------------------------------------------------
local defaults = {
    x = 400,
    y = 300,
    textSize = 18,
    visible = true,
    locked = false,
    mode = "Both", -- "XP", "CP", "Both"
    xpColor = {1, 1, 0, 1},   -- Yellow
    cpColor = {0, 0.8, 1, 1}, -- Blue
}

-------------------------------------------------
-- Apply current settings
-------------------------------------------------
local function ApplySettings()
    if not frame or not xpLabel then return end

    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.x, SV.y)
    frame:SetHidden(not SV.visible)
    xpLabel:ClearAnchors()
    xpLabel:SetAnchor(CENTER, frame, CENTER)
    xpLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", SV.textSize))
    xpLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    xpLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    xpLabel:SetHidden(not SV.visible)
end

-------------------------------------------------
-- Create the label and drag functionality
-------------------------------------------------
local function CreateTextLabel()
    if frame then return end

    frame = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "Frame")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)


    xpLabel = WINDOW_MANAGER:CreateControl(nil, frame, CT_LABEL)
    xpLabel:SetDrawLayer(DL_OVERLAY)

    ApplySettings()
end

-------------------------------------------------
-- Helper: Auto switch XP/CP at max level
-------------------------------------------------
local function GetDisplayMode()
    local level = GetUnitLevel("player") or 1

    -- At level 50, force CP mode
    if level >= 50 then
        return "CP"
    end

    -- Below 50, force XP mode
    if level < 50 then
        return "XP"
    end
end

-------------------------------------------------
-- Update XP / CP display (robust version)
-------------------------------------------------
local function UpdateXPLabel()
    if not xpLabel or not SV then return end

    local text = ""
    local xpColor = SV.xpColor or {1, 1, 0}   -- fallback yellow
    local cpColor = SV.cpColor or {0, 0.8, 1} -- fallback blue
    local level = GetUnitLevel("player") or 1
    local mode = GetDisplayMode()
    
    -- Auto-switch to CP mode if max level reached
    if level >= 50 then
        if mode == "XP" then
            mode = "CP"
        end
    end

    -- XP Display
    if (mode == "XP" or SV.mode == "Both") and level < 50 then
        local currentXP = GetUnitXP("player") or 0
        local maxXP = GetUnitXPMax("player") or 1
        local xpPercent = (currentXP / maxXP) * 100

        text = string.format("|c%02X%02X%02XXP: %d/%d (%.1f%%) - Lv %d|r",
            xpColor[1]*255, xpColor[2]*255, xpColor[3]*255,
            currentXP, maxXP, xpPercent, level)
    elseif level >= 50 and (mode == "XP" or SV.mode == "Both") then
        text = string.format("|c%02X%02X%02XMax Level - Lv %d|r",
            xpColor[1]*255, xpColor[2]*255, xpColor[3]*255,
            level)
    end

    -- CP Display
    if mode == "CP" or SV.mode == "Both" then
        local cp = GetUnitChampionPoints("player") or 0
        local currentCPXP = GetPlayerChampionXP() or 0
        local nextCPXP = GetNumChampionXPInChampionPoint(cp) or 1
        local cpPercent = (currentCPXP / nextCPXP) * 100

        if text ~= "" then text = text .. "\n" end
        text = text .. string.format("|c%02X%02X%02XCP: %d (%.1f%%)|r",
            cpColor[1]*255, cpColor[2]*255, cpColor[3]*255,
            cp, cpPercent)
    end

    xpLabel:SetText(text)
end


-------------------------------------------------
-- LibAddonMenu2 Settings (Nicer & Cleaner)
-------------------------------------------------
local function SetupLAM()
    if not LibAddonMenu2 then
        zo_callLater(SetupLAM, 500)
        return
    end

    -- Icon constants for the professional look
    local iconCP = "|t22:22:EsoUI/Art/Champion/champion_icon_32.dds|t"
    local iconXP = "|t22:22:EsoUI/Art/Progression/progression_indexicon_combined_up.dds|t"
    local iconGear = "|t22:22:EsoUI/Art/Help/help_tabicon_settings_up.dds|t"

    local panelData = {
        type = "panel",
        name = "Champion XP Bar Settings",
        displayName = iconCP .. " |cFFFF00Champion|r |c00FFFFXP Bar|r",
        author = "|cFF00FFTHEWIZADT|r",
        version = "|c00FF001.9|r",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel("ChampionXPBarOptions", panelData)

    local optionsData = {
        -- SECTION: CONFIGURATION
        {
            type = "header",
            name = iconGear .. " |cFFFFFFMain Configuration|r",
        },
        {
            type = "checkbox",
            name = "Enable Experience Bar",
            tooltip = "Toggle the visibility of the tracker.",
            getFunc = function() return SV.visible end,
            setFunc = function(val) SV.visible = val ApplySettings() end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Display Mode",
            choices = {"XP", "CP", "Both"},
            tooltip = "Choose which experience types to track on screen.",
            getFunc = function() return SV.mode end,
            setFunc = function(val) SV.mode = val UpdateXPLabel() end,
            width = "full",
        },

        -- SECTION: APPEARANCE
        {
            type = "header",
            name = "|c00FFFF[ 🎨 ] Visual Styling|r",
        },
        {
            type = "slider",
            name = "Text Size",
            tooltip = "Adjust how large the text appears.",
            min = 10, 
            max = 60,
            step = 1,
            getFunc = function() return SV.textSize end,
            setFunc = function(val) 
                SV.textSize = val 
                ApplySettings() 
            end,
            width = "full",
            default = defaults.textSize,
        },
        {
            type = "colorpicker",
            name = iconXP .. " |cFFFF00XP|r Text Color",
            getFunc = function() return unpack(SV.xpColor) end,
            setFunc = function(r,g,b,a) SV.xpColor = {r,g,b,a} UpdateXPLabel() end,
            width = "half",
        },
        {
            type = "colorpicker",
            name = iconCP .. " |c00CCFFCP|r Text Color",
            getFunc = function() return unpack(SV.cpColor) end,
            setFunc = function(r,g,b,a) SV.cpColor = {r,g,b,a} UpdateXPLabel() end,
            width = "half",
        },

        -- SECTION: POSITIONING
        {
            type = "header",
            name = "|cFFFFFF[ ✥ ] Screen Position|r",
        },
        {
            type = "slider",
            name = "Horizontal (X Offset)",
            min = 0, 
            max = 3000,
            step = 10,
            getFunc = function() return SV.x end,
            setFunc = function(val) SV.x = val ApplySettings() end,
            width = "full",
            default = defaults.x,
        },
        {
            type = "slider",
            name = "Vertical (Y Offset)",
            min = 0, 
            max = 2000,
            step = 10,
            getFunc = function() return SV.y end,
            setFunc = function(val) SV.y = val ApplySettings() end,
            width = "full",
            default = defaults.y,
        },

        -- FOOTER
        {
            type = "divider",
        },
        {
            type = "description",
            text = "For support or bug reports: |c00FF00wizadt@gmail.com|r",
            width = "full",
        },
    }

    LibAddonMenu2:RegisterOptionControls("ChampionXPBarOptions", optionsData)
end

-------------------------------------------------
-- Event Handlers
-------------------------------------------------
local function OnAddonLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- ✅ Character-specific SavedVars (works reliably)
    SV = ZO_SavedVars:New("ChampionXPBarSavedVars", 1, GetCurrentCharacterId(), defaults)

    CreateTextLabel()
    SetupLAM()
    UpdateXPLabel()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EXPERIENCE_UPDATE, UpdateXPLabel)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHAMPION_XP_UPDATE, UpdateXPLabel)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHAMPION_POINT_GAINED, UpdateXPLabel)
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Refresh", 5000, UpdateXPLabel)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)