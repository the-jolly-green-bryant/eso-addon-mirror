local DEG_ADDON = _G["DEG_CURRENT_ADDON"]

local function d(...)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d(...)
end

local LAM2 = LibAddonMenu2

local Obj = {
  initialized = false,
  Addon = nil,
}

function Obj:initialize()
  if self.initialized then return end

  self.Addon = _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]

  local optionsPanelConfig  = {
    type = "panel",
    name = "Dryzler's LoreBooks",
    displayName = "|c3f95ffDryzler's|r |cEFEBBELoreBooks|r",
    author = "|cEFEBBEdryzler.elder-geek.net|r",
    website = "https://www.esoui.com/downloads/fileinfo.php?id=2443",
    version = self.Addon.versionString,
    slashCommand = "/drylore",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  LAM2:RegisterAddonPanel(self.Addon.name, optionsPanelConfig)

  local optionsPanelControls = {}

  for i=1,GetNumCharacters() do
    local charName, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo(i)
    charName = charName:sub(1, charName:find("%^") - 1)

    table.insert(optionsPanelControls, {
      type = "checkbox",
      name = charName,
      getFunc = function()
        return self.Addon:CharWantsBooks(charId)
      end,
      setFunc = function(newValue)
        self.Addon:setCharWantsBooks(charId, newValue)
      end,
      default = function()
        return true
      end
    })
  end

  LAM2:RegisterOptionControls(self.Addon.name, optionsPanelControls)



  self.initialized = true
end

_G[_G["DEG_CURRENT_ADDON"].ADDON_NAME.."Settings"] = Obj
