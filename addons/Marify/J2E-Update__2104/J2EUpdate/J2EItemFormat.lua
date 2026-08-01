
J2EUpdate.lastItemTraitType     = nil

J2EUpdate.SI_TOOLTIP_ITEM_NAME                     = GetString(SI_TOOLTIP_ITEM_NAME)
J2EUpdate.SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED  = GetString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED)
J2EUpdate.SI_ITEM_FORMAT_STR_SET_NAME              = GetString(SI_ITEM_FORMAT_STR_SET_NAME)




function J2EUpdate:AddItemName(tooltip, itemLink)

    if tooltip == nil then
        return
    end
    if itemLink == nil or itemLink == "" then
        return
    end

    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    if (not self.savedVariables.displayTypes[itemType]) then
        return
    end
    if self.savedVariables.showItemNameBottom or self.savedVariables.showSetNameBottom then
        self:Debug("　　[AddItemName] " .. itemLink)
    end


    local itemName = self:GetItemName(itemLink)
    if self.savedVariables.showItemNameBottom and tooltip["AddLine"] then
        if itemName then
            local txt = zo_strformat("|c<<1>><<2>>|r", self.txtColor,
                                                       zo_strformat(GetString(J2E_FORMAT_NAME), itemName))
            tooltip:AddLine(txt, "", 0.8, 0.8, 0.8, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
            self:Debug("　　itemName=" .. txt)
        end
    end


    local hasSet, setName = self:GetItemSetName(itemLink)
    if self.savedVariables.showSetNameBottom and tooltip["AddLine"] then
        if setName then
            local txt = zo_strformat("|c<<1>><<2>>|r", self.txtColor,
                                                       zo_strformat(GetString(J2E_FORMAT_SET_NAME), setName))
            tooltip:AddLine(txt, "", 0.8, 0.8, 0.8, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
            self:Debug("　　setName=" .. txt)
        end
    end

    self:ResetCachedItemFormat()
    self:CheckItem(itemName, hasSet, setName, itemLink)
end




function J2EUpdate:AddItemNameGamePad(tooltip, ...)

    if tooltip == nil then
        return
    end
    local itemLink = ({...})[1]
    if itemLink == nil or itemLink == "" then
        return
    end


    if self.savedVariables.showItemNameBottom or self.savedVariables.showSetNameBottom then
        local itemType, specializedItemType = GetItemLinkItemType(itemLink)
        if (not self.savedVariables.displayTypes[itemType]) then
            return
        end
    end
    self:Debug("　　[AddItemNameGamePad]")


    local itemName = self:GetItemName(itemLink)
    if self.savedVariables.showItemNameBottom then
        local mystyle = {
            fontSize = 24,
            fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1,
            }
        if itemName then
            local txt = zo_strformat(GetString(J2E_FORMAT_NAME), itemName)
            tooltip:AddLine(txt, mystyle, tooltip:GetStyle("bodySection"))
        end
    end


    local hasSet, setName = self:GetItemSetName(itemLink)
    if self.savedVariables.showSetNameBottom then
        if setName then
            local txt = zo_strformat(GetString(J2E_FORMAT_SET_NAME), setName)
            tooltip:AddLine(txt, mystyle, tooltip:GetStyle("bodySection"))
        end
    end

    self:ResetCachedItemFormat()
    self:CheckItem(itemName, hasSet, setName, itemLink)
end




function J2EUpdate:CheckItem(itemName, hasSet, setName, itemLink)

    if (not itemLink) then
        return
    end

    if itemName and (not hasSet) then
        return
    end
    if itemName and hasSet and setName then
        return
    end

    self:Debug("　　[CheckItem(" .. tostring(itemName) .. ", "
                                 .. tostring(hasSet) .. ", "
                                 .. tostring(setName) .. ", "
                                 .. tostring(itemLink) .. "]")


    if self.savedVariables.newItemTable[itemLink] or self.savedVariables.newItemLinkTable[itemLink] then
        self:Debug("　　　　>Already added.")
        return
    end

    if hasSet and (setName == nil) and self.savedVariables.isNotification then
        hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
        local txt = zo_strformat(GetString(J2E_NEW_SET), setName, itemLink)
        self:Message(txt)
    end


    local itemType = GetItemLinkItemType(itemLink)
    if itemName == nil and self.savedVariables.isNotification then
        self:Debug("　　　　not IsItemLinkBound=" .. tostring(not IsItemLinkBound(itemLink)))
        self:Debug("　　　　ContainsNumber=" .. tostring(self:ContainsNumber(itemType, ITEMTYPE_ARMOR, ITEMTYPE_WEAPON)))
        local txt = zo_strformat(GetString(J2E_NEW_ITEM), itemLink)
        self:Message(txt)
    end

    if self:ContainsNumber(itemType, ITEMTYPE_POISON,
                                     ITEMTYPE_POTION,
                                     ITEMTYPE_GLYPH_WEAPON,
                                     ITEMTYPE_GLYPH_ARMOR,
                                     ITEMTYPE_GLYPH_JEWELRY) then
        self:Debug("　　　　CASE 1")
        self.savedVariables.newItemLinkTable[itemLink] = true
    else
        self:Debug("　　　　CASE 2")
        self.savedVariables.newItemTable[itemLink] = true
    end
end




function J2EUpdate:CheckItems()

    local itemLink
    local itemName
    local hasSet, setName
    local slotIndex = ZO_GetNextBagSlotIndex(BAG_GUILDBANK, nil)
    while slotIndex do
        itemLink = GetItemLink(BAG_GUILDBANK, slotIndex)
        if itemLink and itemLink ~= "" then
            itemName = self:GetItemName(itemLink)
            hasSet, setName = self:GetItemSetName(itemLink)
            if self.savedVariables.displayTypes[GetItemLinkItemType(itemLink)] then
                self:CheckItem(itemName, hasSet, setName, itemLink)
            end
        end
        slotIndex = ZO_GetNextBagSlotIndex(BAG_GUILDBANK, slotIndex)
    end
end




function J2EUpdate:Compress(itemName, setId, itemType, itemLink)

    self:Debug("[Compress] \"<<1>>\"", itemName)
    if string.match(itemName, "%^[n|p]") then
        if itemName == "robe^n" then
            itemName = "nR"
        elseif itemName == "jerkin^n" then
            itemName = "nJ"
        else
            itemName = "n"
        end
        self:Debug("　　>\"<<1>>\"", tostring(itemName), self.checkColor)
        itemName = "[" .. itemName --.. "]"
        return itemName
    end


    local armorOrWeaponName
    if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
        if itemType == ITEMTYPE_ARMOR then
            local armorType = GetItemLinkArmorType(itemLink)
            local equipType = GetItemLinkEquipType(itemLink) 
            --self:Debug("　　armorType=\"<<1>>\"", tostring(armorType))
            --self:Debug("　　equipType=\"<<1>>\"", tostring(equipType))
            armorOrWeaponName = self.armorNameTable[armorType][equipType]
            self:Debug("　　armorName=\"<<1>>\"", tostring(armorOrWeaponName))
        elseif itemType == ITEMTYPE_WEAPON then
            local weaponType = GetItemLinkWeaponType(itemLink)
            --self:Debug("　　weaponType=\"<<1>>\"", tostring(weaponType))
            armorOrWeaponName = self.weaponNameTable[weaponType]
            self:Debug("　　weaponName=\"<<1>>\"", tostring(armorOrWeaponName))
        --else
        --    return itemName
        end


        local defaultItem
        if setId and setId ~= 0 then

            local setName = self.defaultOfNameTable[setId]
                        or self.defaultItemSetTable[setId]
                        or self.savedVariables.itemSetTable[setId]
            if setName then
                self:Debug("　　setName=\"<<1>>\" ---", tostring(setName))
                for shortName, format in pairs(self.nameFormatTable) do
                    defaultItem = zo_strformat(format, armorOrWeaponName, setName)
                    if string.lower(defaultItem) == string.lower(itemName) then
                        self:Debug("　　　　\"<<1>>\"", tostring(defaultItem), self.checkColor)
                        self:Debug("　　　　>\"<<1>>\"", tostring(shortName), self.checkColor)
                        itemName = "[" .. shortName --.. "]"
                        --return itemName
                        break
                    --else
                        --self:Debug("　　　　\"<<1>>\"", tostring(defaultItem))
                    end
                end
            end
        else
            for shortName, format in pairs(self.nameFormatTable) do
                defaultItem = zo_strformat(format, armorOrWeaponName)
                if string.lower(defaultItem) == string.lower(itemName) then
                    self:Debug("　　　　\"<<1>>\"", tostring(defaultItem), self.checkColor)
                    self:Debug("　　　　>\"<<1>>\"", tostring(shortName), self.checkColor)
                    itemName = "[" .. shortName --.. "]"
                    --return itemName
                    break
                end
            end
        end
        return itemName
    end


    for id, word in ipairs(self.wordTable) do
        itemName = string.gsub(itemName, word, "<" .. id)
        self:Debug("\"<<1>>\"", tostring(itemName))
    end


    return itemName
end



function J2EUpdate:CreateFullName(name, itemId, itemType, itemLink)

    if name == nil then
        return nil, false -- itemName, isNormal
    end


    local isCreate = false
    local shortName, equipType = string.match(name, "^%[(%d+)([-'%s%u%l]+)$")
    local prefix, shortName2 = string.match(name, "^(%[)([-'%d%s%u%l]*)$")
    if shortName and equipType then
        isCreate = true
        local nameFormat = self.nameFormatTable[shortName]
        if nameFormat == nil or nameFormat == "" then
            self:DebugIfMarify("nameFormat is Not Found. shortName=<<1>>", tostring(shortName),
                                                                           self.failedColor)
            return nil, false  -- itemName, isNormal
        end
        self:Debug("　　　　　　　　nameFormat=" .. tostring(nameFormat))

        local armorOrWeaponName = self.nameFormatTable[equipType]
        if armorOrWeaponName == nil or armorOrWeaponName == "" then
            armorOrWeaponName = equipType
        end
        armorOrWeaponName = armorOrWeaponName:gsub("<<2>> ", "")
        self:Debug("　　　　　　　　armorOrWeaponName=<<1>>", armorOrWeaponName)

        name = zo_strformat(nameFormat, armorOrWeaponName)


    elseif (prefix and shortName2) or (prefix and shortName2 == "") then
        isCreate = true
        --if shortName2 == "" then
        --    shortName2 = "s"
        --end
        if itemLink == nil then
            self:Debug("　　　　　　[CreateFullName(<<1>>, <<2>>, <<3>>)]", name, itemId, itemType)
            itemLink = zo_strformat("|H0:item:<<1>>:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
        else
            self:Debug("　　　　　　[CreateFullName(<<1>>, <<2>>, <<3>>)]", name, itemLink, itemType)
        end

        local nameFormat = self.nameFormatTable[shortName2]
        if nameFormat == nil or nameFormat == "" then
            self:DebugIfMarify("nameFormat is Not Found. shortName=<<1>>", tostring(shortName2),
                                                                           self.failedColor)
            return nil, false  -- itemName, isNormal
        end
        self:Debug("　　　　　　　　nameFormat=" .. tostring(nameFormat))


        -- <<1>> armorOrWeaponName
        local armorOrWeaponName = ""
        if string.match(nameFormat, "<<1>>") then
            if itemType == ITEMTYPE_WEAPON then
                local weaponType = GetItemLinkWeaponType(itemLink)
                armorOrWeaponName = self.weaponNameTable[weaponType]
                self:Debug("　　　　　　　　weaponName=<<1>>", armorOrWeaponName)

            elseif itemType == ITEMTYPE_ARMOR then
                local armorType = GetItemLinkArmorType(itemLink)
                local equipType = GetItemLinkEquipType(itemLink)
                armorOrWeaponName = self.armorNameTable[armorType][equipType]
                self:Debug("　　　　　　　　armorName=<<1>>", armorOrWeaponName)
            end
        end

        -- <<2>> setName
        local setName = ""
        if string.match(nameFormat, "<<2>>") then
            local _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
            setName = self.defaultOfNameTable[setId]
                         or self.defaultItemSetTable[setId]
                         or self.savedVariables.itemSetTable[setId]
            self:Debug("　　　　　　　　setName=<<1>>", setName)
        end

        name = zo_strformat(nameFormat, armorOrWeaponName, setName)


    elseif string.match(name, "[<%[%{](%d+)") then
        isCreate = true
        self:Debug("　　　　　　[CreateFullName(<<1>>)]", name)
        name = self:CreateWordName(name)
    end


    if string.match(name, "%^[n|p]") then
        if not isCreate then
            self:Debug("　　　　　　[CreateFullName(<<1>>)]", name)
        end

        isCreate = true
        name = self:CreateNormalName(name, itemType, itemLink)
        self:Debug("　　　　　　　　>" .. tostring(name))
        return name, true -- itemName, isNormal
    end


    name = name:gsub("%^%a*", "")
    if isCreate then
        self:Debug("　　　　　　　　>" .. tostring(name))
    end
    return name, false  -- itemName, isNormal
end




function J2EUpdate:CreateItemLinkKey(itemLink)

    local key = string.match(itemLink, "|H%d:item:(%d+:%d+:%d+):.*")
    return key
end




function J2EUpdate:CreateNormalName(name, itemType, itemLink)

    self:Debug("　　　　　　　　[CreateNormalName] (<<1>>, <<2>>)", tostring(name),
                                                                tostring(itemType))
    local craftingType, armorType = self:GetCraftingType(itemType, itemLink)
    if craftingType == nil then
        self:DebugIfMarify("craftingType is nil..." .. itemLink, self.failedColor)
        return nil
    end

    local prefixKey, lv, suffixKey = string.match(itemLink, "|H%d:item:%d+:(%d+):(%d+):(%d+):.*")
    if lv == "50" then
        prefixKey = prefixKey .. ":" .. lv
    else
        prefixKey = ":" .. lv
    end
    if craftingType == CRAFTING_TYPE_CLOTHIER then
        prefixKey = armorType .. ":" .. prefixKey
    end
    if self:Equal(prefixKey, ":0", "1::0", "2::0") then
        if name ~= nil then
            return name:gsub("%^%a*", "")
        end
        return name
    end


    local prefix = self.savedVariables.itemPrefixTable[craftingType][prefixKey]
                    or self.defaultNormalItemPrefixTable[craftingType][prefixKey]
    if prefix == nil then
        self:DebugIfMarify("prefixKey NotFound. \"<<1>>\"...<<2>>", tostring(prefixKey),
                                                                    tostring(itemLink),
                                                                    self.failedColor)
        self:DebugIfMarify("　@see [J2EItemNormalData.lua] defaultNormalItemPrefixTable", self.failedColor)
        return nil
    end


    local suffix = self.savedVariables.normalItemSuffixTable[tonumber(suffixKey)]
                    or self.defaultNormalItemSuffixTable[tonumber(suffixKey)]
    if suffix == nil then
        self:DebugIfMarify("suffix is nil..." .. itemLink, self.failedColor)
        return nil
    end

    name = string.gsub(name, "%^.*", "")
    name = string.lower(name)
    if prefix ~= "" then
        name = prefix .. " " .. name
    end
    if suffix ~= "" then
        name = name ..  " " .. suffix
    end
    self:Debug("　　　　　　　　　　>\"<<1>>\"", tostring(name))

    if name ~= nil then
        return name:gsub("%^%a*", "")
    end
    return name
end




function J2EUpdate:CreateWordName(name)

    if name == nil then
        return nil
    end


    self:Debug("　　　　　　　　[CreateWordName(<<1>>]", name)
    local placeTable = {
      {"[<%[%{]",  "%d%d%d", "[>%]%}]?"},
      {"[<%[%{]",  "%d%d",   "[>%]%}]?"},
      {"[<%[%{]",  "%d",     "[>%]%}]?"},
    }
    local pattern
    local prefix, place, suffix
    local word
    local result = name
    for i, values in ipairs(placeTable) do
        pattern = zo_strformat("(<<1>>)(<<2>>)(<<3>>)", values[1], values[2], values[3])
        --d("　　values[1]=" .. tostring(values[1]))
        --d("　　values[2]=" .. tostring(values[2]))
        --d("　　values[3]=" .. tostring(values[3]))
        --d("pattern=" .. tostring(pattern))
        prefix, place, suffix = string.match(result, pattern)
        while place do
            --self:Debug("　　　　　　　　　　prefix=" .. tostring(prefix))
            --self:Debug("　　　　　　　　　　place=" .. tostring(place))
            --self:Debug("　　　　　　　　　　suffix=" .. tostring(suffix))
            --d(tostring(result))
            if prefix == "<" then
                word = self.wordTable[tonumber(place)]

            elseif prefix == "{" then
                prefix = "%" .. prefix
                word = self.defaultOfNameTable[tonumber(place)]
                        or self.defaultItemSetTable[tonumber(place)]
            else
                prefix = "%" .. prefix
                if suffix and suffix ~= "" then
                    suffix = "%" .. suffix
                end
                word = self.defaultItemSetTable[tonumber(place)]
            end

            place = zo_strformat("<<1>><<2>><<3>>", prefix, place, suffix)
            if word == nil or word == "" then
                self:Debug("　　　　　　　　　　word NotFound. <<1>>", tostring(place),
                                                                       self.failedColor)
                return result
            end
            --self:Debug("　　　　　　　　　　prefix=" .. tostring(prefix))
            result = string.gsub(result, place, word)
            self:Debug("　　　　　　　　　　gsub(\"" .. tostring(place) .. "\","
                                             .. "\"" .. tostring(word) .. "\")"
                                             .. "　>" .. tostring(result) .. "")
            prefix, place, suffix = string.match(result, pattern)
        end
    end
    return result
end




function J2EUpdate:GetItemName(itemLink)

    if itemLink == nil then
        return nil
    end
    if self.savedVariables == nil then
        return nil
    end

    -- itemIdに複数のアイテムが紐づくケースがある、、、
    local itemType = GetItemLinkItemType(itemLink)
    if itemType == nil then
        return nil
    end


    self:Debug("　　　　[GetItemName] <<1>> ... <<2>>:<<3>> ", itemLink,
                                                               itemType,
                                                               GetString("SI_ITEMTYPE", itemType))
    local name
    local defName
    local itemSubTable
    if self:ContainsNumber(itemType, ITEMTYPE_POISON,
                                     ITEMTYPE_POTION) then
        local itemLinkKey = self:CreateItemLinkKey(itemLink)
        name = self:GetSubTable(self.savedVariables.itemLinkTable, itemType)[itemLinkKey]
        if name then
            return name, true, false -- itemName, isLinkItem, isNormal
        end

        defName = self.defaultItemLinkTable[itemType][itemLinkKey]
        if defName then
            return defName, true, false -- itemName, isLinkItem, isNormal
        end
    end


    if self:ContainsNumber(itemType, ITEMTYPE_GLYPH_WEAPON,
                                     ITEMTYPE_GLYPH_ARMOR,
                                     ITEMTYPE_GLYPH_JEWELRY) then
        local itemLinkKey = self:CreateItemLinkKey(itemLink)
        name = self:GetSubTable(self.savedVariables.itemLinkTable, itemType)[itemLinkKey]
        if name then
            --self:Debug("　　　　　　><<1>>", name)
            return name, true, false -- itemName, isLinkItem, isNormal
        end


        local itemId, key1, key2 = string.match(itemLink, "|H%d:item:(%d+):(%d+):(%d+):.*")
        local prefixKey = (key2 == "50" and key1 .. ":") or ":" .. key2
        local prefix = self.defaultGlyphPrefixTable[prefixKey]
        if prefix == nil or prefix == "" then
            self:DebugIfMarify("prefixKey \"<<1>>\" is Not Found. <<2>>", tostring(prefixKey),
                                                                          itemLink,
                                                                          self.failedColor)
            self:DebugIfMarify("　@see [J2EItemLinkData.lua] defaultGlyphPrefixTable", self.failedColor)
            return nil, true, false -- itemName, isLinkItem, isNormal
        end
        defName = self.defaultItemLinkTable[itemType][itemId]
        if defName then
            --self:Debug("　　　　　　prefixKey=<<1>>", prefixKey)
            --self:Debug("　　　　　　prefix=<<1>>", prefix)
            --self:Debug("　　　　　　defName=<<1>>", defName)
            defName = zo_strformat("<<1>> <<2>>",prefix ,defName)
            --self:Debug("　　　　　　><<1>>", defName)
            return defName, true, false -- itemName, isLinkItem, isNormal
        end
    end


    local itemId = GetItemLinkItemId(itemLink)
    --self:Debug("　　　　　　itemId=<<1>>", itemId)
    local itemSubTable = self:GetSubTable(self.savedVariables.itemTable, itemType)
    name = itemSubTable[itemId]
    if name then
        self:Debug("　　　　　　name=<<1>>", tostring(name))
        local itemName, isNormal = self:CreateFullName(name, itemId, itemType, itemLink)
        return itemName, false, isNormal -- itemName, isLinkItem, isNormal
    end


    defName = self:GetItemNameDefault(itemId, itemType)
    if defName then
        self:Debug("　　　　　　defName=<<1>>", tostring(defName))
        local itemName, isNormal = self:CreateFullName(defName, itemId, itemType, itemLink)
        return itemName, false, isNormal -- itemName, isLinkItem, isNormal
    end
    return nil, false, false -- itemName, isLinkItem, isNormal
end




function J2EUpdate:GetItemNameDefault(itemId, itemType)

    self:Debug("　　　　　　[GetItemNameDefault] (<<1>>, <<2>>)", itemId, itemType)
    local itemSubTable
    local result
    if itemType then
        if itemType == ITEMTYPE_ARMOR then
            itemSubTable = self.defaultArmorTable[itemType]
            result = itemSubTable[itemId]

        elseif itemType == ITEMTYPE_WEAPON then
            itemSubTable = self.defaultWeaponTable[itemType]
            result = itemSubTable[itemId]

        elseif itemType == ITEMTYPE_FURNISHING then
            itemSubTable = self.defaultFurnishingTable[itemType]
            result = itemSubTable[itemId]

        elseif itemType == ITEMTYPE_RECIPE then
            itemSubTable = self.defaultRecipeTable[itemType]
            result = itemSubTable[itemId]

        elseif self.defaultItemTable[itemType] then
            itemSubTable = self.defaultItemTable[itemType]
            result = itemSubTable[itemId]
        end
        if not itemSubTable then
            return nil
        end
        --self:Debug("　　　　　　　　>result=" .. tostring(result))
        return result

    else
        for key, itemTable in pairs(self.defaultItemTable) do
            result = itemTable[itemId]
            if result then
                return result
            end
        end
    end
    return nil
end




function J2EUpdate:GetItemSetName(itemLink)

    self:Debug("　　　　[GetItemSetName]")
    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
    if (not hasSet) then
        return hasSet, nil
    end

    local name = self.savedVariables.itemSetTable[setId]
    local defName = self.defaultItemSetTable[setId]
    if name and defName then
        if defName ~= name then
            self:DebugIfMarify("Diff SetName. setId=<<1>>", setId, self.failedColor)
            self:DebugIfMarify("　　　　　　<<1>>(savedVariables)", name, self.failedColor)
            self:DebugIfMarify("　　　　　　<<1>>(defaultData)", defName, self.failedColor)
        else
            self.savedVariables.itemSetTable[setId] = nil
        end
    end
    self:Debug("　　　　　　><<1>>:<<2>>", setId, name or defName or "nil(Not Found)")
    return hasSet, name or defName
end




function J2EUpdate:GetSubTable(table, itemType)

    local subTable = table[itemType]
    if subTable == nil then
        subTable = {}
        table[itemType] = subTable
    end
    return subTable
end




function J2EUpdate:ResetCachedItemFormat(isAll)
    self:Debug("　　[ResetCachedItemFormat(<<1>>)]", tostring(isAll), self.disabledColor)

    if isAll or self.savedVariables.showItemName then
        self:ResetString(SI_TOOLTIP_ITEM_NAME)
    end


    if isAll or self.savedVariables.showEnchant then
        self:ResetString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED)

        if self.savedVariables.showEnchant then
            self:UpdateString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_MULTI_EFFECT, "複数効果の付呪 |cc5c29e(Multi-Effect)|r")
        else
            self:ResetString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_MULTI_EFFECT)
        end
    end


    if isAll or self.savedVariables.showSetName then
        self:ResetString(SI_ITEM_FORMAT_STR_SET_NAME)
    end


    if isAll or self.savedVariables.showTrait then

        if self.savedVariables.showTrait and self.lastItemTraitType then
            --self:UpdateString(SI_SMITHING_TRAIT_DESCRIPTION,    "|cffffff<<2>>|r - <<1>>")
            --self:Debug("　　self.lastItemTraitType=<<1>>", tostring(self.lastItemTraitType))
            self:ResetString(self.lastItemTraitType)
            --self:Debug("　　><<1>>", tostring(GetString(self.lastItemTraitType)))
            self.lastItemTraitType = nil
        end
        if isAll then
            --self:ResetString(SI_SMITHING_TRAIT_DESCRIPTION)
            self:ResetString(SI_ITEMTRAITTYPE1)
            self:ResetString(SI_ITEMTRAITTYPE2)
            self:ResetString(SI_ITEMTRAITTYPE3)
            self:ResetString(SI_ITEMTRAITTYPE4)
            self:ResetString(SI_ITEMTRAITTYPE5)
            self:ResetString(SI_ITEMTRAITTYPE6)
            self:ResetString(SI_ITEMTRAITTYPE7)
            self:ResetString(SI_ITEMTRAITTYPE8)
            self:ResetString(SI_ITEMTRAITTYPE9)
            self:ResetString(SI_ITEMTRAITTYPE10)
            self:ResetString(SI_ITEMTRAITTYPE11)
            self:ResetString(SI_ITEMTRAITTYPE12)
            self:ResetString(SI_ITEMTRAITTYPE13)
            self:ResetString(SI_ITEMTRAITTYPE14)
            self:ResetString(SI_ITEMTRAITTYPE15)
            self:ResetString(SI_ITEMTRAITTYPE16)
            self:ResetString(SI_ITEMTRAITTYPE17)
            self:ResetString(SI_ITEMTRAITTYPE18)
            self:ResetString(SI_ITEMTRAITTYPE19)
            self:ResetString(SI_ITEMTRAITTYPE20)
            self:ResetString(SI_ITEMTRAITTYPE21)
            self:ResetString(SI_ITEMTRAITTYPE22)
            self:ResetString(SI_ITEMTRAITTYPE23)
            self:ResetString(SI_ITEMTRAITTYPE24)
            self:ResetString(SI_ITEMTRAITTYPE25)
            self:ResetString(SI_ITEMTRAITTYPE26)
            self:ResetString(SI_ITEMTRAITTYPE27)
            self:ResetString(SI_ITEMTRAITTYPE28)
            self:ResetString(SI_ITEMTRAITTYPE29)
            self:ResetString(SI_ITEMTRAITTYPE30)
            self:ResetString(SI_ITEMTRAITTYPE31)
            self:ResetString(SI_ITEMTRAITTYPE32)
            self:ResetString(SI_ITEMTRAITTYPE33)

            self:ResetString(SI_ITEMTRAITTYPE34)
            self:ResetString(SI_ITEMTRAITTYPE35)
            self:ResetString(SI_ITEMTRAITTYPE36)
            self:ResetString(SI_ITEMTRAITTYPE37)
            self:ResetString(SI_ITEMTRAITTYPE38)
            self:ResetString(SI_ITEMTRAITTYPE39)
            self:ResetString(SI_ITEMTRAITTYPE40)
            self:ResetString(SI_ITEMTRAITTYPE41)
            self:ResetString(SI_ITEMTRAITTYPE42)
            self:ResetString(SI_ITEMTRAITTYPE43)
            self:ResetString(SI_ITEMTRAITTYPE44)
            self:ResetString(SI_ITEMTRAITTYPE45)
            self:ResetString(SI_ITEMTRAITTYPE46)
            self:ResetString(SI_ITEMTRAITTYPE47)
            self:ResetString(SI_ITEMTRAITTYPE48)
            self:ResetString(SI_ITEMTRAITTYPE49)
            self:ResetString(SI_ITEMTRAITTYPE50)
            self:ResetString(SI_ITEMTRAITTYPE51)
            self:ResetString(SI_ITEMTRAITTYPE52)
            self:ResetString(SI_ITEMTRAITTYPE53)
            self:ResetString(SI_ITEMTRAITTYPE54)
            self:ResetString(SI_ITEMTRAITTYPE55)
            self:ResetString(SI_ITEMTRAITTYPE56)
            self:ResetString(SI_ITEMTRAITTYPE57)
            self:ResetString(SI_ITEMTRAITTYPE58)
            self:ResetString(SI_ITEMTRAITTYPE59)
            self:ResetString(SI_ITEMTRAITTYPE60)
        end
    end
