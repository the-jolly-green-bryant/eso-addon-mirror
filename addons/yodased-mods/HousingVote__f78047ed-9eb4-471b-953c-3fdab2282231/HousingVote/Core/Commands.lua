local HV = HousingVote

local function SplitArgs(str)
    local args = {}
    for token in (str or ""):gmatch("%S+") do
        table.insert(args, token)
    end
    return args
end

local HELP = {
    "|c00CCFF/hv guilds|r -- list your guilds with their index",
    "|c00CCFF/hv create <guildIndex> <title...>|r -- host a new contest, announced via that guild's MOTD",
    "|c00CCFF/hv contests|r -- list every contest you know about, numbered for use in the commands below",
    "|c00CCFF/hv rules <#> <text...>|r -- set/update the rules text (host only)",
    "|c00CCFF/hv open <#>|r -- lock the roster and mail it out for voting (host only)",
    "|c00CCFF/hv close <#>|r -- tally votes and publish the winner (host only)",
    "|c00CCFF/hv join <#>|r -- opt in as a voter/participant",
    "|c00CCFF/hv interest <#>|r -- submit your primary house for a contest you've joined",
    "|c00CCFF/hv vote <#> <displayName>|r -- vote for a house by its owner's display name",
    "|c00CCFF/hv voteui <#>|r -- open the gamepad voting screen for a contest you've joined",
    "|c00CCFF/hv menu|r -- (secondary) open the gamepad popup window -- primary interaction is Options > Add-Ons > Housing Vote",
    "|c00CCFF/hv sync|r -- force-refresh the Options > Add-Ons > Housing Vote rows (otherwise auto-refreshes every ~5s)",
    "|c00CCFF/hv status|r -- show everything you're hosting or have joined",
    "|c00CCFF[debug] /hv simulate <type> <#> <fakeName> [fields...]|r -- inject a fake incoming message (ESO blocks mail between your own alts)",
    "|c00CCFF[debug] /hv simulatejoin <#>|r -- seed a local voter view of a contest you host, no mail needed",
    "|c00CCFF[debug] /hv simulatediscover <title>|r -- fake a discovered contest so Join & Submit Interest has something to test",
    "All <#> arguments are numbers from /hv contests, not the raw contest id.",
}

local function CmdGuilds()
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        HV.Print(string.format("  [%d] %s", i, GetGuildName(guildId)))
    end
end

local function CmdCreate(args)
    local guildIndex = tonumber(args[1])
    if not guildIndex or not args[2] then
        HV.Print("Usage: /hv create <guildIndex> <title...>  (see /hv guilds)")
        return
    end
    local guildId = GetGuildId(guildIndex)
    if not guildId or guildId == 0 then
        HV.Print("|cFF0000No guild at that index -- check /hv guilds.|r")
        return
    end
    local title = table.concat(args, " ", 2)
    HV.CreateContest(guildId, title, "")
end

local function CmdContests()
    local list = HV.GetKnownContests()
    if #list == 0 then
        HV.Print("No known contests yet -- host one with /hv create, or wait for a guild MOTD pointer to be noticed.")
        return
    end
    for i, entry in ipairs(list) do
        HV.Print(string.format("  [%d] (%s) '%s' hosted by %s -- %s", i, entry.role, entry.title, entry.hostDisplayName or "?", entry.state))
    end
end

-- Resolves args[1] (a number from /hv contests, or a raw id) to a contest
-- id, printing a standard error and returning nil if it can't be resolved.
local function ResolveOrError(args)
    local contestId = HV.ResolveContestArg(args[1])
    if not contestId then
        HV.Print("|cFF0000Unknown contest -- check /hv contests.|r")
        return nil
    end
    return contestId
end

local function CmdRules(args)
    local contestId = ResolveOrError(args)
    if not contestId then return end
    local contest = HV.sv.hostedContests[contestId]
    if not contest then
        HV.Print("|cFF0000You're not the host of that contest.|r")
        return
    end
    contest.rules = table.concat(args, " ", 2)
    HV.Print("|c00FF00Rules updated. Run /hv open when ready to lock the roster and mail voters.|r")
end

local function CmdOpen(args)
    local contestId = ResolveOrError(args)
    if not contestId then return end
    HV.HostOpenVoting(contestId)
end

local function CmdClose(args)
    local contestId = ResolveOrError(args)
    if not contestId then return end
    HV.HostCloseContest(contestId)
end

local function CmdJoin(args)
    local contestId = ResolveOrError(args)
    if not contestId then return end
    local hostDisplayName = args[2]
        or (HV.discovered[contestId] and HV.discovered[contestId].hostDisplayName)
        or (HV.sv.joinedContests[contestId] and HV.sv.joinedContests[contestId].hostDisplayName)
    if not hostDisplayName then
        HV.Print("|cFF0000Don't know who hosts that contest yet -- supply their display name, or wait for the guild MOTD pointer to be seen.|r")
        return
    end
    HV.JoinContest(contestId, hostDisplayName)
end

local function CmdInterest(args)
    local contestId = ResolveOrError(args)
    if not contestId then return end
    HV.SubmitInterest(contestId)
end

local function CmdVote(args)
    local contestId = ResolveOrError(args)
    if not contestId then return end
    if not args[2] then
        HV.Print("Usage: /hv vote <#> <displayName>")
        return
    end
    HV.SubmitVote(contestId, args[2])
