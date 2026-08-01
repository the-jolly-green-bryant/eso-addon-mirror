local DEG_ADDON = _G["DEG_CURRENT_ADDON"]

local function d(...)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d(...)
end

local function deglib(libSafe, libname, ...)
  if not _G[DEG_ADDON.PACKAGE_NAME].libs then return end
  if not _G[DEG_ADDON.PACKAGE_NAME].libs[libname] then return end
  return _G[DEG_ADDON.PACKAGE_NAME].libs[libname]:initialize(...)
end

local function ts(...)
  return tostring(...)
end

local function getIdFromLink(itemLink)
    local split = {SplitString(':', itemLink)}
    if split[3] then 
      return tonumber(split[3])    
    end
end

local function getItemLink(itemId)
  return "|H0:item:"..itemId..":1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
end 

local Addon = {}
Addon.initialized = false
Addon.debug = false
Addon.name = DEG_ADDON.ADDON_NAME
Addon.versionIntern = 1
Addon.versionString = '1.104'
Addon.saveVariablesName = DEG_ADDON.SAVED_VARS_NAME
Addon.savedVariablesAccount = nil
Addon.savedVariablesChars = nil
Addon.saveVariablesVersion = 1
Addon.vars = {
  researchAssistantLoaded = false,
  defaultsAccount = {dataV2={},airg=true, wantsKnowledge={}, hasKnowledge={}, knowables={stylesByBook={},resultsByRecipe={},recipesByResult={}},settings={icons=true,knowledge=true,knowledgeTooltip=true,traitsTooltip=true,itemstatus=true,sellOrnate=true,sellTraitless=true,decompAll=true,decompTraitless=true,decompOrnate=true,sellStolen=true,traitResearch=true,decompTraitsKnown=true,decompTraitsResearched=false},
    wantsTraitsDetail=nil
  },
  
  ["researchLineToEquiptTypeWeapons"] = 
  {  
      [WEAPONTYPE_AXE] =
      {
          [1] = WEAPONTYPE_AXE,--"Axt (einhändig)",
      },  
      [WEAPONTYPE_HAMMER] =  
      {
          [2] = WEAPONTYPE_HAMMER,--"Keule",
      },  
      [WEAPONTYPE_SWORD] = 
      {
          [3] = WEAPONTYPE_SWORD,--"Schwert (einhändig)",
      },  
      [WEAPONTYPE_TWO_HANDED_AXE] = 
      {
          [4] = WEAPONTYPE_TWO_HANDED_AXE,--"Axt (zweihändig)",
      },                    
      [WEAPONTYPE_TWO_HANDED_HAMMER] = 
      {
          [5] = WEAPONTYPE_TWO_HANDED_HAMMER,--"Keule (zweihändig)",
      },
      [WEAPONTYPE_TWO_HANDED_SWORD] = 
      {
          [6] = WEAPONTYPE_TWO_HANDED_SWORD,--"Schwert (zweihändig)",
      },
      [WEAPONTYPE_DAGGER] = 
      {
          [7] = WEAPONTYPE_DAGGER,--"Dolch",
      },                  
      [WEAPONTYPE_BOW] = 
      {
          [1] = WEAPONTYPE_BOW,--"Bogen",
      },
      [WEAPONTYPE_FIRE_STAFF] = 
      {
          [2] = WEAPONTYPE_FIRE_STAFF,--"Flammenstab",
      },
      [WEAPONTYPE_FROST_STAFF] = 
      {
          [3] = WEAPONTYPE_FROST_STAFF,--"Froststab",
      },
      [WEAPONTYPE_LIGHTNING_STAFF] = 
      {
          [4] = WEAPONTYPE_LIGHTNING_STAFF,--"Blitzstab",
      },
      [WEAPONTYPE_HEALING_STAFF] = 
      {
          [5] = WEAPONTYPE_HEALING_STAFF,--"Heilungsstab",
      },                        
      [WEAPONTYPE_SHIELD] = 
      {
          [6] = WEAPONTYPE_SHIELD,--"Schild",
      },      
  },    
  ["researchLineToEquiptTypeArmor"] = 
  {                    
      [ARMORTYPE_HEAVY] = 
      {
          [8] =  EQUIP_TYPE_CHEST,--"Metallkürass",
          [9] =  EQUIP_TYPE_FEET,--"Metallstiefel",
          [10] = EQUIP_TYPE_HAND,--"Metallarmschutz",
          [11] = EQUIP_TYPE_HEAD,--"Metallhelm",
          [12] = EQUIP_TYPE_LEGS,--"Metallbeinschutz",
          [13] = EQUIP_TYPE_SHOULDERS,--"Metallschulterschutz",
          [14] = EQUIP_TYPE_WAIST,-- "Metallgürtel",
      },
      [ARMORTYPE_LIGHT] = 
      {
          [1] = EQUIP_TYPE_CHEST,--"Stoffgewand",
          [2] = EQUIP_TYPE_FEET,--"Stoffstiefel",
          [3] = EQUIP_TYPE_HAND,--"Stoffarmstulpen",
          [4] = EQUIP_TYPE_HEAD,--"Stoffhaube",
          [5] = EQUIP_TYPE_LEGS,--"Stoffhose",
          [6] = EQUIP_TYPE_SHOULDERS,--"Stoffschulterpolster",
          [7] = EQUIP_TYPE_WAIST,--"Stoffgürtel",
      },      
      
      [ARMORTYPE_MEDIUM] = 
      {
          [8] = EQUIP_TYPE_CHEST,--"Lederwams",
          [9] = EQUIP_TYPE_FEET,--"Lederstiefel",
          [10] = EQUIP_TYPE_HAND,--"Lederarmlinge",
          [11] = EQUIP_TYPE_HEAD,--"Lederkappe",
          [12] = EQUIP_TYPE_LEGS,--"Lederschoner",
          [13] = EQUIP_TYPE_SHOULDERS,--"Lederschulterkappen",
          [14] = EQUIP_TYPE_WAIST,--"Ledergürtel",
      },      
  },     
  ["researchLineToEquiptTypeJewelry"] = 
  {                    
      [-99] = 
      {
          [1] =  EQUIP_TYPE_NECK,
          [2] =  EQUIP_TYPE_RING,
      },
  },   
}
Addon.Paint = _G[DEG_ADDON.ADDON_NAME.."Paint"]
Addon.Settings = _G[DEG_ADDON.ADDON_NAME.."Settings"]
Addon.Keybind = _G[DEG_ADDON.ADDON_NAME.."Keybind"]

Addon.vars.equiptTypeToResearchLineWeapons = {}
Addon.vars.equiptTypeToResearchLineArmor = {}

for type,tbl in pairs(Addon.vars.researchLineToEquiptTypeWeapons) do
  Addon.vars.equiptTypeToResearchLineWeapons[type] = {}
  for numLine,type2 in pairs(tbl) do
    --type = ARMORTYPE_MEDIUM
    --type2 = EQUIP_TYPE_SHOULDERS
    Addon.vars.equiptTypeToResearchLineWeapons[type][type2] = numLine
  end
end 

for type,tbl in pairs(Addon.vars.researchLineToEquiptTypeArmor) do
  Addon.vars.equiptTypeToResearchLineArmor[type] = {}
  for numLine,type2 in pairs(tbl) do
    --type = ARMORTYPE_MEDIUM
    --type2 = EQUIP_TYPE_SHOULDERS
    Addon.vars.equiptTypeToResearchLineArmor[type][type2] = numLine
  end
end

for type,tbl in pairs(Addon.vars.researchLineToEquiptTypeJewelry) do
  Addon.vars.researchLineToEquiptTypeJewelry[type] = {}
  for numLine,type2 in pairs(tbl) do
    --type = ARMORTYPE_MEDIUM
    --type2 = EQUIP_TYPE_SHOULDERS
    Addon.vars.researchLineToEquiptTypeJewelry[type][type2] = numLine
  end
end

