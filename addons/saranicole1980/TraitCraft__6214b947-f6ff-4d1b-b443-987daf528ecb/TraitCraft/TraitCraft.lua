--Name Space
TraitCraft = {}
local TC = TraitCraft
local LLC = LibLazyCrafting

--Basic Info
TC.Name = "TraitCraft"
TC.Author = "@Saranicole1980"

TC.Default = {
    allCrafterIds = {},
    allCrafters = {},
    mainCrafter = {},
    activelyResearchingCharacters = {},
    traitTable = {},
    savedCharacterList = {},
    settings = {
      crafterRequestee = "",
      requestOption = false,
      receiveOption = false,
      autoCraftOption = false,
      autoCraftNirnhoned = false,
      showKnown = false,
      showResearching = true,
      showUnknown = true,
      knownColor = {
        r = 0.0,
        g = 0.447,
        b = 0.698
      },
      unknownColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4
      },
      researchingColor = {
        r = 0.902,
        g = 0.624,
        b = 0.0
      },
    },
    libNamespace = {
      LDM = {},
      LTF = {}
    },
}

local currentlyLoggedInCharId = GetCurrentCharacterId()

TC.currentlyLoggedInCharId = currentlyLoggedInCharId
TC.currentlyLoggedInChar = TC.currentlyLoggedInChar or {}
TC.bitwiseChars = TC.bitwiseChars or {}
TC.traitIndexKey = nil
TC.hookLock = false
TC.rIndices = {}
TC.rObjects = {}
TC.mailInstance = nil
TC.formatter = nil
TC.lastRequested = {}
TC.scanResults = {}
TC.mailSubject = "TRAITCRAFT:RESEARCH:V2"
TC.notifyLock = false
TC.hookTooltipLock = false

local currentlyLoggedInChar = {}
local researchLineIndex = nil
local rootScene = "hud"

local BLACKSMITH 		= CRAFTING_TYPE_BLACKSMITHING
local CLOTHIER 			= CRAFTING_TYPE_CLOTHIER
local WOODWORK 			= CRAFTING_TYPE_WOODWORKING
local JEWELRY_CRAFTING 	= CRAFTING_TYPE_JEWELRYCRAFTING

local mailView = "mailGamepad"

TC.mailLinkKeybind =
{
    alignment = KEYBIND_STRIP_ALIGN_LEFT,

    {
        name = function()
            return TC.Lang.ADD_TO_QUEUE
        end,

        keybind = "UI_SHORTCUT_QUATERNARY",

        callback = function()
            local link = TC.currentItemLink
            if link and TC.autocraft and TC.autocraft.interactionTable then
                TC.makeAnnouncement("|cfd7a1a"..link..TC.Lang.ITEM_ADDED_TO_AUTOCRAFT.."|r", SOUNDS.SMITHING_OPENED)
                TC.autocraft.interactionTable:CraftSmithingItemFromLink(link)
            end
        end,

        visible = function()
            return TC.currentItemLink ~= nil and SCENE_MANAGER:IsShowing(mailView)
        end,

        enabled = function()
            return true
        end,
    }
}


local function setupNoop()
  return
end


function TC.HasJewelryCrafting()
    local skillLineData = SKILLS_DATA_MANAGER:GetCraftingSkillLineData(JEWELRY_CRAFTING)
    return skillLineData:IsAvailable()
end

function TC.GetCraftTypes()
  local craftTypes = { BLACKSMITH, CLOTHIER, WOODWORK, JEWELRY_CRAFTING }
  if not TC.HasJewelryCrafting() then
    craftTypes = { BLACKSMITH, CLOTHIER, WOODWORK }
  end
  return craftTypes
end

local CRAFT_TOKEN = {
  [CRAFTING_TYPE_BLACKSMITHING]       = "BS",
  [CRAFTING_TYPE_CLOTHIER]            = "CL",
  [CRAFTING_TYPE_WOODWORKING]         = "WW",
  [CRAFTING_TYPE_JEWELRYCRAFTING]     = "JW"
}

TC.craftingTypeIndex = 1
TC.researchLineIndex = 1
TC.traitIndex = 1

local SMITHING = ZO_SmithingResearch

if IsInGamepadPreferredMode() then
  SMITHING = ZO_GamepadSmithingResearch
end

function TC.GetCharacterBitwise()
  local characterList = {}
  for i = 1, GetNumCharacters() do
      local name, _, _, _, _, backupId, id = GetCharacterInfo(i)
      characterList[id or backupId] = 2^(i-1)
  end
  return characterList
end

function TC.GetCharIdByName(name)
  local charId
  for i = 1, GetNumCharacters() do
      local n, _, _, _, _, backupId, id = GetCharacterInfo(i)
      if ZO_CachedStrFormat(SI_UNIT_NAME, n) == name then
        return id
      end
  end
end

