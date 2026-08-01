----------------------------------------------------------------------------------------------------------------------------------------
--  BagSpaceIndicator
----------------------------------------------------------------------------------------------------------------------------------------
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
-- The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
-- All rights reserved
--
-- You can read the full terms at https://account.elderscrollsonline.com/add-on-terms
----------------------------------------------------------------------------------------------------------------------------------------
	
local AddonInfo = {
  addon = "BagSpaceIndicator",
  version = "3.2",
  author = "Lord Richter + Vel",
  savename = "BagSpaceIndicatorVars"
}

local BSI = {}
local BSIUI = {}

local g_panel_data = {
    type = "panel",
    name = "Bag Space",
    author = "Vel, Vel_33",
    version = "3.2",
    registerForRefresh = true,
    registerForDefaults = true,
}

BSI.optionsTable = nil

BSI.addonready = 0
BSI.upgrade1 = false
BSI.firsttime = false
BSI.updated = 0
BSI.debug = "Uninitialized"
BSI.message = ""
BSI.bankfree = "" 
BSI.invfree = ""
BSI.savedvariables = {}
BSI.default = { 
	offsetX = 5,
	offsetY = 5,
	EnableBackSpaceNotification = true,
	EnableBankSpaceNotification = true,
	EnableGoldNotification = true,
	EnableBackSpaceIcon = true,
	EnableBankSpaceIcon = true,
	EnableGoldIcon = true,
	EnableColorTint = true
}

BSIUI.windowmgr = GetWindowManager()
BSIUI.topwindow = nil
BSIUI.backdrop = nil
BSIUI.line1 = nil
BSIUI.line2 = nil
BSIUI.line3 = nil
BSIUI.label1 = nil
BSIUI.label2 = nil
BSIUI.label3 = nil
BSIUI.icon1 = nil
BSIUI.icon2 = nil
BSIUI.icon3 = nil
BSIUI.backgroundalpha=0.9

-- define some colors for commonality
BSIUI.Color = {}
BSIUI.Color.white = "|cffffff"
BSIUI.Color.red = "|cff0000"
BSIUI.Color.green = "|c50c878"
BSIUI.Color.yellow = "|cffff00"
--BSIUI.Color.gold = "|cffd700"
BSIUI.Color.gold = "|cffffcc"
BSIUI.Color.gray = "|c7f7f7f"
BSIUI.Color.cream = "|cffffcc"

-- ZOS API References
local GetBagSize = GetBagSize
local GetNumBagUsedSlots = GetNumBagUsedSlots
local GetNumBagFreeSlots = GetNumBagFreeSlots
local GetBagUseableSize = GetBagUseableSize
local GetCurrentMoney = GetCurrentMoney
local GetFrameTimeMilliseconds = GetFrameTimeMilliseconds

local delay = {
	last = nil
}

local template_bagdata = {
	bag=0,
	maximum=0,
	used=0,
	available=0
}

local function initializeTable(template)
  local t2 = {}
  local k,v
  for k,v in pairs(template) do
    t2[k] = v
  end
  return t2 
end

function BSIUpdate()
	if BSI.updated then
		BSI.updated = 0
	end
end


function HideCheck()
  if ZO_CompassFrame and BagSpaceIndicatorFloat then
    BagSpaceIndicatorFloat:SetHidden(ZO_CompassFrame:IsHidden())
  end
end

-- save the window position if they move it
local function OnMoveStop(self)
  BSI.savedvariables.offsetX = self:GetLeft()
  BSI.savedvariables.offsetY = self:GetTop()
end