function Addon:traitWanted(CRAFTING_TYPE, numEquipType, nTrait, charId)  
  local data = self.savedVariablesAccount.dataV2
  
  if not charId then
    if data[CRAFTING_TYPE] then
      for k,v in pairs(data[CRAFTING_TYPE]) do
        if v[numEquipType] then
          if v[numEquipType][nTrait] then          
            return true
          end
        end
      end
    end  
  else  
    if data[CRAFTING_TYPE] then
      if data[CRAFTING_TYPE][charId] then
        if data[CRAFTING_TYPE][charId][numEquipType] then
          if data[CRAFTING_TYPE][charId][numEquipType][nTrait] ~= nil then
            return data[CRAFTING_TYPE][charId][numEquipType][nTrait]
          else
            return false
          end
        end    
      end
    end
  end
  return false
end

function Addon:setTraitWanted(CRAFTING_TYPE, numEquipType, nTrait, charId, bNewValue)
  d("setTraitWanted> CRAFTING_TYPE="..ts(CRAFTING_TYPE)..",numEquipType="..ts(numEquipType)..",nTrait="..ts(nTrait).."charId="..ts(charId)..",bNewValue="..ts(bNewValue))  

  local data = self.savedVariablesAccount.dataV2
  
  if not charId then
    --@todo
    --all chars get the new value
    if data[CRAFTING_TYPE] then
      for charIdTemp,tblEquipTypes in pairs(data[CRAFTING_TYPE]) do
        if tblEquipTypes then
          for numEqiptTypeTemp, tblTraits in pairs(tblEquipTypes) do
            if numEqiptTypeTemp == numEquipType then
              tblTraits[nTrait] = bNewValue            
            end
          end
        end    
      end
    end    
  else
    if not data[CRAFTING_TYPE] then
      data[CRAFTING_TYPE] = {}
    end
    if not data[CRAFTING_TYPE][charId] then
      data[CRAFTING_TYPE][charId] = {}
    end
    if not data[CRAFTING_TYPE][charId][numEquipType] then
      data[CRAFTING_TYPE][charId][numEquipType] = {}
    end
    data[CRAFTING_TYPE][charId][numEquipType][nTrait] = bNewValue
  end
end

function Addon:traitNeeded(CRAFTING_TYPE, numLine, nTrait)
  for charId,tblChar in pairs(self.savedVariablesChars.chars) do
    if self:traitWanted(CRAFTING_TYPE, numLine, nTrait, charId) then
      if not self:hasTrait(CRAFTING_TYPE, numLine, nTrait, charId) then return true end
    end   
  end
  return false
end

function Addon:migrateSettingsToV2()
  --if true then return end

  local wantsCraftingLineV1 = function(CRAFTING_TYPE, numLine, charid)
    --wenn die tbl(s) nicht gesetzt sind, dann wird es als true interpretiert
    --wenn man einen neuen charakter anlegt, dann möchte dieser alle handwerke und alle traits
    --deaktiviert/aktiviert man in den settings dann ein handwerk für den char
    --dann setWantsKnowledge 
    
    local knowledgeType = "Blacksmithing"
    if CRAFTING_TYPE == CRAFTING_TYPE_CLOTHIER then
      knowledgeType = "Clothier"
    elseif CRAFTING_TYPE == CRAFTING_TYPE_WOODWORKING then
      knowledgeType = "Woodworking"
    elseif CRAFTING_TYPE == CRAFTING_TYPE_JEWELRYCRAFTING then
      knowledgeType = "Jewelry"
    end    
    
    if not self:wantsKnowledge(knowledgeType, charid) then return false end
    
    --der char möchte grundätzlich die art von traits --wird das bei einem neuen char auch so angelegt? => ja
    
    --wenn nichts genauers in wantsTrait gesetzt ist, dann möchte er die linie
    --in den settings in den details wird das anhand numLine true / false gesetzt
    
    --wenn man für einen char wieder z.B. blacksmithing aktiviert, könnte man die details by numline löschen / resetten
        
    local ret = false
    if ret == false then
      if self.savedVariablesChars.chars[charid]["wantsTrait"] == nil then ret = true end
    end
    if ret == false then
      if self.savedVariablesChars.chars[charid]["wantsTrait"][CRAFTING_TYPE] == nil then ret = true end
    end
    if ret == false then
      if self.savedVariablesChars.chars[charid]["wantsTrait"][CRAFTING_TYPE][numLine] == nil then ret = true end
    end
    if ret == false then
      ret = self.savedVariablesChars.chars[charid]["wantsTrait"][CRAFTING_TYPE][numLine]
    end
      
    return ret
  end

  local traitWantedV1 = function(CRAFTING_TYPE, numEquipType, nTrait, charidIn)
  --self.savedVariablesAccount.dataV2 = data
  --data[CRAFTING_TYPE_BLACKSMITHING] = {}
  --detailData[researchLine][tType] = bBoolWants
  --data[craftingType][charId] = detailData
  
    for charid,tblChar in pairs(self.savedVariablesChars.chars) do
      if (charidIn == nil or charid == charidIn) then
        if wantsCraftingLineV1(CRAFTING_TYPE, numEquipType, charid) then
          if self.savedVariablesAccount.wantsTraitsDetail == nil then return true end  
          if self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE] == nil then return true end
          if self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE][nTrait] == nil then return true end    
          return self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE][nTrait]
        end
      end
    end
    return false
  end
  
  

  local data = {}  
  data[CRAFTING_TYPE_BLACKSMITHING] = {}
  data[CRAFTING_TYPE_CLOTHIER] = {}
  data[CRAFTING_TYPE_WOODWORKING] = {}
  data[CRAFTING_TYPE_JEWELRYCRAFTING] = {}
  
    
  if (self.savedVariablesAccount.wantsKnowledge) then
    for knowledgeType,tblChars in pairs(self.savedVariablesAccount.wantsKnowledge) do
    
      if knowledgeType == "Blacksmithing" 
      or knowledgeType == "Clothier"
      or knowledgeType == "Woodworking"
      or knowledgeType == "Jewelry" then
      
        local craftingType = CRAFTING_TYPE_BLACKSMITHING
        if knowledgeType == "Clothier" then
          craftingType = CRAFTING_TYPE_CLOTHIER
        end
        if knowledgeType == "Woodworking" then
          craftingType = CRAFTING_TYPE_WOODWORKING              
        end
        if knowledgeType == "Jewelry" then
          craftingType = CRAFTING_TYPE_JEWELRYCRAFTING              
        end
            
        if tblChars then
          for charId, bBool in pairs(tblChars) do
            d("doing "..knowledgeType.." > for char: "..charId)
            if bBool then
              local detailData = {}
              
              for researchLine = 1 , 14 do
                detailData[researchLine] = {}
                
                for numTrait = 1, 9 do  
                  local tTypeW, tDescW, bKnown = GetSmithingResearchLineTraitInfo(craftingType,researchLine,numTrait)                                    
                  detailData[researchLine][tTypeW] = traitWantedV1(craftingType,researchLine,numTrait,charId)
                end
              end                            
              data[craftingType][charId] = detailData
            else
              local detailData = {}
              
              for researchLine = 1 , 14 do
                detailData[researchLine] = {}
                
                for numTrait = 1, 9 do  
                  local tTypeW, tDescW, bKnown = GetSmithingResearchLineTraitInfo(craftingType,researchLine,numTrait)                                    
                  detailData[researchLine][tTypeW] = false
                end
              end
              data[craftingType][charId] = detailData            
            end
          end
        end
      end
    end
  end
   
  self.savedVariablesAccount.dataV2 = data
  self.savedVariablesAccount.settingsV2 = true
end

