AUI.Settings.UnitFrames = {}

local g_LAM = LibAddonMenu2
local g_isInit = false
local g_changedEnabled = false
local g_changedTemplate = false
local g_isPreviewShowing = false

local g_player_unit_frames_enabled = false
local g_target_unit_frames_enabled = false
local g_group_unit_frames_enabled = false
local g_boss_unit_frames_enabled = false
local g_companion_unit_frames_enabled = false

local g_player_unit_frames_Template = nil
local g_target_unit_frames_Template = nil
local g_group_unit_frames_Template = nil
local g_raid_unit_frames_Template = nil
local g_boss_unit_frames_Template = nil
local g_companion_unit_frames_Template = nil

local function GetActivePlayerTemplateName()
	local templateData = AUI.UnitFrames.GetActivePlayerTemplateData()

	if not templateData then
		return nil
	end

	return templateData.internName
end

local function GetActiveTargetTemplateName()
	local templateData = AUI.UnitFrames.GetActiveTargetTemplateData()

	if not templateData then
		return nil
	end

	return templateData.internName
end

local function GetActiveGroupTemplateName()
	local templateData = AUI.UnitFrames.GetActiveGroupTemplateData()

	if not templateData then
		return nil
	end

	return templateData.internName
end

local function GetActiveRaidTemplateName()
	local templateData = AUI.UnitFrames.GetActiveRaidTemplateData()

	if not templateData then
		return nil
	end

	return templateData.internName
end

local function GetActiveBossTemplateName()
	local templateData = AUI.UnitFrames.GetActiveBossTemplateData()

	if not templateData then
		return nil
	end

	return templateData.internName
end

local function GetActiveCompanionTemplateName()
	local templateData = AUI.UnitFrames.GetActiveCompanionTemplateData()

	if not templateData then
		return nil
	end

	return templateData.internName
end

local function GetFrameDefaultSettings(_type, _templateData)
	local data = {}

	if _templateData.control then
		data.width = _templateData.control.defaultWidth
		data.height = _templateData.control.defaultHeight
	end

	if data.width == 0 then
		data.width = nil
	end	
	
	if data.height == 0 then
		data.height = nil
	end		
	
	if not _templateData["default_settings"] then
		_templateData["default_settings"] = {}
	end
	
	data.display = _templateData["default_settings"].display or true

	if _type == AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH then
		data.show_always = _templateData["default_settings"].show_always or false
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})	
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text ~= false or false
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 14
		data.font_style = _templateData["default_settings"].font_style or "outline"	
		data.show_increase_regen_color = _templateData["default_settings"].show_increase_regen_color ~= false or false
		data.show_decrease_regen_color = _templateData["default_settings"].show_decrease_regen_color ~= false or false	
		data.show_increase_regen_effect = _templateData["default_settings"].show_increase_regen_effect ~= false or false	
		data.show_decrease_regen_effect = _templateData["default_settings"].show_decrease_regen_effect ~= false or false	
		data.show_increase_armor_effect = _templateData["default_settings"].show_increase_armor_effect ~= false or false	
		data.show_decrease_armor_effect = _templateData["default_settings"].show_decrease_armor_effect ~= false or false		
		data.show_increase_power_effect = _templateData["default_settings"].show_increase_power_effect ~= false or false	
		data.show_decrease_power_effect = _templateData["default_settings"].show_decrease_power_effect ~= false or false		
	elseif _type == AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA then
		data.show_always = _templateData["default_settings"].show_always or false
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#001f61"), AUI.Color.ConvertHexToRGBA("#003bbb")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text ~= false or false	
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 14
		data.font_style = _templateData["default_settings"].font_style or "outline"			
	elseif _type == AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA then
		data.show_always = _templateData["default_settings"].show_always or false
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#024600"), AUI.Color.ConvertHexToRGBA("#365f00")})	
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text ~= false or false
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false		
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 14
		data.font_style = _templateData["default_settings"].font_style or "outline"		
	elseif _type == AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#384800"), AUI.Color.ConvertHexToRGBA("#4d6300")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == true or false		
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false		
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 12
		data.font_style = _templateData["default_settings"].font_style or "outline"			
	elseif _type == AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#653300"), AUI.Color.ConvertHexToRGBA("#84461a")})		
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == true or false							
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false	
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 12
		data.font_style = _templateData["default_settings"].font_style or "outline"				
	elseif _type == AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})	
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == true or false						
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false		
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 15
		data.font_style = _templateData["default_settings"].font_style or "outline"				
	elseif _type == AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#034a6f")})	
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == true or false			
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false				
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"			
	elseif _type == AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})		
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.bar_companion_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#123c00"), AUI.Color.ConvertHexToRGBA("#237101")})
		data.bar_friendly_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#123c00"), AUI.Color.ConvertHexToRGBA("#237101")})
		data.bar_allied_npc_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#123c00"), AUI.Color.ConvertHexToRGBA("#237101")})
		data.bar_allied_player_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#002f3a"), AUI.Color.ConvertHexToRGBA("#004961")})
		data.bar_neutral_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#533e02"), AUI.Color.ConvertHexToRGBA("#958403")})	
		data.bar_guard_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#252221"), AUI.Color.ConvertHexToRGBA("#3b3736")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text ~= false or false			
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].show_percent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false			
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 15
		data.font_style = _templateData["default_settings"].font_style or "outline"
		data.show_account_name = _templateData["default_settings"].show_account_name or true
		data.caption_mode = _templateData["default_settings"].caption_mode or AUI_UNIT_FRAMES_MODE_CHARACTER_NAME_TITLE
		data.show_increase_regen_color = _templateData["default_settings"].show_increase_regen_color ~= false or false
		data.show_decrease_regen_color = _templateData["default_settings"].show_decrease_regen_color ~= false or false	
		data.show_increase_regen_effect = _templateData["default_settings"].show_increase_regen_effect ~= false or false	
		data.show_decrease_regen_effect = _templateData["default_settings"].show_decrease_regen_effect ~= false or false	
		data.show_increase_armor_effect = _templateData["default_settings"].show_increase_armor_effect ~= false or false	
		data.show_decrease_armor_effect = _templateData["default_settings"].show_decrease_armor_effect ~= false or false		
		data.show_increase_power_effect = _templateData["default_settings"].show_increase_power_effect ~= false or false	
		data.show_decrease_power_effect = _templateData["default_settings"].show_decrease_power_effect ~= false or false			
	elseif _type == AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_SHIELD then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#034a6f")})	
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == true or false	
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false		
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 15
		data.font_style = _templateData["default_settings"].font_style or "outline"		
	elseif _type == AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})		
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.bar_companion_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#123c00"), AUI.Color.ConvertHexToRGBA("#237101")})
		data.bar_friendly_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#123c00"), AUI.Color.ConvertHexToRGBA("#237101")})
		data.bar_allied_npc_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#123c00"), AUI.Color.ConvertHexToRGBA("#237101")})
		data.bar_allied_player_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#002f3a"), AUI.Color.ConvertHexToRGBA("#004961")})
		data.bar_neutral_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#533e02"), AUI.Color.ConvertHexToRGBA("#958403")})	
		data.bar_guard_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#252221"), AUI.Color.ConvertHexToRGBA("#3b3736")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text ~= false or false				
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].show_percent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false		
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 15
		data.font_style = _templateData["default_settings"].font_style or "outline"
		data.show_account_name = _templateData["default_settings"].show_account_name or true
		data.caption_mode = _templateData["default_settings"].caption_mode or AUI_UNIT_FRAMES_MODE_CHARACTER_NAME_TITLE		
		data.show_increase_regen_color = _templateData["default_settings"].show_increase_regen_color ~= false or false
		data.show_decrease_regen_color = _templateData["default_settings"].show_decrease_regen_color ~= false or false	
		data.show_increase_regen_effect = _templateData["default_settings"].show_increase_regen_effect ~= false or false	
		data.show_decrease_regen_effect = _templateData["default_settings"].show_decrease_regen_effect ~= false or false	
		data.show_increase_armor_effect = _templateData["default_settings"].show_increase_armor_effect ~= false or false	
		data.show_decrease_armor_effect = _templateData["default_settings"].show_decrease_armor_effect ~= false or false		
		data.show_increase_power_effect = _templateData["default_settings"].show_increase_power_effect ~= false or false	
		data.show_decrease_power_effect = _templateData["default_settings"].show_decrease_power_effect ~= false or false			
	elseif _type == AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_SHIELD then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#034a6f")})			
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == true or false	
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false	
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 12
		data.font_style = _templateData["default_settings"].font_style or "outline"		
	elseif _type == AUI_UNIT_FRAME_TYPE_GROUP_HEALTH then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})	
		data.bar_color_tank = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_tank) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#0f4d00"), AUI.Color.ConvertHexToRGBA("#297500")})
		data.bar_color_healer = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_healer) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#c96700"), AUI.Color.ConvertHexToRGBA("#b7742c")})
		data.bar_color_dd = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dd) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})			
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.out_of_range_opacity = 0.5		
		data.show_text = _templateData["default_settings"].show_text ~= false or false	
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 12
		data.font_style = _templateData["default_settings"].font_style or "outline"	
		data.show_account_name = _templateData["default_settings"].show_account_name or true
		data.row_distance = _templateData["default_settings"].row_distance or 42
		data.row_count = _templateData["default_settings"].row_count or 4
		data.show_increase_regen_color = _templateData["default_settings"].show_increase_regen_color ~= false or false
		data.show_decrease_regen_color = _templateData["default_settings"].show_decrease_regen_color ~= false or false	
		data.show_increase_regen_effect = _templateData["default_settings"].show_increase_regen_effect ~= false or false	
		data.show_decrease_regen_effect = _templateData["default_settings"].show_decrease_regen_effect ~= false or false	
		data.show_increase_armor_effect = _templateData["default_settings"].show_increase_armor_effect ~= false or false	
		data.show_decrease_armor_effect = _templateData["default_settings"].show_decrease_armor_effect ~= false or false		
		data.show_increase_power_effect = _templateData["default_settings"].show_increase_power_effect ~= false or false	
		data.show_decrease_power_effect = _templateData["default_settings"].show_decrease_power_effect ~= false or false	
	elseif _type == AUI_UNIT_FRAME_TYPE_GROUP_COMPANION then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#123c00"), AUI.Color.ConvertHexToRGBA("#237101")})				
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.out_of_range_opacity = 0.5		
		data.show_text = _templateData["default_settings"].show_text ~= false or false	
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"	
		data.show_increase_regen_color = _templateData["default_settings"].show_increase_regen_color ~= false or false
		data.show_decrease_regen_color = _templateData["default_settings"].show_decrease_regen_color ~= false or false	
		data.show_increase_regen_effect = _templateData["default_settings"].show_increase_regen_effect ~= false or false	
		data.show_decrease_regen_effect = _templateData["default_settings"].show_decrease_regen_effect ~= false or false	
		data.show_increase_armor_effect = _templateData["default_settings"].show_increase_armor_effect ~= false or false	
		data.show_decrease_armor_effect = _templateData["default_settings"].show_decrease_armor_effect ~= false or false		
		data.show_increase_power_effect = _templateData["default_settings"].show_increase_power_effect ~= false or false	
		data.show_decrease_power_effect = _templateData["default_settings"].show_decrease_power_effect ~= false or false		
	elseif _type == AUI_UNIT_FRAME_TYPE_GROUP_SHIELD then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#013753")})
		data.opacity = _templateData["default_settings"].opacity or 1
		data.out_of_range_opacity = _templateData["default_settings"].out_of_range_opacity or 0.5	
		data.show_text = _templateData["default_settings"].show_text == true or false
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false	
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"	
	elseif _type == AUI_UNIT_FRAME_TYPE_RAID_HEALTH then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})
		data.bar_color_tank = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_tank) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#0f4d00"), AUI.Color.ConvertHexToRGBA("#297500")})
		data.bar_color_healer = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_healer) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#c96700"), AUI.Color.ConvertHexToRGBA("#b7742c")})
		data.bar_color_dd = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dd) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})			
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.out_of_range_opacity = 0.5	
		data.show_text = _templateData["default_settings"].show_text ~= false or false
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false	
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"	
		data.show_account_name = _templateData["default_settings"].show_account_name or true
		data.row_distance = _templateData["default_settings"].row_distance or 12
		data.column_distance = _templateData["default_settings"].column_distance or 12			
		data.row_count = _templateData["default_settings"].row_count or 4
		data.show_increase_regen_color = _templateData["default_settings"].show_increase_regen_color ~= false or false
		data.show_decrease_regen_color = _templateData["default_settings"].show_decrease_regen_color ~= false or false	
		data.show_increase_regen_effect = _templateData["default_settings"].show_increase_regen_effect ~= false or false	
		data.show_decrease_regen_effect = _templateData["default_settings"].show_decrease_regen_effect ~= false or false	
		data.show_increase_armor_effect = _templateData["default_settings"].show_increase_armor_effect ~= false or false	
		data.show_decrease_armor_effect = _templateData["default_settings"].show_decrease_armor_effect ~= false or false		
		data.show_increase_power_effect = _templateData["default_settings"].show_increase_power_effect ~= false or false	
		data.show_decrease_power_effect = _templateData["default_settings"].show_decrease_power_effect ~= false or false			
	elseif _type == AUI_UNIT_FRAME_TYPE_RAID_SHIELD then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#034a6f")})
		data.opacity = _templateData["default_settings"].opacity or 1
		data.out_of_range_opacity = 0.5	
		data.show_text = _templateData["default_settings"].show_text == true or false
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"			
	elseif _type == AUI_UNIT_FRAME_TYPE_RAID_COMPANION then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#123c00"), AUI.Color.ConvertHexToRGBA("#237101")})				
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.out_of_range_opacity = 0.5		
		data.show_text = _templateData["default_settings"].show_text ~= false or false	
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"	
		data.show_increase_regen_color = _templateData["default_settings"].show_increase_regen_color ~= false or false
		data.show_decrease_regen_color = _templateData["default_settings"].show_decrease_regen_color ~= false or false	
		data.show_increase_regen_effect = false	
		data.show_decrease_regen_effect = false	
		data.show_increase_armor_effect = false	
		data.show_decrease_armor_effect = false		
		data.show_increase_power_effect = false	
		data.show_decrease_power_effect = false		
	elseif _type == AUI_UNIT_FRAME_TYPE_BOSS_HEALTH then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})		
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text ~= false or false
		data.show_max_value = _templateData["default_settings"].show_max_value ~= false or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"	
		data.row_distance = _templateData["default_settings"].row_distance or 8
		data.column_distance = _templateData["default_settings"].column_distance or 12		
		data.row_count = _templateData["default_settings"].row_count or 6
		data.show_increase_regen_color = _templateData["default_settings"].show_increase_regen_color ~= false or false
		data.show_decrease_regen_color = _templateData["default_settings"].show_decrease_regen_color ~= false or false	
		data.show_increase_regen_effect = _templateData["default_settings"].show_increase_regen_effect ~= false or false	
		data.show_decrease_regen_effect = _templateData["default_settings"].show_decrease_regen_effect ~= false or false	
		data.show_increase_armor_effect = _templateData["default_settings"].show_increase_armor_effect ~= false or false	
		data.show_decrease_armor_effect = _templateData["default_settings"].show_decrease_armor_effect ~= false or false		
		data.show_increase_power_effect = _templateData["default_settings"].show_increase_power_effect ~= false or false	
		data.show_decrease_power_effect = _templateData["default_settings"].show_decrease_power_effect ~= false or false				
	elseif _type == AUI_UNIT_FRAME_TYPE_BOSS_SHIELD then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#034a6f")})
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == true or false
		data.show_max_value = _templateData["default_settings"].show_max_value ~= false or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"	
	elseif _type == AUI_UNIT_FRAME_TYPE_COMPANION then
		data.bar_alignment = _templateData["default_settings"].bar_alignment or BAR_ALIGNMENT_NORMAL
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#123c00"), AUI.Color.ConvertHexToRGBA("#237101")})				
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.out_of_range_opacity = 0.5		
		data.show_text = _templateData["default_settings"].show_text ~= false or false	
		data.show_max_value = _templateData["default_settings"].show_max_value == true or false
		data.showPercent = _templateData["default_settings"].showPercent ~= false or false
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal ~= false or false
		data.font_art = _templateData["default_settings"].font_art or "AUI/fonts/SansitaOne.slug"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"	
		data.show_increase_regen_color = _templateData["default_settings"].show_increase_regen_color ~= false or false
		data.show_decrease_regen_color = _templateData["default_settings"].show_decrease_regen_color ~= false or false	
		data.show_increase_regen_effect = _templateData["default_settings"].show_increase_regen_effect ~= false or false	
		data.show_decrease_regen_effect = _templateData["default_settings"].show_decrease_regen_effect ~= false or false	
		data.show_increase_armor_effect = _templateData["default_settings"].show_increase_armor_effect ~= false or false	
		data.show_decrease_armor_effect = _templateData["default_settings"].show_decrease_armor_effect ~= false or false		
		data.show_increase_power_effect = _templateData["default_settings"].show_increase_power_effect ~= false or false	
		data.show_decrease_power_effect = _templateData["default_settings"].show_decrease_power_effect ~= false or false		
	end

	return data
