--[[--------------------------------------------------------------------
    Whisper Notifier Addon (v1.0.1)
    - Initial public release + minor fixes
----------------------------------------------------------------------]]

-- Constants
local ADDON_NAME = "WhisperNotifier"
local ADDON_VERSION = "1.0.1"
local MAX_VISIBLE_NOTIFICATIONS = 20
local VERTICAL_PADDING = 5
local MIN_DRAG_HEIGHT = 30
local FRAME_WIDTH = 900
local FRAME_HEIGHT = 30

-- Addon Object / Namespace
local WhisperNotifier = {}
local WN = WhisperNotifier

-- Font list and default index
local availableFonts = { "ZoFontWinH7", "ZoFontWinH6", "ZoFontWinH5", "ZoFontWinH4", "ZoFontWinH3", "ZoFontWinH2", "ZoFontWinH1" }
local defaultFontSizeIndex = 4 -- Default to ZoFontWinH4

-- Saved Variables (defaults)
local defaultSavedVars = {
    position = { left = 1120, top = 110 },
    displayDuration = 5.0,
    fadeDuration = 1.0,
    maxNotifications = 20,
    verticalPadding = 5,
    fontColorR = 0, fontColorG = 1, fontColorB = 1, -- Cyan default
    fontSizeIndex = defaultFontSizeIndex,
}
local savedVars

-- Session State
local isLocked = true

-- UI Elements & State
local baseControl = nil
local baseBackground = nil
local controlPool = {}
local activeDisplayOrder = {}
local fadeStates = {}
local fadeDelayUpdateNameBase = ADDON_NAME .. "_FadeDelayTimer_"
local controlNameMap = {}

------------------------------------------------------------------------
-- Helper Functions
------------------------------------------------------------------------
local function GetMaxNotifications() return savedVars and savedVars.maxNotifications or defaultSavedVars.maxNotifications end
local function GetFadeDuration() return savedVars and savedVars.fadeDuration or defaultSavedVars.fadeDuration end
local function GetDisplayDuration() return savedVars and savedVars.displayDuration or defaultSavedVars.displayDuration end
local function GetVerticalPadding() return savedVars and savedVars.verticalPadding or defaultSavedVars.verticalPadding end

local function GetFontNameFromSavedIndex()
    local index = (savedVars and savedVars.fontSizeIndex) or defaultFontSizeIndex
    if type(index) ~= "number" or index < 1 or index > #availableFonts then
        index = defaultFontSizeIndex
        if savedVars then savedVars.fontSizeIndex = index end
    end
    return availableFonts[index]
end

local function GetInactiveControlPoolIndex()
    local maxToCheck = GetMaxNotifications()
    for i = 1, maxToCheck do
        if controlPool[i] and not controlPool[i].active then return i end
    end
    return nil
end

function WhisperNotifier:ApplyFontSettings()
    if not savedVars then return end
    local fontName = GetFontNameFromSavedIndex()
    if not fontName then return end
    local maxToCheck = GetMaxNotifications()
    for i=1, maxToCheck do
        if controlPool[i] and controlPool[i].label then
            controlPool[i].label:SetFont(fontName)
        end
    end
end

function WhisperNotifier:ApplyColorSettings()
    if not savedVars then return end
    local r = savedVars.fontColorR
    local g = savedVars.fontColorG
    local b = savedVars.fontColorB
    for _, poolIndex in ipairs(activeDisplayOrder) do
        local entry = controlPool[poolIndex]
        if entry and entry.label then
            entry.label:SetColor(r, g, b, 1)
        end
    end
end