function TC.CompareCharChanges(savedList, currentList)
  local deltaList = { reordered = {}, deleted = {} }
  for charId, mask in pairs(currentList) do
    if savedList[charId] and savedList[charId] ~= mask then
      -- Order swap involving character that was researching - save the old mask for subtraction
      deltaList.reordered[charId] = savedList[charId]
    end
  end
  for charId, mask in pairs(savedList) do
    if not currentList[charId] then
      -- Character deleted involving character that was researching - save the old mask for subtraction
      deltaList.deleted[charId] = savedList[charId]
      if next(TC.AV.activelyResearchingCharacters) and TC.AV.activelyResearchingCharacters[charId] then
        TC.AV.activelyResearchingCharacters[charId] = nil
      end
    end
  end
  return deltaList
end

function TC.charBitMissing(trait, mask)
  -- Indicates that character bit needs to be set or is missing (as in the case of not researched)
  -- trait is the integer bitmask
  -- mask is the power-of-two flag for the character (e.g., 1, 2, 4, 8, ...)
  if trait and mask then
    return (trait % (mask*2)) < mask
  end
  return true
end

function TC.ResolveTraitDiffs()
  local start = GetFrameTimeMilliseconds()
  local key = nil
  local allMasks = nil
  while true do
    key, allMasks = next(TC.AV.traitTable, TC.traitIndexKey)
    if not key then
      EVENT_MANAGER:UnregisterForUpdate("TC_TraitMaskMigration")
      TC.AV.savedCharacterList = TC.bitwiseChars
      return
    end
    for charId, mask in pairs(TC.deltaList.deleted) do
      if not TC.charBitMissing(allMasks, mask) then
        -- fix deleted
        TC.AV.traitTable[key] = TC.AV.traitTable[key] - mask
      end
    end
    for charId, mask in pairs(TC.deltaList.reordered) do
      if not TC.charBitMissing(allMasks, mask) then
        -- fix reordered
        TC.AV.traitTable[key] = TC.AV.traitTable[key] - mask + TC.bitwiseChars[charId]
      end
    end
    TC.traitIndexKey = key
    if GetFrameTimeMilliseconds() - start > 5 then
        return
    end
  end
end

function TC:GetTraitFromKey(key)
  traitIndex = key % 10000 % 100
  researchLineIndex = (key % 10000 - traitIndex) / 100
  craftingSkillType = (key - traitIndex - (researchLineIndex * 100)) / 10000
--   local craftingName = GetCraftingSkillName(craftingSkillType)
--   local researchLineName = GetSmithingResearchLineInfo(craftingSkillType,researchLineIndex)
--   local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingSkillType,researchLineIndex, traitIndex)
--   local traitName = GetString("SI_ITEMTRAITTYPE", traitType)
	return craftingSkillType, researchLineIndex, traitIndex
end

function TC:GetTraitStringFromKey(key)
  traitIndex = key % 10000 % 100
  researchLineIndex = (key % 10000 - traitIndex) / 100
  craftingSkillType = (key - traitIndex - (researchLineIndex * 100)) / 10000
  local craftingName = GetCraftingSkillName(craftingSkillType)
  local researchLineName = GetSmithingResearchLineInfo(craftingSkillType,researchLineIndex)
  local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingSkillType,researchLineIndex, traitIndex)
  local traitName = GetString("SI_ITEMTRAITTYPE", traitType)
	return researchLineName..": "..traitName
end

function TC:GetItemString(craftingSkillType, researchLineIndex, traitIndex)
  local craftingName = GetCraftingSkillName(craftingSkillType)
  local researchLineName = GetSmithingResearchLineInfo(craftingSkillType,researchLineIndex)
  local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingSkillType,researchLineIndex, traitIndex)
  local traitName = GetString("SI_ITEMTRAITTYPE", traitType)
	return researchLineName..": "..traitName
end

