local KRT = KwibusRandomThings
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local ADDON_NAME = KRT.name

local IsNonEmptyString = KRT.IsNonEmptyString
local DebounceNextFrame = KRT.DebounceNextFrame

local DEFAULTS = { kow = {
    enabled = true,
    text = "overload",
    fontScale = 1.0,
    offsetX = 0,
    offsetY = 0,
    enableReposition = false,
    textSide = "center", -- "left", "center", "right"
    color = { r = 1, g = 0.85, b = 0.2 },
} }

KRT.KOW = {
    id = "kow",
    defaults = DEFAULTS.kow,
    TARGET_BUFF_ID = 24806,

    ui = nil,
    lbl = nil,
}

function KRT.KOW:SV()
    return KRT.sv and KRT.sv.kow
end

function KRT.KOW:HasOverloadBuff()
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if abilityId == self.TARGET_BUFF_ID then
            return true
        end
    end
    return false
end

function KRT.KOW:EnsureOverlay()
    if self.ui then return end
    local sv = self:SV()
    if not sv then return end

    local win = WM:CreateTopLevelWindow("KwibusOverloadWatcher_UI")
    win:SetDimensions(220, 60)
    win:SetHidden(true)
    win:SetMouseEnabled(false)
    win:SetMovable(false)
    win:SetClampedToScreen(true)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawTier(DT_HIGH)
    win:SetDrawLevel(9999)

    local label = WM:CreateControl("KwibusOverloadWatcher_Lbl", win, CT_LABEL)
    label:SetAnchor(CENTER, win, CENTER, 0, 0)
    label:SetFont("ZoFontWinH1")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.ui = win
    self.lbl = label

    self:ApplyAnchor()
    self:UpdateTextStyle()
end

function KRT.KOW:UpdateTextStyle()
    local ui, lbl = self.ui, self.lbl
    if not (ui and lbl) then return end
    local sv = self:SV()
    if not sv then return end

    local text = IsNonEmptyString(sv.text) and sv.text or DEFAULTS.kow.text
    local scale = sv.fontScale or DEFAULTS.kow.fontScale
    local c = sv.color or DEFAULTS.kow.color
    local side = sv.textSide or "center"

    lbl:SetText(text)
    lbl:SetScale(scale)
    lbl:SetColor(c.r or 1, c.g or 0.85, c.b or 0.2, 1)

    if side == "left" then
        lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    elseif side == "right" then
        lbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    else
        lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end

    DebounceNextFrame("KOW_Resize", function()
        local tries = 0
        local function ResizeHitbox()
            tries = tries + 1
            local w = (lbl:GetTextWidth() or 0) * scale + 24
            local h = (lbl:GetTextHeight() or 0) * scale + 24
            if (w <= 26 or h <= 26) and tries < 6 then
                zo_callLater(ResizeHitbox, 0)
                return
            end
            if w < 80 then w = 80 end
            if h < 30 then h = 30 end
            lbl:SetDimensions(w / scale, h / scale)
            ui:SetDimensions(w, h)
        end
        ResizeHitbox()
    end)
end

function KRT.KOW:ApplyAnchor()
    local sv = self:SV()
    if not (self.ui and sv) then return end
    self.ui:ClearAnchors()
    self.ui:SetAnchor(CENTER, GuiRoot, CENTER, sv.offsetX or 0, sv.offsetY or DEFAULTS.kow.offsetY)
end

function KRT.KOW:EnableDragging(enable)
    local sv = self:SV()
    local ui, lbl = self.ui, self.lbl
    if not (ui and lbl and sv) then return end

    ui:SetMouseEnabled(false)
    ui:SetMovable(true)
    ui:SetClampedToScreen(true)
    ui:SetDrawTier(DT_HIGH)
    ui:SetDrawLayer(DL_OVERLAY)

    if enable then
        ui:SetHidden(false)
        lbl:SetMouseEnabled(true)

        lbl:SetHandler("OnMouseDown", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                ui:StartMoving()
            end
        end)

        lbl:SetHandler("OnMouseUp", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                ui:StopMovingOrResizing()
            end
        end)

        ui:SetHandler("OnMoveStop", function(control)
            local rootCx, rootCy = GuiRoot:GetCenter()
            local ux, uy = control:GetCenter()
            sv.offsetX = zo_round(ux - rootCx)
            sv.offsetY = zo_round(uy - rootCy)
            self:ApplyAnchor()
        end)
    else
        lbl:SetMouseEnabled(false)
        lbl:SetHandler("OnMouseDown", nil)
        lbl:SetHandler("OnMouseUp", nil)
        ui:SetHandler("OnMoveStop", nil)
        self:UpdateDisplay()
    end
