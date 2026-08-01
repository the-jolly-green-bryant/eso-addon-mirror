-- ============================================
-- WARDROBE - Equipment Set Manager
-- Adventurer's Toolkit
-- ============================================

NWT.Wardrobe = {
    isOpen = false,
    sceneInitialized = false,
    -- Selection state
    selectedPresetIndex = 1,
    selectedSlotIndex = 1,
    focusPanel = 1, -- 1=presets, 2=paperdoll, 3=details
    -- Equipment slots in display order
    equipSlots = {
        EQUIP_SLOT_HEAD,
        EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_CHEST,
        EQUIP_SLOT_HAND,
        EQUIP_SLOT_WAIST,
        EQUIP_SLOT_LEGS,
        EQUIP_SLOT_FEET,
        EQUIP_SLOT_NECK,
        EQUIP_SLOT_RING1,
        EQUIP_SLOT_RING2,
        EQUIP_SLOT_MAIN_HAND,
        EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_BACKUP_MAIN,
        EQUIP_SLOT_BACKUP_OFF,
    },
    slotNames = {
        [EQUIP_SLOT_HEAD] = "Head",
        [EQUIP_SLOT_SHOULDERS] = "Shoulders",
        [EQUIP_SLOT_CHEST] = "Chest",
        [EQUIP_SLOT_HAND] = "Hands",
        [EQUIP_SLOT_WAIST] = "Waist",
        [EQUIP_SLOT_LEGS] = "Legs",
        [EQUIP_SLOT_FEET] = "Feet",
        [EQUIP_SLOT_NECK] = "Necklace",
        [EQUIP_SLOT_RING1] = "Ring 1",
        [EQUIP_SLOT_RING2] = "Ring 2",
        [EQUIP_SLOT_MAIN_HAND] = "Main Hand",
        [EQUIP_SLOT_OFF_HAND] = "Off Hand",
        [EQUIP_SLOT_BACKUP_MAIN] = "Backup Main",
        [EQUIP_SLOT_BACKUP_OFF] = "Backup Off",
    },
    maxVisiblePresets = 10,
    presetScrollOffset = 0,
}

-- ============================================
-- SAVED VARIABLES DEFAULTS
-- ============================================
NWT.WARDROBE_DEFAULTS = {
    presets = {},
    activePreset = 0,
    quickSlots = { nil, nil, nil },
    showEmptySlots = true,
    showSetBonuses = true,
    accentColor = "FF69B4",
}

-- ============================================
-- INITIALIZATION
-- ============================================
function NWT.InitWardrobeData()
    local charName = GetUnitName("player")
    if not NWT.savedVars.wardrobe then
        NWT.savedVars.wardrobe = {}
    end
    if not NWT.savedVars.wardrobe[charName] then
        NWT.savedVars.wardrobe[charName] = ZO_DeepTableCopy(NWT.WARDROBE_DEFAULTS)
    end
    for k, v in pairs(NWT.WARDROBE_DEFAULTS) do
        if NWT.savedVars.wardrobe[charName][k] == nil then
            NWT.savedVars.wardrobe[charName][k] = ZO_DeepTableCopy(v)
        end
    end
end

function NWT.GetWardrobeSV()
    local charName = GetUnitName("player")
    return NWT.savedVars.wardrobe and NWT.savedVars.wardrobe[charName] or NWT.WARDROBE_DEFAULTS
end

-- ============================================
-- EQUIPMENT SCANNING
-- ============================================
function NWT.GetCurrentEquipment()
    local equipment = {}
    for _, slot in ipairs(NWT.Wardrobe.equipSlots) do
        local itemLink = GetItemLink(BAG_WORN, slot, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            local icon = GetItemLinkIcon(itemLink)
            local quality = GetItemLinkDisplayQuality(itemLink)
            local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, true)
            local traitType, traitDesc = GetItemLinkTraitInfo(itemLink)
            local _, enchantHeader, enchantDesc = GetItemLinkEnchantInfo(itemLink)
            equipment[slot] = {
                itemLink = itemLink,
                icon = icon,
                quality = quality,
                setName = hasSet and setName or nil,
                setId = hasSet and setId or nil,
                traitType = traitType,
                traitDesc = traitDesc,
                enchantDesc = enchantDesc,
            }
        end
    end
    return equipment
end

