local ADDON_NAME = "ArmoryM"
local ADDON_VERSION = 3
ArmoryM = {}
ArmoryM.savedVars = nil


--=============================================================================
-- 1. CONFIGURATION & DEFAULTS
--=============================================================================
local defaults = {
    version = ADDON_VERSION,
    builds = {},
    slots = {},
    currentBuild = "",
    uiScale = 0.7,
    windowX = 920,
    windowY = -20,
    windowVisible = false,
    testGear = {},
    backupGear = {},
    layoutVertical = false,
    uiPinned = false,
    currentPage = 1,
    pageTitle1 = "Page 1",
    pageTitle2 = "Page 2",
    pageTitle3 = "Page 3",
    showNotifications = false,
    lastBackupTime = 0,
    backupData = {},
    savedComponents = {
        gear = false,
        skills = { [1] = false, [2] = false }
    }
}

ArmoryM.isRetrying = false
--=============================================================================
-- 1. CORE UTILITY FUNCTIONS
--=============================================================================
function ArmoryM:DebugPrint(message)
    if self.savedVars and self.savedVars.showNotifications then
        d(message)
    end
end

function ArmoryM:DebugItemLocation(uniqueId, itemLink)
    local itemName = GetItemLinkName(itemLink)

    -- Check backpack
    local backpackSize = GetBagSize(BAG_BACKPACK)
    for slot = 0, backpackSize - 1 do
        if GetItemUniqueId(BAG_BACKPACK, slot) == uniqueId then
            ArmoryM:DebugPrint(string.format("Found %s in backpack slot %d", itemName, slot))
            return { bag = BAG_BACKPACK, slot = slot }
        end
    end

    -- Check equipped items
    for slot = 0, 25 do
        if GetItemUniqueId(BAG_WORN, slot) == uniqueId then
            ArmoryM:DebugPrint(string.format("Found %s in equipped slot %d", itemName, slot))
            return { bag = BAG_WORN, slot = slot }
        end
    end

    ArmoryM:DebugPrint(string.format("Could not find %s (ID: %s) anywhere!", itemName, tostring(uniqueId)))
    return nil
end

-- Protected functions for ESO API restrictions
local function Protected(fname)
    if IsProtectedFunction(fname) then
        return function(...) return CallSecureProtected(fname, ...) end
    else
        return _G[fname]
    end
end
local SlotSkillAbilityInSlot = Protected("SlotSkillAbilityInSlot")
local ClearSlot = Protected("ClearSlot")


function ArmoryM:FindItemAnywhere(uniqueId)
    -- First check backpack
    local backpackSize = GetBagSize(BAG_BACKPACK)
    for slot = 0, backpackSize - 1 do
        if GetItemUniqueId(BAG_BACKPACK, slot) == uniqueId then
            return { bag = BAG_BACKPACK, slot = slot }
        end
    end

    -- Then check equipped items
    for slot = 0, 25 do
        if GetItemUniqueId(BAG_WORN, slot) == uniqueId then
            return { bag = BAG_WORN, slot = slot }
        end
    end

    return nil
end

function ArmoryM:GetEquipSlotName(slot)
    local slotNames = {
        [0] = "Head",
        [1] = "Neck",
        [2] = "Chest",
        [3] = "Shoulders",
        [4] = "Main Hand",
        [5] = "Off Hand",
        [6] = "Waist",
        [8] = "Legs",
        [9] = "Feet",
        [11] = "Ring 1",
        [12] = "Ring 2",
        [16] = "Hands",
        [20] = "Backup Main",
        [21] = "Backup Off"
    }
    return slotNames[slot]
end

--=============================================================================
-- 2. Progress Tracking Bar
--=============================================================================
function ArmoryM:InitializeProgressTracking()
    -- Initialize the progress tracking system
    self.gearLoadingProgress = {
        isLoading = false,
        totalItems = 0,
        completedItems = 0,
        startTime = 0,
        expectedItems = {},
        currentPhase = "",
        updateTimer = nil
    }

    ArmoryM:DebugPrint("Progress tracking initialized")
end

function ArmoryM:InitializeGearProgress(gearData)
    local progress = self.gearLoadingProgress
    progress.isLoading = true
    progress.totalItems = 0
    progress.completedItems = 0
    progress.startTime = GetTimeStamp()
    progress.expectedItems = {}
    progress.currentPhase = "Starting..."

    -- Count total items to equip
    local slots = { 0, 1, 2, 3, 4, 5, 6, 8, 9, 11, 12, 16, 20, 21 }
    for _, slot in ipairs(slots) do
        if gearData[slot] and gearData[slot].uniqueId then
            progress.totalItems = progress.totalItems + 1
            progress.expectedItems[slot] = gearData[slot].uniqueId
        end
    end

    -- Start the progress monitoring
    self:StartProgressMonitoring()
    self:UpdateGearProgress("Initializing...")
end

-- Start monitoring progress with regular updates
function ArmoryM:StartProgressMonitoring()
    -- Clear any existing timer
    if self.gearLoadingProgress.updateTimer then
        EVENT_MANAGER:UnregisterForUpdate(self.gearLoadingProgress.updateTimer)
    end

    self.gearLoadingProgress.updateTimer = "ArmoryM_ProgressMonitor"

    EVENT_MANAGER:RegisterForUpdate(self.gearLoadingProgress.updateTimer, 500, function()
        self:CheckAndUpdateProgress()
    end)
end

-- Check current progress and update display
function ArmoryM:CheckAndUpdateProgress()
    if not self.gearLoadingProgress.isLoading then
        return
    end

    local progress = self.gearLoadingProgress
    local newCompleted = 0

    -- Count currently equipped items that match our expectations
    for slot, expectedId in pairs(progress.expectedItems) do
        local currentId = GetItemUniqueId(BAG_WORN, slot)
        if currentId == expectedId then
            newCompleted = newCompleted + 1
        end
    end

    -- Update if progress changed
    if newCompleted ~= progress.completedItems then
        progress.completedItems = newCompleted
        local percent = progress.totalItems > 0 and math.floor((progress.completedItems / progress.totalItems) * 100) or
            0
        local message = string.format("%s %d/%d items (%d%%)",
            progress.currentPhase,
            progress.completedItems,
            progress.totalItems,
            percent)
        d("|c00FF8C" .. message .. "|r")
    end

    -- Check if loading is complete
    if progress.completedItems >= progress.totalItems then
        self:FinishGearProgress()
    end
end

-- Update the current phase of loading
function ArmoryM:UpdateGearProgress(phase)
    local progress = self.gearLoadingProgress
    progress.currentPhase = phase

    local percent = progress.totalItems > 0 and math.floor((progress.completedItems / progress.totalItems) * 100) or 0
    local message = string.format("%s %d/%d items (%d%%)",
        phase,
        progress.completedItems,
        progress.totalItems,
        percent)
    d("|c00FF8C" .. message .. "|r")
