AntiquityDealIntel = {}
AntiquityDealIntel.name = "AntiquityDealIntel"
AntiquityDealIntel.namespace = "AntiquityDealIntelNamesSpace"

function AntiquityDealIntel.AddTooltipInfo(rootControl, slotIndex) --> void
    local antiquityIndex = GetStoreEntryAntiquityId(slotIndex)
    if antiquityIndex == 0 then return end

    local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
    local numEntriesAcquired, numEntries = GetNumAntiquityLoreEntriesAcquired(antiquityIndex), GetNumAntiquityLoreEntries(antiquityIndex)
    local zone = GetAntiquityZoneId(antiquityIndex)
    ZO_Tooltip_AddDivider(rootControl)
    if numEntriesAcquired == 0 then
        rootControl:AddLine("You haven't dug this up yet!", "ZoFontWinH5", 1, 1, 0, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
    end
    rootControl:AddLine("Lore entries collected:", "ZoFontHeader3", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
    rootControl:AddLine(tostring(numEntriesAcquired) .. " / " .. tostring(numEntries), "ZoFontWinH5", r, g,  b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)

    local dropHint, accesible = AntiquityDealIntel.LibLeadDropHook(antiquityIndex)
    if dropHint then
        local zoneR, zoneG, zoneB = accesible and r or 1, accesible and g or 0, accesible and b or 1
        rootControl:AddLine("Lead drop source:", "ZoFontHeader3", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
        rootControl:AddLine(dropHint,  "ZoFontWinH5", zoneR, zoneG, zoneB, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
    end
end

function AntiquityDealIntel.LibLeadDropHook(antiquityIndex) --> Bool: resultOK, String: DropHint, String: dropZoneNames
    local fetchedLeadDropHint = LibLeadDrop and LibLeadDrop.getLeadDropHint(antiquityIndex)
    if not fetchedLeadDropHint then return end -- addon or data in a known form unavailable
    local hasAccess = false
    local no_zones = true
    for _, zone in ipairs(LibLeadDrop.GetLeadDropZones(antiquityIndex)) do
        no_zones = false
        if CanJumpToPlayerInZone(zone) then
            hasAccess = true
        end
    end
    return fetchedLeadDropHint, hasAccess or no_zones
end

function AntiquityDealIntel.OnEVENT_ADD_ON_LOADED(event, addonName) --> void
    if addonName ~= AntiquityDealIntel.name then return end
    EVENT_MANAGER:UnregisterForEvent(AntiquityDealIntel.namespace, EVENT_ADD_ON_LOADED)

    ZO_PostHook(ItemTooltip, "SetStoreItem", AntiquityDealIntel.AddTooltipInfo)
end

EVENT_MANAGER:RegisterForEvent(AntiquityDealIntel.namespace, EVENT_ADD_ON_LOADED, AntiquityDealIntel.OnEVENT_ADD_ON_LOADED)
