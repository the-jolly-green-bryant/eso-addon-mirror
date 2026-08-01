local DEG_ADDON = _G["DEG_CURRENT_ADDON"]
if _G[DEG_ADDON.PACKAGE_NAME].libs == nil then _G[DEG_ADDON.PACKAGE_NAME].libs = {} end

local deglib = {
  name = "setsort",
  version = 19,
  initialized = false,
  vars = {
    ascii = {

    }
  }
}

local ascii = {
  "!",  "\"",   "#",   "$",   "%",   "&", "'",   "(",   ")",   "*",   "+",   ",", "-",   ".",   "/",
  "0",   "1",   "2",   "3",   "4",   "5",   "6",   "7",   "8",   "9",   ":",   ";",   "<",   "=",   ">",   "?",
  "@",   "A",   "B",   "C",   "D",   "E",   "F",   "G",   "H",   "I",   "J",   "K",   "L",   "M",   "N",   "O",
  "P",   "Q",   "R",   "S",   "T",   "U",   "V",   "W",   "X",   "Y",   "Z",   "[",   "\\",   "]",   "^",   "_",
  "`",   "a",   "b",   "c",   "d",   "e",   "f",   "g",   "h",   "i",   "j",   "k",   "l",   "m",   "n",   "o",
  "p",   "q",   "r",   "s",   "t",   "u",   "v",   "w",   "x",   "y",   "z",   "{",   "|",   "}",   "~",    
}

for k,v in pairs(ascii) do
  deglib.vars.ascii[v] = true
end

function deglib:makeSetName(setName)
  local words = {}
  for word in string.gmatch(setName, '([^ ]+)') do
    table.insert(words, word)
  end
  local ret = ""
  if #words == 1 then
    local pos1 = string.sub(setName, 1, 1)
    local rest = string.sub(setName, 2)
    if not self.vars.ascii[pos1] then
      pos1 = string.sub(setName, 1, 2)
      rest = string.sub(setName, 3)
    end
    
    --Zwillings
    --123456789
    --112345678
    local pos5 = string.sub(rest, 4, 4)
    if not self.vars.ascii[pos5] then
      ret = pos1..string.sub(rest, 1, 5)
    else
      ret = pos1..string.sub(rest, 1, 4)
    end
  else
    for k,v in pairs(words) do
      local pos1 = string.sub(v, 1, 1)
      if not self.vars.ascii[pos1] then
        pos1 = string.sub(v, 1, 2)
      end
      ret = ret..pos1
    end
  end
  
  return ret
end

deglib.freeAreas = {}
deglib.inventoryToSortHeader = {
    [INVENTORY_BACKPACK] = ZO_PlayerInventorySortBy,
    [INVENTORY_BANK] = ZO_PlayerBankSortBy,
    [INVENTORY_GUILD_BANK] = ZO_GuildBankSortBy,
}

function deglib:updateSetSortHeader(inv)
  local parent = self.inventoryToSortHeader[inv]
  
  local thisEntry = nil
  
  local sortByNew = nil
  local sortByStatus = nil
  local sortByName = nil
  local sortByPrice = nil
  local sortByTraitInfo = nil
  
  local entriesNotExpected = {} 
  local numEntriesNotExpected = 0      
  
  for numchild = 1, parent:GetNumChildren() do
    local child = parent:GetChild(numchild)
    local name = child:GetName()
                
    if (string.sub(name, -9) == "SortByNew") then
      sortByNew = child                
    elseif (string.sub(name, -12) == "SortByStatus") then
      sortByStatus = child
    elseif (string.sub(name, -10) == "SortByName") then
      sortByName = child
    elseif (string.sub(name, -15) == "SortByTraitInfo") then
      sortByTraitInfo = child
    elseif (string.sub(name, -11) == "SortByPrice") then
      sortByPrice = child          
    elseif (string.sub(name, -11) == "SortByArrow") then    
  
    elseif (string.sub(name, -10) == "DegSetSort") then        
    --thisEntry = child
      --entriesNotExpected[name] = child
      --numEntriesNotExpected = numEntriesNotExpected + 1
    else
      --entriesNotExpected[name] = child
      --numEntriesNotExpected = numEntriesNotExpected + 1
    end
  end
  
--  if sortByPrice then
    --if GetAPIVersion() < 100021 then
      --sortByPrice:ClearAnchors()
      --sortByPrice:SetAnchor(CENTER, sortByName, CENTER)
      --sortByPrice:SetAnchor(RIGHT, parent, RIGHT, -10, -2)    
    --end
  --end
  
  --local lastChild = sortByName
  --if sortByName then
    --local child = sortByName:GetChild() 
    --child:ClearAnchors()
    --child:SetAnchor(LEFT, sortByName, LEFT) 
    --child:SetWidth(child:GetTextWidth())
    --sortByName:SetWidth(child:GetTextWidth() + 20)
  --end
  
  --for k,v in pairs(entriesNotExpected) do
    --local child = v:GetChild()
    --if child then
      --child:ClearAnchors()
      --child:SetAnchor(LEFT, v, LEFT)
      --if child.GetTextWidth then   
        --child:SetWidth(child:GetTextWidth())
        --v:SetWidth(child:GetTextWidth() + 20)
      --end
    --end 
    --v:ClearAnchors()
    --v:SetAnchor(LEFT, lastChild, RIGHT)
    --lastChild = v
  --end
