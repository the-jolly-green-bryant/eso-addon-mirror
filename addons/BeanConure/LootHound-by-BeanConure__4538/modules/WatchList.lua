LootHound.WatchList = {}
local WL = LootHound.WatchList

-- Links the active WatchList to the Account-Wide saved variables
function WL:Init()
    if not LootHound.savedVars.watchList then LootHound.savedVars.watchList = {} end
    self.list = LootHound.savedVars.watchList
end

-- Adds a new rule to the list and generates a unique timestamp ID for it
function WL:Add(entry)
    if not self.list then
        self.list = LootHound.savedVars.watchList or {}
        LootHound.savedVars.watchList = self.list
    end
    entry.id      = tostring(GetTimeStamp()) .. tostring(math.random(1000,9999))
    entry.enabled = true
    table.insert(self.list, entry)
    LootHound.savedVars.watchList = self.list
    return entry.id
end

-- Removes a rule from the list by its unique ID
function WL:Remove(entryId)
    for i, e in ipairs(self.list) do
        if e.id == entryId then
            table.remove(self.list, i)
            LootHound.savedVars.watchList = self.list
            return true
        end
    end
    return false
end

-- Toggles a rule on or off (Currently unused, ready for future updates)
function WL:SetEnabled(entryId, enabled)
    for _, e in ipairs(self.list) do
        if e.id == entryId then
            e.enabled = enabled
            LootHound.savedVars.watchList = self.list
            return
        end
    end
end

-- Returns the entire table of active rules
function WL:GetAll() return self.list end

-- Scans an item link and compares it against every rule in the Watch List
function WL:FindMatch(itemLink)
    if not itemLink or itemLink == "" then return nil end

    -- Extract data from the looted item
    local itemQuality   = GetItemLinkQuality(itemLink)
    local itemTrait     = GetItemLinkTraitInfo(itemLink)
    local itemEquipSlot = GetItemLinkEquipType(itemLink)
    local itemSetId     = select(6, GetItemLinkSetInfo(itemLink))
    local itemWeapType  = GetItemLinkWeaponType(itemLink)
    local itemArmType   = GetItemLinkArmorType(itemLink)

    -- Loop through active rules to find a match
    for _, entry in ipairs(self.list) do
        if entry.enabled then
            if entry.mode == "simple" then
                if WL:_MatchSimple(entry, itemEquipSlot, itemTrait, itemQuality, itemWeapType, itemArmType) then
                    return entry
                end
            elseif entry.mode == "advanced" then
                if WL:_MatchAdvanced(entry, itemSetId, itemEquipSlot, itemTrait, itemQuality, itemWeapType, itemArmType) then
                    return entry
                end
            end
        end
    end
    return nil -- No matches found
end

-- Evaluates a generic piece of gear (e.g. "Any Divine Chest Piece")
function WL:_MatchSimple(entry, equipSlot, trait, quality, weapType, armType)
    local equipOk = (entry.equipType == nil) or (entry.equipType == equipSlot)
    local weapOk  = (entry.weaponType == nil) or (entry.weaponType == weapType)
    local armOk   = (entry.armourType == nil) or (entry.armourType == 0) or (entry.armourType == armType)
    local traitOk = (entry.traitId  == LootHound.ItemData.TRAIT_ANY) or (entry.traitId == trait)
    local qualOk  = (entry.quality  == LootHound.ItemData.QUALITY_ANY) or (entry.quality == quality)
    
    return equipOk and weapOk and armOk and traitOk and qualOk
end

-- Evaluates a gear piece belonging to a specific Set (e.g. "Turning Tide Chest")
function WL:_MatchAdvanced(entry, setId, equipSlot, trait, quality, weapType, armType)
    -- If the set ID doesn't match, we immediately fail it
    if entry.setId and entry.setId ~= setId then return false end

    -- If it is the right set, check if it's the specific piece/trait requested
    if entry.pieces and #entry.pieces > 0 then
        for _, p in ipairs(entry.pieces) do
            local equipMatch = (p.equipType == nil) or (p.equipType == equipSlot)
            local weapMatch  = (p.weaponType == nil) or (p.weaponType == weapType)
            
            if equipMatch and weapMatch then
                local traitOk = (p.traitId == LootHound.ItemData.TRAIT_ANY) or (p.traitId == trait)
                local qualOk  = (p.quality == LootHound.ItemData.QUALITY_ANY) or (p.quality == quality)
                local armOk   = (p.armourType == nil) or (p.armourType == 0) or (p.armourType == armType)
                if traitOk and qualOk and armOk then return true end
            end
        end
        return false
    end
    return true
end