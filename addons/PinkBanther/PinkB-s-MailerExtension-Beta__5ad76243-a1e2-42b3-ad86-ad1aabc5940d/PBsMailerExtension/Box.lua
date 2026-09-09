-- PB's MailerExtension -- a box of letters
--
-- The drafts box and the sent box are the same object with two different reasons to exist, so
-- they are the same code. What a box does is hold letters in the order they went in, hand one
-- back by number, say what one is in a line, and put one on the page.
--
-- Where they differ is only in how a letter gets in and what happens when the box is full:
--
--   drafts   put there on purpose, and full means refuse. Silently dropping the oldest draft
--            would throw away something somebody chose to keep.
--   sent     put there by the act of sending, and full means drop the oldest. A log that
--            stops recording once it is full has stopped being a log.
--
-- Nothing here touches a control or asks which interface is up. It asks Compose for the page
-- and hands Compose a page back; that is the whole of its relationship with the game, and it
-- is why all of it can be tested on a laptop instead of on a console.
--
-- PBS_MAILER_EXTENSION is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_MAILER_EXTENSION then
	return
end

local addon = PBS_MAILER_EXTENSION
local compose = addon.compose

local Format = addon.Format

-- ---------------------------------------------------------------------------------------
-- When a letter was put in the box
--
-- Both a timestamp and a preformatted stamp are kept. The timestamp is the one to sort or age
-- by later; the string is what is shown, and it is made now rather than at display time
-- because GetDate/GetTimeString answer about NOW, and there is no client call that turns an
-- old timestamp back into a local date and time.
-- ---------------------------------------------------------------------------------------

local function Now()
	local stamp = GetTimeStamp and GetTimeStamp() or 0
	local date = GetDate and GetDate() or 0
	local time = GetTimeString and GetTimeString() or ""

	local label
	local year, month, day = tostring(date):match("^(%d%d%d%d)(%d%d)(%d%d)$")
	if year then
		label = string.format("%s-%s-%s", year, month, day)
	else
		label = tostring(date)
	end
	-- Seconds are noise on a letter; the hour and the minute are what tell two apart.
	label = label .. " " .. (time:match("^(%d+:%d+)") or time)

	return stamp, label
end

local function Gold(amount)
	if ZO_CommaDelimitNumber then
		return ZO_CommaDelimitNumber(amount)
	end
	return tostring(amount)
end

-- ---------------------------------------------------------------------------------------
-- The box
-- ---------------------------------------------------------------------------------------

local Box = {}
Box.__index = Box

-- config.key      which field of the saved variables this box lives in
-- config.defaultMax  how many letters it holds until somebody says otherwise
-- config.rolling  true drops the oldest to make room; false refuses
-- config.nounId   what to call ONE of its letters in a sentence -- "deleted draft 3".
-- config.titleId   what to call the BOX -- "Drafts -- 3 of 50". Two words and not one because
--                  a count needs the box's name and a number needs the letter's, and forcing
--                  either into the other's sentence reads like a machine wrote it. Every
--                  message the two boxes share is written with a hole for one of them.
function addon.NewBox(config)
	return setmetatable({
		key = config.key,
		defaultMax = config.defaultMax,
		rolling = config.rolling and true or false,
		nounId = config.nounId,
		titleId = config.titleId,
	}, Box)
end

function Box:Noun()
	return GetString(self.nounId)
end

function Box:Title()
	return GetString(self.titleId)
end

-- ---------------------------------------------------------------------------------------
-- How many it holds
--
-- Read from the saved variables every time rather than held in a field, so a limit changed in
-- the panel is in force at the next save with nothing to keep in step.
-- ---------------------------------------------------------------------------------------

function Box:Max()
	local sv = addon.sv
	local limit = sv and sv.limits and sv.limits[self.key]
	if type(limit) ~= "number" then
		return self.defaultMax
	end
	return limit
end

