local KRT = KwibusRandomThings
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local ADDON_NAME = KRT.name

local EnsureTable = KRT.EnsureTable
local IsNonEmptyString = KRT.IsNonEmptyString
local DebounceNextFrame = KRT.DebounceNextFrame
local RGBToHex = KRT.RGBToHex

local DEFAULTS = { kic = {
    enabled = true,
    offsetX = 0,
    offsetY = -100,
    fontScale = 1.0,
    enableReposition = false,
    enterText = "IN COMBAT",
    exitText = "WOW ENEMY DIED",
    durationMs = 3000,
    enterColor = { r = 1, g = 0, b = 0 },
    exitColor = { r = 0, g = 1, b = 0 },
} }

KRT.KIC = {
    id = "kic",
    defaults = DEFAULTS.kic, hideTimerId = nil }

local FALLBACK_COLOR = { r = 1, g = 1, b = 1 } -- PERFORMANCE FIX

local cachedSV = nil
function KRT.KIC:SV()
    if cachedSV then return cachedSV end
    if KRT.sv and KRT.sv.kic then
        cachedSV = KRT.sv.kic
        return cachedSV
    end
    return nil
end
local function SV() return KRT.KIC:SV() end

local function KIC_CancelHide()
    if KRT.KIC.hideTimerId ~= nil then
        zo_removeCallLater(KRT.KIC.hideTimerId)
        KRT.KIC.hideTimerId = nil
    end
end

function KRT.KIC:ApplyAnchor()
    local sv = self:SV()
    if not (KwibusInCombat_UI and sv) then return end
    KwibusInCombat_UI:ClearAnchors()
    KwibusInCombat_UI:SetAnchor(CENTER, GuiRoot, CENTER, sv.offsetX or 0, sv.offsetY or DEFAULTS.kic.offsetY)
end

function KRT.KIC:ApplyFontScale()
    local sv = self:SV()
    if not (KwibusInCombat_UIText and sv) then return end
    KwibusInCombat_UIText:SetScale(sv.fontScale or 1.0)
end

function KRT.KIC:EnableDragging(enable)
    local sv = self:SV()
    local ui = KwibusInCombat_UI
    local bg = KwibusInCombat_UIDragBG
    local label = KwibusInCombat_UIText
    if not (ui and label and sv) then return end

    if bg then
        bg:SetHidden(true)
        bg:SetMouseEnabled(false)
    end

    ui:SetMouseEnabled(false)
    ui:SetMovable(true)
    ui:SetClampedToScreen(true)
    ui:SetDrawTier(DT_HIGH)
    ui:SetDrawLayer(DL_OVERLAY)

    if enable then
        ui:SetHidden(false)
        label:SetMouseEnabled(true)

        label:SetHandler("OnMouseDown", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then ui:StartMoving() end
        end)

        label:SetHandler("OnMouseUp", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then ui:StopMovingOrResizing() end
        end)

        ui:SetHandler("OnMoveStop", function(control)
            local rootCx, rootCy = GuiRoot:GetCenter()
            local ux, uy = control:GetCenter()
            sv.offsetX = zo_round(ux - rootCx)
            sv.offsetY = zo_round(uy - rootCy)
            self:ApplyAnchor()
        end)
    else
        label:SetMouseEnabled(false)
        label:SetHandler("OnMouseDown", nil)
        label:SetHandler("OnMouseUp", nil)
        ui:SetHandler("OnMoveStop", nil)
    end
end

function KRT.KIC:ShowMessage(text, color, durationMs)
    local sv = self:SV()
    if not (sv and sv.enabled) then return end
    if not (KwibusInCombat_UI and KwibusInCombat_UIText) then return end

    KIC_CancelHide()

    KwibusInCombat_UIText:SetText(text or "")
    local c = color or FALLBACK_COLOR
    KwibusInCombat_UIText:SetColor(c.r or 1, c.g or 1, c.b or 1, 1)

    -- self:ApplyFontScale() -- OPTIMIZED: Font scale is static, no need to re-apply on every combat change
    KwibusInCombat_UI:SetHidden(false)

    self.hideTimerId = zo_callLater(function()
        local sv2 = self:SV()
        if not (sv2 and sv2.enableReposition) then
            KwibusInCombat_UI:SetHidden(true)
        end
        self.hideTimerId = nil
    end, durationMs or 3000)
end

