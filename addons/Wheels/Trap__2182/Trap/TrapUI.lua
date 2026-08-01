Trap = Trap or { }
local Trap = Trap

Trap.UI = { }

local WM = GetWindowManager()

local function _savePos()
	Trap.savedVars.offsetX = Trap.UI.Frame:GetLeft()
	Trap.savedVars.offsetY = Trap.UI.Frame:GetTop()
end

local function _setPos(left, top)
	Trap.UI.Frame:ClearAnchors()
	Trap.UI.Frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function Trap.UI.Build()
	local frame = WM:GetControlByName("TrapFrame")
	if frame == nil then
		-- TrapFrame
		local f = WM:CreateTopLevelWindow("TrapFrame")
		f:SetClampedToScreen(true)
		f:SetDimensions(50, 50)
		f:ClearAnchors()
		f:SetMouseEnabled(false)
		f:SetMovable(false)
		f:SetHidden(true)
		f:SetHandler("OnMoveStop", function(...) _savePos() end)

		-- TrapTexture
		local t = WM:CreateControl("TrapTexture", f, CT_TEXTURE)
		t:SetTexture("esoui/art/icons/ability_fightersguild_004_a.dds")
		t:SetAnchorFill()

		-- TrapCooldown
		local c = WM:CreateControl("TrapCooldown", t, CT_COOLDOWN)
		c:SetAnchorFill()
		c:SetDrawLayer(DL_BACKGROUND)
		c:SetFillColor(0.15, 0.15, 0.15, 0.7)

		-- TrapBorder
		local b = WM:CreateControl("TrapBorder", c, CT_BACKDROP)
		b:SetEdgeColor(unpack(Trap.Alert_Colors[1]))
		b:SetEdgeTexture(nil, 1, 1, 0, nil)
		b:SetCenterColor(0, 0, 0, 0)
		b:SetAnchor(TOPLEFT, f, TOPLEFT, -1, -1)
		b:SetDimensions(52, 52)
		b:SetAlpha(1)
		b:SetDrawLayer(0)

		-- TrapTimer
		local l = WM:CreateControl("TrapTimer", f, CT_LABEL)
		l:SetAnchorFill()
		l:SetColor(1, 1, 1, 1)
		l:SetFont("$(MEDIUM_FONT)|$(KB_18)|thick-outline")
		l:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		l:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		l:SetPixelRoundingEnabled(true)
		l:SetText(string.format("%.1f", 0.0))

		Trap.UI.Frame = f
		Trap.UI.Time = l
		Trap.UI.BG = b
		Trap.UI.Texture = t
		Trap.UI.Cooldown = c
		_setPos(Trap.savedVars.offsetX, Trap.savedVars.offsetY)
	end
end

function Trap.UI.Toggle()
	local hScene = SCENE_MANAGER:GetScene("hud")
	hScene:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" and Trap.locked then
			Trap.UI.Frame:SetHidden(true)
		end
		if newState == SCENE_SHOWING and Trap.locked then
			Trap.UI.Frame:SetHidden(not Trap.active)
		end
	end)
end