end

-- Mark specific items as being processed
function ArmoryM:MarkItemInProgress(slot, itemName)
    local slotName = self:GetEquipSlotName(slot) or ("slot " .. slot)
    self:UpdateGearProgress(string.format("Equipping %s to %s...", itemName, slotName))
end

-- Finish the progress tracking
function ArmoryM:FinishGearLoading()
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_UpdateAfterEquip", 500, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_UpdateAfterEquip")

        if self.UpdateSlotsDisplay then
            self:UpdateSlotsDisplay()
        end

        -- Show completion message based on retry state
        if not self.isRetrying then
            d("|c00FF00Swap complete|r")
        end

        -- Reset retry flag after completion message
        self.isRetrying = false
    end)
end

--=============================================================================
-- 3. DATA MANAGEMENT (SavedVars)
--=============================================================================
function ArmoryM:CreateBackup()
    if not self.savedVars then return end

    local currentTime = GetTimeStamp()
    if currentTime - (self.savedVars.lastBackupTime or 0) < 300 then return end

    local backup = {
        slots = {},
        builds = {},
        currentBuild = self.savedVars.currentBuild or "",
        backupTime = currentTime
    }

    if self.savedVars.slots then
        for slotNum, slotData in pairs(self.savedVars.slots) do
            if type(slotData) == "table" and slotData.name then
                backup.slots[slotNum] = {
                    name = slotData.name,
                    skills = slotData.skills or {},
                    gear = slotData.gear or {},
                    weaponConfig = slotData.weaponConfig or {}
                }
            end
        end
    end

    if self.savedVars.builds then
        for buildName, buildData in pairs(self.savedVars.builds) do
            if type(buildData) == "table" then
                backup.builds[buildName] = buildData
            end
        end
    end

    self.savedVars.backupData = backup
    self.savedVars.lastBackupTime = currentTime

    ArmoryM:DebugPrint("Backup created with " .. self:CountSlots(backup.slots) .. " slots")
end

function ArmoryM:RestoreFromBackup()
    if not self.savedVars.backupData then
        ArmoryM:DebugPrint("No backup data available")
        return false
    end

    local backup = self.savedVars.backupData
    if not backup.slots or type(backup.slots) ~= "table" then
        ArmoryM:DebugPrint("Backup data is also corrupted")
        return false
    end

    self.savedVars.slots = backup.slots
    self.savedVars.builds = backup.builds or {}
    self.savedVars.currentBuild = backup.currentBuild or ""

    ArmoryM:DebugPrint("Restored from backup (" .. self:CountSlots(backup.slots) .. " slots recovered)")
    return true
end

function ArmoryM:CountSlots(slots)
    local count = 0
    if slots then
        for _ in pairs(slots) do count = count + 1 end
    end
    return count
end

function ArmoryM:MigrateSavedVarsWithComponents(fromVersion, toVersion)
    ArmoryM:DebugPrint("Migrating SavedVars from version " .. fromVersion .. " to " .. toVersion)

    if fromVersion < 2 and toVersion >= 2 then
        if self.savedVars.slots then
            for slotNum, slotData in pairs(self.savedVars.slots) do
                if slotData and not slotData.weaponConfig then
                    slotData.weaponConfig = { frontBar1H = false, backBar1H = false }
                end
            end
        end
    end

    -- Add savedComponents tracking for existing slots
    if self.savedVars.slots then
        for slotNum, slotData in pairs(self.savedVars.slots) do
            if type(slotData) == "table" and not slotData.savedComponents then
                -- Determine what's been saved based on existing data
                local hasGear = slotData.gear and next(slotData.gear) ~= nil
                local hasSkills1 = slotData.skills and slotData.skills[1] and next(slotData.skills[1]) ~= nil
                local hasSkills2 = slotData.skills and slotData.skills[2] and next(slotData.skills[2]) ~= nil

                slotData.savedComponents = {
                    gear = hasGear,
                    skills = { [1] = hasSkills1, [2] = hasSkills2 }
                }
                ArmoryM:DebugPrint("Added component tracking to slot " .. slotNum)
            end
        end
    end
end

--=============================================================================
-- 4. SKILL SYSTEM
--=============================================================================
local function GetSkillFromAbilityId(abilityId)
    local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)

    if not hasProgression then
        ArmoryM:DebugPrint(string.format("Error: Skill %s(%d) has no progressionIndex", GetAbilityName(abilityId),
            abilityId))
        return 0, 0, 0
    end

    -- Quick path
    local t, l, a = GetSkillAbilityIndicesFromProgressionIndex(progressionIndex)
    if t > 0 then
        return t, l, a
    end

    -- Slow path - search all skills
    for t = 1, GetNumSkillTypes() do
        for l = 1, GetNumSkillLines(t) do
            for a = 1, GetNumSkillAbilities(t, l) do
                local progId = select(7, GetSkillAbilityInfo(t, l, a))
                if progId == progressionIndex then
                    return t, l, a
                end
            end
        end
    end

    ArmoryM:DebugPrint(string.format("Error: Skill %s(%d) not found", GetAbilityName(abilityId), abilityId))
    return 0, 0, 0
end

function ArmoryM:LoadSkillBar(skillBar)
    for i = 1, 6 do
        local skill = skillBar[i]
        local slot = i + 2 -- Convert to API slot (3-8)

        if type(skill) == "number" and skill > 0 then
            local t, l, idx = GetSkillFromAbilityId(skill)
            if t > 0 then
                SlotSkillAbilityInSlot(t, l, idx, slot)
            end
        elseif type(skill) == "string" then
            -- Handle crafted abilities
            local craftedAbilityId = select(2, zo_strsplit(":", skill))
            local t, l, idx = GetSkillAbilityIndicesFromCraftedAbilityId(tonumber(craftedAbilityId))
            if t > 0 then
                SlotSkillAbilityInSlot(t, l, idx, slot)
            end
        else
            ClearSlot(slot)
        end
    end
end

function ArmoryM:SaveCurrentSkillsToSlot(slotNumber, barId)
    local skills = {}
    local activeBar = GetActiveWeaponPairInfo()

    if activeBar == barId then
        for i = 3, 8 do -- API slots 3-8 = skill slots 1-6
            local slotType = GetSlotType(i)
            local abilityId = GetSlotBoundId(i)

            if slotType == ACTION_TYPE_ABILITY then
                skills[i - 2] = abilityId
            elseif slotType == ACTION_TYPE_CRAFTED_ABILITY then
                local realId = GetAbilityIdForCraftedAbilityId(abilityId)
                skills[i - 2] = string.format("C:%d:%d", abilityId, realId)
            end
        end

        self.savedVars.slots[slotNumber].skills[barId] = skills

        -- Update tracking
        if self.savedVars.slots[slotNumber].savedComponents then
            self.savedVars.slots[slotNumber].savedComponents.skills[barId] = true
        end
    else
        ArmoryM:DebugPrint(string.format("Switch to bar %d to save its skills", barId))
    end
