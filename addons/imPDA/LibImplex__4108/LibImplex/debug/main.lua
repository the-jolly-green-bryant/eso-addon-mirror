local TOP_LEVEL_CONTROL = LibImplex_DebugWindow
local ZONE_INFO = TOP_LEVEL_CONTROL:GetNamedChild('ZoneInfo')
local TEXT = TOP_LEVEL_CONTROL:GetNamedChild('Text')

local EVENT_NAMESPACE = 'IMP_LibImplex_Debug_EVENT_NAMESPACE'
local LIB


local function SetMinimized(toMinimize)
    -- local parent = control:GetParent()
    -- local isHidden = parent:GetNamedChild('Text'):IsHidden()

    local parent = TOP_LEVEL_CONTROL

    parent:GetNamedChild('Text'):SetHidden(toMinimize)
    parent:GetNamedChild('Text2'):SetHidden(toMinimize)
    parent:GetNamedChild('RenderWorldSwitch'):SetHidden(toMinimize)

    if toMinimize then
        parent:GetNamedChild('MinimizeButton'):SetText('|c00EE00[+]|r')
    else
        parent:GetNamedChild('MinimizeButton'):SetText('|cFF5C00[–]|r')
    end
end


function LibImplex_ShowDebugWindow(addon)
    LIB = addon

    TOP_LEVEL_CONTROL:SetHidden(false)

    local offsetX, offsetY = unpack(addon.sv.debugAnchorOffsets)
    -- local anchor = TOP_LEVEL_CONTROL:GetAnchor()
    -- anchor:SetOffsetX(offsetX)
    -- anchor:SetOffsetY(offsetY)

    -- df('Offsets: %.2f, %.2f', offsetX, offsetY)
    TOP_LEVEL_CONTROL:SetAnchorOffsets(offsetX, offsetY, 1)

    SetMinimized(addon.sv.debugMinimized)

    EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, 1000/60, function()
        local text = ''

        local _, prX, prY, prZ = GetUnitRawWorldPosition('player')
        text = text .. ('GetUnitRawWorldPosition: {%d, %d, %d}\n'):format(prX, prY, prZ)

        local _, pX, pY, pZ = GetUnitWorldPosition('player')
        text = text .. ('GetUnitWorldPosition: {%d, %d, %d}\n'):format(pX, pY, pZ)

        text = text .. ('Difference: {%d, %d, %d}\n'):format(prX - pX, prY - pY, prZ - pZ)

        local npX, npZ = GetNormalizedWorldPosition(zoneId, pX, pY, pZ)
        text = text .. ('GetNormalizedWorldPosition: {%.6f, %.6f}\n'):format(npX, npZ)

        local rnpX, rnpZ = GetRawNormalizedWorldPosition(zoneId, prX, prY, prZ)
        text = text .. ('GetRawNormalizedWorldPosition: {%.6f, %.6f}\n'):format(rnpX, rnpZ)

        local crsoX, crsoY, crsoZ = LibImplex_2DMarkers:Get3DRenderSpaceOrigin()
        text = text .. ('Camera render space origin: {%.6f, %.6f, %.6f}\n'):format(crsoX, crsoY, crsoZ)

        local crX, crY, crZ = GuiRender3DPositionToWorldPosition(crsoX, crsoY, crsoZ)
        text = text .. ('Camera GuiRender3DPositionToWorldPosition: {%.2f, %.2f, %.2f}\n'):format(crX, crY, crZ)

        text = text .. '\n'

        local fX, fY, fZ = LibImplex_2DMarkers:Get3DRenderSpaceForward()
        text = text .. ('Camera Forward: {%.2f, %.2f, %.2f}\n'):format(fX, fY, fZ)

        local rX, rY, rZ = LibImplex_2DMarkers:Get3DRenderSpaceRight()
        text = text .. ('Camera Right: {%.2f, %.2f, %.2f}\n'):format(rX, rY, rZ)

        local uX, uY, uZ = LibImplex_2DMarkers:Get3DRenderSpaceUp()
        text = text .. ('Camera Up: {%.2f, %.2f, %.2f}\n'):format(uX, uY, uZ)

        TEXT:SetText(text)
    end)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
        local zoneIndex = GetUnitZoneIndex('player')
        local zoneName = GetZoneNameByIndex(zoneIndex)
        local zoneId = GetZoneId(zoneIndex)

        ZONE_INFO:SetText(('|c00EE00%s|r (index: %d, ID: %d, subZoneId: %s)\n'):format(zoneName:upper(), zoneIndex, zoneId, IMP_GetCurrentSubzoneId() or '?'))
    end)
end

function IMP_LibImplex_ToggleMinimized(control)
    local isHidden = control:GetParent():GetNamedChild('Text'):IsHidden()
    SetMinimized(not isHidden)
    LIB.sv.debugMinimized = not isHidden
end

function IMP_LibImplex_Debug_SaveOffsets()
    local offsetX, offsetY = select(5, TOP_LEVEL_CONTROL:GetAnchor())
    -- df('Offsets: %.2f, %.2f', offsetX, offsetY)

    LIB.sv.debugAnchorOffsets = {offsetX, offsetY}
end