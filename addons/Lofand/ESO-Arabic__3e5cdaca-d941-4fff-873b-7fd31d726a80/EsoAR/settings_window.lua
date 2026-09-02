-- EsoAR settings entry points shared by both input modes:
--   * console / gamepad: LibHarvensAddonSettings panel under Add-Ons (console_settings.lua)
--   * /esoar chat command (+ sub-commands usable without any cursor)
--   * mouse window built here for keyboard mode
-- Gamepad mode opens the native list screen from gamepad_settings.lua.

local CATS = { "heading", "body", "dialogue", "tooltip", "chat", "book" }
local SIZE_STEP, SIZE_MIN, SIZE_MAX = 5, 50, 200
local WIDTH_STEP, WIDTH_MAX = 20, 1200

local function L(key) return (EsoAR.L and EsoAR.L[key]) or key end

local function fontIndex(key)
  for i, f in ipairs(EsoAR.FONTS) do if f.key == key then return i end end
  return 1
end

local function apply()
  EsoAR:ApplyFonts()
  EsoAR:RefreshSettingsWindow()
end

local function cycleFont(cat, dir)
  local sv = EsoAR.savedVars
  local i = fontIndex(sv.fonts[cat]) + dir
  if i < 1 then i = #EsoAR.FONTS elseif i > #EsoAR.FONTS then i = 1 end
  sv.fonts[cat] = EsoAR.FONTS[i].key
  apply()
end

local function stepSize(cat, dir)
  local sv = EsoAR.savedVars
  sv.scale[cat] = math.max(SIZE_MIN, math.min(SIZE_MAX, (sv.scale[cat] or 100) + dir * SIZE_STEP))
  apply()
end

local function stepWidth(dir)
  local sv = EsoAR.savedVars
  sv.dialogueWidth = math.max(0, math.min(WIDTH_MAX, (sv.dialogueWidth or 0) + dir * WIDTH_STEP))
  apply()
end

function EsoAR:ResetSettings()
  local sv = EsoAR.savedVars
  for _, cat in ipairs(CATS) do sv.fonts[cat] = "noto"; sv.scale[cat] = 100 end
  sv.dialogueWidth = 0
  sv.dialogueColor = { r = 0.77, g = 0.76, b = 0.62, a = 1, custom = false }
  apply()
end

function EsoAR:ApplyHeadingFontToAll()
  local sv = EsoAR.savedVars
  for _, cat in ipairs(CATS) do sv.fonts[cat] = sv.fonts.heading end
  apply()
end

-- ------------------------------------------------------------ mouse window
local WM = WINDOW_MANAGER
local rows, widgets = {}, {}

local function makeLabel(name, parent, w, h, font, align)
  local lbl = WM:CreateControl(name, parent, CT_LABEL)
  lbl:SetDimensions(w, h)
  lbl:SetFont(font or "ZoFontGameLarge")
  lbl:SetColor(1, 1, 1, 1)
  lbl:SetHorizontalAlignment(align or TEXT_ALIGN_CENTER)
  lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  return lbl
end

local function makeButton(name, parent, w, h, text, onClick)
  local btn = CreateControlFromVirtual(name, parent, "ZO_DefaultButton")
  if not btn then
    btn = WM:CreateControl(name, parent, CT_BUTTON)
    btn:SetFont("ZoFontGameLarge")
  end
  btn:SetDimensions(w, h)
  btn:SetText(text)
  btn:SetHandler("OnClicked", onClick)
  return btn
end

