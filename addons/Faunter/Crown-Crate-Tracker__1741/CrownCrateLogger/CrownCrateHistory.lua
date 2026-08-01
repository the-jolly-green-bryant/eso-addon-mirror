-------------------------
-- Base initialization --
-------------------------

local HISTORY_CONTAINER_TYPE_LABEL = 0
local HISTORY_CONTAINER_TYPE_TEXTURE = 1
local HISTORY_CONTAINER_TYPE_REWARD = 2

local CrateHistoryList = ZO_SortFilterList:Subclass()
local setTitleFragment = ZO_SetTitleFragment:New()
setTitleFragment.title = GetString(SI_CROWN_CRATE_TRACKER_HISTORY_TITLE)

-- XML UI
CrateTrackerLoadingLabel:SetText(GetString(SI_CROWN_CRATE_TRACKER_MAIL_SENDING))
CrateTrackerHistorySearchLabel:SetText(GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH))
CrateTrackerHistoryNoMatch:SetText(GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_FAILED))
CrateTrackerHistoryNoCrates:SetText(GetString(SI_CROWN_CRATE_TRACKER_HISTORY_INFO))
CrateTrackerHistoryHeadersReward1:SetText(GetString(SI_CROWN_CRATE_TRACKER_HISTORY_HEADER_REWARD_1))
CrateTrackerHistoryHeadersReward2:SetText(GetString(SI_CROWN_CRATE_TRACKER_HISTORY_HEADER_REWARD_2))
CrateTrackerHistoryHeadersReward3:SetText(GetString(SI_CROWN_CRATE_TRACKER_HISTORY_HEADER_REWARD_3))
CrateTrackerHistoryHeadersReward4:SetText(GetString(SI_CROWN_CRATE_TRACKER_HISTORY_HEADER_REWARD_4))
CrateTrackerHistoryHeadersReward5:SetText(GetString(SI_CROWN_CRATE_TRACKER_HISTORY_HEADER_REWARD_5))
-- Disabled CrateTrackerHistoryHeadersStatus:SetText(GetString(SI_CROWN_CRATE_TRACKER_HISTORY_HEADER_SUBMITTED))





----------------------------
-- Crate history toggling --
----------------------------

-- Expanding upon the crown crate state machine doesn't seem to be possible
-- We'll have to deal with this patchworky code for showing the crate history instead

-- This function is called when the crate history is toggled OFF
local function HideCrateHistory()

	-- Reset the tooltip arrow here instead of in a reward container's OnMouseExit handler
	-- This makes the arrow have a nice fade out with the tooltip when the mouse exits the container
	CrateTrackerHistoryTooltipArrow:SetHidden(true)
	CrateTrackerHistoryTooltipArrow:SetParent(CrateTrackerHistory)
	CrateTrackerHistoryTooltipArrow:ClearAnchors()

	-- Hide the crate history control
	CrateTrackerHistory:SetHidden(true)

	-- Cleanse dirty daedric magic from the scene
	CROWN_CRATE_KEYBOARD_SCENE:RemoveFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	CROWN_CRATE_KEYBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_CENTERED_NO_BLUR)
	CROWN_CRATE_KEYBOARD_SCENE:RemoveFragment(RIGHT_BG_FRAGMENT)
	CROWN_CRATE_KEYBOARD_SCENE:RemoveFragment(setTitleFragment)
	CROWN_CRATE_KEYBOARD_SCENE:RemoveFragment(TITLE_FRAGMENT)

	-- Enable the crates
	CROWN_CRATES_FRAGMENT:Show()

	-- Restore the original keybind strip
	KEYBIND_STRIP:PopKeybindGroupState()
end

