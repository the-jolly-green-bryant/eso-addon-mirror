K2EUpdate = {
    displayName = "|c3CB371" .. "K2E Update" .. "|r",
    shortName = "K2u",
    name = "K2EUpdate",
    author = "@dedo2 (Original:@Naaa)",
    version = "1.2.2",

    txtColor = "|c"..ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_TOOLTIP, ITEM_TOOLTIP_COLOR_GENERAL)):ToHex(),
}




function K2EUpdate:AddItemName(itemLink)
    if itemLink == nil or itemLink == "" then
        return
    end
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    if (not self.savedVariables.displayTypes[itemType]) then
        return
    end


    local itemName = self:GetItemName(itemLink)
    if itemName then
        local txt = self.txtColor .. zo_strformat(GetString(K2E_FORMAT_NAME), itemName) .. "|r"
        ItemTooltip:AddLine(txt, "", 0.8, 0.8, 0.8, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
    end

    local hasSet, setName = self:GetItemSetName(itemLink)
    if setName then
        local txt = self.txtColor .. zo_strformat(GetString(K2E_FORMAT_SET_NAME), setName) .. "|r"
        ItemTooltip:AddLine(txt, "", 0.8, 0.8, 0.8, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
    end

    self:CheckItem(itemName, hasSet, setName, itemLink)
end




function K2EUpdate:AddItemNameGamePad(tooltip, ...)
    local itemLink = ({...})[1]
    if itemLink == nil or itemLink == "" then
        return
    end
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    if (not self.savedVariables.displayTypes[itemType]) then
        return
    end


    local mystyle = {
        fontSize = 24,
        fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1,
        }
    local itemName = self:GetItemName(itemLink)
    if itemName then
        local txt = zo_strformat(GetString(K2E_FORMAT_NAME), itemName)
        tooltip:AddLine(txt, mystyle, tooltip:GetStyle("bodySection"))
    end

    local hasSet, setName = self:GetItemSetName(itemLink)
    if setName then
        local txt = zo_strformat(GetString(K2E_FORMAT_SET_NAME), setName)
        tooltip:AddLine(txt, mystyle, tooltip:GetStyle("bodySection"))
    end

    self:CheckItem(itemName, hasSet, setName, itemLink)
end




function K2EUpdate:AddSkillName(skillData, tooltip)
    local txt = zo_strformat(GetString(K2E_FORMAT_NAME), self:GetSkillName(skillData.abilityId))
    tooltip:AddLine(txt, "", 0.8, 0.8, 0.8, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
end




function K2EUpdate:CheckItem(itemName, hasSet, setName, itemLink)

    if (not itemLink) then
        return
    end
    if itemName and (not hasSet) then
        return
    end
    if itemName and hasSet and setName then
        return
    end

    local itemId = GetItemLinkItemId(itemLink)
    if self.savedVariables.newItemTable[itemId] or self.savedVariables.newItemLinkTable[itemLink] then
        return
    end

    if hasSet and (setName == nil) then
        hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
        local txt = zo_strformat(GetString(K2E_NEW_SET), setName, itemLink)
        self:Message(txt)

    elseif GetDisplayName() == "@Marify" then
        local txt = zo_strformat(GetString(K2E_NEW_ITEM), itemLink)
        self:Message(txt)
    end

    local itemType = GetItemLinkItemType(itemLink)
    if self:ContainsNumber(itemType, ITEMTYPE_POISON, ITEMTYPE_POTION) then
        self.savedVariables.newItemLinkTable[itemLink] = true

    elseif self:ContainsNumber(itemType, ITEMTYPE_ARMOR, ITEMTYPE_WEAPON) then
        self.savedVariables.newItemLinkTable[itemLink] = true

    else
        self.savedVariables.newItemTable[itemId] = itemLink
    end
end




function K2EUpdate:CheckItems()

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




function K2EUpdate:CreateMenu()

    local panelData = {
        type = "panel",
        reference = "DASettingControl",
        name = self.displayName,
        displayName = self.displayName,
        author = self.author,
        version = self.version,
    }
    local panel = LibAddonMenu2:RegisterAddonPanel(self.displayName, panelData)



    local itemtypeSubmenu = {}
    for itemType = ITEMTYPE_ITERATION_BEGIN + 1, ITEMTYPE_MAX_VALUE do

        local itemTypeName = GetString("SI_ITEMTYPE", itemType)
        if self:ContainsNumber(itemType, ITEMTYPE_BLACKSMITHING_MATERIAL,
                                         ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
                                         ITEMTYPE_BLACKSMITHING_BOOSTER) then
            itemTypeName = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_BLACKSMITHING) .. ":" .. itemTypeName

        elseif self:ContainsNumber(itemType, ITEMTYPE_CLOTHIER_MATERIAL,
                                             ITEMTYPE_CLOTHIER_RAW_MATERIAL,
                                             ITEMTYPE_CLOTHIER_BOOSTER) then
            itemTypeName = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CLOTHING) .. ":" .. itemTypeName

        elseif self:ContainsNumber(itemType, ITEMTYPE_WOODWORKING_MATERIAL,
                                             ITEMTYPE_WOODWORKING_RAW_MATERIAL,
                                             ITEMTYPE_WOODWORKING_BOOSTER) then
            itemTypeName = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WOODWORKING) .. ":" .. itemTypeName

        elseif self:ContainsNumber(itemType, ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
                                             ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
                                             ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
                                             ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
                                             ITEMTYPE_JEWELRY_TRAIT,
                                             ITEMTYPE_JEWELRY_RAW_TRAIT) then
            itemTypeName = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRYCRAFTING) .. ":" .. itemTypeName

        elseif self:ContainsNumber(itemType, ITEMTYPE_ENCHANTING_RUNE_ASPECT,
                                             ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
                                             ITEMTYPE_ENCHANTING_RUNE_POTENCY) then
            itemTypeName = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ENCHANTING) .. ":" .. itemTypeName

        elseif self:ContainsNumber(itemType, ITEMTYPE_REAGENT,
                                             ITEMTYPE_POISON_BASE,
                                             ITEMTYPE_POTION_BASE) then
            itemTypeName = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALCHEMY) .. ":" .. itemTypeName

        elseif self:ContainsNumber(itemType, ITEMTYPE_INGREDIENT) then
            itemTypeName = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_PROVISIONING) .. ":" .. itemTypeName
        end
        --itemTypeName = itemTypeName .. "..." .. itemType

        if (not self:ContainsNumber(itemType, ITEMTYPE_DEPRECATED)) then
            itemtypeSubmenu[#itemtypeSubmenu + 1] = {
                type = "checkbox",
                name = itemTypeName,
                getFunc = function()
                    return self.savedVariables.displayTypes[itemType]
                end,
                setFunc = function(value)
                    self.savedVariables.displayTypes[itemType] = value
                end,
                width = "full"
            }
        end
    end
    table.sort(itemtypeSubmenu, function(a, b)
        return a.name < b.name
        end
    )


    local optionsTable = {
        {
            type = "header",
            name = EsoKR:E("표시 설정"), --@dedo2
            width = "full",
        },
        {
            type = "submenu",
            name = EsoKR:E("표시할 항목 유형"), --@dedo2
            controls = itemtypeSubmenu,
        }
    }
    LibAddonMenu2:RegisterOptionControls(self.displayName, optionsTable)



