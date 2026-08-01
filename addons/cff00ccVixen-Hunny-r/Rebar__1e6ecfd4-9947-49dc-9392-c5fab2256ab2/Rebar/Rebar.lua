local LAM2 = LibAddonMenu2

Rebar = {
  name = "Rebar",
  version = 6.0,

  default = {
    offsetX = 0,
    offsetY = -120,
    movable = true,
    layoutPresetVersion = 0,

    barWidth = 230,
    barHeight = 18,
    fontSize = 13,
    lowResourceThreshold = 0.30,

    healthOffsetX = 0,
    healthOffsetY = -34,
    magickaOffsetX = -126,
    magickaOffsetY = 22,
    staminaOffsetX = 126,
    staminaOffsetY = 22,

    healthScale = 1.00,
    magickaScale = 1.00,
    staminaScale = 1.00,

    healthAlpha = 1.00,
    magickaAlpha = 1.00,
    staminaAlpha = 1.00,

    healthColorR = 0.90,
    healthColorG = 0.28,
    healthColorB = 0.18,

    magickaColorR = 0.24,
    magickaColorG = 0.44,
    magickaColorB = 0.95,

    staminaColorR = 0.24,
    staminaColorG = 0.86,
    staminaColorB = 0.36,

    fancyMode = false,
    showBarLabels = false,
    lowResourcePulse = false,
    glowStrength = 1.00,

    animateBars = true,
    animationSpeed = 14.00,
    animationGainSpeed = 17.00,
    animationLossSpeed = 20.00,
    damageTrail = true,
    damageTrailSpeed = 4.00,
    animateRestoreText = true,
    restoreAnimDuration = 0.55,
    restoreAnimScale = 0.18,
  },

  sv = nil,
  svVersion = 2,
  svName = "RebarVars",
}

local UPDATE_INTERVAL_MS = 50
local RESTORE_INTERVAL_SECONDS = 1.0
local shield = 0

local RESOURCE_ORDER = { "health", "magicka", "stamina" }
local RESOURCE_INFO = {
  health = {
    power = COMBAT_MECHANIC_FLAGS_HEALTH,
    title = "HEALTH",
    key = "health",
  },
  magicka = {
    power = COMBAT_MECHANIC_FLAGS_MAGICKA,
    title = "MAGICKA",
    key = "magicka",
  },
  stamina = {
    power = COMBAT_MECHANIC_FLAGS_STAMINA,
    title = "STAMINA",
    key = "stamina",
  },
}

local function Clamp(v, minValue, maxValue)
  if v < minValue then return minValue end
  if v > maxValue then return maxValue end
  return v
end

local function Round(v)
  return math.floor(v + 0.5)
end

local function FormatNumber(value)
  local absValue = math.abs(value)
  if absValue >= 1000000 then
    return string.format("%.1fm", value / 1000000)
  end
  if absValue >= 1000 then
    return string.format("%.1fk", value / 1000)
  end
  return tostring(Round(value))
end

local function FormatSigned(value)
  if value >= 0 then
    return "+" .. FormatNumber(value)
  end
  return "-" .. FormatNumber(math.abs(value))
end

local function MakeFont(isBold, size)
  local fontSize = Clamp(Round(size), 8, 48)
  local face = isBold and "$(BOLD_FONT)" or "$(MEDIUM_FONT)"
  return string.format("%s|%d|soft-shadow-thin", face, fontSize)
end

function Rebar.NormalizeSavedVars()
  for key, value in pairs(Rebar.default) do
    if Rebar.sv[key] == nil then
      Rebar.sv[key] = value
    end
  end
end

function Rebar.ApplyLayoutPresetIfNeeded()
  local targetPresetVersion = 2
  local currentPresetVersion = Rebar.sv.layoutPresetVersion or 0

  if currentPresetVersion >= targetPresetVersion then
    return
  end

  Rebar.sv.barWidth = Rebar.default.barWidth
  Rebar.sv.barHeight = Rebar.default.barHeight
  Rebar.sv.healthOffsetX = Rebar.default.healthOffsetX
  Rebar.sv.healthOffsetY = Rebar.default.healthOffsetY
  Rebar.sv.magickaOffsetX = Rebar.default.magickaOffsetX
  Rebar.sv.magickaOffsetY = Rebar.default.magickaOffsetY
  Rebar.sv.staminaOffsetX = Rebar.default.staminaOffsetX
  Rebar.sv.staminaOffsetY = Rebar.default.staminaOffsetY
  Rebar.sv.layoutPresetVersion = targetPresetVersion
end

function Rebar.GetPulseAlpha(percent)
  if not Rebar.sv or not Rebar.sv.lowResourcePulse or percent > Rebar.sv.lowResourceThreshold then
    return 0
  end

  local threshold = math.max(Rebar.sv.lowResourceThreshold or 0.30, 0.01)
  local danger = Clamp((threshold - percent) / threshold, 0, 1)
  local wave = (math.sin(GetFrameTimeSeconds() * 8) + 1) * 0.5
  return 0.20 + (0.45 * danger * wave)
end

function Rebar.SmoothValue(current, target, speed, deltaSeconds)
  if current == nil then
    return target
  end

  if deltaSeconds <= 0 then
    return current
  end

  local safeSpeed = Clamp(speed or 10, 0.01, 100)
  local blend = 1 - math.exp(-safeSpeed * deltaSeconds)
  local value = current + ((target - current) * blend)

  local snapDistance = math.max(0.5, math.abs(target) * 0.0005)
  if math.abs(target - value) < snapDistance then
    return target
  end

  return value
end

function Rebar.GetResourceValues()
  local data = {}

  for _, key in ipairs(RESOURCE_ORDER) do
    local info = RESOURCE_INFO[key]
    local current, maxPower = GetUnitPower("player", info.power)

    current = current or 0
    maxPower = maxPower or 0

    data[key] = {
      current = current,
      max = maxPower,
      percent = maxPower > 0 and Clamp(current / maxPower, 0, 1) or 0,
    }
  end

  return data
