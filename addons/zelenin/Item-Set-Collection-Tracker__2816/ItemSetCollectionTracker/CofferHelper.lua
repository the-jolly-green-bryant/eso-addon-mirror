local addon = ZO_Object:Subclass()
itemSetCollectionTrackerCofferHelper = addon

function addon:New(...)
    local instance = ZO_Object.New(self)
    instance:initialize(...)
    return instance
end

function addon:initialize(owner)
    self.owner = owner
    self.name = string.format("%sCofferHelper", self.owner.name)

    self.npcs = {
        ["Maj al-Ragath"] = true,
        ["Glirion the Redbeard"] = true,
        ["Urgarlag Chief-bane"] = true,
    }

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_STORE, function()
        local action, name, interactBlocked, isOwned, additionalInfo, contextualInfo, contextualLink, isCriminalInteract = GetGameCameraInteractableActionInfo()
        if self.npcs[name] ~= true then
            return
        end

        local npcName = name

        local fullContainer = nil
        local setContainers = {}
        local setData = {}

        for storeItemIndex = 1, GetNumStoreItems() do
            local icon, name, stack, price, sellPrice, meetsRequirementsToBuy, meetsRequirementsToUse, quality, questNameColor, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2, entryType, buyStoreFailure, buyErrorStringId = GetStoreEntryInfo(storeItemIndex)
            if currencyType1 ~= CURT_UNDAUNTED_KEYS then
                self.owner.logger:Error(string.format("something wrong. currency is not undaunted keys"))
            end
            local itemLink = GetStoreItemLink(storeItemIndex)
            local itemType, specializedItemType = GetItemLinkItemType(itemLink)
            if specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER then
                local numSetId = GetItemLinkNumContainerSetIds(itemLink)
                if numSetId == 0 then
                    fullContainer = {
                        storeItemIndex = storeItemIndex,
                        itemLink = itemLink,
                        name = name,
                        currencyQuantity = currencyQuantity1,
                        currencyType = currencyType1,
                        setIds = {}
                    }
                elseif numSetId > 0 then
                    local container = {
                        storeItemIndex = storeItemIndex,
                        itemLink = itemLink,
                        name = name,
                        currencyQuantity = currencyQuantity1,
                        currencyType = currencyType1,
                        setIds = {}
                    }
                    for setIndex = 1, numSetId do
                        local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkContainerSetInfo(itemLink, setIndex)
                        if setId > 0 then
                            container.setIds[setId] = true
                            if fullContainer ~= nil then
                                fullContainer.setIds[setId] = true
                            end
                            setData[setId] = {
                                all = 0,
                                unknown = 0
                            }
                        end
                    end
                    table.insert(setContainers, container)
                end
            end
        end

        local all = 0
        local unknown = 0
        for setId, _ in pairs(setData) do
            for index = 1, GetNumItemSetCollectionPieces(setId) do
                local pieceId, slot = GetItemSetCollectionPieceInfo(setId, index)
                local itemLink = GetItemSetCollectionPieceItemLink(pieceId, LINK_STYLE_DEFAULT, ITEM_TRAIT_TYPE_NONE)
                local equipType = GetItemLinkEquipType(itemLink)

                if equipType == EQUIP_TYPE_SHOULDERS then
                    all = all + 1
                    setData[setId].all = setData[setId].all + 1

                    local isUnlocked = IsItemSetCollectionPieceUnlocked(pieceId)
                    if isUnlocked == false then
                        unknown = unknown + 1
                        setData[setId].unknown = setData[setId].unknown + 1
                    end
                end
            end
        end

        local function getKnowledge(container)
            local result = {
                all = 0,
                unknown = 0
            }

            for setId, _ in pairs(container.setIds) do
                result.all = setData[setId].all + result.all
                result.unknown = setData[setId].unknown + result.unknown
            end

            return result.unknown, result.all
        end

        local coffers = {}
        if fullContainer ~= nil then
            table.insert(coffers, {
                name = fullContainer.name,
                unknown = unknown,
                all = all,
                qty = unknown == 0 and 0 or fullContainer.currencyQuantity * all / unknown
            })
        end
        for _, setContainer in ipairs(setContainers) do
            local knowledgeUnknown, knowledgeAll = getKnowledge(setContainer)
            table.insert(coffers, {
                name = setContainer.name,
                unknown = knowledgeUnknown,
                all = knowledgeAll,
                qty = knowledgeUnknown == 0 and 0 or setContainer.currencyQuantity * knowledgeAll / knowledgeUnknown
            })
        end

        table.sort(coffers, function(a, b)
            return a.qty < b.qty
        end)

        CHAT_ROUTER:AddSystemMessage(string.format("==="))
        CHAT_ROUTER:AddSystemMessage(string.format("%s:", npcName))
        for _, coffer in ipairs(coffers) do
            if coffer.qty > 0 then
                CHAT_ROUTER:AddSystemMessage(string.format("%s = %0.1f [%d/%d]", coffer.name, coffer.qty, coffer.unknown, coffer.all))
            end
        end
    end)
end
