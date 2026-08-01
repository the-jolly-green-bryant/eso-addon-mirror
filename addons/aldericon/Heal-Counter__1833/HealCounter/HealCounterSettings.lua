--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

--[[
Acknowledgments

I'd like to thank the following people for helping me, either with testing or giving me ideas:
- @Draconise
- @Delphinnia
- @Ray.1
- @Backfill
- @Dailaba
- @rappinhvac
- @Caddic
- @QxQ
- @Rhone2112
- @Xtacy
- @HouseOfD'allyn
- @Karm1cOne

I'd like to thank the following addons; this was my first addon and by examining their code helped me learn a lot:
- AP Meter by ghostbane
- AutoRez by Meai
- Circonians PvP Ranks by Denidil
- Kill Counter by mikethecoder4
- Miat's CC Tracker by dorrino
- Miat's PVP Alerts by dorrino
- Taos AP Session by Taonner
- Purge Tracker by code65536
- Merlin's Heal Helper by Khrill
]]

-- Initialized the addon names
HealCounter = {}
HealCounter.name = "HealCounter"
HealCounter.version = 12.0

-- Initializes various things; variables aptly named
HealCounter.playerName = ''
HealCounter.totalUniquePlayersHealed = 0
HealCounter.totalPlayersRezzed = 0
HealCounter.earthgoreTimestamp = 0
HealCounter.currentSession = {
	players = {},
	abilities = {}
}
HealCounter.selfTotalRezzed = 0
HealCounter.players_table = nil
HealCounter.abilities_table = nil
HealCounter.playerInPvP = false
HealCounter.playerIsMounted = false
HealCounter.siegeShieldTimestamp = 0
HealCounter.frameRate = 99
HealCounter.currentLayerIndex = 2
HealCounter.playerInGroup = false
HealCounter.playerInCombat = false
HealCounter.playerUserID = ''

-- For what HC level you're at
HealCounter.healStreak = {
	[1] = 'Healing Accident',
	[10] = 'Kill them with Heals',
	[25] = 'Healer, not a Fighter',
	[35] = 'Make Heals, Not War',
	[50] = 'Healing Spree',
	[65] = 'Praying for Heals',
	[75] = 'Healing Touch',
	[85] = 'Life of a Healer',
	[100] = "Light's Champion",
	[125] = 'Breath of Heals',
	[150] = 'Ritual Master',
	[175] = 'Heal Monkey',
	[200] = 'Healing Goddess',
	[210] = 'Made Healing History',
	[230] = "Showin' off the Heals",
	[250] = 'Get your Heals Here',
	[260] = 'Quick Caster',
	[275] = 'Call me Professor Heals',
	[300] = 'Insert Heals Here'
}

HealCounter.currentLevel = 0

-- For the addon settings menu
HealCounter.LAM2 = LibAddonMenu2

-- Saved beyond session variables
HealCounter.defaults={
	enabledOnlyInPvP=false,
	unlocked=true,
	showTotalPlayersHealed=true,
	showTotalPlayersRezzed=true,
	debugOnOff=false,
	debugLevel=1,
	displayLeft=0,
	displayTop=0,
	displayScreen=true,
	utilizePopup=true,
	trackingLevel=1,
	trackingSet1=1,
	trackingSet2=1,
	trackingSet3=1,
	rezType=false,
	bestTotalHealed=0,
	bestTotalRezzed=0,
	popupLeft=0,
	popupTop=0,
	trackingAbility1=1,
	purgeLeft=0,
	purgeTop=0,
	purgeIndicator=1,
	showAbilityNum=true,
	purgeName=true,
	purgeTrackingLevel=true,
	displayScreenTransparent=false,
	onlyTrackMounted=false,
	trackFPSNum=10,
	fontSize=18,
	displayHeight=130,
	displayWidth=170,
	tphOffsetY=15,
	tphOffsetX=10,
	tprOffsetY=35,
	tprOffsetX=10,
	set1OffsetY=55,
	set1OffsetX=10,
	set2OffsetY=75,
	set2OffsetX=10,
	set3OffsetX=95,
	set3OffsetY=10,
	ability1OffsetY=115,
	ability1OffsetX=10,
	iconOffsetY=15,
	iconOffsetX=130,
	preview=false,
	displayIcon=true,
	systemMessages=true,
	rezNotification=false,
	siegeNotification=false,
	totalPlayersHealedCombat=false,
	purgePVPDebuffs=false,
	purgeImage=false,
	purgeFontSize=34,
	purgeImageSize=80,
	purgeImageLabelY=60,
	purgeImageLabelX= -50
}

-- these abilities can have many different IDs
HealCounter.majorcourage = {
	[66902] = true, -- proven
	[109966] = true,
	[109994] = true,
	[110020] = true,
	[120015] = true,
}

HealCounter.earthgore = {
	[97857] = true, -- proven
	[97854] = true,
	[97855] = true,
	[97856] = true,
	[97877] = true
}

HealCounter.transmutation = {
	[76936] = true, -- proven
	[76934] = true
}

HealCounter.majoreva = {
	[84341] = true, -- proven
	[61716] = true,
	[63015] = true,
	[63016] = true,
	[63017] = true,
	[63018] = true,
	[63019] = true,
	[63023] = true,
	[63026] = true,
	[63028] = true,
	[63030] = true,
	[63036] = true,
	[63040] = true,
	[63042] = true,
	[69685] = true,
	[90587] = true,
	[90588] = true,
	[90589] = true,
	[90592] = true,
	[90593] = true,
	[90594] = true,
	[90595] = true,
	[90596] = true,
	[90620] = true,
	[90621] = true,
	[90622] = true,
	[90623] = true
}

HealCounter.minorberserk = {
	[62645] = true, -- proven
	[61744] = true,
	[62636] = true,
	[62639] = true,
	[62642] = true,
	[64047] = true,
	[64048] = true,
	[64050] = true,
	[64051] = true,
	[64052] = true,
	[64053] = true,
	[64054] = true,
	[64055] = true,
	[64056] = true,
	[64057] = true,
	[64058] = true,
	[64178] = true,
	[80471] = true,
	[80481] = true,
	[81508] = true,
	[81511] = true,
	[81514] = true,
	[87864] = true,
	[93728] = true,
	[93731] = true,
	[93734] = true,
	[96259] = true
}

HealCounter.rapid = {
	[38566] = true,
	[38567] = true,
	[38568] = true,
	[46484] = true,
	[46485] = true,
	[46487] = true,
	[46488] = true,
	[46489] = true,
	[46491] = true,
	[46492] = true,
	[46493] = true,
	[46495] = true,
	[57478] = true,
	[57477] = true,
	[57479] = true,
	[57480] = true
}

HealCounter.trk = {
	[80503] = true,
	[80504] = true,
	[80503] = true,
	[80504] = true
}

HealCounter.meritoriousService = {
	[65706] = true,
	[65707] = true
}

HealCounter.siegeShield = {
	[22469] = true,
	[38570] = true,
	[39844] = true,
	[41735] = true,
	[46649] = true,
	[46650] = true,
	[46651] = true,
	[46652] = true,
	[46653] = true,
	[46654] = true,
	[47014] = true,
	[66548] = true,
	[92552] = true,
	[92570] = true,
	[92571] = true,
	[92572] = true,
	[92573] = true,
	[92574] = true,
	[92575] = true,
	[92576] = true,
	[93030] = true,
	[93031] = true,
	[93032] = true,
	[93033] = true,
	[93034] = true,
	[93035] = true,
	[93036] = true,
	[93037] = true,
	[95286] = true,
	[22469] = true,
	[38570] = true,
	[39844] = true,
	[41735] = true,
	[46649] = true,
	[46650] = true,
	[46651] = true,
	[46652] = true,
	[46653] = true,
	[46654] = true,
	[47014] = true,
	[66548] = true,
	[92552] = true,
	[92570] = true,
	[92571] = true,
	[92572] = true,
	[92573] = true,
	[92574] = true,
	[92575] = true,
	[92576] = true,
	[93030] = true,
	[93031] = true,
	[93032] = true,
	[93033] = true,
	[93034] = true,
	[93035] = true,
	[93036] = true,
	[93037] = true,
	[95286] = true
}

HealCounter.siege = {
	[7469] = true, -- proven; Ballista
	[7011] = true,
	[7468] = true,
	[13043] = true,
	[14361] = true,
	[14362] = true,
	[14363] = true,
	[14364] = true,
	[14367] = true,
	[16775] = true,
	[16776] = true,
	[28480] = true,
	[30454] = true,
	[35049] = true,
	[35092] = true,
	[39437] = true,
	[39438] = true,
	[39439] = true,
	[39448] = true,
	[39449] = true,
	[39453] = true,
	[66239] = true,
	[66242] = true,
	[66243] = true,
	[66244] = true,
	[68205] = true,
	[85319] = true,
	[85451] = true,
	[85458] = true,
	[85462] = true,
	[86614] = true,
	[86615] = true,
	[86616] = true,
	[86617] = true,
	[86618] = true,
	[86619] = true,
	[86620] = true,
	[86621] = true,
	[86622] = true,
	[91074] = true,
	[91075] = true,
	[91076] = true,
	[91077] = true,
	[92306] = true,
	[92307] = true,
	[92308] = true,
	[92309] = true,
	[64108] = true, -- Oil Catapult
	[16795] = true,
	[16790] = true,
	[16789] = true,
	[16788] = true,
	[35129] = true, -- Oil Pot
	[35130] = true,
	[35130] = true,
	[35132] = true,
	[7007] = true, -- Trebuchet
	[7010] = true,
	[7429] = true,
	[13550] = true,
	[13551] = true,
	[13552] = true,
	[13588] = true,
	[14158] = true,
	[14159] = true,
	[14160] = true,
	[25869] = true,
	[28483] = true,
	[35102] = true,
	[35109] = true,
	[64105] = true,
	[64109] = true,
	[66240] = true,
	[66245] = true,
	[66246] = true,
	[66247] = true,
	[66248] = true,
	[66249] = true,
	[66250] = true,
	[66251] = true,
	[66252] = true,
	[14610] = true, -- Catapult
	[14611] = true,
	[14612] = true,
	[14773] = true,
	[14774] = true,
	[32034] = true,
	[32035] = true,
	[32036] = true,
	[32037] = true,
	[35133] = true,
	[36408] = true,
	[43119] = true,
	[43120] = true,
	[43121] = true,
	[43744] = true,
	[45488] = true,
	[45489] = true,
	[47501] = true,
	[47502] = true,
	[64108] = true,
	[64388] = true,
	[64389] = true,
	[67082] = true,
	[68206] = true,
	[73872] = true,
	[74872] = true,
	[74874] = true,
	[74875] = true,
	[74893] = true,
	[92919] = true,
	[92922] = true,
	[93181] = true,
	[93182] = true,
	[95283] = true,
	[97816] = true,
	[97817] = true,
	[97818] = true,
	[97821] = true,
	[97822] = true,
	[98178] = true,
	[98179] = true,
	[98180] = true,
	[98181] = true,
	[35121] = true,
	[14773] = true, -- Meatbag
	[14774] = true,
	[32034] = true,
	[32035] = true,
	[32036] = true,
	[32037] = true,
	[35133] = true,
	[35134] = true,
	[35136] = true,
	[35139] = true,
	[36408] = true,
	[14773] = true,
	[14774] = true,
	[32034] = true,
	[32035] = true,
	[32036] = true,
	[32037] = true,
	[35133] = true,
	[35134] = true,
	[35136] = true,
	[35139] = true,
	[36408] = true,
	[35080] = true, -- Other
	[35055] = true,
	[35094] = true,
	[35112] = true,
	[35099] = true,
	[35106] = true,
	[15776] = true
}