function NWT.SaveCurrentAsPreset(presetName)
    local sv = NWT.GetWardrobeSV()
    local equipment = NWT.GetCurrentEquipment()
    local preset = {
        name = presetName or ("Preset " .. (#sv.presets + 1)),
        slots = equipment,
        createdAt = GetTimeStamp(),
        lastUsed = GetTimeStamp(),
    }
    table.insert(sv.presets, preset)
    NWT.Debug("|cFF69B4[Wardrobe]|r Saved preset: " .. preset.name)
    return #sv.presets
end

function NWT.DeletePreset(index)
    local sv = NWT.GetWardrobeSV()
    if sv.presets[index] then
        local name = sv.presets[index].name
        table.remove(sv.presets, index)
        NWT.Debug("|cFF69B4[Wardrobe]|r Deleted preset: " .. name)
        return true
    end
    return false
end

function NWT.RenamePreset(index, newName)
    local sv = NWT.GetWardrobeSV()
    if sv.presets[index] then
        sv.presets[index].name = newName
        return true
    end
    return false
end

-- ============================================
-- ITEM LOCATION FINDING
-- ============================================
function NWT.FindItemInBags(targetItemLink)
    if not targetItemLink or targetItemLink == "" then return nil end
    local targetId = GetItemLinkItemId(targetItemLink)
    local bagsToSearch = {
        { bag = BAG_WORN, name = "Equipped" },
        { bag = BAG_BACKPACK, name = "Inventory" },
        { bag = BAG_BANK, name = "Bank" },
        { bag = BAG_SUBSCRIBER_BANK, name = "ESO+ Bank" },
    }
    for i = 1, 10 do
        local houseBag = _G["BAG_HOUSE_BANK_" .. (i == 1 and "ONE" or i == 2 and "TWO" or i == 3 and "THREE" or i == 4 and "FOUR" or i == 5 and "FIVE" or i == 6 and "SIX" or i == 7 and "SEVEN" or i == 8 and "EIGHT" or i == 9 and "NINE" or "TEN")]
        if houseBag then
            table.insert(bagsToSearch, { bag = houseBag, name = "House Storage " .. i })
        end
    end
    for _, bagInfo in ipairs(bagsToSearch) do
        local bagSize = GetBagSize(bagInfo.bag)
        if bagSize and bagSize > 0 then
            for slot = 0, bagSize - 1 do
                local itemLink = GetItemLink(bagInfo.bag, slot, LINK_STYLE_DEFAULT)
                if itemLink and itemLink ~= "" then
                    local itemId = GetItemLinkItemId(itemLink)
                    if itemId == targetId then
                        return {
                            bag = bagInfo.bag,
                            slot = slot,
                            location = bagInfo.name,
                            itemLink = itemLink,
                        }
                    end
                end
            end
        end
    end
    return nil
end

function NWT.GetPresetItemLocations(presetIndex)
    local sv = NWT.GetWardrobeSV()
    local preset = sv.presets[presetIndex]
    if not preset then return {} end
    local locations = {}
    for slot, itemData in pairs(preset.slots) do
        local found = NWT.FindItemInBags(itemData.itemLink)
        locations[slot] = {
            itemData = itemData,
            found = found,
            status = found and (found.bag == BAG_WORN and "equipped" or found.bag == BAG_BACKPACK and "inventory" or "storage") or "missing",
        }
    end
    return locations
end

-- ============================================
-- BANK INTEGRATION
-- ============================================
function NWT.FindEmptySlot(bagId)
    local bagSize = GetBagSize(bagId)
    if not bagSize then return nil end
    for slot = 0, bagSize - 1 do
        local itemLink = GetItemLink(bagId, slot, LINK_STYLE_DEFAULT)
        if not itemLink or itemLink == "" then
            return slot
        end
    end
    return nil
end

function NWT.PullItemFromBank(sourceBag, sourceSlot)
    if not IsBankOpen() then
        d("|cFF69B4[Wardrobe]|r Bank must be open to pull items.")
        return false
    end
    local emptySlot = NWT.FindEmptySlot(BAG_BACKPACK)
    if not emptySlot then
        d("|cFF69B4[Wardrobe]|r No empty inventory slots!")
        return false
    end
    local success = CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, BAG_BACKPACK, emptySlot, 1)
    return success
end

function NWT.StoreItemInBank(sourceSlot, targetBag)
    if not IsBankOpen() then
        d("|cFF69B4[Wardrobe]|r Bank must be open to store items.")
        return false
    end
    targetBag = targetBag or BAG_BANK
    local emptySlot = NWT.FindEmptySlot(targetBag)
    if not emptySlot then
        emptySlot = NWT.FindEmptySlot(BAG_SUBSCRIBER_BANK)
        if emptySlot then
            targetBag = BAG_SUBSCRIBER_BANK
        else
            d("|cFF69B4[Wardrobe]|r No empty bank slots!")
            return false
        end
    end
    local success = CallSecureProtected("RequestMoveItem", BAG_BACKPACK, sourceSlot, targetBag, emptySlot, 1)
    return success
end

function NWT.PullAllPresetItems(presetIndex)
    if not IsBankOpen() then
        d("|cFF69B4[Wardrobe]|r Bank must be open to pull items.")
        return 0
    end
    local locations = NWT.GetPresetItemLocations(presetIndex)
    local pulledCount = 0
    for slot, locData in pairs(locations) do
        if locData.found and locData.status == "storage" then
            if NWT.PullItemFromBank(locData.found.bag, locData.found.slot) then
                pulledCount = pulledCount + 1
            end
        end
    end
    if pulledCount > 0 then
        d("|cFF69B4[Wardrobe]|r Pulled " .. pulledCount .. " items from bank.")
        PlaySound(SOUNDS.INVENTORY_ITEM_APPLY_ENCHANT)
    end
    return pulledCount
end

function NWT.StoreCurrentGearInBank()
    if not IsBankOpen() then
        d("|cFF69B4[Wardrobe]|r Bank must be open to store items.")
        return 0
    end
    local storedCount = 0
    local bagSize = GetBagSize(BAG_BACKPACK)
    for slot = 0, bagSize - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slot, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            local equipType = GetItemLinkEquipType(itemLink)
            if equipType and equipType ~= EQUIP_TYPE_INVALID then
                if NWT.StoreItemInBank(slot) then
                    storedCount = storedCount + 1
                end
            end
        end
    end
    if storedCount > 0 then
        d("|cFF69B4[Wardrobe]|r Stored " .. storedCount .. " gear items in bank.")
        PlaySound(SOUNDS.INVENTORY_ITEM_APPLY_ENCHANT)
    end
    return storedCount
end

-- ============================================
-- EQUIPPING
-- ============================================
function NWT.EquipPreset(presetIndex)
    local sv = NWT.GetWardrobeSV()
    local preset = sv.presets[presetIndex]
    if not preset then 
        d("|cFF69B4[Wardrobe]|r No preset at index " .. tostring(presetIndex))
        return false 
    end
    local locations = NWT.GetPresetItemLocations(presetIndex)
    local equippedCount = 0
    local missingCount = 0
    local needsBankCount = 0
    local attemptedCount = 0
    for slot, locData in pairs(locations) do
        -- Convert slot to number (SavedVariables converts numeric keys to strings)
        local equipSlot = tonumber(slot)
        if locData.found then
            if locData.found.bag == BAG_BACKPACK then
                -- RequestEquipItem(sourceBag, sourceSlot, destBag, destEquipSlot) - called directly per Wizard's Wardrobe
                RequestEquipItem(BAG_BACKPACK, locData.found.slot, BAG_WORN, equipSlot)
                attemptedCount = attemptedCount + 1
                equippedCount = equippedCount + 1
            elseif locData.found.bag == BAG_WORN then
                equippedCount = equippedCount + 1
            else
                needsBankCount = needsBankCount + 1
            end
        else
            missingCount = missingCount + 1
        end
    end
    preset.lastUsed = GetTimeStamp()
    sv.activePreset = presetIndex
    local msg = "|cFF69B4[Wardrobe]|r Equipped " .. preset.name .. ": " .. equippedCount .. " items"
    if attemptedCount > 0 then
        msg = msg .. " (attempted " .. attemptedCount .. ")"
    end
    if needsBankCount > 0 then
        msg = msg .. " (" .. needsBankCount .. " need bank)"
    end
    if missingCount > 0 then
        msg = msg .. " (" .. missingCount .. " missing)"
    end
    d(msg)
    PlaySound(SOUNDS.INVENTORY_ITEM_APPLY_ENCHANT)
    return true
end

-- ============================================
-- SET BONUS CALCULATION
-- ============================================
function NWT.GetPresetSetBonuses(presetIndex)
    local sv = NWT.GetWardrobeSV()
    local preset = sv.presets[presetIndex]
    if not preset then return {} end
    local setCounts = {}
    for slot, itemData in pairs(preset.slots) do
        if itemData.setId then
            setCounts[itemData.setId] = setCounts[itemData.setId] or { name = itemData.setName, count = 0 }
            -- 2H weapons count as 2 pieces (main hand slot with 2H weapon type)
            local countToAdd = 1
            if slot == EQUIP_SLOT_MAIN_HAND and itemData.itemLink then
                local weaponType = GetItemLinkWeaponType(itemData.itemLink)
                if weaponType == WEAPONTYPE_TWO_HANDED_SWORD or weaponType == WEAPONTYPE_TWO_HANDED_AXE or 
                   weaponType == WEAPONTYPE_TWO_HANDED_HAMMER or weaponType == WEAPONTYPE_BOW or
                   weaponType == WEAPONTYPE_HEALING_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF or
                   weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF then
                    countToAdd = 2
                end
            end
            setCounts[itemData.setId].count = setCounts[itemData.setId].count + countToAdd
        end
    end
    local bonuses = {}
    for setId, setData in pairs(setCounts) do
        local hasSet, setName, numBonuses, _, _, maxEquipped = GetItemSetInfo(setId)
        if hasSet then
            table.insert(bonuses, {
                name = setName,
                count = setData.count,
                max = maxEquipped,
            })
        end
    end
    table.sort(bonuses, function(a, b) return a.count > b.count end)
    return bonuses
end


-- ============================================
-- UI SCREEN CLASS
-- ============================================
local ATK_WardrobeScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_WardrobeScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_WardrobeScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, NWT.WardrobeScene) end
function ATK_WardrobeScreen:PerformUpdate() end

