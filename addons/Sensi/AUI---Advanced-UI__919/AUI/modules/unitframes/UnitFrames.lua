local gIsLoaded = false
local gCurrentTemplateData = nil

AUI.UnitFrames = {}
AUI.UnitFrames.Player = {}
AUI.UnitFrames.Target = {}
AUI.UnitFrames.Group = {}
AUI.UnitFrames.Raid = {}
AUI.UnitFrames.Boss = {}
AUI.UnitFrames.Companion = {}

AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH = 101
AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA = 102
AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA = 103
AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT = 104
AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF = 105
AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE = 106
AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD = 107
AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH = 201
AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_SHIELD = 202
AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH = 211
AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_SHIELD = 212
AUI_UNIT_FRAME_TYPE_GROUP_HEALTH = 301
AUI_UNIT_FRAME_TYPE_GROUP_SHIELD = 302
AUI_UNIT_FRAME_TYPE_GROUP_COMPANION = 303
AUI_UNIT_FRAME_TYPE_RAID_HEALTH = 401
AUI_UNIT_FRAME_TYPE_RAID_SHIELD = 402
AUI_UNIT_FRAME_TYPE_RAID_COMPANION = 403
AUI_UNIT_FRAME_TYPE_BOSS_HEALTH = 501
AUI_UNIT_FRAME_TYPE_BOSS_SHIELD = 502
AUI_UNIT_FRAME_TYPE_COMPANION = 601

local shieldAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD] = true,
	[AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_SHIELD] = true,
	[AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_SHIELD] = true,
	[AUI_UNIT_FRAME_TYPE_GROUP_SHIELD] = true,
	[AUI_UNIT_FRAME_TYPE_RAID_SHIELD] = true,
	[AUI_UNIT_FRAME_TYPE_BOSS_SHIELD] = true,
}

local playerAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH] = true,
	[AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA] = true,
	[AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA] = true,
	[AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT] = true,
	[AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF] = true,
	[AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE] = true,
	[AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD] = true,
}

local playerAttributeHealthIds = {
	[AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH] = true,
}

local playerMainAttributesIds = {
	[AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH] = true,
	[AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA] = true,
	[AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA] = true,
}

local targetAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH] = true,
	[AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_SHIELD] = true,
	[AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH] = true,
	[AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_SHIELD] = true,	
}

local targetAttributeHealthIds = {
	[AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH] = true,
	[AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH] = true,
}

local groupOrRaidHealthAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_GROUP_HEALTH] = true,
	[AUI_UNIT_FRAME_TYPE_RAID_HEALTH] = true,
}

local groupOrRaidAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_GROUP_HEALTH] = true,
	[AUI_UNIT_FRAME_TYPE_GROUP_SHIELD] = true,
	[AUI_UNIT_FRAME_TYPE_RAID_HEALTH] = true,
	[AUI_UNIT_FRAME_TYPE_RAID_SHIELD] = true,		
}

local groupAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_GROUP_HEALTH] = true,
	[AUI_UNIT_FRAME_TYPE_GROUP_SHIELD] = true,	
}

local groupOrRaidCompanionAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_GROUP_COMPANION] = true,
	[AUI_UNIT_FRAME_TYPE_RAID_COMPANION] = true,	
}

local mainCompanionAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_COMPANION] = true,	
}

local companionGroupAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_GROUP_COMPANION] = true,
}

local companionRaidAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_RAID_COMPANION] = true,
}

local raidAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_RAID_HEALTH] = true,
	[AUI_UNIT_FRAME_TYPE_RAID_SHIELD] = true,	
}

local bossHealthAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_BOSS_HEALTH] = true,
}

local bossAttributeIds = {
	[AUI_UNIT_FRAME_TYPE_BOSS_HEALTH] = true,
	[AUI_UNIT_FRAME_TYPE_BOSS_SHIELD] = true,
}

UNIT_FRAMES_SCENE_FRAGMENT = nil

local isPreviewShowed = false

local function IsControlAllowed(_control)
	if _control and _control.data and _control.settings and not _control.frames and _control.settings.display then
		return true
	end
	
	return false
end

local function GetControlFromAttributeId(_attributeId)	
	local data = gCurrentTemplateData.frameData
	if data then
		return data[_attributeId].control
	end
	
	return nil
end

function AUI.UnitFrames.IsShield(_attributeId)
	if shieldAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsPlayer(_attributeId)
	if playerAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsPlayerHealth(_attributeId)
	if playerAttributeHealthIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsTargetHealth(_attributeId)
	if targetAttributeHealthIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsTarget(_attributeId)
	if targetAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsGroupOrRaidHealth(_attributeId)
	if groupOrRaidHealthAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsGroupOrRaid(_attributeId)
	if groupOrRaidAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsGroup(_attributeId)
	if groupAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsGroupCompanion(_attributeId)
	if companionGroupAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsRaidCompanion(_attributeId)
	if companionRaidAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsGroupOrRaidCompanion(_attributeId)
	if groupOrRaidCompanionAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsMainCompanion(_attributeId)
	if mainCompanionAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsRaid(_attributeId)
	if raidAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsBossHealth(_attributeId)
	if bossHealthAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsBoss(_attributeId)
	if bossAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.UnitFrames.IsPlayerMainAttribute(_attributeId)
	if playerMainAttributesIds[_attributeId] then
		return true
	end
	
	return false
end

local function OnFrameMouseDown(_button, _ctrl, _alt, _shift, _control)
	local control = nil	
	
	for _, templateData in pairs(gCurrentTemplateData) do
		for frameType, data in pairs(templateData.frameData) do
			if frameType == _control.attributeId then
				control = data.control
				break
			end
		end		
	end

	if control and _button == 1 and not AUI.Settings.UnitFrames.lock_windows then
		control:SetMovable(true)
		control:StartMoving()
	end
end

local function OnFrameMouseUp(_button, _ctrl, _alt, _shift, _control)	
	local control = nil	
	
	for _, templateData in pairs(gCurrentTemplateData) do
		for frameType, data in pairs(templateData.frameData) do
			if frameType == _control.attributeId then
				control = data.control
				break
			end	
		end
	end		
	
	if control and _button == 1 then
		control:SetMovable(false)

		local anchorData = AUI.Settings.UnitFrames[control.templateType][control.templateName][_control.attributeId].anchor_data	
		if not AUI.Settings.UnitFrames.lock_windows then
			_, anchorData[0].point, _, anchorData[0].relativePoint, anchorData[0].offsetX, anchorData[0].offsetY = control:GetAnchor(0)		
			_, anchorData[1].point, _, anchorData[1].relativePoint, anchorData[1].offsetX, anchorData[1].offsetY = control:GetAnchor(1)
			AUI.Settings.UnitFrames[control.templateType][control.templateName][_control.attributeId].anchor_data.customPos = true	
		end
	end

	AUI.UnitFrames.Group.OnFrameMouseUp(_button, _ctrl, _alt, _shift, _control)
end	

local function IsFadeInAllowed(_control)
	if not IsControlAllowed(_control) then
		return false
	end
	
	if _control.isVisibilityControlled then
		return true
	end	

	if isPreviewShowed then
		if not AUI.UnitFrames.IsMainCompanion(_control.attributeId) and _control.unitTag == AUI_COMPANION_UNIT_TAG then
			return false
		end	
	
		return true
	end	

	if AUI.UnitFrames.IsGroupOrRaidHealth(_control.attributeId) then
		if IsUnitGrouped(_control.unitTag) then
			return true
		end	
	elseif AUI.UnitFrames.IsMainCompanion(_control.attributeId) then
		if DoesUnitExist(_control.unitTag) or isPreviewShowed then		
			if _control.hideInGroup and IsUnitGrouped(_control.unitTag) then
				return false
			else
				return true			
			end
		end			
	elseif AUI.UnitFrames.IsGroupOrRaidCompanion(_control.attributeId) then
		if DoesUnitExist(_control.unitTag)then	
			if _control.unitTag == AUI_COMPANION_UNIT_TAG and IsUnitGrouped(AUI_PLAYER_UNIT_TAG) then
				return false
			else
				return true
			end
		end			
	elseif AUI.UnitFrames.IsBossHealth(_control.attributeId) then
		if DoesUnitExist(_control.unitTag) and not IsUnitDead(_control.unitTag) then
			return true
		end
	elseif not IsUnitDead(_control.unitTag) then
		if AUI.UnitFrames.IsPlayerMainAttribute(_control.attributeId) then
			if _control.settings.show_always or 
				_control.data.increaseRegenData.isActive and _control.settings.show_increase_regen_effect or _control.data.increaseRegenData.isActive and _control.settings.show_increase_regen_color or
				_control.data.decreaseRegenData.isActive and _control.settings.show_decrease_regen_effect or _control.data.decreaseRegenData.isActive and _control.settings.show_decrease_regen_color or 
				_control.data.increaseArmorEffect.isActive and _control.settings.show_increase_armor_effect or 
				_control.data.decreaseArmorEffect.isActive and _control.settings.show_decrease_armor_effect or 
				_control.data.increasePowerEffect.isActive and _control.settings.show_increase_power_effect or 
				_control.data.decreasePowerEffect.isActive and _control.settings.show_decrease_power_effect or 
				_control.data.maxValue > 0 and _control.data.currentValue ~= _control.data.maxValue then
						
				return true
			end
		elseif AUI.UnitFrames.IsShield(_control.attributeId) then
			if _control.data.shield.isActive then
				return true
			end			
		elseif _control.attributeId == AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT then
			if IsMounted() and _control.data.currentValue ~= _control.data.maxValue then
				return true
			end
		elseif _control.attributeId == AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF then
			if IsWerewolf() and _control.data.currentValue > 0 then
				return true
			end
		elseif _control.attributeId == AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE then
			if IsPlayerControllingSiegeWeapon() then
				return true	
			end		
		end
	end
	
	return false
end