--[[ Updates positions and BASE CONTROL height - Anchoring all to base ]]--
local function UpdatePositions()
    if not baseControl then return end
    local currentYOffset = 0
    local padding = GetVerticalPadding()
    local totalHeight = 0
    local numActive = #activeDisplayOrder
    local frameHeight = FRAME_HEIGHT -- Use fixed height

    for i, poolIndex in ipairs(activeDisplayOrder) do
        local entry = controlPool[poolIndex]
        if entry and entry.frame then
            entry.frame:ClearAnchors()
            -- Anchor TOPLEFT and TOPRIGHT directly to baseControl
            entry.frame:SetAnchor(TOPLEFT, baseControl, TOPLEFT, 0, currentYOffset)
            entry.frame:SetAnchor(TOPRIGHT, baseControl, TOPRIGHT, 0, currentYOffset)

            currentYOffset = currentYOffset + frameHeight + padding
            totalHeight = currentYOffset - padding
            if i == numActive then totalHeight = currentYOffset - padding end
        else
             d(string.format("%s: Error in UpdatePositions - Invalid entry at index %d (poolIndex %s)", ADDON_NAME, i, tostring(poolIndex)))
        end
    end

    local newBaseHeight = totalHeight
    if not isLocked then
        newBaseHeight = math.max(MIN_DRAG_HEIGHT, totalHeight)
    elseif numActive == 0 then
        newBaseHeight = 1
    end
    if baseControl:GetHeight() ~= newBaseHeight then
        baseControl:SetHeight(newBaseHeight)
    end
    if baseBackground then baseBackground:SetAnchorFill(baseControl) end
end

local function StopFade(poolIndex)
    if not poolIndex then return end
    local entry = controlPool[poolIndex]
    if not entry then return end
    local delayTimerName = fadeDelayUpdateNameBase .. poolIndex
    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        EVENT_MANAGER:UnregisterForUpdate(delayTimerName)
    end
    if entry.fadeState then
        entry.fadeState.loopActive = false
    end
end

local FadeOutLoop -- Forward declare

local function StartFadeOut(poolIndex)
     local entry = controlPool[poolIndex]
     local fadeDuration = GetFadeDuration()
     if not entry or not entry.frame or not entry.fadeState or not entry.fadeFunc or entry.frame:IsControlHidden() then
         if entry and entry.fadeState then entry.fadeState.loopActive = false end
         return
     end
     entry.fadeState.remainingDuration = fadeDuration
     entry.fadeState.duration = fadeDuration
     entry.fadeState.loopActive = true
     entry.fadeFunc()
end

-- Define FadeOutLoop logic used by closures created in Initialize
FadeOutLoop = function(fadeState, frame, poolIndex)
    if not fadeState.loopActive or not frame or frame:IsControlHidden() then
        fadeState.loopActive = false; return
    end
    local frameDelta = GetFrameDeltaTimeSeconds()
    fadeState.remainingDuration = math.max(0, fadeState.remainingDuration - frameDelta)
    local progress = 1 - (fadeState.remainingDuration / fadeState.duration)
    local newAlpha = 1 - progress
    frame:SetAlpha(newAlpha)
    if fadeState.remainingDuration <= 0.1 then
        frame:SetHidden(true)
        if controlPool[poolIndex] then controlPool[poolIndex].active = false end
        for j = #activeDisplayOrder, 1, -1 do
            if activeDisplayOrder[j] == poolIndex then table.remove(activeDisplayOrder, j); break end
        end
        fadeState.loopActive = false
        frame:SetAlpha(1)
    else
        if fadeState.loopActive then
            local entry = controlPool[poolIndex]
            if entry and entry.fadeFunc then zo_callLater(entry.fadeFunc, 1) end
        end
    end
end

