local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
local LMP = LibStub:GetLibrary("LibMediaProvider-1.0")
local CDGSL = ZO_Object:Subclass()

local Addon =
{
    Name = "CDGShowLoot",
    NameSpaced = "CDG Show Loot",
    Author = "CrazyDutchGuy",
    Version = "4.2",
}

local Player = { 
	isCrafting = false,
	LastLootName = nil,
	LootList = nil
}

local COLOR = {
	GREEN = "00CD00",
	RED= "D00000"
}

local localVars = {
	defaults = {	
		filter = {
			gold = false,
			minGold = 0,	
			self = {
				JUNK = false,
				NORMAL = false,
				FINE = false,
				SUPERIOR = false,
				EPIC = false,
				LEGENDARY = false
			},
			group = {
				JUNK = true,
				NORMAL = true,
				FINE = false,
				SUPERIOR = false,
				EPIC = false,
				LEGENDARY = false
			}
		},
		playerColor = "4C4CFF",
		groupColor = "4C4CFF",
		logToDefaultChat = false,
		chatWindow = nil,
		chatContainerId = nil,
		chatWindowId = nil,
		hidePlayerName = false,		
		showBagStacks = true,
		showGroupLoot = false,
		showBankStacks = false,
	}
}

local LOOTCOLOR = {
	JUNK = "C3C3C3",
	NORMAL = "FFFFFF",
	FINE = "2DC50E",
	SUPERIOR = "3A92FF",
	EPIC = "A02EF7",
	LEGENDARY = "EECA2A"
}

local LOOTQUALITY = {
	JUNK = 0,
	NORMAL = 1,
	FINE = 2,
	SUPERIOR = 3,
	EPIC = 4,
	LEGENDARY = 5,
} 

local savedVars_CDGShowLoot = {}

local List = {}

function List.new()
	return {first = 1, last = 0}
end

function List.push(list, value)	
	list.last = list.last + 1
	list[list.last] = value
end

function List.pop(list)
	if list.first > list.last then 
		return nil 
	end
	local value = list[list.first]
	list[list.first] = nil
	list.first = list.first + 1
	return value
end

function List.peek(list)
	if list.first > list.last then 
		return nil 
	end
	return list[list.first]
end

function List.empty(list)
	if list.first > list.last then
		return true
	else
		return false
	end
end

function List.elements(list)
	return list.last
end

function CDGSL:SetDelayedLootUpdate()
	if not delayedHide then
		delayedHide = true
		zo_callLater(function(...) 
			CDGSL:LootClosed(...) 
			delayedHide = false
		end , 1000)	
	end
end