end

local function GetDefaultSettings()
	local defaultData =
	{
		lock_windows = false,
	
		player_unit_frames_enabled = true,					
		target_unit_frames_enabled = true,
		group_unit_frames_enabled = true,	
		raid_unit_frames_enabled = true,	
		boss_unit_frames_enabled = true,
		companion_unit_frames_enabled = false,
		
		boss_game_default_frame_show_text = true,
		boss_game_default_frame_font_size = 16,
		boss_game_default_frame_font_art = "AUI/fonts/SansitaOne.slug",
		boss_game_default_frame_use_thousand_seperator = true,
	}
	
	local templates = AUI.UnitFrames.GetActiveTemplates()

	for _, templateData in pairs(templates) do
		for frameType, data in pairs(templateData.frameData) do
			if data.control and data.control.templateType then
				if not defaultData[data.control.templateType] then
					defaultData[data.control.templateType] = {}
				end
			
				if not defaultData[data.control.templateType][data.control.templateName] then
					defaultData[data.control.templateType][data.control.templateName] = {}
				end			
			
				defaultData[data.control.templateType][data.control.templateName][frameType] = GetFrameDefaultSettings(frameType, templateData.frameData[frameType])
			end
		end	
	end	
	
	return defaultData
end

local function GetDefaultSettingFromType(_type)
	local templates = AUI.UnitFrames.GetActiveTemplates()
	for templateType, templateData in pairs(templates) do
		for frameType, data in pairs(templateData.frameData) do
			if data.control and frameType == _type then
				return GetDefaultSettings()[data.control.templateType][data.control.templateName][frameType]
			end	
		end	
	end
end

local function SetFrameSettings()
	local templates = AUI.UnitFrames.GetActiveTemplates()
	for _, templateData in pairs(templates) do
		for frameType, data in pairs(templateData.frameData) do
			if data.control then
				if data.control.frames then
					for _, frame in pairs(data.control.frames) do
						if frame.templateType then
							frame.settings = AUI.Settings.UnitFrames[frame.templateType][frame.templateName][frameType]
						end
					end
				else
					data.control.settings = AUI.Settings.UnitFrames[data.control.templateType][data.control.templateName][frameType]
				end
			end
		end	
	end
end

local function SetAnchors()
	local templates = AUI.UnitFrames.GetActiveTemplates()
	for _, templateData in pairs(templates) do
		for frameType, data in pairs(templateData.frameData) do
			if data.control and data.control.templateType then
				local relativeToFrameType = nil
				local anchorData = AUI.Settings.UnitFrames[data.control.templateType][data.control.templateName][frameType].anchor_data	
				
				if data.control.relativeTo then
					if anchorData and not anchorData.customPos then
						relativeToFrameType = templateData.frameData[data.control.relativeTo].control
					elseif not anchorData then
						relativeToFrameType = templateData.frameData[data.control.relativeTo].control
					end
				end					

				if not anchorData then
					AUI.Settings.UnitFrames[data.control.templateType][data.control.templateName][frameType].anchor_data = AUI.Table.Copy(data.control.defaultAnchor)
					AUI.Settings.UnitFrames[data.control.templateType][data.control.templateName][frameType].anchor_data.customPos = false
					anchorData = AUI.Settings.UnitFrames[data.control.templateType][data.control.templateName][frameType].anchor_data	
				end
				
				data.control:ClearAnchors()
				if anchorData[0] then	
					data.control:SetAnchor(anchorData[0].point, relativeToFrameType or GuiRoot, anchorData[0].relativePoint, anchorData[0].offsetX, anchorData[0].offsetY)
				end
					
				if anchorData[1] and anchorData[1].point ~= NONE then
					data.control:SetAnchor(anchorData[1].point, relativeToFrameType or GuiRoot, anchorData[1].relativePoint, anchorData[1].offsetX, anchorData[1].offsetY)
				end
			end
		end	
	end
end

local function SetToDefaultPosition()
	local templates = AUI.UnitFrames.GetActiveTemplates()
	for templateType, templateData in pairs(templates) do
		for frameType, data in pairs(templateData.frameData) do
			AUI.Settings.UnitFrames[templateType][templateData.internName][frameType].anchor_data = AUI.Table.Copy(data.control.defaultAnchor)
			
			if AUI.UnitFrames.IsPlayer() then
				AUI.Settings.UnitFrames[templateType][templateData.internName][frameType].anchor_data.customPos = false;
			end
		end	
	end
	
	SetAnchors()
end

local function IsSettingDisabled(_type, _setting)
	local templates = AUI.UnitFrames.GetActiveTemplates()
	for templateType, templateData in pairs(templates) do
		for frameType, data in pairs(templateData.frameData) do
			if frameType == _type then
				if data.disabled_settings and data.disabled_settings[_setting] then
					return true				
				end				
			end	
		end	
	end
	
	return false
end

local function DoesAttributeIdExists(_type)
	local templates = AUI.UnitFrames.GetActiveTemplates()
	for templateType, templateData in pairs(templates) do
		for frameType, data in pairs(templateData.frameData) do
			if frameType == _type then
				return true					
			end				
		end	
	end

	return false
end

local function AcceptEnabledSettings()
	AUI.Settings.UnitFrames.player_unit_frames_enabled = g_player_unit_frames_enabled
	AUI.Settings.UnitFrames.target_unit_frames_enabled = g_target_unit_frames_enabled
	AUI.Settings.UnitFrames.group_unit_frames_enabled = g_group_unit_frames_enabled
	AUI.Settings.UnitFrames.boss_unit_frames_enabled = g_boss_unit_frames_enabled
	AUI.Settings.UnitFrames.companion_unit_frames_enabled = g_companion_unit_frames_enabled
	
	ReloadUI()
end

local function AcceptTemplateSettings()
	AUI.Settings.Templates.Attributes.Player = g_player_unit_frames_Template
	AUI.Settings.Templates.Attributes.Target = g_target_unit_frames_Template
	AUI.Settings.Templates.Attributes.Group = g_group_unit_frames_Template
	AUI.Settings.Templates.Attributes.Raid = g_raid_unit_frames_Template
	AUI.Settings.Templates.Attributes.Boss = g_boss_unit_frames_Template
	--AUI.Settings.Templates.Attributes.Companion = g_companion_unit_frames_Template
	
	ReloadUI()
end

local function RemoveAllVisuals(_unitTag)
	AUI.UnitFrames.RemoveAttributeVisual(_unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
	AUI.UnitFrames.RemoveAttributeVisual(_unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
	AUI.UnitFrames.RemoveAttributeVisual(_unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
	AUI.UnitFrames.RemoveAttributeVisual(_unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
	AUI.UnitFrames.RemoveAttributeVisual(_unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
	AUI.UnitFrames.RemoveAttributeVisual(_unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
end

local function GetPlayerColorSettingsTable()
	local optionTable = {	
		{
			type = "header",
			name = AUI.L10n.GetString("player")
		},			
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a)
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).bar_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 			
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).bar_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("magicka"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}					
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)							
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).bar_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}					
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)							
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).bar_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("stamina"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)						
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)						
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).bar_color[2],
			width = "half",
		},					
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("stamina_mount"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).bar_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("werewolf"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).bar_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).bar_color[2],
			width = "half",
		},			
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("siege")  .. " (" .. AUI.L10n.GetString("health") .. ")",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)											
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)											
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).bar_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("shield"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)						
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).bar_color[2],
			width = "half",
		},					
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("regeneration") .. " (" .. AUI.L10n.GetString("health") ..")",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].increase_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a)				
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].increase_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)
				
				if not g_isPreviewShowing then
					return
				end				
				
				RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)
				AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).increase_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].increase_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].increase_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}

				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)

				if not g_isPreviewShowing then
					return
				end		

				RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)				
				AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)						
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).increase_regen_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("degeneration") .. " (" .. AUI.L10n.GetString("health") ..")",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].decrease_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].decrease_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				
				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)

				if not g_isPreviewShowing then
					return
				end		
				
				RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)				
				AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).decrease_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].decrease_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].decrease_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}

				AUI.UnitFrames.UpdateUI(AUI_PLAYER_UNIT_TAG)

				if not g_isPreviewShowing then
					return
				end	
				
				RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)				
				AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)								
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).decrease_regen_color[2],
			width = "half",
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_regeneration_color"),
			tooltip = AUI.L10n.GetString("show_regeneration_color_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_increase_regen_color end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_increase_regen_color = value
	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end	
				
					RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)
	
					if value then
						AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).show_increase_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_increase_regen_color") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_degeneration_color"),
			tooltip = AUI.L10n.GetString("show_degeneration_color_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_decrease_regen_color end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_decrease_regen_color = value

					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end	
				
					RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)

					if value then
						AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).show_decrease_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_decrease_regen_color") end,	
		},			
	}

	return optionTable
