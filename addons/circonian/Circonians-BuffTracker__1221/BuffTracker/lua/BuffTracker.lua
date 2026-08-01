
local libScroll = LibStub:GetLibrary("LibScroll")
local libFonts 	= LibStub:GetLibrary("LibFonts")
local libssp 	= LibStub:GetLibrary("LibSharedSkillsPanel")

local ADDON_NAME = "BuffTracker"
local DEBUG_MODE = false

local BAR_ANCHOR_OFFSETY = 30

local ANCHOR_RIGHT_SIDE_FLAG 	= 1
local ANCHOR_LEFT_SIDE_FLAG 	= 2

local TYPE_BUFF				= 1
local TYPE_DEBUFF			= 2
local TYPE_ALERT_BUFF		= 3
local TYPE_ALERT_PROC		= 4
local TYPE_HIDDEN_EFFECTS	= 5

local ALLOW_ALERT_SOUNDS = false

local BuffTracker = ZO_Object:New()
BuffTracker.codeVersion = 1.8

-- changeType: EFFECT_RESULT_
-- effectType: BUFF_EFFECT_TYPE
-- statusEffectType: STATUS_EFFECT_TYPE_
-- abilityType: ABILITY_TYPE_
--=====================================================--
--======= DEBUG =========--
--=====================================================--
local function debugMsg(msg, tableItem)
	if not DEBUG_MODE then return end
	if not BUFFTRACKER_DEBUG_TABLE then BUFFTRACKER_DEBUG_TABLE = {} end
	
	if msg and msg ~= "" then
		d(msg)
		table.insert(BUFFTRACKER_DEBUG_TABLE, msg)
	end
	
	-- Used to save object references for later examination:
	if tableItem then
		table.insert(BUFFTRACKER_DEBUG_TABLE, tableItem)
	end
end
--=====================================================--
--=====================================================--


--=====================================================--
--======= SV/UTILITY FUNCTIONS =========--
--=====================================================--
function BuffTracker:GetBar(buffType)
	return self.bars[buffType]
end
function BuffTracker:GetBarBackdrop(buffType)
	return self.bars[buffType].backdrop
end
function BuffTracker:GetRowTypeId(buffType)
	return self.rowTypeId[buffType]
end
function BuffTracker:GetCurrentBuffs(buffType)
	return self.currentBuffs[buffType]
end
function BuffTracker:GetCurrentBuffControl(buffType, effectName)
	return self.currentBuffs[buffType][effectName]
end
function BuffTracker:SetCurrentBuffControl(buffType, effectName, buffControl)
	self.currentBuffs[buffType][effectName] = buffControl
end
function BuffTracker:GetAlertTypeTable(buffType)
	return BuffTracker.sv.alerts[buffType]
end
function BuffTracker:IsAbilityAlertType(effectName, buffType)
	return BuffTracker.sv.alerts[buffType][effectName] and true or false
end
function BuffTracker:SetAbilityAlertData(buffType, effectName, abilityData)
	BuffTracker.sv.alerts[buffType][effectName] = abilityData
end
function BuffTracker:GetAllLayouts()
	return BuffTracker.sv.layout
end
function BuffTracker:GetLayoutData(buffType)
	return BuffTracker.sv.layout[buffType]
end
function BuffTracker:GetMenuBar()
	return self.menuBar
end
function BuffTracker:GetControlAbilityId(control)
	return control.dataEntry.data.abilityId
end
function BuffTracker:GetControlEffectName(control)
	return control.dataEntry.data.name
end

-- ** RowTypeId **--
local function SetTypeRowTypeId(setType, rowTypeId)
	BuffTracker.rowTypeId[setType] = rowTypeId
end


--=====================================================--
--======= OTHER UTILITY FUNCTIONS =========--
--=====================================================--
local function CreateAbilityDataTable(abilityId, effectName, iconFilename)
	effectName = zo_strformat(SI_ABILITY_NAME, effectName)
	
	local abilityData = {
		abilityId	= abilityId,
		name		= effectName,
		texture		= iconFilename,
	}
	return abilityData
end
function BuffTracker:HideTextTimers(shouldHide)
	local buffTypes = {
		TYPE_BUFF,
		TYPE_DEBUFF,
		TYPE_ALERT_BUFF,
		TYPE_ALERT_PROC,
	}
	for k, buffType in pairs(buffTypes) do
		local curBuffs = BuffTracker:GetCurrentBuffs(buffType)
		for k, buffControl in pairs(curBuffs) do
			if buffControl.cooldown.ends then
				buffControl.timeRemainingLabel:SetHidden(shouldHide)
			end
		end
	end
end

function BuffTracker:ResetTimerFonts(fontString)
	fontString = fontString or self.sv.timerSettings.fontString
	
	local buffTypes = {
		TYPE_BUFF,
		TYPE_DEBUFF,
		TYPE_ALERT_BUFF,
		TYPE_ALERT_PROC,
	}
	for k, buffType in pairs(buffTypes) do
		local curBuffs = BuffTracker:GetCurrentBuffs(buffType)
		for k, buffControl in pairs(curBuffs) do
			buffControl.timeRemainingLabel:SetFont(fontString)
		end
	end
end

function BuffTracker:ResetTimerColors(r,g,b)
	r,g,b = r,g,b or unpack(self.sv.timerSettings.fontColor)
	
	local buffTypes = {
		TYPE_BUFF,
		TYPE_DEBUFF,
		TYPE_ALERT_BUFF,
		TYPE_ALERT_PROC,
	}
	for k, buffType in pairs(buffTypes) do
		local curBuffs = BuffTracker:GetCurrentBuffs(buffType)
		for k, buffControl in pairs(curBuffs) do
			buffControl.timeRemainingLabel:SetColor(r,g,b,1)
		end
	end
end
-- SetupBuffIcon
function BuffTracker:SetCooldownRadialColor(r,g,b,a)
	local buffTypes = {
		TYPE_BUFF,
		TYPE_DEBUFF,
		TYPE_ALERT_BUFF,
		TYPE_ALERT_PROC,
	}
	
	for k, buffType in pairs(buffTypes) do
		local curBuffs = self:GetCurrentBuffs(buffType)
		for k, buffControl in pairs(curBuffs) do
			buffControl.cooldown:SetFillColor(r,g,b,a)
		end
	end
end

local function CustomPlaySound(sound)
	if not ALLOW_ALERT_SOUNDS then return end
	
	PlaySound(sound)
end

--=====================================================--
--======= SHARED SKILL PANEL STATE CHANGE FUNCTION =========--
--=====================================================--
local function OnSkillsSceneStateChange(oldState, newState)
	if newState == SCENE_HIDING then 
		ClearMenu()
	end
	if newState ~= SCENE_SHOWING then return end
	
	local buffAlertRowTypeId	= BuffTracker:GetRowTypeId(TYPE_ALERT_BUFF)
	local procAlertRowTypeId	= BuffTracker:GetRowTypeId(TYPE_ALERT_PROC)
	local hiddenEffectsRowTypeId = BuffTracker:GetRowTypeId(TYPE_HIDDEN_EFFECTS)
	local selectedCategory 		= BuffTracker.scrollList:GetSelectedCategory()
	
	if selectedCategory == buffAlertRowTypeId or selectedCategory == procAlertRowTypeId or selectedCategory == hiddenEffectsRowTypeId then
		BuffTracker:UpdateAlertList(selectedCategory)
	end
end
SCENE_MANAGER.scenes["skills"]:RegisterCallback("StateChange", OnSkillsSceneStateChange)