end

function ArmoryM:LoadSkillsFromSlot(slotNumber, barId)
    local slotData = self.savedVars.slots[slotNumber]
    if not slotData or not slotData.skills[barId] then
        ArmoryM:DebugPrint(string.format("No skills saved in slot %d for bar %d", slotNumber, barId))
        return
    end
    self:LoadSkillBar(slotData.skills[barId])
end

function ArmoryM:LoadSkillsBarFromSlot(slotNumber, specificBar)
    if not self.savedVars.slots or not self.savedVars.slots[slotNumber] then
        ArmoryM:DebugPrint(string.format("Slot %d is empty!", slotNumber))
        return false
    end

    local slotData = self.savedVars.slots[slotNumber]
    local currentBar = specificBar or GetActiveWeaponPairInfo()

    -- Validate skills data
    if not slotData.skills or not slotData.skills[currentBar] or not slotData.savedComponents.skills[currentBar] then
        ArmoryM:DebugPrint(string.format("No skills saved for bar %d in slot %d", currentBar, slotNumber))
        return false
    end

    -- Clean up any existing loading processes for skills
    self:ClearAutoLoad()

    ArmoryM:DebugPrint(string.format("=== LOADING BAR %d SKILLS FROM '%s' ===", currentBar, slotData.name))

    -- Load skills for current bar
    self:LoadSkillsFromSlot(slotNumber, currentBar)

    return true
end

--=============================================================================
-- 5. GEAR SYSTEM (ARMOR & JEWELRY ONLY)
--=============================================================================
-- Patch LoadGear to use SmartEquipWeapons
function ArmoryM:LoadGear(gearData)
    if not gearData then
        ArmoryM:DebugPrint("No gear data to load")
        return
    end
    ArmoryM:DebugPrint("Loading gear with robust weapon handling...")
    local currentBar = GetActiveWeaponPairInfo()
    local hasFrontBarWeapons = gearData[4] or gearData[5]
    local hasBackBarWeapons = gearData[20] or gearData[21]

    -- START PHASE 2: ARMOR
    if not self.isRetrying then
        self:OnArmorStart()
    end

    local armorOnly = {
        { 0, "Head" }, { 2, "Chest" }, { 3, "Shoulders" }, { 6, "Waist" },
        { 8, "Legs" }, { 9, "Feet" }, { 16, "Hands" }, { 1, "Neck" }, { 4, "fb" }, { 5, "moh" }, { 20, "bbf" }, { 21, "bbo" }
    }
    local armorCount = 0
    local totalArmor = 0

    -- Count total armor pieces
    for _, slotInfo in ipairs(armorOnly) do
        local slot = slotInfo[1]
        if gearData[slot] and gearData[slot].uniqueId then
            totalArmor = totalArmor + 1
        end
    end

    for i, slotInfo in ipairs(armorOnly) do
        local slot = slotInfo[1]
        local itemData = gearData[slot]
        if itemData and itemData.uniqueId then
            local delay = i * 80 + 200
            EVENT_MANAGER:RegisterForUpdate("ArmoryM_Armor" .. slot, delay, function()
                EVENT_MANAGER:UnregisterForUpdate("ArmoryM_Armor" .. slot)
                self:EquipSingleItem(slot, itemData)

                -- UPDATE ARMOR PROGRESS
                armorCount = armorCount + 1
                if not self.isRetrying then
                    self:OnArmorProgress(armorCount, totalArmor)
                end
            end)
        end
    end

    local armorDelay = #armorOnly * 10 + 100
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_CurrentBarWeapons", armorDelay, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_CurrentBarWeapons")

        -- COMPLETE ARMOR PHASE
        if not self.isRetrying then
            self:OnArmorComplete()
            self:OnWeaponStart()
        end

        if currentBar == 1 and hasFrontBarWeapons then
            self:SmartEquipWeapons(gearData, 1)
        elseif currentBar == 2 and hasBackBarWeapons then
            self:SmartEquipWeapons(gearData, 2)
        end

        -- COMPLETE WEAPON PHASE
        if not self.isRetrying then
            EVENT_MANAGER:RegisterForUpdate("ArmoryM_WeaponComplete", 1000, function()
                EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponComplete")
                self:OnWeaponComplete()
            end)
        end

        EVENT_MANAGER:RegisterForUpdate("ArmoryM_JewelryLoad", 600, function()
            EVENT_MANAGER:UnregisterForUpdate("ArmoryM_JewelryLoad")
            self:LoadJewelryWithConflictResolution(gearData)
        end)

        -- Determine if other bar needs weapons
        local needsOtherBar = false
        if currentBar == 1 and hasBackBarWeapons then
            needsOtherBar = true
        elseif currentBar == 2 and hasFrontBarWeapons then
            needsOtherBar = true
        end

        if needsOtherBar then
            EVENT_MANAGER:RegisterForUpdate("ArmoryM_WeaponSwitchSetup", 2000, function()
                EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponSwitchSetup")
                self:SetupManualWeaponSwitching(gearData, currentBar)
            end)
        else
            EVENT_MANAGER:RegisterForUpdate("ArmoryM_FinishAfterJewelry", 2000, function()
                EVENT_MANAGER:UnregisterForUpdate("ArmoryM_FinishAfterJewelry")
                self:FinishGearLoading()
            end)
        end
    end)
end

function ArmoryM:UnequipAllIncludingWeapons()
    ArmoryM:DebugPrint("Unequipping all items including weapons")
    local slotsToUnequip = { 0, 1, 2, 3, 4, 5, 6, 8, 9, 11, 12, 16, 20, 21 }

    for _, slot in ipairs(slotsToUnequip) do
        local itemLink = GetItemLink(BAG_WORN, slot)
        if itemLink and itemLink ~= "" then
            local itemName = GetItemLinkName(itemLink)
            local slotName = self:GetEquipSlotName(slot) or ("slot " .. slot)
            ArmoryM:DebugPrint(string.format("Unequipping %s from %s", itemName, slotName))
            RequestUnequipItem(BAG_WORN, slot)
        else
            local slotName = self:GetEquipSlotName(slot) or ("slot " .. slot)
            ArmoryM:DebugPrint(string.format("%s is already empty", slotName))
        end
    end
end

