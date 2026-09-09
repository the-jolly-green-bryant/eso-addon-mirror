-- PB's CraftMaterialAssistant -- the window
--
-- ---------------------------------------------------------------------------------------
-- WHY FOUR LABELS AND NOT ONE
--
-- A material list is a table, and a table needs its columns to line up. There is no
-- monospaced face on the console UI, so padding a name out with spaces lines nothing up: "20"
-- and "300" are different widths in every face the client has loaded.
--
-- So the four columns are four labels, side by side, each holding its whole column as one
-- string with "\n" between the rows. Every label lays its own lines out with the same font and
-- therefore the same line height, so row three of the "have" column sits exactly beside row
-- three of the name column -- and each number column is right-aligned inside its own width,
-- which is what makes a column of numbers readable at all.
--
-- The alternative -- a control per cell -- is forty controls to create, anchor, hide and
-- re-lay-out every time an ingredient count changes.
--
-- ---------------------------------------------------------------------------------------
-- THE WINDOW ITSELF
--
-- A plain top-level window with the mouse switched off. It cannot be clicked, dragged or
-- focused, so it can never take a click away from the game underneath it -- which on a
-- controller is the only way an add-on's overlay can really hurt. Position and size are set
-- from the panel instead of by dragging, for the same reason.
--
-- It is created the first time something has to be drawn, not at load: an add-on that has
-- never been switched on should not have left a window behind in the UI.
--
-- Drawn in front by default, and that is not only about legibility: the candidate list is
-- read while the settings panel is open, so the window has to be visible over a full-screen
-- menu. It is not in any scene, so nothing hides it; the draw layer is what decides whether
-- the menu is drawn over it.
-- ---------------------------------------------------------------------------------------

if not PBS_CRAFT_MATERIAL_ASSISTANT then
	return
end

local addon = PBS_CRAFT_MATERIAL_ASSISTANT
local hud = addon.hud

local WINDOW_NAME = "PBsCraftMaterialAssistantWindow"

-- Anchor points, declared one at a time: a client that does not define one of these constants
-- must not take the whole file down with a nil key in a table constructor.
local ANCHORS = {}
local function DeclareAnchor(token, point)
	if point == nil then
		return
	end
	ANCHORS[token] = { point = point }
end

DeclareAnchor("TOPLEFT", TOPLEFT)
DeclareAnchor("TOP", TOP)
DeclareAnchor("TOPRIGHT", TOPRIGHT)
DeclareAnchor("LEFT", LEFT)
DeclareAnchor("CENTER", CENTER)
DeclareAnchor("RIGHT", RIGHT)
DeclareAnchor("BOTTOMLEFT", BOTTOMLEFT)
DeclareAnchor("BOTTOM", BOTTOM)
DeclareAnchor("BOTTOMRIGHT", BOTTOMRIGHT)

addon.POSITIONS = {
	{ token = "TOPLEFT", label = "SI_PBSCMA_POS_TOPLEFT" },
	{ token = "TOP", label = "SI_PBSCMA_POS_TOP" },
	{ token = "TOPRIGHT", label = "SI_PBSCMA_POS_TOPRIGHT" },
	{ token = "LEFT", label = "SI_PBSCMA_POS_LEFT" },
	{ token = "CENTER", label = "SI_PBSCMA_POS_CENTER" },
	{ token = "RIGHT", label = "SI_PBSCMA_POS_RIGHT" },
	{ token = "BOTTOMLEFT", label = "SI_PBSCMA_POS_BOTTOMLEFT" },
	{ token = "BOTTOM", label = "SI_PBSCMA_POS_BOTTOM" },
	{ token = "BOTTOMRIGHT", label = "SI_PBSCMA_POS_BOTTOMRIGHT" },
}

-- Where the window sits when something else wants the same piece of screen. Declared one pair
-- at a time, like the anchors. The client switches these at runtime itself
-- (ZO_KeybindStrip:SetDrawOrder, zo_keybindstrip.lua:180), and the pairs are the ends and the
-- middle of the two enums.
local DRAW_ORDERS = {}
local function DeclareDrawOrder(token, layer, tier)
	if layer == nil or tier == nil then
		return
	end
	DRAW_ORDERS[token] = { layer = layer, tier = tier }
end

DeclareDrawOrder("FRONT", DL_OVERLAY, DT_HIGH)
DeclareDrawOrder("NORMAL", DL_CONTROLS, DT_MEDIUM)
DeclareDrawOrder("BACK", DL_BACKGROUND, DT_LOW)

