-- PB's MailerExtension -- the drafts box
--
-- A draft is what was on the page, plus when it was put away, plus a name if one was given.
-- It is written to the account-wide saved variables, so it survives a logout, a zone change
-- and a patch, and it is readable from any character -- which is the point, because the
-- addressee is an account name and the letter is not the character's.
--
-- Everything a box does is in Box.lua. What is here is the one thing only a draft does: being
-- put there on purpose, from whatever is on the page at that moment.
--
-- PBS_MAILER_EXTENSION is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_MAILER_EXTENSION then
	return
end

local addon = PBS_MAILER_EXTENSION
local compose = addon.compose

local drafts = addon.NewBox({
	key = "drafts",
	defaultMax = addon.DEFAULT_MAX_DRAFTS,
	rolling = false,
	nounId = SI_PBSMX_NOUN_DRAFT,
	titleId = SI_PBSMX_TAB_DRAFTS,
})

addon.drafts = drafts

function drafts:SaveFromCompose(name)
	local page, problem = compose:Read()
	if not page then
		return nil, problem
	end

	if self:IsBlank(page) then
		return nil, GetString(SI_PBSMX_ERROR_BLANK)
	end

	return self:Add(page, name)
end

-- ---------------------------------------------------------------------------------------
-- The letter being written now
--
-- The add-on already watches the Send page while it is open, ten times a second, because the
-- sent box has to have a copy of a letter before it goes (Sent.lua). The same copy is what
-- this saves, so an unfinished letter survives a crash, a disconnect, or walking away.
--
-- It is ONE draft, updated in place, and never sixty. It carries `auto = true`, which is what
-- tells it apart from the drafts somebody chose to keep: those are never written over by this.
--
-- It goes away when the letter goes -- sent, it is not in progress any more -- and when the
-- page is cleared, because clearing the page is somebody saying they are done with it.
-- ---------------------------------------------------------------------------------------

local function CopyPage(page)
	local copy = {}
	for key, value in pairs(page) do
		copy[key] = value
	end

	-- The attachment list is walked and rewritten by the sent box on its way into the record,
	-- so this must not be the same table.
	copy.attachments = {}
	for index, item in ipairs(page.attachments or {}) do
		local entry = {}
		for key, value in pairs(item) do
			entry[key] = value
		end
		copy.attachments[index] = entry
	end

	return copy
end

local function Seconds()
	if GetFrameTimeMilliseconds then
		return GetFrameTimeMilliseconds() / 1000
	end
	return 0
end

function drafts:AutoDraft()
	for _, entry in ipairs(self:All()) do
		if entry.auto then
			return entry
		end
	end
	return nil
end

function drafts:ForgetAutoDraft()
	local entry = self:AutoDraft()
	if not entry then
		return false
	end
	self:Delete(self:IndexOf(entry))
	self.lastAutoSave = nil
	if addon.ui then
		addon.ui:CountChanged()
	end
	return true
end

function drafts:AutoSave(page)
	local seconds = addon:AutoSaveSeconds()
	if seconds <= 0 or self:IsBlank(page) then
		return nil
	end

	local now = Seconds()
	if self.lastAutoSave and (now - self.lastAutoSave) < seconds then
		return nil
	end
	self.lastAutoSave = now

	local entry = self:AutoDraft()
	if entry then
		return self:Update(entry, CopyPage(page))
	end

	-- A full box refuses, and refuses quietly: nobody wants to be told once a minute that a
	-- save they did not ask for did not happen.
	local added = self:Add(CopyPage(page), GetString(SI_PBSMX_AUTOSAVE_NAME))
	if added then
		added.auto = true
		if addon.ui then
			addon.ui:CountChanged()
		end
	end
	return added
end
