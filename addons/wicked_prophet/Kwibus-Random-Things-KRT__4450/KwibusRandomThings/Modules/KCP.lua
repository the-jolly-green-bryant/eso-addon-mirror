local KRT = KwibusRandomThings
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local ADDON_NAME = KRT.name

local EnsureTable = KRT.EnsureTable
local IsNonEmptyString = KRT.IsNonEmptyString
local DebounceNextFrame = KRT.DebounceNextFrame
local RGBToHex = KRT.RGBToHex

local DEFAULTS = { kcp = {
    enabled = true,
    text = "BRITTLE U BITARD!",
    offsetX = 0,
    offsetY = 100,
    fontScale = 1.0,
    enableReposition = false,
  } }

KRT.KCP = {
    id = "kcp",
    defaults = DEFAULTS.kcp,
  SKILL_ID = 183267,
  DEBUFF_ID = 145975,

  ui = nil,
  lbl = nil,

  _slotted = false,
  _slottedAtMs = 0,
  _hasDebuff = false,
  _hasDebuffAtMs = 0,
}

local BARS_TO_CHECK = { 0, 1 } -- PERFORMANCE FIX

function KRT.KCP:SV() return KRT.sv and KRT.sv.kcp end

function KRT.KCP:EnsureOverlay()
  if self.ui then return end
  local sv = self:SV()
  if not sv then return end

  local win = WM:CreateTopLevelWindow("KwibusColorlessPool_UI")
  win:SetDimensions(120, 40)
  win:SetHidden(true)
  win:SetMouseEnabled(false)
  win:SetMovable(false)
  win:SetClampedToScreen(true)
  win:SetDrawLayer(DL_OVERLAY)
  win:SetDrawTier(DT_HIGH)
  win:SetDrawLevel(9999)

  local label = WM:CreateControl("KwibusColorlessPool_Lbl", win, CT_LABEL)
  label:SetAnchor(CENTER, win, CENTER, 0, 0)
  label:SetFont("ZoFontCallout")
  label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  label:SetColor(1, 0, 0, 1)

  self.ui = win
  self.lbl = label

  self:ApplyAnchor()
  self:UpdateTextAndScale()
end

function KRT.KCP:UpdateTextAndScale()
  local win, label = self.ui, self.lbl
  if not (win and label) then return end
  local sv = self:SV()
  if not sv then return end

  local scale = sv.fontScale or 1.0
  local text = sv.text or DEFAULTS.kcp.text
  label:SetText(text)
  label:SetScale(scale)

  DebounceNextFrame("KCP_Resize", function()
    local tries = 0
    local function ResizeHitbox()
      tries = tries + 1
      local w = (label:GetTextWidth() or 0) * scale + 24
      local h = (label:GetTextHeight() or 0) * scale + 24
      if (w <= 26 or h <= 26) and tries < 6 then zo_callLater(ResizeHitbox, 0) return end
      if w < 60 then w = 60 end
      if h < 30 then h = 30 end
      label:SetDimensions(w / scale, h / scale)
      win:SetDimensions(w, h)
    end
    ResizeHitbox()
  end)
end

function KRT.KCP:ApplyAnchor()
  local sv = self:SV()
  if not (self.ui and sv) then return end
  self.ui:ClearAnchors()
  self.ui:SetAnchor(CENTER, GuiRoot, CENTER, sv.offsetX or 0, sv.offsetY or DEFAULTS.kcp.offsetY)
end

function KRT.KCP:EnableDragging(enable)
  local sv = self:SV()
  local ui, label = self.ui, self.lbl
  if not (ui and label and sv) then return end

  ui:SetMouseEnabled(false)
  ui:SetMovable(true)
  ui:SetClampedToScreen(true)

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
    self:OnCombatUpdate()
  end
end

function KRT.KCP:_ComputeIsSkillSlotted()
  for _, bar in ipairs(BARS_TO_CHECK) do
    for slot = 3, 8 do
      if GetSlotBoundId(slot, bar) == self.SKILL_ID then return true end
    end
  end
  return false
end

function KRT.KCP:IsSkillSlottedCached(maxAgeMs)
  local nowMs = GetFrameTimeMilliseconds()
  if (nowMs - (self._slottedAtMs or 0)) > (maxAgeMs or 1000) then
    self._slotted = self:_ComputeIsSkillSlotted()
    self._slottedAtMs = nowMs
  end
  return self._slotted
end

