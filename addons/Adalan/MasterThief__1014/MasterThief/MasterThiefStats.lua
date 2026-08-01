-- MasterThiefStats.lua
-- Statistics tracking module for MasterThief addon

if not MasterThief then
    MasterThief = {}
end

-- Local reference for performance
local MT = MasterThief

----------------------------------------
-- Statistics Default Tables
----------------------------------------
MasterThief.SessionStatsDefault = 
{
	motifsLooted = 0,
	recipesLooted = 0,
	furnishingPlansLooted = 0,
	furnishingsLooted = 0,
	edictsLooted = 0,
	researchPortfoliosLooted = 0,
	hiddenWalletsLooted = 0,
	successfulPickpockets = 0,
	deathsByGuards = 0,
	doorsLockpicked = 0,
	safeboxesLockpicked = 0,
	totalFencedGold = 0,
	goldSpentLaundering = 0,
	highestBounty = 0,
	highestValueItemLooted = { link = "", value = 0 },
	itemsLooted = 0,
	itemsSkipped = 0,
	bladeOfWoeKills = 0,
	lockpickBreaksPrevented = 0,
}

MasterThief.LifetimeStatsDefault = 
{
	motifsLooted = 0,
	recipesLooted = 0,
	furnishingPlansLooted = 0,
	furnishingsLooted = 0,
	edictsLooted = 0,
	researchPortfoliosLooted = 0,
	hiddenWalletsLooted = 0,
	successfulPickpockets = 0,
	deathsByGuards = 0,
	doorsLockpicked = 0,
	safeboxesLockpicked = 0,
	totalFencedGold = 0,
	goldSpentLaundering = 0,
	highestBounty = 0,
	paidBountyTotal = 0,
	highestValueItemLooted = { link = "", value = 0 },
	itemsLooted = 0,
	itemsSkipped = 0,
	thievesTrovesLooted = 0,
	bladeOfWoeKills = 0,
	lockpickBreaksPrevented = 0,
}

