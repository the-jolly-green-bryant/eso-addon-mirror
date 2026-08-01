local ADDON_NAME = "ClearNewPips"

-- ── Clearing Functions ───────────────────────────────────────────────

-- Covers all collectible-based sub-tabs: Collectibles, Stories/DLC,
-- Housing, Outfit Styles, and Tales of Tribute Patrons.
local function ClearCollectiblesNew()
    local count = 0
    for _, collectibleData in ZO_COLLECTIBLE_DATA_MANAGER:CollectibleIterator({ ZO_CollectibleData.IsNew }) do
        ClearCollectibleNewStatus(collectibleData:GetId())
        count = count + 1
    end
    return count
end

-- Covers the Set Items sub-tab (separate system from collectibles).
local function ClearItemSetsNew()
    if not ITEM_SET_COLLECTIONS_DATA_MANAGER then return 0 end
    local count = 0
    for _, pieceData in ITEM_SET_COLLECTIONS_DATA_MANAGER:ItemSetCollectionPieceIterator({ ZO_ItemSetCollectionPieceData.IsNew }) do
        pieceData:ClearNew()
        count = count + 1
    end
    return count
end

-- Collections = all collectibles + item set pieces.
local function ClearCollectionsNew()
    return ClearCollectiblesNew() + ClearItemSetsNew()
end

local function ClearSkillsNew()
    local count = 0
    for _, skillTypeData in SKILLS_DATA_MANAGER:SkillTypeIterator() do
        for _, skillLineData in skillTypeData:SkillLineIterator() do
            if skillLineData:IsNew() then
                skillLineData:ClearNew()
                count = count + 1
            end
            for _, skillData in skillLineData:SkillIterator() do
                if skillData:HasUpdatedStatus() then
                    skillData:ClearUpdate()
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function ClearInventoryNew()
    if not SHARED_INVENTORY then return 0 end
    local count = 0
    for _, bagId in ipairs({BAG_BACKPACK, BAG_VIRTUAL}) do
        local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(bagId)
        if bagCache then
            for slotIndex, slotData in pairs(bagCache) do
                if slotData.brandNew then
                    SHARED_INVENTORY:ClearNewStatus(bagId, slotIndex)
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function ClearChampionNew()
    if not CHAMPION_PERKS then return 0 end
    local count = 0
    if CHAMPION_PERKS:IsChampionSystemNew() then
        CHAMPION_PERKS:SetChampionSystemNew(false)
        count = 1
    end
    -- Unspent champion points cannot be dismissed — player must spend them
    return count
end

-- Covers the Antiquities sub-tab (only Journal sub-tab with "new" pips).
-- Lore Library, Achievements, and Leaderboards have no new-indicator system.
local function ClearJournalNew()
    if not ANTIQUITY_DATA_MANAGER then return 0 end
    local count = 0
    for _, antiquityData in ANTIQUITY_DATA_MANAGER:AntiquityIterator({ ZO_Antiquity.HasNewLead }) do
        antiquityData:ClearNewLead()
        count = count + 1
    end
    return count
end

local function ClearGroupNew()
    local count = 0
    if GROUP_FINDER_APPLICATIONS_LIST_MANAGER
       and GROUP_FINDER_APPLICATIONS_LIST_MANAGER:HasNewApplication() then
        GROUP_FINDER_APPLICATIONS_LIST_MANAGER:SetHasNewApplication(false)
        count = count + 1
    end
    return count
end

-- ── Category Mapping ─────────────────────────────────────────────────
-- Each entry needs a display name, a clear function, and optionally
-- a scene group name so sub-tab indicators also get refreshed.

local CATEGORY_CLEAR_FUNCTIONS = {
    [MENU_CATEGORY_COLLECTIONS] = { name = "Collections", clear = ClearCollectionsNew, sceneGroup = "collectionsSceneGroup" },
    [MENU_CATEGORY_SKILLS]      = { name = "Skills",      clear = ClearSkillsNew },
    [MENU_CATEGORY_INVENTORY]   = { name = "Inventory",   clear = ClearInventoryNew },
    [MENU_CATEGORY_CHAMPION]    = { name = "Champion",    clear = ClearChampionNew },
    [MENU_CATEGORY_JOURNAL]     = { name = "Journal",     clear = ClearJournalNew,     sceneGroup = "journalSceneGroup" },
    [MENU_CATEGORY_GROUP]       = { name = "Group",       clear = ClearGroupNew },
}

local function ClearNewForCategory(category)
    local entry = CATEGORY_CLEAR_FUNCTIONS[category]
    if not entry then
        return false
    end

    local count = entry.clear()
    if count > 0 then
        d(string.format("|cFFD700ClearNewPips|r: Cleared %d notification%s in %s",
            count, count == 1 and "" or "s", entry.name))
    else
        d(string.format("|cFFD700ClearNewPips|r: No new notifications in %s", entry.name))
    end
    return true, entry.sceneGroup
end

-- ── Initialization ───────────────────────────────────────────────────

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- Hook the main menu category click handler.
    -- When Shift is held, clear new pips AND open the menu normally.
    ZO_PreHook(MAIN_MENU_KEYBOARD, "OnCategoryClicked", function(self, category)
        if IsShiftKeyDown() then
            local handled, sceneGroup = ClearNewForCategory(category)
            if handled then
                self:RefreshCategoryIndicators()
                -- Also refresh sub-tab indicators if this category has them
                if sceneGroup then
                    self:UpdateSceneGroupButtons(sceneGroup)
                end
            end
        end
        return false
    end)

    d("|cFFD700ClearNewPips|r loaded. Shift+Click menu categories to clear notifications.")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
