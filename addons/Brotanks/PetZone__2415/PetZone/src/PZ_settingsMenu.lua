if PZ == nil then PZ = {} end
local PetZone = PZ

function PetZone.buildAddonMenu()
    local lang = PetZone.lang or GetCVar("language.2")

    local settings = PetZone.settingsVars.settings
    if not settings or not PetZone.LAM then return false end
    local defaults = PetZone.settingsVars.defaults
    local addonVars = PetZone.addonVars
	local randomPetNameList = ""
	local randomListName = ""
	local randListNames = {}
	local selectedRandList = {}
	local selectedRandPet = ""
	local selectedExPet = ""
	local randPetNames = {}
	local randPetValues = {}
	local ExPetList = ""
	
    local panelData = {
        type 				= 'panel',
        name 				= addonVars.addonNameMenu,
        displayName 		= addonVars.addonNameMenuDisplay,
        author 				= addonVars.addonAuthor,
        version 			= tostring(addonVars.addonVersion),
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand        = "/pz",
        website             = addonVars.addonWebsite
    }

    local savedVariablesOptions = {
        [1] = 'Character',
        [2] = 'Account'
    }

	function PZ.tableContains(tebble, element, recurse, checkIndicator)
		local doesContain = false
		for indicator, value in pairs(tebble) do
			if value == element then
				doesContain = true
				break
			end
			if checkIndicator then
				if indicator == element then
					doesContain = true
					break
				end
			end
			if type(value) == "table" and recurse then
				if checkIndicator then
					if PZ.tableContains(value, element, true, true) then 
						doesContain = true
						break
					end
				else
					if PZ.tableContains(value, element, true) then 
						doesContain = true
						break
					end
				end
			end
		end
		return doesContain
	end
	
    --Build the LAM dropdown boxes for the Pets
    local function BuildPetDropdown()
        local PetValues = {}
        local PetNames = {}
        table.insert(PetNames, PZ_NONE_ENTRIES)
        table.insert(PetValues, 0)
        table.insert(PetNames, PZ_RANDOM_PET)
        table.insert(PetValues, -1) --Random PetId is -1
        table.insert(PetNames, PZ_NO_PET)
        table.insert(PetValues, -2) --No Pet PetId is -2
        settings.defaultPet = 0
		local Randoms = PetZone.settingsVars.settings.CustRandLists
		if Randoms ~= nil then
			for tableName, tableContents in pairs(Randoms) do
                if table.maxn(tableContents) > 0 then -- needs at least one creature in the list to be listed. For safety purposes.
					betterName = "~" .. tableName
					table.insert(PetValues, tableName)
					table.insert(PetNames, betterName)
				end
			end
		end
        local PetData = PetZone.PetData
        if PetData ~= nil then
			for PetId, PetName in pairs(PetData) do
                table.insert(PetValues, PetId)
                table.insert(PetNames, PetName)
            end
        end
			PetZone.DropdownPetNames  = PetNames
			PetZone.DropdownPetValues = PetValues