HealCounter.symphonyOfBlades = {
	[117111] = true,
	[117118] = true,
	[117119] = true,
	[117110] = true
}

function HealCounter:Initialize()
	HealCounter.playerName = zo_strformat("<<1>>", GetUnitName('player'))
	HealCounter.playerInPvP = IsPlayerInAvAWorld()
	HealCounter.playerUserID = zo_strformat("<<1>>", GetUnitDisplayName('player'))

	EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_COMBAT_EVENT, HealCounter.OnCombat)
	EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_RESURRECT_RESULT, HealCounter.OnRez)
	EVENT_MANAGER:RegisterForEvent(HealCounter.Name, EVENT_EFFECT_CHANGED, HealCounter.OnEffectChanged)
	EVENT_MANAGER:RegisterForEvent(HealCounter.Name, EVENT_GROUP_MEMBER_JOINED, HealCounter.OnGroupPlayerChange)
	EVENT_MANAGER:RegisterForEvent(HealCounter.Name, EVENT_GROUP_MEMBER_LEFT, HealCounter.OnGroupPlayerChange)
	EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_PLAYER_ACTIVATED, HealCounter.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_ACTION_LAYER_PUSHED, HealCounter.OnActionLayerChange)
	EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_ACTION_LAYER_POPPED, HealCounter.OnActionLayerChange)
	EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, HealCounter.OnGroupSupportRangeUpdate)
	EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_RESURRECT_REQUEST, HealCounter.OnSelfRez)
	EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_MOUNTED_STATE_CHANGED, HealCounter.OnMountStateChange)
	EVENT_MANAGER:RegisterForUpdate(HealCounter.name, 1000, HealCounter.UpdateWindow)
	EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_PLAYER_COMBAT_STATE, HealCounter.OnPlayerCombatState)

	HealCounter.UpdateWindow()
end

-- Loads the addon; only hit once
function HealCounter.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= HealCounter.name then
		return
	end

	HealCounter.SV = ZO_SavedVars:New("HealCounterTrackerSettings", 1.1, "Settings", HealCounter.defaults)
	HealCounter:InitializeAddonMenu()

	EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_ADD_ON_LOADED)

	HealCounter:Initialize()
	HealCounter:InitControls()
	HealCounter:OnOff()
	HealCounter:SetupHCR()
	HealCounter:SetupPlayerTable()
	HealCounter:SetupAbilitiesTable()
end

-- Sets up the Heal Counter Report
function HealCounter:SetupHCR()
	SLASH_COMMANDS["/hcr"] = function (extra)
		local channel_array = {
			guild1 = CHAT_CHANNEL_GUILD_1,
			guild2 = CHAT_CHANNEL_GUILD_2,
			guild3 = CHAT_CHANNEL_GUILD_3,
			guild4 = CHAT_CHANNEL_GUILD_4,
			guild5 = CHAT_CHANNEL_GUILD_5,
			g1 = CHAT_CHANNEL_GUILD_1,
			g2 = CHAT_CHANNEL_GUILD_2,
			g3 = CHAT_CHANNEL_GUILD_3,
			g4 = CHAT_CHANNEL_GUILD_4,
			g5 = CHAT_CHANNEL_GUILD_5,
			officer1 = CHAT_CHANNEL_OFFICER_1,
			officer2 = CHAT_CHANNEL_OFFICER_2,
			officer3 = CHAT_CHANNEL_OFFICER_3,
			officer4 = CHAT_CHANNEL_OFFICER_4,
			officer5 = CHAT_CHANNEL_OFFICER_5,
			o1 = CHAT_CHANNEL_OFFICER_1,
			o2 = CHAT_CHANNEL_OFFICER_2,
			o3 = CHAT_CHANNEL_OFFICER_3,
			o4 = CHAT_CHANNEL_OFFICER_4,
			o5 = CHAT_CHANNEL_OFFICER_5,
			group = CHAT_CHANNEL_PARTY,
			say = CHAT_CHANNEL_SAY,
			yell = CHAT_CHANNEL_YELL,
			zone = CHAT_CHANNEL_ZONE,
			tell = CHAT_CHANNEL_WHISPER,
			g = CHAT_CHANNEL_PARTY,
			s = CHAT_CHANNEL_SAY,
			y = CHAT_CHANNEL_YELL,
			z = CHAT_CHANNEL_ZONE,
			w = CHAT_CHANNEL_WHISPER,
		}

		local pieces = HealCounter.string_split(extra)
		local chan = channel_array.group
		local message = "message"
		local target = nil
		local error = false
		local c = string.lower(pieces[1])

		if (channel_array[c] ~= nil) then 
			chan = channel_array[c]
		end

		if chan == CHAT_CHANNEL_WHISPER or chan == CHAT_CHANNEL_WHISPER_SENT then
			if #pieces > 1 then
				local t = ""

				for i=2,#pieces do
					local space = " "

					if i == 2 then
						space = ""
					end

					t = t .. space .. pieces[i]
				end

				target = t
			else
				d("You must specify a player when trying to send the Heal Counter Report.")
				error = true
			end
		end

		local message = "*** Heal Counter Report *** "
		message = message .. "TPH: " .. HealCounter.totalUniquePlayersHealed .. " | TPR: " .. HealCounter.totalPlayersRezzed

		if HealCounter.healStreak[HealCounter.currentLevel] ~= nil then
			message = message .. " | Current Level: " .. HealCounter.healStreak[HealCounter.currentLevel]
		end

		if HealCounter.SV.bestTotalHealed > 0 and HealCounter.SV.bestTotalHealed ~= HealCounter.totalUniquePlayersHealed then
			message = message .. " | Overall Best TPH: " .. HealCounter.SV.bestTotalHealed
		end

		if HealCounter.SV.bestTotalRezzed > 0 and HealCounter.SV.bestTotalRezzed ~= HealCounter.totalPlayersRezzed then
			message = message .. " | Overall Best TPR: " .. HealCounter.SV.bestTotalRezzed
		end

		if not error then
			CHAT_SYSTEM:StartTextEntry(message, chan, target)
		end
	end

	SLASH_COMMANDS["/hcr2"] = function (extra)
		local channel_array = {
			guild1 = CHAT_CHANNEL_GUILD_1,
			guild2 = CHAT_CHANNEL_GUILD_2,
			guild3 = CHAT_CHANNEL_GUILD_3,
			guild4 = CHAT_CHANNEL_GUILD_4,
			guild5 = CHAT_CHANNEL_GUILD_5,
			g1 = CHAT_CHANNEL_GUILD_1,
			g2 = CHAT_CHANNEL_GUILD_2,
			g3 = CHAT_CHANNEL_GUILD_3,
			g4 = CHAT_CHANNEL_GUILD_4,
			g5 = CHAT_CHANNEL_GUILD_5,
			officer1 = CHAT_CHANNEL_OFFICER_1,
			officer2 = CHAT_CHANNEL_OFFICER_2,
			officer3 = CHAT_CHANNEL_OFFICER_3,
			officer4 = CHAT_CHANNEL_OFFICER_4,
			officer5 = CHAT_CHANNEL_OFFICER_5,
			o1 = CHAT_CHANNEL_OFFICER_1,
			o2 = CHAT_CHANNEL_OFFICER_2,
			o3 = CHAT_CHANNEL_OFFICER_3,
			o4 = CHAT_CHANNEL_OFFICER_4,
			o5 = CHAT_CHANNEL_OFFICER_5,
			group = CHAT_CHANNEL_PARTY,
			say = CHAT_CHANNEL_SAY,
			yell = CHAT_CHANNEL_YELL,
			zone = CHAT_CHANNEL_ZONE,
			tell = CHAT_CHANNEL_WHISPER,
			g = CHAT_CHANNEL_PARTY,
			s = CHAT_CHANNEL_SAY,
			y = CHAT_CHANNEL_YELL,
			z = CHAT_CHANNEL_ZONE,
			w = CHAT_CHANNEL_WHISPER,
		}

		local pieces = HealCounter.string_split(extra)
		local chan = channel_array.group
		local message = "message"
		local target = nil
		local error = false
		local c = string.lower(pieces[1])

		if (channel_array[c] ~= nil) then 
			chan = channel_array[c]
		end

		if chan == CHAT_CHANNEL_WHISPER or chan == CHAT_CHANNEL_WHISPER_SENT then
			if #pieces > 1 then
				local t = ""

				for i=2,#pieces do
					local space = " "

					if i == 2 then
						space = ""
					end

					t = t .. space .. pieces[i]
				end

				target = t
			else
				d("You must specify a player when trying to send the Heal Counter Report.")
				error = true
			end
		end

		local message = "*** Heal Counter Report *** "

		if HealCounter.currentSession.abilities ~= nil then
			local totalUsed = 0

			for abilityId, abilityInfo in pairs(HealCounter.currentSession.abilities) do
				totalUsed = totalUsed + abilityInfo.used
			end

			for abilityId, abilityInfo in pairs(HealCounter.currentSession.abilities) do
				local avgHeal = abilityInfo.totalHealed / abilityInfo.used
				avgHeal = string.format("%.0f", avgHeal)

				local percentageUsed = (abilityInfo.used / totalUsed) * 100

				if percentageUsed < 0 then
					percentageUsed = 0
				end

				percentageUsed = string.format("%.0f", percentageUsed)

				message = message .. " | " .. abilityInfo.Name .. ": " .. percentageUsed .. "% " .. avgHeal
			end

			if message == "*** Heal Counter Report *** " then
				message = message .. "No abilities to report on"
			end
		else
			message = message .. "No abilities to report on"
		end

		if not error then
			CHAT_SYSTEM:StartTextEntry(message, chan, target)
		end
	end
end

-- For debugging
function HealCounter.debugLog(message, level)
	if HealCounter.SV.debugOnOff == false then
		return
	end

	local levelToDebug = HealCounter.SV.debugLevel

	if levelToDebug == level or levelToDebug > level then
		d(message)
	end
end

-- Helper function for Heal Counter Report
function HealCounter.string_split(string, pattern)
	pattern = pattern or "%S+"
	local array = {}

	for i in string.gmatch(string, pattern) do
		table.insert(array, i)
	end

	return array
end

