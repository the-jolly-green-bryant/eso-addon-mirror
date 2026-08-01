--========================================
--        vars
--========================================
local addon = AssistVampireTrade -- Addon#M
local m = {} -- #M
local l = {} -- #L
local SV_NAME = "AVTSV"
local SV_VER = "1.3"

---
--@type SavedVars
local savedVarsDefaults = {
  accountWide = false,
}

---
--@type MenuOption
--@field #string type
--@field #string name
--@field #()->(#any) getFunc
--@field #(#any:value)->() setFunc
--@field #string width
--@field #any default

--========================================
--        l
--========================================
l.accountSavedVars = {}  --#SavedVars
l.characterSavedVars = {}  --#SavedVars
l.menuOptions = {} --#list<#MenuOption>

l.onStart -- #()->()
= function()
  -- load saved vars with defaults
  addon.callExtension(m.EXTKEY_ADD_DEFAULTS)
  l.accountSavedVars = ZO_SavedVars:NewAccountWide(SV_NAME, SV_VER, nil, savedVarsDefaults)
  l.characterSavedVars = ZO_SavedVars:New(SV_NAME, SV_VER, nil, savedVarsDefaults)
  -- register addon panel
  local LAM2 = LibAddonMenu2
  if LAM2 == nil then return end
  local panelData = {
    debugLevel = 0,
    type = 'panel',
    name = addon.name,
    displayName = "|t32:32:AssistVampireTrade/AVT.dds|t |cff0000AVT Settings|r",
    author = "|cefebbe@Mr_Negative420 (EU)|r",
    version = addon.version,
    website = "https://www.esoui.com/downloads/info3780-AssistVampireTrade.html#info",
    slashCommand = "/avtset",
    registerForRefresh = true,
    registerForDefaults = true,
  }
  LAM2:RegisterAddonPanel('AVTAddonOptions', panelData)
  -- init menu options
  m.addMenuOptions({
    type = "header",
    name = zo_strformat("|c<<1>>Settings|r", ZO_HIGHLIGHT_TEXT:ToHex()),
    width = "full",
  })
  m.addMenuOptions({
    type = "checkbox",
    name = zo_strformat("|c<<1>>Account wide configuration|r", ZO_HIGHLIGHT_TEXT:ToHex()),
    getFunc = function() return l.accountSavedVars.accountWide end,
    setFunc = function(value)
      l.accountSavedVars.accountWide = value
    end,
    width = "full",
    default = true,
  })
  addon.callExtension(m.EXTKEY_ADD_MENUS)
  LAM2:RegisterOptionControls('AVTAddonOptions', l.menuOptions)
end

--========================================
--        m
--========================================
m.EXTKEY_ADD_DEFAULTS = "Settings:addDefaults"
m.EXTKEY_ADD_MENUS = "Settings:addMenus"

m.addDefaults -- #(#any:...)->()
= function(...)
  zo_mixin(savedVarsDefaults, ...)
end

m.addMenuOptions -- #(#MenuOption:...)->()
= function(...)
  for i=1,select('#',...) do
    local option = select(i, ...)
    table.insert(l.menuOptions, option)
  end
end

m.getAccountSavedVars -- #()->(#SavedVars)
= function()
  return l.accountSavedVars
end

m.getCharacterSavedVars -- #()->(#SavedVars)
= function()
  return l.characterSavedVars
end

m.getSavedVars -- #()->(#SavedVars)
= function()
  return l.accountSavedVars.accountWide and l.accountSavedVars or l.characterSavedVars
end

--========================================
--        register
--========================================
addon.register("Settings#M",m)
addon.hookStart(l.onStart)
