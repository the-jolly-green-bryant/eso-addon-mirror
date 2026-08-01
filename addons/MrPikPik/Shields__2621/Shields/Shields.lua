local addonName = "Shields"

local function UpdateLabel(labelControl, current, maximum, shield)
	if labelControl then
        if shield and shield > 0 then
            labelControl:SetText(zo_strformat("<<1>> (<<2>>)", ZO_FormatResourceBarCurrentAndMax(current, maximum), ZO_FormatResourceBarCurrentAndMax(shield, 0, RESOURCE_NUMBERS_SETTING_NUMBER_ONLY)))
        else
            labelControl:SetText(ZO_FormatResourceBarCurrentAndMax(current, maximum))
        end
	end
end

local function UpdateResourceNumbersLabel(self) -- Override for player hp bar
	local current, maximum = GetUnitPower(self:GetEffectiveUnitTag(), self.powerType)
	if self.powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
		self.shield = GetUnitAttributeVisualizerEffectInfo("player", ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
		UpdateLabel(self.control.resourceNumbersLabel, current, maximum, self.shield)
	else
		UpdateLabel(self.control.resourceNumbersLabel, current, maximum, 0)
	end
	
end

local function UpdateText(self) -- PostHook for reticleover-unitframe
	self.shield = GetUnitAttributeVisualizerEffectInfo("reticleover", ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
	UpdateLabel(self.resourceNumbersLabel, self.currentValue, self.maxValue, self.shield)
end

local function GetPlayerHealthBar()
	for i, bar in pairs(PLAYER_ATTRIBUTE_BARS.bars) do
		if bar.powerType == COMBAT_MECHANIC_FLAGS_HEALTH and bar.unitTag == "player" then
			return bar
		end
	end
end

local function UnitAttributeVisual(evt, unitTag, unitAttributeVisual, attributeType, value1, value2)
	if unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
	
	if unitTag == "player" then
		GetPlayerHealthBar():UpdateResourceNumbersLabel()
	elseif unitTag == "reticleover"  then
		UNIT_FRAMES:GetFrame("reticleover").healthBar:UpdateText()
	end
end

local function OnAddonLoaded(event, name)
    if name ~= addonName then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
    
	-- Player healthbar
    local healthBar = GetPlayerHealthBar()
    healthBar.shield = 0
    local mt = getmetatable(healthBar)
    mt.UpdateResourceNumbersLabel = UpdateResourceNumbersLabel
    setmetatable(healthBar, mt)
	
	-- reticleover healthbar
	local reticleoverFrame = UNIT_FRAMES:GetFrame("reticleover")
	reticleoverFrame.healthBar.shield = 0
	ZO_PostHook(reticleoverFrame.healthBar, "UpdateText", UpdateText)
	
	-- Events
	EVENT_MANAGER:RegisterForEvent("Shields", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,   UnitAttributeVisual)
	EVENT_MANAGER:RegisterForEvent("Shields", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, UnitAttributeVisual)
	EVENT_MANAGER:RegisterForEvent("Shields", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, UnitAttributeVisual)
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddonLoaded)