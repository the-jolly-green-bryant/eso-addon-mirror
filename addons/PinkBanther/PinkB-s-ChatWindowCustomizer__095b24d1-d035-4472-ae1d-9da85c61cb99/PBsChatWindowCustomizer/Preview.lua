-- PBS_CHAT_WINDOW_CUSTOMIZER is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_CHAT_WINDOW_CUSTOMIZER then
	return
end

local addon = PBS_CHAT_WINDOW_CUSTOMIZER

-- ---------------------------------------------------------------------------------------
-- The preview frame
--
-- The chat is only drawn on the HUD (ZO_GamepadChatSystem:IsHidden wants HUD_FRAGMENT showing),
-- so while the settings panel is open the real window cannot be seen, and every slider would
-- otherwise mean backing out to the HUD to look. This draws where the window will be instead: an
-- outline at the chosen place and size, the input line where the chat puts it, and a few lines of
-- sample chat in the chosen text size.
--
-- Built entirely from controls of our own. Showing the real chat in a menu would mean calling the
-- chat's Maximize and fade code from an add-on frame, which is exactly the kind of call that
-- leaves client closures untrusted -- and the chat is where the player sends messages from.
--
-- The input line's place is copied from the chat's own XML rather than measured: 30 high
-- (ZO_ChatWindowTopLevelTemplate), 13 up from the bottom and 37 in from the right
-- (gamepadchatsystem.xml), with the message area ending 3 above it (SetAsPrimary).
-- ---------------------------------------------------------------------------------------

local preview = {
	lines = {},
}
addon.preview = preview

local NAME = "PBsChatWindowCustomizerPreview"
local ENTRY_HEIGHT = 30
local ENTRY_BOTTOM = 13
local ENTRY_RIGHT = 37
local ENTRY_GAP = 3
local TEXT_INSET = 6
local EDGE = 2
local MAX_LINES = 40
local CHECK_INTERVAL_MS = 250

-- PB's pink, the same colour as the add-on's name.
local PINK = { 1, 0.41, 0.71 }

-- Sample chat, oldest first. Kept short so a line fits the default width at the default size;
-- the point is to show how big the text is, not how the chat wraps.
local SAMPLE_IDS = {
	"SI_PBSCWC_PREVIEW_LINE_1",
	"SI_PBSCWC_PREVIEW_LINE_2",
	"SI_PBSCWC_PREVIEW_LINE_3",
	"SI_PBSCWC_PREVIEW_LINE_4",
	"SI_PBSCWC_PREVIEW_LINE_5",
	"SI_PBSCWC_PREVIEW_LINE_6",
}

-- A named font the gamepad UI already has built, for the preview's own captions.
local CAPTION_FONT = "ZoFontGamepad22"

local function Texture(parent, suffix, r, g, b, a)
	local texture = WINDOW_MANAGER:CreateControl(NAME .. suffix, parent, CT_TEXTURE)
	texture:SetColor(r, g, b, a)
	return texture
end

local function Label(parent, suffix, font)
	local label = WINDOW_MANAGER:CreateControl(NAME .. suffix, parent, CT_LABEL)
	label:SetFont(font)
	return label
end

