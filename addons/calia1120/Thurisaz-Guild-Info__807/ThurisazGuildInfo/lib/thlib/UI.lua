--[[
  [ Copyright (c) 2014 User Froali from ESOUI.com
  [ All Rights Reserved. If you want to use arts of my AddOns for your own work, please contact me first!
  ]]

--- Create new label with empty text/Erzeugt einen neuen Label mit leerem Text
function TI.CreateCharNameLabel(parent, anchor, name, dimensions, font)
	if(not font) then font = "ZoFontGame" end
	if(not dimensions) then dimensions = {175, 30} end
	local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. name, parent, CT_LABEL)
	control:SetFont(font)
	control:SetColor(255,255,255,255)
	control:SetDimensions(dimensions[1], dimensions[2])
	control:SetAnchor(LEFT, anchor, RIGHT, 0)
	control:SetText("")
	control:SetVerticalAlignment(TOP)
	control:SetHidden(false)

	return control
end

--- Creates a CT_Control/Erzeugt einen CT_Control
function TI:CreateControl(parent, anchor, name, dimensions, offSets, whereOnParent)
	if(not dimensions) then
		dimensions = {175,30}
	end
	if(not offSets) then offSets = {0,0} end
	if(not whereOnParent) then whereOnParent = 2 end
	local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. name, parent, CT_CONTROL)
	control:SetDimensions(dimensions[1],dimensions[2])
	control:SetAnchor(whereOnParent, anchor, nil, offSets[1], offSets[2])
	return control
end

---Creates a Control between 2 other Controls (e.g. in a list) (needs some improvement and is not used yet)
-- @param leftControl control to the left
-- @param rightControl control to the right
-- @param name name of the new control
-- @param dimensions dimensions of the new control as table {width,height}
-- @param controlType type of the new control (e.g. CT_CONTROL, CT_LABEL)
function TI:CreateNewControlBetween(parent, leftControl, rightControl, name, dimensions, controlType)
	local newControl = TI:CreateControl(parent, leftControl, name, dimensions)
	TI.ReAnchorControl(rightControl, newControl, 0, 0)
	return newControl
end

function TI:CreateLabel(parent, anchor, name, dimensions, color, font, whereOnParent, whereOnAnchor)
	if(not font) then font = "ZoFontGame" end
	if(not dimensions) then dimensions = {175, 30} end
	if(not whereOnParent) then whereOnParent = LEFT end
	if(not whereOnAnchor) then whereOnAnchor = RIGHT end
	local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. name, parent, CT_LABEL)
	control:SetFont(font)
	control:SetColor(255,255,255,255)
	control:SetDimensions(dimensions[1], dimensions[2])
	control:SetAnchor(whereOnParent, anchor, whereOnAnchor, 0)
	control:SetText("")
	control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control:SetHidden(false)

	return control
end

function TI.ReAnchorControl(control, newAnchor, newOffsetX, newOffsetY)
	local _b, whereOnMe, _o, whereOnTarget, offsetX, offsetY = control:GetAnchor()
	if(isnumeric(newOffsetX)) then offsetX = newOffsetX end
	if(isnumeric(newOffsetY)) then offsetY = newOffsetY end
	
	if(isnumeric(whereOnMe) and isnumeric(whereOnTarget) and isnumeric(offsetX) and isnumeric(offsetY)) then
		--zo_callLater( function() d("reanchoring control: " .. control:GetName()); end, 500)
		control:ClearAnchors()
		control:SetAnchor(whereOnMe, newAnchor, whereOnTarget, offsetX, offsetY)
	end
	return control
end

---Creates the moveable Announcement Control
function TI:CreateAnnouncementDisplay()
	TI.displayControl = TI:CreateControl(ThurisazGuildInfo, ThurisazGuildInfo, "AnnouncementDisplay", {TI.GetDisplayWidth() ,(TI.SETTINGS_DISPLAY_LABEL_COUNT)*44}, {TI.vars.AnnounceDisplayX, TI.vars.AnnounceDisplayY}, TOPLEFT)
	TI.displayControl:SetHandler( "OnMouseUp" , function(self) TI.OnMoveUI(self) end )
	TI.displayControl:SetMouseEnabled (false)
	TI.displayControl:SetMovable (false)
	
	TI.displayControlbackDrop = WINDOW_MANAGER:CreateControl(TI.displayControl:GetName() .. "BackDrop", TI.displayControl, CT_BACKDROP)
	TI.displayControlbackDrop:ClearAnchors()
	TI.displayControlbackDrop:SetAnchor(TOPLEFT, TI.displayControl, nil, 0,0)
	TI.displayControlbackDrop:SetHidden(true)
	TI.displayControlbackDrop:SetDimensions(TI.GetDisplayWidth() ,(TI.SETTINGS_DISPLAY_LABEL_COUNT)*44)
	TI.displayControlbackDrop:SetCenterColor(1,1,1,0.5)
	
	if(TI.GetDisplayTypeSettings() == TI.SETTINGS_DISPLAY_TYPE_CHAT) then
		TI.displayControl:SetHidden(true)
	end
	TI.SCT:SetTime(TI.vars.AnnounceDisplayTime)
end

function TI.OnMoveUI(self)
	TI.vars.AnnounceDisplayX = self:GetLeft()
	TI.vars.AnnounceDisplayY = self:GetTop()

end

function TI.GetChildren(control)
	local t = {}
	local numChildren = control:GetNumChildren()
	for i = 1, numChildren do
		table.insert(t,control:GetChild(i))
	end
	return t
end