function Addon:Initialize()
  if (self.initialized) then return end
 
  self.savedVariablesAccount = ZO_SavedVars:NewAccountWide(self.saveVariablesName, self.saveVariablesVersion, nil, self.vars.defaultsAccount)
    
  local AddOnManager = GetAddOnManager()
  for i = 1, AddOnManager:GetNumAddOns() do 
    local name, title, author, description, enabled, state, isOutOfDate = AddOnManager:GetAddOnInfo(i)
     if name == "ResearchAssistant" and enabled then 
      self.vars.researchAssistantLoaded = true
     end 
  end
      
  for itemId,v in pairs(self.savedVariablesAccount.knowables.stylesByBook) do
    _G[DEG_ADDON.ADDON_NAME.."Vars"].knowables.stylesByBook[itemId] = v
  end
  for itemId,v in pairs(self.savedVariablesAccount.knowables.resultsByRecipe) do
    _G[DEG_ADDON.ADDON_NAME.."Vars"].knowables.resultsByRecipe[itemId] = v
  end
  for itemId,v in pairs(self.savedVariablesAccount.knowables.recipesByResult) do
    _G[DEG_ADDON.ADDON_NAME.."Vars"].knowables.recipesByResult[itemId] = v
  end
  
  
  local function initWantsKnowledge(knowledgeType, charId)
    if self.savedVariablesAccount.wantsKnowledge[knowledgeType] == nil then
      self.savedVariablesAccount.wantsKnowledge[knowledgeType] = {}
    end
    if self.savedVariablesAccount.wantsKnowledge[knowledgeType][charId] == nil then
      self.savedVariablesAccount.wantsKnowledge[knowledgeType][charId] = false
    end
  end
  
  local fnCharNewOrExists = function(charId, char)    
    d("fnChar "..ts(charId).." "..ts(char))
    if self.savedVariablesAccount.hasKnowledge[charId] == nil then
      self.savedVariablesAccount.hasKnowledge[charId] = {}
    end
    if self.savedVariablesAccount.hasKnowledge[charId].items == nil then
      self.savedVariablesAccount.hasKnowledge[charId].items = {}
    end
    
    initWantsKnowledge("Blacksmithing", charId)
    initWantsKnowledge("Clothier", charId)    
    initWantsKnowledge("Woodworking", charId)
    initWantsKnowledge("Alchemy", charId)
    initWantsKnowledge("Enchanting", charId)
    initWantsKnowledge("Provisioning", charId)
    initWantsKnowledge("Styles", charId)  
    initWantsKnowledge("Jewelry", charId)
  end
    
  
  self.savedVariablesChars = LibChars:initialize(self.savedVariablesAccount, 
    fnCharNewOrExists, 
    fnCharNewOrExists,
    function(charId, char) --fnCharRemoved
      d("fnCharRemoved "..ts(charId).." "..ts(char))
      for knowledgeType,tableChars in pairs(self.savedVariablesAccount.wantsKnowledge) do
        self.savedVariablesAccount.wantsKnowledge[knowledgeType][charId] = nil
      end
      self.savedVariablesAccount.hasKnowledge[charId] = nil      
      --data[CRAFTING_TYPE][charId][numEquipType][nTrait]
      for craftingType,tblChars in pairs(self.savedVariablesAccount.dataV2) do
        tblChars[charId] = nil
      end
    end
  )
  
  if not self.savedVariablesAccount.settingsV2 then
    self:migrateSettingsToV2()
  end  
 
  local moreMotd = ""
  if self.debug then moreMotd =" ,"..ts(GetGameTimeMilliseconds()) end 
  LibMOTD:setMessage(self.savedVariablesAccount, "|c3f95ffDryzler's|r |cEFEBBEInventory|r: "..GetString(SI_DEG_INVENTORY_MOTD)..moreMotd, 1)  
  
  --d("CRAFTING_TYPE_JEWELRYCRAFTING=".. CRAFTING_TYPE_JEWELRYCRAFTING)
  
     
  self.Settings:initialize()    
  
  if not self.debug then  
    self:setupInventories()
  end
 
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) self:onEVENT_INVENTORY_SINGLE_SLOT_UPDATE(...) end)
  EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)  
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RECIPE_LEARNED, function(...) self:onEVENT_RECIPE_LEARNED(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STYLE_LEARNED, function(...) self:onEVENT_STYLE_LEARNED(...) end)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRAIT_LEARNED, function(...) self:onEVENT_TRAIT_LEARNED(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, function(...) self:onEVENT_SMITHING_TRAIT_RESEARCH_STARTED(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, function(...) self:onEVENT_SMITHING_TRAIT_RESEARCH_COMPLETED(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SMITHING_TRAIT_RESEARCH_CANCELED, function(...) self:onEVENT_SMITHING_TRAIT_RESEARCH_CANCELED(...) end)
   
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(...) self:onEVENT_PLAYER_ACTIVATED(...) end) 
     
  local deglibtt = deglib(self.libSafe, "tooltip")
  local tt = deglibtt:new(function(Tooltip, itemLink)
    self:showTooltip(Tooltip, itemLink)
  end)
                 
                 
  degLib("ad1")
                 
  self.initialized = true
end

--######  KEYBINBDS ###################################################

function Addon:pressKB1()
  d("Addon.pressKB1")
  self.Keybind:pressKB1()
end

function Addon:pressKB2()
  d("Addon.pressKB2")
  self.Keybind:pressKB2()
end

function Addon:pressKB3()
  d("Addon.pressKB3")
  self.Keybind:pressKB3()
end

--######  TRAIT RESEARCH ###################################################

function Addon:getNeededByCharsStringTrait(CRAFTING_TYPE, numLine, trait, activeCharId)
  local retFirst = ""
  local retAfter = ""
  
    
  for charid,tblChar in pairs(self.savedVariablesChars.chars) do
    if self:traitWanted(CRAFTING_TYPE,numLine,trait,charid) then
    
--    end
--    if self:wantsCraftingLine(CRAFTING_TYPE, numLine, charid) then
      --für welfine darf das hier nicht..
      --d("+ wantsTrait "..ts(charid).." CRAFTING_TYPE="..ts(CRAFTING_TYPE) .. " numLine="..ts(numLine))
      
      local hasTrait = self:hasTrait(CRAFTING_TYPE, numLine, trait, charid)
      
      if hasTrait or hasTrait == "analyzing" then
      
      else
        if activeCharId and charid == activeCharId then
          retFirst = tblChar.name
        else
          if retAfter ~= "" then retAfter = retAfter..", " end
          retAfter = tblChar.name
        end
      end      
    else
      --d("-not wantsTrait "..ts(charid).." CRAFTING_TYPE="..ts(CRAFTING_TYPE) .. " numLine="..ts(numLine))
    end    
  end  
  
  if retFirst == "" then return retAfter end
  if retAfter == "" then return retFirst end
  return retFirst..", "..retAfter
end

function Addon:getAnalyzingByCharsStringTrait(CRAFTING_TYPE, numLine, trait, activeCharId)
  local retFirst = ""
  local retAfter = ""
  
  for charid,tblChar in pairs(self.savedVariablesChars.chars) do
    if self:traitWanted(CRAFTING_TYPE,numLine,trait,charid) then
--    if self:wantsCraftingLine(CRAFTING_TYPE, numLine, charid) then
      local hasTrait = self:hasTrait(CRAFTING_TYPE, numLine, trait, charid)
      if hasTrait == "analyzing" then
          if activeCharId and charid == activeCharId then          
            retFirst = tblChar.name
          else
            if retAfter ~= "" then retAfter = retAfter..", " end
            retAfter = retAfter..tblChar.name
          end      
      end    
    end
  end  
  
  if retFirst == "" then return retAfter end
  if retAfter == "" then return retFirst end
  return retFirst..", "..retAfter
end

function Addon:getLearnedByCharsStringTrait(CRAFTING_TYPE, numLine, trait, activeCharId)
  local retFirst = ""
  local retAfter = ""
  
  for charid,tblChar in pairs(self.savedVariablesChars.chars) do
    if self:traitWanted(CRAFTING_TYPE,numLine,trait,charid) then
--    if self:wantsCraftingLine(CRAFTING_TYPE, numLine, charid) then
      local hasTrait = self:hasTrait(CRAFTING_TYPE, numLine, trait, charid)
      if hasTrait == true then
        if activeCharId and charid == activeCharId then          
          retFirst = tblChar.name
        else
          if retAfter ~= "" then retAfter = retAfter..", " end
          retAfter = retAfter..tblChar.name
        end    
      end    
    end
  end  
  
  if retFirst == "" then return retAfter end
  if retAfter == "" then return retFirst end
  return retFirst..", "..retAfter
end

--function Addon:traitWantedV1(CRAFTING_TYPE, numEquipType, nTrait, charidIn)
--self.savedVariablesAccount.dataV2 = data
--data[CRAFTING_TYPE_BLACKSMITHING] = {}
--detailData[researchLine][tType] = bBoolWants
--data[craftingType][charId] = detailData

--  for charid,tblChar in pairs(self.savedVariablesChars.chars) do
--    if (charidIn == nil or charid == charidIn) then
--      if self:wantsCraftingLineV1(CRAFTING_TYPE, numEquipType, charid) then
--        if self.savedVariablesAccount.wantsTraitsDetail == nil then return true end  
--        if self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE] == nil then return true end
--        if self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE][nTrait] == nil then return true end    
--        return self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE][nTrait]
--      end
--    end
--  end
--  return false
--end