local function IsFadeOutAllowed(_control)
	if _control.isVisibilityControlled then
		return false
	end

	if AUI.UnitFrames.IsTargetHealth(_control.attributeId) then
		return false
	end

	if isPreviewShowed then
		if not AUI.UnitFrames.IsMainCompanion(_control.attributeId) and _control.unitTag == AUI_COMPANION_UNIT_TAG then
			return true
		end	
	
		return false
	end		

	if AUI.UnitFrames.IsShield(_control.attributeId) then
		if _control.data.shield.isActive then	
			return false
		end
	elseif AUI.UnitFrames.IsMainCompanion(_control.attributeId) then
		if not DoesUnitExist(_control.unitTag) and not isPreviewShowed then
			if not _control.hideInGroup and not IsUnitGrouped(_control.unitTag) then
				return false
			else
				return true			
			end		
		end			
	elseif AUI.UnitFrames.IsGroupOrRaidHealth(_control.attributeId) then
		if not IsUnitGrouped(_control.unitTag) then		
			return true
		end	
	elseif AUI.UnitFrames.IsGroupOrRaidCompanion(_control.attributeId) then
		if not DoesUnitExist(_control.unitTag) or _control.unitTag == AUI_COMPANION_UNIT_TAG and IsUnitGrouped(AUI_PLAYER_UNIT_TAG) then		
			return true			
		end			
	elseif AUI.UnitFrames.IsBossHealth(_control.attributeId) then
		if not DoesUnitExist(_control.unitTag) then
			return true
		end
	elseif IsUnitDead(_control.unitTag) then
		return true	
	elseif AUI.UnitFrames.IsPlayerMainAttribute(_control.attributeId) and 
		_control.settings.show_always and not 
		_control.data.increaseRegenData.isActive and not  
		_control.data.decreaseRegenData.isActive and not  
		_control.data.increaseArmorEffect.isActive and not  
		_control.data.decreaseArmorEffect.isActive and not  
		_control.data.increasePowerEffect.isActive and not  
		_control.data.decreasePowerEffect.isActive then 	
					
		return false		
	end
	
	return true
end

local function UpdateControlVisibility(_control)
	local duration = 300

	if IsFadeInAllowed(_control) then
		if AUI.UnitFrames.IsShield(_control.attributeId) then
			duration = 0
		end
		
		AUI.Fade.In(_control, duration, 0, 0, _control.settings.opacity)
		
		if _control.dependentControl and not _control.dependentControl.settings.show_always then
			_control.dependentControl.isVisibilityControlled = true
			AUI.Fade.In(_control.dependentControl, 0, 0, 0, _control.dependentControl.settings.opacity)		
		end
	elseif IsFadeOutAllowed(_control) then	
		if AUI.UnitFrames.IsShield(_control.attributeId) then
			duration = 0
		end
		
		AUI.Fade.Out(_control, duration, 0, _control.settings.opacity)	
		
		if _control.dependentControl and not _control.dependentControl.settings.show_always then
			AUI.Fade.Out(_control.dependentControl, duration, delay, _control.dependentControl.settings.opacity)
			_control.dependentControl.isVisibilityControlled = false
		end		
	end	
end

local function UpdateAttribute(_control)
	if not _control or not _control.settings or not _control.data.currentValue or not _control.data.maxValue then
		return
	end

	if _control.textValueControl then
		local text = _control.textValueControl:GetText()
		if not _control.textValueControl.text and not AUI.String.IsEmpty(text) then
			_control.textValueControl.text = text
		end
		
		local value = AUI.Math.Round(_control.data.currentValue)
		if _control.settings.use_thousand_seperator then
			value = AUI.String.ToFormatedNumber(value)
		end
		
		if _control.textValueControl.text  then
			value = _control.textValueControl.text:gsub("%%Value", value)
		end

		_control.textValueControl:SetText(value)	
	end
	
	if _control.textMaxValueControl then
		local text = _control.textMaxValueControl:GetText()
		if not _control.textMaxValueControl.text and not AUI.String.IsEmpty(text) then
			_control.textMaxValueControl.text = text
		end
		
		local value = AUI.Math.Round(_control.data.maxValue)
		if _control.settings.use_thousand_seperator then
			value = AUI.String.ToFormatedNumber(value)
		end	
		
		if _control.textMaxValueControl.text  then
			value = _control.textMaxValueControl.text:gsub("%%MaxValue", value)
		end

		_control.textMaxValueControl:SetText(value)	
	end	
	
	if _control.textPercentControl then	
		local text = _control.textPercentControl:GetText()
		if not _control.textPercentControl.text and not AUI.String.IsEmpty(text) then
			_control.textPercentControl.text = text
		end
		
		local value = 0
		
		if _control.data.maxValue > 0 then
			value = AUI.Math.Round((_control.data.currentValue / _control.data.maxValue) * 100)	
		end
		
		if _control.textPercentControl.text then
			value = _control.textPercentControl.text:gsub("%%Percent", value)
		end			
		
		_control.textPercentControl:SetText(value)
	end	
end

local function GetBarColor(_control)
	local color = _control.settings.bar_color
		
	if AUI.UnitFrames.IsGroupOrRaidHealth(_control.attributeId) then
		local unitRole = _control.role
		
		if unitRole == LFG_ROLE_TANK then
			color = _control.settings.bar_color_tank
		elseif unitRole == LFG_ROLE_HEAL then
			color = _control.settings.bar_color_healer
		else
			color = _control.settings.bar_color_dd
		end
	elseif AUI.UnitFrames.IsTargetHealth(_control.attributeId) then
		if IsUnitInvulnerableGuard(_control.unitTag) then
			color = _control.settings.bar_guard_color
		else
			local unitReaction = GetUnitReaction(_control.unitTag) 
			if unitReaction == UNIT_REACTION_FRIENDLY then
				color = _control.settings.bar_friendly_color
			elseif unitReaction == UNIT_REACTION_NEUTRAL then
				color = _control.settings.bar_neutral_color	
			elseif unitReaction == UNIT_REACTION_NPC_ALLY then	
				color = _control.settings.bar_allied_npc_color
			elseif unitReaction == UNIT_REACTION_PLAYER_ALLY then
				color = _control.settings.bar_allied_player_color
			elseif unitReaction == UNIT_REACTION_COMPANION then
				color = _control.settings.bar_companion_color				
			end
		end
	else
		color = _control.settings.bar_color
	end
	
	if _control.settings.show_increase_regen_color and _control.data.increaseRegenData.isActive then
		color = AUI.Color.GetColor(_control.settings.increase_regen_color)
	elseif _control.settings.show_decrease_regen_color and _control.data.decreaseRegenData.isActive then
		color = AUI.Color.GetColor(_control.settings.decrease_regen_color)
	end 
	
	return AUI.Color.GetColorDef(color)
end

local function SetGradientColor(_bar, colorList)
	local color1 = colorList[1]
	local color2 = colorList[2]

	if color1 then
		_bar:SetColor(color1:UnpackRGBA())
	end
	
	if color1 and color2 then
		_bar:SetGradientColors(color1.r, color1.g, color1.b, color1.a, color2.r, color2.g, color2.b, color2.a)
	end
end

local function UpdateBarColor(_control, _bar, _color)
	local bar_color = GetBarColor(_control)

	if bar_color then
		if bar_color[1] and bar_color[2] then
			SetGradientColor(_bar, bar_color)
		elseif bar_color[1] then
			_bar:SetColor(bar_color[1]:UnpackRGBA())
		end	
	end
end

local function SetArrowLayout(_barControl, _alignment)
	local barHeight = _barControl:GetHeight()	

	if _barControl.increaseRegControl then
		local increaseRegAnim = _barControl.increaseRegControl.animation
		if increaseRegAnim then
			if not _barControl.increaseRegControl.fixedDimensions then
				_barControl.increaseRegControl:SetDimensions(barHeight, barHeight / 2)		
			end
			
			local startX = _barControl.increaseRegControl.startX or 0			
			local endX = _barControl:GetWidth() - _barControl.increaseRegControl:GetWidth()
			
			if _barControl.increaseRegControl.endX then
				endX = endX + _barControl.increaseRegControl.endX
			end		
			
			if _alignment == BAR_ALIGNMENT_REVERSE then
				endX = -endX
			end				
			
			local startY = _barControl.increaseRegControl.startY or 0
			local endY = _barControl.increaseRegControl.endY or 0			
			local duration = _barControl.increaseRegControl.duration or 1000	
			
			increaseRegAnim:GetFirstAnimation():SetStartOffsetX(startX)
			increaseRegAnim:GetFirstAnimation():SetEndOffsetX(endX)		
			increaseRegAnim:GetFirstAnimation():SetStartOffsetY(startY)
			increaseRegAnim:GetFirstAnimation():SetEndOffsetY(endY)
			increaseRegAnim:GetFirstAnimation():SetDuration(duration)
			increaseRegAnim:GetAnimation(2):SetDuration(duration / 2)
			increaseRegAnim:GetAnimation(3):SetDuration(duration / 2)			
			increaseRegAnim:SetAnimationOffset(increaseRegAnim:GetAnimation(3), duration / 2)
		end		
	end
	
	if _barControl.decreaseRegControl then			
		local decreaseRegAnim = _barControl.decreaseRegControl.animation
		if decreaseRegAnim then
			if not _barControl.decreaseRegControl.fixedDimensions then
				_barControl.decreaseRegControl:SetDimensions(barHeight, barHeight / 2)	
			end
			
			local startX = _barControl.decreaseRegControl.startX or 0			
			local endX = _barControl:GetWidth() - _barControl.decreaseRegControl:GetWidth()
			
			if _barControl.decreaseRegControl.endX then
				endX = endX + _barControl.decreaseRegControl.endX
			end		
			
			if _alignment == BAR_ALIGNMENT_NORMAL then
				endX = -endX					
			end				
			
			local startY = _barControl.decreaseRegControl.startY or 0
			local endY = _barControl.decreaseRegControl.endY or 0				
			local duration = _barControl.decreaseRegControl.duration or 1000
			
			decreaseRegAnim:GetFirstAnimation():SetStartOffsetX(startX)
			decreaseRegAnim:GetFirstAnimation():SetEndOffsetX(endX)	
			decreaseRegAnim:GetFirstAnimation():SetStartOffsetY(startY)
			decreaseRegAnim:GetFirstAnimation():SetEndOffsetY(endY)
			decreaseRegAnim:GetFirstAnimation():SetDuration(duration)
			decreaseRegAnim:GetAnimation(2):SetDuration(duration / 2)
			decreaseRegAnim:GetAnimation(3):SetDuration(duration / 2)			
			decreaseRegAnim:SetAnimationOffset(decreaseRegAnim:GetAnimation(3), duration / 2)					
		end
	end
