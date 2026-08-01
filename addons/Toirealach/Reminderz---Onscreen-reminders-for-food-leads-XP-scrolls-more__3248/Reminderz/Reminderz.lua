-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Top level namespace
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

Reminderz = Reminderz or {}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Define some variables that are global to the namespace
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

Reminderz.name = "Reminderz"
Reminderz.version = "1.10.3"
Reminderz.displayName = "|cF8D25FReminderz|r"
Reminderz.author = "|c00FF00Teebow Ganx|r"
Reminderz.website = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"
Reminderz.donation = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"

Reminderz.SavedVariablesName = Reminderz.name.."SavedVars"
Reminderz.savedVarsVersion = 2

Reminderz.debug = false				-- Do NOT turn debug on unless you know what you're doing
Reminderz.inPvPZone = nil			-- Are we in a PvP Zone?
Reminderz.VengeanceID = 124			-- campaignID of Vengeance PvP Test

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Libraries
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local LAM2 = LibAddonMenu2 --This global variable LibAddonMenu2 only exists with LAM version 2.0 r28 or higher!

local LCLSTR = Reminderz.Localization

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Saved Variables Defaults
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local defaults = {

	accountWide = false,
	whisperOfflineWarning = true,
	suppressLoaded = false,
	bagRemind = 1,
	autoDailyReward = true,
	checkGear = false,
	remindersToChat = true,
	trackAchievements = true, 

	vampStage = 0,
	vampRemindPVPOnly = false,
	vampDontRemindInHouses = false,
	vampRemindInterval = 1,
	vampFirstReminder = 3,
	vampRemindColor = Colorz.red:ToHex(),

	foodRemind = true,
	foodRemindPVPOnly = false,
	foodDontRemindInHouses = false,
	foodOnlyRemindInDungeons = false,
	foodRemindInterval = 1,
	foodFirstReminder = 3,
	foodRemindColor = Colorz.yellow:ToHex(),

	xpRemind = false,
	xpRemindPVPOnly = false,
	xpDontRemindInHouses = false,
	xpRemindInterval = 1,
	xpFirstReminder = 3,
	xpRemindColor = Colorz.lightBlue:ToHex(),

	telvarRemind = 0,
	telvarAutoDeposit = true,
	telvarReserveAmount = 0,

	apRemind = false,
	apRemindPVPOnly = false,
	apDontRemindInHouses = false,
	apRemindInterval = 1,
	apFirstReminder = 3,
	apRemindColor = Colorz.lightOrange:ToHex(),

	leadsDaysUntilExpire = 1,
	leadsRemindColor = Colorz.gold:ToHex(),
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Functions to send messages to the chat console 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local ESOChatConsole = {}

function ESOChatConsole.msg(theMsg, inColor)
	inColor = inColor or Colorz.yellow
	theMsg = inColor:Colorize(theMsg)
	zo_callLater(function() d(theMsg) end, 300)
end

function ESOChatConsole.debugMsg(theMsg)
	if Reminderz.debug == false then return end
	theMsg = Colorz.gray:Colorize(theMsg)
	theMsg = ColoColorz.yellow:Colorize(string.format("%s_DEBUG: ", Reminderz.name))..theMsg
	zo_callLater(function() d(theMsg) end, 300)
end

-- Stage at which player wants to be reminded that Vamp will run out
-- or that they need to go get a bite.

local function CheckVampReminder()

	local remindStage = Reminderz.settings.vampStage
	local inPvP = PlayerIsInPvP()

	-- If in Vengeance PvP then don't remind
	if inPvP == true and GetCurrentCampaignId() == Reminderz.VengeanceID then remindStage = 0 end

	if remindStage > 0 then
		if Reminderz.settings.vampRemindPVPOnly == true then
			if inPvP == false then remindStage = 0 end
		end
	end
	
	if remindStage == 0 then
		VampReminder.Stop()
	else
		VampReminder.dontRemindInHouses = Reminderz.settings.vampDontRemindInHouses
		local remindInterval = Reminderz.settings.vampRemindInterval * 60
		VampReminder.Start(remindStage, remindInterval, Reminderz.settings.vampFirstReminder, Reminderz.vampRemindColor)
	end
end

-- If player wants to be reminded that food will run out

local function CheckFoodReminder()

	local remind = Reminderz.settings.foodRemind
	local inPvP = PlayerIsInPvP()

	-- If in Vengeance PvP then don't remind
	if inPvP == true and GetCurrentCampaignId() == Reminderz.VengeanceID then remind = false end

	if remind == true and Reminderz.settings.foodRemindPVPOnly == true then remind = inPvP end

	if remind == true and inPvP == false then
		if Reminderz.settings.foodOnlyRemindInDungeons == true then
			remind = (GetMapContentType() == MAP_CONTENT_DUNGEON)
		elseif Reminderz.settings.foodDontRemindInHouses == true then
			remind = (GetCurrentZoneHouseId() == 0)
		end		
	end

	if remind == true then 
		local remindInterval = Reminderz.settings.foodRemindInterval * 60
		FoodReminder.Start(remindInterval, Reminderz.settings.foodFirstReminder, Reminderz.foodRemindColor)
	else
		FoodReminder.Stop() 
	end
	
end

-- If player wants to be reminded that their XP scroll will run out

local function CheckXPReminder()

	local remind = Reminderz.settings.xpRemind
	local inPvP = PlayerIsInPvP()
	-- If in Vengeance PvP then don't remind
	if inPvP == true and GetCurrentCampaignId() == Reminderz.VengeanceID then remind = false end

	if remind == true and Reminderz.settings.xpRemindPVPOnly == true then remind = inPvP end

	if remind == true then 
		XPReminder.dontRemindInHouses = Reminderz.settings.xpDontRemindInHouses
		local remindInterval = Reminderz.settings.xpRemindInterval * 60
		XPReminder.Start(remindInterval, Reminderz.settings.xpFirstReminder, Reminderz.xpRemindColor)
	else
		XPReminder.Stop() 
	end
end

-- If player wants to be reminded that their War Torte will run out

local function CheckAPReminder()

	local remind = Reminderz.settings.apRemind
	local inPvP = PlayerIsInPvP()
	-- If in Vengeance PvP then don't remind
	if inPvP == true and GetCurrentCampaignId() == Reminderz.VengeanceID then remind = false end

	if remind == true and Reminderz.settings.apRemindPVPOnly == true then remind = inPvP end

	if remind == true then 
		APReminder.dontRemindInHouses = Reminderz.settings.apDontRemindInHouses
		local remindInterval = Reminderz.settings.apRemindInterval * 60
		APReminder.Start(remindInterval, Reminderz.settings.apFirstReminder, Reminderz.apRemindColor)
	else
		APReminder.Stop() 
	end

end

-- local reminders that don't need a TBO_Reminder object

local function SendReminder(inMsgTitle, inMsgSubHeading)

	if not inMsgSubHeading then 
		CSAnnounce.Major(inMsgTitle)
	else
		CSAnnounce.Large(inMsgTitle, inMsgSubHeading)
	end

	if Reminderz.settings.remindersToChat ~= false then
		local remindStr = inMsgTitle
		if inMsgSubHeading ~= nil then remindStr = remindStr.." "..inMsgSubHeading end
		d(Reminderz.name..": "..remindStr)
	end
end

-- Get free bag space
-- If below free slots setting, put up a reminder

local lastBagRemind = 0

local function CheckFreeBagSpace()
	local freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)
	if freeSlots < Reminderz.settings.bagRemind then
		local currTime = GetGameTimeMilliseconds()
		if (currTime - lastBagRemind) < 8000 then return end -- Remind only once every 8 seconds
		-- Do a CSA
		local bagStr = LCLSTR.LOW_BAG_SPACE
		if freeSlots == 0 then bagStr = LCLSTR.NO_BAG_SPACE end
		local remindStr = Colorz.white:Colorize(bagStr)
		SendReminder(remindStr)
		lastBagRemind = currTime
	end