-- This function is called when the crate history is toggled ON
local function ShowCrateHistory()

	-- Disable the crates and hide the tracker active text
	CROWN_CRATES_FRAGMENT:Hide()
	CrateTrackerActive:SetHidden(true)

	-- Apply dirty daedric magic to the scene
	CROWN_CRATE_KEYBOARD_SCENE:AddFragment(TITLE_FRAGMENT)
	CROWN_CRATE_KEYBOARD_SCENE:AddFragment(setTitleFragment)
	CROWN_CRATE_KEYBOARD_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
	CROWN_CRATE_KEYBOARD_SCENE:RemoveFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_CENTERED_NO_BLUR)
	CROWN_CRATE_KEYBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)

	-- Create descriptors for the 2 buttons we'll need to show inside the history
	local websiteKeybind = {
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
		name = GetString(SI_CROWN_CRATE_TRACKER_BUTTON_WEBSITE),
		keybind = "UI_SHORTCUT_PRIMARY",
		callback = CrownCrateTracker.VisitWebsite
	}

	local function BackButtonCallback()

		HideCrateHistory()

		-- These two are in here instead of in HideCrateHistory()
		-- This is because the scene might be closed while viewing the history, in which case:
		-- A sound shouldn't be played and the tracker active text should remain hidden
		PlaySound(SOUNDS.CROWN_CRATES_CARDS_LEAVE)
		CrateTrackerActive:SetHidden(false)

		-- Dynamically react to the player's amount of crates when restoring the scene
		local numOwnedCrateTypes = GetNumOwnedCrownCrateTypes()
		if numOwnedCrateTypes == 0 then
			TriggerCrownCrateNPCAnimation(CROWN_CRATE_NPC_ANIMATION_TYPE_MANIFEST_ENTER_NO_CRATES)
		elseif numOwnedCrateTypes == 1 then
			TriggerCrownCrateNPCAnimation(CROWN_CRATE_NPC_ANIMATION_TYPE_MANIFEST_ENTER_ONE_CRATES)
		else
			TriggerCrownCrateNPCAnimation(CROWN_CRATE_NPC_ANIMATION_TYPE_MANIFEST_ENTER_MULTI_CRATES)
		end
	end

	local backKeybind = {
		alignment = KEYBIND_STRIP_ALIGN_RIGHT,
		name = GetString(SI_CROWN_CRATE_TRACKER_BUTTON_BACK),
		keybind = "UI_SHORTCUT_SECONDARY",
		callback = BackButtonCallback
	}

	-- Replace all the keybinds on the strip with new ones
	-- (No idea, don't ask)
	KEYBIND_STRIP:PushKeybindGroupState()
	KEYBIND_STRIP:PushKeybindGroupState()
	KEYBIND_STRIP:AddKeybindButton(websiteKeybind, 2)
	KEYBIND_STRIP:AddKeybindButton(backKeybind, 2)
	KEYBIND_STRIP:PopKeybindGroupState()

	-- Build a new master list in case crates were opened/submitted, play a UI sound, and display the crate history control
	CrateHistoryList:RefreshData()
	PlaySound(SOUNDS.CROWN_CRATES_CARDS_REVEAL_ALL)
	CrateTrackerHistory:SetHidden(false)

	-- Trigger an appropriate NPC animation when entering the crate history menu
	if #CrateHistoryList.masterList == 0 then
		-- If there are no rewards: "Open a crate!"
		TriggerCrownCrateNPCAnimation(CROWN_CRATE_NPC_ANIMATION_TYPE_MANIFEST_ENTER_NO_CRATES)
	else
		-- If crates have been opened: "Select a reward to learn more!"
		TriggerCrownCrateNPCAnimation(CROWN_CRATE_NPC_ANIMATION_TYPE_PRIMARY_CARDS_DEALT)
	end
end

-- This function is called when the player presses the crate history keybind on the keybind strip
local function ToggleCrateHistory()

	-- Create the crate history list if it doesn't already exist
	if not CrateHistoryList.masterList then
		CrateHistoryList:New(CrateTrackerHistory)
	end

	-- If the crate history control is hidden, show it
	-- If the crate history control is visible, hide it
	if CrateTrackerHistory:IsHidden() then
		ShowCrateHistory()
	else
		HideCrateHistory()
	end
end





------------------------------
-- Interface prep and hooks --
------------------------------

-- This function sets text for the the upper-left label
local function SetActiveText()

	local labelText = "Crown Crate Tracker"
	local status

	local date = GetDate()
	local fullDate = tonumber(date)
	local monthDay = tonumber(string.sub(date, 5))

	if fullDate == 20230113 or -- Fatal Fredas
		fullDate == 20231013 or
		fullDate == 20240913 or
		fullDate == 20241213 or
		fullDate == 20250613 or
		fullDate == 20260213 or
		fullDate == 20260313 or
		fullDate == 20261113 or
		fullDate == 20270813 or
		fullDate == 20281013 or
		fullDate == 20290413 or
		fullDate == 20290713 or
		fullDate == 20300913 or
		fullDate == 20301213 then
		status = string.format("|c646464%s|r", GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_5))
	elseif 0213 <= monthDay and monthDay <= 0215 then -- Heart's Day
		status = string.format("|cFFC8D2%s|r", GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_6))
	elseif 0331 <= monthDay and monthDay <= 0402 then -- Jester's Festival
		status = GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_7)
	elseif 0622 <= monthDay and monthDay <= 0624 then -- Anniversary
		status = string.format("|cEECA2A%s|r", GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_8))
	elseif 1029 <= monthDay and monthDay <= 1031 then -- Witches Festival
		status = string.format("|c649632%s|r", GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_9))
	elseif 1223 <= monthDay and monthDay <= 1225 then -- New Life Festival
		status = string.format("|cC8E1FA%s|r", GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_10))
	else
		-- No special date; let's have a bit of fun
		local statusRoll = math.random(1, 1000)

		if statusRoll <= 950 then -- 95.0% chance
			status = GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_1)
		elseif statusRoll <= 980 then -- 3.0% chance
			status = GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_2)
		elseif statusRoll <= 985 then -- 0.5% chance
			status = GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_3)
		elseif statusRoll <= 990 then -- 0.5% chance
			status = GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_4)
		elseif statusRoll <= 992 then -- 0.2% chance
			status = string.format("|c2DC50E%s|r", GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_11))
		elseif statusRoll <= 994 then -- 0.2% chance
			status = string.format("|c3A92FF%s|r", GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_12))
		elseif statusRoll <= 996 then -- 0.2% chance
			status = string.format("|cA02EF7%s|r", GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_13))
		elseif statusRoll <= 998 then -- 0.2% chance
			status = string.format("|cEECA2A%s|r", GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_14))
		elseif statusRoll == 999 then -- 0.1% chance
			status = string.format("|cC16403%s|r", GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_15))
		elseif statusRoll == 1000 then -- 0.1% chance
			status = string.format("|cEA5C40%s|r", GetString(SI_CROWN_CRATE_TRACKER_LABEL_STATUS_16))
		end
	end

	labelText = string.format("%s %s", labelText, status)

	CrateTrackerActiveLabel:SetText(labelText)