-- For turning the addon off / on when entering PVP / PVE, depending on settings
function HealCounter:OnOff()
	if (HealCounter.SV.enabledOnlyInPvP == true and HealCounter.playerInPvP == true) or HealCounter.SV.enabledOnlyInPvP == false then
		EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_COMBAT_EVENT, HealCounter.OnCombat)
		EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_RESURRECT_RESULT, HealCounter.OnRez)
		EVENT_MANAGER:RegisterForEvent(HealCounter.Name, EVENT_EFFECT_CHANGED, HealCounter.OnEffectChanged)
		EVENT_MANAGER:RegisterForEvent(HealCounter.Name, EVENT_GROUP_MEMBER_JOINED, HealCounter.OnGroupPlayerChange)
		EVENT_MANAGER:RegisterForEvent(HealCounter.Name, EVENT_GROUP_MEMBER_LEFT, HealCounter.OnGroupPlayerChange)
		EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_ACTION_LAYER_PUSHED, HealCounter.OnActionLayerChange)
		EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_ACTION_LAYER_POPPED, HealCounter.OnActionLayerChange)
		EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, HealCounter.OnGroupSupportRangeUpdate)
		EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_RESURRECT_REQUEST, HealCounter.OnSelfRez)
		EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_MOUNTED_STATE_CHANGED, HealCounter.OnMountStateChange)
		EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_PLAYER_COMBAT_STATE, HealCounter.OnPlayerCombatState)

		if HealCounter.SV.displayScreen == true and HealCounter.currentLayerIndex <= 2 then
			HealCounterWindow:SetHidden(false)
		end
	else
		EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_COMBAT_EVENT)
		EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_RESURRECT_RESULT)
		EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_EFFECT_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_GROUP_MEMBER_JOINED)
		EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_GROUP_MEMBER_LEFT)
		EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_ACTION_LAYER_PUSHED)
		EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_ACTION_LAYER_POPPED)
		EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_RESURRECT_REQUEST)
		EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_MOUNTED_STATE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(HealCounter.name, EVENT_PLAYER_COMBAT_STATE)

		if HealCounter.SV.unlocked == false then
			HealCounterWindow:SetHidden(true)
		end
	end
end

