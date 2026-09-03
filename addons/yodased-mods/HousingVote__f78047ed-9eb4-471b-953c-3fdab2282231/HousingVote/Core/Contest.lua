local HV = HousingVote

local function NewContestId()
    return string.format("%s-%d", GetDisplayName():gsub("[|~^@]", ""), GetTimeStamp())
end

local function EncodeRoster(interests)
    -- interests: { [displayName] = { houseId=, houseName= } }
    -- Each entry is already sanitized at the leaf level below, so we join
    -- with LIST_SEP directly rather than via HV.EncodeList -- EncodeList
    -- re-sanitizes every element it's given, which would strip the SUB_SEP
    -- we just used to build the "displayName^houseName" pairs.
    local list = {}
    for displayName, info in pairs(interests) do
        table.insert(list, table.concat({ HV.Sanitize(displayName), HV.Sanitize(info.houseName) }, HV.SUB_SEP))
    end
    return table.concat(list, HV.LIST_SEP)
end

local function DecodeRoster(encoded)
    local roster = {}
    for _, entry in ipairs(HV.DecodeList(encoded)) do
        local displayName, houseName = entry:match("^(.-)%" .. HV.SUB_SEP .. "(.*)$")
        if displayName then
            table.insert(roster, { displayName = displayName, houseName = houseName })
        end
    end
    return roster
end

-- ============================================================
-- Host side
-- ============================================================

function HV.CreateContest(guildId, title, rules)
    local contestId = NewContestId()
    HV.sv.hostedContests[contestId] = {
        contestId = contestId,
        guildId = guildId,
        title = title,
        rules = rules,
        state = HV.CONTEST_STATE.INTEREST,
        hostDisplayName = GetDisplayName(),
        interests = {},
        votes = {},
    }
    HV.PublishContestPointer(guildId, contestId, HV.CONTEST_STATE.INTEREST, title)
    HV.Print(string.format("|c00FF00Contest '%s' created (id %s) and announced in the guild MOTD.|r", title, contestId))
    return contestId
end

local function SendInfoTo(contest, recipientDisplayName)
    local roster = EncodeRoster(contest.interests)
    HV.QueueOutbound(recipientDisplayName, HV.MSG.INFO, contest.contestId, {
        HV.Sanitize(contest.title),
        contest.state,
        HV.Sanitize(contest.rules),
        roster,
    })
end

function HV.HostOpenVoting(contestId)
    local contest = HV.sv.hostedContests[contestId]
    if not contest then return end
    contest.state = HV.CONTEST_STATE.VOTING
    HV.PublishContestPointer(contest.guildId, contestId, contest.state, contest.title)
    for displayName in pairs(contest.interests) do
        SendInfoTo(contest, displayName)
    end
    HV.Print(string.format("|c00FF00Voting opened for '%s' -- roster mailed to %d participant(s).|r", contest.title, HV.CountKeys(contest.interests)))
end

function HV.HostCloseContest(contestId)
    local contest = HV.sv.hostedContests[contestId]
    if not contest then return end
    contest.state = HV.CONTEST_STATE.CLOSED

    local tally = {}
    for _, choice in pairs(contest.votes) do
        tally[choice] = (tally[choice] or 0) + 1
    end
    local winner, winnerVotes = nil, -1
    for choice, count in pairs(tally) do
        if count > winnerVotes then
            winner, winnerVotes = choice, count
        end
    end
    contest.winner = winner

    local displayVotes = math.max(winnerVotes, 0)
    HV.PublishContestPointer(contest.guildId, contestId, contest.state, contest.title)
    for displayName in pairs(contest.interests) do
        HV.QueueOutbound(displayName, HV.MSG.RESULTS, contestId, {
            HV.Sanitize(contest.title),
            HV.Sanitize(winner or "No votes cast"),
            tostring(displayVotes),
        })
    end
    HV.Print(string.format("|c00FF00Contest '%s' closed. Winner: %s (%d vote(s)).|r", contest.title, winner or "n/a", displayVotes))
end

-- inbound handlers, called from OnProtocolMessage below
local function HostHandleRequest(contest, fromDisplayName)
    SendInfoTo(contest, fromDisplayName)
end

local function HostHandleInterest(contest, fromDisplayName, fields)
    if contest.state ~= HV.CONTEST_STATE.INTEREST then
        HV.Print(string.format("|cFF6600Ignored interest from %s -- '%s' is no longer taking interest submissions (state: %s).|r",
            fromDisplayName, contest.title, contest.state))
        return
    end
    local houseName = fields[1] or "Unknown House"
    contest.interests[fromDisplayName] = { houseName = houseName }
    HV.Print(string.format("|c00FF00%s registered interest for '%s' (%s).|r", fromDisplayName, contest.title, houseName))
end

local function HostHandleVote(contest, fromDisplayName, fields)
    if contest.state ~= HV.CONTEST_STATE.VOTING then
        HV.Print(string.format("|cFF6600Ignored vote from %s -- '%s' isn't open for voting (state: %s).|r",
            fromDisplayName, contest.title, contest.state))
        return
    end
    if not contest.interests[fromDisplayName] then
        HV.Print(string.format("|cFF6600Ignored vote from %s -- not a registered participant in '%s'.|r",
            fromDisplayName, contest.title))
        return
    end
    contest.votes[fromDisplayName] = fields[1]
    HV.Print(string.format("|c00FF00Vote recorded from %s.|r", fromDisplayName))
end

-- ============================================================
-- Voter side
-- ============================================================