end

function Rebar.HideOriginalBars()
  if ZO_PlayerAttributeHealth then ZO_PlayerAttributeHealth:SetHidden(true) end
  if ZO_PlayerAttributeMagicka then ZO_PlayerAttributeMagicka:SetHidden(true) end
  if ZO_PlayerAttributeStamina then ZO_PlayerAttributeStamina:SetHidden(true) end
  if ZO_ActionBar1KeybindBG then ZO_ActionBar1KeybindBG:SetHidden(true) end
end

function Rebar.SizeLock()
  if not PLAYER_ATTRIBUTE_BARS or not PLAYER_ATTRIBUTE_BARS.attributeVisualizer then return end

  for _, visualizer in pairs(PLAYER_ATTRIBUTE_BARS.attributeVisualizer.visualModules) do
    if visualizer.expandedWidth then
      visualizer.expandedWidth = visualizer.normalWidth
      visualizer.shrunkWidth = visualizer.normalWidth
    end
  end
end

function Rebar.CreateMover()
  if Rebar.mover then return end

  local mover = WINDOW_MANAGER:CreateTopLevelWindow("RebarMover")
  mover:SetDimensions(760, 360)
  mover:SetMovable(true)
  mover:SetMouseEnabled(true)
  mover:SetClampedToScreen(true)
  mover:SetDrawTier(DT_HIGH)
  mover:SetDrawLayer(DL_OVERLAY)

  mover:SetHandler("OnMouseDown", function(self, button)
    if button == MOUSE_BUTTON_INDEX_LEFT and Rebar.sv and Rebar.sv.movable then
      self:StartMoving()
    end
  end)

  mover:SetHandler("OnMouseUp", function(self, button)
    if button == MOUSE_BUTTON_INDEX_LEFT then
      self:StopMovingOrResizing()
    end
  end)

  mover:SetHandler("OnMoveStop", function(self)
    local _, _, _, x, y = self:GetAnchor(0)
    Rebar.sv.offsetX = Round(x)
    Rebar.sv.offsetY = Round(y)
    Rebar.Reposition()
  end)

  Rebar.mover = mover
end

function Rebar.UpdateMoverState()
  if not Rebar.mover or not Rebar.sv then return end

  local unlocked = Rebar.sv.movable
  Rebar.mover:SetMouseEnabled(unlocked)
end

function Rebar.ApplyBarFonts(bar)
  if not bar or not Rebar.sv then return end

  local base = Rebar.sv.fontSize or 14
  local small = Clamp(base - 2, 8, 48)

  bar.restoreLabel:SetFont(MakeFont(false, small))
  bar.warningLabel:SetFont(MakeFont(true, small))
  bar.titleLabel:SetFont(MakeFont(true, base))
  bar.valueLabel:SetFont(MakeFont(false, base))
end