function ArmoryM:EquipSingleItem(slot, itemData)
    if not itemData or not itemData.uniqueId then return false end

    -- Check if already equipped correctly
    local currentEquippedId = GetItemUniqueId(BAG_WORN, slot)
    if currentEquippedId == itemData.uniqueId then
        return true
    end

    -- Find and equip the item
    local itemLocation = self:FindItemAnywhere(itemData.uniqueId)
    if itemLocation then
        local itemName = GetItemLinkName(itemData.itemLink)

        -- Update progress display
        if self.gearLoadingProgress.isLoading then
            self:MarkItemInProgress(slot, itemName)
        end

        local slotName = self:GetEquipSlotName(slot) or ("slot " .. slot)
        ArmoryM:DebugPrint(string.format("Equipping %s to %s", itemName, slotName)) -- This is slow
        RequestEquipItem(itemLocation.bag, itemLocation.slot)
        return true
    else
        local itemName = GetItemLinkName(itemData.itemLink)
        ArmoryM:DebugPrint(string.format("Item not found: %s for slot %d", itemName, slot))
        return false
    end
end

function ArmoryM:UnequipGearJewelry()
    ArmoryM:DebugPrint("Unequipping gear and jewelry")
    local slotsToUnequip = { 11, 12 }

    for _, slot in ipairs(slotsToUnequip) do
        local itemLink = GetItemLink(BAG_WORN, slot)
        if itemLink and itemLink ~= "" then
            local itemName = GetItemLinkName(itemLink)
            ArmoryM:DebugPrint(string.format("Unequipping %s from %s", itemName, self:GetEquipSlotName(slot)))
            RequestUnequipItem(BAG_WORN, slot)
        end
    end
end

function ArmoryM:CheckIfAllBarsLoaded(frontBarHasWeapons, backBarHasWeapons)
    local allLoaded = true
    if frontBarHasWeapons and not self.loadedBars[1] then
        allLoaded = false
    end
    if backBarHasWeapons and not self.loadedBars[2] then
        allLoaded = false
    end

    if allLoaded then
        ArmoryM:DebugPrint("All available weapon bars have been loaded!")
        self:ClearPersistentWeaponSwitching()
        self:FinishGearLoading()
    else
        local pendingBars = {}
        if frontBarHasWeapons and not self.loadedBars[1] then
            table.insert(pendingBars, "front bar")
        end
        if backBarHasWeapons and not self.loadedBars[2] then
            table.insert(pendingBars, "back bar")
        end

        if #pendingBars > 0 then
            local barsText = table.concat(pendingBars, " and ")
            ArmoryM:DebugPrint(string.format("Still need to load: %s", barsText))

            -- Only show user message if not retrying
            if not self.isRetrying then
                d(string.format("|cFFFF00Switch to %s to complete loading|r", barsText))
            end
        end
    end
end

function ArmoryM:LoadAllSkillsFromSlot(slotNumber)
    if not self.savedVars.slots or not self.savedVars.slots[slotNumber] then
        ArmoryM:DebugPrint(string.format("Slot %d is empty!", slotNumber))
        return false
    end

    local slotData = self.savedVars.slots[slotNumber]
    local currentBar = GetActiveWeaponPairInfo()

    -- Validate at least one bar has skills
    if not slotData.savedComponents.skills[1] and not slotData.savedComponents.skills[2] then
        ArmoryM:DebugPrint("No skills saved in slot " .. slotNumber)
        return false
    end

    -- Clean up any existing loading processes
    self:ClearAutoLoad()

    ArmoryM:DebugPrint(string.format("=== LOADING SKILLS FROM '%s' ===", slotData.name))

    -- Load skills for current bar first if available
    if slotData.savedComponents.skills[currentBar] then
        self:LoadSkillsFromSlot(slotNumber, currentBar)
    end

    -- Set up auto-load for other bar if available
    local otherBar = (currentBar == 1) and 2 or 1
    if slotData.savedComponents.skills[otherBar] then
        self:SetupAutoLoadForSlot(slotNumber, currentBar)
    end

    return true
end

function ArmoryM:LoadGearFromSlot(slotNumber)
    if not self.savedVars.slots or not self.savedVars.slots[slotNumber] then
        ArmoryM:DebugPrint(string.format("Slot %d is empty!", slotNumber))
        return false
    end

    local slotData = self.savedVars.slots[slotNumber]

    -- Validate gear data
    if not slotData.gear or not slotData.savedComponents.gear then
        ArmoryM:DebugPrint("No gear saved in slot " .. slotNumber)
        return false
    end

    -- Clean up any existing loading processes
    self:ClearAutoLoad()

    ArmoryM:DebugPrint(string.format("=== LOADING GEAR FROM '%s' ===", slotData.name))



    -- Wait then load gear
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_LoadGear", 100, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_LoadGear")
        self:LoadGear(slotData.gear)
    end)

    return true
end

function ArmoryM:SaveCurrentGear()
    local gear = {}
    -- Save all armor, jewelry, and weapon slots
    local gearSlots = { 0, 1, 2, 3, 4, 5, 6, 8, 9, 11, 12, 16, 20, 21 }
    for _, slot in ipairs(gearSlots) do
        local itemLink = GetItemLink(BAG_WORN, slot)
        if itemLink and itemLink ~= "" then
            gear[slot] = {
                itemLink = itemLink,
                uniqueId = GetItemUniqueId(BAG_WORN, slot),
                weaponType = GetItemWeaponType(BAG_WORN, slot)
            }
        end
    end
    return gear
end

--=============================================================================
-- 6. RING VERIFICATION
--=============================================================================
function ArmoryM:LoadJewelryWithConflictResolution(gearData)
    -- Get the rings we need to equip
    local ring1Data = gearData[11] -- Target Ring 1 slot
    local ring2Data = gearData[12] -- Target Ring 2 slot

    ArmoryM:DebugPrint("=== JEWELRY LOADING WITH ID VERIFICATION ===")
    if ring1Data then
        ArmoryM:DebugPrint(string.format("Build wants Ring 1: %s (ID: %s)", GetItemLinkName(ring1Data.itemLink),
            tostring(ring1Data.uniqueId)))
    else
        ArmoryM:DebugPrint("Build wants Ring 1: EMPTY")
    end

    if ring2Data then
        ArmoryM:DebugPrint(string.format("Build wants Ring 2: %s (ID: %s)", GetItemLinkName(ring2Data.itemLink),
            tostring(ring2Data.uniqueId)))
    else
        ArmoryM:DebugPrint("Build wants Ring 2: EMPTY")
    end

    -- Check what's currently equipped
    local currentRing1 = GetItemLink(BAG_WORN, 11)
    local currentRing2 = GetItemLink(BAG_WORN, 12)

    if currentRing1 and currentRing1 ~= "" then
        ArmoryM:DebugPrint(string.format("Currently in Ring 1: %s (ID: %s)", GetItemLinkName(currentRing1),
            tostring(GetItemUniqueId(BAG_WORN, 11))))
    else
        ArmoryM:DebugPrint("Currently in Ring 1: EMPTY")
    end

    if currentRing2 and currentRing2 ~= "" then
        ArmoryM:DebugPrint(string.format("Currently in Ring 2: %s (ID: %s)", GetItemLinkName(currentRing2),
            tostring(GetItemUniqueId(BAG_WORN, 12))))
    else
        ArmoryM:DebugPrint("Currently in Ring 2: EMPTY")
    end

    -- Wait for unequip to complete, then start smart equipping
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_JewelryLoad", 1000, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_JewelryLoad")

        -- Start the smart equipping process
        self:SmartEquipRings(ring1Data, ring2Data, 1) -- Start with attempt 1

        ArmoryM:DebugPrint("=== JEWELRY LOADING INITIATED ===")
    end)
