-- XP Bonus Tracker Addon
-- Displays total experience bonus from gear, scrolls, and other buffs

XPBonusTracker = {}
XPBonusTracker.name = "XPBonusTracker"

-- Default settings
local defaults = {
    anchorPoint = TOPLEFT,
    anchorRelativePoint = TOPLEFT,
    positionX = 0,
    positionY = 150,
    locked = false,
    visible = true
}

-- Initialize the addon
function XPBonusTracker:Initialize()
    self.savedVariables = ZO_SavedVars:NewAccountWide("XPBonusTrackerSavedVars", 1, nil, defaults)
    
    -- Set up UI references with error checking
    self.ui = XPBonusTrackerUI
    self.percentageLabel = XPBonusTrackerUIPercentage
    
    if not self.ui then
        return
    end
    
    -- Restore position
    self.ui:ClearAnchors()
    self.ui:SetAnchor(
        self.savedVariables.anchorPoint or TOPLEFT,
        GuiRoot,
        self.savedVariables.anchorRelativePoint or TOPLEFT,
        self.savedVariables.positionX,
        self.savedVariables.positionY
    )
    
    -- Set movability
    self.ui:SetMovable(not self.savedVariables.locked)
    
    -- Set visibility
    self.ui:SetHidden(not self.savedVariables.visible)
    
    -- Make sure it's on top
    self.ui:BringWindowToTop()
    
    -- Register for events
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() self:Update() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED, function(_, change, _, _, _, _, _, _, _, _, _, _, _, unitTag)
        if unitTag == "player" then
            self:Update()
        end
    end)
    
    -- Update when gear changes or weapon bar swaps
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function() self:Update() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function() self:Update() end)
    
    -- Save position when moved
    self.ui:SetHandler("OnMoveStop", function()
        self:SavePosition()
    end)
    
    -- Initial update
    self:Update()
    
    -- Register slash commands
    SLASH_COMMANDS["/xpbonus"] = function(args)
        self:HandleSlashCommand(args)
    end
end

