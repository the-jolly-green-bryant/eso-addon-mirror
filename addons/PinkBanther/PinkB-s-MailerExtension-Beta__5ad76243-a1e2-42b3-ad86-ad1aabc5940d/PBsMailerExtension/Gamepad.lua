	-- Nothing here brings the Send page up. The letter is written onto the page from the tab
	-- the player is standing on, and they walk over to it themselves -- see UI.lua for the
	-- error that rule was bought with.
-- PB's MailerExtension -- the drafts box in the gamepad mail window
--
-- The gamepad mail screen is a ZO_Gamepad_ParametricList_Screen with a tab bar, and both of
-- those are open enough to add to without replacing anything:
--
--   * the tabs are a plain array, `MAIL_GAMEPAD.tabBarEntries`, of { text, callback } pairs,
--     built once in ZO_Mail_Gamepad:PerformDeferredInitialization. `baseHeaderData` holds a
--     reference to that same array, so a tab appended after it was built is still drawn.
--
--   * `MAIL_GAMEPAD:AddList(name, setup)` builds a list in the screen's own container, with
--     the screen's own look, and returns it. `SetCurrentList` shows and activates it and puts
--     the others away. So the drafts list is the game's list, not a window of ours sitting on
--     top of the mail screen.
--
-- ---------------------------------------------------------------------------------------
-- WHY THERE IS NOT A SINGLE HOOK IN THIS FILE
-- ---------------------------------------------------------------------------------------
--
-- Version 0.2.0 added the tab with ZO_PostHook on ZO_Mail_Gamepad:PerformDeferredInitialization
-- and on ZO_MailSend_Gamepad:PopulateMainList. Both are post hooks. Neither changes what the
-- client function does. They broke the "To" field on a PS5 anyway:
--
--     ZO_PlayerConsoleInfoRequestManager.lua:134: Attempt to access a private function
--     'ShowSelectFromUserListDialog' from insecure code. The callstack became untrusted
--     2 stack frames from the top.
--       ...MailSend_Gamepad.lua:537: in function 'actionFunction'
--
-- Frame 2 is the closure `userListCallback`, and that closure is *created inside*
-- PopulateMainList. Nothing of ours is on the stack when it runs -- so trust is not a property
-- of the running callstack, it is a property of the function object: **a closure created while
-- an add-on frame was on the stack is permanently untrusted.** ZO_PostHook calls the original
-- from our own function, so every closure the client made during that call was born tainted,
-- and the first one to reach a private function -- picking a recipient from the friends list --
-- failed.
--
-- So the rule for this file: never wrap a client function, and never call one that creates
-- closures meant to outlive the call. What is left is only things that cannot taint anything:
--
--   * callbacks REGISTERED with the client's own callback manager (a scene's or a fragment's
--     "StateChange"). Registering stores our function beside theirs; it does not wrap theirs,
--     and nothing of the client's is created inside our frame.
--   * a table entry appended to an array the client reads later -- the tab, the keybind. Data
--     is not code.
--
-- The cost is one refresh: our scene callback necessarily runs after the client has drawn the
-- header, so the first time the mail window opens, the tab bar is redrawn once with the tab in
-- it. Every open after that finds the tab already in the array.
--
-- PBS_MAILER_EXTENSION is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_MAILER_EXTENSION then
	return
end

local addon = PBS_MAILER_EXTENSION
local ui = addon.ui

local Format = addon.Format

local gamepad = {}
addon.gamepadUI = gamepad

-- ---------------------------------------------------------------------------------------
-- A tab
--
-- The drafts box and the sent box are the same tab twice: a list of letters on the left, the
-- one you are on previewed beside it, A to put it on the page and Y to throw it away. So the
-- tab is written once and made twice, and the only difference between the two is which box it
-- shows and what it is called.
-- ---------------------------------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

local function NewTab(config)
	return setmetatable({
		box = config.box,
		listName = config.listName,
		titleId = config.titleId,
		emptyId = config.emptyId,
	}, Tab)
end

