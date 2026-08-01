-- Initialize file
ZDAT         = ZDAT or {}
ZDAT.UI      = ZDAT.UI or {}
ZDAT.UI.Misc = {}

-- spacer (hidden empty label)
function ZDAT.UI.Misc.spacer(data)
	data.w = data.w or ZDAT.UI.Constants.spacer
	local control = WINDOW_MANAGER:CreateControl("$(parent)"..ZDAT.Utils.uid(), ZDAT_GUI, CT_LABEL)
	control:SetDimensions(data.w, ZDAT.UI.Constants.cellHeight)
	control:SetHidden(true)
	return control
end