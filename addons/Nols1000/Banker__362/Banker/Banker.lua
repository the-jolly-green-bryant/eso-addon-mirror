SI = Banker.SI

Banker.newItem = function(iBagId, iSlotId, iType, iName, iLink, iIcon)
	local item ={
		bagId    = iBagId,
		slotId   = iSlotId,
		itemType = iType,
		name     = iName,
		link     = iLink,
		icon     = iIcon,
	}

	return item
end

Banker.initVars = function()
	PACKAGE = "com.github.Nols1000.banker"
	VERSION = 8

	defaults = {}
	defaults.lang = 1
	defaults.iTypes = {}

	for i = 0, #Banker.ItemTypes - 1, 1 do
		defaults.iTypes[Banker.ItemTypes[i]] = true
	end

	defaults.items   = true
	defaults.money   = true
	defaults.debug   = false
	defaults.msg     = true
	defaults.keymenu = true

	defaults.mStep  = 50
	defaults.mMin   = 500

	defaults.updated = false

	Banker.isBankOpen = false
end

Banker.initUI = function()
	local SI = Banker.SI
	local s = Banker.Settings
	
	Banker.KeybindStripDescriptor =
	{
		{
			name = SI.get(SI.KB_SYNC_ITEMS),
			keybind = "SYNC_INVENTORY",
			callback = function() Banker.stackItems() end,
			visible = function() return Banker.isBankOpen end,
		},
		{
			name = SI.get(SI.KB_SAFE_MONEY),
			keybind = "AUTO_DEPOSIT_MONEY",
			callback = function() Banker.safeMoney() end,
			visible = function() return Banker.isBankOpen end,
		},
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
	}
	
	s.init()
	
	s.add({
		type = "header",
		name = SI.get(SI.COMMON_TITLE),
	});
		
	s.add({
		type  = "description",
		text  = SI.get(SI.COMMON_DESC),
	})
	
	s.add({
		type = "checkbox",
		name = SI.get(SI.EITEMS_TITLE),
		tooltip = "",
		getFunc = function()
			return Banker.vars.items
		end,
		setFunc = function(bool)
			Banker.vars.items = bool
		end,
		default = function()
			return defaults.items
		end
	})
	
	s.add({
		type = "checkbox",
		name = SI.get(SI.MSG_TITLE),
		tooltip = "",
		getFunc = function()
			return Banker.vars.msg
		end,
		setFunc = function(bool)
			Banker.vars.msg = bool
		end,
		default = function()
			return defaults.msg
		end
	})
	
	s.add({
		type = "checkbox",
		name = SI.get(SI.DEBUG_TITLE),
		tooltip = "",
		getFunc = function()
			return Banker.vars.debug
		end,
		setFunc = function(bool)
			Banker.vars.debug = bool
		end,
		default = function()
			return defaults.debug
		end
	})
	
	s.add({
		type = "checkbox",
		name = SI.get(SI.KB_TITLE),
		tooltip = "",
		getFunc = function()
			return Banker.vars.keymenu
		end,
		setFunc = function(bool)
			Banker.vars.keymenu = bool
		end,
		default = function()
			return defaults.keymenu
		end
	})
	
	s.add({
		type = "slider",
		name = SI.get(SI.STEP_TITLE),
		max  = 1000,
		min  = 5,
		getFunc =  function()
			return Banker.vars.mStep
		end,
		setFunc = function(arg0)
			Banker.vars.mStep = arg0
		end,
		default = function()
			return defaults.mStep
		end,
	})
	
	s.add({
		type = "slider",
		name = SI.get(SI.MIN_TITLE),
		max  = 10000,
		min  = 500,
		getFunc =  function()
			return Banker.vars.mMin
		end,
		setFunc = function(arg0)
			Banker.vars.mMin = arg0
		end,
		default = function()
			return defaults.mMin
		end,
	})
	
	s.add({
		type = "header",
		name = SI.get(SI.ITEMTYPE_TITLE),
	});
	
	s.add({
		type  = "description",
		text  = SI.get(SI.ITEMTYPE_DESC),
	})
	
	for i = 0, #Banker.ItemTypes, 1 do
		
		s.add({
			type = "checkbox",
			name = GetString("SI_ITEMTYPE", Banker.ItemTypes[i]),
			tooltip = "",
			getFunc = function()
				return Banker.vars.iTypes[Banker.ItemTypes[i]]
			end,
			setFunc = function(bool)
				Banker.vars.iTypes[Banker.ItemTypes[i]] = bool
			end,
			default = function()
				return defaults.iTypes[Banker.ItemTypes[i]]
			end
		})
	end
end

Banker.onLoaded = function(event, name)
	if name ~= "Banker" then return end
	
	Banker.initVars()
	Banker.vars = ZO_SavedVars:New("BankerVariables", VERSION, nil, defaults)
	Banker.vars.lang = GetCVar("language.2") or "en"

	if Banker.vars.lang ~= "en" or Banker.vars.lang ~= "de" or Banker.vars.lang ~= "fr" then
		Banker.mDebug(string.format("%s is not supported. Banker will use standard language (en).", Banker.vars.lang))
	end

	Banker.initUI()
end

Banker.onOpenBank = function()
	Banker.toggleSyncBinding()

	if Banker.vars.items then
		Banker.stackItems()
	end

	if Banker.vars.money then
		Banker.safeMoney()
	end
