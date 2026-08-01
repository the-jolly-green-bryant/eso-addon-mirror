AUI_SCROLLING_TEXT_EXP = 1
AUI_SCROLLING_TEXT_CXP = 2
AUI_SCROLLING_TEXT_AP = 3
AUI_SCROLLING_TEXT_TELVAR = 4
AUI_SCROLLING_TEXT_DAMAGE_OUT = 5
AUI_SCROLLING_TEXT_HEAL_OUT = 6
AUI_SCROLLING_TEXT_CRIT_DAMAGE_OUT = 7
AUI_SCROLLING_TEXT_CRIT_HEAL_OUT = 8
AUI_SCROLLING_TEXT_DAMAGE_IN = 9
AUI_SCROLLING_TEXT_HEAL_IN = 10
AUI_SCROLLING_TEXT_CRIT_DAMAGE_IN = 11
AUI_SCROLLING_TEXT_CRIT_HEAL_IN = 12
AUI_SCROLLING_TEXT_COMBAT_START = 13
AUI_SCROLLING_TEXT_COMBAT_END = 14
AUI_SCROLLING_TEXT_PROC = 15
AUI_SCROLLING_TEXT_ULTI_READY = 16
AUI_SCROLLING_TEXT_POTION_READY = 17
AUI_SCROLLING_TEXT_HEALTH_LOW = 18
AUI_SCROLLING_TEXT_MAGICKA_LOW = 19
AUI_SCROLLING_TEXT_STAMINA_LLOW = 20
AUI_SCROLLING_TEXT_HEALTH_REG = 21
AUI_SCROLLING_TEXT_MAGICKA_REG = 22
AUI_SCROLLING_TEXT_STAMINA_REG = 23
AUI_SCROLLING_TEXT_HEALTH_DEREG = 24
AUI_SCROLLING_TEXT_MAGICKA_DEREG = 25
AUI_SCROLLING_TEXT_STAMINA_DEREG = 26

AUI_SCROLLING_TEXT_DAMAGE_OUT_TEXTURE = "/esoui/art/icons/alchemy/crafting_alchemy_trait_increaseweaponpower_match.dds"
AUI_SCROLLING_TEXT_CRIT_DAMAGE_OUT_TEXTURE = "/esoui/art/icons/alchemy/crafting_alchemy_trait_lowerweaponpower_conflict.dds"
AUI_SCROLLING_TEXT_HEAL_OUT_TEXTURE = "/esoui/art/icons/alchemy/crafting_alchemy_trait_unstoppable_match.dds"
AUI_SCROLLING_TEXT_CRIT_HEAL_OUT_TEXTURE = "/esoui/art/icons/alchemy/crafting_alchemy_trait_unstoppable_conflict.dds"
AUI_SCROLLING_TEXT_DAMAGE_IN_TEXTURE = "/esoui/art/icons/alchemy/crafting_alchemy_trait_increaseweaponpower_match.dds"
AUI_SCROLLING_TEXT_CRIT_DAMAGE_IN_TEXTURE = "/esoui/art/icons/alchemy/crafting_alchemy_trait_lowerweaponpower_conflict.dds"
AUI_SCROLLING_TEXT_HEAL_IN_DAMAGE_OUT_TEXTURE = "/esoui/art/icons/alchemy/crafting_alchemy_trait_unstoppable_match.dds"
AUI_SCROLLING_TEXT_CRIT_HEAL_IN_TEXTURE = "/esoui/art/icons/alchemy/crafting_alchemy_trait_unstoppable_conflict.dds"
AUI_SCROLLING_TEXT_EXP_TEXTURE = "/esoui/art/icons/icon_experience.dds"
AUI_SCROLLING_TEXT_CXP_TEXTURE = "/esoui/art/champion/champion_points_health_icon-hud-32.dds"
AUI_SCROLLING_TEXT_AP_TEXTURE = "/esoui/art/icons/icon_alliancepoints.dds"
AUI_SCROLLING_TEXT_TELVAR_TEXTURE = "/esoui/art/icons/store_icdlc_rewards.dds"
AUI_SCROLLING_TEXT_ULTIMATE_TEXTURE = "/esoui/art/icons/store_icdlc_story.dds"
AUI_SCROLLING_TEXT_POTION_READY_TEXTURE = "/esoui/art/icons/quest_wine_001.dds"
AUI_SCROLLING_TEXT_COMBAT_START_TEXTURE = "/esoui/art/icons/alchemy/crafting_alchemy_trait_lowerweaponcrit_conflict.dds"
AUI_SCROLLING_TEXT_COMBAT_END_TEXTURE = "/esoui/art/icons/alchemy/crafting_alchemy_trait_lowerweaponcrit_match.dds"
AUI_SCROLLING_TEXT_INSTANT_CAST_TEXTURE = "/esoui/art/icons/store_tgdlc_maw_01.dds"
AUI_SCROLLING_TEXT_HEALTH_LOW_TEXTURE = "/esoui/art/icons/quest_gemstone_round_001.dds"
AUI_SCROLLING_TEXT_MAGICKA_LOW_TEXTURE = "/esoui/art/icons/quest_gemstone_round_002.dds"
AUI_SCROLLING_TEXT_STAMINA_LOW_TEXTURE = "/esoui/art/icons/quest_gemstone_round_003.dds"
AUI_SCROLLING_TEXT_HEALTH_REG_TEXTURE = "/esoui/art/icons/quest_gemstone_round_001.dds"
AUI_SCROLLING_TEXT_MAGICKA_REG_TEXTURE = "/esoui/art/icons/quest_gemstone_round_002.dds"
AUI_SCROLLING_TEXT_STAMINA_REG_TEXTURE = "/esoui/art/icons/quest_gemstone_round_003.dds"
AUI_SCROLLING_TEXT_HEALTH_DEREG_TEXTURE = "/esoui/art/icons/quest_gemstone_round_001.dds"
AUI_SCROLLING_TEXT_MAGICKA_DEREG_TEXTURE = "/esoui/art/icons/quest_gemstone_round_002.dds"
AUI_SCROLLING_TEXT_STAMINA_DEREG_TEXTURE = "/esoui/art/icons/quest_gemstone_round_003.dds"