local function formatRow(cols, widths)
    local out = {}
    for i, col in ipairs(cols) do
        local text = tostring(col)
        local width = widths[i] or #text
        -- pad or truncate
        if #text < width then
            text = text .. string.rep(" ", width - #text)
        else
            text = string.sub(text, 1, width)
        end
        table.insert(out, text)
    end
    return table.concat(out, " | ")
end

local function humanizeFutureTime(targetTime)
    local now = GetTimeStamp()
    local diff = targetTime - now
    if diff < 0 then diff = 0 end  -- clamp if passed

    if diff < 60 then
        return "in a few seconds"
    elseif diff < 3600 then
        local minutes = math.floor(diff / 60)
        return zo_strformat("in <<1>> minutes", minutes)
    elseif diff < 2 * 3600 then
        return "in about an hour"
    elseif diff < 86400 then
        local hours = math.floor(diff / 3600)
        return zo_strformat("in <<1>> hours", hours)
    elseif diff < 2 * 86400 then
        return "tomorrow"
    elseif diff < 7 * 86400 then
        local days = math.floor(diff / 86400)
        return zo_strformat("in <<1>> days", days)
    elseif diff < 30 * 86400 then
        local weeks = math.floor(diff / (7 * 86400))
        return zo_strformat("in <<1>> weeks", weeks)
    else
        local months = math.floor(diff / (30 * 86400))
        return zo_strformat("in <<1>> months", months)
    end
end

function TC:StatsReport()
  --Build Stats Report on Current Research
  local headers = { TC.Lang.STATS_NAME, TC.Lang.STATS_TYPE, TC.Lang.STATS_RESEARCHING, TC.Lang.STATS_FINISH }
  local widths
  local namePad
  local summaryStr = ""

  if IsInGamepadPreferredMode() then
    widths = {30, 30, 30, 25}
    d(formatRow(headers, widths))
    d(string.rep("-", 114))
    namePad = 60
  else
    widths = {5, 5, 5, 5}
    d(formatRow(headers, widths))
    d(string.rep("-", 20))
    namePad = 5
  end
  local summary = {}
  for id, char in pairs(TC.AV.activelyResearchingCharacters) do
    if not summary[id] then
      summary[id] = {}
    end
    if char.research then
      summaryStr = ""
      for key, done in pairs(char.research) do
        local craftingSkillType, researchLineIndex, traitIndex = TC:GetTraitFromKey(key)
        local keyStr = TC:GetTraitStringFromKey(key)
        if not summary[id][craftingSkillType] then
          summary[id][craftingSkillType] = {}
        end
        table.insert(summary[id][craftingSkillType], { keyStr = keyStr, done = done  })
      end
    else
      summary[id] = TC.Lang.LOG_INTO_CHAR
    end
  end
  for iDex, value in pairs(summary) do
    local sumStr = ""
    if type(summary[iDex]) == "string" then
      sumStr = summary[iDex]
    end
    d(formatRow({ TC.AV.activelyResearchingCharacters[iDex].name, sumStr, "", "" }, widths))
    if type(summary[iDex]) == "table" then
      for j, v in pairs(value) do
        d(formatRow({"", GetCraftingSkillName(j), "", ""}, widths))
        for _, vObj in ipairs(v) do
          d(formatRow({ "", "", vObj.keyStr, humanizeFutureTime(vObj.done) }, widths))
        end
      end
      d(string.rep("- ", namePad))
    end
  end
end

local function registerFormatter()
  TC.formatter:RegisterCore("v1")
  TC.formatter:RegisterFilter("recipient", function(ctx, text)
    return ctx.scope:Get("name") or TC.AV.settings.crafterRequestee
  end)
end

--When Loaded
local function OnAddOnLoaded(eventCode, addonName)
  if addonName ~= TC.Name then return end
	EVENT_MANAGER:UnregisterForEvent(TC.Name, EVENT_ADD_ON_LOADED)
  local ns = GetDisplayName()..GetWorldName()
  local oldVars = ZO_SavedVars:NewAccountWide("TraitCraft_Vars", 1, nil, TC.Default)
  local newVars = ZO_SavedVars:NewAccountWide("TraitCraft_Vars", 1, ns, TC.Default)

  if not newVars._migrated and next(oldVars) ~= nil then
      -- Deep copy old data into new
      ZO_DeepTableCopy(oldVars, newVars)

      newVars._migrated = true
  end

  TC.AV = newVars

  if LibTextFormat then
    TC.formatter = TC.formatter or LibTextFormat:New(TC.AV.libNamespace.LTF)
    registerFormatter()
  end

  if LibDynamicMail then
    TC.mailInstance = TC.mailInstance or LibDynamicMail:New(TC.AV.libNamespace.LDM, TC.formatter)
  end

  TC.bitwiseChars = TC.GetCharacterBitwise()

  if not next(TC.AV.savedCharacterList) then
    TC.AV.savedCharacterList = TC.bitwiseChars
  else
    TC.deltaList = TC.CompareCharChanges(TC.AV.savedCharacterList, TC.bitwiseChars)
    if next(TC.deltaList.reordered) or next(TC.deltaList.deleted) then
      EVENT_MANAGER:RegisterForUpdate("TC_TraitMaskMigration", 0, TC.ResolveTraitDiffs)
    end
  end
  SLASH_COMMANDS["/tcstats"] = function(args)
    TC:StatsReport()
  end
end

function TC.isValueInTable(table, element)
  for _, v in ipairs(table) do
    if element == v then
      return true
    end
  end
return false
end

function TC.getValueInTable(table, element)
  for _, v in pairs(table) do
    if element == v then
      return element
    end
  end
  return nil
end

local function getValueFromTable(t)
    return select(2, next(t))
end

function TC:FindTraitIndex(craftingSkillType, researchLineIndex, traitType)
	local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
	for traitIndex = 1, numTraits do
		local foundTraitType, description, _ = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
		if foundTraitType == traitType then
			return traitIndex
		end
	end
	return ITEM_TRAIT_TYPE_NONE
end

function TC:GetTraitKey(craftingSkillType, researchLineIndex, traitIndex)
	if craftingSkillType == nil or researchLineIndex == nil or traitIndex == nil then return end
	return craftingSkillType * 10000 + researchLineIndex * 100 + traitIndex
end

function TC:DoesCharacterKnowTrait(craftingSkillType, researchLineIndex, traitIndex)
	local _, _, knows = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	if knows then return true end
	return false
end

function TC:WillCharacterKnowTrait(craftingSkillType, researchLineIndex, traitIndex)
	local _, _, knows = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	if knows then return true end
	local willKnow = GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex)
	if willKnow ~= nil then return true end
	return false
