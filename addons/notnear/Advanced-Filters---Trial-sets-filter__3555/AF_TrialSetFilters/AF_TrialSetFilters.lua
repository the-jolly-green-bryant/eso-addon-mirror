--AdvancedFilters check
local AF = AdvancedFilters
local util = AF.util
if not AF or not util then return end

--LibSets check
local libSets = LibSets
if not libSets then return end

AF_TrialSetFilters = AF_TrialSetFilters or {}
local afTS = AF_TrialSetFilters
local transl = afTS.translation
if not transl then return end

--Constant
local addonPluginName 		= "AF_TrialSetFilters"
local subMenuPrefix			= addonPluginName .. "SubmenuTrialSet_"
local subMenuEntryAllSets   = "TrialSetsAll"

--Constants for ALL SETS
local allSetsConstantName 	= "--ALL_TRIAL_SETS--"
local allSetsConstantId 	= 9999999999
local charsOfAlphabet 		= ('abcdefghijklmnopqrstuvwxyz')

local umlauts = {
	"ä", "ö", "ü", "ß"
}
local umlautReplacement = {
	"a", "o", "u", "s"
}

local filterPanelsToExclude = {
	LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
	LF_SMITHING_REFINE, LF_SMITHING_CREATION,
	LF_ALCHEMY_CREATION,
	LF_CRAFTBAG,
	LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
	LF_QUICKSLOT
}

--local pointers to ZOs
local EM 			= EVENT_MANAGER
local stc 			= ZO_ShallowTableCopy
local strform 		= ZO_CachedStrFormat
local gisi 			= GetItemLinkSetInfo
local gi 			= GetItemLink
local strchar		= string.char
local strfind		= string.find
local tinsert		= table.insert
local tsort			= table.sort
local ts			= tostring


--local pointers to LibSets
local areSetsLoaded = libSets.AreSetsLoaded
local getSetName = libSets.GetSetName

--local helper functions
local function findUmlaut(strToSearch, posToFind)
	for idx, umlaut in ipairs(umlauts) do
		if strfind(strToSearch, umlaut) == posToFind then return umlautReplacement[idx] end
	end
	return nil
end


-- saved vars and slash commands

local addonDefaults = {
	onlyall = false,
}

local function toggleonlyall()
	local sv = afTS.ASV
	if sv.onlyall == true then
		sv.onlyall = false
		d(GetString(AFTS_COMMAND_MESSAGE_1))
	elseif sv.onlyall == false then
		sv.onlyall = true
		d(GetString(AFTS_COMMAND_MESSAGE_2))
	end
end

local function registerSlashCommands()
	SLASH_COMMANDS["/af_trialset"] = function () toggleonlyall() end
end

--Addon plugin load function
local function addOnPluginLoaded(event, name)
	if name ~= addonPluginName then return end
	EM:UnregisterForEvent(addonPluginName, EVENT_ADD_ON_LOADED)

	afTS.ASV = ZO_SavedVars:NewAccountWide(addonPluginName .. "_Data", 1, nil, addonDefaults)

	registerSlashCommands()

	--Check if library LibSets is loaded and load the sets data if missing yet
	if (not areSetsLoaded() or libSets.trialSets == nil) then
		libSets.LoadSets(true, addonPluginName)
		return
	end
	if (not areSetsLoaded() or libSets.trialSets == nil) then
		d("[AdvancedFilters Plugin]: \'TrialSets\' is missing LibSets trial sets data!")
		return
	end


	--Build the setIds via LibSets
	local trialSetIds = {}
	stc(libSets.trialSets, trialSetIds)
	local setNamesWithId = {}
	local setNamesSorted = {}
	--Get the name of the sets
	for setId, _  in pairs(trialSetIds) do
		local setName = ""
		--All entries except the ALL SETS entry
		setName = getSetName(setId)
		--Remove gender stuff from the set name
		setName = strform("<<C:1>>", setName)
		setNamesWithId[setName] = setId
		--Put the id and name as a table in the table "setNames". This way setNames can be sorted
		--The string contains the setItemId, a divider "::" and the setname
		tinsert(setNamesSorted, setName .. "::" .. ts(setId))
	end
	setNamesWithId[allSetsConstantName] = allSetsConstantId
	tinsert(setNamesSorted, allSetsConstantName .. "::" .. ts(allSetsConstantId))
	tsort(setNamesSorted)