--function Addon:traitNeededV1(CRAFTING_TYPE, numLine, nTrait)
--  for charid,tblChar in pairs(self.savedVariablesChars.chars) do
--    if self:wantsCraftingLineV1(CRAFTING_TYPE, numLine, charid) then
--      --bekannt?
--      if not self:hasTrait(CRAFTING_TYPE, numLine, nTrait, charid) then return true end    
--    end
--  end
--  return false
--end

function Addon:hasTrait(CRAFTING_TYPE, numLine, nTrait, charid)
  if self.savedVariablesChars.chars[charid] == nil then return false end
  if self.savedVariablesChars.chars[charid]["hasTrait"] == nil then return false end
  if self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE] == nil then return false end
  if self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE][numLine] == nil then return false end
  if self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE][numLine][nTrait] == nil then return false end
  return self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE][numLine][nTrait]
end

--z.b. Schwere Rüstung -> Gürtel
--function Addon:wantsCraftingLineV1(CRAFTING_TYPE, numLine, charid)
  --wenn die tbl(s) nicht gesetzt sind, dann wird es als true interpretiert
  --wenn man einen neuen charakter anlegt, dann möchte dieser alle handwerke und alle traits
  --deaktiviert/aktiviert man in den settings dann ein handwerk für den char
  --dann setWantsKnowledge 
  
--  local knowledgeType = "Blacksmithing"
--  if CRAFTING_TYPE == CRAFTING_TYPE_CLOTHIER then
--    knowledgeType = "Clothier"
--  elseif CRAFTING_TYPE == CRAFTING_TYPE_WOODWORKING then
--    knowledgeType = "Woodworking"
--  elseif CRAFTING_TYPE == CRAFTING_TYPE_JEWELRYCRAFTING then
--    knowledgeType = "Jewelry"
--  end    
  
--  if not self:wantsKnowledge(knowledgeType, charid) then return false end
  
  --der char möchte grundätzlich die art von traits --wird das bei einem neuen char auch so angelegt? => ja
  
  --wenn nichts genauers in wantsTrait gesetzt ist, dann möchte er die linie
  --in den settings in den details wird das anhand numLine true / false gesetzt
  
  --wenn man für einen char wieder z.B. blacksmithing aktiviert, könnte man die details by numline löschen / resetten
      
--  local ret = false
--  if ret == false then
--    if self.savedVariablesChars.chars[charid]["wantsTrait"] == nil then ret = true end
--  end
--  if ret == false then
--    if self.savedVariablesChars.chars[charid]["wantsTrait"][CRAFTING_TYPE] == nil then ret = true end
--  end
--  if ret == false then
--    if self.savedVariablesChars.chars[charid]["wantsTrait"][CRAFTING_TYPE][numLine] == nil then ret = true end
--  end
--  if ret == false then
--    ret = self.savedVariablesChars.chars[charid]["wantsTrait"][CRAFTING_TYPE][numLine]
--  end
    
--  return ret
--end

--function Addon:setWantsCraftingLine(CRAFTING_TYPE, numLine, newValue, charid) 
--  if not self.savedVariablesChars.chars[charid]["wantsTrait"] then 
--    self.savedVariablesChars.chars[charid]["wantsTrait"] = {}
--  end
--  if not self.savedVariablesChars.chars[charid]["wantsTrait"][CRAFTING_TYPE] then 
--    self.savedVariablesChars.chars[charid]["wantsTrait"][CRAFTING_TYPE] = {}
--  end
--  self.savedVariablesChars.chars[charid]["wantsTrait"][CRAFTING_TYPE][numLine] = newValue
--end


--
--function Addon:wantsTraitDetail(CRAFTING_TYPE, nTrait)
--  if self.savedVariablesAccount.wantsTraitsDetail == nil then return true end  
--  if self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE] == nil then return true end
--  if self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE][nTrait] == nil then return true end
--
--  return self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE][nTrait]
--end

--function Addon:setWantsTraitDetail(CRAFTING_TYPE, nTrait, bBool)
--  if self.savedVariablesAccount.wantsTraitsDetail == nil then 
--    self.savedVariablesAccount.wantsTraitsDetail = {}
--  end  
--  if self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE] == nil then
--    self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE] = {}
--  end
--  if self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE][nTrait] == nil then 
--    self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE][nTrait] = true
--  end

--  self.savedVariablesAccount.wantsTraitsDetail[CRAFTING_TYPE][nTrait] = bBool
--end

