-- Create namespace
DsRGuildRabenwacht = {}
local DsRGuildRabenwacht = DsRGuildRabenwacht or {}

DsRGuildRabenwacht.name = "DsRGuildRabenwacht"

local isOnlineManager = {}
local LoginTable      = {}

---------------------------------------------------------------------
-- OFFI On/Off Message
---------------------------------------------------------------------
local function OnGuildMemberPlayerStatusChanged(_, guildId, account, prevStatus, currStatus)
    if DsRAutoINV.cfg.GuildMasterJoin == false then return end
    
    local RabenBlue  = "|c9fb6cd"
    local RabenGreen = "|c00ff00"
    local RabenWhite = "|cffffff"
    local RabenLogo  = zo_iconFormat("/DsRGuildHall/misc/DsR_RabenwachtFLO.dds", 20, 20)

	local guildName = GetGuildName(guildId)

    if guildName == "Die sieben Raben" then
        for k,v in pairs(DsRglobals.GuildLeader) do
            if account == v then
                local now       = GetTimeStamp()
                local wasOnline = prevStatus ~= PLAYER_STATUS_OFFLINE
			    local isOnline  = currStatus ~= PLAYER_STATUS_OFFLINE

                if account == "@Hasenwarrior" or account == "@flo1980" or account == "@Magnolyon" or account == "@Ravnic93" then
                    Wacht = "Rabenwächter |r"
                elseif account == "@PettiPuuh" then
                    Wacht = "Ihre Kaiserliche und Königliche Majestät, Rabenmama |r"
                else
                    Wacht = "Rabenwächterin |r"
                end

                if account == "@PettiPuuh" then
                    Rabe = zo_iconFormat("/DsRGuildHall/misc/pettipuuh.dds", 20, 20) .. "|c505050P|r|c646464e|r|c787878t|r|c8c8c8ct|r|ca0a0a0i|r|c8c8c8cP|r|c787878u|r|c646464u|r|c505050h|r"
                elseif account == "@flo1980" then
                    Rabe = zo_iconFormat("/DsRGuildHall/misc/flo1980.dds", 20, 20) .. "|cff0000F|r|cffffffL|r|cff0000O|r"   
                -- elseif account == "@Siraa" then
                    -- Rabe = zo_iconFormat("/DsRGuildHall/misc/siraa.dds", 20, 20) .. "|c007f78S|r|c007051i|r|c00602ar|r|c005003a|r"
                -- elseif account == "@Sisiktil" then
                    -- Rabe = zo_iconFormat("/DsRGuildHall/misc/sisiktil.dds", 20, 20) .. "|cffff8fD|r|ce1d816r|r|cbfb81du|r|c9c9723z|r|c605c00i|r|c3c3a05l|r"
                elseif account == "@Prof_Flausch" then
                    Rabe = zo_iconFormat("/DsRGuildHall/misc/prof_flausch.dds", 20, 20) .. "|ccca6e0Prof Flausch|r"
                elseif account == "@Ravnic93" then
                    Rabe = zo_iconFormat("/DsRGuildHall/misc/ravnic93.dds", 20, 20) .. "|c89693eRavnic|r"
                elseif account == "@Magnolyon" then
                    Rabe = zo_iconFormat("/DsRGuildHall/misc/Magnolyon.dds", 20, 20) .. "|cffbe00B|r|cffac00o|r|cff9900o|r|cff8700p|r|cff7500s|r"
                elseif account == "@Hasenwarrior" then
                    Rabe = zo_iconFormat("/DsRGuildHall/misc/Hasenwarrior.dds", 20, 20) .. "|cD8F781S|r|cF3F781i|r|cF5DA81r|r |cF7BE81H|r|cF5DA81o|r|cF3F781p|r|cD8F781p|r|cBEF781e|r|c9FF781l|r"
                end

			    if(not wasOnline and isOnline and (isOnlineManager[account] == nil or isOnlineManager[account] == false)) then
                    local onTime = GetDiffBetweenTimeStamps(now, DsRVersion.Waechter.WachtLogin[account])
                    if onTime > 1200 then -- 20min
                        DsRVersion.Waechter.WachtLogin[account] = GetTimeStamp()
                        if DsRAutoINV.cfg.GuildMasterJoinSound then
                            PlaySound(SOUNDS.BATTLEGROUND_MATCH_WON)
                        end
                        if account == "@PettiPuuh" then
                            d(RabenLogo .. RabenBlue .. Wacht .. Rabe .. RabenBlue .. " (Erhabene Herrscherin von den Sieben Raben, Hüterin der Krone, Leuchtender Stern der Weisheit und Gnade, Spiegel des Ruhms)|r" .. "|c35fc38 hat sich eingeloggt|r")
                        elseif account == "@flo1980" then
                            d(RabenLogo .. RabenBlue .. Wacht .. Rabe .. RabenBlue .. " (Herr Krah von Rabenwacht, Meister der Münze, allgemeine Aufwertungsdirne, Traummann von @Hasenwarrior und erhabener Gemahl der Mutter der Raben)|r" .. "|c35fc38 hat sich eingeloggt|r")
                        elseif account == "@Magnolyon" then
                            d(RabenLogo .. RabenBlue .. Wacht .. Rabe .. RabenBlue .. " (Päzeptor Boobs von Magnolyon, Herr der Didaktik und Dichter der Raben)|r" .. "|c35fc38 hat sich eingeloggt|r")
                        elseif account == "@Prof_Flausch" then
                            d(RabenLogo .. RabenBlue .. Wacht .. Rabe .. RabenBlue .. " (Flauschigste der Raben und Befreierin der Geisternetch)|r" .. "|c35fc38 hat sich eingeloggt|r")
                        -- elseif account == "@Siraa" then
                            -- d(RabenLogo .. RabenBlue .. Wacht .. Rabe .. RabenBlue .. " (Klinge der Rabenwacht, Meisterin der Schatten und Hand der Rabenmama)|r" .. "|c35fc38 hat sich eingeloggt|r")
                        elseif account == "@Hasenwarrior" then
                            d(RabenLogo .. RabenBlue .. Wacht .. Rabe .. RabenBlue .. " (Torwächter der Hallen der Raben, Heerführer der Legionen und Meister der Artefaktewerke)|r" .. "|c35fc38 hat sich eingeloggt|r")
                        -- elseif account == "@Sisiktil" then
                            -- d(RabenLogo .. RabenBlue .. Wacht .. Rabe .. RabenBlue .. " (Magister Medicus, Rabe der Ruhe und Meister der Silberzunge)|r" .. "|c35fc38 hat sich eingeloggt|r")
                        elseif account == "@Ravnic93" then
                            d(RabenLogo .. RabenBlue .. Wacht .. Rabe .. RabenBlue .. " (Chaosstratege der Raben, Lehrmeister der Taktiken und Beschützer der Flauschigsten)|r" .. "|c35fc38 hat sich eingeloggt|r")
                        end
                    end
                elseif(wasOnline and not isOnline and (isOnlineManager[account] == nil or isOnlineManager[account])) then
                    local onTime = GetDiffBetweenTimeStamps(now, DsRVersion.Waechter.WachtLogin[account])
                    if onTime > 1200 then -- 20min
                        d(RabenLogo .. RabenBlue .. Wacht .. Rabe .. " |cFAA0A0hat sich ausgeloggt|r")
                    end
			    end
                isOnlineManager[account] = isOnline
            end
        end
	end
