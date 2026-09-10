-- PB's MailerExtension -- the drafts and sent boxes in the keyboard mail window
--
-- The keyboard mail window's two tabs are a scene group and a table of tab icons:
--
--     SCENE_MANAGER:AddSceneGroup("mailSceneGroup", ZO_SceneGroup:New("mailInbox", "mailSend"))
--     MAIN_MENU_KEYBOARD:AddSceneGroup(MENU_CATEGORY_MAIL, "mailSceneGroup", iconData)
--
-- Both are added to rather than rebuilt. ZO_SceneGroup:AddScene puts another scene in the
-- group, and the tab bar is drawn from `sceneGroupInfo.menuBarIconData` every time the group
-- is shown (MainMenu_Keyboard:SetupSceneGroupBar), so appending a row to that table is enough
-- to get another tab. Calling AddSceneGroup again with a longer table would work too, and
-- would re-register a StateChange callback on every scene that was already in it.
--
-- No client function is wrapped here -- see FINDINGS §7 for what that costs.
--
-- The windows are drawn here rather than described in XML. Each is a right-panel-sized
-- top-level window -- the same 930x690 footprint the client's own mail windows use -- holding
-- a page of rows. Rows are labels with the mouse switched on, not buttons: a label is the
-- control whose text alignment and colour are certain in every client, and the two things a
-- row has to do are be readable and be clickable.
--
-- Both tabs are the same screen twice, differing only in which box they show.
--
-- PBS_MAILER_EXTENSION is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_MAILER_EXTENSION then
	return
end

local addon = PBS_MAILER_EXTENSION
local ui = addon.ui

local Format = addon.Format

local keyboard = {}
addon.keyboardUI = keyboard

local SCENE_GROUP = "mailSceneGroup"

-- The right-panel footprint, copied from ZO_RightPanelFootPrint (windowtemplates.xml) rather
-- than inherited, so this file needs no XML of its own.
local PANEL_WIDTH, PANEL_HEIGHT, PANEL_OFFSET_Y = 930, 690, 32

-- Eight rows rather than twelve, and the space that buys goes to the letter itself. A box of
-- kept mail whose bodies cannot be read is a box of subject lines; the same panel is worth
-- having on the other two, where it shows what a draft actually says before it goes back on
-- the page.
local ROWS_PER_PAGE = 8
local ROW_HEIGHT = 34
local ROWS_TOP = 64
local PADDING = 10

local BODY_TOP_GAP = 16
local BODY_HEIGHT = 250

local COLOUR_ROW = "C5C29E"
local COLOUR_SELECTED = "FFD100"
local COLOUR_DIM = "9A9A9A"

local function Paint(hex, text)
	return "|c" .. hex .. tostring(text) .. "|r"
end

-- ---------------------------------------------------------------------------------------
-- The window
-- ---------------------------------------------------------------------------------------

local function Label(parent, name, font, width)
	local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
	label:SetFont(font)
	label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	if width then
		label:SetWidth(width)
	end
	return label
end

local function Button(parent, name, text, onClicked)
	local button = CreateControlFromVirtual(name, parent, "ZO_DefaultButton")
	button:SetText(text)
	-- Both dimensions, not just the width: ZO_DefaultButton carries no size of its own, and a
	-- button 200 wide and 0 tall is a button nobody can click.
	button:SetDimensions(200, 28)
	button:SetHandler("OnClicked", onClicked)
	return button
end

local Screen = {}
Screen.__index = Screen

local function NewScreen(config)
	return setmetatable({
		box = config.box,
		sceneName = config.sceneName,
		windowName = config.windowName,
		titleId = config.titleId,
		emptyId = config.emptyId,
		icons = config.icons,
	}, Screen)
end

