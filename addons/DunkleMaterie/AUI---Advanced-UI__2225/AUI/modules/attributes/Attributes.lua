local LMP = LibStub("LibMediaProvider-1.0")
local isLoaded = false
local currentTemplate = nil

AUI.Attributes = {}
AUI.Attributes.Player = {}
AUI.Attributes.Target = {}
AUI.Attributes.Group = {}
AUI.Attributes.Bossbar = {}

AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH = 101
AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA = 102
AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA = 103
AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT = 104
AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF = 105
AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE = 106
AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD = 107
AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH = 201
AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_SHIELD = 202
AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH = 211
AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_SHIELD = 212
AUI_ATTRIBUTE_TYPE_GROUP_HEALTH = 301
AUI_ATTRIBUTE_TYPE_GROUP_SHIELD = 302
AUI_ATTRIBUTE_TYPE_RAID_HEALTH = 401
AUI_ATTRIBUTE_TYPE_RAID_SHIELD = 402
AUI_ATTRIBUTE_TYPE_BOSS_HEALTH = 501
AUI_ATTRIBUTE_TYPE_BOSS_SHIELD = 502

local shieldAttributeIds = {
	[AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD] = true,
	[AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_SHIELD] = true,
	[AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_SHIELD] = true,
	[AUI_ATTRIBUTE_TYPE_GROUP_SHIELD] = true,
	[AUI_ATTRIBUTE_TYPE_RAID_SHIELD] = true,
	[AUI_ATTRIBUTE_TYPE_BOSS_SHIELD] = true,
}

local playerAttributeIds = {
	[AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH] = true,
	[AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA] = true,
	[AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA] = true,
	[AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT] = true,
	[AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF] = true,
	[AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE] = true,
	[AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD] = true,
}

local playerMainAttributesIds = {
	[AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH] = true,
	[AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA] = true,
	[AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA] = true,
}


local targetAttributeIds = {
	[AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH] = true,
	[AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_SHIELD] = true,
	[AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH] = true,
	[AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_SHIELD] = true,	
}

local targetAttributeHealthIds = {
	[AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH] = true,
	[AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH] = true,
}

local groupHealthAttributeIds = {
	[AUI_ATTRIBUTE_TYPE_GROUP_HEALTH] = true,
	[AUI_ATTRIBUTE_TYPE_RAID_HEALTH] = true,
}

local groupAttributeIds = {
	[AUI_ATTRIBUTE_TYPE_GROUP_HEALTH] = true,
	[AUI_ATTRIBUTE_TYPE_GROUP_SHIELD] = true,
	[AUI_ATTRIBUTE_TYPE_RAID_HEALTH] = true,
	[AUI_ATTRIBUTE_TYPE_RAID_SHIELD] = true,	
}

local bossHealthAttributeIds = {
	[AUI_ATTRIBUTE_TYPE_BOSS_HEALTH] = true,
}

local bossAttributeIds = {
	[AUI_ATTRIBUTE_TYPE_BOSS_HEALTH] = true,
	[AUI_ATTRIBUTE_TYPE_BOSS_SHIELD] = true,
}

ATTRIBUTES_SCENE_FRAGMENT = nil

local isPreviewShowed = false

local function IsControlAllowed(_control)
	if _control and _control.enabled and _control.settings and _control.settings.display and not _control.frames then
		return true
	end
	
	return false
end

local function GetControlFromAttributeId(_attributeId)	
	local data = currentTemplate.attributeData
	if data then
		return data[_attributeId].control
	end
	
	return nil
end

function AUI.Attributes.IsShield(_attributeId)
	if shieldAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.Attributes.IsPlayer(_attributeId)
	if playerAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.Attributes.IsPlayer(_attributeId)
	if playerAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.Attributes.IsTargetHealth(_attributeId)
	if targetAttributeHealthIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.Attributes.IsTarget(_attributeId)
	if targetAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.Attributes.IsGroupHealth(_attributeId)
	if groupHealthAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.Attributes.IsGroup(_attributeId)
	if groupAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.Attributes.IsBossHealth(_attributeId)
	if bossHealthAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.Attributes.IsBoss(_attributeId)
	if bossAttributeIds[_attributeId] then
		return true
	end
	
	return false
end

function AUI.Attributes.IsPlayerMainAttribute(_attributeId)
	if playerMainAttributesIds[_attributeId] then
		return true
	end
	
	return false
end

local function GetSettingValue(_type, _value)
	if AUI.Settings.Attributes[currentTemplate.internName] then
		if AUI.Settings.Attributes[currentTemplate.internName][_type] then		
			return AUI.Settings.Attributes[currentTemplate.internName][_type][_value]
		end
	end
	
	return nil
end

local function OnFrameMouseDown(_button, _ctrl, _alt, _shift, _frame)
	local control = nil	
	for type, data in pairs(currentTemplate.attributeData) do
		if type == _frame.attributeId then
			control = data.control
		end		
	end

	if _button == 1 and control and not AUI.Settings.Attributes.lock_windows then
		control:SetMovable(true)
		control:StartMoving()
	end
end

local function OnFrameMouseUp(_button, _ctrl, _alt, _shift, _frame)	
	local control = nil	
	for type, data in pairs(currentTemplate.attributeData) do
		if type == _frame.attributeId then
			control = data.control
		end		
	end	
	
	if control and _button == 1 then
		control:SetMovable(false)

		local anchorData = GetSettingValue(control.attributeId, "anchor_data")
		if not AUI.Settings.Attributes.lock_windows and anchorData then
			_, anchorData[0].point, _, anchorData[0].relativePoint, anchorData[0].offsetX, anchorData[0].offsetY = control:GetAnchor(0)		
			_, anchorData[1].point, _, anchorData[1].relativePoint, anchorData[1].offsetX, anchorData[1].offsetY = control:GetAnchor(1)				
		end
	end

	AUI.Attributes.Group.OnFrameMouseUp(_button, _ctrl, _alt, _shift, _frame)
end	

local function IsFadeInAllowed(_control)
	if _control.isVisibilityControlled then
		return true
	end

	if isPreviewShowed then
		return true
	end
	
	if AUI.Attributes.IsGroupHealth(_control.attributeId) then
		if IsUnitGrouped(_control.unitTag) then
			return true
		end	
	elseif AUI.Attributes.IsBossHealth(_control.attributeId) then
		if DoesUnitExist(_control.unitTag) and not IsUnitDead(_control.unitTag) then
			return true
		end
	elseif not IsUnitDead(_control.unitTag) then
		if AUI.Attributes.IsPlayerMainAttribute(_control.attributeId) then	
			if AUI.Settings.Attributes[currentTemplate.internName].show_player_always or (_control.data.increaseRegenData.isActive and _control.data.increaseRegenData.isChanged or _control.data.decreaseRegenData.isActive and _control.data.decreaseRegenData.isChanged or _control.data.currentValue ~= _control.data.maxValue) then
				return true
			end
		elseif AUI.Attributes.IsShield(_control.attributeId) then
			if _control.data.shield.isActive then
				return true
			end			
		elseif _control.attributeId == AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT then
			if IsMounted() and _control.data.currentValue ~= _control.data.maxValue then
				return true
			end
		elseif _control.attributeId == AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF then
			if IsWerewolf() and _control.data.currentValue > 0 then
				return true
			end
		elseif _control.attributeId == AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE then
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
	
	if isPreviewShowed or AUI.Attributes.IsTargetHealth(_control.attributeId) then
		return false
	end		

	if AUI.Attributes.IsShield(_control.attributeId) then	
		if _control.data.shield.isActive then	
			return false
		end
	elseif AUI.Attributes.IsGroupHealth(_control.attributeId) then
		if not IsUnitGrouped(_control.unitTag) then
			return true
		end	
	elseif AUI.Attributes.IsBossHealth(_control.attributeId) then
		if not DoesUnitExist(_control.unitTag) then
			return true
		end
	elseif IsUnitDead(_control.unitTag) then
		return true	
	else		
		local isPlayerMainAttribute = AUI.Attributes.IsPlayerMainAttribute(_control.attributeId)
		if isPlayerMainAttribute and AUI.Settings.Attributes[currentTemplate.internName].show_player_always then
			return false
		end		
			
		if AUI.Attributes.IsShield(_control.attributeId) then
			if _control.data.currentValue and _control.data.currentValue > 0 and _control.data.shield.isActive then
				return false
			end	
		end	
	end
	
	return true
end