addon.DRAW_ORDERS = {
	{ token = "FRONT", label = "SI_PBSCMA_DRAW_FRONT" },
	{ token = "NORMAL", label = "SI_PBSCMA_DRAW_NORMAL" },
	{ token = "BACK", label = "SI_PBSCMA_DRAW_BACK" },
}

-- Faces and outline tokens: the shortlist PB's QuestTrackerFontChanger settled on, for the
-- same measured reason. Only faces the console UI already has loaded are offered --
-- ANTIQUE_FONT, HANDWRITTEN_FONT, STONE_TABLET_FONT and CHAT_FONT were measured crashing a
-- PS5, because a face nothing else is drawing with has to be built on use and that build comes
-- out of the memory every add-on shares. Aliases, never resolved paths, so a Japanese client
-- hands back a face that can draw Japanese ingredient names.
addon.FACES = {
	{ alias = "$(GAMEPAD_MEDIUM_FONT)", label = "SI_PBSCMA_FACE_GAMEPAD_MEDIUM" },
	{ alias = "$(GAMEPAD_BOLD_FONT)", label = "SI_PBSCMA_FACE_GAMEPAD_BOLD" },
	{ alias = "$(GAMEPAD_LIGHT_FONT)", label = "SI_PBSCMA_FACE_GAMEPAD_LIGHT" },
	{ alias = "$(MEDIUM_FONT)", label = "SI_PBSCMA_FACE_MEDIUM" },
	{ alias = "$(BOLD_FONT)", label = "SI_PBSCMA_FACE_BOLD" },
}

-- Style tokens, not FONT_STYLE_* numbers: SetFont parses "face|size|style" out of the string,
-- and the token names are not the enum names lowercased (FONT_STYLE_OUTLINE_THICK is written
-- "thick-outline"). Only the ones the client's own fontdefs use are offered; the rest would be
-- a guess about what the engine's parser accepts, and a font that fails to build is not a good
-- surprise on a console.
addon.STYLES = {
	{ token = "soft-shadow-thin", label = "SI_PBSCMA_STYLE_SOFT_THIN" },
	{ token = "soft-shadow-thick", label = "SI_PBSCMA_STYLE_SOFT_THICK" },
	{ token = "thick-outline", label = "SI_PBSCMA_STYLE_OUTLINE" },
	{ token = "shadow", label = "SI_PBSCMA_STYLE_SHADOW" },
	{ token = "none", label = "SI_PBSCMA_STYLE_NONE" },
}

addon.MIN_WIDTH, addon.MAX_WIDTH = 320, 1400
addon.MIN_HEIGHT, addon.MAX_HEIGHT = 140, 900
addon.MIN_FONT_SIZE, addon.MAX_FONT_SIZE = 14, 64
addon.MAX_OFFSET_X, addon.MAX_OFFSET_Y = 1400, 800

local PADDING = 12

local COLOUR_TEXT = "FFFFFF"
local COLOUR_DIM = "9A9A9A"
local COLOUR_SHORT = "FF6060"
local COLOUR_OK = "6FE38A"
local COLOUR_CURSOR = "FFD100"

local function Paint(hex, text)
	return "|c" .. hex .. tostring(text) .. "|r"
end

-- ---------------------------------------------------------------------------------------
-- Settings, read defensively
--
-- Every one of these can be missing or nonsense in a saved-variables file written by an older
-- version, and none of them may take the window down: an unreadable setting falls back to the
-- shipped one rather than to nil, which is what SetFont and SetDimensions would choke on.
-- ---------------------------------------------------------------------------------------

local function Settings()
	return (addon.sv and addon.sv.window) or addon.DEFAULTS.window
end

local Clamp = addon.Clamp

function hud:Width()
	return Clamp(Settings().width, addon.MIN_WIDTH, addon.MAX_WIDTH) or addon.DEFAULTS.window.width
end

function hud:Height()
	return Clamp(Settings().height, addon.MIN_HEIGHT, addon.MAX_HEIGHT) or addon.DEFAULTS.window.height
end

function hud:Size()
	return Clamp(Settings().size, addon.MIN_FONT_SIZE, addon.MAX_FONT_SIZE) or addon.DEFAULTS.window.size
end

function hud:Opacity()
	return Clamp(Settings().opacity, 0, 100) or addon.DEFAULTS.window.opacity
end

function hud:OffsetX()
	return Clamp(Settings().offsetX, -addon.MAX_OFFSET_X, addon.MAX_OFFSET_X) or 0