function CDGSL:LootClosed(...)	
	if List.empty(Player.LootList) then
		return
	end
		--
		-- Sort first the lootlist before we start generating loot messages
		--
		table.sort(Player.LootList, function (a,b) 
				if a.who < b.who then 
					return true
				elseif a.who > b.who then
					return false
				else
					return (a.val < b.val) 
				end
			end ) 
		
		local msg = ""
		--
		-- Start traversing the lootlist as long as there are items : 
		-- * if it is the first item then add the playername
		-- * if it is the same player keep adding to the message
		-- * if it is the same item keep increasing the quantity
		--
		while not List.empty(Player.LootList) do
			local l = List.pop(Player.LootList)
			local l_peek = List.peek(Player.LootList)
			

			if msg == "" then 

				if GetUnitName("player") == l.who then
					if not savedVars_CDGShowLoot.hidePlayerName then
						msg = msg .. zo_strformat("|c<<1>> <<2>>|r ", savedVars_CDGShowLoot.playerColor, l.who ) 					
					end
				else
					msg = msg .. zo_strformat("|c<<1>> <<2>>|r ", savedVars_CDGShowLoot.groupColor, l.who ) 
				end
			end
			
			while not List.empty(Player.LootList) do
			
				l_peek = List.peek(Player.LootList)
				
				if l.who == l_peek.who and l.val == l_peek.val then
					l.qty = l.qty + l_peek.qty
					_ ,_ = List.pop(Player.LootList)
				else
					break				
				end
				
				
			end				
			
			if l.val ~= "gold" or (l.val == "gold" and (l.qty < 0 or l.qty > savedVars_CDGShowLoot.filter.minGold)) then
				if l.qty >= 0 then
					msg = msg .. zo_strformat("|c<<3>> <<2[1/$d]>> |r <<t:1>>", l.val, l.qty, COLOR.GREEN, " "  ) 
				else
					msg = msg .. zo_strformat("|c<<3>> <<2[1/$d]>> |r <<t:1>>", l.val, math.abs(l.qty), COLOR.RED, " "   ) 
				end

				if (savedVars_CDGShowLoot.showBagStacks or savedVars_CDGShowLoot.showBankStacks) and l.val ~= "gold" and GetUnitName("player") == l.who then
					local bagAmount = 0
					local bankAmount = 0

					if savedVars_CDGShowLoot.showBagStacks then						
						for bagSlot = 0, GetBagSize(BAG_BACKPACK) do
							local bagItemLink = GetItemLink(BAG_BACKPACK, bagSlot)							
							if l.val == bagItemLink then
								local bagStack,_ = GetSlotStackSize(BAG_BACKPACK, bagSlot)
								bagAmount = bagAmount + bagStack
							end
						end
					end
	
					if savedVars_CDGShowLoot.showBankStacks then						
						for bankSlot = 0, GetBagSize(BAG_BANK) do 
                					local bankItemLink = GetItemLink(BAG_BANK, bankSlot)                			
		                			if l.val == bankItemLink then 
                						local bankStack, _ = GetSlotStackSize(BAG_BANK, bankSlot)                 			
                	        				bankAmount = bankAmount + bankStack
		                			end
        					end
					end

					if savedVars_CDGShowLoot.showBagStacks and savedVars_CDGShowLoot.showBankStacks then
						msg = msg .. " |cC3C3C3["..bagAmount.."/"..bankAmount.."]|r"
					elseif savedVars_CDGShowLoot.showBagStacks then
						msg = msg .. " |cC3C3C3["..bagAmount.."]|r"
					elseif savedVars_CDGShowLoot.showBankStacks then
						msg = msg .. " |cC3C3C3["..bankAmount.."]|r"
					end
				end

				if not List.empty(Player.LootList) and l.who == l_peek.who then
					msg = msg .. ","
				end
			end
			
			
			
			if msg ~= "" and ((not List.empty(Player.LootList) and l.who ~= l_peek.who) or List.empty(Player.LootList)) then
				CDGSL:sendMessage(msg)
				msg = ""
			end
		end	
	
	if List.empty(Player.LootList) then
		Player.LastLootName = nil
		Player.LootList = List.new()
	end
end

function CDGSL:ChatterEnd(...)
	CDGSL:LootClosed(...)
end


function CDGSL:ReticleHiddenUpdate(_, hidden, ...)	
	if hidden then 
		if not Player.isCrafting then
			Player.LastLootName, _, _ = GetLootTargetInfo()
		end
	end
end

function CDGSL:LootReceived(_, lootedBy, itemName, quantity, _, lootType, self)
	local quality = nil
			
	quality = GetItemLinkQuality(itemName)

	if self then	
