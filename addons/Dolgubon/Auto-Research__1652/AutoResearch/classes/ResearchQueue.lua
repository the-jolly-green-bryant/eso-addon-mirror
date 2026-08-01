--[[ The ResearchQueue is used to scan the player inventory and/or bank for researchable items and 
     then retrieve them in order of:
     
     a) shortest research time; then
     b) highest priority trait (configured in settings); then
     c) left to right on the research tab.
     
     When a new ResearchQueue instance is created with :New(), it determines which research lines
     and traits have the lowest research times, and also starts tracking how many research slots
     are used.
     
     You can use the instance:AreResearchSlotsFull() method to determine if more research can be done.
     
     To populate the queue with item slots, call instance:Fill(bagIds)
     
     Then, to retrieve the next item for research from the queue, call instance:GetNext().  It will
     return a table with the following properties: bagId, slotIndex, researchLineIndex.
]]--

local ar   = AutoResearch
local class = ar.classes
class.ResearchQueue = ZO_Object:Subclass()

local name = ar.name .. "ResearchQueue"

function class.ResearchQueue:New(...)
    local instance = ZO_Object.New(self)
    instance:Initialize(...)
    return instance
end

function class.ResearchQueue:Initialize(craftSkill)
    self.name = name
    self.craftSkill = craftSkill
    self.data = {}
    self.currentResearchCount = 0
    -- Max number of research slots based on passives
    self.maxResearchCount = GetMaxSimultaneousSmithingResearch(craftSkill)
    -- Since it would be time-consuming to remove all items in a research line from the cache every
    -- time an item from that line is researched, just store a list of research lines to ignore
    self.ignoredResearchLineIndexes = {}
    
    -- Lookup table to find the research order index by trait
    self.researchOrderByTrait = {}
    self.maxResearchOrder = 0
    for _, researchCategory in ipairs( { "armor", "weapons", "jewelry" } ) do
        for traitOrder,traitType in ipairs(ar.settings.traitResearchOrder[researchCategory]) do
            self.researchOrderByTrait[traitType] = traitOrder
            if traitOrder > self.maxResearchOrder then
                self.maxResearchOrder = traitOrder
            end
        end
    end
    
    self.researchOrderByResearchLineIndex = {}
    self.maxResearchLineOrder = 0
    for researchLineOrder,researchLineIndex in ipairs(ar.settings.researchLineOrder[craftSkill]) do
        if researchLineIndex > 0 then
            self.researchOrderByResearchLineIndex[researchLineIndex] = researchLineOrder
        end
        if researchLineOrder > self.maxResearchLineOrder then
            self.maxResearchLineOrder = researchLineOrder
        end
    end
    
    -- How many traits are unknown for each research line index
    self.researchLineUnknownCounts = {}
    
    -- If a trait is known, then self.knownTraitsByResearchLine[researchLineIndex][traitType] will be true.
    self.knownTraitsByResearchLine = {}
    
    -- Number of research lines
    local researchLineCount = GetNumSmithingResearchLines(craftSkill)
    
    -- For each research line, find which traits are known, count how many traits are unknown and
    -- determine if the research line has an active research in progress.
    for researchLineIndex = 1, researchLineCount do
        self.knownTraitsByResearchLine[researchLineIndex] = {}
        -- Count the total number of unknown traits for each research line
        local _, _, numTraits = GetSmithingResearchLineInfo(craftSkill, researchLineIndex)
        local researchLineUnknownCount = 0
        for traitIndex = 1, numTraits do
            local traitType, _, known = GetSmithingResearchLineTraitInfo(craftSkill, researchLineIndex, traitIndex)
            local durationSecs = select(2, GetSmithingResearchLineTraitTimes(craftSkill, researchLineIndex, traitIndex))
            if not known then  
                        
                -- unknown and not researching
                if not durationSecs then
                    researchLineUnknownCount = researchLineUnknownCount + 1
                    
                -- actively researching. igore this research line
                else
                    self.currentResearchCount = self.currentResearchCount + 1
                    researchLineUnknownCount = nil
                    break
                end
            else
                --known trait
                self.knownTraitsByResearchLine[researchLineIndex][traitType] = true
                --workaround for bug where there's an active research counter for a known trait
                if durationSecs and CancelSmithingTraitResearch then
                    self.invalidResearchTrait = {researchLineIndex = researchLineIndex, traitIndex = traitIndex }
                    return
                end
            end
        end
        if researchLineUnknownCount then
            self.researchLineUnknownCounts[researchLineIndex] = researchLineUnknownCount
        end
    end
end

-- The internal data structure groups all research lines that have the same number of unknown traits
-- together in the same priority.  This method creates a new group of research lines.
local function AddNewGroup(self, researchLineUnknownCount, i)
    local newGroup = {
        researchLineUnknownCount = researchLineUnknownCount,
        slotsByResearchOrder = { }
    }
    for researchOrder = 1, self.maxResearchOrder do
        newGroup.slotsByResearchOrder[researchOrder] = {}
    end
    if not i then
        i = #self.data + 1
    end
    table.insert(self.data, i, newGroup)
    return newGroup
end

