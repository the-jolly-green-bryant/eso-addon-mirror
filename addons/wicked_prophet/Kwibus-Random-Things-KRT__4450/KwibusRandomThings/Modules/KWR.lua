local KRT = KwibusRandomThings
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local ADDON_NAME = KRT.name

local EnsureTable = KRT.EnsureTable
local IsNonEmptyString = KRT.IsNonEmptyString
local DebounceNextFrame = KRT.DebounceNextFrame
local RGBToHex = KRT.RGBToHex

-- Module-local defaults wrapper
local DEFAULTS = { kwr = {
    enabled = true,
    showCSA = true,
    showChat = true,
    color = { r = 0.043, g = 1.0, b = 1.0 },
    posX = 0,
    posY = 200,
    lifespanMs = 5000,
    keepVisible = false,
    textScale = 1.0,
  } }

KRT.KWR = {
    id = "kwr",
    defaults = DEFAULTS.kwr,
  DIFF_NORMAL = 1,
  DIFF_VETERAN = 2,

  initialized = false,
  deactivated = false,
  trialDiff = 1,

  COOLDOWN_MS = 2000,
  UPDATE_NAME = ADDON_NAME .. "_KWR_Cooldown",

  pendingMsg = nil,
  lastChangeMs = 0,
  cooldownArmed = false,

  ui = { tlw = nil, label = nil, hideNonce = 0, lastMessage = nil, pad = 12 },
}

function KRT.KWR:SV() return KRT.sv and KRT.sv.kwr end

function KRT.KWR:SeedDifficultyFromGame()
  local eff = ZO_GetEffectiveDungeonDifficulty()
  self.trialDiff = (eff == DUNGEON_DIFFICULTY_VETERAN) and self.DIFF_VETERAN or self.DIFF_NORMAL
end

function KRT.KWR:DiffToColored(diff)
  return (diff == self.DIFF_VETERAN) and "|c00FF00Veteran|r" or "|cFF0000Normal|r"
end

function KRT.KWR:HideBigNow()
  local tlw = self.ui.tlw
  if tlw and not tlw:IsHidden() then tlw:SetHidden(true) end
end

function KRT.KWR:ApplyOverlayPosition()
  local tlw = self.ui.tlw
  if not tlw then return end
  local sv = self:SV()
  if not sv then return end
  tlw:ClearAnchors()
  tlw:SetAnchor(CENTER, GuiRoot, CENTER, sv.posX or 0, sv.posY or DEFAULTS.kwr.posY)
end

function KRT.KWR:ApplyTextScale()
  local label = self.ui.label
  if not label then return end
  local sv = self:SV()
  if not sv then return end
  label:SetScale(zo_clamp(tonumber(sv.textScale) or 1.0, 0.5, 2.0))
end

function KRT.KWR:SizeTLWToText()
  local tlw, label = self.ui.tlw, self.ui.label
  if not (tlw and label) then return end
  local sv = self:SV()
  if not sv then return end

  local scale = zo_clamp(tonumber(sv.textScale) or 1.0, 0.5, 2.0)
  local w = (label:GetTextWidth() or 0) * scale + self.ui.pad * 2
  local h = (label:GetTextHeight() or 0) * scale + self.ui.pad * 2

  if w <= 2 or h <= 2 then DebounceNextFrame("KWR_Size", function() self:SizeTLWToText() end); return end
  tlw:SetDimensions(math.max(w, 120), math.max(h, 40))
end

function KRT.KWR:EnsureOverlay()
  if self.ui.tlw and self.ui.label then return end

  local tlw = WM:CreateTopLevelWindow("KWR_MovableBigTLW")
  tlw:SetMouseEnabled(false)
  tlw:SetMovable(true)
  tlw:SetClampedToScreen(true)
  tlw:SetResizeHandleSize(0)
  tlw:SetDrawTier(DT_HIGH)
  tlw:SetDrawLayer(DL_OVERLAY)
  tlw:SetDrawLevel(999)

  tlw:SetHandler("OnMoveStop", function(selfTlw)
    local cx, cy = selfTlw:GetCenter()
    local rootW, rootH = GuiRoot:GetDimensions()
    local s = KRT.KWR:SV()
    if not s then return end
    s.posX = zo_round(cx - rootW * 0.5)
    s.posY = zo_round(cy - rootH * 0.5)
    KRT.KWR:ApplyOverlayPosition()
  end)

  local label = WM:CreateControl("KWR_MovableBigLabel", tlw, CT_LABEL)
  label:SetFont("ZoFontAnnounceLarge")
  label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  label:SetMouseEnabled(true)
  label:ClearAnchors()
  label:SetAnchor(CENTER, tlw, CENTER, 0, 0)
  label:SetHandler("OnMouseDown", function() tlw:StartMoving() end)
  label:SetHandler("OnMouseUp", function() tlw:StopMovingOrResizing() end)

  tlw:SetDimensions(120, 40)

  self.ui.tlw, self.ui.label = tlw, label
  self:ApplyTextScale()
  self:ApplyOverlayPosition()
  tlw:SetHidden(true)
