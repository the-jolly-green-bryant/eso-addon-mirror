function RuESO_doubleNamesNPC(RuESO)
	
	if RuESO_doubleNamesBoth then
		RuESO_doubleNamesBoth(RuESO)
	end

	local GetUnitNameOld = GetUnitName

	function GetUnitName(target)
		
		local currentNpcName = GetUnitNameOld(target)
		local newNpcName
		
		if (not target or target == "player" or RuESO.Settings.ShowNPC == "ru" or currentNpcName == nil or currentNpcName == "") then
			return currentNpcName
		end
		
		if (target == "reticleover") then
			if (not DoesUnitExist("reticleover") or IsUnitPlayer("reticleover")) then return currentNpcName end
		end
		
		-- LibCombat
		if (LibCombat ~= nil and target:match("^boss%d+$") ~= nil) then
			return currentNpcName
		end
		
		newNpcName = npcNames[zo_strlower(currentNpcName)]
			
		if newNpcName ~= nil then
			if (RuESO.Settings.ShowNPC == "ruen") then
				currentNpcName = currentNpcName .. " (" .. newNpcName .. ")"
			elseif (RuESO.Settings.ShowNPC == "enru") then
				currentNpcName = newNpcName .. " (" .. currentNpcName .. ")"
			else
				currentNpcName = newNpcName
			end
		end
			
		return currentNpcName
	end
	
	local GetMapLocationTooltipLineInfoOld = GetMapLocationTooltipLineInfo
	
	function GetMapLocationTooltipLineInfo(...)
		local icon, name, groupingId, categoryName = GetMapLocationTooltipLineInfoOld(...)
		
		if (name == nil or RuESO.Settings.ShowNPC == "ru") then
			return icon, name, groupingId, categoryName
		end
		
		newNpcName = npcNames[zo_strlower(name)]
			
		if newNpcName ~= nil then
			if (RuESO.Settings.ShowNPC == "ruen") then
				name = name .. "\n|ca99e83" .. newNpcName .. "|r"
			elseif (RuESO.Settings.ShowNPC == "enru") then
				name = newNpcName .. "\n|ca99e83" .. name .. "|r"
			else
				name = newNpcName
			end
		end
			
		return icon, name, groupingId, categoryName
	end
	
	RuESO_doubleNamesNPC = nil
end