local function UpdateControlVisibility(_control)
	if IsFadeInAllowed(_control) then
		AUI.Fade.In(_control, 300, 0, 0, _control.settings.opacity)
		if _control.dependentControl and not (AUI.Attributes.IsPlayerMainAttribute(_control.dependentControl.attributeId) and AUI.Settings.Attributes[currentTemplate.internName].show_player_always) then
			_control.dependentControl.isVisibilityControlled = true
			AUI.Fade.In(_control.dependentControl, 0, 0, 0, _control.dependentControl.settings.opacity)		
		end
	elseif IsFadeOutAllowed(_control) then	
		local duration = 300
		local delay = 0
		local isUnitDead = IsUnitDead(_control.unitTag)
		local isUnitOnline = IsUnitOnline(_control.unitTag)
			
		if not isUnitDead and isUnitOnline then
			if _control.attributeId == AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT then			
				delay = 800
			elseif not AUI.Attributes.IsShield(_control.attributeId) then
				delay = 800
			end
		end	
		
		AUI.Fade.Out(_control, duration, delay, _control.settings.opacity)	
		if _control.dependentControl and not (AUI.Attributes.IsPlayerMainAttribute(_control.dependentControl.attributeId) and AUI.Settings.Attributes[currentTemplate.internName].show_player_always) then
			AUI.Fade.Out(_control.dependentControl, duration, delay, _control.dependentControl.settings.opacity)
			_control.dependentControl.isVisibilityControlled = false
		end		
	end	
end

local function UpdateAttribute(_control)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("UpdateAttribute | " .. _control:GetName())
	end
	--/DebugMessage--

	if not _control or not _control.settings or not _control.data.currentValue or not _control.data.maxValue then
		return
	end

	if _control.textValueControl then
		local text = _control.textValueControl:GetText()
		if not _control.textValueControl.text and not AUI.String.IsEmpty(text) then
			_control.textValueControl.text = text
		end
		
		local value = AUI.Math.Round(_control.data.currentValue)
		if _control.settings.useThousandSeperator then
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
		if _control.settings.useThousandSeperator then
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

local function GetDataFromAttributeId(_type)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.GetDataFromAttributeId | " .. _type)
	end
	--/DebugMessage--

	local data = {}
	
	data.defaultColor =  AUI.Color.GetColorDef(GetSettingValue(_type, "bar_color"))		
	data.increaseRegenColor = AUI.Color.GetColorDef(GetSettingValue(_type, "increase_regen_color"))
	data.decreaseRegenColor = AUI.Color.GetColorDef(GetSettingValue(_type, "decrease_regen_color"))
	
	data.display = GetSettingValue(_type, "display")
	data.width = GetSettingValue(_type, "width")
	data.height = GetSettingValue(_type, "height")	
	data.opacity = GetSettingValue(_type, "opacity")	
	data.outOfRangeOpacity = GetSettingValue(_type, "out_of_range_opacity")	
	data.showPercent = GetSettingValue(_type, "show_percent")	
	data.showAccountName = GetSettingValue(_type, "show_account_name")	
	data.showText = GetSettingValue(_type, "show_text")	
	data.showMaxValue = GetSettingValue(_type, "show_max_value")		
	data.useThousandSeperator = GetSettingValue(_type, "use_thousand_seperator")
	data.showIncreaseRegenColor = GetSettingValue(_type, "show_increase_regen_color")
	data.showDecreaseRegenColor = GetSettingValue(_type, "show_decrease_regen_color")	
	data.fontArt = GetSettingValue(_type, "font_art")
	data.fontSize = GetSettingValue(_type, "font_size")
	data.fontStyle = GetSettingValue(_type, "font_style")
	data.rowDistance = GetSettingValue(_type, "row_distance")
	data.columnDistance = GetSettingValue(_type, "column_distance")	
	data.rowCount = GetSettingValue(_type, "row_count")		
	
	return data
end

local function GetBarColor(_type, _unitTag)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.GetBarColor | " .. _type .. " | " .. _unitTag)
	end
	--/DebugMessage--

	local color = AUI.Settings.Attributes[currentTemplate.internName][_type].bar_color

	if AUI.Attributes.IsTargetHealth(_type) then
		if _isGuard or IsUnitInvulnerableGuard(_unitTag) then
			color = AUI.Settings.Attributes[currentTemplate.internName][_type].bar_guard_color
		else
			local unitReaction = _unitReaction or GetUnitReaction(_unitTag) 
			if unitReaction == UNIT_REACTION_FRIENDLY then
				color = AUI.Settings.Attributes[currentTemplate.internName][_type].bar_friendly_color
			elseif unitReaction == UNIT_REACTION_NEUTRAL then
				color = AUI.Settings.Attributes[currentTemplate.internName][_type].bar_neutral_color	
			elseif unitReaction == UNIT_REACTION_NPC_ALLY then	
				color = AUI.Settings.Attributes[currentTemplate.internName][_type].bar_allied_npc_color
			elseif unitReaction == UNIT_REACTION_PLAYER_ALLY then
				color = AUI.Settings.Attributes[currentTemplate.internName][_type].bar_allied_player_color
			end
		end
	end	
	
	return AUI.Color.GetColorDef(color)
end

local function SetGradientColor(_bar, colorList)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.SetGradientColor | " .. _bar:GetName())
	end
	--/DebugMessage--

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
	local barColor = nil
	if _control.settings.showIncreaseRegenColor and _control.data.increaseRegenData.isActive then
		barColor = AUI.Color.GetColor(_control.settings.increaseRegenColor)
	elseif _control.settings.showDecreaseRegenColor and _control.data.decreaseRegenData.isActive then
		barColor = AUI.Color.GetColor(_control.settings.decreaseRegenColor)
	else	
		if AUI.Attributes.IsTargetHealth(_control.attributeId) then
			barColor = GetBarColor(_control.attributeId, _control.unitTag)
		else
			barColor = AUI.Color.GetColor(_control.settings.barColor)
		end
	end

	if _color then
		barColor = _color
	end

	if barColor then
		--DebugMessage--
		if AUI_DEBUG then
			AUI.DebugMessage("AUI.Attributes.UpdateBarColor | " .. _control:GetName())
		end
		--/DebugMessage--	
	
		if barColor[1] and barColor[2] then
			SetGradientColor(_bar, barColor)
		elseif barColor[1] then
			_bar:SetColor(barColor[1]:UnpackRGBA())
		end	
	end
end

