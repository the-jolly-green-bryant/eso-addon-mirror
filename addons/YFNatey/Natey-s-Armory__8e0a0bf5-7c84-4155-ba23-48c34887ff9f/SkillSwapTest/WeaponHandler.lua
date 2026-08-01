local ADDON_NAME = "ArmoryM"



function ArmoryM:EquipCurrentBarWeaponsOnly(gearData, currentBar, sourceSlotNumber)
    -- Pass through all parameters including sourceSlotNumber
    return self:LoadCurrentBarWeaponsOnly(gearData, currentBar, sourceSlotNumber)
end

function ArmoryM:LoadCurrentBarWeaponsOnly(gearData, currentBar, sourceSlotNumber)
    local weaponsToLoad = {}

    -- Load ALL weapons regardless of current bar
    if gearData[4] then
        weaponsToLoad[4] = gearData[4]
        ArmoryM:DebugPrint("Will load FRONT MAIN: " .. GetItemLinkName(gearData[4].itemLink))
    end
    if gearData[5] then
        weaponsToLoad[5] = gearData[5]
        ArmoryM:DebugPrint("Will load FRONT OFF: " .. GetItemLinkName(gearData[5].itemLink))
    end
    if gearData[20] then
        weaponsToLoad[20] = gearData[20]
        ArmoryM:DebugPrint("Will load BACK MAIN: " .. GetItemLinkName(gearData[20].itemLink))
    end
    if gearData[21] then
        weaponsToLoad[21] = gearData[21]
        ArmoryM:DebugPrint("Will load BACK OFF: " .. GetItemLinkName(gearData[21].itemLink))
    end

    -- Count weapons to equip
    local weaponCount = 0
    for _ in pairs(weaponsToLoad) do
        weaponCount = weaponCount + 1
    end

    if weaponCount == 0 then
        ArmoryM:DebugPrint("No weapons to load")
        return
    end

    ArmoryM:DebugPrint("Equipping " .. weaponCount .. " weapons across all bars...")

    -- Equip weapons with proper delays
    local delay = 0
    for slot, itemData in pairs(weaponsToLoad) do
        delay = delay + 100

        EVENT_MANAGER:RegisterForUpdate("ArmoryM_WeaponLoad" .. slot, delay, function()
            EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponLoad" .. slot)

            local itemName = GetItemLinkName(itemData.itemLink)
            ArmoryM:DebugPrint(string.format("Equipping %s to slot %d", itemName, slot))

            -- Find the item first
            local itemLocation = self:FindItemAnywhere(itemData.uniqueId)
            if itemLocation then
                -- Check if it's already equipped correctly
                local currentEquippedId = GetItemUniqueId(BAG_WORN, slot)
                if currentEquippedId ~= itemData.uniqueId then
                    RequestEquipItem(itemLocation.bag, itemLocation.slot)
                    ArmoryM:DebugPrint(string.format("Requested equip: %s", itemName))
                else
                    ArmoryM:DebugPrint(string.format("Already equipped: %s", itemName))
                end
            else
                ArmoryM:DebugPrint(string.format("Item not found: %s (ID: %s)", itemName,
                    tostring(itemData.uniqueId)))
            end
        end)
    end

    -- Add verification after all weapons should be equipped
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_WeaponVerification", delay + 400, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponVerification")
        self:VerifyWeaponEquippingWithProgress(weaponsToLoad, currentBar, sourceSlotNumber)
    end)
end