end

function hud:OffsetY()
	return Clamp(Settings().offsetY, -addon.MAX_OFFSET_Y, addon.MAX_OFFSET_Y) or 0
end

function hud:Face()
	local wanted = Settings().face
	for _, face in ipairs(addon.FACES) do
		if face.alias == wanted then
			return wanted
		end
	end
	return addon.DEFAULTS.window.face
end

function hud:Style()
	local wanted = Settings().style
	for _, style in ipairs(addon.STYLES) do
		if style.token == wanted then
			return wanted
		end
	end
	return addon.DEFAULTS.window.style
end

function hud:Position()
	local wanted = Settings().position
	if ANCHORS[wanted] then
		return wanted
	end
	return ANCHORS[addon.DEFAULTS.window.position] and addon.DEFAULTS.window.position or "TOPLEFT"
end

function hud:Draw()
	local wanted = Settings().draw
	if DRAW_ORDERS[wanted] then
		return wanted
	end
	return DRAW_ORDERS[addon.DEFAULTS.window.draw] and addon.DEFAULTS.window.draw or "FRONT"
end

-- "face|size|style" -- the string a LabelControl's SetFont parses.
function hud:FontString()
	return string.format("%s|%d|%s", self:Face(), self:Size(), self:Style())
end

-- Marked protected-attributes in the API dump, which has been wrong in both directions before,
-- and shipped add-ons do call it. Attempted, and its failure survivable: a refused call leaves
-- the window drawing where it already was, and the panel says so rather than letting the
-- setting look as though it did something.
local function ApplyDrawOrder(window, token)
	local order = DRAW_ORDERS[token] or DRAW_ORDERS.FRONT
	if not (window and order) then
		return false
	end
	return (pcall(function()
		window:SetDrawLayer(order.layer)
		window:SetDrawTier(order.tier)
	end))
end

-- ---------------------------------------------------------------------------------------
-- The controls
-- ---------------------------------------------------------------------------------------

local function MakeLabel(wm, name, parent, alignment)
	local label = wm:CreateControl(name, parent, CT_LABEL)
	label:SetMouseEnabled(false)
	label:SetVerticalAlignment(TEXT_ALIGN_TOP)
	label:SetHorizontalAlignment(alignment)
	-- Left white on purpose: the colour of every line lives in the text as |cRRGGBB markup,
	-- which is the only way one label can carry rows in three different colours.
	label:SetColor(1, 1, 1, 1)
	return label
end

function hud:Create()
	if self.window then
		return true
	end
	if self.failed then
		return false
	end

	local wm = WINDOW_MANAGER
	if not (wm and wm.CreateTopLevelWindow and wm.CreateControl and CT_LABEL and GuiRoot) then
		self.failed = true
		return false
	end

	local ok, window = pcall(function()
		return wm:CreateTopLevelWindow(WINDOW_NAME)
	end)
	if not ok or not window then
		self.failed = true
		return false
	end

	window:SetMouseEnabled(false)
	window:SetMovable(false)
	window:SetHidden(true)

	-- Created before the labels so it is drawn under them.
	if CT_BACKDROP then
		local madeOk, made = pcall(function()
			return wm:CreateControl(WINDOW_NAME .. "Backdrop", window, CT_BACKDROP)
		end)
		if madeOk and made then
			self.backdrop = made
			self.backdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
			self.backdrop:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
			self.backdrop:SetMouseEnabled(false)
		end
	end

	self.window = window
	self.title = MakeLabel(wm, WINDOW_NAME .. "Title", window, TEXT_ALIGN_LEFT)
	self.columns = {
		MakeLabel(wm, WINDOW_NAME .. "Name", window, TEXT_ALIGN_LEFT),
		MakeLabel(wm, WINDOW_NAME .. "Need", window, TEXT_ALIGN_RIGHT),
		MakeLabel(wm, WINDOW_NAME .. "Have", window, TEXT_ALIGN_RIGHT),
		MakeLabel(wm, WINDOW_NAME .. "Short", window, TEXT_ALIGN_RIGHT),
	}

	self:Apply()
	return true
end

function hud:Available()
	return self.window ~= nil and not self.failed
end

