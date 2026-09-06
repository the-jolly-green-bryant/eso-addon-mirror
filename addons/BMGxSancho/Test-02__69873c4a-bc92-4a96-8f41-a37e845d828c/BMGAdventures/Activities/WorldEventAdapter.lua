local BA = BMGAdventures
BA.WorldEventAdapter = BA.WorldEventAdapter or {}

local function record(kind, ...)
    BA.Diagnostics:Count("worldEventCallbacks")
    local values = {...}
    local out = {}
    for i=1,#values do out[#out+1] = tostring(values[i]) end
    BA.Diagnostics:Record(kind, table.concat(out, "|"))
end

function BA.WorldEventAdapter:Initialize()
    -- Diagnostic-only in dev2. Participation ending is not assumed to mean success.
    local events = {
        { EVENT_WORLD_EVENT_ACTIVATED, "WORLD_EVENT_ACTIVATED" },
        { EVENT_WORLD_EVENT_PARTICIPATION_BEGIN, "WORLD_EVENT_PARTICIPATION_BEGIN" },
        { EVENT_WORLD_EVENT_STEP_CHANGED, "WORLD_EVENT_STEP_CHANGED" },
        { EVENT_WORLD_EVENT_STEP_PROGRESS_CHANGED, "WORLD_EVENT_PROGRESS" },
        { EVENT_WORLD_EVENT_PARTICIPATION_END, "WORLD_EVENT_PARTICIPATION_END" },
        { EVENT_WORLD_EVENT_DEACTIVATED, "WORLD_EVENT_DEACTIVATED" },
    }
    for index, row in ipairs(events) do
        local eventCode, kind = row[1], row[2]
        if eventCode then
            EVENT_MANAGER:RegisterForEvent(BA.name .. "WorldEvent" .. tostring(index), eventCode, function(_, ...)
                record(kind, ...)
            end)
        end
    end
end