function KRT.KIC:OnCombatStateChanged(inCombat)
    local sv = self:SV()
    if not (sv and sv.enabled) then return end
    if sv.enableReposition then return end
    if inCombat then
        self:ShowMessage(sv.enterText, sv.enterColor, sv.durationMs)
    else
        self:ShowMessage(sv.exitText, sv.exitColor, sv.durationMs)
    end
end

function KRT.KIC:RegisterSlashCommands()
    SLASH_COMMANDS["/kic"] = function(arg)
        arg = (arg or ""):lower()
        if arg == "test" then
            local sv = self:SV()
            if not sv then return end
            local prevMove = sv.enableReposition
            sv.enableReposition = false
            self:EnableDragging(false)
            self:ShowMessage(sv.enterText, sv.enterColor, sv.durationMs)
            zo_callLater(function()
                self:ShowMessage(sv.exitText, sv.exitColor, sv.durationMs)
                sv.enableReposition = prevMove
                self:EnableDragging(prevMove)
            end, (sv.durationMs or 3000) + 500)
        else
            d("[KRT] /kic test")
        end
    end
end

function KRT.KIC:Initialize()
    local sv = self:SV()
    if not sv then return end

    self:ApplyAnchor()
    self:ApplyFontScale()
    self:EnableDragging(sv.enableReposition)

    if sv.enableReposition then
        KIC_CancelHide()
        self:ShowMessage("move me", { r = 1, g = 1, b = 1 }, 9999999)
    end

    EM:RegisterForEvent(ADDON_NAME .. "_KIC_Activated", EVENT_PLAYER_ACTIVATED, function()
        local sv2 = self:SV()
        if not sv2 then return end
        self:ApplyAnchor()
        self:ApplyFontScale()
    end)

    EM:RegisterForEvent(ADDON_NAME .. "_KIC_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        self:OnCombatStateChanged(inCombat)
    end)

    self:RegisterSlashCommands()
end

function KRT.KIC:GetLAMSubmenu()
    return {
        type = "submenu",
        name = "Kwibus In Combat",
        controls = {
            { type = "checkbox", name = "Enable InCombat messages",
              getFunc = function() return SV().enabled end,
              setFunc = function(v)
                  SV().enabled = v
                  if (not v) and KwibusInCombat_UI then KwibusInCombat_UI:SetHidden(true) end
              end,
              width = "full",
            },
            { type = "checkbox", name = "Enable repositioning (drag)",
              tooltip = "Shows a drag box and a move me message.",
              getFunc = function() return SV().enableReposition end,
              setFunc = function(v)
                  SV().enableReposition = v
                  KRT.KIC:EnableDragging(v)
                  KRT.KIC:ApplyAnchor()
                  if v then
                      KRT.KIC.hideTimerId = nil
                      KRT.KIC:ShowMessage("move me", { r = 1, g = 1, b = 1 }, 9999999)
                  else
                      if KwibusInCombat_UI then KwibusInCombat_UI:SetHidden(true) end
                  end
              end,
              width = "full",
              disabled = function() return not SV().enabled end,
            },
            { type = "slider", name = "Font scale", min = 0.5, max = 2.0, step = 0.05,
              getFunc = function() return SV().fontScale end,
              setFunc = function(v) SV().fontScale = v; KRT.KIC:ApplyFontScale() end,
              width = "full",
              disabled = function() return not SV().enabled end,
            },
            { type = "slider", name = "Duration (ms)", min = 500, max = 8000, step = 100,
              getFunc = function() return SV().durationMs end,
              setFunc = function(v) SV().durationMs = v end,
              width = "full",
              disabled = function() return not SV().enabled end,
            },
            { type = "editbox", name = "Enter combat text", isMultiline = false,
              getFunc = function() return SV().enterText end,
              setFunc = function(v) SV().enterText = v end,
              width = "full",
              disabled = function() return not SV().enabled end,
            },
            { type = "editbox", name = "Exit combat text", isMultiline = false,
              getFunc = function() return SV().exitText end,
              setFunc = function(v) SV().exitText = v end,
              width = "full",
              disabled = function() return not SV().enabled end,
            },
            { type = "button", name = "Reset horizontal position",
              func = function() SV().offsetX = 0; KRT.KIC:ApplyAnchor() end,
              disabled = function() return not SV().enabled or not SV().enableReposition end,
              width = "half",
            },
            { type = "button", name = "Reset vertical position",
              func = function() SV().offsetY = DEFAULTS.kic.offsetY; KRT.KIC:ApplyAnchor() end,
              disabled = function() return not SV().enabled or not SV().enableReposition end,
              width = "half",
            },
        }
    }
end

KRT:RegisterModule(KRT.KIC)