-- Returns the limit that was applied, and how many letters are currently above it.
--
-- Lowering a limit never deletes anything here, and that is deliberate in both directions. On
-- the box that refuses, every letter in it is one somebody chose to keep and a slider is not an
-- instruction to throw any of them away. On the rolling box it is about the slider itself: a
-- panel that reports every step of a drag would trim at 90, then 80, then 70 on the way down to
-- 10, and a slider overshot by one notch would be letters gone for good. So the new limit takes
-- effect the next time the box takes a letter, which for the sent box is the next letter sent.
function Box:SetMax(value)
	value = math.floor(tonumber(value) or self.defaultMax)
	if value < addon.LIMIT_FLOOR then
		value = addon.LIMIT_FLOOR
	elseif value > addon.LIMIT_CEILING then
		value = addon.LIMIT_CEILING
	end

	local sv = addon.sv
	if sv then
		sv.limits = sv.limits or {}
		sv.limits[self.key] = value
	end

	local over = #self:All() - value
	return value, over > 0 and over or 0
end

-- The store is a plain array in the order letters went in, oldest first. Newest-first would
-- read better in a list, but it would renumber every letter each time one arrived, and these
-- numbers are what somebody types at a command. Only removing renumbers, and removing is the
-- moment you are looking at the list anyway.
function Box:Store()
	local sv = addon.sv
	if not sv then
		return nil
	end
	sv[self.key] = sv[self.key] or {}
	return sv[self.key]
end

function Box:All()
	return self:Store() or {}
end

function Box:At(index)
	local all = self:All()
	if type(index) ~= "number" or index < 1 or index > #all then
		return nil
	end
	return all[index]
end

function Box:IndexOf(entry)
	for index, candidate in ipairs(self:All()) do
		if candidate == entry then
			return index
		end
	end
	return nil
end

function Box:IsBlank(page)
	if (page.to or "") ~= "" or (page.subject or "") ~= "" or (page.body or "") ~= "" then
		return false
	end
	if #(page.attachments or {}) > 0 then
		return false
	end
	return (page.gold or 0) == 0 and (page.cod or 0) == 0
end

