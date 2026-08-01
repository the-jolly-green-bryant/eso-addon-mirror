local templates = {}
local tempGroupFames = {}
local tempRaidFames = {}	
local tempBossFames = {}
local currentTemplate = nil

function AUI.Attributes.GetTemplateNames()
	local names = {}

	for _internName, data in pairs(templates) do	
		table.insert(names, {[_internName] = data.name})
	end

	return names
end

function AUI.Attributes.GetCurrentTemplateData()
	return currentTemplate	
end

local function SetAnchors()
	for type, data in pairs(currentTemplate.attributeData) do
		local relativeTo = nil
		if data.control then
			if data.control.relativeTo then
				relativeTo = currentTemplate.attributeData[data.control.relativeTo].control
			end					
			
			local anchorData = AUI.Settings.Attributes[currentTemplate.internName][data.control.attributeId].anchor_data		
			if anchorData then
				data.control:ClearAnchors()
				if anchorData[0] then	
					data.control:SetAnchor(anchorData[0].point, relativeTo or GuiRoot, anchorData[0].relativePoint, anchorData[0].offsetX, anchorData[0].offsetY)
				end
					
				if anchorData[1] and anchorData[1].point ~= NONE then
					data.control:SetAnchor(anchorData[1].point, relativeTo or GuiRoot, anchorData[1].relativePoint, anchorData[1].offsetX, anchorData[1].offsetY)
				end		
			end	
		end
	end	
end

