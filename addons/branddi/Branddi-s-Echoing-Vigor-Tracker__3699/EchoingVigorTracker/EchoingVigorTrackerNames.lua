
function EchoingVigorTracker.updateNamesDuration()
	-- update player @names once every so often
	EchoingVigorTracker.updatePlayerNames(false)
end

-- this is just to assign names to players
function EchoingVigorTracker.OnEffectChanged(_, changeType, _, effectName, unitTag, startTimeSec, endTimeSec, _, iconName, _, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

	local i = 0
	if unitTag == "player" and IsUnitGrouped("player") == false then i = 1
	elseif unitTag == "group1" then i = 1
	elseif unitTag == "group2" then i = 2
	elseif unitTag == "group3" then i = 3
	elseif unitTag == "group4" then i = 4
	elseif unitTag == "group5" then i = 5
	elseif unitTag == "group6" then i = 6
	elseif unitTag == "group7" then i = 7
	elseif unitTag == "group8" then i = 8
	elseif unitTag == "group9" then i = 9
	elseif unitTag == "group10" then i = 10
	elseif unitTag == "group11" then i = 11
	elseif unitTag == "group12" then i = 12
	else
		return
	end

	if EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_UNIT_ID]~=unitId then
		if EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_UNIT_ID]~=0 then
			--d("changing the unit ID for "..EchoingVigorTracker.echoingVigorMembers[i][PURGE_NAME].." "..EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_AT_NAME])
		end
		EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_UNIT_ID] = unitId -- assign name to player
	end

end



function EchoingVigorTracker.updatePlayerNames(reset)

	for i = 1, 12 do
		local searchBy = "group"..i
		if IsUnitGrouped("player") == false and i == 1 then
			searchBy = "player"
		end

		local atName = GetUnitDisplayName(searchBy) or ""

		atName = string.gsub(atName,"@","")

		if EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_AT_NAME] ~= atName then
			EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_AT_NAME] = atName
			EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_UNIT_ID] = 0 -- when name changes, reset the ID
		end

		EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_ROLE] = GetGroupMemberSelectedRole(searchBy)

		if reset then
			EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_UNIT_ID] = 0
		end


	end
end