function Screen:BuildWindow()
	if self.window then
		return self.window
	end

	local window = WINDOW_MANAGER:CreateTopLevelWindow(self.windowName)
	window:SetDimensions(PANEL_WIDTH, PANEL_HEIGHT)
	window:SetAnchor(RIGHT, GuiRoot, RIGHT, 0, PANEL_OFFSET_Y)
	window:SetMouseEnabled(true)
	window:SetHidden(true)
	self.window = window

	self.title = Label(window, self.windowName .. "Title", "ZoFontWinH2", PANEL_WIDTH - PADDING * 2)
	self.title:SetAnchor(TOPLEFT, window, TOPLEFT, PADDING, PADDING)

	self.rows = {}
	for index = 1, ROWS_PER_PAGE do
		local row = Label(window, self.windowName .. "Row" .. index, "ZoFontGame", PANEL_WIDTH - PADDING * 2)
		row:SetAnchor(TOPLEFT, window, TOPLEFT, PADDING, ROWS_TOP + (index - 1) * ROW_HEIGHT)
		row:SetHeight(ROW_HEIGHT)
		row:SetMouseEnabled(true)
		row:SetHandler("OnMouseUp", function(_, button, upInside)
			if upInside and row.pbIndex then
				self:Select(row.pbIndex)
			end
		end)
		self.rows[index] = row
	end

	local listBottom = ROWS_TOP + ROWS_PER_PAGE * ROW_HEIGHT

	self.footer = Label(window, self.windowName .. "Footer", "ZoFontGame", PANEL_WIDTH - PADDING * 2)
	self.footer:SetAnchor(TOPLEFT, window, TOPLEFT, PADDING, listBottom + PADDING)

	-- The letter itself. A plain multi-line label: the body already arrives with its own line
	-- breaks, and what does not fit is cut off by the label rather than by us, so nothing has
	-- to guess at a character count.
	self.body = Label(window, self.windowName .. "Body", "ZoFontGame", PANEL_WIDTH - PADDING * 2)
	self.body:SetAnchor(TOPLEFT, window, TOPLEFT, PADDING, listBottom + PADDING + BODY_TOP_GAP + 12)
	self.body:SetHeight(BODY_HEIGHT)
	self.body:SetVerticalAlignment(TEXT_ALIGN_TOP)
	if self.body.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
		self.body:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	end

	self.loadButton = Button(window, self.windowName .. "Load", self.box:LoadLabel(), function()
		if self.selected then
			ui:RequestLoad(self.box, self.selected)
		end
	end)
	self.loadButton:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, PADDING, -PADDING)

	self.deleteButton = Button(window, self.windowName .. "Delete", GetString(SI_PBSMX_KEYBIND_DELETE), function()
		if self.selected then
			ui:ConfirmDelete(self.box, self.selected, function()
				self.selected = nil
				self:Refresh()
			end)
		end
	end)
	self.deleteButton:SetAnchor(BOTTOMLEFT, self.loadButton, BOTTOMRIGHT, PADDING, 0)

	self.previousButton = Button(window, self.windowName .. "Previous", GetString(SI_PBSMX_PAGE_PREVIOUS), function()
		self:SetPage((self.page or 1) - 1)
	end)
	self.previousButton:SetDimensions(120, 28)
	self.previousButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -PADDING - 130, -PADDING)

	self.nextButton = Button(window, self.windowName .. "Next", GetString(SI_PBSMX_PAGE_NEXT), function()
		self:SetPage((self.page or 1) + 1)
	end)
	self.nextButton:SetDimensions(120, 28)
	self.nextButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -PADDING, -PADDING)

	return window
end

-- ---------------------------------------------------------------------------------------
-- Drawing it
-- ---------------------------------------------------------------------------------------

function Screen:Pages()
	local count = #self.box:All()
	if count == 0 then
		return 1
	end
	return math.ceil(count / ROWS_PER_PAGE)
end

function Screen:SetPage(page)
	local pages = self:Pages()
	if page < 1 then
		page = 1
	elseif page > pages then
		page = pages
	end
	self.page = page
	self:Refresh()
end

function Screen:Select(index)
	self.selected = index
	self:Refresh()
end

