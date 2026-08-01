ResearchCraft = {
    name = "ResearchCraft",
    title = "Research Craft",
    version = "1.6.7",
    author = "silvereyes",
    defaults = {
        reserve = 20,
    },
}
local self = ResearchCraft
local researchableCraftSkills = {
    [CRAFTING_TYPE_BLACKSMITHING]   = true,
    [CRAFTING_TYPE_CLOTHIER]        = true,
    [CRAFTING_TYPE_WOODWORKING]     = true,
    [CRAFTING_TYPE_JEWELRYCRAFTING or -1] = true,
}
local cheapStyles = {
    [ITEMSTYLE_RACIAL_HIGH_ELF]     = true,
    [ITEMSTYLE_RACIAL_DARK_ELF]     = true,
    [ITEMSTYLE_RACIAL_WOOD_ELF]     = true,
    [ITEMSTYLE_RACIAL_NORD]         = true,
    [ITEMSTYLE_RACIAL_BRETON]       = true,
    [ITEMSTYLE_RACIAL_REDGUARD]     = true,
    [ITEMSTYLE_RACIAL_KHAJIIT]      = true,
    [ITEMSTYLE_RACIAL_ORC]          = true,
    [ITEMSTYLE_RACIAL_ARGONIAN]     = true,
    [ITEMSTYLE_RACIAL_IMPERIAL]     = true,
    [ITEMSTYLE_AREA_ANCIENT_ELF]    = true,
    [ITEMSTYLE_AREA_REACH]          = true,
    [ITEMSTYLE_ENEMY_PRIMITIVE]     = true,
}
local itemTraitTypeOrder = {
    ITEM_TRAIT_TYPE_WEAPON_INFUSED,
    ITEM_TRAIT_TYPE_ARMOR_DIVINES,
    ITEM_TRAIT_TYPE_WEAPON_SHARPENED,
    ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,
    ITEM_TRAIT_TYPE_WEAPON_PRECISE,
    ITEM_TRAIT_TYPE_ARMOR_INFUSED,
    ITEM_TRAIT_TYPE_WEAPON_DECISIVE,
    ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
    ITEM_TRAIT_TYPE_WEAPON_CHARGED,
    ITEM_TRAIT_TYPE_ARMOR_STURDY,
    ITEM_TRAIT_TYPE_WEAPON_DEFENDING,
    ITEM_TRAIT_TYPE_ARMOR_REINFORCED,
    ITEM_TRAIT_TYPE_WEAPON_TRAINING,
    ITEM_TRAIT_TYPE_ARMOR_TRAINING,
    ITEM_TRAIT_TYPE_WEAPON_POWERED,
    ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS,
    ITEM_TRAIT_TYPE_WEAPON_NIRNHONED,
    ITEM_TRAIT_TYPE_ARMOR_NIRNHONED,
    ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY,
    ITEM_TRAIT_TYPE_JEWELRY_TRIUNE,
    ITEM_TRAIT_TYPE_JEWELRY_INFUSED,
    ITEM_TRAIT_TYPE_JEWELRY_ARCANE,
    ITEM_TRAIT_TYPE_JEWELRY_ROBUST,
    ITEM_TRAIT_TYPE_JEWELRY_SWIFT,
    ITEM_TRAIT_TYPE_JEWELRY_HEALTHY,
    ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE,
    ITEM_TRAIT_TYPE_JEWELRY_HARMONY,
}
local styledCategories = {
    [ITEM_TRAIT_TYPE_CATEGORY_ARMOR]  = true,
    [ITEM_TRAIT_TYPE_CATEGORY_WEAPON] = true,
}
local function DiscoverResearchableTraits(craftSkill, researchLineIndex, returnAll)
    
    -- Get the total number of traits in the research line
    local _, _, numTraits = GetSmithingResearchLineInfo(craftSkill, researchLineIndex)
    
    -- Range check
    if numTraits <= 0 then return end
    
    -- Initialize the traits array
    self.researchableTraits[researchLineIndex] = {}
    
    for traitIndex = 1, numTraits do
        local traitType, traitDescription, known = GetSmithingResearchLineTraitInfo(craftSkill, researchLineIndex, traitIndex)

        -- Trait is not known
        if not known then  
            local durationSecs = GetSmithingResearchLineTraitTimes(craftSkill, researchLineIndex, traitIndex)
            
            if not durationSecs then
                -- Trait is researchable
                table.insert(self.researchableTraits[researchLineIndex], traitIndex)
                
            elseif not returnAll then
                -- No additional research can be done in this line right now.
                self.currentResearchCount = self.currentResearchCount + 1
                self.researchableTraits[researchLineIndex] = nil
                return true
            end
            
        end
    end
    
    -- All traits are researched for this line.  Exclude it from any further processing.
    if #self.researchableTraits[researchLineIndex] == 0 then
        self.researchableTraits[researchLineIndex] = nil
    end
