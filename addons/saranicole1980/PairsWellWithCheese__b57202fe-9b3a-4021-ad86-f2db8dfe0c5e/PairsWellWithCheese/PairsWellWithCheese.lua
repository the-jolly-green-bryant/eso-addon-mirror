local IFTTT = PairsWellWithCheese
local EM = EVENT_MANAGER


function IFTTT:RefreshTriggers()
  for key, obj in pairs(self.Triggers.items) do
    obj:Refresh()
  end
  for key, obj in pairs(self.Outcomes.items) do
    obj:RefreshCategories()
  end
  self:BuildMenu()
  self:AddCallbacks()
end

function IFTTT:AddCallbacks()
  local callbackTable = {}
  for key, item in pairs(self.Links.savedVarsChar.links) do
    local trigger = item.trigger
    local partsObj = self.Split(trigger.data)
    local type = self.toCapitalized(partsObj[3])
    callbackTable[type] = callbackTable[type] or {}
    table.insert(callbackTable[type], item)
  end
  for k, obj in pairs(callbackTable) do
    self.Triggers.items[k]:callbacks(obj)
  end
  callbackTable = {}
  for key, item in pairs(self.Links.savedVarsAcc.links) do
    local trigger = item.trigger
    local partsObj = self.Split(trigger.data)
    local type = self.toCapitalized(partsObj[3])
    callbackTable[type] = callbackTable[type] or {}
    table.insert(callbackTable[type], item)
  end
  for k, obj in pairs(callbackTable) do
    self.Triggers.items[k]:callbacks(obj)
  end
end

function IFTTT:RemoveCallbacks()
  local callbackTable = {}
  for key, item in pairs(self.Links.savedVarsChar.links) do
    local trigger = item.trigger
    local partsObj = self.Split(trigger.data)
    local type = self.toCapitalized(partsObj[3])
    callbackTable[type] = callbackTable[type] or {}
    table.insert(callbackTable[type], item)
  end
  for k, obj in pairs(callbackTable) do
    self.Triggers.items[k]:removeCallbacks(obj)
  end
  callbackTable = {}
  for key, item in pairs(self.Links.savedVarsAcc.links) do
    local trigger = item.trigger
    local partsObj = self.Split(trigger.data)
    local type = self.toCapitalized(partsObj[3])
    callbackTable[type] = callbackTable[type] or {}
    table.insert(callbackTable[type], item)
  end
  for k, obj in pairs(callbackTable) do
    self.Triggers.items[k]:removeCallbacks(obj)
  end
end

local function OnPlayerActivated()
  EM:UnregisterForEvent(IFTTT.Name.."PlayerActivated", EVENT_PLAYER_ACTIVATED)
  IFTTT:RefreshTriggers()
end

local function OnAddOnLoaded(eventCode, addonName)
  if addonName ~= IFTTT.Name then return end
	EVENT_MANAGER:UnregisterForEvent(IFTTT.Name, EVENT_ADD_ON_LOADED)
	
	local ns = GetDisplayName()..GetWorldName()
	IFTTT.AV = ZO_SavedVars:NewAccountWide("PairsWellWithCheese_Vars", 1, ns, IFTTT.Default, ns)
  IFTTT.CV = ZO_SavedVars:NewCharacterIdSettings("PairsWellWithCheese_Vars", 1, ns, IFTTT.Default, ns)
  IFTTT.Triggers:Initialize(IFTTT)
  IFTTT.Outcomes:Initialize(IFTTT)
  IFTTT.Links:Initialize(IFTTT)
  EM:RegisterForEvent(IFTTT.Name.."PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EM:RegisterForEvent(IFTTT.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
