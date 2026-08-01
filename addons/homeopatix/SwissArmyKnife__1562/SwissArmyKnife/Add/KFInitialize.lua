-- Initialize Addon File
-- @author    : Homeo
-- @lastModif : 06/01/2017

--------------------
---- INITIALIZE ----
--------------------
function Initialize()
	local stackCountBackpack, stackCountBank = processInventoryData()
	local nbCembers = (stackCountBackpack + stackCountBank)
	local iconRank = ReturnPVPRank()
	local NameHome = ReturnHomePrincipale()
	local isvamp, HasCompVamp, BRV = IsVampire()
	local iswolf, HasCompLoup, BRW = IsWerewolf()


	if(SAK.settings.DISPLAY_AT_START == true) then
		d("*****************************************")
		d(string.format("%s |cff0000Swiss|r|cffffffArmy|r|cff0000Knife|r v%s %s %s",SAK.clefIcon, SAK.version, SAK.lang.KF_INITIALIZED, SAK.clefIcon))

		if(IsNotHuman() ~= nil) then
    			d(string.format("|cFFFFFF%s|r -> %s %s %s %s %s", SAK.playerName, ReturnAlliance(), ReturnRace(), ReturnClass(), "|t80%:80%:".. IsNotHuman() .."|t", iconRank))
    		else
			d(string.format("|cFFFFFF%s|r -> %s %s %s %s", SAK.playerName, ReturnAlliance(), ReturnRace(), ReturnClass(), iconRank))
    		end

		if(isvamp) then
			if(HasCompVamp) then
				if(BRV == -1) then 
					d(string.format("%s !!!!", SAK.lang.KF_VAMP_1))
				else
					timer = BRV - GetTimeStamp()
					timerLabel = ZO_FormatTime(timer, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
					d(string.format("%s |cFFFFFF%s|r",SAK.lang.KF_VAMP_2, timerLabel))
				end
			end
		end


		if(iswolf) then
			if(HasCompLoup) then
				if(BRV == -1) then 
					d(string.format("%s !!!!", SAK.lang.KF_VAMP_3))
				else
					timer = BRV - GetTimeStamp()
					timerLabel = ZO_FormatTime(timer, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
					d(string.format("%s |cFFFFFF%s|r",SAK.lang.KF_VAMP_4, timerLabel))
				end
			end
			
		end

		d(string.format("%s : |cFFFFFF%s|r", SAK.lang.KF_TIME_PLAYED_1, TimePlayed(false)))

		if(stackCountBackpack > 0) then
			d(string.format("%s : |cB114FF%s|r |cFFFFFFx|r %s",SAK.bagIcon, stackCountBackpack, SAK.clefIcon))
		end
		if(stackCountBank > 0) then
			d(string.format("%s : |cB114FF%s|r |cFFFFFFx|r %s",SAK.bankIcon, stackCountBank, SAK.clefIcon))
		end

		if(NameHome ~= "") then
			d(string.format("%s : |cFFFFFF%s|r",SAK.lang.KF_HOUSE_2, NameHome))
		end

		d(string.format("%s |cFFFFFF%s|r %s",SAK.lang.KF_SLASH_20, SAK.settings.MINIMUM_GOLD_SAVINGS, SAK.GoldIcon))
		d(string.format("%s |c5EA4FF%s|r %s",SAK.lang.KF_SLASH_21, SAK.settings.MINIMUM_TELVAR_SAVINGS, SAK.TelVarIcon))
		d(string.format("%s |c33FF33%s|r %s",SAK.lang.KF_ALLI_2, SAK.settings.MINIMUM_ALLIANCE_SAVINGS, SAK.AlliIcon))
		d(string.format("%s |cFF9933%s|r %s",SAK.lang.KF_ALLI_4, SAK.settings.MINIMUM_WRITVOUCHER_SAVINGS, SAK.IconVoucher))
		if(SAK.settings.DISPLAY_REPAIR == true)then
			d(string.format("%s |cFFFFFF%s|r",SAK.lang.KF_AUTO_REPA_1, SAK.lang.KF_AUTO_REPA_13))
		else
			d(string.format("%s |cFFFFFF%s|r",SAK.lang.KF_AUTO_REPA_1, SAK.lang.KF_AUTO_REPA_14))
		end
		if(SAK.settings.DISPLAY_RECHARGE == true)then
			d(string.format("%s |cFFFFFF%s|r",SAK.lang.KF_AUTO_REPA_6, SAK.lang.KF_AUTO_REPA_13))
		else
			d(string.format("%s |cFFFFFF%s|r",SAK.lang.KF_AUTO_REPA_6, SAK.lang.KF_AUTO_REPA_14))
		end
		d(string.format("|cFFFFFF%s|r %s", "/khelp ", SAK.lang.KF_SLASH_2))
		d(string.format("|cFFFFFF%s|r %s", "/klanghelp : ", SAK.lang.KF_LANG_10))
		d(SAK.lang.KF_GOOD)
	else
		d(string.format("%s |cB114FF%s|r v%s %s %s",SAK.clefIcon, "KeyFragment ", SAK.version, SAK.lang.KF_INITIALIZED, SAK.clefIcon))
	end

	--IsNotHuman()

	SAK.settings.ShowStart = false	
	SAK.settings.AT_STATION = false
	SAK.settings.GOLD_CONNECTED = AtConnection(CURT_MONEY)
	SAK.settings.TELVAR_CONNECTED = AtConnection(CURT_TELVAR_STONES)
	SAK.settings.ALLIANCE_CONNECTED = AtConnection(CURT_ALLIANCE_POINTS)

	if(SAK.settings.CONNECTED_TIME ~= GetTimeStamp()) then
		SAK.settings.CONNECTED_TIME = GetTimeStamp()
	end
end


