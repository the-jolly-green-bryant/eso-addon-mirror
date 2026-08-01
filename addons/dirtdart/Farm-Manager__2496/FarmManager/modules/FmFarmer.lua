FmFarmer = ZO_Object:Subclass()
local fm = FarmManager

local function GetDisplayName(memberName)
    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        for memberIndex = 1, GetNumGuildMembers(guildId) do
            local hasChar, characterName = GetGuildMemberCharacterInfo(guildId, memberIndex)
            if hasChar then
                characterName = zo_strformat(SI_UNIT_NAME, characterName)
                if characterName == memberName then
                    local account = GetGuildMemberInfo(guildId, memberIndex)
                    return account
                end
            end
        end
    end
end

local function Sleep(s)
    local ntime = os.clock() + s
    repeat until os.clock() > ntime
end

local function GetEmptySlot(bagNumber)
    local sleepCount = 0
    local dest = nil
    while (dest == nil) and (sleepCount < 5) do
        dest = FindFirstEmptySlotInBag(bagNumber)
        if dest == nil then
            Sleep(2)
            sleepCount = sleepCount + 1
        end
    end
    return dest
end

function FmFarmer:New(memberName)
    local farmer = ZO_Object.New(self)
    farmer:Init(memberName)
    return farmer
end

function FmFarmer:Init(memberName)
    self.name = memberName
    self.displayName = GetDisplayName(memberName)
    self.itemsFarmed = FmItemList:New()
    self.itemsDeposited = FmItemList:New()
    self.timeStarted = GetTimeStamp()
    self.totalValueFarmed = 0
    self.totalValueDeposited = 0
    self.events = {}
    self.bag = BAG_DELETE
end

function FmFarmer:Farm(itemLink, quantity)
    local item = self.itemsFarmed:Add(itemLink, quantity)
    self.totalValueFarmed = self.totalValueFarmed + (item.value * quantity)
    fm.window:OnItemFarmed(item, ACTION_FARM)
end

function FmFarmer:ItemFilter(itemData)
    local item = self.itemsFarmed.items[itemData.slotIndex]
    return item ~= nil
end

function FmFarmer:MoveItemsToBackpack()
    local srcBag = BAG_VIRTUAL
    local manager = FmInventoryManager:New()
    local bagCache = SHARED_INVENTORY:GenerateFullSlotData(nil, srcBag)

    for _, data in pairs(bagCache) do
        local itemLink = GetItemLink(srcBag, data.slotIndex)
        local itemId = GetItemLinkItemId(itemLink)
        local item = self.itemsFarmed.items[itemId]
        if item ~= nil then
            manager:AddItemToBackpack(srcBag, data.slotIndex, item.quantity)
        end
    end
end

function FmFarmer:DepositItemsInBank()
    if self.bagId == BAG_DELETE then
        d("Must be at a bank to deposit")
        return
    end

    local srcBag = BAG_BACKPACK
    local manager = FmInventoryManager:New()
    local bagCache = SHARED_INVENTORY:GenerateFullSlotData(nil, srcBag)

    for _, data in pairs(bagCache) do
        local itemLink = GetItemLink(srcBag, data.slotIndex)
        local itemId = GetItemLinkItemId(itemLink)
        local item = self.itemsFarmed.items[itemId]
        if item ~= nil then
            manager:AddItemToBank(self.bagId, srcBag, data.slotIndex, item.quantity)
        end
    end
end

function FmFarmer:Deposit(itemLink, quantity)
    local item = self.itemsDeposited:Add(itemLink, quantity)
    self.totalValueDeposited = self.totalValueDeposited + (item.value * quantity)
    fm.window:OnItemFarmed(item, ACTION_DEPOSIT)
end

function FmFarmer:GetGoldPerSecond()
    if self.itemsFarmed.totalValue == 0 then return 0 end
    return self.itemsFarmed.totalValue / (GetTimeStamp() - self.timeStarted)
end

function FmFarmer:Reset()
    self:Init(self.name)
end