-- Calculate total XP bonus
function XPBonusTracker:GetTotalXPBonus()
    local totalBonus = 0
    local sources = {}
    
    -- Get bonus from buffs/effects  
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)
        
        -- Check for ANY XP bonus buffs by looking for "experience" keyword
        if buffName then
            local buffNameLower = string.lower(buffName)
            local foundBuff = false
            
            -- Mythic Aetherial Ambrosia (150%) - CHECK MOST SPECIFIC FIRST!
            if string.find(buffNameLower, "mythic") and string.find(buffNameLower, "aetherial") and string.find(buffNameLower, "ambrosia") then
                totalBonus = totalBonus + 150
                table.insert(sources, "Mythic Aetherial Ambrosia (+150%)")
                foundBuff = true
                
            -- Aetherial Ambrosia (100%)
            elseif string.find(buffNameLower, "aetherial") and string.find(buffNameLower, "ambrosia") then
                totalBonus = totalBonus + 100
                table.insert(sources, "Aetherial Ambrosia (+100%)")
                foundBuff = true
            
            -- Psijic Ambrosia (50%)
            elseif string.find(buffNameLower, "psijic") and string.find(buffNameLower, "ambrosia") then
                totalBonus = totalBonus + 50
                table.insert(sources, "Psijic Ambrosia (+50%)")
                foundBuff = true
                
            -- Crown Experience Scroll (50%)
            elseif string.find(buffNameLower, "crown") and string.find(buffNameLower, "experience") and string.find(buffNameLower, "scroll") then
                totalBonus = totalBonus + 50
                table.insert(sources, "Crown XP Scroll (+50%)")
                foundBuff = true
                
            -- Grand Gold Coast Experience Scroll (150%) - CHECK THIS FIRST!
            elseif string.find(buffNameLower, "grand") and string.find(buffNameLower, "gold coast") and string.find(buffNameLower, "experience") then
                totalBonus = totalBonus + 150
                table.insert(sources, "Grand Gold Coast XP Scroll (+150%)")
                foundBuff = true
                
            -- Major Gold Coast Experience Scroll (100%) - CHECK THIS SECOND!
            elseif string.find(buffNameLower, "major") and string.find(buffNameLower, "gold coast") and string.find(buffNameLower, "experience") then
                totalBonus = totalBonus + 100
                table.insert(sources, "Major Gold Coast XP Scroll (+100%)")
                foundBuff = true
                
            -- Gold Coast Experience Scroll (50%) - CHECK THIS LAST!
            elseif string.find(buffNameLower, "gold coast") and string.find(buffNameLower, "experience") and string.find(buffNameLower, "scroll") then
                totalBonus = totalBonus + 50
                table.insert(sources, "Gold Coast XP Scroll (+50%)")
                foundBuff = true
            end
            
            -- Generic experience buff detection - catch anything with "experience" we haven't matched
            if not foundBuff and (string.find(buffNameLower, "experience") or string.find(buffNameLower, "xp")) then
                -- Try to extract percentage from buff name if it has one
                local percent = string.match(buffName, "(%d+)%%")
                if percent then
                    totalBonus = totalBonus + tonumber(percent)
                    table.insert(sources, buffName)
                else
                    -- Unknown XP buff
                    table.insert(sources, buffName .. " (?%)")
                end
            end
        end
    end
    
    -- Check for ESO Plus bonus (10%)
    if IsESOPlusSubscriber() then
        totalBonus = totalBonus + 10
        table.insert(sources, "ESO Plus (+10%)")
    end
    
    -- Check for Training trait on equipped gear
    -- Only count ACTIVE weapon bar, not backbar
    local trainingPieces = 0
    local totalTrainingBonus = 0
    
    -- Get active weapon pair to determine which weapon bar is active
    local activeWeaponPair = GetActiveWeaponPairInfo()
    local isMainBar = (activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN or activeWeaponPair == 1)
    
    -- Scan ALL equipment slots (0-25) to make sure we don't miss anything
    for slotIndex = 0, 25 do
        local itemLink = GetItemLink(BAG_WORN, slotIndex)
        if itemLink and itemLink ~= "" then
            local traitType, traitDescription, traitSubtype = GetItemLinkTraitInfo(itemLink)
            
            -- Check if this is Training gear
            if traitType == 6 or traitType == 15 then
                local shouldCount = true
                
                -- Check if item is broken (0% durability) - broken items don't give bonuses
                local condition = GetItemCondition(BAG_WORN, slotIndex)
                if condition == 0 then
                    shouldCount = false -- Item is broken, skip it
                end
                
                -- If this is a weapon (trait=6), check if it's on the active bar
                if traitType == 6 and shouldCount then
                    -- Determine which bar this weapon belongs to based on slot
                    local isMainBarWeaponSlot = (slotIndex <= 10)
                    
                    -- Only count if weapon matches active bar
                    if isMainBar and not isMainBarWeaponSlot then
                        -- On main bar but weapon is in backbar slot - don't count
                        shouldCount = false
                    elseif not isMainBar and isMainBarWeaponSlot then
                        -- On back bar but weapon is in mainbar slot - don't count
                        shouldCount = false
                    end
                end
                
                -- Count this Training piece if we should
                if shouldCount then
                    trainingPieces = trainingPieces + 1
                    
                    local itemQuality = GetItemLinkQuality(itemLink) or 0
                    local bonusPercent = 0
                    
                    if traitType == 6 then
                        -- Weapon Training (traitType = 6)
                        local weaponType = GetItemLinkWeaponType(itemLink)
                        local is2H = (weaponType >= 3 and weaponType <= 6) or (weaponType >= 8 and weaponType <= 12)
                        
                        if is2H then
                            -- Two handed weapon table
                            if itemQuality == 5 then bonusPercent = 9
                            elseif itemQuality == 4 then bonusPercent = 8
                            elseif itemQuality == 3 then bonusPercent = 7
                            elseif itemQuality == 2 then bonusPercent = 6
                            else bonusPercent = 5 end
                        else
                            -- One handed weapon/shield table
                            if itemQuality == 5 then bonusPercent = 4.5
                            elseif itemQuality == 4 then bonusPercent = 4
                            elseif itemQuality == 3 then bonusPercent = 3.5
                            elseif itemQuality == 2 then bonusPercent = 3
                            else bonusPercent = 2.5 end
                        end
                    else
                        -- Armor Training (traitType = 15)
                        if itemQuality == 5 then bonusPercent = 11
                        elseif itemQuality == 4 then bonusPercent = 10
                        elseif itemQuality == 3 then bonusPercent = 9
                        elseif itemQuality == 2 then bonusPercent = 8
                        else bonusPercent = 7 end
                    end
                    
                    totalTrainingBonus = totalTrainingBonus + bonusPercent
                end
            end
        end
    end
    
    -- Add Training gear bonus
    if trainingPieces > 0 then
        totalBonus = totalBonus + totalTrainingBonus
        table.insert(sources, string.format("Training Gear (All Equipped) x%d (+%d%%)", trainingPieces, totalTrainingBonus))
    end
    
    -- Check for Ring of Mara (10% when grouped with spouse)
    -- This is harder to detect reliably, but we can check for the buff
    for i = 1, numBuffs do
        local buffName = GetUnitBuffInfo("player", i)
        if buffName and string.find(string.lower(buffName), "ring of mara") then
            totalBonus = totalBonus + 10
            table.insert(sources, "Ring of Mara (+10%)")
            break
        end
    end
    
    -- Check for Heartland Conqueror set bonus (Bow only, 12% XP gain)
    -- This set gives XP bonus when bow is equipped
    for i = 1, numBuffs do
        local buffName = GetUnitBuffInfo("player", i)
        if buffName and string.find(string.lower(buffName), "heartland conqueror") then
            totalBonus = totalBonus + 12
            table.insert(sources, "Heartland Conqueror (+12%)")
            break
        end
    end
    
    -- Check for Altmer racial passive "Spell Recharge" (formerly Highborn) - 1% XP gain
    -- This is a passive ability, ID 35965
    local race = GetUnitRace("player")
    if race == "High Elf" or race == "Altmer" then
        -- Check if the player has unlocked this passive
        -- The passive is always active if you're Altmer
        totalBonus = totalBonus + 1
        table.insert(sources, "Highborn (Altmer Racial) (+1%)")
    end
    
    -- Check for Votan's Archive Vision Learned stackable bonus (12% when fully stacked)
    -- This appears as a buff when you complete archive runs
    for i = 1, numBuffs do
        local buffName, _, _, _, stackCount = GetUnitBuffInfo("player", i)
        if buffName and (string.find(string.lower(buffName), "archive") or string.find(string.lower(buffName), "vision")) and 
           string.find(string.lower(buffName), "learn") then
            -- Each stack gives a percentage, cap at 12%
            local archiveBonus = math.min(stackCount or 12, 12)
            totalBonus = totalBonus + archiveBonus
            table.insert(sources, string.format("Archive Vision Learned (+%d%%)", archiveBonus))
            break
        end
    end
    
    -- Check for Mora's Whisper (0-15% XP bonus from Necrom zone)
    for i = 1, numBuffs do
        local buffName = GetUnitBuffInfo("player", i)
        if buffName and string.find(string.lower(buffName), "mora") and string.find(string.lower(buffName), "whisper") then
            -- Try to extract percentage from buff description or default to 15%
            local moraBonus = 15 -- Maximum bonus
            totalBonus = totalBonus + moraBonus
            table.insert(sources, string.format("Mora's Whisper (+%d%%)", moraBonus))
            break
        end
    end
    
    return totalBonus, sources
