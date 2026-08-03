local SRC = SupportRotationCallouts
SRC.TrashRotation = SRC.TrashRotation or {}
local Trash = SRC.TrashRotation

local MAX_TEAMS = 4
local function TeamKey(team) return "trashUltimateTeam" .. tostring(team) end
local function CountKey(team) return TeamKey(team) .. "Count" end
local function EnabledKey(team) return TeamKey(team) .. "Enabled" end

local function SessionTrashGroup(team)
    local session = Conductor and Conductor.RaidSession and Conductor.RaidSession:GetActive() or nil
    local plan = session and session.raidPlan or (Conductor and Conductor.saved and Conductor.saved.activeRaidPlan) or nil
    local assignments = session and session.assignments or nil
    local groups = plan and plan.trashPlan and plan.trashPlan.groups or (assignments and (assignments.trashUltimateGroups or assignments.ultimateGroups))
    local group = groups and (groups[team] or groups[tostring(team)]) or nil
    if type(group) ~= "table" then return nil end
    return group.players or group.accounts or group
end

function Trash:IsTeamEnabled(team)
    return SRC.saved[EnabledKey(team)] == true
end

function Trash:FindNextEnabledTeam(startTeam)
    local start = zo_clamp(tonumber(startTeam) or 1, 1, MAX_TEAMS)
    for offset = 0, MAX_TEAMS - 1 do
        local candidate = ((start - 1 + offset) % MAX_TEAMS) + 1
        if self:IsTeamEnabled(candidate) then return candidate end
    end
    return nil
end

function Trash:Initialize()
    self.currentTeam = self:FindNextEnabledTeam(1) or 1
    self.active = false
    self.sessionGeneration = nil
    self.sessionFingerprint = nil
end

function Trash:GetTeamAccounts(team)
    local key = TeamKey(team)
    local sessionGroup = SessionTrashGroup(team)
    local source = sessionGroup or (SRC.saved[key] or {})
    local count = sessionGroup and #sessionGroup or zo_clamp(tonumber(SRC.saved[CountKey(team)]) or 1, 1, 6)
    local accounts, seen = {}, {}
    for index = 1, count do
        local account = SRC:NormalizeAccountName(source[index] or "")
        if account ~= "" and account ~= "@" and not seen[account] then
            local resolved = Conductor and Conductor.LiveSession and Conductor.LiveSession:ResolveAccount(account, "TRASH_ULTIMATE") or account
            if resolved then
                accounts[#accounts + 1] = resolved
                seen[resolved] = true
            end
        end
    end
    return accounts
end

function Trash:SetCurrentTeam(team)
    self.currentTeam = self:FindNextEnabledTeam(team) or 1
end

function Trash:Advance()
    self:SetCurrentTeam((self.currentTeam % MAX_TEAMS) + 1)
end

function Trash:OnTrashCombatStarted()
    if SRC.saved.trashRotationEnabled ~= true or self.active or SRC.bossEncounterActive then return end
    local team = self:FindNextEnabledTeam(self.currentTeam)
    if not team then return end
    self.currentTeam = team
    self.active = true
    self.sessionGeneration = Conductor and Conductor.LiveSession and Conductor.LiveSession:GetGeneration() or 0
    self.sessionFingerprint = Conductor and Conductor.LiveSession and Conductor.LiveSession:GetFingerprint() or ""

    local accounts = self:GetTeamAccounts(team)
    local names = (#accounts > 0) and accounts or { "ULTIMATE GROUP " .. tostring(team) }

    if Conductor and Conductor.TimelineEngine then
        local timeline = Conductor.TimelineEngine
        timeline:Clear("trash pull started")
        timeline:Start("trash ultimate group")
        timeline:AddEvent({
            key = "TRASH_ULTIMATE",
            label = "Ultimate Group " .. tostring(team),
            targetMs = (GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0) + 1000,
            lane = "RAID",
            audiences = { "all" },
            displayAssignedText = #accounts > 0 and table.concat(accounts, "  ") or "ROSTER ASSIGNMENT NEEDED",
            trashTeam = team,
            assignedAccounts = accounts,
        })
    end

    if SRC.Display and SRC.Display.ShowRaidCallout then
        SRC.Display:ShowRaidCallout(names, "ULTIMATE GROUP " .. tostring(team), "NOW", 2200)
    end
    if SRC.Diagnostics then
        SRC.Diagnostics:AddFields("TRASH_ROTATION", "Ultimate team called", {
            team = team,
            players = table.concat(accounts, ","),
        })
    end
end

function Trash:CancelForBoss()
    if not self.active then return end
    self.active = false
    if SRC.Diagnostics then SRC.Diagnostics:Add("TRASH_ROTATION", "Trash rotation cancelled for boss encounter") end
end

function Trash:OnCombatEnded()
    if not self.active then return end
    self.active = false
    if Conductor and Conductor.TimelineEngine then Conductor.TimelineEngine:Clear("trash pull ended") end
    if SRC.saved.trashAdvanceOnCombatEnd ~= false then self:Advance() end
end

function Trash:ResetRuntime(reason)
    self.active = false
    self.sessionGeneration = nil
    self.sessionFingerprint = nil
    self:SetCurrentTeam(1)
    if SRC.Diagnostics then SRC.Diagnostics:Add("TRASH_ROTATION", "Runtime reset: " .. tostring(reason or "unspecified")) end
end

function Trash:Reset()
    self:ResetRuntime("manual reset")
end