end

function ArmoryM:SmartEquipRings(ring1Data, ring2Data, attempt)
    local maxAttempts = 3

    if attempt > maxAttempts then
        ArmoryM:DebugPrint("Max ring equipping attempts reached, giving up")
        return
    end

    ArmoryM:DebugPrint(string.format("=== RING EQUIPPING ATTEMPT %d ===", attempt))

    -- Equip Ring 1 first if we have it
    if ring1Data then
        ArmoryM:DebugPrint(string.format("Attempting to equip Ring 1: %s", GetItemLinkName(ring1Data.itemLink)))
        self:EquipSingleItem(11, ring1Data)
    end

    -- Wait a moment then equip Ring 2
    if ring2Data then
        EVENT_MANAGER:RegisterForUpdate("ArmoryM_Ring2Equip", 200, function()
            EVENT_MANAGER:UnregisterForUpdate("ArmoryM_Ring2Equip")
            ArmoryM:DebugPrint(string.format("Attempting to equip Ring 2: %s", GetItemLinkName(ring2Data.itemLink)))
            self:EquipSingleItem(12, ring2Data)

            -- Wait then verify the results
            EVENT_MANAGER:RegisterForUpdate("ArmoryM_RingVerify", 200, function()
                EVENT_MANAGER:UnregisterForUpdate("ArmoryM_RingVerify")
                self:VerifyAndFixRings(ring1Data, ring2Data, attempt)
            end)
        end)
    else
        -- Only Ring 1 to equip, verify after a delay
        EVENT_MANAGER:RegisterForUpdate("ArmoryM_Ring1Verify", 200, function()
            EVENT_MANAGER:UnregisterForUpdate("ArmoryM_Ring1Verify")
            self:VerifyAndFixRings(ring1Data, ring2Data, attempt)
        end)
    end
end

function ArmoryM:VerifyAndFixRings(ring1Data, ring2Data, attempt)
    ArmoryM:DebugPrint("=== VERIFYING RING PLACEMENT ===")

    -- Check what's actually equipped
    local actualRing1Id = GetItemUniqueId(BAG_WORN, 11)
    local actualRing2Id = GetItemUniqueId(BAG_WORN, 12)

    -- Check what we wanted
    local wantedRing1Id = ring1Data and ring1Data.uniqueId
    local wantedRing2Id = ring2Data and ring2Data.uniqueId

    -- Verify Ring 1
    local ring1Correct = (not wantedRing1Id and actualRing1Id == 0) or (actualRing1Id == wantedRing1Id)
    local ring2Correct = (not wantedRing2Id and actualRing2Id == 0) or (actualRing2Id == wantedRing2Id)

    if actualRing1Id and actualRing1Id ~= 0 then
        local ring1Name = GetItemLinkName(GetItemLink(BAG_WORN, 11))
        ArmoryM:DebugPrint(string.format("Ring 1 slot has: %s (ID: %s) - %s", ring1Name, tostring(actualRing1Id),
            ring1Correct and "CORRECT" or "WRONG"))
    else
        ArmoryM:DebugPrint(string.format("Ring 1 slot: EMPTY - %s", ring1Correct and "CORRECT" or "WRONG"))
    end

    if actualRing2Id and actualRing2Id ~= 0 then
        local ring2Name = GetItemLinkName(GetItemLink(BAG_WORN, 12))
        ArmoryM:DebugPrint(string.format("Ring 2 slot has: %s (ID: %s) - %s", ring2Name, tostring(actualRing2Id),
            ring2Correct and "CORRECT" or "WRONG"))
    else
        ArmoryM:DebugPrint(string.format("Ring 2 slot: EMPTY - %s", ring2Correct and "CORRECT" or "WRONG"))
    end

    -- Show progress for rings
    local gearData = {}
    gearData[11] = ring1Data
    gearData[12] = ring2Data


    -- If both are correct, we're done
    if ring1Correct and ring2Correct then
        ArmoryM:DebugPrint("Safe to swap bars")
        return
    end

    -- Something is wrong, try to fix it
    ArmoryM:DebugPrint("Ring placement incorrect, attempting to fix...")

    -- Check if rings are swapped
    local ring1InSlot2 = wantedRing1Id and (actualRing2Id == wantedRing1Id)
    local ring2InSlot1 = wantedRing2Id and (actualRing1Id == wantedRing2Id)

    if ring1InSlot2 and ring2InSlot1 then
        ArmoryM:DebugPrint("Rings are swapped, performing swap fix...")
        self:FixSwappedRings(ring1Data, ring2Data)
        return
    end

    -- Individual ring fixes
    if not ring1Correct then
        ArmoryM:DebugPrint("Fixing Ring 1 placement...")
        if actualRing1Id ~= 0 then
            RequestUnequipItem(BAG_WORN, 11) -- Remove wrong ring
        end
        if wantedRing1Id and actualRing2Id == wantedRing1Id then
            RequestUnequipItem(BAG_WORN, 12) -- Remove from wrong slot
        end
    end

    if not ring2Correct then
        ArmoryM:DebugPrint("Fixing Ring 2 placement...")
        if actualRing2Id ~= 0 then
            RequestUnequipItem(BAG_WORN, 12) -- Remove wrong ring
        end
        if wantedRing2Id and actualRing1Id == wantedRing2Id then
            RequestUnequipItem(BAG_WORN, 11) -- Remove from wrong slot
        end
    end

    -- Retry after unequipping
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_RetryRings", 300, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_RetryRings")
        self:SmartEquipRings(ring1Data, ring2Data, attempt + 1)
    end)
end

