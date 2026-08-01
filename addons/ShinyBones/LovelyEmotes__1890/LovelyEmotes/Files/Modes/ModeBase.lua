LE_ModeBase = ZO_Object:Subclass()

function LE_ModeBase:New(name, contentControl)
	local obj = ZO_Object.New(self)
	obj:Initialize(name, contentControl)

	return obj
end

function LE_ModeBase:Initialize(name, contentControl)
	self.Name = name

	if contentControl then
		self.ContentControl = contentControl
	else
		self.ContentControl = CreateControl(nil, GuiRoot, CT_CONTROL)
	end

	self.ContentControl:SetHidden(true)

	self.ContentControl:SetHandler("OnEffectivelyShown", function() self:Enable() end)
	self.ContentControl:SetHandler("OnEffectivelyHidden", function() self:Disable() end)
end

function LE_ModeBase:IsActive()
	return not self.ContentControl:IsControlHidden()
end

function LE_ModeBase:IsEnabled()
	return not self.ContentControl:IsHidden()
end

-- To be overridden: Is called once when the mode is added to the main window. Requires to call "LE_ModeBase.Setup(self)" if overridden
function LE_ModeBase:Setup(parentControl)
	self.ContentControl:SetParent(parentControl)
	self.ContentControl:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 0, 0)
	self.ContentControl:SetAnchor(BOTTOMRIGHT, parentControl, BOTTOMRIGHT, 0, 0)
end

-- To be overridden: Is used to update the main window height. The returned value represents only the content height
function LE_ModeBase:GetHeight()
	return 450
end

-- To be overridden: Is called when the mode becomes active. Requires to call "LE_ModeBase.Activate(self)" if overridden
function LE_ModeBase:Activate()
	self.ContentControl:SetHidden(false)
end

-- To be overridden: Is called when the mode becomes inactive. Requires to call "LE_ModeBase.Deactivate(self)" if overridden
function LE_ModeBase:Deactivate()
	self.ContentControl:SetHidden(true)
end

-- To be overridden: Is called when the mode is shown
function LE_ModeBase:Enable()
end

-- To be overridden: Is called when the mode is hidden
function LE_ModeBase:Disable()
end