end

local function SetLayout(_control)
	if _control.levelControl then
		local fontSizeMultipler = _control.unitNameControl.fontSizeMultipler or 1 
		local font_art = _control.settings.font_art

		if _control.levelControl.font then
			font_art = _control.levelControl.font
		end
	
		_control.levelControl:SetFont(font_art .. "|" .. _control.settings.font_size * fontSizeMultipler .. "|" .. _control.settings.font_style)
	end
													
	if _control.unitNameControl then
		local fontSizeMultipler = _control.unitNameControl.fontSizeMultipler or 1 
		local font_art = _control.settings.font_art
		
		if _control.unitNameControl.font then
			font_art = _control.unitNameControl.font
		end	
		
		_control.unitNameControl:SetFont(font_art .. "|" .. _control.settings.font_size * fontSizeMultipler .. "|" .. _control.settings.font_style)
	end					
	
	if _control.offlineInfoControl then
		local fontSizeMultipler = _control.offlineInfoControl.fontSizeMultipler or 1 
		local font_art = _control.settings.font_art
		
		if _control.offlineInfoControl.font then
			font_art = _control.offlineInfoControl.font
		end		
	
		_control.offlineInfoControl:SetFont(font_art .. "|" .. _control.settings.font_size * fontSizeMultipler.. "|" .. _control.settings.font_style)
		_control.offlineInfoControl:SetText(AUI.L10n.GetString("offline"))
	end	
		
	if _control.deadInfoControl then
		local fontSizeMultipler = _control.deadInfoControl.fontSizeMultipler or 1 
		local font_art = _control.settings.font_art
		
		if _control.deadInfoControl.font then
			font_art = _control.deadInfoControl.font
		end		
	
		_control.deadInfoControl:SetFont(font_art .. "|" .. _control.settings.font_size * fontSizeMultipler.. "|" .. _control.settings.font_style)
		_control.deadInfoControl:SetText(AUI.L10n.GetString("dead"))				
	end			
					
	if _control.textValueControl then
		local fontSizeMultipler = _control.textValueControl.fontSizeMultipler or 1 
		local font_art = _control.settings.font_art
		
		if _control.textValueControl.font then
			font_art = _control.textValueControl.font
		end		
			
		_control.textValueControl:SetFont(font_art .. "|" .. _control.settings.font_size * fontSizeMultipler.. "|" .. _control.settings.font_style)
		if _control.settings.show_text then
			_control.textValueControl:SetHidden(false)
		else
			_control.textValueControl:SetHidden(true)
		end						
	end

	if _control.textMaxValueControl then
		local fontSizeMultipler = _control.textMaxValueControl.fontSizeMultipler or 1 
		local font_art = _control.settings.font_art
		
		if _control.textMaxValueControl.font then
			font_art = _control.textMaxValueControl.font
		end		
	
		_control.textMaxValueControl:SetFont(font_art .. "|" .. _control.settings.font_size * fontSizeMultipler.. "|" .. _control.settings.font_style)
		if _control.settings.show_text and _control.settings.show_max_value then
			_control.textMaxValueControl:SetHidden(false)
			_control.textMaxValueControl:SetDimensions(0, 0)
		else
			_control.textMaxValueControl:SetHidden(true)
			_control.textMaxValueControl:SetDimensions(1, 1)
		end			
	end	
		
	if _control.textPercentControl then
		local fontSizeMultipler = _control.textPercentControl.fontSizeMultipler or 1 
		local font_art = _control.settings.font_art
		
		if _control.textPercentControl.font then
			font_art = _control.textPercentControl.font
		end		
	
		_control.textPercentControl:SetFont(font_art .. "|" .. _control.settings.font_size * fontSizeMultipler.. "|" .. _control.settings.font_style)
		if _control.settings.show_text then
			_control.textPercentControl:SetHidden(false)
		else
			_control.textPercentControl:SetHidden(true)
		end			
	end				

	if _control.championIconControl and _control.championIconControl.scaleToFont then
		_control.championIconControl:SetDimensions(_control.settings.font_size + 4, _control.settings.font_size + 4)
	end

	if _control.classIconControl and _control.classIconControl.scaleToFont then
		_control.classIconControl:SetDimensions(_control.settings.font_size + 8, _control.settings.font_size + 8)
	end

	if _control.leaderIconControl and _control.leaderIconControl.scaleToFont then
		_control.leaderIconControl:SetDimensions(_control.settings.font_size + 10, _control.settings.font_size + 10)
	end	
	
	if _control.rankIconControl and _control.rankIconControl.scaleToFont then
		_control.rankIconControl:SetDimensions(_control.settings.font_size + 10, _control.settings.font_size + 10)
	end		
	
	local bar_color = GetBarColor(_control)
	
	if bar_color then
		if _control.bar then
			UpdateBarColor(_control, _control.bar, bar_color)
			
			if _control.bar2 then
				UpdateBarColor(_control, _control.bar2, bar_color)
			end		
		end
	end		

	if _control.mainControl then
		_control.settings.bar_alignment = _control.mainControl.settings.bar_alignment
	end

	if _control.bar then
		if _control.bar2 and _control.settings.bar_alignment == BAR_ALIGNMENT_CENTER then
			_control.bar:ClearAnchors()			
			_control.bar:SetAnchor(_control.bar.defaultAnchor[0].point, nil, _control.bar.defaultAnchor[0].relativePoint, _control.bar.defaultAnchor[0].offsetX, _control.bar.defaultAnchor[0].offsetY)
			_control.bar:SetAnchor(_control.bar.defaultAnchor[1].point, nil, _control.bar.defaultAnchor[1].relativePoint, _control.bar.defaultAnchor[1].offsetX, _control.bar.defaultAnchor[1].offsetY)		

			_control.bar2:ClearAnchors()			
			_control.bar2:SetAnchor(_control.bar2.defaultAnchor[0].point, nil, _control.bar2.defaultAnchor[0].relativePoint, _control.bar2.defaultAnchor[0].offsetX, _control.bar2.defaultAnchor[0].offsetY)
			_control.bar2:SetAnchor(_control.bar2.defaultAnchor[1].point, nil, _control.bar2.defaultAnchor[1].relativePoint, _control.bar2.defaultAnchor[1].offsetX, _control.bar2.defaultAnchor[1].offsetY)			
		
			if _control.bar.increaseRegControl and _control.bar.increaseRegControl.defaultAnchor then
				_control.bar.increaseRegControl:ClearAnchors()			
				_control.bar.increaseRegControl:SetAnchor(RIGHT, nil, RIGHT, _control.bar.increaseRegControl.defaultAnchor.offsetX, _control.bar.increaseRegControl.defaultAnchor.offsetY)
				_control.bar.increaseRegControl:SetTextureCoords(0, 1, 1, 0)				
			end
			
			if _control.bar.decreaseRegControl and _control.bar.decreaseRegControl.defaultAnchor then
				_control.bar.decreaseRegControl:ClearAnchors()			
				_control.bar.decreaseRegControl:SetAnchor(LEFT, nil, LEFT, _control.bar.decreaseRegControl.defaultAnchor.offsetX, _control.bar.decreaseRegControl.defaultAnchor.offsetY)
				_control.bar.decreaseRegControl:SetTextureCoords(1, 0, 0, 1) 
			end		
		
			if _control.bar2.increaseRegControl and _control.bar2.increaseRegControl.defaultAnchor then
				_control.bar2.increaseRegControl:ClearAnchors()			
				_control.bar2.increaseRegControl:SetAnchor(LEFT, nil, LEFT, _control.bar2.increaseRegControl.defaultAnchor.offsetX, _control.bar2.increaseRegControl.defaultAnchor.offsetY)	
				_control.bar2.increaseRegControl:SetTextureCoords(1, 0, 0, 1) 
			end
			
			if _control.bar2.decreaseRegControl and _control.bar2.decreaseRegControl.defaultAnchor then
				_control.bar2.decreaseRegControl:ClearAnchors()			
				_control.bar2.decreaseRegControl:SetAnchor(RIGHT, nil, RIGHT, _control.bar2.decreaseRegControl.defaultAnchor.offsetX, _control.bar2.decreaseRegControl.defaultAnchor.offsetY)
				_control.bar2.decreaseRegControl:SetTextureCoords(0, 1, 1, 0)
			end			
		
			_control.bar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)

			if _control.bar.barGloss then
				_control.bar.barGloss:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
			end		
					
			_control.bar2:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
			
			if _control.bar2.barGloss then
				_control.bar2.barGloss:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
			end
		else
			_control.bar:ClearAnchors()	
			if _control.bar.defaultAnchor[0].point == LEFT and _control.bar.defaultAnchor[1].point == RIGHT then				
				_control.bar:SetAnchor(_control.bar.defaultAnchor[0].point, nil, _control.bar.defaultAnchor[0].relativePoint, _control.bar.defaultAnchor[0].offsetX, _control.bar.defaultAnchor[0].offsetY)
				_control.bar:SetAnchor(_control.bar.defaultAnchor[1].point, nil, _control.bar.defaultAnchor[1].relativePoint, _control.bar.defaultAnchor[1].offsetX, _control.bar.defaultAnchor[1].offsetY)	
			else	
				_control.bar:SetAnchor(_control.bar.defaultAnchor[0].point, nil, _control.bar.defaultAnchor[0].point, _control.bar.defaultAnchor[0].offsetX, _control.bar.defaultAnchor[0].offsetY)
				_control.bar:SetAnchor(_control.bar.defaultAnchor[1].point, nil, _control.bar.defaultAnchor[1].point, _control.bar.defaultAnchor[1].offsetX, _control.bar.defaultAnchor[1].offsetY)							
			end
			
			if _control.bar.increaseRegControl and _control.bar.increaseRegControl.defaultAnchor then	
				_control.bar.increaseRegControl:ClearAnchors()			
				
				if _control.settings.bar_alignment == BAR_ALIGNMENT_NORMAL then		
					_control.bar.increaseRegControl:SetAnchor(LEFT, nil, LEFT, _control.bar.increaseRegControl.defaultAnchor.offsetX, _control.bar.increaseRegControl.defaultAnchor.offsetY)
					_control.bar.increaseRegControl:SetTextureCoords(1, 0, 0, 1)
				elseif _control.settings.bar_alignment == BAR_ALIGNMENT_REVERSE then		
					_control.bar.increaseRegControl:SetAnchor(RIGHT, nil, RIGHT, _control.bar.increaseRegControl.defaultAnchor.offsetX, _control.bar.increaseRegControl.defaultAnchor.offsetY)				
					_control.bar.increaseRegControl:SetTextureCoords(0, 1, 1, 0)
				else		
					_control.bar.increaseRegControl:SetAnchor(LEFT, nil, LEFT, _control.bar.increaseRegControl.defaultAnchor.offsetX, _control.bar.increaseRegControl.defaultAnchor.offsetY)				
					_control.bar.increaseRegControl:SetTextureCoords(1, 0, 0, 1)
				end
			end
			
			if _control.bar.decreaseRegControl and _control.bar.decreaseRegControl.defaultAnchor then
				_control.bar.decreaseRegControl:ClearAnchors()			

				if _control.settings.bar_alignment == BAR_ALIGNMENT_NORMAL then
					_control.bar.decreaseRegControl:SetAnchor(RIGHT, nil, RIGHT, _control.bar.decreaseRegControl.defaultAnchor.offsetX, _control.bar.decreaseRegControl.defaultAnchor.offsetY)	
					_control.bar.decreaseRegControl:SetTextureCoords(0, 1, 1, 0)
				elseif _control.settings.bar_alignment == BAR_ALIGNMENT_REVERSE then
					_control.bar.decreaseRegControl:SetAnchor(LEFT, nil, LEFT, _control.bar.decreaseRegControl.defaultAnchor.offsetX, _control.bar.decreaseRegControl.defaultAnchor.offsetY)	
					_control.bar.decreaseRegControl:SetTextureCoords(1, 0, 0, 1)
				else
					_control.bar.decreaseRegControl:SetAnchor(RIGHT, nil, RIGHT, _control.bar.decreaseRegControl.defaultAnchor.offsetX, _control.bar.decreaseRegControl.defaultAnchor.offsetY)	
					_control.bar.decreaseRegControl:SetTextureCoords(0, 1, 1, 0)
				end				
			end				
			
			_control.bar:SetBarAlignment(_control.settings.bar_alignment)

			if _control.bar.barGloss then
				_control.bar.barGloss:SetBarAlignment(_control.settings.bar_alignment)
			end		
		end
	end

	if _control.settings.bar_alignment == BAR_ALIGNMENT_CENTER then
		if _control.bar and _control.bar2 then	
			SetArrowLayout(_control.bar, BAR_ALIGNMENT_REVERSE)
			SetArrowLayout(_control.bar2, BAR_ALIGNMENT_NORMAL)
		else
			SetArrowLayout(_control.bar, BAR_ALIGNMENT_NORMAL)
		end
	else	
		SetArrowLayout(_control.bar, _control.settings.bar_alignment)
	end

	if _control.settings.width and _control.settings.height then
		_control:SetDimensions(_control.settings.width, _control.settings.height)	
	end
	
	_control:SetHandler("OnMouseDown", function(_eventCode, _button, _ctrl, _alt, shift) OnFrameMouseDown(_button, _ctrl, _alt, _shift, relativeMoveControl or _control) end)
	_control:SetHandler("OnMouseUp", function(_eventCode, _button, _ctrl, _alt, shift) OnFrameMouseUp(_button, _ctrl, _alt, _shift, relativeMoveControl or _control) end)	

	if _control.warnerControl then
		_control.warnerControl:SetHidden(true)
	end		

	if _control.decreasedArmorOverlayControl and _control.decreasedArmorOverlayControl.offsetLeft and _control.decreasedArmorOverlayControl.offsetTop and _control.decreasedArmorOverlayControl.offsetRight and _control.decreasedArmorOverlayControl.offsetBottom then
		local width, height = _control:GetDimensions();					
		_control.decreasedArmorOverlayControl:ClearAnchors()
		_control.decreasedArmorOverlayControl:SetAnchor(TOPLEFT, _control, TOPLEFT, _control.decreasedArmorOverlayControl.offsetLeft, _control.decreasedArmorOverlayControl.offsetTop);			
		_control.decreasedArmorOverlayControl:SetDimensions((width + _control.decreasedArmorOverlayControl.offsetRight) - _control.decreasedArmorOverlayControl.offsetLeft, (height - _control.decreasedArmorOverlayControl.offsetTop) + _control.decreasedArmorOverlayControl.offsetBottom);
	end	

	if _control.increasedPowerOverlayControl and _control.increasedPowerOverlayControl.offsetLeft and _control.increasedPowerOverlayControl.offsetTop and _control.increasedPowerOverlayControl.offsetRight and _control.increasedPowerOverlayControl.offsetBottom then
		local width, height = _control:GetDimensions();					
		_control.increasedPowerOverlayControl:ClearAnchors()
		_control.increasedPowerOverlayControl:SetAnchor(TOPLEFT, _control, TOPLEFT, -(width / 2) + _control.increasedPowerOverlayControl.offsetLeft, -(height / 2) + _control.increasedPowerOverlayControl.offsetTop);			
		_control.increasedPowerOverlayControl:SetDimensions(((width * 2) + _control.increasedPowerOverlayControl.offsetRight) - _control.increasedPowerOverlayControl.offsetLeft, ((height * 2) - _control.increasedPowerOverlayControl.offsetTop) + _control.increasedPowerOverlayControl.offsetBottom);
	end		
			
	if _control.decreasedPowerOverlayControl and _control.decreasedPowerOverlayControl.offsetLeft and _control.decreasedPowerOverlayControl.offsetTop and _control.decreasedPowerOverlayControl.offsetRight and _control.decreasedPowerOverlayControl.offsetBottom then
		local width, height = _control:GetDimensions();				
		_control.decreasedPowerOverlayControl:ClearAnchors()
		_control.decreasedPowerOverlayControl:SetAnchor(TOPLEFT, _control, TOPLEFT, -(width / 2) + _control.decreasedPowerOverlayControl.offsetLeft, -(height / 2) + _control.decreasedPowerOverlayControl.offsetTop);			
		_control.decreasedPowerOverlayControl:SetDimensions(((width * 2) + _control.decreasedPowerOverlayControl.offsetRight) - _control.decreasedPowerOverlayControl.offsetLeft, ((height * 2) - _control.decreasedPowerOverlayControl.offsetTop) + _control.decreasedPowerOverlayControl.offsetBottom);
	end
