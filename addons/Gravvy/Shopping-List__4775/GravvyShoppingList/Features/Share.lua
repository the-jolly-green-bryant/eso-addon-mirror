ShoppingListShare = {}

local Share = ShoppingListShare
local PREFIX_V1 = "SL1:"
local PREFIX_V2 = "SL2:"
local PREFIX_V3 = "SL3:"
local FORMAT_VERSION_V1 = 1
local FORMAT_VERSION_V2 = 2
local FORMAT_VERSION_V3 = 3
local MAX_ITEMS = ShoppingListModel.MAX_ITEMS_PER_LIST
local MAX_NAME_BYTES = ShoppingListModel.MAX_NAME_LENGTH
local MAX_NOTE_BYTES = ShoppingListModel.MAX_NOTE_LENGTH
local MAX_LINK_BYTES = ShoppingListModel.MAX_LINK_LENGTH
local MAX_CODE_LENGTH = 20000
local MAX_U16 = 65535
local MAX_U32 = ShoppingListModel.MAX_PRICE
local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
local DECODE = {}

local QUALITY_MODE_VALUE = {
    any = 0,
    minimum = 1,
    exact = 2,
}
local QUALITY_MODE_NAME = {
    [0] = "any",
    [1] = "minimum",
    [2] = "exact",
}
local LEVEL_MODE_VALUE = {
    any = 0,
    exact = 1,
}
local LEVEL_MODE_NAME = {
    [0] = "any",
    [1] = "exact",
}
local TARGET_MODE_VALUE = {
    buy = 0,
    own = 1,
}
local TARGET_MODE_NAME = {
    [0] = "buy",
    [1] = "own",
}

Share.MAX_CODE_LENGTH = MAX_CODE_LENGTH
Share.PREFIX = PREFIX_V3

for index = 1, #ALPHABET do
    DECODE[string.sub(ALPHABET, index, index)] = index - 1
end