--afTS._setNamesWithId = setNamesWithId
--afTS._setNamesSorted = setNamesSorted

	local function GetFilterCallbackForSets( setId )
		return function( slot , slotIndex)
			if util.prepareSlot ~= nil then
				if slotIndex ~= nil and type(slot) ~= "table" then
					slot = util.prepareSlot(slot, slotIndex)
				end
			end
			local setFound = false
			--get the item link
			local itemLink = gi(slot.bagId, slot.slotIndex)
			--Get the set item information
			local _, _, _, _, _, setIdToCompareTo = gisi(itemLink)
			if setIdToCompareTo == nil then return false end
			--Check for all sets?
			if setId == allSetsConstantId then
				for setIdToCompareToLoop, _ in pairs(trialSetIds) do
					setFound = (setIdToCompareTo == setIdToCompareToLoop) or false
					if setFound then return true end
				end
				--Only check one specific set
			else
				setFound = (setIdToCompareTo == setId) or false
			end
			return setFound
		end
	end

	local allTrialSetsDropdownCallback = { { name = subMenuEntryAllSets, filterCallback = GetFilterCallbackForSets( allSetsConstantId ) } }
	local fullDropdownSetsCallbacks      = {}
	local dropdownFiveSetEachCallbacks   = {}
	local dropdownFiveSetEachKeys		 = {}
	local dropdownFiveSetEachCharactersKey = {}
	local foundSetsCharacters            = {}
	--Get the name of the sets
	--[[
	for setName, setId  in pairs(setNamesWithId) do
		tinsert(fullLevelDropdownSetsCallbacks, { name = setName, filterCallback = GetFilterCallbackForSets( setId ) } )
	end
	]]
	local function buildFullLevelDropdownSetCallbacks()
		if fullDropdownSetsCallbacks ~= nil then
			local addedAllSetsEntry = {}
			--Sorted list of set names in the dropdown!
			for _, setString in ipairs(setNamesSorted) do
				--Split the set string by the "::"
				local setName, setIdStr = zo_strsplit("::", setString)
				if tonumber(setIdStr) ~= allSetsConstantId then
					local setNameLower = setName:lower()
					local character
					local charForUmlaut = findUmlaut(setNameLower, 1)
					if charForUmlaut ~= nil then
						character = charForUmlaut
					else
						character = setNameLower:sub(1, 1)
					end
					local charByte                      = character:byte()
					fullDropdownSetsCallbacks[charByte] = fullDropdownSetsCallbacks[charByte] or {}
					if not ZO_IsElementInNumericallyIndexedTable(foundSetsCharacters, charByte) then
						tinsert(foundSetsCharacters, charByte)
					end
					--[[
					if not addedAllSetsEntry[charByte] then
						tinsert(fullDropdownSetsCallbacks[charByte], { name = allSetsConstantName, filterCallback = GetFilterCallbackForSets( allSetsConstantId ) } )
						addedAllSetsEntry[charByte] = true
					end
					]]
					local setId = tonumber(setIdStr)
					tinsert(fullDropdownSetsCallbacks[charByte], { name = setName, filterCallback = GetFilterCallbackForSets( setId ) } )
				end
			end
			tsort(fullDropdownSetsCallbacks)
			tsort(foundSetsCharacters)
			--Now use always 5 characters of the alphabet and put all sets below this headline, e.g. A-E, F-J
			dropdownFiveSetEachCallbacks = {}
			local entriesForDropdownFiveSetEachCallbacks = {}
			local charOfAlphabet = ""
			local packageCharacterCountOfAlphabet = 5
			local firstCharOfFiverGroup = ""
			local fiveCharacters = ""
			--Only check until Y and just add the 26th char to the last packeg of U-Y -> U-Z
			local count = 0
			for i=1, 25 do
				count = i - 1
				charOfAlphabet = charsOfAlphabet:match(charOfAlphabet..'(.)')
				if charOfAlphabet and charOfAlphabet ~= "" then
					local charByte = charOfAlphabet:byte()
					tinsert(entriesForDropdownFiveSetEachCallbacks, charByte)
