--[[



                         ----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----


                      #####        #####    ###########         #       #   #       #        ###########  #  #       #  ###########
                    ##     ##    ##     ##       #             # #     # #   #     #         #            #  #       #  #
                   #         #  #         #      #             #  #   #  #    #   #          #            #   #     #   #
                   #            #         #      #             #   # #   #     # #           #            #   #     #   #
                   #     #####  #         #      #             #    #    #      #            ########     #    #   #    ########
                   #         #  #         #      #             #         #      #            #            #    #   #    #
                   #         #  #         #      #             #         #      #            #            #     # #     #
                    ##     ##    ##     ##       #             #         #      #            #            #     # #     #
                      #####        #####         #             #         #      #            #            #      #      ###########


                         ----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----


                                                         ----o----(||)----oo----(||)----o----

                                                                  v1.13 22nd May 2019
                                                          Copyright (C) Taraezor / Chris Birch

                                                         ----o----(||)----oo----(||)----o----



	Description
	===========
	Removes guild recruitment spam from chat. Simple, fast, efficient.


	Got My Five - Scoring
	=====================

	Guild recruitment messages all share one thing in common: certain words are likely to appear in the chat spam. Words such as "guild", "pst",
	"looking", "member", and "recruit" are likely to appear. Along with some fancy formatting and we have the makings of a profile of very
	probable guild recruitment spam.

	Each hit on a key word or characteristic is noted and if the message exceeds a (fairly low) score then it is flagged as spam.

	Use "/gmf" in chat for configurable parameters.




                                                         ----o----(||)----oo----(||)----o----



	About Taraezor
	==============

	My real name is Chris Birch and I reside in Sydney, Australia. I was once a mainframe applications/systems designer/analyst with proficiency in
	JCL, CList, ADABAS/Natural environments with a penchant for Core Dumps, algorithms and elegant design. Languages also include Pascal, BASIC,
	COBOL, Assembler, 6502 Machine Code, Lua, FORTRAN, with familiarity of a score of others such as SNOBOL.

	Since the early 80's I have developed a number of utilities for PC/Apple ][/Mac. Most recently, I am the developer of the "We Don't Wipe" AddOn
	for World of Warcraft which is a "DPS maximiser". I have developed numerous other WoW AddOns. In TESO I am also the author of "Spam Bam", the
	unique and fast way to remove gold spam from chat!

                                                         ----o----(||)----oo----(||)----o----

	My all-time favourite games include The Last of Us, Diablo, ESO, Borderlands, WoW, Wizardry, Zork, The Hitchhiker's Guide to the Galaxy,
	Simpsons Hit and Run, Rayman 3, Pokémon, Professor Layton, Civilization, Final Fantasy, Skyrim, 80 Days, Escape Velocity and Red Dead Redemption.

	My online gaming presence is usually as Taraezor, Tarocalypse, or similar. I am currently Guild Master of "How Do You Exit Cyrodiil".

                                                         ----o----(||)----oo----(||)----o----



--==================================================================================================================================================--
--||                                                                                                                                              ||--
--||                                                     --=<[:::     CHANGE LOG     :::]>=--                                                     ||--
--||                                                                                                                                              ||--
--==================================================================================================================================================--

v1.13 - 22nd May 2019
=====
* Improved testing to catch marginal positives
* Version number change to keep it "up to date" with the latest API of 100027

v1.12 - 10th September 2017
=====
* Activated "GuildChat" option
* Complete revamp of text colouring for the /gmf menu and parameters
* Complete overhaul of the way setting and reporting parameters works
* "Discord" hits has a higher weighting now. Plus 1 to the total if >= 1 was found

v1.11 - 7th September 2017
=====
* Version number change to keep it "up to date" with the latest API of 100020

v1.10 - 5th June 2017
=====
* Parameter to include/exclude guid chat (officer chat for now is still never tested )
* Added DebMin, DebMax
* Version number change to keep it "up to date" with the latest API of 100019

v1.09 - 18th December 2016
=====
* Added Discord to the list of flags
* Bugfix: minscore/minlen parameters required all uppercase for test to succeed
* More robust checking of minscore/minlen parameters to capture nul values

v1.08 - 6th December 2016
=====
* Just a version number change to keep it "up to date" with the latest API of 100017
* Delete and debug chat commands now also cause the settings to be listed
* Improved chat commands

v1.07 - 24th July 2016
=====
* Just a version number change to keep it "up to date" with the latest API of 100015

v1.06 - 15th January 2016
=====
* Just a version number change to keep it "up to date" with the latest API of 100013
* Added version number saved parameter

v1.05 - 27th April 2015
=====
* Just a version number change to keep it "up to date" with the latest API of 100011

v1.04 - 18th January 2015
=====
* Just a version number change to keep it "up to date" with the latest API of 100010

v1.03 - 6th October 2014
=====
* Just a version number change to keep it "up to date" with the latest API of 100009

v1.02 - 23rd August 2014
=====
* Just a version number change to keep it "up to date" with the latest API of 100008
* Couple of default parameter values tweaked for better performance

v1.01 - 28th June 2014
=====
* Minor Bug Fix: In game default reset now uses correct default values.
* Works with API 100007

v1.00 - 16th June 2014
=====
* Initial release for API 100004

]]

