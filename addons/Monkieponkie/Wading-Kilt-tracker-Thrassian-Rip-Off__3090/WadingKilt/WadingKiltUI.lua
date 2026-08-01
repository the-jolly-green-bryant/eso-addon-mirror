WadingKilt = WadingKilt or { }
local t = WadingKilt
t.UI = { }
t.fragAdded = false

local WM = GetWindowManager()
local SM = SCENE_MANAGER

local function _savePos()
	t.savedVars.offsetX = t.UI.frame:GetLeft()
	t.savedVars.offsetY = t.UI.frame:GetTop()
end

local function _setPos(left, top)
	t.UI.frame:ClearAnchors()
	t.UI.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function t.UI.setDisplay(fragValue, displayValue)
	if fragValue and not t.fragAdded then
		t.fragAdded = true
		SM:GetScene("hud"):AddFragment(t.UI.frameFragment)
		SM:GetScene("hudui"):AddFragment(t.UI.frameFragment)
		t.UI.frame:SetHidden(not t.checkEquipped())
	elseif not fragValue and t.fragAdded then
		t.fragAdded = false
		SM:GetScene("hud"):RemoveFragment(t.UI.frameFragment)
		SM:GetScene("hudui"):RemoveFragment(t.UI.frameFragment)
		t.UI.frame:SetHidden(displayValue)
	end
end

function t.UI.build()
	local frame = WM:CreateTopLevelWindow("WadingKiltFrame")
	frame:SetClampedToScreen(true)
	frame:SetDimensions(50, 50)
	frame:ClearAnchors()
	frame:SetMouseEnabled(false)
	frame:SetMovable(false)
	frame:SetHidden(false)
	frame:SetHandler("OnMoveStop", function(...) _savePos() end)

	local tex = WM:CreateControl("WadingKiltTexture", frame, CT_TEXTURE)
	tex:SetTexture("/esoui/art/actionbar/quickslotbg.dds")
	tex:SetAnchorFill()

	local border = WM:CreateControl("WadingKiltBorder", tex, CT_TEXTURE)
	border:SetTexture("/esoui/art/actionbar/gamepad/gp_abilityframe64.dds")
	border:SetAnchorFill()

	local count = WM:CreateControl("WadingKiltStacks", tex, CT_LABEL)
	count:SetAnchorFill()
	count:SetColor(1, 0.5, 0, 1)
	count:SetFont("$(MEDIUM_FONT)|$(KB_36)|thick-outline")
	count:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	count:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	count:SetPixelRoundingEnabled(true)
	count:SetText("0")

	t.UI.frame = frame
	t.UI.count = count
	t.UI.frameFragment = ZO_HUDFadeSceneFragment:New(t.UI.frame)
	_setPos(t.savedVars.offsetX, t.savedVars.offsetY)
	t.UI.setDisplay(true)
end

