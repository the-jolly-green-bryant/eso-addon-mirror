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
-- The line along the bottom
--
-- How much room is left for saved data, on the same row as the button prompts at the bottom of
-- the screen and to the right of them. Its fragment goes on the scene rather than on a tab, so
-- it is there on the inbox and the send page too, and it goes away with the mail window.
--
-- The figures are what is on disk and only move when the game writes saved variables out, so
-- there is nothing to poll: it is filled in when the mail window opens.
-- ---------------------------------------------------------------------------------------

local storage = nil
local storageFailed = false

local function BuildStorageLine()
	if storage or storageFailed then
		return storage
	end

	local built = {}
	local ok = pcall(function()
		local line = CreateControlFromVirtual("PBsMailerExtensionStorage", ZO_Mail_Gamepad_TopLevel, "PBsMailerExtension_Storage_Gamepad")
		line:ClearAnchors()

		-- On the button prompts' own row, ending at the right edge. ZO_KeybindStripControl is
		-- the full-width control at the bottom of the screen that the prompts sit in, so its
		-- right edge is theirs, and anchoring to it puts this beside them at whatever height
		-- the strip happens to be.
		--
		-- The right inset is the one the mail window gives its own right-hand pane.
		if ZO_KeybindStripControl then
			line:SetAnchor(RIGHT, ZO_KeybindStripControl, RIGHT, -30, 0)
			-- The strip draws its background over the screen it is on, so this has to be
			-- drawn above it or it would be behind that background.
			if line.SetDrawTier and DT_HIGH then
				line:SetDrawTier(DT_HIGH)
			end
		else
			-- No strip to sit beside: the empty strip along the bottom of the right-hand pane,
			-- which is where this used to live.
			line:SetAnchor(BOTTOMRIGHT, ZO_Mail_Gamepad_TopLevel, BOTTOMRIGHT, -30, -70)
		end

		built.text = line:GetNamedChild("Text")
		assert(built.text)

		-- White, and set here rather than left to the template. ZO_Mail_Gamepad_Label is the
		-- mail window's heading face, and its colour is INTERFACE_TEXT_COLOR_DISABLED -- a grey
		-- meant for a heading sitting on the window's own dark panel. On the button prompts'
		-- row it sits on the strip's background instead, and disappears into it.
		built.text:SetColor(1, 1, 1, 1)

		built.fragment = ZO_FadeSceneFragment:New(line)
	end)

	if not ok or not built.fragment then
		storageFailed = true
		return nil
	end

	storage = built
	return storage
end

function gamepad:RefreshStorage()
	local built = BuildStorageLine()
	if not built then
		return false
	end

	local text, low = addon:StorageLine()
	if not text then
		built.text:SetText("")
		return false
	end

	built.text:SetText(low and ("|cC74A4A" .. text .. "|r") or text)
	return true
end

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

-- ---------------------------------------------------------------------------------------
-- The pane beside the list
--
-- Declared in Gamepad.xml as a copy of the inbox's own mail view -- the same virtual templates,
-- the same anchors, the same gaps -- and only put on the screen here.
--
-- Three versions were spent building it out of those templates in Lua instead, and both of the
-- things that went wrong are things XML does not have:
--
--   * a control takes two anchors and SetAnchor ADDS one, so a template already carrying an
--     anchor of its own has room for one more, not two. XML anchors replace.
--   * a row's height is settled by the time an XML layout is resolved. The same pieces built in
--     Lua measured zero, and every field landed on top of the heading above it -- the address
--     inside its own label, "subject" printed over "message".
--
-- What is still done here is what the client also does in Lua: the attachment slots, created
-- one at a time and anchored to the base control the XML leaves for them.
-- ---------------------------------------------------------------------------------------

local VIEW_NAME = "PBsMailerExtensionMailView"

local view = nil
local viewFailed = false

local function ClientString(preferredId, ownId)
	if preferredId and GetString(preferredId) ~= "" then
		return GetString(preferredId)
	end
	return GetString(ownId)
