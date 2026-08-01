BlastbonesCounter = {}

BlastbonesCounter.name = "BlastbonesCounter"
GCDtimer = 2
numberOfGCDs = 0
blastbonesOnCooldown = false

local function hideCounterOnEnd()
  if blastbonesOnCooldown == false and BlastbonesCounter.savedVariables.visible == false then
    BlastbonesCounterIndicatorLabel:SetHidden(true)
  end
end

local function update()
  if GCDtimer <= 0 then
    BlastbonesCounterIndicatorLabel:SetText("B")
  else
    BlastbonesCounterIndicatorLabel:SetText(GCDtimer)
  end

  GCDtimer = GCDtimer -1

  if numberOfGCDs < 2 then
    zo_callLater(function() update() end, (1000 + BlastbonesCounter.savedVariables.delay))
    numberOfGCDs = numberOfGCDs +1
  else if numberOfGCDs == 2 then
      zo_callLater(function() hideCounterOnEnd() end, (1000 + BlastbonesCounter.savedVariables.delay))
      blastbonesOnCooldown = false
    end
  end
end

local function showBlast()
  BlastbonesCounterIndicatorLabel:SetHidden(false)
  BlastbonesCounter.savedVariables.visible = true
end

local function hideBlast()
  BlastbonesCounterIndicatorLabel:SetHidden(true)
  BlastbonesCounter.savedVariables.visible = false
end

local function getVisibility()
  return BlastbonesCounter.savedVariables.visible
end

local function setVisibility(v)
  if v == true then
    showBlast()
  else
    hideBlast()
  end
end

local function getFontSize()
  return BlastbonesCounter.savedVariables.fontSize
end

local function setFontSize(v)
  
  local value = v
  local case = {
    [27] = function()
      value = 26
    end,
    [29] = function()
      value = 28
    end,
    [31] = function()
      value = 30
    end,
    [33] = function()
      value = 32
    end,
    [35] = function()
      value = 34
    end,
    [37] = function()
      value = 36
    end,
    [38] = function()
      value = 36
    end,
    [39] = function()
      value = 40
    end
  }

  if case[value] then
    case[value]()
  end
  BlastbonesCounterIndicatorLabel:SetFont("$(" .. BlastbonesCounter.savedVariables.font .. ")|$(KB_" .. value .. ")|soft-shadow-thick")
  BlastbonesCounter.savedVariables.fontSize = value
end

local function getFont()
  return BlastbonesCounter.savedVariables.font
end

local function setFont(font)
  BlastbonesCounterIndicatorLabel:SetFont("$("..font..")|$(KB_" .. getFontSize() .. ")|soft-shadow-thick")
  BlastbonesCounter.savedVariables.font = font
end

local function getFontColor()
  return BlastbonesCounter.savedVariables.fontColor.r, BlastbonesCounter.savedVariables.fontColor.g, BlastbonesCounter.savedVariables.fontColor.b, BlastbonesCounter.savedVariables.fontColor.a
end

local function setFontColor(r,g,b,a)
  BlastbonesCounterIndicatorLabel:SetColor(r,g,b,a)
  BlastbonesCounter.savedVariables.fontColor.r = r
  BlastbonesCounter.savedVariables.fontColor.g = g
  BlastbonesCounter.savedVariables.fontColor.b = b
  BlastbonesCounter.savedVariables.fontColor.a = a
end

local function getDelay()
  return BlastbonesCounter.savedVariables.delay
end

local function setDelay(v)
  BlastbonesCounter.savedVariables.delay = v
end

local function getMovement()
  return BlastbonesCounter.savedVariables.movement
end

local function setMovement(v)
  BlastbonesCounter.savedVariables.movement = v
  BlastbonesCounterIndicator:SetMovable(BlastbonesCounter.savedVariables.movement)
end