local AUI_SCROLLING_TEXT_PANEL_COUNT = 3

local SCROLLING_TEXT_SCENE_FRAGMENT = nil

local g_isInit = false
local isPreviewShow = false
local assembledData = {}	
local panelList = {}

local function OnMouseDown(_eventCode, _button, _ctrl, _alt, _shift, _control)
	if _button == 1 and not AUI.Settings.Combat.lock_windows then
		_control:SetMovable(true)
		_control:StartMoving()
	end
end

local function OnMouseUp(_eventCode, _button, _ctrl, _alt, _shift, _control, _positionData)
	_control:SetMovable(false)

	if _button == 1 and not AUI.Settings.Combat.lock_windows then
		_, _positionData.point, _, _positionData.relativePoint, _positionData.offsetX, _positionData.offsetY = _control:GetAnchor()
	end
end

local function SetScrollingControlLayout(_control, _data)
	local size = _data.size or 0

	local width = size
	local Height = size
	local text = _data.text or ""
	local showIcon = _data.showIcons
	local iconTexture = _data.iconTexture
	local suffix = _data.suffix or ""
	local textColor = _data.textColor
	local fontArt = _data.fontArt or "ESO-FWNTLGUDC70 DB"
	
	local textControl = GetControl(_control, "_Text")
	local suffixControl = GetControl(_control, "_Suffix")
	local iconContainerControl = GetControl(_control, "_IconContainer")

	textControl:SetFont(fontArt .. "|" .. size .. "|" .. "soft-shadow-thick")
	textControl:SetText(text)
	
	if suffixControl then
		suffixControl:SetFont(fontArt .. "|" .. size - (size / 2.7) .. "|" .. "soft-shadow-thick")
		suffixControl:SetText(suffix)
	end		
	
	local textWidth, textHeight = textControl:GetTextDimensions() 
	width = textWidth
	
	if textColor then
		textControl:SetColor(textColor:UnpackRGBA())
	end	
	
	if iconContainerControl then
		local iconTextureControl = GetControl(iconContainerControl, "_Icon")
	
		if showIcon and iconTexture then
			iconContainerControl:SetHidden(false)
			iconContainerControl:SetDimensions(size + 6, size + 6)
			iconTextureControl:SetDimensions(size, size)
			iconTextureControl:SetTexture(iconTexture)
		else
			iconContainerControl:SetHidden(true)
			iconContainerControl:SetDimensions(0, 0)
			iconTextureControl:SetDimensions(0, 0)
			iconTextureControl:SetTexture("")			
		end	
		
		width = width + (size + 12)
	else
		width = width + size
	end
	
	_control:SetDimensions(width, size)
end

function AUI.Combat.Text.GetPanelList()
	return panelList
end

