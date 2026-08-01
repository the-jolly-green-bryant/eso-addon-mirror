---[ Namespaces ]---

if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.CarpetButtonUI then MC.CarpetButtonUI = ZO_Object.New( ZO_Object:Subclass() ) end

---[ Static Values ]---

local WM = WINDOW_MANAGER
local NS = "MC_CarpetButtonUI"

local AUTO_HIDE_HANDLE = NS .. "_Glow"
local AUTO_HIDE_REFRESH = 2000

local ANIM_HANDLE = NS .. "_Animation"

local MOVE_THRESHOLD = 4

local TEXT_COLOR = ZO_ColorDef:New(ZO_ColorDef.HexToFloats("FFFFFF"))

------[[ Methods ]]------

function MC.CarpetButtonUI:SetEnabled( enabled )
	if enabled then enabled = MC.House:CanEditCurrentHouse() end
	self.Enabled = enabled

	local alpha = self.MCButton:GetAlpha()
	if enabled then
		self.MCButton:SetColor(1, 1, 0.9, alpha)
	else
		self.MCButton:SetColor(0.6, 0.6, 0.6, alpha)
	end
end

function MC.CarpetButtonUI:Show()
	local show = MC.House:IsCurrentlyInAHouse()

	if show then
		self:SetEnabled( true )

		if nil ~= MC.Vars and nil ~= MC.Vars.Settings and nil ~= MC.Vars.Settings.CarpetButtonUI then
			local settings = MC.Vars.Settings.CarpetButtonUI
			if nil ~= settings and nil ~= settings.Left and nil ~= settings.Top then
				self.Window:ClearAnchors()
				self.Window:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
			end
		end
	end

	self.Window:SetHidden( not show )

	if show then
		self:Refresh()
	end
end

function MC.CarpetButtonUI:Hide()
	self.Window:SetHidden(true)
end

function MC.CarpetButtonUI:Refresh()
	local engineActive = MC.Engine:IsActive()
	self.MCLabel1:SetHidden(engineActive)
	self.MCLabel2:SetHidden(engineActive)
	self.OffLabel:SetHidden(not engineActive)
end

do
	local selfRef
	
	local function SetAnimationProgress(progress)
		local alpha = zo_lerp(selfRef.AnimateAlphaFrom, selfRef.AnimateAlphaTo, progress)
		selfRef.RevealAnimationAlpha = alpha
		selfRef.MCLabel1:SetAlpha(alpha)
		selfRef.MCLabel2:SetAlpha(alpha)
		selfRef.OffLabel:SetScale(1 + alpha * 0.5)

		local sampleWeight = 0.75 + alpha * 0.25
		selfRef.MCButton:SetTextureSampleProcessingWeight(TEX_SAMPLING_WEIGHT_RGB, sampleWeight)
	end
	
	local function StopAnimation()
		if selfRef.AnimateAlphaTo then
			local COMPLETE_PROGRESS = 1
			SetAnimationProgress(COMPLETE_PROGRESS)
		end

		EVENT_MANAGER:UnregisterForUpdate("MagicCarpet.ButtonUI.OnUpdate")
	end

	local function UpdateAnimation()
		local startTimeMS = selfRef.AnimateAlphaStartMS
		if not startTimeMS then
			StopAnimation()
			return
		end

		local currentTimeMS = GetFrameTimeMilliseconds()
		local elapsedTimeMS = currentTimeMS - startTimeMS
		local durationMS = selfRef.AnimateAlphaDurationMS
		if elapsedTimeMS >= durationMS then
			StopAnimation()
			return
		end

		local progress = elapsedTimeMS / durationMS
		SetAnimationProgress(progress)
	end

	function MC.CarpetButtonUI:Animate(visible)
		selfRef = self
		self.AnimateAlphaFrom = zo_lerp(self.MinLabelAlpha, self.MaxLabelAlpha, self.RevealAnimationAlpha or 0)
		self.AnimateAlphaTo = visible and self.MaxLabelAlpha or self.MinLabelAlpha
		self.AnimateAlphaStartMS = GetFrameTimeMilliseconds()
		self.AnimateAlphaDurationMS = math.abs(self.AnimateAlphaFrom - self.AnimateAlphaTo) * 500

		EVENT_MANAGER:RegisterForUpdate("MagicCarpet.ButtonUI.OnUpdate", 1, UpdateAnimation)
	end
