-- ***** FavoriteMount *****

-- TODO item - Remove global saved variables - noted at version 2.00.  Updatecount: 0
-- TODO multimount keybind - check if tempDisable is active




-- Initialize addon variables
--------------------------------------------------
FavoriteMount = {}
FavoriteMount.debug = false
if FavoriteMount.debug then d("FavoriteMount: Initialize addon variables") end
FavoriteMount.version = "2.06 (2026-04-10)"
FavoriteMount.name = "FavoriteMount"
FavoriteMount.displayName = "|c00E600Favorite Mount|r"
FavoriteMount.author = "|c787878ShadowMau / Pawprints.Shadow|r"
FavoriteMount.website = "https://www.esoui.com/downloads/info2915-FavoriteMount.html"
FavoriteMount.donation = "https://www.paypal.com/donate/?hosted_button_id=3MACYMHKL9Q4J"
FavoriteMount.global_typeMount = COLLECTIBLE_CATEGORY_TYPE_MOUNT	-- ZOS Global
FavoriteMount.unlockedMultiMountList = {}
FavoriteMount.tempDisable = false

ZO_CreateStringId("SI_BINDING_NAME_FM_TOGGLE_ONLY_MULTIMOUNT", "Toggle Multimount Only")

--------------------------------------------------
-- Default saved variable settings
--------------------------------------------------
if FavoriteMount.debug then d("Load default settings") end
-- TODO we will remove this after a few versions because this is no longer needed
FavoriteMount.globalDefaults = {}	-- depreciated remove later
FavoriteMount.characterDefaults = {
	onlyMultiMount = false,
	favoriteMountsList = {},
	
}

--------------------------------------------------
-- *** OnAddOnLoaded - Check to see if this addon is the one loaded
--------------------------------------------------
function FavoriteMount.OnAddOnLoaded(event, addonName)
	if addonName == FavoriteMount.name then
		if FavoriteMount.debug then d("FavoriteMount: Addon Loaded") end
		
		FavoriteMount.Startup()
		FavoriteMount.CreateSettingsMenu()
		EVENT_MANAGER:UnregisterForEvent(FavoriteMount.name, EVENT_ADD_ON_LOADED)
	end
end


EVENT_MANAGER:RegisterForEvent(FavoriteMount.name, EVENT_ADD_ON_LOADED, FavoriteMount.OnAddOnLoaded)

--------------------------------------------------
-- *** Startup - Initialize settings, load saved variables and register event triggers.
--------------------------------------------------
function FavoriteMount.Startup()
	if FavoriteMount.debug then d("FavoriteMount: Startup") end
	
	-- TODO I am currently loading the account-wide variables in order to clear them out
	-- the addon was re-writtent to no longer need them saved.  In a few versions we will eliminate this call
	FavoriteMount.GSV = ZO_SavedVars:NewAccountWide("FavoriteMountSavedVariables", 2, nil, FavoriteMount.globalDefaults)
	FavoriteMount.GSV = {}
	
	FavoriteMount.CSV = ZO_SavedVars:NewCharacterIdSettings("FavoriteMountSavedVariables", 1, nil, FavoriteMount.characterDefaults)
	
	FavoriteMount.CreateUnlockedMountsList() -- called to make a list of unlocked multimounts
	EVENT_MANAGER:RegisterForEvent(FavoriteMount.name, EVENT_MOUNTED_STATE_CHANGED, FavoriteMount.SwitchMount)
	
end