local function GetDefaultData(_type, _templateData)
	local data = {}
	
	if not _templateData["default_settings"] then
		 _templateData["default_settings"] = {}
	end		
	
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
	
	if _type == AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})	
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal	
		data.show_increase_regen_color = _templateData["default_settings"].show_inc_regen_color == nil or _templateData["default_settings"].show_inc_regen_color	
		data.show_decrease_regen_color = _templateData["default_settings"].show_dec_regen_color == nil or _templateData["default_settings"].show_dec_regen_color
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 14
		data.font_style = _templateData["default_settings"].font_style or "outline"
	elseif _type == AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA then	
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#001f61"), AUI.Color.ConvertHexToRGBA("#003bbb")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text		
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal	
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 14
		data.font_style = _templateData["default_settings"].font_style or "outline"		
	elseif _type == AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#024600"), AUI.Color.ConvertHexToRGBA("#365f00")})	
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal			
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 14
		data.font_style = _templateData["default_settings"].font_style or "outline"		
	elseif _type == AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#384800"), AUI.Color.ConvertHexToRGBA("#4d6300")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == true		
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal			
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 12
		data.font_style = _templateData["default_settings"].font_style or "outline"			
	elseif _type == AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#653300"), AUI.Color.ConvertHexToRGBA("#84461a")})		
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == true								
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal		
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 12
		data.font_style = _templateData["default_settings"].font_style or "outline"					
	elseif _type == AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})	
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == true						
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal			
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 15
		data.font_style = _templateData["default_settings"].font_style or "outline"							
	elseif _type == AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#034a6f")})	
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text			
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal				
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"					
	elseif _type == AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})		
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.bar_friendly_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#123c00"), AUI.Color.ConvertHexToRGBA("#237101")})
		data.bar_allied_npc_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#123c00"), AUI.Color.ConvertHexToRGBA("#237101")})
		data.bar_allied_player_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#002f3a"), AUI.Color.ConvertHexToRGBA("#004961")})
		data.bar_neutral_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#533e02"), AUI.Color.ConvertHexToRGBA("#958403")})	
		data.bar_guard_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#252221"), AUI.Color.ConvertHexToRGBA("#3b3736")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_account_name = _templateData["default_settings"].show_account_name == nil or _templateData["default_settings"].show_account_name	
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text					
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].show_percent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal		
		data.show_increase_regen_color = _templateData["default_settings"].show_inc_regen_color == true	
		data.show_decrease_regen_color = _templateData["default_settings"].show_dec_regen_color == true		
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 15
		data.font_style = _templateData["default_settings"].font_style or "outline"
	elseif _type == AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_SHIELD then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#034a6f")})	
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text			
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal		
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 15
		data.font_style = _templateData["default_settings"].font_style or "outline"		
	elseif _type == AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})	
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.bar_friendly_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#237101"), AUI.Color.ConvertHexToRGBA("#33a103")})
		data.bar_allied_npc_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#237101"), AUI.Color.ConvertHexToRGBA("#1b449d")})
		data.bar_allied_player_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#004961"), AUI.Color.ConvertHexToRGBA("#006156")})
		data.bar_neutral_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#958403"), AUI.Color.ConvertHexToRGBA("#a49a00")})	
		data.bar_guard_color = AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#252221"), AUI.Color.ConvertHexToRGBA("#3b3736")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_account_name = _templateData["default_settings"].show_account_name == nil or _templateData["default_settings"].show_account_name	
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text			
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal		
		data.show_increase_regen_color = _templateData["default_settings"].show_inc_regen_color == true	
		data.show_decrease_regen_color = _templateData["default_settings"].show_dec_regen_color == true	
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 15
		data.font_style = _templateData["default_settings"].font_style or "outline"
	elseif _type == AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_SHIELD then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#034a6f")})			
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text			
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal		
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 15
		data.font_style = _templateData["default_settings"].font_style or "outline"		
	elseif _type == AUI_ATTRIBUTE_TYPE_GROUP_HEALTH then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})	
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.out_of_range_opacity = 0.5	
		data.show_account_name = _templateData["default_settings"].show_account_name == nil or _templateData["default_settings"].show_account_name	
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text		
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal		
		data.show_increase_regen_color = _templateData["default_settings"].show_inc_regen_color == nil or _templateData["default_settings"].show_inc_regen_color	
		data.show_decrease_regen_color = _templateData["default_settings"].show_dec_regen_color == nil or _templateData["default_settings"].show_dec_regen_color
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 12
		data.font_style = _templateData["default_settings"].font_style or "outline"	
		data.row_distance = _templateData["default_settings"].row_distance or 42
	elseif _type == AUI_ATTRIBUTE_TYPE_GROUP_SHIELD then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#013753")})
		data.opacity = _templateData["default_settings"].opacity or 1
		data.out_of_range_opacity = _templateData["default_settings"].out_of_range_opacity or 0.5	
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text		
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal		
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 12
		data.font_style = _templateData["default_settings"].font_style or "outline"
	elseif _type == AUI_ATTRIBUTE_TYPE_RAID_HEALTH then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.out_of_range_opacity = 0.5	
		data.show_account_name = _templateData["default_settings"].show_account_name == nil or _templateData["default_settings"].show_account_name	
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text			
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal		
		data.show_increase_regen_color = _templateData["default_settings"].show_inc_regen_color == nil or _templateData["default_settings"].show_inc_regen_color	
		data.show_decrease_regen_color = _templateData["default_settings"].show_dec_regen_color == nil or _templateData["default_settings"].show_dec_regen_color
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"	
		data.row_distance = _templateData["default_settings"].row_distance or 12
		data.column_distance = _templateData["default_settings"].column_distance or 12		
		data.row_count = _templateData["default_settings"].row_count or 4
	elseif _type == AUI_ATTRIBUTE_TYPE_RAID_SHIELD then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#034a6f")})
		data.opacity = _templateData["default_settings"].opacity or 1
		data.out_of_range_opacity = 0.5	
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text	
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal	
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 12
		data.font_style = _templateData["default_settings"].font_style or "outline"
	elseif _type == AUI_ATTRIBUTE_TYPE_BOSS_HEALTH then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#520000"), AUI.Color.ConvertHexToRGBA("#950000")})
		data.increase_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_reg_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#ab7900"), AUI.Color.ConvertHexToRGBA("#694a00")})
		data.decrease_regen_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color_dec_inc) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#742679"), AUI.Color.ConvertHexToRGBA("#431546")})		
		data.width = data.width
		data.height = data.height
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text		
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal	
		data.show_increase_regen_color = _templateData["default_settings"].show_inc_regen_color == nil or _templateData["default_settings"].show_inc_regen_color	
		data.show_decrease_regen_color = _templateData["default_settings"].show_dec_regen_color == nil or _templateData["default_settings"].show_dec_regen_color		
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 10
		data.font_style = _templateData["default_settings"].font_style or "outline"	
		data.row_distance = _templateData["default_settings"].row_distance or 8
		data.column_distance = _templateData["default_settings"].column_distance or 12		
		data.row_count = _templateData["default_settings"].row_count or 6
	elseif _type == AUI_ATTRIBUTE_TYPE_BOSS_SHIELD then
		data.bar_color = AUI.Color.GetColorDef(_templateData["default_settings"].bar_color) or AUI.Color.GetColorDef({AUI.Color.ConvertHexToRGBA("#07174e"), AUI.Color.ConvertHexToRGBA("#034a6f")})
		data.opacity = _templateData["default_settings"].opacity or 1
		data.show_text = _templateData["default_settings"].show_text == nil or _templateData["default_settings"].show_text	
		data.show_max_value = _templateData["default_settings"].show_max_value == true
		data.showPercent = _templateData["default_settings"].showPercent == nil or _templateData["default_settings"].show_percent
		data.use_thousand_seperator = _templateData["default_settings"].use_decimal == nil or _templateData["default_settings"].use_decimal	
		data.font_art = _templateData["default_settings"].font_art or "Sansita One"
		data.font_size = _templateData["default_settings"].font_size or 12
		data.font_style = _templateData["default_settings"].font_style or "outline"		
	end

	data.display = true
	
	return data
