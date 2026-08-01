FurnishingRecipeCollector = FurnishingRecipeCollector or {}
local FRC = FurnishingRecipeCollector
FRC.Name = "FurnishingRecipeCollector"
FRC.DisplayName = "Furnishing Recipe Collector"
FRC.Author = "tomstock"
FRC.Version = "1.4.9"

FRC.logger = nil

FRC.defaultSetting = {
  debug = false,
  price="Avg",
  furnishing_on = true,
  furnishing_showrecipe_on = true,
  furnishing_showrecipe_ttc_on = true,
  furnishing_showrecipe_lck_on = true,
  furnishingrecipe_on = true,
  furnishingrecipe_ttc_on = true,
  grabbag_on= true,
  grabbag_lck_on= true,
  folio_on= true,
  folio_lck_on= true,
  colorCharUnknown=0x777766,
  colorCharKnown=0x3399FF,
  colorAllUnknown=0x777766,
  colorAllKnown=0x55ff1c,
  colorAllPartial=0x3399FF,
  colorQualityNormal=0XEDEAED,
  colorQualityMagic=0X34A221,
  colorQualitySuperior=0X458ADF,
  colorQualityEpic=0X9D43EC,
  colorQualityLegendary=0XE2C437,
  gui={
    lastX = 100,
    lastY = 100,
    width = 650,
    height = 550,
    sort = "Location",
    sortDirection = ZO_SORT_ORDER_UP,
    filterLocation = "All",
    filterQuality = "All",
    filterKnowledge = "All",
  },
  guiDebug={
    lastX = 100,
    lastY = 100,
    width = 650,
    height = 550,
  }
}

--------------------------------------------------------------------
-- Locals
--------------------------------------------------------------------
--ZOs local speed-up/reference variables
local tos = tostring
local LCK = LibCharacterKnowledge
local SLASH = LibSlashCommander

local slashMainCommand
local slashDebugCommand

--[[
  ==============================================
  Setup LibDebugLogger as an optional dependency
  ==============================================
--]]
if LibDebugLogger then
  FRC.logger = LibDebugLogger.Create(FRC.Name)
  FRC.logger:SetEnabled(false)
end