local function SetupList(list)
	-- NoCapitalization, because a subject is the player's own words and the list has no
	-- business shouting them.
	list:AddDataTemplate("ZO_GamepadMenuEntryNoCapitalization", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
end

-- The preview beside the list. Wrapped in pcall on purpose: the tooltip pane belongs to the
-- screen we are a guest on, and a preview that fails to draw must not take the tab down with
-- it. Everything the preview says is also in the row itself and in the commands.
local function ClearPreview()
	if not GAMEPAD_TOOLTIPS then
		return
	end
	pcall(function()
		GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
	end)
end

function Tab:Selected()
	if not self.list then
		return nil, nil
	end
	local data = self.list:GetTargetData()
	if not data then
		return nil, nil
	end
	return data.pbIndex, self.box:At(data.pbIndex)
end

function Tab:ShowPreview()
	local _, entry = self:Selected()
	if not GAMEPAD_TOOLTIPS then
		return
	end

	pcall(function()
		if not entry then
			GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
			return
		end
		GAMEPAD_TOOLTIPS:LayoutTitleAndDescriptionTooltip(GAMEPAD_RIGHT_TOOLTIP,
			self.box:Describe(entry, true), self.box:Preview(entry))
	end)
end

function Tab:Refresh()
	if not self.list then
		return
	end

	self.list:Clear()
	for index, entry in ipairs(self.box:All()) do
		local data = ZO_GamepadEntryData:New(self.box:Describe(entry, true))
		data.pbIndex = index
		self.list:AddEntry("ZO_GamepadMenuEntryNoCapitalization", data)
	end
	self.list:Commit()

	self:ShowPreview()
	if MAIL_GAMEPAD and MAIL_GAMEPAD.RefreshKeybind then
		MAIL_GAMEPAD:RefreshKeybind()
	end
end

-- ---------------------------------------------------------------------------------------
-- The keybinds
--
-- A (put on the page), Y (delete), B (back out of the mail window), and the shoulder buttons
-- for paging the list -- the same four a gamepad list in this game always has.
-- ---------------------------------------------------------------------------------------

function Tab:InitializeKeybinds()
	self.keybinds =
	{
		alignment = KEYBIND_STRIP_ALIGN_LEFT,

		KEYBIND_STRIP:GetDefaultGamepadBackButtonDescriptor(),

		{
			name = GetString(SI_PBSMX_KEYBIND_LOAD),
			keybind = "UI_SHORTCUT_PRIMARY",
			callback = function()
				local index = self:Selected()
				if index then
					ui:RequestLoad(self.box, index)
				end
			end,
			enabled = function()
				return self:Selected() ~= nil
			end,
		},

		{
			name = GetString(SI_PBSMX_KEYBIND_DELETE),
			keybind = "UI_SHORTCUT_TERTIARY",
			callback = function()
				local index = self:Selected()
				if index then
					ui:ConfirmDelete(self.box, index, function() self:Refresh() end)
				end
			end,
			enabled = function()
				return self:Selected() ~= nil
			end,
		},
	}

	if ZO_Gamepad_AddListTriggerKeybindDescriptors then
		ZO_Gamepad_AddListTriggerKeybindDescriptors(self.keybinds, self.list)
	end
end

-- ---------------------------------------------------------------------------------------
-- The tab itself
-- ---------------------------------------------------------------------------------------

function Tab:BuildList()
	if self.list or not MAIL_GAMEPAD or not MAIL_GAMEPAD.AddList then
		return
	end

	self.list = MAIL_GAMEPAD:AddList(self.listName, SetupList)
	self.list:SetNoItemText(GetString(self.emptyId))
	self.list:SetOnTargetDataChangedCallback(function()
		self:ShowPreview()
		if MAIL_GAMEPAD.RefreshKeybind then
			MAIL_GAMEPAD:RefreshKeybind()
		end
	end)

	self:InitializeKeybinds()
end

function Tab:Enter()
	self:BuildList()
	if not self.list then
		return
	end

	-- No right-hand pane of our own, so the inbox's or the send page's is taken down. The
	-- preview tooltip lives in that space instead.
	MAIL_GAMEPAD:SwitchToFragment(nil)
	self:Refresh()
	MAIL_GAMEPAD:SwitchToKeybind(self.keybinds)
	MAIL_GAMEPAD:SetCurrentList(self.list)
	self:ShowPreview()
end

function Tab:Add()
	if self.added or not MAIL_GAMEPAD or not MAIL_GAMEPAD.tabBarEntries then
		return false
	end
	self.added = true

	table.insert(MAIL_GAMEPAD.tabBarEntries,
	{
		text = function()
			local count = #self.box:All()
			if count > 0 then
				return Format(SI_PBSMX_TAB_DRAFTS_COUNT, GetString(self.titleId), count)
			end
			return GetString(self.titleId)
		end,
		callback = function()
			self:Enter()
		end,
	})

	return true
end

-- ---------------------------------------------------------------------------------------
-- The two of them
-- ---------------------------------------------------------------------------------------

gamepad.drafts = NewTab({
	box = addon.drafts,
	listName = "PBsMailerExtensionDrafts",
	titleId = SI_PBSMX_TAB_DRAFTS,
	emptyId = SI_PBSMX_LIST_EMPTY,
})

gamepad.sent = NewTab({
	box = addon.sent,
	listName = "PBsMailerExtensionSent",
	titleId = SI_PBSMX_TAB_SENT,
	emptyId = SI_PBSMX_SENT_EMPTY,
})

function gamepad:Tabs()
	return { self.drafts, self.sent }
end

-- The header was drawn a moment before the tabs existed, so it is drawn again -- once, on the
-- first open of a session. Callbacks are blocked and the selected tab is put back, so the
-- redraw cannot move anybody off the tab they are on.
function gamepad:RefreshTabBar()
	local header = MAIL_GAMEPAD.header
	if not header or not header.tabBar or not MAIL_GAMEPAD.headerData then
		return
	end
	if not ZO_GamepadGenericHeader_Refresh then
		return
	end

	local selected = header.tabBar.GetSelectedIndex and header.tabBar:GetSelectedIndex() or nil

	local BLOCK_TAB_BAR_CALLBACKS = true
	ZO_GamepadGenericHeader_Refresh(header, MAIL_GAMEPAD.headerData, BLOCK_TAB_BAR_CALLBACKS)

	if selected and ZO_GamepadGenericHeader_SetActiveTabIndex then
		local ALLOW_EVEN_IF_DISABLED, BLOCK_SELECTION_CALLBACK = false, true
		ZO_GamepadGenericHeader_SetActiveTabIndex(header, selected, ALLOW_EVEN_IF_DISABLED, BLOCK_SELECTION_CALLBACK)
	end
end

-- ---------------------------------------------------------------------------------------
-- Saving from the Send page
--
-- A keybind rather than a row in the Send page's list. The row read better -- it sat under
-- Send, where a controller finds it without being told -- but putting it there meant calling
-- the client's own AddMainListEntry and Commit inside PopulateMainList, and that is exactly
-- what tainted the recipient picker. A keybind is a table appended to a descriptor the client
-- reads later: no client code runs in our frame at all.
--
-- The strip already carries A (select), X (secondary, when the row has one), Y (clear) and B
-- (back), so the quaternary bind is the free one.
--
-- mainKeybindDescriptor does not exist until the mail window has been opened once, which is
-- why this is attempted from the two places that mean "the window is open now" rather than at
-- login. If the very first thing a session does is open mail straight onto the Send page --
-- replying to a letter does that -- the button arrives one tab change late.
-- ---------------------------------------------------------------------------------------

function gamepad:AddSaveKeybind()
	if self.saveKeybindAdded then
		return false
	end

	local send = MAIL_GAMEPAD and (MAIL_GAMEPAD.GetSend and MAIL_GAMEPAD:GetSend() or MAIL_GAMEPAD.send)
	if not send or not send.mainKeybindDescriptor then
		return false
	end
	self.saveKeybindAdded = true

	table.insert(send.mainKeybindDescriptor,
	{
		name = GetString(SI_PBSMX_SAVE_ENTRY),
		keybind = "UI_SHORTCUT_QUATERNARY",
		callback = function()
			ui:Save("")
		end,
	})

	return true
end

-- ---------------------------------------------------------------------------------------
-- Wiring
--
-- Everything is guarded and nothing is required: on a client where the gamepad mail screen is
-- not there to be added to, this file does nothing at all and the commands still work.
-- ---------------------------------------------------------------------------------------

function gamepad:Initialize()
	if not MAIL_GAMEPAD then
		return false
	end

	-- The mail window opening is where the tabs and the keybind go in: everything they attach
	-- to is built the first time it opens.
	if MAIL_GAMEPAD_SCENE and MAIL_GAMEPAD_SCENE.RegisterCallback then
		MAIL_GAMEPAD_SCENE:RegisterCallback("StateChange", function(_, newState)
			if newState == SCENE_SHOWING then
				local added = false
				for _, tab in ipairs(self:Tabs()) do
					added = tab:Add() or added
				end
				self:AddSaveKeybind()
				if added then
					self:RefreshTabBar()
				end
			elseif newState == SCENE_HIDDEN then
				ClearPreview()
			end
		end)
	end

	-- The Send page opening and closing is what the sent box's copy of the page follows. Its
	-- showing is also one of the two ways to leave one of our tabs, so the preview goes with it.
	if GAMEPAD_MAIL_SEND_FRAGMENT and GAMEPAD_MAIL_SEND_FRAGMENT.RegisterCallback then
		GAMEPAD_MAIL_SEND_FRAGMENT:RegisterCallback("StateChange", function(_, newState)
			if newState == SCENE_FRAGMENT_SHOWING then
				ClearPreview()
				self:AddSaveKeybind()
			elseif newState == SCENE_FRAGMENT_SHOWN then
				ui:PageOpened()
			elseif newState == SCENE_FRAGMENT_HIDDEN then
				ui:PageClosed()
			end
		end)
	end

	-- And the other way out of a tab of ours.
	if GAMEPAD_MAIL_INBOX_FRAGMENT and GAMEPAD_MAIL_INBOX_FRAGMENT.RegisterCallback then
		GAMEPAD_MAIL_INBOX_FRAGMENT:RegisterCallback("StateChange", function(_, newState)
			if newState == SCENE_FRAGMENT_SHOWING then
				ClearPreview()
			end
		end)
	end

	-- Nothing here brings the Send page up. A letter is written onto the page from the tab the
	-- player is standing on, and they walk over to it themselves -- see UI.lua and FINDINGS §9
	-- for the bug that rule was bought with.

	return true
end