end

local function BuildView()
	if view or viewFailed then
		return view
	end

	local built = {}
	local ok = pcall(function()
		local pane = CreateControlFromVirtual(VIEW_NAME, ZO_Mail_Gamepad_TopLevel, "ZO_GamepadGrid_NavQuadrant_2_3_4_Anchors")
		local container = CreateControlFromVirtual("$(parent)Container", pane, "ZO_GamepadGrid_NavQuadrant_ContainerAnchors")

		-- The inset the inbox gives its own view inside the container.
		local mailView = CreateControlFromVirtual("$(parent)View", container, "PBsMailerExtension_MailView_Gamepad")
		mailView:ClearAnchors()
		mailView:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 68)
		mailView:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, 0, -120)

		local attachmentsBox = mailView:GetNamedChild("AttachmentsBox")

		built.pane = pane
		built.addressLabel = mailView:GetNamedChild("AddressLabel")
		built.address = mailView:GetNamedChild("AddressField")
		built.subject = mailView:GetNamedChild("SubjectField")
		built.body = mailView:GetNamedChild("Body")
		built.moneyLabel = attachmentsBox:GetNamedChild("MoneyLabel")
		built.money = attachmentsBox:GetNamedChild("Money")
		built.noMoney = attachmentsBox:GetNamedChild("NoMoney")
		built.noAttachments = attachmentsBox:GetNamedChild("NoAttachments")

		-- Every piece has to be there, and .edit is what the client's templates hang the label
		-- on. A pane missing any of it is not a pane worth showing, and the tooltip is better.
		assert(built.addressLabel and built.address and built.address.edit)
		assert(built.subject and built.subject.edit)
		assert(built.body and built.body.edit)
		assert(built.money and built.noMoney and built.noAttachments)

		-- The same slot control the mail window uses, at the same size and spacing. Not bound
		-- as inventory slots, though: these are a picture of what is attached, and on a kept
		-- letter a picture of what WAS. Nothing here should look reachable.
		local SLOT_PADDING = 8
		local base = attachmentsBox:GetNamedChild("AttachmentsBase")
		local slots = {}
		local previous = base
		for index = 1, (MAIL_MAX_ATTACHED_ITEMS or 6) do
			local slot = CreateControlFromVirtual("$(parent)Slot", attachmentsBox, "ZO_MailAttachmentSlot_Gamepad", index)
			slot:ClearAnchors()
			slot:SetAnchor(TOPLEFT, previous, TOPRIGHT, SLOT_PADDING, 0)
			slot:SetAnchor(BOTTOMLEFT, previous, BOTTOMRIGHT, SLOT_PADDING, 0)
			slot.icon = slot:GetNamedChild("Icon")
			slot:SetHidden(true)
			slots[index] = slot
			previous = slot
		end
		built.slots = slots

		built.fragment = ZO_FadeSceneFragment:New(pane)
	end)

	if not ok or not built.fragment then
		viewFailed = true
		return nil
	end

	view = built
	return view
end


-- The tooltip the mail screen actually carries, kept as the fallback for a client where the
-- pane above could not be built. GAMEPAD_LEFT_TOOLTIP and not RIGHT: the inbox draws attached
-- items in the left one (mailinbox_gamepad.lua:158) and the send page draws bag items in it
-- (mailsend_gamepad.lua:843). 1.3.0 used the right one, which this scene does not carry, and
-- so drew nothing at all.
local function PreviewTooltip()
	return GAMEPAD_LEFT_TOOLTIP
end

local function ClearTooltipPreview()
	if not GAMEPAD_TOOLTIPS or PreviewTooltip() == nil then
		return
	end
	pcall(function()
		GAMEPAD_TOOLTIPS:HideBg(PreviewTooltip())
		GAMEPAD_TOOLTIPS:ClearLines(PreviewTooltip())
		GAMEPAD_TOOLTIPS:Reset(PreviewTooltip())
	end)
end

