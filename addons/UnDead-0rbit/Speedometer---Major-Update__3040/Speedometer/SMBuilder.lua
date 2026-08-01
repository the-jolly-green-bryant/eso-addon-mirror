SMBuilder = {}
local WM = WINDOW_MANAGER

function SMBuilder.BuildTLW()
    local TLW = WM:CreateTopLevelWindow("SpeedometerUI")
	TLW:SetDimensions(500,250)
	TLW:SetResizeToFitDescendents(true)
	TLW:ClearAnchors()
	TLW:SetAnchor(ANCHOR_TOP_LEFT, GuiRoot, ANCHOR_TOP_LEFT, Speedometer.SavedVariables.Left, Speedometer.SavedVariables.Top)
	TLW:SetMovable(true)
	TLW:SetMouseEnabled(true)
	TLW:SetClampedToScreen(true)
	TLW:SetHandler("OnMoveStop", SMBuilder.OnMoveStop)

	local gphFragment = ZO_HUDFadeSceneFragment:New(TLW, nil, 0)
	HUD_SCENE:AddFragment(gphFragment)
	HUD_UI_SCENE:AddFragment(gphFragment)

    return TLW
end

function SMBuilder.OnMoveStop(self)
    Speedometer.SavedVariables.Left = self:GetLeft()
    Speedometer.SavedVariables.Top = self:GetTop()
end

function SMBuilder.BuildContainer(Name, Parent, Width, Height, Anchor, pAnchor)
	local Card = WM:CreateControl(Name, Parent, CT_CONTROL)
	Card:SetDimensions(Width, Height)
	Card:SetAnchor(Anchor, Parent, pAnchor, 0, 0)
	return Card
end

function SMBuilder.BuildCoolDown(Name, Parent, Image, Angle, Size)
	local CBar = WM:CreateControl(Name, Parent, CT_COOLDOWN)
	CBar:SetDimensions(Size, Size)
	CBar:SetRadialCooldownOriginAngle(Angle)
	CBar:SetTexture(IMAGE_FILE .. Image)
	CBar:SetAnchor(ANCHOR_CENTER, Parent, ANCHOR_CENTER, 0, 0)
end

function SMBuilder.BuildSquareTexture(Name, Parent, Image, Size)
	local Texture = WM:CreateControl(Name, Parent, CT_TEXTURE)
	Texture:SetDrawLayer(DL_CONTROLS)
	Texture:SetDimensions(Size, Size)
	Texture:SetAnchor(ANCHOR_CENTER, Parent, ANCHOR_CENTER, 0, 0)
	Texture:SetTexture(IMAGE_FILE .. Image)
	return Texture
end

function SMBuilder.BuildSpeedLabel(name, color, parent, dimX, dimY)
	local newLabel = WM:CreateControl(name, parent, CT_LABEL)
	newLabel:SetFont("$(BOLD_FONT)|$(KB_36)|soft-shadow-thick")
	newLabel:SetColor(color[1], color[2], color[3], color[4])
    newLabel:SetHidden(false)
	newLabel:SetAnchor(ANCHOR_BOTTOM_LEFT, parent, ANCHOR_BOTTOM_LEFT, 0, -2)
	newLabel:SetDimensions(dimX, dimY)
	newLabel:SetText("88.8")
	newLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	newLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
	return newLabel
end

function SMBuilder.BuildSpeedUnitLabel(name, color, parent)
	local newLabel = WM:CreateControl(name, parent, CT_LABEL)
	newLabel:SetFont("$(BOLD_FONT)|$(KB_20)|soft-shadow-thick")
	newLabel:SetColor(color[1], color[2], color[3], color[4])
    newLabel:SetHidden(false)
	newLabel:SetAnchor(ANCHOR_BOTTOM_LEFT, parent, ANCHOR_BOTTOM_RIGHT, 0, -4)
	newLabel:SetDimensions(30, 20)
	newLabel:SetText("m/s")
	newLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	return newLabel
end

function SMBuilder.BuildLabel(name, text, color, parent, dimX, dimY, anchorX, anchorY, fontSize, vAlign)
	local newLabel = WM:CreateControl(name, parent, CT_LABEL)
	newLabel:SetFont("$(BOLD_FONT)|$(KB_" .. fontSize .. ")")
	newLabel:SetColor(color[1], color[2], color[3], color[4])
    newLabel:SetHidden(false)
	newLabel:SetAnchor(anchorX, parent, anchorY, 0, 0)
	newLabel:SetDimensions(dimX, dimY)
	newLabel:SetText(text)
	newLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	newLabel:SetVerticalAlignment(vAlign)
	return newLabel
end

function SMBuilder.BuildDivider(name, parent, dimX)
	local newDivider = WM:CreateControl(name, parent, CT_TEXTURE)
	newDivider:SetDrawLayer(DL_CONTROLS)
	newDivider:SetDimensions(dimX, 4)
	newDivider:SetAnchor(ANCHOR_TOP, parent, ANCHOR_BOTTOM, 0, 8)
	newDivider:SetTexture("/esoui/art/progression/ability_line.dds")
	return newDivider
end

function SMBuilder.CreateButton(name, parent, relative, dimX, dimY, anchorX, anchorY, Normal, Pressed, Over, Disabled)
	local newButton = WM:CreateControl(name, parent, CT_BUTTON)
    newButton:SetHidden(false)
	newButton:SetAnchor(anchorX, relative, anchorY, 1, 0)
	newButton:SetDimensions(dimX, dimY)
	newButton:SetClickSound("ZO_ButtonBehaviorClickSound")
	newButton:SetNormalTexture(Normal)
	newButton:SetPressedTexture(Pressed)
	newButton:SetMouseOverTexture(Over)
	newButton:SetDisabledTexture(Disabled)
	return newButton
end

function SMBuilder.ButtonOnMouseExit(self)
	ZO_Tooltips_HideTextTooltip()
end

