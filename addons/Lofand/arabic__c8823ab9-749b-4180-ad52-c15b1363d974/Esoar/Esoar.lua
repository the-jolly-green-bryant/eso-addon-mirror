local LMP = LibMediaProvider
EsoAR = EsoAR or {
  name = "EsoAR",
  firstInit = true,
  chat = { changed = true, privCursorPos = 0, editing = false },
  version = "0.12",
  langKeyboard = "en",
  langVer = {
  ["stable"] = "ar",
  },
}

-- Global toggle for keyboard conversion (English <-> Arabic)
langKeyboard = langKeyboard or "en"

EsoAR.Defaults = {
  Anchor = { BOTTOMRIGHT, BOTTOMRIGHT, 0, 7 },
  ignorePatcher = true,
  lang = "ar",
}
EsoAR.savedVars = EsoAR.Defaults

local arabic = { EsoAR.langVer.stable, }
local isNeedToChangeAdditionalFontTable = { EsoAR.langVer.stable, "en", }

function EsoAR:setLanguage(lang)
  zo_callLater(function()
    SetCVar("language.2", lang)
    EsoAR.savedVars.lang = lang
    ReloadUI()
  end, 500)
end

function EsoAR:getLanguage() return GetCVar("language.2") end

function EsoAR:getFontPath()
  for _, x in pairs(isNeedToChangeAdditionalFontTable) do if self:getLanguage() == x then return "EsoAR/fonts/" end end
  return "EsoUI/Common/Fonts/"
end

function EsoAR:fontChangeWhenInit()
  local styles = { "ZO_TOOLTIP_STYLES", "ZO_CRAFTING_TOOLTIP_STYLES", "ZO_GAMEPAD_DYEING_TOOLTIP_STYLES" }
  local path = EsoAR:getFontPath()
  local function f(x) return path .. x end
  local fontFaces = EsoAR.fontFaces
  for _, v in pairs(styles) do for k, fnt in pairs(fontFaces[v]) do _G[v][k]["fontFace"] = f(fnt) end end

  local fontString = "EsoAR/fonts/arabic-medium.slug"
  for _, fontStyle in pairs(styles) do
    local fontInformation = _G[fontStyle]
    for key, fontData in pairs(fontInformation) do
      fontData["fontFace"] = fontString
    end
  end

  LMP:Register("font", "عربي (أساسي)", "$(EsoAR_SARABUN_FONT)")
  LMP:Register("font", "عربي (متوسط)", "$(EsoAR_SARABUN_MEDIUM_FONT)")
  LMP:Register("font", "عربي (عريض)", "$(EsoAR_SARABUN_BOLD_FONT)")
  LMP:Register("font", "TH Noto Serif Medium", "$(EsoAR_NOTO_SERIF_THAI_MEDIUM_FONT)")

  SetSCTKeyboardFont(f(fontFaces.FTN87) .. "|29|soft-shadow-thick")
  SetSCTGamepadFont(f(fontFaces.FTN87) .. "|35|soft-shadow-thick")
  SetNameplateKeyboardFont(f(fontFaces.FTN87), 4)
  SetNameplateGamepadFont(f(fontFaces.FTN87), 4)

  ZoFontTributeAntique40:SetFont("EsoAR/fonts/notoserifthai-medium.slug|40")
  ZoFontTributeAntique30:SetFont("EsoAR/fonts/notoserifthai-medium.slug|30")
  ZoFontTributeAntique20:SetFont("EsoAR/fonts/notoserifthai-medium.slug|20")
end

local function fontChangeWhenPlayerActivated()
  local path = EsoAR:getFontPath()
  local function f(x) return path .. x end
  local fontFaces = EsoAR.fontFaces

  SetSCTKeyboardFont(f(fontFaces.FTN87) .. "|29|soft-shadow-thick")
  SetSCTGamepadFont(f(fontFaces.FTN87) .. "|35|soft-shadow-thick")
  SetNameplateKeyboardFont(f(fontFaces.FTN87) .. "|20", 4)
  SetNameplateGamepadFont(f(fontFaces.FTN87)  .. "|20", 4)
end

local function EsoARInit()
  EsoAR:fontChangeWhenInit()
  ZO_CreateStringId("SI_BINDING_NAME_CHANGE_LANG_KEYBOARD", "تبديل لوحة المفاتيح العربية/الإنجليزية")

  ZO_PreHook("ZO_ChatTextEntry_Execute", function(control) control.system:CloseTextEntry(true) end)
  ZO_PreHook("ZO_ChatTextEntry_Escape", function(control) control.system:CloseTextEntry(true) end)
  ZO_PreHook("ZO_ChatTextEntry_TextChanged", function(control, newText) EsoAR:Convert(control.system.textEntry) end)
  ZO_PreHook("ZO_EditDefaultText_OnTextChanged", function(edit) EsoAR:Convert(edit) end)
end

function EsoAR:SwitchLangKeyboard()
  if langKeyboard == "ar" then langKeyboard = "en" else langKeyboard = "ar" end
end

local function loadscreen(eventCode)
  fontChangeWhenPlayerActivated()
  if EsoAR.firstInit then
    EsoAR.firstInit = false
    for _, v in pairs(isNeedToChangeAdditionalFontTable) do
      if EsoAR:getLanguage() ~= v and EsoAR.savedVars.lang == v then EsoAR:setLanguage(v) end
    end
  end

  zo_callLater(function() CALLBACK_MANAGER:FireCallbacks("loadscreen") end, 1000)
end

function EsoAR:newInit()
  EsoAR.savedVars = ZO_SavedVars:NewAccountWide("EsoAR_Variables", 1, nil, { lang = EsoAR.langVer.stable })
  if EsoAR:getLanguage() ~= "en" then
    SetCVar("IgnorePatcherLanguageSetting", 1)
    if GetCVar("IgnorePatcherLanguageSetting") == "1" then EsoAR.savedVars["ignorePatcher"] = true end
  else
    SetCVar("IgnorePatcherLanguageSetting", 0)
  end
end

local function LoadscreenLoaded()
  if EsoAR.savedVars["addonVer"] ~= EsoAR.version then
    EsoAR.savedVars["addonVer"] = EsoAR.version
  end
end

local function onAddonLoaded(eventCode, addonName)
  if (addonName ~= EsoAR.name) then
    return
  end
  EVENT_MANAGER:UnregisterForEvent(EsoAR.name, EVENT_ADD_ON_LOADED)
  EsoAR:newInit()
  EsoARInit()
end

EVENT_MANAGER:RegisterForEvent(EsoAR.name, EVENT_ADD_ON_LOADED, onAddonLoaded)
EVENT_MANAGER:RegisterForEvent("EsoAR_LoadScreen", EVENT_PLAYER_ACTIVATED, loadscreen)
CALLBACK_MANAGER:RegisterCallback("loadscreen", LoadscreenLoaded)