end

-- This function is only called once, as soon as the addon is loaded
-- It applies hooks to all relevant functions and modifies certain base behaviors
function CrownCrateTracker.HookRelevantFunctions()

	-- Create the crate history toggle button that will be used when adding/removing keybinds
	local crateHistoryKeybind = {
		alignment = KEYBIND_STRIP_ALIGN_RIGHT,
		name = GetString(SI_CROWN_CRATE_TRACKER_BUTTON_HISTORY),
		keybind = "UI_SHORTCUT_SECONDARY",
		callback = ToggleCrateHistory
	}

	-- Add the crate history keybind and show the tracker active label when entering the crown crate scene
	local function AddKeybindsHook()
		SetActiveText()
		CrateTrackerActive:SetHidden(false)

		-- Crate history is only supported for keyboard mode
		if not IsInGamepadPreferredMode() then
			KEYBIND_STRIP:AddKeybindButton(crateHistoryKeybind)
		end
	end

	-- Remove the crate history keybind when leaving the crown crate scene
	local function RemoveKeybindsHook()

		-- Crate history is only supported for keyboard mode
		if not IsInGamepadPreferredMode() then
			KEYBIND_STRIP:RemoveKeybindButton(crateHistoryKeybind)
		end
	end

	-- Clean up the crate scene if the player exits while browsing the crate history
	-- Also mail all unsubmitted crate results after exiting
	local function ExitHook(scene, newState)
		if newState == SCENE_HIDING then

			CrateTrackerActive:SetHidden(true)

			if not CrateTrackerHistory:IsHidden() then
				HideCrateHistory()
			end

			if not CrownCrateTracker.savedVariables.allSubmitted and CrownCrateTracker.currentState == CrownCrateTracker.STATE_IDLE then
				-- Disabled CrownCrateTracker.MailCrateResults()
			end
		end
	end

	-- Block all error alerts when the addon fails to send a mail
	local function MailErrorHook(eventCode, reason)
		if CrownCrateTracker.hasMailPending then
			return true
		end
	end

	-- Play a sound when the crate history sort headers are clicked
	local function PlayHeaderSound(control, upInside)
		if control.isCrownCrateTrackerHeader and upInside then
			PlaySound(SOUNDS.DIALOG_ACCEPT)
		end
	end

	-- Prevent the crown crate menu from getting blurred
	local function BlockCrateSceneBlur(effect)
		local currentScene = SCENE_MANAGER:GetCurrentScene():GetName()
		if (currentScene == "crownCrateKeyboard" or currentScene == "crownCrateGamepad") and 
		effect == FULLSCREEN_EFFECT_CHARACTER_FRAMING_BLUR then
			return true
		end
	end

	-- Apply all the hooks
	ZO_PreHook(ZO_CrownCratesPackChoosing, "AddManifestKeybinds", AddKeybindsHook)
	ZO_PreHook(ZO_CrownCratesPackChoosing, "RemoveManifestKeybinds", RemoveKeybindsHook)
	ZO_PreHook(CROWN_CRATE_KEYBOARD_SCENE, "SetState", ExitHook)
	ZO_PreHook(CROWN_CRATE_GAMEPAD_SCENE, "SetState", ExitHook)
	ZO_PreHook(ZO_AlertText_GetHandlers(), EVENT_MAIL_SEND_FAILED, MailErrorHook)
	ZO_PreHook(_G, "ZO_SortHeader_OnMouseUp", PlayHeaderSound)
	ZO_PreHook(_G, "SetFullscreenEffect", BlockCrateSceneBlur)
end





----------------------
-- Crate history UI --
----------------------

