ForceOverflow = ForceOverflow or { }
local fo = ForceOverflow
fo.ui = { }

local function savePos()
	fo.savedVars.offsetX = fo.ui.frame:GetLeft()
	fo.savedVars.offsetY = fo.ui.frame:GetTop()
end

local function setPos()
	fo.ui.frame:ClearAnchors()
	fo.ui.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, fo.savedVars.offsetX, fo.savedVars.offsetY)
end

function fo.ui.setDisplay(value)
	if value then
		SCENE_MANAGER:GetScene("hud"):AddFragment(fo.ui.frag)
		SCENE_MANAGER:GetScene("hudui"):AddFragment(fo.ui.frag)
	else
		SCENE_MANAGER:GetScene("hud"):RemoveFragment(fo.ui.frag)
		SCENE_MANAGER:GetScene("hudui"):RemoveFragment(fo.ui.frag)
		fo.ui.frame:SetHidden(false)
	end

	fo.ui.container:SetHidden(value)
	fo.ui.frame:SetMovable(not value)
	fo.ui.frame:SetMouseEnabled(not value)
end

function fo.setupUI()
	fo.ui.frame = FOFrame
	fo.ui.container = FOFrame_Container
	fo.ui.texture = FOFrame_Container_Texture
	fo.ui.timer = FOFrame_Container_Time

	fo.ui.frag = ZO_HUDFadeSceneFragment:New(fo.ui.frame)

	fo.ui.frame:SetHandler("OnMoveStop", savePos, "FO")
	setPos()
	fo.ui.setDisplay(true)
end