end

---------------------------------------------------------------------
-- Read Recruting
---------------------------------------------------------------------
function DsRGuildRabenwacht.ReadRecrut()
    for i = 1, 5 do
        local guildId   = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        if guildName == "Die sieben Raben" then
            d("|c9fb6cd[DsR]|r |cFAA0A0Checke aktuelle Bewerbungen|r")
            local guildId         = GetGuildId(GuildNum)
            local numApplications = GetGuildFinderNumGuildApplications(guildId)

            for a = 1, numApplications do
                local level, championPoints, alliance, classId, accountName, characterName, achievementPoints, applicationMessage = GetGuildFinderGuildApplicationInfoAt(guildId, a)
                local CheckLen = zo_strlen(applicationMessage)

                if CheckLen <= 10 then
                    d("|cFF0000Bewerbung von |r " .. accountName .. "|cFF0000 automatisch abgelehnt|r ")

                    local declineMessage = "Hey, leider können wir keine Bewerbungen ohne Text berücksichtigen. Bitte schreib uns doch ein paar Zeilen über dich, wenn du dich nochmal bewerben möchtest."
                    DeclineGuildApplication(guildId, a, declineMessage, false, "")
                end
            end
            d("|c9fb6cd[DsR]|r |cFAA0A0Abgeschlossen|r")
            return
        end
    end