end




function K2EUpdate:GetItemName(itemLink)

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
    local name = self.savedVariables.itemLinkTable[itemLink]

    local maskedItemLink = itemLink
    if self:ContainsNumber(itemType, ITEMTYPE_POISON, ITEMTYPE_POTION) then
        maskedItemLink = string.gsub(itemLink, "(|H%d:item:%d+:%d+:%d+:%d+:).*", "%10:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
    end
    local defName = self.defaultItemLinkTable[maskedItemLink]

    if name then
        if defName and defName == name then
            self.savedVariables.itemLinkTable[itemLink] = nil
        end
        if GetDisplayName() == "@Marify" then
            return "|c88AAFF" .. name .. "|r"
        end
        return name
    elseif defName then
        if GetDisplayName() == "@Marify" then
            return "|c88AAFF" .. defName .. "|r"
        end
        return defName
    end


    local itemId = GetItemLinkItemId(itemLink)
    name = self.savedVariables.itemTable[itemId]
    defName = self.defaultItemTable[itemId]

    if name then
        if defName and defName == name then
            self.savedVariables.itemTable[itemId] = nil
        end
        return name
    elseif defName then
        return defName
    end


    name = self.savedVariables.normalItemTable[itemId]
    if name then
        local prefixKey, suffixKey = string.match(itemLink, "|H%d:item:%d+:(%d+:%d+):(%d+):.*")
        --d("suffixKey=" .. tostring(suffixKey))

        local craftingType, armorType = self:GetCraftingType(itemType, itemLink)
        if craftingType == nil then
            self:Debug("|cFF0000 craftingType is nil...|r" .. itemLink)
            return nil
        end

        local prefixs = self.savedVariables.itemPrefixTable[craftingType]
        if prefixs == nil then
            self:Debug("|cFF0000 prefixs is nil...|r" .. itemLink)
            return nil
        end

        if craftingType == CRAFTING_TYPE_CLOTHIER then
            prefixKey = armorType .. ":" .. prefixKey
        end
        local prefix = prefixs[prefixKey]
        if prefix == nil then
            return nil
        end

        local suffix = self.normalItemSuffixTable[tonumber(suffixKey)]
        if suffix == nil then
            self:Debug("|cFF0000 suffix is nil...|r" .. itemLink)
            return nil
        end

        name = prefix .. " " .. name ..  " " .. suffix
        if GetDisplayName() == "@Marify" then
            return "|cA0522D" .. name .. "|r"
        end
        return name
    end
    return nil
end




function K2EUpdate:GetItemSetName(itemLink)

    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
    if (not hasSet) then
        return hasSet, nil
    end

    local name = self.savedVariables.itemSetTable[setId]
    local defName = self.defaultItemSetTable[setId]

    if name then
        if defName and defName == name then
            self.savedVariables.itemSetTable[setId] = nil
        end
        return hasSet, name
    elseif defName then
        return hasSet, defName
    end

    return hasSet, nil
end




function K2EUpdate:GetSkillName(abilityId)

    local name = self.savedVariables.skillTable[abilityId]
    local defName = self.defaultSkillTable[abilityId]
    if name then
        if defName and defName == name then
            self.savedVariables.skillTable[abilityId] = nil
        end
        return name
    elseif defName then
        return defName
    end

    return nil
end




function K2EUpdate:OnAddOnLoaded(event, addonName)

    if addonName ~= K2EUpdate.name then
        return
    end
    setmetatable(K2EUpdate, {__index = LibMarify})


    self:InitializeTable()
    self:InitializeCommand()
    if GetCVar("language.2") == "en" then
        return
    end
    self:CreateMenu()


    EVENT_MANAGER:RegisterForEvent(self.name,  EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, slotIndex) self:AddItemName(GetItemLink(bagId, slotIndex)) end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)

    --self:PostHook(ZO_SlottableSkill,                                  "SetKeyboardTooltip",     function(tooltip, ...)   self:AddSkillName(self.skillData:GetPointAllocatorProgressionData(), ...) end)
    self:PostHook(ZO_PassiveSkillProgressionData,                       "SetKeyboardTooltip",     function(skillData, ...) self:AddSkillName(skillData, ...) end)
    self:PostHook(ZO_ActiveSkillProgressionData,                        "SetKeyboardTooltip",     function(skillData, ...) self:AddSkillName(skillData, ...) end)
    self:PostHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP),    "LayoutItem",             function(tooltip, ...)   self:AddItemNameGamePad(tooltip, ...) end)
    self:PostHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP),   "LayoutItem",             function(tooltip, ...)   self:AddItemNameGamePad(tooltip, ...) end)
    self:PostHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutItem",             function(tooltip, ...)   self:AddItemNameGamePad(tooltip, ...) end)
    self:PostHook(ItemTooltip,                                          "SetBagItem",             function(tooltip, ...)   self:AddItemName(GetItemLink(...)) end)
    self:PostHook(ItemTooltip,                                          "SetWornItem",            function(tooltip, ...)   self:AddItemName(GetItemLink(BAG_WORN, ...)) end)
    self:PostHook(ItemTooltip,                                          "SetTradingHouseListing", function(tooltip, ...)   self:AddItemName(GetTradingHouseListingItemLink(...)) end)
    self:PostHookForAGS(ItemTooltip,                                    "SetTradingHouseItem",    function(tooltip, ...)   self:AddItemName(GetTradingHouseSearchResultItemLink(...)) end)
    LibCustomMenu:RegisterContextMenu(function(...) self:ShowContextMenu(...) end, LibCustomMenu.CATEGORY_LATE)

    if GetDisplayName() == "@Marify" then
        EVENT_MANAGER:RegisterForEvent(self.name,  EVENT_GUILD_BANK_ITEMS_READY, function(...) K2EUpdate:CheckItems() end)
    end
