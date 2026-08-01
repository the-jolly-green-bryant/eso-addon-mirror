local MARK_TYPE_LOREBOOKS = nil
local EVENT_NAMESPACE = 'IMP_CART_LOREBOOKS'

local function keepOnPlayersHeight(marker, distance, prwX, prwY, prwZ)
    marker[2] = prwY + 200
end

local LOREBOOKS = {}
local LOREBOOK_MARK_INDICIES = {}

local function addMarksForLorebooks()
    local zoneId, prwX, prwY, prwZ = GetUnitRawWorldPosition('player')
    local convX, convZ = ImperialCartographer.Calculations.GetNWToRNWConversionFunctions(zoneId, prwX, prwY, prwZ)

    local calibration = {ImperialCartographer.Coordinates.GetCalibration(zoneId)}
    local rwY = 0

    local texture = '/esoui/art/miscellaneous/gamepad/gp_bullet.dds'
    local size = 48

    for i = 1, #LOREBOOKS do
        local nwX, nwZ = unpack(LOREBOOKS[i])
        local rnwX, rnwZ = convX(nwX), convZ(nwZ)
        local rwX, rwZ = ImperialCartographer.Coordinates.ConvertNormalizedToWorld(rnwX, rnwZ, calibration)

        local mark, markIndex = ImperialCartographer.MarksManager:AddMark(MARK_TYPE_LOREBOOKS, {}, {rwX, rwY, rwZ}, texture, size)

        LOREBOOK_MARK_INDICIES[#LOREBOOK_MARK_INDICIES+1] = markIndex
    end
end

local INITIALIZED = false
EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
    -- if not ImperialCartographer.sv.questTracker.enabled then return end
    if not LoreBooks_GetLocalData then return end

    if not INITIALIZED then
        MARK_TYPE_LOREBOOKS = ImperialCartographer.MarksManager:AddMarkType(function() end, true, keepOnPlayersHeight)
        INITIALIZED = true
    end

    local zoneId = GetUnitWorldPosition('player')
    local mapId = GetMapIdByZoneId(zoneId)
    LOREBOOKS = LoreBooks_GetLocalData(mapId)

    addMarksForLorebooks()
end)