end

-- Update the display
function XPBonusTracker:Update()
    if not self.ui or not self.percentageLabel then
        return
    end
    
    local bonus, sources = self:GetTotalXPBonus()
    
    -- Update percentage display
    if bonus > 0 then
        self.percentageLabel:SetText(string.format("+%d%%", bonus))
        self.percentageLabel:SetColor(0, 1, 0, 1) -- Green
    else
        self.percentageLabel:SetText("+0%")
        self.percentageLabel:SetColor(0.8, 0.8, 0.8, 1) -- Gray
    end
    
    -- Make sure widget is visible and on top
    if self.savedVariables.visible then
        self.ui:SetHidden(false)
        self.ui:BringWindowToTop()
        self.ui:SetAlpha(1.0)
    end
end

-- Save current position
function XPBonusTracker:SavePosition()
    if not self.ui then 
        d("XP Bonus Tracker: ERROR - UI not found when trying to save position")
        return 
    end
    
    -- Get the widget's complete anchor information
    local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = self.ui:GetAnchor(0)
    
    if isValidAnchor then
        -- Round to integers to avoid float precision issues
        offsetX = math.floor(offsetX + 0.5)
        offsetY = math.floor(offsetY + 0.5)
        
        -- Save complete anchor info
        self.savedVariables.anchorPoint = point
        self.savedVariables.anchorRelativePoint = relativePoint
        self.savedVariables.positionX = offsetX
        self.savedVariables.positionY = offsetY
        
        d(string.format("XP Bonus Tracker: Position saved! Point=%d, RelPoint=%d, X=%d, Y=%d", 
            point, relativePoint, offsetX, offsetY))
        d("Position will be restored on next login")
    else
        d("XP Bonus Tracker: ERROR - Could not get anchor position")
    end
