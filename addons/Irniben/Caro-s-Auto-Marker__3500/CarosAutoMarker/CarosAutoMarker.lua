CarosAutoMarker = {
	name = "CarosAutoMarker",
}

local GS = GetString

local currentLocationId = false
local currentLocationData = {}
local savedLocationData = {}
local allowMarking = true

local function onReticleChange()
	if GetUnitTargetMarkerType("reticleover") ~= 0 then return end
	if not IsUnitAttackable("reticleover") then return end
	if GetUnitDifficulty("reticleover") == MONSTER_DIFFICULTY_NONE then return end
	local theName = GetUnitName("reticleover") 
	local nameLower = string.lower(theName)
	if theName == "" then return end
	if currentLocationData[nameLower] then
		AssignTargetMarkerToReticleTarget(currentLocationData[nameLower][1])
		table.insert(currentLocationData[nameLower], currentLocationData[nameLower][1])
		table.remove(currentLocationData[nameLower], 1)
	elseif savedLocationData.doRecord and savedLocationData.enemies[theName] == nil then
		savedLocationData.enemies[theName] = {}
	end
	
end

local function refreshCurrentLocation()
	currentLocationData = {}
	savedLocationData = CarosAutoMarker.sV.locations[currentLocationId] or {}
	local enemyData = savedLocationData.enemies or {}
	
	-- otherwise it will stay false and we only get the empty table to work with locally
	if savedLocationData.doRecord then savedLocationData.enemies = enemyData end 
	
	for i, v in pairs(enemyData) do
		if v then
			local someEnemy = {}
			for j, w in pairs(v) do
				if w then table.insert(someEnemy, j) end
			end
			currentLocationData[string.lower(i)] = someEnemy
		else
			currentLocationData[string.lower(i)] = nil
		end
	end
	EVENT_MANAGER:UnregisterForEvent(CarosAutoMarker.name.."ReticleChange", EVENT_RETICLE_TARGET_CHANGED, onReticleChange)
	EVENT_MANAGER:RegisterForEvent(CarosAutoMarker.name.."ReticleChange", EVENT_RETICLE_TARGET_CHANGED, onReticleChange)
end

local function onPlayerActivate()
	local newLocationId = GetUnitWorldPosition("player")
	if newLocationId ~= currentLocationId then
		currentLocationId = newLocationId
		refreshCurrentLocation()
	end
end

local function refreshGroupLeader()
	local oldSetting = allowMarking
	if CarosAutoMarker.sV.onlyAsLeader and IsUnitGrouped("player") and not IsUnitGroupLeader("player") then
		allowMarking = false
	else
		allowMarking = true
	end
	if oldSetting ~= allowMarking then refreshCurrentLocation() end
end

local function refreshLocations()
	local locationNames = {}
	local locationIds = {}
	
	for i, _ in pairs(CarosAutoMarker.sV.locations) do
		if type(i) == "number" then
			table.insert(locationIds, i)
			table.insert(locationNames, zo_strformat("<<C:1>>", GetZoneNameById(i)))
		end
	end
	
	return locationNames, locationIds
end

