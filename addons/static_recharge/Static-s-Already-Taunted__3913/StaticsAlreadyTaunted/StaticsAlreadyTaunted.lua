--[[----------------------------------------------
Static's Already Taunted
Author: Static_Recharge
Version: 2.0.1
Description: Indicates if a target is already
taunted by another source.
----------------------------------------------]]--


--[[----------------------------------------------
Addon Information
----------------------------------------------]]--
local SAT = {
  addonName = "StaticsAlreadyTaunted",
  addonVersion = "2.0.1",
  author = "|cFF0000Static_Recharge|r",
  varsVersion = 2,
}


--[[----------------------------------------------
Aliases
----------------------------------------------]]--
local EM = EVENT_MANAGER
local CM = CALLBACK_MANAGER
local CS = CHAT_SYSTEM
local LAM2 = LibAddonMenu2
local SM = SCENE_MANAGER
local WM = WINDOW_MANAGER


--[[----------------------------------------------
Variable, Table and Constant Declarations
----------------------------------------------]]--
SAT.Const = {
  chatPrefix = "|cFF0000[SAT]: |cFFFFFF",
  chatSuffix = "|r",
  playerTauntAbilityID = 38254,
  tauntCounterAbilityID = 52790,
  companionTauntAbilityID = 157235,
  companionRangedTauntAbilityID = 157242,
  overTauntedAbilityID = 52788,
  targetUnitTag = "reticleover",
  sizeMin = 16,
  sizeMax = 128,
  sizeStep = 4,
  updateDelayMS = 200,
}

SAT.Icons = {
  [1] = "/esoui/art/tutorial/gamepad/gp_lfg_tank.dds",
  [2] = "/esoui/art/tribute/tributecarddefeatbanner_taunt.dds",
  [3] = "/art/fx/texture/shield_outline.dds",
  [4] = "/esoui/art/hud/gamepad/gp_radialicon_cancel_down.dds",
  [5] = "/esoui/art/notifications/gamepad/gp_notificationicon_duel.dds",
  [6] = "/art/fx/texture/whitesquare.dds",
  [7] = "/esoui/art/targetmarkers/target_blue_square_64.dds",
  [8] = "/esoui/art/targetmarkers/target_gold_star_64.dds",
  [9] = "/esoui/art/targetmarkers/target_green_circle_64.dds",
  [10] = "/esoui/art/targetmarkers/target_orange_triangle_64.dds",
  [11] = "/esoui/art/targetmarkers/target_pink_moons_64.dds",
  [12] = "/esoui/art/targetmarkers/target_red_weapons_64.dds",
  [13] = "/esoui/art/targetmarkers/target_purple_oblivion_64.dds",
  [14] = "/esoui/art/targetmarkers/target_white_skull_64.dds",
  [15] = "/esoui/art/icons/mapkey/mapkey_groupboss.dds"
}

SAT.Defaults = {
  showDuration = true,
  firstLoad = true,
  showStackCount = true,
  fontSize = 13,
  Other = {
    color = {a = 1, r = 1, g = 0, b = 0},
    icon = SAT.Icons[1],
    size = 32,
    enabled = true,
  },
  Player = {
    color = {a = 1, r = 0, g = 1, b = 0},
    icon = SAT.Icons[1],
    size = 32,
    enabled = true,
  },
  Companion = {
    color = {a = 1, r = 0, g = 0, b = 1},
    icon = SAT.Icons[1],
    size = 32,
    enabled = false,
  },
  OverTaunted = {
    color = {a = 1, r = 1, g = 0, b = 0},
    icon = SAT.Icons[15],
    size = 48,
    enabled = true,
    blinkEnabled = false,
    blinkThreshold = 3,
  },
}
SAT.unlocked = false


--[[----------------------------------------------
General Functions
----------------------------------------------]]--
function SAT.SendToChat(text)
  if text ~= nil then
    CS:AddMessage(SAT.Const.chatPrefix .. text .. SAT.Const.chatSuffix)
  else
    CS:AddMessage(SAT.Const.chatPrefix .. "nil string" .. SAT.Const.chatSuffix)
  end
end


--[[----------------------------------------------
Icon Control Functions
----------------------------------------------]]--
function SAT_ON_MOVE_STOP()
  SAT.SavedVars.left = SAT.Controls.Panel:GetLeft()
  SAT.SavedVars.top = SAT.Controls.Panel:GetTop()
  d(SAT.SavedVars.left, SAT.SavedVars.top)
end