local function makeLabel(parent, font)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    ShoppingListAccessibility:SetFont(label, font or "ZoFontGame")
    label:SetColor(0.9, 0.9, 0.9, 1)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function makeButton(parent, text, width)
    local button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    button:SetDimensions(width, 30)
    ShoppingListAccessibility:SetFont(button, "ZoFontGame")
    button:SetText(text)
    button:SetNormalFontColor(0.85, 0.78, 0.62, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    return button
end

local function trim(value)
    return string.match(value or "", "^%s*(.-)%s*$")
end

local function encodeBase64(value)
    local result = {}
    for position = 1, #value, 3 do
        local first = string.byte(value, position)
        local second = string.byte(value, position + 1)
        local third = string.byte(value, position + 2)
        local packed = (first * 65536) + ((second or 0) * 256) + (third or 0)

        result[#result + 1] = string.sub(ALPHABET, math.floor(packed / 262144) + 1, math.floor(packed / 262144) + 1)
        result[#result + 1] = string.sub(ALPHABET, (math.floor(packed / 4096) % 64) + 1, (math.floor(packed / 4096) % 64) + 1)
        if second then
            result[#result + 1] = string.sub(ALPHABET, (math.floor(packed / 64) % 64) + 1, (math.floor(packed / 64) % 64) + 1)
        end
        if third then
            result[#result + 1] = string.sub(ALPHABET, (packed % 64) + 1, (packed % 64) + 1)
        end
    end
    return table.concat(result)
end

local function decodeBase64(value)
    if value == "" or #value % 4 == 1 then
        return nil
    end

    local result = {}
    for position = 1, #value, 4 do
        local first = DECODE[string.sub(value, position, position)]
        local second = DECODE[string.sub(value, position + 1, position + 1)]
        local thirdCharacter = string.sub(value, position + 2, position + 2)
        local fourthCharacter = string.sub(value, position + 3, position + 3)
        local third = thirdCharacter ~= "" and DECODE[thirdCharacter] or nil
        local fourth = fourthCharacter ~= "" and DECODE[fourthCharacter] or nil
        if first == nil or second == nil or (thirdCharacter ~= "" and third == nil)
            or (fourthCharacter ~= "" and fourth == nil)
        then
            return nil
        end

        local packed = (first * 262144) + (second * 4096)
            + ((third or 0) * 64) + (fourth or 0)
        result[#result + 1] = string.char(math.floor(packed / 65536) % 256)
        if third ~= nil then
            result[#result + 1] = string.char(math.floor(packed / 256) % 256)
        end
        if fourth ~= nil then
            result[#result + 1] = string.char(packed % 256)
        end
    end
    return table.concat(result)
end

Share.EncodeBase64 = encodeBase64
Share.DecodeBase64 = decodeBase64

local function appendU16(parts, value)
    parts[#parts + 1] = string.char(math.floor(value / 256) % 256, value % 256)
end

local function appendU32(parts, value)
    parts[#parts + 1] = string.char(
        math.floor(value / 16777216) % 256,
        math.floor(value / 65536) % 256,
        math.floor(value / 256) % 256,
        value % 256
    )
end

local function appendString(parts, value)
    appendU16(parts, #value)
    if value ~= "" then
        parts[#parts + 1] = value
    end
end

local function checksum(value)
    local first = 1
    local second = 0
    for index = 1, #value do
        first = (first + string.byte(value, index)) % 65521
        second = (second + first) % 65521
    end
    return (second * 65536) + first
end

local function wholeNumber(value, minimum, maximum)
    value = tonumber(value)
    if not value or value ~= math.floor(value)
        or value < minimum or value > maximum
    then
        return nil
    end
    return value
end

local function makeReader(payload)
    local position = 1
    local reader = {}

    function reader:Byte()
        local value = string.byte(payload, position)
        position = position + 1
        return value
    end

    function reader:U16()
        local first = self:Byte()
        local second = self:Byte()
        if first == nil or second == nil then
            return nil
        end
        return (first * 256) + second
    end

    function reader:U32()
        local first = self:Byte()
        local second = self:Byte()
        local third = self:Byte()
        local fourth = self:Byte()
        if first == nil or second == nil or third == nil or fourth == nil then
            return nil
        end
        return (first * 16777216) + (second * 65536) + (third * 256) + fourth
    end

    function reader:Bytes(length, maxLength, allowEmpty)
        if not length or length > maxLength or (length == 0 and not allowEmpty)
            or position + length - 1 > #payload
        then
            return nil
        end
        local value = string.sub(payload, position, position + length - 1)
        position = position + length
        return value
    end

    function reader:String(maxLength, allowEmpty)
        return self:Bytes(self:U16(), maxLength, allowEmpty)
    end

    function reader:IsDone()
        return position == #payload + 1
    end

    return reader
end

local function decodeV1(payload)
    local reader = makeReader(payload)
    if reader:Byte() ~= FORMAT_VERSION_V1 then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_VERSION)
    end
    local listName = reader:String(MAX_NAME_BYTES, false)
    local itemCount = reader:U16()
    if not listName or trim(listName) == "" or not itemCount or itemCount > MAX_ITEMS then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_LIST_DATA)
    end

    local items = {}
    for _ = 1, itemCount do
        local itemNameLength = reader:U16()
        local quantity = reader:U32()
        local itemName = reader:Bytes(itemNameLength, MAX_NAME_BYTES, false)
        if not itemName or trim(itemName) == ""
            or not quantity or quantity < 1 or quantity > ShoppingListModel.MAX_QUANTITY
        then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
        end
        items[#items + 1] = { name = itemName, desired = quantity }
    end
    if not reader:IsDone() then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_EXTRA_DATA)
    end
    return { name = listName, note = "", items = items, formatVersion = 1 }
end

local function encodeOptionalU16(value)
    if value == nil then
        return 0
    end
    value = wholeNumber(value, 0, MAX_U16 - 1)
    return value and value + 1 or nil
end

local function encodeOptionalU32(value)
    if value == nil then
        return 0
    end
    value = wholeNumber(value, 0, MAX_U32 - 1)
    return value and value + 1 or nil
end

local function decodeOptional(value)
    if value == 0 then
        return nil
    end
    return value and value - 1 or nil
end

function Share.EncodeList(list)
    if not list then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_NO_LIST)
    end

    local listName = trim(list.name)
    local listNote = tostring(list.note or "")
    if list.recurring ~= nil and type(list.recurring) ~= "boolean" then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_LIST_DATA)
    end
    local recurring = list.recurring == true and 1 or 0
    if listName == "" or #listName > MAX_NAME_BYTES then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_LIST_NAME_LONG)
    end
    if #listNote > MAX_NOTE_BYTES then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_LIST_DATA)
    end
    if type(list.items) ~= "table" or #list.items > MAX_ITEMS then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_TOO_MANY_ITEMS)
    end

    local parts = { string.char(FORMAT_VERSION_V3) }
    appendString(parts, listName)
    appendString(parts, listNote)
    parts[#parts + 1] = string.char(recurring)
    appendU16(parts, #list.items)

    for _, item in ipairs(list.items) do
        if type(item) ~= "table" or type(item.match or {}) ~= "table" then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
        end
        local itemName = trim(item.name)
        local itemLink = tostring(item.itemLink or "")
        local itemNote = tostring(item.note or "")
        local quantity = wholeNumber(item.desired, 1, ShoppingListModel.MAX_QUANTITY)
        local match = item.match or {}
        if not ShoppingListModel:IsValidMatchingRule(match) then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
        end
        local setName = trim(match.setName)
        local setId = match.setId == nil and 0
            or wholeNumber(match.setId, 1, MAX_U32)
        local traitType = encodeOptionalU16(match.traitType)
        local qualityMode = QUALITY_MODE_VALUE[match.qualityMode or "any"]
        local quality = encodeOptionalU16(match.quality)
        local levelMode = LEVEL_MODE_VALUE[match.levelMode or "any"]
        local level = encodeOptionalU16(match.level)
        local championPoints = encodeOptionalU32(match.championPoints)
        local maxUnitPrice = item.maxUnitPrice == nil and 0
            or wholeNumber(item.maxUnitPrice, 1, MAX_U32)
        local targetMode = TARGET_MODE_VALUE[item.targetMode or "buy"]

        if itemName == "" or #itemName > MAX_NAME_BYTES then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_NAME_LONG)
        end
        if #itemLink > MAX_LINK_BYTES or #itemNote > MAX_NOTE_BYTES
            or #setName > MAX_NAME_BYTES
        then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
        end
        if itemLink ~= "" then
            local _, _, linkType = ZO_LinkHandler_ParseLink(itemLink)
            if linkType ~= ITEM_LINK_TYPE or trim(GetItemLinkName(itemLink) or "") == "" then
                return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
            end
        end
        if setName == "" and setId ~= 0 then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
        end
        if not quantity then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_QUANTITY)
        end
        if setId == nil or traitType == nil or qualityMode == nil
            or quality == nil or levelMode == nil or level == nil
            or championPoints == nil or maxUnitPrice == nil
            or targetMode == nil
        then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
        end

        appendString(parts, itemName)
        appendU32(parts, quantity)
        appendString(parts, itemLink)
        appendString(parts, itemNote)
        appendString(parts, setName)
        appendU32(parts, setId)
        appendU16(parts, traitType)
        parts[#parts + 1] = string.char(qualityMode)
        appendU16(parts, quality)
        parts[#parts + 1] = string.char(levelMode)
        appendU16(parts, level)
        appendU32(parts, championPoints)
        appendU32(parts, maxUnitPrice)
        parts[#parts + 1] = string.char(targetMode)
    end

    local body = table.concat(parts)
    local payload = { body }
    appendU32(payload, checksum(body))
    local code = PREFIX_V3 .. encodeBase64(table.concat(payload))
    if #code > MAX_CODE_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_LIST_LONG)
    end
    return code
end

local function decodeModern(payload, expectedVersion, includesTargetMode)
    if #payload < 5 then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_INVALID)
    end

    local body = string.sub(payload, 1, #payload - 4)
    local checksumReader = makeReader(string.sub(payload, #payload - 3))
    if checksumReader:U32() ~= checksum(body) then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_INVALID)
    end

    local reader = makeReader(body)
    if reader:Byte() ~= expectedVersion then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_VERSION)
    end

    local listName = reader:String(MAX_NAME_BYTES, false)
    local listNote = reader:String(MAX_NOTE_BYTES, true)
    local recurring = false
    local recurringValid = true
    if includesTargetMode then
        local recurringValue = reader:Byte()
        if recurringValue == 1 then
            recurring = true
        elseif recurringValue ~= 0 then
            recurringValid = false
        end
    end
    local itemCount = reader:U16()
    if not listName or trim(listName) == "" or listNote == nil
        or not recurringValid or not itemCount or itemCount > MAX_ITEMS
    then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_LIST_DATA)
    end

    local items = {}
    for _ = 1, itemCount do
        local itemName = reader:String(MAX_NAME_BYTES, false)
        local quantity = reader:U32()
        local itemLink = reader:String(MAX_LINK_BYTES, true)
        local itemNote = reader:String(MAX_NOTE_BYTES, true)
        local setName = reader:String(MAX_NAME_BYTES, true)
        local setId = reader:U32()
        local traitType = decodeOptional(reader:U16())
        local qualityMode = QUALITY_MODE_NAME[reader:Byte()]
        local quality = decodeOptional(reader:U16())
        local levelMode = LEVEL_MODE_NAME[reader:Byte()]
        local level = decodeOptional(reader:U16())
        local championPoints = decodeOptional(reader:U32())
        local maxUnitPrice = reader:U32()
        local targetMode = "buy"
        if includesTargetMode then
            targetMode = TARGET_MODE_NAME[reader:Byte()]
        end

        if not itemName or trim(itemName) == ""
            or not quantity or quantity < 1 or quantity > ShoppingListModel.MAX_QUANTITY
            or itemLink == nil or itemNote == nil or setName == nil
            or setId == nil or not qualityMode or not levelMode
            or maxUnitPrice == nil
            or targetMode == nil
            or (qualityMode ~= "any" and quality == nil)
            or (levelMode == "exact" and (level == nil or championPoints == nil))
        then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
        end

        if itemLink ~= "" then
            local _, _, linkType = ZO_LinkHandler_ParseLink(itemLink)
            if linkType ~= ITEM_LINK_TYPE or trim(GetItemLinkName(itemLink) or "") == "" then
                return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
            end
        end
        if setName == "" and setId ~= 0 then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
        end

        local match = {
            qualityMode = qualityMode,
            quality = quality,
            levelMode = levelMode,
            level = level,
            championPoints = championPoints,
            traitType = traitType,
        }
        if setName ~= "" then
            match.setName = setName
            match.normalizedSetName = ShoppingListData.NormalizeName(setName)
            match.setId = setId ~= 0 and setId or nil
        end
        match = ShoppingListModel:NormalizeMatchingRule(match)
        if not match then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
        end

        items[#items + 1] = {
            name = itemName,
            desired = quantity,
            itemLink = itemLink,
            note = itemNote,
            maxUnitPrice = maxUnitPrice ~= 0 and maxUnitPrice or nil,
            targetMode = targetMode,
            match = match,
        }
    end

    if not reader:IsDone() then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_EXTRA_DATA)
    end
    return {
        name = listName,
        note = listNote,
        recurring = recurring,
        items = items,
        formatVersion = expectedVersion,
    }
end

local function decodeV2(payload)
    return decodeModern(payload, FORMAT_VERSION_V2, false)
end

local function decodeV3(payload)
    return decodeModern(payload, FORMAT_VERSION_V3, true)
end

function Share.DecodeCode(code)
    code = trim(code)
    if #code > MAX_CODE_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_CODE_LONG)
    end

    local prefix
    local decoder
    if string.sub(code, 1, #PREFIX_V3) == PREFIX_V3 then
        prefix = PREFIX_V3
        decoder = decodeV3
    elseif string.sub(code, 1, #PREFIX_V2) == PREFIX_V2 then
        prefix = PREFIX_V2
        decoder = decodeV2
    elseif string.sub(code, 1, #PREFIX_V1) == PREFIX_V1 then
        prefix = PREFIX_V1
        decoder = decodeV1
    else
        return nil, zo_strformat(
            GetString(SI_SHOPPING_LIST_SHARE_ERROR_PREFIX),
            PREFIX_V1 .. ", " .. PREFIX_V2 .. ", or " .. PREFIX_V3
        )
    end

    local payload = decodeBase64(string.sub(code, #prefix + 1))
    if not payload then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_INVALID)
    end
    return decoder(payload)
end

function Share.BuildImportPreview(data, decoded)
    if type(data) ~= "table" or type(decoded) ~= "table"
        or type(decoded.items) ~= "table"
    then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_LIST_DATA)
    end

    local conflict, archivedConflict = data:FindListByName(decoded.name)
    local candidates = {}
    local internalDuplicates = 0
    local matchingEntries = 0
    for _, source in ipairs(decoded.items) do
        local candidate, message = data:BuildItemCandidate(source)
        if not candidate then
            return nil, message
        end
        for _, prior in ipairs(candidates) do
            if ShoppingListModel:ItemsAreDuplicates(prior, candidate) then
                internalDuplicates = internalDuplicates + 1
                break
            end
        end
        if conflict and not archivedConflict then
            for _, existing in ipairs(conflict.items) do
                if ShoppingListModel:ItemsAreDuplicates(existing, candidate) then
                    matchingEntries = matchingEntries + 1
                    break
                end
            end
        end
        candidates[#candidates + 1] = candidate
    end

    local sample = {}
    for index = 1, math.min(4, #decoded.items) do
        local item = decoded.items[index]
        sample[#sample + 1] = zo_strformat(
            GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_ITEM),
            item.name,
            item.desired
        )
    end
    if #decoded.items > #sample then
        sample[#sample + 1] = zo_strformat(
            GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_MORE),
            #decoded.items - #sample
        )
    end

    return {
        decoded = decoded,
        conflict = conflict,
        archivedConflict = archivedConflict == true,
        copyName = data:GetUniqueListName(decoded.name),
        internalDuplicates = internalDuplicates,
        matchingEntries = matchingEntries,
        sample = table.concat(sample, ", "),
        canMerge = conflict ~= nil
            and not archivedConflict
            and conflict.locked ~= true,
    }
end

function Share.GetImportPreviewText(preview)
    local decoded = preview.decoded
    local conflict
    if preview.conflict then
        conflict = zo_strformat(
            GetString(preview.archivedConflict
                and SI_SHOPPING_LIST_IMPORT_CONFLICT_ARCHIVED
                or SI_SHOPPING_LIST_IMPORT_CONFLICT_ACTIVE),
            preview.conflict.name
        )
    else
        conflict = GetString(SI_SHOPPING_LIST_IMPORT_CONFLICT_NONE)
    end
    local lines = {
        zo_strformat(
            GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_NAME),
            decoded.name
        ),
        zo_strformat(
            GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_FORMAT),
            decoded.formatVersion or 1
        ),
        zo_strformat(
            GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_COUNT),
            #decoded.items
        ),
        zo_strformat(
            GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_NOTE),
            decoded.note and decoded.note ~= ""
                and GetString(SI_YES) or GetString(SI_NO)
        ),
        zo_strformat(
            GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_RECURRING),
            decoded.recurring and GetString(SI_YES) or GetString(SI_NO)
        ),
        zo_strformat(GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_CONFLICT), conflict),
    }
    if preview.conflict then
        lines[#lines + 1] = zo_strformat(
            GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_COPY_NAME),
            preview.copyName
        )
    end
    lines[#lines + 1] = zo_strformat(
            GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_DUPLICATES),
            preview.internalDuplicates,
            preview.matchingEntries
        )
    lines[#lines + 1] = zo_strformat(
            GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_ITEMS),
            preview.sample ~= "" and preview.sample
                or GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_EMPTY)
        )
    return table.concat(lines, "\n")
end

function Share.GetImportPreviewHelp(preview)
    if preview.canMerge then
        return GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_CHOOSE)
    end
    if preview.archivedConflict then
        return GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_ARCHIVED_HELP)
    end
    if preview.conflict then
        return GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_LOCKED_HELP)
    end
    return GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_NEW_HELP)
