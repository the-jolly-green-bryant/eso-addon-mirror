AUI.Menu = {}

AUI_UNIT_FRAMES_MODE_TITLE = 0
AUI_UNIT_FRAMES_MODE_CHARACTER_NAME = 1
AUI_UNIT_FRAMES_MODE_ACCOUNT_NAME = 2
AUI_UNIT_FRAMES_MODE_CHARACTER_NAME_TITLE = 3
AUI_UNIT_FRAMES_MODE_ACCOUNT_NAME_TITLE = 4

function AUI.Menu.GetFontTypeList()
	local fontTypeList = 
	{
		[0] = {["EsoUI/Common/Fonts/univers55.slug"]							= "Univers 55"},
		[1] = {["esoui/common/fonts/univers57.slug"]							= "Univers 57"},
		[2] = {["EsoUI/Common/Fonts/univers67.slug"]							= "Univers 67"},
		[3] = {["EsoUI/Common/Fonts/ProseAntiquePSMT.slug"]						= "ProseAntique"},
		[4] = {["EsoUI/Common/Fonts/consola.slug"]								= "Consolas"},
		[5] = {["EsoUI/Common/Fonts/FTN57.slug"]								= "Futura Condensed"},
		[6] = {["EsoUI/Common/Fonts/FTN87.slug"]								= "FTN87"},
		[7] = {["EsoUI/Common/Fonts/FTN47.slug"]								= "Futura Condensed Light"},
		[8] = {["EsoUI/Common/Fonts/FTN47.slug"]								= "Skyrim Handwritten"},
		[9] = {["EsoUI/Common/Fonts/trajanpro-regular.slug"]					= "Trajan Pro"},
		[10] = {["AUI/fonts/Kingthings_Calligraphica_2.slug"]					= "Calligraphica"},
		[11] = {["AUI/fonts/Almendra-Bold.slug"]								= "Almendra"},
		[12] = {["AUI/fonts/SansitaOne.slug"]									= "Sansita One"},
	    [13] = {["AUI/fonts/Bellota-Bold.slug"]									= "Bellota"},
		[14] = {["esoui/common/fonts/eso_fwudc_70-m.slug"]						= "ESO-FWUDC_70 M"},
		[15] = {["esoui/common/fonts/eso_fwntlgudc70-db.slug"]					= "ESO-FWNTLGUDC70 DB"},
		[16] = {["esoui/common/fonts/myingheiprc-w5.slug"]						= "Myingheiprc-w5"}		
	}
	
	return fontTypeList
end

function AUI.Menu.GetFontStyleList()
	local fontStyleList = 
	{
		[0] = {["normal"] 						 = AUI.L10n.GetString("font_style_normal")},
		[1] = {["outline"]						 = AUI.L10n.GetString("font_style_outline")},
		[2] = {["thick-outline"]		   	   	 = AUI.L10n.GetString("font_style_outline_thick")},
		[3] = {["shadow"]				   		 = AUI.L10n.GetString("font_style_shadow")},
		[4] = {["soft-shadow-thick"]	   	   	 = AUI.L10n.GetString("font_style_shadow_thick")},
		[5] = {["soft-shadow-thin"] 		   	 = AUI.L10n.GetString("font_style_shadow_thin")}
	}
	
	return fontStyleList
end

function AUI.Menu.GetTopAndBottomList()
	local positionTopAndBottomList = 
	{
		[0] = {["top"] 						= AUI.L10n.GetString("top")},
		[1] = {["bottom"] 					= AUI.L10n.GetString("bottom")}
	}
	
	return positionTopAndBottomList
end

function AUI.Menu.GetAtrributesBarAlignmentList()
	local list = 
	{
		[100] = {[BAR_ALIGNMENT_NORMAL] 			= AUI.L10n.GetString("normal")},
		[101] = {[BAR_ALIGNMENT_REVERSE]			= AUI.L10n.GetString("reverse")},
		[102] = {[BAR_ALIGNMENT_CENTER]				= AUI.L10n.GetString("center")}		
	}
	
	return list
end

function AUI.Menu.GetTextAnimationList()
	local textAnimationList = 
	{
		[0] = {[AUI_ANIMATION_VERTICAL] 			= AUI.L10n.GetString("vertical")},
		[1] = {[AUI_ANIMATION_ECLIPSE]				= AUI.L10n.GetString("eclipse")}
	}
	
	return textAnimationList
end


function AUI.Menu.GetAlignmentList()
	local list = 
	{
		[0] = {[AUI_VERTICAL] 					= AUI.L10n.GetString("vertical")},
		[1] = {[AUI_VERTICAL_REVERSE] 			= AUI.L10n.GetString("vertical_reverse")},
		[2] = {[AUI_HORIZONTAL] 				= AUI.L10n.GetString("horizontal")},
		[3] = {[AUI_HORIZONTAL_REVERSE] 		= AUI.L10n.GetString("horizontal_reverse")}
	}
	
	return list
end

function AUI.Menu.GetAnchorList()
	local list = 
	{
		[0] = {[AUI_TEXT_ANCHOR_INSIDE] 				= AUI.L10n.GetString("inside")},
		[1] = {[AUI_TEXT_ANCHOR_OUTSIDE] 				= AUI.L10n.GetString("outside")}
	}
	
	return list
end

function AUI.Menu.GetSortingList()
	local list = 
	{
		[0] = {[AUI_SORTING_SMALL_TO_LARGE] 			= AUI.L10n.GetString("small_to_large")},
		[1] = {[AUI_SORTING_LARGE_TO_SMALL] 			= AUI.L10n.GetString("large_to_small")}
	}
	
	return list
end


function AUI.Menu.GetTextAnimationTypeList()
	local textAnimationTypeList = 
	{
		[0] = {[AUI_ANIMATION_MODE_FORWARD] 				= AUI.L10n.GetString("normal")},
		[1] = {[AUI_ANIMATION_MODE_BACKWARD]				= AUI.L10n.GetString("backward")},
		[2] = {[AUI_ANIMATION_MODE_REVERSE_FORWARD] 		= AUI.L10n.GetString("normal_reverse")},
		[3] = {[AUI_ANIMATION_MODE_REVERSE_BACKWARD]		= AUI.L10n.GetString("backward_reverse")}	
	}
	
	return textAnimationTypeList
end

function AUI.Menu.GetCaptionTypeList()
	local positionTopAndBottomList = 
	{
		[100] = {[AUI_UNIT_FRAMES_MODE_TITLE] 						= AUI.L10n.GetString("title")},
		[101] = {[AUI_UNIT_FRAMES_MODE_CHARACTER_NAME] 				= AUI.L10n.GetString("character_name")},
		[102] = {[AUI_UNIT_FRAMES_MODE_ACCOUNT_NAME] 				= AUI.L10n.GetString("account_name")},
		[103] = {[AUI_UNIT_FRAMES_MODE_CHARACTER_NAME_TITLE] 		= AUI.L10n.GetString("character_name") .. " + " .. AUI.L10n.GetString("title")},
		[104] = {[AUI_UNIT_FRAMES_MODE_ACCOUNT_NAME_TITLE] 			= AUI.L10n.GetString("account_name") .. " + " .. AUI.L10n.GetString("title")}
	}
	
	return positionTopAndBottomList
end

function AUI.Menu.GetSCTPanelTypeList()
	local panelList= AUI.Combat.Text.GetPanelList()
	local panelTypeList = {}
	
	for internName, data in pairs(panelList) do
		table.insert(panelTypeList, {[internName] = data.name})
	end
	
	return panelTypeList
end