end

function KRT.KWR:ShowBigMovable(textNoOuterColor)
  local sv = self:SV()
  if not (sv and sv.enabled and sv.showCSA and IsNonEmptyString(textNoOuterColor)) then
    self:HideBigNow()
    return
  end

  self:EnsureOverlay()
  self:ApplyTextScale()

  local c = sv.color or DEFAULTS.kwr.color
  self.ui.label:SetText(RGBToHex(c.r, c.g, c.b) .. textNoOuterColor .. "|r")

  self:SizeTLWToText()
  DebounceNextFrame("KWR_SizeAfterText", function() self:SizeTLWToText() end)

  self.ui.tlw:SetHidden(false)

  self.ui.hideNonce = (self.ui.hideNonce or 0) + 1
  local myNonce = self.ui.hideNonce
  if not sv.keepVisible then
    zo_callLater(function()
      local sv2 = self:SV()
      if myNonce == self.ui.hideNonce and sv2 and sv2.enabled and sv2.showCSA and not sv2.keepVisible then
        self:HideBigNow()
      end
    end, sv.lifespanMs or 5000)
  end
end

function KRT.KWR:BuildMessageText(diffText)
  return zo_strformat("Instance reset. Difficulty: <<1>> – charge ult", diffText)
end

function KRT.KWR:ShowNotification(textNoOuterColor)
  local sv = self:SV()
  if not (sv and sv.enabled and IsNonEmptyString(textNoOuterColor)) then return end

  self.ui.lastMessage = textNoOuterColor

  if sv.showCSA then self:ShowBigMovable(textNoOuterColor) else self:HideBigNow() end

  if sv.showChat and CHAT_SYSTEM then
    local c = sv.color or DEFAULTS.kwr.color
    CHAT_SYSTEM:AddMessage(RGBToHex(c.r, c.g, c.b) .. textNoOuterColor .. "|r")
  end
end

function KRT.KWR:ArmCooldown(messageNoOuterColor)
  self.pendingMsg = messageNoOuterColor
  self.lastChangeMs = GetFrameTimeMilliseconds()
  if self.cooldownArmed then return end
  self.cooldownArmed = true

  EM:RegisterForUpdate(self.UPDATE_NAME, 100, function()
    local now = GetFrameTimeMilliseconds()
    if (now - self.lastChangeMs) >= self.COOLDOWN_MS then
      EM:UnregisterForUpdate(self.UPDATE_NAME)
      self.cooldownArmed = false
      if self.pendingMsg then
        self:ShowNotification(self.pendingMsg)
        self.pendingMsg = nil
      end
    end
  end)
end

function KRT.KWR:QueueResetMessage(newDiff)
  self:ArmCooldown(self:BuildMessageText(self:DiffToColored(newDiff)))
end

function KRT.KWR:UpdateDifficulty(newDiff)
  if not self.initialized then self.trialDiff = newDiff; return end
  if newDiff == self.trialDiff then return end
  self.trialDiff = newDiff
  if not self.deactivated then self:QueueResetMessage(newDiff) end
end

function KRT.KWR:OnPlayerActivated()
  self:SeedDifficultyFromGame()
  self.initialized = true
  self.deactivated = false

  if self.cooldownArmed then
    EM:UnregisterForUpdate(self.UPDATE_NAME)
    self.cooldownArmed = false
    self.pendingMsg = nil
  end

  self:EnsureOverlay()
  self:ApplyTextScale()
  self:ApplyOverlayPosition()

  local sv = self:SV()
  if sv and sv.enabled and sv.showCSA and sv.keepVisible then
    self:ShowBigMovable(self.ui.lastMessage or "Reset notification will appear here")
  else
    self:HideBigNow()
  end
end

function KRT.KWR:OnDeactivated() self.deactivated = true end