end

local function GetTargetColorSettingsTable(_frameType, submenuName)
	local shieldType = AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_SHIELD

	if _frameType == AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH then
		shieldType = AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_SHIELD	
	end

	local optionTable = 
	{	
		{
			type = "header",
			name = submenuName
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)												
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)												
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_color[2],
			width = "half",
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("shield"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][shieldType].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][shieldType].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(shieldType, AUI.UnitFrames.GetActivePlayerTemplateData()).bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][shieldType].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][shieldType].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(shieldType, AUI.UnitFrames.GetActivePlayerTemplateData()).bar_color[2],
			width = "half",
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("companion"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_companion_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_companion_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_companion_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_companion_color[2])
					})
				end													
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_companion_color[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_companion_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_companion_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_companion_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_companion_color[2])
					})
				end													
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_companion_color[2],
			width = "half",
		},			
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("friendly"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_friendly_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_friendly_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_friendly_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_friendly_color[2])
					})
				end													
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_friendly_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_friendly_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_friendly_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_friendly_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_friendly_color[2])
					})						
				end												
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_friendly_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("allied") .. " (" .. AUI.L10n.GetString("npc") .. ")",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_npc_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_npc_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_npc_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_npc_color[2])
					})							
				end
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_allied_npc_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_npc_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_npc_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_npc_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_npc_color[2])
					})	
				end
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_allied_npc_color[2],
			width = "half",
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("allied") .. " (" .. AUI.L10n.GetString("player") .. ")",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_player_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a)
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_player_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_player_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_player_color[2])
					})	
				end	
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_allied_player_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_player_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a)
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_player_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_player_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_allied_player_color[2])
					})	
				end		
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_allied_player_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("neutral"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_neutral_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_neutral_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_neutral_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_neutral_color[2])
					})	
				end
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_neutral_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_neutral_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_neutral_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_neutral_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_neutral_color[2])
					})	
				end
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_neutral_color[2],
			width = "half",
		},					
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("guard"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_guard_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a)
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_guard_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_guard_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_guard_color[2])
					})
				end	
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_guard_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_guard_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a)
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_guard_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.UnitFrames.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_guard_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_guard_color[2])
					})
				end		
			  end,
			default = GetDefaultSettingFromType(_frameType).bar_guard_color[2],
			width = "half",
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("regeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].increase_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].increase_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}

				AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)

				if not g_isPreviewShowing then
					return
				end	
				
				RemoveAllVisuals(AUI_TARGET_UNIT_TAG)			
				AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)				
			end,
			default = GetDefaultSettingFromType(_frameType).increase_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].increase_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].increase_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}

				AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
				
				if not g_isPreviewShowing then
					return
				end	
				
				RemoveAllVisuals(AUI_TARGET_UNIT_TAG)				
				AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
			end,
			default = GetDefaultSettingFromType(_frameType).increase_regen_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("degeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].decrease_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].decrease_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}

				AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)
				
				if not g_isPreviewShowing then
					return
				end					
				
				RemoveAllVisuals(AUI_TARGET_UNIT_TAG)				
				AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
			end,
			default = GetDefaultSettingFromType(_frameType).decrease_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].decrease_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].decrease_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}

				AUI.UnitFrames.UpdateUI(AUI_TARGET_UNIT_TAG)

				if not g_isPreviewShowing then
					return
				end	
				
				RemoveAllVisuals(AUI_TARGET_UNIT_TAG)				
				AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)						
			end,
			default = GetDefaultSettingFromType(_frameType).decrease_regen_color[2],
			width = "half",
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_regeneration_color"),
			tooltip = AUI.L10n.GetString("show_regeneration_color_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_increase_regen_color end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_increase_regen_color = value

					AUI.UnitFrames.UpdateUI()		

					if not g_isPreviewShowing then
						return
					end	
				
					RemoveAllVisuals(AUI_TARGET_UNIT_TAG)
		
					if value then
						AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
					end
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_increase_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_increase_regen_color") end,
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_degeneration_color"),
			tooltip = AUI.L10n.GetString("show_degeneration_color_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_decrease_regen_color end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_decrease_regen_color = value

					AUI.UnitFrames.UpdateUI()	

					if not g_isPreviewShowing then
						return
					end	
				
					RemoveAllVisuals(AUI_TARGET_UNIT_TAG)

					if value then
						AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
					end
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_decrease_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_decrease_regen_color") end,
		},		
	}
	
	return optionTable
end

local function GetGroupColorSettingsTable()
	local optionTable = 
	{	
		{
			type = "header",
			name = AUI.L10n.GetString("group")
		},			
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health") .. " (Tank)",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_tank[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_tank[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()	
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).bar_color_tank[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_tank[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_tank[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).bar_color_tank[2],
			width = "half",
		},	
		
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health") .. " (Healer)",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_healer[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_healer[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()	
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).bar_color_healer[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_healer[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_healer[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).bar_color_healer[2],
			width = "half",
		},		
		
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health") .. " (Damage)",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_dd[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_dd[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()	
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).bar_color_dd[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_dd[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_color_dd[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).bar_color_dd[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("shield"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()				
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).bar_color[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()					
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).bar_color[2],
			width = "half",
		},
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("regeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].increase_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].increase_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()				
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).increase_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].increase_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].increase_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()						
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).increase_regen_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("degeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].decrease_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].decrease_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}

				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()						
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).decrease_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].decrease_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].decrease_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}

				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()						
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).decrease_regen_color[2],
			width = "half",
		},			
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_regeneration_color"),
			tooltip = AUI.L10n.GetString("show_regeneration_color_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_increase_regen_color end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_increase_regen_color = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end						
					
					for i = 1, 4, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end					
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).show_increase_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "show_increase_regen_color") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_degeneration_color"),
			tooltip = AUI.L10n.GetString("show_degeneration_color_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_decrease_regen_color end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_decrease_regen_color = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end						
					
					for i = 1, 4, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end	
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).show_decrease_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "show_decrease_regen_color") end,	
		},	
		{
			type = "header",
			name = AUI.L10n.GetString("companion") .. " (" .. AUI.L10n.GetString("group") .. ")"
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("companion"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()												
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).bar_color[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()													
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).bar_color[2],
			width = "half",
		},			
	}
	return optionTable			
end

local function GetRaidColorSettingsTable()
	local optionTable = 
	{	
		{
			type = "header",
			name = AUI.L10n.GetString("raid")
		},			
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health") .. " (Tank)",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_tank[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_tank[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(24)
				AUI.UnitFrames.UpdateUI()	
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).bar_color_tank[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_tank[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_tank[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(24)
				AUI.UnitFrames.UpdateUI()
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).bar_color_tank[2],
			width = "half",
		},			
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health") .. " (Healer)",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_healer[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_healer[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(24)
				AUI.UnitFrames.UpdateUI()	
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).bar_color_healer[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_healer[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_healer[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(24)
				AUI.UnitFrames.UpdateUI()
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).bar_color_healer[2],
			width = "half",
		},			
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health") .. " (Damage)",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_dd[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_dd[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(24)
				AUI.UnitFrames.UpdateUI()	
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).bar_color_dd[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_dd[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_color_dd[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(4)
				AUI.UnitFrames.UpdateUI()
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).bar_color_dd[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("shield"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(24)
				AUI.UnitFrames.UpdateUI()						
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).bar_color[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(24)
				AUI.UnitFrames.UpdateUI()							
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).bar_color[2],
			width = "half",
		},
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("regeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].increase_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].increase_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI()				
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).increase_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].increase_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].increase_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI()						
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).increase_regen_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("degeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].decrease_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].decrease_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}

				AUI.UnitFrames.Group.SetPreviewGroupSize(24)
				AUI.UnitFrames.UpdateUI()
				
				if not g_isPreviewShowing then
					return
				end						
				
				for i = 1, 24, 1 do	
					unitTag = "group" .. i	
					RemoveAllVisuals(unitTag)
					
					if value then
						AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
					end
				end							
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).decrease_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].decrease_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].decrease_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}

				AUI.UnitFrames.Group.SetPreviewGroupSize(24)
				AUI.UnitFrames.UpdateUI()						
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).decrease_regen_color[2],
			width = "half",
		},			
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_regeneration_color"),
			tooltip = AUI.L10n.GetString("show_regeneration_color_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_increase_regen_color end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_increase_regen_color = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end						
					
					for i = 1, 24, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end					
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).show_increase_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "show_increase_regen_color") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_degeneration_color"),
			tooltip = AUI.L10n.GetString("show_degeneration_color_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_decrease_regen_color end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_decrease_regen_color = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end						
					
					for i = 1, 24, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end	
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).show_decrease_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "show_decrease_regen_color") end,	
		},			
		{
			type = "header",
			name = AUI.L10n.GetString("companion") .. " (" .. AUI.L10n.GetString("raid") .. ")"
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("companion"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(24)
				AUI.UnitFrames.UpdateUI()												
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).bar_color[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.Group.SetPreviewGroupSize(24)
				AUI.UnitFrames.UpdateUI()													
			  end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).bar_color[2],
			width = "half",
		},		
	}
	return optionTable			
end

local function GetBossColorSettingsTable()
	local optionTable = 
	{	
		{
			type = "header",
			name = AUI.L10n.GetString("boss")
		},			
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).bar_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).bar_color[2],
			width = "half",
		},								
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("shield"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)						
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)					
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).bar_color[2],
			width = "half",
		},					
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("regeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].increase_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].increase_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)
							
				if not g_isPreviewShowing then
					return
				end								
							
				for i = 1, MAX_BOSSES, 1 do	
					unitTag = "boss" .. i	

					RemoveAllVisuals(unitTag)
					AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)								
				end					
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).increase_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].increase_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].increase_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)
					
				if not g_isPreviewShowing then
					return
				end	
					
				for i = 1, MAX_BOSSES, 1 do	
					unitTag = "boss" .. i	

					RemoveAllVisuals(unitTag)
					AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
				end							
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).increase_regen_color[2],
			width = "half",
		},								
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("degeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].decrease_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].decrease_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)
				
				if not g_isPreviewShowing then
					return
				end				
				
				for i = 1, MAX_BOSSES, 1 do	
					unitTag = "boss" .. i	

					RemoveAllVisuals(unitTag)
					AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)								
				end						
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).decrease_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].decrease_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].decrease_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)
				
				if not g_isPreviewShowing then
					return
				end					
				
				for i = 1, MAX_BOSSES, 1 do	
					unitTag = "boss" .. i	

					RemoveAllVisuals(unitTag)
					AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)															
				end							
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).decrease_regen_color[2],
			width = "half",
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_regeneration_color"),
			tooltip = AUI.L10n.GetString("show_regeneration_color_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_increase_regen_color end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_increase_regen_color = value
					AUI.UnitFrames.UpdateUI()
					
				if not g_isPreviewShowing then
					return
				end						
					
					for i = 1, MAX_BOSSES, 1 do	
						unitTag = "boss" .. i	

						RemoveAllVisuals(unitTag)					
						AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).show_increase_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "show_increase_regen_color") end,
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_degeneration_color"),
			tooltip = AUI.L10n.GetString("show_degeneration_color_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_decrease_regen_color end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_decrease_regen_color = value
					AUI.UnitFrames.UpdateUI()
				
				if not g_isPreviewShowing then
					return
				end					
				
					for i = 1, MAX_BOSSES, 1 do	
						unitTag = "boss" .. i	

						RemoveAllVisuals(unitTag)
						AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).show_decrease_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "show_decrease_regen_color") end,
		},			
	}
	
	return optionTable