function AUI.Combat.Text.UpdateUI()
	if not g_isInit then
		return
	end	

	for _, data in pairs(panelList) do
		data.control:ClearAnchors()
		data.control:SetAnchor(AUI.Settings.Combat.scrolling_text_panel_positions[data.internName].point, GUIROOT, AUI.Settings.Combat.scrolling_text_panel_positions[data.internName].relativePoint, AUI.Settings.Combat.scrolling_text_panel_positions[data.internName].offsetX, AUI.Settings.Combat.scrolling_text_panel_positions[data.internName].offsetY)	

		data.control:SetHandler("OnMouseDown", function(_eventCode, _button, _ctrl, _alt, _shift) OnMouseDown(_eventCode, _button, _ctrl, _alt, _shift, data.control) end)
		data.control:SetHandler("OnMouseUp", function(_eventCode, _button, _ctrl, _alt, _shift) OnMouseUp(_eventCode, _button, _ctrl, _alt, _shift, data.control, AUI.Settings.Combat.scrolling_text_panel_positions[data.internName]) end)	
	
		data.control:SetDimensions(AUI.Settings.Combat.scrolling_text_panel_width[data.internName], AUI.Settings.Combat.scrolling_text_panel_height[data.internName])
	end		
end
	
function InsertAssembledData()		
	for panelType, list in pairs(assembledData) do	
		for scrollingTextType, data in pairs(list) do		
			if data.assemble and data.value then
				if data.assembleCount > 1 then
					data.text = AUI.String.ToFormatedNumber(data.value * data.assembleCount) .. " x" .. data.assembleCount	
				end
			end
			
			AUI.Animations.StartAnimation(data.controlName, data.panel, data.duration, data.animationType, data.animationMode, AUI_ALIGNMENT_TOPLEFT, data.size + 28, 0, 0, 0, 0, true, function(control) SetScrollingControlLayout(control, data) end)
			assembledData[panelType][scrollingTextType] = nil
		end
		assembledData[panelType] = nil
	end
end	
	