--[[ Adds a new item slot to the sorted queue. ]]--
function class.ResearchQueue:Add(bagId, slotIndex)
    
    -- Ignore non-researchable items
    local validator = class.Validator:New(bagId, slotIndex)
    local newSlot = validator:Validate()
    if not newSlot then
        return
    end

    -- Get the research line
    local linkParser = ar.craftSkills[self.craftSkill].linkParser
    local researchLineIndex = linkParser:GetItemLinkResearchLineIndex(newSlot.itemLink)
    if not researchLineIndex or researchLineIndex == 0 then
        return
    end
    
    -- Ignore items for in-progress research lines or those with all traits known
    local researchLineUnknownCount = self.researchLineUnknownCounts[researchLineIndex]
    if not researchLineUnknownCount or researchLineUnknownCount == 0 then
        return
    end
    
    -- Ignore items with known traits
    if self.knownTraitsByResearchLine[researchLineIndex][newSlot.itemTraitType] then
        return
    end
    
    --[[ Data is arranged in the following heirarchy:
    
         [ group ] all slots that will take the same amount of time to research, sorted with
             |     shortest time group first
             |
             |=> [ research order ] slots with traits that are all the same priority, 
                         |          lower number priority first
                         |
                         |=> [slots] a list of slots for the given research order, sorted by 
                                     research line priority.  Only a single slot from each 
                                     research line / trait combination is used.
      ]]--    
    local groupCount = #self.data
    if groupCount == 0 then
        AddNewGroup(self, researchLineUnknownCount, 1)
        groupCount = 1
    end
    newSlot.researchLineIndex = researchLineIndex
    local researchOrder = self.researchOrderByTrait[newSlot.itemTraitType]
    if not researchOrder or researchOrder == 0 then
        return
    end
    local researchLineOrder = self.researchOrderByResearchLineIndex[researchLineIndex]
    if not researchLineOrder or researchLineOrder == 0 then
        return
    end
    for i=1,groupCount do
        local group = self.data[i]
        if researchLineUnknownCount >= group.researchLineUnknownCount then
            if researchLineUnknownCount > group.researchLineUnknownCount then
                group = AddNewGroup(self, researchLineUnknownCount, i)
            end
            local slots = group.slotsByResearchOrder[researchOrder]
            
            for slotOrder=#slots,1,-1  do
                local slot = slots[slotOrder]
                local slotResearchLineOrder = self.researchOrderByResearchLineIndex[slot.researchLineIndex]
                -- A slot is already assigned to this research line for this research order
                if researchLineOrder == slotResearchLineOrder then
                  
                    -- Prioritize lower level, lower quality, and non-set items
                    if newSlot.requiredLevel < slot.requiredLevel 
                       or newSlot.requiredChampionPoints < slot.requiredChampionPoints
                       or newSlot.quality < slot.quality
                       or (not newSlot.hasSet and slot.hasSet)
                    then
                        slots[slotOrder] = newSlot
                    end
                    return
                    
                -- First slot identified for this research line and research order
                elseif researchLineOrder < slotResearchLineOrder then
                    table.insert(slots, slotOrder + 1, newSlot)
                    return
                end
            end
            table.insert(slots, 1, newSlot)
            return
        end
    end
    local newGroup = AddNewGroup(self, researchLineUnknownCount)
    table.insert(newGroup.slotsByResearchOrder[researchOrder], newSlot)
end

--[[ True if the current research count equals or exceeds the number of available research slots. 
     Otherwise nil. ]]--
function class.ResearchQueue:AreResearchSlotsFull()
    if self.currentResearchCount >= self.maxResearchCount then
        return true
    end
end

--[[ Scan the given bags for all rearchable items and add them to this queue ]]--
function class.ResearchQueue:Fill(bagIds)
    for _, bagId in ipairs(bagIds) do
        local slotIndex = ZO_GetNextBagSlotIndex(bagId)
        while slotIndex do
            self:Add(bagId, slotIndex)
            slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
        end
     end
end

--[[ Removes and returns the next item from the queue ]]--
function class.ResearchQueue:GetNext()
    for _, group in ipairs(self.data) do
        for researchOrder, slots in ipairs(group.slotsByResearchOrder) do
            while #slots > 0 do
                -- Note: we remove from the end of the slots table, for performance reasons
                local slot = table.remove(slots)
                -- Ignore research lines that have just started research
                if not self.ignoredResearchLineIndexes[slot.researchLineIndex] then
                    self.ignoredResearchLineIndexes[slot.researchLineIndex] = true
                    -- Increment the current research count and return
                    self.currentResearchCount = self.currentResearchCount + 1
                    return slot
                end
            end
        end
    end
end

--[[ Removes the given inventory item from the queue ]]--
function class.ResearchQueue:Remove(bagId, slotIndex)
    for _, group in ipairs(self.data) do
        for researchOrder, slots in ipairs(group.slotsByResearchOrder) do
            for i = #slots, 1, -1 do
                local slot = slots[i]
                if slot.bagId == bagId and slot.slotIndex == slotIndex then
                    table.remove(slots, i)
                    return
                end
            end
        end
    end
end