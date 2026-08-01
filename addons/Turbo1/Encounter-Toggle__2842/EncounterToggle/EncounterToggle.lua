EncounterToggle = {
	name = "EncounterToggle",
	title = "|cFF860DEncounter|r Toggle",
	version = "1.1",
	slashCommand = "/encountertoggle",
	
	defaults = {
		status = true,
	},	
}

local function OnAddOnLoaded(event, addonName)
	if addonName ~= EncounterToggle.name then return end
	
	EncounterToggle.vars = ZO_SavedVars:NewAccountWide("EncounterToggleSavedVariables", 1, nil, EncounterToggle.defaults, nil, "$InstallationWide")
	
	SLASH_COMMANDS[EncounterToggle.slashCommand] = EncounterToggle.SlashCommandHandler
	
	EVENT_MANAGER:UnregisterForEvent(EncounterToggle.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(EncounterToggle.name, EVENT_PLAYER_ACTIVATED, EncounterToggle.OnPlayerActivated)
	
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ENCOUNTER_LOG", "Toggle Encounter log")
end

function EncounterToggle.SlashCommandHandler(command)
	command = string.lower(command)

	if (command == "status") then
		EncounterToggle.vars.status = not EncounterToggle.vars.status
		CHAT_ROUTER:AddSystemMessage(string.format(
			"[%s] Status Message: %s", EncounterToggle.title, 
			GetString(EncounterToggle.vars.status and SI_CHECK_BUTTON_ON or SI_CHECK_BUTTON_OFF)
		))
	else
		CHAT_ROUTER:AddSystemMessage(string.format("[%s]", EncounterToggle.title))
		CHAT_ROUTER:AddSystemMessage("/encountertoggle status – Prints a status message upon loading into a raid/arena/dungeon")
	end
end

function EncounterToggle.ToggleLogging(value)
    local toggle = (value == nil) and not IsEncounterLogEnabled() or value
    SetEncounterLogEnabled(toggle)
	EncounterToggle.print()
end

function EncounterToggle.print()
    if IsEncounterLogEnabled() then
		CHAT_ROUTER:AddSystemMessage("Encounter log enabled.")
	else
		CHAT_ROUTER:AddSystemMessage("Encounter log disabled.")
	end
end

function EncounterToggle.status()
    if IsEncounterLogEnabled() then
		CHAT_ROUTER:AddSystemMessage("Encounter log is active.")
	else
		CHAT_ROUTER:AddSystemMessage("Encounter log is inactive.")
	end
end

function EncounterToggle.OnPlayerActivated(event)
    if (EncounterToggle.vars.status == false) then
		return 
	end
	
	local current_instance = GetCurrentZoneDungeonDifficulty()

    if current_instance ~= DUNGEON_DIFFICULTY_NONE then
		if current_instance == DUNGEON_DIFFICULTY_VETERAN or DUNGEON_DIFFICULTY_NORMAL then
			EncounterToggle.status()
		end       
    end
end

EVENT_MANAGER:RegisterForEvent(EncounterToggle.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
