Reforged.Modules.register({
    id      = "items",
    enabled = function()
        return GetCVar("language.2") == "br" and (
            Reforged.Settings.ShowItemsNamesTooltip    ~= "br" or
            Reforged.Settings.ShowItemsEnchantsTooltip ~= "br" or
            Reforged.Settings.ShowItemsTraitsTooltip   ~= "br" or
            Reforged.Settings.ShowItemsSetsTooltip     ~= "br"
        )
    end,
    activate = function()
        local rsd     = Reforged.Settings.Data
        local backup  = Reforged.StringsBackup
        local mr      = Reforged.Strings.magicReplace
        local enchants = Reforged.Data.Links.enchants or {}

        -- Build pre-sorted lookup tables once at activation time
        local sortedPrefixes = {}
        for k, v in pairs(rsd.Prefixes) do
            sortedPrefixes[#sortedPrefixes + 1] = {pt = k, en = v}
        end
        table.sort(sortedPrefixes, function(a, b) return #a.pt > #b.pt end)

        local sortedAffixes = {}
        for k, v in pairs(rsd.Affixes) do
            sortedAffixes[#sortedAffixes + 1] = {pt = k, en = v}
        end
        table.sort(sortedAffixes, function(a, b) return #a.pt > #b.pt end)

        local sortedEnchantPrefixes = {}
        for k, v in pairs(rsd.EnchantPrefixes) do
            sortedEnchantPrefixes[#sortedEnchantPrefixes + 1] = {pt = k, en = v}
        end
        table.sort(sortedEnchantPrefixes, function(a, b) return #a.pt > #b.pt end)

        local function splitItemName(itemName, itemNameRaw)
            local finalName   = ""
            local foundPrefix = nil
            local foundAffix  = nil
            local remainder   = mr(itemName, itemNameRaw, "")

            for _, d in ipairs(sortedPrefixes) do
                if string.find(remainder, d.pt, 1, true) then
                    foundPrefix = d.en
                    remainder = mr(remainder, d.pt, "")
                    break
                end
            end
            for _, d in ipairs(sortedAffixes) do
                if string.find(remainder, d.pt, 1, true) then
                    foundAffix = d.en
                    remainder = mr(remainder, d.pt, "")
                    break
                end
            end

            if foundPrefix then finalName = foundPrefix .. " " end
            finalName = finalName .. (rsd.Parts[itemNameRaw] or itemNameRaw)
            if foundAffix  then finalName = finalName .. " " .. foundAffix end
            return finalName
        end

        local function buildBilingual(brText, enText, mode)
            if mode == "bren" then
                return string.format("%s \n|ca99e83 (%s)", brText, enText)
            elseif mode == "enbr" then
                return string.format("%s \n|ca99e83 (%s)", enText, brText)
            end
            return enText
        end

        -- Inventory list: hook GetItemName(bagId, slotIndex) to show bilingual names
        Reforged.Hooks.replace("GetItemName", function(orig)
            return function(bagId, slotIndex)
                local originalNameRaw = orig(bagId, slotIndex)
                local mode = Reforged.Settings.ShowItemsNamesTooltip
                if mode == "br" or Reforged.craftingStationActive then return originalNameRaw end
                if type(bagId) ~= "number" or type(slotIndex) ~= "number" then return originalNameRaw end

                local lnk = GetItemLink(bagId, slotIndex)
                if not lnk or lnk == "" then return originalNameRaw end

                if not originalNameRaw or originalNameRaw == "" then return originalNameRaw end

                local itmType    = GetItemLinkItemType(lnk)
                local itmId      = GetItemLinkItemId(lnk)
                local itmName    = GetItemLinkName(lnk)
                local itmNameRaw = rsd.Items[itmId]
                local itmNameRawBr = ZO_CachedStrFormat("<<z:1>>",
                    GetItemLinkName("|H1:item:" .. itmId .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))

                local finalName = nil

                if itmType == ITEMTYPE_GLYPH_ARMOR or itmType == ITEMTYPE_GLYPH_JEWELRY or itmType == ITEMTYPE_GLYPH_WEAPON then
                    if itmNameRaw then
                        local prefix  = ""
                        local lowered = ZO_CachedStrFormat("<<z:1>>", itmName)
                        for _, d in ipairs(sortedEnchantPrefixes) do
                            if string.find(lowered, d.pt, 1, true) then
                                prefix = d.en .. " "
                                break
                            end
                        end
                        finalName = prefix .. itmNameRaw
                    end
                elseif itmType == ITEMTYPE_POISON or itmType == ITEMTYPE_POTION then
                    local key = ZO_CachedStrFormat("<<z:1>>", itmName)
                    finalName = rsd.Potions[key] or rsd.Items[itmId]
                elseif itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON then
                    if itmNameRawBr and rsd.Parts[ZO_CachedStrFormat("<<z:1>>", itmNameRawBr)] then
                        finalName = splitItemName(ZO_CachedStrFormat("<<z:1>>", itmName), itmNameRawBr)
                    else
                        finalName = rsd.Items[itmId]
                    end
                else
                    finalName = rsd.Items[itmId]
                end

                if finalName then
                    if mode == "bren" then
                        return originalNameRaw .. " |ca99e83(" .. finalName .. ")|r"
                    elseif mode == "enbr" then
                        return finalName .. " |ca99e83(" .. originalNameRaw .. ")|r"
                    else
                        return finalName
                    end
                end
                return originalNameRaw
            end
        end)

        local function modifyTooltip(lnk)
            if not lnk or lnk == "" then return end
            local settings = Reforged.Settings
            local anyActive = settings.ShowItemsNamesTooltip    ~= "br"
                           or settings.ShowItemsEnchantsTooltip ~= "br"
                           or settings.ShowItemsTraitsTooltip   ~= "br"
                           or settings.ShowItemsSetsTooltip     ~= "br"
            if not anyActive then return end

            local itmType     = GetItemLinkItemType(lnk)
            local itmId       = GetItemLinkItemId(lnk)
            local itmName     = GetItemLinkName(lnk)
            local brsName     = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, itmName)
            local itmNameRaw  = rsd.Items[itmId]
            local itmNameRawBr = ZO_CachedStrFormat("<<z:1>>",
                GetItemLinkName("|H1:item:" .. itmId .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))

            local finalName, finalEnchant, finalTrait, finalSet
            local brsEnchant, brsTrait, brsSet

            -- Names
            if itmType == ITEMTYPE_GLYPH_ARMOR or itmType == ITEMTYPE_GLYPH_JEWELRY or itmType == ITEMTYPE_GLYPH_WEAPON then
                if itmNameRaw then
                    local prefix = ""
                    local lowered = ZO_CachedStrFormat("<<z:1>>", itmName)
                    for _, d in ipairs(sortedEnchantPrefixes) do
                        if string.find(lowered, d.pt, 1, true) then
                            prefix = d.en .. " "
                            break
                        end
                    end
                    finalName = prefix .. itmNameRaw
                end
            elseif itmType == ITEMTYPE_POISON or itmType == ITEMTYPE_POTION then
                local key = ZO_CachedStrFormat("<<z:1>>", itmName)
                finalName = rsd.Potions[key] or rsd.Items[itmId]
            elseif itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON then
                if itmNameRawBr and rsd.Parts[ZO_CachedStrFormat("<<z:1>>", itmNameRawBr)] then
                    finalName = splitItemName(ZO_CachedStrFormat("<<z:1>>", itmName), itmNameRawBr)
                else
                    finalName = rsd.Items[itmId]
                end
            else
                finalName = rsd.Items[itmId]
            end

            -- Enchantments
            if itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON
            or itmType == ITEMTYPE_GLYPH_ARMOR or itmType == ITEMTYPE_GLYPH_JEWELRY or itmType == ITEMTYPE_GLYPH_WEAPON then
                local enchantId = GetItemLinkFinalEnchantId(lnk)
                if enchants[enchantId] then
                    local _, enchantHeader = GetItemLinkEnchantInfo(lnk)
                    brsEnchant  = string.match(enchantHeader, ": (.*)$")
                    finalEnchant = enchants[enchantId]
                end
            end

            -- Traits
            if itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON
            or itmType == ITEMTYPE_ARMOR_TRAIT or itmType == ITEMTYPE_JEWELRY_TRAIT or itmType == ITEMTYPE_WEAPON_TRAIT then
                local traitType = GetItemLinkTraitType(lnk)
                if rsd.Traits[traitType] then
                    brsTrait  = GetString("SI_ITEMTRAITTYPE", traitType)
                    finalTrait = rsd.Traits[traitType]
                end
            end

            -- Sets
            if itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON then
                local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(lnk, false)
                brsSet = setName
                if rsd.Sets[setId] then finalSet = rsd.Sets[setId] end
            end
            if itmType == ITEMTYPE_CONTAINER then
                local numSetIds = GetItemLinkNumContainerSetIds(lnk)
                for i = 1, numSetIds do
                    local _, _, _, _, _, setId = GetItemLinkContainerSetInfo(lnk, i)
                    if rsd.Sets[setId] then finalSet = rsd.Sets[setId] end
                end
            end

            -- Apply strings
            local mode
            mode = settings.ShowItemsNamesTooltip
            if mode ~= "br" and finalName and brsName then
                local out = mode == "en" and finalName or buildBilingual(brsName, finalName, mode)
                SafeAddString(SI_TOOLTIP_ITEM_NAME, out, 10)
            end

            mode = settings.ShowItemsEnchantsTooltip
            if mode ~= "br" and finalEnchant and brsEnchant then
                local out = mode == "en" and finalEnchant or buildBilingual(brsEnchant, finalEnchant, mode)
                SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED,
                    ZO_CachedStrFormat(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, out), 10)
            end

            mode = settings.ShowItemsTraitsTooltip
            if mode ~= "br" and finalTrait and brsTrait then
                local out = mode == "en" and finalTrait or buildBilingual(brsTrait, finalTrait, mode)
                SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER, out, 10)
                SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER,
                    GetString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER):gsub("<<2>>", out), 10)
            end

            mode = settings.ShowItemsSetsTooltip
            if mode ~= "br" and finalSet and brsSet then
                local out
                if mode == "en" then
                    out = string.format("«%s»", finalSet)
                else
                    out = buildBilingual(brsSet, finalSet, mode)
                end
                SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME,
                    GetString(SI_ITEM_FORMAT_STR_SET_NAME):gsub("«<<1>>»", out), 10)
            end
        end

        local function restoreItemStrings()
            SafeAddString(SI_TOOLTIP_ITEM_NAME,                        backup["SI_TOOLTIP_ITEM_NAME"], 10)
            SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED,     backup["SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED"], 10)
            SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER,        backup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER"], 10)
            SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER, backup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER"], 10)
            SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME,                 backup["SI_ITEM_FORMAT_STR_SET_NAME"], 10)
        end

        local function itemTooltipHook(tooltipCtrl, method, linkFunc)
            local origMethod = tooltipCtrl[method]
            tooltipCtrl[method] = function(self, ...)
                if linkFunc then modifyTooltip(linkFunc(...)) end
                origMethod(self, ...)
                restoreItemStrings()
            end
        end

        local function comparativeHook(tooltip, gameDataType, ...)
            if gameDataType == TOOLTIP_GAME_DATA_EQUIPPED_INFO then
                local slotIndex, actorCategory = ...
                modifyTooltip(GetItemLink(GetWornBagForGameplayActorCategory(actorCategory), slotIndex))
            elseif gameDataType == TOOLTIP_GAME_DATA_STOLEN then
                restoreItemStrings()
            end
        end

        local function GetWornLink(slot, bagId) return GetItemLink(bagId, slot) end
        local function GetChatLink(lnk)         return lnk end
        local function CheckAlchemyName(...)
            local link, result = GetAlchemyResultingItemLink(...)
            return result == PROSPECTIVE_ALCHEMY_RESULT_KNOWN and link or ""
        end

        -- Keyboard tooltip hooks
        itemTooltipHook(ItemTooltip, "SetAttachedMailItem",             GetAttachedItemLink)
        itemTooltipHook(ItemTooltip, "SetBagItem",                      GetItemLink)
        itemTooltipHook(ItemTooltip, "SetBuybackItem",                  GetBuybackItemLink)
        itemTooltipHook(ItemTooltip, "SetLink",                         GetChatLink)
        itemTooltipHook(ItemTooltip, "SetLootItem",                     GetLootItemLink)
        itemTooltipHook(ItemTooltip, "SetStoreItem",                    GetStoreItemLink)
        itemTooltipHook(ItemTooltip, "SetTradeItem",                    GetTradeItemLink)
        itemTooltipHook(ItemTooltip, "SetTradingHouseItem",             GetTradingHouseSearchResultItemLink)
        itemTooltipHook(ItemTooltip, "SetTradingHouseListing",          GetTradingHouseListingItemLink)
        itemTooltipHook(ItemTooltip, "SetWornItem",                     GetWornLink)
        itemTooltipHook(ItemTooltip, "SetReward",                       GetItemRewardItemLink)
        itemTooltipHook(ItemTooltip, "SetItemUsingEnchantment",         GetEnchantedItemResultingItemLink)
        itemTooltipHook(ItemTooltip, "SetAction",                       GetSlotItemLink)
        itemTooltipHook(ItemTooltip, "SetItemSetCollectionPieceLink",   GetChatLink)
        itemTooltipHook(PopupTooltip, "SetLink",                        GetChatLink)

        ZO_PreHookHandler(ComparativeTooltip1, "OnAddGameData", comparativeHook)
        ZO_PreHookHandler(ComparativeTooltip2, "OnAddGameData", comparativeHook)

        itemTooltipHook(ZO_AlchemyTopLevelTooltip,                              "SetPendingAlchemyItem",     CheckAlchemyName)
        itemTooltipHook(ZO_EnchantingTopLevelTooltip,                           "SetPendingEnchantingItem",  GetEnchantingResultingItemLink)
        itemTooltipHook(ZO_ProvisionerTopLevelTooltip,                          "SetProvisionerResultItem",  GetRecipeResultItemLink)
        itemTooltipHook(ZO_SmithingTopLevelCreationPanelResultTooltip,          "SetPendingSmithingItem",    GetSmithingPatternResultLink)
        itemTooltipHook(ZO_SmithingTopLevelImprovementPanelResultTooltip,       "SetSmithingImprovementResult", GetSmithingImprovedItemLink)
        itemTooltipHook(ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip,     "SetPendingRetraitItem",     GetResultingItemLinkAfterRetrait)
        itemTooltipHook(ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip,     "SetBagItem",               GetItemLink)
        itemTooltipHook(ZO_RetraitStation_KeyboardTopLevelReconstructPanelOptionsPreviewTooltip, "SetItemSetCollectionPieceLink", GetChatLink)

        -- Third-party compatibility
        if Reforged.IsAddonRunning("TamrielTradeCentre") then
            if TamrielTradeCentre_ItemInfo then
                Reforged.Hooks.pre(TamrielTradeCentre_ItemInfo, "New",
                    function() SafeAddString(SI_TOOLTIP_ITEM_NAME, backup["SI_TOOLTIP_ITEM_NAME"], 10) end)
            end
            if TamrielTradeCentre_MasterWritInfo then
                Reforged.Hooks.pre(TamrielTradeCentre_MasterWritInfo, "New",
                    function() SafeAddString(SI_TOOLTIP_ITEM_NAME, backup["SI_TOOLTIP_ITEM_NAME"], 10) end)
            end
        end

        if ItemBrowser then
            itemTooltipHook(ExtendedJournalItemTooltip, "SetLink", GetChatLink)
        end
        if WishList then
            itemTooltipHook(WishListTooltip, "SetLink", GetChatLink)
        end

        -- Gamepad hooks
        function ZO_IsIngameUI(...) return true end  -- required for gamepad tooltip path

        local function gpPre(fn)  return function(tooltip, ...) modifyTooltip(fn(...))  end end
        local function gpPost()   restoreItemStrings() end

        local gpLeft    = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
        local gpRight   = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP)
        local gpMovable = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP)

        Reforged.Hooks.pre(gpLeft,    "LayoutItem", gpPre(function(lnk) return lnk end))
        Reforged.Hooks.pre(gpRight,   "LayoutItem", gpPre(function(lnk) return lnk end))
        Reforged.Hooks.pre(gpMovable, "LayoutItem", gpPre(function(lnk) return lnk end))
        Reforged.Hooks.post(gpLeft,    "LayoutItem", gpPost)
        Reforged.Hooks.post(gpRight,   "LayoutItem", gpPost)
        Reforged.Hooks.post(gpMovable, "LayoutItem", gpPost)

        Reforged.Hooks.pre(ZO_GamepadSmithingCreation,    "SetupResultTooltip", function(_, ...) modifyTooltip(GetSmithingPatternResultLink(...)) end)
        Reforged.Hooks.pre(ZO_GamepadSmithingImprovement, "SetupResultTooltip", function(_, ...) modifyTooltip(GetSmithingImprovedItemLink(...)) end)
        Reforged.Hooks.pre(ZO_GamepadAlchemy,             "UpdateTooltip",      function(t)      modifyTooltip(CheckAlchemyName(t:GetAllCraftingBagAndSlots())) end)
        Reforged.Hooks.pre(ZO_GamepadEnchanting,          "UpdateTooltip",      function(t)
            if t:IsCraftable() then
                modifyTooltip(GetEnchantingResultingItemLink(t:GetAllCraftingBagAndSlots()))
            elseif t:IsExtractable() and t.extractionSlot:HasOneItem() then
                modifyTooltip(GetItemLink(t.extractionSlot:GetItemBagAndSlot(1)))
            end
        end)
        Reforged.Hooks.pre(ZO_GamepadSmithingExtraction,  "RefreshTooltip",     function(t)
            if t.extractionSlot:HasOneItem() then
                local bagId, slotIndex = t.extractionSlot:GetItemBagAndSlot(1)
                modifyTooltip(GetItemLink(bagId, slotIndex))
            end
        end)
        Reforged.Hooks.pre(ZO_RetraitStation_Retrait_Gamepad, "LayoutSourceItemTooltip", function(_, itemData)
            if itemData then modifyTooltip(GetItemLink(itemData.bagId, itemData.slotIndex)) end
        end)
        Reforged.Hooks.pre(ZO_RetraitStation_Retrait_Gamepad, "LayoutResultItemTooltip", function(t, traitData)
            local itemData = t.inventory:CurrentSelection()
            if itemData and traitData then
                modifyTooltip(GetResultingItemLinkAfterRetrait(itemData.bagId, itemData.slotIndex, traitData.trait))
            end
        end)
        Reforged.Hooks.pre(ZO_RetraitStation_Reconstruct_Gamepad, "RefreshResultTooltip", function(t)
            if t.itemSetPieceData and t:IsOptionsModeShowing() then
                modifyTooltip(t.itemSetPieceData:GetItemLink())
            end
        end)

        Reforged.Hooks.post(ZO_GamepadSmithingCreation,    "SetupResultTooltip",  gpPost)
        Reforged.Hooks.post(ZO_GamepadSmithingImprovement, "SetupResultTooltip",  gpPost)
        Reforged.Hooks.post(ZO_GamepadAlchemy,             "UpdateTooltip",       gpPost)
        Reforged.Hooks.post(ZO_GamepadEnchanting,          "UpdateTooltip",       gpPost)
        Reforged.Hooks.post(ZO_GamepadSmithingExtraction,  "RefreshTooltip",      gpPost)
        Reforged.Hooks.post(ZO_RetraitStation_Retrait_Gamepad, "LayoutSourceItemTooltip", gpPost)
        Reforged.Hooks.post(ZO_RetraitStation_Retrait_Gamepad, "LayoutResultItemTooltip", gpPost)
        Reforged.Hooks.post(ZO_RetraitStation_Reconstruct_Gamepad, "RefreshResultTooltip", gpPost)

        -- English keyword search across all bag-based inventory contexts.
        -- searchResults for BAG_SLOT_TARGET uses a nested structure: [bagId][slotIndex].
        local searchContextBags = {
            playerInventoryTextSearch = { BAG_WORN, BAG_BACKPACK, BAG_VIRTUAL },
            playerBankTextSearch      = { BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK },
            guildBankTextSearch       = { BAG_BACKPACK, BAG_GUILDBANK },
        }
        Reforged.Hooks.pre(TEXT_SEARCH_MANAGER, "OnBackgroundListFilterComplete", function(_, taskId)
            if not Reforged.Settings.EnglishSearch then return end
            local context, filterTarget = TEXT_SEARCH_MANAGER:GetInProgressTaskInfoById(taskId)
            local bags = searchContextBags[context]
            if not bags or filterTarget ~= BACKGROUND_LIST_FILTER_TARGET_BAG_SLOT then return end
            local contextSearch = TEXT_SEARCH_MANAGER.contextSearches[context]
            local searchString = zo_strlower(contextSearch.searchText)
            if not searchString or searchString == "" or zo_strmatch(searchString, "[a-z]") == nil then return end
            if not contextSearch.searchResults[filterTarget] then
                contextSearch.searchResults[filterTarget] = {}
            end
            local items = rsd.Items
            if not items then return end
            for _, bagId in ipairs(bags) do
                for slotIndex = 0, GetBagSize(bagId) - 1 do
                    local link = GetItemLink(bagId, slotIndex)
                    if link ~= "" then
                        local itemId = GetItemLinkItemId(link)
                        if itemId ~= 0 then
                            local enName = items[itemId]
                            if enName and zo_strfind(zo_strlower(enName), searchString, 1, true) then
                                if not contextSearch.searchResults[filterTarget][bagId] then
                                    contextSearch.searchResults[filterTarget][bagId] = {}
                                end
                                contextSearch.searchResults[filterTarget][bagId][slotIndex] = true
                            end
                        end
                    end
                end
            end
        end)
    end,
})
