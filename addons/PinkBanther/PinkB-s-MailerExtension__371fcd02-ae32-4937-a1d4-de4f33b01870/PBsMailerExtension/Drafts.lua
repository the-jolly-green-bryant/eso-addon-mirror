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
