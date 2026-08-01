ToggleStatus = ToggleStatus or { }
local ts = ToggleStatus
ts.ui = { }

local function savePos()
	ts.savedVars.offsetX = ts.ui.frame:GetLeft()
	ts.savedVars.offsetY = ts.ui.frame:GetTop() 
end

local function setPos()
	ts.ui.frame:ClearAnchors()
	ts.ui.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ts.savedVars.offsetX, ts.savedVars.offsetY)
end

function ts.ui.setDisplay(value)
	if value then
		SCENE_MANAGER:GetScene("hud"):AddFragment(ts.ui.frag)
		SCENE_MANAGER:GetScene("hudui"):AddFragment(ts.ui.frag)
	else
		SCENE_MANAGER:GetScene("hud"):RemoveFragment(ts.ui.frag)
		SCENE_MANAGER:GetScene("hudui"):RemoveFragment(ts.ui.frag)
		ts.ui.frame:SetHidden(false)
	end
	ts.ui.container:SetHidden(value)
	ts.ui.frame:SetMovable(not value)
	ts.ui.frame:SetMouseEnabled(not value)
end

function ts.ui.setupUI()
	ts.ui.frame = TSFrame
	ts.ui.container = TSFrameContainer
	ts.ui.texture = TSFrameContainerIconTexture
	ts.ui.border = TSFrameContainerIconBorder
	ts.ui.stacks = TSFrameContainerIconStacks
	ts.ui.status = TSFrameContainerStatus

	ts.ui.frag = ZO_HUDFadeSceneFragment:New(ts.ui.frame)
	ts.ui.frame:SetHandler("OnMoveStop", savePos, "TS")
	setPos()
	ts.ui.setDisplay(true)
end
