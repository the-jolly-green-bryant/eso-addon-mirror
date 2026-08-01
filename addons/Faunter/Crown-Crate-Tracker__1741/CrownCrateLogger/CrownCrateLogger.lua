---------------------
-- Crate recording --
---------------------

-- This function is called every time a new crown crate is opened
local function OnCrownCrateOpenResponse(eventCode, crownCrateId, response)

	-- Create the crate's data string, which will contain compact data about this crate
	local timestamp = GetTimeStamp()
	local crateData = string.format("%s,%s", timestamp, crownCrateId)

	-- Loop through all of this crate's rewards and record the results
	local totalRewards = GetNumCurrentCrownCrateTotalRewards()
	for i = 1, totalRewards do

		-- Get all of the current reward's info
		local rewardName, rewardTypeText, cardFaceImage, cardFaceFrameAccentImage, gemsExchanged, isBonus, crownCrateTierId, stackCount = GetCrownCrateRewardInfo(i)
		local rewardProductType, referenceDataId = GetCrownCrateRewardProductReferenceData(i)

		local countFormatted = string.format("%sx", stackCount)
		local cardType
		local rewardType

		-- Format the card type
		if isBonus then
			cardType = "="
		else
			cardType = "-"
		end

		-- Handle the different reward types
		if rewardProductType == MARKET_PRODUCT_TYPE_COLLECTIBLE then
			rewardType = "c"
		elseif rewardProductType == MARKET_PRODUCT_TYPE_ITEM then
			rewardType = "i"
		else
			rewardType = "?"
			referenceDataId = string.format("%s<%s>%s", rewardProductType, rewardName, referenceDataId)
		end

		-- Append the current reward's info to the crate data
		crateData = string.format("%s,%s%s%s%s%s", crateData, i, cardType, rewardType, countFormatted, referenceDataId)
	end

	-- Finalize the data string by adding a terminator character
	crateData = string.format("%s]", crateData)

	-- Make a new entry in the SavedVariables
	-- CrownCrateData.Crates["Crate info"] is never nil because the Settings table is nested inside during addon loading
	-- The Settings table isn't included in the count either, so we can safely increment the index when adding new crates
	local crateInfo = ZO_SavedVars:New("CrownCrateData", nil, nil, nil, "Crates", "Crate info", #CrownCrateData.Crates["Crate info"] + 1)

	-- Save the crate's data and set the crate status to Unsubmitted
	crateInfo["Data"] = crateData
	crateInfo["Status"] = "Unsubmitted"
	CrownCrateTracker.savedVariables.allSubmitted = false

	--[[
	Finished crateData looks something like this: 1506422942,4,1-i1x124675,2-c1x1216,3-i1x124678,4-i25x79690,5=c1x18]
	The properties are separated by commas, and each crate ends with the terminator character ]
	The line starts with a timestamp and the crate ID, followed by info on all the rewards received from this crate
	The reward result structure starts with the reward number, then "-" or "=" for normal or bonus, i for Item or c for Collectible, a stackCount with "x" after it, and finally the item ID
	crateData is used for sending compact information through the in-game mail system, as well as populating crate history rows
	]]
end





--------------------
-- Crate reminder --
--------------------

-- This function is called after loading screens
-- It mails any unsubmitted crate results and checks if a crate reminder should be announced
local function RefreshAddon()

	-- If there happen to be any unsubmitted crate results, mail them all in
	if not CrownCrateTracker.savedVariables.allSubmitted then
		CrownCrateTracker.MailCrateResults()
	end

	-- If the player doesn't have any crates to open at the moment, there is no need to continue further
	local ownedCrateTypes = GetNumOwnedCrownCrateTypes()
	if ownedCrateTypes == 0 then

		-- Reset the addon state if no mailing was done
		if CrownCrateTracker.currentState == CrownCrateTracker.STATE_REFRESHING then
			CrownCrateTracker.currentState = CrownCrateTracker.STATE_IDLE
		end

		return
	end

	local timestamp = GetTimeStamp()
	local gameTime = math.floor(GetGameTimeMilliseconds() / 1000)

	--[[
	Create a session variable to act as a unique identifier which can be checked retroactively to tell this session apart from others
	The session is changed when logging into a different account or when exiting out of the client completely
	It needs to be retroactive so we can make a crate reminder play at least once per login, even if the addon is activated mid-game
	Session collision will never be a problem, especially if we allow for a 5-second margin of error
	Within 5 seconds, it's impossible to log into 2 different accounts or exit the client and relog
	]]

	local session = HashString(GetUnitDisplayName("player")) + timestamp - gameTime
	local isNewSession = session < CrownCrateTracker.savedVariables.session - 5 or CrownCrateTracker.savedVariables.session + 5 < session

	-- If this is a new session, or if we're in-game and the amount of has crates changed, play a reminder containing whichever key toggles the crown crate menu
	if isNewSession or CrownCrateTracker.savedVariables.numCratesChanged then

		CrownCrateTracker.savedVariables.numCratesChanged = false
		CrownCrateTracker.savedVariables.session = session

		local validKey
		local invalidKey = GetKeyName(KEY_INVALID)
		local announcementText

		-- Locate the crown crate action indices and go through all the binds that can be set for this action
		local layer, category, action = GetActionIndicesFromName("TOGGLE_CROWN_CRATES")
		for i = 1, GetMaxBindingsPerAction() do

			local keyName = GetKeyName(GetActionBindingInfo(layer, category, action, i))

			-- Exit the loop when the first valid key is found
			if keyName ~= invalidKey then
				validKey = keyName
				break
			end
		end

		-- Set the appropriate announcement text
		if validKey then
			announcementText = string.format("%s |cC5C29E%s|r %s", GetString(SI_CROWN_CRATE_TRACKER_REMINDER_BOUND_1), validKey, GetString(SI_CROWN_CRATE_TRACKER_REMINDER_BOUND_2))
		else
			announcementText = GetString(SI_CROWN_CRATE_TRACKER_REMINDER_UNBOUND)
		end

		-- Announce the reminder if the state is still refreshing (no mailing was done) or wait for the idle state (in case the addon is mailing->announcing)
		-- However, don't remind if the player already went inside the crate menu while we were waiting
		-- We use a custom recursive instead of registering the function for an update because we want to announce immediately if we're still refreshing
		local function WaitForAllClear()
			local currentScene = SCENE_MANAGER:GetCurrentScene():GetName()
			if currentScene == "crownCrateKeyboard" or currentScene == "crownCrateGamepad" then
				return
			elseif CrownCrateTracker.currentState == CrownCrateTracker.STATE_REFRESHING or CrownCrateTracker.currentState == CrownCrateTracker.STATE_IDLE then
				local csaMessage = string.format("\n%s\n\n%s\n%s", CrownCrateTracker.ICON_CSA, announcementText, GetString(SI_CROWN_CRATE_TRACKER_REMINDER_INFO))
				CrownCrateTracker.ShowCSA(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.CROWN_CRATES_CARD_FLIPPING, csaMessage, nil, CrownCrateTracker.DURATION_LONG)
			else
				zo_callLater(WaitForAllClear, CrownCrateTracker.DURATION_SHORTEST)
			end
		end
		WaitForAllClear()
	elseif CrownCrateTracker.currentState == CrownCrateTracker.STATE_REFRESHING then

		-- Reset the addon state if no mailing and reminding was done
		CrownCrateTracker.currentState = CrownCrateTracker.STATE_IDLE
	end