end

function Share:New(owner)
    return setmetatable({ owner = owner }, { __index = self })
end

function Share:Initialize()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListShareWindow")
    window:SetDimensions(650, 275)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    self.window = window

    local backdrop = ShoppingListControls:CreateBackdrop(window)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.98)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop)

    local title = makeLabel(window, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_SHARE_TITLE))
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 10)
    title:SetDimensions(360, 30)
    title:SetMouseEnabled(true)
    title:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StartMoving()
        end
    end)
    title:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StopMovingOrResizing()
        end
    end)
    ShoppingListControls:MakeWindowMovable(
        window,
        title,
        self.owner.data,
        "share"
    )

    local help = makeLabel(window, "ZoFontGame")
    help:SetText(GetString(SI_SHOPPING_LIST_SHARE_HELP))
    help:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 46)
    help:SetDimensions(614, 52)
    help:SetVerticalAlignment(TEXT_ALIGN_TOP)
    help:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

    local codeBackdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, window, "ZO_EditBackdrop")
    codeBackdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 106)
    codeBackdrop:SetDimensions(614, 34)

    local codeEdit = WINDOW_MANAGER:CreateControlFromVirtual(nil, codeBackdrop, "ZO_DefaultEditForBackdrop")
    codeEdit:ClearAnchors()
    codeEdit:SetAnchor(TOPLEFT, codeBackdrop, TOPLEFT, 3, 2)
    codeEdit:SetAnchor(BOTTOMRIGHT, codeBackdrop, BOTTOMRIGHT, -3, -2)
    ShoppingListAccessibility:SetFont(codeEdit, "ZoFontGame")
    codeEdit:SetMaxInputChars(MAX_CODE_LENGTH)
    codeEdit:SetNewLineEnabled(false)
    codeEdit:SetSelectAllOnFocus(true)
    codeEdit:SetHandler("OnEscape", function() self:Hide() end)
    self.codeEdit = codeEdit

    self.status = makeLabel(window, "ZoFontGameSmall")
    self.status:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 148)
    self.status:SetDimensions(614, 38)

    local regenerate = makeButton(window, GetString(SI_SHOPPING_LIST_SHARE_CURRENT_CODE), 135)
    regenerate:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 18, -16)
    regenerate:SetHandler("OnClicked", function() self:ExportCurrent() end)

    local selectCode = makeButton(window, GetString(SI_SHOPPING_LIST_SHARE_SELECT_CODE), 100)
    selectCode:SetAnchor(LEFT, regenerate, RIGHT, 8, 0)
    selectCode:SetHandler("OnClicked", function() self:SelectCode() end)

    local import = makeButton(window, GetString(SI_SHOPPING_LIST_SHARE_IMPORT_CODE), 105)
    import:SetAnchor(LEFT, selectCode, RIGHT, 8, 0)
    import:SetHandler("OnClicked", function() self:OpenImportDialog() end)

    local backup = makeButton(window, GetString(SI_SHOPPING_LIST_BACKUP_BUTTON), 95)
    backup:SetAnchor(LEFT, import, RIGHT, 8, 0)
    backup:SetHandler("OnClicked", function()
        if self.owner.backup then
            self.owner.backup:Open()
        end
    end)

    local close = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_CLOSE), 80)
    close:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -16)
    close:SetHandler("OnClicked", function() self:Hide() end)

    self:CreateImportDialog()
    self:CreateImportPreviewDialog()