local function CAMInit()
	-- Setup the SavedVars
	CarosAutoMarker.sV = ZO_SavedVars:NewAccountWide("CarosAutoMarkerSavedVariables", 1, nil, {}) -- account wide
	CarosAutoMarker.sV.onlyAsLeader = CarosAutoMarker.sV.onlyAsLeader == nil or CarosAutoMarker.sV.onlyAsLeader
	CarosAutoMarker.sV.locations = CarosAutoMarker.sV.locations or {}
	local locationData = CarosAutoMarker.sV.locations
	
	local hasNames = {en = true, fr = true, de = true}
	local addNames = hasNames[string.lower(GetCVar("Language.2"))] or false
	
	for i, v in pairs(CarosAutoMarker.PreSetEnemies) do
		locationData[i] = locationData[i] or { doRecord = addNames }
		locationData[i].enemies = locationData[i].enemies or {}
		if addNames then
			for j, w in pairs(v) do
				locationData[i].enemies[w] = locationData[i].enemies[w] or {}
			end
		end
	end
	
	local locationNames, locationIds = refreshLocations()
	
	local markerIcons = {
		"target_blue_square",
		"target_gold_star",
		"target_green_circle",
		"target_orange_triangle",
		"target_pink_moons",
		"target_purple_oblivion",
		"target_red_weapons",
		"target_white_skull",
	}
	
	local panelName = "Caro's Auto Marker"
	local panelData = {
		type = "panel",
		name = panelName,
		displayName = "|c9e0911Caro|r's  Auto Marker",
		author = "|c1d6dadIrniben|r",
		registerForRefresh = true,
    }
	
	local changedAnything = false
	
	local hasPlayerChosenLocationToEdit = false
	local locationToEdit = false -- will be set to a string
	local locationDataToEdit = false -- will be set to a table
	
	local enemyNameToEdit = false -- will be set to a string
	local enemyDataToEdit = false -- will be set to a table
	
	local enemyNames = {}	-- record all enemy names
	local enemyDisplayNames = {}	-- add current marker icons to the name
	
	local function updateEnemyList()
		enemyNames = {}
		enemyDisplayNames = {}
		if not locationDataToEdit then return {}, {} end
		locationDataToEdit.enemies = locationDataToEdit.enemies or {}
		for i, v in pairs(locationDataToEdit.enemies) do
			table.insert(enemyNames, i)
			local myIcons = {}
			local myDisplayName = i
			if type(v) == "table" then
				for j, w in pairs(v) do
					if w then
						table.insert(myIcons, string.format("|t24:24:esoui/art/compass/%s.dds|t", markerIcons[j]))
					end
				end
				if #myIcons > 0 then
					myDisplayName = string.format("%s (%s)", i, table.concat(myIcons, ", "))
				end
			end
			table.insert(enemyDisplayNames, myDisplayName) 
		end
		return enemyDisplayNames, enemyNames
	end
		
	local function setEnemy()
	
	end
	
	local function setLocation(locationId, initSelection, notUserSelected)
		enemyDataToEdit = false
		enemyNameToEdit = false
		hasPlayerChosenLocationToEdit = not initSelection
		locationToEdit = locationId
		locationData[locationToEdit] = locationData[locationToEdit] or { doRecord = true }
		locationDataToEdit = locationData[locationToEdit]
		if CarosAutoMarkerLAM_LocationHeading then 
			CarosAutoMarkerLAM_LocationHeading.data.name = zo_strformat("<<C:1>>", GetZoneNameById(locationToEdit)) 
			CarosAutoMarkerLAM_LocationHeading:UpdateValue()
		end
		if CarosAutoMarkerLAM_EnemyDropdown then 
			CarosAutoMarkerLAM_EnemyDropdown:UpdateChoices(updateEnemyList())
		end
		if CarosAutoMarkerLAM_LocationDropdown and notUserSelected then
			CarosAutoMarkerLAM_LocationDropdown.dropdown:SetSelectedItemText(zo_strformat("<<C:1>>", GetZoneNameById(locationId)))
		end
	end
	
	setLocation(638, true, true) --sets to AA as default
	
	local optionsData = {
		{
			type = "checkbox",
			name = GS(CaroAM_OnlyAsGroupLeader),
			tooltip = GS(CaroAM_OnlyAsGroupLeaderTT),
			width = "full",
			default = false,
			getFunc = function() return CarosAutoMarker.sV.onlyAsLeader end,
			setFunc = function(value) CarosAutoMarker.sV.onlyAsLeader = value refreshGroupLeader() end,
		},		
		{
			type = "dropdown",
			name = GS(CaroAM_LocationDropdown),
			width = "half",
			choices = locationNames,
			choicesValues = locationIds,
			sort = "name-up",
			default = false,
			getFunc = function() return locationToEdit end,
			setFunc = function(value) 
				setLocation(value)
			end,
			reference = "CarosAutoMarkerLAM_LocationDropdown",
			disabled = function() 
				return false 
			end, 
		},
		{
			type = "button",
			name = GS(CaroAM_LocationAddCurrent),
			width = "half",
			func = function() 
				if GetCurrentZoneHouseId() ~= 0 or GetCurrentZoneDungeonDifficulty() == 0 then 
					d(GS(CaroAM_OnlyTrialsAndDungeons)) 
					return 
				end
				local zoneId = GetUnitWorldPosition("player")
				locationData[zoneId] = locationData[zoneId] or { doRecord = true }
				CarosAutoMarkerLAM_LocationDropdown:UpdateChoices(refreshLocations())
				CarosAutoMarkerLAM_LocationDropdown.dropdown:SetSelectedItemText(zo_strformat("<<C:1>>", GetZoneNameById(i)))
				changedAnything = true
				setLocation(zoneId)
			end,
		},
		{
			type = "header",
			name = "", 
			width = "full",
			reference = "CarosAutoMarkerLAM_LocationHeading"
		},
		{
			type = "description",
			text = GS(CaroAM_ExplainNames), 
			width = "full", 
		},
		{
			type = "dropdown",
			name = GS(CaroAM_EnemyDropdown),
			width = "full",
			choices = enemyDisplayNames,
			choicesValues = enemyNames,
			sort = "name-up",
			default = false,
			getFunc = function() return enemyNameToEdit or "" end,
			setFunc = function(value) 
				enemyNameToEdit = value
				locationDataToEdit.enemies = locationDataToEdit.enemies or {}
				locationDataToEdit.enemies[enemyNameToEdit] = locationDataToEdit.enemies[enemyNameToEdit] or {}
				enemyDataToEdit = locationDataToEdit.enemies[enemyNameToEdit]
			end,
			reference = "CarosAutoMarkerLAM_EnemyDropdown",
			disabled = function() return false end, -- refresh choices here
		},
		{
			type = "button",
			name = GS(CaroAM_EnemyAddName),
			width = "half",
			func = function() 
				ESO_Dialogs["CaroAM_RenameDialog"] = ESO_Dialogs["CaroAM_RenameDialog"] or {
					canQueue = true,
					uniqueIdentifier = "CaroAM_RenameDialog",
					title = {text = GS(CaroAM_EnemyAddName)},
					mainText = {text = GS(CaroAM_EnemyAddNameDiag)},
					editBox = {},
					buttons = {
						[1] = {
							text = SI_DIALOG_CONFIRM,
							callback = function(dialog)
								if not locationDataToEdit then return end
								local txt = ZO_Dialogs_GetEditBoxText(dialog)
								if txt ~= "" then 
									locationDataToEdit.enemies = locationDataToEdit.enemies or {}
									locationDataToEdit.enemies[txt] = locationDataToEdit.enemies[txt] or {}
									CarosAutoMarkerLAM_EnemyDropdown:UpdateChoices(updateEnemyList())
									enemyNameToEdit = txt
									CarosAutoMarkerLAM_EnemyDropdown.dropdown:SetSelectedItemText(txt)
									enemyDataToEdit = locationDataToEdit.enemies[txt]
								end
							end,
						},
						[2] = {
							text = SI_DIALOG_CANCEL,
							callback = function() end,
						},
						},
					setup = function() end,
				}
				ZO_Dialogs_ShowDialog("CaroAM_RenameDialog", {}, {mainTextParams = {}, initialEditText = ""})
			end,
		},
		{
			type = "button",
			name = GS(CaroAM_EnemyRemoveName),
			width = "half",
			func = function() 
				if not enemyNameToEdit or enemyNameToEdit == "" then return end
				locationDataToEdit.enemies[enemyNameToEdit] = nil
				CarosAutoMarkerLAM_EnemyDropdown:UpdateChoices(updateEnemyList())
				enemyNameToEdit = false
				enemyDataToEdit = false
				changedAnything = true
			end,
			disabled = function() return not enemyNameToEdit or enemyNameToEdit == "" end,		
		},
		{
			type = "checkbox",
			name = GS(CaroAM_EnemyRecordNames),
			width = "full",
			default = false,
			getFunc = function() 
				if locationDataToEdit and locationDataToEdit.doRecord ~= nil then 
					return locationDataToEdit.doRecord 
				else 
					return true 
				end 
			end,
			setFunc = function(value) locationDataToEdit.doRecord = value changedAnything = true end,
			disabled = function() return not locationDataToEdit end,
		},		
		
		{
			type = "divider",
			width = "full",
		},
		--[[
		{
			type = "description",
			text = GS(CPC_LAM_GeneralDescr), 
			width = "full", 
			
		},
		]]--
	}	
	
	for i, v in pairs(markerIcons) do
		local optCtrName = string.format("|t28:28:esoui/art/compass/%s.dds|t (%s)", v, i)
		table.insert(optionsData,
			{
				type = "checkbox",
				name = optCtrName,
				width = "half",
				default = false,
				getFunc = function() 
					if not enemyDataToEdit then return false end
					return enemyDataToEdit[i] 
				end,
				setFunc = function(value) 
					if not enemyDataToEdit then return end
					enemyDataToEdit[i] = value
					CarosAutoMarkerLAM_EnemyDropdown:UpdateChoices(updateEnemyList())
					changedAnything = true
				end,
				disabled = function() 
					if enemyDataToEdit then 
						local optControl = GetControl(string.format("CarosAutoMarkerLAM_MarkerCheckbox%s", i))
						if optControl then
							local otherEnemies = {}
							for someEnemyName, someEnemyData in pairs(locationDataToEdit.enemies) do
								if someEnemyName ~= enemyNameToEdit then
									if type(someEnemyData) == "table" and someEnemyData[i] then 
										table.insert(otherEnemies, someEnemyName)
									end
								end
							end
							if #otherEnemies > 0 then
								optControl.label:SetText(string.format("%s |t24:24:esoui/art/miscellaneous/new_icon.dds:inheritcolor|t", optCtrName))
								optControl.data.tooltipText = table.concat(otherEnemies, ", ")
							else
								optControl.label:SetText(optCtrName)
								optControl.data.tooltipText = nil
							end
							--optControl:UpdateValue()
						end
						return false
					else
						return true
					end
				end,
				reference = string.format("CarosAutoMarkerLAM_MarkerCheckbox%s", i),
			}
		)
	end
		
	local LAM = LibAddonMenu2
	
    local myPanel = LAM:RegisterAddonPanel("CarosAutoMarkerOptions", panelData)
	LAM:RegisterOptionControls("CarosAutoMarkerOptions", optionsData)
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
		if panel ~= myPanel then return end
		local function resizeCheckbox(optControl)
			optControl:SetHeight(30)
			optControl.container:SetAnchor(TOPRIGHT, optControl, TOPRIGHT, 0, 0)
			optControl.label:SetAnchor(TOPLEFT, optControl, TOPLEFT, 0, 0)
			optControl.label:SetAnchor(TOPRIGHT, optControl.container, TOPLEFT, 5, 0)
		end
		for i, v in pairs(markerIcons) do
			local optControl = GetControl(string.format("CarosAutoMarkerLAM_MarkerCheckbox%s", i))
			if optControl then resizeCheckbox(optControl) end
		end
	end)
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel ~= myPanel then return end
		if not hasPlayerChosenLocationToEdit then
			local zoneId = GetUnitWorldPosition("player")
			if locationData[zoneId] then setLocation(zoneId, false, true) end
		end
		CarosAutoMarkerLAM_EnemyDropdown:UpdateChoices(updateEnemyList())
		changedAnything = false
	end)
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
		-- cleanup empty tables
		if panel ~= myPanel then return end
		for someLocationId, someLocationData in pairs(locationData) do
			if someLocationData.enemies then
				local anyEnemyActive = false
				for someEnemyName, someEnemyData in pairs(someLocationData.enemies) do
					if someEnemyData then
						local anyMarkerActive = false
						for i, v in pairs(someEnemyData) do
							if v then anyMarkerActive = true break end
						end
						if not anyMarkerActive then
							someLocationData.enemies[someEnemyName] = false
						else
							anyEnemyActive = true
						end
					end
				end
				someLocationData.active = anyEnemyActive
			end
		end
		if changedAnything then refreshCurrentLocation() end
	end)

	EVENT_MANAGER:UnregisterForEvent(CarosAutoMarker.name.."OnLoad", EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(CarosAutoMarker.name.."OnActivate", EVENT_PLAYER_ACTIVATED, onPlayerActivate)
	EVENT_MANAGER:RegisterForEvent(CarosAutoMarker.name.."OnLeaderUpdate", EVENT_LEADER_UPDATE, refreshGroupLeader) 
end

local function CAMOnAddonLoaded(event, addonName)
  if addonName == CarosAutoMarker.name then
    CAMInit()
  end
end

EVENT_MANAGER:RegisterForEvent(CarosAutoMarker.name.."OnLoad", EVENT_ADD_ON_LOADED, CAMOnAddonLoaded)