function DSDB.CreateMainWindowControl()
	local width = 300

	--------------------------------------------------------------------------------
	-- CREATE MAIN WINDOW IN XML
	--------------------------------------------------------------------------------
	DSDB.cMainWindow = WINDOW_MANAGER:CreateTopLevelWindow("DSDBWindow")
	DSDB.cMainWindow:SetDimensions(width , 56) 
	DSDB.cMainWindow:SetMovable(not DSDB.locked)
	DSDB.cMainWindow:SetMouseEnabled(not DSDB.locked)	

	
	--------------------------------------------------------------------------------
	-- TOP CONTROL
	--------------------------------------------------------------------------------
	DSDB.topRow = WINDOW_MANAGER:CreateControl("DSDBTop", DSDB.cMainWindow, CT_CONTROL)
	DSDB.topRow:SetDimensions(width,25)
	DSDB.topRow:SetAnchor(TOPLEFT , DSDB.cMainWindowBackground, TOPLEFT )
	--------------------------------------------------------------------------------
	-- DIVIDER BETWEEN ROWS
	--------------------------------------------------------------------------------
	DSDB.topRow.divider = WINDOW_MANAGER:CreateControl("DSDBtopDivider", DSDB.topRow, CT_TEXTURE)
	DSDB.topRow.divider:SetTexture("/esoui/art/miscellaneous/horizontaldivider.dds")
	DSDB.topRow.divider:SetAnchor( TOPLEFT, DSDB.topRow, BOTTOMLEFT, -60 , 2 )
    DSDB.topRow.divider:SetAnchor( TOPRIGHT , DSDB.topRow, BOTTOMRIGHT, 60 , 2 )
    DSDB.topRow.divider:SetHeight(4)
	--------------------------------------------------------------------------------
	-- BOTTOM CONTROL
	--------------------------------------------------------------------------------
	DSDB.bottomRow = WINDOW_MANAGER:CreateControl("DSDBbottom", DSDB.cMainWindow, CT_CONTROL)
	DSDB.bottomRow:SetDimensions(width,25)
	DSDB.bottomRow:SetAnchor(BOTTOMLEFT , DSDB.cMainWindowBackground, BOTTOMLEFT )
	
	--------------------------------------------------------------------------------
	-- TOP ROW
	--------------------------------------------------------------------------------

	DSDB.Time = WINDOW_MANAGER:CreateControl("DSDBTime", DSDB.topRow, CT_CONTROL)
	DSDB.Time:SetDimensions(60,25)
	DSDB.Time.Label = WINDOW_MANAGER:CreateControl("DSDBTimeLabel", DSDB.Time, CT_LABEL)	
	DSDB.Time.Label:SetFont("ZoFontGame")
	DSDB.Time.Label:SetText("00:00:00")
	DSDB.Time:SetAnchor(TOPLEFT , DSDB.topRow, TOPLEFT )
	DSDB.Time.Label:SetAnchor(LEFT , DSDB.Time, LEFT )
	
	DSDB.transmute = WINDOW_MANAGER:CreateControl("DSDBTransmutes", DSDB.topRow, CT_CONTROL)
	DSDB.transmute:SetDimensions(50,25)
	DSDB.transmute.Texture = WINDOW_MANAGER:CreateControl("DSDBTransmutesIcon", DSDB.transmute, CT_TEXTURE)	
	DSDB.transmute.Texture:SetTexture("/esoui/art/currency/icon_seedcrystal.dds")
	DSDB.transmute.Texture:SetDimensions(24,24)
	DSDB.transmute.Label = WINDOW_MANAGER:CreateControl("DSDBTransmutesLabel", DSDB.transmute, CT_LABEL)
	DSDB.transmute.Label:SetFont("ZoFontGame")
	DSDB.transmute.Label:SetText(GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT))
	DSDB.transmute:SetAnchor(LEFT , DSDB.Time, RIGHT )
	DSDB.transmute.Texture:SetAnchor(LEFT,DSDB.transmute,LEFT,0,0 )
	DSDB.transmute.Label:SetAnchor(LEFT,DSDB.transmute.Texture,RIGHT,2,0 )
	
	DSDB.gold = WINDOW_MANAGER:CreateControl("DSDBGold", DSDB.topRow, CT_CONTROL)
	DSDB.gold:SetDimensions(80,25)
	DSDB.gold.Texture = WINDOW_MANAGER:CreateControl("DSDBGoldIcon", DSDB.gold, CT_TEXTURE)	
	DSDB.gold.Texture:SetTexture("/esoui/art/icons/item_generic_coinbag.dds")
	DSDB.gold.Texture:SetDimensions(24,24)
	DSDB.gold.Label = WINDOW_MANAGER:CreateControl("DSDBGoldLabel", DSDB.gold, CT_LABEL)
	DSDB.gold.Label:SetFont("ZoFontGame")
	DSDB.gold.Label:SetText(GetCurrencyAmount(CURT_MONEY,CURRENCY_LOCATION_CHARACTER))
	DSDB.gold:SetAnchor(LEFT , DSDB.transmute, RIGHT )
	DSDB.gold.Texture:SetAnchor(LEFT,DSDB.gold,LEFT,0,0 )
	DSDB.gold.Label:SetAnchor(LEFT,DSDB.gold.Texture,RIGHT,2,0 )
	
	DSDB.ticket = WINDOW_MANAGER:CreateControl("DSDBTicket", DSDB.topRow, CT_CONTROL)
	DSDB.ticket:SetDimensions(62,25)
	DSDB.ticket.Texture = WINDOW_MANAGER:CreateControl("DSDBTicketdIcon", DSDB.ticket, CT_TEXTURE)	
	DSDB.ticket.Texture:SetTexture("/esoui/art/currency/u49_tt_tradebars.dds")
	DSDB.ticket.Texture:SetDimensions(24,24)
	DSDB.ticket.Label = WINDOW_MANAGER:CreateControl("DSDBTicketLabel", DSDB.ticket, CT_LABEL)
	DSDB.ticket.Label:SetFont("ZoFontGame")
	DSDB.ticket.Label:SetText(GetCurrencyAmount(CURT_TRADE_BARS,CURRENCY_LOCATION_ACCOUNT))
	DSDB.ticket:SetAnchor(LEFT , DSDB.gold, RIGHT )
	DSDB.ticket.Texture:SetAnchor(LEFT,DSDB.ticket,LEFT,0,0 )
	DSDB.ticket.Label:SetAnchor(LEFT,DSDB.ticket.Texture,RIGHT,2,0 )
	
	DSDB.key = WINDOW_MANAGER:CreateControl("DSDBKeys", DSDB.topRow, CT_CONTROL)
	DSDB.key:SetDimensions(50,25)
	DSDB.key.Texture = WINDOW_MANAGER:CreateControl("DSDBKeysIcon", DSDB.key, CT_TEXTURE)	
	DSDB.key.Texture:SetTexture("/esoui/art/currency/undauntedkey_mipmap.dds")
	DSDB.key.Texture:SetDimensions(24,24)
	DSDB.key.Label = WINDOW_MANAGER:CreateControl("DSDBKeysLabel", DSDB.key, CT_LABEL)
	DSDB.key.Label:SetFont("ZoFontGame")
	DSDB.key.Label:SetText(GetCurrencyAmount(CURT_UNDAUNTED_KEYS,CURRENCY_LOCATION_ACCOUNT))
	DSDB.key:SetAnchor(LEFT , DSDB.ticket, RIGHT, 2, 0 )
	DSDB.key.Texture:SetAnchor(LEFT,DSDB.key,LEFT,0,0 )
	DSDB.key.Label:SetAnchor(LEFT,DSDB.key.Texture,RIGHT,2,0 )
	
	--------------------------------------------------------------------------------
	-- BOTTOM ROW
	--------------------------------------------------------------------------------
	DSDB.fps = WINDOW_MANAGER:CreateControl("DSDBFps", DSDB.topRow, CT_CONTROL)
	DSDB.fps:SetDimensions(50,25)
	DSDB.fps.Label = WINDOW_MANAGER:CreateControl("DSDBFpsLabel", DSDB.fps, CT_LABEL)
	DSDB.fps.Label:SetFont("ZoFontGame")
	DSDB.fps.Label:SetText("999 fps")
	DSDB.fps:SetAnchor(BOTTOMLEFT , DSDB.bottomRow, BOTTOMLEFT )
	DSDB.fps.Label:SetAnchor(LEFT , DSDB.fps, LEFT )
	
	DSDB.ping = WINDOW_MANAGER:CreateControl("DSDBPing", DSDB.topRow, CT_CONTROL)
	DSDB.ping:SetDimensions(70,25)
	DSDB.ping.Texture = WINDOW_MANAGER:CreateControl("DSDBPingIcon", DSDB.ping, CT_TEXTURE)	
	DSDB.ping.Texture:SetTexture("/esoui/art/campaign/campaignbrowser_hipop.dds")
	DSDB.ping.Texture:SetDimensions(24,24)
	DSDB.ping.Label = WINDOW_MANAGER:CreateControl("DSDBPingLabel", DSDB.ping, CT_LABEL)
	DSDB.ping.Label:SetFont("ZoFontGame")
	DSDB.ping.Label:SetText("999 ms")
	DSDB.ping:SetAnchor(LEFT , DSDB.fps, RIGHT )
	DSDB.ping.Texture:SetAnchor(LEFT,DSDB.ping,LEFT,0,0 )
	DSDB.ping.Label:SetAnchor(LEFT,DSDB.ping.Texture,RIGHT,0,0 )
	
	DSDB.inventory = WINDOW_MANAGER:CreateControl("DSDBInventory", DSDB.topRow, CT_CONTROL)
	DSDB.inventory:SetDimensions(80,25)
	DSDB.inventory.Texture = WINDOW_MANAGER:CreateControl("DSDBInventoryIcon", DSDB.inventory, CT_TEXTURE)	
	DSDB.inventory.Texture:SetTexture("/esoui/art/tutorial/menubar_inventory_up.dds")
	DSDB.inventory.Texture:SetDimensions(24,24)
	DSDB.inventory.Label = WINDOW_MANAGER:CreateControl("DSDBInventoryLabel", DSDB.inventory, CT_LABEL)
	DSDB.inventory.Label:SetFont("ZoFontGame")
	DSDB.inventory.Label:SetText(GetNumBagUsedSlots(BAG_BACKPACK).."/"..GetBagSize(BAG_BACKPACK))
	DSDB.inventory:SetAnchor(LEFT , DSDB.ping, RIGHT )
	DSDB.inventory.Texture:SetAnchor(LEFT,DSDB.inventory,LEFT,0,0 )
	DSDB.inventory.Label:SetAnchor(LEFT,DSDB.inventory.Texture,RIGHT,0,0 )
	
	DSDB.bank = WINDOW_MANAGER:CreateControl("DSDBBank", DSDB.topRow, CT_CONTROL)
	DSDB.bank:SetDimensions(80,25)
	DSDB.bank.Texture = WINDOW_MANAGER:CreateControl("DSDBBankIcon", DSDB.bank, CT_TEXTURE)	
	DSDB.bank.Texture:SetTexture("/esoui/art/icons/servicemappins/servicepin_bank.dds")
	DSDB.bank.Texture:SetDimensions(24,24)
	DSDB.bank.Label = WINDOW_MANAGER:CreateControl("DSDBBankLabel", DSDB.bank, CT_LABEL)
	DSDB.bank.Label:SetFont("ZoFontGame")
	if IsESOPlusSubscriber() then
		DSDB.bank.Label:SetText(GetNumBagUsedSlots(BAG_BANK)+GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK).."/"..GetBagSize(BAG_SUBSCRIBER_BANK)+GetBagSize(BAG_BANK))
	else
		DSDB.bank.Label:SetText(GetNumBagUsedSlots(BAG_BANK)+GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK).."/"..GetBagSize(BAG_BANK))	
	end
	DSDB.bank:SetAnchor(LEFT , DSDB.inventory, RIGHT )
	DSDB.bank.Texture:SetAnchor(LEFT,DSDB.bank,LEFT,0,0 )
	DSDB.bank.Label:SetAnchor(LEFT,DSDB.bank.Texture,RIGHT,2,0 )
		

end