end

local function GetPlayerSettingsTable()
	local optionTable = 
	{	
		{
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("player")),
			controls = 
			{															
				{
					type = "header",
					name = AUI.L10n.GetString("health"),
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("always_show"),
					tooltip = AUI.L10n.GetString("always_show_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_always end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_always = value	
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).show_always,
					width = "full",
					disabled = function() 
						return false
					end,
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].width end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].width = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].height end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].height = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "height") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].opacity end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].opacity = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "opacity") end,
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_text end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_text = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_max_value end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_max_value = value	
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_max_value") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].use_thousand_seperator end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].use_thousand_seperator = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "use_thousand_seperator") end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].font_art) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].font_art = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).font_art),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "font_art") end,					
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_style"),
					tooltip = AUI.L10n.GetString("font_style_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].font_style) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].font_style = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).font_style),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "font_style") end,					
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].font_size = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "font_size") end,
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].bar_alignment) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].bar_alignment = value							
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).bar_alignment),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "bar_alignment") end,					
				},				
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_regeneration_effect"),
					tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_increase_regen_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_increase_regen_effect = value
				
							AUI.UnitFrames.UpdateUI()
							
							if not g_isPreviewShowing then
								return
							end	
				
							RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)
				
							if value then
								AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
							end
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).show_increase_regen_effect,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_increase_regen_effect") end,	
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_degeneration_effect"),
					tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_decrease_regen_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_decrease_regen_effect = value

							AUI.UnitFrames.UpdateUI()
							
							if not g_isPreviewShowing then
								return
							end	
							
							RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)

							if value then
								AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
							end
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).show_decrease_regen_effect,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_decrease_regen_effect") end,	
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_increase_armor_effect"),
					tooltip = AUI.L10n.GetString("show_increase_armor_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_increase_armor_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_increase_armor_effect = value
				
							AUI.UnitFrames.UpdateUI()
							
							if not g_isPreviewShowing then
								return
							end								
							
							RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)
				
							if value then
								AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
							end
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).show_increase_armor_effect,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_increase_armor_effect") end,	
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_decrease_armor_effect"),
					tooltip = AUI.L10n.GetString("show_decrease_armor_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_decrease_armor_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_decrease_armor_effect = value

							AUI.UnitFrames.UpdateUI()
							
							if not g_isPreviewShowing then
								return
							end							
							
							RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)

							if value then
								AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
							end
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).show_decrease_armor_effect,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_decrease_armor_effect") end,	
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_increase_power_effect"),
					tooltip = AUI.L10n.GetString("show_increase_power_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_increase_power_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_increase_power_effect = value
				
							AUI.UnitFrames.UpdateUI()
							
							if not g_isPreviewShowing then
								return
							end								
							
							RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)
				
							if value then
								AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
							end
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).show_increase_power_effect,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_increase_power_effect") end,	
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_decrease_power_effect"),
					tooltip = AUI.L10n.GetString("show_decrease_power_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_decrease_power_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH].show_decrease_power_effect = value

							AUI.UnitFrames.UpdateUI()
							
							if not g_isPreviewShowing then
								return
							end								
							
							RemoveAllVisuals(AUI_PLAYER_UNIT_TAG)

							if value then
								AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
							end
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH).show_decrease_power_effect,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_decrease_power_effect") end,	
				},				
				{
					type = "header",
					name = AUI.L10n.GetString("magicka"),
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("always_show"),
					tooltip = AUI.L10n.GetString("always_show_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].show_always end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].show_always = value	
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).show_always,
					width = "full",
					disabled = function() 
						return false
					end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].width end,
					setFunc = function(value) 
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].width = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].height end,
					setFunc = function(value) 
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].height = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "height") end,
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].opacity end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].opacity = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "opacity") end,
				},			
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].show_text end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].show_text = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].show_max_value end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].show_max_value = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_max_value") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].use_thousand_seperator end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].use_thousand_seperator = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "use_thousand_seperator") end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].font_art) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].font_art = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).font_art),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA, "font_art") end,					
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_style"),
					tooltip = AUI.L10n.GetString("font_style_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].font_style) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].font_style = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).font_style),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA, "font_style") end,					
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].font_size = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "font_size") end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].bar_alignment) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA].bar_alignment = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA).bar_alignment),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA, "bar_alignment") end,					
				},					
				{
					type = "header",
					name = AUI.L10n.GetString("stamina"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("always_show"),
					tooltip = AUI.L10n.GetString("always_show_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].show_always end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].show_always = value	
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).show_always,
					width = "full",
					disabled = function() 
						return false
					end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].width end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].width = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "width") end,	
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].height end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].height = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "height") end,
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].opacity end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].opacity = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "opacity") end,
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].show_text end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].show_text = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].show_max_value end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].show_max_value = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "show_max_value") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].use_thousand_seperator end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].use_thousand_seperator = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "use_thousand_seperator") end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].font_art) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].font_art = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).font_art),					
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA, "font_art") end,					
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_style"),
					tooltip = AUI.L10n.GetString("font_style_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].font_style) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].font_style = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).font_style),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA, "font_style") end,					
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].font_size = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH, "font_size") end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].bar_alignment) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA].bar_alignment = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA).bar_alignment),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA, "bar_alignment") end,					
				},					
				{
					type = "header",
					name = AUI.L10n.GetString("shield"),
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].width end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].width = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].height end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].height = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD, "height") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].opacity end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].opacity = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD, "opacity") end,
				},			
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].show_text end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].show_text = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].show_max_value end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].show_max_value = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD, "show_max_value") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].use_thousand_seperator end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].use_thousand_seperator = value
							AUI.UnitFrames.UpdateUI()
							
							if not g_isPreviewShowing then
								return
							end	
							
							AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, false)
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD, "use_thousand_seperator") end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].font_art) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].font_art = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).font_art),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD, "font_art") end,					
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_style"),
					tooltip = AUI.L10n.GetString("font_style_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].font_style) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].font_style = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).font_style),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD, "font_style") end,					
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].font_size = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD, "font_size") end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].bar_alignment) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD].bar_alignment = value							
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD).bar_alignment),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD, "bar_alignment") end,					
				},					
				{
					type = "header",
					name = AUI.L10n.GetString("siege") .. " (" .. AUI.L10n.GetString("health") .. ")"
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].width end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].width = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].height end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].height = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE, "height") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].opacity end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].opacity = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE, "opacity") end,
				},			
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].show_text end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].show_text = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].show_max_value end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].show_max_value = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE, "show_max_value") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].use_thousand_seperator end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].use_thousand_seperator = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE, "use_thousand_seperator") end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].font_art) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].font_art = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).font_art),		
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE, "font_art") end,					
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_style"),
					tooltip = AUI.L10n.GetString("font_style_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].font_style) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].font_style = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).font_style),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE, "font_style") end,					
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].font_size = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE, "font_size") end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].bar_alignment) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE].bar_alignment = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE).bar_alignment),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE, "bar_alignment") end,					
				},				
				{
					type = "header",
					name = AUI.L10n.GetString("stamina") .. " (" .. AUI.L10n.GetString("mount") .. ")",
				},	
					{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].width end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].width = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].height end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].height = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT, "height") end,
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].opacity end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].opacity = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT, "opacity") end,
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].show_text end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].show_text = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].show_max_value end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].show_max_value = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT, "show_max_value") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].use_thousand_seperator end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].use_thousand_seperator = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT, "use_thousand_seperator") end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].font_art) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].font_art = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).font_art),	
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT, "font_art") end,					
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_style"),
					tooltip = AUI.L10n.GetString("font_style_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].font_style) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].font_style = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).font_style),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT, "font_style") end,					
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].font_size = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT, "font_size") end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].bar_alignment) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT].bar_alignment = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT).bar_alignment),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT, "bar_alignment") end,					
				},					
				{
					type = "header",
					name = AUI.L10n.GetString("werewolf"),
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].width end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].width = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].height end,
					setFunc = function(value) 
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].height = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF, "height") end,
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].opacity end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].opacity = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF, "opacity") end,
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].show_text end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].show_text = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].show_max_value end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].show_max_value = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF, "show_max_value") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].use_thousand_seperator end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].use_thousand_seperator = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF, "use_thousand_seperator") end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].font_art) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].font_art = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).font_art),						
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF, "font_art") end,					
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_style"),
					tooltip = AUI.L10n.GetString("font_style_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].font_style) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].font_style = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).font_style),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF, "font_style") end,					
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].font_size = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF, "font_size") end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].bar_alignment) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Player[GetActivePlayerTemplateName()][AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF].bar_alignment = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF).bar_alignment),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF, "bar_alignment") end,					
				},				
			}
		},
	}
	
	return optionTable
end

local function GetGroupSettingsTable()
	local optionTable = 
	{																
		{
			type = "header",
			name = AUI.L10n.GetString("health")
		},			
		{
			type = "slider",
			name = AUI.L10n.GetString("width"),
			tooltip = AUI.L10n.GetString("width_tooltip"),
			min = 160,
			max = 350,
			step = 2,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].width end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].width = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).width,
			width = "half",		
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "width") end,
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("height"),
			tooltip = AUI.L10n.GetString("height_tooltip"),
			min = 16,
			max = 48,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].height end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].height = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).height,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "height") end,
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("distance"),
			tooltip = AUI.L10n.GetString("row_distance_tooltip"),
			min = 32,
			max = 60,
			step = 2,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].row_distance end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].row_distance = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).row_distance,
			width = "full",	
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "row_distance") end,					
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_text"),
			tooltip = AUI.L10n.GetString("show_text_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_text end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_text = value	
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).show_text,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "show_text") end,
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_max_value"),
			tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_max_value end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_max_value = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).show_max_value,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "show_max_value") end,
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].use_thousand_seperator end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].use_thousand_seperator = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end	
					
					AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, false)
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "use_thousand_seperator") end,
		},			
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_art"),
			tooltip = AUI.L10n.GetString("font_art_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].font_art) end,
			setFunc = function(value) 
				value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].font_art = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end							
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).font_art),					
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "font_art") end,					
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_style"),
			tooltip = AUI.L10n.GetString("font_style_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].font_style) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].font_style = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).font_style),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "font_style") end,					
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("font_size"),
			tooltip = AUI.L10n.GetString("font_size_tooltip"),
			min = 4,
			max = 22,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].font_size end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].font_size = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).font_size,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "font_size") end,
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_account_name"),
			tooltip = AUI.L10n.GetString("show_account_name_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_account_name end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_account_name = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).show_account_name,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "show_account_name") end,
		},					
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].use_thousand_seperator end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].use_thousand_seperator = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "use_thousand_seperator") end,
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("opacity"),
			tooltip = AUI.L10n.GetString("opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].opacity = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).opacity,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "opacity") end,					
		},				
		{
			type = "slider",
			name = AUI.L10n.GetString("unit_out_of_range_opacity"),
			tooltip = AUI.L10n.GetString("unit_out_of_range_opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].out_of_range_opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].out_of_range_opacity = value
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].out_of_range_opacity = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).out_of_range_opacity,
			width = "half",	
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "out_of_range_opacity") end,					
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("alignment"),
			tooltip = AUI.L10n.GetString("alignment_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_alignment) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].bar_alignment = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).bar_alignment),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "bar_alignment") end,					
		},				
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_regeneration_effect"),
			tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_increase_regen_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_increase_regen_effect = value
		
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 4, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end	
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).show_increase_regen_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "show_increase_regen_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_degeneration_effect"),
			tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_decrease_regen_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_decrease_regen_effect = value

					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 4, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).show_decrease_regen_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "show_decrease_regen_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_increase_armor_effect"),
			tooltip = AUI.L10n.GetString("show_increase_armor_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_increase_armor_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_increase_armor_effect = value
		
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 4, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
						end
					end
				end
			end,
			default = false,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "show_increase_armor_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_decrease_armor_effect"),
			tooltip = AUI.L10n.GetString("show_decrease_armor_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_decrease_armor_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_decrease_armor_effect = value

					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 4, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).show_decrease_armor_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "show_decrease_armor_effect") end,	
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_increase_power_effect"),
			tooltip = AUI.L10n.GetString("show_increase_power_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_increase_power_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_increase_power_effect = value
		
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
						
					if not g_isPreviewShowing then
						return
					end									
						
					for i = 1, 4, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).show_increase_power_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "show_increase_power_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_decrease_power_effect"),
			tooltip = AUI.L10n.GetString("show_decrease_power_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_decrease_power_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].show_decrease_power_effect = value
					
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
								
					if not g_isPreviewShowing then
						return
					end	
								
					for i = 1, 4, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
					end
				end							
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH).show_decrease_power_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_HEALTH, "show_decrease_power_effect") end,	
		},										
	}

	return optionTable