--=====================================================--
--======= CONTROL RESET FUNCTIONS =========--
--=====================================================--
local function CustomPoolResetBehavior(control)
	-- .horizontalAlignment is not reset on purpose, this way we only have to reset anchors
	-- if the anchor side needs to be changed the next time this control is used
	control:SetParent(nil)
	control.previousBuffControl = nil
	control.nextBuffControl 	= nil
	control.dataEntry			= nil
	control.poolKey				= nil
	control.buffType			= nil
	control.buffAlertSoundPlayed 	= false
	control.procAlertSoundPlayed 	= false
	
	control.cooldown:SetHidden(true)
	control.timeRemainingLabel:SetHidden(true)
	control.cooldownCompleteAnim:SetHidden(true)
	control.cooldown:SetHandler("OnUpdate", nil)
end


--=====================================================--
--======= COOLDOWN FUNCTIONS =========--
--=====================================================--
local function StartBuffCooldown(buffControl, remainingTimeInSecs)
	if not remainingTimeInSecs then return end
	local buffType = buffControl.buffType
	local cooldown = buffControl.cooldown
	local cooldownCompleteAnim	= buffControl.cooldownCompleteAnim
	
	--local oldEndTime = cooldown.ends
	local newEndTime = GetFrameTimeSeconds() + remainingTimeInSecs
	--[[ Removed in favor of resetting during OnEffectUpdated
	-- If there is an old end time, then this is a refresh of the buff so 
	-- reset the proc sound indicator
	if oldEndTime and oldEndTime < newEndTime then
		--buffControl.procAlertSoundPlayed = false
	end
	--]]
	cooldown.ends = newEndTime
	
	
	-- Grab info about alert sounds:
	local effectName 		= BuffTracker:GetControlEffectName(buffControl)
	local isBuffAlert 		= BuffTracker:IsAbilityAlertType(effectName, TYPE_ALERT_BUFF)
	local isProcAlert 		= BuffTracker:IsAbilityAlertType(effectName, TYPE_ALERT_PROC)
	local buffAlertSound 	= "None"
	local procAlertSound	= "None"
	local soundOffset 		= 0
	
	if isBuffAlert then
		buffAlertSound = BuffTracker.sv.alertSoundSettings.buffAlertSound
		soundOffset = BuffTracker.sv.alertSoundSettings.buffAlertSoundOffset
	end
	if isProcAlert then
		procAlertSound = BuffTracker.sv.alertSoundSettings.procAlertSound
	end
	

	-- Set update for control to update text timer & to play alert sounds:
	local function RefreshCooldown(cooldown, buffType)
		local secsLeft = zo_round(zo_max(0, cooldown.ends - GetFrameTimeSeconds()))
		cooldown.remainingTimeInSecs = secsLeft
		local formattedTime = FormatTimeSeconds(secsLeft, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_NONE)
		
		buffControl.timeRemainingLabel:SetText(formattedTime)
		
		if buffType == TYPE_BUFF and not buffControl.buffAlertSoundPlayed then
			if buffAlertSound ~= "None" and soundOffset > 0 and secsLeft < soundOffset then
				buffControl.buffAlertSoundPlayed = true
				CustomPlaySound(buffAlertSound)
			end
		end
		if buffType == TYPE_ALERT_PROC and not buffControl.procAlertSoundPlayed then
			if procAlertSound ~= "None" then
				buffControl.procAlertSoundPlayed = true
				CustomPlaySound(procAlertSound)
			end
		end
	end
	
	cooldown:SetHandler("OnUpdate", function() RefreshCooldown(cooldown, buffType) end)
	
	
	-- Show/Hide text timers
	local hideTextTimer = BuffTracker.sv.timerSettings.hideTextTimer
	buffControl.timeRemainingLabel:SetHidden(hideTextTimer)
	
	
	-- Handle cooldown animations:
	local remainingTimeInMs = remainingTimeInSecs * 1000
	--CD_TIME_TYPE_TIME_REMAINING, CD_TIME_TYPE_TIME_UNTIL
	--cooldown:StartCooldown(remainingTimeInMs, remainingTimeInMs, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)  
	cooldown:StartCooldown(remainingTimeInMs, remainingTimeInMs, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, NO_LEADING_EDGE)  
	if(cooldownCompleteAnim.animation) then
		cooldownCompleteAnim.animation:GetTimeline():PlayInstantlyToStart()
	end
	buffControl.cooldownCompleteAnim.animation = cooldownCompleteAnim.animation or CreateSimpleAnimation(ANIMATION_TEXTURE, cooldownCompleteAnim)
	local anim = cooldownCompleteAnim.animation

	anim:SetImageData(16,1)
	anim:SetFramerate(30)
	anim:GetTimeline():PlayFromStart()
	--anim:GetTimeline():PlayFromEnd()
	
	cooldownCompleteAnim:SetHidden(false)
	cooldown:SetHidden(false)
	
end

--=====================================================--
--======= EFFECT FUNCTIONS =========--
--=====================================================--
local function OnEffectGained(abilityData, effectType, remainingTime)
	if effectType == BUFF_EFFECT_TYPE_NOT_AN_EFFECT then return end
	
	local effectName	= abilityData.name
	local isABuffAlert 	= BuffTracker:IsAbilityAlertType(effectName, TYPE_ALERT_BUFF)
	local isAProcAlert 	= BuffTracker:IsAbilityAlertType(effectName, TYPE_ALERT_PROC)

	if isABuffAlert then
		BuffTracker:RemoveAbilityEffect(effectName, TYPE_ALERT_BUFF)
	end
	if isAProcAlert then
		BuffTracker:AddAbilityEffect(abilityData, TYPE_ALERT_PROC, remainingTime)
	end
	
	-- effectType always buff or debuff
	-- But don't add to buff/debuff bar if its a hidden effect
	if BuffTracker:IsAbilityAlertType(effectName, TYPE_HIDDEN_EFFECTS) then return end
	
	BuffTracker:AddAbilityEffect(abilityData, effectType, remainingTime)
end

local function OnEffectRemoved(abilityData, effectType)
	if effectType == BUFF_EFFECT_TYPE_NOT_AN_EFFECT then return end
	
	local effectName	= abilityData.name
	local isABuffAlert 	= BuffTracker:IsAbilityAlertType(effectName, TYPE_ALERT_BUFF)
	local isAProcAlert 	= BuffTracker:IsAbilityAlertType(effectName, TYPE_ALERT_PROC)

	if isABuffAlert then
		BuffTracker:AddAbilityEffect(abilityData, TYPE_ALERT_BUFF)
	end
	if isAProcAlert then
		BuffTracker:RemoveAbilityEffect(effectName, TYPE_ALERT_PROC)
	end
	
	-- effectType always buff or debuff
	-- if its a hidden effect it shouldn't exist...but let it fallthrough just in case
	-- something strange happens so a control doesn't get stuck on the screen
	-- RemoveAbilityEffect() can handle it if the control doesn't exist.
	--if BuffTracker:IsAbilityAlertType(effectName, TYPE_HIDDEN_EFFECTS) then return end
	
	BuffTracker:RemoveAbilityEffect(effectName, effectType)
end

local function OnEffectUpdated(abilityData, effectType, remainingTime)
	if not remainingTime then return end
	if effectType == BUFF_EFFECT_TYPE_NOT_AN_EFFECT then return end
	
	local effectName		= abilityData.name
	local buffControl		= BuffTracker:GetCurrentBuffControl(TYPE_BUFF, effectName)
	local debuffControl		= BuffTracker:GetCurrentBuffControl(TYPE_DEBUFF, effectName)
	local alertProcControl	= BuffTracker:GetCurrentBuffControl(TYPE_ALERT_PROC, effectName)
	-- buff alerts don't have cooldowns
	
	if buffControl then
		-- this is a refresh of the buff so reset the buff sound indicator
		buffControl.buffAlertSoundPlayed = false
		StartBuffCooldown(buffControl, remainingTime)
	end
	if debuffControl then
		StartBuffCooldown(debuffControl, remainingTime)
	end
	if alertProcControl then
		-- this is a refresh of the buff so reset the proc sound indicator
		alertProcControl.procAlertSoundPlayed = false
		
		StartBuffCooldown(alertProcControl, remainingTime)
	end