--GHOST
function ArmoryM:SetupPersistentWeaponSwitching(gearData)
    -- Clear any existing listeners
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_WeaponLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)

    -- Store gear data persistently
    self.persistentWeaponGear = gearData
    self.weaponSwitchingActive = true
    self.loadedBars = {} -- Track which bars have been loaded

    local currentBar = GetActiveWeaponPairInfo()

    -- Mark current bar as loaded (since we just loaded it)
    self.loadedBars[currentBar] = true

    -- Check what bars have weapons
    local frontBarHasWeapons = gearData[4] or gearData[5]
    local backBarHasWeapons = gearData[20] or gearData[21]

    if not frontBarHasWeapons and not backBarHasWeapons then
        ArmoryM:DebugPrint("No weapons to load - skipping weapon system")
        self:FinishGearLoading()
        return
    end

    -- Set up PERSISTENT listener that stays active
    EVENT_MANAGER:RegisterForEvent("ArmoryM_WeaponLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
        function(eventCode, activeWeaponPair, locked)
            if not self.weaponSwitchingActive then return end

            ArmoryM:DebugPrint(string.format("Bar switch detected: %d", activeWeaponPair))

            -- Check if this bar has weapons to load
            local hasWeaponsForThisBar = false
            if activeWeaponPair == 1 then
                hasWeaponsForThisBar = frontBarHasWeapons
            elseif activeWeaponPair == 2 then
                hasWeaponsForThisBar = backBarHasWeapons
            end

            if hasWeaponsForThisBar then
                ArmoryM:DebugPrint(string.format("Loading weapons for bar %d...", activeWeaponPair))

                -- Load weapons after a short delay
                EVENT_MANAGER:RegisterForUpdate("ArmoryM_BarSwitchWeapons", 100, function()
                    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_BarSwitchWeapons")

                    -- Verify we're still on the same bar
                    if GetActiveWeaponPairInfo() == activeWeaponPair then
                        -- PASS self.currentLoadingSlot to maintain auto-retry capability
                        self:LoadCurrentBarWeaponsOnly(self.persistentWeaponGear, activeWeaponPair,
                            self.currentLoadingSlot)
                        self.loadedBars[activeWeaponPair] = true

                        ArmoryM:DebugPrint(string.format("Bar %d weapons loaded", activeWeaponPair))

                        -- Check if user has loaded all available bars
                        self:CheckIfAllBarsLoaded(frontBarHasWeapons, backBarHasWeapons)
                    else
                        ArmoryM:DebugPrint("Bar changed during weapon loading - skipping")
                    end
                end)
            else
                ArmoryM:DebugPrint(string.format("Bar %d has no weapons to load", activeWeaponPair))
            end
        end)

    -- Set up a timeout (much longer since this is persistent)
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_PersistentWeaponTimeout", 120000, function() -- 2 minutes
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_PersistentWeaponTimeout")
        if self.weaponSwitchingActive then
            ArmoryM:DebugPrint("Persistent weapon loading timeout - finishing")
            self:ClearPersistentWeaponSwitching()
            self:FinishGearLoading()
        end
    end)

    -- Show user their options
    self:ShowWeaponSwitchingStatus(frontBarHasWeapons, backBarHasWeapons, currentBar)
end

-- GHOST setuppersistenceweaponswitching never called
function ArmoryM:ShowWeaponSwitchingStatus(frontBarHasWeapons, backBarHasWeapons, currentBar)
    local pendingBars = {}
    if frontBarHasWeapons and not self.loadedBars[1] then
        table.insert(pendingBars, "front bar")
    end
    if backBarHasWeapons and not self.loadedBars[2] then
        table.insert(pendingBars, "back bar")
    end

    if #pendingBars > 0 then
        local barsText = table.concat(pendingBars, " and ")
        -- Only show the bar switch message if NOT retrying
        if not self.isRetrying then
            d(string.format("|cFFFF00Switch to %s to load remaining weapons|r", barsText))
            d("|cFFFF00Use /armfinish to complete loading early|r")
        end
    else
        -- All weapons loaded - show success message
        if not self.isRetrying then
            d("|c00FF00All weapons loaded!|r")
        end
    end
end

--GHOST
function ArmoryM:ClearPersistentWeaponSwitching()
    self.persistentWeaponGear = nil
    self.weaponSwitchingActive = false
    self.loadedBars = {}

    EVENT_MANAGER:UnregisterForEvent("ArmoryM_WeaponLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_PersistentWeaponTimeout")
    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_BarSwitchWeapons")
    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_AutoFinish")
    ArmoryM:DebugPrint("Persistent weapon switching cleared")
end