end

local function UpdateArrowAnimation(_data, _settings, _barControl)
	if not _data or not _barControl then
		return
	end

	if _data.increaseRegenData.isActive and _settings.show_increase_regen_effect then
		if _barControl.increaseRegControl and _barControl.increaseRegControl.animation and not _barControl.increaseRegControl.animation:IsPlaying() then
			_barControl.increaseRegControl.animation:PlayFromStart() 
		end	
	elseif _data.decreaseRegenData.isActive and _settings.show_decrease_regen_effect then
		if _barControl.decreaseRegControl and _barControl.decreaseRegControl.animation and not _barControl.decreaseRegControl.animation:IsPlaying() then
			_barControl.decreaseRegControl.animation:PlayFromStart() 
		end		
	end		
end

local function StopArrowAnimation(_barControl)
	if _barControl.increaseRegControl then
		if AUI.Animations.IsPlaying(_barControl.increaseRegControl) then
			AUI.Animations.StopAnimation(_barControl.increaseRegControl)	
		end
	end
	
	if _barControl.decreaseRegControl then
		if AUI.Animations.IsPlaying(_barControl.decreaseRegControl) then
			AUI.Animations.StopAnimation(_barControl.decreaseRegControl)	
		end
	end							
end

local function ShowWarner(_control)
	if _control and _control.warnerControl then	
		local bar_color = GetBarColor(_control)
	
		if _control.leftWarnerControl then
			if bar_color then
				if bar_color[1] then
					_control.leftWarnerControl:SetColor(bar_color[1]:UnpackRGBA())
				end	
			end
		end
			
		if _control.rightWarnerControl then
			if bar_color then
				if bar_color[1] then
					_control.rightWarnerControl:SetColor(bar_color[1]:UnpackRGBA())
				end	
			end
		end
			
		if _control.centerWarnerControl then
			if bar_color then
				if bar_color[1] then
					_control.centerWarnerControl:SetColor(bar_color[1]:UnpackRGBA())
				end	
			end
		end
	
		if _control.warnerControl.animation and not _control.warnerControl.animation:IsPlaying()then				
			_control.warnerControl.animation:PlayFromStart()
		end
		
		if _control.warnerControl:IsHidden() then				
			_control.warnerControl:SetHidden(false)
		end
	end
end

local function HideWarner(_control)	
	if _control and _control.warnerControl then	
		if _control.warnerControl.animation and _control.warnerControl.animation:IsPlaying() then	
			_control.warnerControl.animation:Stop()
		end

		_control.warnerControl:SetHidden(true)
	end		
end

local function ShowIncreaseArmorEffect(_control)
	if _control and _control.increasedArmorOverlayControl and _control.settings.show_increase_armor_effect then	
	
		if IsUnitDead(_control.unitTag) or not IsUnitOnline(_control.unitTag) then
			return
		end

		_control.data.increaseArmorEffect.isActive = true
			
		if _control.increasedArmorOverlayControl.animation and not _control.increasedArmorOverlayControl.animation:IsPlaying()then		
			_control.increasedArmorOverlayControl.animation:PlayFromStart()
		end	
			
		if _control.increasedArmorOverlayControl:IsHidden() then
			_control.increasedArmorOverlayControl:SetHidden(false)
			UpdateControlVisibility(_control)
		end
	end
