AUI.Buffs = {}

AUI_BUFF_TYPE_NORMAL = 1
AUI_BUFF_TYPE_DEBUFF = 2
AUI_BUFF_TYPE_HOT = 3
AUI_BUFF_TYPE_DOT = 4
AUI_BUFF_ALIGNMENT_LEFT = 100
AUI_BUFF_ALIGNMENT_RIGHT = 101

AUI_BUFF_TYPE_PLAYER = 1001
AUI_DEBUFF_TYPE_PLAYER = 1002
AUI_BUFF_TYPE_TARGET = 1003
AUI_DEBUFF_TYPE_TARGET = 1004

local BUFF_SCENE_FRAGMENT = nil
local g_isInit = false
local buffDataList = {}
local activeBuffs = {}
local mainBuffControls = nil
local currentTemplate = nil
local isPreviewShow = nil
local buffControlCount  = 0

local function OnMouseDown(_eventCode, _button, _ctrl, _alt, _shift, _control)
	if _button == 1 and not AUI.Settings.Buffs.lock_window then
		_control:SetMovable(true)
		_control:StartMoving()
	end
end

local function OnMouseUp(_eventCode, _button, _ctrl, _alt, _shift, _control, _positionData)
	_control:SetMovable(false)
		
	if _button == 1 and not AUI.Settings.Buffs.lock_window then
		_, _positionData.point, _, _positionData.relativePoint, _positionData.offsetX, _positionData.offsetY = _control:GetAnchor()
	end
end

local function SyncTargetDebuffPositionX()
	local targetBuffPosition = AUI.Settings.Buffs.target_buff_position
	local targetDebuffPosition = AUI.Settings.Buffs.target_debuff_position

	if not targetBuffPosition or not targetDebuffPosition then
		return
	end

	targetDebuffPosition.point = targetBuffPosition.point
	targetDebuffPosition.relativePoint = targetBuffPosition.relativePoint
	targetDebuffPosition.offsetX = targetBuffPosition.offsetX

	if g_isInit and AUI_Buff_Target_Debuffs then
		AUI_Buff_Target_Debuffs:ClearAnchors()
		AUI_Buff_Target_Debuffs:SetAnchor(targetDebuffPosition.point, GUIROOT, targetDebuffPosition.relativePoint, targetDebuffPosition.offsetX, targetDebuffPosition.offsetY)
	end
end

local function GetBuffControls(_unitTag, _effectType)	
	if not buffDataList[_unitTag] then
		buffDataList[_unitTag] = {}
	end
	
	if not buffDataList[_unitTag][_effectType] then
		buffDataList[_unitTag][_effectType] = {}
	end	

	return buffDataList[_unitTag][_effectType]
end

local function GetActiveBuffControls(_unitTag, _effectType)	
	if not activeBuffs[_unitTag] then
		activeBuffs[_unitTag] = {}
	end
	
	if not activeBuffs[_unitTag][_effectType] then
		activeBuffs[_unitTag][_effectType] = {}
	end	

	return activeBuffs[_unitTag][_effectType]
end

local function Sort(controlLeft, controlRight, _sortMode)
	if _sortMode == AUI_SORTING_SMALL_TO_LARGE then
		if controlLeft.buffData.EndTime < 0 and controlRight.buffData.EndTime < 0 then		
			if controlLeft.buffData.StartTime < controlRight.buffData.StartTime then
				return true
			end		
		elseif controlLeft.buffData.EndTime < 0 and controlRight.buffData.EndTime > 0 then
			return false
		elseif controlLeft.buffData.EndTime > 0 and controlRight.buffData.EndTime < 0 or controlLeft.buffData.EndTime < controlRight.buffData.EndTime then
			return true
		end
	elseif _sortMode == AUI_SORTING_LARGE_TO_SMALL then
		if controlLeft.buffData.EndTime < 0 and controlRight.buffData.EndTime < 0 then		
			if controlLeft.buffData.StartTime > controlRight.buffData.StartTime then
				return true
			end		
		elseif controlLeft.buffData.EndTime > 0 and controlRight.buffData.EndTime < 0 then
			return false
		elseif controlLeft.buffData.EndTime < 0 and controlRight.buffData.EndTime > 0 or controlLeft.buffData.EndTime > controlRight.buffData.EndTime then
			return true
		end
	end

	return false
end

local function GetParentWindow(_unitTag, _effectType)
	for _, control in pairs(mainBuffControls) do
		if control.unitTag == _unitTag and control.effectType == _effectType then
			return control
		end
	end		

	return nil
end

