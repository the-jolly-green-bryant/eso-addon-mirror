DsRGuildBar = {}
local DsRGuildBar = DsRGuildBar  or {}

DsRGuildBar.name = "DsRGuildBar"

DsRGuildBar.cntItem={
	[30357]={icon="/esoui/art/icons/lockpick.dds",			    lnk="|H1:item:30357:175:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"},	--Lockpick
	[33271]={icon="/esoui/art/icons/soulgem_006_filled.dds",	lnk="|H1:item:33271:31:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"},	--Soulgem
	[44879]={icon="/esoui/art/lfg/lfg_bonus_crate.dds",		    lnk="|H1:item:44879:121:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"},	--Repairkit
}

DsRGuildBar.colors={
	c_no_avail=ZO_ColorDef:New(.25,.25,.25, 1), --#404040  //( 64, 64, 64)  //( 64/255, 64/255, 64/255,1)
	c_disabled=ZO_ColorDef:New(.45,.45,.45, 1), --#737373  //(115,115,115)  //(115/255,115/255,115/255,1)
	c_red_todo=ZO_ColorDef:New(  1,.15,  0, 1), --#ff2600  //(255, 38,  0)  //(255/255, 38/255,  0/255,1)
	c_green_ok=ZO_ColorDef:New(  0,  1,  0, 1), --#00ff00  //(  0,255,  0)  //(  0/255,255/255,  0/255,1)
	c_yellow  =ZO_ColorDef:New(  1,.80,  0, 1), --#ffcc00  //(255,204,  0)  //(255/255,204/255,  0/255,1)
}

DsRGuildBar.hiddenShortly = false

local OffsetXSpaceTXT = ""