function WhisperNotifier:ShowNotification(sender)
    local poolIndex = GetInactiveControlPoolIndex()
    if not poolIndex then return end

    local entry = controlPool[poolIndex]
    if not entry or not entry.frame or not entry.label then return end

    StopFade(poolIndex)

    entry.active = true
    local formattedMessage = string.format("%s sent you a private message!", sender)
    entry.label:SetText(formattedMessage)
    entry.label:SetFont(GetFontNameFromSavedIndex())

    entry.frame:SetHidden(false)
    entry.frame:SetAlpha(1)

    if isLocked then
        entry.label:SetColor(savedVars.fontColorR, savedVars.fontColorG, savedVars.fontColorB, 1)
    else
        entry.label:SetColor(1, 1, 0, 1)
    end

    for i = #activeDisplayOrder, 1, -1 do
        if activeDisplayOrder[i] == poolIndex then table.remove(activeDisplayOrder, i); break end
    end
    table.insert(activeDisplayOrder, 1, poolIndex)
    UpdatePositions() -- Position AFTER setting active

    local delayTimerName = fadeDelayUpdateNameBase .. poolIndex
    local displayDuration = GetDisplayDuration()
    if EVENT_MANAGER and type(EVENT_MANAGER.RegisterForUpdate) == "function" then
        local startFadeCallback = function() StartFadeOut(poolIndex) end
        EVENT_MANAGER:RegisterForUpdate(delayTimerName, displayDuration * 1000, startFadeCallback)
    else
         d(ADDON_NAME .. ": Error - EVENT_MANAGER or RegisterForUpdate missing.")
    end
end

------------------------------------------------------------------------
-- UI Setup and Event Handlers
------------------------------------------------------------------------

function WhisperNotifier:UpdateLockState(newState)
    isLocked = newState
    if baseControl then
        baseControl:SetMovable(not isLocked)
        baseControl:SetMouseEnabled(not isLocked)
    end
    if baseBackground then
        if not isLocked then
            baseBackground:SetCenterColor(0.2, 0.2, 0.2, 1.0)
            baseBackground:SetEdgeColor(1, 1, 0, 1.0)
        else
            baseBackground:SetCenterColor(0, 0, 0, 0)
            baseBackground:SetEdgeColor(0, 0, 0, 0)
        end
    end
    if savedVars then
        local r = savedVars.fontColorR
        local g = savedVars.fontColorG
        local b = savedVars.fontColorB
        for _, poolIndex in ipairs(activeDisplayOrder) do
             local entry = controlPool[poolIndex]
             if entry and entry.label then
                 if isLocked then entry.label:SetColor(r, g, b, 1) else entry.label:SetColor(1, 1, 0, 1) end
             end
        end
    end
    UpdatePositions()
end

local function OnBaseControlMoveStop(control)
    if control == baseControl and savedVars and not isLocked then
        local left = baseControl:GetLeft()
        local top = baseControl:GetTop()
        savedVars.position.left = left
        savedVars.position.top = top
    end
end

local function OnChatMessageReceived(eventCode, channelType, senderName, message, ...)
    if channelType == CHAT_CHANNEL_WHISPER then
        WhisperNotifier:ShowNotification(senderName)
    end
end

local function RegisterSlashCommands()
    if SLASH_COMMANDS["/testwhisper"] then return end
    SLASH_COMMANDS["/testwhisper"] = function(inputText)
        local sender = inputText and inputText ~= "" and inputText or "TestSender"
        WhisperNotifier:ShowNotification(sender)
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
end