end

local function GetGroupShieldSettingsTable()
	local optionTable = 
	{	
		{
			type = "header",
			name = AUI.L10n.GetString("shield"),
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("width"),
			tooltip = AUI.L10n.GetString("width_tooltip"),
			min = 225,
			max = 450,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].width end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].width = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).width,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD, "width") end,
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("height"),
			tooltip = AUI.L10n.GetString("height_tooltip"),
			min = 16,
			max = 80,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].height end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].height = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).height,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD, "height") end,
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("opacity"),
			tooltip = AUI.L10n.GetString("opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].opacity = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).opacity,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD, "opacity") end,
		},			
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_text"),
			tooltip = AUI.L10n.GetString("show_text_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].show_text end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].show_text = value	
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).show_text,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD, "show_text") end,
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_max_value"),
			tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].show_max_value end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].show_max_value = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).show_max_value,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD, "show_max_value") end,
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].use_thousand_seperator end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].use_thousand_seperator = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end	
					
					AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, false)
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD, "use_thousand_seperator") end,
		},	
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_art"),
			tooltip = AUI.L10n.GetString("font_art_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].font_art) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].font_art = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).font_art),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD, "font_art") end,					
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_style"),
			tooltip = AUI.L10n.GetString("font_style_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].font_style) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].font_style = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).font_style),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD, "font_style") end,					
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("font_size"),
			tooltip = AUI.L10n.GetString("font_size_tooltip"),
			min = 4,
			max = 22,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].font_size end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].font_size = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).font_size,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD, "font_size") end,
		},	
		{
			type = "dropdown",
			name = AUI.L10n.GetString("alignment"),
			tooltip = AUI.L10n.GetString("alignment_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].bar_alignment) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_SHIELD].bar_alignment = value	
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD).bar_alignment),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_SHIELD, "bar_alignment") end,					
		}
	}

	return optionTable
end

local function GetGroupCompanionSettingsTable()
	local optionTable = 
	{																
		{
			type = "header",
			name = AUI.L10n.GetString("companion")
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show"),
			tooltip = AUI.L10n.GetString("show_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].display end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].display = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
					
					if value then
						AUI.UnitFrames.ShowFrame(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION)
					else
						AUI.UnitFrames.HideFrame(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION)							
					end				
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).display,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "display") end,
		},			
		{
			type = "slider",
			name = AUI.L10n.GetString("width"),
			tooltip = AUI.L10n.GetString("width_tooltip"),
			min = 160,
			max = 350,
			step = 2,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].width end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].width = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).width,
			width = "half",		
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "width") end,
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("height"),
			tooltip = AUI.L10n.GetString("height_tooltip"),
			min = 14,
			max = 34,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].height end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].height = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).height,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "height") end,
		},					
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_text"),
			tooltip = AUI.L10n.GetString("show_text_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_text end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_text = value	
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).show_text,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "show_text") end,
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_max_value"),
			tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_max_value end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_max_value = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).show_max_value,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "show_max_value") end,
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].use_thousand_seperator end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].use_thousand_seperator = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end	
					
					AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, false)
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "use_thousand_seperator") end,
		},			
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_art"),
			tooltip = AUI.L10n.GetString("font_art_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].font_art) end,
			setFunc = function(value) 
				value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].font_art = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end							
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).font_art),					
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "font_art") end,					
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_style"),
			tooltip = AUI.L10n.GetString("font_style_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].font_style) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].font_style = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).font_style),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "font_style") end,					
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("font_size"),
			tooltip = AUI.L10n.GetString("font_size_tooltip"),
			min = 4,
			max = 22,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].font_size end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].font_size = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).font_size,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "font_size") end,
		},						
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].use_thousand_seperator end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].use_thousand_seperator = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "use_thousand_seperator") end,
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("opacity"),
			tooltip = AUI.L10n.GetString("opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].opacity = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).opacity,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "opacity") end,					
		},				
		{
			type = "slider",
			name = AUI.L10n.GetString("unit_out_of_range_opacity"),
			tooltip = AUI.L10n.GetString("unit_out_of_range_opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].out_of_range_opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].out_of_range_opacity = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).out_of_range_opacity,
			width = "half",	
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "out_of_range_opacity") end,					
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("alignment"),
			tooltip = AUI.L10n.GetString("alignment_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].bar_alignment) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].bar_alignment = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).bar_alignment),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "bar_alignment") end,					
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_regeneration_effect"),
			tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_increase_regen_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_increase_regen_effect = value
		
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 4, 1 do	
						unitTag = GetCompanionUnitTagByGroupUnitTag("group" .. i)
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end	
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).show_increase_regen_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "show_increase_regen_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_degeneration_effect"),
			tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_decrease_regen_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_decrease_regen_effect = value

					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 4, 1 do	
						unitTag = GetCompanionUnitTagByGroupUnitTag("group" .. i)
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).show_decrease_regen_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "show_decrease_regen_effect") end,	
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_increase_armor_effect"),
			tooltip = AUI.L10n.GetString("show_increase_armor_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_increase_armor_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_increase_armor_effect = value
		
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 4, 1 do	
						unitTag = GetCompanionUnitTagByGroupUnitTag("group" .. i)
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
						end
					end
				end
			end,
			default = false,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "show_increase_armor_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_decrease_armor_effect"),
			tooltip = AUI.L10n.GetString("show_decrease_armor_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_decrease_armor_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_decrease_armor_effect = value

					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 4, 1 do	
						unitTag = GetCompanionUnitTagByGroupUnitTag("group" .. i)
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).show_decrease_armor_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "show_decrease_armor_effect") end,	
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_increase_power_effect"),
			tooltip = AUI.L10n.GetString("show_increase_power_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_increase_power_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_increase_power_effect = value
		
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
						
					if not g_isPreviewShowing then
						return
					end									
						
					for i = 1, 4, 1 do	
						unitTag = GetCompanionUnitTagByGroupUnitTag("group" .. i)
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).show_increase_power_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "show_increase_power_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_decrease_power_effect"),
			tooltip = AUI.L10n.GetString("show_decrease_power_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_decrease_power_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Group[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].show_decrease_power_effect = value
					
					AUI.UnitFrames.Group.SetPreviewGroupSize(4)	
					AUI.UnitFrames.UpdateUI()
								
					if not g_isPreviewShowing then
						return
					end	
								
					for i = 1, 4, 1 do	
						unitTag = GetCompanionUnitTagByGroupUnitTag("group" .. i)
						RemoveAllVisuals(unitTag)
						AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
					end
				end							
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION).show_decrease_power_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_GROUP_COMPANION, "show_decrease_power_effect") end,	
		},			
	}

	return optionTable
end

local function GetRaidSettingsTable()
	local optionTable = 
	{																							
		{
			type = "header",
			name = AUI.L10n.GetString("health")
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("width"),
			tooltip = AUI.L10n.GetString("width_tooltip"),
			min = 100,
			max = 350,
			step = 2,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].width end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].width = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).width,
			width = "half",	
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "width") end,					
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("height"),
			tooltip = AUI.L10n.GetString("height_tooltip"),
			min = 32,
			max = 48,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].height end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].height = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).height,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "height") end,
		},						
		{
			type = "slider",
			name = AUI.L10n.GetString("column_distance"),
			tooltip = AUI.L10n.GetString("column_distance_tooltip"),
			min = 2,
			max = 24,
			step = 2,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].column_distance end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].column_distance = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).column_distance,
			width = "half",	
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "column_distance") end,					
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("row_distance"),
			tooltip = AUI.L10n.GetString("row_distance_tooltip"),
			min = 2,
			max = 24,
			step = 2,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].row_distance end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].row_distance = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).row_distance,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "row_distance") end,					
		},
		{
			type = "slider",
			name = AUI.L10n.GetString("row_count"),
			tooltip = AUI.L10n.GetString("row_count_tooltip"),
			min = 4,
			max = 12,
			step = 2,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].row_count end,
			setFunc = function(value) 
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].row_count = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).row_count,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "row_count") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_text"),
			tooltip = AUI.L10n.GetString("show_text_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_text end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_text = value	
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).show_text,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "show_text") end,
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_max_value"),
			tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_max_value end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_max_value = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).show_max_value,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "show_max_value") end,
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].use_thousand_seperator end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveGroupTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].use_thousand_seperator = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end	
					
					AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, false)
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "use_thousand_seperator") end,
		},			
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_art"),
			tooltip = AUI.L10n.GetString("font_art_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].font_art) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].font_art = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).font_art),					
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "font_art") end,					
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_style"),
			tooltip = AUI.L10n.GetString("font_style_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].font_style) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].font_style = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).font_style),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "font_style") end,					
		},				
		{
			type = "slider",
			name = AUI.L10n.GetString("font_size"),
			tooltip = AUI.L10n.GetString("font_size_tooltip"),
			min = 4,
			max = 22,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].font_size end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].font_size = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).font_size,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "font_size") end,
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_account_name"),
			tooltip = AUI.L10n.GetString("show_account_name_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_account_name end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_account_name = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).show_account_name,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "show_account_name") end,	
		},				
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].use_thousand_seperator end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].use_thousand_seperator = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "use_thousand_seperator") end,	
		},
		{
			type = "slider",
			name = AUI.L10n.GetString("opacity"),
			tooltip = AUI.L10n.GetString("opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].opacity = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).opacity,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "opacity") end,					
		},				
		{
			type = "slider",
			name = AUI.L10n.GetString("unit_out_of_range_opacity"),
			tooltip = AUI.L10n.GetString("unit_out_of_range_opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].out_of_range_opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].out_of_range_opacity = value
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].out_of_range_opacity = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).out_of_range_opacity,
			width = "half",	
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "out_of_range_opacity") end,							
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("alignment"),
			tooltip = AUI.L10n.GetString("alignment_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_alignment) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].bar_alignment = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).bar_alignment),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "bar_alignment") end,					
		},					
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_regeneration_effect"),
			tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_increase_regen_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_increase_regen_effect = value
		
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 24, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end	
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).show_increase_regen_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "show_increase_regen_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_degeneration_effect"),
			tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_decrease_regen_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_decrease_regen_effect = value

					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 24, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end	
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).show_decrease_regen_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "show_decrease_regen_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_increase_armor_effect"),
			tooltip = AUI.L10n.GetString("show_increase_armor_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_increase_armor_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_increase_armor_effect = value
		
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 24, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
						end
					end
				end
			end,
			default = false,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "show_increase_armor_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_decrease_armor_effect"),
			tooltip = AUI.L10n.GetString("show_decrease_armor_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_decrease_armor_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_decrease_armor_effect = value

					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 24, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).show_decrease_armor_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "show_decrease_armor_effect") end,	
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_increase_power_effect"),
			tooltip = AUI.L10n.GetString("show_increase_power_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_increase_power_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_increase_power_effect = value
		
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 24, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).show_increase_power_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "show_increase_power_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_decrease_power_effect"),
			tooltip = AUI.L10n.GetString("show_decrease_power_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_decrease_power_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_HEALTH].show_decrease_power_effect = value

					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 24, 1 do	
						unitTag = "group" .. i	
						RemoveAllVisuals(unitTag)
						AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_HEALTH).show_decrease_power_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_HEALTH, "show_decrease_power_effect") end,	
		}			
	}

	return optionTable
end