--------------------------------------------------
-- *** SwitchMount - Randomly set a mount as active when the player dismounts
--------------------------------------------------
function FavoriteMount.SwitchMount(eventid, mounted)
	if FavoriteMount.debug then
		d("FavoriteMount: SwitchMount") 
		if mounted then d("Character Mounted") else d("Character Not Mounted") end
	end
	
	if (not mounted) and (not FavoriteMount.tempDisable) then
		
		local mountList = FavoriteMount.CSV.favoriteMountsList
		local multiMountList = FavoriteMount.unlockedMultiMountList
		local activeMount = GetActiveCollectibleByType(FavoriteMount.global_typeMount)
		local newMount = activeMount
		
		if FavoriteMount.debug then d("OnlyMultiMount CSV = ", FavoriteMount.CSV.onlyMultiMount) end
		
		if 	FavoriteMount.CSV.onlyMultiMount then
			if #multiMountList == 1 then
				newMount = multiMountList[1]
			elseif #multiMountList > 1 then
				while activeMount == newMount do
					newMount = multiMountList[math.random(#multiMountList)]
				end
			end		
		else	
			if mountList == nil then newMount = activeMount 
			
			elseif #mountList == 1 then newMount = mountList[1] 
			
			elseif #mountList > 1 then 
				while activeMount == newMount do
					newMount = mountList[math.random(#mountList)]
				end
			end
		
		end
		
		if FavoriteMount.debug then d("active mount: "..activeMount.." - new mount: "..newMount) end
		-- quickly check if the user quickly remounted.  IsMounted is a zos function
		-- if newMount is equal to the activeMount at this point, there is no switch to be made
		if newMount ~= activeMount then
			zo_callLater(function() FavoriteMount.FireSwich(newMount, 0) end, 1500)
		end
		
	end
end


--------------------------------------------------
-- *** FireSwich - Make up to 5 attempts to activate the new mount
--------------------------------------------------
function FavoriteMount.FireSwich(newMount, attemptNumber)
	if FavoriteMount.debug then d("FavoriteMount: FireSwich newMount: "..newMount.." Attempt: "..attemptNumber) end
	
	if attemptNumber < 5 then
		if not IsCollectibleActive(newMount) then
			if not IsMounted() then
				UseCollectible(newMount, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
				attemptNumber = attemptNumber + 1
				zo_callLater(function() FavoriteMount.FireSwich(newMount, attemptNumber) end, (500 * attemptNumber))
			end
		end
	end
end


--------------------------------------------------
-- *** CreateUnlockedMountsList - Create a new copy of available mounts
--------------------------------------------------	
function FavoriteMount.CreateUnlockedMountsList()
	if FavoriteMount.debug then d("FavoriteMount: CreateUnlockedMountsList") end
	
	local mounts = {}
	-- local multiMounts = {}
	local mountCounter = 0
	local muliMountCounter = 0
	local totalUnlockedMounts = GetTotalUnlockedCollectiblesByCategoryType(FavoriteMount.global_typeMount)
	
	if totalUnlockedMounts > 0 then
		for counter = 1, GetTotalCollectiblesByCategoryType(FavoriteMount.global_typeMount) do
			local collectibleID = GetCollectibleIdFromType(FavoriteMount.global_typeMount, counter)
			local name, description, unlockedTexture, lockedTexture, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(collectibleID)
			local mountNameClean = ZO_CachedStrFormat(SI_UNIT_NAME, name)
			
			if unlocked then
				if hint ~= "" and string.find(hint, "Multi%-Rider") then
					muliMountCounter = muliMountCounter + 1
					mountCounter = mountCounter + 1
					FavoriteMount.unlockedMultiMountList[muliMountCounter] = collectibleID
					mounts[mountCounter] = {mountNameClean.." |t32:32:EsoUI/Art/Tutorial/radialIcon_joinMount_over.dds|t", collectibleID, unlockedTexture}
				else
					mountCounter = mountCounter + 1
					mounts[mountCounter] = {mountNameClean, collectibleID,unlockedTexture}
				end
			end
		end
		-- table.sort (multiMounts, function(a,b) return a[1] < b[1] end)
		table.sort (mounts, function(a,b) return a[1] < b[1] end)
	end
	
	-- FavoriteMount.CSV.unlockedMultiMountList = multiMounts -- We will only use this list if the user select use only multiMounts
	
	return mounts
	
end


--------------------------------------------------
-- *** CheckIfFavorite - Sort through the list of mounts
--------------------------------------------------	
function FavoriteMount.CheckIfFavorite(mount)
	-- if FavoriteMount.debug then d("FavoriteMount: CheckIfFavorite") d("MountID: "..mount)end
	
	local list = FavoriteMount.CSV.favoriteMountsList
	local found = false
	
	if list then
		for count = 1, #list do
			if mount == list[count] then found = true break end
		end
	end
	
	-- if FavoriteMount.debug then d("Found: ") if found then d("true") else d("false") end end
	
	return found
end


--------------------------------------------------
-- *** SortMounts - Sort through the list of mounts
--------------------------------------------------	
function FavoriteMount.SortMounts()
	if FavoriteMount.debug then d("FavoriteMount: SortMounts") end
	
	local availableMountName = {}
	local availableMountID = {}
	local availableMountTooltip = {}
	local favoriteMountName = {}
	local favoriteMountID = {}
	local favoriteMountTooltip = {}
	
	
	
	for key, value in ipairs(FavoriteMount.CreateUnlockedMountsList()) do
		-- CreateUnlockedMountsList returns in the format of {name, id, tooltip}
		local found = FavoriteMount.CheckIfFavorite(value[2])
		if found then
			table.insert (favoriteMountName, value[1])
			table.insert (favoriteMountID, value[2])
			table.insert (favoriteMountTooltip, "|t600%:600%:"..value[3].."|t")
		else
			table.insert (availableMountName, value[1])
			table.insert (availableMountID, value [2])
			table.insert (availableMountTooltip, "|t600%:600%:"..value[3].."|t")
		end
	end
	-- return availableMountName, availableMountID, availableMountTooltip, favoriteMountName, favoriteMountID, favoriteMountTooltip
	
	AvailableMounts:UpdateChoices(availableMountName, availableMountID, availableMountTooltip)
	FavoriteMounts:UpdateChoices(favoriteMountName, favoriteMountID, favoriteMountTooltip)
end


--------------------------------------------------
-- *** SetOnlyMultimount - toggle the option to only use multimounts
--------------------------------------------------	
function FavoriteMount.SetOnlyMultimount(toggle, hotkey)
	if FavoriteMount.debug then 
		d("FavoriteMount: SetOnlyMultimount") 
		if toggle then d("Multimount: true") else d("Multimount: false") end
	end
	
	if (not FavoriteMount.tempDisable) then
		FavoriteMount.CSV.onlyMultiMount = toggle
		FavoriteMount.CreateUnlockedMountsList() -- called to make a list of unlocked multimounts
		-- artificially triget a mount switch in case they turned on using multimounts
		FavoriteMount.SwitchMount(0, false)
		
		if hotkey then
			PlaySound(SOUNDS.ARMORY_OPEN)
			if toggle then CHAT_ROUTER:AddSystemMessage("FavoriteMount: Start Using Multimount Only") else CHAT_ROUTER:AddSystemMessage("FavoriteMount: Stop Using Multimount Only") end
		end
	else
		PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
		CHAT_ROUTER:AddSystemMessage("FavoriteMount is temporarily disabled")
	end

end


--------------------------------------------------
-- *** ToggleMount - toggle the mount into favorite or available
--------------------------------------------------	
function FavoriteMount.ToggleMount(toggle, id)
	if FavoriteMount.debug then d("FavoriteMount: ToggleMount - MountID: "..id.." toggle: ") end
	
	if toggle then
		if FavoriteMount.debug then d("Add: "..id) end
		table.insert(FavoriteMount.CSV.favoriteMountsList, id)
	else
		for key, value in ipairs(FavoriteMount.CSV.favoriteMountsList) do
			if FavoriteMount.debug then d("Remove Key: "..key.."Value= "..value) end
			if value == id then
				table.remove(FavoriteMount.CSV.favoriteMountsList, key)
				if FavoriteMount.debug then d("REMOVED: ".. key) end
				break
			end
		end
	end
	
	FavoriteMount.SortMounts()
	
	-- local availableMountName, availableMountID, availableMountTooltip, favoriteMountName, favoriteMountID, favoriteMountTooltip = FavoriteMount.SortMounts()
	
	-- AvailableMounts:UpdateChoices(availableMountName, availableMountID, availableMountTooltip)
	-- FavoriteMounts:UpdateChoices(favoriteMountName, favoriteMountID, favoriteMountTooltip)
end




--------------------
-- ***** Settings *****
--------------------



--------------------
-- *** CreateSettingsMenu - Create the in-game settings menu
--------------------
function FavoriteMount.CreateSettingsMenu()
	if FavoriteMount.debug then d("FavoriteMount: CreateSettingsMenu") end
	
	local LAM = LibAddonMenu2
	local panelName = "FavoriteMountSettingsPanel"
	
	local panelData = {		-- Table that defines the libaddonmenu2 menu panel
		type = "panel",
		name = "Favorite Mount",
		registerForRefresh = true,
		displayName = FavoriteMount.displayName,
		author = FavoriteMount.author,
		website = FavoriteMount.website,
		version = FavoriteMount.version,
		donation = FavoriteMount.donation
	}
	
	local optionsData = {}	-- The table that holds all of the libaddonmenu2 menu options
	local tempTable = {} 	-- The reuseable temporary table to bulid the optionsData table
	
	--------------------------------------------------
	-- Create a placeholders.  Actual values will be calculated when the menu is open
	--	through RegisterCallback("LAM-PanelOpened")
	--------------------------------------------------	
	local availableMountName = {"placeholder"}
	local availableMountID = {1}
	local availableMountTooltip = {"placeholder"}
	local favoriteMountName = {"placeholder"}
	local favoriteMountID = {1}
	local favoriteMountTooltip = {"placeholder"}
	
	local am = GetAddOnManager()
	for i = 1, am:GetNumAddOns() do
		local name, _, _,_,_,status = am:GetAddOnInfo(i)
		
		if ((name == "LibAddonMenu-2.0") and (status == ADDON_STATE_ENABLED)) then
			if (am:GetAddOnVersion(i) < 40) then
				tempTable = { -- description
					type = "description",
					title = "|cEE4B2BWARNING: OUTDATED LIBADDONMENU2 VERSION DETECTED.\n\n  This may cause unexpected errors or results when using the settings menu. Reloadui may fix the problem.  Otherwise you will have to check your addon's directory on your computer to find where the outdated LibAddonMenu2 is being loaded.\n\nSee the ESOUI page on LibAddonMenu2 (https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html) for instructions.\n\nOr you can try the automated tool called Delete LibStub and Embedded libraries found here (https://www.esoui.com/downloads/info4197-DeleteLibStubandEmbeddedlibraries.html)\n\nYou can also try turning off all other addons expect this one and LibAddonMenu2.  Make your changes.  Then turn your other addons back on.\n\nUSING THE MENU WITH OUTDATED LIBADDONMENU2 MAY RESULT IN CORRUPTED VARIABLES OR OTHER ERRORS|r",
					width = "full"
				}
				table.insert(optionsData, tempTable)

			end
		end
	end
	
	-- FavoriteMount.SortMounts()
	
	if GetUnitDisplayName('player') == "@pawprints.shadow" then
		tempTable = {
			type = "checkbox",
			name = "Turn on Debug: ",
			getFunc = function() return FavoriteMount.debug end,
			setFunc = function() FavoriteMount.debug = not FavoriteMount.debug end,
		}
		table.insert(optionsData, tempTable)
	end
	
	tempTable = {
		type = "checkbox",
		name = "Temporarily Disable: ",
		getFunc = function() return FavoriteMount.tempDisable end,
		setFunc = function() FavoriteMount.tempDisable = not FavoriteMount.tempDisable end
	}
	table.insert(optionsData, tempTable)
	
	--------------------------------------------------
	-- Use only multimounts
	--------------------------------------------------	
	if #FavoriteMount.unlockedMultiMountList > 0 then
		tempTable = {
			type = "checkbox",
			name = "Use only multimounts: ",
			getFunc = function() return FavoriteMount.CSV.onlyMultiMount end,
			setFunc = function(value) FavoriteMount.SetOnlyMultimount(value) end
		}
		table.insert(optionsData, tempTable)
	end
	
	--------------------------------------------------
	-- List of available mounts
	--------------------------------------------------	
	tempTable = {
		type = "dropdown",
		name = "Available Mounts",
		width = "half",
		scrollable = true,
		reference = "AvailableMounts",
		getFunc = function () return end,
		setFunc = function(mountID) if FavoriteMount.debug then d("Selected Value: "..mountID) end FavoriteMount.ToggleMount(true, mountID) end,
		choices = availableMountName,
		choicesValues = availableMountID,
		choicesTooltips = availableMountTooltip
	}
	table.insert(optionsData, tempTable)
	
	--------------------------------------------------
	-- List of favorite mounts
	--------------------------------------------------	
	tempTable = {
		type = "dropdown",
		name = "Favorite Mounts",
		width = "half",
		scrollable = true,
		reference = "FavoriteMounts",
		getFunc = function() return end,
		setFunc = function(mountID) if FavoriteMount.debug then d("Selected Value: "..mountID) end FavoriteMount.ToggleMount(false, mountID) end,
		choices = favoriteMountName,
		choicesValues = favoriteMountID,
		choicesTooltips = favoriteMountTooltip
	}
	table.insert(optionsData, tempTable)
	
	--[[
	--------------------------------------------------
	-- Test of a search box
	--------------------------------------------------	
	tempTable = {
		type = "editbox",
		name = "Test Search Box",
		getFunc = function()end,
		setFunc = function() d("tried to do stuff")end,
		tooltip = "This is a test search box",
		width = "full",
		
	}
	table.insert(optionsData, tempTable)
	--]]
	
	local myPanel = LAM:RegisterAddonPanel(panelName, panelData)
	LAM:RegisterOptionControls(panelName, optionsData)
	
	-- FavoriteMount.SortMounts()
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel) if panel ~= myPanel then return end CHAT_ROUTER:AddSystemMessage("My Settings Panel Callback Fired") FavoriteMount.SortMounts()end)
end
