local LMP = LibMediaProvider
EsoAR = EsoAR or {}
EsoAR.name = "EsoAR"
EsoAR.version = "1.6.2"
EsoAR.firstInit = true
EsoAR.chat = { changed = true, privCursorPos = 0, editing = false }
EsoAR.langVer = { stable = "ar" }

-- Global toggle for keyboard conversion (English <-> Arabic)
langKeyboard = langKeyboard or "en"

-- Fonts shipped in EsoAR/fonts/. Every one has been checked to contain the
-- Arabic presentation-form glyphs the game needs (Cairo is a remapped build).
EsoAR.FONTS = {
  { key = "noto",    file = "NotoNaskhArabic.slug" },
  { key = "andalus", file = "1_AndalusArabic.slug" },
  { key = "tahoma",  file = "Tahoma.slug" },
  { key = "tahomab", file = "TahomaBold.slug" },
  { key = "segoe",   file = "SegoeUI.slug" },
  { key = "arial",   file = "Arial.slug" },
  { key = "times",   file = "TimesNewRoman.slug" },
  { key = "trad",    file = "TraditionalArabic.slug" },
  { key = "majalla", file = "SakkalMajalla.slug" },
  { key = "calibri", file = "Calibri.slug" },
  { key = "cairo",   file = "Cairo.slug" },
}
local FONT_FILE = {}
for _, f in ipairs(EsoAR.FONTS) do FONT_FILE[f.key] = f.file end

-- "<Name>-ArDigits.slug": same font with 0-9 drawn as Arabic-Indic digits
-- (built by tools/make_digit_fonts.py). Used when savedVars.arabicDigits is on.
local function digitVariant(file) return (file:gsub("%.slug$", "-ArDigits.slug")) end

local DEFAULT_DIALOGUE_COLOR = { r = 0.77, g = 0.76, b = 0.62, a = 1, custom = false }

EsoAR.Defaults = {
  lang = "ar",
  ignorePatcher = true,
  fonts = { heading = "noto", body = "noto", dialogue = "noto", tooltip = "noto", chat = "noto", book = "noto" },
  scale = { heading = 100, body = 100, dialogue = 100, tooltip = 100, chat = 100, book = 100 },
  dialogueColor = DEFAULT_DIALOGUE_COLOR,
  dialogueWidth = 0,
  -- EsoAR menu switches: true = Arabic, false = English
  arabicDigits = false,   -- all digits drawn as Arabic-Indic (font swap)
  englishTraits = false,  -- trait names (SafeAddString, traits_en.lua)
  englishSets = false,    -- set / set-piece names (API wrappers, sets_en.lua)
  englishZones = false,   -- zone / map / location names (API wrappers, zones_en.lua)
}
EsoAR.savedVars = EsoAR.Defaults

local function isOurLanguage(code) return code == "ar" or code == "en" end

-- Console builds cannot change base-game settings (language CVar) and the
-- custom .lang/.str files cannot be installed there, so language switching is
-- PC-only. Also never reload more than once per session (no reload loops).
local function onConsole() return IsConsoleUI and IsConsoleUI() end
local languageSwitchAttempted = false

function EsoAR:setLanguage(lang, force)
  if onConsole() or (languageSwitchAttempted and not force) then return end
  languageSwitchAttempted = true
  zo_callLater(function()
    local ok = pcall(SetCVar, "language.2", lang)
    if ok and GetCVar("language.2") == lang then
      EsoAR.savedVars.lang = lang
      ReloadUI()
    end
  end, 500)
end

function EsoAR:getLanguage() return GetCVar("language.2") end

function EsoAR:getFontPath()
  if isOurLanguage(self:getLanguage()) then return "EsoAR/fonts/" end
  return "EsoUI/Common/Fonts/"
end


local function facePath(cat)
  local sv = EsoAR.savedVars
  local key = (sv.fonts and sv.fonts[cat]) or "noto"
  local file = FONT_FILE[key] or FONT_FILE.noto
  if sv.arabicDigits then file = digitVariant(file) end
  return "EsoAR/fonts/" .. file
end

local function scaled(base, cat)
  local sv = EsoAR.savedVars
  local pct = (sv.scale and sv.scale[cat]) or 100
  return math.max(8, math.floor(base * pct / 100 + 0.5))
end

