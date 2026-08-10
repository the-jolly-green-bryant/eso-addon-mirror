HF.LayoutExport = {}

local MAX_URL_LENGTH = 7800 -- TSC Data Hub uses 7800 against an ~8000 URL ceiling with safety margin.
local MAX_IMPORT_ITEM_COUNT = 2000
local MAX_IMPORT_PATH_NODES = 100
local MAX_IMPORT_DATA_LENGTH = 2000000
local MAX_WORLD_COORDINATE = 2147483647
local MAX_ORIENTATION_RADIANS = (math.pi * 2) + 0.01
local DEFAULT_ENDPOINT = ""

local function Trim(value)
    return string.match(tostring(value or ""), "^%s*(.-)%s*$") or ""
end

local function ValidateHttpUrl(value)
    local url = Trim(value)
    if url == "" then
        return nil, "no export endpoint is configured"
    end
    if #url > 2000 then
        return nil, "the export endpoint is too long"
    end
    if string.find(url, "%s") then
        return nil, "the export endpoint cannot contain spaces"
    end

    local lowerUrl = string.lower(url)
    if not string.match(lowerUrl, "^https?://") then
        return nil, "the export endpoint must start with http:// or https://"
    end
    local authority = string.match(lowerUrl, "^https?://([^/%?#]+)")
    if not authority or authority == "" then
        return nil, "the export endpoint must include a host"
    end
    return url
end

local function EnsureIngestPath(endpoint)
    local path, suffix = string.match(endpoint, "^([^%?#]*)(.*)$")
    path = path or endpoint
    suffix = suffix or ""
    if not string.match(path, "/ingest/?$") then
        path = string.gsub(path, "/+$", "") .. "/ingest"
    end
    return path .. suffix
end

local function UrlEncode(value)
    value = tostring(value or "")
    value = string.gsub(value, "\n", "\r\n")
    value = string.gsub(value, "([^%w%-_%.~])", function(char)
        return string.format("%%%02X", string.byte(char))
    end)
    return value
end

local function EscapeField(value)
    value = tostring(value or "")
    value = string.gsub(value, "\\", "\\\\")
    value = string.gsub(value, "|", "\\p")
    value = string.gsub(value, "~", "\\t")
    value = string.gsub(value, ",", "\\c")
    value = string.gsub(value, "\n", "\\n")
    value = string.gsub(value, "\r", "")
    return value
end

local function RoundNumber(value)
    value = tonumber(value) or 0
    if value >= 0 then return math.floor(value + 0.5) end
    return math.ceil(value - 0.5)
end

local function IsFiniteNumber(value)
    return type(value) == "number"
        and value == value
        and value ~= math.huge
        and value ~= -math.huge
end

local function IsIntegerInRange(value, minimum, maximum)
    return IsFiniteNumber(value)
        and value == math.floor(value)
        and value >= minimum
        and value <= maximum
end

local function IsValidOrientation(value)
    return IsFiniteNumber(value) and math.abs(value) <= MAX_ORIENTATION_RADIANS
end

local function EncodeOptionalNumber(value, scale)
    if value == nil then return "" end
    return tostring(RoundNumber((tonumber(value) or 0) * (scale or 1)))
end

local function SerializeFurniturePath(path)
    if type(path) ~= "table" or type(path.nodes) ~= "table" or #path.nodes == 0 then
        return ""
    end

    local pathParts = {
        table.concat({
            "1",
            EncodeOptionalNumber(path.state),
            EncodeOptionalNumber(path.followType),
            EncodeOptionalNumber(path.startingNodeIndex or 1),
        }, ":"),
    }

    for _, node in ipairs(path.nodes) do
        table.insert(pathParts, table.concat({
            EncodeOptionalNumber(node.worldX),
            EncodeOptionalNumber(node.worldY),
            EncodeOptionalNumber(node.worldZ),
            EncodeOptionalNumber(node.pitch, 10000),
            EncodeOptionalNumber(node.yaw, 10000),
            EncodeOptionalNumber(node.roll, 10000),
            EncodeOptionalNumber(node.speed),
            EncodeOptionalNumber(node.delayMs),
        }, ":"))
    end

    return EscapeField(table.concat(pathParts, "/"))
end

