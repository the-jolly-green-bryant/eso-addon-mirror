---@local lib @classdef LibItemLinks
local lib = LibStub:NewLibrary("LibItemLinks", 1)

if not lib then
  return    -- already loaded and no upgrade necessary
end


local function array_key_exists(key, arr)
  return (arr[key] ~= nil)
end

local function array_keys(t)
  local keys = {}
  for k,_ in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end



lib.name = "LibItemLinks"
lib.ver = 1
lib.savedVars = "LibItemLinksVars"
lib.displayVersion = "1.0 r1"


lib.defaultVars = {
  Links = {
  }
}


local SavedVariables

local Links = {
}


local SupportedTypes = {
  [ITEMTYPE_BLACKSMITHING_MATERIAL] = true,
  [ITEMTYPE_BLACKSMITHING_BOOSTER] = true,
  [ITEMTYPE_CLOTHIER_MATERIAL] = true,
  [ITEMTYPE_CLOTHIER_BOOSTER] = true,
  [ITEMTYPE_WOODWORKING_MATERIAL] = true,
  [ITEMTYPE_WOODWORKING_BOOSTER] = true,
  [ITEMTYPE_ARMOR_TRAIT] = true,
  [ITEMTYPE_WEAPON_TRAIT] = true,
  [ITEMTYPE_STYLE_MATERIAL] = true,
  [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = true,
  [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = true,
}


local HouseBags = {
  BAG_HOUSE_BANK_EIGHT,
  BAG_HOUSE_BANK_FIVE,
  BAG_HOUSE_BANK_FOUR,
  BAG_HOUSE_BANK_NINE,
  BAG_HOUSE_BANK_ONE,
  BAG_HOUSE_BANK_SEVEN,
  BAG_HOUSE_BANK_SIX,
  BAG_HOUSE_BANK_TEN,
  BAG_HOUSE_BANK_THREE,
  BAG_HOUSE_BANK_TWO,
}


function lib.OnUpdateEvent()
  
  local BC = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK, BAG_VIRTUAL, BAG_BANK, BAG_SUBSCRIBER_BANK)
  
  for k, data in pairs(BC) do
    local b = data.bagId
    local s = data.slotIndex
    local t = data.itemType
    local n = data.name
    
    if (array_key_exists(t, SupportedTypes)) then
      if (not array_key_exists(t, Links)) then
        Links[t] = {}
      end
      Links[t][n] = GetItemLink(b, s, LINK_STYLE_BRACKETS) 
    end
  end
  
  
  if (IsOwnerOfCurrentHouse()) then
    lib.ScanHouseBags()
  end
end


function lib.ScanHouseBags()
  
  local BC = SHARED_INVENTORY:GenerateFullSlotData(nil, unpack(HouseBags))
  
  for k, data in pairs(BC) do
    local b = data.bagId
    local s = data.slotIndex
    local t = data.itemType
    local n = data.name
    
    if (array_key_exists(t, SupportedTypes)) then
      if (not array_key_exists(t, Links)) then
        Links[t] = {}
      end
      Links[t][n] = GetItemLink(b, s, LINK_STYLE_BRACKETS) 
    end
  end
end




--[[  ***********  Library API  ***********  ]]


function lib.GetItemLink(itemType, itemName)
  if (array_key_exists(itemType, Links)) then
    return Links[itemType][itemName]
  else
    return nil
  end
end


--[[  *********  End Library API  *********  ]]



-- debugging for me
if (GetUnitDisplayName("player") == "@tomtomhotep") then
  SLASH_COMMANDS['/hotep2'] = function ()
    d(array_keys(Links))
  end
  
  SLASH_COMMANDS['/hotep3'] = function (extra)
    d(Links[tonumber(extra)])
  end
  
  SLASH_COMMANDS['/hotep4'] = function ()
    d(Links)
  end
end





--  ***********  Init  ***********  


function lib:Init()
  SavedVariables = ZO_SavedVars:NewAccountWide(lib.savedVars, lib.ver, nil, lib.defaultVars)
  Links = SavedVariables.Links
  self.OnUpdateEvent()
  EVENT_MANAGER:RegisterForUpdate(self.name, 180000, self.OnUpdateEvent)
end





function lib.OnAddOnLoaded(event, addonName)
  if (addonName == lib.name) then
    EVENT_MANAGER:UnregisterForEvent(lib.name, EVENT_ADD_ON_LOADED)
    lib:Init()
  end
end


EVENT_MANAGER:RegisterForEvent(lib.name, EVENT_ADD_ON_LOADED, lib.OnAddOnLoaded)

