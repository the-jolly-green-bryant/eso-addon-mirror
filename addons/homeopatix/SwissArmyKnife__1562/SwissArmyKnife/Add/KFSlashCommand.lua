-- SlashCommand Addon File
-- @author    : Homeo
-- @lastModif : 06/01/2017

--------------------
-- SLASH-COMMANDS --
--------------------

function setGold(valueGold)
	SAK.settings.MINIMUM_GOLD_SAVINGS = tonumber(valueGold)
	d(string.format("%s |cFFFFFF%s|r %s",SAK.lang.KF_SLASH_20, tonumber(valueGold), SAK.GoldIcon))
end

function setBagSizeTreshold(valueBag)
	SAK.settings.MIN_BAG_TRESHOLD = tonumber(valueBag)
end

function setSeuil(valueSeuil)
	SAK.settings.SEUIL_REPAIR = tonumber(valueSeuil)
	d(string.format("%s |cFFFFFF%s|r %s",SAK.lang.KF_SEUIL_REP_5, tonumber(valueSeuil), "%"))
	updateUI()
end

function setSeuil_arm(valueSeuil_arm)
	SAK.settings.SEUIL_REPAIR_ARM = tonumber(valueSeuil_arm)
	d(string.format("%s |cFFFFFF%s|r %s",SAK.lang.KF_SEUIL_REPA_5, tonumber(valueSeuil_arm), "%"))
	updateUI()
end

function setSeuilAutoCharge(valueSeuil)
	SAK.settings.SEUIL_CHARGE_AUTO = tonumber(valueSeuil)
	d(string.format("%s |cFFFFFF%s|r %s",SAK.lang.KF_AUTO_REPA_11, tonumber(valueSeuil), "%"))
	updateUI()
end

function setStonesAlarm(valueStones)
	SAK.settings.MAXIMUM_TELVAR_SAVINGS = tonumber(valueStones)
end

function setStonesAlliance(valueStones)
	SAK.settings.MINIMUM_ALLIANCE_SAVINGS = tonumber(valueStones)
	d(string.format("%s |c33FF33%s|r %s",SAK.lang.KF_ALLI_2, tonumber(valueStones), SAK.AlliIcon))
end


function setStones(valueStones)
	SAK.settings.MINIMUM_TELVAR_SAVINGS = tonumber(valueStones)
	d(string.format("%s |c5EA4FF%s|r %s",SAK.lang.KF_SLASH_21, tonumber(valueStones), SAK.TelVarIcon))
end

function setWritVoucher(valueStones)
	SAK.settings.MINIMUM_WRITVOUCHER_SAVINGS = tonumber(valueStones)
	d(string.format("%s |cFF9933%s|r %s",SAK.lang.KF_ALLI_4, tonumber(valueStones), SAK.IconVoucher))
end

function Help()
	d("*****************************************")
	d(string.format("%s %s |cff0000Swiss|r|cffffffArmy|r|cff0000Knife|r %s",SAK.clefIcon, SAK.lang.KF_SLASH_1, SAK.clefIcon))
	d(string.format("|cFFFFFF%s|r %s", "/khelp : ", SAK.lang.KF_SLASH_2))
	d(string.format("|cFFFFFF%s|r %s", "/klanghelp : ", SAK.lang.KF_LANG_10))
	d(string.format("|cFFFFFF%s|r %s", "/kshow : ", SAK.lang.KF_SLASH_3))
	d(string.format("|cFFFFFF%s|r %s", "/khide : ", SAK.lang.KF_SLASH_4))
	d(string.format("|cFFFFFF%s|r %s %s %s", "/kall : ", SAK.lang.KF_SLASH_5, SAK.clefIcon, SAK.lang.KF_SLASH_5_2))
	d(string.format("|cFFFFFF%s|r %s", "/knone : ", SAK.lang.KF_SLASH_7))
	d(string.format("|cFFFFFF%s|r %s", "/ksetgold xxxx : ", SAK.lang.KF_SLASH_18))
	d(string.format("|cFFFFFF%s|r %s", "/ksetstones xxxx : ", SAK.lang.KF_SLASH_19))
	d(string.format("|cFFFFFF%s|r %s", "/kfs : ", SAK.lang.KF_SETTINGS_3))
	d(string.format("|cFFFFFF%s|r %s", "/kgl : ", SAK.lang.KF_SLASH_22))
	d(string.format("|cFFFFFF%s|r %s", "/krep xxx : ", SAK.lang.KF_SEUIL_REP_4))
	d(string.format("|cFFFFFF%s|r %s", "/krepa xxx : ", SAK.lang.KF_SEUIL_REPA_4))
	d(string.format("|cFFFFFF%s|r %s", "/kreset : ", SAK.lang.KF_STATS_2))
	d(string.format("|cFFFFFF%s|r %s", "/kj : ", SAK.lang.KF_HOUSE_3))
	d(string.format("|cFFFFFF%s|r %s", "/kb : ", SAK.lang.KF_HOUSE_6))
	d("*****************************************")