function SAT_ON_UPDATE()
  if not SAT.initialized then return end
  if SAT.lastUpdate then
    local now = GetFrameTimeSeconds()
    if (now - SAT.lastUpdate) >= SAT.Const.updateDelayMS / 1000 then
      SAT.UpdateTarget()
      SAT.lastUpdate = now
    end
  else
    SAT.lastUpdate = GetFrameTimeSeconds()
  end  
end

function SAT.RestorePanel()
	local left = SAT.SavedVars.left
	local top = SAT.SavedVars.top
	if left ~= nil and top ~= nil then
		SAT.Controls.Panel:ClearAnchors()
		SAT.Controls.Panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	end
end

function SAT.Unlock()
  SAT.unlocked = not SAT.unlocked
  if SAT.unlocked then
    local size = {
      SAT.SavedVars.Other.size,
      SAT.SavedVars.Player.size,
      SAT.SavedVars.Companion.size,
      SAT.SavedVars.OverTaunted.size,
    }
    table.sort(size, function(a, b) return a>b end)
    SAT.Controls.Labels:SetHidden(true)
    SAT.Controls.Backdrop:SetDimensions(size[1], size[1])
    SAT.Controls.Backdrop:SetHidden(false)
    SAT.Controls.Other:SetHidden(false)
    SAT.Controls.Player:SetHidden(false)
    SAT.Controls.Companion:SetHidden(false)
    SAT.Controls.OverTaunted:SetHidden(false)
    SAT.Controls.Panel:SetMovable(true)
    SAT.SendToChat("Window unlocked.")
  else
    SAT.Controls.Labels:SetHidden(false)
    SAT.Controls.Backdrop:SetHidden(true)
    SAT.Controls.Other:SetHidden(true)
    SAT.Controls.Player:SetHidden(true)
    SAT.Controls.Companion:SetHidden(true)
    SAT.Controls.OverTaunted:SetHidden(true)
    SAT.Controls.Panel:SetMovable(false)
    SAT.SendToChat("Window locked.")
  end
end

function SAT.UpdateIcons()
  -- Other icon
  SAT.Controls.Other:SetDimensions(SAT.SavedVars.Other.size, SAT.SavedVars.Other.size)
  SAT.Controls.Other:SetColor(SAT.SavedVars.Other.color.r, SAT.SavedVars.Other.color.g, SAT.SavedVars.Other.color.b, SAT.SavedVars.Other.color.a)
  SAT.Controls.Other:SetTexture(SAT.SavedVars.Other.icon)

  -- Player icon
  SAT.Controls.Player:SetDimensions(SAT.SavedVars.Player.size, SAT.SavedVars.Player.size)
  SAT.Controls.Player:SetColor(SAT.SavedVars.Player.color.r, SAT.SavedVars.Player.color.g, SAT.SavedVars.Player.color.b, SAT.SavedVars.Player.color.a)
  SAT.Controls.Player:SetTexture(SAT.SavedVars.Player.icon)

  -- Companion icon
  SAT.Controls.Companion:SetDimensions(SAT.SavedVars.Companion.size, SAT.SavedVars.Companion.size)
  SAT.Controls.Companion:SetColor(SAT.SavedVars.Companion.color.r, SAT.SavedVars.Companion.color.g, SAT.SavedVars.Companion.color.b, SAT.SavedVars.Companion.color.a)
  SAT.Controls.Companion:SetTexture(SAT.SavedVars.Companion.icon)

  -- Over Taunted icon
  SAT.Controls.OverTaunted:SetDimensions(SAT.SavedVars.OverTaunted.size, SAT.SavedVars.OverTaunted.size)
  SAT.Controls.OverTaunted:SetColor(SAT.SavedVars.OverTaunted.color.r, SAT.SavedVars.OverTaunted.color.g, SAT.SavedVars.OverTaunted.color.b, SAT.SavedVars.OverTaunted.color.a)
  SAT.Controls.OverTaunted:SetTexture(SAT.SavedVars.OverTaunted.icon)
end