function Rebar.CreateResourceBar(controlName, parent, title)
  local bar = {}

  bar.panel = WINDOW_MANAGER:CreateControl(controlName, parent, CT_CONTROL)
  bar.panel:SetDimensions(230, 36)

  bar.restoreLabel = WINDOW_MANAGER:CreateControl(controlName .. "Restore", bar.panel, CT_LABEL)
  bar.restoreLabel:SetAnchor(TOP, bar.panel, TOP, 0, 0)
  bar.restoreLabel:SetFont("ZoFontGameSmall")
  bar.restoreLabel:SetColor(0.88, 0.88, 0.88, 0.85)
  bar.restoreLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  bar.restoreLabel:SetText("+0/s")

  bar.warningLabel = WINDOW_MANAGER:CreateControl(controlName .. "Warn", bar.panel, CT_LABEL)
  bar.warningLabel:SetAnchor(RIGHT, bar.panel, RIGHT, -6, 21)
  bar.warningLabel:SetFont("ZoFontGameSmall")
  bar.warningLabel:SetColor(1.00, 0.30, 0.25, 0.95)
  bar.warningLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  bar.warningLabel:SetText("LOW")
  bar.warningLabel:SetHidden(true)

  bar.frame = WINDOW_MANAGER:CreateControl(controlName .. "Frame", bar.panel, CT_BACKDROP)
  bar.frame:SetAnchor(TOPLEFT, bar.panel, TOPLEFT, 0, 12)
  bar.frame:SetDimensions(230, 18)
  bar.frame:SetCenterColor(0.01, 0.01, 0.01, 0.88)
  bar.frame:SetEdgeColor(0.18, 0.18, 0.18, 0.95)
  bar.frame:SetEdgeTexture("", 1, 1, 1)

  bar.statusBg = WINDOW_MANAGER:CreateControl(controlName .. "StatusBg", bar.frame, CT_STATUSBAR)
  bar.statusBg:SetAnchor(TOPLEFT, bar.frame, TOPLEFT, 2, 2)
  bar.statusBg:SetAnchor(BOTTOMRIGHT, bar.frame, BOTTOMRIGHT, -2, -2)
  bar.statusBg:SetMinMax(0, 1)
  bar.statusBg:SetValue(1)
  if bar.statusBg.SetTexture then
    bar.statusBg:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
  end
  if bar.statusBg.SetColor then
    bar.statusBg:SetColor(0.15, 0.15, 0.15, 0.85)
  end

  bar.trail = WINDOW_MANAGER:CreateControl(controlName .. "Trail", bar.frame, CT_STATUSBAR)
  bar.trail:SetAnchor(TOPLEFT, bar.frame, TOPLEFT, 2, 2)
  bar.trail:SetAnchor(BOTTOMRIGHT, bar.frame, BOTTOMRIGHT, -2, -2)
  bar.trail:SetMinMax(0, 1)
  bar.trail:SetValue(1)
  if bar.trail.SetTexture then
    bar.trail:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
  end
  if bar.trail.SetColor then
    bar.trail:SetColor(1, 1, 1, 0.18)
  end

  bar.status = WINDOW_MANAGER:CreateControl(controlName .. "Status", bar.frame, CT_STATUSBAR)
  bar.status:SetAnchor(TOPLEFT, bar.frame, TOPLEFT, 2, 2)
  bar.status:SetAnchor(BOTTOMRIGHT, bar.frame, BOTTOMRIGHT, -2, -2)
  bar.status:SetMinMax(0, 1)
  bar.status:SetValue(1)
  if bar.status.SetTexture then
    bar.status:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
  end

  bar.highlight = WINDOW_MANAGER:CreateControl(controlName .. "Highlight", bar.frame, CT_BACKDROP)
  bar.highlight:SetAnchor(TOPLEFT, bar.frame, TOPLEFT, 1, 1)
  bar.highlight:SetAnchor(TOPRIGHT, bar.frame, TOPRIGHT, -1, 1)
  bar.highlight:SetHeight(7)
  bar.highlight:SetCenterColor(1, 1, 1, 0.12)
  bar.highlight:SetEdgeColor(0, 0, 0, 0)

  bar.glow = WINDOW_MANAGER:CreateControl(controlName .. "Glow", bar.frame, CT_BACKDROP)
  bar.glow:SetAnchorFill(bar.frame)
  bar.glow:SetCenterColor(1.00, 1.00, 1.00, 0)
  bar.glow:SetEdgeColor(1.00, 1.00, 1.00, 0)
  bar.glow:SetEdgeTexture("", 1, 1, 1)
  bar.glow:SetHidden(true)

  bar.titleLabel = WINDOW_MANAGER:CreateControl(controlName .. "Title", bar.frame, CT_LABEL)
  bar.titleLabel:SetAnchor(LEFT, bar.frame, LEFT, 8, 0)
  bar.titleLabel:SetFont("ZoFontGameBold")
  bar.titleLabel:SetColor(0.88, 0.88, 0.88, 0.95)
  bar.titleLabel:SetText(title)

  bar.valueLabel = WINDOW_MANAGER:CreateControl(controlName .. "Value", bar.frame, CT_LABEL)
  bar.valueLabel:SetAnchor(CENTER, bar.frame, CENTER, 0, 0)
  bar.valueLabel:SetFont("ZoFontGame")
  bar.valueLabel:SetColor(0.98, 0.98, 0.98, 0.95)
  bar.valueLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  bar.valueLabel:SetText("0 / 0")

  bar.displayValue = nil
  bar.trailValue = nil
  bar.restoreAnimStart = 0
  bar.restoreAnimDirection = 0

  Rebar.ApplyBarFonts(bar)

  return bar
end

function Rebar.CreateCustomBars()
  if Rebar.custom then return end

  local root = WINDOW_MANAGER:CreateTopLevelWindow("RebarCustomRoot")
  root:SetDimensions(760, 360)
  root:SetMovable(false)
  root:SetMouseEnabled(false)
  root:SetClampedToScreen(true)
  root:SetDrawTier(DT_HIGH)
  root:SetDrawLayer(DL_OVERLAY)
  root:SetAnchor(CENTER, Rebar.mover, CENTER, 0, 0)

  Rebar.custom = {
    root = root,
    bars = {},
    restoreRates = { health = 0, magicka = 0, stamina = 0 },
    sampleValues = { health = 0, magicka = 0, stamina = 0 },
    sampleTime = 0,
    lastUpdateTime = 0,
  }

  Rebar.custom.bars.health = Rebar.CreateResourceBar("RebarHealth", root, RESOURCE_INFO.health.title)
  Rebar.custom.bars.magicka = Rebar.CreateResourceBar("RebarMagicka", root, RESOURCE_INFO.magicka.title)
  Rebar.custom.bars.stamina = Rebar.CreateResourceBar("RebarStamina", root, RESOURCE_INFO.stamina.title)
end

function Rebar.ApplyBarTheme(key, bar, percent)
  local colorR = Rebar.sv[key .. "ColorR"]
  local colorG = Rebar.sv[key .. "ColorG"]
  local colorB = Rebar.sv[key .. "ColorB"]
  local scale = Rebar.sv[key .. "Scale"]
  local alpha = Rebar.sv[key .. "Alpha"]

  bar.panel:SetScale(scale or 1)
  bar.panel:SetAlpha(alpha or 1)

  local darkR = Clamp(colorR * 0.65, 0, 1)
  local darkG = Clamp(colorG * 0.65, 0, 1)
  local darkB = Clamp(colorB * 0.65, 0, 1)

  local fillTexture = "EsoUI/Art/Miscellaneous/progressbar_genericfill.dds"

  if bar.status.SetTexture then
    bar.status:SetTexture(fillTexture)
  end

  if bar.trail and bar.trail.SetTexture then
    bar.trail:SetTexture(fillTexture)
  end

  if bar.status.SetColor then
    bar.status:SetColor(colorR, colorG, colorB, 0.98)
  end

  if bar.status.SetGradientColors then
    bar.status:SetGradientColors(darkR, darkG, darkB, 1, colorR, colorG, colorB, 1)
  end

  if bar.statusBg and bar.statusBg.SetColor then
    bar.statusBg:SetColor(Clamp(darkR * 0.35, 0, 1), Clamp(darkG * 0.35, 0, 1), Clamp(darkB * 0.35, 0, 1), 0.85)
  end

  if bar.trail then
    if Rebar.sv.damageTrail then
      local trailR = Clamp(colorR * 0.85, 0, 1)
      local trailG = Clamp(colorG * 0.85, 0, 1)
      local trailB = Clamp(colorB * 0.85, 0, 1)
      if bar.trail.SetColor then
        bar.trail:SetColor(trailR, trailG, trailB, 0.55)
      end
      if bar.trail.SetGradientColors then
        bar.trail:SetGradientColors(Clamp(trailR * 0.75, 0, 1), Clamp(trailG * 0.75, 0, 1), Clamp(trailB * 0.75, 0, 1), 1, trailR, trailG, trailB, 1)
      end
      bar.trail:SetHidden(false)
    else
      bar.trail:SetHidden(true)
    end
  end

  local pulseAlpha = Rebar.GetPulseAlpha(percent)
  bar.frame:SetEdgeColor(0.16, 0.16, 0.16, Clamp(0.78 + pulseAlpha, 0.60, 1.00))

  if bar.highlight then
    bar.highlight:SetCenterColor(1, 1, 1, 0.10)
  end

  if percent <= Rebar.sv.lowResourceThreshold then
    bar.warningLabel:SetColor(1.00, 0.30, 0.25, Clamp(0.55 + pulseAlpha, 0.35, 0.95))
    bar.frame:SetEdgeColor(Clamp(colorR * 1.10, 0, 1), Clamp(colorG * 1.10, 0, 1), Clamp(colorB * 1.10, 0, 1), Clamp(0.60 + pulseAlpha, 0.45, 1.00))
  else
    bar.warningLabel:SetColor(1.00, 0.30, 0.25, 0.95)
  end

  if Rebar.sv.showBarLabels then
    bar.titleLabel:SetHidden(false)
  else
    bar.titleLabel:SetHidden(true)
  end