local function ClearPreview()
	ClearTooltipPreview()
	if view then
		pcall(function()
			view.address.edit:SetText("")
			view.subject.edit:SetText("")
			view.body.edit:SetText("")
			view.moneyLabel:SetText("")
			view.money:SetHidden(true)
			view.noMoney:SetHidden(true)
			view.noAttachments:SetHidden(true)
			for _, slot in ipairs(view.slots) do
				slot:SetHidden(true)
			end
		end)
	end
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

-- What the pane says about a letter. The heading over the first box is the one difference
-- between the boxes: a letter you are going to send has an addressee, and one that arrived has
-- a sender.
local BODY_VIEW_CHARACTERS = 3000

function Tab:FillView(entry)
	local address, heading
	if entry.received then
		address = entry.from
		heading = ClientString(SI_GAMEPAD_MAIL_INBOX_FROM, SI_PBSMX_VIEW_FROM)
	else
		address = entry.to
		heading = ClientString(SI_GAMEPAD_MAIL_SEND_TO, SI_PBSMX_VIEW_TO)
	end

	view.addressLabel:SetText(heading)
	view.address.edit:SetText((address and address ~= "") and address or GetString(SI_PBSMX_NO_ADDRESSEE))
	view.subject.edit:SetText((entry.subject and entry.subject ~= "") and entry.subject or GetString(SI_PBSMX_NO_SUBJECT))

	local body = entry.body or ""
	if body == "" then
		body = GetString(SI_PBSMX_PREVIEW_NO_BODY)
	elseif #body > BODY_VIEW_CHARACTERS then
		body = body:sub(1, BODY_VIEW_CHARACTERS) .. "..."
	end
	view.body.edit:SetText(body)

	self:FillExtras(entry)
end

