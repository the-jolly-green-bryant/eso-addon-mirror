Armorskull = {
  name = 'armorskull',
}

local panelData = {
  type = "panel",
  name = "Armorskull",
  author = 'taugrim',
  version = '1.11'
}

local db = {}
local defaults = {
  location = {
    x = 0,
    y = 0
  },
  settings = {
    customScale = 20,
    backgroundColor={0,0,0,0.8},
    -- Shared thresholds used for BOTH Physical and Spell Resistance
    levels = {
      { color={1,1,1,1}, level = 0 },
      { color={1,1,1,1}, level = 0 },
      { color={1,1,1,1}, level = 0 },
      { color={1,1,1,1}, level = 0 },
      { color={1,1,1,1}, level = 0 }
    },
    renderTick = 500
  },
}

local optionsData = {}
local LAM2 = LibAddonMenu2

local currentPhysicalResistLevel = 0
local currentSpellResistLevel = 0

-- --------------------
-- Methods
-- --------------------
function Armorskull.Initialize()
  local self = Armorskull

  self.UI = {
    BG = ArmorskullUIBG,
    Border = ArmorskullUIBorder,
    
    PhysicalResist = ArmorskullUIPhysicalResist,
    PhysicalResistLabel = ArmorskullUIPhysicalResistLabel,
    
    SpellResist = ArmorskullUISpellResist,
    SpellResistLabel = ArmorskullUISpellResistLabel,
  }

  EVENT_MANAGER:RegisterForUpdate(self.name..'Render',db.settings.renderTick,self.Render)
  EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

  self.UI.BG:SetEdgeColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())
  self.UI.BG:SetCenterColor(unpack(db.settings.backgroundColor))
  self.UI.Border:SetCenterColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())

  self.CustomScale(db.settings.customScale)

  self.Render(true)

  ArmorskullUI:ClearAnchors()
  ArmorskullUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, db.location.x,
    db.location.y)

  local fragment = ZO_HUDFadeSceneFragment:New(ArmorskullUI, nil, 0)
  HUD_SCENE:AddFragment(fragment)
  HUD_UI_SCENE:AddFragment(fragment)
end

function Armorskull.SaveLocation()
  db.location.x = ArmorskullUI:GetLeft()
  db.location.y = ArmorskullUI:GetTop()
end

function Armorskull.Render(initial)
  local self = Armorskull

  local physicalResistColor = {1,1,1,1}
  local physicalResistLevel = GetPlayerStat(STAT_DAMAGE_RESIST_PHYSICAL)
  local sharedLevels = db.settings.levels

  for i in pairs(sharedLevels) do
    local alertLevel = tonumber(sharedLevels[i].level)

    if alertLevel ~= 0 and physicalResistLevel >= alertLevel then
      physicalResistColor = sharedLevels[i].color
    end
  end

  if currentPhysicalResistLevel ~= physicalResistLevel or initial then
    currentPhysicalResistLevel = physicalResistLevel
    self.UI.PhysicalResist:SetText(physicalResistLevel)

    local r,g,b,a = unpack(physicalResistColor)
    self.UI.PhysicalResist:SetColor(r,g,b,a)
  end
  
  local spellResistColor = {1,1,1,1}
  local spellResistLevel = GetPlayerStat(STAT_DAMAGE_RESIST_MAGIC)

  for i in pairs(sharedLevels) do
    local alertLevel = tonumber(sharedLevels[i].level)

    if alertLevel ~= 0 and spellResistLevel >= alertLevel then
      spellResistColor = sharedLevels[i].color
    end
  end
  
  if currentSpellResistLevel ~= spellResistLevel or initial then
    currentSpellResistLevel = spellResistLevel
    self.UI.SpellResist:SetText(spellResistLevel)

    local r,g,b,a = unpack(spellResistColor)
    self.UI.SpellResist:SetColor(r,g,b,a)
  end

  local borderColor = {1,1,1,0.5}
  local r,g,b,a = unpack(borderColor)
  self.UI.Border:SetEdgeColor(ZO_ColorDef:New(r,g,b,a):UnpackRGBA())
end

function Armorskull.CustomScale(value)
  local self = Armorskull

  self.UI.PhysicalResist:SetFont('$(GAMEPAD_BOLD_FONT)|'..tostring( 28 + (28/100*value) )..'|thin-outline')
  self.UI.PhysicalResistLabel:SetFont('$(BOLD_FONT)|'..tostring( 12 + (12/100*value) )..'|thin-outline')
  self.UI.SpellResist:SetFont('$(GAMEPAD_BOLD_FONT)|'..tostring( 28 + (28/100*value) )..'|thin-outline')
  self.UI.SpellResistLabel:SetFont('$(BOLD_FONT)|'..tostring( 12 + (12/100*value) )..'|thin-outline')

  ArmorskullUI:SetDimensions( 155 + (155/100*value), 40 + (40/100*value) )
  self.UI.BG:SetDimensions( 155 + (155/100*value), 40 + (40/100*value) )
  self.UI.Border:SetDimensions( 158 + (158/100*value), 43 + (43/100*value) )