--			d("BuildPetDropdown done")
    end
    BuildPetDropdown()

    --Build the LAM dropdown boxes for the zones
    local function BuildZoneDopdown()
        local zoneNameDropDownBoxes = {}
        local zoneValueDropDownBoxes = {}
        local subZoneNameDropdownBoxes = {}
        local subZoneValueDropdownBoxes = {}
        local zoneData = PetZone.ZoneData
		local subZoneNameToId = {}
		if zoneData ~= nil then
            table.insert(zoneNameDropDownBoxes, PZ_NONE_ENTRIES)
            table.insert(zoneValueDropDownBoxes, PZ_NONE_ENTRIES)
            table.insert(zoneNameDropDownBoxes, PZ_ALL_ENTRIES)
            table.insert(zoneValueDropDownBoxes, PZ_ALL_ENTRIES)
            for zone, subZones in pairs(zoneData) do
				local zoneNameOverwriteId = 0
                local zoneNameOverwrite = ""
                for subZone, value in pairs(subZones) do
                    --Got a zoneId for the zone, then get this entry and build the name of the zone via LibZone localized data!
                    if subZone == PZ_ZONE_ID_STRING then
                        if PetZone.libZone ~= nil and tonumber(value) ~= 0 then
                            zoneNameOverwriteId = tonumber(value)
                            zoneNameOverwrite = PetZone.libZone:GetZoneName(tonumber(value), lang)
							if zoneNameOverwrite == nil or zoneNameOverwrite == "" then
								zoneNameOverwrite = zo_strformat("<<C:1>>", GetZoneNameByIndex(GetZoneIndex(tonumber(value))))
							end
                        end
                    end
                    --Exclude subzone ""_mappedZoneName" as it is only a mapped name for the zone!
                    if subZone ~= PZ_ZONE_ID_STRING and subZone ~= PZ_ZONE_MAPPING_STRING then
                        --Subzone is a boolean or subzone is an alternative/mapping name string?
                        local valueIsSubZoneName = (type(value) == "string" and value ~= "")
                        local valueIsZoneId = not valueIsSubZoneName and (type(value) == "number")
                        if (type(value) == "boolean" and value == true) or valueIsSubZoneName or valueIsZoneId then
                            if subZoneValueDropdownBoxes[zone] == nil then
                                subZoneValueDropdownBoxes[zone] = {}
                                subZoneNameDropdownBoxes[zone] = {}
                            end
                            subZoneValueDropdownBoxes[zone][subZone] = subZone
                            local subZoneName = string.gsub(subZone, '_base', '')
                            if valueIsSubZoneName then
                                subZoneName = value
                            else
                                --subZoneId was provided?
                                if valueIsZoneId then
                                    subZoneName = PetZone.libZone:GetZoneName(tonumber(value), lang)
									if subZoneName == nil or subZoneName == "" then
										subZoneName = zo_strformat("<<C:1>>", GetZoneNameByIndex(GetZoneIndex(tonumber(value))))
									end
                                else
                                    subZoneName = string.gsub(subZone, '_base', '')
                                end
                            end
                            subZoneName = zo_strformat('<<C:1>>', subZoneName)
                            subZoneNameDropdownBoxes[zone][subZone] = subZoneName
							--trying to build a nested table that attaches multiple subzone ids to one name
							if subZoneNameToId[zone] == nil then
								subZoneNameToId[zone] = {}
							end
							if subZoneNameToId[zone][subZoneName] == nil then
								subZoneNameToId[zone][subZoneName] = {}
							end
							for zone, subzones in pairs(subZoneNameDropdownBoxes) do
								for subid, subname in pairs(subzones) do
									if subname == subZoneName then
										if not PZ.tableContains(subZoneNameToId[zone][subZoneName], subid) then
											table.insert(subZoneNameToId[zone][subZoneName], subid)
--											d(tostring(zone) .. " " .. tostring(subZoneName) .. " " .. tostring(subid))
										end
									end
								end
--								d(tostring(zone))
							end
                        end
                    end
                end -- for subZone, value
                --Add the zone table entry now
                local zoneName, subZoneName
                if zoneNameOverwrite ~= "" then
                    zoneName = zoneNameOverwrite
                else
                    zoneName, subZoneName = PetZone.MapZoneAndSubZoneNames(zone, nil, zoneNameOverwrite)
                end
                zoneName = zo_strformat('<<C:1>>', zoneName)
                if zoneName ~= "YA DONE FUCKED UP BROTANKS" then table.insert(zoneNameDropDownBoxes, zoneName) end
                if zone ~= "IGNOREME" then table.insert(zoneValueDropDownBoxes, zone) end
            end -- for zone, subZones
		end
        PetZone.DropdownZoneNames     = zoneNameDropDownBoxes
        PetZone.DropdownZoneValues    = zoneValueDropDownBoxes
        PetZone.DropdownSubZoneNames  = subZoneNameDropdownBoxes
        PetZone.DropdownSubZoneValues = subZoneValueDropdownBoxes
		PetZone.IdByName = subZoneNameToId
--		d("BuildZoneDopdown done")
    end
    BuildZoneDopdown()


    --Hide the Pet selection dropdown
    local function SetPetSelectDropdownBoxState(state)
        state = state or false
        if PetZone_LAM_Dropdown_Pets_For_Pet ~= nil then
            PetZone_LAM_Dropdown_Pets_For_Pet:SetHidden(not state)
        end
    end
	
	local function BuildRandomListsDropdown()
		local newRandListNames = {}
		local masterList = PetZone.settingsVars.settings.CustRandLists
		if masterList ~= nil then
			for name, _ in pairs(masterList) do
				table.insert(newRandListNames, name)
			end
		end
			randListNames = newRandListNames 
--			d("BuildRandomListsDropdown done")
	end
	BuildRandomListsDropdown()
	
    local function BuildRandPetDropdown()
        local PetValues = {}
        local PetNames = {}
        settings.defaultPet = 0
        local PetData = PetZone.PetData
		if PetData ~= nil then
            for PetId, PetName in pairs(PetData) do
                table.insert(PetValues, PetId)
                table.insert(PetNames, PetName)
            end
        end
        randPetNames  = PetNames
        randPetValues = PetValues