--######  TOLLTIP ###################################################
function Addon:showTooltip(Tooltip, itemLink)
    if not self.savedVariablesAccount.settings.traitsTooltip and not self.savedVariablesAccount.settings.knowledgeTooltip then return end
    
    --item mit trait oder learnable?
    
    --if not self.savedVariablesAccount.settings.knowledge then return end
    local ret = ""
    local itemId = getIdFromLink(itemLink)
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB() 
    
    if itemType == ITEMTYPE_RECIPE then
      if self.savedVariablesAccount.settings.knowledgeTooltip then
        local knowledgeType = "Provisioning"      
        if specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING then
          knowledgeType = "Alchemy"        
        elseif specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING then
          knowledgeType = "Blacksmithing"
        elseif specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING then
          knowledgeType = "Clothier"
        elseif specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING then
          knowledgeType = "Enchanting"
        elseif specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING then
          knowledgeType = "Woodworking"
        end
      
      
        if self:wantsKnowledge(knowledgeType) and not self:hasItemKnowledge(knowledgeType, itemId) then
          ZO_Tooltip_AddDivider(Tooltip)
          local text = GetString(SI_DEG_NEED_BY)..": "..self:getNeededByCharsString(knowledgeType, itemId, GetCurrentCharacterId())
          Tooltip:AddLine(text, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false) 
        elseif self:othersWantAndNeedItemKnowledge(knowledgeType, itemId) then
          ZO_Tooltip_AddDivider(Tooltip)        
          local text = GetString(SI_DEG_NEED_BY)..": "..self:getNeededByCharsString(knowledgeType, itemId)
          Tooltip:AddLine(text, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)        
        else
          ZO_Tooltip_AddDivider(Tooltip)
          local text = GetString(SI_DEG_NEED_NOT).."."
          Tooltip:AddLine(text, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)                
        end      
      end
    elseif itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
      if self.savedVariablesAccount.settings.knowledgeTooltip then
        local knowledgeType = "Styles"                  
        if self:wantsKnowledge(knowledgeType) and not self:hasItemKnowledge(knowledgeType, itemId) then
          ZO_Tooltip_AddDivider(Tooltip)
          local text = GetString(SI_DEG_NEED_BY)..": "..self:getNeededByCharsString(knowledgeType, itemId, GetCurrentCharacterId())
          Tooltip:AddLine(text, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)        
        elseif self:othersWantAndNeedItemKnowledge(knowledgeType, itemId) then
          ZO_Tooltip_AddDivider(Tooltip)
          local text = GetString(SI_DEG_NEED_BY)..": "..Addon:getNeededByCharsString(knowledgeType, itemId)
          Tooltip:AddLine(text, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)
        else
          ZO_Tooltip_AddDivider(Tooltip)
          local text = GetString(SI_DEG_NEED_NOT).."."
          Tooltip:AddLine(text, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)
        end
      end
    elseif itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
      if self.savedVariablesAccount.settings.traitsTooltip then
        local trait = GetItemLinkTraitInfo(itemLink)
        if trait ~= ITEM_TRAIT_TYPE_NONE and trait ~= ITEM_TRAIT_TYPE_DEPRECATED 
          and trait ~= ITEM_TRAIT_TYPE_ARMOR_INTRICATE
          and trait ~= ITEM_TRAIT_TYPE_WEAPON_INTRICATE
          and trait ~= ITEM_TRAIT_TYPE_ARMOR_ORNATE
          and trait ~= ITEM_TRAIT_TYPE_WEAPON_ORNATE
          and trait ~= ITEM_TRAIT_TYPE_JEWELRY_ORNATE
          and trait ~= ITEM_TRAIT_TYPE_JEWELRY_INTRICATE
          then
          local _, _, _, specializedItemTypeEquip = GetItemLinkInfo(itemLink)
          --if specializedItemTypeEquip ~= EQUIP_TYPE_NECK and specializedItemTypeEquip ~= EQUIP_TYPE_RING then
          
            local isJewelry = false
            local specializedItemTypeArmor, specializedItemTypeWeapon = GetItemLinkArmorType(itemLink), GetItemLinkWeaponType(itemLink)
            local specializedItemType = specializedItemTypeArmor
            if specializedItemType == 0 then
              if (specializedItemTypeWeapon == 0) then
                specializedItemType = -1
              else
                specializedItemType = specializedItemTypeWeapon
              end
            end             
                               
            local CRAFTING_TYPE = CRAFTING_TYPE_BLACKSMITHING
            if specializedItemTypeArmor == ARMORTYPE_MEDIUM then
              CRAFTING_TYPE = CRAFTING_TYPE_CLOTHIER
            elseif specializedItemTypeArmor == ARMORTYPE_LIGHT then   
              CRAFTING_TYPE = CRAFTING_TYPE_CLOTHIER
            elseif specializedItemTypeWeapon == WEAPONTYPE_FIRE_STAFF or specializedItemTypeWeapon == WEAPONTYPE_FROST_STAFF or specializedItemTypeWeapon == WEAPONTYPE_LIGHTNING_STAFF then
              CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING    
            elseif specializedItemTypeWeapon == WEAPONTYPE_HEALING_STAFF then
              CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING
            elseif specializedItemTypeWeapon == WEAPONTYPE_BOW then    
              CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING
            elseif specializedItemTypeWeapon == WEAPONTYPE_SHIELD then
              CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING                        
            elseif specializedItemTypeArmor == ARMORTYPE_NONE and specializedItemTypeEquip == EQUIP_TYPE_NECK then    
              specializedItemType =-99
              isJewelry = true
              CRAFTING_TYPE = CRAFTING_TYPE_JEWELRYCRAFTING
            elseif specializedItemTypeArmor == ARMORTYPE_NONE and specializedItemTypeEquip == EQUIP_TYPE_RING then
              specializedItemType =-99
              isJewelry = true
              CRAFTING_TYPE = CRAFTING_TYPE_JEWELRYCRAFTING              
            end  
          
            if specializedItemType == specializedItemTypeWeapon then
              --waffenmodus
              
              if self.vars.equiptTypeToResearchLineWeapons[specializedItemType][specializedItemTypeWeapon] then
                local numLine = self.vars.equiptTypeToResearchLineWeapons[specializedItemType][specializedItemTypeWeapon]
                
                if self:traitWanted(CRAFTING_TYPE, numLine, trait) then
                    
                  local traitNeededText = self:getNeededByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                  local traitIsAnalyzingText = self:getAnalyzingByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                  local traitLearnedByText = self:getLearnedByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())

                  if traitNeededText ~= "" then
                    traitNeededText = GetString(SI_DEG_TRAIT_NEED_BY)..": "..traitNeededText
                  end
                  if traitIsAnalyzingText ~= "" then                                             
                    traitIsAnalyzingText = GetString(SI_DEG_TRAIT_ANALYZING_BY)..": "..traitIsAnalyzingText
                    if traitNeededText ~= "" then
                      traitIsAnalyzingText = "\n"..traitIsAnalyzingText
                    end                      
                  end
                  if traitLearnedByText ~= "" then
                    traitLearnedByText = GetString(SI_DEG_TRAIT_LEARNED_BY)..": "..traitLearnedByText
                    if traitNeededText ~= "" or traitIsAnalyzingText ~= "" then
                      traitLearnedByText = "\n"..traitLearnedByText
                    end                      
                  end    

                  ZO_Tooltip_AddDivider(Tooltip)
                  Tooltip:AddLine(traitNeededText..traitIsAnalyzingText..traitLearnedByText, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)                                        
                else
                  --keiner möchte den Trait, lasse keine farbe
                  local text = GetString(SI_DEG_TRAIT_NEED_NOT)
                  ZO_Tooltip_AddDivider(Tooltip)
                  Tooltip:AddLine(text, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)
                end
              end
            elseif specializedItemType == specializedItemTypeArmor then
              --rüstungsmodus
              --type = ARMORTYPE_MEDIUM
              --type2 = EQUIP_TYPE_SHOULDERS              
              if self.vars.equiptTypeToResearchLineArmor[specializedItemType][specializedItemTypeEquip] then
                local numLine = self.vars.equiptTypeToResearchLineArmor[specializedItemType][specializedItemTypeEquip]
                                
                --d("CRAFTING_TYPE="..ts(CRAFTING_TYPE).." numLine="..ts(numLine).." trait="..ts(trait))
                                
                if self:traitWanted(CRAFTING_TYPE, numLine, trait) then
                  local traitNeededText = self:getNeededByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                  local traitIsAnalyzingText = self:getAnalyzingByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                  local traitLearnedByText = self:getLearnedByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())

                  if traitNeededText ~= "" then
                    traitNeededText = GetString(SI_DEG_TRAIT_NEED_BY)..": "..traitNeededText
                  end
                  if traitIsAnalyzingText ~= "" then                                             
                    traitIsAnalyzingText = GetString(SI_DEG_TRAIT_ANALYZING_BY)..": "..traitIsAnalyzingText
                    if traitNeededText ~= "" then
                      traitIsAnalyzingText = "\n"..traitIsAnalyzingText
                    end                      
                  end
                  if traitLearnedByText ~= "" then
                    traitLearnedByText = GetString(SI_DEG_TRAIT_LEARNED_BY)..": "..traitLearnedByText
                    if traitNeededText ~= "" or traitIsAnalyzingText ~= "" then
                      traitLearnedByText = "\n"..traitLearnedByText
                    end                      
                  end
                            
                  ZO_Tooltip_AddDivider(Tooltip)
                  Tooltip:AddLine(traitNeededText..traitIsAnalyzingText..traitLearnedByText, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)
                else
                  --keiner möchte den Trait, lasse keine farbe
                  local text = GetString(SI_DEG_TRAIT_NEED_NOT)
                  ZO_Tooltip_AddDivider(Tooltip)
                  Tooltip:AddLine(text, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)
                end
              end
            elseif specializedItemType == -99 then
              --jewelry
                local numLine = self.vars.researchLineToEquiptTypeJewelry[specializedItemType][specializedItemTypeEquip]
                                
                --d("CRAFTING_TYPE="..ts(CRAFTING_TYPE).." numLine="..ts(numLine).." trait="..ts(trait))
                                
                if self:traitWanted(CRAFTING_TYPE, numLine, trait) then
                  local traitNeededText = self:getNeededByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                  local traitIsAnalyzingText = self:getAnalyzingByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())
                  local traitLearnedByText = self:getLearnedByCharsStringTrait(CRAFTING_TYPE, numLine, trait, GetCurrentCharacterId())

                  if traitNeededText ~= "" then
                    traitNeededText = GetString(SI_DEG_TRAIT_NEED_BY)..": "..traitNeededText
                  end
                  if traitIsAnalyzingText ~= "" then                                             
                    traitIsAnalyzingText = GetString(SI_DEG_TRAIT_ANALYZING_BY)..": "..traitIsAnalyzingText
                    if traitNeededText ~= "" then
                      traitIsAnalyzingText = "\n"..traitIsAnalyzingText
                    end                      
                  end
                  if traitLearnedByText ~= "" then
                    traitLearnedByText = GetString(SI_DEG_TRAIT_LEARNED_BY)..": "..traitLearnedByText
                    if traitNeededText ~= "" or traitIsAnalyzingText ~= "" then
                      traitLearnedByText = "\n"..traitLearnedByText
                    end                      
                  end
                            
                  ZO_Tooltip_AddDivider(Tooltip)
                  Tooltip:AddLine(traitNeededText..traitIsAnalyzingText..traitLearnedByText, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)
                else
                  --keiner möchte den Trait, lasse keine farbe
                  local text = GetString(SI_DEG_TRAIT_NEED_NOT)
                  ZO_Tooltip_AddDivider(Tooltip)
                  Tooltip:AddLine(text, "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, false)
                end              
            end                    
          --end        
        end      
      end
    end
end

function Addon:initKnowledgeHandlingForCurrentChar()
  local charId = GetCurrentCharacterId()
         
  --d("updateInventoryKnowledge start: "..GetCurrentCharacterId())
  self:updateInventoryKnowledge()
  --d("updateInventoryKnowledge finished: "..GetCurrentCharacterId())
  
  --if self.debug or not self.savedVariablesAccount.hasKnowledge[charId].scanComplete then    
    local async = LibAsync
    local task = async:Create("DEGInventoryInitCharKnowledge")
    
    task:Call(function()
      --d("updateStyleKnowledge start: "..GetCurrentCharacterId())            
      self:updateStyleKnowledge()
      self.savedVariablesAccount.hasKnowledge[charId].scanCompleteStyles = true
      self.savedVariablesAccount.hasKnowledge[charId].scanComplete = self.savedVariablesAccount.hasKnowledge[charId].scanCompleteRecipes
      --d("updateStyleKnowledge finished: "..GetCurrentCharacterId())
    end)
    
    task:Call(function()
      --d("updateRecipeKnowledge start: "..GetCurrentCharacterId())
      self:updateRecipeKnowledge()
      self.savedVariablesAccount.hasKnowledge[charId].scanCompleteRecipes = true
      self.savedVariablesAccount.hasKnowledge[charId].scanComplete = self.savedVariablesAccount.hasKnowledge[charId].scanCompleteStyles
      --d("updateRecipeKnowledge finished: "..GetCurrentCharacterId())
    end)
    
    task:Call(function()
      --d("updateRecipeKnowledge start: "..GetCurrentCharacterId())
      self:updateTraitKnowledge()
      --self.savedVariablesAccount.hasKnowledge[charId].scanCompleteTraits = true
      --self.savedVariablesAccount.hasKnowledge[charId].scanComplete = self.savedVariablesAccount.hasKnowledge[charId].scanCompleteStyles
      --d("updateRecipeKnowledge finished: "..GetCurrentCharacterId())
    end)    
   
  --end
end

function Addon:handleKnowledgeByItem(itemId, itemLink)
  local charId = GetCurrentCharacterId()
  
  if itemId then
    itemLink = getItemLink(itemId)
  else
    itemId = getIdFromLink(itemLink)
  end
  
  if IsItemLinkBookKnown(itemLink) then
    self:setKnowledgeByItem(charId, itemId)
  elseif IsItemLinkRecipeKnown(itemLink) then
    self:setKnowledgeByItem(charId, itemId)
  end
end

function Addon:updateInventoryKnowledge()
  for bagId,inventory in pairs(PLAYER_INVENTORY.inventories) do
    local bagSize = GetBagSize(bagId)
    --d("initKnowledge> bagSize("..bagId..")=" .. bagSize)
    for slotId=0,bagSize,1 do
      local itemLink = GetItemLink(bagId, slotId)
      self:handleKnowledgeByItem(nil, itemLink)
    end
  end
end

function Addon:updateRecipeKnowledge()
  local charId = GetCurrentCharacterId()
  for itemId,resultItemId in pairs(_G[DEG_ADDON.ADDON_NAME.."Vars"].knowables.resultsByRecipe) do    
    self:handleKnowledgeByItem(itemId)
  end
end

function Addon:updateTraitKnowledge()
  --@todo wenn ein trait gelernt, während man mit dem char eingeloggt ist, aber kein reload passiert sonderngleich ausloggen
  local charid = GetCurrentCharacterId()
  
  if not self.savedVariablesChars.chars[charid]["hasTrait"] then
    self.savedVariablesChars.chars[charid]["hasTrait"] = {}
  end
  
  self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_BLACKSMITHING] = {}
  for researchLineIndex = 1, GetNumSmithingResearchLines(CRAFTING_TYPE_BLACKSMITHING) do
    self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_BLACKSMITHING][researchLineIndex] = {}
    local _, _, numTraits = GetSmithingResearchLineInfo(CRAFTING_TYPE_BLACKSMITHING, researchLineIndex)
    
    for traitIndex = 1, numTraits do
      local traitType, _, known = GetSmithingResearchLineTraitInfo(CRAFTING_TYPE_BLACKSMITHING, researchLineIndex, traitIndex)      
      local number_nilable_duration, number_nilable_timeRemainingSecs = GetSmithingResearchLineTraitTimes(CRAFTING_TYPE_BLACKSMITHING, researchLineIndex, traitIndex)
      
      if number_nilable_timeRemainingSecs then
        self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_BLACKSMITHING][researchLineIndex][traitType] = 'analyzing'
      else        
        self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_BLACKSMITHING][researchLineIndex][traitType] = known
      end         
    end        
  end
  
  self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_CLOTHIER] = {}
  for researchLineIndex = 1, GetNumSmithingResearchLines(CRAFTING_TYPE_CLOTHIER) do
    self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_CLOTHIER][researchLineIndex] = {}
    local _, _, numTraits = GetSmithingResearchLineInfo(CRAFTING_TYPE_CLOTHIER, researchLineIndex)
    
    for traitIndex = 1, numTraits do
      local traitType, _, known = GetSmithingResearchLineTraitInfo(CRAFTING_TYPE_CLOTHIER, researchLineIndex, traitIndex)      
      local number_nilable_duration, number_nilable_timeRemainingSecs = GetSmithingResearchLineTraitTimes(CRAFTING_TYPE_CLOTHIER, researchLineIndex, traitIndex)
      
      if number_nilable_timeRemainingSecs then
        self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_CLOTHIER][researchLineIndex][traitType] = 'analyzing'
      else        
        self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_CLOTHIER][researchLineIndex][traitType] = known
      end    
    end        
  end   
  
  self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_WOODWORKING] = {}
  for researchLineIndex = 1, GetNumSmithingResearchLines(CRAFTING_TYPE_WOODWORKING) do
    self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_WOODWORKING][researchLineIndex] = {}
    local _, _, numTraits = GetSmithingResearchLineInfo(CRAFTING_TYPE_WOODWORKING, researchLineIndex)
    
    for traitIndex = 1, numTraits do
      local traitType, _, known = GetSmithingResearchLineTraitInfo(CRAFTING_TYPE_WOODWORKING, researchLineIndex, traitIndex)      
      local number_nilable_duration, number_nilable_timeRemainingSecs = GetSmithingResearchLineTraitTimes(CRAFTING_TYPE_WOODWORKING, researchLineIndex, traitIndex)
      
      if number_nilable_timeRemainingSecs then
        self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_WOODWORKING][researchLineIndex][traitType] = 'analyzing'
      else        
        self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_WOODWORKING][researchLineIndex][traitType] = known
      end        
    end        
  end     
  
  self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_JEWELRYCRAFTING] = {}
  for researchLineIndex = 1, GetNumSmithingResearchLines(CRAFTING_TYPE_JEWELRYCRAFTING) do
    self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_JEWELRYCRAFTING][researchLineIndex] = {}
    local _, _, numTraits = GetSmithingResearchLineInfo(CRAFTING_TYPE_JEWELRYCRAFTING, researchLineIndex)
    
    for traitIndex = 1, numTraits do
      local traitType, _, known = GetSmithingResearchLineTraitInfo(CRAFTING_TYPE_JEWELRYCRAFTING, researchLineIndex, traitIndex)      
      local number_nilable_duration, number_nilable_timeRemainingSecs = GetSmithingResearchLineTraitTimes(CRAFTING_TYPE_JEWELRYCRAFTING, researchLineIndex, traitIndex)
      
      if number_nilable_timeRemainingSecs then
        self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_JEWELRYCRAFTING][researchLineIndex][traitType] = 'analyzing'
      else        
        self.savedVariablesChars.chars[charid]["hasTrait"][CRAFTING_TYPE_JEWELRYCRAFTING][researchLineIndex][traitType] = known
      end        
    end        
  end  