function AUI.Combat.Text.InsertMessage(_value, _scrollingTextType, _panelName, _iconTexture, _suffix)	
	if not g_isInit or not _panelName then
		return
	end	

	local data = {}

	if type(_value) == "number" then
		data.text = AUI.String.ToFormatedNumber(_value)
		data.value = _value
	elseif type(_value) == "string" then
		data.text = _value
	else
		return
	end
	
	local panelData = panelList[_panelName]
	
	data.assemble = false
	data.assembleCount = 0
	data.iconTexture = _iconTexture
	data.suffix = _suffix
	data.scrollingTextType = _scrollingTextType
	data.controlName = "AUI_Scrolling_Text_Control"
	data.panel = panelData.control
	data.panelName = _panelName
	data.showIcons = AUI.Settings.Combat.scrolling_text_panel_show_icons[_panelName]
	data.duration = AUI.Settings.Combat.scrolling_text_panel_duration[_panelName]
	data.animationType = AUI.Settings.Combat.scrolling_text_panel_animation[_panelName]
	data.animationMode = AUI.Settings.Combat.scrolling_text_panel_animation_mode[_panelName]		
	
	if data.duration then
		data.duration = data.duration * 1000
	else
		data.duration = 3000
	end

	if _scrollingTextType == AUI_SCROLLING_TEXT_DAMAGE_OUT then	
		data.size = AUI.Settings.Combat.scrolling_text_out_damage_normal_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_damage_out_color_normal)
		data.fontArt = AUI.Settings.Combat.scrolling_text_damage_out_normal_font_art
		if data.value and AUI.Settings.Combat.scrolling_text_assemble_damage_out_normal then
			data.assemble = true
		end			
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_CRIT_DAMAGE_OUT then
		data.size = AUI.Settings.Combat.scrolling_text_out_damage_crit_size	
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_damage_out_color_crit)
		data.fontArt = AUI.Settings.Combat.scrolling_text_damage_out_crit_font_art	
		if data.value and AUI.Settings.Combat.scrolling_text_assemble_damage_out_crit then
			data.assemble = true
		end			
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_HEAL_OUT then
		data.size = AUI.Settings.Combat.scrolling_text_out_heal_normal_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_heal_out_color_normal)
		data.fontArt = AUI.Settings.Combat.scrolling_text_heal_out_normal_font_art
		if data.value and AUI.Settings.Combat.scrolling_text_assemble_heal_out_normal then
			data.assemble = true
		end			
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_CRIT_HEAL_OUT then
		data.size = AUI.Settings.Combat.scrolling_text_out_heal_crit_size	
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_heal_out_color_crit)
		data.fontArt = AUI.Settings.Combat.scrolling_text_heal_out_crit_font_art		
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_DAMAGE_IN then
		data.size = AUI.Settings.Combat.scrolling_text_in_damage_normal_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_damage_in_color_normal)
		data.fontArt = AUI.Settings.Combat.scrolling_text_damage_in_normal_font_art
		if data.value and AUI.Settings.Combat.scrolling_text_assemble_damage_in_normal then
			data.assemble = true
		end			
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_CRIT_DAMAGE_IN then
		data.size = AUI.Settings.Combat.scrolling_text_in_damage_crit_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_damage_in_color_crit)
		data.fontArt = AUI.Settings.Combat.scrolling_text_damage_in_crit_font_art
		if data.value and AUI.Settings.Combat.scrolling_text_assemble_damage_in_crit then
			data.assemble = true
		end				
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_HEAL_IN then
		data.size = AUI.Settings.Combat.scrolling_text_in_heal_normal_size	
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_heal_in_color_normal)
		data.fontArt = AUI.Settings.Combat.scrolling_text_heal_in_normal_font_art	
		if data.value and AUI.Settings.Combat.scrolling_text_assemble_heal_in_normal then
			data.assemble = true
		end			
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_CRIT_HEAL_IN then
		data.size = AUI.Settings.Combat.scrolling_text_in_heal_crit_size	
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_heal_in_color_crit)
		data.fontArt = AUI.Settings.Combat.scrolling_text_heal_in_crit_font_art	
		if data.value and AUI.Settings.Combat.scrolling_text_assemble_heal_in_crit then
			data.assemble = true
		end				
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_EXP then			
		data.size = AUI.Settings.Combat.scrolling_text_exp_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_exp_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_exp_font_art
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_CXP then	
		data.size = AUI.Settings.Combat.scrolling_text_cxp_size	
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_cxp_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_cxp_font_art
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_AP then
		data.size = AUI.Settings.Combat.scrolling_text_ap_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_ap_color)	
		data.fontArt = AUI.Settings.Combat.scrolling_text_ap_font_art
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_TELVAR then
		data.size = AUI.Settings.Combat.scrolling_text_telvar_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_telvar_color)	
		data.fontArt = AUI.Settings.Combat.scrolling_text_telvar_font_art		
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_COMBAT_START then
		data.size = AUI.Settings.Combat.scrolling_text_combat_start_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_combat_start_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_combat_start_font_art
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_COMBAT_END then
		data.size = AUI.Settings.Combat.scrolling_text_combat_end_size	
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_combat_end_color)	
		data.fontArt = AUI.Settings.Combat.scrolling_text_combat_end_font_art
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_PROC then
		data.size = AUI.Settings.Combat.scrolling_text_instant_cast_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_instant_cast_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_instant_cast_font_art
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_ULTI_READY then
		data.size = AUI.Settings.Combat.scrolling_text_ultimate_ready_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_ultimate_ready_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_ultimate_ready_font_art
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_POTION_READY then
		data.size = AUI.Settings.Combat.scrolling_text_potion_ready_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_potion_ready_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_potion_ready_font_art	
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_HEALTH_LOW then
		data.size = AUI.Settings.Combat.scrolling_text_health_low_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_health_low_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_health_low_font_art					
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_MAGICKA_LOW then
		data.size = AUI.Settings.Combat.scrolling_text_magicka_low_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_magicka_low_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_magicka_low_font_art			
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_STAMINA_LOW then
		data.size = AUI.Settings.Combat.scrolling_text_stamina_low_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_stamina_low_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_stamina_low_font_art			
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_HEALTH_REG then
		data.size = AUI.Settings.Combat.scrolling_text_health_reg_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_health_reg_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_health_reg_font_art					
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_MAGICKA_REG then
		data.size = AUI.Settings.Combat.scrolling_text_magicka_reg_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_magicka_reg_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_magicka_reg_font_art			
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_STAMINA_REG then
		data.size = AUI.Settings.Combat.scrolling_text_stamina_reg_size
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_stamina_reg_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_stamina_reg_font_art			
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_HEALTH_DEREG then
		data.size = AUI.Settings.Combat.scrolling_text_health_dereg_size	
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_health_dereg_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_health_dereg_font_art					
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_MAGICKA_DEREG then
		data.size = AUI.Settings.Combat.scrolling_text_magicka_dereg_size	
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_magicka_dereg_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_magicka_dereg_font_art			
	elseif _scrollingTextType == AUI_SCROLLING_TEXT_STAMINA_DEREG then
		data.size = AUI.Settings.Combat.scrolling_text_stamina_dereg_size	
		data.textColor = AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_stamina_dereg_color)
		data.fontArt = AUI.Settings.Combat.scrolling_text_stamina_dereg_font_art			
	end	

	if data.assemble then	
		if not assembledData[_panelName] then
			assembledData[_panelName]= {}
		end	
	
		if not assembledData[_panelName][_scrollingTextType] then
			assembledData[_panelName][_scrollingTextType] = data
			assembledData[_panelName][_scrollingTextType].assembleCount = 1
		else
			if assembledData[_panelName][_scrollingTextType].value == data.value or _scrollingTextType == AUI_SCROLLING_TEXT_EXP or _scrollingTextType == AUI_SCROLLING_TEXT_CXP or _scrollingTextType == AUI_SCROLLING_TEXT_AP or _scrollingTextType == AUI_SCROLLING_TEXT_TELVAR then	
				assembledData[_panelName][_scrollingTextType].assembleCount = assembledData[_panelName][_scrollingTextType].assembleCount + 1
			end
		end
	else
		AUI.Animations.StartAnimation(data.controlName, data.panel, data.duration, data.animationType, data.animationMode, AUI_ALIGNMENT_TOPLEFT, data.size + 28, 0, 0, 0, 0, true, function(control) SetScrollingControlLayout(control, data) end)	
	end