-- Creates the addon settings menu
function HealCounter:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Heal Counter",
		displayName = "|c66ccffHeal Counter",
		author = "|c4779ce@aldericon|r",
		version = string.format("%.2f", HealCounter.version),
		slashCommand = "/heal_counter",
		registerForRefresh = true,
		registerForDefaults = true
	}

	local optionsPanel = self.LAM2:RegisterAddonPanel("Heal_Counter", panelData)
	local optionsData = {}

	table.insert(optionsData, {
		type = "description",
		text = "Heal Counter is an one-in-all addon for any type of healer, in group or out, in PVP or PVE, for all situations.",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Heal Counter Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Turn OFF when satisfied with frame positions",
		tooltip = "ON - various displays can moved on the screen by left clicking and dragging, OFF - all locked in place and cannot be moved",
		default = self.defaults.unlocked,
		disabled = function()
			if self.SV.displayScreen == false and self.SV.utilizePopup == false and self.SV.purgeIndicator == 1 then
				return true
			end
		end,
		getFunc = function() return self.SV.unlocked end,
		setFunc = function(newValue) self.SV.unlocked = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Enabled only in PVP",
		tooltip = "ON - enabled in PVP only (does not include Battlegrounds), OFF - enabled everywhere",
		default = self.defaults.enabledOnlyInPvP,
		getFunc = function() return self.SV.enabledOnlyInPvP end,
		setFunc = function(newValue) self.SV.enabledOnlyInPvP = newValue self:OnOff() end,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Choose Unit Tracking Level:",
		tooltip = 'What types of units should be tracked',
		choices = {"Everything (players, NPCs, Pets, etc.)", "Players Only", "Group Members Only"},
		getFunc = function() 
			if self.SV.trackingLevel==1 then 
				return "Everything (players, NPCs, Pets, etc.)"
			elseif self.SV.trackingLevel==2 then
				return "Players Only"				
			elseif self.SV.trackingLevel==3 then
				return "Group Members Only"
			end
		end,
		setFunc = function(newValue)
			if newValue ~= self.SV.trackingLevel and newValue ~= "Everything (players, NPCs, Pets, etc.)" and self.SV.trackingLevel ~= "Group Members Only" then
				HealCounter.currentSession.players = {}
				HealCounter.currentSession.abilities = {}
			
				HealCounter.ClearSessionTables()
				
				if newValue == "Group Members Only" then
					HealCounter.totalUniquePlayersHealed = 0
					HealCounter.totalPlayersRezzed = 0
				end
			end
		
			if newValue=="Everything (players, NPCs, Pets, etc.)" then 
				self.SV.trackingLevel=1
			elseif newValue=="Players Only" then
				self.SV.trackingLevel=2
			elseif newValue=="Group Members Only" then
				self.SV.trackingLevel=3
			end
			self:InitControls()
		end,
			default = 1,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Accepted vs. All Rezzed",
		tooltip = 'ON - all rezzes count, OFF - only accepted rezzes count',
		default = self.defaults.rezType,
		disabled = function()
			if self.SV.displayScreen == false and self.SV.utilizePopup == false then
				return true
			end
		end,
		getFunc = function() return self.SV.rezType end,
		setFunc = function(newValue) self.SV.rezType = newValue end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Turn off calculations if FPS gets too low",
		tooltip = "Calculations and display updates stop when FPS gets this low",
		default = 10,
		min     = 0,
        max     = 100,
        step    = 1,
		getFunc = function() return self.SV.trackFPSNum end,
		setFunc = function(newValue) self.SV.trackFPSNum = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Show System Messages",
		tooltip = 'ON - show any system messages related to the addon (such as HCR Level), OFF - show no system messages related to the addon',
		default = self.defaults.systemMessages,
		getFunc = function() return self.SV.systemMessages end,
		setFunc = function(newValue) self.SV.systemMessages = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Rez Notification",
		tooltip = 'ON - notifies you via center screen announcement if someone accepts or denies your rez, OFF - no center screen announcement on rez decision',
		default = self.defaults.rezNotification,
		getFunc = function() return self.SV.rezNotification end,
		setFunc = function(newValue) self.SV.rezNotification = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Siege Notification",
		tooltip = 'ON - notifies you via center screen announcement when you hit someone with your siege, OFF - no center screen announcement when sieging',
		default = self.defaults.siegeNotification,
		getFunc = function() return self.SV.siegeNotification end,
		setFunc = function(newValue) self.SV.siegeNotification = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Character vs. UserID",
		tooltip = 'ON - use character name whenever possible, OFF - use UserID whenever possible',
		default = self.defaults.purgeName,
		getFunc = function() return self.SV.purgeName end,
		setFunc = function(newValue) self.SV.purgeName = newValue end,
	})
	table.insert(optionsData, {
		type = "button",
		name = "Reset Session",
		tooltip = 'Resets your session',
		func = function ()
			HealCounter.OnResetButtonClicked()
		end,
	})
	table.insert(optionsData, {
		type = "button",
		name = "Reset High Scores",
		tooltip = 'Resets your Overall Best TPH and TPR',
		func = function ()
			HealCounter.OnResetHighScores()
		end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Purge Indicator Options",
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Use Purge Indicator",
		tooltip = 'Whether to utilize a popup that will tell you when you need to cleanse yourself, or your group (PVE Only!), of debuffs.',
		choices = {"Never", "Only PVE", "Only PVP", "Always"},
		getFunc = function() 
			if self.SV.purgeIndicator==1 then 
				return "Never"
			elseif self.SV.purgeIndicator==2 then 
				return "Only PVE"
			elseif self.SV.purgeIndicator==3 then
				return "Only PVP"				
			elseif self.SV.purgeIndicator==4 then
				return "Always"
			end
		end,
		setFunc = function(newValue)
			if newValue=="Never" then 
				self.SV.purgeIndicator=1
			elseif newValue=="Only PVE" then
				self.SV.purgeIndicator=2
			elseif newValue=="Only PVP" then
				self.SV.purgeIndicator=3
			elseif newValue=="Always" then
				self.SV.purgeIndicator=4
			end
			self:InitControls()
		end,
			default = 2,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Tracking Level",
		tooltip = 'ON - yourself AND your group (PVE Only!), OFF - only yourself',
		default = self.defaults.purgeTrackingLevel,
		disabled = function()
			if self.SV.purgeIndicator == 1 then
				return true
			end
		end,
		getFunc = function() return self.SV.purgeTrackingLevel end,
		setFunc = function(newValue) self.SV.purgeTrackingLevel = newValue end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Font Size",
		tooltip = "Choose font size to use for purge indicator",
		default = 34,
		disabled = function()
			if self.SV.purgeIndicator == 1 then
				return true
			end
		end,
		min     = 24,
        max     = 50,
        step    = 1,
		getFunc = function() return self.SV.purgeFontSize end,
		setFunc = function(newValue) self.SV.purgeFontSize = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "PVP Debuffs",
		tooltip = 'ON - track only PVP debuffs while in PVP (Maim, Defile, Poisons), OFF - track all debuffs while in PVP',
		default = self.defaults.purgePVPDebuffs,
		disabled = function()
			if self.SV.purgeIndicator == 1 or self.SV.purgeIndicator == 2 then
				return true
			end
		end,
		getFunc = function() return self.SV.purgePVPDebuffs end,
		setFunc = function(newValue) self.SV.purgePVPDebuffs = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Image vs. Text",
		tooltip = 'Works only with PVP Debuffs option. ON - displays image of debuff with "Purge DEBUFF (X)" text, OFF - displays "Purge NAME (X)" text instead of debuff image',
		default = self.defaults.purgeImage,
		disabled = function()
			if self.SV.purgeIndicator == 1 or self.SV.purgePVPDebuffs == false then
				return true
			end
		end,
		getFunc = function() return self.SV.purgeImage end,
		setFunc = function(newValue) self.SV.purgeImage = newValue end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Image Size",
		tooltip = "Works only with PVP Debuffs option. Choose size to use for debuff icon.",
		default = 80,
		disabled = function()
			if self.SV.purgeIndicator == 1 or self.SV.purgePVPDebuffs == false or self.SV.purgeImage == false then
				return true
			end
		end,
		min     = 50,
        max     = 80,
        step    = 1,
		getFunc = function() return self.SV.purgeImageSize end,
		setFunc = function(newValue) self.SV.purgeImageSize = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Purge Text Up / Down",
		tooltip = "Works only with PVP Debuffs option. Choose size to use for debuff icon.",
		default = 18,
		disabled = function()
			if self.SV.purgeIndicator == 1 then
				return true
			end
		end,
		min     = -60,
        max     = 60,
        step    = 1,
		getFunc = function() return self.SV.purgeImageLabelY end,
		setFunc = function(newValue) self.SV.purgeImageLabelY = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Purge Text Left / Right",
		tooltip = "Works only with PVP Debuffs option. Choose size to use for debuff icon.",
		default = 18,
		disabled = function()
			if self.SV.purgeIndicator == 1 then
				return true
			end
		end,
		min     = -60,
        max     = 60,
        step    = 1,
		getFunc = function() return self.SV.purgeImageLabelX end,
		setFunc = function(newValue) self.SV.purgeImageLabelX = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Display Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Display Screen Values",
		tooltip = "ON - control whether to display ANY values directly on the screen, OFF - display no values",
		default = self.defaults.displayScreen,
		getFunc = function() return self.SV.displayScreen end,
		setFunc = function(newValue) self.SV.displayScreen = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Display Extra Player / Ability Information",
		tooltip = "ON - control whether to use the popup filled with extra player / ability information, OFF - not able to display popup anymore",
		default = self.defaults.utilizePopup,
		getFunc = function() return self.SV.utilizePopup end,
		setFunc = function(newValue) self.SV.utilizePopup = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Display Total Unique Players Healed (TPH)",
		tooltip = 'ON - total unique players healed shown in dispay, OFF - total unique players healed not shown',
		default = self.defaults.showTotalPlayersHealed,
		disabled = function() return not self.SV.displayScreen end,
		getFunc = function() return self.SV.showTotalPlayersHealed end,
		setFunc = function(newValue) self.SV.showTotalPlayersHealed = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "TPH per Combat",
		tooltip = 'ON - TPH is per combat instance, OFF - TPH is per session',
		default = self.defaults.totalPlayersHealedCombat,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.showTotalPlayersHealed == false then
				return true
			end
		end,
		getFunc = function() return self.SV.totalPlayersHealedCombat end,
		setFunc = function(newValue) self.SV.totalPlayersHealedCombat = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Display Total Players Rezzed (TPR)",
		tooltip = 'ON - total players rezzed shown in dispay, OFF - total players rezzed not shown',
		default = self.defaults.showTotalPlayersRezzed,
		disabled = function() return not self.SV.displayScreen end,
		getFunc = function() return self.SV.showTotalPlayersRezzed end,
		setFunc = function(newValue) self.SV.showTotalPlayersRezzed = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Choose Set #1 to track:",
		tooltip = 'Choose a set to track for the first set slot',
		requiresReload = true,
		choices = {"None", "Earthgore", "Spell Power Cure", "Transmutation", "Gossamer", "Troll King", "Meritorious Service", "Olorime"},
		disabled = function() return not self.SV.displayScreen end,
		getFunc = function() 
			if self.SV.trackingSet1==1 then 
				return "None"
			elseif self.SV.trackingSet1==2 then 
				return "Earthgore"
			elseif self.SV.trackingSet1==3 then
				return "Spell Power Cure"				
			elseif self.SV.trackingSet1==4 then
				return "Transmutation"
			elseif self.SV.trackingSet1==5 then
				return "Gossamer"
			elseif self.SV.trackingSet1==6 then
				return "Troll King"
			elseif self.SV.trackingSet1==7 then
				return "Meritorious Service"
			elseif self.SV.trackingSet1==8 then
				return "Olorime"
			elseif self.SV.trackingSet1==9 then
				return "Symphony of Blades"
			end
		end,
		setFunc = function(newValue)
			if newValue=="None" then 
				self.SV.trackingSet1=1
			elseif newValue=="Earthgore" then
				self.SV.trackingSet1=2
			elseif newValue=="Spell Power Cure" then
				self.SV.trackingSet1=3
			elseif newValue=="Transmutation" then
				self.SV.trackingSet1=4
			elseif newValue=="Gossamer" then
				self.SV.trackingSet1=5
			elseif newValue=="Troll King" then
				self.SV.trackingSet1=6
			elseif newValue=="Meritorious Service" then
				self.SV.trackingSet1=7
			elseif newValue=="Olorime" then
				self.SV.trackingSet1=8
			elseif newValue=="Symphony of Blades" then
				self.SV.trackingSet1=9
			end
			self:InitControls()
		end,
			default = 1,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Choose Set #2 to track:",
		tooltip = 'Choose a set to track for the second set slot',
		requiresReload = true,
		choices = {"None", "Earthgore", "Spell Power Cure", "Transmutation", "Gossamer", "Troll King", "Meritorious Service", "Olorime"},
		disabled = function() return not self.SV.displayScreen end,
		getFunc = function() 
			if self.SV.trackingSet2==1 then 
				return "None"
			elseif self.SV.trackingSet2==2 then 
				return "Earthgore"
			elseif self.SV.trackingSet2==3 then
				return "Spell Power Cure"				
			elseif self.SV.trackingSet2==4 then
				return "Transmutation"
			elseif self.SV.trackingSet2==5 then
				return "Gossamer"
			elseif self.SV.trackingSet2==6 then
				return "Troll King"
			elseif self.SV.trackingSet2==7 then
				return "Meritorious Service"
			elseif self.SV.trackingSet2==8 then
				return "Olorime"
			elseif self.SV.trackingSet2==9 then
				return "Symphony of Blades"
			end
		end,
		setFunc = function(newValue)
			if newValue=="None" then 
				self.SV.trackingSet2=1
			elseif newValue=="Earthgore" then
				self.SV.trackingSet2=2
			elseif newValue=="Spell Power Cure" then
				self.SV.trackingSet2=3
			elseif newValue=="Transmutation" then
				self.SV.trackingSet2=4
			elseif newValue=="Gossamer" then
				self.SV.trackingSet2=5
			elseif newValue=="Troll King" then
				self.SV.trackingSet2=6
			elseif newValue=="Meritorious Service" then
				self.SV.trackingSet2=7
			elseif newValue=="Olorime" then
				self.SV.trackingSet2=8
			elseif newValue=="Symphony of Blades" then
				self.SV.trackingSet2=9
			end
			self:InitControls()
		end,
			default = 1,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Choose Set #3 to track:",
		tooltip = 'Choose a set to track for the third set slot',
		requiresReload = true,
		choices = {"None", "Earthgore", "Spell Power Cure", "Transmutation", "Gossamer", "Troll King", "Meritorious Service", "Olorime"},
		disabled = function() return not self.SV.displayScreen end,
		getFunc = function() 
			if self.SV.trackingSet3==1 then 
				return "None"
			elseif self.SV.trackingSet3==2 then 
				return "Earthgore"
			elseif self.SV.trackingSet3==3 then
				return "Spell Power Cure"				
			elseif self.SV.trackingSet3==4 then
				return "Transmutation"
			elseif self.SV.trackingSet3==5 then
				return "Gossamer"
			elseif self.SV.trackingSet3==6 then
				return "Troll King"
			elseif self.SV.trackingSet3==7 then
				return "Meritorious Service"
			elseif self.SV.trackingSet3==8 then
				return "Olorime"
			elseif self.SV.trackingSet3==9 then
				return "Symphony of Blades"
			end
		end,
		setFunc = function(newValue)
			if newValue=="None" then 
				self.SV.trackingSet3=1
			elseif newValue=="Earthgore" then
				self.SV.trackingSet3=2
			elseif newValue=="Spell Power Cure" then
				self.SV.trackingSet3=3
			elseif newValue=="Transmutation" then
				self.SV.trackingSet3=4
			elseif newValue=="Gossamer" then
				self.SV.trackingSet3=5
			elseif newValue=="Troll King" then
				self.SV.trackingSet3=6
			elseif newValue=="Meritorious Service" then
				self.SV.trackingSet3=7
			elseif newValue=="Olorime" then
				self.SV.trackingSet3=8
			elseif newValue=="Symphony of Blades" then
				self.SV.trackingSet3=9
			end
			self:InitControls()
		end,
			default = 1,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Choose Ability to track:",
		tooltip = 'Choose an ability to track',
		requiresReload = true,
		choices = {"None", "Rapids", "Combat Prayer", "Siege Shield"},
		disabled = function() return not self.SV.displayScreen end,
		getFunc = function() 
			if self.SV.trackingAbility1==1 then 
				return "None"
			elseif self.SV.trackingAbility1==3 then
				return "Rapids"
			elseif self.SV.trackingAbility1==4 then
				return "Combat Prayer"
			elseif self.SV.trackingAbility1==5 then
				return "Siege Shield"
			end
		end,
		setFunc = function(newValue)
			if newValue=="None" then 
				self.SV.trackingAbility1=1
			elseif newValue=="Rapids" then
				self.SV.trackingAbility1=3
			elseif newValue=="Combat Prayer" then
				self.SV.trackingAbility1=4
			elseif newValue=="Siege Shield" then
				self.SV.trackingAbility1=5
			end
			self:InitControls()
		end,
			default = 2,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Choose number display for ability tracker:",
		tooltip = 'ON - both numbers are shown, OFF - only when players are in range AND need the ability are shown',
		default = self.defaults.showAbilityNum,
		disabled = function()
			if self.SV.trackingAbility1 ~= 3 or self.SV.displayScreen == false then
				return true
			end
		end,
		getFunc = function() return self.SV.showAbilityNum end,
		setFunc = function(newValue) self.SV.showAbilityNum = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Only track Rapids while mounted",
		tooltip = 'ON - if tracking rapids, only track while mounted (NTM, which means "need to mount", shown while not mounted), OFF - track rapids always',
		default = self.defaults.onlyTrackMounted,
		disabled = function()
			if self.SV.trackingAbility1 ~= 3 or self.SV.displayScreen == false then
				return true
			end
		end,
		getFunc = function() return self.SV.onlyTrackMounted end,
		setFunc = function(newValue) self.SV.onlyTrackMounted = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Screen Display Customization",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Preview Display",
		tooltip = "ON - be able to view the display while making changes, OFF - will go back to hiding when not on main screen",
		default = self.defaults.preview,
		disabled = function() return not self.SV.displayScreen end,
		getFunc = function() return self.SV.preview end,
		setFunc = function(newValue) self.SV.preview = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Make Transparent",
		tooltip = "ON - makes the display on the screen transparent, OFF - display is not transparent",
		default = self.defaults.displayScreenTransparent,
		disabled = function() return not self.SV.displayScreen end,
		getFunc = function() return self.SV.displayScreenTransparent end,
		setFunc = function(newValue) self.SV.displayScreenTransparent = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Display Icon",
		tooltip = "ON - icon is displayed, OFF - hides the icon on the display screen that opens the pop-up",
		default = self.defaults.displayIcon,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.utilizePopup == false then
				return true
			end
		end,
		getFunc = function() return self.SV.displayIcon end,
		setFunc = function(newValue) self.SV.displayIcon = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Font Size",
		tooltip = "Choose font size to use for display and popup",
		default = 18,
		disabled = function() return not self.SV.displayScreen end,
		min     = 12,
        max     = 24,
        step    = 1,
		getFunc = function() return self.SV.fontSize end,
		setFunc = function(newValue) self.SV.fontSize = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Height of Screen Display",
		tooltip = "Choose height of screen display",
		default = 130,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.displayScreenTransparent == true then
				return true
			end
		end,
		min     = 0,
        max     = 130,
        step    = 1,
		getFunc = function() return self.SV.displayHeight end,
		setFunc = function(newValue) self.SV.displayHeight = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Width of Screen Display",
		tooltip = "Choose width of screen display",
		default = 170,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.displayScreenTransparent == true then
				return true
			end
		end,
		min     = 0,
        max     = 170,
        step    = 1,
		getFunc = function() return self.SV.displayWidth end,
		setFunc = function(newValue) self.SV.displayWidth = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Icon Up / Down",
		tooltip = "Choose to move Icon up or down",
		default = 15,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.utilizePopup == false then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.iconOffsetY end,
		setFunc = function(newValue) self.SV.iconOffsetY = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Icon Left / Right",
		tooltip = "Choose to move Icon left or right",
		default = 130,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.utilizePopup == false then
				return true
			end
		end,
		min     = 0,
        max     = 140,
        step    = 1,
		getFunc = function() return self.SV.iconOffsetX end,
		setFunc = function(newValue) self.SV.iconOffsetX = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move TPH Up / Down",
		tooltip = "Choose to move TPH up or down",
		default = 15,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.showTotalPlayersHealed == false then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.tphOffsetY end,
		setFunc = function(newValue) self.SV.tphOffsetY = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move TPH Left / Right",
		tooltip = "Choose to move TPH left or right",
		default = 10,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.showTotalPlayersHealed == false then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.tphOffsetX end,
		setFunc = function(newValue) self.SV.tphOffsetX = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move TPR Up / Down",
		tooltip = "Choose to move TPR up or down",
		default = 35,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.showTotalPlayersRezzed == false then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.tprOffsetY end,
		setFunc = function(newValue) self.SV.tprOffsetY = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move TPR Left / Right",
		tooltip = "Choose to move TPR left or right",
		default = 10,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.showTotalPlayersRezzed == false then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.tprOffsetX end,
		setFunc = function(newValue) self.SV.tprOffsetX = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Set #1 Up / Down",
		tooltip = "Choose to move Set #1 up or down",
		default = 55,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.trackingSet1 == 1 then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.set1OffsetY end,
		setFunc = function(newValue) self.SV.set1OffsetY = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Set #1 Left / Right",
		tooltip = "Choose to move Set #1 left or right",
		default = 10,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.trackingSet1 == 1 then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.set1OffsetX end,
		setFunc = function(newValue) self.SV.set1OffsetX = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Set #2 Up / Down",
		tooltip = "Choose to move Set #2 up or down",
		default = 75,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.trackingSet2 == 1 then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.set2OffsetY end,
		setFunc = function(newValue) self.SV.set2OffsetY = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Set #2 Left / Right",
		tooltip = "Choose to move Set #2 left or right",
		default = 10,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.trackingSet2 == 1 then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.set2OffsetX end,
		setFunc = function(newValue) self.SV.set2OffsetX = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Set #3 Up / Down",
		tooltip = "Choose to move Set #3 up or down",
		default = 75,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.trackingSet3 == 1 then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.set3OffsetY end,
		setFunc = function(newValue) self.SV.set3OffsetY = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Set #3 Left / Right",
		tooltip = "Choose to move Set #3 left or right",
		default = 10,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.trackingSet3 == 1 then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.set3OffsetX end,
		setFunc = function(newValue) self.SV.set3OffsetX = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Ability Up / Down",
		tooltip = "Choose to move Abiity up or down",
		default = 95,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.trackingAbility1 == 1 then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.ability1OffsetY end,
		setFunc = function(newValue) self.SV.ability1OffsetY = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Move Ability Left / Right",
		tooltip = "Choose to move Ability left or right",
		default = 10,
		disabled = function()
			if self.SV.displayScreen == false or self.SV.trackingAbility1 == 1 then
				return true
			end
		end,
		min     = 0,
        max     = 110,
        step    = 1,
		getFunc = function() return self.SV.ability1OffsetX end,
		setFunc = function(newValue) self.SV.ability1OffsetX = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Debugging",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Show Debugging Messages",
		tooltip = "ON - print debug messages to chat, OFF - No debug messages",
		default = self.defaults.debugOnOff,
		getFunc = function() return self.SV.debugOnOff end,
		setFunc = function(newValue) self.SV.debugOnOff = newValue end,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Choose Debug Level:",
		tooltip = 'How Heavy Should Debugging Be.',
		choices = {"Information", "Debug", "Everything"},
		getFunc = function() 
			if self.SV.debugLevel==1 then 
				return "Everything"
			elseif self.SV.debugLevel==2 then
				return "Debug"				
			elseif self.SV.debugLevel==3 then
				return "Everything"
			end
		end,
		setFunc = function(newValue)
			if newValue=="Information" then 
				self.SV.debugLevel=1
			elseif newValue=="Debug" then
				self.SV.debugLevel=2
			elseif newValue=="Everything" then
				self.SV.debugLevel=3
			end
			self:InitControls()
		end,
			default = 1,
	})

	self.LAM2:RegisterOptionControls("Heal_Counter", optionsData)	

	ZO_CreateStringId("SI_BINDING_NAME_HEALCOUNTER_SHOW_REPORT", "Toggle Heal Counter Report")