local function SetLayout(_control)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.SetLayout | " .. _control:GetName())
	end
	--/DebugMessage--

	if _control.levelControl then
		local fontSizeMultipler = _control.unitNameControl.fontSizeMultipler or 1 
		local font = _control.settings.fontArt
		
		if _control.levelControl.font then
			font = _control.levelControl.font
		end
	
		_control.levelControl:SetFont(LMP:Fetch('font', font) .. "|" .. _control.settings.fontSize * fontSizeMultipler .. "|" .. _control.settings.fontStyle)
	end
													
	if _control.unitNameControl then
		local fontSizeMultipler = _control.unitNameControl.fontSizeMultipler or 1 
		local font = _control.settings.fontArt
		
		if _control.unitNameControl.font then
			font = _control.unitNameControl.font
		end	
		
		_control.unitNameControl:SetFont(LMP:Fetch('font', font) .. "|" .. _control.settings.fontSize * fontSizeMultipler .. "|" .. _control.settings.fontStyle)
	end					
	
	if _control.offlineInfoControl then
		local fontSizeMultipler = _control.offlineInfoControl.fontSizeMultipler or 1 
		local font = _control.settings.fontArt
		
		if _control.offlineInfoControl.font then
			font = _control.offlineInfoControl.font
		end		
	
		_control.offlineInfoControl:SetFont(LMP:Fetch('font', font) .. "|" .. _control.settings.fontSize * fontSizeMultipler.. "|" .. _control.settings.fontStyle)
		_control.offlineInfoControl:SetText(AUI.L10n.GetString("offline"))
	end	
		
	if _control.deadInfoControl then
		local fontSizeMultipler = _control.deadInfoControl.fontSizeMultipler or 1 
		local font = _control.settings.fontArt
		
		if _control.deadInfoControl.font then
			font = _control.deadInfoControl.font
		end		
	
		_control.deadInfoControl:SetFont(LMP:Fetch('font', font) .. "|" .. _control.settings.fontSize * fontSizeMultipler.. "|" .. _control.settings.fontStyle)
		_control.deadInfoControl:SetText(AUI.L10n.GetString("dead"))				
	end			
					
	if _control.textValueControl then
		local fontSizeMultipler = _control.textValueControl.fontSizeMultipler or 1 
		local font = _control.settings.fontArt
		
		if _control.textValueControl.font then
			font = _control.textValueControl.font
		end		
	
		_control.textValueControl:SetFont(LMP:Fetch('font', font) .. "|" .. _control.settings.fontSize * fontSizeMultipler.. "|" .. _control.settings.fontStyle)
		if _control.settings.showText then
			_control.textValueControl:SetHidden(false)
		else
			_control.textValueControl:SetHidden(true)
		end						
	end

	if _control.textMaxValueControl then
		local fontSizeMultipler = _control.textMaxValueControl.fontSizeMultipler or 1 
		local font = _control.settings.fontArt
		
		if _control.textMaxValueControl.font then
			font = _control.textMaxValueControl.font
		end		
	
		_control.textMaxValueControl:SetFont(LMP:Fetch('font', font) .. "|" .. _control.settings.fontSize * fontSizeMultipler.. "|" .. _control.settings.fontStyle)
		if _control.settings.showText and _control.settings.showMaxValue then
			_control.textMaxValueControl:SetHidden(false)
			_control.textMaxValueControl:SetDimensions(0, 0)
		else
			_control.textMaxValueControl:SetHidden(true)
			_control.textMaxValueControl:SetDimensions(1, 1)
		end			
	end	
		
	if _control.textPercentControl then
		local fontSizeMultipler = _control.textPercentControl.fontSizeMultipler or 1 
		local font = _control.settings.fontArt
		
		if _control.textPercentControl.font then
			font = _control.textPercentControl.font
		end		
	
		_control.textPercentControl:SetFont(LMP:Fetch('font', font) .. "|" .. _control.settings.fontSize * fontSizeMultipler.. "|" .. _control.settings.fontStyle)
		if _control.settings.showText then
			_control.textPercentControl:SetHidden(false)
		else
			_control.textPercentControl:SetHidden(true)
		end			
	end				

	if _control.championIconControl and _control.championIconControl.scaleToFont then
		_control.championIconControl:SetDimensions(_control.settings.fontSize + 4, _control.settings.fontSize + 4)
	end

	if _control.classIconControl and _control.classIconControl.scaleToFont then
		_control.classIconControl:SetDimensions(_control.settings.fontSize + 8, _control.settings.fontSize + 8)
	end

	if _control.leaderIconControl and _control.leaderIconControl.scaleToFont then
		_control.leaderIconControl:SetDimensions(_control.settings.fontSize + 10, _control.settings.fontSize + 10)
	end	
	
	if _control.rankIconControl and _control.rankIconControl.scaleToFont then
		_control.rankIconControl:SetDimensions(_control.settings.fontSize + 10, _control.settings.fontSize + 10)
	end		
	
	_control.settings.barColor = GetBarColor(_control.attributeId, _control.unitTag)

	local barColor = AUI.Color.GetColor(_control.settings.barColor)
	
	if barColor then	
		if _control.barLeft and _control.barRight then
			UpdateBarColor(_control, _control.barLeft, barColor)
			UpdateBarColor(_control, _control.barRight, barColor)		
		elseif _control.bar then
			UpdateBarColor(_control, _control.bar, barColor)			
		end
	end		

	if _control.settings.width and _control.settings.height then
		_control:SetDimensions(_control.settings.width, _control.settings.height)	
	end
	
	local relativeMoveControl = nil
	if _control.relativeMoveControl then
		relativeMoveControl = GetControlFromAttributeId(_control.relativeMoveControl)
	end	
		
	if _control.parent then
		_control.parentControl = GetControlFromAttributeId(_control.parent)
		_control:SetParent(_control.parentControl)
	end		

	if _control.dependent then
		_control.dependentControl = GetControlFromAttributeId(_control.dependent)
	end		

	_control:SetHandler("OnMouseDown", function(_eventCode, _button, _ctrl, _alt, shift) OnFrameMouseDown(_button, _ctrl, _alt, _shift, relativeMoveControl or _control) end)
	_control:SetHandler("OnMouseUp", function(_eventCode, _button, _ctrl, _alt, shift) OnFrameMouseUp(_button, _ctrl, _alt, _shift, relativeMoveControl or _control) end)	
	
	local barColor = AUI.Color.GetColor(_control.settings.barColor)
		
	if _control.warnerControl then
		if barColor and _control.warnerControl:GetType() == CT_TEXTURE then
			if barColor[1] then
				_control.warnerControl:SetColor(barColor[1]:UnpackRGBA())
			end	
		end
		
		_control.warnerControl:SetHidden(true)
	end		

	if _control.leftWarnerControl then
		if barColor then
			if barColor[1] then
				_control.leftWarnerControl:SetColor(barColor[1]:UnpackRGBA())
			end	
		end
	end
		
	if _control.rightWarnerControl then
		if barColor then
			if barColor[1] then
				_control.rightWarnerControl:SetColor(barColor[1]:UnpackRGBA())
			end	
		end
	end
		
	if _control.centerWarnerControl then
		if barColor then
			if barColor[1] then
				_control.centerWarnerControl:SetColor(barColor[1]:UnpackRGBA())
			end	
		end
	end

	if _control.bar then
		if _control.bar.increaseRegLeftControl then
			local startX = _control.bar.increaseRegLeftControl.startX or 0			
			local endX = _control.bar.increaseRegLeftControl.endX or 0
			local startY = _control.bar.increaseRegLeftControl.startY or 0
			local endY = _control.bar.increaseRegLeftControl.endY or 0			
			local duration = _control.bar.increaseRegLeftControl.duration or 800	
		
			_control.bar.increaseRegLeftAnim:GetFirstAnimation():SetStartOffsetX(startX)
			_control.bar.increaseRegLeftAnim:GetFirstAnimation():SetEndOffsetX((_control.bar:GetWidth()  + endX))		
			_control.bar.increaseRegLeftAnim:GetFirstAnimation():SetStartOffsetY(startY)
			_control.bar.increaseRegLeftAnim:GetFirstAnimation():SetEndOffsetY(endY)
			_control.bar.increaseRegLeftAnim:GetFirstAnimation():SetDuration(duration)
			_control.bar.increaseRegLeftAnim:GetAnimation(2):SetDuration(duration / 2)
			_control.bar.increaseRegLeftAnim:GetAnimation(3):SetDuration(duration / 2)			
			_control.bar.increaseRegLeftAnim:SetAnimationOffset(_control.bar.increaseRegLeftAnim:GetAnimation(3), duration / 2)
		end		

		if _control.bar.increaseRegRightControl then
			local startX = _control.bar.increaseRegRightControl.startX or 0			
			local endX = _control.bar.increaseRegRightControl.endX or 0
			local startY = _control.bar.increaseRegRightControl.startY or 0
			local endY = _control.bar.increaseRegRightControl.endY or 0			
			local duration = _control.bar.increaseRegRightControl.duration or 800
		
			_control.bar.increaseRegRightAnim:GetFirstAnimation():SetStartOffsetX(startX)
			_control.bar.increaseRegRightAnim:GetFirstAnimation():SetEndOffsetX(-(_control.bar:GetWidth() + endX))
			_control.bar.increaseRegRightAnim:GetFirstAnimation():SetStartOffsetY(startY)
			_control.bar.increaseRegRightAnim:GetFirstAnimation():SetEndOffsetY(endY)
			_control.bar.increaseRegRightAnim:GetFirstAnimation():SetDuration(duration)
			_control.bar.increaseRegRightAnim:GetAnimation(2):SetDuration(duration / 2)
			_control.bar.increaseRegRightAnim:GetAnimation(3):SetDuration(duration / 2)			
			_control.bar.increaseRegRightAnim:SetAnimationOffset(_control.bar.increaseRegRightAnim:GetAnimation(3), duration / 2)				
		end	

		if _control.bar.decreaseRegLeftControl then
			local startX = _control.bar.decreaseRegLeftControl.startX or 0			
			local endX = _control.bar.decreaseRegLeftControl.endX or 0
			local startY = _control.bar.decreaseRegLeftControl.startY or 0
			local endY = _control.bar.decreaseRegLeftControl.endY or 0				
			local duration = _control.bar.decreaseRegLeftControl.duration or 800
			
			_control.bar.decreaseRegLeftAnim:GetFirstAnimation():SetStartOffsetX(startX)
			_control.bar.decreaseRegLeftAnim:GetFirstAnimation():SetEndOffsetX(-(_control.bar:GetWidth() + endX))	
			_control.bar.decreaseRegLeftAnim:GetFirstAnimation():SetStartOffsetY(startY)
			_control.bar.decreaseRegLeftAnim:GetFirstAnimation():SetEndOffsetY(endY)
			_control.bar.decreaseRegLeftAnim:GetFirstAnimation():SetDuration(duration)
			_control.bar.decreaseRegLeftAnim:GetAnimation(2):SetDuration(duration / 2)
			_control.bar.decreaseRegLeftAnim:GetAnimation(3):SetDuration(duration / 2)			
			_control.bar.decreaseRegLeftAnim:SetAnimationOffset(_control.bar.decreaseRegLeftAnim:GetAnimation(3), duration / 2)					
		end		

		if _control.bar.decreaseRegRightControl then
			local startX = _control.bar.decreaseRegRightControl.startX or 0			
			local endX = _control.bar.decreaseRegRightControl.endX or 0
			local startY = _control.bar.decreaseRegRightControl.startY or 0
			local endY = _control.bar.decreaseRegRightControl.endY or 0			
			local duration = _control.barLeft.increaseRegLeftControl.duration or 800

			_control.bar.decreaseRegRightAnim:GetFirstAnimation():SetStartOffsetX(startX)
			_control.bar.decreaseRegRightAnim:GetFirstAnimation():SetEndOffsetX((_control.bar:GetWidth() + endX))	
			_control.bar.decreaseRegRightAnim:GetFirstAnimation():SetStartOffsetY(startY)
			_control.bar.decreaseRegRightAnim:GetFirstAnimation():SetEndOffsetY(endY)
			_control.bar.decreaseRegRightAnim:GetFirstAnimation():SetDuration(duration)
			_control.bar.decreaseRegRightAnim:GetAnimation(2):SetDuration(duration / 2)
			_control.bar.decreaseRegRightAnim:GetAnimation(3):SetDuration(duration / 2)			
			_control.bar.decreaseRegRightAnim:SetAnimationOffset(_control.bar.decreaseRegRightAnim:GetAnimation(3), duration / 2)					
		end				
	end

	if _control.barLeft then
		if _control.barLeft.increaseRegLeftControl then
			local startX = _control.barLeft.increaseRegLeftControl.startX or 0			
			local endX = _control.barLeft.increaseRegLeftControl.endX or 0
			local startY = _control.barLeft.increaseRegLeftControl.startY or 0
			local endY = _control.barLeft.increaseRegLeftControl.endY or 0
			local duration = _control.barLeft.increaseRegLeftControl.duration or 800
		
			_control.barLeft.increaseRegLeftAnim:GetFirstAnimation():SetStartOffsetX(startX)
			_control.barLeft.increaseRegLeftAnim:GetFirstAnimation():SetEndOffsetX(-(_control.barLeft:GetWidth() + endX))	
			_control.barLeft.increaseRegLeftAnim:GetFirstAnimation():SetStartOffsetY(startY)
			_control.barLeft.increaseRegLeftAnim:GetFirstAnimation():SetEndOffsetY(endY)
			_control.barLeft.increaseRegLeftAnim:GetFirstAnimation():SetDuration(duration)
			_control.barLeft.increaseRegLeftAnim:GetAnimation(2):SetDuration(duration / 2)
			_control.barLeft.increaseRegLeftAnim:GetAnimation(3):SetDuration(duration / 2)			
			_control.barLeft.increaseRegLeftAnim:SetAnimationOffset(_control.barLeft.increaseRegLeftAnim:GetAnimation(3), duration / 2)					
		end	

		if _control.barLeft.decreaseRegLeftControl then
			local startX = _control.barLeft.decreaseRegLeftControl.startX or 0			
			local endX = _control.barLeft.decreaseRegLeftControl.endX or 0
			local startY = _control.barLeft.decreaseRegLeftControl.startY or 0
			local endY = _control.barLeft.decreaseRegLeftControl.endY or 0				
			local duration = _control.barLeft.decreaseRegLeftControl.duration or 800
			
			_control.barLeft.decreaseRegLeftAnim:GetFirstAnimation():SetStartOffsetX(startX)
			_control.barLeft.decreaseRegLeftAnim:GetFirstAnimation():SetEndOffsetX((_control.barLeft:GetWidth() + endX))
			_control.barLeft.decreaseRegLeftAnim:GetFirstAnimation():SetStartOffsetY(startY)
			_control.barLeft.decreaseRegLeftAnim:GetFirstAnimation():SetEndOffsetY(endY)	
			_control.barLeft.decreaseRegLeftAnim:GetFirstAnimation():SetDuration(duration)
			_control.barLeft.decreaseRegLeftAnim:GetAnimation(2):SetDuration(duration / 2)
			_control.barLeft.decreaseRegLeftAnim:GetAnimation(3):SetDuration(duration / 2)			
			_control.barLeft.decreaseRegLeftAnim:SetAnimationOffset(_control.barLeft.decreaseRegLeftAnim:GetAnimation(3), duration / 2)						
		end				
	end
	
	if _control.barRight then
		_control.barRight.barGloss = GetControl(_control.barRight, "Gloss")					
		_control.barRight.increaseRegRightControl = GetControl(_control.barRight, "_IncreaseRegRight")	
		_control.barRight.decreaseRegRightControl = GetControl(_control.barRight, "_DecreaseRegRight")

		if _control.barRight.increaseRegRightControl then
			local startX = _control.barRight.increaseRegRightControl.startX or 0			
			local endX = _control.barRight.increaseRegRightControl.endX or 0
			local startY = _control.barRight.increaseRegRightControl.startY or 0
			local endY = _control.barRight.increaseRegRightControl.endY or 0
			local duration = _control.barRight.increaseRegRightControl.duration or 800
		
			_control.barRight.increaseRegRightAnim:GetFirstAnimation():SetStartOffsetX(startX)
			_control.barRight.increaseRegRightAnim:GetFirstAnimation():SetEndOffsetX(_control.barRight:GetWidth() + endX)	
			_control.barRight.increaseRegRightAnim:GetFirstAnimation():SetStartOffsetY(startY)
			_control.barRight.increaseRegRightAnim:GetFirstAnimation():SetEndOffsetY(endY)	
			_control.barRight.increaseRegRightAnim:GetFirstAnimation():SetDuration(duration)
			_control.barRight.increaseRegRightAnim:GetAnimation(2):SetDuration(duration / 2)
			_control.barRight.increaseRegRightAnim:GetAnimation(3):SetDuration(duration / 2)			
			_control.barRight.increaseRegRightAnim:SetAnimationOffset(_control.barRight.increaseRegRightAnim:GetAnimation(3), duration / 2)					
		end	

		if _control.barRight.decreaseRegRightControl then
			local startX = _control.barRight.decreaseRegRightControl.startX or 0			
			local endX = _control.barRight.decreaseRegRightControl.endX or 0
			local startY = _control.barRight.decreaseRegRightControl.startY or 0
			local endY = _control.barRight.decreaseRegRightControl.endY or 0	
			local duration = _control.barRight.decreaseRegRightControl.duration or 800				
		
			_control.barRight.decreaseRegRightAnim:GetFirstAnimation():SetStartOffsetX(startX)
			_control.barRight.decreaseRegRightAnim:GetFirstAnimation():SetEndOffsetX(-(_control.barRight:GetWidth() + endX))
			_control.barRight.decreaseRegRightAnim:GetFirstAnimation():SetStartOffsetY(startY)
			_control.barRight.decreaseRegRightAnim:GetFirstAnimation():SetEndOffsetY(endY)	
			_control.barRight.decreaseRegRightAnim:GetFirstAnimation():SetDuration(duration)				
			_control.barRight.decreaseRegRightAnim:GetAnimation(2):SetDuration(duration / 2)
			_control.barRight.decreaseRegRightAnim:GetAnimation(3):SetDuration(duration / 2)			
			_control.barRight.decreaseRegRightAnim:SetAnimationOffset(_control.barRight.decreaseRegRightAnim:GetAnimation(3), duration / 2)					
		end				
	end			