----------------------------------------
-- Tracking Functions - Item Looting
----------------------------------------
function MasterThief:TrackItemLooted(itemLootLink, iSellPrice, itemType, specializedType)
    if not MasterThief.SessionStats or not MasterThief.SavedVarsLifetimeStats then 
        return 
    end
    
    -- Increment basic counters
    MasterThief.SessionStats.itemsLooted = MasterThief.SessionStats.itemsLooted + 1
    MasterThief.SavedVarsLifetimeStats.itemsLooted = MasterThief.SavedVarsLifetimeStats.itemsLooted + 1
    
    -- If itemType wasn't passed, get it
    if not itemType then
        itemType = GetItemLinkItemType(itemLootLink)
    end
    
    local itemName = GetItemLinkName(itemLootLink)
    
    -- Track specific item types
    if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
        MasterThief.SessionStats.motifsLooted = MasterThief.SessionStats.motifsLooted + 1
        MasterThief.SavedVarsLifetimeStats.motifsLooted = MasterThief.SavedVarsLifetimeStats.motifsLooted + 1
    
    -- Furnishing PLANS (detect by name prefix)
    elseif itemName:match("^Blueprint:") or itemName:match("^Design:") or 
           itemName:match("^Diagram:") or itemName:match("^Pattern:") or
           itemName:match("^Praxis:") or itemName:match("^Sketch:") or
           itemName:match("^Formula:") then
        MasterThief.SessionStats.furnishingPlansLooted = MasterThief.SessionStats.furnishingPlansLooted + 1
        MasterThief.SavedVarsLifetimeStats.furnishingPlansLooted = MasterThief.SavedVarsLifetimeStats.furnishingPlansLooted + 1
    
    -- Regular RECIPES
    elseif itemName:match("^Recipe:") then
        MasterThief.SessionStats.recipesLooted = MasterThief.SessionStats.recipesLooted + 1
        MasterThief.SavedVarsLifetimeStats.recipesLooted = MasterThief.SavedVarsLifetimeStats.recipesLooted + 1
    
    -- FURNISHINGS (itemType 56)
    elseif itemType == ITEMTYPE_FURNISHING then
        MasterThief.SessionStats.furnishingsLooted = MasterThief.SessionStats.furnishingsLooted + 1
        MasterThief.SavedVarsLifetimeStats.furnishingsLooted = MasterThief.SavedVarsLifetimeStats.furnishingsLooted + 1
	end
	
	-- EDICTS (specific item IDs: 71779, 73754, etc.)
    local itemId = GetItemLinkItemId(itemLootLink)
    local edictIds = { [71779] = true, [73754] = true }
    if edictIds[itemId] then
        MasterThief.SessionStats.edictsLooted = MasterThief.SessionStats.edictsLooted + 1
        MasterThief.SavedVarsLifetimeStats.edictsLooted = MasterThief.SavedVarsLifetimeStats.edictsLooted + 1
    end
	
	-- Azandar's Research Portfolio (companion perk, item ID 197790)
    if itemId == 197790 then
        
        MasterThief.SessionStats.researchPortfoliosLooted = (MasterThief.SessionStats.researchPortfoliosLooted or 0) + 1
        MasterThief.SavedVarsLifetimeStats.researchPortfoliosLooted = (MasterThief.SavedVarsLifetimeStats.researchPortfoliosLooted or 0) + 1
    end
    
    -- Hidden Wallet (companion perk, item ID 187747)

    if itemId == 187747 then
        
        MasterThief.SessionStats.hiddenWalletsLooted = (MasterThief.SessionStats.hiddenWalletsLooted or 0) + 1
        MasterThief.SavedVarsLifetimeStats.hiddenWalletsLooted = (MasterThief.SavedVarsLifetimeStats.hiddenWalletsLooted or 0) + 1
    end

    -- Track highest value item
    if iSellPrice and iSellPrice > MasterThief.SessionStats.highestValueItemLooted.value then
        MasterThief.SessionStats.highestValueItemLooted.link = itemLootLink
        MasterThief.SessionStats.highestValueItemLooted.value = iSellPrice
    end
    if iSellPrice and iSellPrice > MasterThief.SavedVarsLifetimeStats.highestValueItemLooted.value then
        MasterThief.SavedVarsLifetimeStats.highestValueItemLooted.link = itemLootLink
        MasterThief.SavedVarsLifetimeStats.highestValueItemLooted.value = iSellPrice
    end
	
	-- Refresh stats display if window is open
    if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
        MasterThief:UpdateSessionStatsDisplay()
        MasterThief:UpdateLifetimeStatsDisplay()
    end
end

function MasterThief:TrackItemSkipped()
    if not MasterThief.SessionStats or not MasterThief.SavedVarsLifetimeStats then 
        return 
    end
 
    MasterThief.SessionStats.itemsSkipped = MasterThief.SessionStats.itemsSkipped + 1
    MasterThief.SavedVarsLifetimeStats.itemsSkipped = MasterThief.SavedVarsLifetimeStats.itemsSkipped + 1
    
    if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
        MasterThief:UpdateSessionStatsDisplay()
        MasterThief:UpdateLifetimeStatsDisplay()
    end
end

function MasterThief:TrackSuccessfulPickpocket()
    
    if not MasterThief.SessionStats or not MasterThief.SavedVarsLifetimeStats then 
        return 
    end
    
    MasterThief.SessionStats.successfulPickpockets = (MasterThief.SessionStats.successfulPickpockets or 0) + 1
    MasterThief.SavedVarsLifetimeStats.successfulPickpockets = (MasterThief.SavedVarsLifetimeStats.successfulPickpockets or 0) + 1
    
    if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
        MasterThief:UpdateSessionStatsDisplay()
        MasterThief:UpdateLifetimeStatsDisplay()
    end
end

