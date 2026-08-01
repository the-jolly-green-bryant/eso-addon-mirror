-- CharacterMarkdown - Companion Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

local function CollectCompanionData()
    -- Use API layer granular functions (composition at collector level)
    local companions = CM.api.companion.GetAllCompanions()
    local hasActive = CM.api.companion.HasActiveCompanion()

    local data = {}

    -- Transform API data to expected format
    data.companions = {}
    for _, comp in ipairs(companions.list or {}) do
        if comp.unlocked then
            table.insert(data.companions, {
                name = comp.name,
                id = comp.id,
            })
        end
    end

    data.hasActive = hasActive or false

    -- Active companion details (cross-API composition)
    if data.hasActive then
        -- Try multiple approaches to get companion name
        local name = nil
        local level = 0

        -- Approach 1: Try GetUnitName("companion") - unit API
        name = CM.SafeCall(GetUnitName, "companion")
        level = CM.SafeCall(GetUnitLevel, "companion") or 0

        -- Approach 2: If unit API fails, try to find active companion from list
        -- (This is a fallback - ideally we'd have GetActiveCompanionId())
        if not name or name == "" then
            CM.DebugPrint("COMPANION", "GetUnitName('companion') failed, trying to find active companion from list")
            -- Try to match by checking which companion is active
            -- Note: This is a workaround - ideally ESO would provide GetActiveCompanionId()
            for _, comp in ipairs(companions.list or {}) do
                -- If we only have one companion and it's active, use it
                if #companions.list == 1 then
                    name = comp.name
                    CM.DebugPrint("COMPANION", string.format("Using single companion name: %s", tostring(name)))
                    break
                end
            end
        end

        -- Final fallback
        if not name or name == "" then
            name = "Unknown Companion"
            CM.Error(
                "Companion: Failed to get companion name. GetUnitName('companion') returned nil/empty and couldn't find active companion in list."
            )
        end

        data.active = {
            name = name,
            level = level,
        }
        data.skills = CM.api.companion.GetCompanionSkills()
        data.equipment = CM.api.companion.GetCompanionEquipment()

        -- Get rapport level (API 101049+)
        local hasRapport = HasActiveCompanion()
        if hasRapport then
            data.rapportLevel = GetActiveCompanionRapportLevel()
            data.rapportLevelDescription = GetActiveCompanionRapportLevelDescription(data.rapportLevel)
        end

        -- Get outfit info (API 101048+)
        if CM.api.companion.GetCompanionOutfit then
            data.outfit = CM.api.companion.GetCompanionOutfit()
        end

        -- Add computed summary for active companion
        data.summary = {
            totalCompanions = companions.list and #companions.list or 0,
            hasActive = true,
            activeLevel = data.active.level or 0,
            skillCount = data.skills and #data.skills or 0,
            equipmentCount = data.equipment and #data.equipment or 0,
            rapportLevel = data.rapportLevelDescription or nil,
        }
    else
        data.active = nil
        data.skills = nil
        data.equipment = nil
        data.summary = {
            totalCompanions = companions.list and #companions.list or 0,
            hasActive = false,
        }
    end

    return data
end

CM.collectors.CollectCompanionData = CollectCompanionData

CM.DebugPrint("COLLECTOR", "Companion collector module loaded")