local function GetBuffData(_unitTag, _effectType)
	local alignment = nil
	local size = 32
	local color = "#ffffff"
	local distance = 12
	local fontArt = "ESO-FWNTLGUDC70 DB"
	local fontSize = 11
	local showBuffTime = true
	local textPosition = AUI_TEXT_ANCHOR_OUTSIDE
	
	if _unitTag == AUI_PLAYER_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_BUFF then
		size = AUI.Settings.Buffs.player_buff_size
		alignment = AUI.Settings.Buffs.player_buff_alignment
		distance = AUI.Settings.Buffs.player_buff_distance
		fontArt = AUI.Settings.Buffs.player_buff_font_art
		fontSize =  AUI.Settings.Buffs.player_buff_font_size
		showBuffTime = AUI.Settings.Buffs.player_show_buff_time 
		textPosition = AUI.Settings.Buffs.player_buff_text_position 
	elseif _unitTag == AUI_PLAYER_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_DEBUFF then	
		size = AUI.Settings.Buffs.player_debuff_size
		alignment = AUI.Settings.Buffs.player_debuff_alignment
		fontArt = AUI.Settings.Buffs.player_debuff_font_art
		fontSize =  AUI.Settings.Buffs.player_debuff_font_size
		showBuffTime = AUI.Settings.Buffs.player_show_debuff_time 		
		distance = AUI.Settings.Buffs.player_debuff_distance
		textPosition = AUI.Settings.Buffs.player_debuff_text_position 
	elseif _unitTag == AUI_TARGET_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_BUFF then
		size = AUI.Settings.Buffs.target_buff_size
		alignment = AUI.Settings.Buffs.target_buff_alignment
		distance = AUI.Settings.Buffs.target_buff_distance
		fontArt = AUI.Settings.Buffs.target_buff_font_art
		fontSize =  AUI.Settings.Buffs.target_buff_font_size
		showBuffTime = AUI.Settings.Buffs.target_show_buff_time 
		textPosition = AUI.Settings.Buffs.target_buff_text_position 		
	elseif _unitTag == AUI_TARGET_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_DEBUFF then
		size = AUI.Settings.Buffs.target_debuff_size
		alignment = AUI.Settings.Buffs.target_debuff_alignment
		distance = AUI.Settings.Buffs.target_debuff_distance
		fontArt = AUI.Settings.Buffs.target_debuff_font_art
		fontSize =  AUI.Settings.Buffs.target_debuff_font_size
		showBuffTime = AUI.Settings.Buffs.target_show_debuff_time	
		textPosition = AUI.Settings.Buffs.target_debuff_text_position 		
	end	
	
	if IsInGamepadPreferredMode() then
		if _unitTag == AUI_PLAYER_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_BUFF then
			size = AUI.Settings.Buffs.gamepad_player_buff_size
		elseif _unitTag == AUI_TARGET_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_BUFF then
			size = AUI.Settings.Buffs.gamepad_target_buff_size
		elseif _unitTag == AUI_TARGET_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_DEBUFF then
			size = AUI.Settings.Buffs.gamepad_target_debuff_size
		end
	end

	return size, alignment, distance, fontArt, fontSize, showBuffTime, textPosition
end

local function GetSortMode(_unitTag, _effectType)
	local sortMode = AUI_SORTING_LARGE_TO_SMALL

	if _unitTag == AUI_PLAYER_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_BUFF then
		sortMode = AUI.Settings.Buffs.player_buff_sorting
	elseif _unitTag == AUI_PLAYER_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_DEBUFF then	
		sorting = AUI.Settings.Buffs.player_debuff_sorting	
	elseif sortMode == AUI_TARGET_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_BUFF then
		sortMode = AUI.Settings.Buffs.target_buff_sorting
	elseif _unitTag == AUI_TARGET_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_DEBUFF then
		sortMode = AUI.Settings.Buffs.target_debuff_sorting
	end
	
	return sortMode
end

local function UpdateBuffsLayout(_unitTag, _effectType)
	local sortMode = GetSortMode(_unitTag, _effectType)
	local activeBuffs = GetActiveBuffControls(_unitTag, _effectType)
	local sortedBuffList = AUI.Table.GetKeysSortedByValue(activeBuffs, Sort, sortMode)
	local lastControl = nil

	for _, key in pairs(sortedBuffList) do
		local control = activeBuffs[key]	
		local iconTextureControl = GetControl(control, "_Icon")
		local point = TOPLEFT
		local rPoint = TOPRIGHT
		local distanceLeft = 0
		local distanceTop = 0	
		
		if control.buffData.alignment == AUI_VERTICAL then
			point = TOPLEFT
			rPoint = BOTTOMLEFT
			distanceTop = control.buffData.distance	
		elseif control.buffData.alignment == AUI_VERTICAL_REVERSE then
			point = BOTTOMLEFT
			rPoint = TOPLEFT
			distanceTop = -control.buffData.distance		
		elseif control.buffData.alignment == AUI_HORIZONTAL then
			point = TOPLEFT
			rPoint = TOPRIGHT
			distanceLeft = control.buffData.distance	
		elseif control.buffData.alignment == AUI_HORIZONTAL_REVERSE then
			point = TOPRIGHT
			rPoint = TOPLEFT
			distanceLeft = -control.buffData.distance				
		end
		
		control:ClearAnchors()
		
		if lastControl then
			control:SetAnchor(point, lastControl, rPoint, distanceLeft, distanceTop)			
		else
			control:SetAnchor(TOPLEFT)	
		end			

		iconTextureControl:SetTexture(control.buffData.IconTexture)	
		
		lastControl = control
	end		
end

local function SetBuffLayout(_control)
	local iconTextureControl = GetControl(_control, "_Icon")
	iconTextureControl:SetDimensions(_control.buffData.size, _control.buffData.size)			

	local textControl = GetControl(_control, "_Text")
	textControl:SetFont(_control.buffData.fontArt .. "|" .. (_control.buffData.size + _control.buffData.fontSize) / 3.8 .. "|" .. "thick-outline")
	
	textControl:ClearAnchors()
	
	if _control.buffData.textPosition == AUI_TEXT_ANCHOR_INSIDE then
		textControl:SetAnchor(BOTTOM, iconTextureControl, BOTTOM, 0, 2)		
	else
		textControl:SetAnchor(TOP, iconTextureControl, BOTTOM, 0, 2)
	end

	if _control.buffData.showBuffTime then
		textControl:SetHidden(false)
	else
		textControl:SetHidden(true)
	end				

	_control:SetDimensions(_control.buffData.size, _control.buffData.size)		
