MMOMB = {
    name = "MMOMouseBar", -- Matches folder and Manifest file names.
    version = "1.02", -- A nuisance to match to the Manifest.
    author = "DarkPhalanx",
    color = "DDFFEE", -- Used in menu titles and so on.
    menuName = "MMO Mouse Bar", -- A UNIQUE identifier for menu object.
}

function MMOMB.GetGuiRootWidth()
    local w, h = GuiRoot:GetDimensions()
    local w = math.floor(w / 2)
    return w
end

function MMOMB.GetGuiRootHeight()
    local w, h = GuiRoot:GetDimensions()
    local h = math.floor(h / 2)
    return h
end

-- Default settings.
MMOMB.savedVars = {
    firstLoad = true, -- First time the addon is loaded ever.
    accountWide = false, -- Load settings from account savedVars, instead of character.
    unlock = false,
    showButtonText = false,
    showActionBarBackground = false,
    preset = "Custom",
    presetXoffset = 0,
    presetYoffset = math.floor(MMOMB.GetGuiRootHeight() * 0.88),
    actionButtonPos = {
        { ActionButton3:GetLeft(), ActionButton3:GetTop() }, -- 1
        { ActionButton4:GetLeft(), ActionButton4:GetTop() }, -- 2
        { ActionButton5:GetLeft(), ActionButton5:GetTop() }, -- 3
        { ActionButton6:GetLeft(), ActionButton6:GetTop() }, -- 4
        { ActionButton7:GetLeft(), ActionButton7:GetTop() }, -- 5
        { ActionButton8:GetLeft(), ActionButton8:GetTop() }, -- Ultimate Button
        { ActionButton9:GetLeft(), ActionButton9:GetTop() }, -- Weapon Swap
    }
}

-- Functions.
-- Saves single button position
function MMOMB.ButtonSave(slotNum)

    local tableRowNr = slotNum - 2
    local OffsetX = _G['ActionButton' .. slotNum]:GetLeft()
    local OffsetY = _G['ActionButton' .. slotNum]:GetTop()

    -- Save X and Y in saved variables.
    MMOMB.savedVars.actionButtonPos[tableRowNr][1] = OffsetX
    MMOMB.savedVars.actionButtonPos[tableRowNr][2] = OffsetY
end

-- Saves all button positions
function MMOMB.ButtonSaveAll()

    for slotNum = 3, 9 do

        MMOMB.ButtonSave(slotNum)
    end
end

-- Unlocks or locks a single button.
function MMOMB.ButtonUnLock(slotNum, value)

    -- Directly save the button location when locked again.
    if (not value) then
        MMOMB.ButtonSave(slotNum)
    end

    _G['ActionButton' .. slotNum]:SetMovable(value)
    _G['ActionButton' .. slotNum]:SetMouseEnabled(value)
    _G['ActionButton' .. slotNum .. 'Button']:SetMouseEnabled(not value)
end

-- Unlocks or locks a single button.
function MMOMB.ButtonUnLockAll(value)

    -- Save setting
    MMOMB.savedVars.unlock = value
    if (value) then MMOMB.savedVars.preset = "Custom" end


    for slotNum = 3, 9 do
        MMOMB.ButtonUnLock(slotNum, value)
    end
end

-- Sets all buttons to their saved posistions.
function MMOMB.ButtonRestorePosition(slotNum)

    local tableRowNr = slotNum - 2
    local OffsetX = MMOMB.savedVars.actionButtonPos[tableRowNr][1]
    local OffsetY = MMOMB.savedVars.actionButtonPos[tableRowNr][2]

    _G['ActionButton' .. slotNum]:ClearAnchors()
    _G['ActionButton' .. slotNum]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, OffsetX, OffsetY)
end

-- Sets all buttons to their saved posistions.
function MMOMB.ButtonRestorePositionAll()

    for slotNum = 3, 9 do

        MMOMB.ButtonRestorePosition(slotNum)
    end
end

-- Hide or show button text.
function MMOMB.ShowButtonTextAll(setting)

    -- Save setting
    MMOMB.savedVars.showButtonText = setting

    local alpha = 0

    if (setting) then
        alpha = 1
    end

    for slotNum = 3, 9 do
        _G['ActionButton' .. slotNum .. 'ButtonText']:SetAlpha(alpha)
        _G['ActionButton' .. slotNum .. 'ButtonText']:SetHidden(not setting)
    end