local function LoadAddon(eventCode, addOnName)
	if(addOnName == AddonInfo.addon) then
		
		local labelheight = 20
		local labelwidth = 100
		BSI.normal = initializeTable(template_bagdata)
		BSI.bank = initializeTable(template_bagdata)
		BSI.subscriber = initializeTable(template_bagdata)
		-- adjust the default offset based on screen size
		local screenwidth = GuiRoot:GetWidth()
		-- BSI.default.offsetX = screenwidth*0.2
		BSI.default.offsetX = 5
		BSI.default.offsetY = 5
		BSI.savedvariables = ZO_SavedVars:New(AddonInfo.savename,1,nil,BSI.default)
		
		-- upgrade and repair saved variables  
		if BSI.savedvariables.offsetX==nil then
		  BSI.savedvariables.offsetX = BSI.defaults.offsetX
		  BSI.upgrade1 = true
		end
		
		if BSI.savedvariables.offsetY==nil then
			BSI.savedvariables.offsetY = BSI.defaults.offsetY
			BSI.upgrade1 = true
		end
    
		if BSI.savedvariables.ishidden==nil then
			BSI.savedvariables.ishidden = false
			BSI.upgrade1 = true
			BSI.firsttime = true
		end
    
		if BSI.savedvariables.displaywindow then
			BSI.savedvariables.displaywindow = nil
		end
		
		-- Vel variables initiate
		if BSI.savedvariables.EnableGoldNotification == nil then
		  BSI.savedvariables.EnableGoldNotification = BSI.default.EnableGoldNotification
		end
		if BSI.savedvariables.EnableBackSpaceNotification == nil then
		  BSI.savedvariables.EnableBackSpaceNotification = BSI.default.EnableBackSpaceNotification
		end
		if BSI.savedvariables.EnableBankSpaceNotification == nil then
		  BSI.savedvariables.EnableBankSpaceNotification = BSI.default.EnableBankSpaceNotification
		end
		if BSI.savedvariables.EnableGoldIcon == nil then
		  BSI.savedvariables.EnableGoldIcon = BSI.default.EnableGoldIcon
		end
		if BSI.savedvariables.EnableBackSpaceIcon == nil then
		  BSI.savedvariables.EnableBackSpaceIcon = BSI.default.EnableBackSpaceIcon
		end
		if BSI.savedvariables.EnableBankSpaceIcon == nil then
		  BSI.savedvariables.EnableBankSpaceIcon = BSI.default.EnableBankSpaceIcon
		end
		if BSI.savedvariables.EnableColorTint == nil then
			BSI.savedvariables.EnableColorTint = BSI.default.EnableColorTint
		end
		
		
		BSI.savedvariables.addonversion = AddonInfo.version
		if (LibNorthCastle) then LibNorthCastle:Register(AddonInfo.addon,AddonInfo.version) end
		
		-- create the floating information window
		local windowcfg
		BSIUI.topwindow = BSIUI.windowmgr:CreateTopLevelWindow("BagSpaceIndicatorFloat")
		windowcfg = BSIUI.topwindow
		windowcfg:SetClampedToScreen(true)
		windowcfg:SetMouseEnabled(true) 
		windowcfg:SetResizeToFitDescendents(true)
		windowcfg:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSI.savedvariables.offsetX, BSI.savedvariables.offsetY)
		windowcfg:SetHidden(BSI.savedvariables.ishidden)
		windowcfg:SetMovable(true)
		windowcfg:SetHandler("OnMoveStop", OnMoveStop)
		
		--BSIUI.backdrop = BSIUI.windowmgr:CreateControl("BagSpaceIndicatorFloatBG", BSIUI.topwindow, CT_BACKDROP)
		--windowcfg = BSIUI.backdrop
		--windowcfg:SetHidden(true)
		--windowcfg:SetClampedToScreen(false)
		--windowcfg:SetAnchor(TOPLEFT, BSIUI.topwindow, TOPLEFT, 0, 0)
		--windowcfg:SetResizeToFitDescendents(true)
		--windowcfg:SetResizeToFitPadding(32,5)
		--windowcfg:SetDimensionConstraints(labelwidth,labelheight)
		--windowcfg:SetInsets (5,5,-5,-5)
		--windowcfg:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 16)
		--windowcfg:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
		--windowcfg:SetAlpha(BSIUI.backgroundalpha)
		--windowcfg:SetDrawLayer(0)
    
		BSIUI.infobox = BSIUI.windowmgr:CreateControl("BagSpaceIndicatorFloatBox", BSIUI.topwindow, CT_CONTROL)
		windowcfg = BSIUI.infobox
		windowcfg:SetAnchor(TOPLEFT, BSIUI.topwindow, TOPLEFT, 5, 5)
  		
		-- gold
		BSIUI.line1 = BSIUI.windowmgr:CreateControl("BagSpaceIndicatorFloatLine1", BSIUI.infobox, CT_CONTROL)
		windowcfg = BSIUI.line1
		windowcfg:SetAnchor(TOPLEFT, BSIUI.infobox, TOPLEFT, 0, 0)

		-- Отображаем иконку денег
		if (BSI.savedvariables.EnableGoldIcon) then
			BSIUI.icon1 = BSIUI.windowmgr:CreateControl("BagSpaceIndicatorFloatIcon1", BSIUI.line1, CT_TEXTURE)
			windowcfg = BSIUI.icon1
			windowcfg:SetDimensions(labelheight*0.75,labelheight*0.75)
			windowcfg:SetAnchor(LEFT, BSIUI.line1, LEFT, labelheight*.2, labelheight*.1)
			windowcfg:SetTexture("/esoui/art/currency/currency_gold.dds")
		end
		
		windowcfg:SetHidden(not BSI.savedvariables.EnableGoldNotification)
		
		BSIUI.label1 = BSIUI.windowmgr:CreateControl("BagSpaceIndicatorFloatLabel1", BSIUI.line1, CT_LABEL)
		windowcfg = BSIUI.label1
		windowcfg:SetColor(0.8, 0.8, 0.8, 1)
		windowcfg:SetFont("ZoFontGameMedium")
		windowcfg:SetWrapMode(TEX_MODE_CLAMP)
		windowcfg:SetText("")
		windowcfg:SetAnchor(LEFT, BSIUI.icon1, RIGHT, 8, 1)
		windowcfg:SetDimensions(labelwidth,labelheight)
    
		-- bags
		BSIUI.line2 = BSIUI.windowmgr:CreateControl("BagSpaceIndicatorFloatLine2", BSIUI.infobox, CT_CONTROL)
		windowcfg = BSIUI.line2
		windowcfg:SetAnchor(TOPLEFT, BSIUI.infobox, CENTER, labelwidth, 0)
		--windowcfg:SetAnchor(TOPLEFT, BSIUI.infobox, TOPLEFT, 0, labelheight)

		-- Отображаем иконку рюкзака
		if (BSI.savedvariables.EnableBackSpaceIcon) then
			BSIUI.icon2 = BSIUI.windowmgr:CreateControl("BagSpaceIndicatorFloatIcon2", BSIUI.line2, CT_TEXTURE)
			windowcfg = BSIUI.icon2
			windowcfg:SetDimensions(labelheight,labelheight)
			windowcfg:SetAnchor(LEFT, BSIUI.line2, LEFT, 0, 0)
			windowcfg:SetTexture("/esoui/art/tooltips/icon_bag.dds")
		end
		
		windowcfg:SetHidden(not BSI.savedvariables.EnableBackSpaceNotification)
		
		BSIUI.label2 = BSIUI.windowmgr:CreateControl("BagSpaceIndicatorFloatLabel2", BSIUI.line2, CT_LABEL)
		windowcfg = BSIUI.label2
		windowcfg:SetColor(0.8, 0.8, 0.8, 1)
		windowcfg:SetFont("ZoFontGameMedium")
		windowcfg:SetWrapMode(TEX_MODE_CLAMP)
		windowcfg:SetText("")
		windowcfg:SetAnchor(LEFT, BSIUI.icon2, RIGHT, 10, 1)
		windowcfg:SetDimensions(labelwidth,labelheight)
    
		--bank
		BSIUI.line3 = BSIUI.windowmgr:CreateControl("BagSpaceIndicatorFloatLine3", BSIUI.infobox, CT_CONTROL)
		windowcfg = BSIUI.line3
		windowcfg:SetAnchor(TOPLEFT, BSIUI.infobox, TOPLEFT, (labelwidth*2), 0)
		--windowcfg:SetAnchor(TOPLEFT, BSIUI.infobox, TOPLEFT, 0, (labelheight*2))
	
		-- Отображаем иконку банка
		if (BSI.savedvariables.EnableBankSpaceIcon) then
			BSIUI.icon3 = BSIUI.windowmgr:CreateControl("BagSpaceIndicatorFloatIcon3", BSIUI.line3, CT_TEXTURE)
			windowcfg = BSIUI.icon3
			windowcfg:SetDimensions(labelheight,labelheight)
			windowcfg:SetAnchor(LEFT, BSIUI.line3, LEFT, 0, 0)
			windowcfg:SetTexture("/esoui/art/tooltips/icon_bank.dds")
		end
		
		windowcfg:SetHidden(not BSI.savedvariables.EnableBankSpaceNotification)
		BSIUI.label3 = BSIUI.windowmgr:CreateControl("BagSpaceIndicatorFloatLabel3", BSIUI.line3, CT_LABEL)
		windowcfg = BSIUI.label3
		windowcfg:SetColor(0.8, 0.8, 0.8, 1)
		windowcfg:SetFont("ZoFontGameMedium")
		windowcfg:SetWrapMode(TEX_MODE_CLAMP)
		windowcfg:SetText("")
		windowcfg:SetAnchor(LEFT, BSIUI.icon3, RIGHT, 5, 1)
		windowcfg:SetDimensions(labelwidth,labelheight)
		
		UpdateBSIData()
		InitSettingsPanel()
		
		if (BSI.goldamount < 10000000) then BagSpaceIndicatorFloatLabel1:SetFont("ZoFontGameMedium") 
		--else BagSpaceIndicatorFloatLabel1:SetFont("ZoFontGameSmall") end
		else BagSpaceIndicatorFloatLabel1:SetFont("ZoFontGameMedium") end
		
		BagSpaceIndicatorFloatLabel2:SetText(BSI.floatbag)
		BagSpaceIndicatorFloatLabel3:SetText(BSI.floatbank)
		BagSpaceIndicatorFloatLabel1:SetText(BSI.floatgold)
							
		EVENT_MANAGER:UnregisterForEvent(AddonInfo.addon, EVENT_ADD_ON_LOADED)
		
		BSI.addonready = 1
		

	end	
