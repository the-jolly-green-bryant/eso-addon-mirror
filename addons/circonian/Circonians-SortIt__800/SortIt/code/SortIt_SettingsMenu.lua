
local LAM2 = LibStub("LibAddonMenu-2.0")
local LIBSI = LibStub:GetLibrary("LibSortIt-1.0")

----------------------------------------------------------
--  Colors  --
----------------------------------------------------------
local colorRed 			= "|cFF0000" 	-- Red
local colorYellow 		= "|cFFFF00" 	-- yellow 
local colorGreen 		= "|c00FF00" 	-- green

----------------------------------------------------------
--  Default Saved Variables  --
----------------------------------------------------------
SortIt.PlayerDefaults = {
	sortPacks = {},
	curPackName = {
		[INVENTORY_BACKPACK]	 = "Item Equip Quality",
		[INVENTORY_BANK] 		= "Item Equip Quality",
		[INVENTORY_GUILD_BANK] 	= "Item Equip Quality",
	},
	["NUM_SORTS"] 			= 3,
	["1ST_SORTKEY"] 		= "Item Type",
	["1ST_SORTKEY_ORDER"] 	= true,
	["2ND_SORTKEY"] 		= "Equip Type",
	["2ND_SORTKEY_ORDER"] 	= true,
	["3RD_SORTKEY"] 		= "Quality",
	["3RD_SORTKEY_ORDER"] 	= true,
	["4TH_SORTKEY"] 		= "Name",
	["4TH_SORTKEY_ORDER"] 	= true,
	["5TH_SORTKEY"] 		= "Name",
	["5TH_SORTKEY_ORDER"] 	= true,
	["6TH_SORTKEY"] 		= "Name",
	["6TH_SORTKEY_ORDER"] 	= true,
	["7TH_SORTKEY"] 		= "Name",
	["7TH_SORTKEY_ORDER"] 	= true,
	["8TH_SORTKEY"] 		= "Name",
	["8TH_SORTKEY_ORDER"] 	= true,
	["9TH_SORTKEY"] 		= "Name",
	["9TH_SORTKEY_ORDER"] 	= true,
	["10TH_SORTKEY"] 		= "Name",
	["10TH_SORTKEY_ORDER"] 	= true,
	["11TH_SORTKEY"] 		= "Name",
	["11TH_SORTKEY_ORDER"] 	= true,
	["12TH_SORTKEY"] 		= "Name",
	["12TH_SORTKEY_ORDER"] 	= true,
}

----------------------------------------------------------
----------------------------------------------------------



-- Get a boolean value for the Asc control
-- True = ON,  False = OFF
local function GetAscBool(_Control)
	local sAscText = _Control.checkbox:GetText()
	local sCheckedText = _Control.checkedText
	
	if sAscText == sCheckedText then
		return true
	end
	return false
end
-- Grab all of the data from the options controls
local function GetNewSortData()
	local tPartialSortTable = {
		[1] = {displayName = SORTIT_1ST_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_1ST_SORT_ORDER)},
		[2] = {displayName = SORTIT_2ND_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_2ND_SORT_ORDER)},
		[3] = {displayName = SORTIT_3RD_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_3RD_SORT_ORDER)},
		[4] = {displayName = SORTIT_4TH_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_4TH_SORT_ORDER)},
		[5] = {displayName = SORTIT_5TH_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_5TH_SORT_ORDER)},
		[6] = {displayName = SORTIT_6TH_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_6TH_SORT_ORDER)},
		[7] = {displayName = SORTIT_7TH_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_7TH_SORT_ORDER)},
		[8] = {displayName = SORTIT_8TH_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_8TH_SORT_ORDER)},
		[9] = {displayName = SORTIT_9TH_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_9TH_SORT_ORDER)},
		[10] = {displayName = SORTIT_10TH_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_10TH_SORT_ORDER)},
		[11] = {displayName = SORTIT_11TH_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_11TH_SORT_ORDER)},
		[12] = {displayName = SORTIT_12TH_SORT.dropdown:GetSelectedItem(), Asc = GetAscBool(SORTIT_12TH_SORT_ORDER)},
	}
	return tPartialSortTable
end