end

-- Hide or show the black actionbar background.
function MMOMB.ShowActionBarBackground(setting)

    -- Save setting
    MMOMB.savedVars.showActionBarBackground = setting

    local alpha = 0

    if (setting) then
        alpha = 1
    end

    ZO_ActionBar1KeybindBG:SetAlpha(alpha)
    ZO_ActionBar1KeybindBG:SetHidden(not setting)
end

function MMOMB.preset1(x, y)
    -- Save offsets
    MMOMB.savedVars.presetXoffset = x
    MMOMB.savedVars.presetYoffset = y

    -- Everything is alligned to button 4, here we position button 4.
    ActionButton4:ClearAnchors()
    ActionButton4:SetAnchor(CENTER, GuiRoot, CENTER, x, y)

    -- These are alligned to button 4 (the middel one)
    ActionButton3:ClearAnchors()
    ActionButton3:SetAnchor(TOPRIGHT, ActionButton4, TOPLEFT, -2, 0)
    ActionButton5:ClearAnchors()
    ActionButton5:SetAnchor(TOPLEFT, ActionButton4, TOPRIGHT, 2, 0)
    ActionButton6:ClearAnchors()
    ActionButton6:SetAnchor(TOPRIGHT, ActionButton4, BOTTOMLEFT, -2, 2)
    ActionButton7:ClearAnchors()
    ActionButton7:SetAnchor(TOPLEFT, ActionButton4, BOTTOMLEFT, 0, 2)

    -- Weapon swap button.
    ActionButton8:ClearAnchors()
    ActionButton8:SetAnchor(LEFT, ActionButton5, RIGHT, 64, 24)

    -- Ultimate button
    ActionButton9:ClearAnchors()
    ActionButton9:SetAnchor(RIGHT, ActionButton3, LEFT, -64, 24)

    -- Actionbar text and beground for this preset.
    MMOMB.ShowButtonTextAll(false)

    MMOMB.ButtonSaveAll()
end

-- Only show the loading message on first load ever.
function MMOMB.Activated(e)
    EVENT_MANAGER:UnregisterForEvent(MMOMB.name, EVENT_PLAYER_ACTIVATED)

    if MMOMB.savedVars.firstLoad then
        MMOMB.savedVars.firstLoad = false
    end

    -- Init functions
    MMOMB.ShowButtonTextAll(MMOMB.savedVars.showButtonText)
    MMOMB.ShowActionBarBackground(MMOMB.savedVars.showActionBarBackground)
end

-- When player is ready, after everything has been loaded.
EVENT_MANAGER:RegisterForEvent(MMOMB.name, EVENT_PLAYER_ACTIVATED, MMOMB.Activated)

function MMOMB.OnAddOnLoaded(event, addonName)
    if addonName ~= MMOMB.name then return end
    EVENT_MANAGER:UnregisterForEvent(MMOMB.name, EVENT_ADD_ON_LOADED)

    -- Load saved variables.
    MMOMB.characterSavedVars = ZO_SavedVars:New("MMOMouseBarSavedVariables", 1, nil, MMOMB.savedVars)
    MMOMB.accountSavedVars = ZO_SavedVars:NewAccountWide("MMOMouseBarSavedVariables", 1, nil, MMOMB.savedVars)

    if not MMOMB.characterSavedVars.accountWide then
        MMOMB.savedVars = MMOMB.characterSavedVars
    else
        MMOMB.savedVars = MMOMB.accountSavedVars
    end

    -- Settings menu in Settings.lua.
    MMOMB.LoadSettings()

    -- Init functions
    MMOMB.ButtonRestorePositionAll()
    MMOMB.ButtonUnLockAll(MMOMB.savedVars.unlock)

    -- Slash commands must be lowercase!!! Set to nil to disable.
    SLASH_COMMANDS["/mmomb"] = nil

    -- The following is only needed when changing SLASH_COMMANDS live,
    -- but not when loading addons, starting with 100030.
    -- CHAT_SYSTEM.textEntry.slashCommandAutoComplete:InvalidateSlashCommandCache()
end

-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(MMOMB.name, EVENT_ADD_ON_LOADED, MMOMB.OnAddOnLoaded)