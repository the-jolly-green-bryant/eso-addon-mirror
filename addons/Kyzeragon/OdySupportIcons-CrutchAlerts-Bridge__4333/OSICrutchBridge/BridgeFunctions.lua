local OCB = OSICrutchBridge

-- We must keep track of active icons ourselves, because other addons
-- can't be trusted with just the returned keys. If an addon decides
-- to keep a list of icons they created and then clean it up much
-- later, we need to be able to verify that the intended one is being
-- deleted. We can't just delete via only key, which might make
-- Crutch discard a key that's newly in use somewhere else.
-- Use the table as the key so it can be checked by reference.
local activeIcons = {} -- {{key = "Space3"} = true}

local function StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

local textures = {
    ["odysupporticons/icons/green_arrow.dds"] = {path = "CrutchAlerts/assets/shape/chevron.dds", color = {0, 1, 0}}
}

local function ConvertTexture(texture)
    if (StartsWith(texture, "/")) then
        texture = texture:sub(2) -- Remove first /
    end

    if (StartsWith(texture:lower(), "odysupporticons")) then
        local replacement = textures[texture:lower()]
        if (replacement) then
            return replacement.path, replacement.color
        end
        -- TODO: map more textures
        CrutchAlerts.dbgOther("|cFFFF00OSI-Crutch Bridge: no texture replacement available for " .. texture .. "; using poop instead.")
        return "CrutchAlerts/assets/poop.dds"
    end
    return texture
end

---------------------------------------------------------------------
function OCB.OSI.GetIconSize()
    return OCB.savedOptions.size
end

local defaultColor = {1, 1, 1} -- opacity set later

---------------------------------------------------------------------
function OCB.OSI.CreatePositionIcon(x, y, z, texture, size, color, offset, callback)
    if (callback) then
        CrutchAlerts.dbgOther("|cFFFF00OSI-Crutch Bridge doesn't support callback in CreatePositionIcon! Continuing...|r")
    end

    local replacementColor
    texture, replacementColor = ConvertTexture(texture)
    if (not color) then
        if (replacementColor) then
            color = replacementColor
        else
            color = defaultColor
        end
    end
    color[4] = OCB.savedOptions.opacity

    offset = offset or 0
    size = size or OCB.OSI.GetIconSize()

    local key = CrutchAlerts.Drawing.CreateWorldTexture(
        texture,
        x, y + offset, z,
        size / 200, size / 200,
        color,
        false, -- useDepthBuffer
        true) -- faceCamera

    -- TODO: OSI returns a table with functions etc, but hopefully no addons besides QRH/ExoYs use that?
    local icon = {key = key, texture = texture}
    activeIcons[icon] = true
    return icon
end

function OCB.OSI.DiscardPositionIcon(icon)
    if (not activeIcons[icon]) then
        CrutchAlerts.dbgSpam("|cFF0000Something tried to DiscardPositionIcon an icon that's no longer active. |t100%:100%:" .. icon.texture .. "|t|r")
        return
    end
    activeIcons[icon] = nil
    CrutchAlerts.Drawing.RemoveWorldTexture(icon.key)
end

---------------------------------------------------------------------
local BRIDGE_UNIQUE_NAME = "OSICrutchBridge"
local BRIDGE_PRIORITY = 400

local function GetUnitTagForName(displayName)
    local unitTag
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        local name = GetUnitDisplayName(tag)
        if (name and name:lower() == displayName:lower()) then
            unitTag = tag
            break
        end
    end
    return unitTag
end

-- offset is not used
function OCB.OSI.SetMechanicIconForUnit(displayName, texture, size, color, offset, callback)
    if (callback) then
        CrutchAlerts.dbgOther("|cFFFF00OSI-Crutch Bridge doesn't support callback in CreatePositionIcon! Continuing...|r")
    end

    size = size or OCB.OSI.GetIconSize()

    local replacementColor
    texture, replacementColor = ConvertTexture(texture)
    if (not color) then
        if (replacementColor) then
            color = replacementColor
        else
            color = defaultColor
        end
    end
    color[4] = OCB.savedOptions.opacity

    local unitTag = GetUnitTagForName(displayName)
    if (unitTag) then
        CrutchAlerts.SetAttachedIconForUnit(
            unitTag,
            BRIDGE_UNIQUE_NAME,
            BRIDGE_PRIORITY,
            texture,
            size,
            color)
    else
        CrutchAlerts.dbgOther("|cFFFF00OSI-Crutch Bridge couldn't set mechanic icon for " .. displayName .. "|r")
    end
end

function OCB.OSI.RemoveMechanicIconForUnit(displayName)
    local unitTag = GetUnitTagForName(displayName)
    if (unitTag) then
        CrutchAlerts.RemoveAttachedIconForUnit(unitTag, BRIDGE_UNIQUE_NAME)
    else
        CrutchAlerts.dbgOther("|cFFFF00OSI-Crutch Bridge couldn't remove mechanic icon for " .. displayName .. "|r")
    end
end

function OCB.OSI.ResetMechanicIcons()
    CrutchAlerts.RemoveAllAttachedIcons(BRIDGE_UNIQUE_NAME)
end
