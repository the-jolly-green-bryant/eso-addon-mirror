local ADDON_NAME = 'Aldanga\'s Lazier Writ Precrafter'
local ADDON_VERSION = '1.7.0'

local LAM2 = LibAddonMenu2

LazierWritPrecrafterSettings = ZO_Object:Subclass()

local settings = nil

function LazierWritPrecrafterSettings:New()
  local obj = ZO_Object.New(self)
  self:Initialize()
  return obj
end

local optionsName = 'LazierWritPrecrafterPanel'

local PROFESSION_CONSTANTS = {
  [CRAFTING_TYPE_BLACKSMITHING] =  SI_ITEMFILTERTYPE13,
  [CRAFTING_TYPE_CLOTHIER] = SI_ITEMFILTERTYPE14,
  [CRAFTING_TYPE_WOODWORKING] = SI_ITEMFILTERTYPE15,
  [CRAFTING_TYPE_JEWELRYCRAFTING] = SI_ITEMFILTERTYPE25,
  [CRAFTING_TYPE_ENCHANTING] = SI_ITEMFILTERTYPE17,
}

function LazierWritPrecrafterSettings:Initialize()
  local LazierWritPrecrafterDefault = {
    professions = {
      [CRAFTING_TYPE_BLACKSMITHING] = true,
      [CRAFTING_TYPE_CLOTHIER] = true,
      [CRAFTING_TYPE_WOODWORKING] = true,
      [CRAFTING_TYPE_JEWELRYCRAFTING] = true,
      [CRAFTING_TYPE_ENCHANTING] = true,
    },
  }

  settings = ZO_SavedVars:NewCharacterIdSettings('LazierWritPrecrafterSettingsVars', 1, nil, LazierWritPrecrafterDefault)

  local panelData = {
    type = 'panel',
    name = ADDON_NAME,
    displayName = ADDON_NAME,
    author = 'Aldanga',
    version = ADDON_VERSION,
    slashCommand = '/lwp',
    registerForRefresh = true,
    registerForDefaults = true
  }

  LAM2:RegisterAddonPanel(optionsName, panelData)

  local optionsTable = {
    {
      type = 'header',
      name = 'Professions',
      width = 'full'
    },
  }
  for key, value in pairs(LazierWritPrecrafterDefault.professions) do
    local profession = {
      type = 'checkbox',
      name = GetString(PROFESSION_CONSTANTS[key]),
      getFunc = function()
        return settings.professions[key]
      end,
      setFunc = function(value)
        settings.professions[key] = value
      end,
      width = 'full',
      default = LazierWritPrecrafterDefault.professions[key]
    }
    table.insert(optionsTable, profession)
  end

  LAM2:RegisterOptionControls(optionsName, optionsTable)
end

function LazierWritPrecrafterSettings:GetSettings()
  return settings
end
