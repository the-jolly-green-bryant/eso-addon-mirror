WishList = WishList or {}
local WL = WishList

local zostrfor = zo_strformat

local WL_getGearMarkerTexture = WL.getGearMarkerTexture

------------------------------------------------
--- Dialog local function
------------------------------------------------
--Build the entry text for the entries of the last added dropdown control, at the add item dialog
local function buildLastAddedEntryText(lastAddedData)
    if not lastAddedData then return end
    local charId = lastAddedData.charId
    local charName = (charId ~= nil and WL.accData.chars and WL.accData.chars[charId] and WL.accData.chars[charId].name) or nil
    if charName == nil then return nil end

    local dateTime = lastAddedData.dateTime
    local dateTimeString = os.date("%c", dateTime)
    local setId = lastAddedData.setId
    local libSets = WL.LibSets
    local setName = libSets.GetSetName(setId)
    local itemTypeId = lastAddedData.itemTypeId
    local itemTypeIdIcon = WL.buildItemItemTypeIconText("", itemTypeId, 24)
    local weaponOrArmorType = lastAddedData.armorOrWeaponType
    local weaponOrArmorTypeIcon = WL.buildItemWeaponOrArmorTypeIconText("", weaponOrArmorType, itemTypeId, 24)
    local slotType = lastAddedData.slotType
    local slotIcon = WL.buildItemSlotIconText("", slotType, 24)
    local trait = lastAddedData.trait
    local traitIcon = WL.buildItemTraitIconText("", trait, 24)
    local quality = lastAddedData.quality
    local setQualityText = WL.ColorizeByQualityColor(setName, quality)

    local specialAddedType = lastAddedData.specialAddedType
    local entryTextTemplate = "%s: %s %s %s%s%s%s(%s)"
    local entryTextTemplateNoSpecialAddedType = "%s: %s %s %s%s%s%s"
    local entryTextTemplateToUse
    local specialAddedTypeText
    local entryText
    if specialAddedType ~= nil then
        local addDialogButtonTextures = WL.addDialogButtonTextures
        local specialAddedTypeTexture = addDialogButtonTextures[specialAddedType]
        if specialAddedTypeTexture ~= nil then
            specialAddedTypeText = zo_iconFormat(string.format(specialAddedTypeTexture, "up"),24,24)
            entryTextTemplateToUse = entryTextTemplate
            entryText = string.format(entryTextTemplateToUse, tostring(dateTimeString), tostring(charName), tostring(setQualityText),tostring(itemTypeIdIcon),tostring(weaponOrArmorTypeIcon),tostring(slotIcon),tostring(traitIcon), tostring(specialAddedTypeText))
        end
    else
        entryTextTemplateToUse = entryTextTemplateNoSpecialAddedType
        entryText = string.format(entryTextTemplateToUse, tostring(dateTimeString), tostring(charName), tostring(setQualityText),tostring(itemTypeIdIcon),tostring(weaponOrArmorTypeIcon),tostring(slotIcon),tostring(traitIcon))
    end
    return entryText
end