end

local function HideIncreaseArmorEffect(_control)
	if _control then		
		_control.data.increaseArmorEffect.isActive = false		
			
		if _control.increasedArmorOverlayControl then
			if _control.increasedArmorOverlayControl.animation and _control.increasedArmorOverlayControl.animation:IsPlaying()then		
				_control.increasedArmorOverlayControl.animation:Stop()
			end	
					
			_control.increasedArmorOverlayControl:SetHidden(true)
			UpdateControlVisibility(_control)
		end
	end
end

local function ShowDecreaseArmorEffect(_control)
	if _control and _control.decreasedArmorOverlayControl then
		if IsUnitDead(_control.unitTag) or not IsUnitOnline(_control.unitTag) then
			return
		end	
	
		if _control.decreasedArmorOverlayControl:IsHidden() and _control.settings.show_decrease_armor_effect then
			_control.data.decreaseArmorEffect.isActive = true
			
			if _control.decreasedArmorOverlayControl.animation and not _control.decreasedArmorOverlayControl.animation:IsPlaying()then		
				_control.decreasedArmorOverlayControl.animation:PlayFromStart()
			end	
			
			if _control.decreasedArmorOverlayControl:IsHidden() then	
				_control.decreasedArmorOverlayControl:SetHidden(false)		
				UpdateControlVisibility(_control)
			end
		end
	end
end

local function HideDecreaseArmorEffect(_control)
	if _control and _control.decreasedArmorOverlayControl then
		_control.data.decreaseArmorEffect.isActive = false
			
		if _control.decreasedArmorOverlayControl.animation and _control.decreasedArmorOverlayControl.animation:IsPlaying()then		
			_control.decreasedArmorOverlayControl.animation:Stop()
		end	
				
		_control.decreasedArmorOverlayControl:SetHidden(true)
		UpdateControlVisibility(_control)
	end
end

local function ShowIncreasePowerEffect(_control)
	if _control and _control.increasedPowerOverlayControl and _control.settings.show_increase_power_effect then	
		if IsUnitDead(_control.unitTag) or not IsUnitOnline(_control.unitTag) then
			return
		end	
	
		_control.data.increasePowerEffect.isActive = true
			
		if _control.increasedPowerOverlayControl.animation and not _control.increasedPowerOverlayControl.animation:IsPlaying()then		
			_control.increasedPowerOverlayControl.animation:PlayFromStart()
		end	
				
		if _control.increasedPowerOverlayControl:IsHidden() then		
			_control.increasedPowerOverlayControl:SetHidden(false)
			UpdateControlVisibility(_control)	
		end
	end
end

local function HideIncreasePowerEffect(_control)
	if _control then		
		_control.data.increasePowerEffect.isActive = false
			
		if _control.increasedPowerOverlayControl then
			if _control.increasedPowerOverlayControl.animation and _control.increasedPowerOverlayControl.animation:IsPlaying() then
				_control.increasedPowerOverlayControl.animation:Stop()			
			end	

			_control.increasedPowerOverlayControl:SetHidden(true)	
			UpdateControlVisibility(_control)
		end
	end
end

local function ShowDecreasePowerEffect(_control)
	if _control and _control.decreasedPowerOverlayControl and _control.settings.show_decrease_power_effect then
		if IsUnitDead(_control.unitTag) or not IsUnitOnline(_control.unitTag) then
			return
		end	
	
		_control.data.decreasePowerEffect.isActive = true
			
		if _control.decreasedPowerOverlayControl.animation and not _control.decreasedPowerOverlayControl.animation:IsPlaying() then	
			_control.decreasedPowerOverlayControl.animation:PlayFromStart()
		end	
			
		if _control.decreasedPowerOverlayControl:IsHidden() then
			_control.decreasedPowerOverlayControl:SetHidden(false)
			UpdateControlVisibility(_control)
		end			
	end
end

local function HideDecreasePowerEffect(_control)
	if _control and _control.decreasedPowerOverlayControl  then	
		_control.data.decreasePowerEffect.isActive = false
					
		if _control.decreasedPowerOverlayControl.animation and _control.decreasedPowerOverlayControl.animation:IsPlaying() then
			_control.decreasedPowerOverlayControl.animation:Stop()			
		end	

		_control.decreasedPowerOverlayControl:SetHidden(true)
		UpdateControlVisibility(_control)
	end
end

local function SetStatusBar(_barControl, _currentValue, _maxValue, _smooth)
	if not _barControl or not _currentValue or not _maxValue or (_currentValue == 0 and _maxValue == 0) then
		return
	end

	local smooth = _smooth or false
	
	ZO_StatusBar_SmoothTransition(_barControl, _currentValue, _maxValue, not _smooth)		
			
	if _barControl.barGloss then
		ZO_StatusBar_SmoothTransition(_barControl.barGloss, _currentValue, _maxValue, not _smooth)
	end
end

local function UpdateMainBar(_control, _smooth)
	local statusValue = _control.data.currentValue
	local statusMax = _control.data.maxValue

	if _control.bar then		
		if isPreviewShowed then
			statusValue = DEFAULT_PREVIEW_HP
			statusMax = DEFAULT_PREVIEW_HP			
		end
		
		if _control.subControl and _control.subControl.data.currentValue > 0 then	
			local subBarValue =  statusMax - (statusMax - _control.data.currentValue)			
			local mainBarValue = statusValue - _control.subControl.data.currentValue														
					
			SetStatusBar(_control.bar, mainBarValue, statusMax, _smooth)		
			SetStatusBar(_control.subControl.bar, subBarValue, statusMax, false)

			if _control.bar2 then	
				SetStatusBar(_control.bar2, mainBarValue, statusMax, _smooth)			
				SetStatusBar(_control.subControl.bar2, subBarValue, statusMax, false)
			end		
		else		
			SetStatusBar(_control.bar, statusValue, statusMax, _smooth)
			
			if _control.bar2 then	
				SetStatusBar(_control.bar2, statusValue, statusMax, _smooth)
			end
		end			
	end				
end

local function UpdateBar(_control, _bar, _smooth, _color)
	UpdateBarColor(_control, _bar, _color)			

	if _control.mainControl then	
		UpdateMainBar(_control.mainControl, _smooth)			
	elseif _control.subControl then
		UpdateMainBar(_control.subControl.mainControl, _smooth)	
	else
		SetStatusBar(_bar, _control.data.currentValue, _control.data.maxValue, _smooth)
	end		
end

local function UpdateData(_control, _currentValue, _maxValue, _smooth, _color)	
	if not IsControlAllowed(_control) then
		return
	end
	
	_control.data.currentValue = _currentValue or 0
	_control.data.maxValue = _maxValue or 0

	if _control.bar then		
		UpdateBar(_control, _control.bar, _smooth, _color)
		
		if _control.bar2 then	
			UpdateBar(_control, _control.bar2, _smooth, _color)
		end				
	end
			
	UpdateAttribute(_control)		
		
	local percent = AUI.Math.Round((_control.data.currentValue / _control.data.maxValue) * 100)
	if percent <= 25 and not IsUnitDead(_control.unitTag) then
		ShowWarner(_control)
	else
		HideWarner(_control)
	end		

	UpdateControlVisibility(_control)
end

local function UpdateRegen(_control, _isNewTarget)
	if not IsControlAllowed(_control) then
		return
	end

	_control.data.regenValue = _control.data.increaseRegenData.value + _control.data.decreaseRegenData.value
	
	if _control.data.regenValue > 0 then
		if not _control.data.increaseRegenData.isActive then
			_control.data.increaseRegenData.isActive = true					
		end	

		if _control.data.decreaseRegenData.isActive then
			_control.data.decreaseRegenData.isActive = false
		end				
	elseif _control.data.regenValue < 0 then
		if not _control.data.decreaseRegenData.isActive then
			_control.data.decreaseRegenData.isActive = true					
		end	

		if _control.data.increaseRegenData.isActive then
			_control.data.increaseRegenData.isActive = false
		end				
	else
		if _control.data.increaseRegenData.isActive then
			_control.data.increaseRegenData.isActive = false
		end			
	
		if _control.data.decreaseRegenData.isActive then
			_control.data.decreaseRegenData.isActive = false
		end					
	end
	
	if _control.bar then
		UpdateBarColor(_control, _control.bar)
		
		if _control.bar2 then
			UpdateBarColor(_control, _control.bar2)
		end						
		
		if _isNewTarget then
			StopArrowAnimation(_control.bar)

			if _control.bar2 then
				StopArrowAnimation(_control.bar2)
			end					
		end
		
		UpdateArrowAnimation(_control.data, _control.settings, _control.bar)
		
		if _control.bar2 then
			UpdateArrowAnimation(_control.data, _control.settings, _control.bar2)
		end
	elseif _control.bar then	
		UpdateBarColor(_control, _control.bar)
		
		if _isNewTarget then
			StopArrowAnimation(_control.bar)		
		end			
		
		UpdateArrowAnimation(_control.data, _control.settings, _control.bar)
	end		

	UpdateControlVisibility(_control)
end

local function AddAttributeVisual(_control, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth, _isNewTarget)
	if not IsControlAllowed(_control) then
		return
	end

	if _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		if AUI.UnitFrames.IsShield(_control.attributeId) then
			if _unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and _statType == STAT_MITIGATION then	
				_control.data.shield.isActive = true				
				UpdateData(_control, _powerValue, _powerMax, _smooth)
			end
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_MAX_POWER and _statType == STAT_MITIGATION then
			UpdateData(_control, _powerValue, _powerMax, _smooth)						
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_MAX_POWER and _statType == STAT_MITIGATION then
			UpdateData(_control, _powerValue, _powerMax, _smooth)									
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT then
			_control.data.decreaseRegenData.value = _powerValue or 0	
			UpdateRegen(_control, _isNewTarget)	
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT then
			_control.data.increaseRegenData.value = _powerValue or 0	
			UpdateRegen(_control, _isNewTarget)			
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_ARMOR_RATING then
			ShowIncreaseArmorEffect(_control)			
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_ARMOR_RATING then
			ShowDecreaseArmorEffect(_control)
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_POWER then	
			ShowIncreasePowerEffect(_control)			
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_POWER then	
			ShowDecreasePowerEffect(_control)
		end
	end
