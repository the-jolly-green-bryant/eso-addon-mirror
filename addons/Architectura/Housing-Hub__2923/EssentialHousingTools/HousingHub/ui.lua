if IsNewerEssentialHousingHubVersionAvailable() or not IsEssentialHousingHubRootPathValid() then
	return
end

local EHH = EssentialHousingHub
if not EHH then
	return
end

local RAD45, RAD90, RAD180, RAD270, RAD360 = 0.25 * math.pi, 0.5 * math.pi, math.pi, 1.5 * math.pi, 2 * math.pi
local round = function(n, d) if nil == d then return zo_roundToZero(n) else return zo_roundToNearest(n, 1 / (10 ^ d)) end end
local bit = EHH.Bit
local Textures = EHH.Textures
local cos = math.cos
local sin = math.sin

local function CaseInsensitiveStringComparer(s1, s2)
	if not s1 and s2 then return true end
	if s1 and not s2 then return false end
	return string.lower(s1) > string.lower(s2)
end

local function CompareStringValues(s1, s2)
	if "string" ~= type(s1) then
		return "string" ~= type(s2) and 0 or -1
	end

	if "string" ~= type(s2) then
		return 1
	end

	local l1, l2 = #s1, #s2
	local l = math.min(l1, l2)
	local c1, c2

	for index = 1, l do
		c1, c2 = string.lower(string.sub(s1, index, index)), string.lower(string.sub(s2, index, index))

		if c1 < c2 then
			return -1
		elseif c2 < c1 then
			return 1
		end
	end

	if l1 < l2 then
		return -1
	elseif l2 < l1 then
		return 1
	end

	return 0
end

local TIP_FX_SHARE_COMMUNITY = "|cffffff" ..
	"Publish a home's FX to |c00ffffall PC players on all servers|cffffff. " ..
	"You may publish multiple homes' FX to the Community.\n\n" ..
	"This sharing method:\n" ..
	" - |c00ffffInstantly|cffffff shares FX data after your next login or /reloadui.\n" ..
	" - |c00ffffCan|cffffff share with offline players.\n" ..
	" - |c00ffffDoes not|cffffff use chat or in-game mail.\n" ..
	"\nKeep in mind that this method:\n" ..
	" - |c00ffffCannot|cffffff share other players' FX.\n" ..
	" - |c00ffffDoes|cffffff require the Essential Housing Community app to be installed. You will be prompted to install it if you have not done so already.\n"

local TIP_FX_SHARE_GUILDS = "|cffffff" ..
	"Share your FX with any online members of one or more of your guilds. Silent but slower than other sharing methods.\n\n" ..
	"This sharing method:\n" ..
	" - |c00ffffCan|cffffff share other players' FX.\n" ..
	" - |c00ffffDoes not|cffffff use chat or in-game mail.\n" ..
	" - |c00ffffDoes not|cffffff require the Essential Housing Community app.\n" ..
	"\nKeep in mind that this method:\n" ..
	" - |c00ffffSlowly|cffffff shares your data in the background.\n" ..
	" - |c00ffffCannot|cffffff share with offline players.\n"

local TIP_FX_SHARE_CHAT = "|cffffff" ..
	"Share your FX with any players in your current Chat channel, such as |cffff00/say|cffffff, |cffff00/group|cffffff or |cffff00/guild|cffffff.\n\n" ..
	"This sharing method:\n" ..
	" - |c00ffffCan|cffffff share other players' FX.\n" ..
	" - |c00ffffDoes not|cffffff require the Essential Housing Community app.\n" ..
	"\nKeep in mind that this method:\n" ..
	" - |c00ffffDoes|cffffff use chat messages to share FX data.\n" ..
	" - |c00ffffRequires|cffffff you to manually send one or more messages.\n" ..
	" - |c00ffffCannot|cffffff share with offline players.\n"

local TIP_FX_SHARE_MAIL = "|cffffff" ..
	"Share your FX with a specific @player. Ideal for sharing with an offline player that does not have the Essential Housing Community app installed.\n\n" ..
	"This sharing method:\n" ..
	" - |c00ffffInstantly|cffffff shares your data.\n" ..
	" - |c00ffffCan|cffffff share with offline players.\n" ..
	" - |c00ffffDoes not|cffffff require the Essential Housing Community app.\n" ..
	"\nKeep in mind that this method:\n" ..
	" - |c00ffffDoes|cffffff use in-game mail to share FX data.\n" ..
	" - |c00ffffCannot|cffffff share other players' FX.\n"

function EHH:BuildItemQuantityList(itemQuantities, formatString, itemSeparator)
	local list = {}
	for item, quantity in pairs(itemQuantities) do
		table.insert(list, string.format(formatString or "%s (x%d)", item, quantity))
	end
	return table.concat(list, itemSeparator or ", ")
end

function EHH:IsPointInsideControl(control, x, y)
	local minX, minY, maxX, maxY = control:GetScreenRect()
	return x >= minX and y >= minY and x <= maxX and y <= maxY
end

function EHH:GetAllChildControls(parent, children)
	children = children or {}
	if parent then
		local numChildren = parent:GetNumChildren()
		for childIndex = 1, numChildren do
			local child = parent:GetChild(childIndex)
			table.insert(children, child)
			self:GetAllChildControls(child, children)
		end
	end
	return children
end

function EHH:ForEachChildControl(parent, callback)
	local children = self:GetAllChildControls(parent)
	for index, child in ipairs(children) do
		callback(child)
	end
	return children
end

---[ Texture Rotation and Scaling ]---

function EHH:Rotate2D(x, y, angle)
	local c, s = math.cos(angle), math.sin(angle)
	return y * s + x * c, y * c - x * s
end

function EHH:TransformTexture(texture, angle, centerX, centerY, scaleX, scaleY)
	centerX, centerY = centerX or 0.5, centerY or 0.5
	-- scaleX, scaleY = 1 / (scaleX or 1), 1 / (scaleY or 1)
	local c, s = math.cos(angle), math.sin(angle)
	local factorX, factorY = 1 / (scaleX or 1), 1 / (scaleY or 1)
	scaleX = zo_lerp(factorX, factorY, math.abs(s))
	scaleY = zo_lerp(factorX, factorY, math.abs(c))

	local x1, y1 = -0.5 * s + -0.5 * c, -0.5 * c - -0.5 * s
	local x2, y2 = -0.5 * s +  0.5 * c, -0.5 * c -  0.5 * s
	local x4, y4 =  0.5 * s + -0.5 * c,  0.5 * c - -0.5 * s
	local x8, y8 =  0.5 * s +  0.5 * c,  0.5 * c -  0.5 * s

	texture:SetVertexUV(1, centerX + scaleX * x1, centerY + scaleY * y1)
	texture:SetVertexUV(2, centerX + scaleX * x2, centerY + scaleY * y2)
	texture:SetVertexUV(4, centerX + scaleX * x4, centerY + scaleY * y4)
	texture:SetVertexUV(8, centerX + scaleX * x8, centerY + scaleY * y8)
end

---[ Dialog Management ]---

function EHH:DoesDialogExist(dialogKey)
	dialogKey = string.lower(dialogKey)
	return nil ~= self.Dialogs[dialogKey]
end

function EHH:GetDialog(dialogKey)
	dialogKey = string.lower(dialogKey)
	return self.Dialogs[dialogKey]
end

function EHH:CreateDialog(dialogKey)
	dialogKey = string.lower(dialogKey)
	local dialog = {}
	dialog.DialogKey = dialogKey
	self.Dialogs[dialogKey] = dialog
	return dialog
end

---[ Colors ]---

local function IsColor(c)
	return	"table" == type(c) and
			"number" == type(c.r) and
			"number" == type(c.g) and
			"number" == type(c.b) and
			"number" == type(c.a)
end

local function IsGradient(c)
	return	"table" == type(c) and
			IsColor(c.tl) and
			IsColor(c.tr) and
			IsColor(c.bl) and
			IsColor(c.br)
end

local function CreateColor(r, g, b, a)
	return { r = r, g = g, b = b, a = a }
end

local function FadeColor(c, colorCoeff, alphaCoeff)
	colorCoeff = colorCoeff or 1
	alphaCoeff = alphaCoeff or 0

	if IsGradient(c) then
		return CreateColor(colorCoeff * c.tl.r, colorCoeff * c.tl.g, colorCoeff * c.tl.b, alphaCoeff * c.tl.a)
	else
		return CreateColor(colorCoeff * c.r, colorCoeff * c.g, colorCoeff * c.b, alphaCoeff * c.a)
	end
end

local function CreateGradient(topLeft, topRight, bottomLeft, bottomRight)
	return { tl = EHH:CloneTable(topLeft), tr = EHH:CloneTable(topRight), bl = EHH:CloneTable(bottomLeft), br = EHH:CloneTable(bottomRight) }
end

local function CreateGradientFade(color, directions)
	local c

	if IsGradient(color) then
		c = CreateGradient(color.tl, color.tr, color.bl, color.br)
	else
		c = CreateGradient(color, color, color, color)
	end

	if bit.Has(directions, bit.New(1)) then c.tl = FadeColor(c.tl) end
	if bit.Has(directions, bit.New(2)) then c.tr = FadeColor(c.tr) end
	if bit.Has(directions, bit.New(3)) then c.bl = FadeColor(c.bl) end
	if bit.Has(directions, bit.New(4)) then c.br = FadeColor(c.br) end

	return c
end

local function LerpColor(cout, c1, c2, interval)
	if IsGradient(c1) then
		local tl1, tr1, bl1, br1 = c1.tl, c1.tr, c1.bl, c1.br
		local tl2, tr2, bl2, br2 = c2.tl, c2.tr, c2.bl, c2.br

		if not cout then
			cout = { tl = EHH:CloneTable(Colors.Black), tr = EHH:CloneTable(Colors.Black), bl = EHH:CloneTable(Colors.Black), br = EHH:CloneTable(Colors.Black) }
		elseif not cout.tl then
			cout.tl, cout.tr, cout.bl, cout.br = EHH:CloneTable(Colors.Black), EHH:CloneTable(Colors.Black), EHH:CloneTable(Colors.Black), EHH:CloneTable(Colors.Black)
		end

		cout.tl.r, cout.tl.g, cout.tl.b, cout.tl.a = zo_lerp(tl1.r, tl2.r, interval), zo_lerp(tl1.g, tl2.g, interval), zo_lerp(tl1.b, tl2.b, interval), zo_lerp(tl1.a, tl2.a, interval)
		cout.tr.r, cout.tr.g, cout.tr.b, cout.tr.a = zo_lerp(tr1.r, tr2.r, interval), zo_lerp(tr1.g, tr2.g, interval), zo_lerp(tr1.b, tr2.b, interval), zo_lerp(tr1.a, tr2.a, interval)
		cout.bl.r, cout.bl.g, cout.bl.b, cout.bl.a = zo_lerp(bl1.r, bl2.r, interval), zo_lerp(bl1.g, bl2.g, interval), zo_lerp(bl1.b, bl2.b, interval), zo_lerp(bl1.a, bl2.a, interval)
		cout.br.r, cout.br.g, cout.br.b, cout.br.a = zo_lerp(br1.r, br2.r, interval), zo_lerp(br1.g, br2.g, interval), zo_lerp(br1.b, br2.b, interval), zo_lerp(br1.a, br2.a, interval)
	else
		if not cout then
			cout = {}
		elseif cout.tl then
			cout.tl, cout.tr, cout.bl, cout.br = nil, nil, nil, nil
		end

		cout.r, cout.g, cout.b, cout.a = zo_lerp(c1.r, c2.r, interval), zo_lerp(c1.g, c2.g, interval), zo_lerp(c1.b, c2.b, interval), zo_lerp(c1.a, c2.a, interval)
	end
end

local function SetVertexColor(control, vertex, color, filter)
	if "userdata" ~= type(control) or "number" ~= type(vertex) or "table" ~= type(color) or not control.SetVertexColors then
		return
	end

	if "table" ~= type(filter) then
		filter = {}
	end

	control:SetVertexColors(vertex, color.r * (filter.r or 1), color.g * (filter.g or 1), color.b * (filter.b or 1), color.a * (filter.a or 1))
end

function EHH:SetVertexColor(...)
	return SetVertexColor(...)
end

local function SetColor(control, color, filter)
	if "userdata" ~= type(control) or "table" ~= type(color) then
		return
	end

	if "table" ~= type(filter) then
		filter = {}
	end

	if color.tl or color.tr or color.bl or color.br then
		SetVertexColor(control, 1, color.tl, filter)
		SetVertexColor(control, 2, color.tr, filter)
		SetVertexColor(control, 4, color.bl, filter)
		SetVertexColor(control, 8, color.br, filter)
	else
		control:SetColor((color.r or 1) * (filter.r or 1), (color.g or 1) * (filter.g or 1), (color.b or 1) * (filter.b or 1), (color.a or 1) * (filter.a or 1))
	end
end

function EHH:SetColor(...)
	return SetColor(...)
end

local function AlphaColor(color, alpha)
	return CreateColor(color.r * alpha, color.g * alpha, color.b * alpha, color.a * alpha)
end

local Colors = {}
-- 687FCF
-- Colors.ButtonBackdrop = CreateGradient(CreateColor(0, 0.4, 0.5, 1), CreateColor(0, 0.2, 0.3, 1), CreateColor(0, 0.4, 0.5, 1), CreateColor(0, 0.2, 0.3, 1))
-- 0.407, 0.50, 0.812
-- 0.307, 0.35, 0.612
-- Colors.Arrow = CreateColor(0.407, 0.50, 0.812, 1)
-- Orange color: (0.784, 0.627, 0.322, 1)
Colors.Arrow = CreateColor(1, 1, 1, 1)
Colors.Black = CreateColor(0, 0, 0, 1)
Colors.ButtonOutline = CreateColor(0, 0, 0, 1)
Colors.ButtonBackdrop = CreateGradient(CreateColor(0.407, 0.5, 0.812, 1), CreateColor(0.307, 0.35, 0.612, 1), CreateColor(0.407, 0.5, 0.812, 1), CreateColor(0.307, 0.35, 0.612, 1))
Colors.ButtonLabelColor = CreateColor(1, 1, 1, 1)
Colors.ButtonLabelFont = "$(BOLD_FONT)|$(KB_19)|soft-shadow-thin"
Colors.ControlBackdrop = CreateColor(0, 0, 0, 1)
Colors.ControlBackdropHighlight = CreateColor(0.3, 0.3, 0.3, 1)
Colors.ControlBox = CreateGradient(CreateColor(0.407, 0.5, 0.812, 1), CreateColor(0.307, 0.35, 0.612, 1), CreateColor(0.407, 0.5, 0.812, 1), CreateColor(0.307, 0.35, 0.612, 1))
Colors.CustomFont = "$(MEDIUM_FONT)|$(KB_%d)|%s"
Colors.Default = CreateColor(1, 1, 1, 1)
Colors.Divider = CreateColor(0.2, 0.9, 1, 1)
Colors.Label = CreateColor(1, 1, 1, 1)
Colors.LabelFont = "$(BOLD_FONT)|$(KB_19)"
Colors.LabelFontBold = "$(BOLD_FONT)|$(KB_19)|soft-shadow-thick"
Colors.LabelHeading = CreateColor(0.507, 0.62, 1, 1)
Colors.LabelHeadingFont = "$(BOLD_FONT)|$(KB_19)"
--Colors.ListBackdrop = CreateGradient(CreateColor(0.307, 0.35, 0.612, 1), CreateColor(0, 0, 0, 1), CreateColor(0.307, 0.35, 0.612, 1), CreateColor(0, 0, 0, 1))
--Colors.ListBox = CreateGradient(CreateColor(0.407, 0.5, 0.812, 1), CreateColor(0.307, 0.35, 0.612, 1), CreateColor(0.407, 0.5, 0.812, 1), CreateColor(0.307, 0.35, 0.612, 1))
Colors.ListBackdrop = CreateGradient(CreateColor(0.125, 0.15, 0.3, 1), CreateColor(0, 0, 0, 1), CreateColor(0.125, 0.15, 0.3, 1), CreateColor(0, 0, 0, 1))
Colors.ListBox = CreateGradient(CreateColor(0.2, 0.25, 0.412, 1), CreateColor(0.307, 0.35, 0.612, 1), CreateColor(0.2, 0.25, 0.412, 1), CreateColor(0.307, 0.35, 0.612, 1))
Colors.ListItemFont = "$(BOLD_FONT)|$(KB_19)|soft-shadow-thick"
Colors.ListItemBackdrop = CreateColor(0.307, 0.35, 0.612, 0)
Colors.ListItemSelectedBackdrop = CreateColor(0.25, 0.25, 0.25, 0.5)
Colors.ItemMouseEnter = CreateColor(0.407, 0.5, 0.812, 0.4)
Colors.ItemSelected = CreateColor(0.407, 0.5, 0.812, 0.4)
Colors.ItemLabel = CreateColor(1, 1, 1, 1)
Colors.FilterDisabled = CreateColor(0.4, 0.4, 0.4, 1)
Colors.SliderArrow = CreateColor(0.407, 0.5, 0.812, 1)
Colors.SliderBackdrop = CreateColor(0, 0, 0, 1)
Colors.SliderThumb = CreateColor(0.407, 0.5, 0.812, 1)
Colors.TabBackdrop = CreateGradient(CreateColor(0.407, 0.50, 0.812, 1), CreateColor(0.307, 0.35, 0.612, 1), CreateColor(0.407, 0.50, 0.812, 1), CreateColor(0.307, 0.35, 0.612, 1))
Colors.Transparent = CreateColor(0, 0, 0, 0)
Colors.WindowBackdrop = CreateColor(0.307, 0.35, 0.612, 1)
Colors.WindowBox = CreateGradient(CreateColor(0.407, 0.50, 0.812, 0.5), CreateColor(0.307, 0.35, 0.612, 0.5), CreateColor(0.407, 0.50, 0.812, 0.5), CreateColor(0.307, 0.35, 0.612, 0.5))

function EHH:DeferredInitializeColors()
	self.Colors = Colors
end

---[ Controls ]---

function EHH:CreateItemStockString(itemLabel, totalCount, boundCount)
	totalCount, boundCount = totalCount or 0, boundCount or 0
	local tradeableCount = totalCount - boundCount
	local tradeableString = tradeableCount > 0 and string.format(" |cffffffx|cffff88%d%s|r", tradeableCount, self.Textures.ICON_TRADEABLE) or ""
	local boundString = boundCount > 0 and string.format(" |cffffffx|cffff88%d%s|r", boundCount, self.Textures.ICON_CROWN) or ""

	if itemLabel and #itemLabel > 30 then
		itemLabel = string.sub(itemLabel, 1, 27) .. "..."
	end

	return string.format("%s%s |cffffff%s|r", tradeableString, boundString, itemLabel or "")
end

local function SetControlHidden(control, hidden, includeNestedChildren)
	local t = type(control)

	if "userdata" == t then
		control:SetHidden(hidden)

		if includeNestedChildren then
			local child

			for index = 1, control:GetNumChildren() do
				child = control:GetChild(index)
				SetControlHidden(child, hidden, true)
			end
		end
	elseif "table" == t then
		for index = 1, #control do
			SetControlHidden(control[index], hidden, includeNestedChildren)
		end
	end
end
EHH.SetControlHidden = SetControlHidden

local function CreateAnchor(localPoint, anchorControl, anchorPoint, offsetX, offsetY)
	return { localPoint, anchorControl, anchorPoint, offsetX, offsetY }
end

local function AddAnchor(control, anchor)
	if anchor then
		control:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
	end
end

local function CreateWindow(name, anchor1, anchor2, width, height, movable, resizable, clamped)
	local w = WINDOW_MANAGER:CreateTopLevelWindow(name)

	if anchor1 then AddAnchor(w, anchor1) end
	if anchor2 then AddAnchor(w, anchor2) end
	if width then w:SetWidth(width) end
	if height then w:SetHeight(height) end
	w:SetMouseEnabled(true)
	w:SetMovable(false ~= movable)
	w:SetResizeHandleSize(false ~= resizable and 10 or 0)
	w:SetClampedToScreen(false ~= clamped)

	return w
end

local function CreateLabel(name, control, text, anchor1, anchor2, width, height, Halignment, Valignment, color)
	local c = WINDOW_MANAGER:CreateControl(name, control, CT_LABEL)

	c:SetFont(Colors.LabelFont)
	c:SetHorizontalAlignment(Halignment or TEXT_ALIGN_LEFT)
	c:SetVerticalAlignment(Valignment or TEXT_ALIGN_CENTER)
	c:SetText(text)
	if anchor1 then AddAnchor(c, anchor1) end
	if anchor2 then AddAnchor(c, anchor2) end
	if width then c:SetWidth(width) end
	if height then c:SetHeight(height) end
	if color then SetColor(c, color) else c:SetColor(1, 1, 1, 1) end

	return c
end

local function SetLabelFont(control, size, shadow, outline)
	control:SetFont(string.format(Colors.CustomFont, size, shadow and "soft-shadow-thick" or (outline and "outline" or "")))
end

local function CreateButtonLabel(...)
	local c = CreateLabel(...)
	SetColor(c, Colors.ButtonLabelColor)
	c:SetFont(Colors.ButtonLabelFont)
	c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

	return c
end

local function CreateContainer(name, parent, anchor1, anchor2, width, height)
	local c = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)

	if not width and not height then c:SetResizeToFitDescendents(true) end
	if anchor1 then AddAnchor(c, anchor1) end
	if anchor2 then AddAnchor(c, anchor2) end
	if width then c:SetWidth(width) end
	if height then c:SetHeight(height) end

	return c
end

local function CreateTexture(name, parent, anchor1, anchor2, width, height, texture, color)
	local c = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)

	c:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
	if anchor1 then AddAnchor(c, anchor1) end
	if anchor2 then AddAnchor(c, anchor2) end
	if width then c:SetWidth(width) end
	if height then c:SetHeight(height) end
	if texture then c:SetTexture(texture) end
	if color then SetColor(c, color) end

	return c
end

local function CreateButtonOnMouseEnter(control)
	control.Backdrop:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1.4)
	WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_UI_HAND)
end

local function CreateButtonOnMouseExit(control)
	control.Backdrop:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1)
	WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
end

local function CreateButton(name, parent, label, anchor, width, height, onClick)
	local button = CreateContainer(name, parent, anchor, nil, width, height)
	if anchor then AddAnchor(button, anchor) end
	button:SetMouseEnabled(true)
	button:SetHandler("OnMouseDown", onClick)
	button:SetHandler("OnMouseEnter", CreateButtonOnMouseEnter)
	button:SetHandler("OnMouseExit", CreateButtonOnMouseExit)
--[[
	button.Outline = CreateTexture(name .. "Outline", button, CreateAnchor(TOPLEFT, button, TOPLEFT, 0, 0), CreateAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, 0, 0), nil, nil, EHH.Textures.Solid, Colors.ButtonOutline)
	button.Outline:SetMouseEnabled(false)

	button.Backdrop = CreateTexture(name .. "Backdrop", button.Outline, CreateAnchor(TOPLEFT, button.Outline, TOPLEFT, 1, 1), CreateAnchor(BOTTOMRIGHT, button.Outline, BOTTOMRIGHT, -1, -1), nil, nil, EHH.Textures.Solid, Colors.ButtonBackdrop)
	button.Backdrop:SetMouseEnabled(false)
]]
	button.Backdrop = CreateTexture(name .. "Backdrop", button, CreateAnchor(TOPLEFT, button, TOPLEFT, 0, 0), CreateAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, 0, 0), nil, nil, EHH.Textures.ICON_BUTTON, Colors.Default)
	button.Backdrop:SetMouseEnabled(false)

	button.Label = CreateButtonLabel(name .. "Label", button.Backdrop, label, CreateAnchor(TOPLEFT, button.Backdrop, TOPLEFT, 0, 0), CreateAnchor(BOTTOMRIGHT, button.Backdrop, BOTTOMRIGHT, 0, 0))
	button.Label:SetMouseEnabled(false)

	if not width and not height then
		local width, height = button.Label:GetTextDimensions()
		button:SetDimensions(width + 24, height + 12)
	end

	return button
end

local function CreateWindowBackdrop( outlineName, backdropName, parent, topFadeHeight, bottomFadeHeight )
	topFadeHeight, bottomFadeHeight = topFadeHeight or 0, bottomFadeHeight or 0
	local f, bb, bo, tb, to

	local o = CreateTexture( outlineName, parent )
	o:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, topFadeHeight )
	o:SetAnchor( BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, bottomFadeHeight )
	o:SetMouseEnabled( false )
	SetColor( o, Colors.WindowBox )

	if 0 < topFadeHeight then
		f = CreateTexture( nil, parent )
		to = f
		f:SetAnchor( TOPLEFT, o, TOPLEFT, 0, -topFadeHeight )
		f:SetAnchor( BOTTOMRIGHT, o, TOPRIGHT, 0, 0 )
		f:SetMouseEnabled( false )
		SetColor( f, CreateGradientFade( Colors.WindowBox, bit.Set( bit.New( 1 ), bit.New( 2 ) ) ) )

		f = CreateTexture( nil, parent )
		tb = f
		f:SetAnchor( TOPLEFT, o, TOPLEFT, 2, -( topFadeHeight - 2 ) )
		f:SetAnchor( BOTTOMRIGHT, o, TOPRIGHT, -2, 2 )
		f:SetMouseEnabled( false )
		SetColor( f, CreateGradientFade( Colors.WindowBackdrop, bit.Set( bit.New( 1 ), bit.New( 2 ) ) ) )
	end

	if 0 < bottomFadeHeight then
		f = CreateTexture( nil, parent )
		bo = f
		f:SetAnchor( TOPLEFT, o, BOTTOMLEFT, 0, 0 )
		f:SetAnchor( BOTTOMRIGHT, o, BOTTOMRIGHT, 0, bottomFadeHeight )
		f:SetMouseEnabled( false )
		SetColor( f, CreateGradientFade( Colors.WindowBox, bit.Set( bit.New( 3 ), bit.New( 4 ) ) ) )

		f = CreateTexture( nil, parent )
		bb = f
		f:SetAnchor( TOPLEFT, o, BOTTOMLEFT, 2, -2 )
		f:SetAnchor( BOTTOMRIGHT, o, BOTTOMRIGHT, -2, bottomFadeHeight - 2 )
		f:SetMouseEnabled( false )
		SetColor( f, CreateGradientFade( Colors.WindowBackdrop, bit.Set( bit.New( 3 ), bit.New( 4 ) ) ) )
	end

	local b = CreateTexture( backdropName, parent )

	b:SetAnchor( TOPLEFT, o, TOPLEFT, 2, 2 )
	b:SetAnchor( BOTTOMRIGHT, o, BOTTOMRIGHT, -2, -2 )
	b:SetMouseEnabled( false )
	SetColor( b, Colors.WindowBackdrop )

	return o, b, to, tb, bo, bb
end

---[ Picklist Control ]---

do
	EHH.Picklist = ZO_Object:Subclass()
	local base = EHH.Picklist

	local defaults = {}
	base.Defaults = defaults
	defaults.AlphaPicklist = 1
	defaults.ColorArrow = Colors.Arrow
	defaults.ColorBackdrop = Colors.ControlBackdrop
	defaults.ColorBox = Colors.ControlBox
	defaults.ColorLabel = Colors.Label
	defaults.ColorListBackdrop = Colors.ListBackdrop
	defaults.ColorListBox = Colors.ListBox
	defaults.ColorItemMouseEnter = Colors.ItemMouseEnter
	defaults.ColorItemSelected = Colors.ItemSelected
	defaults.ColorItemLabel = Colors.ItemLabel
	defaults.ColorFilterDisabled = Colors.FilterDisabled
	defaults.ColorSliderArrow = Colors.SliderArrow
	defaults.ColorSliderBackdrop = Colors.SliderBackdrop
	defaults.ColorSliderThumb = Colors.SliderThumb
	defaults.DrawLayerPicklist = DL_TEXT
	defaults.DrawLevelPicklist = 50000
	defaults.DrawTierPicklist = DT_HIGH
	defaults.FontLabel = "$(MEDIUM_FONT)|$(KB_16)"
	defaults.FontItemLabel = "$(MEDIUM_FONT)|$(KB_16)"
	defaults.Height = 26
	defaults.HeightListMaxRatio = 0.9
	defaults.HeightMax = 200
	defaults.HeightMin = 24
	defaults.PaddingListHeight = 10
	defaults.PaddingListWidth = 28
	defaults.ScrollInterval = 100
	defaults.ScrollLinesLarge = 10
	defaults.ScrollLinesSmall = 1
	defaults.SpacingItems = 2
	defaults.VisibleItemsMax = 30
	defaults.VisibleItemsMin = 1
	defaults.Width = 200
	defaults.WidthMax = 1024
	defaults.WidthMin = 50

	local behaviors = {}
	base.EventBehaviors = behaviors
	behaviors.HardwareOnly = 1
	behaviors.AlwaysRaise = 2

	base.ActiveInstance = nil
	base.CreateTooltip = function(...) return EssentialHousingHub:SetInfoTooltip(...) end
	base.DefaultSortFunction = function (itemA, itemB) return 0 > CompareStringValues(itemA.Label, itemB.Label) end
	base.Instances = {}
	base.WasHardwareEventRaised = false
	base.PicklistDialog = ZO_Object.New(ZO_Object:Subclass())

	function base.PicklistDialog:Initialize()
		if not self.Initialized then
			local prefix = "EHHPicklistDialog"
			local w, c

			w = WINDOW_MANAGER:CreateTopLevelWindow(prefix)
			self.Window = w
			w:SetHidden(true)
			w:SetAlpha(base.Defaults.AlphaPicklist)
			w:SetClampedToScreen(true)
			w:SetMovable(false)
			w:SetMouseEnabled(false)
			w:SetResizeHandleSize(0)
			self:UpdateDrawOrder()

			c = WINDOW_MANAGER:CreateControl(nil, w, CT_TEXTURE)
			self.Box = c
			c:SetTexture(Textures.Solid)
			c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
			c:SetMouseEnabled(false)
			SetColor(c, base.Defaults.ColorListBox)
			c:SetAnchorFill(w)

			c = WINDOW_MANAGER:CreateControl(nil, self.Box, CT_TEXTURE)
			self.Backdrop = c
			c:SetTexture(Textures.Solid)
			c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
			c:SetMouseEnabled(false)
			SetColor(c, base.Defaults.ColorListBackdrop)
			c:SetAnchor(TOPLEFT, self.Box, TOPLEFT, 2, 2)
			c:SetAnchor(BOTTOMRIGHT, self.Box, BOTTOMRIGHT, -2, -2)

			c = WINDOW_MANAGER:CreateControl(nil, self.Backdrop, CT_SCROLL)
			self.ScrollRegion = c
			c:SetMouseEnabled(true)
			c:SetAnchor(TOPLEFT, self.Backdrop, TOPLEFT, 2, 2)
			c:SetAnchor(BOTTOMRIGHT, self.Backdrop, BOTTOMRIGHT, -18, -2)

			c = WINDOW_MANAGER:CreateControl(nil, self.Backdrop, CT_TEXTURE)
			self.SliderBox = c
			c:SetAnchor(TOPLEFT, self.Backdrop, TOPRIGHT, -17, 21)
			c:SetAnchor(BOTTOMRIGHT, self.Backdrop, BOTTOMRIGHT, -2, -21)
			SetColor(c, base.Defaults.ColorSliderBackdrop)
			c:SetMouseEnabled(false)

			c = WINDOW_MANAGER:CreateControl(nil, self.SliderBox, CT_SLIDER)
			self.Slider = c
			c:SetAllowDraggingFromThumb(true)
			c:SetMouseEnabled(true)
			c:SetValue(0)
			c:SetValueStep(1)
			c:SetOrientation(ORIENTATION_VERTICAL)
			c:SetThumbTexture("EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 15, 64)
			SetColor(c:GetThumbTextureControl(), base.Defaults.ColorSliderThumb)
			c:SetAnchorFill(self.SliderBox)

			self.Slider:SetHandler("OnValueChanged", function(control, value, eventReason)
				self:Refresh(value)
			end)

			local scrollingUp

			local function Scrolling()
				local value = self.Slider:GetValue()
				if 0 >= value then value = 1 end
				local direction = scrollingUp and -1 or 1
				self.Slider:SetValue(value + direction * (IsShiftKeyDown() and base.Defaults.ScrollLinesLarge or base.Defaults.ScrollLinesSmall))
			end

			local function StopScrolling()
				HUB_EVENT_MANAGER:UnregisterForUpdate("EHH.Picklist.Scrolling")
			end

			local function StartScrolling(isUp)
				scrollingUp = isUp
				Scrolling()

				HUB_EVENT_MANAGER:RegisterForUpdate("EHH.Picklist.Scrolling", base.Defaults.ScrollInterval, Scrolling)
			end

			self.ScrollRegion:SetHandler("OnMouseWheel", function(control, delta, ctrl, alt, shift)
				local slider = self.Slider
				local value = slider:GetValue()

				if 0 == value then value = 1 end
				slider:SetValue(value - (delta * (shift and base.Defaults.ScrollLinesLarge or base.Defaults.ScrollLinesSmall)))
			end)

			c = WINDOW_MANAGER:CreateControl(nil, self.Slider, CT_TEXTURE)
			self.SliderUp = c
			c:SetTexture("esoui/art/miscellaneous/gamepad/gp_scrollarrow_up.dds")
			c:SetAnchor(BOTTOM, self.Slider, TOP, 0, -1)
			SetColor(c, base.Defaults.ColorSliderArrow)
			c:SetDimensions(15, 18)
			c:SetMouseEnabled(true)
			c:SetHandler("OnMouseUp", StopScrolling)
			c:SetHandler("OnMouseDown", function() StartScrolling(true) end)

			c = WINDOW_MANAGER:CreateControl(nil, self.Slider, CT_TEXTURE)
			self.SliderDown = c
			c:SetTexture("esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds")
			c:SetAnchor(TOP, self.Slider, BOTTOM, 0, 1)
			SetColor(c, base.Defaults.ColorSliderArrow)
			c:SetDimensions(15, 18)
			c:SetMouseEnabled(true)
			c:SetHandler("OnMouseUp", StopScrolling)
			c:SetHandler("OnMouseDown", function() StartScrolling(false) end)

			c = WINDOW_MANAGER:CreateControl(nil, self.ScrollRegion, CT_CONTROL)
			self.ListBox = c
			c:SetAnchorFill(self.ScrollRegion)
			c:SetMouseEnabled(false)

			c = WINDOW_MANAGER:CreateControl(nil, self.ListBox, CT_TEXTURE)
			self.ItemMouseEnter = c
			c:SetHidden(true)
			c:SetTexture(Textures.Solid)
			c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
			SetColor(c, base.Defaults.ColorItemMouseEnter)
			c:SetMouseEnabled(false)

			c = WINDOW_MANAGER:CreateControl(nil, self.ListBox, CT_TEXTURE)
			self.ItemSelected = c
			c:SetHidden(true)
			c:SetTexture(Textures.Solid)
			c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
			SetColor(c, base.Defaults.ColorItemSelected)
			c:SetMouseEnabled(false)

			self.ListItems = {}

			for index = 1, base.Defaults.VisibleItemsMax do
				c = WINDOW_MANAGER:CreateControl(nil, self.ListBox, CT_LABEL)
				table.insert(self.ListItems, c)
				SetColor(c, base.Defaults.ColorItemLabel)
				c:SetFont(base.Defaults.FontItemLabel)
				c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				c:SetMaxLineCount(10)
				c:SetMouseEnabled(true)
				c:SetText("")
				c:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
				c:SetHandler("OnMouseEnter", function(control)
					self:OnItemMouseEnter(control)
					self:OnShowItemTooltip(control)
				end)
				c:SetHandler("OnMouseExit", function(control)
					self:OnItemMouseExit(control)
					EssentialHousingHub:HideTooltip()
				end)
				c:SetHandler("OnMouseDown", function(control, ...)
					self:OnItemMouseDown(control.ItemIndex, control.Item, ...)
				end)
			end

			self.OnMousePressHandler = function(...)
				self:OnMousePressed(...)
			end

			self.Initialized = true
		end

		return self.Window
	end
	
	function base.PicklistDialog:UpdateDrawOrder()
		local w = self.Window
		local layer, level, tier = base.Defaults.DrawLayerPicklist, base.Defaults.DrawLevelPicklist, base.Defaults.DrawTierPicklist

		local instance = self.ActiveInstance
		if instance then
			layer = math.max(layer, instance.Control:GetDrawLayer())
			level = math.max(level, instance.Control:GetDrawLevel() + 5)
			tier = math.max(tier, instance.Control:GetDrawTier())
		end

		w:SetDrawLayer(layer)
		w:SetDrawLevel(level)
		w:SetDrawTier(tier)
	end

	function base.PicklistDialog:OnMousePressed(button, state)
		if self.ActiveInstance then
			if not self:IsMouseOverControl(self.Window) and not self:IsMouseOverControl(self.ActiveInstance:GetControl()) then
				self:Hide()
			end
		end
	end

	function base.PicklistDialog:GetMaxHeight()
		return math.floor(GuiRoot:GetHeight() * base.Defaults.HeightListMaxRatio)
	end

	function base.PicklistDialog:IsActiveInstance(instance)
		return instance == self.ActiveInstance
	end

	function base.PicklistDialog:Hide()
		self.ActiveInstance = nil

		local win = self:Initialize()
		win:SetHidden(true)
	end

	function base.PicklistDialog:Show(instance)
		if self.ActiveInstance == instance then
			return
		end

		local win = self:Initialize()
		win:SetHidden(true)

		self.ActiveInstance = instance
		if not instance then
			return
		end

		local items = instance:GetItems()
		if not items then
			return
		end

		local itemHeight = self:GetItemHeight()
		local listItemsVisible = self:GetNumVisibleItems()
		local listHeight = (itemHeight * listItemsVisible) + base.Defaults.PaddingListHeight
		local listWidth = instance:GetWidth() + base.Defaults.PaddingListWidth
		local listItem, previousItem

		self.ItemMouseEnter:SetHidden(true)
		self.ItemMouseEnter:ClearAnchors()

		self.ItemSelected:SetHidden(true)
		self.ItemSelected:ClearAnchors()

		for index = 1, #self.ListItems do
			listItem = self.ListItems[index]

			listItem:ClearAnchors()
			if 1 == index then
				listItem:SetAnchor(TOPLEFT, self.ListBox, TOPLEFT, 1, 1)
				listItem:SetAnchor(BOTTOMRIGHT, self.ListBox, TOPRIGHT, -1, itemHeight)
				listItem:SetHidden(false)
			elseif index <= listItemsVisible then
				listItem:SetAnchor(TOPLEFT, previousItem, BOTTOMLEFT, 0, 0)
				listItem:SetAnchor(BOTTOMRIGHT, previousItem, BOTTOMRIGHT, 0, itemHeight)
				listItem:SetHidden(false)
			else
				listItem:SetHidden(true)
			end

			previousItem = listItem
		end

		self.Slider:SetMinMax(1, math.max(1, 1 + #items - listItemsVisible))

		if instance:GetSorted() and instance:GetItemsDirty() then
			local sorter = instance:GetSortFunction()

			if "function" == type(sorter) then
				table.sort(instance:GetItems(), sorter)
			end

			instance:SetItemsDirty(false)
		end

		self.Slider:SetHidden(listItemsVisible >= #items)

		local maxWidth = 0

		for index = 1, listItemsVisible do
			maxWidth = math.max(maxWidth, self:GetItemLabelWidth(index))
		end

		if maxWidth > listWidth - base.Defaults.PaddingListWidth then
			listWidth = maxWidth + 2 * base.Defaults.PaddingListWidth
		end

		win:SetDimensions(listWidth, listHeight)
		self:RefreshAnchor()
		self:ScrollToSelected()
		self:UpdateDrawOrder()
		win:SetHidden(false)

		HUB_EVENT_MANAGER:RegisterForUpdate("EHH.PicklistDialog.OnHeartbeat", 200, function() self:OnHeartbeat() end)
	end

	function base.PicklistDialog:RefreshAnchor()
		if not self.Window or not self.ActiveInstance then
			return
		end

		local instance = self.ActiveInstance
		local screenWidth, screenHeight = GuiRoot:GetDimensions()
		local screenCenterX, screenCenterY = GuiRoot:GetCenter()
		local width, height = self.Window:GetDimensions()
		local left, top, right, bottom = instance:GetScreenRect()
		local centerX, centerY = instance:GetCenter()

		self.Window:ClearAnchors()

		if screenWidth > left + width and screenHeight > bottom + height then
			self.Window:SetAnchor(TOPLEFT, instance:GetControl(), BOTTOMLEFT, 0, -1)
		elseif 0 < right - width and screenHeight > bottom + height then
			self.Window:SetAnchor(TOPRIGHT, instance:GetControl(), BOTTOMRIGHT, 0, -1)
		elseif screenWidth > left + width and 0 < top - height then
			self.Window:SetAnchor(BOTTOMLEFT, instance:GetControl(), TOPLEFT, 0, 1)
		elseif 0 < right - width and 0 < top - height then
			self.Window:SetAnchor(BOTTOMRIGHT, instance:GetControl(), TOPRIGHT, 0, 1)
		elseif screenCenterX >= centerX then
			self.Window:SetAnchor(LEFT, instance:GetControl(), RIGHT, -1, 0)
		else
			self.Window:SetAnchor(RIGHT, instance:GetControl(), LEFT, 1, 0)
		end

		self.AnchorX, self.AnchorY = centerX, centerY
	end

	function base.PicklistDialog:GetFontHeight()
		return self.ListItems[1]:GetFontHeight()
	end

	function base.PicklistDialog:GetItemLabelWidth(index)
		local item = self.ListItems[index]

		if not item then
			return 0
		end

		local text = item:GetText()

		if not text or "" == text then
			return 0
		end

		local newLineIndex = string.find(text, "\n")

		if newLineIndex and 0 < newLineIndex then
			text = string.sub(text, 1, newLineIndex - 1)
		end

		return item:GetStringWidth(text)
	end

	function base.PicklistDialog:GetItemHeight()
		local instance = self.ActiveInstance
		local itemLineHeight = self:GetFontHeight() or 0
		local itemLines = instance and (instance:GetItemLines() or 0) or 0
		local itemHeight = itemLines * itemLineHeight + base.Defaults.SpacingItems

		return itemHeight
	end

	function base.PicklistDialog:GetNumVisibleItems()
		local instance = self.ActiveInstance

		if not instance then
			return 0
		end

		local items = instance:GetItems()

		if not items then
			return 0
		end

		local itemHeight = self:GetItemHeight()
		local maxHeight = self:GetMaxHeight()
		local count = math.floor(math.max(base.Defaults.VisibleItemsMin * itemHeight, math.min(#items * itemHeight, maxHeight)) / itemHeight)

		return math.min(count, base.Defaults.VisibleItemsMax)
	end

	function base.PicklistDialog:Refresh(offset)
		local instance = self.ActiveInstance
		if not instance then
			return
		end

		offset = offset or self.Slider:GetValue()

		local win = self:Initialize()
		local items = instance:GetItems()
		local itemIndex = offset
		local itemsVisible = self:GetNumVisibleItems()
		local maxItemIndex = math.min(#items, offset + itemsVisible)
		local selectedItem = instance:GetSelectedItemObject()

		for index = 1, itemsVisible do
			local listItem = self.ListItems[index]
			local item = items[itemIndex]

			if item then
				listItem:SetText(item.Label)
				listItem.ItemIndex = itemIndex
				listItem.Item = item

				if selectedItem == item then
					self.ItemSelected:ClearAnchors()
					self.ItemSelected:SetAnchorFill(listItem)
					self.ItemSelected:SetHidden(false)
					selectedItem = nil
				end

				itemIndex = itemIndex + 1
				if itemIndex > maxItemIndex then
					itemIndex = -1
				end
			else
				listItem:SetText("")
				listItem.ItemIndex = nil
				listItem.Item = nil
			end
		end

		if selectedItem then
			self.ItemSelected:SetHidden(true)
			self.ItemSelected:ClearAnchors()
		end
	end

	function base.PicklistDialog:ScrollToTop()
		self.Slider:SetValue(1)
		self:Refresh()
	end

	function base.PicklistDialog:ScrollToSelected()
		local instance = self.ActiveInstance

		if not instance then
			self:ScrollToTop()
			return
		end

		local itemIndex = instance:GetSelectedItemIndex()

		if not itemIndex then
			self:ScrollToTop()
			return
		end

		self.Slider:SetValue(itemIndex)
		self:Refresh()
	end

	function base.PicklistDialog:OnHeartbeat()
		local instance = self.ActiveInstance

		if not instance then
			HUB_EVENT_MANAGER:UnregisterForUpdate("EHH.PicklistDialog.OnHeartbeat")
			return
		end

		if instance:GetControl():IsHidden() then
			self:Hide()
			HUB_EVENT_MANAGER:UnregisterForUpdate("EHH.PicklistDialog.OnHeartbeat")
			return
		end

		local centerX, centerY = instance:GetCenter()

		if centerX ~= self.AnchorX or centerY ~= self.AnchorY then
			self:RefreshAnchor()
		end
	end

	function base.PicklistDialog:OnItemMouseEnter(control)
		if control and control.Item then
			local _, _, anchor = self.ItemMouseEnter:GetAnchor(1)

			if control ~= anchor then
				self.ItemMouseEnter:ClearAnchors()
				self.ItemMouseEnter:SetAnchorFill(control)
				self.ItemMouseEnter:SetHidden(false)
			end
		end
	end

	function base.PicklistDialog:OnItemMouseExit(control)
		local _, _, anchor = self.ItemMouseEnter:GetAnchor(1)

		if control == anchor then
			self.ItemMouseEnter:SetHidden(true)
			self.ItemMouseEnter:ClearAnchors()
		end
	end

	function base.PicklistDialog:OnItemMouseDown(itemIndex, item)
		local instance = self.ActiveInstance

		if instance and itemIndex and item then
			base.WasHardwareEventRaised = true
			instance:SetSelectedItem(item)
		end

		self:Hide()
	end

	function base.PicklistDialog:OnShowItemTooltip(control)
		if control:GetWidth() < control:GetStringWidth(control:GetText()) then
			local screenX = GuiRoot:GetCenter()
			local controlX = control:GetCenter()
			local anchorTooltip, anchorControl, anchorOffsetX

			if controlX <= screenX then
				anchorTooltip, anchorControl, anchorOffsetX = LEFT, RIGHT, 25
			else
				anchorTooltip, anchorControl, anchorOffsetX = RIGHT, LEFT, -25
			end

			EssentialHousingHub:SetTooltip(EssentialHousingHub:Trim(control:GetText()), control, anchorTooltip)
			--EssentialHousingHub:ShowTooltip(nil, control, EssentialHousingHub:Trim(control:GetText()), anchorTooltip, anchorOffsetX, 0, anchorControl)
		end
	end

	function EHH.Picklist:New(...)
		local obj = ZO_Object.New(self)
		local picklist = obj:Initialize(...)

		if picklist then
			base.Instances[picklist:GetName()] = picklist
		end

		return picklist
	end

	function EHH.Picklist:Initialize(name, parent, anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY, width, height)
		if not self then
			error(string.format("Failed to create Picklist: Initialization instance is nil."))
			return nil
		end

		if self.Initialized then
			error(string.format("Failed to create Picklist: Instance is already initialized."))
			return nil
		end

		if not parent then
			error(string.format("Failed to create Picklist: Parent is required."))
			return nil
		end

		if not name then
			error(string.format("Failed to create Picklist: Name is required."))
			return nil
		end

		if base.Instances[name] then
			error(string.format("Failed to create Picklist: Duplicate name: %s", name))
			return nil
		end

		local c

		self.Enabled = true
		self.EventBehavior = base.EventBehaviors.HardwareOnly
		self.Name = name
		self.Parent = parent
		self.Width = width or base.Defaults.Width
		self.Height = height or base.Defaults.Height
		self.ItemLines = 1
		self.Font = base.Defaults.FontItemLabel
		self.Sorted = false
		self.SortFunction = base.DefaultSortFunction
		self.SelectedItem = nil
		self.IsControlHidden = false
		self.ItemsDirty = false
		self.Items = {}

		c = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
		self.Control = c
		c:SetDimensions(self.Width, self.Height)
		c:SetMouseEnabled(true)
		c:SetHandler("OnMouseDown", function(...)
			self:TogglePicklist()
		end)

		c = WINDOW_MANAGER:CreateControl(nil, self.Control, CT_TEXTURE)
		self.Control.Box = c
		c:SetTexture(Textures.Solid)
		c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
		SetColor(c, base.Defaults.ColorBox)
		c:SetAnchor(TOPLEFT, self.Control, TOPLEFT, 0, 0)
		c:SetAnchor(BOTTOMRIGHT, self.Control, BOTTOMRIGHT, 0, 0)

		c = WINDOW_MANAGER:CreateControl(nil, self.Control.Box, CT_TEXTURE)
		self.Control.Backdrop = c
		c:SetTexture(Textures.Solid)
		c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
		SetColor(c, base.Defaults.ColorBackdrop)
		c:SetAnchor(TOPLEFT, self.Control.Box, TOPLEFT, 2, 2)
		c:SetAnchor(BOTTOMRIGHT, self.Control.Box, BOTTOMRIGHT, -2, -2)

		c = WINDOW_MANAGER:CreateControl(nil, self.Control.Backdrop, CT_LABEL)
		self.Control.Label = c
		SetColor(c, base.Defaults.ColorLabel)
		c:SetFont(self:GetFont())
		c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		c:SetText("")
		c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		c:SetAnchor(LEFT, self.Control.Backdrop, nil, 3)
		c:SetAnchor(RIGHT, self.Control.Backdrop, nil, -20)

		c = WINDOW_MANAGER:CreateControl(nil, self.Control.Backdrop, CT_TEXTURE)
		self.Control.Arrow = c
		c:SetTexture(Textures.ICON_ARROW)
		c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
		SetColor(c, base.Defaults.ColorArrow)
		c:SetTextureCoords(0, 1, 1, 0)
		c:SetAnchor(RIGHT, self.Control.Backdrop, nil, -4)
		c:SetDimensions(11, 11)

		self:SetAnchor(anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY)
		self.Initialized = true

		return self
	end

	function EHH.Picklist:RefreshEnabled()
		self:HidePicklist()
		self.Control:SetMouseEnabled(self.Enabled)
		SetColor(self.Control.Box, base.Defaults.ColorBox, (not self.Enabled) and base.Defaults.ColorFilterDisabled)
		SetColor(self.Control.Label, base.Defaults.ColorLabel, (not self.Enabled) and base.Defaults.ColorFilterDisabled)
	end

	function EHH.Picklist:SetEnabled(value)
		self.Enabled = true == value
		self:RefreshEnabled()
	end

	function EHH.Picklist:GetFont(value)
		return self.Font
	end

	function EHH.Picklist:SetFont(value)
		self.Font = value
		self.Control.Label:SetFont(self.Font)
	end

	function EHH.Picklist:GetEventBehavior(value)
		return self.EventBehavior
	end

	function EHH.Picklist:SetEventBehavior(value)
		if self:IsTableValue(base.EventBehaviors, value) then
			self.EventBehavior = value
		end
	end

	function EHH.Picklist:GetName()
		return self.Name
	end

	function EHH.Picklist:GetParent()
		return self.Parent
	end

	function EHH.Picklist:GetControl()
		return self.Control
	end

	function EHH.Picklist:GetDrawLevel()
		return self.Control:GetDrawLevel()
	end

	function EHH.Picklist:SetDrawLayer(value)
		self.Control:SetDrawLayer(value)
		self.Control.Box:SetDrawLayer(value)
		self.Control.Backdrop:SetDrawLayer(value)
		self.Control.Label:SetDrawLayer(value)
		self.Control.Arrow:SetDrawLayer(value)
	end

	function EHH.Picklist:SetDrawLevel(value)
		self.Control:SetDrawLevel(value)
		self.Control.Box:SetDrawLevel(value)
		self.Control.Backdrop:SetDrawLevel(value + 1)
		self.Control.Label:SetDrawLevel(value + 2)
		self.Control.Arrow:SetDrawLevel(value + 3)
	end

	function EHH.Picklist:SetDrawTier(value)
		self.Control:SetDrawTier(value)
		self.Control.Box:SetDrawTier(value)
		self.Control.Backdrop:SetDrawTier(value)
		self.Control.Label:SetDrawTier(value)
		self.Control.Arrow:SetDrawTier(value)
	end

	function EHH.Picklist:GetWidth()
		return self.Control:GetWidth()
	end

	function EHH.Picklist:SetWidth(value)
		self.Width = zo_clamp(tonumber(value) or base.Defaults.Width, base.Defaults.WidthMin, base.Defaults.WidthMax)
		self.Control:SetWidth(self.Width)
		return self.Width
	end

	function EHH.Picklist:GetHeight()
		return self.Control:GetHeight()
	end

	function EHH.Picklist:SetHeight(value)
		self.Height = zo_clamp(tonumber(value) or base.Defaults.Height, base.Defaults.HeightMin, base.Defaults.HeightMax)
		self.Control:SetHeight(self.Height)
		return self.Height
	end

	function EHH.Picklist:GetDimensions()
		return self.Control:GetDimensions()
	end

	function EHH.Picklist:SetDimensions(width, height)
		self.Control:SetDimensions(width, height)
	end

	function EHH.Picklist:GetCenter()
		return self.Control:GetCenter()
	end

	function EHH.Picklist:GetScreenRect()
		return self.Control:GetScreenRect()
	end

	function EHH.Picklist:GetItemLines()
		return self.ItemLines or 1
	end

	function EHH.Picklist:SetItemLines(value)
		self.ItemLines = zo_clamp(tonumber(value) or 1, 1, 10)
	end

	function EHH.Picklist:GetItemsDirty()
		return self.ItemsDirty
	end

	function EHH.Picklist:SetItemsDirty(value)
		self.ItemsDirty = true == value
	end

	function EHH.Picklist:GetSorted()
		return self.Sorted
	end

	function EHH.Picklist:SetSorted(value)
		self.Sorted = true == value
		self.ItemsDirty = true
	end

	function EHH.Picklist:GetSortFunction()
		return self.SortFunction
	end

	function EHH.Picklist:SetSortFunction(func)
		self.ItemsDirty = true
		self.SortFunction = "function" == type(func) and func or nil

		if self.SortFunction then
			self.Sorted = true
		else
			self.Sorted = false
			self.SortFunction = base.DefaultSortFunction
		end
	end

	function EHH.Picklist:GetHandlers(event)
		if not event then
			return nil
		end

		event = string.lower(event)

		if not self.Handlers then
			self.Handlers = {}
		end

		local handlers = self.Handlers[event]

		if not handlers then
			handlers = {}
			self.Handlers[event] = handlers
		end

		return handlers
	end

	function EHH.Picklist:AddHandler(event, handler)
		local handlers = self:GetHandlers(event)

		if handlers then
			handlers[handler] = true
			return handler
		end

		return nil
	end

	function EHH.Picklist:RemoveHandler(event, handler)
		local handlers = self:GetHandlers(event)

		if handlers and handlers[handler] then
			handlers[handler] = nil
			return handler
		end

		return nil
	end

	function EHH.Picklist:CallHandlers(event, ...)
		local handlers = self:GetHandlers(event)

		if handlers then
			for handler in pairs(handlers) do
				handler(self, ...)
			end
		end
	end

	function EHH.Picklist:IsHidden()
		return self.IsControlHidden
	end

	function EHH.Picklist:SetHidden(value)
		self.IsControlHidden = false ~= value
		self.Control:SetHidden(value)
	end

	function EHH.Picklist:ClearAnchors()
		self.Control:ClearAnchors()
		self:OnResized()
	end

	function EHH.Picklist:SetAnchor(anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY)
		if anchorFrom or anchor or anchorTo then
			self.Control:SetAnchor(anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY)
		end
	end

	function EHH.Picklist:GetItems()
		return self.Items
	end

	function EHH.Picklist:GetItemByIndex(index)
		return self.Items[index]
	end

	function EHH.Picklist:FindItemIndex(item)
		local matchedIndex = nil

		if "number" == type(item) then
			for index, itemObj in ipairs(self.Items) do
				if item == itemObj.Value then
					matchedIndex = index
					break
				end
			end
		elseif "string" == type(item) then
			local lowerValue = string.lower(EssentialHousingHub:Trim(item))

			for index, itemObj in ipairs(self.Items) do
				if lowerValue == string.lower(EssentialHousingHub:Trim(itemObj.Label)) then
					matchedIndex = index
					break
				end
			end
		elseif "table" == type(item) then
			for index, itemObj in ipairs(self.Items) do
				if item.Label == itemObj.Label and item.Value == itemObj.Value then
					matchedIndex = index
					break
				end
			end
		end

		return matchedIndex
	end

	function EHH.Picklist:FindItem(item)
		return self.Items[self:FindItemIndex(item)]
	end

	function EHH.Picklist:GetSelectedItemIndex()
		return self:FindItemIndex(self.SelectedItem)
	end

	function EHH.Picklist:GetSelectedItemValue()
		if self.SelectedItem then
			return self.SelectedItem.Value
		end
		return nil
	end

	function EHH.Picklist:GetSelectedItem()
		return self.SelectedItem and self.SelectedItem.Label or nil
	end

	function EHH.Picklist:GetSelectedItemObject()
		return self.SelectedItem
	end

	function EHH.Picklist:ClearItems()
		if not self.Items then
			self.Items = {}
		else
			for index = #self.Items, 1, -1 do
				table.remove(self.Items, index)
			end
		end

		self.SelectedItem = nil
		self.ItemsDirty = true
		self:Refresh()
	end

	function EHH.Picklist:SetItems(items)
		local selectedItem = self.SelectedItem

		if "table" == type(items) then
			self.Items = items
		else
			self:ClearItems()
		end

		self.ItemsDirty = true

		if selectedItem then
			self.SelectedItem = self:FindItem(selectedItem)
		else
			self.SelectedItem = nil
		end

		return self:GetItems()
	end

	function EHH.Picklist:AddItem(label, clickHandler, value)
		local item = nil
		if label then
			item = { Label = label, Value = value, ClickHandler = clickHandler }
			table.insert(self.Items, item)
		end

		self.ItemsDirty = true
		return item
	end

	function EHH.Picklist:InsertItem(index, label, clickHandler, value)
		local item = nil
		if label then
			item = { Label = label, Value = value, ClickHandler = clickHandler }
			table.insert(self.Items, index, item)
		end

		self.ItemsDirty = true
		return item
	end

	function EHH.Picklist:SetSelectedItem(item)
		local hardware = base.WasHardwareEventRaised
		base.WasHardwareEventRaised = false

		local previousSelectedItem = self.SelectedItem
		self.SelectedItem = self:FindItem(item)

		if hardware or self:GetEventBehavior() == base.EventBehaviors.AlwaysRaise then
			self:OnSelectionChanged(self.SelectedItem)
		end

		self:Refresh()
		return self.SelectedItem
	end

	function EHH.Picklist:SelectFirstItem()
		local item = self.Items[1]
		if item then
			self:SetSelectedItem(item)
		end
	end

	function EHH.Picklist:OnSelectionChanged(previousItem)
		if self.SelectingRecursions and 0 < self.SelectingRecursions then return end
		self.SelectingRecursions = (self.SelectingRecursions or 0) + 1

		local item = self:GetSelectedItemObject()

		if item and item.ClickHandler then
			item.ClickHandler(self, item)
		end

		self:CallHandlers("OnSelectionChanged", item, previousItem)
		self.SelectingRecursions = self.SelectingRecursions - 1
	end

	function EHH.Picklist:Refresh()
		local label = nil
		local item = self:GetSelectedItemObject()

		if item then
			label = item.Label
		end

		self.Control.Label:SetText(label or "")
	end

	function EHH.Picklist:HidePicklist()
		if self.PicklistDialog:IsActiveInstance(self) then
			self.PicklistDialog:Hide()
		end
	end

	function EHH.Picklist:ShowPicklist()
		self.PicklistDialog:Show(self)
	end

	function EHH.Picklist:TogglePicklist()
		if self.PicklistDialog:IsActiveInstance(self) then
			self:CallHandlers("OnHidePicklist")
			self.PicklistDialog:Hide()
		else
			self:CallHandlers("OnShowPicklist")
			self.PicklistDialog:Show(self)
		end
	end
end

---[ List Control ]---

do
	local base = ZO_Object:Subclass()
	EHH.List = base

	local defaults = {}
	base.Defaults = defaults
	defaults.AlphaList = 1
	defaults.ColorBackdrop = Colors.ListBackdrop
	defaults.ColorBox = Colors.ControlBox
	defaults.ColorItemMouseEnter = Colors.ItemMouseEnter
	defaults.ColorItemLabel = Colors.ItemLabel
	defaults.ColorListItemBackdrop = Colors.ListItemBackdrop
	defaults.ColorListItemSelectedBackdrop = Colors.ListItemSelectedBackdrop
	defaults.ColorSliderArrow = Colors.SliderArrow
	defaults.ColorSliderBackdrop = Colors.SliderBackdrop
	defaults.ColorSliderThumb = Colors.SliderThumb
	defaults.DrawLayer = DL_TEXT
	defaults.DrawLevel = 50000
	defaults.DrawTier = DT_HIGH
	defaults.FontItemLabel = "$(BOLD_FONT)|$(KB_16)"
	defaults.Height = 200
	defaults.HeightListMaxRatio = 0.9
	defaults.HeightMax = 1000
	defaults.HeightMin = 40
	defaults.PaddingListHeight = 10
	defaults.PaddingListWidth = 28
	defaults.ScrollInterval = 100
	defaults.ScrollLinesLarge = 10
	defaults.ScrollLinesSmall = 3
	defaults.ScrollRegionInsets = 2
	defaults.SpacingItems = 2
	defaults.VisibleItemsMax = 60
	defaults.VisibleItemsMin = 1
	defaults.Width = 200
	defaults.WidthMax = 1000
	defaults.WidthMin = 80

	local behaviors = {}
	behaviors.HardwareOnly = 1
	behaviors.AlwaysRaise = 2
	base.EventBehaviors = behaviors

	base.CreateTooltip = function(...) return EssentialHousingHub:SetInfoTooltip(...) end
	base.DefaultSortFunction = function(itemA, itemB) return 0 > CompareStringValues(itemA.Label, itemB.Label) end

	function base:New(...)
		local obj = ZO_Object.New(self)
		local list = obj:Initialize(...)
		return list
	end

	function base:Initialize(name, parent, anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY, width, height)
		if not self then
			error(string.format("Failed to create List: Initialization instance is nil."))
			return nil
		end

		if self.Initialized then
			error(string.format("Failed to create List: Instance is already initialized."))
			return nil
		end

		if not parent then
			error(string.format("Failed to create List: Parent is required."))
			return nil
		end

		self.Enabled = true
		self.EventBehavior = self.EventBehaviors.HardwareOnly
		self.Name = name
		self.Parent = parent
		self.ItemLines = 1
		self.Sorted = false
		self.SortFunction = base.DefaultSortFunction
		self.DragAndDropEnabled = false
		self.ItemsDirty = false
		self.Items = {}

		local c

		c = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
		self.Control = c
		c:SetMouseEnabled(false)
		if width and height then
			c:SetDimensions(self.Width, self.Height)
		else
			c:SetResizeToFitDescendents(true)
		end

		c = WINDOW_MANAGER:CreateControl(nil, self.Control, CT_TEXTURE)
		self.Control.Box = c
		c:SetTexture(Textures.Solid)
		c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
		SetColor(c, base.Defaults.ColorBox)
		c:SetAnchor(TOPLEFT, self.Control, TOPLEFT, 0, 0)
		c:SetAnchor(BOTTOMRIGHT, self.Control, BOTTOMRIGHT, 0, 0)

		c = WINDOW_MANAGER:CreateControl(nil, self.Control.Box, CT_TEXTURE)
		self.Control.Backdrop = c
		c:SetTexture(Textures.Solid)
		c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
		SetColor(c, base.Defaults.ColorBackdrop)
		c:SetAnchor(TOPLEFT, self.Control.Box, TOPLEFT, 2, 2)
		c:SetAnchor(BOTTOMRIGHT, self.Control.Box, BOTTOMRIGHT, -2, -2)

		c = WINDOW_MANAGER:CreateControl(nil, self.Control.Backdrop, CT_SCROLL)
		self.Control.ScrollRegion = c
		c:SetMouseEnabled(true)
		c:SetAnchor(TOPLEFT, self.Control.Backdrop, TOPLEFT, 2, base.Defaults.ScrollRegionInsets)
		c:SetAnchor(BOTTOMRIGHT, self.Control.Backdrop, BOTTOMRIGHT, -18, -base.Defaults.ScrollRegionInsets)

		c = WINDOW_MANAGER:CreateControl(nil, self.Control.Backdrop, CT_TEXTURE)
		self.Control.SliderBox = c
		c:SetAnchor(TOPLEFT, self.Control.Backdrop, TOPRIGHT, -17, 21)
		c:SetAnchor(BOTTOMRIGHT, self.Control.Backdrop, BOTTOMRIGHT, -2, -21)
		SetColor(c, base.Defaults.ColorSliderBackdrop)
		c:SetMouseEnabled(false)

		c = WINDOW_MANAGER:CreateControl(nil, self.Control.SliderBox, CT_SLIDER)
		self.Control.Slider = c
		c:SetAllowDraggingFromThumb(true)
		c:SetMouseEnabled(true)
		c:SetValue(0)
		c:SetValueStep(1)
		c:SetOrientation(ORIENTATION_VERTICAL)
		c:SetThumbTexture("EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 15, 64)
		SetColor(c:GetThumbTextureControl(), base.Defaults.ColorSliderThumb)
		c:SetAnchorFill(self.Control.SliderBox)

		self.Control.Slider:SetHandler("OnValueChanged", function(control, value, eventReason)
			self:Refresh(value)
		end)

		self.Control.ScrollRegion:SetHandler("OnMouseWheel", function(control, delta, ctrl, alt, shift)
			local slider = self.Control.Slider
			local value = slider:GetValue()
			if 0 == value then value = 1 end
			slider:SetValue(value - (delta * (shift and base.Defaults.ScrollLinesLarge or base.Defaults.ScrollLinesSmall)))
		end)

		local scrollingUp

		local function Scrolling()
			local value = self.Control.Slider:GetValue()
			if 0 >= value then value = 1 end
			local direction = scrollingUp and -1 or 1
			self.Control.Slider:SetValue(value + direction * (IsShiftKeyDown() and base.Defaults.ScrollLinesLarge or base.Defaults.ScrollLinesSmall))
		end

		local function StopScrolling()
			HUB_EVENT_MANAGER:UnregisterForUpdate("EHH.List.Scrolling")
		end

		local function StartScrolling(isUp)
			scrollingUp = isUp
			Scrolling()

			HUB_EVENT_MANAGER:RegisterForUpdate("EHH.List.Scrolling", base.Defaults.ScrollInterval, Scrolling)
		end

		c = WINDOW_MANAGER:CreateControl(nil, self.Control.Slider, CT_TEXTURE)
		self.Control.SliderUp = c
		c:SetTexture("esoui/art/miscellaneous/gamepad/gp_scrollarrow_up.dds")
		c:SetAnchor(BOTTOM, self.Control.Slider, TOP, 0, -1)
		SetColor(c, base.Defaults.ColorSliderArrow)
		c:SetDimensions(15, 18)
		c:SetMouseEnabled(true)
		c:SetHandler("OnMouseUp", StopScrolling)
		c:SetHandler("OnMouseDown", function() StartScrolling(true) end)

		c = WINDOW_MANAGER:CreateControl(nil, self.Control.Slider, CT_TEXTURE)
		self.Control.SliderDown = c
		c:SetTexture("esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds")
		c:SetAnchor(TOP, self.Control.Slider, BOTTOM, 0, 1)
		SetColor(c, base.Defaults.ColorSliderArrow)
		c:SetDimensions(15, 18)
		c:SetMouseEnabled(true)
		c:SetHandler("OnMouseUp", StopScrolling)
		c:SetHandler("OnMouseDown", function() StartScrolling(false) end)

		c = WINDOW_MANAGER:CreateControl(nil, self.Control.ScrollRegion, CT_CONTROL)
		self.Control.ListBox = c
		c:SetAnchorFill(self.Control.ScrollRegion)
		c:SetMouseEnabled(false)

		self.ListItemBackdrops = {}
		self.ListItems = {}

		for index = 1, base.Defaults.VisibleItemsMax do
			local c = WINDOW_MANAGER:CreateControl(nil, self.Control.ListBox, CT_TEXTURE)
			table.insert(self.ListItemBackdrops, c)
			SetColor(c, base.Defaults.ColorListItemBackdrop)
			c:SetResizeToFitDescendents(true)
			c:SetMouseEnabled(false)
		end

		c = WINDOW_MANAGER:CreateControl(nil, self.Control.ListBox, CT_TEXTURE)
		self.Control.ItemMouseEnter = c
		c:SetHidden(true)
		c:SetTexture(Textures.Solid)
		c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
		SetColor(c, base.Defaults.ColorItemMouseEnter)
		c:SetMouseEnabled(false)

		for index = 1, base.Defaults.VisibleItemsMax do
			local c = WINDOW_MANAGER:CreateControl(nil, self.Control.ListBox, CT_LABEL)
			table.insert(self.ListItems, c)

			SetColor(c, base.Defaults.ColorItemLabel)
			c:SetFont(base.Defaults.FontItemLabel)
			c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			c:SetMaxLineCount(10)
			c:SetText("")
			c:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
			c:SetMouseEnabled(true)
			c:SetHandler("OnMouseEnter", function()
				self:OnItemMouseEnter(c)
				self:OnShowItemTooltip(c)
			end)
			c:SetHandler("OnMouseExit", function()
				self:OnItemMouseExit(c)
				EssentialHousingHub:HideTooltip()
			end)
			c:SetHandler("OnMouseDown", function(c, ...)
				self:OnItemMouseDown(c, ...)
			end)
			c:SetHandler("OnMouseUp", function(c, ...)
				self:OnItemMouseUp(c, ...)
			end)
		end

		self:AnchorListItems()
		self:SetAnchor(anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY)
		self.Initialized = true

		do
			local w = WINDOW_MANAGER:CreateTopLevelWindow()
			self.DragContainer = w
			w:SetDimensions(400, 50)
			w:SetClampedToScreen(true)
			w:SetClampedToScreenInsets(0, 0, 0, 0)
			w:SetMouseEnabled(true)
			w:SetMovable(true)
			w:SetResizeHandleSize(0)
			w:SetHidden(true)
			w:SetDrawLayer(DL_OVERLAY)
			w:SetDrawTier(DT_HIGH)
			w:SetDrawLevel(221001)

			local bo = WINDOW_MANAGER:CreateControl(nil, self.DragContainer, CT_TEXTURE)
			w.Border = bo
			SetColor(bo, FadeColor(base.Defaults.ColorListItemSelectedBackdrop, 1, 0.65))
			bo:SetMouseEnabled(false)
			bo:SetAnchor(TOPLEFT, w, TOPLEFT, 0, 0)
			bo:SetAnchor(BOTTOMRIGHT, w, BOTTOMRIGHT, 0, 0)

			local b = WINDOW_MANAGER:CreateControl(nil, self.DragContainer, CT_TEXTURE)
			w.Backdrop = b
			SetColor(b, FadeColor(base.Defaults.ColorBackdrop, 1, 0.65))
			b:SetMouseEnabled(false)
			b:SetAnchor(TOPLEFT, w, TOPLEFT, 3, 3)
			b:SetAnchor(BOTTOMRIGHT, w, BOTTOMRIGHT, -3, -3)

			local c = WINDOW_MANAGER:CreateControl(nil, b, CT_LABEL)
			w.Label = c
			SetColor(c, base.Defaults.ColorItemLabel)
			c:SetMouseEnabled(false)
			c:SetFont(base.Defaults.FontItemLabel)
			c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			c:SetMaxLineCount(10)
			c:SetText("")
			c:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
			c:SetAnchor(TOPLEFT, b, TOPLEFT, 6, 3)
			c:SetAnchor(BOTTOMRIGHT, b, BOTTOMRIGHT, -6, -3)
		end

		return self
	end

	function base:RefreshList()
		local items = self:GetItems()
		if not items then
			return
		end

		local listItemsVisible = self:GetNumVisibleItems()
		self.Control.ItemMouseEnter:SetHidden(true)
		self.Control.ItemMouseEnter:ClearAnchors()
		self.Control.Slider:SetMinMax(1, math.max(1, 1 + #items - listItemsVisible))
		self.Control.Slider:SetHidden(listItemsVisible >= #items)

		if self:GetSorted() and self:GetItemsDirty() then
			local sorter = self:GetSortFunction()

			if "function" == type(sorter) then
				table.sort(self:GetItems(), sorter)
			end

			self:SetItemsDirty(false)
		end

		self:AnchorListItems()
		self:Refresh()
	end

	function base:Refresh(offset)
		offset = offset or self.Control.Slider:GetValue()

		local backdrops, listItems = self.ListItemBackdrops, self.ListItems
		local items = self:GetItems()
		local itemIndex = offset
		local itemsVisible = self:GetNumVisibleItems()
		local maxItemIndex = math.min(#items, offset + itemsVisible)

		for index = 1, #listItems do
			local backdrop = backdrops[index]
			local listItem = listItems[index]
			local item = items[itemIndex]

			if index <= itemsVisible and item then
				SetColor(backdrop, item.BackdropColor or base.Defaults.ColorListItemBackdrop)
				backdrop:SetHidden(false)

				listItem:SetText(item.Label)
				listItem:SetHidden(false)
				listItem.ItemIndex = itemIndex
				listItem.Item = item
				listItem.ToolTip = item.ToolTip

				itemIndex = itemIndex + 1
				if itemIndex > maxItemIndex then
					itemIndex = -1
				end
			else
				backdrop:SetHidden(true)

				listItem:SetText("")
				listItem:SetHidden(true)
				listItem.ItemIndex = nil
				listItem.Item = nil
				listItem.ToolTip = nil
			end
		end
	end

	function base:GetFontHeight()
		return self.ListItems[1]:GetFontHeight()
	end

	function base:GetItemLabelWidth(index)
		local item = self.ListItems[index]

		if not item then
			return 0
		end

		local text = item:GetText()

		if not text or "" == text then
			return 0
		end

		local newLineIndex = string.find(text, "\n")

		if newLineIndex and 0 < newLineIndex then
			text = string.sub(text, 1, newLineIndex - 1)
		end

		return item:GetStringWidth(text)
	end

	function base:GetItemHeight()
		return self.ItemHeight or 25
	end

	function base:SetItemHeight(value)
		self.ItemHeight = tonumber(value) or 25
		local items = self.ListItems

		for _, item in ipairs(items) do
			item:SetHeight(self.ItemHeight)
		end
	end

	function base:GetScrollRegionInsets()
		return 2 * base.Defaults.ScrollRegionInsets
	end

	function base:GetNumVisibleItems()
		local items = self:GetItems()

		if not items then
			return 0
		end

		local itemHeight = self:GetItemHeight()
		local spacing = self:GetItemSpacing()
		local height = self:GetHeight() - self:GetScrollRegionInsets()
		local count = math.floor(height / (itemHeight + spacing))

		return zo_clamp(count, base.Defaults.VisibleItemsMin, math.min(#items, base.Defaults.VisibleItemsMax)) -- math.min(count, base.Defaults.VisibleItemsMax)
	end

	function base:ScrollTo(index)
		local items = self:GetItems()
		index = zo_clamp(tonumber(index) or 0, 0, items and #items or 0)

		self.Control.Slider:SetValue(index)
		self:Refresh()
	end

	function base:ScrollToTop()
		self:ScrollTo(1)
	end

	function base:OnItemMouseEnter(control)
		if control then
			local item = control.Item
			if item then
				local highlight = self.Control.ItemMouseEnter
				local _, _, anchor = highlight:GetAnchor(1)

				if control ~= anchor then
					highlight:ClearAnchors()
					highlight:SetAnchorFill(control)
					highlight:SetHidden(false)
				end

				if item.MouseEnterHandler then
					item.MouseEnterHandler(item, control.ItemIndex)
				end
			end
		end
	end

	function base:OnItemMouseExit(control)
		if control then
			local item = control.Item
			local highlight = self.Control.ItemMouseEnter
			local _, _, anchor = highlight:GetAnchor(1)

			if control == anchor then
				highlight:SetHidden(true)
				highlight:ClearAnchors()
			end

			if item and item.MouseExitHandler then
				item.MouseExitHandler(item, control.ItemIndex)
			end
		end
	end

	function base:OnItemDragStart()
		HUB_EVENT_MANAGER:UnregisterForUpdate("EHH.List.OnItemDragStart")
		HUB_EVENT_MANAGER:UnregisterForUpdate("EHH.List.OnItemDragUpdate")

		if not self:GetDragAndDropEnabled() then
			self.DragData = nil
			self:DisplayNotification(self:GetDragAndDropDisabledMessage() or "Drag-and-drop is disabled.")
			return
		end

		local dragData = self.DragData
		if not dragData then
			return
		end

		local item, control = dragData.Item, dragData.Control
		local args = dragData.Args and unpack(dragData.Args) or nil
		local mx, my = GetUIMousePosition()
		local dc = self.DragContainer

		dragData.IsDragging = true
		dc.Label:SetText(item.Label)
		dc:ClearAnchors()
		dc:SetAnchor(CENTER, GuiRoot, TOPLEFT, mx, my)
		dc:SetHidden(false)
		dc:StartMoving()

		HUB_EVENT_MANAGER:RegisterForUpdate("EHH.List.OnItemDragUpdate", 100, function() self:OnItemDragUpdate() end)
	end

	function base:OnItemDragUpdate()
		local dragData = self.DragData
		if not dragData then
			return
		end

		local item, control = dragData.Item, dragData.Control
		local mx, my = GetUIMousePosition()
		local _, y1, _, y2 = self.Control.Box:GetScreenRect()
		local offset = self.Control.Slider:GetValue()
		local newOffset

		if my < y1 then
			newOffset = offset - 1
		elseif my > y2 then
			newOffset = offset + 1
		end

		if newOffset then
			newOffset = zo_clamp(newOffset, 1, #self:GetItems())

			if newOffset ~= offset then
				self.Control.Slider:SetValue(newOffset)
			end
		end
	end

	function base:OnItemMouseUp()
		HUB_EVENT_MANAGER:UnregisterForUpdate("EHH.List.OnItemDragStart")
		HUB_EVENT_MANAGER:UnregisterForUpdate("EHH.List.OnItemDragUpdate")

		local dragData = self.DragData
		if not dragData then
			return
		end

		local item, control = dragData.Item, dragData.Control
		local args = dragData.Args and unpack(dragData.Args) or nil

		if item then
			if not dragData.IsDragging then
				if item.ClickHandler then
					item.ClickHandler(item, control.ItemIndex, args)
				elseif item.MouseDownHandler then
					item.MouseDownHandler(item, control.ItemIndex, args)
				end
			else
				local items = self:GetItems()
				local numItems = #items
				local dc = self.DragContainer
				local _, dcy = dc:GetCenter()

				dc:StopMovingOrResizing()
				dc:SetHidden(true)

				local box = self.Control.Box
				local _, by1, _, by2 = box:GetScreenRect()
				local margin = math.floor(self:GetScrollRegionInsets() * 0.5)
				local itemHeight = self:GetItemHeight() + self:GetItemSpacing()
				local baseIndex = self.Control.Slider:GetValue()
				local offset = dcy - (by1 + margin)
				local itemOffset = math.floor(offset / itemHeight)
				local targetIndex = baseIndex + itemOffset
				local sourceIndex = item.Index

				sourceIndex, targetIndex = zo_clamp(sourceIndex, 1, numItems), zo_clamp(targetIndex, 1, numItems)
				self:OnSelectedItemDragAndDrop(sourceIndex, targetIndex)
			end
		end
	end

	function base:OnItemMouseDown(control, ...)
		HUB_EVENT_MANAGER:UnregisterForUpdate("EHH.List.OnItemDragStart")
		HUB_EVENT_MANAGER:UnregisterForUpdate("EHH.List.OnItemDragUpdate")

		if control then
			local dragData = self.DragData
			if not dragData then
				dragData = {}
				self.DragData = dragData
			end

			dragData.IsDragging = false
			dragData.Control = control
			dragData.Item = control.Item
			dragData.StartTime = GetGameTimeMilliseconds()
			dragData.Args = {...}

			HUB_EVENT_MANAGER:RegisterForUpdate("EHH.List.OnItemDragStart", 260, function() self:OnItemDragStart() end)
		end
	end

	function base:OnShowItemTooltip(control)
		local msg = control.ToolTip or control:GetText()

		if control:GetWidth() < control:GetStringWidth(msg) then
			local screenX = GuiRoot:GetCenter()
			local controlX = control:GetCenter()
			local anchorTooltip, anchorControl, anchorOffsetX

			if controlX <= screenX then
				anchorTooltip, anchorControl, anchorOffsetX = LEFT, RIGHT, 25
			else
				anchorTooltip, anchorControl, anchorOffsetX = RIGHT, LEFT, -25
			end

			EssentialHousingHub:SetTooltip(EssentialHousingHub:Trim(control:GetText()), control, anchorTooltip)
			--EssentialHousingHub:ShowTooltip(nil, control, EssentialHousingHub:Trim(msg), anchorTooltip, anchorOffsetX, 0, anchorControl)
		end
	end

	function base:RefreshEnabled()
		self.Control:SetMouseEnabled(self.Enabled)
		SetColor(self.Control.Box, base.Defaults.ColorBox, (not self.Enabled) and base.Defaults.ColorFilterDisabled)
		SetColor(self.Control.Label, base.Defaults.ColorLabel, (not self.Enabled) and base.Defaults.ColorFilterDisabled)
	end

	function base:SetEnabled(value)
		self.Enabled = true == value
		self:RefreshEnabled()
	end

	function base:GetDragAndDropDisabledMessage()
		return self.DragAndDropDisabledMessage
	end

	function base:SetDragAndDropDisabledMessage(value)
		self.DragAndDropDisabledMessage = value
	end

	function base:GetDragAndDropEnabled()
		return true == self.DragAndDropEnabled
	end

	function base:SetDragAndDropEnabled(value)
		self.DragAndDropEnabled = true == value
		self:Refresh()
	end

	function base:GetEventBehavior(value)
		return self.EventBehavior
	end

	function base:SetEventBehavior(value)
		if self:IsTableValue(base.EventBehaviors, value) then
			self.EventBehavior = value
		end
	end

	function base:GetName()
		return self.Name
	end

	function base:GetParent()
		--return self.Parent
		return self.Control:GetParent()
	end

	function base:SetParent(parent)
		--self.Parent = parent
		self.Control:SetParent(parent)
	end

	function base:GetControl()
		return self.Control
	end

	function base:GetDrawLevel()
		return self.Control:GetDrawLevel()
	end

	function base:SetDrawLevel(value)
		self.Control:SetDrawLevel(value)
	end

	function base:GetWidth()
		return self.Control:GetWidth()
	end

	function base:SetWidth(value)
		self.Width = zo_clamp(tonumber(value) or base.Defaults.Width, base.Defaults.WidthMin, base.Defaults.WidthMax)
		self.Control:SetWidth(self.Width)
		return self.Width
	end

	function base:GetHeight()
		return self.Control:GetHeight()
	end

	function base:SetHeight(value)
		self.Height = zo_clamp(tonumber(value) or base.Defaults.Height, base.Defaults.HeightMin, base.Defaults.HeightMax)
		self.Control:SetHeight(self.Height)
		return self.Height
	end

	function base:GetDimensions()
		return self.Control:GetDimensions()
	end

	function base:SetDimensions(width, height)
		self:SetWidth(width)
		self:SetHeight(height)
	end

	function base:GetCenter()
		return self.Control:GetCenter()
	end

	function base:GetScreenRect()
		return self.Control:GetScreenRect()
	end

	function base:SetItemHorizontalAlignment(value)
		for _, item in ipairs(self.ListItems) do
			item:SetHorizontalAlignment(value)
		end
	end

	function base:SetItemVerticalAlignment(value)
		for _, item in ipairs(self.ListItems) do
			item:SetVerticalAlignment(value)
		end
	end

	function base:SetItemFont(value)
		for _, item in ipairs(self.ListItems) do
			item:SetFont(value)
		end
	end

	function base:GetItemSpacing()
		return self.ItemSpacing or base.Defaults.SpacingItems
	end

	function base:SetItemSpacing(value)
		local spacing = tonumber(value) or self.ItemSpacing or base.Defaults.SpacingItems
		self.ItemSpacing = spacing
		self:AnchorListItems()
	end

	function base:AnchorListItems()
		local backdrops, items = self.ListItemBackdrops, self.ListItems
		local spacing = self:GetItemSpacing()
		local previousItem
		local maxIndex = #items

		for index = 1, maxIndex do
			local backdrop, item = backdrops[index], items[index]

			backdrop:ClearAnchors()
			item:ClearAnchors()

			if not previousItem then
				item:SetAnchor(TOPLEFT, self.Control.ListBox, TOPLEFT, 1, 0)
				item:SetAnchor(TOPRIGHT, self.Control.ListBox, TOPRIGHT, -1, 0)
			else
				item:SetAnchor(TOPLEFT, previousItem, BOTTOMLEFT, 0, spacing)
				item:SetAnchor(TOPRIGHT, previousItem, BOTTOMRIGHT, 0, spacing)
			end

			backdrop:SetAnchor(TOPLEFT, item, TOPLEFT, 0, 0)
			backdrop:SetAnchor(BOTTOMRIGHT, item, BOTTOMRIGHT, 0, 0)

			previousItem = item
		end
	end

	function base:GetItemLines()
		return self.ItemLines or 1
	end

	function base:SetItemLines(value)
		value = zo_clamp(tonumber(value) or 1, 1, 10)
		self.ItemLines = value

		local lineHeight = value * self:GetFontHeight()
		local items = self.ListItems

		for index = 1, #items do
			local item = items[index]
			item:SetMaxLineCount(value)
			item:SetHeight(lineHeight)
		end

		self:Refresh()
	end

	function base:GetItemsDirty()
		return self.ItemsDirty
	end

	function base:SetItemsDirty(value)
		self.ItemsDirty = true == value
	end

	function base:GetSorted()
		return self.Sorted
	end

	function base:SetSorted(value)
		self.Sorted = true == value
		self.ItemsDirty = true
	end

	function base:GetSortFunction()
		return self.SortFunction
	end

	function base:SetSortFunction(func)
		self.ItemsDirty = true
		self.SortFunction = "function" == type(func) and func or nil

		if self.SortFunction then
			self.Sorted = true
		else
			self.SortFunction = base.DefaultSortFunction
		end
	end

	function base:GetHandlers(event)
		if not event then
			return nil
		end

		event = string.lower(event)

		if not self.Handlers then
			self.Handlers = {}
		end

		local handlers = self.Handlers[event]

		if not handlers then
			handlers = {}
			self.Handlers[event] = handlers
		end

		return handlers
	end

	function base:AddHandler(event, handler)
		local handlers = self:GetHandlers(event)

		if handlers then
			handlers[handler] = true
			return handler
		end

		return nil
	end

	function base:RemoveHandler(event, handler)
		local handlers = self:GetHandlers(event)

		if handlers and handlers[handler] then
			handlers[handler] = nil
			return handler
		end

		return nil
	end

	function base:CallHandlers(event, ...)
		local handlers = self:GetHandlers(event)

		if handlers then
			for handler in pairs(handlers) do
				handler(self, ...)
			end
		end
	end

	function base:IsHidden()
		return self.Control:IsHidden()
	end

	function base:SetHidden(value)
		self.Control:SetHidden(value)
	end

	function base:ClearAnchors()
		self.Control:ClearAnchors()
		self:OnResized()
	end

	function base:SetAnchor(anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY)
		if anchorFrom or anchor or anchorTo then
			self.Control:SetAnchor(anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY)
		end
	end

	function base:GetItems()
		return self.Items
	end

	function base:GetItemByIndex(index)
		return self.Items[index]
	end

	function base:FindItemIndex(item)
		local matchedIndex = nil

		if "number" == type(item) then
			for index, itemObj in ipairs(self.Items) do
				if item == itemObj.Value then
					matchedIndex = index
					break
				end
			end
		elseif "string" == type(item) then
			local lowerValue = string.lower(EssentialHousingHub:Trim(item))

			for index, itemObj in ipairs(self.Items) do
				if lowerValue == string.lower(EssentialHousingHub:Trim(itemObj.Label)) then
					matchedIndex = index
					break
				end
			end
		elseif "table" == type(item) then
			for index, itemObj in ipairs(self.Items) do
				if item.Label == itemObj.Label and item.Value == itemObj.Value then
					matchedIndex = index
					break
				end
			end
		end

		return matchedIndex
	end

	function base:FindItem(item)
		return self.Items[self:FindItemIndex(item)]
	end

	function base:ClearItems()
		if not self.Items then
			self.Items = {}
		else
			for index = #self.Items, 1, -1 do
				table.remove(self.Items, index)
			end
		end

		self.SelectedItem = nil
		self.ItemsDirty = true
		self:Refresh()
	end

	function base:SetItems(items)
		if "table" == type(items) then
			self.Items = items
		else
			self:ClearItems()
		end

		self.ItemsDirty = true
		return self:GetItems()
	end

	function base:AddItem(label, value, clickHandler, mouseEnterHandler, mouseExitHandler)
		local item = nil
		if label then
			item = { Label = label, Value = value, ClickHandler = clickHandler, MouseEnterHandler = mouseEnterHandler, MouseExitHandler = mouseExitHandler }
			table.insert(self.Items, item)
		end

		self.ItemsDirty = true
		return item
	end

	function base:InsertItem(index, label, value, clickHandler, mouseEnterHandler, mouseExitHandler)
		local item = nil
		if label then
			item = { Label = label, Value = value, ClickHandler = clickHandler, MouseEnterHandler = mouseEnterHandler, MouseExitHandler = mouseExitHandler }
			table.insert(self.Items, index, item)
		end

		self.ItemsDirty = true
		return item
	end
end

---[ User Interface Macros ]---

local function tip(control, msg, anchorFrom, offsetX, offsetY, anchorTo)
	--EHH:SetInfoTooltip(control, msg, anchorFrom or TOPLEFT, offsetX or 10, offsetY or 0, anchorTo or TOPRIGHT)
	EHH:SetTooltip(msg, control, anchorFrom, offsetX, offsetY)
end

local function SetFormButtonEnabled(control, enabled)
	if enabled then
		control.r1, control.g1, control.b1, control.a1 = nil, nil, nil, nil
		control.r2, control.g2, control.b2, control.a2 = nil, nil, nil, nil
	else
		control.r1, control.g1, control.b1, control.a1 = 0.3, 0.3, 0.3, 1
		control.r2, control.g2, control.b2, control.a2 = 0.2, 0.2, 0.2, 0.5
	end
end

local function OnFormButtonMouseEnter(control)
	local r1, g1, b1, a1 = control.r1 or 0, control.g1 or 0.7, control.b1 or 0.7, control.a1 or 1
	local r2, g2, b2, a2 = control.r2 or 0, control.g2 or 0.5, control.b2 or 0.5, control.a2 or 0.5
	control:SetVertexColors(1 + 2, r1, g1, b1, a1)
	control:SetVertexColors(4 + 8, r2, g2, b2, a2)
	WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_UI_HAND)
end

local function OnFormButtonMouseExit(control)
	local r1, g1, b1, a1 = control.r1 or 0, control.g1 or 0.5, control.b1 or 0.5, control.a1 or 1
	local r2, g2, b2, a2 = control.r2 or 0, control.g2 or 0.5, control.b2 or 0.5, control.a2 or 0.5
	control:SetVertexColors(1 + 2, r1, g1, b1, a1)
	control:SetVertexColors(4 + 8, r2, g2, b2, a2)
	WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
end

local function OnFormTabButtonMouseEnter(control)
	if 50 <= control:GetHeight() then
		control:SetVertexColors(1 + 2, 0, 0.9, 0.9, 1)
		control:SetVertexColors(4, 0, 0.5, 0.5, 0.5)
		control:SetVertexColors(8, 0, 0.25, 0.25, 0.5)
	else
		control:SetVertexColors(1 + 2, 0, 0.7, 0.7, 1)
		control:SetVertexColors(4, 0, 0.5, 0.5, 0.5)
		control:SetVertexColors(8, 0, 0.25, 0.25, 0.5)
	end
	WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_UI_HAND)
end

local function OnFormTabButtonMouseExit(control)
	if 50 <= control:GetHeight() then
		control:SetVertexColors(1 + 2, 0, 0.7, 0.7, 1)
		control:SetVertexColors(4, 0, 0.5, 0.5, 0.5)
		control:SetVertexColors(8, 0, 0.25, 0.25, 0.5)
	else
		control:SetVertexColors(1 + 2, 0, 0.5, 0.5, 1)
		control:SetVertexColors(4, 0, 0.5, 0.5, 0.5)
		control:SetVertexColors(8, 0, 0.25, 0.25, 0.5)
	end
	WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
end

local function OnFormRowMouseEnter(control)
	control.Background:SetColor(0, 0, 0, 0.3)
end

local function OnFormRowMouseExit(control)
	control.Background:SetColor(0, 0, 0, 0.3)
end

local function OnHubShortcutMouseEnter(control)
	control:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1.8)
end

local function OnHubShortcutMouseExit(control)
	control:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1)
end

local function OnHubEntryDescriptionMouseDown(self, control, button, upInside, ctrl, alt, shift, command)
	local furnitureLink = control.FurnitureLink
	local parentControl = control:GetParent()
	local iterations = 0
	while (not furnitureLink or "" == furnitureLink) and parentControl and iterations < 10 do
		if parentControl.Data then
			furnitureLink = parentControl.Data.FurnitureLink
		end
		parentControl = parentControl:GetParent()
		iterations = iterations + 1
	end

	if "" == furnitureLink then
		furnitureLink = nil
	end

	if control.HouseId then
		local house = self:GetHouseById(control.HouseId)
		if house then
			if self:IsInOwnedHouse(house.Id) then
				self:DisplayNotification(string.format("You are already here in %s", house.Name or "this home"))
				return
			end

			local message = string.format("Jumping to your %s%s", house.Name, furnitureLink and string.format(" for %s", furnitureLink) or "")
			self:ShowChatMessage(message)
			self:DisplayNotification(message)
			self:HideHousingHub()

			local metaData =
			{
				houseName = house.Name,
				furnitureLink = furnitureLink,
			}

			local function OnSuccess(houseId, owner, metaData)
				if houseId == house.Id and metaData and metaData.furnitureLink then
					local message = string.format("Arrived at %s for %s", metaData.houseName or "your home", metaData.furnitureLink or "the item(s)")
					self:ShowChatMessage(message)
					self:DisplayNotification(message)
				end
			end

			local CURRENT_PLAYER = nil
			local SUPPRESS_NOTIFICATION = true
			local INSIDE_ENTRANCE = false
			self:JumpToHouse(house.Id, CURRENT_PLAYER, "hub", SUPPRESS_NOTIFICATION, INSIDE_ENTRANCE, metaData, OnSuccess)

			return
		end
	end

	self:ShowHubTileFurnitureLink(furnitureLink)
end

---[ Scenes ]---

function EHH:GetCurrentSceneName()
	local scene = SCENE_MANAGER:GetCurrentScene()
	if scene then return scene:GetName() end
	return ""
end

function EHH:IsHUDSceneShowing()
	local sceneName = self:GetCurrentSceneName()
	return "hud" == sceneName or "hudui" == sceneName
end

---[ Email ]---

function EHH:ShowNewEmail(to, subject, attachGold)
	SCENE_MANAGER:Show("mailSend")

	zo_callLater(function()
		ZO_MailSendToField:SetText(to)

		if subject then
			ZO_MailSendSubjectField:SetText(subject)
		else
			ZO_MailSendSubjectField:SetText("")
		end

		if attachGold then
			QueueMoneyAttachment(attachGold)
		end

		ZO_MailSendBodyField:TakeFocus()
	end, 500)
end

---[ Jumping ]---

function EHH:JumpToHome()
	return EHH:SlashCommandHome()
end

function EHH:JumpToFavoriteHouse(index)
	return EHH:SlashCommandHouse(tostring(index))
end

---[ House Population  ]---

function EHH:ShowHousePopulationChanged(population)
	local previousPopulation = EHH.CurrentHousePopulation or 0
	EHH.CurrentHousePopulation = population

	if 0 == population then
		return
	end

	self:UpdateCurrentHouseStats()
end

---[ Sounds ]---

function EHH:PlaySoundThrottled(sound, durationMS)
	if nil == durationMS then
		durationMS = 450
	end

	local currentTimeMS = GetFrameTimeMilliseconds()
	if currentTimeMS < self.NextSoundEffectMS then
		return false
	end

	self.NextSoundEffectMS = currentTimeMS + durationMS
	PlaySound(sound)

	return true
end

function EHH:PlaySoundFailure()
	return self:PlaySoundThrottled(SOUNDS.GENERAL_ALERT_ERROR)
end

function EHH:PlaySoundConfirm()
	return self:PlaySoundThrottled(SOUNDS.POSITIVE_CLICK)
end

function EHH:PlaySoundEffectAdded()
	return self:PlaySoundThrottled(SOUNDS.CROWN_CRATES_DEAL_PRIMARY)
end

function EHH:PlaySoundEffectChanged()
	return PlaySound(SOUNDS.DYEING_TOOL_SET_FILL_USED)
end

function EHH:PlaySoundEffectCloned()
	return self:PlaySoundThrottled(SOUNDS.CROWN_CRATES_CARDS_LEAVE)
end

function EHH:PlaySoundEffectEndEdit()
	return self:PlaySoundThrottled(SOUNDS.TABLET_CLOSE)
end

function EHH:PlaySoundEffectRemoved()
	return self:PlaySoundThrottled(SOUNDS.HUD_ARMOR_BROKEN)
end

function EHH:PlaySoundEffectStartEdit()
	return self:PlaySoundThrottled(SOUNDS.TABLET_OPEN)
end

---[ Controls ]---

function EHH:GetOpenHouseCategoryListItems()
	if not self.OpenHouseCategoryListItems then
		local items = {}
		self.OpenHouseCategoryListItems = items

		local categories, categoryVersion = self:GetOpenHouseCategories()
		if "table" == type(categories) then
			for categoryIndex, categoryName in pairs(categories) do
				local categoryIndexNumber = tonumber(categoryIndex)
				if categoryIndexNumber then
					local categoryId = categoryVersion + (categoryIndexNumber * 0.001)
					local item =
					{
						Label = categoryName,
						Value = categoryId,
					}
					table.insert(items, item)
				end
			end

			table.sort(items, function(left, right) return string.lower(left.Label) < string.lower(right.Label) end)
		end
	end

	return self.OpenHouseCategoryListItems
end

function EHH:RefreshOpenHouseCategoryList()
	if false == self.openHouseCategoriesDirty then
		return
	end

	local ui = self:GetDialog("HousingHub")
	local categoryFilter = ui and ui.CategoryFilter or nil
	if not ui or not categoryFilter then
		return
	end

	local categories = self:CloneTable(self:GetOpenHouseCategoryListItems())
	local numHousesPerCategory = self:GetNumOpenHousesPerCategory()
	if numHousesPerCategory then
		for index, category in ipairs(categories) do
			local numHouses = numHousesPerCategory[category.Value]
			if numHouses then
				category.Label = string.format("%s (|c44bbff%d houses|r)", category.Label, numHouses)
			end
		end
	end
	table.insert(categories, 1, {Label = "- All Categories -", Value = 0})

	categoryFilter:SetItems(categories)
end

function EHH:GetNumOpenHousesPerCategory()
	return self.numOpenHousesPerCategory
end

function EHH:SetNumOpenHousesPerCategory(numHouses)
	self.openHouseCategoriesDirty = true
	self.numOpenHousesPerCategory = numHouses
	self:RefreshOpenHouseCategoryList()
end

function EHH:IsMouseOverControl(control)
	local iterations = 0
	local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()

	while mouseOverControl and iterations < 100 do
		if mouseOverControl == control then
			return true
		end

		if mouseOverControl:GetOwningWindow() == control then
			return true
		end

		mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
		iterations = iterations + 1
	end

	return false
end

function EHH:ShowHelp(helpKey)
	return self:ShowURL(self.Defs.Urls[helpKey])
end

function EHH:SetTooltip(messageOrFunction, control, anchorPoint, offsetX, offsetY)
	return HOUSING_HUB_TOOLTIP:Show(messageOrFunction, control, anchorPoint, offsetX, offsetY)
end

function EHH:ClearTooltip()
	HOUSING_HUB_TOOLTIP:Clear()
end

function EHH:ShowTooltip(tooltip, control, message, tooltipAnchor, offsetX, offsetY, controlAnchor)
	if nil == control then return end
	if nil == tooltip then tooltip = InformationTooltip end

	if nil == tooltipAnchor and nil == controlAnchor then
		local centerX, centerY = GuiRoot:GetCenter()
		local controlX, controlY = control:GetCenter()

		if controlX >= centerX then
			tooltipAnchor, controlAnchor, offsetX = RIGHT, LEFT, -30
		else
			tooltipAnchor, controlAnchor, offsetX = LEFT, RIGHT, 30
		end

		if 300 < math.abs(centerY - controlY) then
			if controlY >= centerY then
				if tooltipAnchor == RIGHT then
					tooltipAnchor, controlAnchor, offsetY = BOTTOMRIGHT, TOPLEFT, -30
				else
					tooltipAnchor, controlAnchor, offsetY = BOTTOMLEFT, TOPRIGHT, -30
				end
			else
				if tooltipAnchor == RIGHT then
					tooltipAnchor, controlAnchor, offsetY = TOPRIGHT, BOTTOMLEFT, 30
				else
					tooltipAnchor, controlAnchor, offsetY = TOPLEFT, BOTTOMRIGHT, 30
				end
			end
		end
	else
		if nil == tooltipAnchor then tooltipAnchor = RIGHT end
		if nil == controlAnchor then controlAnchor = LEFT end
		if nil == offsetX then offsetX = -5 end
		if nil == offsetY then offsetY = 0 end
	end

	self.ActiveTooltipControls[tooltip] = control
	InitializeTooltip(tooltip, control, tooltipAnchor, offsetX, offsetY, controlAnchor)
	tooltip:AddLine(message, "", 1, 1, 1, 1)
end

function EHH:ShowControlTooltip(tooltip, control, tooltipAnchor, offsetX, offsetY, controlAnchor, relativeControl)
	local message

	if control then
		if "function" == type(control.InfoTooltipMessage) then
			message = control.InfoTooltipMessage(control)
		else
			message = control.InfoTooltipMessage
		end
	end

	if message then
		self:SetTooltip(message, control, tooltipAnchor, offsetX, offsetY)
		--self:ShowTooltip(tooltip, relativeControl or control, message, tooltipAnchor, offsetX, offsetY, controlAnchor)
	end
end

function EHH:HideTooltip(tooltip)
	if nil == tooltip then
		tooltip = InformationTooltip
	end

	ClearTooltip(tooltip)
	self:ClearTooltip()
--[[
	if nil == tooltip then
		tooltip = InformationTooltip
	end

	self.ActiveTooltipControls[tooltip] = nil
	ClearTooltip(tooltip)
]]
end

function EHH:SetInfoTooltip(control, message, tooltipAnchor, offsetX, offsetY, controlAnchor, relativeControl, showImmediately)
	if nil == control or nil == message or ("string" == type(message) and "" == message) then
		return
	end

	if nil ~= control.InfoTooltipMessage then
		control.InfoTooltipMessage = message
	else
		control.InfoTooltipMessage = message

		control:SetHandler("OnMouseEnter", function(...)
			self:ShowControlTooltip(InformationTooltip, control, tooltipAnchor, offsetX, offsetY, controlAnchor, relativeControl)
		end, "EHHTooltip")

		control:SetHandler("OnMouseExit", function(...)
			self:HideTooltip(InformationTooltip)
		end, "EHHTooltip")
	end

	if control.Backdrop then
		self:SetInfoTooltip(control.Backdrop, message, BOTTOMRIGHT, offsetX, offsetY, TOPLEFT)
	end

	if control.Label then
		self:SetInfoTooltip(control.Label, message, BOTTOMRIGHT, offsetX, offsetY, TOPLEFT)
	end

	if control.Value then
		self:SetInfoTooltip(control.Value, message, BOTTOMLEFT, offsetX, offsetY, TOPRIGHT)
	end

	if control.MinLabel then
		self:SetInfoTooltip(control.MinLabel, message, BOTTOMRIGHT, offsetX, offsetY, TOPLEFT)
	end

	if control.MaxLabel then
		self:SetInfoTooltip(control.MaxLabel, message, BOTTOMLEFT, offsetX, offsetY, TOPRIGHT)
	end

	if control.UnitsLabel then
		self:SetInfoTooltip(control.UnitsLabel, message, BOTTOMLEFT, offsetX, offsetY, TOPRIGHT)
	end

	for tooltipControl, targetControl in pairs(self.ActiveTooltipControls) do
		if targetControl == control then
			self:ShowControlTooltip(tooltipControl, control, tooltipAnchor, offsetX, offsetY, controlAnchor)
			break
		end
	end
	
	if showImmediately then
		self:ShowControlTooltip(InformationTooltip, control, tooltipAnchor, offsetX, offsetY, controlAnchor, relativeControl)
	end
end

function EHH:ClearInfoTooltip(control)
	if nil == control then return end

	if nil ~= control.InfoTooltipMessage then
		control.InfoTooltipMessage = nil
		control:SetHandler("OnMouseEnter", nil, "EHHTooltip")
		control:SetHandler("OnMouseExit", nil, "EHHTooltip")
	end

	for tooltipControl, targetControl in pairs(self.ActiveTooltipControls) do
		if targetControl == control then
			EssentialHousingHub:HideTooltip(tooltipControl)
			break
		end
	end
end

function EHH:CreateHeading(controlName, parentControl, text)
	local control = WINDOW_MANAGER:CreateControl(controlName, parentControl, CT_LABEL)

	control:SetFont(Colors.LabelHeadingFont)
	control:SetColor(1.0, 1.0, 0.5, 1)
	control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	control:SetVerticalAlignment(TEXT_ALIGN_TOP)
	control:SetText(text)

	return control
end

function EHH:CreateButton(controlName, parentControl, text, anchors, clickHandler)
	local control = WINDOW_MANAGER:CreateControl(controlName, parentControl, CT_BUTTON)

	control:SetClickSound("Click")
	control:SetFont(Colors.LabelFontBold)
	control:SetNormalFontColor(0, 0.9, 1, 1)
	control:SetMouseOverFontColor(0.5, 0.9, 1, 1)
	control:SetDisabledFontColor(0.4, 0.4, 0.4, 1)
	control:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	if nil ~= text then control:SetText(text) end
	control:SetDimensions(self.Defs.Controls.Buttons.HorizontalMargin + control:GetLabelControl():GetTextWidth(), self.Defs.Controls.Buttons.Height)
	if nil ~= clickHandler then control:SetHandler("OnClicked", clickHandler) end
	if nil ~= anchors and 0 < #anchors then
		for index, anchor in ipairs(anchors) do control:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5]) end
	end

	return control
end

function EHH:CreateTextureButton(controlName, parentControl, texture, width, height, anchors, clickHandler)
	local control = WINDOW_MANAGER:CreateControl(controlName, parentControl, CT_BUTTON)

	control:SetClickSound("Click")
	control:SetText("")
	control:SetNormalTexture(texture)
	if width then control:SetWidth(width) end
	if height then control:SetHeight(height) end
	if nil ~= clickHandler then control:SetHandler("OnClicked", clickHandler) end
	if nil ~= anchors and 0 < #anchors then
		for index, anchor in ipairs(anchors) do control:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5]) end
	end

	return control
end

do
	local function OnMouseEnter(control)
		control.Backdrop:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 2)
	end

	local function OnMouseExit(control)
		control.Backdrop:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1)
	end

	function EHH:CreateTabButton(controlName, parentControl, text, width, height, anchors, clickHandler)
		local control = WINDOW_MANAGER:CreateControl(controlName, parentControl, CT_CONTROL)

		if nil ~= anchors and 0 < #anchors then
			for index, anchor in ipairs(anchors) do
				control:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
			end
		end

		control:SetResizeToFitDescendents(true)
		control:SetMouseEnabled(true)
		control.Backdrop = CreateTexture(controlName .. "Backdrop", control, CreateAnchor(CENTER, control, CENTER, 0, 0), nil, 60, 22)
		SetColor(control.Backdrop, Colors.TabBackdrop)
		control.Button = CreateButtonLabel(controlName .. "Button", control.Backdrop, text, CreateAnchor(CENTER, control.Backdrop, CENTER, 0, 0))
		control:SetHandler("OnMouseDown", clickHandler)
		control:SetHandler("OnMouseEnter", OnMouseEnter)
		control:SetHandler("OnMouseExit", OnMouseExit)

		return control
	end
end

function EHH:CreateSlider(controlName, controlLabel, unitsLabel, parentControl, valueChangedFunc, minValue, maxValue, valueStep, precision, allowDefault, tabFunc)
	local currentValue = minValue
	if nil == currentValue then currentValue = 0 end

	local slider = WINDOW_MANAGER:CreateControl(controlName, parentControl, CT_SLIDER)
	slider.LabelText = controlLabel
	slider.Precision = precision or 0
	slider.ValueChangedFunc = valueChangedFunc
	slider.IsParam = true

	slider:SetHeight(15)
	slider:SetOrientation(ORIENTATION_HORIZONTAL)
	slider:SetMinMax(minValue, maxValue)
	slider:SetValueStep(valueStep)
	slider:SetThumbTexture("EsoUI/Art/Miscellaneous/scrollbox_elevator.dds", "EsoUI/Art/Miscellaneous/scrollbox_elevator_disabled.dds", nil, 8, 16)
	slider:SetAllowDraggingFromThumb(true)
	slider:SetMouseEnabled(true)
	slider:SetBackgroundMiddleTexture("EsoUI/Art/ChatWindow/chat_scrollbar_track.dds")
	slider.PreviousValue = nil
	slider:SetValue(currentValue)

	slider:SetHandler("OnValueChanged", function(self, value, eventReason)

		if nil == value then value = 0 end

		local precision = slider.Precision
		if nil == precision then precision = 0 end

		if eventReason == EVENT_REASON_HARDWARE then

			local hardwarePrecision = 1
			local _, sliderMax = slider:GetMinMax()
			local sliderWidth = slider:GetWidth()

			if sliderWidth >= (sliderMax * 10) then hardwarePrecision = 0.1
			elseif sliderWidth >= (sliderMax * 4) then hardwarePrecision = 0.25
			elseif sliderWidth >= (sliderMax * 2) then hardwarePrecision = 0.5 end

			zo_callLater(function() if value == slider:GetValue() then slider:SetValue(zo_roundToNearest(value, hardwarePrecision)) end end, 10)

		else
			value = zo_roundToNearest(value, 1 / math.pow(10, precision))
		end

		local curValue = slider.Value:GetText()
		slider.Value:SetText(string.format("%." .. tostring(precision) .. "f", value))

		if "" ~= curValue then
			curValue = tonumber(curValue)
			if nil ~= curValue and 0 > curValue then
				if slider.UnitsLabel and "degrees" == slider.UnitsLabel:GetText() then
					local textValue = (-360 + value)
					slider.Value:SetText(string.format("%." .. tostring(precision) .. "f", textValue))
				end
			end
		end

		if not EHH.SuppressSliderFunctions then
			if slider.ValueChangedFunc then slider.ValueChangedFunc(slider, value) end
		end

	end)

	slider.Backdrop = WINDOW_MANAGER:CreateControl(nil, slider, CT_BACKDROP)
	slider.Backdrop:SetCenterColor(0, 0, 0)
	slider.Backdrop:SetAnchor(TOPLEFT, slider, TOPLEFT, 0, 4)
	slider.Backdrop:SetAnchor(BOTTOMRIGHT, slider, BOTTOMRIGHT, 0, -4)
	slider.Backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 32, 4)
	slider.Backdrop:SetMouseEnabled(false)

	slider.RowBackdrop = WINDOW_MANAGER:CreateControl(nil, slider, CT_BACKDROP)
	slider.RowBackdrop:SetAnchor(TOPLEFT, slider, TOPLEFT, -5, -26)
	slider.RowBackdrop:SetAnchor(BOTTOMRIGHT, slider, BOTTOMRIGHT, 5, 3)
	slider.RowBackdrop:SetMouseEnabled(false)

	slider.MinLabel = WINDOW_MANAGER:CreateControl(nil, slider, CT_LABEL)
	slider.MinLabel:SetFont("ZoFontGameSmall")
	slider.MinLabel:SetAnchor(LEFT, slider, LEFT, 1, -14)
	slider.MinLabel:SetText(tostring(minValue))
	slider.MinLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	slider.MinLabel:SetMouseEnabled(true)

	slider.MaxLabel = WINDOW_MANAGER:CreateControl(nil, slider, CT_LABEL)
	slider.MaxLabel:SetFont("ZoFontGameSmall")
	slider.MaxLabel:SetAnchor(RIGHT, slider, RIGHT, -1, -14)
	slider.MaxLabel:SetText(tostring(maxValue))
	slider.MaxLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	slider.MaxLabel:SetMouseEnabled(true)

	slider.Label = WINDOW_MANAGER:CreateControl(nil, slider, CT_LABEL)
	slider.Label:SetFont("ZoFontWinH5")
	slider.Label:SetAnchor(BOTTOMLEFT, slider, TOPLEFT, 10, 0)
	slider.Label:SetAnchor(BOTTOMRIGHT, slider, TOP, -5, 0)
	slider.Label:SetText(slider.LabelText)
	slider.Label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	slider.Label:SetWidth(150)
	slider.Label:SetMouseEnabled(true)

	slider.ValueBackdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, slider, "ZO_EditBackdrop")
	slider.ValueBackdrop:SetAnchor(LEFT, slider.Label, RIGHT, 10, -2)
	slider.ValueBackdrop:SetDimensions(55, 20)

	slider.Value = WINDOW_MANAGER:CreateControlFromVirtual(nil, slider.ValueBackdrop, "ZO_DefaultEditForBackdrop") 
	slider.Value:SetFont("$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin")
	slider.Value:SetAnchor(TOPLEFT, slider.ValueBackdrop, TOPLEFT, 4, 0)
	slider.Value:SetAnchor(BOTTOMRIGHT, slider.ValueBackdrop, BOTTOMRIGHT, -4, 0)
	slider.Value:SetMaxInputChars(7)
	slider.Value.PreviousValue = nil
	slider.Value:SetHandler("OnFocusLost", function()

		local text = slider.Value:GetText()

		if "" ~= text and slider.DefaultCheckbox then
			ZO_CheckButton_SetCheckState(slider.DefaultCheckbox, false)
		else

			local value = tonumber(text) or 0

			if 0 > value then
				if slider.UnitsLabel and "degrees" == slider.UnitsLabel:GetText() then
					value = (360 + value) % 360
				end
			end

			slider:SetValue(value)

		end

	end)
	slider.Value:SetHandler("OnEnter", function(self) self:LoseFocus() end)
	if nil ~= tabFunc then slider.Value:SetHandler("OnTab", function() tabFunc(slider) end) end

	slider.Value:SetText(string.format("%." .. tostring(slider.Precision) .. "f", currentValue))

	if nil ~= unitsLabel and "" ~= unitsLabel then
		slider.UnitsLabel = WINDOW_MANAGER:CreateControl(nil, slider, CT_LABEL)
		slider.UnitsLabel:SetFont("$(MEDIUM_FONT)|$(KB_14)|soft-shadow-thin")
		slider.UnitsLabel:SetAnchor(LEFT, slider.ValueBackdrop, RIGHT, 8, 2)
		slider.UnitsLabel:SetText(unitsLabel)
		slider.UnitsLabel:SetMouseEnabled(true)
	end

	if allowDefault then
		slider.DefaultCheckbox = WINDOW_MANAGER:CreateControlFromVirtual(controlName .. "_DefaultCheckbox", slider, "ZO_CheckButton")
		slider.DefaultCheckbox:SetAnchor(BOTTOMRIGHT, slider, TOPRIGHT, -36, -2)
		ZO_CheckButton_SetLabelText(slider.DefaultCheckbox, "Default")
		slider.DefaultCheckbox.label:ClearAnchors()
		slider.DefaultCheckbox.label:SetAnchor(RIGHT, slider.DefaultCheckbox, LEFT, -5, 1)
		slider.DefaultCheckbox.label:SetFont("ZoFontGameSmall")

		ZO_CheckButton_SetCheckState(slider.DefaultCheckbox, false)
		ZO_CheckButton_SetToggleFunction(slider.DefaultCheckbox, function()
			if ZO_CheckButton_IsChecked(slider.DefaultCheckbox) then
				slider.Value:SetText("")
			end
		end)
	end

	return slider
end

function EHH:AdjustSlider(window, buffer, slider)
	local numHistoryLines = buffer:GetNumHistoryLines()
	local numVisHistoryLines = buffer:GetNumVisibleLines()
	local bufferScrollPos = buffer:GetScrollPosition()
	local sliderMin, sliderMax = slider:GetMinMax()
	local sliderValue = slider:GetValue()
	
	slider:SetMinMax(0, numHistoryLines)
	
	if sliderValue == sliderMax then
		slider:SetValue(numHistoryLines)
	elseif numHistoryLines == buffer:GetMaxHistoryLines() then
		slider:SetValue(sliderValue - 1)
	end

	if numHistoryLines > numVisHistoryLines then
		slider:SetHidden(false)
	else
		slider:SetHidden(true)
	end
end

function EHH:AddBufferText(window, buffer, slider, message)
	if nil == window or nil == buffer or nil == slider or nil == message then return end
	buffer:AddMessage(message, 1, 1, 1)
	self:AdjustSlider(window, buffer, slider)
end

function EHH:CreateComboBoxEntry(comboBox, label, value, callback)
	local item = comboBox:CreateItemEntry(label, callback)
	item.Value = value
	comboBox:AddItem(item)
end

function EHH:GetSelectedComboBoxEntry(comboBox)
	local item = comboBox:GetSelectedItemData()
	return item
end

function EHH:GetSelectedComboBoxValue(comboBox)
	local value, item = nil, self:GetSelectedComboBoxEntry(comboBox)
	if nil ~= item then value = item.Value end
	return value
end

function EHH:SelectComboBoxValue(comboBox, value)
	for index, item in ipairs(comboBox:GetItems()) do
		if value == item.Value then
			comboBox:SelectItemByIndex(index)
			break
		end
	end
end

---[ Modal Dialogs ]---

function EHH:EnterUIMode(delay)
	zo_callLater(function() if not IsGameCameraUIModeActive() then ZO_SceneManager_ToggleHUDUIBinding() end end, tonumber(delay) or 50)
end

function EHH:ExitUIMode(delay)
	zo_callLater(function() if IsGameCameraUIModeActive() then ZO_SceneManager_ToggleHUDUIBinding() end end, tonumber(delay) or 50)
end

function EHH:HideAllDialogs()
	ZO_Dialogs_ReleaseAllDialogs()
end

function EHH:SetupAlertDialog()
    if not ESO_Dialogs[self.Defs.Dialogs.Alert] then
		ESO_Dialogs[self.Defs.Dialogs.Alert] = {
            canQueue = true,
            title = {
                text = "",
            },
            mainText = {
                text = "",
            },
            buttons = {
                [1] = {
                    text = SI_OK,
                    callback = function(dialog) end,
                },
            }
        }
    end

	return ESO_Dialogs[self.Defs.Dialogs.Alert]
end

function EHH:SetupConfirmDialog()
    if not ESO_Dialogs[self.Defs.Dialogs.Confirm] then
		ESO_Dialogs[self.Defs.Dialogs.Confirm] = {
            canQueue = true,
            title = {
                text = "",
            },
            mainText = {
                text = "",
            },
            buttons = {
                [1] = {
                    text = SI_DIALOG_CONFIRM,
                    callback = function(dialog) end,
                },
                [2] = {
                    text = SI_DIALOG_CANCEL,
					callback = function(dialog) end,
                }
            }
        }
    end

	return ESO_Dialogs[self.Defs.Dialogs.Confirm]
end

function EHH:ShowAlertDialog(body, confirmCallback, forceUIMode)
	local function onClick()
		if nil ~= confirmCallback then
			confirmCallback()
		end
		if nil == forceUIMode or forceUIMode then
			self:EnterUIMode()
		end
	end

	local dialogData =
	{
		body = body,
		buttons =
		{
			{
				text = "Close",
				handler = onClick,
			},
		},
	}
	self:SuppressDialogUI()
	self:ShowCustomDialog(dialogData)
end

function EHH:ShowErrorDialog(...)
	self:PlaySoundFailure()
	self:ShowAlertDialog(...)
end

function EHH:ShowConfirmationDialog(body, confirmCallback, cancelCallback, forceUIMode)
	local function onConfirm()
		if nil ~= confirmCallback then
			confirmCallback()
		end
		if nil == forceUIMode or forceUIMode then
			self:EnterUIMode()
		end
	end

	local function onCancel()
		if nil ~= cancelCallback then
			cancelCallback()
		end
		if nil == forceUIMode or forceUIMode then
			self:EnterUIMode()
		end
	end

	local dialogData =
	{
		body = body,
		buttons =
		{
			{
				text = "Yes",
				handler = onConfirm,
			},
			{
				text = "No",
				handler = onCancel,
			},
		},
	}
	self:SuppressDialogUI()
	self:ShowCustomDialog(dialogData)
end
-- /script Hub:ShowCustomDialog({body = "Testing", buttons={{text="Hello", handler=function() end}, {text="There"}, {text="World"}, {text="Weee"},}})
function EHH:HideCustomDialog()
	HousingHubCustomDialog:SetHidden(true)
end

function EHH:IsCustomDialogHidden()
	return HousingHubCustomDialog:IsHidden()
end

function EHH:GetCustomDialogList()
	return HousingHubCustomDialog.List
end

function EHH:GetCustomDialogEditBox()
	return HousingHubCustomDialog.EditBox
end

function EHH:ShowCustomDialog(data)
	local body = data.body
	local list = data.list
	local listLabel = data.listLabel
	local edit = data.edit
	local buttons = data.buttons

	self:HideCustomDialog()

	local dialog = HousingHubCustomDialog
	dialog.Body:SetText(body)
	
	local dialogList, dialogListLabel, dialogListContainer = dialog.List, dialog.ListLabel, dialog.ListContainer
	dialogList:ClearItems()
	dialogListLabel:SetHidden(true)
	if list then
		if listLabel then
			dialogListLabel:SetText(listLabel)
			dialogListLabel:SetHidden(false)
		end
		dialogList:SetItems(self:CloneTable(list))
		dialogListContainer:SetHidden(false)
	else
		dialogListContainer:SetHidden(true)
	end

	local editBackdrop = dialog.EditBox:GetParent()
	if edit then
		local defaultText = edit.defaultText
		local editEnabled = edit.editEnabled
		local maxInputChars = tonumber(edit.maxInputChars) or 10240
		local maxLineCount = tonumber(edit.maxLineCount or nil)
		local text = edit.text

		local FONT = ZoFontEdit
		local SCALE = 1.0
		local width = zo_clamp(40 + GetStringWidthScaledPixels(FONT, defaultText or text or "", SCALE), 100, 960)
		if not maxLineCount then
			maxLineCount = 1
			local newLines = {SplitString("\n", defaultText or text or "")}
			if "table" == type(newLines) then
				maxLineCount = newLines and math.min(15, #newLines) or 1
			end
		end

		editBackdrop:SetWidth(width)
		editBackdrop:SetHeight(28 * maxLineCount)
		editBackdrop:SetHidden(false)

		dialog.EditBox:SetMaxInputChars(maxInputChars)
		dialog.EditBox:SetEditEnabled(false ~= edit.editEnabled)
		dialog.EditBox:SetText(text or "")
		dialog.EditBox:SetHidden(false)
		if dialog.EditBox.SetDefaultText then
			dialog.EditBox:SetDefaultText(defaultText or "")
		end
	else
		dialog.EditBox:SetHidden(true)
		editBackdrop:SetHidden(true)
		editBackdrop:SetHeight(0)
	end

	for buttonIndex = 1, #dialog.Buttons do
		local buttonControl = dialog.Buttons[buttonIndex]
		local buttonData = buttons and buttons[buttonIndex]

		if buttonData and buttonData.handler then
			local handler = function(...)
				EssentialHousingHub:HideCustomDialog()
				return buttonData.handler(...)
			end

			buttonControl:SetHandler("OnMouseDown", handler)
			buttonControl:SetText(buttonData.text)
			buttonControl:SetHidden(false)
		else
			buttonControl:SetHandler("OnMouseDown", nil)
			buttonControl:SetHidden(true)
		end
	end

	dialog:SetHidden(false)

	self:EnterUIMode(400)
--[[
	if edit then
		zo_callLater(function()
			dialog.EditBox:SetSelection(0, #dialog.EditBox:GetText())
			dialog.EditBox:TakeFocus()
		end, 450)
	end
]]
end

function EHH:ShowURL(url)
	self:SuppressDialogUI()
	RequestOpenUnsafeURL(url)
end

function EHH:SuppressDialogUI()
	if not self.SuppressedDialogs then
		self.SuppressedDialogs = {}

		if not self:IsHousingHubHidden() then
			self.SuppressedDialogs["HousingHub"] = true
			self:HideHousingHub()
		end
	end

	if nil == next(self.SuppressedDialogs) then
		self.SuppressedDialogs = nil
	else
		HUB_EVENT_MANAGER:RegisterForUpdate(self.Name .. ".UnsuppressDialogUI", 250, function() self:UnsuppressDialogUI() end)
	end
end

function EHH:UnsuppressDialogUI()
	if ZO_Dialogs_IsShowingDialog() then
		return
	end

	if not self.UnsuppressingDialogs then
		self.UnsuppressingDialogs = true
	else
		HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".UnsuppressDialogUI")

		if self.SuppressedDialogs then
			if self.SuppressedDialogs["HousingHub"] and not self.HouseJumpRequest then
				zo_callLater(function()
					self:ShowHousingHub(true)
				end, 100)
			end
		end

		self.SuppressedDialogs = nil
		self.UnsuppressingDialogs = nil
	end
end

function EHH:CreateHouseLink(ownerName, houseId)
	houseId = tonumber( houseId ) or 0
	ownerName = tostring( ownerName ) or ""
	if "" == ownerName or "nil" == ownerName then
		ownerName = GetDisplayName()
	end
	return ZO_HousingBook_GetHouseLink( houseId, ownerName )
end

function EHH:ShareHouseLink(ownerName, houseId)
	ZO_LinkHandler_InsertLink( self:CreateHouseLink( ownerName, houseId ) )
	self:DisplayNotification( "Link pasted to chat" )
	return true
end

function EHH:ShareHubHouseLink(control)
	if "table" == type(control.Data) then
		local ownerName, houseId = control.Data.Owner, control.Data.HouseId
		self:ShareHouseLink(ownerName, houseId)
	end
end

function EHH:ShareHubFurnitureLink(control)
	local link = control.Data.FurnitureLink
	if link and "" ~= link then
		ZO_LinkHandler_InsertLink(link)
		self:DisplayNotification("Link pasted to chat")
	end
end

---[ Dialog Settings ]---

function EHH:GetDialogSettings(windowName)
	local settings = self:GetSettingTable(string.format("DialogSettings.%s", windowName))
	return settings
end

function EHH:SaveDialogSettings(windowName, window)
	local settings = self:GetSettingTable(string.format("DialogSettings.%s", windowName))
	if "userdata" == type(window) then
		settings.Left = window:GetLeft()
		settings.Top = window:GetTop()
		settings.Right = window:GetRight()
		settings.Bottom = window:GetBottom()
		settings.Width = window:GetWidth()
		settings.Height = window:GetHeight()
	else
		ZO_ClearTable(settings)
	end
end

---[ House Name Dialog ]---

function EHH:SetupHouseNameDialog()
	local ui = self:GetDialog("HouseNameDialog")
	if not ui then
		ui = self:CreateDialog("HouseNameDialog")
		do
			local win = WINDOW_MANAGER:CreateTopLevelWindow("EHHHouseNameWin")
			ui.Window = win
			win:SetHidden(true)
			win:SetDimensions(250, 50)
			win:SetClampedToScreen(true)
			win:SetClampedToScreenInsets(-6, -3, 6, 3)
			win:SetMouseEnabled(true)
			win:SetMovable(true)
			win:SetResizeHandleSize(0)

			zo_callLater(function()
				local settings = self:GetDialogSettings("EHHHouseNameDialog")
				if settings.Left and settings.Top then
					win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top)
				else
					win:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -2, 2)
				end

				self:OnHouseNameMoved()
			end, 2000)

			local c = WINDOW_MANAGER:CreateControl("EHHHouseOwner", win, CT_LABEL)
			ui.OwnerLabel = c
			c:SetFont("$(GAMEPAD_BOLD_FONT)|$(KB_22)|soft-shadow-thick")
			c:SetInheritAlpha(false)
			c:SetColor(1, 1, 1, 1)
			c:SetDimensions(250, 28)
			c:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			c:SetText("")
			c:SetAnchor(RIGHT, win, RIGHT)
			c:SetMouseEnabled(false)

			local c = WINDOW_MANAGER:CreateControl( "EHHHouseName", win, CT_LABEL )
			ui.HouseNameLabel = c
			c:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(KB_22)|soft-shadow-thick")
			c:SetInheritAlpha(false)
			c:SetColor(1, 1, 1, 1)
			c:SetDimensions(250, 22)
			c:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			c:SetText("")
			c:SetAnchor(TOPRIGHT, EHHHouseOwner, BOTTOMRIGHT)
			c:SetMouseEnabled(false)

			win:SetHandler("OnMoveStop", function(...) return self:OnHouseNameMoved(...) end)
		end
	end

	return ui
end

function EHH:OnHouseNameMoved()
	local ui = self:GetDialog("HouseNameDialog")
	if ui then
		local win = ui.Window
		if not win then
			return
		end

		self:SaveDialogSettings("EHHHouseNameDialog", win)

		local x, y = win:GetCenter()
		local centerX = GuiRoot:GetCenter()
		local screenWidth = GuiRoot:GetWidth()
		local textAlign, nameAnchorLocal, nameAnchorRelative, ownerAnchorLocal, ownerAnchorRelative

		local distCenter = math.abs(centerX - x)
		local distLeft = x
		local distRight = screenWidth - x

		if distLeft < distCenter and distLeft < distRight then
			textAlign = TEXT_ALIGN_LEFT
			ownerAnchorLocal, ownerAnchorRelative = TOPLEFT, TOPLEFT
			nameAnchorLocal, nameAnchorRelative = TOPLEFT, BOTTOMLEFT
		elseif distRight < distCenter and distRight < distLeft then
			textAlign = TEXT_ALIGN_RIGHT
			ownerAnchorLocal, ownerAnchorRelative = TOPRIGHT, TOPRIGHT
			nameAnchorLocal, nameAnchorRelative = TOPRIGHT, BOTTOMRIGHT
		else
			textAlign = TEXT_ALIGN_CENTER
			ownerAnchorLocal, ownerAnchorRelative = TOP, TOP
			nameAnchorLocal, nameAnchorRelative = TOP, BOTTOM
		end

		local ownerLabel = ui.OwnerLabel
		ownerLabel:ClearAnchors()
		ownerLabel:SetAnchor(ownerAnchorLocal, win, ownerAnchorRelative, 0, 0)
		ownerLabel:SetHorizontalAlignment(textAlign)

		local houseNameLabel = ui.HouseNameLabel
		houseNameLabel:ClearAnchors()
		houseNameLabel:SetAnchor(nameAnchorLocal, ownerLabel, nameAnchorRelative, 0, 0)
		houseNameLabel:SetHorizontalAlignment(textAlign)
	end
end

function EHH:GetCustomHouseName()
	return self.CurrentHouseName
end

function EHH:SetCustomHouseName(name)
	if self.IsEHT then
		return
	end

	local ui = self:SetupHouseNameDialog()
	if not ui then
		return
	end

	if not self:IsHouseZone() then
		self.CurrentHouseName = ""
		ui.Window:SetHidden(true)
		return
	end

	name = name or ""

	local isOwner = self:IsOwner()
	local ownerName = self:GetOwner()
	local houseName = self:GetHouseName()
	local houseNickname = self:GetCurrentHouseNickname()

	if "" ~= name then
		self.CurrentHouseName = name
	elseif "" ~= houseNickname then
		self.CurrentHouseName = houseNickname
	elseif "" ~= houseName then
		self.CurrentHouseName = houseName
	else
		self.CurrentHouseName = ""
	end

	if isOwner then
		ui.OwnerLabel:SetText(self.CurrentHouseName)
		ui.HouseNameLabel:SetText("")
	else
		ui.OwnerLabel:SetText(ownerName or "")
		ui.HouseNameLabel:SetText(self.CurrentHouseName)
	end
	ui.Window:SetHidden(false)
end

---[ HUD : Notification ]---

function EHH:SetupNotificationDialog()
	local ui = self:GetDialog("NotificationDialog")
	if not ui then
		ui = self:CreateDialog("NotificationDialog")

		local prefix = "EHHNotificationDialog"
		local c, grp, win

		win = WINDOW_MANAGER:CreateTopLevelWindow(prefix)
		ui.Window = win
		win:SetHidden(true)
		win:SetAlpha(0.5)
		win:SetClampedToScreen(true)
		win:SetMouseEnabled(true)
		win:SetMovable(true)
		win:SetResizeHandleSize(0)
		win:SetDimensions(1, 100)
		win:SetDrawLayer(DL_OVERLAY)
		win:SetDrawTier(DT_HIGH)
		win:SetDrawLevel(230000)

		local settings = self:GetDialogSettings(prefix)
		if settings.Left and settings.Top then
			win:SetAnchor(TOPLEFT, GuiRoot, nil, settings.Left, settings.Top)
		else
			win:SetAnchor(BOTTOM, GuiRoot, nil, 0, -340)
		end
		win:SetHandler("OnMoveStart", function()
			ui.IsMoving = true
			win:SetAlpha(0.75)
		end)
		win:SetHandler("OnMoveStop", function()
			self:SaveDialogSettings(prefix, win)
			ui.IsMoving = false
			if not ui.DurationMS then
				win:SetAlpha(0)
				win:SetHidden(true)
			end
		end)

		c = CreateTexture(prefix .. "Backdrop", win, CreateAnchor(CENTER, win, CENTER, 0, 0), nil, nil, nil, Textures.Solid, CreateColor(0, 0, 0, 0.9))
		ui.Backdrop = c
		c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
		c:SetDrawLayer(DL_OVERLAY)
		c:SetDrawLevel(230000)
		c:SetDrawTier(DT_HIGH)
		c:SetMouseEnabled(false)

		c = WINDOW_MANAGER:CreateControl(prefix .. "Message", ui.Backdrop, CT_LABEL)
		ui.Message = c
		c:SetColor(101 / 255 * 1.5, 114 / 255 * 1.5, 169 / 255 * 1.5, 1)
		c:SetText("")
		c:SetFont("$(BOLD_FONT)|$(KB_32)")
		c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		c:SetVerticalAlignment(TEXT_ALIGN_TOP)
		c:SetMouseEnabled(false)
		c:SetAnchor(CENTER, ui.Backdrop, CENTER, 0, 0)
		c:SetDrawLayer(DL_OVERLAY)
		c:SetDrawLevel(230001)
		c:SetDrawTier(DT_HIGH)
		c:SetHandler("OnRectChanged", function(control) win:SetDimensions(control:GetDimensions()) end)
	end

	return ui
end

function EHH:HideNotification()
	local ui = self:SetupNotificationDialog()
	if ui then
		if not ui.IsMoving then
			ui.Window:SetHidden(true)
		end

		ui.DurationMS = nil
		ui.StartFrameTimeMS = nil
		HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. "FadeNotification")
	end
end

function EHH:FadeNotification()
	local ui = self:GetDialog("NotificationDialog")
	if ui then
		local ft = GetFrameTimeMilliseconds()
		local interval = ft - ui.StartFrameTimeMS
		local progress = interval / ui.DurationMS

		local alpha
		if ui.IsMoving then
			alpha = 0.75
		else
			local FADE_INTERVAL_MS = 400
			if interval < FADE_INTERVAL_MS then
				alpha = self:VariableEaseIn(interval / FADE_INTERVAL_MS, 2)
			elseif (ui.DurationMS - interval) < FADE_INTERVAL_MS then
				alpha = self:VariableEaseIn((ui.DurationMS - interval) / FADE_INTERVAL_MS, 2)
			else
				alpha = 1
			end
		end
		ui.Window:SetAlpha(alpha)

		if 1 <= progress then
			self:HideNotification()
		end
	end
end

function EHH:DisplayNotification(message, duration)
	if not message then
		return false
	end

	local ui = self:SetupNotificationDialog()
	if not ui then
		return
	end

	local ft = GetFrameTimeMilliseconds()
	duration = tonumber(duration) or zo_clamp((#message / 7) * 700, 2000, 7000)

	ui.StartFrameTimeMS = ft
	ui.DurationMS = duration
	ui.Message:SetText(message)
	ui.Backdrop:SetResizeToFitDescendents(true)
	ui.Backdrop:SetResizeToFitPadding(16, 20)
	ui.Window:SetHidden(false)
	ui.Window:SetAlpha(0)
	HUB_EVENT_MANAGER:RegisterForUpdate(self.Name .. "FadeNotification", 20, function(...) return self:FadeNotification(...) end)

	return true
end

---[ Hub ]---

function EHH:DeferredInitializeHub()
	if not ESSENTIAL_HOUSING_HUB_SCENE then
		self.HubSceneName = "EssentialHousingHubScene"

		local ui = self:SetupHousingHub()
		local scene = ZO_Scene:New(self.HubSceneName, SCENE_MANAGER)
		self.HubScene = scene
		ESSENTIAL_HOUSING_HUB_SCENE = scene
		--scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW_NO_KEYBIND_STRIP)
		scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
		scene:AddFragment(ZO_FadeSceneFragment:New(ui.Window))
		scene:AddFragment(CODEX_WINDOW_SOUNDS)
		scene:AddFragment(MOUSE_UI_MODE_FRAGMENT)

		self:RegisterHousingBookHousingHub()
		local categoryInfo =
		{
			descriptor = self.HubSceneName,
			binding = "HOUSINGHUB",
			categoryName = SI_BINDING_NAME_HOUSINGHUB,
			callback = EssentialHousingHub.ShowHousingHubAction,
			visible = function(buttonData) return true end,
			normal = "esoui/art/collections/collections_tabicon_housing_up.dds",
			pressed = "esoui/art/collections/collections_tabicon_housing_down.dds",
			highlight = "esoui/art/collections/collections_tabicon_housing_over.dds",
			disabled = "esoui/art/collections/collections_tabicon_housing_disabled.dds",
		}
		ZO_MenuBar_AddButton(MAIN_MENU_KEYBOARD.categoryBar, categoryInfo)

		HUB_EVENT_MANAGER:RegisterCallback(self.HubScene, "StateChange", function(oldState, newState)
			if newState == SCENE_SHOWN then
				self:OnHousingHubShown()
				self:SetCanHelpShow(true)
			elseif newState == SCENE_HIDING then
				self:OnHousingHubHidden()
				self:SetCanHelpShow(false)
			end
		end)
	end
end

function EHH:RegisterHousingBookHousingHub()
	local dock = ZO_HousingBook_KeyboardContents -- HousingInteractButtons
	if not dock then
		return
	end

	local function OnClick()
		SCENE_MANAGER:ShowBaseScene()
		zo_callLater(function() self:ShowHousingHub() end, 500)
	end

	local button = CreateButton("EHHHousingBookHubButton", dock, "Housing Hub", nil, 120, 36, OnClick)
	button:SetExcludeFromResizeToFitExtents(true)
	button:SetAnchor(TOP, dock, BOTTOM, 0, 4)
end

function EHH:GetHubTileByPoint(x, y)
	for tileIndex, tile in ipairs(self:GetHubListControls()) do
		if not tile:IsHidden() and tile:IsPointInside(x, y, 0, 0, 0, 0) then
			return tile
		end
	end
	
	return nil
end

function EHH:OnHubStreamTileMouseDown(control)
	
end

function EHH:OnHubStreamTileMouseUp(control)

end

do
	local hubDialog

	function EHH:OnHubTileMoving()
		local mouseX, mouseY = GetUIMousePosition()
		local scrollPanel = hubDialog.ScrollPanel
		local top = scrollPanel:GetTop()
		local bottom = scrollPanel:GetBottom()
		local slider = hubDialog.ScrollSlider

		if mouseY < top then
			local sliderValue = slider:GetValue()
			slider:SetValue(sliderValue - 1)
		elseif mouseY > bottom then
			local sliderValue = slider:GetValue()
			slider:SetValue(sliderValue + 1)
		end

		local targetTile = self:GetHubTileByPoint(mouseX, mouseY)
		local isValid = nil ~= targetTile
		HousingHubTileDrag:SetIsValid(isValid)
	end
	
	function EHH:StartDraggingHubTile(control)
		local initialX, initialY = GetUIMousePosition()
		local dragControl = HousingHubTileDrag
		local width, height = dragControl:GetDimensions()
		initialX, initialY = initialX - 0.5 * width, initialY - 0.5 * height

		dragControl.ProxyToControl = control
		dragControl.ProxyFavoriteIndex = control.Data.FavIndex
		dragControl:ClearAnchors()
		dragControl:SetSimpleAnchor(GuiRoot, initialX, initialY)
		dragControl:SetHidden(false)
		dragControl:StartMoving()
		
		hubDialog = self:GetDialog("HousingHub")
		HUB_EVENT_MANAGER:RegisterForUpdate(self.Name .. "DraggingHubTile", 300, function() self:OnHubTileMoving() end)
	end
end

function EHH:OnHubTileMoveStopped(control)
	local dragControl = HousingHubTileDrag

	if control then
		local finalX, finalY = dragControl:GetCenter()
		local sourceFavoriteIndex = dragControl.ProxyFavoriteIndex
		local targetTile = self:GetHubTileByPoint(finalX, finalY)
		local targetFavoriteIndex
		
		if targetTile then
			targetFavoriteIndex = targetTile.Data.FavIndex
		end

		if not targetFavoriteIndex then
			if targetTile then
				targetFavoriteIndex = self.Defs.Limits.MaxFavoriteHouses
			else
				local topLeftTile = self:GetHubListControl(1)
				local minX = topLeftTile:GetLeft()
				local minY = topLeftTile:GetTop()

				targetFavoriteIndex = (finalX < minX or finalY < minY) and 1 or self.Defs.Limits.MaxFavoriteHouses
			end
		end

		if targetFavoriteIndex then
			self:MoveFavoriteHouse(self.World, sourceFavoriteIndex, targetFavoriteIndex)
			self:InvalidateHubList("Favorites")
			self:RefreshHousingHub()
		end
	end

	dragControl.ProxyToControl = nil
	dragControl.ProxyFavoriteIndex = nil
	dragControl:SetHidden(true)

	HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. "DraggingHubTile")
end

function EHH:OnHubTileMouseHeld(control)
	local frameTimeMS = GetFrameTimeMilliseconds()
	local heldTimeMS = frameTimeMS - control.MouseDownMS

	if not control.MouseDragging and heldTimeMS >= 250 then
		control.MouseDragging = true
		control:SetHandler("OnUpdate", nil, "MouseClick")
		self:StartDraggingHubTile(control)
	end
end

function EHH:OnHubTileMouseDown(control, ...)
	control.MouseDragging = false
	control.MouseDownMS = GetFrameTimeMilliseconds()

	local hubTabName = self:GetCurrentHousingHubTabAndCategoryIndex()
	local hubTabSort = self:GetPersistentState("HousingHubFavoriteSort")
	if control.Data.FavIndex and hubTabName == "Favorites" and hubTabSort == "Manual" then
		control.MouseClickDelayCheck = true
		control:SetHandler("OnUpdate", function() self:OnHubTileMouseHeld(control) end, "MouseClick")
	else
		control.MouseClickDelayCheck = false
		self:PerformHubTilePrimaryAction(control)
	end
end

function EHH:OnHubTileMouseUp(control, ...)
	if control.MouseClickDelayCheck then
		control:SetHandler("OnUpdate", nil, "MouseClick")
		if not control.MouseDragging then
			self:PerformHubTilePrimaryAction(control)
		end
	end

	control.MouseClickDelayCheck = false
	control.MouseDragging = false
	control.MouseDownMS = nil
end

do
	local function OnFocusHubTileChangedCallback()
		EHH:OnFocusHubTileChanged()
	end

	function EHH:OnFocusHubTileChanged()
		if self.isLoadingData then
			HUB_EVENT_MANAGER:RegisterForUpdate("EssentialHousingHub.OnFocusHubTileChanged", 100, OnFocusHubTileChangedCallback)

			for _, tile in ipairs(self.HubListTiles) do
				--tile:SetHandler("OnUpdate", nil, "FocusTileUpdate")
				tile.FocusAnimation:Stop()
			end

			return
		end
		HUB_EVENT_MANAGER:UnregisterForUpdate("EssentialHousingHub.OnFocusHubTileChanged")

		for _, tile in ipairs(self.HubListTiles) do
			if tile == self.focusHubTile then
				tile.IsFocusTile = true
				tile.FocusAnimation:PlayForward()
				--tile:SetHandler("OnUpdate", OnFocusTileUpdate, "FocusTileUpdate")
				self:SetEnhancedMouseOverMarginForControl(tile, 8)
			elseif tile.IsFocusTile then
				self:SetEnhancedMouseOverMarginForControl(tile, 0)
				tile.FocusAnimation:PlayBackward()
				tile.IsFocusTile = false
				--tile:SetHandler("OnUpdate", nil, "FocusTileUpdate")
			end
		end
	end

	function EHH:ClearFocusHubTile(control)
		if control == self.focusHubTile then
			self.focusHubTile = nil
			self:OnFocusHubTileChanged()
		end
	end

	function EHH:SetFocusHubTile(control)
		if control ~= self.focusHubTile then
			self.focusHubTile = control
			self:OnFocusHubTileChanged()
		end
	end
end

function EHH:DismissNotification(panelName)
	local stateTable = self:GetPersistentStateTable("ShowNotificationPanels")
	stateTable[panelName] = false
	self:SetNotificationPanelHidden(panelName, true)
end

function EHH:SetNotificationPanelHidden(panelName, hidden)
	local ui = self:GetDialog("HousingHub")
	if not ui then
		return
	end

	local panel = ui.NotificationPanels[panelName]
	if not panel then
		return
	end

	local stateTable = self:GetPersistentStateTable("ShowNotificationPanels")
	local state = stateTable[panelName]
	if false == state then
		hidden = true
	end

	local visibleIndex = 0
	for index, p in ipairs(ui.VisibleNotificationPanels) do
		if p == panel then
			visibleIndex = index
			break
		end
	end

	if hidden and 0 ~= visibleIndex then
		table.remove(ui.VisibleNotificationPanels, visibleIndex)
	elseif not hidden and 0 == visibleIndex then
		table.insert(ui.VisibleNotificationPanels, panel)
	end

	local anchorToTop, anchorToBottom
	for index, p in ipairs(ui.VisibleNotificationPanels) do
		p:ClearAnchors()
		if p.AnchorToSide == BOTTOM then
			if anchorToBottom then
				p:SetAnchor(BOTTOMRIGHT, anchorToBottom, TOPRIGHT, 0, 36)
			else
				p:SetAnchor(BOTTOMRIGHT, ui.NotificationContainer, BOTTOMRIGHT, 0, 0)
			end
			anchorToBottom = p
		else
			if anchorToTop then
				p:SetAnchor(TOPRIGHT, anchorToTop, BOTTOMRIGHT, 0, 36)
			else
				p:SetAnchor(TOPRIGHT, ui.NotificationContainer, TOPRIGHT, 0, 0)
			end
			anchorToTop = p
		end
		p:SetHidden(false)
	end
	panel:SetHidden(hidden)
end

function EHH:GetHubListControl(index)
	return self.HubListControls[index]
end

function EHH:GetHubListControls()
	return self.HubListControls
end

function EHH:SetHubListControls(controls)
	for index, control in ipairs(self.HubListControls) do
		control:SetHidden(true)
	end

	self.HubListControls = controls

	if controls == self.HubListRows then
		self.NumHubListEntrySlots = self.NumHubListRows
	elseif controls == self.HubListStreamRows then
		self.NumHubListEntrySlots = self.NumHubListStreamRows
	else
		self.NumHubListEntrySlots = self.NumHubListTiles
	end

	self:UpdateHubListSlider()
	self:UpdateHubList()

	for index, control in ipairs(self.HubListControls) do
		if control.Data and control.Data.Visible then
			control:SetHidden(false)
		end
	end
end

function EHH:AreHubListControlsTiles()
	return self.HubListControls == self.HubListTiles
end

function EHH:UseHubListControlTiles()
	self:SetHubListControls(self.HubListTiles)
end

function EHH:UseHubListControlRows()
	self:SetHubListControls(self.HubListRows)
end

function EHH:UseHubListControlStreamRows()
	self:SetHubListControls(self.HubListStreamRows)
end

function EHH:RefreshHubListControlsPreferenceButtons()
	local dialog = self:GetDialog("HousingHub")
	if self.AreHubListControlsOverriden then
		dialog.PreferRowsButton:SetHidden(true)
		dialog.PreferTilesButton:SetHidden(true)
	else
		dialog.PreferRowsButton:SetHidden(false)
		dialog.PreferTilesButton:SetHidden(false)
	end
end

function EHH:UsePreferredHubListControls()
	self.AreHubListControlsOverriden = false
	local preference = self:GetPersistentState("HubListControls")
	if "rows" == preference then
		self:UseHubListControlRows()
	else
		self:UseHubListControlTiles()
	end
	self:RefreshHubListControlsPreferenceButtons()
end

function EHH:OverrideHubListControls(controls)
	self.AreHubListControlsOverriden = false
	if "rows" == controls then
		self:UseHubListControlRows()
	elseif "streamrows" == controls then
		self:UseHubListControlStreamRows()
	else
		self:UseHubListControlTiles()
	end
	self.AreHubListControlsOverriden = true
	self:RefreshHubListControlsPreferenceButtons()
end

function EHH:SetPreferredHubListControls(controls)
	self:SetPersistentState("HubListControls", "rows" == controls and "rows" or "tiles")
	if not self.AreHubListControlsOverriden then
		if "rows" == controls then
			self:UseHubListControlRows()
		else
			self:UseHubListControlTiles()
		end
	end
	self:RefreshHubListControlsPreferenceButtons()
end

function EHH:ConfirmStreamChannelGoLive()
	if not self:IsStreamChannelDataValid() then
		self:ShowStreamChannelSettings()
		return false
	end

	local data =
	{
		body = "Your Twitch channel will appear in the Live Streams tab for all Community members - " ..
			"plus Community members will see a brief notification of your Live Stream " ..
			"that links to your Twitch channel when they log in or change characters.\n\n" ..
			"|acApproximately how long do you plan to stream for right now?",
		buttons =
		{
			{
				text = "1 - 2 Hours",
				handler = function()
					if self:StreamChannelGoLive(2) then
						ReloadUI()
					end
				end,
			},
			{
				text = "3 - 4 Hours",
				handler = function()
					if self:StreamChannelGoLive(4) then
						ReloadUI()
					end
				end,
			},
			{
				text = "5 - 6 Hours",
				handler = function()
					if self:StreamChannelGoLive(6) then
						ReloadUI()
					end
				end,
			},
			{
				text = "7 - 8 Hours",
				handler = function()
					if self:StreamChannelGoLive(8) then
						ReloadUI()
					end
				end,
			},
			{
				text = "Cancel",
				handler = function() end,
			},
		},
	}
	self:ShowCustomDialog(data)
	return true
end

do
	function EHH:SetupHousingHub()
		local ui = self:GetDialog("HousingHub")
		if not ui then
			self.NumHubListEntrySlots = 6
			self.NumHubListEntryColumns = 3
			self.HubMaxListCount = nil
			self.HubListFirstIndex = nil
			self.HubListFilterDefault = "Enter a search"
			self.HubListTiles = {}
			self.NumHubListTiles = 6
			self.HubListRows = {}
			self.NumHubListRows = 5
			self.HubListStreamRows = {}
			self.NumHubListStreamRows = 3
			self.HubList = {}
			self.DecoTrackItemCounts = {}
			self.HubListControls = self.HubListRows

			ui = self:CreateDialog("HousingHub")
			local VISIT_PLAYER_TEXT = "@player name"

			do
				local guildManagerSingleton = GUILD_HOME
				local guildDescriptionPane = ZO_GuildHomePane

				if guildManagerSingleton and guildManagerSingleton.SetGuildId and guildDescriptionPane then
					local hint = "" ..
						"Add a \"Visit Guildhall\" button for members with Housing Hub or EHT\n" ..
						"In your \"About Us\" just include  |c88ffffGuildhall: @player|r  or  |c88ffffGuildhall: house @player|r"
					local c = CreateLabel("EHHGuildhallHintLabel", guildDescriptionPane, hint, CreateAnchor(TOPLEFT, guildDescriptionPane, BOTTOMLEFT, 20, 10), CreateAnchor(TOPRIGHT, guildDescriptionPane, BOTTOMRIGHT, -20, 10))
					EHH.EHHGuildhallHintLabel = c
					SetLabelFont(c, 16, false, true)
					c:SetColor(1, 1, 1, 1)
					local b = CreateButton("EHHGuildDescriptionHintDismissButton", c, "Dismiss", CreateAnchor(RIGHT, c, LEFT, -15), 80, 30, function()
						self:SetSetting("HideGuildhallHintMessage", true)
						EHH.EHHGuildhallHintLabel:SetHidden(true)
					end)
					
					if self:GetSetting("HideGuildhallHintMessage") then
						EHH.EHHGuildhallHintLabel:SetHidden(true)
					end

					if guildManagerSingleton.SetGuildId then
						local keybinds = guildManagerSingleton.keybindStripDescriptor
						if keybinds then
							local visitGuildhallKeybind =
							{
								name = "|c88ffffVisit Guildhall|r",
								keybind = "UI_SHORTCUT_PRIMARY",
								callback = function()
									local currentGuildId = guildManagerSingleton.guildId
									if currentGuildId then
										self:VisitGuildhall(currentGuildId)
									end
								end,
								visible = function()
									local currentGuildId = guildManagerSingleton.guildId
									return self:DoesGuildhallExist(currentGuildId)
								end,
							}
							table.insert(keybinds, visitGuildhallKeybind)
						end

						local originalSetGuildId = guildManagerSingleton.SetGuildId
						if originalSetGuildId then
							guildManagerSingleton.SetGuildId = function(guildId, ...)
								local returnValue
								if guildId then
									returnValue = originalSetGuildId(guildId, ...)
								end

								local currentGuildId = guildManagerSingleton.guildId
								if currentGuildId and not self:GetSetting("HideGuildhallHintMessage") then
									local guild = self:GetGuildById(currentGuildId)
									EHH.EHHGuildhallHintLabel:SetHidden(false)

									if guild then
										if guild.GuildhallOwner then
											EHH.EHHGuildhallHintLabel:SetHidden(true)
										end
									end
								else
									EHH.EHHGuildhallHintLabel:SetHidden(true)
								end

								return returnValue
							end

							-- Force an initial refresh.
							guildManagerSingleton.SetGuildId()
						end
					end
				end
			end

			local windowName = "EHHHousingHubDialog"
			local prefix = "EHHHousingHubDialog"
			local settings = self:GetDialogSettings(windowName)
			local width, height = self.Defs.Controls.HubWindow.Width, self.Defs.Controls.HubWindow.Height
			local baseDrawLevel = 100

			-- Window Controls

			local c, grp, section, frame, win, windowFrame

			ui.ToggleTab = ToggleTab

			win = WINDOW_MANAGER:CreateTopLevelWindow(prefix)
			ui.Window = win
			win:SetDimensions(width, height)
			win:SetHidden(true)
			win:SetAlpha(1)
			win:SetMovable(true)
			win:SetMouseEnabled(true)
			win:SetClampedToScreen(true)
			win:SetResizeHandleSize(0)
			local guiWidth, guiHeight = GuiRoot:GetDimensions()
			win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, guiWidth * 0.6 - width * 0.5, guiHeight * 0.5 - height * 0.5)
			win:SetHandler("OnEffectivelyShown", function(...) self:RefreshHousingHub() end )

			c = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
			ui.HubBackdrop = c
			c:SetTexture(Textures.GLASS_FROSTED)
			c:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
			c:SetAnchor(TOPLEFT)
			c:SetAnchor(BOTTOMRIGHT, nil, nil, nil, -52)
			c:SetColor(0.2, 0.2, 0.2, 1)
			c:SetTextureCoords(1, 0, 1, 0)
--[[
			do
				local b = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
				ui.HubBackdropOverlay = b
				b:SetTexture(Textures.HUB_LOGO)
				b:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
				b:SetAnchor(CENTER)
				b:SetColor(0.407, 0.5, 0.812, 1.0)
				b:SetDimensions(500, 500)
				b:SetShaderEffectType(SHADER_EFFECT_TYPE_RADIAL_BLUR)
				b:SetTextureCoords(-0.2, 1.2, -0.2, 1.2)
HBD = ui.HubBackdropOverlay
				b:SetHandler("OnUpdate", function()
					local t = GetFrameTimeSeconds()
					local x = 0.5 + sin(t) * 0.2
					local y = 0.5 - sin(t * 1.4) * 0.2
					-- ui.HubBackdropOverlay:SetRadialBlur(x, y, 15, 0.1, 0.0)
				end)
			end
]]
			do
				local b1 = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
				ui.HubBackdrop1 = b1
				b1:SetTexture(Textures.HUB_CAUSTIC)
				b1:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
				b1:SetAnchor(TOPLEFT, nil, nil, 4, 4)
				b1:SetAnchor(BOTTOMRIGHT, nil, nil, -4, -56)
				b1:SetColor(0.65, 0, 1, 1)
				b1:SetShaderEffectType(SHADER_EFFECT_TYPE_CAUSTIC)
				b1:SetCaustic(1.01, 1.01, 0.5, 0.25)
				b1:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 2.0)

				local b2 = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
				ui.HubBackdrop2 = b2
				b2:SetTexture(Textures.HUB_CAUSTIC)
				b2:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
				b2:SetAnchor(TOPLEFT, nil, nil, 4, 4)
				b2:SetAnchor(BOTTOMRIGHT, nil, nil, -4, -56)
				b2:SetBlendMode(TEX_BLEND_MODE_ADD)
				b2:SetColor(0, 0.5, 1, 1)
				b2:SetShaderEffectType(SHADER_EFFECT_TYPE_CAUSTIC)
				b2:SetCaustic(1, 1, 0.5, 0)
				b2:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1)
			end

			windowFrame = WINDOW_MANAGER:CreateControl(prefix .. "WindowFrame", win, CT_CONTROL)
			ui.WindowFrame = windowFrame
			windowFrame:SetAnchor(TOPLEFT, win, TOPLEFT, 8, 8)
			windowFrame:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -8, -8)
			windowFrame:SetDrawLevel(baseDrawLevel)

			-- Tabs

			c = WINDOW_MANAGER:CreateControl(nil, win, CT_CONTROL)
			ui.TabButtonBar = c
			c:SetAnchor(LEFT, win, TOPLEFT, 15, -28)
			c:SetAnchor(RIGHT, win, TOPRIGHT, -15, -28)
			c:SetHeight(26)
			c:SetDrawLevel(0)
			c:SetMouseEnabled(false)

			c = WINDOW_MANAGER:CreateControl(nil, ui.TabButtonBar, CT_TEXTURE)
			ui.TabButtonBarShadow = c
			c:SetAnchor(TOPLEFT, nil, TOPLEFT, 4, 5)
			c:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, -4, 5)
			c:SetColor(0, 0, 0, 0.3)
			c:SetDrawLevel(0)
			c:SetMouseEnabled(false)

			c = WINDOW_MANAGER:CreateControl(nil, ui.TabButtonBar, CT_TEXTURE)
			ui.TabButtonBarOutline = c
			c:SetAnchor(TOPLEFT, nil, nil, -1, -1)
			c:SetAnchor(BOTTOMRIGHT, nil, nil, 1, 1)
			c:SetColor(0, 0, 0, 1)
			c:SetDrawLevel(1)
			c:SetExcludeFromResizeToFitExtents(true)
			c:SetMouseEnabled(false)

			c = WINDOW_MANAGER:CreateControl(nil, ui.TabButtonBar, CT_TEXTURE)
			ui.TabButtonBarBackdrop = c
			c:SetAnchorFill()
			c:SetColor(0.2, 0.25, 0.5, 1)
			c:SetDrawLevel(2)
			c:SetExcludeFromResizeToFitExtents(true)
			c:SetMouseEnabled(false)

			c = WINDOW_MANAGER:CreateControl(prefix .. "TabButtons", ui.TabButtonBar, CT_CONTROL)
			ui.TabButtonContainer = c
			c:SetAnchor(LEFT, nil, nil, 26)
			c:SetAnchor(RIGHT)
			c:SetHeight(44)
			c:SetDrawLevel(baseDrawLevel) baseDrawLevel = baseDrawLevel + 1
			c:SetResizeToFitDescendents(true)
			c:SetMouseEnabled(false)

			ui.TabButtons = {}
			local previousTabButtonDrawLevel = baseDrawLevel + 200
			local previousLeftTabButton, previousRightTabButton

			local function addTabButton(template, label, key, tooltip, rightAlign, addNewIcon, margin)
				template = template or "HousingHubTabButton"
				key = key or label

				local btn = WINDOW_MANAGER:CreateControlFromVirtual(string.format("EHHHousingHubTab%s", key), ui.TabButtonContainer, template)	
				btn.Key = key
				btn:SetDrawLevel(previousTabButtonDrawLevel)
				previousTabButtonDrawLevel = previousTabButtonDrawLevel - 10
				btn.Backdrop:SetDrawLevel(previousTabButtonDrawLevel)

				if rightAlign then
					if previousRightTabButton then
						btn:SetAnchor(RIGHT, previousRightTabButton, LEFT, -(margin or 23))
					else
						btn:SetAnchor(RIGHT, ui.TabButtonContainer, RIGHT)
					end

					previousRightTabButton = btn
				else
					if previousLeftTabButton then
						btn:SetAnchor(LEFT, previousLeftTabButton, RIGHT, margin or 23)
					else
						btn:SetAnchor(LEFT, ui.TabButtonContainer, LEFT, -26)
					end
					
					previousLeftTabButton = btn
				end

				btn:SetHeight(26)
				btn:SetText(label)
				btn:SetMouseEnabled(false)
				btn.Backdrop:SetHandler("OnMouseDown", function()
					self:ShowHousingHubView(btn.Key)
				end, "TabAction")

				if tooltip then
					self:SetInfoTooltip(btn.Backdrop, tooltip, BOTTOM, 0, -10, TOP)
				end

				table.insert(ui.TabButtons, btn)

				if addNewIcon then
					local newIcon = WINDOW_MANAGER:CreateControl(nil, btn, CT_TEXTURE)
					btn.NewIcon = newIcon
					newIcon:SetHidden(true)
					newIcon:SetDrawLevel(previousTabButtonDrawLevel)
					newIcon:SetTexture(self.Textures.ICON_ALERT)
					newIcon:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
					newIcon:SetDimensions(36, 72)
					newIcon:SetAnchor(CENTER, nil, nil, nil, -8)
					newIcon:SetColor(0.8, 0.72, 0.32, 1)

					local timeline = ANIMATION_MANAGER:CreateTimeline()
					timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP)
					timeline:SetPlaybackLoopCount(LOOP_INDEFINITELY)
					newIcon.AnimationTimeline = timeline

					local animation = timeline:InsertAnimation(ANIMATION_CUSTOM, newIcon)
					animation:SetDuration(2200)
					animation:SetUpdateFunction(function(animationControl, progress)
						local control = animationControl:GetAnimatedControl()
						local interval = self:VariableEase(progress, 3)
						control:SetScale(zo_lerp(0.75, 1, interval))
					end)
					
					newIcon:SetHandler("OnEffectivelyHidden", function()
						timeline:Stop()
					end)
				end
				
				return btn
			end

			local DEFAULT_TAB_TEMPLATE = "HousingHubLocalTabButton"
			local COMMUNITY_TAB_TEMPLATE = "HousingHubCommunityTabButton"
			local ADD_NEW_ICON = true
			local RIGHT_ALIGN = true
			addTabButton(DEFAULT_TAB_TEMPLATE, "Favorites", "Favorites", "A customizable list of your favorite homes - yours or any other players.")
			addTabButton(DEFAULT_TAB_TEMPLATE, "My Homes", "My Homes", "A list of the homes that you own.")
			addTabButton(DEFAULT_TAB_TEMPLATE, "Visited Homes", "Recent", "A list of the homes that you have visited.")
			addTabButton(DEFAULT_TAB_TEMPLATE, "Guests", "Guest Journal", "A list of all guest signatures left in your homes' guest journals.", nil, ADD_NEW_ICON)
			addTabButton(DEFAULT_TAB_TEMPLATE, "Guilds", "Guilds", "A list of your guilds' housing tour entries.")
			addTabButton(DEFAULT_TAB_TEMPLATE, "Furniture", "Furniture", "A list of all of your furniture, in one place. Requires the DecoTrack add-on.")
			addTabButton(COMMUNITY_TAB_TEMPLATE, "Trending", "Trending Houses", "Today's featured open houses - a mix of some of the most visited and some of the most recently listed homes.", RIGHT_ALIGN)
			addTabButton(COMMUNITY_TAB_TEMPLATE, "Open Houses", "Open Houses", "A list of houses opened by members of our Community for anyone and everyone to visit, share, stream, enjoy and get inspired!", RIGHT_ALIGN)
			addTabButton(COMMUNITY_TAB_TEMPLATE, "Live Streams", "Live Streams", "Live streams of ESO Housing content creators.", RIGHT_ALIGN, ADD_NEW_ICON)
--[[
			do
				local btn = WINDOW_MANAGER:CreateControlFromVirtual("EHHHubTipsButton", windowFrame, "HousingHubTexture")
				ui.TipsButton = btn
				btn:SetAnchor(RIGHT, ui.Window, LEFT)
				btn:SetColor(0.58, 0.75, 1, 1)
				btn:SetDimensions(32, 60)
				btn:SetDrawLayer(DL_CONTROLS)
				btn:SetDrawLevel(0)
				btn:SetDrawTier(DT_LOW)
				btn:SetMouseEnabled(true)
				btn:SetTexture(Textures.HUB_BUTTON)

				btn:SetHandler("OnMouseDown", function()
					--
				end)

				local lbl = WINDOW_MANAGER:CreateControl(nil, btn, CT_TEXTURE)
				btn.Label = lbl
				lbl:SetAnchor(CENTER)
				lbl:SetColor(1, 1, 1, 1)
				lbl:SetDimensions(20, 40)
				lbl:SetDrawLayer(DL_OVERLAY)
				lbl:SetMouseEnabled(false)
				lbl:SetTexture(Textures.ICON_TIPS)
				self:TransformTexture(lbl, -0.5 * math.pi, 0.5, 0.5, 1, 1)
			end
]]
			do
				local lbl = WINDOW_MANAGER:CreateControlFromVirtual("EHHHubSetupCommunityButton", windowFrame, "HousingHubLabelPanel")
				ui.SetupCommunityLabel = lbl
				lbl:SetHidden(true)
				lbl:SetAnchor(TOPLEFT, windowFrame, nil, 230, 188)
				lbl:SetAnchor(BOTTOMRIGHT, windowFrame, nil, -238, -188)
				lbl:SetDrawLevel(baseDrawLevel)
				lbl:SetFont("$(BOLD_FONT)|$(KB_22)|soft-shadow-thick")
				lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				lbl:SetMaxLineCount(20)
				lbl:SetMouseEnabled(true)
				lbl:SetText("To sign guest journals, tour Open Houses or " ..
					"host Open Houses of your own, please install the " ..
					"Essential Housing Community App that comes bundled " ..
					"with this add-on.\n\n" ..
					"If you have just installed the Community app, please type\n" ..
					"|cffff00/reloadui|r in your chat window to complete " ..
					"the installation.\n" ..
					"In some cases it may be necessary to exit and restart the game.\n\n" ..
					"|acCheck out our 1-minute installation walkthrough " ..
					"in the |cffff00Community App|r|ac section of help guide.")
				lbl:SetHandler("OnMouseDown", function()
					self:ShowHelpTopic("CommunityApp")
				end)
			end

			do
				local lbl = WINDOW_MANAGER:CreateControlFromVirtual("EHHHubUpdateDecoTrackButton", windowFrame, "HousingHubLabelPanel")
				ui.InstallDecoTrackLabel = lbl
				lbl:SetHidden(true)
				lbl:SetAnchor(TOPLEFT, windowFrame, nil, 120, 88)
				lbl:SetAnchor(BOTTOMRIGHT, windowFrame, nil, -128, -88)
				lbl:SetDrawLevel(baseDrawLevel)
				lbl:SetFont("$(BOLD_FONT)|$(KB_22)|soft-shadow-thick")
				lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
				lbl:SetVerticalAlignment(TEXT_ALIGN_TOP)
				lbl:SetMaxLineCount(4)
				lbl:SetMouseEnabled(true)
				lbl:SetText("Quickly search furniture in your bank, homes, storage chests and characters\n" ..
					"from the Hub with |c88ffffDecoTrack|r - available from Minion or |cffff88ESOUI.com|r")
				lbl:SetHandler("OnMouseDown", function()
					self:ShowURL(self.Defs.Urls.DownloadDecoTrack)
				end)
				
				local tex = WINDOW_MANAGER:CreateControlFromVirtual("EHHHubUpdateDecoTrackPromoImage", lbl, "HousingHubTexture")
				lbl.Image = tex
				tex:SetAnchor(TOP, nil, nil, 30, 86)
				tex:SetDimensions(753 * 0.6, 588 * 0.6)
				tex:SetDrawLayer(DL_OVERLAY)
				tex:SetDrawTier(DT_HIGH)
				tex:SetInheritAlpha(false)
				tex:SetMouseEnabled(false)
				tex:SetTexture(self.Textures.ICON_DECOTRACK_PROMO)
				tex:SetTextureCoords(0, 753 / 897, 0, 588 / 631)
			end

			do
				local lbl = WINDOW_MANAGER:CreateControlFromVirtual("EHHHubGuildTourSetupLabel", windowFrame, "HousingHubLabelPanel")
				ui.SetupGuildHomesLabel = lbl
				lbl:SetHidden(true)
				lbl:SetAnchor(TOPLEFT, windowFrame, nil, 180, 77)
				lbl:SetAnchor(BOTTOMRIGHT, windowFrame, nil, -188, -77)
				lbl:SetDrawLevel(baseDrawLevel)
				lbl:SetMouseEnabled(false)
				lbl:SetText("")

				local lbl1 = WINDOW_MANAGER:CreateControl(nil, lbl, CT_LABEL)
				lbl1:SetAnchor(TOPLEFT, nil, nil, 40, 0)
				lbl1:SetAnchor(TOPRIGHT, nil, nil, -40, 0)
				lbl1:SetColor(1, 1, 1, 1)
				lbl1:SetDrawLayer(DL_OVERLAY)
				lbl1:SetDrawTier(DT_HIGH)
				lbl1:SetFont("$(BOLD_FONT)|$(KB_22)|soft-shadow-thick")
				lbl1:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
				lbl1:SetMaxLineCount(4)
				lbl1:SetMouseEnabled(false)
				lbl1:SetText("Does your guild organize housing showcases or contests?\n" ..
					"Give your guild members a guided tour here.")

				local lbl2 = WINDOW_MANAGER:CreateControl(nil, lbl, CT_LABEL)
				lbl2:SetAnchor(TOPLEFT, lbl1, BOTTOMLEFT, 0, 15)
				lbl2:SetAnchor(TOPRIGHT, lbl1, BOTTOMRIGHT, 0, 15)
				lbl2:SetColor(1, 1, 1, 1)
				lbl2:SetDrawLayer(DL_OVERLAY)
				lbl2:SetDrawTier(DT_HIGH)
				lbl2:SetFont("$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thick")
				lbl2:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				lbl2:SetMaxLineCount(4)
				lbl2:SetMouseEnabled(false)
				lbl2:SetText("Ask a guild officer to list the |cffff88@names|r of |cffff88guild members|r " ..
					"participating in your housing event in your guild's Message of the Day.")

				local txt = WINDOW_MANAGER:CreateControlFromVirtual("EHHHubGuildMotDPromo", lbl, "HousingHubTexture")
				txt:SetAnchor(TOP, lbl2, BOTTOM, 0, 20)
				txt:SetDimensions(320, 200)
				txt:SetDrawLayer(DL_OVERLAY)
				txt:SetDrawTier(DT_HIGH)
				txt:SetInheritAlpha(false)
				txt:SetMouseEnabled(false)
				txt:SetTexture(self.Textures.ICON_GUILD_MOTD)

				local lbl3 = WINDOW_MANAGER:CreateControl(nil, lbl, CT_LABEL)
				lbl3:SetAnchor(TOPLEFT, lbl2, BOTTOMLEFT, 0, 240)
				lbl3:SetAnchor(TOPRIGHT, lbl2, BOTTOMRIGHT, 0, 240)
				lbl3:SetColor(1, 1, 1, 1)
				lbl3:SetDrawLayer(DL_OVERLAY)
				lbl3:SetDrawTier(DT_HIGH)
				lbl3:SetFont("$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thick")
				lbl3:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				lbl3:SetMaxLineCount(4)
				lbl3:SetMouseEnabled(false)
				lbl3:SetText("The Hub will automatically list the participants' primary homes here as a " ..
					"convenient way for your guild members to tour them all with a click.")
			end

			do
				local MOTD_WIDTH = 200
				local grp = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
				ui.GuildMotD = grp
				grp:SetHidden(true)
				grp:SetAnchor(TOPLEFT, win, TOPRIGHT, 10, 20)
				grp:SetAnchor(BOTTOMLEFT, win, BOTTOMRIGHT, 10, -60)
				grp:SetColor(0.3, 0.3, 0.3, 0.95)
				grp:SetTexture(self.Textures.GLASS_FROSTED)
				grp:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
				grp:SetWidth(MOTD_WIDTH)

				local scroll = WINDOW_MANAGER:CreateControl(nil, grp, CT_SCROLL)
				ui.GuildMotDScroll = scroll
				scroll:SetAnchor(TOPLEFT, grp, TOPLEFT, 10, 10)
				scroll:SetAnchor(BOTTOMRIGHT, grp, BOTTOMRIGHT, -10, -10)
				scroll:SetMouseEnabled(true)
				scroll:SetHandler("OnMouseWheel", function(self, delta, ctrl, alt, shift)
					local scroll = ui.GuildMotDScroll
					local _, scrollOffset = scroll:GetScrollOffsets()

					scroll:SetVerticalScroll(scrollOffset - 20 * (delta or 1) * (shift and 2 or 1))
					ZO_UpdateScrollFade(true, scroll, ZO_SCROLL_DIRECTION_VERTICAL, 0.1)
				end)

				local lbl = WINDOW_MANAGER:CreateControl(nil, ui.GuildMotDScroll, CT_LABEL)
				ui.GuildMotDLabel = lbl
				lbl:SetColor(1, 1, 1, 1)
				lbl:SetFont("$(CHAT_FONT)|$(KB_18)")
				lbl:SetAnchor(TOPLEFT, ui.GuildMotDScroll, TOPLEFT, 0, 0)
				lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				lbl:SetMaxLineCount(200)
				lbl:SetWidth(MOTD_WIDTH - 20)
			end

			-- Filter criteria

			c = WINDOW_MANAGER:CreateControl(nil, ui.WindowFrame, CT_CONTROL)
			ui.FilterCriteriaContainer = c
			c:SetAnchor(TOPLEFT, nil, TOPLEFT, -24, 6)
			c:SetAnchor(BOTTOMLEFT, nil, TOPLEFT, -24, 32)
			-- c:SetAnchor(TOPLEFT, nil, TOPLEFT, -24, 48)
			-- c:SetAnchor(BOTTOMLEFT, nil, TOPLEFT, -24, 74)
			c:SetDrawLevel(1000)
			c:SetDrawTier(DT_LOW)
			c:SetResizeToFitDescendents(true)
			c:SetResizeToFitPadding(40, 0)

			c = WINDOW_MANAGER:CreateControl(nil, ui.FilterCriteriaContainer, CT_TEXTURE)
			ui.FilterCriteriaShadow = c
			c:SetAnchor(TOPLEFT, nil, nil, 4, 5)
			c:SetAnchor(BOTTOMRIGHT, nil, nil, -4, 5)
			c:SetColor(0, 0, 0, 0.25)
			c:SetDrawLevel(1001)
			c:SetDrawTier(DT_LOW)
			c:SetExcludeFromResizeToFitExtents(true)

			c = WINDOW_MANAGER:CreateControl(nil, ui.FilterCriteriaContainer, CT_TEXTURE)
			ui.FilterCriteriaOutline = c
			c:SetAnchor(TOPLEFT, nil, nil, -1, -1)
			c:SetAnchor(BOTTOMRIGHT, nil, nil, 1, 1)
			c:SetColor(0, 0, 0, 1)
			c:SetDrawLevel(1002)
			c:SetDrawTier(DT_LOW)
			c:SetExcludeFromResizeToFitExtents(true)

			c = WINDOW_MANAGER:CreateControl(nil, ui.FilterCriteriaContainer, CT_TEXTURE)
			ui.FilterCriteriaBackdrop = c
			c:SetAnchorFill()
			c:SetColor(0.2, 0.25, 0.5, 1)
			c:SetDrawLevel(1003)
			c:SetDrawTier(DT_LOW)
			c:SetExcludeFromResizeToFitExtents(true)

			baseDrawLevel = 100

			c = WINDOW_MANAGER:CreateControlFromVirtual("HousingHubRowCountLabel", ui.FilterCriteriaContainer, "HousingHubLabelBase")
			ui.RowCount = c
			c:SetDrawLevel(baseDrawLevel + 1100)
			c:SetAnchor(LEFT, nil, nil, 24)
			c:SetColor(1, 1, 1, 1)
			c:SetText("")
			c:SetWidth(128)

			do
				ui.FilterBackdrop = CreateTexture(nil, ui.FilterCriteriaContainer, CreateAnchor(LEFT, ui.RowCount, RIGHT), nil, 170, 36, Textures.Solid, Colors.ControlBox)
				ui.FilterBackdrop2 = CreateTexture(nil, ui.FilterBackdrop, CreateAnchor(TOPLEFT, ui.FilterBackdrop, TOPLEFT, 2, 2), CreateAnchor(BOTTOMRIGHT, ui.FilterBackdrop, BOTTOMRIGHT, -2, -2), 276, 32, Textures.Solid, Colors.ControlBackdrop)
				
				ui.FilterBackdrop:SetDrawLevel(baseDrawLevel + 1101)
				ui.FilterBackdrop2:SetDrawLevel(baseDrawLevel + 1102)
			end

			c = WINDOW_MANAGER:CreateControlFromVirtual(nil, ui.FilterBackdrop2, "ZO_DefaultEditForBackdrop")
			ui.Filter = c
			c:SetFont("$(MEDIUM_FONT)|$(KB_20)")
			c:SetDrawLevel(baseDrawLevel + 1110)
			c:ClearAnchors()
			c:SetAnchor(LEFT, ui.FilterBackdrop2, nil, 4)
			c:SetAnchor(RIGHT, ui.FilterBackdrop2, nil, -4)
			c:SetMaxInputChars(128)
			c:SetMouseEnabled(true)
			c:SetText(self.HubListFilterDefault)
			c:SetHandler("OnMouseUp", function()
				zo_callLater(function() ui.Filter:SelectAll() end, 50)
			end)
			c:SetHandler("OnFocusLost", function(...)
				self:ScrollHubListToTop()
				return self:RefreshHousingHub(...)
			end)
			c:SetHandler("OnEnter", function(...)
				self:ScrollHubListToTop()
				return self:RefreshHousingHub(...)
			end)

			local EXAMPLE_COLOR = "|c98afff"
			local SEARCH_HOUSES_TOOLTIP_HINT = 
				"|cffff88To find homes...\n" .. EXAMPLE_COLOR ..
				"    grand topal hideaway" ..
				"\n|cbbbbbb  or just\n" .. EXAMPLE_COLOR ..
				"    topal" ..
				"\n|cbbbbbb  or a player's homes\n" .. EXAMPLE_COLOR ..
				"    @cardinal05" ..
				"\n|cbbbbbb  or a player's specific home\n" .. EXAMPLE_COLOR ..
				"    @cardinal05 grand topal" ..
				"\n|cbbbbbb  or a home's nickname\n" .. EXAMPLE_COLOR ..
				"    ocean of stars" ..
				"\n|cbbbbbb  or your private notes for a home\n" .. EXAMPLE_COLOR ..
				"    custom build" ..
				"\n|cbbbbbb  or exclude terms\n" .. EXAMPLE_COLOR ..
				"    estate -surreal"

			local SEARCH_FURNITURE_TOOLTIP_HINT
			if self:DoesDecoTrackSupportEnhancedSearch() then
				SEARCH_FURNITURE_TOOLTIP_HINT =
					"|cffff88To find your furniture...\n" .. EXAMPLE_COLOR ..
					"    replica dreamshard" ..
					"\n|cbbbbbb  or exclude terms\n" .. EXAMPLE_COLOR ..
					"    replica -dream" ..
					"\n|cbbbbbb  or a category of furniture\n" .. EXAMPLE_COLOR ..
					"    lighting" ..
					"\n|cbbbbbb  or a home's furniture\n" .. EXAMPLE_COLOR ..
					"    grand topal" ..
					"\n|cbbbbbb  or a character's furniture\n" .. EXAMPLE_COLOR ..
					"    Builder Barbara"
				if self:DoesDecoTrackSupportBoundItems() then
					SEARCH_FURNITURE_TOOLTIP_HINT = SEARCH_FURNITURE_TOOLTIP_HINT ..
						"\n|cbbbbbb  or tradeable furniture\n" .. EXAMPLE_COLOR ..
						"    tradeable display case" ..
						"\n|cbbbbbb  or bound furniture\n" .. EXAMPLE_COLOR ..
						"    bound display case"
				else
					SEARCH_FURNITURE_TOOLTIP_HINT = SEARCH_FURNITURE_TOOLTIP_HINT ..
						"\n\n|cffff88To find bound or tradeable furniture...\n|cffffff" ..
						"Update |cffff00DecoTrack|cffffff from Minion or ESOUI.com"
				end
			else
				SEARCH_FURNITURE_TOOLTIP_HINT =
					"|cffff88To find your furniture...\n|cffffff" ..
					"Install |cffff00DecoTrack|cffffff from Minion or ESOUI.com"
			end

			c:SetHandler("OnMouseEnter", function(control)
				WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PREVIEW)
				local tabName = string.lower(self:GetCurrentHousingHubTabAndCategoryIndex())
				local tooltipText = "furniture" == tabName and SEARCH_FURNITURE_TOOLTIP_HINT or SEARCH_HOUSES_TOOLTIP_HINT
				self:SetTooltip(tooltipText, control, RIGHT)
			end, "Tooltip")

			do
				local function OnHide()
					self:ClearTooltip()
					WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
				end
				c:SetHandler("OnMouseExit", OnHide, "Tooltip")
				c:SetHandler("OnEffectivelyHidden", OnHide, "Tooltip")
			end

			do
				local clear = WINDOW_MANAGER:CreateControlFromVirtual("HousingHubClearFilterButton", ui.FilterCriteriaContainer, "HousingHubShortcutButton")
				ui.ClearFilterButton = clear
				clear:SetHidden(true)
				clear:SetAnchor(LEFT, ui.Filter, RIGHT, 11)
				clear:SetDimensions(15, 15)
				clear:SetDrawLayer(DL_OVERLAY)
				clear:SetDrawLevel(50001)
				clear:SetDrawTier(DT_HIGH)
				clear:SetMouseEnabled(true)
				clear:SetTexture(self.Textures.ICON_CLOSE)
				clear:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
				clear:SetHandler("OnMouseDown", function()
					ui.Filter:SetText("")
					self:ScrollHubListToTop()
					self:RefreshHousingHub()
				end)
				clear:SetHandler("OnMouseEnter", function()
					clear:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 2)
				end)
				clear:SetHandler("OnMouseExit", function()
					clear:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1)
				end)

				local backdrop = WINDOW_MANAGER:CreateControl(nil, ui.ClearFilterButton, CT_TEXTURE)
				backdrop:SetAnchor(TOPLEFT, nil, nil, -4, -4)
				backdrop:SetColor(0, 0, 0, 0.85)
				backdrop:SetDimensions(23, 23)
				backdrop:SetDrawLayer(DL_CONTROLS)
				backdrop:SetDrawLevel(10000)
				backdrop:SetMouseEnabled(false)
			end

			do
				local c = WINDOW_MANAGER:CreateControlFromVirtual("HousingHubSortLabel", ui.FilterCriteriaContainer, "HousingHubLabelBase")
				ui.SortLabel = c
				c:SetDrawLevel(baseDrawLevel + 1100)
				c:SetAnchor(LEFT, ui.FilterBackdrop, RIGHT, 35, 0)
				c:SetColor(1, 1, 1, 1)
				c:SetText("Sort by")
			end

			do
				local sort = EHH.Picklist:New("EHHHousingHubSort", ui.FilterCriteriaContainer, LEFT, ui.SortLabel, RIGHT, 12, 0, 210, 36)
				ui.Sort = sort
				sort:SetDrawLevel(baseDrawLevel + 1100)
				sort:SetHidden(true)
				sort:SetFont("$(MEDIUM_FONT)|$(KB_20)")
				sort:AddHandler("OnSelectionChanged", function(ctl, item)
					local sortKey
					if item and item.Value then
						local sortId = tonumber(item.Value)
						if sortId then
							local sortDef = self.Defs.HubSorts[sortId]
							if sortDef then
								sortKey = sortDef.key
							end
						end
					end
					
					local currentView = self:GetHousingHubView()
					if "Furniture" == currentView then
						self:SetPersistentState("HousingHubFurnitureSort", sortKey)
					elseif "Favorites" == currentView then
						self:SetPersistentState("HousingHubFavoriteSort", sortKey)
					elseif "Open Houses" == currentView then
						self:SetPersistentState("HousingHubOpenHousesSort", sortKey)
					else
						self:SetPersistentState("HousingHubOtherSort", sortKey)
					end

					self:RefreshHousingHub()
				end)
			end

			c = WINDOW_MANAGER:CreateControl(nil, ui.FilterCriteriaContainer, CT_TEXTURE)
			ui.HideInaccessibleToggle = c
			c:SetAnchor(LEFT, ui.Sort:GetControl(), RIGHT, 30, 0)
			c:SetDrawLevel(baseDrawLevel + 1100)
			c:SetDimensions(34, 34)
			c:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1.25)
			SetColor(c, Colors.ControlBox)
			c:SetMouseEnabled(false)
			c.Checked = false

			c = WINDOW_MANAGER:CreateControl(nil, ui.HideInaccessibleToggle, CT_LABEL)
			ui.HideInaccessibleToggle.Label = c
			c:SetAnchor(LEFT, ui.HideInaccessibleToggle, RIGHT, -3, -1)
			c:SetDrawLevel(baseDrawLevel + 1110)
			c:SetFont("$(BOLD_FONT)|$(KB_20)|soft-shadow-thick")
			c:SetColor(1, 1, 1, 1)
			c:SetMaxLineCount(1)
			c:SetMouseEnabled(false)
			c:SetText("Hide inaccessible")
			self:SetInfoTooltip(c, "When checked, all homes last known to be inaccessible are hidden from the list")

			ui.HideInaccessibleToggle.RefreshEnabled = function(control)
				local enabled = control.Checked
				if enabled then
					control:SetTexture("esoui/art/cadwell/checkboxicon_checked.dds")
				else
					control:SetTexture("esoui/art/cadwell/checkboxicon_unchecked.dds")
				end

				if control.IsDisabled then
					control.Label:SetColor(0.3, 0.3, 0.3, 1)
					control:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 0.5)
				else
					control.Label:SetColor(1, 1, 1, 1)
					control:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1.25)
				end

				if control.Checked then
					SetColor(control, Colors.Arrow)
				else
					SetColor(control, Colors.ControlBox)
				end

				local mouseEnabled = true ~= control.IsDisabled
				control:SetMouseEnabled(mouseEnabled)
				control.Label:SetMouseEnabled(mouseEnabled)
			end

			ui.HideInaccessibleToggle.Toggle = function(control)
				if control.IsDisabled then
					return
				end

				local enabled = not control.Checked
				self:SetSetting("HousingHubHideInaccessible", enabled)
				control.Checked = enabled
				control:RefreshEnabled()
				self:ShowHousingHubView()
			end
			
			do
				local control = ui.HideInaccessibleToggle
				control.Checked = true == self:GetSetting("HousingHubHideInaccessible")
				control:SetHandler("OnMouseDown", function() control.Toggle(control) end)
				control.Label:SetHandler("OnMouseDown", function() control.Toggle(control) end)
				control:RefreshEnabled()
			end

			do
				local container = WINDOW_MANAGER:CreateControl(nil, ui.WindowFrame, CT_CONTROL)
				ui.StreamingButtonContainer = container
				container:SetHidden(true)
				container:SetAnchorFill()
				container:SetMouseEnabled(false)

				do
					local c = WINDOW_MANAGER:CreateControlFromVirtual("EHHHousingHubGoLiveButton", container, "HousingHubGlowingButton")
					ui.GoLiveButton = c
					c:SetAnchor(TOP, nil, nil, 70, 20)
					c:SetDimensions(120, 26)
					c:SetDrawLevel(1000)
					c:SetText("Go Live...")
					c:SetMouseEnabled(true)
					self:SetInfoTooltip(c, "Let the Community know when your Twitch Stream is about to go live!\n\n" ..
						"All Community members will see a brief notification of your Live Stream that links to your Twitch channel when they log in or change characters.",
						BOTTOM, 0, 0, TOP)
					c:SetHandler("OnMouseDown", function()
						self:ConfirmStreamChannelGoLive()
					end)
				end

				do
					local c = WINDOW_MANAGER:CreateControlFromVirtual("EHHHousingHubEditStreamButton", container, "HousingHubButton")
					ui.EditStreamButton = c
					c:SetAnchor(LEFT, ui.GoLiveButton, RIGHT, 40)
					c:SetDimensions(120, 26)
					c:SetDrawLevel(1000)
					c:SetText("Edit Channel")
					c:SetMouseEnabled(true)
					self:SetInfoTooltip(c, "Setup or change your Twitch channel details.", BOTTOM, 0, 0, TOP)
					c:SetHandler("OnMouseDown", function()
						self:ShowStreamChannelSettings()
					end)
				end

				do
					local c = WINDOW_MANAGER:CreateControlFromVirtual("EHHHousingHubRefreshStreamsButton", container, "HousingHubButton")
					ui.RefreshStreamsButton = c
					c:SetAnchor(RIGHT, ui.GoLiveButton, LEFT, -40)
					c:SetDimensions(120, 26)
					c:SetDrawLevel(1000)
					c:SetText("Refresh List")
					c:SetMouseEnabled(true)
					self:SetInfoTooltip(c, "Refresh the list of streamers and their channel statuses.", BOTTOM, 0, 0, TOP)
					c:SetHandler("OnMouseDown", function()
						ReloadUI()
					end)
				end
			end

			do
				if self.Defs.CategoryFilters.Enabled then
					local c

					c = WINDOW_MANAGER:CreateControl(nil, ui.WindowFrame, CT_TEXTURE)
					ui.CategoryFilterContainer = c
					c:SetAnchor(TOPLEFT, nil, nil, -24, 48)
					c:SetColor(0.1, 0.125, 0.2, 1)
					c:SetDimensionConstraints(0, 26, 800, 26)
					c:SetDrawLevel(1000)
					c:SetDrawTier(DT_LOW)
					c:SetResizeToFitDescendents(true)
					c:SetResizeToFitPadding(40, 0)

					c = WINDOW_MANAGER:CreateControl(nil, ui.CategoryFilterContainer, CT_TEXTURE)
					ui.CategoryFilterShadow = c
					c:SetAnchor(TOPLEFT, nil, nil, 4, 5)
					c:SetAnchor(BOTTOMRIGHT, nil, nil, -4, 5)
					c:SetColor(0, 0, 0, 0.25)
					c:SetDrawLevel(1001)
					c:SetDrawTier(DT_LOW)
					c:SetExcludeFromResizeToFitExtents(true)

					c = WINDOW_MANAGER:CreateControl(nil, ui.CategoryFilterContainer, CT_TEXTURE)
					ui.CategoryFilterOutline = c
					c:SetAnchor(TOPLEFT, nil, nil, -1, -1)
					c:SetAnchor(BOTTOMRIGHT, nil, nil, 1, 1)
					c:SetColor(0, 0, 0, 1)
					c:SetDrawLevel(1002)
					c:SetDrawTier(DT_LOW)
					c:SetExcludeFromResizeToFitExtents(true)

					c = WINDOW_MANAGER:CreateControl(nil, ui.CategoryFilterContainer, CT_TEXTURE)
					ui.CategoryFilterBackdrop = c
					c:SetAnchorFill()
					c:SetColor(0.2, 0.25, 0.5, 1)
					c:SetDrawLevel(1003)
					c:SetDrawTier(DT_LOW)
					c:SetExcludeFromResizeToFitExtents(true)

					c = WINDOW_MANAGER:CreateControlFromVirtual(nil, ui.CategoryFilterContainer, "HousingHubLabelBase")
					ui.CategoryFilterLabel = c
					c:SetDrawLevel(1100)
					c:SetAnchor(LEFT, nil, nil, 24)
					c:SetColor(1, 1, 1, 1)
					c:SetText("Category")
					c:SetWidth(128)

					local categoryFilter = EHH.Picklist:New("EHHHousingHubCategoryFilter", ui.CategoryFilterContainer, LEFT, ui.CategoryFilterLabel, RIGHT, 0, 0, 500, 36)
					ui.CategoryFilter = categoryFilter
					categoryFilter:SetFont("$(MEDIUM_FONT)|$(KB_20)")
					self.openHouseCategoriesDirty = true
					self:RefreshOpenHouseCategoryList()
					categoryFilter:SetDrawLevel(1200)
					categoryFilter:AddHandler("OnSelectionChanged", function(ctl, item)
						local categoryValue
						if item and item.Value then
							categoryValue = item.Value
						end

						local currentView = self:GetHousingHubView()
						if "Open Houses" == currentView then
							self.SelectedHousingHubCategoryFilter = categoryValue
						end

						self:RefreshHousingHub()
					end)
				end
			end
			
			do
				local bb = WINDOW_MANAGER:CreateControlFromVirtual(nil, windowFrame, "HousingHubButton")
				ui.BackButton = bb
				bb:SetHidden(true)
				bb:SetAnchor(LEFT, ui.FilterCriteriaBackdrop, RIGHT, 20, -1)
				bb:SetText("Back to Guilds")
				bb:SetHandler("OnMouseDown", function()
					self:ShowHousingHubView("Guilds")
				end)
			end

			-- Scroll Panel

			c = WINDOW_MANAGER:CreateControl(prefix .. "ScrollPanel", windowFrame, CT_SCROLL)
			ui.ScrollPanel = c
			c:SetAnchor(TOPLEFT, windowFrame, nil, 5, 96)
			c:SetAnchor(BOTTOMRIGHT, windowFrame, nil, -44, -59)
			c:SetMouseEnabled(true)
			c:SetDrawLevel(baseDrawLevel)
			c:SetHandler("OnMouseDown", function(...) return ui.Window:StartMoving(true) end)
			c:SetHandler("OnMouseUp", function(...) return ui.Window:StopMovingOrResizing() end)

			c = WINDOW_MANAGER:CreateControl(prefix .. "ScrollTiles", windowFrame, CT_CONTROL)
			ui.ScrollTiles = c
			c:SetAnchor(TOPLEFT, windowFrame, nil, 5, 96)
			c:SetAnchor(BOTTOMRIGHT, windowFrame, nil, -38, -59)
			c:SetDrawLevel(baseDrawLevel + 1)

			c = WINDOW_MANAGER:CreateControl(prefix .. "ScrollSliderBackground", windowFrame, CT_TEXTURE)
			ui.ScrollSliderBackground = c
			c:SetAnchor(TOPLEFT, ui.ScrollPanel, TOPRIGHT, 12, 18)
			c:SetAnchor(BOTTOMRIGHT, ui.ScrollPanel, BOTTOMRIGHT, 31, -36)
			c:SetColor(0, 0, 0, 0.65)
			c:SetMouseEnabled(false)

			c = WINDOW_MANAGER:CreateControl(prefix .. "ScrollSlider", windowFrame, CT_SLIDER)
			ui.ScrollSlider = c
			self.HubScrollSlider = c
			c:SetWidth(20)
			c:SetAnchor(TOPLEFT, ui.ScrollPanel, TOPRIGHT, 11, 22)
			c:SetAnchor(BOTTOMRIGHT, ui.ScrollPanel, BOTTOMRIGHT, 30, -38)
			c:SetValue(0)
			c:SetValueStep(1)
			c:SetMouseEnabled(true)
			c:SetDrawLevel(baseDrawLevel)
			c:SetAllowDraggingFromThumb(true)
			c:SetThumbTexture("EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 22, 64)
			c:GetThumbTextureControl():SetAlpha(0.55)
			c:SetOrientation(ORIENTATION_VERTICAL)

			local function GetScrollIncrement(shift)
				local numSlots = self.NumHubListEntrySlots
				return (shift or IsShiftKeyDown()) and numSlots or (6 == numSlots and 3 or 2)
			end

			ui.ScrollSlider:SetHandler("OnValueChanged", function(control, value, eventReason)
				self:UpdateHubList(value)
				self:UpdateHubBookmarkWidget()
			end)

			ui.ScrollPanel:SetHandler("OnMouseWheel", function(control, delta, ctrl, alt, shift)
				local slider = ui.ScrollSlider
				local value = slider:GetValue()
				if 0 == value then value = 1 end
				slider:SetValue(value - (delta * GetScrollIncrement(shift)))
			end)

			ui.ScrollSliderUp = self:CreateTextureButton(
				prefix .. "ScrollSliderUpButton",
				ui.ScrollSlider,
				"esoui/art/miscellaneous/gamepad/gp_scrollarrow_up.dds",
				22, 22,
				{ { BOTTOM, ui.ScrollSlider, TOP, 0, 0 } },
				function() local value = ui.ScrollSlider:GetValue() ui.ScrollSlider:SetValue(value - GetScrollIncrement()) end)
			ui.ScrollSliderUp:SetMouseEnabled(true)
			ui.ScrollSliderUp:SetAlpha(0.55)

			ui.ScrollSliderDown = self:CreateTextureButton(
				prefix .. "ScrollSliderDownButton",
				ui.ScrollSlider,
				"esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds",
				22, 22,
				{ { TOP, ui.ScrollSlider, BOTTOM, 0, 0 } },
				function() local value = ui.ScrollSlider:GetValue() if 0 == value then value = 1 end ui.ScrollSlider:SetValue(value + GetScrollIncrement()) end)
			ui.ScrollSliderDown:SetMouseEnabled(true)
			ui.ScrollSliderDown:SetAlpha(0.55)

			-- Hub entry rows

			for index = 1, self.NumHubListTiles do
				self:CreateHubEntryTile(ui, index)
			end

			for index = 1, self.NumHubListRows do
				self:CreateHubEntryRow(ui, index)
			end
			
			for index = 1, self.NumHubListStreamRows do
				self:CreateHubEntryStreamRow(ui, index)
			end

			-- Jump to any Player House

			do
				local help = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)HelpButton", win, "HousingHubButton")
				ui.HelpButton = help
				help:SetAnchor(BOTTOMLEFT, nil, nil, 32, -10)
				help:SetColor(1, 1, 0.65, 1)
				help:SetText("Help")
				help:SetHandler("OnMouseDown", function()
					self:ResetHelp()
					return true
				end)
			end

			c = WINDOW_MANAGER:CreateControl("EHHHubJumpToContainer", ui.WindowFrame, CT_CONTROL)
			ui.JumpToContainer = c
			c:SetDrawLevel(baseDrawLevel)
			c:SetAnchor(BOTTOMRIGHT)
			c:SetDimensions(858, 26)
			c:SetMouseEnabled(false)

			c = WINDOW_MANAGER:CreateControl(nil, ui.JumpToContainer, CT_TEXTURE)
			ui.JumpToShadow = c
			c:SetAnchor(TOPLEFT, nil, nil, 4, 5)
			c:SetAnchor(BOTTOMRIGHT, nil, nil, -4, 5)
			c:SetColor(0, 0, 0, 0.25)
			c:SetDrawLevel(0)
			c:SetMouseEnabled(false)

			c = WINDOW_MANAGER:CreateControl(nil, ui.JumpToContainer, CT_TEXTURE)
			ui.JumpToOutline = c
			c:SetAnchor(TOPLEFT, nil, nil, -1, -1)
			c:SetAnchor(BOTTOMRIGHT, nil, nil, 1, 1)
			c:SetColor(0, 0, 0, 1)
			c:SetDrawLevel(0)
			c:SetMouseEnabled(false)

			c = WINDOW_MANAGER:CreateControl(nil, ui.JumpToContainer, CT_TEXTURE)
			ui.JumpToBackdrop = c
			c:SetAnchorFill()
			c:SetColor(0.2, 0.25, 0.5, 1)
			c:SetDrawLevel(0)
			c:SetMouseEnabled(false)

			do
				local c = WINDOW_MANAGER:CreateControlFromVirtual("HousingHubJumpToContainerLabel", ui.JumpToContainer, "HousingHubLabelBase")
				ui.JumpToContainerLabel = c
				c:SetDrawLevel(baseDrawLevel + 1010)
				c:SetAnchor(LEFT, nil, nil, 15)
				c:SetColor(1, 1, 1, 1)
				c:SetText("Favorite or Jump to")
			end

			do
				local outer = CreateTexture(nil, ui.JumpToContainer, CreateAnchor(LEFT, ui.JumpToContainerLabel, RIGHT, 13), CreateAnchor(RIGHT, ui.JumpToContainerLabel, RIGHT, 213), 200, 36, Textures.Solid, Colors.ControlBox)
				local inner = CreateTexture(nil, outer, CreateAnchor(TOPLEFT, outer, TOPLEFT, 1, 1), CreateAnchor(BOTTOMRIGHT, outer, BOTTOMRIGHT, -1, -1), 198, 32, Textures.Solid, Colors.ControlBackdrop)
				ui.JumpToPlayerBackdrop = inner
			end

			c = WINDOW_MANAGER:CreateControlFromVirtual("EHHJumpToPlayerEdit", ui.JumpToPlayerBackdrop, "ZO_DefaultEditForBackdrop")
			ui.JumpToPlayer = c
			c:SetFont("$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thin")
			c:SetDrawLevel(baseDrawLevel + 1010)
			c:ClearAnchors()
			c:SetAnchor(LEFT, ui.JumpToPlayerBackdrop, nil, 4)
			c:SetAnchor(RIGHT, ui.JumpToPlayerBackdrop, nil, -4)
			c:SetMaxInputChars(64)
			c:SetMouseEnabled(true)
			c:SetText(VISIT_PLAYER_TEXT)
			c:SetHandler("OnMouseUp", function()
				zo_callLater(function() ui.JumpToPlayer:SelectAll() end, 50)
			end)

			do
				local playerIndex, playerList, playerNameList, playerHighlightList

				local function GetNumPlayers()
					return zo_clamp(playerList and #playerList or 0, 0, 25)
				end

				c = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
				ui.JumpToPlayerList = c
				c:SetHidden(true)
				c:SetDrawLevel(baseDrawLevel + 1000)
				c:SetDrawTier(DT_HIGH)
				c:SetDrawLayer(DL_OVERLAY)
				c:SetAnchor(TOPLEFT, ui.JumpToPlayerBackdrop, BOTTOMLEFT, 0, 2)
				c:SetAnchor(TOPRIGHT, ui.JumpToPlayerBackdrop, BOTTOMRIGHT, 200, 2)
				c:SetTexture(Textures.Solid)
				c:SetColor(0.2, 0.2, 0.2, 1)
				c:SetMouseEnabled(false)

				playerHighlightList, playerNameList = {}, {}

				for index = 0, 24 do
					c = WINDOW_MANAGER:CreateControl(nil, ui.JumpToPlayerList, CT_TEXTURE)
					table.insert(playerHighlightList, c)
					c:SetHidden(true)
					c:SetDrawLevel(baseDrawLevel + 1001)
					c:SetDrawTier(DT_HIGH)
					c:SetDrawLayer(DL_OVERLAY)
					c:SetAnchor(TOPLEFT, ui.JumpToPlayerList, TOPLEFT, 8, 8 + 24 * index)
					c:SetAnchor(BOTTOMRIGHT, ui.JumpToPlayerList, TOPRIGHT, -8, 34 + 24 * index)
					c:SetColor(0, 0, 0, 0.5)
					c:SetMouseEnabled(false)
				end

				for index = 0, 24 do
					c = WINDOW_MANAGER:CreateControl(nil, ui.JumpToPlayerList, CT_LABEL)
					table.insert(playerNameList, c)
					c:SetDrawLevel(baseDrawLevel + 1002)
					c:SetDrawTier(DT_HIGH)
					c:SetDrawLayer(DL_OVERLAY)
					c:SetFont("$(MEDIUM_FONT)|$(KB_16)")
					c:SetAnchor(TOPLEFT, ui.JumpToPlayerList, TOPLEFT, 10, 10 + 24 * index)
					c:SetAnchor(BOTTOMRIGHT, ui.JumpToPlayerList, TOPRIGHT, -10, 32 + 24 * index)
					c:SetColor(1, 1, 1, 1)
					c:SetText("")
					c:SetMaxLineCount(1)
					c:SetMouseEnabled(true)
					c:SetHandler("OnMouseDown", function()
						local name = playerList and playerList[ index + 1 ]
						if name then
							ui.JumpToPlayer:SetText(name)
							ui.JumpToPlayerList:SetHidden(true)
						end
					end)
				end

				local function JumpToPlayerOnFocusLost()
					ui.JumpToPlayerList:SetHidden(true)

					local search = self:Trim(ui.JumpToPlayer:GetText())
					if search == "" then
						ui.JumpToPlayer:SetText(VISIT_PLAYER_TEXT)
					end
				end

				ui.JumpToPlayer:SetHandler("OnFocusLost", JumpToPlayerOnFocusLost)

				ui.JumpToPlayer:SetHandler("OnDownArrow", function()
					if not playerList then
						return
					end

					if not playerIndex then
						playerIndex = 0
					end

					if playerIndex + 1 <= GetNumPlayers() then
						playerIndex = playerIndex + 1
					end

					for index = 1, #playerHighlightList do
						playerHighlightList[ index ]:SetHidden(index ~= playerIndex)
					end
				end)

				ui.JumpToPlayer:SetHandler("OnUpArrow", function()
					if not playerList then
						return
					end

					if not playerIndex then
						playerIndex = 0 < #playerList and 1 or 0
					end

					if playerIndex - 1 > 0 and playerIndex - 1 <= GetNumPlayers() then
						playerIndex = playerIndex - 1
					end

					for index = 1, #playerHighlightList do
						playerHighlightList[ index ]:SetHidden(index ~= playerIndex)
					end
				end)

				ui.JumpToPlayer:SetHandler("OnEnter", function()
					ui.JumpToPlayer:LoseFocus()

					if not playerList then
						return
					end

					if not playerIndex or 0 == playerIndex or playerIndex > GetNumPlayers() then
						return
					end

					ui.JumpToPlayer:SetText(playerList[ playerIndex ])
					ui.JumpToPlayerList:SetHidden(true)
				end)

				local function OnTextChanged()
					local search = self:Trim(ui.JumpToPlayer:GetText())
					if search ~= "" and string.sub(search, 1, 1) ~= "@" and string.lower(search) ~= string.lower(VISIT_PLAYER_TEXT) then
						search = "@" .. search
						ui.JumpToPlayer:SetText(search)
					end

					playerIndex = nil
					playerList = nil

					if search and 2 <= #search then
						--local matches = self:GetMatchingGuildMemberNames(search)
						local matches = self:GetMatchingPlayerNames(search)
						if matches then
							playerList = {}

							for name in pairs(matches) do
								table.insert(playerList, name)
							end

							table.sort(playerList, CaseInsensitiveStringComparer)
						end
					end

					if not playerList or 0 >= #playerList then
						ui.JumpToPlayerList:SetHidden(true)
						return
					end

					for index = 1, #playerHighlightList do
						playerHighlightList[index]:SetHidden(true)
					end

					for index = 1, #playerNameList do
						local name = playerList[index]
						if name then
							playerNameList[index]:SetText(name)
						else
							playerNameList[index]:SetText("")
						end
					end

					ui.JumpToPlayerList:SetHeight(18 + 24 * GetNumPlayers())
					ui.JumpToPlayerList:SetHidden(false)
				end

				ui.JumpToPlayer:SetHandler("OnTextChanged", OnTextChanged)
				ui.JumpToPlayer:SetHandler("OnFocusGained", OnTextChanged)
			end

			do
				local list = EHH.Picklist:New("EHHHousingHubJumpToHouseList", ui.JumpToContainer, LEFT, ui.JumpToPlayerBackdrop, RIGHT, 10, 0, 245, 36)
				local control = list:GetControl()
				ui.JumpToHouseList = list
				control:SetDrawLevel(baseDrawLevel)
				list:SetSorted(false)
				list:SetFont("$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thin")

				local houses = {}
				for _, house in pairs(self:GetAllHouses()) do
					table.insert(houses, house)
				end
				table.sort(houses, function(left, right) return left.Name < right.Name end)
				table.insert(houses, 1, { Id = 0, Name = "Primary House" })

				for _, house in ipairs(houses) do
					list:AddItem(house.Name, nil, house)
				end
				list:SelectFirstItem()
			end

			c = WINDOW_MANAGER:CreateControlFromVirtual("EHHHousingHubVisitButton", ui.JumpToContainer, "HousingHubButton")
			ui.JumpToButton = c
			c:SetDrawLevel(baseDrawLevel)
			c:SetAnchor(LEFT, ui.JumpToHouseList:GetControl(), RIGHT, 24)
			c:SetText("Visit")
			c:SetMouseEnabled(true)
			self:SetInfoTooltip(c, "Travel to this home", BOTTOM, 0, 0, TOP)
			c:SetHandler("OnMouseDown", function()
				local player = self:Trim(ui.JumpToPlayer:GetText())
				if not player or "" == player or player == VISIT_PLAYER_TEXT or "@" ~= string.sub(player, 1, 1) then
					self:DisplayNotification("Please enter the |cffff66@name|r of the owner to jump to.")
					return
				end

				local houseName = ui.JumpToHouseList:GetSelectedItem()
				local houseId
				if houseName == "Primary House" then
					houseId = 0
				else
					local house = self:GetHouseByName(houseName)
					houseId = house and house.Id
				end

				if not houseId then
					self:DisplayNotification("Select a specific house or choose Primary Home.")
					return
				end

				if 0 == houseId then
					self:VisitHubEntry(player)
				else
					self:VisitHubEntry(player, houseId)
				end
			end)

			c = WINDOW_MANAGER:CreateControlFromVirtual("EHHHousingHubFavoriteButton", ui.JumpToContainer, "HousingHubButton")
			ui.AddFavoriteButton = c
			c:SetDrawLevel(baseDrawLevel)
			c:SetAnchor(LEFT, ui.JumpToButton, RIGHT, 34)
			c:SetText("Add Favorite")
			c:SetMouseEnabled(true)
			self:SetInfoTooltip(c, "Add this home to your Favorites list", BOTTOM, 0, 0, TOP)
			c:SetHandler("OnMouseDown", function()
				local player = ui.JumpToPlayer:GetText()

				if not player or "" == player or "@" ~= string.sub(player, 1, 1) or player == VISIT_PLAYER_TEXT then
					self:DisplayNotification("Please enter the |cffff66@name|r of the owner.")
					return
				end

				local houseName = ui.JumpToHouseList:GetSelectedItem()
				local houseId
				if houseName == "Primary House" then
					houseId = 0
				else
					local house = self:GetHouseByName(houseName)
					houseId = house and house.Id
				end

				if not houseId then
					self:DisplayNotification("Select a specific house or choose Primary Home")
					return
				end

				if 0 == houseId then houseId = nil end
				local world = self:GetWorldCode()

				if self:AddOrUpdateFavoriteHouse(world, houseId, player) then
					self:DisplayNotification("Favorite added.")
					self:RefreshHousingHub()
				else
					self:DisplayNotification("Failed to add favorite.")
				end
			end)

			-- c = WINDOW_MANAGER:CreateControl(nil, ui.TabButtonBar, CT_TEXTURE)
			c = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
			ui.EHHTitle = c
			c:SetTexture(Textures.HOUSING_HUB_LOGO)
			c:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
			-- c:SetAnchor(RIGHT, nil, nil, -8)
			c:SetAnchor(TOPLEFT, nil, TOPRIGHT, -114, 9)
			c:SetColor(1, 1, 1, 1)
			c:SetDrawLevel(baseDrawLevel)
			c:SetDimensions(136, 52)
			c:SetTextureCoords(0, 128/256, 0, 50/64)
			c:SetScale(0.8)
			c:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1.3)

			c = CreateLabel(nil, ui.EHHTitle, string.format("v %s", tostring(self.AddOnVersion)), CreateAnchor(BOTTOMRIGHT, nil, nil, -12, -4))
			ui.EHHVersionNumber = c
			SetLabelFont(c, 16, true, false)
			c:SetColor(1, 1, 1, 1)

			do
				local c = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)PreferTilesButton", win, "HousingHubTexture")
				ui.PreferTilesButton = c
				c:SetHidden(true)
				-- c:SetAnchor(CENTER, nil, TOPRIGHT, -97, 28)
				c:SetAnchor(CENTER, nil, TOPRIGHT, -97, 78)
				c:SetDrawLayer(DL_CONTROLS)
				c:SetDimensions(28, 28)
				c:SetMouseEnabled(true)
				c:SetTexture(Textures.ICON_LIST_TILES)
				c:SetHandler("OnMouseDown", function()
					self:SetPreferredHubListControls("tiles")
					return true
				end)
				tip(c, "Show the list as Tiles", TOP, 0, 10, BOTTOM)
			end

			do
				local c = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)PreferRowsButton", win, "HousingHubTexture")
				ui.PreferRowsButton = c
				c:SetHidden(true)
				-- c:SetAnchor(CENTER, nil, TOPRIGHT, -61, 28)
				c:SetAnchor(CENTER, nil, TOPRIGHT, -61, 78)
				c:SetDrawLayer(DL_CONTROLS)
				c:SetDimensions(28, 28)
				c:SetMouseEnabled(true)
				c:SetTexture(Textures.ICON_LIST_ROWS)
				c:SetHandler("OnMouseDown", function()
					self:SetPreferredHubListControls("rows")
					return true
				end)
				tip(c, "Show the list as Rows", TOP, 0, 10, BOTTOM)
			end

			-- Notifications

			ui.NotificationPanels = {}
			ui.VisibleNotificationPanels = {}

			do
				local c = WINDOW_MANAGER:CreateControl("EHHNotificationContainer", ui.Window, CT_CONTROL)
				ui.NotificationContainer = c

				c:SetAnchor(TOPLEFT, ui.Window, TOPLEFT, -255, 55)
				c:SetAnchor(BOTTOMRIGHT, ui.Window, BOTTOMLEFT, -20, 0)
				c:SetMouseEnabled(false)
			end

			do
				local c = WINDOW_MANAGER:CreateControlFromVirtual("EHHDragAndDropFavoritesButton", ui.NotificationContainer, "HousingHubButtonPanel")
				ui.NotificationPanels["DragAndDropFavorites"] = c

				c:SetHidden(true)
				c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				c:SetMaxLineCount(20)
				c:SetWidth(235)
				c:SetText("Now you can easily reorder your Favorites.\n\n" ..
					"Choose |cffff00Manual|r sorting at the top, " ..
					"then drag the tiles to organize them." ..
					"\n|ar|cffff88Tip   " .. self.Textures.ICON_NOTIFICATION)

				c.Backdrop:SetHandler("OnMouseDown", function()
					self:DismissNotification("DragAndDropFavorites")
					return true
				end, "DismissNotification")
			end

			do
				local c = WINDOW_MANAGER:CreateControlFromVirtual("EHHHowToAddFavoritesTip", ui.NotificationContainer, "HousingHubButtonPanel")
				ui.NotificationPanels["HowToAddFavorites"] = c

				c.AnchorToSide = BOTTOM
				c:SetHidden(true)
				c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				c:SetMaxLineCount(20)
				c:SetWidth(235)
				c:SetText("Track your favorite homes and keep notes on any home that you visit. To get started...\n\n" ..
					"Click " .. zo_iconFormat(self.Textures.ICON_FAVORITE_DISABLED, 20, 20) .. " on your favorite homes in any tab\n\n" ..
					"Or type a @player name and choose a home down here " .. self.Textures.INLINE_ICON_FORWARD_ARROW .. " and click |cffff00Add Favorite|r" ..
					"\n|ar|cffff88Tip   " .. self.Textures.ICON_NOTIFICATION)

				c.Backdrop:SetHandler("OnMouseDown", function()
					self:DismissNotification("HowToAddFavorites")
					return true
				end, "DismissNotification")
			end

			do
				local c = WINDOW_MANAGER:CreateControlFromVirtual("EHHHowToAddHomeNotesTip", ui.NotificationContainer, "HousingHubButtonPanel")
				ui.NotificationPanels["HowToAddHomeNotes"] = c

				c:SetHidden(true)
				c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				c:SetMaxLineCount(20)
				c:SetWidth(235)
				c:SetText("Keep notes on any home from any tab.\n\n" ..
					"Just click the bottom of a home's tile, type a brief note and press enter." ..
					"\n|ar|cffff88Tip   " .. self.Textures.ICON_NOTIFICATION)

				c.Backdrop:SetHandler("OnMouseDown", function()
					self:DismissNotification("HowToAddHomeNotes")
					return true
				end, "DismissNotification")
			end

			do
				local c = WINDOW_MANAGER:CreateControlFromVirtual("EHHInstallCommunityAppButton", ui.NotificationContainer, "HousingHubLabelPanel")
				ui.NotificationPanels["InstallCommunityApp"] = c

				c:SetHidden(true)
				c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				c:SetMaxLineCount(20)
				c:SetWidth(235)
				c:SetText("Join thousands of players in The Elder Scrolls Online's largest Housing Community.\n\n" ..
					"As a Community member you will be able to tour other players' open houses, " ..
					"list your own and see who stopped by - all from the Housing Hub.\n" ..
					"\n|ar|cffff88Click for more info   " .. self.Textures.ICON_NOTIFICATION)

				c.Backdrop:SetHandler("OnMouseDown", function()
					self:ShowHelpTopic("CommunityApp")
					return true
				end, "Notification")
			end

			do
				local c = WINDOW_MANAGER:CreateControlFromVirtual("EHHUpdateDecoTrackButton", ui.NotificationContainer, "HousingHubLabelPanel")
				ui.NotificationPanels["UpdateDecoTrack"] = c

				c:SetHidden(true)
				c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				c:SetMaxLineCount(20)
				c:SetWidth(235)
				c:SetText("DecoTrack needs to visit one or more homes to complete its database.\n\n" ..
					"|ar|cffff88Click to update now   " .. self.Textures.ICON_NOTIFICATION)

				c.Backdrop:SetHandler("OnMouseDown",
					function()
						self:ShowConfirmationDialog(
							"Automatically visit each of your homes now in order to update DecoTrack's database of your furnishings?",
							function()
								self:DecoTrackVisitAllHomes()
								return true
							end)
					end, "DecoTrack")

				local tooltipText = "|cffff88" ..
					"As long as DecoTrack remains enabled for all of your characters, all of your furniture items - and their location - are tracked. Each home that you own will need to be visited though in order for DecoTrack to build its initial database.\n\n" ..
					"|cffffff" ..
					"It seems as though you have recently installed DecoTrack or purchased a new home. " ..
					"Your furniture database can be updated automatically for each home that you own.\n\n" ..
					"Click to get started or just type...\n" ..
					"|c00ffff/deco update|cffffff"
				tip(c, tooltipText, TOPRIGHT, -12, 0, TOPLEFT)
			end
			
			do
				local c = WINDOW_MANAGER:CreateControlFromVirtual("EHHLiveStreamChannelSetupNotification", ui.NotificationContainer, "HousingHubLabelPanel")
				ui.NotificationPanels["LiveStreamChannelSetup"] = c

				c:SetHidden(true)
				c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				c:SetMaxLineCount(20)
				c:SetWidth(235)
				c:SetText("Do you |cffff44Stream on Twitch|r?\n" ..
					"Let the Community know when you are live and grow your channel!\n" ..
					"\n|ar|cffff88Click for more info   " .. self.Textures.ICON_NOTIFICATION)

				c.Backdrop:SetHandler("OnMouseDown", function()
					self:ShowStreamChannelSettings()
					self:DismissNotification("LiveStreamChannelSetup")
					return true
				end, "Notification")
			end

			do
				local widget = WINDOW_MANAGER:CreateControlFromVirtual("HousingHubBookmarkWidget", ui.Window, "HousingHubFramedOpaqueLabel24")
				self.HubBookmarkWidget = widget
				widget:SetHidden(true)
				widget:SetAlpha(0)
				widget:SetClampedToScreen(true)
				widget:SetDimensionConstraints(0, 0, 200, 150)
				widget:SetMaxLineCount(3)
				widget:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
				widget.LastUpdate = 0

				widget.Backdrop = widget:GetNamedChild("Backdrop")
				widget.Backdrop:SetDrawTier(1000)
				widget.Backdrop:SetDrawLayer(DL_CONTROLS)
				widget.Backdrop:SetDrawLevel(200000)

				widget:SetDrawTier(1000)
				widget:SetDrawLayer(DL_TEXT)
				widget:SetDrawLevel(200001)
				
				function EHH_HubBookmarkWidget_OnUpdate()
					local idleMS = GetFrameTimeMilliseconds() - widget.LastUpdate
					local interval = (idleMS - 1750) / 750
					if 0 > interval then
						return
					end
					widget:SetAlpha(1 - interval)
					if 1 <= interval then
						widget:SetHidden(true)
						EVENT_MANAGER:UnregisterForUpdate("EssentialHousingHub.HubBookmarkWidget")
					end
				end
			end

			self:ShowHousingHubView()
		end

		return ui
	end

	local function HubEntrySupportsNotes(control)
		local data = control.Data
		if data then
			return (tonumber(data.HouseId) or (data.Owner or "") ~= "") and not (data.GuildIndex or data.FurnitureLink)
		end
		return false
	end

	function EHH:CreateHubEntryTile(ui, index)
		local control = WINDOW_MANAGER:CreateControlFromVirtual(string.format("EHHHubListEntryTile%d", index), ui.ScrollTiles, "HousingHubTile")
		self.HubListTiles[index] = control
		control.Data = {}
		control.IsStreamRow = nil
		control.BaseAnimationOffset = index * 600

		local SIZE_X, SIZE_Y = 289, 179
		local SPACING_X, SPACING_Y = 40, 48
		local HALF_SIZE_X, HALF_SIZE_Y = 0.5 * SIZE_X, 0.5 * SIZE_Y
		local anchorToColumn = ((index - 1) % self.NumHubListEntryColumns)
		local anchorToRow = math.floor((index - 1) / self.NumHubListEntryColumns)
		local controlOffsetX = 0.5 * SPACING_X + HALF_SIZE_X + (SIZE_X + SPACING_X) * anchorToColumn
		local controlOffsetY = 0.5 * SPACING_Y + (SIZE_Y + SPACING_Y) * anchorToRow
		control:SetAnchor(TOP, nil, TOPLEFT, controlOffsetX, controlOffsetY)
		control.BaseAnchorOffsetX, control.BaseAnchorOffsetY = controlOffsetX, controlOffsetY

		tip(control.ItemsQuantity, function(c) return c.DynamicTooltipData end, TOPRIGHT, 0, 24, BOTTOMRIGHT)
		tip(control.ItemsQuantifier, function(c) return c.DynamicTooltipData end, TOPRIGHT, 0, 24, TOPRIGHT)

		local function OnDescriptionMouseDown(...)
			return OnHubEntryDescriptionMouseDown(self, ...)
		end

		control.Caption1:SetHandler("OnMouseDown", OnDescriptionMouseDown)
		control.Caption2:SetHandler("OnMouseDown", OnDescriptionMouseDown)
		control.Caption3:SetHandler("OnMouseDown", OnDescriptionMouseDown)
		control.Caption4:SetHandler("OnMouseDown", OnDescriptionMouseDown)

		control.NoteEdit:SetHandler("OnFocusLost", function()
			control.SaveNote()
		end)
		control.NoteEdit:SetHandler("OnKeyUp", function(c, key, ctrl, alt, sh, cmd)
			if key == KEY_ENTER then
				control.SaveNote()
			end
		end)

		do
			local c = control.NoteLabel
			c:SetHandler("OnMouseDown", function()
				control.EditNote()
				return true
			end)
			c:SetHandler("OnMouseEnter", function()
				if c.InfoTooltipMessage and c.InfoTooltipMessage ~= "" then
					if c:WasTruncated() then
						self:ShowControlTooltip(InformationTooltip, c, TOP, 0, 5, BOTTOM)
					end
				end
			end)
			c:SetHandler("OnMouseExit", function()
				WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
				EssentialHousingHub:HideTooltip(InformationTooltip)
			end)
		end

		control.RefreshNote = function()
			if not control.Data.VisitDate and HubEntrySupportsNotes(control) then
				local note, noteDate = "", nil
				local noteData = self:GetHouseNote(self.World, control.Data.HouseId, control.Data.Owner)
				if "table" == type(noteData) then
					note, noteDate = noteData.Note or "", noteData.Date
				end

				control.NoteEdit:SetText(note)
				if not note or "" == note then
					note = "Add private notes..."
					control.NoteLabel.IsEmpty = true
					control.NoteLabel.InfoTooltipMessage = ""
					control.NoteLabel:SetAlpha(control.IsFocusTile and 1 or 0)
				else
					control.NoteLabel.IsEmpty = false
					control.NoteLabel.InfoTooltipMessage = note
					control.NoteLabel:SetAlpha(1)
				end
				control.NoteLabel:SetText(note)
				control.SetNoteHidden(false)
			else
				control.SetNoteHidden(true)
			end
		end

		control.SetNoteHidden = function(hidden)
			if not hidden and not HubEntrySupportsNotes(control) then
				hidden = true
			end
			control.NoteEditBackdrop:SetHidden(true)
			control.NoteLabel:SetHidden(hidden)
		end

		control.EditNote = function()
			control.NoteLabel:SetHidden(true)
			control.NoteEditBackdrop:SetHidden(false)
			control.NoteEdit:TakeFocus()
		end

		control.SaveNote = function()
			if not control.NoteEditBackdrop:IsHidden() then
				local note = self:Trim(control.NoteEdit:GetText() or "")
				if note == "" or note == "Add private notes..." then
					note = nil
				end
				if HubEntrySupportsNotes(control) then
					local noteData = note and { Note = note, Date = GetTimeStamp() } or nil
					self:SetHouseNote(self.World, control.Data.HouseId, control.Data.Owner, noteData)
					self:InvalidateHubList("Open Houses")
					self:InvalidateHubList("Favorites")
				end
				control.NoteEditBackdrop:SetHidden(true)
				control.NoteLabel:SetHidden(false)
				control.RefreshNote()
			end
		end

		control.TagCount = 0
		control.Tags = {}

		for tagIndex = 1, 14 do
			c = WINDOW_MANAGER:CreateControlFromVirtual(string.format("HubTileTag_%d_%d", index, tagIndex), control.TagContainer, "HousingHubOpaqueLabel15WithTooltip")
			control.Tags[tagIndex] = c
			c.TagIndex = tagIndex

			c:SetHidden(true)
			c:SetColor(1, 1, 1, 1)
			c:SetDimensions(134, 20)
			c:SetFont("$(MEDIUM_FONT)|$(KB_15)")
			c:SetMouseEnabled(true)

			c:SetHandler("OnMouseDown", function(...)
				OnHubEntryDescriptionMouseDown(self, ...)
				return true
			end)

			c:SetHandler("OnMouseEnter", function(ctl, ...)
				if ctl.HouseId then
					WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_UI_HAND)
				end

				local parent = ctl:GetParent()
				local handler = parent:GetHandler("OnMouseEnter", "BubbleControlEvent")
				if handler then
					handler(parent, ...)
				end
			end, "Tag")

			c:SetHandler("OnMouseExit", function(ctl, ...)
				if ctl.HouseId then
					WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
				end

				local parent = ctl:GetParent()
				local handler = parent:GetHandler("OnMouseExit", "BubbleControlEvent")
				if handler then
					handler(parent, ...)
				end
			end, "Tag")
		end

		control.ClearTags = function()
			for tagIndex = 1, control.TagCount do
				control.Tags[tagIndex]:SetHidden(true)
			end

			control.TagCount = 0
		end

		control.AddTag = function(container)
			local label = container.FormattedLabel
			local containerName = container.Name

			if not label or not containerName then
				return false
			end

			local houses = self:FindHousesByName(containerName)
			local houseId

			if houses and houses[1] then
				houseId = houses[1].Id
			end

			local tagIndex = control.TagCount + 1
			local tag = control.Tags[tagIndex]

			if tag then
				local column = tagIndex <= 7 and 1 or 2
				local row = tagIndex <= 7 and tagIndex or (tagIndex - 7)

				control.TagCount = tagIndex
				tag.HouseId = houseId
				tag:SetText(label)
				tag:ClearAnchors()

				if row > 1 then
					tag:SetAnchor(BOTTOMLEFT, control.Tags[tagIndex - 1], TOPLEFT, 0, -1)
				else
					if 1 == column then
						tag:SetAnchor(BOTTOMLEFT, control.TagContainer, BOTTOMLEFT, 0, 0)
					else
						tag:SetAnchor(BOTTOMLEFT, control.TagContainer, BOTTOM, 3, 0)
					end
				end

				tag:SetHidden(false)
				return true
			end
			
			return false
		end

		control.Favorite:SetHandler("OnMouseDown", function()
			self:ToggleFavoriteHubEntry(control)
			return true
		end)
		control.Favorite:SetHandler("OnMouseEnter", OnHubShortcutMouseEnter)
		control.Favorite:SetHandler("OnMouseExit", OnHubShortcutMouseExit)
		OnHubShortcutMouseExit(control.Favorite)
		tip(control.Favorite, "Toggle this home as a Favorite", TOP, 0, 36, BOTTOM)

		control.ShareLink:SetHandler("OnMouseDown", function()
			self:ShareHubHouseLink(control)
			return true
		end)
		control.ShareLink:SetHandler("OnMouseEnter", OnHubShortcutMouseEnter)
		control.ShareLink:SetHandler("OnMouseExit", OnHubShortcutMouseExit)
		OnHubShortcutMouseExit(control.ShareLink)
		tip(control.ShareLink, "Share a link to this home\n\nEssential Housing Tools or\nHousing Hub required", TOP, 0, 36, BOTTOM)
		
		control.ShareFurnitureLink:SetHandler("OnMouseDown", function()
			self:ShareHubFurnitureLink(control)
			return true
		end)
		control.ShareFurnitureLink:SetHandler("OnMouseEnter", OnHubShortcutMouseEnter)
		control.ShareFurnitureLink:SetHandler("OnMouseExit", OnHubShortcutMouseExit)
		OnHubShortcutMouseExit(control.ShareFurnitureLink)
		tip(control.ShareFurnitureLink, "Paste item link in chat", TOP, 0, 36, BOTTOM)

		control.VisitButton:SetHandler("OnMouseDown", function()
			self:VisitHubEntry(control)
			return true
		end)
		control.VisitButton:SetHandler("OnMouseEnter", OnHubShortcutMouseEnter)
		control.VisitButton:SetHandler("OnMouseExit", OnHubShortcutMouseExit)
		OnHubShortcutMouseExit(control.VisitButton)
		tip(control.VisitButton, "Travel to this home", TOP, 0, 36, BOTTOM)

		control.OpenHouse:SetHandler("OnMouseDown", function()
			if not control.OpenHouse.IsDisabled then
				self:ToggleOpenHouseHubEntry(control)
			else
				if "streamrow" == self.TileType then
					self:OnHubStreamTileMouseDown(control)
				else
					self:OnHubTileMouseDown(control)
				end
			end
			return true
		end)
		control.ClosedHouse:SetHandler("OnMouseDown", function()
			if not control.ClosedHouse.IsDisabled then
				self:ToggleOpenHouseHubEntry(control)
			else
				if "streamrow" == self.TileType then
					self:OnHubStreamTileMouseDown(control)
				else
					self:OnHubTileMouseDown(control)
				end
			end
			return true
		end)
		control.ShareFXButton:SetHandler("OnMouseDown", function()
			if not control.ShareFXButton.IsDisabled then
				self:ShareFXHubEntry(control)
			else
				if "streamrow" == self.TileType then
					self:OnHubStreamTileMouseDown(control)
				else
					self:OnHubTileMouseDown(control)
				end
			end
			return true
		end)

		self:EnableEnhancedMouseOverBehaviorForControlGraph(control, true)
		return control
	end

	function EHH:CreateHubEntryRow(ui, index)
		local control = WINDOW_MANAGER:CreateControlFromVirtual(string.format("EHHHubListEntryRow%d", index), ui.ScrollTiles, "HousingHubRow")
		self.HubListRows[index] = control
		control.Data = {}
		control.IsStreamRow = nil

		local SIZE_X, SIZE_Y = 960, 82
		local SPACING_Y = 10
		local HALF_SIZE_X, HALF_SIZE_Y = 0.5 * SIZE_X, 0.5 * SIZE_Y
		local anchorToRow = index - 1
		local controlOffsetX = 10
		local controlOffsetY = (SIZE_Y + SPACING_Y) * anchorToRow
		control:SetAnchor(TOPLEFT, nil, nil, controlOffsetX, controlOffsetY)

		tip(control.ItemsQuantity, function(c) return c.DynamicTooltipData end, TOPRIGHT, 0, 24, BOTTOMRIGHT)
		tip(control.ItemsQuantifier, function(c) return c.DynamicTooltipData end, TOPRIGHT, 0, 24, TOPRIGHT)

		local function OnDescriptionMouseDown(...)
			return OnHubEntryDescriptionMouseDown(self, ...)
		end

		control.Caption1:SetHandler("OnMouseDown", OnDescriptionMouseDown)
		control.Caption2:SetHandler("OnMouseDown", OnDescriptionMouseDown)
		control.Caption3:SetHandler("OnMouseDown", OnDescriptionMouseDown)
		control.Caption4:SetHandler("OnMouseDown", OnDescriptionMouseDown)

		control.NoteEdit:SetHandler("OnFocusLost", function()
			control.SaveNote()
		end)
		control.NoteEdit:SetHandler("OnKeyUp", function(c, key, ctrl, alt, sh, cmd)
			if key == KEY_ENTER then
				control.SaveNote()
			end
		end)

		do
			local c = control.NoteLabel
			c:SetHandler("OnMouseDown", function()
				control.EditNote()
				return true
			end)
			c:SetHandler("OnMouseEnter", function()
				if c.InfoTooltipMessage and c.InfoTooltipMessage ~= "" then
					if c:WasTruncated() then
						self:ShowControlTooltip(InformationTooltip, c, TOP, 0, 5, BOTTOM)
					end
				end
			end)
			c:SetHandler("OnMouseExit", function()
				WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
				EssentialHousingHub:HideTooltip(InformationTooltip)
			end)
		end

		control.RefreshNote = function()
			if not control.Data.VisitDate and HubEntrySupportsNotes(control) then
				local note, noteDate = "", nil
				local noteData = self:GetHouseNote(self.World, control.Data.HouseId, control.Data.Owner)
				if "table" == type(noteData) then
					note, noteDate = noteData.Note or "", noteData.Date
				end

				control.NoteEdit:SetText(note)
				if not note or "" == note then
					note = "Add private notes..."
					control.NoteLabel.IsEmpty = true
					control.NoteLabel.InfoTooltipMessage = ""
					control.NoteLabel:SetAlpha(0)
				else
					control.NoteLabel.IsEmpty = false
					control.NoteLabel.InfoTooltipMessage = note
					control.NoteLabel:SetAlpha(1)
				end
				control.NoteLabel:SetText(note)
				control.SetNoteHidden(false)
			else
				control.SetNoteHidden(true)
			end
		end

		control.SetNoteHidden = function(hidden)
			if not hidden and not HubEntrySupportsNotes(control) then
				hidden = true
			end
			control.NoteEditBackdrop:SetHidden(true)
			control.NoteLabel:SetHidden(hidden)
		end

		control.EditNote = function()
			control.NoteLabel:SetHidden(true)
			control.NoteEditBackdrop:SetHidden(false)
			control.NoteEdit:TakeFocus()
		end

		control.SaveNote = function()
			if not control.NoteEditBackdrop:IsHidden() then
				local note = self:Trim(control.NoteEdit:GetText() or "")
				if note == "" or note == "Add private notes..." then
					note = nil
				end
				if HubEntrySupportsNotes(control) then
					local noteData = note and {Note = note, Date = GetTimeStamp()} or nil
					self:SetHouseNote(self.World, control.Data.HouseId, control.Data.Owner, noteData)
					self:InvalidateHubList("Open Houses")
					self:InvalidateHubList("Favorites")
				end
				control.NoteEditBackdrop:SetHidden(true)
				control.NoteLabel:SetHidden(false)
				control.RefreshNote()
			end
		end

		if control.Favorite then
			control.Favorite:SetHandler("OnMouseDown", function()
				self:ToggleFavoriteHubEntry(control)
				return true
			end)
			control.Favorite:SetHandler("OnMouseEnter", OnHubShortcutMouseEnter)
			control.Favorite:SetHandler("OnMouseExit", OnHubShortcutMouseExit)
			OnHubShortcutMouseExit(control.Favorite)
			tip(control.Favorite, "Toggle this home as a Favorite", TOP, 0, 36, BOTTOM)
		end

		if control.ShareLink then
			control.ShareLink:SetHandler("OnMouseDown", function()
				self:ShareHubHouseLink(control)
				return true
			end)
			control.ShareLink:SetHandler("OnMouseEnter", OnHubShortcutMouseEnter)
			control.ShareLink:SetHandler("OnMouseExit", OnHubShortcutMouseExit)
			OnHubShortcutMouseExit(control.ShareLink)
			tip(control.ShareLink, "Share a link to this home\n\nEssential Housing Tools or\nHousing Hub required", TOP, 0, 36, BOTTOM)
		end

		if control.VisitButton then
			control.VisitButton:SetHandler("OnMouseDown", function()
				self:VisitHubEntry(control)
				return true
			end)
			control.VisitButton:SetHandler("OnMouseEnter", OnHubShortcutMouseEnter)
			control.VisitButton:SetHandler("OnMouseExit", OnHubShortcutMouseExit)
			OnHubShortcutMouseExit(control.VisitButton)
			tip(control.VisitButton, "Travel to this home", TOP, 0, 36, BOTTOM)
		end

		if control.OpenHouse then
			control.OpenHouse:SetHandler("OnMouseDown", function()
				if not control.OpenHouse.IsDisabled then
					self:ToggleOpenHouseHubEntry(control)
				else
					if "streamrow" == self.TileType then
						self:OnHubStreamTileMouseDown(control)
					else
						self:OnHubTileMouseDown(control)
					end
				end
				return true
			end)
		end
		if control.ClosedHouse then
			control.ClosedHouse:SetHandler("OnMouseDown", function()
				if not control.ClosedHouse.IsDisabled then
					self:ToggleOpenHouseHubEntry(control)
				else
					if "streamrow" == self.TileType then
						self:OnHubStreamTileMouseDown(control)
					else
						self:OnHubTileMouseDown(control)
					end
				end
				return true
			end)
		end
		if control.ShareFXButton then
			control.ShareFXButton:SetHandler("OnMouseDown", function()
				if not control.ShareFXButton.IsDisabled then
					self:ShareFXHubEntry(control)
				else
					if "streamrow" == self.TileType then
						self:OnHubStreamTileMouseDown(control)
					else
						self:OnHubTileMouseDown(control)
					end
				end
				return true
			end)
		end

		self:EnableEnhancedMouseOverBehaviorForControlGraph(control, true)
		return control
	end

	function EHH:CreateHubEntryStreamRow(ui, index)
		local control = WINDOW_MANAGER:CreateControlFromVirtual(string.format("EHHHubListEntryStreamRow%d", index), ui.ScrollTiles, "HousingHubStreamRow")
		self.HubListStreamRows[index] = control
		control.Data = {}
		control.IsStreamRow = true

		local SIZE_X, SIZE_Y = 960, 134
		local SPACING_Y = 24
		local HALF_SIZE_X, HALF_SIZE_Y = 0.5 * SIZE_X, 0.5 * SIZE_Y
		local anchorToRow = index - 1
		local controlOffsetX = 10
		local controlOffsetY = (SIZE_Y + SPACING_Y) * anchorToRow
		control:SetAnchor(TOPLEFT, nil, nil, controlOffsetX, controlOffsetY)
		
		control:SetMouseEnabled(true)
		control:SetHandler("OnMouseDown", function(control)
			if control.Data.URL and "" ~= control.Data.URL then
				self:OpenStreamChannelURL(control.Data.URL)
			end
		end)

		return control
	end

	function EHH:CreateHubEntryRecord(data)
		local rec = {}

		if data.Id and 0 ~= data.Id and "" ~= data.Id and "0" ~= data.Id then
			rec.HouseId = data.Id
		else
			rec.HouseId = data.HouseId
		end
		rec.Icon = data.Icon or ""
		rec.Image = data.Image or ""
		rec.Category = data.Category
		rec.HouseCategory = data.HouseCategory
		rec.HouseDescription = data.HouseDescription
		rec.Name = data.Name or ""
		rec.Nickname = data.Nickname or ""
		rec.Owner = data.Owner or ""
		rec.IsNew = true == data.IsNew
		rec.LastVisit = data.LastVisit
		rec.CommunityFX = nil
		rec.FavIndex = data.FavIndex
		rec.Record = nil
		rec.SortKey = data.SortKey
		rec.FurnitureLink = data.FurnitureLink
		rec.Containers = data.Containers
		rec.Count = data.Count
		rec.BoundCount = data.BoundCount
		rec.ItemsSpecial = nil
		rec.ItemsSpecialMax = nil
		rec.ItemsStandard = nil
		rec.ItemsStandardMax = nil
		rec.PublishedDate = data.PublishedDate
		rec.NumSignatures = data.NumSignatures
		rec.TrendingScore = data.TrendingScore
		rec.TradingPriceInfo = data.TradingPriceInfo
		rec.EstimatedUnitValue = data.EstimatedUnitValue
		rec.EstimatedUnitValueString = data.EstimatedUnitValueString
		rec.EstimatedTotalValue = data.EstimatedTotalValue
		rec.EstimatedTotalValueString = data.EstimatedTotalValueString
		rec.VisitorName = data.VisitorName
		rec.VisitorDisplayName = data.VisitorDisplayName
		rec.VisitDate = data.VisitDate
		rec.HouseName = data.HouseName
		rec.MaxItemsTraditional = data.MaxItemsTraditional
		rec.NumItemsTraditional = data.NumItemsTraditional

		rec.ChannelName = data.ChannelName
		rec.URL = data.URL
		rec.Schedule = data.Schedule
		rec.Description = data.Description
		rec.LastLiveTS = data.LastLiveTS
		rec.LastEndTS = data.LastEndTS
		rec.LastLiveAgeHours = data.LastLiveAgeHours

		if data.GuildId then
			rec.GuildId = data.GuildId
			rec.GuildIndex = data.GuildIndex
			return rec
		end
		
		local isOwner = data.IsOwner or self:IsOwnerLocalPlayer(rec.Owner)
		rec.IsOwner = isOwner

		if isOwner then
			rec.Owner = nil
			rec.SortOwner = self.DisplayNameLower
		elseif rec.Owner then
			rec.SortOwner = string.lower(rec.Owner)
		else
			rec.SortOwner = ""
		end

		local houseId = tonumber(rec.HouseId)
		if 0 == houseId then
			houseId = nil
			rec.SortHouseId = 0
		else
			rec.SortHouseId = houseId or 0
		end
		rec.HouseId = houseId

		if not houseId and not rec.FurnitureLink and not rec.GuildId then
			rec.Name = "Primary Home"
			rec.Icon = "esoui/art/icons/housing_altmer_medium.dds"
			rec.Image = GetHousePreviewBackgroundImage(1)
		end
		
		if houseId then
			do
				local note, noteDate = "", nil
				local noteData = self:GetHouseNote(self.World, houseId, rec.Owner)
				if "table" == type(noteData) then
					note, noteDate = noteData.Note or "", noteData.Date
				end
				rec.HouseNote, rec.HouseNoteDate = note, noteDate
			end

			if "" == rec.Icon or "" == rec.Image or "" == rec.Name then
				local house = self:GetHouseById(houseId)

				if not house and isOwner then
					local primaryHouseId = GetHousingPrimaryHouse()

					if primaryHouseId and 0 ~= primaryHouseId then
						house = self:GetHouseById(primaryHouseId)
					end
				end

				if house then
					if "" == rec.Icon then rec.Icon = house.Icon end
					if "" == rec.Image then rec.Image = house.Image end
					if "" == rec.Name then rec.Name = house.Name end
				end
			end

			if "" == rec.Nickname then
				local nickname = self:GetHouseNickname(houseId, rec.Owner)
				if nickname and "" ~= nickname and "1" ~= tostring(nickname) then
					rec.Nickname = nickname
				end
			end

			local record = self:GetHouse(self.World, houseId, rec.Owner)

			rec.Record = record
			rec.LastVisit = (record and tonumber(record.LastVisitTS)) or rec.LastVisit or nil
		end

		rec.SortName = string.lower(rec.Name or "")
		rec.SortNickname = string.lower(rec.Nickname or "")

		do
			local nameTerms = string.format("%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n", rec.Name or "", rec.HouseName or "", rec.Nickname or "", rec.HouseDescription or "", rec.SortOwner or "", rec.VisitorName or "", rec.VisitorDisplayName or "", rec.Category or "", rec.ChannelName or "", rec.Description or "")
			local houseNameTerms, tagTerms = "", ""
			local boundTerms, noteTerms

			if rec.Containers and #rec.Containers > 0 then
				for _, container in ipairs(rec.Containers) do
					houseNameTerms = houseNameTerms .. container.Name .. "\n"
				end
			end

			if rec.BoundCount and rec.BoundCount > 0 then
				boundTerms = "crown bound\n"
			elseif rec.Count and rec.Count - (rec.BoundCount or 0) > 0 then
				boundTerms = "tradeable sellable\n"
			else
				boundTerms = ""
			end

			--if 0 ~= houseId or "" ~= owner then
			if rec.Owner or 0 ~= houseId then
				local houseNote = self:GetHouseNote(self.World, rec.HouseId, rec.Owner)
				if houseNote and houseNote.Note then
					noteTerms = tostring(houseNote.Note) .. "\n"
				else
					noteTerms = ""
				end
			else
				noteTerms = ""
			end
			
			if rec.FurnitureLink and "" ~= rec.FurnitureLink then
				local tags = self:GetItemLinkFurnitureBehaviorTags(rec.FurnitureLink)
				for index, tag in ipairs(tags) do
					tagTerms = tagTerms .. tag.name .. "\n"
				end
			end

			rec.SearchTerms = string.format("%s%s%s%s%s", nameTerms, houseNameTerms, boundTerms, noteTerms, tagTerms)
		end

		return rec
	end

	do
		local COLORS =
		{
			Active =
			{
				"|cffffff",
				"|cd0d9ff",
				"|cb0ccff",
			},
			Inactive =
			{
				"|c888888",
				"|c666688",
				"|c444488",
			},
		}

		local GUILDHALL_TOOLTIP_HINT = "" ..
			"Ask an officer to add the Guildhall's owner to this guild's About Us section.\n" ..
			"For example:\n\n" ..
			"|c88ffff" ..
			"Guildhall: @player\n" ..
			"|ror|c88ffff\n" ..
			"Guildhall: Humblemud @player|r"

		function EHH:UpdateHubEntry(entry, data)
			if entry.Data and not entry.IsStreamRow then
				entry.SaveNote()
			end

			entry.Data = data
			
			if entry.IsStreamRow then
				local url = data.URL
				local channelName = data.ChannelName
				local lastLiveAgeHours = tonumber(data.LastLiveAgeHours)

				if lastLiveAgeHours then
					local offAir = lastLiveAgeHours > self.Defs.Limits.MaxBroadcastHours
					local lastLiveString = ""
					if offAir then
						lastLiveString = string.format("Last live\n%s ago", self:GetTimeSpanString(lastLiveAgeHours * 60 * 60, 1))
					else
						lastLiveString = "|cffff88LIVE NOW|r"
					end

					entry.URL = url
					entry.Description:SetText(data.Description or "")
					entry.ChannelName:SetText(channelName)
					entry.Schedule:SetText(data.Schedule or "")
					entry.Live:SetHidden(offAir)
					entry.LastLive:SetText(lastLiveString)
				end

				return
			end
			
			entry.Data.IsOwner = data.IsOwner
			entry.Data.LastVisitAgeDays = nil
			entry.Data.HouseCategory = nil
			entry.Data.HouseDescription = nil
			entry.Nickname = data.Nickname
			entry.LastFX = nil
			entry.LastVisit = nil
			entry.IsInaccessible = nil
			entry.OpenHouseInfo = nil
			entry.SetNoteHidden(data.FurnitureLink and "" ~= data.FurnitureLink)
			data.FXCount, data.FXTimestamp = 0, nil

			local isGuestRecord = data.VisitDate ~= nil
			local inaccessibleHouse = false
			local houseId = data.HouseId
			local isOwner = data.IsOwner
			local isNew = data.IsNew
			local ownerOrPlayer = isOwner and self.DisplayNameLower or data.Owner
			local openHouse = nil

			entry.AutoExtendTile = not isGuestRecord and not data.GuildIndex

			local colors = COLORS.Active
			entry.Colors = colors

			if houseId and not isGuestRecord then
				inaccessibleHouse = self:GetInaccessibleHouse(self.World, houseId, data.Owner)
				if inaccessibleHouse then
					if inaccessibleHouse.attemptedDate then
						local today = self:GetDate()
						local days = today - inaccessibleHouse.attemptedDate
						data.InaccessibleDays = days
					else
						data.InaccessibleDays = 0
					end
					
					colors = COLORS.Inactive
					entry.Colors = colors
				end

				openHouse = self:GetOpenHouse(houseId, not isOwner and data.Owner or nil)
				self:SetOpenHouseState(entry, openHouse, isOwner)
				
				if openHouse then
					data.HouseCategory = openHouse.C
					data.HouseDescription = openHouse.D
				end

				do
					local effects, timestamp = self:GetHouseEffects(houseId, ownerOrPlayer)
					if effects and timestamp then
						local numEffects = #effects
						if 0 < numEffects then
							data.FXCount = numEffects
							data.FXTimestamp = tonumber(timestamp)
						end
					end
				end

				do
					if self.IsEHT then
						local effects, timestamp = EHT.Data.GetHouseEffects(houseId, ownerOrPlayer)
						if effects then
							local numEffects = #effects
							if 0 < numEffects then
								timestamp = tonumber(timestamp)
								if isOwner or (not data.FXTimestamp or (timestamp and timestamp > data.FXTimestamp)) then
									data.FXCount = numEffects
									data.FXTimestamp = timestamp
								end
							end
						end
					end
				end
			else
				self:SetOpenHouseState(entry, nil, false)
				isNew = false
			end
			
			local inaccessibleDays = inaccessibleHouse and data.InaccessibleDays
			local caption1, caption2, caption3, caption4, relativeAge
			if data.VisitDate then
				caption1 = data.HouseName
				caption2 = data.VisitorName
				caption3 = data.VisitorDisplayName
				relativeAge = self:GetRelativeTimeString(data.VisitDate, nil, 1, "|cb0ccff", "|cffffff")
			elseif data.FurnitureLink then
				caption1 = data.Name
				caption2 = data.Category
			elseif data.GuildIndex then
				caption1 = data.Name
			else
				caption1 = data.Owner or self.DisplayNameLower
				caption2 = data.Name
				caption3 = entry.Nickname
				caption4 = self:GetOpenHouseSubcategoryName(data.HouseCategory)
			end

			if caption1 and "" ~= caption1 then
				entry.Caption1:SetText(caption1)
				entry.Caption1:SetHidden(false)
			elseif caption2 and "" ~= caption2 then
				entry.Caption1:SetText(caption2)
				entry.Caption1:SetHidden(false)
				caption2 = caption3
				caption3 = nil
			elseif caption3 and "" ~= caption3 then
				entry.Caption1:SetText(caption3)
				entry.Caption1:SetHidden(false)
				caption3 = nil
			else
				entry.Caption1:SetHidden(true)
			end

			if caption2 and "" ~= caption2 then
				entry.Caption2:SetText(caption2)
				entry.Caption2:SetHidden(false)
			elseif caption3 and "" ~= caption3 then
				entry.Caption2:SetText(caption3)
				entry.Caption2:SetHidden(false)
				caption3 = nil
			else
				entry.Caption2:SetHidden(true)
			end

			if caption3 and "" ~= caption3 then
				entry.Caption3:SetText(caption3)
				entry.Caption3:SetHidden(false)
			else
				entry.Caption3:SetHidden(true)
			end

			if caption4 and "" ~= caption4 then
				entry.Caption4:SetText(caption4)
				entry.Caption4:SetHidden(false)
			else
				entry.Caption4:SetHidden(true)
			end

			if data.HouseDescription and "" ~= data.HouseDescription then
				entry.Caption5:SetText(data.HouseDescription)
				entry.Caption5:SetHidden(false)
			else
				entry.Caption5:SetHidden(true)
			end

			if entry.RelativeAge then
				if relativeAge and "" ~= relativeAge then
					entry.RelativeAge:SetText(relativeAge)
					entry.RelativeAge:SetHidden(false)
				else
					entry.RelativeAge:SetHidden(true)
				end
			end

			if entry.EstimatedValue then
				if not (data.EstimatedTotalValueString or data.EstimatedUnitValueString) then
					entry.EstimatedValue:SetHidden(true)
				else
					entry.EstimatedValue:SetText((data.EstimatedTotalValueString or "") .. (data.EstimatedUnitValueString or ""))
					entry.EstimatedValue:SetHidden(false)
				end
			end

			local numItems, maxItems
			if data.MaxItemsTraditional then
				numItems = data.NumItemsTraditional
				maxItems = " / " .. tostring(data.MaxItemsTraditional)
			elseif data.FavIndex and data.FurnitureLink then
				numItems = string.format("%d", data.FavIndex or 0)
				maxItems = "items"
			end

			if maxItems then
				entry.ItemsLimit:SetText(maxItems)
				entry.ItemsLimit:SetHidden(false)
				entry.ItemsPlaced:SetText(numItems)
				entry.ItemsPlaced:SetHidden(false)
				entry.Limits:SetHidden(false)
			else
				entry.ItemsLimit:SetHidden(true)
				entry.ItemsPlaced:SetHidden(true)
				entry.Limits:SetHidden(true)
			end
--[[
			if EHH.IsDev and data.TrendingScore and data.TrendingScore > 0 then
				desc = desc .. string.format(" (%d score / %d visits)", data.TrendingScore, data.NumSignatures)
			end
]]
			entry.Shortcuts:SetHidden(true)

			if isGuestRecord then
				entry.SetNoteHidden(true)
			else
				if inaccessibleDays then
					if inaccessibleDays <= 0 then
						data.LastVisitAgeDays = 0
					else
						data.LastVisitAgeDays = inaccessibleDays
					end

					isNew = false
				elseif houseId then
					local lastVisit = tonumber(data.LastVisit)
					if lastVisit then
						local daysAgo = self:GetDate() - self:ConvertSecondsToDays(lastVisit)
						data.LastVisitAgeDays = daysAgo

						if isNew and daysAgo <= self.Defs.Limits.MaxOpenHouseAgeForNewStatus then
							isNew = false
						end
					end
				end

				if houseId or not isOwner then
					self:SetFavoriteIconState(entry.Favorite, self:IsFavoriteHouse(self.World, houseId, data.Owner))
					entry.Shortcuts:SetHidden(false)
				end
			
				entry.RefreshNote()
			end

			if inaccessibleDays then
				entry.Border:SetVertexColors(15, 0.35, 0.35, 0.35, 1)
				entry.Background:SetColor(0, 0, 0, 1)
				entry.Image:SetDesaturation(1)
			else
				if isNew then
					entry.Border:SetVertexColors(15, 0.75, 0.85, 1, 1)
				elseif openHouse then
					if isOwner then
						entry.Border:SetVertexColors(5, 0.49, 0.6, 1, 1)
						entry.Border:SetVertexColors(10, 0.75, 0.85, 1, 1)
					else
						entry.Border:SetVertexColors(15, 0.75, 0.85, 1, 1)
					end
				elseif data.FurnitureLink and "" ~= data.FurnitureLink then
					entry.Border:SetVertexColors(5, 1, 1, 1, 1)
					entry.Border:SetVertexColors(10, 0.49, 0.6, 1, 1)
				else
					entry.Border:SetVertexColors(15, 0.49, 0.6, 1, 1)
				end
				--entry.Background:SetColor(0.14, 0.14, 0.14, 0.95)
				entry.Background:SetColor(0.102, 0.133, 0.166, 0.95)
				entry.Image:SetDesaturation(0)
			end

			local isShowingHeraldry = false

			if entry.Heraldry then
				if data.GuildId then
					local heraldryData = {self:GetGuildHeraldry(data.GuildId)}
					if 0 < #heraldryData then
						local textures = self:GetHeraldryTextures(unpack(heraldryData))
						local c
						
						entry.HeraldryBackground:SetTexture(textures[1].TextureFile)
						c = textures[1].Color
						entry.HeraldryBackground:SetColor(c.R, c.G, c.B, 1)
						entry.HeraldrySwordsAndShield:SetVertexColors(1, 0.2 + 0.5 * c.R, 0.2 + 0.5 * c.G, 0.2 + 0.5 * c.B, 1)
						entry.HeraldrySwordsAndShield:SetVertexColors(6, 0.1 + 0.4 * c.R, 0.1 + 0.4 * c.G, 0.1 + 0.4 * c.B, 1)
						entry.HeraldrySwordsAndShield:SetVertexColors(8, 0, 0, 0, 1)

						entry.HeraldryStyle:SetTexture(textures[2].TextureFile)
						c = textures[2].Color
						entry.HeraldryStyle:SetColor(c.R, c.G, c.B, 1)

						entry.HeraldryCrest:SetTexture(textures[3].TextureFile)
						c = textures[3].Color
						entry.HeraldryCrest:SetColor(c.R, c.G, c.B, 1)

						entry.HeraldryBackdrop:SetHidden(false)
						entry.Heraldry:SetHidden(false)
						entry.Image:SetHidden(true)
						entry.Icon:SetHidden(true)

						isShowingHeraldry = true
					end
				end

				if not isShowingHeraldry then
					entry.Heraldry:SetHidden(true)
					entry.HeraldryBackdrop:SetHidden(true)
				end
			end

			if not isShowingHeraldry then
				if data.Image and "" ~= data.Image then
					entry.Icon:SetHidden(true)
					entry.Image:SetTexture(data.Image)
					entry.Image:SetHidden(false)
				elseif data.Icon and "" ~= data.Icon then
					entry.Icon:SetTexture(data.Icon)
					entry.Icon:SetHidden(false)
					entry.Image:SetHidden(true)
				else
					entry.Icon:SetHidden(true)
					entry.Image:SetHidden(true)
				end
			end

			do
				local mouseEnabled = entry.Caption1.FurnitureLink and "" ~= entry.Caption1.FurnitureLink
				entry.Caption1.FurnitureLink = data.FurnitureLink
				entry.Caption1:SetMouseEnabled(mouseEnabled)
				entry.Caption2:SetMouseEnabled(mouseEnabled)
				entry.Caption3:SetMouseEnabled(mouseEnabled)
			end

			self:RefreshHubTileAdditionalInfo(entry)

			if entry.Tags then
				entry.ClearTags()
				if data.Containers then
					local containerCount = 0
					for containerIndex, container in ipairs(data.Containers) do
						entry.AddTag(container)
						containerCount = containerCount + 1
						if containerCount >= 8 then
							break
						end
					end
				end
			end

			do
				local shareFXButton = entry.ShareFXButton
				local hideShareFX = not EHT or not EHT.UI or isGuestRecord or not houseId or (not data.FXCount or 0 == data.FXCount)
				local color = hideShareFX and 0.45 or 1
				shareFXButton:SetColor(color, color, color, 1)
				shareFXButton.IsDisabled = hideShareFX
			end

			if entry.HomeTourButton then
				local hideGuild = isGuestRecord or (not data.GuildIndex)
				entry.HomeTourButton:SetHidden(hideGuild)
				entry.VisitGuildhallButton:SetHidden(hideGuild)

				if not hideGuild then
					if self:DoesGuildhallExist(data.GuildId) then
						self:ClearInfoTooltip(entry.VisitGuildhallButton)
					else
						self:SetInfoTooltip(entry.VisitGuildhallButton, GUILDHALL_TOOLTIP_HINT, RIGHT, -15, 0, LEFT)
					end
				end
			end

			if entry.FurnitureShortcuts then
				entry.FurnitureShortcuts:SetHidden(not data.FurnitureLink or data.FurnitureLink == "")
			end
		end
	end

	function EHH:GetHubListCount()
		if self.HubList then
			if self.HubMaxListCount then
				return math.min(#self.HubList, self.HubMaxListCount)
			else
				return #self.HubList
			end
		else
			return 0
		end
	end

	function EHH:GetNumHubListItems()
		local count = self:GetHubListCount()
		if self.HubListCount then
			return math.min(count, self.HubListCount)
		end
		return count
	end

	function EHH:UpdateHubList(firstIndex)
		firstIndex = firstIndex or self.HubListFirstIndex or 1

		local ui = self:GetDialog("HousingHub")
		local list = self.HubList
		local maxIndex = list and self:GetHubListCount() or 0
		local lastIndex

		if 0 < maxIndex then
			if not firstIndex or firstIndex > maxIndex then
				firstIndex = 1
			end

			lastIndex = firstIndex + self.NumHubListEntrySlots - 1

			if lastIndex > maxIndex then
				lastIndex = maxIndex
				firstIndex = lastIndex - self.NumHubListEntrySlots + 1
				if 1 > firstIndex then firstIndex = 1 end
			end

			local maxControlIndex = 1
			for index = 1, self.NumHubListEntrySlots do
				local c = self:GetHubListControl(index)
				if c then
					local entryIndex = index + firstIndex - 1
					local r = list[entryIndex]
					if r then
						self:UpdateHubEntry(c, r)
						c.Data.Visible = true
						c:SetHidden(false)
						maxControlIndex = index
					else
						c.Data.Visible = false
						c:SetHidden(true)
					end
				end
			end

			self.HubListFirstIndex = firstIndex
			self.HubListMaxControlIndex = maxControlIndex
			self.IsEndOfHubList = maxIndex == lastIndex
		elseif self:GetHubListControls() then
			for _, c in ipairs(self:GetHubListControls()) do
				c.Data.Visible = false
				c:SetHidden(true)
			end

			self.HubListMaxControlIndex = 0
			self.IsEndOfHubList = true
		end
	end

	function EHH:UpdateHubBookmarkWidget()
		local tile = self:GetHubListControl(1)
		local slider = self.HubScrollSlider
		local widget = self.HubBookmarkWidget

		if not tile or tile:IsControlHidden() then
			widget:SetHidden(true)
		else
			if self.IsEndOfHubList then
				tile = self:GetHubListControl(self.HubListMaxControlIndex)
			end

			if not tile or not tile.Data then
				widget:SetHidden(true)
			else
				local entry = tile.Data
				local sort = self.CurrentHousingHubSort
				local key = sort and sort.bookmarkKey
				local text
				if key then
					if "function" == type(key) then
						text = key(entry)
					else
						text = entry[key]
					end
				end

				if not text then
					widget:SetHidden(true)
				else
					local height = slider:GetHeight()
					local interval = self.IsEndOfHubList and 1 or (self.HubListFirstIndex / #self.HubList)
					local sliderOffset = interval * height

					widget:ClearAnchors()
					widget:SetAnchor(LEFT, slider, TOPRIGHT, 25, sliderOffset)
					widget:SetText(text)
					widget:SetAlpha(1)
					widget:SetHidden(false)
					widget.LastUpdate = GetFrameTimeMilliseconds()

					EVENT_MANAGER:RegisterForUpdate("EssentialHousingHub.HubBookmarkWidget", 1, EHH_HubBookmarkWidget_OnUpdate)
				end
			end
		end
	end

	function EHH:UpdateHubListSlider()
		local ui = self:GetDialog("HousingHub")
		local numItems, maxEntries = self:GetHubListCount(), self.NumHubListEntrySlots
		local scrollMin, scrollMax = 0 < numItems and 1 or 0, 0 < (numItems - maxEntries + 1) and (numItems - maxEntries + 1) or 1
		local hideSlider = 1 >= scrollMax

		ui.ScrollSlider:SetMinMax(scrollMin, scrollMax)
		ui.ScrollSlider:SetHidden(hideSlider)
		ui.ScrollSliderUp:SetHidden(hideSlider)
		ui.ScrollSliderDown:SetHidden(hideSlider)
		ui.ScrollSliderBackground:SetHidden(hideSlider)

		if ui.RowCount then
			local numRows = self:GetNumHubListItems()
			ui.RowCount:SetText(string.format("%d result%s", numRows, 1 == numRows and "" or "s"))
		end
	end

	function EHH:BindHubList(list, sortComparer, filter, categoryFilter, hideInaccessible)
		local ui = self:GetDialog("HousingHub")
		filter = filter and self:Trim(string.lower(filter))

		if categoryFilter or hideInaccessible or (filter and "" ~= filter) then
			local filteredList = {}
			local search = self.TextSearch:New()
			search:SetFilter(filter)

			for listIndex, data in ipairs(list) do
				local houseId, owner = tonumber(data.HouseId) or 0, data.Owner or ""
				local addEntry = true

				if categoryFilter and categoryFilter ~= data.HouseCategory then
					addEntry = false
				elseif hideInaccessible and 0 ~= houseId and "" ~= owner then
					local inaccessibleHouse = self:GetInaccessibleHouse(self.World, houseId, owner)
					addEntry = nil == inaccessibleHouse
				end

				if addEntry then
					if search:Match(data.SearchTerms) then
						table.insert(filteredList, data)
					end
				end
			end

			self.HubList = filteredList
		else
			self.HubList = list
		end

		if 0 ~= sortComparer then
			table.sort(self.HubList, "function" == type(sortComparer) and sortComparer or self:GetDefaultHubEntryComparer())
		end

		self:UpdateHubListSlider()
		self:UpdateHubList()

		--self:SetIsLoading(false)
		ui.ScrollPanel:SetHidden(false)
	end

	function EHH:ShowHubList(origList, sortComparer, filter, categoryFilter, hideInaccessible, cacheKey)
		local ui = self:GetDialog("HousingHub")
		if not ui or ui.Window:IsHidden() or not self:GetData() then
			return
		end

		if 200 < #origList then
			ui.ScrollPanel:SetHidden(true)
			--self:SetIsLoading(true)
		end

		local originalScrollValue = ui.ScrollSlider:GetValue()
		local list = {}
		local index = 0

		local function BuildHubList()
			local endBatch = GetGameTimeMilliseconds() + 50

			while true do
				index = index + 1
				local data = origList[index]

				if not data then
					HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".BuildHubList")
					self:CacheHubList(cacheKey, list)
					self:BindHubList(list, sortComparer, filter, categoryFilter, hideInaccessible)
					ui.ScrollSlider:SetValue(originalScrollValue or 0)
					return
				end
				
				table.insert(list, self:CreateHubEntryRecord(data))

				if GetGameTimeMilliseconds() > endBatch then
					if ui.Window:IsHidden() then
						HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".BuildHubList")
					end
					self:UpdateHubListSlider()
					return
				end
			end
		end

		HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".BuildHubList")
		HUB_EVENT_MANAGER:RegisterForUpdate(self.Name .. ".BuildHubList", 1, BuildHubList)
	end

	function EHH:FlashHousingHubFilter()
		local ui = self:GetDialog("HousingHub")
		if not ui or ui.Window:IsHidden() then
			HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".FlashHousingHubFilter")
			return
		end

		if ui.FilterBackdrop.FlashState then
			ui.FilterBackdrop:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1)
			SetColor(ui.FilterBackdrop2, Colors.ControlBackdrop)
			ui.FilterBackdrop.FlashState = false
		else
			ui.FilterBackdrop:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 2)
			SetColor(ui.FilterBackdrop2, Colors.ControlBackdropHighlight)
			ui.FilterBackdrop.FlashState = true
		end
	end

	function EHH:GetHousingHubView()
		local ui = self:GetDialog("HousingHub")
		return (ui and ui.CurrentView) and ui.CurrentView or "Recent"
	end

	function EHH:SetHubSortHidden(hidden)
		local ui = self:GetDialog("HousingHub")
		if ui then
			ui.SortLabel:SetHidden(hidden)
			ui.Sort:SetHidden(hidden)
		end
	end

	do
		local CachedHubLists = {}

		function EHH:FlushHubListCache()
			CachedHubLists = {}
		end
		
		function EHH:SetHubListTrendingOverride(value)
			self:FlushHubListCache()
			self:FlushCommunityMetaDataCache()
			self.OverrideTrending = tonumber(value)
			self:HideHousingHub()
			self:ShowHousingHub()
		end

		function EHH:GetCachedHubList(cacheKey)
			return CachedHubLists[ cacheKey ]
		end

		function EHH:CacheHubList(cacheKey, list)
			if cacheKey and list then
				CachedHubLists[ cacheKey ] = list
			end
		end

		function EHH:InvalidateHubList(cacheKey)
			if cacheKey then
				CachedHubLists[ cacheKey ] = nil
			end
		end

		function EHH:InsertCacheHubEntry(cacheKey, hubEntry)
			local list = self:GetCachedHubList(cacheKey)

			if list and hubEntry then
				local addEntry = true

				for _, entry in ipairs(list) do
					if entry.HouseId == hubEntry.HouseId and entry.Owner == hubEntry.Owner then
						addEntry = false
						break
					end
				end

				if addEntry then
					table.insert(list, hubEntry)
					return true
				end
			end

			return false
		end
	end

	function EHH:GetCurrentHousingHubTabAndCategoryIndex()
		local tabName = self:GetPersistentState("HousingHubTab")
		local categoryIndex = self:GetPersistentState("HousingHubCategory") or nil
		if not tabName or "" == tabName then
			return "My Homes", categoryIndex
		end
		return tabName, categoryIndex
	end

	function EHH:SetCurrentHousingHubTabName(tabName)
		self:SetPersistentState("HousingHubTab", tabName)
	end
	
	function EHH:SetCurrentHousingHubCategoryIndex(categoryIndex)
		self:SetPersistentState("HousingHubCategory", categoryIndex)
	end
	
	function EHH:GetCurrentHousingHubSort()
		return self.CurrentHousingHubSort
	end
	
	function EHH:SetCurrentHousingHubSort(sort)
		self.CurrentHousingHubSort = sort
	end

	function EHH:ScrollHubListToTop()
		local ui = self:GetDialog("HousingHub")
		if ui then
			self.HubListFirstIndex = 1
			ui.ScrollSlider:SetValue(1)
		end
	end
	
	local _showHousingHubView_viewName
	local _showHousingHubView_categoryIndex
	
	local function OnRetryShowHousingHubView()
		EssentialHousingHub:ShowHousingHubView(_showHousingHubView_viewName, _showHousingHubView_categoryIndex)
	end

	function EHH:ShowOpenHousesUpdateMessageIfNecessary(isCallback)
		local messageKey

		messageKey = "OpenHousesExplanatoryMessage"
		if not self:HasShownMessage(messageKey) then
			local houses = self:GetOpenHouses()
			if "table" == type(houses) and 0 < NonContiguousCount(houses) then
				self:HideHousingHub()
				self:SetMessageShown(messageKey, true)
				local message = "|acOpen Houses and the Community\n|r\n" ..
					"The Essential Housing Community is available to everyone as a way to " ..
					"share and collaborate with other players that also enjoy ESO Housing... " ..
					"players beyond the boundaries of a Friends list, a Guild roster or even a single ESO Server.\n" ..
					"In short, the Essential Housing Community is meant to be a hub where everyone can connect.\n\n" ..
					"For this reason, we wanted to reiterate the purpose of Open Houses. " ..
					"By listing, or having listed, any home as an Open House, you are publicly " ..
					"inviting the Community to share, visit, tour, stream, blog, vlog, enjoy and gain " ..
					"inspiration from your home.\n\n" ..
					"The opportunity to develop these tools for this Community is a blessing because " ..
					"it is players like yourself that make our Community so special. " ..
					"We cannot overstate just how much we appreciate each and every one of you."
				self:ShowAlertDialog(message, function() self:ShowOpenHousesUpdateMessageIfNecessary(true) end)
				return true
			end
		end

		messageKey = "OpenHousesCategories"
		if not self:HasShownMessage(messageKey) then
			local houses = self:GetOpenHouses()
			if "table" == type(houses) and 0 < NonContiguousCount(houses) then
				self:HideHousingHub()
				self:SetMessageShown(messageKey, true)
				local message = "|acFeature your Open Houses in Categories\n|r\n" ..
					"Now you can list an Open House in a specific category and, in the Open Houses tab, you can " ..
					"choose to view houses in any of our categories.\n\n" ..
					"To add any existing Open House to a category, simply unlist and relist your Open House. " ..
					"You will be prompted to choose a category for your home to appear in.\n\n" ..
					"We hope that you enjoy this new feature and, as always, Happy Housing!"
				self:ShowAlertDialog(message, function() self:ShowOpenHousesUpdateMessageIfNecessary(true) end)
				return true
			end
		end

		messageKey = "OpenHousesInternationalCharacters"
		if not self:HasShownMessage(messageKey) then
			local houses = self:GetOpenHouses()
			if "table" == type(houses) and 0 < NonContiguousCount(houses) then
				self:HideHousingHub()
				self:SetMessageShown(messageKey, true)
				local message = "|acInternational Characters and Symbols\n|r\n" ..
					"Custom open house names and custom book FX that use international characters can appear correctly " ..
					"for other players simply by republishing your open house and/or your home's FX.\n\n" ..
					"For custom names of an open house, simply unlist and relist your open house.\n" ..
					"For custom book FX, simply republish your home's FX to the Community.\n\n" ..
					"Happy Housing!"
				self:ShowAlertDialog(message, function() self:ShowOpenHousesUpdateMessageIfNecessary(true) end)
				return true
			end
		end

		if isCallback then
			self:ShowHousingHub()
		end
		return false
	end
	
	function EHH:ShowHousingHubView(viewName, categoryIndex)
		local ui = self:GetDialog("HousingHub")
		if ui.Window:IsHidden() then
			return
		end

		if self:ShowOpenHousesUpdateMessageIfNecessary() then
			return
		end

		ui.Sort:HidePicklist()

		if self:IsCommunityMetaDataLoaded() then
			_showHousingHubView_viewName, _showHousingHubView_categoryIndex = nil, nil
			self:SetIsLoading(false)
			EVENT_MANAGER:UnregisterForUpdate("EssentialHousingHub.RetryShowHousingHubView")
		else
			_showHousingHubView_viewName, _showHousingHubView_categoryIndex = viewName, categoryIndex
			self:SetIsLoading(true)
			EVENT_MANAGER:RegisterForUpdate("EssentialHousingHub.RetryShowHousingHubView", 100, OnRetryShowHousingHubView)
			return
		end
		
		local tabs = ui.TabButtons
		local filter = string.lower(self:Trim(ui.Filter:GetText()))
		local cacheKey, cachedList
		local list = {}
		local sortComparer
		local hideInaccessible = true == self:GetSetting("HousingHubHideInaccessible")
		local showHideInaccessibleToggle = false

		self:SetNotificationPanelHidden("DragAndDropFavorites", true)
		self:SetNotificationPanelHidden("HowToAddFavorites", true)
		self:SetNotificationPanelHidden("HowToAddHomeNotes", true)
		self:SetNotificationPanelHidden("LiveStreamChannelSetup", true)

		self.HubMaxListCount = nil
		self.HubListCount = nil

		if not filter or "" == filter or string.lower(self.HubListFilterDefault) == filter then
			filter = nil
		end

		local previousViewName = self:GetCurrentHousingHubTabAndCategoryIndex()
		if not previousViewName or "" == previousViewName then
			previousViewName = "Recent"
		end

		if not viewName then
			viewName = previousViewName
			ui.CurrentView = viewName
			ui.CurrentCategoryIndex = categoryIndex
		else
			ui.CurrentView = viewName
			ui.CurrentCategoryIndex = categoryIndex
		end

		self:SetCurrentHousingHubTabName(viewName)
		self:SetCurrentHousingHubCategoryIndex(categoryIndex)

		if ui.CurrentView ~= previousViewName then
			self:ScrollHubListToTop()
		end

		for index, btn in ipairs(tabs) do
			if btn.Key == viewName then
				btn:SetHeight(46)
				btn.Backdrop:SetAlpha(1)
			else
				btn:SetHeight(30)
				btn.Backdrop:SetAlpha(0.5)
			end
		end

		local categoryFilter
		if self.Defs.CategoryFilters.Enabled then
			if "Open Houses" == viewName then
				categoryFilter = self.SelectedHousingHubCategoryFilter
				if categoryFilter and "" ~= categoryFilter then
					ui.CategoryFilter:SetSelectedItem(categoryFilter)
				else
					ui.CategoryFilter:SetSelectedItem(0)
				end
				ui.CategoryFilterContainer:SetHidden(false)
			else
				ui.CategoryFilterContainer:SetHidden(true)
			end
		end

		local selectedSortKey
		if "Furniture" == viewName then
			selectedSortKey = self:GetPersistentState("HousingHubFurnitureSort")
		elseif "Favorites" == viewName then
			selectedSortKey = self:GetPersistentState("HousingHubFavoriteSort")
		elseif "Open Houses" == viewName then
			selectedSortKey = self:GetPersistentState("HousingHubOpenHousesSort")
		else
			selectedSortKey = self:GetPersistentState("HousingHubOtherSort")
		end

		local sortList = ui.Sort
		sortList:SetHidden(true)
		sortList:ClearItems()
		
		local overrideHubListControls = nil
		
		local defaultViewSortKey = self.Defs.HubDefaultSorts[viewName]
		local sortDefs = self.Defs.HubSorts
		local selectedSort
		for _, sortDef in ipairs(sortDefs) do
			if sortDef.views[viewName] then
				local sortId = sortDef.id
				ui.Sort:AddItem(sortDef.name, nil, sortId)
				if sortDef.key == selectedSortKey then
					selectedSort = sortDef
					sortComparer = selectedSort.comparer
				end
			end
		end

		if (not selectedSort or not selectedSort.id) and defaultViewSortKey then
			local defaultSort = self.Defs.HubSortKeys[defaultViewSortKey]
			if defaultSort then
				selectedSort = defaultSort
				sortComparer = selectedSort.comparer
			end
		end

		if selectedSort and selectedSort.id then
			ui.Sort:SetSelectedItem(selectedSort.id)
		end

		sortList:SetSorted(true)
 		self:SetHubSortHidden(true)
		self:SetCurrentHousingHubSort(selectedSort)

		ui.StreamingButtonContainer:SetHidden(true)
		ui.SetupCommunityLabel:SetHidden(true)
		ui.InstallDecoTrackLabel:SetHidden(true)
		ui.SetupGuildHomesLabel:SetHidden(true)
		ui.GuildMotD:SetHidden(true)
		ui.BackButton:SetHidden(true)
		self:SetNotificationPanelHidden("UpdateDecoTrack", true)
		self.DecoTrackItemCounts = self:GetDecoTrackCountsByHouse()

		if EHH.AreHousingHubTabsDirty then
			EHH.AreHousingHubTabsDirty = false
			self:RefreshHousingHubTabs()
		end

		cacheKey = viewName
		local communityOpenHouseMetaData

		if not self:IsStreamChannelDataValid() then
			self:SetNotificationPanelHidden("LiveStreamChannelSetup", false)
		end

		if "Favorites" == viewName then
			self.DecoTrackItemCounts = nil
			local world = self.World
			local houses = self:GetFavoriteHouses(world)
			self:SetHubSortHidden(false)

			if houses then
				if selectedSort and "Manual" == selectedSort.key then
					local count = 0
					for index = 1, self.Defs.Limits.MaxFavoriteHouses do
						local houseId, owner = self:GetHouseKeyInfo(houses[index])
						if houseId or owner then
							local entry =
							{
								FavIndex = index,
								HouseId = houseId,
								Owner = owner,
							}
							table.insert(list, entry)

							if houseId or owner then
								count = count + 1
							end
						end
					end

					self.HubListCount = count
				else
					for index = 1, self.Defs.Limits.MaxFavoriteHouses do
						if houses[index] then
							local houseId, owner = self:GetHouseKeyInfo(houses[index])
							if houseId or owner then
								local entry =
								{
									FavIndex = index,
									HouseId = houseId,
									Owner = owner,
								}
								table.insert(list, entry)
							end
						end
					end
				end
			end

			local isListEmpty = nil == next(list)
			self:SetNotificationPanelHidden("DragAndDropFavorites", isListEmpty)
			self:SetNotificationPanelHidden("HowToAddHomeNotes", isListEmpty)
			self:SetNotificationPanelHidden("HowToAddFavorites", not isListEmpty)
		elseif "My Homes" == viewName then
			self:SetHubSortHidden(false)

			for houseId, houseData in pairs(self:GetAllHouses()) do
				if IsCollectibleUnlocked(houseData.CollectibleId) then
					houseData = self:CloneTable(houseData)
					table.insert(list, houseData)
				end
			end

			self:SetNotificationPanelHidden("HowToAddFavorites", false)
		elseif "Live Streams" == viewName then
			ui.StreamingButtonContainer:SetHidden(false)
			cacheKey = nil
			overrideHubListControls = "streamrows"
			sortComparer = 0

			local metaDataList = self:GetCommunityMetaDataByKey("sc")
			local now = GetTimeStamp()
			local MAX_ENTRY_AGE_DAYS = self.Defs.Limits.MaxChannelInactivityDays

			if metaDataList and "table" == type(metaDataList) then
				for index, channelData in ipairs(metaDataList) do
					if channelData.URL and channelData.ChannelName then
						local lastLiveTS = tonumber(channelData.LastLiveTS)
						if lastLiveTS then
							local entryAgeHours = (now - lastLiveTS) / 60 / 60
							local entryAgeDays = entryAgeHours / 24
							if entryAgeDays <= MAX_ENTRY_AGE_DAYS then
								channelData.LastLiveAgeHours = entryAgeHours
								table.insert(list, channelData)
							end
						end
					end
				end
			end

			table.sort(list, function(left, right)
				return (tonumber(left.LastLiveTS) or 0) > (tonumber(right.LastLiveTS) or 0)
			end)
		elseif "Guest Journal" == viewName then
			overrideHubListControls = "tiles"
			cacheKey = nil
			sortComparer = 0
			self:SetHubSortHidden(true)

			local guests = self:GetAllHouseGuests()
			if guests then
				local maxJournalSignatureAgeForNewStatus = self.Defs.Limits.MaxJournalSignatureAgeForNewStatus
				local today = self:GetDate()

				for index, guest in ipairs(guests) do
					local ageDays = guest.visitDate and today - self:GetDate(guest.visitDate)
					local entry =
					{
						Owner = self.DisplayNameLower,
						HouseId = guest.houseId,
						HouseName = guest.houseName,
						VisitorName = guest.name,
						VisitorDisplayName = guest.displayName,
						VisitDate = guest.visitDate,
						IsNew = ageDays and ageDays <= maxJournalSignatureAgeForNewStatus
					}
					table.insert(list, entry)
				end
			end

			local SUPPRESS_DIALOG = true
			if 0 == #list and not self:CheckCommunityConnection(SUPPRESS_DIALOG) then
				ui.SetupCommunityLabel:SetHidden(false)
			end

			self:UpdateViewedGuestCount()
			EHH.AreHousingHubTabsDirty = true
		elseif "Furniture" == viewName then
			-- Prevent autofill of open house data.
			communityOpenHouseMetaData = {}

			overrideHubListControls = "tiles"
			local hasSeenAllHomes = self:HasDecoTrackVisitedAllOwnedHomes()
			self:SetNotificationPanelHidden("UpdateDecoTrack", hasSeenAllHomes)

			local canCacheList = false
			if self:HasRegisteredForDecoTrackCallbacks("HubFurnitureView") then
				cachedList = self:GetCachedHubList(cacheKey)
			else
				local function OnFullUpdate()
					self:InvalidateHubList("Furniture")
					self:RefreshHousingHub()
				end

				if self:RegisterForDecoTrackCallbacks("HubFurnitureView", OnFullUpdate) then
					canCacheList = true
				end
			end

			if cachedList then
				list = cachedList
			else
				local results = self:SearchDecoTrack("")
				if results then
					local subcount, result, link
					local matches = {}

					for categoryName, category in pairs(results.Categories) do
						for link, item in pairs(category.Items) do
							result = matches[ link ]

							if not result then
								result =
								{
									Category = categoryName,
									Name = GetItemLinkName(link),
									Link = link,
									Count = 0,
									BoundCount = 0,
									Containers = {},
									BoundContainers = {},
								}
								matches[ link ] = result
							elseif not result.BoundContainers then
								result.BoundContainers = {}
							end

							result.Count = result.Count + item.Count
							result.BoundCount = (result.BoundCount or 0) + (item.BoundCount or 0)

							for containerName, count in pairs(item.Containers) do
								result.Containers[ containerName ] = (result.Containers[ containerName ] or 0) + count
							end

							if item.BoundContainers then
								for containerName, boundCount in pairs(item.BoundContainers) do
									result.BoundContainers[ containerName ] = (result.BoundContainers[ containerName ] or 0) + boundCount
								end
							end
						end
					end

					for _, item in pairs(matches) do
						table.insert(list, item)
					end

					table.sort(list, function(itemA, itemB)
						return (itemA.Name or "") < (itemB.Name or "")
					end)
					
					local ICON_GOLD = Textures.ICON_GOLD and zo_iconFormat(Textures.ICON_GOLD, 14, 14) or "g"

					for _, item in ipairs(list) do
						local containers = {}

						for containerName, count in pairs(item.Containers) do
							local boundCount = item.BoundContainers[containerName] or 0
							local _, parenIndex = PlainStringFind(containerName, " (")
							if parenIndex and 1 < parenIndex then
								containerName = string.sub(containerName, 1, parenIndex - 1)
							end
							local container =
							{
								Name = containerName,
								FormattedLabel = self:CreateItemStockString(containerName, count, boundCount),
							}
							table.insert(containers, container)
						end

						table.sort(containers, function(left, right) return left.Name > right.Name end)

						local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, GetItemLinkQuality(item.Link))
						if r and g and b then
							item.Name = string.format("|c%s%s|r", ZO_ColorDef:New(r, g, b):ToHex() or "ffffff", item.Name)
						end

						item.SortKey = string.lower(item.Name)
						item.Category = item.Category or ""
						item.Containers = containers
						item.FavIndex = item.Count
						item.Icon = GetItemLinkIcon(item.Link)
						item.FurnitureLink = item.Link
						item.EstimatedUnitValueString = ""
						item.EstimatedTotalValueString = ""
						item.EstimatedUnitValue = 0
						item.EstimatedTotalValue = 0

						local tradingPriceInfo = self:GetItemLinkTradingPriceInfo(item.Link)
						item.TradingPriceInfo = tradingPriceInfo

						if tradingPriceInfo and tradingPriceInfo.Resale and 0 ~= tradingPriceInfo.Resale then
							local suggestedPrice = tradingPriceInfo.Resale
							local itemCount = item.Count or 1
							item.EstimatedUnitValue = suggestedPrice

							if 1 == itemCount then
								item.EstimatedUnitValueString = string.format("%s|cffff88%s|r", ICON_GOLD, self:FormatCurrency(suggestedPrice))
								item.EstimatedTotalValue = suggestedPrice
							else
								item.EstimatedUnitValueString = string.format("%s|cffff88%s|r/ea", ICON_GOLD, self:FormatCurrency(suggestedPrice))
								item.EstimatedTotalValue = suggestedPrice * itemCount
								item.EstimatedTotalValueString = string.format("%s|cffff88%s|r @ ", ICON_GOLD, self:FormatCurrency(item.EstimatedTotalValue))
							end
						end
					end
				end
			end

			ui.InstallDecoTrackLabel:SetHidden(list ~= nil and 0 < #list)
			self:SetHubSortHidden(false)
		elseif "Guilds" == viewName then
			-- Prevent autofill of open house data.
			communityOpenHouseMetaData = {}

			overrideHubListControls = "tiles"

			if not categoryIndex then
				local guilds = self:GetGuilds()
				local guildData
				sortComparer = nil

				for index, guild in ipairs(guilds) do
					if guild.Id then
						guildData = {
							GuildId = guild.Id,
							GuildIndex = guild.GuildIndex,
							Icon = "esoui/art/icons/heraldrybg_nord_03.dds",
							Name = guild.Name,
						}

						table.insert(list, guildData)
					end
				end
			else
				ui.BackButton:SetHidden(false)

				local guildIndex = categoryIndex
				local guild = self:GetGuildByIndex(guildIndex)
				local members = self:GetGuildMemberNames(guildIndex)
				local motd

				if guild and guild.MotD then
					ui.GuildMotDLabel:SetText(string.format("|ac|cffffff%s\n|cffffffGuild Message of the Day\n|r\n%s", tostring(guild.Name), guild.MotD))
					ui.GuildMotD:SetHidden(false)

					motd = string.lower(guild.MotD)

					for index, memberName in ipairs(members) do
						if string.find(motd, string.lower(memberName)) then
							table.insert(list, {
								Owner = memberName
							})
						end
					end

					if 4 > #list then
						list = {}

						for index, memberName in ipairs(members) do
							if string.find(motd, string.sub(string.lower(memberName), 2)) then
								table.insert(list, {
									Owner = memberName
								})
							end
						end
					end

					if 4 > #list then
						list = {}
					end
				end

				if 0 == #list then
					ui.SetupGuildHomesLabel:SetHidden(false)
				end
			end
		elseif "Open Houses" == viewName or "Trending Houses" == viewName then
			local isTrendingView = "Trending Houses" == viewName
			if isTrendingView then
				self.HubMaxListCount = self.Defs.Limits.MaxTrendingHouses
				sortComparer = 0
				self:SetHubSortHidden(true)
			else
				self:SetHubSortHidden(false)
			end
			showHideInaccessibleToggle = true

			cachedList = self:GetCachedHubList(cacheKey)
			if cachedList then
				list = cachedList
				-- Prevent autofill of open house data.
				communityOpenHouseMetaData = {}
			else
				communityOpenHouseMetaData = self:GetCommunityMetaData({ World = self.World, Type = "oh" })
				local today = self:GetDate()
				local MAX_OFFSET_DAYS = 26
				local trendingDailyOffset = (self.OverrideTrending or today) % MAX_OFFSET_DAYS

				if communityOpenHouseMetaData and "table" == type(communityOpenHouseMetaData) then
					local allHouses = self:GetAllHouses()
					local maxOpenHouseAgeForNewStatus = self.Defs.Limits.MaxOpenHouseAgeForNewStatus
					local numOpenHousesPerCategory = {}

					for _, worldHouses in pairs(communityOpenHouseMetaData) do
						for _, record in pairs(worldHouses.Houses) do
							local owner, houseId, houseNickname, dateOpened, houseCategory, houseDescription, numSignatures = record[1], record[2], tostring(record[3]), tonumber(record[4]), record[5], record[6], record[7]
							if owner and houseId then
								if not houseCategory then
									houseCategory = self:GetUncategorizedOpenHouseCategory()
								end
								if houseCategory then
									local numHouses = numOpenHousesPerCategory[houseCategory] or 0
									numOpenHousesPerCategory[houseCategory] = numHouses + 1
								end

								local isOwner = owner == self.DisplayNameLower
								local masterHouse = allHouses[houseId]
								if masterHouse then
									local houseData =
									{
										CollectibleId = masterHouse.CollectibleId,
										Icon = masterHouse.Icon,
										Id = masterHouse.Id,
										Image = masterHouse.Image,
										Name = masterHouse.Name,
									}

									local ageDays = dateOpened and math.floor(math.max(0, today - dateOpened)) or nil
									if houseNickname and "1" ~= houseNickname then
										houseData.Nickname = houseNickname
									else
										houseData.Nickname = nil
									end
									houseData.Owner = owner
									houseData.IsOwner = isOwner
									houseData.PublishedDate = dateOpened
									houseData.HouseCategory = houseCategory
									houseData.HouseDescription = houseDescription
									houseData.IsNew = ageDays and ageDays <= maxOpenHouseAgeForNewStatus
									houseData.NumSignatures = numSignatures

									if isTrendingView then
										local trendingScore = houseData.NumSignatures or 0
										if trendingScore > 0 then
											local trendingScoreModifier = 1
											if houseData.Owner and #houseData.Owner > 1 and string.byte(string.upper(string.sub(houseData.Owner, 2, 2))) % MAX_OFFSET_DAYS == trendingDailyOffset then
												trendingScoreModifier = 2
											end

											trendingScore = trendingScoreModifier * trendingScore
											if ageDays then
												local modifier = math.max(0.35, 3 - (ageDays / 5))
												trendingScore = math.max(0, modifier * trendingScore)
											end
										end
										houseData.TrendingScore = trendingScore
									end

									table.insert(list, houseData)
								end
							end
						end
					end
					
					self:SetNumOpenHousesPerCategory(numOpenHousesPerCategory)

					if isTrendingView then
						table.sort(list, self:GetTrendingHubEntryComparer())

						if #list > self.HubMaxListCount then
							local placedOwners = {}
							local trendingList = {}
							local index1, index2 = 1, #list
							local count = 0
							while count < self.HubMaxListCount and index1 <= index2 do
								local item
								if count % 2 == 0 then
									item = list[index1]
									index1 = index1 + 1
								else
									item = list[index2]
									index2 = index2 - 1
								end

								if item then
									local ownerName = string.lower(item.Owner or "")
									if "" ~= ownerName and not placedOwners[ ownerName ] and not self:GetInaccessibleHouse(self.World, item.Id, item.Owner) then
										placedOwners[ ownerName ] = true
										table.insert(trendingList, item)
										count = count + 1
									end
								end
							end

							list = trendingList
						end
					end
				end
			end

			if #list == 0 then
				ui.SetupCommunityLabel:SetHidden(false)
			end
		else
			local recents = self:GetRecentlyVisitedHouses()

			if "table" == type(recents) then
				local allHouses = self:GetAllHouses()

				for index, entry in ipairs(recents) do
					if entry.HouseId then
						local houseData = --self:CloneTable(allHouses[ entry.HouseId ])
						{
							HouseId = entry.HouseId,
							Owner = entry.Owner,
							LastVisit = entry.TS,
						}
						table.insert(list, houseData)
					end
				end
			end
		end

		ui.Filter:LoseFocus()

		ui.HideInaccessibleToggle:SetHidden(not showHideInaccessibleToggle)
		ui.HideInaccessibleToggle:ClearAnchors()
		if ui.Sort:IsHidden() then
			ui.HideInaccessibleToggle:SetAnchor(LEFT, ui.FilterBackdrop, RIGHT, 30, 0)
		else
			ui.HideInaccessibleToggle:SetAnchor(LEFT, ui.Sort:GetControl(), RIGHT, 30, 0)
		end

		if not filter then
			filter = nil

			ui.FilterBackdrop:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1)
			SetColor(ui.FilterBackdrop2, Colors.ControlBackdrop)
			ui.Filter:SetText(self.HubListFilterDefault)
			ui.ClearFilterButton:SetHidden(true)
			HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".FlashHousingHubFilter")
		else
			ui.ClearFilterButton:SetHidden(false)
			HUB_EVENT_MANAGER:RegisterForUpdate(self.Name .. ".FlashHousingHubFilter", 500, function(...) return self:FlashHousingHubFilter(...) end)
		end

		if overrideHubListControls then
			self:OverrideHubListControls(overrideHubListControls)
		else
			self:UsePreferredHubListControls()
		end

		if 0 == categoryFilter then
			categoryFilter = nil
		end

		local updateList = cachedList and cachedList or list
		if updateList then
			-- Attempt to look up DecoTrack house limit metadata.
			local houseLimits = self:GetDecoTrackCountsByHouse()
			if houseLimits then
				local displayNameLower = self.DisplayNameLower
				for _, record in ipairs(updateList) do
					if not record.Owner or record.Owner == displayNameLower then
						local houseId = record.HouseId or record.Id
						if houseId then
							local limits = houseLimits[houseId]
							if limits then
								local maxItems = GetHouseFurnishingPlacementLimit(houseId, 0) or 0
								local numItems = limits[0] or 0
								
								record.MaxItemsTraditional = maxItems
								record.NumItemsTraditional = numItems
							end
						end
					end
				end
			end
		end

		hideInaccessible = hideInaccessible and showHideInaccessibleToggle
		if cachedList then
			--self:SetIsLoading(true)
			self:BindHubList(cachedList, sortComparer, filter, categoryFilter, hideInaccessible)
		else
			self:ShowHubList(list, sortComparer, filter, categoryFilter, hideInaccessible, cacheKey, maxListCount)
		end
	end

	function EHH:RefreshHubTileAdditionalInfo(control)
		control.AdditionalInfo:SetHidden(true)

		local data = control.Data
		if "table" ~= type(data) then
			return
		end

		if data.VisitDate or data.GuildId or (not data.HouseId and not data.Owner) then
			return
		end

		local fxCount = tonumber(data.FXCount)
		local openHouseAgeDays = tonumber(data.OpenHouseAgeDays)
		local lastVisitAgeDays = tonumber(data.LastVisitAgeDays)
		local dimmed = "|ccccccc"

		do
			local unitLabel = control.FXCount.Units
			local valueLabel = control.FXCount.Value
			local valueString, unitString

			unitString = "FX"
			if fxCount and 0 < math.floor(fxCount) then
				valueString = string.format("%d", fxCount)
			else
				valueString = string.format("%snone|r", dimmed)
			end

			if control.IsInaccessible then
				unitString = string.format("|cff0000%s|r", unitString)
				valueString = string.format("|cff0000%s|r", valueString)
			end

			unitLabel:SetText(unitString)
			valueLabel:SetText(valueString)
		end

		do
			local unitLabel = control.OpenHouseTimestamp.Units
			local valueLabel = control.OpenHouseTimestamp.Value
			local valueString, unitString

			if openHouseAgeDays then
				unitString = "Open"
				if 1 > openHouseAgeDays then
					valueString = "today"
				else
					valueString = string.format("%d days", openHouseAgeDays)
				end
			else
				unitString = "Home"
				valueString = string.format("%sunlisted|r", dimmed)
			end

			if control.IsInaccessible then
				unitString = string.format("|cff0000%s|r", unitString)
				valueString = string.format("|cff0000%s|r", valueString)
			end

			unitLabel:SetText(unitString)
			valueLabel:SetText(valueString)
		end

		do
			local unitLabel = control.VisitTimestamp.Units
			local valueLabel = control.VisitTimestamp.Value
			local valueString, unitString

			unitString = "Last visit"
			if lastVisitAgeDays then
				if 1 > lastVisitAgeDays then
					valueString = "today"
				else
					valueString = string.format("%d days", lastVisitAgeDays)
				end
			else
				valueString = string.format("%snever|r", dimmed)
			end

			if control.IsInaccessible then
				unitString = string.format("|cff0000%s|r", unitString)
				valueString = string.format("|cff0000%s|r", valueString)
			end

			unitLabel:SetText(unitString)
			valueLabel:SetText(valueString)
		end

		control.AdditionalInfo:SetHidden(false)
	end

	function EHH:SetFavoriteIconState(icon, state)
		if state then
			icon.IsFavorite = true
			icon:SetTexture(Textures.ICON_FAVORITE)
			icon:SetColor(1, 0.35, 0.35, 1)
		else
			icon.IsFavorite = nil
			icon:SetTexture(Textures.ICON_FAVORITE_DISABLED)
			icon:SetColor(1, 1, 1, 1)
		end
	end

	function EHH:SetOpenHouseState(control, openHouse, showButton)
		local colors = control.Colors

		if openHouse and openHouse.O then
			local publishedDate = tonumber(openHouse.O)
			local today = self:GetDate()
			if not publishedDate or today == publishedDate then
				control.Data.OpenHouseAgeDays = 0
			else
				control.Data.OpenHouseAgeDays = today - publishedDate
			end
		else
			control.Data.OpenHouseAgeDays = nil
		end

		-- control.OpenHouseStamp:SetHidden(not openHouse)
		local isOpen = nil ~= control.Data.OpenHouseAgeDays
		local isDisabled = not control.Data.IsOwner
		control.OpenHouse.IsDisabled = isDisabled
		control.ClosedHouse.IsDisabled = isDisabled
		control.OpenHouse:SetHidden(not isOpen)
		control.ClosedHouse:SetHidden(isOpen)
	end

	function EHH:ToggleFavoriteHubEntry(entry)
		local houseId = entry.Data.HouseId
		local owner = entry.Data.Owner

		self:SetFavoriteIconState(entry.Favorite, self:ToggleFavoriteHouse(self.World, houseId, owner))
		self:InvalidateHubList("Favorites")

		if not self:IsHousingHubHidden() then
			self:RefreshHousingHub()
		end

		return true
	end

	function EHH:ToggleOpenHouseHubEntry(entry)
		local houseId = entry.Data.HouseId
		local isOpen = self:IsOpenHouse(houseId)
		local name = self:GetHouseName(houseId)
		local nickname = self:GetHouseNickname(houseId, entry.Data.Owner)

		if isOpen then
			local message = string.format("Remove the Open House listing for your |c00ffff%s|r (|c88ffff%s|r)?", name, nickname)
			self:ShowConfirmationDialog(message, function()
				self:ToggleOpenHouseHubEntryInternal(entry)
			end)
		else
			local message = string.format("List your |c00ffff%s|r (|c88ffff%s|r) as an Open House and publish any FX to the Community?\n\n" .. self.Defs.Text.OpenHouseDisclaimer, name, nickname)
			local listItems = self:GetOpenHouseCategoryListItems()
			local dialogData
			dialogData =
			{
				body = message,
				buttons =
				{
					{
						text = "Yes, add my home to the public Open Houses list",
						handler = function()
							local categoryList = self:GetCustomDialogList()
							local houseCategory = categoryList:GetSelectedItemValue()
							if houseCategory then
								entry.Data.HouseCategory = houseCategory

								local houseDescription = self:GetCustomDialogEditBox():GetText()
								entry.Data.HouseDescription = houseDescription

								self:ToggleOpenHouseHubEntryInternal(entry)
							else
								self:ShowAlertDialog("Please choose a Category to list your home in.", function()
									self:ShowCustomDialog(dialogData)
								end)
							end
						end,
					},
					{
						text = "Cancel",
						handler = function() end,
					},
				},
				edit =
				{
					defaultText = "Enter a house description or narrative backstory\n\n",
					editEnabled = true,
					maxInputChars = 500,
					maxLineCount = 5,
					text = nil, -- self:GetOpenHouseDescription(houseId),
				},
				list = listItems,
				listLabel = "Choose a category for this open house",
			}
			self:ShowCustomDialog(dialogData)
		end
	end

	function EHH:ToggleOpenHouseHubEntryInternal(entry)
		local houseId = entry.Data.HouseId
		local houseCategory = entry.Data.HouseCategory
		local houseDescription = entry.Data.HouseDescription
		local isOpen = self:ToggleOpenHouse(houseId, houseCategory, houseDescription)

		if nil == isOpen then
			self:ShowAlertDialog("Your Open House could not be listed. " ..
				"Please ensure that the Essential Housing Community app is installed and running. " ..
				"After doing so, please restart the game or type /reloadui.")
			return
		end

		local SUPPRESS_MESSAGE = true
		EHH.Effect:PublishFX(houseId, SUPPRESS_MESSAGE)

		local name = self:GetHouseName(houseId)
		local nickname = self:GetHouseNickname(houseId, entry.Data.Owner)
		local openHouse = self:GetOpenHouse(houseId)

		local message
		if isOpen then
			message = "will be listed as an Open House for the Community.\n\n" ..
				self.Defs.Text.OpenHouseListedDisclaimer .. "\n\n" ..
				"Please remember to set your Default Visitor Access to |cffffffVisitor|r or |cffffffLimited Visitor|r from\n" ..
				"|cffffffHousing Editor|r || |cffffffBrowse|r || |cffffffSettings tab|r"
		else
			message = "Open House listing will be removed after reloading the UI or logging out."
		end
		
		local prompt
		prompt = string.format("Your |c00ffff%s|r (|c88ffff%s|r) %s\n\n" ..
			"|cffff88Reload now to publish your changes immediately?",
			name, nickname, message)

		self:SetOpenHouseState(entry, openHouse, true)
		self:RefreshHubTileAdditionalInfo(entry)

		self:InvalidateHubList("Favorites")
		self:InvalidateHubList("My Homes")
		self:InvalidateHubList("Open Houses")
		self:InvalidateHubList("Recent")

		self:ShowConfirmationDialog(prompt, EHCommunity_DoubleReloadUI and EHCommunity_DoubleReloadUI or ReloadUI)
	end

	function EHH:DoesGuildhallExist(guildId)
		local guild = self:GetGuildById(guildId)
		if guild and guild.GuildhallOwner then
			return true
		end
		return false
	end

	function EHH:VisitGuildhall(guildId)
		local guild = self:GetGuildById(guildId)
		if guild and guild.GuildhallOwner then
			self:JumpToHouse(guild.GuildhallHouseId, guild.GuildhallOwner)
			return true
		end
		return false
	end
	
	function EHH:PerformHubTilePrimaryAction(entry, ...)
		if entry.Data.FurnitureLink then
			return self:ShowHubTileFurnitureLink(entry.Data.FurnitureLink)
		else
			return self:VisitHubEntry(entry, ...)
		end
	end

	function EHH:ShowHubTileFurnitureLink(furnitureLink)
		if furnitureLink then
			alt = alt or IsAltKeyDown()
			command = command or IsCommandKeyDown()
			ctrl = ctrl or IsControlKeyDown()
			shift = shift or IsShiftKeyDown()

			if (2 == button or (1 == button and (alt or command or ctrl or shift))) and CHAT_SYSTEM and CHAT_SYSTEM.textEntry and CHAT_SYSTEM.textEntry.editControl then
				StartChatInput(furnitureLink)
				CHAT_SYSTEM:Maximize()
				zo_callLater(function() StartChatInput("") end, 250)
			else
				ZO_PopupTooltip_SetLink(furnitureLink)
			end
		end
	end

	function EHH:VisitHubEntry(entry, houseId, outside)
		local houseName, owner

		if not entry or "string" == type(entry) then
			owner = entry

			if houseId then
				local house = self:GetHouseById(houseId)
				if house then
					houseName = house.Name
				else
					houseId = nil
					houseName = "home"
				end
			else
				houseName = "home"
			end
		else
			houseName = entry.Data.Name or "home"
			houseId = entry.Data.HouseId
			owner = entry.Data.Owner
		end

		if nil == outside and houseId and self:IsOwnerLocalPlayer(owner) then
			local dialogData =
			{
				body = string.format("Travel to your %s?", houseName or "home"),
				buttons =
				{
					{
						text = "Interior",
						handler = function()
							local INSIDE = false
							self:VisitHubEntry(owner, houseId, INSIDE)
						end,
					},
					{
						text = "Exterior",
						handler = function()
							local OUTSIDE = true
							self:VisitHubEntry(owner, houseId, OUTSIDE)
						end,
					},
					{
						text = "Cancel",
						handler = function() end,
					},
				},
			}
			self:SuppressDialogUI()
			self:ShowCustomDialog(dialogData)
--[[
			ClearMenu()
			AddMenuItem("Inside", function()
				local INSIDE = false
				self:VisitHubEntry(owner, houseId, INSIDE)
			end)
			AddMenuItem("Outside Entrance", function()
				local OUTSIDE = true
				self:VisitHubEntry(owner, houseId, OUTSIDE)
			end)
			ShowMenu(GuiRoot, nil, MENU_TYPE_TEXT_ENTRY_DROP_DOWN)

			local function OnMenuHidden()
				ZO_MenuBG:SetCenterColor(1, 1, 1, 1)
				ZO_MenuBG:SetEdgeColor(1, 1, 1, 1)
			end

			ZO_Menu:SetHandler("OnUpdate", function()
				local minX, minY, maxX, maxY = ZO_Menu:GetScreenRect()
				local mouseX, mouseY = GetUIMousePosition()
				local MARGIN = 15
				if mouseX < ( minX - MARGIN ) or mouseX > ( maxX + MARGIN ) or mouseY < ( minY - MARGIN ) or mouseY > ( maxY + MARGIN ) then
					ClearMenu()
				else
					ZO_MenuBG:SetCenterColor(0, 0, 0, 1)
					ZO_MenuBG:SetEdgeColor(0, 0, 0, 1)
				end
			end, "HousingHub")
			ZO_Menu:SetHandler("OnEffectivelyHidden", function()
				ZO_Menu:SetHandler("OnMouseExit", nil, "HousingHub")
				ZO_Menu:SetHandler("OnEffectivelyHidden", nil, "HousingHub")
				OnMenuHidden()
			end, "HousingHub")
]]
			return
		end

		if houseId or (owner and "" ~= owner) then
			self:HideHousingHub()
			local USE_DEFAULT_NOTIFICATION = nil
			self:JumpToHouse(houseId, owner, "hub", USE_DEFAULT_NOTIFICATION, outside)
			return true
		end

		return false
	end

	function EHH:ShareFXHubEntry(entry)
		if EHT and EHT.UI then
			local name = entry.Data.Name or "home"
			local houseId = entry.Data.HouseId
			local owner = entry.Data.Owner

			if not EHT.UI.ShareFXContextMenu or EHT.UI.ShareFXContextMenu.Window:IsHidden() then
				EHT.UI.ShowShareFXContextMenu(owner, houseId, TOPRIGHT, entry.ShareFXButton, BOTTOMRIGHT, 0, 0)
			else
				EHT.UI.HideShareFXContextMenu()
			end

			return true
		end

		return false
	end

	function EHH:ViewHubGuild(entry)
		if entry and entry.Data and entry.Data.GuildIndex then
			self:ShowHousingHubView("Guilds", entry.Data.GuildIndex)
		end
	end

	function EHH:VisitHubGuildhall(entry)
		if entry and entry.Data and entry.Data.GuildIndex then
			if self:VisitGuildhall(entry.Data.GuildId) then
				self:HideHousingHub()
			end
		end
	end

	function EHH:IsHousingHubHidden()
		return not SCENE_MANAGER:IsShowing(self.HubSceneName)
	end

	function EHH:ShowHousingHub(forceShow)
		if forceShow then
			SCENE_MANAGER:Show(self.HubSceneName)
		else
			SCENE_MANAGER:Toggle(self.HubSceneName)
		end
	end

	function EHH:HideHousingHub()
		if SCENE_MANAGER:IsShowing(self.HubSceneName) then
			SCENE_MANAGER:ShowBaseScene()
		end
	end

	function EHH:RefreshHousingHub()
		local ui = self:SetupHousingHub()
		self:ShowHousingHubView()

		local SUPPRESS_DIALOG = true
		self:SetNotificationPanelHidden("InstallCommunityApp", self:CheckCommunityConnection(SUPPRESS_DIALOG))
	end

	function EHH:GetHousingHubTabButtonControl(tabKey)
		local ui = self:GetDialog("HousingHub")
		if not ui then
			return nil
		end

		local tabButtons = ui.TabButtons
		for index, tabButton in ipairs(tabButtons) do
			if tabButton.Key == tabKey then
				return tabButton
			end
		end

		return nil
	end

	function EHH:RefreshHousingHubTabs()
		do
			local tabButton = self:GetHousingHubTabButtonControl("Guest Journal")
			if tabButton then
				local hasUnviewedGuests = self:HasUnviewedGuests()
				if hasUnviewedGuests then
					tabButton.NewIcon.AnimationTimeline:PlayFromStart()
				else
					tabButton.NewIcon.AnimationTimeline:Stop()
				end

				tabButton.NewIcon:SetHidden(not hasUnviewedGuests)
			end
		end

		if self:IsCommunityMetaDataLoaded() then
			local tabButton = self:GetHousingHubTabButtonControl("Live Streams")
			if tabButton then
				local areStreamsLive = self:AreStreamChannelsLive()
				if areStreamsLive then
					tabButton.NewIcon.AnimationTimeline:PlayFromStart()
				else
					tabButton.NewIcon.AnimationTimeline:Stop()
				end

				tabButton.NewIcon:SetHidden(not areStreamsLive)
			end
		end
	end

	function EHH:OnHousingHubShown()
		self:RefreshHousingHubTabs()
	end

	function EHH:OnHousingHubHidden()
		EVENT_MANAGER:UnregisterForUpdate("EssentialHousingHub.RetryShowHousingHubView")
	end
end

function EssentialHousingHub.ShowHousingHubAction()
	return EssentialHousingHub:ShowHousingHub()
end

function EssentialHousingHub.TravelToPrimaryHome()
	local PRIMARY_HOME = nil
	local LOCAL_PLAYER = nil
	return EssentialHousingHub:JumpToHouse(PRIMARY_HOME, LOCAL_PLAYER)
end

function EssentialHousingHub.TravelToFavoriteHome(favoriteIndex)
	if favoriteIndex then
		return EssentialHousingHub:JumpToFavoriteHouse(favoriteIndex)
	end
end

do
	local notifiedOwners = {}

	function EHH:ConfirmNotifyOpenHouseOwner(houseId, owner)
		if not owner or not houseId then
			return
		end

		local house = self:GetHouseById(houseId)
		if not house then
			return
		end
		local houseName = house.Name

		owner = string.lower(owner)
		if not self:IsOpenHouse(houseId, owner) then
			return
		end

		local notificationKey = string.format("%s_%s", owner, houseName)
		if notifiedOwners[notificationKey] then
			self:ShowAlertDialog(string.format("%s's %s still appears to be inaccessible at the moment - but they have been notified. :)", owner, houseName))
			return
		end

		self:ShowConfirmationDialog(string.format(
			"|c00ffff%s|cffffff's |c00ffff%s|cffffff does not appear to be open for visitors (most likely a simple oversight).\n\n" ..
			"|cffff00Would you like to automatically notify this homeowner to make them aware?", owner, houseName),
			function()
				if not notifiedOwners[notificationKey] then
					notifiedOwners[notificationKey] = true

					EHH.Effect:OpenMailbox()
					SendMail(owner, "Open House Access", string.format(
						"Hello! This is an automated message, sent using %s, just to let you know that I was " ..
						"unable to visit the Open House you are hosting at your %s. If possible, would you be able to check that " ..
						"home's Settings in the Housing Editor to verify that your Default Visitor Access is set to Visitor or Limited Visitor? " ..
						"Thank you so much!", self.Title, houseName))

					zo_callLater(function()
						EHH.Effect:CloseMailbox()
						zo_callLater(function()
							self:ShowAlertDialog(string.format("An in-game mail has been sent to %s regarding visitor access for their %s. " ..
								"Thanks for letting them know!", owner, houseName))
						end, 500)
					end, 1000)
				end
			end)
	end
end

---[ Hint ]---

do
	local hideDuration, hideCallback

	function EHH:SetupHintDialog()
		local ui = self:GetDialog("Hint")
		if nil == ui then
			ui = self:CreateDialog("Hint")

			local prefix = "EHHHintDialog"
			local settingsName = "HintDialog"
			local w = WINDOW_MANAGER:CreateTopLevelWindow(prefix)

			ui.Window = w
			w:SetDimensions(100, 100)
			w:SetMovable(true)
			w:SetMouseEnabled(true)
			w:SetClampedToScreen(true)
			w:SetResizeHandleSize(0)
			w:SetAlpha(0.8)
			w:SetHidden(true)

			local settings = self:GetDialogSettings(settingsName)

			if settings.Left and settings.Top then
				w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top)
			else
				w:SetAnchor(CENTER, GuiRoot, CENTER, 0, 200)
			end

			w:SetHandler("OnMoveStart", function()
				HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".HideHint")
			end)

			w:SetHandler("OnMoveStop", function()
				self:SaveDialogSettings(settingsName, w)

				if hideDuration then
					HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".HideHint")
					HUB_EVENT_MANAGER:RegisterForUpdate(self.Name .. ".HideHint", hideDuration, function(...) return self:HideHint(...) end)
				end
			end)

			local l = WINDOW_MANAGER:CreateControl(prefix .. "InstructionLabel", w, CT_LABEL)
			ui.Hint = l
			l:SetFont("$(BOLD_FONT)|$(KB_22)|soft-shadow-thin")
			l:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			l:SetColor(1, 1, 1, 1)
			l:SetAnchor(CENTER, w, CENTER, 0, 0)
			l:SetMaxLineCount(6)
		end

		return ui, ui.Window, ui.Hint
	end

	function EHH:ShowHint(msg, duration, callback)
		local ui, w, l = self:SetupHintDialog()
		if not ui or not w or not l then return end

		l:SetText(msg)
		w:SetDimensions(l:GetTextDimensions())
		w:SetHidden(false)

		hideDuration = duration
		hideCallback = callback

		if duration then
			HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".HideHint")
			HUB_EVENT_MANAGER:RegisterForUpdate(self.Name .. ".HideHint", hideDuration, function(...) return self:HideHint(...) end)
		end
	end

	function EHH:HideHint()
		HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".HideHint")

		local ui, w, l = self:SetupHintDialog()
		if not ui or not w or not l then return end

		w:SetHidden(true)

		if hideCallback then hideCallback() end
	end
end

---[ Lore Reader ]---

function EHH:ShowBook(title, body, medium)
	LORE_READER:Show(title, body, medium or 1, true)
	PlaySound("Book_Open")
end

function EHH:HideBook()
	SCENE_MANAGER:Hide("loreReaderInteraction")
	PlaySound("Book_Close")
end

function EHH:IsBookHidden()
	return LORE_READER.title:IsHidden()
end

function EHH:OnGuestbookInterval()
	if self:IsBookHidden() then
		HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".OnGuestbookInterval")
		KEYBIND_STRIP:RemoveKeybindButtonGroup(self.Defs.Keybinds.Guestbook)
		KEYBIND_STRIP:RemoveKeybindButtonGroup(self.Defs.Keybinds.GuestbookAdmin)
	end
end

do
	local addedKeybinds = false

	function EHH:ShowGuestbook(forceOpen, owner, houseId)
		if not forceOpen and not EHH.Effect:CanShowGuestbook() then
			return false
		end

		if not self:IsBookHidden() then
			-- Avoid refreshing unnecessarily.
			return false
		end

		if not houseId then
			houseId = self:GetHouseId()
			owner = self:GetOwner()
		end

		local signatures = self:GetGuestbook(owner, houseId)

		if "table" ~= type(signatures) then
			return false
		end

		local signatureList = {}
		local groupDate, signatureDate, ts
		local line, dateLine, indent = 0, 0, 0
		local localPlayerSignature = string.format("(%s)", self.DisplayNameLower)

		for index, signature in ipairs(signatures) do
			if "table" == type(signature) and 2 <= #signature then
				ts = tonumber(signature[2])

				if ts then
					signatureDate = FormatAchievementLinkTimestamp(signature[2])

					if not groupDate or groupDate ~= signatureDate then
						groupDate = signatureDate
						line = line + 1 indent = string.rep(" ", 3 - round(3 * math.sin(0.8 * (line % 15) * math.pi)))
						dateLine = dateLine + 1

						if 0 ~= dateLine % 3 then
							table.insert(signatureList, "")
						end
						table.insert(signatureList, "")
						table.insert(signatureList, indent .. groupDate)
					end

					line = line + 1 indent = string.rep(" ", round(5 * math.sin(0.8 * (line % 15) * math.pi)))
					local signatureString = signature[1]
					if PlainStringFind(string.lower(signatureString), localPlayerSignature) then
						signatureString = string.format("|c0011bb%s|c000000", signatureString)
					end

					table.insert(signatureList, indent .. signatureString)
				end
			end
		end

		if 0 == #signatureList then
			table.insert(signatureList, "\n\n|c003090The journal is empty\n ...though you could change that.|r")
		end

		if not self:IsOpenHouse(houseId, owner) then
			return false
		end

		local title = self:GetOpenHouseName(houseId, owner) or ""
		local preface = string.format("\n\n%s wishes you a pleasant visit and politely asks guests to sign in...\n", owner)

		self:ShowBook("|c000000" .. title, "|c000000" .. preface .. table.concat(signatureList, "\n"))

		KEYBIND_STRIP:RemoveKeybindButtonGroup(self.Defs.Keybinds.Guestbook)
		KEYBIND_STRIP:RemoveKeybindButtonGroup(self.Defs.Keybinds.GuestbookAdmin)
		KEYBIND_STRIP:AddKeybindButtonGroup(self.Defs.Keybinds.Guestbook)
		if self:IsOwner() then
			KEYBIND_STRIP:AddKeybindButtonGroup(self.Defs.Keybinds.GuestbookAdmin)
		end

		HUB_EVENT_MANAGER:RegisterForUpdate(self.Name .. ".OnGuestbookInterval", 200, function(...) return self:OnGuestbookInterval(...) end)
		return true
	end
end

function EHH:SignGuestbook()
	local signatures = self:GetGuestbook()

	if "table" ~= type(signatures) then
		return false
	end

	local hasSigned = false
	local myself = string.lower(self:GetCurrentSignerName())

	for index, signature in ipairs(signatures) do
		if "string" == type(signature[1]) and myself == string.lower(signature[1]) then
			hasSigned = true
			break
		end
	end

	if self:SignCommunityGuestbook() then
		self:DismissGuestbook(true)
		self:OnGuestJournalSigned()

		if hasSigned then
			self:ShowAlertDialog(
				"You erase your old signature and sign at the end of the list." ..
				"\n\n" ..
				"Please note that your signature will only be visible to others once you |cffff88/reloadui|r or relog.")
		else
			self:ShowAlertDialog(
				"Your signature has been recorded." ..
				"\n\n" ..
				"Please note that your signature will only be visible to others once you |cffff88/reloadui|r or relog.")
		end
	end

	return true
end

function EHH:ResetGuestbook(confirmed)
	if not self:IsOwner() then
		self:ShowAlertDialog("This is not your home.\n\n" ..
			"It would be rude to tear the pages from a Guest Journal that isn't your own.")
		return false
	end

	local signatures = self:GetGuestbook()

	if "table" ~= type(signatures) or 0 >= #signatures then
		self:ShowAlertDialog("The guest journal already appears to be empty.")
		return false
	end

	if true ~= confirmed then
		zo_callLater(function()
			self:ShowConfirmationDialog(
				"|cff8888Warning: This cannot be undone.\n\n" ..
				"|cffffffReset your Guest Journal and reload the UI?",
				function() zo_callLater(function() self:ResetGuestbook(true) end, 500) end)
		end, 500)
		return false
	end

	local result, message = self:RequestResetGuestbook()
	if result then
		if EHCommunity_DoubleReloadUI then
			EHCommunity_DoubleReloadUI()
		else
			ReloadUI()
		end
		return true
	end

	self:ShowAlert("", string.format("Request failed:\n%s", message or "Unknown exception."))
	return false
end

function EHH:DismissGuestbook(suppressDialogs)
	if not self:IsBookHidden() then
		self.Effect:DismissGuestbook()
		self:HideBook()
-- /script Hub:SetSetting("ShowMyGuestJournals", nil)
		if true ~= suppressDialogs then
			if self:IsOwner() and not self:GetSetting("HideMyGuestJournals") then
				self:ShowConfirmationDialog(
					"The guest journal has been dismissed.\n\n" ..
					"|cffff88Would you like to hide your homes' Guest Journals on future visits?|r\n\n" ..
					"Note that you may summon the Guest Journal at any time from the " ..
					"|cffffffHousing Hub Widget\n|ac" .. self.Textures.ICON_HUB_WIDGET,
					function()
						self:SetSetting("ShowMyGuestJournals", false)
					end
				)
			elseif not self:IsOwner() and not self:GetSetting("HideSignedGuestJournals") then
				self:ShowConfirmationDialog(
					"The guest journal has been dismissed.\n\n" ..
					"|cffff88Would you like to hide other players' Guest Journals that you have already signed?|r\n\n" ..
					"Note that you may summon the Guest Journal at any time from the " ..
					"|cffffffHousing Hub Widget\n|ac" .. self.Textures.ICON_HUB_WIDGET,
					function()
						self:SetSetting("ShowSignedGuestJournals", false)
					end
				)
			end
		end
	end
end

---[ Folium Discognitum ]---

function EHH:OnLoreBookInterval()
	if self:IsBookHidden() then
		if not self:IsLorebookSelectionDialogHidden() then
			self:EnterUIMode()
		end

		EHH.Effect:SetCanShowFoliumDiscognitum( false )
		EHH.Effect:SetCanShowLoreBook( false )

		zo_callLater( function()
			EHH.Effect:SetCanShowFoliumDiscognitum( true )
			EHH.Effect:SetCanShowLoreBook( true )
		end, 200 )

		HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. "OnLoreBookInterval")
	end
end

do
	function EHH:IsLorebookSelectionDialogHidden()
		local ui = self.LorebookSelectionDialog
		return not ui or ui.Window:IsHidden()
	end

	function EHH:SetupLorebookSelectionDialog( categoryId, categoryLabel )
		local ui = self.LorebookSelectionDialog

		if ui then
			ui.CategoryId = categoryId
		else
			ui = { }
			self.LorebookSelectionDialog = ui
			ui.CategoryId = categoryId

			local prefix = "EHHLorebookSelectionDialog"
			local c, w

			w = CreateWindow( prefix, CreateAnchor( CENTER, GuiRoot, CENTER ), nil, 400, 200, false, false, true )
			ui.Window = w
			w:SetHidden( true )
			w:SetAlpha( 0.9 )
			w:SetMouseEnabled( false )
			w:SetResizeHandleSize( 0 )
			w:SetDrawTier( DT_LOW )
			w:SetDrawLayer( DL_BACKGROUND )

			ui.Outline, ui.Backdrop = CreateWindowBackdrop( prefix .. "Outline", prefix .. "Backdrop", w, 10, 10 )

			c = CreateLabel( prefix .. "Category", w, "", CreateAnchor( TOP, w, TOP, 0, 15 ), nil, nil, nil, TEXT_ALIGN_CENTER )
			ui.CategoryLabel = c
			SetLabelFont( c, 22, false, true )
			c:SetColor( 0.1, 1, 1, 1 )

			c = CreateLabel( prefix .. "Directions", w, "Choose a collection and book...", CreateAnchor( TOP, ui.CategoryLabel, BOTTOM, 0, 15 ) )
			ui.DirectionsLabel = c

			c = EHH.Picklist:New( prefix .. "Collection", w, TOP, ui.DirectionsLabel, BOTTOM, 0, 10, 380 )
			ui.Collection = c
			c:SetSorted( true )

			c = EHH.Picklist:New( prefix .. "Book", w, TOP, ui.Collection:GetControl(), BOTTOM, 0, 10, 380 )
			ui.Book = c
			c:SetSorted( true )

			c = CreateTexture( prefix .. "CloseButton", w, CreateAnchor( BOTTOM, w, BOTTOM, 0, 0 ), nil, 100, 30 )
			ui.CloseButton = c
			c:SetDrawLayer(DL_CONTROLS)
			c:SetColor( 0, 0.3, 0.4, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseUp", function( control )
				ui.Window:SetAlpha( 0 )
				zo_callLater( function() if ui.Window:GetAlpha() == 0 then ui.Window:SetHidden( true ) end end, 500 )
			end )

			c = CreateButtonLabel( prefix .. "CloseButtonLabel", w, "Close", CreateAnchor( CENTER, ui.CloseButton, CENTER, 0, 0 ) )
			ui.CloseButtonLabel = c

			local function OnCheckLorebookSelectionDialog()
				local success = false
				local maxDistance = 10
				local x, y, z = GetPlayerWorldPositionInHouse()

				if x or y or z then
					local dx, dy, dz = x - ( ui.PlayerX or 0 ), y - ( ui.PlayerY or 0 ), z - ( ui.PlayerZ or 0 )

					if maxDistance >= math.abs( dx ) and maxDistance >= math.abs( dy ) and maxDistance >= math.abs( dz ) then
						success = true
					end
				end

				if not success then
					ui.Window:SetHidden( true )
					HUB_EVENT_MANAGER:UnregisterForUpdate( "EHH.OnCheckLorebookSelectionDialog" )
				end
			end

			ui.Window:SetHandler( "OnShow", function( control )
				local category = ui.CategoryId
				if not category then return end

				ui.Book:ClearItems()
				ui.Book:Refresh()
				ui.Collection:ClearItems()

				for collection = 1, 300 do
					local text = GetLoreCollectionInfo( category, collection )

					if "" ~= ( text or "" ) then
						ui.Collection:AddItem( text, nil, collection )
					else
						break
					end
				end

				ui.Collection:Refresh()
				self:HideInteractionPrompt()

				ui.PlayerX, ui.PlayerY, ui.PlayerZ = GetPlayerWorldPositionInHouse()
				ui.Window:SetAlpha( 1 )
				self:EnterUIMode()

				HUB_EVENT_MANAGER:RegisterForUpdate( "EHH.OnCheckLorebookSelectionDialog", 100, OnCheckLorebookSelectionDialog )
			end )

			ui.Collection:AddHandler( "OnSelectionChanged", function( control, item )
				local category = ui.CategoryId
				if not category or not item then return end

				local collection = tonumber( item.Value )
				if not collection then return end

				ui.CollectionId = collection
				ui.Book:ClearItems()

				for book = 1, 300 do
					local text = GetLoreBookInfo( category, collection, book )

					if "" ~= ( text or "" ) then
						ui.Book:AddItem( text, nil, book )
					else
						break
					end
				end

				ui.Book:Refresh()
			end )

			ui.Book:AddHandler( "OnSelectionChanged", function( control, item )
				local category, collection = ui.CategoryId, ui.CollectionId
				if not category or not collection or not item then return end

				local book = tonumber( item.Value )
				if not book then return end

				if self:ShowSpecificBook( category, collection, book ) then
					--ui.Window:SetHidden( true )
				end
			end )
		end

		ui.CategoryLabel:SetText( categoryLabel )

		return ui
	end

	function EHH:ShowSpecificBook( category, collection, book )
		local body, medium, showTitle = ReadLoreBook( category, collection, book )
		local title, result

		if "" == ( body or "" ) then
			body = "You have never seen this volume before -- or perhaps you simply cannot recall?\n\nShalidor may be able to provide you with answers..."
			result = false
		elseif showTitle then
			title = GetLoreBookInfo( category, collection, book )
			result = true
		end

		self:ShowBook( title and ( "|c000000" .. title ) or "", "|c000000\n" .. body )
		EHH.Effect:SetCanShowFoliumDiscognitum(false)
		EHH.Effect:SetCanShowLoreBook(false)
		HUB_EVENT_MANAGER:RegisterForUpdate(self.Name .. "OnLoreBookInterval", 100, function(...) return self:OnLoreBookInterval(...) end)

		return result
	end

	function EHH:ShowFoliumDiscognitum(title, category)
		category = tonumber(category)

		local ui = self:SetupLorebookSelectionDialog(category, title)
		ui.Window:SetHidden( false )

		return true
	end
end

---[ Interaction Prompt ]---

function EHH:RegisterInteractionKeybinds()
	--KEYBIND_STRIP:RemoveKeybindButtonGroup(self.Defs.Keybinds.GuestbookInteract)
	--KEYBIND_STRIP:AddKeybindButtonGroup(self.Defs.Keybinds.GuestbookInteract)
	--InsertNamedActionLayerAbove("Essential Housing Tools (Interaction)", GetString(SI_KEYBINDINGS_LAYER_GENERAL))
end

function EHH:UnregisterInteractionKeybinds()
	--RemoveActionLayerByName("Essential Housing Tools (Interaction)")
	--KEYBIND_STRIP:RemoveKeybindButtonGroup(self.Defs.Keybinds.GuestbookInteract)
end

function EHH:ShowInteractionPrompt(keybind, label, callback, rightAlign)
	local ui = self:GetDialog("InteractionPrompt")
	if not ui then
		ui = self:CreateDialog("InteractionPrompt")

		local prefix = "EHHInteractionPrompt"

		local win = WINDOW_MANAGER:CreateTopLevelWindow(prefix)
		ui.Window = win
		win:SetDimensionConstraints(200, 60, 200, 60)
		win:SetHidden(true)
		win:SetAlpha(0.9)
		win:SetMovable(false)
		win:SetMouseEnabled(false)
		win:SetClampedToScreen(true)
		win:SetResizeHandleSize(0)
		win:SetDrawTier(DT_HIGH)
		win:SetDrawLayer(DL_TEXT)
		win:SetAnchor(TOPRIGHT, GuiRoot, CENTER, -60, 0)

		local btn = WINDOW_MANAGER:CreateControlFromVirtual(prefix .. "KeybindButton", win, "ZO_KeybindButton")
		ui.Button = btn
		btn:SetAnchorFill()
		--btn:SetupStyle(KEYBIND_STRIP_STANDARD_STYLE)
		--btn:SetNormalTextColor(ZO_NORMAL_TEXT)
		--btn.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		
		ApplyTemplateToControl(btn, "ZO_KeybindButton_Keyboard_Template")
	end

	ui.Window:SetHidden(true)
	ui.Button:SetText(label)

	if keybind then
		--ZO_KeybindButtonTemplate_Setup(ui.Button, keybind, callback, label)
		--ui.Button:SetKeybind(keybind)
		ui.Button:ShowKeyIcon(false)
		ui.Button:SetEnabled(true)
		ui.Button:SetKeybindEnabled(true)
		ui.Button:SetCallback(callback)
--[[
		local DO_NOT_SHOW_UNBOUND = false
		local PREFER_KEYBOARD_MODE = false
		local DO_NOT_SHOW_AS_HOLD = false
		ui.Button:SetKeybind(keybind, DO_NOT_SHOW_UNBOUND, keybind, PREFER_KEYBOARD_MODE, DO_NOT_SHOW_AS_HOLD)
]]
		--self:RegisterInteractionKeybinds()
	else
		--ui.Button:SetKeybind(nil)
		ui.Button:ShowKeyIcon(false)
		ui.Button:SetEnabled(false)
		ui.Button:SetKeybindEnabled(false)
		ui.Button:SetCallback(nil)
		--self:UnregisterInteractionKeybinds()
	end

	if not IsUIHidden then
		ui.Window:SetHidden(false)
		self.HiddenDialogs["INTERACTION_PROMPT"] = false
	else
		self.HiddenDialogs["INTERACTION_PROMPT"] = true
	end
end

function EHH:HideInteractionPrompt()
	local ui = self:GetDialog("InteractionPrompt")
	if ui then
		self.HiddenDialogs["INTERACTION_PROMPT"] = false
		ui.Window:SetHidden(true)
		ui.Button:SetEnabled(false)
	end
	self:UnregisterInteractionKeybinds()
end

function EHH:IsInteractionPromptHidden()
	local ui = self:GetDialog("InteractionPrompt")
	return not ui or ui.Window:IsHidden()
end

function EHH:GetInteractionPromptLabel()
	local ui = self:GetDialog("InteractionPrompt")
	if not ui or not ui.Button or not ui.Button.nameLabel or ui.Window:IsHidden() then return "" end
	return ui.Button.nameLabel:GetText() or ""
end

---[ Community App Dialog ]---

function EHH:HideCommunityAppDialog()
	local ui = self:GetDialog("CommunityAppInfo")
	if ui then
		ui.Window:SetHidden(true)
	end
end

function EHH:ShowCommunityAppDialog()
	local ui = self:GetDialog("CommunityAppInfo")
	if not ui then
		ui = self:CreateDialog("CommunityAppInfo")

		local prefix = "CommunityAppDialog"
		local height, width = 566, 600
		local baseDrawLevel = 1000
		local b, btn, c, win

		local function tip(control, msg)
			self:SetTooltip(msg, control)
		end

		win = WINDOW_MANAGER:CreateTopLevelWindow(prefix)
		ui.Window = win
		win:SetDimensionConstraints(width, height, width, height)
		win:SetHidden(true)
		win:SetAlpha(0.85)
		win:SetMovable(true)
		win:SetMouseEnabled(true)
		win:SetClampedToScreen(true)
		win:SetResizeHandleSize(0)
		win:SetDrawTier(DT_HIGH)
		win:SetDrawLayer(DL_TEXT)
		win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

		c = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
		ui.BackdropShadow = c
		c:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
		c:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0)
		c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
		c:SetDrawLevel(baseDrawLevel - 2)
		c:SetTexture(Textures.Solid)
		c:SetVertexColors(2 + 8, 0, 0.3, 0.4, 1)
		c:SetVertexColors(1 + 4, 0.1, 0.1, 0.1, 1)

		c = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
		ui.Backdrop = c
		c:SetAnchor(TOPLEFT, win, TOPLEFT, 2, 2)
		c:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -2, -2)
		c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
		c:SetDrawLevel(baseDrawLevel - 1)
		c:SetTexture(Textures.Solid)
		c:SetVertexColors(1 + 4, 0, 0.3, 0.4, 1)
		c:SetVertexColors(2 + 8, 0.1, 0.1, 0.1, 1)

		b = WINDOW_MANAGER:CreateControl(prefix .. "Body", win, CT_CONTROL)
		ui.Body = b
		b:SetAnchor(LEFT, win, LEFT, 15, 0)
		b:SetAnchor(RIGHT, win, RIGHT, -15, 0)
		b:SetDrawLevel(baseDrawLevel)
		b:SetResizeToFitDescendents(true)

		c = WINDOW_MANAGER:CreateControl(nil, b, CT_LABEL)
		ui.Title = c
		c:SetAnchor(TOPLEFT, b, TOPLEFT, 0, 0)
		c:SetAnchor(TOPRIGHT, b, TOPRIGHT, 0, 0)
		c:SetDrawLevel(baseDrawLevel)
		c:SetFont("$(BOLD_FONT)|$(KB_36)|soft-shadow-thick")
		c:SetMouseEnabled(false)
		c:SetText("Join Our Community")
		c:SetColor(0.5, 1, 1, 1)
		c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

		c = WINDOW_MANAGER:CreateControl(nil, b, CT_LABEL)
		ui.Prologue = c
		c:SetAnchor(TOP, ui.Title, BOTTOM, 0, 15)
		c:SetDrawLevel(baseDrawLevel)
		c:SetFont("$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thick")
		c:SetMouseEnabled(false)
		c:SetText("|cffffffThe following |cffff00free|cffffff features are available to all Community members:")
		c:SetMaxLineCount(2)
		c:SetColor(1, 1, 1, 1)
		c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		c:SetWidth(width - 10)

		c = WINDOW_MANAGER:CreateControl(nil, b, CT_LABEL)
		ui.Features = c
		c:SetAnchor(TOPLEFT, ui.Prologue, BOTTOMLEFT, 54, 15)
		c:SetAnchor(TOPRIGHT, ui.Prologue, BOTTOMRIGHT, -28, 15)
		c:SetDrawLevel(baseDrawLevel)
		c:SetFont("$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thick")
		c:SetMouseEnabled(false)
		c:SetMaxLineCount(12)
		c:SetText("" ..
			"Publicly invite all Community members to visit by hosting an Open House at any or all of your homes.\n\n" ..
			"Allow your guests to sign in and see who stopped by with the Guest Journal that is automatically included in each of your Open Houses.\n\n" ..
			"Easily publish all of your home's visual FX** to all Community players (even when they are offline) and without the need to share via chat, email or guild.")
		c:SetColor(1, 1, 0.4, 1)

		c = WINDOW_MANAGER:CreateControl(nil, b, CT_LABEL)
		ui.Addendum = c
		c:SetAnchor(TOP, ui.Features, BOTTOM, 0, 4)
		c:SetDrawLevel(baseDrawLevel)
		c:SetFont("$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thick")
		c:SetMouseEnabled(false)
		c:SetText("** Maximum storage capacity allows for approximately 3,000 FX")
		c:SetColor(1, 1, 1, 1)

		c = WINDOW_MANAGER:CreateControl(nil, b, CT_LABEL)
		ui.Epilogue = c
		c:SetAnchor(TOP, ui.Features, BOTTOM, -12, 40)
		c:SetDrawLevel(baseDrawLevel)
		c:SetFont("$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thick")
		c:SetMouseEnabled(false)
		c:SetText("" ..
			"|cffffffSelect your platform below for a " ..
			"|cffff00simple, 1-minute Setup Guide|cffffff " ..
			"and join our growing Community of builders, designers and creators...")
		c:SetColor(1, 1, 1, 1)
		c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		c:SetMaxLineCount(4)
		c:SetWidth(width - 40)

		c = WINDOW_MANAGER:CreateControl(nil, b, CT_TEXTURE)
		btn = c
		ui.WindowsButton = c
		c:SetAnchor(TOP, ui.Epilogue, BOTTOM, -170, 25)
		c:SetDimensions(150, 50)
		c:SetDrawLevel(baseDrawLevel)
		c:SetTexture(Textures.Solid)
		c:SetColor(0, 0.7, 0.7, 1)
		c:SetMouseEnabled(true)
		c:SetHandler("OnMouseEnter", OnFormButtonMouseEnter)
		c:SetHandler("OnMouseExit", OnFormButtonMouseExit)
		c:SetHandler("OnMouseDown", function()
			self:HideCommunityAppDialog()
			self:ShowConfirmationDialog(
				"|cffffffInstallation on |c00ffffWindows|cffffff takes less than 60 seconds " ..
				"and requires NO additional download - the app is already included in " ..
				"Essential Housing Tools...\n\n" ..
				"A one-time installation is all that is needed to get started.\n\n" .. 
				"|cffff00Watch the " .. zo_iconFormat(Textures.ICON_YOUTUBE, 24, 24) .. "|cffff00 " ..
				"Installation Guide video now?",
				function() self:ShowURL(self.Defs.Urls.SetupCommunityPC) end)
		end)

		c = WINDOW_MANAGER:CreateControl(nil, btn, CT_LABEL)
		btn.Label = c
		c:SetAnchor(CENTER, btn, CENTER, 0, 0)
		c:SetDrawLevel(baseDrawLevel)
		c:SetFont("$(BOLD_FONT)|$(KB_22)|soft-shadow-thick")
		c:SetMouseEnabled(false)
		c:SetText("Windows")
		c:SetColor(1, 1, 1, 1)

		OnFormButtonMouseExit(btn)

		c = WINDOW_MANAGER:CreateControl(nil, b, CT_TEXTURE)
		btn = c
		ui.MacButton = c
		c:SetAnchor(TOP, ui.Epilogue, BOTTOM, 0, 25)
		c:SetDimensions(150, 50)
		c:SetDrawLevel(baseDrawLevel)
		c:SetTexture(Textures.Solid)
		c:SetColor(0, 0.7, 0.7, 1)
		c:SetMouseEnabled(true)
		c:SetHandler("OnMouseEnter", OnFormButtonMouseEnter)
		c:SetHandler("OnMouseExit", OnFormButtonMouseExit)
		c:SetHandler("OnMouseDown", function()
			local guideVideo = function()
				self:ShowConfirmationDialog(
					"|cffff00Would you like to watch the Community for Mac setup guide video?",
					function() self:ShowURL(self.Defs.Urls.SetupCommunityMac) end)
			end

			self:HideCommunityAppDialog()
			self:ShowConfirmationDialog(
				"|cffffffInstallation on |c00ffffMac|cffffff is easy - just download the " ..
				"Essential Housing Community for Mac app package, right-click the package and " ..
				"choose \"Open\".\n\n" ..
				"The package installer guides you through the setup process in seconds.\n\n" ..
				"|cffff00Would you like to download the |c00ffffMac|cffff00 app now?",
				function() self:ShowURL(self.Defs.Urls.DownloadCommunityMac) guideVideo() end,
				function() guideVideo() end)
		end)

		c = WINDOW_MANAGER:CreateControl(nil, btn, CT_LABEL)
		btn.Label = c
		c:SetAnchor(CENTER, btn, CENTER, 0, 0)
		c:SetDrawLevel(baseDrawLevel)
		c:SetFont("$(BOLD_FONT)|$(KB_22)|soft-shadow-thick")
		c:SetMouseEnabled(false)
		c:SetText("Mac")
		c:SetColor(1, 1, 1, 1)

		OnFormButtonMouseExit(btn)

		c = WINDOW_MANAGER:CreateControl(nil, b, CT_TEXTURE)
		btn = c
		ui.CancelButton = c
		c:SetAnchor(TOP, ui.Epilogue, BOTTOM, 170, 27)
		c:SetDimensions(135, 46)
		c:SetDrawLevel(baseDrawLevel)
		c:SetTexture(Textures.Solid)
		c:SetColor(0, 0.6, 0.6, 1)
		c:SetMouseEnabled(true)
		c:SetHandler("OnMouseEnter", OnFormButtonMouseEnter)
		c:SetHandler("OnMouseExit", OnFormButtonMouseExit)
		c:SetHandler("OnMouseDown", function()
			self:HideCommunityAppDialog()
		end)

		c = WINDOW_MANAGER:CreateControl(nil, btn, CT_LABEL)
		btn.Label = c
		c:SetAnchor(CENTER, btn, CENTER, 0, 0)
		c:SetDrawLevel(baseDrawLevel)
		c:SetFont("$(BOLD_FONT)|$(KB_22)|soft-shadow-thick")
		c:SetMouseEnabled(false)
		c:SetText("Maybe Later")
		c:SetColor(0.85, 0.85, 0.85, 1)

		OnFormButtonMouseExit(btn)
	end

	self:HideHousingHub()
	ui.Window:SetHidden(false)
	self:EnterUIMode(250)

	return ui
end

---[ Checkbox Control ]---

do
	EHH.Checkbox = ZO_Object:Subclass()

	local base = EHH.Checkbox

	local behaviors = {}
	base.EventBehaviors = behaviors
	behaviors.HardwareOnly = 1
	behaviors.AlwaysRaise = 2
	behaviors = nil

	local states = {}
	base.States = states
	states.Indeterminate = 0
	states.Unchecked = 1
	states.Checked = 2
	states = nil

	base.CreateTooltip = function(...) return EssentialHousingHub:SetInfoTooltip(...) end
	base.WasHardwareEventRaised = false

	function EHH.Checkbox:New(...)
		local obj = ZO_Object.New(self)
		local control = obj:Initialize(...)
		return control
	end

	function EHH.Checkbox:Initialize(name, parent, anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY, width, height)
		if not self then
			error(string.format("Failed to create Checkbox: Initialization instance is nil."))
			return nil
		end

		if self.Initialized then
			error(string.format("Failed to create Checkbox: Instance is already initialized."))
			return nil
		end

		if not parent then
			error(string.format("Failed to create Checkbox: Parent is required."))
			return nil
		end

		local c

		self.Enabled = true
		self.EventBehavior = base.EventBehaviors.HardwareOnly
		self.Name = name
		self.Parent = parent
		self.Width = width or 200
		self.Height = height or 28
		self.State = base.States.Unchecked

		c = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
		self.Control = c
		c:SetDimensions(self.Width, self.Height)
		c:SetMouseEnabled(true)
		c:SetHandler("OnMouseDown", function(...)
			base.WasHardwareEventRaised = true
			self:Toggle()
			base.WasHardwareEventRaised = false
		end)

		c = CreateTexture(nil, self.Control)
		self.Control.Box = c
		c:SetTexture(Textures.ICON_UNCHECKED)
		c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
		SetColor(c, Colors.Box)
		c:SetDimensions(16, 16)
		c:SetAnchor(LEFT, self.Control, LEFT, 0, 0)

		c = WINDOW_MANAGER:CreateControl(nil, self.Control, CT_LABEL)
		self.Control.Label = c
		SetColor(c, Colors.Label)
		c:SetFont(Colors.LabelFont)
		c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		c:SetText("")
		c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		c:SetAnchor(LEFT, self.Control.Box, RIGHT, 4, 0)
		c:SetAnchor(RIGHT, self.Control, RIGHT, 0, 0)

		self:SetAnchor(anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY)
		self.Initialized = true

		return self
	end

	function EHH.Checkbox:RefreshEnabled()
		self.Control:SetMouseEnabled(self.Enabled)
		SetColor(self.Control.Box, Colors.Box, (not self.Enabled) and Colors.FilterDisabled)
		SetColor(self.Control.Label, Colors.Label, (not self.Enabled) and Colors.FilterDisabled)
	end

	function EHH.Checkbox:SetEnabled(value)
		self.Enabled = true == value
		self:RefreshEnabled()
	end

	function EHH.Checkbox:GetEventBehavior(value)
		return self.EventBehavior
	end

	function EHH.Checkbox:SetEventBehavior(value)
		if self:IsTableValue(base.EventBehaviors, value) then
			self.EventBehavior = value
		end
	end

	function EHH.Checkbox:GetName()
		return self.Name
	end

	function EHH.Checkbox:GetParent()
		return self.Parent
	end

	function EHH.Checkbox:GetControl()
		return self.Control
	end

	function EHH.Checkbox:GetDrawLevel()
		return self.Control:GetDrawLevel()
	end

	function EHH.Checkbox:SetDrawLevel(value)
		self.Control:SetDrawLevel(value)
	end

	function EHH.Checkbox:GetText()
		return self.Control.Label:GetText()
	end

	function EHH.Checkbox:SetText(value)
		self.Control.Label:SetText(value)
	end

	function EHH.Checkbox:GetWidth()
		return self.Control:GetWidth()
	end

	function EHH.Checkbox:SetWidth(value)
		self.Width = zo_clamp(tonumber(value) or 200, 40, 2000)
		self.Control:SetWidth(self.Width)
		return self.Width
	end

	function EHH.Checkbox:GetHeight()
		return self.Control:GetHeight()
	end

	function EHH.Checkbox:SetHeight(value)
		self.Height = zo_clamp(tonumber(value) or 28, 28, 2000)
		self.Control:SetHeight(self.Height)
		return self.Height
	end

	function EHH.Checkbox:GetDimensions()
		return self.Control:GetDimensions()
	end

	function EHH.Checkbox:SetDimensions(width, height)
		self.Control:SetDimensions(width, height)
	end

	function EHH.Checkbox:GetCenter()
		return self.Control:GetCenter()
	end

	function EHH.Checkbox:GetScreenRect()
		return self.Control:GetScreenRect()
	end

	function EHH.Checkbox:GetHandlers(event)
		if not event then
			return nil
		end

		event = string.lower(event)

		if not self.Handlers then
			self.Handlers = {}
		end

		local handlers = self.Handlers[event]

		if handlers then
			handlers = {}
			self.Handlers[event] = {}
		end

		return handlers
	end

	function EHH.Checkbox:AddHandler(event, handler)
		local handlers = self:GetHandlers(event)

		if handlers then
			handlers[handler] = true
			return handler
		end

		return nil
	end

	function EHH.Checkbox:RemoveHandler(event, handler)
		local handlers = self:GetHandlers(event)

		if handlers and handlers[handler] then
			handlers[handler] = nil
			return handler
		end

		return nil
	end

	function EHH.Checkbox:CallHandlers(event, ...)
		local handlers = self:GetHandlers(event)

		if handlers then
			for handler in pairs(handlers) do
				handler(self, ...)
			end
		end
	end

	function EHH.Checkbox:IsHidden()
		return self.Control:IsHidden()
	end

	function EHH.Checkbox:SetHidden(value)
		self.Control:SetHidden(value)
	end

	function EHH.Checkbox:ClearAnchors()
		self.Control:ClearAnchors()
		self:OnResized()
	end

	function EHH.Checkbox:SetAnchor(anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY)
		if anchorFrom or anchor or anchorTo then
			self.Control:SetAnchor(anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY)
		end
	end

	function EHH.Checkbox:IsIndeterminate()
		return self.State == base.States.Indeterminate
	end

	function EHH.Checkbox:IsUnchecked()
		return self.State == base.States.Unchecked
	end

	function EHH.Checkbox:IsChecked()
		return self.State == base.States.Checked
	end

	function EHH.Checkbox:SetState(state)
		if self:IsTableValue(base.States, state) then
			self.State = state

			if base.WasHardwareEventRaised or self:GetEventBehavior() ~= base.EventBehaviors.HardwareOnly then
				self:OnChanged()
			end

			self:Refresh()
		end
	end

	function EHH.Checkbox:Toggle()
		if self.State == base.States.Checked then
			self:SetState(base.States.Unchecked)
		else
			self:SetState(base.States.Checked)
		end
	end

	function EHH.Checkbox:SetChecked(value)
		self:SetState(value and base.States.Checked or base.States.Unchecked)
	end

	function EHH.Checkbox:Refresh()
		if self.State == base.States.Checked then
			self.Control.Box:SetTexture(Textures.ICON_CHECKED)
		elseif self.State == base.States.Unchecked then
			self.Control.Box:SetTexture(Textures.ICON_UNCHECKED)
		else
			self.Control.Box:SetTexture(Textures.ICON_INDETERMINATE)
		end
	end

	do
		local isChanging = false

		function EHH.Checkbox:OnChanged()
			if isChanging then
				return
			end

			isChanging = true
			self:CallHandlers("OnChanged", self.State)
			isChanging = false
		end
	end
end

function EHH:QueueLiveStreamerMessages()
	if self.liveStreamerMessages then
		return
	end

	self.liveStreamerMessages = {}

	local now = GetTimeStamp()
	local metaDataList = self:GetCommunityMetaDataByKey("sc")
	if metaDataList and "table" == type(metaDataList) then
		for index, channelData in ipairs(metaDataList) do
			local lastLiveTS = tonumber(channelData.LastLiveTS)
			if lastLiveTS then
				local lastEndTS = tonumber(channelData.LastEndTS)
				if not lastEndTS or lastEndTS < lastLiveTS then
					lastEndTS = lastLiveTS + self.Defs.Limits.MaxBroadcastHours * 3600
				end
				if now <= lastEndTS then
					if not self:HasShownLiveStreamMessage(channelData) then
						local messageAndChannelData =
						{
							message = string.format("|cffff44%s|r\nis live on Twitch", channelData.ChannelName),
							url = channelData.URL,
							channelData = channelData,
						}
						table.insert(self.liveStreamerMessages, messageAndChannelData)
					end
				end
			end
		end
	end

	EVENT_MANAGER:RegisterForUpdate("EHH.PlayNextQueuedLiveStreamerMessage", 9000, function() self:PlayNextQueuedLiveStreamerMessage() end)
end

function EHH:PlayNextQueuedLiveStreamerMessage()
	if self.liveStreamerMessages then
		if not self:IsHUDSceneShowing() then
			return
		end

		local messageData = table.remove(self.liveStreamerMessages, 1)
		if messageData then
			self:SetLiveStreamMessageShown(messageData.channelData)
			HousingHubStreamMessage:Play(messageData.message, messageData.url)
			return
		end
	end

	EVENT_MANAGER:UnregisterForUpdate("EHH.PlayNextQueuedLiveStreamerMessage")
end

---[ World Rendering ]---

do
	local disabledCount = 0

	function EHH:SetWorldRenderingEnabled(enabled)
		local count = self.DisableWorldRenderingCount or 0
		
		if false ~= enabled then
			count = math.max(0, count - 1)
		else
			count = count + 1
		end

		SetShouldRenderWorld(0 >= count)
		self.DisableWorldRenderingCount = count
	end
end

---[ Widget ]---

function EHH:GetWidget()
	return HousingHubWidget
end

function EHH:GetWidgetSettings()
	local settings = self:GetSettings()
	local data = settings.Widget

	if not data then
		data =
		{
			Anchor = TOPRIGHT,
			X = 0,
			Y = 380,
		}
		settings.Widget = data
	end

	return data
end

function EHH:SetWidgetSettings(anchor, x, y)
	if anchor and x and y then
		local data = self:GetWidgetSettings()
		data.Anchor, data.X, data.Y = anchor, x, y
	end
end

function EHH:GetWidgetAnchor()
	return self:GetWidgetSettings().Anchor
end

function EHH:IsWidgetLeftAnchored()
	return self:GetWidgetAnchor() == TOPLEFT
end

function EHH:RefreshWidget()
	local widget = self:GetWidget()
	if 0 == self.CurrentHouseId or self.IsEHT then
		widget:SetHidden(true)
	else
		widget:UpdateHouseStats(tostring(self.CurrentHousePopulation), tostring(self.CurrentTraditionalItems))
		widget:SetHidden(false)
	end
end

do
	local CubicBezierEasing = ZO_GenerateCubicBezierEase(.48, .74, .06, 1.54)

	function EHH:RefreshWidgetButtons()
		local widget = self:GetWidget()
		local numButtons = widget.NumButtons
		local offset = widget.ButtonOffset or 0
		local offsetCoefficient = widget.ButtonOffsetCoefficient or -1
		local verticalOffsetCoefficient = widget.ButtonVerticalOffsetCoefficient
		local minOffset = self.Defs.Limits.MinWidgetButtonOffset
		local maxOffset = self.Defs.Limits.MaxWidgetButtonOffset
		local isLeftAnchored = self:IsWidgetLeftAnchored()
		local buttonAnchor = isLeftAnchored and BOTTOMLEFT or BOTTOMRIGHT
		local labelAnchor = isLeftAnchored and LEFT or RIGHT
		local incrementalOffsetX = self.Defs.Limits.BaseWidgetButtonIncrementalOffsetX
		local baseWidgetButtonOffset = self.Defs.Limits.BaseWidgetButtonInset

		for buttonIndex, button in ipairs(widget.ButtonControls) do
			local percent = 1 - (buttonIndex / numButtons)
			--local progress = 1 - CubicBezierEasing(self:VariableEaseIn(offset, 1.5 - 0.5 * percent))
			local progress = 1 - CubicBezierEasing(self:VariableEaseIn(offset, 5 - 3.5 * percent))
			local offsetX = zo_lerp(minOffset, maxOffset, progress) * offsetCoefficient
			local offsetY = 34 * buttonIndex * verticalOffsetCoefficient

			button:ClearAnchors()
			button:SetAnchor(buttonAnchor, nil, nil, offsetX, offsetY)

			local labelOffsetX = baseWidgetButtonOffset * -offsetCoefficient
			button.Label:ClearAnchors()
			button.Label:SetAnchor(labelAnchor, nil, nil, labelOffsetX)

			local iconAnchor = labelAnchor == LEFT and RIGHT or LEFT
			button.Checkbox:ClearAnchors()
			button.Checkbox:SetAnchor(CENTER, button, iconAnchor, labelOffsetX > 0 and -32 or 32)
			button.Icon:ClearAnchors()
			button.Icon:SetAnchor(CENTER, button, iconAnchor, labelOffsetX > 0 and -32 or 32)
		end
	end
end

function EHH:RefreshWidgetPosition(x, y)
	local widget = self:GetWidget()
	local screenWidth, screenHeight = GuiRoot:GetDimensions()
	local width, height = widget:GetDimensions()
	local left = widget:GetLeft()
	local anchor

	if x and y then
		if x < screenWidth * 0.5 then
			anchor = TOPLEFT
		else
			anchor = TOPRIGHT
		end

		x = 0
		y = zo_clamp(y, 30, screenHeight - 10)
		self:SetWidgetSettings(anchor, x, y)
	else
		local data = self:GetWidgetSettings()
		anchor, x, y = data.Anchor, data.X, data.Y
	end

	local openDownwards = y < 0.5 * screenHeight
	widget.ButtonVerticalOffsetCoefficient = openDownwards and 1 or -1
	widget:ClearAnchors()
	widget:SetAnchor(anchor, GuiRoot, anchor, x, y)
	widget.Stats:ClearAnchors()

	local texX1, texX2, buttonAnchor, buttonAnchorX
	local isLeftAnchored = self:IsWidgetLeftAnchored()
	if isLeftAnchored then
		texX1, texX2 = 0, 1
		buttonAnchor, buttonAnchorX = BOTTOMLEFT, -self.Defs.Limits.PrimaryWidgetButtonOffset

		widget.IsLeftAnchored = true
		widget.ButtonOffsetCoefficient = -1
		widget.Stats:SetAnchor(LEFT, nil, nil, self.Defs.Limits.PrimaryWidgetStatsOffset)
	else
		texX1, texX2 = 1, 0
		buttonAnchor, buttonAnchorX = BOTTOMRIGHT, self.Defs.Limits.PrimaryWidgetButtonOffset

		widget.IsLeftAnchored = false
		widget.ButtonOffsetCoefficient = 1
		widget.Stats:SetAnchor(RIGHT, nil, nil, -self.Defs.Limits.PrimaryWidgetStatsOffset)
	end

	local texY1, texY2
	if openDownwards then
		texY1, texY2 = 0, 1
	else
		texY1, texY2 = 1, 0
	end

	widget.WidgetButton:ClearAnchors()
	widget.WidgetButton:SetAnchor(buttonAnchor, nil, nil, buttonAnchorX)
	widget.WidgetButton:SetTextureCoords(texX1, texX2, texY1, texY2)
	widget.WidgetButton.Over:SetTextureCoords(texX1, texX2, texY1, texY2)

	for buttonIndex, button in ipairs(widget.ButtonControls) do
		button:SetTextureCoords(texX1, texX2, texY1, texY2)
		button.Over:SetTextureCoords(texX1, texX2, texY1, texY2)
		button.IsLeftAnchored = isLeftAnchored
	end

	self:RefreshWidgetButtons()
end

function EHH:ResetWidget()
	local widget = self:GetWidget()
	widget:SetButtonOffset(0)
end

function EHH:SetIsLoading(loading)
	loading = true == loading
	if loading ~= self.isLoadingData then
		self.isLoadingData = loading
		if loading then
			HUB_EVENT_MANAGER:UnregisterForUpdate("EssentialHousingHub.HideLoadingDialog")
			HousingHubLoadingDialog.ShowHideAnimation:PlayForward()
		else
			HUB_EVENT_MANAGER:RegisterForUpdate("EssentialHousingHub.HideLoadingDialog", 600, function()
				HUB_EVENT_MANAGER:UnregisterForUpdate("EssentialHousingHub.HideLoadingDialog")
				HousingHubLoadingDialog.ShowHideAnimation:PlayBackward()
				HousingHubLoadingDialog.ShowHideTilesAnimation:PlayBackward()
			end)
		end
	end
end

---[ Global XML ]---

function EHH_Texture_IsHidden(self)
	return self._IsHidden
end

function EHH_Texture_SetHidden(self, hidden)
	self._IsHidden = hidden
	self._SetHiddenMethod(self, hidden or self._IsLoading)
end

function EHH_Texture_SetTexture(self, textureFile)
	if textureFile and "" ~= textureFile and textureFile ~= self._TextureFile then
		self._IsLoading = true
		self._TextureFile = textureFile
		self._SetHiddenMethod(self, true)
	end
	self._SetTextureMethod(self, textureFile)
end

function EHH_Texture_OnTextureLoaded(self)
	self._IsLoading = false
	self._SetHiddenMethod(self, self._IsHidden)
end

function EHH_Texture_ShadowTextureLoading(self)
	if self._SetTexture then
		return
	end

	self._IsLoading = false
	self._IsHidden = self:IsHidden()

	self._IsHiddenMethod = self.IsHidden
	self.IsHidden = EHH_Texture_IsHidden

	self._SetHiddenMethod = self.SetHidden
	self.SetHidden = EHH_Texture_SetHidden

	self._SetTextureMethod = self.SetTexture
	self.SetTexture = EHH_Texture_SetTexture

	self:SetHandler("OnTextureLoaded", EHH_Texture_OnTextureLoaded)
end

function EHH_HousingHubLabelPanel_OnResized(control)
	if not control.IsResizing then
		control.IsResizing = true

		local width, height = control:GetDimensions()
		local overscanWidthPx = zo_lerp(14, 90, width / 1024)
		local overscanHeightPx = zo_lerp(14, 90, height / 1024)
		control.Outline:SetDimensions(width + overscanWidthPx, height + overscanHeightPx)

		control.IsResizing = false
	end
end

function EHH_HousingHubButton_OnTextChanged(self)
	if self and self.Backdrop then
		local width, height = self:GetDimensions()
		width, height = math.max(60, 9 + width * 1.0234375), math.max(32, 12 + height * 1.09375)
		self.Backdrop:SetDimensions(width, height)
	end
end

function EHH_HousingHubButtonBackdrop_OnInitialized(self, texture)
	if self and EssentialHousingHub then
		self:SetColor(0.58, 0.75, 1, 1)
		self:GetParent().Backdrop = self
		self:SetTexture(texture or EssentialHousingHub.Textures.HUB_BUTTON)
		self.FocusAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HousingHubButton_FocusAnimation", self)
		self.FocusAnimation:PlayInstantlyToStart()
	end
end

function EHH_HousingHubButtonHighlight_OnUpdate(self)
	local parentControl = self:GetParent()
	local animOffset = parentControl.BaseAnimationOffset
	local ft = GetFrameTimeMilliseconds() + animOffset
	local backdrop1, backdrop2 = self.Backdrop1, self.Backdrop2
	local interval1 = (ft % 5000) / 5000
	local interval2 = (2 * (0.2 + interval1)) % 1

	if 0 == animOffset % 2 then
		interval1 = 1 - interval1
	else
		interval2 = 1 - interval2
	end

	local progress1 = math.abs(-1 + 2 * ((ft % 8000) / 8000))
	local progress2 = math.abs(-1 + 2 * (((ft + 3000) % 11000) / 11000))
	local coeff1 = -(0.01 + 0.025 * progress1)
	local coeff2 = -(0.04 - 0.04 * progress2)
	local offset1 = coeff1 * interval1
	local offset2 = coeff2 * interval2

	backdrop1:SetColor(1, 1, 0.5 + 0.5 * progress1, 0.75 * math.sin(interval1 * math.pi))
	backdrop2:SetColor(1, 1, 1 - 0.35 * progress2, 0.55 * math.sin(interval2 * math.pi))

	backdrop1:SetTextureCoords(-offset1, 1 + coeff1 - offset1, -offset1, 1 + coeff1 - offset1)
	backdrop2:SetTextureCoords(1 + offset2, -coeff2 + offset2, 1 + offset2, -coeff2 + offset2)
end

function EHH_HousingHubPushButton_OnInitialized(self)
	self.Down = self:GetNamedChild("Down")
	self.Label = self:GetNamedChild("Label")
	self.Over = self:GetNamedChild("Over")
	self.Font = self.Font or "$(BOLD_FONT)|$(KB_20)|soft-shadow-thick"
	self.FontOver = self.FontOver or "$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thin"

	self:SetTexture(EssentialHousingHub.Textures.ICON_BUTTON)
	self.Down:SetTexture(EssentialHousingHub.Textures.ICON_BUTTON_DOWN)
	self.Over:SetTexture(EssentialHousingHub.Textures.ICON_BUTTON_OVER)
	self.Label:SetFont(self.Font)
end

function EHH_HousingHubPushButton_OnMouseDown(self)
	self.Down:SetHidden(false)
	self.Over:SetHidden(true)
	self.Label:SetAnchor(CENTER, nil, nil, 1, 1)
	self.Label:SetFont(self.Font)
	
	if self.PropagateDrag then
		self:GetOwningWindow():StartMoving()
	end
end

function EHH_HousingHubPushButton_OnMouseUp(self)
	if self:IsPointInside(GetUIMousePosition()) then
		self.Over:SetHidden(false)
	end
	self.Down:SetHidden(true)
	self.Label:SetAnchor(CENTER, nil, nil, 0, 0)
	self.Label:SetFont(self.FontOver)

	if self.PropagateDrag then
		self:GetOwningWindow():StopMovingOrResizing()
	end
end

function EHH_HousingHubBlade_OnInitialized(self)
	self:SetTexture(EssentialHousingHub.Textures.ICON_BLADE)
	self.Over = self:GetNamedChild("Over")
	self.Over:SetTexture(EssentialHousingHub.Textures.ICON_BLADE_OVER)
	self.Label = self:GetNamedChild("Label")

	self.FocusAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HousingHubBlade_FocusAnimation", self.Over)
	self.FocusAnimation:PlayInstantlyToStart()
end

function EHH_Widget_OnInitialized(self)
	EssentialHousingHub.HubWidgetControl = self
end

function EHH_Widget_DeferredInitialize(self)	
	local hub = EssentialHousingHub

	local function RefreshVisibility(visible)
		local hidden
		if not hub.IsEHT and hub:IsAddOnEnabled() and hub:GetSetting("EnableHousingHubWidget") then
			hidden = not visible or not hub:IsHouseZone()
		else
			hidden = true
		end

		self:SetHidden(hidden)
		hub:SetCanHelpShow(not hidden)
	end

	HUB_EVENT_MANAGER:RegisterCallback(HUD_SCENE, "StateChange", function(oldState, newState)
		if newState == SCENE_SHOWN then
			RefreshVisibility(true)
		elseif newState == SCENE_HIDING then
			RefreshVisibility(false)
		end
	end)

	HUB_EVENT_MANAGER:RegisterCallback(HUD_UI_SCENE, "StateChange", function(oldState, newState)
		if newState == SCENE_SHOWN then
			RefreshVisibility(true)
		elseif newState == SCENE_HIDING then
			RefreshVisibility(false)
		end
	end)

	self.WidgetButton = self:GetNamedChild("WidgetButton")
	self.Stats = self.WidgetButton:GetNamedChild("Stats")
	self.GuestCount = self.Stats:GetNamedChild("GuestCount")
	self.FurnitureCount = self.Stats:GetNamedChild("FurnitureCount")
	self.ButtonPool = ZO_ControlPool:New("HousingHubWidgetBlade", self, "HousingHubWidgetButton")
	self.ButtonControls = {}
	self.ButtonOffsetCoefficient = -1
	self.ButtonVerticalOffsetCoefficient = 1
	self.ButtonOffset = 1
	self.NumButtons = 0

	self.UpdateHouseStats = function(self, guestCount, furnitureCount)
		self.GuestCount:SetText(tostring(guestCount))
		self.FurnitureCount:SetText(tostring(furnitureCount))
	end
	
	self.AcquireButton = function(self)
		self.NumButtons = self.NumButtons + 1
		local button = self.ButtonPool:AcquireObject()
		table.insert(self.ButtonControls, button)
		return button
	end
	
	self.ReleaseAllButtons = function(self)
		self.NumButtons = 0
		self.ButtonPool:ReleaseAllObjects()
		ZO_ClearNumericallyIndexedTable(self.ButtonControls)
	end
	
	self.AddButton = function(self, labelText, callback, mouseEnter, mouseExit)
		local button = self:AcquireButton()
		local offsetY = self.NumButtons * -34

		button.Callback = callback
		button.MouseEnterCallback = mouseEnter
		button.MouseExitCallback = mouseExit
		button.Label:SetText(labelText)
		button.Label:SetAnchor(LEFT, nil, nil, 92)
		button.Label:SetMaxLineCount(1)
		button.Label:SetWidth(120)
		button.Label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
		button.Checkbox:SetHidden(true)
		button.Icon:SetHidden(true)
		button.Icon:SetColor(1, 1, 0.85, 1)

		button:ClearAnchors()
		button:SetDimensions(250, 32)
		button:SetAnchor(BOTTOM, nil, nil, 0, offsetY)
		button:SetHidden(false)

		return button
	end

	self.AddCheckbox = function(self, labelText, callback, mouseEnter, mouseExit)
		local button = self:AddButton(labelText, callback, mouseEnter, mouseExit)
		button.Checkbox:SetHidden(false)

		return button
	end

	self.AddIconButton = function(self, labelText, iconTexture, callback, mouseEnter, mouseExit)
		local button = self:AddButton(labelText, callback, mouseEnter, mouseExit)
		button.Icon:SetTexture(iconTexture)
		button.Icon:SetHidden(false)

		return button
	end

	self.SetButtonOffset = function(self, offset)
		self.ButtonOffset = zo_clamp(offset, 0, 1)
		hub:RefreshWidgetButtons()
	end
	
	local function JumpToPreviousHouse()
		hub:JumpToPreviousHouse()
	end
	
	local function DisplayPreviousHome(control, owner, houseName)
		local interval = (GetFrameTimeMilliseconds() % 2200) / 2200
		local subinterval = (2 * interval) % 1
		control.Label:SetAlpha(20 * hub:VariableEase(subinterval, 2))
		if 0.5 >= interval then
			control.Label:SetText(houseName)
		else
			control.Label:SetText(owner)
		end
	end
	
	local function OnPreviousHomeMouseEnter(control)
		local houseId, owner = hub:GetPreviousHouse()
		if houseId then
			local houseName = hub:GetHouseName(houseId)
			if hub:IsOwnerLocalPlayer(owner) then
				owner = hub.DisplayName
			end
			HUB_EVENT_MANAGER:RegisterForUpdate("EHH.Hub.DisplayPreviousHome", 1, function() DisplayPreviousHome(control, owner, houseName) end)
		end
	end

	local function OnPreviousHomeMouseExit(control)
		HUB_EVENT_MANAGER:UnregisterForUpdate("EHH.Hub.DisplayPreviousHome")
		control.Label:SetText("Previous Home")
		control.Label:SetAlpha(1)
	end

	local function OpenHousingHub()
		hub:ShowHousingHub()
	end

	local function OpenSetupGuide()
		hub:ShowURL(hub.Defs.Urls.SetupCommunityPC)
		hub:EnterUIMode()
	end
	
	local function OpenHelp()
		hub:ResetHelp()
	end

	local function SummonGuestJournal()
		local FORCE = true
		if hub.Effect:SummonGuestbook(FORCE) then
			hub:ExitUIMode()
		else
			hub:DisplayNotification("Guest Journals are only available in Open Houses")
		end
	end

	local function SendMailToOwner()
		if not hub:IsOwner() then
			hub:ShowNewEmail(hub:GetOwner(), "Your " .. hub:GetHouseName())
			hub:EnterUIMode()
		else
			hub:DisplayNotification("You must be in another player's home")
		end
	end

	local function ToggleShowFX()
		EHH.EffectUI:ShowHideEffects()
		self.ShowFX:SetCheckedState(not EHH.EffectUI:AreEffectsHidden())
	end

	self:AddIconButton("Housing Hub", hub.Textures.ICON_GLOBE, OpenHousingHub)
	self:AddIconButton("Previous Home", hub.Textures.ICON_BACK_ARROW, JumpToPreviousHouse, OnPreviousHomeMouseEnter, OnPreviousHomeMouseExit)
	self:AddIconButton("Guest Journal", hub.Textures.ICON_BOOK, SummonGuestJournal)
	self:AddIconButton("Mail Owner", hub.Textures.ICON_MAIL, SendMailToOwner)
	self:AddIconButton("Setup Guide", hub.Textures.ICON_VIDEO, OpenSetupGuide)
	self:AddIconButton("Help Tutorials", hub.Textures.ICON_HELP, OpenHelp)
	self.ShowFX = self:AddCheckbox("Enable Effects", ToggleShowFX)
	self.ShowFX:SetCheckedState(not EHH.EffectUI:AreEffectsHidden())

	self.FocusAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HousingHubWidget_FocusAnimation", self)

	local function SetButtonHitInsets(left, right)
		for _, buttonControl in pairs(self.ButtonControls) do
			buttonControl:SetHitInsets(left, -2, right, 2)
		end
	end

	self.PlayAnimationForward = function()
		SetButtonHitInsets(-40, 40)
		self.FocusAnimation:PlayForward()
	end

	self.PlayAnimationBackward = function()
		SetButtonHitInsets(40, -40)
		self.FocusAnimation:PlayBackward()
	end
end

function EHH_WidgetButton_ResetMouseClick(self)
	self:SetHandler("OnUpdate", nil, "Drag")
	self.DragStartTime = nil
	self.IsDragging = nil
end

function EHH_WidgetButton_OnDrag(self)
	if self.IsDragging then
		local mouseX, mouseY = GetUIMousePosition()
		EssentialHousingHub:RefreshWidgetPosition(mouseX, mouseY)
	else
		EHH_WidgetButton_ResetMouseClick(self)
	end
end

function EHH_WidgetButton_OnMousePressed(self)
	if self.DragStartTime then
		if not self.IsDragging and self.DragStartTime <= GetFrameTimeMilliseconds() then
			self.IsDragging = true
			self:SetHandler("OnUpdate", EHH_WidgetButton_OnDrag, "Drag")
		end
	else
		EHH_WidgetButton_ResetMouseClick(self)
	end
end

function EHH_WidgetButton_OnMouseDown(self, button)
	if button == MOUSE_BUTTON_INDEX_LEFT then
		self.DragStartTime = GetFrameTimeMilliseconds() + EssentialHousingHub.Defs.Limits.MinWidgetButtonDragClickMS
		self.IsDragging = nil
		self:SetHandler("OnUpdate", EHH_WidgetButton_OnMousePressed, "Drag")
	end
end

function EHH_WidgetButton_OnMouseUp(self, button)
	if button == MOUSE_BUTTON_INDEX_LEFT then
		if self.DragStartTime and GetFrameTimeMilliseconds() < self.DragStartTime then
			EssentialHousingHub:ShowHousingHub()
		end
		EHH_WidgetButton_ResetMouseClick(self)
	end
end

function EHH_GetShowHideTileAnimationProgress(progress)
	progress = 1 - progress
	if progress < 0.75 then
		progress = progress * 1.26
	else
		progress = progress * 4
	end
	return zo_clamp(progress, 0, 1)
end

-- HousingHubTooltip

local HubTooltip = ZO_InitializingObject:Subclass()

function HubTooltip:Initialize(tooltipControl)
	self.control = tooltipControl
	self.label = tooltipControl:GetNamedChild("Label")

	self.messageFunction = nil
	self.messageText = nil
	self.nextRefreshMS = nil
	self.refreshIntervalMS = nil

	self.target =
	{
		control = nil,
		anchorTo = nil,
		anchorFrom = nil,
		offsetX = 0,
		offsetY = 0,
	}
	
	local DEFAULT_OFFSET_UI = 20
	self.anchorFromPoints =
	{
		[BOTTOM] =
		{
			anchorTo = TOP,
			anchorFrom = BOTTOM,
			defaultOffsetX = 0,
			defaultOffsetY = -DEFAULT_OFFSET_UI,
		},
		[TOP] =
		{
			anchorTo = BOTTOM,
			anchorFrom = TOP,
			defaultOffsetX = 0,
			defaultOffsetY = DEFAULT_OFFSET_UI,
		},
		[RIGHT] =
		{
			anchorTo = LEFT,
			anchorFrom = RIGHT,
			defaultOffsetX = -DEFAULT_OFFSET_UI,
			defaultOffsetY = 0,
		},
		[LEFT] =
		{
			anchorTo = RIGHT,
			anchorFrom = LEFT,
			defaultOffsetX = DEFAULT_OFFSET_UI,
			defaultOffsetY = 0,
		},
		[BOTTOMRIGHT] =
		{
			anchorTo = TOPLEFT,
			anchorFrom = BOTTOMRIGHT,
			defaultOffsetX = -DEFAULT_OFFSET_UI,
			defaultOffsetY = -DEFAULT_OFFSET_UI,
		},
		[BOTTOMLEFT] =
		{
			anchorTo = TOPRIGHT,
			anchorFrom = BOTTOMLEFT,
			defaultOffsetX = DEFAULT_OFFSET_UI,
			defaultOffsetY = -DEFAULT_OFFSET_UI,
		},
		[TOPRIGHT] =
		{
			anchorTo = BOTTOMLEFT,
			anchorFrom = TOPRIGHT,
			defaultOffsetX = -DEFAULT_OFFSET_UI,
			defaultOffsetY = DEFAULT_OFFSET_UI,
		},
		[TOPLEFT] =
		{
			anchorTo = BOTTOMRIGHT,
			anchorFrom = TOPLEFT,
			defaultOffsetX = DEFAULT_OFFSET_UI,
			defaultOffsetY = DEFAULT_OFFSET_UI,
		},
		[CENTER] =
		{
			anchorTo = CENTER,
			anchorFrom = CENTER,
			defaultOffsetX = 0,
			defaultOffsetY = 0,
		},
	}
end

function HubTooltip:RefreshAnchors()
	local tooltip = self.control
	tooltip:ClearAnchors()

	local target = self.target
	if target.control then
		tooltip:SetAnchor(target.anchorFrom, target.control, target.anchorTo, target.offsetX, target.offsetY)
	end
end

function HubTooltip:AnchorTo(control, anchorPoint, offsetX, offsetY)
	local anchorPoints = self.anchorFromPoints[anchorPoint] or self.anchorFromPoints[BOTTOM]
	local target = self.target
	target.control = control or GuiRoot
	target.anchorTo = anchorPoints.anchorTo
	target.anchorFrom = anchorPoints.anchorFrom
	target.offsetX = anchorPoints.defaultOffsetX -- offsetX or anchorPoints.defaultOffsetX
	target.offsetY = anchorPoints.defaultOffsetY -- offsetY or anchorPoints.defaultOffsetY

	self:RefreshAnchors()
end

function HubTooltip:IsHidden()
	return self.control:IsHidden()
end

function HubTooltip:SetHidden(hidden)
	self.control:SetHidden(hidden)
end

function HubTooltip:ClearRefreshInterval()
	self.nextRefreshMS = nil
	self.refreshIntervalMS = nil
end

function HubTooltip:SetRefreshInterval(intervalMS)
	if intervalMS ~= self.refreshIntervalMS then
		self.refreshIntervalMS = intervalMS
		if intervalMS then
			self.nextRefreshMS = GetFrameTimeMilliseconds() + intervalMS
		else
			self.nextRefreshMS = nil
		end
	end
end

function HubTooltip:SetText(message, ...)
	if "function" == type(message) then
		self.messageFunction = message
		self.messageText = nil
		self.label:SetText(self.messageFunction(self.label) or "")

		if not self.refreshIntervalMS then
			self.refreshIntervalMS = 1000
			self.nextRefreshMS = GetFrameTimeMilliseconds() + self.refreshIntervalMS
		end
	else
		self.messageFunction = nil
		self.messageText = message or ""

		if 0 == select("#", ...) then
			self.label:SetText(self.messageText or "")
		else
			self.label:SetText(string.format(self.messageText, ...))
		end
	end
end

function HubTooltip:Clear()
	self.control:SetHidden(true)

	self.messageFunction = nil
	self.messageText = nil
	self.nextRefreshMS = nil
	self.refreshIntervalMS = nil
	
	local target = self.target
	target.control = nil
	target.anchorTo = nil
	target.anchorFrom = nil
	target.offsetX = 0
	target.offsetY = 0
end

function HubTooltip:Show(message, control, anchorPoint, offsetX, offsetY)
	self.nextRefreshMS = nil
	self.refreshIntervalMS = nil

	self:SetText(message)
	self:AnchorTo(control, anchorPoint, offsetX, offsetY)
	self:SetHidden(false)
end

function HubTooltip:Hide()
	self:SetHidden(true)
end

function HubTooltip:OnUpdate()
	local targetControl = self.target.control
	if targetControl then
		local mouseX, mouseY = GetUIMousePosition()
		if not targetControl:IsPointInside(mouseX, mouseY) and (not targetControl.HasFocus or not targetControl:HasFocus()) then
			self:Clear()
			return
		end
	end

	if self.messageFunction then
		if self.refreshIntervalMS then
			local timeMS = GetFrameTimeMilliseconds()
			if timeMS >= self.nextRefreshMS then
				self.nextRefreshMS = timeMS + self.refreshIntervalMS
				self:SetText(self.messageFunction)
			end
		end
	end
end

function EHH_Tooltip_OnInitialized(control)
	HOUSING_HUB_TOOLTIP = HubTooltip:New(control)
end

function EHH_Tooltip_OnUpdate()
	HOUSING_HUB_TOOLTIP:OnUpdate()
end

function ghh() return EHH:GetDialog("HousingHub") end

---[ Module Registration ]---

EssentialHousingHub.Modules.UserInterface = true