--		for bagslot = 0, GetBagSize(BAG_BACKPACK) do
--			if itemName == GetItemLink(BAG_BACKPACK, bagslot) then
--				quality = select(8, GetItemInfo(BAG_BACKPACK, bagslot))
--				break
--			end				
--		end

		if 	(savedVars_CDGShowLoot.filter.self.JUNK and (quality == LOOTQUALITY.JUNK)) or 
		   	(savedVars_CDGShowLoot.filter.self.NORMAL and (quality == LOOTQUALITY.NORMAL)) or
		   	(savedVars_CDGShowLoot.filter.self.FINE and (quality == LOOTQUALITY.FINE)) or
			(savedVars_CDGShowLoot.filter.self.SUPERIOR and (quality == LOOTQUALITY.SUPERIOR)) or
			(savedVars_CDGShowLoot.filter.self.EPIC and (quality == LOOTQUALITY.EPIC)) or
			(savedVars_CDGShowLoot.filter.self.LEGENDARY and (quality == LOOTQUALITY.LEGENDARY)) then 
			--
			-- nothing
			--
		else
			List.push(Player.LootList, {who = GetUnitName("player"), qty = quantity, val = itemName})	
		end

	else	 
 
		--if savedVars_CDGShowLoot.showGroupLoot then
			if 	(savedVars_CDGShowLoot.filter.group.JUNK and (quality == LOOTQUALITY.JUNK)) or 
			   	(savedVars_CDGShowLoot.filter.group.NORMAL and (quality == LOOTQUALITY.NORMAL)) or
			   	(savedVars_CDGShowLoot.filter.group.FINE and (quality == LOOTQUALITY.FINE)) or
				(savedVars_CDGShowLoot.filter.group.SUPERIOR and (quality == LOOTQUALITY.SUPERIOR)) or
				(savedVars_CDGShowLoot.filter.group.EPIC and (quality == LOOTQUALITY.EPIC)) or
				(savedVars_CDGShowLoot.filter.group.LEGENDARY and (quality == LOOTQUALITY.LEGENDARY)) then 
				--
				-- nothing
				--
			else			
				List.push(Player.LootList, {who = lootedBy, qty = quantity, val = itemName})
					
				CDGSL:SetDelayedLootUpdate()
			end
--		end
	end
end

function CDGSL:MoneyUpdate(_, newMoney, oldMoney,...) 
	if not savedVars_CDGShowLoot.filter.gold then
		List.push(Player.LootList, {who = GetUnitName("player"), qty = (newMoney - oldMoney), val = "gold"})
	end
end

function CDGSL:CraftingStationInteract(...)
	Player.isCrafting = true	
end

function CDGSL:EndCraftingStationInteract(...)
	Player.isCrafting = false
end

function CDGSL:CraftCompleted(...)
	Player.LastLootName, _, _ = GetLootTargetInfo()
	local items = GetNumLastCraftingResultItemsAndPenalty()
	for i=1, items do
		local itemName, _, quantity, _, _, _, _, _, quality, _, _ = GetLastCraftingResultItemInfo(i)
		if itemName == nil then 
			CDGSL:sendMessage("Failed to retrieve last crafting results") 
		end
		local itemLink = CDGSL:LookUpItemNameInBag(itemName)
		if itemLink == nil then 
			CDGSL:sendMessage("Failed to look up item [" .. itemName .. "], retrying ...")
			itemLink = CDGSL:LookUpItemNameInBag(itemName)
			if itemLink == nil then 
				CDGSL:sendMessage("Retry failed, giving up...")
			end
		end
		--
		-- Some odd cases it can happen that the itemLink is nil, but why ...
		--
		if itemLink ~= nil then						
			if 	(savedVars_CDGShowLoot.filter.self.JUNK and (quality == LOOTQUALITY.JUNK)) or 
			   	(savedVars_CDGShowLoot.filter.self.NORMAL and (quality == LOOTQUALITY.NORMAL)) or
			   	(savedVars_CDGShowLoot.filter.self.FINE and (quality == LOOTQUALITY.FINE)) or
				(savedVars_CDGShowLoot.filter.self.SUPERIOR and (quality == LOOTQUALITY.SUPERIOR)) or
				(savedVars_CDGShowLoot.filter.self.EPIC and (quality == LOOTQUALITY.EPIC)) or
				(savedVars_CDGShowLoot.filter.self.LEGENDARY and (quality == LOOTQUALITY.LEGENDARY)) then 
			--
			-- Do Nothing
			--
			else		
				List.push(Player.LootList, {who = GetUnitName("player"),qty = quantity, val = itemLink})
			end
		end
	end
    CDGSL:LootClosed()