function ArmoryM:FixSwappedRings(ring1Data, ring2Data)
    ArmoryM:DebugPrint("Performing ring swap fix...")

    -- Unequip both rings
    RequestUnequipItem(BAG_WORN, 11)
    RequestUnequipItem(BAG_WORN, 12)

    -- Wait then re-equip correctly
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_SwapFix", 300, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_SwapFix")

        if ring1Data then
            self:EquipSingleItem(11, ring1Data)
        end

        if ring2Data then
            EVENT_MANAGER:RegisterForUpdate("ArmoryM_SwapFix2", 400, function()
                EVENT_MANAGER:UnregisterForUpdate("ArmoryM_SwapFix2")
                self:EquipSingleItem(12, ring2Data)

                -- Final verification
                EVENT_MANAGER:RegisterForUpdate("ArmoryM_SwapVerify", 300, function()
                    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_SwapVerify")
                    ArmoryM:DebugPrint("Swap fix complete, verifying...")

                    local finalRing1 = GetItemUniqueId(BAG_WORN, 11)
                    local finalRing2 = GetItemUniqueId(BAG_WORN, 12)
                    local ring1Ok = (not ring1Data) or (finalRing1 == ring1Data.uniqueId)
                    local ring2Ok = (not ring2Data) or (finalRing2 == ring2Data.uniqueId)

                    if ring1Ok and ring2Ok then
                        ArmoryM:DebugPrint("✓ Ring swap fix successful!")
                    else
                        ArmoryM:DebugPrint("✗ Ring swap fix failed, manual intervention needed")
                    end
                end)
            end)
        end
    end)
end

function ArmoryM:LoadRingsWithSwapHandling(ring1Data, ring2Data)
    -- Get currently equipped rings
    local currentRing1Id = GetItemUniqueId(BAG_WORN, 11)
    local currentRing2Id = GetItemUniqueId(BAG_WORN, 12)

    -- Track what we want to equip
    local targetRing1Id = ring1Data and ring1Data.uniqueId
    local targetRing2Id = ring2Data and ring2Data.uniqueId

    ArmoryM:DebugPrint(string.format("Ring loading: Target Ring1=%s, Target Ring2=%s",
        targetRing1Id and GetItemLinkName(ring1Data.itemLink) or "none",
        targetRing2Id and GetItemLinkName(ring2Data.itemLink) or "none"))

    -- Check if rings are already correctly equipped
    local ring1Correct = (not targetRing1Id) or (currentRing1Id == targetRing1Id)
    local ring2Correct = (not targetRing2Id) or (currentRing2Id == targetRing2Id)

    if ring1Correct and ring2Correct then
        ArmoryM:DebugPrint("Rings already correctly equipped")
        return
    end

    -- Check for cross-equipped rings (ring1 target is in slot 12, ring2 target is in slot 11)
    local ring1InSlot2 = targetRing1Id and (currentRing2Id == targetRing1Id)
    local ring2InSlot1 = targetRing2Id and (currentRing1Id == targetRing2Id)

    if ring1InSlot2 and ring2InSlot1 then
        -- Rings are perfectly swapped - we need to swap them
        ArmoryM:DebugPrint("Rings are swapped, performing ring swap...")
        self:SwapEquippedRings()
        return
    end

    -- Handle individual ring conflicts with proper sequencing
    local equipmentQueue = {}

    -- Check if we need to unequip anything first to avoid conflicts
    if targetRing1Id and currentRing2Id == targetRing1Id then
        -- Ring 1 target is in Ring 2 slot, need to unequip it first
        ArmoryM:DebugPrint("Ring 1 target is in Ring 2 slot, unequipping first...")
        RequestUnequipItem(BAG_WORN, 12)
        table.insert(equipmentQueue, { ring1Data, 11, 800 })
    elseif targetRing1Id and not ring1Correct then
        table.insert(equipmentQueue, { ring1Data, 11, 200 })
    end

    if targetRing2Id and currentRing1Id == targetRing2Id then
        -- Ring 2 target is in Ring 1 slot, need to unequip it first
        ArmoryM:DebugPrint("Ring 2 target is in Ring 1 slot, unequipping first...")
        RequestUnequipItem(BAG_WORN, 11)
        table.insert(equipmentQueue, { ring2Data, 12, 1000 })
    elseif targetRing2Id and not ring2Correct then
        table.insert(equipmentQueue, { ring2Data, 12, 400 })
    end

    -- Execute the equipment queue with delays
    for i, equipment in ipairs(equipmentQueue) do
        local itemData, slot, delay = equipment[1], equipment[2], equipment[3]
        EVENT_MANAGER:RegisterForUpdate("ArmoryM_RingQueue" .. i, delay, function()
            EVENT_MANAGER:UnregisterForUpdate("ArmoryM_RingQueue" .. i)
            self:EquipSingleItem(slot, itemData)
        end)
    end
end

function ArmoryM:SwapEquippedRings()
    -- Get the rings that are currently equipped (but in wrong slots)
    local ring1Data = {
        itemLink = GetItemLink(BAG_WORN, 12),
        uniqueId = GetItemUniqueId(BAG_WORN, 12)
    }
    local ring2Data = {
        itemLink = GetItemLink(BAG_WORN, 11),
        uniqueId = GetItemUniqueId(BAG_WORN, 11)
    }

    -- Unequip both rings
    RequestUnequipItem(BAG_WORN, 11) -- Ring 1 slot
    RequestUnequipItem(BAG_WORN, 12) -- Ring 2 slot

    -- Wait then re-equip them in correct positions
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_SwapRing1", 800, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_SwapRing1")
        if ring1Data.uniqueId and ring1Data.uniqueId ~= 0 then
            self:EquipSingleItem(11, ring1Data)
        end
    end)

    EVENT_MANAGER:RegisterForUpdate("ArmoryM_SwapRing2", 1200, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_SwapRing2")
        if ring2Data.uniqueId and ring2Data.uniqueId ~= 0 then
            self:EquipSingleItem(12, ring2Data)
        end
    end)
end

-- Helper function for jewelry loading
function ArmoryM:LoadJewelryPhase(gearData)
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_JewelryLoad", 600, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_JewelryLoad")
        self:LoadJewelryWithConflictResolution(gearData)
    end)
end

--=============================================================================
-- 8. BUILD MANAGEMENT (HIGH LEVEL)
--=============================================================================
function ArmoryM:SaveBuildToSlot(buildName, slotNumber)
    if not buildName or buildName == "" then
        ArmoryM:DebugPrint("Build name cannot be empty!")
        return false
    end

    -- Create backup before saving
    self:CreateBackup()

    if slotNumber < 1 or slotNumber > 12 then
        ArmoryM:DebugPrint("Invalid slot number: " .. tostring(slotNumber))
        return false
    end

    if not self.savedVars.slots then
        self.savedVars.slots = {}
    end

    -- Save with error handling
    local success, errorMsg = pcall(function()
        local gear = self:SaveCurrentGear()
        local frontBar1H = gear[4] and gear[5]
        local backBar1H = gear[20] and gear[21]

        self.savedVars.slots[slotNumber] = {
            name = buildName,
            skills = { [1] = {}, [2] = {} },
            gear = gear,
            weaponConfig = { frontBar1H = frontBar1H, backBar1H = backBar1H }
        }

        local currentBar = GetActiveWeaponPairInfo()
        self:SaveCurrentSkillsToSlot(slotNumber, currentBar)
        self:SetupAutoSaveForSlot(slotNumber, currentBar)
    end)

    if success then
        ArmoryM:DebugPrint(string.format("Saved '%s' to slot %d. Swap bars to complete.", buildName, slotNumber))
        return true
    else
        ArmoryM:DebugPrint("Save failed: " .. tostring(errorMsg))
        self:RestoreFromBackup()
        return false
    end
