TiradilSuite = {}

TiradilSuite.BUILD_TAG = "TGA-QWxjaG9saWNWYWRlcg=="

function TiradilSuite.ToggleWindow()
    if TiradilGuildAssistantWindow:IsHidden() then
        TiradilGuildAssistantWindow:SetHidden(false)
    else
        TiradilGuildAssistantWindow:SetHidden(true)
    end
end

local GUIDE_SECTIONS = {
    "GUIDE_SECTION_START_TITLE", "GUIDE_SECTION_START_BODY",
    "GUIDE_SECTION_ROSTER_TITLE", "GUIDE_SECTION_ROSTER_BODY",
    "GUIDE_SECTION_LEDGER_TITLE", "GUIDE_SECTION_LEDGER_BODY",
    "GUIDE_SECTION_WATCH_TITLE", "GUIDE_SECTION_WATCH_BODY",
    "GUIDE_SECTION_TRADER_TITLE", "GUIDE_SECTION_TRADER_BODY",
    "GUIDE_SECTION_TRIALLOG_TITLE", "GUIDE_SECTION_TRIALLOG_BODY",
    "GUIDE_SECTION_COMMANDS_TITLE", "GUIDE_SECTION_COMMANDS_BODY",
}

local GUIDE_CONTENT_WIDTH = 630
local guideTitleLabels = {}
local guideBodyLabels = {}
local guideControlsCreated = false

local function CreateGuideControlsIfNeeded()
    if guideControlsCreated then return end
    local listControl = TiradilGuideFrameList
    if not listControl then return end
    local scrollChild = GetControl(listControl, "ScrollChild")
    if not scrollChild then return end

    local wm = WINDOW_MANAGER
    local previousControl = nil
    for i = 1, #GUIDE_SECTIONS, 2 do
        local titleLabel = wm:CreateControl(nil, scrollChild, CT_LABEL)
        titleLabel:SetFont("ZoFontWinH4")
        titleLabel:SetColor(1, 0.72, 0, 1)
        titleLabel:SetDimensions(GUIDE_CONTENT_WIDTH, 0)
        if previousControl then
            titleLabel:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT, 0, 22)
        else
            titleLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, 4)
        end

        local bodyLabel = wm:CreateControl(nil, scrollChild, CT_LABEL)
        bodyLabel:SetFont("ZoFontGame")
        bodyLabel:SetColor(1, 1, 1, 1)
        bodyLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
        bodyLabel:SetDimensions(GUIDE_CONTENT_WIDTH, 0)
        bodyLabel:SetAnchor(TOPLEFT, titleLabel, BOTTOMLEFT, 0, 8)

        table.insert(guideTitleLabels, titleLabel)
        table.insert(guideBodyLabels, bodyLabel)
        previousControl = bodyLabel
    end
    guideControlsCreated = true
end

function TiradilSuite.RefreshGuideContent()
    CreateGuideControlsIfNeeded()
    if not guideControlsCreated then return end

    for i = 1, #GUIDE_SECTIONS, 2 do
        local idx = (i + 1) / 2
        local titleKey = GUIDE_SECTIONS[i]
        local bodyKey = GUIDE_SECTIONS[i + 1]
        guideTitleLabels[idx]:SetText(TiradilL10n.Get(titleKey))
        guideBodyLabels[idx]:SetText(TiradilL10n.Get(bodyKey))
    end
end

function TiradilSuite.ToggleGuide()
    if not TiradilGuideFrame then return end
    if TiradilGuideFrame:IsHidden() then
        TiradilGuideFrame:SetHidden(false)
        zo_callLater(function()
            TiradilSuite.RefreshGuideContent()
        end, 0)
    else
        TiradilGuideFrame:SetHidden(true)
    end
end

local WINDOW_LAYOUT_REGISTRY = {
    { frameName = "GuildLedgerFrame",           getVars = function() return GuildLedger and GuildLedger.savedVars end },
    { frameName = "TiradilRosterWindow",        getVars = function() return TiradilRoster and TiradilRoster.savedVars end },
    { frameName = "TiradilInactiveWatchWindow", getVars = function() return TiradilInactiveWatch and TiradilInactiveWatch.savedVars end },
    { frameName = "TiradilGuildAssistantWindow",getVars = function() return TiradilSuite.savedVars end },
}

function TiradilSuite.RestoreWindowLayouts()
    for _, entry in ipairs(WINDOW_LAYOUT_REGISTRY) do
        local frame = _G[entry.frameName]
        local vars = entry.getVars and entry.getVars()
        local layout = vars and vars.windowLayout
        if frame and layout and layout.width and layout.height then
            pcall(frame.SetDimensions, frame, layout.width, layout.height)
            if layout.left and layout.top then
                pcall(function()
                    frame:ClearAnchors()
                    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, layout.left, layout.top)
                end)
            end
        end
    end
