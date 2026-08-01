-- This addon was hacked up from SnapShot.

EsoGrinder = {}
EsoGrinder.name = "EsoGrinder"

EsoGrinder.Loots   = {}
EsoGrinder.delim = 1
EsoGrinder.ddebug = false
EsoGrinder.started = true

local Delimiters = {{label="Tab",value="\t"},{label="Semicolon",value=";"},{label="Slash",value="/"}}

-- ItemLink Hash Functions ---------------------------------------------------------------------------=

local function GetItemLinkFromHash(itemHash)
  return table.concat({"|H1:",string.gsub(itemHash,"!",":0"),"|h|h"})
end

local function GetItemLinkHash(itemLink)
  return string.gsub(string.sub(itemLink,5,-5),":0","!")
end

-- Item Pricing Functions ----------------------------------------------------------------------------=

local function GetPriceMM(itemLink)
  if MasterMerchant then
    local value = MasterMerchant.GetItemLinePrice(itemLink) or 0
    if value < 10 then return math.floor(value*100+0.5)/100 end
    if value < 100 then return math.floor(value*10+0.5)/10 end
    return math.floor(value+0.5)
  end
  return -1 -- if MM not loaded
end

local function GetPriceTTC(itemLink)
  if TamrielTradeCentre then
    local iTTC = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
    if iTTC then
      local value = (iTTC.SuggestedPrice or 0) * 1.25
      if value == 0 then value = ((iTTC.Min or 0)+(iTTC.Avg or 0))/2 end
      if value < 10 then return math.floor(value*100+0.5)/100 end
      if value < 100 then return math.floor(value*10+0.5)/10 end
      return math.floor(value+0.5)
    end
    return 0 -- if no TTC data record
  end
  return -1 -- if TTC not loaded
end

function EsoGrinder:Initialize()
    self.savedVariables = ZO_SavedVars:NewAccountWide("EsoGrinderSavedVariables",1,nil,{})
    self.loot_save      = self.savedVariables.loot_save     or 0
    self.loot_save = {}
    self.savedVariables.loot_save = {}

    EVENT_MANAGER:RegisterForEvent(self.name,EVENT_LOOT_RECEIVED,self.LootLog)
    EVENT_MANAGER:RegisterForEvent(self.name,EVENT_INVENTORY_SINGLE_SLOT_UPDATE,self.LootTake)

    zo_callLater(function() d("EGR: Started.") end, 1000)
end
 
function EsoGrinder.OnAddOnLoaded(event, addonName)
    if addonName == EsoGrinder.name then
    EsoGrinder:Initialize()
    EVENT_MANAGER:UnregisterForEvent(EsoGrinder.name,EVENT_ADD_ON_LOADED)
    end
end

function EsoGrinder.DebugPrint(print_string)
    if EsoGrinder.ddbug then
        d(print_string)
    end
end

function EsoGrinder.OnSlashCommandDebug(extra)
    if EsoGrinder.ddbug then
        d("EGR: Debug off.")
        EsoGrinder.ddbug = false
        return
    end

    d("EGR: Debug on.")
    EsoGrinder.ddbug = true
end

function EsoGrinder.OnSlashCommandStart(extra)
    if EsoGrinder.started then
        d("EGR: Already started.")
        return
    end

    EVENT_MANAGER:RegisterForEvent(EsoGrinder.name,EVENT_LOOT_RECEIVED,EsoGrinder.LootLog)
    EVENT_MANAGER:RegisterForEvent(EsoGrinder.name,EVENT_INVENTORY_SINGLE_SLOT_UPDATE,EsoGrinder.LootTake)
    EsoGrinder.started = true
    d("EGR: Started.")
end