end

local function UpdateArrowAnimation(_data, _barControl)
	if not _data or not _barControl then
		return
	end

	if _data.increaseRegenData.isActive then
		if _barControl.increaseRegLeftAnim and not _barControl.increaseRegLeftAnim:IsPlaying() then
			_barControl.increaseRegLeftAnim:PlayFromStart() 
		end
		
		if _barControl.increaseRegRightAnim and not _barControl.increaseRegRightAnim:IsPlaying() then
			_barControl.increaseRegRightAnim:PlayFromStart() 
		end		
	elseif _data.decreaseRegenData.isActive then
		if _barControl.decreaseRegLeftAnim and not _barControl.decreaseRegLeftAnim:IsPlaying() then
			_barControl.decreaseRegLeftAnim:PlayFromStart() 
		end
		
		if _barControl.decreaseRegRightAnim and not _barControl.decreaseRegRightAnim:IsPlaying() then
			_barControl.decreaseRegRightAnim:PlayFromStart() 
		end			
	end		
end

local function StopArrowAnimation(_barControl)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.StopArrowAnimation |" .. _barControl:GetName())
	end
	--/DebugMessage--

	if _barControl.increaseRegLeftControl then
		if AUI.Animations.IsPlaying(_barControl.increaseRegLeftControl) then
			AUI.Animations.StopAnimation(_barControl.increaseRegLeftControl)	
		end
	end
	
	if _barControl.increaseRegRightControl then
		if AUI.Animations.IsPlaying(_barControl.increaseRegRightControl) then
			AUI.Animations.StopAnimation(_barControl.increaseRegRightControl)	
		end
	end	
			
	if _barControl.decreaseRegLeftControl then
		if AUI.Animations.IsPlaying(_barControl.decreaseRegLeftControl) then
			AUI.Animations.StopAnimation(_barControl.decreaseRegLeftControl)	
		end
	end				

	if _barControl.decreaseRegRightControl then
		if AUI.Animations.IsPlaying(_barControl.decreaseRegRightControl) then
			AUI.Animations.StopAnimation(_barControl.decreaseRegRightControl)	
		end
	end				