end

function Addon:setKnowledgeByItem(charId, itemId)
  return self.libSafe:call(self._setKnowledgeByItem, charId, itemId)
end

function Addon:updateStyleKnowledge()
  local charId = GetCurrentCharacterId()
  for itemId,v in pairs(_G[DEG_ADDON.ADDON_NAME.."Vars"].knowables.stylesByBook) do
    self:handleKnowledgeByItem(itemId)
  end
end

function Addon:setKnowledgeByItem(charId, itemId)
  self.savedVariablesAccount.hasKnowledge[charId].items[itemId] = true
end


--#################################################################################################

function Addon:hasItemKnowledge(knowledgeType, itemId, charId)
  if not charId then charId = GetCurrentCharacterId() end
  if self.savedVariablesAccount.hasKnowledge[charId].items[itemId] then
    return true
  end
  return false
end

function Addon:setWantsKnowledge(knowledgeType, charId, newValue, bOnlyKnowledge)
  self.savedVariablesAccount.wantsKnowledge[knowledgeType][charId] = newValue
  
  --details alles auf true oder false
  if bOnlyKnowledge then return end
  
  local bDoSetup = false
  
  local CRAFTING_TYPE = CRAFTING_TYPE_BLACKSMITHING
  if knowledgeType == "Blacksmithing" then
    local CRAFTING_TYPE = CRAFTING_TYPE_BLACKSMITHING
    bDoSetup = true
  end
  if knowledgeType == "Clothier" then
    CRAFTING_TYPE = CRAFTING_TYPE_CLOTHIER
    bDoSetup = true
  end
  if knowledgeType == "Woodworking" then
    CRAFTING_TYPE = CRAFTING_TYPE_WOODWORKING              
    bDoSetup = true
  end
  if knowledgeType == "Jewelry" then
    CRAFTING_TYPE = CRAFTING_TYPE_JEWELRYCRAFTING              
    bDoSetup = true
  end
    
  if bDoSetup then
    --alles auf true
    --researchLines?
    local numLines = GetNumSmithingResearchLines(CRAFTING_TYPE)      
    for numEquipType= 1, numLines do
      local string_name, textureName_icon, number_numTraits, number_timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(CRAFTING_TYPE, numEquipType)
      for numTrait = 1, number_numTraits do
        local tType, tDesc, bKnown = GetSmithingResearchLineTraitInfo(CRAFTING_TYPE,numEquipType,numTrait) -- weapons
        self:setTraitWanted(CRAFTING_TYPE,numEquipType,tType,charId,newValue)      
      end
    end
  end  