-- One row: [size -][ 100% ][size +]   [font <][ font name ][font >]   category
local function buildRow(parent, cat, y)
  local prefix = "EsoAR_Row_" .. cat
  local name = makeLabel(prefix .. "Name", parent, 130, 34, "ZoFontGameLarge", TEXT_ALIGN_RIGHT)
  name:SetColor(0.77, 0.76, 0.62, 1)
  name:SetText(L("CAT_" .. cat))
  name:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, y)

  local fNext = makeButton(prefix .. "FontNext", parent, 34, 28, "<", function() cycleFont(cat, 1) end)
  fNext:SetAnchor(RIGHT, name, LEFT, -8, 0)
  local fVal = makeLabel(prefix .. "FontValue", parent, 160, 34)
  fVal:SetAnchor(RIGHT, fNext, LEFT, -2, 0)
  local fPrev = makeButton(prefix .. "FontPrev", parent, 34, 28, ">", function() cycleFont(cat, -1) end)
  fPrev:SetAnchor(RIGHT, fVal, LEFT, -2, 0)

  local sUp = makeButton(prefix .. "SizeUp", parent, 34, 28, "+", function() stepSize(cat, 1) end)
  sUp:SetAnchor(RIGHT, fPrev, LEFT, -24, 0)
  local sVal = makeLabel(prefix .. "SizeValue", parent, 70, 34)
  sVal:SetAnchor(RIGHT, sUp, LEFT, -2, 0)
  local sDown = makeButton(prefix .. "SizeDown", parent, 34, 28, "-", function() stepSize(cat, -1) end)
  sDown:SetAnchor(RIGHT, sVal, LEFT, -2, 0)

  rows[cat] = { font = fVal, size = sVal }
end

local function buildWindow()
  local win = EsoAR_SettingsWindow
  if not win or widgets.built then return end
  widgets.built = true
  win:GetNamedChild("Title"):SetText(L("WIN_TITLE"))
  win:GetNamedChild("Hint"):SetText(L("WIN_HINT"))
  win:GetNamedChild("Cmds"):SetText(L("HELP_CMDS"))

  local parent = win:GetNamedChild("Rows")
  -- column headers
  local hFont = makeLabel("EsoAR_HeadFont", parent, 160, 20, "ZoFontGameBold")
  hFont:SetColor(0.77, 0.76, 0.62, 1)
  hFont:SetText(L("COL_FONT"))
  hFont:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -174, 0)
  local hSize = makeLabel("EsoAR_HeadSize", parent, 70, 20, "ZoFontGameBold")
  hSize:SetColor(0.77, 0.76, 0.62, 1)
  hSize:SetText(L("COL_SIZE"))
  hSize:SetAnchor(RIGHT, hFont, LEFT, -60, 0)

  for i, cat in ipairs(CATS) do buildRow(parent, cat, 24 + (i - 1) * 36) end

  -- dialogue width row
  local y = 24 + #CATS * 36 + 8
  local wName = makeLabel("EsoAR_WidthName", parent, 200, 34, "ZoFontGameLarge", TEXT_ALIGN_RIGHT)
  wName:SetColor(0.77, 0.76, 0.62, 1)
  wName:SetText(L("LBL_WIDTH"))
  wName:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, y)
  local wUp = makeButton("EsoAR_WidthUp", parent, 34, 28, "+", function() stepWidth(1) end)
  wUp:SetAnchor(RIGHT, wName, LEFT, -8, 0)
  local wVal = makeLabel("EsoAR_WidthValue", parent, 90, 34)
  wVal:SetAnchor(RIGHT, wUp, LEFT, -2, 0)
  local wDown = makeButton("EsoAR_WidthDown", parent, 34, 28, "-", function() stepWidth(-1) end)
  wDown:SetAnchor(RIGHT, wVal, LEFT, -2, 0)
  widgets.width = wVal

  -- bottom buttons
  local bar = win:GetNamedChild("Buttons")
  local close = makeButton("EsoAR_BtnClose", bar, 150, 32, L("BTN_CLOSE"), function() EsoAR:ToggleSettingsWindow(false) end)
  close:SetAnchor(RIGHT, bar, RIGHT, 0, 0)
  local reset = makeButton("EsoAR_BtnReset", bar, 150, 32, L("BTN_RESET"), function() EsoAR:ResetSettings() end)
  reset:SetAnchor(RIGHT, close, LEFT, -12, 0)
  local all = makeButton("EsoAR_BtnAll", bar, 200, 32, L("BTN_ALL"), function() EsoAR:ApplyHeadingFontToAll() end)
  all:SetAnchor(RIGHT, reset, LEFT, -12, 0)
end

function EsoAR:RefreshSettingsWindow()
  local win = EsoAR_SettingsWindow
  if not win or win:IsHidden() then return end
  local sv = EsoAR.savedVars
  for cat, r in pairs(rows) do
    r.font:SetText(L("FONT_" .. (sv.fonts[cat] or "noto")))
    r.size:SetText(tostring(sv.scale[cat] or 100) .. "%")
  end
  if widgets.width then
    local w = sv.dialogueWidth or 0
    widgets.width:SetText(w == 0 and L("DEFAULT_WIDTH") or tostring(w))
  end
