SetMasterGlobal = {}
local This = SetMasterGlobal

This.DataVersion = 3 -- Integer that increments each time we need to update saved data

This.Namespace = This.Namespace  or "SetMaster"

This.Version = "1.0"
This.SaveDataVersion = 1 -- Data version given to ZO's NewAccountWide. DO NOT INCREMENT

This.HouseBankBagRange = This.HouseBankBagRange  or { First = BAG_HOUSE_BANK_ONE, Last = BAG_HOUSE_BANK_TEN }

-- Fonts
This.ArmorWeightFont = This.ArmorWeightFont or "EsoUI/Common/Fonts/ProseAntiquePSMT.otf|14"
This.ArmorWeightFontLarge = This.ArmorWeightFontLarge or "EsoUI/Common/Fonts/ProseAntiquePSMT.otf|18"
This.TraitCountFont = This.TraitCountFont or "EsoUI/Common/Fonts/ProseAntiquePSMT.otf|20"

local LocalizationTable = {}

-- if a string is not available, then use the key as value
local LocalizationMetaTable = {
	__index = function(tbl, key)
		key = tostring(key)
		d("SetMaster Error: Could not find localized string for '" .. key .. '"')
		return key
	end
}

function This.IsTableEmpty(InTable)
	return next(InTable) == nil
end

function This.TableContains(Array, Value)
	for _, TableValue in pairs(Array) do
		if Value == TableValue then
			return true
		end
	end
	return false
end

function This.ArrayFind(Array, Value)
	for i, ValueItr in ipairs(Array) do
		if ValueItr == Value then
			return i
		end
	end
	
	return 0
end

