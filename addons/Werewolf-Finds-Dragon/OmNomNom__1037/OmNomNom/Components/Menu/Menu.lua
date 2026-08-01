local obj = omNomNomAddon
local db  = omNomNomAddonDB

function obj.setupMenuObject(_, addon)
  if addon ~= "OmNomNom" or not LibStub then return end

  obj.menuObject = LibStub:GetLibrary("LibAddonMenu-2.0")

  if not obj.menuObject then return end

  local lom        = obj.lom
  local playerName = GetUnitName("player")

  obj.panelData = {
    type                  = "panel",
    name                  = "Om Nom Nom",
    displayName           = function() return lom:Format("<<LOM-BLUE>>Om Nom Nom!<<LOM-CLEAR>>", {BLUE=lom.blueColor, CLEAR=lom.clearColor}) end,
    author                = "Werewolf Finds Dragon",
    resetFunc             = function() obj.eventHandler(nil, true) end,
    registerForRefresh    = true,
    registerForDefaults   = true
  }

  obj.optionsData = {
    {
      type                  = "description",
      text                  = "Provides you with a text alert when your food/drink buff expires."
    },

    {
      type                  = "checkbox",
      name                  = "Toggle Addon",
      tooltip               = "This option respectively enables/disables OmNomNom's functionality.",
      getFunc               = function() return db.addonState end,
      setFunc               = function() db.addonState = not db.addonState obj.eventHandler() end
    },

    {
      type                  = "editbox",
      name                  = "Food Effect Expired Text",
      tooltip               = "This is what you see as an alert when your food buff expires.",
      getFunc               = function() return db[playerName].foodText end,
      setFunc               = function(var) db[playerName].foodText = var end,
      disabled              = function() return not db.addonState end,
      default               = obj.defaultsDB[playerName].foodText
    },

    {
      type                  = "editbox",
      name                  = "Drink Effect Expired Text",
      tooltip               = "This is what you see as an alert when your drink buff expires.",
      getFunc               = function() return db[playerName].drinkText end,
      setFunc               = function(var) db[playerName].drinkText = var end,
      disabled              = function() return not db.addonState end,
      default               = obj.defaultsDB[playerName].drinkText
    }
  }

  obj.menuObject:RegisterAddonPanel("OmNomNom_Panel",     obj.panelData)
  obj.menuObject:RegisterOptionControls("OmNomNom_Panel", obj.optionsData)

  EVENT_MANAGER:UnregisterForEvent("OmNomNom_MenuLoad")
end

EVENT_MANAGER:RegisterForEvent("OmNomNom_MenuLoad", EVENT_ADD_ON_LOADED, obj.setupMenuObject)