------------------------------------------------
--- Dialog Initializers
------------------------------------------------
function WL.WishListWindowAddItemInitialize(control)
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")
    local labelLastAddedHistory = GetControl(content, "LastAddedHistoryLabel")
    local comboBoxBaseControlLastAddedHistory = content:GetNamedChild("LastAddedHistoryCombo")
    local comboLastAddedHistory = ZO_ComboBox_ObjectFromContainer(comboBoxBaseControlLastAddedHistory)
    local textureLastAddedHistory = content:GetNamedChild("LastAddedHistoryTexture")
    local labelItemType = GetControl(content, "ItemTypeText")
    local comboItemType = ZO_ComboBox_ObjectFromContainer(content:GetNamedChild("ItemTypeCombo")) --GetControl(content, "ItemTypeCombo")
    local labelArmorOrWeaponType = GetControl(content, "ArmorOrWeaponTypeText")
    local comboArmorOrWeaponType = ZO_ComboBox_ObjectFromContainer(content:GetNamedChild("ArmorOrWeaponTypeCombo")) --GetControl(content, "ArmorOrWeaponTypeCombo")
    local labelSlot = GetControl(content, "SlotText")
    local comboSlot = ZO_ComboBox_ObjectFromContainer(content:GetNamedChild("SlotCombo")) --GetControl(content, "SlotCombo")
    local labelTrait = GetControl(content, "TraitText")
    local comboTrait = ZO_ComboBox_ObjectFromContainer(content:GetNamedChild("TraitCombo")) --GetControl(content, "TraitCombo")
    local labelQuality = GetControl(content, "QualityText")
    local comboQuality = ZO_ComboBox_ObjectFromContainer(content:GetNamedChild("QualityCombo")) --GetControl(content, "QualityCombo")
    local labelChars = GetControl(content, "CharsText")
    local comboChars = ZO_ComboBox_ObjectFromContainer(content:GetNamedChild("CharsCombo")) --GetControl(content, "CharsCombo")

    ZO_Dialogs_RegisterCustomDialog("WISHLIST_EVENT_ADD_ITEM_DIALOG", {
        customControl = control,
        title = { text = GetString(WISHLIST_DIALOG_ADD_ITEM) },
        mainText = { text = "???" },
        setup = function(dialog, data)
            --local wlWindow = (data ~= nil and data.wlWindow ~= nil and data.wlWindow == true) or false
            descLabel:SetText(WL.currentSetName)

            labelLastAddedHistory:SetText(GetString(WISHLIST_HEADER_LAST_ADDED))
            labelItemType:SetText(GetString(WISHLIST_HEADER_TYPE))
            --labelArmorOrWeaponType:SetText("Armor/Weapon Type")
            labelTrait:SetText(GetString(WISHLIST_HEADER_TRAIT))
            labelQuality:SetText(GetString(WISHLIST_HEADER_QUALITY))
            labelSlot:SetText(GetString(WISHLIST_HEADER_SLOT))
            labelChars:SetText(GetString(WISHLIST_HEADER_CHARS))

            WL.checkCharsData()


            --Last added history combobox: Selected entry callback
            local lastAddedHistoryCallback = function( comboBox, entryText, entry, selectionChanged )
                --d("[WL]lastAddedHistoryCallback-"..entryText)
                --Get the lastAddedData via the id
                textureLastAddedHistory:SetTexture("")
                textureLastAddedHistory:SetHidden(true)
                if entry.id == nil then return end
                local lastAddedViaDialogData = WL.accData.lastAddedViaDialog
                if not lastAddedViaDialogData or not lastAddedViaDialogData[entry.id] then return end
                local entryData = lastAddedViaDialogData[entry.id]
                local specialAddedType = entryData.specialAddedType
                if specialAddedType ~= nil then
                    local specialAddedTypeToTextureFile = WL.addDialogButtonTextures
                    if specialAddedTypeToTextureFile[specialAddedType] ~= nil then
                        textureLastAddedHistory:SetTexture(string.format(specialAddedTypeToTextureFile[specialAddedType], "up"))
                        textureLastAddedHistory:SetHidden(false)
                        textureLastAddedHistory:SetDimensions(28, 28)
                    end
                end

                --Close the current dialog and reload a new one with the correct setData, if the current setId is not
                --the same as of the chosen "lastAdded" combobox
                local delayBeforeChange = 0
                if WL.currentSetId ~= entryData.setId then
                    --Close the dialog, as it needs to be re-opened for a new setId
                    WishListAddItemDialogCancel:callback()
                    local clientLang = WL.clientLang or WL.fallbackSetLang
                    local libSets = WishList.LibSets
                    --Reopen it with the correct setId
                    local setData = {
                        setId       = entryData.setId,
                        names       = libSets.GetSetNames(entryData.setId),
                    }
                    delayBeforeChange = 10
                    WL.lastSelectedLastAddedHistoryEntry = entry
                    WL.showAddItem(setData, true)
                end
                --Call delayed if poup dialog was closed, and re-opened for another setId
                zo_callLater(function()
                    --Set the comboboxes to the rows of the last added entry data
                    --Quality
                    comboQuality:SelectItemByIndex(entryData.quality, false)
                    --Character
                    local charIdx
                    for idx, charData in ipairs(comboChars.m_sortedItems) do
                        if charData and charData.id == entryData.charId then
                            charIdx = idx
                            break
                        end
                    end
                    if charIdx and charIdx ~= nil and charIdx > 0 then
                        comboChars:SelectItemByIndex(charIdx, false)
                    end
                    --ItemType
                    local itemTypeIdx
                    for idx, itemTypeData in ipairs(comboItemType.m_sortedItems) do
                        if itemTypeData and itemTypeData.id == entryData.itemTypeId then
                            itemTypeIdx = idx
                            break
                        end
                    end
                    if itemTypeIdx and itemTypeIdx ~= nil and itemTypeIdx > 0 then
                        comboItemType:SelectItemByIndex(itemTypeIdx, false)
                        zo_callLater(function()
                            --ArmorOrWeaponTyp
                            local armorOrWeaponTypeIdx
                            for idx, armorOrWeaponTypeData in ipairs(comboArmorOrWeaponType.m_sortedItems) do
                                if armorOrWeaponTypeData and armorOrWeaponTypeData.id == entryData.armorOrWeaponType then
                                    armorOrWeaponTypeIdx = idx
                                    break
                                end
                            end
                            if armorOrWeaponTypeIdx and armorOrWeaponTypeIdx ~= nil and armorOrWeaponTypeIdx > 0 then
                                comboArmorOrWeaponType:SelectItemByIndex(armorOrWeaponTypeIdx, false)
                                zo_callLater(function()
                                    --SlotType
                                    local slotTypeIdx
                                    for idx, slotTypeData in ipairs(comboSlot.m_sortedItems) do
                                        if slotTypeData and slotTypeData.id == entryData.slotType then
                                            slotTypeIdx = idx
                                            break
                                        end
                                    end
                                    if slotTypeIdx and slotTypeIdx ~= nil and slotTypeIdx > 0 then
                                        comboSlot:SelectItemByIndex(slotTypeIdx, false)
                                        zo_callLater(function()
                                            --Trait
                                            local traitTypeIdx
                                            for idx, traitTypeData in ipairs(comboTrait.m_sortedItems) do
                                                if traitTypeData and traitTypeData.id == entryData.trait then
                                                    traitTypeIdx = idx
                                                    break
                                                end
                                            end
                                            if traitTypeIdx and traitTypeIdx ~= nil and traitTypeIdx > 0 then
                                                comboTrait:SelectItemByIndex(traitTypeIdx, false)
                                            end
                                        end, 10)
                                    end
                                end, 10)
                            end
                        end, 10)
                    end
                    --Show the tooltip now
                    WL.buildSetItemTooltipForDialog(WishListAddItemDialog, nil)
                end, delayBeforeChange)

            end

            local function createdLastAddedHistoryComboBoxEntries()
                --Last added history combobox
                comboLastAddedHistory:SetSortsItems(false)
                comboLastAddedHistory:ClearItems()
                local lastAddedHistoryData = WL.GetLastAddedHistory()
                --Create a sorted table with non-gap integer index
                local lastAddedHistoryDataSortedByTimeStamp = {}
                for timestamp, lastAddedData in pairs(lastAddedHistoryData) do
                    table.insert(lastAddedHistoryDataSortedByTimeStamp, lastAddedData)
                end
                table.sort(lastAddedHistoryDataSortedByTimeStamp, function(a, b)
                    return a.dateTime < b.dateTime
                end)
                --Add 1 empty entry
                local entry = ZO_ComboBox:CreateItemEntry(" ", function()
                    textureLastAddedHistory:SetTexture("")
                    textureLastAddedHistory:SetHidden(true)
                end)
                entry.id = -1
                comboLastAddedHistory:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
                for idx, lastAddedData in ipairs(lastAddedHistoryDataSortedByTimeStamp) do
                    local entryText = buildLastAddedEntryText(lastAddedData)
                    if entryText ~= nil and entryText ~= "" then
                        local lastAddedEntry = ZO_ComboBox:CreateItemEntry(entryText, lastAddedHistoryCallback)
                        lastAddedEntry.id = lastAddedData.dateTime
                        comboLastAddedHistory:AddItem(lastAddedEntry, ZO_COMBOBOX_SUPRESS_UPDATE)
                    end
                end
                if not WL.lastSelectedLastAddedHistoryEntry then
                    comboLastAddedHistory:SelectItemByIndex(1, true)
                else
                    comboLastAddedHistory:SelectItem(WL.lastSelectedLastAddedHistoryEntry, true)
                    WL.lastSelectedLastAddedHistoryEntry = nil
                end
            end
            createdLastAddedHistoryComboBoxEntries()

            --Add right click context menu to the lastAdded combobox
            ZO_PreHookHandler(comboBoxBaseControlLastAddedHistory, "OnMouseUp", function(comboBoxCtrl, mouseButton, upInside, alt, shift, ctrl)
                if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
                    ClearMenu()
                    --LibCustomMenu
                    if comboLastAddedHistory.m_selectedItemData ~= nil and comboLastAddedHistory.m_selectedItemData.id ~= -1 then
                        AddCustomMenuItem(GetString(WISHLIST_CONTEXTMENU_REMOVE_FROM_LAST_ADDED), function()
                            local entry = comboLastAddedHistory.m_selectedItemData
                            if WL.accData.lastAddedViaDialog and WL.accData.lastAddedViaDialog[entry.id] then
                                textureLastAddedHistory:SetTexture("")
                                textureLastAddedHistory:SetHidden(true)
                                WL.accData.lastAddedViaDialog[entry.id] = nil
                                --As there is no proper "remove item" function we totally need to rebuild the combobox entries...
                                createdLastAddedHistoryComboBoxEntries()
                            end
                        end)
                        AddCustomMenuItem("-", function() end)
                    end
                    if comboLastAddedHistory.m_sortedItems and #comboLastAddedHistory.m_sortedItems > 1 then
                        AddCustomMenuItem(GetString(WISHLIST_CONTEXTMENU_CLEAR_LAST_ADDED), function()
                            --Show ask before clear dialog
                            --But close the current dialog before as no dialog can be shown "above the other opened dialog" :-(
                            textureLastAddedHistory:SetTexture("")
                            textureLastAddedHistory:SetHidden(true)
                            WishListAddItemDialogCancel:callback()
                            WL.showQuestionDialog(GetString(WISHLIST_CLEAR_LAST_ADDED_TITLE), GetString(WISHLIST_CLEAR_LAST_ADDED_TEXT),
                                    function(dialog)
                                        --Clear combobox
                                        comboLastAddedHistory:ClearItems()
                                        --SavedVariables nun noch leeren
                                        WL.accData.lastAddedViaDialog = nil
                                        WL.accData.lastAddedViaDialog = {}
                                    end,
                                    function(dialog) end,
                                    {}
                            )
                        end)
                    end
                    ShowMenu(comboBoxCtrl)

                    return true --do not open the combobox if right clicked
                end
            end)


            --Quality Callback
            local callbackQuality = function( comboBox, entryText, entry, selectionChanged )
                --Rebuild the itemLink to update the quality in the itemLink
                WL.buildSetItemTooltipForDialog(WishListAddItemDialog, nil)
            end

            --Quality combobox
            comboQuality:SetSortsItems(false)
            comboQuality:ClearItems()
            local qualityData = WL.quality
            for quality, qualityDescription in ipairs(qualityData) do
                local entry = ZO_ComboBox:CreateItemEntry(qualityDescription, callbackQuality)
                entry.id = quality
                comboQuality:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
            end
            comboQuality:SelectItemByIndex(1, true)


            --Chars Callback
            local callbackChars = function( comboBox, entryText, entry, selectionChanged ) end

            --Characters dropdown box
            --The name to compare for the pre-selection in the char dropdownbox (currently logged in, or currently chosen at WhishList tab?)
            local charNameToCompare = ""
            if WL.data.preSelectLoggedinCharAtItemAddDialog then
                charNameToCompare = WL.LoggedInCharData.nameClean
            else
                charNameToCompare = WL.CurrentCharData.nameClean
            end

            comboChars:SetSortsItems(true)
            comboChars:ClearItems()
            local cnt = 0
            local currentChar = 0
            for _, charData in ipairs(WL.charsData) do
                local classId = WL.accData.chars[charData.id].class
                local charName = charData.name
                --charName = zo_iconTextFormat(WL.getClassIcon(classId), 20, 20, charName)
                local entry = ZO_ComboBox:CreateItemEntry(charName, callbackChars)
                entry.id = charData.id
                entry.name = charData.name
                entry.nameClean = charData.nameClean
                entry.class = classId
                comboChars:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
                cnt = cnt + 1
                if charNameToCompare == charData.nameClean then
                    currentChar = cnt
                end
            end
            comboChars:SelectItemByIndex(currentChar, true)

            --Traits Callback
            local callbackTraitsTypes = function( comboBox, entryText, entry, selectionChanged )
                WL.buildSetItemTooltipForDialog(WishListAddItemDialog, nil)
            end

            --Slots Callback
            local callbackSlotsTypes = function( comboBox, entryText, entry, selectionChanged )
                local itemTypeId = comboItemType:GetSelectedItemData().id
                local typeId = comboArmorOrWeaponType:GetSelectedItemData().id
                local slotId = 0
                local selectedSlotData = comboSlot:GetSelectedItemData()
                if selectedSlotData == nil then
                    return
                else
                    slotId = selectedSlotData.id
                end

                --Traits
                local traits = {}
                comboTrait:SetSortsItems(true)
                comboTrait:ClearItems()

                --Add 1st entry to trait combobox with "- All traits -"
                local allTraitsTraitId = WISHLIST_TRAIT_TYPE_ALL
                entry = ZO_ComboBox:CreateItemEntry(WL.TraitTypes[allTraitsTraitId], callbackTraitsTypes)
                entry.id = allTraitsTraitId --Any/All traits of current chosen item
                comboTrait:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)

                local setsData = WL.accData.sets[WL.currentSetId]
                for setItemId, _ in pairs(setsData) do
                    if type(setItemId) == "number" then
                        local itemLink = WL.buildItemLink(setItemId, WISHLIST_QUALITY_LEGENDARY) --Always use the legendary quality for the setData
                        local itemType = GetItemLinkItemType(itemLink)
                        local armorOrWeaponType
                        if itemType == ITEMTYPE_ARMOR then
                            armorOrWeaponType = GetItemLinkArmorType(itemLink)
                        elseif itemType == ITEMTYPE_WEAPON then
                            armorOrWeaponType = GetItemLinkWeaponType(itemLink)
                        end
                        local equipType = GetItemLinkEquipType(itemLink)
                        local traitType = GetItemLinkTraitInfo(itemLink)
                        if itemType == itemTypeId and armorOrWeaponType == typeId and equipType == slotId then
                            if traits[traitType] == nil then
                                traits[traitType] = WL.TraitTypes[traitType]
                                entry = ZO_ComboBox:CreateItemEntry(traits[traitType], callbackTraitsTypes)
                                entry.id = traitType
                                comboTrait:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
                            end
                        end
                    end
                end
                comboTrait:SelectItemByIndex(1, true)
                callbackTraitsTypes()
            end

            --Armor/Weapon Type Callback
            local callbackArmorOrWeaponTypes = function( comboBox, entryText, entry, selectionChanged )
                local itemTypeId = comboItemType:GetSelectedItemData().id
                local typeId = comboArmorOrWeaponType:GetSelectedItemData().id

                --Slots
                local slots = {}
                comboSlot:SetSortsItems(true)
                comboSlot:ClearItems()

                local setsData = WL.accData.sets[WL.currentSetId]
                for setItemId, _ in pairs(setsData) do
                    if type(setItemId) == "number" then
                        local itemLink = WL.buildItemLink(setItemId, WISHLIST_QUALITY_LEGENDARY) --Always use the legendary quality for the setData
                        local itemType = GetItemLinkItemType(itemLink)
                        local armorOrWeaponType
                        if itemType == ITEMTYPE_ARMOR then
                            armorOrWeaponType = GetItemLinkArmorType(itemLink)
                        elseif itemType == ITEMTYPE_WEAPON then
                            armorOrWeaponType = GetItemLinkWeaponType(itemLink)
                        end
                        local equipType = GetItemLinkEquipType(itemLink)
                        if itemType == itemTypeId and armorOrWeaponType == typeId then
                            if slots[equipType] == nil then
                                slots[equipType] = WL.SlotTypes[equipType]
                                entry = ZO_ComboBox:CreateItemEntry(slots[equipType], callbackSlotsTypes)
                                entry.id = equipType
                                comboSlot:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
                            end
                        end
                    end
                end

                comboSlot:SelectItemByIndex(1, true)
                callbackSlotsTypes()
            end

            --Item Types Callback
            local callbackItemTypes = function( comboBox, entryText, entry, selectionChanged )
                --Armor/Weapon Type
                local armorOrWeaponTypes = {}
                local itemTypeId = comboItemType:GetSelectedItemData().id
                comboArmorOrWeaponType:SetSortsItems(true)
                comboArmorOrWeaponType:ClearItems()

                local setsData = WL.accData.sets[WL.currentSetId]
                if itemTypeId == ITEMTYPE_ARMOR then
                    labelArmorOrWeaponType:SetText(GetString(SI_ITEMTYPE2) .. " " .. GetString(SI_SMITHING_HEADER_ITEM) ) -- Armor Type

                    for setItemId, _ in pairs(setsData) do
                        if type(setItemId) == "number" then
                            local itemLink = WL.buildItemLink(setItemId, WISHLIST_QUALITY_LEGENDARY) --Always use the legendary quality for the setData
                            local itemType = GetItemLinkItemType(itemLink)
                            if itemType == ITEMTYPE_ARMOR then --Armor
                                local armorOrWeaponType = GetItemLinkArmorType(itemLink)
                                if armorOrWeaponTypes[armorOrWeaponType] == nil then
                                    armorOrWeaponTypes[armorOrWeaponType] = WL.ArmorTypes[armorOrWeaponType]
                                    entry = ZO_ComboBox:CreateItemEntry(armorOrWeaponTypes[armorOrWeaponType], callbackArmorOrWeaponTypes)
                                    entry.id = armorOrWeaponType
                                    comboArmorOrWeaponType:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
                                end
                            end
                        end
                    end

                else
                    labelArmorOrWeaponType:SetText(GetString(SI_ITEMTYPE1) .. " " .. GetString(SI_SMITHING_HEADER_ITEM)) -- Weapon Type

                    for setItemId, _ in pairs(setsData) do
                        if type(setItemId) == "number" then
                            local itemLink = WL.buildItemLink(setItemId, WISHLIST_QUALITY_LEGENDARY) --Always use the legendary quality for the setData
                            local itemType = GetItemLinkItemType(itemLink)
                            if itemType == ITEMTYPE_WEAPON then --Weapon
                                local armorOrWeaponType = GetItemLinkWeaponType(itemLink)
                                if armorOrWeaponTypes[armorOrWeaponType] == nil then
                                    armorOrWeaponTypes[armorOrWeaponType] = WL.WeaponTypes[armorOrWeaponType]
                                    entry = ZO_ComboBox:CreateItemEntry(armorOrWeaponTypes[armorOrWeaponType], callbackArmorOrWeaponTypes)
                                    entry.id = armorOrWeaponType
                                    comboArmorOrWeaponType:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
                                end
                            end
                        end
                    end
                end

                comboArmorOrWeaponType:SelectItemByIndex(1, true)
                callbackArmorOrWeaponTypes()
            end

            --Item types
            local itemTypes = {}
            comboItemType:SetSortsItems(true)
            comboItemType:ClearItems()

            local setsData = WL.accData.sets[WL.currentSetId]
            for setItemId, _ in pairs(setsData) do
                if type(setItemId) == "number" then
                    local itemLink = WL.buildItemLink(setItemId, WISHLIST_QUALITY_LEGENDARY) --Always use the legendary quality for the setData
                    local itemType = GetItemLinkItemType(itemLink)
                    if itemTypes[itemType] == nil then
                        itemTypes[itemType] = WL.ItemTypes[itemType]
                        local entry = ZO_ComboBox:CreateItemEntry(itemTypes[itemType], callbackItemTypes)
                        entry.id = itemType
                        comboItemType:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
                    end
                end
            end
            comboItemType:SelectItemByIndex(1, true)
            callbackItemTypes()
        end,
        noChoiceCallback = function(dialog)
            WL.hideItemLinkTooltip()
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    --local wlWindow = (dialog.data ~= nil and dialog.data.wlWindow ~= nil and dialog.data.wlWindow == true) or false
                    WL.hideItemLinkTooltip()
                    local items, selectedCharData = WL.buildSetItemDataFromAddItemDialog(comboItemType, comboArmorOrWeaponType, comboTrait, comboSlot, comboChars, comboQuality)
                    if items ~= nil and #items > 0 then
                        --Add the currently selected values to the "Last added" history data of the SavedVariables, no special added type!
                        WL.addLastAddedHistoryFromAddItemDialog(WL.currentSetId, comboItemType, comboArmorOrWeaponType, comboTrait, comboSlot, comboChars, comboQuality, nil)
                        WishList:AddItem(items, selectedCharData)
                    end
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)
                    WL.hideItemLinkTooltip()
                end,
            },
        },
    })

    WL.addItemDialog = control
