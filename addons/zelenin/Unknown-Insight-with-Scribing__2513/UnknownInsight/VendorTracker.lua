local class = ZO_InitializingObject:Subclass()
unknownInsightVendorTracker = class

local color = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_ANNOUNCEMENTS)

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sVendorTracker", self.owner.name)

    local scribingItemTypes = {
        [ITEMTYPE_CRAFTED_ABILITY] = true,
        [ITEMTYPE_CRAFTED_ABILITY_SCRIPT] = true,
    }

    local function hasScribingItems(itemLinks)
        for _, itemLink in ipairs(itemLinks) do
            local itemType, specializedItemType = GetItemLinkItemType(itemLink)
            if scribingItemTypes[itemType] then
                return true
            end
        end
        return false
    end

    local function hasUnknown(itemLinks, character)
        for _, itemLink in ipairs(itemLinks) do
            if self.owner:IsUnknownByCharacter(itemLink, character.id) then
                return true
            end
        end
        return false
    end

    local function listCharacters(itemLinks)
        local characterNames = {}
        for _, character in ipairs(LibCharacter:GetAccountCharacters(nil, LibCharacter.SORT_NAME)) do
            if hasUnknown(itemLinks, character) then
                table.insert(characterNames, character.name)
            end
        end
        return characterNames
    end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_STORE, function()
        --local action, name, interactBlocked, isOwned, additionalInfo, contextualInfo, contextualLink, isCriminalInteract = GetGameCameraInteractableActionInfo()
        --if self.npcName ~= name then
        --    return
        --end

        local itemLinks = {}
        for storeItemIndex = 1, GetNumStoreItems() do
            local itemLink = GetStoreItemLink(storeItemIndex)
            table.insert(itemLinks, itemLink)
        end

        if not hasScribingItems(itemLinks) then
            return
        end

        --for storeItemIndex = 1, GetNumStoreItems() do
        --    local icon, name, stack, price, sellPrice, meetsRequirementsToBuy, meetsRequirementsToUse, quality, questNameColor, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2, entryType, buyStoreFailure, buyErrorStringId, actorCategory = GetStoreEntryInfo(storeItemIndex)
        --
        --    --local itemLink = GetStoreItemLink(storeItemIndex)
        --    --local itemType, specializedItemType = GetItemLinkItemType(itemLink)
        --    --CHAT_ROUTER:AddSystemMessage(string.format("%s icon: %s, name: %s, stack: %d, price: %d, sellPrice: %d, meetsRequirementsToBuy: %s, meetsRequirementsToUse: %s, quality: %d, questNameColor: %s, currencyType1: %d, currencyQuantity1: %d, currencyType2: %d, currencyQuantity2: %d, entryType: %d, buyStoreFailure: %d, buyErrorStringId: %d, actorCategory: %d", itemLink, icon, name, stack, price, sellPrice, tostring(meetsRequirementsToBuy), tostring(meetsRequirementsToUse), quality, tostring(questNameColor), currencyType1, currencyQuantity1, currencyType2, currencyQuantity2, entryType, buyStoreFailure, buyErrorStringId, actorCategory))
        --
        --end

        local unknownColor = self.owner.settings.data.colorUnknown

        local characterNames = listCharacters(itemLinks)
        if #characterNames == 0 then
            CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r The vendor has not unknown items", color:ToHex(), self.owner.addonData.title))
        else
            CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r The vendor has unknown items for: |c%s%s|r", color:ToHex(), self.owner.addonData.title, self.owner:rgbToHex(unknownColor.r, unknownColor.g, unknownColor.b), table.concat(characterNames, ", ")))
        end
    end)
end