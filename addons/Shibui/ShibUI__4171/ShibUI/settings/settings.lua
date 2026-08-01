--------------------------------------------------
-- ShibUI Settings Module
--------------------------------------------------
local SUI = SUI
local sv

SUI.Settings = SUI.Settings or {}
local Settings = SUI.Settings

local Log = function(...) SUI.Debug:Log("Settings", ...) end

--------------------------------------------------
-- Settings Section Helpers
-- Each function returns a table of settings for a specific section.
-- These are combined to form the full settings panel.
-- Add new sections as needed.
--------------------------------------------------


local function GeneralSettings()
    return {
        {
            type = "description",
            text = "ShibUI is a minimal and modern interface mod for ESO, created by Shownie in collaboration with AI. It hides or replaces textures to achieve a clean, unobtrusive style.\n\nThe name 'ShibUI' comes from the Japanese word 'shibui' (渋い), which describes a subtle, refined aesthetic — simple, yet elegant.",
            width = "full",
        },
        { 
            type = "header",
            name = "General Settings "
        },
        {
            type = "checkbox",
            name = "Account Wide Settings",
            tooltip = "Use the same settings for all characters on this account.",
            getFunc = function() return sv.accountWide end,
            setFunc = function(value) sv.accountWide = value end,
            default = SUI.SavedVars.defaults.accountWide,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = "Confirm Reload UI",
            tooltip = "Show a confirmation prompt before reloading the UI.",
            getFunc = function() return sv.confirmReload end,
            setFunc = function(value) sv.confirmReload = value end,
            default = SUI.SavedVars.defaults.confirmReload,
            requiresReload = false,
        },
        {
            type = "checkbox",
            name = "Enable Debug Mode",
            tooltip = "Toggle debug messages for troubleshooting.",
            getFunc = function() return sv.debug end,
            setFunc = function(value) sv.debug = value end,
            default = SUI.SavedVars.defaults.debug,
            requiresReload = true,
        },
    }
end

local function ChatWindowSettings()
    return {
        {
            type = "header",
            name = "Chat Window Settings",
        },
        {
            type = "slider",
            name = "Width",
            min = 300, max = 1000,
            getFunc = function() return sv.chatWidth end,
            setFunc = function(value)
                sv.chatWidth = value
                SUI.ChatWindow:SetSize()
            end,
            default = SUI.SavedVars.defaults.chatWidth,
        },
        {
            type = "slider",
            name = "Height",
            min = 200, max = 800,
            getFunc = function() return sv.chatHeight end,
            setFunc = function(value)
                sv.chatHeight = value
                SUI.ChatWindow:SetSize()
            end,
            default = SUI.SavedVars.defaults.chatHeight,
        },

        {
            type = "dropdown",
            name = "Side",
            choices = {"Left", "Right"},
            getFunc = function() return sv.chatSide end,
            setFunc = function(value)
                sv.chatSide = value
                SUI.ChatWindow:SetPosition()
            end,
            default = SUI.SavedVars.defaults.chatSide,
        },
        {
            type = "dropdown",
            name = "Anchor",
            choices = {"Top", "Bottom"},
            getFunc = function() return sv.chatAnchor end,
            setFunc = function(value)
                sv.chatAnchor = value
                SUI.ChatWindow:SetPosition()
            end,
            default = SUI.SavedVars.defaults.chatAnchor,
        },
        {
            type = "dropdown",
            name = "Default Channel on Login",
            choices = {"Say", "Group", "Zone", "Guild 1", "Guild 2", "Guild 3", "Guild 4", "Guild 5"},
            getFunc = function() return sv.chatDefaultChannelName end,
            setFunc = function(value)
                sv.chatDefaultChannelName = value
                local map = {
                    ["Say"] = CHAT_CHANNEL_SAY,
                    ["Group"] = CHAT_CHANNEL_PARTY,
                    ["Zone"] = CHAT_CHANNEL_ZONE,
                    ["Guild 1"] = CHAT_CHANNEL_GUILD_1,
                    ["Guild 2"] = CHAT_CHANNEL_GUILD_2,
                    ["Guild 3"] = CHAT_CHANNEL_GUILD_3,
                    ["Guild 4"] = CHAT_CHANNEL_GUILD_4,
                    ["Guild 5"] = CHAT_CHANNEL_GUILD_5,
                }
                sv.chatDefaultChannel = map[value]
            end,
            default = SUI.SavedVars.defaults.chatDefaultChannelName,
        },
    }
end

