CraftingBuildAlert = {
    displayName = "Crafting Build Alert",
    shortName = "CBA",
    name = "CraftingBuildAlert",
    version = "1.2.0",
    logger = nil,
	lastNag = nil,
	libZone = nil,
	lastZoneName = nil,
	variablesVersion = 1,
	charVariablesVersion = 2,
	Default = {
	  isDebug = false,
	},
	CharDefault = {
	  craftBuildID = 0,
	  currentBuildID = 0,
	  doWorldAlerts = true,
	},
}

function CraftingBuildAlert:GetBuildNames()
    local buildNames = {}
	table.insert(buildNames, "--None")
	
    for i = 1, GetNumUnlockedArmoryBuilds() do
        table.insert(buildNames, GetArmoryBuildName(i))
    end
	
    return buildNames
end

function CraftingBuildAlert:GetBuildIDs()
    local buildIDs = {}
	table.insert(buildIDs, 0)
	
    for i = 1, GetNumUnlockedArmoryBuilds() do
        table.insert(buildIDs, i)
    end
	
    return buildIDs
end

function CraftingBuildAlert:IsOnCraftingBuild()
    if (self.savedCharVariables.craftBuildID ~= nil) and
	   (self.savedCharVariables.craftBuildID ~= 0) and
	   (self.savedCharVariables.currentBuildID ~= nil) then
	  return (self.savedCharVariables.craftBuildID == self.savedCharVariables.currentBuildID)
	end
    return nil
end

function CraftingBuildAlert:IsInDungeonOrRaid()
	local player = "player"
	local inDungeon = false
	
	if self.libZone == nil then
		--[[ Order matters for the next three statements.
		     The first two check the map type with OR.
			 The third ANDs the the type with the difficulty to identify group dungeons.
		]]
		inDungeon = IsUnitInDungeon(player) or inDungeon
		inDungeon = (GetMapContentType() == MAP_CONTENT_DUNGEON) or inDungeon
		inDungeon = (ZO_WorldMap_GetMapDungeonDifficulty() > DUNGEON_DIFFICULTY_NONE) and inDungeon
		-- Can't check for public dungeons without LibZone
		-- Don't care if player is in a delve
		inDungeon = IsPlayerInRaid() or inDungeon
		
	else
		local isInPVP, isInDelve, isInPublicDungeon, isInGroupDungeon, isInRaid, isInGroup, groupSize = self.libZone:GetCurrentZoneAndGroupStatus()
		
		inDungeon = isInGroupDungeon or inDungeon
		inDungeon = isInPublicDungeon or inDungeon
		-- Don't care if player is in a delve
		inDungeon = isInRaid or inDungeon
	end
	
	
	
	return inDungeon
end

function CraftingBuildAlert:GetCurrentZoneName()
	local currentZoneId, currentZoneIndex
	if self.libZone ~= nil then
		currentZoneId, _, currentZoneIndex, _, _, _ = self.libZone:GetCurrentZoneIds()
	else
		currentZoneIndex = GetCurrentZoneIndex()
		currentZoneId = GetZoneId(currentZoneIndex())
	end
	
	return GetZoneNameById(currentZoneId)
end

