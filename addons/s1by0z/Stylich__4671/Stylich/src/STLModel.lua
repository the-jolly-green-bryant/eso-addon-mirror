-- addon namespace (single global table, defined in STLConstants.lua)
local STLModel = Stylich.Model
local STLLang = Stylich.Lang

-- Helper
local OFMGR = ZO_OUTFIT_MANAGER
local ZOSF = zo_strformat
local MSG = STLLang.msg

-- locals
local categories = {
    -- appearance
	COLLECTIBLE_CATEGORY_TYPE_COSTUME,              -- 4
	COLLECTIBLE_CATEGORY_TYPE_POLYMORPH,            -- 12
	COLLECTIBLE_CATEGORY_TYPE_SKIN,                 -- 11
	COLLECTIBLE_CATEGORY_TYPE_PERSONALITY,          -- 9
	COLLECTIBLE_CATEGORY_TYPE_HAT,                  -- 10
	COLLECTIBLE_CATEGORY_TYPE_HAIR,                 -- 13
	COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS,    -- 14
	COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY,     -- 15
	COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY,     -- 16
	COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING,         -- 17
    COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING,         -- 18
    -- pet
	COLLECTIBLE_CATEGORY_TYPE_VANITY_PET,           -- 3
    -- mount
	COLLECTIBLE_CATEGORY_TYPE_MOUNT,                -- 2
    -- COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE          -- 24
}



--- Writes trace messages to the console
-- fmt with %d, %s,
local function trace(fmt, ...)
	if STLModel.isDebug then
		d(string.format(fmt, ...))
    end
end

-- Debug mode
STLModel.isDebug = false

-- Settings
STLModel.SavedSettings = {}
STLModel.SavedSettings.Name = 'Stylich_Settings'
STLModel.SavedSettings.Version = '1'
STLModel.SavedSettings.Defaults = {
    PlayEntranceMementos = true,
    ShowQuickBar = true,
    ShowQuickDropdown = true,
    LockQuickBar = false,
    CloseOnCombat = false,
    RevealDelay = 400,   -- default ms between the entrance memento and the look reveal (per-style override in style.RevealDelay)
    QuickBarLeft = nil,
    QuickBarTop = nil,
}
STLModel.Settings = {}

-- StyleData
--[[
    StyleData = {
        LastId = <Number of last used Id
        Styles { 
            [style id] = {
                Name = <given name>
                SortKey = <key to sort styles>
                OutfitId = <id of selected outfit>
                TitleId = <id of selected title>
                IgnoreTitle = <true: don't set title>
                Collectibles {
                    [collectible category id] = <item id>
                }
                Costume = {
                    id = ...
                    link = ...
                }
            }
        }

    }

--]]

STLModel.SavedStyles = {}
STLModel.SavedStyles.Name = 'Stylich_Styles'
STLModel.SavedStyles.Version = '1'
STLModel.SavedStyles.Defaults = {  
    LastId = 0,
    Styles = {}
}
STLModel.StyleData = {}