function ATK_WardrobeScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = "Equip Preset",
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                local idx = NWT.Wardrobe.selectedPresetIndex
                NWT.EquipPreset(idx)
                NWT.UpdateWardrobeDashboard()
                PlaySound(SOUNDS.POSITIVE_CLICK)
            end,
            visible = function()
                local sv = NWT.GetWardrobeSV()
                return sv.presets and #sv.presets > 0
            end,
        },
        {
            name = "Save Current Gear",
            keybind = "UI_SHORTCUT_SECONDARY",
            callback = function()
                NWT.SaveCurrentAsPreset()
                NWT.UpdateWardrobeDashboard()
                PlaySound(SOUNDS.POSITIVE_CLICK)
            end,
        },
        {
            name = "Delete Preset",
            keybind = "UI_SHORTCUT_QUATERNARY",
            callback = function()
                local idx = NWT.Wardrobe.selectedPresetIndex
                NWT.DeletePreset(idx)
                if NWT.Wardrobe.selectedPresetIndex > 1 then
                    NWT.Wardrobe.selectedPresetIndex = NWT.Wardrobe.selectedPresetIndex - 1
                end
                NWT.UpdateWardrobeDashboard()
                PlaySound(SOUNDS.NEGATIVE_CLICK)
            end,
            visible = function()
                local sv = NWT.GetWardrobeSV()
                return sv.presets and #sv.presets > 0
            end,
        },
        {
            name = function()
                return NWT.Wardrobe.focusPanel == 1 and "Presets" or "< Presets"
            end,
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            callback = function()
                if NWT.Wardrobe.focusPanel > 1 then
                    NWT.Wardrobe.focusPanel = NWT.Wardrobe.focusPanel - 1
                    NWT.UpdateWardrobeDashboard()
                    PlaySound(SOUNDS.GAMEPAD_MENU_BACKWARD)
                end
            end,
        },
        {
            name = function()
                return NWT.Wardrobe.focusPanel == 2 and "Gear" or "Gear >"
            end,
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            callback = function()
                if NWT.Wardrobe.focusPanel < 2 then
                    NWT.Wardrobe.focusPanel = NWT.Wardrobe.focusPanel + 1
                    NWT.UpdateWardrobeDashboard()
                    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
                end
            end,
        },
    }
    local function OnBack()
        NWT.CloseWardrobeDashboard()
    end
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, OnBack)
end

