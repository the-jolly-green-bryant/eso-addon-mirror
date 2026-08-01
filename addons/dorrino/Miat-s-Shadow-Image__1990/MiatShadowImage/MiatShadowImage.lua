local GPS = LibStub("LibGPS2")
local LAM2 = LibStub("LibAddonMenu-2.0")

local addonDefaults = {
	unlocked = true,
	controlOffsetX = 0,
	controlOffsetY = 0,
	controlScale = 1,
}

local function GetCoordsDistance2D(selfX, selfY, targetX, targetY)
	local distance = math.sqrt(((targetX-selfX)*(targetX-selfX))+((targetY-selfY)*(targetY-selfY)))
	return distance
end

local shadowReturnIds = {
	[35451] = true,
	[36290] = true,
	[36295] = true,
	[36300] = true,
}	
	
-- local shadowReturnIds = {
	-- [36299] = true,
-- }

-- local shadowExpireIds = {
	-- [88696] = true,
	-- [88699] = true,
	-- [88702] = true,
	-- [88705] = true,
-- }

local shadowSetupIds = {
	[38528] = true,
	[38529] = true,
	[38530] = true,
	[38531] = true,
	[88696] = true,
	[88697] = true,
	[88699] = true,
	[88700] = true,
	[88702] = true,
	[88703] = true,
	[88705] = true,
	[88706] = true,
}

local shadowReturnResults = {
	[2245] = true,
	[2250] = true,
}

local Miat_ShadowImage = ZO_Object:Subclass()

function Miat_ShadowImage:New(...)
    local image = ZO_Object.New(self)
    image:Initialize(...)
    return image
end

function Miat_ShadowImage:Initialize(control)
	self.updateName = 'MiatShadowImage'
	self.version = '1.06'
	self.SV = ZO_SavedVars:NewAccountWide("MiatShadowImageSettings", 1.04, "Settings", addonDefaults)
	
    self.control = control
    self.timerControl = control:GetNamedChild('Timer')
    self.iconControl = control:GetNamedChild('Icon')
    self.outOfRangeControl = control:GetNamedChild('OOR')
	
	self:CreateAddonMenu()
	self:SetupEvents()
	self:SetupControl()
	self:ManageUnlocked()
end

function Miat_ShadowImage:SetupEvents()
	self.control:RegisterForEvent(EVENT_COMBAT_EVENT, function(_, ...) self:OnCombatEvent(...) end)
	self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function() self:ResetShadow() end)
	-- self.control:AddFilterForEvent(EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, 1)
	self.control:RegisterForEvent(EVENT_ACTION_SLOT_ABILITY_USED, function(_, ...) self:OnAbilityUsed(...) end)
end

function Miat_ShadowImage:SetupControl()
	self.control:ClearAnchors()
	self.control:SetAnchor(CENTER, GuiRoot, CENTER, self.SV.controlOffsetX, self.SV.controlOffsetY)
end

function Miat_ShadowImage:OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, combat_log, sourceUnitId, targetUnitId, abilityId)
	-- if self.SV.unlocked or not (shadowReturnIds[abilityId] and shadowReturnResults[result]) then return end
	if self.SV.unlocked then return end

	if shadowSetupIds[abilityId] and result == 2245 then
		self.shadowTime = hitValue
	end
	-- if abilityName == "Shadow" then 
		-- d("__________________________")
		-- d(result, hitValue, abilityId) 
	-- end
	if shadowReturnIds[abilityId] then
		if result == 2245 then
			if not self.eventCounter then self.eventCounter = 0 end
			self.eventCounter = self.eventCounter + 1
			self:SetupShadow(self.shadowTime)
		elseif result == 2250 then
			if not self.eventCounter then self.eventCounter = 1 end
			self.eventCounter = self.eventCounter - 1
			if self.eventCounter == 0 then
				self:ResetShadow()
			end
		end
	end
end

function Miat_ShadowImage:OnAbilityUsed(slotNum)
	local isSetup = GetSlotBoundId(slotNum) == 35441
	local isReturn = GetSlotBoundId(slotNum) == 35445
	if isSetup or isReturn then
		self.slotNumber = slotNum
	end
	
	-- if isReturn then
		-- self:ResetShadow()
	-- end