end

-- must use frameTime instead of beginTime to calculate time remaining
-- See notes where function is called for reasons.
-- This is only used to calculate remaining time for cooldowns.
local function CalculateRemainingTime(endTime)
	-- Must use frameTime, but its not 100% accurate so only show cooldown if remainingTime > 1 sec.
	local frameTime 	= GetFrameTimeMilliseconds()/1000
	local remainingTime = endTime - frameTime
	
	return remainingTime > 1 and remainingTime
end

-- Only used on load to check all current effects
-- the rest are done on effect changed event
local function CheckAllBuffs()
	local numBuffs 		= GetNumBuffs("player")
	local buffAlerts	= BuffTracker:GetAlertTypeTable(TYPE_ALERT_BUFF)
	
	for buffIndex = 1, numBuffs do
		local effectName, beginTime, endTime, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff  = GetUnitBuffInfo("player", buffIndex)
	
		local abilityData 	= CreateAbilityDataTable(abilityId, effectName, iconFilename)
		
		-- On reload UI the cooldowns get reset because controls are recreated, but the
		-- beginTime for effects does not get reset. It will still have the actual beginTime, 
		-- which was before the ui was reloaded so the calculations would be off. Must use frameTime:
		local remainingTime = CalculateRemainingTime(endTime)
		OnEffectGained(abilityData, effectType, remainingTime)
	end
	
	local curBuffs = BuffTracker:GetCurrentBuffs(TYPE_BUFF)
	
	for effectName, abilityData in pairs(buffAlerts) do
		if not curBuffs[effectName] then
			BuffTracker:AddAbilityEffect(abilityData, TYPE_ALERT_BUFF)
		end
	end
end

-- When an effect is unhidden we check here to see if the player currently has
-- that effect, if so we add it.
function BuffTracker:TryAddUnhiddenEffect(effectNameToAdd)
	local numBuffs = GetNumBuffs("player")
	
	for buffIndex = 1, numBuffs do
		local effectName, beginTime, endTime, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff  = GetUnitBuffInfo("player", buffIndex)
		
		if effectNameToAdd == effectName then
			local abilityData 	= CreateAbilityDataTable(abilityId, effectName, iconFilename)
			
			-- On reload UI the cooldowns get reset because controls are recreated, but the
			-- beginTime for effects does not get reset. It will still have the actual beginTime, 
			-- which was before the ui was reloaded so the calculations would be off. Must use frameTime:
			local remainingTime = CalculateRemainingTime(endTime)
			
			OnEffectGained(abilityData, effectType, remainingTime)
		end
	end
end


