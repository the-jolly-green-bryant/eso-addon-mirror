local IE = InventoryExtensions
IE.UI = {
    Controls = {}
}

function IE.UI.Label(name, parent, dims, anchor, font, color, align, text, hidden)
	--Validate arguments
--	if (name==nil or name=="") then return end
	parent=(parent==nil) and GuiRoot or parent
	if (#anchor~=4 and #anchor~=5) then return end
	font	=(font==nil) and "ZoFontGame" or font
	color	=(color~=nil and #color==4) and color or {1,1,1,1}
	align	=(align~=nil and #align==2) and align or {0,0}
	hidden=(hidden==nil) and false or hidden

	--Create the label
	local label=_G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)

	if dims then label:SetDimensions(dims[1], dims[2]) end
	label:ClearAnchors()
	label:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
	label:SetFont(font)
	label:SetColor(unpack(color))
	label:SetHorizontalAlignment(align[1])
	label:SetVerticalAlignment(align[2])
	label:SetText(text)
	label:SetHidden(hidden)
	return label
end