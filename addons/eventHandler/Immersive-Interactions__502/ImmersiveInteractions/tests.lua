-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --

do
	-- make sure the caller has an active conversation
	-- return false if the conversation is valid; return true if there is a problem
	function ImmersiveFunctions.IsInvalid()
		local actType = GetInteractionType()

		return not (actType == INTERACTION_CONVERSATION or actType == INTERACTION_QUEST)
	end

	function ImmersiveFunctions.IsValid()
		return not ImmersiveFunctions.IsInvalid()
	end

	function ImmersiveFunctions.IsHidden()
		local handles = ImmersiveFunctions.GetData("handles")
		for k, v in pairs(handles) do
			if v:IsHidden() then return true end
		end

		return false
	end

	function ImmersiveFunctions.CheckHiding()
		return ImmersiveFunctions.NoAudio() or ImmersiveFunctions.GetData("bService")
	end

	function ImmersiveFunctions.IsPvPZone()
		local zone = GetUnitZone("interact")
		if zone == "Cyrodiil" or zone == "Imperial City" or zone == "Imperial Sewers" then
			return true
		end
	end

	-- check if the name of the NPC/interactable is known to lack audio
	-- return true on match found; return false otherwise
	function ImmersiveFunctions.NoAudio()
		-- debug code
		if ImmersiveFunctions.Debug() then
			-- debug weird Vvardenfal names
			if not GetUnitName("interact"):find(GetUnitName("interact")) then
				df("IMMINT::ERROR::GetUnitName(\"interact\")::")
				df("IMMINT::TYPE::string contains non-valid formatting::")
				df(tostring("IMMINT::TARGET::\""..GetUnitName("interact").."\"::"))
			end

			-- debug zones
			if ImmersiveFunctions.Debug("filter") then
				d(GetUnitZone("interact"))
			end
		end

		-- PvP zones
		if ImmersiveFunctions.GetSetting("bAlwaysShowPvP") and ImmersiveFunctions.IsPvPZone() then
			return true
		end

		local unitName = GetUnitName("interact")

		-- check against table of known repeatable interactions
		if ImmersiveFunctions.GetSetting("bSkipDaily") then
			local skipDaily = ImmersiveFunctions.GetData("skipDaily")
			for k, v in pairs(skipDaily) do
				if unitName:find(v) then return true end
			end
		end

		-- check against table of known interactions to not have audio
		local skipTitles = ImmersiveFunctions.GetData("skipTitles")
		for k, v in pairs(skipTitles) do
			if unitName:find(v) then return true end
		end

		-- check against pattern of known interactions to not have audio
		local bodyText = ImmersiveFunctions.GetData("bodyText")
		if (bodyText:sub(1,1) == '<' and bodyText:sub(-1) == '>') then return true end
		if (bodyText:sub(1,1) == '"' and bodyText:sub(-1) == '"') then return true end

		return false
	end
end
