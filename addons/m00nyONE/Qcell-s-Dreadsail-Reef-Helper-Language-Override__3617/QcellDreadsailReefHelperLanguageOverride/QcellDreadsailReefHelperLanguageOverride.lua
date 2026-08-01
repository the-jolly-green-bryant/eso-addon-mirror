QDRHLO = QDRHLO or {}
QDRHLO.name = "QcellDreadsailReefHelperLanguageOverride"


function QDRHLO.OnAddonLoaded(_, addonName)
    if addonName ~= QDRHLO.name then return end
    EVENT_MANAGER:UnregisterForEvent(QDRHLO.name, EVENT_ADD_ON_LOADED )

    QDRH.data.lylanarName = QDRHLO.data.lylanarName
    QDRH.data.turlassilName =  QDRHLO.data.turlassilName
    QDRH.data.reefGuardianName =  QDRHLO.data.reefGuardianName
    QDRH.data.taleriaName =  QDRHLO.data.taleriaName
end

EVENT_MANAGER:RegisterForEvent( QDRHLO.name, EVENT_ADD_ON_LOADED, QDRHLO.OnAddonLoaded )