-- Remember the game's own tooltip style sizes once so scaling stays relative
-- to the original instead of compounding on every apply.
local tooltipBase = nil
local TOOLTIP_STYLE_TABLES = { "ZO_TOOLTIP_STYLES", "ZO_CRAFTING_TOOLTIP_STYLES", "ZO_GAMEPAD_DYEING_TOOLTIP_STYLES" }

local function snapshotTooltipBase()
  if tooltipBase then return end
  tooltipBase = {}
  for _, tname in ipairs(TOOLTIP_STYLE_TABLES) do
    local t = _G[tname]
    if type(t) == "table" then
      tooltipBase[tname] = {}
      for key, style in pairs(t) do
        if type(style) == "table" and type(style.fontSize) == "number" then
          tooltipBase[tname][key] = style.fontSize
        end
      end
    end
  end
end

-- Apply the player's font/size choices to every named game font, tooltip style,
-- combat text, nameplates and the dialogue window. Safe to call repeatedly.
function EsoAR:ApplyFonts()
  local defs = EsoAR.fontDefs or {}
  for name, def in pairs(defs) do
    local obj = _G[name]
    if obj and obj.SetFont then
      local base, style, cat = def[1], def[2], def[3]
      local str = facePath(cat) .. "|" .. scaled(base, cat)
      if style and style ~= "" then str = str .. "|" .. style end
      obj:SetFont(str)
    end
  end

  snapshotTooltipBase()
  local tipFace = facePath("tooltip")
  for _, tname in ipairs(TOOLTIP_STYLE_TABLES) do
    local t = _G[tname]
    if type(t) == "table" then
      for key, style in pairs(t) do
        if type(style) == "table" then
          style.fontFace = tipFace
          local base = tooltipBase[tname] and tooltipBase[tname][key]
          if base then style.fontSize = scaled(base, "tooltip") end
        end
      end
    end
  end

  local headFace = facePath("heading")
  if not SetSCTKeyboardFont then return EsoAR:ApplyDialogueStyle() end
  SetSCTKeyboardFont(headFace .. "|" .. scaled(17, "heading") .. "|soft-shadow-thick")
  SetSCTGamepadFont(headFace .. "|" .. scaled(21, "heading") .. "|soft-shadow-thick")
  SetNameplateKeyboardFont(headFace .. "|" .. scaled(12, "heading"), 4)
  SetNameplateGamepadFont(headFace .. "|" .. scaled(12, "heading"), 4)

  EsoAR:ApplyDialogueStyle()
end

function EsoAR:ApplyDialogueStyle()
  local body = ZO_InteractWindowTargetAreaBodyText
  if body then
    local c = EsoAR.savedVars.dialogueColor
    if c and c.custom then body:SetColor(c.r, c.g, c.b, c.a or 1) end
    local w = EsoAR.savedVars.dialogueWidth
    if w and w > 0 then body:SetWidth(w) end
  end
end

-- Trait names live in the client string table (SI_ITEMTRAITTYPE*). The
-- Arabic values come from ar_client.str; SafeAddString swaps them for the
-- English names from traits_en.lua and back, instantly.
local traitArabic = nil
local traitVersion = 100
function EsoAR:ApplyTraitNames()
  local names = EsoAR.TRAITS_EN
  if not names or not SafeAddString then return end
  if not traitArabic then
    traitArabic = {}
    for sid in pairs(names) do
      local id = _G[sid]
      if id then traitArabic[sid] = GetString(id) end
    end
  end
  traitVersion = traitVersion + 1
  local english = EsoAR.savedVars.englishTraits
  for sid, en in pairs(names) do
    local id = _G[sid]
    local ar = traitArabic[sid]
    if id and ar then SafeAddString(id, english and en or ar, traitVersion) end
  end
end

local function registerMediaFonts()
  if not LMP then return end
  for _, f in ipairs(EsoAR.FONTS) do
    local label = (EsoAR.L and EsoAR.L["FONT_" .. f.key]) or f.key
    LMP:Register("font", "EsoAR " .. label, "EsoAR/fonts/" .. f.file)
  end
end

