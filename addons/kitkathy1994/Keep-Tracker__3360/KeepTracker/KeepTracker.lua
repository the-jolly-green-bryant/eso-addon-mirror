------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	//////////////////////////////////////////////////////////////////////////////////////////	KEEP TRACKER BASICS	//////////////////////////////////////////////////////////////////////////////////////////	--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
KeepTracker = {}																						--	Declares basic variables and values.
local kt = KeepTracker																					--	
local LMP = LibMapPins																					--	
																										--	
kt.name = "KeepTracker"																					--	
kt.vars = {}																							--	kt.vars is our saved variables to store our lists and user values. It is done per character.
																										--	
local DefaultVars = {																					--	DefaultVars is our default values for kt.vars, including empty lists and default booleans.
	hasResourcesQuest = false,																			--	
	hasKeepsQuest = false,																				--	
	debugMode = false,																					--	
	keepList = {},																						--	
	rscList = {},																						--	
	pinStyle = "checkmark_glarge",																		--	
	pinTooltipEnabled = false,																			--	
}																										--	
local pinLayoutData = {																					--	pinLayoutData is the definition of our map pins, the values inside can be changed within other
   level = 150,																							--	functions. Level is set to 150 so that it appears above resource and keep map pins.
   texture = "KeepTracker/checkmark_glarge.dds",														--	
   size = 20,																							--	
}																										--	
																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	//////////////////////////////////////////////////////////////////////////////////////////	ON ADD-ON LOADED	//////////////////////////////////////////////////////////////////////////////////////////	--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.OnAddOnLoaded(eventCode, addonName)															--	Name:		OnAddOnLoaded
	if addonName ~= kt.name then																		--	
		return																							--	Event:		EVENT_ADD_ON_LOADED
	end																									--	
																										--	Args:		number eventCode,
	kt:Initialize(eventCode)																			--				string addonName,
end																										--	
																										--	Purpose:	Runs function kt:Initialize when this addon is loaded.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	//////////////////////////////////////////////////////////////////////////////////////////	STANDARD FUNCTIONS	//////////////////////////////////////////////////////////////////////////////////////////	--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.QuestListUpdated(eventCode)																	--	Name:		QuestListUpdated
	kt.Debug_Display("------------------------")														--	
	kt.Debug_Display("Quest List Updated!")																--	Event:		EVENT_QUEST_LIST_UPDATED
																										--	
	-- Resources check																					--	Args:		number eventCode,
	if (kt.HasActiveQuest("Capture Any Nine Resources") and (not kt.vars.hasResourcesQuest)) then		--	
		-- Rising Edge																					--	Purpose:	Determines whether the player has the quest "Capture Any Nine Resources" or
		kt.Debug_Display("Nine Resources Rising Edge detected!")										--				"Capture Any Three Keeps" in their quest journal. This is done by using two
		kt.Debug_Display("eventCode: " .. tostring(eventCode))											--				special booleans: kt.vars.hasResourcesQuest, and kt.vars.hasKeepsQuest.
		kt.vars.hasResourcesQuest = true																--				If the player has the boolean set to false (default state), but the quest
		kt.Debug_Display("kt.vars.hasResourcesQuest set to true")										--				journal has the quest listed, that means the player just picked up the quest
	elseif ((not kt.HasActiveQuest("Capture Any Nine Resources")) and kt.vars.hasResourcesQuest) then	--				(Rising Edge).
		-- Falling Edge																					--				If the player has the boolean set to true (set in this function only), but
		kt.Debug_Display("Nine Resources Falling Edge detected!")										--				the quest journal does not have the quest listed, that means the player has
		kt.Debug_Display("eventCode: " .. tostring(eventCode))											--				either turned in the quest, or abandoned the quest (Falling Edge).
		kt.vars.hasResourcesQuest = false																--				In either of the above states, the boolean value should be updated to show
		kt.Debug_Display("kt.vars.hasResourcesQuest set to false")										--				the actual status of the quest, whether the player has it active or not.
		kt.vars.rscList = {} -- Clear list once the quest is done										--				In cases of Falling Edges, this function will also clear the tracked list
		kt.Debug_Display("Resource list has been cleared")												--				in order to remove all markers from the map.
	end																									----------------------------------------------------------------------------------------------------------
																										--	This quest is called in the above event, as well as in multiple other functions. This is
	-- Keeps check																						--	because the event EVENT_QUEST_LIST_UPDATED does not trigger every time we want to run these
	if (kt.HasActiveQuest("Capture Any Three Keeps") and (not kt.vars.hasKeepsQuest)) then				--	quest checks. When it is called by another function, another eventCode value is sent as a param.
		-- Rising Edge																					--	
		kt.Debug_Display("Three Keeps Rising Edge detected!")											--	It is not physically possible for a player to hold both "Capture Any Nine Resources" and
		kt.Debug_Display("eventCode: " .. tostring(eventCode))											--	"Capture Any Three Keeps" at the same time, but the function is written such that it will
		kt.vars.hasKeepsQuest = true																	--	still work as intended, should any such strange behaviours occur.
		kt.Debug_Display("kt.vars.hasKeepsQuest set to true")											--	
	elseif ((not kt.HasActiveQuest("Capture Any Three Keeps")) and kt.vars.hasKeepsQuest) then			--	
		-- Falling Edge																					--	
		kt.Debug_Display("Three Keeps Falling Edge detected!")											--	
		kt.Debug_Display("eventCode: " .. tostring(eventCode))											--	
		kt.vars.hasKeepsQuest = false																	--	
		kt.Debug_Display("kt.vars.hasKeepsQuest set to false")											--	
		kt.vars.keepList = {} -- Clear list once the quest is done										--	
		kt.Debug_Display("Keeps list has been cleared")													--	
	end																									--	
																										--	
	kt.Debug_Display("------------------------")														--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.QuestAdded(eventCode, journalIndex, questName, objectiveName)								--	Name:		QuestAdded
	-- Run the update function here too but send the other event code so we can keep track				--	
	if questName == "Capture Any Nine Resources" or questName == "Capture Any Three Keeps" then			--	Event:		EVENT_QUEST_ADDED
		kt.QuestListUpdated(eventCode)																	--	
	end																									--	Args:		number eventCode,
