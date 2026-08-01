Farmer = ZO_Object:Subclass()
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

local function rPrint(s, l, i) -- recursive Print (structure, limit, indent)
	l = (l) or 100; i = i or "";	-- default item limit, indent string
	if (l<1) then print "ERROR: Item limit reached."; return l-1 end;
	local ts = type(s);
	if (ts ~= "table") then print (i,ts,s); return l-1 end
	d(i,ts);           -- print "table"
	for k,v in pairs(s) do  -- print "[KEY] VALUE"
		l = rPrint(v, l, i.."\t["..tostring(k).."]");
		if (l < 0) then break end
	end
	return l
end

function Farmer:New(memberName)
    local farmer = ZO_Object.New(self)
    farmer:Init(memberName)
    return farmer
end

function Farmer:Init(memberName)
    self.name = memberName
    self.displayName = GetDisplayName(memberName)
    self.itemsFarmed = ItemList:New()
    self.itemsDeposited = ItemList:New()
    self.timeStarted = GetTimeStamp()
    self.totalValueFarmed = 0
    self.totalValueDeposited = 0
    self.events = {}
    self.bag = BAG_DELETE
end

function Farmer:Farm(itemLink, quantity)
    local item = self.itemsFarmed:Add(itemLink, quantity)
    self.totalValueFarmed = self.totalValueFarmed + (item.value * quantity)
    fm.window:OnItemFarmed(item, ACTION_FARM)
end

function Farmer:ItemFilter(itemData)
    local item = self.itemsFarmed.items[itemData.slotIndex]
    return item ~= nil
end

function Farmer:MoveItemsToBackpack()
    local srcBag = BAG_VIRTUAL
    local manager = InventoryManager:New()
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

function Farmer:DepositItemsInBank()
    if self.bagId == BAG_DELETE then
        d("Must be at a bank to deposit")
        return
    end

    local srcBag = BAG_BACKPACK
    local manager = InventoryManager:New()
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

function Farmer:Deposit(itemLink, quantity)
    local item = self.itemsDeposited:Add(itemLink, quantity)
    self.totalValueDeposited = self.totalValueDeposited + (item.value * quantity)
    fm.window:OnItemFarmed(item, ACTION_DEPOSIT)
end

function Farmer:GetGoldPerSecond()
    if self.itemsFarmed.totalValue == 0 then return 0 end
    return self.itemsFarmed.totalValue / (GetTimeStamp() - self.timeStarted)
end

function Farmer:Reset()
    self:Init(self.name)
end