end

function WL.WishListWindowRemoveItemInitialize(control)
    local title     = GetControl(control, "Title")
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")

    ZO_Dialogs_RegisterCustomDialog("WISHLIST_EVENT_REMOVE_ITEM_DIALOG", {
        customControl = control,
        title = { text = "???" },
        mainText = { text = "???" },
        setup = function(dialog, data)
            local wlWindow = (data ~= nil and data.wlWindow ~= nil and data.wlWindow == true) or false
            local removeFromHistory = data.removeFromHistory or false
            --local charNameText = WL.buildCharNameChatText(WL.CurrentCharData, WL.CurrentCharData.id)
            local charNameText = WL.CurrentCharData.name
            charNameText = WL.addCharBrackets(charNameText)
            local setName = data.itemData and data.itemData.name
            --Coming from context menu of e.g. Set Item Collection UI
            local removeType = dialog.data.removeType
            local removeFromAllWishLists = false
            if removeType == WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS or
              removeType == WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS then
                removeFromAllWishLists = true
            end
            local noDataCall = false
            if wlWindow == false then
                if data.itemData == nil then
                    --All items should be removed/changed etc.
                    noDataCall = true
                end
            end
            --Remove item from WishList or history?
            if data.wholeSet then
                if removeFromHistory then
                    title:SetText(zostrfor(GetString(WISHLIST_DIALOG_REMOVE_WHOLE_SET), setName) .. " [" .. GetString(WISHLIST_HISTORY_TITLE) .. "]")
                else
                    title:SetText(zostrfor(GetString(WISHLIST_DIALOG_REMOVE_WHOLE_SET), setName))
                end
                descLabel:SetText(zostrfor(GetString(WISHLIST_DIALOG_REMOVE_WHOLE_SET_QUESTION).. "\n" .. charNameText,  setName))
            else
                local timeStamp
                local dateAndTime
                local itemType
                local armorOrWeaponType
                local slot
                local itemLink
                local traitId
                --Coming from link handler or inventory context menu e.g.??
                if not wlWindow and data ~= nil and data.itemData ~= nil and data.itemData.itemLink ~= nil then
                    itemLink = data.itemData.itemLink
                    timeStamp = data.itemData.timestamp
                    dateAndTime = WL.getDateTimeFormatted(timeStamp)
                    itemType = data.itemData.itemType
                    armorOrWeaponType = data.itemData.armorOrWeaponType
                    slot = data.itemData.slot
                    traitId = GetItemLinkTraitInfo(itemLink)
                elseif noDataCall == false then
                    --Coming from WishList window
                    itemLink = WL.buildItemLink(WL.CurrentItem.id, WL.CurrentItem.quality)
                    timeStamp = data.itemData.timestamp
                    dateAndTime = WL.getDateTimeFormatted(timeStamp)
                    itemType = data.itemData.itemType
                    armorOrWeaponType = data.itemData.armorOrWeaponType
                    slot = data.itemData.slot
                    traitId = data.itemData.trait
                end
                local armorOrWeaponTypeText = ""
                local slotText = ""
                local itemTraitText = ""
                if noDataCall == false then
                    if itemType == ITEMTYPE_WEAPON then
                        --Weapon
                        armorOrWeaponTypeText = WL.WeaponTypes[armorOrWeaponType]
                    elseif itemType == ITEMTYPE_ARMOR then
                        --Armor
                        armorOrWeaponTypeText = WL.ArmorTypes[armorOrWeaponType]
                    end
                    slotText = WL.SlotTypes[slot]
                    itemTraitText = WL.TraitTypes[traitId]
                    itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
                    --Description text of the dialog
                    if data.removeType == WISHLIST_REMOVE_ITEM_TYPE_NORMAL then
                        descLabel:SetText(zostrfor(GetString(WISHLIST_DIALOG_REMOVE_ITEM_QUESTION) .. "\n" .. itemTraitText .. charNameText, itemLink))
                    end
                end
                --Title of the dialog
                local removeItemTitles = {
                    [WISHLIST_REMOVE_ITEM_TYPE_NORMAL]              = GetString(WISHLIST_DIALOG_REMOVE_ITEM),
                    [WISHLIST_REMOVE_ITEM_TYPE_DATEANDTIME]         = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_DATETIME), dateAndTime),
                    [WISHLIST_REMOVE_ITEM_TYPE]                     = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_TYPE), itemType),
                    [WISHLIST_REMOVE_ITEM_TYPE_ARMORANDWEAPONTYPE]  = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_ARMORORWEAPONTYPE), armorOrWeaponTypeText),
                    [WISHLIST_REMOVE_ITEM_TYPE_SLOT]                = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_SLOT), slotText),
                    [WISHLIST_REMOVE_ITEM_TYPE_TRAIT]               = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_TRAIT), itemTraitText),
                    [WISHLIST_REMOVE_ITEM_TYPE_ARMORANDWEAPONTYPE_SLOT] = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_TYPE_ARMORORWEAPONTYPE_SLOT), itemType, armorOrWeaponTypeText, slotText),
                    [WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION] = GetString(WISHLIST_DIALOG_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION),
                    [WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET] = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET), setName),
                    [WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS] = GetString(WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS),
                    [WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS] = ZO_CachedStrFormat(GetString(WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS), setName),
                }
                local titelForRemoveItem = removeItemTitles[data.removeType]
                if titelForRemoveItem == "" then titelForRemoveItem = removeItemTitles[WISHLIST_REMOVE_ITEM_TYPE_NORMAL] end
                if removeFromHistory then
                    titelForRemoveItem = titelForRemoveItem .. " [" .. GetString(WISHLIST_HISTORY_TITLE) .. "]"
                end
                title:SetText(titelForRemoveItem)

                --Build the tooltip data, but only if a single item will be removed
                if data.removeType == WISHLIST_REMOVE_ITEM_TYPE_NORMAL then
                    local virtualListRowControl = {}
                    local style = ""
                    virtualListRowControl.data      = {}
                    virtualListRowControl.data.itemLink   = itemLink
                    virtualListRowControl.data.style      = style
                    WL.buildSetItemTooltipForDialog(WishListRemoveItemDialog, virtualListRowControl)
                else
                    if removeFromAllWishLists == false then
                        descLabel:SetText(titelForRemoveItem .. "?\n" .. charNameText)
                    else
                        descLabel:SetText(titelForRemoveItem .. "?\n" .. GetString(WISHLIST_ALL_WISHLISTS))
                    end
                end
            end
        end,
        noChoiceCallback = function(dialog)
            WL.hideItemLinkTooltip()
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    local wlWindow = (dialog.data ~= nil and dialog.data.wlWindow ~= nil and dialog.data.wlWindow == true) or false
                    WL.hideItemLinkTooltip()
                    --Remove a whole set
                    if dialog.data then
                        local removeFromHistory = dialog.data.removeFromHistory or false
                        local noDataCall = (not wlWindow and dialog.data.itemData == nil) or false
                        local setId = noDataCall == false and dialog.data and dialog.data.itemData and dialog.data.itemData.setId
                        if dialog.data.wholeSet then
                            if removeFromHistory then
                                WishList:RemoveAllHistoryItemsOfSet(setId, WL.CurrentCharData)
                            else
                                WishList:RemoveAllItemsOfSet(setId, WL.CurrentCharData)
                            end
                        else
                            local removeType = dialog.data.removeType
                            local isLinkHandlerItem = (not wlWindow and dialog.data ~= nil and dialog.data.itemData ~= nil and dialog.data.itemData.itemLink ~= nil) or false
                            --Removing one selected item?
                            if removeType == WISHLIST_REMOVE_ITEM_TYPE_NORMAL then
                                if isLinkHandlerItem then
                                    --Coming from the link handler
                                    local linkHandlerItem = {}
                                    linkHandlerItem = dialog.data.itemData
                                    local itemLink = linkHandlerItem.itemLink
                                    linkHandlerItem.id = tonumber(WL.GetItemIDFromLink(itemLink))
                                    local traitId = GetItemLinkTraitInfo(itemLink)
                                    linkHandlerItem.trait = traitId
                                    if removeFromHistory then
                                        WishList:RemoveHistoryItem(linkHandlerItem, WL.LoggedInCharData)
                                    else
                                        WishList:RemoveItem(linkHandlerItem, WL.LoggedInCharData)
                                    end
                                else
                                    if removeFromHistory then
                                        WishList:RemoveHistoryItem(WL.CurrentItem, WL.CurrentCharData)
                                    else
                                        --Coming from the WishList window
                                        WishList:RemoveItem(WL.CurrentItem, WL.CurrentCharData)
                                    end
                                end

                            --Remove several items by date&time, armorOrWeaponType, slot, trait
                            else
                                local criteriaToIdentifyItemsToRemove = {}
                                local removeFromAllWishLists = false
                                if removeType == WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS or
                                  removeType == WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS then
                                    removeFromAllWishLists = true
                                end
                                if noDataCall == false then
                                    local data = dialog.data.itemData
                                    local timeStamp = data.timestamp
                                    local itemType = data.itemType
                                    local armorOrWeaponType = data.armorOrWeaponType
                                    local slot = data.slot
                                    local traitId = data.trait
                                    if removeType     == WISHLIST_REMOVE_ITEM_TYPE_DATEANDTIME then
                                        criteriaToIdentifyItemsToRemove.timestamp = timeStamp
                                    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE_ARMORANDWEAPONTYPE then
                                        criteriaToIdentifyItemsToRemove.armorOrWeaponType = armorOrWeaponType
                                    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE_SLOT then
                                        criteriaToIdentifyItemsToRemove.slot = slot
                                    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE_TRAIT then
                                        criteriaToIdentifyItemsToRemove.trait = traitId
                                    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE then
                                        criteriaToIdentifyItemsToRemove.itemType = itemType
                                    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION then
                                        criteriaToIdentifyItemsToRemove.knownInSetItemCollectionBook = true
                                        criteriaToIdentifyItemsToRemove.setId = nil
                                    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET then
                                        criteriaToIdentifyItemsToRemove.knownInSetItemCollectionBook = true
                                        criteriaToIdentifyItemsToRemove.setId = setId
                                    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS then
                                        criteriaToIdentifyItemsToRemove.knownInSetItemCollectionBook = true
                                        criteriaToIdentifyItemsToRemove.setId = nil
                                        criteriaToIdentifyItemsToRemove.removeFromAllWishLists = true
                                    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS then
                                        criteriaToIdentifyItemsToRemove.knownInSetItemCollectionBook = true
                                        criteriaToIdentifyItemsToRemove.setId = setId
                                        criteriaToIdentifyItemsToRemove.removeFromAllWishLists = true
                                    end
                                else
                                    if removeType == WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION then
                                        criteriaToIdentifyItemsToRemove.knownInSetItemCollectionBook = true
                                        criteriaToIdentifyItemsToRemove.setId = nil
                                    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS then
                                        criteriaToIdentifyItemsToRemove.knownInSetItemCollectionBook = true
                                        criteriaToIdentifyItemsToRemove.setId = nil
                                        criteriaToIdentifyItemsToRemove.removeFromAllWishLists = true
                                    end
                                end
                                if removeFromHistory then
                                    WishList:RemoveAllHistoryItemsWithCriteria(criteriaToIdentifyItemsToRemove, WL.CurrentCharData)
                                else
                                    if removeFromAllWishLists == true then
                                        for _, charDataInLoop in pairs(WL.charsData) do
                                            WishList:RemoveAllItemsWithCriteria(criteriaToIdentifyItemsToRemove, charDataInLoop, true)
                                        end
                                    else
                                        WishList:RemoveAllItemsWithCriteria(criteriaToIdentifyItemsToRemove, WL.CurrentCharData, false)
                                    end
                                end
                            end
                        end
                    end
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)
                    WL.hideItemLinkTooltip()
                end,
            },
        },
    })
