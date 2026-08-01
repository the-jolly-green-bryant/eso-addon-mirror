-- Normalize saved animationDuration values
local MeterskullMigration = {}

local function NormalizeAnimationDurationValue(v)
    local valid = { off = true, fast = true, standard = true, slow = true }

    if type(v) == "table" then
        v = v.armorskull or v.penskull or v.critskull or v.critresiskull or v.powerskull or v.healthskull or v.magskull or v.stamskull
    end

    if type(v) ~= "string" then v = "standard" end
    v = string.lower(v)
    if not valid[v] then v = "standard" end
    return v
end

local function NormalizeSavedVarsAnimationDuration()
    if not MeterskullSettings then return end
    for world, worldData in pairs(MeterskullSettings) do
        if type(worldData) == "table" then
            for accountName, accountData in pairs(worldData) do
                if type(accountData) == "table" then
                    for charId, charData in pairs(accountData) do
                        if type(charData) == "table" then
                            if type(charData.sharedSettings) ~= "table" then charData.sharedSettings = {} end
                            -- Only update saved var when normalized value differs (case-insensitive)
                            local existing = charData.sharedSettings.animationDuration
                            local normalized = NormalizeAnimationDurationValue(existing)
                            local existingNormalized = type(existing) == "string" and string.lower(existing) or nil
                            if existingNormalized ~= normalized then
                                charData.sharedSettings.animationDuration = normalized
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Run normalization once when the addon is loaded
EVENT_MANAGER:RegisterForEvent("MeterskullMigration", EVENT_ADD_ON_LOADED, function(_, addOnName)
    if addOnName ~= "Meterskull" then return end
    NormalizeSavedVarsAnimationDuration()
    EVENT_MANAGER:UnregisterForEvent("MeterskullMigration", EVENT_ADD_ON_LOADED)
end)

return MeterskullMigration
