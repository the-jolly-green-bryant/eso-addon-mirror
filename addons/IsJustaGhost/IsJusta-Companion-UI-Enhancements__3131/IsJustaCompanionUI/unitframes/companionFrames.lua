
local STRING_CUSTOM = GetString(SI_GRAPHICSPRESETS7)
local frameStyles = {STRING_CUSTOM}
local NUM_FRAME_STYLES = 1

IJA_CompanionUnitFrame_Style_Custom = 1

do
	local optionalFrameStyles = {'BUI'}
	for k, name in ipairs(optionalFrameStyles) do
		if _G[name] then
			NUM_FRAME_STYLES = NUM_FRAME_STYLES + 1
			frameStyles[k + 1] = name
			_G['IJA_CompanionUnitFrame_Style_'  .. name] = k + 1
		end
	end
end

local formatStyleList = {STRING_CUSTOM}
local NUM_HEALTH_STYLES = 1

do
	local optionalFormatStyles = {'BUI', 'Azurah'}
	for k, name in ipairs(optionalFormatStyles) do
		if _G[name] then
			formatStyleList[k + 1] = name
			NUM_HEALTH_STYLES = NUM_HEALTH_STYLES + 1
		end
	end
end

--[[
IJA_CompanionUnitFrame_Style_BUI

]]

-- these anchors are set after initialization
local COMPANION_FRAME_ANCHOR_ORIGINAL
local COMPANION_FRAME_ANCHOR

local Default_Health_Gradient = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH]
local Default_Shield_Gradient = {ZO_ColorDef:New(.25, .25, .5, 1), ZO_ColorDef:New(.5, .5, 1, .5)}

---------------------------------------------------------------------------------------------------------------
-- Helper functions
---------------------------------------------------------------------------------------------------------------
local function isCompanionNotActive()
	return not HasActiveCompanion() and not HasPendingCompanion()
end

local function getColoredLevel(unitTag)
	local level = GetUnitLevel(unitTag)
	local i = level <= 5 and 1 or level <= 10 and 2 or level <= 15 and 3 or level < 20 and 4 or level == 20 and 5
	local color = GetItemQualityColor(i)
	
--	local color = ZO_ColorDef:New(level <= 5 and 'ffffff' or level <= 10 and '66ff66' or level <= 15 and '3366ff' or level < 20 and 'b366ff' or level == 20 and 'ffff00')
	
	local color = ZO_ColorDef:New('66ff66')
	return color:Colorize(level)
end

local function getGradient(gradient)
	local r, g, b, a = gradient.r, gradient.g, gradient.b, gradient.a
	return ZO_ColorDef:New(r, g, b, a)
end

local function getDimensions(control)
	local name = control:GetName()
	
	return savedVars.dimensions[name].width, savedVars.dimensions[name].height
end

local function getAbrreviatedNumber(current, useUppercaseSuffixes)
	if useUppercaseSuffixes ~= nil then
		return ZO_AbbreviateAndLocalizeNumber(current, NUMBER_ABBREVIATION_PRECISION_TENTHS, useUppercaseSuffixes)
	end
	local shortAmount, suffix = AbbreviateNumber(current, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES)
	return shortAmount .. suffix
end

---------------------------------------------------------------------------------------------------------------
-- CompanionFrame_StatusBar
---------------------------------------------------------------------------------------------------------------
local CompanionFrame_StatusBar = ZO_InitializingObject:Subclass()

function CompanionFrame_StatusBar:Initialize(name, parent, layoutData)
	local barControl = parent:GetNamedChild(name)
	local anchor = layoutData.anchor
	local xOffset = layoutData.xOffset or 0
	local maxHealth = select(2 ,GetUnitPower(self.unitTag, POWERTYPE_HEALTH))

	self.barControl = barControl
	self.gradientColorTable = layoutData.gradient
	
	self.xOffset = xOffset
	barControl:SetMinMax(0, maxHealth)
	barControl:SetValue(0, maxHealth, true)
	
	self:SetGradientColor()
	
	if anchor ~= nil then
	--	self:SetAnchor(anchor)
	end
end

function CompanionFrame_StatusBar:SetAnchor(anchor)
	anchor:Set(self.barControl)
end

function CompanionFrame_StatusBar:SetDimensions(width, height)
	self.barControl:SetDimensions(width, height)
end

function CompanionFrame_StatusBar:SetGradientColor(gradientColorTable)
	gradientColorTable = gradientColorTable or self.gradientColorTable
    if self.barControl and gradientColorTable then
        local r, g, b, a = getGradient(gradientColorTable[2])
        local r1, g1, b1, a1 = getGradient(gradientColorTable[1])
		
		ZO_StatusBar_SetGradientColor(self.barControl, {ZO_ColorDef:New(r, g, b, a), ZO_ColorDef:New(r1, g1, b1, a1)})
    end
end

function CompanionFrame_StatusBar:SetValue(currentValue, maxValue, forceInit)
	ZO_StatusBar_SmoothTransition(self.barControl, currentValue, maxValue, forceInit)
end

function CompanionFrame_StatusBar:Update(cur, max, forceInit)
	local barCur = cur
	local barMax = max
	
	local updateBarType = false
	local updateValue = cur ~= self.currentValue or self.maxValue ~= max
	
	if updateValue then
		self.currentValue = cur
		self.maxValue = max
		
		ZO_StatusBar_SmoothTransition(self.barControl, barCur, barMax, forceInit)
	end
end

local function shieldOverlayUpdate(self, cur, max, forceInit)
	local barCur = cur
	local barMax = max
	
	local healthBar = self.barControl:GetParent()
	if forceInit then
		-- used on shield applied to set the bar width so 100% will will reflect the amount of shield applied vs max health
		local shieldPct = max / (healthBar.max or 1)
		local width, height = healthBar:GetDimensions()
		width = math.min(shieldPct, 1) * (width)
		self.barControl:SetDimensions(width, height)
	end
	
	local updateBarType = false
	local updateValue = cur ~= self.currentValue or self.maxValue ~= max
	if updateValue then
		self.currentValue = cur
		self.maxValue = max
		
		ZO_StatusBar_SmoothTransition(self.barControl, barCur, barMax, forceInit)
	end
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local CompanionFrame_Object = ZO_Object:Subclass()