-- ============================================
-- SCENE INITIALIZATION
-- ============================================
function NWT.InitWardrobeScene()
    if NWT.Wardrobe.sceneInitialized then return end
    local ui = ATK_Wardrobe_UI
    if not ui then return end
    
    local hiddenControl = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenWardrobeList", GuiRoot, "ATK_HouseList_Screen")
    hiddenControl:SetHidden(true)
    hiddenControl:SetAlpha(0)
    
    local fragment = ZO_SimpleSceneFragment:New(ui)
    local hiddenFragment = ZO_SimpleSceneFragment:New(hiddenControl)
    
    NWT.WardrobeScene = ZO_Scene:New("wardrobeDashboardScene", SCENE_MANAGER)
    NWT.WardrobeScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    NWT.WardrobeScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NWT.WardrobeScene:AddFragment(fragment)
    NWT.WardrobeScene:AddFragment(hiddenFragment)
    
    NWT.WardrobeScreen = ATK_WardrobeScreen:New(hiddenControl)
    NWT.WardrobeList = NWT.WardrobeScreen:GetMainList()
    NWT.WardrobeList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function() end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    -- D-pad up/down navigation (same pattern as Housing)
    NWT.WardrobeList.MovePrevious = function(self, ...)
        NWT.WardrobeNavigate("up")
    end
    NWT.WardrobeList.MoveNext = function(self, ...)
        NWT.WardrobeNavigate("down")
    end
    
    -- D-pad left/right navigation for panel switching (same pattern as Housing)
    NWT.WardrobeList:SetOnMovementChangedCallback(function(list, movement)
        if movement == MOVEMENT_CONTROLLER_MOVE_NEXT_HORIZONTAL then
            NWT.WardrobeNavigate("right")
        elseif movement == MOVEMENT_CONTROLLER_MOVE_PREVIOUS_HORIZONTAL then
            NWT.WardrobeNavigate("left")
        end
    end)
    
    NWT.WardrobeScene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            NWT.Wardrobe.isOpen = true
            NWT.UpdateWardrobeDashboard()
        elseif newState == SCENE_HIDDEN then
            NWT.Wardrobe.isOpen = false
        end
    end)
    
    NWT.Wardrobe.sceneInitialized = true