end

function Rebar.LayoutCustomBars()
  if not Rebar.custom or not Rebar.sv then return end

  local panelHeight = Rebar.sv.barHeight + 18
  local maxX = math.abs(Rebar.sv.healthOffsetX)
  local minY = Rebar.sv.healthOffsetY
  local maxY = Rebar.sv.healthOffsetY

  for _, key in ipairs(RESOURCE_ORDER) do
    local x = Rebar.sv[key .. "OffsetX"]
    local y = Rebar.sv[key .. "OffsetY"]

    if math.abs(x) > maxX then
      maxX = math.abs(x)
    end

    if y < minY then
      minY = y
    end

    if y > maxY then
      maxY = y
    end
  end

  local moverWidth = math.floor((maxX * 2) + Rebar.sv.barWidth + 48)
  local moverHeight = math.floor((maxY - minY) + panelHeight + 48)

  local minimumWidth = Rebar.sv.barWidth + 48
  local minimumHeight = panelHeight + 48

  if moverWidth < minimumWidth then
    moverWidth = minimumWidth
  end

  if moverHeight < minimumHeight then
    moverHeight = minimumHeight
  end

  Rebar.mover:SetDimensions(moverWidth, moverHeight)
  Rebar.custom.root:SetDimensions(moverWidth, moverHeight)

  for _, key in ipairs(RESOURCE_ORDER) do
    local bar = Rebar.custom.bars[key]
    local x = Rebar.sv[key .. "OffsetX"]
    local y = Rebar.sv[key .. "OffsetY"]

    bar.panel:ClearAnchors()
    bar.panel:SetAnchor(CENTER, Rebar.custom.root, CENTER, x, y)
    bar.panel:SetDimensions(Rebar.sv.barWidth, panelHeight)

    bar.frame:SetDimensions(Rebar.sv.barWidth, Rebar.sv.barHeight)

    if bar.highlight then
      bar.highlight:SetHeight(math.max(4, math.floor(Rebar.sv.barHeight * 0.42)))
    end
  end
end

function Rebar.UpdateRestoreRates(resources)
  if not Rebar.custom then return end

  local now = GetFrameTimeSeconds()
  if Rebar.custom.sampleTime == 0 then
    Rebar.custom.sampleTime = now
    for _, key in ipairs(RESOURCE_ORDER) do
      Rebar.custom.sampleValues[key] = resources[key].current
    end
    return
  end

  if (now - Rebar.custom.sampleTime) < RESTORE_INTERVAL_SECONDS then
    return
  end

  for _, key in ipairs(RESOURCE_ORDER) do
    local delta = resources[key].current - Rebar.custom.sampleValues[key]
    Rebar.custom.restoreRates[key] = delta
    Rebar.custom.sampleValues[key] = resources[key].current

    local bar = Rebar.custom.bars and Rebar.custom.bars[key]
    if bar and delta ~= 0 then
      bar.restoreAnimStart = now
      bar.restoreAnimDirection = delta > 0 and 1 or -1
    end
  end

  Rebar.custom.sampleTime = now
end

function Rebar.UpdateRestoreAnimation(key, bar)
  if not bar or not bar.restoreLabel or not Rebar.sv then return end

  local colorR, colorG, colorB = 0.88, 0.88, 0.88
  local alpha = 0.85
  local yOffset = 0
  local scale = 1

  if Rebar.sv.animateRestoreText then
    local direction = bar.restoreAnimDirection or 0
    local duration = Clamp(Rebar.sv.restoreAnimDuration or 0.55, 0.10, 2.00)
    local elapsed = GetFrameTimeSeconds() - (bar.restoreAnimStart or 0)

    if direction ~= 0 and elapsed >= 0 and elapsed < duration then
      local t = Clamp(elapsed / duration, 0, 1)
      local pulse = math.sin(t * math.pi)
      local popScale = Clamp(Rebar.sv.restoreAnimScale or 0.18, 0, 0.80)

      scale = 1 + (pulse * popScale)
      yOffset = -Round(6 * pulse)
      alpha = Clamp(alpha + (0.25 * pulse), 0, 1)

      if direction > 0 then
        local baseR = Rebar.sv[key .. "ColorR"] or 1
        local baseG = Rebar.sv[key .. "ColorG"] or 1
        local baseB = Rebar.sv[key .. "ColorB"] or 1

        colorR = Clamp(baseR * 1.25, 0, 1)
        colorG = Clamp(baseG * 1.25, 0, 1)
        colorB = Clamp(baseB * 1.25, 0, 1)
      else
        colorR, colorG, colorB = 1.00, 0.40, 0.35
      end
    end
  end

  bar.restoreLabel:ClearAnchors()
  bar.restoreLabel:SetAnchor(TOP, bar.panel, TOP, 0, yOffset)

  if bar.restoreLabel.SetScale then
    bar.restoreLabel:SetScale(scale)
  end

  bar.restoreLabel:SetColor(colorR, colorG, colorB, alpha)