end

-- --------------------
-- Create Settings
-- --------------------

optionsData[#optionsData+1] = {
  type = "description",
  title = "",
  text = [[Armorskull is a customizable meter that displays your current Physical Resistance and Spell Resistance.
  ]]
}

optionsData[#optionsData+1] = {
  type = "colorpicker",
  name = "BG Color",
  tooltip = "Container BG Color",
  getFunc = function() return unpack(db.settings.backgroundColor) end,
  setFunc = function(r,g,b,a) 
    db.settings.backgroundColor = {r,g,b,a}
    Armorskull.UI.BG:SetCenterColor(r,g,b,a)
  end,
  default = unpack(defaults.settings.backgroundColor)
}

optionsData[#optionsData+1] = {
  type = "slider",
  name = "Custom Scale (Default: 20)",
  tooltip = "Enlarge by %",
  min = 0,
  max = 100,
  getFunc = function() 
    return db.settings.customScale
  end,
  setFunc = function(value)
    Armorskull.CustomScale(value)
    db.settings.customScale = value
  end,
  default = defaults.settings.customScale
}

optionsData[#optionsData+1] = {
  type = "header",
  name = "Color Notifications",
}

optionsData[#optionsData+1] = {
  type = "description",
  text = [[Set up to 5 resistance thresholds and assign each a color. These 5 levels apply to BOTH Physical Resistance and Spell Resistance -- whichever stat crosses a threshold will switch to that color.
  ]]
}

local resistOptions = {}

for i in pairs(defaults.settings.levels) do
  resistOptions[#resistOptions+1] = {
    type = "editbox",
    name = "Resist Level #"..i,
    tooltip = "Resist level for Level #"..i,
    getFunc = function() return db.settings.levels[i].level end,
    setFunc = function(level) db.settings.levels[i].level = level end,
    default = defaults.settings.levels[i].level,
    width = 'half'
  }
  resistOptions[#resistOptions+1] = {
    type = "colorpicker",
    tooltip = "Color for Level #"..i,
    getFunc = function() return unpack(db.settings.levels[i].color) end,
    setFunc = function(r,g,b,a) db.settings.levels[i].color = {r,g,b,a} end,
    default = unpack(defaults.settings.levels[i].color),
    width = 'half'
  }
end

optionsData[#optionsData + 1] = {
  type = "submenu",
  name = 'Resist Alerts',
  reference = "Resist_Options_Submenu",
  controls = resistOptions
}

optionsData[#optionsData+1] = {
  type = "header",
  name = "Performance",
}

optionsData[#optionsData+1] = {
  type = "description",
  title = "",
  text = [[The milliseconds for the loop that renders the Resistance values in the meter. Select the interval based on what is best for performance for your system.
  ]]
}

optionsData[#optionsData+1] = {
  type = "slider",
  name = "Render Interval (Default: 500ms)",
  tooltip = "How fast should the meter re-render",
  min = 200,
  max = 3000,
  getFunc = function() 
    return db.settings.renderTick
  end,
  setFunc = function(value)
    EVENT_MANAGER:UnregisterForUpdate(Armorskull.name..'Render')
    EVENT_MANAGER:RegisterForUpdate(Armorskull.name..'Render',value,
      Armorskull.Render)
    db.settings.renderTick = value
  end,
  default = defaults.settings.renderTick
}

local function OnPlayerActivated(eventCode)
  EVENT_MANAGER:UnregisterForEvent(Armorskull.name, eventCode)
  Armorskull.Initialize()
end

function Armorskull.OnAddOnLoaded(event, addOnName)
  if addOnName == Armorskull.name then
    db = ZO_SavedVars:New("ArmorskullSettings", 3, nil, defaults)
    LAM2:RegisterAddonPanel("ArmorskullOptions", panelData)
    LAM2:RegisterOptionControls("ArmorskullOptions", optionsData)

    EVENT_MANAGER:RegisterForEvent(Armorskull.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
  end
end

-- --------------------
-- Attach Listeners
-- --------------------
EVENT_MANAGER:RegisterForEvent(Armorskull.name, EVENT_ADD_ON_LOADED,
  Armorskull.OnAddOnLoaded)