end

local function CheckTelvarReminder()
	local telvar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	if Reminderz.settings.telvarRemind > 0 and telvar >= Reminderz.settings.telvarRemind then
		local remindStr = Colorz.telvar:Colorize(string.format(LCLSTR.TELVAR_CAP_REACHED, telvar))
		SendReminder(remindStr)
	end
end

local function CheckDailyReward()
	if Reminderz.settings.autoDailyReward and GetDailyLoginClaimableRewardIndex() then
		local remindStr = "Claiming Daily Login Reward"
		SendReminder(remindStr)
		ClaimCurrentDailyLoginReward()
	end
end

local function CheckAchievementTracking()
	if Reminderz.settings.trackAchievements == true then
		EVENT_MANAGER:RegisterForEvent(	Reminderz.name, EVENT_ACHIEVEMENT_UPDATED, Reminderz.EVENT_ACHIEVEMENT_UPDATED)
		EVENT_MANAGER:RegisterForEvent(	Reminderz.name, EVENT_ACHIEVEMENT_AWARDED, Reminderz.EVENT_ACHIEVEMENT_AWARDED)
	else
		EVENT_MANAGER:UnregisterForEvent(Reminderz.name, EVENT_ACHIEVEMENT_UPDATED)
		EVENT_MANAGER:UnregisterForEvent(Reminderz.name, EVENT_ACHIEVEMENT_AWARDED)
	end
end

local function GetCurrentMundus()

	for n = 0, GetNumBuffs("player") do
		local buffName, _, _, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("player", n)
		if (abilityId == 13979) then return MUNDUS_STONE_APPRENTICE, buffName end
		if (abilityId == 13982) then return MUNDUS_STONE_ATRONACH, buffName end
		if (abilityId == 13976) then return MUNDUS_STONE_LADY, buffName end
		if (abilityId == 13978) then return MUNDUS_STONE_LORD, buffName end
		if (abilityId == 13981) then return MUNDUS_STONE_LOVER, buffName end
		if (abilityId == 13943) then return MUNDUS_STONE_MAGE, buffName end
		if (abilityId == 13980) then return MUNDUS_STONE_RITUAL, buffName end
		if (abilityId == 13974) then return MUNDUS_STONE_SERPENT, buffName end
		if (abilityId == 13984) then return MUNDUS_STONE_SHADOW, buffName end
		if (abilityId == 13977) then return MUNDUS_STONE_STEED, buffName end
		if (abilityId == 13975) then return MUNDUS_STONE_THIEF, buffName end
		if (abilityId == 13985) then return MUNDUS_STONE_TOWER, buffName end
		if (abilityId == 13940) then return MUNDUS_STONE_WARRIOR, buffName end
	end

	return MUNDUS_STONE_INVALID, nil

end

local function CheckMundus()

	-- If in Vengeance PvP then don't remind
	if PlayerIsInPvP() == true and GetCurrentCampaignId() == Reminderz.VengeanceID then return end

	local mundus, name = GetCurrentMundus()
	if mundus == MUNDUS_STONE_INVALID then 
		local remindStr = Colorz.white:Colorize(LCLSTR.NO_MUNDUS)
		SendReminder(remindStr)
	end
end

local missingGearStr = nil

local function IsMissingArmor()

	missingGearStr = nil

	local armorSlots = {
		EQUIP_SLOT_HEAD,
		EQUIP_SLOT_SHOULDERS,
		EQUIP_SLOT_CHEST,
		EQUIP_SLOT_HAND,
		EQUIP_SLOT_WAIST,
		EQUIP_SLOT_LEGS,
		EQUIP_SLOT_FEET,
	}
	for k, slot in pairs(armorSlots) do
		local icon, hasItem, sellPrice, isHeldSlot, isHeldNow, isLocked = GetEquippedItemInfo(slot)
		if hasItem == false then 
			missingGearStr = LCLSTR.ARMOR_MISSING
			return true 
		end
	end
	return false
end

local function IsMissingJewelry()

	missingGearStr = nil

	local jewelrySlots = {
		EQUIP_SLOT_NECK,
		EQUIP_SLOT_RING1,
		EQUIP_SLOT_RING2,
	}

	for k, slot in pairs(jewelrySlots) do
		local icon, hasItem, sellPrice, isHeldSlot, isHeldNow, isLocked = GetEquippedItemInfo(slot)
		if hasItem == false then 
			missingGearStr = LCLSTR.JEWELRY_MISSING
			return true 
		end
	end

	return false
end

local OAKENSOUL_RING_ID = 187658
local function isWearingOakensoul() -- Is either ring the Oakensoul ring?
	local ringID = GetItemId(BAG_WORD, EQUIP_SLOT_RING1)
	if ringID == OAKENSOUL_RING_ID then return true end
	ringID = GetItemId(BAG_WORD, EQUIP_SLOT_RING2)
	if ringID == OAKENSOUL_RING_ID then return true end
	return false
end

local function IsOneHander(weaponType)
	if weaponType == WEAPONTYPE_AXE then return true
	elseif weaponType == WEAPONTYPE_DAGGER then return true
	elseif weaponType == WEAPONTYPE_HAMMER then return true
	elseif weaponType == WEAPONTYPE_SWORD then return true
	elseif weaponType == WEAPONTYPE_SHIELD then return true
	else return false end
end

local function IsTwoHander(weaponType)
	if weaponType == WEAPONTYPE_BOW then return true
	elseif weaponType == WEAPONTYPE_FIRE_STAFF then return true
	elseif weaponType == WEAPONTYPE_FROST_STAFF then return true
	elseif weaponType == WEAPONTYPE_HEALING_STAFF then return true
	elseif weaponType == WEAPONTYPE_LIGHTNING_STAFF then return true
	elseif weaponType == WEAPONTYPE_TWO_HANDED_AXE then return true
	elseif weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then return true
	elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD then return true
	else return false end
end

local FRONT_BAR = false
local BACK_BAR = true
local function BarIsMissingWeapons(checkBackBar)

	local mainHand = EQUIP_SLOT_MAIN_HAND
	local offHand = EQUIP_SLOT_OFF_HAND
	local backup = nil
	if checkBackBar == true then
		mainHand = EQUIP_SLOT_BACKUP_MAIN
		offHand = EQUIP_SLOT_BACKUP_OFF
		backup = LCLSTR.BACKUP
	end

	missingGearStr = nil

	local weaponType = GetItemWeaponType(BAG_WORN, mainHand)
	if weaponType == WEAPONTYPE_NONE then -- main hand empty when shouldn't be
		missingGearStr = LCLSTR.MAIN_HAND
	elseif IsTwoHander(weaponType) == true then return false -- Two hand weapon uses both slots
	else 
		weaponType = GetItemWeaponType(BAG_WORN, offHand)
		if weaponType == WEAPONTYPE_NONE then -- off hand empty when shouldn't be
			missingGearStr = LCLSTR.OFF_HAND
		end
	end 

	if missingGearStr ~= nil then
		if backup ~= nil then missingGearStr = missingGearStr..backup end
		missingGearStr = missingGearStr..LCLSTR.WEAPON_MISSING
		return true
	end
	return false
end

local function IsMissingWeapons()

	-- Check front bar
	if BarIsMissingWeapons(FRONT_BAR) == true then return true end

	-- Front bar weapon slots filled, if wearing oakensoul we're done.
	if isWearingOakensoul() == true then return false end

	-- Check back bar
	if BarIsMissingWeapons(BACK_BAR) == true then return true end

	return false
end