function KRT.KCP:_ComputeHasDebuff()
  for i = 1, GetNumBuffs("reticleover") do
    local _, _, _, _, _, _, _, _, _, _, id = GetUnitBuffInfo("reticleover", i)
    if id == self.DEBUFF_ID then return true end
  end
  return false
end

function KRT.KCP:HasDebuffCached(maxAgeMs)
  local nowMs = GetFrameTimeMilliseconds()
  if (nowMs - (self._hasDebuffAtMs or 0)) > (maxAgeMs or 120) then
    self._hasDebuff = self:_ComputeHasDebuff()
    self._hasDebuffAtMs = nowMs
  end
  return self._hasDebuff
end

function KRT.KCP:OnCombatUpdate()
  local sv = self:SV()
  if not sv then return end

  if not sv.enabled then
    if self.ui then self.ui:SetHidden(true) end
    return
  end

  if sv.enableReposition then
    if self.ui then self.ui:SetHidden(false) end
    return
  end

  if not self.ui then return end

  if IsUnitInCombat("player")
      and DoesUnitExist("reticleover")
      and IsUnitAttackable("reticleover")
      and not IsUnitDead("reticleover") then
    if self:IsSkillSlottedCached(1000) then
      self.ui:SetHidden(self:HasDebuffCached(120))
      return
    end
  end

  self.ui:SetHidden(true)
end

function KRT.KCP:Initialize()
  local sv = self:SV()
  if not sv then return end

  self:EnsureOverlay()
  self:ApplyAnchor()
  self:UpdateTextAndScale()
  self:EnableDragging(sv.enableReposition)

  EM:RegisterForEvent(ADDON_NAME .. "_KCP_Combat", EVENT_PLAYER_COMBAT_STATE, function()
    self:OnCombatUpdate()
  end)

  EM:RegisterForEvent(ADDON_NAME .. "_KCP_Target", EVENT_RETICLE_TARGET_CHANGED, function()
    self._hasDebuffAtMs = 0
    self._slottedAtMs = 0
    self:OnCombatUpdate()
  end)

  EM:RegisterForEvent(ADDON_NAME .. "_KCP_Effect", EVENT_EFFECT_CHANGED, function()
    self._hasDebuffAtMs = 0
    self:OnCombatUpdate()
  end)
  EM:AddFilterForEvent(ADDON_NAME .. "_KCP_Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
end

local function SV() return KRT.sv end

function KRT.KCP:GetLAMSubmenu()
    return {
      type = "submenu",
      name = "Kwibus Colorless Pool",
      controls = {
        { type = "checkbox", name = "Enable Colorless Pool Reminder",
          getFunc = function() return SV().kcp.enabled end,
          setFunc = function(v) SV().kcp.enabled = v; KRT.KCP:OnCombatUpdate() end,
          width = "full",
        },
        { type = "checkbox", name = "Enable repositioning (drag)",
          getFunc = function() return SV().kcp.enableReposition end,
          setFunc = function(v)
            SV().kcp.enableReposition = v
            KRT.KCP:EnableDragging(v)
            KRT.KCP:ApplyAnchor()
          end,
          width = "full",
          disabled = function() return not SV().kcp.enabled end,
        },
        { type = "editbox", name = "Reminder text", isMultiline = false,
          getFunc = function() return SV().kcp.text end,
          setFunc = function(v)
            SV().kcp.text = IsNonEmptyString(v) and v or DEFAULTS.kcp.text
            KRT.KCP:UpdateTextAndScale()
          end,
          width = "full",
          disabled = function() return not SV().kcp.enabled end,
        },
        { type = "slider", name = "Text scale", min = 0.5, max = 3.0, step = 0.1,
          getFunc = function() return SV().kcp.fontScale end,
          setFunc = function(v) SV().kcp.fontScale = v; KRT.KCP:UpdateTextAndScale() end,
          width = "full",
          disabled = function() return not SV().kcp.enabled end,
        },
        { type = "button", name = "Reset horizontal position",
          func = function() SV().kcp.offsetX = 0; KRT.KCP:ApplyAnchor() end,
          disabled = function() return not SV().kcp.enabled or not SV().kcp.enableReposition end,
          width = "half",
        },
        { type = "button", name = "Reset vertical position",
          func = function() SV().kcp.offsetY = DEFAULTS.kcp.offsetY; KRT.KCP:ApplyAnchor() end,
          disabled = function() return not SV().kcp.enabled or not SV().kcp.enableReposition end,
          width = "half",
        },
      },
    }
end

KRT:RegisterModule(KRT.KCP)