end

function Miat_ShadowImage:SetupShadow(duration)
	self.duration = duration
	self.endTime = GetFrameTimeSeconds()+(duration/1000)
	self:ApplyInRange()
	EVENT_MANAGER:RegisterForUpdate(self.updateName, 25, function() self:OnUpdate() end)
	self:ShowShadow()
end

function Miat_ShadowImage:ManageUnlocked()
	if self.SV.unlocked then
		GAME_MENU_SCENE:AddFragment(SHADOWIMAGE_TRACKER_FRAGMENT)
		self.control:SetMovable(true)
		self.outOfRangeControl:SetText('Unlocked!')
		self.outOfRangeControl:SetColor(1,1,1)
		self.outOfRangeControl:SetHidden(false)
		self:ShowShadow()
	else
		GAME_MENU_SCENE:RemoveFragment(SHADOWIMAGE_TRACKER_FRAGMENT)
		self.control:SetMovable(false)
		self.outOfRangeControl:SetText('Out of Range!')
		self.outOfRangeControl:SetHidden(true)
		self:HideShadow()
	end
end

function Miat_ShadowImage:ShowShadow()
	HUD_SCENE:AddFragment(SHADOWIMAGE_TRACKER_FRAGMENT)
	HUD_UI_SCENE:AddFragment(SHADOWIMAGE_TRACKER_FRAGMENT)
	LOOT_SCENE:AddFragment(SHADOWIMAGE_TRACKER_FRAGMENT)
	self.control:SetHidden(false)
	-- d('show')
end

function Miat_ShadowImage:HideShadow()
	HUD_SCENE:RemoveFragment(SHADOWIMAGE_TRACKER_FRAGMENT)
	HUD_UI_SCENE:RemoveFragment(SHADOWIMAGE_TRACKER_FRAGMENT)
	LOOT_SCENE:RemoveFragment(SHADOWIMAGE_TRACKER_FRAGMENT)
	self.control:SetHidden(true)
	-- d('hide')
end

function Miat_ShadowImage:ResetShadow()

	self:HideShadow()
	self:ClearImageData()
	EVENT_MANAGER:UnregisterForUpdate(self.updateName)
	self.slotNumber = nil
end

function Miat_ShadowImage:ApplyOutOfRange()
	self.outOfRangeControl:SetHidden(false)
	self.outOfRangeControl:SetText('Out of Range!')
	self.outOfRangeControl:SetColor(1,0,0)
	self.timerControl:SetAlpha(0.65)
	self.timerControl:SetColor(1,0,0)
	self.iconControl:SetAlpha(0.65)
end

function Miat_ShadowImage:ApplyInRange()
	self.outOfRangeControl:SetHidden(false)
	self.outOfRangeControl:SetText('In range!')
	self.outOfRangeControl:SetColor(0,1,0)
	self.timerControl:SetAlpha(1)
	self.timerControl:SetColor(0,1,0)
	self.iconControl:SetAlpha(1)
end

function Miat_ShadowImage:ApplyUnknown()
	self.outOfRangeControl:SetHidden(true)
	self.timerControl:SetAlpha(0.5)
	self.timerControl:SetColor(0.5,0.5,0.5)
	self.iconControl:SetAlpha(0.5)
end

function Miat_ShadowImage:ClearImageData()
	self.endTime = nil
	self.duration = nil
	self.eventCounter = nil
end

function Miat_ShadowImage:GetValidRange()
	if self.slotNumber then
		local testSlot = GetSlotBoundId(self.slotNumber)
		if testSlot == 35445 then
			return true
		elseif testSlot == 35441 then
			return false
		end
	end
	return nil
end