end

function KRT.KOW:UpdateDisplay()
    local sv = self:SV()
    if not sv then return end
    if not self.ui then return end

    if not sv.enabled then
        self.ui:SetHidden(true)
        return
    end

    if sv.enableReposition then
        self.ui:SetHidden(false)
        return
    end

    self.ui:SetHidden(not self:HasOverloadBuff())
end

function KRT.KOW:Initialize()
    local sv = self:SV()
    if not sv then return end

    self:EnsureOverlay()
    self:ApplyAnchor()
    self:UpdateTextStyle()
    self:EnableDragging(sv.enableReposition)

    EM:RegisterForEvent(ADDON_NAME .. "_KOW_Activated", EVENT_PLAYER_ACTIVATED, function()
        self:UpdateDisplay()
    end)

    EM:RegisterForEvent(ADDON_NAME .. "_KOW_Effect", EVENT_EFFECT_CHANGED, function(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId)
        if unitTag ~= "player" then return end
        if abilityId ~= self.TARGET_BUFF_ID then return end
        self:UpdateDisplay()
    end)
    EM:AddFilterForEvent(ADDON_NAME .. "_KOW_Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    self:UpdateDisplay()
end

local function SV()
    return KRT.sv
end

function KRT.KOW:GetLAMSubmenu()
    return {
        type = "submenu",
        name = "Overload Watcher",
        controls = {
            {
                type = "checkbox",
                name = "Enable Overload Watcher",
                getFunc = function() return SV().kow.enabled end,
                setFunc = function(v)
                    SV().kow.enabled = v
                    KRT.KOW:UpdateDisplay()
                end,
                width = "full",
            },
            {
                type = "checkbox",
                name = "Enable repositioning (drag)",
                getFunc = function() return SV().kow.enableReposition end,
                setFunc = function(v)
                    SV().kow.enableReposition = v
                    KRT.KOW:EnableDragging(v)
                    KRT.KOW:ApplyAnchor()
                end,
                width = "full",
                disabled = function() return not SV().kow.enabled end,
            },
            {
                type = "dropdown",
                name = "Text side",
                choices = { "Left", "Center", "Right" },
                choicesValues = { "left", "center", "right" },
                getFunc = function() return SV().kow.textSide end,
                setFunc = function(v)
                    SV().kow.textSide = v
                    KRT.KOW:UpdateTextStyle()
                end,
                width = "full",
                disabled = function() return not SV().kow.enabled end,
            },
            {
                type = "editbox",
                name = "Reminder text",
                isMultiline = false,
                getFunc = function() return SV().kow.text end,
                setFunc = function(v)
                    SV().kow.text = IsNonEmptyString(v) and v or DEFAULTS.kow.text
                    KRT.KOW:UpdateTextStyle()
                    KRT.KOW:UpdateDisplay()
                end,
                width = "full",
                disabled = function() return not SV().kow.enabled end,
            },
            {
                type = "slider",
                name = "Text scale",
                min = 0.5,
                max = 3.0,
                step = 0.1,
                getFunc = function() return SV().kow.fontScale end,
                setFunc = function(v)
                    SV().kow.fontScale = v
                    KRT.KOW:UpdateTextStyle()
                end,
                width = "full",
                disabled = function() return not SV().kow.enabled end,
            },
            {
                type = "button",
                name = "Reset horizontal position",
                func = function()
                    SV().kow.offsetX = 0
                    KRT.KOW:ApplyAnchor()
                end,
                width = "half",
                disabled = function() return not SV().kow.enabled or not SV().kow.enableReposition end,
            },
            {
                type = "button",
                name = "Reset vertical position",
                func = function()
                    SV().kow.offsetY = DEFAULTS.kow.offsetY
                    KRT.KOW:ApplyAnchor()
                end,
                width = "half",
                disabled = function() return not SV().kow.enabled or not SV().kow.enableReposition end,
            },
        },
    }
end

KRT:RegisterModule(KRT.KOW)