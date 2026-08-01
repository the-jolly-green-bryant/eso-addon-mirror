if PZ == nil then PZ = {} end
local PetZone = PZ

function PetZone.trimZone2Pet()
--	d("trimming saved pets..")
    local addonVars = PetZone.addonVars
	local tempSettings = {}
    if (PetZone.settingsVars.defaultSettings.saveMode == 1) then
        tempSettings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVariablesName, addonVars.addonSavedVarsVersion , "Settings", defaults)
    elseif (PetZone.settingsVars.defaultSettings.saveMode == 2) then
        tempSettings = ZO_SavedVars:NewCharacterIdSettings(addonVars.addonSavedVariablesName, addonVars.addonSavedVarsVersion, "Settings", defaults)
	end
--	d("Part One:")
	for zone, subzen in pairs(PetZone.settingsVars.settings.zone2Pet) do
--		d(zone)
		for subby, subval in pairs(subzen) do
			if not (subby == "PetId") and (type(subval) == "table") then
				if PetZone.settingsVars.settings.zone2Pet[zone][subby].PetId ~= nil and PetZone.settingsVars.settings.zone2Pet[zone][subby].PetId == 0 then
--					d("removing " .. subby)
					PetZone.settingsVars.settings.zone2Pet[zone][subby] = nil
				elseif PetZone.settingsVars.settings.zone2Pet[zone][subby].PetId ~= nil and PetZone.settingsVars.settings.zone2Pet[zone][subby].PetId ~= 0 then
					PetZone.settingsVars.settings.zone2Pet[zone][subby] = PetZone.settingsVars.settings.zone2Pet[zone][subby].PetId
				end
			elseif not (subby == "PetId") and type(subval) ~= "table" then
				if PetZone.settingsVars.settings.zone2Pet[zone][subby] == 0 then 
--					d("removing " .. subby)
					PetZone.settingsVars.settings.zone2Pet[zone][subby] = nil 
				end
			end
		end
		if PetZone.settingsVars.settings.zone2Pet[zone].PetId ~= nil and PetZone.settingsVars.settings.zone2Pet[zone].PetId == 0 then
			PetZone.settingsVars.settings.zone2Pet[zone].PetId = nil
		end
		if next(subzen) == nil then
--			d("removing " .. zone)
			PetZone.settingsVars.settings.zone2Pet[zone] = nil
		end
	end
	if tempSettings.zone2Pet ~= nil then
--		d("Part Two:")
		for zone, subzen in pairs(tempSettings.zone2Pet) do
--			d(zone)
			for subby, subval in pairs(subzen) do
				if not (subby == "PetId") and (type(subval) == "table") then
					if tempSettings.zone2Pet[zone][subby].PetId ~= nil and tempSettings.zone2Pet[zone][subby].PetId == 0 then
--						d("removing " .. subby)
						tempSettings.zone2Pet[zone][subby] = nil
					elseif tempSettings.zone2Pet[zone][subby].PetId ~= nil and tempSettings.zone2Pet[zone][subby].PetId ~= 0 then
						tempSettings.zone2Pet[zone][subby] = tempSettings.zone2Pet[zone][subby].PetId
					end
				elseif not (subby == "PetId") and type(subval) ~= "table" then
					if tempSettings.zone2Pet[zone][subby] == 0 then 
--						d("removing " .. subby)
						tempSettings.zone2Pet[zone][subby] = nil 
					end
				end
			end
			if tempSettings.zone2Pet[zone].PetId ~= nil and tempSettings.zone2Pet[zone].PetId == 0 then
				tempSettings.zone2Pet[zone].PetId = nil
			end
			if next(subzen) == nil then
--				d("removing " .. zone)
				tempSettings.zone2Pet[zone] = nil
			end
		end
	end
--	d("done trimming")
end

--Read the SavedVariables
function PetZone.getSettings()
    local addonVars = PetZone.addonVars
    --The default values for the language and save mode
    local defaultsSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide settings
    }

    --Pre-set the deafult values
    local defaults = {
        alwaysUseClientLanguage		= true,
        zone2Pet                  = {},
        autoPresetForZoneOnNewPet = false,
		WeaponSwapChange = false,
		MountStateChange = false,
		HideInCombat = false,
		CheckForInfo = false,
		HideInDungeons = false,
		HideInGroups = false,
		HideInStealth = false,
--		InfoDump = nil,
--		InfoZDump = nil,
		CustRandLists = {},
		ExList = {},
    }
    PetZone.settingsVars.defaults = defaults

    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    --Load the user's settings from SavedVariables file -> Character settings to determine account-wide or character only
    PetZone.settingsVars.defaultSettings = ZO_SavedVars:NewCharacterIdSettings(addonVars.addonSavedVariablesName, 999, "SettingsForAll", defaultsSettings)

    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    if (PetZone.settingsVars.defaultSettings.saveMode == 1) then
        PetZone.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(addonVars.addonSavedVariablesName, addonVars.addonSavedVarsVersion , "Settings", defaults)
    elseif (PetZone.settingsVars.defaultSettings.saveMode == 2) then
        PetZone.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVariablesName, addonVars.addonSavedVarsVersion, "Settings", defaults)
    else
        PetZone.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVariablesName, addonVars.addonSavedVarsVersion, "Settings", defaults)
    end
    --=============================================================================================================
	PetZone.trimZone2Pet()