end

local function IsFcoisResearchMarked(bagId, slotIndex)
    if not FCOIS or not FCOIsMarked then
        return
    end
    local itemInstanceId = GetItemInstanceId(bagId, slotIndex)
    if FCOIsMarked(itemInstanceId, FCOIS_CON_ICON_RESEARCH) then
        return true
    end
end
local function IsFcoisLocked(bagId, slotIndex)
    if FCOIS and FCOIS.callDeconstructionSelectionHandler(bagId, slotIndex, false, false, true, true, true, true, LF_SMITHING_RESEARCH) then
        return true
    end
end
local function IsResearchable(bagId, slotIndex)
    local _, _, _, _, locked, _, itemStyle, quality = GetItemInfo(bagId, slotIndex)
    if locked then 
        return 
    end
    if IsFcoisResearchMarked(bagId, slotIndex) then
        return true
    end
    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
    local hasSet = GetItemLinkSetInfo(itemLink)
    if quality < (ITEM_QUALITY_ARTIFACT or ITEM_FUNCTIONAL_QUALITY_ARTIFACT)
       and not IsFcoisLocked(bagId, slotIndex)
       and cheapStyles[itemStyle] 
       and not hasSet
    then
        return true
    end
end
local function GetResearchableItem(bagId, craftSkill, researchLineIndex, returnAll)
    local slotIndex = ZO_GetNextBagSlotIndex(bagId)
    local researchableItems = {}
    while slotIndex do
        if IsResearchable(bagId, slotIndex) then
            for i = 1, #self.researchableTraits[researchLineIndex] do
                local traitIndex = self.researchableTraits[researchLineIndex][i]
                if not researchableItems[traitIndex] 
                   and CanItemBeSmithingTraitResearched(bagId, slotIndex, craftSkill, researchLineIndex, traitIndex) 
                then                    
                    if i == 1 and not returnAll then
                        return slotIndex
                    end
                    researchableItems[traitIndex] = slotIndex
                    break
                end
            end
        end
        slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
    end
    return researchableItems
end
local function OnAlertNoSuppression(category, soundId, message)
    if not self.researching or category ~= UI_ALERT_CATEGORY_ALERT then
        return
    end
    if message == SI_SMITHING_BLACKSMITH_EXTRACTION_FAILED 
       or message == SI_SMITHING_CLOTHIER_EXTRACTION_FAILED
       or message == SI_SMITHING_WOODWORKING_EXTRACTION_FAILED
       or message == SI_SMITHING_EXTRACTION_FAILED
    then
        return true
    end
end
-- Stolen from pChat. Thanks Ayantir.
-- Set copied text into text entry, if possible
local function CopyToTextEntry(message)

    -- Max of inputbox is 351 chars
    if string.len(message) < 351 then
        if CHAT_SYSTEM.textEntry:GetText() == "" then
            CHAT_SYSTEM.textEntry:Open(message)
            ZO_ChatWindowTextEntryEditBox:SelectAll()
        end
    end

end
local function EndCraft()
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_CRAFT_COMPLETED)
    self.craftGear = nil
    self.maxCraftCount = nil
    self.traitTypeToIndexMap = nil