-- This function initializes the crate history list and is only called a single time, when the crate history is toggled ON for the first time
function CrateHistoryList:New(crateHistoryControl)

	-- Get the two arrow headers that will be used for sorting the list
	local numberSortHeader = GetControl(crateHistoryControl, "HeadersNumber")
	local crateSortHeader = GetControl(crateHistoryControl, "HeadersCrate")

	-- Mark the headers so the ZO_SortHeader_OnMouseUp hook knows to play a sound when they're clicked
	numberSortHeader.isCrownCrateTrackerHeader = true
	crateSortHeader.isCrownCrateTrackerHeader = true

	-- Make the initial click sort the list in ascending order, because the default sort is descending (newest crates first)
	ZO_SortHeader_InitializeArrowHeader(numberSortHeader, "crateNumber", ZO_SORT_ORDER_UP)
	ZO_SortHeader_InitializeArrowHeader(crateSortHeader, "crateType", ZO_SORT_ORDER_UP)
	ZO_SortHeader_SetTooltip(numberSortHeader, GetString(SI_CROWN_CRATE_TRACKER_HISTORY_HEADER_CRATE_NUMBER))
	ZO_SortHeader_SetTooltip(crateSortHeader, GetString(SI_CROWN_CRATE_TRACKER_HISTORY_HEADER_CRATE_TYPE))

	-- Initialize CrateHistoryList.list (there must be a child named List that inherits ZO_ScrollList inside the control)
	ZO_SortFilterList.InitializeSortFilterList(CrateHistoryList, crateHistoryControl)

	-- Create the keys that will be used for sorting the list
	-- Many crateTypes can be the same, so we use their crateNumbers to sort one level deeper
	local sortKeys = {
		["crateNumber"] = {},
		["crateType"] = { tiebreaker = "crateNumber" }
	}

	-- Set the default sort key and the initial order the list should be sorted in
	CrateHistoryList.currentSortKey = "crateNumber"
	CrateHistoryList.currentSortOrder = ZO_SORT_ORDER_DOWN

	-- Create a crate history row data type and set its row setup function
	local function SetupCallback(crateHistoryControl, crateData)
		CrateHistoryList:SetupHistoryRow(crateHistoryControl, crateData)
	end
	ZO_ScrollList_AddDataType(CrateHistoryList.list, 1, "CrateHistoryRow", 60, SetupCallback)

	-- Set the function to be called when the list needs to get sorted
	local function SortingFunction(listEntry1, listEntry2)
		return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, CrateHistoryList.currentSortKey, sortKeys, CrateHistoryList.currentSortOrder)
	end
	CrateHistoryList.sortFunction = SortingFunction

	-- Make the row backgrounds alternate between dark and transparent, and enable mouse-over row highlighting
	-- There must be a texture named BG that inherits ZO_ThinListBgStrip inside the virtual row control for alternating backgrounds to work
	CrateHistoryList:SetAlternateRowBackgrounds(true)
	ZO_ScrollList_EnableHighlight(CrateHistoryList.list, "ZO_TallListHighlight")

	-- Set up a search box to filter the list
	CrateHistoryList.searchBox = GetControl(crateHistoryControl, "SearchBox")
	CrateHistoryList.searchTerm = CrateHistoryList.searchBox:GetText():lower()

	-- Whenever its text changes, play a search sound, save the updated text, and refresh the filters (this filters and then sorts the list)
	CrateHistoryList.searchBox:SetHandler("OnTextChanged", function()
		PlaySound(SOUNDS.BOOK_PAGE_TURN)
		CrateHistoryList.searchTerm = CrateHistoryList.searchBox:GetText():lower()
		CrateHistoryList:RefreshFilters()
	end)
end

