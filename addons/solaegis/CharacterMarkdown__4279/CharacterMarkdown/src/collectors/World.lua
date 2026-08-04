-- CharacterMarkdown - World Progress Data Collector
-- Skyshards, lorebooks, zone completion, dungeons, Cadwell

local CM = CharacterMarkdown

local function CollectWorldProgressData()
    local worldApi = CM.api and CM.api.world
    if not worldApi then
        CM.Warn("World API not loaded")
        return nil
    end

    local data = {
        skyshards = worldApi.GetSkyshards() or { collected = 0, total = 0, zones = {} },
        lorebooks = worldApi.GetLorebooks() or { collected = 0, total = 0, categories = {} },
        zoneCompletion = worldApi.GetCurrentZoneCompletion() or { currentZone = "", completionPercentage = 0 },
        dungeons = worldApi.GetDungeonProgress() or {
            delves = { completed = 0, total = 0 },
            publicDungeons = { completed = 0, total = 0 },
        },
        cadwell = worldApi.GetCadwellProgress and worldApi.GetCadwellProgress() or nil,
        endlessDungeon = nil,
    }

    local settings = CM.GetSettings()
    if settings and settings.includeEndlessDungeon then
        local score = CM.SafeCall(GetEndlessDungeonScore)
        local isInstance = CM.SafeCall(IsInstanceEndlessDungeon) or false
        local isStarted = CM.SafeCall(IsEndlessDungeonStarted) or false
        local verses = {}
        if GetNumEndlessDungeonActiveVerses and GetEndlessDungeonActiveVerseAbility then
            local numVerses = CM.SafeCall(GetNumEndlessDungeonActiveVerses) or 0
            for i = 1, numVerses do
                local abilityId = CM.SafeCall(GetEndlessDungeonActiveVerseAbility, i)
                if abilityId and abilityId > 0 then
                    local name = CM.SafeCall(GetAbilityName, abilityId, "player")
                    table.insert(verses, { id = abilityId, name = name or tostring(abilityId) })
                end
            end
        end
        if isInstance or isStarted or (score and score > 0) or #verses > 0 then
            data.endlessDungeon = {
                score = score or 0,
                isInstance = isInstance,
                isStarted = isStarted,
                verses = verses,
            }
        end
    end

    return data
end

CM.collectors.CollectWorldProgressData = CollectWorldProgressData

CM.DebugPrint("COLLECTOR", "World collector module loaded")
