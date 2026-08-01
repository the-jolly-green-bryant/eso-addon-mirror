WishList = WishList or {}
local WL = WishList

------------------------------------------------
--- Wishlist - Keybindings
------------------------------------------------
--Add/Remove an item from the wishlist via keybinding, or inventory context menu (bagId and slotIndex are given then)
function WL:AddOrRemoveFromWishList(bagId, slotIndex, alreadyOnWishListCheckData, currentCharOrDialog, useAnyQuality)
    --d("WishList:AddOrRemoveFromWishList()")
    currentCharOrDialog = currentCharOrDialog or false
    useAnyQuality = useAnyQuality or false
    if bagId == nil or slotIndex == nil then
        bagId, slotIndex = WL.GetBagAndSlotFromControlUnderMouse()
    end
    --bag and slot could be retrieved?
    if bagId ~= nil and slotIndex ~= nil then
        --Check if already on Wishlist, or was this done before already?
        local isAlreadyOnWL, setItemId, setId, setName, bonuses, itemType, armorOrWeaponType, equipType, traitType, itemQuality, charData, item
        if alreadyOnWishListCheckData ~= nil then
            isAlreadyOnWL = alreadyOnWishListCheckData.isAlreadyOnWL
            setItemId = alreadyOnWishListCheckData.setItemId
            setId = alreadyOnWishListCheckData.setId
            setName = alreadyOnWishListCheckData.setName
            bonuses = alreadyOnWishListCheckData.bonuses
            itemType = alreadyOnWishListCheckData.itemType
            armorOrWeaponType = alreadyOnWishListCheckData.armorOrWeaponType
            equipType = alreadyOnWishListCheckData.equipType
            traitType = alreadyOnWishListCheckData.traitType
            itemQuality = alreadyOnWishListCheckData.itemQuality
            charData = alreadyOnWishListCheckData.charData
            item = alreadyOnWishListCheckData.item
        else
            isAlreadyOnWL, setItemId, setId, setName, bonuses, itemType, armorOrWeaponType, equipType, traitType, itemQuality, charData, item = WL.checkIfAlreadyOnWishList(bagId, slotIndex, nil, nil)
        end
        --If not: add the item
        if setItemId == nil then
            --d("<< ABORTED!")
            return
        end
        if not isAlreadyOnWL == true then
            local qualityWL = itemQuality + WL.ESOquality2WLqualityAdd
            setName = zo_strformat("<<C:1>>", setName)

            local items = {}
            local data = {}
            data.setId      = setId
            data.setName    = setName
            data.bonuses    = bonuses
            data.id         = setItemId
            data.itemType   = itemType
            data.armorOrWeaponType = armorOrWeaponType
            data.slot       = equipType
            data.trait      = traitType
            data.quality    = qualityWL
            table.insert(items, data)

            --Add for current char?
            if currentCharOrDialog == true then
                --WishList:AddItem(items, charData, alreadyOnWishlistCheckDone, noAddedChatOutput)
                WishList:AddItem(items, charData, true)
            else
                --Show add dialog
                --WL.ShowChooseChar(doAWishListCopy, addItemForCharData, comingFromWishListWindow)
                WL.ShowChooseChar(false, items, false, useAnyQuality)
            end
        else
            --Already on WishList, so ask to remove it
            --local item = {}
            item.id = setItemId
            item.itemLink = GetItemLink(bagId, slotIndex)
            WL.showRemoveItem(item)
        end
    end
end
