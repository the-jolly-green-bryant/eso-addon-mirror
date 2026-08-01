local L = sidWarTools.Localization

local function Initialize(saveData)
	if(saveData.killNotifications) then
		local LKE = LibStub("LibKillEvents")

		LKE:RegisterForPlayerKill(function(targetName, abilityNames, alliancePoints)
			local abilities = table.concat(abilityNames, "+")
			local charLink = ZO_LinkHandler_CreateCharacterLink(zo_strformat("<<1>>", targetName))
			local apText = zo_iconTextFormat("EsoUI/Art/currency/alliancePoints.dds", 18, 18, alliancePoints)
			df(L["PLAYER_KILL_LAST_HIT_NOTIFICATION"], abilities, charLink, apText)
		end)

		LKE:RegisterForPlayerKillAssist(function(targetName)
			local charLink = ZO_LinkHandler_CreateCharacterLink(zo_strformat("<<1>>", targetName))
			df(L["PLAYER_KILL_ASSIST_NOTIFICATION"], charLink)
		end)

		LKE:RegisterForPlayerDeath(function(sourceName, assistNames, abilityNames)
			local abilities = table.concat(abilityNames, "+")

			if(sourceName == "") then
				df(L["KILL_SUICIDE_NOTIFICATION"], abilities)
			else
				local charLink
				if(sourceName:find("%^.x")) then -- is player name
					charLink = ZO_LinkHandler_CreateLink(zo_strformat("<<g:1>>", sourceName), nil, CHARACTER_LINK_TYPE, zo_strformat("<<1>>", sourceName))
					df(L["PLAYER_KILL_DEATH_NOTIFICATION"], charLink, abilities)
				else
					if(not sourceName:find("%^.")) then sourceName = sourceName .. "^M" end
					charLink = zo_strformat("<<g:1>>", sourceName)
					df(L["KILL_DEATH_NOTIFICATION"], charLink, abilities)
				end
			end
		end)

		LKE:RegisterForNonPlayerKill(function(targetName, abilityNames)
			if(not saveData.npcKillNotifications) then return end
			local abilities = table.concat(abilityNames, "+")
			df(L["KILL_LAST_HIT_NOTIFICATION"], abilities, zo_strformat("<<1>>", targetName))
		end)
	end
end

sidWarTools.InitializeKillNotifications = Initialize
