ShoppingListBackup = {}

local Backup = ShoppingListBackup
local PREFIX = "SLB1:"
local FORMAT_VERSION = 1
local MAX_CODE_LENGTH = 500000
local MAX_ENTRIES = 250000
local MAX_DEPTH = 32
local RESTORE_DIALOG = "SHOPPING_LIST_CONFIRM_BACKUP_RESTORE"
local SAFETY_RESTORE_DIALOG = "SHOPPING_LIST_CONFIRM_SAFETY_RESTORE"

Backup.MAX_CODE_LENGTH = MAX_CODE_LENGTH

function Backup.GetHealth(code)
    local length = type(code) == "string" and #code or 0
    local percent = math.min(100, math.floor((length * 100 / MAX_CODE_LENGTH) + 0.5))
    local state = SI_SHOPPING_LIST_BACKUP_HEALTH_GOOD
    local level = "good"
    if percent >= 90 then
        state = SI_SHOPPING_LIST_BACKUP_HEALTH_CRITICAL
        level = "critical"
    elseif percent >= 75 then
        state = SI_SHOPPING_LIST_BACKUP_HEALTH_WARNING
        level = "warning"
    end
    return zo_strformat(
        GetString(SI_SHOPPING_LIST_BACKUP_HEALTH),
        ZO_CommaDelimitNumber(length),
        ZO_CommaDelimitNumber(MAX_CODE_LENGTH),
        percent,
        GetString(state)
    ), level, percent
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

local function appendU32(parts, value)
    parts[#parts + 1] = string.char(
        math.floor(value / 16777216) % 256,
        math.floor(value / 65536) % 256,
        math.floor(value / 256) % 256,
        value % 256
    )
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

local function sortKeys(keys)
    local order = { number = 1, string = 2, boolean = 3 }
    table.sort(keys, function(left, right)
        local leftType = type(left)
        local rightType = type(right)
        if leftType ~= rightType then
            return order[leftType] < order[rightType]
        end
        if leftType == "number" then
            return left < right
        end
        return tostring(left) < tostring(right)
    end)
end