end




function K2EUpdate:InitializeCommand()

    if GetCVar("language.2") == "en" then
        local defaultLang = self.savedVariables.defaultLanguage
        if defaultLang then
            SLASH_COMMANDS["/lang" .. defaultLang] = function()
                SetCVar("language.2", defaultLang)
            end
        end
    else
        self.savedVariables.defaultLanguage = GetCVar("language.2")
        SLASH_COMMANDS["/langen"] = function()
            SetCVar("language.2", "en")
        end
        SLASH_COMMANDS["/K2E_update"] = function()
            SetCVar("language.2", "en")
        end
    end
    SLASH_COMMANDS["/K2E_reset"] = function()
        self:ResetTable()
    end
end




function K2EUpdate:InitializeTable()
    self.savedVariables = ZO_SavedVars:NewAccountWide("K2EUpdateVariables", 2, nil, {})
    if self.savedVariables.skillTable == nil then
        self.savedVariables.skillTable = {}
    end
    if self.savedVariables.itemLinkTable == nil then
        self.savedVariables.itemLinkTable = {}
    end
    if self.savedVariables.itemTable == nil then
        self.savedVariables.itemTable = {}
    end
    if self.savedVariables.normalItemTable == nil then
        self.savedVariables.normalItemTable = {}
    end
    if self.savedVariables.itemPrefixTable == nil then
        self.savedVariables.itemPrefixTable = {}
        self.savedVariables.itemPrefixTable[CRAFTING_TYPE_BLACKSMITHING] = {}
        self.savedVariables.itemPrefixTable[CRAFTING_TYPE_CLOTHIER] = {}
        self.savedVariables.itemPrefixTable[CRAFTING_TYPE_WOODWORKING] = {}
        self.savedVariables.itemPrefixTable[CRAFTING_TYPE_JEWELRYCRAFTING] = {}
    end


    if self.savedVariables.itemSetTable == nil then
        self.savedVariables.itemSetTable = {}
    end
    if self.savedVariables.newItemLinkTable == nil then
        self.savedVariables.newItemLinkTable = {}
    end
    if self.savedVariables.newItemTable == nil then
        self.savedVariables.newItemTable = {}
    end
    local size = 0
    for key, value in pairs(self.savedVariables.newItemTable) do
        size = size + 1
    end
    for key, value in pairs(self.savedVariables.newItemLinkTable) do
        size = size + 1
    end
    if GetCVar("language.2") ~= "en" and size > 100 then
        self:Message(GetString(K2E_MSG_TOEN))
    end


    if self.savedVariables.displayTypes == nil then
        self.savedVariables.displayTypes = {}
    end
    for itemType = ITEMTYPE_ITERATION_BEGIN + 1, ITEMTYPE_MAX_VALUE do
        if self.savedVariables.displayTypes[itemType] == nil then
            self.savedVariables.displayTypes[itemType] = self:ContainsNumber(itemType,
                                                                        ITEMTYPE_ADDITIVE,
                                                                        ITEMTYPE_ARMOR,
                                                                        ITEMTYPE_ARMOR_TRAIT,
                                                                        ITEMTYPE_BLACKSMITHING_BOOSTER,
                                                                        ITEMTYPE_BLACKSMITHING_MATERIAL,
                                                                        ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
                                                                        ITEMTYPE_CLOTHIER_BOOSTER,
                                                                        ITEMTYPE_CLOTHIER_MATERIAL,
                                                                        ITEMTYPE_CLOTHIER_RAW_MATERIAL,
                                                                        ITEMTYPE_DEPRECATED,
                                                                        ITEMTYPE_ENCHANTING_RUNE_ASPECT,
                                                                        ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
                                                                        ITEMTYPE_ENCHANTING_RUNE_POTENCY,
                                                                        ITEMTYPE_FLAVORING,
                                                                        ITEMTYPE_FURNISHING_MATERIAL,
                                                                        ITEMTYPE_INGREDIENT,
                                                                        ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
                                                                        ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
                                                                        ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
                                                                        ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
                                                                        ITEMTYPE_JEWELRY_RAW_TRAIT,
                                                                        ITEMTYPE_JEWELRY_TRAIT,
                                                                        ITEMTYPE_LOCKPICK,
                                                                        ITEMTYPE_LURE,
                                                                        ITEMTYPE_MASTER_WRIT,
                                                                        ITEMTYPE_PLUG,
                                                                        ITEMTYPE_POISON,
                                                                        ITEMTYPE_POISON_BASE,
                                                                        ITEMTYPE_POTION,
                                                                        ITEMTYPE_POTION_BASE,
                                                                        ITEMTYPE_RACIAL_STYLE_MOTIF,
                                                                        ITEMTYPE_RAW_MATERIAL,
                                                                        ITEMTYPE_REAGENT,
                                                                        ITEMTYPE_SPICE,
                                                                        ITEMTYPE_STYLE_MATERIAL,
                                                                        ITEMTYPE_WEAPON,
                                                                        ITEMTYPE_WEAPON_TRAIT,
                                                                        ITEMTYPE_WOODWORKING_BOOSTER,
                                                                        ITEMTYPE_WOODWORKING_MATERIAL,
                                                                        ITEMTYPE_WOODWORKING_RAW_MATERIAL)
        end
    end

    if GetCVar("language.2") == "en" then
        local size = 0
        size = size + self:UpdateItemLinkTable()
        size = size + self:UpdateItemTable()
        size = size + self:UpdateSkillTable()
        if size == 0 then
            return
        end

        local defaultLang = self.savedVariables.defaultLanguage
        local returnMessage = self.savedVariables.returnMessage
        if defaultLang and returnMessage then
            zo_callLater(function()
                local editControl = CHAT_SYSTEM:GetEditControl()
                if (not editControl:HasFocus()) then
                   StartChatInput()
                end
                editControl:SetText("/lang" .. defaultLang)
            end, 3000)
            self:Message(returnMessage)
        end
    else
        self.savedVariables.returnMessage = GetString(K2E_MSG_TORETURN)
    end
