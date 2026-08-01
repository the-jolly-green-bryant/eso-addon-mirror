LibDataStructures = {
    name = "LibDataStructures",
    version = "2024.12.06",
}
local LDS = LibDataStructures


local function Initialize()

end

-- register the addon
EVENT_MANAGER:RegisterForEvent(LDS.name, EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= LDS.name then return end
    EVENT_MANAGER:UnregisterForEvent(LDS.name, EVENT_ADD_ON_LOADED)

    Initialize()
end)