function CraftingBuildAlert:CreateMenu()

    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "Mightyjo",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel(self.displayName, panelData)
    
    local debugOptionName = GetString(CRAFTING_BUILD_ALERT_OPTION_DEBUG)
	local worldAlertsOptionName = GetString(CRAFTING_BUILD_ALERT_OPTION_WORLD_ALERT)
    local optionsTable = {
	    {
		    type = "header",
			name = "Account-wide Settings",
			width = "full",
		},
        {
            type = "checkbox",
            name = debugOptionName,
            getFunc = function()
                return self.savedVariables.isDebug
            end,
            setFunc = function(value)
                self.savedVariables.isDebug = value
            end,
            width = "full",
            default = false,
        },
		{
		    type = "divider",
		},
		{
		    type = "header",
			name = "Per-account Settings",
			width = "full",
		},
		{
		    type = "dropdown",
			name = "Crafting Build",
			choices = self:GetBuildNames(),
			choicesValues = self:GetBuildIDs(),
			getFunc = function()
			    if self.savedCharVariables.craftBuildID == nil then
			        return 0
				else
			        return self.savedCharVariables.craftBuildID
				end
		    end,
			setFunc = function(var)
			    self.savedCharVariables.craftBuildID = var
			end,
			default = 0,
			width = "full",
		},
		 {
            type = "checkbox",
            name = worldAlertsOptionName,
            getFunc = function()
                return self.savedCharVariables.doWorldAlerts
            end,
            setFunc = function(value)
                self.savedCharVariables.doWorldAlerts = value
            end,
            width = "full",
            default = true,
        },
    }
    LibAddonMenu2:RegisterOptionControls(self.displayName, optionsTable)
end

function CraftingBuildAlert:Info(text, ...)
    
	if self.logger then
	  self:Log(LibDebugLogger.LOG_LEVEL_INFO, text, ...)
	else
	  if ... ~= nil then
	    text = zo_strformat(text, unpack({...}))
	  end
	  d( string.format("%s: %s", self.name, text) )
	end
	
end

function CraftingBuildAlert:Debug(text, ...)
    
	if self.logger == nil then
	  return
	end
	
	if self.savedVariables.isDebug == false then
	  return
	end
	  
	self:Log(LibDebugLogger.LOG_LEVEL_DEBUG, text, ...)
	
end

function CraftingBuildAlert:Warn(text, ...)
    
	if self.logger == nil then
	  return
	end
	  
	self:Log(LibDebugLogger.LOG_LEVEL_WARNING, text, ...)
	
end

function CraftingBuildAlert:Error(text, ...)
    
	if self.logger == nil then
	  return
	end
	  
	self:Log(LibDebugLogger.LOG_LEVEL_ERROR, text, ...)
	
end

function CraftingBuildAlert:Log(level, text, ...)
    if self.logger == nil then
	  return
	end
	
	local _logger = self.logger
	
	local switch = {
	  [LibDebugLogger.LOG_LEVEL_DEBUG] = function (text) _logger:Debug(text) end,
	  [LibDebugLogger.LOG_LEVEL_INFO] = function (text) _logger:Info(text) end,
	  [LibDebugLogger.LOG_LEVEL_WARNING] = function (text) _logger:Warn(text) end,
	  [LibDebugLogger.LOG_LEVEL_ERROR] = function (text) _logger:Error(text) end,
	  default = nil,
	}
	
	local case = switch[level] or switch.default
	if case then
	  if ... ~= nil then
	    text = zo_strformat(text, unpack({...}))
	  end
	  case(text)
	end

end

function CraftingBuildAlert:BuildUpdate()
    return function(_, buildId)
        self.savedCharVariables.currentBuildID = buildId
	end
end

function CraftingBuildAlert:BuildRestored()
    return function(_, result, buildId)
        if result then 
            self.savedCharVariables.currentBuildID = buildId
	    end
	end
end

function CraftingBuildAlert:BuildSaved()
    return function(_, result, buildId)
        if result then
            self.savedCharVariables.currentBuildID = buildId
	    end
	end
end

function CraftingBuildAlert:CraftingStationInteract()
    return function(_, craftingType, isCraftingSameAsPrevious)
    	--if isCraftingSameAsPrevious then
            -- Don't nag when we're switching tabs at a crafting station
    	    --return
    	--end
    	
    	local onCraftingBuild = self:IsOnCraftingBuild()
    	
    	if onCraftingBuild == nil then
    	    -- Don't nag if a crafting build isn't set
    	elseif onCraftingBuild then
    	    -- Don't nag if we're on the crafting build
		elseif craftingType == CRAFTING_TYPE_SCRIBING then
		    -- Don't nag for scribing (while it's not on the champion tree)
    	else
    	    -- Nag if we're not on the crafting build and we've just opened a crafting station
           	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ABILITY_COMPANION_ULTIMATE_READY)
           	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
           	params:SetText(GetString(CRAFTING_BUILD_ALERT_STATION_NAG))
			params:SetLifespanMS(5000)
           	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    	end
		
		return
    end
