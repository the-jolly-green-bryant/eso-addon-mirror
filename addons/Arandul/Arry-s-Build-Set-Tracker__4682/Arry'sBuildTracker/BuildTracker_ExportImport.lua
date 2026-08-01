-- BuildTracker_ExportImport.lua
--
-- Turns a build table into a compact, shareable text string (and back).
--
-- NOTE on history: format bumped BT2 -> BT3. Previous versions only stored
-- setId+equipType+armorType+weaponType per slot and re-derived itemId on
-- import via GetItemIdForSlot. That silently broke slots assigned via
-- /bt setitem (which have no equipType/armorType/weaponType to re-derive
-- from), AND, once we discovered some sets have multiple valid "alias"
-- itemIds for the same slot (see BuildTracker_LibSetsAdapter.lua), it meant
-- an exported/reimported build could land on a different (though
-- functionally equivalent) alias than the one originally chosen. Storing
-- itemId directly and trusting it on import avoids both problems entirely -
-- what you picked is exactly what comes back.

BuildTracker = BuildTracker or {}
BuildTracker.ExportImport = {}

local ExportImport = BuildTracker.ExportImport

local EXPORT_FORMAT_VERSION = "BT3"
local FIELD_SEP = "."  -- separates name, each slot entry, and the checksum
local PART_SEP = ","   -- separates fields within a single slot entry

-- ---------------------------------------------------------------------------
-- Name escaping - percent-encode EVERY character that isn't a plain ASCII
-- letter or digit. This guarantees the encoded name can never contain a
-- space, our separators, a "|", or anything else that could be misread by
-- ESO's text renderer or the slash-command tokenizer.
-- ---------------------------------------------------------------------------

local function EncodeName(name)
    return (name:gsub("[^%w]", function(c)
        return string.format("%%%02X", c:byte())
    end))
end

local function DecodeName(str)
    return (str:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end))
end

-- ---------------------------------------------------------------------------
-- Checksum - catches a mis-copied/truncated paste with a clear error instead
-- of a confusing downstream failure. Not cryptographic, just a sanity check.
-- ---------------------------------------------------------------------------

local function Checksum(str)
    local sum = 0
    for i = 1, #str do
        sum = (sum * 31 + str:byte(i)) % 1000000007
    end
    return sum
end

-- ---------------------------------------------------------------------------
-- Export
-- ---------------------------------------------------------------------------

function ExportImport.ExportBuild(buildId)
    local build = BuildTracker.Data.GetBuild(buildId)
    if not build then
        return nil, "No build with that id"
    end

    local parts = { EXPORT_FORMAT_VERSION, EncodeName(build.name) }

    for _, slotId in ipairs(BuildTracker.SLOT_ORDER) do
        local slotData = build.slots[slotId]
        if slotData then
            local entry = table.concat({
                slotId,
                slotData.setId,
                slotData.itemId,
                slotData.equipType or 0,
                slotData.armorType or 0,
                slotData.weaponType or 0,
            }, PART_SEP)
            table.insert(parts, entry)
        end
    end

    local body = table.concat(parts, FIELD_SEP)
    local checksum = Checksum(body)

    return body .. FIELD_SEP .. "C" .. checksum
end

-- ---------------------------------------------------------------------------
-- Import
-- ---------------------------------------------------------------------------

function ExportImport.ImportBuild(exportString)
    if not exportString or exportString == "" then
        return nil, "Empty import string"
    end
    exportString = exportString:match("^%s*(.-)%s*$") -- trim whitespace/quotes leftovers

    local fields = {}
    for token in (exportString .. FIELD_SEP):gmatch("([^%" .. FIELD_SEP .. "]*)%" .. FIELD_SEP) do
        table.insert(fields, token)
    end

    if #fields < 3 then
        return nil, "Doesn't look like a complete Build Tracker export string"
    end

    -- Last field is the checksum, everything before it is the body we hashed.
    local checksumField = fields[#fields]
    table.remove(fields, #fields)
    local body = table.concat(fields, FIELD_SEP)

    local expectedChecksum = "C" .. Checksum(body)
    if checksumField ~= expectedChecksum then
        return nil, "Checksum mismatch - the string was likely cut off or altered when copied"
    end

    if fields[1] ~= EXPORT_FORMAT_VERSION then
        return nil, "Unrecognized or incompatible export format (expected " .. EXPORT_FORMAT_VERSION .. ")"
    end

    local name = DecodeName(fields[2])
    local slotEntries = {}
    for i = 3, #fields do
        local slotId, setId, itemId, equipType, armorType, weaponType =
            fields[i]:match("^(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)$")
        if not slotId then
            return nil, "Malformed slot entry: " .. tostring(fields[i])
        end
        slotId, setId, itemId, equipType, armorType, weaponType =
            tonumber(slotId), tonumber(setId), tonumber(itemId), tonumber(equipType), tonumber(armorType), tonumber(weaponType)
        if equipType == 0 then equipType = nil end
        if armorType == 0 then armorType = nil end
        if weaponType == 0 then weaponType = nil end
        table.insert(slotEntries, {
            slotId = slotId, setId = setId, itemId = itemId,
            equipType = equipType, armorType = armorType, weaponType = weaponType,
        })
    end

    -- Trust the stored itemId directly rather than re-deriving it - see the
    -- header comment for why. We only validate that the set itself still
    -- exists, as a sanity check against importing something LibSets no
    -- longer recognizes at all.
    local resolvedSlots = {}
    for _, entry in ipairs(slotEntries) do
        if BuildTracker.Sets.SetExists(entry.setId) then
            resolvedSlots[entry.slotId] = {
                setId = entry.setId,
                itemId = entry.itemId,
                equipType = entry.equipType,
                armorType = entry.armorType,
                weaponType = entry.weaponType,
            }
        else
            BuildTracker.Debug("Import warning: setId %s no longer exists, dropping it", tostring(entry.setId))
        end
    end

    local newId = BuildTracker.Data.CreateBuild(name)
    local build = BuildTracker.Data.GetBuild(newId)
    build.slots = resolvedSlots

    CALLBACK_MANAGER:FireCallbacks(BuildTracker.EVENTS.BUILDS_IMPORTED, newId)
    return newId
end