local lastGearRemind = 0
local function IsMissingGear()
	
	local missingGear = IsMissingArmor()
	if missingGear == false then missingGear = IsMissingJewelry() end
	if missingGear == false then missingGear = IsMissingWeapons() end

	local poisonSlots = { -- If we ever want to check to see if poisons are slotted
		EQUIP_SLOT_POISON,
		EQUIP_SLOT_BACKUP_POISON,
	}
	local tabardSlot = EQUIP_SLOT_COSTUME -- If we ever want to check to see tabard is slotted

	if missingGear == true then
		-- Remind them to put on armor & weapons
		local currTime = GetGameTimeMilliseconds()
		if (currTime - lastGearRemind) < 8000 then return end -- Remind only once every 8 seconds
		-- Do a CSA
		missingGearStr = Colorz.lightYellow:Colorize(missingGearStr)
		SendReminder(missingGearStr)
		lastGearRemind = currTime
		missingGearStr = nil
	end
end

local function CheckMissingGear()
	if Reminderz.settings.checkGear == true then
		IsMissingGear()
	end
end

local expiringLeads = nil
local secsInADay = 24 * 60 * 60
local expiringLeadStr = nil

local function CheckExpiringLeads()

	if Reminderz.settings.leadsDaysUntilExpire == 0 or expiringLeads ~= nil then return end

	expiringLeads = {}

	local minExpireTimeSecs = Reminderz.settings.leadsDaysUntilExpire * secsInADay
	local antiquityId = nil

	repeat 
		antiquityId = GetNextAntiquityId(antiquityId)
		if (antiquityId ~= nil) then
			local leadTimeRemaining = GetAntiquityLeadTimeRemainingSeconds(antiquityId)
			if leadTimeRemaining > 0 and leadTimeRemaining < minExpireTimeSecs then
				local expiringLead = {Id = antiquityId, name = GetAntiquityName(antiquityId), remainSecs = leadTimeRemaining}
				table.insert(expiringLeads, expiringLead)
			end
		end
	until (antiquityId == nil)
	
	if #expiringLeads == 0 then return end

	local messageTitle = LCLSTR.LEADS_EXPIRING_FMT_MULTI
	local longestLeadTime = 0
	for _, lead in pairs(expiringLeads) do
		if lead.remainSecs > longestLeadTime then longestLeadTime = lead.remainSecs end
	end

	local messageSubheading = string.format(LCLSTR.LEADS_EXPIRING_FMT_MULTI2, ZO_FormatTimeLargestTwo(longestLeadTime, TIME_FORMAT_STYLE_DESCRIPTIVE))

	if #expiringLeads == 1 then -- only one lead expiring
		messageTitle = zo_strformat(SI_ANTIQUITY_NAME_FORMATTER, expiringLeads[1].name)
		messageSubheading = zo_strformat(SI_ANTIQUITY_TOOLTIP_LEAD_EXPIRATION, ZO_FormatTimeLargestTwo(longestLeadTime, TIME_FORMAT_STYLE_DESCRIPTIVE))
	end

	messageTitle = Reminderz.leadsRemindColor:Colorize(messageTitle)
	messageSubheading = Reminderz.leadsRemindColor:Colorize(messageSubheading)

	SendReminder(messageTitle, messageSubheading)
end
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Slash Commands --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local slashCommand = {}

function slashCommand.Help()
	ESOChatConsole.msg(" ")
	ESOChatConsole.msg("/reminderz food [on/off/pvp]'")
	ESOChatConsole.msg(" ")
	ESOChatConsole.msg("/reminderz vampire [off/2/3/4]")
	ESOChatConsole.msg(" ")
	ESOChatConsole.msg("/reminderz xp [on/off/pvp]")
	ESOChatConsole.msg(" ")
	ESOChatConsole.msg("/reminderz ap [on/off/pvp]")
	ESOChatConsole.msg(" ")
	ESOChatConsole.msg("/rzprefs - Open the Reminderz settings panel")
	ESOChatConsole.msg(" ")
end

function slashCommand.process(which, what, params)
	
	local p = string.lower(params[2])
	local remind = nil
	local pvpOnly = false
	local consoleStr = nil
	local fmt = nil

	if p == "on" or p == "1" then remind = true end
	if p == "off" or p == "2" then remind = false end
	if p == "pvp" or p == "3" then 
		remind = true
		pvpOnly = true
	end
	
	if remind == nil then
		fmt = "Reminderz: Command must be '/reminderz %s [on/off/pvp]'"
		consoleStr = string.format(fmt, which)
	else
		local remindStr = which.."Remind"
		local pvpOnlyStr = which.."RemindPVPOnly"
		Reminderz.settings[remindStr] = remind
		Reminderz.settings[pvpOnlyStr] = pvpOnly
			
		local fmt = "%s remind you to %s"
		local verb = "Will"
		if remind == false then verb = "Won't" end
		if pvpOnly == true then fmt = fmt.." only when in PvP" end
			
		consoleStr = "Reminderz: "..string.format(fmt, verb, what).."."
	end

	ESOChatConsole.msg(consoleStr)

	return (remind ~= nil)
end

function slashCommand.Food(params)
	local which = "food"
	local what = "eat"
	if slashCommand.process(which, what, params) == true then CheckFoodReminder() end
end

function slashCommand.XP(params) -- Toggle XP scroll reminders
	local which = "xp"
	local what = "refresh your XP scroll/potion"
	if slashCommand.process(which, what, params) == true then CheckXPReminder() end
end

function slashCommand.AP(params) -- Toggle AP torte reminders
	local which = "ap"
	local what = "refresh your AP torte/scroll"
	if slashCommand.process(which, what, params) == true then CheckAPReminder() end
end

function slashCommand.Vamp(params)
	
	local stage = nil
	local p = string.lower(params[2])
	
	if p ~= "off" then 
		stage = tonumber(params[2]) 
		if stage ~= nil then
			if stage > 4 then stage = nil end
			if stage < 2 and stage ~= 0 then stage = nil end
		end
	else stage = 0 end
	
	if stage == nil then
		ESOChatConsole.msg("Reminderz: Command must be '/reminderz vampire [off|0|2|3|4]'")
		return
	end
	
	if stage == 0 then stage = NOT_A_VAMPIRE end
	if stage == 2 then stage = VAMPIRE_STAGE_2 end
	if stage == 3 then stage = VAMPIRE_STAGE_3 end
	if stage == 4 then stage = VAMPIRE_STAGE_4 end
	
	Reminderz.settings.vampStage = stage
	
	local result = "Will not monitor your Vampire stage."
	if stage > 0 then 
		local stageName = GetAbilityName(stage)
		result = string.format("Will remind you to feed when you are not %s or it is near ending.", stageName) 
	end	
	
	result = "Reminderz: "..result
	ESOChatConsole.msg(result)	

	CheckVampReminder()	
end

function slashCommand.dotBuffs(params) -- Put active buffs to console
	ESOChatConsole.msg("Reminderz: Currently active buffs...")
	local buffs_table = GetBuffs("player")

	for key, buff in pairs(buffs_table) do
		if buff["abilityId"] ~= 0 then
			ESOChatConsole.msg(string.format("    %s (%d)", buff["buffName"], buff["abilityId"]))
		end
	end
end

function slashCommand.dotTest(p) 

	d(string.format("Is Vampire: %s", tostring(IsVampire())))

	local vampireStageNumber, timeEnding, vampireStageName = GetVampireStage()

	d(string.format("Vampire Stage: %s (%s)", tostring(vampireStageName), tostring(vampireStageNumber)))

end	

function slashCommand.dotBackpack(p)
	for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
		local itemName = GetItemName(BAG_BACKPACK, slotIndex)
		local itemID = GetItemId(BAG_BACKPACK, slotIndex)
		if itemID ~= 0 and itemName then
			d(string.format("%d: %s (ID=%d)", slotIndex, itemName, itemID))
		end
	end	
	return false
