local ADDON_NAME = "GroupLoot"
local ADDON_VERSION = "0.9.7"

local LAM2 = LibStub("LibAddonMenu-2.0")
if not LAM2 then return end

GroupLootSettings = ZO_Object:Subclass()

local settings = nil

function GroupLootSettings:New()
    local obj = ZO_Object.New(self)
    obj:Initialize()
    return obj
end

function GroupLootSettings:Initialize()
    local GroupLootDefaults = {
        displayGold         = true,
        displayTrash        = false, -- Grey
        displayNormal       = true, -- White
        displayMagic        = true, -- Green
        displayArcane       = true, -- Blue
        displayArtifact     = true, -- Purple
        displayLegendary    = true, -- Yellow
        displayOnWindow     = true,
        displayOnChat       = true,
        displayOwnLoot      = true,
        displayGroupLoot    = true,
        displaySetItems     = false,
        positionLeft        = nil,
        positionTop         = nil,
        displayLootValue    = false,
        manualHighscoreReset = true,
    }

    --
    settings = ZO_SavedVars:New(ADDON_NAME .. "_db", 2, nil, GroupLootDefaults)
    -- 
    if not settings.displayOnWindow then GroupLootWindow:SetHidden(not settings.displayOnWindow) end
    local sceneFragment = ZO_HUDFadeSceneFragment:New(GroupLootWindow)
    sceneFragment:SetConditional(function() return settings.displayOnWindow end)
    HUD_SCENE:AddFragment(sceneFragment)
    HUD_UI_SCENE:AddFragment(sceneFragment)
    --

    if settings.displayOnWindow then
        self:SetWindowValues()
    end

    local panelData = {
        type = "panel",
        name = ADDON_NAME,
        displayName = ZO_HIGHLIGHT_TEXT:Colorize("Group Loot"),
        author = "Temeez",
        version = ADDON_VERSION,
        slashCommand = "/grouploot",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM2:RegisterAddonPanel(ADDON_NAME .. "Panel", panelData)

    local optionsTable = {
        {
            type = "header",
            name = "Display and Count",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Own loot",
            tooltip = "Show or hide loot the loot you get.",
            getFunc = function() return settings.displayOwnLoot end,
            setFunc = function(value) self:ToggleOwnLoot(value) end,
            width = "full",
            default = GroupLootDefaults.displayOwnLoot,
        },
        {
            type = "checkbox",
            name = "Group loot",
            tooltip = "Show or hide the loot group members get.",
            getFunc = function() return settings.displayGroupLoot end,
            setFunc = function(value) self:ToggleGroupLoot(value) end,
            width = "full",
            default = GroupLootDefaults.displayGroupLoot,
        },
        {
            type = "checkbox",
            name = "Loot value",
            tooltip = "Show or hide loot value on chat/window.",
            getFunc = function() return settings.displayLootValue end,
            setFunc = function(value) self:ToggleLootValue(value) end,
            width = "full",
            default = GroupLootDefaults.displayLootValue,
        },
        {
            type = "checkbox",
            name = "Trash",
            tooltip = "Show or hide trash (grey) items on loot.",
            getFunc = function() return settings.displayTrash end,
            setFunc = function(value) self:ToggleTrash(value) end,
            width = "full",
            default = GroupLootDefaults.displayTrash
        },
        {
            type = "checkbox",
            name = "Normal",
            tooltip = "Show or hide normal (white) items on loot.",
            getFunc = function() return settings.displayNormal end,
            setFunc = function(value) self:ToggleNormal(value) end,
            width = "full",
            default = GroupLootDefaults.displayNormal
        },
        {
            type = "checkbox",
            name = "Magic",
            tooltip = "Show or hide magic (green) items on loot.",
            getFunc = function() return settings.displayMagic end,
            setFunc = function(value) self:ToggleMagic(value) end,
            width = "full",
            default = GroupLootDefaults.displayMagic
        },
        {
            type = "checkbox",
            name = "Arcane",
            tooltip = "Show or hide arcane (blue) items on loot.",
            getFunc = function() return settings.displayArcane end,
            setFunc = function(value) self:ToggleArcane(value) end,
            width = "full",
            default = GroupLootDefaults.displayArcane
        },
        {
            type = "checkbox",
            name = "Artifact",
            tooltip = "Show or hide artifact (purple) items on loot.",
            getFunc = function() return settings.displayArtifact end,
            setFunc = function(value) self:ToggleArtifact(value) end,
            width = "full",
            default = GroupLootDefaults.displayArtifact
        },
        {
            type = "checkbox",
            name = "Legendary",
            tooltip = "Show or hide legendary (yellow) items on loot.",
            getFunc = function() return settings.displayLegendary end,
            setFunc = function(value) self:ToggleLegendary(value) end,
            width = "full",
            default = GroupLootDefaults.displayLegendary
        },

        {
            type = "header",
            name = "Display Settings",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Display set items only",
            tooltip = "Show or hide set item loot.",
            getFunc = function() return settings.displaySetItems end,
            setFunc = function(value) self:ToggleSetItems(value) end,
            width = "full",
            default = GroupLootDefaults.displaySetItems
        },
        {
            type = "checkbox",
            name = "Display on chat",
            tooltip = "Show or hide loot on chat.",
            getFunc = function() return settings.displayOnChat end,
            setFunc = function(value) self:ToggleOnChat(value) end,
            width = "full",
            default = GroupLootDefaults.displayOnChat
        },
        {
            type = "checkbox",
            name = "Display on window",
            tooltip = "Show or hide loot on the window.",
            getFunc = function() return settings.displayOnWindow end,
            setFunc = function(value) self:ToggleOnWindow(value) end,
            width = "full",
            default = GroupLootDefaults.displayOnWindow,
        },
    }

    LAM2:RegisterOptionControls(ADDON_NAME .. "Panel", optionsTable)
end

function GroupLootSettings:GetSettings()
    return settings
end

function GroupLootSettings:DisplayInChat()
    return settings.displayOnChat
end

function GroupLootSettings:DisplayOwnLoot()
    return settings.displayOwnLoot
end

function GroupLootSettings:DisplayGroupLoot()
    return settings.displayGroupLoot
end

function GroupLootSettings:DisplayLootValue()
    return settings.displayLootValue
end

function GroupLootSettings:DisplaySetItems()
    return settings.displaySetItems
end

--[[
    UI functions

    piste -> : ? tesm
]]--
function GroupLootSettings:MoveStart()
    GroupLootWindowBG:SetAlpha(0.5)
    GroupLootWindowBuffer:ShowFadedLines()
end

function GroupLootSettings:MoveStop()
    GroupLootWindowBG:SetAlpha(0)
    settings.positionLeft = math.floor(GroupLootWindow:GetLeft())
    settings.positionTop = math.floor(GroupLootWindow:GetTop())
end

function GroupLootSettings:SetWindowValues()
    local left  = settings.positionLeft
    local top   = settings.positionTop

    GroupLootWindow:ClearAnchors()
    GroupLootWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    GroupLootWindow:SetAlpha(0.5)
    GroupLootWindowBG:SetAlpha(0)
    GroupLootWindow:SetHidden(false)

    GroupLootWindowBuffer:ClearAnchors()
    GroupLootWindowBuffer:SetAnchor(TOP, GroupLootWindow, TOP, 0, 0)
    GroupLootWindowBuffer:SetWidth(400)
    GroupLootWindowBuffer:SetHeight(80)

    --use the same font as in chat window
    local face = ZoFontEditChat:GetFontInfo()
    local fontSize = GetChatFontSize()
    local decoration = (fontSize <= 14 and "soft-shadow-thin" or "soft-shadow-thick")
    GroupLootWindowBuffer:SetFont(zo_strjoin("|", face, fontSize, decoration))
end

--[[
    Addon menu functions
]]--
function GroupLootSettings:ToggleTrash(value)
    settings.displayTrash = value
end

function GroupLootSettings:ToggleNormal(value)
    settings.displayNormal = value
end

function GroupLootSettings:ToggleMagic(value)
    settings.displayMagic = value
end

function GroupLootSettings:ToggleArcane(value)
    settings.displayArcane = value
end

function GroupLootSettings:ToggleArtifact(value)
    settings.displayArtifact = value
end

function GroupLootSettings:ToggleLegendary(value)
    settings.displayLegendary = value
end

function GroupLootSettings:ToggleOnChat(value)
    settings.displayOnChat = value
end

function GroupLootSettings:ToggleOnWindow(value)
    settings.displayOnWindow = value
    if value then self:SetWindowValues() end
end

function GroupLootSettings:ToggleSetItems(value)
    settings.displaySetItems = value
end

function GroupLootSettings:ToggleOwnLoot(value)
    settings.displayOwnLoot = value
end

function GroupLootSettings:ToggleGroupLoot(value)
    settings.displayGroupLoot = value
end

function GroupLootSettings:ToggleLootValue(value)
    settings.displayLootValue = value
end