----------------------------------------
-- Tracking Functions - Gold & Fencing
----------------------------------------
function MasterThief:TrackFencedGold(goldAmount)
    if not MasterThief.SessionStats or not MasterThief.SavedVarsLifetimeStats then 
        return 
    end
    
    MasterThief.SessionStats.totalFencedGold = MasterThief.SessionStats.totalFencedGold + goldAmount
    MasterThief.SavedVarsLifetimeStats.totalFencedGold = MasterThief.SavedVarsLifetimeStats.totalFencedGold + goldAmount
    
    -- Refresh stats display if window is open
    if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
        MasterThief:UpdateSessionStatsDisplay()
        MasterThief:UpdateLifetimeStatsDisplay()
    end
end

function MasterThief:TrackLaunderedGold(goldAmount)
    if not MasterThief.SessionStats or not MasterThief.SavedVarsLifetimeStats then return end
    MasterThief.SessionStats.goldSpentLaundering = (MasterThief.SessionStats.goldSpentLaundering or 0) + goldAmount
    MasterThief.SavedVarsLifetimeStats.goldSpentLaundering = (MasterThief.SavedVarsLifetimeStats.goldSpentLaundering or 0) + goldAmount
    if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
        MasterThief:UpdateSessionStatsDisplay()
        MasterThief:UpdateLifetimeStatsDisplay()
    end
end
----------------------------------------
-- Tracking Functions - Lockpicking
----------------------------------------
function MasterThief:TrackDoorLockpicked()
    if not MasterThief.SessionStats or not MasterThief.SavedVarsLifetimeStats then return end
    MasterThief.SessionStats.doorsLockpicked = MasterThief.SessionStats.doorsLockpicked + 1
    MasterThief.SavedVarsLifetimeStats.doorsLockpicked = MasterThief.SavedVarsLifetimeStats.doorsLockpicked + 1
    if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
        MasterThief:UpdateSessionStatsDisplay()
        MasterThief:UpdateLifetimeStatsDisplay()
    end
end

function MasterThief:TrackSafeboxLockpicked()
    if not MasterThief.SessionStats or not MasterThief.SavedVarsLifetimeStats then return end
    MasterThief.SessionStats.safeboxesLockpicked = MasterThief.SessionStats.safeboxesLockpicked + 1
    MasterThief.SavedVarsLifetimeStats.safeboxesLockpicked = MasterThief.SavedVarsLifetimeStats.safeboxesLockpicked + 1
    if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
        MasterThief:UpdateSessionStatsDisplay()
        MasterThief:UpdateLifetimeStatsDisplay()
    end
end

----------------------------------------
-- Tracking Functions - Combat & Justice
----------------------------------------
function MasterThief:TrackDeathByGuards()
    
    if not MasterThief.SessionStats or not MasterThief.SavedVarsLifetimeStats then 
        return 
    end
    
    MasterThief.SessionStats.deathsByGuards = MasterThief.SessionStats.deathsByGuards + 1
    MasterThief.SavedVarsLifetimeStats.deathsByGuards = MasterThief.SavedVarsLifetimeStats.deathsByGuards + 1
    
    if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
        MasterThief:UpdateSessionStatsDisplay()
        MasterThief:UpdateLifetimeStatsDisplay()
    end
end

function MasterThief:BountyChanged(bounty, previousBounty)   
    -- Track highest bounty
    if bounty > MasterThief.SessionStats.highestBounty then
        MasterThief.SessionStats.highestBounty = bounty
    end
    
    if bounty > MasterThief.SavedVarsLifetimeStats.highestBounty then
        MasterThief.SavedVarsLifetimeStats.highestBounty = bounty
    end
    
    -- Refresh stats display if bounty increased
    if bounty > previousBounty then
        if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
            MasterThief:UpdateSessionStatsDisplay()
            MasterThief:UpdateLifetimeStatsDisplay()
        end
    end
end

