--- The SimpleClock addon namespace.
--- This is the version that is shown ingame! Use "SimpleClock - Copy" for filming.
---@class SimpleClock
---@field OnAddOnLoaded function
---@field name string
SimpleClock = {}
SimpleClock.name = "SimpleClock"
local ADDON_NAME = "SimpleClock"

--- # SimpleClockVars.
---@class savedVariables
---@field fontColor table # The color of the clock font.
---@field clockFormat string # The format of the clock.
---@field font string # The font used for the clock.
---@field fontColor.r number # The red component of the clock font color.
---@field fontColor.g number # The green component of the clock font color.
---@field fontColor.b number # The blue component of the clock font color.
---@field fontColor.a number # The alpha component of the clock font color.
---@field fontSize number # The size of the clock font.
---@field visible boolean # The visibility status of the clock.
---@field version number # The version of the addon.
local savedVariables

-- Console/gamepad movement state
local isGamepadMoveModeActive = false
local moveLastUpdateMs = 0
local moveModePreviousVisibility = nil



---@enum (key) fontTable
---```
--- Create a reversed font table for easy lookup later called revFontTable.
--- This will have the key as "Medium" instead of "MEDIUM_FONT", etc.
---```
local fontTable = {
  ["MEDIUM_FONT"] = "Medium",
  ["BOLD_FONT"] = "Bold",
  ["CHAT_FONT"] = "Chat",
  ["GAMEPAD_LIGHT_FONT"] = "Gamepad Light",
  ["GAMEPAD_MEDIUM_FONT"] = "Gamepad Medium",
  ["GAMEPAD_BOLD_FONT"] = "Gamepad Bold",
  ["ANTIQUE_FONT"] = "Antique",
  ["HANDWRITTEN_FONT"] = "Handwritten",
  ["STONE_TABLET_FONT"] = "Stone Tablet",
}

--- Shows the clock.
local function ShowClock()
  SimpleClockLabel:SetHidden(false)
  savedVariables.visible = true
end

--- Hides the clock.
local function HideClock()
  SimpleClockLabel:SetHidden(true)
  savedVariables.visible = false
end

--- Maps special character codes to their respective UTF-8 sequences.
---@param charCode number # The character code.
---@return string|nil charCode # The UTF-8 sequence, or nil if the character code is not mapped.
local function mapSpecialCharacters(charCode)
  local specialCharacters = {
    [233] = "\195\169",
    [232] = "\195\168",
    [192] = "\195\128",
    [194] = "\195\130",
    [196] = "\195\132",
    [198] = "\195\134",
    [199] = "\195\135",
    [200] = "\195\136",
    [201] = "\195\137",
    [202] = "\195\138",
    [203] = "\195\139",
    [204] = "\195\140",
    [207] = "\195\143",
    [212] = "\195\148",
    [338] = "\197\146",
    [217] = "\195\153",
    [219] = "\195\155",
    [220] = "\195\156",
    [224] = "\195\160",
    [228] = "\195\164",
    [230] = "\195\166",
    [231] = "\195\167",
    [234] = "\195\170",
    [235] = "\195\171",
    [238] = "\195\174",
    [239] = "\195\175",
    [244] = "\195\180",
    [339] = "\197\147",
    [249] = "\195\185",
    [251] = "\195\187",
    [252] = "\195\188",
  }
  return specialCharacters[charCode]
end

--- Iterates through characters in a string, handling special characters.
---@param str string # The input string.
---@return string constructed_str # The constructed string with special characters replaced.
local function iterateCharacters(str)
  local i = 1
  local constructed_str = ""
  while i <= #str do
    local charCode = string.byte(str, i)
    local charSize = 1
    if charCode >= 192 and charCode < 224 then
      charSize = 2
    elseif charCode >= 224 and charCode < 240 then
      charSize = 3
    end
    local utf8Char = mapSpecialCharacters(charCode) or string.sub(str, i, i + charSize - 1)
    constructed_str = constructed_str .. utf8Char
    i = i + 1
  end
  return constructed_str
end

--- Determines if a string is empty or nil.
---@param s string # The string to check.
---@return boolean # True if the string is empty or nil, false otherwise.
local function isempty(s)
  return s == nil or s == ""
end

-- Resize the clock container around the current label. Extra padding gives the
-- vignette room to fade smoothly on all four sides.
local function UpdateClockContainerSize()
  if not SimpleClock or not SimpleClockLabel then return end
  local textWidth = SimpleClockLabel:GetTextWidth() or 0
  local textHeight = SimpleClockLabel:GetTextHeight() or 0
  SimpleClock:SetDimensions(math.max(64, textWidth + 44), math.max(34, textHeight + 20))