-- Called whenever anything about the look changes, so moving a slider in the panel moves the
-- real thing while you watch it.
function hud:Apply()
	if not self.window then
		return
	end

	local width, height, size = self:Width(), self:Height(), self:Size()
	local anchor = ANCHORS[self:Position()] or ANCHORS.TOPLEFT

	self.window:SetDimensions(width, height)
	self.window:ClearAnchors()
	self.window:SetAnchor(anchor.point, GuiRoot, anchor.point, self:OffsetX(), self:OffsetY())

	local font = self:FontString()
	local titleHeight = math.floor(size * 2.7)

	self.title:SetFont(font)
	self.title:ClearAnchors()
	self.title:SetAnchor(TOPLEFT, self.window, TOPLEFT, PADDING, PADDING)
	self.title:SetDimensions(width - PADDING * 2, titleHeight)
	if self.title.SetMaxLineCount then
		self.title:SetMaxLineCount(2)
	end

	-- A number column has to hold four digits and a little air. Derived from the text size so
	-- that making the text bigger does not push the numbers into each other.
	local numberWidth = math.floor(size * 3.2)
	if numberWidth < 56 then
		numberWidth = 56
	end
	local nameWidth = width - PADDING * 2 - numberWidth * 3
	if nameWidth < 80 then
		-- A window narrow enough for this is a window the numbers matter more in than the
		-- names; the name column keeps a floor and the ellipsis does the rest.
		nameWidth = 80
	end

	local bodyTop = PADDING + titleHeight
	local bodyHeight = height - bodyTop - PADDING
	if bodyHeight < size then
		bodyHeight = size
	end

	local widths = { nameWidth, numberWidth, numberWidth, numberWidth }
	local x = PADDING
	for index, label in ipairs(self.columns) do
		label:SetFont(font)
		label:ClearAnchors()
		label:SetAnchor(TOPLEFT, self.window, TOPLEFT, x, bodyTop)
		label:SetDimensions(widths[index], bodyHeight)
		if label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
			label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
		end
		-- The hard bound on what can be drawn: without it a long list would push text out of
		-- the window and over whatever is beside it. One more than a full page, for the
		-- heading row.
		if label.SetMaxLineCount then
			label:SetMaxLineCount(addon.PAGE_SIZE + 1)
		end
		x = x + widths[index]
	end

	if self.backdrop then
		local alpha = self:Opacity() / 100
		self.backdrop:SetCenterColor(0, 0, 0, alpha)
		self.backdrop:SetEdgeColor(0, 0, 0, alpha)
		self.backdrop:SetHidden(alpha <= 0)
	end

	-- Applied every time rather than only on the change: the choice has to survive the window
	-- being created after the setting was made, which is the usual order on a fresh login.
	self.drawOrderRefused = not ApplyDrawOrder(self.window, self:Draw())
end

-- ---------------------------------------------------------------------------------------
-- Drawing
-- ---------------------------------------------------------------------------------------

local function SetText(hud, titleLines, columns)
	hud.title:SetText(table.concat(titleLines, "\n"))
	for index, label in ipairs(hud.columns) do
		label:SetText(table.concat(columns[index] or {}, "\n"))
	end
	hud.window:SetHidden(false)
end

-- A single line across the whole window: no table, just something to say.
local function Message(hud, titleLines, message)
	SetText(hud, titleLines, { { Paint(COLOUR_DIM, message) }, {}, {}, {} })
end

