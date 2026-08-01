local classes = LWTLootTracker.classes
local window = LWTLootTrackerWindow
local guiButton = LWTLootTrackerGuiButton
local collection = {}
local lastUpdateTime = 0

------------------------------------------------------------
-- UIPrefab (local: thin view-model for scroll list rows)
------------------------------------------------------------
local UIPrefab = ZO_Object:Subclass()

function UIPrefab:New(item)
	local entry = ZO_Object.New(self)
	entry:Init(item)
	return entry
end

function UIPrefab:Init(item)
	self.texture = item.texture
	self.itemLink = item.itemLink
	self.itemId = item.itemId
	self.itemName = item.itemName
	self.amount = item.amount
	self.value = item.value
	self.order = item.order
end

function UIPrefab:Add(item)
	self.amount = item.amount
	self.order = item.order
end

local sortFuncs = {
	["VALUE"] = function(a, b) return a.data.value() * a.data.amount > b.data.value() * b.data.amount end,
	["VALUEINV"] = function(a, b) return a.data.value() * a.data.amount < b.data.value() * b.data.amount end,
	["NAME"] = function(a, b) return a.data.itemName < b.data.itemName end,
	["NAMEINV"] = function(a, b) return a.data.itemName > b.data.itemName end,
	["ORDER"] = function(a, b) return a.data.order > b.data.order end,
	["ORDERINV"] = function(a, b) return a.data.order < b.data.order end
}

local priceTypes = { "Sale Avg", "Listed Avg", "Suggested" }

classes.LWTLootTrackerMainWindow = ZO_Object:Subclass()

local function ToGold(amount)
	return ZO_CurrencyControl_FormatCurrencyAndAppendIcon(amount, false, CURT_MONEY, false)
end

function classes.LWTLootTrackerMainWindow:New(...)
	local object = ZO_Object.New(self)
	object:Init(...)
	return object
end

function classes.LWTLootTrackerMainWindow:Init()
	collection = window:GetNamedChild("DetailPanel"):GetNamedChild("Collection")
	ZO_ScrollList_AddDataType(collection, 1, "LWTLootTrackerItemPrefab", 30,
		function(control, data) self:UpdateDataRow(control, data) end)

	LWTLootTracker.InitPriceProviderSelectable()

	local butPos = LWTLootTracker.settings.current.posButton;
	guiButton:SetAnchor(TOPLEFT, nil, TOPLEFT, butPos[1], butPos[2])
	local winPos = LWTLootTracker.settings.current.posWindow;
	window:SetAnchor(TOPLEFT, nil, TOPLEFT, winPos[1], winPos[2])
end

function classes.LWTLootTrackerMainWindow:Show()
	window:SetHidden(false)
end

function classes.LWTLootTrackerMainWindow:Hide()
	window:SetHidden(true)
end

function classes.LWTLootTrackerMainWindow:UpdateDataRow(control, data)
	if (data ~= nil and control ~= nil) then
		control:GetNamedChild("Icon"):SetTexture(data.texture)
		control:GetNamedChild("NameText"):SetText(zo_strformat('<<t:1>>', data.itemLink))
		control:GetNamedChild("CountsText"):SetText(data.amount)
		control:GetNamedChild("PriceText"):SetText(ToGold(math.floor(data.value() * data.amount)))
	end

	window:GetNamedChild("TotalText"):SetText(ToGold(math.floor(LWTLootTracker.tracker.totalValue() or 0)))
	window:GetNamedChild("GoldPerHourText"):SetText(ToGold(math.floor(LWTLootTracker.tracker:GetGoldPerSecond() * 60 * 60)))
	window:GetNamedChild("GoldPerMinuteText"):SetText(ToGold(math.floor(LWTLootTracker.tracker:GetGoldPerSecond() * 60)))
	window:GetNamedChild("GoldPerSecondText"):SetText(ToGold(math.floor(LWTLootTracker.tracker:GetGoldPerSecond())))

	window:GetNamedChild("ButtonReset"):GetNamedChild("ButtonResetText"):SetText(GetString(LWTLOOTRACKER_UI_BUTTON_RESET))
	if (LWTLootTracker.isTracking) then
		window:GetNamedChild("ButtonToggle"):GetNamedChild("ButtonToggleText"):SetText(GetString(
			LWTLOOTRACKER_UI_BUTTON_STOP))
	else
		window:GetNamedChild("ButtonToggle"):GetNamedChild("ButtonToggleText"):SetText(GetString(
			LWTLOOTRACKER_UI_BUTTON_START))
	end

	window:GetNamedChild("TotalNameText"):SetText(GetString(LWTLOOTRACKER_UI_TOTAL_NAME))
	window:GetNamedChild("GoldPerHourNameText"):SetText(GetString(LWTLOOTRACKER_UI_PER_HOUR_NAME))
	window:GetNamedChild("GoldPerMinuteNameText"):SetText(GetString(LWTLOOTRACKER_UI_PER_MINUTE_NAME))
	window:GetNamedChild("GoldPerSecondNameText"):SetText(GetString(LWTLOOTRACKER_UI_PER_SECOND_NAME))

	if (LWTLootTracker.isTracking) then
		LWTLootTracker.classes.LWTLootTrackerMainWindow:UpdateTimer()
	end