end

function BSIOpenBank(eventCode)
	if (BSI.addonready == 0) then return end
	BSI.updated=1
	postBagInformation()
end

function BSICloseBank(eventCode)
  if (BSI.addonready == 0) then return end
  BSI.updated=1
  postBagInformation()
end


function BSIInventoryEvent(bagId, slotId, isNewItem, itemSoundCategory, updateReason)
	if (BSI.addonready == 0) then return end
	BSI.updated=1
	postBagInformation()
end 

function BSIItemEvent(eventCode, eventData)
	if (BSI.addonready == 0) then return end
	BSI.updated=1
	postBagInformation()
end 

function BSIMoneyEvent(eventCode, eventData)
  if (BSI.addonready == 0) then return end
  BSI.updated=1
  postBagInformation()
end 


function postBagInformation()
	UpdateBSIData()
	
	--if (BSI.goldamount < 10000000) then BagSpaceIndicatorFloatLabel1:SetFont("ZoFontGameMedium") 
	--else BagSpaceIndicatorFloatLabel1:SetFont("ZoFontGameSmall")
	--end
	BagSpaceIndicatorFloatLabel1:SetFont("ZoFontGameMedium")
	BagSpaceIndicatorFloatLabel2:SetText(BSI.floatbag)
	BagSpaceIndicatorFloatLabel1:SetText(BSI.floatgold)
	BagSpaceIndicatorFloatLabel3:SetText(BSI.floatbank)