-- Set up manual weapon switching (improved)
function ArmoryM:SetupManualWeaponSwitching(gearData, originalBar)
    local otherBar = (originalBar == 1) and 2 or 1
    local otherBarName = (otherBar == 1) and "front bar" or "back bar"

    -- Clear any existing weapon load listener
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_WeaponLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)

    -- Store gear data
    self.pendingGearData = gearData
    self.originalBar = originalBar
    self.otherBar = otherBar
    self.weaponLoadActive = true

    -- Set up the listener
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_WeaponLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
        function(eventCode, activeWeaponPair, locked)
            ArmoryM:DebugPrint(string.format("Bar changed to %d (waiting for %d)", activeWeaponPair, self.otherBar))

            if activeWeaponPair == self.otherBar and self.weaponLoadActive then
                ArmoryM:DebugPrint("Correct bar switch detected - loading weapons...")

                -- Disable further switching
                self.weaponLoadActive = false

                -- Small delay to ensure bar switch is complete
                EVENT_MANAGER:RegisterForUpdate("ArmoryM_OtherBarWeapons", 100, function()
                    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_OtherBarWeapons")

                    -- Equip weapons for the new bar (PASS self.currentLoadingSlot)
                    self:EquipCurrentBarWeaponsOnly(self.pendingGearData, activeWeaponPair, self.currentLoadingSlot)

                    -- Clean up after a delay
                    EVENT_MANAGER:RegisterForUpdate("ArmoryM_CleanupWeaponLoad", 100, function()
                        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_CleanupWeaponLoad")
                        self:CleanupWeaponLoading()
                        self:FinishGearLoading()
                    end)
                end)
            end
        end)

    -- Safety timeout - clean up after 30 seconds if no bar switch
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_WeaponLoadTimeout", 30000, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponLoadTimeout")
        if self.weaponLoadActive then
            ArmoryM:DebugPrint("Weapon load timeout - cleaning up")
            self:CleanupWeaponLoading()
            self:FinishGearLoading()
        end
    end)
end

-- Set up listener to load other bar weapons when player switches
function ArmoryM:SetupWeaponLoadListener(gearData, originalBar)
    local otherBar = (originalBar == 1) and 2 or 1
    local otherBarName = (otherBar == 1) and "front bar" or "back bar"


    -- Store the gear data for the listener
    self.pendingGearData = gearData
    self.originalBar = originalBar
    self.otherBar = otherBar

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_WeaponLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
        function(eventCode, activeWeaponPair, locked)
            if activeWeaponPair == self.otherBar then
                ArmoryM:DebugPrint("Player switched bars - loading other bar weapons...")

                -- Small delay to ensure bar switch is complete
                EVENT_MANAGER:RegisterForUpdate("ArmoryM_OtherBarWeapons", 100, function()
                    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_OtherBarWeapons")
                    self:EquipCurrentBarWeapons(self.pendingGearData, activeWeaponPair)

                    -- Clean up and finish
                    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_WeaponLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
                    self.pendingGearData = nil
                    self.originalBar = nil
                    self.otherBar = nil

                    EVENT_MANAGER:RegisterForUpdate("ArmoryM_FinishAfterSwitch", 100, function()
                        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_FinishAfterSwitch")
                        self:FinishGearLoading()
                    end)
                end)
            end
        end)
end

-- Clean up weapon loading state
function ArmoryM:CleanupWeaponLoading()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_WeaponLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponLoadTimeout")

    self.pendingGearData = nil
    self.originalBar = nil
    self.otherBar = nil
    self.weaponLoadActive = false

    ArmoryM:DebugPrint("Weapon loading state cleaned up")
end

-- NOT Ghost, called by loadgear in ArmoryM.lua Robust weapon equipping with retries and verification
function ArmoryM:SmartEquipWeapons(gearData, currentBar, attempt)
    local maxAttempts = 4
    attempt = attempt or 1
    if attempt > maxAttempts then
        ArmoryM:DebugPrint("Max weapon equipping attempts reached, giving up")
        return
    end
    local weaponSlots = {}
    if currentBar == 1 then
        weaponSlots = { { 4, "Main Hand" }, { 5, "Off Hand" } }
    elseif currentBar == 2 then
        weaponSlots = { { 20, "Backup Main" }, { 21, "Backup Off" } }
    end
    ArmoryM:DebugPrint(string.format("=== WEAPON EQUIPPING ATTEMPT %d (Bar %d) ===", attempt, currentBar))
    for i, weaponInfo in ipairs(weaponSlots) do
        local slot = weaponInfo[1]
        local itemData = gearData[slot]
        if itemData and itemData.uniqueId then
            local delay = i * 100
            EVENT_MANAGER:RegisterForUpdate("ArmoryM_WeaponSmart" .. slot, delay, function()
                EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponSmart" .. slot)
                local checkBar = GetActiveWeaponPairInfo()
                if checkBar == currentBar then
                    self:EquipSingleItem(slot, itemData)
                else
                    ArmoryM:DebugPrint("Bar changed during weapon equip - skipping")
                end
            end)
        end
    end
    -- Verification after all equips
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_WeaponVerify" .. currentBar, 100, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponVerify" .. currentBar)
        self:VerifyAndFixWeapons(gearData, currentBar, attempt)
    end)