end

function Addon:wantsKnowledge(knowledgeType, charId)
  if not charId then charId = GetCurrentCharacterId() end
  if self.savedVariablesAccount.wantsKnowledge[knowledgeType][charId] ~= nil then
    return self.savedVariablesAccount.wantsKnowledge[knowledgeType][charId]
  end
  return true --default: wants knowledge
end

function Addon:othersWantAndNeedItemKnowledge(knowledgeType, itemId, charId)  
  if not charId then charId = GetCurrentCharacterId() end
  for tempCharId,tempWantsKnowledge in pairs(self.savedVariablesAccount.wantsKnowledge[knowledgeType]) do
    if tempCharId ~= charId then
      if tempWantsKnowledge then
        if self:hasItemKnowledge(knowledgeType, itemId, tempCharId) == false then
          return true
        end
      end
    end
  end  
  return false
end

function Addon:getNeededByCharsString(knowledgeType, itemId, activeCharId)
  local retFirst = ""
  local retAfter = ""
  for tempCharId,tempWantsKnowledge in pairs(self.savedVariablesAccount.wantsKnowledge[knowledgeType]) do
    if tempWantsKnowledge then
      if self:hasItemKnowledge(knowledgeType, itemId, tempCharId) == false then
        if activeCharId and tempCharId == activeCharId then          
          retFirst = self.savedVariablesChars.chars[tempCharId].name
        else
          if retAfter ~= "" then retAfter = retAfter..", " end
          retAfter = retAfter..self.savedVariablesChars.chars[tempCharId].name         
        end
      end
    end
  end
  
  if retFirst == "" then return retAfter end
  if retAfter == "" then return retFirst end
  return retFirst..", "..retAfter
end


--#################################################################################################

function Addon:checkIsGrid()
  if InventoryGridView then
    if InventoryGridView.settings then
      if InventoryGridView.settings.IsGrid then
        if InventoryGridView.currentIGVId then
          return InventoryGridView.settings.IsGrid(InventoryGridView.currentIGVId)    
        end
      end      
    end      
  end
  return false
end

function Addon:updateItemInInventory(inventoryType, parentControl, slot)        
  local try, isGrid = xpcall(function() return self:checkIsGrid() end, function(errobj) _G.d(self.name..">error: "..tostring(errobj)); return false end)

  if not try then
    --isGrid konnte nicht (zuverlässig) ermittelt
    isGrid = nil
  end

  local thisControl, thisControlIcon, thisControlResearch = self.Paint:setupItemControls(parentControl, slot, isGrid)
  if thisControl then
    thisControl:SetHidden(true)
  end
  
  if isGrid then    
    return
  else
    if thisControl then
      thisControl:SetHidden(false)
    end  
    if thisControl and thisControlIcon and thisControlResearch then
      self.Paint:paintItem(inventoryType, thisControl, thisControlIcon, thisControlResearch, slot, isGrid)
    end
  end
end

function Addon:setupInventories()
  --player inventories
  for bagId,inventory in pairs(PLAYER_INVENTORY.inventories) do
    if inventory.listView then
      if inventory.listView.dataTypes then
        if inventory.listView.dataTypes[1] then
          if inventory.listView.dataTypes[1].setupCallback then
            ZO_PreHook(inventory.listView.dataTypes[1], "setupCallback", function(control, slot)    
              if ( control.slotControlType and control.slotControlType == 'listSlot' and control.dataEntry.data.slotIndex ) then
                self:updateItemInInventory("player", control, slot)
              end
            end)
          end
        end
      end
    end
  end
  
  --deconstruction hook
  ZO_PreHook(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1], "setupCallback", function(control, slot)  
    if ( control.slotControlType and control.slotControlType == 'listSlot' and control.dataEntry.data.slotIndex ) then
      self:updateItemInInventory("player", control, slot)
    end
  end)  
    
  --rebuy
  ZO_PreHook(ZO_BuyBackList.dataTypes[1], "setupCallback", function(control, slot)    
    if (control.slotControlType and control.slotControlType == 'listSlot' and control.dataEntry.data.slotIndex ) then
      self:updateItemInInventory("buyBack", control, slot)
    end
  end)  
end


Addon.hasSetupSmithingResearch = false
function Addon:setupSmithingResearch()
  if (self.hasSetupSmithingResearch) then return end

  local oldFn = SMITHING.researchPanel.SetupTraitDisplay
  
  local theFn = function(theSelf, slotControl, researchLine, known, duration, traitIndex)
    oldFn(theSelf, slotControl, researchLine, known, duration, traitIndex)
    
    if self.savedVariablesAccount.settings.traitResearch then
    
      if known then
  
      elseif duration then
  
      elseif researchLine.itemTraitCounts and researchLine.itemTraitCounts[traitIndex] then
              
          local CRAFTING_TYPE = researchLine.craftingType
          local numEquipType = researchLine.researchLineIndex
          local nTrait, tDesc, bKnown = GetSmithingResearchLineTraitInfo(CRAFTING_TYPE,numEquipType,traitIndex)
      
          local charid = GetCurrentCharacterId()
          if (Addon:traitWanted(CRAFTING_TYPE, numEquipType, nTrait, charid)) then
            slotControl.statusLabel:SetColor(0.0*255/255,0.5*255/255,0.0*255/255,1*255/255)
          end
      else
  
      end
    else
    
    end
  end
  SMITHING.researchPanel.SetupTraitDisplay = theFn
  self.hasSetupSmithingResearch = true
