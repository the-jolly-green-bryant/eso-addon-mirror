function RuESO_doubleNamesBoth(RuESO)
	local GetGameCameraInteractableActionInfoOld = GetGameCameraInteractableActionInfo
	local prevInteractNpcEn = ""
	local prevInteractNpcRu = ""
	
	function GetGameCameraInteractableActionInfo(...)		
		local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfoOld()
		local newNpcName, temp1, temp2, interactionType, settingType
		
		if action == GetString(SI_GAMECAMERAACTIONTYPE2) or action == GetString(SI_GAMECAMERAACTIONTYPE21) or action == GetString(SI_GAMECAMERAACTIONTYPE1) or action == GetString(SI_GAMECAMERAACTIONTYPE7) then
			interactionType = "npc"
			settingType = RuESO.Settings.ShowNPC
		elseif action == GetString(SI_GAMECAMERAACTIONTYPE5) then
			interactionType = "craft"
			settingType = RuESO.Settings.ShowCraft
		end
		
		if not settingType or settingType == "ru" or interactableName == nil then
			return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
		end
		
		if interactionType == "npc" then
			if interactableName == prevInteractNpcRu then
				newNpcName = prevInteractNpcEn
			else
				newNpcName = npcNames[zo_strlower(interactableName)]
				
				if newNpcName == nil then
					return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
				end
					
				if interactableName ~= nil then
					prevInteractNpcEn = newNpcName
					prevInteractNpcRu = interactableName
				end
			end
			
			if newNpcName ~= interactableName then
				if settingType == "ruen" then
					interactableName = ZO_CachedStrFormat(SI_ZONE_NAME, interactableName) .. "\n" .. newNpcName
				elseif (settingType == "enru") then
					interactableName = newNpcName .. "\n" .. ZO_CachedStrFormat(SI_ZONE_NAME, interactableName)
				else
					interactableName = newNpcName
				end
			end
		elseif interactionType == "craft" then
			local ruName = string.match(interactableName, "%((.*)%)$")
			
			if interactableName == prevInteractNpcRu then
				newNpcName = prevInteractNpcEn
			else				
				if ruName and RuESO.Settings.Data.SetsNames[zo_strlower(ruName)] then
					newNpcName = RuESO.Settings.Data.SetsNames[zo_strlower(ruName)] -- RuESO:MagicReplace(interactableName, ruName, RuESO.Settings.Data.SetsNames[zo_strlower(ruName)])
				end
				
				if newNpcName == nil then
					return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
				end
					
				if interactableName ~= nil then
					prevInteractNpcEn = newNpcName
					prevInteractNpcRu = interactableName
				end
			end
			
			if newNpcName ~= interactableName and ruName then
				local firstPart = string.match(interactableName, "^(.*) %(")
				
				if settingType == "ruen" then
					interactableName = string.format("%s (%s — %s)", firstPart, ruName, RuESO.Settings.Data.SetsNames[zo_strlower(ruName)])
				elseif (settingType == "enru") then
					interactableName = string.format("%s (%s — %s)", firstPart, RuESO.Settings.Data.SetsNames[zo_strlower(ruName)], ruName)
				else
					interactableName = string.format("%s (%s)", firstPart, RuESO.Settings.Data.SetsNames[zo_strlower(ruName)])
				end
			end
		end
		
		return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
	end
	
	RuESO_doubleNamesBoth = nil
end