end

function postBankInformation()

end

function UpdateBSIData()
  -- h5. Bag
  --  * BAG_BACKPACK
  --  * BAG_BANK
  --  * BAG_BUYBACK
  --  * BAG_GUILDBANK
  --  * BAG_SUBSCRIBER_BANK
  --  * BAG_VIRTUAL 
  --  * BAG_WORN 

	local bagid = BAG_BACKPACK
	local bankid = BAG_BANK
	local subbankid = BAG_SUBSCRIBER_BANK
	local guildbankid = BAG_GUILDBANK 
	
	local gold = GetCurrentMoney()
	BSI.goldamount = gold
	local goldfmt = FormatIntegerWithDigitGrouping(gold,",",3);
	
	-- normal bag
	BSI.normal=initializeTable(template_bagdata)
	BSI.normal.bag = bagid
	BSI.normal.maximum = GetBagSize(bagid)
	BSI.normal.used = GetNumBagUsedSlots(bagid)
	BSI.normal.available = GetNumBagFreeSlots(bagid)
	BSI.normal.usable = GetBagUseableSize(bagid)
  
	-- normal bank
	BSI.bank = initializeTable(template_bagdata)
	BSI.bank.bag=bankid 
	BSI.bank.maximum=GetBagSize(bankid)
	BSI.bank.used=GetNumBagUsedSlots(bankid)
	BSI.bank.usable = GetBagUseableSize(bankid)
	BSI.bank.available=BSI.bank.usable - BSI.bank.used
  
	-- subscriber bank
 	BSI.subscriber = initializeTable(template_bagdata)
	BSI.subscriber.bag = subbankid
	BSI.subscriber.maximum = GetBagSize(subbankid)
	BSI.subscriber.used = GetNumBagUsedSlots(subbankid)
	BSI.subscriber.usable = GetBagUseableSize(subbankid)
	BSI.subscriber.available = BSI.subscriber.usable - BSI.subscriber.used

	-- total bank  
	local bankmax = BSI.bank.maximum + BSI.subscriber.usable
	local bankused = BSI.bank.used + BSI.subscriber.used
	
	local banksizewarning = BSIUI.Color.white
	local bagsizewarning = BSIUI.Color.white
	local goldColor = BSIUI.Color.white
	if (BSI.savedvariables.EnableColorTint == true) then
		goldColor = BSIUI.Color.gold
	end
	
	-- Тонирование цифр цветом зависит от настройки этого пункта в меню (по умолчанию true) -- 18.12.2024 -- Vel
	if (BSI.savedvariables.EnableColorTint == true) then
		-- установка цвета отображения ячеек инвентаря
		if (BSI.normal.used >= BSI.normal.maximum - 5) then bagsizewarning = BSIUI.Color.red
		elseif (BSI.normal.used > (BSI.normal.maximum - 20)) then bagsizewarning = BSIUI.Color.yellow
		elseif (BSI.normal.used > (BSI.normal.maximum * 0.5)) then bagsizewarning = BSIUI.Color.green
		end
		
		-- установка цвета отображения ячеек банка
		if (bankused >= bankmax - 5) then banksizewarning = BSIUI.Color.red
		elseif (bankused > (bankmax - 20)) then banksizewarning = BSIUI.Color.yellow
		elseif (bankused > (bankmax * 0.5)) then banksizewarning = BSIUI.Color.green
		end

		-- установка цвета отображения количества золотых
		if (BSI.goldamount > 10000000) then goldColor = BSIUI.Color.red
		elseif (BSI.goldamount > 5000000) then goldColor = BSIUI.Color.yellow
		elseif (BSI.goldamount > 1000000) then goldColor = BSIUI.Color.green
		end
	end
	-- text for the bank/inventory dialog
	
	local backpack = BSIUI.Color.cream.."Backpack: "..bagsizewarning..BSI.normal.used.." / "..BSI.normal.maximum..BSIUI.Color.cream
	local playerbank = ",  Bank: "..banksizewarning..bankused.." / "..bankmax..BSIUI.Color.cream
	local goldline = goldColor..goldfmt.." "
	local bagline = bagsizewarning..BSI.normal.used.." / "..BSI.normal.maximum
	local bankline = banksizewarning..bankused.." / "..bankmax

	BSI.message = backpack..playerbank
	BSI.bankfree = backpack..playerbank 
	BSI.invfree = backpack
	
	BSI.floatbag = bagline
	BSI.floatgold = goldline
	BSI.goldamount = gold
	
	BSI.floatbank = bankline
	
	BSI.updated = 1
	return message