end

function Share:CreateImportDialog()
    local dialog = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListImportWindow")
    dialog:SetDimensions(650, 210)
    dialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    dialog:SetClampedToScreen(true)
    dialog:SetMouseEnabled(true)
    dialog:SetHidden(true)
    dialog:SetDrawTier(DT_HIGH)
    dialog:SetDrawLayer(DL_OVERLAY)
    dialog:SetDrawLevel(10)
    self.importWindow = dialog

    local backdrop = ShoppingListControls:CreateBackdrop(dialog)
    backdrop:SetAnchorFill(dialog)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.99)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop, { 0.035, 0.035, 0.045, 0.99 })

    local title = makeLabel(dialog, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_IMPORT_TITLE))
    title:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 10)
    title:SetDimensions(614, 30)
    ShoppingListControls:MakeWindowMovable(
        dialog,
        title,
        self.owner.data,
        "import"
    )

    local help = makeLabel(dialog, "ZoFontGame")
    help:SetText(GetString(SI_SHOPPING_LIST_IMPORT_HELP))
    help:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 46)
    help:SetDimensions(614, 26)

    local codeBackdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, dialog, "ZO_EditBackdrop")
    codeBackdrop:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 76)
    codeBackdrop:SetDimensions(614, 34)

    local codeEdit = WINDOW_MANAGER:CreateControlFromVirtual(nil, codeBackdrop, "ZO_DefaultEditForBackdrop")
    codeEdit:ClearAnchors()
    codeEdit:SetAnchor(TOPLEFT, codeBackdrop, TOPLEFT, 3, 2)
    codeEdit:SetAnchor(BOTTOMRIGHT, codeBackdrop, BOTTOMRIGHT, -3, -2)
    ShoppingListAccessibility:SetFont(codeEdit, "ZoFontGame")
    codeEdit:SetMaxInputChars(MAX_CODE_LENGTH)
    codeEdit:SetNewLineEnabled(false)
    codeEdit:SetSelectAllOnFocus(true)
    codeEdit:SetDefaultText(GetString(SI_SHOPPING_LIST_IMPORT_PLACEHOLDER))
    codeEdit:SetHandler("OnEnter", function() self:ImportCode() end)
    codeEdit:SetHandler("OnEscape", function() self:CloseImportDialog() end)
    self.importEdit = codeEdit

    self.importStatus = makeLabel(dialog, "ZoFontGameSmall")
    self.importStatus:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 116)
    self.importStatus:SetDimensions(614, 34)

    local import = makeButton(dialog, GetString(SI_SHOPPING_LIST_SHARE_IMPORT_CODE), 105)
    import:SetAnchor(BOTTOMLEFT, dialog, BOTTOMLEFT, 18, -16)
    import:SetHandler("OnClicked", function() self:ImportCode() end)

    local cancel = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_CANCEL), 90)
    cancel:SetAnchor(BOTTOMRIGHT, dialog, BOTTOMRIGHT, -18, -16)
    cancel:SetHandler("OnClicked", function() self:CloseImportDialog() end)
