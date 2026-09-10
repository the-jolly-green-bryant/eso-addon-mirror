local addon = PoppysHardmodeReminder
local notified
local missingGeneration = 0
addon.normalTest = false

local function FindEncounter()
    local index = GetUnitZoneIndex("player")
    local zone = index and GetZoneId(index) or 0
    local entries = addon.encounters[zone]
    if not entries then return nil end
    if not IsUnitUsingVeteranDifficulty("player") and not addon.normalTest then
        return nil
    end
    for i = 1, 6 do
        local tag = "boss" .. i
        if DoesUnitExist(tag) then
            local name = string.lower(zo_strformat("<<1>>", GetUnitName(tag)))
            if entries[name] and not IsUnitDead(tag) then
                return entries[name]
            end
        end
    end
end

function addon.ResetReminder()
    notified = nil
    missingGeneration = missingGeneration + 1
end

function addon.CheckReminder()
    local encounter = FindEncounter()
    missingGeneration = missingGeneration + 1
    if not encounter then
        -- Ignore brief empty lists during boss refreshes. A sustained absence
        -- re-arms the next approach; forceReset alone is not proof of a wipe.
        local generation = missingGeneration
        zo_callLater(function()
            if generation == missingGeneration and not FindEncounter() then
                notified = nil
            end
        end, 1500)
        return
    end
    if notified == encounter or IsUnitDeadOrReincarnating("player") then return end
    notified = encounter
    -- Nearby trash combat must not prevent an encounter-area reminder.
    addon.ShowWarning()
end