function EsoGrinder.OnSlashCommandStop(extra)
    if not EsoGrinder.started then
        d("EGR: Not started.")
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EsoGrinder.name, EVENT_LOOT_RECEIVED)
    EVENT_MANAGER:UnregisterForEvent(EsoGrinder.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EsoGrinder.started = false
    d("EGR: Stopped.")
end

function EsoGrinder.OnSlashCommandApiVersion(extra)
    EsoGrinder.DebugPrint(string.format("EGR: ESO APIVersion = %s",GetAPIVersion()))
end

SLASH_COMMANDS["/egrdebug"] = EsoGrinder.OnSlashCommandDebug
SLASH_COMMANDS["/egrstart"] = EsoGrinder.OnSlashCommandStart
SLASH_COMMANDS["/egrstop"] = EsoGrinder.OnSlashCommandStop
SLASH_COMMANDS["/egrapiversion"] = EsoGrinder.OnSlashCommandApiVersion

function EsoGrinder.LootLog(ec,rv,nm,qt,sd,ty,sf,pk,ic,itemId,st) -- EVENT_LOOT_RECEIVED ---------------=
    --d('LootLog')
    if #EsoGrinder.Loots == 0 then return end
    if EsoGrinder.Loots[#EsoGrinder.Loots].itemId == itemId
    then EsoGrinder.Loots[#EsoGrinder.Loots].isLoot = true

    local iLink = GetItemLinkFromHash(EsoGrinder.Loots[#EsoGrinder.Loots].hash)
    local iStatus = "-"
    local s = ""
    local sz = 0
    local x, y = GetMapPlayerPosition("player")
    local player_location_name = GetPlayerLocationName()
    local player_active_subzone_name = GetPlayerActiveSubzoneName()
    local player_active_zone_name = GetPlayerActiveZoneName()
    local player_status = GetPlayerStatus()
    local player_name = GetUnitName("player")
    if IsItemLinkBound(iLink) then iStatus = "B" end
    if IsItemLinkStolen(iLink) then iStatus = "S" end

    local iLine = {
      EsoGrinder.Loots[#EsoGrinder.Loots].name,
      EsoGrinder.Loots[#EsoGrinder.Loots].quantity,
      GetItemLinkItemType(iLink),
      GetItemLinkQuality(iLink),
      iStatus,
      GetItemLinkValue(iLink,false),
      GetPriceMM(iLink),
      GetPriceTTC(iLink),
      os.date("%Y-%m-%d %H:%M:%S",GetTimeStamp()),
      player_name,
      x,
      y,
      player_location_name,
      player_active_zone_name,
      player_active_subzone_name,
      player_status
    }
    s = table.concat(iLine,Delimiters[EsoGrinder.delim].value)
    --d(s)
    table.insert(EsoGrinder.loot_save, s)
    sz = #EsoGrinder.loot_save
    --d(sz)
    el = EsoGrinder.loot_save[sz]
    --d(el)
    EsoGrinder.savedVariables.loot_save = EsoGrinder.loot_save
    --el = EsoGrinder.savedVariables.loot_save[sz]
    --d(el)
    EsoGrinder.DebugPrint(string.format("EGR: %s %s",sz, el))
  end
end

function EsoGrinder.LootTake(ec,bag,slot,isNew,sd,re,qty) -- EVENT_INVENTORY_SINGLE_SLOT_UPDATE --------=
  if isNew and qty > 0 then
    --d('LootTake')
    local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME,GetItemName(bag,slot))
    local itemHash = GetItemLinkHash(GetItemLink(bag,slot))
    table.insert(EsoGrinder.Loots,{
      ["hash"] = itemHash,
      ["isLoot"] = false,
      ["itemId"] = GetItemId(bag,slot),
      ["name"] = itemName,
      ["quantity"] = qty,
      ["when"] = os.date("%Y-%m-%d %H:%M:%S",GetTimeStamp())
    })
  end
end

EVENT_MANAGER:RegisterForEvent(EsoGrinder.name, EVENT_ADD_ON_LOADED, EsoGrinder.OnAddOnLoaded)