STLModel.CategoryInfo = {
    -- appearance
	[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = {catId = 13, desc = MSG.CATEGORY_TYPE_COSTUME, tex = "/esoui/art/treeicons/gamepad/gp_collectionicon_costumes.dds"},
	[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = {catId = 11, desc = MSG.CATEGORY_TYPE_POLYMORPH, tex = "/esoui/art/treeicons/gamepad/gp_collectionicon_polymorphs.dds"},
	[COLLECTIBLE_CATEGORY_TYPE_SKIN] = {catId = 10, desc = MSG.CATEGORY_TYPE_SKIN, tex = "/esoui/art/treeicons/gamepad/gp_collectionicon_skins.dds"},
	[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = {catId = 12, desc = MSG.CATEGORY_TYPE_PERSONALITY, tex = "/esoui/art/treeicons/gamepad/gp_collectionicon_personalities.dds"},
	[COLLECTIBLE_CATEGORY_TYPE_HAT] = {catId = 9, desc = MSG.CATEGORY_TYPE_HAT, tex = "/esoui/art/treeicons/gamepad/gp_collectionicon_hats.dds"},
	[COLLECTIBLE_CATEGORY_TYPE_HAIR] = {catId = 14, desc = MSG.CATEGORY_TYPE_HAIR, tex = "/esoui/art/treeicons/gamepad/gp_collectionicon_hair.dds"},
	[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = {catId = 15, desc = MSG.CATEGORY_TYPE_FACIAL_HAIR_HORNS, tex = "/esoui/art/treeicons/gamepad/gp_collectionicon_facialhair.dds"},
	[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = {catId = 18, desc = MSG.CATEGORY_TYPE_FACIAL_ACCESSORY, tex = "/esoui/art/treeicons/gamepad/achievement_categoryicon_champion.dds"},
	[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = {catId = 19, desc = MSG.CATEGORY_TYPE_PIERCING_JEWELRY, tex = "/esoui/art/treeicons/gamepad/gp_collectionicon_facialaccessories.dds"},
	[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = {catId = 17, desc = MSG.CATEGORY_TYPE_HEAD_MARKING, tex = "/esoui/art/treeicons/gamepad/gp_collectionicon_facialmarkings.dds"},
    [COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = {catId = 16, desc = MSG.CATEGORY_TYPE_BODY_MARKING, tex = "/esoui/art/treeicons/gamepad/gp_collectionicon_bodymarkings.dds"},
    -- pet (local)
	[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = {catId = 79, desc = MSG.CATEGORY_TYPE_VANITY_PET, tex = "/esoui/art/treeicons/gamepad/gp_store_indexicon_vanitypets.dds"},
    -- mount (horse)
    [COLLECTIBLE_CATEGORY_TYPE_MOUNT] = {catId = 70, desc = MSG.CATEGORY_TYPE_MOUNT, tex = "/esoui/art/treeicons/gamepad/gp_store_indexicon_mounts.dds"},

   -- [COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE] = ?
}

-- Weapon slots stored with a style: front bar (main+off) and back bar (main+off).
-- Each saved slot is one of three states:
--   { id = <uid>, link = <link> } -> equip this weapon
--   { id = 0, link = 0 }          -> slot was empty -> unequip
--   nil (slot/Weapons absent)     -> legacy style, don't touch weapons
local weaponSlots = {
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}


STLModel.NO_OUTFIT_ID = -1
STLModel.NO_TITLE_ID = -1
STLModel.COMPANION_KEEP = -1   -- companion: leave the current one untouched (0 = dismiss)

--- Map Category_Type_ID to Name/Index
function STLModel.ShowCategoryData()

    for i=1, #categories do
        trace("Index %d: %d", i, categories[i])
    end

    
    for categoryIndex=1, GetNumCollectibleCategories() do
         -- toplevelindex
		local name, numSubCatgories = GetCollectibleCategoryInfo(categoryIndex)

		if numSubCatgories > 0 then

            for subCategoryIndex=1, numSubCatgories do
                -- toplevelindex/subCategoryIndex
				local subCategoryName = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)

                -- toplevelindex/subCategoryIndex
				local catId = GetCollectibleCategoryId(categoryIndex, subCategoryIndex)
                local texture = GetCollectibleCategoryGamepadIcon(categoryIndex, subCategoryIndex)

				d("Cat: "..name.."/"..subCategoryName.." TopCatIndex: "..categoryIndex.." SubCatIndex: "..subCategoryIndex.." CatId: "..catId.." Texture: "..texture)
			end
		else
            local catId = GetCollectibleCategoryId(categoryIndex, nil)
            
			 d("Cat: "..name.." TopCatIndex: "..categoryIndex.." CatId: "..catId)
		end
	end

end

function STLModel.GetCategories()
    return categories
end

function STLModel.GetCatInfoByCatType (cattype)
    local cd = STLModel.CategoryInfo[cattype]

    if not cd then 
        return "Unknown Category: "..cattype, "esoui/art/buttons/decline_up.dds"
    else 
        return cd["desc"], cd["tex"]
    end
end


function STLModel.CheckConsistency()
    local styles = STLModel.StyleData.Styles

    local i = 0

    -- check if table is empty. don't use "#" because it doens't work on non-sequencial tables! 
    for _,_ in pairs(styles) do 
        i = 1
        break
    end

    if i == 0 then
        STLModel.NewStyle()
    end
end

function STLModel.GetStyleByName(name)
    local styles = STLModel.StyleData.Styles

    for _, style in pairs(styles) do 
        if style.Name == name then
            return style 
        end
    end

    return false
end

function STLModel.GetStyleById(id)
    local style = STLModel.StyleData.Styles[id]
    return style 
end

function STLModel.NewStyle()
    local style = STLModel.CreateNewStyle()
	STLModel.StoreStyle(style)
	return STLModel.StyleData.LastId
end

function STLModel.CreateNewStyle(name)
    trace("CreateNewStyle")
    local style = {}

    -- increment last id
    STLModel.StyleData.LastId = STLModel.StyleData.LastId + 1

    if not name then
        name = "New Style "..STLModel.StyleData.LastId
    end

    style.Name = name
    style.SortKey = name

    STLModel.StyleData.Styles[STLModel.StyleData.LastId] = style
    
    return style
end

function STLModel.GetCostumeFromBag(id)

    local function GetItemDataFilterComparator()
        return function(itemData)
            if itemData.itemType == ITEMTYPE_DISGUISE or itemData.itemType == ITEMTYPE_COSTUME or itemData.itemType == ITEMTYPE_TABARD then
                -- precalculate the IDString for later use
                itemData.IdStringSTL = Id64ToString(itemData.uniqueId)
                return true
            end
        end
    end

    if not id then return false end

    local itemCache = SHARED_INVENTORY:GenerateFullSlotData(GetItemDataFilterComparator(), BAG_BACKPACK)

    for _, itemData in pairs(itemCache) do 
        if id == itemData.IdStringSTL then 
            trace("Found in cache: "..itemData.name.." Bag/Slot: "..itemData.bagId.."/"..itemData.slotIndex)
            return itemData.bagId, itemData.slotIndex 
        end 
    end
    
    return false
end


function STLModel.SetCostume(costume)
    -- return true, if we must wait
    local mustWait = false

    if not costume then
        costume = { id = 0, link = 0 } 
    end

	-- anything to change?
    if Id64ToString(GetItemUniqueId(BAG_WORN, EQUIP_SLOT_COSTUME)) ~= costume.id then

        if costume.id == 0 then
            -- unequip cosutume
            if GetItemInstanceId(BAG_WORN, EQUIP_SLOT_COSTUME) then
                if GetNumBagFreeSlots(BAG_BACKPACK) > 0 then
                    trace("Unequipping slot %d", EQUIP_SLOT_COSTUME)
                    UnequipItem(EQUIP_SLOT_COSTUME)
                    mustWait = true
                else
                    local link = GetItemLink(BAG_WORN, EQUIP_SLOT_COSTUME)
                    d(ZOSF("Stylich: Not enough space in backpack for <<1>>.", link))         
                end
            else
                trace("Nothing to unequip in slot %d", EQUIP_SLOT_COSTUME)
            end
        else            
            -- find item in one of the bags
            local sourceBag, sourceBagSlot = STLModel.GetCostumeFromBag(costume.id)

            if sourceBagSlot then 
                -- equip the found item
                EquipItem(sourceBag, sourceBagSlot, EQUIP_SLOT_COSTUME)
                mustWait = true
            else
                d(ZOSF("Stylich: Costume not found: <<1>>.", costume.link)) 
            end	
        end
	end
	
	return mustWait
end

--- Finds an equippable weapon by its unique id in the backpack or worn bags.
-- @return bagId, slotIndex of the weapon, or false if not found.
function STLModel.GetWeaponFromBag(id)
    if not id then return false end

    local function comparator(itemData)
        if itemData.itemType == ITEMTYPE_WEAPON then
            -- precalculate the IDString for later use
            itemData.IdStringSTL = Id64ToString(itemData.uniqueId)
            return true
        end
    end

    local itemCache = SHARED_INVENTORY:GenerateFullSlotData(comparator, BAG_BACKPACK, BAG_WORN)

    for _, itemData in pairs(itemCache) do
        if id == itemData.IdStringSTL then
            trace("Found weapon in cache: "..itemData.name.." Bag/Slot: "..itemData.bagId.."/"..itemData.slotIndex)
            return itemData.bagId, itemData.slotIndex
        end
    end

    return false
end

--- Applies one saved weapon slot. Mirrors STLModel.SetCostume.
-- @param targetSlot one of the EQUIP_SLOT_* weapon slots
-- @param weapon saved slot data, or nil to leave the slot untouched (legacy styles)
-- @return true if an equip/unequip was triggered (caller may want to wait)
function STLModel.SetWeapon(targetSlot, weapon)
    local mustWait = false

    -- nil -> legacy style without weapon data -> don't touch this slot
    if not weapon then
        return false
    end

    -- anything to change?
    if Id64ToString(GetItemUniqueId(BAG_WORN, targetSlot)) ~= weapon.id then

        if weapon.id == 0 then
            -- slot was saved empty -> unequip whatever is worn here
            if GetItemInstanceId(BAG_WORN, targetSlot) then
                if GetNumBagFreeSlots(BAG_BACKPACK) > 0 then
                    trace("Unequipping weapon slot %d", targetSlot)
                    UnequipItem(targetSlot)
                    mustWait = true
                else
                    d(ZOSF(MSG.MSG_NO_SPACE, GetItemLink(BAG_WORN, targetSlot)))
                end
            else
                trace("Nothing to unequip in weapon slot %d", targetSlot)
            end
        else
            -- find the saved weapon in the bags and equip it
            local sourceBag, sourceBagSlot = STLModel.GetWeaponFromBag(weapon.id)

            if sourceBagSlot then
                EquipItem(sourceBag, sourceBagSlot, targetSlot)
                mustWait = true
            else
                d(ZOSF(MSG.MSG_WEAPON_NOT_FOUND, weapon.link))
            end
        end
    end

    return mustWait
end

--- Applies all saved weapon slots, one at a time.
-- Equip/unequip requests are staggered because firing all four in the same
-- frame is unreliable - typically the last bar processed (the back bar) is
-- dropped by the game. Out of combat only; legacy styles (no data) are skipped.
function STLModel.ApplyWeapons(weapons)
    if not weapons then
        return
    end

    if IsUnitInCombat("player") then
        d(MSG.MSG_COMBAT_WEAPONS)
        return
    end

    local index = 1

    local function step()
        if index > #weaponSlots then return end
        local slot = weaponSlots[index]
        index = index + 1
        STLModel.SetWeapon(slot, weapons[slot])
        -- let the game process this slot before touching the next one
        zo_callLater(step, 300)
    end

    step()
end

function STLModel.StoreStyleByName(name)
    local style = STLModel.GetStyleByName(name)
    if not style then
        style = STLModel.CreateNewStyle(name)
    end
    STLModel.StoreStyle(style)
end

function STLModel.StoreStyle(style)
    if not style then
        d("Stylich: Style not found")
        return
    end

    -- get outfit
    local ofid = OFMGR:GetEquippedOutfitIndex(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    if ofid then
        style.OutfitId = ofid;
    else
        style.OutfitId = STLModel.NO_OUTFIT_ID
    end

    -- get title
    local titleId = GetCurrentTitleIndex()
    if titleId then
        style.TitleId = titleId;
    else
        style.TitleId = STLModel.NO_TITLE_ID
    end


    -- get collectibles
    style.Collectibles = {}
    for categoryIndex = 1, #categories do
        local activeCollectible = GetActiveCollectibleByType(categories[categoryIndex], GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        style.Collectibles[categories[categoryIndex]] = activeCollectible
    end

    -- costume
    if GetItemInstanceId(BAG_WORN, EQUIP_SLOT_COSTUME) then
        style.Costume = { id = Id64ToString(GetItemUniqueId(BAG_WORN, EQUIP_SLOT_COSTUME)), link = GetItemLink(BAG_WORN, EQUIP_SLOT_COSTUME) }
    else
        style.Costume = { id = 0, link = 0 }
    end

    -- weapons (front + back bar). 0 = empty slot (will unequip on load).
    style.Weapons = {}
    for i = 1, #weaponSlots do
        local slot = weaponSlots[i]
        if GetItemInstanceId(BAG_WORN, slot) then
            style.Weapons[slot] = { id = Id64ToString(GetItemUniqueId(BAG_WORN, slot)), link = GetItemLink(BAG_WORN, slot) }
        else
            style.Weapons[slot] = { id = 0, link = 0 }
        end
    end
end

function STLModel.LoadStyleByName (name)
    local style = STLModel.GetStyleByName(name)
    STLModel.LoadStyle(style)
end

function STLModel.LoadStyleById(id)
    if not id then
        return
    end

    local style = STLModel.GetStyleById(id)
    if STLModel.LoadStyle(style) then
        -- remember the last *successfully applied* style so the quick-switcher shows it
        STLModel.Settings.LastAppliedStyle = id
    end
end


-- Applies the visual look (no memento). Called either immediately, or after the
-- entrance memento finishes (so the change is masked -> revealed, and so the game
-- doesn't block collectible swaps like personality while a memento is playing).
function STLModel.ApplyLook(style, skipPersonality, skipPhysCostume, skipCostumeColl)
    if not style then
        return
    end

    -- set outfit
    if style.OutfitId == STLModel.NO_OUTFIT_ID then
        OFMGR:UnequipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    else
        OFMGR:EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, style.OutfitId)
    end

    -- set title
    if not style.IgnoreTitle then
        if not style.TitleId or style.TitleId == STLModel.NO_TITLE_ID then
            SelectTitle(nil)
        else
            SelectTitle(style.TitleId)
        end
    end

    -- set collectibles. In the memento reveal, personality is deferred to AFTER the
    -- memento (skipPersonality), and the costume is applied BEFORE it ONLY when a costume
    -- is being equipped (skipCostumeColl) - an empty/unequip costume stays in the masked
    -- reveal here so the removal is hidden like the rest of the change.
    local collectibles = style.Collectibles or {}
    for categoryIndex = 1, #categories do
        local catType = categories[categoryIndex]
        if not ((skipPersonality and catType == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY)
             or (skipCostumeColl and catType == COLLECTIBLE_CATEGORY_TYPE_COSTUME)) then
            local collectibleId = collectibles[catType]
            local activeCollectible = GetActiveCollectibleByType(catType, GAMEPLAY_ACTOR_CATEGORY_PLAYER)

            if collectibleId ~= activeCollectible then
                -- only change if necessary
                if collectibleId == COLLECTIBLE_CATEGORY_TYPE_INVALID then
                    UseCollectible(activeCollectible, GAMEPLAY_ACTOR_CATEGORY_PLAYER)  -- un-use current
                else
                    UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
                end
            end
        end
    end

    -- set physical costume (skipped if it was already equipped first, before the memento)
    if not skipPhysCostume then
        STLModel.SetCostume(style.Costume)
    end

    -- set weapons one at a time (out of combat). Legacy styles -> skipped.
    STLModel.ApplyWeapons(style.Weapons)
end

-- applies ONE collectible category (absent = don't touch). Used to apply specific
-- categories out of band: the costume BEFORE the memento, the personality AFTER it.
function STLModel.ApplyCollectibleCategory(collectibles, catType)
    local collectibleId = collectibles[catType]
    if collectibleId == nil then return end   -- not stored -> leave as-is
    local active = GetActiveCollectibleByType(catType, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    if collectibleId ~= active then
        if collectibleId == COLLECTIBLE_CATEGORY_TYPE_INVALID then
            UseCollectible(active, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        else
            UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        end
    end
end

-- applies ONLY the personality (deferred to the end of the memento so its animation
-- doesn't conflict with the memento's).
function STLModel.ApplyPersonality(style)
    if not style then return end
    STLModel.ApplyCollectibleCategory(style.Collectibles or {}, COLLECTIBLE_CATEGORY_TYPE_PERSONALITY)
end

function STLModel.LoadStyle(style)
    if not style then
        d("Stylich: Style not found!")
        return false
    end

    local memId = style.Memento
    local hasMemento = STLModel.Settings.PlayEntranceMementos ~= false
        and memId and memId ~= 0 and IsCollectibleUnlocked(memId)

    -- If the style has an entrance memento but it can't actually fire right now
    -- (on cooldown, or otherwise unusable), change NOTHING: the look and its memento
    -- stay atomic (no half-transformation without the reveal).
    if hasMemento then
        local cooldownRemaining = GetCollectibleCooldownAndDuration(memId)
        local usable = IsCollectibleUsable(memId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        if (cooldownRemaining and cooldownRemaining > 0) or not usable then
            d(zo_strformat(MSG.MSG_MEMENTO_COOLDOWN, math.ceil((cooldownRemaining or 0) / 1000)))
            return false
        end
    end

    if hasMemento then
        -- Apply the COSTUME first (before the memento) ONLY when a costume is being
        -- EQUIPPED, so it takes precedence and the memento masks the rest. If the costume
        -- is being removed (empty) or untouched, leave it in the masked reveal below so
        -- the removal is hidden together with the rest of the change.
        local collectibles = style.Collectibles or {}
        local costumeId = collectibles[COLLECTIBLE_CATEGORY_TYPE_COSTUME]
        local settingCostumeColl = costumeId ~= nil and costumeId ~= COLLECTIBLE_CATEGORY_TYPE_INVALID
        if settingCostumeColl then
            STLModel.ApplyCollectibleCategory(collectibles, COLLECTIBLE_CATEGORY_TYPE_COSTUME)
        end
        local settingPhysCostume = style.Costume and style.Costume.id and style.Costume.id ~= 0
        if settingPhysCostume then STLModel.SetCostume(style.Costume) end

        -- Dismissing a companion has no animation -> do it up front (like the costume).
        -- Summoning has an animation, so it's deferred to the end below.
        local companionId = style.Companion
        if companionId == 0 then STLModel.ApplyCompanion(style) end

        -- Fire the memento so its animation starts and masks the character.
        UseCollectible(memId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        STLModel.lastMemento = memId   -- tracked for the quick-bar cooldown indicator
        Stylich.UI.StartCooldownWatch()   -- begin the cooldown poll (self-stops at 0)

        -- Reveal the rest of the look while masked. Personality is deferred to the end of
        -- the cooldown; a costume is skipped here only if it was equipped above.
        local delay = style.RevealDelay or STLModel.Settings.RevealDelay or 400
        zo_callLater(function() STLModel.ApplyLook(style, true, settingPhysCostume, settingCostumeColl) end, delay)

        -- Personality is an animation collectible that conflicts with the memento's
        -- animation, so defer it to the end of the memento's cooldown. The cooldown
        -- isn't readable in the same frame as the use, so read it a moment later then
        -- schedule the personality for the remaining time.
        zo_callLater(function()
            local remaining = GetCollectibleCooldownAndDuration(memId) or 0
            local persoDelay = (remaining > 0) and remaining or (delay + 1000)
            zo_callLater(function() STLModel.ApplyPersonality(style) end, persoDelay)
            -- summon the companion after the personality (staggered; summon has an animation)
            if companionId and companionId > 0 then
                zo_callLater(function() STLModel.ApplyCompanion(style) end, persoDelay + 800)
            end
        end, 200)
    else
        STLModel.ApplyLook(style)
        STLModel.ApplyCompanion(style)
    end

    return true
end

function STLModel.DeleteStyle(id)
    trace("DeleteStyle")
    if not id then
        return
    end

    local style = STLModel.GetStyleById(id)
    if not style then
        d("Stylich: Style not found. ID: "..id)
        return
    end

    trace("Delete Style "..style.Name)
    STLModel.StyleData.Styles[id] = nil
end

function STLModel.ReloadStyle(id)
    trace("ReloadStyle")
    if not id then
        return
    end
    local style = STLModel.GetStyleById(id)
    if not style then
        d("Stylich: Style not found. ID: "..id)
        return
    end

    trace("Reload Style "..style.Name)
    STLModel.StoreStyle(style)
end


--- returns a sorted list {id, name} of the player's unlocked mementos
function STLModel.GetMementosSorted()
    local list = {}
    local total = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)
    for i = 1, total do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if id and id > 0 and IsCollectibleUnlocked(id) then
            list[#list + 1] = { id = id, name = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, GetCollectibleName(id)) }
        end
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

--- assigns an entrance memento (collectibleId, or 0/nil for none) to a style
function STLModel.SetStyleMemento(styleId, collectibleId)
    local style = STLModel.GetStyleById(styleId)
    if not style then return end
    style.Memento = collectibleId or 0
end

--- returns a sorted list {id, name} of the player's unlocked companions
function STLModel.GetCompanionsSorted()
    local list = {}
    local total = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
    for i = 1, total do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_COMPANION, i)
        if id and id > 0 and IsCollectibleUnlocked(id) then
            list[#list + 1] = { id = id, name = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, GetCollectibleName(id)) }
        end
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

--- assigns a companion to a style: COMPANION_KEEP = don't touch, 0 = dismiss, id = summon
function STLModel.SetStyleCompanion(styleId, collectibleId)
    local style = STLModel.GetStyleById(styleId)
    if not style then return end
    style.Companion = collectibleId or STLModel.COMPANION_KEEP
end

--- applies the style's companion choice. COMPANION_KEEP/nil = leave the current one;
-- 0 = dismiss whatever is out; id = summon it. Fails silently if it can't right now
-- (combat, restricted zone, ...) - the game shows its own message.
function STLModel.ApplyCompanion(style)
    if not style then return end
    local id = style.Companion
    if id == nil or id == STLModel.COMPANION_KEEP then return end   -- keep / don't touch

    local active = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION, GAMEPLAY_ACTOR_CATEGORY_PLAYER)

    if id == 0 then
        -- dismiss: toggle off whatever companion is currently out
        if active and active ~= 0 then
            UseCollectible(active, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        end
        return
    end

    -- summon the chosen companion (if unlocked and not already out)
    if not IsCollectibleUnlocked(id) then return end
    if id ~= active then
        UseCollectible(id, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    end
end

--- returns a sorted list of styles
function STLModel.GetStylesSorted()
	trace('GetStylesSorted')

	--- sorts the styles according to their sortKey
	-- a style w/o sortKey will be sorted to the end of the list 
	local function StyleSortHelper(item1, item2)
		local sortKey1 = item1.sortKey
        if not sortKey1 or sortKey1 == "" then
            -- sort items w/o keys to the end
            sortKey1 = 'zzzzzzzzzzzzzzzzzzzzzzzz'
        end
        sortKey1 = sortKey1..item1.name
		
		
		local sortKey2 = item2.sortKey
		if not sortKey2 or sortKey2 == "" then
            -- sort items w/o keys to the end
			sortKey2 = 'zzzzzzzzzzzzzzzzzzzzzzzz'
		end
        sortKey2 = sortKey2..item2.name

        return (sortKey1 < sortKey2)
    end

	local styleData = {}
	
	local styles = STLModel.StyleData.Styles

	for styleId, style in pairs(styles) do 
		local data = {
			id = styleId,
			name = style.Name,
			sortKey = style.SortKey
		}
	
		table.insert(styleData, data)
	end

    -- Sort the style according to their sortkey
    table.sort(styleData, function(item1, item2) return StyleSortHelper(item1, item2) end)	

    return styleData
end