function MasterThief:TrackBladeOfWoeKill()
    if not MasterThief.SessionStats or not MasterThief.SavedVarsLifetimeStats then return end
    
    MasterThief.SessionStats.bladeOfWoeKills = (MasterThief.SessionStats.bladeOfWoeKills or 0) + 1
    MasterThief.SavedVarsLifetimeStats.bladeOfWoeKills = (MasterThief.SavedVarsLifetimeStats.bladeOfWoeKills or 0) + 1
    
    if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
        MasterThief:UpdateSessionStatsDisplay()
        MasterThief:UpdateLifetimeStatsDisplay()
    end
end

----------------------------------------
-- Tracking Functions - Lockpicking (companion perk)
----------------------------------------
function MasterThief:TrackLockpickBreakPrevented()
    if not MasterThief.SessionStats or not MasterThief.SavedVarsLifetimeStats then return end
    MasterThief.SessionStats.lockpickBreaksPrevented = (MasterThief.SessionStats.lockpickBreaksPrevented or 0) + 1
    MasterThief.SavedVarsLifetimeStats.lockpickBreaksPrevented = (MasterThief.SavedVarsLifetimeStats.lockpickBreaksPrevented or 0) + 1
    if MasterThief.lootlistWindow and not MasterThief.lootlistWindow:IsHidden() then
        MasterThief:UpdateSessionStatsDisplay()
        MasterThief:UpdateLifetimeStatsDisplay()
    end
end

----------------------------------------
-- Reset Functions
----------------------------------------
function MasterThief:ResetSessionStats()
    MasterThief.SessionStats = {
        itemsLooted = 0,
        itemsSkipped = 0,
        motifsLooted = 0,
        recipesLooted = 0,
        furnishingPlansLooted = 0,
        furnishingsLooted = 0,
        edictsLooted = 0,
        researchPortfoliosLooted = 0,
        hiddenWalletsLooted = 0,
        successfulPickpockets = 0,
        deathsByGuards = 0,
        doorsLockpicked = 0,
        safeboxesLockpicked = 0,
        totalFencedGold = 0,
        goldSpentLaundering = 0,
        highestBounty = 0,
        highestValueItemLooted = { link = "", value = 0 },
        bladeOfWoeKills = 0,
		lockpickBreaksPrevented = 0,
    }
    
    self:UpdateSessionStatsDisplay()
    d("[MasterThief] Session statistics reset")
end

function MasterThief:ResetLifetimeStats()
    MasterThief.SavedVarsLifetimeStats.itemsLooted = 0
    MasterThief.SavedVarsLifetimeStats.itemsSkipped = 0
    MasterThief.SavedVarsLifetimeStats.motifsLooted = 0
    MasterThief.SavedVarsLifetimeStats.recipesLooted = 0
    MasterThief.SavedVarsLifetimeStats.furnishingPlansLooted = 0
    MasterThief.SavedVarsLifetimeStats.furnishingsLooted = 0
    MasterThief.SavedVarsLifetimeStats.edictsLooted = 0
    MasterThief.SavedVarsLifetimeStats.researchPortfoliosLooted = 0
    MasterThief.SavedVarsLifetimeStats.hiddenWalletsLooted = 0
    MasterThief.SavedVarsLifetimeStats.successfulPickpockets = 0
    MasterThief.SavedVarsLifetimeStats.deathsByGuards = 0
    MasterThief.SavedVarsLifetimeStats.doorsLockpicked = 0
    MasterThief.SavedVarsLifetimeStats.safeboxesLockpicked = 0
    MasterThief.SavedVarsLifetimeStats.totalFencedGold = 0
    MasterThief.SavedVarsLifetimeStats.goldSpentLaundering = 0
    MasterThief.SavedVarsLifetimeStats.highestBounty = 0
    MasterThief.SavedVarsLifetimeStats.highestValueItemLooted = { link = "", value = 0 }
    MasterThief.SavedVarsLifetimeStats.thievesTrovesLooted = 0
    MasterThief.SavedVarsLifetimeStats.bladeOfWoeKills = 0
	MasterThief.SavedVarsLifetimeStats.lockpickBreaksPrevented = 0
    
    self:UpdateLifetimeStatsDisplay()
    d("[MasterThief] Lifetime statistics reset")
end