end

function Share:CreateImportPreviewDialog()
    local dialog = WINDOW_MANAGER:CreateTopLevelWindow(
        "ShoppingListImportPreviewWindow"
    )
    dialog:SetDimensions(650, 390)
    dialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    dialog:SetHidden(true)
    dialog:SetDrawTier(DT_HIGH)
    dialog:SetDrawLayer(DL_OVERLAY)
    dialog:SetDrawLevel(20)
    self.previewWindow = dialog

    local backdrop = ShoppingListControls:CreateBackdrop(dialog)
    backdrop:SetAnchorFill(dialog)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.99)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop)

    local title = makeLabel(dialog, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_IMPORT_PREVIEW_TITLE))
    title:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 10)
    title:SetDimensions(614, 30)
    ShoppingListControls:MakeWindowMovable(
        dialog,
        title,
        self.owner.data,
        "importPreview"
    )

    self.previewDetails = makeLabel(dialog, "ZoFontGame")
    self.previewDetails:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 48)
    self.previewDetails:SetDimensions(614, 250)
    self.previewDetails:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self.previewDetails:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

    self.previewStatus = makeLabel(dialog, "ZoFontGameSmall")
    self.previewStatus:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 302)
    self.previewStatus:SetDimensions(614, 32)

    self.previewMerge = makeButton(
        dialog,
        GetString(SI_SHOPPING_LIST_IMPORT_MERGE),
        140
    )
    self.previewMerge:SetAnchor(BOTTOMLEFT, dialog, BOTTOMLEFT, 18, -16)
    self.previewMerge:SetHandler("OnClicked", function()
        self:CompleteImport("merge")
    end)

    self.previewCopy = makeButton(
        dialog,
        GetString(SI_SHOPPING_LIST_IMPORT_CREATE_COPY),
        140
    )
    self.previewCopy:SetAnchor(LEFT, self.previewMerge, RIGHT, 10, 0)
    self.previewCopy:SetHandler("OnClicked", function()
        self:CompleteImport("copy")
    end)

    local cancel = makeButton(
        dialog,
        GetString(SI_SHOPPING_LIST_BUTTON_CANCEL),
        90
    )
    cancel:SetAnchor(BOTTOMRIGHT, dialog, BOTTOMRIGHT, -18, -16)
    cancel:SetHandler("OnClicked", function() self:CloseImportPreview(true) end)