function CompanionFrame_Object:New(parent, template)
	local newObject = ZO_Object:MultiSubclass(self, template)
   newObject:Initialize(parent)
   return newObject
end

function CompanionFrame_Object:Initialize(parent)
	zo_mixin(self, parent)
	self.unitTag = 'companion'
	
	self:PerformDeferredInitialization()
	
	local layoutData = self:GetLayoutData()
	
	local frame = IJA_CompanionUnit:GetNamedChild('Frame')
	self.frame = frame
	
	self.background				= frame:GetNamedChild('Background')
	self.nameLabel				= frame:GetNamedChild('Name')
	self.statusLabel			= frame:GetNamedChild('Status')
	self.healthValue			= frame:GetNamedChild('Value')
	
	local healthBar				= CompanionFrame_StatusBar:New('Hp', frame, layoutData.healthBarTemplateData)
	self.shieldOverlay			= CompanionFrame_StatusBar:New('ShieldOverlay', healthBar.barControl, layoutData.shieldOverlayTemplateData)
	
	
	ZO_PreHookHandler(healthBar.barControl, "OnMinMaxValueChanged", function(_, min, max)
		healthBar.max = max
	--	updateShield(healthBar.healthBar, info)
		shieldOverlay:SetMinMax(min, max)
	end)
	ZO_PreHookHandler(healthBar.barControl, "OnValueChanged", function(_, value)
		healthBar.current = value
	end)
			
	self.shieldOverlay.Update = shieldOverlayUpdate
	
	self.healthBar				= healthBar
	
	self.animateShowHide = true
end

function CompanionFrame_Object:SetHealthValue(valueString)
	self:HideHealthValue(valueString == '')
	self.healthValue:SetText(valueString)
end

function CompanionFrame_Object:UpdateStatus(isDead, isPending)
	local hideBars = (isDead == true) or isPending
	
	self:SetBarsHidden(hideBars)
	self:HideHealthValue(hideBars)
	self.statusLabel:SetHidden(not hideBars)
	
	local hideName = self.hideNameOnStatus and isPending or false
	self.nameLabel:SetHidden(hideName)
	
	if isDead then
		self.statusLabel:SetText(GetString(SI_UNIT_FRAME_STATUS_DEAD))
	elseif isPending then
		self.statusLabel:SetText(GetString(SI_UNIT_FRAME_STATUS_SUMMONING))
	else
		self.statusLabel:SetText("")
	end
end

function CompanionFrame_Object:UpdateName(hasPendingCompanion)
	local displayname = ''
	
	self.healthValue:SetHidden(hasPendingCompanion)
	if hasPendingCompanion then
		displayname = zo_strformat(SI_COMPANION_NAME_FORMATTER, GetCompanionName(GetPendingCompanionDefId()))
	else
		local level = getColoredLevel(self.unitTag)
		displayname = (self.savedVars.showLevel and level .. " " or "") .. GetUnitName(self.unitTag)
	end
	self.nameLabel:SetText(displayname)
end

function CompanionFrame_Object:SetHidden(hidden)
	self.frame:SetHidden(hidden)
end

function CompanionFrame_Object:CreateFrame(name)
end

---------------------------------------------------------------------------------------------------------------
-- CompanionFrame_Manager
---------------------------------------------------------------------------------------------------------------
local CompanionFrame_Manager = ZO_InitializingObject:Subclass()

function CompanionFrame_Manager:Initialize(parent)
	zo_mixin(self, parent)
	
	self.unitTag = 'companion'
	
	COMPANION_FRAME_ANCHOR_ORIGINAL = ZO_Anchor:New(TOPLEFT, ZO_SmallGroupAnchorFrame, TOPLEFT, 70, 60)
	COMPANION_FRAME_ANCHOR = ZO_Anchor:New(TOPLEFT, ZO_SmallGroupAnchorFrame, TOPLEFT, 70, 60)

	self.style = 0
	self.companionFrames = {}
end

function CompanionFrame_Manager:PerformDeferredInitialization()
	if not self.savedVars.useCompanionFrame then return end
	
	for i = 1, #frameStyles do
		local style = i == 1 and 'ZOS' or frameStyles[i]
		local getTemplate = _G['IJA_CompanionFrames_' .. style .. '_Template']
		self.companionFrames[i] = CompanionFrame_Object:New(self, getTemplate(self))
	end
	
	self:RegisterEvents()
	
	self:SetStyle(self.savedVars.selectedFrameStyle)
	
	local disabled = not HasActiveCompanion()
	self:SetDisabledState(disabled)
	
	self.initialized = true
	
	local function OnGamepadPreferredModeChanged()
		self:ApplyVisualStyle()
	end
	ZO_PlatformStyle:New(OnGamepadPreferredModeChanged)
	
	IJA_CompanionUnitFrame:SetHandler("OnMoveStop", function(control) self:OnMoveStop(control) end)
	self:SetLocked(self.savedVars.locked)
	self:SetAnchor()
end

function CompanionFrame_Manager:ApplyVisualStyle()
	local companionFrame = self.selectedFrame
	if companionFrame == nil then return end
	companionFrame:ApplyVisualStyle()
end

function CompanionFrame_Manager:GetLayoutData()
	local companionFrame = self.selectedFrame
	if companionFrame == nil then return end
	return companionFrame:GetLayoutData()
end

function CompanionFrame_Manager:SetStyle(style)
	if self.style ~= style then
		self.style = style
		self.selectedFrame = self.companionFrames[style]
		self:ApplyVisualStyle()
	end
end

function CompanionFrame_Manager:GetHealth()
	return GetUnitPower(self.unitTag, POWERTYPE_HEALTH)
end
	
function CompanionFrame_Manager:IsDisabled()
	return self.disabled
end
	
function CompanionFrame_Manager:SetScale()
	local companionFrame = self.selectedFrame
	if companionFrame then
		companionFrame:SetScale()
	end
end

function CompanionFrame_Manager:SetOccupancy()
	local companionFrame = self.selectedFrame
	if companionFrame then
		companionFrame:SetOccupancy()
	end
end