end

function TC:IsResearchingTrait(craftingSkillType, researchLineIndex, traitIndex)
	local _, _, knows = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	if knows then return false end
	local willKnow = GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex)
	if willKnow ~= nil then return true end
	return false
end

function TC:GetResearchTimeForTrait(craftingSkillType, researchLineIndex, traitIndex)
	local duration, timeRemaining = GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex)
  local whenDoneTimeStamp = GetTimeStamp() + timeRemaining
  return whenDoneTimeStamp
end

function TC:SetTraitResearching(craftingType, researchLineIndex, traitIndex)
  local char = TC.AV.activelyResearchingCharacters[currentlyLoggedInCharId]
  if char then
    local key = TC:GetTraitKey(craftingType, researchLineIndex, traitIndex)
    local whenDone = TC:GetResearchTimeForTrait(craftingType, researchLineIndex, traitIndex)
    if not char.research then
      char.research = {}
    end
    char.research[key] = whenDone
  end
end

function TC:StopTraitResearchingWithKey(id, key)
  local char = TC.AV.activelyResearchingCharacters[id]
  if char and char.research and next(char.research) then
    char.research[key] = nil
  end
end

function TC:SetTraitKnownOnCharIdWithKey(id, key)
  local charBitId = TC.bitwiseChars[id]
  if key and not TC.AV.traitTable[key] then
    TC.AV.traitTable[key] = 0
  end
  if key and TC.charBitMissing(TC.AV.traitTable[key], charBitId) then
    TC.AV.traitTable[key] = TC.AV.traitTable[key] + charBitId
  end
  TC:StopTraitResearchingWithKey(id, key)
end

function TC:SetTraitKnown(craftingType, researchLineIndex, traitIndex)
  local charBitId = TC.bitwiseChars[currentlyLoggedInCharId]
  local key = TC:GetTraitKey(craftingType, researchLineIndex, traitIndex)
  if key and not TC.AV.traitTable[key] then
    TC.AV.traitTable[key] = 0
  end
  if key and TC.AV.traitTable[key] and charBitId then
    if TC.charBitMissing(TC.AV.traitTable[key], charBitId) then
      TC.AV.traitTable[key] = TC.AV.traitTable[key] + charBitId
    end
    TC:StopTraitResearchingWithKey(currentlyLoggedInCharId, key)
  end
end

function TC:SetTraitUnknown(craftingType, researchLineIndex, traitIndex)
  local charBitId = TC.bitwiseChars[currentlyLoggedInCharId]
  local key = TC:GetTraitKey(craftingType, researchLineIndex, traitIndex)
  if key then
    if TC.AV.traitTable[key] and TC.AV.traitTable[key] > 0 then
      if key and not TC.charBitMissing(TC.AV.traitTable[key], charBitId) then
        TC.AV.traitTable[key] = TC.AV.traitTable[key] - charBitId
      end
    end
    TC:StopTraitResearchingWithKey(currentlyLoggedInCharId, key)
  end
end

local function checkTrait(craftingType, researchLineIndex, traitIndex)
  if TC:IsResearchingTrait(craftingType, researchLineIndex, traitIndex) then
    TC:SetTraitResearching(craftingType, researchLineIndex, traitIndex)
  elseif TC:DoesCharacterKnowTrait(craftingType, researchLineIndex, traitIndex) then
    TC:SetTraitKnown(craftingType, researchLineIndex, traitIndex)
  else
    TC:SetTraitUnknown(craftingType, researchLineIndex, traitIndex)
  end
end

local function SetResearchHooks()
  EVENT_MANAGER:UnregisterForEvent("TC_ResearchComplete", EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED)
  EVENT_MANAGER:UnregisterForEvent("TC_ResearchCanceled", EVENT_SMITHING_TRAIT_RESEARCH_CANCELED)
  EVENT_MANAGER:UnregisterForEvent("TC_ResearchStarted", EVENT_SMITHING_TRAIT_RESEARCH_STARTED)
  EVENT_MANAGER:RegisterForEvent("TC_ResearchComplete", EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, TC.SetTraitKnown)
  EVENT_MANAGER:RegisterForEvent("TC_ResearchStarted", EVENT_SMITHING_TRAIT_RESEARCH_STARTED, TC.SetTraitResearching)
  EVENT_MANAGER:RegisterForEvent("TC_ResearchCanceled", EVENT_SMITHING_TRAIT_RESEARCH_CANCELED, TC.SetTraitUnknown)
end