function BlastbonesCounter.Initialize()

  setVisibility(BlastbonesCounter.savedVariables.visible)
  setFont(BlastbonesCounter.savedVariables.font)
  setFontSize(BlastbonesCounter.savedVariables.fontSize)
  setFontColor(BlastbonesCounter.savedVariables.fontColor.r, BlastbonesCounter.savedVariables.fontColor.g, BlastbonesCounter.savedVariables.fontColor.b, BlastbonesCounter.savedVariables.fontColor.a)
  setDelay(BlastbonesCounter.savedVariables.delay)
  setMovement(BlastbonesCounter.savedVariables.movement)

  BlastbonesCounter.inCombat = IsUnitInCombat("player")

  local LAM = LibAddonMenu2
  local panelName = "BlastbonesCounterOptions"

  local panelDate = {type = "panel", name = "BlastbonesCounter", author = "@ensmeangl"}
  local optionsData = {
      [1] = {
        type = "checkbox",
        name = "Show UI",
        tooltip = "Show or hide the counter.",
        getFunc = function() return getVisibility() end,
        setFunc = function(value) setVisibility(value) end
          
      },
      [2] = {
        type = "checkbox",
        name = "Unlock UI",
        tooltip = "Move or lock the counter.",
        getFunc = function() return getMovement() end,
        setFunc = function(value) setMovement(value) end
      },
      [3] = {
        type = "dropdown",
        name = "Font",
        tooltip = "Set the font of the counter.",
        choices = {
          "MEDIUM_FONT",
          "BOLD_FONT",
          "CHAT_FONT",
          "GAMEPAD_LIGHT_FONT",
          "GAMEPAD_BOLD_FONT",
          "ANTIQUE_FONT",
          "HANDWRITTEN_FONT",
          "STONE_TABLET_FONT"
        },
        getFunc = function() return getFont() end,
        setFunc = function(value) setFont(value) end
      },
      [4] = {
        type = "slider",
        name = "Font size",
        tooltip = "Set the font size of the counter.",
        getFunc = function() return getFontSize() end,
        setFunc = function(value) setFontSize(value) end,
        min = 8,
        max = 40
      },
      [5] = {
        type = "colorpicker",
        name = "Font color",
        tooltip = "Set the color of the counter",
        getFunc = function() return getFontColor() end,
        setFunc = function(r,g,b,a) setFontColor(r,g,b,a) end
      },
      [6] = {
        type = "slider",
        name = "Blastbones GCD delay",
        tooltip = "Set the GCD delay for the counter. Increase or decrease this delay based on your weaving speed. Change this setting only if you know what you are doing. Otherwise leave it to default(100ms)",
        getFunc = function() return getDelay() end,
        setFunc = function(value) setDelay(value) end,
        min = 0,
        max = 300
      }
  }

  local panel = LAM:RegisterAddonPanel(panelName, panelDate)
  LAM:RegisterOptionControls(panelName, optionsData)

  EVENT_MANAGER:RegisterForEvent(BlastbonesCounter.name, EVENT_COMBAT_EVENT, BlastbonesCounter.onBlastbonesCast)
  --EVENT_MANAGER:AddFilterForEvent(BlastbonesCounter.name, EVENT_COMBAT_EVENT,  REGISTER_FILTER_ABILITY_ID, 117750, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

end

function BlastbonesCounter.OnAddOnLoaded(event, addonName)
  if addonName == BlastbonesCounter.name then
    EVENT_MANAGER:UnregisterForEvent(BlastbonesCounter.name, EVENT_ADD_ON_LOADED)
    
    local defaults = {
      fontSize = 32,
      font = "BOLD_FONT",
      fontColor = {
        r = 255,
        g = 255,
        b = 255,
        a = 255,
      },
      visible = true,
      delay = 100,
      movement = false
      
    }
  
    BlastbonesCounter.savedVariables = ZO_SavedVars:NewCharacterIdSettings("BlastbonesCounterSavedVariables", 1, nil, defaults)
    BlastbonesCounter.RestorePosition()
    BlastbonesCounter.Initialize()
    
    BlastbonesCounter.savedVariables.visible = false
  end
end

function BlastbonesCounter.onBlastbonesCast(_, result, _, abilityName, _, abilityActionSlotType, _, _, _, _, _, _, _, _, _, _, abilityId, _)

  if abilityActionSlotType == ACTION_SLOT_TYPE_NORMAL_ABILITY and blastbonesOnCooldown == false and result == ACTION_RESULT_EFFECT_GAINED_DURATION and (abilityName == "Stalking Blastbones" or abilityName == "Blighted Blastbones" or abilityName == "Blastbones") then
    
    BlastbonesCounterIndicatorLabel:SetHidden(false)
    blastbonesOnCooldown = true
    GCDtimer = 2
    numberOfGCDs = 0
    update()
  end
end

function BlastbonesCounter.OnIndicatorMoveStop()
  BlastbonesCounter.savedVariables.left = BlastbonesCounterIndicator:GetLeft()
  BlastbonesCounter.savedVariables.top = BlastbonesCounterIndicator:GetTop()
end

function BlastbonesCounter.RestorePosition()
  local left = BlastbonesCounter.savedVariables.left
  local top = BlastbonesCounter.savedVariables.top
 
  BlastbonesCounterIndicator:ClearAnchors()
  BlastbonesCounterIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

SLASH_COMMANDS["/showblast"] = showBlast
SLASH_COMMANDS["/hideblast"] = hideBlast
EVENT_MANAGER:RegisterForEvent(BlastbonesCounter.name, EVENT_ADD_ON_LOADED, BlastbonesCounter.OnAddOnLoaded)