end

local function ShowWarner(_control)
	if _control and not _control.data.warner.isActive then	
		--DebugMessage--
		if AUI_DEBUG then
			AUI.DebugMessage("AUI.Attributes.ShowWarner | " .. _control:GetName())
		end
		--/DebugMessage--	
	
		if _control.warnerControl then	
			if _control.warnerControl.animations then
				for _, animation in pairs(_control.warnerControl.animations) do			
					animation:PlayFromStart()
				end			
			end	

			_control.warnerControl:SetHidden(false)			
		end				

		_control.data.warner.isActive = true
	end
end

local function HideWarner(_control)
	if _control and _control.data.warner.isActive then	
		--DebugMessage--
		if AUI_DEBUG then
			AUI.DebugMessage("AUI.Attributes.HideWarner | " .. _control:GetName())
		end
		--/DebugMessage--	
	
		if _control.warnerControl then
			if _control.warnerControl.animations then
				for _, animation in pairs(_control.warnerControl.animations) do			
					animation:Stop()
				end				
			end		

			_control.warnerControl:SetHidden(true)
		end		

		_control.data.warner.isActive = false
	end
end

local function ShowIncreaseArmorEffect(_control)
	if _control then
		if _control.increasedArmorOverlayControl then	
			--DebugMessage--
			if AUI_DEBUG then
				AUI.DebugMessage("AUI.Attributes.ShowIncreaseArmorEffect | " .. _control:GetName())
			end
			--/DebugMessage--		
		
			_control.data.increaseArmorEffect.isActive = true

			_control.increasedArmorOverlayControl:SetAlpha(1)
			
			if _control.increasedArmorOverlayControl.animations then
				for _, animation in pairs(_control.increasedArmorOverlayControl.animations) do			
					animation:PlayFromStart()
				end
			end			
		end
	end
end

local function HideIncreaseArmorEffect(_control)
	if _control then
		if _control.increasedArmorOverlayControl and _control.data.increaseArmorEffect.isActive then
			--DebugMessage--
			if AUI_DEBUG then
				AUI.DebugMessage("AUI.Attributes.HideIncreaseArmorEffect | " .. _control:GetName())
			end
			--/DebugMessage--		
		
			_control.data.increaseArmorEffect.isActive = false
		
			_control.increasedArmorOverlayControl:SetAlpha(0)
			
			if _control.increasedArmorOverlayControl.animations then
				for _, animation in pairs(_control.increasedArmorOverlayControl.animations) do			
					animation:Stop()
				end
			end				
		end
	end
end

local function ShowDecreaseArmorEffect(_control)
	if _control then
		if _control.decreasedArmorOverlayControl and not _control.data.decreaseArmorEffect.isActive then
			--DebugMessage--
			if AUI_DEBUG then
				AUI.DebugMessage("AUI.Attributes.ShowDecreaseArmorEffect | " .. _control:GetName())
			end
			--/DebugMessage--
		
			_control.data.decreaseArmorEffect.isActive = true
			_control.decreasedArmorOverlayControl:SetAlpha(1)
			
			if _control.decreasedArmorOverlayControl.animations then
				for _, animation in pairs(_control.decreasedArmorOverlayControl.animations) do			
					animation:PlayFromStart()
				end
			end				
		end
	end
end

local function HideDecreaseArmorEffect(_control)
	if _control then
		if _control.decreasedArmorOverlayControl and _control.data.decreaseArmorEffect.isActive then
			--DebugMessage--
			if AUI_DEBUG then
				AUI.DebugMessage("AUI.Attributes.HideDecreaseArmorEffect | " .. _control:GetName())
			end
			--/DebugMessage--		
		
			_control.data.decreaseArmorEffect.isActive = false
			_control.decreasedArmorOverlayControl:SetAlpha(0)
			
			if _control.decreasedArmorOverlayControl.animations then
				for _, animation in pairs(_control.decreasedArmorOverlayControl.animations) do			
					animation:Stop()
				end
			end			
		end
	end
end

local function ShowIncreasePowerEffect(_control)
	if _control then
		if _control.increasedPowerOverlayControl and not _control.data.increasePowerEffect.isActive then	
			--DebugMessage--
			if AUI_DEBUG then
				AUI.DebugMessage("AUI.Attributes.ShowIncreasePowerEffect | " .. _control:GetName())
			end
			--/DebugMessage--		
		
			_control.data.increasePowerEffect.isActive = true
			_control.increasedPowerOverlayControl:SetAlpha(1)
			
			if _control.increasedPowerOverlayControl.animations then
				for _, animation in pairs(_control.increasedPowerOverlayControl.animations) do			
					animation:PlayFromStart()
				end
			end	
		end
	end
end

local function HideIncreasePowerEffect(_control)
	if _control then
		if _control.increasedPowerOverlayControl and _control.data.increasePowerEffect.isActive then	
			--DebugMessage--
			if AUI_DEBUG then
				AUI.DebugMessage("AUI.Attributes.HideIncreasePowerEffect | " .. _control:GetName())
			end
			--/DebugMessage--		
		
			_control.data.increasePowerEffect.isActive = false
			_control.increasedPowerOverlayControl:SetAlpha(0)
			
			if _control.increasedPowerOverlayControl.animations then
				for _, animation in pairs(_control.increasedPowerOverlayControl.animations) do		
					animation:Stop()
				end
			end			
		end
	end
end

local function ShowDecreasePowerEffect(_control)
	if _control then
		if _control.decreasedPowerOverlayControl and not _control.data.decreasePowerEffect.isActive then	
			--DebugMessage--
			if AUI_DEBUG then
				AUI.DebugMessage("AUI.Attributes.ShowDecreasePowerEffect | " .. _control:GetName())
			end
			--/DebugMessage--		
		
			_control.data.decreasePowerEffect.isActive = true
			_control.decreasedPowerOverlayControl:SetAlpha(1)
			
			if _control.decreasedPowerOverlayControl.animations then
				for _, animation in pairs(_control.decreasedPowerOverlayControl.animations) do		
					animation:PlayFromStart()
				end
			end	
		end
	end
end

local function HideDecreasePowerEffect(_control)
	if _control then
		if _control.decreasedPowerOverlayControl and _control.data.decreasePowerEffect.isActive then	
			--DebugMessage--
			if AUI_DEBUG then
				AUI.DebugMessage("AUI.Attributes.HideDecreasePowerEffect | " .. _control:GetName())
			end
			--/DebugMessage--		
		
			_control.data.decreasePowerEffect.isActive = false
			_control.decreasedPowerOverlayControl:SetAlpha(0)
			
			if _control.decreasedPowerOverlayControl.animations then
				for _, animation in pairs(_control.decreasedPowerOverlayControl.animations) do		
					animation:Stop()
				end
			end			
		end
	end
end

local function SetStatusBar(_barControl, _currentValue, _maxValue, _smooth)
	if not _barControl or not _currentValue or not _maxValue then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.SetStatusBar | " .. _barControl:GetName())
	end
	--/DebugMessage--	
	
	local smooth = _smooth or false
	
	ZO_StatusBar_SmoothTransition(_barControl, _currentValue, _maxValue, not _smooth)		
			
	if _barControl.barGloss then
		ZO_StatusBar_SmoothTransition(_barControl.barGloss, _currentValue, _maxValue, not _smooth)
	end
end

local function UpdateMainBar(_control, _smooth)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.UpdateMainBar | " .. _control:GetName())
	end
	--/DebugMessage--

	local statusValue = _control.data.currentValue
	local statusMax = _control.data.maxValue

	if _control.barLeft and _control.barRight then		
		if isPreviewShowed then
			statusValue = DEFAULT_PREVIEW_HP
			statusMax = DEFAULT_PREVIEW_HP			
		end
		
		if _control.subControl.data.currentValue > 0 then	
			local subBarValue =  statusMax - (statusMax - _control.data.currentValue)			
			local mainBarValue = statusValue - _control.subControl.data.currentValue														
					
			SetStatusBar(_control.barLeft, mainBarValue, statusMax, _smooth)
			SetStatusBar(_control.barRight, mainBarValue, statusMax, _smooth)
					
			SetStatusBar(_control.subControl.barLeft, subBarValue, statusMax, false)	
			SetStatusBar(_control.subControl.barRight, subBarValue, statusMax, false)	
		else		
			SetStatusBar(_control.barLeft, statusValue, statusMax, _smooth)
			SetStatusBar(_control.barRight, statusValue, statusMax, _smooth)
		end			
	elseif _control.bar then
		if isPreviewShowed then
			statusValue = DEFAULT_PREVIEW_HP
			statusMax = DEFAULT_PREVIEW_HP	
		end				
				
		if _control.subControl.data.currentValue > 0 then
			local subBarValue =  statusMax - (statusMax - _control.data.currentValue)
			local mainBarValue = statusValue - _control.subControl.data.currentValue	
			
			SetStatusBar(_control.bar, mainBarValue, statusMax, _smooth)
			SetStatusBar(_control.subControl.bar, subBarValue, statusMax, false)					
		else
			SetStatusBar(_control.bar, statusValue, statusMax, _smooth)
		end
	end				