end

--- Updates the clock display with the current time.
local function clock()
  local time = ""
  if isempty(savedVariables.clockFormat) then
    time = tostring(os.date("%a %B %d, %H:%M:%S"))
  else
    time = tostring(os.date(savedVariables.clockFormat))
  end

  SimpleClockLabel:SetText(iterateCharacters(time))
  -- Resize the soft vignette around the clock text. The extra room is intentional:
  -- the DDS fades to transparent on all four sides, like the reference screenshot.
  UpdateClockContainerSize()
  zo_callLater(function () clock() end, 1000)
end

--- Retrieves the visibility status of the clock.
---@return boolean visible # The visibility status.
local function getVisibility()
  return savedVariables.visible
end

--- Sets the visibility status of the clock.
---@param v boolean # The visibility status to set.
local function setVisibility(v)
  if (v == true) then
    ShowClock()
  else
    HideClock()
  end
end

--- Retrieves the font size of the clock.
---@return number fontSize # The font size.
local function getFontSize()
  return savedVariables.fontSize
end

--- Sets the font size based on the input value.
---@param v number # The input value.
local function setFontSize(v)
  local value = math.floor((tonumber(v) or 24) + 0.5)
  -- Console: use the numeric font size directly. KB_* aliases only exist for
  -- selected sizes and caused the LAM slider to appear to do nothing.
  SimpleClockLabel:SetFont("$(" .. savedVariables.font .. ")|" .. tostring(value) .. "|soft-shadow-thick")
  savedVariables.fontSize = value
  zo_callLater(UpdateClockContainerSize, 0)
end
--- Retrieves the available font choices.
--- @return table fontChoices # An array of font choices.
local function getFontChoices()
  local fontChoices = {}
  for k, v in pairs(fontTable) do
    fontChoices[#fontChoices+1] = v
  end
  return fontChoices
end

--- Retrieves the currently selected font.
--- @return string sv_font # The currently selected font.
local function getFont()
  local sv_font = savedVariables.font
  return fontTable[sv_font]
end

--- Sets the font to the specified font.
--- @param font string # The font to set.
local function setFont(font)
  for k, v in pairs(fontTable) do
    if v == font then
      savedVariables.font = k
      SimpleClockLabel:SetFont("$(" .. k .. ")|" .. tostring(getFontSize()) .. "|soft-shadow-thick")
      zo_callLater(UpdateClockContainerSize, 0)
    end
  end
end


--- Retrieves the font color from the saved variables.
--- @return number r, number g, number b, number a # The red, green, blue, and alpha components of the font color.
local function getFontColor()
  return savedVariables.fontColor.r, savedVariables.fontColor.g, savedVariables.fontColor.b, savedVariables.fontColor.a
end

--- Sets the font color using the specified RGBA components.
--- @param r number # The red component (0-1) of the font color.
--- @param g number # The green component (0-1) of the font color.
--- @param b number # The blue component (0-1) of the font color.
--- @param a number # The alpha component (0-1) of the font color.
local function setFontColor(r, g, b, a)
  SimpleClockLabel:SetColor(r, g, b, a)
  savedVariables.fontColor.r = r
  savedVariables.fontColor.g = g
  savedVariables.fontColor.b = b
  savedVariables.fontColor.a = a
end

--- Retrieves the clock format from the saved variables.
--- @return string clockFormat # The clock format.
local function getClockFormat()
  return savedVariables.clockFormat
end

--- Sets the clock format in the saved variables.
--- @param clockFormat string # The clock format to set.
local function setClockFormat(clockFormat)
  savedVariables.clockFormat = clockFormat
end

-- Applies the saved console position to the clock.
local function ApplyClockPosition()
  if not SimpleClock or not savedVariables then return end
  SimpleClock:ClearAnchors()
  SimpleClock:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVariables.positionX or 0, savedVariables.positionY or 10)
end

local function RequestSavedVariablesSave()
  local addonManager = GetAddOnManager and GetAddOnManager()
  if addonManager and addonManager.RequestAddOnSavedVariablesPrioritySave then
    addonManager:RequestAddOnSavedVariablesPrioritySave(ADDON_NAME)
  end
end