end

-- This function is called after every loading screen
-- We use it to refresh the addon every time a loading screen ends
local function OnPlayerActivated(eventCode, initial)

	-- Wait for all announcements and scenes to be cleared before refreshing the addon
	local function WaitForAllClear()
		local hasAnyActiveLines = CENTER_SCREEN_ANNOUNCE:HasAnyActiveLines()
		local currentScene = SCENE_MANAGER:GetCurrentScene():GetName()

		-- If the player enters the crown crate scene while we wait, there is no need to refresh
		if not hasAnyActiveLines and (currentScene == "crownCrateKeyboard" or currentScene == "crownCrateGamepad") then
			EVENT_MANAGER:UnregisterForUpdate("CrownCrateTrackerActivated")
			CrownCrateTracker.savedVariables.numCratesChanged = false
			CrownCrateTracker.currentState = CrownCrateTracker.STATE_IDLE
		elseif not hasAnyActiveLines and (currentScene == "hud" or currentScene == "hudui") then
			EVENT_MANAGER:UnregisterForUpdate("CrownCrateTrackerActivated")
			RefreshAddon()
		end
	end

	-- Keep checking if we're ready to refresh the addon until we are
	EVENT_MANAGER:RegisterForUpdate("CrownCrateTrackerActivated", CrownCrateTracker.DURATION_SHORTEST, WaitForAllClear)
end

-- This function is called every time there is a change in the amount of owned crown crates
-- We use it to set a flag for the crate reminder announcement in RefreshAddon()
local function OnCrownCrateQuantityUpdate(eventCode, crateId, count)

	-- If there are more crates left after the quantity change, force the reminder after the next loading screen
	-- For example, someone might buy crates or receive some from login rewards / out-of-game events, and not open them immediately
	local ownedCrateTypes = GetNumOwnedCrownCrateTypes()
	if ownedCrateTypes == 0 then
		CrownCrateTracker.savedVariables.numCratesChanged = false -- There are no more crates, so block the reminder
	else
		CrownCrateTracker.savedVariables.numCratesChanged = true
	end
end





-------------------
-- Addon loading --
-------------------

-- This function is called before the player is activated, when addons are still being loaded
local function OnAddOnLoaded(eventCode, addonName)

	-- If the addon isn't Crown Crate Tracker, ignore it
	if addonName ~= CrownCrateTracker.ADDON_NAME then
		return
	end

	-- Unregister this addon from further addon loaded events
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

	-- Create the SavedVariables
	local defaults = { mailErrorOccurred = false, numCratesChanged = false, allSubmitted = false, session = -1 }
	CrownCrateTracker.savedVariables = ZO_SavedVars:New("CrownCrateData", 2, nil, defaults, "Crates", "Crate info", "Settings")

	-- Register listeners for all relevant events
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CROWN_CRATE_OPEN_RESPONSE, OnCrownCrateOpenResponse)
	-- Disabled EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	-- Disabled EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CROWN_CRATE_QUANTITY_UPDATE, OnCrownCrateQuantityUpdate)
	-- Disabled EVENT_MANAGER:RegisterForEvent(addonName, EVENT_MAIL_SEND_SUCCESS, CrownCrateTracker.OnMailSendSuccess)
	-- Disabled EVENT_MANAGER:RegisterForEvent(addonName, EVENT_MAIL_SEND_FAILED, CrownCrateTracker.OnMailSendFailed)

	-- Hook all relevant functions
	CrownCrateTracker.HookRelevantFunctions()

	-- Create a chat command for opening the website
	SLASH_COMMANDS["/crowncrates"] = CrownCrateTracker.VisitWebsite
end

-- Register a listener so we can start setting up the addon when it gets loaded
EVENT_MANAGER:RegisterForEvent(CrownCrateTracker.ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)