--[[
  ==============================================
  Plugin Initialization - cache titles where possible, recreate when necessary
  ==============================================
--]]
local function OnLoad(eventCode, name)

  if name ~= FRC.Name then return end
  EVENT_MANAGER:UnregisterForEvent(FRC.Name, EVENT_ADD_ON_LOADED)

  FRC.savedVariables = ZO_SavedVars:NewAccountWide("FurnishingRecipeCollectorSavedVariables", 1, nil, FRC.defaultSetting) --Instead of nil you can also use GetWorldName() to save the SV server dependent

  if FRC.logger ~= nil then FRC.logger:Info("Loaded logger") end
  if FRC.logger ~= nil then FRC.logger:SetEnabled(FRC.savedVariables.debug) end

  local menuOptions = {
    type         = "panel",
    name         = FRC.DisplayName,
    displayName   = FRC.DisplayName,
    author       = FRC.Author,
    version       = FRC.Version,
    registerForRefresh  = true,
    registerForDefaults = true,
  }

  local dataTable = {
    {
      type = "description",
      text = "Displays additional information in tooltips for furnshing recipes obtained through Writ vendors. ",
    },
    {
      type = "description",
      text = "Character Knowledge requires the LibCharacterKnowledge library to be installed or Character Knowledge addon installed.",
    },
    {
      type = "description",
      text = "Debug requires the LibDebugLogger library to be installed",
    },
    {
      type = "description",
      text = "Prices require the TamrielTradeCentre addon to be installed",
    },
    {
      type = "divider",
    },
    {
      type = "description",
      text = "/furrecipe - opens a window for viewing recipe list",
    },
    {
      type = "divider",
    },
    {
      type = "dropdown", name = "TTC Price", tooltip = "The price that will display across the addon", choices = {"Min", "Avg", "Max"}, getFunc = function() return FRC.savedVariables.price end, setFunc = function( newValue ) FRC.savedVariables.price = newValue; if FRC.logger ~= nil then FRC.logger:SetEnabled(FRC.savedVariables.price) end end, },
    {
      type = "divider",
    },
    { type = "checkbox", name = "Debug Logging Enabled", getFunc = function() return FRC.savedVariables.debug end, setFunc = function( newValue ) FRC.savedVariables.debug = newValue; if FRC.logger ~= nil then FRC.logger:SetEnabled(FRC.savedVariables.debug) end end, --[[warning = "",]] requiresReload = false},
    {
      type = "divider",
    },
    {type = "checkbox",name = "Show on Furnishings",getFunc = function() return FRC.savedVariables.furnishing_on end,setFunc = function( newValue ) FRC.savedVariables.furnishing_on = newValue; end,--[[warning = "",]]  requiresReload = false},
    {type = "checkbox",name = "Show Recipe on Furnishings",getFunc = function() return FRC.savedVariables.furnishing_showrecipe_on end,setFunc = function( newValue ) FRC.savedVariables.furnishing_showrecipe_on = newValue; end,--[[warning = "",]]  requiresReload = false},
    {type = "checkbox",name = "Show Recipe TTC Value on Furnishings",getFunc = function() return FRC.savedVariables.furnishing_showrecipe_ttc_on end,setFunc = function( newValue ) FRC.savedVariables.furnishing_showrecipe_ttc_on = newValue; end,--[[warning = "",]]  requiresReload = false},
    {type = "checkbox",name = "Show Recipe Character Knowledge on Furnishings",getFunc = function() return FRC.savedVariables.furnishing_showrecipe_lck_on end,setFunc = function( newValue ) FRC.savedVariables.furnishing_showrecipe_lck_on = newValue; end,--[[warning = "",]]  requiresReload = false},
    {
      type = "divider",
    },
    {type = "checkbox",name = "Show on Furnishing Recipes",getFunc = function() return FRC.savedVariables.furnishingrecipe_on end,setFunc = function( newValue ) FRC.savedVariables.furnishingrecipe_on = newValue; end,--[[warning = "",]]  requiresReload = false},
    {type = "checkbox",name = "Show Recipe TTC Value on Furnishing Recipes",getFunc = function() return FRC.savedVariables.furnishingrecipe_ttc_on end,setFunc = function( newValue ) FRC.savedVariables.furnishingrecipe_ttc_on = newValue; end,--[[warning = "",]]  requiresReload = false},

    {
      type = "divider",
    },
    {type = "checkbox",name = "Show on Writ Vendor Grab Bags",getFunc = function() return FRC.savedVariables.grabbag_on end,setFunc = function( newValue ) FRC.savedVariables.grabbag_on = newValue; end,--[[warning = "",]]  requiresReload = false},
    {type = "checkbox",name = "Show Character Knowledge",getFunc = function() return FRC.savedVariables.grabbag_lck_on end,setFunc = function( newValue ) FRC.savedVariables.grabbag_lck_on = newValue; end,--[[warning = "",]]  requiresReload = false},
    {
      type = "divider",
    },
    {type = "checkbox",name = "Show on Writ Vendor Folios",getFunc = function() return FRC.savedVariables.folio_on end,setFunc = function( newValue ) FRC.savedVariables.folio_on = newValue; end,--[[warning = "",]]  requiresReload = false},
    {type = "checkbox",name = "Show Character Knowledge",getFunc = function() return FRC.savedVariables.folio_lck_on end,setFunc = function( newValue ) FRC.savedVariables.folio_lck_on = newValue; end,--[[warning = "",]]  requiresReload = false},
  }
  local LAM = LibAddonMenu2
  LAM:RegisterAddonPanel(FRC.Name .. "Options", menuOptions )
  LAM:RegisterOptionControls(FRC.Name .. "Options", dataTable )

  FRC.HookTooltips()

  if LCK ~= nil then
    LCK.RegisterForCallback("InsertYourAddonNameHere", LCK.EVENT_INITIALIZED, function( )
      FRC.InitGui()
      FRC.InitDebugGui()
    end)
  else
    FRC.InitGui()
    FRC.InitDebugGui()
  end

  if not IsConsoleUI() then
    if SLASH ~= nil then
      slashMainCommand = SLASH:Register()
      slashMainCommand:AddAlias("/furrecipe")
      slashMainCommand:AddAlias("/frc")
      slashMainCommand:SetCallback(FurnishingRecipeCollector.FRC_Toggle)
      slashMainCommand:SetDescription("Furniture Recipe Collector")
      slashDebugCommand = SLASH:Register()
      slashDebugCommand:AddAlias("/frc_debug")
      slashDebugCommand:SetCallback(FurnishingRecipeCollector.FRC_DebugToggle)
      slashDebugCommand:SetDescription("Furniture Recipe Collector Debug")
    else
      SLASH_COMMANDS["/furrecipe"] = FurnishingRecipeCollector.FRC_Toggle
      SLASH_COMMANDS["/frc"] = FurnishingRecipeCollector.FRC_Toggle
      SLASH_COMMANDS["/frc_debug"] = FurnishingRecipeCollector.FRC_DebugToggle
    end
  end
end
function FRC.Donate(control, mouseButton)
  local amount = 2000
  if mouseButton == 2 then
    amount = 10000
  elseif mouseButton == 3 then
    amount = 25000
  end

  SCENE_MANAGER:Show("mailSend")
  zo_callLater(function()
    ZO_MailSendToField:SetText("@tomstock")
    ZO_MailSendSubjectField:SetText("Thank you for FurnishingRecipeCollector!")
    QueueMoneyAttachment(amount)
    ZO_MailSendBodyField:TakeFocus()
  end, 200)
end
--[[
  ==============================================
  AddOn global and loading
  ==============================================
--]]
FRC = FRC
EVENT_MANAGER:RegisterForEvent(FRC.Name, EVENT_ADD_ON_LOADED, OnLoad)