-- This function is called by CrateHistoryList:RefreshData() when the crate history is toggled ON
-- It builds the master list of crates that is later displayed in the history control
function CrateHistoryList:BuildMasterList()

	CrateHistoryList.masterList = {}

	-- Ignore older crates that were recorded without data (addon versions 1.2 and below)
	local totalCrates = #CrownCrateData.Crates["Crate info"]

	-- Go through all recorded crates and insert their data into the master list, one by one
	for i = 1, totalCrates do

		-- Create reward data tables to hold all of this crate's reward data (Cards 1-5)
		local itemQuantities = {}
		local itemTextures = {}
		local itemNames = {}
		local itemTiers = {}
		local itemLinks = {}
		local itemBonuses = {}

		local crateProperties = {}
		local currentProperty = 1
		local previousSeparatorIndex = 0

		local currentRowData = CrownCrateData.Crates["Crate info"][i].Data
		local submitStatus = CrownCrateData.Crates["Crate info"][i].Status

		-- Loop through every single character in this crate's data line and separate the crate properties
		-- Example crate data = "1511966113,6,1-i1x64701,2-c1x98,3-i25x79690,4-i10x124674,5=c1x110]"
		-- Example properties =  1         ,2,3         ,4      ,5          ,6           ,7
		for j = 1, currentRowData:len() do

			local currentChar = currentRowData:sub(j, j)

			if currentChar == "," or currentChar == "]" then
				crateProperties[currentProperty] = currentRowData:sub(previousSeparatorIndex + 1, j - 1)
				currentProperty = currentProperty + 1
				previousSeparatorIndex = j
			end
		end

		-- The timestamp and the crateId are always properties 1 and 2
		local timestamp = crateProperties[1]
		local crateId = crateProperties[2]

		-- Deal with reward numbers instead of properties for the rewards
		local numRewards = #crateProperties - 2

		-- Set a hard cap to only display the supported amount of rewards, in case there are more for some reason
		if numRewards > CrownCrateTracker.MAX_REWARDS_SUPPORTED then
			numRewards = CrownCrateTracker.MAX_REWARDS_SUPPORTED
		end

		-- Store all of this crate's reward data into the data tables
		for j = 1, numRewards do

			-- We account for the first 2 properties (timestamp and crateId) by using an offset
			-- This allows us to deal with the rewards directly when asking for crate properties
			local currentProperty = j + 2

			-- For the time being, we don't care about the first character of reward properties (card number such as "1" or "5")

			-- Character 2 is always the item bonus level (normal reward "-" and bonus reward "=")
			local bonus = crateProperties[currentProperty]:sub(2, 2)
			if bonus == "-" then
				itemBonuses[j] = false
			elseif bonus == "=" then
				itemBonuses[j] = true
			end

			-- Character 3 is always the item type (Collectible "c", Item "i", or Unknown "?")
			local itemType = crateProperties[currentProperty]:sub(3, 3)
			local itemId
			local propertyLength = crateProperties[currentProperty]:len()

			-- Get the stack count by looping through every single character in this reward property, starting from character 4, until we reach an "x"
			for k = 4, propertyLength do

				local currentChar = crateProperties[currentProperty]:sub(k, k)

				-- If we reach an x, that means the item quantity is before it, and the item id is after it
				if currentChar == "x" then
					itemQuantities[j] = tonumber(crateProperties[currentProperty]:sub(4, k - 1))
					itemId = crateProperties[currentProperty]:sub(k + 1, propertyLength)
					break
				end
			end

			-- Handle the different item types
			if itemType == "i" then
				itemLinks[j] = string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
				itemNames[j] = GetItemLinkName(itemLinks[j])
				local tierString = string.format("%s-i%sx%s", crateId, itemQuantities[j], itemId)
				itemTiers[j] = 0 -- Disabled CrownCrateRewardTiers[tierString]
				itemTextures[j] = GetItemLinkIcon(itemLinks[j])
			elseif itemType == "c" then
				local itemDesc
				itemNames[j], itemDesc, itemTextures[j] = GetCollectibleInfo(itemId)
				local tierString = string.format("%s-c%sx%s", crateId, itemQuantities[j], itemId)
				itemTiers[j] = 0 -- Disabled CrownCrateRewardTiers[tierString]
				itemLinks[j] = string.format("|H1:collectible:%s|h|h", itemId)
			else
				itemNames[j] = string.format("???: %s", itemId)
				itemTiers[j] = -1
				itemLinks[j] = "|H1:item:112432:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0|h|h"
				itemTextures[j] = "esoui/art/icons/icon_missing.dds"
			end

			-- Format the item name to remove all modifiers and fix the capitalization
			itemNames[j] = zo_strformat("<<t:1>>", itemNames[j])
		end

		-- If this crate has less rewards than the maximum supported, set the blank ones to empty instead of nil
		if numRewards < CrownCrateTracker.MAX_REWARDS_SUPPORTED then
			for j = numRewards + 1, CrownCrateTracker.MAX_REWARDS_SUPPORTED do
				itemQuantities[j] = 0
				itemNames[j] = ""
				itemTiers[j] = -1
				itemLinks[j] = ""
				itemTextures[j] = ""
				itemBonuses[j] = false
			end
		end

		-- Copy all of this crate's reward data into a single rewards table to easily insert it in the master list
		local rewardData = {}
		for j = 1, CrownCrateTracker.MAX_REWARDS_SUPPORTED do
			local name = itemNames[j]
			local tier = itemTiers[j]
			local link = itemLinks[j]
			local quantity = itemQuantities[j]
			local texture = itemTextures[j]
			local bonus = itemBonuses[j]

			rewardData[j] = { rewardName = name, rewardTier = tier, rewardLink = link, rewardQuantity = quantity, rewardTexture = texture, isRewardBonus = bonus }
		end

		-- Insert this the entire crate data into the master list
		table.insert(CrateHistoryList.masterList, {
			crateNumber = string.format("%s %s", GetString(SI_CROWN_CRATE_TRACKER_HISTORY_LABEL_CRATE_NUMBER), i),
			crateTimestamp = timestamp,
			crateType = crateId,
			crateStatus = submitStatus,
			crateRewards = rewardData
		})
	end

	-- If the master list is empty, there are no recorded crates, so show the no crates label
	if #CrateHistoryList.masterList == 0 then
		CrateTrackerHistoryNoCrates:SetHidden(false)
	else
		CrateTrackerHistoryNoCrates:SetHidden(true)
	end
end

-- This function determines if a given row contains a bonus reward
local function RowContainsBonusReward(rowRewards)
	if rowRewards[1].isRewardBonus or
	rowRewards[2].isRewardBonus or
	rowRewards[3].isRewardBonus or
	rowRewards[4].isRewardBonus or
	rowRewards[5].isRewardBonus then
		return true
	else
		return false
	end
end

