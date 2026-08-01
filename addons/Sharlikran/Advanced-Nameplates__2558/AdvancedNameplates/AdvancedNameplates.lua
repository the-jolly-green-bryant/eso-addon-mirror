--[[
-------------------------------------------------------------------------------
-- Advanced Nameplates
-------------------------------------------------------------------------------
-- Original Addon by: Tierney11290 (Stratejacket), released in 2017
-- License: MIT License
--
-- Current Maintainer: Sharlikran
-- First upload: 2020-03-07
--
-- This project was revived and continued by the current maintainer with
-- permission inferred from the original author's ESOUI project page,
-- in accordance with community guidelines.
--
-------------------------------------------------------------------------------
-- License Terms:
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-------------------------------------------------------------------------------
]]

local LMP = LibMediaProvider
local LAM = LibAddonMenu2

ANP = {}
ANP.appName = "AdvancedNameplates"
ANP.fontStyleChoices = {}
ANP.fontStyleValues = {}
ANP.fontListChoices = {}

ANP.show_log = false
if LibDebugLogger then
  ANP.logger = LibDebugLogger.Create(ANP.appName)
end
local logger
local viewer
if DebugLogViewer then viewer = true else viewer = false end
if LibDebugLogger then logger = true else logger = false end

local function create_log(log_type, log_content)
  if not viewer and log_type == "Info" then
    CHAT_ROUTER:AddSystemMessage(log_content)
    return
  end
  if not ANP.show_log then return end
  if logger and log_type == "Debug" then
    ANP.logger:Debug(log_content)
  end
  if logger and log_type == "Info" then
    ANP.logger:Info(log_content)
  end
  if logger and log_type == "Verbose" then
    ANP.logger:Verbose(log_content)
  end
  if logger and log_type == "Warn" then
    ANP.logger:Warn(log_content)
  end
end

local function emit_message(log_type, text)
  if (text == "") then
    text = "[Empty String]"
  end
  create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
  indent = indent or "."
  table_history = table_history or {}

  if not t then
    emit_message(log_type, indent .. "[Nil Table]")
    return
  end

  if next(t) == nil then
    emit_message(log_type, indent .. "[Empty Table]")
    return
  end

  for k, v in pairs(t) do
    local vType = type(v)

    emit_message(log_type, indent .. "(" .. vType .. "): " .. tostring(k) .. " = " .. tostring(v))

    if (vType == "table") then
      if (table_history[v]) then
        emit_message(log_type, indent .. "Avoiding cycle on table...")
      else
        table_history[v] = true
        emit_table(log_type, v, indent .. "  ", table_history)
      end
    end
  end
end

function ANP:dm(log_type, ...)
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    if (type(value) == "table") then
      emit_table(log_type, value)
    else
      emit_message(log_type, tostring(value))
    end
  end
end

local ANP_FONT_STYLE_NORMAL = 1
local ANP_FONT_STYLE_OUTLINE = 2
local ANP_FONT_STYLE_OUTLINE_THICK = 3
local ANP_FONT_STYLE_SHADOW = 4
local ANP_FONT_STYLE_SOFT_SHADOW_THICK = 5
local ANP_FONT_STYLE_SOFT_SHADOW_THIN = 6
local StyleList = {
  [ANP_FONT_STYLE_NORMAL] = "Normal",
  [ANP_FONT_STYLE_OUTLINE] = "Outline",
  [ANP_FONT_STYLE_OUTLINE_THICK] = "Thin-Outline",
  [ANP_FONT_STYLE_SHADOW] = "Shadow",
  [ANP_FONT_STYLE_SOFT_SHADOW_THICK] = "Soft-Shadow-Thick",
  [ANP_FONT_STYLE_SOFT_SHADOW_THIN] = "Soft-Shadow-Thin",
}
local defaults = {
  FontKB = "Univers 57",
  FontGP = "Univers 57",
  FontStyle = ANP_FONT_STYLE_NORMAL, -- don't subtract 1, that is done when set
  FontSize = 20,
}