function preview:Create()
	if self.control then
		return self.control
	end
	if not WINDOW_MANAGER or not GuiRoot then
		return nil
	end

	local top = WINDOW_MANAGER:CreateTopLevelWindow(NAME)
	top:SetHidden(true)
	top:SetMouseEnabled(false)
	-- Above the settings panel, which is what it is drawn over.
	top:SetDrawLayer(DL_OVERLAY)
	top:SetDrawTier(DT_HIGH)
	self.control = top

	local fill = Texture(top, "Fill", 0, 0, 0, 0.6)
	fill:SetAnchorFill(top)

	local edges = {
		{ "EdgeTop", TOPLEFT, TOPRIGHT, "height" },
		{ "EdgeBottom", BOTTOMLEFT, BOTTOMRIGHT, "height" },
		{ "EdgeLeft", TOPLEFT, BOTTOMLEFT, "width" },
		{ "EdgeRight", TOPRIGHT, BOTTOMRIGHT, "width" },
	}
	for _, edge in ipairs(edges) do
		local texture = Texture(top, edge[1], PINK[1], PINK[2], PINK[3], 1)
		texture:SetAnchor(edge[2], top, edge[2], 0, 0)
		texture:SetAnchor(edge[3], top, edge[3], 0, 0)
		if edge[4] == "height" then
			texture:SetHeight(EDGE)
		else
			texture:SetWidth(EDGE)
		end
	end

	local entry = Texture(top, "Entry", 1, 1, 1, 0.15)
	entry:SetAnchor(BOTTOMLEFT, top, BOTTOMLEFT, TEXT_INSET, -ENTRY_BOTTOM)
	entry:SetAnchor(BOTTOMRIGHT, top, BOTTOMRIGHT, -ENTRY_RIGHT, -ENTRY_BOTTOM)
	entry:SetHeight(ENTRY_HEIGHT)
	self.entry = entry

	local entryLabel = Label(top, "EntryLabel", CAPTION_FONT)
	entryLabel:SetAnchor(LEFT, entry, LEFT, 8, 0)
	entryLabel:SetColor(1, 1, 1, 0.6)
	entryLabel:SetText(GetString(SI_PBSCWC_PREVIEW_ENTRY))

	local caption = Label(top, "Caption", CAPTION_FONT)
	caption:SetColor(PINK[1], PINK[2], PINK[3], 1)
	caption:SetText(GetString(SI_PBSCWC_PREVIEW_CAPTION))
	self.caption = caption

	-- Checked a few times a second while shown: the preview goes away by itself once the panel
	-- it belongs to is no longer on screen, whichever way the player left it.
	local nextCheck = 0
	top:SetHandler("OnUpdate", function()
		local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
		if now < nextCheck then
			return
		end
		nextCheck = now + CHECK_INTERVAL_MS
		if not preview:StillWanted() then
			preview:Hide()
		end
	end)

	return top
end

-- One label per sample line, stacked up from the input line, so a line too long for the window
-- ends in "..." rather than wrapping into the one above.
function preview:LineLabel(index)
	local label = self.lines[index]
	if label then
		return label
	end
	label = Label(self.control, "Line" .. index, CAPTION_FONT)
	label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	label:SetMaxLineCount(1)
	local below = index == 1 and self.entry or self.lines[index - 1]
	local gap = index == 1 and -ENTRY_GAP or 0
	label:SetAnchor(BOTTOMLEFT, below, TOPLEFT, 0, gap)
	if index == 1 then
		label:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, -TEXT_INSET, -(ENTRY_BOTTOM + ENTRY_HEIGHT + ENTRY_GAP))
	else
		label:SetAnchor(BOTTOMRIGHT, below, TOPRIGHT, 0, 0)
	end
	self.lines[index] = label
	return label
end

function preview:IsShown()
	return self.control ~= nil and not self.control:IsHidden()
end

-- Redraws the frame for the current settings. Cheap, and a no-op while hidden.
function preview:Update()
	if not self:IsShown() then
		return
	end

	local layout = addon:Clamped(addon:EffectiveLayout())
	local corner = addon.cornerByKey[layout.corner]
	local point = addon:CornerPoint(corner)
	local top = self.control
	top:ClearAnchors()
	top:SetAnchor(point, GuiRoot, point, corner.sx * layout.x, corner.sy * layout.y)
	top:SetDimensions(layout.width, layout.height)

	-- The caption sits just above the frame, or just below it when the frame is at the top of the
	-- screen and there is no room above.
	local _, rectTop = addon:RectOf(layout)
	self.caption:ClearAnchors()
	if rectTop < 30 then
		self.caption:SetAnchor(TOPLEFT, top, BOTTOMLEFT, 0, 4)
	else
		self.caption:SetAnchor(BOTTOMLEFT, top, TOPLEFT, 0, -4)
	end

	-- The same descriptor the chat has, or is about to have, so the preview costs no font the
	-- chat does not already need.
	local descriptor = addon:EffectiveDescriptor()
	local size = addon:Account().enabled and addon:FontSize() or addon:DefaultFontSize()
	local available = layout.height - (ENTRY_BOTTOM + ENTRY_HEIGHT + ENTRY_GAP) - TEXT_INSET

	local used = 0
	for index = 1, MAX_LINES do
		local label = self:LineLabel(index)
		label:SetFont(descriptor)
		local lineHeight = type(label.GetFontHeight) == "function" and label:GetFontHeight() or 0
		if not lineHeight or lineHeight <= 0 then
			lineHeight = math.ceil(size * 1.3)
		end
		local fits = used + lineHeight <= available
		if fits then
			used = used + lineHeight
			-- Newest line at the bottom, like the chat, so the lines run backwards from the end of
			-- the sample and wrap round when the window is taller than the sample is long.
			local sampleIndex = #SAMPLE_IDS - ((index - 1) % #SAMPLE_IDS)
			label:SetText(GetString(_G[SAMPLE_IDS[sampleIndex]]))
		end
		label:SetHidden(not fits)
	end