end
local function MarkTraitCrafted(patternIndex, itemTraitType)
    self.craftGear[itemTraitType][patternIndex] = nil
    self.maxCraftCount = self.maxCraftCount - 1
    if not next(self.craftGear[itemTraitType]) then
        self.craftGear[itemTraitType] = nil
    end
end
local function CraftNext()

    if self.maxCraftCount < 1 then
        EndCraft()
        return
    end
    
    -- check inventory for available slot
    local slotIndex = FindFirstEmptySlotInBag(BAG_BACKPACK)
    if not slotIndex then
        ZO_AlertEvent(EVENT_INVENTORY_IS_FULL, 1, 0)
        EndCraft()
        return
    end
    
    -- Look up the next trait and pattern
    local itemTraitType
    for i=1, #itemTraitTypeOrder do
        if self.craftGear[itemTraitTypeOrder[i]] then
            itemTraitType = itemTraitTypeOrder[i]
            break
        end
    end
    if not itemTraitType then
        EndCraft()
        return
    end
    
    local patternIndex = next(self.craftGear[itemTraitType])
    
    -- Check inventory for sufficient materials
    local materialIndex = 1 -- always use the cheap stuff
    local materialCount = GetCurrentSmithingMaterialItemCount(patternIndex, materialIndex)
    local materialRequired = select(3, GetSmithingPatternMaterialItemInfo(patternIndex, materialIndex))
    local materialLink = GetSmithingPatternMaterialItemLink(patternIndex, materialIndex)
    if materialCount < materialRequired then
        d("You do not have the " .. tostring(materialRequired) .. "x " .. materialLink 
          .. " required to continue crafting.")
        EndCraft()
        return
    end
    
    -- if crafting weapons or armor, find style stone with the biggest stack
    local itemTraitTypeCategory = GetItemTraitTypeCategory(itemTraitType)
    local selectedItemStyle
    if styledCategories[itemTraitTypeCategory] then
        local maxStyleItemStackSize = 0
        local minStyleId = GetFirstKnownItemStyleId(patternIndex)
        local maxStyleId = GetHighestItemStyleId()
        for itemStyle = minStyleId, maxStyleId do
            if GetValidItemStyleId(itemStyle)
               and IsSmithingStyleKnown(itemStyle, patternIndex)
               and cheapStyles[itemStyle]
            then
                local styleItemStackSize = GetCurrentSmithingStyleItemCount(itemStyle)
                if styleItemStackSize > maxStyleItemStackSize then
                    maxStyleItemStackSize = styleItemStackSize  
                    selectedItemStyle = itemStyle       
                end
            end
        end
    
        -- No cheap style materials found for any known styles
        if not selectedItemStyle then
            d("You do not have any inexpensive style stones for known motifs.")
            EndCraft()
            return
        end
    end
    
    -- Check inventory for trait stone
    local traitItemIndex = self.traitTypeToIndexMap[itemTraitType]
    local traitName = GetString("SI_ITEMTRAITTYPE", GetSmithingTraitItemInfo(traitItemIndex))
    local traitItemLink = GetSmithingTraitItemLink(traitItemIndex)
    local itemLink = GetSmithingPatternResultLink(patternIndex, materialIndex, materialRequired, 
                                                  selectedItemStyle, traitItemIndex)
    itemLink = itemLink .. " ("..traitName..")"
    --d("trait item index: "..tostring(traitItemIndex))
    local traitStoneCount = GetCurrentSmithingTraitItemCount(traitItemIndex)
    if traitStoneCount == 0 then
        d("You do not have any "..tostring(traitItemLink).." so you cannot craft "..itemLink)
        MarkTraitCrafted(patternIndex, itemTraitType)
        CraftNext()
        return
    end
    
    local message = "Crafting " .. itemLink .. " using " .. tostring(materialRequired) .. "x " .. materialLink
    if selectedItemStyle then
        local styleItemLink = GetItemStyleMaterialLink(selectedItemStyle)
        --local itemStyleName = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", selectedItemStyle))
        message = message .. ", 1x " .. styleItemLink
    end
    message = message .. " and 1x " .. traitItemLink .. "..."
    d(message)
    -- Craft the item, at last
    MarkTraitCrafted(patternIndex, itemTraitType)
    --CraftNext()
    CraftSmithingItem(patternIndex, materialIndex, materialRequired, 
                      selectedItemStyle, traitItemIndex)
