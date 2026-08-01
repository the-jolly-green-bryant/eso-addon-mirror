COURTEOUSDUNGEONEER = COURTEOUSDUNGEONEER or {
	name = "CourteousDungeoneer",
	displayName = "Courteous Dungeoneer",
	author = "Ancillae_Secretorum",
	version = "0.52",
	variableVersion = 2,
	message = "ESOUI > Courteous Dungeoneer : Found a ",
	Default = { customMessage = "", alertForChests = true, alertForHeavySacks = true },
	chests = { ["de"] = "Truhe", ["en"] = "Chest",  ["es"] = "cofre", ["fr"] = "coffre", ["ru"] = "Сундук" },
	sacks = { ["de"] = "schwerer Sack", ["en"] = "Heavy Sack", ["es"] = "saco pesado", ["fr"] = "sac lourd", ["ru"] = "Тяжелый мешок" },
	arenas = { [1] = "Dragonstar Arena", [2] = "Blackrose Prison", [3] = "Infinite Archive" }
}

function COURTEOUSDUNGEONEER.OutputMessage(item)
	local customMessage = string.gsub(COURTEOUSDUNGEONEER.savedVariables.customMessage, "CHAR", GetUnitName("player"))	-- replacing the pattern "CHAR" by the character's name
	customMessage = string.gsub(customMessage, "ITEM", item[COURTEOUSDUNGEONEER.clientLanguage])						-- replacing the pattern "ITEM" by the item's name
	CHAT_SYSTEM:StartTextEntry(COURTEOUSDUNGEONEER.message .. item["en"] .. ". " .. customMessage, CHAT_CHANNEL_PARTY)
end

function COURTEOUSDUNGEONEER.InsideArena()
	local zone = GetPlayerActiveZoneName()
	for i, arena in ipairs(COURTEOUSDUNGEONEER.arenas) do
		if arena == currentZone then
			return true
		end
	end
	return false
end

function COURTEOUSDUNGEONEER.ClientInteractResult(eventCode, result, interactTargetName)
	-- interactTargetName ends with "^m" or "^f" in several (but not all) languages, for example "cofre^m" in spanish, instead of "cofre"
	interactTargetName = string.gsub(interactTargetName, "%^%a", "")									-- removing this unwanted ending
	if not IsUnitInDungeon("player") then
		return false                                      												-- not in a dungeon
	elseif GetCurrentZoneDungeonDifficulty() == 0 then
		return false																					-- not in a group dungeon
	elseif COURTEOUSDUNGEONEER.InsideArena() then														-- in an arena (trivial chests)
		return false
	elseif interactTargetName == COURTEOUSDUNGEONEER.sacks[COURTEOUSDUNGEONEER.clientLanguage] and COURTEOUSDUNGEONEER.savedVariables.alertForHeavySacks then
		COURTEOUSDUNGEONEER.OutputMessage(COURTEOUSDUNGEONEER.sacks)
	elseif interactTargetName == COURTEOUSDUNGEONEER.chests[COURTEOUSDUNGEONEER.clientLanguage] and COURTEOUSDUNGEONEER.savedVariables.alertForChests then
		COURTEOUSDUNGEONEER.OutputMessage(COURTEOUSDUNGEONEER.chests)
	end
end

function COURTEOUSDUNGEONEER.CreateSettingsPanel()
	local panelData = {
		type = "panel",
		name = COURTEOUSDUNGEONEER.name,
		displayName = COURTEOUSDUNGEONEER.displayName,
		author = COURTEOUSDUNGEONEER.author,
		version = COURTEOUSDUNGEONEER.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LibAddonMenu2:RegisterAddonPanel(COURTEOUSDUNGEONEER.name, panelData)
	
	local optionsData = {
		[1] = {
			type = "divider"
		},
		[2] = {
			type = "description",
			text = COURTEOUSDUNGEONEER.localization.settings.description
		},
		[3] = {
			type = "divider"
		},
		[4] = {
			type = "checkbox",
			name = COURTEOUSDUNGEONEER.localization.settings.warnForChests,
			tooltip = COURTEOUSDUNGEONEER.localization.settings.warnForChestsTooltip,
			default = true,
			getFunc = function() 
				return COURTEOUSDUNGEONEER.savedVariables.alertForChests
			end,
			setFunc = function(on) 
				COURTEOUSDUNGEONEER.savedVariables.alertForChests = on
			end
		},
		[5] = {
			type = "checkbox",
			name = COURTEOUSDUNGEONEER.localization.settings.warnForHeavySacks,
			tooltip = COURTEOUSDUNGEONEER.localization.settings.warnForHeavySacksTooltip,
			default = true,
			getFunc = function() 
				return COURTEOUSDUNGEONEER.savedVariables.alertForHeavySacks
			end,
			setFunc = function(on) 
				COURTEOUSDUNGEONEER.savedVariables.alertForHeavySacks = on
			end
		},
		[6] = {
			type = "editbox",
			name = COURTEOUSDUNGEONEER.localization.settings.customMessage,
			tooltip = COURTEOUSDUNGEONEER.localization.settings.customMessageTooltip,
			isMultiline = true,
			getFunc = function()
				return COURTEOUSDUNGEONEER.savedVariables.customMessage
			end,
			setFunc = function(text)
				COURTEOUSDUNGEONEER.savedVariables.customMessage = text
			end,
			width = "full",
		}
	}
	LibAddonMenu2:RegisterOptionControls(COURTEOUSDUNGEONEER.name, optionsData)
end

function COURTEOUSDUNGEONEER:Initialize()
	COURTEOUSDUNGEONEER.clientLanguage = GetCVar("language.2") or ""
	COURTEOUSDUNGEONEER.CreateSettingsPanel()
	EVENT_MANAGER:RegisterForEvent(COURTEOUSDUNGEONEER.name, EVENT_CLIENT_INTERACT_RESULT, COURTEOUSDUNGEONEER.ClientInteractResult)
end
 
function COURTEOUSDUNGEONEER.OnAddOnLoaded(event, addonName)
	if addonName == COURTEOUSDUNGEONEER.name then
		COURTEOUSDUNGEONEER.savedVariables = ZO_SavedVars:NewAccountWide("CourteousDungeoneerSavedVariables", COURTEOUSDUNGEONEER.variableVersion, nil, COURTEOUSDUNGEONEER.Default)
    	EVENT_MANAGER:UnregisterForEvent(COURTEOUSDUNGEONEER.name, EVENT_ADD_ON_LOADED)
    	COURTEOUSDUNGEONEER:Initialize()
	end
end
 
SLASH_COMMANDS["/ascd"] = function(txt)
	if txt == "" then
		d([[Type /ascd followed by your custom message to set it.
		Use CHAR as a stand in for your current character.
		Use ITEM as a stand in for the item you found in your client's tongue.
		Type '/ascd msg' to see your message]])
	elseif txt == "msg" then
		d(COURTEOUSDUNGEONEER.savedVariables.customMessage)
	else
		COURTEOUSDUNGEONEER.savedVariables.customMessage = txt
	end
end

EVENT_MANAGER:RegisterForEvent(COURTEOUSDUNGEONEER.name, EVENT_ADD_ON_LOADED, COURTEOUSDUNGEONEER.OnAddOnLoaded)