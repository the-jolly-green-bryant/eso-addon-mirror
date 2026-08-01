function DovahMova_doubleNamesLocations(DovahMova)

	local rsd = DovahMova.Settings.Data
	
	-- Third-party Compatibility
	-- AwesomeGuildStore
	local AGSform1 = "|ca99e83"
	local AGSform2 = "|r"
	
	if DovahMova:IsAddonRunning("AwesomeGuildStore") then
		if AwesomeGuildStore.class.StoreLocationHelper then
			ZO_PreHook(AwesomeGuildStore.class.StoreLocationHelper, "CollectStoresOnCurrentMap", function()
				AGSform1 = ""
				AGSform2 = ""
			end)
			ZO_PreHook(AwesomeGuildStore.class.StoreLocationHelper, "UpdateKioskAndStore", function()
				AGSform1 = ""
				AGSform2 = ""
			end)
			ZO_PostHook(AwesomeGuildStore.class.StoreLocationHelper, "CollectStoresOnCurrentMap", function()
				AGSform1 = "|ca99e83"
				AGSform2 = "|r"
			end)
			ZO_PostHook(AwesomeGuildStore.class.StoreLocationHelper, "UpdateKioskAndStore", function()
				AGSform1 = "|ca99e83"
				AGSform2 = "|r"
			end)
		end
	end
	
	-- EasyTravel
	if DovahMova:IsAddonRunning("EasyTravel") then
		local ShowLocationsBackup
		
		if EasyTravel.PlayerList and EasyTravel.PlayerList.Rebuild then
			ZO_PreHook(EasyTravel.PlayerList, "Rebuild", function()
				ShowLocationsBackup = DovahMova.Settings.ShowLocations
				DovahMova.Settings.ShowLocations = "ua"
			end)
			
			ZO_PostHook(EasyTravel.PlayerList, "Rebuild", function()
				DovahMova.Settings.ShowLocations = ShowLocationsBackup
			end)
		end
		
		if EasyTravel.class and EasyTravel.class.PlayerList and EasyTravel.class.PlayerList.Rebuild then
			ZO_PreHook(EasyTravel.class.PlayerList, "Rebuild", function()
				ShowLocationsBackup = DovahMova.Settings.ShowLocations
				DovahMova.Settings.ShowLocations = "ua"
			end)
			
			ZO_PostHook(EasyTravel.class.PlayerList, "Rebuild", function()
				DovahMova.Settings.ShowLocations = ShowLocationsBackup
			end)
		end
	end

	-- Unboxer
	if DovahMova:IsAddonRunning("Unboxer") then
		local ShowLocationsBackup
		
		if Unboxer.classes.rules.rewards.Solo then
			ZO_PreHook(Unboxer.classes.rules.rewards.Solo, "GetDlcs", function()
				ShowLocationsBackup = DovahMova.Settings.ShowLocations
				DovahMova.Settings.ShowLocations = "ua"
			end)
			
			ZO_PostHook(Unboxer.classes.rules.rewards.Solo, "GetDlcs", function()
				DovahMova.Settings.ShowLocations = ShowLocationsBackup
			end)
		end
	end
	-- Third-party Compatibility
	
	-- Only keep dungeon-related functionality
	LFGDoubleNames(DovahMova)
	
	DovahMova_doubleNamesLocations = nil
end

