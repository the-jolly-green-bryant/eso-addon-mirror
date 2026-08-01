local ADDON_NAME = "BoostTimer"
local DISPLAY_NAME = "Aldren's Timers"
local UPDATE_INTERVAL_MS = 1000
local MINIMUM_REMAINING_SECONDS = 300
local MAX_VISIBLE_TIMERS = 3
local SHARE_DIALOG_NAME = "ALDRENS_TIMERS_SHARE_DIALOG"
local SHARE_CHAT_MESSAGE = "Stop opening menus just to check your buff timers! Aldren's Timers keeps your food, drinks, potions, and scrolls visible right on your screen. Give it a try!"

local defaults = {
    offsetX = 480,
    offsetY = 175,
    width = 440,
    height = 120,
    fontSize = 24,
    hideInMenus = true,
}

local savedVariables
local timerWindow
local timerLabel
local visibleTimerRows = 1

local function RefreshPanelVisibility()
    if not timerWindow or not savedVariables then
        return
    end

    local shouldHide = savedVariables.hideInMenus and IsGameCameraUIModeActive()
    timerWindow:SetHidden(shouldHide)
end

local function FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = seconds % 60

    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, remainingSeconds)
    end

    return string.format("%d:%02d", minutes, remainingSeconds)
end

local function GetFriendlySourceName(effectName)
    local normalizedName = string.lower(effectName or "")

    if string.find(normalizedName, "potion", 1, true)
        or string.find(normalizedName, "elixir", 1, true)
        or string.find(normalizedName, "draught", 1, true)
        or string.find(normalizedName, "tincture", 1, true) then
        return "Potion"
    end

    if string.find(normalizedName, "scroll", 1, true)
        or string.find(normalizedName, "experience boost", 1, true)
        or string.find(normalizedName, "alliance point boost", 1, true)
        or string.find(normalizedName, "inspiration boost", 1, true) then
        return "Scroll"
    end

    if string.find(normalizedName, "event", 1, true)
        or string.find(normalizedName, "festival", 1, true) then
        return "Event"
    end

    if string.find(normalizedName, "recovery", 1, true) then
        return "Drink"
    end

    if string.find(normalizedName, "increase max", 1, true)
        or string.find(normalizedName, "max health", 1, true)
        or string.find(normalizedName, "max magicka", 1, true)
        or string.find(normalizedName, "max stamina", 1, true) then
        return "Food"
    end

    return "Other"
end

local function GetTimedBoosts()
    local boosts = {}
    local now = GetFrameTimeSeconds()
    local buffCount = GetNumBuffs("player")

    for buffIndex = 1, buffCount do
        local buffName, _, timeEnding = GetUnitBuffInfo("player", buffIndex)

        if buffName and buffName ~= "" and timeEnding and timeEnding > now then
            local remaining = timeEnding - now

            if remaining >= MINIMUM_REMAINING_SECONDS then
                boosts[#boosts + 1] = {
                    name = buffName,
                    remaining = remaining,
                }
            end
        end
    end

    table.sort(boosts, function(left, right)
        return left.remaining < right.remaining
    end)

    return boosts
end

local function GetAutomaticPanelHeight()
    local extraRows = math.max(0, visibleTimerRows - 1)
    local rowHeight = savedVariables.fontSize + 8
    return savedVariables.height + (extraRows * rowHeight)
end

local function ApplyPanelSettings()
    if not timerWindow or not timerLabel then
        return
    end

    timerWindow:ClearAnchors()
    timerWindow:SetAnchor(TOP, GuiRoot, TOP, savedVariables.offsetX, savedVariables.offsetY)
    timerWindow:SetDimensions(savedVariables.width, GetAutomaticPanelHeight())
    timerLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", savedVariables.fontSize))
end