function hud:RenderMaterials()
	local requirements = addon.recipes:Requirements()
	if not requirements then
		Message(self, { Paint(COLOUR_TEXT, GetString(SI_PBSCMA_WINDOW_TITLE)) },
			GetString(SI_PBSCMA_WINDOW_TARGET_LOST))
		return
	end

	local title = { }
	local heading = Paint(COLOUR_TEXT, requirements.name)
		.. Paint(COLOUR_DIM, string.format("  x%d", requirements.iterations))
	if requirements.resultCount and requirements.resultCount ~= requirements.iterations then
		heading = heading .. Paint(COLOUR_DIM,
			addon.Format(SI_PBSCMA_WINDOW_YIELD, requirements.resultCount))
	end
	title[1] = heading

	local second
	if requirements.shortCount > 0 then
		second = Paint(COLOUR_SHORT, addon.Format(SI_PBSCMA_WINDOW_SHORT, requirements.shortCount))
	else
		second = Paint(COLOUR_OK, GetString(SI_PBSCMA_WINDOW_ENOUGH))
	end
	if requirements.craftable then
		second = second .. Paint(COLOUR_DIM,
			addon.Format(SI_PBSCMA_WINDOW_CRAFTABLE, requirements.craftable))
	end
	if requirements.unknownCount > 0 then
		second = second .. Paint(COLOUR_DIM, GetString(SI_PBSCMA_WINDOW_UNCOUNTED))
	end
	title[2] = second

	local names = { Paint(COLOUR_DIM, GetString(SI_PBSCMA_COLUMN_MATERIAL)) }
	local needs = { Paint(COLOUR_DIM, GetString(SI_PBSCMA_COLUMN_NEED)) }
	local haves = { Paint(COLOUR_DIM, GetString(SI_PBSCMA_COLUMN_HAVE)) }
	local shorts = { Paint(COLOUR_DIM, GetString(SI_PBSCMA_COLUMN_SHORT)) }

	for _, row in ipairs(requirements.rows) do
		local isShort = (row.short or 0) > 0
		local colour = isShort and COLOUR_SHORT or COLOUR_TEXT
		names[#names + 1] = Paint(colour, row.name)
		needs[#needs + 1] = Paint(colour, row.need)
		haves[#haves + 1] = Paint(row.have == nil and COLOUR_DIM or colour,
			row.have == nil and "?" or row.have)
		if row.have == nil then
			shorts[#shorts + 1] = Paint(COLOUR_DIM, "?")
		elseif isShort then
			shorts[#shorts + 1] = Paint(COLOUR_SHORT, row.short)
		else
			shorts[#shorts + 1] = Paint(COLOUR_OK, "-")
		end
	end

	SetText(self, title, { names, needs, haves, shorts })
end

function hud:RenderBrowse()
	local entries = addon:PageEntries()

	local title = {}
	local text = addon.sv.browse.text or ""
	local category = addon.recipes:CategoryName(addon:Category())
	if text ~= "" then
		title[1] = Paint(COLOUR_TEXT, addon.Format(SI_PBSCMA_BROWSE_TITLE_SEARCH, text))
			.. Paint(COLOUR_DIM, "  " .. category)
	else
		title[1] = Paint(COLOUR_TEXT, addon.Format(SI_PBSCMA_BROWSE_TITLE, category))
	end
	title[2] = Paint(COLOUR_DIM, addon.Format(SI_PBSCMA_BROWSE_COUNT,
		#addon.matches, addon:Page(), addon:PageCount()))
		.. (addon.truncated and Paint(COLOUR_DIM, GetString(SI_PBSCMA_BROWSE_TRUNCATED)) or "")

	if #entries == 0 then
		Message(self, title, GetString(SI_PBSCMA_BROWSE_EMPTY))
		return
	end

	local cursor = addon:Cursor()
	local names = { Paint(COLOUR_DIM, GetString(SI_PBSCMA_COLUMN_CANDIDATE)) }
	local counts = { Paint(COLOUR_DIM, GetString(SI_PBSCMA_COLUMN_INGREDIENTS)) }

	for number, entry in ipairs(entries) do
		local selected = number == cursor
		local colour = selected and COLOUR_CURSOR or COLOUR_TEXT
		local marker = selected and ">" or " "
		local name = entry.name
		if not entry.known then
			name = name .. GetString(SI_PBSCMA_BROWSE_UNKNOWN_MARK)
		end
		names[#names + 1] = Paint(colour, string.format("%s%d. %s", marker, number, name))
		counts[#counts + 1] = Paint(selected and COLOUR_CURSOR or COLOUR_DIM, entry.ingredients)
	end

	SetText(self, title, { names, counts, {}, {} })
end

-- The one entry point. Everything that changes anything calls this and nothing else.
function hud:Refresh()
	if not addon.sv or not addon:Enabled() then
		if self.window then
			self.window:SetHidden(true)
		end
		return
	end

	if not self:Create() then
		return
	end
	self:Apply()

	if not addon.recipes:Available() then
		Message(self, { Paint(COLOUR_TEXT, GetString(SI_PBSCMA_WINDOW_TITLE)) },
			GetString(SI_PBSCMA_ERROR_NO_API))
		return
	end

	if addon:Showing() then
		self:RenderBrowse()
	elseif addon:HasTarget() then
		self:RenderMaterials()
	else
		Message(self, { Paint(COLOUR_TEXT, GetString(SI_PBSCMA_WINDOW_TITLE)) },
			GetString(SI_PBSCMA_WINDOW_NOTHING_PICKED))
	end
end

-- After a reset: the window is rebuilt from the shipped settings rather than kept with the
-- old geometry, and a window that failed to create once is allowed to try again.
function hud:Reset()
	self.failed = false
	self:Apply()
end
