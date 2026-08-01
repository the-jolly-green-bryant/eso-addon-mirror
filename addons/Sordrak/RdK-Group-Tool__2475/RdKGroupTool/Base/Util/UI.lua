-- RdK Group Tool UI
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}
RdKGTool.util.ui = RdKGTool.util.ui or {}

local RdKGToolUI = RdKGTool.util.ui
local wm = GetWindowManager()

RdKGToolUI.labelFont = "$(BOLD_FONT)|$(KB_20)soft-shadow-thick"

--checkbox
local function CheckBoxSetChecked(control, isChecked)
	if isChecked ~= nil then
		control.isChecked = isChecked
		if isChecked == true then
			control.labelButton:SetText(RdKGToolUI.constants.ON)
		elseif isChecked == false then
			control.labelButton:SetText(RdKGToolUI.constants.OFF)
		end
		control:AdjustColor(false)
	end
end

local function CheckboxOnMouseEnter(control)
	control:AdjustColor(true)
	if control.OnMouseEnter ~= nil and type(control.OnMouseEnter) == "function" then
		control.OnMouseEnter(control)
	end
end

local function CheckboxOnMouseExit(control)
	control:AdjustColor(false)
	if control.OnMouseExit ~= nil and type(control.OnMouseExit) == "function" then
		control.OnMouseExit(control)
	end
end

local function CheckboxOnMouseUp(control)
	control:SetChecked(not control.isChecked)
	control:AdjustColor(true)
	if control.OnCheckChanged ~= nil and type(control.OnCheckChanged) == "function" then
		control.OnCheckChanged(control, control.isChecked)
	end
	if control.OnMouseUp ~= nil and type(control.OnMouseUp) == "function" then
		control.OnMouseUp(control)
	end
end

local function CheckboxAdjustColors(control, highlighted)
	if control.isEnabled == true then
		if control.isChecked == true then
			if highlighted == true then
				control.labelText:SetColor(ZO_HIGHLIGHT_TEXT:UnpackRGBA())
				control.labelButton:SetColor(ZO_HIGHLIGHT_TEXT:UnpackRGBA())
			else
				control.labelText:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
				control.labelButton:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
			end
		else
			if highlighted == true then
				control.labelText:SetColor(ZO_DEFAULT_DISABLED_MOUSEOVER_COLOR:UnpackRGBA())
				control.labelButton:SetColor(ZO_HIGHLIGHT_TEXT:UnpackRGBA())
			else
				control.labelText:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
				control.labelButton:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
			end
		end
	else
		control.labelText:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
		control.labelButton:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
	end
end

local function CheckboxSetEnabled(control, isEnabled)
	if isEnabled ~= nil then
		control.isEnabled = isEnabled
		control:AdjustColor(false)
	end
end

function RdKGToolUI.CreateCheckBox(parent, data, controlName)
	if data.width ~= nil and data.height ~= nil then
		local control = wm:CreateControl(controlName, parent, CT_CONTROL)
		control:SetDimensions(data.width, data.height)
		control:SetWidth(data.width)
		
		control:SetMouseEnabled(true)
		control.OnMouseEnter = data.OnMouseEnter
		control.OnMouseExit = data.OnMouseExit
		control.OnMouseUp = data.OnMouseUp
		control.OnCheckChanged = data.OnCheckChanged
		
		control:SetHandler("OnMouseEnter", CheckboxOnMouseEnter)
		control:SetHandler("OnMouseExit", CheckboxOnMouseExit)
		control:SetHandler("OnMouseUp", CheckboxOnMouseUp)

		control.labelText = wm:CreateControl(nil, control, CT_LABEL)
		control.labelText:SetWidth(data.width - 45)
		control.labelText:SetText(data.text)
		control.labelText:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
		control.labelText:SetFont(RdKGToolUI.labelFont)
		
		control.labelButton = wm:CreateControl(nil, control, CT_LABEL)
		control.labelButton:SetWidth(45)
		control.labelButton:SetAnchor(TOPLEFT, control, TOPLEFT, data.width - 45, 0)
		control.labelButton:SetFont(RdKGToolUI.labelFont)
		
		control.isChecked = data.isChecked
		if control.isChecked == nil then
			control.isChecked = true
		end
		
		control.AdjustColor = CheckboxAdjustColors
		
		control.SetChecked = CheckBoxSetChecked
		control:SetChecked(control.isChecked)
		
		control.isEnabled = data.isEnabled
		if control.isEnabled == nil then
			control.isEnabled = true
		end
		
		
		control.SetEnabled = CheckboxSetEnabled
		control:SetEnabled(control.isEnabled)
		
		
		
		return control
	end
end

--Util
--Moves the arrow around for 180 degrees -> used by follow the crown visual
function RdKGToolUI.NormalizeAngle(angle)
    if angle < -math.pi then 
		return angle + 2 * math.pi 
	end
    if angle > math.pi then 
		return angle - 2 * math.pi 
	end
    return angle
end