LWTLootTracker = {
	version = "1.0.0",
	name = "LWTLootTracker",
	displayName = "LWT Loot Tracker",
	settings = {},
	window = {},
	tracker = {},
	classes = {},
	isShowing = false,
	isTracking = false,
}

------------------------------------------------------------
-- Item (local: price lookup per itemLink)
------------------------------------------------------------
local Item = ZO_Object:Subclass()

function Item:New(itemLink)
	local item = ZO_Object.New(self)
	item:Init(itemLink)
	return item
end

function Item:Init(itemLink)
	self.texture = GetItemLinkInfo(itemLink)
	self.itemId = GetItemLinkItemId(itemLink)
	self.itemName = GetItemLinkName(itemLink)
	self.itemLink = itemLink
	self.priceProvider = LWTLootTracker.settings.current.priceProvider
	self.priceType = LWTLootTracker.settings.current.priceType
	self.amount = 0
	self.cachedValue = -1
	self.value = function()
		return self:GetPrice()
	end
end

function Item:GetPrice()
	local settings = LWTLootTracker.settings.current
	if (self.cachedValue ~= -1 and self.priceProvider == settings.priceProvider and self.priceType == settings.priceType) then
		return self.cachedValue
	end

	local priceProvider = settings.priceProvider
	local priceType = settings.priceType

	self.priceProvider = priceProvider
	self.priceType = priceType

	local ok, priceData = pcall(LWTPriceInfo.GetPriceData, self.itemLink)

	if (not ok or priceData == nil or priceData[priceProvider] == nil) then
		self.cachedValue = self:GetNPCPrice()
		return self.cachedValue
	end

	local providerData = priceData[priceProvider]
	local price = providerData[priceType]

	if (price == nil or price == 0) then
		self.cachedValue = self:GetNPCPrice()
		return self.cachedValue
	end

	if (priceType == "Suggested") then
		price = price / LWTPriceInfo.SUGGESTED_MARKUP
	end

	self.cachedValue = price
	return self.cachedValue
end

function Item:GetNPCPrice()
	local itemPrice = 0
	if (self.itemLink ~= nil and self.itemLink ~= "") then
		_, itemPrice, _, _, _ = GetItemLinkInfo(self.itemLink)
	end
	return itemPrice
end

------------------------------------------------------------
-- Collection (local: aggregates Items by itemId)
------------------------------------------------------------
local Collection = ZO_Object:Subclass()

function Collection:New()
	local collection = ZO_Object.New(self)
	collection:Init()
	return collection
end

function Collection:Init()
	self.totalItems = 0
	self.items = {}
	self.cachedValue = 0
	self.lastAmount = 0
	self.lastPriceProvider = nil
	self.lastPriceType = nil
	self.totalValue = function()
		local settings = LWTLootTracker.settings.current
		if self.lastAmount ~= self.totalItems or self.lastPriceProvider ~= settings.priceProvider or self.lastPriceType ~= settings.priceType then
			self.lastPriceProvider = settings.priceProvider
			self.lastPriceType = settings.priceType
			self.lastAmount = self.totalItems
			self.cachedValue = 0
			for _, value in pairs(self.items) do
				self.cachedValue = self.cachedValue + value.value() * value.amount
			end
		end

		return self.cachedValue
	end
end

function Collection:Add(itemLink, amount)
	local itemId = GetItemLinkItemId(itemLink)
	if self.items[itemId] == nil then
		self.items[itemId] = Item:New(itemLink)
	end

	local item = self.items[itemId]

	item.amount = item.amount + amount
	self.totalItems = self.totalItems + amount
	item.order = self.totalItems

	return item
end

function Collection:Get(itemLink)
	local itemId = GetItemLinkItemId(itemLink)
	return self.items[itemId]
end

------------------------------------------------------------
-- Tracker (exposed via LWTLootTracker.Tracker for UI)
------------------------------------------------------------
local Tracker = ZO_Object:Subclass()
LWTLootTracker.Tracker = Tracker

function Tracker:New()
	local tracker = ZO_Object.New(self)
	tracker:Init()
	return tracker
end

function Tracker:Init()
	self.itemsFarmed = Collection:New()
	self.timeStarted = GetTimeStamp()
	self.lastPause = GetTimeStamp()
	self.totalValue = function()
		return self.itemsFarmed.totalValue()
	end
end

function Tracker:Farm(itemLink, amount)
	local item = self.itemsFarmed:Add(itemLink, amount)
	LWTLootTracker.window:OnItemFarmed(item)
end

