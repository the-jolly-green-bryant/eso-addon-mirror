local IBOW={}
IBOW.LAM2 = LibStub("LibAddonMenu-2.0")
IBOW.name="InnocentBladeOfWoe"
IBOW.version="1.23"
-- IBOW.allowTrespassing=true
IBOW.defaults={
	useBladeOfWoe=true,
	useVampireFeed=true
}

local function d() end

function IBOW:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Innocent Blade of Woe",
		displayName = "Innocent Blade of Woe",
		author = "Dorrino",
		version = self.version,
		registerForRefresh = true,
	}
	local optionsPanel = self.LAM2:RegisterAddonPanel("InnocentBladeOfWoe", panelData)
	local optionsData = {}
	table.insert(optionsData, {
		type = "header",
		name = "Innocent Blade of Woe options",
	})	
	table.insert(optionsData, {
		type = "checkbox",
		name = "Innocent Blade of Woe",
		tooltip = "ON - Blade of Woe popup disables Prevent Attacking Innocent, OFF - Blade of Woe popup does not affect Prevent Attacking Innocent",
		default = self.defaults.useBladeOfWoe,
		getFunc = function() return self.savedVariables.useBladeOfWoe end,
		setFunc = function(newValue) self.savedVariables.useBladeOfWoe = newValue self:EnableAddon() end,
	})	
	table.insert(optionsData, {
		type = "checkbox",
		name = "Innocent Vampire Feed",
		tooltip = "ON - Vampire Feed popup disables Prevent Attacking Innocent, OFF - Vampire Feed popup disables Prevent Attacking Innocent,",
		default = self.defaults.useVampireFeed,
		getFunc = function() return self.savedVariables.useVampireFeed end,
		setFunc = function(newValue) self.savedVariables.useVampireFeed = newValue self:EnableAddon() end,
	})	
	self.LAM2:RegisterOptionControls("InnocentBladeOfWoe", optionsData)	
end



function IBOW:ShouldApply()
	return GetSetting_Bool(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS)
end

function IBOW:Lock(applyLock)
	if applyLock then
		if not self.locked and self:ShouldApply() then 
			self.locked=true
			SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, 0)
			-- d("Prevent Attacking Innocents", self:ShouldApply(), self.locked)
		end
	else
		if self.locked then 
			self.locked=false
			SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, 1)
			-- d("Prevent Attacking Innocents", self:ShouldApply(), self.locked)			
		end
	end
end

-- function IBOW:Trespassing()
	-- if not self.allowTrespassing then return false end
	-- if IsTrespassing() then self:Lock(true)	return true
	-- else
		-- if not self.isInCombat then self:Lock(false) end 
		-- return false
	-- end
-- end

function IBOW:IsValidSynergy(synergyName, synergyFile)
	local isWoe = IBOW.savedVariables.useBladeOfWoe and (synergyFile:find("_darkbrotherhood_003") or synergyName == GetAbilityName(78219))
	local isFeed = IBOW.savedVariables.useVampireFeed and (synergyFile:find("ability_vampire_002") or synergyName == GetAbilityName(33152))

	return isWoe or isFeed
	-- return 	((synergyFile:find("_darkbrotherhood_003") and IBOW.savedVariables.useBladeOfWoe) or 
			-- (synergyFile:find("ability_vampire_002") and IBOW.savedVariables.useVampireFeed))
	
	-- return 	((synergyName == GetAbilityName(78219) and IBOW.savedVariables.useBladeOfWoe) or 
			-- (synergyName == GetAbilityName(33152) and IBOW.savedVariables.useVampireFeed))
end

function IBOW.OnSynergyChanged(eventCode)
	-- if IBOW:Trespassing() then return end
	
	local synergyName, synergyFile = GetSynergyInfo()
	-- d('synergy changed '..tostring(synergyFile))
	if synergyName and IBOW:IsValidSynergy(synergyName, synergyFile) then 
		-- d('VALID SYNERGY')
		IBOW:Lock(true)
	else
		IBOW:Lock(false)
	end
end

function IBOW:IsTargetValid()
	return (GetFullBountyPayoffAmount()>0 and GetUnitType("reticleover")==2 and GetUnitReaction("reticleover")==1 and IsUnitInCombat("reticleover"))
end

function IBOW.OnTargetChanged(eventCode)
	-- if IBOW:Trespassing() then return end
	if IBOW.isHidden then return end
	

	if IBOW:IsTargetValid() then	
		IBOW:Lock(true) 
	else
		IBOW:Lock(false)
	end
end

function IBOW.OnLayerPushed(eventCode, layerIndex, activeLayerIndex)
	IBOW:Lock(false)
end

-- function IBOW.OnLayerPopped(eventCode, layerIndex, activeLayerIndex)
	-- IBOW:Trespassing()
-- end

-- function IBOW.OnZoneChanged(eventCode)
	-- IBOW:Trespassing()