end
local function CraftResearch(encoded)
    if not encoded then
        d("Expected encoded research trait list. Please run /researchexport on the toon you want to craft for, and then copy/paste the resulting command here.")
        return
    end
    
    local craftSkill = GetCraftingInteractionType()
    if not researchableCraftSkills[craftSkill] then
        d("You cannot craft researchable gear here. Please go to an equipment crafting station and try again.")
        return
    end
    
    local isLine = true
    local isCraftSkill = true
    local isFreeSlots = false
    self.craftGear = {}
    self.traitTypeToIndexMap = {}
    for traitItemIndex = 1, GetNumSmithingTraitItems() do
        local itemTraitType = GetSmithingTraitItemInfo(traitItemIndex)
        if itemTraitType then
            self.traitTypeToIndexMap[itemTraitType] = traitItemIndex
        end
    end
    local nameToPatternMap = {}
    for patternIndex = 1, GetNumSmithingPatterns() do
        local _, name = GetSmithingPatternInfo(patternIndex)
        nameToPatternMap[name] = patternIndex
    end
    local patternIndex
    local researchLineIndex
    for part in string.gmatch(encoded, '([^:]+)') do
        if isCraftSkill then
            isCraftSkill = false
            if tonumber(part) ~= craftSkill then
                d("You cannot craft that type of gear here. Please visit the appropriate craft station.")
                return
            end
            isFreeSlots = true
        elseif isFreeSlots then
            self.maxCraftCount = tonumber(part)
            isFreeSlots = false
        elseif isLine then
            researchLineIndex = tonumber(part)
            local researchLineName = GetSmithingResearchLineInfo(craftSkill, researchLineIndex)
            patternIndex = nameToPatternMap[researchLineName]
        else
            for splitPart in string.gmatch(part, '([^,]+)') do
                local researchTraitIndex = tonumber(splitPart)
                local itemTraitType, _, known = GetSmithingResearchLineTraitInfo(craftSkill, researchLineIndex, researchTraitIndex)
        
                -- Trait is known
                if known then  
                    if not self.craftGear[itemTraitType] then
                        self.craftGear[itemTraitType] = {}
                    end
                    self.craftGear[itemTraitType][patternIndex] = true
                end
            end
        end
        isLine = not isLine
    end
    
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFT_COMPLETED, CraftNext)
    CraftNext()
end
local function PrintUsage()
    d("Usage: /researchexport <skill> <reserve> <limit> <nirn>")
    d("  <skill>: blacksmithing (bs, metal, smith), clothier (cloth), woodworking (ww) or jewelry (jc)")
    d("  <reserve>: (optional) number of inventory slots to leave empty. default 20")
    d("  <limit>: (optional) max number of pieces to craft; -or- half -or- third -or- quarter (available slots - reserve / 2, 3 or 4)")
    d("  <nirn>: (optional) if the word nirn is specified, nirncrux items are included in the export")
end
function WordSplit(str)
    local words = {}
    for word in str:gmatch("%w+") do table.insert(words, word) end
    return unpack(words)
