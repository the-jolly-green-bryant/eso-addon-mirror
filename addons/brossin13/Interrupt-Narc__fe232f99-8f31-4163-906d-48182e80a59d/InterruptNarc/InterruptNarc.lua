-- ============================================================
-- InterruptNarc.lua
-- DIAGNOSTIC VERSION 4
-- Testing EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED to see if it
-- fires on NPC units when they get interrupted/staggered.
-- ============================================================

InterruptNarc = {}

InterruptNarcSV = InterruptNarcSV or {
    debugMode = false
}

local function StripSuffix(name)
    if not name then return "" end
    return name:match("^([^^]+)") or name
end

local function OnAttributeVisualUpdated(eventCode, unitTag, 
                                         unitAttributeVisual,
                                         attributeType,
                                         powerType,
                                         value, maxValue)
    if InterruptNarcSV.debugMode then
        d(string.format("[IN:DEBUG] ATTR_VISUAL unitTag=%s visual=%s attrType=%s value=%s",
            tostring(unitTag),
            tostring(unitAttributeVisual),
            tostring(attributeType),
            tostring(value)))
    end
end

local function OnAttributeVisualAdded(eventCode, unitTag,
                                       unitAttributeVisual,
                                       attributeType,
                                       powerType,
                                       value, maxValue)
    if InterruptNarcSV.debugMode then
        d(string.format("[IN:DEBUG] ATTR_ADDED unitTag=%s visual=%s attrType=%s value=%s",
            tostring(unitTag),
            tostring(unitAttributeVisual),
            tostring(attributeType),
            tostring(value)))
    end
end

local function OnAttributeVisualRemoved(eventCode, unitTag,
                                         unitAttributeVisual,
                                         attributeType,
                                         powerType,
                                         value, maxValue)
    if InterruptNarcSV.debugMode then
        d(string.format("[IN:DEBUG] ATTR_REMOVED unitTag=%s visual=%s attrType=%s value=%s",
            tostring(unitTag),
            tostring(unitAttributeVisual),
            tostring(attributeType),
            tostring(value)))
    end
end

local function OnDebugCommand(args)
    InterruptNarcSV.debugMode = not InterruptNarcSV.debugMode
    if InterruptNarcSV.debugMode then
        d("[InterruptNarc] Debug ON — interrupt an NPC and screenshot")
    else
        d("[InterruptNarc] Debug OFF")
    end
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= "InterruptNarc" then return end

    InterruptNarcSV = InterruptNarcSV or { debugMode = false }

    EVENT_MANAGER:RegisterForEvent("InterruptNarc", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnAttributeVisualUpdated)
    EVENT_MANAGER:RegisterForEvent("InterruptNarc", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnAttributeVisualAdded)
    EVENT_MANAGER:RegisterForEvent("InterruptNarc", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnAttributeVisualRemoved)

    SLASH_COMMANDS["/narcdebug"] = OnDebugCommand

    d("[InterruptNarc] Loaded. | /narcdebug then interrupt an NPC")
end

EVENT_MANAGER:RegisterForEvent("InterruptNarc_Load", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