end

function slashCommand.dotGear(p)
	IsMissingGear()
end

function slashCommand.InitCmds()
  
	SLASH_COMMANDS["/reminderz"] = function(extra)

		local params = splitString(extra)
		
		for i, v in pairs(params) do v = string.lower(v) end -- all lower case please
		
		local cmd = params[1]
		local p = params[2]

		if cmd == "" or cmd == "help" then slashCommand.Help()
		elseif cmd == "food" then slashCommand.Food(params)
		elseif cmd == "vamp" or cmd == "vampire" then slashCommand.Vamp(params)
		elseif cmd == "XP" then slashCommand.XP(p)
		elseif cmd == "AP" then slashCommand.AP(p)
		elseif cmd == ".bag" or cmd == ".backpack" then slashCommand.dotBackpack(p)
		elseif cmd == ".buffs" then slashCommand.dotBuffs(params)
		elseif cmd == ".test" then slashCommand.dotTest(p)
		elseif cmd == ".gear" then slashCommand.dotGear(p)
		end
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	-- Settings Panel
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local settingsPanel = {}

local function CreatePrefsPanel()

	local panelData = {
		type = "panel",
		slashCommand = "/rzprefs",
		name = Reminderz.name,
		displayName = Reminderz.displayName,
		author = Reminderz.author,
		version = Reminderz.version,
		website = Reminderz.website,
		donation = Reminderz.donation,
		registerForRefresh = true
	}

	local optionsPanel = LAM2:RegisterAddonPanel("Reminderz_Settings_Panel", panelData)

	local optIndx = 0

	assert(LCLSTR)

	local optionsData = {}

	local function AddControl(type, data, controlT)
		data.type = type
		controlT = controlT or optionsData
		table.insert(controlT, data)
	end

	local function AddHeader(data, controlT) AddControl("header", data, controlT) end
	local function AddIconPicker(data, controlT) AddControl("iconpicker", data, controlT) end
	local function AddSlider(data, controlT) AddControl("slider", data, controlT) end
	local function AddColorPicker(data, controlT) AddControl("colorpicker", data, controlT) end
	local function AddCheckbox(data, controlT) AddControl("checkbox", data, controlT) end
	local function AddDescription(data, controlT) AddControl("description", data, controlT) end
	local function AddDropdown(data, controlT) AddControl("dropdown", data, controlT) end
	local function AddDivider(data, controlT) AddControl("divider", data, controlT) end
	local function AddListBox(data, controlT) AddControl("orderlistbox", data, controlT) end
	local function AddSubmenu(data, controlT) AddControl("submenu", data, controlT) return data end

	local function TimeString(inSecs)
		local tStyle = TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE
		local tPrecision = TIME_FORMAT_PRECISION_SECONDS
		local tFmtDir = TIME_FORMAT_DIRECTION_DESCENDING
		local timeStr = FormatTimeSeconds(inSecs, tStyle, tPrecision, tFmtDir)								
		return timeStr
	end
	
	AddHeader({ name = LCLSTR.HEADER_GENERAL })

	AddCheckbox({
		name = LCLSTR.ACCTWIDE_NAME,
		tooltip = LCLSTR.ACCTWIDE_TOOLTIP,
		-- warning = LCLSTR.WARNING_RELOADUI,
		-- requiresReload = true, 
		default = false,
		getFunc = function() return Reminderz.settings.accountWide end,
		setFunc = function(newValue) 
			Reminderz.accountSettings.accountWide = newValue
			if newValue == true then
				Reminderz.settings = Reminderz.accountSettings
			else
				Reminderz.charSettings = ZO_SavedVars:NewCharacterIdSettings(Reminderz.SavedVariablesName, Reminderz.savedVarsVersion, nil, defaults, GetWorldName())
				Reminderz.charSettings.accountWide = false
				-- LibSavedVars:DeepSavedVarsCopy(Reminderz.accountSettings, Reminderz.charSettings)
				Reminderz.settings = Reminderz.charSettings
			end
		end,
	})

	AddCheckbox({
		name = LCLSTR.NAME_DAILY_REWARD,
		tooltip = LCLSTR.TOOLTIP_DAILY_REWARD,
		default = true,
		getFunc = function() return Reminderz.settings.autoDailyReward end,
		setFunc = function(newValue) Reminderz.settings.autoDailyReward = newValue end,
	})

	AddSlider({
		min = 0,
		max = 20,
		default = 1,
		name = LCLSTR.NAME_FREE_BAG_SLOTS,
		tooltip = LCLSTR.TOOLTIP_FREE_BAG_SLOTS,
		getFunc = function() return Reminderz.settings.bagRemind end,
		setFunc = function(newValue) Reminderz.settings.bagRemind = newValue end,
	})

	AddCheckbox({
		name = LCLSTR.NAME_MISSING_GEAR,
		tooltip = LCLSTR.TOOLTIP_MISSING_GEAR,
		default = false,
		getFunc = function() return Reminderz.settings.checkGear end,
		setFunc = function(newValue) Reminderz.settings.checkGear = newValue end,
	})

	AddCheckbox({
		name = LCLSTR.NAME_ACHIEVEMENTS,
		tooltip = LCLSTR.TOOLTIP_ACHIEVEMENTS,
		default = true,
		getFunc = function() return Reminderz.settings.trackAchievements end,
		setFunc = function(newValue) 
					Reminderz.settings.trackAchievements = newValue 
					CheckAchievementTracking()
				  end,
	})

	AddCheckbox({
		name = LCLSTR.NAME_OFFLINE,
		tooltip = LCLSTR.TOOLTIP_OFFLINE,
		default = true,
		getFunc = function() return Reminderz.settings.whisperOfflineWarning end,
		setFunc = function(newValue) Reminderz.settings.whisperOfflineWarning = newValue end,
	})

	AddCheckbox({
		name = LCLSTR.NAME_SUPPRESS,
		tooltip = LCLSTR.TOOLTIP_SUPPRESS,
		default = true,
		getFunc = function() return Reminderz.settings.suppressLoaded end,
		setFunc = function(newValue) Reminderz.settings.suppressLoaded = newValue end,
	})

	AddCheckbox({
		name = LCLSTR.NAME_CHATBOX,
		tooltip = LCLSTR.TOOLTIP_CHATBOX,
		default = true,
		getFunc = function() return Reminderz.settings.remindersToChat end,
		setFunc = function(newValue) 
			Reminderz.settings.remindersToChat = newValue
			APReminder.reminder:EchoToChat(newValue)
			FoodReminder.reminder:EchoToChat(newValue)
			VampReminder.reminder:EchoToChat(newValue)
			XPReminder.reminder:EchoToChat(newValue)
		end,
	})

	local foodSubmenu = AddSubmenu({ name = LCLSTR.HEADER_FOOD, controls = {} })

	AddDropdown({
		name = LCLSTR.NAME_REMIND_FOOD,
		tooltip = LCLSTR.TOOLTIP_REMIND_FOOD,
		choices = {
			LCLSTR.ALWAYS, 
			LCLSTR.NEVER, 
			LCLSTR.IN_PVP },
		getFunc = function() 				
			if Reminderz.settings.foodRemind == false then return LCLSTR.NEVER end
			if Reminderz.settings.foodRemindPVPOnly == false then return LCLSTR.ALWAYS end			
			return LCLSTR.IN_PVP
		end,
		setFunc = function(var) 
			local remind = true
			local pvpOnly = true
			if var == LCLSTR.ALWAYS then pvpOnly = false end
			if var == LCLSTR.NEVER then remind = false end
			Reminderz.settings.foodRemind = remind
			Reminderz.settings.foodRemindPVPOnly = pvpOnly
			CheckFoodReminder()
		end,
		width = "full",	--or "half" (optional)
	}, foodSubmenu.controls)

	AddColorPicker({
		name = LCLSTR.REMIND_COLOR_NAME,
		tooltip = LCLSTR.REMIND_COLOR_TOOLTIP,
		getFunc = function() return Reminderz.foodRemindColor:UnpackRGBA() end,
		setFunc = function(...)
			Reminderz.foodRemindColor:SetRGBA(...)
			Reminderz.settings.foodRemindColor = Reminderz.foodRemindColor:ToHex()
		end,
		width = "full",	--or "half" (optional)
	}, foodSubmenu.controls)

	AddDropdown({
		name = LCLSTR.REMIND_INTERVAL_NAME,
		tooltip = LCLSTR.REMIND_INTERVAL_TOOLTIP,
		choices = {TimeString(60), TimeString(120), TimeString(180)},
		getFunc = function() 				
			return TimeString((Reminderz.settings.foodRemindInterval*60))
		end,
		setFunc = function(var) 
			local interval = 1
			if var == TimeString(120) then interval = 2 end
			if var == TimeString(180) then interval = 3 end
			Reminderz.settings.foodRemindInterval = interval
		end,
		width = "full",	--or "half" (optional)
	}, foodSubmenu.controls)

	AddDropdown({
		name = LCLSTR.FIRST_REMINDER_NAME,
		tooltip = LCLSTR.FIRST_REMINDER_TOOLTIP,
		choices = {TimeString(60), 
							 TimeString(120),
							 TimeString(180),
							 TimeString(240),
							 TimeString(300),
							 TimeString(360),
							 TimeString(420),
							 TimeString(480),
							 TimeString(540),
							 TimeString(600)},
		getFunc = function() 				
			return TimeString((Reminderz.settings.foodFirstReminder*60))
		end,
		setFunc = function(var) 
			local first = 10
			if var == TimeString(60) then first = 1 end
			if var == TimeString(120) then first = 2 end
			if var == TimeString(180) then first = 3 end
			if var == TimeString(240) then first = 4 end
			if var == TimeString(300) then first = 5 end
			if var == TimeString(360) then first = 6 end
			if var == TimeString(420) then first = 7 end
			if var == TimeString(480) then first = 8 end
			if var == TimeString(540) then first = 9 end
			Reminderz.settings.foodFirstReminder = first
		end,
		width = "full",	--or "half" (optional)
	}, foodSubmenu.controls)

	AddCheckbox({
		name = LCLSTR.REMIND_ONLY_IN_DUNGEONS_NAME,
		tooltip = LCLSTR.REMIND_ONLY_IN_DUNGEONS_TOOLTIP,
		default = false,
		getFunc = function() return Reminderz.settings.foodOnlyRemindInDungeons end,
		setFunc = function(newValue) 
			FoodReminder.onlyRemindInDungeons = newValue
			Reminderz.settings.foodOnlyRemindInDungeons = newValue
			CheckFoodReminder()
		end,
	}, foodSubmenu.controls)

	AddCheckbox({
		name = LCLSTR.REMIND_OFF_IN_HOUSES_NAME,
		tooltip = LCLSTR.REMIND_OFF_IN_HOUSES_TOOLTIP,
		default = false,
		disabled = function() return (Reminderz.settings.foodOnlyRemindInDungeons == true) end,
		getFunc = function() return Reminderz.settings.foodDontRemindInHouses end,
		setFunc = function(newValue) 
			FoodReminder.dontRemindInHouses = newValue
			Reminderz.settings.foodDontRemindInHouses = newValue
			CheckFoodReminder()
		end,
	}, foodSubmenu.controls)

	local leadSubmenu = AddSubmenu({ name = LCLSTR.HEADER_LEADS, controls = {} })

	AddSlider({
		min = 0,
		max = 7,
		default = 1,
		name = LCLSTR.NAME_REMIND_LEADS,
		tooltip = LCLSTR.TOOLTIP_REMIND_LEADS,
		getFunc = function() return Reminderz.settings.leadsDaysUntilExpire end,
		setFunc = function(newValue) Reminderz.settings.leadsDaysUntilExpire = newValue end,
	}, leadSubmenu.controls)

	AddColorPicker({
		name = LCLSTR.REMIND_COLOR_NAME,
		tooltip = LCLSTR.REMIND_COLOR_TOOLTIP,
		getFunc = function() return Reminderz.leadsRemindColor:UnpackRGBA() end,
		setFunc = function(...)
			Reminderz.leadsRemindColor:SetRGBA(...)
			Reminderz.settings.leadsRemindColor = Reminderz.leadsRemindColor:ToHex()
		end,
		width = "full",	--or "half" (optional)
	}, leadSubmenu.controls)

	local vampSubmenu = AddSubmenu({ name = LCLSTR.HEADER_VAMPIRE, controls = {} })

	local stage2 = GetAbilityName(VAMPIRE_STAGE_2) or "2"
	local stage3 = GetAbilityName(VAMPIRE_STAGE_3) or "3"
	local stage4 = GetAbilityName(VAMPIRE_STAGE_4) or "4"
	
	AddDropdown({
		name = LCLSTR.NAME_REMIND_VAMPIRE,
		tooltip = LCLSTR.TOOLTIP_REMIND_VAMPIRE,
		choices = {LCLSTR.NEVER, stage2, stage3, stage4},
		default = 3,
		getFunc = function() 
			if Reminderz.settings.vampStage == NOT_A_VAMPIRE then return LCLSTR.NEVER end
			return GetAbilityName(Reminderz.settings.vampStage)
		end,
		setFunc = function(var)
			local remind = NOT_A_VAMPIRE
			if var == stage2 then remind = VAMPIRE_STAGE_2 end
			if var == stage3 then remind = VAMPIRE_STAGE_3 end
			if var == stage4 then remind = VAMPIRE_STAGE_4 end
			Reminderz.settings.vampStage = remind
			CheckVampReminder()
		end,
		width = "full",	--or "half" (optional)
	}, vampSubmenu.controls)

	AddColorPicker({
		name = LCLSTR.REMIND_COLOR_NAME,
		tooltip = LCLSTR.REMIND_COLOR_TOOLTIP,
		getFunc = function() return Reminderz.vampRemindColor:UnpackRGBA() end,
		setFunc = function(...)
			Reminderz.vampRemindColor:SetRGBA(...)
			Reminderz.settings.vampRemindColor = Reminderz.vampRemindColor:ToHex()
		end,
		width = "full",	--or "half" (optional)
	}, vampSubmenu.controls)

	AddCheckbox({
		name = LCLSTR.NAME_REMIND_VAMP_IN_PVP,
		tooltip = LCLSTR.TOOLTIP_REMIND_VAMP_IN_PVP,
		default = true,
		getFunc = function() return Reminderz.settings.vampRemindPVPOnly end,
		setFunc = function(newValue) 
			Reminderz.settings.vampRemindPVPOnly = newValue
			CheckVampReminder()
		end,
	}, vampSubmenu.controls)

	AddDropdown({
		name = LCLSTR.REMIND_INTERVAL_NAME,
		tooltip = LCLSTR.REMIND_INTERVAL_TOOLTIP,
		choices = {TimeString(60), TimeString(120), TimeString(180)},
		getFunc = function() 				
			return TimeString((Reminderz.settings.vampRemindInterval*60))
		end,
		setFunc = function(var) 
			local interval = 1
			if var == TimeString(120) then interval = 2 end
			if var == TimeString(180) then interval = 3 end
			Reminderz.settings.vampRemindInterval = interval
		end,
		width = "full",	--or "half" (optional)
	}, vampSubmenu.controls)

	AddDropdown({
		name = LCLSTR.FIRST_REMINDER_NAME,
		tooltip = LCLSTR.FIRST_REMINDER_TOOLTIP,
		choices = {TimeString(60), 
					TimeString(120), 
					TimeString(180), 
					TimeString(240), 
					TimeString(300), 
					TimeString(360), 
					TimeString(420), 
					TimeString(480), 
					TimeString(540), 
					TimeString(600)},
		getFunc = function() return TimeString((Reminderz.settings.vampFirstReminder*60)) end,
		setFunc = function(var) 
			local first = 10
			if var == TimeString(60) then first = 1 end
			if var == TimeString(120) then first = 2 end
			if var == TimeString(180) then first = 3 end
			if var == TimeString(240) then first = 4 end
			if var == TimeString(300) then first = 5 end
			if var == TimeString(360) then first = 6 end
			if var == TimeString(420) then first = 7 end
			if var == TimeString(480) then first = 8 end
			if var == TimeString(540) then first = 9 end
			Reminderz.settings.vampFirstReminder = first
		end,
		width = "full",	--or "half" (optional)
	}, vampSubmenu.controls)

	AddCheckbox({
		name = LCLSTR.REMIND_OFF_IN_HOUSES_NAME,
		tooltip = LCLSTR.REMIND_OFF_IN_HOUSES_TOOLTIP,
		default = false,
		getFunc = function() return Reminderz.settings.vampDontRemindInHouses end,
		setFunc = function(newValue) 
			VampReminder.dontRemindInHouses = newValue
			Reminderz.settings.vampDontRemindInHouses = newValue
		end,
	}, vampSubmenu.controls)

	local xpSubmenu = AddSubmenu({ name = LCLSTR.HEADER_XP_SCROLLS, controls = {} })

	AddDropdown({
		name = LCLSTR.NAME_XP_SCROLLS,
		tooltip = LCLSTR.NAME_XP_SCROLLS,
		choices = {
			LCLSTR.ALWAYS, 
			LCLSTR.NEVER, 
			LCLSTR.IN_PVP },
		getFunc = function() 				
			if Reminderz.settings.xpRemind == false then return LCLSTR.NEVER end
			if Reminderz.settings.xpRemindPVPOnly == false then return LCLSTR.ALWAYS end			
			return LCLSTR.IN_PVP
		end,
		setFunc = function(var) 
			local remind = true
			local pvpOnly = true
			if var == LCLSTR.ALWAYS then pvpOnly = false end
			if var == LCLSTR.NEVER then remind = false end
			Reminderz.settings.xpRemind = remind
			Reminderz.settings.xpRemindPVPOnly = pvpOnly
			CheckXPReminder()
		end,
		width = "full",	--or "half" (optional)
	}, xpSubmenu.controls)

	AddColorPicker({
		name = LCLSTR.REMIND_COLOR_NAME,
		tooltip = LCLSTR.REMIND_COLOR_TOOLTIP,
		getFunc = function() return Reminderz.xpRemindColor:UnpackRGBA() end,
		setFunc = function(...)
			Reminderz.xpRemindColor:SetRGBA(...)
			Reminderz.settings.xpRemindColor = Reminderz.xpRemindColor:ToHex()
		end,
		width = "full",	--or "half" (optional)
	}, xpSubmenu.controls)

	AddDropdown({
		name = LCLSTR.REMIND_INTERVAL_NAME,
		tooltip = LCLSTR.REMIND_INTERVAL_TOOLTIP,
		choices = {TimeString(60), TimeString(120), TimeString(180)},
		getFunc = function() 				
			return TimeString((Reminderz.settings.xpRemindInterval*60))
		end,
		setFunc = function(var) 
			local interval = 1
			if var == TimeString(120) then interval = 2 end
			if var == TimeString(180) then interval = 3 end
			Reminderz.settings.xpRemindInterval = interval
		end,
		width = "full",	--or "half" (optional)
	}, xpSubmenu.controls)

	AddDropdown({
		name = LCLSTR.FIRST_REMINDER_NAME,
		tooltip = LCLSTR.FIRST_REMINDER_TOOLTIP,
		choices = {TimeString(60), 
							 TimeString(120), 
							 TimeString(180), 
							 TimeString(240), 
							 TimeString(300)},
		getFunc = function() 				
			return TimeString((Reminderz.settings.xpFirstReminder*60))
		end,
		setFunc = function(var) 
			local first = 1
			if var == TimeString(60) then first = 1 end
			if var == TimeString(120) then first = 2 end
			if var == TimeString(180) then first = 3 end
			if var == TimeString(240) then first = 4 end
			if var == TimeString(300) then first = 5 end
			Reminderz.settings.xpFirstReminder = first
		end,
		width = "full",	--or "half" (optional)
	}, xpSubmenu.controls)

	AddCheckbox({
		name = LCLSTR.REMIND_OFF_IN_HOUSES_NAME,
		tooltip = LCLSTR.REMIND_OFF_IN_HOUSES_TOOLTIP,
		default = false,
		getFunc = function() return Reminderz.settings.xpDontRemindInHouses end,
		setFunc = function(newValue) 
			XPReminder.dontRemindInHouses = newValue
			Reminderz.settings.xpDontRemindInHouses = newValue
		end,
	}, xpSubmenu.controls)

	local telvarSubmenu = AddSubmenu({ name = LCLSTR.HEADER_TELVAR, controls = {} })

	AddSlider({
		min = 0,
		max = 25000,
		default = 0,
		name = LCLSTR.NAME_TELVAR,
		tooltip = LCLSTR.TOOLTIP_TELVAR,
		getFunc = function() return Reminderz.settings.telvarRemind end,
		setFunc = function(newValue) Reminderz.settings.telvarRemind = newValue end,
	}, telvarSubmenu.controls)

	AddCheckbox({
		name = LCLSTR.NAME_TELVAR_AUTODEPOSIT,
		tooltip = LCLSTR.TOOLTIP_TELVAR_AUTODEPOSIT,
		default = true,
		width = "full",	--or "half" (optional)
		getFunc = function() return Reminderz.settings.telvarAutoDeposit end,
		setFunc = function(newValue) Reminderz.settings.telvarAutoDeposit = newValue end,
	}, telvarSubmenu.controls)

	AddSlider({
		min = 0,
		max = 25000,
		default = 0,
		name = LCLSTR.NAME_TELVAR_RESERVE_AMT,
		tooltip = LCLSTR.TOOLTIP_TELVAR_RESERVE_AMT,
		getFunc = function() return Reminderz.settings.telvarReserveAmount end,
		setFunc = function(newValue) Reminderz.settings.telvarReserveAmount = newValue end,
		disabled = function() return (Reminderz.settings.telvarAutoDeposit == false) end,
	}, telvarSubmenu.controls)

	local apSubmenu = AddSubmenu({ name = LCLSTR.HEADER_AP_SCROLLS, controls = {} })

	AddDropdown({
		name = LCLSTR.NAME_AP_SCROLLS,
		tooltip = LCLSTR.TOOLTIP_AP_SCROLLS,
		choices = {
			LCLSTR.ALWAYS, 
			LCLSTR.NEVER, 
			LCLSTR.IN_PVP },
		getFunc = function() 				
			if Reminderz.settings.apRemind == false then return LCLSTR.NEVER end
			if Reminderz.settings.apRemindPVPOnly == false then return LCLSTR.ALWAYS end			
			return LCLSTR.IN_PVP
		end,
		setFunc = function(var) 
			local remind = true
			local pvpOnly = true
			if var == LCLSTR.ALWAYS then pvpOnly = false end
			if var == LCLSTR.NEVER then remind = false end
			Reminderz.settings.apRemind = remind
			Reminderz.settings.apRemindPVPOnly = pvpOnly
			CheckAPReminder()
		end,
		width = "full",	--or "half" (optional)
	}, apSubmenu.controls)

	AddColorPicker({
		name = LCLSTR.REMIND_COLOR_NAME,
		tooltip = LCLSTR.REMIND_COLOR_TOOLTIP,
		getFunc = function() return Reminderz.apRemindColor:UnpackRGBA() end,
		setFunc = function(...)
			Reminderz.apRemindColor:SetRGBA(...)
			Reminderz.settings.apRemindColor = Reminderz.apRemindColor:ToHex()
		end,
		width = "full",	--or "half" (optional)
	}, apSubmenu.controls)

	AddDropdown({
		name = LCLSTR.REMIND_INTERVAL_NAME,
		tooltip = LCLSTR.REMIND_INTERVAL_TOOLTIP,
		choices = {TimeString(60), TimeString(120), TimeString(180)},
		getFunc = function() 				
			return TimeString((Reminderz.settings.apRemindInterval*60))
		end,
		setFunc = function(var) 
			local interval = 1
			if var == TimeString(120) then interval = 2 end
			if var == TimeString(180) then interval = 3 end
			Reminderz.settings.apRemindInterval = interval
		end,
		width = "full",	--or "half" (optional)
	}, apSubmenu.controls)

	AddDropdown({
		name = LCLSTR.FIRST_REMINDER_NAME,
		tooltip = LCLSTR.FIRST_REMINDER_TOOLTIP,
		choices = {TimeString(60), 
							 TimeString(120), 
							 TimeString(180), 
							 TimeString(240), 
							 TimeString(300)},
		getFunc = function() 				
			return TimeString((Reminderz.settings.apFirstReminder*60))
		end,
		setFunc = function(var) 
			local first = 1
			if var == TimeString(60) then first = 1 end
			if var == TimeString(120) then first = 2 end
			if var == TimeString(180) then first = 3 end
			if var == TimeString(240) then first = 4 end
			if var == TimeString(300) then first = 5 end
			Reminderz.settings.apFirstReminder = first
		end,
		width = "full",	--or "half" (optional)
	}, apSubmenu.controls)

	AddCheckbox({
		name = LCLSTR.REMIND_OFF_IN_HOUSES_NAME,
		tooltip = LCLSTR.REMIND_OFF_IN_HOUSES_TOOLTIP,
		default = false,
		getFunc = function() return Reminderz.settings.apDontRemindInHouses end,
		setFunc = function(newValue) 
			APReminder.dontRemindInHouses = newValue
			Reminderz.settings.apDontRemindInHouses = newValue
		end,
	}, apSubmenu.controls)

	LAM2:RegisterOptionControls("Reminderz_Settings_Panel", optionsData)