-- https://stackoverflow.com/questions/6075262/lua-table-tostringtablename-and-table-fromstringstringtable-functions
function This.TableToString(val, name, skipnewlines, depth)
	skipnewlines = skipnewlines or false
	depth = depth or 0

	local tmp = string.rep(" ", depth)

	if name then 
		tmp = tmp .. name .. " = "
	end

	if type(val) == "table" then
		tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

		for k, v in pairs(val) do
			tmp =  tmp .. This.TableToString(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
		end

		tmp = tmp .. string.rep(" ", depth) .. "}"
	elseif type(val) == "number" then
		tmp = tmp .. tostring(val)
	elseif type(val) == "string" then
		tmp = tmp .. string.format("%q", val)
	elseif type(val) == "boolean" then
		tmp = tmp .. (val and "true" or "false")
	else
		tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
	end

	return tmp
end

function This.AddOrGetTableElement(Table, Key, Value)
	local ExistingValue = Table[Key]
	if ExistingValue ~= nil then
		return ExistingValue
	end
	
	Table[Key] = Value
	return Value
end

function This.SetLocalizationTable(Localization)
	setmetatable(Localization, LocalizationMetaTable)
	LocalizationTable = Localization
end

function This.ToStringSafe(InString)
	if InString == nil then
		return "nil"
	end
	
	return InString
end

function This.BoolToString(InBool)
	if InBool then
		return "true"
	end
	
	return "false"
end

local function StringSplit (InString, Seperator)
        if Seperator == nil then
                Seperator = "/?"
        end
		
        local Ret = {}
        for StrItr in string.gmatch(InString, "([^" .. Seperator .. "]+)") do
                table.insert(Ret, StrItr)
        end
		
        return Ret
end

-- Localize a string that usues "/?" as a seperator between keys. Helpful so XML elements can just use their text as a loc key.
function This.LocalizeString(InString)
	local SplitResult = StringSplit(InString)
	return This.Localize(unpack(SplitResult))
end

function This.Localize(...)
	local ArgPack = {...}
	local LocalizationItr = LocalizationTable
	for _, ArgValue in ipairs(ArgPack) do
		LocalizationItr = LocalizationItr[ArgValue]
	end
	
	if type(LocalizationItr) ~= 'string' then
		d("SetMaster Error: Invalid localization key '" .. This.TableToString(ArgPack) .. "'")
		d("     Type was: " .. type(LocalizationItr))
		
		return "<Localization Error>"
	end
	
	return LocalizationItr
end
-- Taken from IIfA
local function GetEquippedItemLink(MouseOverControl)
	local FullSlotName = MouseOverControl:GetName()
	local SlotName = string.gsub(FullSlotName, "ZO_CharacterEquipmentSlots", "")
	local index = 0

	if
				SlotName == "Head"			then index = 0
		elseif	SlotName == "Neck" 			then index = 1
		elseif	SlotName == "Chest" 		then index = 2
		elseif	SlotName == "Shoulder" 		then index = 3
		elseif	SlotName == "MainHand" 		then index = 4
		elseif	SlotName == "OffHand" 		then index = 5
		elseif	SlotName == "Belt" 			then index = 6
		elseif	SlotName == "Costume" 		then index = 7
		elseif	SlotName == "Leg" 			then index = 8
		elseif	SlotName == "Foot" 			then index = 9
		elseif	SlotName == "Ring1" 		then index = 11
		elseif	SlotName == "Ring2" 		then index = 12
		elseif	SlotName == "Glove" 		then index = 16
		elseif	SlotName == "BackupMain" 	then index = 20
		elseif	SlotName == "BackupOff" 	then index = 21
		elseif	SlotName == "Poison" 		then index = 13
		elseif	SlotName == "BackupPoison"	then index = 14
	end

	local ItemLink = GetItemLink(0, index, LINK_STYLE_BRACKETS)
	return ItemLink
end

-- Mostly based on code from IIfA
-- @return ItemLink, bEquipped
-- bEquipped: Is the item currently worn by the player?
function This.GetMouseOverItemLink()
	local MouseOverControl = moc()
	if not MouseOverControl then
		return nil, false
	end

	local ControlName = nil
	if MouseOverControl:GetParent() then
		ControlName = MouseOverControl:GetParent():GetName()
	else
		ControlName = MouseOverControl:GetName()
	end

	if	--ControlName == 'ZO_CraftBagListContents' or
		ControlName == 'ZO_EnchantingTopLevelInventoryBackpackContents' or
		ControlName == 'ZO_GuildBankBackpackContents' or
		ControlName == 'ZO_PlayerBankBackpackContents' or
		ControlName == 'ZO_PlayerInventoryListContents' or
		--ControlName == 'ZO_QuickSlotListContents' or
		ControlName == 'ZO_SmithingTopLevelDeconstructionPanelInventoryBackpackContents' or
		ControlName == 'ZO_SmithingTopLevelImprovementPanelInventoryBackpackContents' or
		ControlName == 'ZO_SmithingTopLevelRefinementPanelInventoryBackpackContents' or
		ControlName == 'ZO_HouseBankBackpackContents' or
		ControlName == 'ZO_PlayerInventoryBackpackContents' then
		if not MouseOverControl.dataEntry then
			return nil, false
		end
		local MouseOverData = MouseOverControl.dataEntry.data
		return GetItemLink(MouseOverData.bagId, MouseOverData.slotIndex, LINK_STYLE_BRACKETS), false

	elseif ControlName == "ZO_LootAlphaContainerListContents" then						-- is loot item
		if not MouseOverControl.dataEntry then
			return nil, false
		end
		local MouseOverData = MouseOverControl.dataEntry.data
		return GetLootItemLink(MouseOverData.lootId, LINK_STYLE_BRACKETS), false

	elseif ControlName == "ZO_InteractWindowRewardArea" then							-- is reward item
		return GetQuestRewardItemLink(MouseOverControl.index, LINK_STYLE_BRACKETS), false

	elseif ControlName == "ZO_Character" then											-- is worn item
		return GetEquippedItemLink(MouseOverControl), true

	elseif ControlName == "ZO_StoreWindowListContents" then							-- is store item
		return GetStoreItemLink(MouseOverControl.index, LINK_STYLE_BRACKETS), false

	elseif ControlName == "ZO_BuyBackListContents" then								-- is buyback item
		return GetBuybackItemLink(MouseOverControl.index, LINK_STYLE_BRACKETS), false

	-- following 4 if's derived directly from MasterMerchant
	elseif string.sub(ControlName, 1, 14) == "MasterMerchant" then
		local MocGp = MouseOverControl:GetParent():GetParent()
		if MocGp then
			local GpControlName = MocGp:GetName()
			if	GpControlName == 'MasterMerchantWindowListContents' or
				GpControlName == 'MasterMerchantWindowList' or
				GpControlName == 'MasterMerchantGuildWindowListContents' then
				if MouseOverControl.GetText then
					return MouseOverControl:GetText(), false
				end
			end
		end
	elseif ControlName == 'ZO_LootAlphaContainerListContents' then
		return GetLootItemLink(MouseOverControl.dataEntry.data.lootId), false
	elseif ControlName == 'ZO_MailInboxMessageAttachments' then
		return GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), MouseOverControl.id, LINK_STYLE_DEFAULT), false
	elseif ControlName == 'ZO_MailSendAttachments' then
		return GetMailQueuedAttachmentLink(MouseOverControl.id, LINK_STYLE_DEFAULT), false

	elseif ControlName == "ZO_MailInboxMessageAttachments" then
		return nil, false

	elseif ControlName:sub(1, 44) == "ZO_TradingHouseItemPaneSearchResultsContents" or
		ControlName:sub(1, 48) == "ZO_TradingHouseBrowseItemsRightPaneSearchResults" then
		local MouseOverData = MouseOverControl.dataEntry
		if MouseOverData then
			MouseOverData = MouseOverData.data
		end
		-- The only thing with 0 time remaining should be guild tabards, no
		-- stats on those!
		if not MouseOverData or MouseOverData.timeRemaining == 0 then
			return nil, false
		end
		return MouseOverData.itemLink, false

	elseif ControlName == "ZO_TradingHousePostedItemsListContents" then
		return GetTradingHouseListingItemLink(MouseOverControl.dataEntry.data.slotIndex), false
		
  	elseif ControlName == 'ZO_TradingHouseLeftPanePostItemFormInfo' then
		if MouseOverControl.slotIndex and MouseOverControl.bagId then
			return GetItemLink(MouseOverControl.bagId, MouseOverControl.slotIndex), false
		end
		
	elseif ControlName == 'DolgubonSetCrafterWindowMaterialListListContents' then
		return MouseOverControl.data[1].ControlName, false
	end
	
	--d("No item link found for mouse-over control: " .. ControlName)
	
	return nil, false
end

function This.IsAnyElementVisible(ElementList)
	for _, Element in ipairs(ElementList) do
		if Element:IsHidden() == false then
			return true
		end
	end
	
	return false
end

function This.IsBagHouseBank(BagId)
	return BagId >= This.HouseBankBagRange.First and BagId <= This.HouseBankBagRange.Last
end

function This.GetAccountOwnerName()
	return This.Localize("OwnerName", "Account")
end

function This.GetHouseOwnerName()
	return This.Localize("OwnerName", "House")
end

function This.GetDateDisplayString()
	return os.date("%x")
end

function This.Range(From, To, Step)
  Step = Step or 1
  return function(_, Lastvalue)
    local NextValue = Lastvalue + Step
    if Step > 0 
		and NextValue <= To 
		or Step < 0 
		and NextValue >= To 
		or Step == 0
    then
      return NextValue
    end
  end, nil, From - Step
end