--d(">i: " ..ts(i) .. ", char: " ..ts(charOfAlphabet))
					if count == 0 or (count % packageCharacterCountOfAlphabet == 0 and i < 25) then
						firstCharOfFiverGroup = charOfAlphabet
						fiveCharacters = ""
--d(">>firstCharOfFiverGroup: " ..firstCharOfFiverGroup)
					end
					if count > 1 and (i % packageCharacterCountOfAlphabet == 0 or i == 25) then
--d(">>drin - mod: " ..ts(i % packageCharacterCountOfAlphabet))
						local isLastChar = (i == 25) or false
						local toChar = (isLastChar == false and charOfAlphabet) or "z" --always add Z to the last package U-Z
						fiveCharacters = ts(firstCharOfFiverGroup:upper()) .. "-" .. toChar:upper()
						if fiveCharacters ~= "" then
							table.insert(dropdownFiveSetEachKeys, fiveCharacters)
--d(">>>fiveCharacters: " ..ts(fiveCharacters))
							local toCharByte
							if isLastChar == true then
								toCharByte = toChar:byte()
								tinsert(entriesForDropdownFiveSetEachCallbacks, toCharByte)
							end

							--Add the characters of the 5 alphabet chars to the key table for the setNames
							dropdownFiveSetEachCharactersKey[fiveCharacters] = {}
							local startCharByte = firstCharOfFiverGroup:byte()
							local endCharByte = toCharByte or toChar:byte()
--d(">>>startCharByte: " ..ts(startCharByte) .. ", endCharByte: " ..ts(endCharByte))
							for charToAddAsByte=startCharByte, endCharByte, 1 do
								table.insert(dropdownFiveSetEachCharactersKey[fiveCharacters], ts(strchar(charToAddAsByte)))
							end

							fiveCharacters = subMenuPrefix .. fiveCharacters
							dropdownFiveSetEachCallbacks[fiveCharacters] = {}
							local setsToAddForFiveCharacters = {}
							--Add "All sets" entry once
							tinsert(setsToAddForFiveCharacters, { name = allSetsConstantName, filterCallback = GetFilterCallbackForSets( allSetsConstantId ) } )
							for _, charByteOfFiveCharacterSetsToAdd in ipairs(entriesForDropdownFiveSetEachCallbacks) do
--d(">charByte: " ..ts(charByteOfFiveCharacterSetsToAdd) .. ", char: " ..ts(strchar(charByteOfFiveCharacterSetsToAdd)))
								if fullDropdownSetsCallbacks[charByteOfFiveCharacterSetsToAdd] ~= nil then
									--Add headline with the character
									tinsert(setsToAddForFiveCharacters, { name="_" .. strchar(charByteOfFiveCharacterSetsToAdd), callback=nil, itemType=MENU_ADD_OPTION_HEADER })
									for _, setsOfCharacter in ipairs(fullDropdownSetsCallbacks[charByteOfFiveCharacterSetsToAdd]) do
										tinsert(setsToAddForFiveCharacters, setsOfCharacter)
									end
								end
							end
							dropdownFiveSetEachCallbacks[fiveCharacters] = setsToAddForFiveCharacters
							entriesForDropdownFiveSetEachCallbacks = {}
						end
					end
				end
			end