function HV.JoinContest(contestId, hostDisplayName)
    HV.sv.joinedContests[contestId] = HV.sv.joinedContests[contestId] or {
        contestId = contestId,
        hostDisplayName = hostDisplayName,
    }
    HV.QueueOutbound(hostDisplayName, HV.MSG.REQUEST, contestId, {})
    HV.Print(string.format("|c00FF00Requested contest info for %s from %s.|r", contestId, hostDisplayName))
end

function HV.SubmitInterest(contestId)
    local joined = HV.sv.joinedContests[contestId]
    if not joined then
        HV.Print("|cFF0000You haven't joined that contest yet -- use /hv join first.|r")
        return
    end
    local _, houseName = HV.GetMyPrimaryHouse()
    if not houseName then
        HV.Print("|cFF0000You don't have a primary house set. Set one in the housing menu first.|r")
        return
    end
    HV.QueueOutbound(joined.hostDisplayName, HV.MSG.INTEREST, contestId, { HV.Sanitize(houseName) })
    HV.Print(string.format("|c00FF00Interest submitted for '%s' with house %s.|r", contestId, houseName))
end

function HV.SubmitVote(contestId, choiceDisplayName)
    local joined = HV.sv.joinedContests[contestId]
    if not joined then return end
    joined.myVote = choiceDisplayName
    HV.QueueOutbound(joined.hostDisplayName, HV.MSG.VOTE, contestId, { HV.Sanitize(choiceDisplayName) })
    HV.Print(string.format("|c00FF00Vote for %s submitted.|r", choiceDisplayName))
end

local function VoterHandleInfo(joined, fields)
    joined.title = fields[1]
    joined.state = fields[2]
    joined.rules = fields[3]
    joined.roster = DecodeRoster(fields[4])
    HV.Print(string.format("|c00FF00'%s' updated -- state: %s, %d house(s) on the roster.|r", joined.title, joined.state, #joined.roster))
end

local function VoterHandleResults(joined, fields)
    joined.title = fields[1]
    joined.winner = fields[2]
    joined.winnerVotes = fields[3]
    joined.state = HV.CONTEST_STATE.CLOSED
    HV.Print(string.format("|c00FF00Results for '%s': %s wins with %s vote(s).|r", joined.title, joined.winner, tostring(joined.winnerVotes)))
end

-- ============================================================
-- inbound dispatch (wired up from Mail.lua)
-- ============================================================

function HV.OnProtocolMessage(senderDisplayName, parsed)
    local hosted = HV.sv.hostedContests[parsed.contestId]
    if hosted then
        if parsed.msgType == HV.MSG.REQUEST then
            HostHandleRequest(hosted, senderDisplayName)
        elseif parsed.msgType == HV.MSG.INTEREST then
            HostHandleInterest(hosted, senderDisplayName, parsed.fields)
        elseif parsed.msgType == HV.MSG.VOTE then
            HostHandleVote(hosted, senderDisplayName, parsed.fields)
        end
        return
    end

    local joined = HV.sv.joinedContests[parsed.contestId]
    if joined then
        if parsed.msgType == HV.MSG.INFO then
            VoterHandleInfo(joined, parsed.fields)
        elseif parsed.msgType == HV.MSG.RESULTS then
            VoterHandleResults(joined, parsed.fields)
        end
    end
end

-- Non-persistent cache of pointers seen this session, so /hv join <id>
-- doesn't require re-typing the host's name.
HV.discovered = {}

function HV.OnMotdPointer(guildId, contestId, state, hostDisplayName, title)
    HV.discovered[contestId] = { hostDisplayName = hostDisplayName, title = title, state = state }

    if HV.sv.hostedContests[contestId] then return end -- it's our own
    if HV.sv.joinedContests[contestId] then return end -- already tracking it
    HV.Print(string.format("|cFFCC00Housing contest '%s' is %s (hosted by %s). Type /hv contests to see it.|r",
        title, state, hostDisplayName))
end

-- ============================================================
-- numeric lookup, so no command needs a typed contest id -- generated ids
-- are long and painful to enter with a controller's on-screen keyboard.
-- ============================================================

-- Every contest this character knows about (hosting, joined, or merely
-- discovered via a guild MOTD pointer), deduped and in a stable order so
-- the same index means the same contest across consecutive commands.
function HV.GetKnownContests()
    local seen = {}
    local list = {}

    local function add(contestId, title, state, role, hostDisplayName)
        if seen[contestId] then return end
        seen[contestId] = true
        table.insert(list, {
            contestId = contestId,
            title = title or "?",
            state = state or "?",
            role = role,
            hostDisplayName = hostDisplayName,
        })
    end

    for contestId, c in pairs(HV.sv.hostedContests) do
        add(contestId, c.title, c.state, "hosting", c.hostDisplayName)
    end
    for contestId, j in pairs(HV.sv.joinedContests) do
        local d = HV.discovered[contestId]
        add(contestId, j.title or (d and d.title), j.state or (d and d.state), "joined", j.hostDisplayName)
    end
    for contestId, d in pairs(HV.discovered) do
        add(contestId, d.title, d.state, "discovered", d.hostDisplayName)
    end

    table.sort(list, function(a, b) return a.contestId < b.contestId end)
    return list
end

-- Accepts either a number (an index into HV.GetKnownContests()) or a raw
-- contest id string, and returns the resolved contest id or nil. Slash
-- command handlers should always funnel their contest argument through
-- this rather than using the raw arg directly.
function HV.ResolveContestArg(arg)
    if not arg or arg == "" then return nil end
    local index = tonumber(arg)
    if index then
        local entry = HV.GetKnownContests()[index]
        return entry and entry.contestId or nil
    end
    return arg
end