end

function Share:SetStatus(message, isError)
    if self.owner.accessibility then
        message = self.owner.accessibility:FormatStatus(message, isError)
    end
    self.status:SetText(message or "")
    if isError then
        self.status:SetColor(1, 0.35, 0.35, 1)
    else
        self.status:SetColor(0.65, 0.82, 0.55, 1)
    end
end

function Share:Open()
    self.owner.ui:CloseListDialog()
    self:CloseImportDialog()
    self.window:SetHidden(false)
    self:ExportCurrent()
end

function Share:Hide()
    self:CloseImportPreview(false)
    self:CloseImportDialog()
    self.codeEdit:LoseFocus()
    self.window:SetHidden(true)
end

function Share:SetImportStatus(message, isError)
    if self.owner.accessibility then
        message = self.owner.accessibility:FormatStatus(message, isError)
    end
    self.importStatus:SetText(message or "")
    if isError then
        self.importStatus:SetColor(1, 0.35, 0.35, 1)
    else
        self.importStatus:SetColor(0.65, 0.82, 0.55, 1)
    end
end

function Share:OpenImportDialog()
    self:CloseImportPreview(false)
    self.importEdit:SetText("")
    self:SetImportStatus("")
    self.window:SetMouseEnabled(false)
    self.importWindow:SetHidden(false)
    self.importEdit:TakeFocus()
