local LAM2 = LibAddonMenu2

PyramidAttributes = {
  name = "PyramidAttributes",
  version = 4.5,

  default = {
    offsetX = 0,
    offsetY = -89,
    movable = false,
  },

  sv = nil,
  svVersion = 1,
  svName = "PyramidAttributesVars",
}
local shield = 0

function PyramidAttributes:Initialize()
  PyramidAttributes.Reposition()
  PyramidAttributes.RemoveArmourBuff()
  PyramidAttributes.SizeLock()

  EVENT_MANAGER:RegisterForEvent(PyramidAttributes.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,   PyramidAttributes.UnitAttributeVisual)
  EVENT_MANAGER:RegisterForEvent(PyramidAttributes.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, PyramidAttributes.UnitAttributeVisual)
  EVENT_MANAGER:RegisterForEvent(PyramidAttributes.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, PyramidAttributes.UnitAttributeVisual)
  EVENT_MANAGER:RegisterForEvent(PyramidAttributes.name, EVENT_PLAYER_ACTIVATED, PyramidAttributes.PlayerActivate)
  PyramidAttributes.sv = ZO_SavedVars:NewAccountWide("PyramidAttributesVars", PyramidAttributes.version, nil, PyramidAttributes.default)
  ZO_PlayerAttributeHealth:SetMovable(PyramidAttributes.sv.movable)

  if PyramidAttributes.sv.offsetX ~= 0 or PyramidAttributes.sv.offsetY ~= -89 then
    ZO_PlayerAttributeHealth:ClearAnchors()
    ZO_PlayerAttributeHealth:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PyramidAttributes.sv.offsetX, PyramidAttributes.sv.offsetY)
  end

  PyramidAttributes:CreateSettingsWindow()
end

function PyramidAttributes.PlayerActivate()
shield=0
end

function PyramidAttributes.SizeLock()
  for index, visualizer in pairs(PLAYER_ATTRIBUTE_BARS.attributeVisualizer.visualModules) do
    if visualizer.expandedWidth then
      visualizer.expandedWidth = visualizer.normalWidth
      visualizer.shrunkWidth = visualizer.normalWidth
    end
  end
end

function PyramidAttributes.OnAddOnLoaded(_, name)
  if name ~= PyramidAttributes.name then return end
  EVENT_MANAGER:UnregisterForEvent(PyramidAttributes.name, EVENT_ADD_ON_LOADED)
  PyramidAttributes:Initialize()
end

EVENT_MANAGER:RegisterForEvent(PyramidAttributes.name, EVENT_ADD_ON_LOADED, PyramidAttributes.OnAddOnLoaded)

function PyramidAttributes.Reposition()
  ZO_PlayerAttributeHealth:ClearAnchors()
  ZO_PlayerAttributeHealth:SetAnchor(BOTTOM, ActionButton5, BOTTOM, 0, -89)
  ZO_PlayerAttributeMagicka:ClearAnchors()
  ZO_PlayerAttributeMagicka:SetAnchor(RIGHT, ZO_PlayerAttributeHealth, BOTTOM, -0.4, 15)
  ZO_PlayerAttributeStamina:ClearAnchors()
  ZO_PlayerAttributeStamina:SetAnchor(LEFT, ZO_PlayerAttributeHealth, BOTTOM, 0.9, 15)
  --ActionButton8CountText:ClearAnchors()
  --ActionButton8CountText:SetAnchor(TOP, ActionButton8, TOP, 0, -0)
  ZO_ActionBar1KeybindBG:SetHidden(true)
end

function PyramidAttributes.SaveLoc()
  PyramidAttributes.sv.offsetX = ZO_PlayerAttributeHealth:GetLeft()
  PyramidAttributes.sv.offsetY = ZO_PlayerAttributeHealth:GetTop()
end

function PyramidAttributes:CreateSettingsWindow()
  local panelData = {
    type = "panel",
    name = "PyramidAttributes",
    displayName = "PyramidAttributes",
    author = "|cff9beaJonno|r",
    version = PyramidAttributes.version,
  }

  local optionsData = {
    {
      type = "header",
      name = "PyramidAttributes Settings",
    },
    {
      type = "description",
      text = "Options",
    },
    {
      type = "checkbox",
      name = "Movable",
      default = true,
      getFunc = function() return PyramidAttributes.sv.movable end,
      setFunc = function(value)
        PyramidAttributes.sv.movable = value
        ZO_PlayerAttributeHealth:SetMovable(value)
      end,
    },
  }

  LAM2:RegisterAddonPanel(PyramidAttributes.name .. "Menu", panelData)
  LAM2:RegisterOptionControls(PyramidAttributes.name .. "Menu", optionsData)
end

function PyramidAttributes.UnitAttributeVisual(evt, unitTag, unitAttributeVisual, _, attributeType, _, value1, value2, _, _)
  if unitTag == "player" and unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and attributeType == ATTRIBUTE_HEALTH then
    if evt == EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED then
      shield = shield + (value2 - value1)
    elseif evt == EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED then
      shield = shield + value1
    elseif evt == EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED then
      shield = shield - value1
    end
  end

  local originalText = ZO_PlayerAttributeHealthResourceNumbers:GetText()
  local health  = originalText:match("(([%w%.]*)k)")
  local percent = originalText:match("([%w%.]*%%)")
  local added   = originalText:match("%([%w%.]*k*%)")

  if health  == nil then health  = "" end
  if percent == nil then percent = "" end
  if added   == nil then added   = "" end

  local locNumber = string.format("%.1f", shield / 1000):gsub("%.",".")

  if GetSetting(SETTING_TYPE_UI, UI_SETTING_RESOURCE_NUMBERS) == "1" then
    if shield > 999 then
      ZO_PlayerAttributeHealthResourceNumbers:SetText(string.format("%s (%s%s)", health, locNumber, "k"))
    elseif shield > 0 then
      ZO_PlayerAttributeHealthResourceNumbers:SetText(string.format("%s (%s)", health, shield))
    else
      ZO_PlayerAttributeHealthResourceNumbers:SetText(health)
    end
  elseif GetSetting(SETTING_TYPE_UI, UI_SETTING_RESOURCE_NUMBERS) == "3" then
    if shield > 999 then
      ZO_PlayerAttributeHealthResourceNumbers:SetText(string.format("%s %s (%s%s)", health, percent, locNumber, "k"))
    elseif shield > 0 then
      ZO_PlayerAttributeHealthResourceNumbers:SetText(string.format("%s %s (%s)", health, percent, shield))
    else
      ZO_PlayerAttributeHealthResourceNumbers:SetText(string.format("%s %s", health, percent))
    end
  end
end

function PyramidAttributes.RemoveArmourBuff()
  RedirectTexture("esoui/art/unitattributevisualizer/attributebar_dynamic_increasedarmor_frame.dds", "PyramidAttributes/PyramidAttributes.dds")
  RedirectTexture("esoui/art/unitattributevisualizer/attributebar_dynamic_increasedarmor_bg.dds", "PyramidAttributes/PyramidAttributes.dds")
  RedirectTexture("esoui/art/tooltips/munge_overlay.dds", "PyramidAttributes/PyramidAttributes.dds")
end