-- end

function IBOW.OnStealthState(eventCode, unitTag, stealthState)
	if eventCode=="unregister" then
		-- d("hide unregister", IBOW.isHidden, IBOW.isInvisible)
		if IBOW.isHidden or IBOW.isInvisible then 
			EVENT_MANAGER:UnregisterForEvent(IBOW.name, EVENT_SYNERGY_ABILITY_CHANGED) 
		end
		return 
	end

	if stealthState>=3 then --and not IBOW:Trespassing() then
		if stealthState==4 or stealthState==6 then
			IBOW.isInvisible=true
		else
			IBOW.isHidden=true
		end
		EVENT_MANAGER:RegisterForEvent(IBOW.name, EVENT_SYNERGY_ABILITY_CHANGED, IBOW.OnSynergyChanged)
	else
		IBOW.isHidden=false
		IBOW.isInvisible=false
		EVENT_MANAGER:UnregisterForEvent(IBOW.name, EVENT_SYNERGY_ABILITY_CHANGED)
		if not IBOW.isInCombat then IBOW:Lock(false) end
	end
end

function IBOW.OnCombatState(eventCode, inCombat)
	if eventCode=="unregister" then
		-- d("combat unregister", IBOW.isInCombat)
 		if IBOW.isInCombat then 
			EVENT_MANAGER:UnregisterForEvent(IBOW.name, EVENT_RETICLE_TARGET_PLAYER_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(IBOW.name, EVENT_RETICLE_TARGET_CHANGED)
		end
		return 
	end
	
	if inCombat then --and not IBOW:Trespassing() then
		IBOW.isInCombat=true
		EVENT_MANAGER:RegisterForEvent(IBOW.name, EVENT_RETICLE_TARGET_PLAYER_CHANGED, IBOW.OnTargetChanged)
		EVENT_MANAGER:RegisterForEvent(IBOW.name, EVENT_RETICLE_TARGET_CHANGED, IBOW.OnTargetChanged)
	else
		IBOW.isInCombat=false
		EVENT_MANAGER:UnregisterForEvent(IBOW.name, EVENT_RETICLE_TARGET_PLAYER_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(IBOW.name, EVENT_RETICLE_TARGET_CHANGED)
		IBOW:Lock(false) --if not IBOW:Trespassing() then IBOW:Lock(false) end
	end
end

function IBOW:Startup()
	if IsUnitInCombat("player") then 
		self.isInCombat=true
		EVENT_MANAGER:RegisterForEvent(IBOW.name, EVENT_RETICLE_TARGET_PLAYER_CHANGED, IBOW.OnTargetChanged)
		EVENT_MANAGER:RegisterForEvent(IBOW.name, EVENT_RETICLE_TARGET_CHANGED, IBOW.OnTargetChanged)
	else
		self.isInCombat=false
	end
	
	local stealthState=GetUnitStealthState("player")
	if stealthState>=3 then
		if stealthState==4 or stealthState==6 then
			self.isInvisible=true
		else
			self.isHidden=true
		end
		EVENT_MANAGER:RegisterForEvent(IBOW.name, EVENT_SYNERGY_ABILITY_CHANGED, IBOW.OnSynergyChanged)
	else
		self.isHidden=false
		self.isInvisible=false
	end
end


function IBOW.OnActivated()
	IBOW:Lock(false)
	IBOW:Startup()
	-- IBOW:Trespassing()
end

function IBOW:EnableAddon()
	if self.savedVariables.useBladeOfWoe or self.savedVariables.useVampireFeed then
		if not self.addonEnabled then
			self.addonEnabled=true
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, self.OnStealthState)
			EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnCombatState)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_LAYER_PUSHED, self.OnLayerPushed)
			-- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_LAYER_POPPED, self.OnLayerPopped)
			-- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ZONE_CHANGED, self.OnZoneChanged)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.OnActivated)
			self.OnActivated()
		end
	else
		if self.addonEnabled then
			self.addonEnabled=false
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTION_LAYER_PUSHED)
			-- EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTION_LAYER_POPPED)
			-- EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ZONE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE)
			self:Lock(false)
			self.OnCombatState("unregister")
			self.OnStealthState("unregister")
		end
	end
end

function IBOW.OnLoad(eventCode, addonName)
	if addonName~=IBOW.name then return end
	EVENT_MANAGER:UnregisterForEvent(IBOW.name, EVENT_ADD_ON_LOADED)
	IBOW.savedVariables = ZO_SavedVars:New("InnocentBladeOfWoeSettings", 1.2, nil, IBOW.defaults)
	IBOW:InitializeAddonMenu()
	IBOW.locked=false
	IBOW:EnableAddon()
	
end

EVENT_MANAGER:RegisterForEvent(IBOW.name, EVENT_ADD_ON_LOADED, IBOW.OnLoad)

