local class = ZO_InitializingObject:Subclass()
unknownInsightDataProvider = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%s%s", self.owner.name, "DataProvider")
    self.data = LibSimpleSavedVars:NewInstallationWide(string.format("%sData", self.name), 1, {
        version = nil,
        lang = nil,
        items = {},
        characters = {},
    })

    self.cache = {
        items = nil,
        isValid = {},
        isAccountWide = {},
    }
    self.onEndOfScanCallbacks = {}

    for catIndex, _ in pairs(self.data.items) do
        self.data.items[catIndex] = LibBitSetLoad(LibBitSet:New(), self.data.items[catIndex])
    end
    for charId, _ in pairs(self.data.characters) do
        self.data.characters[charId] = LibBitSetLoad(LibBitSet:New(), self.data.characters[charId])
    end

    self.meta = {
        version = GetESOVersionString(),
        lang = GetCVar("Language.2"),
        currentCharacterId = GetCurrentCharacterId(),
        currentAccount = GetDisplayName(),
    }

    local function scan()
        self:Scan()
    end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MULTIPLE_RECIPES_LEARNED, scan)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RECIPE_LEARNED, scan)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STYLE_LEARNED, scan)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COLLECTIBLE_NOTIFICATION_NEW, scan)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTED_ABILITY_LOCK_STATE_CHANGED, scan)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED, scan)
    zo_callLater(scan, 7000)
end

function class:Scan()
    self:gc()
    self:scanItems()
    self:loadItemData()
    self:scanCharacter()

    for _, callback in ipairs(self.onEndOfScanCallbacks) do
        callback()
    end
end

function class:loadItemData()
    if self.cache.items ~= nil then
        return
    end

    self.cache.items = {}
    for categoryIndex, bitSet in pairs(self.data.items) do
        for itemId, _ in LibBitSetIterator(bitSet, 1) do
            local itemData = self.owner.categories[categoryIndex].getData(self:GetItem(itemId))
            self.cache.items[itemId] = itemData
        end
    end
end

function class:scanItems()
    if self.data.version == self.meta.version and self.data.lang == self.meta.lang then
        return
    end

    self.data.items = {}
    for categoryIndex, _ in ipairs(self.owner.categories) do
        self.data.items[categoryIndex] = LibBitSet:New()
    end

    self.owner:Error("Start of scan")

    local notValidCounter = 0
    local notValidThreshold = 10000

    local itemId = 1
    while notValidCounter < notValidThreshold do
        if itemId % 50000 == 0 then
            self.owner:Log(string.format("Scanning [%06d/%06d]", itemId, itemId + notValidThreshold - notValidCounter))
        end

        local itemLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
        local itemName = GetItemLinkName(itemLink) or ""
        if itemName == "" then
            notValidCounter = notValidCounter + 1
        else
            notValidCounter = 0

            local itemData = self:GetItem(itemId)
            for categoryIndex, categoryData in ipairs(self.owner.categories) do
                if categoryData.filter(itemData) then
                    self.data.items[categoryIndex]:SetBit(itemId)
                end
            end
        end

        itemId = itemId + 1
    end

    self.owner:Success("End of scan")

    self.data.version = self.meta.version
    self.data.lang = self.meta.lang
end

function class:scanCharacter()
    self.data.characters[self.meta.currentCharacterId] = LibBitSet:New()

    for categoryIndex, bitSet in pairs(self.data.items) do
        for itemId, _ in LibBitSetIterator(bitSet, 1) do
            local itemData = self:GetItemData(itemId)
            if self.owner.categories[categoryIndex].isKnown(itemData) then
                self.data.characters[self.meta.currentCharacterId]:SetBit(itemId)
            else
                self.data.characters[self.meta.currentCharacterId]:ClearBit(itemId)
            end

            if self.owner.categories[categoryIndex].accountWide then
                for characterId, _ in pairs(self.data.characters) do
                    if self.data.characters[self.meta.currentCharacterId]:GetBit(itemData.id) == 1 then
                        self.data.characters[characterId]:SetBit(itemId)
                    else
                        self.data.characters[characterId]:ClearBit(itemId)
                    end
                end
            end
        end
    end
end

function class:gc()
    for characterId, _ in pairs(self.data.characters) do
        if not LibCharacter:Exists(characterId) then
            self.data.characters[characterId] = nil
        end
    end
end

function class:AddOnEndOfScanCallback(callback)
    if type(callback) ~= "function" then
        error("not valid OnEndOfScan Callback")
        return
    end
    table.insert(self.onEndOfScanCallbacks, callback)
end

function class:GetItem(id)
    local itemLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", id)
    local itemName = GetItemLinkName(itemLink) or ""
    if itemName == "" then
        return nil
    end

    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    return {
        id = id,
        name = zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName),
        itemType = itemType,
        specializedItemType = specializedItemType,
    }
end

function class:IsValid(itemId)
    if self.cache.isValid[itemId] == nil then
        self.cache.isValid[itemId] = false
        for _, bitSet in pairs(self.data.items) do
            if bitSet:GetBit(itemId) == 1 then
                 self.cache.isValid[itemId] = true
                break
            end
        end
    end

    return self.cache.isValid[itemId]
end

function class:IsAccountWide(itemId)
    if self.cache.isAccountWide[itemId] == nil then
        self.cache.isAccountWide[itemId] = false
        for categoryIndex, bitSet in pairs(self.data.items) do
            if bitSet:GetBit(itemId) == 1 then
                self.cache.isAccountWide[itemId] = self.owner.categories[categoryIndex].accountWide
                break
            end
        end
    end

    return self.cache.isAccountWide[itemId]
end

function class:GetKnowledgeType(itemId)
    if self.data.characters[self.meta.currentCharacterId]:GetBit(itemId) == 0 then
        return UI_KNOWLEDGE_TYPE_CURRENT
    end

    local count = 0
    for _, character in ipairs(LibCharacter:GetAccountCharacters(nil, LibCharacter.SORT_NAME)) do
        if self.data.characters[character.id] ~= nil then
            count = count + 1
            if self.data.characters[character.id]:GetBit(itemId) == 1 then
                count = count - 1
            end
        end
    end

    return count > 0 and UI_KNOWLEDGE_TYPE_PARTIAL or UI_KNOWLEDGE_TYPE_ALL
end

function class:GetItemData(itemId)
    return self.cache.items[itemId]
end