function CompanionFrame_Manager:FormatHealthValue(current, maximum, effMax, shield, overrideSetting)
	if HasPendingCompanion() then return '' end
	
    local returnValue = ""
    local percent = 0
    local shield = shield or 0
	
    if maximum ~= 0 then
        percent = (current/maximum) * 100
        if percent < 10 then
            percent = ZO_CommaDelimitDecimalNumber(zo_roundToNearest(percent, .1))
            percent = ZO_FastFormatDecimalNumber(percent)
        else
            percent = zo_round(percent)
        end
    end
	
    local USE_LOWERCASE_NUMBER_SUFFIXES = false
    local setting = overrideSetting or self.style == 1 and self.savedVars.valueFormat or 0
	
	local function useOptionalFormat(key)
		return self.style == 1 and self.savedVars.valueStyle == key or self.style == key
	end
	
	if setting == RESOURCE_NUMBERS_SETTING_NUMBER_ONLY  then
		returnValue = ZO_AbbreviateAndLocalizeNumber(current, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES)
	elseif setting == RESOURCE_NUMBERS_SETTING_PERCENT_ONLY then
		returnValue = percent .. '%'
	elseif setting == RESOURCE_NUMBERS_SETTING_NUMBER_AND_PERCENT then
		returnValue = zo_strformat(SI_ATTRIBUTE_NUMBERS_WITH_PERCENT, ZO_AbbreviateAndLocalizeNumber(current, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES), percent)
	--	returnValue = zo_strformat('<<1>> (<<2>>%)', ZO_LocalizeDecimalNumber(current), percent)
	elseif useOptionalFormat(2) and BUI then
			local ShowMax = BUI.Vars.FrameShowMax
			local short = current > 100000
			returnValue = (short and BUI.DisplayNumber(current/1000,1) or BUI.DisplayNumber(current))
				.. (ShowMax and "/" .. ((short and BUI.DisplayNumber(maximum/1000,1) or BUI.DisplayNumber(maximum))) or "")
				
		elseif useOptionalFormat(3) and Azurah.db.attributes.healthOverlay > 1 then
			local formatFunction = Azurah.overlayFuncs[Azurah.db.attributes.healthOverlay + ((Azurah.db.attributes.healthOverlayFancy) and 10 or 0)]
			returnValue = formatFunction(current, maximum, effMax, shield)
		end
		
    return returnValue
end

function CompanionFrame_Manager:UpdateBackground()
	
end

function CompanionFrame_Manager:SetBarsHidden(hidden)
	local companionFrame = self.selectedFrame
	if companionFrame == nil then return end
	companionFrame:SetBarsHidden(hidden)
end

function CompanionFrame_Manager:SetLocked(locked)
	IJA_CompanionUnitFrame:SetMovable(not locked)
	IJA_CompanionUnitFrame.lock:SetHidden(locked)
end

function CompanionFrame_Manager:OnMoveStop(control)
	COMPANION_FRAME_ANCHOR:SetFromControlAnchor(control)
	self.savedVars.anchor = COMPANION_FRAME_ANCHOR
	self.savedVars.isMoved = true
end

function CompanionFrame_Manager:SetAnchor()
	if self.savedVars.isMoved then
		COMPANION_FRAME_ANCHOR:ResetToAnchor(self.savedVars.anchor)
		COMPANION_FRAME_ANCHOR:SetTarget(GuiRoot)
		COMPANION_FRAME_ANCHOR:Set(IJA_CompanionUnitFrame)
	else
		COMPANION_FRAME_ANCHOR_ORIGINAL:Set(IJA_CompanionUnitFrame)
	end
end

---------------------------------------------------------------------------------------------------------------
-- update frame
---------------------------------------------------------------------------------------------------------------
function CompanionFrame_Manager:SetDisabledState(disabled)
	local companionFrame = self.selectedFrame
	if companionFrame == nil then return end
	self.disabled = companionFrame:GetDisabledState(disabled)
	
	if IsUnitGrouped("player") then
		-- if "Use Group Frame" is not enabled, the player's companion will not be included in the refresh.
		UNIT_FRAMES:SetGroupIndexDirty(1)
	end
	self:UpdateFrame()
end

function CompanionFrame_Manager:ComputeHidden()
	if not self.hasActiveCompanion and not self.hasPendingCompanion then
		return true
	end
	
	return self.disabled
end

function CompanionFrame_Manager:RefreshVisible(instant)
	local companionFrame = self.selectedFrame
    local hidden = self:ComputeHidden()
	
    if hidden ~= self.hidden then
        self.hidden = hidden
        if not hidden and self.dirty then
            self.dirty = nil
            self:RefreshControls()
        end
		
        if not instant then
            if not self.showHideTimeline then
                self.showHideTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_UnitFrameFadeAnimation", companionFrame.frame)
            end
			
            if hidden then
                if self.showHideTimeline:IsPlaying() then
                    self.showHideTimeline:PlayBackward()
                else
                    self.showHideTimeline:PlayFromEnd()
                end
            else
                if self.showHideTimeline:IsPlaying() then
                    self.showHideTimeline:PlayForward()
                else
                    self.showHideTimeline:PlayFromStart()
                end
            end
        else
            if self.showHideTimeline then
                self.showHideTimeline:Stop()
            end
            companionFrame:SetHidden(hidden)
        end
    end
end

function CompanionFrame_Manager:RefreshControls()
	local companionFrame = self.selectedFrame
	if self.hidden then
		self.dirty = true
	else
		if self.hasActiveCompanion then
			self:UpdateName()
			
			local current, maxHealth, powerEffMax = self:GetHealth()
			
			self:UpdateShieldOverlay(self.unitTag, POWERTYPE_HEALTH, 0, maxHealth * 0.6, FORCE_INIT)
			self:UpdateHealthBar(self.unitTag, POWERTYPE_HEALTH)
			
			--Since we have a target, there is nothing pending
			local NOT_PENDING = false
			self:UpdateStatus(IsUnitDead(self.unitTag), NOT_PENDING)
		elseif self.hasPendingCompanion then
			self:UpdateName(true)
			--Since there is technically no unit yet, we need to pretend there is one that is not dead and is online
			local NOT_DEAD = false
			self:UpdateStatus(NOT_DEAD, self.hasPendingCompanion)
		end
	end