end

function WL.WishListWindowReloadItemsInitialize(control)
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")

    ZO_Dialogs_RegisterCustomDialog("WISHLIST_EVENT_RELOAD_ITEMS_DIALOG", {
        customControl = control,
        title = { text = GetString(WISHLIST_DIALOG_RELOAD_ITEMS) },
        mainText = { text = "???" },
        setup = function(dialog, data)
            --local wlWindow = (data ~= nil and data.wlWindow ~= nil and data.wlWindow == true) or false
            descLabel:SetText(GetString(WISHLIST_DIALOG_RELOAD_ITEMS_QUESTION))
        end,
        noChoiceCallback = function(dialog)
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    --local wlWindow = (dialog.data ~= nil and dialog.data.wlWindow ~= nil and dialog.data.wlWindow == true) or false
                    --Disabled with version 2.5 as LibSets provides the setData now and scanning is not needed anymore
                    --WL.LoadSets()
                    WL.GetAllSetData()
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)

                end,
            },
        },
    })
end

function WL.WishListWindowRemoveAllItemsInitialize(control)
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")

    ZO_Dialogs_RegisterCustomDialog("WISHLIST_EVENT_REMOVE_ALL_ITEMS_DIALOG", {
        customControl = control,
        title = { text = GetString(WISHLIST_BUTTON_REMOVE_ALL_TT) },
        mainText = { text = "???" },
        setup = function(dialog, data)
            --local wlWindow = (data ~= nil and data.wlWindow ~= nil and data.wlWindow == true) or false
            --local charNameText = WL.buildCharNameChatText(WL.CurrentCharData, WL.CurrentCharData.id)
            local charNameText = WL.CurrentCharData.name
            charNameText = WL.addCharBrackets(charNameText)
            descLabel:SetText(GetString(WISHLIST_DIALOG_REMOVE_ALL_ITEMS_QUESTION)..charNameText)
        end,
        noChoiceCallback = function(dialog)
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    --local wlWindow = (dialog.data ~= nil and dialog.data.wlWindow ~= nil and dialog.data.wlWindow == true) or false
                    WishList:RemoveAllItems(WL.CurrentCharData)
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)

                end,
            },
        },
    })
end

function WL.WishListWindowClearHistoryInitialize(control)
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")

    ZO_Dialogs_RegisterCustomDialog("WISHLIST_EVENT_CLEAR_HISTORY_DIALOG", {
        customControl = control,
        title = { text = GetString(WISHLIST_BUTTON_CLEAR_HISTORY_TT) },
        mainText = { text = "???" },
        setup = function(dialog, data)
            --local wlWindow = (data ~= nil and data.wlWindow ~= nil and data.wlWindow == true) or false
            --local charNameText = WL.buildCharNameChatText(WL.CurrentCharData, WL.CurrentCharData.id)
            local charNameText = WL.CurrentCharData.name
            charNameText = WL.addCharBrackets(charNameText)
            descLabel:SetText(GetString(WISHLIST_DIALOG_CLEAR_HISTORY_QUESTION)..charNameText)
        end,
        noChoiceCallback = function(dialog)
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    --local wlWindow = (dialog.data ~= nil and dialog.data.wlWindow ~= nil and dialog.data.wlWindow == true) or false
                    WishList:ClearHistory(WL.CurrentCharData)
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)

                end,
            },
        },
    })
end