end																										--				number journalIndex,
																										--				string questName,
																										--				string objectiveName,
																										--	
																										--	Purpose:	Runs function kt.QuestListUpdated when quest "Capture Any Nine Resources" or
																										--				"Capture Any Three Keeps" has been picked up at the questboards.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.QuestCompleted(eventCode, questName, _, _, _, _, _, _)										--	Name:		QuestCompleted
	kt.Debug_Display("------------------------")														--	
	kt.Debug_Display("Quest " .. questName .. " has been completed!")									--	Event:		EVENT_QUEST_COMPLETE
	kt.Debug_Display("------------------------")														--	
																										--	Args:		number eventCode,
	if questName == "Capture Any Nine Resources" or questName == "Capture Any Three Keeps" then			--				string questName,
		kt.QuestListUpdated(eventCode)																	--	
	end																									--	Purpose:	Runs function kt.QuestListUpdated when the quest "Capture Any Nine Resources" or
end																										--				"Capture Any Three Keeps" has been turned in to the questboards.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.KeepCaptured(eventCode, keepID, battlegroundContext, owningAlliance, oldOwningAlliance)		--	Name:		KeepCaptured
	if kt.vars.hasKeepsQuest or kt.vars.hasResourcesQuest then											--	
		keepName = GetKeepName(keepID)																	--	Event:		EVENT_KEEP_ALLIANCE_OWNER_CHANGED
		if (owningAlliance == GetUnitAlliance("player")) and (GetPlayerLocationName() == keepName) then	--	
			-- Player captured something																--	Args:		number eventCode,
			kt.Debug_Display("------------------------")												--				number keepID,
			kt.Debug_Display("Location Captured: " .. keepName)											--				BattleFroundQueryContextType battlegroundContext,
			if GetKeepType(keepID) == 0 then															--				number owningAlliance,
				kt.Debug_Display("Location is a Castle")												--				number oldOwningAlliance,
				if kt.vars.hasKeepsQuest then															--	
					kt.Debug_Display("Player has Capture Three Keeps and has captured a keep")			--	Purpose:	First, determines if the location that changed hands has been captured by the player.
					if kt.ListContains(kt.vars.keepList, keepID) or #kt.vars.keepList >= 3 then			--				If captured by the player, determine type of location (keep or resource) captured and,
						kt.Debug_Display("Player has already captured this keep or keep list is full.")	--				if the correct quest is active, adds the location to the list to keep track of them.
					else																				----------------------------------------------------------------------------------------------------------
						kt.Debug_Display("Adding keep to list")											--	Alliances:	
						kt.vars.keepList[#kt.vars.keepList+1] = keepID									--		0	Unknown
						LMP:RefreshPins("kt_capturedlocationpin")										--		1	Aldmeri Dominion
					end																					--		2	Ebonheart Pact
				end																						--		3	Daggerfall Covenant
			elseif GetKeepType(keepID) == 1 then														--	
				kt.Debug_Display("Location is a Resource")												--	
				if kt.vars.hasResourcesQuest then														--	Keep Types:
					kt.Debug_Display("Player has Capture Nine Resources and captured a resource")		--		0	Castles
					if kt.ListContains(kt.vars.rscList, keepID) or #kt.vars.rscList >= 9 then			--		1	Resources
						kt.Debug_Display("Resource already captured or list is full.")					--		2	Cyrodiil Gates
					else																				--		3	Scroll Temples
						kt.Debug_Display("Adding resource to list")										--		4	Scroll Gates
						kt.vars.rscList[#kt.vars.rscList+1] = keepID									--		5	Outposts
						LMP:RefreshPins("kt_capturedlocationpin")										--		6	IC Districts
					end																					--		7	Towns
				end																						--		8	Bridges
			else																						--		9	Milegates
				kt.Debug_Display("Captured location type unhandled!")									--	
				kt.Debug_Display("Keep type: " .. GetKeepType(keepID))									--	LMP:RefreshPins is called once a location is added to the list so that the map pins are updated
			end																							--	instantly as opposed to waiting for the map to update normally. This refresh is targetted so that
			kt.Debug_Display("------------------------")												--	only our custom pins will be updated.
		else																							--	
			-- Something else changed hands but not captured by player									--
		end																								--	
	end																									--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	//////////////////////////////////////////////////////////////////////////////////////////	UTILITY FUNCTIONS	//////////////////////////////////////////////////////////////////////////////////////////	--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.Active()																					--	Name:		Active
	EVENT_MANAGER:UnregisterForEvent(kt.name, EVENT_PLAYER_ACTIVATED)									--	
	pinLayoutData.texture = kt.name .. "/icons/" .. kt.vars.pinStyle .. ".dds"							--	Event:		EVENT_PLAYER_ACTIVATED
	kt.QuestListUpdated(eventCode)																		--	
end																										--	Purpose:	Runs only once (as it is unregistered from event afterwards) when the player loads into
																										--				the game for the first time. This is for functions that would ideally be run at
																										--				initialisation but couldn't. Some of the values in initialisation takes some time to load
																										--				and this function allows these functions and changes to be done a little later, after
																										--				kt.vars has been completely loaded in.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.Tooltip_Toggle()																			--	Name:		Tooltip_Toggle
	if kt.vars.pinTooltipEnabled then																	--	
		d("[Keep Tracker] Location tooltips disabled.")													--	Purpose:	Used by slash commands to toggle user setting of displaying map pin tooltips.
		kt.vars.pinTooltipEnabled = false																--	
	else																								--	
		d("[Keep Tracker] Location tooltips enabled.")													--	
		kt.vars.pinTooltipEnabled = true																--	
	end																									--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.Debug_Toggle()																				--	Name:		Debug_Toggle
	if kt.vars.debugMode then																			--	
		d("[Keep Tracker] Debug mode disabled.")														--	Purpose:	Used by slash commands to toggle user setting of debug commands and verbose chat.
		kt.vars.debugMode = false																		--	
		kt.DebugCommands("remove")																		--	
	else																								--	
		d("[Keep Tracker] Debug mode enabled. New commands are available.")								--	
		kt.vars.debugMode = true																		--	
		kt.DebugCommands("add")																			--	
	end																									--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.DebugCommands(change)																		--	Name:		DebugCommands
	if (change == "add") then																			--	
		SLASH_COMMANDS["/kt_rsclist"] = kt.DisplayResourcesList											--	Args:		string change,
		SLASH_COMMANDS["/kt_keeplist"] = kt.DisplayKeepsList											--	
		SLASH_COMMANDS["/kt_rscquest"] = kt.DisplayResourcesQuest										--	Purpose:	Simple function to clean up visibility of other functions. When parameter is "add",
		SLASH_COMMANDS["/kt_keepquest"] = kt.DisplayKeepsQuest											--				adds all debug slash commands; when parameter is "remove", removes all debug slash
		SLASH_COMMANDS["/kt_addkeep"] = kt.AddKeep														--				commands. InvalidateSlashCommandCache is called at the end of each to reset the auto
		SLASH_COMMANDS["/kt_addrsc"] = kt.AddResource													--				complete/auto suggest popups so it does not recommend slash commands that are no
		SLASH_COMMANDS["/kt_clearlist"] = kt.ClearList													--				longer active.
		CHAT_SYSTEM.textEntry.slashCommandAutoComplete:InvalidateSlashCommandCache()					--	
	elseif (change == "remove") then																	--	
		SLASH_COMMANDS["/kt_rsclist"] = nil																--	
		SLASH_COMMANDS["/kt_keeplist"] = nil															--	
		SLASH_COMMANDS["/kt_rscquest"] = nil															--	
		SLASH_COMMANDS["/kt_keepquest"] = nil															--	
		SLASH_COMMANDS["/kt_addkeep"] = nil																--	
		SLASH_COMMANDS["/kt_addrsc"] = nil																--	
		SLASH_COMMANDS["/kt_clearlist"] = nil															--	
		CHAT_SYSTEM.textEntry.slashCommandAutoComplete:InvalidateSlashCommandCache()					--	
	else																								--	
		d("Can only 'add' or 'remove' debug commands")													--	
	end																									--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.AddKeep(keepID)																				--	Name:		AddKeep
	kt.vars.keepList[#kt.vars.keepList+1] = keepID														--	
	d("[Keep Tracker] Added " .. GetKeepName(keepID) .. " to keepList")									--	Args:		number keepID,
end																										--	
																										--	Purpose:	Used by slash commands to add a keep manually to the keeps list. Only for debugging.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.AddResource(keepID)																			--	Name:		AddResource
	kt.vars.rscList[#kt.vars.rscList+1] = keepID														--	
	d("[Keep Tracker] Added " .. GetKeepName(keepID) .. " to rscList")									--	Args:		number keepID,
end																										--	
																										--	Purpose:	Used by slash commands to add a resource manually to the resource list. Only for
																										--				debugging.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.ClearList(listType)																			--	Name:		ClearList
	if listType == "keep" then																			--	
		kt.vars.keepList = {}																			--	Args:		string listType,
		d("[Keep Tracker] Keeps list has been cleared.")												--	
	elseif listType == "resource" then																	--	Purpose:	Used by slash commands to manually clear specified list type ("keep" or "resource").
		kt.vars.rscList = {}																			--				Only for debugging.
		d("[Keep Tracker] Resources list has been cleared.")											--	
	else																								--	
		d("[Keep Tracker] Unknown list type: " .. listType)												--	
	end																									--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.Debug_Display(display)																		--	Name:		Debug_Display
	if kt.vars.debugMode == true then																	--	
		d(display)																						--	Args:		string display,
	end																									--	
end																										--	Purpose:	Displays string "display" to chat if debug mode boolean is enabled. Used for Debugging.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.GetAllActiveQuests()																		--	Name:		GetAllActiveQuests
	questList = {}																						--	
	for i = 1, GetNumJournalQuests(), 1																	--	Purpose:	There isn't one. Originally written to return a quest list from the journal, it was
	do																									--				never really needed once the add-on was completed. Included more for a
		questList[i] = GetJournalQuestName(i)															--				if-needed-in-the-future reason than anything else. It is not called or used anywhere.
	end																									--	
	return questList																					--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.HasActiveQuest(questName)																	--	Name:		HasActiveQuest
	for i = 0, GetNumJournalQuests()+1, 1																--	
	do																									--	Args:		string questName,
		if GetJournalQuestName(i) == questName then														--	
			return true																					--	Purpose:	Checks if the player's journal contains a quest whose name matches the argument.
		end																								--				Returns true if such a quest is found, false otherwise.
	end																									--	
	return false																						--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.ListContains(list, value)																	--	Name:		ListContains
	if #list < 1 then																					--	
		return false																					--	Args:		table list,
	end																									--				var value,
	for i = 1, #list, 1																					--	
	do																									--	Purpose:	Utility function. Iterates through a list and looks for a set value. If this value is
		if list[i] == value then																		--				found within the list, returns true.
			return true																					--	
		end																								--	
	end																									--	
	return false																						--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.DisplayResourcesList()																		--	Name:		DisplayResourcesList
	if #kt.vars.rscList < 1 then																		--	
		d("[Keep Tracker] Resources list is empty.")													--	Purpose:	Used by slash commands to print current values inside resource list to chat. Only
	else																								--				for debugging.
		d("[Keep Tracker] Resources list contains:")													--	
		for i = 1, #kt.vars.rscList, 1																	--	
		do																								--	
			d(i .. ": " .. GetKeepName(kt.vars.rscList[i]))												--	
		end																								--	
	end																									--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.DisplayKeepsList()																			--	Name:		DisplayKeepsList
	if #kt.vars.keepList < 1 then																		--	
		d("[Keep Tracker] Keeps list is empty.")														--	Purpose:	Used by slash commands to print current values inside keep list to chat. Only
	else																								--				for debugging.
		d("[Keep Tracker] Keeps list contains:")														--	
		for i = 1, #kt.vars.keepList, 1																	--	
		do																								--	
			d(i .. ": " .. GetKeepName(kt.vars.keepList[i]))											--	
		end																								--	
	end																									--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.DisplayResourcesQuest()																		--	Name:		DisplayResourcesQuest
	d("[Keep Tracker] Player has resources quest: " .. tostring(kt.vars.hasResourcesQuest))				--	
end																										--	Purpose:	Used by slash commands to print current value of resource quest boolean to chat.
																										--				Only for debugging.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt.DisplayKeepsQuest()																			--	Name:		DisplayKeepsQuest
	d("[Keep Tracker] Player has keeps quest: " .. tostring(kt.vars.hasKeepsQuest))						--	
end																										--	Purpose:	Used by slash commands to print current value of keep quest boolean to chat. Only
																										--				for debugging.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	//////////////////////////////////////////////////////////////////////////////////////////	MAP PINS FUNCTIONS	//////////////////////////////////////////////////////////////////////////////////////////	--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function pinCreate()																				--	Name:		pinCreate
	if #kt.vars.keepList > 0 then																		--	
		pinLayoutData.size = 25																			--	Purpose:	Local function to be called by pinCallback only. Used to place the pins on the map
		for i = 1, #kt.vars.keepList, 1																	--				using values inside the keep and resource lists.
		do																								--	
			pinType, locX, locY = GetKeepPinInfo(kt.vars.keepList[i], 2)								--				Since both lists store the value of keepID, we can use this keepID with the function
			LMP:CreatePin("kt_capturedlocationpin", GetKeepName(kt.vars.keepList[i]), locX, locY)		--				GetKeepPinInfo (second parameter must be 2 to get the value we want) to obtain that
		end																								--				keep's pin's X and Y coordinates on the map. This allows us to create our map pin
	end																									--				at exactly the same location as the keep/resource captured.
	if #kt.vars.rscList > 0 then																		--	
		pinLayoutData.size = 20																			--				We set the pin size for resources at 20 and for keeps at 25 (just arbitrary, but I
		for i = 1, #kt.vars.rscList, 1																	--				felt it looked nicer with these values).
		do																								--	
			pinType, locX, locY = GetKeepPinInfo(kt.vars.rscList[i], 2)									--	
			LMP:CreatePin("kt_capturedlocationpin", GetKeepName(kt.vars.rscList[i]), locX, locY)		--	
		end																								--	
	end																									--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function pinCallback()																			--	Name:		pinCallback
	if (not LMP:IsEnabled("kt_capturedlocationpin")) then												--	
		return																							--	Purpose:	Local function to be called by Map Pins library whenever the map is updated. This
	end																									--				function first checks if our custom pin "kt_capturedlocationpin" is enabled, and if
	local zone, subzone = LMP:GetZoneAndSubzone()														--				not simply breaks here.
	if (not (zone == "cyrodiil")) then																	--				If our custom pin is enabled, only do something if we're looking at the Cyrodiil map
		return																							--				as a whole, and not any sub-map of Cyrodiil (like the entrance gates).
	end																									--				If all those checks clear, then call the above pinCreated function to place our pins.
	if (not (subzone == "ava_whole")) then																--	
		return																							--	
	end																									--	
	pinCreate()																							--	
end																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local pinTooltipCreator = {																				--	pinTooltipCreator is a local table with tooltip information and constructor. It is used by the
	creator = function()																				--	Map Pins library to create a mouse-over tooltip on our custom map pins.
			InformationTooltip:AddLine("Location Captured")												--	
	end,																								--	Tooltips only display if kt.vars.pinTooltipEnabled boolean is set to true. This can be toggled
	tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,															--	with slash commands and is saved per character.
	hasTooltip = function()																				--	
		return kt.vars.pinTooltipEnabled																--	
	end,																								--	
}																										--	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	//////////////////////////////////////////////////////////////////////////////////////////	EVENT REGISTRATIONS	//////////////////////////////////////////////////////////////////////////////////////////	--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(kt.name, EVENT_ADD_ON_LOADED, kt.OnAddOnLoaded)							--	Runs kt.OnAddOnLoaded when any addon is loaded.
EVENT_MANAGER:RegisterForEvent(kt.name, EVENT_PLAYER_ACTIVATED, kt.Active)								--	Runs kt.Active when the player has finished a loading screen.
EVENT_MANAGER:RegisterForEvent(kt.name, EVENT_QUEST_ADDED, kt.QuestAdded)								--	Runs kt.QuestAdded when a player picks up a new quest.
EVENT_MANAGER:RegisterForEvent(kt.name, EVENT_QUEST_COMPLETE, kt.QuestCompleted)						--	Runs kt.QuestCompleted when a quest is turned in and removed from the quest journal.
EVENT_MANAGER:RegisterForEvent(kt.name, EVENT_QUEST_LIST_UPDATED, kt.QuestListUpdated)					--	Runs kt.QuestListUpdated when the quest journal entries change slots (usually after every loadscreen).
EVENT_MANAGER:RegisterForEvent(kt.name, EVENT_KEEP_ALLIANCE_OWNER_CHANGED, kt.KeepCaptured)				--	Runs kt.KeepCaptured when a keep/resource/town/outpost is captured by any alliance.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	//////////////////////////////////////////////////////////////////////////////////////////	  SLASH COMMANDS	//////////////////////////////////////////////////////////////////////////////////////////	--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/kt_debug"] = kt.Debug_Toggle															--	Toggles debug mode for KeepTracker, including enabling all debug slash commands and verbose chat.
SLASH_COMMANDS["/kt_tooltip"] = kt.Tooltip_Toggle														--	Toggles display of map pin tooltips, default is off.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	//////////////////////////////////////////////////////////////////////////////////////////	INITIALIZE FUNCTION	//////////////////////////////////////////////////////////////////////////////////////////	--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function kt:Initialize(eventCode)																		--	Name:		Initialize
	EVENT_MANAGER:UnregisterForEvent(kt.name, EVENT_ADD_ON_LOADED)										--	
																										--	Args:		number eventCode,
	-- Load saved variables																				--	
	kt.vars = ZO_SavedVars:NewCharacterNameSettings("KTVars", 1, nil, DefaultVars)						--	Purpose:	Runs basic initial code for KeepTracker, called by kt.OnAddOnLoaded function. First
	if kt.vars.debugMode then																			--				unregisters from event, then loads saved variables from file if one exists. Enable
		kt.DebugCommands("add")																			--				debug slash commands if debug mode was left on. Declares custom map pin using Map Pins
	end																									--				library.
	LibMapPins:AddPinType("kt_capturedlocationpin", pinCallback, nil, pinLayoutData, pinTooltipCreator)	--				Note that the first argument has to be unique as it is the key used to distinguish pin
end																										--				types. This also instructs what the callback function is, and the base pin data.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------