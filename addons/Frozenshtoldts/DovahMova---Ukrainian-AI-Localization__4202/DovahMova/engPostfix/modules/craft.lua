function DovahMova_doubleNamesBoth(DovahMova)
	local GetGameCameraInteractableActionInfoOld = GetGameCameraInteractableActionInfo
	local prevInteractCraftEn = ""
	local prevInteractCraftUa = ""
	
	function GetGameCameraInteractableActionInfo(...)		
		local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfoOld()
		local newCraftName, settingType
		
		if action == GetString(SI_GAMECAMERAACTIONTYPE5) then
			settingType = DovahMova.Settings.ShowCraft
		else
			return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
		end
		
		if not settingType or settingType == "ua" or interactableName == nil then
			return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
		end
		
		-- Handle craft station interactions
		local uaName = string.match(interactableName, "%((.*)%)$")
		
		if interactableName == prevInteractCraftUa then
			newCraftName = prevInteractCraftEn
		else				
			if uaName and DovahMova.Settings.Data.SetsNames[zo_strlower(uaName)] then
				newCraftName = DovahMova.Settings.Data.SetsNames[zo_strlower(uaName)]
			end
			
			if newCraftName == nil then
				return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
			end
				
			if interactableName ~= nil then
				prevInteractCraftEn = newCraftName
				prevInteractCraftUa = interactableName
			end
		end
		
		if newCraftName ~= interactableName and uaName then
			local firstPart = string.match(interactableName, "^(.*) %(")
			
					if settingType == "uaen" then
			interactableName = string.format("%s (%s — %s)", firstPart, uaName, DovahMova.Settings.Data.SetsNames[zo_strlower(uaName)])
		else
			interactableName = string.format("%s (%s)", firstPart, DovahMova.Settings.Data.SetsNames[zo_strlower(uaName)])
		end
		end
		
		return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
	end
	
	-- Don't set the function to nil - it needs to be callable from settings
end