--		d("BuildRandPetDropdown done")
    end
    BuildRandPetDropdown()

	--update the display of the current custom randomlist
	local function RefreshListAndDropdowns()
		randomPetNameList = ""
		local masterList = PetZone.settingsVars.settings.CustRandLists
		if masterList[selectedRandList] ~= nil and masterList[selectedRandList] ~= "" then
			for _, ids in pairs(masterList[selectedRandList]) do
				local collectibleName, _, _, _, _, _, _, _ = GetCollectibleInfo(ids)
				local PetName = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleName)
				if randomPetNameList == "" then
					randomPetNameList = PetName
				else
					randomPetNameList = randomPetNameList .. "\n" .. PetName
				end
			end
		end
		PetZone_LAM_Randomlist_State.data.text = randomPetNameList
		PetZone_LAM_Randomlist_State:UpdateValue() 
		BuildPetDropdown()
		PetZone_LAM_Dropdown_Pets_For_Pet:UpdateChoices(PetZone.DropdownPetNames, PetZone.DropdownPetValues)
--		d("RefreshListAndDropdowns done")
	end
	
	local function AddPetToRandList()
		local masterList = PetZone.settingsVars.settings.CustRandLists
		if selectedRandList ~= nil and selectedRandList ~= "" and selectedRandPet ~= nil and selectedRandPet ~= "" then
			table.insert(masterList[selectedRandList], selectedRandPet)
		end
		PetZone.settingsVars.settings.CustRandLists = masterList
		RefreshListAndDropdowns()
	end
	
	local function RemPetFromRandList()
		local masterList = PetZone.settingsVars.settings.CustRandLists
		if selectedRandList ~= nil and selectedRandList ~= "" and selectedRandPet ~= nil and selectedRandPet ~= "" and table.maxn(masterList[selectedRandList]) > 0 then
			for pos, pet in pairs(masterList[selectedRandList]) do
				if pet == selectedRandPet then
					table.remove(masterList[selectedRandList], pos)
					break
				end
			end
		end
		PetZone.settingsVars.settings.CustRandLists = masterList
		RefreshListAndDropdowns()
--		d("RemPetFromRandList done")
	end
	
	--add custom list name to the master custom list list
	local function AddCustListName()
		local masterList = PetZone.settingsVars.settings.CustRandLists
		if not PZ.tableContains(masterList, randomListName, false, true) and not (randomListName == nil or randomListName == "") then
			masterList[randomListName] = {}
		end
		PetZone.settingsVars.settings.CustRandLists = masterList
		BuildRandomListsDropdown()
		PetZone_LAM_CustomListDropdown_Control:UpdateChoices(randListNames)
		RefreshListAndDropdowns()
	end
	
	local function RemCustListName()
		local masterList = PetZone.settingsVars.settings.CustRandLists
		if PZ.tableContains(masterList, selectedRandList, false, true) then
			masterList[selectedRandList] = nil
		end
		PetZone.settingsVars.settings.CustRandLists = masterList
		BuildRandomListsDropdown()
		PetZone_LAM_CustomListDropdown_Control:UpdateChoices(randListNames)
		RefreshListAndDropdowns()
	end
	
	local function refreshKennelList()
		ExPetList = ""
		local kennel = PetZone.settingsVars.settings.ExList
		if kennel ~= nil and kennel ~= "" then
			for _, ids in pairs(kennel) do
				local collectibleName, _, _, _, _, _, _, _ = GetCollectibleInfo(ids)
				local names = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleName)
				if ExPetList == "" then
					ExPetList = names
				else
					ExPetList = ExPetList .. "\n" .. names
				end
			end
--			d("refreshKennelList done")
		end
	end
	refreshKennelList()
	
	local function KennelPet()
		local kennel = PetZone.settingsVars.settings.ExList
		if not PZ.tableContains(kennel, selectedExPet) and not (selectedExPet == nil or selectedExPet == "") then table.insert(kennel, selectedExPet) end
		PetZone.settingsVars.settings.ExList = kennel
		refreshKennelList()
		PetZone_LAM_KennelList_State.data.text = ExPetList
		PetZone_LAM_KennelList_State:UpdateValue() 
	end
	
	local function unKennelPet()
		local kennel = PetZone.settingsVars.settings.ExList
		for pos, pet in pairs(kennel) do
			if pet == selectedExPet then
				table.remove(kennel, pos)
			end
		end
		PetZone.settingsVars.settings.ExList = kennel
		refreshKennelList()
		PetZone_LAM_KennelList_State.data.text = ExPetList
		PetZone_LAM_KennelList_State:UpdateValue()
--		d("unKennelPet done")
	end
	
    --Change the entries of the LAM subZone dropdownbox
    local function ChangeSubZoneEntries(zone)