function SAT.UpdateMenuIcons()
  -- Other icon
  SAT.Controls.MenuOther:SetDimensions(SAT.SavedVars.Other.size, SAT.SavedVars.Other.size)
  SAT.Controls.MenuOther:SetColor(SAT.SavedVars.Other.color.r, SAT.SavedVars.Other.color.g, SAT.SavedVars.Other.color.b, SAT.SavedVars.Other.color.a)
  SAT.Controls.MenuOther:SetTexture(SAT.SavedVars.Other.icon)

  -- Player icon
  SAT.Controls.MenuPlayer:SetDimensions(SAT.SavedVars.Player.size, SAT.SavedVars.Player.size)
  SAT.Controls.MenuPlayer:SetColor(SAT.SavedVars.Player.color.r, SAT.SavedVars.Player.color.g, SAT.SavedVars.Player.color.b, SAT.SavedVars.Player.color.a)
  SAT.Controls.MenuPlayer:SetTexture(SAT.SavedVars.Player.icon)

  -- Companion icon
  SAT.Controls.MenuCompanion:SetDimensions(SAT.SavedVars.Companion.size, SAT.SavedVars.Companion.size)
  SAT.Controls.MenuCompanion:SetColor(SAT.SavedVars.Companion.color.r, SAT.SavedVars.Companion.color.g, SAT.SavedVars.Companion.color.b, SAT.SavedVars.Companion.color.a)
  SAT.Controls.MenuCompanion:SetTexture(SAT.SavedVars.Companion.icon)

  -- Over Taunted icon
  SAT.Controls.MenuOverTaunted:SetDimensions(SAT.SavedVars.OverTaunted.size, SAT.SavedVars.OverTaunted.size)
  SAT.Controls.MenuOverTaunted:SetColor(SAT.SavedVars.OverTaunted.color.r, SAT.SavedVars.OverTaunted.color.g, SAT.SavedVars.OverTaunted.color.b, SAT.SavedVars.OverTaunted.color.a)
  SAT.Controls.MenuOverTaunted:SetTexture(SAT.SavedVars.OverTaunted.icon)
end

function SAT.HUDSceneChange(oldState, newState)
  if (newState == SCENE_SHOWN) then
    SAT.Controls.Panel:SetHidden(false)
  elseif (newState == SCENE_HIDDEN) then
    SAT.Controls.Panel:SetHidden(true)
  end
end

function SAT.HUDUISceneChange(oldState, newState)
  if (newState == SCENE_SHOWN) then
    SAT.Controls.Panel:SetHidden(false)
  elseif (newState == SCENE_HIDDEN) then
    SAT.Controls.Panel:SetHidden(true)
  end
end

function SAT.UpdateDuration(timeEnding)
  if not SAT.SavedVars.showDuration then SAT.Controls.Duration:SetHidden(true) return end
  local duration = math.max(timeEnding - GetFrameTimeSeconds(), 0)
  SAT.Controls.Duration:SetText(string.format("%i", duration))
  SAT.Controls.Duration:SetHidden(false)
end

function SAT.UpdateStackCount(stackCount)
  if not SAT.SavedVars.showStackCount then SAT.Controls.StackCount:SetHidden(true) return end
  SAT.Controls.StackCount:SetText(stackCount)
  SAT.Controls.StackCount:SetHidden(false)
  if stackCount >= SAT.SavedVars.OverTaunted.blinkThreshold and SAT.SavedVars.OverTaunted.blinkEnabled and not SAT.blinking then
    SAT.BlinkAnimation(true)
    SAT.blinking = true
  elseif SAT.blinking and stackCount < SAT.SavedVars.OverTaunted.blinkThreshold then
    SAT.BlinkAnimation(false)
    SAT.blinking = false
  end
end

function SAT.UpdateFontSize()
  local font = string.format("$(BOLD_FONT)|$(KB_%i)|soft-shadow-thin", SAT.SavedVars.fontSize)
  SAT.Controls.Duration:SetFont(font)
  SAT.Controls.StackCount:SetFont(font)
end

function SAT.BlinkAnimation(start)
  if start then
    SAT.timeline1:PlayFromStart()
    SAT.timeline2:PlayFromStart()
  else
    SAT.timeline1:Stop()
    SAT.timeline2:Stop()
  end
end