end



function CraftingBuildAlert:ZoneChanged()
    return function(_, _, _, _, _, _)
		local now = GetGameTimeMilliseconds()
		local minDelay = 10000
		local currentZoneName = self:GetCurrentZoneName()
		
		-- Don't nag more than once for a zone
		-- Ensure chance to nag for a new zone
		if self.lastZoneName == currentZoneName then
			return
		else
			self.lastZoneName = currentZoneName
			self.lastNag = nil
		end
			
		-- Don't nag if the user doesn't want this feature
		if not self.savedCharVariables.doWorldAlerts then
			return
		end
		
		--[[ The LUA engine is single-threaded, so even though several events can fire this handler
			 at once, one of them will get to finish and set lastNag so the others can bail out early.
		]]
		if (self.lastNag == nil) or ((self.lastNag ~= nil) and (now - self.lastNag >= minDelay)) then
			self.lastNag = now
		
			local onCraftingBuild = self:IsOnCraftingBuild()
			local inDungeon = self:IsInDungeonOrRaid()

			if onCraftingBuild == nil then
				-- Don't nag if a crafting build isn't set
			elseif onCraftingBuild and inDungeon then
				-- Nag if we're on the crafting build and we've just entered a dungeon
				local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.DUEL_BOUNDARY_WARNING)
				params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
				params:SetText(GetString(CRAFTING_BUILD_ALERT_STATION_NAG))
				params:SetLifespanMS(5000)
				CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
				
			else
				-- Don't nag if we're not on the crafting build or not in a dungeon, trial, etc.
			end
		else 
				-- Don't nag repeatedly for similar events
		end
		
		return
	end
end

function CraftingBuildAlert:OnAddOnLoaded(event, addonName)

    if addonName ~= self.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    
	if LibDebugLogger then
	    self.logger = LibDebugLogger(self.name)
	end
	
	if LibZone then
		self.libZone = LibZone
	end

    self.savedVariables = ZO_SavedVars:NewAccountWide("CraftingBuildAlertVariables", self.variablesVersion, nil, self.Default)
	local savedCharVariables_old = ZO_SavedVars:NewCharacterIdSettings("CraftingBuildAlertVariables", self.charVariablesVersion-1, nil, self.CharDefault)
	local upgradedCharVariables = {
		craftBuildID = savedCharVariables_old.craftBuildID,
		currentBuildID = savedCharVariables_old.currentBuildID,
		doWorldAlerts = savedCharVariables_old.doWorldAlerts,
	}
	self.savedCharVariables  = ZO_SavedVars:NewCharacterIdSettings("CraftingBuildAlertVariables", self.charVariablesVersion, nil, upgradedCharVariables)
	self:CreateMenu()
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ARMORY_BUILD_UPDATED, self:BuildUpdate())
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, self:BuildRestored())
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ARMORY_BUILD_SAVE_RESPONSE, self:BuildSaved())
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTING_STATION_INTERACT, self:CraftingStationInteract())
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ZONE_CHANGED, self:ZoneChanged())
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CURRENT_SUBZONE_LIST_CHANGED, self:ZoneChanged())
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LINKED_WORLD_POSITION_CHANGED, self:ZoneChanged())
	
	self:Info(GetString(CRAFTING_BUILD_ALERT_LOADED))

end



EVENT_MANAGER:RegisterForEvent(CraftingBuildAlert.name, EVENT_ADD_ON_LOADED, function(...) CraftingBuildAlert:OnAddOnLoaded(...) end)