local function CreatePanel()
  local ANPpanel = {
    type = "panel",
    name = "Advanced Nameplates",
    displayName = ZO_HIGHLIGHT_TEXT:Colorize("Advanced Nameplates"),
    author = "|cff9b15Sharlikran|r, Tierney11290 (Stratejacket), |c66ccffErian Kalil|r",
    website = "https://www.esoui.com/downloads/info2558-AdvancedNameplatesNecrom.html",
    version = "2.34",
    slashCommand = "/anp",
    registerForRefresh = true,
    registerForDefaults = true,
  }
  LAM:RegisterAddonPanel(ANP.appName, ANPpanel)
end

local function CreateOptions()
  local ANPoptions = {}
  ANPoptions[#ANPoptions + 1] = {
    type = "header",
    name = GetString(ANP_Options_Header),
  }
  ANPoptions[#ANPoptions + 1] = {
    type = "slider",
    name = GetString(ANP_Font_Size_Desc),
    tooltip = GetString(ANP_Font_Size_Tip),
    min = 16,
    max = 48,
    step = 1,
    getFunc = function() return ANP.SV.FontSize end,
    setFunc = function(val)
      ANP.SV.FontSize = val
      ANP.SetFont()
    end,
    default = defaults.FontSize,
  }
  ANPoptions[#ANPoptions + 1] = {
    type = "dropdown",
    name = GetString(ANP_Font_Style_Desc),
    tooltip = GetString(ANP_Font_Style_Tip),
    choices = ANP.fontStyleChoices,
    choicesValues = ANP.fontStyleValues,
    getFunc = function() return ANP.SV.FontStyle end,
    setFunc = function(val)
      ANP.SV.FontStyle = val
      ANP.SetFont()
    end,
    default = defaults.FontStyle,
  }
  ANPoptions[#ANPoptions + 1] = {
    type = "dropdown",
    name = GetString(ANP_Font_Keyboard_Desc),
    tooltip = GetString(ANP_Font_Keyboard_Tip),
    choices = ANP.fontListChoices,
    getFunc = function() return ANP.SV.FontKB end,
    setFunc = function(val)
      ANP.SV.FontKB = val
      ANP:SetKeyboardFont(ANP.SV.FontKB)
    end,
    default = defaults.FontKB,
  }
  ANPoptions[#ANPoptions + 1] = {
    type = "dropdown",
    name = GetString(ANP_Font_Gamepad_Desc),
    tooltip = GetString(ANP_Font_Gamepad_Tip),
    choices = ANP.fontListChoices,
    getFunc = function() return ANP.SV.FontGP end,
    setFunc = function(val)
      ANP.SV.FontGP = val
      ANP:SetGamepadFont(ANP.SV.FontGP)
    end,
    default = defaults.FontGP,
  }
  LAM:RegisterOptionControls(ANP.appName, ANPoptions)
end

local function CreateFontStyleChoices()
  for styleConstant, styleString in pairs(StyleList) do
    ANP.fontStyleChoices[styleConstant] = styleString
    ANP.fontStyleValues[styleConstant] = styleConstant
  end
end

function ANP:SetKeyboardFont(fontName)
  local fontFilename = LMP:Fetch("font", fontName)
  local fontString = string.format("%s|%d", fontFilename, ANP.SV.FontSize)
  SetNameplateKeyboardFont(fontString, ANP.SV.FontStyle - 1)
end

function ANP:SetGamepadFont(fontName)
  local fontFilename = LMP:Fetch("font", fontName)
  local fontString = string.format("%s|%d", fontFilename, ANP.SV.FontSize)
  SetNameplateGamepadFont(fontString, ANP.SV.FontStyle - 1)
end

