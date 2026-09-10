-- PB's MailerExtension -- what both interfaces need
--
-- The keyboard and the gamepad mail screens are two different programs that happen to send the
-- same letters, so there are two files that draw a drafts box. This is the part that would
-- otherwise be written twice in both of them:
--
--   * saving what is on the page, with the answer said out loud where it can be seen
--   * loading a draft that may need the Send page opened first, and applying it once it is
--   * asking "are you sure" before a draft is thrown away
--
-- On a console the chat window is often not on screen, so every outcome goes through ZO_Alert
-- as well: the alert is the answer, and the chat line is the detail behind it.
--
-- PBS_MAILER_EXTENSION is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_MAILER_EXTENSION then
	return
end

local addon = PBS_MAILER_EXTENSION
local compose = addon.compose

local Print = addon.Print
local Line = addon.Line
local Format = addon.Format

local ui = {}
addon.ui = ui

local DELETE_DIALOG = "PBS_MAILER_EXTENSION_CONFIRM_DELETE_DRAFT"

-- ---------------------------------------------------------------------------------------
-- Saying what happened
--
-- Two channels on purpose. The alert is short, appears over the game, and is the only thing
-- somebody playing on a controller with the chat window closed will ever see. The chat lines
-- carry the detail -- which item could not be re-attached, and why -- and are there to be
-- gone back to.
-- ---------------------------------------------------------------------------------------

local function Alert(text)
	if ZO_Alert then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS and SOUNDS.NONE or nil, text)
	end
end

local function AlertError(text)
	if ZO_Alert then
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS and SOUNDS.NEGATIVE_CLICK or nil, text)
	end
end

ui.Alert = Alert
ui.AlertError = AlertError

-- ---------------------------------------------------------------------------------------
-- Saving
-- ---------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------
-- The counts moved
--
-- A tab's name carries how many letters its box holds, and nothing re-evaluates that on its
-- own. Everything that adds or removes one says so here; an interface that draws a count
-- registers to hear about it.
-- ---------------------------------------------------------------------------------------

function ui:OnCountChanged(handler)
	self.countChangedHandler = handler
end

function ui:CountChanged()
	if self.countChangedHandler then
		pcall(self.countChangedHandler)
	end
end

function ui:Save(name)
	local drafts = addon.drafts
	local draft, problem = drafts:SaveFromCompose(name)
	if not draft then
		AlertError(problem)
		Print(problem)
		return nil
	end

	local index = drafts:IndexOf(draft)
	self:CountChanged()
	local said = Format(SI_PBSMX_SAVED, index, drafts:Describe(draft))
	Alert(Format(SI_PBSMX_ALERT_SAVED, index))
	Print(said)
	return draft
end

-- ---------------------------------------------------------------------------------------
-- Keeping the mail you are looking at
--
-- The copy is of what the letter said, and the message says so plainly when the letter had
-- something attached: a record is not a bag, and somebody who thinks the parcel is safe now
-- will find out the hard way when the mail expires.
-- ---------------------------------------------------------------------------------------

function ui:Keep()
	local kept = addon.kept
	local entry, problem = kept:SaveFromInbox()
	if not entry then
		AlertError(problem)
		Print(problem)
		return nil
	end

	local index = kept:IndexOf(entry)
	self:CountChanged()
	Alert(Format(SI_PBSMX_ALERT_KEPT, index))
	Print(Format(SI_PBSMX_KEPT, index, kept:Describe(entry)))

	if #(entry.attachments or {}) > 0 or (entry.gold or 0) > 0 then
		Print(GetString(SI_PBSMX_KEPT_ATTACHMENTS_WARNING))
	end

	return entry
end

-- ---------------------------------------------------------------------------------------
-- Reading one whole
--
-- The tooltip beside the list is a preview and cuts the body off; this is the whole of it.
-- Chat is the only surface with somewhere to put a long letter, so that is where it goes.
-- ---------------------------------------------------------------------------------------

function ui:Read(box, index)
	local entry = box:At(index)
	if not entry then
		return false
	end

	Print(box:Describe(entry))
	for line in (box:Preview(entry) .. "\n"):gmatch("(.-)\n") do
		Line("  " .. line)
	end

	Alert(GetString(SI_PBSMX_ALERT_READ))
	return true
end

-- ---------------------------------------------------------------------------------------
-- Loading
--
-- A draft can only be written onto a page that is open, and the drafts box is a different tab
-- from the page. So loading from the box is two steps: remember which draft, ask the interface
-- to go to the Send page, and apply it when that page reports itself open.
--
-- Each interface registers how to do its own half. This is the same shape the client uses for
-- "reply to this mail" -- ZO_MailSend_Gamepad:ComposeMailTo stores initialContact and applies
-- it in OnShowing -- for the same reason.
-- ---------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------
-- Loading
--
-- The letter is written onto the compose page where the player is standing -- which is the
-- drafts or sent tab, not the Send page -- and then they are told to walk over to it.
--
-- The add-on used to make that tab change itself, and that was a bug of the same family as
-- FINDINGS §7: switching to the Send tab runs the client's ZO_MailSend_Gamepad:OnShowing, which
-- calls PopulateMainList, which creates the closure that actually sends the mail. Called from
-- our frame, that closure was born untrusted, and pressing Send then failed on a private
-- function. One button press by the player is the price of the client building its own screen
-- from its own frame.
-- ---------------------------------------------------------------------------------------