local function Initialize()
    savedVars = ZO_SavedVars:NewAccountWide(ADDON_NAME .. "_SavedVars", 1, nil, defaultSavedVars)
    WhisperNotifier.savedVars = savedVars
    WhisperNotifier.defaultSavedVars = defaultSavedVars
    isLocked = true

    if not savedVars.position or type(savedVars.position.left) ~= "number" or type(savedVars.position.top) ~= "number" then
        d(ADDON_NAME .. ": Warning - Invalid saved position data format. Resetting to defaults.")
        savedVars.position = zo_deepcopy(defaultSavedVars.position)
    end

    baseControl = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "Base")
    baseControl:SetWidth(FRAME_WIDTH)
    baseControl:SetHeight(1)
    baseControl:SetHidden(false)
    baseControl:SetClampedToScreen(true)
    baseControl:SetMouseEnabled(not isLocked)
    baseControl:SetMovable(not isLocked)
    baseControl:SetHandler("OnMoveStop", OnBaseControlMoveStop)

    baseBackground = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "BaseBackground", baseControl, CT_BACKDROP)
    baseBackground:SetAnchorFill(baseControl)
    baseBackground:SetDrawTier(DT_LOW)
    baseBackground:SetMouseEnabled(false)
    baseBackground:SetCenterColor(0,0,0,0)
    baseBackground:SetEdgeColor(0,0,0,0)

    local success, errorMsg = pcall(baseControl.SetAnchor, baseControl, TOPLEFT, GuiRoot, TOPLEFT, savedVars.position.left, savedVars.position.top)
    if not success then
         d(string.format("%s: Error setting initial anchor! %s. Resetting.", ADDON_NAME, tostring(errorMsg)))
         baseControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, defaultSavedVars.position.left, defaultSavedVars.position.top)
    end

    controlPool = {}
    activeDisplayOrder = {}
    controlNameMap = {}
    local maxNotificationsToCreate = GetMaxNotifications()
    local currentFontName = GetFontNameFromSavedIndex()
    local fadeOutDuration = GetFadeDuration()

    for i = 1, maxNotificationsToCreate do
        local frameName = ADDON_NAME .. "DisplayFrame" .. i
        local labelName = ADDON_NAME .. "DisplayLabel" .. i
        local frame = WINDOW_MANAGER:CreateControl(frameName, baseControl, CT_CONTROL)
        frame:SetDimensions(FRAME_WIDTH, FRAME_HEIGHT)
        frame:SetHidden(true)
        frame:SetMouseEnabled(false)
        frame:SetMovable(false)

        local label = WINDOW_MANAGER:CreateControl(labelName, frame, CT_LABEL)
        label:SetAnchor(TOPLEFT, frame, TOPLEFT, 5, 5)
        label:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -5, -5)
        label:SetFont(currentFontName)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetColor(savedVars.fontColorR, savedVars.fontColorG, savedVars.fontColorB, 1)
        label:SetText("")

        local poolIndex = i
        local fadeState = { remainingDuration = 0, duration = fadeOutDuration, loopActive = false }
        local loopFunc = nil
        loopFunc = function()
            local currentEntry = controlPool[poolIndex]
            if not currentEntry then return end
            local currentFrame = currentEntry.frame
            local currentFadeState = currentEntry.fadeState
            if not currentFadeState.loopActive or not currentFrame or currentFrame:IsControlHidden() then
                currentFadeState.loopActive = false; return
            end
            local frameDelta = GetFrameDeltaTimeSeconds()
            currentFadeState.remainingDuration = math.max(0, currentFadeState.remainingDuration - frameDelta)
            local progress = 1 - (currentFadeState.remainingDuration / currentFadeState.duration)
            local newAlpha = 1 - progress
            currentFrame:SetAlpha(newAlpha)
            if currentFadeState.remainingDuration <= 0.1 then
                currentFrame:SetHidden(true)
                if controlPool[poolIndex] then controlPool[poolIndex].active = false end
                for j = #activeDisplayOrder, 1, -1 do
                    if activeDisplayOrder[j] == poolIndex then table.remove(activeDisplayOrder, j); break end
                end
                currentFadeState.loopActive = false
                currentFrame:SetAlpha(1)
            else
                if currentFadeState.loopActive then zo_callLater(loopFunc, 1) end
            end
        end

        controlPool[i] = { frame = frame, label = label, active = false, poolIndex = i, fadeFunc = loopFunc, fadeState = fadeState }
        controlNameMap[frameName] = controlPool[i]
    end

    WN:UpdateLockState(isLocked)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessageReceived)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, RegisterSlashCommands)

    d(ADDON_NAME .. " v" .. ADDON_VERSION .. " Initialized.")
end

local function OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        _G[ADDON_NAME] = WhisperNotifier
        WhisperNotifier.UpdateLockState = WN.UpdateLockState
        WhisperNotifier.ApplyColorSettings = WN.ApplyColorSettings
        WhisperNotifier.ApplyFontSettings = WN.ApplyFontSettings
        WhisperNotifier.UpdatePositions = UpdatePositions
        WhisperNotifier.isLocked = isLocked

        Initialize()
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
end

------------------------------------------------------------------------
-- Event Registration and Global Assignment
------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)