end

function deglib:initialize()
    if self.initialized then return self end
  
    for k,inv in pairs({INVENTORY_BACKPACK, INVENTORY_BANK, INVENTORY_GUILD_BANK}) do
      local inventory = PLAYER_INVENTORY.inventories[inv]
      
      --hm
      if inventory.sortFn == nil then
        inventory.sortFn = function(entry1, entry2)
          return ZO_TableOrderingFunction(entry1.data, entry2.data, inventory.currentSortKey, ZO_Inventory_GetDefaultHeaderSortKeys(), inventory.currentSortOrder)      
        end
      end    
      
      ZO_PreHook(inventory, "sortFn", function(entry1, entry2)
        if inventory.currentSortKey == 'degSetSort' then        
          local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(GetItemLink(entry1.data.bagId, entry1.data.slotIndex))
          if hasSet then
            if not entry1.data.degsetsortname then
              entry1.data.degsetsortnameorig = entry1.data.name
              entry1.data.degsetsortname = self:makeSetName(setName).. ": "..entry1.data.name
              --entry1.data.degsetsortname = entry1.data.name
            end
            entry1.data.name = entry1.data.degsetsortname
            if inventory.currentSortOrder then
              entry1.data.degSetSort = "_"..setName.." "..entry1.data.name
            else
              entry1.data.degSetSort = "ZZZ_"..setName.." "..entry1.data.name
            end        
          else 
            entry1.data.degSetSort = entry1.data.name
          end
        
          local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(GetItemLink(entry2.data.bagId, entry2.data.slotIndex))
          entry2.data.degSetSort = setName.." "..entry2.data.name
          if hasSet then           
            if not entry2.data.degsetsortname then
              entry2.data.degsetsortnameorig = entry2.data.name
              entry2.data.degsetsortname = self:makeSetName(setName).. ": "..entry2.data.name
              --entry2.data.degsetsortname = entry2.data.name
            end
            entry2.data.name = entry2.data.degsetsortname
            if inventory.currentSortOrder then
              entry2.data.degSetSort = "_"..setName.." "..entry2.data.name
            else
              entry2.data.degSetSort = "ZZZ_"..setName.." "..entry2.data.name
            end        
          else
            entry2.data.degSetSort = entry2.data.name
          end
        else 
          if entry1.data.degsetsortnameorig then
            --hier stimmt 'manchmal' was nicht
            entry1.data.name = entry1.data.degsetsortnameorig
          end
          if entry2.data.degsetsortnameorig then
            --hier stimmt 'manchmal' was nicht
            entry2.data.name = entry2.data.degsetsortnameorig
          end
        end
      end)
                        
      local nameHeader = nil
      
      for i = 1, self.inventoryToSortHeader[inv]:GetNumChildren() do
        if not nameHeader then
          local child = self.inventoryToSortHeader[inv]:GetChild(i)
          if string.sub(child:GetName(), -4) == "Name" then
            for j = 1, child:GetNumChildren() do
              if not nameHeader then
                local child2 = child:GetChild(j)
                if string.sub(child2:GetName(), -8) == "NameName" then
                  nameHeader = child2
                end
              end
            end
          end          
        end
      end
                                              
      if nameHeader then      
        local sortHeader = CreateControlFromVirtual("$(parent)DegSetSort", self.inventoryToSortHeader[inv], "ZO_SortHeader")
        sortHeader:SetAnchor(CENTER, nameHeader, CENTER, 0, 0)
        --sortHeader:SetAnchor(LEFT, nameHeader, LEFT, nameHeader:GetTextWidth() + 10, 0)      
        sortHeader:SetDimensions(80, 20)
      
        ZO_SortHeader_Initialize(sortHeader, "Set", "degSetSort", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontHeader")
        
        inventory.sortHeaders:AddHeader(sortHeader)
        
        ZO_PreHook(self.inventoryToSortHeader[inv], "SetHidden", function(val)
          self:updateSetSortHeader(inv)
        end)
        
      end
    end
    
    local fnBefore = ZO_Inventory_GetDefaultHeaderSortKeys
    ZO_Inventory_GetDefaultHeaderSortKeys = function()
      local sortKeys = fnBefore()
      sortKeys.degSetSort = {}
      return sortKeys
    end
    
    self.initialized = true
    
    return self
end

degLibRegisterLib(deglib.name, deglib.version, deglib)