--afTS._entriesForDropdownFiveSetEachCallbacks = entriesForDropdownFiveSetEachCallbacks
--afTS._fullDropdownSetsCallbacks 		= fullDropdownSetsCallbacks
--afTS._dropdownFiveSetEachCallbacks 	= dropdownFiveSetEachCallbacks
--afTS._dropdownFiveSetEachCharactersKey = dropdownFiveSetEachCharactersKey
		end
	end
	buildFullLevelDropdownSetCallbacks()


	--Loop over the standard set names and add them to the returnTable
	local function getSetNames(returnTable, character)
		if returnTable == nil or character == nil then return end
		--Build the set names without gender specific strings
		for setName, setId in pairs(setNamesWithId) do
			if setId ~= allSetsConstantId then
				local setNameLower = setName:lower()
				local firstChar
				local charForUmlaut = findUmlaut(setNameLower, 1)
				if charForUmlaut ~= nil then
					firstChar = charForUmlaut
				else
					firstChar = setNameLower:sub(1, 1)
				end
				--local charByte = firstChar:byte()
				--if charByte == character then
				if firstChar == character then
					--Check if entry with setId already exists (e.g. the entry with the "allSetsConstantId" ID) and don't overwrite it
					if returnTable[setName] == nil then
						returnTable[setName] = setName
					end
				end
			end
		end
	end

	local function buildFilterInformation()
		--For each of the entries of 5 alhpabet characters:

		for _, fiveCharacters in ipairs(dropdownFiveSetEachKeys) do
			local fiveCharactersSubMenuName = subMenuPrefix .. fiveCharacters

			local stringsEN = {
				[allSetsConstantName]      = "-All trial sets-",
			}
			local stringsDE = {
				[allSetsConstantName]      = "-Alle Trial Sets-",
			}
			local stringsFR = {
				[allSetsConstantName]      = "-Tous les set des trial-",
			}
			stringsEN[fiveCharactersSubMenuName] = transl.TRIAL_SETS_MENU_ENTRY ..fiveCharacters
			stringsDE[fiveCharactersSubMenuName] = transl.TRIAL_SETS_MENU_ENTRY ..fiveCharacters
			stringsFR[fiveCharactersSubMenuName] = transl.TRIAL_SETS_MENU_ENTRY ..fiveCharacters

			--Add the setnames below
			local charactersOfFiverGroup = dropdownFiveSetEachCharactersKey[fiveCharacters]
			if charactersOfFiverGroup ~= nil then
				for _, character in ipairs(charactersOfFiverGroup) do
					local upperCharOfCharacter = character:upper()
					stringsEN["_"..character] = "-"..upperCharOfCharacter.."-"
					getSetNames(stringsEN, character)
					stringsDE["_"..character] = "-"..upperCharOfCharacter.."-"
					getSetNames(stringsDE, character)
					stringsFR["_"..character] = "-"..upperCharOfCharacter.."-"
					getSetNames(stringsFR, character)
				end
			end

			--[[
				This section packages the data for Advanced Filters to use.
				All keys are required except for deStrings, frStrings, and ruStrings, as they correspond to
					optional languages. Al language keys are assigned the same table here only to demonstrate
					the key names. You do not need to do this.
				The filterType key expects an ITEMFILTERTYPE constant provided by the game.
				The values for key/value pairs in subfilters can be any of the string keys from lines 127 - 218
					of AdvancedFiltersData.lua (AF_Callbacks table) such as "All", "OneHanded", "Body", or
					"Blacksmithing".
				If your filterType is ITEMFILTERTYPE_ALL then subfilters must only contain the value "All".
			  ]]

			--[[
				If you want your filters to show up under more than one main filter, redefine filterInformation
				to include the new filterType. The shorthand version (not including optional languages) is shown here.
			  ]]
			local filterInformation = {
				submenuName = fiveCharactersSubMenuName,
				callbackTable = dropdownFiveSetEachCallbacks[fiveCharactersSubMenuName],
				filterType = {
					ITEMFILTERTYPE_ARMOR,
					ITEMFILTERTYPE_WEAPONS,
					ITEMFILTERTYPE_JEWELRY,
				    ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL,
				    ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS,
				    ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR,
				    ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY,
				},
				subfilters = {"All",},
				excludeSubfilters = {"Clothing", "Vanity", "JewelryRetrait"},
				excludeFilterPanels = filterPanelsToExclude,
				enStrings = stringsEN,
				frStrings = stringsFR,
				deStrings = stringsDE,
			}
			--[[
				Again, register your filters by passing your new filter information to this function.
			  ]]
			AdvancedFilters_RegisterFilter(filterInformation)

			filterInformation = {
				submenuName = fiveCharactersSubMenuName,
				callbackTable = dropdownFiveSetEachCallbacks[fiveCharactersSubMenuName],
				filterType = ITEMFILTERTYPE_ALL,
				onlyGroups = {"Armor", "ArmorRetrait", "Weapons"},
				subfilters = {"All",},
				excludeSubfilters = {"Clothing", "Vanity", "JewelryRetrait"},
				excludeFilterPanels = filterPanelsToExclude,
				enStrings = stringsEN,
				frStrings = stringsFR,
				deStrings = stringsDE,
			}
			--[[
				Again, register your filters by passing your new filter information to this function.
			  ]]
			AdvancedFilters_RegisterFilter(filterInformation)
		end
	end

	--First add 1 entry for "All trial sets"
	local stringsAllEN = { [subMenuEntryAllSets] = transl.ALL_TRIAL_SETS_SUBMENU_ENTRY }
	local stringsAllDE = { [subMenuEntryAllSets] = transl.ALL_TRIAL_SETS_SUBMENU_ENTRY }
	local stringsAllFR = { [subMenuEntryAllSets] = transl.ALL_TRIAL_SETS_SUBMENU_ENTRY }

	local filterInformationAllTrialSets = {
		callbackTable = allTrialSetsDropdownCallback,
		filterType = {
			ITEMFILTERTYPE_ARMOR,
			ITEMFILTERTYPE_WEAPONS,
			ITEMFILTERTYPE_JEWELRY,
			ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL,
			ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS,
			ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR,
			ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY,
		},
		subfilters = {"All",},
		excludeSubfilters = {"Clothing", "Vanity", "JewelryRetrait"},
		excludeFilterPanels = filterPanelsToExclude,
		enStrings = stringsAllEN,
		frStrings = stringsAllFR,
		deStrings = stringsAllDE,
	}
	--[[
        Again, register your filters by passing your new filter information to this function.
      ]]
	AdvancedFilters_RegisterFilter(filterInformationAllTrialSets)

	filterInformationAllTrialSets = {
		callbackTable = allTrialSetsDropdownCallback,
		filterType = ITEMFILTERTYPE_ALL,
		onlyGroups = {"Armor", "ArmorRetrait", "Weapons"},
		subfilters = {"All",},
		excludeSubfilters = {"Clothing", "Vanity", "JewelryRetrait"},
		excludeFilterPanels = filterPanelsToExclude,
		enStrings = stringsAllEN,
		frStrings = stringsAllFR,
		deStrings = stringsAllDE,
	}
	--[[
        Again, register your filters by passing your new filter information to this function.
      ]]
	AdvancedFilters_RegisterFilter(filterInformationAllTrialSets)

	--For each 5 first characters of the alphabet build it's own filterinformation table with a submenu
	--containing all the sets of the characters
	-- buildFilterInformation()

	if afTS.ASV.onlyall == false then
		buildFilterInformation()
	end
end

EM:RegisterForEvent(addonPluginName .. "_Loaded", EVENT_ADD_ON_LOADED, addOnPluginLoaded)