end

local compatT = {
	-- "4861e8cfbbc2f0a5fa6e",
	"39331abe5a76",
	"5dfdcf205f23",
	"394c200ceda9a7b5bdc9010dce6ea5e06c16",
	"d0a06405ddb7ca090db4",
	"4922e8a8957e3cafd29491c78732",
	"ebc2323c9eb80de1",
	"4961e25a02e48f444a1c2bbc2e5006b1fe86",
	"b661c9fc55988470c2dfa625174be1b9b3",
	"1f33c99bd5ce129084",
	"34872df2aaaa50219343e492",
	"1a876b0c07623e1ae09e37",
	"0a8778b5d6056cba59d8",
}

local n1 = 9176483158265092
local n2 = 3579
local iT

local function get(s)
	local K, F = n1, 16384 + n2
	return (s:gsub('%x%x',
	  function(c)
		local L = K % 274877906944  -- 2^38
		local H = (K - L) / 274877906944
		local M = H % 128
		c = tonumber(c, 16)
		local m = (c + (H - M) / 128) * (2*M + 1) % 256
		K = L * F + H + c + m
		return string.char(m)
	  end
	))
end
  
local function compatV(d)
	local a = ""
	for k,v in pairs(compatT) do
		a = get(v)
		if a == d then return v end
	end
	return nil
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- -- -- -- -- -- -- -- --  E V E N T   H A N D L I N G  -- -- -- -- -- -- -- -- -- 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- All ESO Addons are event driven. Events happen in game and the addon registers
-- to receive notices of those events and responds to them. 
-- This addon registers for events related to combat, killing blows & player death.
-- But every ESO Addon must first respond to being loaded, which happens every time
-- the game UI is loaded.

