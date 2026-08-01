-- Author: Momorodah

MomosSN.helpers = {}
-- hmm should I make these lookup tables instead of functions...?
function MomosSN.helpers:ConvertFontNameString(value)
	if value == "Antique" then return "ANTIQUE_FONT"
	elseif value == "Handwritten" then return "HANDWRITTEN_FONT"
	elseif value == "Stone Tablet" then return "STONE_TABLET_FONT"
	else return "ANTIQUE_FONT"
	end
end

function MomosSN.helpers:ConvertTextAlignString(value)
	if value == "Bottom" then return TEXT_ALIGN_BOTTOM
	elseif value == "Center" then return TEXT_ALIGN_CENTER
	elseif value == "Left" then return TEXT_ALIGN_LEFT
	elseif value == "Right" then return TEXT_ALIGN_RIGHT
	elseif value == "Top" then return TEXT_ALIGN_TOP
	else return TEXT_ALIGN_CENTER
	end
end
function MomosSN.helpers:ConvertAnchorString(value)
	if value == "Bottom" then return BOTTOM
	elseif value == "Bottom left" then return BOTTOMLEFT
	elseif value == "Bottom right" then return BOTTOMRIGHT
	elseif value == "Center" then return CENTER
	elseif value == "Left" then return LEFT
	elseif value == "None" then return NONE
	elseif value == "Right" then return RIGHT
	elseif value == "Top" then return TOP
	elseif value == "Top left" then return TOPLEFT
	elseif value == "Top right" then return TOPRIGHT
	else return NONE
	end
end