-- This function is used to match reward tier search terms in the correct language
local function RowContainsTierSearchMatch(searchTerm, rowRewards)

	for i = 1, #rowRewards do
		if (searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_RADIANT) and rowRewards[i].rewardTier == 7) or
		(searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_APEX) and rowRewards[i].rewardTier == 6) or
		(searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_LEGENDARY) and rowRewards[i].rewardTier == 5) or
		(searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_EPIC) and rowRewards[i].rewardTier == 4) or
		(searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_SUPERIOR) and rowRewards[i].rewardTier == 3) or
		(searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_FINE) and rowRewards[i].rewardTier == 2) or
		(searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_COMMON) and rowRewards[i].rewardTier == 1) then
			return true
		end
	end

	return false
end

-- This function is called by CrateHistoryList:RefreshData() after the master list has been built
-- It is also called when the text inside the search box changes
function CrateHistoryList:FilterScrollList()

	-- Get the list and clear it
	local scrollData = ZO_ScrollList_GetDataList(CrateHistoryList.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	-- Look through the master list for rows that contain search matches and insert them
	for i = 1, #CrateHistoryList.masterList do

		local rowData = CrateHistoryList.masterList[i]

		-- If the search matches a reward, include the current row in the filtered list
		if string.find(rowData.crateRewards[1].rewardName:lower(), CrateHistoryList.searchTerm, 1, true) or
		string.find(rowData.crateRewards[2].rewardName:lower(), CrateHistoryList.searchTerm, 1, true) or
		string.find(rowData.crateRewards[3].rewardName:lower(), CrateHistoryList.searchTerm, 1, true) or
		string.find(rowData.crateRewards[4].rewardName:lower(), CrateHistoryList.searchTerm, 1, true) or
		string.find(rowData.crateRewards[5].rewardName:lower(), CrateHistoryList.searchTerm, 1, true) or
		(CrateHistoryList.searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_BONUS) and RowContainsBonusReward(rowData.crateRewards)) or
		RowContainsTierSearchMatch(CrateHistoryList.searchTerm, rowData.crateRewards) then
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, rowData))
		end
	end

	-- If there are rows in the list, but the search returned no results, show the "no matches" label
	if #CrateHistoryList.masterList ~= 0 and #scrollData == 0 then
		CrateTrackerHistoryNoMatch:SetHidden(false)
	else
		CrateTrackerHistoryNoMatch:SetHidden(true)
	end
end

-- This function is called by CrateHistoryList:RefreshData() after the master list has been built and filtered
-- It is also called when the text inside the search box was changed, after the list has been filtered
function CrateHistoryList:SortScrollList()

	-- Sort the list using our sorting function
	table.sort(ZO_ScrollList_GetDataList(CrateHistoryList.list), CrateHistoryList.sortFunction)
end

-- This function is used to set up the non-reward containers in a crate history row
local function SetUpContainer(containerType, rowControl, containerControl, containerChild, childData, tooltipPosition, tooltipText, containerSound)

	-- If the container is a reward container, we don't need to be here
	if containerType == HISTORY_CONTAINER_TYPE_REWARD then
		return
	end

	-- Handle the different container types
	-- A non-reward container should not contain both a texture and a label at the same time
	if containerType == HISTORY_CONTAINER_TYPE_LABEL then
		containerChild.normalColor = ZO_DEFAULT_TEXT
		containerChild:SetText(childData)
	elseif containerType == HISTORY_CONTAINER_TYPE_TEXTURE then
		containerChild:SetTexture(childData)
	else
		return
	end

	-- When the mouse enters this container, hightlight the entire row and show an appropriate tooltip
	containerControl:SetHandler("OnMouseEnter", function() CrateHistoryList:EnterRow(rowControl) ZO_Tooltips_ShowTextTooltip(containerControl, tooltipPosition, tooltipText) end)

	-- when the mouse exits this container, remove the row hightlight and hide the tooltip
	containerControl:SetHandler("OnMouseExit", function() CrateHistoryList:ExitRow(rowControl) ZO_Tooltips_HideTextTooltip() end)

	-- when the mouse clicks this container, play an appropriate sound and trigger NPC chatter
	containerControl:SetHandler("OnMouseDown", function() PlaySound(containerSound) TriggerCrownCrateNPCAnimation(CROWN_CRATE_NPC_ANIMATION_TYPE_IDLE_CHATTER) end)
end