local function RemoveSortPackFromSavedVars(_sDisplayName)
	for k,v in ipairs(SortIt.SavedVariables.sortPacks) do
		if v.displayName == _sDisplayName then
			table.remove(SortIt.SavedVariables.sortPacks, k)
		end
	end
end
local function RemoveAccountSort(_sDisplayName)
	LIBSI:RemoveSortPack(SortIt.name, _sDisplayName)
	RemoveSortPackFromSavedVars(_sDisplayName)
	SORTIT_SORTPACK_DROPDOWN_REMOVE:UpdateChoices(LIBSI:GetAllSortPackDisplayNames(SortIt.name))
end

local function AddCharSort(_sPackDisplayName)
	if _sPackDisplayName == "" then
		SortIt.ShowErrorDialog("BAD NAME", "You must enter a name for your sort package.")
		return
	end
	if LIBSI:DoesSortPackNameExist(SortIt.name, _sPackDisplayName) then
		SortIt.ShowErrorDialog("BAD NAME", "Sort Pack name already in use. Sort Pack names must be unique.")
		return
	end
	-- This must stay ZO_SORT_ORDER_UP to keep the Asc booleans/reversetiebreakerOrder working correctly
	local bCurrentOrder = ZO_SORT_ORDER_UP
	local tPartialSortTable = GetNewSortData()
	
	local tNewPack = {
		[1] = {
			displayName = _sPackDisplayName,
			sortKeys = {},
		},
	}
	local iNumSorts = tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem())
	for i = 1, iNumSorts do
		local KeyDisplayName = tPartialSortTable[i].displayName
		local KeyName = LIBSI:GetSortKeyNameFromDisplayName(SortIt.name, tPartialSortTable[i].displayName)
		local bAsc = tPartialSortTable[i].Asc
		
		tNewPack[1].sortKeys[i] = {key = KeyName, Asc = bAsc}
	end
	
	table.insert(SortIt.SavedVariables.sortPacks, tNewPack[1])
	
	LIBSI:CreateSortPacks(SortIt.name, tNewPack)
	SORTIT_SORTPACK_DROPDOWN_REMOVE:UpdateChoices(LIBSI:GetAllSortPackDisplayNames(SortIt.name))
end

local function IsControlDisabled(_SortNumber)
	