end

--#################################################################################################

function Addon:onEVENT_TRAIT_LEARNED()
  d("onEVENT_TRAIT_LEARNED")  
  self:updateTraitKnowledge()
end

function Addon:onEVENT_SMITHING_TRAIT_RESEARCH_STARTED()
  d("onEVENT_SMITHING_TRAIT_RESEARCH_STARTED")
  self:updateTraitKnowledge()
end

function Addon:onEVENT_SMITHING_TRAIT_RESEARCH_COMPLETED()
  d("onEVENT_SMITHING_TRAIT_RESEARCH_COMPLETED")
  self:updateTraitKnowledge()
end

function Addon:onEVENT_SMITHING_TRAIT_RESEARCH_CANCELED()
  d("onEVENT_SMITHING_TRAIT_RESEARCH_CANCELED")
  self:updateTraitKnowledge()
end

function Addon:onEVENT_INVENTORY_SINGLE_SLOT_UPDATE(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
  --d("onEVENT_INVENTORY_SINGLE_SLOT_UPDATE")
  --d("onEVENT_INVENTORY_SINGLE_SLOT_UPDATE "..ts(bagId).." "..ts(slotId).." "..ts(isNewItem).." "..ts(itemSoundCategory).." "..ts(inventoryUpdateReason).." "..ts(stackCountChange))
  
  --KEYBIND_STRIP:UpdateKeybindButtonGroup(self.vars.storeButtonGroup)
  
  local itemLink = GetItemLink(bagId, slotId)
  if not itemLink or itemLink == "" then return end
  local itemId = getIdFromLink(itemLink)
  if not itemId then return end
  local itemType, specializedItemType = GetItemLinkItemType(itemLink)
  
  if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
    if not _G[DEG_ADDON.ADDON_NAME.."Vars"].knowables.stylesByBook[itemId] then
      self.savedVariablesAccount.knowables.stylesByBook[itemId] = true
    end  
  elseif itemType == ITEMTYPE_RECIPE then
    if not _G[DEG_ADDON.ADDON_NAME.."Vars"].knowables.resultsByRecipe[itemId] then
            
      local resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
      local itemIdResult = getIdFromLink(resultItemLink)

      self.savedVariablesAccount.knowables.resultsByRecipe[itemId] = itemIdResult
      if itemIdResult and itemIdResult ~= true then
        self.savedVariablesAccount.knowables.recipesByResult[itemIdResult] = itemId
      end
    end
  end  
end

function Addon:onEVENT_RECIPE_LEARNED(eventCode, recipeListIndex, recipeIndex)
  d("onEVENT_RECIPE_LEARNED: "..tostring(recipeListIndex).."/"..tostring(recipeIndex))
  self:updateRecipeKnowledge()
end

function Addon:onEVENT_STYLE_LEARNED(eventCode, styleIndex, chapterIndex, isDefaultRacialStyle)  
  d("onEVENT_STYLE_LEARNED: "..tostring(styleIndex).."/"..tostring(chapterIndex).."/"..tostring(isDefaultRacialStyle))
  self:updateStyleKnowledge()
end

Addon.fnToggleAIRG = nil
Addon.fnToggleAIRGSetup = false

function Addon:toggleAIRG()
  d("Addon:toggleAIRG") 
  
  if (Addon.fnToggleAIRGSetup == false) then  
  
    local maxColumns = math.max(GetNumSmithingResearchLines(CRAFTING_TYPE_BLACKSMITHING),
    GetNumSmithingResearchLines(CRAFTING_TYPE_CLOTHIER),
    GetNumSmithingResearchLines(CRAFTING_TYPE_WOODWORKING),
    GetNumSmithingResearchLines(CRAFTING_TYPE_JEWELRYCRAFTING))
                             
    for numEquipType = 1, maxColumns do
      local elementId = "AIResearchGridColumnFooterLabel" .. numEquipType
      local element = _G[elementId]
      if (element ~= nil) then      
        ZO_PreHook(element, "SetText", function()
          if not Addon:getAIRG() then return end

          local elementId = "AIResearchGridDropdownCharacterDropdownSelectedItemText"
          local element = _G[elementId]
          local charName = element:GetText()
          local bIsRelative = false
          if charName ~= GetString(AIRG_OPTIONS_ALL) then
            --d("charName="..charName..";isRelative")
            bIsRelative = true
          else
            --d("charName="..charName..";isAll")
          end

          local charId = nil
          if (bIsRelative) then
            for charidTemp,tblChar in pairs(Addon.savedVariablesChars.chars) do            
              if tblChar.name == charName then
                charId = charidTemp
              end
            end
          end

          local craftingType = CRAFTING_TYPE_BLACKSMITHING;
          if AIResearchGridWindowSubTitle:GetText() == GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CLOTHING) then
            craftingType = CRAFTING_TYPE_CLOTHIER
          end
          if AIResearchGridWindowSubTitle:GetText() == GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WOODWORKING) then
            craftingType = CRAFTING_TYPE_WOODWORKING
          end  
          if AIResearchGridWindowSubTitle:GetText() == GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRYCRAFTING) then
            craftingType = CRAFTING_TYPE_JEWELRYCRAFTING
          end        
                    
          for numTrait = 1, 18 do
            local elementId = "AIResearchGridButton".. tostring(numEquipType) .. "x" .. tostring(numTrait)
            local element = _G[elementId]
  
            local tType, tDesc, bKnown = GetSmithingResearchLineTraitInfo(craftingType,numEquipType,numTrait)
            if (numTrait > 9) then
              tType, tDesc, bKnown = GetSmithingResearchLineTraitInfo(craftingType,numEquipType,numTrait-9)
            end
           
            if element ~= nil then
              if (element:GetTextureFileName() == "esoui/art/buttons/decline_up.dds") then                                         

                if Addon:traitWanted(craftingType, numEquipType, tType, charId) == false then
                  element:SetColor(0.0*255/255,0.5*255/255,0.0*255/255,1*255/255)
                end
              end
            end
          end
        end)            
      end
    end 
  end
  Addon.fnToggleAIRGSetup = true
  
  Addon.fnToggleAIRG()
end

function Addon:getAIRG()
  return self.savedVariablesAccount.airg
end

function Addon:setAIRG(bValue)
  self.savedVariablesAccount.airg = bValue
  
  if bValue then
    self:enableAIRG()
  else 
    self:disableAIRG()
  end
end

function Addon:enableAIRG()
    if AIResearchGrid then
      if not self.fnToggleAIRG then
        self.fnToggleAIRG = AIRG_ToggleMainWindow
      end      
      AIRG_ToggleMainWindow = self.toggleAIRG
    end
end

function Addon:disableAIRG() 
  if self.fnToggleAIRG then
    AIRG_ToggleMainWindow = self.fnToggleAIRG
  end
end

function Addon:onEVENT_PLAYER_ACTIVATED(intEventCode, bInitial)
  
  d("onEVENT_PLAYER_ACTIVATED: "..GetUnitName("player").." "..GetCurrentCharacterId())


  self.Keybind:initialize()

  if self.debug then  
    self:setupInventories()
  end
  
  self:initKnowledgeHandlingForCurrentChar()    
  
  self:setupSmithingResearch()
  
   
  if (self.savedVariablesAccount.airg) then
    self:enableAIRG()
  end
       
  deglib(self.libSafe, "setsort")
end

--#################################################################################################

function Addon:d(m)
  if self.debug then
    _G.d(self.name.."> "..tostring(m))
  end
end

_G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT] = Addon

EVENT_MANAGER:RegisterForEvent(DEG_ADDON.ADDON_NAME, EVENT_ADD_ON_LOADED, 
  function(event, AddonName)
    if AddonName == _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT].name then
      _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:Initialize()
      EVENT_MANAGER:UnregisterForEvent(_G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT].name, EVENT_ADD_ON_LOADED)
    end
  end
)