local function GetRaidShieldSettingsTable()
	local optionTable = 
	{	
		{
			type = "header",
			name = AUI.L10n.GetString("shield"),
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("width"),
			tooltip = AUI.L10n.GetString("width_tooltip"),
			min = 225,
			max = 450,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].width end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].width = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).width,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_SHIELD, "width") end,
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("height"),
			tooltip = AUI.L10n.GetString("height_tooltip"),
			min = 16,
			max = 80,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].height end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].height = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).height,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_SHIELD, "height") end,
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("opacity"),
			tooltip = AUI.L10n.GetString("opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].opacity = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).opacity,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_SHIELD, "opacity") end,
		},			
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_text"),
			tooltip = AUI.L10n.GetString("show_text_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].show_text end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].show_text = value	
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).show_text,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_SHIELD, "show_text") end,
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_max_value"),
			tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].show_max_value end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].show_max_value = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).show_max_value,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_SHIELD, "show_max_value") end,
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].use_thousand_seperator end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].use_thousand_seperator = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end	
					
					AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, false)
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_SHIELD, "use_thousand_seperator") end,
		},	
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_art"),
			tooltip = AUI.L10n.GetString("font_art_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].font_art) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].font_art = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).font_art),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_SHIELD, "font_art") end,					
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_style"),
			tooltip = AUI.L10n.GetString("font_style_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].font_style) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].font_style = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).font_style),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_SHIELD, "font_style") end,					
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("font_size"),
			tooltip = AUI.L10n.GetString("font_size_tooltip"),
			min = 4,
			max = 22,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].font_size end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].font_size = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).font_size,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_SHIELD, "font_size") end,
		},	
		{
			type = "dropdown",
			name = AUI.L10n.GetString("alignment"),
			tooltip = AUI.L10n.GetString("alignment_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].bar_alignment) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_SHIELD].bar_alignment = value	
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_SHIELD).bar_alignment),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_SHIELD, "bar_alignment") end,					
		}
	}

	return optionTable
end

local function GetRaidCompanionSettingsTable()
	local optionTable = 
	{																
		{
			type = "header",
			name = AUI.L10n.GetString("companion")
		},			
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show"),
			tooltip = AUI.L10n.GetString("show_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].display end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].display = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
					
					if value then
						AUI.UnitFrames.ShowFrame(AUI_UNIT_FRAME_TYPE_RAID_COMPANION)
					else
						AUI.UnitFrames.HideFrame(AUI_UNIT_FRAME_TYPE_RAID_COMPANION)							
					end						
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).display,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_COMPANION, "display") end,
		},			
		{
			type = "slider",
			name = AUI.L10n.GetString("width"),
			tooltip = AUI.L10n.GetString("width_tooltip"),
			min = 160,
			max = 350,
			step = 2,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].width end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].width = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).width,
			width = "half",		
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_COMPANION, "width") end,
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("height"),
			tooltip = AUI.L10n.GetString("height_tooltip"),
			min = 6,
			max = 20,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].height end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].height = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).height,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_COMPANION, "height") end,
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("opacity"),
			tooltip = AUI.L10n.GetString("opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].opacity = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).opacity,
			width = "half",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_COMPANION, "opacity") end,					
		},				
		{
			type = "slider",
			name = AUI.L10n.GetString("unit_out_of_range_opacity"),
			tooltip = AUI.L10n.GetString("unit_out_of_range_opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].out_of_range_opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].out_of_range_opacity = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).out_of_range_opacity,
			width = "half",	
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_COMPANION, "out_of_range_opacity") end,					
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_text"),
			tooltip = AUI.L10n.GetString("show_text_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].show_text end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].show_text = value	
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).show_text,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_COMPANION, "show_text") end,
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_max_value"),
			tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].show_max_value end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].show_max_value = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).show_max_value,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_COMPANION, "show_max_value") end,
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].use_thousand_seperator end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].use_thousand_seperator = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end	
					
					AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, false)
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_COMPANION, "use_thousand_seperator") end,
		},			
		{
			type = "dropdown",
			name = AUI.L10n.GetString("alignment"),
			tooltip = AUI.L10n.GetString("alignment_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].bar_alignment) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].bar_alignment = value
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).bar_alignment),
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_COMPANION, "bar_alignment") end,					
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_regeneration_effect"),
			tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].show_increase_regen_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].show_increase_regen_effect = value
		
					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 24, 1 do	
						unitTag = GetCompanionUnitTagByGroupUnitTag("group" .. i)
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end	
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).show_increase_regen_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_COMPANION, "show_increase_regen_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_degeneration_effect"),
			tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].show_decrease_regen_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Raid[GetActiveRaidTemplateName()][AUI_UNIT_FRAME_TYPE_RAID_COMPANION].show_decrease_regen_effect = value

					AUI.UnitFrames.Group.SetPreviewGroupSize(24)	
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end								
					
					for i = 1, 24, 1 do	
						unitTag = GetCompanionUnitTagByGroupUnitTag("group" .. i)
						RemoveAllVisuals(unitTag)
						
						if value then
							AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						end
					end
				end
			end,
			default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_RAID_COMPANION).show_decrease_regen_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_RAID_COMPANION, "show_decrease_regen_effect") end,	
		},			
	}

	return optionTable
end

local function GetBossAUISettingsTable()
	local optionTable = 
	{	
		{
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("boss") .. " (AUI)"),
			controls = 
			{		
				{
					type = "header",
					name = AUI.L10n.GetString("health")
				},				
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					tooltip = AUI.L10n.GetString("show_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].display end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].display = value
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].display = value
							AUI.UnitFrames.UpdateUI()

							if value then
								AUI.UnitFrames.ShowFrame(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH)
								AUI.UnitFrames.ShowFrame(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD)
							else
								AUI.UnitFrames.HideFrame(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH)
								AUI.UnitFrames.HideFrame(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD)							
							end
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).display,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "display") end,
				},			
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 160,
					max = 350,
					step = 2,
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].width end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].width = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).width,
					width = "half",		
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 48,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].height end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].height = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "height") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("column_distance"),
					tooltip = AUI.L10n.GetString("column_distance_tooltip"),
					min = 2,
					max = 24,
					step = 2,
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].column_distance end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].column_distance = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).column_distance,
					width = "half",	
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "column_distance") end,					
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("row_distance"),
					tooltip = AUI.L10n.GetString("row_distance_tooltip"),
					min = 2,
					max = 24,
					step = 2,
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].row_distance end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].row_distance = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).row_distance,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "row_distance") end,					
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("row_count"),
					tooltip = AUI.L10n.GetString("row_count_tooltip"),
					min = 2,
					max = 6,
					step = 2,
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].row_count end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].row_count = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).row_count,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "row_count") end,	
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].font_art) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].font_art = value
							AUI.UnitFrames.UpdateUI()
						end							
					end,	
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).font_art),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "font_art") end,					
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_style"),
					tooltip = AUI.L10n.GetString("font_style_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].font_style) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].font_style = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).font_style),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "font_style") end,					
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].font_size = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "font_size") end,
				},									
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].use_thousand_seperator end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].use_thousand_seperator = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "use_thousand_seperator") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].opacity end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].opacity = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "opacity") end,					
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].bar_alignment) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].bar_alignment = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).bar_alignment),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "bar_alignment") end,					
				},										
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_regeneration_effect"),
					tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_increase_regen_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_increase_regen_effect = value
				
							AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)			
				
							if not g_isPreviewShowing then
								return
							end					
				
							for i = 1, MAX_BOSSES, 1 do	
								unitTag = "boss" .. i	

								RemoveAllVisuals(unitTag)
								AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
							end	
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).show_increase_regen_effect,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "show_increase_regen_effect") end,	
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_degeneration_effect"),
					tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_decrease_regen_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_decrease_regen_effect = value

							AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)

							if not g_isPreviewShowing then
								return
							end	

							for i = 1, MAX_BOSSES, 1 do	
								unitTag = "boss" .. i	

								RemoveAllVisuals(unitTag)
								AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
							end
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).show_decrease_regen_effect,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "show_decrease_regen_effect") end,	
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_increase_armor_effect"),
					tooltip = AUI.L10n.GetString("show_increase_armor_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_increase_armor_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_increase_armor_effect = value
				
							AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)			
				
							if not g_isPreviewShowing then
								return
							end					
				
							for i = 1, MAX_BOSSES, 1 do	
								unitTag = "boss" .. i	

								RemoveAllVisuals(unitTag)
								AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
							end
						end
					end,
					default = false,
					width = "full",
					disabled = function() return true end,	
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_decrease_armor_effect"),
					tooltip = AUI.L10n.GetString("show_decrease_armor_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_decrease_armor_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_decrease_armor_effect = value

							AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)

							if not g_isPreviewShowing then
								return
							end	

							for i = 1, MAX_BOSSES, 1 do	
								unitTag = "boss" .. i	

								RemoveAllVisuals(unitTag)
								AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)						
							end
						end							
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).show_decrease_armor_effect,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "show_decrease_armor_effect") end,	
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_increase_power_effect"),
					tooltip = AUI.L10n.GetString("show_increase_power_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_increase_power_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_increase_power_effect = value
				
							if not g_isPreviewShowing then
								return
							end					
				
							AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)
				
							for i = 1, MAX_BOSSES, 1 do	
								unitTag = "boss" .. i	

								RemoveAllVisuals(unitTag)
								AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
							end
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).show_increase_power_effect,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "show_increase_power_effect") end,	
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_decrease_power_effect"),
					tooltip = AUI.L10n.GetString("show_decrease_power_effect_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_decrease_power_effect end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_HEALTH].show_decrease_power_effect = value

							AUI.UnitFrames.UpdateUI(AUI_BOSS_UNIT_TAG)

							if not g_isPreviewShowing then
								return
							end	

							for i = 1, MAX_BOSSES, 1 do	
								unitTag = "boss" .. i	

								RemoveAllVisuals(unitTag)
								AUI.UnitFrames.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)					
							end
						end							
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH).show_decrease_power_effect,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_HEALTH, "show_decrease_power_effect") end,	
				},
				{
					type = "header",
					name = AUI.L10n.GetString("shield"),
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].width end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].width = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].height end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].height = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD, "height") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].opacity end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].opacity = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD, "opacity") end,
				},			
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].show_text end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].show_text = value					
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].show_max_value end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].show_max_value = value				
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD, "show_max_value") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].use_thousand_seperator end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].use_thousand_seperator = value
							AUI.UnitFrames.UpdateUI()
							
							if not g_isPreviewShowing then
								return
							end	
							
							AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, false)
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD, "use_thousand_seperator") end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].font_art) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].font_art = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).font_art),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD, "font_art") end,					
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_style"),
					tooltip = AUI.L10n.GetString("font_style_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].font_style) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].font_style = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).font_style),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD, "font_style") end,					
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].font_size = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD, "font_size") end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].bar_alignment) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.Boss[GetActiveBossTemplateName()][AUI_UNIT_FRAME_TYPE_BOSS_SHIELD].bar_alignment = value	
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD).bar_alignment),
					disabled = function() return IsSettingDisabled(AUI_UNIT_FRAME_TYPE_BOSS_SHIELD, "bar_alignment") end,					
				}			
			}			
		}
	}

	return optionTable
end

local function GetBossDefaultSettingsTable()
	local optionTable = 
	{	
		{
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("boss") ..  " (" .. AUI.L10n.GetString("default") .. ")"),
			controls = 
			{		
				{
					type = "header",
					name = AUI.L10n.GetString("health"),
				},			
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.boss_game_default_frame_show_text end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.boss_game_default_frame_show_text = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettings().boss_game_default_frame_show_text,
					width = "full",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.UnitFrames.boss_game_default_frame_use_thousand_seperator end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.boss_game_default_frame_use_thousand_seperator = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettings().boss_game_default_frame_use_thousand_seperator,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4 ,
					max = 22 ,
					step = 1,
					getFunc = function() return AUI.Settings.UnitFrames.boss_game_default_frame_font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.UnitFrames.boss_game_default_frame_font_size = value
							AUI.UnitFrames.UpdateUI()
						end
					end,
					default = GetDefaultSettings().boss_game_default_frame_font_size,
					width = "full",
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.boss_game_default_frame_font_art) end,
					setFunc = function(value)
						value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						if value ~= nil then
							AUI.Settings.UnitFrames.boss_game_default_frame_font_art = value
							AUI.UnitFrames.UpdateUI()
						end							
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().boss_game_default_frame_font_art),		
				}
			}			
		}
	}

	return optionTable
end

local function GetSubmenuTable(_subMenuName)
	local optionTable = 
	{	
		type = "submenu",
		name = AUI_TXT_COLOR_SUBMENU:Colorize(_subMenuName),
		controls = {}
	}
	
	return optionTable
end