-- Fired from event effect_changed
local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
	if effectType == BUFF_EFFECT_TYPE_NOT_AN_EFFECT then return end
	-- I'm guessing EFFECT_RESULT_TRANSFER does not mean transfered TO the player, that would instead
	-- fire an EFFECT_RESULT_GAINED, but this probably means transfered to someone/something else
	-- which were not handling other character/mob buffs.
	if changeType == EFFECT_RESULT_TRANSFER then return end
	
	if abilityId == 14890 and BuffTracker.sv.hideBlockingBuff then return end
	
	
	local abilityData 	= CreateAbilityDataTable(abilityId, effectName, iconName)
	local remainingTime = CalculateRemainingTime(endTime)
	
	if changeType == EFFECT_RESULT_GAINED then
		-- here on a new effect beginTime is ok.
		-- Or maybe not..its not because the silly game fires EFFECT_RESULT_GAINED for buffs we already have when you swap weapons.
		-- which messes up this remaining time, so we must use frameTime here as well :(
		--local remainingTime = endTime > beginTime and (endTime - beginTime)
		local isInCurBuffs = BuffTracker:GetCurrentBuffControl(TYPE_BUFF, effectName)
		local isInCurDebuffs = BuffTracker:GetCurrentBuffControl(TYPE_DEBUFF, effectName)
	
		-- The games buff code is terrible I' sick of making exceptions & rewriting things just 
		-- to "get things to work" because the code is so terrible.
		if isInCurBuffs or isInCurDebuffs then return end
		
		OnEffectGained(abilityData, effectType, remainingTime)
		
	elseif changeType == EFFECT_RESULT_FADED then
		OnEffectRemoved(abilityData, effectType)
		
	else -- EFFECT_RESULT_UPDATED or EFFECT_RESULT_FULL_REFRESH
		-- when updated the endTime is updated, but not the beginning time so
		-- the time left is not endTime - beginTime, so we must use frameTime to calculate time remaining.
		--local remainingTime = endTime > beginTime and (endTime - beginTime)
		
		OnEffectUpdated(abilityData, effectType, remainingTime)
	end
end


--==============================================================--
--======= SHARED ON RIGHT CLICK CONTEXT MENU FUNCTIONS =========--
--====== SHARED BY ALL BAR ABILITY BUTTONS & ROW CONTROLS ======--
--==============================================================--
local function ShowRightClickMenuForAbility(abilityData)
	local effectName		= abilityData.name
	
	local isInCurBuffs		= BuffTracker:GetCurrentBuffControl(TYPE_BUFF, effectName)
	
	local isInBuffAlerts 	= BuffTracker:IsAbilityAlertType(effectName, TYPE_ALERT_BUFF)
	local isInProcAlerts 	= BuffTracker:IsAbilityAlertType(effectName, TYPE_ALERT_PROC)
	local isHiddenEffect 	= BuffTracker:IsAbilityAlertType(effectName, TYPE_HIDDEN_EFFECTS)
	
	local buffRowTypeId		= BuffTracker:GetRowTypeId(TYPE_ALERT_BUFF)
	local procRowTypeId		= BuffTracker:GetRowTypeId(TYPE_ALERT_PROC)
	local hiddenEffectsRowTypeId = BuffTracker:GetRowTypeId(TYPE_HIDDEN_EFFECTS)
	
	ClearMenu()
	
	if isInBuffAlerts then
		AddCustomMenuItem("Remove Buff Alert", function()
			BuffTracker:SetAbilityAlertData(TYPE_ALERT_BUFF, effectName, nil)
			BuffTracker:RemoveAbilityEffect(effectName, TYPE_ALERT_BUFF)
			BuffTracker:UpdateAlertList(buffRowTypeId)
		end)
	else
		AddCustomMenuItem("Add to Buff Alerts", function() 
			BuffTracker:SetAbilityAlertData(TYPE_ALERT_BUFF, effectName, abilityData)
			BuffTracker:UpdateAlertList(buffRowTypeId)
			
			if not isInCurBuffs then
				BuffTracker:AddAbilityEffect(abilityData, TYPE_ALERT_BUFF)
			end
		end)
	end
	
	if isInProcAlerts then
		AddCustomMenuItem("Remove Proc Alert", function()
			BuffTracker:SetAbilityAlertData(TYPE_ALERT_PROC, effectName, nil)
			BuffTracker:RemoveAbilityEffect(effectName, TYPE_ALERT_PROC)
			BuffTracker:UpdateAlertList(procRowTypeId)
		end)
	else
		AddCustomMenuItem("Add to Proc Alerts", function()
			BuffTracker:SetAbilityAlertData(TYPE_ALERT_PROC, effectName, abilityData)
			BuffTracker:UpdateAlertList(procRowTypeId)
			
			if isInCurBuffs then
				BuffTracker:AddAbilityEffect(abilityData, TYPE_ALERT_PROC)
			end
		end)
	end
	
	
	if isHiddenEffect then
		AddCustomMenuItem("Unhide Buff", function()
			BuffTracker:SetAbilityAlertData(TYPE_HIDDEN_EFFECTS, effectName, nil)
			BuffTracker:UpdateAlertList(hiddenEffectsRowTypeId)
			BuffTracker:TryAddUnhiddenEffect(effectName)
			
		end)
	else
		AddCustomMenuItem("Hide Buff", function()
			BuffTracker:SetAbilityAlertData(TYPE_HIDDEN_EFFECTS, effectName, abilityData)
			BuffTracker:UpdateAlertList(hiddenEffectsRowTypeId)
			
			if isInCurBuffs then
				BuffTracker:RemoveAbilityEffect(effectName, TYPE_BUFF)
			end
		end)
	end
	
	ShowMenu()
end

--=====================================================--
--======= MENU BUTTON ON CLICK CALLBACK FUNCTIONS =========--
--=====================================================--
local function MenuButton_Buffs_Callback(self, button, upInside)
	BuffTracker.alertWindow.label:SetText("Buff Alerts")
	local buffRowTypeId = BuffTracker:GetRowTypeId(TYPE_ALERT_BUFF)
	
	CALLBACK_MANAGER:FireCallbacks("OnSharedSkillsPanelMenuBtnClick", buffRowTypeId, "BuffTracker")
	BuffTracker:UpdateAlertList(buffRowTypeId)
end

local function MenuButton_Procs_Callback(self, button, upInside)
	BuffTracker.alertWindow.label:SetText("Proc Alerts")
	local procRowTypeId = BuffTracker:GetRowTypeId(TYPE_ALERT_PROC)
	
	CALLBACK_MANAGER:FireCallbacks("OnSharedSkillsPanelMenuBtnClick", procRowTypeId, "BuffTracker")
	BuffTracker:UpdateAlertList(procRowTypeId)
end

local function MenuButton_HiddenEffects_Callback(self, button, upInside)
	BuffTracker.alertWindow.label:SetText("Hidden Effects")
	local hiddenEffectsRowTypeId	= BuffTracker:GetRowTypeId(TYPE_HIDDEN_EFFECTS)
	
	CALLBACK_MANAGER:FireCallbacks("OnSharedSkillsPanelMenuBtnClick", hiddenEffectsRowTypeId, "BuffTracker")
	BuffTracker:UpdateAlertList(hiddenEffectsRowTypeId)
end
--=====================================================--
--======= SETUP BUFF CONTROL FUNCTIONS =========--
--=====================================================--
local function SetupBuffLabel(buffControl)
	local ICON_LABEL_OFFSETX = 10
	local buffType 		= buffControl.buffType
	local layoutData 	= BuffTracker:GetLayoutData(buffType)
	
	local label			= buffControl.label
	local icon			= buffControl.icon
	local bar 			= BuffTracker:GetBar(buffType)

	if not (layoutData.vertical and layoutData.showNames) then
		label:SetHidden(true)
		return
	end
	
	label:SetText(buffControl.dataEntry.data.name)
	label:SetFont(layoutData.fontString)
	label:SetColor(unpack(layoutData.fontColor))
	
	if layoutData.horizontalAlignment == LEFT then
		-- Only reset anchors if anchor side has changed
		if buffControl.horizontalAlignment ~= LEFT then
			buffControl.horizontalAlignment = LEFT
			
			label:ClearAnchors()
			label:SetAnchor(TOPLEFT, icon, TOPRIGHT, ICON_LABEL_OFFSETX, 0)
			label:SetAnchor(BOTTOMLEFT, icon, BOTTOMRIGHT, ICON_LABEL_OFFSETX, 0)
		end
	else
		-- Only reset anchors if anchor side has changed
		if buffControl.horizontalAlignment ~= RIGHT then
			buffControl.horizontalAlignment = RIGHT
			
			label:ClearAnchors()
			label:SetAnchor(TOPRIGHT, icon, TOPLEFT, -ICON_LABEL_OFFSETX, 0)
			label:SetAnchor(BOTTOMRIGHT, icon, BOTTOMLEFT, -ICON_LABEL_OFFSETX, 0)
		end
	end
	label:SetHidden(false)
end

local function SetupBuffIcon(buffControl)
	local layoutData 	= BuffTracker:GetLayoutData(buffControl.buffType)
	local iconSize 		= layoutData.iconSize
	-- no longer used, its anchored to resizewhen the template changes sizes
	--local textureSize 	= layoutData.textureSize
	local iconTemplateSize 	= iconSize - BuffTracker.sv.radialCooldown.lineWidth
	local icon 			= buffControl.icon
	local iconTemplate	= buffControl.iconTemplate
	
	buffControl:SetDimensions(iconSize, iconSize)
	
	if BuffTracker.sv.radialCooldown.overlayIcon then
		iconTemplateSize = iconSize
	end
	
	buffControl.iconTemplate:SetDimensions(iconTemplateSize, iconTemplateSize)
	-- no longer used, its anchored to resizewhen the template changes sizes
	--icon:SetDimensions(textureSize, textureSize)
	icon:SetTexture(buffControl.dataEntry.data.texture)
	
	local r,g,b,a = unpack(BuffTracker.sv.radialCooldown.color)
	buffControl.cooldown:SetFillColor(r,g,b,a)
	
	local cooldownOverlayIcon = BuffTracker.sv.radialCooldown.overlayIcon
	local drawTier = cooldownOverlayIcon and DT_HIGH or DT_LOW
	buffControl.cooldown:SetDrawTier(drawTier)
end

--=====================================================--
--======= ANCHOR FUNCTIONS =========--
--=====================================================--
-- Reanchors the bar header (background with text) when the alignment changes
local function Anchor_Bar(buffType)
	local bar			= BuffTracker:GetBar(buffType)
	local layoutData	= BuffTracker:GetLayoutData(buffType)
	local point 		= layoutData.verticalAlignment + layoutData.horizontalAlignment
		
	bar.buffType	= buffType
	
	bar:ClearAnchors()
	bar:SetAnchor(point, nil, TOPLEFT, layoutData.offsetX, layoutData.offsetY)
end

-- Reanchors the bar header (background with text) when the alignment changes
local function Anchor_BarHeader(buffType)
	local bar			= BuffTracker:GetBar(buffType)
	local barBackdrop	= BuffTracker:GetBarBackdrop(buffType)
	local layoutData 	= BuffTracker:GetLayoutData(buffType)
	local point 		= layoutData.verticalAlignment + layoutData.horizontalAlignment
	
	barBackdrop:ClearAnchors()
	barBackdrop:SetAnchor(point, bar, point,0,0)
end

--[[ AnchorBuffToBuff()
-- when I reference barXXXXXX I'm refering to the bars alignment/anchorPoint 
-- because layoutData.verticalAlignment & .horizontalAlignment are for the bar, so were modifying 
-- its aligments to determine the anchorPoint & relativeTo Point for the icons.

-- If anchoring buffControl to the bar:  iconPoint == barPoint & relativeTo = barPoint

-- FOR VERTICAL (when there is a previous buffControl)
-- iconPoint == barPoint  (anchorPoint)
-- realtiveTo  (point to anchor to on the other buff control)
-- iconhorizontalAlignment == barhorizontalAlignment
-- iconrelativeTo Horizontal = barhorizontalAlignment
-- iconrelativeTo vertical 	= opposite of barverticalAlignment

-- FOR HORIZONTAL (when there is a previous buffControl)
-- iconPoint == barPoint (anchorPoint)
-- realtiveTo  (point to anchor to on the other buff control)
-- iconhorizontalAlignment == barhorizontalAlignment
-- iconrelativeTo Horizontal = opposite of iconhorizontalAlignment
-- iconrelativeTo vertical 	= iconverticalAlignment
--]]
local function AnchorBuffToBuff(buffControl, prevBuffControl)
	local buffType 		= buffControl.buffType
	local layoutData 	= BuffTracker:GetLayoutData(buffType)
	local isVertical	= layoutData.vertical
	
	local verticalAlignment		= layoutData.verticalAlignment	
	local horizontalAlignment	= layoutData.horizontalAlignment
	local point					= verticalAlignment + horizontalAlignment 
	local headerPaddingY 		= BAR_ANCHOR_OFFSETY
	local relativeTo
	
	-- If anchored on the bottom reverse the offsetY padding for the first buffControl anchor
	if verticalAlignment == BOTTOM then
		headerPaddingY = -headerPaddingY
	end
	
	if isVertical then
		relativeTo = verticalAlignment == TOP and BOTTOM or TOP
		relativeTo = relativeTo + horizontalAlignment
		
	else
		relativeTo = horizontalAlignment == LEFT and RIGHT or LEFT
		relativeTo = relativeTo + verticalAlignment
	end
	
	buffControl:ClearAnchors()
	
	if prevBuffControl then
		buffControl:SetAnchor(point, prevBuffControl, relativeTo, 0, 0)
	else
		local bar = BuffTracker:GetBar(buffType)
		bar.firstBuff = buffControl
		buffControl:SetAnchor(point, bar, point, 0, headerPaddingY)
	end
end

-- Used when a buff is removed from the anchor chain. I.E. from any position in the list
-- resets prev/next buff references and reanchor around the buff (if necessary)
-- I.E. Anchor the buff after buffControl to the buff before buffControl
local function RemoveBuffFromAnchorChain(buffControl)
	local bar = BuffTracker:GetBar(buffControl.buffType)
	local previousBuffControl 	= buffControl.previousBuffControl
	local nextBuffControl 		= buffControl.nextBuffControl
	
	-- can be nil if buffControl is firstBuff
	if previousBuffControl then
		previousBuffControl.nextBuffControl = nextBuffControl
	else
		-- will nil out firstBuff if there are none left
		bar.firstBuff = nextBuffControl
	end
	
	-- can be nil if buffControl is lastBuff
	if nextBuffControl then
		nextBuffControl.previousBuffControl = previousBuffControl
		AnchorBuffToBuff(nextBuffControl, previousBuffControl)
	else
		-- will nil out lastBuff if there are none left
		bar.lastBuff	= previousBuffControl
	end
end

-- adds a buff (anchors it) to the end of the anchor chain
-- I.E. Anchors it to the bar or the last buff (end of the list)
local function AddBuffToAnchorChain(buffControl)
	local bar 			= BuffTracker:GetBar(buffControl.buffType)
	local lastBuff 		= bar.lastBuff
	
	if lastBuff then
		lastBuff.nextBuffControl 		= buffControl
		buffControl.previousBuffControl = lastBuff
	end
	
	buffControl:SetParent(bar)
	AnchorBuffToBuff(buffControl, lastBuff)
	
	bar.lastBuff = buffControl
end

-- Used when various settings are changed to reanchor the buffs, buff name labels
-- icons, and buff bar heading (background with bar/buffType name)
function BuffTracker:ReanchorBarOnNameAlignmentChange(buffType)
	local bar			= self:GetBar(buffType)
	local buffControl 	= bar.firstBuff
	
	-- Always reAnchor the bar & bar header, even if there are no buff controls
	Anchor_Bar(buffType)
	Anchor_BarHeader(buffType)
	
	if not buffControl then return end
	
	AnchorBuffToBuff(buffControl, nil) -- anchor to bar
	
	while buffControl do
		SetupBuffLabel(buffControl)
		SetupBuffIcon(buffControl)
		if buffControl.nextBuffControl then
			AnchorBuffToBuff(buffControl.nextBuffControl, buffControl)
		end
		buffControl = buffControl.nextBuffControl
	end
end

--=====================================================--
--======= ADD EFFECT FUNCTIONS =========--
--=====================================================--
function BuffTracker:AddAbilityEffect(abilityData, buffType, remainingTime)
	local layoutData 	= self:GetLayoutData(buffType)
	local isNewControl, buffControl = self:GetNewBuffControl(abilityData, buffType, remainingTime)
	-- The silly game fires EFFECT_RESULT_GAINED for buffs we already have when you swap weapons.
	-- So we need to ignore those gains. If we already have the buff on the bar nil will be returned.
	if not isNewControl then return end
	
	AddBuffToAnchorChain(buffControl)
	
	local playSound = "None"
	
	-- Must play alert sounds here AND when we update the cooldown in case they set something as an alert proc
	-- that does not have a cooldown timer. This will play on originally gaining the proc alert or gaining the buff alert.
	-- But it will only play the buff alert IF the play time offset is 0, else the "buff" alert sound gets played
	-- in the refresh cooldown because it needs to be played before the alert actually happens.
	if buffType == TYPE_ALERT_PROC then
		--[[ Set flag so it doesn't play a second time when the "original" cooldown starts. All future procs, as in if the effect procs again while its already up and the timer is refreshed, those sounds will be played by the refresh cooldown function.
		--]]
		buffControl.procAlertSoundPlayed = true
		playSound = self.sv.alertSoundSettings.procAlertSound
		
	elseif buffType == TYPE_ALERT_BUFF then
		-- Play if the offset is 0, otherwise the sound was played when the buff countdown timer reached the offset.
		-- Also play if the effects duration is 0, because that means it would never get played by the cooldown timer.
		local abilityDuration 	= GetAbilityDuration(abilityData.abilityId)
		local soundOffset 		= BuffTracker.sv.alertSoundSettings.buffAlertSoundOffset
		if abilityDuration == 0 or soundOffset == 0 then
			playSound = self.sv.alertSoundSettings.buffAlertSound
		end
	end
	
	if playSound ~= "None" then
		CustomPlaySound(playSound)
	end
	
	self:SetCurrentBuffControl(buffType, abilityData.name, buffControl)
end

--=====================================================--
--======= REMOVE BUFF FUNCTIONS =========--
--=====================================================--
function BuffTracker:RemoveAllBuffs()
	local buffTypes = {
		TYPE_BUFF,
		TYPE_DEBUFF,
		TYPE_ALERT_BUFF,
		TYPE_ALERT_PROC,
	}
	
	for k, buffType in pairs(buffTypes) do
		local curBuffs = self:GetCurrentBuffs(buffType)
		for effectName, buffControl in pairs(curBuffs) do
			self:RemoveAbilityEffect(effectName, buffType)
		end
	end
end

function BuffTracker:RemoveAbilityEffect(effectName, buffType)
	local buffControl	= self:GetCurrentBuffControl(buffType, effectName)
	if not buffControl then return end
	local layoutData 	= self:GetLayoutData(buffType)
	
	RemoveBuffFromAnchorChain(buffControl)
	
	self.buffPool:ReleaseObject(buffControl.poolKey)
	self:SetCurrentBuffControl(buffType, effectName, nil)
end



--=====================================================--
--======= SETUP BUFF CONTROL FUNCTION =========--
--=====================================================--
function BuffTracker:GetNewBuffControl(abilityData, buffType, remainingTime)
	-- The silly game fires EFFECT_RESULT_GAINED for buffs we already have when you swap weapons.
	-- So we need to ignore those gains. If we already have the buff on the bar just ignore it
	local effectName = abilityData.name
	local buffControl, key
	buffControl = self:GetCurrentBuffControl(buffType, effectName)
	
	if buffControl then
		-- if cooldown, update it
		if remainingTime then
			StartBuffCooldown(buffControl, remainingTime)
		end
		return false, buffControl
	end
	
	buffControl, key 		= self.buffPool:AcquireObject()
	buffControl.poolKey 	= key
	buffControl.buffType	= buffType
	
	-- mimic scrollList row control data storage so it can all
	-- be accessed with the same code.
	buffControl.dataEntry = {
		data = abilityData,
	}
	
	SetupBuffIcon(buffControl)
	SetupBuffLabel(buffControl)
	
	local r,g,b = unpack(self.sv.timerSettings.fontColor)
	buffControl.timeRemainingLabel:SetColor(r,g,b,1)
	
	local fontString = self.sv.timerSettings.fontString
	buffControl.timeRemainingLabel:SetFont(fontString)
	
	if remainingTime then
		StartBuffCooldown(buffControl, remainingTime)
	end
	
	return true, buffControl
end


--=====================================================--
--======= HANDLER FUNCTIONS  =========--
--=====================================================--
-- row clicked in shared skills panel
-- and click on any buff control
function HandleBuffAndRowControl_OnMouseUp(self, button, upInside)
	if not upInside then return end
	if button ~= MOUSE_BUTTON_INDEX_RIGHT then return end
	
	local abilityData = self.dataEntry.data
	-- Repack data to remove recursive entry dataEntry.data.dataEntry.data....
	local abilityData = CreateAbilityDataTable(abilityData.abilityId, abilityData.name, abilityData.texture)
	
	ShowRightClickMenuForAbility(abilityData)
end
--[[
--**************************************************************************************--
-- TODO: or not, I haven't decided if I want tooltips or not since we can't get
-- tooltips for other abilities 
--**************************************************************************************--
-- abilityId changed to use name !!!!!!!!!!!!!
--********************************************************--
local function TryCreateAbilityTooltip(abilityId, point, relativeTo, relativePoint)
	local description = GetAbilityDescription(abilityId)
	
	if not description or description == "" then return end
	
	local norm = ZO_NORMAL_TEXT
    local abilityName = GetAbilityName(abilityId)
	
    InitializeTooltip(BuffTracker_Tooltip, relativeTo, point, 0, 0, relativePoint)
	BuffTracker_Tooltip:AddLine(zo_strformat(SI_ABILITY_TOOLTIP_NAME, abilityName), "ZoFontWinH4", norm.r, norm.g, norm.b, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER)
	
	ZO_Tooltip_AddDivider(BuffTracker_Tooltip)
	
	BuffTracker_Tooltip:AddLine(zo_strformat(SI_ABILITY_TOOLTIP_DESCRIPTION, description), "ZoFontWinH4", norm.r, norm.g, norm.b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER)
end
--]]
	--[[
    if description ~= "" then
		AbilityTooltip:AddLine(zo_strformat(SI_ABILITY_TOOLTIP_DESCRIPTION, description), "ZoFontWinH4", norm.r, norm.g, norm.b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER)
	else
		AbilityTooltip:AddLine("Game description not available", "ZoFontWinH4", norm.r, norm.g, norm.b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER)
    end
	
	ZO_Tooltip_AddDivider(AbilityTooltip)
	--]]
--[[
local function ShowAbilityTooltip(abilityId, point, relativeTo, relativePoint, offsetX, offsetY)
	local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)

	-- can't get tooltips for skills you don't have..I'm not building them myself manually:
	if not hasProgression then 
		TryCreateAbilityTooltip(abilityId, point, relativeTo, relativePoint)
		return
	end
	local name, morph, rank = GetAbilityProgressionInfo(progressionIndex)
	
    InitializeTooltip(BuffTracker_Tooltip, relativeTo, point, offsetX, offsetY, relativePoint)
	BuffTracker_Tooltip:SetProgressionAbility(progressionIndex, morph, rank)
	--AbilityTooltip:SetProgressionAbility(22, morph, rank)
	----AbilityTooltip:SetSkillAbility(5,3,1)
end
--]]
function BuffTracker_BuffAlertRowControl_OnMouseEnter(self)
--[[
	local abilityId = self.dataEntry.data.abilityId
	
	ShowAbilityTooltip(abilityId, LEFT, self, RIGHT, 20, 0)
	--]]
