--IMPORTANT --IMPORTANT --IMPORTANT --IMPORTANT
--IMPORTANT --IMPORTANT --IMPORTANT --IMPORTANT
--IMPORTANT --IMPORTANT --IMPORTANT --IMPORTANT
--IMPORTANT --IMPORTANT --IMPORTANT --IMPORTANT
--IMPORTANT --IMPORTANT --IMPORTANT --IMPORTANT

-- LibLoadedAddons will not be used anymore since 2021-12! It's obsolete. Please use the txt files of libraries and
-- addons -> tag ## AddOnVersion: <unsignedInteger> and/or global variables to cross-check other addons

--IMPORTANT --IMPORTANT --IMPORTANT --IMPORTANT
--IMPORTANT --IMPORTANT --IMPORTANT --IMPORTANT
--IMPORTANT --IMPORTANT --IMPORTANT --IMPORTANT
--IMPORTANT --IMPORTANT --IMPORTANT --IMPORTANT
--IMPORTANT --IMPORTANT --IMPORTANT --IMPORTANT



--> Library is OBSOLETE! Do not use anymore! Checking for the global variable (old included hardcoded calls)
local LIBRARY_NAME = "LibLoadedAddons"

EVENT_MANAGER:RegisterForEvent(LIBRARY_NAME, EVENT_PLAYER_ACTIVATED, function(eventId, firstRun)
--d("["..LIBRARY_NAME.."]EVENT_PLAYER_ACTIVATED - firstRun: " ..tostring(firstRun))
    if not firstRun then return end

    EVENT_MANAGER:UnregisterForEvent(LIBRARY_NAME, EVENT_PLAYER_ACTIVATED)

    local wasStillFound = (_G[LIBRARY_NAME] ~= nil) or false
    _G[LIBRARY_NAME] = nil
    assert(not wasStillFound, "\'" .. LIBRARY_NAME .. "\' is OBSOLETE! Please check your addons and remove it and/or inform the developers of these addons to remove it!")
end)