local function GetTargetSettingTable(_frameType)
	local optionTable = 
	{	
		{
			type = "header",
			name = AUI.L10n.GetString("health")
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show"),
			tooltip = AUI.L10n.GetString("show_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].display end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].display = value
					AUI.UnitFrames.HideFrame(_frameType)
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).display,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "display") end,			
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("width"),
			tooltip = AUI.L10n.GetString("width_tooltip"),
			min = 225,
			max = 400,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].width end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].width = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).width,
			width = "half",
			disabled = function() return IsSettingDisabled(_frameType, "width") end,
		},
		{
			type = "slider",
			name = AUI.L10n.GetString("height"),
			tooltip = AUI.L10n.GetString("height_tooltip"),
			min = 16,
			max = 80,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].height end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].height = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).height,
			width = "half",
			disabled = function() return IsSettingDisabled(_frameType, "height") end,
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("opacity"),
			tooltip = AUI.L10n.GetString("opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].opacity = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).opacity,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "opacity") end,
		},				
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_account_name"),
			tooltip = AUI.L10n.GetString("show_account_name_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_account_name end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_account_name = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_account_name,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_account_name") end,
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("caption"),
			tooltip = AUI.L10n.GetString("caption_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetCaptionTypeList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetCaptionTypeList(), AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].caption_mode) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetCaptionTypeList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].caption_mode = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetCaptionTypeList(), GetDefaultSettingFromType(_frameType).caption_mode),
			disabled = function() return IsSettingDisabled(_frameType, "caption_mode") end,					
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_text"),
			tooltip = AUI.L10n.GetString("show_text_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_text end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_text = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_text,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_text") end,
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_max_value"),
			tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_max_value end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_max_value = value					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_max_value,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_max_value") end,
		},					
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].use_thousand_seperator end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].use_thousand_seperator = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "use_thousand_seperator") end,
		},							
		{
			type = "slider",
			name = AUI.L10n.GetString("font_size"),
			tooltip = AUI.L10n.GetString("font_size_tooltip"),
			min = 4 ,
			max = 22 ,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].font_size end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].font_size = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).font_size,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "font_size") end,
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_art"),
			tooltip = AUI.L10n.GetString("font_art_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].font_art) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].font_art = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(_frameType).font_art),
			disabled = function() return IsSettingDisabled(_frameType, "font_art") end,					
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("alignment"),
			tooltip = AUI.L10n.GetString("alignment_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_alignment) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_alignment = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(_frameType).bar_alignment),
			disabled = function() return IsSettingDisabled(_frameType, "bar_alignment") end,					
		},					
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_regeneration_effect"),
			tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_increase_regen_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_increase_regen_effect = value
		
					if not g_isPreviewShowing then
						return
					end					
		
					RemoveAllVisuals(AUI_TARGET_UNIT_TAG)
		
					if value then
						AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
					end
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_increase_regen_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_increase_regen_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_degeneration_effect"),
			tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_decrease_regen_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_decrease_regen_effect = value

					if not g_isPreviewShowing then
						return
					end	

					RemoveAllVisuals(AUI_TARGET_UNIT_TAG)

					if value then
						AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
					end
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_decrease_regen_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_decrease_regen_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_increase_armor_effect"),
			tooltip = AUI.L10n.GetString("show_increase_armor_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_increase_armor_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_increase_armor_effect = value
		
					if not g_isPreviewShowing then
						return
					end					
		
					RemoveAllVisuals(AUI_TARGET_UNIT_TAG)
		
					if value then
						AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
					end
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_increase_armor_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_increase_armor_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_decrease_armor_effect"),
			tooltip = AUI.L10n.GetString("show_decrease_armor_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_decrease_armor_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_decrease_armor_effect = value

					if not g_isPreviewShowing then
						return
					end	

					RemoveAllVisuals(AUI_TARGET_UNIT_TAG)

					if value then
						AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
					end
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_decrease_armor_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_decrease_armor_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_increase_power_effect"),
			tooltip = AUI.L10n.GetString("show_increase_power_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_increase_power_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_increase_power_effect = value
		
					if not g_isPreviewShowing then
						return
					end					
		
					RemoveAllVisuals(AUI_TARGET_UNIT_TAG)
		
					if value then
						AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)	
					end
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_increase_power_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_increase_power_effect") end,	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_decrease_power_effect"),
			tooltip = AUI.L10n.GetString("show_decrease_power_effect_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_decrease_power_effect end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_decrease_power_effect = value

					if not g_isPreviewShowing then
						return
					end	

					RemoveAllVisuals(AUI_TARGET_UNIT_TAG)

					if value then
						AUI.UnitFrames.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
					end
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_decrease_power_effect,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_decrease_power_effect") end,	
		}				
	}

	return optionTable
end

local function GetTargetShieldSettingTable(_frameType)
	local optionTable = 
	{	
		{
			type = "header",
			name = AUI.L10n.GetString("shield"),
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("width"),
			tooltip = AUI.L10n.GetString("width_tooltip"),
			min = 225,
			max = 450,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].width end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].width = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).width,
			width = "half",
			disabled = function() return IsSettingDisabled(_frameType, "width") end,
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("height"),
			tooltip = AUI.L10n.GetString("height_tooltip"),
			min = 16,
			max = 80,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].height end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].height = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).height,
			width = "half",
			disabled = function() return IsSettingDisabled(_frameType, "height") end,
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("opacity"),
			tooltip = AUI.L10n.GetString("opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].opacity end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].opacity = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).opacity,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "opacity") end,
		},			
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_text"),
			tooltip = AUI.L10n.GetString("show_text_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_text end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_text = value					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_text,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_text") end,
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_max_value"),
			tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_max_value end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].show_max_value = value					
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).show_max_value,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "show_max_value") end,
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].use_thousand_seperator end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].use_thousand_seperator = value
					AUI.UnitFrames.UpdateUI()
					
					if not g_isPreviewShowing then
						return
					end	
					
					AUI.UnitFrames.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, false)
				end
			end,
			default = GetDefaultSettingFromType(_frameType).use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "use_thousand_seperator") end,
		},	
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_art"),
			tooltip = AUI.L10n.GetString("font_art_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].font_art) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].font_art = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettingFromType(_frameType).font_art),
			disabled = function() return IsSettingDisabled(_frameType, "font_art") end,					
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_style"),
			tooltip = AUI.L10n.GetString("font_style_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].font_style) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].font_style = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettingFromType(_frameType).font_style),
			disabled = function() return IsSettingDisabled(_frameType, "font_style") end,					
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("font_size"),
			tooltip = AUI.L10n.GetString("font_size_tooltip"),
			min = 4,
			max = 22,
			step = 1,
			getFunc = function() return AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].font_size end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].font_size = value
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = GetDefaultSettingFromType(_frameType).font_size,
			width = "full",
			disabled = function() return IsSettingDisabled(_frameType, "font_size") end,
		},	
		{
			type = "dropdown",
			name = AUI.L10n.GetString("alignment"),
			tooltip = AUI.L10n.GetString("alignment_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Menu.GetAtrributesBarAlignmentList(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_alignment) end,
			setFunc = function(value)
				value = AUI.Table.GetKey(AUI.Menu.GetAtrributesBarAlignmentList(), value)
				if value ~= nil then
					AUI.Settings.UnitFrames.Target[GetActiveTargetTemplateName()][_frameType].bar_alignment = value							
					AUI.UnitFrames.UpdateUI()
				end
			end,
			default = AUI.Table.GetValue(AUI.Menu.GetAtrributesBarAlignmentList(), GetDefaultSettingFromType(_frameType).bar_alignment),
			disabled = function() return IsSettingDisabled(_frameType, "bar_alignment") end,					
		},				
	}
	
	return optionTable
end