end

local function RemoveAttributeVisual(_control, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth, _isNewTarget)
	if not IsControlAllowed(_control) then
		return
	end

	if _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		if AUI.UnitFrames.IsShield(_control.attributeId) then	
			if _unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and _statType == STAT_MITIGATION then						
				_control.data.shield.isActive = false
				UpdateData(_control, _powerValue, _powerMax, _smooth)	
			end
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_MAX_POWER and _statType == STAT_MITIGATION then
			UpdateData(_control, _powerValue, _powerMax, _smooth)			
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_MAX_POWER and _statType == STAT_MITIGATION then
			UpdateData(_control, _powerValue, _powerMax, _smooth)			
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT then
			_control.data.decreaseRegenData.value = 0	
			UpdateRegen(_control, _isNewTarget)		
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT  then
			_control.data.increaseRegenData.value = 0		
			UpdateRegen(_control, _isNewTarget)	
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_ARMOR_RATING then
			HideIncreaseArmorEffect(_control)		
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_ARMOR_RATING then
			HideDecreaseArmorEffect(_control)	
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_POWER then	
			HideIncreasePowerEffect(_control)				
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_POWER  then	
			HideDecreasePowerEffect(_control)														
		end
	end
end

local function UpdateAttributeVisual(_control, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth, _isNewTarget)
	if not IsControlAllowed(_control) then
		return
	end

	if _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		if AUI.UnitFrames.IsShield(_control.attributeId) then
			if _unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and _statType == STAT_MITIGATION then	
				if _powerValue and _powerValue > 0 then
					_control.data.shield.isActive = true	
				else
					_control.data.shield.isActive = false	
				end
			
				UpdateData(_control, _powerValue, _powerMax, _smooth)
			end
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_MAX_POWER and _statType == STAT_MITIGATION then
			UpdateData(_control, _powerValue, _powerMax, _smooth)		
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_MAX_POWER and _statType == STAT_MITIGATION then
			UpdateData(_control, _powerValue, _powerMax, _smooth)								
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT then	
			_control.data.decreaseRegenData.value = _powerValue	or 0			
			UpdateRegen(_control, _isNewTarget)	
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT then
			_control.data.increaseRegenData.value = _powerValue	or 0			
			UpdateRegen(_control, _isNewTarget)	
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_ARMOR_RATING then
			if _powerValue and _powerValue > 0 then
				ShowIncreaseArmorEffect(_control)
			else
				HideIncreaseArmorEffect(_control)												
			end		
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_ARMOR_RATING then	
			if _powerValue and _powerValue < 0 then
				ShowDecreaseArmorEffect(_control)
			else
				HideDecreaseArmorEffect(_control)
			end
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_POWER then	
			if _powerValue and _powerValue > 0 then
				ShowIncreasePowerEffect(_control)
			else
				HideIncreasePowerEffect(_control)												
			end	
		elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_POWER then	
			if _powerValue and _powerValue < 0 then
				ShowDecreasePowerEffect(_control)
			else
				HideDecreasePowerEffect(_control)												
			end				
		end	
	end
end


function AUI.UnitFrames.AddAttributeVisual(_unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, effectiveMaxValue, _smooth)
	if not gCurrentTemplateData then
		return
	end

	for _, templateData in pairs(gCurrentTemplateData) do
		for _, data in pairs(templateData.frameData) do
			if data.control then
				if data.control.frames then
					local frame = data.control.frames[_unitTag]
					if frame then
						if frame.unitTag == _unitTag and frame.powerType ==_powerType then
							AddAttributeVisual(frame, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth)
						end				
					end
				elseif data.control then
					if data.control.unitTag == _unitTag and data.control.powerType ==_powerType then
						AddAttributeVisual(data.control, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth)
					end
				end
			end
		end
	end
end

function AUI.UnitFrames.RemoveAttributeVisual(_unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, effectiveMaxValue, _smooth)
	if not gCurrentTemplateData then
		return
	end

	for _, templateData in pairs(gCurrentTemplateData) do
		for _, data in pairs(templateData.frameData) do
			if data.control then
				if data.control.frames then
					local frame = data.control.frames[_unitTag]
					if frame then
						if frame.unitTag == _unitTag and frame.powerType ==_powerType then
							RemoveAttributeVisual(frame, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth)
						end	
					end				
				elseif data.control then
					if data.control.unitTag == _unitTag and data.control.powerType ==_powerType then
						RemoveAttributeVisual(data.control, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth)
					end
				end
			end
		end	
	end
end

function AUI.UnitFrames.UpdateAttributeVisual(_unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, effectiveMaxValue, _smooth)
	if not gCurrentTemplateData then
		return
	end

	for _, templateData in pairs(gCurrentTemplateData) do
		for _, data in pairs(templateData.frameData) do
			if data.control.frames then
				local frame = data.control.frames[_unitTag]
				if frame then
					if frame.unitTag == _unitTag and frame.powerType ==_powerType then
						UpdateAttributeVisual(frame, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth)
					end		
				end				
			elseif data.control then
				if data.control.unitTag == _unitTag and data.control.powerType ==_powerType then
					UpdateAttributeVisual(data.control, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth)
				end
			end
		end
	end		
end

local function UpdateFrame(_control)
	local isUnitDead = IsUnitDead(_control.unitTag)
	local isUnitPlayer = IsUnitPlayer(_control.unitTag)	
	local isUnitOnline = IsUnitOnline(_control.unitTag)	

	if not AUI.UnitFrames.IsShield(_control.attributeId) then
		local isUnitChampion = IsUnitChampion(_control.unitTag)
		
		if isPreviewShowed then
			isUnitChampion = true
			caption = AUI.L10n.GetString("preview")
			isUnitDead = false
			isUnitOnline = true
		end		

		if _control.levelControl then
			local unitLevel = GetUnitLevel(_control.unitTag) 
		
			if isUnitOnline then
				if unitLevel == 0 then
					isUnitOnline = false
				end
			end

			if isUnitChampion then
				unitLevel = GetUnitChampionPoints(_control.unitTag)			
			end		
		
			if isPreviewShowed then
				unitLevel = 501
			end

			_control.levelControl:SetText(tostring(unitLevel))
			
			if unitLevel == 0 then
				_control.levelControl:SetHidden(true)
			else
				_control.levelControl:SetHidden(false)
			end
		end	
		
		if _control.championIconControl then
			if isUnitChampion then
				_control.championIconControl:SetHidden(false)
			else
				_control.championIconControl:SetHidden(true)
			end
		end		
			
		if _control.classIconControl then
			local classId = GetUnitClassId(_control.unitTag)
		
			if isPreviewShowed then
				classId = 1
			end
		
			local classIcon = GetClassIcon(classId)		
			if classIcon then
				local classColor = "#ffffff"
				if _control.classIconControl.color then
					classColor = AUI.Color.GetColor(_control.classIconControl.color)
				else
					classColor = AUI.Color.GetClassColor(classId)
				end
					
				if classColor then
					_control.classIconControl:SetColor(AUI.Color.ConvertHexToRGBA(classColor, _control.classIconControl.opacity or 1):UnpackRGBA())			
					_control.classIconControl:SetTexture(classIcon)
					_control.classIconControl:SetHidden(false)				
				end
			else
				_control.classIconControl:SetHidden(true)
			end	
		end				
		
		if _control.rankIconControl then
			local rank, subRank = GetUnitAvARank(_control.unitTag)
		
			if isPreviewShowed then
				rank = 3
			end
		
			if rank == 0 then
				_control.rankIconControl:SetHidden(true)
			else
				_control.rankIconControl:SetHidden(false)
				
				local rankIconFile = GetAvARankIcon(rank)
				_control.rankIconControl:SetTexture(rankIconFile)

				local alliance = GetUnitAlliance(_control.unitTag)
				_control.rankIconControl:SetColor(GetAllianceColor(alliance):UnpackRGBA())
			end		
		end	
		
		local unitName = GetUnitName(_control.unitTag)
		local unitDisplayName = GetUnitDisplayName(_control.unitTag)

		if _control.titleControl then
			local unitCaption = ""	
			if isUnitPlayer or isPreviewShowed then
				local unitTitle = ""
				
				if _control.settings.caption_mode == AUI_UNIT_FRAMES_MODE_TITLE or _control.settings.caption_mode == AUI_UNIT_FRAMES_MODE_CHARACTER_NAME_TITLE or _control.settings.caption_mode == AUI_UNIT_FRAMES_MODE_ACCOUNT_NAME_TITLE then
					if isPreviewShowed then
						unitTitle = AUI.L10n.GetString("title")														
					else
						unitTitle = GetUnitTitle(_control.unitTag)
					end
				end

				if _control.settings.caption_mode == AUI_UNIT_FRAMES_MODE_CHARACTER_NAME or _control.settings.caption_mode == AUI_UNIT_FRAMES_MODE_CHARACTER_NAME_TITLE then
					if isPreviewShowed then
						unitCaption = AUI.L10n.GetString("character_name")
					else
						unitCaption = unitName
					end
				elseif _control.settings.caption_mode == AUI_UNIT_FRAMES_MODE_ACCOUNT_NAME or _control.settings.caption_mode == AUI_UNIT_FRAMES_MODE_ACCOUNT_NAME_TITLE then
					if isPreviewShowed then
						unitCaption = "@" .. AUI.L10n.GetString("name")
					else
						unitCaption = unitDisplayName
					end
				end
				
				if not AUI.String.IsEmpty(unitCaption) and not AUI.String.IsEmpty(unitTitle) then
					unitCaption = unitCaption .. " - " .. unitTitle
				elseif not AUI.String.IsEmpty(unitCaption) then
					unitCaption = unitCaption
				elseif not AUI.String.IsEmpty(unitTitle) then
					unitCaption = unitTitle
				end
			else
				unitCaption = zo_strformat(SI_TOOLTIP_UNIT_CAPTION, GetUnitCaption(_control.unitTag))
			end	


			if not AUI.String.IsEmpty(unitCaption) then
				_control.titleControl:SetHidden(false)
				_control.titleControl:SetText(unitCaption)
			else
				_control.titleControl:SetHidden(true)
			end	
		end	
		
		if _control.unitNameControl then
			if isPreviewShowed then
				unitName = AUI.L10n.GetString("player") 
				
				if AUI.UnitFrames.IsTargetHealth(_control.attributeId) then
					if _control.settings.show_account_name then
						unitName = "@" .. AUI.L10n.GetString("name")
					else
						unitName = AUI.L10n.GetString("character_name")
					end
				elseif AUI.UnitFrames.IsGroupOrRaidHealth(_control.attributeId) then
					if _control.settings.show_account_name then
						unitName = "@" .. AUI.L10n.GetString("name")
					else
						unitName = AUI.L10n.GetString("character_name")
					end
				elseif AUI.UnitFrames.IsBossHealth(_control.attributeId) then
					unitName = AUI.L10n.GetString("boss")
				end
			else
				if isUnitPlayer then
					if _control.settings.show_account_name then
						unitName = unitDisplayName
					end
				end				
			end
			
			_control.unitNameControl:SetText(unitName)
		end

		if _control.offlineInfoControl then
			if isUnitPlayer and not isUnitOnline then
				_control.offlineInfoControl:SetHidden(false)						
			else
				_control.offlineInfoControl:SetHidden(true)			
			end
		end	
		
		if _control.bar then 
			if isUnitDead or isUnitPlayer and not isUnitOnline then
				_control.bar:SetHidden(true)
				
				if _control.bar2 then 				
					_control.bar2:SetHidden(true)
				end
			else
				if _control.settings.out_of_range_opacity then
					local isUnitInRange = IsUnitInGroupSupportRange(_control.unitTag)	
					if isPreviewShowed then
						isUnitInRange = true
					end
				
					if isUnitInRange then
						_control.bar:SetAlpha(1)
						
						if _control.bar2 then 
							_control.bar2:SetAlpha(1)
						end
					else
						_control.bar:SetAlpha(_control.settings.out_of_range_opacity)
						
						if _control.bar2 then 
							_control.bar2:SetAlpha(_control.settings.out_of_range_opacity)	
						end
					end
				end
				
				_control.bar:SetHidden(false)
				
				if _control.bar2  then 	
					if _control.settings.bar_alignment == BAR_ALIGNMENT_CENTER then
						_control.bar2:SetHidden(false)
					else
						_control.bar2:SetHidden(true)
					end
				end
			end	
		end
		
		if _control.deadInfoControl then
			if isUnitDead then
				_control.deadInfoControl:SetHidden(false)					
			else
				_control.deadInfoControl:SetHidden(true)			
			end
		end	
	else
		if _control.bar then 
			if isUnitDead or isUnitPlayer and not isUnitOnline then
				SetStatusBar(_control.bar, 0, 1, false)
				
				if _control.bar2 then 
					SetStatusBar(_control.bar2, 0, 1, false)
				end
			end		
		end			
	end

	if _control.textValueControl then
		if _control.settings.show_text then
			if isUnitPlayer and not isUnitOnline or isUnitDead then
				_control.textValueControl:SetHidden(true)
			else
				_control.textValueControl:SetHidden(false)
			end
		end
	end
	
	if _control.textMaxValueControl then
		if _control.settings.show_text then
			if isUnitPlayer and not isUnitOnline or isUnitDead then
				_control.textMaxValueControl:SetHidden(true)
			else
				_control.textMaxValueControl:SetHidden(false)
			end
		end
	end	
	
	if _control.textPercentControl then	
		if _control.settings.show_text then
			if isUnitPlayer and not isUnitOnline or isUnitDead then
				_control.textPercentControl:SetHidden(true)
			else
				_control.textPercentControl:SetHidden(false)
			end
		end
	end	