end
----------------------------------------------------------
--******************************************************--
----------------------------------------------------------
--  Create Menu --
----------------------------------------------------------
--******************************************************--
function SortIt.CreateSettingsMenu()
	local panelData = {
		type = "panel",
		name = SortIt.name,
		displayName = "|cFF0000 Circonians |c00FFFF SortIt",
		author = "Circonian",
		version = SortIt.realVersion,
		slashCommand = "/sortit",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("SortIt_Options", panelData)
	
	local optionsData = {
		[1] = {
			type = "submenu",
			name = "Tips on Sort Keys",
			tooltip = "Just a few tips about how some of the sort Keys work.",
			controls = {
				[1] = {
					type = "description",
					text = colorYellow.."When choosing a boolean filter (something that is either true or false), like is the item  Armor, Light Armor, 1h Mace, ect... Setting the sort order Ascending to OFF will put it at the top of the list, ON will put it at the bottom of the list \'for that sort\'.",
				},
				[2] = {
					type = "description",
					text = colorYellow.."Some filters, like Item Type, Equip Type, Crafting Mat Type, ect... are numeric values based on in game code, just experiment to see which direction Ascending ON/OFF sorts it.",
				},
				[3] = {
					type = "description",
					text = colorYellow.."Crafting Mat Type ONLY refers to crafting \'materials\'. So the Crafting Mat Type sort key will group all crafting \'materials\' together & sort them by the games built in numerical value for each items crafting type.",
				},
				[4] = {
					type = "description",
					text = colorYellow.."After everything is sorted by the chosen sort keys if there is still a tie in determining sort order the items name is used as the tiebreaker to decide which item should appear first.",
				},
			},
		},
		[2] = {
			type = "description",
			text = colorRed.."You can not edit sort packages at this time. Just delete the one you dont want and create a new one.",
		},
		[3] = {
			type = "description",
			text = colorYellow.."Select a Sort Package to delete.",
		},
		[4] = {
			type = "dropdown",
			name = "Sort Packages",
			tooltip = "Pick a Sort Package to delete.",
			width = "half",
			choices = LIBSI:GetAllSortPackDisplayNames(SortIt.name),
			sort = "name-up",
			getFunc = function() return end,
			setFunc = function(iValue) 
				--LIBSI:ChangeSortByPackDisplayName(SortIt.name, iValue, INVENTORY_BANK, ZO_SORT_ORDER_UP)
				end,
			reference = "SORTIT_SORTPACK_DROPDOWN_REMOVE",
		},
		[5] = {
			type = "button",
			name = "Delete Sort Package",
			tooltip = "Deletes the currently selected sort package.",
			width = "half",
			func = function() RemoveAccountSort(SORTIT_SORTPACK_DROPDOWN_REMOVE.dropdown:GetSelectedItem()) end,
		},
		
		[6] = {
			type = "header",
		},
		[7] = {
			type = "description",
			text = colorYellow.."Select the number of sort keys you wish to use. Then select your sort keys, sort orders, & then choose a name, and click Create Sort Pack.",
		},
				
		[8] = {
			type = "editbox",
			name = "Sort Package Name",
			tooltip = "Pick a Name for this Sort Package.",
			width = "half",
			getFunc = function() return SORTIT_EDITBOX_SORTPACKAGE_NAME.editbox:GetText() end,
			setFunc = function(text) SORTIT_EDITBOX_SORTPACKAGE_NAME.editbox:SetText(text) end,
			reference = "SORTIT_EDITBOX_SORTPACKAGE_NAME",
		},
		[9] = {
			type = "button",
			name = "Create Sort Package",
			tooltip = "Creates a Sort Package with the options listed below.",
			width = "half",
			func = function() AddCharSort(SORTIT_EDITBOX_SORTPACKAGE_NAME.editbox:GetText()) 
				end,
		},
		
		
		
		------------------------------------------------------------------------------------
		-----------------  	    Start Option Controls    		  	------------------------
		------------------------------------------------------------------------------------
		
		[10] = {
			type = "dropdown",
			name = "Number of Sorts",
			tooltip = "Choose the number of Sort Keys to use.",
			width = "full",
			choices = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
			default = 3,
			sort = "name-up",
			getFunc = function() return SortIt.SavedVariables["NUM_SORTS"] end,
			setFunc = function(iValue) SortIt.SavedVariables["NUM_SORTS"] = iValue
			end,
			reference = "SORTIT_NUM_SORTS",
		},
		
		[11] = {
			type = "dropdown",
			name = "1st Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			getFunc = function() return SortIt.SavedVariables["1ST_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["1ST_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_1ST_SORT",
		},
		[12] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			getFunc = function() return SortIt.SavedVariables["1ST_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["1ST_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_1ST_SORT_ORDER",
		},
		[13] = {
			type = "dropdown",
			name = "2nd Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 2) end,
			getFunc = function() return SortIt.SavedVariables["2ND_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["2ND_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_2ND_SORT",
		},
		[14] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 2) end,
			getFunc = function() return SortIt.SavedVariables["2ND_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["2ND_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_2ND_SORT_ORDER",
		},
		[15] = {
			type = "dropdown",
			name = "3rd Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 3) end,
			getFunc = function() return SortIt.SavedVariables["3RD_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["3RD_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_3RD_SORT",
		},
		[16] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 3) end,
			getFunc = function() return SortIt.SavedVariables["3RD_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["3RD_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_3RD_SORT_ORDER",
		},
		[17] = {
			type = "dropdown",
			name = "4th Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 4) end,
			getFunc = function() return SortIt.SavedVariables["4TH_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["4TH_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_4TH_SORT",
		},
		[18] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 4) end,
			getFunc = function() return SortIt.SavedVariables["4TH_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["4TH_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_4TH_SORT_ORDER",
		},
		[19] = {
			type = "dropdown",
			name = "5th Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 5) end,
			getFunc = function() return SortIt.SavedVariables["5TH_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["5TH_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_5TH_SORT",
		},
		[20] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 5) end,
			getFunc = function() return SortIt.SavedVariables["5TH_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["5TH_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_5TH_SORT_ORDER",
		},
		[21] = {
			type = "dropdown",
			name = "6th Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 6) end,
			getFunc = function() return SortIt.SavedVariables["6TH_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["6TH_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_6TH_SORT",
		},
		[22] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 6) end,
			getFunc = function() return SortIt.SavedVariables["6TH_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["6TH_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_6TH_SORT_ORDER",
		},
		[23] = {
			type = "dropdown",
			name = "7th Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 7) end,
			getFunc = function() return SortIt.SavedVariables["7TH_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["7TH_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_7TH_SORT",
		},
		[24] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 7) end,
			getFunc = function() return SortIt.SavedVariables["7TH_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["7TH_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_7TH_SORT_ORDER",
		},
		[25] = {
			type = "dropdown",
			name = "8th Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 8) end,
			getFunc = function() return SortIt.SavedVariables["8TH_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["8TH_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_8TH_SORT",
		},
		[26] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 8) end,
			getFunc = function() return SortIt.SavedVariables["8TH_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["8TH_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_8TH_SORT_ORDER",
		},
		[27] = {
			type = "dropdown",
			name = "9th Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 9) end,
			getFunc = function() return SortIt.SavedVariables["9TH_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["9TH_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_9TH_SORT",
		},
		[28] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 9) end,
			getFunc = function() return SortIt.SavedVariables["9TH_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["9TH_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_9TH_SORT_ORDER",
		},
		
		
		
		[29] = {
			type = "dropdown",
			name = "10th Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 10) end,
			getFunc = function() return SortIt.SavedVariables["10TH_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["10TH_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_10TH_SORT",
		},
		[30] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 10) end,
			getFunc = function() return SortIt.SavedVariables["10TH_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["10TH_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_10TH_SORT_ORDER",
		},
		[31] = {
			type = "dropdown",
			name = "11th Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 11) end,
			getFunc = function() return SortIt.SavedVariables["11TH_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["11TH_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_11TH_SORT",
		},
		[32] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 11) end,
			getFunc = function() return SortIt.SavedVariables["11TH_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["11TH_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_11TH_SORT_ORDER",
		},
		[33] = {
			type = "dropdown",
			name = "12th Sort",
			width = "half",
			choices = LIBSI:GetAllSortKeyDisplayNames(SortIt.name),
			sort = "name-up",
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 12) end,
			getFunc = function() return SortIt.SavedVariables["12TH_SORTKEY"] end,
			setFunc = function(iValue) SortIt.SavedVariables["12TH_SORTKEY"] = iValue 
			end,
			reference = "SORTIT_12TH_SORT",
		},
		[34] = {
			type = "checkbox",
			name = "Ascending Order",
			tooltip = "ON for Ascending or OFF for Descending",
			width = "half",
			default = true,
			disabled = function() return (tonumber(SORTIT_NUM_SORTS.dropdown:GetSelectedItem()) < 12) end,
			getFunc = function() return SortIt.SavedVariables["12TH_SORTKEY_ORDER"] end,
			setFunc = function(iValue) SortIt.SavedVariables["12TH_SORTKEY_ORDER"] = iValue end,
			reference = "SORTIT_12TH_SORT_ORDER",
		},
	}

	LAM2:RegisterOptionControls("SortIt_Options", optionsData)
end





--sadsadsadsadsadsad
-------------------------------------------------------------------------------------------
-- You need to fix the sort order. Right now the Asc / Desc doesn't work, but
-- I think thats it & its done.
-- I think the problem is that I am constantly resetting the sortHeaderGroup.sortDirection
-- To the clickedHeader.initialDirection, so its always true...
-- But I don't want it to always be true,
-- I need its value to be based off of whether or not the first key was set to Asc true
--
--.....
--....
-- However, thats a problem....I wiped that value when I created the SortKey tables
-- I looped through read the Asc value & used it to determine reverseTiebreakerOrder
-- Although it shouldn't be to difficult to fix...just go back where I set the reversetie....
-- and ALSO save the ASC property into the table along with it...then
-- When I grab the stuff in the changeSort, I can just grab the ASC there & I have
-- the starting sort order.
-------------------------------------------------------------------------------------------

















