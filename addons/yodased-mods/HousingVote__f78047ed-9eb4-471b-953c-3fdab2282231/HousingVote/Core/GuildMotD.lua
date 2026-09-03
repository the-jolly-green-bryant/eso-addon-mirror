local HV = HousingVote

-- The guild MOTD is real guild data replicated by the game to every member
-- (addon or not) -- it's the one "broadcast to the whole guild" channel
-- that doesn't touch chat-send (blocked for addons) or mail-blast (spam-ban
-- risk at guild scale). We use it purely as a discovery pointer; the actual
-- rules/roster payload still travels by mail, only to people who ask.
--
-- Each entry: "[HV1|contestId|state|hostDisplayName|title] -- human sentence"
-- Multiple contests' entries coexist back-to-back; anything else already in
-- the guild's MOTD (their own welcome text, etc.) is left untouched.
--
-- CONFIRMED BUG (fixed): PublishContestPointer used to strip out ANY
-- HousingVote pointer before writing, not just its own contest's -- so a
-- second contest's publish silently wiped the first one's pointer, even
-- though they were unrelated. Fixed by scoping removal to that one
-- contest's own id, and by having ScanGuilds walk every pointer in the
-- MOTD (gmatch) instead of only ever finding the first one.
--
-- CONFIRMED BUG (fixed): the bracket tag was the ENTIRE visible entry --
-- e.g. "[yodased-1234567890VOTINGyodasedTest]" with no explanation at all
-- for guild members who don't have the addon. Fixed by appending a plain-
-- English sentence after the tag ("<host> is hosting 'Title' -- get the
-- Housing Vote addon to join!" etc., worded per state). The tag stays
-- machine-parseable and first (so a precise, anchored removal is possible
-- when republishing); the sentence is what a human actually reads. The
-- removal pattern below was extended to also consume that trailing
-- sentence (stopping at the next "[" or end of string) so republishing a
-- contest (e.g. on a state change) can't leave an orphaned old sentence
-- behind once its tag is gone.

local POINTER_PATTERN = "%[HV1%|([^|]*)%|([^|]*)%|([^|]*)%|([^%]]*)%]"

local STATE_HUMAN_TEXT = {
    INTEREST = "%s is hosting a housing contest, '%s' -- get the Housing Vote addon to join!",
    VOTING = "%s's housing contest '%s' is now voting -- get the Housing Vote addon to vote!",
    CLOSED = "%s's housing contest '%s' has ended.",
}

local lastSeenMotd = {} -- guildId -> last motd string we've already reacted to

local function EscapeForPattern(str)
    return (str:gsub("(%W)", "%%%1"))
end

-- Square brackets would break the tag's own delimiters or the "stop at the
-- next [" removal boundary, so both get replaced everywhere a title is
-- used in the MOTD (not just inside the tag).
local function SanitizeForMotd(title)
    return HV.Sanitize(title):gsub("%[", "("):gsub("%]", ")")
end

local function BuildPointer(contestId, state, hostDisplayName, title)
    local safeTitle = SanitizeForMotd(title)
    local tag = string.format("[HV1|%s|%s|%s|%s]", contestId, state, hostDisplayName, safeTitle)
    local template = STATE_HUMAN_TEXT[state] or "%s is running a housing contest, '%s'."
    local sentence = string.format(template, hostDisplayName, safeTitle)
    return tag .. " -- " .. sentence
end

-- Publishes/updates THIS contest's entry in a guild's MOTD, leaving any
-- other contest's entry (or the guild's own description text) alone.
-- Requires the caller to actually hold MOTD-edit permission in that guild
-- (typically Guild Master or an officer rank with it) -- SetGuildMotD will
-- simply fail silently or error for anyone else, so we surface that back.
function HV.PublishContestPointer(guildId, contestId, state, title)
    local existing = GetGuildMotD(guildId) or ""
    -- Matches our own tag plus everything up to the next "[" (the start of
    -- another entry) or the end of the string -- i.e. the whole old entry,
    -- tag and trailing sentence together, not just the tag.
    local ownEntryPattern = "%[HV1%|" .. EscapeForPattern(contestId) .. "%|[^|]*%|[^|]*%|[^%]]*%][^%[]*"
    local withoutOwnOldEntry = existing:gsub(ownEntryPattern, "")
    local entry = BuildPointer(contestId, state, GetDisplayName(), title)
    -- Appended, not prepended: a guild's own MOTD text should stay the
    -- first thing anyone sees, not get pushed behind our entry.
    local newMotd = (withoutOwnOldEntry .. " " .. entry):gsub("^%s+", ""):gsub("%s+$", "")

    local ok = pcall(SetGuildMotD, guildId, newMotd)
    if not ok then
        HV.Print("|cFF0000Couldn't update the guild MOTD -- you likely don't have MOTD/officer permission in that guild.|r")
        return false
    end
    lastSeenMotd[guildId] = newMotd
    return true
end

-- Scans every guild the player is in for HousingVote pointers that have
-- changed since we last looked, and reports each one via HV.OnMotdPointer.
local function ScanGuilds()
    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        local motd = GetGuildMotD(guildId) or ""
        if motd ~= lastSeenMotd[guildId] then
            lastSeenMotd[guildId] = motd
            for contestId, state, hostDisplayName, title in motd:gmatch(POINTER_PATTERN) do
                if HV.OnMotdPointer then
                    HV.OnMotdPointer(guildId, contestId, state, hostDisplayName, title)
                end
            end
        end
    end
end

function HV.InitGuildMotd()
    -- Guild data isn't necessarily loaded the instant the addon initializes,
    -- and there's no dedicated "MOTD changed" event, so we check on login
    -- and periodically thereafter (cheap: just a table of strings).
    zo_callLater(ScanGuilds, 3000)
    EVENT_MANAGER:RegisterForUpdate(HV.name .. "MotdPoll", 60000, ScanGuilds)
end