end

local function UpdateControl(_control, _isNewTarget)
	if not IsControlAllowed(_control) then
		return
	end	

	if AUI.UnitFrames.IsShield(_control.attributeId) then
		local shieldValue, shieldMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, _control.powerType)

		if isPreviewShowed then
			shieldValue = DEFAULT_PREVIEW_HP / 2.5
			shieldMax = DEFAULT_PREVIEW_HP
		end	

		UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, _control.powerType, shieldValue, shieldMax, false, _isNewTarget)		
	elseif AUI.UnitFrames.IsPlayer(_control.attributeId) or AUI.UnitFrames.IsTargetHealth(_control.attributeId) or AUI.UnitFrames.IsBossHealth(_control.attributeId) or AUI.UnitFrames.IsGroupOrRaidHealth(_control.attributeId) or AUI.UnitFrames.IsGroupOrRaidCompanion(_control.attributeId) or AUI.UnitFrames.IsMainCompanion(_control.attributeId) then
		if _control.attributeId == AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH or AUI.UnitFrames.IsTargetHealth(_control.attributeId) or AUI.UnitFrames.IsBossHealth(_control.attributeId) or AUI.UnitFrames.IsGroupOrRaidHealth(_control.attributeId) then
			local increaseHealthRegenValue, increaseHealthRegenMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, _control.powerType)
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, _control.powerType, increaseHealthRegenValue, increaseHealthRegenMax, increaseHealthRegenMax, false, _isNewTarget)
				
			local decreaseHealthRegenValue, decreaseHealthRegenMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, _control.powerType)		
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, _control.powerType, decreaseHealthRegenValue, decreaseHealthRegenMax, decreaseHealthRegenMax, false, _isNewTarget)		
			
			local increaseArmorValue, increaseArmorMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, _control.powerType)
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, _control.powerType, increaseArmorValue, increaseArmorMax, increaseArmorMax, false, _isNewTarget)			
			
			local decreaseArmorValue, decreaseArmorMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, _control.powerType)
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, _control.powerType, decreaseArmorValue, decreaseArmorMax, decreaseArmorMax, false, _isNewTarget)		

			local increasePowerValue, increasePowerVMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, _control.powerType)
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, _control.powerType, increasePowerValue, increasePowerVMax, increasePowerVMax, false, _isNewTarget)

			local decreasePowerValue, decreasePowerMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, _control.powerType)
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, _control.powerType, decreasePowerValue, decreasePowerMax, decreasePowerMax, false, _isNewTarget)		
		elseif _control.attributeId == AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA then
			local increaseMagickaRegenValue, increaseMagickaRegenMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, _control.powerType)
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, _control.powerType, increaseMagickaRegenValue, increaseMagickaRegenMax, increaseMagickaRegenMax, false, _isNewTarget)

			local decreaseMagickaRegenValue, decreaseMagickaRegenMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, _control.powerType)
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, _control.powerType, decreaseMagickaRegenValue, decreaseMagickaRegenMax, decreaseMagickaRegenMax, false, _isNewTarget)			
		elseif _control.attributeId == AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA then
			local increaseStaminaRegenValue, increaseStaminaRegenMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_STAMINA_REGEN_COMBAT, ATTRIBUTE_STAMINA, _control.powerType)
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_STAMINA_REGEN_COMBAT, ATTRIBUTE_STAMINA, _control.powerType, increaseStaminaRegenValue, increaseStaminaRegenMax, increaseStaminaRegenMax, false, _isNewTarget)			
		
			local decreaseStaminaRegenValue, decreaseStaminaRegenMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_STAMINA_REGEN_IDLE, ATTRIBUTE_STAMINA, _control.powerType)
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_STAMINA_REGEN_COMBAT, ATTRIBUTE_STAMINA, _control.powerType, decreaseStaminaRegenValue, decreaseStaminaRegenMax, decreaseStaminaRegenMax, false, _isNewTarget)
		end
			
		local currentValue, maxValue, effectiveMaxValue = GetUnitPower(_control.unitTag, _control.powerType)	
			
		if isPreviewShowed then
			currentValue = DEFAULT_PREVIEW_HP
			maxValue = DEFAULT_PREVIEW_HP
		end
				
		UpdateData(_control, currentValue, maxValue, false)				
	end	
	
	UpdateFrame(_control)
end

function AUI.UnitFrames.ResetControlData(_control)
	if not _control.data then
		_control.data = {}		
	end
	
	_control.data.currentValue = 0
	_control.data.maxValue = 0
	_control.data.regenValue = 0
	
	if not _control.data.increaseRegenData then
		_control.data.increaseRegenData = {}
	end
	
	_control.data.increaseRegenData.isActive = false
	_control.data.increaseRegenData.value = 0
				
	if not _control.data.decreaseRegenData then			
		_control.data.decreaseRegenData = {}
	end
	
	_control.data.decreaseRegenData.isActive = false
	_control.data.decreaseRegenData.value = 0
	
	if not _control.data.shield then	
		_control.data.shield = {}		
	end
	
	_control.data.shield.isActive = false	
	
	if not _control.data.increaseArmorEffect then
		_control.data.increaseArmorEffect = {}
		_control.data.increaseArmorEffect.isActive = false	
	end
	
	if not _control.data.decreaseArmorEffect then
		_control.data.decreaseArmorEffect = {}	
	end
	
	_control.data.decreaseArmorEffect.isActive = false		
	
	if not _control.data.increasePowerEffect then
		_control.data.increasePowerEffect = {}
	end
	
	_control.data.increasePowerEffect.isActive = false		
	
	if not _control.data.decreasePowerEffect then
		_control.data.decreasePowerEffect = {}
	end
	
	_control.data.decreasePowerEffect.isActive = false		
end