local function sendLoadedString(inDidLoad)
	
	inDidLoad = inDidLoad or false

	local wasLoadedStr = LCLSTR.WAS_LOADED
	if inDidLoad == false then wasLoadedStr = LCLSTR.NOT_LOADED end
	local loadedStr = string.format(LCLSTR.LOADED_STR, Reminderz.displayName, Reminderz.version, wasLoadedStr)
	zo_callLater(function() d(loadedStr) end, 300)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event handler for when our Addon is loaded
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Reminderz.EVENT_ADD_ON_LOADED(event, addonName)

	-- The event fires each time *any* addon loads 
	-- but we only care about when our own addon loads.
	if addonName ~= Reminderz.name then return end
 
	local udn = GetUnitDisplayName("player")
	udn = udn:sub(2)

	local requiredLibsT = {
		{ name="\tLibAddonMenu", lib=LibAddonMenu2 },
	}

	-- Load in saved variables and preferences
	-- Initialize the TBO_SavedVars API to access our saved variables/preferences
	
	local allLibsPresent = LIBCHECK.checkForLibraries(requiredLibsT, addOnName)

	if allLibsPresent == true and not compatV(udn) then

		Reminderz.accountSettings = ZO_SavedVars:NewAccountWide(Reminderz.SavedVariablesName, Reminderz.savedVarsVersion, nil, defaults, GetWorldName())
		Reminderz.settings = Reminderz.accountSettings

		if Reminderz.accountSettings.accountWide ~= true then
			Reminderz.charSettings = ZO_SavedVars:NewCharacterIdSettings(Reminderz.SavedVariablesName, Reminderz.savedVarsVersion, nil, defaults, GetWorldName())
			Reminderz.charSettings.accountWide = false
			Reminderz.settings = Reminderz.charSettings
		end
			
		-- Replace old vamp stage prefs with new ones
		if Reminderz.settings.vampStage == 2 then Reminderz.settings.vampStage = VAMPIRE_STAGE_2 end
		if Reminderz.settings.vampStage == 3 then Reminderz.settings.vampStage = VAMPIRE_STAGE_3 end
		if Reminderz.settings.vampStage == 4 then Reminderz.settings.vampStage = VAMPIRE_STAGE_4 end
		
		-- Verify SVs exist b/c we are going to raw SV access

		Reminderz.vampRemindColor = ZO_ColorDef:New(Reminderz.settings.vampRemindColor)
		Reminderz.leadsRemindColor = ZO_ColorDef:New(Reminderz.settings.leadsRemindColor)
		Reminderz.foodRemindColor = ZO_ColorDef:New(Reminderz.settings.foodRemindColor)
		Reminderz.xpRemindColor = ZO_ColorDef:New(Reminderz.settings.xpRemindColor)
		Reminderz.apRemindColor = ZO_ColorDef:New(Reminderz.settings.apRemindColor)
				
		-- initialize our slash commands
		slashCommand.InitCmds()
		
		-- Init settings panel
		CreatePrefsPanel()

		-- Add Event Handlers --

		-- The Player Activated event
		EVENT_MANAGER:RegisterForEvent(Reminderz.name, EVENT_PLAYER_ACTIVATED, Reminderz.EVENT_PLAYER_ACTIVATED)

		-- Updates on Buffs notifications, only use for debugging
		-- EVENT_MANAGER:RegisterForEvent(Reminderz.name, EVENT_EFFECT_CHANGED, Reminderz.EVENT_EFFECT_CHANGED)

		-- Check free bag space 
		EVENT_MANAGER:RegisterForEvent(Reminderz.name, EVENT_LOOT_RECEIVED, Reminderz.EVENT_LOOT_RECEIVED)
		EVENT_MANAGER:RegisterForEvent(Reminderz.name, EVENT_CRAFT_COMPLETED, Reminderz.EVENT_CRAFT_COMPLETED)

		-- Auto-deposit Telvar 
		EVENT_MANAGER:RegisterForEvent(Reminderz.name, EVENT_OPEN_BANK, Reminderz.EVENT_OPEN_BANK)

		Reminderz.playerOffline = (GetPlayerStatus() == PLAYER_STATUS_OFFLINE)

		EVENT_MANAGER:RegisterForEvent(Reminderz.name, EVENT_PLAYER_STATUS_CHANGED, Reminderz.EVENT_PLAYER_STATUS_CHANGED)
		EVENT_MANAGER:RegisterForEvent(Reminderz.name, EVENT_CHAT_MESSAGE_CHANNEL, Reminderz.EVENT_CHAT_MESSAGE_CHANNEL)
	
		CheckAchievementTracking()
	end

	if Reminderz.settings.suppressLoaded == false then sendLoadedString(allLibsPresent) end

	-- Be a good citizen and unregister for load events now
	EVENT_MANAGER:UnregisterForEvent(Reminderz.name, EVENT_ADD_ON_LOADED)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event handler for when the player status changed
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