end

function Rebar.UpdateBarText(key, bar, resource)
  local current = resource.current
  local maxPower = resource.max
  local percent = resource.percent

  local restoreRate = 0
  if Rebar.custom and Rebar.custom.restoreRates then
    restoreRate = Rebar.custom.restoreRates[key] or 0
  end

  bar.restoreLabel:SetText(string.format("%s/s", FormatSigned(restoreRate)))

  if percent <= Rebar.sv.lowResourceThreshold then
    bar.warningLabel:SetHidden(false)
    bar.warningLabel:SetText("LOW")
  else
    bar.warningLabel:SetHidden(true)
  end

  if key == "health" then
    local shieldText = ""
    if shield > 0 then
      shieldText = " +Shield " .. FormatNumber(shield)
    end

    bar.valueLabel:SetText(string.format("%s / %s%s", FormatNumber(current), FormatNumber(maxPower), shieldText))
  else
    bar.valueLabel:SetText(string.format("%s / %s", FormatNumber(current), FormatNumber(maxPower)))
  end
end

function Rebar.OnPowerUpdate(_, unitTag, _, powerType)
  if unitTag ~= "player" then return end

  if powerType == COMBAT_MECHANIC_FLAGS_HEALTH or powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
    Rebar.UpdateCustomBars()
  end
end

function Rebar.UpdateCustomBars()
  if not Rebar.sv or not Rebar.custom then return end

  Rebar.HideOriginalBars()

  local resources = Rebar.GetResourceValues()
  Rebar.UpdateRestoreRates(resources)

  local now = GetFrameTimeSeconds()
  local deltaSeconds = UPDATE_INTERVAL_MS / 2000

  if Rebar.custom.lastUpdateTime and Rebar.custom.lastUpdateTime > 0 then
    deltaSeconds = Clamp(now - Rebar.custom.lastUpdateTime, 0, 0.25)
  end

  Rebar.custom.lastUpdateTime = now

  for _, key in ipairs(RESOURCE_ORDER) do
    local bar = Rebar.custom.bars[key]
    local resource = resources[key]

    if bar and resource then
      Rebar.ApplyBarFonts(bar)

      local maxPower = resource.max > 0 and resource.max or 1
      local targetValue = Clamp(resource.current, 0, maxPower)

      if bar.displayValue == nil then
        bar.displayValue = targetValue
      end

      if bar.trailValue == nil then
        bar.trailValue = targetValue
      end

      if Rebar.sv.animateBars then
        local legacySpeed = Rebar.sv.animationSpeed or 14
        local gainSpeed = Rebar.sv.animationGainSpeed or (legacySpeed * 1.10)
        local lossSpeed = Rebar.sv.animationLossSpeed or (legacySpeed * 0.82)
        local mainSpeed = targetValue >= bar.displayValue and gainSpeed or lossSpeed

        if targetValue < bar.displayValue and maxPower > 0 then
          local lossPercent = Clamp((bar.displayValue - targetValue) / maxPower, 0, 1)
          mainSpeed = mainSpeed + (lossPercent * 6.0)
        end

        bar.displayValue = Rebar.SmoothValue(bar.displayValue, targetValue, mainSpeed, deltaSeconds)

        if Rebar.sv.damageTrail then
          if targetValue < bar.trailValue then
            bar.trailValue = Rebar.SmoothValue(bar.trailValue, targetValue, Rebar.sv.damageTrailSpeed or 3, deltaSeconds)
          else
            bar.trailValue = targetValue
          end
        else
          bar.trailValue = bar.displayValue
        end
      else
        bar.displayValue = targetValue
        bar.trailValue = targetValue
      end

      local displayValue = Clamp(bar.displayValue, 0, maxPower)
      local trailValue = Clamp(bar.trailValue, 0, maxPower)

      if trailValue < displayValue then
        trailValue = displayValue
      end

      if bar.statusBg then
        bar.statusBg:SetMinMax(0, maxPower)
        bar.statusBg:SetValue(maxPower)
      end

      if bar.trail then
        bar.trail:SetMinMax(0, maxPower)
        bar.trail:SetValue(trailValue)
      end

      bar.status:SetMinMax(0, maxPower)
      bar.status:SetValue(displayValue)

      Rebar.ApplyBarTheme(key, bar, resource.percent)
      Rebar.UpdateBarText(key, bar, resource)
      Rebar.UpdateRestoreAnimation(key, bar)
    end
  end
end

function Rebar.Reposition()
  if not Rebar.sv then return end

  if not Rebar.mover then
    Rebar.CreateMover()
  end

  if not Rebar.custom then
    Rebar.CreateCustomBars()
  end

  Rebar.mover:ClearAnchors()
  Rebar.mover:SetAnchor(CENTER, GuiRoot, CENTER, Rebar.sv.offsetX, Rebar.sv.offsetY)

  Rebar.LayoutCustomBars()
  Rebar.UpdateMoverState()
  Rebar.UpdateCustomBars()
end

