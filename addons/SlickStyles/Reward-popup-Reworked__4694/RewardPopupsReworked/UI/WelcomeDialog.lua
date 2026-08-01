local RPR = RewardPopupsReworked

RPR.WelcomeDialog = {}

local Welcome = RPR.WelcomeDialog
local WINDOW_NAME = "RewardPopupsReworkedWelcomeDialog"

local DESCRIPTION =
    "Reward Popups Reworked removes intrusive reward prompts and replaces them with a small, non-blocking Action Widget when player attention is required.\n\n"
    .. "Tamriel Tomes and Golden Pursuits can be handled manually through the widget, while supported rewards may be claimed automatically when enabled. "
    .. "Unknown or choice-based Golden Pursuits rewards are always left for manual review."

local function StyleButton(button)
    button:SetFont("ZoFontGameBold")
    button:SetNormalFontColor(0.92, 0.92, 0.84, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    button:SetPressedFontColor(0.75, 0.85, 1, 1)
    button:SetNormalTexture("EsoUI/Art/Buttons/ESO_buttonLarge_up.dds")
    button:SetPressedTexture("EsoUI/Art/Buttons/ESO_buttonLarge_down.dds")
    button:SetMouseOverTexture("EsoUI/Art/Buttons/ESO_buttonLarge_mouseOver.dds")
end

function Welcome:Initialize()
    self.neverShow = false
    self:CreateWindow()

    EVENT_MANAGER:RegisterForUpdate(WINDOW_NAME .. "Show", 1200, function()
        EVENT_MANAGER:UnregisterForUpdate(WINDOW_NAME .. "Show")
        self:ShowIfNeeded()
    end)
end

function Welcome:CreateWindow()
    local window = WINDOW_MANAGER:CreateTopLevelWindow(WINDOW_NAME)
    self.control = window

    window:SetDimensions(640, 370)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.03, 0.035, 0.05, 0.96)
    backdrop:SetEdgeColor(0.55, 0.72, 0.95, 0.8)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)

    local title = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 26, 22)
    title:SetAnchor(TOPRIGHT, window, TOPRIGHT, -26, 22)
    title:SetFont("ZoFontWinH1")
    title:SetColor(0.82, 0.93, 1, 1)
    title:SetText(RPR.displayName)

    local body = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    body:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 16)
    body:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 16)
    body:SetFont("ZoFontGame")
    body:SetColor(0.9, 0.9, 0.84, 1)
    body:SetText(DESCRIPTION)

    local toggle = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
    self.toggle = toggle
    toggle:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 26, -92)
    toggle:SetDimensions(300, 28)
    toggle:SetFont("ZoFontGame")
    toggle:SetNormalFontColor(0.82, 0.9, 1, 1)
    toggle:SetMouseOverFontColor(1, 1, 1, 1)
    toggle:SetHandler("OnClicked", function() self:ToggleNeverShow() end)
    self:RefreshToggleText()

    local enableReplacement = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
    enableReplacement:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -26, -76)
    enableReplacement:SetDimensions(280, 36)
    enableReplacement:SetText("Enable Manual Mode")
    StyleButton(enableReplacement)
    enableReplacement:SetHandler("OnClicked", function() self:EnableFeatures(false) end)

    local enableAuto = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
    enableAuto:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -26, -28)
    enableAuto:SetDimensions(280, 36)
    enableAuto:SetText("Enable Automatic Mode")
    StyleButton(enableAuto)
    enableAuto:SetHandler("OnClicked", function() self:EnableFeatures(true) end)

    local later = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
    later:SetAnchor(RIGHT, enableAuto, LEFT, -12, 0)
    later:SetDimensions(130, 40)
    later:SetText("Configure Later")
    StyleButton(later)
    later:SetHandler("OnClicked", function() self:Dismiss() end)
end

function Welcome:ShowIfNeeded()
    if not RPR.savedVars or not RPR.savedVars.general then return end
    if RPR.savedVars.general.showWelcome == false then return end

    self.neverShow = false
    self:RefreshToggleText()
    self.control:SetHidden(false)
end

function Welcome:RefreshToggleText()
    if not self.toggle then return end

    self.toggle:SetText((self.neverShow and "[x] " or "[ ] ") .. "Never show this message again")
end

function Welcome:ToggleNeverShow()
    self.neverShow = not self.neverShow
    self:RefreshToggleText()
end

function Welcome:ApplyNeverShow()
    if self.neverShow then
        RPR.savedVars.general.showWelcome = false
    end
end

function Welcome:EnableFeatures(enableAutoClaim)
    if not RPR.savedVars or not RPR.savedVars.general then
        self.control:SetHidden(true)
        return
    end

    RPR.savedVars.general.showWelcome = false

    if RPR.EnableCoreFeatures then
        RPR:EnableCoreFeatures(enableAutoClaim == true)
    end

    self.control:SetHidden(true)

    if enableAutoClaim == true then
        RPR:Notify(
            "Automatic Mode enabled. Reloading UI...",
            true
        )
    else
        RPR:Notify(
            "Manual Mode enabled. Reloading UI...",
            true
        )
    end

    zo_callLater(function()
        ReloadUI()
    end, 500)
end

function Welcome:Dismiss()
    if not RPR.savedVars or not RPR.savedVars.general then
        self.control:SetHidden(true)
        return
    end

    self:ApplyNeverShow()
    self.control:SetHidden(true)
end