end

function ArmoryM:LoadBuildFromSlot(slotNumber)
    -- Initialize retry flag properly
    -- Unequip everything
    self:UnequipAllIncludingWeapons()
    -- Only reset to false if this is a brand new load (not a retry)
    if ArmoryM_ProgressBar and not ArmoryM_ProgressBar:IsHidden() then
        ArmoryM:DebugPrint("New build loading - clearing previous progress bar")
        self:HideProgressBar()
    end
    if not self.isRetrying then
        self.isRetrying = false
    end

    -- Update the UI
    if self.UpdateSlotsDisplay then
        self:UpdateSlotsDisplay()
    end
    if not self.savedVars.slots or not self.savedVars.slots[slotNumber] then
        ArmoryM:DebugPrint(string.format("Slot %d is empty!", slotNumber))
        return false
    end

    local slotData = self.savedVars.slots[slotNumber]

    -- Validate data
    if not slotData.name then
        ArmoryM:DebugPrint("Slot " .. slotNumber .. " data is corrupted")
        return false
    end

    -- SAFETY CHECK: Initialize savedComponents if missing (for old saves)
    if not slotData.savedComponents then
        slotData.savedComponents = {
            gear = slotData.gear and next(slotData.gear) ~= nil,
            skills = {
                [1] = slotData.skills and slotData.skills[1] and next(slotData.skills[1]) ~= nil,
                [2] = slotData.skills and slotData.skills[2] and next(slotData.skills[2]) ~= nil
            }
        }
        ArmoryM:DebugPrint("Initialized missing savedComponents for slot " .. slotNumber)
    end

    -- Check if anything is saved
    if not slotData.savedComponents.gear and
        not slotData.savedComponents.skills[1] and
        not slotData.savedComponents.skills[2] then
        ArmoryM:DebugPrint("No gear or skills saved in slot " .. slotNumber)
        return false
    end

    self:ClearAutoLoad()
    local currentBar = GetActiveWeaponPairInfo()

    -- Show loading message
    if not self.isRetrying then
        ArmoryM:DebugPrint(string.format("=== LOADING BUILD '%s' (Current Bar: %d) ===", slotData.name, currentBar))
    else
        ArmoryM:DebugPrint(string.format("=== RETRYING BUILD '%s' ===", slotData.name))
    end

    -- Load skills first
    if slotData.savedComponents.skills[currentBar] then
        self:LoadSkillsFromSlot(slotNumber, currentBar)
    end

    -- Load gear if available
    if slotData.savedComponents.gear then
        self.currentLoadingSlot = slotNumber

        -- START PROGRESS BAR HERE - Only for new loads, not retries
        if not self.isRetrying then
            self:OnUnequipStart()
            self:UnequipGearJewelry()

            -- Mark unequip as complete after delay
            EVENT_MANAGER:RegisterForUpdate("ArmoryM_UnequipComplete", 600, function()
                EVENT_MANAGER:UnregisterForUpdate("ArmoryM_UnequipComplete")
                self:OnUnequipComplete()
            end)
        else
            -- For retries, skip straight to verification phase
            self:OnVerificationStart()
        end

        local loadDelay = self.isRetrying and 200 or 1000
        EVENT_MANAGER:RegisterForUpdate("ArmoryM_LoadGear", loadDelay, function()
            EVENT_MANAGER:UnregisterForUpdate("ArmoryM_LoadGear")
            self.savedVars.currentBuild = slotData.name
            self:LoadGear(slotData.gear)
        end)
    else
        -- Just set current build name
        self.savedVars.currentBuild = slotData.name
        if not self.isRetrying then
            d("|c00FF00Skills loaded - No gear to load|r")
        end
    end

    -- Set up auto-load for other bar skills
    local otherBar = (currentBar == 1) and 2 or 1
    if slotData.savedComponents.skills[otherBar] then
        self:SetupAutoLoadForSlot(slotNumber, currentBar)
    end

    return true
end

function ArmoryM:DeleteBuildFromSlot(slotNumber)
    if not self.savedVars.slots or not self.savedVars.slots[slotNumber] then
        ArmoryM:DebugPrint(string.format("Slot %d is already empty!", slotNumber))
        return
    end

    local buildName = self.savedVars.slots[slotNumber].name
    self.savedVars.slots[slotNumber] = nil

    if self.savedVars.currentBuild == buildName then
        self.savedVars.currentBuild = ""
        self:ClearAutoLoad()

        if self.skillDisplay then
            self:UpdateSkillDisplay()
        end
    end

    ArmoryM:DebugPrint(string.format("Deleted build '%s' from slot %d", buildName, slotNumber))
end

function ArmoryM:GetSlotName(slotNumber)
    if not self.savedVars.slots or not self.savedVars.slots[slotNumber] then
        return nil
    end
    return self.savedVars.slots[slotNumber].name
end

function ArmoryM:GetSlotSaveStatus(slotNumber)
    if not self.savedVars.slots or not self.savedVars.slots[slotNumber] then
        return {
            name = nil,
            hasGear = false,
            hasSkills = { [1] = false, [2] = false },
            isEmpty = true
        }
    end

    local slotData = self.savedVars.slots[slotNumber]
    local savedComponents = slotData.savedComponents or {
        gear = false,
        skills = { [1] = false, [2] = false }
    }

    -- If savedComponents doesn't exist yet, determine based on data
    if not slotData.savedComponents then
        -- Gear is saved if there's any gear data
        local hasGear = slotData.gear and next(slotData.gear) ~= nil

        -- Skills are saved if there's any skill data for that bar
        local hasSkills1 = slotData.skills and slotData.skills[1] and next(slotData.skills[1]) ~= nil
        local hasSkills2 = slotData.skills and slotData.skills[2] and next(slotData.skills[2]) ~= nil

        savedComponents = {
            gear = hasGear,
            skills = { [1] = hasSkills1, [2] = hasSkills2 }
        }

        -- Save this determination for future use
        slotData.savedComponents = savedComponents
    end

    return {
        name = slotData.name,
        hasGear = savedComponents.gear,
        hasSkills = savedComponents.skills,
        isEmpty = not (savedComponents.gear or savedComponents.skills[1] or savedComponents.skills[2])
    }
end

