AUI.Menu = {}

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
		[102] = {[BAR_ALIGNMENT_CENTER]				= AUI.L10n.GetString("center")},		
	}
	
	return list
end

function AUI.Menu.GetTextAnimationList()
	local textAnimationList = 
	{
		[0] = {[AUI_ANIMATION_VERTICAL] 			= AUI.L10n.GetString("vertical")},
		[1] = {[AUI_ANIMATION_ECLIPSE]				= AUI.L10n.GetString("eclipse")},
	}
	
	return textAnimationList
end


function AUI.Menu.GetAlignmentList()
	local list = 
	{
		[0] = {[AUI_VERTICAL] 				= AUI.L10n.GetString("vertical")},
		[1] = {[AUI_VERTICAL_REVERSE] 		= AUI.L10n.GetString("vertical_reverse")},
		[2] = {[AUI_HORIZONTAL] 				= AUI.L10n.GetString("horizontal")},
		[3] = {[AUI_HORIZONTAL_REVERSE] 		= AUI.L10n.GetString("horizontal_reverse")},
	}
	
	return list
end

function AUI.Menu.GetSortingList()
	local list = 
	{
		[0] = {[AUI_SORTING_SMALL_TO_LARGE] 			= AUI.L10n.GetString("small_to_large")},
		[1] = {[AUI_SORTING_LARGE_TO_SMALL] 			= AUI.L10n.GetString("large_to_small")},
	}
	
	return list
end


function AUI.Menu.GetTextAnimationTypeList()
	local textAnimationTypeList = 
	{
		[0] = {[AUI_ANIMATION_MODE_FORWARD] 				= AUI.L10n.GetString("normal")},
		[1] = {[AUI_ANIMATION_MODE_BACKWARD]				= AUI.L10n.GetString("backward")},
		[2] = {[AUI_ANIMATION_MODE_REVERSE_FORWARD] 		= AUI.L10n.GetString("normal_reverse")},
		[3] = {[AUI_ANIMATION_MODE_REVERSE_BACKWARD]		= AUI.L10n.GetString("backward_reverse")},		
	}
	
	return textAnimationTypeList
end

function AUI.Menu.GetSCTPanelTypeList()
	local panelList= AUI.Combat.Text.GetPanelList()
	local panelTypeList = {}
	
	for internName, data in pairs(panelList) do
		table.insert(panelTypeList, {[internName] = data.name})
	end
	
	return panelTypeList
end