local function serialize(root)
    local parts = { string.char(FORMAT_VERSION) }
    local visited = {}
    local entryCount = 0

    local function write(value, depth)
        if depth > MAX_DEPTH then
            return false
        end
        local valueType = type(value)
        if valueType == "nil" then
            parts[#parts + 1] = "N"
        elseif valueType == "boolean" then
            parts[#parts + 1] = value and "T" or "F"
        elseif valueType == "number" then
            if value ~= value or value == math.huge or value == -math.huge then
                return false
            end
            local number = string.format("%.17g", value)
            parts[#parts + 1] = "D"
            appendU32(parts, #number)
            parts[#parts + 1] = number
        elseif valueType == "string" then
            parts[#parts + 1] = "S"
            appendU32(parts, #value)
            parts[#parts + 1] = value
        elseif valueType == "table" then
            if visited[value] then
                return false
            end
            visited[value] = true
            local keys = {}
            for key in pairs(value) do
                local keyType = type(key)
                if keyType ~= "number" and keyType ~= "string" and keyType ~= "boolean" then
                    return false
                end
                keys[#keys + 1] = key
            end
            entryCount = entryCount + #keys
            if entryCount > MAX_ENTRIES then
                return false
            end
            sortKeys(keys)
            parts[#parts + 1] = "A"
            appendU32(parts, #keys)
            for _, key in ipairs(keys) do
                if not write(key, depth + 1) or not write(value[key], depth + 1) then
                    return false
                end
            end
            visited[value] = nil
        else
            return false
        end
        return true
    end

    if not write(root, 0) then
        return nil
    end
    local body = table.concat(parts)
    local result = { body }
    appendU32(result, checksum(body))
    return table.concat(result)
end

local function deserialize(payload)
    if #payload < 6 then
        return nil
    end

    local bodyLength = #payload - 4
    local body = string.sub(payload, 1, bodyLength)
    local a, b, c, d = string.byte(payload, bodyLength + 1, #payload)
    local expected = (a * 16777216) + (b * 65536) + (c * 256) + d
    if checksum(body) ~= expected then
        return nil
    end

    local position = 1
    local entryCount = 0
    local function readByte()
        local value = string.byte(body, position)
        position = position + 1
        return value
    end
    local function readU32()
        local first = readByte()
        local second = readByte()
        local third = readByte()
        local fourth = readByte()
        if not first or not second or not third or not fourth then
            return nil
        end
        return (first * 16777216) + (second * 65536) + (third * 256) + fourth
    end
    local function readString(length)
        if not length or length < 0 or position + length - 1 > #body then
            return nil
        end
        local value = string.sub(body, position, position + length - 1)
        position = position + length
        return value
    end

    if readByte() ~= FORMAT_VERSION then
        return nil
    end

    local read
    read = function(depth)
        if depth > MAX_DEPTH then
            return nil, false
        end
        local tag = readByte()
        if tag == string.byte("N") then
            return nil, true
        elseif tag == string.byte("T") then
            return true, true
        elseif tag == string.byte("F") then
            return false, true
        elseif tag == string.byte("D") then
            local value = tonumber(readString(readU32()))
            return value, value ~= nil
        elseif tag == string.byte("S") then
            local value = readString(readU32())
            return value, value ~= nil
        elseif tag == string.byte("A") then
            local count = readU32()
            if not count then
                return nil, false
            end
            entryCount = entryCount + count
            if entryCount > MAX_ENTRIES then
                return nil, false
            end
            local result = {}
            for _ = 1, count do
                local key, keyOk = read(depth + 1)
                local value, valueOk = read(depth + 1)
                local keyType = type(key)
                if not keyOk or not valueOk
                    or (keyType ~= "number" and keyType ~= "string" and keyType ~= "boolean")
                then
                    return nil, false
                end
                result[key] = value
            end
            return result, true
        end
        return nil, false
    end

    local result, ok = read(0)
    if not ok or position ~= #body + 1 then
        return nil
    end
    return result
end

function Backup.Encode(data)
    local payload = serialize(data)
    if not payload then
        return nil, GetString(SI_SHOPPING_LIST_BACKUP_ERROR_DATA)
    end
    local code = PREFIX .. ShoppingListShare.EncodeBase64(payload)
    if #code > MAX_CODE_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_BACKUP_ERROR_LONG)
    end
    return code
end

function Backup.Decode(code)
    code = string.match(code or "", "^%s*(.-)%s*$")
    if #code > MAX_CODE_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_BACKUP_ERROR_LONG)
    end
    if string.sub(code, 1, #PREFIX) ~= PREFIX then
        return nil, zo_strformat(GetString(SI_SHOPPING_LIST_BACKUP_ERROR_PREFIX), PREFIX)
    end
    local payload = ShoppingListShare.DecodeBase64(string.sub(code, #PREFIX + 1))
    local decoded = payload and deserialize(payload)
    if type(decoded) ~= "table" then
        return nil, GetString(SI_SHOPPING_LIST_BACKUP_ERROR_INVALID)
    end
    return decoded
end

function Backup.GetSafetyLabel(snapshot)
    local kindId = SI_SHOPPING_LIST_SAFETY_KIND_OTHER
    if snapshot.kind == "pre_migration" then
        kindId = SI_SHOPPING_LIST_SAFETY_KIND_MIGRATION
    elseif snapshot.kind == "pre_import" then
        kindId = SI_SHOPPING_LIST_SAFETY_KIND_IMPORT
    elseif snapshot.kind == "pre_restore" then
        kindId = SI_SHOPPING_LIST_SAFETY_KIND_RESTORE
    elseif snapshot.kind == "pre_legacy_recovery" then
        kindId = SI_SHOPPING_LIST_SAFETY_KIND_LEGACY
    elseif snapshot.kind == "pre_progress_reset" then
        kindId = SI_SHOPPING_LIST_SAFETY_KIND_PROGRESS_RESET
    end
    return zo_strformat(
        GetString(SI_SHOPPING_LIST_SAFETY_ENTRY),
        snapshot.id,
        GetString(kindId),
        snapshot.sourceSchema or 1
    )
end

function Backup:New(owner)
    return setmetatable({ owner = owner }, { __index = self })
end

function Backup:Initialize()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListBackupWindow")
    window:SetDimensions(700, 500)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    self.window = window

    local backdrop = ShoppingListControls:CreateBackdrop(window)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.99)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop, { 0.035, 0.035, 0.045, 0.99 })

    local title = makeLabel(window, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_BACKUP_TITLE))
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 10)
    title:SetDimensions(664, 30)
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
    help:SetText(GetString(SI_SHOPPING_LIST_BACKUP_HELP))
    help:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 46)
    help:SetDimensions(664, 54)
    help:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local codeBackdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, window, "ZO_EditBackdrop")
    codeBackdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 106)
    codeBackdrop:SetDimensions(664, 230)

    local codeEdit = WINDOW_MANAGER:CreateControlFromVirtual(
        nil,
        codeBackdrop,
        "ZO_DefaultEditMultiLineForBackdrop"
    )
    codeEdit:ClearAnchors()
    codeEdit:SetAnchor(TOPLEFT, codeBackdrop, TOPLEFT, 5, 4)
    codeEdit:SetAnchor(BOTTOMRIGHT, codeBackdrop, BOTTOMRIGHT, -5, -4)
    ShoppingListAccessibility:SetFont(codeEdit, "ZoFontGame")
    codeEdit:SetMaxInputChars(MAX_CODE_LENGTH)
    codeEdit:SetNewLineEnabled(false)
    codeEdit:SetDefaultText(GetString(SI_SHOPPING_LIST_BACKUP_PLACEHOLDER))
    codeEdit:SetHandler("OnEscape", function() self:Hide() end)
    self.codeEdit = codeEdit

    self.status = makeLabel(window, "ZoFontGameSmall")
    self.status:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 410)
    self.status:SetDimensions(664, 34)

    local safetyLabel = makeLabel(window, "ZoFontGame")
    safetyLabel:SetText(GetString(SI_SHOPPING_LIST_SAFETY_TITLE))
    safetyLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 346)
    safetyLabel:SetDimensions(175, 30)

    local safetyControl = WINDOW_MANAGER:CreateControlFromVirtual(
        "ShoppingListSafetyCopyDropdown",
        window,
        "ZO_ComboBox"
    )
    safetyControl:SetAnchor(LEFT, safetyLabel, RIGHT, 8, 0)
    safetyControl:SetDimensions(275, 30)
    self.safetyCombo = ZO_ComboBox_ObjectFromContainer(safetyControl)
    self.safetyCombo:SetSortsItems(false)

    local restoreSafety = makeButton(
        window,
        GetString(SI_SHOPPING_LIST_SAFETY_RESTORE),
        180
    )
    restoreSafety:SetAnchor(LEFT, safetyControl, RIGHT, 8, 0)
    restoreSafety:SetHandler("OnClicked", function() self:ConfirmSafetyRestore() end)
    self.restoreSafetyButton = restoreSafety

    local generate = makeButton(window, GetString(SI_SHOPPING_LIST_BACKUP_GENERATE), 130)
    generate:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 18, -16)
    generate:SetHandler("OnClicked", function() self:Generate() end)

    local selectCode = makeButton(window, GetString(SI_SHOPPING_LIST_SHARE_SELECT_CODE), 100)
    selectCode:SetAnchor(LEFT, generate, RIGHT, 8, 0)
    selectCode:SetHandler("OnClicked", function() self:SelectCode() end)

    local restore = makeButton(window, GetString(SI_SHOPPING_LIST_BACKUP_RESTORE), 120)
    restore:SetAnchor(LEFT, selectCode, RIGHT, 8, 0)
    restore:SetHandler("OnClicked", function() self:ConfirmRestore() end)

    local close = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_CLOSE), 80)
    close:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -16)
    close:SetHandler("OnClicked", function() self:Hide() end)

    ZO_Dialogs_RegisterCustomDialog(RESTORE_DIALOG, {
        title = { text = SI_SHOPPING_LIST_BACKUP_RESTORE_TITLE },
        mainText = { text = SI_SHOPPING_LIST_BACKUP_RESTORE_CONFIRM },
        buttons = {
            {
                text = SI_SHOPPING_LIST_BACKUP_RESTORE,
                callback = function() self:RestorePending() end,
            },
            { text = SI_DIALOG_CANCEL },
        },
        finishedCallback = function()
            self.owner.ui:RestoreOwnedMouse()
        end,
    })

    ZO_Dialogs_RegisterCustomDialog(SAFETY_RESTORE_DIALOG, {
        title = { text = SI_SHOPPING_LIST_SAFETY_RESTORE_TITLE },
        mainText = { text = SI_SHOPPING_LIST_SAFETY_RESTORE_CONFIRM },
        buttons = {
            {
                text = SI_SHOPPING_LIST_SAFETY_RESTORE,
                callback = function() self:RestoreSelectedSafetyCopy() end,
            },
            { text = SI_DIALOG_CANCEL },
        },
        finishedCallback = function()
            self.owner.ui:RestoreOwnedMouse()
        end,
    })
end

function Backup:SetStatus(message, isError)
    if self.owner.accessibility then
        message = self.owner.accessibility:FormatStatus(message, isError)
    end
    self.status:SetText(message or "")
    self.status:SetColor(isError and 1 or 0.65, isError and 0.35 or 0.82, isError and 0.35 or 0.55, 1)
end

function Backup:Open()
    if self.owner.share then
        self.owner.share:Hide()
    end
    self.window:SetHidden(false)
    self:RefreshSafetyCopies()
    self:Generate()
end

function Backup:RefreshSafetyCopies()
    local combo = self.safetyCombo
    combo:ClearItems()
    self.selectedSafetyId = nil
    local selectedLabel
    local snapshots = self.owner.data:GetSafetySnapshots()
    for index = #snapshots, 1, -1 do
        local snapshot = snapshots[index]
        local snapshotId = snapshot.id
        local label = Backup.GetSafetyLabel(snapshot)
        local entry = combo:CreateItemEntry(label, function()
            self.selectedSafetyId = snapshotId
        end)
        combo:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
        if not self.selectedSafetyId then
            self.selectedSafetyId = snapshotId
            selectedLabel = label
        end
    end
    combo:UpdateItems()
    if selectedLabel then
        combo:SetSelectedItem(selectedLabel)
    else
        combo:SetSelectedItem(GetString(SI_SHOPPING_LIST_SAFETY_EMPTY))
    end
    self.restoreSafetyButton:SetEnabled(self.selectedSafetyId ~= nil)
end

function Backup:ConfirmSafetyRestore()
    if not self.selectedSafetyId then
        self:SetStatus(GetString(SI_SHOPPING_LIST_SAFETY_MISSING), true)
        return
    end
    ZO_Dialogs_ShowDialog(SAFETY_RESTORE_DIALOG)
end

function Backup:RestoreSelectedSafetyCopy()
    local ok, message = self.owner.data:RestoreSafetySnapshot(self.selectedSafetyId)
    if not ok then
        self:SetStatus(message, true)
        return
    end
    self.owner.ui.listSignature = nil
    self.owner.accessibility:Apply()
    self.owner:RefreshInventory()
    self:RefreshSafetyCopies()
    self:SetStatus(GetString(SI_SHOPPING_LIST_SAFETY_RESTORED))
end

function Backup:Hide()
    self.codeEdit:LoseFocus()
    self.window:SetHidden(true)
end

function Backup:Generate()
    local code, message = Backup.Encode(self.owner.data:GetBackupData())
    if not code then
        self:SetStatus(message, true)
        return
    end
    self.healthMessage = Backup.GetHealth(code)
    self.codeEdit:SetText(code)
    self:SelectCode()
end

function Backup:SelectCode()
    self.codeEdit:TakeFocus()
    if self.codeEdit.SelectAll then
        self.codeEdit:SelectAll()
    end
    local status = GetString(SI_SHOPPING_LIST_BACKUP_COPY_HINT)
    if self.healthMessage then
        status = status .. "\n" .. self.healthMessage
    end
    self:SetStatus(status)
end

function Backup:ConfirmRestore()
    local decoded, message = Backup.Decode(self.codeEdit:GetText())
    if not decoded then
        self:SetStatus(message, true)
        return
    end
    self.pendingRestore = decoded
    ZO_Dialogs_ShowDialog(RESTORE_DIALOG)
end

function Backup:RestorePending()
    local snapshot = self.pendingRestore
    self.pendingRestore = nil
    local ok, message = self.owner.data:RestoreBackup(snapshot)
    if not ok then
        self:SetStatus(message, true)
        return
    end

    self.owner.ui.listSignature = nil
    if self.owner.accessibility then
        self.owner.accessibility:Apply()
    end
    if self.owner.inventory then
        self.owner.inventory:Refresh()
    else
        self.owner.ui:Refresh()
        self.owner.gamepad:Refresh(true)
    end
    self:Hide()
    self.owner.ui:SetStatus(GetString(SI_SHOPPING_LIST_BACKUP_RESTORED))
end