local function UpdateGamepadMove()
  if not isGamepadMoveModeActive or not savedVariables then return end
  -- Do not move the clock while navigating any console menu.
  if IsGameCameraUIModeActive and IsGameCameraUIModeActive() then return end

  local stickX = GetGamepadLeftStickX and GetGamepadLeftStickX(true) or 0
  local stickY = GetGamepadLeftStickY and GetGamepadLeftStickY(true) or 0
  if math.abs(stickX) < 0.18 then stickX = 0 end
  if math.abs(stickY) < 0.18 then stickY = 0 end
  if stickX == 0 and stickY == 0 then return end

  local now = GetGameTimeMilliseconds()
  local dt = 0.016
  if moveLastUpdateMs > 0 then
    dt = math.min((now - moveLastUpdateMs) / 1000, 0.05)
  end
  moveLastUpdateMs = now

  local speed = tonumber(savedVariables.gamepadMoveSpeed) or 420
  savedVariables.positionX = (savedVariables.positionX or 0) + (stickX * speed * dt)
  savedVariables.positionY = (savedVariables.positionY or 10) - (stickY * speed * dt)
  ApplyClockPosition()
end

local function StartGamepadMoveMode()
  if isGamepadMoveModeActive then return end
  isGamepadMoveModeActive = true
  moveModePreviousVisibility = savedVariables.visible
  moveLastUpdateMs = 0
  -- The clock stays hidden while a menu is open. After closing the menu it
  -- becomes visible automatically and can then be moved with the left stick.
  if not (IsGameCameraUIModeActive and IsGameCameraUIModeActive()) then
    SimpleClockLabel:SetHidden(false)
    SimpleClock:SetHidden(false)
  end
  EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "GamepadMove", 16, UpdateGamepadMove)
  d("|cFFFFFFSimpleClock Move mode: |c00FF00ON|r - move with left stick")
end

local function StopGamepadMoveMode()
  if not isGamepadMoveModeActive then return end
  EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "GamepadMove")
  isGamepadMoveModeActive = false
  moveLastUpdateMs = 0
  RequestSavedVariablesSave()
  if moveModePreviousVisibility == false then SimpleClockLabel:SetHidden(true) end
  moveModePreviousVisibility = nil
  d("|cFFFFFFSimpleClock Move mode: |cFFAA00OFF|r - position saved")
end

local function ToggleGamepadMoveMode()
  if isGamepadMoveModeActive then StopGamepadMoveMode() else StartGamepadMoveMode() end
end

-- Console HUD visibility: never draw the clock over inventory, settings, notifications, etc.
local function RefreshClockHudVisibility()
  if not savedVariables then return end
  local inMenu = IsGameCameraUIModeActive and IsGameCameraUIModeActive()
  local hudShowing = true
  if SCENE_MANAGER and SCENE_MANAGER.GetScene then
    local hud = SCENE_MANAGER:GetScene("hud")
    local hudui = SCENE_MANAGER:GetScene("hudui")
    hudShowing = (hud and hud:IsShowing()) or (hudui and hudui:IsShowing()) or false
  end
  local shouldShow = savedVariables.visible and not inMenu and hudShowing
  SimpleClock:SetHidden(not shouldShow)
  SimpleClockLabel:SetHidden(not shouldShow)
end

local function OnGameCameraUIModeChanged()
  RefreshClockHudVisibility()
end

--- Initializes the SimpleClock addon by setting up the options panel and registering the option controls.
local function initializeSimpleClockAddon()
  setVisibility(savedVariables.visible)
  setFont(savedVariables.font)
  setFontSize(savedVariables.fontSize)
  setFontColor(savedVariables.fontColor.r, savedVariables.fontColor.g, savedVariables.fontColor.b, savedVariables.fontColor.a)
  setClockFormat(savedVariables.clockFormat)
  local fontChoices = getFontChoices()
  local panelName = "SimpleClockOptions"

  --- The panel data for the SimpleClock addon.
  ---@class panelData
  ---@field type string @The type of the panel.
  ---@field name string @The name of the panel.
  ---@field author string @The author of the addon.
  local panelData = {
    type = "panel",
    name = "SimpleClock",
    author = "@moshulu",
  }

  local optionsData = {
    [1] = {
      type = "checkbox",
      name = GetString(SIMPLECLOCK_VISIBLE),
      tooltip = GetString(SIMPLECLOCK_VISIBLE_TOOLTIP),
      getFunc = function () return getVisibility() end,
      setFunc = function (value) setVisibility(value) end,
    },
    [2] = {
      type = "dropdown",
      name = GetString(SIMPLECLOCK_FONT),
      choices = fontChoices,
      getFunc = function () return getFont() end,
      setFunc = function (value) setFont(value) end,
    },
    [3] = {
      type = "slider",
      name = GetString(SIMPLECLOCK_FONTSIZE),
      getFunc = function () return getFontSize() end,
      setFunc = function (value) setFontSize(value) end,
      min = 8,
      max = 60,
      step = 1,
    },
    [4] = {
      type = "colorpicker",
      name = GetString(SIMPLECLOCK_FONTCOLOR),
      getFunc = function () return getFontColor() end,
      setFunc = function (r, g, b, a) setFontColor(r, g, b, a) end,
    },
    [5] = {
      type = "editbox",
      name = GetString(SIMPLECLOCK_CLOCKFORMAT),
      tooltip = GetString(SIMPLECLOCK_CLOCKFORMAT_TOOLTIP),
      getFunc = function () return getClockFormat() end,
      setFunc = function (clockFormat) setClockFormat(clockFormat) end,
    },
    [6] = {
      type = "slider",
      name = "Gamepad move speed",
      tooltip = "Movement speed while positioning the clock with the left stick.",
      min = 100,
      max = 1000,
      step = 25,
      getFunc = function () return savedVariables.gamepadMoveSpeed or 420 end,
      setFunc = function (value) savedVariables.gamepadMoveSpeed = value end,
      width = "full",
    },
    [7] = {
      type = "button",
      name = "Toggle move mode",
      tooltip = "Enable move mode, use the left stick to position the clock, then press again to save.",
      func = function () ToggleGamepadMoveMode() end,
      width = "full",
    },
  }

  local LAM = LibAddonMenu2
  LAM:RegisterAddonPanel(panelName, panelData)
  LAM:RegisterOptionControls(panelName, optionsData)