function WL.WishListWindowChooseCharInitialize(control)
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")
    local labelChars = GetControl(content, "CharsText")
    local comboChars = ZO_ComboBox_ObjectFromContainer(content:GetNamedChild("CharsCombo")) --GetControl(content, "CharsCombo")
    local labelQuality = GetControl(content, "QualityText")
    local comboQualityControl = content:GetNamedChild("QualityCombo")
    local comboQuality = ZO_ComboBox_ObjectFromContainer(comboQualityControl) --GetControl(content, "QualityCombo")

    --Quality Callback
    local callbackQuality = function( comboBox, entryText, entry, selectionChanged ) end

    --Quality combobox
    comboQuality:SetSortsItems(false)
    comboQuality:ClearItems()
    local qualityData = WL.quality
    for quality, qualityDescription in ipairs(qualityData) do
        local entry = ZO_ComboBox:CreateItemEntry(qualityDescription, callbackQuality)
        entry.id = quality
        comboQuality:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end
    comboQuality:SelectItemByIndex(1, true)
    comboQualityControl:SetHidden(true)

    --Chars Callback
    local callbackChars = function( comboBox, entryText, entry, selectionChanged ) end

    ZO_Dialogs_RegisterCustomDialog("WISHLIST_EVENT_CHOOSE_CHAR_DIALOG", {
        customControl = control,
        title = { text = GetString(WISHLIST_BUTTON_CHOOSE_CHARACTER_TT) },
        mainText = { text = "???" },
        setup = function(dialog, data)
            --local wlWindow = (data ~= nil and data.wlWindow ~= nil and data.wlWindow == true) or false
            local isCopyingWishList = (data.copyWishList ~= nil and data.copyWishList == true) or false
            --Characters dropdown box
            --The name to compare:
            --If we are copying a wishlist from this char this char should not be in the list of choosable chars anymore!
            local charNameToCompare = ""
            if isCopyingWishList then
                --The "exclude" charname selected at the wishlist tab
                charNameToCompare = WL.CurrentCharData.nameClean
            else
                --We are not copying a wishlist form a char so we are adding an item from a link handler.
                --Preselect the char by help of the settings: Either logged in char or selected char at the wishlist tab!
                if WL.data.preSelectLoggedinCharAtItemAddDialog then
                    charNameToCompare = WL.LoggedInCharData.nameClean
                else
                    charNameToCompare = WL.CurrentCharData.nameClean
                end
            end

            comboChars:SetSortsItems(true)
            comboChars:ClearItems()
            WL.checkCharsData()
            local cnt = 0
            local currentChar = 0
            for _, charData in ipairs(WL.charsData) do
                --Are we copying a wishlist?
                local doAddCharToComboBox = true
                if isCopyingWishList then
                    --Then do not add the char where we are copying from to the combobox
                    if charNameToCompare == charData.nameClean then
                        doAddCharToComboBox = false
                        --Preselect the first char in the list
                        currentChar = 1
                    end
                end
                if doAddCharToComboBox then
                    local classId = WL.accData.chars[charData.id].class
                    local charName = charData.name
                    --charName = zo_iconTextFormat(WL.getClassIcon(classId), 20, 20, charName)
                    local entry = ZO_ComboBox:CreateItemEntry(charName, callbackChars)
                    entry.id = charData.id
                    entry.name = charData.name
                    entry.nameClean = charData.nameClean
                    entry.class = classId
                    comboChars:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
                    cnt = cnt + 1
                    if charNameToCompare == charData.nameClean then
                        currentChar = cnt
                    end
                end
            end
            comboChars:SelectItemByIndex(currentChar, true)

            labelChars:SetText(GetString(WISHLIST_HEADER_CHARS))
            if isCopyingWishList then
                labelQuality:SetHidden(true)
                comboQualityControl:SetHidden(true)
                --local charNameText = WL.buildCharNameChatText(WL.CurrentCharData, WL.CurrentCharData.id)
                local charNameText = WL.CurrentCharData.name
                charNameText = WL.addCharBrackets(charNameText)
                descLabel:SetText(zostrfor(GetString(WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_COPY_WL), charNameText))
            else
                labelQuality:SetHidden(false)
                labelQuality:SetText(GetString(WISHLIST_HEADER_QUALITY))
                comboQualityControl:SetHidden(false)
                local useAnyQuality = data and data.useAnyQuality
                if useAnyQuality == true then
                    comboQuality:SelectItemByIndex(1, true)
                end

                if data ~= nil and data.dataForChar ~= nil and data.dataForChar[1] ~= nil then
                    local itemLink = data.dataForChar[1].itemLink
                    local countMoreItems = #data.dataForChar - 1
                    local textId = countMoreItems <= 0 and WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_ADD_ITEM or WISHLIST_BUTTON_CHOOSE_CHARACTER_QUESTION_ADD_ITEM_AND_MORE
                    descLabel:SetText(zostrfor(GetString(textId), itemLink, tostring(countMoreItems)))
                end
            end
        end,
        noChoiceCallback = function(dialog)
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    --local wlWindow = (dialog.data ~= nil and dialog.data.wlWindow ~= nil and dialog.data.wlWindow == true) or false
                    local comboCharsSelectedData = comboChars:GetSelectedItemData()
                    local toCharId = comboCharsSelectedData.id
                    local qualityWL = comboQuality:GetSelectedItemData().id
                    if toCharId == nil then return false end
                    local isCopyingWishList = (dialog.data and dialog.data.copyWishList and dialog.data.copyWishList == true) or false
                    if isCopyingWishList then
                        WL.checkCurrentCharData(false)
                        WL.copyWishList(WL.CurrentCharData, toCharId)
                    else
                        local toCharData = WL.getCharDataById(toCharId)
                        --Add item to wishlist of selected char, from link handler / context menu within Set item collections
                        if dialog.data and dialog.data.dataForChar then
                            local dataForChar = dialog.data.dataForChar
                            local useAnyQuality = dialog.data and dialog.data.useAnyQuality
                            if useAnyQuality == true then
                                comboQuality:SelectItemByIndex(1, true)
                            end

                            --Update the quality if not chosen "All"
                            if qualityWL ~= WISHLIST_QUALITY_ALL then
                                for _, item in ipairs(dataForChar) do
                                    item.quality = qualityWL
                                end
                            end
                            WishList:AddItem(dataForChar, toCharData, false)
                        end
                    end
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)

                end,
            },
        },
    })
end

function WL.WishListWindowChangeQualityInitialize(control)
    local title     = GetControl(control, "Title")
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")

    local labelQuality = GetControl(content, "QualityText")
    local comboQualityControl = content:GetNamedChild("QualityCombo")
    local comboQuality = ZO_ComboBox_ObjectFromContainer(comboQualityControl) --GetControl(content, "QualityCombo")

    --Quality Callback
    local callbackQuality = function( comboBox, entryText, entry, selectionChanged ) end

    ZO_Dialogs_RegisterCustomDialog("WISHLIST_EVENT_CHANGE_QUALITY_DIALOG", {
        customControl = control,
        title = { text = "???" },
        mainText = { text = "???" },
        setup = function(dialog, data)
            local wlWindow = (data ~= nil and data.wlWindow ~= nil and data.wlWindow == true) or false
            --local charNameText = WL.buildCharNameChatText(WL.CurrentCharData, WL.CurrentCharData.id)
            local charNameText = WL.CurrentCharData.name
            charNameText = WL.addCharBrackets(charNameText)
            labelQuality:SetText(GetString(WISHLIST_HEADER_QUALITY))

            --Quality combobox
            comboQuality:SetSortsItems(false)
            comboQuality:ClearItems()
            local qualityData = WL.quality
            local counter = 0
            local currentQualityIndex = 1
            for quality, qualityDescription in ipairs(qualityData) do
                local entry = ZO_ComboBox:CreateItemEntry(qualityDescription, callbackQuality)
                entry.id = quality
                comboQuality:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
                if not data.wholeSet then
                    counter = counter + 1
                    if WL.CurrentItem and WL.CurrentItem.quality and quality == WL.CurrentItem.quality then
                        currentQualityIndex = counter
                    end
                end
            end
            --Select the current quality of the item in the quality combobox
            comboQuality:SelectItemByIndex(currentQualityIndex, true)

            --Change quality of whole set or single item?
            if data.wholeSet then
                local setName = data.itemData.name
                title:SetText(zostrfor(GetString(WISHLIST_DIALOG_CHANGE_QUALITY_WHOLE_SET) .. " \'<<1>>\'", setName))
                descLabel:SetText(zostrfor(GetString(WISHLIST_DIALOG_CHANGE_QUALITY_WHOLE_SET_QUESTION).. "\n" .. charNameText,  setName))
            else
                local timeStamp
                local dateAndTime
                local itemType
                local armorOrWeaponType
                local slot
                local itemLink
                local traitId
                --Coming from link handler??
                if not wlWindow and data ~= nil and data.itemData ~= nil and data.itemData.itemLink ~= nil then
                    itemLink = data.itemData.itemLink
                    timeStamp = data.itemData.timestamp
                    dateAndTime = WL.getDateTimeFormatted(timeStamp)
                    itemType = data.itemData.itemType
                    armorOrWeaponType = data.itemData.armorOrWeaponType
                    slot = data.itemData.slot
                    traitId = GetItemLinkTraitInfo(itemLink)
                else
                    --Coming from WishList window
                    itemLink = WL.buildItemLink(WL.CurrentItem.id, WL.CurrentItem.quality)
                    timeStamp = data.itemData.timestamp
                    dateAndTime = WL.getDateTimeFormatted(timeStamp)
                    itemType = data.itemData.itemType
                    armorOrWeaponType = data.itemData.armorOrWeaponType
                    slot = data.itemData.slot
                    traitId = data.itemData.trait
                end
                local armorOrWeaponTypeText = ""
                if itemType == ITEMTYPE_WEAPON then
                    --Weapon
                    armorOrWeaponTypeText = WL.WeaponTypes[armorOrWeaponType]
                elseif itemType == ITEMTYPE_ARMOR then
                    --Armor
                    armorOrWeaponTypeText = WL.ArmorTypes[armorOrWeaponType]
                end
                local slotText = WL.SlotTypes[slot]
                local itemTraitText = WL.TraitTypes[traitId]
                itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
                --Description text of the dialog
                descLabel:SetText(zostrfor(GetString(WISHLIST_DIALOG_CHANGE_QUALITY_QUESTION) .. "\n" .. itemTraitText .. charNameText, itemLink))
                --Title of the dialog
                title:SetText(GetString(WISHLIST_DIALOG_CHANGE_QUALITY))

                --Build the tooltip data, but only if a single item will be removed
                local virtualListRowControl = {}
                local style = ""
                virtualListRowControl.data      = {}
                virtualListRowControl.data.itemLink   = itemLink
                virtualListRowControl.data.style      = style
                WL.buildSetItemTooltipForDialog(WishListChangeQualityDialog, virtualListRowControl)
            end
        end,
        noChoiceCallback = function(dialog)
            WL.hideItemLinkTooltip()
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    local wlWindow = (dialog.data ~= nil and dialog.data.wlWindow ~= nil and dialog.data.wlWindow == true) or false
                    WL.hideItemLinkTooltip()
                    --Remove a whole set
                    if dialog.data then
                        local newQuality = comboQuality:GetSelectedItemData().id
                        if dialog.data.wholeSet then
                            WishList:ChangeQualityOfItemsOfSet(dialog.data.itemData.setId, WL.CurrentCharData, newQuality)
                        else
                            local isLinkHandlerItem = (not wlWindow and dialog.data ~= nil and dialog.data.itemData ~= nil and dialog.data.itemData.itemLink ~= nil) or false
                            if isLinkHandlerItem then
                                --Coming from the link handler
                                local linkHandlerItem = {}
                                linkHandlerItem = dialog.data.itemData
                                local itemLink = linkHandlerItem.itemLink
                                linkHandlerItem.id = tonumber(WL.GetItemIDFromLink(itemLink))
                                local traitId = GetItemLinkTraitInfo(itemLink)
                                linkHandlerItem.trait = traitId
                                WishList:ChangeQualityOfItem(linkHandlerItem, WL.LoggedInCharData, newQuality)
                            else
                                --Coming from the WishList window
                                WishList:ChangeQualityOfItem(WL.CurrentItem, WL.CurrentCharData, newQuality)
                            end
                        end
                    end
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)
                    WL.hideItemLinkTooltip()
                end,
            },
        },
    })