end

function AUI.Attributes.AddTemplate(_name, _internName, _version, _data, _isCompact)
	if not _name or not _internName or not _version or not _data then
		return
	end

	local data = {}
	data.version = _version
	data.name = _name
	data.internName = _internName
	data.isCompact = _isCompact
	data.attributeData = _data
	if not templates[_internName] then
		templates[_internName] = data
	end
end

function AUI.Attributes.ResetControlData(_control)
	if not _control.data then
		_control.data = {}		
	end
	
	_control.data.currentValue = 0
	_control.data.maxValue = 1
	_control.data.regenValue = 0
	
	if not _control.data.increaseRegenData then
		_control.data.increaseRegenData = {}
	end
	
	_control.data.increaseRegenData.isActive = false
	_control.data.increaseRegenData.isChanged = false
	_control.data.increaseRegenData.value = 0
				
	if not _control.data.decreaseRegenData then			
		_control.data.decreaseRegenData = {}
	end
	
	_control.data.decreaseRegenData.isActive = false
	_control.data.decreaseRegenData.isChanged = false
	_control.data.decreaseRegenData.value = 0
	
	if not _control.data.shield then	
		_control.data.shield = {}		
	end
	
	_control.data.shield.isActive = false
	_control.data.shield.isChanged = false		
	
	if not _control.data.warner then	
		_control.data.warner = {}	
	end
	
	_control.data.warner.isActive = true
	
	if not _control.data.increaseArmorEffect then
		_control.data.increaseArmorEffect = {}
		_control.data.increaseArmorEffect.isActive = true	
		_control.data.increaseArmorEffect.isChanged = false	
	end
	
	if not _control.data.decreaseArmorEffect then
		_control.data.decreaseArmorEffect = {}	
	end
	
	_control.data.decreaseArmorEffect.isActive = true	
	_control.data.decreaseArmorEffect.isChanged = false		
	
	if not _control.data.increasePowerEffect then
		_control.data.increasePowerEffect = {}
	end
	
	_control.data.increasePowerEffect.isActive = true	
	_control.data.increasePowerEffect.isChanged = false		
	
	if not _control.data.decreasePowerEffect then
		_control.data.decreasePowerEffect = {}
	end
	
	_control.data.decreasePowerEffect.isActive = true	
	_control.data.decreasePowerEffect.isChanged = false		