function LFGDoubleNames(DovahMova)
	local rsd = DovahMova.Settings.Data
	local locationsData = DovahMova_getLocations()  -- Use the complete locations data
	local locs2 = ZO_ACTIVITY_FINDER_ROOT_MANAGER.sortedLocationsData[2] -- Normal Dungeons
	local locs3 = ZO_ACTIVITY_FINDER_ROOT_MANAGER.sortedLocationsData[3] -- Vet Dungeons

	for i = 1, #locs2 do
		local rawName = locs2[i]["rawName"]

		-- Use proper translation lookup with lowercase Ukrainian names
		local translatedName = nil
		local lowercaseName = string.lower(rawName)
		translatedName = locationsData[lowercaseName]

		if not translatedName then
			translatedName = locationsData[ZO_CachedStrFormat("<<z:1>>", lowercaseName)]
		end
		if not translatedName then
			translatedName = locationsData[rawName]
		end
		if not translatedName then
			translatedName = locationsData[ZO_CachedStrFormat("<<z:1>>", rawName)]
		end

		if translatedName then
			local postfix = ""
			if string.match(rawName, " I$") then
				postfix = " I"
				rawName = string.gsub(rawName, " I$", "")
			elseif string.match(rawName, " II$") then
				postfix = " II"
				rawName = string.gsub(rawName, " II$", "")
			end

			-- Get the English name for the base dungeon name (without I/II)
			local englishName = nil
			local baseLowercaseName = string.lower(rawName)
			englishName = locationsData[baseLowercaseName]

			if not englishName then
				englishName = locationsData[ZO_CachedStrFormat("<<z:1>>", baseLowercaseName)]
			end
			if not englishName then
				englishName = locationsData[rawName]
			end
			if not englishName then
				englishName = locationsData[ZO_CachedStrFormat("<<z:1>>", rawName)]
			end

			if englishName then
				translatedName = englishName .. postfix
			end

			if DovahMova.Settings.ShowLocations ~= "ua" then
				locs2[i]["nameKeyboard"] = ZO_CachedStrFormat(SI_ZONE_NAME, locs2[i]["rawName"] .. " (" .. translatedName .. ")")
				locs2[i]["nameGamepad"] = ZO_CachedStrFormat(SI_ZONE_NAME, locs2[i]["rawName"] .. " (" .. translatedName .. ")")
			else
				locs2[i]["nameKeyboard"] = ZO_CachedStrFormat(SI_ZONE_NAME, locs2[i]["rawName"])
				locs2[i]["nameGamepad"] = ZO_CachedStrFormat(SI_ZONE_NAME, locs2[i]["rawName"])
			end
		end
	end
	
	for i = 1, #locs3 do
		local rawName = locs3[i]["rawName"]
		-- Use proper translation lookup with lowercase Ukrainian names
		local translatedName = nil
		local lowercaseName = string.lower(rawName)
		translatedName = locationsData[lowercaseName]

		if not translatedName then
			translatedName = locationsData[ZO_CachedStrFormat("<<z:1>>", lowercaseName)]
		end
		if not translatedName then
			translatedName = locationsData[rawName]
		end
		if not translatedName then
			translatedName = locationsData[ZO_CachedStrFormat("<<z:1>>", rawName)]
		end
		
		if translatedName then
			local postfix = ""
			if string.match(rawName, " I$") then
				postfix = " I"
				rawName = string.gsub(rawName, " I$", "")
			elseif string.match(rawName, " II$") then
				postfix = " II"
				rawName = string.gsub(rawName, " II$", "")
			end
			
			-- Get the English name for the base dungeon name (without I/II)
			local englishName = nil
			local baseLowercaseName = string.lower(rawName)
			englishName = locationsData[baseLowercaseName]

			if not englishName then
				englishName = locationsData[ZO_CachedStrFormat("<<z:1>>", baseLowercaseName)]
			end
			if not englishName then
				englishName = locationsData[rawName]
			end
			if not englishName then
				englishName = locationsData[ZO_CachedStrFormat("<<z:1>>", rawName)]
			end
			if englishName then
				translatedName = englishName .. postfix
			end
			
			if DovahMova.Settings.ShowLocations ~= "ua" then
				if string.find(locs3[i]["nameKeyboard"], "target_veteranRank_icon") then
					locs3[i]["nameKeyboard"] = "|t100%:100%:EsoUI/Art/UnitFrames/target_veteranRank_icon.dds|t " .. ZO_CachedStrFormat(SI_ZONE_NAME, locs3[i]["rawName"] .. " (" .. translatedName .. ")")
				end
				if string.find(locs3[i]["nameGamepad"], "^Ветеранське підземелля") then
					locs3[i]["nameGamepad"] = "Ветеранське підземелля " .. locs3[i]["rawName"] .. " (" .. translatedName .. ")"
				end
			else
				if string.find(locs3[i]["nameKeyboard"], "target_veteranRank_icon") then
					locs3[i]["nameKeyboard"] = "|t100%:100%:EsoUI/Art/UnitFrames/target_veteranRank_icon.dds|t " .. ZO_CachedStrFormat(SI_ZONE_NAME, locs3[i]["rawName"])
				end
				if string.find(locs3[i]["nameGamepad"], "^Ветеранське підземелля") then
					locs3[i]["nameGamepad"] = "Ветеранське підземелля " .. locs3[i]["rawName"]
				end
			end
		end
	end
end
