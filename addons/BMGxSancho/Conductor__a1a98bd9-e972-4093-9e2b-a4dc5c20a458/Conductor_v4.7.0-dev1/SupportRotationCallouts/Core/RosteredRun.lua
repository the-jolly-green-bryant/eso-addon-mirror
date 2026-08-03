local C = Conductor
C.RosteredRun = C.RosteredRun or {}
local RosteredRun = C.RosteredRun

local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = Copy(item) end
    return output
end

local function NormalizeAccount(value)
    if C.NormalizeAccountName then return C:NormalizeAccountName(value or "") end
    return tostring(value or "")
end

local function BuildPlayers(slots)
    local players = {}
    local seen = {}
    for index, slot in ipairs(slots or {}) do
        local accountName = NormalizeAccount(slot.player ~= "" and slot.player or slot.manualPlayer)
        if accountName ~= "" and not seen[accountName] then
            seen[accountName] = true
            players[#players + 1] = {
                accountName = accountName,
                rosterSlot = index,
                rosterRole = slot.role,
                combatRole = index <= 2 and "TANK" or index <= 4 and "HEALER" or "DD",
                classKey = slot.class or "",
                loadout = {
                    set1 = slot.set1 or "NONE",
                    set2 = slot.set2 or "NONE",
                    monster = slot.monster or "NONE",
                    mythic = slot.mythic or "NONE",
                    arena = slot.arena or "NONE",
                    manualSet1 = slot.manualSet1 or "",
                    manualSet2 = slot.manualSet2 or "",
                    manualMonster = slot.manualMonster or "",
                    manualMythic = slot.manualMythic or "",
                    manualArena = slot.manualArena or "",
                    notes = slot.manualNotes or "",
                },
                inference = {
                    source = slot.source or "AUTO",
                    confidence = tonumber(slot.roleConfidence) or 0,
                    inferredRole = slot.inferredRole,
                },
            }
        end
    end
    return players
end

local function BuildSynchronization(players, hostAccount)
    local synchronization = { accepted = {}, pending = {}, disconnected = {}, incompatible = {} }
    local host = NormalizeAccount(hostAccount)
    for _, player in ipairs(players or {}) do
        if player.accountName == host then
            synchronization.accepted[player.accountName] = true
        else
            synchronization.pending[player.accountName] = true
        end
    end
    return synchronization
end

function RosteredRun:Start(slots, context)
    if not C.RaidSession then return nil, "Raid Session service is unavailable." end
    context = context or {}
    local players = BuildPlayers(slots)
    if #players == 0 then return nil, "No current group players were available." end

    local hostAccount = NormalizeAccount(GetDisplayName and GetDisplayName() or "")
    local session = C.RaidSession:Create({
        mode = C.RaidSession.MODES.ROSTERED,
        hostAccount = hostAccount,
        trial = context.trial,
        difficulty = context.difficulty,
        objective = context.objective,
        strategy = context.strategy,
        players = players,
        assignments = Copy(context.assignments or {}),
        responsibilities = Copy(context.responsibilities or {}),
        synchronization = BuildSynchronization(players, hostAccount),
        runtime = { encounter=nil, encounterState="INACTIVE", executionMode="INACTIVE" },
    })

    if C.EventBus then
        C.EventBus:Publish("ROSTERED_RUN_STARTED", { session=session, playerCount=#players })
    end
    if C.Diagnostics and C.Diagnostics.AddFields then
        C.Diagnostics:AddFields("RAID_SESSION", "Rostered Run started", {
            sessionId = session.sessionId,
            players = #players,
            trial = tostring(session.trial or ""),
            difficulty = tostring(session.difficulty or ""),
            objective = tostring(session.objective or ""),
        })
    end
    return session
end

function RosteredRun:GetSummary()
    local session = C.RaidSession and C.RaidSession:GetActive()
    if not session or session.mode ~= (C.RaidSession and C.RaidSession.MODES.ROSTERED) then
        return "No active Rostered Run."
    end
    return string.format("Rostered Run active: %d players | %s", #(session.players or {}), tostring(session.state or "CREATED"))
end