end

local function SetControlData(_control)
	if _control then
		local controlName = _control:GetName()
	
		AUI.Attributes.ResetControlData(_control)
	
		_control.bar = GetControl(_control, "_Bar")	
		_control.barLeft = GetControl(_control, "_BarLeft")	
		_control.barRight =  GetControl(_control, "_BarRight")	

		if _control.bar then
			_control.bar.barGloss = GetControl(_control.bar, "Gloss")	
			
			_control.bar.increaseRegLeftControl = GetControl(_control.bar, "_IncreaseRegLeft")	
			_control.bar.increaseRegRightControl = GetControl(_control.bar, "_IncreaseRegRight")	
			_control.bar.decreaseRegLeftControl = GetControl(_control.bar, "_DecreaseRegLeft")	
			_control.bar.decreaseRegRightControl = GetControl(_control.bar, "_DecreaseRegRight")	

			if _control.bar.increaseRegLeftControl then
				_control.bar.increaseRegLeftAnim = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.bar.increaseRegLeftControl)			
			end		

			if _control.bar.increaseRegRightControl then
				_control.bar.increaseRegRightAnim = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.bar.increaseRegRightControl)				
			end	

			if _control.bar.decreaseRegLeftControl then
				_control.bar.decreaseRegLeftAnim = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.bar.decreaseRegLeftControl)				
			end		

			if _control.bar.decreaseRegRightControl then
				_control.bar.decreaseRegRightAnim = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.bar.decreaseRegRightControl)				
			end				
		end

		if _control.barLeft then
			_control.barLeft.barGloss = GetControl(_control.barLeft, "Gloss")
			_control.barLeft.increaseRegLeftControl = GetControl(_control.barLeft, "_IncreaseRegLeft")		
			_control.barLeft.decreaseRegLeftControl = GetControl(_control.barLeft, "_DecreaseRegLeft")	

			if _control.barLeft.increaseRegLeftControl and not _control.barLeft.increaseRegLeftAnim then
				_control.barLeft.increaseRegLeftAnim = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.barLeft.increaseRegLeftControl)				
			end	

			if _control.barLeft.decreaseRegLeftControl and not _control.barLeft.decreaseRegLeftAnim then
				_control.barLeft.decreaseRegLeftAnim = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.barLeft.decreaseRegLeftControl)					
			end				
		end
		
		if _control.barRight then
			_control.barRight.barGloss = GetControl(_control.barRight, "Gloss")					
			_control.barRight.increaseRegRightControl = GetControl(_control.barRight, "_IncreaseRegRight")	
			_control.barRight.decreaseRegRightControl = GetControl(_control.barRight, "_DecreaseRegRight")

			if _control.barRight.increaseRegRightControl and not _control.barRight.increaseRegRightAnim then
				_control.barRight.increaseRegRightAnim = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.barRight.increaseRegRightControl)				
			end	

			if _control.barRight.decreaseRegRightControl and not _control.barRight.decreaseRegRightAnim then
				_control.barRight.decreaseRegRightAnim = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.barRight.decreaseRegRightControl)				
			end				
		end		
		

		_control.textValueControl = GetControl(_control, "_Text_Value")
		_control.textMaxValueControl = GetControl(_control, "_Text_MaxValue")
		_control.textPercentControl = GetControl(_control, "_Text_Percent")
		_control.leaderIconControl = GetControl(_control, "_LeaderIcon")	
		_control.levelControl = GetControl(_control, "_Text_Level")	
		_control.championIconControl = GetControl(_control, "_ChampionIcon")	
		_control.classIconControl = GetControl(_control, "_ClassIcon")	
		_control.rankIconControl = GetControl(_control, "_RankIcon")	
		_control.titleControl = GetControl(_control, "_Title")	
		_control.unitNameControl = GetControl(_control, "_Text_Name")
		_control.offlineInfoControl = GetControl(_control, "_Text_Offline")
		_control.deadInfoControl = GetControl(_control, "_Text_DeadInfo")
		_control.warnerControl = GetControl(_control, "Warner")	
		_control.leftWarnerControl = GetControl(_control, "FrameLeftWarner")	
		_control.rightWarnerControl = GetControl(_control, "FrameRightWarner")	
		_control.centerWarnerControl = GetControl(_control, "FrameCenterWarner")
		
		_control.increasedArmorOverlayControl = GetControl(_control, "IncreasedArmorOverlay")
		_control.decreasedArmorOverlayControl = GetControl(_control, "DecreasedArmorOverlay")
		_control.increasedPowerOverlayControl = GetControl(_control, "IncreasedPowerOverlay")
		_control.decreasedPowerOverlayControl = GetControl(_control, "DecreasedPowerOverlay")
	end