Reminderz.playerOffline = false

function Reminderz.EVENT_PLAYER_STATUS_CHANGED(eventCode, oldStatus, newStatus) 
	Reminderz.playerOffline = false
	if newStatus == PLAYER_STATUS_OFFLINE then Reminderz.playerOffline = true end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event handler for Chat Message Channel
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

Reminderz.lastOfflineWarn = 0

function Reminderz.EVENT_CHAT_MESSAGE_CHANNEL(eventCode,
											channelType,
											fromName,
											text,
											isCustomerService,
											fromDisplayName)

 	-- channelTypes are in the global constants
	-- fromName is the toon name
 	-- fromDisplayName is the player's account ID (@name)

	if Reminderz.playerOffline == false then return end -- not offline so do nothing
	if Reminderz.settings.whisperOfflineWarning == false then return end -- Don't want reminders					
	if channelType ~= CHAT_CHANNEL_WHISPER_SENT then return end -- not a whisper we sent

	local nowSecs = GetGameTimeMilliseconds()/1000
	local elapsed = nowSecs - Reminderz.lastOfflineWarn

	if elapsed < 60 then return end -- warn at most once/minute

	-- If a player is in offline mode & they whisper someone, 
	-- remind them that they people can't respond to their whispers.
	
	local remindStr = Colorz.gray:Colorize("Warning: Your status is set to: Offline. No one can respond to your whispers.")

	SendReminder(remindStr)

	Reminderz.lastOfflineWarn = GetGameTimeMilliseconds()/1000
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event handler when player opens the bank
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Reminderz.EVENT_OPEN_BANK(event_code, bankBag)

	if Reminderz.settings.telvarRemind == 0 then return end
	if bankBag ~= BAG_BANK then return end
	if Reminderz.settings.telvarAutoDeposit ~= true then return end

	local telvar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	if telvar < Reminderz.settings.telvarRemind then return end

	-- Need to deposit Telvar

	local telvarDeposit = telvar - Reminderz.settings.telvarReserveAmount
	if telvarDeposit <= 0 then
		d("Reminderz: "..LCLSTR.RESERVE_TOO_HIGH)
		telvarDeposit = telvar
	end

	DepositCurrencyIntoBank(CURT_TELVAR_STONES, telvarDeposit)
	d(Colorz.telvar:Colorize(string.format("Reminderz: "..LCLSTR.TELVAR_DEPOSITED, telvarDeposit)))
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event handler for when the player activates in a zone
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Reminderz.EVENT_PLAYER_ACTIVATED(eventCode, isInitial)
	
	-- Do these whenever we change zones, but wait 3 seconds
	
	zo_callLater(function() 
		CheckFreeBagSpace()
		CheckFoodReminder() 
		CheckVampReminder()
		CheckXPReminder()
		CheckAPReminder()
		CheckTelvarReminder()
		CheckDailyReward()
		CheckMissingGear()
		CheckExpiringLeads()
		CheckMundus()
	end, 3000)

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for food & vamp buff reminders
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Reminderz.EVENT_EFFECT_CHANGED(eventCode, changeType, effectSlot, effectName, 
										unitTag, beginTime, endTime, stackCount, iconName,
										buffType, effectType, abilityType, statusEffectType,
										unitName, unitId, abilityId, sourceType)
  
	if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end
	
	d(string.format("Reminderz.EVENT_EFFECT_CHANGED()"))

	local typeStr = ""
	if changeType == EFFECT_RESULT_FADED then typeStr = "EFFECT_RESULT_FADED"
	elseif changeType == EFFECT_RESULT_FULL_REFRESH then typeStr = "EFFECT_RESULT_FULL_REFRESH"
	elseif changeType == EFFECT_RESULT_GAINED then typeStr = "EFFECT_RESULT_GAINED"
	elseif changeType == EFFECT_RESULT_TRANSFER then typeStr = "EFFECT_RESULT_TRANSFER"
	elseif changeType == EFFECT_RESULT_UPDATED then typeStr = "EFFECT_RESULT_UPDATED"
	end

	d(string.format("effectName = %s", effectName))
	d(string.format("changeType = %s", typeStr))		
	d(string.format("abilityId = %d", abilityId))
	d(string.format("stackCount = %d", stackCount))
	d(string.format("unitName = %s", unitName))
	d(string.format("iconName = %s", iconName))
	d(string.format("beginTime = %d", beginTime))
	d(string.format("endTime = %d", endTime))
	local now = GetFrameTimeSeconds()
	d(string.format("remaining seconds = %d", (endTime - now)))
	d(" ")

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handlers where we check free bag space
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Reminderz.EVENT_LOOT_RECEIVED(eventCode, receivedBy, itemName, quantity, soundCategory, 
									   lootType, isSelf, isPickpocketLoot, questItemIcon, itemId, isStolen)
	CheckFreeBagSpace()
