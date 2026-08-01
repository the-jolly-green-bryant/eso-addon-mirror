-- Update Addon File
-- @author    : Homeo
-- @lastModif : 23/09/2017

--------------------
---- UPDATE UI -----
--------------------


function updateStacksNumber()
    local NomCouper = SAK.playerName
    local lvl, xp, xpn = ReturnLevel()
    local IsHuman, resTime = IsNotHuman()
    local iconRank, rank = ReturnPVPRank()
    local travelCost = GetRecallCost()
    local heat = GetInfoBounty()
    local CoutTotal = RepairCost()
    local xpmanque = xpn-xp
    local poucentage = (xp*100) / xpn
    local colorEnlighted = false
	
    StoneTrans = GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
    WritVouch = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS, CURRENCY_LOCATION_CHARACTER)
   WritVouchBank = GetCurrencyAmount(CURT_WRIT_VOUCHERS, CURRENCY_LOCATION_BANK)

    --local roeBag = GetItemLinkStacks(SAK.roe)
	
    if(string.len(NomCouper) >= 22) then
	NomCouper = string.sub(NomCouper, 0, 22).."..."
    end


--------------------
--- DEBUG ZONE -----
--------------------

    --lvl = 1234

--------------------
-- END DEBUG ZONE --
--------------------
	-- display mount traianing
	DisplayMountTrainingInfo()


	-- display bounty
	local bntyTmp = GetBounty()

	SAK.settings.TOTALSELL, SAK.settings.SELLUSED = GetFenceSellTransactionInfo()
	local RestToSold = SAK.settings.TOTALSELL - SAK.settings.SELLUSED

	if(SAK.settings.bounty > 0) then
		DisplayBountyBar(NomCouper, bntyTmp, heat, RestToSold)
	else
		SwissArmyKnifeContainerBackgroundLabel:SetText(NomCouper)
    		SwissArmyKnifeContainerBackgroundLabel2:SetText(NomCouper)
		SwissArmyKnifeContainerBackgroundLabel:SetColor(255, 255, 255, 255)
			
		if(SAK.settings.DISPLAY_THIEF == true) then
			if(SAK.settings.totalNumberStolen > 0) then
				SwissArmyKnifeContainerBountyTimer:SetColor(255, 255, 255, 255)
				SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s%s/%s   %s%s", SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
			else
				SwissArmyKnifeContainerBountyTimer:SetColor(0, 0, 0, 0)
				SwissArmyKnifeContainerBountyTimer:SetText("")
			end
		end
	end

	-- display Crystal transmute
	if(SAK.settings.DISPLAY_TRANSMUTE == true) then
		SwissArmyKnifeContainerCrystalTransmute:SetText(string.format("|cFFFFFF%s|r %s",StoneTrans, SAK.IconTransmute))
	end

	-- display Writ Voucher
	if(SAK.settings.DISPLAY_WRITVOUCHER == true) then
		SwissArmyKnifeContainerWritVoucher:SetText(string.format("|cFFFFFF%s|r %s",(WritVouch+WritVouchBank), SAK.IconVoucher))
	end

	-- display price travel
	if(SAK.settings.DISPLAY_TRAVEL == true) then
		SwissArmyKnifeContainerLabelCost:SetText(string.format("%s%s |cFFFFFF%s|r",SAK.iconTP, SAK.GoldIcon, travelCost))
	end

	-- display champion lvl
	if(SAK.settings.DISPLAY_CH_PT == true) then
	if(IsUnitChampion("player")) then
		if(GetShownAttribute() == 1) then
			SwissArmyKnifeContainerBackgroundLabel4:SetText(string.format("%s |cF53D00%s|r %s", GetIcon(), lvl, SAK.iconChamp))
			if(SAK.settings.DISPLAY_XP == true) then
				SwissArmyKnifeContainerStatusBarGreen:SetAlpha(0)
				SwissArmyKnifeContainerStatusBarBlue:SetAlpha(0)
				SwissArmyKnifeContainerStatusBarRed:SetAlpha(0.75)
				SwissArmyKnifeContainerStatusBarRed:SetValue(poucentage)
			end
		end
		if(GetShownAttribute() == 2) then
			SwissArmyKnifeContainerBackgroundLabel4:SetText(string.format("%s |c00CCFF%s|r %s", GetIcon(), lvl, SAK.iconChamp))
			if(SAK.settings.DISPLAY_XP == true) then
				SwissArmyKnifeContainerStatusBarGreen:SetAlpha(0)
				SwissArmyKnifeContainerStatusBarBlue:SetAlpha(0.75)
				SwissArmyKnifeContainerStatusBarRed:SetAlpha(0)
				SwissArmyKnifeContainerStatusBarBlue:SetValue(poucentage)
			end
		end
		if(GetShownAttribute() == 3) then
			SwissArmyKnifeContainerBackgroundLabel4:SetText(string.format("%s |c4DFF00%s|r %s", GetIcon(), lvl, SAK.iconChamp))
			if(SAK.settings.DISPLAY_XP == true) then
				SwissArmyKnifeContainerStatusBarGreen:SetAlpha(0.75)
				SwissArmyKnifeContainerStatusBarBlue:SetAlpha(0)
				SwissArmyKnifeContainerStatusBarRed:SetAlpha(0)
				SwissArmyKnifeContainerStatusBarGreen:SetValue(poucentage)
			end
		end
	else
		SwissArmyKnifeContainerBackgroundLabel4:SetText(string.format("%s %s", "lvl", lvl))
		SwissArmyKnifeContainerStatusBarRed:SetAlpha(0.75)
		SwissArmyKnifeContainerStatusBarRed:SetValue(poucentage)
	end
	end

	-- display xp or not
	if(SAK.settings.DISPLAY_XP == true) then
		if(poucentage >= 10) then
			poucentage = string.sub(poucentage, 0, 2)
		else
			poucentage = string.sub(poucentage, 0, 1)
		end

		-- Display enlightning pool bar
		local fullPool = GetEnlightenedPool()
		local test = GetEnlightenedMultiplier()
		local res = fullPool * (test+1)

		if(SAK.settings.DISPLAY_POOLBAR == true) then
			SwissArmyKnifeContainerStatusBarGold:SetAlpha(0.75)
			if(res < xpn)then
				respc = res * 100 / xpn
				SwissArmyKnifeContainerStatusBarGold:SetValue(respc)
			else
				SwissArmyKnifeContainerStatusBarGold:SetValue(res/100)
			end
		else
			SwissArmyKnifeContainerStatusBarGold:SetAlpha(0)
		end
		
		-- Display enlightning pool
		if(SAK.settings.DISPLAY_POOL == false) then
			if(IsEnlightenedAvailableForCharacter("player") and GetEnlightenedPool() > 0) then
				SwissArmyKnifeContainerBackgroundLabel3:SetText(string.format("%s / %s (%s%s) - |cffff00%sxp|r", comma_value(xp), comma_value(xpn), poucentage, "%", comma_value(xpmanque)))
				SwissArmyKnifeContainerStatusBar2:SetValue(100)
				SwissArmyKnifeContainerStatusBar2:SetAlpha(0.3)
			else
				SwissArmyKnifeContainerBackgroundLabel3:SetText(string.format("%s / %s (%s%s) - |cffffff%sxp|r", comma_value(xp), comma_value(xpn), poucentage, "%", comma_value(xpmanque)))
				SwissArmyKnifeContainerStatusBar2:SetValue(100)
				SwissArmyKnifeContainerStatusBar2:SetAlpha(0.3)
			end
		else
			if(IsEnlightenedAvailableForCharacter("player") and GetEnlightenedPool() > 0) then
				SwissArmyKnifeContainerBackgroundLabel3:SetText(string.format("%s / %s (%s%s) - |cffff00%sxp|r", comma_value(xp), comma_value(xpn), poucentage, "%", comma_value(res)))
				SwissArmyKnifeContainerStatusBar2:SetValue(100)
				SwissArmyKnifeContainerStatusBar2:SetAlpha(0.3)
			else
				SwissArmyKnifeContainerBackgroundLabel3:SetText(string.format("%s / %s (%s%s) - |cffffff%sxp|r", comma_value(xp), comma_value(xpn), poucentage, "%", comma_value(res)))
				SwissArmyKnifeContainerStatusBar2:SetValue(100)
				SwissArmyKnifeContainerStatusBar2:SetAlpha(0.3)
			end
		end
	else
		SwissArmyKnifeContainerBackgroundLabel3:SetText(string.format("|cffffff%s|r", NomCouper))
	end



   -- Display icon race, alliance, vampire or werwolf, pvp ... ---------------------   	
    if(IsHuman ~= nil) then
    	SwissArmyKnifeContainerBackgroundLabelIcon4:SetText(string.format("%s %s %s %s %s", ReturnAlliance(), ReturnRace(), ReturnClass(),"|t80%:80%:".. IsNotHuman() .."|t", iconRank))
     	if(resTime ~= 0) then
		SwissArmyKnifeContainerBackgroundLabelIcon5:SetText(string.format("%s", resTime))
		SwissArmyKnifeContainerBackgroundLabelIcon6:SetText(string.format("        %s", rank))
    	end
    else
	SwissArmyKnifeContainerBackgroundLabelIcon4:SetText(string.format("%s %s %s %s", ReturnAlliance(), ReturnRace(), ReturnClass(), iconRank))
	SwissArmyKnifeContainerBackgroundLabelIcon6:SetText(string.format("%s", rank))
    end

	local isvamp, HasCompVamp, BRV = IsVampire()
	local iswolf, HasCompLoup, BRW = IsWerewolf()

	if(isvamp) then
		if(HasCompVamp) then
			if(BRV == -1) then 
				SwissArmyKnifeContainerBackgroundLabelIcon7:SetText("B")
			else
				SwissArmyKnifeContainerBackgroundLabelIcon7:SetText("")
			end
		else
			SwissArmyKnifeContainerBackgroundLabelIcon7:SetText("")
		end
	end


	if(iswolf) then
		if(HasCompLoup) then
			if(BRV == -1) then 
				SwissArmyKnifeContainerBackgroundLabelIcon7:SetText("B")
			else
				SwissArmyKnifeContainerBackgroundLabelIcon7:SetText("")
			end
		else
			SwissArmyKnifeContainerBackgroundLabelIcon7:SetText("")
		end
	end

	-- DISPLAY BAND ADDON --
	WichOneDisplay()
	-- DISPLAY ADDON --

	-- Display gold bag and bank and telvar stone bag and bank
	SwissArmyKnifeContainerGoldLabel:SetText(string.format("%s%s |cFFFF00%s|r", SAK.bankIcon, SAK.GoldIcon, comma_value(GetBankedMoney())))
    	SwissArmyKnifeContainerGoldLabel2:SetText(string.format("%s%s |c5EA4FF%s|r", SAK.bankIcon, SAK.TelVarIcon, comma_value(GetBankedCurrencyAmount(CURT_TELVAR_STONES))))
	SwissArmyKnifeContainerAlliLabel:SetText(string.format("%s%s |c33FF33%s|r", SAK.bankIcon, SAK.AlliIcon, comma_value(GetBankedCurrencyAmount(CURT_ALLIANCE_POINTS))))

    	SwissArmyKnifeContainerTelVarLabel:SetText(string.format("|cFFFF00%s|r %s%s", comma_value(GetCurrentMoney()), SAK.GoldIcon, SAK.bagIcon))
	SwissArmyKnifeContainerAlliLabel2:SetText(string.format("|c33FF33%s|r %s%s", comma_value(GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)), SAK.AlliIcon, SAK.bagIcon))

	local TESTAGE = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)

	if(SAK.settings.DISPLAY_ALARM_TELVAR == true) then
		if(SAK.settings.MAXIMUM_TELVAR_SAVINGS <= TESTAGE) then
			if(SAK.settings.TELVAR_DISPLAY ~= 10) then
				SwissArmyKnifeContainerTelVarLabel2:SetText(string.format("|cFF0000%s|r %s%s", comma_value(GetCarriedCurrencyAmount(CURT_TELVAR_STONES)), SAK.TelVarIcon, SAK.bagIcon))
				SwissArmyKnifeContainerTelVarLabel2:SetColor(255, 0, 0, 255)
				SAK.settings.TELVAR_DISPLAY = SAK.settings.TELVAR_DISPLAY +1
			else
				SwissArmyKnifeContainerTelVarLabel2:SetText(string.format("|c5EA4FF%s|r %s%s", comma_value(GetCarriedCurrencyAmount(CURT_TELVAR_STONES)), SAK.TelVarIcon, SAK.bagIcon))
				SwissArmyKnifeContainerTelVarLabel2:SetColor(255, 0, 0, 0)
				SAK.settings.TELVAR_DISPLAY = 0
			end
		else
			SwissArmyKnifeContainerTelVarLabel2:SetText(string.format("|c5EA4FF%s|r %s%s", comma_value(GetCarriedCurrencyAmount(CURT_TELVAR_STONES)), SAK.TelVarIcon, SAK.bagIcon))
		end
	else
		SwissArmyKnifeContainerTelVarLabel2:SetText(string.format("|c5EA4FF%s|r %s%s", comma_value(GetCarriedCurrencyAmount(CURT_TELVAR_STONES)), SAK.TelVarIcon, SAK.bagIcon))
	end

	-- Display bag & bank size
	if(SAK.settings.DISPLAY_BAGBANK == true) then
		local bagsize = GetBagSize(BAG_BACKPACK)
		local bagsizeleft = GetNumBagUsedSlots(BAG_BACKPACK)
		local banksize = GetBagSize(BAG_BANK)
		local banksizeleft = GetNumBagUsedSlots(BAG_BANK)
		local banksecsize = GetBagSize(BAG_SUBSCRIBER_BANK)
		local banksecsizeleft = GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK)
		local bz = banksize + banksecsize
		local bzl = banksizeleft + banksecsizeleft
		local _, _, nbrJunk = CostJunk()
		
		--display junk
		if(SAK.settings.DISPLAY_JUNK_BAG == true) then
			if((bagsize - bagsizeleft) <= SAK.settings.MIN_BAG_TRESHOLD) then
				SwissArmyKnifeContainerBagSize:SetText(string.format("%s |cF53D00%s|r/|c0080FF%s|r/|cF53D00%s|r   %s/%s %s",SAK.bagIcon, bagsizeleft, nbrJunk, bagsize, bzl, bz, SAK.bankIcon))
		else
				SwissArmyKnifeContainerBagSize:SetText(string.format("%s |cFFFFFF%s|r/|c0080FF%s|r/%s   %s/%s %s",SAK.bagIcon, bagsizeleft, nbrJunk, bagsize, bzl, bz, SAK.bankIcon))
			end
		else
			if((bagsize - bagsizeleft) <= SAK.settings.MIN_BAG_TRESHOLD) then
				SwissArmyKnifeContainerBagSize:SetText(string.format("%s |cF53D00%s|r/|cF53D00%s|r   %s/%s %s",SAK.bagIcon, bagsizeleft, bagsize, bzl, bz, SAK.bankIcon))
		else
				SwissArmyKnifeContainerBagSize:SetText(string.format("%s |cFFFFFF%s|r/%s   %s/%s %s",SAK.bagIcon, bagsizeleft, bagsize, bzl, bz, SAK.bankIcon))
			end
		end
	end

	-- Display Armor
	Display_Armor()

	-- Display weapon  
	Display_Weapon() 
	

	-- Display repair cost
  	if(SAK.settings.DISPLAY_REPAIRCOST == true) then
		if(CoutTotal ~= 0) then
			SwissArmyKnifeContainerCostRepair:SetText(string.format("%s %s %s",SAK.lang.KF_COST_REPAIR,  comma_value(CoutTotal), SAK.GoldIcon))
		else
			SwissArmyKnifeContainerCostRepair:SetText(string.format(" "))
		end
	end

	-- Display time played
	if(SAK.settings.DISPLAY_TIME_PLAYED == true) then
		SwissArmyKnifeContainerTimePlayed:SetText(string.format("%s", TimePlayed(true)))
		SwissArmyKnifeContainerTimePlayedForSession:SetText(PlayedSession())
	end
	
	-- Display session gold
	if(SAK.settings.DISPLAY_SESSION_GOLD == true) then
		local timePH, goldPH = GoldPerHour()
		local TelVarPH, TelVarStonePH = TelVarPerHour()
		local AlliancePH, AlliancePointPH = AlliancePerHour()

		if(SAK.settings.DISPLAY_GOLD == true) then
			SwissArmyKnifeContainerGoldHour:SetText(string.format("%s %s", comma_value(goldPH), SAK.GoldIcon))
			SwissArmyKnifeContainerGoldHourMoy:SetText(string.format("~ %s/%s %s",comma_value(timePH), string.sub(SAK.lang.KF_TIME_PLAYED_4, 2, 2), SAK.GoldIcon))
		end
		if(SAK.settings.DISPLAY_TELVAR == true) then
			SwissArmyKnifeContainerGoldHour:SetText(string.format("%s %s", comma_value(TelVarStonePH), SAK.TelVarIcon))
			SwissArmyKnifeContainerGoldHourMoy:SetText(string.format("~ %s/%s %s",comma_value(TelVarPH), string.sub(SAK.lang.KF_TIME_PLAYED_4, 2, 2), SAK.TelVarIcon))
		end
		if(SAK.settings.DISPLAY_ALLIANCE == true) then
			SwissArmyKnifeContainerGoldHour:SetText(string.format("%s %s", comma_value(AlliancePointPH), SAK.AlliIcon))
			SwissArmyKnifeContainerGoldHourMoy:SetText(string.format("~ %s/%s %s",comma_value(AlliancePH), string.sub(SAK.lang.KF_TIME_PLAYED_4, 2, 2), SAK.AlliIcon))
		end
	end
end	