local function AttributeBarSettings()
    return {
        {
            type = "header",
            name = "Attribute Bar Settings",
        },
        {
            type = "dropdown",
            name = "Bar Layout",
            tooltip = "Choose the layout style for attribute bars:\n• Default - ESO's original centered layout\n• ShibUI - Horizontal spread layout\n• Pyramid - Health on top, Magicka and Stamina below\n• Stacked - All bars stacked vertically",
            choices = { "Default", "ShibUI", "Pyramid", "Stacked" },
            choicesValues = { "default", "shibui", "pyramid", "stacked" },
            getFunc = function() return sv.attributeBarLayout end,
            setFunc = function(layout)
                sv.attributeBarLayout = layout
                SUI.AttributeBar:ApplyLayout(layout)
            end,
            default = SUI.SavedVars.defaults.attributeBarLayout,
        },
        {
            type = "dropdown",
            name = "Bar Width",
            tooltip = "Choose Normal or Expanded for fixed width, or Default for dynamic width based on current stats.",
            choices = { "Default", "Normal", "Expanded" },
            choicesValues = { "default", "normal", "expanded" },
            getFunc = function() return sv.attributeBarSize end,
            setFunc = function(mode)
                sv.attributeBarSize = mode
                SUI.AttributeBar:ApplySize(mode)
            end,
            default = SUI.SavedVars.defaults.attributeBarSize,
        },
    }
end

local function ActionBarSettings()
    return {
        { 
            type = "header",
            name = "Action Bar",
        },
        {
            type = "checkbox",
            name = "Show Weapon Swap Icon",
            tooltip =  "Toggle the visibility of the weapon swap icon on the action bar.",
            getFunc = function() return sv.showWeaponSwap end,
            setFunc = function(value) 
                sv.showWeaponSwap = value 
                if SUI.ActionBar and SUI.ActionBar.ApplyWeaponSwapVisibility then
                    SUI.ActionBar:ApplyWeaponSwapVisibility()
                end
            end,
            default = SUI.SavedVars.defaults.showWeaponSwap,
        },
        {
            type = "checkbox",
            name =  "Show Keybindings",
            tooltip =  "Toggle the visibility of keybindings on the action bar.",
            getFunc = function() return sv.showKeybindings end,
            setFunc = function(value) 
                sv.showKeybindings = value 
                if SUI.ActionBar and SUI.ActionBar.ApplyKeybindingsVisibility then
                    SUI.ActionBar:ApplyKeybindingsVisibility()
                end
            end,
            default = SUI.SavedVars.defaults.showKeybindings,
        },
        {
            type = "checkbox",
            name = "Use Scaled Ultimate Slots",
            tooltip = "Toggle the use of scaled ultimate slots on the action bar.",
            getFunc = function() return sv.scaledUltimateButton end,
            setFunc = function(value) 
                sv.scaledUltimateButton = value 
                if SUI.ActionBar and SUI.ActionBar.ApplyUltimateButtonScaling then
                    SUI.ActionBar:ApplyUltimateButtonScaling()
                end
            end,
            default = SUI.SavedVars.defaults.scaledUltimateButton,
        },
    }
end

local function TargetBarSettings()
    return {
        {
            type = "header",
            name = "Target Bar",
        },
        {
            type = "checkbox",
            name = "Show Only Hostile Targets",
            tooltip = "Display only hostile targets on the target bar.",
            getFunc = function() return sv.showHostileOnly end,
            setFunc = function(value) sv.showHostileOnly = value end,
            default = SUI.SavedVars.defaults.showHostileOnly,
        },
    }
end

local function PlayerProgressBarSettings()
    return {
        {
            type = "header",
            name = "Player Progress Bar",
        },
        { 
            type = "checkbox",
            name = "Always Show Player Progress Bar",
            tooltip = "Keep the player progress bar visible at all times.",
            getFunc = function() return sv.showPlayerProgressBar end,
            setFunc = function(value)
                sv.showPlayerProgressBar = value 
                if SUI.PPB and SUI.PPB.Toggle then
                    SUI.PPB:Toggle()
                end
            end,
            default = SUI.SavedVars.defaults.showPlayerProgressBar,
        },
    }
end

--------------------------------------------------
-- Settings Panel Creation
--------------------------------------------------
local function SettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then
        Log("LibAddonMenu2 not found. Settings panel will not be created.")
        return
    end

    local panelData = {
        type                = "panel",
        name                = SUI.menuName,
        displayName         = SUI.displayName,
        author              = SUI.author,
        version             = SUI.version,
        slashCommand        = "/shibui",
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local optionsTable = {}
    local function appendOptions(tbl)
        for _, i in ipairs(tbl) do
            table.insert(optionsTable, i)
        end
    end

    appendOptions(GeneralSettings())
    appendOptions(ChatWindowSettings())
    appendOptions(AttributeBarSettings())
    appendOptions(ActionBarSettings())
    appendOptions(TargetBarSettings())
    appendOptions(PlayerProgressBarSettings())

    LAM:RegisterAddonPanel(SUI.menuName, panelData)
    LAM:RegisterOptionControls(SUI.menuName, optionsTable)
    Log("Settings panel created successfully")
end

--------------------------------------------------
-- Settings Initialization
--------------------------------------------------
function Settings:Initialize()
    sv = SUI.SavedVars.saved
    SettingsPanel()
end