end

Banker.onCloseBank = function()
	Banker.toggleSyncBinding()
end

Banker.stackItems = function()
	local bankItems = Banker.getItems(BAG_BANK)
	local backpackItems = Banker.getItems(BAG_BACKPACK)

	for i = 0, #backpackItems-1, 1 do
		for k = 0, #bankItems-1, 1 do
			if backpackItems[i].name == bankItems[k].name then
				if Banker.vars.iTypes[backpackItems[i].itemType] then
					Banker.transferItem(BAG_BACKPACK, BAG_BANK, i, k)
				end
			end
		end
	end
end

Banker.safeMoney = function()
	local bankMoney = GetBankedMoney()
	local playerMoney = GetCurrentMoney()

	if playerMoney > Banker.vars.mMin then
		local n = math.floor( (playerMoney - Banker.vars.mMin) / Banker.vars.mStep )

		if n > 0 then
			local tMoney = n * Banker.vars.mStep

			DepositMoneyIntoBank(tMoney)
			Banker.msg(string.format("%s |t16:16:EsoUI/Art/currency/currency_gold.dds|t were transferd to your bank.", tMoney))
		end
	end
end

Banker.getItems = function(bagId)
	local items = {}
	local numBagSlots = GetBagSize(bagId)

	for i = 0, numBagSlots, 1 do
		icon, _, _, _, _, _ = GetItemInfo(bagId, i)
		itemType = GetItemType(bagId, i)
		name = GetItemName(bagId, i)
		link = GetItemLink(bagId, i, LINK_STYLE_BRACKETS) -- LINK_STYLE_DEFAULT
		
		Banker.test = {
			bagId = bagId,
			index = i,
			itemT = itemType,
			name = name,
			link = link,
			icon = icon
		}
		items[i] = Banker.newItem(bagId, i, itemType, name, link, icon)
	end

	return items
end

Banker.transferItem = function(fromBag, toBag, fromSlot, toSlot)

	local fStackSize = GetSlotStackSize(fromBag, fromSlot)
	local fName      = GetItemLink(fromBag, fromSlot)
	local tStackSize = GetSlotStackSize(toBag, toSlot)
	
	local stack      = (fStackSize + tStackSize) - 200

	if stack <= 0 and fStackSize ~= 0 then
		if Banker.Lib.stackItem(fromBag, fromSlot, toBag, toSlot, fStackSize, fName) then
			local texture = GetItemInfo(fromBag, fromSlot)
			Banker.msg(string.format("%s x [%s] was added to bank.", fStackSize, fName))
		else
			Banker.msg(string.format("[%s] wasn't added to bank.", fName))
		end
	elseif fStackSize ~= 0 then
		fStackSize = fStackSize - stack
		if fStackSize > 0 then
			if Banker.Lib.stackItem(fromBag, fromSlot, toBag, toSlot, fStackSize, fName) then
				local texture = GetItemInfo(fromBag, fromSlot)
				Banker.msg(string.format("%s x [%s] was added to bank.", fStackSize, fName))
			else
				Banker.msg(string.format("[%s] wasn't added to bank.", fName))
			end
		end
	end
end

Banker.toggleSyncBinding = function()
	Banker.isBankOpen = not Banker.isBankOpen
	
	if Banker.isBankOpen then
		Banker.mDebug("Banker.isBankOpen: true")
	else
		Banker.mDebug("Banker.isBankOpen: false");
	end
	
	if Banker.vars.keymenu then
		if Banker.isBankOpen then
			Banker.mDebug("show")
			KEYBIND_STRIP:AddKeybindButtonGroup(Banker.KeybindStripDescriptor)
			KEYBIND_STRIP:UpdateKeybindButtonGroup(Banker.KeybindStripDescriptor)
		else
			Banker.mDebug("hide")
			KEYBIND_STRIP:RemoveKeybindButtonGroup(Banker.KeybindStripDescriptor)
		end
	end
end

Banker.mDebug = function(arg0)
	if Banker.vars.debug then
		CHAT_SYSTEM:AddMessage("[BANKER] " .. arg0)
	end
end

Banker.msg = function(arg0)
	if Banker.vars.msg then
		CHAT_SYSTEM:AddMessage(arg0)
	end
end

EVENT_MANAGER:RegisterForEvent("BankerOnBankOpen", EVENT_OPEN_BANK, Banker.onOpenBank)
EVENT_MANAGER:RegisterForEvent("BankerOnBankClose", EVENT_CLOSE_BANK, Banker.onCloseBank)
EVENT_MANAGER:RegisterForEvent("BankerOnLoad", EVENT_ADD_ON_LOADED, Banker.onLoaded)

Banker.Lib = {}

Banker.Lib.stackItem = function(fromBag, fromSlot, toBag, toSlot, quantity, name)
    Banker.mDebug("stacking")
    local result = true
    -- just in case
    ClearCursor()
    -- must call secure protected (pickup the item via cursor)
    result = CallSecureProtected("PickupInventoryItem", fromBag, fromSlot, quantity)
    Banker.mDebug("called secure protected")
    if (result) then
        -- must call secure protected (drop the item on the cursor)
		Banker.mDebug("called secure protected2")
        result = CallSecureProtected("PlaceInInventory", toBag, toSlot)
    end
    -- clear the cursor to avoid issues
    ClearCursor()
    return result
end