end

local function LoadData(templateData, type)
	local data = templateData.attributeData[type]

	if not data then
		return
	end
	
	local unitTag = nil
	local powerType = nil
	local unitAttributeVisual = nil
	local statType = nil
	local attributeType = nil
	local attributeId = nil		
	
	if type == AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH then
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_HEALTH
		attributeType = ATTRIBUTE_HEALTH		
	elseif type == AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA then	
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_MAGICKA
		attributeType = ATTRIBUTE_MAGICKA			
	elseif type == AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA then
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_STAMINA
		attributeType = ATTRIBUTE_STAMINA	
	elseif type == AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT then
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_MOUNT_STAMINA
	elseif type == AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF then
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_WEREWOLF	
	elseif type == AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE then
		unitTag = AUI_CONTROLED_SIEGE_UNIT_TAG
		powerType = POWERTYPE_HEALTH	
	elseif type == AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD then
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_HEALTH
		unitAttributeVisual = ATTRIBUTE_VISUAL_POWER_SHIELDING
		statType = STAT_MITIGATION
		attributeType = ATTRIBUTE_HEALTH
		attributeId = ATTRIBUTE_HEALTH				
	elseif type == AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH then
		unitTag = AUI_TARGET_UNIT_TAG
		powerType = POWERTYPE_HEALTH	
	elseif type == AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_SHIELD then
		unitTag = AUI_TARGET_UNIT_TAG
		powerType = POWERTYPE_HEALTH
		unitAttributeVisual = ATTRIBUTE_VISUAL_POWER_SHIELDING
		statType = STAT_MITIGATION
		attributeType = ATTRIBUTE_HEALTH
		attributeId = ATTRIBUTE_HEALTH			
	elseif type == AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH then
		unitTag = AUI_TARGET_UNIT_TAG
		powerType = POWERTYPE_HEALTH	
	elseif type == AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_SHIELD then
		unitTag = AUI_TARGET_UNIT_TAG
		powerType = POWERTYPE_HEALTH	
		unitAttributeVisual = ATTRIBUTE_VISUAL_POWER_SHIELDING
		statType = STAT_MITIGATION
		attributeType = ATTRIBUTE_HEALTH
		attributeId = ATTRIBUTE_HEALTH			
	elseif type == AUI_ATTRIBUTE_TYPE_GROUP_HEALTH then
		unitTag = AUI_GROUP_UNIT_TAG
		powerType = POWERTYPE_HEALTH				
	elseif type == AUI_ATTRIBUTE_TYPE_RAID_HEALTH then
		unitTag = AUI_GROUP_UNIT_TAG
		powerType = POWERTYPE_HEALTH		
	elseif type == AUI_ATTRIBUTE_TYPE_BOSS_HEALTH then
		unitTag = AUI_BOSS_UNIT_TAG
		powerType = POWERTYPE_HEALTH				
	end			
	
	templateData.settings[type] = {}
	local controlName = data.name		
	local isVirtual = data.virtual
	if controlName then			
		if type == AUI_ATTRIBUTE_TYPE_GROUP_HEALTH then	
			data.control = AUI_Attributes_Window_Group
			data.control.frames = {}
					
			for i = 1, 4, 1 do
				local unitTag = "group" .. i
				local frame = CreateControlFromVirtual(controlName, data.control, controlName, i)	

				frame.unitTag = unitTag
				frame.powerType = powerType
				frame.attributeId = type
				frame.unitAttributeVisual = unitAttributeVisual
				frame.statType = statType
				frame.attributeType = attributeType							
				frame:SetHidden(true)
				frame:SetAlpha(1)		
				frame.enabled = false
				frame.display = true
				frame.isGroup = true

				data.control.frames[unitTag] = frame
				tempGroupFames[unitTag] = frame	

				SetControlData(frame)		
			end						
		elseif type == AUI_ATTRIBUTE_TYPE_RAID_HEALTH then
			data.control = AUI_Attributes_Window_Raid
			data.control.frames = {}
					
			for i = 1, 24, 1 do
				local unitTag = "group" .. i
				local frame = CreateControlFromVirtual(controlName, data.control, controlName, unitTag)	
				frame.unitTag = unitTag
				frame.powerType = powerType
				frame.attributeId = type
				frame.unitAttributeVisual = unitAttributeVisual
				frame.statType = statType
				frame.attributeType = attributeType					
				frame:SetHidden(true)
				frame:SetAlpha(1)						
				frame.enabled = false
				frame.display = true				

				data.control.frames[unitTag] = frame	
				tempRaidFames[unitTag] = frame

				SetControlData(frame)						
			end	
		elseif type == AUI_ATTRIBUTE_TYPE_GROUP_SHIELD then
			data.control = AUI_Attributes_Window_Group_Shield				
			data.control.frames = {}
					
			for i = 1, 4, 1 do
				local unitTag = "group" .. i
				local frame = CreateControlFromVirtual(controlName, tempGroupFames[unitTag], controlName, i)	

				frame.unitTag = unitTag
				frame.powerType = POWERTYPE_HEALTH
				frame.unitAttributeVisual = ATTRIBUTE_VISUAL_POWER_SHIELDING
				frame.statType = STAT_MITIGATION
				frame.attributeType = ATTRIBUTE_HEALTH
				frame.attributeId = type
				frame.unitAttributeVisual = unitAttributeVisual
				frame.statType = statType
				frame.attributeType = attributeType							
				frame:SetHidden(true)
				frame:SetAlpha(1)
				frame.enabled = false
				frame.display = true

				if frame.owns then
					frame.mainControl = tempGroupFames[unitTag]
					frame.mainControl.subControl = frame
				else
					frame:SetParent(tempGroupFames[unitTag])
				end

				data.control.frames[unitTag] = frame

				SetControlData(frame)	
			end					
		elseif type == AUI_ATTRIBUTE_TYPE_RAID_SHIELD then
			data.control = AUI_Attributes_Window_Raid_Shield
			data.control.frames = {}
							
			for i = 1, 24, 1 do
				local unitTag = "group" .. i
				local frame = CreateControlFromVirtual(controlName, tempRaidFames[unitTag], controlName, i)	
				frame.unitTag = unitTag
				frame.powerType = POWERTYPE_HEALTH
				frame.unitAttributeVisual = ATTRIBUTE_VISUAL_POWER_SHIELDING
				frame.statType = STAT_MITIGATION
				frame.attributeType = ATTRIBUTE_HEALTH					
				frame.attributeId = type
				frame.unitAttributeVisual = unitAttributeVisual
				frame.statType = statType
				frame.attributeType = attributeType							
				frame:SetHidden(true)
				frame:SetAlpha(1)	
				frame.enabled = false
				frame.display = true

				if frame.owns then
					frame.mainControl = tempRaidFames[unitTag]
					frame.mainControl.subControl = frame
					frame:SetParent(frame.mainControl)
				else
					frame:SetParent(tempRaidFames[unitTag])
				end	

				data.control.frames[unitTag] = frame
				
				SetControlData(frame)	
			end		
		elseif type == AUI_ATTRIBUTE_TYPE_BOSS_HEALTH then
			data.control = AUI_Attributes_Window_Boss
			data.control.frames = {}
					
			for i = 1, MAX_BOSSES, 1 do
				local unitTag = "boss" .. i
				local frame = CreateControlFromVirtual(controlName, data.control, controlName, i)	

				frame.unitTag = unitTag
				frame.powerType = powerType
				frame.attributeId = type
				frame.unitAttributeVisual = unitAttributeVisual
				frame.statType = statType
				frame.attributeType = attributeType							
				frame:SetHidden(true)
				frame:SetAlpha(1)		
				frame.enabled = false
				frame.display = true

				data.control.frames[unitTag] = frame
				tempBossFames[unitTag] = frame	

				SetControlData(frame)						
			end	
		elseif type == AUI_ATTRIBUTE_TYPE_BOSS_SHIELD then
			data.control = AUI_Attributes_Window_Boss_Shield
			data.control.frames = {}
					
			for i = 1, MAX_BOSSES, 1 do
				local unitTag = "boss" .. i
				local frame = CreateControlFromVirtual(controlName, tempBossFames[unitTag], controlName, i)	
				frame.unitTag = unitTag
				frame.powerType = POWERTYPE_HEALTH
				frame.unitAttributeVisual = ATTRIBUTE_VISUAL_POWER_SHIELDING
				frame.statType = STAT_MITIGATION
				frame.attributeType = ATTRIBUTE_HEALTH					
				frame.attributeId = type
				frame.unitAttributeVisual = unitAttributeVisual
				frame.statType = statType
				frame.attributeType = attributeType							
				frame:SetHidden(true)
				frame:SetAlpha(1)	
				frame.enabled = false
				frame.display = true

				if frame.owns then
					frame.mainControl = tempBossFames[unitTag]
					frame.mainControl.subControl = frame
					frame:SetParent(frame.mainControl)
				else
					frame:SetParent(tempBossFames[unitTag])
				end						

				data.control.frames[unitTag] = frame
				
				SetControlData(frame)				
			end					
		else
			if isVirtual then
				data.control = CreateControlFromVirtual(controlName, AUI_Attributes_Window, controlName)	
			else
				data.control = GetControl(controlName)
			end
		end
	
		if data.control then		
			data.control.unitTag = unitTag
			data.control.powerType = powerType	
			data.control.unitAttributeVisual = unitAttributeVisual
			data.control.statType = statType
			data.control.attributeType = attributeType
			data.control.attributeId = type						
			data.control.enabled = false	
		
			if data.control.frames then
				for _, frame in pairs(data.control.frames) do
					data.control.defaultWidth = frame:GetWidth()
					data.control.defaultHeight = frame:GetHeight()				
					break
				end			
			else
				data.control.defaultWidth = data.control:GetWidth()
				data.control.defaultHeight = data.control:GetHeight()	
			end
			
			data.anchor_data = {
			}
			data.anchor_data[0] = {}
			data.anchor_data[1] = {}			
			_, data.anchor_data[0].point, _, data.anchor_data[0].relativePoint, data.anchor_data[0].offsetX, data.anchor_data[0].offsetY = data.control:GetAnchor(0)		
			_, data.anchor_data[1].point, _, data.anchor_data[1].relativePoint, data.anchor_data[1].offsetX, data.anchor_data[1].offsetY = data.control:GetAnchor(1)	

			templateData.settings[type] = GetDefaultData(type, data)
			templateData.settings[type].anchor_data = data.anchor_data					

			SetControlData(data.control)
		end		
		
		data.attributeId = type
	end		