--d("ChangeSubZoneEntries - zone: " .. tostring(zone))
        if zone == nil then return false end
        PetZone.LAMDropdownSubZoneNames = {}
        PetZone.LAMDropdownSubZoneValues = {}
        --Is the subzone dropdownbox there?
        if PetZone_LAM_Dropdown_SubZones_For_Pet ~= nil then
            --Hide the Pet selection dropdown box
            SetPetSelectDropdownBoxState(false)
			--Is the zone name "- -"?
            if zone == PZ_NONE_ENTRIES then

                table.insert(PetZone.LAMDropdownSubZoneNames, PZ_NONE_ENTRIES)
                table.insert(PetZone.LAMDropdownSubZoneValues, PZ_NONE_ENTRIES)
				
			elseif zone == PZ_ALL_ENTRIES then
			
                table.insert(PetZone.LAMDropdownSubZoneNames, PZ_ALL_ENTRIES)
                table.insert(PetZone.LAMDropdownSubZoneValues, PZ_ALL_ENTRIES)
                SetPetSelectDropdownBoxState(true)
				
            else
                --Loop over subzone array with the given zone name
				for zoneName, subZoneData in pairs(PetZone.IdByName) do
					if zoneName == zone then
                        table.insert(PetZone.LAMDropdownSubZoneNames, PZ_ALL_ENTRIES)
                        table.insert(PetZone.LAMDropdownSubZoneValues, PZ_ALL_ENTRIES)
						for subZoneName, subZoneIds in pairs(subZoneData) do
							table.insert(PetZone.LAMDropdownSubZoneNames, subZoneName)
							table.insert(PetZone.LAMDropdownSubZoneValues, subZoneIds)
                        end
                    end
				end
            end
            local numEntries = #PetZone.LAMDropdownSubZoneNames
            if numEntries > 0 then
--d(">updateChoices of SUBZONES")
                PetZone_LAM_Dropdown_SubZones_For_Pet:UpdateChoices(PetZone.LAMDropdownSubZoneNames, PetZone.LAMDropdownSubZoneValues)
                if not PetZone.preventerVars.doNotUpdateSubZoneValue then
                    local firstEntry = PetZone.LAMDropdownSubZoneNames[1]
                    PetZone.LAMSelectedSubZone = firstEntry
                    --And now select the default entry of the subZones
--d(">updateValue of SUBZONES to: " ..tostring(firstEntry))
                    PetZone_LAM_Dropdown_SubZones_For_Pet:UpdateValue(false, firstEntry)
                end
            end
        else
            d(">LAM dropdown not found: PetZone_LAM_Dropdown_SubZones_For_Pet")
        end
			PetZone.preventerVars.doNotUpdateSubZoneValue = false 
--			d("ChangeSubZoneEntries done")
    end

    --Get the current zone and subzone and update the LAM drodpwons to these values
    local function GetCurrentZoneAndUpdateLAMDropdowns()
        --Get the chosen Pet for this zone and subzone
        local zone, subZone = PetZone.GetZoneAndSubzone()
		--Make sure we have the data
		if not PetZone.IdByName[zone] then return false end
--d(">GetCurrentZoneAndUpdateLAMDropdowns - zone: " .. tostring(zone) .. ", subZone: " .. tostring(subZone))
        local firstEntry = PetZone.LAMDropdownSubZoneNames[1]
        PetZone.LAMSelectedSubZone = firstEntry
        PetZone.preventerVars.doNotUpdateSubZoneValue = true
        if zone ~= nil then
			--d(zone)
            --Set the zone to the current one
            PetZone.LAMSelectedZone = zone
            PetZone_LAM_Dropdown_Zones_For_Pet:UpdateValue(false, zone)
            if subZone ~= nil then
                --Set the subZone to the current one
                for subName, subIds in pairs(PetZone.IdByName[zone]) do
					if PZ.tableContains(subIds, subZone, true) then
						PetZone.LAMSelectedSubZone = subZone
--						d("trying for: " ..subName .." " ..subIds[1])
						PetZone_LAM_Dropdown_SubZones_For_Pet:UpdateValue(false, subIds)
						break
					end
				end
			else
                --Set the subZone to -ALL-
                PetZone_LAM_Dropdown_SubZones_For_Pet:UpdateValue(false, firstEntry)
            end
        else
            --Set the zone to -NONE-
            PetZone_LAM_Dropdown_Zones_For_Pet:UpdateValue(false, PetZone.DropdownZoneValues[1])
            --Set the subZone to -NONE-
            PetZone_LAM_Dropdown_SubZones_For_Pet:UpdateValue(false, firstEntry)
        end
    end

    --Check if the Pet for the current zone is changed and set it to the new one
    local function UpdatePetSettingsForCurrentZoneAndSubzone(zoneInSettings, subZoneInSettings)