--[[----------------------------------------------
Settings Menu
----------------------------------------------]]--
function SAT.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Static's Already Taunted",
		displayName = "|cFF0000Static's Already Taunted|r",
		author = SAT.author,
		website = "https://www.esoui.com/downloads/info3913-StaticsAlreadyTaunted.html",
		feedback = "https://www.esoui.com/portal.php?&uid=6533",
		slashCommand = "/satmenu",
		registerForRefresh = true,
		registerForDefaults = true,
		version = SAT.addonVersion,
	}
	
	local optionsData = {}

	local i = 1
  optionsData[i] = {
    type = "header",
    name = "General", -- or string id or function returning a string
    width = "full", -- or "half" (optional)
  }

  i = i+1
  optionsData[i] = {
    type = "checkbox",
    name = "Lock Window", -- or string id or function returning a string
    getFunc = function() return not SAT.unlocked end,
    setFunc = function(value) SAT.Unlock() end,
    tooltip = "Unlocks and shows the icon for moving around the screen. It must be locked again for proper operation.", -- or string id or function returning a string (optional)
    width = "full", -- or "half" (optional)
  }

  i = i+1
  optionsData[i] = {
    type = "checkbox",
    name = "Show Duration", -- or string id or function returning a string
    getFunc = function() return SAT.SavedVars.showDuration end,
    setFunc = function(value) SAT.SavedVars.showDuration = value end,
    tooltip = "Shows the remaining duration of the taunt debuff on the target.", -- or string id or function returning a string (optional)
    width = "full", -- or "half" (optional)
    default = SAT.Defaults.showDuration,
  }

  i = i+1
  optionsData[i] = {
    type = "checkbox",
    name = "Show Stack Count", -- or string id or function returning a string
    getFunc = function() return SAT.SavedVars.showStackCount end,
    setFunc = function(value) SAT.SavedVars.showStackCount = value end,
    tooltip = "Shows the stack count on the taunt debuff. 5 stacks = over taunted state.", -- or string id or function returning a string (optional)
    width = "full", -- or "half" (optional)
    default = SAT.Defaults.showStackCount,
  }

  i = i+1
  optionsData[i] = {
    type = "slider",
    name = "Font Size", -- or string id or function returning a string
    getFunc = function() return SAT.SavedVars.fontSize end,
    setFunc = function(size) SAT.SavedVars.fontSize = size SAT.UpdateFontSize() end,
    min = 10,
    max = 30,
    step = 1, -- (optional)
    clampInput = false, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
    autoSelect = true, -- boolean, automatically select everything in the text input field when it gains focus (optional)
    width = "full", -- or "half" (optional)
    default = SAT.Defaults.fontSize, -- default value or function that returns the default value (optional)
  }

  i = i+1
  optionsData[i] = {
    type = "checkbox",
    name = "Over Taunt Warning", -- or string id or function returning a string
    getFunc = function() return SAT.SavedVars.OverTaunted.blinkEnabled end,
    setFunc = function(value) SAT.SavedVars.OverTaunted.blinkEnabled = value end,
    width = "full", -- or "half" (optional)
    tooltip = "Blinks to indicate the target is close to becoming over taunted.", -- or string id or function returning a string (optional)
    default = SAT.Defaults.OverTaunted.blinkEnabled,
  }

  i = i+1
  optionsData[i] = {
    type = "slider",
    name = "Over Taunt Warning Threshold", -- or string id or function returning a string
    getFunc = function() return SAT.SavedVars.OverTaunted.blinkThreshold end,
    setFunc = function(size) SAT.SavedVars.OverTaunted.blinkThreshold = size end,
    min = 2,
    max = 4,
    step = 1, -- (optional)
    clampInput = false, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
    autoSelect = true, -- boolean, automatically select everything in the text input field when it gains focus (optional)
    width = "full", -- or "half" (optional)
    disabled = function() return not SAT.SavedVars.OverTaunted.blinkEnabled end,
    default = SAT.Defaults.OverTaunted.blinkThreshold, -- default value or function that returns the default value (optional)
  }

  i = i+1
  optionsData[i] = {
    type = "checkbox",
    name = "Other Player Taunted Enabled", -- or string id or function returning a string
    getFunc = function() return SAT.SavedVars.Other.enabled end,
    setFunc = function(value) SAT.SavedVars.Other.enabled = value end,
    width = "full", -- or "half" (optional)
    default = SAT.Defaults.Other.enabled,
  }

  i = i+1
  optionsData[i] = {
    type = "checkbox",
    name = "Player Taunted Enabled", -- or string id or function returning a string
    getFunc = function() return SAT.SavedVars.Player.enabled end,
    setFunc = function(value) SAT.SavedVars.Player.enabled = value end,
    width = "full", -- or "half" (optional)
    default = SAT.Defaults.Player.enabled,
  }

  i = i+1
  optionsData[i] = {
    type = "checkbox",
    name = "Companion Taunted Enabled", -- or string id or function returning a string
    getFunc = function() return SAT.SavedVars.Companion.enabled end,
    setFunc = function(value) SAT.SavedVars.Companion.enabled = value end,
    width = "full", -- or "half" (optional)
    default = SAT.Defaults.Companion.enabled,
  }

  i = i+1
  optionsData[i] = {
    type = "checkbox",
    name = "Over Taunted Enabled", -- or string id or function returning a string
    getFunc = function() return SAT.SavedVars.OverTaunted.enabled end,
    setFunc = function(value) SAT.SavedVars.OverTaunted.enabled = value end,
    width = "full", -- or "half" (optional)
    default = SAT.Defaults.OverTaunted.enabled,
  }

  i = i+1
  optionsData[i] = {
    type = "submenu",
    name = "Other Player Taunted", -- or string id or function returning a string
    disabled = function() return not SAT.SavedVars.Other.enabled end,
    controls = {
      {
        type = "colorpicker",
        name = "Color & Opacity", -- or string id or function returning a string
        getFunc = function() return SAT.SavedVars.Other.color.r, SAT.SavedVars.Other.color.g, SAT.SavedVars.Other.color.b, SAT.SavedVars.Other.color.a end, -- (alpha is optional)
        setFunc = function(r,g,b,a) SAT.SavedVars.Other.color = {a = a, r = r, g = g, b = b} SAT.UpdateIcons() SAT.UpdateMenuIcons() end, -- (alpha is optional)
        width = "full", -- or "half" (optional)
        default = SAT.Defaults.Other.color, -- (optional) table of default color values (or default = defaultColor, where defaultColor is a table with keys of r, g, b[, a]) or a function that returns the color
      },
      {
        type = "iconpicker",
        name = "Icon", -- or string id or function returning a string
        choices = SAT.Icons,
        getFunc = function() return SAT.SavedVars.Other.icon end,
        setFunc = function(icon) SAT.SavedVars.Other.icon = icon SAT.UpdateIcons() SAT.UpdateMenuIcons() end,
        maxColumns = 5, -- number of icons in one row (optional)
        visibleRows = 3, -- number of visible rows (optional)
        iconSize = 32, -- size of the icons (optional)
        width = "full", --or "half" (optional)
        default = SAT.Defaults.Other.icon, -- default value or function that returns the default value (optional)
      },
      {
        type = "slider",
        name = "Size", -- or string id or function returning a string
        getFunc = function() return SAT.SavedVars.Other.size end,
        setFunc = function(size) SAT.SavedVars.Other.size = size SAT.UpdateIcons() SAT.UpdateMenuIcons() end,
        min = SAT.Const.sizeMin,
        max = SAT.Const.sizeMax,
        step = SAT.Const.sizeStep, -- (optional)
        clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
        autoSelect = true, -- boolean, automatically select everything in the text input field when it gains focus (optional)
        width = "full", -- or "half" (optional)
        default = SAT.Defaults.Other.size, -- default value or function that returns the default value (optional)
      },
      {
        type = "header",
        name = "Preview", -- or string id or function returning a string
        width = "full", -- or "half" (optional)
      },
      {
        type = "texture",
        image = SAT.SavedVars.Other.icon,
        imageWidth = SAT.SavedVars.Other.size, -- max of 250 for half width, 510 for full
        imageHeight = SAT.SavedVars.Other.size, -- max of 100
        width = "full", -- or "half" (optional)
        reference = "SATMenuIconOther" -- unique global reference to control (optional)
      },
    },
  }

  i = i+1
  optionsData[i] = {
    type = "submenu",
    name = "Player Taunted", -- or string id or function returning a string
    disabled = function() return not SAT.SavedVars.Player.enabled end,
    controls = {
      {
        type = "colorpicker",
        name = "Color & Opacity", -- or string id or function returning a string
        getFunc = function() return SAT.SavedVars.Player.color.r, SAT.SavedVars.Player.color.g, SAT.SavedVars.Player.color.b, SAT.SavedVars.Player.color.a end, -- (alpha is optional)
        setFunc = function(r,g,b,a) SAT.SavedVars.Player.color = {a = a, r = r, g = g, b = b} SAT.UpdateIcons() SAT.UpdateMenuIcons() end, -- (alpha is optional)
        width = "full", -- or "half" (optional)
        default = SAT.Defaults.Player.color, -- (optional) table of default color values (or default = defaultColor, where defaultColor is a table with keys of r, g, b[, a]) or a function that returns the color
      },
      {
        type = "iconpicker",
        name = "Icon", -- or string id or function returning a string
        choices = SAT.Icons,
        getFunc = function() return SAT.SavedVars.Player.icon end,
        setFunc = function(icon) SAT.SavedVars.Player.icon = icon SAT.UpdateIcons() SAT.UpdateMenuIcons() end,
        maxColumns = 5, -- number of icons in one row (optional)
        visibleRows = 3, -- number of visible rows (optional)
        iconSize = 32, -- size of the icons (optional)
        width = "full", --or "half" (optional)
        default = SAT.Defaults.Player.icon, -- default value or function that returns the default value (optional)
      },
      {
        type = "slider",
        name = "Size", -- or string id or function returning a string
        getFunc = function() return SAT.SavedVars.Player.size end,
        setFunc = function(size) SAT.SavedVars.Player.size = size SAT.UpdateIcons() SAT.UpdateMenuIcons() end,
        min = SAT.Const.sizeMin,
        max = SAT.Const.sizeMax,
        step = SAT.Const.sizeStep, -- (optional)
        clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
        autoSelect = true, -- boolean, automatically select everything in the text input field when it gains focus (optional)
        width = "full", -- or "half" (optional)
        default = SAT.Defaults.Player.size, -- default value or function that returns the default value (optional)
      },
      {
        type = "header",
        name = "Preview", -- or string id or function returning a string
        width = "full", -- or "half" (optional)
      },
      {
        type = "texture",
        image = SAT.SavedVars.Player.icon,
        imageWidth = SAT.SavedVars.Player.size, -- max of 250 for half width, 510 for full
        imageHeight = SAT.SavedVars.Player.size, -- max of 100
        width = "full", -- or "half" (optional)
        reference = "SATMenuIconPlayer" -- unique global reference to control (optional)
      },
    },
  }

  i = i+1
  optionsData[i] = {
    type = "submenu",
    name = "Companion Taunted", -- or string id or function returning a string
    disabled = function() return not SAT.SavedVars.Companion.enabled end,
    controls = {
      {
        type = "colorpicker",
        name = "Color & Opacity", -- or string id or function returning a string
        getFunc = function() return SAT.SavedVars.Companion.color.r, SAT.SavedVars.Companion.color.g, SAT.SavedVars.Companion.color.b, SAT.SavedVars.Companion.color.a end, -- (alpha is optional)
        setFunc = function(r,g,b,a) SAT.SavedVars.Companion.color = {a = a, r = r, g = g, b = b} SAT.UpdateIcons() SAT.UpdateMenuIcons() end, -- (alpha is optional)
        width = "full", -- or "half" (optional)
        default = SAT.Defaults.Companion.color, -- (optional) table of default color values (or default = defaultColor, where defaultColor is a table with keys of r, g, b[, a]) or a function that returns the color
      },
      {
        type = "iconpicker",
        name = "Icon", -- or string id or function returning a string
        choices = SAT.Icons,
        getFunc = function() return SAT.SavedVars.Companion.icon end,
        setFunc = function(icon) SAT.SavedVars.Companion.icon = icon SAT.UpdateIcons() SAT.UpdateMenuIcons() end,
        maxColumns = 5, -- number of icons in one row (optional)
        visibleRows = 3, -- number of visible rows (optional)
        iconSize = 32, -- size of the icons (optional)
        width = "full", --or "half" (optional)
        default = SAT.Defaults.Companion.icon, -- default value or function that returns the default value (optional)
      },
      {
        type = "slider",
        name = "Size", -- or string id or function returning a string
        getFunc = function() return SAT.SavedVars.Companion.size end,
        setFunc = function(size) SAT.SavedVars.Companion.size = size SAT.UpdateIcons() SAT.UpdateMenuIcons() end,
        min = SAT.Const.sizeMin,
        max = SAT.Const.sizeMax,
        step = SAT.Const.sizeStep, -- (optional)
        clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
        autoSelect = true, -- boolean, automatically select everything in the text input field when it gains focus (optional)
        width = "full", -- or "half" (optional)
        default = SAT.Defaults.Companion.size, -- default value or function that returns the default value (optional)
      },
      {
        type = "header",
        name = "Preview", -- or string id or function returning a string
        width = "full", -- or "half" (optional)
      },
      {
        type = "texture",
        image = SAT.SavedVars.Companion.icon,
        imageWidth = SAT.SavedVars.Companion.size, -- max of 250 for half width, 510 for full
        imageHeight = SAT.SavedVars.Companion.size, -- max of 100
        width = "full", -- or "half" (optional)
        reference = "SATMenuIconCompanion" -- unique global reference to control (optional)
      },
    },
  }

  i = i+1
  optionsData[i] = {
    type = "submenu",
    name = "Over Taunted", -- or string id or function returning a string
    disabled = function() return not SAT.SavedVars.OverTaunted.enabled end,
    controls = {
      {
        type = "colorpicker",
        name = "Color & Opacity", -- or string id or function returning a string
        getFunc = function() return SAT.SavedVars.OverTaunted.color.r, SAT.SavedVars.OverTaunted.color.g, SAT.SavedVars.OverTaunted.color.b, SAT.SavedVars.OverTaunted.color.a end, -- (alpha is optional)
        setFunc = function(r,g,b,a) SAT.SavedVars.OverTaunted.color = {a = a, r = r, g = g, b = b} SAT.UpdateIcons() SAT.UpdateMenuIcons() end, -- (alpha is optional)
        width = "full", -- or "half" (optional)
        default = SAT.Defaults.OverTaunted.color, -- (optional) table of default color values (or default = defaultColor, where defaultColor is a table with keys of r, g, b[, a]) or a function that returns the color
      },
      {
        type = "iconpicker",
        name = "Icon", -- or string id or function returning a string
        choices = SAT.Icons,
        getFunc = function() return SAT.SavedVars.OverTaunted.icon end,
        setFunc = function(icon) SAT.SavedVars.OverTaunted.icon = icon SAT.UpdateIcons() SAT.UpdateMenuIcons() end,
        maxColumns = 5, -- number of icons in one row (optional)
        visibleRows = 3, -- number of visible rows (optional)
        iconSize = 32, -- size of the icons (optional)
        width = "full", --or "half" (optional)
        default = SAT.Defaults.OverTaunted.icon, -- default value or function that returns the default value (optional)
      },
      {
        type = "slider",
        name = "Size", -- or string id or function returning a string
        getFunc = function() return SAT.SavedVars.OverTaunted.size end,
        setFunc = function(size) SAT.SavedVars.OverTaunted.size = size SAT.UpdateIcons() SAT.UpdateMenuIcons() end,
        min = SAT.Const.sizeMin,
        max = SAT.Const.sizeMax,
        step = SAT.Const.sizeStep, -- (optional)
        clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
        autoSelect = true, -- boolean, automatically select everything in the text input field when it gains focus (optional)
        width = "full", -- or "half" (optional)
        default = SAT.Defaults.OverTaunted.size, -- default value or function that returns the default value (optional)
      },
      {
        type = "header",
        name = "Preview", -- or string id or function returning a string
        width = "full", -- or "half" (optional)
      },
      {
        type = "texture",
        image = SAT.SavedVars.OverTaunted.icon,
        imageWidth = SAT.SavedVars.OverTaunted.size, -- max of 250 for half width, 510 for full
        imageHeight = SAT.SavedVars.OverTaunted.size, -- max of 100
        width = "full", -- or "half" (optional)
        reference = "SATMenuIconOverTaunted" -- unique global reference to control (optional)
      },
    },
  }

  SAT.LAMSettingsPanel = LAM2:RegisterAddonPanel(SAT.addonName  .. "_LAM", panelData)
  LAM2:RegisterOptionControls(SAT.addonName .. "_LAM", optionsData)
  CM:RegisterCallback("LAM-PanelControlsCreated", function(panel)
    if panel == SAT.LAMSettingsPanel then
      SAT.Controls.MenuOther = WM:GetControlByName("SATMenuIconOther").texture
      SAT.Controls.MenuPlayer = WM:GetControlByName("SATMenuIconPlayer").texture
      SAT.Controls.MenuCompanion = WM:GetControlByName("SATMenuIconCompanion").texture
      SAT.Controls.MenuOverTaunted = WM:GetControlByName("SATMenuIconOverTaunted").texture
      SAT.UpdateMenuIcons()
    end
  end)