end

function AUI.Combat.Text.GetPanelCount()
	return AUI_SCROLLING_TEXT_PANEL_COUNT
end

function AUI.Combat.Text.SetPanelToDefaultPosition(defaultSettings, panelName)
	if not g_isInit then
		return
	end

	local control = panelList[panelName].control
	if control then
		control:ClearAnchors()
		control:SetAnchor(defaultSettings.scrolling_text_panel_positions[panelName].point, GuiRoot, defaultSettings.scrolling_text_panel_positions[panelName].relativePoint, defaultSettings.scrolling_text_panel_positions[panelName].offsetX, defaultSettings.scrolling_text_panel_positions[panelName].offsetY)
		_, AUI.Settings.Combat.scrolling_text_panel_positions[panelName].point, _, AUI.Settings.Combat.scrolling_text_panel_positions[panelName].relativePoint, AUI.Settings.Combat.scrolling_text_panel_positions[panelName].offsetX, AUI.Settings.Combat.scrolling_text_panel_positions[panelName].offsetY = control:GetAnchor()
	end
end	

local function InsertPreviewMessages(_panelName)
	local duration = 100
	local increaser = 700

	if AUI.Settings.Combat.scrolling_text_show_damage_out and AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(1600, AUI_SCROLLING_TEXT_DAMAGE_OUT, AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName, AUI_SCROLLING_TEXT_DAMAGE_OUT_TEXTURE, AUI.L10n.GetString("damage"))
		end, duration)
		
		duration = duration + increaser
	end
	
	if AUI.Settings.Combat.scrolling_text_show_damage_out and AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(1600, AUI_SCROLLING_TEXT_DAMAGE_OUT, AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName, AUI_SCROLLING_TEXT_DAMAGE_OUT_TEXTURE, AUI.L10n.GetString("damage"))
		end, duration)
		
		duration = duration + increaser
	end

	if AUI.Settings.Combat.scrolling_text_show_critical_damage_out and AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(2500, AUI_SCROLLING_TEXT_CRIT_DAMAGE_OUT, AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName, AUI_SCROLLING_TEXT_CRIT_DAMAGE_OUT_TEXTURE, AUI.L10n.GetString("critical_damage"))
		end, duration)
	end	
	
	if AUI.Settings.Combat.scrolling_text_show_heal_out and AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(400, AUI_SCROLLING_TEXT_HEAL_OUT, AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName, AUI_SCROLLING_TEXT_HEAL_OUT_TEXTURE, AUI.L10n.GetString("healing"))
		end, duration)
		
		duration = duration + increaser
	end
	
	if AUI.Settings.Combat.scrolling_text_show_critical_heal_out and AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(750, AUI_SCROLLING_TEXT_CRIT_HEAL_OUT, AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName, AUI_SCROLLING_TEXT_CRIT_HEAL_OUT_TEXTURE, AUI.L10n.GetString("critical_healing"))
		end, duration)
		
		duration = duration + increaser
	end	
	
	if AUI.Settings.Combat.scrolling_text_show_damage_in and AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(1600, AUI_SCROLLING_TEXT_DAMAGE_IN, AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName, AUI_SCROLLING_TEXT_DAMAGE_IN_TEXTURE, AUI.L10n.GetString("damage"))	
		end, duration)
		
		duration = duration + increaser
	end
	
	if AUI.Settings.Combat.scrolling_text_show_critical_damage_in and AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(2500, AUI_SCROLLING_TEXT_CRIT_DAMAGE_IN, AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName, AUI_SCROLLING_TEXT_CRIT_DAMAGE_IN_TEXTURE, AUI.L10n.GetString("critical_damage"))	
		end, duration)
		
		duration = duration + increaser
	end	
	
	if AUI.Settings.Combat.scrolling_text_show_heal_in and AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(400, AUI_SCROLLING_TEXT_HEAL_IN, AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName, AUI_SCROLLING_TEXT_HEAL_IN_DAMAGE_OUT_TEXTURE, AUI.L10n.GetString("healing"))
		end, duration)
		
		duration = duration + increaser
	end
	
	if AUI.Settings.Combat.scrolling_text_show_critical_heal_in and AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.String.ToFormatedNumber(750), AUI_SCROLLING_TEXT_CRIT_HEAL_IN, AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName, AUI_SCROLLING_TEXT_CRIT_HEAL_IN_TEXTURE,  AUI.L10n.GetString("critical_healing"))
		end, duration)
		
		duration = duration + increaser
	end	
	
	if AUI.Settings.Combat.scrolling_text_show_exp and AUI.Settings.Combat.scrolling_text_exp_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.String.ToFormatedNumber(600) .. " EXP", AUI_SCROLLING_TEXT_EXP, AUI.Settings.Combat.scrolling_text_exp_parent_panelName, AUI_SCROLLING_TEXT_EXP_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end
	
	if AUI.Settings.Combat.scrolling_text_show_cxp and AUI.Settings.Combat.scrolling_text_cxp_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.String.ToFormatedNumber(600) .. " CXP", AUI_SCROLLING_TEXT_CXP, AUI.Settings.Combat.scrolling_text_cxp_parent_panelName, AUI_SCROLLING_TEXT_CXP_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end	
	
	if AUI.Settings.Combat.scrolling_text_show_ap and AUI.Settings.Combat.scrolling_text_ap_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.String.ToFormatedNumber(150) .. " AP", AUI_SCROLLING_TEXT_AP, AUI.Settings.Combat.scrolling_text_ap_parent_panelName, AUI_SCROLLING_TEXT_AP_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end
	
	if AUI.Settings.Combat.scrolling_text_show_telvar and AUI.Settings.Combat.scrolling_text_telvar_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.String.ToFormatedNumber(8) .. " Tel'Var", AUI_SCROLLING_TEXT_TELVAR, AUI.Settings.Combat.scrolling_text_telvar_parent_panelName, AUI_SCROLLING_TEXT_TELVAR_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end	
	
	if AUI.Settings.Combat.scrolling_text_show_combat_start and AUI.Settings.Combat.scrolling_text_combat_start_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("combat_start"), AUI_SCROLLING_TEXT_COMBAT_START, AUI.Settings.Combat.scrolling_text_combat_start_parent_panelName, AUI_SCROLLING_TEXT_COMBAT_START_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end
	
	if AUI.Settings.Combat.scrolling_text_show_combat_end and AUI.Settings.Combat.scrolling_text_combat_end_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("combat_end"), AUI_SCROLLING_TEXT_COMBAT_END, AUI.Settings.Combat.scrolling_text_combat_end_panelName, AUI_SCROLLING_TEXT_COMBAT_END_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end
	
	if AUI.Settings.Combat.scrolling_text_show_instant_casts and AUI.Settings.Combat.scrolling_text_instant_cast_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("ability_proc_name"), AUI_SCROLLING_TEXT_PROC, AUI.Settings.Combat.scrolling_text_instant_cast_parent_panelName, AUI_SCROLLING_TEXT_INSTANT_CAST_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end	
	
	if AUI.Settings.Combat.scrolling_text_show_ultimate_ready and AUI.Settings.Combat.scrolling_text_ultimate_ready_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("ultimate_ready"), AUI_SCROLLING_TEXT_ULTI_READY, AUI.Settings.Combat.scrolling_text_ultimate_ready_parent_panelName, AUI_SCROLLING_TEXT_ULTIMATE_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end	
	
	if AUI.Settings.Combat.scrolling_text_show_potion_ready and AUI.Settings.Combat.scrolling_text_potion_ready_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("potion_ready"), AUI_SCROLLING_TEXT_POTION_READY, AUI.Settings.Combat.scrolling_text_potion_ready_parent_panelName, AUI_SCROLLING_TEXT_POTION_READY_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end		
	
	if AUI.Settings.Combat.scrolling_text_show_health_low and AUI.Settings.Combat.scrolling_text_health_low_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("health_low"), AUI_SCROLLING_TEXT_HEALTH_LOW, AUI.Settings.Combat.scrolling_text_health_low_parent_panelName, AUI_SCROLLING_TEXT_HEALTH_LOW_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end		
	
	if AUI.Settings.Combat.scrolling_text_show_magicka_low and AUI.Settings.Combat.scrolling_text_magicka_low_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("magicka_low"), AUI_SCROLLING_TEXT_MAGICKA_LOW, AUI.Settings.Combat.scrolling_text_magicka_low_parent_panelName, AUI_SCROLLING_TEXT_MAGICKA_LOW_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end		

	if AUI.Settings.Combat.scrolling_text_show_stamina_low and AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("stamina_low"), AUI_SCROLLING_TEXT_STAMINA_LOW, AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName, AUI_SCROLLING_TEXT_STAMINA_LOW_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end	
	
	if AUI.Settings.Combat.scrolling_text_show_health_reg and AUI.Settings.Combat.scrolling_text_health_reg_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage("+ " .. AUI.String.ToFormatedNumber(164) .. " " ..  AUI.L10n.GetString("health"), AUI_SCROLLING_TEXT_HEALTH_REG, AUI.Settings.Combat.scrolling_text_health_reg_parent_panelName, AUI_SCROLLING_TEXT_HEALTH_REG_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end		
	
	if AUI.Settings.Combat.scrolling_text_show_magicka_reg and AUI.Settings.Combat.scrolling_text_magicka_reg_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage("+ " .. AUI.String.ToFormatedNumber(164) .. " " ..  AUI.L10n.GetString("magicka"), AUI_SCROLLING_TEXT_MAGICKA_REG, AUI.Settings.Combat.scrolling_text_magicka_reg_parent_panelName, AUI_SCROLLING_TEXT_MAGICKA_REG_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end		

	if AUI.Settings.Combat.scrolling_text_show_stamina_reg and AUI.Settings.Combat.scrolling_text_stamina_reg_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage("+ " .. AUI.String.ToFormatedNumber(164) .. " " ..  AUI.L10n.GetString("stamina"), AUI_SCROLLING_TEXT_STAMINA_REG, AUI.Settings.Combat.scrolling_text_stamina_reg_parent_panelName, AUI_SCROLLING_TEXT_STAMINA_REG_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end	
	
	if AUI.Settings.Combat.scrolling_text_show_health_dereg and AUI.Settings.Combat.scrolling_text_health_dereg_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage("- " .. AUI.String.ToFormatedNumber(98) .. " " ..  AUI.L10n.GetString("health"), AUI_SCROLLING_TEXT_HEALTH_DEREG, AUI.Settings.Combat.scrolling_text_health_dereg_parent_panelName, AUI_SCROLLING_TEXT_HEALTH_DEREG_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end
	
	if AUI.Settings.Combat.scrolling_text_show_magicka_dereg and AUI.Settings.Combat.scrolling_text_magicka_dereg_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end		
		
			AUI.Combat.Text.InsertMessage("- " .. AUI.String.ToFormatedNumber(98) .. " " ..  AUI.L10n.GetString("magicka"), AUI_SCROLLING_TEXT_MAGICKA_DEREG, AUI.Settings.Combat.scrolling_text_magicka_dereg_parent_panelName, AUI_SCROLLING_TEXT_MAGICKA_DEREG_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end		

	if AUI.Settings.Combat.scrolling_text_show_stamina_dereg and AUI.Settings.Combat.scrolling_text_stamina_dereg_parent_panelName == _panelName then
		zo_callLater(function()
			if not isPreviewShow then
				return
			end
			
			AUI.Combat.Text.InsertMessage("- " .. AUI.String.ToFormatedNumber(98) .. " " ..  AUI.L10n.GetString("stamina"), AUI_SCROLLING_TEXT_STAMINA_DEREG, AUI.Settings.Combat.scrolling_text_stamina_dereg_parent_panelName, AUI_SCROLLING_TEXT_STAMINA_DEREG_TEXTURE)
		end, duration)
		
		duration = duration + increaser
	end		
end

function AUI.Combat.Text.UpdatePreview(_panelName)	
	if not g_isInit then
		return
	end

	if isPreviewShow and _panelName then
		local panelData = panelList[_panelName]
	
		AUI.Animations.RemoveFrom(panelData.control)

		zo_callLater(function()
			InsertPreviewMessages(_panelName)	
		end, 200)
		
		EVENT_MANAGER:UnregisterForUpdate("AUI_UPDATE_SCROLLING_TEXT_PREVIEW" .. _panelName) 	
		EVENT_MANAGER:RegisterForUpdate("AUI_UPDATE_SCROLLING_TEXT_PREVIEW" .. _panelName, 6000, function() if isPreviewShow then InsertPreviewMessages(_panelName) end end)			
	end
end

function AUI.Combat.Text.ShowPreview()
	if not g_isInit then
		return
	end

	isPreviewShow = true
	
	AUI_Scrolling_Text:SetHidden(false)
		
	for _, panelData in pairs(panelList) do
		local bgControl = GetControl(panelData.control, "_Container")	
		bgControl:SetHidden(false)
		panelData.control:SetMouseEnabled(true)

		AUI.Combat.Text.UpdatePreview(panelData.internName)
	end	
	
	SCROLLING_TEXT_SCENE_FRAGMENT.hiddenReasons:SetHiddenForReason("ShouldntShow", true)	
end

function AUI.Combat.Text.HidePreview()
	if not g_isInit then
		return
	end

	AUI_Scrolling_Text:SetHidden(true)	
	
	for panelName, panelData in pairs(panelList) do
		EVENT_MANAGER:UnregisterForUpdate("AUI_UPDATE_SCROLLING_TEXT_PREVIEW" .. panelName)
	
		local bgControl = GetControl(panelData.control, "_Container")	
		bgControl:SetHidden(true)
		panelData.control:SetMouseEnabled(false)

		AUI.Animations.RemoveFrom(panelData.control)	
	end		

	SCROLLING_TEXT_SCENE_FRAGMENT.hiddenReasons:SetHiddenForReason("ShouldntShow", false)
		
	isPreviewShow = false
end

function AUI.Combat.Text.AddSctPanel(_panelName, _internName, _width, _height, _anchorData, _showIcons, _animationType, _animationMode, _animationTime)
	if not _panelName or not _internName or not _width or not _height or not _anchorData or not _showIcons or not _animationType or not _animationMode or not _animationTime or panelList[_internName] then
		return
	end

	local panelControl = CreateControlFromVirtual("AUI_Scrolling_Text_Panel", AUI_Scrolling_Text, "AUI_Scrolling_Text_Panel", _panelName)

	local panelData = {
		["name"] = _panelName,
		["internName"] = _internName,
		["control"] = panelControl,
		["width"] = _width,
		["height"] = _height,
		["anchorData"] = _anchorData,
		["showIcons"] = _showIcons,
		["animationType"] = _animationType,
		["animationMode"] = _animationMode,
		["animationTime"] = _animationTime,		
	}

	local containerControl = GetControl(panelControl, "_Container")
	
	local textControl = GetControl(containerControl, "_Text")
	if textControl then
		textControl:SetText(panelData.name)
	end	

	panelList[_internName] = panelData
end

function AUI.Combat.Text.Load()
	if g_isInit then
		return
	end

	g_isInit = true	
	
	SCROLLING_TEXT_SCENE_FRAGMENT = ZO_SimpleSceneFragment:New(AUI_Scrolling_Text)	
	SCROLLING_TEXT_SCENE_FRAGMENT.hiddenReasons = ZO_HiddenReasons:New()		
    SCROLLING_TEXT_SCENE_FRAGMENT:SetConditional(function()
        return not SCROLLING_TEXT_SCENE_FRAGMENT.hiddenReasons:IsHidden()
    end)		
	
	HUD_SCENE:AddFragment(SCROLLING_TEXT_SCENE_FRAGMENT)
	HUD_UI_SCENE:AddFragment(SCROLLING_TEXT_SCENE_FRAGMENT)
	SIEGE_BAR_SCENE:AddFragment(SCROLLING_TEXT_SCENE_FRAGMENT)
	if SIEGE_BAR_UI_SCENE then
		SIEGE_BAR_UI_SCENE:AddFragment(SCROLLING_TEXT_SCENE_FRAGMENT)
	end	
	
	AUI.Combat.Text.UpdateUI()
	
	EVENT_MANAGER:RegisterForUpdate("AUI_UPDATE_SCROLLING_TEXT_INSERT_ASSEMBELD_DATA", 100, InsertAssembledData)
end