function Screen:Refresh()
	if not self.window then
		return
	end

	local all = self.box:All()
	local pages = self:Pages()
	self.page = math.min(self.page or 1, pages)

	self.title:SetText(#all == 0 and GetString(self.emptyId)
		or Format(SI_PBSMX_LIST_HEADER, self.box:Title(), #all, self.box:Max()))

	local first = (self.page - 1) * ROWS_PER_PAGE
	for slot = 1, ROWS_PER_PAGE do
		local index = first + slot
		local entry = all[index]
		local row = self.rows[slot]
		if entry then
			row.pbIndex = index
			local text = string.format("%d. %s", index, self.box:Describe(entry))
			row:SetText(Paint(index == self.selected and COLOUR_SELECTED or COLOUR_ROW, text))
			row:SetHidden(false)
		else
			row.pbIndex = nil
			row:SetText("")
			row:SetHidden(true)
		end
	end

	-- The page number on the left, how much room is left for saved data on the right of the
	-- same line. The keyboard window has no bottom strip of its own to put it in.
	local line, low = addon:StorageLine()
	self.footer:SetText(Paint(COLOUR_DIM, Format(SI_PBSMX_PAGE_OF, self.page, pages)) ..
		(line and ("   " .. (low and ("|cC74A4A" .. line .. "|r") or Paint(COLOUR_DIM, line))) or ""))

	local chosen = self.selected and all[self.selected] or nil
	self.body:SetText(chosen and self.box:Preview(chosen) or Paint(COLOUR_DIM, GetString(SI_PBSMX_PICK_ONE)))
	self.previousButton:SetHidden(pages < 2)
	self.nextButton:SetHidden(pages < 2)

	local hasSelection = self.selected ~= nil and all[self.selected] ~= nil
	if not hasSelection then
		self.selected = nil
	end
	self.loadButton:SetEnabled(hasSelection)
	self.deleteButton:SetEnabled(hasSelection)
end

-- ---------------------------------------------------------------------------------------
-- The tab
-- ---------------------------------------------------------------------------------------

function Screen:Add(group, groupInfo, categoryInfo)
	self:BuildWindow()

	local scene = ZO_Scene:New(self.sceneName, SCENE_MANAGER)
	self.scene = scene

	scene:AddFragment(ZO_FadeSceneFragment:New(self.window))

	-- The furniture that makes it a mail window rather than a panel floating over the world.
	-- Each one is checked first: a client missing one of these must lose the decoration, not
	-- the tab. Named one at a time rather than looped over a table, because a nil in the
	-- middle of a table constructor ends the list early and quietly.
	if FRAGMENT_GROUP then
		if FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW then
			scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
		end
		if FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL then
			scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
		end
	end
	local function Add(sceneFragment)
		if sceneFragment then
			scene:AddFragment(sceneFragment)
		end
	end
	Add(TITLE_FRAGMENT)
	Add(MAIL_TITLE_FRAGMENT)
	Add(RIGHT_BG_FRAGMENT)
	Add(MAIL_WINDOW_SOUNDS)
	-- Keeps the mailbox open across a tab change, the way the other tabs do. Without it,
	-- stepping into this box would close the mailbox and stepping back would re-open it.
	Add(MAIL_INTERACTION_FRAGMENT)
	if groupInfo.sceneGroupBarFragment then
		scene:AddFragment(groupInfo.sceneGroupBarFragment)
	end

	scene:RegisterCallback("StateChange", function(_, newState)
		if newState == SCENE_SHOWING then
			self.selected = nil
			self:SetPage(1)
		end
	end)

	group:AddScene(self.sceneName)
	MAIN_MENU_KEYBOARD:AddRawScene(self.sceneName, MENU_CATEGORY_MAIL, categoryInfo, SCENE_GROUP)

	table.insert(groupInfo.menuBarIconData,
	{
		categoryName = self.titleId,
		descriptor = self.sceneName,
		normal = self.icons.normal,
		pressed = self.icons.pressed,
		highlight = self.icons.highlight,
	})

	return true
end

-- ---------------------------------------------------------------------------------------
-- The two of them
-- ---------------------------------------------------------------------------------------

keyboard.drafts = NewScreen({
	box = addon.drafts,
	sceneName = "pbMailerDrafts",
	windowName = "PBsMailerExtensionDraftsWindow",
	titleId = SI_PBSMX_TAB_DRAFTS,
	emptyId = SI_PBSMX_LIST_EMPTY,
	icons =
	{
		normal = "EsoUI/Art/Crafting/sketches_tabIcon_up.dds",
		pressed = "EsoUI/Art/Crafting/sketches_tabIcon_down.dds",
		highlight = "EsoUI/Art/Crafting/sketches_tabIcon_over.dds",
	},
})

keyboard.sent = NewScreen({
	box = addon.sent,
	sceneName = "pbMailerSent",
	windowName = "PBsMailerExtensionSentWindow",
	titleId = SI_PBSMX_TAB_SENT,
	emptyId = SI_PBSMX_SENT_EMPTY,
	icons =
	{
		normal = "EsoUI/Art/Guild/tabIcon_history_up.dds",
		pressed = "EsoUI/Art/Guild/tabIcon_history_down.dds",
		highlight = "EsoUI/Art/Guild/tabIcon_history_over.dds",
	},
})

keyboard.kept = NewScreen({
	box = addon.kept,
	sceneName = "pbMailerKept",
	windowName = "PBsMailerExtensionKeptWindow",
	titleId = SI_PBSMX_TAB_KEPT,
	emptyId = SI_PBSMX_KEPT_EMPTY,
	icons =
	{
		normal = "EsoUI/Art/Collections/collections_tabIcon_itemSets_up.dds",
		pressed = "EsoUI/Art/Collections/collections_tabIcon_itemSets_down.dds",
		highlight = "EsoUI/Art/Collections/collections_tabIcon_itemSets_over.dds",
	},
})

function keyboard:Screens()
	return { self.drafts, self.sent, self.kept }
end

-- ---------------------------------------------------------------------------------------
-- Saving from the Send page
--
-- The Send page's keybind strip is a table the client builds once and hands to KEYBIND_STRIP
-- each time the scene shows, so a button appended to it is drawn with the others. It has
-- Clear on the negative bind and Send on the secondary; the tertiary is free.
-- ---------------------------------------------------------------------------------------

function keyboard:AddSaveKeybind()
	if not MAIL_SEND or not MAIL_SEND.staticKeybindStripDescriptor then
		return false
	end

	table.insert(MAIL_SEND.staticKeybindStripDescriptor,
	{
		name = GetString(SI_PBSMX_SAVE_ENTRY),
		keybind = "UI_SHORTCUT_TERTIARY",
		callback = function()
			ui:Save("")
		end,
	})

	return true
end

-- The inbox strip carries the primary, secondary, tertiary, quaternary, negative and help
-- binds; the quinary is the free one, and the client uses it on keyboard screens of its own
-- (the store window, the fence, the inventory), so it is a real key here.
function keyboard:AddKeepKeybind()
	-- The inbox's strip is its "selection" descriptor -- the one added while a mail is picked
	-- out -- not a static one like the Send page's.
	local descriptor = MAIL_INBOX and (MAIL_INBOX.selectionKeybindStripDescriptor or MAIL_INBOX.staticKeybindStripDescriptor)
	if not descriptor then
		return false
	end

	table.insert(descriptor,
	{
		name = GetString(SI_PBSMX_KEEP_ENTRY),
		keybind = "UI_SHORTCUT_QUINARY",
		callback = function()
			ui:Keep()
			self.kept:Refresh()
		end,
		visible = function()
			return addon.kept:ActiveMailId() ~= nil
		end,
	})

	return true
end

function keyboard:Initialize()
	if not SCENE_MANAGER or not MAIN_MENU_KEYBOARD then
		return false
	end

	local group = SCENE_MANAGER:GetSceneGroup(SCENE_GROUP)
	local groupInfo = MAIN_MENU_KEYBOARD.sceneGroupInfo and MAIN_MENU_KEYBOARD.sceneGroupInfo[SCENE_GROUP]
	local categoryInfo = MAIN_MENU_KEYBOARD.categoryInfo and MAIN_MENU_KEYBOARD.categoryInfo[MENU_CATEGORY_MAIL]
	if not group or not groupInfo or not categoryInfo then
		return false
	end

	for _, screen in ipairs(self:Screens()) do
		screen:Add(group, groupInfo, categoryInfo)
	end

	-- The Send page opening is what the sent box's copy of the page follows.
	if MAIL_SEND_SCENE then
		MAIL_SEND_SCENE:RegisterCallback("StateChange", function(_, newState)
			if newState == SCENE_SHOWN then
				ui:PageOpened()
			elseif newState == SCENE_HIDDEN then
				ui:PageClosed()
			end
		end)
	end

	self:AddSaveKeybind()
	self:AddKeepKeybind()

	return true
end