end


function BuffTracker_BuffBar_Button_OnMouseEnter(self)
--[[
	local abilityId 			= self.dataEntry.data.abilityId
	local layoutData 			= BuffTracker:GetLayoutData(self.buffType)
	local alignLeft	= layoutData.horizontalAlignment == LEFT
	
	local point 			= alignLeft and LEFT or RIGHT
	local relativePoint 	= alignLeft and RIGHT or LEFT
	
	
	--CreateAbilityTooltip(abilityId, point, self, relativePoint)
	
	ShowAbilityTooltip(abilityId, point, self, relativePoint, 0, 0)
	--]]
end

function BuffTracker_BuffBar_Button_OnMouseExit(self)
	--ClearTooltip(BuffTracker_Tooltip)
end

function BuffTracker_BuffAlertRowControl_OnMouseExit(self)
	--ClearTooltip(SkillTooltip)
end

--=====================================================--
--======= OnMoveStop FUNCTIONS  =========--
--=====================================================--
--[[ old code
function BuffTracker:SetAnchorCorner(buffType)
	local layoutData 	= BuffTracker:GetLayoutData(bar.buffType)
	local isVertical	= layoutData.vertical
	local growDirection	= layoutData.growthDirection
	local alignLeft		= layoutData.horizontalAlignment == LEFT
	
	if isVertical then
	
	else
		if growDirection == "Right" then
			
		else
			
		end
	end
end
--]]
-- shared by all bars
local function SaveBarPosition(bar)
	local layoutData 	= BuffTracker:GetLayoutData(bar.buffType)
	
	if layoutData.verticalAlignment == TOP then
		layoutData.offsetY	= bar:GetTop()
	else
		layoutData.offsetY	= bar:GetBottom()
	end
	
	if layoutData.horizontalAlignment == LEFT then
		layoutData.offsetX	= bar:GetLeft()
	else
		layoutData.offsetX	= bar:GetRight()
	end
