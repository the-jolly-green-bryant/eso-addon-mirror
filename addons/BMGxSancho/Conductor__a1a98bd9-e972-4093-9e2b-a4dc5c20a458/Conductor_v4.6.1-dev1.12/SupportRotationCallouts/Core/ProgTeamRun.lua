local C = Conductor
local SRC = SupportRotationCallouts
C.ProgTeamRun = C.ProgTeamRun or {}
local ProgTeamRun = C.ProgTeamRun

local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = Copy(item) end
    return output
end

local function NormalizeAccount(value)
    if C.NormalizeAccountName then return C:NormalizeAccountName(value or "") end
    return string.lower(tostring(value or ""))
end

local function SlotAccount(slot)
    if not slot then return "" end
    local value = slot.player
    if not value or value == "" then value = slot.manualPlayer end
    return NormalizeAccount(value)
end

local function CombatRoleForSlot(index)
    if index <= 2 then return "TANK" end
    if index <= 4 then return "HEALER" end
    return "DD"
end

local function CurrentGroupMap()
    local current = {}
    local ordered = {}
    local function AddAccount(accountName)
        local account = NormalizeAccount(accountName)
        if account == "" or current[account] then return end
        local player = C.Database and C.Database:GetPlayer(account) or nil
        player = player or { accountName = account, role = "UNKNOWN", source = "group" }
        current[account] = player
        ordered[#ordered + 1] = player
    end

    local groupSize = GetGroupSize and tonumber(GetGroupSize()) or 0
    if groupSize > 0 and GetUnitDisplayName then
        for index = 1, groupSize do AddAccount(GetUnitDisplayName("group" .. tostring(index))) end
    else
        AddAccount(GetDisplayName and GetDisplayName() or "")
    end
    return current, ordered
end

local function PlayerRole(player)
    local role = string.upper(tostring(player and player.role or ""))
    if role == "TANK" or role == "HEALER" or role == "DD" then return role end
    return "UNKNOWN"
end

function ProgTeamRun:Compare(profile)
    if not profile then return nil, "No Prog Team selected." end
    local currentMap, currentPlayers = CurrentGroupMap()
    local savedAccounts = {}
    local comparison = {
        profileId = profile.id,
        profileName = profile.name,
        present = {},
        missing = {},
        extras = {},
        suggestions = {},
        createdAt = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0,
    }

    for index, slot in ipairs(profile.players or {}) do
        local account = SlotAccount(slot)
        if account ~= "" then
            savedAccounts[account] = true
            if currentMap[account] then
                comparison.present[#comparison.present + 1] = { slot = index, accountName = account, role = CombatRoleForSlot(index) }
            else
                comparison.missing[#comparison.missing + 1] = { slot = index, accountName = account, role = CombatRoleForSlot(index) }
            end
        end
    end

    for _, player in ipairs(currentPlayers) do
        local account = NormalizeAccount(player.accountName)
        if account ~= "" and not savedAccounts[account] then
            comparison.extras[#comparison.extras + 1] = {
                accountName = account,
                role = PlayerRole(player),
                player = player,
            }
        end
    end

    local used = {}
    for _, missing in ipairs(comparison.missing) do
        local selectedIndex = nil
        for index, extra in ipairs(comparison.extras) do
            if not used[index] and extra.role == missing.role then selectedIndex = index; break end
        end
        if not selectedIndex then
            for index in ipairs(comparison.extras) do if not used[index] then selectedIndex = index; break end end
        end
        if selectedIndex then
            used[selectedIndex] = true
            comparison.suggestions[#comparison.suggestions + 1] = {
                slot = missing.slot,
                missingAccount = missing.accountName,
                replacementAccount = comparison.extras[selectedIndex].accountName,
                replacementPlayer = comparison.extras[selectedIndex].player,
                role = missing.role,
            }
        end
    end

    SRC.saved.progTeamComparison = Copy(comparison)
    if C.EventBus then C.EventBus:Publish("PROG_TEAM_COMPARED", { profile = profile, comparison = comparison }) end
    return comparison
end

function ProgTeamRun:Open(profile, destinationSlots)
    if not profile then return nil, "No Prog Team selected." end
    if type(destinationSlots) ~= "table" then return nil, "Team Review is unavailable." end

    for index = 1, 12 do
        destinationSlots[index] = Copy((profile.players or {})[index] or {
            role = index <= 2 and ("Tank " .. index) or index <= 4 and ("Healer " .. (index - 2)) or ("DD " .. (index - 4)),
            player = "", class = "", set1 = "NONE", set2 = "NONE", monster = "NONE", mythic = "NONE", arena = "NONE", source = "PROG_TEAM",
        })
        destinationSlots[index].source = "PROG_TEAM"
    end

    SRC.saved.profileDraftInstance = (profile.context or {}).trial or SRC.saved.profileDraftInstance
    SRC.saved.profileDraftDifficulty = (profile.context or {}).difficulty or SRC.saved.profileDraftDifficulty
    SRC.saved.profileDraftObjective = (profile.context or {}).objective or SRC.saved.profileDraftObjective
    SRC.saved.profileDraftStrategy = (profile.context or {}).strategy or SRC.saved.profileDraftStrategy

    local comparison = self:Compare(profile)
    if C.EventBus then C.EventBus:Publish("PROG_TEAM_OPENED", { profile = profile, comparison = comparison }) end
    return comparison
end

local function PopulateFromPlayer(slot, player)
    if not slot or not player then return end
    slot.player = NormalizeAccount(player.accountName)
    slot.manualPlayer = ""
    slot.class = player.classKey or player.className or slot.class or ""
    local gear = player.gear or {}
    slot.set1 = gear.set1Key or gear.set1 or "NONE"
    slot.set2 = gear.set2Key or gear.set2 or "NONE"
    slot.monster = gear.monsterKey or gear.monster or "NONE"
    slot.mythic = gear.mythicKey or gear.mythic or "NONE"
    slot.arena = gear.arenaKey or gear.arena or "NONE"
    slot.source = "PROG_TEAM_REPLACEMENT"
end

function ProgTeamRun:ApplySuggestions(slots)
    local comparison = SRC.saved.progTeamComparison
    if type(comparison) ~= "table" or type(slots) ~= "table" then return 0 end
    local applied = 0
    for _, suggestion in ipairs(comparison.suggestions or {}) do
        local slot = slots[suggestion.slot]
        if slot then
            PopulateFromPlayer(slot, suggestion.replacementPlayer or (C.Database and C.Database:GetPlayer(suggestion.replacementAccount)))
            applied = applied + 1
        end
    end
    if C.EventBus then C.EventBus:Publish("PROG_TEAM_REPLACEMENTS_APPLIED", { comparison = comparison, count = applied }) end
    return applied
end

local function BuildPlayers(slots)
    local players = {}
    local seen = {}
    for index, slot in ipairs(slots or {}) do
        local account = SlotAccount(slot)
        if account ~= "" and not seen[account] then
            seen[account] = true
            players[#players + 1] = {
                accountName = account,
                rosterSlot = index,
                rosterRole = slot.role,
                combatRole = CombatRoleForSlot(index),
                classKey = slot.class or "",
                loadout = {
                    set1 = slot.set1 or "NONE", set2 = slot.set2 or "NONE", monster = slot.monster or "NONE",
                    mythic = slot.mythic or "NONE", arena = slot.arena or "NONE", notes = slot.manualNotes or "",
                },
                inference = { source = slot.source or "PROG_TEAM", confidence = tonumber(slot.roleConfidence) or 1.0 },
            }
        end
    end
    return players
end

local function BuildSynchronization(players, hostAccount)
    local synchronization = { accepted = {}, pending = {}, disconnected = {}, incompatible = {} }
    local host = NormalizeAccount(hostAccount)
    for _, player in ipairs(players or {}) do
        if player.accountName == host then synchronization.accepted[player.accountName] = true
        else synchronization.pending[player.accountName] = true end
    end
    return synchronization
end

function ProgTeamRun:Start(profile, slots, context)
    if not C.RaidSession then return nil, "Raid Session service is unavailable." end
    if not profile then return nil, "No Prog Team selected." end
    local players = BuildPlayers(slots)
    if #players == 0 then return nil, "The Prog Team roster is empty." end

    context = context or {}
    local savedContext = profile.context or {}
    local hostAccount = NormalizeAccount(GetDisplayName and GetDisplayName() or "")
    local session = C.RaidSession:Create({
        mode = C.RaidSession.MODES.PROG_TEAM,
        hostAccount = hostAccount,
        trial = context.trial or savedContext.trial,
        difficulty = context.difficulty or savedContext.difficulty,
        objective = context.objective or savedContext.objective,
        strategy = context.strategy or savedContext.strategy,
        players = players,
        assignments = Copy(context.assignments or savedContext.assignments or {}),
        responsibilities = Copy(context.responsibilities or savedContext.responsibilities or {}),
        synchronization = BuildSynchronization(players, hostAccount),
        runtime = { encounter = nil, encounterState = "INACTIVE", executionMode = "INACTIVE" },
        sourceProfileId = profile.id,
    })

    if C.EventBus then C.EventBus:Publish("PROG_TEAM_RUN_STARTED", { session = session, profile = profile, playerCount = #players }) end
    return session
end

function ProgTeamRun:GetSummaryText(comparison)
    comparison = comparison or SRC.saved.progTeamComparison
    if type(comparison) ~= "table" then return "No Prog Team comparison is available." end
    return string.format("%s: %d present, %d missing, %d substitutes available", tostring(comparison.profileName or "Prog Team"), #(comparison.present or {}), #(comparison.missing or {}), #(comparison.extras or {}))
end

function ProgTeamRun:PrintComparison(comparison)
    comparison = comparison or SRC.saved.progTeamComparison
    if type(comparison) ~= "table" then return false end
    local function Print(message)
        if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then CHAT_SYSTEM:AddMessage(message)
        elseif d then d(message) end
    end
    Print("|cFFD447Conductor Prog Team Comparison|r")
    Print(self:GetSummaryText(comparison))
    for _, missing in ipairs(comparison.missing or {}) do
        Print(string.format("|cFF5555Missing|r %s (%s)", missing.accountName, missing.role))
    end
    for _, suggestion in ipairs(comparison.suggestions or {}) do
        Print(string.format("|cFFD447Suggested|r %s -> %s", suggestion.missingAccount, suggestion.replacementAccount))
    end
    if #(comparison.missing or {}) == 0 then Print("|c55FF55Saved roster matches the current group.|r") end
    return true
end