end

local function UpdateBar(_control, _bar, _smooth, _color)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.UpdateBar | " .. _control:GetName())
	end
	--/DebugMessage--
	
	UpdateBarColor(_control, _bar, _color)			
		
	if _control.mainControl then	
		UpdateMainBar(_control.mainControl, _smooth)			
	elseif _control.subControl then
		UpdateMainBar(_control.subControl.mainControl, _smooth)	
	else
		SetStatusBar(_bar, _control.data.currentValue, _control.data.maxValue, _smooth)
	end		
end

local function IsUpdateDataAllowed(_control)
	if AUI.Attributes.IsTarget(_control.attributeId) or not _control.data.currentValue or not _control.data.maxValue or _control.data.currentValue ~= _currentValue or _control.data.maxValue ~= _maxValue then	
		return true
	end
	
	return false
end

local function UpdateData(_control, _currentValue, _maxValue, _smooth, _color)		
	if _control and _control.data and _currentValue ~= nil and _maxValue ~= nil then	
		if IsUpdateDataAllowed(_control) then	
			--DebugMessage--
			if AUI_DEBUG then
				AUI.DebugMessage("AUI.Attributes.UpdateData |" .. _control:GetName() .. " | " .. tostring(_currentValue) .. " | " .. tostring(_maxValue))
			end
			--/DebugMessage--
		
			_control.data.currentValue = _currentValue or 0
			_control.data.maxValue = _maxValue or _control.data.currentValue + 1	
			
			if _control.owns then
				if _control.data.currentValue >= _control.mainControl.data.currentValue then
					_control.data.currentValue = _control.mainControl.data.currentValue / 1.2
				end
			else
			
			end		

			if _control.barLeft and _control.barRight then		
				UpdateBar(_control, _control.barLeft, _smooth, _color)
				UpdateBar(_control, _control.barRight, _smooth, _color)					
			else	
				if _control.bar then
					UpdateBar(_control, _control.bar, _smooth, _color)
				end
			end
		
			UpdateAttribute(_control)	
			UpdateControlVisibility(_control)	
			
			if _control.data.currentValue and _control.data.maxValue then
				local percent = AUI.Math.Round((_control.data.currentValue / _control.data.maxValue) * 100)
				local isUnitDead = IsUnitDead(_control.unitTag)
				if percent <= 25 and not isUnitDead then
					ShowWarner(_control)
				else
					HideWarner(_control)
				end			
			end				
		end	
	end
end

local function UpdateRegen(_control, _isNewTarget)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.UpdateRegen " .. _control:GetName())
	end
	--/DebugMessage--

	if _control and _control.data then
		_control.data.regenValue = _control.data.increaseRegenData.value + _control.data.decreaseRegenData.value
		
		if _control.data.regenValue > 0 then
			if not _control.data.increaseRegenData.isActive then
				_control.data.increaseRegenData.isChanged = true
				_control.data.increaseRegenData.isActive = true					
			end	

			if _control.data.decreaseRegenData.isActive then
				_control.data.decreaseRegenData.isChanged = true
				_control.data.decreaseRegenData.isActive = false
			end				
		elseif _control.data.regenValue < 0 then
			if not _control.data.decreaseRegenData.isActive then
				_control.data.decreaseRegenData.isChanged = true
				_control.data.decreaseRegenData.isActive = true					
			end	

			if _control.data.increaseRegenData.isActive then
				_control.data.increaseRegenData.isChanged = true
				_control.data.increaseRegenData.isActive = false
			end				
		else
			if _control.data.increaseRegenData.isActive then
				_control.data.increaseRegenData.isChanged = true
				_control.data.increaseRegenData.isActive = false
			end			
		
			if _control.data.decreaseRegenData.isActive then
				_control.data.decreaseRegenData.isChanged = true
				_control.data.decreaseRegenData.isActive = false
			end					
		end
		
		if _control.barLeft and _control.barRight then
			UpdateBarColor(_control, _control.barLeft)
			UpdateBarColor(_control, _control.barRight)
			
			if _isNewTarget then
				StopArrowAnimation(_control.barLeft)
				StopArrowAnimation(_control.barRight)			
			end
			
			UpdateArrowAnimation(_control.data, _control.barLeft)
			UpdateArrowAnimation(_control.data, _control.barRight)
		elseif _control.bar then	
			UpdateBarColor(_control, _control.bar)
			
			if _isNewTarget then
				StopArrowAnimation(_control.bar)		
			end			
			
			UpdateArrowAnimation(_control.data, _control.bar)
		end						
	end
end

local function AddAttributeVisual(_control, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth, _isNewTarget)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.AddAttributeVisual | " .. _control:GetName())
	end
	--/DebugMessage--

	if not IsControlAllowed(_control) then
		return
	end
	
	if AUI.Attributes.IsShield(_control.attributeId) then
		if _unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and _statType == STAT_MITIGATION and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then	
			if not _control.data.shield.isActive then
				_control.data.shield.isActive = true
				_control.data.shield.isChanged = true
			end
				
			UpdateData(_control, _powerValue, _powerMax, _smooth)
		end
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_MAX_POWER and _statType == STAT_MITIGATION and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		UpdateData(_control, _powerValue, _powerMax, _smooth)						
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_MAX_POWER and _statType == STAT_MITIGATION and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		UpdateData(_control, _powerValue, _powerMax, _smooth)									
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		_control.data.decreaseRegenData.value = _powerValue or 0	
		UpdateRegen(_control, _isNewTarget)	
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		_control.data.increaseRegenData.value = _powerValue or 0	
		UpdateRegen(_control, _isNewTarget)			
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_ARMOR_RATING and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		_control.data.increaseArmorEffect.isChanged = true
		ShowIncreaseArmorEffect(_control)			
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_ARMOR_RATING and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		_control.data.decreaseArmorEffect.isChanged = true
		ShowDecreaseArmorEffect(_control)
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_POWER and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then	
		ShowIncreasePowerEffect(_control)			
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_POWER and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then	
		ShowDecreasePowerEffect(_control)
	end
	
	UpdateControlVisibility(_control)
	
	_control.data.shield.isChanged = false
	_control.data.increaseRegenData.isChanged = false							
	_control.data.decreaseRegenData.isChanged = false		
	_control.data.increaseArmorEffect.isChanged = false
	_control.data.decreaseArmorEffect.isChanged = false
end

local function RemoveAttributeVisual(_control, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth, _isNewTarget)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("RemoveAttributeVisual | " .. _control:GetName())
	end
	--/DebugMessage--

	if not IsControlAllowed(_control) then
		return
	end

	if AUI.Attributes.IsShield(_control.attributeId) then	
		if _unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and _statType == STAT_MITIGATION and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
			if _control.data.shield.isActive then
				if not _powerValue or _powerValue and _powerValue == 0 then
					_control.data.shield.isChanged = true
					_control.data.shield.isActive = false	
				end
			end

			UpdateData(_control, _powerValue, _powerMax, _smooth)	
		end
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_MAX_POWER and _statType == STAT_MITIGATION and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		UpdateData(_control, _powerValue, _powerMax, _smooth)			
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_MAX_POWER and _statType == STAT_MITIGATION and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		UpdateData(_control, _powerValue, _powerMax, _smooth)			
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		_control.data.decreaseRegenData.value = 0	
		UpdateRegen(_control, _isNewTarget)		
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		_control.data.increaseRegenData.value = 0		
		UpdateRegen(_control, _isNewTarget)	
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_ARMOR_RATING and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		_control.data.increaseArmorEffect.isChanged = true
		HideIncreaseArmorEffect(_control)		
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_ARMOR_RATING and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		_control.data.decreaseArmorEffect.isChanged = true
		HideDecreaseArmorEffect(_control)	
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_POWER and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then	
		HideIncreasePowerEffect(_control)				
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_POWER and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then	
		HideDecreasePowerEffect(_control)														
	end
	
	UpdateControlVisibility(_control)
	
	_control.data.shield.isChanged = false
	_control.data.increaseRegenData.isChanged = false							
	_control.data.decreaseRegenData.isChanged = false		
	_control.data.increaseArmorEffect.isChanged = false
	_control.data.decreaseArmorEffect.isChanged = false
end