end


--[[----------------------------------------------
Target Buff Functions
----------------------------------------------]]--
function SAT.UpdateTarget()
  if SAT.unlocked then return end -- if unlocked ignore reticle changes
  local numBuffs = GetNumBuffs(SAT.Const.targetUnitTag)
  local Taunts = {}
  for i=1, numBuffs do
    local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(SAT.Const.targetUnitTag, i)
    Taunts[abilityId] = {
      buffName = buffName,
      timeEnding = timeEnding,
      stackCount = stackCount,
      abilityId = abilityId,
      castByPlayer = castByPlayer,
    }
    --SAT.SendToChat(string.format("%s: %d", buffName, abilityId))
  end

  if Taunts[SAT.Const.tauntCounterAbilityID] then
    SAT.UpdateStackCount(Taunts[SAT.Const.tauntCounterAbilityID].stackCount)
  else
    SAT.Controls.StackCount:SetHidden(true)
  end

  if Taunts[SAT.Const.playerTauntAbilityID] then
    local data = Taunts[SAT.Const.playerTauntAbilityID]
    if data.castByPlayer and SAT.SavedVars.Player.enabled then
      SAT.Controls.Other:SetHidden(true)
      SAT.Controls.Player:SetHidden(false)
    elseif not data.castByPlayer and SAT.SavedVars.Other.enabled then
      SAT.Controls.Other:SetHidden(false)
      SAT.Controls.Player:SetHidden(true)
    end
    SAT.Controls.Companion:SetHidden(true)
    SAT.Controls.OverTaunted:SetHidden(true)
    SAT.UpdateDuration(data.timeEnding)
  elseif (Taunts[SAT.Const.companionTauntAbilityID] or Taunts[SAT.Const.companionRangedTauntAbilityID]) and SAT.SavedVars.Companion.enabled then
    local data = Taunts[SAT.Const.companionTauntAbilityID] or Taunts[SAT.Const.companionRangedTauntAbilityID]
    SAT.Controls.Other:SetHidden(true)
    SAT.Controls.Player:SetHidden(true)
    SAT.Controls.Companion:SetHidden(false)
    SAT.Controls.OverTaunted:SetHidden(true)
    SAT.Controls.StackCount:SetHidden(true)
    SAT.UpdateDuration(data.timeEnding)
  elseif Taunts[SAT.Const.overTauntedAbilityID] and SAT.SavedVars.OverTaunted.enabled then
    local data = Taunts[SAT.Const.overTauntedAbilityID]
    SAT.Controls.Other:SetHidden(true)
    SAT.Controls.Player:SetHidden(true)
    SAT.Controls.Companion:SetHidden(true)
    SAT.Controls.OverTaunted:SetHidden(false)
    SAT.Controls.StackCount:SetHidden(true)
    SAT.UpdateDuration(data.timeEnding)
  else
    -- hide all icons if no buffs detected
    SAT.Controls.Other:SetHidden(true)
    SAT.Controls.Player:SetHidden(true)
    SAT.Controls.Companion:SetHidden(true)
    SAT.Controls.OverTaunted:SetHidden(true)
    SAT.Controls.Duration:SetHidden(true)
    SAT.Controls.StackCount:SetHidden(true)
  end
