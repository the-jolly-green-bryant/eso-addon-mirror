HarvensAttributeBars = {}

function HarvensAttributeBars:UpdateLabels()
	local current, max
	for powerType, attr in pairs(self.attributes) do
		current, max = GetUnitPower("player", powerType)
		self:OnAttributeUpdate(powerType, current, max)
		self.lastVal = current
	end
end

function HarvensAttributeBars:UpdateStats(inCombat)
	local val
	for powerType, attr in pairs(self.attributes) do
		if inCombat then
			val = GetPlayerStat(attr.statRegenInCombatIndex, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
		else
			val = GetPlayerStat(attr.statRegenIndex, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
		end
		if not ( attr.statIndex == STAT_STAMINA_MAX and val == 0 ) then --some bug
			attr.regenLabel:SetText("("..val.."/2s)")
		end
	end
end

function HarvensAttributeBars.PlayerActivated()
	HarvensAttributeBars:UpdateLabels()
	HarvensAttributeBars:UpdateStats(false)
end

function HarvensAttributeBars:OnAttributeUpdate(powerType, current, max, effectiveMax)
	diff = current - self.attributes[powerType].lastVal
	color = current/max
	self.attributes[powerType].label:SetColor(1, color, color, 1)
	
	if self.sv.displayValue == 1 then
		self.attributes[powerType].label:SetText(current.." / "..max)
	elseif self.sv.displayValue == 2 then
		local val = math.floor(color*100)
		self.attributes[powerType].label:SetText(val.."%")
	else
		self.attributes[powerType].label:SetText(" ")
	end
	
	--self.attributes[powerType].label:SetText(current.." / "..max)
	self.attributes[powerType].lastVal = current
	if diff == 0 then
		return
	elseif diff > 0 then
		self.attributes[powerType].diffLabel:SetColor(0, 1, 0, 1)
		self.attributes[powerType].diffLabel:SetText("+"..diff)
	else
		self.attributes[powerType].diffLabel:SetColor(1, 0, 0, 1)
		self.attributes[powerType].diffLabel:SetText(diff)
	end
	self.attributes[powerType].diffFade:PlayFromStart()
end

function HarvensAttributeBars.PowerUpdate(eventType, unitTag, powerPoolIndex, powerType, current, max, effectiveMax)
	if unitTag == "reticleover" then
		 if powerType == POWERTYPE_HEALTH then
		 	HarvensAttributeBars:UpdateReticleOverHealth(current, max)
		 end
		 return
	end
	if unitTag ~= "player" then return end
	
	if powerType ~= POWERTYPE_STAMINA and powerType ~= POWERTYPE_HEALTH and powerType ~= POWERTYPE_MAGICKA then return end
	
	HarvensAttributeBars:OnAttributeUpdate(powerType, current, max, effectiveMax)
end

function HarvensAttributeBars.EventStatsUpdate(eventType, unitTag)
	if unitTag ~= "player" then return end
	
	HarvensAttributeBars:UpdateStats(IsUnitInCombat("player"))
end

function HarvensAttributeBars.EventCombatState(eventType, inCombat)
	HarvensAttributeBars:UpdateStats(inCombat)
end

function HarvensAttributeBars:UpdateReticleOverHealth(current, max)
	local diff = 0
	if self.lastHP > 0 then
		diff = current - self.lastHP
		if diff > 0 then
			self.reticleDiff:SetColor(0, 1, 0, 1)
			self.reticleDiff:SetText("+"..diff)
			self.reticleDiffFade:PlayFromStart()
		elseif diff < 0 then
			self.reticleDiff:SetColor(1, 0, 0, 1)
			self.reticleDiff:SetText(diff)
			self.reticleDiffFade:PlayFromStart()
		end
	end
	self.lastHP = current
	
	color = current/max
	self.reticleLabel:SetColor(1, color, color, 1)
	if self.sv.displayReticleValue == 1 then
		self.reticleLabel:SetText(current.." / "..max)
	elseif self.sv.displayReticleValue == 2 then
		local val = math.floor(color*100)
		self.reticleLabel:SetText(val.."%")
	end
end

function HarvensAttributeBars.EventReticleTargetChanged(evenType)
	if not DoesUnitExist("reticleover") then return end
	
	local current, max = GetUnitPower("reticleover", POWERTYPE_HEALTH)
	HarvensAttributeBars.lastHP = 0
	HarvensAttributeBars:UpdateReticleOverHealth(current, max)
end

function HarvensAttributeBars:SetupOptions()
	local settings = LibHarvensAddonSettings:AddAddon("Harven's Attribute Bars")
	
	local displayValues = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Display Values as",
		items = {
			{
				name = "None",
				data = 0,
			},
			{
				name = "Min/Max",
				data = 1,
			},
			{
				name = "Precentage",
				data = 2,
			},
		},
		setFunction = function(combobox, name, item)
			self.sv.displayValue = item.data
			self:UpdateLabels()
		end,
		getFunction = function()
			return self.displayValueNumToString[self.sv.displayValue]
		end,
	}
	
	local displayReticleValues = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Display Reticle Values as",
		items = {
			{
				name = "None",
				data = 0,
			},
			{
				name = "Min/Max",
				data = 1,
			},
			{
				name = "Precentage",
				data = 2,
			},
		},
		setFunction = function(combobox, name, item)
			self.sv.displayReticleValue = item.data
			
			if self.sv.displayReticleValue == 0 then
				self.reticleLabel:SetHidden(true)
				self.reticleDiff:SetHidden(true)
				local _, point, _, relPoint, x, y = ZO_TargetUnitFramereticleoverTextArea:GetAnchor(0)
				ZO_TargetUnitFramereticleoverTextArea:ClearAnchors()
				ZO_TargetUnitFramereticleoverTextArea:SetAnchor(point, ZO_TargetUnitFramereticleover, relPoint, x, y+6)
			else
				self.reticleLabel:SetHidden(false)
				self.reticleDiff:SetHidden(false)
				local _, point, _, relPoint, x, y = ZO_TargetUnitFramereticleoverTextArea:GetAnchor(0)
				ZO_TargetUnitFramereticleoverTextArea:ClearAnchors()
				ZO_TargetUnitFramereticleoverTextArea:SetAnchor(point, self.reticleLabel, relPoint, x, y-6)
			end
		end,
		getFunction = function()
			return self.displayValueNumToString[self.sv.displayReticleValue]
		end,
	}
	
	local forceVisible = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Allways Visible",
		getFunction = function()
			return self.sv.forceVisible
		end,
		setFunction = function(state)
			self.sv.forceVisible = state
			PLAYER_ATTRIBUTE_BARS:ForceShow(state)
		end,
	}
	
	settings:AddSettings({displayValues, displayReticleValues, forceVisible})
