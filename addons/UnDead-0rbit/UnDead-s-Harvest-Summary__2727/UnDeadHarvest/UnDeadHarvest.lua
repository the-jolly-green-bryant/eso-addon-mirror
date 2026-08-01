UnDeadHarvest = {}
UnDeadHarvest.MailTopic = ""
UnDeadHarvest.MailBody = ""
UnDeadHarvest.ChosenCategory = ""
UnDeadHarvest.ChosenName = ""
UnDeadHarvest.ChosenColor = ""
UnDeadHarvest.ChosenItemId = ""

local function Set_Activated()
	UHS_Data.Active = {}
	for k, v in pairs(UHS_Data.Saved.Items) do
		if UHS_Data.Saved.Items[k][ITEM_ACTIVE] then
			UHS_Data.Active[k] = v
		end
	end
end

local function Create_Container(slotNum, PreviousSlotNum)
	local TLW = GetControl("UnDeadHarvestUI")
	local Name = "UHS_Container_" .. slotNum
	local Parent = PreviousSlotNum and GetControl("UHS_Container_" .. PreviousSlotNum) or GetControl("UHS_Title_Label")
	return UHS_Builder.BuildContainer(Name, TLW, Parent, 260, 25, ANCHOR_TOP_LEFT, ANCHOR_BOTTOM_LEFT), Name
end

local function Format_Gain(k)
	local Text = ""
	local ImportedGain = UHS_Data.Saved.Items[k][ITEM_GAIN]
	if ImportedGain > 0 then Text = "|c66FF00" .. ImportedGain .. "|r" end
	if ImportedGain == 0 then Text = "|c848482" .. ImportedGain .. "|r" end
	if ImportedGain < 0 then Text = "|cc32148" .. ImportedGain .. "|r" end
	return Text
end


-- Go Back Once All Works and swap to v
-- To Clear cycle list of all keys
function UnDeadHarvest.CreateUI()
	Set_Activated()
	-- Get a stable, sorted list of active item keys
	local keys = {}
	for k in pairs(UHS_Data.Active) do table.insert(keys, k) end
	table.sort(keys)

	-- Count how many slots already exist
	local slotNum = 1
	local prevSlot = nil
	for i, k in ipairs(keys) do
		local containerName = "UHS_Container_" .. slotNum
		local container = GetControl(containerName)
		if not container then
			container, _ = Create_Container(slotNum, slotNum > 1 and (slotNum-1) or nil)
		end
		container:SetHidden(false)
		-- Update or create labels for this slot
		local gainName = "UHS_Gain_" .. slotNum
		local nameName = "UHS_Name_" .. slotNum
		local amountName = "UHS_Amount_" .. slotNum

		local gainLbl = GetControl(gainName) or UHS_Builder.BuildDataLabel(gainName, "", COLOR_WHITE, container, 60, 25, ANCHOR_LEFT)
		local nameLbl = GetControl(nameName) or UHS_Builder.BuildDataLabel(nameName, "", COLOR_WHITE, container, 140, 25, ANCHOR_CENTER)
		local amountLbl = GetControl(amountName) or UHS_Builder.BuildDataLabel(amountName, "", COLOR_WHITE, container, 60, 25, ANCHOR_RIGHT)

		gainLbl:SetText(Format_Gain(k))
		nameLbl:SetText(UHS_Data.Saved.Items[k][ITEM_NAME])
		local amt = UnDeadHarvest.GetTotal(UHS_Data.Saved.Items[k][ITEM_CODE])
		amountLbl:SetText(tostring(amt))
		if amountLbl.SetHorizontalAlignment then amountLbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) end

		slotNum = slotNum + 1
		prevSlot = slotNum - 1
	end

	-- Hide any extra slots
	while true do
		local container = GetControl("UHS_Container_" .. slotNum)
		if not container then break end
		container:SetHidden(true)
		local gainLbl = GetControl("UHS_Gain_" .. slotNum)
		if gainLbl then gainLbl:SetText("") end
		local nameLbl = GetControl("UHS_Name_" .. slotNum)
		if nameLbl then nameLbl:SetText("") end
		local amountLbl = GetControl("UHS_Amount_" .. slotNum)
		if amountLbl then amountLbl:SetText("") end
		slotNum = slotNum + 1
	end
end

--if UnDeadHarvest.SavedVariables[AI[i]][ITEM_CODE] == "Gold" then text = string.format("$%s", text) end
local function Set_Gain_Lbl(slotNum, k)
	local lbl = GetControl("UHS_Gain_" .. slotNum)
	if lbl then
		lbl:SetText(Format_Gain(k))
	end
end

function UnDeadHarvest.ClearGain()
	-- Get a stable, sorted list of active item keys
	local keys = {}
	for k in pairs(UHS_Data.Active) do table.insert(keys, k) end
	table.sort(keys)
	for slotNum, k in ipairs(keys) do
		UHS_Data.Saved.Items[k][ITEM_GAIN] = 0
		Set_Gain_Lbl(slotNum, k)
	end
end

function UnDeadHarvest.UpdateGain(itemId, quantity)
	if quantity > 0 then
		for k,v in pairs(UHS_Data.Active) do
			if itemId == UHS_Data.Saved.Items[k][ITEM_CODE] then
				UHS_Data.Saved.Items[k][ITEM_GAIN] = UHS_Data.Saved.Items[k][ITEM_GAIN] + quantity
				Set_Gain_Lbl(k)
			end
		end
	end
end

function UnDeadHarvest.RefreshLabels()
	-- Get a stable, sorted list of active item keys
	local keys = {}
	for k in pairs(UHS_Data.Active) do table.insert(keys, k) end
	table.sort(keys)

	local slotNum = 1
	for _, k in ipairs(keys) do
		local container = GetControl("UHS_Container_" .. slotNum)
		if container then container:SetHidden(false) end
		Set_Gain_Lbl(slotNum, k)
		local lblName = GetControl("UHS_Name_" .. slotNum)
		if lblName then lblName:SetText(UHS_Data.Saved.Items[k][ITEM_NAME]) end
		local lblAmount = GetControl("UHS_Amount_" .. slotNum)
		if lblAmount then
			local text = tostring(UnDeadHarvest.GetTotal(UHS_Data.Saved.Items[k][ITEM_CODE]))
			lblAmount:SetText(text)
		end
		slotNum = slotNum + 1
	end

	-- Hide any extra slots
	while true do
		local container = GetControl("UHS_Container_" .. slotNum)
		if not container then break end
		container:SetHidden(true)
		local gainLbl = GetControl("UHS_Gain_" .. slotNum)
		if gainLbl then gainLbl:SetText("") end
		local nameLbl = GetControl("UHS_Name_" .. slotNum)
		if nameLbl then nameLbl:SetText("") end
		local amountLbl = GetControl("UHS_Amount_" .. slotNum)
		if amountLbl then amountLbl:SetText("") end
		slotNum = slotNum + 1
	end
end

function UnDeadHarvest.GetTotal(code)
	if code == "Fish" then
		local bagSize = GetNumBagUsedSlots(BAG_BACKPACK)
		local fishTotal = 0
		for s = 1, bagSize do
			local _, qntS = GetItemInfo(BAG_BACKPACK, s)
			local itemTypeS = GetItemType(BAG_BACKPACK, s)
			if itemTypeS == 54 then
				fishTotal = fishTotal + qntS
			end
		end
		return fishTotal

	elseif code == "Gold" then
		local total = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
		return total

	elseif code == "AP" then
		local total = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER)
		return total

	elseif code == "TelVar" then
		local total = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)
		return total

	else
		local total = 0
		local _, qnt = GetItemInfo(BAG_VIRTUAL, code)
		local _, qnt2 = GetItemInfo(BAG_BACKPACK, code)
		if HasCraftBagAccess() then total = qnt + qnt2 else total = 0 + qnt2 end
		return total
	end
end

function UnDeadHarvest.GetFish(quantity)
	UHS_Data.Saved.Items.Fish[ITEM_GAIN] = UHS_Data.Saved.Items.Fish[ITEM_GAIN] + quantity
end

--Initialize the addon
function UnDeadHarvest:Initialize()
	UHS_Data.Saved = ZO_SavedVars:New("UnDeadHarvestItems", 1, nil, UHS_Data.Defaults)
	if UHS_Data.Saved.HasImported == false then
		UHS_Data.AddOldItems()
	end

	UnDeadUI.CreateUI()
	UnDeadHarvest.CreateUI()
	UHS_Settings.CreateSettings()
	UnDeadHarvest.ClearGain()
end

function UnDeadHarvest:ResetGain(option)
	d("Resetting Harvest Gain")
	UnDeadHarvest.ClearGain()
end

SLASH_COMMANDS["/uhsreset"] = UnDeadHarvest.ResetGain

function UnDeadHarvest:DisableAll(option)
	d("Disabling All Harvest Items.")
	for k,v in pairs(UHS_Data.Saved.Items) do
		UHS_Data.Saved.Items[k][ITEM_ACTIVE] = false
	end
	UnDeadHarvest.RefreshLabels()
end

SLASH_COMMANDS["/uhsdisableall"] = UnDeadHarvest.DisableAll

--[[
	presets
	fasttravel
	set goals = finish
	use recent items to select to add to list
]]
