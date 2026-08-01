local SRC = SupportRotationCallouts
local Settings = SRC.Settings
local LHAS = LibHarvensAddonSettings

local function AssignmentChanged(moduleKey)
    if SRC.OnAssignmentSettingsChanged then SRC:OnAssignmentSettingsChanged(moduleKey) end
end

local function ModuleToggleChanged(savedKey, value, displayKey, moduleKey)
    SRC.saved[savedKey] = value
    if not value and SRC.Display then SRC.Display:ClearModuleState(displayKey) end
    AssignmentChanged(moduleKey)
end

local ROLE_ITEMS = {
    { name = "Trial Lead", data = "lead" },
    { name = "Support", data = "support" },
    { name = "Damage Dealer", data = "dd" },
}
local QUEUE_ITEMS = {
    { name = "Current + Next + Me", data = "context" },
    { name = "Full module rotation", data = "full" },
    { name = "Personal alerts only", data = "personal" },
}
local COLOR_ITEMS = {
    { name = "Gold", data = "gold" }, { name = "White", data = "white" },
    { name = "Red", data = "red" }, { name = "Cyan", data = "cyan" },
    { name = "Green", data = "green" },
}
local LAYOUT_ITEMS = { { name = "Vertical", data = "vertical" }, { name = "Horizontal", data = "horizontal" } }
local ALIGN_ITEMS = { { name = "Left", data = "left" }, { name = "Center", data = "center" }, { name = "Right", data = "right" } }
local ORDER_ITEMS = { { name = "Player name first", data = "nameFirst" }, { name = "Action first", data = "actionFirst" } }
local VISIBILITY_ITEMS = {
    { name = "Always", data = "always" },
    { name = "Only In Combat", data = "combat" },
    { name = "Never", data = "never" },
}
local DIAG_ITEMS = { { name = "Off", data = "off" }, { name = "Standard", data = "standard" }, { name = "Developer", data = "developer" } }

local function HasActiveProfile() return SRC.Profiles and SRC.Profiles:GetActive() ~= nil end

local function IsLeadRole() return SRC.saved.displayRole == "lead" end
local function IsSupportRole() return SRC.saved.displayRole == "support" end
local function PersonalDashboardEnabled() return SRC.saved.personalDashboardEnabled == true end
local function RotationDashboardEnabled() return SRC.saved.rotationDashboardEnabled == true end
local function DamageDealerDashboardEnabled() return SRC.saved.damageDealerDashboardEnabled == true end

local function ApplyRoleDefaults(role)
    SRC.saved.rotationDashboardEnabled = false
    SRC.saved.personalDashboardEnabled = false
    SRC.saved.damageDealerDashboardEnabled = false
    SRC.saved.timelineEnabled = true
    SRC.saved.buffsDebuffsDashboardEnabled = true
    SRC.saved.teamCoverageDashboardEnabled = false
    if SRC.TeamCoverageDashboard then SRC.TeamCoverageDashboard:Refresh() end
end

local GroupPlayerItems

local function AddAssignmentRows(panel, labelPrefix, countKey, rotationKey, moduleKey, maximum)
    local rows = {}
    for index = 1, maximum do
        local pos = index
        rows[#rows + 1] = {
            type = LHAS.ST_DROPDOWN,
            label = labelPrefix .. " " .. tostring(pos),
            tooltip = "Choose a player from the current group. Conductor does not require typed account names.",
            items = GroupPlayerItems,
            getFunction = function() return { data = SRC.saved[rotationKey][pos] or "" } end,
            setFunction = function(_,_,data)
                SRC.saved[rotationKey][pos] = SRC:NormalizeAccountName((data and data.data) or "")
                AssignmentChanged(moduleKey)
            end,
            disable = function() return pos > (SRC.saved[countKey] or 1) end,
        }
    end
    panel:AddSettings(rows)
end


local EnsureRaidRoster

local RAID_SLOT_ROLES = { "Tank 1", "Tank 2", "Healer 1", "Healer 2", "DD 1", "DD 2", "DD 3", "DD 4", "DD 5", "DD 6", "DD 7", "DD 8" }