end

function HelpLang()
	d("*****************************************")
	d(string.format("%s %s |cff0000Swiss|r|cffffffArmy|r|cff0000Knife|r %s",SAK.clefIcon, SAK.lang.KF_SLASH_11, SAK.clefIcon))
	d(string.format("|cFFFFFF%s|r %s", "/klanghelp : ", SAK.lang.KF_SLASH_2))
	d("*************** GROUP *******************")
	d(string.format("|cFFFFFF%s|r %s", "/kh TEXT : ", SAK.lang.KF_LANG_1))
	d(string.format("|cFFFFFF%s|r %s", "/kt TEXT : ", SAK.lang.KF_LANG_2))
	d("*************** FRIEND ******************")
	d(string.format("|cFFFFFF%s|r %s", "/kr TEXT : ", SAK.lang.KF_LANG_3))
	d("*************** GUILD *******************")
	d(string.format("|cFFFFFF%s|r %s", "/kg1 TEXT : ", SAK.lang.KF_LANG_4))
	d(string.format("|cFFFFFF%s|r %s", "/kg2 TEXT : ", SAK.lang.KF_LANG_5))
	d(string.format("|cFFFFFF%s|r %s", "/kg3 TEXT : ", SAK.lang.KF_LANG_6))
	d(string.format("|cFFFFFF%s|r %s", "/kg4 TEXT : ", SAK.lang.KF_LANG_7))
	d(string.format("|cFFFFFF%s|r %s", "/kg5 TEXT : ", SAK.lang.KF_LANG_8))
	d("*****************************************")
end

function ShowKey()
    	SwissArmyKnifeContainer:SetHidden(false)
	SAK.settings.MUST_BE_SHOWN = true
end

function HideKey()
    	SwissArmyKnifeContainer:SetHidden(true)
	SAK.settings.MUST_BE_SHOWN = false
	
end

function DisplayAll()
	d(string.format("%s %s %s", SAK.lang.KF_SLASH_8, SAK.clefIcon, SAK.lang.KF_SLASH_8_2))
	SAK.settings.SHOW_KEY_ALL = true
	
end

function DisplayNone()
	d(string.format("%s %s %s %s %s", SAK.lang.KF_SLASH_10, SAK.clefIcon, SAK.lang.KF_SLASH_10_2, SAK.clefBis, SAK.lang.KF_SLASH_10_3))
	SAK.settings.SHOW_KEY_ALL = false
	
end

function GetOutOfGroup()
	if IsUnitGrouped("player") then
		d(SAK.lang.KF_SLASH_24)
		GroupLeave()
	else
		d(SAK.lang.KF_SLASH_23)
	end
end

----------------------------
-- SLASH COMMANDS TO CHAT --
----------------------------
function SayHello(valueText1)
	if IsUnitGrouped("player") then
		if(valueText1 ~= "") then
			SAK.settings.SAY_HELLO = valueText1
		end
	CHAT_SYSTEM:StartTextEntry("/g "..SAK.settings.SAY_HELLO, channel, target)
	else
		d(SAK.lang.KF_SLASH_23)
	end
end