-------------------------------------------------------------------------------------------------------------------------------------------------
local function ScoreWindow_Scale()
	DsRGuildBar.SV.BarScale =  DsRGuildBar.SV.BarScale or 0
	local scaleModifier = 1 + ( DsRGuildBar.SV.BarScale/100)
	if DsRGuildBarWindow:GetScale() ~= scaleModifier then DsRGuildBarWindow:SetScale(scaleModifier) end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetTTime(i_ctrl)
	local OStimeH = os.date("%H")
	local OStimeM = os.date("%M")
	local ico=(tonumber(OStimeH)>=6 and tonumber(OStimeH)<18) and 
		zo_iconFormat("/esoui/art/tutorial/cadwell_indexicon_gold_up.dds", 28,28) or 
		zo_iconFormat("/esoui/art/tutorial/cadwell_indexicon_silver_up.dds", 26,26)
	i_ctrl:SetText(string.format('%s%s|cCCCCAA%02d:%02d|r',OffsetXSpaceTXT,ico,OStimeH,OStimeM))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetCrown(i_ctrl)
	local crowns = GetCurrencyAmount(CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT)
	local icon   = zo_iconFormat("/esoui/art/lfg/lfg_leader_icon.dds",28,28)

	i_ctrl:SetText(string.format('%s%s%s',OffsetXSpaceTXT,icon,crowns))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetNumCP(i_ctrl)
	local ico,lvl=" "," "
	if IsUnitChampion('player') then
		--erfrischt?
		if IsEnlightenedAvailableForCharacter() and GetEnlightenedPool()>0 then
			ico=ZO_ColorDef:New(1,1,0,1):Colorize(zo_iconFormatInheritColor("/esoui/art/mainmenu/menubar_champion_down.dds", 28,28))
		else
			ico=zo_iconFormat("/esoui/art/mainmenu/menubar_champion_up.dds",28,28)
		end
		lvl=string.format('|cFFFFCC%s|r',GetPlayerChampionPointsEarned())
	else
		ico=zo_iconFormat("/esoui/art/mainmenu/menubar_skills_up.dds",28,28)
		lvl=string.format('|c7FA292Level:|r |cE8E7E3%s|r',GetUnitLevel("player"))
	end
	i_ctrl:SetText(string.format('%s%s%s',OffsetXSpaceTXT,ico,lvl))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetCntXP(i_ctrl)
	local ico=" "
	local myStatus=GetPlayerStatus()
	if myStatus==PLAYER_STATUS_OFFLINE then
		ico=zo_iconFormat("/esoui/art/tutorial/tutorial_illo_status_offline.dds", 27,26)
	elseif myStatus==PLAYER_STATUS_AWAY then
		ico=zo_iconFormat("/esoui/art/tutorial/tutorial_illo_status_afk.dds", 27,26)
	elseif myStatus==PLAYER_STATUS_DO_NOT_DISTURB then
		ico=zo_iconFormat("/esoui/art/tutorial/tutorial_illo_status_dnd.dds", 27,26)
	else --myStatus==PLAYER_STATUS_ONLINE
		ico=zo_iconFormat("/esoui/art/tutorial/tutorial_illo_status_online.dds", 27,26)
	end	
	local lvl=GetUnitLevel('player')
	local XPcurr,XPnxtCP,XPperc
	if lvl>=50 then
		XPcurr,XPnxtCP=GetPlayerChampionXP(),GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
	else
		XPcurr,XPnxtCP=GetUnitXP('player'),GetUnitXPMax('player')
	end
	if GetPlayerChampionPointsEarned()==3600 and lvl>=50 then
		i_ctrl:SetText(string.format('%s%s',OffsetXSpaceTXT,ico))
	else
		-- if DsRGuildBar.SV.showXPperc then
			-- XPperc=math.floor((math.floor(XPcurr*100/XPnxtCP*2) + 1)/2)
			-- i_ctrl:SetText(string.format('%s|cDEDEDE%s|r|cA0A0CF|u2:1::/|u%s|r |cDEDEDE(%s%%)|r',ico,zo_strformat(SI_NUMBER_FORMAT,XPcurr),zo_strformat(SI_NUMBER_FORMAT,XPnxtCP),XPperc))
		-- else
			i_ctrl:SetText(string.format('%s%s|cDEDEDE%s|r|cA0A0CF|u2:1::/|u%s|r',OffsetXSpaceTXT,ico,zo_strformat(SI_NUMBER_FORMAT,XPcurr),zo_strformat(SI_NUMBER_FORMAT,XPnxtCP)))
		-- end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetFillGrade(i_ctrl,i_invType)
	local ico=(i_invType==INVENTORY_BACKPACK) and 
		zo_iconFormat("/esoui/art/tooltips/icon_bag.dds",19,19) or
		zo_iconFormat("/esoui/art/tooltips/icon_bank.dds",19,19)
	local numUsedSlots,numSlots = PLAYER_INVENTORY:GetNumSlots(i_invType)

	if (numSlots-numUsedSlots)<=0 then
		i_ctrl:SetColor(1,0,0,1)
	elseif (numSlots-numUsedSlots)<=10 then
		i_ctrl:SetColor(1,1,0,1)
	else
		i_ctrl:SetColor(0,1,0,1)
	end
	if i_invType==INVENTORY_BACKPACK then
		if DsRGuildBar.SV.BarInventoryspace == 2 then
			i_ctrl:SetText(string.format('%s%s%s|cBFBFBF|u2:1::|u|r',OffsetXSpaceTXT,ico,numUsedSlots))
		elseif DsRGuildBar.SV.BarInventoryspace == 3 then
			i_ctrl:SetText(string.format('%s%s%s|cBFBFBF|u2:1::/|u|r|cDEDEDE%s|r',OffsetXSpaceTXT,ico,numUsedSlots,numSlots))
		end
	end
	if i_invType==INVENTORY_BANK then
		if DsRGuildBar.SV.BarBankspace == 2 then
			i_ctrl:SetText(string.format('%s%s%s|cBFBFBF|u2:1::|u|r',OffsetXSpaceTXT,ico,numUsedSlots))
		elseif DsRGuildBar.SV.BarBankspace == 3 then
			i_ctrl:SetText(string.format('%s%s%s|cBFBFBF|u2:1::/|u|r|cDEDEDE%s|r',OffsetXSpaceTXT,ico,numUsedSlots,numSlots))
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetKrusch(i_ctrl,i_id,i_X,i_Y)
	local ico=zo_iconFormat(DsRGuildBar.cntItem[i_id].icon,i_X,i_Y)
	local invCnt,bankCnt,crftBagCnt=GetItemLinkStacks(DsRGuildBar.cntItem[i_id].lnk)
	if invCnt==0 then
		i_ctrl:SetColor(1,.7,.7,1)
	elseif i_id==54200 then
		i_ctrl:SetColor(.76,.56,.94,1)
	else
		i_ctrl:SetColor(.87,.87,.87,1)
	end
	i_ctrl:SetText(string.format('%s%s%s',OffsetXSpaceTXT,ico,invCnt))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetStolen(i_ctrl)
	local ico=""
	local bag=SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK)
	local stolenItems=0
	for _, data in pairs(bag) do
		if IsItemStolen(data.bagId,data.slotIndex) then 
			stolenItems=stolenItems+GetSlotStackSize(data.bagId,data.slotIndex) 
		end
	end
	local maxSell,curSell,_=GetFenceSellTransactionInfo()
	local maxLaun,curLaun,_=GetFenceLaunderTransactionInfo()
	local canSell=maxSell-curSell
	local canLaun=maxLaun-curLaun
	local combined=""
	if stolenItems>0 then
		stolenItems=tostring(stolenItems)
		ico=DsRGuildBar.colors.c_red_todo:Colorize(zo_iconFormatInheritColor("/esoui/art/inventory/inventory_stolenitem_icon.dds",20,20))
		if canSell~=maxSell or canLaun~=maxLaun then combined=string.format("|c999999|u1:0::(%s/%s)|u|r",canSell,canLaun) end
		i_ctrl:SetText(string.format("%s%s|cCCCCAA%s|r%s",OffsetXSpaceTXT,ico,stolenItems,combined))
	else
		stolenItems=""
		i_ctrl:SetText("")
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetMyCurr(i_ctrl,currencyType,i_X,i_Y)
	local location=(currencyType==CURT_CHAOTIC_CREATIA or currencyType==CURT_UNDAUNTED_KEYS or 
					currencyType==CURT_ENDEAVOR_SEALS or 
					currencyType==CURT_ENDLESS_DUNGEON or currencyType==CURT_IMPERIAL_FRAGMENTS or
					currencyType==CURT_TOME_CHALLENGE_REROLLS or currencyType==CURT_TOME_POINTS or
					currencyType==CURT_TOME_POINT_CACHES or currencyType==CURT_TOME_TOKENS or
					currencyType==CURT_TRADE_BARS) and CURRENCY_LOCATION_ACCOUNT or CURRENCY_LOCATION_CHARACTER
	local currBag  = GetCurrencyAmount(currencyType,location)
	local currBank = DsRglobals:ThousandNumber(GetBankedCurrencyAmount(currencyType))

	local xmuteWarn,xmuteMax=950,1000
	local ico=""
	local hlpTxt,hlpTxt2="",""

	--icon-mod
	if currencyType==CURT_ALLIANCE_POINTS then
		ico=GetColoredAvARankIconMarkup(GetUnitAvARank("player"),GetUnitAlliance("player"),i_X)
	else
		ico=zo_iconFormat(GetCurrencyKeyboardIcon(currencyType),i_X,i_Y)
	end

	--text-mod
	if currencyType==CURT_CHAOTIC_CREATIA then
		if IsESOPlusSubscriber() then xmuteWarn=2950	xmuteMax=3000 end
		hlpTxt=string.format("|cA0A0CF|u2:1::|r")
		hlpTxt2=""
	elseif currencyType==CURT_WRIT_VOUCHERS then
		if DsRGuildBar.SV.BarWritvoucher == 2 then
			hlpTxt=""
		elseif DsRGuildBar.SV.BarWritvoucher == 3 then
			hlpTxt=string.format("|cA0A0CF|u2:1::/|u|r%s",currBank)
		end
		hlpTxt2=""
	elseif currencyType==CURT_TELVAR_STONES then
		if DsRGuildBar.SV.BarTelVar == 2 then
			hlpTxt=""
		elseif DsRGuildBar.SV.BarTelVar == 3 then
			hlpTxt=string.format("|cA0A0CF|u2:1::/|u|r%s",currBank)
		end
		hlpTxt2=""
	elseif currencyType==CURT_ALLIANCE_POINTS then
		if DsRGuildBar.SV.BarAP == 2 then
			hlpTxt=""
		elseif DsRGuildBar.SV.BarAP == 3 then
			hlpTxt=string.format("|cA0A0CF|u2:1::/|u|r%s",currBank)
		end
		hlpTxt2=""
	elseif currencyType==CURT_MONEY then
		if DsRGuildBar.SV.BarGold == 2 then
			hlpTxt=""
		elseif DsRGuildBar.SV.BarGold == 3 then
			hlpTxt=string.format("|cA0A0CF|u2:1::/|u|r%s",currBank)
		end
		hlpTxt2=""
	end

	--color-mod
	-- if currencyType==CURT_EVENT_TICKETS and currBag>9 then 
	-- 	i_ctrl:SetColor(1,0,0,1) 
	if currencyType==CURT_CHAOTIC_CREATIA and currBag>=xmuteWarn then	
		i_ctrl:SetColor(1,0,0,1) 
	elseif currencyType==CURT_ALLIANCE_POINTS then
		i_ctrl:SetColor(.65,1,.76,1)
	else
		i_ctrl:SetColor(1,1,.76,1)
	end

	i_ctrl:SetText(string.format('%s%s%s|u1:0::%s|u%s',OffsetXSpaceTXT,ico,hlpTxt2,zo_strformat(SI_NUMBER_FORMAT,currBag),hlpTxt))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildBar.Toolbar_Update()
	--- Hintergrund -------------------------------------------------
	if DsRGuildBar.SV.BarBG then
		DsRGuildBarWindowBG:SetHidden(false)
		DsRGuildBarWindowBG:SetAlpha(DsRGuildBar.SV.BarBGtrans / 100)
	else
		DsRGuildBarWindowBG:SetHidden(true)
	end

	--- Zeit -------------------------------------------------
	if DsRGuildBar.SV.BarOStime then 
		DsRGuildBarWindowInfo01:SetHidden(false)
		GetTTime(DsRGuildBarWindowInfo01)
	else
		DsRGuildBarWindowInfo01:SetHidden(true)
		DsRGuildBarWindowInfo01:SetText("")
	end

	--- Spielerinfos -----------------------------------------
	if DsRGuildBar.SV.BarCrowns then 
		DsRGuildBarWindowInfo02:SetHidden(false)
		GetCrown(DsRGuildBarWindowInfo02)
	else
		DsRGuildBarWindowInfo02:SetHidden(true)
		DsRGuildBarWindowInfo02:SetText("")
	end
	if DsRGuildBar.SV.BarCP then 
		DsRGuildBarWindowInfo03:SetHidden(false)
		GetNumCP(DsRGuildBarWindowInfo03)
	else
		DsRGuildBarWindowInfo03:SetHidden(true)
		DsRGuildBarWindowInfo03:SetText("")
	end
	if DsRGuildBar.SV.BarshowXP then 
		DsRGuildBarWindowInfo04:SetHidden(false)
		GetCntXP(DsRGuildBarWindowInfo04)
	else
		DsRGuildBarWindowInfo04:SetHidden(true)
		DsRGuildBarWindowInfo04:SetText("")
	end
	
	--- Platz ------------------------------------------------
	if DsRGuildBar.SV.BarInventoryspace ~= 1 then 
		DsRGuildBarWindowInfo05:SetHidden(false)
		GetFillGrade(DsRGuildBarWindowInfo05, INVENTORY_BACKPACK)
	else
		DsRGuildBarWindowInfo05:SetHidden(true)
		DsRGuildBarWindowInfo05:SetText("")
	end
	if DsRGuildBar.SV.BarBankspace ~= 1 then 
		DsRGuildBarWindowInfo06:SetHidden(false)
		GetFillGrade(DsRGuildBarWindowInfo06, INVENTORY_BANK)
	else
		DsRGuildBarWindowInfo06:SetHidden(true)
		DsRGuildBarWindowInfo06:SetText("")
	end
	
	--- Währungen --------------------------------------------
	if DsRGuildBar.SV.BarGold ~= 1 then 
		DsRGuildBarWindowInfo07:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo07, CURT_MONEY, 17,17)
	else
		DsRGuildBarWindowInfo07:SetHidden(true)
		DsRGuildBarWindowInfo07:SetText("")
	end
	if DsRGuildBar.SV.BarAP ~= 1 then 
		DsRGuildBarWindowInfo08:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo08, CURT_ALLIANCE_POINTS, 23, 0)
	else
		DsRGuildBarWindowInfo08:SetHidden(true)
		DsRGuildBarWindowInfo08:SetText("")
	end
	if DsRGuildBar.SV.BarTelVar ~= 1 then 
		DsRGuildBarWindowInfo09:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo09, CURT_TELVAR_STONES, 21,21)
	else
		DsRGuildBarWindowInfo09:SetHidden(true)
		DsRGuildBarWindowInfo09:SetText("")
	end
	if DsRGuildBar.SV.BarWritvoucher ~= 1 then 
		DsRGuildBarWindowInfo10:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo10, CURT_WRIT_VOUCHERS, 21,21)
	else
		DsRGuildBarWindowInfo10:SetHidden(true)
		DsRGuildBarWindowInfo10:SetText("")
	end
	-- if DsRGuildBar.SV.BarEticket then 
	-- 	DsRGuildBarWindowInfo11:SetHidden(false)
	-- 	GetMyCurr(DsRGuildBarWindowInfo11, CURT_EVENT_TICKETS, 21,21)
	-- else
		DsRGuildBarWindowInfo11:SetHidden(true)
		DsRGuildBarWindowInfo11:SetText("")
	-- end
	if DsRGuildBar.SV.BarTransmute then 
		DsRGuildBarWindowInfo12:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo12, CURT_CHAOTIC_CREATIA, 18,18)
	else
		DsRGuildBarWindowInfo12:SetHidden(true)
		DsRGuildBarWindowInfo12:SetText("")
	end
	if DsRGuildBar.SV.BarUndaunted then 
		DsRGuildBarWindowInfo13:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo13, CURT_UNDAUNTED_KEYS, 21,21)
	else
		DsRGuildBarWindowInfo13:SetHidden(true)
		DsRGuildBarWindowInfo13:SetText("")
	end
	if DsRGuildBar.SV.BarEndeavor then 
		DsRGuildBarWindowInfo14:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo14, CURT_ENDEAVOR_SEALS, 21,19)
	else
		DsRGuildBarWindowInfo14:SetHidden(true)
		DsRGuildBarWindowInfo14:SetText("")
	end
	if DsRGuildBar.SV.BarImperialFragements then 
		DsRGuildBarWindowInfo15:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo15, CURT_IMPERIAL_FRAGMENTS, 23,19)
	else
		DsRGuildBarWindowInfo15:SetHidden(true)
		DsRGuildBarWindowInfo15:SetText("")
	end
	if DsRGuildBar.SV.BarEndless then 
		DsRGuildBarWindowInfo16:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo16, CURT_ENDLESS_DUNGEON, 19,19)
	else
		DsRGuildBarWindowInfo16:SetHidden(true)
		DsRGuildBarWindowInfo16:SetText("")
	end
	if DsRGuildBar.SV.BaromeChallenge then 
		DsRGuildBarWindowInfo17:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo17, CURT_TOME_CHALLENGE_REROLLS, 19,19)
	else
		DsRGuildBarWindowInfo17:SetHidden(true)
		DsRGuildBarWindowInfo17:SetText("")
	end
	if DsRGuildBar.SV.BarTomePoints then 
		DsRGuildBarWindowInfo18:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo18, CURT_TOME_POINTS, 19,19)
	else
		DsRGuildBarWindowInfo18:SetHidden(true)
		DsRGuildBarWindowInfo18:SetText("")
	end
	if DsRGuildBar.SV.BarTomePointCach then 
		DsRGuildBarWindowInfo19:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo19, CURT_TOME_POINT_CACHES, 19,19)
	else
		DsRGuildBarWindowInfo19:SetHidden(true)
		DsRGuildBarWindowInfo19:SetText("")
	end
	if DsRGuildBar.SV.BarTomeToken then 
		DsRGuildBarWindowInfo20:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo20, CURT_TOME_TOKENS, 19,19)
	else
		DsRGuildBarWindowInfo20:SetHidden(true)
		DsRGuildBarWindowInfo20:SetText("")
	end
	if DsRGuildBar.SV.BarTradeBars then 
		DsRGuildBarWindowInfo21:SetHidden(false)
		GetMyCurr(DsRGuildBarWindowInfo21, CURT_TRADE_BARS, 19,19)
	else
		DsRGuildBarWindowInfo21:SetHidden(true)
		DsRGuildBarWindowInfo21:SetText("")
	end
	--- Inventar ---------------------------------------------
	if DsRGuildBar.SV.BarLockpicks then 
		DsRGuildBarWindowInfo22:SetHidden(false)
		GetKrusch(DsRGuildBarWindowInfo22, 30357, 20,20)	--Lockpick
	else
		DsRGuildBarWindowInfo22:SetHidden(true)
		DsRGuildBarWindowInfo22:SetText("")
	end
	if DsRGuildBar.SV.BarSoulGems then 
		DsRGuildBarWindowInfo23:SetHidden(false)
		GetKrusch(DsRGuildBarWindowInfo23, 33271, 20,19)	--Soulgem
	else
		DsRGuildBarWindowInfo23:SetHidden(true)
		DsRGuildBarWindowInfo23:SetText("")
	end
	if DsRGuildBar.SV.BarRepairKits then 
		DsRGuildBarWindowInfo24:SetHidden(false)
		GetKrusch(DsRGuildBarWindowInfo24, 44879, 20,20)	--Repairkit
	else
		DsRGuildBarWindowInfo24:SetHidden(true)
		DsRGuildBarWindowInfo24:SetText("")
	end

	if DsRGuildBar.SV.BarStolen then 
		DsRGuildBarWindowInfo25:SetHidden(false)
		GetStolen(DsRGuildBarWindowInfo25)
	else
		DsRGuildBarWindowInfo25:SetHidden(true)
		DsRGuildBarWindowInfo25:SetText("")
	end
	
    DsRGuildBar.totalWidth=15
	local myControls={
		[1]  = DsRGuildBarWindowInfo01,
		[2]  = DsRGuildBarWindowInfo02,
        [3]  = DsRGuildBarWindowInfo03,
        [4]  = DsRGuildBarWindowInfo04,
		[5]  = DsRGuildBarWindowInfo05,
        [6]  = DsRGuildBarWindowInfo06,
        [7]  = DsRGuildBarWindowInfo07,
        [8]  = DsRGuildBarWindowInfo08,
		[9]  = DsRGuildBarWindowInfo09,
        [10] = DsRGuildBarWindowInfo10,
        [11] = DsRGuildBarWindowInfo11,
        [12] = DsRGuildBarWindowInfo12,
		[13] = DsRGuildBarWindowInfo13,
        [14] = DsRGuildBarWindowInfo14,
        [15] = DsRGuildBarWindowInfo15,
        [16] = DsRGuildBarWindowInfo16,
		[17] = DsRGuildBarWindowInfo17,
        [18] = DsRGuildBarWindowInfo18,
        [19] = DsRGuildBarWindowInfo19,
		[20] = DsRGuildBarWindowInfo20,
		[21] = DsRGuildBarWindowInfo21,
		[22] = DsRGuildBarWindowInfo22,
		[23] = DsRGuildBarWindowInfo23,
		[24] = DsRGuildBarWindowInfo24,
		[25] = DsRGuildBarWindowInfo25,
	}
	for i,ctrl in ipairs(myControls) do
		local _, _, _, _, x, _, _=ctrl:GetAnchor(0)
		DsRGuildBar.totalWidth = DsRGuildBar.totalWidth+ctrl:GetTextWidth()+x
	end

	DsRGuildBarWindow:SetWidth(DsRGuildBar.totalWidth)
	if DsRGuildBar.SV.BarPosition == 1 then
		DsRGuildBarWindow:ClearAnchors()
		DsRGuildBarWindow:SetAnchor(TOP, GuiRoot, TOP, 0, 0)
	else
		DsRGuildBarWindow:ClearAnchors()
		DsRGuildBarWindow:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, 0)
	end

	ScoreWindow_Scale()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function OnCurrencyUpdate(event,currencyType,currencyLocation,newAmount,oldAmount,reason)
	if currencyType==CURT_MONEY then
		GetMyCurr(DsRGuildBarWindowInfo07, currencyType, 17,17)
	elseif currencyType==CURT_ALLIANCE_POINTS then
		GetMyCurr(DsRGuildBarWindowInfo08, currencyType, 23, 0)
	elseif currencyType==CURT_WRIT_VOUCHERS then
		GetMyCurr(DsRGuildBarWindowInfo10, currencyType, 21,21)
	elseif currencyType==CURT_CHAOTIC_CREATIA then
		GetMyCurr(DsRGuildBarWindowInfo12, currencyType, 18,18)
	elseif currencyType==CURT_UNDAUNTED_KEYS then
		GetMyCurr(DsRGuildBarWindowInfo13, currencyType, 21,21)
	-- elseif currencyType==CURT_EVENT_TICKETS then
	-- 	GetMyCurr(DsRGuildBarWindowInfo11, currencyType, 21,21)
	elseif currencyType==CURT_ENDEAVOR_SEALS then
		GetMyCurr(DsRGuildBarWindowInfo14, currencyType, 21,19)
	elseif currencyType==CURT_IMPERIAL_FRAGMENTS then
		GetMyCurr(DsRGuildBarWindowInfo15, currencyType, 23,19)
	elseif currencyType==CURT_TELVAR_STONES then
		GetMyCurr(DsRGuildBarWindowInfo09, currencyType, 21,21)
	elseif currencyType==CURT_ENDLESS_DUNGEON then
		GetMyCurr(DsRGuildBarWindowInfo16, currencyType, 19,19)
	elseif currencyType==CURT_TOME_CHALLENGE_REROLLS then
		GetMyCurr(DsRGuildBarWindowInfo17, currencyType, 19,19)
	elseif currencyType==CURT_TOME_POINTS then
		GetMyCurr(DsRGuildBarWindowInfo18, currencyType, 19,19)
	elseif currencyType==CURT_TOME_POINT_CACHES then
		GetMyCurr(DsRGuildBarWindowInfo19, currencyType, 19,19)
	elseif currencyType==CURT_TOME_TOKENS then
		GetMyCurr(DsRGuildBarWindowInfo20, currencyType, 19,19)
	elseif currencyType==CURT_TRADE_BARS then
		GetMyCurr(DsRGuildBarWindowInfo21, currencyType, 19,19)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildBar.SetHiddenShortly(hidden)
    local oldStatus = DsRGuildBar.hiddenShortly
    DsRGuildBar.hiddenShortly = hidden
	DsRGuildBarWindow:SetHidden(hidden)
    if DsRGuildBar.hiddenShortly ~= oldStatus then DsRGuildBar.Toolbar_Update() end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildBar.OnAddonLoaded(event, addonName)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildBar.name, EVENT_ADD_ON_LOADED) 
	
    if DsRGuildBar.SV.BarOnOff then
		local OffsetXSpace = DsRGuildBar.SV.BarOffSetX or 0
		
		for a = 1, OffsetXSpace do
			OffsetXSpaceTXT = OffsetXSpaceTXT .. " "
		end

		local refreshSeconds = DsRGuildBar.SV.BarRefreshTimer * 1000
		DsRGuildBar.Toolbar_Update()
		EVENT_MANAGER:RegisterForUpdate("DsRGuildBarToolbar_Update", refreshSeconds, DsRGuildBar.Toolbar_Update)
        EVENT_MANAGER:RegisterForEvent(DsRGuildBar.name, EVENT_CURRENCY_UPDATE, OnCurrencyUpdate)
		DsRGuildBarWindow:SetHidden(false)

		if DsRGuildBar.SV.BarMenueHide then
		    -- hide listeners
			ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
				DsRGuildBar.SetHiddenShortly(true)
			end)
			ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
				DsRGuildBar.SetHiddenShortly(true)
			end)
			-- ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
				-- DsRGuildBar.SetHiddenShortly(true)
			-- end)
			ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
				DsRGuildBar.SetHiddenShortly(true)
			end)
		
			-- show listeners
			ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
				DsRGuildBar.SetHiddenShortly(false)
			end)
			ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function()
				DsRGuildBar.SetHiddenShortly(false)
			end)
			-- ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function()
			-- 	DsRGuildBar.SetHiddenShortly(false)
			-- end)
			ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function()
				DsRGuildBar.SetHiddenShortly(false)
			end)
		end
	else
        EVENT_MANAGER:UnregisterForEvent(DsRGuildBar.name, EVENT_CURRENCY_UPDATE)
		DsRGuildBarWindow:SetHidden(true)
	end
end