end


--[[----------------------------------------------
Initialization
----------------------------------------------]]--
function SAT.OnAddonLoaded(eventCode, addonName)
  if addonName ~= SAT.addonName then return end
  EM:UnregisterForEvent(SAT.addonName, EVENT_ADD_ON_LOADED)

  SAT.SavedVars = ZO_SavedVars:NewAccountWide("StaticsAlreadyTaunted", SAT.varsVersion, nil, SAT.Defaults, nil)

  SAT.Controls = {
    Panel = WM:GetControlByName("SAT_Panel"),
    Backdrop = WM:GetControlByName("SAT_PanelBackdrop"),
    Other = WM:GetControlByName("SAT_PanelIcon_Other"),
    Player = WM:GetControlByName("SAT_PanelIcon_Player"),
    Companion = WM:GetControlByName("SAT_PanelIcon_Companion"),
    OverTaunted = WM:GetControlByName("SAT_PanelIcon_OverTaunted"),
    Labels = WM:GetControlByName("SAT_PanelLabels"),
    Duration = WM:GetControlByName("SAT_PanelLabelsDuration"),
    StackCount = WM:GetControlByName("SAT_PanelLabelsStackCount"),
  }

  SAT.CreateSettingsWindow()
  SAT.RestorePanel()
  SAT.UpdateIcons()
  SAT.UpdateFontSize()

  SAT.animation1, SAT.timeline1 = CreateSimpleAnimation(ANIMATION_ALPHA, SAT.Controls.Panel)
  SAT.animation2, SAT.timeline2 = CreateSimpleAnimation(ANIMATION_ALPHA, SAT.Controls.Labels)
  SAT.animation1:SetAlphaValues(1, 0.25)
  SAT.animation1:SetDuration(500)
  SAT.animation2:SetAlphaValues(1, 0.25)
  SAT.animation2:SetDuration(500)
  SAT.timeline1:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG)
  SAT.timeline2:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG)

  local scene = SM:GetScene("hud")
  scene:RegisterCallback("StateChange", SAT.HUDSceneChange)
  local scene = SM:GetScene("hudui")
  scene:RegisterCallback("StateChange", SAT.HUDUISceneChange)
  
  EM:RegisterForEvent(SAT.addonName, EVENT_PLAYER_ACTIVATED, function()
    if SAT.SavedVars.firstLoad then
      SAT.SendToChat("Updated to version " .. SAT.addonVersion .. ". Add-on settings have been reset to defaults.")
      SAT.SavedVars.firstLoad = false
    end
    EM:UnregisterForEvent(SAT.addonName, EVENT_PLAYER_ACTIVATED)
  end)

  SLASH_COMMANDS["/satunlock"] = SAT.Unlock

  SAT.initialized = true
end


--[[----------------------------------------------
Main Registration
----------------------------------------------]]--
EM:RegisterForEvent(SAT.addonName, EVENT_ADD_ON_LOADED, SAT.OnAddonLoaded)