--=============================================================================
-- 9. AUTO-SAVE/AUTO-LOAD SYSTEM
--=============================================================================
function ArmoryM:SetupAutoSaveForSlot(slotNumber, savedBar)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_AutoSave", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_AutoSave", EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
        function(eventCode, activeWeaponPair, locked)
            if activeWeaponPair ~= savedBar then
                self:SaveCurrentSkillsToSlot(slotNumber, activeWeaponPair)
                local slotData = self.savedVars.slots[slotNumber]

                -- Update tracking
                if slotData and slotData.savedComponents then
                    slotData.savedComponents.skills[activeWeaponPair] = true
                end

                if self.UpdateSlotsDisplay then
                    self:UpdateSlotsDisplay()
                end

                EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_AutoSave", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
                ArmoryM:DebugPrint(string.format("Finished saving '%s' to slot %d", slotData.name, slotNumber))
            end
        end)
end

function ArmoryM:SetupAutoLoadForSlot(slotNumber, currentBar)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_AutoLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)

    self.autoLoadSlot = slotNumber
    self.autoLoadCurrentBar = currentBar
    self.autoLoadOtherBar = (currentBar == 1) and 2 or 1

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_AutoLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
        function(eventCode, activeWeaponPair, locked)
            if activeWeaponPair == self.autoLoadOtherBar then
                local slotData = self.savedVars.slots[self.autoLoadSlot]
                if slotData then
                    self:LoadSkillsFromSlot(self.autoLoadSlot, activeWeaponPair)
                    ArmoryM:DebugPrint(string.format("Auto-loaded bar %d for '%s'", activeWeaponPair, slotData.name))
                end

                self.autoLoadSlot = nil
                self.autoLoadCurrentBar = nil
                self.autoLoadOtherBar = nil
                EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_AutoLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
                ArmoryM:DebugPrint("Auto-load complete")
            end
        end)

    ArmoryM:DebugPrint(string.format("Auto-load set up for slot %d. Switch to bar %d to complete loading.", slotNumber,
        self.autoLoadOtherBar))
end

--=============================================================================
-- 10. CLEANUP & STATE MANAGEMENT
--=============================================================================
-- Updated ClearAutoLoad to clean up weapon load listeners
function ArmoryM:ClearAutoLoad()
    -- Clear skill auto-load
    self.autoLoadSlot = nil
    self.autoLoadCurrentBar = nil
    self.autoLoadOtherBar = nil

    -- Clear weapon loading
    self:CleanupWeaponLoading()

    -- Unregister all events
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_AutoLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_AutoSave", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_WeaponLoad", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)

    -- Clean up all timers
    for i = 0, 30 do
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_SimpleEquip" .. i)
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_Armor" .. i)
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_Weapon" .. i)
    end

    -- Clean up gear loading timers
    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_LoadGear")
    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_UpdateAfterEquip")
    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_CurrentBarWeapons")
    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_OtherBarWeapons")
    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_CleanupWeaponLoad")
    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_WeaponLoadTimeout")

    ArmoryM:DebugPrint("All auto-load systems cleared")
end

-- Helper function to finish gear loading
function ArmoryM:FinishGearLoading()
    -- COMPLETE THE PROGRESS BAR
    if not self.isRetrying then
        self:OnLoadingComplete()
    end

    EVENT_MANAGER:RegisterForUpdate("ArmoryM_UpdateAfterEquip", 500, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_UpdateAfterEquip")

        if self.UpdateSlotsDisplay then
            self:UpdateSlotsDisplay()
        end

        -- Show completion message based on retry state
        if not self.isRetrying then
            d("|c00FF00Swap complete|r")
        else
            -- Retry completed successfully - show success message
            d("|c00FF00Retry successful - Swap complete|r")
        end

        -- Reset retry flag after completion message
        self.isRetrying = false
    end)
end

--=============================================================================
-- 11. SLOT MANAGEMENT UTILITIES
--=============================================================================
function ArmoryM:InitializeNewSlot(slotNumber, buildName)
    if not self.savedVars.slots then
        self.savedVars.slots = {}
    end

    -- Create the slot if it doesn't exist or initialize its components
    if not self.savedVars.slots[slotNumber] then
        self.savedVars.slots[slotNumber] = {
            name = buildName,
            skills = { [1] = {}, [2] = {} },
            gear = {},
            weaponConfig = { frontBar1H = false, backBar1H = false },
            savedComponents = { -- Track what's been saved
                gear = false,
                skills = { [1] = false, [2] = false }
            }
        }
    else
        -- Update existing slot name if provided
        if buildName and buildName ~= "" then
            self.savedVars.slots[slotNumber].name = buildName
        end

        -- Ensure the savedComponents tracking exists
        if not self.savedVars.slots[slotNumber].savedComponents then
            self.savedVars.slots[slotNumber].savedComponents = {
                gear = self.savedVars.slots[slotNumber].gear and next(self.savedVars.slots[slotNumber].gear) ~= nil,
                skills = {
                    [1] = self.savedVars.slots[slotNumber].skills[1] and
                        next(self.savedVars.slots[slotNumber].skills[1]) ~= nil,
                    [2] = self.savedVars.slots[slotNumber].skills[2] and
                        next(self.savedVars.slots[slotNumber].skills[2]) ~= nil
                }
            }
        end
    end

    return self.savedVars.slots[slotNumber]
end

---=============================================================================
-- 14. INITIALIZATION
--=============================================================================
local function InitializeSafeVars()
    ArmoryM.savedVars = ZO_SavedVars:NewCharacterIdSettings("ArmoryM_SavedVars", 1, nil, defaults)

    local needsMigration = false
    local needsRestore = false

    if not ArmoryM.savedVars.version then
        ArmoryM.savedVars.version = 1
        needsMigration = true
    elseif ArmoryM.savedVars.version < ADDON_VERSION then
        needsMigration = true
    end

    if not ArmoryM.savedVars.slots or type(ArmoryM.savedVars.slots) ~= "table" then
        ArmoryM:DebugPrint("SavedVars corruption detected")
        needsRestore = true
    end

    ArmoryM:CreateBackup()

    if needsMigration then
        ArmoryM:MigrateSavedVarsWithComponents(ArmoryM.savedVars.version, ADDON_VERSION)
    end

    if needsRestore then
        ArmoryM:RestoreFromBackup()
    end

    ArmoryM.savedVars.version = ADDON_VERSION
    ArmoryM:DebugPrint("SavedVars initialized safely (version " .. ADDON_VERSION .. ")")
end

local function Initialize()
    InitializeSafeVars()
    ArmoryM:InitializeProgressTracking()

    zo_callLater(function()
        ArmoryM:CreateSettingsMenu()
        ArmoryM:CreateSlotsDisplay()
    end, 100)
end

local function OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