end




function K2EUpdate:ResetTable()
    self.savedVariables.skillTable = {}
    self.savedVariables.itemLinkTable = {}
    self.savedVariables.itemTable = {}
    self.savedVariables.itemSetTable = {}
    self.savedVariables.newItemLinkTable = {}
    self.savedVariables.newItemTable = {}
    self:Message(GetString(K2E_RESET_TABLE))
end




function K2EUpdate:ShowContextMenu(inventorySlot, slotActions)

    local slotType = ZO_InventorySlot_GetType(inventorySlot)
    local itemLink = nil

    -- @see http://wiki.esoui.com/Constant_Values
    if slotType == nil then
        return true

    elseif slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
        local slotIndex = ZO_Inventory_GetSlotIndex(inventorySlot)
        itemLink = GetTradingHouseSearchResultItemLink(slotIndex)

    elseif slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
        local slotIndex = ZO_Inventory_GetSlotIndex(inventorySlot)
        itemLink = GetTradingHouseListingItemLink(slotIndex)

    elseif slotType == SLOT_TYPE_ITEM
        or slotType == SLOT_TYPE_EQUIPMENT
        or slotType == SLOT_TYPE_BANK_ITEM
        or slotType == SLOT_TYPE_GUILD_BANK_ITEM then
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
        itemLink = GetItemLink(bagId, slotIndex)

    end
    if itemLink == nil or itemLink == "" then
        return true
    end


    local itemNameJp = GetItemLinkName(itemLink)
    local itemNameEn = self:GetItemName(itemLink)
    local hasSet, setNameEn = self:GetItemSetName(itemLink)


    local editControl = CHAT_SYSTEM:GetEditControl()
    slotActions:AddCustomSlotAction(K2E_COPY_ITEM_NAME_JP, function()
        if (not editControl:HasFocus()) then
            StartChatInput()
        end
        editControl:SetText(itemNameJp:gsub("(\^)%a*", ""))
    end)

    if itemNameEn then
        slotActions:AddCustomSlotAction(K2E_COPY_ITEM_NAME_EN, function()
            if (not editControl:HasFocus()) then
                StartChatInput()
            end
            editControl:SetText(itemNameEn:gsub("(\^)%a*", ""))
        end)
    end

    if setNameEn then
        slotActions:AddCustomSlotAction(K2E_COPY_SET_NAME, function()
            if (not editControl:HasFocus()) then
                StartChatInput()
            end
            editControl:SetText(setNameEn:gsub("(\^)%a*", ""))
        end)
    end

    if GetDisplayName() == "@Marify" then
        ZO_CreateStringId("K2E_COPY_INFO", EsoKR:E("채팅에 정보를 복사하다")) --@dedo2
        slotActions:AddCustomSlotAction(K2E_COPY_INFO, function()
            if (not editControl:HasFocus()) then
                StartChatInput()
            end
            local itemId = GetItemLinkItemId(itemLink)
            local itemType, specializedItemType = GetItemLinkItemType(itemLink)
            local traitInfo = GetItemTraitInformationFromItemLink(itemLink)
            local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
            local txt = tostring(itemNameJp)
                        .. ", itemId=" .. tostring(itemId)
                        .. ", itemType=" .. tostring(itemType)
                        .. ":" .. GetString("SI_ITEMTYPE", itemType)
                        .. ", specializedItemType=" .. tostring(specializedItemType)
                        .. ":" .. GetString("SI_SPECIALIZEDITEMTYPE", specializedItemType)
                        .. ", traitInfo=" .. tostring(traitInfo)
                        .. ", setId=" .. tostring(setId)
            editControl:SetText(txt)
        end)
    end
    return true