end

function CDGSL:LookUpItemNameInBag(itemName)
	for b=1, GetBagSize(BAG_BACKPACK) do
		local bagItemName = GetItemName(BAG_BACKPACK, b) 
		if (bagItemName == itemName) then 
			return GetItemLink(BAG_BACKPACK, b) 	
		end		
	end
end

function CDGSL:QuestRemoved(isCompleted, ...)
	if isCompleted then
		CDGSL:LootClosed()
	end
end

local function getChatWindows()
	windows  = {}
	index = 1
	for i = 1, GetNumChatContainers() do
		for j = 1, GetNumChatContainerTabs(i) do
			name,_,_,_,_ = GetChatContainerTabInfo(i, j)
			windows[index] = i.."."..j.." "..name
			index = index + 1
		end
	end
	return windows
end

local function getChatWindow()
	return savedVars_CDGShowLoot.chatWindow
end

local function setChatWindow(value)
	savedVars_CDGShowLoot.chatWindow = value
	savedVars_CDGShowLoot.chatContainerId = tonumber(string.sub(savedVars_CDGShowLoot.chatWindow,1,1))
	savedVars_CDGShowLoot.chatWindowId = tonumber(string.sub(savedVars_CDGShowLoot.chatWindow,3,3))
end

function CDGSL:sendMessage(message)	
	if savedVars_CDGShowLoot.logToDefaultChat then
		if savedVars_CDGShowLoot.chatWindow then
			CHAT_SYSTEM["containers"][savedVars_CDGShowLoot.chatContainerId]["windows"][savedVars_CDGShowLoot.chatWindowId]["buffer"]:AddMessage(message)
		else
			CHAT_SYSTEM:AddMessage(message)
		end
	end
	CDGLibGui.addMessage(message)
end

