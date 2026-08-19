ShoppingListShare = {}

local Share = ShoppingListShare
local PREFIX = "SL1:"
local FORMAT_VERSION = 1
local MAX_ITEMS = 500
local MAX_NAME_BYTES = 512
local MAX_CODE_LENGTH = 20000
local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
local DECODE = {}

Share.MAX_CODE_LENGTH = MAX_CODE_LENGTH

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

function Share.EncodeList(list)
    if not list then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_NO_LIST)
    end
    local listName = trim(list.name)
    if listName == "" or #listName > MAX_NAME_BYTES then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_LIST_NAME_LONG)
    end
    if #list.items > MAX_ITEMS then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_TOO_MANY_ITEMS)
    end

    local parts = { string.char(FORMAT_VERSION) }
    appendU16(parts, #listName)
    parts[#parts + 1] = listName
    appendU16(parts, #list.items)

    for _, item in ipairs(list.items) do
        local itemName = trim(item.name)
        local quantity = math.floor(tonumber(item.desired) or 0)
        if itemName == "" or #itemName > MAX_NAME_BYTES then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_NAME_LONG)
        end
        if quantity < 1 or quantity > 1000000 then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_QUANTITY)
        end
        appendU16(parts, #itemName)
        appendU32(parts, quantity)
        parts[#parts + 1] = itemName
    end

    local code = PREFIX .. encodeBase64(table.concat(parts))
    if #code > MAX_CODE_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_LIST_LONG)
    end
    return code
end

function Share.DecodeCode(code)
    code = trim(code)
    if #code > MAX_CODE_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_CODE_LONG)
    end
    if string.sub(code, 1, #PREFIX) ~= PREFIX then
        return nil, zo_strformat(GetString(SI_SHOPPING_LIST_SHARE_ERROR_PREFIX), PREFIX)
    end

    local payload = decodeBase64(string.sub(code, #PREFIX + 1))
    if not payload then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_INVALID)
    end

    local position = 1
    local function readByte()
        local value = string.byte(payload, position)
        position = position + 1
        return value
    end
    local function readU16()
        local first = readByte()
        local second = readByte()
        if first == nil or second == nil then
            return nil
        end
        return (first * 256) + second
    end
    local function readU32()
        local first = readByte()
        local second = readByte()
        local third = readByte()
        local fourth = readByte()
        if first == nil or second == nil or third == nil or fourth == nil then
            return nil
        end
        return (first * 16777216) + (second * 65536) + (third * 256) + fourth
    end
    local function readString(length)
        if not length or length < 1 or length > MAX_NAME_BYTES
            or position + length - 1 > #payload
        then
            return nil
        end
        local value = string.sub(payload, position, position + length - 1)
        position = position + length
        return value
    end

    if readByte() ~= FORMAT_VERSION then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_VERSION)
    end
    local listName = readString(readU16())
    local itemCount = readU16()
    if not listName or trim(listName) == "" or not itemCount or itemCount > MAX_ITEMS then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_LIST_DATA)
    end

    local items = {}
    for _ = 1, itemCount do
        local itemNameLength = readU16()
        local quantity = readU32()
        local itemName = readString(itemNameLength)
        if not itemName or trim(itemName) == ""
            or not quantity or quantity < 1 or quantity > 1000000
        then
            return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_ITEM_DATA)
        end
        items[#items + 1] = { name = itemName, desired = quantity }
    end
    if position ~= #payload + 1 then
        return nil, GetString(SI_SHOPPING_LIST_SHARE_ERROR_EXTRA_DATA)
    end
    return { name = listName, items = items }
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

    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, window, "ZO_DefaultBackdrop")
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

    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, dialog, "ZO_DefaultBackdrop")
    backdrop:SetAnchorFill(dialog)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.99)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop, { 0.035, 0.035, 0.045, 0.99 })

    local title = makeLabel(dialog, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_IMPORT_TITLE))
    title:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 10)
    title:SetDimensions(614, 30)

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
    self.importEdit:SetText("")
    self:SetImportStatus("")
    self.window:SetMouseEnabled(false)
    self.importWindow:SetHidden(false)
    self.importEdit:TakeFocus()
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

    local list, importMessage = self.owner.data:ImportList(decoded.name, decoded.items)
    if not list then
        self:SetImportStatus(importMessage, true)
        return
    end

    self.owner.ui.listSignature = nil
    self.owner.ui:SelectList(list.id)
    self.owner:RefreshInventory()
    self:Hide()
    self.owner.ui:SetStatus(zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_LIST_IMPORTED),
        list.name,
        #list.items,
        GetString(#list.items == 1
            and SI_SHOPPING_LIST_NOUN_ITEM
            or SI_SHOPPING_LIST_NOUN_ITEMS)
    ))
end
