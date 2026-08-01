Courage = Courage or { }
local Courage = Courage

Courage.UI = { }

local WM = GetWindowManager()

local function _savePos()
	Courage.savedVars.offsetX = Courage.UI.Frame:GetLeft()
	Courage.savedVars.offsetY = Courage.UI.Frame:GetTop()
end

local function _setPos(left, top)
	Courage.UI.Frame:ClearAnchors()
	Courage.UI.Frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function Courage.UI.Build()
	local frame = WM:GetControlByName("CourageFrame")
	if frame == nil then
		-- CourageFrame
		local f = WM:CreateTopLevelWindow("CourageFrame")
		f:SetClampedToScreen(true)
		f:SetDimensions(50, 50)
		f:ClearAnchors()
		f:SetMouseEnabled(false)
		f:SetMovable(false)
		f:SetHidden(true)
		f:SetHandler("OnMoveStop", function(...) _savePos() end)

		-- CourageTexture
		local t = WM:CreateControl("CourageTexture", f, CT_TEXTURE)
		t:SetTexture("esoui/art/icons/u26_skyrim_world_boss_daily30.dds")
		t:SetAnchorFill()

		-- CourageCooldown
		local c = WM:CreateControl("CourageCooldown", t, CT_COOLDOWN)
		c:SetAnchorFill()
		c:SetDrawLayer(DL_BACKGROUND)
		c:SetFillColor(0.15, 0.15, 0.15, 0.7)

		-- CourageBorder
		local b = WM:CreateControl("CourageBorder", c, CT_BACKDROP)
		b:SetEdgeColor(unpack(Courage.Alert_Colors[1]))
		b:SetEdgeTexture(nil, 1, 1, 0, nil)
		b:SetCenterColor(0, 0, 0, 0)
		b:SetAnchor(TOPLEFT, f, TOPLEFT, -1, -1)
		b:SetDimensions(52, 52)
		b:SetAlpha(1)
		b:SetDrawLayer(0)

		-- CourageTimer
		local l = WM:CreateControl("CourageTimer", f, CT_LABEL)
		l:SetAnchorFill()
		l:SetColor(1, 1, 1, 1)
		l:SetFont("$(MEDIUM_FONT)|$(KB_18)|thick-outline")
		l:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		l:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		l:SetPixelRoundingEnabled(true)
		l:SetText(string.format("%.1f", 0.0))

		Courage.UI.Frame = f
		Courage.UI.Time = l
		Courage.UI.BG = b
		Courage.UI.Texture = t
		Courage.UI.Cooldown = c
		_setPos(Courage.savedVars.offsetX, Courage.savedVars.offsetY)
	end
end

function Courage.UI.Toggle()
	local hScene = SCENE_MANAGER:GetScene("hud")
	hScene:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" and Courage.locked then
			Courage.UI.Frame:SetHidden(true)
		end
		if newState == SCENE_SHOWING and Courage.locked then
			Courage.UI.Frame:SetHidden(not Courage.active)
		end
	end)
end