function SayThanks(valueText2)
	if IsUnitGrouped("player") then
		if(valueText2 ~= "") then
			SAK.settings.SAY_THANKS = valueText2
		end
	CHAT_SYSTEM:StartTextEntry("/g "..SAK.settings.SAY_THANKS, channel, target)
	else
		d(SAK.lang.KF_SLASH_23)
	end
end

function SayPlop(valueText3)
	if(valueText3 ~= "") then
		SAK.settings.SAY_PLOP = valueText3
	end
	CHAT_SYSTEM:StartTextEntry("/r "..SAK.settings.SAY_PLOP, channel, target)
end

function SayGuild1(valueText4)
	if(valueText4 ~= "") then
		SAK.settings.SAY_GUILD_1 = valueText4
	end
	CHAT_SYSTEM:StartTextEntry("/guild1 " ..SAK.settings.SAY_GUILD_1, channel, target)
end
function SayGuild2(valueText4)
	if(valueText4 ~= "") then
		SAK.settings.SAY_GUILD_2 = valueText4
	end
	CHAT_SYSTEM:StartTextEntry("/guild2 " ..SAK.settings.SAY_GUILD_2, channel, target)
end
function SayGuild3(valueText4)
	if(valueText4 ~= "") then
		SAK.settings.SAY_GUILD_3 = valueText4
	end
	CHAT_SYSTEM:StartTextEntry("/guild3 " ..SAK.settings.SAY_GUILD_3, channel, target)
end
function SayGuild4(valueText4)
	if(valueText4 ~= "") then
		SAK.settings.SAY_GUILD_4 = valueText4
	end
	CHAT_SYSTEM:StartTextEntry("/guild4 " ..SAK.settings.SAY_GUILD_4, channel, target)
end
function SayGuild5(valueText4)
	if(valueText4 ~= "") then
		SAK.settings.SAY_GUILD_5 = valueText4
	end
	CHAT_SYSTEM:StartTextEntry("/guild5 " ..SAK.settings.SAY_GUILD_5, channel, target)
end

function resetGold()
	local bank = GetBankedMoney()
	local bag = GetCurrentMoney()
	local goldTotal = bank + bag

	SAK.settings.GOLD_CONNECTED = goldTotal
	SAK.settings.CONNECTED_TIME = GetTimeStamp()

	d(string.format("!! %s !!", SAK.lang.KF_STATS_3))

	updateUI()
end

local function GetHouseName(houseId)
        local collectibleId = GetCollectibleIdForHouse(houseId)
        local houseName = GetCollectibleInfo(collectibleId)
        return houseName
end

function ReturnHomePrincipale()
	local home = GetHousingPrimaryHouse()
	local Name = ""

	if(home ~= nil) then
		Name = GetHouseName(home)
	end

	return Name 
end

function JollyJumper()
	home = GetHousingPrimaryHouse()

	SAK.settings.BASE_HOME = GetHouseName(home)

	if(IsInCyrodiil() or IsInImperialCity() or IsInAvAZone()) then
		d(string.format("%s", SAK.lang.KF_HOUSE_5))
	else
		d(string.format("!! %s |cffffff%s|r !!", SAK.lang.KF_HOUSE_4, SAK.settings.BASE_HOME))

		if(RequestJumpToHouse(home)) then
			JumpToHouse(SAK.settings.BASE_HOME)
		end
	end
end

function DisplayJunk()
	local itemPrice, stackTotal = CostJunk()

	if(itemPrice ~= 0)then
		d(string.format("%s %s pour %s %s", stackTotal, SAK.lang.KF_JUNK_3, itemPrice, SAK.GoldIcon))
	else
		d(SAK.lang.KF_JUNK_2)
	end
end