end

-- Done for an easy access reference in the Settings.lua file
-- So I don't have to create another global function
function BuffTracker:SaveBarPosition(bar)
	SaveBarPosition(bar)
end

-- When an object is moved it is changing the anchor to the nearest ? corner of the screen
-- and not just changing the offset. Growth direction depends on having a specific bar/window anchor
-- so we must re-anchor the bar everytime its moved.
-- Is this a ZOS bug ? I don't ever remeber it doing this?
local function OnBarMoveStop(bar)
	SaveBarPosition(bar)
	--Anchor_Bar(bar.buffType)
end

--=====================================================--
--======= SCROLLLIST FUNCTIONS  =========--
--=====================================================--
-- setup row control in shared skills panel (shared for buffs & procs)
local function BuffAlertRowSetup(rowControl, data, scrollList)
	rowControl.label:SetText(data.name)
	rowControl.icon:SetTexture(data.texture)
end

-- Update the shared skills panel scrollList with ability alerts
function BuffTracker:UpdateAlertList(rowTypeId)
	if not rowTypeId then return end
	-- categoryId == rowTypeId (still says categoryId from old code)
	-- I should change this in all addons to say GetRowTypeId
	local selectedCategory = self.scrollList:GetSelectedCategory()
	if rowTypeId ~= selectedCategory then return end

	local buffRowTypeId	= self:GetRowTypeId(TYPE_ALERT_BUFF)
	local procRowTypeId	= self:GetRowTypeId(TYPE_ALERT_PROC)
	local hiddenEffectsRowTypeId = BuffTracker:GetRowTypeId(TYPE_HIDDEN_EFFECTS)
	
	local buffTable
	if rowTypeId == buffRowTypeId then
		buffTable = self:GetAlertTypeTable(TYPE_ALERT_BUFF)
	elseif rowTypeId == procRowTypeId then
		buffTable = self:GetAlertTypeTable(TYPE_ALERT_PROC)
	elseif rowTypeId == hiddenEffectsRowTypeId then
		buffTable = self:GetAlertTypeTable(TYPE_HIDDEN_EFFECTS)
	end
	
	local scrollDataTable = {}
	
	for effectName, abilityData in pairs(buffTable) do
		table.insert(scrollDataTable, abilityData)
	end
	
	self.scrollList:UpdateScrollListCategory(scrollDataTable, rowTypeId)