local function UpdateAttributeVisual(_control, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, _smooth, _isNewTarget)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("UpdateAttributeVisual | " .. _control:GetName() .. " | " .. _unitAttributeVisual .. " | " .. _statType .. " | " .. _attributeType .. " | " .. _powerType)
	end
	--/DebugMessage--

	if not IsControlAllowed(_control) then
		return
	end

	if AUI.Attributes.IsShield(_control.attributeId) then
		if _unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and _statType == STAT_MITIGATION and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
			if _powerValue and _powerValue > 0 then
				if not _control.data.shield.isActive then
					_control.data.shield.isChanged = true		
				end
			
				_control.data.shield.isActive = true				
			else
				if _control.data.shield.isActive then
					_control.data.shield.isChanged = true		
				end			
			
				_control.data.shield.isActive = false
			end
			
			UpdateData(_control, _powerValue, _powerMax, _smooth)
			_control.data.shield.isChanged = false
		end
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_MAX_POWER and _statType == STAT_MITIGATION and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		UpdateData(_control, _powerValue, _powerMax, _smooth)		
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_MAX_POWER and _statType == STAT_MITIGATION and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		UpdateData(_control, _powerValue, _powerMax, _smooth)								
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then	
		_control.data.decreaseRegenData.value = _powerValue	or 0			
		UpdateRegen(_control, _isNewTarget)	
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER and _statType == STAT_HEALTH_REGEN_COMBAT and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		_control.data.increaseRegenData.value = _powerValue	or 0			
		UpdateRegen(_control, _isNewTarget)	
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_ARMOR_RATING and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then
		if _powerValue and _powerValue > 0 then
			ShowIncreaseArmorEffect(_control)
		else
			HideIncreaseArmorEffect(_control)												
		end		
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_ARMOR_RATING and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then	
		if _powerValue and _powerValue < 0 then
			ShowDecreaseArmorEffect(_control)
		else
			HideDecreaseArmorEffect(_control)
		end
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and _statType == STAT_POWER and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then	
		if _powerValue and _powerValue > 0 then
			ShowIncreasePowerEffect(_control)
		else
			HideIncreasePowerEffect(_control)												
		end	
	elseif _unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT and _statType == STAT_POWER and _attributeType == ATTRIBUTE_HEALTH and _powerType == POWERTYPE_HEALTH then	
		if _powerValue and _powerValue < 0 then
			ShowDecreasePowerEffect(_control)
		else
			HideDecreasePowerEffect(_control)												
		end				
	end	
	
	UpdateControlVisibility(_control)
end


function AUI.Attributes.AddAttributeVisual(_unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, effectiveMaxValue, _smooth)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AddAttributeVisual | " .. _unitTag)
	end
	--/DebugMessage--

	if not currentTemplate then
		return
	end

	for _, data in pairs(currentTemplate.attributeData) do
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

function AUI.Attributes.RemoveAttributeVisual(_unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, effectiveMaxValue, _smooth)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.RemoveAttributeVisual | " .. _unitTag)
	end
	--/DebugMessage--

	if not currentTemplate then
		return
	end

	for _, data in pairs(currentTemplate.attributeData) do
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

function AUI.Attributes.UpdateAttributeVisual(_unitTag, _unitAttributeVisual, _statType, _attributeType, _powerType, _powerValue, _powerMax, effectiveMaxValue, _smooth)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.UpdateAttributeVisual | " .. _unitTag)
	end
	--/DebugMessage--

	if not currentTemplate then
		return
	end

	for _, data in pairs(currentTemplate.attributeData) do
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

local function UpdateFrame(_control)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.UpdateFrame | " .. _control:GetName())
	end
	--/DebugMessage--

	local isUnitDead = IsUnitDead(_control.unitTag)
	local isUnitPlayer = IsUnitPlayer(_control.unitTag)	
	local isUnitOnline = IsUnitOnline(_control.unitTag)	

	if not AUI.Attributes.IsShield(_control.attributeId) then
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
		
		if _control.titleControl then
			local caption = ""	
			
			if isUnitPlayer then
				caption = GetUnitTitle(_control.unitTag)
			else
				caption = zo_strformat(SI_TOOLTIP_UNIT_CAPTION, GetUnitCaption(_control.unitTag))
			end	
		
			if(caption ~= "") then
				_control.titleControl:SetHidden(false)
				_control.titleControl:SetText(caption)
			else
				_control.titleControl:SetHidden(true)
			end	
		end	
		
		if _control.unitNameControl then
			local unitName = GetUnitName(_control.unitTag)
	
			if isPreviewShowed then
				unitName = AUI.L10n.GetString("player") 
				
				if AUI.Attributes.IsTargetHealth(_control.attributeId) then
					unitName = AUI.L10n.GetString("target")
				elseif AUI.Attributes.IsGroupHealth(_control.attributeId) then
					unitName = AUI.L10n.GetString("group")	
				elseif AUI.Attributes.IsBossHealth(_control.attributeId) then
					unitName = AUI.L10n.GetString("boss")
				end
			else
				if isUnitPlayer and _control.settings.showAccountName then
					unitName = GetUnitDisplayName(_control.unitTag)
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
		
		if _control.barLeft and _control.barRight then 
			if isUnitDead or isUnitPlayer and not isUnitOnline then
				_control.barLeft:SetHidden(true)		
				_control.barRight:SetHidden(true)					
			else
				if _control.settings.outOfRangeOpacity then
					local isUnitInRange = IsUnitInGroupSupportRange(_control.unitTag)	
					if isPreviewShowed then
						isUnitInRange = true
					end
				
					if isUnitInRange then
						_control.barLeft:SetAlpha(1)
						_control.barRight:SetAlpha(1)
					else
						_control.barLeft:SetAlpha(_control.settings.outOfRangeOpacity)
						_control.barRight:SetAlpha(_control.settings.outOfRangeOpacity)		
					end
				end
				
				_control.barLeft:SetHidden(false)	
				_control.barRight:SetHidden(false)	
			end	
		else
			if _control.bar then
				if isUnitDead or isUnitPlayer and not isUnitOnline then
					_control.bar:SetHidden(true)					
				else
					local isUnitInRange = IsUnitInGroupSupportRange(_control.unitTag)	
					if isPreviewShowed then
						isUnitInRange = true
					end
					
					if _control.settings.outOfRangeOpacity then
						if isUnitInRange then
							_control.bar:SetAlpha(1)
						else
							_control.bar:SetAlpha(_control.settings.outOfRangeOpacity)
						end
					end
					
					_control.bar:SetHidden(false)			
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
		if _control.barLeft and _control.barRight then 
			if isUnitDead or isUnitPlayer and not isUnitOnline then
				SetStatusBar(_control.barLeft, 0, 1, false)
				SetStatusBar(_control.barRight, 0, 1, false)
			end
		elseif _control.bar then
			if isUnitDead or isUnitPlayer and not isUnitOnline then
				SetStatusBar(_control.bar, 0, 1, false)
			end			
		end			
	end

	if _control.textValueControl then
		if _control.settings.showText then
			if isUnitPlayer and not isUnitOnline or isUnitDead then
				_control.textValueControl:SetHidden(true)
			else
				_control.textValueControl:SetHidden(false)
			end
		end
	end
	
	if _control.textMaxValueControl then
		if _control.settings.showText then
			if isUnitPlayer and not isUnitOnline or isUnitDead then
				_control.textMaxValueControl:SetHidden(true)
			else
				_control.textMaxValueControl:SetHidden(false)
			end
		end
	end	
	
	if _control.textPercentControl then	
		if _control.settings.showText then
			if isUnitPlayer and not isUnitOnline or isUnitDead then
				_control.textPercentControl:SetHidden(true)
			else
				_control.textPercentControl:SetHidden(false)
			end
		end
	end	
end

local function UpdateControl(_control, _isNewTarget)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.UpdateControl | " .. _control:GetName())
	end
	--/DebugMessage--

	if not IsControlAllowed(_control) then
		return
	end	

	AUI.Attributes.ResetControlData(_control)
	
	if AUI.Attributes.IsShield(_control.attributeId) then
		local shieldValue, shieldMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, _control.powerType)

		if isPreviewShowed then
			shieldValue = DEFAULT_PREVIEW_HP / 2.5
			shieldMax = DEFAULT_PREVIEW_HP
		end	

		UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, _control.powerType, shieldValue, shieldMax, false, _isNewTarget)		
	elseif AUI.Attributes.IsPlayer(_control.attributeId) or AUI.Attributes.IsTargetHealth(_control.attributeId) or AUI.Attributes.IsBossHealth(_control.attributeId) or AUI.Attributes.IsGroupHealth(_control.attributeId) then
		if _control.attributeId == AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH or AUI.Attributes.IsTargetHealth(_control.attributeId) or AUI.Attributes.IsBossHealth(_control.attributeId) or AUI.Attributes.IsGroupHealth(_control.attributeId) then
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
		elseif _control.attributeId == AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA then
			local increaseMagickaRegenValue, increaseMagickaRegenMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, _control.powerType)
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, _control.powerType, increaseMagickaRegenValue, increaseMagickaRegenMax, increaseMagickaRegenMax, false, _isNewTarget)

			local decreaseMagickaRegenValue, decreaseMagickaRegenMax = GetUnitAttributeVisualizerEffectInfo(_control.unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, _control.powerType)
			UpdateAttributeVisual(_control, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, _control.powerType, decreaseMagickaRegenValue, decreaseMagickaRegenMax, decreaseMagickaRegenMax, false, _isNewTarget)			
		elseif _control.attributeId == AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA then
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

