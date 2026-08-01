local lib = LibNeuralNetworks
local math = lib.math

EVENT_MANAGER:RegisterForEvent(lib.id, EVENT_ADD_ON_LOADED, function(event, name)
    if(name == lib.name) then
        -- Initialization
    end
end)