end

--=========================================================--
--= INITIALIZE BARS =--
--=========================================================--
function BuffTracker:InitializeBars()
	local layoutData = self:GetAllLayouts()
	
	local function SetupBar(buffType)
		local bar			= BuffTracker:GetBar(buffType)
		local barLayoutData	= BuffTracker:GetLayoutData(buffType)
		
		Anchor_Bar(buffType)
		Anchor_BarHeader(buffType)
		
		local barFragment = self.barFragments[buffType]
		barFragment:SetHiddenForReason("UserDisabled", not barLayoutData.enabled)
						
		bar:SetMouseEnabled(barLayoutData.unlocked)
		--bar:SetHandler("OnMouseUp", SaveBarPosition)
		bar:SetHandler("OnMoveStop", OnBarMoveStop)
		
		-- Due to resizeToFitDescendents & the anchor OffsetY for icons
		-- hiding this throws the last icon half-way outside of the window making click-dragging
		-- a bit troubling. I'm cheating with an easy fix, instead of hiding, just set alpha to 0
		-- that doesn't effect the window size so everything works fine and the title backdrop is 
		-- so small, its not going to hurt anything.
		--bar.backdrop:SetHidden(barLayoutData.hideTitle)
		local alpha = barLayoutData.hideTitle and 0 or 1
		bar.backdrop:SetAlpha(alpha)
	end
	
	SetupBar(TYPE_BUFF)
	SetupBar(TYPE_DEBUFF)
	SetupBar(TYPE_ALERT_BUFF)
	SetupBar(TYPE_ALERT_PROC)
end

--==========================================================--
--= INITIALIZE / CREATE SHARED SKILLS PANEL & ITS BUTTONS  =--
--==========================================================--
local function CreateMenuBarButtons()
	local buffAlertRowTypeId	= BuffTracker:GetRowTypeId(TYPE_ALERT_BUFF)
	local procAlertRowTypeId	= BuffTracker:GetRowTypeId(TYPE_ALERT_PROC)
	local hiddenEffectsRowTypeId	= BuffTracker:GetRowTypeId(TYPE_HIDDEN_EFFECTS)
	local menuBar				= BuffTracker:GetMenuBar()
	
	-- Create the buttons in the shared skills panel
	local buffBtn =
	{
		descriptor 	= "BuffTracker_BuffAlert_Button",
		normal 		= "/esoui/art/miscellaneous/eso_icon_warning.dds",
		pressed 	= "/esoui/art/miscellaneous/eso_icon_warning.dds", 
		disabled 	= "/esoui/art/miscellaneous/eso_icon_warning.dds", 
		highlight 	= "/esoui/art/miscellaneous/eso_icon_warning.dds",
		rowTypeId	= buffAlertRowTypeId,
		callback 	= MenuButton_Buffs_Callback,
	}
	local procBtn =
	{
		descriptor 	= "BuffTracker_ProcAlert_Button",
		normal 		= "/esoui/art/miscellaneous/eso_icon_warning.dds",
		pressed 	= "/esoui/art/miscellaneous/eso_icon_warning.dds", 
		disabled 	= "/esoui/art/miscellaneous/eso_icon_warning.dds", 
		highlight 	= "/esoui/art/miscellaneous/eso_icon_warning.dds", 
		rowTypeId	= procAlertRowTypeId,
		callback 	= MenuButton_Procs_Callback,
	}
	local hiddenEffectsBtn =
	{
		descriptor 	= "BuffTracker_HiddenEffects_Button",
		normal 		= "/esoui/art/miscellaneous/eso_icon_warning.dds",
		pressed 	= "/esoui/art/miscellaneous/eso_icon_warning.dds", 
		disabled 	= "/esoui/art/miscellaneous/eso_icon_warning.dds", 
		highlight 	= "/esoui/art/miscellaneous/eso_icon_warning.dds", 
		rowTypeId	= hiddenEffectsRowTypeId,
		callback 	= MenuButton_HiddenEffects_Callback,
	}

	local buffAlertButton 	= ZO_MenuBar_AddButton(menuBar, buffBtn)
	local procAlertButton 	= ZO_MenuBar_AddButton(menuBar, procBtn)
	local hiddenEffectsButton 	= ZO_MenuBar_AddButton(menuBar, hiddenEffectsBtn)
	local buffImage 		= buffAlertButton:GetNamedChild("Image")
	local procImage 		= procAlertButton:GetNamedChild("Image")
	
	buffAlertButton.rowTypeId = buffAlertRowTypeId
	procAlertButton.rowTypeId = procAlertRowTypeId
	hiddenEffectsButton.rowTypeId = hiddenEffectsRowTypeId
	
	buffImage:SetColor(1, 0, 0, 1)
	procImage:SetColor(0, 1, 0, 1)
end

function BuffTracker:InitializeSharedSkillsPanel()
	self.alertWindow = libssp:CreateSharedSkillsPanel()
	local ROW_HEIGHT	= 45
	local alertWindow 	= self.alertWindow
	local scrollList 	= alertWindow.scrollList
	
	
	local buffRowTypeId = scrollList:AddDataType("BuffTrackerAlertRowControlTemplate", ROW_HEIGHT, BuffAlertRowSetup)
	local procRowTypeId = scrollList:AddDataType("BuffTrackerAlertRowControlTemplate", ROW_HEIGHT, BuffAlertRowSetup)
	local hiddenEffectsRowTypeId = scrollList:AddDataType("BuffTrackerAlertRowControlTemplate", ROW_HEIGHT, BuffAlertRowSetup)
	
	-- this is for rowTypeId for the scrollList, there is no buff/debuff, only alerts
	self.rowTypeId = {
		[TYPE_ALERT_BUFF] 		= buffRowTypeId,
		[TYPE_ALERT_PROC] 		= procRowTypeId,
		[TYPE_HIDDEN_EFFECTS] 	= hiddenEffectsRowTypeId,
	}
	
	self.alertWindow	= alertWindow
	self.menuBar		= alertWindow.menuBar
	self.scrollList 	= scrollList
	
	CreateMenuBarButtons()
	libssp:SelectInitialMenuBarButton()
end