end

function preview:Show()
	if not self:Create() then
		return false
	end
	self.scene = SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene and SCENE_MANAGER:GetCurrentScene() or nil
	self.control:SetHidden(false)
	self:Update()
	return true
end

function preview:Hide()
	if self.control then
		self.control:SetHidden(true)
	end
	self.forced = false
	self.forPanel = false
end

-- Whether whatever asked for the preview is still on screen: the scene it was shown in, and for
-- the settings panel, the panel itself. LibHarvensAddonSettings marks the selected add-on's
-- panel with .selected; a copy of the library that does not is judged by the scene alone.
function preview:StillWanted()
	if not (self.forced or self.forPanel) then
		return false
	end
	local current = SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene and SCENE_MANAGER:GetCurrentScene() or nil
	if current ~= self.scene then
		return false
	end
	if self.forPanel and not self.forced then
		if not addon:Account().preview then
			return false
		end
		local panel = addon.settingsPanel
		if panel and panel.selected == false then
			return false
		end
	end
	return true
end

-- ---------------------------------------------------------------------------------------
-- Following the settings panel
--
-- On console the library opens a panel in two steps (LibHarvensAddonSettings, Console/
-- Settings.lua, the add-on list's activatedCallback):
--
--   addon:Select()                                      fires AddonSelected, then sets .selected
--   SCENE_MANAGER:Push("LibHarvensAddonSettingsScene")  and only then shows the panel
--
-- So AddonSelected arrives while the add-on list is still the current scene. A preview shown
-- there notes the wrong scene and hides itself the moment the panel comes up. And Select()
-- returns early for the add-on already selected, so a second visit to the same panel fires
-- nothing at all. The panel scene itself is the reliable signal: shown with our panel selected
-- means the preview is wanted, hiding means it is not.
--
-- The scene only exists once the library has initialised, which it does the first time the main
-- menu opens -- after every add-on has loaded -- so it is looked up when a panel is picked, not
-- at load. The first pick of any panel always comes before its scene is shown.
-- ---------------------------------------------------------------------------------------

local PANEL_SCENE_NAME = "LibHarvensAddonSettingsScene"

function preview:PanelScene()
	local library = LibHarvensAddonSettings
	local scene = library and library.scene
	if not scene and SCENE_MANAGER and type(SCENE_MANAGER.GetScene) == "function" then
		scene = SCENE_MANAGER:GetScene(PANEL_SCENE_NAME)
	end
	if type(scene) == "table" and type(scene.RegisterCallback) == "function" then
		return scene
	end
	return nil
end

-- Registered on the library's scene, beside the library's own callbacks. Once only.
function preview:WatchPanelScene()
	if self.panelScene then
		return self.panelScene
	end
	local scene = self:PanelScene()
	if not scene then
		return nil
	end
	self.panelScene = scene
	scene:RegisterCallback("StateChange", function(_, newState)
		if newState == SCENE_SHOWN then
			local panel = addon.settingsPanel
			self:SetPanelOpen(panel ~= nil and panel.selected == true)
		elseif newState == SCENE_HIDING then
			self:SetPanelOpen(false)
		end
	end)
	return scene
end

-- LibHarvensAddonSettings_AddonSelected. On console the panel scene is not up yet, and its
-- SCENE_SHOWN does the showing; the PC copy of the library has no such scene and shows the panel
-- in place, so there the preview goes up at once.
function preview:OnAddonSelected(addonSettings)
	local scene = self:WatchPanelScene()
	if addonSettings ~= addon.settingsPanel then
		self:SetPanelOpen(false)
		return
	end
	if scene and not (type(scene.IsShowing) == "function" and scene:IsShowing()) then
		return
	end
	self:SetPanelOpen(true)
end

-- The settings panel was opened (true) or another add-on's panel was picked (false).
function preview:SetPanelOpen(open)
	self.forPanel = open and true or false
	if self.forPanel and addon:Account().preview then
		self:Show()
	elseif not self.forced then
		self:Hide()
	end
end

-- The slash command: shows the frame wherever the player is -- on the HUD it sits on top of the
-- real chat, which is the quickest way to see that the two agree.
function preview:Toggle()
	if self:IsShown() then
		self:Hide()
		return false
	end
	self.forced = true
	return self:Show()
end
