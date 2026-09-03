local HV = HousingVote

-- Primary interactive surface for console: native rows in the Add-ons
-- menu via LibConsoleMenu (LCM). Confirmed working end-to-end by testing
-- (a vote row was pressable and correctly went disabled after voting).
--
-- Structure: "Housing Vote" (root) contains "Refresh List", a "Host a
-- Contest" form submenu (added once guild data is actually available --
-- see CONFIRMED BUG below), one submenu PER CONTEST (status, join +
-- submit interest, host-only open/close controls), and -- flat, at the
-- root, not nested -- one "Vote: <contest> -> <house>" row per roster
-- entry once a contest's voting opens.
--
-- This stays entirely within LCM's confirmed real constraints:
--   - Options are append-only, and ONLY confirmed to work at the ROOT
--     menu (menu:AddOptions can be called again later to add more rows).
--     Whether an already-created SUBMENU can later receive more appended
--     options is NOT confirmed anywhere in the docs, so nothing relies on
--     it: each contest's submenu is built completely, in one shot, the
--     first time that contest is seen, and never touched again.
--   - A row's `name` is a static string fixed when added, never renamed.
--     Live state goes through `tooltip` and `disabled`, both confirmed to
--     accept functions that re-evaluate live.
--
-- CONFIRMED BUG (fixed): the "Host a Contest" guild selector's `choices`
-- were snapshotted once, at addon-load time, via GetNumGuilds()/GetGuildId
-- -- but guild membership data often isn't loaded that early, so the
-- dropdown could come up empty with nothing valid to select, silently
-- blocking Create. Fixed by not adding the host form until the periodic
-- sync sees GetNumGuilds() > 0, matching the same wait-and-poll approach
-- already used for discovering contests.
--
-- CONFIRMED BUG (fixed): vote choices were 10 pre-reserved slot rows
-- nested in each contest's submenu, to work around not being able to
-- append into an existing submenu -- but that's an arbitrary cap on
-- contest size. Fixed by appending vote rows at the ROOT instead (the one
-- append path that's actually confirmed unlimited), named with the
-- contest title so they stay clearly associated with it.

local menu
local addedContestIds = {}
local addedVoteRowKeys = {}
local hostFormAdded = false

local hostForm = {
    guildIndex = 1,
    title = "",
}

-- ============================================================
-- helpers
-- ============================================================

local function FindKnownContest(contestId)
    for _, entry in ipairs(HV.GetKnownContests()) do
        if entry.contestId == contestId then
            return entry
        end
    end
    return nil
end

local function GetGuildChoices()
    local choices = {}
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        table.insert(choices, { name = GetGuildName(guildId), value = i })
    end
    return choices
end

-- ============================================================
-- "Host a Contest" form -- only added once GetNumGuilds() > 0 (see sync)
-- ============================================================

local function AddHostSubmenu()
    if hostFormAdded then return end
    if GetNumGuilds() == 0 then return end
    hostFormAdded = true

    menu:AddOptions({
        {
            type = "submenu",
            name = "Host a Contest",
            options = {
                {
                    type = "selector",
                    name = "Guild",
                    tooltip = "Which guild's MOTD announces this contest.",
                    choices = GetGuildChoices(),
                    getFunc = function() return hostForm.guildIndex end,
                    setFunc = function(value) hostForm.guildIndex = value end,
                    default = 1,
                },
                {
                    type = "editbox",
                    name = "Title",
                    tooltip = "Contest title, shown to everyone who joins.",
                    getFunc = function() return hostForm.title end,
                    setFunc = function(value) hostForm.title = value end,
                    default = "",
                    maxInputCharacters = 40,
                    placeholderText = "Best House Contest",
                },
                {
                    type = "button",
                    name = "Create Contest",
                    tooltip = "Creates the contest and announces it via the selected guild's MOTD.",
                    disabled = function() return hostForm.title == nil or hostForm.title == "" end,
                    func = function()
                        local guildId = GetGuildId(hostForm.guildIndex)
                        if not guildId or guildId == 0 then
                            HV.Print("|cFF0000No guild at that selection.|r")
                            return
                        end
                        HV.CreateContest(guildId, hostForm.title, "")
                        hostForm.title = ""
                        HV.SyncConsoleMenuRows()
                    end,
                },
            },
        },
    })
end

-- ============================================================
-- per-contest submenu (status, join, host controls -- NOT vote choices,
-- see AddVoteRows below)
-- ============================================================

local function BuildStatusRow(contestId)
    return {
        type = "button",
        name = "Status",
        tooltip = function()
            local e = FindKnownContest(contestId)
            if not e then return "No longer available." end
            return string.format("Hosted by %s\nRole: %s\nState: %s", e.hostDisplayName or "?", e.role, e.state)
        end,
        func = function()
            local e = FindKnownContest(contestId)
            if not e then
                HV.Print("|cFF0000That contest is no longer known.|r")
                return
            end
            if e.role == "hosting" then
                local contest = HV.sv.hostedContests[contestId]
                HV.Print(string.format("|c00CCFF'%s' [%s] -- %d interested, %d votes.|r",
                    contest.title, contest.state, HV.CountKeys(contest.interests), HV.CountKeys(contest.votes)))
            else
                HV.Print(string.format("|c00CCFF'%s' -- role: %s, state: %s.|r", e.title, e.role, e.state))
            end
        end,
    }
end

local function BuildJoinRow(contestId)
    return {
        type = "button",
        name = "Join & Submit Interest",
        tooltip = "Opts you in and submits your currently-set primary house.",
        disabled = function()
            local e = FindKnownContest(contestId)
            return not e or e.role ~= "discovered"
        end,
        func = function()
            local e = FindKnownContest(contestId)
            if not e then return end
            HV.JoinContest(contestId, e.hostDisplayName)
            HV.SubmitInterest(contestId)
        end,
    }
end

local function BuildOpenVotingRow(contestId)
    return {
        type = "button",
        name = "Open Voting",
        tooltip = "Locks the roster and mails it to everyone who submitted interest.",
        disabled = function()
            local contest = HV.sv.hostedContests[contestId]
            return not contest or contest.state ~= HV.CONTEST_STATE.INTEREST
        end,
        func = function() HV.HostOpenVoting(contestId) end,
    }
end

local function BuildCloseRow(contestId)
    return {
        type = "button",
        name = "Close & Tally",
        tooltip = "Tallies votes and mails the results to participants.",
        disabled = function()
            local contest = HV.sv.hostedContests[contestId]
            return not contest or contest.state ~= HV.CONTEST_STATE.VOTING
        end,
        func = function() HV.HostCloseContest(contestId) end,
    }
end

local function BuildContestSubmenu(entry)
    local contestId = entry.contestId
    return {
        type = "submenu",
        name = entry.title,
        options = {
            BuildStatusRow(contestId),
            BuildJoinRow(contestId),
            BuildOpenVotingRow(contestId),
            BuildCloseRow(contestId),
        },
    }
end

local function AddContestRow(entry)
    if addedContestIds[entry.contestId] then return end
    addedContestIds[entry.contestId] = true
    menu:AddOptions({ BuildContestSubmenu(entry) })
end

-- ============================================================
-- vote rows -- flat, at the root, unlimited (see file header)
-- ============================================================

local function AddVoteRows(contestId, joined)
    for i, rEntry in ipairs(joined.roster) do
        local key = contestId .. "#" .. i
        if not addedVoteRowKeys[key] then
            addedVoteRowKeys[key] = true

            local voteChoice = rEntry.displayName
            local contestTitle = joined.title or contestId
            menu:AddOptions({
                {
                    type = "button",
                    name = string.format("Vote (%s): %s (%s)", contestTitle, rEntry.houseName, rEntry.displayName),
                    tooltip = string.format("Cast your vote for this house in '%s'.", contestTitle),
                    disabled = function()
                        local j = HV.sv.joinedContests[contestId]
                        return not j or j.state ~= HV.CONTEST_STATE.VOTING or j.myVote ~= nil
                    end,
                    func = function()
                        HV.SubmitVote(contestId, voteChoice)
                    end,
                },
            })
        end
    end
end

-- ============================================================
-- sync / registration
-- ============================================================

local function SyncMenuRows()
    if not menu then return end

    AddHostSubmenu()

    for _, entry in ipairs(HV.GetKnownContests()) do
        AddContestRow(entry)
    end

    for contestId, joined in pairs(HV.sv.joinedContests) do
        if joined.state == HV.CONTEST_STATE.VOTING and joined.roster and #joined.roster > 0 then
            AddVoteRows(contestId, joined)
        end
    end
end

local function RegisterMenu()
    local LCM = LibConsoleMenu
    if not LCM or type(LCM.CreateAddonMenu) ~= "function" then
        return
    end

    menu = LCM:CreateAddonMenu(HV.name, {
        title = "Housing Vote",
        author = "yodased-mods",
        version = "0.5.0",
        category = "HOUSING",
    })

    menu:AddOptions({
        {
            type = "button",
            name = "Refresh List",
            tooltip = "Check for newly discovered or created contests, and for guild data if Host a Contest hasn't appeared yet.",
            func = function() SyncMenuRows() end,
        },
    })

    SyncMenuRows()
    EVENT_MANAGER:RegisterForUpdate(HV.name .. "ConsoleMenuSync", 5000, SyncMenuRows)
end

function HV.InitConsoleMenu()
    if not IsConsoleUI or not IsConsoleUI() then
        return
    end
    RegisterMenu()
end

-- Exposed for /hv sync (a manual nudge) and for the Lua test harness.
HV.SyncConsoleMenuRows = SyncMenuRows