end




function K2EUpdate:UpdateItemLinkTable()

    local itemLinkTable = self.savedVariables.itemLinkTable
    local itemName
    local itemId
    local itemType
    local prefixName
    local normalItemName
    local size = 0
    for itemLink, _ in pairs(self.savedVariables.newItemLinkTable) do
        itemType = GetItemLinkItemType(itemLink)
        itemName = GetItemLinkName(itemLink):gsub("(\^)%a*", "")

        if self:ContainsNumber(itemType, ITEMTYPE_ARMOR, ITEMTYPE_WEAPON) then
            itemId = GetItemLinkItemId(itemLink)
            prefixName = self:Contains(itemName, self.normalItemPrefixs)
            normalItemName = self:Contains(itemName, self.normalItemNames)
            if prefixName and normalItemName then

                local prefixKey, suffixKey = string.match(itemLink, "|H%d:item:%d+:(%d+:%d+):(%d+):.*")
                local craftingType, armorType = self:GetCraftingType(itemType, itemLink)
                if craftingType == nil then
                    --self:Message("craftingType is nil..." .. itemLink)
                    return nil
                end

                if craftingType == CRAFTING_TYPE_CLOTHIER then
                    prefixKey = armorType .. ":" .. prefixKey
                end
                local prefixTable = self.savedVariables.itemPrefixTable[craftingType]
                local prefix = prefixTable[prefixKey]
                if prefix == nil then
                    prefixTable[prefixKey] = prefixName
                end

                self.savedVariables.normalItemTable[itemId] = normalItemName
                size = size + 1

            else
                --d("prefixName=" .. tostring(prefixName))
                --d("normalItemName=" .. tostring(normalItemName))
                self.savedVariables.newItemTable[itemId] = itemLink
            end
        else
            itemLinkTable[itemLink] = itemName
            size = size + 1
            if GetDisplayName() == "@Marify" then
                local txt = "Add itemLink " .. itemLink
                self:Message(txt)
            end
        end
    end
    self.savedVariables.newItemLinkTable = {}


    for itemLink, _ in pairs(self.defaultItemLinkTable) do
        if GetItemLinkName(itemLink) == itemLinkTable[itemLink] then
            itemLinkTable[itemLink] = nil
        end
    end


    if size > 0 then
        self:Message("Update " .. size .. " ItemLink name")
    end
    return size