function TC.ScanKnownTraits()
  local start = GetFrameTimeMilliseconds()
  local craftTypes = TC.GetCraftTypes()
  local traitLimit = 9
  while TC.craftingTypeIndex <= #craftTypes do
    checkTrait(craftTypes[TC.craftingTypeIndex], TC.researchLineIndex, TC.traitIndex)
    TC.traitIndex = TC.traitIndex + 1
    if TC.traitIndex > traitLimit then
      TC.traitIndex = 1
      TC.researchLineIndex = TC.researchLineIndex + 1
      if TC.researchLineIndex > GetNumSmithingResearchLines(craftTypes[TC.craftingTypeIndex]) then
          TC.researchLineIndex = 1
          TC.craftingTypeIndex = TC.craftingTypeIndex + 1
      end
    end
    if TC.craftingTypeIndex > #craftTypes then
      EVENT_MANAGER:UnregisterForUpdate("TC_ScanKnownTraits")
      SetResearchHooks()
      return
    end
    if GetFrameTimeMilliseconds() - start > 5 then
        return -- resume next frame with current indices
    end
  end
end

function TC:ScanForResearchExpired()
  if not IsUnitInCombat("player") and not IsUnitDead("player") then
    local now = GetTimeStamp()
    for id, char in pairs(TC.AV.activelyResearchingCharacters) do
      if char.research and next(char.research) then
        for key, done in pairs(char.research) do
          local timeRemaining = GetDiffBetweenTimeStamps(done, now)
          if timeRemaining <= 0 then
            TC:SetTraitKnownOnCharIdWithKey(id, key)
            local traitKey = TC:GetTraitStringFromKey(key)
            d(TraitCraft.Lang.RESEARCH_EXPIRED..char.name.." - "..traitKey)
          end
        end
      end
    end
  end
end

function TC:ScanMaxNumResearch()
  local craftTypes = self:GetCraftTypes()
  if not TC.AV.activelyResearchingCharacters[currentlyLoggedInCharId]["maxSimultResearch"] then
    TC.AV.activelyResearchingCharacters[currentlyLoggedInCharId]["maxSimultResearch"] = {}
  end
  for i = 1, #craftTypes do
    TC.AV.activelyResearchingCharacters[currentlyLoggedInCharId]["maxSimultResearch"][craftTypes[i]] = GetMaxSimultaneousSmithingResearch(craftTypes[i])
  end
  if not TC.AV.activelyResearchingCharacters[currentlyLoggedInCharId].research then
    TC.AV.activelyResearchingCharacters[currentlyLoggedInCharId].research = {}
  end
end

function TC.sortKeysByValue(tbl)
  local keys = {}
  for k in pairs(tbl) do
      table.insert(keys, k)
  end
  table.sort(keys, function(a, b)
      if tbl[a] == tbl[b] then
          return a < b  -- tiebreaker: smaller key first
      else
          return tbl[a] > tbl[b]
      end
  end)
  return keys
end