end

---------------------------------------------------------------------
-- OFFI PREFIX
---------------------------------------------------------------------
local function DsRGuildRabenwacht_Mark_SetupChatHooks()
	local function DsRGuildRabenwacht_Mark_AddIconToMessage(messageType, fromName, text, isFromCustomerService, fromDisplayName)
	    local formattedText = text

        local guildId = 0
        if messageType == CHAT_CHANNEL_GUILD_1 then guildId = GetGuildId(1) end
        if messageType == CHAT_CHANNEL_GUILD_2 then guildId = GetGuildId(2) end
        if messageType == CHAT_CHANNEL_GUILD_3 then guildId = GetGuildId(3) end
        if messageType == CHAT_CHANNEL_GUILD_4 then guildId = GetGuildId(4) end
        if messageType == CHAT_CHANNEL_GUILD_5 then guildId = GetGuildId(5) end

        local guildName = GetGuildName(guildId)

        if guildName == "Die sieben Raben" or guildName == "Hasenbande" then
            for k,v in pairs(DsRglobals.GuildLeader) do
                if fromName == v or fromDisplayName == v then
                    if fromName == "@PettiPuuh" or fromDisplayName == "@PettiPuuh" then
                        formattedText = string.format("|cFF0000[Chefin]|r %s", formattedText)
                    else
                        formattedText = string.format("|cFF0000[OFFI]|r %s", formattedText)
                    end
                else
                    formattedText = formattedText
                end
            end
        else
            formattedText = formattedText
        end

        local channelInfo = ZO_ChatSystem_GetChannelInfo()[messageType]
	    if (not channelInfo or not channelInfo.format) then
		    return
	    end
		return formattedText, channelInfo.saveTarget
	end
	local oldFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
	if (oldFormatter) then
		CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(messageType, fromName, text, isFromCustomerService, fromDisplayName)
			local oldText = oldFormatter(messageType, fromName, text, isFromCustomerService, fromDisplayName)
			return DsRGuildRabenwacht_Mark_AddIconToMessage(messageType, fromName, oldText, isFromCustomerService, fromDisplayName)
		end)
	else
		CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, DsRGuildRabenwacht_Mark_AddIconToMessage)
	end	
	EVENT_MANAGER:UnregisterForEvent(DsRGuildRabenwacht.name .. "Activated", EVENT_PLAYER_ACTIVATED)
end

function DsRGuildRabenwacht.OnPlayerActivated()
	if (pChat or rChat) then
		EVENT_MANAGER:RegisterForUpdate(DsRGuildRabenwacht.name .. "DelayedActivated", 500,
			function()
				EVENT_MANAGER:UnregisterForUpdate(DsRGuildRabenwacht.name .. "DelayedActivated")
				DsRGuildRabenwacht_Mark_SetupChatHooks()
			end)
	else
		DsRGuildRabenwacht_Mark_SetupChatHooks()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- ON ADDON LAODED
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildRabenwacht.OnAddonLoaded(event, name)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildRabenwacht.name, EVENT_ADD_ON_LOADED)
    
    EVENT_MANAGER:RegisterForEvent(DsRGuildRabenwacht.name, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, OnGuildMemberPlayerStatusChanged)
	EVENT_MANAGER:RegisterForEvent(DsRGuildRabenwacht.name .. "Activated", EVENT_PLAYER_ACTIVATED, DsRGuildRabenwacht.OnPlayerActivated)

    zo_callLater(function() DsRGuildRabenwacht.ReadRecrut() end, 30000 )
end