end

function CompanionFrame_Manager:SetGradient(statusBar, gradientColorTable)
	local companionFrame = self.selectedFrame
	if companionFrame == nil then return end
	companionFrame[statusBar]:SetGradientColor(gradientColorTable)
end

function CompanionFrame_Manager:UpdateFrame()
	if not self.zosInit then self:PrepareZO_UnitFrames() end
	
	local companionFrame = self.selectedFrame
	self.hasActiveCompanion = HasActiveCompanion()
	self.hasPendingCompanion = HasPendingCompanion()
	
	if companionFrame then
		local ANIMATED = false
		self:RefreshVisible(ANIMATED)
		self:RefreshControls()
		
	end
end

---------------------------------------------------------------------------------------------------------------
-- Update stats
---------------------------------------------------------------------------------------------------------------
function CompanionFrame_Manager:UpdateName(hasPendingCompanion)
	local companionFrame = self.selectedFrame
	if companionFrame == nil then return end
	companionFrame:UpdateName(hasPendingCompanion)
end

function CompanionFrame_Manager:UpdateStatus(isDead, isPending)
	local companionFrame = self.selectedFrame
	if companionFrame == nil then return end
	companionFrame:UpdateStatus(isDead, isPending)
end

function CompanionFrame_Manager:UpdateHealthValue(unitTag, powerType, current, powerMax, powerEffMax, shield)
	local companionFrame = self.selectedFrame
	if (current == nil) then
	
		current, powerMax, powerEffMax = self:GetHealth()
		companionFrame.healthBar.max = powerMax
		companionFrame.healthBar.powerEffMax = powerEffMax
		companionFrame.healthBar.current = current
	end

	if (powerType == POWERTYPE_HEALTH) then
		local valueString = self:FormatHealthValue(current, powerMax, powerEffMax, shield)
		
		companionFrame:SetHealthValue(valueString)
	end
end

function CompanionFrame_Manager:UpdateHealthBar(unitTag, powerType, current, powerMax, powerEffMax)
	local companionFrame = self.selectedFrame
	if companionFrame == nil then return end
	
	local forceInit = false
	if (current == nil) then
		current, powerMax, powerEffMax = self:GetHealth()
		forceInit = true
	end

	companionFrame.healthBar:SetValue(current, powerMax, forceInit)
	self:UpdateHealthValue(unitTag, powerType, current, powerMax, powerEffMax, 0)
end

function CompanionFrame_Manager:UpdateShieldOverlay(unitTag, powerType, shieldValue, shieldMax, forceInit)
	local companionFrame = self.selectedFrame
	if companionFrame == nil then return end
	
	if forceInit then
		-- set dimensions
		local shieldPct = shieldMax / (companionFrame.healthBar.max or 1)
	--	local xOffset = unitFrame.shieldOverlay.xOffset
		local width, height = companionFrame.healthBar.barControl:GetDimensions()
		width = math.min(shieldPct, 1) * (width)
	--	companionFrame.shieldOverlay:SetDimensions(width, height)
		
		companionFrame:SetShieldOverlayDimmensions(width, height)
	end

	companionFrame.shieldOverlay:SetValue(shieldValue, shieldMax, forceInit)
	self:UpdateHealthValue(unitTag, powerType, powerValue, powerMax, powerEffMax, shieldValue)
end

---------------------------------------------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------------------------------------------
function CompanionFrame_Manager:RegisterEvents()
	local function updateLocalCompanion()
		self:SetDisabledState(not HasActiveCompanion())
	end
	IJA_CompanionUnit:RegisterForEvent(EVENT_LEVEL_UPDATE, updateLocalCompanion)
--	IJA_CompanionUnit:AddFilterForEvent(EVENT_LEVEL_UPDATE, REGISTER_FILTER_UNIT_TAG, self.unitTag)

	IJA_CompanionUnit:RegisterForEvent(EVENT_GROUP_UPDATE, updateLocalCompanion)
	IJA_CompanionUnit:RegisterForEvent(EVENT_GROUP_MEMBER_JOINED, updateLocalCompanion)
	IJA_CompanionUnit:RegisterForEvent(EVENT_GROUP_MEMBER_LEFT, updateLocalCompanion)
	
--[[
	COMPANION_STATE_INACTIVE = 0
	COMPANION_STATE_BLOCKED_PERMANENT = 1
	COMPANION_STATE_BLOCKED_TEMPORARY = 2
	COMPANION_STATE_INITIALIZING = 3
	COMPANION_STATE_INITIALIZED_PENDING = 4
	COMPANION_STATE_PENDING = 5
	COMPANION_STATE_HIDDEN = 6
	COMPANION_STATE_ACTIVE = 7
]]

	local INACTIVE_COMPANION_STATES = {
		[COMPANION_STATE_INACTIVE] = true,
		[COMPANION_STATE_BLOCKED_PERMANENT] = true,
		[COMPANION_STATE_BLOCKED_TEMPORARY] = true,
		[COMPANION_STATE_HIDDEN] = true,
		[COMPANION_STATE_INITIALIZING] = true,
	}
	local function OnCompanionStateChanged(eventCode, newState, oldState)
		local disabled = INACTIVE_COMPANION_STATES[newState] or false
		self:SetDisabledState(disabled)
	end
	IJA_CompanionUnit:RegisterForEvent(EVENT_ACTIVE_COMPANION_STATE_CHANGED, OnCompanionStateChanged)
	
	local function OnUnitDeathStateChanged(_, unitTag, isDead)
		if self:IsDisabled() then return end
		self:UpdateStatus(isDead, HasPendingCompanion())
	end
	IJA_CompanionUnit:RegisterForEvent(EVENT_UNIT_DEATH_STATE_CHANGED, OnUnitDeathStateChanged)
--	IJA_CompanionUnit:AddFilterForEvent(EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, self.unitTag)
	
	-- health bar update
	local function OnPowerUpdate(_, unitTag, _, powerType, powerValue, powerMax, powerEffMax)
		if self:IsDisabled() then return end
		self:UpdateHealthBar(unitTag, powerType, powerValue, powerMax, powerEffMax)
	end
	IJA_CompanionUnit:RegisterForEvent(EVENT_POWER_UPDATE, OnPowerUpdate)