end
local function ResearchExport(parameters)
    
    local skill, reserve, limit, nirn = WordSplit(parameters)
    
    local craftSkill
    if skill == "smith" or skill == "bs" or skill == "blacksmithing" or skill == "metal" then
        craftSkill = CRAFTING_TYPE_BLACKSMITHING
    elseif skill == "cloth" or skill == "clothier" then
        craftSkill = CRAFTING_TYPE_CLOTHIER
    elseif skill == "ww" or skill == "woodworking" then
        craftSkill = CRAFTING_TYPE_WOODWORKING
    elseif (skill == "jc" or skill == "jewelry") and CRAFTING_TYPE_JEWELRYCRAFTING then
        craftSkill = CRAFTING_TYPE_JEWELRYCRAFTING
    else
        d("Invalid parameter "..tostring(skill))
        PrintUsage()
        return
    end
    
    if reserve then
        if tonumber(reserve) then
            reserve = tonumber(reserve)
        else
            nirn = limit
            limit = reserve
            reserve = self.defaults.reserve
        end
    else
        reserve = self.defaults.reserve
    end
    
    local freeSlots
    if limit and tonumber(limit) then
        freeSlots = tonumber(limit)
    else
        freeSlots = GetNumBagFreeSlots(BAG_BACKPACK) - reserve
        if freeSlots < 0 then 
            d("You do not have enough free slots in your inventory.")
            return
        end
    end
    if limit == "half" then
        freeSlots = math.floor(freeSlots / 2)
    elseif limit == "third" then
        freeSlots = math.floor(freeSlots / 3)
    elseif limit == "quarter" then
        freeSlots = math.floor(freeSlots / 4)
    elseif limit == "nirn" then
        nirn = limit
        limit = nil
    end
    local encoded = "/researchcraft "..tostring(craftSkill)..":"..tostring(freeSlots)..":"
    
    -- Subtotals how many traits are researched for each research line in this craft skill
    self.researchableTraits = {}
    
    -- Total number of research lines for this craft skill
    local researchLineCount = GetNumSmithingResearchLines(craftSkill)
    
    -- Loop through each research line (e.g. axe, mace, etc.)
    local firstLine = true
    for researchLineIndex = 1, researchLineCount do
        -- Calculate subtotals for the research line
        DiscoverResearchableTraits(craftSkill, researchLineIndex, true)
        if self.researchableTraits[researchLineIndex] then
            local backpackResearchables = GetResearchableItem(BAG_BACKPACK, craftSkill, 
                                                              researchLineIndex, true)
            local bankResearchables     = GetResearchableItem(BAG_BANK, craftSkill, 
                                                              researchLineIndex, true)
            local subBankResearchables
            if BAG_SUBSCRIBER_BANK then
                subBankResearchables    = GetResearchableItem(BAG_SUBSCRIBER_BANK, craftSkill, 
                                                              researchLineIndex, true)
            end
            local firstTrait = true
            for i = 1, #self.researchableTraits[researchLineIndex] do
                local traitIndex = self.researchableTraits[researchLineIndex][i]
                local traitType = GetSmithingResearchLineTraitInfo(craftSkill, researchLineIndex, 
                                                                   traitIndex)
                if not backpackResearchables[traitIndex] and not bankResearchables[traitIndex] 
                   and (nirn == "nirn" or traitType ~= ITEM_TRAIT_TYPE_ARMOR_NIRNHONED)
                   and (nirn == "nirn" or traitType ~= ITEM_TRAIT_TYPE_WEAPON_NIRNHONED)
                   and (not subBankResearchables or not subBankResearchables[traitIndex])
                then
                    if firstTrait then
                        if firstLine then
                            firstLine = false
                        else
                            encoded = encoded .. ":"
                        end
                        encoded = encoded .. tostring(researchLineIndex) .. ":"
                        firstTrait = false
                    else
                        encoded = encoded .. ","
                    end
                    encoded = encoded .. tostring(traitIndex)
                end
            end
        end
    end 
    CopyToTextEntry(encoded)
end
local function OnAddonLoaded(event, name)
    if name ~= self.name then return end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    
    ZO_PreHook("ZO_AlertNoSuppression", OnAlertNoSuppression)
    SLASH_COMMANDS["/rexport"] = ResearchExport
    SLASH_COMMANDS["/researchexport"] = ResearchExport
    SLASH_COMMANDS["/rcraft"] = CraftResearch
    SLASH_COMMANDS["/researchcraft"] = CraftResearch
end
EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)