-- This function is only used to set up the reward containers in a crate history row
local function SetUpRewardContainer(containerType, rowControl, containerControl, rewardData, isRewardBonus)

	-- If the container isn't a reward container, we don't need to be here
	if containerType ~= HISTORY_CONTAINER_TYPE_REWARD then
		return
	end

	-- Get the reward controls we need to work on for this container
	local rewardTexture = GetControl(containerControl, "Texture")
	local rewardLabel = GetControl(containerControl, "Quantity")
	local rewardHighlight = GetControl(containerControl, "Highlight")

	-- Highlight this container if it matches the text in the search box
	local shouldHighlight = CrateHistoryList.searchTerm ~= "" and (
	string.find(rewardData.rewardName:lower(), CrateHistoryList.searchTerm, 1, true) or
	(CrateHistoryList.searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_BONUS) and isRewardBonus) or
	(CrateHistoryList.searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_RADIANT) and rewardData.rewardTier == 7) or
	(CrateHistoryList.searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_APEX) and rewardData.rewardTier == 6) or
	(CrateHistoryList.searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_LEGENDARY) and rewardData.rewardTier == 5) or
	(CrateHistoryList.searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_EPIC) and rewardData.rewardTier == 4) or
	(CrateHistoryList.searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_SUPERIOR) and rewardData.rewardTier == 3) or
	(CrateHistoryList.searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_FINE) and rewardData.rewardTier == 2) or
	(CrateHistoryList.searchTerm == GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SEARCH_TERM_COMMON) and rewardData.rewardTier == 1))

	rewardHighlight:SetHidden(not shouldHighlight)

	-- If the reward stack count is 0 or lower, clean up the container because it is empty or invalid
	-- Otherwise, add all of the reward data to this container
	if rewardData.rewardQuantity <= 0 then

		-- Clean up controls that have empty rewards
		rewardTexture:SetTexture("esoui/art/icons/icon_missing.dds")
		rewardTexture:SetHidden(true)
		rewardLabel:SetText("")
		rewardLabel:SetHidden(true)

		-- Only handle the bare minimum for empty containers (row highlight on/off and error click sound)
		containerControl:SetHandler("OnMouseEnter", function() CrateHistoryList:EnterRow(rowControl) end)
		containerControl:SetHandler("OnMouseExit", function() CrateHistoryList:ExitRow(rowControl) end)
		containerControl:SetHandler("OnMouseDown", function() PlaySound(SOUNDS.JUSTICE_PICKPOCKET_FAILED) end)
	else
		-- Add the texture and display it
		rewardTexture:SetTexture(rewardData.rewardTexture)
		rewardTexture:SetHidden(false)

		-- Format the tooltip text and set the label's quantity text
		local rewardTooltipText = string.format("|cFFFFFF%s|r", GetString(SI_CROWN_CRATE_TRACKER_HISTORY_TOOLTIP_INFO))

		-- Set the appropriate color for the item name
		local tierColor
		if (rewardData.rewardTier == 1) then
			tierColor = "|cFFFFFF" -- common white
		elseif (rewardData.rewardTier == 2) then
			tierColor = "|c2DC50E" -- fine green
		elseif (rewardData.rewardTier == 3) then
			tierColor = "|c3A92FF" -- superior blue
		elseif (rewardData.rewardTier == 4) then
			tierColor = "|cA02EF7" -- epic purple
		elseif (rewardData.rewardTier == 5) then
			tierColor = "|cEECA2A" -- legendary yellow
		elseif (rewardData.rewardTier == 6) then
			tierColor = "|cC16403" -- apex orange
		elseif (rewardData.rewardTier == 7) then
			tierColor = "|cEA5C40" -- radiant bright orange
		elseif (rewardData.rewardTier == -1) then
			tierColor = "|cC64343" -- unknown red
		else
			tierColor = ""
		end

		if rewardData.rewardQuantity == 1 then
			rewardTooltipText = string.format("%s%s|r\n%s", tierColor, rewardData.rewardName, rewardTooltipText)
			rewardLabel:SetText("")
			rewardLabel:SetHidden(true)
		else
			rewardTooltipText = string.format("%s%s (%s)|r\n%s", tierColor, rewardData.rewardName, rewardData.rewardQuantity, rewardTooltipText)
			rewardLabel:SetText(rewardData.rewardQuantity)
			rewardLabel:SetHidden(false)
		end

		-- Create a zoom-in animation that will be used when mousing over the container
		local animation, timeline = CreateSimpleAnimation(ANIMATION_SIZE, rewardTexture, 0)
		animation:SetDuration(150)
		animation:SetEasingFunction(ZO_EaseInLinear)
		animation:SetStartAndEndWidth(52, 64)
		animation:SetStartAndEndHeight(52, 64)

		-- When the mouse enters this container, highlight the entire row, play a zoom-in animation on the texture, and show the name tooltip
		local function OnMouseEnterRewardContainer()
			CrateHistoryList:EnterRow(rowControl)
			timeline:PlayForward()
			ZO_Tooltips_ShowTextTooltip(containerControl, TOP, rewardTooltipText)
		end

		-- When the mouse exits this container, remove the row highlight, play a zoom-out animation on the texture, hide the item name and link tooltips, and reset the arrow texture
		local function OnMouseExitRewardContainer()
			CrateHistoryList:ExitRow(rowControl)
			timeline:PlayBackward()
			ZO_Tooltips_HideTextTooltip()
			ClearTooltip(ItemTooltip)
		end

		-- When the mouse clicks this container, anchor the arrow texture to the link tooltip, replace the name tooltip with the link tooltip, and play a sound
		local function OnMouseDownRewardContainer()
			CrateTrackerHistoryTooltipArrow:SetAnchor(CENTER, containerControl, LEFT, -3, 0)
			CrateTrackerHistoryTooltipArrow:SetParent(ItemTooltip)
			CrateTrackerHistoryTooltipArrow:SetHidden(false)

			ZO_Tooltips_HideTextTooltip()

			InitializeTooltip(ItemTooltip, containerControl, RIGHT, -5, 0, LEFT)
			ItemTooltip:SetLink(rewardData.rewardLink)

			PlaySound(SOUNDS.CROWN_CRATES_CARD_FLIPPING)
		end

		-- Set all of the handlers for this container
		containerControl:SetHandler("OnMouseEnter", OnMouseEnterRewardContainer)
		containerControl:SetHandler("OnMouseExit", OnMouseExitRewardContainer)
		containerControl:SetHandler("OnMouseDown", OnMouseDownRewardContainer)
	end