end 

function ThrashingDelay(timer)
	local now = GetFrameTimeMilliseconds() 
	if delay.last == nil then
		delay.last = now 
	end	
	local diff = now - delay.last
	local eval = (diff >= timer)
	if eval then
		delay.last = now 
	end
	return eval
end

function InitSettingsPanel()

	local LAM = LibAddonMenu2
	
	local panelData = {
		type = "panel",
		name = "Bag Space Indicator",
		author = "Vel",
		version = "3.3",
		registerForRefresh		= true,
		registerForDefaults		= true,
	}

	LAM:RegisterAddonPanel("Options", panelData)
		
	local optionsTable = {
		{
			type = "header", 
			name = "Main Options",
		},
		{	-- показывать ли вместимость сумки
			type = "checkbox",
			name = "Display the bag space",
			--tooltip = "Displays",
			getFunc = function()
						return BSI.savedvariables.EnableBackSpaceNotification
					  end,
			setFunc = function(value)
						BSI.savedvariables.EnableBackSpaceNotification = value
					  end,	
		},
		{	-- показывать ли иконку сумки
			type = "checkbox",
			name = "Display the bag icon",
			--tooltip = "Displays",
			getFunc = function()
						return BSI.savedvariables.EnableBackSpaceIcon
					  end,
			setFunc = function(value)
						BSI.savedvariables.EnableBackSpaceIcon = value
					  end,	
		},
		{	-- показывать ли вместимость банка
			type = "checkbox",
			name = "Display the bank space",
			--tooltip = "Displays",
			getFunc = function()
						return BSI.savedvariables.EnableBankSpaceNotification
					  end,
			setFunc = function(value)
						 BSI.savedvariables.EnableBankSpaceNotification = value
					  end,
		},
		{	-- показывать ли иконку банка
			type = "checkbox",
			name = "Display the bank icon",
			--tooltip = "Displays",
			getFunc = function()
						return BSI.savedvariables.EnableBankSpaceIcon
					  end,
			setFunc = function(value)
						BSI.savedvariables.EnableBankSpaceIcon = value
					  end,	
		},
		{	-- показывать ли количество золота
			type = "checkbox",
			name = "Display the gold amount", 
			--tooltip = "Displays",
			getFunc = function()
						return BSI.savedvariables.EnableGoldNotification
					  end,
			setFunc = function(value)
						 BSI.savedvariables.EnableGoldNotification = value
					  end,
		},
		{	-- показывать ли иконку денег
			type = "checkbox",
			name = "Display the gold icon",
			--tooltip = "Displays",
			getFunc = function()
						return BSI.savedvariables.EnableGoldIcon
					  end,
			setFunc = function(value)
						BSI.savedvariables.EnableGoldIcon = value
					  end,	
		},
		{	-- использовать цвет для маркировки заполненности
			type = "checkbox",
			name = "Use color tint for numbers",
			tooltip = "Using colors (green, gold & red) for tint numbers, for example: if half of your bank if filled, number will tint in green; maximum - 20 will tint in yellow and maximum - 5 wiil tint in red colors",
			getFunc = function()
						return BSI.savedvariables.EnableColorTint
					  end,
			setFunc = function(value)
						BSI.savedvariables.EnableColorTint = value
					  end,	
		},
	}

	LAM:RegisterOptionControls("Options", optionsTable)