end

function HarvensAttributeBars.OnLoaded(eventType, addonName)
	if addonName ~= "HarvensAttributeBars" then return end
	
	defaults = {displayValue = 1, displayReticleValue = 1, forceVisible = false}
	
	HarvensAttributeBars.sv = ZO_SavedVars:New("HarvensAttributeBars_SavedVariables", 1, nil, defaults)
	HarvensAttributeBars.displayValueNumToString = {
		[0] = "None",
		[1] = "Min/Max",
		[2] = "Precentage",
	}
	
	HarvensAttributeBars.attributes = {}
	HarvensAttributeBars.unitName = GetUnitName("player")
	
	local health = GetControl(PLAYER_ATTRIBUTE_BARS.control, "Health")
	local healthTable = { 
		label = WINDOW_MANAGER:CreateControlFromVirtual(health:GetName().."HarvensLabel", health, "HarvensAttributeBarsLabel"),
		statIndex = STAT_HEALTH_MAX,
		statRegenIndex = STAT_HEALTH_REGEN_IDLE,
		statRegenInCombatIndex = STAT_HEALTH_REGEN_COMBAT,
		regenLabel = WINDOW_MANAGER:CreateControlFromVirtual(health:GetName().."HarvensRegenLabel", health, "HarvensAttributeBarsLabel"),
		diffLabel = WINDOW_MANAGER:CreateControlFromVirtual(health:GetName().."HarvensDiffLabel", health, "HarvensAttributeBarsLabel"),
		lastVal = 0,
	}
	healthTable.label:SetAnchor(BOTTOM, health, TOP, 0, 2)
	healthTable.regenLabel:SetAnchor(RIGHT, healthTable.label, LEFT, -8, 0)
	healthTable.regenLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	healthTable.diffLabel:SetAnchor(LEFT, healthTable.label, RIGHT, 8, 0)
	healthTable.diffFade = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensAttributeBarsDiffFade", healthTable.diffLabel)
	HarvensAttributeBars.attributes[POWERTYPE_HEALTH] = healthTable
	
	local stamina = GetControl(PLAYER_ATTRIBUTE_BARS.control, "Stamina")
	local staminaTable = {
		label = WINDOW_MANAGER:CreateControlFromVirtual(stamina:GetName().."HarvensLabel", stamina, "HarvensAttributeBarsLabel"),
		statIndex = STAT_STAMINA_MAX,
		statRegenIndex = STAT_STAMINA_REGEN_IDLE,
		statRegenInCombatIndex = STAT_STAMINA_REGEN_COMBAT,
		regenLabel = WINDOW_MANAGER:CreateControlFromVirtual(stamina:GetName().."HarvensRegenLabel", stamina, "HarvensAttributeBarsLabel"),
		diffLabel = WINDOW_MANAGER:CreateControlFromVirtual(stamina:GetName().."HarvensDiffLabel", stamina, "HarvensAttributeBarsLabel"),
		lastVal = 0,
	}
	staminaTable.label:SetAnchor(BOTTOMLEFT, stamina, TOPLEFT, 0, 2)
	staminaTable.regenLabel:SetAnchor(LEFT, staminaTable.label, RIGHT, 8, 0)
	staminaTable.regenLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	staminaTable.diffLabel:SetAnchor(LEFT, staminaTable.regenLabel, RIGHT, 8, 0)
	staminaTable.diffFade = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensAttributeBarsDiffFade", staminaTable.diffLabel)
	HarvensAttributeBars.attributes[POWERTYPE_STAMINA] = staminaTable
	
	local magicka = GetControl(PLAYER_ATTRIBUTE_BARS.control, "Magicka")
	local magickaTable = {
		label = WINDOW_MANAGER:CreateControlFromVirtual(magicka:GetName().."HarvensLabel", magicka, "HarvensAttributeBarsLabel"),
		statIndex = STAT_MAGICKA_MAX,
		statRegenIndex = STAT_MAGICKA_REGEN_IDLE,
		statRegenInCombatIndex = STAT_MAGICKA_REGEN_COMBAT,
		regenLabel = WINDOW_MANAGER:CreateControlFromVirtual(magicka:GetName().."HarvensRegenLabel", magicka, "HarvensAttributeBarsLabel"),
		diffLabel = WINDOW_MANAGER:CreateControlFromVirtual(magicka:GetName().."HarvensDiffLabel", magicka, "HarvensAttributeBarsLabel"),
		lastVal = 0,
	}
	magickaTable.label:SetAnchor(BOTTOMRIGHT, magicka, TOPRIGHT, 0, 2)
	magickaTable.regenLabel:SetAnchor(RIGHT, magickaTable.label, LEFT, -8, 0)
	magickaTable.regenLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	magickaTable.diffLabel:SetAnchor(RIGHT, magickaTable.regenLabel, LEFT, -8, 0)
	magickaTable.diffFade = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensAttributeBarsDiffFade", magickaTable.diffLabel)
	HarvensAttributeBars.attributes[POWERTYPE_MAGICKA] = magickaTable
	
	EVENT_MANAGER:RegisterForEvent("HarvensAttributeBarsPlayerActivated", EVENT_PLAYER_ACTIVATED, HarvensAttributeBars.PlayerActivated)
	EVENT_MANAGER:RegisterForEvent("HarvensAttributeBarsPowerUpdate", EVENT_POWER_UPDATE, HarvensAttributeBars.PowerUpdate)
	EVENT_MANAGER:RegisterForEvent("HarvensAttributeBarsStatsUpdate", EVENT_STATS_UPDATED, HarvensAttributeBars.EventStatsUpdate)
	EVENT_MANAGER:RegisterForEvent("HarvensAttributeBarsCombatState", EVENT_PLAYER_COMBAT_STATE, HarvensAttributeBars.EventCombatState)
	
	HarvensAttributeBars.lastHP = 0

	HarvensAttributeBars.reticleLabel = WINDOW_MANAGER:CreateControlFromVirtual(ZO_TargetUnitFramereticleover:GetName().."HarvensLabel", ZO_TargetUnitFramereticleover, "HarvensAttributeBarsLabel")
	HarvensAttributeBars.reticleLabel:SetAnchor(TOP, ZO_TargetUnitFramereticleover, BOTTOM)
	HarvensAttributeBars.reticleDiff = WINDOW_MANAGER:CreateControlFromVirtual(ZO_TargetUnitFramereticleover:GetName().."HarvensDiffLabel", ZO_TargetUnitFramereticleover, "HarvensAttributeBarsLabel")
	HarvensAttributeBars.reticleDiff:SetAnchor(LEFT, HarvensAttributeBars.reticleLabel, RIGHT, 8, 0)
	HarvensAttributeBars.reticleDiffFade = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensAttributeBarsDiffFade", HarvensAttributeBars.reticleDiff)
	
	if HarvensAttributeBars.sv.displayReticleValue ~= 0 then
		local _, point, _, relPoint, x, y = ZO_TargetUnitFramereticleoverTextArea:GetAnchor(0)
		ZO_TargetUnitFramereticleoverTextArea:ClearAnchors()
		ZO_TargetUnitFramereticleoverTextArea:SetAnchor(point, HarvensAttributeBars.reticleLabel, relPoint, x, y-6)
	else
		HarvensAttributeBars.reticleLabel:SetHidden(true)
		HarvensAttributeBars.reticleDiff:SetHidden(true)
	end
	
--	HarvensAttributeBars.reticleMagicka = WINDOW_MANAGER:CreateControlFromVirtual(ZO_TargetUnitFramereticleover:GetName().."HarvensMagickaBar", ZO_TargetUnitFramereticleover, "ReticleMagickaBar")
--	HarvensAttributeBars.reticleMagicka:SetAnchor(TOP, ZO_TargetUnitFramereticleover, BOTTOM)
	
	PLAYER_ATTRIBUTE_BARS:ForceShow(HarvensAttributeBars.sv.forceVisible)
	
	EVENT_MANAGER:RegisterForEvent("HarvensAttributeBarsReticleTargetChanged", EVENT_RETICLE_TARGET_CHANGED, HarvensAttributeBars.EventReticleTargetChanged)
	
	HarvensAttributeBars:SetupOptions()
end

EVENT_MANAGER:RegisterForEvent("HarvensAttributeBarsOnLoaded", EVENT_ADD_ON_LOADED, HarvensAttributeBars.OnLoaded)