end




function J2EUpdate:SetItemFormat(itemLink)

    if itemLink == nil or itemLink == "" then
        return
    end
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    if (not self.savedVariables.displayTypes[itemType]) then
        return
    end

    if not self.savedVariables.showEnchant
        and not self.savedVariables.showTrait
        and not self.savedVariables.showItemName
        and not self.savedVariables.showSetName then
        return
    end
    self:Debug("　　[SetItemFormat] " .. itemLink)


    if self.savedVariables.showItemName then
        local itemName, isLinkItem, isNormal = self:GetItemName(itemLink)
        if itemName then
            local txt = zo_strformat("\n|c<<1>>(<<2>>)|r", self.txtColor, itemName)
            if GetDisplayName() == "@Marify" then
                if isLinkItem then
                    txt = zo_strformat("\n|c5D9999(<<1>>)|r", itemName)
                elseif isNormal then
                    txt = zo_strformat("\n|c666666(<<1>>)|r", itemName)
                end
            end
            --local orgText = GetString(SI_TOOLTIP_ITEM_NAME)
            self:UpdateString(SI_TOOLTIP_ITEM_NAME, "<<1>>" .. txt)
        end
    end


    if not self:ContainsNumber(itemType, ITEMTYPE_ARMOR, ITEMTYPE_WEAPON) then
        return
    end


    if self.savedVariables.showEnchant then
        local hasCharges, enchantHeader = GetItemLinkEnchantInfo(itemLink)
        if hasCharges then
            local enchantName = self.enchantDataTable[enchantHeader]
            if enchantName then
                local txt = zo_strformat("|c<<1>>(<<2>>)|r", self.txtColor, enchantName)
                self:UpdateString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, "<<1>>付呪 " .. txt)

            elseif enchantHeader == GetString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_MULTI_EFFECT) then
                -- Pass

            else
                self:DebugIfMarify("|cff1493 enchantHeader=" .. tostring(enchantHeader) .. "|r" .. itemLink)
            end
        end
    end


    if self.savedVariables.showTrait then
        local itemTraitType = GetItemLinkTraitType(itemLink)
        if itemTraitType and itemTraitType ~= ITEM_TRAIT_TYPE_NONE then
            self.lastItemTraitType = SI_ITEMTRAITTYPE0 + itemTraitType
            --self:Debug("　　lastItemTraitType=<<1>>", tostring(self.lastItemTraitType))
            local traitName = self.traitDataTable[self.lastItemTraitType]
            --self:Debug("　　traitName=<<1>>", tostring(traitName))
            if traitName then
                local originFormats = GetString(self.lastItemTraitType)
                --self:Debug("　　originFormats=<<1>>", tostring(originFormats))
                local txt = zo_strformat("<<1>>|c<<2>>(<<3>>)|r", originFormats, self.txtColor, traitName)
                self:UpdateString(self.lastItemTraitType, txt)

            else
                self:DebugIfMarify("|cFF1493 itemTraitType=" .. tostring(itemTraitType) .. "|r")
            end
        end
    end


    if self.savedVariables.showSetName then
        local hasSet, setName = self:GetItemSetName(itemLink)
        if setName then
            local txt = zo_strformat("\n|c<<1>>(<<2>> SET)|r", self.txtColor, setName)
            self:UpdateString(SI_ITEM_FORMAT_STR_SET_NAME, "<<1>>セットの一部(<<2>>/<<3>>アイテム)" .. txt)
        end
    end

end




function J2EUpdate:UpdateCompare(task)
    self:DebugIfMarify("UpdateCompare()", self.checkColor)

    local toHide = self:IsDebug()
    if toHide then
        self.savedVariables.isDebug = false
    end

    self:DebugIfMarify("　　Check Start.", self.checkColor)
    local list
    local itemLink
    local itemName
    local itemTypeTest
    local errorCount = 0
    task:For(ITEMTYPE_ITERATION_BEGIN + 1, ITEMTYPE_MAX_VALUE, 1):Do(function(itemType)
        list = {}

        if itemType == ITEMTYPE_ARMOR then
            table.insert(list, self.defaultArmorTable[itemType])
        elseif itemType == ITEMTYPE_WEAPON then
            table.insert(list, self.defaultWeaponTable[itemType])
        elseif itemType == ITEMTYPE_FURNISHING then
            table.insert(list, self.defaultFurnishingTable[itemType])
        elseif itemType == ITEMTYPE_RECIPE then
            table.insert(list, self.defaultRecipeTable[itemType])
        elseif self:ContainsNumber(itemType, ITEMTYPE_POISON, ITEMTYPE_POTION) then
            table.insert(list, self.defaultItemLinkTable[itemType])
        else
            table.insert(list, self.defaultItemTable[itemType])
        end
        table.insert(list, self.savedVariables.itemTable[itemType])

        for i, itemSubTable in pairs(list) do
            task:For(pairs(itemSubTable)):Do(function(itemId, defName)
                if self:ContainsNumber(itemType, ITEMTYPE_POISON, ITEMTYPE_POTION) then
                    itemLink = zo_strformat("|H0:item:<<1>>:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
                else
                    itemLink = zo_strformat("|H0:item:<<1>>:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
                end
                itemName = GetItemLinkName(itemLink):gsub("%^%a*", "")
                itemTypeTest = GetItemLinkItemType(itemLink)
                if itemTypeTest ~= itemType then
                    self:DebugIfMarify("Diff ItemType [<<1>>]", itemId, self.failedColor)
                    d("　　O:" .. itemTypeTest .. ":" .. GetString("SI_ITEMTYPE", itemTypeTest))
                    d("　　X:" .. itemType .. ":" .. GetString("SI_ITEMTYPE", itemType))
                    errorCount = errorCount + 1
                end

                local defNameOrigin = defName
                defName = self:CreateFullName(defName, itemId, itemType, itemLink)
                if string.lower(itemName) ~= string.lower(defName) then
                    self:DebugIfMarify("Diff Name [<<1>>]", itemId, self.failedColor)
                    d("　　O:" .. tostring(itemName))
                    d("　　X:" .. tostring(defName))
                    d("　　\"" .. tostring(defNameOrigin) .. "\"")
                    self.savedVariables.itemTable[itemType][itemId] = tostring(itemName)
                    d("　　　　>" .. tostring(self.savedVariables.itemTable[itemType][itemId]))

                    -- Retry
                    --self:DebugIfMarify("　　　　Retry↓", self.failedColor)
                    --self.savedVariables.isDebug = true
                    --defName = self:CreateFullName(defNameOrigin, itemId, itemType, itemLink)
                    --self.savedVariables.isDebug = false

                    errorCount = errorCount + 1
                --else
                --    d("　　" .. tostring(itemName))
                end
                if errorCount > 10 then
                    self:DebugIfMarify("　　All Checked.", self.checkColor)
                    task:Cancel()
                end
            end):Then(function()
                if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
                    self:DebugIfMarify("　　[<<1>>]<<2[/def/save]>> checked. <<3>>", itemType,
                                                                                     i,
                                                                                     GetString("SI_ITEMTYPE", itemType),
                                                                                     self.checkColor)
                end
            end)
        end
    end):Then(function()
        self:DebugIfMarify("　　All Checked.", self.checkColor)
        if toHide then
            self.savedVariables.isDebug = true
        end
    end)

end




function J2EUpdate:UpdateItemLinkTable()
    self:DebugIfMarify("UpdateItemLinkTable()", self.checkColor)
    local itemLinkTable = self.savedVariables.itemLinkTable
    local itemSubTable
    local itemType
    local itemLinkKey
    local itemName
    local size = 0
    for itemLink, _ in pairs(self.savedVariables.newItemLinkTable) do
        itemType = GetItemLinkItemType(itemLink)
        itemSubTable = self:GetSubTable(itemLinkTable, itemType)

        itemLinkKey = self:CreateItemLinkKey(itemLink)
        itemName = GetItemLinkName(itemLink):gsub("(\^)%a*", "")
        itemSubTable[itemLinkKey] = itemName
        size = size + 1
        if GetDisplayName() == "@Marify" then
            local txt = "Add itemLink " .. itemLink
            self:Message(txt)
        end
    end
    self.savedVariables.newItemLinkTable = {}

    local itemId, key1, key2
    local prefixKey
    local prefix
    local maskedItemLink
    local defName
    for itemType, itemSubTable in pairs(itemLinkTable) do
        for itemLinkKey, itemName in pairs(itemSubTable) do

            if self:ContainsNumber(itemType, ITEMTYPE_GLYPH_WEAPON,
                                             ITEMTYPE_GLYPH_ARMOR,
                                             ITEMTYPE_GLYPH_JEWELRY) then
                itemId, key1, key2 = string.match(itemLinkKey, "(%d+):(%d+):(%d+)")
                prefixKey = (key2 == "50" and key1 .. ":") or ":" .. key2
                prefix = self.defaultGlyphPrefixTable[prefixKey]
                defName = self.defaultItemLinkTable[itemType][itemId]
                if prefix and defName then
                    defName = zo_strformat("<<1>> <<2>>",prefix ,defName)
                end
            else
                defName = self.defaultItemLinkTable[itemType][itemLinkKey]
            end
            if defName then
                if string.lower(defName) == string.lower(itemName) then
                    itemSubTable[itemLinkKey] = nil
                end
            end
        end
    end


    if size > 0 then
        self:Message("Update " .. size .. " ItemLink name")
    end
    self.updateTotal = self.updateTotal + size
end




function J2EUpdate:UpdateItemTable(task)
    self:DebugIfMarify("UpdateItemTable()", self.checkColor)
    local itemSetTable = self.savedVariables.itemSetTable
    local itemTable = self.savedVariables.itemTable
    local itemSubTable
    local size = 0
    local itemType
    local itemName
    local hasSet, setName
    task:For(pairs(self.savedVariables.newItemTable)):Do(function(itemLink, _)
        itemId = GetItemLinkItemId(itemLink)
        itemType = GetItemLinkItemType(itemLink)
        itemSubTable = self:GetSubTable(itemTable, itemType)

        itemName = GetItemLinkName(itemLink)
        if self:ContainsNumber(itemType, ITEMTYPE_ARMOR, ITEMTYPE_WEAPON) then
            if string.match(itemName, "%^[n|p]") then
                self:Debug("　　Normal Item \"<<1>>\"", itemName)

                local prefixKey, lv, suffixKey = string.match(itemLink, "|H%d:item:%d+:(%d+):(%d+):(%d+):.*")
                self:Debug("　　suffixKey=\"<<1>>\"", suffixKey)
                local suffix = self.savedVariables.normalItemSuffixTable[tonumber(suffixKey)]
                                or self.defaultNormalItemSuffixTable[tonumber(suffixKey)]
                self:Debug("　　suffix=\"<<1>>\"", tostring(suffix))
                if suffix == nil then
                    suffix = string.match(itemName, "(of .*)%^[n|p]")
                    self:DebugIfMarify("New suffix [<<1>>] = \"<<2>>\"", suffixKey, suffix, self.checkColor)
                    self.savedVariables.normalItemSuffixTable[tonumber(suffixKey)] = suffix
                end

                itemName = string.lower(itemName)
                if suffix and suffix ~= "" then
                    suffix = string.lower(suffix)
                    itemName = itemName:gsub("%s" .. suffix, "")
                end
                if self:IsDebug() then
                    d("　　>\"" .. itemName .. "\"")
                end

                local craftingType, armorType = self:GetCraftingType(itemType, itemLink)
                if craftingType == nil then
                    self:DebugIfMarify("craftingType is nil...<<1>>", itemLink, self.failedColor)
                end
                if lv == "50" then
                    prefixKey = prefixKey .. ":" .. lv
                else
                    prefixKey = ":" .. lv
                end
                if craftingType == CRAFTING_TYPE_CLOTHIER then
                    prefixKey = armorType .. ":" .. prefixKey
                end


                self:Debug("　　prefixKey=\"<<1>>\"", tostring(prefixKey))
                local prefix = self.savedVariables.itemPrefixTable[craftingType][prefixKey]
                                or self.defaultNormalItemPrefixTable[craftingType][prefixKey]
                if prefix == nil then
                    prefix = self:Contains(itemName, self.normalItemPrefixs)
                    self:Debug("　　>New prefix [<<1>>] = \"<<2>>\"", prefixKey, prefix, self.checkColor)
                    self.savedVariables.itemPrefixTable[craftingType][prefixKey] = prefix
                end
                self:Debug("　　prefix=\"<<1>>\"", prefix)
                if prefix and prefix ~= "" then
                    prefix = string.lower(prefix)
                    prefix = prefix:gsub("%-", "%%-")
                    itemName = itemName:gsub(prefix .. "%s", "")
                end
                self:Debug("　　>\"<<1>>\"", itemName)
                itemName = self:Compress(itemName)
                self:Debug("　　>\"<<1>>\"", itemName)


            else
                hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
                if hasSet and (not itemSetTable[setId]) and (not self.defaultItemSetTable[setId]) then
                    itemSetTable[setId] = setName:gsub("(\^)%a*", "")
                end

                itemName = itemName:gsub("%^%a*", "")
                itemName = self:Compress(itemName, setId, itemType, itemLink)
            end
        else
            itemName = itemName:gsub("%^%a*", "")
            itemName = self:Compress(itemName)
        end
        itemSubTable[itemId] = itemName

        size = size + 1
        if GetDisplayName() == "@Marify" then
            local txt = "Add item " .. itemLink
            self:Message(txt)
        end
    end):Then(function()
        self.savedVariables.newItemTable = {}

    end):Then(function()
        local defSuffix
        for suffixKey, suffix in pairs(self.savedVariables.normalItemSuffixTable) do
            defSuffix = self.defaultNormalItemSuffixTable[suffixKey]
            if defSuffix and string.lower(defSuffix) == string.lower(suffix) then
                self.savedVariables.normalItemSuffixTable[suffixKey] = nil
            end
        end

        local defPrefix
        local itemSubTable
        for craftingType, itemSubTable in pairs(self.savedVariables.itemPrefixTable) do
            for prefixKey, prefix in pairs(itemSubTable) do
                defPrefix = self.defaultNormalItemPrefixTable[craftingType][prefixKey]
                if defPrefix and string.lower(defPrefix) == string.lower(prefix) then
                    self.savedVariables.itemPrefixTable[craftingType][prefixKey] = nil
                end
            end
        end

    end):Then(function(task)
        local fullName
        local defItemName
        local itemLink
        local setId
        task:For(pairs(itemTable)):Do(function(itemType, itemSubTable)
            if self.savedVariables.displayTypes[itemType] then
                task:For(pairs(itemSubTable)):Do(function(itemId, itemName)

                    defItemName = self:GetItemNameDefault(itemId, itemType)
                    if defItemName then
                        fullName = self:CreateFullName(itemName, itemId, itemType)
                        defItemName = self:CreateFullName(defItemName, itemId, itemType)
                        if defItemName then
                            if string.lower(defItemName) == string.lower(fullName) then
                                itemSubTable[itemId] = nil
                            else
                                self:DebugIfMarify("[<<1>>] \"<<2>>\" in SavedVariables",itemId, fullName, self.failedColor)
                                self:DebugIfMarify("[<<1>>] \"<<2>>\" in DefaultData",itemId, defItemName, self.failedColor)
                            end
                        end

                    elseif self:ContainsNumber(itemType, ITEMTYPE_ARMOR, ITEMTYPE_WEAPON)
                            and itemName == self:CreateFullName(itemName, itemId, itemType) then

                        itemLink = zo_strformat("|H0:item:<<1>>:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
                        _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
                        itemName = self:Compress(itemName, setId, itemType, itemLink)
                        itemSubTable[itemId] = itemName
                    else
                        itemName = self:Compress(itemName, setId, itemType, itemLink)
                        itemSubTable[itemId] = itemName
                    end
                end)
            else
                if #itemSubTable > 0 then
                    self:Debug("itemType<<1>> is not display", itemType)
                end
                itemTable[itemType] = nil
            end
        end)

    end):Then(function(task)
        task:For(pairs(self.defaultItemSetTable)):Do(function(itemId, setName)
            if setName == itemSetTable[itemId] then
                itemSetTable[itemId] = nil
            end
        end)

    end):Then(function()
        if size > 0 then
            self:Message("Update " .. size .. " Item name")
        end
        self.updateTotal = self.updateTotal + size
    end)
end