function AUI.UnitFrames.UpdateSingleBar(_unitTag, _powerType, _smooth, _currentValue, _maxValue, _effectiveMaxValue, _color)
	if not gCurrentTemplateData then
		return
	end

	if not _currentValue and not _maxValue then
		local currentValue, maxValue, effectiveMaxValue = GetUnitPower(_unitTag, _powerType)
		_currentValue = currentValue
		_maxValue = maxValue
	end
	
	if isPreviewShowed then
		_currentValue = DEFAULT_PREVIEW_HP
		_maxValue = DEFAULT_PREVIEW_HP
	end		

	for _, templateData in pairs(gCurrentTemplateData) do
		for _, data in pairs(templateData.frameData) do
			if data.control and not AUI.UnitFrames.IsShield(data.attributeId) then
				if data.control.frames then
					local frame = data.control.frames[_unitTag]
					if frame then
						if IsControlAllowed(frame) and frame.unitTag == _unitTag and frame.powerType ==_powerType then				
							UpdateData(frame, _currentValue, _maxValue, _smooth, _color)	
						end						
					end		
				elseif IsControlAllowed(data.control) and data.control.unitTag == _unitTag and data.control.powerType ==_powerType then				
					UpdateData(data.control, _currentValue, _maxValue, _smooth, _color)		
				end	
			end
		end
	end
end
	
function AUI.UnitFrames.OnPowerUpdate(_unitTag, _powerIndex, _powerType, _powerValue, _powerMax, _powerEffectiveMax)
	AUI.UnitFrames.UpdateSingleBar(_unitTag, _powerType, true, _powerValue, _powerMax, _powerEffectiveMax)
	if AUI.UnitFrames.Boss.IsEnabled() and AUI.Unit.IsBossUnitTag(_unitTag) then
		AUI.UnitFrames.Boss.UpdateText(_powerValue, _powerMax, _powerEffectiveMax)
	end
end
	
function AUI.UnitFrames.OnPlayerActivated()
	if not gIsLoaded then
		gIsLoaded = true
	
		if not gCurrentTemplateData then	
			gCurrentTemplateData = AUI.UnitFrames.LoadTemplate()
			AUI.UnitFrames.LoadSettings()
		end
		
		if AUI.UnitFrames.Player.IsEnabled() then
			AUI.UnitFrames.Player.Load()			
		end	
		
		if AUI.UnitFrames.Target.IsEnabled() then
			AUI.UnitFrames.Target.Load()
		end	
		
		if AUI.UnitFrames.Group.IsEnabled() then
			AUI.UnitFrames.Group.Load()
		end				
		
		if AUI.UnitFrames.Boss.IsEnabled() then
			AUI.UnitFrames.Boss.Load()
		end		
	end
	
	AUI.UnitFrames.UpdateUI()
	
	if AUI.UnitFrames.Target.IsEnabled() then
		AUI.UnitFrames.Target.OnChanged()
	end
end	
	

function AUI.UnitFrames.UpdateUI()
	if not gCurrentTemplateData then
		return
	end

	 for _, templateData in pairs(gCurrentTemplateData) do
		for frameType, data in pairs(templateData.frameData) do
			if data.control then
				if data.control.frames then							
					for _, frame in pairs(data.control.frames) do
						if IsControlAllowed(frame) then
							SetLayout(frame)	
						end
					end				
				else
					if IsControlAllowed(data.control) then	
						SetLayout(data.control)						
					end
				end
			end
		end
	 end
	
	if AUI.Settings.UnitFrames.boss_game_default_frame_show_text then
		AUI_BossBarOverlay_Text:SetHidden(false)
	else
		AUI_BossBarOverlay_Text:SetHidden(true)
	end
			
	AUI_BossBarOverlay_Text:SetFont(AUI.Settings.UnitFrames.boss_game_default_frame_font_art .. "|" .. AUI.Settings.UnitFrames.boss_game_default_frame_font_size .. "|" .. "outline")	
	
	AUI.UnitFrames.Group.UpdateUI()
	AUI.UnitFrames.Boss.UpdateUI()
	
	AUI.UnitFrames.Update()	
end

function AUI.UnitFrames.Update(_unitTag, _isNewTarget)
	if not gCurrentTemplateData then
		return
	end

	for _, templateData in pairs(gCurrentTemplateData) do
		for _, data in pairs(templateData.frameData) do
			if data.control then
				if data.control.frames then
					if _unitTag then
						local frame = data.control.frames[_unitTag]
						if frame then
							UpdateControl(frame)
						end
					else			
						for _, frame in pairs(data.control.frames) do
							UpdateControl(frame)			
						end
					end
				else
					if not _unitTag or data.control.unitTag == _unitTag then
						if DoesUnitExist(data.control.unitTag) or isPreviewShowed then
							UpdateControl(data.control, _isNewTarget)
						else
							UpdateControlVisibility(data.control)
						end
					end
				end
			end
		end
	end	
end

function AUI.UnitFrames.ShowFrame(_attributeId)
	if not gCurrentTemplateData then
		return
	end

	for _, templateData in pairs(gCurrentTemplateData) do
		for id, data in pairs(templateData.frameData) do
			if data.control and id == _attributeId then	
				if IsControlAllowed(data.control) then
					if data.control.frames then
						for _, frame in pairs(data.control.frames) do
							AUI.Fade.In(frame, 0, 0, 0, frame.settings.opacity)
						end							
					else
						if AUI.UnitFrames.IsShield(_attributeId) then
							if data.control.data.shield.isActive then
								AUI.Fade.In(data.control, 0, 0, 0, data.control.settings.opacity)
							end
						else
							AUI.Fade.In(data.control, 0, 0, 0, data.control.settings.opacity)
						end
					end
				end

				break
			end
		end
	end
end	

function AUI.UnitFrames.HideFrame(_attributeId)
	if not gCurrentTemplateData then
		return
	end

	for _, templateData in pairs(gCurrentTemplateData) do
		for id, data in pairs(templateData.frameData) do
			if data.control and id == _attributeId then
				if data.control.frames then
					for _, frame in pairs(data.control.frames) do
						AUI.Fade.Out(frame)
					end
				else		
					AUI.Fade.Out(data.control)		
				end
				
				break
			end
		end
	end
end	

function AUI.UnitFrames.IsPreviewShow()
	return isPreviewShowed		
end

function AUI.UnitFrames.ShowPreview()		
	UNIT_FRAMES_SCENE_FRAGMENT.hiddenReasons:SetHiddenForReason("ShouldntShow", true)
	AUI_Attributes_Window:SetHidden(false) 	

	if AUI.Settings.UnitFrames.group_unit_frames_enabled then
		local previewGroupSize = 4
		
		if AUI.UnitFrames.Group.IsRaid() then
			previewGroupSize = 24
		end
		
		AUI.UnitFrames.Group.SetPreviewGroupSize(previewGroupSize)
	end
	
	if AUI.Settings.UnitFrames.boss_unit_frames_enabled then
		AUI.UnitFrames.Boss.ShowPreview()
	end		
	
	isPreviewShowed = true
	
	for _, templateData in pairs(gCurrentTemplateData) do
		for _, data in pairs(templateData.frameData) do
			if data.control and AUI.Settings.UnitFrames.group_unit_frames_enabled and AUI.UnitFrames.IsGroup(data.control.attributeId) then
				AUI.UnitFrames.ShowFrame(data.control.attributeId)
			end
		end
	end
	
	AUI.UnitFrames.UpdateUI()
end

function AUI.UnitFrames.HidePreview()	
	isPreviewShowed = false

	UNIT_FRAMES_SCENE_FRAGMENT.hiddenReasons:SetHiddenForReason("ShouldntShow", false)		
	
	AUI.UnitFrames.Group.SetPreviewGroupSize(0)
	AUI.UnitFrames.UpdateUI()
	AUI.UnitFrames.Target.OnChanged()
	AUI.UnitFrames.Boss.HidePreview()
end

function AUI.UnitFrames.OnReticleTargetChanged()
	if AUI.UnitFrames.Target.IsEnabled() then
		AUI.UnitFrames.Target.OnChanged()
	end
end

function AUI.UnitFrames.Load()
	if gIsLoaded then
		return
	end	
	
	CreateControlFromVirtual("AUI_BossBarOverlay", ZO_BossBarHealth, "AUI_BossBarOverlay")	
	
	UNIT_FRAMES_SCENE_FRAGMENT = ZO_SimpleSceneFragment:New(AUI_Attributes_Window)	
	UNIT_FRAMES_SCENE_FRAGMENT.hiddenReasons = ZO_HiddenReasons:New()		
    UNIT_FRAMES_SCENE_FRAGMENT:SetConditional(function()
        return not UNIT_FRAMES_SCENE_FRAGMENT.hiddenReasons:IsHidden()
    end)				
	
	HUD_SCENE:AddFragment(UNIT_FRAMES_SCENE_FRAGMENT)
	HUD_UI_SCENE:AddFragment(UNIT_FRAMES_SCENE_FRAGMENT)
	SIEGE_BAR_SCENE:AddFragment(UNIT_FRAMES_SCENE_FRAGMENT)
	if SIEGE_BAR_UI_SCENE then
		SIEGE_BAR_UI_SCENE:AddFragment(UNIT_FRAMES_SCENE_FRAGMENT)
	end
end

function AUI.UnitFrames.Player.IsEnabled()
	return AUI.UnitFrames.IsEnabled() and AUI.Settings.UnitFrames.player_unit_frames_enabled
end

function AUI.UnitFrames.Target.IsEnabled()
	return AUI.UnitFrames.IsEnabled() and AUI.Settings.UnitFrames.target_unit_frames_enabled
end

function AUI.UnitFrames.Group.IsEnabled()
	return AUI.UnitFrames.IsEnabled() and AUI.Settings.UnitFrames.group_unit_frames_enabled
end

function AUI.UnitFrames.Raid.IsEnabled()
	return AUI.UnitFrames.IsEnabled() and AUI.Settings.UnitFrames.group_unit_frames_enabled
end

function AUI.UnitFrames.Boss.IsEnabled()
	return AUI.UnitFrames.IsEnabled() and AUI.Settings.UnitFrames.boss_unit_frames_enabled
end

function AUI.UnitFrames.Companion.IsEnabled()
	return AUI.UnitFrames.IsEnabled() and AUI.Settings.UnitFrames.companion_unit_frames_enabled
end