--	IJA_CompanionUnit:AddFilterForEvent(EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, self.unitTag)
--	IJA_CompanionUnit:AddFilterForEvent(EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
	
	-- shield overlay update
	local function OnUnitAttributeVisualAdded(_, unitTag, visualType, stat, attribute, powerType, value, maxValue, sequenceId)
		if self:IsDisabled() then return end
		if powerType == POWERTYPE_HEALTH and visualType == ATTRIBUTE_VISUAL_POWER_SHIELDING then
			self:UpdateShieldOverlay(unitTag, powerType, value, maxValue, true)
		end
	end
	IJA_CompanionUnit:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnUnitAttributeVisualAdded)
--	IJA_CompanionUnit:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, self.unitTag)
--	IJA_CompanionUnit:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
	
	local function OnUnitAttributeVisualUpdated(_, unitTag, visualType, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
		if self:IsDisabled() then return end
		if powerType == POWERTYPE_HEALTH and visualType == ATTRIBUTE_VISUAL_POWER_SHIELDING then
			self:UpdateShieldOverlay(unitTag, powerType, newValue, newMaxValue)
		end
	end
	IJA_CompanionUnit:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnUnitAttributeVisualUpdated)
--	IJA_CompanionUnit:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, self.unitTag)
--	IJA_CompanionUnit:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
	
	local function OnUnitAttributeVisualRemoved(_, unitTag, visualType, stat, attribute, powerType, value, maxValue, sequenceId)
		if self:IsDisabled() then return end
		if powerType == POWERTYPE_HEALTH and visualType == ATTRIBUTE_VISUAL_POWER_SHIELDING then
			self:UpdateShieldOverlay(unitTag, powerType, 0, 1)
		end
	end
	IJA_CompanionUnit:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnUnitAttributeVisualRemoved)
--	IJA_CompanionUnit:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, self.unitTag)
--	IJA_CompanionUnit:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
	
	
	local eventFilters = {EVENT_LEVEL_UPDATE, EVENT_UNIT_DEATH_STATE_CHANGED, EVENT_POWER_UPDATE, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED}
	for k, eventId in pairs(eventFilters) do
		IJA_CompanionUnit:AddFilterForEvent(eventId, REGISTER_FILTER_UNIT_TAG, self.unitTag)
		
		if eventId ~= EVENT_UNIT_DEATH_STATE_CHANGED and eventId ~= EVENT_LEVEL_UPDATE then
			IJA_CompanionUnit:AddFilterForEvent(eventId, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
		end
	end
	
	local function onplayeractivated()
		if self:IsDisabled() then return end
		self:UpdateFrame()
	end
	IJA_CompanionUnit:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onplayeractivated)
end

function CompanionFrame_Manager:PrepareZO_UnitFrames()
	local unitFrame = UNIT_FRAMES:GetFrame(self.unitTag)
	
	if unitFrame then
		function unitFrame:SetHiddenForReason(reason, hidden)
			hidden = true
			if self.hiddenReasons:SetHiddenForReason(reason, hidden) then
				local INSTANT = true
				self:RefreshVisible(INSTANT)
			end
		end

		unitFrame:SetHiddenForReason('disabled', true)
		
		ZO_UnitFrames:UnregisterForEvent(EVENT_ACTIVE_COMPANION_STATE_CHANGED)
	
		-- Below is used to remove the player's companion from the group frame if "Use Group Frame" is not enabled.
		local function hideCompanionFromGroup()
			return not self.savedVars.useGroupFrame
		end
		
		local original_GetCompanionUnitTagByGroupUnitTag = GetCompanionUnitTagByGroupUnitTag
		function GetCompanionUnitTagByGroupUnitTag(unitTag)
			local groupCompanionUnitTag = original_GetCompanionUnitTagByGroupUnitTag(unitTag)
			if unitTag == GetLocalPlayerGroupUnitTag() and hideCompanionFromGroup() then
				return 'hide'
			end
			
			return groupCompanionUnitTag
		end
		
		function UNIT_FRAMES:UpdateCompanionGroupSize()
			local companionGroupSize = GetNumCompanionsInGroup()
			if hideCompanionFromGroup() and (HasActiveCompanion() or HasPendingCompanion()) then
				companionGroupSize = companionGroupSize - 1
			end
			
			self.companionGroupSize = companionGroupSize
		end
		
		self.zosInit = true
	end
end

---------------------------------------------------------------------------------------------------------------
-- Frame options
---------------------------------------------------------------------------------------------------------------
local isShield = false
local icons = {
	['SI_IJA_MCF_LOCK'] = {
		[1] = zo_iconFormat("/esoui/art/miscellaneous/gamepad/gp_icon_unlocked32.dds", "32", "32"),
		[2] = zo_iconFormat("/esoui/art/miscellaneous/gamepad/gp_icon_locked32.dds", "32", "32"),
		[3] = zo_iconFormat("/esoui/art/miscellaneous/gamepad/gp_icon_locked32_disabled.dds", "32", "32"),
	}
}
local function getSettingIcon(index, state)
	return state and icons[index][2] or icons[index][1]
end