function Tracker:GetGoldPerSecond()
	local total = self.itemsFarmed.totalValue()
	if total == 0 then return 0 end

	local time = GetTimeStamp() - self.timeStarted
	if (self.lastPause > 0) then
		time = time - (GetTimeStamp() - self.lastPause)
	end

	if time <= 0 then return 0 end

	return total / time
end

function Tracker:Reset()
	local wasTracking = LWTLootTracker.isTracking
	self:Init()
	LWTLootTracker.Start(true)
	LWTLootTracker.Stop(true)
	if (wasTracking) then
		LWTLootTracker.Start(true)
	end
end

------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------
function LWTLootTracker.OnAddOnLoaded(_, addonName)
	if addonName ~= LWTLootTracker.name then return end
	EVENT_MANAGER:UnregisterForEvent(LWTLootTracker.name, EVENT_ADD_ON_LOADED)

	LWTLootTracker.InitSettings()
	LWTLootTracker.window = LWTLootTracker.classes.LWTLootTrackerMainWindow:New()
	LWTLootTracker.tracker = Tracker:New()
	LWTLootTracker.Stop()
end

function LWTLootTracker.ToggleVisual()
	if LWTLootTracker.isShowing then
		LWTLootTracker.Hide()
	else
		LWTLootTracker.Show()
	end
end

function LWTLootTracker.Show()
	LWTLootTracker.window:Show()
	LWTLootTracker.classes.LWTLootTrackerMainWindow:UpdateDataRow(nil, nil)
	LWTLootTracker.isShowing = true
end

function LWTLootTracker.Hide()
	LWTLootTracker.window:Hide()
	LWTLootTracker.isShowing = false
end

function LWTLootTracker.ToggleTracking()
	if LWTLootTracker.isTracking then
		LWTLootTracker.Stop()
	else
		LWTLootTracker.Start()
	end
end

function LWTLootTracker.SetSort(type)
	if (type == LWTLootTracker.settings.current.sortBy) then
		if (string.sub(type, -3) == "INV") then
			LWTLootTracker.settings.current.sortBy = string.sub(type, 1, -4)
		else
			LWTLootTracker.settings.current.sortBy = type .. "INV"
		end
	else
		LWTLootTracker.settings.current.sortBy = type
	end
	LWTLootTracker.classes.LWTLootTrackerMainWindow:OnItemFarmed(nil)
end

function LWTLootTracker.Start(silent)
	EVENT_MANAGER:RegisterForEvent(LWTLootTracker.name, EVENT_LOOT_RECEIVED, LWTLootTracker.OnLootReceived)
	LWTLootTracker.isTracking = true
	if (LWTLootTracker.tracker.lastPause > 0) then
		LWTLootTracker.tracker.timeStarted = LWTLootTracker.tracker.timeStarted + (GetTimeStamp() - LWTLootTracker.tracker.lastPause)
		LWTLootTracker.tracker.lastPause = 0
	end
	LWTLootTracker.classes.LWTLootTrackerMainWindow:UpdateDataRow(nil, nil)
	if not silent then
		d(GetString(LWTLOOTRACKER_UI_STARTED))
	end
end

function LWTLootTracker.Stop(silent)
	EVENT_MANAGER:UnregisterForEvent(LWTLootTracker.name, EVENT_LOOT_RECEIVED)
	LWTLootTracker.isTracking = false
	LWTLootTracker.tracker.lastPause = GetTimeStamp()
	LWTLootTracker.classes.LWTLootTrackerMainWindow:UpdateDataRow(nil, nil)
	if not silent then
		d(GetString(LWTLOOTRACKER_UI_STOPPED))
	end
end

function LWTLootTracker.OnLootReceived(_, _, itemLink, amount, _, _, isMe)
	if not isMe then return end
	LWTLootTracker.tracker:Farm(itemLink, amount)
end

function LWTLootTracker.Reset()
	LWTLootTracker.tracker:Reset()
	LWTLootTracker.window:Reset()
end

function LWTLootTracker.InitSettings()
	LWTLootTracker.settings.name = LWTLootTracker.name .. "Settings"
	LWTLootTracker.settings.defaults = {
		priceProvider = "NPC",
		priceType = "Sale Avg",
		sortBy = "ORDER",
		posButton = { 128, 128 },
		posWindow = { 256, 256 }
	}

	LWTLootTracker.settings.current = ZO_SavedVars:NewAccountWide("LWTLootTrackerVars", 2, nil, LWTLootTracker.settings.defaults)
end

EVENT_MANAGER:RegisterForEvent(LWTLootTracker.name, EVENT_ADD_ON_LOADED, LWTLootTracker.OnAddOnLoaded)