function ChangeBandeau()
	if(SAK.settings.Display_Bandeau == 1)then
		SAK.settings.DISPLAY_DEADRIC = true
		SAK.settings.DISPLAY_POTION = false
		SAK.settings.DISPLAY_SOULGEM = false
		SAK.settings.DISPLAY_WRIT = false
		SAK.settings.DISPLAY_COMBAT_POPO = false
		SAK.settings.DISPLAY_STEALING = false
		SAK.settings.Display_Bandeau = 2
		WichOneDisplay()
		return
	end
	if(SAK.settings.Display_Bandeau == 2)then
		SAK.settings.DISPLAY_DEADRIC = false
		SAK.settings.DISPLAY_POTION = true
		SAK.settings.DISPLAY_SOULGEM = false
		SAK.settings.DISPLAY_WRIT = false
		SAK.settings.DISPLAY_COMBAT_POPO = false
		SAK.settings.DISPLAY_STEALING = false
		SAK.settings.Display_Bandeau = 3
		WichOneDisplay()
		return
	end
	if(SAK.settings.Display_Bandeau == 3)then
		SAK.settings.DISPLAY_DEADRIC = false
		SAK.settings.DISPLAY_POTION = false
		SAK.settings.DISPLAY_SOULGEM = true
		SAK.settings.DISPLAY_WRIT = false
		SAK.settings.DISPLAY_COMBAT_POPO = false
		SAK.settings.DISPLAY_STEALING = false
		SAK.settings.Display_Bandeau = 4
		WichOneDisplay()
		return
	end
	if(SAK.settings.Display_Bandeau == 4)then
		SAK.settings.DISPLAY_DEADRIC = false
		SAK.settings.DISPLAY_POTION = false
		SAK.settings.DISPLAY_SOULGEM = false
		SAK.settings.DISPLAY_WRIT = true
		SAK.settings.DISPLAY_COMBAT_POPO = false
		SAK.settings.DISPLAY_STEALING = false
		SAK.settings.Display_Bandeau = 5
		WichOneDisplay()
		return
	end
	if(SAK.settings.Display_Bandeau == 5)then
		SAK.settings.DISPLAY_DEADRIC = false
		SAK.settings.DISPLAY_POTION = false
		SAK.settings.DISPLAY_SOULGEM = false
		SAK.settings.DISPLAY_WRIT = false
		SAK.settings.DISPLAY_COMBAT_POPO = true
		SAK.settings.DISPLAY_STEALING = false
		SAK.settings.Display_Bandeau = 6
		WichOneDisplay()
		return
	end
	if(SAK.settings.Display_Bandeau == 6)then
		SAK.settings.DISPLAY_DEADRIC = false
		SAK.settings.DISPLAY_POTION = false
		SAK.settings.DISPLAY_SOULGEM = false
		SAK.settings.DISPLAY_WRIT = false
		SAK.settings.DISPLAY_COMBAT_POPO = false
		SAK.settings.DISPLAY_STEALING = true
		SAK.settings.Display_Bandeau = 1
		WichOneDisplay()
		return
	end
end

SLASH_COMMANDS["/khelp"] = Help
SLASH_COMMANDS["/kshow"] = ShowKey
SLASH_COMMANDS["/khide"] = HideKey
SLASH_COMMANDS["/kall"] = DisplayAll
SLASH_COMMANDS["/knone"] = DisplayNone
SLASH_COMMANDS["/ksetgold"] = setGold
SLASH_COMMANDS["/ksetstones"] = setStones
SLASH_COMMANDS["/kgl"] = GetOutOfGroup
SLASH_COMMANDS["/krep"] = setSeuil
SLASH_COMMANDS["/krepa"] = setSeuil_arm
SLASH_COMMANDS["/kjunk"] = DisplayJunk
SLASH_COMMANDS["/kb"] = ChangeBandeau

SLASH_COMMANDS["/kreset"] = resetGold

-- slash command to talk to group and friends
SLASH_COMMANDS["/klanghelp"] = HelpLang
SLASH_COMMANDS["/kh"] = SayHello
SLASH_COMMANDS["/kt"] = SayThanks
SLASH_COMMANDS["/kr"] = SayPlop
SLASH_COMMANDS["/kg1"] = SayGuild1
SLASH_COMMANDS["/kg2"] = SayGuild2
SLASH_COMMANDS["/kg3"] = SayGuild3
SLASH_COMMANDS["/kg4"] = SayGuild4
SLASH_COMMANDS["/kg5"] = SayGuild5

-- slash command for house
SLASH_COMMANDS["/kj"] = JollyJumper