end

function NWT.WardrobeNavigate(dir)
    local w = NWT.Wardrobe
    local sv = NWT.GetWardrobeSV()
    
    -- Left/Right switches between panels (1=presets, 2=paperdoll)
    if dir == "left" then
        if w.focusPanel > 1 then
            w.focusPanel = w.focusPanel - 1
            PlaySound(SOUNDS.GAMEPAD_MENU_BACKWARD)
        end
    elseif dir == "right" then
        if w.focusPanel < 2 then
            w.focusPanel = w.focusPanel + 1
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
    elseif w.focusPanel == 1 then
        -- Presets panel navigation
        if dir == "up" and w.selectedPresetIndex > 1 then
            w.selectedPresetIndex = w.selectedPresetIndex - 1
            PlaySound(SOUNDS.GAMEPAD_MENU_BACKWARD)
        elseif dir == "down" then
            if #sv.presets > 0 and w.selectedPresetIndex < #sv.presets then
                w.selectedPresetIndex = w.selectedPresetIndex + 1
                PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
            end
        end
    elseif w.focusPanel == 2 then
        -- Paperdoll slot navigation
        if dir == "up" and w.selectedSlotIndex > 1 then
            w.selectedSlotIndex = w.selectedSlotIndex - 1
            PlaySound(SOUNDS.GAMEPAD_MENU_BACKWARD)
        elseif dir == "down" and w.selectedSlotIndex < #w.equipSlots then
            w.selectedSlotIndex = w.selectedSlotIndex + 1
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
    end
    NWT.UpdateWardrobeDashboard()
    -- Update keybind strip to reflect panel changes
    if KEYBIND_STRIP and NWT.WardrobeScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.WardrobeScreen.keybindStripDescriptor)
    end
end

function NWT.OpenWardrobeDashboard()
    NWT.InitWardrobeData()
    NWT.InitWardrobeScene()
    if NWT.WardrobeScene then
        SCENE_MANAGER:Show("wardrobeDashboardScene")
    end
end

function NWT.CloseWardrobeDashboard()
    if NWT.WardrobeScene then
        SCENE_MANAGER:Hide("wardrobeDashboardScene")
    end
end