function Rebar.StartUpdateLoop()
  EVENT_MANAGER:UnregisterForUpdate(Rebar.name .. "CustomBarsUpdate")
  EVENT_MANAGER:RegisterForUpdate(Rebar.name .. "CustomBarsUpdate", UPDATE_INTERVAL_MS, Rebar.UpdateCustomBars)
end

function Rebar.UnitAttributeVisual(evt, unitTag, unitAttributeVisual, _, attributeType, _, value1, value2)
  if unitTag ~= "player" then return end
  if unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
  if attributeType ~= ATTRIBUTE_HEALTH then return end

  if evt == EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED then
    shield = shield + ((value2 or 0) - (value1 or 0))
  elseif evt == EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED then
    shield = shield + (value1 or 0)
  elseif evt == EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED then
    shield = shield - (value1 or 0)
  end

  if shield < 0 then
    shield = 0
  end
end

function Rebar.PlayerActivate()
  shield = 0

  if Rebar.custom then
    Rebar.custom.sampleTime = 0
    Rebar.custom.lastUpdateTime = 0

    for _, key in ipairs(RESOURCE_ORDER) do
      local bar = Rebar.custom.bars and Rebar.custom.bars[key]
      if bar then
        bar.displayValue = nil
        bar.trailValue = nil
        bar.restoreAnimStart = 0
        bar.restoreAnimDirection = 0
      end
    end
  end

  Rebar.Reposition()
end

function Rebar.HookAttributeBarAnchors()
  if not PLAYER_ATTRIBUTE_BARS then return end

  if PLAYER_ATTRIBUTE_BARS.UpdateAnchors then
    ZO_PostHook(PLAYER_ATTRIBUTE_BARS, "UpdateAnchors", function()
      zo_callLater(function()
        Rebar.HideOriginalBars()
      end, 0)
    end)
  end

  if PLAYER_ATTRIBUTE_BARS.OnUnitAttributesUpdated then
    ZO_PostHook(PLAYER_ATTRIBUTE_BARS, "OnUnitAttributesUpdated", function()
      zo_callLater(function()
        Rebar.HideOriginalBars()
      end, 0)
    end)
  end
end

function Rebar.RemoveArmourBuff()
  RedirectTexture("esoui/art/unitattributevisualizer/attributebar_dynamic_increasedarmor_frame.dds", "Rebar/Rebar.dds")
  RedirectTexture("esoui/art/unitattributevisualizer/attributebar_dynamic_increasedarmor_bg.dds", "Rebar/Rebar.dds")
  RedirectTexture("esoui/art/tooltips/munge_overlay.dds", "Rebar/Rebar.dds")
end

function Rebar.reanchor()
  Rebar.Reposition()
end