-- The money and the attachments, drawn the way the mail window draws them: gold if there is
-- any, otherwise a C.O.D. if there is one, otherwise the words the client uses for neither.
function Tab:FillExtras(entry)
	local gold = entry.gold or 0
	local cod = entry.cod or 0

	if gold > 0 or cod == 0 then
		view.moneyLabel:SetText(ClientString(SI_MAIL_READ_SENT_GOLD_LABEL, SI_PBSMX_VIEW_GOLD))
	else
		view.moneyLabel:SetText(ClientString(SI_MAIL_READ_COD_LABEL, SI_PBSMX_VIEW_COD))
	end

	local amount = gold > 0 and gold or cod
	if amount > 0 and ZO_CurrencyControl_SetSimpleCurrency then
		ZO_CurrencyControl_SetSimpleCurrency(view.money, CURT_MONEY, amount, ZO_MAIL_ATTACHED_MONEY_OPTIONS_GAMEPAD)
		view.money:SetHidden(false)
		view.noMoney:SetHidden(true)
	else
		view.noMoney:SetText(ClientString(SI_GAMEPAD_MAIL_INBOX_NO_ATTACHED_GOLD, SI_PBSMX_VIEW_NO_GOLD))
		view.money:SetHidden(true)
		view.noMoney:SetHidden(false)
	end

	local attachments = entry.attachments or {}
	view.noAttachments:SetHidden(#attachments > 0)

	for index, slot in ipairs(view.slots) do
		local item = attachments[index]
		if item then
			local icon = (item.link and item.link ~= "" and GetItemLinkIcon and GetItemLinkIcon(item.link)) or nil
			ZO_Inventory_SetupSlot(slot, item.stack or 1, icon)
			-- A letter that arrived is a record: what it carried is not in these slots and not
			-- anywhere else either, so it is drawn faded rather than as something to reach for.
			if slot.icon and slot.icon.SetAlpha then
				slot.icon:SetAlpha(entry.received and 0.4 or 1)
			end
			slot:SetHidden(false)
		else
			slot:SetHidden(true)
		end
	end
end

function Tab:ShowPreview()
	local _, entry = self:Selected()

	if BuildView() then
		if not entry then
			ClearPreview()
			return
		end
		local ok = pcall(function() self:FillView(entry) end)
		if ok then
			return
		end
	end

	-- Fallback: the tooltip.
	if not GAMEPAD_TOOLTIPS or PreviewTooltip() == nil then
		return
	end

	if not entry then
		ClearTooltipPreview()
		return
	end

	pcall(function()
		local tooltip = PreviewTooltip()
		if GAMEPAD_TOOLTIP_DARK_BG then
			GAMEPAD_TOOLTIPS:SetBgType(tooltip, GAMEPAD_TOOLTIP_DARK_BG)
		end
		GAMEPAD_TOOLTIPS:ShowBg(tooltip)
		GAMEPAD_TOOLTIPS:LayoutTitleAndDescriptionTooltip(tooltip,
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
			name = self.box:LoadLabel(),
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
			name = GetString(SI_PBSMX_KEYBIND_READ),
			keybind = "UI_SHORTCUT_SECONDARY",
			callback = function()
				local index, entry = self:Selected()
				if entry then
					ui:Read(self.box, index)
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

	-- Our own right-hand pane takes the place of the inbox's or the send page's. If it could
	-- not be built, nothing is put there and the preview falls back to the tooltip.
	local built = BuildView()
	MAIL_GAMEPAD:SwitchToFragment(built and built.fragment or nil)
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

gamepad.kept = NewTab({
	box = addon.kept,
	listName = "PBsMailerExtensionKept",
	titleId = SI_PBSMX_TAB_KEPT,
	emptyId = SI_PBSMX_KEPT_EMPTY,
})

function gamepad:Tabs()
	return { self.drafts, self.sent, self.kept }
end

-- The count in a tab's name comes from a function, but nothing re-evaluates it on its own: the
-- tab bar is built once when the header is drawn. So anything that changes how many letters a
-- box holds says so here, and the bar is drawn again with the new number.
function gamepad:CountChanged()
	if MAIL_GAMEPAD and MAIL_GAMEPAD.header then
		self:RefreshTabBar()
	end
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

-- The inbox's own strip carries A (take), X (delete), Y (options), the quinary and the right
-- stick, so the quaternary is the free one there. Appended the same way as the Send page's --
-- a table entry the client reads later, and nothing of the client's runs in our frame.
function gamepad:AddKeepKeybind()
	if self.keepKeybindAdded then
		return false
	end

	local inbox = MAIL_GAMEPAD and (MAIL_GAMEPAD.GetInbox and MAIL_GAMEPAD:GetInbox() or MAIL_GAMEPAD.inbox)
	if not inbox or not inbox.mainKeybindDescriptor then
		return false
	end
	self.keepKeybindAdded = true

	table.insert(inbox.mainKeybindDescriptor,
	{
		name = GetString(SI_PBSMX_KEEP_ENTRY),
		keybind = "UI_SHORTCUT_QUATERNARY",
		callback = function()
			ui:Keep()
			self.kept:Refresh()
		end,
		enabled = function()
			return addon.kept:ActiveMailId() ~= nil
		end,
	})

	return true
end

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
				-- The disk figures are read here rather than watched: they only move when the
				-- game writes saved variables out.
				local line = BuildStorageLine()
				if line and MAIL_GAMEPAD_SCENE.AddFragment then
					MAIL_GAMEPAD_SCENE:AddFragment(line.fragment)
				end
				self:RefreshStorage()

				local added = false
				for _, tab in ipairs(self:Tabs()) do
					added = tab:Add() or added
				end
				self:AddSaveKeybind()
				self:AddKeepKeybind()
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
				self:AddKeepKeybind()
			end
		end)
	end

	-- Whenever a box gains or loses a letter, the tab bar is drawn again so the number in a
	-- tab's name is the number in its box.
	ui:OnCountChanged(function()
		self:CountChanged()
	end)

	-- Nothing here brings the Send page up. A letter is written onto the page from the tab the
	-- player is standing on, and they walk over to it themselves -- see UI.lua and FINDINGS §9
	-- for the bug that rule was bought with.

	return true
end