end




function K2EUpdate:UpdateItemTable()

    local itemSetTable = self.savedVariables.itemSetTable
    local itemTable = self.savedVariables.itemTable
    local size = 0
    local hasSet, setName
    for itemId, itemLink in pairs(self.savedVariables.newItemTable) do
        hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)

        itemTable[itemId] = GetItemLinkName(itemLink):gsub("(\^)%a*", "")
        if hasSet and (not itemSetTable[setId]) and (not self.defaultItemSetTable[setId]) then
            itemSetTable[setId] = setName:gsub("(\^)%a*", "")
        end
        size = size + 1
        if GetDisplayName() == "@Marify" then
            local txt = "Add item " .. itemLink
            self:Message(txt)
        end
    end
    self.savedVariables.newItemTable = {}


    for itemId, itemName in pairs(self.defaultItemTable) do
        if itemName == itemTable[itemId] then
            itemTable[itemId] = nil
        end
    end

    for itemId, setName in pairs(self.defaultItemSetTable) do
        if setName == itemSetTable[itemId] then
            itemSetTable[itemId] = nil
        end
    end


    if size > 0 then
        self:Message("Update " .. size .. " Item name")
    end
    return size
end




function K2EUpdate:UpdateSkillTable()

    local size = 0
    for _, skillTypeData in SKILLS_DATA_MANAGER:SkillTypeIterator() do
        --d("skillType=" .. skillTypeData:GetSkillType() .. ":" .. skillTypeData:GetName())

        for _, skillLineData in skillTypeData:SkillLineIterator() do
            --d("　　skillLine=" .. skillLineData:GetSkillLineIndex() .. ":" .. skillLineData:GetName())

            for _, skillData in skillLineData:SkillIterator() do
                --d("　　　　skill=" .. skillData:GetSkillIndex() .. ", isPassive=" .. tostring(skillData:IsPassive()))

                for _, skillProgression in pairs(skillData.skillProgressions) do
                    --d("　　　　　　abilityId=" .. tostring(skillProgression.abilityId) .. ":" .. tostring(skillProgression.name))

                    local skillName = skillProgression.name:gsub("(\^)%a*", "")
                    local defaultSkillName = self:GetSkillName(skillProgression.abilityId)
                    if (defaultSkillName == nil) or (defaultSkillName ~= skillName) then
                        self.savedVariables.skillTable[skillProgression.abilityId] = skillName
                        size = size + 1
                    else
                        self.savedVariables.skillTable[skillProgression.abilityId] = nil
                    end
                end
            end
        end
    end


    if size > 0 then
        self:Message("Update " .. size .. " Skill name")
    end
    return size
end

EVENT_MANAGER:RegisterForEvent(K2EUpdate.name, EVENT_ADD_ON_LOADED, function(...) K2EUpdate:OnAddOnLoaded(...) end)