end

function TiradilSuite.SaveWindowLayouts()
    for _, entry in ipairs(WINDOW_LAYOUT_REGISTRY) do
        local frame = _G[entry.frameName]
        local vars = entry.getVars and entry.getVars()
        if frame and vars then
            vars.windowLayout = {
                width = frame:GetWidth(),
                height = frame:GetHeight(),
                left = frame:GetLeft(),
                top = frame:GetTop(),
            }
        end
    end
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= "TiradilGuildAssistant" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("TiradilGuildAssistant", EVENT_ADD_ON_LOADED)

    TiradilGuildAssistant_SavedVars = TiradilGuildAssistant_SavedVars or {}
    TiradilGuildAssistant_SavedVars.buildOrigin = TiradilGuildAssistant_SavedVars.buildOrigin or TiradilSuite.BUILD_TAG
    TiradilSuite.savedVars = TiradilGuildAssistant_SavedVars

    TiradilRoster.Initialize()
    GuildLedger.Initialize()
    if TiradilInactiveWatch and TiradilInactiveWatch.Initialize then
        TiradilInactiveWatch.Initialize()
    end
    if TiradilTrader and TiradilTrader.Initialize then
        pcall(TiradilTrader.Initialize)
    end
    if TiradilTrialLog and TiradilTrialLog.Initialize then
        pcall(TiradilTrialLog.Initialize)
    end

    if TiradilL10n and TiradilL10n.RefreshAll then
        TiradilL10n.RefreshAll()
    end

    TiradilGuildAssistantWindow:SetMovable(true)
    pcall(TiradilSuite.RestoreWindowLayouts)

    SLASH_COMMANDS["/tga"] = function() TiradilSuite.ToggleWindow() end
    SLASH_COMMANDS["/tgaledger"] = function() if GuildLedger and GuildLedger.ToggleUI then GuildLedger.ToggleUI() end end
    SLASH_COMMANDS["/tgawatch"] = function() if TiradilInactiveWatch and TiradilInactiveWatch.ToggleWindow then TiradilInactiveWatch.ToggleWindow() end end
    SLASH_COMMANDS["/tgaroster"] = function() if TiradilRosterWindow then TiradilRosterWindow:SetHidden(not TiradilRosterWindow:IsHidden()) end end

    if TiradilGuildButton_TryInitialize then
        pcall(TiradilGuildButton_TryInitialize)
    end

    if TiradilRosterColumn_TryInitialize then
        pcall(TiradilRosterColumn_TryInitialize)
    end

end

EVENT_MANAGER:RegisterForEvent("TiradilGuildAssistant", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

local WELCOME_DIALOG_NAME = "TIRADIL_TGA_WELCOME"

local function ShowWelcomeDialogIfNeeded()
    if not TiradilGuildAssistant_SavedVars then return end
    if TiradilGuildAssistant_SavedVars.hasShownWelcome then return end
    TiradilGuildAssistant_SavedVars.hasShownWelcome = true

    if not ESO_Dialogs[WELCOME_DIALOG_NAME] then
        ESO_Dialogs[WELCOME_DIALOG_NAME] = {
            canQueue = true,
            title = { text = "" },
            mainText = { text = "" },
            buttons = {
                [1] = { text = SI_DIALOG_CONFIRM },
            },
        }
    end

    local dialog = ESO_Dialogs[WELCOME_DIALOG_NAME]
    dialog.title.text = "Welcome to Tiradil's Guild Assistant!"
    dialog.mainText.text = "Thank you for installing!\n\nTo open the addon: click the small button at the bottom-right of your Guild Home screen, or type /tga anytime.\n\nWhat's inside: Guild Roster, Guild Ledger (bank, donations, sales, trader bids), Non-Contributors tracker, and Trader Analytics (charts across all your guilds).\n\nQuick commands: /tga, /tgaledger, /tgaroster, /tgawatch.\n\n(You can change the addon's language from its own Settings panel.)"
    ZO_Dialogs_ShowDialog(WELCOME_DIALOG_NAME)
end

local function OnPlayerActivatedFirstTime(eventCode)
    EVENT_MANAGER:UnregisterForEvent("TiradilGuildAssistantWelcome", EVENT_PLAYER_ACTIVATED)
    pcall(ShowWelcomeDialogIfNeeded)
end

EVENT_MANAGER:RegisterForEvent("TiradilGuildAssistantWelcome", EVENT_PLAYER_ACTIVATED, OnPlayerActivatedFirstTime)

local function OnPlayerDeactivated(eventCode)
    pcall(TiradilSuite.SaveWindowLayouts)
end

EVENT_MANAGER:RegisterForEvent("TiradilGuildAssistant", EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