function Rebar:CreateSettingsWindow()
  local panelData = {
    type = "panel",
    name = "Rebar",
    displayName = "Rebar",
    author = "|cff9beaVixen Hunny|r",
    version = Rebar.version,
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local function RefreshLayout()
    zo_callLater(Rebar.Reposition, 0)
  end

  local function RefreshVisuals()
    zo_callLater(Rebar.UpdateCustomBars, 0)
  end

  local optionsData = {
    {
      type = "header",
      name = "Rebar - Custom Attribute Bars",
    },
    {
      type = "description",
      text = "HAB-style bars are active. Resource restore values above each bar update every 1000ms.",
    },
    {
      type = "header",
      name = "Global",
    },
    {
      type = "checkbox",
      name = "Unlock Drag Movement",
      getFunc = function() return Rebar.sv.movable end,
      setFunc = function(v)
        Rebar.sv.movable = v
        Rebar.UpdateMoverState()
      end,
      default = Rebar.default.movable,
    },
    {
      type = "slider",
      name = "Group X",
      min = -3000, max = 3000, step = 2,
      getFunc = function() return Rebar.sv.offsetX end,
      setFunc = function(v)
        Rebar.sv.offsetX = v
        RefreshLayout()
      end,
      default = Rebar.default.offsetX,
    },
    {
      type = "slider",
      name = "Group Y",
      min = -3000, max = 3000, step = 2,
      getFunc = function() return Rebar.sv.offsetY end,
      setFunc = function(v)
        Rebar.sv.offsetY = v
        RefreshLayout()
      end,
      default = Rebar.default.offsetY,
    },
    {
      type = "slider",
      name = "Bar Width",
      min = 160, max = 560, step = 2,
      getFunc = function() return Rebar.sv.barWidth end,
      setFunc = function(v)
        Rebar.sv.barWidth = v
        RefreshLayout()
      end,
      default = Rebar.default.barWidth,
    },
    {
      type = "slider",
      name = "Bar Height",
      min = 12, max = 40, step = 1,
      getFunc = function() return Rebar.sv.barHeight end,
      setFunc = function(v)
        Rebar.sv.barHeight = v
        RefreshLayout()
      end,
      default = Rebar.default.barHeight,
    },
    {
      type = "slider",
      name = "Font Size",
      min = 8, max = 48, step = 1,
      getFunc = function() return Rebar.sv.fontSize end,
      setFunc = function(v)
        Rebar.sv.fontSize = v
        RefreshVisuals()
      end,
      default = Rebar.default.fontSize,
    },
    {
      type = "slider",
      name = "Low Resource Threshold",
      min = 0.10, max = 0.60, step = 0.01,
      getFunc = function() return Rebar.sv.lowResourceThreshold end,
      setFunc = function(v)
        Rebar.sv.lowResourceThreshold = v
        RefreshVisuals()
      end,
      default = Rebar.default.lowResourceThreshold,
    },
    {
      type = "header",
      name = "Style & Animation",
    },
    {
      type = "checkbox",
      name = "Show Bar Titles",
      getFunc = function() return Rebar.sv.showBarLabels end,
      setFunc = function(v)
        Rebar.sv.showBarLabels = v
        RefreshVisuals()
      end,
      default = Rebar.default.showBarLabels,
    },
    {
      type = "checkbox",
      name = "Pulse Low Resource Warning",
      getFunc = function() return Rebar.sv.lowResourcePulse end,
      setFunc = function(v)
        Rebar.sv.lowResourcePulse = v
        RefreshVisuals()
      end,
      default = Rebar.default.lowResourcePulse,
    },
    {
      type = "checkbox",
      name = "Animate Bars",
      getFunc = function() return Rebar.sv.animateBars end,
      setFunc = function(v)
        Rebar.sv.animateBars = v
        RefreshVisuals()
      end,
      default = Rebar.default.animateBars,
    },
    {
      type = "checkbox",
      name = "Animate Restore Values",
      getFunc = function() return Rebar.sv.animateRestoreText end,
      setFunc = function(v)
        Rebar.sv.animateRestoreText = v
        RefreshVisuals()
      end,
      default = Rebar.default.animateRestoreText,
    },
    {
      type = "slider",
      name = "Restore Pop Duration",
      min = 0.10, max = 1.20, step = 0.01,
      getFunc = function() return Rebar.sv.restoreAnimDuration end,
      setFunc = function(v)
        Rebar.sv.restoreAnimDuration = v
      end,
      default = Rebar.default.restoreAnimDuration,
    },
    {
      type = "slider",
      name = "Restore Pop Scale",
      min = 0.00, max = 0.60, step = 0.01,
      getFunc = function() return Rebar.sv.restoreAnimScale end,
      setFunc = function(v)
        Rebar.sv.restoreAnimScale = v
      end,
      default = Rebar.default.restoreAnimScale,
    },
    {
      type = "slider",
      name = "Animation Speed (Legacy)",
      min = 2.00, max = 24.00, step = 0.10,
      getFunc = function() return Rebar.sv.animationSpeed end,
      setFunc = function(v)
        Rebar.sv.animationSpeed = v
      end,
      default = Rebar.default.animationSpeed,
      warning = "Used only when Gain/Loss speeds are not available in older profiles.",
    },
    {
      type = "slider",
      name = "Gain Animation Speed",
      min = 2.00, max = 30.00, step = 0.10,
      getFunc = function() return Rebar.sv.animationGainSpeed end,
      setFunc = function(v)
        Rebar.sv.animationGainSpeed = v
      end,
      default = Rebar.default.animationGainSpeed,
    },
    {
      type = "slider",
      name = "Loss Animation Speed",
      min = 2.00, max = 30.00, step = 0.10,
      getFunc = function() return Rebar.sv.animationLossSpeed end,
      setFunc = function(v)
        Rebar.sv.animationLossSpeed = v
      end,
      default = Rebar.default.animationLossSpeed,
    },
    {
      type = "checkbox",
      name = "Show Damage Loss Trail",
      getFunc = function() return Rebar.sv.damageTrail end,
      setFunc = function(v)
        Rebar.sv.damageTrail = v
        RefreshVisuals()
      end,
      default = Rebar.default.damageTrail,
    },
    {
      type = "slider",
      name = "Damage Trail Speed",
      min = 1.00, max = 12.00, step = 0.10,
      getFunc = function() return Rebar.sv.damageTrailSpeed end,
      setFunc = function(v)
        Rebar.sv.damageTrailSpeed = v
      end,
      default = Rebar.default.damageTrailSpeed,
    },
    {
      type = "slider",
      name = "Legacy Glow Strength",
      min = 0.20, max = 1.60, step = 0.01,
      getFunc = function() return Rebar.sv.glowStrength end,
      setFunc = function(v)
        Rebar.sv.glowStrength = v
      end,
      default = Rebar.default.glowStrength,
      warning = "Legacy setting kept for compatibility. Classic style ignores this value.",
    },
    {
      type = "header",
      name = "Health Bar",
    },
    {
      type = "slider",
      name = "Health X",
      min = -500, max = 500, step = 1,
      getFunc = function() return Rebar.sv.healthOffsetX end,
      setFunc = function(v)
        Rebar.sv.healthOffsetX = v
        RefreshLayout()
      end,
      default = Rebar.default.healthOffsetX,
    },
    {
      type = "slider",
      name = "Health Y",
      min = -500, max = 500, step = 1,
      getFunc = function() return Rebar.sv.healthOffsetY end,
      setFunc = function(v)
        Rebar.sv.healthOffsetY = v
        RefreshLayout()
      end,
      default = Rebar.default.healthOffsetY,
    },
    {
      type = "slider",
      name = "Health Scale",
      min = 0.50, max = 1.80, step = 0.01,
      getFunc = function() return Rebar.sv.healthScale end,
      setFunc = function(v)
        Rebar.sv.healthScale = v
        RefreshVisuals()
      end,
      default = Rebar.default.healthScale,
    },
    {
      type = "slider",
      name = "Health Opacity",
      min = 0.20, max = 1.00, step = 0.01,
      getFunc = function() return Rebar.sv.healthAlpha end,
      setFunc = function(v)
        Rebar.sv.healthAlpha = v
        RefreshVisuals()
      end,
      default = Rebar.default.healthAlpha,
    },
    {
      type = "colorpicker",
      name = "Health Color",
      getFunc = function() return Rebar.sv.healthColorR, Rebar.sv.healthColorG, Rebar.sv.healthColorB end,
      setFunc = function(r, g, b)
        Rebar.sv.healthColorR = r
        Rebar.sv.healthColorG = g
        Rebar.sv.healthColorB = b
        RefreshVisuals()
      end,
      default = { Rebar.default.healthColorR, Rebar.default.healthColorG, Rebar.default.healthColorB },
    },
    {
      type = "header",
      name = "Magicka Bar",
    },
    {
      type = "slider",
      name = "Magicka X",
      min = -500, max = 500, step = 1,
      getFunc = function() return Rebar.sv.magickaOffsetX end,
      setFunc = function(v)
        Rebar.sv.magickaOffsetX = v
        RefreshLayout()
      end,
      default = Rebar.default.magickaOffsetX,
    },
    {
      type = "slider",
      name = "Magicka Y",
      min = -500, max = 500, step = 1,
      getFunc = function() return Rebar.sv.magickaOffsetY end,
      setFunc = function(v)
        Rebar.sv.magickaOffsetY = v
        RefreshLayout()
      end,
      default = Rebar.default.magickaOffsetY,
    },
    {
      type = "slider",
      name = "Magicka Scale",
      min = 0.50, max = 1.80, step = 0.01,
      getFunc = function() return Rebar.sv.magickaScale end,
      setFunc = function(v)
        Rebar.sv.magickaScale = v
        RefreshVisuals()
      end,
      default = Rebar.default.magickaScale,
    },
    {
      type = "slider",
      name = "Magicka Opacity",
      min = 0.20, max = 1.00, step = 0.01,
      getFunc = function() return Rebar.sv.magickaAlpha end,
      setFunc = function(v)
        Rebar.sv.magickaAlpha = v
        RefreshVisuals()
      end,
      default = Rebar.default.magickaAlpha,
    },
    {
      type = "colorpicker",
      name = "Magicka Color",
      getFunc = function() return Rebar.sv.magickaColorR, Rebar.sv.magickaColorG, Rebar.sv.magickaColorB end,
      setFunc = function(r, g, b)
        Rebar.sv.magickaColorR = r
        Rebar.sv.magickaColorG = g
        Rebar.sv.magickaColorB = b
        RefreshVisuals()
      end,
      default = { Rebar.default.magickaColorR, Rebar.default.magickaColorG, Rebar.default.magickaColorB },
    },
    {
      type = "header",
      name = "Stamina Bar",
    },
    {
      type = "slider",
      name = "Stamina X",
      min = -500, max = 500, step = 1,
      getFunc = function() return Rebar.sv.staminaOffsetX end,
      setFunc = function(v)
        Rebar.sv.staminaOffsetX = v
        RefreshLayout()
      end,
      default = Rebar.default.staminaOffsetX,
    },
    {
      type = "slider",
      name = "Stamina Y",
      min = -500, max = 500, step = 1,
      getFunc = function() return Rebar.sv.staminaOffsetY end,
      setFunc = function(v)
        Rebar.sv.staminaOffsetY = v
        RefreshLayout()
      end,
      default = Rebar.default.staminaOffsetY,
    },
    {
      type = "slider",
      name = "Stamina Scale",
      min = 0.50, max = 1.80, step = 0.01,
      getFunc = function() return Rebar.sv.staminaScale end,
      setFunc = function(v)
        Rebar.sv.staminaScale = v
        RefreshVisuals()
      end,
      default = Rebar.default.staminaScale,
    },
    {
      type = "slider",
      name = "Stamina Opacity",
      min = 0.20, max = 1.00, step = 0.01,
      getFunc = function() return Rebar.sv.staminaAlpha end,
      setFunc = function(v)
        Rebar.sv.staminaAlpha = v
        RefreshVisuals()
      end,
      default = Rebar.default.staminaAlpha,
    },
    {
      type = "colorpicker",
      name = "Stamina Color",
      getFunc = function() return Rebar.sv.staminaColorR, Rebar.sv.staminaColorG, Rebar.sv.staminaColorB end,
      setFunc = function(r, g, b)
        Rebar.sv.staminaColorR = r
        Rebar.sv.staminaColorG = g
        Rebar.sv.staminaColorB = b
        RefreshVisuals()
      end,
      default = { Rebar.default.staminaColorR, Rebar.default.staminaColorG, Rebar.default.staminaColorB },
    },
  }

  LAM2:RegisterAddonPanel(Rebar.name .. "Menu", panelData)
  LAM2:RegisterOptionControls(Rebar.name .. "Menu", optionsData)
end

function Rebar:Initialize()
  Rebar.RemoveArmourBuff()
  Rebar.SizeLock()
  Rebar.HookAttributeBarAnchors()

  EVENT_MANAGER:RegisterForEvent(Rebar.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, Rebar.UnitAttributeVisual)
  EVENT_MANAGER:RegisterForEvent(Rebar.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, Rebar.UnitAttributeVisual)
  EVENT_MANAGER:RegisterForEvent(Rebar.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, Rebar.UnitAttributeVisual)
  EVENT_MANAGER:RegisterForEvent(Rebar.name, EVENT_PLAYER_ACTIVATED, Rebar.PlayerActivate)
  EVENT_MANAGER:RegisterForEvent(Rebar.name .. "PowerUpdate", EVENT_POWER_UPDATE, Rebar.OnPowerUpdate)

  Rebar.sv = ZO_SavedVars:NewAccountWide("RebarVars", Rebar.svVersion, nil, Rebar.default)
  Rebar.NormalizeSavedVars()
  Rebar.ApplyLayoutPresetIfNeeded()

  Rebar.CreateMover()
  Rebar.CreateCustomBars()
  Rebar.UpdateMoverState()
  Rebar.Reposition()
  Rebar.StartUpdateLoop()

  Rebar:CreateSettingsWindow()
end

function Rebar.OnAddOnLoaded(_, name)
  if name ~= Rebar.name then return end

  EVENT_MANAGER:UnregisterForEvent(Rebar.name, EVENT_ADD_ON_LOADED)
  Rebar:Initialize()
end

EVENT_MANAGER:RegisterForEvent(Rebar.name, EVENT_ADD_ON_LOADED, Rebar.OnAddOnLoaded)