end

local function CreateNewBuffControl(_virtualControl, _unitTag, _effectType)
	local controls = GetBuffControls(_unitTag, _effectType)	
	local control = controls[buffControlCount]

	if not control then
		local parent = GetParentWindow(_unitTag, _effectType)			
		if parent then
			control = CreateControlFromVirtual("AUI_Buff" .. _unitTag .. "_" .. _effectType .. "_" , parent, _virtualControl, buffControlCount)
			local size, alignment, distance, fontArt, fontSize, showBuffTime, textPosition = GetBuffData(_unitTag, _effectType)
			
			control.buffData = {}
			control.buffData.IconTexture = ""
			control.buffData.StartTime =0
			control.buffData.EndTime = 0
			control.buffData.StartDuration = 0							
			control.buffData.unitTag = _unitTag
			control.buffData.effectType = _effectType
			control.buffData.size = size
			control.buffData.alignment = alignment
			control.buffData.distance = distance
			control.buffData.fontArt = fontArt
			control.buffData.fontSize = fontSize
			control.buffData.showBuffTime = showBuffTime
			control.buffData.textPosition = textPosition

			controls[buffControlCount] = control
			
			buffControlCount = buffControlCount + 1

			SetBuffLayout(control)
		end
	end	

	return control
end

local function GetBuffControl(_abilityId, _unitTag, _effectType)
	if not currentTemplate and currentTemplate.templateData then
		return nil
	end

	local controls = GetBuffControls(_unitTag, _effectType)	

	for id, control in pairs(controls) do			
		if control.buffData.AbilityId == _abilityId then	
			return control
		end
	end

	if _unitTag == AUI_PLAYER_UNIT_TAG then
		if _effectType == BUFF_EFFECT_TYPE_BUFF then
			return CreateNewBuffControl(currentTemplate.templateData[AUI_BUFF_TYPE_PLAYER].name, _unitTag, _effectType)
		elseif _effectType == BUFF_EFFECT_TYPE_DEBUFF then
			return CreateNewBuffControl(currentTemplate.templateData[AUI_DEBUFF_TYPE_PLAYER].name, _unitTag, _effectType)
		end		
	elseif _unitTag == AUI_TARGET_UNIT_TAG then
		if _effectType == BUFF_EFFECT_TYPE_BUFF then
			return CreateNewBuffControl(currentTemplate.templateData[AUI_BUFF_TYPE_TARGET].name, _unitTag, _effectType)
		elseif _effectType == BUFF_EFFECT_TYPE_DEBUFF then
			return CreateNewBuffControl(currentTemplate.templateData[AUI_DEBUFF_TYPE_TARGET].name, _unitTag, _effectType)
		end		
	end
	
	return nil
end

local function SetPreviewLayout(_unitTag, _effectType)
	local alignment = AUI_HORIZONTAL
	
	local main = nil
	if _unitTag == AUI_PLAYER_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_BUFF then
		alignment = AUI.Settings.Buffs.player_buff_alignment
		main = AUI_Buff_Player_Buffs
	elseif _unitTag == AUI_PLAYER_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_DEBUFF then	
		alignment = AUI.Settings.Buffs.player_debuff_alignment
		main = AUI_Buff_Player_Debuffs
	elseif _unitTag == AUI_TARGET_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_BUFF then
		alignment = AUI.Settings.Buffs.target_buff_alignment
		main = AUI_Buff_Target_Buffs
	elseif _unitTag == AUI_TARGET_UNIT_TAG and _effectType == BUFF_EFFECT_TYPE_DEBUFF then
		alignment = AUI.Settings.Buffs.target_debuff_alignment
		main = AUI_Buff_Target_Debuffs
	end	

	local info = GetControl(main, "_Info")
	local arrow = GetControl(main, "_DirectionArrow")

	arrow:ClearAnchors()
	info:ClearAnchors()
	
	if alignment == AUI_VERTICAL then
		arrow:SetTextureRotation(math.rad(180))		
		arrow:SetAnchor(BOTTOM, main, TOP, 0, -10)	
		info:SetAnchor(BOTTOM, arrow, TOP, 0, -4)			
	elseif alignment == AUI_VERTICAL_REVERSE then
		arrow:SetTextureRotation(math.rad(0))		
		arrow:SetAnchor(TOP, main, BOTTOM, 0, 24)		
		info:SetAnchor(TOP, arrow, BOTTOM, 0, 4)			
	elseif alignment == AUI_HORIZONTAL then
		arrow:SetTextureRotation(math.rad(270))		
		arrow:SetAnchor(RIGHT, main, LEFT, -10)	
		info:SetAnchor(RIGHT, arrow, LEFT, -4, -2)	
	elseif alignment == AUI_HORIZONTAL_REVERSE then		
		arrow:SetTextureRotation(math.rad(90))		
		arrow:SetAnchor(LEFT, main, RIGHT, 10)	
		info:SetAnchor(LEFT, arrow, RIGHT, 4, -2)			
	end
end

local function GetBuff(_abilityId, _unitTag, _effectType)
	local controls = GetActiveBuffControls(_unitTag, _effectType)	

	for id, control in pairs(controls) do			
		if control.buffData.AbilityId == _abilityId then	
			return control
		end
	end
	
	return nil
end