end

--Gear markers
function WL.WishListWindowAddGearMarkerInitialize(control)
    local title     = GetControl(control, "Title")
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")

    ZO_Dialogs_RegisterCustomDialog("WISHLIST_EVENT_ADD_GEAR_MARKER_DIALOG", {
        customControl = control,
        title = { text = "???" },
        mainText = { text = "???" },
        setup = function(dialog, data)
            local wlWindow = (data ~= nil and data.wlWindow ~= nil and data.wlWindow == true) or false
            local gearData = data.gearData
            if not gearData.gearId then return end
            local gearMarkerTextureStr = WL_getGearMarkerTexture(gearData, true, 28, 28)
            if gearMarkerTextureStr == nil then gearMarkerTextureStr = "" end
            --local charNameText = WL.buildCharNameChatText(WL.CurrentCharData, WL.CurrentCharData.id)
            local charNameText = WL.CurrentCharData.name
            charNameText = WL.addCharBrackets(charNameText)
            local setName = data.itemData and data.itemData.name
            --Coming from context menu of e.g. Set Item Collection UI
            local assignType        = dialog.data.assignType
            local addToAllWishLists = data.addToAllWishLists
            local noDataCall        = false
            if wlWindow == false then
                if data.itemData == nil then
                    --All items should be addd/changed etc.
                    noDataCall = true
                end
            end
            --d(">wholeSet: " ..tostring(data.wholeSet) .. ", noDataCall: " ..tostring(noDataCall).. ", assignType: " ..tostring(assignType).. ", addToAllWishLists: " ..tostring(addToAllWishLists))

            --Add gear marker from item / whole set
            if data.wholeSet then
                title:SetText(zostrfor(GetString(WISHLIST_DIALOG_ADD_GEAR_WHOLE_SET), setName))
                --Add all gear markers to the set
                if assignType ~= WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_NORMAL then
                    --Not possible, only 1 gear marker icon can be added
                    return
                    --descLabel:SetText(zostrfor(GetString(WISHLIST_DIALOG_ADD_GEAR_WHOLE_SET_QUESTION).. "\n" .. charNameText, setName))
                else
                    --Add only selected gear marker to the set
                    descLabel:SetText(zostrfor(GetString(WISHLIST_DIALOG_ADD_SELECTED_GEAR_WHOLE_SET_QUESTION).. "\n" .. charNameText, gearMarkerTextureStr, setName))
                end
            else
                --[[
                local timeStamp
                local dateAndTime
                local itemType
                local armorOrWeaponType
                local slot
                local traitId
                ]]
                local itemLink
                --Coming from link handler or inventory context menu e.g.??
                if not wlWindow and data ~= nil and data.itemData ~= nil and data.itemData.itemLink ~= nil then
                    itemLink = data.itemData.itemLink
                    --timeStamp = data.itemData.timestamp
                    --dateAndTime = WL.getDateTimeFormatted(timeStamp)
                    --itemType = data.itemData.itemType
                    --armorOrWeaponType = data.itemData.armorOrWeaponType
                    --slot = data.itemData.slot
                    --traitId = GetItemLinkTraitInfo(itemLink)
                elseif noDataCall == false then
                    --Coming from WishList window
                    itemLink = WL.buildItemLink(WL.CurrentItem.id, WL.CurrentItem.quality)
                    --timeStamp = data.itemData.timestamp
                    --dateAndTime = WL.getDateTimeFormatted(timeStamp)
                    --itemType = data.itemData.itemType
                    --armorOrWeaponType = data.itemData.armorOrWeaponType
                    --slot = data.itemData.slot
                    --traitId = data.itemData.trait
                end
                if noDataCall == false then
                    --Description text of the dialog
                    if assignType == WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_NORMAL then
                        descLabel:SetText(zostrfor(GetString(WISHLIST_DIALOG_ADD_GEAR_MARKER_QUESTION) .. "\n" .. gearMarkerTextureStr .. charNameText, itemLink))
                    end
                end
                --Title of the dialog
                local addItemTitles = {
                    [WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_NORMAL] = GetString(WISHLIST_DIALOG_ADD_GEAR_MARKER),
                    [WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_ALL]    = zostrfor(GetString(WISHLIST_DIALOG_ADD_GEAR_MARKER_ALL), gearMarkerTextureStr),
                    --[[
                    [WISHLIST_ADD_ITEM_TYPE_DATEANDTIME]         = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_ADD_ITEM_DATETIME), dateAndTime),
                    [WISHLIST_ADD_ITEM_TYPE]                     = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_ADD_ITEM_TYPE), itemType),
                    [WISHLIST_ADD_ITEM_TYPE_ARMORANDWEAPONTYPE]  = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_ADD_ITEM_ARMORORWEAPONTYPE), armorOrWeaponTypeText),
                    [WISHLIST_ADD_ITEM_TYPE_SLOT]                = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_ADD_ITEM_SLOT), slotText),
                    [WISHLIST_ADD_ITEM_TYPE_TRAIT]               = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_ADD_ITEM_TRAIT), itemTraitText),
                    [WISHLIST_ADD_ITEM_TYPE_ARMORANDWEAPONTYPE_SLOT] = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_ADD_ITEM_TYPE_ARMORORWEAPONTYPE_SLOT), itemType, armorOrWeaponTypeText, slotText),
                    [WISHLIST_ADD_ITEM_TYPE_KNOWN_SETITEMCOLLECTION] = GetString(WISHLIST_DIALOG_ADD_ITEM_KNOWN_SETITEMCOLLECTION),
                    [WISHLIST_ADD_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET] = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_ADD_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET), setName),
                    [WISHLIST_ADD_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS] = GetString(WISHLIST_CONTEXTMENU_ADD_ITEM_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS),
                    [WISHLIST_ADD_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS] = ZO_CachedStrFormat(GetString(WISHLIST_CONTEXTMENU_ADD_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS), setName),
                    ]]
                }
                local titelForAddItem = addItemTitles[assignType]
                if titelForAddItem == "" then titelForAddItem = addItemTitles[WISHLIST_ADD_GEAR_MARKER_ITEM_TYPE_NORMAL] end
                title:SetText(titelForAddItem)

                --Build the tooltip data, but only if a single item will be addd
                if assignType == WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_NORMAL then
                    local virtualListRowControl = {}
                    local style = ""
                    virtualListRowControl.data      = {}
                    virtualListRowControl.data.itemLink   = itemLink
                    virtualListRowControl.data.style      = style
                    WL.buildSetItemTooltipForDialog(WishListAddGearMarkerDialog, virtualListRowControl)
                else
                    if addToAllWishLists == false then
                        descLabel:SetText(titelForAddItem .. "?\n" .. charNameText)
                    else
                        descLabel:SetText(titelForAddItem .. "?\n" .. GetString(WISHLIST_ALL_WISHLISTS))
                    end
                end
            end
        end,
        noChoiceCallback = function(dialog)
            WL.hideItemLinkTooltip()
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    local wlWindow = (dialog.data ~= nil and dialog.data.wlWindow ~= nil and dialog.data.wlWindow == true) or false
                    WL.hideItemLinkTooltip()
                    --Add a whole set
                    if dialog.data and dialog.data.gearData and dialog.data.gearData.gearId then
                        local gearData = dialog.data.gearData
                        local noDataCall = (not wlWindow and dialog.data.itemData == nil) or false
                        local assignType = dialog.data.assignType
                        local setId      = noDataCall == false and dialog.data and dialog.data.itemData and dialog.data.itemData.setId
                        if dialog.data.wholeSet then
                            if assignType == WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_ALL then
                                --Not possible, only 1 gear texture can be assigned
                                --Add all gear markers from the set
                                --WishList:AddGearMarkerToSet(setId, WL.CurrentCharData, gearData, true)
                                return
                            elseif assignType == WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_NORMAL then
                                --Add only selected gear marker from the set
                                WishList:AddGearMarkerToSet(setId, WL.CurrentCharData, gearData, false)
                            end

                        else
                            local isLinkHandlerItem = (not wlWindow and dialog.data ~= nil and dialog.data.itemData ~= nil and dialog.data.itemData.itemLink ~= nil) or false
                            --Removing one selected item?
                            if assignType == WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_NORMAL then
                                if isLinkHandlerItem == true then
                                    --Coming from the link handler
                                    local linkHandlerItem = {}
                                    linkHandlerItem = dialog.data.itemData
                                    local itemLink = linkHandlerItem.itemLink
                                    linkHandlerItem.id = tonumber(WL.GetItemIDFromLink(itemLink))
                                    local traitId = GetItemLinkTraitInfo(itemLink)
                                    linkHandlerItem.trait = traitId
--d(">link handler")
                                    WishList:AddGearMarker(linkHandlerItem, WL.LoggedInCharData, gearData)
                                else
--d(">WishList window")
                                    --Coming from the WishList window
                                    WishList:AddGearMarker(WL.CurrentItem, WL.CurrentCharData, gearData)
                                end

                            --Add gear markers dependent on criteria, e.g. add to all items
                            else
                                local addGearMarkersToAllItensOnWishList = false
                                local criteriaToIdentifyItemsToAdd       = {}
                                local addToAllWishLists = dialog.data.addToAllWishLists
                                addToAllWishLists = addToAllWishLists or false
                                if assignType == WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_ALL then
                                    addGearMarkersToAllItensOnWishList = true
                                end
                                if noDataCall == false then
                                    local data = dialog.data.itemData
                                    if assignType == WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_ALL then
                                        addGearMarkersToAllItensOnWishList = true
                                        criteriaToIdentifyItemsToAdd.setId = nil
                                        criteriaToIdentifyItemsToAdd.addToAllWishLists = addToAllWishLists
                                    end
                                else
                                    if assignType == WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_ALL then
                                        addGearMarkersToAllItensOnWishList = true
                                        criteriaToIdentifyItemsToAdd.setId = nil
                                        criteriaToIdentifyItemsToAdd.addToAllWishLists = addToAllWishLists
                                    end
                                end
                                if addToAllWishLists == true then
                                    for _, charDataInLoop in pairs(WL.charsData) do
                                        WishList:AddAllGearMarkersWithCriteria(criteriaToIdentifyItemsToAdd, charDataInLoop, true, gearData, addGearMarkersToAllItensOnWishList)
                                    end
                                else
                                    WishList:AddAllGearMarkersWithCriteria(criteriaToIdentifyItemsToAdd, WL.CurrentCharData, false, gearData, addGearMarkersToAllItensOnWishList)
                                end
                            end
                        end
                    end
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)
                    WL.hideItemLinkTooltip()
                end,
            },
        },
    })