end

-- Saves the positioning of the display window
function HealCounter.DisplayOnMoveStop()
	HealCounter.SV.displayLeft = HealCounterWindow:GetLeft();
	HealCounter.SV.displayTop = HealCounterWindow:GetTop();
end

-- Saves the positioning of the popup
function HealCounter.PopupOnMoveStop()
	HealCounter.SV.popupLeft = HealCounterReport:GetLeft();
	HealCounter.SV.popupTop = HealCounterReport:GetTop();
end

-- Saves the position of the purge indicator
function HealCounter.PurgeOnMoveStop()
	HealCounter.SV.purgeLeft = HealCounterPurgeIndicator:GetLeft();
	HealCounter.SV.purgeTop = HealCounterPurgeIndicator:GetTop();
end

-- As settings are changed, hides or displays various features
function HealCounter:InitControls()
	HealCounterWindow:ClearAnchors();
	HealCounterWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HealCounter.SV.displayLeft, HealCounter.SV.displayTop);

	HealCounterWindow:SetMouseEnabled(HealCounter.SV.unlocked) 
	HealCounterWindow:SetMovable(HealCounter.SV.unlocked)
	
	HealCounterReport:ClearAnchors();
	HealCounterReport:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HealCounter.SV.popupLeft, HealCounter.SV.popupTop);

	HealCounterReport:SetMouseEnabled(HealCounter.SV.unlocked) 
	HealCounterReport:SetMovable(HealCounter.SV.unlocked)
	HealCounterPurgeIndicatorPurgeLabel:SetHidden(true)

	if HealCounter.SV.purgeImage == true and HealCounter.SV.purgePVPDebuffs == true then
		HealCounterPurgeIndicatorPurgeImage:SetTexture('esoui/art/icons/ability_debuff_root.dds')
		HealCounterPurgeIndicatorPurgeImage:SetHidden(false)
		HealCounterPurgeIndicatorPurgeLabel:SetHidden(false)
		HealCounterPurgeIndicatorPurgeLabel:SetColor(255, 255, 255, 255)
		HealCounterPurgeIndicatorPurgeLabel:SetText("Purge DEBUFF (X)")
	else
		HealCounterPurgeIndicatorPurgeLabel:SetColor(255, 255, 255, 255)
		HealCounterPurgeIndicatorPurgeLabel:SetText("Purge Indicator")
		HealCounterPurgeIndicatorPurgeImage:SetHidden(true)
		HealCounterPurgeIndicatorPurgeLabel:SetHidden(false)
	end

	HealCounterPurgeIndicator:ClearAnchors();
	HealCounterPurgeIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HealCounter.SV.purgeLeft, HealCounter.SV.purgeTop);

	HealCounterPurgeIndicator:SetMouseEnabled(HealCounter.SV.unlocked) 
	HealCounterPurgeIndicator:SetMovable(HealCounter.SV.unlocked)

	if HealCounter.SV.purgeIndicator ~= 1 then
		HealCounterPurgeIndicator:SetHidden(not HealCounter.SV.unlocked)
		HealCounterPurgeIndicatorPurgeLabel:SetFont("$(BOLD_FONT)|" .. HealCounter.SV.purgeFontSize)
		HealCounterPurgeIndicatorPurgeImage:SetDimensions(HealCounter.SV.purgeImageSize, HealCounter.SV.purgeImageSize);

		HealCounterPurgeIndicatorPurgeLabel:ClearAnchors();
		HealCounterPurgeIndicatorPurgeLabel:SetAnchor(CENTER, HealCounterPurgeIndicatorPurgeImage, CENTER, HealCounter.SV.purgeImageLabelX, HealCounter.SV.purgeImageLabelY);
	else
		HealCounterPurgeIndicator:SetHidden(true)
	end

	if HealCounter.SV.displayScreen == true then
		if HealCounter.SV.displayHeight > 130 then
			HealCounter.SV.displayHeight = 130
		end

		if HealCounter.SV.displayWidth > 170 then
			HealCounter.SV.displayWidth = 170
		end

		HealCounterWindow:SetHeight(HealCounter.SV.displayHeight)
		HealCounterWindow:SetWidth(HealCounter.SV.displayWidth)
		HealCounterWindowPopupButton:SetAnchor(TOPLEFT, HealCounterWindow, TOPLEFT, HealCounter.SV.iconOffsetX, HealCounter.SV.iconOffsetY)
		HealCounterWindowTPH:SetAnchor(TOPLEFT, HealCounterWindow, TOPLEFT, HealCounter.SV.tphOffsetX, HealCounter.SV.tphOffsetY)
		HealCounterWindowTPR:SetAnchor(TOPLEFT, HealCounterWindow, TOPLEFT, HealCounter.SV.tprOffsetX, HealCounter.SV.tprOffsetY)
		HealCounterWindowSet1:SetAnchor(TOPLEFT, HealCounterWindow, TOPLEFT, HealCounter.SV.set1OffsetX, HealCounter.SV.set1OffsetY)
		HealCounterWindowSet2:SetAnchor(TOPLEFT, HealCounterWindow, TOPLEFT, HealCounter.SV.set2OffsetX, HealCounter.SV.set2OffsetY)
		HealCounterWindowSet3:SetAnchor(TOPLEFT, HealCounterWindow, TOPLEFT, HealCounter.SV.set3OffsetX, HealCounter.SV.set3OffsetY)
		HealCounterWindowAbility1:SetAnchor(TOPLEFT, HealCounterWindow, TOPLEFT, HealCounter.SV.ability1OffsetX, HealCounter.SV.ability1OffsetY)
	end

	HealCounterWindow_Backdrop:SetHidden(HealCounter.SV.displayScreenTransparent)

	HealCounterWindowTPH:SetHidden(not HealCounter.SV.showTotalPlayersHealed)
	
	HealCounterWindowTPR:SetHidden(not HealCounter.SV.showTotalPlayersRezzed)

	if HealCounter.SV.trackingSet1 == 1 then
		HealCounterWindowSet1:SetHidden(true)
		HealCounterReportSortSet1Column:SetHidden(true)
	elseif HealCounter.SV.trackingSet1 ~= 1 then
		HealCounterWindowSet1:SetHidden(false)
		HealCounterReportSortSet1Column:SetHidden(false)
	end

	if HealCounter.SV.trackingSet2 == 1 then
		HealCounterWindowSet2:SetHidden(true)
		HealCounterReportSortSet2Column:SetHidden(true)
	elseif HealCounter.SV.trackingSet2 ~= 1 then
		HealCounterWindowSet2:SetHidden(false)
		HealCounterReportSortSet2Column:SetHidden(false)
	end

	if HealCounter.SV.trackingSet3 == 1 then
		HealCounterWindowSet3:SetHidden(true)
		HealCounterReportSortSet3Column:SetHidden(true)
	elseif HealCounter.SV.trackingSet3 ~= 1 then
		HealCounterWindowSet3:SetHidden(false)
		HealCounterReportSortSet3Column:SetHidden(false)
	end

	if HealCounter.SV.trackingAbility1 == 1 then
		HealCounterWindowAbility1:SetHidden(true)
		HealCounterReportSortAbility1Column:SetHidden(true)
	elseif HealCounter.SV.trackingAbility1 ~= 1 then
		HealCounterWindowAbility1:SetHidden(false)
		HealCounterReportSortAbility1Column:SetHidden(false)
	end

	if HealCounter.SV.trackingAbility1 == 5 then
		HealCounterReportSortAbility1Column:SetHidden(true)
	end

	if HealCounter.currentLayerIndex > 2 and HealCounter.SV.preview == false then
		HealCounterWindow:SetHidden(true)
	elseif HealCounter.currentLayerIndex <= 2 and HealCounter.SV.preview == false then
		HealCounterWindow:SetHidden(not HealCounter.SV.displayScreen)
	elseif HealCounter.SV.preview == true then
		HealCounterWindow:SetHidden(false)
	end

	HealCounterReportBestTPH:SetText("Overall Best TPH: "..HealCounter.SV.bestTotalHealed)
	HealCounterReportBestTPR:SetText("Overall Best TPR: "..HealCounter.SV.bestTotalRezzed)

	if HealCounter.SV.utilizePopup == false then
		HealCounterWindowPopupButton:SetHidden(true)
	elseif HealCounter.SV.utilizePopup == true then
		HealCounterWindowPopupButton:SetHidden(not HealCounter.SV.displayIcon)
	end

	if HealCounter.SV.displayScreen == true then
		HealCounterWindowTPH:SetFont("$(MEDIUM_FONT)|" .. HealCounter.SV.fontSize)
		HealCounterWindowTPR:SetFont("$(MEDIUM_FONT)|" .. HealCounter.SV.fontSize)
		HealCounterWindowSet1:SetFont("$(MEDIUM_FONT)|" .. HealCounter.SV.fontSize)
		HealCounterWindowSet2:SetFont("$(MEDIUM_FONT)|" .. HealCounter.SV.fontSize)
		HealCounterWindowSet3:SetFont("$(MEDIUM_FONT)|" .. HealCounter.SV.fontSize)
		HealCounterWindowAbility1:SetFont("$(MEDIUM_FONT)|" .. HealCounter.SV.fontSize)
	end
