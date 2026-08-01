local CPR2 = ChampionPointRespecV2 or {}

CPR2.importedHash= ""

function CPR2.DisplayExportWindow()
	ExportWindowTitle:SetText(CPR2.savedVariables.specs[CPR2.configSelected].name.." hash:")
	ExportWindowEditBoxBGEditBox:SetText(CPR2.savedVariables.specs[CPR2.configSelected].hash)
	ExportWindow:SetHidden(false)
end

function CPR2.ImportHash(hash)
	d("importing config...")
	if CPR2.IsValidHash(hash) then
		d("hash is valid")
		CPR2.importedHash = hash;
		zo_callLater(function () ZO_Dialogs_ShowDialog("CPR2_IMPORT_CONFIG_NAME", nil, nil) end, 100)
	else 
		d(hash.." is not a valid hash.")
	end
end

function CPR2.IsValidHash(hash)
	if string.len(hash) ~= 72 then d("hash is too long or short") return false end
	local counter = 1
	for discipline = 1, GetNumChampionDisciplines() do
		for skill = 1, GetNumChampionDisciplineSkills() - 4 do																								
			if (CPR2.GetBase10(string.sub(hash, counter, counter + 1)) == nil) then
				return false
			end
			counter = counter + 2
		end
	end
	return true
end