end

function WL.WishListWindowRemoveGearMarkerInitialize(control)
    local title     = GetControl(control, "Title")
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")

    ZO_Dialogs_RegisterCustomDialog("WISHLIST_EVENT_REMOVE_GEAR_MARKER_DIALOG", {
        customControl = control,
        title = { text = "???" },
        mainText = { text = "???" },
        setup = function(dialog, data)
            local wlWindow = (data ~= nil and data.wlWindow ~= nil and data.wlWindow == true) or false
            local gearData = data.gearData
            if not gearData.gearId then return end
            local gearMarkerTextureStr = WL_getGearMarkerTexture(gearData, true, 28, 28)
            if gearMarkerTextureStr == nil then gearMarkerTextureStr = "" end

            --local charNameText = WL.buildCharNameChatText(WL.CurrentCharData, WL.CurrentCharData.id)
            local charNameText = WL.CurrentCharData.name
            charNameText = WL.addCharBrackets(charNameText)
            local setName = data.itemData and data.itemData.name
            --Coming from context menu of e.g. Set Item Collection UI
            local removeType = dialog.data.removeType
            local removeFromAllWishLists = data.removeFromAllWishLists
            local noDataCall = false
            if wlWindow == false then
                if data.itemData == nil then
                    --All items should be removed/changed etc.
                    noDataCall = true
                end
            end
            --Remove gear marker from item / whole set
            if data.wholeSet then
                title:SetText(zostrfor(GetString(WISHLIST_DIALOG_REMOVE_GEAR_WHOLE_SET), setName))
                --Remove all gear markes of the set
                if removeType == WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_ALL then
                    descLabel:SetText(zostrfor(GetString(WISHLIST_DIALOG_REMOVE_GEAR_WHOLE_SET_QUESTION).. "\n" .. charNameText, setName))
                else
                    --Remove only selected gear marker of the set
                    descLabel:SetText(zostrfor(GetString(WISHLIST_DIALOG_REMOVE_SELECTED_GEAR_WHOLE_SET_QUESTION).. "\n" .. charNameText, gearMarkerTextureStr, setName))
                end
            else
                --[[
                local timeStamp
                local dateAndTime
                local itemType
                local armorOrWeaponType
                local slot
                local traitId
                ]]
                local itemLink
                --Coming from link handler or inventory context menu e.g.??
                if not wlWindow and data ~= nil and data.itemData ~= nil and data.itemData.itemLink ~= nil then
                    itemLink = data.itemData.itemLink
                    --timeStamp = data.itemData.timestamp
                    --dateAndTime = WL.getDateTimeFormatted(timeStamp)
                    --itemType = data.itemData.itemType
                    --armorOrWeaponType = data.itemData.armorOrWeaponType
                    --slot = data.itemData.slot
                    --traitId = GetItemLinkTraitInfo(itemLink)
                elseif noDataCall == false then
                    --Coming from WishList window
                    itemLink = WL.buildItemLink(WL.CurrentItem.id, WL.CurrentItem.quality)
                    --timeStamp = data.itemData.timestamp
                    --dateAndTime = WL.getDateTimeFormatted(timeStamp)
                    --itemType = data.itemData.itemType
                    --armorOrWeaponType = data.itemData.armorOrWeaponType
                    --slot = data.itemData.slot
                    --traitId = data.itemData.trait
                end
                if noDataCall == false then
                    --Description text of the dialog
                    if data.removeType == WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_NORMAL then
                        descLabel:SetText(zostrfor(GetString(WISHLIST_DIALOG_REMOVE_GEAR_MARKER_QUESTION) .. "\n" .. gearMarkerTextureStr .. charNameText, itemLink))
                    end
                end
                --Title of the dialog
                local removeItemTitles = {
                    [WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_NORMAL] = GetString(WISHLIST_DIALOG_REMOVE_GEAR_MARKER),
                    [WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_ALL]    = zostrfor(GetString(WISHLIST_DIALOG_REMOVE_GEAR_MARKER_ALL), gearMarkerTextureStr),
                    --[[
                    [WISHLIST_REMOVE_ITEM_TYPE_DATEANDTIME]         = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_DATETIME), dateAndTime),
                    [WISHLIST_REMOVE_ITEM_TYPE]                     = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_TYPE), itemType),
                    [WISHLIST_REMOVE_ITEM_TYPE_ARMORANDWEAPONTYPE]  = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_ARMORORWEAPONTYPE), armorOrWeaponTypeText),
                    [WISHLIST_REMOVE_ITEM_TYPE_SLOT]                = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_SLOT), slotText),
                    [WISHLIST_REMOVE_ITEM_TYPE_TRAIT]               = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_TRAIT), itemTraitText),
                    [WISHLIST_REMOVE_ITEM_TYPE_ARMORANDWEAPONTYPE_SLOT] = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_TYPE_ARMORORWEAPONTYPE_SLOT), itemType, armorOrWeaponTypeText, slotText),
                    [WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION] = GetString(WISHLIST_DIALOG_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION),
                    [WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET] = ZO_CachedStrFormat(GetString(WISHLIST_DIALOG_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET), setName),
                    [WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS] = GetString(WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS),
                    [WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS] = ZO_CachedStrFormat(GetString(WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS), setName),
                    ]]
                }
                local titelForRemoveItem = removeItemTitles[data.removeType]
                if titelForRemoveItem == "" then titelForRemoveItem = removeItemTitles[WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_NORMAL] end
                title:SetText(titelForRemoveItem)

                --Build the tooltip data, but only if a single item will be removed
                if data.removeType == WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_NORMAL then
                    local virtualListRowControl = {}
                    local style = ""
                    virtualListRowControl.data      = {}
                    virtualListRowControl.data.itemLink   = itemLink
                    virtualListRowControl.data.style      = style
                    WL.buildSetItemTooltipForDialog(WishListRemoveGearMarkerDialog, virtualListRowControl)
                else
                    if removeFromAllWishLists == false then
                        descLabel:SetText(titelForRemoveItem .. "?\n" .. charNameText)
                    else
                        descLabel:SetText(titelForRemoveItem .. "?\n" .. GetString(WISHLIST_ALL_WISHLISTS))
                    end
                end
            end
        end,
        noChoiceCallback = function(dialog)
            WL.hideItemLinkTooltip()
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    local wlWindow = (dialog.data ~= nil and dialog.data.wlWindow ~= nil and dialog.data.wlWindow == true) or false
                    WL.hideItemLinkTooltip()
                    --Remove a whole set
                    if dialog.data and dialog.data.gearData and dialog.data.gearData.gearId then
                        local gearData = dialog.data.gearData
                        local noDataCall = (not wlWindow and dialog.data.itemData == nil) or false
                        local removeType = dialog.data.removeType
                        local setId = noDataCall == false and dialog.data and dialog.data.itemData and dialog.data.itemData.setId
                        if dialog.data.wholeSet then
                            if removeType == WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_ALL then
                                --Remove all gear markers from the set
                                WishList:RemoveGearMarkerOfSet(setId, WL.CurrentCharData, gearData, true)
                            elseif removeType == WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_NORMAL then
                                --Remove only selected gear marker from the set
                                WishList:RemoveGearMarkerOfSet(setId, WL.CurrentCharData, gearData, false)
                            end

                        else
                            local isLinkHandlerItem = (not wlWindow and dialog.data ~= nil and dialog.data.itemData ~= nil and dialog.data.itemData.itemLink ~= nil) or false
                            --Removing one selected item?
                            if removeType == WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_NORMAL then
                                if isLinkHandlerItem then
                                    --Coming from the link handler
                                    local linkHandlerItem = {}
                                    linkHandlerItem = dialog.data.itemData
                                    local itemLink = linkHandlerItem.itemLink
                                    linkHandlerItem.id = tonumber(WL.GetItemIDFromLink(itemLink))
                                    local traitId = GetItemLinkTraitInfo(itemLink)
                                    linkHandlerItem.trait = traitId
                                    WishList:RemoveGearMarker(linkHandlerItem, WL.LoggedInCharData, gearData)
                                else
                                    --Coming from the WishList window
                                    WishList:RemoveGearMarker(WL.CurrentItem, WL.CurrentCharData, gearData)
                                end

                            --Remove several gear markers (e.g. all)
                            else
                                local removeAllGearMarkers = false
                                local criteriaToIdentifyItemsToRemove = {}
                                local removeFromAllWishLists = dialog.data.removeFromAllWishLists
                                removeFromAllWishLists = removeFromAllWishLists or false
                                if removeType == WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_ALL then
                                    removeAllGearMarkers = true
                                end
                                if noDataCall == false then
                                    local data = dialog.data.itemData
                                    if removeType == WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_ALL then
                                        removeAllGearMarkers = true
                                        criteriaToIdentifyItemsToRemove.setId = nil
                                        criteriaToIdentifyItemsToRemove.removeFromAllWishLists = removeFromAllWishLists
                                    end
                                else
                                    if removeType == WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_ALL then
                                        removeAllGearMarkers = true
                                        criteriaToIdentifyItemsToRemove.setId = nil
                                        criteriaToIdentifyItemsToRemove.removeFromAllWishLists = removeFromAllWishLists
                                    end
                                end
                                if removeFromAllWishLists == true then
                                    for _, charDataInLoop in pairs(WL.charsData) do
                                        WishList:RemoveAllGearMarkersWithCriteria(criteriaToIdentifyItemsToRemove, charDataInLoop, true, gearData, removeAllGearMarkers)
                                    end
                                else
                                    WishList:RemoveAllGearMarkersWithCriteria(criteriaToIdentifyItemsToRemove, WL.CurrentCharData, false, gearData, removeAllGearMarkers)
                                end
                            end
                        end
                    end
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)
                    WL.hideItemLinkTooltip()
                end,
            },
        },
    })
end

------------------------------------------------
--- Dialog Functions
------------------------------------------------
--Build the itemLink and create the item tooltip to show next to the dialog
function WL.buildSetItemTooltipForDialog(dialogCtrl, tooltipData)
    --Build the set data from the comboboxes of the dialog control
    local control = {}
    if tooltipData == nil then
        control = WL.buildItemlinkTooltipData(dialogCtrl)
    else
        control = tooltipData
    end
    if control == nil then return nil end
    --Show the tooltip for the item now
    WL.showItemLinkTooltip(control, dialogCtrl, TOPRIGHT, -50, -100, TOPLEFT)