local function EsoARInit()
  registerMediaFonts()
  EsoAR:ApplyFonts()
  EsoAR:ApplyTraitNames()
  if EsoAR.InstallNameHooks then EsoAR:InstallNameHooks() end
  ZO_CreateStringId("SI_BINDING_NAME_CHANGE_LANG_KEYBOARD", "ﺔﻳﺰﻴﻠﺠﻧﻹﺍ/ﺔﻴﺑﺮﻌﻟﺍ ﺢﻴﺗﺎﻔﻤﻟﺍ ﺔﺣﻮﻟ ﻞﻳﺪﺒﺗ")

  ZO_PreHook("ZO_ChatTextEntry_Execute", function(control) control.system:CloseTextEntry(true) end)
  ZO_PreHook("ZO_ChatTextEntry_Escape", function(control) control.system:CloseTextEntry(true) end)
  ZO_PreHook("ZO_ChatTextEntry_TextChanged", function(control, newText) EsoAR:Convert(control.system.textEntry) end)
  ZO_PreHook("ZO_EditDefaultText_OnTextChanged", function(edit) EsoAR:Convert(edit) end)

  if EsoAR.RegisterSettings then EsoAR:RegisterSettings() end
  if EsoAR.InitSettingsWindow then EsoAR:InitSettingsWindow() end
  if EsoAR.AddMainMenuEntry then EsoAR:AddMainMenuEntry() end
end

function EsoAR:SwitchLangKeyboard()
  if langKeyboard == "ar" then langKeyboard = "en" else langKeyboard = "ar" end
end

local function loadscreen(eventCode)
  EsoAR:ApplyFonts()
  if EsoAR.firstInit then
    EsoAR.firstInit = false
    local cur = EsoAR:getLanguage()
    if cur ~= "ar" and EsoAR.savedVars.lang ~= "en" then
      EsoAR.savedVars.lang = "ar"
      EsoAR:setLanguage("ar")
    end
  end
  zo_callLater(function() CALLBACK_MANAGER:FireCallbacks("loadscreen") end, 1000)
end

function EsoAR:newInit()
  EsoAR.savedVars = ZO_SavedVars:NewAccountWide("EsoAR_Variables", 1, nil, EsoAR.Defaults)
  -- saved-vars from older versions lack the new tables; fill them in
  EsoAR.savedVars.fonts = EsoAR.savedVars.fonts or ZO_ShallowTableCopy(EsoAR.Defaults.fonts)
  EsoAR.savedVars.scale = EsoAR.savedVars.scale or ZO_ShallowTableCopy(EsoAR.Defaults.scale)
  EsoAR.savedVars.dialogueColor = EsoAR.savedVars.dialogueColor or DEFAULT_DIALOGUE_COLOR
  EsoAR.savedVars.dialogueWidth = EsoAR.savedVars.dialogueWidth or 0
  for _, k in ipairs({ "arabicDigits", "englishTraits", "englishSets", "englishZones" }) do
    if EsoAR.savedVars[k] == nil then EsoAR.savedVars[k] = false end
  end
  for _, cat in ipairs({ "heading", "body", "dialogue", "tooltip", "chat", "book" }) do
    if not FONT_FILE[EsoAR.savedVars.fonts[cat] or ""] then EsoAR.savedVars.fonts[cat] = "noto" end
    EsoAR.savedVars.scale[cat] = EsoAR.savedVars.scale[cat] or 100
  end

  if not onConsole() then
    if EsoAR:getLanguage() ~= "en" then
      pcall(SetCVar, "IgnorePatcherLanguageSetting", 1)
      if GetCVar("IgnorePatcherLanguageSetting") == "1" then EsoAR.savedVars.ignorePatcher = true end
    else
      pcall(SetCVar, "IgnorePatcherLanguageSetting", 0)
    end
  end
end

local function LoadscreenLoaded()
  if EsoAR.savedVars.addonVer ~= EsoAR.version then
    EsoAR.savedVars.addonVer = EsoAR.version
  end
end

local function onAddonLoaded(eventCode, addonName)
  if addonName ~= EsoAR.name then return end
  EVENT_MANAGER:UnregisterForEvent(EsoAR.name, EVENT_ADD_ON_LOADED)
  EsoAR:newInit()
  EsoARInit()
end

EVENT_MANAGER:RegisterForEvent(EsoAR.name, EVENT_ADD_ON_LOADED, onAddonLoaded)
EVENT_MANAGER:RegisterForEvent("EsoAR_LoadScreen", EVENT_PLAYER_ACTIVATED, loadscreen)
CALLBACK_MANAGER:RegisterCallback("loadscreen", LoadscreenLoaded)