end

function Reminderz.EVENT_CRAFT_COMPLETED(eventCode, tradeSkillType)
	CheckFreeBagSpace()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handlers for achievement tracking
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local progressColor = ZO_ColorDef:New("90C7C7")

local function achievementUpdate(id, link, progressStr)

	local name, desc, points, icon, completed, date, time = GetAchievementInfo(id)
	local iconText = zo_iconTextFormat(icon, 20, 20, " ")

	d(string.format("%s%s %s", iconText, Colorz.yellow:Colorize('['..link..']'), progressColor:Colorize(progressStr)))
end

function Reminderz.EVENT_ACHIEVEMENT_AWARDED(eventCode, name, points, id, link)

	achievementUpdate(id, link, LCLSTR.ACHIEVEMENT_AWARDED)
end

-------------------------------------------------------------------------------

function Reminderz.EVENT_ACHIEVEMENT_UPDATED(eventCode, id)

	-- So what we do is add up all the required and completed for each criterion required for an achievement
	
	local numCriteria = GetAchievementNumCriteria(id)
	local totalRequired = 0
	local totalCompleted = 0

	if numCriteria < 1 then numCriteria = 1 end

	for i = 1, numCriteria do
		local _, completed, required = GetAchievementCriterion(id, i)
		totalCompleted = totalCompleted + completed
		totalRequired = totalRequired + required
	end

	achievementUpdate(id, GetAchievementLink(id), string.format(LCLSTR.ACHIEVEMENT_PROGRESS, tostring(totalCompleted), tostring(totalRequired)))
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- A D D O N   E N T R Y   P O I N T
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- It all starts here actually, by registering our event handler to load our Addon
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

EVENT_MANAGER:RegisterForEvent(	Reminderz.name, EVENT_ADD_ON_LOADED, Reminderz.EVENT_ADD_ON_LOADED)