end

-- Handle slash commands
function XPBonusTracker:HandleSlashCommand(args)
    args = string.lower(args)
    
    if args == "lock" then
        self.savedVariables.locked = true
        self.ui:SetMovable(false)
        d("XP Bonus Tracker: UI locked")
        
    elseif args == "unlock" then
        self.savedVariables.locked = false
        self.ui:SetMovable(true)
        d("XP Bonus Tracker: UI unlocked (drag to reposition)")
        
    elseif args == "show" then
        self.savedVariables.visible = true
        self.ui:SetHidden(false)
        self:Update()
        d("XP Bonus Tracker: Shown")
        
    elseif args == "hide" then
        self.savedVariables.visible = false
        self.ui:SetHidden(true)
        d("XP Bonus Tracker: Hidden")
        
    elseif args == "toggle" or args == "" then
        self.savedVariables.visible = not self.savedVariables.visible
        self.ui:SetHidden(not self.savedVariables.visible)
        if self.savedVariables.visible then
            self:Update()
        end
        d("XP Bonus Tracker: " .. (self.savedVariables.visible and "Shown" or "Hidden"))
        
    elseif args == "refresh" then
        self:Update()
        local bonus, sources = self:GetTotalXPBonus()
        d(string.format("XP Bonus Tracker: Total +%d%%", bonus))
        
    elseif args == "reset" then
        self.savedVariables.positionX = defaults.positionX
        self.savedVariables.positionY = defaults.positionY
        self.ui:ClearAnchors()
        self.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, defaults.positionX, defaults.positionY)
        d("XP Bonus Tracker: Position reset")
        
    elseif args == "save" then
        self:SavePosition()
        d("XP Bonus Tracker: Manually saved current position")
        
    elseif args == "test" then
        d("===== XP Bonus Test =====")
        d("Scanning ALL equipped slots...")
        local foundCount = 0
        for slot = 0, 25 do
            local itemLink = GetItemLink(BAG_WORN, slot)
            if itemLink and itemLink ~= "" then
                local itemName = GetItemName(BAG_WORN, slot)
                local traitType = GetItemLinkTraitInfo(itemLink)
                local quality = GetItemLinkQuality(itemLink)
                
                if traitType == 6 or traitType == 15 then
                    foundCount = foundCount + 1
                    local qualityName = {"Normal","Fine","Superior","Epic","Legendary"}
                    d(string.format("  Slot %d: %s (trait=%d, quality=%s)", slot, itemName, traitType, qualityName[quality] or quality))
                else
                    -- Show non-training items too
                    d(string.format("  Slot %d: %s (NO TRAINING)", slot, itemName))
                end
            end
        end
        d(string.format("Total Training pieces found: %d", foundCount))
        local bonus, sources = self:GetTotalXPBonus()
        d(string.format("Total XP Bonus: +%d%%", bonus))
        d("==========================")
        
    elseif args == "debug" then
        d("===== XP Bonus Tracker Debug =====")
        d("Scanning equipped items for Training trait...")
        
        local trainingCount = 0
        local totalTrainingBonus = 0
        for slotIndex = 0, 30 do  -- Scan all slots including backbar
            local itemLink = GetItemLink(BAG_WORN, slotIndex)
            if itemLink and itemLink ~= "" then
                local itemName = GetItemName(BAG_WORN, slotIndex)
                local traitType, traitDescription, traitSubtype = GetItemLinkTraitInfo(itemLink)
                
                -- Debug: print raw values
                d(string.format("  DEBUG Slot %d: traitType=%s, traitDesc=%s", 
                    slotIndex, tostring(traitType), tostring(traitDescription)))
                
                -- Additional weapon debug
                if traitType == ITEM_TRAIT_TYPE_WEAPON_TRAINING then
                    local weaponType = GetItemLinkWeaponType(itemLink)
                    d(string.format("  WEAPON DEBUG: weaponType=%s, WEAPONTYPE_TWO_HANDED_HAMMER=%s", 
                        tostring(weaponType), tostring(WEAPONTYPE_TWO_HANDED_HAMMER)))
                end
                
                -- Check for Training: ITEM_TRAIT_TYPE_WEAPON_TRAINING = 1, ITEM_TRAIT_TYPE_ARMOR_TRAINING = 12
                local hasTraining = (traitType == ITEM_TRAIT_TYPE_WEAPON_TRAINING or traitType == ITEM_TRAIT_TYPE_ARMOR_TRAINING)
                
                if hasTraining then
                    trainingCount = trainingCount + 1
                    
                    -- Try to extract percentage from trait description
                    local bonusPercent = nil
                    if traitDescription then
                        -- Simple pattern: just find any number before %
                        local numStr = string.match(traitDescription, "([%d%.]+)%%")
                        if numStr then
                            bonusPercent = tonumber(numStr)
                            d(string.format("  Found bonus in description: %s%%", numStr))
                        else
                            d(string.format("  Could not extract percentage from: %s", traitDescription))
                        end
                    end
                    
                    -- If not found in description, calculate from item stats
                    if not bonusPercent then
                        local itemQuality = GetItemLinkQuality(itemLink) or 0
                        local itemLevel = GetItemLinkRequiredLevel(itemLink) or 1
                        local itemCP = GetItemLinkRequiredChampionPoints(itemLink) or 0
                        
                        -- Check if weapon or armor
                        local isWeapon = (traitType == ITEM_TRAIT_TYPE_WEAPON_TRAINING)
                        
                        -- Better 2H weapon detection using weapon type
                        local weaponType = GetItemLinkWeaponType(itemLink)
                        -- Fixed range: 3-6 for 2H melee (hammer is 6!), 8-12 for ranged 2H
                        local is2H = (weaponType >= 3 and weaponType <= 6) or (weaponType >= 8 and weaponType <= 12)
                        
                        d(string.format("  Item stats: quality=%d, level=%d, CP=%d, isWeapon=%s, weaponType=%s, is2H=%s", 
                            itemQuality, itemLevel, itemCP, tostring(isWeapon), tostring(weaponType), tostring(is2H)))
                        
                        local effectiveLevel = itemCP > 0 and itemCP or itemLevel
                        
                        -- Training bonus based on CP160 gear quality levels (official table values)
                        if effectiveLevel >= 160 or itemCP >= 160 then
                            if isWeapon then
                                if is2H then
                                    -- Two handed weapons (2H axes/swords/hammers, bows, staves)
                                    if itemQuality >= 5 then  -- Legendary
                                        bonusPercent = 9
                                    elseif itemQuality >= 4 then  -- Epic (Purple)
                                        bonusPercent = 8
                                    elseif itemQuality >= 3 then  -- Superior (Blue)
                                        bonusPercent = 7
                                    elseif itemQuality >= 2 then  -- Fine (Green)
                                        bonusPercent = 6
                                    else  -- Normal/White
                                        bonusPercent = 5
                                    end
                                else
                                    -- One handed weapons or shields
                                    if itemQuality >= 5 then  -- Legendary
                                        bonusPercent = 4.5
                                    elseif itemQuality >= 4 then  -- Epic (Purple)
                                        bonusPercent = 4
                                    elseif itemQuality >= 3 then  -- Superior (Blue)
                                        bonusPercent = 3.5
                                    elseif itemQuality >= 2 then  -- Fine (Green)
                                        bonusPercent = 3
                                    else  -- Normal/White
                                        bonusPercent = 2.5
                                    end
                                end
                            else
                                -- Armor Training bonuses
                                if itemQuality >= 5 then  -- Legendary
                                    bonusPercent = 11
                                elseif itemQuality >= 4 then  -- Epic (Purple)
                                    bonusPercent = 10
                                elseif itemQuality >= 3 then  -- Superior (Blue)
                                    bonusPercent = 9
                                elseif itemQuality >= 2 then  -- Fine (Green)
                                    bonusPercent = 8
                                else  -- Normal/White
                                    bonusPercent = 7
                                end
                            end
                        elseif effectiveLevel >= 100 then
                            bonusPercent = 7
                        elseif effectiveLevel >= 50 then
                            bonusPercent = 6
                        else
                            bonusPercent = 5
                        end
                    end
                    
                    local itemQuality = GetItemLinkQuality(itemLink) or 0
                    local itemCP = GetItemLinkRequiredChampionPoints(itemLink) or 0
                    local qualityNames = {"Trash", "Normal", "Fine", "Superior", "Epic", "Legendary"}
                    d(string.format("  Slot %d: %s - TRAINING (+%d%%) [CP%d %s quality=%d]", 
                        slotIndex, itemName, bonusPercent, itemCP, qualityNames[itemQuality + 1] or "Unknown", itemQuality))
                    
                    totalTrainingBonus = totalTrainingBonus + bonusPercent
                end
            end
        end
        
        d(string.format("Total Training pieces: %d (Total bonus: +%d%%)", trainingCount, totalTrainingBonus))
        
        local bonus, sources = self:GetTotalXPBonus()
        d(string.format("Total XP Bonus: +%d%%", bonus))
        if #sources > 0 then
            d("Sources: " .. table.concat(sources, ", "))
        end
        
        -- Check UI state
        d("Widget visible: " .. tostring(not self.ui:IsHidden()))
        d("Widget position: " .. tostring(self.savedVariables.positionX) .. ", " .. tostring(self.savedVariables.positionY))
        d("===================================")
        
    else
        d("XP Bonus Tracker commands:")
        d("  /xpbonus - Toggle visibility")
        d("  /xpbonus show - Show widget")
        d("  /xpbonus hide - Hide widget")
        d("  /xpbonus refresh - Force refresh display")
        d("  /xpbonus lock - Lock position")
        d("  /xpbonus unlock - Unlock position")
        d("  /xpbonus reset - Reset position")
        d("  /xpbonus debug - Show debug info")
    end
end

-- Initialize when addon loads
function XPBonusTracker.OnAddOnLoaded(event, addonName)
    if addonName == "XPBonusTracker" then
        XPBonusTracker:Initialize()
        EVENT_MANAGER:UnregisterForEvent("XPBonusTracker", EVENT_ADD_ON_LOADED)
    end
end

-- Register addon loaded event
EVENT_MANAGER:RegisterForEvent("XPBonusTracker", EVENT_ADD_ON_LOADED, XPBonusTracker.OnAddOnLoaded)