function KRT.KWR:Initialize()
  self:SeedDifficultyFromGame()
  self:EnsureOverlay()
  self:ApplyTextScale()
  self:ApplyOverlayPosition()

  EM:RegisterForEvent(ADDON_NAME .. "_KWR_Deactivated", EVENT_PLAYER_DEACTIVATED, function() self:OnDeactivated() end)

  EM:RegisterForEvent(ADDON_NAME .. "_KWR_Vet1", EVENT_VETERAN_DIFFICULTY_CHANGED, function(_, _, isDifficult)
    self:UpdateDifficulty(isDifficult and self.DIFF_VETERAN or self.DIFF_NORMAL)
  end)

  EM:RegisterForEvent(ADDON_NAME .. "_KWR_Vet2", EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, function(_, isVeteranDifficulty)
    self:UpdateDifficulty(isVeteranDifficulty and self.DIFF_VETERAN or self.DIFF_NORMAL)
  end)

  EM:RegisterForEvent(ADDON_NAME .. "_KWR_Joined", EVENT_GROUP_MEMBER_JOINED, function(_, _, isPlayer)
    if isPlayer then self:SeedDifficultyFromGame() end
  end)
  EM:AddFilterForEvent(ADDON_NAME .. "_KWR_Joined", EVENT_GROUP_MEMBER_JOINED, REGISTER_FILTER_UNIT_TAG, "player")

  EM:RegisterForEvent(ADDON_NAME .. "_KWR_Left", EVENT_GROUP_MEMBER_LEFT, function(_, _, isPlayer)
    if isPlayer then self:SeedDifficultyFromGame() end
  end)
  EM:AddFilterForEvent(ADDON_NAME .. "_KWR_Left", EVENT_GROUP_MEMBER_LEFT, REGISTER_FILTER_UNIT_TAG, "player")

  EM:RegisterForEvent(ADDON_NAME .. "_KWR_Activated", EVENT_PLAYER_ACTIVATED, function()
    self:OnPlayerActivated()
  end)
end

-- =========================================================

local function SV() return KRT.sv end

function KRT.KWR:GetLAMSubmenu()
    return {
      type = "submenu",
      name = "Kwibus Reset",
      controls = {
        { type = "checkbox", name = "Enable Reset notifications",
          getFunc = function() return SV().kwr.enabled end,
          setFunc = function(v) SV().kwr.enabled = v; if not v then KRT.KWR:HideBigNow() end end,
          width = "full",
        },
        { type = "checkbox", name = "Show on-screen notification",
          getFunc = function() return SV().kwr.showCSA end,
          setFunc = function(v) SV().kwr.showCSA = v; if not v then KRT.KWR:HideBigNow() end end,
          width = "full",
          disabled = function() return not SV().kwr.enabled end,
        },
        { type = "checkbox", name = "Keep on screen (for moving)",
          getFunc = function() return SV().kwr.keepVisible end,
          setFunc = function(v)
            SV().kwr.keepVisible = v
            KRT.KWR:EnsureOverlay()
            if v and SV().kwr.showCSA then
              KRT.KWR:ShowBigMovable(KRT.KWR.ui.lastMessage or "Reset notification will appear here")
            else
              KRT.KWR:HideBigNow()
            end
          end,
          width = "full",
          disabled = function() return not SV().kwr.enabled end,
        },
        { type = "colorpicker", name = "Notification color",
          getFunc = function()
            local c = SV().kwr.color
            return c.r, c.g, c.b
          end,
          setFunc = function(r, g, b)
            local c = SV().kwr.color
            c.r, c.g, c.b = r, g, b
            if SV().kwr.keepVisible and SV().kwr.showCSA then
              KRT.KWR:ShowBigMovable(KRT.KWR.ui.lastMessage or "Reset notification will appear here")
            end
          end,
          width = "full",
          disabled = function() return not SV().kwr.enabled end,
        },
        { type = "slider", name = "Text size (percent)", min = 50, max = 200, step = 5,
          getFunc = function() return math.floor((SV().kwr.textScale or 1.0) * 100 + 0.5) end,
          setFunc = function(v)
            SV().kwr.textScale = zo_clamp((tonumber(v) or 100) / 100, 0.5, 2.0)
            KRT.KWR:EnsureOverlay()
            KRT.KWR:ApplyTextScale()
          end,
          width = "full",
          disabled = function() return not SV().kwr.enabled end,
        },
        { type = "slider", name = "Show time (seconds)", min = 1, max = 10, step = 1,
          getFunc = function() return math.floor((SV().kwr.lifespanMs or 5000) / 1000) end,
          setFunc = function(v) SV().kwr.lifespanMs = v * 1000 end,
          width = "full",
          disabled = function() return not SV().kwr.enabled end,
        },
        { type = "checkbox", name = "Show chat message",
          getFunc = function() return SV().kwr.showChat end,
          setFunc = function(v) SV().kwr.showChat = v end,
          width = "full",
          disabled = function() return not SV().kwr.enabled end,
        },
        { type = "button", name = "Reset horizontal position",
          func = function() SV().kwr.posX = 0; KRT.KWR:ApplyOverlayPosition() end,
          width = "half",
          disabled = function() return not SV().kwr.enabled or not SV().kwr.keepVisible end,
        },
        { type = "button", name = "Reset vertical position",
          func = function() SV().kwr.posY = DEFAULTS.kwr.posY; KRT.KWR:ApplyOverlayPosition() end,
          width = "half",
          disabled = function() return not SV().kwr.enabled or not SV().kwr.keepVisible end,
        },
      },
    }
end

KRT:RegisterModule(KRT.KWR)