end

-- Helper function for sorting tables in popup
function HealCounter.spairs(t, order)
    local keys = {}

    for k in pairs(t) do
		keys[#keys+1] = k
	end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0

    return function()
        i = i + 1

        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- Sets up abilities table; only fired once
function HealCounter:SetupAbilitiesTable()
	local tkw = HealCounterReportAbilitiesTable
	tkw:ClearAnchors()
    tkw.DataOffset = 0
    tkw.MaxLines = 9
    tkw.MaxColumns = 6
    tkw.DataLines = {}
    tkw.Lines = {}
    tkw:SetHeight(258)
    tkw:SetWidth(570)
    tkw:SetAnchor(TOPLEFT,HealCounterReport,TOPLEFT,10,360)
    tkw:SetDrawLayer(DL_BACKGROUND)
    tkw:SetMouseEnabled(true)
	tkw:SetHandler("OnMouseWheel",function(self,delta)
		if HealCounter.abilities_table == nil then
			return
		end

        local tlw = HealCounter.abilities_table
        local value = tlw.DataOffset - delta

        if value < 0 then 
            value = 0
        elseif value > HealCounter.tablelength(tlw.DataLines) - tlw.MaxLines then 
            value = HealCounter.tablelength(tlw.DataLines) - tlw.MaxLines 
        end

        tlw.DataOffset = value
        tlw.Slider:SetValue(tlw.DataOffset)
        HealCounter.UpdateSessionAbilitiesTable()
    end)

	tkw.BackGround = WINDOW_MANAGER:CreateControl(nil,tkw,CT_BACKDROP)
    tkw.BackGround:SetAnchorFill(tkw)
    tkw.BackGround:SetCenterColor(0.0, 0.0, 0.0, 0.5)   
    tkw.BackGround:SetEdgeColor(1, 1, 1, 0.5)
    tkw.BackGround:SetEdgeTexture(nil, 2, 2, 2.0, 2.0)  

    local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
    tkw.Slider = WINDOW_MANAGER:CreateControl("HealCounterAbilitiesScrollBar",tkw,CT_SLIDER)

    tkw.Slider:SetDimensions(13,tkw:GetHeight())
    tkw.Slider:SetMouseEnabled(true)
    tkw.Slider:SetThumbTexture(tex,tex,tex,13,35,0,0,1,1)
    tkw.Slider:SetValue(0)
    tkw.Slider:SetValueStep(1)
    tkw.Slider:SetAnchorFill()
    tkw.Slider:SetMinMax(0,50)
    tkw.Slider:ClearAnchors()
    tkw.Slider:SetAnchor(TOPLEFT,tkw,TOPLEFT,tkw:GetWidth() - 15,5)
    tkw.Slider:SetHandler("OnValueChanged",function(self,value,eventReason)
        if HealCounter.abilities_table == nil then
			return
		end

        local tlw = HealCounter.abilities_table
        tlw.DataOffset = math.min(value,HealCounter.tablelength(tlw.DataLines) - tlw.MaxLines)
        HealCounter.UpdateSessionAbilitiesTable()
    end)

	for i=1,tkw.MaxLines do
        tkw.Lines[i] = WINDOW_MANAGER:CreateControlFromVirtual("HealCounterAbilityTableLine_" .. i, tkw, "HealCounterTableLine")
        tkw.Lines[i]:SetDimensions(tkw:GetWidth()-10,25)

        if i == 1 then
            tkw.Lines[i]:SetAnchor(TOPLEFT,tkw,TOPLEFT,0,5)
        else
            tkw.Lines[i]:SetAnchor(TOPLEFT,tkw.Lines[i-1],BOTTOMLEFT,0,3)
        end

        local index = i
        tkw.Lines[i].Columns = {}

        for j=1,tkw.MaxColumns do 
            tkw.Lines[i].Columns[j] = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i],CT_LABEL)
            local oy = 0

            if i == 1 then
                tkw.Lines[i].Columns[j]:SetFont("ZoFontGameBold")
            else
                tkw.Lines[i].Columns[j]:SetFont("ZoFontGameSmall")
                 oy = 3
            end

            tkw.Lines[i].Columns[j]:SetDimensions(tkw.Lines[i]:GetWidth()/6,25)

            if i==1 then
                local sw, wh = tkw.Lines[i].Columns[j]:GetTextDimensions()
                tkw.Lines[i].Columns[j]:SetDimensions(sw,25)

                if j == 1 then
                     tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT,tkw.Lines[i],TOPLEFT,18,0)
                else
                    local sw, wh = tkw.Lines[i].Columns[j-1]:GetTextDimensions()
                    local ox = (tkw.Lines[i]:GetWidth()/tkw.MaxColumns) - sw

                    if j == 2 then
                        ox = ox + 25
                    end

                    if j == 3 then 
                        ox = ox - 25
                    end

                    if j == 4 then
                        ox = ox - 25
                    end

					tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j-1],TOPRIGHT, ox,oy)
                end
            else
                local w, h = tkw.Lines[1].Columns[j]:GetTextDimensions()
                local offx = 0

                if j ~= 1 and i == 2 and j ~= 5 and j ~= 6 then
                    offx = (w/2) - tkw.Lines[i].Columns[j]:GetTextDimensions()
                end

                if j ~= 1 and i == 2 and j == 6 then
                    offx = offx + 18
                end

				if j == 2 and i == 2 then
					offx = offx - 3
				end

				if j == 3 and i == 2 then
					offx = offx - 15
				end

				if j == 4 and i == 2 then
					offx = offx - 15
				end

				if j == 5 and i == 2 then
					offx = offx + 5
				end

				if j == 6 and i == 2 then
					offx = offx - 15
				end

                tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT,tkw.Lines[i-1].Columns[j],BOTTOMLEFT,offx,oy)
            end

            if i == 1 then
                if j == 1 then 
                    tkw.Lines[i].Columns[j]:SetText("Name")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].name < t[a].name end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].name > t[a].name end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.abilities_table.DataLines = dl
                            HealCounter.UpdateSessionAbilitiesTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

                if j == 2 then 
                    tkw.Lines[i].Columns[j]:SetText("Used")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].count < t[a].count end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].count > t[a].count end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.abilities_table.DataLines = dl
                            HealCounter.UpdateSessionAbilitiesTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

                if j == 3 then 
                    tkw.Lines[i].Columns[j]:SetText("Avg.")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].avgHeal < t[a].avgHeal end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].avgHeal > t[a].avgHeal end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.abilities_table.DataLines = dl
                            HealCounter.UpdateSessionAbilitiesTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

				if j == 4 then 
                    tkw.Lines[i].Columns[j]:SetText("Min.")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].minHeal < t[a].minHeal end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].minHeal > t[a].minHeal end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.abilities_table.DataLines = dl
                            HealCounter.UpdateSessionAbilitiesTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

				if j == 5 then 
                    tkw.Lines[i].Columns[j]:SetText("Max.")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].maxHeal < t[a].maxHeal end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].maxHeal > t[a].maxHeal end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.abilities_table.DataLines = dl
                            HealCounter.UpdateSessionAbilitiesTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

				if j == 6 then 
                    tkw.Lines[i].Columns[j]:SetText("Crit")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].crit < t[a].crit end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].crit > t[a].crit end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.abilities_table.DataLines = dl
                            HealCounter.UpdateSessionAbilitiesTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end
            end

            tkw.Lines[i].Columns[j]:SetHidden(false)
        end
    end

    HealCounter.abilities_table = tkw
end