function ANP:SetFont()
  if not IsInGamepadPreferredMode() then
    ANP:SetKeyboardFont(ANP.SV.FontKB)
  elseif IsInGamepadPreferredMode() then
    ANP:SetGamepadFont(ANP.SV.FontGP)
  end
end

local function RegisterFonts()
  LMP:Register("font", "Adventure", "$(AN_ADVENTURE_FONT)")
  LMP:Register("font", "Arial Narrow", "$(AN_ARIAL_NARROW_FONT)")
  LMP:Register("font", "Black Chancery", "$(AN_BLACK_CHANCERY_FONT)")
  LMP:Register("font", "Century Gothic", "$(AN_CENTURY_GOTHIC_FONT)")
  LMP:Register("font", "Crimson Regular", "$(AN_CRIMSON_REGULAR_FONT)")
  LMP:Register("font", "ESO Cartographer", "$(AN_ESO_CARTOGRAPHER_FONT)")
  LMP:Register("font", "Fitzgerald", "$(AN_FITZGERALD_FONT)")
  LMP:Register("font", "Futura Std Con", "$(AN_FUTURA_STD_CON_FONT)")
  LMP:Register("font", "Futura Std Con Bold", "$(AN_FUTURA_STD_CON_BOLD_FONT)")
  LMP:Register("font", "Futura Std Con Lt", "$(AN_FUTURA_STD_CON_LT_FONT)")
  LMP:Register("font", "Gentium", "$(AN_GENTIUM_FONT)")
  LMP:Register("font", "All Hooked Up", "$(AN_ALL_HOOKED_UP_FONT)")
  LMP:Register("font", "Magic Cards Normal", "$(AN_MAGIC_CARDS_NORMAL_FONT)")
  LMP:Register("font", "Patrick Hand SC", "$(AN_PATRICK_HAND_SC_FONT)")
  LMP:Register("font", "Permanent Marker", "$(AN_PERMANENT_MARKER_FONT)")
  LMP:Register("font", "Skurri", "$(AN_SKURRI_FONT)")
end

local function SetFontListChoices()
  ANP:dm("Debug", "SetFontListChoices")
  ANP.fontListChoices = LMP:List(LMP.MediaType.FONT)
end

function ANP:SetupLAM()
  ANP:dm("Debug", "SetupLAM")
  SetFontListChoices()
  CreatePanel()
  CreateOptions()
end

local function OnAddOnLoaded(eventCode, addOnName)
  if (ANP.appName ~= addOnName) then return end
  ANP:dm("Debug", "OnAddOnLoaded")

  ANP.SV = ZO_SavedVars:NewAccountWide("AdvancedNameplates_SavedVariables", 1, nil, defaults)
  local sv = AdvancedNameplates_SavedVariables["Default"][GetDisplayName()]["$AccountWide"]
  -- Clean up saved variables (from previous versions)
  for key, _ in pairs(sv) do
    -- Delete key-value pair if the key can't also be found in the default settings (except for version)
    if key ~= "version" and defaults[key] == nil then
      sv[key] = nil
    end
  end

  RegisterFonts()
  CreateFontStyleChoices()
  ANP:SetFont()

  if type(ANP.SV.FontStyle) ~= 'number' then ANP.SV.FontStyle = ANP_FONT_STYLE_NORMAL end
  EVENT_MANAGER:UnregisterForEvent(ANP.appName .. "Load", EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent(ANP.appName .. "Load", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

local function OnPlayerActivated(eventCode, initial)
  ANP:dm("Debug", "OnPlayerActivated")
  ANP:SetupLAM()
  EVENT_MANAGER:UnregisterForEvent(ANP.appName .. "Activated", EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(ANP.appName .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

local function OnPlayerActivatedSetFont(eventCode, initial)
  ANP:dm("Debug", "OnPlayerActivatedSetFont")
  ANP:SetFont()
end
EVENT_MANAGER:RegisterForEvent(ANP.appName .. "SetFont", EVENT_PLAYER_ACTIVATED, OnPlayerActivatedSetFont)
