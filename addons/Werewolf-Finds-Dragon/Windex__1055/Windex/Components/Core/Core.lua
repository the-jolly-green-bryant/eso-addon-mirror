windexAddon   = { pluginLoadFunctions = {}, pluginCombatFunctions = {}, pluginFocusFunctions = {}, pluginPopFunctions = {}, pluginPushFunctions = {}, pluginReticleFunctions = {}, pluginToggleFunctions = {}, baseInterface = {}, combatInterface = {}, baseAddons = {}, combatAddons = {} }
windexAddonDB = windexAddonDB or { isDisabled = true }
local obj, db = windexAddon

-- Windex Functions

function obj.parseFunctions(funcType, isLoad)
  if isLoad or (db and not db.isDisabled) then
    for _, pluginFunction in pairs(obj["plugin"..funcType.."Functions"]) do
      pluginFunction(db)
    end
  end
end

function obj.doLoadFunctions()
  EVENT_MANAGER:UnregisterForEvent("windex_LoadFunctions")

  db = windexAddonDB

  obj.parseFunctions("Load", true)
end

function obj.doCombatFunctions()
  obj.inCombat = IsUnitInCombat("player")

  obj.parseFunctions("Combat")
end

function obj.doFocusFunctions(_, hasFocus)
  obj.focusChange = hasFocus

  obj.parseFunctions("Focus")
end

function obj.doPopFunctions()
  obj.parseFunctions("Pop")
end

function obj.doPushFunctions()
  obj.parseFunctions("Push")
end

function obj.doReticleFunctions()
  obj.parseFunctions("Reticle")
end

function obj.doToggleFunctions()
  db.isDisabled = not db.isDisabled

  obj.parseFunctions("Toggle", true)

  if obj.inCombat then
    obj.parseFunctions("Combat")
  end
end

function obj.fragmentHandler(state, scene, fragment)
  state = (state == true and "Add" or "Remove").."Fragment"

  scene[state](scene, fragment)
end

-- Windex Menu

function obj.setupMenuObject(_, addonName)
  if addonName ~= "Windex" then return end 

  if LibStub then
    obj.menuObject = LibStub:GetLibrary("LibAddonMenu-2.0", true)
  end

  obj.panel             = {
    type                = "panel",
    name                = "Windex",
    author              = "Werewolf Finds Dragon",
    resetFunc           = function() obj.toggleState() end,
    registerForDefaults = true
  }

  obj.options         = {
    {
      type            = "description",
      text            = "This options page allows you to control which elements will be toggled with the toggle key."
    },

    {
      type            = "description",
      text            = "You can set the toggle key under keybindings, it's necessary to do so to use this addon."
    }
  }

  obj.subMenuTypes  = {
    baseInterface   = "|ceeeeccPrimary Toggles (|rInterface|ceeeecc)|r",
    combatInterface = "|ceeeeccShow in Combat Toggles (|rInterface|ceeeecc)|r",
    baseAddons      = "|ceeeeccPrimary Toggles (|rAddOns|ceeeecc)|r",
    combatAddons    = "|ceeeeccShow in Combat Toggles (|rAddOns|ceeeecc)|r"
  }

  obj.buildSubmenu("baseInterface")
  obj.buildSubmenu("combatInterface")
  obj.buildSubmenu("baseAddons")
  obj.buildSubmenu("combatAddons")

  if obj.menuObject then
    obj.menuObject:RegisterAddonPanel("Windex_Panel",     obj.panel)
    obj.menuObject:RegisterOptionControls("Windex_Panel", obj.options)
  end

  EVENT_MANAGER:UnregisterForEvent("windex_MenuObject")
end

function obj.toggleElement(element, var)
  db[element] = var

  if obj.pluginLoadFunctions[element] then
    obj.pluginLoadFunctions[element]()
  end
end

function obj.buildMenuOptions(name, element, inject)
  if not inject or not name or not element then return end

  obj[inject][#obj[inject] + 1] = {
    type    = "checkbox",
    name    = name,
    tooltip = "Toggles "..name.." handling on/off.",
    getFunc = function() return db[element] end,
    setFunc = function(var) obj.toggleElement(element, var) end,
    default = false
  }
end

function obj.buildSubmenu(myTable)
  if next(obj[myTable]) then
    obj.options[#obj.options + 1] = {
      type     = "submenu",
      name     = obj.subMenuTypes[myTable],
      controls = obj[myTable]
    }
  end
end

-- Windex Events

EVENT_MANAGER:RegisterForEvent("windex_MenuObject",       EVENT_ADD_ON_LOADED,          obj.setupMenuObject)
EVENT_MANAGER:RegisterForEvent("windex_LoadFunctions",    EVENT_ACTION_LAYER_PUSHED,    obj.doLoadFunctions)
EVENT_MANAGER:RegisterForEvent("windex_CombatFunctions",  EVENT_PLAYER_COMBAT_STATE,    obj.doCombatFunctions)
EVENT_MANAGER:RegisterForEvent("windex_FocusFunctions",   EVENT_GAME_FOCUS_CHANGED,     obj.doFocusFunctions)
EVENT_MANAGER:RegisterForEvent("windex_PopFunctions",     EVENT_ACTION_LAYER_POPPED,    obj.doPopFunctions)
EVENT_MANAGER:RegisterForEvent("windex_PushFunctions",    EVENT_ACTION_LAYER_PUSHED,    obj.doPushFunctions)
EVENT_MANAGER:RegisterForEvent("windex_ReticleFunctions", EVENT_RETICLE_TARGET_CHANGED, obj.doReticleFunctions)