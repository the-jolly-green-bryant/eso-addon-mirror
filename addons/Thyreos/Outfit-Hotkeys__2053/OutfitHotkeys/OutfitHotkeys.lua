----------
-- DATA --
----------

OutfitHotkeys = {
    name            = "OutfitHotkeys",           -- Matches folder and Manifest file names.
    -- version         = "1.0",                -- A nuisance to match to the Manifest.
    author          = "Thyreos",
    menuName        = "Outfit Hotkeys",   -- Unique identifier for menu object.
    -- Default settings.
    savedVariables = {
        restoreOutfit = false,
        currentOutfitIndex = 0,
        mementoMap = {
            [0] = 0, -- unequip
            [1] = 0, -- outfit01
            [2] = 0, -- outfit02
            [3] = 0, -- outfit03
            [4] = 0, -- outfit04
            [5] = 0, -- outfit05
            [6] = 0, -- outfit06
        },
    },
    playerMementos = {},
    triggeredByZoning = false, -- flag used to skip memento when restoring outfit after zoning
}

----------------------
-- HELPER FUNCTIONS --
----------------------

function OutfitHotkeys.EquipOutfit(index)
    if index > 0 then
        EquipOutfit(index)
    else
        UnequipOutfit()
    end

    OutfitHotkeys.savedVariables.currentOutfitIndex = index
end

function OutfitHotkeys.UseMemento(outfitIndex)
    mementoId = OutfitHotkeys.savedVariables.mementoMap[outfitIndex]
    if mementoId ~= nil and mementoId ~= 0 then
        UseCollectible(mementoId)
    end
end

function OutfitHotkeys.GetWornOutfitIndex()
    local index = GetEquippedOutfitIndex()
    if index == nil then index = 0 end
    return index
end

function OutfitHotkeys.LoadPlayerMementos()
    -- collectible collection has many top level categories
    -- top level categories have many collectibles and many subcategories
    -- sub categories have many collectibles 

    -- main loop = all toplevel categories
    for i=1, GetNumCollectibleCategories() do
        local topLevelIndex = i
        local categoryName, numSubCatgories, numCollectibles, unlockedCollectibles, totalCollectibles, hidesLocked = GetCollectibleCategoryInfo(topLevelIndex)
        -- secondary loop = all collectibles in a top level category
        for j=1, numCollectibles do
            local collectibleIndex = j
            local subCategoryIndex = nil
            local collectibleId = GetCollectibleId(topLevelIndex, subCategoryIndex, collectibleIndex)
            local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint, isPlaceholder = GetCollectibleInfo(collectibleId)
            if unlocked and categoryType == COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
                local data = {
                    mementoName = name,
                    mementoId = collectibleId,
                }
                table.insert(OutfitHotkeys.playerMementos, data)
            end
        end
        -- tertiary loop = all subcategories in a top level category        
        for k=1, numSubCatgories do
            local name, numCollectibles, unlockedCollectibles, totalCollectibles = GetCollectibleSubCategoryInfo(topLevelIndex, subCategoryIndex)
            -- quartenary loop = all collectibles in a subcategory
            for m=1, numCollectibles do
                local collectibleIndex = m
                local collectibleId = GetCollectibleId(topLevelIndex, subCategoryIndex, collectibleIndex)
                local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint, isPlaceholder = GetCollectibleInfo(collectibleId)
                if unlocked and categoryType == COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
                    local data = {
                        mementoName = name,
                        mementoId = collectibleId,
                    }
                    table.insert(OutfitHotkeys.playerMementos, data)
                end
            end
        end
    end

    table.sort(OutfitHotkeys.playerMementos, function (objA, objB) return objA.mementoName < objB.mementoName end)
    table.insert(OutfitHotkeys.playerMementos, 1, { mementoName = GetString(SI_OUTFITHOTKEYS_MENU_NO_MOMENTO_CHOICE), mementoId = 0})
end

function OutfitHotkeys.GetMementoNames()
    local names = {}
    for k,v in ipairs(OutfitHotkeys.playerMementos) do
        table.insert(names, v.mementoName)
    end
    return names
end

function OutfitHotkeys.GetMementoIds()
    local ids = {}
    for k,v in ipairs(OutfitHotkeys.playerMementos) do
        table.insert(ids, v.mementoId)
    end
    return ids
end

--------------------
-- EVENT HANDLERS --
--------------------

function OutfitHotkeys.OutfitEquipped(e, equipOutfitResult)
    local outfitIndex = OutfitHotkeys.GetWornOutfitIndex()
    OutfitHotkeys.savedVariables.currentOutfitIndex = outfitIndex
    if OutfitHotkeys.triggeredByZoning then
        OutfitHotkeys.triggeredByZoning = false
    else 
        OutfitHotkeys.UseMemento(outfitIndex)
    end
end
EVENT_MANAGER:RegisterForEvent(OutfitHotkeys.name, EVENT_OUTFIT_EQUIP_RESPONSE, OutfitHotkeys.OutfitEquipped)

function OutfitHotkeys.PlayerActivated(e)
    if OutfitHotkeys.savedVariables.restoreOutfit then
        OutfitHotkeys.triggeredByZoning = true
        OutfitHotkeys.EquipOutfit(OutfitHotkeys.savedVariables.currentOutfitIndex)
    end
end
EVENT_MANAGER:RegisterForEvent(OutfitHotkeys.name, EVENT_PLAYER_ACTIVATED, OutfitHotkeys.PlayerActivated)

function OutfitHotkeys.OnAddOnLoaded(event, addonName)
    if addonName ~= OutfitHotkeys.name then return end
    EVENT_MANAGER:UnregisterForEvent(OutfitHotkeys.name, EVENT_ADD_ON_LOADED)

    OutfitHotkeys.savedVariables = ZO_SavedVars:New("OutfitHotkeysSavedVariables", 1, nil, OutfitHotkeys.savedVariables)
    
    OutfitHotkeys.LoadPlayerMementos()
    OutfitHotkeys.LoadSettings()
end
EVENT_MANAGER:RegisterForEvent(OutfitHotkeys.name, EVENT_ADD_ON_LOADED, OutfitHotkeys.OnAddOnLoaded)