--==================================================================================================================================================--
--||                                                                                                                                              ||--
--||                                                   --=<[:::   GLOBAL AND DEFAULTS   :::]>=--                                                  ||--
--||                                                                                                                                              ||--
--==================================================================================================================================================--

local defaults	= {

	savedMinScore	= 5,
	savedMinLength	= 30,
	savedDelete	= true,
	savedDebug	= false,
	savedDebMin	= 3,
	savedDebMax	= 7,
	savedGuildChat	= true
}

GotMyFive		= {}
GotMyFive.SavedVar	= {

	savedMinScore	= defaults.savedMinScore,
	savedMinLength	= defaults.savedMinLength,
	savedDelete	= defaults.savedDelete,
	savedDebug	= defaults.savedDebug,
	savedDebMin	= defaults.savedDebMin,
	savedDebMax	= defaults.savedDebMax,
	savedGuildChat	= defaults.savedGuildChat,

	version		= 1.14
}

--==================================================================================================================================================--
--||                                                                                                                                              ||--
--||                                                     --=<[:::   SLASH HANDLERS   :::]>=--                                                     ||--
--||                                                                                                                                              ||--
--==================================================================================================================================================--

local function GetWords( parameterStr)

	local i, parameters = 1, {}
	for word in string.gfind(parameterStr, "(%w+)") do
		parameters[i] = word
		i=i+1
	end
	return parameters
end

