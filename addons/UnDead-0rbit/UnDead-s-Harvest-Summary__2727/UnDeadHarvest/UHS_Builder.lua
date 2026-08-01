UHS_Builder = {}

local WM = WINDOW_MANAGER

function UHS_Builder.BuildTLW()
	local TLW = WM:CreateTopLevelWindow("UnDeadHarvestUI")
	TLW:SetDimensions(270, 50)
	TLW:SetResizeToFitDescendents(true)
	TLW:ClearAnchors()
	TLW:SetAnchor(ANCHOR_TOP_LEFT, GuiRoot, ANCHOR_TOP_LEFT, UHS_Data.Saved.Left, UHS_Data.Saved.Top)
	TLW:SetMovable(true)
	TLW:SetMouseEnabled(true)
	TLW:SetClampedToScreen(true)
	TLW:SetHandler("OnMoveStop", UHS_Builder.OnMoveStop)

	local gphFragment = ZO_HUDFadeSceneFragment:New(TLW, nil, 0)
	HUD_SCENE:AddFragment(gphFragment)
	HUD_UI_SCENE:AddFragment(gphFragment)

    return TLW
end

function UHS_Builder.OnMoveStop(self)
    UHS_Data.Saved.Left = self:GetLeft()
    UHS_Data.Saved.Top = self:GetTop()
end

function UHS_Builder.BuildLabel(name, text, color, parent, relative, dimX, dimY, anchorX, anchorY)
	local newLabel = WM:CreateControl(name, parent, CT_LABEL)
	newLabel:SetFont("$(BOLD_FONT)|$(KB_18)|soft-shadow-thick")
	newLabel:SetColor(color[1], color[2], color[3], color[4])
    newLabel:SetHidden(false)
	newLabel:SetAnchor(anchorX, relative, anchorY, 0, 0)
	newLabel:SetDimensions(dimX, dimY)
	newLabel:SetText(text)
	return newLabel
end

function UHS_Builder.BuildButton(name, parent, relative, Normal, Pressed, Over, Disabled)
	local btn = WM:CreateControl(name, parent, CT_BUTTON)
    btn:SetHidden(false)
	btn:SetAnchor(ANCHOR_LEFT, relative, ANCHOR_RIGHT, 0, -1)
	btn:SetDimensions(25, 25)
	btn:SetClickSound("ZO_ButtonBehaviorClickSound")
	btn:SetNormalTexture(Normal)
	btn:SetPressedTexture(Pressed)
	btn:SetMouseOverTexture(Over)
	btn:SetDisabledTexture(Disabled)
	return btn
end

function UHS_Builder.BuildContainer(Name, TLW, Parent, Width, Height, Anchor, pAnchor)
	local Card = WM:CreateControl(Name, TLW, CT_CONTROL)
	Card:SetDimensions(Width, Height)
	Card:SetAnchor(Anchor, Parent, pAnchor, 0, 0)
	return Card
end

function UHS_Builder.BuildDataLabel(name, text, color, parent, dimX, dimY, Anchor)
	local newLabel = WM:CreateControl(name, parent, CT_LABEL)
	newLabel:SetFont("$(BOLD_FONT)|$(KB_18)|soft-shadow-thick")
	newLabel:SetColor(color[1], color[2], color[3], color[4])
    newLabel:SetHidden(false)
	newLabel:SetAnchor(Anchor, parent, Anchor, 0, 0)
	newLabel:SetDimensions(dimX, dimY)
	newLabel:SetText(text)
	return newLabel
end