local function RemoveBuff(_abilityId, _unitTag, _effectType, _fadeMode)
	EVENT_MANAGER:UnregisterForUpdate("AUI_Update_BuffControl" .. tostring(_unitTag) .. _abilityId)

	local activeBuffs = GetActiveBuffControls(_unitTag, _effectType)
	if activeBuffs and activeBuffs[_abilityId] then	
		if _fadeMode then
			AUI.Fade.Out(activeBuffs[_abilityId], 500)
		else
			AUI.Fade.Out(activeBuffs[_abilityId])
		end

		activeBuffs[_abilityId] = nil
				
		UpdateBuffsLayout(_unitTag, _effectType)
	end
end

local function UpdateBuffTime(_abilityId, _unitTag, _effectType, _control)
	local timeLeft = _control.buffData.EndTime - GetFrameTimeSeconds()
	local duration = _control.buffData.EndTime - _control.buffData.StartTime

	local textControl = GetControl(_control, "_Text")
	if textControl then
		local formatedTimeString = ""
		if _control.buffData.StartDuration > 0 then
			if timeLeft >= 1 then
				formatedTimeString = AUI.Time.GetFormatedString(timeLeft, AUI_TIME_FORMAT_SHORT)
			else
				formatedTimeString = AUI.Time.GetFormatedString(timeLeft, AUI_TIME_FORMAT_SHORT)
			end
		else
			EVENT_MANAGER:UnregisterForUpdate("AUI_Update_BuffControl" .. tostring(_unitTag) .. _abilityId)
		end	
		textControl:SetText(formatedTimeString)		
	end
		
	local cooldownControl = GetControl(_control, "_Cooldown")
	if cooldownControl then
		cooldownControl:StartCooldown(timeLeft * 1000, duration * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
	end		
	
	if timeLeft <= 0 then
		EVENT_MANAGER:UnregisterForUpdate("AUI_Update_BuffControl" .. tostring(_unitTag) .. _abilityId)
	end
end

local function UpdateBuff(_abilityId, _unitTag, _effectType, _iconTexture, _startTime, _endTime)
	local activeBuffs = GetActiveBuffControls(_unitTag, _effectType)	
	if activeBuffs and activeBuffs[_abilityId] then
		EVENT_MANAGER:UnregisterForUpdate("AUI_Update_BuffControl" .. tostring(_unitTag) .. _abilityId)	

		local control = activeBuffs[_abilityId]
		local startDuration = _endTime - _startTime
		
		if startDuration <= 0 then
			_endTime = -1
			startDuration = -1
		end
		
		control.buffData.IconTexture = _iconTexture
		control.buffData.StartTime = _startTime or 0
		control.buffData.EndTime = _endTime or 0
		control.buffData.AbilityId = _abilityId
		control.buffData.StartDuration = startDuration
			
		UpdateBuffsLayout(_unitTag, _effectType)
		
		EVENT_MANAGER:RegisterForUpdate("AUI_Update_BuffControl" .. tostring(_unitTag) .. _abilityId, 0, function() UpdateBuffTime(_abilityId, _unitTag, _effectType, control) end)
	end
end

local function AddBuff(_abilityId, _unitTag, _effectType, _iconTexture, _startTime, _endTime, _fadeMode)	
	local activeBuffs = GetActiveBuffControls(_unitTag, _effectType)	
	if activeBuffs and not activeBuffs[_abilityId] then
		local control = GetBuffControl(_abilityId, _unitTag, _effectType)
		
		EVENT_MANAGER:UnregisterForUpdate("AUI_Update_BuffControl" .. tostring(_unitTag) .. _abilityId)	

		local startDuration = _endTime - _startTime
			
		if startDuration <= 0 then
			_endTime = -1
			startDuration = -1
		end
			
		if not _iconTexture then
			_iconTexture = "/esoui/art/icons/icon_missing.dds"
		end	

		control.buffData.IconTexture = _iconTexture
		control.buffData.StartTime = _startTime or 0
		control.buffData.EndTime = _endTime or 0
		control.buffData.AbilityId = _abilityId
		control.buffData.StartDuration = startDuration

		if _fadeMode then
			AUI.Fade.In(control, 500)
		else
			AUI.Fade.In(control)
		end	

		local activeBuffs = GetActiveBuffControls(_unitTag, _effectType)	
		activeBuffs[_abilityId] = control	
		
		UpdateBuffsLayout(_unitTag, _effectType)
		
		EVENT_MANAGER:RegisterForUpdate("AUI_Update_BuffControl" .. tostring(_unitTag) .. _abilityId, 0, function() UpdateBuffTime(_abilityId, _unitTag, _effectType, control) end)	
	end
end

local function RemoveBuffs(_unitTag, _fadeMode)
	if activeBuffs and activeBuffs[_unitTag] then
		for effectType, buffControls in pairs(activeBuffs[_unitTag]) do
			for _, control in pairs(buffControls) do
				RemoveBuff(control.buffData.AbilityId, _unitTag, effectType, _fadeMode)
			end
		end
	end
end

local function RemoveAllBuffs()
	if activeBuffs then
		for unitTag, unitData in pairs(activeBuffs) do
			for effectType, buffControls in pairs(unitData) do	
				for _, control in pairs(buffControls) do
					RemoveBuff(control.buffData.AbilityId	, unitTag, effectType, false)
				end
			end
		end
	end
end

local function IsBuffAllowed(_unitTag, _startTime, _endTime, _effectType, _abilityType, _castByPlayer)
	if _unitTag ~= AUI_PLAYER_UNIT_TAG and _unitTag ~= AUI_TARGET_UNIT_TAG then
		return false
	end
	
	if _effectType == BUFF_EFFECT_TYPE_BUFF then
		local duration = _endTime - _startTime
	
		if _unitTag == AUI_PLAYER_UNIT_TAG then
			if not _castByPlayer and AUI.Settings.Buffs.player_allow_only_own_buffs then
				return false
			end		
		
			if AUI.Settings.Buffs.player_show_permanent_buffs and duration <= 0 then														
				return true
			elseif AUI.Settings.Buffs.player_show_time_limit_buffs and duration > 0 then
				return true
			end
		elseif _unitTag == AUI_TARGET_UNIT_TAG then
			if AUI.Settings.Buffs.target_show_permanent_buffs and duration <= 0 then														
				return true
			elseif AUI.Settings.Buffs.target_show_time_limit_buffs and duration > 0 then
				return true
			end	
		end
	elseif _effectType == BUFF_EFFECT_TYPE_DEBUFF then
		if _unitTag == AUI_PLAYER_UNIT_TAG then
			if AUI.Settings.Buffs.player_show_debuffs then
				return true
			end
		elseif _unitTag == AUI_TARGET_UNIT_TAG then
			if not _castByPlayer and AUI.Settings.Buffs.player_allow_only_own_debuffs then
				return false
			end			
		
			if AUI.Settings.Buffs.target_show_debuffs then
				return true
			end		
		end
	end
	
	return false
end

local function RefreshBuffs(_unitTag)
	RemoveBuffs(_unitTag)

	local numBuffs = GetNumBuffs(_unitTag)
	for buffIndex = 1, numBuffs do
		local buffName, startTime, endTime, buffSlot, stackCount, iconFile, unitTag, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(_unitTag, buffIndex) 

		local effectFilter = AUI.GetGlobalEffectFilter()
		if not effectFilter[abilityId] then
			if IsBuffAllowed(_unitTag, startTime, endTime, effectType, abilityType, castByPlayer) then
				AddBuff(abilityId, _unitTag, effectType, iconFile, startTime, endTime, false)				
			end	
		end		
	end	
end

function AUI.Buffs.OnEffectChanged(_changeType, _effectSlot, _effectName, _unitTag, _beginTime, _endTime, _stackCount, _iconName, _buffType, _effectType, _abilityType, _statusEffectType, _unitName, _unitId, _abilityId, _combatUnitType)
	if not g_isInit or isPreviewShow then
		return
	end

	local castByPlayer = false
	if _combatUnitType == COMBAT_UNIT_TYPE_PLAYER or _combatUnitType == COMBAT_UNIT_TYPE_PLAYER_PET then
		castByPlayer = true
	end

	if _changeType == EFFECT_RESULT_GAINED then
		local isBuffAlowed = IsBuffAllowed(_unitTag, _beginTime, _endTime, _effectType, _abilityType, castByPlayer)
		if isBuffAlowed then
			AddBuff(_abilityId, _unitTag, _effectType, _iconName, _beginTime, _endTime, false)
		end
	elseif _changeType == EFFECT_RESULT_FADED then
		 RemoveBuff(_abilityId, _unitTag, _effectType, false)			 
	elseif _changeType == EFFECT_RESULT_UPDATED then	
		local isBuffAlowed = IsBuffAllowed(_unitTag, _beginTime, _endTime, _effectType, _abilityType, castByPlayer)
		if isBuffAlowed then
			UpdateBuff(_abilityId, _unitTag, _effectType, _iconName, _beginTime, _endTime)
		end
	end	
end

local function AddPreviewBuff(abilityId, _unitTag, _effectType, _textureFile, _time)
	local seconds = _time / 1000

	AddBuff(abilityId, _unitTag, _effectType, _textureFile, GetFrameTimeSeconds(), GetFrameTimeSeconds() + seconds, false)
	
	if _time > 0 then
		EVENT_MANAGER:UnregisterForUpdate("AUI_Buffs_Preview" .. abilityId)
		EVENT_MANAGER:RegisterForUpdate("AUI_Buffs_Preview" .. abilityId, _time,
		function() 
			UpdateBuff(abilityId, _unitTag, _effectType, _textureFile, GetFrameTimeSeconds(), GetFrameTimeSeconds() + seconds)
		end)
	end
end

local function UpdatePreview()
	if not g_isInit  or not isPreviewShow then
		return
	end

	if AUI.Settings.Buffs.player_show_permanent_buffs then
		AddPreviewBuff("PreviewPlayerPermPassiveBuff1", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_werewolf_010.dds", -1) -- Lykanthropie	
		AddPreviewBuff("PreviewPlayerPermPassiveBuff2", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_vampire_007.dds", -1) -- Vampire			
	end	
	
	AddPreviewBuff("PreviewPlayerAbilityBuff1", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_mageguild_003.dds", 4000) -- Äquilibrium	
	AddPreviewBuff("PreviewPlayerAbilityBuff2", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_fightersguild_002.dds", 15000) -- Meisterjäger
	AddPreviewBuff("PreviewPlayerAbilityBuff3", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_undaunted_005.dds", 5000) -- Knochenschild
	AddPreviewBuff("PreviewPlayerAbilityBuff4", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_undaunted_001.dds", -1) -- Blutiger Altar
	AddPreviewBuff("PreviewPlayerAbilityBuff5", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_mageguild_002.dds", -1) -- Magierlicht	
	
	if AUI.Settings.Buffs.player_show_time_limit_buffs then
		AddPreviewBuff("PreviewPlayerPermTLPassiveBuff1", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/store_tricolor_food_01.dds", 7200000) -- Bufffood (All Attributes)	
	end
	
	if AUI.Settings.Buffs.show_player_passive_permanent_debuffs then
		AddPreviewBuff("PreviewPlayerPermPassiveBuff1", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_werewolf_010.dds", -1) -- Lykanthropie	
		AddPreviewBuff("PreviewPlayerPermPassiveBuff2", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_vampire_007.dds", -1) -- Vampire		
	end
	
	if AUI.Settings.Buffs.player_show_debuffs then
		AddPreviewBuff("PreviewPlayerDebuff1", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF, "/esoui/art/icons/ability_destructionstaff_010.dds", 10000) -- Impuls
		AddPreviewBuff("PreviewPlayerDebuff2", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF, "/esoui/art/icons/ability_destructionstaff_001b.dds", 1300) -- Kraftschlag
		AddPreviewBuff("PreviewPlayerDebuff3", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF, "/esoui/art/icons/ability_destructionstaff_011.dds", 21000) -- größere Verteilung
		AddPreviewBuff("PreviewPlayerDebuff4", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF, "/esoui/art/icons/ability_otherclass_001.dds", -1) -- Seelenfalle
		AddPreviewBuff("PreviewPlayerDebuff5", AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF, "/esoui/art/icons/ability_undaunted_002.dds", 15000) -- Inneres Feuer
	end	
	
	if AUI.Settings.Buffs.target_show_permanent_buffs then
		AddPreviewBuff("PreviewTargetPermPassiveBuff1", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_werewolf_010.dds", -1) -- Lykanthropie	
		AddPreviewBuff("PreviewTargetPermPassiveBuff2", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_vampire_007.dds", -1) -- Vampire			
	end	
	
	AddPreviewBuff("PreviewTargetAbilityBuff1", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_mageguild_003.dds", 4000) -- Äquilibrium	
	AddPreviewBuff("PreviewTargetAbilityBuff2", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_fightersguild_002.dds", 15000) -- Meisterjäger
	AddPreviewBuff("PreviewTargetAbilityBuff3", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_undaunted_005.dds", 5000) -- Knochenschild
	AddPreviewBuff("PreviewTargetAbilityBuff4", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_undaunted_001.dds", -1) -- Blutiger Altar
	AddPreviewBuff("PreviewTargetAbilityBuff5", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/ability_mageguild_002.dds", -1) -- Magierlicht	
	
	if AUI.Settings.Buffs.target_show_time_limit_buffs then
		AddPreviewBuff("PreviewTargetPermTLPassiveBuff1", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF, "/esoui/art/icons/store_tricolor_food_01.dds", 7200000) -- Bufffood (All Attributes)	
	end		
	
	if AUI.Settings.Buffs.target_show_debuffs then
		AddPreviewBuff("PreviewTargetDebuff1", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF, "/esoui/art/icons/ability_destructionstaff_010.dds", 10000) -- Impuls
		AddPreviewBuff("PreviewTargetDebuff2", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF, "/esoui/art/icons/ability_destructionstaff_001b.dds", 1300) -- Kraftschlag
		AddPreviewBuff("PreviewTargetDebuff3", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF, "/esoui/art/icons/ability_destructionstaff_011.dds", 21000) -- größere Verteilung
		AddPreviewBuff("PreviewTargetDebuff4", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF, "/esoui/art/icons/ability_otherclass_001.dds", -1) -- Seelenfalle
		AddPreviewBuff("PreviewTargetDebuff5", AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF, "/esoui/art/icons/ability_undaunted_002.dds", 15000) -- Inneres Feuer
	end
end

function AUI.Buffs.ShowPreview(_show)
	if not g_isInit then
		return
	end

	AUI_Buff:SetHidden(not _show)
	
	for _, control in pairs(mainBuffControls) do
		local main = control		
		local info = GetControl(main, "_Info")
		local arrow = GetControl(main, "_DirectionArrow")
		local dragOverlay = GetControl(main, "_DragOverlay")
	
		main:SetMouseEnabled(_show)	
		info:SetHidden(not _show)
		arrow:SetHidden(not _show)
		dragOverlay:SetHidden(not _show)
	end	
	
	BUFF_SCENE_FRAGMENT.hiddenReasons:SetHiddenForReason("ShouldntShow", _show)	
	
	isPreviewShow = _show

	SetPreviewLayout(AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF)
	SetPreviewLayout(AUI_PLAYER_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF)
	SetPreviewLayout(AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_BUFF)
	SetPreviewLayout(AUI_TARGET_UNIT_TAG, BUFF_EFFECT_TYPE_DEBUFF)
	
	AUI.Buffs.RefreshAll()	
end

function AUI.Buffs.SetToDefaultPosition(_defaultSettings)
	if not g_isInit then
		return
	end

	_defaultSettings.target_debuff_position.point = _defaultSettings.target_buff_position.point
	_defaultSettings.target_debuff_position.relativePoint = _defaultSettings.target_buff_position.relativePoint
	_defaultSettings.target_debuff_position.offsetX = _defaultSettings.target_buff_position.offsetX

	AUI_Buff_Player_Buffs:ClearAnchors()
	AUI_Buff_Player_Buffs:SetAnchor(_defaultSettings.player_buff_position.point, GuiRoot, _defaultSettings.player_buff_position.relativePoint, _defaultSettings.player_buff_position.offsetX, _defaultSettings.player_buff_position.offsetY)
	_, AUI.Settings.Buffs.player_buff_position.point, _, AUI.Settings.Buffs.player_buff_position.relativePoint, AUI.Settings.Buffs.player_buff_position.offsetX, AUI.Settings.Buffs.player_buff_position.offsetY = AUI_Buff_Player_Buffs:GetAnchor()

	AUI_Buff_Player_Debuffs:ClearAnchors()
	AUI_Buff_Player_Debuffs:SetAnchor(_defaultSettings.player_debuff_position.point, GuiRoot, _defaultSettings.player_debuff_position.relativePoint, _defaultSettings.player_debuff_position.offsetX, _defaultSettings.player_debuff_position.offsetY)
	_, AUI.Settings.Buffs.player_debuff_position.point, _, AUI.Settings.Buffs.player_debuff_position.relativePoint, AUI.Settings.Buffs.player_debuff_position.offsetX, AUI.Settings.Buffs.player_debuff_position.offsetY = AUI_Buff_Player_Debuffs:GetAnchor()
		
	AUI_Buff_Target_Buffs:ClearAnchors()
	AUI_Buff_Target_Buffs:SetAnchor(_defaultSettings.target_buff_position.point, GuiRoot, _defaultSettings.target_buff_position.relativePoint, _defaultSettings.target_buff_position.offsetX, _defaultSettings.target_buff_position.offsetY)
	_, AUI.Settings.Buffs.target_buff_position.point, _, AUI.Settings.Buffs.target_buff_position.relativePoint, AUI.Settings.Buffs.target_buff_position.offsetX, AUI.Settings.Buffs.target_buff_position.offsetY = AUI_Buff_Target_Buffs:GetAnchor()
	SyncTargetDebuffPositionX()
		
	AUI_Buff_Target_Debuffs:ClearAnchors()
	AUI_Buff_Target_Debuffs:SetAnchor(_defaultSettings.target_debuff_position.point, GuiRoot, _defaultSettings.target_debuff_position.relativePoint, _defaultSettings.target_debuff_position.offsetX, _defaultSettings.target_debuff_position.offsetY)
	_, AUI.Settings.Buffs.target_debuff_position.point, _, AUI.Settings.Buffs.target_debuff_position.relativePoint, AUI.Settings.Buffs.target_debuff_position.offsetX, AUI.Settings.Buffs.target_debuff_position.offsetY = AUI_Buff_Target_Debuffs:GetAnchor()

end

function AUI.Buffs.RefreshAll()
	for _, control in pairs(mainBuffControls) do	
		local size, alignment, distance, fontArt, fontSize, showBuffTime, textPosition = GetBuffData(control.unitTag, control.effectType)		
		control:SetDimensions(size, size)
		
		local dragOverlay = GetControl(control, "_DragOverlay")
		if dragOverlay then
			dragOverlay:SetDimensions(size, size)
		end
	end		

	if buffDataList then
		for unitTag, unitTagList in pairs(buffDataList) do	
			for effectType, effectTypeList in pairs(unitTagList) do
				for id, control in pairs(effectTypeList) do
					local size, alignment, distance, fontArt, fontSize, showBuffTime, textPosition = GetBuffData(unitTag, effectType)
					
					control.buffData.size = size
					control.buffData.alignment = alignment
					control.buffData.distance = distance
					control.buffData.fontArt = fontArt
					control.buffData.fontSize = fontSize
					control.buffData.showBuffTime = showBuffTime
					control.buffData.textPosition = textPosition
					
					SetBuffLayout(control)
				end
				UpdateBuffsLayout(unitTag, effectType)
			end
		end	
	end	

	RefreshBuffs(AUI_PLAYER_UNIT_TAG)
	RefreshBuffs(AUI_TARGET_UNIT_TAG)
	
	if isPreviewShow then
		UpdatePreview()
	end		
end

function AUI.Buffs.OnTargetChanged()
	if not g_isInit or isPreviewShow then
		return
	end
		
	if DoesUnitExist(AUI_TARGET_UNIT_TAG) then
		RefreshBuffs(AUI_TARGET_UNIT_TAG)
	else
		RemoveBuffs(AUI_TARGET_UNIT_TAG)
	end		
end

function AUI.Buffs.OnPlayerActivated()
	if not g_isInit then
		if not currentTemplate then	
			local templateName = AUI.Settings.Templates.Buffs
			currentTemplate = AUI.Buffs.LoadTemplate(templateName)
		end

		AUI_Buff_Player_Buffs:ClearAnchors()
		AUI_Buff_Player_Buffs:SetAnchor(AUI.Settings.Buffs.player_buff_position.point, GUIROOT, AUI.Settings.Buffs.player_buff_position.relativePoint, AUI.Settings.Buffs.player_buff_position.offsetX, AUI.Settings.Buffs.player_buff_position.offsetY)
		AUI_Buff_Player_Buffs:SetHandler("OnMouseDown", function(_eventCode, _button, _ctrl, _alt, _shift) OnMouseDown(_eventCode, _button, _ctrl, _alt, _shift, AUI_Buff_Player_Buffs) end)
		AUI_Buff_Player_Buffs:SetHandler("OnMouseUp", function(_eventCode, _button, _ctrl, _alt, _shift) OnMouseUp(_eventCode, _button, _ctrl, _alt, _shift, AUI_Buff_Player_Buffs, AUI.Settings.Buffs.player_buff_position) end)

		AUI_Buff_Player_Debuffs:ClearAnchors()
		AUI_Buff_Player_Debuffs:SetAnchor(AUI.Settings.Buffs.player_debuff_position.point, GUIROOT, AUI.Settings.Buffs.player_debuff_position.relativePoint, AUI.Settings.Buffs.player_debuff_position.offsetX, AUI.Settings.Buffs.player_debuff_position.offsetY)
		AUI_Buff_Player_Debuffs:SetHandler("OnMouseDown", function(_eventCode, _button, _ctrl, _alt, _shift) OnMouseDown(_eventCode, _button, _ctrl, _alt, _shift, AUI_Buff_Player_Debuffs) end)
		AUI_Buff_Player_Debuffs:SetHandler("OnMouseUp", function(_eventCode, _button, _ctrl, _alt, _shift) OnMouseUp(_eventCode, _button, _ctrl, _alt, _shift, AUI_Buff_Player_Debuffs, AUI.Settings.Buffs.player_debuff_position) end)	
		
		AUI_Buff_Target_Buffs:ClearAnchors()
		AUI_Buff_Target_Buffs:SetAnchor(AUI.Settings.Buffs.target_buff_position.point, GUIROOT, AUI.Settings.Buffs.target_buff_position.relativePoint, AUI.Settings.Buffs.target_buff_position.offsetX, AUI.Settings.Buffs.target_buff_position.offsetY)
		AUI_Buff_Target_Buffs:SetHandler("OnMouseDown", function(_eventCode, _button, _ctrl, _alt, _shift) OnMouseDown(_eventCode, _button, _ctrl, _alt, _shift, AUI_Buff_Target_Buffs) end)
		AUI_Buff_Target_Buffs:SetHandler("OnMouseUp", function(_eventCode, _button, _ctrl, _alt, _shift)
			OnMouseUp(_eventCode, _button, _ctrl, _alt, _shift, AUI_Buff_Target_Buffs, AUI.Settings.Buffs.target_buff_position)
			SyncTargetDebuffPositionX()
		end)
		SyncTargetDebuffPositionX()

		AUI_Buff_Target_Debuffs:ClearAnchors()
		AUI_Buff_Target_Debuffs:SetAnchor(AUI.Settings.Buffs.target_debuff_position.point, GUIROOT, AUI.Settings.Buffs.target_debuff_position.relativePoint, AUI.Settings.Buffs.target_debuff_position.offsetX, AUI.Settings.Buffs.target_debuff_position.offsetY)
		AUI_Buff_Target_Debuffs:SetHandler("OnMouseDown", function(_eventCode, _button, _ctrl, _alt, _shift) OnMouseDown(_eventCode, _button, _ctrl, _alt, _shift, AUI_Buff_Target_Debuffs) end)
		AUI_Buff_Target_Debuffs:SetHandler("OnMouseUp", function(_eventCode, _button, _ctrl, _alt, _shift)
			OnMouseUp(_eventCode, _button, _ctrl, _alt, _shift, AUI_Buff_Target_Debuffs, AUI.Settings.Buffs.target_debuff_position)
			SyncTargetDebuffPositionX()
		end)	
		
		g_isInit = true
	end
	
	AUI.Buffs.RefreshAll()
end	

function AUI.Buffs.OnGamepadPreferredModeChanged(_gamepadPreferred)
	if g_isInit then
		AUI.Buffs.RefreshAll()
	end
end

function AUI.Buffs.Load()
	if g_isInit then
		return
	end

	AUI_Buff_Player_Buffs.unitTag = AUI_PLAYER_UNIT_TAG
	AUI_Buff_Player_Buffs.effectType = BUFF_EFFECT_TYPE_BUFF
	AUI_Buff_Player_Debuffs.unitTag = AUI_PLAYER_UNIT_TAG
	AUI_Buff_Player_Debuffs.effectType = BUFF_EFFECT_TYPE_DEBUFF	
	AUI_Buff_Target_Buffs.unitTag = AUI_TARGET_UNIT_TAG
	AUI_Buff_Target_Buffs.effectType = BUFF_EFFECT_TYPE_BUFF		
	AUI_Buff_Target_Debuffs.unitTag = AUI_TARGET_UNIT_TAG
	AUI_Buff_Target_Debuffs.effectType = BUFF_EFFECT_TYPE_DEBUFF		
	
	mainBuffControls = {
		[1] = AUI_Buff_Player_Buffs,
		[2] = AUI_Buff_Player_Debuffs,
		[3] = AUI_Buff_Target_Buffs,
		[4] = AUI_Buff_Target_Debuffs,
	}
	
	BUFF_SCENE_FRAGMENT = ZO_SimpleSceneFragment:New(AUI_Buff)
	BUFF_SCENE_FRAGMENT.hiddenReasons = ZO_HiddenReasons:New()		
    BUFF_SCENE_FRAGMENT:SetConditional(function()
        return not BUFF_SCENE_FRAGMENT.hiddenReasons:IsHidden()
    end)	
	
	HUD_SCENE:AddFragment(BUFF_SCENE_FRAGMENT)
	HUD_UI_SCENE:AddFragment(BUFF_SCENE_FRAGMENT)
	SIEGE_BAR_SCENE:AddFragment(BUFF_SCENE_FRAGMENT)
	if SIEGE_BAR_UI_SCENE then
		SIEGE_BAR_UI_SCENE:AddFragment(BUFF_SCENE_FRAGMENT)
	end		
end