end

------[[ Handlers ]]------

function MC.CarpetButtonUI:OnMoved()
	local left, top = self.Window:GetLeft(), self.Window:GetTop()
	MC.Vars.Settings.CarpetButtonUI = { Left = left, Top = top }
end

function MC.CarpetButtonUI:OnMouseEnter()
	local VISIBLE = true
	self:Animate(VISIBLE)
end

function MC.CarpetButtonUI:OnMouseExit()
	local HIDDEN = false
	self:Animate(HIDDEN)
end

do
	local selfRef

	local function OnUpdate()
		if selfRef.StartDragTimeMS <= GetGameTimeMilliseconds() then
			local x, y = GetUIMousePosition()
			selfRef.Window:ClearAnchors()
			selfRef.Window:SetAnchor(CENTER, GuiRoot, TOPLEFT, x, y)
		end
	end

	function MC.CarpetButtonUI:OnMouseDown()
		selfRef = self
		self.StartDragTimeMS = GetGameTimeMilliseconds() + 300

		EVENT_MANAGER:RegisterForUpdate("MagicCarpet.ButtonUI.OnMouseDown", 1, OnUpdate)
	end
end

function MC.CarpetButtonUI:OnMouseUp(button, upInside)
	EVENT_MANAGER:UnregisterForUpdate("MagicCarpet.ButtonUI.OnMouseDown")
	self:OnMoved()

	local startDragTimeMS = self.StartDragTimeMS or 0
	self.StartDragTimeMS = 0

	if upInside and button == MOUSE_BUTTON_INDEX_LEFT and GetGameTimeMilliseconds() < startDragTimeMS then
		if not self.Enabled then
			MC.FailedAlert()
			d("Cannot edit current house.")
			return
		end

		if not MC.Engine:IsActive() then
			if MC.CarpetUI:IsHidden() then
				MC.CarpetUI:Show()
			else
				MC.CarpetUI:Hide()
			end
		else
			local success, message = MC.Engine:Deactivate()
			if not success and nil ~= message then
				MC.FailedAlert()
				d( message )
			end
		end
	end
end

---[ Constructors ]---