end

function classes.LWTLootTrackerMainWindow:UpdateTimer()
	local curTime = GetTimeStamp()
	local timeRun = curTime - LWTLootTracker.tracker.timeStarted
	if (LWTLootTracker.tracker.lastPause > 0) then
		timeRun = timeRun - (curTime - LWTLootTracker.tracker.lastPause)
	end

	local hours = math.floor(timeRun / 3600)
	local minutes = math.floor((timeRun - (hours * 3600)) / 60)
	local seconds = math.floor(timeRun - (hours * 3600) - (minutes * 60))
	window:GetNamedChild("TimerText"):SetText(string.format("%02d:%02d:%02d", hours, minutes, seconds))
end

function LWTLootTracker.InitPriceProviderSelectable()
	local providerNames = {}
	local haveSelected = false

	for _, name in ipairs(LWTPriceInfo.ProviderNames) do
		if LWTPriceInfo.ProviderAvailable[name] then
			table.insert(providerNames, name)
			if LWTLootTracker.settings.current.priceProvider == name then
				haveSelected = true
			end
		end
	end

	-- Price provider
	local dropdownProvider = window:GetNamedChild("PriceProvider").dropdown

	if (haveSelected) then
		dropdownProvider:SetSelectedItem(LWTLootTracker.settings.current.priceProvider)
	else
		dropdownProvider:SetSelectedItem("NPC")
	end

	local function OnPriceProviderSelect(_, choiceText, _)
		LWTLootTracker.settings.current.priceProvider = choiceText
		LWTLootTracker.classes.LWTLootTrackerMainWindow:OnItemFarmed(nil)
	end

	for i = 1, #providerNames do
		local entry = dropdownProvider:CreateItemEntry(providerNames[i], OnPriceProviderSelect)
		dropdownProvider:AddItem(entry)
	end

	-- Price type
	local dropdownType = window:GetNamedChild("PriceType").dropdown
	dropdownType:SetSelectedItem(LWTLootTracker.settings.current.priceType)

	local function OnPriceTypeSelect(_, choiceText, _)
		LWTLootTracker.settings.current.priceType = choiceText
		LWTLootTracker.classes.LWTLootTrackerMainWindow:OnItemFarmed(nil)
	end

	for i = 1, #priceTypes do
		local entry = dropdownType:CreateItemEntry(priceTypes[i], OnPriceTypeSelect)
		dropdownType:AddItem(entry)
	end
end

function classes.LWTLootTrackerMainWindow:OnItemFarmed(item)
	local scrollData = ZO_ScrollList_GetDataList(collection)
	if (item ~= nil) then
		local found = false
		for _, itemData in pairs(scrollData) do
			if itemData.data.itemId == item.itemId then
				itemData.data:Add(item)
				found = true
				break
			end
		end

		if not found then
			local data = UIPrefab:New(item)
			scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1, data)
		end
	end

	table.sort(scrollData, sortFuncs[LWTLootTracker.settings.current.sortBy])

	ZO_ScrollList_Commit(collection)
end

function classes.LWTLootTrackerMainWindow:Reset()
	ZO_ScrollList_Clear(collection)
	ZO_ScrollList_Commit(collection)

	LWTLootTracker.tracker = LWTLootTracker.Tracker:New()
	classes.LWTLootTrackerMainWindow:UpdateDataRow(nil, nil)
	if (LWTLootTracker.isTracking == false) then
		LWTLootTracker.classes.LWTLootTrackerMainWindow:UpdateTimer()
	end
end

function classes.LWTLootTrackerMainWindow:MoveEndButton()
	LWTLootTracker.settings.current.posButton = { guiButton:GetLeft(), guiButton:GetTop() }
end

function classes.LWTLootTrackerMainWindow:MoveEndWindow()
	LWTLootTracker.settings.current.posWindow = { window:GetLeft(), window:GetTop() }
end

function classes.LWTLootTrackerMainWindow:SetButtonAlpha(alpha)
	guiButton:GetNamedChild("ButtonBG"):SetAlpha(alpha)
end

function classes.LWTLootTrackerMainWindow:OnUpdate()
	local time = GetSecondsSinceMidnight()
	if (lastUpdateTime ~= time and LWTLootTracker.isTracking) then
		lastUpdateTime = time

		classes.LWTLootTrackerMainWindow:UpdateDataRow(nil, nil)
	end
end