--d("[PetZone]UpdatePetSettingsForCurrentZoneAndSubzone - isMounted: " .. tostring(isCharMounted) .. ", zone: " ..tostring(zoneInSettings) .. ", subZone: " ..tostring(subZoneInSettings) .. ")
        local zone, subZone = PetZone.GetZoneAndSubzone()
        if zone == zoneInSettings then
			if type(subZoneInSettings) == "table" then
				if PZ.tableContains(subZoneInSettings, subZone, true) then
					--d(">>>Activate Pet")
					PetZone.ActivatePetForZone(zone, subZone)
				end
			elseif subZone == subZoneInSettings then
				--d(">>>Activate Pet")
				PetZone.ActivatePetForZone(zone, subZone)
			end
		end
    end

    PetZone.PZSettingsPanel = PetZone.LAM:RegisterAddonPanel(PetZone.addonVars.addonName .. "_LAM", panelData)

    --LAM 2.0 callback function if the panel was created
    local PZLAMPanelCreated = function(panel)
        if panel == PetZone.PZSettingsPanel then
--d("PZLAMPanelCreated")
            --Build the standard subzone entries with the "-NONE-" entry
            ChangeSubZoneEntries(PZ_NONE_ENTRIES)
        end
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", PZLAMPanelCreated)

    local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

        {
            type = 'description',
            title = '|c80FF00 Choose your vanity pet by zone and subzone!|r',
			text = '   Pet choices in order of priority: \n     1. Specific subzone choice \n     2. -ALL- subzones for current zone \n     3. -ALL- zones \n \n(You can also reach this menu via the command /pz)',
        },
        --==============================================================================
        {
            type = 'header',
            name = 'Pets',
        },

        --ZONEs
        {
            type = "dropdown",
            name = "Zone", -- or string id or function returning a string
--            tooltip = "Choose the zone for the Pet", -- or string id or function returning a string (optional)
            choices = PetZone.DropdownZoneNames,
            choicesValues = PetZone.DropdownZoneValues, -- if specified, these values will get passed to setFunc instead (optional)
            getFunc = function()
                local getVar = PZ_NONE_ENTRIES
                if PetZone.LAMSelectedZone ~= nil then
                    getVar = PetZone.LAMSelectedZone
                end
--d("ZONE DROPDOWN: GetFunc - getVar: " .. tostring(getVar))
                return getVar
            end,
            setFunc = function(zoneName)
                if zoneName ~= nil and zoneName ~= "" and zoneName ~= PZ_NONE_ENTRIES then
                    PetZone.LAMSelectedZone = zoneName
                    --Enable the Pet dropdown box now
                    SetPetSelectDropdownBoxState(true)
                else
                    PetZone.LAMSelectedZone = nil
                    --Disable the Pet dropdown box now
                    SetPetSelectDropdownBoxState(false)
                end
                --PetZone.LAMSelectedSubZone = nil
                --If zone is changed, update the subZone dropdown accordingly
--d("ZONE DROPDOWN: SetFunc - zoneName: " .. tostring(zoneName) .. ", LAMselectedZone: " .. tostring(PetZone.LAMSelectedZone))
                ChangeSubZoneEntries(zoneName)
            end,
            --choicesTooltips = {"tooltip 1", "tooltip 2", "tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
            sort = "name-up", --or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
            width = "half", --or "half" (optional)
            scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
            --disabled = function() return 1 == 2 end, --or boolean (optional)
            default = function()
                --Choose first entry of the dropdown: "All zones"
                --ChangeSubZoneEntries(PZ_NONE_ENTRIES)
                return PetZone.DropdownZoneValues[1]
            end, -- default value or function that returns the default value (optional)
            reference = "PetZone_LAM_Dropdown_Zones_For_Pet" -- unique global reference to control (optional)
        },
        --SUB ZONEs
        {
            type = "dropdown",
            name = "Subzone", -- or string id or function returning a string
--            tooltip = "Choose the subzone of the currently chosen zone for the Pet", -- or string id or function returning a string (optional)
            choices = PetZone.LAMDropdownSubZoneNames,
--            choicesValues = PetZone.LAMDropdownSubZoneValues[1], -- if specified, these values will get passed to setFunc instead (optional)
            getFunc = function()
                local getVar = PZ_NONE_ENTRIES
                if PetZone.LAMSelectedSubZone ~= nil then
                    getVar = PetZone.LAMSelectedSubZone
                end
--d("SUBZONE DROPDOWN: GetFunc - getVar: " .. tostring(getVar))
                return getVar
            end,
            setFunc = function(subZoneName)
                if subZoneName ~= nil then
					if (subZoneName[1] ~= "" and subZoneName[1] ~= PZ_NONE_ENTRIES) or subZoneName == PZ_ALL_ENTRIES then
						PetZone.LAMSelectedSubZone = subZoneName
						--Enable the Pet dropdown box now
						SetPetSelectDropdownBoxState(true)
					end
				else
                    PetZone.LAMSelectedSubZone = nil
                    --Disable the Pet dropdown box now
                    SetPetSelectDropdownBoxState(false)
                end
--d("SUBZONE DROPDOWN: SetFunc - subZoneName: " .. tostring(subZoneName) .. ", LAMselectedSubZone: " .. tostring(PetZone.LAMSelectedSubZone))
            end,
            --choicesTooltips = {"tooltip 1", "tooltip 2", "tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
            sort = "name-up", --or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
            width = "half", --or "half" (optional)
            scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
            --disabled = function() return 1 == 2 end, --or boolean (optional)
            default = function()
                return PetZone.DropdownSubZoneValues[1]
            end, -- default value or function that returns the default value (optional)
            reference = "PetZone_LAM_Dropdown_SubZones_For_Pet" -- unique global reference to control (optional)
        },
        --Pets
        {
            type = "dropdown",
            name = "Pet for zone & subzone", -- or string id or function returning a string
--            tooltip = "Choose the Pet for the selected zone and subzone", -- or string id or function returning a string (optional)
            choices = PetZone.DropdownPetNames,
            choicesValues = PetZone.DropdownPetValues, -- if specified, these values will get passed to setFunc instead (optional)
            getFunc = function()
                --Get the chosen Pet for the zone and subzone from the settings
				local chosenPetId = ""
				if type(PetZone.LAMSelectedSubZone) == "table" then
					chosenPetId = PetZone.LoadPetIdFromSettings(PetZone.LAMSelectedZone, PetZone.LAMSelectedSubZone[1]) or settings.defaultPet
				elseif type(PetZone.LAMSelectedSubZone) ~= "table" then
					chosenPetId = PetZone.LoadPetIdFromSettings(PetZone.LAMSelectedZone, PetZone.LAMSelectedSubZone) or settings.defaultPet
				end
                return chosenPetId
            end,
            setFunc = function(PetId)
                if PetZone.LAMSelectedZone ~= nil and PetZone.LAMSelectedSubZone ~= nil then
					--Save the chosen Pet to the settings
					PetZone.SavePetIdToSettings(PetId, false, PetZone.LAMSelectedZone, PetZone.LAMSelectedSubZone) --save the PetId to the settings (change collectible in the background)
					--Check if the Pet for the current zone is changed and set it to the new one
					UpdatePetSettingsForCurrentZoneAndSubzone(PetZone.LAMSelectedZone, PetZone.LAMSelectedSubZone)
				end
            end,
            --choicesTooltips = {"tooltip 1", "tooltip 2", "tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
            sort = "name-up", --or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
			default = PetZone.DropdownPetValues[1],
            width = "full", --or "half" (optional)
            scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
            disabled = function() return PetZone.LAMSelectedZone == nil or PetZone.LAMSelectedSubZone == nil end, --or boolean (optional)
            --default = function() return   end, -- default value or function that returns the default value (optional)
            reference = "PetZone_LAM_Dropdown_Pets_For_Pet" -- unique global reference to control (optional)
        },
        {
            type = "button",
            name = "Current zone", -- string id or function returning a string
            func = function()
                GetCurrentZoneAndUpdateLAMDropdowns()
            end,
            tooltip = "Select the current zone & subzone", -- string id or function returning a string (optional)
            width = "full", --or "half" (optional)
            reference = "PetZone_LAM_Button_GetCurrentZone", -- unique global reference to control (optional)
        },
		{
			type = "submenu",
			name = "Random Pet Lists",
			tooltip = "For making smaller, more specific random pet lists to assign to zones. If you want a random cat following you through Elsweyr, but only a cat, try this!",	--(optional)
			controls = {
            {
                type = "editbox",
                name = "Type a List Name",
                tooltip = "Name your own lists! Please be reasonable.",
                getFunc = function() return "" end,
                setFunc = function(text) randomListName = text end,
                isMultiline = false,	--boolean
                width = "half",	--or "half" (optional)
            },
			{
				type = "button",
				name = "Add Name as Custom List",
				func = function() AddCustListName() end,
				tooltip = "Unique names only! Duplicates won't register.",
				width = "half",
			},
			{
				type = "dropdown",
				name = "Custom Lists",
				tooltip = "",
				sort = "name-up",
				scrollable = true,
				choices = randListNames,
				getFunc = function()
						if selectedRandList == nil or selectedRandList == "" then
							if table.maxn(randListNames) > 0 then
								selectedRandList = randListNames[1]
							end
						end
						return selectedRandList
					end,
				setFunc = function(randList)
							if randList ~= nil and randList ~= "" then
								selectedRandList = randList
							end
							RefreshListAndDropdowns()
						end,
				width = "half",	--or "half" (optional)
				default = function() --cannot get the damn default to work. Not the end of the world, but still a little annoying.
						if table.maxn(randListNames) > 0 then
							return randListNames[1]
						end
					end,
				reference = "PetZone_LAM_CustomListDropdown_Control"
			},
			{
				type = "dropdown",
				name = "Pet to Add or Remove",
				tooltip = "",
				sort = "name-up",
				scrollable = true,
				choices = randPetNames,
				choicesValues = randPetValues,
				getFunc = function()
						if selectedRandPet == nil or selectedRandPet == "" then
							selectedRandPet = randPetValues[1]
						end
						return selectedRandPet
					end,
				setFunc = function(selectedPet) 
							if selectedPet ~= nil and selectedPet ~= "" then
								selectedRandPet = selectedPet
							end
						end,
				width = "half",	--or "half" (optional)
				default = randPetValues[1],
			},
			{
				type = "button",
				name = "Remove Pet from List",
				func = function() RemPetFromRandList() end,
				tooltip = "Only removes one instance of the selected pet.",
				width = "half",
			},
			{
				type = "button",
				name = "Add Pet to List",
				func = function() AddPetToRandList() end,
				tooltip = "You can add a pet to the same list multiple times, if you want to increase the chances of it appearing.",
				width = "half",
			},
			{
				type = "button",
				name = "Delete Selected List",
				func = function() RemCustListName() end,
				tooltip = "Self-explanatory. And non-reversible! Careful now.",
				width = "half",
			},
			{
				type = 'description',
				title = "List Contents",
				text = randomPetNameList,
				width = "half",
				reference = "PetZone_LAM_Randomlist_State",
			},
			},
		},
		{
			type = "submenu",
			name = "Pet Exclusion List",
			tooltip = "Any pets placed on this list won't show up in -RANDOM-. They'll still appear if specifically assigned to a zone, or put on a custom random list.",	--(optional)
			controls = {
			{
				type = "button",
				name = "Add Pet to List",
				func = function() KennelPet() end,
				tooltip = "",
				width = "half",
			},
			{
				type = "dropdown",
				name = "Pet to Add or Remove",
				tooltip = "",
				sort = "name-up",
				scrollable = true,
				choices = randPetNames,
				choicesValues = randPetValues,
				getFunc = function() 
						if selectedExPet == nil or selectedExPet == "" then
							selectedExPet = randPetValues[1]
						end
						return selectedExPet
					end,
				setFunc = function(selectedPet) 
							if selectedPet ~= nil and selectedPet ~= "" then
								selectedExPet = selectedPet
							end
						end,
				width = "half",	--or "half" (optional)
				default = randPetValues[1],
			},
			{
				type = "button",
				name = "Remove Pet from List",
				func = function() unKennelPet() end,
				tooltip = "",
				width = "half",
			},
			{
				type = 'description',
				title = '"The Kennel"',
				text = ExPetList,
				width = "half",
				reference = "PetZone_LAM_KennelList_State",
			},
			{
				type = "button",
				name = "Clear List",
				func = function()
						PetZone.settingsVars.settings.ExList = {}
						refreshKennelList()
						PetZone_LAM_KennelList_State.data.text = ExPetList
						PetZone_LAM_KennelList_State:UpdateValue() 	
					end,
				tooltip = "",
				width = "half",
			},
			},
		},
		{
		type = 'header',
		name = 'Options',
		},
        {
            type = 'dropdown',
            name = 'Use Settings For:',
            tooltip = 'Choosing \"Character\" only affects your current character\'s settings; any other characters set to \"Account\" will still share settings. Requires UI reload!',
            choices = savedVariablesOptions,
            getFunc = function() return savedVariablesOptions[PetZone.settingsVars.defaultSettings.saveMode] end,
            setFunc = function(value)
                for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        PetZone.settingsVars.defaultSettings.saveMode = i
                    end
                end
            end,
            requiresReload = true,
        },
		{
            type = "checkbox",
            name = 'Set zone/subzone pets from collections menu',
            tooltip = 'If you change your pet manually in the collectibles menu, it will also be set as the current zone & subzone\'s default pet.',
            getFunc = function() return settings.autoPresetForZoneOnNewPet end,
            setFunc = function(value) settings.autoPresetForZoneOnNewPet = value
            end,
            default = defaults.autoPresetForZoneOnNewPet,
            width="full",
        },
		{
			type = "checkbox",
			name = 'Hide pets in combat',
			tooltip = 'Brings a different pet back at the end of combat if you\'re using -RANDOM- pets. If you spam skills right from the start of combat, it might take a bit for your pet to disappear.',
			getFunc = function() return settings.HideInCombat end,
			setFunc = function(value) 
						settings.HideInCombat = value 
						if value == true then
							EVENT_MANAGER:RegisterForEvent(PetZone.addonVars.addonName,  EVENT_PLAYER_COMBAT_STATE, PetZone.InCombat)
						elseif value == false then
							EVENT_MANAGER:UnregisterForEvent(PetZone.addonVars.addonName,  EVENT_PLAYER_COMBAT_STATE)
						end
					end,
			default = defaults.HideInCombat,
			width = "full",
		},
		{
			type = "checkbox",
			name = 'Hide pets in dungeons and delves',
			tooltip = 'Vanity pets can get distracting! Enable this to keep your team members happy.',
			getFunc = function() return settings.HideInDungeons end,
			setFunc = function(value) settings.HideInDungeons = value end,
			default = defaults.HideInDungeons,
			width = "full",
		},
		{
			type = "checkbox",
			name = 'Hide pets when in groups',
			tooltip = 'Vanity pets can get distracting! Enable this to keep your team members happy.',
			getFunc = function() return settings.HideInGroups end,
			setFunc = function(value) 
						settings.HideInGroups = value 
						if value == true then
							EVENT_MANAGER:RegisterForEvent(PetZone.addonVars.addonName, EVENT_GROUP_UPDATE, PetZone.GroupChanged)
							EVENT_MANAGER:RegisterForEvent(PetZone.addonVars.addonName, EVENT_GROUP_MEMBER_LEFT, PetZone.GroupChanged)
							EVENT_MANAGER:AddFilterForEvent(PetZone.addonVars.addonName, EVENT_GROUP_MEMBER_LEFT, REGISTER_FILTER_UNIT_TAG, "player")
						elseif value == false then
							EVENT_MANAGER:UnregisterForEvent(PetZone.addonVars.addonName, EVENT_GROUP_UPDATE)
							EVENT_MANAGER:UnregisterForEvent(PetZone.addonVars.addonName, EVENT_GROUP_MEMBER_LEFT)
						end
					end,
			default = defaults.HideInGroups,
			width = "full",
		},
		{
			type = "checkbox",
			name = 'Hide pets when sneaking',
			tooltip = "Glowing ponies aren't particularly stealthy.",
			getFunc = function() return settings.HideInStealth end,
			setFunc = function(value) 
						settings.HideInStealth = value 
						if value == true then
							EVENT_MANAGER:RegisterForEvent(PetZone.addonVars.addonName, EVENT_STEALTH_STATE_CHANGED, PetZone.StealthChanged)
						elseif value == false then
							EVENT_MANAGER:UnregisterForEvent(PetZone.addonVars.addonName,  EVENT_STEALTH_STATE_CHANGED)
						end
					end,
			default = defaults.HideInStealth,
			width = "full",
		},
--[[		{
			type = "checkbox",
			name = 'Help gather data for the developer (PC NA only)',
			tooltip = 'Checks for missing zone/subzone data when you change zones, and sends it to the developer via in-game mail when you\'ve collected a certain amount.',
			getFunc = function() return settings.CheckForInfo end,
			setFunc = function(value) settings.CheckForInfo = value end,
			default = defaults.CheckForInfo,
			width = "full",
		},]]
		{
            type = 'description',
            title = 'Switching Options:',
			text = 'Pets switch automatically when you change zones, but that doesn\'t always work as expected. Try these settings for more control.',
		},
		{
			type = "checkbox",
			name = 'Switch pets when switching weapon sets',
			tooltip = 'Checks zone/subzone data and updates your pet when you swap your weapon sets. Useful for frequently triggering -RANDOM- pets.',
			getFunc = function() return settings.WeaponSwapChange end,
			setFunc = function(value) 
						settings.WeaponSwapChange = value 
						if value == true then
							EVENT_MANAGER:RegisterForEvent(PetZone.addonVars.addonName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, PetZone.EventActiveWeaponPairChanged)
						elseif value == false then
							EVENT_MANAGER:UnregisterForEvent(PetZone.addonVars.addonName,  EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
						end
					end,
			default = defaults.WeaponSwapChange,
			width = "full",
		},
		{
			type = "checkbox",
			name = 'Switch pets when mounting and dismounting',
			tooltip = 'Checks zone/subzone data and updates your pet when you mount or dismount. Not so useful indoors.',
			getFunc = function() return settings.MountStateChange end,
			setFunc = function(value) 
						settings.MountStateChange = value 
						if value == true then
							EVENT_MANAGER:RegisterForEvent(PetZone.addonVars.addonName, EVENT_MOUNTED_STATE_CHANGED, PetZone.EventMountedStateChanged)
						elseif value == false then
							EVENT_MANAGER:UnregisterForEvent(PetZone.addonVars.addonName,  EVENT_MOUNTED_STATE_CHANGED)
						end
					end,
			default = defaults.MountStateChange,
			width = "full",
		},

    } -- optionsTable
    -- END OF OPTIONS TABLE
    PetZone.LAM:RegisterOptionControls(PetZone.addonVars.addonName .. "_LAM", optionsTable)
end