end

function Share:OpenImportPreview(preview)
    self.pendingImport = preview
    self.importEdit:LoseFocus()
    self.importWindow:SetHidden(true)
    self.window:SetMouseEnabled(false)
    self.previewDetails:SetText(Share.GetImportPreviewText(preview))
    self.previewStatus:SetText(Share.GetImportPreviewHelp(preview))
    self.previewStatus:SetColor(0.75, 0.82, 0.65, 1)
    self.previewMerge:SetEnabled(preview.canMerge)
    self.previewCopy:SetText(GetString(preview.conflict
        and SI_SHOPPING_LIST_IMPORT_CREATE_COPY
        or SI_SHOPPING_LIST_IMPORT_CREATE_LIST))
    self.previewWindow:SetHidden(false)
end

function Share:CloseImportPreview(returnToImport)
    if not self.previewWindow then
        return
    end
    self.previewWindow:SetHidden(true)
    self.pendingImport = nil
    if returnToImport then
        self.window:SetMouseEnabled(false)
        self.importWindow:SetHidden(false)
        self.importEdit:TakeFocus()
    else
        self.window:SetMouseEnabled(true)
    end
end

function Share:CloseImportDialog()
    if not self.importWindow then
        return
    end
    self.importEdit:LoseFocus()
    self.importWindow:SetHidden(true)
    self.window:SetMouseEnabled(true)