local function Slice(tbl, first, last)
  local sliced = {}
  for i = first or 1, last or #tbl do
    sliced[#sliced + 1] = tbl[i]
  end
  return sliced
end

-- accepted with gratitude from Dolgubon
local function getPatternFromResearchLine(station, researchLine)
    if station == CRAFTING_TYPE_CLOTHIER and researchLine > 1 then
        return researchLine + 1
    end
    if station == CRAFTING_TYPE_WOODWORKING then
        local map = {
            1,3,4,5,6,2
        }
        return map[researchLine]
    end
    return researchLine
end

function TC:ScanUnknownTraitsForCrafting(charId, craftingType, scanCallback)
  local nirnCraftTypes = { CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING }
  local tempResearchTable = {
    rCounter = {},
    rObjects = {}
  }
  local char = self.AV.activelyResearchingCharacters[charId]
  if char == nil or not char["maxSimultResearch"] then
    d(self.Lang.LOG_INTO_CHAR)
    return
  end
  local maxSimultResearch = char["maxSimultResearch"][craftingType]
  local serializeContain = {}
  local serializeRecord = {}
  local mask = self.bitwiseChars[charId]
  if not char then
    d(self.Lang.LOG_INTO_CHAR)
    return
  end
  local research = char.research or {}
  local researchLineLimit = GetNumSmithingResearchLines(craftingType)
  local traitLimit = 9
  if not self.AV.settings.autoCraftNirnhoned and self.isValueInTable(nirnCraftTypes, craftingType) then
    traitLimit = 8
  end
  local key
  local trait
  if not self.rIndices[charId] then
    self.rIndices[charId] = {}
  end
  if not self.rObjects[charId] then
    self.rObjects[charId] = {}
  end

  for r = 1, researchLineLimit do
    for t = 1, traitLimit do
      key = self:GetTraitKey(craftingType, r, t)
      trait = self.AV.traitTable[key] or 0
      if self.charBitMissing(trait, mask) and not research[key] then
        if not tempResearchTable.rCounter[r] then
          tempResearchTable.rCounter[r] = 0
        end
        tempResearchTable.rCounter[r] =  tempResearchTable.rCounter[r] + 1
        if not tempResearchTable.rObjects[r] then
          tempResearchTable.rObjects[r] = {}
        end
        table.insert(tempResearchTable.rObjects[r], t)
      end
    end
  end
  self.rIndices[charId][craftingType] = TC.sortKeysByValue(tempResearchTable.rCounter)
  self.rObjects[charId] = tempResearchTable.rObjects

  local researchIndices = Slice(self.rIndices[charId][craftingType], 1, maxSimultResearch)
  local serializeContain = {}
  local csvContain = {}
  for i = #researchIndices, 1, -1 do
    local researchIndex = researchIndices[i]
    local traitObjects = tempResearchTable.rObjects[researchIndex]
    local traitIndices = select(1, traitObjects)
    serializeRecord["researchIndex"] = researchIndex
    serializeRecord["traitIndex"] = traitIndices[1]
    serializeContain[CRAFT_TOKEN[craftingType]] = serializeContain[CRAFT_TOKEN[craftingType]] or {}
    table.insert(serializeContain[CRAFT_TOKEN[craftingType]], serializeRecord)
    if self.autocraft and self.autocraft.interactionTable then
      local pattern = getPatternFromResearchLine(craftingType, researchIndex)
      local trait = GetSmithingResearchLineTraitInfo(craftingType, researchIndex, traitIndices[1])
      if trait then
        trait = trait + 1
      end
      local itemLink = self.autocraft.interactionTable:getItemLinkFromParticulars(pattern, false, 1, LLC_FREE_STYLE_CHOICE, trait, craftingType, 0, 1)
      if itemLink and itemLink ~= "" then
        table.insert(csvContain, itemLink)
      end
    end
    serializeRecord = {}
  end
  scanCallback(serializeContain, csvContain)
end

function TC:ScanUnknownTraitsForRequesting()
  local charId = GetCurrentCharacterId()
  local craftTypes = self:GetCraftTypes()
  local itemDescriptions = "|r\r\n  "
  local sendObject = {}
  local csvObject = {}
  for i = 1, #craftTypes do
    local craftingType = craftTypes[i]
    self:ScanUnknownTraitsForCrafting(charId, craftingType, function(serializedObj, csvValues)
      table.insert(sendObject, serializedObj)
      table.insert(csvObject, csvValues)
    end)
  end
  return sendObject, csvObject
end

function TC.makeAnnouncement(text, sound)
  local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
			params:SetText(text)
			CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

function TC.showCompose(scene, newState, scanResults)
  local sceneName = scene:GetName()
  if sceneName == rootScene and newState == SCENE_SHOWING then
    SCENE_MANAGER:UnregisterCallback("SceneStateChanged", TC.showCompose)
    TC.mailInstance:ComposeMail(scanResults.senderDisplayName, TC.Lang.REQUESTED_ITEMS, "")
    if IsConsoleUI() then
      TC.makeAnnouncement(TC.Lang.MAIL_PROCESSED, SOUNDS.MAIL_WINDOW_OPEN)
      TC.makeAnnouncement(TC.Lang.CRAFT_REQUEST_TOOLTIP, SOUNDS.MAIL_WINDOW_OPEN)
    end
    TC.scanResults = {}
  end
end

local function notifyOnce(notification)
  if not TC.notifyLock then
    d(notification)
  end
  TC.notifyLock = true
end

local function Split(search, delim)
  local parts = {}
  local start = 1

  while true do
      local i, j = search:find(delim, start, true) -- true = plain match
      if not i then
          table.insert(parts, search:sub(start))
          break
      end

      table.insert(parts, search:sub(start, i - 1))
      start = j + 1
  end
  return parts
end

local function mailHookCallback()
  ZO_PostHook(ZO_GamepadLinks, "OnLinkShown", function(self, linkData)
    if linkData.link and linkData.linkType == "item" then
      TC.currentItemLink = linkData.link
      KEYBIND_STRIP:AddKeybindButtonGroup(TC.mailLinkKeybind)
    end
  end)
  ZO_PostHook(ZO_GamepadLinks, "OnLinkHidden", function(self, linkData)
      TC.currentItemLink = nil
      KEYBIND_STRIP:UpdateKeybindButtonGroup(TC.mailLinkKeybind)
  end)
end

function TC.hookTooltips()
  ZO_PostHook(MAIL_GAMEPAD:GetInbox(), "UpdateLinks", mailHookCallback)
end

local function importCraftableLinks(interactionTable, body)
  local addedRequests
  if interactionTable and type(interactionTable["importCraftableLinksFromString"]) == "function" then
    addedRequests = interactionTable:importCraftableLinksFromString(body)
  end
  if not addedRequests and body then
    addedRequests = {}
    for link in string.gmatch(body, "(|H%d:item:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+|h|h)") do
      table.insert(addedRequests, interactionTable:CraftSmithingItemFromLink(link))
    end
  end
  return addedRequests
end

function TC:processRequestMail()
  if IsInGamepadPreferredMode() or IsConsoleUI() then
    self.hookTooltips()
  end
  if TC.AV.settings.receiveOption then
    self.mailInstance:RegisterInboxEvents(self.Name.."FetchItems")
    self.mailInstance:RegisterInboxEvents(self.Name.."QueueItems")

    self.mailInstance:RegisterInboxCallback(self.Name.."FetchItems", function()
      self.mailInstance.mailIds = self.mailInstance:FetchMailIdsForSubject(self.mailSubject)
    end)
    self.mailInstance:RegisterInboxCallback(self.Name.."QueueItems", function(event, mailId)
      if not next(self.mailInstance.mailIds) then
        return
      end

      if self.isValueInTable(self.mailInstance.mailIds, mailId) then
        TC.scanResults = self.mailInstance:RetrieveMailData(mailId)
        if not TC.scanResults then
          return
        end
        local mailBody = self.mailInstance:RetrieveActiveMailBody()
        local delim = string.rep("-", 30)
        local bodysplit = Split(mailBody, delim)
        if not bodysplit then
          return
        end

        self.scanResults.body = bodysplit[2]

        if self.scanResults.body then
          if not TC.notifyLock and self.autocraft and self.autocraft.interactionTable then
            importCraftableLinks(self.autocraft.interactionTable, self.scanResults.body)
          end
          self.mailInstance:SafeDeleteMail(mailId, true)
          notifyOnce(TC.Lang.REQUESTOR_USERNAME..TC.scanResults.senderDisplayName)
        end
      end
      self.mailInstance:UnregisterInboxReadEvents("QueueItems")
    end, true)
  end
end

local function TC_Event_Player_Activated(event, isA)
	--Only fire once after login!
	EVENT_MANAGER:UnregisterForEvent("TC_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:UnregisterForEvent(TC.Name.."mailbox", EVENT_MAIL_READABLE)
	TC.currentlyLoggedInChar = {}
	TC.BuildMenu()
	if TC.AV.activelyResearchingCharacters[currentlyLoggedInCharId] then
    EVENT_MANAGER:RegisterForUpdate("TC_ScanKnownTraits", 0, TC.ScanKnownTraits)
    TC:ScanMaxNumResearch()
  end
  if LLC then
    if TC.AV.settings.autoCraftOption then
      local isCrafter = false
      if next(TC.AV.allCrafterIds) then
        if TC.isValueInTable(TC.AV.allCrafterIds, currentlyLoggedInCharId) then
          isCrafter = true
        end
      end
      TC.autocraft = TC_Autocraft:New(TC, isCrafter)
      if isCrafter then
        if LibDynamicMail then
          EVENT_MANAGER:RegisterForEvent(TC.Name.."mailbox", EVENT_MAIL_OPEN_MAILBOX , function(mailId) TC:processRequestMail(mailId) end )
        end
      elseif TC.autocraft then
        TC_Autocraft:Destroy()
      end
    end
  end
  local FIVE_MINUTES_MS = 5 * 60 * 1000  -- 5 min in ms
  EVENT_MANAGER:UnregisterForUpdate("TC_ScanForResearchExpired")
  zo_callLater(TC.ScanForResearchExpired, 90000)
  EVENT_MANAGER:RegisterForUpdate("TC_ScanForResearchExpired", FIVE_MINUTES_MS, TC.ScanForResearchExpired)
end

function TC.addResearchIcon(control, craftingType, researchLineIndex, traitIndex, firstOrientation, secondOrientation, sideFloat, controlName)
  local icon
  if control.altNeedIcon and next(control.altNeedIcon) then
    for id, value in pairs(control.altNeedIcon) do
      for key, icon in pairs(value) do
        icon:ClearAnchors()
        icon:SetHidden(true)
      end
    end
  end
  if not control.researchIcon then
    control.researchIcon = { path = "/esoui/art/lfg/lfg_tabicon_grouptools_up.dds" }
  end
  if not control.researchIcon.icon then
    icon = WINDOW_MANAGER:CreateControl(controlName, control, CT_TEXTURE)
    icon:SetDimensions(40, 40)
    icon:SetAnchor(firstOrientation, control, secondOrientation, sideFloat, 0)
    icon:SetTexture(control.researchIcon.path)
    control.researchIcon.icon = icon
  else
    control.researchIcon.icon:SetHidden(false)
  end
  return icon
end

function TC:GetCommonStyles()
	-- Courtesy of Weolo and wolfstar's TraitBuddy
	local styles = {}
	local STYLE_KHAJIIT = 9
	for itemStyleIndex = 1, STYLE_KHAJIIT do
		local itemStyleId = GetValidItemStyleId(itemStyleIndex)
		if itemStyleId > 0 then
			-- d(sf("Adding style %s itemStyleId %s", GetItemStyleName(itemStyleId), itemStyleId))
			styles[itemStyleId] = true
		end
	end
	return styles
end

function TC.CreateIcon(control, id, key, iconPath, r, g, b, sideFloat, firstOrientation, secondOrientation, controlName)
  local icon
  if not control.altNeedIcon then
      control.altNeedIcon = {}
  end
  if not control.altNeedIcon[id] then
    control.altNeedIcon[id] = {}
  end
  if not control.altNeedIcon[id][key] and not GetControl(controlName) then
    icon = WINDOW_MANAGER:CreateControl(controlName, control, CT_TEXTURE)
    icon:SetDimensions(40, 40)
    icon:SetAnchor(firstOrientation, control, secondOrientation, sideFloat, 0)
    icon:SetTexture(iconPath)
    icon:SetColor(r, g, b, 1)
    control.altNeedIcon[id][key] = icon
  else
    control.altNeedIcon[id][key]:SetColor(r, g, b, 1)
    control.altNeedIcon[id][key]:SetAnchor(firstOrientation, control, secondOrientation, sideFloat, 0)
    control.altNeedIcon[id][key]:SetHidden(false)
  end
  return icon
end

function TC.addCharIcon(control, id, value, sideFloat, key, firstOrientation, secondOrientation, controlName)
  local icon
  if control.researchIcon and control.researchIcon.icon then
    control.researchIcon.icon:ClearAnchors()
    control.researchIcon.icon:SetHidden(true)
  end
  local trait = TC.AV.traitTable[key] or 0
  local mask = TC.bitwiseChars[id]
  local iconPath = value.icon or TC.IconList[1]

  local char = TC.AV.activelyResearchingCharacters[id]
  --Researching
  if TC.AV.settings.showResearching and char and char.research and char.research[key] then
    TC.CreateIcon(control, id, key, iconPath, TC.AV.settings.researchingColor.r, TC.AV.settings.researchingColor.g, TC.AV.settings.researchingColor.b, sideFloat, firstOrientation, secondOrientation, controlName)
  --Unknown
  elseif TC.AV.settings.showUnknown and TC.charBitMissing(trait, mask) then
    TC.CreateIcon(control, id, key,iconPath, TC.AV.settings.unknownColor.r, TC.AV.settings.unknownColor.g, TC.AV.settings.unknownColor.b, sideFloat, firstOrientation, secondOrientation, controlName)
  --Known
  elseif TC.AV.settings.showKnown and not TC.charBitMissing(trait, mask) then
    TC.CreateIcon(control, id, key, iconPath, TC.AV.settings.knownColor.r, TC.AV.settings.knownColor.g, TC.AV.settings.knownColor.b, sideFloat, firstOrientation, secondOrientation, controlName)
  end
end

function TC.AddAltNeedIcon(control, craftingType, researchLineIndex, traitIndex, firstOrientation, secondOrientation, sideFloat, prefix)
  local controlName
  local knows = TC:DoesCharacterKnowTrait(craftingType, researchLineIndex, traitIndex)
  if not knows then
    controlName = prefix.."Unresearched"..currentlyLoggedInCharId.."C"..craftingType.."R"..researchLineIndex.."T"..traitIndex
    TC.addResearchIcon(control, craftingType, researchLineIndex, traitIndex, firstOrientation, secondOrientation, sideFloat, controlName)
  else
    local key = TC:GetTraitKey(craftingType, researchLineIndex, traitIndex)
    if control.altNeedIcon and next(control.altNeedIcon) then
      for id, value in pairs(control.altNeedIcon) do
        for key, iconval in pairs(value) do
          iconval:ClearAnchors()
          iconval:SetHidden(true)
        end
      end
    end
    for id, value in pairs(TC.AV.activelyResearchingCharacters) do
      controlName = prefix..id.."C"..craftingType.."R"..researchLineIndex.."T"..traitIndex
      TC.addCharIcon(control, id, value, sideFloat, key, firstOrientation, secondOrientation, controlName)
      sideFloat = sideFloat + 40
    end
  end
end

local function setupTraitDisplayCallback(self, control, researchLine, known, duration, traitIndex)
  local icon = nil
  icon = control:GetNamedChild("Icon")
  if traitIndex then
    TC.AddAltNeedIcon(icon, researchLine.craftingType, researchLineIndex, traitIndex, RIGHT, RIGHT, 180, "iconId")
  end
  TC.hookLock = setupNoop
end

local function addSmithingHook()
  ZO_PreHook(SMITHING, "SetupTraitDisplay", TC.hookLock)
end

local function OnCraftingInteract(eventCode, craftingType)
  if next(TC.AV.allCrafterIds) then
    if TC.AV.allCrafters[craftingType] == currentlyLoggedInCharId then
      TC.hookLock = setupTraitDisplayCallback
      ZO_PreHook(SMITHING, "ShowTraitsFor", function(self, data)
        researchLineIndex = data.researchLineIndex
        addSmithingHook()
      end)
    end
  end
end

EVENT_MANAGER:RegisterForEvent(TC.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent("TC_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, TC_Event_Player_Activated)
EVENT_MANAGER:RegisterForEvent(TC.name, EVENT_CRAFTING_STATION_INTERACT, OnCraftingInteract)