end

EVENT_MANAGER:RegisterForUpdate("BSIHideCheck", 100, HideCheck)
EVENT_MANAGER:RegisterForUpdate("BSIUpdateCheck", 110, BSIUpdate)

EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_ADD_ON_LOADED, LoadAddon)

EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_OPEN_STORE, BSIOpenBank)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_OPEN_BANK, BSIOpenBank)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_CLOSE_BANK, BSICloseBank)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_OPEN_GUILD_BANK, BSIOpenBank)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_CLOSE_GUILD_BANK, BSICloseBank)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_GUILD_BANK_UPDATED_QUANTITY, BSIOpenBank)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_GUILD_BANK_ITEMS_READY, BSIOpenBank)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_GUILD_BANK_SELECTED, BSIOpenBank)

EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, BSIInventoryEvent)

EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, BSIItemEvent)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_INVENTORY_BOUGHT_BAG_SPACE, BSIItemEvent)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_INVENTORY_ITEM_DESTROYED, BSIItemEvent)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_INVENTORY_ITEM_USED, BSIItemEvent)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_INVENTORY_BANK_CAPACITY_CHANGED, BSIItemEvent)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_INVENTORY_BOUGHT_BANK_SPACE, BSIItemEvent)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_STABLE_INTERACT_END, BSIItemEvent)

EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_MONEY_UPDATE, BSIMoneyEvent)
EVENT_MANAGER:RegisterForEvent(AddonInfo.addon, EVENT_GUILD_BANKED_MONEY_UPDATE, BSIOpenBank)