-- ============================================
-- UI UPDATE
-- ============================================
function NWT.UpdateWardrobeDashboard()
    local ui = ATK_Wardrobe_UI
    if not ui then return end
    local w = NWT.Wardrobe
    local sv = NWT.GetWardrobeSV()
    local colors = NWT.GetColors and NWT.GetColors() or { accent = "FF69B4", positive = "00FF00", negative = "FF4444", warning = "FFAA00" }
    local qualityColors = { [0] = "9D9D9D", [1] = "FFFFFF", [2] = "2DC50E", [3] = "3A92FF", [4] = "A02EF7", [5] = "EECA2A" }
    
    local header = ui:GetNamedChild("Header")
    if header then
        local title = header:GetNamedChild("Title")
        if title then title:SetText("|cFF69B4WARDROBE|r") end
        local subtitle = header:GetNamedChild("Subtitle")
        if subtitle then
            subtitle:SetText(GetUnitName("player"))
        end
    end
    
    local leftCol = ui:GetNamedChild("LeftCol")
    if leftCol then
        local presetsCard = leftCol:GetNamedChild("PresetsCard")
        if presetsCard then
            local list = presetsCard:GetNamedChild("List")
            if list then
                for i = 1, w.maxVisiblePresets do
                    local row = list:GetNamedChild("Row" .. i)
                    if row then
                        local presetIdx = i + w.presetScrollOffset
                        local preset = sv.presets[presetIdx]
                        if preset then
                            local selected = presetIdx == w.selectedPresetIndex
                            local prefix = selected and "|cFFD700▶ |r" or "   "
                            local color = selected and "FFFFFF" or "AAAAAA"
                            row:SetText(prefix .. "|c" .. color .. preset.name .. "|r")
                        else
                            row:SetText("")
                        end
                    end
                end
                local selFrame = list:GetNamedChild("SelectionFrame")
                if selFrame then
                    local visibleIdx = w.selectedPresetIndex - w.presetScrollOffset
                    if visibleIdx >= 1 and visibleIdx <= w.maxVisiblePresets then
                        selFrame:SetHidden(false)
                        selFrame:ClearAnchors()
                        selFrame:SetAnchor(TOPLEFT, list, TOPLEFT, 0, (visibleIdx - 1) * 38)
                    else
                        selFrame:SetHidden(true)
                    end
                end
            end
            local newBtn = presetsCard:GetNamedChild("NewPresetBtn")
            if newBtn then
                newBtn:SetText("|c888888[X] Save Current Gear|r")
            end
        end
    end
    
    local centerCol = ui:GetNamedChild("CenterCol")
    if centerCol then
        local preset = sv.presets[w.selectedPresetIndex]
        local locations = preset and NWT.GetPresetItemLocations(w.selectedPresetIndex) or {}
        local paperdoll = centerCol:GetNamedChild("Paperdoll")
        if paperdoll then
            local presetLabel = paperdoll:GetNamedChild("PresetName")
            if presetLabel then
                presetLabel:SetText(preset and ("|cFFD700" .. preset.name .. "|r") or "|c888888No Preset Selected|r")
            end
            for i, slot in ipairs(w.equipSlots) do
                local slotControl = paperdoll:GetNamedChild("Slot" .. i)
                if slotControl then
                    local icon = slotControl:GetNamedChild("Icon")
                    local statusIcon = slotControl:GetNamedChild("Status")
                    local frame = slotControl:GetNamedChild("Frame")
                    local locData = locations[slot]
                    
                    -- Highlight selected slot when paperdoll panel is focused
                    local isSelected = (w.focusPanel == 2 and i == w.selectedSlotIndex)
                    if frame then
                        if isSelected then
                            frame:SetEdgeColor(1, 0.84, 0, 1) -- Gold border for selected
                        else
                            frame:SetEdgeColor(0.33, 0.33, 0.33, 1) -- Default gray
                        end
                    end
                    
                    if locData and locData.itemData then
                        if icon then
                            icon:SetTexture(locData.itemData.icon or "EsoUI/Art/Icons/icon_missing.dds")
                            icon:SetHidden(false)
                            icon:SetAlpha(1)
                        end
                        if statusIcon then
                            if locData.status == "equipped" then
                                statusIcon:SetTexture("EsoUI/Art/Miscellaneous/Gamepad/gp_check.dds")
                                statusIcon:SetColor(0, 1, 0, 1)
                            elseif locData.status == "inventory" then
                                statusIcon:SetTexture("EsoUI/Art/Miscellaneous/Gamepad/gp_check.dds")
                                statusIcon:SetColor(0, 1, 0, 0.7)
                            elseif locData.status == "storage" then
                                statusIcon:SetTexture("EsoUI/Art/Inventory/gamepad/gp_inventory_icon_bank.dds")
                                statusIcon:SetColor(1, 0.7, 0, 1)
                            else
                                statusIcon:SetTexture("EsoUI/Art/Miscellaneous/Gamepad/gp_x.dds")
                                statusIcon:SetColor(1, 0, 0, 1)
                            end
                            statusIcon:SetHidden(false)
                        end
                    else
                        if icon then
                            icon:SetTexture("EsoUI/Art/Icons/icon_missing.dds")
                            icon:SetAlpha(0.3)
                        end
                        if statusIcon then statusIcon:SetHidden(true) end
                    end
                end
            end
        end
    end
    
    local rightCol = ui:GetNamedChild("RightCol")
    if rightCol then
        local detailsCard = rightCol:GetNamedChild("DetailsCard")
        if detailsCard then
            local preset = sv.presets[w.selectedPresetIndex]
            local selectedSlot = w.equipSlots[w.selectedSlotIndex]
            local locations = preset and NWT.GetPresetItemLocations(w.selectedPresetIndex) or {}
            local locData = locations[selectedSlot]
            local itemName = detailsCard:GetNamedChild("ItemName")
            local itemIcon = detailsCard:GetNamedChild("ItemIcon")
            local itemStats = detailsCard:GetNamedChild("ItemStats")
            local itemLocation = detailsCard:GetNamedChild("ItemLocation")
            if locData and locData.itemData then
                local data = locData.itemData
                local q = data.quality or 1
                local qc = qualityColors[q] or "FFFFFF"
                if itemName then itemName:SetText("|c" .. qc .. GetItemLinkName(data.itemLink) .. "|r") end
                if itemIcon then
                    itemIcon:SetTexture(data.icon or "EsoUI/Art/Icons/icon_missing.dds")
                    itemIcon:SetHidden(false)
                end
                local statsText = ""
                if data.setName then statsText = statsText .. "|cFFD700Set:|r " .. data.setName .. "\n" end
                if data.traitDesc and data.traitDesc ~= "" then statsText = statsText .. "|c00FFFF Trait:|r " .. data.traitDesc .. "\n" end
                if data.enchantDesc and data.enchantDesc ~= "" then statsText = statsText .. "|c00FF00Enchant:|r " .. data.enchantDesc .. "\n" end
                if itemStats then itemStats:SetText(statsText) end
                if itemLocation then
                    local statusColor = locData.status == "equipped" and "00FF00" or locData.status == "inventory" and "00FF00" or locData.status == "storage" and "FFAA00" or "FF4444"
                    local statusText = locData.found and locData.found.location or "NOT FOUND"
                    itemLocation:SetText("|c" .. statusColor .. "Location: " .. statusText .. "|r")
                end
            else
                if itemName then itemName:SetText("|c888888" .. (w.slotNames[selectedSlot] or "Empty") .. "|r") end
                if itemIcon then itemIcon:SetHidden(true) end
                if itemStats then itemStats:SetText("") end
                if itemLocation then itemLocation:SetText("") end
            end
        end
        local setBonusCard = rightCol:GetNamedChild("SetBonusCard")
        if setBonusCard then
            local bonusList = setBonusCard:GetNamedChild("List")
            if bonusList then
                local bonuses = NWT.GetPresetSetBonuses(w.selectedPresetIndex)
                for i = 1, 5 do
                    local row = bonusList:GetNamedChild("Row" .. i)
                    if row then
                        local bonus = bonuses[i]
                        if bonus then
                            local color = bonus.count >= bonus.max and "00FF00" or "FFAA00"
                            row:SetText("|c" .. color .. bonus.name .. " " .. bonus.count .. "/" .. bonus.max .. "|r")
                        else
                            row:SetText("")
                        end
                    end
                end
            end
        end
    end
end

-- ============================================
-- SLASH COMMAND
-- ============================================
SLASH_COMMANDS["/wardrobe"] = function()
    if NWT.Wardrobe.isOpen then
        NWT.CloseWardrobeDashboard()
    else
        NWT.OpenWardrobeDashboard()
    end
end