local function CreateOptions()
	local options = 
	{	
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("general"))
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("acount_wide"),
			tooltip = AUI.L10n.GetString("acount_wide_tooltip"),
			getFunc = function() return AUI.Settings.MainMenu.modul_unit_frames_account_wide end,
			setFunc = function(value)
				if value ~= nil then
					if value ~= AUI.Settings.MainMenu.modul_unit_frames_account_wide then
						AUI.Settings.MainMenu.modul_unit_frames_account_wide = value
						ReloadUI()
					else
						AUI.Settings.MainMenu.modul_unit_frames_account_wide = value
					end
				end
			end,
			default = true,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_warning_tooltip"),
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("preview"),
			tooltip = AUI.L10n.GetString("preview_tooltip"),
			getFunc = function() return g_isPreviewShowing end,
			setFunc = function(value)
				if value ~= nil then
					if value == true then	
						AUI.UnitFrames.ShowPreview()	
					else
						AUI.UnitFrames.HidePreview()
					end	
					
					g_isPreviewShowing = value
				end
			end,
			default = g_isPreviewShowing,
			width = "full",
			warning = AUI.L10n.GetString("preview_warning"),	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("lock_window"),
			tooltip = AUI.L10n.GetString("lock_window_tooltip"),
			getFunc = function() return AUI.Settings.UnitFrames.lock_windows end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.UnitFrames.lock_windows = value
				end
			end,
			default = GetDefaultSettings().lock_windows,
			width = "full",
		},			
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("display")),
			controls = 
			{					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("player"),
					getFunc = function() return g_player_unit_frames_enabled end,
					setFunc = function(value)
						if value ~= nil then
							g_player_unit_frames_enabled = value
							g_changedEnabled = true
						end
					end,
					default = GetDefaultSettings().player_unit_frames_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("target"),
					getFunc = function() return g_target_unit_frames_enabled end,
					setFunc = function(value)
						if value ~= nil then
							g_target_unit_frames_enabled = value
							g_changedEnabled = true
						end
					end,
					default = GetDefaultSettings().target_unit_frames_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("group") .. " & " .. AUI.L10n.GetString("raid"),
					getFunc = function() return g_group_unit_frames_enabled end,
					setFunc = function(value)
						if value ~= nil then
							g_group_unit_frames_enabled = value
							g_changedEnabled = true
						end
					end,
					default = GetDefaultSettings().group_unit_frames_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				},				
				{
					type = "checkbox",
					name = AUI.L10n.GetString("boss"),
					getFunc = function() return g_boss_unit_frames_enabled end,
					setFunc = function(value)
						if value ~= nil then
							g_boss_unit_frames_enabled = value
							g_changedEnabled = true
						end
					end,
					default = GetDefaultSettings().boss_unit_frames_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				},	
				-- {
					-- type = "checkbox",
					-- name = AUI.L10n.GetString("companion"),
					-- getFunc = function() return g_companion_unit_frames_enabled end,
					-- setFunc = function(value)
						-- if value ~= nil then
							-- g_companion_unit_frames_enabled = value
							-- g_changedEnabled = true
						-- end
					-- end,
					-- default = GetDefaultSettings().companion_unit_frames_enabled,
					-- width = "full",
					-- warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				-- },				
				{
					type = "button",
					name = AUI.L10n.GetString("accept_settings"),
					tooltip = AUI.L10n.GetString("accept_settings_tooltip"),
					func = function() AcceptEnabledSettings() end,
					disabled = function() return not g_changedEnabled end,
				},		
			}
		},
		{	
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("themes")),
			controls = 
			{		
				{
					type = "dropdown",
					name = AUI.L10n.GetString("player"),
					choices = AUI.Table.GetChoiceList(AUI.UnitFrames.GetThemeNames("Player"), "value"),
					getFunc = function() 	
						return AUI.Table.GetValue(AUI.UnitFrames.GetThemeNames("Player"), g_player_unit_frames_Template)						
					end,
					setFunc = function(value) 
						value = AUI.Table.GetKey(AUI.UnitFrames.GetThemeNames("Player"), value)
						if value ~= nil then
							g_player_unit_frames_Template = value
							g_changedTemplate = true
						end
					end,
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
					disabled = function() return not AUI.UnitFrames.Player.IsEnabled() end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("target"),
					choices = AUI.Table.GetChoiceList(AUI.UnitFrames.GetThemeNames("Target"), "value"),
					getFunc = function() 					
						return AUI.Table.GetValue(AUI.UnitFrames.GetThemeNames("Target"), g_target_unit_frames_Template)						
					end,
					setFunc = function(value) 
						value = AUI.Table.GetKey(AUI.UnitFrames.GetThemeNames("Target"), value)
						if value ~= nil then
							g_target_unit_frames_Template = value
							g_changedTemplate = true
						end
					end,
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
					disabled = function() return not AUI.UnitFrames.Target.IsEnabled() end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("group"),
					choices = AUI.Table.GetChoiceList(AUI.UnitFrames.GetThemeNames("Group"), "value"),
					getFunc = function() 					
						return AUI.Table.GetValue(AUI.UnitFrames.GetThemeNames("Group"), g_group_unit_frames_Template)						
					end,
					setFunc = function(value) 
						value = AUI.Table.GetKey(AUI.UnitFrames.GetThemeNames("Group"), value)
						if value ~= nil then
							g_group_unit_frames_Template = value
							g_changedTemplate = true
						end
					end,
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
					disabled = function() return not AUI.UnitFrames.Group.IsEnabled() end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("raid"),
					choices = AUI.Table.GetChoiceList(AUI.UnitFrames.GetThemeNames("Raid"), "value"),
					getFunc = function() 					
						return AUI.Table.GetValue(AUI.UnitFrames.GetThemeNames("Raid"), g_raid_unit_frames_Template)						
					end,
					setFunc = function(value) 
						value = AUI.Table.GetKey(AUI.UnitFrames.GetThemeNames("Raid"), value)
						if value ~= nil then
							g_raid_unit_frames_Template = value
							g_changedTemplate = true
						end
					end,
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
					disabled = function() return not AUI.UnitFrames.Raid.IsEnabled() end,
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("boss"),
					choices = AUI.Table.GetChoiceList(AUI.UnitFrames.GetThemeNames("Boss"), "value"),
					getFunc = function() 					
						return AUI.Table.GetValue(AUI.UnitFrames.GetThemeNames("Boss"), g_boss_unit_frames_Template)						
					end,
					setFunc = function(value) 
						value = AUI.Table.GetKey(AUI.UnitFrames.GetThemeNames("Boss"), value)
						if value ~= nil then
							g_boss_unit_frames_Template = value
							g_changedTemplate = true
						end
					end,
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
					disabled = function() return not AUI.UnitFrames.Boss.IsEnabled() end,
				},	
				-- {
					-- type = "dropdown",
					-- name = AUI.L10n.GetString("companion"),
					-- choices = AUI.Table.GetChoiceList(AUI.UnitFrames.GetThemeNames("Companion"), "value"),
					-- getFunc = function() 					
						-- return AUI.Table.GetValue(AUI.UnitFrames.GetThemeNames("Companion"), g_companion_unit_frames_Template)						
					-- end,
					-- setFunc = function(value) 
						-- value = AUI.Table.GetKey(AUI.UnitFrames.GetThemeNames("Companion"), value)
						-- if value ~= nil then
							-- g_companion_unit_frames_Template = value
							-- g_changedTemplate = true
						-- end
					-- end,
					-- warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
					-- disabled = function() return not AUI.UnitFrames.Companion.IsEnabled() end,
				-- },				
				{
					type = "button",
					name = AUI.L10n.GetString("accept_settings"),
					tooltip = AUI.L10n.GetString("accept_settings_tooltip"),
					func = function() AcceptTemplateSettings() end,
					disabled = function() return not g_changedTemplate end,
				}				
			}
		}		
	}
	
	local optionsCount = 0
	for i = 1, #options do 
		optionsCount = optionsCount + 1
	end				
	
	if optionsCount > 0 then	
		local optionsColorTable = 
		{			
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("colors")),
			controls = {}
		}
	
		if g_player_unit_frames_enabled then
			local playerColorOptionTable = GetPlayerColorSettingsTable()
			for i = 1, #playerColorOptionTable do 
				table.insert(optionsColorTable.controls, playerColorOptionTable[i]) 
			end		
		end	
		
		if g_target_unit_frames_enabled and DoesAttributeIdExists(AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH) then
			local submenuName = AUI.L10n.GetString("target")
			if DoesAttributeIdExists(AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH) then
				submenuName = submenuName .. " (" .. AUI.L10n.GetString("primary") .. ")"
			end	
		
			local targetColorOptionTable = GetTargetColorSettingsTable(AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH, submenuName)
			for i = 1, #targetColorOptionTable do 
				table.insert(optionsColorTable.controls, targetColorOptionTable[i]) 
			end		
		end	
		
		if g_target_unit_frames_enabled and DoesAttributeIdExists(AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH) then
			local submenuName = AUI.L10n.GetString("target")
			if DoesAttributeIdExists(AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH) then
				submenuName = submenuName .. " (" .. AUI.L10n.GetString("secondary") .. ")"
			end	
		
			local targetColorOptionTable = GetTargetColorSettingsTable(AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH, AUI.L10n.GetString("target") .. " " .. AUI.L10n.GetString("secondary") .. ")")
			for i = 1, #targetColorOptionTable do 
				table.insert(optionsColorTable.controls, targetColorOptionTable[i] ) 
			end	
		end	

		if g_group_unit_frames_enabled then
			local groupColorOptionTable = GetGroupColorSettingsTable()
			for i = 1, #groupColorOptionTable do 
				table.insert(optionsColorTable.controls, groupColorOptionTable[i]) 
			end	

			local raidColorOptionTable = GetRaidColorSettingsTable()
			for i = 1, #raidColorOptionTable do 
				table.insert(optionsColorTable.controls, raidColorOptionTable[i]) 
			end				
		end	
		

		if g_boss_unit_frames_enabled then
			local bossColorOptionTable = GetBossColorSettingsTable()
			for i = 1, #bossColorOptionTable do 
				table.insert(optionsColorTable.controls, bossColorOptionTable[i]) 
			end		
		end		
		
		table.insert(options, optionsColorTable) 	
	end

	if g_player_unit_frames_enabled then
		local playerOptionTable = GetPlayerSettingsTable()
		for i = 1, #playerOptionTable do 
			table.insert(options, playerOptionTable[i]) 
		end		
	end
	
	if g_target_unit_frames_enabled and DoesAttributeIdExists(AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH) then
		local submenuName = AUI.L10n.GetString("target") .. " (" .. AUI.L10n.GetString("primary") .. ")"	
		local targetPrimarySubmenu = GetSubmenuTable(submenuName)	
		local targetPrimaryOptions = GetTargetSettingTable(AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH)
		local targetPrimaryShieldOptions = GetTargetShieldSettingTable(AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_SHIELD)

		for i = 1, #targetPrimaryOptions do		
			table.insert(targetPrimarySubmenu.controls, targetPrimaryOptions[i]) 
		end	
		
		for i = 1, #targetPrimaryShieldOptions do		
			table.insert(targetPrimarySubmenu.controls, targetPrimaryShieldOptions[i]) 
		end				

		table.insert(options, targetPrimarySubmenu) 
	end
	
	if g_target_unit_frames_enabled and DoesAttributeIdExists(AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH) then
		local submenuName = AUI.L10n.GetString("target") .. " (" .. AUI.L10n.GetString("secondary") .. ")"	
		local targetSecondarySubmenu = GetSubmenuTable(submenuName)	
		local targetSecondaryOptions = GetTargetSettingTable(AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH)
		local targetSecondaryShieldOptions = GetTargetShieldSettingTable(AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_SHIELD)

		for i = 1, #targetSecondaryOptions do		
			table.insert(targetSecondarySubmenu.controls, targetSecondaryOptions[i]) 
		end	
		
		for i = 1, #targetSecondaryShieldOptions do		
			table.insert(targetSecondarySubmenu.controls, targetSecondaryShieldOptions[i]) 
		end		

		table.insert(options, targetSecondarySubmenu) 
	end	
	
	if g_group_unit_frames_enabled then
		local groupSubmenu = GetSubmenuTable(AUI.L10n.GetString("group"))	
		local groupOptions = GetGroupSettingsTable()
		local groupShieldOptions = GetGroupShieldSettingsTable()
		local groupCompanionOptions = GetGroupCompanionSettingsTable()
	
		for i = 1, #groupOptions do		
			table.insert(groupSubmenu.controls, groupOptions[i]) 
		end		

		for i = 1, #groupShieldOptions do 
			table.insert(groupSubmenu.controls, groupShieldOptions[i]) 
		end		
	
		for i = 1, #groupCompanionOptions do 
			table.insert(groupSubmenu.controls, groupCompanionOptions[i]) 
		end	
	
		table.insert(options, groupSubmenu) 

		local raidSubmenu = GetSubmenuTable(AUI.L10n.GetString("raid"))	
		local raidOptions = GetRaidSettingsTable()
		local raidShieldOptions = GetRaidShieldSettingsTable()
		local raidCompanionOptions = GetRaidCompanionSettingsTable()
	
		for i = 1, #raidOptions do		
			table.insert(raidSubmenu.controls, raidOptions[i]) 
		end		

		for i = 1, #raidShieldOptions do 
			table.insert(raidSubmenu.controls, raidShieldOptions[i]) 
		end		
	
		for i = 1, #raidCompanionOptions do 
			table.insert(raidSubmenu.controls, raidCompanionOptions[i]) 
		end		
	
		table.insert(options, raidSubmenu) 	
	end

	if g_boss_unit_frames_enabled then
		local bossAUIOptions = GetBossAUISettingsTable()
		for i = 1, #bossAUIOptions do 
			table.insert(options, bossAUIOptions[i]) 
		end			
	
		local bossDefaultOptions = GetBossDefaultSettingsTable()
		for i = 1, #bossDefaultOptions do 
			table.insert(options, bossDefaultOptions[i]) 
		end		
	end
	
	local footerOptions = 
	{
		{
			type = "header",
		},		
		{
			type = "button",
			name = AUI.L10n.GetString("reset_to_default_position"),
			tooltip = AUI.L10n.GetString("reset_to_default_position_tooltip"),
			func = function() SetToDefaultPosition() end,
		},		
	}	
	
	for i = 1, #footerOptions do 
		table.insert(options , footerOptions[i] ) 
	end		
	
	return options
end

function AUI.UnitFrames.LoadSettings()
	if g_isInit then
		return
	end

	local panelData = 
	{
		type = "panel",
		name = AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("attributes_module_name") .. ")",
		displayName = "|cFFFFB0" .. AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("attributes_module_name") .. ")",
		author = AUI_TXT_COLOR_AUTHOR:Colorize(AUI_ATTRIBUTE_AUTHOR),
		version = AUI_TXT_COLOR_VERSION:Colorize(AUI_ATTRIBUTE_VERSION),
		slashCommand = "/auiuf",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	if AUI.Settings.MainMenu.modul_unit_frames_account_wide then
		AUI.Settings.UnitFrames = ZO_SavedVars:NewAccountWide("AUI_Attributes", 10, nil, GetDefaultSettings())
	else
		AUI.Settings.UnitFrames = ZO_SavedVars:New("AUI_Attributes", 10, nil, GetDefaultSettings())
	end		
	
	g_player_unit_frames_enabled = AUI.Settings.UnitFrames.player_unit_frames_enabled
	g_target_unit_frames_enabled = AUI.Settings.UnitFrames.target_unit_frames_enabled
	g_group_unit_frames_enabled = AUI.Settings.UnitFrames.group_unit_frames_enabled	
	g_boss_unit_frames_enabled = AUI.Settings.UnitFrames.boss_unit_frames_enabled
	g_companion_unit_frames_enabled = AUI.Settings.UnitFrames.companion_unit_frames_enabled

	if g_player_unit_frames_enabled then
		g_player_unit_frames_Template = GetActivePlayerTemplateName()
	else
		AUI.UnitFrames.SetDeactivePlayerTemplate()
	end

	if g_target_unit_frames_enabled then
		g_target_unit_frames_Template = GetActiveTargetTemplateName()
	else
		AUI.UnitFrames.SetDeactiveTargetTemplate()
	end
	
	if g_group_unit_frames_enabled then
		g_group_unit_frames_Template = GetActiveGroupTemplateName()
		g_raid_unit_frames_Template = GetActiveRaidTemplateName()
	else
		AUI.UnitFrames.SetDeactiveGroupTemplate()
		AUI.UnitFrames.SetDeactiveRaidTemplate()
	end
	
	if g_boss_unit_frames_enabled then
		g_boss_unit_frames_Template = GetActiveBossTemplateName()
	else
		AUI.UnitFrames.SetDeactiveBossTemplate()
	end

	if g_companion_unit_frames_enabled then
		g_companion_unit_frames_Template = GetActiveCompanionTemplateName()
	else
		AUI.UnitFrames.SetDeactiveCompanionTemplate()
	end

	g_LAM:RegisterOptionControls("AUI_Menu_UnitFrames", CreateOptions())
	g_LAM:RegisterAddonPanel("AUI_Menu_UnitFrames", panelData)
	
	SetAnchors()
	SetFrameSettings()	
	
	g_isInit = true
end
