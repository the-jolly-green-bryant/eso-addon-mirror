NewCrown = NewCrown or {}

function NewCrown.DebugMessage(message)
	if NewCrown.DebugEnabled then
		d("NewCrown: "..message)
	end
end

function NewCrown.Init()
	
	NewCrown.InCombat = IsUnitInCombat("player")
	NewCrown.SetLocation()
	
	NewCrown.LoadSavedVars()	
	NewCrown.SetupMenu()
	NewCrown.SetNewGroupSize()	--Get group size for the first time. (Could be you reloaded when in a group)
	NewCrown.CheckNewLeader()	--If you are in a group, the leader could be one of the specials :)
	NewCrown.UpdateCrown()
end

function NewCrown.LoadSavedVars()
	NewCrown.DebugMessage("Loading SavedVars...")
	NewCrown.SavedVars = ZO_SavedVars:NewAccountWide("NCSavedVars", NewCrown.VariableVersion, nil, NewCrown.DefaultSavedVars, GetWorldName())
	NewCrown.DebugMessage("SavedVars Loaded!")
end

function NewCrown.UpdateCrown()
	NewCrown.DebugMessage("Setting NewCrown...")
	
	if NewCrown.CheckCrownSetOrRemove() == true then
		NewCrown.SetCrown()
	else 
		NewCrown.RemoveCrown()	
	end	
end

function NewCrown.SetCrown()
	NewCrown.UpdateIconPath()
	SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, NewCrown.SavedVars.IconSize, NewCrown.IconPath, "esoui\art\compass\groupleader_door.dds")
	NewCrown.DebugMessage("NewCrown set!")
end

function NewCrown.RemoveCrown()
	SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, nil, nil)
	NewCrown.DebugMessage("NewCrown Removed!")
end

function NewCrown.CheckCrownSetOrRemove()

	NewCrown.DebugMessage("Checking validations...")
	NewCrown.DebugMessage("When to activate: "..NewCrown.SavedVars.WhenToActivate.." | InCombat: "..tostring(NewCrown.InCombat))
	NewCrown.DebugMessage("Location: "..NewCrown.Location)

	--[[
	-- Checking When to Activate
	-- Always (1) doesn't need to be checked, because it will always me true (returned at the end)
	-- Returns False, when the Crown shoudn't be displayed
	--]]
	if NewCrown.SavedVars.WhenToActivate == NewCrown.WhenToActivateChoices[4] then --Never 
		return false
	elseif NewCrown.SavedVars.WhenToActivate == NewCrown.WhenToActivateChoices[2] then --Combat Only
		if NewCrown.InCombat == false then
			return false
		end
		--Positive path doensnt need to be checked
	elseif NewCrown.SavedVars.WhenToActivate == NewCrown.WhenToActivateChoices[3] then --Idle Only
		if NewCrown.InCombat == true then
			return false
		end
		--Positive path doensnt need to be checked
	end
	
	--[[
	-- Check if the crown is enabled in this location
	--]]
	if NewCrown.Location == "Overland" then
		if NewCrown.SavedVars.ActiveInOverland == false then
			return false
		end
	elseif NewCrown.Location == "AvA" then
		if NewCrown.SavedVars.ActiveInAva == false then
			return false
		end
	elseif NewCrown.Location == "Trial" then
		if NewCrown.SavedVars.ActiveInTrial == false then
			return false
		end
	elseif NewCrown.Location == "Dungeon" then
		if NewCrown.SavedVars.ActiveInDungeon == false then
			return false
		end
	end
	
	return true
end

function NewCrown.UpdateIconPath()
	--Check if the Icon needs to be updated with the Leader Icon
	if NewCrown.LeaderIcon ~= "" and NewCrown.SavedVars.SpecialFeatureEnabled then 
		NewCrown.IconPath = NewCrown.LeaderIcon 
	else 
		NewCrown.IconPath = NewCrown.SavedVars.CurrentIcon 
	end
end

function NewCrown.CheckNewLeader()
	NewCrown.DebugMessage("Checking new leader....")
	
	local PlayerSpecificIcons = {
		{
			["AccountName"] = "@Yoshi.D",
			["IconPath"] = "/NewCrown/Textures/Yoshi.dds",
		},
		{
			["AccountName"] = "@Toontje88",
			["IconPath"] = "/NewCrown/Textures/Toontje88.dds",
		},
		{
			["AccountName"] = "@Refoss",
			["IconPath"] = "/NewCrown/Textures/Refoss.dds",
		},
		{
			["AccountName"] = "@MissCoko",
			["IconPath"] = "/NewCrown/Textures/Coko.dds",
		},
		{
			["AccountName"] = "@Xzander1992",
			["IconPath"] = "/NewCrown/Textures/Xzander.dds",
		},
		{
			["AccountName"] = "@KAI_MOOK",
			["IconPath"] = "/NewCrown/Textures/Kai.dds",
		},
		{
			["AccountName"] = "@Jenivaaa",
			["IconPath"] = "/NewCrown/Textures/DragonAegis.dds",
		},
		{
			["AccountName"] = "@RLRevenant",
			["IconPath"] = "/NewCrown/Textures/DragonAegis.dds",
		},
		{
			["AccountName"] = "@IRaZ",
			["IconPath"] = "/NewCrown/Textures/Irezz.dds",
		},
		{
			["AccountName"] = "@Moonprayer",
			["IconPath"] = "/NewCrown/Textures/moon.dds",
		},
		{
			["AccountName"] = "@StonedFlyingLamb",
			["IconPath"] = "/NewCrown/Textures/stoned_inverse_border.dds",
		},
		{
			["AccountName"] = "@Leandra.c",
			["IconPath"] = "/NewCrown/Textures/Leandra.c.dds",
		},
	}	
	
	local OldLeaderIcon = NewCrown.LeaderIcon
	NewCrown.LeaderIcon = "" -- Set to "", if there is a match it will update later
	
	local LeaderTag = GetGroupLeaderUnitTag()
	local LeaderDisplayName = GetUnitDisplayName(LeaderTag)
	for i, v in ipairs(PlayerSpecificIcons) do
		if v.AccountName == LeaderDisplayName then 
			NewCrown.LeaderIcon = v.IconPath
		end
	end
	
	if OldLeaderIcon ~= NewCrown.LeaderIcon then
		NewCrown.DebugMessage("New LeaderIcon:"..NewCrown.LeaderIcon)
		NewCrown.UpdateCrown()
	end
	
end

function NewCrown.SetNewGroupSize()
	NewCrown.GroupSize = GetGroupSize()
end

function NewCrown.SetLocation()
	NewCrown.DebugMessage("Checking location...")
	if IsUnitInDungeon("player") == true then
		NewCrown.DebugMessage("Player is in a Dungeon Area")
		--Player is in a Solo instance, Group dungeons Trial or Delve
		if IsPlayerInRaid() == true then
			--Player is in a trial
			NewCrown.Location = "Trial"
		else
			--Player is in a Solo instance, Group Dungeon or Delve
			NewCrown.Location = "Dungeon"
		end
	elseif IsPlayerInAvAWorld() == true then
		--PlayerIsIn Cyrodiil or Imperial City
		NewCrown.Location = "AvA"
	else
		--Player is not in above, so overland!
		NewCrown.Location = "Overland"
	end
	NewCrown.DebugMessage("Location:"..NewCrown.Location)
end