function BuffTracker:Initialize()
	-- pool is shared for buffs, debuffs, buff alerts, & proc alerts
	self.buffPool 		= ZO_ControlPool:New("BuffTracker_Buff")
	self.buffPool:SetCustomResetBehavior(CustomPoolResetBehavior)
	
	self.bars = {
		[TYPE_BUFF] 			= BuffTracker_BuffBar,
		[TYPE_DEBUFF] 			= BuffTracker_DebuffBar,
		[TYPE_ALERT_BUFF]		= BuffTracker_BuffAlertBar,
		[TYPE_ALERT_PROC] 		= BuffTracker_ProcAlertBar,
	}
	
	-- current buff controls displayed:
	self.currentBuffs = {
		[TYPE_BUFF] 		= {},
		[TYPE_DEBUFF] 		= {},
		[TYPE_ALERT_BUFF]	= {},
		[TYPE_ALERT_PROC]	= {},
	}
	
	local BUFF_BAR_FRAGMENT			= ZO_HUDFadeSceneFragment:New(self.bars[TYPE_BUFF])
	local DEBUFF_BAR_FRAGMENT 		= ZO_HUDFadeSceneFragment:New(self.bars[TYPE_DEBUFF])
	local ALERT_BUFF_BAR_FRAGMENT 	= ZO_HUDFadeSceneFragment:New(self.bars[TYPE_ALERT_BUFF])
	local ALERT_PROC_BAR_FRAGMENT 	= ZO_HUDFadeSceneFragment:New(self.bars[TYPE_ALERT_PROC])
	
	self.barFragments = {
		[TYPE_BUFF] 		= BUFF_BAR_FRAGMENT,
		[TYPE_DEBUFF] 		= DEBUFF_BAR_FRAGMENT,
		[TYPE_ALERT_BUFF]	= ALERT_BUFF_BAR_FRAGMENT,
		[TYPE_ALERT_PROC]	= ALERT_PROC_BAR_FRAGMENT,
	}
	
    HUD_SCENE:AddFragment(BUFF_BAR_FRAGMENT)
    HUD_UI_SCENE:AddFragment(BUFF_BAR_FRAGMENT)
	
    HUD_SCENE:AddFragment(DEBUFF_BAR_FRAGMENT)
    HUD_UI_SCENE:AddFragment(DEBUFF_BAR_FRAGMENT)
	
    HUD_SCENE:AddFragment(ALERT_BUFF_BAR_FRAGMENT)
    HUD_UI_SCENE:AddFragment(ALERT_BUFF_BAR_FRAGMENT)
	
    HUD_SCENE:AddFragment(ALERT_PROC_BAR_FRAGMENT)
    HUD_UI_SCENE:AddFragment(ALERT_PROC_BAR_FRAGMENT)
	

	self:InitializeBars()
end

--=========================================================--
--= NEW =--
--=========================================================--
function BuffTracker:New()
	--************************************************************************************************--
	-- DEFAULT_TEXTURE_PADDING no longer used, its anchored to resize when the template changes sizes
	--************************************************************************************************--
	--local DEFAULT_TEXTURE_PADDING = 8
	local DEFAULT_FONT_SIZE		= 20
	local DEFAULT_ICON_SIZE		= 45
	local DEFAULT_TEXT_TIMER_SIZE = 20
	--local DEFULAT_TEXTURE_SIZE	= DEFAULT_ICON_SIZE - DEFAULT_TEXTURE_PADDING
	--local DEFAULT_FONT_NAME		= libFonts:GetFontByLibFontType(LIBFONTS_BOLD)
	local DEFAULT_FONT_NAME		= libFonts:GetFontNameByLibFontType(LIBFONTS_BOLD)
	local DEFAULT_FONT_STRING 	= zo_strformat("$(<<1>>)|<<2>>", DEFAULT_FONT_NAME, DEFAULT_FONT_SIZE)
	local norm = ZO_NORMAL_TEXT
	
	--self.DEFAULT_TEXTURE_PADDING 	= DEFAULT_TEXTURE_PADDING
	self.DEFAULT_FONT_NAME 			= DEFAULT_FONT_NAME
	self.DEFAULT_FONT_SIZE			= DEFAULT_FONT_SIZE
	-- must have a special/seperate table for lam default = ....for resetting defaults
	-- because it requires them to be packed with r=xx, g=xx, b=xx, a=xx
	self.DEFAULT_FONT_COLOR_RESET	= {r=norm.r, g=norm.g, b=norm.b, a=1}
	self.DEFAULT_FONT_COLOR 		= {norm.r, norm.g, norm.b, 1}
	local guiWidth					= GuiRoot:GetWidth()
	
	local function CreateDefaultLayout(offsetX, offsetY, horizontalAlignment)
		return {
			offsetX	= offsetX,
			offsetY = offsetY,
			
			direction = "Down",
			showNames	= true,
			
			verticalAlignment = TOP,
			horizontalAlignment = horizontalAlignment,
			
			unlocked	= true,
			hideTitle	= false,
			vertical	= true,
			
			iconSize	= DEFAULT_ICON_SIZE,
			--textureSize = DEFULAT_TEXTURE_SIZE,
			fontName	= DEFAULT_FONT_NAME,
			fontOutline	= "None",
			fontSize	= DEFAULT_FONT_SIZE,
			fontColor	= self.DEFAULT_FONT_COLOR,
			fontString	= DEFAULT_FONT_STRING,
			enabled		= true,
		}
	end
	
	local default = {
		hideBlockingBuff	= false,
		timerSettings = {
			hideTextTimer = false,
			fontName	= DEFAULT_FONT_NAME,
			fontOutline	= "None",
			fontSize	= DEFAULT_TEXT_TIMER_SIZE,
			fontColor	= self.DEFAULT_FONT_COLOR,
			fontString	= zo_strformat("$(<<1>>)|<<2>>", DEFAULT_FONT_NAME, DEFAULT_TEXT_TIMER_SIZE),
		},
		radialCooldown = {
			overlayIcon	= true,
			color = {0, 1, 0, 0.75},
			lineWidth	= 6,
		},
		alertSoundSettings = {
			buffAlertSound = "None",
			procAlertSound	= "None",
			buffAlertSoundOffset = 0,
		},
		hiddenEffects = {},
		alerts	= {
			[TYPE_ALERT_BUFF]		= {},
			[TYPE_ALERT_PROC]		= {},
			[TYPE_HIDDEN_EFFECTS]	= {},
		},
		layout = {
			[TYPE_BUFF]			= CreateDefaultLayout(0, 300, LEFT),
			[TYPE_DEBUFF]		= CreateDefaultLayout(0, 100, LEFT),
			[TYPE_ALERT_BUFF] 	= CreateDefaultLayout(guiWidth, 300, RIGHT),
			[TYPE_ALERT_PROC]	= CreateDefaultLayout(guiWidth, 500, RIGHT),
		},
	}
	
	self.sv = ZO_SavedVars:New("BuffTrackerSavedVars", 1.3, nil, default)
	
	self:Initialize()
	BuffTracker_CreateSettingsMenu(self)
	
	return self
end


-------------------------------------------------------------------
--  On Player Activation  --
-------------------------------------------------------------------
local function OnPlayerActivated()
	if not BuffTracker.alertWindow  then
		BuffTracker:InitializeSharedSkillsPanel()
	end
	
	ALLOW_ALERT_SOUNDS = false
	-- remove: Hacky fix, if a buff wears off during zoning the addon does not receive the effect removed
	BuffTracker:RemoveAllBuffs()
	CheckAllBuffs()
	ALLOW_ALERT_SOUNDS = true
end



-------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------
local function OnAddOnLoaded(event, addonName)
	if addonName ~= ADDON_NAME then return end

	if DEBUG_MODE then
		BUFFTRACKER = BuffTracker
	end
	
	BuffTracker:New()
	
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	
	--local targetBuffBar = BuffTracker:GetBar(TYPE_TARGET_BUFF)
	
	local buffBar = BuffTracker:GetBar(TYPE_BUFF)
	buffBar:RegisterForEvent(EVENT_EFFECT_CHANGED, 	OnEffectChanged)
    buffBar:AddFilterForEvent(EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
	

	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

---------------------------------------------------------------------
--  Register Events --
---------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)


