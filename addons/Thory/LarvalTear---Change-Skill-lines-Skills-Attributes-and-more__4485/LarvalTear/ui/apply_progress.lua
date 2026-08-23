local Addon = LarvalTearMod
local ApplyProgress = Addon.UI.ApplyProgress
local Log = Addon.Common.Log

local WINDOW_NAME = "LTM_ApplyProgressWindow"
local WINDOW_WIDTH = 350
local WINDOW_HEIGHT = 130
local WINDOW_TOP_OFFSET = 300
local CONTENT_PADDING = 14
local CLOSE_BUTTON_SIZE = 24
local CLOSE_BUTTON_TEXTURE_PREFIX = "/esoui/art/buttons/decline"

local PHASE_LABELS = {
    Equipment = "Equipment",
    Role = "Role",
    Subclass = "Subclass",
    Skills = "Skills",
    PassiveSkills = "Passive Skills",
    ClassMastery = "Class Mastery",
    Attribute = "Attribute",
    ChampionPoints = "Champion Points",
    Finalize = "Finalize",
}

local function NormalizePhaseName(phaseName)
    if type(phaseName) ~= "string" or phaseName == "" then
        return "-"
    end

    local label = PHASE_LABELS[phaseName]
    if type(label) == "string" then
        return label
    end

    local text = phaseName:gsub("_", " ")
    return (text:gsub("(%a)([%w_']*)", function(first, rest)
        return string.upper(first) .. string.lower(rest)
    end))
end

local function NormalizeReason(reason)
    if type(reason) ~= "string" or reason == "" then
        return "-"
    end

    return Log.LocalizeErrorReason(reason)
end

local function SetLabelText(label, text)
    if label and type(label.SetText) == "function" then
        label:SetText(tostring(text or ""))
    end
end

local function CreateBackdrop(parent, centerR, centerG, centerB, centerA, edgeR, edgeG, edgeB, edgeA)
    local backdrop = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    backdrop:SetAnchorFill(parent)
    backdrop:SetCenterColor(centerR, centerG, centerB, centerA)
    backdrop:SetEdgeColor(edgeR, edgeG, edgeB, edgeA)
    return backdrop
end

local function CreateLabel(parent, font, color, anchorPoint, anchorTarget, anchorTargetPoint, offsetX, offsetY)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font)
    label:SetColor(color[1], color[2], color[3], color[4])
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetAnchor(anchorPoint, anchorTarget, anchorTargetPoint, offsetX, offsetY)
    return label
end

local function CreateWindow(self)
    if self.window then
        return
    end

    local window = WINDOW_MANAGER:CreateTopLevelWindow(WINDOW_NAME)
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:SetAnchor(TOP, GuiRoot, TOP, 0, WINDOW_TOP_OFFSET)
    window:SetMouseEnabled(false)
    window:SetHidden(true)
    if type(window.SetDrawTier) == "function" then
        window:SetDrawTier(DT_HIGH)
    end
    if type(window.SetDrawLayer) == "function" then
        window:SetDrawLayer(DL_CONTROLS)
    end
    if type(window.SetDrawLevel) == "function" then
        window:SetDrawLevel(20)
    end
    self.window = window

    CreateBackdrop(window, 0.02, 0.025, 0.03, 0.94, 0.38, 0.42, 0.48, 0.95)

    local title = CreateLabel(window, "ZoFontWinH4", { 0.92, 0.94, 0.98, 1.0 }, TOPLEFT, window, TOPLEFT, CONTENT_PADDING, 10)
    title:SetDimensions(WINDOW_WIDTH - (CONTENT_PADDING * 2) - CLOSE_BUTTON_SIZE, 24)
    self.titleLabel = title

    local status = CreateLabel(window, "ZoFontGame", { 0.86, 0.88, 0.92, 1.0 }, TOPLEFT, title, BOTTOMLEFT, 0, 8)
    status:SetDimensions(WINDOW_WIDTH - (CONTENT_PADDING * 2), 22)
    self.statusLabel = status

    local phase = CreateLabel(window, "ZoFontGameSmall", { 0.70, 0.76, 0.84, 1.0 }, TOPLEFT, status, BOTTOMLEFT, 0, 6)
    phase:SetDimensions(WINDOW_WIDTH - (CONTENT_PADDING * 2), 20)
    self.phaseLabel = phase

    local reason = CreateLabel(window, "ZoFontGameSmall", { 0.96, 0.48, 0.42, 1.0 }, TOPLEFT, phase, BOTTOMLEFT, 0, 4)
    reason:SetDimensions(WINDOW_WIDTH - (CONTENT_PADDING * 2), 20)
    reason:SetHidden(true)
    self.reasonLabel = reason

    local closeButton = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
    closeButton:SetDimensions(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -8, 8)
    closeButton:SetMouseEnabled(true)
    if type(closeButton.SetClickSound) == "function" and SOUNDS and SOUNDS.DEFAULT_CLICK then
        closeButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
    end
    closeButton:SetNormalTexture(CLOSE_BUTTON_TEXTURE_PREFIX .. "_up.dds")
    closeButton:SetMouseOverTexture(CLOSE_BUTTON_TEXTURE_PREFIX .. "_over.dds")
    closeButton:SetPressedTexture(CLOSE_BUTTON_TEXTURE_PREFIX .. "_down.dds")
    closeButton:SetDisabledTexture(CLOSE_BUTTON_TEXTURE_PREFIX .. "_disabled.dds")
    closeButton:SetHidden(true)
    closeButton:SetHandler("OnClicked", function()
        ApplyProgress:Hide()
    end)
    self.closeButton = closeButton
end

function ApplyProgress:Show(buildName)
    CreateWindow(self)
    self.resultSuccess = nil
    SetLabelText(self.titleLabel, type(buildName) == "string" and buildName ~= "" and buildName or "LarvalTear")
    SetLabelText(self.statusLabel, "Preparing...")
    SetLabelText(self.phaseLabel, "Phase: -")
    SetLabelText(self.reasonLabel, "")
    if self.reasonLabel then
        self.reasonLabel:SetHidden(true)
    end
    if self.closeButton then
        self.closeButton:SetHidden(true)
    end
    self.window:SetMouseEnabled(false)
    self.window:SetHidden(false)
end

function ApplyProgress:Hide()
    if self.window then
        self.window:SetHidden(true)
    end
end

function ApplyProgress:UpdatePhase(phaseName)
    CreateWindow(self)
    SetLabelText(self.phaseLabel, "Phase: " .. NormalizePhaseName(phaseName))
end

function ApplyProgress:UpdateStatus(text)
    CreateWindow(self)
    SetLabelText(self.statusLabel, type(text) == "string" and text or "")
end

function ApplyProgress:SetResult(success, reason)
    CreateWindow(self)
    self.resultSuccess = success == true
    if success == true then
        SetLabelText(self.statusLabel, "Completed")
        SetLabelText(self.reasonLabel, "")
        if self.reasonLabel then
            self.reasonLabel:SetHidden(true)
        end
        if self.closeButton then
            self.closeButton:SetHidden(true)
        end
        self.window:SetMouseEnabled(false)
        return
    end

    SetLabelText(self.statusLabel, "Failed")
    SetLabelText(self.reasonLabel, "Reason: " .. NormalizeReason(reason))
    if self.reasonLabel then
        self.reasonLabel:SetHidden(false)
    end
    if self.closeButton then
        self.closeButton:SetHidden(false)
    end
    self.window:SetMouseEnabled(false)
end