do
	local self = MC.CarpetButtonUI

	-- Initialize

	self.RevealAnimationAlpha, self.MinLabelAlpha, self.MaxLabelAlpha = 0, 0, 1
	self.Enabled = false

	local c, p, w

	-- Top-level Window

	w = WM:CreateTopLevelWindow(NS)
	self.Window = w
	w:SetHidden(true)
	w:SetDimensionConstraints(100, 60, 100, 60)
	w:SetMovable(true)
	w:SetMouseEnabled(true)
	w:SetClampedToScreen(true)
	w:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -10, -60)
	w:SetHandler("OnMoveStop", function() self:OnMoved() end)
	w:SetHandler("OnMouseEnter", function() self:OnMouseEnter() end)
	w:SetHandler("OnMouseExit", function() self:OnMouseExit() end)
	w:SetHandler("OnMouseDown", function() self:OnMouseDown() end)
	w:SetHandler("OnMouseUp", function(control, button, upInside) self:OnMouseUp(button, upInside) end)

	-- MC Button

	do
		local function SetupTexture(t)
			t:SetTextureCoords(0, 1, -0.25, 0.9)
			t:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
			t:SetShaderEffectType(SHADER_EFFECT_TYPE_WAVE)
			t:SetWave(0.85, 1.65, 2.5, 0)
			t:SetWaveBounds(0.05, 0.03, 0.075, 0.125)
			t:SetMouseEnabled(false)
		end

		c = WM:CreateControl( NS .. "MCShadow", w, CT_TEXTURE )
		self.MCShadow = c
		c:SetTexture("/MagicCarpet/media/carpeticonbackground.dds")
		c:SetAnchor( CENTER, w, CENTER, 0, 4 )
		c:SetDimensions( 100, 60 )
		c:SetColor( 1, 1, 1, 1 )
		c:SetDrawLevel(1)
		SetupTexture(c)

		c = WM:CreateControl( NS .. "MCButton", w, CT_TEXTURE )
		self.MCButton = c
		c:SetTexture("/MagicCarpet/media/carpeticon.dds")
		c:SetAnchor( CENTER, w, CENTER, 0, 0 )
		c:SetDimensions( 100, 60 )
		c:SetColor( 1, 1, 1, 1 )
		c:SetDrawLevel(2)
		c:SetTextureSampleProcessingWeight(TEX_SAMPLING_WEIGHT_RGB, 0.75)
		SetupTexture(c)
		
		local SINE = math.sin
		local TWO_PI = math.pi * 2
		EVENT_MANAGER:RegisterForUpdate("MagicCarpet.ButtonUI.OnHoverUpdate", 1, function()
			local currentTimeS = GetFrameTimeSeconds()
			local progress = SINE(currentTimeS % TWO_PI) * 0.5 + 0.5
			local offsetY = progress * 0.25
			self.MCButton:SetTextureCoords(0, 1, -offsetY, 1.15 - offsetY)

			local scale = 0.8 + progress * 0.2
			self.MCShadow:SetScale(scale)
		end)
	end

	-- Labels

	do
		local r, g, b = TEXT_COLOR:UnpackRGBA()

		c = WM:CreateControl(NS .. "MCLabel1", w, CT_LABEL)
		self.MCLabel1 = c
		c:SetAnchor(BOTTOMRIGHT, w, CENTER, 5, -8)
		c:SetFont("$(BOLD_FONT)|$(KB_21)|outline")
		c:SetColor(r, g, b, self.MinLabelAlpha)
		c:SetText("Magic")
		c:SetHidden(false)
		c:SetMouseEnabled(false)

		c = WM:CreateControl(NS .. "MCLabel2", w, CT_LABEL)
		self.MCLabel2 = c
		c:SetAnchor(TOPLEFT, w, CENTER, -6, -11)
		c:SetFont("$(BOLD_FONT)|$(KB_21)|outline")
		c:SetColor(r, g, b, self.MinLabelAlpha)
		c:SetText("Carpet")
		c:SetHidden(false)
		c:SetMouseEnabled(false)

		c = WM:CreateControl( NS .. "OffLabel", w, CT_LABEL )
		self.OffLabel = c
		c:SetAnchor( CENTER, w, CENTER, 0, 0 )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_TOP )
		c:SetFont("$(BOLD_FONT)|$(KB_21)|outline")
		--c:SetFont( "$(BOLD_FONT)|$(KB_32)|outline" )
		c:SetColor(r, g, b, 1)
		c:SetText("OFF")
		c:SetHidden(true)
		c:SetMouseEnabled(false)
	end
end

do
	local win = WM:CreateTopLevelWindow("MagicCarpetHighLatencyWarning")
	win:SetHidden(true)

	local label = WM:CreateControl(nil, win, CT_LABEL)
	label:SetAnchor(TOPLEFT)
	label:SetColor(1, 1, 1, 1)
	label:SetDimensionConstraints(0, 0, 320, 0)
	label:SetDrawLevel(3)
	label:SetFont("$(BOLD_FONT)|$(KB_18)")
	label:SetMaxLineCount(4)
	label:SetText("High internet latency detected.\nMagic Carpet may not function properly.")

	local border = WM:CreateControl(nil, label, CT_TEXTURE)
	border:SetAnchor(TOPLEFT, nil, nil, -6, -6)
	border:SetAnchor(BOTTOMRIGHT, nil, nil, 6, 6)
	border:SetColor(1, 1, 1, 1)
	border:SetDrawLevel(1)

	local backdrop = WM:CreateControl(nil, label, CT_TEXTURE)
	backdrop:SetAnchor(TOPLEFT, nil, nil, -3, -3)
	backdrop:SetAnchor(BOTTOMRIGHT, nil, nil, 3, 3)
	backdrop:SetColor(1, 0, 0, 1)
	backdrop:SetDrawLevel(2)

	win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 10, 10)
end