end

function AUI.Attributes.LoadTemplate(_name)
	local templateData = templates[_name]
	
	if not templateData then
		_name = "AUI"
		templateData = templates[_name]
	end
				
	templateData.settings = {}
	templateData.settings.version = templateData.version		
	templateData.settings.show_player_always = templateData.isCompact or false	

	LoadData(templateData, AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_SHIELD)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_SHIELD)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_GROUP_HEALTH)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_GROUP_SHIELD)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_RAID_HEALTH)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_RAID_SHIELD)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_BOSS_HEALTH)
	LoadData(templateData, AUI_ATTRIBUTE_TYPE_BOSS_SHIELD)
	
	for type, data in pairs(templateData.attributeData) do	
		local controlName = data.name		
		if controlName then
			if data.control and data.control.owns and templateData.attributeData[data.control.owns] then
				data.control.mainControl = templateData.attributeData[data.control.owns].control
				data.control.mainControl.subControl = data.control
			end		
		end		
	end	
	
	currentTemplate = templateData
	
	local defaultSettings = AUI.Attributes.GetDefaultSettings()	
	defaultSettings[_name] = templateData.settings
	
	AUI.Attributes.SetMenuData()	

	if defaultSettings[_name].version <= 0 or AUI.Settings.Attributes[_name].version ~= defaultSettings[_name].version then		
		AUI.Settings.Attributes[_name] = defaultSettings[_name]
	end	
	
	for type, data in pairs(templateData.attributeData) do	
		if data.control then
			if  data.control.frames then
				if AUI.Attributes.IsGroup(type) then
					for _, frame in pairs(data.control.frames) do	
						if AUI.Attributes.IsGroup(frame.attributeId) and AUI.Attributes.Group.IsEnabled() then 
							frame.enabled = true
						end
					end
				elseif AUI.Attributes.IsBoss(type) then
					for _, frame in pairs(data.control.frames) do										
						if AUI.Attributes.IsBoss(frame.attributeId) and AUI.Attributes.Bossbar.IsEnabled() then					
							frame.enabled = true
						end
					end				
				end
			end		
		
			if AUI.Attributes.IsPlayer(type) and AUI.Attributes.Player.IsEnabled() then 
				data.control.enabled = true
			elseif AUI.Attributes.IsTarget(type) and AUI.Attributes.Target.IsEnabled() then 
				data.control.enabled = true
			elseif AUI.Attributes.IsGroup(type) and AUI.Attributes.Group.IsEnabled() then 						
				data.control.enabled = true
			elseif AUI.Attributes.IsBoss(type) and AUI.Attributes.Bossbar.IsEnabled() then
				data.control.enabled = true
			end							
		end		
	end		
	
	SetAnchors()

	tempGroupFames = nil
	tempRaidFames = nil	
	tempBossFames = nil	
	
	templateData.isLoaded = true
	
	return templateData
end

function AUI.Attributes.SetToDefaultPosition()
	local templateName = currentTemplate.internName
	local defaultSettings = AUI.Attributes.GetDefaultSettings()
	
	for type, data in pairs(currentTemplate.attributeData) do
		local anchorData = AUI.Settings.Attributes[currentTemplate.internName][data.control.attributeId].anchor_data		
		local defaultAnchorData = defaultSettings[templateName][type]["anchor_data"]
		if anchorData and defaultAnchorData then	
			anchorData[0] = AUI.Table.Copy(defaultAnchorData[0])
			anchorData[1] = AUI.Table.Copy(defaultAnchorData[1])
		end
	end	
	
	SetAnchors()
end