function Miat_ShadowImage:OnUpdate()
	if not self.endTime then return end
	
	local inRange = self:GetValidRange()

	if inRange ~= nil then
		if inRange then
			self:ApplyInRange()
		else
			self:ApplyOutOfRange()
		end
	else
		self:ApplyUnknown()
	end
	
	local timeLeft = math.ceil(self.endTime - GetFrameTimeSeconds())
	if timeLeft <= 0 then
		timeLeft = ""
		-- self:ResetShadow()
	end
	
	-- local isValidScene = SCENE_MANAGER:GetCurrentScene() == HUD_SCENE or SCENE_MANAGER:GetCurrentScene() == HUD_UI_SCENE or SCENE_MANAGER:GetCurrentScene() == LOOT_SCENE or (self.SV.unlocked and SCENE_MANAGER:GetCurrentScene() == GAME_MENU_SCENE)
	
	-- self.control:SetHidden(not (self.SV.unlocked or (self.endTime and isValidScene)))
	
	-- d(self.SV.unlocked or (self.endTime and isValidScene))
	
	self.timerControl:SetText(timeLeft)
end

function Miat_ShadowImage:CreateAddonMenu()
	local panelData = {
		type = "panel",
		name = "Miat's Shadow Image",
		displayName = "Miat's Shadow Image",
		author = "Dorrino",
		version = self.version,
		-- slashCommand = "",
		registerForRefresh = true,
		registerForDefaults = false,
		-- resetFunc = function() 	end
	}
	
	local optionsPanel = LAM2:RegisterAddonPanel("Miat_ShadowImage", panelData)
		
	local optionsData = {}
	
	
	table.insert(optionsData, {
		type = "header",
		name = "Shadow Image Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Turn OFF when satisfied with icon position",
		tooltip = "ON - icon can me moved on the screen by left clicking and dragging, OFF - icon is locked in place and can not be moved",
		default = addonDefaults.unlocked,
		-- disabled = function() return not self.SV.enabled end,
		getFunc = function() return self.SV.unlocked end,
		setFunc = function(newValue) self.SV.unlocked = newValue self:ManageUnlocked() end,
	})

	table.insert(optionsData, {
		type = "slider",
		name = "Set Icon Scale (%)",
		tooltip = "Icon Scale scale goes from 50% to 200% of original scale",
		default = tonumber(string.format("%.0f", 100*addonDefaults.controlScale)),
		-- disabled = function() return not self.SV.enabled or not self.SV.showKillFeedFrame end,
		min     = 50,
        max     = 200,
        step    = 1,
		getFunc = function() return tonumber(string.format("%.0f", 100*self.SV.controlScale)) end,
		setFunc = function(newValue) self.SV.controlScale = newValue/100 end,
	})
	
	LAM2:RegisterOptionControls("Miat_ShadowImage", optionsData)	
end

function Miat_ShadowImage:SavePosition(control)
	local coordX, coordY = control:GetCenter()
	self.SV.controlOffsetX=coordX-(GuiRoot:GetWidth()/2)
	self.SV.controlOffsetY=coordY-(GuiRoot:GetHeight()/2)
	control:ClearAnchors()
	control:SetAnchor(CENTER, GuiRoot, CENTER, self.SV.controlOffsetX, self.SV.controlOffsetY)
end

function Miat_ShadowImage:OnMouseWheel(control, delta)
	if not self.SV.unlocked then return end
	
	local scale = self.SV.controlScale + delta*0.01
	if scale < 0.5 or scale > 2 then return end
	
	control:SetScale(scale)
	self.SV.controlScale = scale
end

function Miat_ShadowImage_SavePosition(...)
	Miat_ShadowImage:SavePosition(...)
end

function Miat_ShadowImage_OnMouseWheel(...)
	Miat_ShadowImage:OnMouseWheel(...)
end

function Miat_ShadowImage_OnInitialized(...)
    -- MIAT_SHADOWIMAGE = Miat_ShadowImage:New(...)
end

EVENT_MANAGER:RegisterForEvent('MiatShadowImage', EVENT_ADD_ON_LOADED, function(_, addonName) 
	if addonName == 'MiatShadowImage' then
		EVENT_MANAGER:UnregisterForEvent('MiatShadowImage', EVENT_ADD_ON_LOADED)
		SHADOWIMAGE_TRACKER_FRAGMENT = ZO_FadeSceneFragment:New(MiatShadowImageFrame, nil, 0)
		MIAT_SHADOWIMAGE = Miat_ShadowImage:New(MiatShadowImageFrame)
	end
end)