function Box:Add(page, name)
	local store = self:Store()
	if not store then
		return nil, GetString(SI_PBSMX_ERROR_NOT_LOADED)
	end

	local max = self:Max()
	if #store >= max then
		if not self.rolling then
			return nil, Format(SI_PBSMX_ERROR_FULL, self:Title(), #store, max)
		end
		while #store >= max do
			table.remove(store, 1)
		end
	end

	local sv = addon.sv
	local stamp, label = Now()

	page.id = sv.nextId or 1
	sv.nextId = page.id + 1
	page.name = name and name ~= "" and name or ""
	page.stamp = stamp
	page.savedAt = label

	store[#store + 1] = page
	return page, nil
end

function Box:Delete(index)
	local entry = self:At(index)
	if not entry then
		return nil
	end
	table.remove(self:Store(), index)
	return entry
end

function Box:DeleteAll()
	local store = self:Store()
	local removed = #store
	for index = removed, 1, -1 do
		table.remove(store, index)
	end
	return removed
end

-- ---------------------------------------------------------------------------------------
-- Putting one back on the page
--
-- Taking a letter out of a box never empties the box. A draft is a thing you go back to,
-- possibly more than once; a sent letter is a thing you may want to send again to somebody
-- else. Neither is consumed by being looked at. They go when you say so.
-- ---------------------------------------------------------------------------------------

function Box:LoadToCompose(index)
	local entry = self:At(index)
	if not entry then
		return false, Format(SI_PBSMX_ERROR_NO_SUCH, self:Noun(), tostring(index))
	end

	-- Writing does not need the Send page to be the tab in front of you, only for the mail
	-- window to have been opened once this session so the controls exist. See Compose:Surface.
	if not compose:CanWrite() then
		return false, GetString(SI_PBSMX_ERROR_NOT_OPEN)
	end

	return compose:Write(entry)
end

-- ---------------------------------------------------------------------------------------
-- Saying what a letter is
--
-- One line, and it has to answer "is this the one?" without being opened: what it is about,
-- who it is to, what is riding on it, and when. The name is preferred over the subject because
-- somebody who bothered to name a draft named it for this line.
--
-- omitDate is for the places already short of room -- a gamepad list row, a dialog title. The
-- date is the first thing worth dropping: two letters are told apart by their subject and
-- their addressee long before they are told apart by their minute.
-- ---------------------------------------------------------------------------------------

function Box:Describe(entry, omitDate)
	if not entry then
		return ""
	end

	local title = entry.name
	if not title or title == "" then
		title = entry.subject
	end
	if not title or title == "" then
		title = GetString(SI_PBSMX_NO_SUBJECT)
	end

	local to = (entry.to and entry.to ~= "") and entry.to or GetString(SI_PBSMX_NO_ADDRESSEE)

	local parts = {}
	local attachments = #(entry.attachments or {})
	if attachments > 0 then
		parts[#parts + 1] = Format(SI_PBSMX_DESCRIBE_ITEMS, attachments)
	end
	if (entry.gold or 0) > 0 then
		parts[#parts + 1] = Format(SI_PBSMX_DESCRIBE_GOLD, Gold(entry.gold))
	end
	if (entry.cod or 0) > 0 then
		parts[#parts + 1] = Format(SI_PBSMX_DESCRIBE_COD, Gold(entry.cod))
	end
	if not omitDate and entry.savedAt and entry.savedAt ~= "" then
		parts[#parts + 1] = entry.savedAt
	end

	local line = Format(SI_PBSMX_DESCRIBE, title, to)
	if #parts > 0 then
		line = line .. "  [" .. table.concat(parts, ", ") .. "]"
	end
	return line
end

-- ---------------------------------------------------------------------------------------
-- The whole of a letter, for a tooltip
--
-- Several lines rather than one: this is what is shown beside the list while a letter is
-- picked out, and it is the only place the body can be read without loading it onto the page.
-- The body is cut off rather than shown whole -- a tooltip that runs off the screen has
-- stopped being a preview.
-- ---------------------------------------------------------------------------------------

local BODY_PREVIEW_CHARACTERS = 300

function Box:Preview(entry)
	if not entry then
		return ""
	end

	local lines = {}

	lines[#lines + 1] = Format(SI_PBSMX_PREVIEW_TO, (entry.to and entry.to ~= "") and entry.to or GetString(SI_PBSMX_NO_ADDRESSEE))
	lines[#lines + 1] = Format(SI_PBSMX_PREVIEW_SUBJECT, (entry.subject and entry.subject ~= "") and entry.subject or GetString(SI_PBSMX_NO_SUBJECT))

	local body = entry.body or ""
	if body == "" then
		body = GetString(SI_PBSMX_PREVIEW_NO_BODY)
	elseif #body > BODY_PREVIEW_CHARACTERS then
		body = body:sub(1, BODY_PREVIEW_CHARACTERS) .. "..."
	end
	lines[#lines + 1] = ""
	lines[#lines + 1] = body

	local attachments = entry.attachments or {}
	if #attachments > 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = Format(SI_PBSMX_PREVIEW_ATTACHMENTS, #attachments)
		for _, item in ipairs(attachments) do
			local name = (item.name and item.name ~= "") and item.name or GetString(SI_PBSMX_NOTE_UNNAMED_ITEM)
			lines[#lines + 1] = "  " .. name .. (item.stack and item.stack > 1 and (" x" .. item.stack) or "")
		end
	end

	if (entry.gold or 0) > 0 then
		lines[#lines + 1] = Format(SI_PBSMX_DESCRIBE_GOLD, Gold(entry.gold))
	end
	if (entry.cod or 0) > 0 then
		lines[#lines + 1] = Format(SI_PBSMX_DESCRIBE_COD, Gold(entry.cod))
	end

	if entry.savedAt and entry.savedAt ~= "" then
		lines[#lines + 1] = ""
		lines[#lines + 1] = entry.savedAt
	end

	return table.concat(lines, "\n")
end