end

local function CmdMenu()
    HV.OpenGamepadWindow()
end

local function CmdVoteUi(args)
    local contestId = ResolveOrError(args)
    if not contestId then return end
    HV.ShowVoteScreenFor(contestId)
end

local function CmdSync()
    if not HV.SyncConsoleMenuRows then
        HV.Print("|cFF0000The console Add-ons menu isn't available on this UI mode.|r")
        return
    end
    HV.SyncConsoleMenuRows()
    HV.Print("|c00CCFFSynced -- check Options > Add-Ons > Housing Vote for any new rows.|r")
end

-- ============================================================
-- DEBUG / solo-testing only. ESO blocks mail between your own alts (all
-- characters on an account share one mailbox, and self-mail is rejected
-- outright), so these let you exercise the full flow from one character
-- by injecting messages directly instead of actually mailing them.
-- ============================================================

local function CmdSimulate(args)
    local msgType = args[1] and args[1]:upper()
    local contestId = HV.ResolveContestArg(args[2])
    local senderDisplayName = args[3]
    if not msgType or not HV.MSG[msgType] or not contestId or not senderDisplayName then
        HV.Print("Usage: /hv simulate <REQUEST|INFO|INTEREST|VOTE|RESULTS> <#> <fakeSenderName> [fields...]")
        return
    end
    local fields = {}
    for i = 4, #args do table.insert(fields, args[i]) end
    HV.OnProtocolMessage(senderDisplayName, { msgType = HV.MSG[msgType], contestId = contestId, fields = fields })
    HV.Print(string.format("|c00CCFF[debug] simulated %s from %s.|r", msgType, senderDisplayName))
end

-- Seeds a local voter-side view of a contest you host, copied directly
-- from your own hostedContests data (no mail involved), so /hv voteui and
-- /hv menu have something real to render for the voter role too.
local function CmdSimulateJoin(args)
    local contestId = ResolveOrError(args)
    if not contestId then return end
    local contest = HV.sv.hostedContests[contestId]
    if not contest then
        HV.Print("|cFF0000[debug] you can only simulatejoin a contest you're hosting.|r")
        return
    end
    local roster = {}
    for displayName, info in pairs(contest.interests) do
        table.insert(roster, { displayName = displayName, houseName = info.houseName })
    end
    HV.sv.joinedContests[contestId] = {
        contestId = contestId,
        hostDisplayName = contest.hostDisplayName,
        title = contest.title,
        rules = contest.rules,
        state = contest.state,
        roster = roster,
    }
    HV.Print("|c00CCFF[debug] seeded a local voter-side view of this contest -- try /hv voteui or /hv menu now.|r")
end

-- Injects a fake "discovered" contest so /hv contests, /hv menu, and the
-- Options > Add-Ons > Housing Vote menu all show a Join & Submit Interest
-- action to press -- you can never see your own hosted contest as
-- "discovered" for real, so this is the only way to solo-test that step.
local function CmdSimulateDiscover(args)
    local title = table.concat(args, " ")
    if title == "" then
        HV.Print("Usage: /hv simulatediscover <title>")
        return
    end
    local contestId = "debug-" .. GetTimeStamp()
    HV.discovered[contestId] = {
        hostDisplayName = "@DebugHost",
        title = title,
        state = HV.CONTEST_STATE.INTEREST,
    }
    HV.Print(string.format("|c00CCFF[debug] '%s' now shows as discovered -- try Join & Submit Interest on it via /hv menu or the Add-ons menu.|r", title))
end

local function CmdStatus()
    HV.Print("|c00CCFFHosting:|r")
    for id, c in pairs(HV.sv.hostedContests) do
        HV.Print(string.format("  %s -- '%s' [%s] %d interested, %d votes", id, c.title, c.state, HV.CountKeys(c.interests), HV.CountKeys(c.votes)))
    end
    HV.Print("|c00CCFFJoined:|r")
    for id, j in pairs(HV.sv.joinedContests) do
        HV.Print(string.format("  %s -- '%s' [%s]%s", id, j.title or "?", j.state or "?", j.myVote and (" your vote: " .. j.myVote) or ""))
    end
end

local HANDLERS = {
    guilds = CmdGuilds,
    create = CmdCreate,
    contests = CmdContests,
    rules = CmdRules,
    open = CmdOpen,
    close = CmdClose,
    join = CmdJoin,
    interest = CmdInterest,
    vote = CmdVote,
    voteui = CmdVoteUi,
    menu = CmdMenu,
    sync = CmdSync,
    simulate = CmdSimulate,
    simulatejoin = CmdSimulateJoin,
    simulatediscover = CmdSimulateDiscover,
    status = CmdStatus,
}

local function OnSlashCommand(fullArgString)
    local args = SplitArgs(fullArgString)
    local sub = table.remove(args, 1)
    local handler = sub and HANDLERS[sub:lower()]
    if not handler then
        for _, line in ipairs(HELP) do HV.Print(line) end
        return
    end
    handler(args)
end

function HV.InitCommands()
    SLASH_COMMANDS["/hv"] = OnSlashCommand
    SLASH_COMMANDS["/housingvote"] = OnSlashCommand
end
