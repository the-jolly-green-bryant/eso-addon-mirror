Verdant = Verdant or {}
local Verdant = Verdant

Verdant.DonutProbe = {}
local M = Verdant.DonutProbe

local zui = Verdant.zenimax.ui
local WINDOW_MANAGER = zui.WINDOW_MANAGER

local SIZE   = 96
local VALUES = { 50, 30, 20 }
local COLORS = {
  { r = 0.42, g = 0.78, b = 0.50, a = 1 },
  { r = 0.95, g = 0.80, b = 0.35, a = 1 },
  { r = 0.64, g = 0.66, b = 0.58, a = 1 },
}
local VARIANTS = {
  { key = "rad",   label = "origin rad", opts = { mode = "origin", origin_unit = "rad" } },
  { key = "deg",   label = "origin deg", opts = { mode = "origin", origin_unit = "deg" } },
  { key = "stack", label = "stacked",    opts = { mode = "stack" } },
}

local window
local donuts = {}

local function build()
  local Donut = Verdant.lib.plot.Donut
  window = WINDOW_MANAGER:CreateTopLevelWindow("VerdantDonutProbe")
  window:SetDimensions(40 + #VARIANTS * (SIZE + 24), SIZE + 76)
  window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
  window:SetMovable(true)
  window:SetMouseEnabled(true)
  window:SetClampedToScreen(true)
  window:SetDrawTier(DT_HIGH)

  local bg = WINDOW_MANAGER:CreateControl("VerdantDonutProbeBg", window, CT_BACKDROP)
  bg:SetAnchorFill(window)
  bg:SetCenterColor(0.05, 0.07, 0.06, 0.92)
  bg:SetEdgeColor(0.30, 0.42, 0.34, 0.9)
  bg:SetEdgeTexture("", 1, 1, 1)

  local title = WINDOW_MANAGER:CreateControl("VerdantDonutProbeTitle", window, CT_LABEL)
  title:SetFont("ZoFontGameSmall")
  title:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 8)
  title:SetDimensions(300, 14)
  title:SetColor(0.75, 0.90, 0.80, 1)
  title:SetText("donut probe  50 / 30 / 20")

  for i, v in ipairs(VARIANTS) do
    local d = Donut.new("VerdantDonutProbe" .. v.key, window, SIZE, v.opts)
    local x = 20 + (i - 1) * (SIZE + 24)
    d:control():SetAnchor(TOPLEFT, window, TOPLEFT, x, 30)
    d:set(VALUES, COLORS)
    donuts[i] = d
    local lbl = WINDOW_MANAGER:CreateControl("VerdantDonutProbeLbl" .. v.key, window, CT_LABEL)
    lbl:SetFont("ZoFontGameSmall")
    lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    lbl:SetAnchor(TOPLEFT, window, TOPLEFT, x, 30 + SIZE + 6)
    lbl:SetDimensions(SIZE, 14)
    lbl:SetColor(0.80, 0.85, 0.80, 0.9)
    lbl:SetText(v.label)
  end
  window:SetHidden(true)
end

function M.toggle()
  if not window then build() end
  window:SetHidden(not window:IsHidden())
end

function M.set(values)
  if not window then build() end
  for _, d in ipairs(donuts) do d:set(values, COLORS) end
end

function M.is_shown()
  return window ~= nil and not window:IsHidden()
end