end

--- Event handler for the EVENT_ADD_ON_LOADED event.
---@param event string # The event name.
---@param name string # The name of the loaded addon.
function SimpleClock.OnAddOnLoaded(event, name)
  if name ~= "SimpleClock" then return end
  EVENT_MANAGER:UnregisterForEvent("SimpleClock", EVENT_ADD_ON_LOADED)

  --- The default values for the SimpleClock addon.
  ---@class defaults
  ---@field fontSize number # The size of the clock font.
  ---@field font string # The font used for the clock.
  ---@field fontColor table # The color of the clock font.
  ---@field fontColor.r number # The red component of the clock font color.
  ---@field fontColor.g number # The green component of the clock font color.
  ---@field fontColor.b number # The blue component of the clock font color.
  ---@field fontColor.a number # The alpha component of the clock font color.
  ---@field visible boolean # The visibility status of the clock.
  ---@field clockFormat string # The format of the clock.
  local defaults = {
    fontSize = 24,
    font = "MEDIUM_FONT",
    fontColor = {
      r = 255,
      g = 255,
      b = 255,
      a = 255,
    },
    visible = true,
    clockFormat = "%a %B %d, %H:%M:%S",
    positionX = 0,
    positionY = 10,
    gamepadMoveSpeed = 420,
  }
  savedVariables = ZO_SavedVars:NewAccountWide("SimpleClockVars", 3, nil, defaults)
  -- Migrate the old display-name font value used by some SimpleClock versions.
  if savedVariables.font == "Medium" then savedVariables.font = "MEDIUM_FONT" end
  ApplyClockPosition()
  EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "MenuVisibility", EVENT_GAME_CAMERA_UI_MODE_CHANGED, OnGameCameraUIModeChanged)
  local huduiScene = SCENE_MANAGER and SCENE_MANAGER:GetScene("hudui")
  if huduiScene then
    huduiScene:RegisterCallback("StateChange", function() zo_callLater(RefreshClockHudVisibility, 0) end)
  end
  local hudScene = SCENE_MANAGER and SCENE_MANAGER:GetScene("hud")
  if hudScene then
    hudScene:RegisterCallback("StateChange", function() zo_callLater(RefreshClockHudVisibility, 0) end)
  end

  initializeSimpleClockAddon()
  clock()
  EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "HudVisibility", 100, RefreshClockHudVisibility)
  RefreshClockHudVisibility()
end

-- Check if LibSlashCommander is available
local LSC = LibSlashCommander
if LSC then
  -- Register slash commands with LibSlashCommander
  local commandShowClock = LSC:Register("/showclock", ShowClock, "Shows the clock.")
  local commandHideClock = LSC:Register("/hideclock", HideClock, "Hides the clock.")
else
  -- Fallback to registering slash commands with the original method
  SLASH_COMMANDS["/showclock"] = ShowClock
  SLASH_COMMANDS["/hideclock"] = HideClock
end
SLASH_COMMANDS["/simpleclockmove"] = ToggleGamepadMoveMode

--- Register the EVENT_ADD_ON_LOADED event
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, SimpleClock.OnAddOnLoaded)