local function RGBtoHEX(r,g,b,a)
	--	hex = string.format("%.2x%.2x%.2x%.2x", math.floor(a * 255),math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
	return string.format("%.2x%.2x%.2x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

local function QColortoHex(qcolor)	
	return RGBtoHEX(qcolor.r,qcolor.g,qcolor.b,qcolor.a)
end

local function HEXtoRGB(hex)
    local a, r, g, b
    
    if(string.len(hex) == 8)
    then
        a, r, g, b = tonumber("0x"..string.sub(hex, 1, 2)) / 255, tonumber("0x"..string.sub(hex, 3, 4)) / 255, tonumber("0x"..string.sub(hex, 5, 6)) / 255, tonumber("0x"..string.sub(hex, 7, 8)) / 255
    elseif(string.len(hex) == 6)
    then
        a, r, g, b = 1, tonumber("0x"..string.sub(hex, 1, 2)) / 255, tonumber("0x"..string.sub(hex, 3, 4)) / 255, tonumber("0x"..string.sub(hex, 5, 6)) / 255
    end
    
    if(a)
    then
        return r, g, b, a
    end
	
end

function CDGSL:HideIfVisible()
	if CDGLibGui.isHiddenInDialogs() then
		CDGLibGui.Hide()
	end
end

function CDGSL:ShowIfVisible()
	if CDGLibGui.isHiddenInDialogs() then
		CDGLibGui.Show()
	end
end

function CDGSL:SetPreHooks()
	ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
        CDGSL:HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function()
        CDGSL:ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
        CDGSL:HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function()
        CDGSL:ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
        CDGSL:HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function()
        CDGSL:ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
        CDGSL:HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
        CDGSL:ShowIfVisible()
    end)
end



local function createLAM2Panel()
    local panelData = 
    {
        type = "panel",
        name = Addon.NameSpaced,
        displayName = ZO_HIGHLIGHT_TEXT:Colorize(Addon.NameSpaced),
        author = "|cFFA500"..Addon.Author.."|r",
        version = Addon.Version,        
    }

    local optionsData = {}
    --{        
        table.insert(optionsData, { type = "description", text = "Show Loot is an addon that displays items looted in a optional loot window or a default chat window of your choice.", })
        table.insert(optionsData, { type = "header", name = "General Options", })
        table.insert(optionsData, { type = "checkbox", name = "Log to eso chat window", tooltip = "Log to eso chat window", getFunc = function() return savedVars_CDGShowLoot.logToDefaultChat end, setFunc = function(value) savedVars_CDGShowLoot.logToDefaultChat = value end, })
        table.insert(optionsData, { type = "dropdown", name = "Chat Window", tooltip = "Chat window", choices = getChatWindows(), getFunc = function() return getChatWindow() end, setFunc = function(value) setChatWindow(value) end, })
    	table.insert(optionsData, { type = "colorpicker", name = "Player Color", tooltip = "Player Color Name.", getFunc = function() return HEXtoRGB(savedVars_CDGShowLoot.playerColor) end, setFunc = function(r,g,b,a) savedVars_CDGShowLoot.playerColor = RGBtoHEX(r,g,b,a) end, })
    	table.insert(optionsData, { type = "colorpicker", name = "Group Color", tooltip = "Group Players Color Name.", getFunc = function() return HEXtoRGB(savedVars_CDGShowLoot.groupColor) end, setFunc = function(r,g,b,a) savedVars_CDGShowLoot.groupColor = RGBtoHEX(r,g,b,a) end, })
    	table.insert(optionsData, { type = "header", name = "Font Settings", })
        table.insert(optionsData, { type = "dropdown", name = "Font Type", tooltip = "Font Type.", choices = LMP:List("font"), getFunc = function() return CDGLibGui.getDefaultFont() end, setFunc = function(value) CDGLibGui.setDefaultFont(value) end, warning = "Will need to reload the UI.", })
    	table.insert(optionsData, { type = "slider", name = "Font Size", tooltip = "Font Size.", min = 10, max = 30, step = 1, getFunc = function() return CDGLibGui.getFontSize() end, setFunc = function(value) CDGLibGui.setFontSize(value) end, warning = "Will need to reload the UI.", })
    	table.insert(optionsData, { type = "dropdown", name = "Font Style", tooltip = "Font Style.", choices = CDGLibGui.fontstyles, getFunc = function() return CDGLibGui.getFontStyle() end, setFunc = function(value) CDGLibGui.setFontStyle(value) end, warning = "Will need to reload the UI.", })
    	table.insert(optionsData, { type = "header", name = "General Filters", })
        table.insert(optionsData, { type = "checkbox", name = "Hide Gold Gains", tooltip = "Don't show gold gains.", getFunc = function() return savedVars_CDGShowLoot.filter.gold end, setFunc = function(value) savedVars_CDGShowLoot.filter.gold = value end, })
        table.insert(optionsData, { type = "slider", name = "Minimal gold to display", tooltip = "Minimum amount of gold gain needed before displaying.", min = 0, max = 1000, step = 10, getFunc = function() return savedVars_CDGShowLoot.filter.minGold end, setFunc = function(value) savedVars_CDGShowLoot.filter.minGold = value end, })
    	table.insert(optionsData, { type = "checkbox", name = "Hide player name", tooltip = "Don't show your own personal name when displaying loot", getFunc = function() return savedVars_CDGShowLoot.hidePlayerName end, setFunc = function(value) savedVars_CDGShowLoot.hidePlayerName = value end, })
    	table.insert(optionsData, { type = "checkbox", name = "Show Bag Stacks", tooltip = "Show amount of items in your bag.", getFunc = function() return savedVars_CDGShowLoot.showBagStacks end, setFunc = function(value) savedVars_CDGShowLoot.showBagStacks = value end, })
    	table.insert(optionsData, { type = "checkbox", name = "Show Bank Stacks", tooltip = "Show amount of items in your bank.", getFunc = function() return savedVars_CDGShowLoot.showBankStacks end, setFunc = function(value) savedVars_CDGShowLoot.showBankStacks = value end, })
        table.insert(optionsData, { type = "header",   name = "Personal Loot Filters", })
    	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.JUNK)).."Junk".."|r",          "", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.self.JUNK end,       setFunc = function(value) savedVars_CDGShowLoot.filter.self.JUNK = value end, })
	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.NORMAL)).."Normal".."|r",      "", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.self.NORMAL end,     setFunc = function(value) savedVars_CDGShowLoot.filter.self.NORMAL = value end, })
	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.FINE)).."Fine".."|r",          "", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.self.FINE end,       setFunc = function(value) savedVars_CDGShowLoot.filter.self.FINE = value end, })
	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.SUPERIOR)).."Superior".."|r",  "", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.self.SUPERIOR end,   setFunc = function(value) savedVars_CDGShowLoot.filter.self.SUPERIOR = value end, })
	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.EPIC)).."Epic".."|r",          "", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.self.EPIC end,       setFunc = function(value) savedVars_CDGShowLoot.filter.self.EPIC = value end, })
	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.LEGENDARY)).."Legendary".."|r","", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.self.LEGENDARY end,  setFunc = function(value) savedVars_CDGShowLoot.filter.self.LEGENDARY = value end, })
	table.insert(optionsData, { type = "header",   name = "Group Loot Filters", })
	--table.insert(optionsData, { type = "description", text = "The new patch made group loot filters not possible anymore.Group loot disabled till i have a solutiion. If you like spam you can enable the option below", })
	--table.insert(optionsData, { type = "checkbox", name = "Show Group Loot", tooltip = "Show ALL group loot", getFunc = function() return savedVars_CDGShowLoot.showGroupLoot end, setFunc = function(value) savedVars_CDGShowLoot.nshowGroupLoot = value end, })
    	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.JUNK)).."Junk".."|r",          "", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.group.JUNK end,      setFunc = function(value) savedVars_CDGShowLoot.filter.group.JUNK = value end, })
	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.NORMAL)).."Normal".."|r",      "", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.group.NORMAL end,    setFunc = function(value) savedVars_CDGShowLoot.filter.group.NORMAL = value end, })
	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.FINE)).."Fine".."|r",          "", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.group.FINE end,      setFunc = function(value) savedVars_CDGShowLoot.filter.group.FINE = value end, })
	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.SUPERIOR)).."Superior".."|r",  "", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.group.SUPERIOR end,  setFunc = function(value) savedVars_CDGShowLoot.filter.group.SUPERIOR = value end, })
	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.EPIC)).."Epic".."|r",          "", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.group.EPIC end,      setFunc = function(value) savedVars_CDGShowLoot.filter.group.EPIC = value end, })
	table.insert(optionsData, { type = "checkbox", name = "|c"..QColortoHex(GetItemQualityColor(LOOTQUALITY.LEGENDARY)).."Legendary".."|r","", tooltip = "Do NOT show items of this quality.", getFunc = function() return savedVars_CDGShowLoot.filter.group.LEGENDARY end, setFunc = function(value) savedVars_CDGShowLoot.filter.group.LEGENDARY = value end, })
    	table.insert(optionsData, { type = "header", name = "Optional Loot Window", })
        table.insert(optionsData, { type = "checkbox", name = "Hide window", tooltip = "Hide the loot window.", getFunc = function() return CDGLibGui.isHidden() end, setFunc = function(value) CDGLibGui.setHidden(value) end, })
        table.insert(optionsData, { type = "checkbox", name = "Hide window when in dialog", tooltip = "Hide the loot window when dialog windows are open.", getFunc = function() return CDGLibGui.isHiddenInDialogs() end, setFunc = function(value) CDGLibGui.HideInDialogs(value) end, })
    	table.insert(optionsData, { type = "checkbox", name = "Unlock window", tooltip = "Unlock window to move it.", getFunc = function() return CDGLibGui.isMovable() end, setFunc = function(value) CDGLibGui.setMovable(value) end, })
		table.insert(optionsData, { type = "checkbox", name = "Hide background", tooltip = "Hide the background of the window", getFunc = function() return CDGLibGui.isBackgroundHidden() end, setFunc = function(value) CDGLibGui.setBackgroundHidden(value) end, warning = "Background is needed to move window."})
		table.insert(optionsData, { type = "checkbox", name = "Show timestamps", tooltip = "Show timestamps before message", getFunc = function() return CDGLibGui.isTimestampEnabled() end, setFunc = function(value) CDGLibGui.setTimestampEnabled(value) end, })
        table.insert(optionsData, { type = "slider", name = "Time till text fades out", tooltip = "Time needed before ffading out.", min = 0, max = 10, step = 1, getFunc = function() return CDGLibGui.getTimeTillLineFade() end, setFunc = function(value) CDGLibGui.setTimeTillLineFade(value) end, })
        
    --} 

   	LAM2:RegisterAddonPanel(Addon.Name.."LAM2Options", panelData)    
    LAM2:RegisterOptionControls(Addon.Name.."LAM2Options", optionsData)