function CompanionFrame_Manager:GetFrameOptions()
	local function PanelOpened(currentAddonPanel)
		EVENT_MANAGER:UnregisterForUpdate('InitializeOptionHandlers')
		local function onUpdate()
			if not IJA_CompanionUnit_FrameOptions then return end
			EVENT_MANAGER:UnregisterForUpdate('InitializeOptionHandlers')
			CALLBACK_MANAGER:UnregisterCallback("LAM-PanelOpened", PanelOpened)
			self:InitializeOptionHandlers(currentAddonPanel)
		end
		
		EVENT_MANAGER:RegisterForUpdate('InitializeOptionHandlers', 1, onUpdate)
	end
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", PanelOpened)
	
	local function disabled()
		return not (self.savedVars.useCompanionFrame and self.initialized)
	end
	
	local function styleDisabled(style)
		return disabled() or self.savedVars.selectedFrameStyle ~= style
	end
	
	local isCustomFrameEnabled = {
		['BUI'] = function() return not (disabled() and (BUI and BUI.Vars) and BUI.Vars.RaidFrames) or false end
	}
	
	local function applySetting(settingIndex, value, subKey, functionName, ...)
		local companionFrame = self.selectedFrame
		
		if subKey then
			self.savedVars[settingIndex][subKey] = value
		else
			self.savedVars[settingIndex] = value
		end
		
		if companionFrame then 
			local updateFunction = self[functionName]
			if updateFunction then
				updateFunction(self, ...)
			end
			
			self:ApplyVisualStyle()
		end
	end
	
	local function applyShieldGradient(value, subKey)
		self.savedVars.shieldGradient[subKey] = value
		local companionFrame = self.selectedFrame

		if companionFrame then
			local maxHealth = companionFrame.healthBar.max or 1
			-- set the shield to be 60% of health 
			local shieldValue = maxHealth * 0.6
			self:UpdateShieldOverlay(self.unitTag, POWERTYPE_HEALTH, shieldValue, shieldValue)
		end
	end
	
	local function getColors(key, subKey)
		local gradient = self.savedVars[key][subKey]
		return gradient.r, gradient.g, gradient.b, gradient.a
	end
	
	local function getChoiceValues(choices)
		local choicesValues = {}
		
		for k, v in ipairs(choices) do
			table.insert(choicesValues, k)
		end
		
		return choicesValues
	end
	
	local controlList = {
		{ type = "checkbox",	-- use frame
            name = GetString(SI_IJA_MCF_FRAME),
			tooltip = GetString(SI_IJA_MCF_FRAME_TOOLTIP),
            getFunc = function() return self.savedVars.useCompanionFrame end,
            setFunc = function(value) self.savedVars.useCompanionFrame = value end,
            width = "full",
			requiresReload = true,
        },
		{ type = "divider",
			height = 10,
		},
		{ type = "dropdown",	-- selectedFrameStyle
			name = GetString(SI_IJA_MCF_FRAMESTYLE),
			choices = frameStyles,
			choicesValues = getChoiceValues(frameStyles),
			getFunc = function() return self.savedVars.selectedFrameStyle end,
			setFunc = function(value)
				applySetting('selectedFrameStyle', value, nil, 'SetStyle', value)
				-- do refresh
			end,
			width = "full",
			disabled = function() return disabled() end,
		},
		{ type = "divider",
			height = 10,
		},
		{ type = "colorpicker",
			name = GetString(SI_IJA_MCF_GRADEINT_HEALTH_LEFT),
			tooltip = "Color Picker's tooltip text.",
			getFunc = function() return getColors('healthGradient', 2) end,
			setFunc = function(r,g,b,a)
				isShield = false
				applySetting('healthGradient', {r = r, g = g, b = b, a = a}, 2)
				self:SetGradient('healthBar', self.savedVars.healthGradient)
			end,
			disabled = function() return disabled() end,
			default = Default_Health_Gradient[2],
			width = "half", -- or "half" (optional)
		},
		{ type = "colorpicker",
			name = GetString(SI_IJA_MCF_GRADEINT_HEALTH_RIGHT),
			tooltip = "Color Picker's tooltip text.",
			getFunc = function() return getColors('healthGradient', 1) end,
			setFunc = function(r,g,b,a)
				isShield = false
				applySetting('healthGradient', {r = r, g = g, b = b, a = a}, 1)
				self:SetGradient('healthBar', self.savedVars.healthGradient)
			end,
			
			disabled = function() return disabled() end,
			default = Default_Health_Gradient[1],
			width = "half",
		},
		{ type = "button",		-- reset Health gradient
			name = GetString(SI_IJA_MCF_GRADEINT_HEALTH_RESET),
			func = function()
				self.savedVars.healthGradient = ZO_ShallowTableCopy(Default_Health_Gradient)
				self:SetGradient('healthBar', Default_Health_Gradient)
			end,
			disabled = function() return disabled() end,
            width = "full",
		},
		{ type = "colorpicker",
			name = GetString(SI_IJA_MCF_GRADEINT_SHEILD_LEFT),
			tooltip = "Color Picker's tooltip text.",
			getFunc = function() return getColors('shieldGradient', 1) end,
			setFunc = function(r,g,b,a)
				isShield = true
				applySetting('shieldGradient', {r = r, g = g, b = b, a = a}, 1)
				self:SetGradient('shieldOverlay', self.savedVars.shieldGradient)
			end,
			disabled = function() return disabled() end,
			default = Default_Shield_Gradient[1],
			reference = "IJA_CompanionUnit_FrameOptions_Shiled_Left",
			width = "half", -- or "half" (optional)
		},
		{ type = "colorpicker",
			name = GetString(SI_IJA_MCF_GRADEINT_SHEILD_RIGHT),
			tooltip = "Color Picker's tooltip text.",
			getFunc = function() return getColors('shieldGradient', 2) end,
			setFunc = function(r,g,b,a)
				isShield = true
				applySetting('shieldGradient', {r = r, g = g, b = b, a = a}, 2)
				self:SetGradient('shieldOverlay', self.savedVars.shieldGradient)
			end,
			disabled = function() return disabled() end,
			default = Default_Shield_Gradient[2],
			reference = "IJA_CompanionUnit_FrameOptions_Shiled_Right",
			width = "half", -- or "half" (optional)
		},
		{ type = "button",		-- reset Shield gradient
			name = GetString(SI_IJA_MCF_GRADEINT_SHEILD_RESET),
			func = function()
				self.savedVars.shieldGradient = ZO_ShallowTableCopy(Default_Shield_Gradient)
				self:SetGradient('shieldOverlay', Default_Shield_Gradient)
			end,
			disabled = function() return disabled() end,
            width = "full",
		},
		{ type = "divider",
			height = 10,
		},
		{ type = "checkbox",	-- lock
            name = zo_strformat(GetString(SI_IJA_MCF_LOCK), getSettingIcon('SI_IJA_MCF_LOCK', self.savedVars.locked)),
			tooltip = GetString(SI_IJA_MCF_LOCK_TOOLTIP),
            getFunc = function() return self.savedVars.locked end,
            setFunc = function(value)
				applySetting('locked', value, nil, 'SetLocked', value)
				IJA_MCF_LOCK.label:SetText(zo_strformat(GetString(SI_IJA_MCF_LOCK), getSettingIcon('SI_IJA_MCF_LOCK', value)))
            end,
			reference = "IJA_MCF_LOCK",
			disabled = function() return disabled() end,
            width = "full",
        },
		{ type = "divider",
			height = 10,
		},
		{ type = "button",		-- reset
			name = GetString(SI_IJA_MCF_COMPANIONFRAME_RESET),
			tooltip = GetString(SI_IJA_MCF_COMPANIONFRAME_RESET_TOOLTIP),
			func = function()
				self.savedVars.isMoved = false
				self:UpdateAnchor()
			end,
			disabled = function() return disabled() end,
            width = "full",
		},
		{ type = "header",
            name = GetString(SI_IJA_MCF_ZOS_HEADER),
			height = 10,
            width = "full",
		},
		{ type = "slider",		-- transparency
            name = GetString(SI_IJA_MCF_OCCUPANCY),
			tooltip = GetString(SI_IJA_MCF_OCCUPANCY_TOOLTIP),
			min = 0,
			max = 100,
			step = 10,
			getFunc = function() return self.savedVars.occupancy end,
			setFunc = function(value)
				applySetting('occupancy', value, nil)
			end,
			disabled = function() return styleDisabled(1) end,
			width = "full",
		},
		{ type = "checkbox",	-- show level in zos
            name = GetString(SI_IJA_MCF_SHOWLEVEL),
			tooltip = GetString(SI_IJA_MCF_SHOWLEVEL_TOOLTIP),
            getFunc = function() return self.savedVars.showLevel end,
            setFunc = function(value)
				applySetting('showLevel', value, nil, 'UpdateName')
            end,
			disabled = function() return styleDisabled(1) end,
            width = "full",
        },
		{ type = "checkbox",	-- use zos group frame
            name = GetString(SI_IJA_MCF_GROUPFRAME),
			tooltip = GetString(SI_IJA_MCF_GROUPFRAME_TOOLTIP),
            getFunc = function() return self.savedVars.useGroupFrame end,
            setFunc = function(value)
				applySetting('useGroupFrame', value, nil, 'SetDisabledState', not HasActiveCompanion())
            end,
			disabled = function() return styleDisabled(1) end,
            width = "full",
        },
		{ type = "checkbox",	-- hide bar background
            name = GetString(SI_IJA_MCF_HIDEBARBG),
			tooltip = GetString(SI_IJA_MCF_HIDEBARBG_TOOLTIP),
            getFunc = function() return self.savedVars.hideBarBg end,
            setFunc = function(value)
				applySetting('hideBarBg', value, nil)
            end,
			disabled = function() return styleDisabled(1) end,
            width = "full",
        },
		{ type = "slider",		-- scale
            name = GetString(SI_IJA_MCF_SCALE),
			tooltip = GetString(SI_IJA_MCF_SCALE_TOOLTIP),
			min = 50,
			max = 200,
			step = 1,
			getFunc = function() return self.savedVars.frameScale end,
			setFunc = function(value)
				applySetting('frameScale', value, nil, 'SetScale')
			end,
			disabled = function() return styleDisabled(1) end,
			width = "full",
		},
		{ type = "dropdown",
			name = GetString(SI_IJA_MCF_HEALTHSTYLE),
			choices = formatStyleList,
			choicesValues = getChoiceValues(formatStyleList),
			getFunc = function()
				return self.savedVars.valueStyle
			end,
			setFunc = function(value)
				self.savedVars.valueStyle = value
				
				if value > 1 then
					self.savedVars.valueFormat = 0
				end
				applySetting('valueStyle', value, nil, 'UpdateHealthValue', self.unitTag, POWERTYPE_HEALTH)
			end,
			width = "half",
			disabled = function() return styleDisabled(1) end,
		},
		{ type = "dropdown",
			name = GetString(SI_IJA_MCF_HEALTHFORMAT),
			choices = {GetString(SI_RESOURCENUMBERSSETTING0), GetString(SI_RESOURCENUMBERSSETTING1), GetString(SI_RESOURCENUMBERSSETTING2), GetString(SI_RESOURCENUMBERSSETTING3)},
			choicesValues = {0, 1, 2, 3},
			getFunc = function()
				return self.savedVars.valueFormat
			end,
			setFunc = function(value)
				self.savedVars.valueFormat = value
				applySetting('valueFormat', value, nil, 'UpdateHealthValue', self.unitTag, POWERTYPE_HEALTH)
			end,
			width = NUM_HEALTH_STYLES > 1 and "half" or "full",
			disabled = function() return (styleDisabled(1) and self.savedVars.valueStyle == 1) end,
		},
		{ type = "header",
            name = GetString(SI_IJA_MCF_BUI_HEADER),
			height = 10,
            width = "full",
			style = 'BUI'
		},
		{ type = "checkbox",	-- use bui fancy bar
            name = GetString(SI_IJA_MCF_BUI_USEFANCY),
			tooltip = GetString(SI_IJA_MCF_BUI_USEFANCY_TOOLTIP),
            getFunc = function() return self.savedVars.useFancyBar end,
            setFunc = function(value)
				applySetting('useFancyBar', value, nil, 'UpdateLocalCompanion')
            end,
			disabled = function() return styleDisabled(2) end,
            width = "full",
			style = 'BUI'
        }
	}
	
	function tableShift(tbl, start)
		local size = #tbl
		
		for i = start, size do
			tbl[i] = tbl[i + 1]
		end
		
		tbl[size] = nil
	end
	
	for k, entry in pairs(controlList) do
		if entry.type == "dropdown" and #entry.choices == 1 then
			-- set savedVars to first choice to prevent conflicts if this was available previously
			entry.setFunc(1)
			tableShift(controlList, k)
		elseif entry.style and not _G[entry.style] then
			-- remove style options associated with addons not enabled.
			tableShift(controlList, k)
		end
	end
	--[[
	if not BUI then
		for i = 1, 2 do
			tableShift(controlList, #controlList)
		end
	end
	]]
	local menu = {
		type = "submenu",
		name = GetString(SI_IJA_MCF_FRAME_HEADER),
		reference = 'IJA_CompanionUnit_FrameOptions',
		controls = controlList,
	}

	return menu
end


function CompanionFrame_Manager:InitializeOptionHandlers(currentAddonPanel)
	-- used to make the companion frame show when setting are opened
	local companionFrame = self.selectedFrame
	local function show()
		if not companionFrame then return end
		IJA_CompanionUnit:SetHidden(false)
		self:UpdateFrame()
	end
	show()
	
	local function resetShield()
		if companionFrame then
			self:UpdateShieldOverlay(self.unitTag, POWERTYPE_HEALTH, 0, companionFrame.healthBar.max or 1)
		end
	end
	
	local lastColor = 0
	local function colorPreview()
		local colorPicker = SYSTEMS:GetObject("colorPicker")
		if colorPicker:IsShown() then
			local rgba = {colorPicker:GetColors()}
			local r, g, b, a = colorPicker:GetColors()
			
			newColor = table.concat(rgba)
			if lastColor ~= newColor then
				lastColor = newColor
				colorPicker.colorSelectedCallback(unpack(rgba))
			end
			
			if companionFrame then
				if isShield then
					local shieldValue = companionFrame.healthBar.max * 0.6
					self:UpdateShieldOverlay(self.unitTag, POWERTYPE_HEALTH, shieldValue, shieldValue, true)
				else
					resetShield()
				end
			end
		else
			if isShield then
				resetShield()
			end
		end
	end
	EVENT_MANAGER:RegisterForUpdate('IJA_CompanionUnit_FrameOptions_ColorPreview', 1, colorPreview)

	IJA_CompanionUnit_FrameOptions:SetHandler('OnEffectivelyHidden', function()
		EVENT_MANAGER:UnregisterForUpdate('IJA_CompanionUnit_FrameOptions_ColorPreview')
		resetShield()
		self:UpdateFrame()
	end)
	
	IJA_CompanionUnit_FrameOptions:SetHandler('OnEffectivelyShown', function()
		companionFrame = self.selectedFrame
		if companionFrame then
			show()
			EVENT_MANAGER:RegisterForUpdate('IJA_CompanionUnit_FrameOptions_ColorPreview', 1, colorPreview)
		end
	end)
	
	local originalOnStop = IJA_CompanionUnit_FrameOptions.animation:GetHandler("OnStop")
	local function onStop(control, completedPlaying)
		originalOnStop(control, completedPlaying)
		
		if companionFrame then
			show()
			if not control.open then
				resetShield()
			end
		end
	end
	IJA_CompanionUnit_FrameOptions.animation:SetHandler("OnStop", onStop)
end

--------------------------------------------------------
function IJA_CompanionFrames_Initialize(parent)
	return CompanionFrame_Manager:New(parent)
end

--[[
IJA_COMPANION_UI.companionFrames
IJA_CompanionUnitFrame
IJA_CompanionUnitFrameHp
IJA_CompanionUnitFrameHpShieldOverlay

/script IJA_COMPANION_UI.companionFrames:UpdateShieldOverlay(nil, nil, , 32000, true)
/script IJA_COMPANION_UI.companionFrames:UpdateShieldOverlay(nil, nil, 0, 1, true)

/script IJA_COMPANION_UI.companionFrames:UpdateHealthBar(nil, nil, 30000, 32000)
/script IJA_COMPANION_UI.companionFrames:UpdateHealthBar(nil, nil, 20000, 32000)
/script IJA_COMPANION_UI.companionFrames:UpdateHealthBar(nil, nil, 10000, 32000)


/script IJA_COMPANION_UI.companionFrames:UpdateHealthValue('companion', POWERTYPE_HEALTH, current, powerMax, powerEffMax, shield)
/script IJA_COMPANION_UI.companionFrames:UpdateHealthValue('companion', POWERTYPE_HEALTH)

/script IJA_COMPANION_UI.companionFrames:UpdateStatus(false, true)
/script IJA_COMPANION_UI.companionFrames:UpdateStatus(true, false)

/script ApplyTemplateToControl(IJA_CompanionUnitFrame, "IJA_CompanionUnitFrameZOS_Gamepad_Template")
/script ApplyTemplateToControl(IJA_CompanionUnitFrame, "IJA_CompanionUnitFrameBUI")


/script 
/script 

/script IJA_CompanionUnitFrameHpBDLeft:SetDimensions(200, 30)
/script IJA_CompanionUnitFrameHpBD:SetDimensions(200, 30)
/script IJA_CompanionUnitFrameHpBDLeft:SetColor(0 ,0 ,0 ,0.8)
/script IJA_CompanionUnitFrameHpBDLeft:SetColor(0 ,0 ,0 ,0.8)

/script IJA_CompanionUnitFrameHpBDLeft:SetTexture('EsoUI/Art/Miscellaneous/progressbar_genericFill.dds')
/script IJA_CompanionUnitFrameHpBDLeft:SetTexture('EsoUI/Art/Miscellaneous/progressbar_genericFill_tall.dds')
/script IJA_CompanionUnitFrameHpBDLeft:SetTexture('')
/script IJA_CompanionUnitFrameHpBDLeft:SetTexture('')
/script IJA_CompanionUnitFrameHpBDLeft:SetTexture('')


/script 
/script IJA_CompanionUnitFrameHpUnderlay:SetAlpha(0.5)
/script IJA_CompanionUnitFrameHp:GetNamedChild('BG'):SetEdgeColor(0 ,0 ,0 ,0)
/script IJA_CompanionUnitFrameHp:GetNamedChild('BGRight'):SetTexture('')
/script IJA_CompanionUnitFrameHp:GetNamedChild('BGMiddle'):SetTexture('')


/script IJA_CompanionUnitFrameHpBG:SetCenterTexture('')
/script IJA_CompanionUnitFrameHpBG:SetEdgeTexture('', 2, 16)
/script IJA_CompanionUnitFrameHpBG:SetCenterColor(0 ,0 ,0 ,0.8)
/script IJA_CompanionUnitFrameHpBG:SetColor(0 ,0 ,0 ,0.8)
/script IJA_CompanionUnitFrameHpBG:SetCenterTexture('EsoUI/Art/Miscellaneous/progressbar_genericFill_tall.dds')
]]