local function SerializeLayoutV1(layout)
    local parts = {}
    table.insert(parts, "HFEXPORT|1")
    table.insert(parts, table.concat({
        "META",
        EscapeField(layout.id),
        EscapeField(layout.name),
        EscapeField(layout.author),
        tostring(layout.houseId or 0),
        EscapeField(layout.houseName),
        tostring(layout.timestamp or 0),
        tostring(layout.items and #layout.items or layout.furnitureCount or 0),
    }, "|"))

    for _, item in ipairs(layout.items or {}) do
        table.insert(parts, table.concat({
            "ITEM",
            tostring(item.furnitureDataId or 0),
            EscapeField(item.itemName),
            tostring(item.itemId or 0),
            tostring(item.collectibleId or 0),
            tostring(item.worldX or 0),
            tostring(item.worldY or 0),
            tostring(item.worldZ or 0),
            string.format("%.6f", item.pitch or 0),
            string.format("%.6f", item.yaw or 0),
            string.format("%.6f", item.roll or 0),
            tostring(item.stateIndex or 0),
        }, "|"))
    end

    return table.concat(parts, "\n")
end

local function SerializeLayoutV2(layout)
    local names = {}
    local nameIndex = {}
    local itemParts = {}

    local function GetNameIndex(name)
        name = tostring(name or "Unknown Furniture")
        local key = name
        if not nameIndex[key] then
            table.insert(names, EscapeField(name))
            nameIndex[key] = #names
        end
        return nameIndex[key]
    end

    for _, item in ipairs(layout.items or {}) do
        local idx = GetNameIndex(item.itemName)
        table.insert(itemParts, table.concat({
            tostring(item.furnitureDataId or 0),
            tostring(item.itemId or 0),
            tostring(item.collectibleId or 0),
            tostring(RoundNumber(item.worldX)),
            tostring(RoundNumber(item.worldY)),
            tostring(RoundNumber(item.worldZ)),
            tostring(RoundNumber((item.pitch or 0) * 10000)),
            tostring(RoundNumber((item.yaw or 0) * 10000)),
            tostring(RoundNumber((item.roll or 0) * 10000)),
            tostring(item.stateIndex or 0),
            tostring(idx),
            EscapeField(item.sourceFurnitureId or ""),
            EscapeField(item.parentSourceFurnitureId or ""),
            SerializeFurniturePath(item.path),
        }, ","))
    end

    local meta = table.concat({
        EscapeField(layout.id),
        EscapeField(layout.name),
        EscapeField(layout.author),
        tostring(layout.houseId or 0),
        EscapeField(layout.houseName),
        tostring(layout.timestamp or 0),
        tostring(layout.items and #layout.items or layout.furnitureCount or 0),
        EscapeField(layout.ownerName or ""),
        EscapeField(layout.source or ""),
        tostring(layout.snapshotVersion or 2),
        EscapeField(layout.coordinateSpace or "world"),
    }, "|")

    return "HFv2:" .. meta .. "~" .. table.concat(names, "~") .. "~" .. table.concat(itemParts, ";")
end

local function SerializeLayout(layout, format)
    if format == "v1" then return SerializeLayoutV1(layout) end
    return SerializeLayoutV2(layout)
end

local function MakeSessionId(layout)
    local id = layout and layout.id or "layout"
    return string.format("%s-%d", tostring(id), GetTimeStamp())
end

local function BuildEncodedChunksForUrl(endpoint, meta, payload)
    local chunks = {}
    local maxChunkSize = MAX_URL_LENGTH - #endpoint - #meta - 80
    if maxChunkSize < 300 then maxChunkSize = 300 end
    local encodedPayload = UrlEncode(payload or "")
    local pos = 1

    while pos <= #encodedPayload do
        local endPos = math.min(pos + maxChunkSize - 1, #encodedPayload)
        if endPos < #encodedPayload then
            if string.sub(encodedPayload, endPos, endPos) == "%" then
                endPos = endPos - 1
            elseif endPos > pos and string.sub(encodedPayload, endPos - 1, endPos - 1) == "%" then
                endPos = endPos - 2
            end
        end
        if endPos < pos then endPos = pos + maxChunkSize - 1 end
        table.insert(chunks, string.sub(encodedPayload, pos, endPos))
        pos = endPos + 1
    end
    if #chunks == 0 then table.insert(chunks, "") end

    return chunks
end

local function BuildUrls(endpoint, kind, record, payload, format)
    local urls = {}
    local sessionId = MakeSessionId(record)
    local base = endpoint
    local sep = string.find(base, "?", 1, true) and "&" or "?"
    local meta = string.format(
        "%skind=%s&sid=%s&layoutId=%s&name=%s&author=%s&houseId=%s&houseName=%s&format=%s",
        sep,
        UrlEncode(kind or "layout"),
        UrlEncode(sessionId),
        UrlEncode(record.id or ""),
        UrlEncode(record.name or ""),
        UrlEncode(record.author or ""),
        UrlEncode(record.houseId or 0),
        UrlEncode(record.houseName or ""),
        UrlEncode(format or "v2")
    )

    local chunks = BuildEncodedChunksForUrl(base, meta, payload)

    for i, chunk in ipairs(chunks) do
        urls[i] = string.format("%s%s&i=%d&n=%d&d=%s", base, meta, i, #chunks, chunk)
    end

    return urls, sessionId
end

local function RefreshExportControls()
    if HF.RefreshUI then HF.RefreshUI() end
    if KEYBIND_STRIP and HF.hiddenListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
    end
end

local function GetQueue()
    local runtimeQueue = HF.runtime and HF.runtime.exportQueue
    if runtimeQueue and runtimeQueue.urls then return runtimeQueue end

    local savedQueue = HF.savedVars and HF.savedVars.exportQueue
    if savedQueue and savedQueue.urls then
        HF.runtime.exportQueue = savedQueue
        return savedQueue
    end
    return nil
end

local function SaveQueue(queue)
    if HF.runtime then HF.runtime.exportQueue = queue end
    if HF.savedVars then HF.savedVars.exportQueue = queue end
end

local function GetValidatedEndpoint(showError)
    local endpoint, reason = ValidateHttpUrl(HF.LayoutExport.GetEndpoint())
    if not endpoint then
        if showError ~= false then
            HF.Chat("Export unavailable: " .. tostring(reason) .. ". Use /hf endpoint https://your-host/ingest")
        end
        return nil
    end
    return EnsureIngestPath(endpoint)
end

local function GetBaseUrl()
    local endpoint = GetValidatedEndpoint(false)
    if not endpoint then return nil end
    return string.gsub(endpoint, "/ingest.*$", "")
end

local function BuildStatusUrl(queueOrSessionId)
    local sessionId = type(queueOrSessionId) == "table" and queueOrSessionId.sessionId or queueOrSessionId
    if not sessionId or sessionId == "" then return nil end
    local baseUrl = GetBaseUrl()
    if not baseUrl then return nil end
    return baseUrl .. "/status?sid=" .. UrlEncode(sessionId)
end

local function SetQueueState(queue, state)
    if queue then queue.state = state end
    SaveQueue(queue)
    RefreshExportControls()
end

local function ParseMissingList(value)
    local missing = {}
    value = tostring(value or "")
    for numberText in string.gmatch(value, "(%d+)") do
        local index = tonumber(numberText)
        if index and index > 0 then table.insert(missing, index) end
    end
    table.sort(missing)
    return missing
end

function HF.LayoutExport.HasPendingExportUrl()
    local queue = GetQueue()
    return queue and queue.urls and queue.pending and queue.position and queue.position <= #queue.pending
end

function HF.LayoutExport.GetQueue()
    return GetQueue()
end

function HF.LayoutExport.GetQueueLabel()
    local queue = GetQueue()
    if not queue or not queue.urls then return "" end
    local sent = HF.TableCount(queue.sent or {})
    local total = queue.totalChunks or #queue.urls
    if HF.LayoutExport.HasPendingExportUrl() then
        local chunkIndex = queue.pending[queue.position]
        return string.format("%s chunk %d/%d (%d sent)", queue.label or "Export", chunkIndex or 0, total, sent)
    end
    return string.format("%s %s: %d/%d sent", queue.label or "Export", queue.state or "checking", sent, total)
end

function HF.LayoutExport.OpenNextQueuedUrl()
    if not RequestOpenUnsafeURL then
        HF.Chat("RequestOpenUnsafeURL is unavailable on this client.")
        return false
    end

    local queue = GetQueue()
    if not queue or not queue.urls or not queue.pending or not queue.position or queue.position > #queue.pending then
        HF.Chat("No export chunk URL is waiting. Use /hf status to open the upload status page.")
        if HF.OpenExportQueueUI then HF.OpenExportQueueUI() end
        return false
    end

    if HF.ui then HF.ui.screenMode = "export" end
    local chunkIndex = queue.pending[queue.position]
    local url = queue.urls[chunkIndex]
    if not url then
        HF.Chat("Queued chunk URL is missing. Rebuild the export queue.")
        SetQueueState(queue, "failed")
        return false
    end
    local validUrl, reason = ValidateHttpUrl(url)
    if not validUrl then
        HF.Chat("Queued export URL rejected: " .. tostring(reason) .. ". Rebuild the export queue with a valid endpoint.")
        SetQueueState(queue, "failed")
        return false
    end

    RequestOpenUnsafeURL(validUrl)
    queue.sent = queue.sent or {}
    queue.sent[chunkIndex] = true
    queue.position = queue.position + 1
    queue.state = queue.position <= #queue.pending and "sending" or "checking"

    if queue.position <= #queue.pending then
        HF.Chat(string.format("Opened export chunk %d/%d. Approve it, return to HousingForge, then press [A] for the next chunk.", chunkIndex, queue.totalChunks or #queue.urls))
    else
        HF.Chat(string.format("Opened final queued chunk. Use /hf status to check session %s.", tostring(queue.sessionId)))
    end
    SaveQueue(queue)
    RefreshExportControls()
    return true
end

local function QueueExportUrls(urls, sessionId, label, format)
    SaveQueue({
        urls = urls or {},
        pending = {},
        position = 1,
        sent = {},
        sessionId = sessionId,
        label = label or "Export",
        totalChunks = #(urls or {}),
        state = "pending",
        format = format or "v2",
        missing = {},
    })

    local queue = GetQueue()
    for i = 1, queue.totalChunks do table.insert(queue.pending, i) end
    SaveQueue(queue)

    if HF.OpenExportQueueUI then HF.OpenExportQueueUI() end
    HF.Chat(string.format("%s ready: %d chunks. Press [A] for each URL, then /hf status.", label or "Export", queue.totalChunks))
    RefreshExportControls()
    return true
end

function HF.LayoutExport.GetEndpoint()
    local configured = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.exportEndpoint
    if configured == nil then return DEFAULT_ENDPOINT end
    return Trim(configured)
end

function HF.LayoutExport.SetEndpoint(endpoint)
    local normalized, reason = ValidateHttpUrl(endpoint)
    if not normalized then
        HF.Chat("Export endpoint rejected: " .. tostring(reason) .. ". Use /hf endpoint https://your-host/ingest")
        return false
    end
    if not HF.savedVars or not HF.savedVars.settings then
        HF.Chat("HousingForge is not ready to save an export endpoint yet.")
        return false
    end
    normalized = EnsureIngestPath(normalized)
    HF.savedVars.settings.exportEndpoint = normalized
    HF.Chat("Export endpoint set to: " .. normalized)
    if HF.RefreshUI then HF.RefreshUI() end
    return true
end

function HF.LayoutExport.GetFormat()
    local format = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.exportFormat or "v2"
    if format ~= "v1" and format ~= "v2" then format = "v2" end
    return format
end

function HF.LayoutExport.SetFormat(format)
    format = tostring(format or ""):lower()
    if format ~= "v1" and format ~= "v2" then
        HF.Chat("Usage: /hf format v1|v2")
        return false
    end
    HF.savedVars.settings.exportFormat = format
    HF.Chat("Export format set to " .. format .. ".")
    if HF.RefreshUI then HF.RefreshUI() end
    return true
end

function HF.LayoutExport.OpenStatusUrl()
    local queue = GetQueue()
    if not queue or not queue.sessionId then
        HF.Chat("No export session is saved.")
        return false
    end
    if not RequestOpenUnsafeURL then
        HF.Chat("RequestOpenUnsafeURL is unavailable on this client.")
        return false
    end
    queue.state = "checking"
    SaveQueue(queue)
    local statusUrl = BuildStatusUrl(queue)
    if not statusUrl then
        HF.Chat("Export status unavailable: configure a valid http:// or https:// endpoint first.")
        return false
    end
    RequestOpenUnsafeURL(statusUrl)
    HF.Chat("Opened export status page. If it lists missing chunks, run /hf retrymissing 1,2,3 with those numbers.")
    RefreshExportControls()
    return true
end

function HF.LayoutExport.QueueMissing(missingText)
    local queue = GetQueue()
    if not queue or not queue.urls then
        HF.Chat("No saved export queue to retry.")
        return false
    end
    local missing = ParseMissingList(missingText)
    if #missing == 0 then
        HF.Chat("Usage: /hf retrymissing 1,2,3 using the missing chunks from /hf status.")
        HF.LayoutExport.OpenStatusUrl()
        return false
    end

    local pending = {}
    for _, chunkIndex in ipairs(missing) do
        if queue.urls[chunkIndex] then table.insert(pending, chunkIndex) end
    end
    if #pending == 0 then
        HF.Chat("None of those missing chunks exist in this queue.")
        return false
    end

    queue.pending = pending
    queue.position = 1
    queue.state = "missing"
    queue.missing = pending
    SaveQueue(queue)
    HF.Chat(string.format("Queued %d missing chunks only. Press [A] to resend them.", #pending))
    if HF.OpenExportQueueUI then HF.OpenExportQueueUI() end
    RefreshExportControls()
    return true
end

function HF.LayoutExport.ClearQueue()
    SaveQueue(nil)
    HF.Chat("Export queue cleared.")
    RefreshExportControls()
end

local function UnescapeField(value)
    value = tostring(value or "")
    local decoded = {}
    local escapeValues = {
        ["\\"] = "\\",
        p = "|",
        t = "~",
        c = ",",
        n = "\n",
    }
    local index = 1
    while index <= #value do
        local character = string.sub(value, index, index)
        if character == "\\" and index < #value then
            local escapeCode = string.sub(value, index + 1, index + 1)
            local replacement = escapeValues[escapeCode]
            if replacement then
                decoded[#decoded + 1] = replacement
                index = index + 2
            else
                decoded[#decoded + 1] = character
                index = index + 1
            end
        else
            decoded[#decoded + 1] = character
            index = index + 1
        end
    end
    return table.concat(decoded)
end

local function SplitDelimited(value, delimiter)
    local parts = {}
    local startIndex = 1
    while true do
        local delimiterIndex = string.find(value, delimiter, startIndex, true)
        if not delimiterIndex then
            table.insert(parts, string.sub(value, startIndex))
            break
        end
        table.insert(parts, string.sub(value, startIndex, delimiterIndex - 1))
        startIndex = delimiterIndex + #delimiter
    end
    return parts
end

local function ParseOptionalNumber(value, scale)
    if value == nil or value == "" then return nil, true end
    local numberValue = tonumber(value)
    if not numberValue then return nil, false end
    return numberValue / (scale or 1), true
end

local function DeserializeFurniturePath(value, strict)
    local pathText = UnescapeField(value)
    if pathText == "" then return nil end

    local pathParts = SplitDelimited(pathText, "/")
    local header = SplitDelimited(pathParts[1] or "", ":")
    if header[1] ~= "1" then
        return nil, strict and "unsupported furniture path version" or nil
    end
    if #pathParts - 1 > MAX_IMPORT_PATH_NODES then
        return nil, strict and "furniture path has too many nodes" or nil
    end

    local state, stateOk = ParseOptionalNumber(header[2])
    local followType, followOk = ParseOptionalNumber(header[3])
    local startingNodeIndex, startOk = ParseOptionalNumber(header[4])
    if not stateOk or not followOk or not startOk then
        return nil, strict and "furniture path header is invalid" or nil
    end

    local path = {
        state = state,
        followType = followType,
        startingNodeIndex = startingNodeIndex or 1,
        nodes = {},
    }

    for pathIndex = 2, #pathParts do
        local nodeParts = SplitDelimited(pathParts[pathIndex], ":")
        if #nodeParts < 8 then
            return nil, strict and "furniture path node is incomplete" or nil
        end

        local worldX, worldXOk = ParseOptionalNumber(nodeParts[1])
        local worldY, worldYOk = ParseOptionalNumber(nodeParts[2])
        local worldZ, worldZOk = ParseOptionalNumber(nodeParts[3])
        local pitch, pitchOk = ParseOptionalNumber(nodeParts[4], 10000)
        local yaw, yawOk = ParseOptionalNumber(nodeParts[5], 10000)
        local roll, rollOk = ParseOptionalNumber(nodeParts[6], 10000)
        local speed, speedOk = ParseOptionalNumber(nodeParts[7])
        local delayMs, delayOk = ParseOptionalNumber(nodeParts[8])
        if not worldXOk or not worldYOk or not worldZOk or not pitchOk or not yawOk or not rollOk or not speedOk or not delayOk
            or worldX == nil or worldY == nil or worldZ == nil then
            return nil, strict and "furniture path node contains invalid values" or nil
        end

        table.insert(path.nodes, {
            worldX = worldX,
            worldY = worldY,
            worldZ = worldZ,
            pitch = pitch or 0,
            yaw = yaw or 0,
            roll = roll or 0,
            speed = speed,
            delayMs = delayMs or 0,
        })
    end

    if #path.nodes == 0 then
        return nil, strict and "furniture path has no nodes" or nil
    end
    return path
end

local function DecodeLayoutV2(raw, strict)
    raw = tostring(raw or "")
    if strict and #raw > MAX_IMPORT_DATA_LENGTH then
        return nil, string.format("HFv2 data exceeds the %d-byte import limit", MAX_IMPORT_DATA_LENGTH)
    end
    if string.sub(raw, 1, 5) ~= "HFv2:" then return nil, "data is not an HFv2 layout" end
    local body = string.sub(raw, 6)
    local sections = SplitDelimited(body, "~")
    if #sections < 2 then return nil, "HFv2 layout sections are incomplete" end
    local meta = sections[1]
    local itemsText = sections[#sections] or ""
    local names = {}
    for i = 2, #sections - 1 do names[i - 1] = UnescapeField(sections[i]) end
    local metaParts = SplitDelimited(meta, "|")
    if strict and #metaParts < 7 then return nil, "HFv2 metadata is incomplete" end
    local declaredCount = tonumber(metaParts[7])
    local layout = {
        id = UnescapeField(metaParts[1]),
        name = UnescapeField(metaParts[2]),
        author = UnescapeField(metaParts[3]),
        houseId = tonumber(metaParts[4]) or 0,
        houseName = UnescapeField(metaParts[5]),
        timestamp = tonumber(metaParts[6]) or 0,
        furnitureCount = tonumber(metaParts[7]) or 0,
        ownerName = UnescapeField(metaParts[8]),
        source = UnescapeField(metaParts[9]),
        snapshotVersion = tonumber(metaParts[10]) or 1,
        coordinateSpace = UnescapeField(metaParts[11]),
        items = {},
    }
    if layout.coordinateSpace == "" then layout.coordinateSpace = "world" end

    local serializedItems = SplitDelimited(itemsText, ";")
    for _, itemText in ipairs(serializedItems) do
        if itemText ~= "" then
            local parts = SplitDelimited(itemText, ",")
            if strict and #parts < 11 then return nil, "an HFv2 furniture record is incomplete" end
            local furnitureDataId = tonumber(parts[1])
            local itemId = tonumber(parts[2])
            local collectibleId = tonumber(parts[3])
            local worldX = tonumber(parts[4])
            local worldY = tonumber(parts[5])
            local worldZ = tonumber(parts[6])
            local pitch = tonumber(parts[7])
            local yaw = tonumber(parts[8])
            local roll = tonumber(parts[9])
            local stateIndex = tonumber(parts[10])
            local nameIndex = tonumber(parts[11])
            if strict and (not furnitureDataId or not itemId or not collectibleId or not worldX or not worldY or not worldZ
                or not pitch or not yaw or not roll or not stateIndex or not nameIndex) then
                return nil, "an HFv2 furniture record contains invalid numbers"
            end
            if strict and (nameIndex < 1 or nameIndex ~= math.floor(nameIndex) or not names[nameIndex] or names[nameIndex] == "") then
                return nil, "an HFv2 furniture record has an invalid name reference"
            end

            local path, pathError = DeserializeFurniturePath(parts[14], strict)
            if strict and pathError then return nil, pathError end
            table.insert(layout.items, {
                furnitureDataId = furnitureDataId or 0,
                itemId = itemId or 0,
                collectibleId = collectibleId or 0,
                worldX = worldX or 0,
                worldY = worldY or 0,
                worldZ = worldZ or 0,
                pitch = (pitch or 0) / 10000,
                yaw = (yaw or 0) / 10000,
                roll = (roll or 0) / 10000,
                stateIndex = stateIndex or 0,
                itemName = names[nameIndex] or "Unknown",
                sourceFurnitureId = UnescapeField(parts[12]),
                parentSourceFurnitureId = UnescapeField(parts[13]),
                path = path,
            })
        end
    end
    layout.furnitureCount = #layout.items
    return layout, nil, declaredCount
end

function HF.LayoutExport.DecodeLayoutData(raw)
    local layout = DecodeLayoutV2(raw, false)
    return layout
end

local function ValidateImportedLayout(layout, declaredCount)
    if not layout then return false, "the layout could not be decoded" end
    if Trim(layout.id) == "" then return false, "the layout id is missing" end
    if Trim(layout.name) == "" then return false, "the layout name is missing" end
    if Trim(layout.houseName) == "" then return false, "the house name is missing" end
    if #layout.id > 128 or #layout.name > 128 or #layout.houseName > 128
        or #(layout.author or "") > 128 or #(layout.ownerName or "") > 128 or #(layout.source or "") > 64 then
        return false, "layout metadata is too long"
    end

    local houseId = tonumber(layout.houseId)
    if not houseId or houseId <= 0 or houseId ~= math.floor(houseId) then
        return false, "the house id is invalid"
    end
    if GetCollectibleIdForHouse and (GetCollectibleIdForHouse(houseId) or 0) == 0 then
        return false, "the house id is not recognized by this client"
    end

    if not declaredCount or declaredCount < 0 or declaredCount ~= math.floor(declaredCount) then
        return false, "the declared furniture count is invalid"
    end
    if declaredCount > MAX_IMPORT_ITEM_COUNT then
        return false, string.format("the layout exceeds the %d-item import limit", MAX_IMPORT_ITEM_COUNT)
    end
    if type(layout.items) ~= "table" or declaredCount ~= #layout.items then
        return false, "the declared furniture count does not match the decoded items"
    end
    if layout.coordinateSpace ~= "world" then
        return false, "only world-coordinate HFv2 layouts are supported"
    end
    if not layout.snapshotVersion or layout.snapshotVersion < 1 or layout.snapshotVersion > 2 or layout.snapshotVersion ~= math.floor(layout.snapshotVersion) then
        return false, "the layout snapshot version is invalid"
    end

    for itemIndex, item in ipairs(layout.items) do
        if (item.furnitureDataId or 0) <= 0 and (item.itemId or 0) <= 0 and (item.collectibleId or 0) <= 0 then
            return false, string.format("furniture item %d has no usable item identity", itemIndex)
        end
        if not IsIntegerInRange(item.furnitureDataId, 0, MAX_WORLD_COORDINATE)
            or not IsIntegerInRange(item.itemId, 0, MAX_WORLD_COORDINATE)
            or not IsIntegerInRange(item.collectibleId, 0, MAX_WORLD_COORDINATE)
            or not IsIntegerInRange(item.stateIndex, 0, MAX_WORLD_COORDINATE) then
            return false, string.format("furniture item %d has invalid identifiers or state", itemIndex)
        end
        if not IsIntegerInRange(item.worldX, -MAX_WORLD_COORDINATE, MAX_WORLD_COORDINATE)
            or not IsIntegerInRange(item.worldY, -MAX_WORLD_COORDINATE, MAX_WORLD_COORDINATE)
            or not IsIntegerInRange(item.worldZ, -MAX_WORLD_COORDINATE, MAX_WORLD_COORDINATE)
            or not IsValidOrientation(item.pitch)
            or not IsValidOrientation(item.yaw)
            or not IsValidOrientation(item.roll) then
            return false, string.format("furniture item %d has an invalid transform", itemIndex)
        end
        if #(item.itemName or "") > 256 or #(item.sourceFurnitureId or "") > 32 or #(item.parentSourceFurnitureId or "") > 32 then
            return false, string.format("furniture item %d contains oversized text", itemIndex)
        end
        if item.path then
            if type(item.path.nodes) ~= "table" or #item.path.nodes < 1 or #item.path.nodes > MAX_IMPORT_PATH_NODES
                or (item.path.state ~= nil and not IsIntegerInRange(item.path.state, 0, MAX_WORLD_COORDINATE))
                or (item.path.followType ~= nil and not IsIntegerInRange(item.path.followType, 0, MAX_WORLD_COORDINATE))
                or not IsIntegerInRange(item.path.startingNodeIndex or 1, 1, #item.path.nodes) then
                return false, string.format("furniture item %d has invalid path metadata", itemIndex)
            end
            for nodeIndex, node in ipairs(item.path.nodes) do
                if not IsIntegerInRange(node.worldX, -MAX_WORLD_COORDINATE, MAX_WORLD_COORDINATE)
                    or not IsIntegerInRange(node.worldY, -MAX_WORLD_COORDINATE, MAX_WORLD_COORDINATE)
                    or not IsIntegerInRange(node.worldZ, -MAX_WORLD_COORDINATE, MAX_WORLD_COORDINATE)
                    or not IsValidOrientation(node.pitch)
                    or not IsValidOrientation(node.yaw)
                    or not IsValidOrientation(node.roll)
                    or (node.speed ~= nil and not IsIntegerInRange(node.speed, 0, MAX_WORLD_COORDINATE))
                    or not IsIntegerInRange(node.delayMs or 0, 0, MAX_WORLD_COORDINATE) then
                    return false, string.format("furniture item %d path node %d is invalid", itemIndex, nodeIndex)
                end
            end
        end
    end
    return true
end

local function MakeImportedLayoutId(sourceId, houseId)
    local safeSourceId = string.gsub(Trim(sourceId), "[^%w%-_]", "-")
    safeSourceId = string.gsub(safeSourceId, "%-+", "-")
    safeSourceId = string.sub(safeSourceId, 1, 72)
    if safeSourceId == "" then safeSourceId = tostring(houseId or 0) end

    local baseId = "import-" .. safeSourceId
    local candidate = baseId
    local suffix = 2
    while HF.savedVars.layouts[candidate] do
        candidate = baseId .. "-" .. tostring(suffix)
        suffix = suffix + 1
    end
    return candidate
end

function HF.LayoutExport.ImportLayoutData(raw, nameOverride)
    if not HF.savedVars then
        local reason = "HousingForge saved data is not initialized"
        HF.Chat("Layout import failed: " .. reason .. ".")
        return nil, reason
    end
    if type(HF.savedVars.layouts) ~= "table" then HF.savedVars.layouts = {} end

    local layout, decodeError, declaredCount = DecodeLayoutV2(raw, true)
    if not layout then
        HF.Chat("Layout import failed: " .. tostring(decodeError) .. ".")
        return nil, decodeError
    end

    local valid, validationError = ValidateImportedLayout(layout, declaredCount)
    if not valid then
        HF.Chat("Layout import failed: " .. tostring(validationError) .. ".")
        return nil, validationError
    end

    local override = Trim(nameOverride)
    if override ~= "" then
        layout.name = string.sub(override, 1, 64)
    else
        layout.name = string.sub(layout.name, 1, 64)
    end
    local sourceLayoutId = layout.id
    local sourceType = layout.source
    layout.id = MakeImportedLayoutId(sourceLayoutId, layout.houseId)
    layout.sourceLayoutId = sourceLayoutId
    layout.importedSource = sourceType
    layout.source = "imported"
    layout.imported = true
    layout.marketplace = false
    layout.importedAt = GetTimeStamp and GetTimeStamp() or layout.timestamp
    layout.furnitureCount = #layout.items

    HF.savedVars.layouts[layout.id] = layout
    HF.savedVars.lastSelectedLayoutId = layout.id

    if HF.ui then
        HF.ui.layoutViewMode = "local"
        if HF.BuildLayoutList then HF.BuildLayoutList() end
        for index, savedLayout in ipairs(HF.ui.sortedLayouts or {}) do
            if savedLayout.id == layout.id then
                HF.ui.selectedLayoutIndex = index
                local maxVisible = HF.ui.maxVisibleLayouts or 10
                local scrollOffset = HF.ui.layoutScrollOffset or 0
                if index <= scrollOffset then
                    HF.ui.layoutScrollOffset = index - 1
                elseif index > scrollOffset + maxVisible then
                    HF.ui.layoutScrollOffset = index - maxVisible
                end
                break
            end
        end
        if HF.SyncHiddenList then HF.SyncHiddenList() end
    end
    if HF.RefreshUI then HF.RefreshUI() end
    HF.Chat(string.format("Imported '%s' with %d furniture items.", layout.name, layout.furnitureCount))
    return layout
end

local function ExportLayoutWithKind(layout, kind, label, formatOverride)
    if not layout then
        HF.Chat("No layout selected to export.")
        return false
    end
    if not RequestOpenUnsafeURL then
        HF.Chat("RequestOpenUnsafeURL is unavailable on this client.")
        return false
    end

    local format = formatOverride or HF.LayoutExport.GetFormat()
    local endpoint = GetValidatedEndpoint()
    if not endpoint then return false end
    local payload = SerializeLayout(layout, format)
    local urls, sessionId = BuildUrls(endpoint, kind or "layout", layout, payload, format)

    return QueueExportUrls(urls, sessionId, string.format("%s '%s'", label or "layout", layout.name or layout.id or "layout"), format)
end

function HF.LayoutExport.ExportLayout(layout, formatOverride)
    return ExportLayoutWithKind(layout, "layout", "layout", formatOverride)
end

function HF.LayoutExport.ExportLayoutMap(layout, formatOverride)
    local ok = ExportLayoutWithKind(layout, "map", "layout map", formatOverride)
    if ok then
        HF.Chat("After upload completes, use /hf status. The status page links to the map viewer.")
    end
    return ok
end

function HF.LayoutExport.ExportPayload(kind, record, payload, label)
    if not RequestOpenUnsafeURL then
        HF.Chat("RequestOpenUnsafeURL is unavailable on this client.")
        return false
    end

    local endpoint = GetValidatedEndpoint()
    if not endpoint then return false end
    local urls, sessionId = BuildUrls(endpoint, kind, record or {}, payload or "", "v1")
    return QueueExportUrls(urls, sessionId, label or kind or "payload", "v1")
end

function HF.LayoutExport.ExportPayloadAsync(kind, record, payloadBuilder, label)
    if not RequestOpenUnsafeURL then
        HF.Chat("RequestOpenUnsafeURL is unavailable on this client.")
        return false
    end
    local endpoint = GetValidatedEndpoint()
    if not endpoint then return false end

    local function BuildAndSend()
        local ok, payload = pcall(payloadBuilder)
        if not ok then
            HF.Chat("Export failed while building payload: " .. tostring(payload))
            return
        end

        local urls, sessionId = BuildUrls(endpoint, kind, record or {}, payload or "", "v1")
        QueueExportUrls(urls, sessionId, label or kind or "payload", "v1")
    end

    if zo_callLater then
        zo_callLater(BuildAndSend, 100)
    else
        BuildAndSend()
    end
    return true
end