end 

function CDGSL:EVENT_ADD_ON_LOADED(eventCode, addOnName, ...)
	if(addOnName == "CDGShowLoot") then
		savedVars_CDGShowLoot = ZO_SavedVars:New("CDGShowLoot_SavedVariables", 2, nil, localVars.defaults)
		CDGLibGui.initializeSavedVariable()		
		CDGLibGui.CreateWindow()						

		createLAM2Panel()

		Player.LootList = List.new()
		--
		-- No point starting these events earlier till the addon is fully loaded.
		--
		EVENT_MANAGER:RegisterForEvent("CDGShowLoot", EVENT_CRAFTING_STATION_INTERACT, function(...) CDGSL:CraftingStationInteract(...) end)
		EVENT_MANAGER:RegisterForEvent("CDGShowLoot", EVENT_END_CRAFTING_STATION_INTERACT, function(...) CDGSL:EndCraftingStationInteract(...) end)
		EVENT_MANAGER:RegisterForEvent("CDGShowLoot", EVENT_CRAFT_COMPLETED, function(...) CDGSL:CraftCompleted(...) end)
		EVENT_MANAGER:RegisterForEvent("CDGShowLoot", EVENT_RETICLE_HIDDEN_UPDATE, function(...) CDGSL:ReticleHiddenUpdate(...) end)
		EVENT_MANAGER:RegisterForEvent("CDGShowLoot", EVENT_LOOT_CLOSED, function(...) CDGSL:LootClosed(...) end)	
		EVENT_MANAGER:RegisterForEvent("CDGShowLoot", EVENT_CHATTER_END, function(...) CDGSL:ChatterEnd(...) end)
		EVENT_MANAGER:RegisterForEvent("CDGShowLoot", EVENT_QUEST_REMOVED, function(...) CDGSL:QuestRemoved(...) end)
		EVENT_MANAGER:RegisterForEvent("CDGShowLoot", EVENT_MONEY_UPDATE, function(...) CDGSL:MoneyUpdate(...) end )
		EVENT_MANAGER:RegisterForEvent("CDGShowLoot", EVENT_LOOT_RECEIVED, function(...) CDGSL:LootReceived(...) end)	

		EVENT_MANAGER:UnregisterForEvent( "CDGShowLoot", EVENT_ADD_ON_LOADED )	
    end
end

EVENT_MANAGER:RegisterForEvent("CDGShowLoot", EVENT_ADD_ON_LOADED, function(...) CDGSL:EVENT_ADD_ON_LOADED(...) end )	