end

-- This function is called after everything is done and we're ready to display all the rows
function CrateHistoryList:SetupHistoryRow(rowControl, crateData)

	-- Get all the non-reward controls we need to work on for this row
	local numberContainer = GetControl(rowControl, "NumberContainer")
	local numberLabel = GetControl(rowControl, "NumberLabel")
	local numberText = crateData.crateNumber
	local numberSound = SOUNDS.CROWN_CRATES_GEM_WOBBLE
	local numberTooltipText

	local crateContainer = GetControl(rowControl, "CrateContainer")
	local crateTexture = GetControl(rowControl, "CrateTexture")
	local crateIcon = GetCrownCrateIcon(crateData.crateType)
	local crateSound = SOUNDS.CROWN_CRATES_MANIFEST_CHOSEN
	local crateTooltipText = zo_strformat("<<t:1>>", GetCrownCrateName(crateData.crateType))

	local statusContainer = GetControl(rowControl, "StatusContainer")
	local statusTexture = GetControl(rowControl, "StatusTexture")
	local statusIcon
	local statusSound = SOUNDS.CROWN_CRATES_CARD_SELECTED
	local statusTooltipText = string.format("|cFFFFFF%s|r", GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SUBMIT_INFO))

	-- Crate number formatting
	local currentTime = GetTimeStamp()
	local date, time = FormatAchievementLinkTimestamp(crateData.crateTimestamp)
	local daysAgo = math.floor((currentTime - crateData.crateTimestamp) / ZO_ONE_DAY_IN_SECONDS)
	local daysAgoFormatted
	if daysAgo <= 0 then
		daysAgoFormatted = string.format("%s %s", GetString(SI_CROWN_CRATE_TRACKER_HISTORY_TOOLTIP_DAYS), GetString(SI_CROWN_CRATE_TRACKER_HISTORY_TOOLTIP_TODAY))
	else
		daysAgoFormatted = string.format("%s %s", GetString(SI_CROWN_CRATE_TRACKER_HISTORY_TOOLTIP_DAYS), daysAgo)
	end
	numberTooltipText = string.format("%s\n|cFFFFFF%s %s %s\n%s|r", GetString(SI_CROWN_CRATE_TRACKER_HISTORY_TOOLTIP_TIMESTAMP_1), date, GetString(SI_CROWN_CRATE_TRACKER_HISTORY_TOOLTIP_TIMESTAMP_2), time, daysAgoFormatted)

	-- Crate status formatting
	if crateData.crateStatus == "Submitted" then
		statusIcon = "esoui/art/hud/gamepad/gp_radialicon_accept_down.dds"
		statusTooltipText = string.format("%s\n%s", GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SUBMITTED_YES), statusTooltipText)
	else
		statusIcon = "esoui/art/hud/gamepad/gp_radialicon_cancel_down.dds"
		statusTooltipText = string.format("|cC64343%s|r\n%s", GetString(SI_CROWN_CRATE_TRACKER_HISTORY_SUBMITTED_NO), statusTooltipText)
	end

	-- Set up all the non-reward containers for this row
	SetUpContainer(HISTORY_CONTAINER_TYPE_LABEL, rowControl, numberContainer, numberLabel, numberText, LEFT, numberTooltipText, numberSound)
	SetUpContainer(HISTORY_CONTAINER_TYPE_TEXTURE, rowControl, crateContainer, crateTexture, crateIcon, TOP, crateTooltipText, crateSound)
	-- Disabled SetUpContainer(HISTORY_CONTAINER_TYPE_TEXTURE, rowControl, statusContainer, statusTexture, statusIcon, LEFT, statusTooltipText, statusSound)

	-- Set up all the reward containers for this row
	-- Note: We use CrownCrateTracker.MAX_REWARDS_SUPPORTED instead of MAX_CROWN_CRATE_REWARD_SLOTS in case ZOS decides to increase the cap
	for i = 1, CrownCrateTracker.MAX_REWARDS_SUPPORTED do
		local currentReward = string.format("Reward%s", i)
		local rewardContainer = GetControl(rowControl, currentReward)
		local rewardData = crateData.crateRewards[i]
		local isRewardBonus = crateData.crateRewards[i].isRewardBonus

		SetUpRewardContainer(HISTORY_CONTAINER_TYPE_REWARD, rowControl, rewardContainer, rewardData, isRewardBonus)
	end

	-- Finalize the row
	ZO_SortFilterList.SetupRow(CrateHistoryList, rowControl, crateData)
end