local function Slash( parameterStr)

	parameterStr = zo_strupper( parameterStr)
	local parameters = GetWords( parameterStr)

	if ((#parameters == 0) or (parameters[1] == "HELP")) then
		d("|c1E90FFUse|r /gmf |c1E90FFor|r /gm5 |c1E90FFor|r /gotmyfive")
		d("/gmf delete |c1E90FFto toggle deleting the spam. Currently: |r"..tostring(GotMyFive.SavedVar.savedDelete))
		d("/gmf debug |c1E90FFto toggle debug mode. Currently: |r".. tostring(GotMyFive.SavedVar.savedDebug))
		d("/gmf parms |c1E90FFfor a list of parameter values you may set|r")
	elseif (parameters[1] == "DELETE") or (parameters[1] == "DEL") then
		GotMyFive.SavedVar.savedDelete = not GotMyFive.SavedVar.savedDelete
		d("|c1E90FFDelete value is now: |r"..tostring(GotMyFive.SavedVar.savedDelete))
	elseif (parameters[1] == "DEBUG") or (parameters[1] == "DEB") then
		GotMyFive.SavedVar.savedDebug = not GotMyFive.SavedVar.savedDebug
		d("|c1E90FFDebug mode is now: |r".. tostring(GotMyFive.SavedVar.savedDebug))
	elseif (parameters[1] == "PARMS") or (parameters[1] == "PARM") then
		if parameters[2] then
			local mode = string.sub( parameters[2], 1, 1).. zo_strlower( string.sub( parameters[2], 2) )
			d( mode.. "|c1E90FF".. " Parameters:|r")
		else
			d( "|c1E90FF".. "Parameters:|r")
		end
		if GotMyFive.SavedVar.savedDebug then
			d( "|c1E90FFMinScore:|r"..GotMyFive.SavedVar.savedMinScore.." |c1E90FFMinLen:|r"..GotMyFive.SavedVar.savedMinLength..
				" |c1E90FFDebMin:|r"..GotMyFive.SavedVar.savedDebMin.." |c1E90FFDebMax:|r"..GotMyFive.SavedVar.savedDebMax )
		else
			d( "|c1E90FFMinScore:|r"..GotMyFive.SavedVar.savedMinScore.." |c1E90FFMinLen:|r"..GotMyFive.SavedVar.savedMinLength )
		end
		d("|c1E90FFGuildChat:|r".. tostring(GotMyFive.SavedVar.savedGuildChat).. "|c1E90FF (toggle. True = allow/ignore)|r")
		d("|c1E90FFRevert to defaults:|r /gmf defaults")
		d("|c1E90FFSee defaults:|r /gmf defaults see")
		d("|c1E90FFSet one of them:|r /gmf minlen {value}")
	elseif (parameters[1] == "DEF") or (parameters[1] == "DEFAULT") or (parameters[1] == "DEFAULTS") then
		if (#parameters < 2) then
			GotMyFive.SavedVar.savedMinScore  = defaults.savedMinScore
			GotMyFive.SavedVar.savedMinLength  = defaults.savedMinLength
			GotMyFive.SavedVar.savedGuildChat = defaults.savedGuildChat
			GotMyFive.SavedVar.savedDebMin = defaults.savedDebMin
			GotMyFive.SavedVar.savedDebMax = defaults.savedDebMax
			d("|c1E90FFParameters reset to |rdefault|c1E90FF values:|r")
			Slash("parms New")
		else
			d("Default|c1E90FF parameter values (NOT necessarily current):|r")
			if GotMyFive.SavedVar.savedDebug then
				d("|c1E90FFMinScore:|r".. defaults.savedMinScore.. " |c1E90FFMinLen:|r".. defaults.savedMinLength..
					" |c1E90FFDebMin:|r".. defaults.savedDebMin.. " |c1E90FFDebMax:|r".. defaults.savedDebMax )
			else
				d("|c1E90FFMinScore:|r".. defaults.savedMinScore.. " |c1E90FFMinLen:|r".. defaults.savedMinLength )
			end
			d("|c1E90FFGuildChat:|r".. tostring(defaults.savedGuildChat).. "|c1E90FF (toggle. True = allow/ignore)|r")
			d("|c1E90FFRevert to defaults:|r /gmf defaults")
			d("|c1E90FFSee defaults:|r /gmf defaults see")
			d("|c1E90FFSet one of them:|r /gmf minlen {value}")
		end
	elseif parameters[1] == "MINSCORE" then
		if tonumber(parameters[2]) then
			GotMyFive.SavedVar.savedMinScore = tonumber(parameters[2])
			Slash("parms New")
		else
			Slash("parms Unchanged")
		end
	elseif parameters[1] == "MINLEN" then
		if tonumber(parameters[2]) then
			GotMyFive.SavedVar.savedMinLength = tonumber(parameters[2])
			Slash("parms New")
		else
			Slash("parms Unchanged")
		end
	elseif parameters[1] == "GUILDCHAT" then
		GotMyFive.SavedVar.savedGuildChat = not GotMyFive.SavedVar.savedGuildChat
		d("|c1E90FFNew parameters:|r")
		Slash("parms New")
	elseif parameters[1] == "DEBMIN" then
		if tonumber(parameters[2]) then
			GotMyFive.SavedVar.savedDebMin = tonumber(parameters[2])
			Slash("parms New")
		else
			Slash("parms Unchanged")
		end
	elseif parameters[1] == "DEBMAX" then
		if tonumber(parameters[2]) then
			GotMyFive.SavedVar.savedDebMax = tonumber(parameters[2])
			Slash("parms New")
		else
			Slash("parms Unchanged")
		end
	end
end

SLASH_COMMANDS["/gmf"] = Slash
SLASH_COMMANDS["/gm5"] = Slash
SLASH_COMMANDS["/gotmyfive"] = Slash

--==================================================================================================================================================--
--||                                                                                                                                              ||--
--||                                                     --=<[:::   CHECK FOR SPAM   :::]>=--                                                     ||--
--||                                                                                                                                              ||--
--==================================================================================================================================================--

-- Note to self: to test simply go somewhere away from other players and in /s channel just copy paste the spam into a message

local function IsSpam(eventType, ...)

	if eventType ~= EVENT_CHAT_MESSAGE_CHANNEL then 
		return false
	end
	
	local messageType, fromName, text = ...
	if (messageType == CHAT_CHANNEL_GUILD_1) or (messageType == CHAT_CHANNEL_GUILD_2) or (messageType == CHAT_CHANNEL_GUILD_3) or
			(messageType == CHAT_CHANNEL_GUILD_4) or (messageType == CHAT_CHANNEL_GUILD_5) then
		if GotMyFive.SavedVar.savedGuildChat == true then
			return false
		end
	elseif not ((messageType == CHAT_CHANNEL_SAY) or (messageType == CHAT_CHANNEL_YELL) or (messageType == CHAT_CHANNEL_ZONE) or
			(messageType == CHAT_CHANNEL_WHISPER)) then
		return false
	end

	fromName = zo_strformat("<<1>>", fromName)
	local accountName = GetDisplayName()

	if (GetUnitName("player") == fromName) or (accountName == fromName) then
		if accountName ~= "@Taraezor" then
			return false
		end
	end

	local length = zo_strlen( text)
	if length < GotMyFive.SavedVar.savedMinLength then return false end

	local fancy = 1
	repeat
		if string.match( text, "%b<>") then break end
		if string.match( text, "%b\"\"") then break end
		if string.match( text, "%b()") then break end
		if string.match( text, "%b**") then break end
		if string.match( text, "%b++") then break end
		if string.match( text, "%b{}") then break end
		if string.match( text, "%b[]") then break end -- yeah could be a link but it doesn't really matter.
		fancy = 0
	until fancy == 0

	text = zo_strupper( text)

	local _, colourHits = string.gsub( text, "C%x%x%x%x%x%x", "")
	local _, guildHits = string.gsub( text, "GUILD", "")
	local _, recruitHits = string.gsub( text, "RECRUIT", "")	-- Quebec: recrute
	local _, whisperHits = string.gsub( text, "WHISPER", "")
	local _, friendlyHits = string.gsub( text, "FRIENDLY", "")
	local _, lookingHits = string.gsub( text, "LOOKING", "")
	local _, roleplayHits = string.gsub( text, "ROLEPLAY", "")
	local _, activeHits = string.gsub( text, "ACTIVE", "") -- will also catch INactive. intended
	local _, discordHits = string.gsub( text, "DISCORD", "")
	discordHits = ( discordHits > 0 ) and ( discordHits + 1 ) or 0

-- Noted that not testing JOIN(ing) or ACTIV(e)(ity)

	local total = fancy + colourHits + guildHits + recruitHits + whisperHits + friendlyHits + lookingHits + roleplayHits + 
					activeHits + discordHits
					
	local parameters = nil

	local weHits, tradHits, craftHits, rpHits, inviteHits, memberHits, storeHits, shopHits, 
			pvpHits, pveHits, joinHits, contactHits = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local parms, totalParms = false, 0
					
	if total < GotMyFive.SavedVar.savedMinScore then

		parameters = GetWords( text)

		for i=1,#parameters do
			local _, temp = string.gsub( parameters[i], "^WE$", "")
			weHits = weHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^TRAD", "")
			tradHits = tradHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^CRAFT", "")
			craftHits = craftHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^RP", "")
			rpHits = rpHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^INVITE", "")
			inviteHits = inviteHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^MEMBER", "")
			memberHits = memberHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^STORE", "")
			storeHits = storeHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^SHOP", "")
			shopHits = shopHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^PVP", "")
			pvpHits = pvpHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^PVE", "")
			pveHits = pveHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^JOIN", "")
			joinHits = joinHits + (temp or 0)
			local _, temp = string.gsub( parameters[i], "^CONTACT$", "")
			contactHits = contactHits + (temp or 0)
			totalParms = weHits + tradHits + craftHits + rpHits + inviteHits + memberHits + storeHits + shopHits + pveHits + pvpHits +
							joinHits + contactHits
			if totalParms >= GotMyFive.SavedVar.savedMinScore then break end
		end
		parms = true
	end
	
	total = total + totalParms

	local pstHits, pmHits, newHits, formHits, playerHits = 0, 0, 0, 0, 0
	local extras, totalExtras = false, 0
	
	if total < GotMyFive.SavedVar.savedMinScore and total >= ( GotMyFive.SavedVar.savedMinScore * 0.75 ) then

		for i=1,#parameters do
			local _, temp = string.gsub( parameters[i], "^PST", "")
			pstHits = pstHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^PM", "")
			pmHits = pmHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^NEW", "")
			newHits = newHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^FORM", "")
			formHits = formHits + (temp or 0)
			_, temp = string.gsub( parameters[i], "^PLAYER", "")
			playerHits = playerHits + (temp or 0)
			totalExtras = pstHits + pmHits + newHits + formHits + playerHits
			if ( total + totalExtras ) >= GotMyFive.SavedVar.savedMinScore then break end
		end
		extras = true
	end

	local total =  total + totalExtras

	if GotMyFive.SavedVar.savedDebug and ( total >= GotMyFive.SavedVar.savedDebMin ) and ( total <= GotMyFive.SavedVar.savedDebMax ) then
		if fancy > 0 then d("fancy!") end
		if colourHits > 0 then d("Coloured ".. colourHits.." times!") end
		if guildHits > 0 then d("guildHits ".. guildHits.." times!") end
		if recruitHits > 0 then d("recruitHits ".. recruitHits.." times!") end
		if whisperHits > 0 then d("whisperHits ".. whisperHits.." times!") end
		if friendlyHits > 0 then d("friendlyHits ".. friendlyHits.." times!") end
		if lookingHits > 0 then d("lookingHits ".. lookingHits.." times!") end
		if roleplayHits > 0 then d("roleplayHits ".. roleplayHits.." times!") end
		if activeHits > 0 then d("activeHits ".. activeHits.." times!") end
		if discordHits > 0 then d("discordHits ".. discordHits.." times!") end
		if parms == true then
			if weHits > 0 then d("weHits ".. weHits.." times!") end
			if tradHits > 0 then d("tradHits ".. tradHits.." times!") end
			if craftHits > 0 then d("craftHits ".. craftHits.." times!") end
			if rpHits > 0 then d("rpHits ".. rpHits.." times!") end
			if inviteHits > 0 then d("inviteHits ".. inviteHits.." times!") end
			if memberHits > 0 then d("memberHits ".. memberHits.." times!") end
			if storeHits > 0 then d("storeHits ".. storeHits.." times!") end
			if shopHits > 0 then d("shopHits ".. shopHits.." times!") end
			if pveHits > 0 then d("pveHits ".. pveHits.." times!") end
			if pvpHits > 0 then d("pvpHits ".. pvpHits.." times!") end
			if joinHits > 0 then d("joinHits ".. joinHits.." times!") end
			if contactHits > 0 then d("contactHits ".. contactHits.." times!") end
		end
		if extras == true then
			if pstHits > 0 then d("pstHits ".. pstHits.." times!") end
			if pmHits > 0 then d("pmHits ".. pmHits.." times!") end
			if newHits > 0 then d("newHits ".. newHits.." times!") end
			if formHits > 0 then d("formHits ".. formHits.." times!") end
			if playerHits > 0 then d("playerHits ".. playerHits.." times!") end
		end
		d("total="..total)
	end

	if total < GotMyFive.SavedVar.savedMinScore then return false end

	if GotMyFive.SavedVar.savedDebug then
		if total <= GotMyFive.SavedVar.savedDebMax then return false end
	end

	return GotMyFive.SavedVar.savedDelete
end

--==================================================================================================================================================--
--||                                                                                                                                              ||--
--||                                                     --=<[:::   INITIALISATION   :::]>=--                                                     ||--
--||                                                                                                                                              ||--
--==================================================================================================================================================--

function GotMyFive.OnChatEvent( control, ...)

	if IsSpam(...) then return end
	GotMyFive.OnChatEventOrg( control, ...)
end

function GotMyFive:Initialise()
	
	GotMyFive.SavedVar = ZO_SavedVars:NewAccountWide( "GotMyFive_SavedVariables", 1, nil, GotMyFive.SavedVar)
	self.OnChatEventOrg = CHAT_SYSTEM.OnChatEvent
	CHAT_SYSTEM.OnChatEvent = GotMyFive.OnChatEvent
end

local function GotMyFiveAddonLoaded(eventType, addonName)

	if addonName ~= "GotMyFive" then return end
	GotMyFive:Initialise()
end

EVENT_MANAGER:RegisterForEvent("GotMyFiveInitialise", EVENT_ADD_ON_LOADED, GotMyFiveAddonLoaded)