local function RegistryItems(collection, predicate, includeNone)
    local items = {}
    if includeNone then items[#items + 1] = { name = "None", data = "NONE" } end
    if Conductor and Conductor.Registry then
        local entries = Conductor.Registry:GetAll(collection) or {}
        table.sort(entries, function(a,b) return tostring(a.name or a.key) < tostring(b.name or b.key) end)
        for _, entry in ipairs(entries) do
            if not predicate or predicate(entry) then items[#items + 1] = { name = entry.name or entry.key, data = entry.key } end
        end
    end
    return items
end

GroupPlayerItems = function()
    local items = { { name = "Unassigned", data = "" } }
    local seen = {}
    if SRC.Roster and SRC.Roster.Refresh then SRC.Roster:Refresh(true) end
    local rosterAccounts = SRC.Roster and SRC.Roster.accountToUnitTag or {}
    for accountName in pairs(rosterAccounts) do
        local name = tostring(accountName or "")
        if name ~= "" and not seen[name] then
            local player = Conductor and Conductor.Database and Conductor.Database:GetPlayer(name) or nil
            local verified = player and (player.source == "network" or player.source == "local")
            local status = verified and " |c55FF55(Conductor)|r" or " |cAAAAAA(loadout unknown)|r"
            items[#items + 1] = { name = name .. status, data = name }
            seen[name] = true
        end
    end
    table.sort(items, function(a,b)
        if a.data == "" then return true end
        if b.data == "" then return false end
        return tostring(a.name) < tostring(b.name)
    end)
    return items
end

local function ClassItems() return RegistryItems("CLASSES", nil, true) end

local function SlotRoleKey(slotIndex)
    if slotIndex <= 2 then return "TANK" end
    if slotIndex <= 4 then return "HEALER" end
    return "DD"
end

local function EntrySupportsRole(entry, roleKey)
    for _, role in ipairs(entry.roles or {}) do
        if role == roleKey then return true end
    end
    return false
end

local function FivePieceItems(slotIndex)
    local roleKey = SlotRoleKey(slotIndex)
    return RegistryItems("GEAR", function(e)
        return e.setCategory ~= "MYTHIC" and e.setCategory ~= "PASSIVE_BONUS"
            and e.setCategory ~= "ARENA_WEAPON"
            and EntrySupportsRole(e, roleKey)
            and (not e.classKey or roleKey == "DD")
    end, true)
end

local function MonsterItems(slotIndex)
    local roleKey = SlotRoleKey(slotIndex)
    return RegistryItems("MONSTER_SETS", function(e) return EntrySupportsRole(e, roleKey) end, true)
end

local function MythicItems(slotIndex)
    local roleKey = SlotRoleKey(slotIndex)
    return RegistryItems("GEAR", function(e)
        return e.setCategory == "MYTHIC" and EntrySupportsRole(e, roleKey)
    end, true)
end

local function ArenaWeaponItems(slotIndex)
    local roleKey = SlotRoleKey(slotIndex)
    return RegistryItems("GEAR", function(e)
        return e.setCategory == "ARENA_WEAPON" and EntrySupportsRole(e, roleKey)
    end, true)
end

local CLASS_DD_SET = {
    ARCANIST = "SPATTERING_DISJUNCTION",
    NECROMANCER = "CORPSEBURSTER",
}

local function ApplyClassSpecificDDSet(slotIndex, classKey)
    if SlotRoleKey(slotIndex) ~= "DD" then return end
    local slot = EnsureRaidRoster()[slotIndex]
    local setKey = CLASS_DD_SET[classKey]
    for _, classSetKey in pairs(CLASS_DD_SET) do
        if classSetKey ~= setKey then
            if slot.set1 == classSetKey then slot.set1 = "NONE" end
            if slot.set2 == classSetKey then slot.set2 = "NONE" end
        end
    end
    if not setKey or slot.set1 == setKey or slot.set2 == setKey then return end
    if not slot.set1 or slot.set1 == "" or slot.set1 == "NONE" then slot.set1 = setKey
    elseif not slot.set2 or slot.set2 == "" or slot.set2 == "NONE" then slot.set2 = setKey
    else slot.set2 = setKey end
end

EnsureRaidRoster = function()
    if Conductor and Conductor.TrackingConfiguration and not Conductor.TrackingConfiguration.initialized then Conductor.TrackingConfiguration:Initialize() end
    SRC.saved.raidRosterSlots = SRC.saved.raidRosterSlots or {}
    for i=1,12 do
        SRC.saved.raidRosterSlots[i] = SRC.saved.raidRosterSlots[i] or { role=RAID_SLOT_ROLES[i], player="", class="", set1="", set2="", monster="NONE", mythic="NONE", arena="NONE", manualPlayer="", manualSet1="", manualSet2="", manualMonster="", manualMythic="", manualArena="", manualNotes="", source="MANUAL" }
    end
    return SRC.saved.raidRosterSlots
end

local function NormalizeLookupName(value)
    return string.upper(tostring(value or "")):gsub("[^A-Z0-9]", "")
end

local function BuildEquipmentRegistryIndex()
    local index = {}
    if not Conductor or not Conductor.Registry then return index end
    for _, collection in ipairs({ "GEAR", "MONSTER_SETS" }) do
        for _, entry in ipairs(Conductor.Registry:GetAll(collection) or {}) do
            index[NormalizeLookupName(entry.name or entry.key)] = entry
        end
    end
    return index
end

local function AddRoleScore(scores, roleKey, amount, reason)
    scores[roleKey] = (scores[roleKey] or 0) + amount
    if reason then
        scores.reasons = scores.reasons or { TANK={}, HEALER={}, DD={} }
        scores.reasons[roleKey][#scores.reasons[roleKey] + 1] = reason
    end
end

local function ScorePlayerRole(player, savedRole)
    local scores = { TANK=0, HEALER=0, DD=0, reasons={ TANK={}, HEALER={}, DD={} } }
    local declared = string.upper(tostring(player.role or ""))

    -- Manual/saved slot ownership is authoritative when the same player is already assigned.
    if savedRole then AddRoleScore(scores, savedRole, 1000, "saved roster assignment") end

    -- Explicit Conductor combat roles are authoritative. Lead/Support are view roles and require inference.
    if declared == "TANK" then AddRoleScore(scores, "TANK", 900, "Conductor role")
    elseif declared == "HEALER" or declared == "HEAL" then AddRoleScore(scores, "HEALER", 900, "Conductor role")
    elseif declared == "DD" or declared == "DAMAGE" or declared == "DPS" then AddRoleScore(scores, "DD", 900, "Conductor role") end

    local registryIndex = BuildEquipmentRegistryIndex()
    local capabilities = player.capabilities or {}
    for _, setEntry in ipairs(capabilities.gearSets or player.gearSets or {}) do
        local entry = registryIndex[NormalizeLookupName(setEntry.setName)]
        if entry then
            for _, role in ipairs(entry.roles or {}) do
                if role == "TANK" or role == "HEALER" or role == "DD" then
                    AddRoleScore(scores, role, 120, entry.name or setEntry.setName)
                end
            end
            if entry.setCategory == "MYTHIC" or entry.setCategory == "ARENA_WEAPON" then
                for _, role in ipairs(entry.roles or {}) do
                    if role == "TANK" or role == "HEALER" or role == "DD" then AddRoleScore(scores, role, 35) end
                end
            end
        end
    end

    local function ScoreSkillName(name)
        local n = NormalizeLookupName(name)
        if n == "" then return end
        if n:find("COMBATPRAYER",1,true) or n:find("GRANDHEALING",1,true) or n:find("REGENERATION",1,true)
            or n:find("HEALINGSPRINGS",1,true) or n:find("ILLUSTRIOUSHEALING",1,true) then
            AddRoleScore(scores, "HEALER", 80, name)
        end
        if n:find("PIERCEARMOR",1,true) or n:find("PUNCTURE",1,true) or n:find("HEROICSLASH",1,true)
            or n:find("DEFENSIVEPOSTURE",1,true) then
            AddRoleScore(scores, "TANK", 80, name)
        end
    end
    for _, skill in ipairs(capabilities.skills or player.skills or {}) do ScoreSkillName(skill.abilityName or skill.name) end

    -- Weapon slots provide a useful tie-breaker, but never override Conductor or strong gear evidence.
    for _, gear in ipairs(capabilities.gear or player.gear or {}) do
        local name = NormalizeLookupName(gear.itemName)
        if name:find("RESTORATIONSTAFF",1,true) then AddRoleScore(scores, "HEALER", 45, "restoration staff") end
        if name:find("SWORD",1,true) and name:find("SHIELD",1,true) then AddRoleScore(scores, "TANK", 45, "sword and shield") end
        if name:find("INFERNOSTAFF",1,true) or name:find("BOW",1,true) or name:find("GREATSWORD",1,true)
            or name:find("DAGGER",1,true) then AddRoleScore(scores, "DD", 25, "damage weapon") end
    end

    -- ESO's selected Activity Finder role is intentionally only a weak fallback.
    if declared == "UNKNOWN" or declared == "LEAD" or declared == "SUPPORT" then
        local native = string.upper(tostring(player.nativeRole or player.queueRole or ""))
        if native == "TANK" then AddRoleScore(scores, "TANK", 10, "ESO selected role")
        elseif native == "HEALER" or native == "HEAL" then AddRoleScore(scores, "HEALER", 10, "ESO selected role")
        elseif native == "DAMAGE" or native == "DPS" or native == "DD" then AddRoleScore(scores, "DD", 10, "ESO selected role") end
    end

    local bestRole, bestScore = "DD", scores.DD
    if scores.TANK > bestScore then bestRole, bestScore = "TANK", scores.TANK end
    if scores.HEALER > bestScore then bestRole, bestScore = "HEALER", scores.HEALER end
    local confidence = bestScore >= 900 and 100 or bestScore >= 240 and 95 or bestScore >= 120 and 85 or bestScore >= 45 and 65 or bestScore > 0 and 40 or 20
    return bestRole, confidence, scores
end

local function ResolveClassKey(player)
    if player.classKey and player.classKey ~= "" then return player.classKey end
    local byId = { [1]="DRAGONKNIGHT", [2]="SORCERER", [3]="NIGHTBLADE", [4]="WARDEN", [5]="NECROMANCER", [6]="TEMPLAR", [117]="ARCANIST" }
    return byId[tonumber(player.classId)] or player.className or ""
end

local function PopulateSlotFromPlayer(slot, player, slotIndex, inferredRole, confidence)
    slot.role = RAID_SLOT_ROLES[slotIndex]
    slot.player = player.accountName or slot.player or ""
    slot.class = ResolveClassKey(player)
    local capabilities = player.capabilities or {}
    local sets = capabilities.gearSets or player.gearSets or {}
    local regular, monster, mythic, arena = {}, nil, nil, nil
    local registryIndex = BuildEquipmentRegistryIndex()
    for _, setEntry in ipairs(sets) do
        local entry = registryIndex[NormalizeLookupName(setEntry.setName)]
        if entry then
            if Conductor.Registry and Conductor.Registry:Get("MONSTER_SETS", entry.key) then monster = entry.key
            elseif entry.setCategory == "MYTHIC" then mythic = entry.key
            elseif entry.setCategory == "ARENA_WEAPON" then arena = entry.key
            elseif entry.setCategory ~= "PASSIVE_BONUS" then regular[#regular + 1] = entry.key end
        end
    end
    slot.set1, slot.set2 = regular[1] or "NONE", regular[2] or "NONE"
    slot.monster, slot.mythic, slot.arena = monster or "NONE", mythic or "NONE", arena or "NONE"
    ApplyClassSpecificDDSet(slotIndex, slot.class)
    slot.inferredRole = inferredRole
    slot.roleConfidence = confidence
    slot.source = (player.source == "network" or player.source == "local") and "CONDUCTOR VERIFIED" or "GROUP ROSTER / UNKNOWN LOADOUT"
end

local function PopulateSlotFromAccount(slotIndex, accountName)
    local slots = EnsureRaidRoster()
    local slot = slots[slotIndex]
    accountName = tostring(accountName or "")
    if accountName == "" then
        slots[slotIndex] = { role=RAID_SLOT_ROLES[slotIndex], player="", class="", set1="NONE", set2="NONE", monster="NONE", mythic="NONE", arena="NONE", manualPlayer="", manualSet1="", manualSet2="", manualMonster="", manualMythic="", manualArena="", manualNotes="", source="AUTO" }
        return
    end
    local player = Conductor and Conductor.Database and Conductor.Database:GetPlayer(accountName) or nil
    if not player and Conductor and Conductor.Database then player = Conductor.Database:GetOrCreatePlayer(accountName) end
    if player then
        player.accountName = accountName
        local role, confidence = ScorePlayerRole(player, SlotRoleKey(slotIndex))
        PopulateSlotFromPlayer(slot, player, slotIndex, role, confidence)
        slot.source = (player.source == "network" or player.source == "local") and "CONDUCTOR VERIFIED" or "GROUP ROSTER / UNKNOWN LOADOUT"
    else
        slot.player = accountName
        slot.class = ""
        slot.set1, slot.set2 = "NONE", "NONE"
        slot.monster, slot.mythic, slot.arena = "NONE", "NONE", "NONE"
        slot.source = "GROUP ROSTER / UNKNOWN LOADOUT"
    end
end

local function CurrentRosterPlayers()
    local output, seen = {}, {}
    if SRC.Roster and SRC.Roster.Refresh then SRC.Roster:Refresh(true) end
    local rosterAccounts = SRC.Roster and SRC.Roster.accountToUnitTag or {}
    for accountName, unitTag in pairs(rosterAccounts) do
        local player = Conductor and Conductor.Database and Conductor.Database:GetPlayer(accountName) or nil
        if not player and Conductor and Conductor.Database then
            player = Conductor.Database:GetOrCreatePlayer(accountName)
        end
        if player then
            player.accountName = accountName
            if unitTag and DoesUnitExist(unitTag) then
                player.classId = player.classId ~= 0 and player.classId or (GetUnitClassId and GetUnitClassId(unitTag) or 0)
                player.characterName = player.characterName ~= "" and player.characterName or (GetUnitName and GetUnitName(unitTag) or "")
                player.isLocalPlayer = unitTag == "player"
            end
            output[#output + 1] = player
            seen[accountName] = true
        end
    end
    table.sort(output, function(a,b) return tostring(a.accountName) < tostring(b.accountName) end)
    return output
end

local function SyncRaidRosterFromNetwork()
    local slots = EnsureRaidRoster()
    local players = CurrentRosterPlayers()
    local savedRoles = {}
    local savedLoadouts = {}
    for i, slot in ipairs(slots) do
        if slot.player and slot.player ~= "" and (slot.source == "MANUAL" or slot.source == "SAVED PROFILE" or slot.source == "REVIEWED" or slot.source == "SAVED TEAM / UNVERIFIED CURRENT") then
            local key = string.lower(slot.player)
            savedRoles[key] = SlotRoleKey(i)
            savedLoadouts[key] = {
                class=slot.class or "", set1=slot.set1 or "NONE", set2=slot.set2 or "NONE",
                monster=slot.monster or "NONE", mythic=slot.mythic or "NONE", arena=slot.arena or "NONE",
            }
        end
    end

    local analyzed = {}
    for _, player in ipairs(players) do
        local savedRole = savedRoles[string.lower(tostring(player.accountName or ""))]
        local role, confidence, scores = ScorePlayerRole(player, savedRole)
        analyzed[#analyzed + 1] = { player=player, role=role, confidence=confidence, scores=scores }
    end
    table.sort(analyzed, function(a,b)
        if a.confidence ~= b.confidence then return a.confidence > b.confidence end
        return tostring(a.player.accountName) < tostring(b.player.accountName)
    end)

    local buckets = { TANK={}, HEALER={}, DD={} }
    for _, item in ipairs(analyzed) do buckets[item.role][#buckets[item.role] + 1] = item end

    -- Clear stale auto-populated data before rebuilding the 2/2/8 roster.
    for i=1,12 do
        slots[i] = { role=RAID_SLOT_ROLES[i], player="", class="", set1="NONE", set2="NONE", monster="NONE", mythic="NONE", arena="NONE", manualPlayer="", manualSet1="", manualSet2="", manualMonster="", manualMythic="", manualArena="", manualNotes="", source="AUTO" }
    end

    local used = {}
    local function PopulateReviewedSlot(slotIndex, item, roleKey)
        PopulateSlotFromPlayer(slots[slotIndex], item.player, slotIndex, roleKey, item.confidence)
        local source = tostring(item.player.source or "")
        local preserved = savedLoadouts[string.lower(tostring(item.player.accountName or ""))]
        if source ~= "network" and source ~= "local" and preserved then
            local slot = slots[slotIndex]
            slot.class = slot.class ~= "" and slot.class or preserved.class
            slot.set1, slot.set2 = preserved.set1, preserved.set2
            slot.monster, slot.mythic, slot.arena = preserved.monster, preserved.mythic, preserved.arena
            slot.source = "SAVED TEAM / UNVERIFIED CURRENT"
        end
    end
    local function AssignRange(roleKey, firstSlot, lastSlot)
        for slotIndex=firstSlot,lastSlot do
            local item = table.remove(buckets[roleKey], 1)
            if item then PopulateReviewedSlot(slotIndex, item, roleKey); used[item.player.accountName] = true end
        end
    end
    AssignRange("TANK", 1, 2)
    AssignRange("HEALER", 3, 4)
    AssignRange("DD", 5, 12)

    -- Fill any open slots with remaining players by confidence rather than trusting an incorrect queue role.
    local remaining = {}
    for _, item in ipairs(analyzed) do if not used[item.player.accountName] then remaining[#remaining + 1] = item end end
    for i=1,12 do
        if slots[i].player == "" and #remaining > 0 then
            local item = table.remove(remaining, 1)
            PopulateReviewedSlot(i, item, SlotRoleKey(i))
        end
    end

    local assigned = { TANK=0, HEALER=0, DD=0 }
    if SRC.Diagnostics and SRC.Diagnostics.AddFields then
        for i, slot in ipairs(slots) do if slot.player and slot.player ~= "" then assigned[SlotRoleKey(i)] = assigned[SlotRoleKey(i)] + 1 end end
        SRC.Diagnostics:AddFields("RAID_SETUP", "Current group analyzed and roster populated", { players=#players, tanks=assigned.TANK, healers=assigned.HEALER, damage=assigned.DD })
    end
    return slots, players, assigned
end

local function StartRosteredRun()
    local slots = SyncRaidRosterFromNetwork()
    if not slots then return nil end
    local session, errorMessage = Conductor.RosteredRun:Start(slots, {
        trial = SRC.saved.profileDraftInstance or "",
        difficulty = SRC.saved.profileDraftDifficulty or "veteran",
        objective = SRC.saved.profileDraftObjective or "prog",
        strategy = SRC.saved.profileDraftStrategy or "",
    })
    if not session and SRC.Diagnostics then
        SRC.Diagnostics:Add("RAID_SESSION", "Unable to start Rostered Run: " .. tostring(errorMessage or "unknown error"))
    end
    return session
end

local function ProgTeamContext()
    return {
        trial = SRC.saved.profileDraftInstance or "",
        difficulty = SRC.saved.profileDraftDifficulty or "veteran",
        objective = SRC.saved.profileDraftObjective or "prog",
        strategy = SRC.saved.profileDraftStrategy or "",
    }
end

local function SaveProgTeam()
    if not Conductor.TeamProfilesV2 then return nil end
    local profile, errorMessage = Conductor.TeamProfilesV2:SaveFromRoster(
        SRC.saved.progTeamDraftName or "",
        EnsureRaidRoster(),
        ProgTeamContext()
    )
    if not profile then
        if SRC.Diagnostics then SRC.Diagnostics:Add("RAID_SESSION", "Unable to save Prog Team: " .. tostring(errorMessage or "unknown error")) end
        return nil
    end
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then CHAT_SYSTEM:AddMessage("|c55FF55Conductor saved Prog Team:|r " .. tostring(profile.name)) end
    return profile
end

local function OpenProgTeam()
    local profile = Conductor.TeamProfilesV2 and Conductor.TeamProfilesV2:GetSelected()
    if not profile or not Conductor.ProgTeamRun then return nil end
    SRC.saved.progTeamDraftName = profile.name or SRC.saved.progTeamDraftName
    if Conductor.TeamProfilesV2.ApplyToPlayerSetup then
        Conductor.TeamProfilesV2:ApplyToPlayerSetup(profile)
    end
    local comparison, errorMessage = Conductor.ProgTeamRun:Open(profile, EnsureRaidRoster())
    if not comparison then
        if SRC.Diagnostics then SRC.Diagnostics:Add("RAID_SESSION", "Unable to open Prog Team: " .. tostring(errorMessage or "unknown error")) end
        return nil
    end
    Conductor.ProgTeamRun:PrintComparison(comparison)
    return comparison
end

local function ShowProgTeamComparison()
    if Conductor.ProgTeamRun then Conductor.ProgTeamRun:PrintComparison() end
end

local function ApplyProgTeamSuggestions()
    if not Conductor.ProgTeamRun then return 0 end
    local count = Conductor.ProgTeamRun:ApplySuggestions(EnsureRaidRoster())
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(string.format("|cFFD447Conductor applied %d suggested Prog Team replacement(s).|r", count))
    end
    return count
end

local function StartProgTeamRun()
    local profile = Conductor.TeamProfilesV2 and Conductor.TeamProfilesV2:GetSelected()
    if not profile or not Conductor.ProgTeamRun then return nil end
    local session, errorMessage = Conductor.ProgTeamRun:Start(profile, EnsureRaidRoster(), ProgTeamContext())
    if not session then
        if SRC.Diagnostics then SRC.Diagnostics:Add("RAID_SESSION", "Unable to start Prog Team Run: " .. tostring(errorMessage or "unknown error")) end
        return nil
    end
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(string.format("|c55FF55Conductor started Prog Team Run:|r %s (%d players)", tostring(profile.name or "Prog Team"), #(session.players or {})))
    end
    return session
end

local function DeleteProgTeam()
    if Conductor.TeamProfilesV2 and Conductor.TeamProfilesV2:DeleteSelected() then
        if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then CHAT_SYSTEM:AddMessage("|cFFD447Conductor deleted the selected Prog Team.|r") end
        return true
    end
    return false
end

local function ShareRaidSession()
    if not Conductor.SessionSharing then return false end
    local shared, errorMessage = Conductor.SessionSharing:ShareActiveSession()
    if not shared and SRC.Diagnostics then SRC.Diagnostics:Add("RAID_SESSION", "Unable to share Raid Session: " .. tostring(errorMessage or "unknown error")) end
    if not shared and CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then CHAT_SYSTEM:AddMessage("|cFF5555Conductor could not share the Raid Session:|r " .. tostring(errorMessage or "unknown error")) end
    return shared
end

local function AcceptRaidSessionInvitation()
    return Conductor.SessionSharing and Conductor.SessionSharing:AcceptPendingInvitation() or false
end

local function DeclineRaidSessionInvitation()
    return Conductor.SessionSharing and Conductor.SessionSharing:DeclinePendingInvitation() or false
end

local function ShowRaidSessionSynchronization()
    if Conductor.SessionSharing then Conductor.SessionSharing:PrintSynchronizationSummary() end
end

local function AddRaidRosterRows(panel)
    panel:AddSettings({
        { type=LHAS.ST_LABEL, label="|cFFD447Team Review|r" },
        { type=LHAS.ST_LABEL, label="Conductor scans the current group automatically. Players running Conductor contribute verified gear, skills, ultimates, and support capabilities. Other group members remain visible with unknown loadouts." },
        { type=LHAS.ST_BUTTON, buttonText="REFRESH CURRENT GROUP", tooltip="Rescan the current group, infer the 2 Tank / 2 Healer / 8 Damage Dealer layout, and import all available Conductor network data.", clickHandler=function() SyncRaidRosterFromNetwork(); if SRC.Notify then SRC:Notify("Current group refreshed.") end end },
    })
    for index=1,12 do
        local pos=index
        panel:AddSettings({
            { type=LHAS.ST_LABEL, label="|cFFD447" .. RAID_SLOT_ROLES[pos] .. "|r" },
            { type=LHAS.ST_DROPDOWN, label="Current Group Player", items=GroupPlayerItems, getFunction=function() return {data=EnsureRaidRoster()[pos].player or ""} end, setFunction=function(_,_,data) PopulateSlotFromAccount(pos, (data and data.data) or "") end },
            { type=LHAS.ST_DROPDOWN, label="Class", items=ClassItems, getFunction=function() return {data=EnsureRaidRoster()[pos].class or ""} end, setFunction=function(_,_,data) local classKey=(data and data.data) or ""; EnsureRaidRoster()[pos].class=classKey; ApplyClassSpecificDDSet(pos,classKey); EnsureRaidRoster()[pos].source="REVIEWED" end },
        })
    end
    panel:AddSettings({
        { type=LHAS.ST_BUTTON, buttonText="OPEN VERIFIED TEAM COVERAGE", tooltip="Review verified providers, missing responsibilities, and unknown capability without entering loadouts manually.", clickHandler=function() if SRC.Diagnostics and SRC.Diagnostics.ToggleTeamIntelligenceSummary then SRC.Diagnostics:ToggleTeamIntelligenceSummary() end end },
    })
end

local function AddEffectToggleRows(panel, effectType, heading)
    local rows = { { type=LHAS.ST_LABEL, label="|cFFD447" .. heading .. "|r" } }
    local effects = {}
    for _, effect in ipairs(Conductor.Registry and Conductor.Registry:GetAll("EFFECTS") or {}) do
        if effect.effectType == effectType then effects[#effects+1] = effect end
    end
    table.sort(effects, function(a,b) return tostring(a.name or a.key) < tostring(b.name or b.key) end)
    for _, effect in ipairs(effects) do
        local key=effect.key
        rows[#rows+1] = { type=LHAS.ST_CHECKBOX, label=effect.name or key, tooltip=(effect.whyItMatters or "") .. " This choice controls what appears on the Buffs & Debuffs Dashboard.", getFunction=function() return not Conductor.TrackingConfiguration or Conductor.TrackingConfiguration:IsEffectEnabled(key) end, setFunction=function(v) if Conductor.TrackingConfiguration then Conductor.TrackingConfiguration:SetEffectEnabled(key,v) end end }
    end
    panel:AddSettings(rows)
end

local function AddRegistryToggleRows(panel, collection, heading, predicate)
    local rows = { { type=LHAS.ST_LABEL, label="|cFFD447" .. heading .. "|r" } }
    for _, entry in ipairs(Conductor.Registry and Conductor.Registry:GetAll(collection) or {}) do
        if not predicate or predicate(entry) then
            local key=entry.key
            rows[#rows+1] = { type=LHAS.ST_CHECKBOX, label=entry.name or key, getFunction=function() return not Conductor.TrackingConfiguration or Conductor.TrackingConfiguration:IsRegistryEntryEnabled(collection,key) end, setFunction=function(v) if Conductor.TrackingConfiguration then Conductor.TrackingConfiguration:SetRegistryEntryEnabled(collection,key,v) end end }
        end
    end
    local headingRow = table.remove(rows, 1)
    table.sort(rows, function(a,b) return tostring(a.label) < tostring(b.label) end)
    table.insert(rows, 1, headingRow)
    panel:AddSettings(rows)
end

local function AddUltimateModule(panel, title, enabledKey, countKey, rotationKey, moduleKey, displayKey, prefix)
    panel:AddSettings({
        { type = LHAS.ST_LABEL, label = "|cFFD447" .. title .. "|r" },
        { type = LHAS.ST_LABEL, label = "|cFFD447Coordinate " .. title .. " assignments, readiness, and timing through the Personalized Timeline.|r" },
        { type = LHAS.ST_CHECKBOX, label = "Enable " .. title .. " module", tooltip = "Show and coordinate this module during combat.", getFunction=function() return SRC.saved[enabledKey] ~= false end, setFunction=function(v) ModuleToggleChanged(enabledKey,v,displayKey,moduleKey) end },
        { type = LHAS.ST_SLIDER, label = "Number of players", tooltip = "Select how many players participate in this rotation.", min=1,max=4,step=1, getFunction=function() return SRC.saved[countKey] or 1 end, setFunction=function(v) SRC.saved[countKey]=v; AssignmentChanged(moduleKey) end },
    })
    AddAssignmentRows(panel, prefix, countKey, rotationKey, moduleKey, 4)
end


local function Notify(message)
    if SRC.Notify then SRC:Notify(message)
    elseif ZO_Alert then pcall(ZO_Alert, UI_ALERT_CATEGORY_ALERT, nil, tostring(message or "Conductor updated.")) end
end

local function ClearCurrentTeam()
    local slots = EnsureRaidRoster()
    for i=1,12 do
        slots[i] = { role=RAID_SLOT_ROLES[i], player="", class="", set1="NONE", set2="NONE", monster="NONE", mythic="NONE", arena="NONE", manualPlayer="", manualSet1="", manualSet2="", manualMonster="", manualMythic="", manualArena="", manualNotes="", source="MANUAL" }
    end
    SRC.saved.progTeamDraftName = ""
    SRC.saved.progTeamComparison = nil
    Notify("New blank team created.")
end

local function ImportCurrentGroupToTeam()
    SyncRaidRosterFromNetwork()
    Notify("Current group imported into Team Review.")
end

local function PlanningModeItems()
    return { {name="Recommended",data="RECOMMENDED"}, {name="Assisted",data="ASSISTED"}, {name="Custom",data="CUSTOM"} }
end
local function TrashFormatItems()
    return { {name="Recommended",data="RECOMMENDED"}, {name="4 Teams of 3",data="FOUR_TEAMS_OF_THREE"}, {name="3 Teams of 4",data="THREE_TEAMS_OF_FOUR"}, {name="Custom",data="CUSTOM"} }
end
local function StrategyItems()
    return Conductor.RaidStrategies and Conductor.RaidStrategies:GetItems(SRC.saved.profileDraftInstance, SRC.saved.profileDraftDifficulty, SRC.saved.profileDraftObjective) or {{name="Recommended Baseline",data=""}}
end
local function CompileCurrentRaidPlan(session)
    if not session or not Conductor.RaidPlanCompiler then return nil end
    return Conductor.RaidPlanCompiler:Compile(session, { strategyId=SRC.saved.raidPlanStrategyId, planningMode=SRC.saved.raidPlanPlanningMode, trashTeamFormat=SRC.saved.raidPlanTrashTeamFormat })
end

local function PrepareCurrentRaid(resetAssignments)
    if resetAssignments == true and SRC.ResetRaidAssignments then
        SRC:ResetRaidAssignments("prepare current raid")
    end
    SyncRaidRosterFromNetwork()
    local session = StartRosteredRun()
    local plan = session and CompileCurrentRaidPlan(session) or nil
    SRC.saved.teamSharingEnabled = plan ~= nil
    if plan then
        Notify(string.format("Raid Plan prepared. %d assignment(s) need review.", #(plan.unresolved or {})))
    else
        Notify("Conductor could not prepare the current group.")
    end
    return session
end

local function ShareCurrentRaid()
    local session = PrepareCurrentRaid(false)
    if not session then return false end
    SRC.saved.teamSharingEnabled = true
    local ok = ShareRaidSession()
    if ok then Notify("Raid Plan transfer started. Check Plan Status for delivery and acceptance.") end
    return ok
end

function Settings:RegisterPanel()
    if self.registered then return true end
    if not LHAS then self:AddDiagnostic("LibHarvensAddonSettings unavailable"); return false end
    local panel = LHAS:AddAddon(SRC.displayName, { allowRefresh = true })
    if not panel then self:AddDiagnostic("Unable to create console settings panel"); return false end

    -- Credits are always visible at the top of the main Conductor page.
    panel:AddSettings({
        { type = LHAS.ST_LABEL, label = "|cFFD447Created and maintained by BMGXSANCHO|r" },
        { type = LHAS.ST_LABEL, label = "Questions, bugs, or suggestions: send in-game mail to |cFFD447@BMGXSANCHO|r" },
        { type = LHAS.ST_BUTTON, label = "How-to-use-me", buttonText = "How-to-use-me", tooltip = "Open the beginner-friendly Conductor guide.", clickHandler=function() if SRC.HowToUseMe then SRC.HowToUseMe:Show() end end },
    })

    panel:AddSettings({
        { type = LHAS.ST_SECTION, label = "General" },
        { type = LHAS.ST_CHECKBOX, label = "Enable Conductor", tooltip = "Enable or disable Conductor without removing your saved Raid Setups and preferences.", getFunction=function() return SRC.saved.enabled end, setFunction=function(v) SRC:SetEnabled(v) end },
        { type = LHAS.ST_DROPDOWN, label = "User role", tooltip = "Choose how the Personalized Timeline filters encounter events. Trial Leads see the complete command timeline. Supports and Damage Dealers see role-relevant assignments, mechanics, and shared events.", items=function() return ROLE_ITEMS end, getFunction=function() return {data=SRC.saved.displayRole or "lead"} end, setFunction=function(_,_,data)
            SRC.saved.displayRole=data.data
            ApplyRoleDefaults(data.data)
                    Settings:ApplyDisplayMode()
            Settings:ApplyDisplaySettings()
        end },
        { type = LHAS.ST_DROPDOWN, label = "Dashboard visibility", tooltip = "Choose when persistent dashboards are shown. Preview buttons always work from settings.", items=function() return VISIBILITY_ITEMS end, getFunction=function() return {data=SRC.saved.dashboardVisibility or "combat"} end, setFunction=function(_,_,data) SRC.saved.dashboardVisibility=data.data; Settings:ApplyDisplayMode() end },
        { type = LHAS.ST_SLIDER, label = "Dashboard background opacity", tooltip = "Adjust the background opacity of Conductor dashboards.", min=10,max=90,step=5, getFunction=function() return zo_round((SRC.saved.dashboardBackgroundOpacity or 0.38) * 100) end, setFunction=function(v) SRC.saved.dashboardBackgroundOpacity=zo_clamp(v/100,0.10,0.90); Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_LABEL, label = "Detected PlayStation account: " .. tostring(GetDisplayName()) },
        { type = LHAS.ST_CHECKBOX, label = "Allow trial dummy testing", tooltip = "Test Conductor on a Trial Target Dummy before using it in live group content.", getFunction=function() return SRC.saved.dummyMode end, setFunction=function(v) SRC.saved.dummyMode=v end },
    })


    panel:AddSettings({
        { type = LHAS.ST_SECTION, label = "Group Coverage" },
        { type = LHAS.ST_LABEL, label = "|cFFD447Open one coverage table at a time. The Conductor menu closes while the table is open. Use the standard L2/R2 page controls and Circle back control.|r" },
        { type = LHAS.ST_SLIDER, label = "Group Coverage scale", min=0.60,max=1.10,step=0.05, getFunction=function() return SRC.saved.teamCoverageScale or 0.85 end, setFunction=function(v) SRC.saved.teamCoverageScale=v; if SRC.TeamCoverageDashboard then SRC.TeamCoverageDashboard:Refresh() end end },
        { type = LHAS.ST_SLIDER, label = "Group Coverage horizontal position", min=-700,max=700,step=10, getFunction=function() return SRC.saved.teamCoverageOffsetX or 0 end, setFunction=function(v) SRC.saved.teamCoverageOffsetX=v; if SRC.TeamCoverageDashboard and SRC.TeamCoverageDashboard.control then SRC.TeamCoverageDashboard.control:ClearAnchors(); SRC.TeamCoverageDashboard.control:SetAnchor(CENTER,GuiRoot,CENTER,v,SRC.saved.teamCoverageOffsetY or 0) end end },
        { type = LHAS.ST_SLIDER, label = "Group Coverage vertical position", min=-400,max=400,step=10, getFunction=function() return SRC.saved.teamCoverageOffsetY or 0 end, setFunction=function(v) SRC.saved.teamCoverageOffsetY=v; if SRC.TeamCoverageDashboard and SRC.TeamCoverageDashboard.control then SRC.TeamCoverageDashboard.control:ClearAnchors(); SRC.TeamCoverageDashboard.control:SetAnchor(CENTER,GuiRoot,CENTER,SRC.saved.teamCoverageOffsetX or 0,v) end end },

        { type = LHAS.ST_LABEL, label = "|cFFD447Buffs Table|r" },
        { type = LHAS.ST_BUTTON, buttonText = "OPEN BUFFS TABLE", clickHandler=function() if SRC.TeamCoverageDashboard then SRC.TeamCoverageDashboard:ToggleCategory("BUFF") end end },

        { type = LHAS.ST_LABEL, label = "|cFFD447Debuffs Table|r" },
        { type = LHAS.ST_BUTTON, buttonText = "OPEN DEBUFFS TABLE", clickHandler=function() if SRC.TeamCoverageDashboard then SRC.TeamCoverageDashboard:ToggleCategory("DEBUFF") end end },

        { type = LHAS.ST_LABEL, label = "|cFFD447Other Effects|r" },
        { type = LHAS.ST_BUTTON, buttonText = "OPEN OTHER EFFECTS", clickHandler=function() if SRC.TeamCoverageDashboard then SRC.TeamCoverageDashboard:ToggleCategory("OTHER") end end },
        { type = LHAS.ST_BUTTON, buttonText = "REFRESH GROUP COVERAGE", clickHandler=function() if SRC.TeamCoverageDashboard and SRC.TeamCoverageDashboard.ForceRefresh then SRC.TeamCoverageDashboard:ForceRefresh() elseif SRC.TeamIntelligenceEngine then SRC.TeamIntelligenceEngine:BuildCurrentTeam() end end },
        { type = LHAS.ST_LABEL, label = "|cFFD447Raid Setup Recommendation|r" },
        { type = LHAS.ST_LABEL, label = "Review the current grouped team and the important buffs, debuffs, and other effects Conductor cannot currently find." },
        { type = LHAS.ST_BUTTON, buttonText = "OPEN RAID SETUP RECOMMENDATION", clickHandler=function() if SRC.TeamCoverageDashboard and SRC.TeamCoverageDashboard.ShowRecommendations then SRC.TeamCoverageDashboard:ShowRecommendations() end end },
    })

    panel:AddSettings({
        { type = LHAS.ST_SECTION, label = "Control Center" },
        { type = LHAS.ST_LABEL, label = "|cFFD447CONTROL CENTER  >  TIMELINE|r" },
        { type = LHAS.ST_CHECKBOX, label = "Show Personalized Timeline", tooltip = "Future events move from right to left across the fixed NOW line. Player actions report timing accuracy; encounter mechanics remain white.", getFunction=function() return SRC.saved.timelineEnabled ~= false end, setFunction=function(v) SRC.saved.timelineEnabled=v; if not v and SRC.TimelineDisplay and SRC.TimelineDisplay.window then SRC.TimelineDisplay.window:SetHidden(true) end end },
        { type = LHAS.ST_BUTTON, buttonText = "Preview Timeline", tooltip = "Preview upcoming events and green, yellow, and red execution accuracy.", clickHandler=function() if SRC.TimelineDisplay then SRC.TimelineDisplay:Preview() end end },
        { type = LHAS.ST_SLIDER, label = "Timeline width", tooltip = "Adjust horizontal space within safe screen boundaries. Event labels remain fully contained inside the Timeline.", min=600,max=1050,step=25,unit=" px", getFunction=function() return SRC.saved.timelineWidth or 900 end, setFunction=function(v) SRC.saved.timelineWidth=v; if SRC.TimelineDisplay then SRC.TimelineDisplay:ApplySettings() end end },
        { type = LHAS.ST_SLIDER, label = "Timeline height", tooltip = "Adjust vertical space while preserving the event and assigned-player stack inside the Timeline.", min=95,max=175,step=5,unit=" px", getFunction=function() return SRC.saved.timelineHeight or 160 end, setFunction=function(v) SRC.saved.timelineHeight=v; if SRC.TimelineDisplay then SRC.TimelineDisplay:ApplySettings() end end },
        { type = LHAS.ST_SLIDER, label = "Timeline scale", tooltip = "Scale is intentionally limited so the Timeline cannot become larger than the approved default or too small to read.", min=80,max=100,step=5,unit="%", getFunction=function() return zo_round((SRC.saved.timelineScale or 1)*100) end, setFunction=function(v) SRC.saved.timelineScale=v/100; if SRC.TimelineDisplay then SRC.TimelineDisplay:ApplySettings() end end },
        { type = LHAS.ST_SLIDER, label = "Timeline horizontal position", min=-1600,max=1600,step=10, getFunction=function() return SRC.saved.timelineOffsetX or 0 end, setFunction=function(v) SRC.saved.timelineOffsetX=v; if SRC.TimelineDisplay then SRC.TimelineDisplay:ApplySettings() end end },
        { type = LHAS.ST_SLIDER, label = "Timeline vertical position", min=-900,max=900,step=10, getFunction=function() return SRC.saved.timelineOffsetY or 260 end, setFunction=function(v) SRC.saved.timelineOffsetY=v; if SRC.TimelineDisplay then SRC.TimelineDisplay:ApplySettings() end end },
    })

    panel:AddSettings({
        { type = LHAS.ST_LABEL, label = "|cFFD447CONTROL CENTER  >  BUFFS & DEBUFFS DASHBOARD|r" },
        { type = LHAS.ST_LABEL, label = "|cFFD447Monitor important raid buffs and debuffs at a glance while the Timeline handles active coordination.|r" },
        { type = LHAS.ST_CHECKBOX, label = "Show Buffs & Debuffs Dashboard", getFunction=function() return SRC.saved.buffsDebuffsDashboardEnabled ~= false end, setFunction=function(v) SRC.saved.buffsDebuffsDashboardEnabled=v; Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_BUTTON, buttonText = "Preview Buffs & Debuffs Dashboard", tooltip = "Play a short simulated encounter showing live timers and group recipient blocks.", clickHandler=function() if SRC.Display then SRC.Display:PreviewBuffsDebuffs() end end },
        { type = LHAS.ST_CHECKBOX, label = "Show Buffs & Debuffs Dashboard title", getFunction=function() return SRC.saved.buffsDebuffsShowTitle ~= false end, setFunction=function(v) SRC.saved.buffsDebuffsShowTitle=v; Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_SLIDER, label = "Buffs & Debuffs Dashboard scale", min=60,max=160,step=5,unit="%", getFunction=function() return zo_round((SRC.saved.buffsDebuffsScale or 0.9)*100) end, setFunction=function(v) SRC.saved.buffsDebuffsScale=v/100; Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_SLIDER, label = "Buffs & Debuffs Dashboard horizontal position", min=-1600,max=1600,step=10, getFunction=function() return SRC.saved.buffsDebuffsOffsetX or 430 end, setFunction=function(v) SRC.saved.buffsDebuffsOffsetX=v; Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_SLIDER, label = "Buffs & Debuffs Dashboard vertical position", min=-900,max=900,step=10, getFunction=function() return SRC.saved.buffsDebuffsOffsetY or -120 end, setFunction=function(v) SRC.saved.buffsDebuffsOffsetY=v; Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_LABEL, label = "|cFFD447Buffs & Debuffs Dashboard Placement|r" },
        { type = LHAS.ST_BUTTON, buttonText = "Move Buffs & Debuffs Dashboard up", clickHandler=function() Settings:NudgeBuffsDebuffs(0,-10) end },
        { type = LHAS.ST_BUTTON, buttonText = "Move Buffs & Debuffs Dashboard down", clickHandler=function() Settings:NudgeBuffsDebuffs(0,10) end },
        { type = LHAS.ST_BUTTON, buttonText = "Move Buffs & Debuffs Dashboard left", clickHandler=function() Settings:NudgeBuffsDebuffs(-10,0) end },
        { type = LHAS.ST_BUTTON, buttonText = "Move Buffs & Debuffs Dashboard right", clickHandler=function() Settings:NudgeBuffsDebuffs(10,0) end },
        { type = LHAS.ST_BUTTON, buttonText = "Reset Buffs & Debuffs Dashboard position", clickHandler=function() Settings:ResetBuffsDebuffsPosition() end },
    })



    panel:AddSettings({
        { type = LHAS.ST_LABEL, label = "|cFFD447CONTROL CENTER  >  CALLOUTS|r" },
        { type = LHAS.ST_CHECKBOX, label = "Show role-based callouts", tooltip = "Trial Leads see all callouts. Supports see support callouts. Damage Dealers see only damage-dealer callouts.", getFunction=function() return SRC.saved.calloutsEnabled ~= false end, setFunction=function(v) SRC.saved.calloutsEnabled=v; Notify(v and "Callouts enabled." or "Callouts disabled.") end },
        { type = LHAS.ST_LABEL, label = "Callouts are timed from the same active Timeline event. When an event reaches the NOW line, the matching role callout is shown." },

        { type = LHAS.ST_LABEL, label = "|cFFD447Trial Lead Callouts|r" },
        { type = LHAS.ST_BUTTON, buttonText = "PREVIEW TRIAL LEAD CALLOUTS", clickHandler=function() if SRC.Display and SRC.Display.PreviewLeadCallout then SRC.Display:PreviewLeadCallout() end end },
        { type = LHAS.ST_SLIDER, label = "Trial Lead callout size", min=60,max=160,step=5,unit="%", getFunction=function() return zo_round((SRC.saved.calloutScale or 1.0)*100) end, setFunction=function(v) SRC.saved.calloutScale=v/100; Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_SLIDER, label = "Trial Lead horizontal position", min=-1600,max=1600,step=10, getFunction=function() return SRC.saved.calloutOffsetX or 0 end, setFunction=function(v) SRC.saved.calloutOffsetX=v; Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_SLIDER, label = "Trial Lead vertical position", min=-900,max=900,step=10, getFunction=function() return SRC.saved.calloutOffsetY or -80 end, setFunction=function(v) SRC.saved.calloutOffsetY=v; Settings:ApplyDisplaySettings() end },

        { type = LHAS.ST_LABEL, label = "|cFFD447Support Callouts|r" },
        { type = LHAS.ST_BUTTON, buttonText = "PREVIEW SUPPORT CALLOUTS", clickHandler=function() if SRC.Display and SRC.Display.PreviewPersonal then SRC.Display:PreviewPersonal() end end },
        { type = LHAS.ST_SLIDER, label = "Support callout size", min=60,max=160,step=5,unit="%", getFunction=function() return zo_round((SRC.saved.personalScale or 1.0)*100) end, setFunction=function(v) SRC.saved.personalScale=v/100; Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_SLIDER, label = "Support horizontal position", min=-1600,max=1600,step=10, getFunction=function() return SRC.saved.personalOffsetX or 0 end, setFunction=function(v) SRC.saved.personalOffsetX=v; Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_SLIDER, label = "Support vertical position", min=-900,max=900,step=10, getFunction=function() return SRC.saved.personalOffsetY or 60 end, setFunction=function(v) SRC.saved.personalOffsetY=v; Settings:ApplyDisplaySettings() end },

        { type = LHAS.ST_LABEL, label = "|cFFD447Damage Dealer Callouts|r" },
        { type = LHAS.ST_BUTTON, buttonText = "PREVIEW DD CALLOUTS", clickHandler=function() if SRC.Display and SRC.Display.PreviewDamageDealerDashboard then SRC.Display:PreviewDamageDealerDashboard() end end },
        { type = LHAS.ST_SLIDER, label = "DD callout size", min=60,max=160,step=5,unit="%", getFunction=function() return zo_round((SRC.saved.damageDealerScale or 1.0)*100) end, setFunction=function(v) SRC.saved.damageDealerScale=v/100; Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_SLIDER, label = "DD horizontal position", min=-1600,max=1600,step=10, getFunction=function() return SRC.saved.damageDealerOffsetX or 0 end, setFunction=function(v) SRC.saved.damageDealerOffsetX=v; Settings:ApplyDisplaySettings() end },
        { type = LHAS.ST_SLIDER, label = "DD vertical position", min=-900,max=900,step=10, getFunction=function() return SRC.saved.damageDealerOffsetY or -80 end, setFunction=function(v) SRC.saved.damageDealerOffsetY=v; Settings:ApplyDisplaySettings() end },
    })

    panel:AddSettings({
        { type = LHAS.ST_SECTION, label = "Raid Setup" },
        { type = LHAS.ST_LABEL, label = "|cFFD447Prepare, review, optionally save, and share the current raid with as few steps as possible.|r" },
        { type = LHAS.ST_LABEL, label = "|cFFD4471. Encounter|r" },
        { type = LHAS.ST_DROPDOWN, label = "Trial or Dungeon", items=function() return SRC.Profiles:GetInstanceItems(SRC.saved.profileDraftCategory or "trial") end, getFunction=function() return {data=SRC.saved.profileDraftInstance or ""} end, setFunction=function(_,_,data)
            local nextValue = data.data
            if SRC.saved.profileDraftInstance ~= nextValue and SRC.ResetRaidAssignments then SRC:ResetRaidAssignments("trial changed") end
            SRC.saved.profileDraftInstance=nextValue
        end },
        { type = LHAS.ST_DROPDOWN, label = "Difficulty", items=function() return SRC.Profiles:GetDifficultyItems() end, getFunction=function() return {data=SRC.saved.profileDraftDifficulty or "veteran"} end, setFunction=function(_,_,data)
            local nextValue = data.data
            if SRC.saved.profileDraftDifficulty ~= nextValue and SRC.ResetRaidAssignments then SRC:ResetRaidAssignments("difficulty changed") end
            SRC.saved.profileDraftDifficulty=nextValue
        end },
        { type = LHAS.ST_DROPDOWN, label = "Run Objective", items=function() return SRC.Profiles:GetObjectiveItems() end, getFunction=function() return {data=SRC.saved.profileDraftObjective or "prog"} end, setFunction=function(_,_,data) SRC.saved.profileDraftObjective=data.data end },
        { type = LHAS.ST_DROPDOWN, label = "Planning Mode", items=PlanningModeItems, getFunction=function() return {data=SRC.saved.raidPlanPlanningMode or "RECOMMENDED"} end, setFunction=function(_,_,data) SRC.saved.raidPlanPlanningMode=data.data end },
        { type = LHAS.ST_DROPDOWN, label = "Recommended Strategy", items=StrategyItems, getFunction=function() return {data=SRC.saved.raidPlanStrategyId or ""} end, setFunction=function(_,_,data) SRC.saved.raidPlanStrategyId=data.data or "" end },
        { type = LHAS.ST_DROPDOWN, label = "Trash Ultimate Teams", items=TrashFormatItems, getFunction=function() return {data=SRC.saved.raidPlanTrashTeamFormat or "RECOMMENDED"} end, setFunction=function(_,_,data) SRC.saved.raidPlanTrashTeamFormat=data.data end },
        { type = LHAS.ST_LABEL, label = "|cFFD4472. Prepare Raid Plan|r" },
        { type = LHAS.ST_BUTTON, buttonText = "PREPARE RAID PLAN", tooltip = "Scan the current group, resolve available responsibilities, build trash ultimate teams, and prepare the selected encounter strategy.", clickHandler=function() PrepareCurrentRaid(true) end },
        { type = LHAS.ST_LABEL, label = "|cFFD4473. Optional Saved Team|r" },
        { type = LHAS.ST_EDIT, label = "Team Name", tooltip = "Only needed when you want to preserve this reviewed team for future raids.", getFunction=function() return SRC.saved.progTeamDraftName or "" end, setFunction=function(v) SRC.saved.progTeamDraftName=v or "" end },
        { type = LHAS.ST_BUTTON, buttonText = "SAVE CURRENT TEAM SETTINGS", tooltip = "Save or update the selected team using the current roster, verified loadouts, role placement, and encounter context.", clickHandler=function() local profile=SaveProgTeam(); if profile then Notify("Team settings saved.") end end },
        { type = LHAS.ST_DROPDOWN, label = "Saved Team", items=function() return Conductor.TeamProfilesV2 and Conductor.TeamProfilesV2:GetItems() or {{name="No saved teams",data=""}} end, getFunction=function() return {data=SRC.saved.selectedProgTeamId or ""} end, setFunction=function(_,_,data) if Conductor.TeamProfilesV2 then local id=(data and data.data) or ""; Conductor.TeamProfilesV2:SetSelected(id); local profile=Conductor.TeamProfilesV2:GetSelected(); SRC.saved.progTeamDraftName=profile and (profile.name or "") or "" end end },
        { type = LHAS.ST_BUTTON, buttonText = "LOAD SAVED TEAM", tooltip = "Load a saved team and compare it with the current group.", clickHandler=function() OpenProgTeam(); Notify("Saved team loaded for review.") end, disable=function() return not (Conductor.TeamProfilesV2 and Conductor.TeamProfilesV2:GetSelected()) end },
        { type = LHAS.ST_BUTTON, buttonText = "DELETE SAVED TEAM", clickHandler=function() DeleteProgTeam(); Notify("Saved team deleted.") end, disable=function() return not (Conductor.TeamProfilesV2 and Conductor.TeamProfilesV2:GetSelected()) end },
        { type = LHAS.ST_LABEL, label = "|cFFD4474. Share Raid Plan|r" },
        { type = LHAS.ST_LABEL, label = "Conductor shares the selected strategy, assignments, trash ultimate teams, and boss plan. Each recipient builds their personalized session locally." },
        { type = LHAS.ST_BUTTON, buttonText = "SHARE RAID PLAN", tooltip = "Prepare if necessary, then send the active Raid Plan to current group members running Conductor.", clickHandler=function() ShareCurrentRaid() end },
        { type = LHAS.ST_BUTTON, buttonText = "SHOW PLAN STATUS", tooltip = "Show accepted, pending, declined, disconnected, incompatible, and non-Conductor players in chat.", clickHandler=function() ShowRaidSessionSynchronization() end },
        { type = LHAS.ST_BUTTON, buttonText = "ACCEPT RECEIVED PLAN", tooltip = "Fallback control when the native invitation dialog is unavailable.", clickHandler=function() AcceptRaidSessionInvitation() end, disable=function() return not (Conductor.SessionTransfer and Conductor.SessionTransfer.pendingValidated) end },
        { type = LHAS.ST_BUTTON, buttonText = "DECLINE RECEIVED PLAN", clickHandler=function() DeclineRaidSessionInvitation() end, disable=function() return not (Conductor.SessionTransfer and Conductor.SessionTransfer.pendingValidated) end },
        { type = LHAS.ST_BUTTON, buttonText = "CANCEL ACTIVE SHARE", clickHandler=function() if Conductor.SessionSharing then Conductor.SessionSharing:CancelShare() end end, disable=function() return not (Conductor.SessionTransfer and Conductor.SessionTransfer.outgoing and Conductor.SessionTransfer.outgoing.state ~= "SENT") end },
    })

    AddRaidRosterRows(panel)

    panel:AddSettings({
        { type = LHAS.ST_LABEL, label = "|cFFD447Raid Plan Assignments|r" },
        { type = LHAS.ST_LABEL, label = "|cFFD447Conductor fills recommended assignments automatically. Use this section only when the Trial Lead wants to override the suggested plan.|r" },
        { type = LHAS.ST_EDIT, label = "Encounter Assignment Name", tooltip = "Use a boss or encounter name, such as Oaxiltso, Bahsei, or Xalvakka.", getFunction=function() return SRC.saved.encounterAssignmentName or "" end, setFunction=function(v) SRC.saved.encounterAssignmentName=v or "" end },
        { type = LHAS.ST_BUTTON, buttonText = "SAVE ASSIGNMENTS FOR THIS ENCOUNTER", clickHandler=function() if Conductor.EncounterAssignmentProfiles then Conductor.EncounterAssignmentProfiles:SaveCurrent() end end },
        { type = LHAS.ST_DROPDOWN, label = "Saved Encounter Assignments", items=function() return Conductor.EncounterAssignmentProfiles and Conductor.EncounterAssignmentProfiles:GetItems() or {{name="None",data=""}} end, getFunction=function() return {data=SRC.saved.activeEncounterAssignmentKey or ""} end, setFunction=function(_,_,data) SRC.saved.activeEncounterAssignmentKey=data.data or "" end },
        { type = LHAS.ST_BUTTON, buttonText = "LOAD SELECTED ENCOUNTER ASSIGNMENTS", clickHandler=function() if Conductor.EncounterAssignmentProfiles then Conductor.EncounterAssignmentProfiles:Load() end end },
        { type = LHAS.ST_BUTTON, buttonText = "DELETE SELECTED ENCOUNTER ASSIGNMENTS", clickHandler=function() if Conductor.EncounterAssignmentProfiles then Conductor.EncounterAssignmentProfiles:DeleteSelected() end end },
        { type = LHAS.ST_CHECKBOX, label = "Enable trash rotation", getFunction=function() return SRC.saved.trashRotationEnabled == true end, setFunction=function(v) SRC.saved.trashRotationEnabled=v end },
        { type = LHAS.ST_CHECKBOX, label = "Advance team after each trash pull", getFunction=function() return SRC.saved.trashAdvanceOnCombatEnd ~= false end, setFunction=function(v) SRC.saved.trashAdvanceOnCombatEnd=v end },
        { type = LHAS.ST_DROPDOWN, label = "Next trash ultimate group", items=function()
            local items = {}
            for team = 1, 4 do if SRC.saved["trashUltimateTeam" .. team .. "Enabled"] == true then items[#items+1] = {name="Ultimate Group " .. team,data=team} end end
            if #items == 0 then items[1] = {name="No teams enabled",data=1} end
            return items
        end, getFunction=function() return {data=SRC.saved.trashCurrentTeam or 1} end, setFunction=function(_,_,data) SRC.saved.trashCurrentTeam=data.data; if SRC.TrashRotation then SRC.TrashRotation:SetCurrentTeam(data.data) end end },
    })

    for team = 1, 4 do
        local t = team
        local teamKey = "trashUltimateTeam" .. tostring(t)
        local countKey = teamKey .. "Count"
        local enabledKey = teamKey .. "Enabled"
        panel:AddSettings({
            { type = LHAS.ST_LABEL, label = "|cFFD447Ultimate Group " .. tostring(t) .. "|r" },
            { type = LHAS.ST_CHECKBOX, label = "Enable Ultimate Group " .. tostring(t), getFunction=function() return SRC.saved[enabledKey] == true end, setFunction=function(v) SRC.saved[enabledKey]=v; if SRC.TrashRotation then SRC.TrashRotation:SetCurrentTeam(SRC.saved.trashCurrentTeam or 1) end end },
            { type = LHAS.ST_SLIDER, label = "Number of players", min=1,max=6,step=1, getFunction=function() return SRC.saved[countKey] or 1 end, setFunction=function(v) SRC.saved[countKey]=v end, disable=function() return SRC.saved[enabledKey] ~= true end },
        })
        local rows = {}
        for index = 1, 6 do
            local pos = index
            rows[#rows+1] = { type=LHAS.ST_DROPDOWN, label="Player " .. tostring(pos), items=GroupPlayerItems, getFunction=function() return {data=(SRC.saved[teamKey] or {})[pos] or ""} end, setFunction=function(_,_,data) SRC.saved[teamKey][pos]=SRC:NormalizeAccountName((data and data.data) or "") end, disable=function() return SRC.saved[enabledKey] ~= true or pos > (SRC.saved[countKey] or 1) end }
        end
        panel:AddSettings(rows)
    end


    panel:AddSettings({
        { type = LHAS.ST_LABEL, label = "|cFFD447Rotation-Specific Assignments|r" },
        { type = LHAS.ST_LABEL, label = "Gear and skill providers such as Nazaray, Pillager, Major Slayer, Warhorn, and Barrier are detected from Raid Setup - Team and are no longer assigned here." },
        { type = LHAS.ST_LABEL, label = "|cFFD447Colossus Rotation|r" },
    })
    AddUltimateModule(panel,"Colossus","colossusEnabled","rotationCount","rotation","ColossusRotation","COLOSSUS","Colo")

    panel:AddSettings({
        { type=LHAS.ST_SECTION, label="Buffs & Debuffs Configuration" },
        { type=LHAS.ST_LABEL, label="|cFFD447Choose what Conductor should monitor, display, and use when evaluating team responsibilities.|r" },
    })
    AddEffectToggleRows(panel, "BUFF", "Buffs")
    AddEffectToggleRows(panel, "DEBUFF", "Debuffs")
    AddEffectToggleRows(panel, "OTHER", "Other Responsibilities")
    AddRegistryToggleRows(panel, "GEAR", "Armor Sets", function(e) return e.setCategory ~= "MYTHIC" end)
    AddRegistryToggleRows(panel, "MONSTER_SETS", "Monster Sets")
    AddRegistryToggleRows(panel, "GEAR", "Mythics", function(e) return e.setCategory == "MYTHIC" end)
    AddRegistryToggleRows(panel, "ULTIMATES", "Ultimates")
    AddRegistryToggleRows(panel, "SCRIBED_ABILITIES", "Scribing")

    panel:AddSettings({
        { type = LHAS.ST_SECTION, label = "Encounter Details" },
        { type = LHAS.ST_LABEL, label = "|cFFD447Automatically coordinate boss burn windows from the active Raid Setup, selected difficulty, encounter state, and enabled support modules.|r" },
        { type = LHAS.ST_CHECKBOX, label = "Enable Encounter Intelligence", tooltip = "Automatically announce HOLD ULTIMATES, upcoming burn windows, and the configured burn sequence during supported trials.", getFunction=function() return SRC.saved.encounterIntelligenceEnabled == true end, setFunction=function(v) SRC.saved.encounterIntelligenceEnabled=v end },
        { type = LHAS.ST_SLIDER, label = "Minimum burn window", tooltip = "Do not begin a coordinated burn unless Conductor expects at least this many usable damage seconds.", min=12,max=20,step=1, getFunction=function() return SRC.saved.encounterMinimumBurnWindow or 12 end, setFunction=function(v) SRC.saved.encounterMinimumBurnWindow=v end },
        { type = LHAS.ST_SLIDER, label = "Default burn cycle", tooltip = "Fallback interval used by provisional encounter rules until a trial receives fully validated mechanic timing.", min=25,max=60,step=1, getFunction=function() return SRC.saved.encounterDefaultCycleSeconds or 40 end, setFunction=function(v) SRC.saved.encounterDefaultCycleSeconds=v end },
        { type = LHAS.ST_LABEL, label = "|cFFD447Damage Dealer role receives only HOLD, BURN WINDOW, and DAMAGE ULTIMATES callouts.|r" },
        { type = LHAS.ST_LABEL, label = "|cFFD447Raid Recommendations|r" },
        { type = LHAS.ST_CHECKBOX, label = "Enable automatic raid recommendations", tooltip = "Protect the planned raid sequence with concise HOLD BURN, USE BACKUP, REAPPLY, and RESUME BURN guidance when observable conditions justify it.", getFunction=function() return SRC.saved.recommendationEnabled ~= false end, setFunction=function(v) SRC.saved.recommendationEnabled=v end },
        { type = LHAS.ST_CHECKBOX, label = "Write next-pull focus to chat", tooltip = "After the pull-health report, write up to four lowest-health coordination priorities to the Trial Lead chat HUD.", getFunction=function() return SRC.saved.recommendationChatEnabled ~= false end, setFunction=function(v) SRC.saved.recommendationChatEnabled=v end },
        { type = LHAS.ST_LABEL, label = "|cFFD447Post-Pull Raid Health|r" },
        { type = LHAS.ST_CHECKBOX, label = "Write Trial Lead pull-health report to chat", tooltip = "After each pull, write rotation health, synchronization, burn-window quality, recovery interruptions, and the lowest effect-health results to the Trial Lead's in-game chat HUD. Enabled by default and hidden from Supports and Damage Dealers.", getFunction=function() return SRC.saved.postPullChatEnabled ~= false end, setFunction=function(v) SRC.saved.postPullChatEnabled=v end },
    })




    panel:AddSettings({
        { type = LHAS.ST_SECTION, label = "Developer Tools" },
        { type = LHAS.ST_CHECKBOX, label = "Enable temporary encounter debug window", tooltip = "Development-only movable and resizable validation window for vDSR HM and vRG HM testing. Disabled by default. Shows encounter decision state and keeps only the latest 7 events in memory and stores no encounter history.", getFunction=function() return SRC.saved.temporaryEncounterDebugEnabled == true end, setFunction=function(v) if SRC.TemporaryEncounterDebug then SRC.TemporaryEncounterDebug:SetEnabled(v) else SRC.saved.temporaryEncounterDebugEnabled=v end end },
        { type = LHAS.ST_BUTTON, buttonText = "RESET DEBUG WINDOW POSITION", tooltip = "Return the temporary encounter debug window to the lower-left corner.", clickHandler=function() if SRC.TemporaryEncounterDebug and SRC.TemporaryEncounterDebug.ResetPosition then SRC.TemporaryEncounterDebug:ResetPosition() end end },
        { type = LHAS.ST_LABEL, label = "|cFFD447Inspect what Conductor loaded, normalized, validated, and shared. These tools do not alter live combat coordination.|r" },

        { type = LHAS.ST_LABEL, label = "|cFFD447Responsibilities|r" },
        { type = LHAS.ST_LABEL, label = "Review who currently satisfies each enabled responsibility. This remains a developer tool until the future Knowledge menu is introduced." },
        { type = LHAS.ST_BUTTON, buttonText = "OPEN RESPONSIBILITY EXPLORER", clickHandler=function() if SRC.Diagnostics and SRC.Diagnostics.ShowResponsibilities then SRC.Diagnostics:ShowResponsibilities() end end },
        { type = LHAS.ST_BUTTON, buttonText = "OPEN CURRENT TEAM COVERAGE", clickHandler=function() if SRC.Diagnostics and SRC.Diagnostics.ToggleTeamIntelligenceSummary then SRC.Diagnostics:ToggleTeamIntelligenceSummary() end end },

        { type = LHAS.ST_LABEL, label = "|cFFD447Knowledge Base|r" },
        { type = LHAS.ST_BUTTON, buttonText = "OPEN KNOWLEDGE BASE HEALTH", tooltip = "View Knowledge Base health and validation totals.", clickHandler=function()
            if SRC.Diagnostics and SRC.Diagnostics.ShowKnowledgeBaseHealth then SRC.Diagnostics:ShowKnowledgeBaseHealth() end
        end },
        { type = LHAS.ST_BUTTON, buttonText = "RUN VALIDATION AND OPEN RESULTS", tooltip = "Re-run validation and show errors and warnings.", clickHandler=function()
            if SRC.Diagnostics and SRC.Diagnostics.RunAndShowValidation then SRC.Diagnostics:RunAndShowValidation() end
        end },
        { type = LHAS.ST_BUTTON, buttonText = "OPEN PROVIDER MAPPING AUDIT", tooltip = "Review unresolved and one-way effect/provider mappings.", clickHandler=function()
            if SRC.Diagnostics and SRC.Diagnostics.ShowProviderMappingAudit then SRC.Diagnostics:ShowProviderMappingAudit() end
        end },

        { type = LHAS.ST_LABEL, label = "|cFFD447Registry Explorer|r" },
        { type = LHAS.ST_DROPDOWN, label = "Registry collection", tooltip = "Choose a registry.", items=function() return SRC.Diagnostics:GetRegistryCollectionItems() end, getFunction=function() return {data=SRC.saved.developerRegistryCollection or "EFFECTS"} end, setFunction=function(_,_,data) SRC.saved.developerRegistryCollection=data.data end },
        { type = LHAS.ST_BUTTON, buttonText = "OPEN SELECTED REGISTRY", clickHandler=function()
            if SRC.Diagnostics and SRC.Diagnostics.ShowSelectedRegistry then SRC.Diagnostics:ShowSelectedRegistry() end
        end },
        { type = LHAS.ST_EDIT, label = "Knowledge lookup", tooltip = "Search names, stable IDs, Ability IDs, Set IDs, effects, or providers.", getFunction=function() return SRC.saved.developerLookupQuery or "" end, setFunction=function(v) SRC.saved.developerLookupQuery=v or "" end },
        { type = LHAS.ST_BUTTON, buttonText = "RUN KNOWLEDGE LOOKUP", clickHandler=function()
            if SRC.Diagnostics and SRC.Diagnostics.RunKnowledgeLookup then SRC.Diagnostics:RunKnowledgeLookup() end
        end },

        { type = LHAS.ST_LABEL, label = "|cFFD447Performance & Network|r" },
        { type = LHAS.ST_BUTTON, buttonText = "OPEN PERFORMANCE / NETWORK", clickHandler=function()
            if SRC.Diagnostics and SRC.Diagnostics.ShowPerformanceFoundations then SRC.Diagnostics:ShowPerformanceFoundations() end
        end },
        { type = LHAS.ST_BUTTON, buttonText = "SHOW / HIDE CONDUCTOR NETWORK STATUS", clickHandler=function()
            if SRC.Diagnostics and SRC.Diagnostics.ToggleNetworkSummary then SRC.Diagnostics:ToggleNetworkSummary() end
        end },
        { type = LHAS.ST_BUTTON, buttonText = "REFRESH LOCAL CAPABILITY SCAN", tooltip = "Rescan your current loadout and capabilities.", clickHandler=function()
            if SRC.PlayerScanner and SRC.PlayerScanner.RefreshLocalCapabilities then SRC.PlayerScanner:RefreshLocalCapabilities() end
            if SRC.Diagnostics and SRC.Diagnostics.ShowLocalCapabilitySummary then SRC.Diagnostics:ShowLocalCapabilitySummary() end
        end },
        { type = LHAS.ST_BUTTON, buttonText = "SHOW / HIDE RAID INTELLIGENCE PROFILE", tooltip = "View your detected providers and capabilities.", clickHandler=function()
            if SRC.Diagnostics and SRC.Diagnostics.ToggleLocalCapabilitySummary then SRC.Diagnostics:ToggleLocalCapabilitySummary() end
        end },
        { type = LHAS.ST_BUTTON, buttonText = "SHOW / HIDE CURRENT TEAM COVERAGE", tooltip = "View capabilities found in current Conductor profiles.", clickHandler=function()
            if SRC.Diagnostics and SRC.Diagnostics.ToggleTeamIntelligenceSummary then SRC.Diagnostics:ToggleTeamIntelligenceSummary() end
        end },

        { type = LHAS.ST_LABEL, label = "|cFFD447Diagnostic Sessions|r" },
        { type = LHAS.ST_LABEL, label = "|cFFD447Advanced encounter-research tools. Most players should leave these disabled.|r" },
        { type = LHAS.ST_CHECKBOX, label = "Capture coordinated support-set research", tooltip="Record support events for private testing.", getFunction=function() return SRC.saved.researchCaptureEnabled == true end,setFunction=function(v) SRC.saved.researchCaptureEnabled=v end },
        { type = LHAS.ST_DROPDOWN, label = "Logging level", items=function() return DIAG_ITEMS end,getFunction=function() return {data=SRC.Diagnostics:GetMode()} end,setFunction=function(_,_,data) SRC.Diagnostics:SetMode(data.data) end },
        { type = LHAS.ST_EDIT, label = "New session name", getFunction=function() return SRC.saved.diagnosticSessionName or "Trial Test" end,setFunction=function(v) SRC.saved.diagnosticSessionName=v or "Trial Test" end },
        { type = LHAS.ST_BUTTON, buttonText = "Start silent session", clickHandler=function() if SRC.Diagnostics:GetMode()=="off" then SRC.Diagnostics:SetMode("standard") end; SRC.Diagnostics:StartSession(SRC.saved.diagnosticSessionName) end },
        { type = LHAS.ST_BUTTON, buttonText = "End and save active session", clickHandler=function() SRC.Diagnostics:EndSession() end },
        { type = LHAS.ST_DROPDOWN, label = "Saved session", items=function() return SRC.Diagnostics:GetSessionItems() end,getFunction=function() return {data=SRC.saved.selectedDiagnosticSession or ""} end,setFunction=function(_,_,data) SRC.Diagnostics:SelectSession(data.data) end },
        { type = LHAS.ST_BUTTON, buttonText = "Open saved session viewer", clickHandler=function() SRC.Diagnostics:ShowViewer(true) end },
        { type = LHAS.ST_BUTTON, buttonText = "Delete selected session", clickHandler=function() SRC.Diagnostics:DeleteSelectedSession() end },
        { type = LHAS.ST_BUTTON, buttonText = "Delete all saved sessions", clickHandler=function() SRC.Diagnostics:DeleteAllSessions() end },
        { type = LHAS.ST_CHECKBOX, label = "Show live diagnostic overlay", getFunction=function() return SRC.saved.diagnosticOverlay end,setFunction=function(v) SRC.saved.diagnosticOverlay=v; SRC.Diagnostics:SetOverlay(v) end },
        { type = LHAS.ST_BUTTON, buttonText = "Clear live overlay history", clickHandler=function() SRC.Diagnostics:Clear() end },
    })

    self.registered = true
    self.panel = panel
    self:AddDiagnostic("Console settings panel registered")
    return true
end