end

function Share:SelectCode()
    self.codeEdit:TakeFocus()
    if self.codeEdit.SelectAll then
        self.codeEdit:SelectAll()
    end
    self:SetStatus(GetString(SI_SHOPPING_LIST_SHARE_COPY_HINT))
end

function Share:ExportCurrent()
    local code, message = Share.EncodeList(self.owner.data:GetCurrentList())
    if not code then
        self:SetStatus(message, true)
        return
    end
    self.codeEdit:SetText(code)
    self:SelectCode()
end

function Share:ImportCode()
    local decoded, message = Share.DecodeCode(self.importEdit:GetText())
    if not decoded then
        self:SetImportStatus(message, true)
        return
    end

    local preview, previewMessage = Share.BuildImportPreview(
        self.owner.data,
        decoded
    )
    if not preview then
        self:SetImportStatus(previewMessage, true)
        return
    end

    self:OpenImportPreview(preview)
end

function Share:CompleteImport(mode)
    local preview = self.pendingImport
    if not preview then
        return
    end
    local list, importMessage
    if mode == "merge" then
        if not preview.canMerge then
            self.previewStatus:SetText(GetString(
                SI_SHOPPING_LIST_IMPORT_PREVIEW_CANNOT_MERGE
            ))
            self.previewStatus:SetColor(1, 0.35, 0.35, 1)
            return
        end
        list, importMessage = self.owner.data:MergeImportedList(
            preview.conflict.id,
            preview.decoded
        )
    else
        list, importMessage = self.owner.data:ImportList(
            preview.decoded.name,
            preview.decoded.items,
            preview.decoded.note,
            preview.decoded.recurring
        )
    end
    if not list then
        self.previewStatus:SetText(importMessage)
        self.previewStatus:SetColor(1, 0.35, 0.35, 1)
        return
    end

    self.owner.ui.listSignature = nil
    self.owner.ui:SelectList(list.id)
    self.owner:RefreshInventory()
    local importedCount = #preview.decoded.items
    local status = zo_strformat(
        GetString(mode == "merge"
            and SI_SHOPPING_LIST_STATUS_LIST_IMPORT_MERGED
            or SI_SHOPPING_LIST_STATUS_LIST_IMPORTED),
        list.name,
        importedCount,
        GetString(importedCount == 1
            and SI_SHOPPING_LIST_NOUN_ITEM
            or SI_SHOPPING_LIST_NOUN_ITEMS)
    )
    self:Hide()
    self.owner.ui:SetStatus(status)
end
