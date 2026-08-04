local C = Conductor
local SRC = SupportRotationCallouts
C.SessionImporter = C.SessionImporter or {}
local Importer = C.SessionImporter

local function Normalize(value)
    if C.NormalizeAccountName then return C:NormalizeAccountName(value or "") end
    return tostring(value or "")
end

local function BuildSlots(snapshot)
    local roles = { "Main Tank", "Off Tank", "Healer 1", "Healer 2",
        "Damage Dealer 1", "Damage Dealer 2", "Damage Dealer 3", "Damage Dealer 4",
        "Damage Dealer 5", "Damage Dealer 6", "Damage Dealer 7", "Damage Dealer 8" }
    local slots = {}
    for index = 1, 12 do
        slots[index] = { role=roles[index], player="", class="", set1="NONE", set2="NONE",
            monster="NONE", mythic="NONE", arena="NONE", manualPlayer="", manualSet1="",
            manualSet2="", manualMonster="", manualMythic="", manualArena="", manualNotes="",
            source="SHARED" }
    end
    for fallbackIndex, player in ipairs(snapshot.players or {}) do
        local index = tonumber(player.rosterSlot) or fallbackIndex
        if index >= 1 and index <= 12 then
            local loadout = player.loadout or {}
            local slot = slots[index]
            slot.player = Normalize(player.accountName)
            slot.class = player.classKey or ""
            slot.set1 = loadout.set1 or "NONE"
            slot.set2 = loadout.set2 or "NONE"
            slot.monster = loadout.monster or "NONE"
            slot.mythic = loadout.mythic or "NONE"
            slot.arena = loadout.arena or "NONE"
            slot.manualSet1 = loadout.manualSet1 or ""
            slot.manualSet2 = loadout.manualSet2 or ""
            slot.manualMonster = loadout.manualMonster or ""
            slot.manualMythic = loadout.manualMythic or ""
            slot.manualArena = loadout.manualArena or ""
            slot.manualNotes = loadout.notes or ""
            slot.source = "SHARED"
        end
    end
    return slots
end

function Importer:Import(snapshot, sender)
    local valid, validationError = C.SessionSnapshot:Validate(snapshot, false)
    if not valid then return nil, validationError end
    if not C.RaidSession or not C.saved then return nil, "Raid Session storage is unavailable." end

    local slots = BuildSlots(snapshot)
    local receivedProfile
    if C.TeamProfilesV2 and C.TeamProfilesV2.ImportSharedSession then
        receivedProfile = C.TeamProfilesV2:ImportSharedSession(snapshot, slots)
    end

    local session = C.SessionSnapshot:ToRaidSession(snapshot)
    if receivedProfile then session.sourceProfileId = receivedProfile.id end
    local imported = C.RaidSession:ApplyRemoteSnapshot(session, "validated shared Raid Session accepted")
    if not imported then return nil, "The active Raid Session could not be created." end

    C.saved.raidRosterSlots = slots
    C.saved.profileDraftInstance = snapshot.trial or C.saved.profileDraftInstance or ""
    C.saved.profileDraftDifficulty = snapshot.difficulty or C.saved.profileDraftDifficulty or "veteran"
    C.saved.profileDraftObjective = snapshot.objective or C.saved.profileDraftObjective or "prog"
    C.saved.profileDraftStrategy = snapshot.strategy or C.saved.profileDraftStrategy or ""
    C.saved.sharedRaidSessionId = snapshot.sessionId
    C.saved.sharedRaidSessionHost = Normalize(sender or snapshot.hostAccount)
    C.saved.sharedRaidSessionMode = snapshot.mode
    C.saved.sharedRaidSessionName = snapshot.teamName

    if C.EventBus then
        C.EventBus:Publish("RAID_SESSION_IMPORTED", { session=imported, snapshot=snapshot, slots=slots, profile=receivedProfile })
        C.EventBus:Publish("RAID_SETUP_REFRESH_REQUESTED", { reason="shared Raid Session imported", session=imported })
    end
    return imported
end