-- Sets up the players table; only fired once
function HealCounter:SetupPlayerTable()
	local tkw = HealCounterReportPlayersTable
	tkw:ClearAnchors()
    tkw.DataOffset = 0
    tkw.MaxLines = 9
    tkw.MaxColumns = 8
    tkw.DataLines = {}
    tkw.Lines = {}
    tkw:SetHeight(258)
    tkw:SetWidth(570)
    tkw:SetAnchor(TOPLEFT,HealCounterReport,TOPLEFT,10,70)
    tkw:SetDrawLayer(DL_BACKGROUND)
    tkw:SetMouseEnabled(true)
	tkw:SetHandler("OnMouseWheel",function(self,delta)
        if HealCounter.players_table == nil then
			return
		end

        local tlw = HealCounter.players_table
        local value = tlw.DataOffset - delta

        if value < 0 then 
            value = 0
        elseif value > HealCounter.tablelength(tlw.DataLines) - tlw.MaxLines then 
            value = HealCounter.tablelength(tlw.DataLines) - tlw.MaxLines 
        end

        tlw.DataOffset = value
        tlw.Slider:SetValue(tlw.DataOffset)
        HealCounter.UpdateSessionPlayersTable()
    end)

	tkw.BackGround = WINDOW_MANAGER:CreateControl(nil,tkw,CT_BACKDROP)
    tkw.BackGround:SetAnchorFill(tkw)
    tkw.BackGround:SetCenterColor(0.0, 0.0, 0.0, 0.5)   
    tkw.BackGround:SetEdgeColor(1, 1, 1, 0.5)
    tkw.BackGround:SetEdgeTexture(nil, 2, 2, 2.0, 2.0)  

    local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
    tkw.Slider = WINDOW_MANAGER:CreateControl("HealCounterPlayersScrollBar",tkw,CT_SLIDER)

    tkw.Slider:SetDimensions(13,tkw:GetHeight())
    tkw.Slider:SetMouseEnabled(true)
    tkw.Slider:SetThumbTexture(tex,tex,tex,13,35,0,0,1,1)
    tkw.Slider:SetValue(0)
    tkw.Slider:SetValueStep(1)
    tkw.Slider:SetAnchorFill()
    tkw.Slider:SetMinMax(0,50)
    tkw.Slider:ClearAnchors()
    tkw.Slider:SetAnchor(TOPLEFT,tkw,TOPLEFT,tkw:GetWidth() - 15,5)
    tkw.Slider:SetHandler("OnValueChanged",function(self,value,eventReason)
        if HealCounter.players_table == nil then
			return
		end

        local tlw = HealCounter.players_table
        tlw.DataOffset = math.min(value,HealCounter.tablelength(tlw.DataLines) - tlw.MaxLines)
        HealCounter.UpdateSessionPlayersTable()
    end)

	local set1 = HealCounter.SV.trackingSet1
	local set2 = HealCounter.SV.trackingSet2
	local set3 = HealCounter.SV.trackingSet3
	local ability1 = HealCounter.SV.trackingAbility1

	for i=1,tkw.MaxLines do
        tkw.Lines[i] = WINDOW_MANAGER:CreateControlFromVirtual("HealCounterPlayerTableLine_" .. i, tkw, "HealCounterTableLine")
        tkw.Lines[i]:SetDimensions(tkw:GetWidth()-10,25)

        if i == 1 then
            tkw.Lines[i]:SetAnchor(TOPLEFT,tkw,TOPLEFT,0,5)
        else
            tkw.Lines[i]:SetAnchor(TOPLEFT,tkw.Lines[i-1],BOTTOMLEFT,0,3)
        end

        local index = i
        tkw.Lines[i].Columns = {}

        for j=1,tkw.MaxColumns do 
            tkw.Lines[i].Columns[j] = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i],CT_LABEL)
            local oy = 0

            if i == 1 then
                tkw.Lines[i].Columns[j]:SetFont("ZoFontGameBold")
            else
                tkw.Lines[i].Columns[j]:SetFont("ZoFontGameSmall")
                 oy = 3
            end

            tkw.Lines[i].Columns[j]:SetDimensions(tkw.Lines[i]:GetWidth()/6,25)

            if i==1 then
                local sw, wh = tkw.Lines[i].Columns[j]:GetTextDimensions()

                tkw.Lines[i].Columns[j]:SetDimensions(sw,25)

                if j == 1 then
                     tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT,tkw.Lines[i],TOPLEFT,18,0)
                else
                    local sw, wh = tkw.Lines[i].Columns[j-1]:GetTextDimensions()
                    local ox = (tkw.Lines[i]:GetWidth()/tkw.MaxColumns) - sw

                    if j == 2 then
                        ox = ox + 20
                    end

					if j == 3 then
                        ox = ox + 30
                    end

                    if j == 4 then
                        ox = ox - 25
                    end

					if j == 5 then
						ox = ox - 30
					end

					if j == 6 then
						ox = ox - 30
					end

					tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j-1],TOPRIGHT, ox,oy)
                end
            else
                local w, h = tkw.Lines[1].Columns[j]:GetTextDimensions()
                local offx = 0

                if j ~= 1 and i == 2 and j ~= 5 and j ~= 6 then
                    offx = (w/2) - tkw.Lines[i].Columns[j]:GetTextDimensions()
                end

                if j ~= 1 and i == 2 and j == 6 then
                    offx = offx + 18
                end

				if j == 2 and i == 2 then
					offx = offx - 27
				end

				if j == 5 and i == 2 then
					offx = offx + 8
				end

				if j == 6 and i == 2 then
					offx = offx - 6
				end

                tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT,tkw.Lines[i-1].Columns[j],BOTTOMLEFT,offx,oy)
            end

            if i == 1 then
                if j == 1 then 
                    tkw.Lines[i].Columns[j]:SetText("Name")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].name < t[a].name end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].name > t[a].name end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.players_table.DataLines = dl
                            HealCounter.UpdateSessionPlayersTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

				if j == 2 then 
                    tkw.Lines[i].Columns[j]:SetText("UserID")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].atName < t[a].atName end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].atName > t[a].atName end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.players_table.DataLines = dl
                            HealCounter.UpdateSessionPlayersTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

                if j == 3 then 
                    tkw.Lines[i].Columns[j]:SetText("Heal")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].count < t[a].count end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].count > t[a].count end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.players_table.DataLines = dl
                            HealCounter.UpdateSessionPlayersTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

                if j == 4 then 
                    tkw.Lines[i].Columns[j]:SetText("Rez")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].rezzed < t[a].rezzed end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].rezzed > t[a].rezzed end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.players_table.DataLines = dl
                            HealCounter.UpdateSessionPlayersTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

				if j == 5 and set1 ~= 1 then
					local set1Text = "Set1"

					if set1 == 2 then
						set1Text = "EG"
					elseif set1 == 3 then
						set1Text = "SPC"
					elseif set1 == 4 then
						set1Text = "TRS"
					elseif set1 == 5 then
						set1Text = "GOS"
					elseif set1 == 6 then
						set1Text = "TRK"
					elseif set1 == 7 then
						set1Text = "MS"
					elseif set1 == 8 then
						set1Text = "OLO"
					elseif set1 == 9 then
						set1Text = "SB"
					end

                    tkw.Lines[i].Columns[j]:SetText(set1Text)
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set1 < t[a].set1 end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set1 > t[a].set1 end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.players_table.DataLines = dl
                            HealCounter.UpdateSessionPlayersTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

				if j == 6 and set2 ~= 1 then
					local set2Text = "Set2"

					if set2 == 2 then
						set2Text = "EG"
					elseif set2 == 3 then
						set2Text = "SPC"
					elseif set2 == 4 then
						set2Text = "TRS"
					elseif set2 == 5 then
						set2Text = "GOS"
					elseif set2 == 6 then
						set2Text = "TRK"
					elseif set2 == 7 then
						set2Text = "MS"
					elseif set2 == 8 then
						set2Text = "OLO"
					elseif set2 == 9 then
						set2Text = "SB"
					end

                    tkw.Lines[i].Columns[j]:SetText(set2Text)
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set2 < t[a].set2 end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set2 > t[a].set2 end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.players_table.DataLines = dl
                            HealCounter.UpdateSessionPlayersTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

				if j == 7 and set3 ~= 1 then
					local set3Text = "Set3"

					if set3 == 2 then
						set3Text = "EG"
					elseif set3 == 3 then
						set3Text = "SPC"
					elseif set3 == 4 then
						set3Text = "TRS"
					elseif set3 == 5 then
						set3Text = "GOS"
					elseif set3 == 6 then
						set3Text = "TRK"
					elseif set3 == 7 then
						set3Text = "MS"
					elseif set3 == 8 then
						set3Text = "OLO"
					elseif set3 == 9 then
						set3Text = "SB"
					end

                    tkw.Lines[i].Columns[j]:SetText(set3Text)
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set3 < t[a].set3 end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set3 > t[a].set3 end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.players_table.DataLines = dl
                            HealCounter.UpdateSessionPlayersTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

				if j == 8 and ability1 ~= 1 and ability1 ~= 5 then
					local ability1Text = "AB1"

					if ability1 == 3 then
						ability1Text = "RPD"
					elseif ability1 == 4 then
						ability1Text = "CBP"
					end

                    tkw.Lines[i].Columns[j]:SetText(ability1Text)
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].ability1 < t[a].ability1 end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].ability1 > t[a].ability1 end) do
                                    table.insert(dl, v)
                                end
                            end

                            HealCounter.players_table.DataLines = dl
                            HealCounter.UpdateSessionPlayersTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end
            end

            tkw.Lines[i].Columns[j]:SetHidden(false)
        end
    end

    HealCounter.players_table = tkw
end

function HealCounter.sortPlayerName()
	local tkw = HealCounterReportPlayersTable

	local i = 1
	local j = 1

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].name < t[a].name end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].name > t[a].name end) do
			table.insert(dl, v)
		end
	end

	HealCounter.players_table.DataLines = dl
	HealCounter.UpdateSessionPlayersTable()
end

function HealCounter.sortPlayerAtName()
	local tkw = HealCounterReportPlayersTable

	local i = 1
	local j = 2

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].atName < t[a].atName end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].atName > t[a].atName end) do
			table.insert(dl, v)
		end
	end

	HealCounter.players_table.DataLines = dl
	HealCounter.UpdateSessionPlayersTable()
end

function HealCounter.sortPlayerHeal()
	local tkw = HealCounterReportPlayersTable

	local i = 1
	local j = 3

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].count < t[a].count end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].count > t[a].count end) do
			table.insert(dl, v)
		end
	end

	HealCounter.players_table.DataLines = dl
	HealCounter.UpdateSessionPlayersTable()
end

function HealCounter.sortPlayerRez()
	local tkw = HealCounterReportPlayersTable

	local i = 1
	local j = 4

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].rezzed < t[a].rezzed end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].rezzed > t[a].rezzed end) do
			table.insert(dl, v)
		end
	end

	HealCounter.players_table.DataLines = dl
	HealCounter.UpdateSessionPlayersTable()
end

function HealCounter.sortPlayerSet1()
	local tkw = HealCounterReportPlayersTable

	local i = 1
	local j = 5

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set1 < t[a].set1 end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set1 > t[a].set1 end) do
			table.insert(dl, v)
		end
	end

	HealCounter.players_table.DataLines = dl
	HealCounter.UpdateSessionPlayersTable()
end