end

--NOT GHOST, called by smart equip weapons
function ArmoryM:VerifyAndFixWeapons(gearData, currentBar, attempt)
    local weaponSlots = {}
    if currentBar == 1 then
        weaponSlots = { 4, 5 }
    elseif currentBar == 2 then
        weaponSlots = { 20, 21 }
    end
    local allCorrect = true
    for _, slot in ipairs(weaponSlots) do
        local wanted = gearData[slot] and gearData[slot].uniqueId
        local actual = GetItemUniqueId(BAG_WORN, slot)
        if wanted and actual ~= wanted then
            allCorrect = false
            ArmoryM:DebugPrint(string.format("Weapon slot %d incorrect (wanted %s, got %s)", slot, tostring(wanted),
                tostring(actual)))
            if actual ~= 0 then
                RequestUnequipItem(BAG_WORN, slot)
            end
        end
    end
    if allCorrect then
        d("|c00FF00|Weapons equipped - switch bars to finish|r")

        return
    end
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_WeaponRetry" .. currentBar, 100, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponRetry" .. currentBar)
        self:LoadBuildFromSlot(self.currentLoadingSlot)
    end)
end

--=============================================================================
-- SIMPLE BAR SWITCH LISTENER GHOST
--=============================================================================
function ArmoryM:SetupSimpleBarSwitchListener(gearData, originalBar, targetBar)
    -- Clear any existing listeners
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_WeaponLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)

    -- Store minimal state
    self.pendingWeaponGear = gearData
    self.targetWeaponBar = targetBar
    self.weaponListenerActive = true

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_WeaponLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
        function(eventCode, activeWeaponPair, locked)
            if not self.weaponListenerActive then return end

            if activeWeaponPair == self.targetWeaponBar then
                ArmoryM:DebugPrint(string.format("Switched to bar %d - loading weapons", activeWeaponPair))

                -- Disable listener
                self.weaponListenerActive = false

                -- Load weapons for this bar
                EVENT_MANAGER:RegisterForUpdate("ArmoryM_DelayedWeaponLoad", 100, function()
                    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_DelayedWeaponLoad")

                    -- PASS self.currentLoadingSlot for auto-retry capability
                    self:LoadCurrentBarWeaponsOnly(self.pendingWeaponGear, activeWeaponPair, self.currentLoadingSlot)

                    -- Clean up and finish
                    EVENT_MANAGER:RegisterForUpdate("ArmoryM_CleanupWeapons", 100, function()
                        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_CleanupWeapons")
                        self:CleanupSimpleWeaponLoading()
                        self:FinishGearLoading()
                    end)
                end)
            end
        end)

    -- Timeout after 30 seconds
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_WeaponTimeout", 30000, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponTimeout")
        if self.weaponListenerActive then
            ArmoryM:DebugPrint("Weapon loading timeout")
            self:CleanupSimpleWeaponLoading()
        end
    end)
end

--=============================================================================
-- WEAPON VALIDATION - PREVENT WRONG HAND ISSUES  --GHOST
--=============================================================================
function ArmoryM:ValidateWeaponForCurrentBar(gearData, currentBar)
    -- Check for obvious weapon type mismatches
    local issues = {}

    if currentBar == 1 then
        -- Check front bar weapons
        local mainHand = gearData[4]
        local offHand = gearData[5]

        if mainHand and mainHand.weaponType == WEAPONTYPE_SHIELD then
            table.insert(issues, "Shield in main hand slot 4")
        end

        if offHand and (offHand.weaponType == WEAPONTYPE_BOW or
                offHand.weaponType == WEAPONTYPE_TWO_HANDED_SWORD) then
            table.insert(issues, "2H weapon in off hand slot 5")
        end
    elseif currentBar == 2 then
        -- Check back bar weapons
        local mainHand = gearData[20]
        local offHand = gearData[21]

        if mainHand and mainHand.weaponType == WEAPONTYPE_SHIELD then
            table.insert(issues, "Shield in main hand slot 20")
        end

        if offHand and (offHand.weaponType == WEAPONTYPE_BOW or
                offHand.weaponType == WEAPONTYPE_TWO_HANDED_SWORD) then
            table.insert(issues, "2H weapon in off hand slot 21")
        end
    end

    if #issues > 0 then
        ArmoryM:DebugPrint("Weapon validation issues found:")
        for _, issue in ipairs(issues) do
            ArmoryM:DebugPrint("  - " .. issue)
        end
        return false
    end

    return true