function AUI.Attributes.UpdateSingleBar(_unitTag, _powerType, _smooth, _currentValue, _maxValue, _effectiveMaxValue, _color)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.UpdateSingleBar | " .. _unitTag .. " | " .. _powerType .. " | " .. _currentValue .. " | " .. _maxValue)
	end
	--/DebugMessage--

	if not currentTemplate then
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

	for _, data in pairs(currentTemplate.attributeData) do
		if not AUI.Attributes.IsShield(data.attributeId) then
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
	
function AUI.Attributes.OnPowerUpdate(_unitTag, _powerIndex, _powerType, _powerValue, _powerMax, _powerEffectiveMax)
	AUI.Attributes.UpdateSingleBar(_unitTag, _powerType, true, _powerValue, _powerMax, _powerEffectiveMax)
	if AUI.Attributes.Bossbar.IsEnabled() and AUI.Unit.IsBossUnitTag(_unitTag) then
		AUI.Attributes.Bossbar.UpdateText(_powerValue, _powerMax, _powerEffectiveMax)
	end
end
	
function AUI.Attributes.OnPlayerActivated()
	if not isLoaded then
		if not currentTemplate then	
			local templateName = AUI.Settings.Template.Attributes
			currentTemplate = AUI.Attributes.LoadTemplate(templateName)
			AUI.Attributes.UpdateUI()
		end
		
		if AUI.Attributes.Group.IsEnabled() then
			AUI.Attributes.Group.Load()
		end
		
		if AUI.Attributes.Player.IsEnabled() then
			AUI.Attributes.Player.Load()
			
		end	
		
		if AUI.Attributes.Target.IsEnabled() then
			AUI.Attributes.Target.Load()
		end	
		
		if AUI.Attributes.Bossbar.IsEnabled() then
			AUI.Attributes.Bossbar.Load()
		end

		isLoaded = true
	end
	
	AUI.Attributes.Update()
	AUI.Attributes.Target.OnChanged()
end	
	

function AUI.Attributes.UpdateUI()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.UpdateUI")
	end
	--/DebugMessage--

	if not currentTemplate then
		return
	end

	for type, data in pairs(currentTemplate.attributeData) do
		if data.control then
			local attributeData = GetDataFromAttributeId(type)
			if data.control.frames then							
				for _, frame in pairs(data.control.frames) do
					frame.settings = attributeData		
									
					if IsControlAllowed(frame) then
						if not frame.isInit or isPreviewShowed then
							frame.isInit = true	
							SetLayout(frame)	
						end	
					end
				end				
			else	
				data.control.settings = attributeData
				if IsControlAllowed(data.control) then
					if not data.control.isInit or isPreviewShowed then
						data.control.isInit = true								
						SetLayout(data.control)						
					end
				end
			end
		end
	end

	if AUI.Settings.Attributes.boss_show_text then
		AUI_BossBarOverlay_Text:SetHidden(false)
	else
		AUI_BossBarOverlay_Text:SetHidden(true)
	end
			
	AUI_BossBarOverlay_Text:SetFont(LMP:Fetch('font', AUI.Settings.Attributes.boss_font_art) .. "|" .. AUI.Settings.Attributes.boss_font_size .. "|" .. "outline")	
	
	AUI.Attributes.Group.UpdateUI()
	AUI.Attributes.Bossbar.UpdateUI()
	
	AUI.Attributes.Update()	
end

function AUI.Attributes.Update(_unitTag, _isNewTarget)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Attributes.Update | " .. tostring(_unitTag))
	end
	--/DebugMessage--

	if not currentTemplate then
		return
	end

	if currentTemplate.attributeData then
		for _, data in pairs(currentTemplate.attributeData) do
			if data.control.frames then
				if _unitTag then
					local frame = data.control.frames[_unitTag]
					if frame then
						local doesUnitExist = DoesUnitExist(frame.unitTag)
				
						if AUI.Unit.IsGroupUnitTag(_unitTag) then					
							doesUnitExist = true
						end
						
						if doesUnitExist or isPreviewShowed then
							UpdateControl(frame)
						else
							UpdateControlVisibility(frame)
						end
					end
				else			
					for _, frame in pairs(data.control.frames) do
						local doesUnitExist = DoesUnitExist(frame.unitTag)
					
						if AUI.Unit.IsGroupUnitTag(frame.unitTag) then
							doesUnitExist = true
						end					
					
						if doesUnitExist or isPreviewShowed then
							UpdateControl(frame)
						else
							UpdateControlVisibility(frame)
						end
					end
				end
			elseif IsControlAllowed(data.control) then
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

function AUI.Attributes.ShowFrame(_attributeId)
	if currentTemplate then
		for id, data in pairs(currentTemplate.attributeData) do
			if id == _attributeId then		
				if data.control.frames then
					for _, frame in pairs(data.control.frames) do
						AUI.Fade.In(frame, 0, 0, 0, frame.settings.opacity)
					end							
				elseif IsControlAllowed(data.control) then	
					AUI.Fade.In(data.control, 0, 0, 0, data.control.settings.opacity)	
				end
			end
		end	
	end
end	

function AUI.Attributes.HideFrame(_attributeId)
	if currentTemplate then
		for id, data in pairs(currentTemplate.attributeData) do
			if id == _attributeId then
				if data.control.frames then
					for _, frame in pairs(data.control.frames) do
						AUI.Fade.Out(frame)
					end
				else		
					AUI.Fade.Out(data.control)		
				end
			end
		end	
	end
end	

function AUI.Attributes.IsPreviewShow()
	return isPreviewShowed		
end

function AUI.Attributes.ShowPreview()
	local previewGroupSize = 4
	
	if AUI.Attributes.Group.IsRaid() then
		previewGroupSize = 24
	end

	isPreviewShowed = true		
	
	ATTRIBUTES_SCENE_FRAGMENT.hiddenReasons:SetHiddenForReason("ShouldntShow", true)
	AUI_Attributes_Window:SetHidden(false) 	
	
	AUI.Attributes.Group.SetPreviewGroupSize(previewGroupSize)
	AUI.Attributes.UpdateUI()	

	AUI.Attributes.Bossbar.ShowPreview()
	
	for _, data in pairs(currentTemplate.attributeData) do
		AUI.Attributes.ShowFrame(data.control.attributeId)
	end
end

function AUI.Attributes.HidePreview()	
	isPreviewShowed = false

	ATTRIBUTES_SCENE_FRAGMENT.hiddenReasons:SetHiddenForReason("ShouldntShow", false)		
	
	AUI.Attributes.Group.SetPreviewGroupSize(0)
	AUI.Attributes.UpdateUI()
	AUI.Attributes.Target.OnChanged()
	AUI.Attributes.Bossbar.HidePreview()
end

function AUI.Attributes.OnReticleTargetChanged()
	if AUI.Attributes.Target.IsEnabled() then
		AUI.Attributes.Target.OnChanged()
	end
end

function AUI.Attributes.Load()
	if isLoaded then
		return
	end	
	
	CreateControlFromVirtual("AUI_BossBarOverlay", ZO_BossBarHealth, "AUI_BossBarOverlay")	
	
	ATTRIBUTES_SCENE_FRAGMENT = ZO_SimpleSceneFragment:New(AUI_Attributes_Window)	
	ATTRIBUTES_SCENE_FRAGMENT.hiddenReasons = ZO_HiddenReasons:New()		
    ATTRIBUTES_SCENE_FRAGMENT:SetConditional(function()
        return not ATTRIBUTES_SCENE_FRAGMENT.hiddenReasons:IsHidden()
    end)				
	
	HUD_SCENE:AddFragment(ATTRIBUTES_SCENE_FRAGMENT)
	HUD_UI_SCENE:AddFragment(ATTRIBUTES_SCENE_FRAGMENT)
	SIEGE_BAR_SCENE:AddFragment(ATTRIBUTES_SCENE_FRAGMENT)
	if SIEGE_BAR_UI_SCENE then
		SIEGE_BAR_UI_SCENE:AddFragment(ATTRIBUTES_SCENE_FRAGMENT)
	end
end

function AUI.Attributes.Group.IsEnabled()
	return AUI.Settings.Attributes.group_attributes_enabled
end

function AUI.Attributes.Player.IsEnabled()
	return AUI.Settings.Attributes.player_attributes_enabled
end

function AUI.Attributes.Target.IsEnabled()
	return AUI.Settings.Attributes.target_attributes_enabled
end

function AUI.Attributes.Bossbar.IsEnabled()
	return AUI.Settings.Attributes.boss_attributes_enabled
end