end

--Add the currently selected data of the add item dialog to last added history in the SavedVariables
function WL.addLastAddedHistoryFromAddItemDialog(setId, comboItemType, comboArmorOrWeaponType, comboTrait, comboSlot, comboChars, comboQuality, specialAddedType)
    --local entryTextTemplate = "dateTime: %s, SetId: %s, itemType: %s, weaponOrArmorType: %s, slotType: %s, trait: %s, quality: %s, charId: %s, specialAddedType: %s"
    local itemTypeId = comboItemType:GetSelectedItemData().id
    local typeId = comboArmorOrWeaponType:GetSelectedItemData().id
    local traitId = comboTrait:GetSelectedItemData().id
    local slotId = comboSlot:GetSelectedItemData().id
    local qualityId = comboQuality:GetSelectedItemData().id
    --Selected character ID and name for the SavedVars
    local comboCharsSelectedData = comboChars:GetSelectedItemData()
    local charId = comboCharsSelectedData.id

    local newAddedData = {}
    newAddedData.dateTime = GetTimeStamp()
    newAddedData.setId = setId
    newAddedData.itemTypeId = itemTypeId
    newAddedData.armorOrWeaponType = typeId
    newAddedData.specialAddedType = specialAddedType
    newAddedData.slotType = slotId
    newAddedData.trait = traitId
    newAddedData.quality = qualityId
    newAddedData.charId = charId

    --local entryText = string.format(entryTextTemplate, tostring(os.date("%c", newAddedData.dateTime)), tostring(setId),tostring(itemTypeId),tostring(typeId),tostring(slotId),tostring(traitId),tostring(qualityId),tostring(charId),tostring(specialAddedType))
--d("[WL.addLastAddedHistoryFromAddItemDialog] " .. entryText)
    WL:AddLastAddedHistory(newAddedData)
end


--Get items which would be added to the WishList via the Add item dialog
function WL.buildSetItemDataFromAddItemDialog(comboItemType, comboArmorOrWeaponType, comboTrait, comboSlot, comboChars, comboQuality)
    local itemTypeId = comboItemType:GetSelectedItemData().id
    local armorOrWeaponTypeId = comboArmorOrWeaponType:GetSelectedItemData().id
    local traitId = comboTrait:GetSelectedItemData().id
    local slotId = comboSlot:GetSelectedItemData().id
    local qualityId = comboQuality:GetSelectedItemData().id
    local comboCharsSelectedData = comboChars:GetSelectedItemData()

    --Selected character ID and name for the SavedVars
    local charId = comboCharsSelectedData.id
    local charName = comboCharsSelectedData.name
    local charNameClean = comboCharsSelectedData.nameClean
    local charClass = comboCharsSelectedData.class
    local selectedCharData = {}
    selectedCharData.id         = charId
    selectedCharData.name       = charName
    selectedCharData.nameClean  = charNameClean
    selectedCharData.class      = charClass

    local items = WL.getSetItemsByCriteria(WL.currentSetId, itemTypeId, armorOrWeaponTypeId, traitId, slotId, qualityId, false)

    return items, selectedCharData
end

function WL.showAddItem(setData, comingFromWishListWindow, doNotUpdateCurrentCharData)
    comingFromWishListWindow = comingFromWishListWindow or false
    doNotUpdateCurrentCharData = doNotUpdateCurrentCharData or false
    WL.createWindow(false)
    local clientLang = WL.clientLang or WL.fallbackSetLang
    WL.currentSetId = setData.setId
    WL.currentSetName = setData.names and setData.names[clientLang] or setData.setNames[clientLang]
    --Character data was chosen at external addon? Or are we coming from internal WishList?
    if not doNotUpdateCurrentCharData then
d(">WL.showAddItem -> checkCurrentCharData")
        WL.checkCurrentCharData()
    end
    ZO_Dialogs_ShowDialog("WISHLIST_EVENT_ADD_ITEM_DIALOG", {set=setData.setId, wlWindow=comingFromWishListWindow})
end

function WL.showRemoveItem(item, removeWholeSet, comingFromWishListWindow, removeFromHistory, removeType)
    if removeType == nil then removeType = WISHLIST_REMOVE_ITEM_TYPE_NORMAL end
    removeWholeSet = removeWholeSet or false
    comingFromWishListWindow = comingFromWishListWindow or false
    removeFromHistory = removeFromHistory or false
    WL.createWindow(false)
    WL.CurrentItem = item
    WL.checkCurrentCharData()
    ZO_Dialogs_ShowDialog("WISHLIST_EVENT_REMOVE_ITEM_DIALOG", {itemData=item, wholeSet=removeWholeSet, wlWindow=comingFromWishListWindow, removeFromHistory=removeFromHistory, removeType=removeType})
end

function WL.ShowReloadItems(comingFromWishListWindow)
    comingFromWishListWindow = comingFromWishListWindow or false
    WL.createWindow(false)
    ZO_Dialogs_ShowDialog("WISHLIST_EVENT_RELOAD_ITEMS_DIALOG", { wlWindow=comingFromWishListWindow })
end

function WL.ShowRemoveAllItems(comingFromWishListWindow)
    comingFromWishListWindow = comingFromWishListWindow or false
    WL.createWindow(false)
    WL.checkCurrentCharData()
    if not WL.IsEmpty(WL.CurrentCharData) then
        ZO_Dialogs_ShowDialog("WISHLIST_EVENT_REMOVE_ALL_ITEMS_DIALOG", { wlWindow=comingFromWishListWindow })
    end
end

function WL.ShowChooseChar(doAWishListCopy, addItemForCharData, comingFromWishListWindow, useAnyQuality)
    comingFromWishListWindow = comingFromWishListWindow or false
    useAnyQuality = useAnyQuality or false
    WL.createWindow(false)
    --Get the currently selected character from the Wishlist tab
    WL.checkCurrentCharData(false)
    doAWishListCopy = doAWishListCopy or false
    ZO_Dialogs_ShowDialog("WISHLIST_EVENT_CHOOSE_CHAR_DIALOG", {copyWishList=doAWishListCopy, dataForChar=addItemForCharData, wlWindow=comingFromWishListWindow, useAnyQuality=useAnyQuality})
end

function WL.ShowClearHistory(comingFromWishListWindow)
    comingFromWishListWindow = comingFromWishListWindow or false
    --WL.createWindow(false)
    --WL.checkCurrentCharData()
    --if not WL.IsEmpty(WL.CurrentCharData) then
        ZO_Dialogs_ShowDialog("WISHLIST_EVENT_CLEAR_HISTORY_DIALOG", { wlWindow=comingFromWishListWindow })
    --end
end

function WL.showChangeQuality(item, changeWholeSet, comingFromWishListWindow)
    changeWholeSet = changeWholeSet or false
    comingFromWishListWindow = comingFromWishListWindow or false
    WL.createWindow(false)
    WL.CurrentItem = item
    WL.checkCurrentCharData()
    ZO_Dialogs_ShowDialog("WISHLIST_EVENT_CHANGE_QUALITY_DIALOG", {itemData=item, wholeSet=changeWholeSet, wlWindow=comingFromWishListWindow})
end

function WL.showQuestionDialog(questionTitle, questionText, callbackYesFnc, callbackNoFnc, data)
    if questionTitle == nil or questionTitle == "" or questionText == nil or questionText == ""
            or callbackYesFnc == nil or type(callbackYesFnc) ~= "function" or callbackNoFnc == nil or type(callbackNoFnc) ~= "function" then
        return
    end
    data = data or {}
    ZO_Dialogs_RegisterCustomDialog("WISHLIST_QUESTION_DIALOG", {
        canQueue = true,
        title = {
            text = questionTitle,
        },
        mainText = {
            text = questionText,
        },
        buttons =  {
            [1] = {
                text = SI_DIALOG_CONFIRM,
                callback = callbackYesFnc,
            },
            [2] = {
                text = SI_DIALOG_CANCEL,
                callback = callbackNoFnc,
            }
        },
        --setup = function(dialog, data) end,
    })
    ZO_Dialogs_ShowDialog("WISHLIST_QUESTION_DIALOG", data)
end

function WL.getAddItemDialogButtonTexture(specialAddType, buttonType)
    if specialAddType == nil or specialAddType == "" then return "" end
    local specialAddTypeToButtontexture = WL.addDialogButtonTextures
    local textureFileName = ""
    if buttonType ~= nil and buttonType ~= "" then
        textureFileName = string.format(specialAddTypeToButtontexture[specialAddType], buttonType) or ""
    else
        textureFileName = specialAddTypeToButtontexture[specialAddType] or ""
    end
    return textureFileName
end

function WL.showAddGearMarkerIcon(data, gearData, assignWholeSet, comingFromWishListWindow, assignType, addToAllWishLists)
    if assignType == nil then assignType = WISHLIST_ASSIGN_GEAR_MARKER_ITEM_TYPE_NORMAL end
    comingFromWishListWindow = comingFromWishListWindow or false
    addToAllWishLists = addToAllWishLists or false
    WL.createWindow(false)
    local clientLang = WL.clientLang or WL.fallbackSetLang
    WL.CurrentItem = data
    WL.currentSetId = data.setId
    WL.currentSetName = (data.names ~= nil and data.names[clientLang]) or data.name
    WL.checkCurrentCharData()
    ZO_Dialogs_ShowDialog("WISHLIST_EVENT_ADD_GEAR_MARKER_DIALOG", {itemData=data, gearData=gearData, wholeSet=assignWholeSet, wlWindow=comingFromWishListWindow, assignType=assignType, addToAllWishLists=addToAllWishLists})
end

function WL.showRemoveGearMarkerIcon(data, gearData, removeWholeSet, comingFromWishListWindow, removeType, removeFromAllWishLists)
    if removeType == nil then removeType = WISHLIST_REMOVE_GEAR_MARKER_ITEM_TYPE_NORMAL end
    removeWholeSet = removeWholeSet or false
    comingFromWishListWindow = comingFromWishListWindow or false
    removeFromAllWishLists = removeFromAllWishLists or false
    WL.createWindow(false)
    WL.CurrentItem = data
    WL.checkCurrentCharData()
    ZO_Dialogs_ShowDialog("WISHLIST_EVENT_REMOVE_GEAR_MARKER_DIALOG", {itemData=data, gearData=gearData, wholeSet=removeWholeSet, wlWindow=comingFromWishListWindow, removeType=removeType, removeFromAllWishLists=removeFromAllWishLists})
end