local function UpdateTimerDisplay()
    local boosts = GetTimedBoosts()

    if #boosts == 0 then
        visibleTimerRows = 1
        timerLabel:SetText("No timed boosts found")
        ApplyPanelSettings()
        return
    end

    local lines = {}
    local visibleCount = math.min(#boosts, MAX_VISIBLE_TIMERS)
    visibleTimerRows = visibleCount

    for index = 1, visibleCount do
        local boost = boosts[index]
        lines[#lines + 1] = string.format("%s  %s", GetFriendlySourceName(boost.name), FormatTime(boost.remaining))
    end

    timerLabel:SetText(table.concat(lines, "\n"))
    ApplyPanelSettings()
end

local function ResetPanelSettings()
    savedVariables.offsetX = defaults.offsetX
    savedVariables.offsetY = defaults.offsetY
    savedVariables.width = defaults.width
    savedVariables.height = defaults.height
    savedVariables.fontSize = defaults.fontSize
    ApplyPanelSettings()
end

local function ApplyShareDialogFonts(dialog)
    if not dialog then
        return
    end

    local titleControl = dialog:GetNamedChild("Title")
    if titleControl then
        titleControl:SetFont("$(BOLD_FONT)|36|soft-shadow-thick")
    end

    local textControl = dialog:GetNamedChild("Text")
    if textControl then
        textControl:SetFont("$(BOLD_FONT)|32|soft-shadow-thick")
    end

    for buttonIndex = 1, 2 do
        local buttonControl = dialog:GetNamedChild("Button" .. buttonIndex)
        local buttonLabel = buttonControl and buttonControl:GetNamedChild("NameLabel")
        local keyLabel = buttonControl and buttonControl:GetNamedChild("KeyLabel")

        if buttonLabel then
            buttonLabel:SetFont("$(BOLD_FONT)|30|soft-shadow-thick")
        end

        if keyLabel then
            keyLabel:SetFont("$(GAMEPAD_MEDIUM_FONT)|34|soft-shadow-thick")
        end
    end
end

local function SafeStartChatInput(text, channel, target)
    local isRestrictedCommunicationPermitted = true

    if target ~= nil and IsCommunicationRestricted() then
        isRestrictedCommunicationPermitted = CanCommunicateWith(target)
    end

    if IsChatSystemAvailableForCurrentPlatform() and isRestrictedCommunicationPermitted then
        ZO_GetChatSystem():StartTextEntry(text, channel, target, true)
    end
end

local function OpenShareChatFromGameplay()
    local attempts = 0

    SCENE_MANAGER:ShowBaseScene()

    local function TryOpenChat()
        attempts = attempts + 1

        if not IsGameCameraUIModeActive() then
            SafeStartChatInput(SHARE_CHAT_MESSAGE, CHAT_CHANNEL_ZONE)
            return
        end

        if attempts < 20 then
            zo_callLater(TryOpenChat, 100)
        end
    end

    zo_callLater(TryOpenChat, 100)
end

local function ShowShareDialog()
    if not ESO_Dialogs[SHARE_DIALOG_NAME] then
        ESO_Dialogs[SHARE_DIALOG_NAME] = {
            canQueue = true,
            title = {
                text = "Share Aldren's Timers?",
            },
            mainText = {
                text = "This will post a recommendation in Zone Chat.",
            },
            buttons = {
                [1] = {
                    text = "Yes",
                    callback = OpenShareChatFromGameplay,
                },
                [2] = {
                    text = "No",
                },
            },
        }
    end

    local dialog = ZO_Dialogs_ShowDialog(SHARE_DIALOG_NAME)
    ApplyShareDialogFonts(dialog)
end

local function CreateSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local panelData = {
        type = "panel",
        name = DISPLAY_NAME,
        displayName = DISPLAY_NAME,
        author = "Aldren Project",
        version = "0.0.14",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "description",
            text = "Move and resize the timer panel. Changes appear immediately.",
        },
        {
            type = "checkbox",
            name = "Hide While Menus Are Open",
            tooltip = "Hides the timer panel while inventory, craft bag, map, settings, and other pause-style menus are open.",
            getFunc = function() return savedVariables.hideInMenus end,
            setFunc = function(value)
                savedVariables.hideInMenus = value
                RefreshPanelVisibility()
            end,
            default = defaults.hideInMenus,
        },
        {
            type = "slider",
            name = "Horizontal Position",
            tooltip = "Moves the timer panel left or right.",
            min = -900,
            max = 900,
            step = 10,
            getFunc = function() return savedVariables.offsetX end,
            setFunc = function(value)
                savedVariables.offsetX = value
                ApplyPanelSettings()
            end,
            default = defaults.offsetX,
        },
        {
            type = "slider",
            name = "Vertical Position",
            tooltip = "Moves the timer panel up or down.",
            min = 0,
            max = 900,
            step = 10,
            getFunc = function() return savedVariables.offsetY end,
            setFunc = function(value)
                savedVariables.offsetY = value
                ApplyPanelSettings()
            end,
            default = defaults.offsetY,
        },
        {
            type = "slider",
            name = "Panel Width",
            tooltip = "Changes the width of the timer panel.",
            min = 240,
            max = 900,
            step = 10,
            getFunc = function() return savedVariables.width end,
            setFunc = function(value)
                savedVariables.width = value
                ApplyPanelSettings()
            end,
            default = defaults.width,
        },
        {
            type = "slider",
            name = "Minimum Panel Height",
            tooltip = "Sets the one-row panel height. The panel grows downward automatically when more timers appear.",
            min = 60,
            max = 400,
            step = 10,
            getFunc = function() return savedVariables.height end,
            setFunc = function(value)
                savedVariables.height = value
                ApplyPanelSettings()
            end,
            default = defaults.height,
        },
        {
            type = "slider",
            name = "Text Size",
            tooltip = "Changes the timer text size.",
            min = 16,
            max = 44,
            step = 1,
            getFunc = function() return savedVariables.fontSize end,
            setFunc = function(value)
                savedVariables.fontSize = value
                ApplyPanelSettings()
            end,
            default = defaults.fontSize,
        },
        {
            type = "button",
            name = "Reset Position and Size",
            tooltip = "Returns the timer panel to the tested default position and size.",
            func = ResetPanelSettings,
            width = "half",
        },
        {
            type = "button",
            name = "Share Aldren's Timers",
            tooltip = "Prepares a recommendation in Zone Chat for you to send.",
            func = ShowShareDialog,
            width = "half",
        },
    }

    local panel = LAM:RegisterAddonPanel("AldrensTimersSettingsPanel", panelData)
    LAM:RegisterOptionControls("AldrensTimersSettingsPanel", optionsData)
end

local function CreateTimerWindow()
    timerWindow = WINDOW_MANAGER:CreateTopLevelWindow("BoostTimerWindow")
    timerWindow:SetMouseEnabled(false)
    timerWindow:SetClampedToScreen(true)

    local background = WINDOW_MANAGER:CreateControl("BoostTimerBackground", timerWindow, CT_BACKDROP)
    background:SetAnchorFill(timerWindow)
    background:SetCenterColor(0, 0, 0, 0.65)
    background:SetEdgeColor(1, 1, 1, 0.30)
    background:SetEdgeTexture(nil, 1, 1, 1)

    timerLabel = WINDOW_MANAGER:CreateControl("BoostTimerLabel", timerWindow, CT_LABEL)
    timerLabel:SetAnchor(TOPLEFT, timerWindow, TOPLEFT, 14, 12)
    timerLabel:SetAnchor(BOTTOMRIGHT, timerWindow, BOTTOMRIGHT, -14, -12)
    timerLabel:SetColor(1, 1, 1, 1)
    timerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    timerLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    ApplyPanelSettings()
    RefreshPanelVisibility()
    UpdateTimerDisplay()
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "TimerUpdate", UPDATE_INTERVAL_MS, UpdateTimerDisplay)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "MenuVisibility", EVENT_GAME_CAMERA_UI_MODE_CHANGED, RefreshPanelVisibility)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    savedVariables = ZO_SavedVars:NewAccountWide("AldrensTimersSavedVariables", 1, nil, defaults)
    CreateTimerWindow()
    CreateSettingsPanel()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
