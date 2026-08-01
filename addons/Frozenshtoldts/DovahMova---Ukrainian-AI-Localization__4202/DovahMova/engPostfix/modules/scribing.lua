function DovahMova_doubleNamesScribing(DovahMova)
	if DovahMova:GetLanguage() == "ua" then
		local rsd = DovahMova.Settings.Data
		
		-- Hook scribing script name functions
		local GetCraftedAbilityScriptDisplayNameOld = GetCraftedAbilityScriptDisplayName
		function GetCraftedAbilityScriptDisplayName(scriptId)
			local scriptName = GetCraftedAbilityScriptDisplayNameOld(scriptId)
			
			if (scriptName == nil or DovahMova.Settings.ShowScribing == "ua") then
				return scriptName
			end
			
			-- Look for English name in the data
			local englishName = rsd.ScribingScripts and rsd.ScribingScripts[scriptId]
			
			if englishName ~= nil then
				if DovahMova.Settings.ShowScribing == "uaen" then
					scriptName = scriptName .. " (" .. englishName .. ")"
				else
					scriptName = englishName
				end
			end
			
			return scriptName
		end
		

		
		-- Hook scribing UI elements
		if ZO_Scribing then
			-- Hook scribing script list entries
			local originalSetupScribingScriptEntry = ZO_Scribing.SetupScriptEntry
			if originalSetupScribingScriptEntry then
				ZO_Scribing.SetupScriptEntry = function(self, control, scriptData)
					originalSetupScribingScriptEntry(self, control, scriptData)
					
					local scriptId = scriptData.scriptId
					if scriptId then
						local scriptName = GetCraftedAbilityScriptDisplayNameOld(scriptId)
						if scriptName then
							local englishName = rsd.ScribingScripts and rsd.ScribingScripts[scriptId]
							if englishName and DovahMova.Settings.ShowScribing ~= "ua" then
								local finalName
								if DovahMova.Settings.ShowScribing == "uaen" then
									finalName = scriptName .. " (" .. englishName .. ")"
								else
									finalName = englishName
								end
								
								local nameControl = control:GetNamedChild("Name")
								if nameControl then
									nameControl:SetText(DovahMova:MagicReplace(nameControl:GetText(), scriptName, finalName))
								end
							end
						end
					end
				end
			end
		end
		

	end
end