function ui:Report(ok, notes)
	if not ok then
		AlertError(notes)
		Print(notes)
		return false
	end

	Print(Format(SI_PBSMX_LOADED, self.lastBox and self.lastBox:Noun() or "", self.lastIndex or ""))
	for _, note in ipairs(notes) do
		Line("  " .. note)
	end

	if #notes > 0 then
		AlertError(Format(SI_PBSMX_ALERT_LOADED_WITH_NOTES, #notes))
	else
		Alert(GetString(SI_PBSMX_ALERT_LOADED))
	end
	return true
end

function ui:Apply(box, index)
	self.lastBox = box
	self.lastIndex = index

	local entry = box:At(index)
	local ok, notes = box:LoadToCompose(index)

	-- Which draft the page is now holding, by its stable id rather than its place in the list.
	-- This is what lets the draft go when the letter is sent, and it is only ever a draft: a
	-- sent letter or a kept one is a record, and sending a copy of it does not use it up.
	if ok and entry and box == addon.drafts then
		self.pageSource = entry.id
	end

	return self:Report(ok, notes)
end

-- ---------------------------------------------------------------------------------------
-- What the page is holding
-- ---------------------------------------------------------------------------------------

-- Called when the letter on the page has gone.
function ui:LetterSent()
	local id = self.pageSource
	self.pageSource = nil

	if not id or not addon:DeleteDraftOnSend() then
		return false
	end

	local removed = addon.drafts:DeleteById(id)
	if removed then
		Print(Format(SI_PBSMX_DRAFT_SENT, addon.drafts:Describe(removed)))
		return true
	end
	return false
end

-- Called when the page has been cleared. Whatever it was holding, it is not holding it now.
function ui:PageCleared()
	self.pageSource = nil
	if addon.drafts then
		addon.drafts:ForgetAutoDraft()
	end
end

function ui:RequestLoad(box, index)
	if not box:At(index) then
		AlertError(Format(SI_PBSMX_ERROR_NO_SUCH, box:Noun(), tostring(index)))
		return false
	end

	local wasOpen = compose:IsOpen()
	if not self:Apply(box, index) then
		return false
	end

	-- Said second, and said loudly, because it is the one thing left to do.
	if not wasOpen then
		Alert(GetString(SI_PBSMX_ALERT_GO_TO_SEND))
		Print(GetString(SI_PBSMX_GO_TO_SEND))
	end

	return true
end

-- ---------------------------------------------------------------------------------------
-- The page opening and closing
--
-- Both interfaces tell us; what happens as a result is decided here, once. The sent box needs
-- to know because it keeps a copy of the page while it is open -- see Sent.lua for why it
-- cannot simply read the page when the letter goes.
-- ---------------------------------------------------------------------------------------

function ui:PageOpened()
	if addon.sent then
		addon.sent:StartWatching()
	end
end

function ui:PageClosed()
	if addon.sent then
		addon.sent:StopWatching()
	end
end

-- ---------------------------------------------------------------------------------------
-- Deleting
--
-- Registered for both platforms in one dialog: ZO_Dialogs_ShowPlatformDialog picks the
-- keyboard or the gamepad presentation, the same way the client's own "clear this mail"
-- confirmation is written once and shown in both.
-- ---------------------------------------------------------------------------------------

local function RegisterDeleteDialog()
	if not ESO_Dialogs or ESO_Dialogs[DELETE_DIALOG] then
		return
	end

	ESO_Dialogs[DELETE_DIALOG] =
	{
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.BASIC or nil,
		},
		title =
		{
			text = SI_PBSMX_DELETE_TITLE,
		},
		mainText =
		{
			text = SI_PBSMX_DELETE_PROMPT,
		},
		buttons =
		{
			[1] =
			{
				text = SI_DIALOG_ACCEPT,
				callback = function(dialog)
					dialog.data.callback()
				end,
			},
			[2] =
			{
				text = SI_DIALOG_CANCEL,
			},
		},
	}
end

function ui:ConfirmDelete(box, index, onDone)
	local entry = box:At(index)
	if not entry then
		return
	end

	local function DoDelete()
		local removed = box:Delete(index)
		self:CountChanged()
		Print(Format(SI_PBSMX_DELETED, box:Noun(), index, box:Describe(removed)))
		Alert(Format(SI_PBSMX_ALERT_DELETED, box:Noun()))
		if onDone then
			onDone()
		end
	end

	RegisterDeleteDialog()

	if ESO_Dialogs and ESO_Dialogs[DELETE_DIALOG] and ZO_Dialogs_ShowPlatformDialog then
		-- The title takes the box's word for one of its letters, so the same dialog asks
		-- "delete this draft?" and "delete this kept mail?" without being two dialogs.
		ZO_Dialogs_ShowPlatformDialog(DELETE_DIALOG, { callback = DoDelete },
			{
				titleParams = { box:Noun() },
				mainTextParams = { box:Describe(entry, true) },
			})
		return
	end

	-- No dialog system to ask with: better to do nothing than to throw a draft away silently.
	AlertError(GetString(SI_PBSMX_ERROR_NO_DIALOG))
end