end

function EsoAR:ToggleSettingsWindow(show)
  local win = EsoAR_SettingsWindow
  if not win then return end
  buildWindow()
  if show == nil then show = win:IsHidden() end
  win:SetHidden(not show)
  if show then EsoAR:RefreshSettingsWindow() end
end

-- Open whichever UI fits the current input mode.
function EsoAR:OpenSettings()
  if IsInGamepadPreferredMode() and EsoAR.OpenGamepadSettings and EsoAR:OpenGamepadSettings() then return end
  EsoAR:ToggleSettingsWindow(true)
end

-- ------------------------------------------------------------ chat command
local function say(msg) CHAT_ROUTER:AddSystemMessage("|c6FA8DCEsoAR|r " .. msg) end

local function listState()
  local sv = EsoAR.savedVars
  local keys = {}
  for _, f in ipairs(EsoAR.FONTS) do keys[#keys + 1] = f.key end
  say("fonts: " .. table.concat(keys, ", "))
  for _, cat in ipairs(CATS) do
    say(string.format("%-9s font=%-8s size=%d%%", cat, sv.fonts[cat] or "noto", sv.scale[cat] or 100))
  end
  say("dialogue width=" .. tostring(sv.dialogueWidth or 0))
end

local function handleCommand(text)
  local args = {}
  for w in string.gmatch(text or "", "%S+") do args[#args + 1] = string.lower(w) end
  local cmd = args[1]
  local sv = EsoAR.savedVars
  if not cmd or cmd == "" or cmd == "open" then
    EsoAR:OpenSettings()
  elseif cmd == "menu" then
    EsoAR:OpenMenu()
  elseif cmd == "window" then
    EsoAR:ToggleSettingsWindow(true)
  elseif cmd == "list" then
    listState()
  elseif cmd == "reset" then
    EsoAR:ResetSettings(); say("reset")
  elseif cmd == "font" and args[2] and args[3] then
    local key = args[3]
    local valid = false
    for _, f in ipairs(EsoAR.FONTS) do if f.key == key then valid = true end end
    if not valid then say("unknown font: " .. key); return end
    if args[2] == "all" then
      for _, cat in ipairs(CATS) do sv.fonts[cat] = key end
    elseif sv.fonts[args[2]] ~= nil then
      sv.fonts[args[2]] = key
    else
      say("unknown category: " .. args[2]); return
    end
    apply(); say("font " .. args[2] .. " = " .. key)
  elseif cmd == "size" and args[2] and tonumber(args[3]) then
    local v = math.max(SIZE_MIN, math.min(SIZE_MAX, tonumber(args[3])))
    if args[2] == "all" then
      for _, cat in ipairs(CATS) do sv.scale[cat] = v end
    elseif sv.scale[args[2]] ~= nil then
      sv.scale[args[2]] = v
    else
      say("unknown category: " .. args[2]); return
    end
    apply(); say("size " .. args[2] .. " = " .. v .. "%")
  elseif (cmd == "digits" or cmd == "traits" or cmd == "sets" or cmd == "zones") and args[2] then
    local on = (args[2] == "on" or args[2] == "ar" or args[2] == "1")
    local off = (args[2] == "off" or args[2] == "en" or args[2] == "0")
    if not (on or off) then say("usage: /esoar " .. cmd .. " on|off"); return end
    if cmd == "digits" then sv.arabicDigits = on; EsoAR:ApplyFonts()
    elseif cmd == "traits" then sv.englishTraits = off; EsoAR:ApplyTraitNames()
    elseif cmd == "sets" then sv.englishSets = off
    else sv.englishZones = off end
    say(cmd .. " = " .. (on and "arabic" or "english"))
  elseif cmd == "width" and tonumber(args[2]) then
    sv.dialogueWidth = math.max(0, math.min(WIDTH_MAX, tonumber(args[2])))
    apply(); say("dialogue width = " .. sv.dialogueWidth)
  else
    say("usage: /esoar [open|window|list|reset|font <cat|all> <key>|size <cat|all> <50-200>|width <px>|digits|traits|sets|zones on/off]")
  end
end

function EsoAR:InitSettingsWindow()
  SLASH_COMMANDS["/esoar"] = handleCommand
  SLASH_COMMANDS["/تعريب"] = handleCommand
end