end

function ArmoryM:VerifyWeaponEquippingWithProgress(weaponsToLoad, expectedBar, sourceSlotNumber)
    -- Start verification phase
    self:OnVerificationStart()

    local successCount = 0
    local totalCount = 0
    local failedWeapons = {}

    for slot, itemData in pairs(weaponsToLoad) do
        totalCount = totalCount + 1
        local currentEquippedId = GetItemUniqueId(BAG_WORN, slot)

        if currentEquippedId == itemData.uniqueId then
            successCount = successCount + 1
        else
            failedWeapons[slot] = itemData
        end
    end

    if successCount == totalCount then
        ArmoryM:DebugPrint("All weapons equipped successfully!")
        d("|c00FF00All weapons equipped successfully!|r")
        self:OnLoadingComplete()
    else
        ArmoryM:DebugPrint(string.format("Only %d/%d weapons equipped correctly", successCount, totalCount))

        if sourceSlotNumber and next(failedWeapons) then
            self.isRetrying = true
            self:OnRetryStart()

            EVENT_MANAGER:RegisterForUpdate("ArmoryM_WeaponRetry", 1000, function()
                EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponRetry")
                self:LoadBuildFromSlot(sourceSlotNumber)
            end)
        else
            self:OnLoadingComplete()
        end
    end
end

function ArmoryM:VerifyAndFixWeapons(gearData, currentBar, attempt)
    local weaponSlots = {}
    if currentBar == 1 then
        weaponSlots = { 4, 5 }
    elseif currentBar == 2 then
        weaponSlots = { 20, 21 }
    end
    local allCorrect = true
    for _, slot in ipairs(weaponSlots) do
        local wanted = gearData[slot] and gearData[slot].uniqueId
        local actual = GetItemUniqueId(BAG_WORN, slot)
        if wanted and actual ~= wanted then
            allCorrect = false
            ArmoryM:DebugPrint(string.format("Weapon slot %d incorrect (wanted %s, got %s)", slot, tostring(wanted),
                tostring(actual)))
            if actual ~= 0 then
                RequestUnequipItem(BAG_WORN, slot)
            end
        end
    end
    if allCorrect then
        ArmoryM:DebugPrint("Weapons equipped correctly!")
        return
    end
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_WeaponRetry" .. currentBar, 1000, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponRetry" .. currentBar)
        self:SmartEquipWeapons(gearData, currentBar, (attempt or 1) + 1)
    end)
end

--GHOST
function ArmoryM:DebugWeaponEquipAttempt(slot, itemData, currentBar)
    local itemName = GetItemLinkName(itemData.itemLink)
    local itemLocation = self:FindItemAnywhere(itemData.uniqueId)

    ArmoryM:DebugPrint(string.format("=== WEAPON EQUIP DEBUG (Slot %d, Bar %d) ===", slot, currentBar))
    ArmoryM:DebugPrint(string.format("Item: %s", itemName))
    ArmoryM:DebugPrint(string.format("Target ID: %s", tostring(itemData.uniqueId)))
    ArmoryM:DebugPrint(string.format("Current Bar: %d", GetActiveWeaponPairInfo()))

    if itemLocation then
        ArmoryM:DebugPrint(string.format("Found in: Bag %d, Slot %d", itemLocation.bag, itemLocation.slot))

        -- Check current equipped item in target slot
        local currentEquippedId = GetItemUniqueId(BAG_WORN, slot)
        if currentEquippedId == itemData.uniqueId then
            ArmoryM:DebugPrint("✓ Already equipped correctly!")
            return true
        else
            ArmoryM:DebugPrint(string.format("Current equipped ID: %s (different)", tostring(currentEquippedId)))
            ArmoryM:DebugPrint("Attempting to equip...")
            RequestEquipItem(itemLocation.bag, itemLocation.slot)
            return true
        end
    else
        ArmoryM:DebugPrint("✗ Item not found anywhere!")
        return false
    end
end