end

--Save the chosen Pet number PetId from the LAM settings to the SavedVariables. The boolean parameter activatePet
--will activate the chosen Pet directly
function PetZone.SavePetIdToSettings(PetId, activatePet, zone, subZone)
    activatePet = activatePet or false
--d("PetZone.SavePetIdToSettings - PetId: " ..tostring(PetId)  .. " (" .. ZO_CachedStrFormat("<<C:1>>", GetCollectibleInfo(PetId)) .. "), activatePet: " .. tostring(activatePet) .. ", zone: " ..tostring(zone) .. ", subZone: " .. tostring(subZone))
    local settings = PetZone.settingsVars.settings
    local doCheckIfActivatePetNow = false
    local subZoneToUse
    -- Is the zone and the subzone given, and is the subzone a special subzone, and not any (all in the zone = -ALL-) or none (-NONE-)
	if zone ~= nil and zone ~= "" and type(subZone) == "table" then --(subZone ~= nil and subZone ~= "" and subZone ~= PZ_NONE_ENTRIES and subZone ~= PZ_ALL_ENTRIES)
--d(">zone & subZone saving, zone: " ..tostring(zone) .. ", subZone: " .. tostring(subZone) ..", PetId: " .. tostring(PetId) .. " (" .. ZO_CachedStrFormat("<<C:1>>", GetCollectibleInfo(PetId)) .. ")")
		for _, subId in pairs(subZone) do
			if settings.zone2Pet[zone] == nil then settings.zone2Pet[zone] = {} end
			if PetId == 0 then
				settings.zone2Pet[zone][subId] = nil
			else
				settings.zone2Pet[zone][subId] = PetId
			end
			subZoneToUse = subId
			doCheckIfActivatePetNow = true
			--d("Saving to: " ..subId)
		end
		if next(settings.zone2Pet[zone]) == nil then settings.zone2Pet[zone] = nil end
	elseif zone ~= nil and zone ~= "" and type(subZone) ~= "table" and (subZone ~= nil and subZone ~= "" and subZone ~= PZ_NONE_ENTRIES and subZone ~= PZ_ALL_ENTRIES) then
		for subName, subIds in pairs(PetZone.IdByName[zone]) do
			if PZ.tableContains(subIds, subZone, true) then
				for _, subId in pairs(subIds) do
					if settings.zone2Pet[zone] == nil then settings.zone2Pet[zone] = {} end
					if PetId == 0 then
						settings.zone2Pet[zone][subId] = nil
					else
						settings.zone2Pet[zone][subId] = PetId
					end
					subZoneToUse = subId
					doCheckIfActivatePetNow = true
				end
				if next(settings.zone2Pet[zone]) == nil then settings.zone2Pet[zone] = nil end
				break
			end
		end
    -- Is the zone given, and is the zone not -NONE-, and is no subzone given or the subzone is -ALL-
    elseif zone ~= nil and zone ~= "" and zone ~= PZ_NONE_ENTRIES then
        --Subzone is given but -ALL-)?
        if      (PetZone.subZone ~= nil and subZone == PZ_ALL_ENTRIES)
            or  (PetZone.subZone == nil) then
--d(">zone saving, zone: " ..tostring(zone) .. ", PetId: " .. tostring(PetId) .. " (" .. ZO_CachedStrFormat("<<C:1>>", GetCollectibleInfo(PetId)) .. ")")
            if settings.zone2Pet[zone] == nil then settings.zone2Pet[zone] = {} end
            if PetId == 0 then
				settings.zone2Pet[zone].PetId = nil
			else
				settings.zone2Pet[zone].PetId = PetId
			end
			if next(settings.zone2Pet[zone]) == nil then settings.zone2Pet[zone] = nil end
            doCheckIfActivatePetNow = true
        end
    end
    --Activate the Pet for the current zone & subzone
    if doCheckIfActivatePetNow and activatePet then
--d(">Activating Pet now")
        PetZone.ActivatePetForZone(zone, subZoneToUse)
    end
end

--Load the Pet number from the SavedVariables
function PetZone.LoadPetIdFromSettings(zone, subZone)
    local settings = PetZone.settingsVars.settings
    local chosenPetId = 0
    if zone ~= PZ_NONE_ENTRIES and subZone ~= PZ_NONE_ENTRIES then
        if settings.zone2Pet[zone] ~= nil then
            if subZone ~= PZ_ALL_ENTRIES then
                if settings.zone2Pet[zone][subZone] ~= nil then
					chosenPetId = settings.zone2Pet[zone][subZone]
                end
            elseif settings.zone2Pet[zone].PetId then
                chosenPetId = settings.zone2Pet[zone].PetId
            end
        end
    end
    return chosenPetId
end