function HealCounter.sortPlayerSet2()
	local tkw = HealCounterReportPlayersTable

	local i = 1
	local j = 6

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set2 < t[a].set2 end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set2 > t[a].set2 end) do
			table.insert(dl, v)
		end
	end

	HealCounter.players_table.DataLines = dl
	HealCounter.UpdateSessionPlayersTable()
end

function HealCounter.sortPlayerSet3()
	local tkw = HealCounterReportPlayersTable

	local i = 1
	local j = 7

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set3 < t[a].set3 end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].set3 > t[a].set3 end) do
			table.insert(dl, v)
		end
	end

	HealCounter.players_table.DataLines = dl
	HealCounter.UpdateSessionPlayersTable()
end

function HealCounter.sortPlayerAbility1()
	local tkw = HealCounterReportPlayersTable

	local i = 1
	local j = 8

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].ability1 < t[a].ability1 end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.players_table.DataLines, function(t,a,b) return t[b].ability1 > t[a].ability1 end) do
			table.insert(dl, v)
		end
	end

	HealCounter.players_table.DataLines = dl
	HealCounter.UpdateSessionPlayersTable()
end

function HealCounter.sortAbilityName()
	local tkw = HealCounterReportAbilitiesTable

	local i = 1
	local j = 1

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].name < t[a].name end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].name > t[a].name end) do
			table.insert(dl, v)
		end
	end

	HealCounter.abilities_table.DataLines = dl
	HealCounter.UpdateSessionAbilitiesTable()
end

function HealCounter.sortAbilityUsed()
	local tkw = HealCounterReportAbilitiesTable

	local i = 1
	local j = 2

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].count < t[a].count end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].count > t[a].count end) do
			table.insert(dl, v)
		end
	end

	HealCounter.abilities_table.DataLines = dl
	HealCounter.UpdateSessionAbilitiesTable()
end

function HealCounter.sortAbilityAvg()
	local tkw = HealCounterReportAbilitiesTable

	local i = 1
	local j = 3

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].avgHeal < t[a].avgHeal end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].avgHeal > t[a].avgHeal end) do
			table.insert(dl, v)
		end
	end

	HealCounter.abilities_table.DataLines = dl
	HealCounter.UpdateSessionAbilitiesTable()
end

function HealCounter.sortAbilityMin()
	local tkw = HealCounterReportAbilitiesTable

	local i = 1
	local j = 4

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].minHeal < t[a].minHeal end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].minHeal > t[a].minHeal end) do
			table.insert(dl, v)
		end
	end

	HealCounter.abilities_table.DataLines = dl
	HealCounter.UpdateSessionAbilitiesTable()
end

function HealCounter.sortAbilityMax()
	local tkw = HealCounterReportAbilitiesTable

	local i = 1
	local j = 5

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].maxHeal < t[a].maxHeal end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].maxHeal > t[a].maxHeal end) do
			table.insert(dl, v)
		end
	end

	HealCounter.abilities_table.DataLines = dl
	HealCounter.UpdateSessionAbilitiesTable()
end

function HealCounter.sortAbilityCrit()
	local tkw = HealCounterReportAbilitiesTable

	local i = 1
	local j = 6

	tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
	local dl = {}

	if tkw.Lines[i].Columns[j].SortButton.Desc then
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].crit < t[a].crit end) do
			table.insert(dl, v)
		end
	else
		for k,v in HealCounter.spairs(HealCounter.abilities_table.DataLines, function(t,a,b) return t[b].crit > t[a].crit end) do
			table.insert(dl, v)
		end
	end

	HealCounter.abilities_table.DataLines = dl
	HealCounter.UpdateSessionAbilitiesTable()
end


-- Open the popup
function HealCounter.OpenReport()
    HealCounterReport:SetHidden(false)
	HealCounterReport._isHidden = false;

	HealCounterReportBestTPH:SetText("Overall Best TPH: "..HealCounter.SV.bestTotalHealed)
	HealCounterReportBestTPR:SetText("Overall Best TPR: "..HealCounter.SV.bestTotalRezzed)
	
	HealCounter.UpdateTables()
end

-- Updates the popup
function HealCounter.UpdateTables()
	if HealCounter.players_table ~= nil then
		local tkw = HealCounter.players_table

		tkw.DataLines = {}

		if HealCounter.currentSession.players ~= nil then
			for playerName, playerInfo in pairs(HealCounter.currentSession.players) do
				if playerInfo.numHealed > 0 or playerInfo.numRezzed > 0 or playerInfo.set1 > 0 or playerInfo.set2 > 0 or playerInfo.set3 > 0 or playerInfo.ability1 > 0 then
					local data = {["name"] = playerName, ["count"] = playerInfo.numHealed, ["rezzed"] = playerInfo.numRezzed, ["atName"] = playerInfo.atName, ["set1"] = playerInfo.set1, ["set2"] = playerInfo.set2, ['set3'] = playerInfo.set3, ["ability1"] = playerInfo.ability1}
					table.insert(tkw.DataLines, data)
				end
			end
		end
	end

	if HealCounter.abilities_table ~= nil then
		local tlw = HealCounter.abilities_table

		tlw.DataLines = {}

		if HealCounter.currentSession.abilities ~= nil then
			local abilitiesAlreadyListed = {}
		
			for abilityId, abilityInfo in pairs(HealCounter.currentSession.abilities) do
				if abilitiesAlreadyListed[abilityInfo.Name] == nil then
					local avgHeal = abilityInfo.totalHealed / abilityInfo.used
					avgHeal = tonumber(string.format("%.0f", avgHeal))

					local critPercentage = (abilityInfo.totalCrit / abilityInfo.used) * 100

					if critPercentage < 0 then
						critPercentage = 0
					end

					critPercentage = tonumber(string.format("%.0f", critPercentage))

					local data = {["name"] = abilityInfo.Name, ["count"] = abilityInfo.used, ["avgHeal"] = avgHeal, ["minHeal"] = abilityInfo.minHeal, ["maxHeal"] = abilityInfo.maxHeal, ["crit"] = critPercentage}
					abilitiesAlreadyListed[abilityInfo.Name] = true
					table.insert(tlw.DataLines, data)
				end
			end
		end
	end

	HealCounter.UpdateSessionPlayersTable()
	HealCounter.UpdateSessionAbilitiesTable()
end

-- Helper function for generating the popup's tables
function HealCounter.tablelength(T)
	local count = 0

	for _ in pairs(T) do
		count = count + 1
	end

	return count
end

-- When resetting the session, clears up the popup
function HealCounter.ClearSessionTables()
	local pt = HealCounter.players_table
	local at = HealCounter.abilities_table

	pt.Slider:SetMinMax(0,0)
	at.Slider:SetMinMax(0,0)

	local pt_pk = pt.DataOffset
	local at_pk = at.DataOffset

	for i = 2,pt.MaxLines do
		if pt_pk + (i-1) > #pt.DataLines then
			break
		end

        local curLine = pt.Lines[i]

        curLine.Columns[1]:SetText('')
		curLine.Columns[2]:SetText('')
        curLine.Columns[3]:SetText('')
        curLine.Columns[4]:SetText('')
		curLine.Columns[5]:SetText('')
		curLine.Columns[6]:SetText('')
		curLine.Columns[7]:SetText('')
    end 

	pt.DataLines = {}

	for i = 2,at.MaxLines do
		if at_pk + (i-1) > #at.DataLines then
			break
		end

        local curLine = at.Lines[i]

        curLine.Columns[1]:SetText('')
		curLine.Columns[2]:SetText('')
        curLine.Columns[3]:SetText('')
        curLine.Columns[4]:SetText('')
		curLine.Columns[5]:SetText('')
		curLine.Columns[6]:SetText('')
    end 

	at.DataLines = {}
end

-- Updates the players table
function HealCounter.UpdateSessionPlayersTable(...)
    if HealCounter.players_table == nil then
		return
	end

    local tlw = HealCounter.players_table

    tlw.DataOffset = tlw.DataOffset or 0

    if tlw.DataOffset < 0 then
		tlw.DataOffset = 0
	end

    if HealCounter.tablelength(tlw.DataLines) == 0 then 
		return
	end

    tlw.Slider:SetMinMax(0,HealCounter.tablelength(tlw.DataLines) - tlw.MaxLines)

	local pk = tlw.DataOffset

    for i = 2,tlw.MaxLines do
        if pk + (i-1) > #tlw.DataLines then
			break
		end

        local curLine = tlw.Lines[i]
        local curData = tlw.DataLines[pk + i -1]
		local rezzed = curData.rezzed

		if curData.name == HealCounter.playerName then
			rezzed = "|c4779ce"..HealCounter.selfTotalRezzed
		end

        curLine.Columns[1]:SetText(curData.name)
		curLine.Columns[2]:SetText(curData.atName)
        curLine.Columns[3]:SetText(curData.count)
        curLine.Columns[4]:SetText(rezzed)

		if HealCounter.SV.trackingSet1 ~= 1 then
			curLine.Columns[5]:SetText(curData.set1)
		end

		if HealCounter.SV.trackingSet2 ~= 1 then
			curLine.Columns[6]:SetText(curData.set2)
		end

		if HealCounter.SV.trackingSet3 ~= 1 then
			curLine.Columns[7]:SetText(curData.set3)
		end

		if HealCounter.SV.trackingAbility1 ~= 1 and HealCounter.SV.trackingAbility1 ~= 5 then
			curLine.Columns[8]:SetText(curData.ability1)
		end
    end 
end

-- Updates the abilities table
function HealCounter.UpdateSessionAbilitiesTable(...)
    if HealCounter.abilities_table == nil then
		return
	end

    local tlw = HealCounter.abilities_table

    tlw.DataOffset = tlw.DataOffset or 0

    if tlw.DataOffset < 0 then
		tlw.DataOffset = 0
	end

    if HealCounter.tablelength(tlw.DataLines) == 0 then 
	  return
	end

    tlw.Slider:SetMinMax(0,HealCounter.tablelength(tlw.DataLines) - tlw.MaxLines)

	local pk = tlw.DataOffset

    for i = 2,tlw.MaxLines do
        if pk + (i-1) > #tlw.DataLines then
			break
		end

        local curLine = tlw.Lines[i]
        local curData = tlw.DataLines[pk + i -1]

        curLine.Columns[1]:SetText(curData.name)
		curLine.Columns[2]:SetText(curData.count)
        curLine.Columns[3]:SetText(curData.avgHeal)
		curLine.Columns[4]:SetText(curData.minHeal)
		curLine.Columns[5]:SetText(curData.maxHeal)
		curLine.Columns[6]:SetText(curData.crit.."%")
    end 
end

-- To able to manually close the popup
function HealCounter.CloseReport()
    HealCounterReport:SetHidden(true)
	HealCounterReport._isHidden = true;
end

-- Toggling report with keybinding
function HealCounter.ToggleReport()
	if HealCounterReport._isHidden == true then
		HealCounter.OpenReport()
	elseif HealCounterReport._isHidden == false then
		HealCounter.CloseReport()
	else
		HealCounter.OpenReport()
	end
end
