LibBSCWizardBridge = LibBSCWizardBridge or {}
local LIB = LibBSCWizardBridge

LIB.name = "LibBSCWizardBridge"
LIB.version = 2
LIB.providers = LIB.providers or {}
LIB.clients = LIB.clients or {}
LIB.callbackManager = LIB.callbackManager or ZO_CallbackObject:New()
LIB.editor = LIB.editor or nil
LIB.activeProviderKey = LIB.activeProviderKey or nil
LIB.activeContext = LIB.activeContext or nil
LIB._registeredClientOrder = LIB._registeredClientOrder or {}
LIB.editorMaxBodyHeight = LIB.editorMaxBodyHeight or 360
LIB.editorWidth = LIB.editorWidth or 540
LIB.editorBodyWidth = LIB.editorBodyWidth or 500
LIB.editorInnerBodyWidth = LIB.editorInnerBodyWidth or 480
LIB._collapsedStateByKey = LIB._collapsedStateByKey or {}
LIB.SCOPE_SETUP = "setup"
LIB.SCOPE_PAGE = "page"
LIB.PAGE_SCOPE_KEY = "__pagePayload"
LIB._confirmDialogRegistered = LIB._confirmDialogRegistered or false
LIB._confirmDialogName = LIB._confirmDialogName or "LIBBSCWIZARDBRIDGE_GENERIC_CONFIRM"

local function deepCopy(v)
    if type(v) ~= "table" then return v end
    local t = {}
    for k, val in pairs(v) do
        t[k] = deepCopy(val)
    end
    return t
end

local function getMaxNumericKey(tbl)
    local maxKey = 0
    if type(tbl) ~= "table" then return maxKey end
    for k in pairs(tbl) do
        if type(k) == "number" and k > maxKey then
            maxKey = k
        end
    end
    return maxKey
end

local function shiftRight(tbl, startIndex)
    if type(tbl) ~= "table" then return end
    local maxKey = getMaxNumericKey(tbl)
    for i = maxKey, startIndex, -1 do
        tbl[i + 1] = tbl[i]
    end
end

local function removeAt(tbl, index)
    if type(tbl) ~= "table" then return end
    local maxKey = getMaxNumericKey(tbl)
    for i = index, maxKey do
        tbl[i] = tbl[i + 1]
    end
    tbl[maxKey] = nil
end

local function isPayloadEmpty(payload)
    if type(payload) ~= "table" then return payload == nil end
    for _, v in pairs(payload) do
        if v ~= nil and v ~= "" then
            return false
        end
    end
    return true
end

function LIB:NormalizeScope(scope)
    if scope == self.SCOPE_PAGE then
        return self.SCOPE_PAGE
    end
    return self.SCOPE_SETUP
end

function LIB:RegisterProvider(providerKey, providerDef)
    if not providerKey or providerKey == "" then return false end
    providerDef = providerDef or {}
    providerDef.key = providerKey
    self.providers[providerKey] = providerDef
    return true
end

function LIB:RegisterClient(clientDef)
    if type(clientDef) ~= "table" or not clientDef.id or clientDef.id == "" then
        return false
    end
    self.clients[clientDef.id] = clientDef
    self._registeredClientOrder[#self._registeredClientOrder + 1] = clientDef.id
    return true
end

function LIB:GetProvider(providerKey)
    return self.providers[providerKey]
end

function LIB:GetClient(clientId)
    return self.clients[clientId]
end

function LIB:GetClientScope(client, context)
    if not client then
        return self.SCOPE_SETUP
    end

    local scope = client.storageScope
    if type(client.getStorageScope) == "function" then
        local ok, result = pcall(client.getStorageScope, context, client)
        if ok and result ~= nil then
            scope = result
        end
    end

    if scope == nil then
        scope = self.SCOPE_SETUP
    end

    return self:NormalizeScope(scope)
end

function LIB:GetContextScope(context)
    if not context then
        return self.SCOPE_SETUP
    end
    return self:NormalizeScope(context.storageScope or context.scope)
end

function LIB:ClientMatchesContextScope(client, context)
    return self:GetClientScope(client, context) == self:GetContextScope(context)
end

function LIB:HasClientsForScope(providerKey, scope)
    local wantedScope = self:NormalizeScope(scope)
    local found = false

    self:ForEachClient(providerKey, function(client)
        if self:GetClientScope(client) == wantedScope then
            found = true
        end
    end)

    return found
end

function LIB:ForEachClient(providerKey, fn)
    for _, clientId in ipairs(self._registeredClientOrder) do
        local client = self.clients[clientId]
        if client and (not providerKey or client.provider == providerKey) then
            fn(client)
        end
    end
end

function LIB:GetClientStore(client)
    if not client or type(client.getStore) ~= "function" then return nil end
    local ok, store = pcall(client.getStore)
    if not ok or type(store) ~= "table" then return nil end
    return store
end

function LIB:GetProviderRoot(client, providerKey, create)
    local store = self:GetClientStore(client)
    if not store then return nil end
    if create and type(store[providerKey]) ~= "table" then
        store[providerKey] = {}
    end
    return store[providerKey]
end

function LIB:GetPageTable(client, providerKey, context, create)
    if not client or not context or not context.zoneTag or not context.pageId then return nil end
    local root = self:GetProviderRoot(client, providerKey, create)
    if not root then return nil end

    if create and type(root[context.zoneTag]) ~= "table" then
        root[context.zoneTag] = {}
    end
    local zoneStore = root[context.zoneTag]
    if not zoneStore then return nil end

    if create and type(zoneStore[context.pageId]) ~= "table" then
        zoneStore[context.pageId] = {}
    end
    return zoneStore[context.pageId]
end

function LIB:GetPayload(clientId, providerKey, context)
    local client = self:GetClient(clientId)
    if not client then return nil end
    local pageTable = self:GetPageTable(client, providerKey, context, false)
    if not pageTable then return nil end

    local scope = self:GetClientScope(client, context)
    if scope == self.SCOPE_PAGE then
        return pageTable[self.PAGE_SCOPE_KEY]
    end

    if not context.index then return nil end
    return pageTable[context.index]
end

function LIB:SetPayload(clientId, providerKey, context, payload)
    local client = self:GetClient(clientId)
    if not client then return false end
    local pageTable = self:GetPageTable(client, providerKey, context, true)
    if not pageTable then return false end

    local scope = self:GetClientScope(client, context)
    if scope == self.SCOPE_PAGE then
        if payload == nil or isPayloadEmpty(payload) then
            pageTable[self.PAGE_SCOPE_KEY] = nil
        else
            pageTable[self.PAGE_SCOPE_KEY] = deepCopy(payload)
        end
        return true
    end

    if not context.index then return false end

    if payload == nil or isPayloadEmpty(payload) then
        pageTable[context.index] = nil
    else
        pageTable[context.index] = deepCopy(payload)
    end
    return true
end

function LIB:DeletePayload(clientId, providerKey, context)
    return self:SetPayload(clientId, providerKey, context, nil)
end

function LIB:ApplyContext(providerKey, context, reason)
    if not providerKey or not context then return end

    self:ForEachClient(providerKey, function(client)
        local payload = self:GetPayload(client.id, providerKey, context)
        if payload and type(client.apply) == "function" then
            pcall(client.apply, payload, context, reason)
        elseif (payload == nil or isPayloadEmpty(payload)) and type(client.clear) == "function" then
            pcall(client.clear, context, reason)
        end
    end)

    self.callbackManager:FireCallbacks("OnContextApplied", providerKey, context, reason)
end

function LIB:DuplicateSetup(providerKey, context)
    if not providerKey or not context or not context.zoneTag or not context.pageId or not context.index then return end
    local newIndex = context.index + 1

    self:ForEachClient(providerKey, function(client)
        if self:GetClientScope(client, context) == self.SCOPE_SETUP then
            local pageTable = self:GetPageTable(client, providerKey, context, true)
            if pageTable then
                shiftRight(pageTable, newIndex)
                pageTable[newIndex] = deepCopy(pageTable[context.index])
            end
        end
    end)
end

function LIB:DeleteSetup(providerKey, context)
    if not providerKey or not context or not context.zoneTag or not context.pageId or not context.index then return end

    self:ForEachClient(providerKey, function(client)
        if self:GetClientScope(client, context) == self.SCOPE_SETUP then
            local pageTable = self:GetPageTable(client, providerKey, context, false)
            if pageTable then
                removeAt(pageTable, context.index)
            end
        end
    end)
end

function LIB:ClearSetup(providerKey, context)
    if not providerKey or not context or not context.zoneTag or not context.pageId or not context.index then return end

    self:ForEachClient(providerKey, function(client)
        if self:GetClientScope(client, context) == self.SCOPE_SETUP then
            local pageTable = self:GetPageTable(client, providerKey, context, false)
            if pageTable then
                pageTable[context.index] = nil
            end
        end
    end)
end

function LIB:RearrangeSetups(providerKey, zoneTag, pageId, sortTable)
    if not providerKey or not zoneTag or not pageId or type(sortTable) ~= "table" then return end

    self:ForEachClient(providerKey, function(client)
        local context = { zoneTag = zoneTag, pageId = pageId, scope = self.SCOPE_SETUP }
        if self:GetClientScope(client, context) == self.SCOPE_SETUP then
            local oldPage = self:GetPageTable(client, providerKey, context, false)
            if oldPage then
                local pageCopy = deepCopy(oldPage)
                local newPage = {}
                if pageCopy[self.PAGE_SCOPE_KEY] ~= nil then
                    newPage[self.PAGE_SCOPE_KEY] = deepCopy(pageCopy[self.PAGE_SCOPE_KEY])
                end
                for newIndex, entry in ipairs(sortTable) do
                    local oldIndex = entry and entry.data and entry.data.index
                    if oldIndex and pageCopy[oldIndex] ~= nil then
                        newPage[newIndex] = deepCopy(pageCopy[oldIndex])
                    end
                end
                local zoneStore = self:GetProviderRoot(client, providerKey, true)[zoneTag]
                zoneStore[pageId] = newPage
            end
        end
    end)
end

function LIB:DuplicatePage(providerKey, zoneTag, pageId)
    if not providerKey or not zoneTag or not pageId then return end
    local newPageId = pageId + 1

    self:ForEachClient(providerKey, function(client)
        local root = self:GetProviderRoot(client, providerKey, true)
        root[zoneTag] = root[zoneTag] or {}
        local zoneStore = root[zoneTag]
        shiftRight(zoneStore, newPageId)
        zoneStore[newPageId] = deepCopy(zoneStore[pageId] or {})
    end)
end

function LIB:DeletePage(providerKey, zoneTag, pageId)
    if not providerKey or not zoneTag or not pageId then return end

    self:ForEachClient(providerKey, function(client)
        local root = self:GetProviderRoot(client, providerKey, false)
        local zoneStore = root and root[zoneTag]
        if zoneStore then
            removeAt(zoneStore, pageId)
        end
    end)
end

function LIB:RearrangePages(providerKey, zoneTag, sortTable)
    if not providerKey or not zoneTag or type(sortTable) ~= "table" then return end

    self:ForEachClient(providerKey, function(client)
        local root = self:GetProviderRoot(client, providerKey, false)
        local zoneStore = root and root[zoneTag]
        if zoneStore then
            local pageCopy = deepCopy(zoneStore)
            local newZoneStore = {}
            for newIndex, entry in ipairs(sortTable) do
                local oldIndex = entry and entry.data and entry.data.index
                if oldIndex and pageCopy[oldIndex] ~= nil then
                    newZoneStore[newIndex] = deepCopy(pageCopy[oldIndex])
                end
            end
            root[zoneTag] = newZoneStore
        end
    end)
end


function LIB:_RaiseDialogToFront(dialog)
    if not dialog then return end

    if dialog.SetDrawLayer then
        dialog:SetDrawLayer(DL_OVERLAY)
    end
    if dialog.SetDrawTier then
        dialog:SetDrawTier(DT_HIGH)
    end
    if dialog.SetDrawLevel then
        dialog:SetDrawLevel(9999)
    end
    if dialog.BringWindowToTop then
        dialog:BringWindowToTop()
    end
end

function LIB:EnsureConfirmDialog()
    if self._confirmDialogRegistered then return end
    self._confirmDialogRegistered = true

    ZO_Dialogs_RegisterCustomDialog(self._confirmDialogName,
    {
        canQueue = true,

        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },

        title =
        {
            text = "<<1>>",
        },

        mainText =
        {
            text = "<<1>>",
        },

        setup = function(dialog)
            LIB:_RaiseDialogToFront(dialog)
        end,

        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = function(dialog)
                    local data = dialog.data
                    return (data and data.confirmText) or GetString(SI_DIALOG_CONFIRM)
                end,
                callback = function(dialog)
                    local data = dialog.data
                    if data and type(data.onConfirm) == "function" then
                        data.onConfirm(data)
                    end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = function(dialog)
                    local data = dialog.data
                    return (data and data.cancelText) or GetString(SI_DIALOG_CANCEL)
                end,
                callback = function(dialog)
                    local data = dialog.data
                    if data and type(data.onCancel) == "function" then
                        data.onCancel(data)
                    end
                end,
            },
        },
    })
end

function LIB:ShowConfirmDialog(options)
    options = options or {}
    self:EnsureConfirmDialog()

    local title = tostring(options.title or "Confirm")
    local mainText = tostring(options.mainText or "Do you want to continue?")

    ZO_Dialogs_ShowPlatformDialog(self._confirmDialogName,
    {
        title = title,
        mainText = mainText,
        confirmText = options.confirmText,
        cancelText = options.cancelText,
        onConfirm = options.onConfirm,
        onCancel = options.onCancel,
        customData = options.customData,
    },
    {
        titleParams = { title },
        mainTextParams = { mainText },
    })

    zo_callLater(function()
        for i = 1, 4 do
            local dialog = _G["ZO_Dialog" .. tostring(i)]
            if dialog and not dialog:IsHidden() then
                LIB:_RaiseDialogToFront(dialog)
            end
        end
    end, 0)
end

function LIB:ConfirmClearActiveEditor(keepOpen)
    self:ShowConfirmDialog({
        title = "Clear Setup Links",
        mainText = "Do you really want to clear the saved setup link settings?",
        confirmText = "Clear",
        cancelText = GetString(SI_DIALOG_CANCEL),
        onConfirm = function()
            LIB:ClearActiveEditor(keepOpen)
        end,
    })
end

function LIB:_GetEditorDrawTier()
    if self.editor and self.editor.drawTier then
        return self.editor.drawTier
    end
    return DT_HIGH
end

function LIB:_ApplyEditorDrawTier(drawTier)
    if not self.editor then return end

    local resolvedDrawTier = drawTier or DT_HIGH
    self.editor.drawTier = resolvedDrawTier

    if self.editor.win then
        self.editor.win:SetDrawTier(resolvedDrawTier)
    end

    if self.editor.bodyScroll then
        self.editor.bodyScroll:SetDrawTier(resolvedDrawTier)
    end
end



function LIB:_GetFooterButtonDefinition(name)
    local footerButtons = self.activeOptions and self.activeOptions.footerButtons
    local def = type(footerButtons) == "table" and footerButtons[name] or nil
    return type(def) == "table" and def or nil
end

function LIB:_GetDefaultFooterButtonText(name)
    if name == "save" then
        return "Save"
    elseif name == "clear" then
        return "Clear"
    elseif name == "close" then
        return "Close"
    elseif name == "collapse" then
        return self:_IsEditorCollapsed() and ">" or "<"
    end
    return ""
end

function LIB:_GetFooterButtonText(name)
    local def = self:_GetFooterButtonDefinition(name)
    local text = def and def.text or nil
    if type(text) == "function" then
        local ok, result = pcall(text, {
            lib = self,
            name = name,
            providerKey = self.activeProviderKey,
            context = self.activeContext and deepCopy(self.activeContext) or nil,
            options = self.activeOptions,
            editorValues = self.editor and self.editor.values or nil,
        })
        if ok then text = result else text = nil end
    end
    if type(text) == "string" and text ~= "" then
        return text
    end
    return self:_GetDefaultFooterButtonText(name)
end

function LIB:_RunFooterButtonDefaultAction(name)
    if name == "save" then
        self:CommitActiveEditor()
    elseif name == "clear" then
        self:ConfirmClearActiveEditor(true)
    elseif name == "close" then
        self:HideEditor()
    elseif name == "collapse" then
        self:ToggleEditorCollapsed()
    end
end

function LIB:_HandleFooterButtonClick(name)
    local def = self:_GetFooterButtonDefinition(name)
    local buttonControl = nil
    if self.editor then
        if name == "save" then
            buttonControl = self.editor.saveBtn
        elseif name == "clear" then
            buttonControl = self.editor.clearBtn
        elseif name == "close" then
            buttonControl = self.editor.closeBtn
        elseif name == "collapse" then
            buttonControl = self.editor.collapseBtn
        end
    end

    local function defaultAction()
        self:_RunFooterButtonDefaultAction(name)
    end

    if def and type(def.onClick) == "function" then
        local ok, handled = pcall(def.onClick, {
            lib = self,
            name = name,
            control = buttonControl,
            providerKey = self.activeProviderKey,
            context = self.activeContext and deepCopy(self.activeContext) or nil,
            options = self.activeOptions,
            editorValues = self.editor and self.editor.values or nil,
            defaultAction = defaultAction,
        })
        if ok and handled == true then
            return
        end
    end

    defaultAction()
end

function LIB:EnsureEditor()
    if self.editor and self.editor.win then return end

    local win = WINDOW_MANAGER:CreateTopLevelWindow("LibBSCWizardBridgeEditor")
    win:SetHidden(true)
    win:SetDimensions(self.editorWidth, 260)
    win:SetMovable(false)
    win:SetMouseEnabled(true)
    win:SetClampedToScreen(true)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawTier(self:_GetEditorDrawTier())

    local bg = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.88)
    bg:SetEdgeColor(1, 1, 1, 0.45)
    bg:SetEdgeTexture(nil, 1, 1, 2, 0)

    local title = WINDOW_MANAGER:CreateControl(nil, win, CT_LABEL)
    title:SetFont("ZoFontWinH1")
    title:SetAnchor(TOPLEFT, win, TOPLEFT, 18, 18)
    title:SetDimensions(self.editorBodyWidth, 30)
    title:SetText("Setup Links")

    local subtitle = WINDOW_MANAGER:CreateControl(nil, win, CT_LABEL)
    subtitle:SetFont("ZoFontGame")
    subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)
    subtitle:SetDimensions(self.editorBodyWidth, 34)
    subtitle:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    subtitle:SetText("")

    local bodyPlain = WINDOW_MANAGER:CreateControl("LibBSCWizardBridgeEditorBodyPlain", win, CT_CONTROL)
    bodyPlain:SetAnchor(TOPLEFT, subtitle, BOTTOMLEFT, 0, 14)
    bodyPlain:SetDimensions(self.editorInnerBodyWidth, 1)
    bodyPlain:SetHidden(true)

    local bodyScroll = WINDOW_MANAGER:CreateControlFromVirtual("LibBSCWizardBridgeEditorBodyScroll", win, "ZO_ScrollContainer")
    bodyScroll:SetAnchor(TOPLEFT, subtitle, BOTTOMLEFT, 0, 14)
    bodyScroll:SetDimensions(self.editorBodyWidth, 1)
    bodyScroll:SetDrawLayer(DL_OVERLAY)
    bodyScroll:SetDrawTier(self:_GetEditorDrawTier())
    bodyScroll:SetHidden(true)

    local bodyScrollChild = bodyScroll:GetNamedChild("ScrollChild")
    bodyScrollChild:ClearAnchors()
    bodyScrollChild:SetAnchor(TOPLEFT, bodyScroll, TOPLEFT, 0, 0)
    bodyScrollChild:SetDimensions(self.editorInnerBodyWidth, 1)

    local closeBtn = WINDOW_MANAGER:CreateControlFromVirtual("LibBSCWizardBridgeEditorClose", win, "ZO_DefaultButton")
    closeBtn:SetDimensions(120, 32)
    closeBtn:SetText("Close")

    local clearBtn = WINDOW_MANAGER:CreateControlFromVirtual("LibBSCWizardBridgeEditorClear", win, "ZO_DefaultButton")
    clearBtn:SetDimensions(120, 32)
    clearBtn:SetText("Clear")

    local saveBtn = WINDOW_MANAGER:CreateControlFromVirtual("LibBSCWizardBridgeEditorSave", win, "ZO_DefaultButton")
    saveBtn:SetDimensions(120, 32)
    saveBtn:SetText("Save")

    local collapseBtn = WINDOW_MANAGER:CreateControlFromVirtual("LibBSCWizardBridgeEditorCollapse", win, "ZO_DefaultButton")
    collapseBtn:SetDimensions(32, 26)
    collapseBtn:SetText("<")

    saveBtn:SetHandler("OnClicked", function() LIB:_HandleFooterButtonClick("save") end)
    clearBtn:SetHandler("OnClicked", function() LIB:_HandleFooterButtonClick("clear") end)
    closeBtn:SetHandler("OnClicked", function() LIB:_HandleFooterButtonClick("close") end)
    collapseBtn:SetHandler("OnClicked", function() LIB:_HandleFooterButtonClick("collapse") end)

    self.editor = {
        win = win,
        bg = bg,
        title = title,
        subtitle = subtitle,
        bodyPlain = bodyPlain,
        bodyScroll = bodyScroll,
        bodyScrollChild = bodyScrollChild,
        body = bodyPlain,
        useScrollBody = false,
        saveBtn = saveBtn,
        clearBtn = clearBtn,
        closeBtn = closeBtn,
        collapseBtn = collapseBtn,
        dynamicControls = {},
        values = {},
        buildSerial = 0,
        references = {},
        referenceOrder = {},
        showSaveButton = true,
        showClearButton = true,
        showCloseButton = true,
        isCollapsed = false,
        collapseKey = nil,
        currentContentHeight = 1,
    }
end

function LIB:ClearDynamicControls()
    if not self.editor then return end
    for _, control in ipairs(self.editor.dynamicControls) do
        if control then
            control:SetHidden(true)
        end
    end
    self.editor.dynamicControls = {}
    self.editor.values = {}
    self.editor.references = {}
    self.editor.referenceOrder = {}
    self.editor.runtimeRefs = {}
    if self.editor.bodyPlain then
        self.editor.bodyPlain:SetDimensions(self.editorInnerBodyWidth, 1)
    end
    if self.editor.bodyScrollChild then
        self.editor.bodyScrollChild:SetDimensions(self.editorInnerBodyWidth, 1)
    end
    self.editor.body = self.editor.bodyPlain
    self.editor.useScrollBody = false
    if self.editor.bodyScroll and ZO_Scroll_ResetToTop then
        ZO_Scroll_ResetToTop(self.editor.bodyScroll)
    end
end

function LIB:_RegisterDynamicControl(control)
    self.editor.dynamicControls[#self.editor.dynamicControls + 1] = control
    return control
end

function LIB:_CreateLabel(parent, name, text, x, y, width, font, tooltipText)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    label:SetDimensions(width or 220, 28)
    label:SetFont(font or "ZoFontGame")
    label:SetText(text or "")
    label:SetMouseEnabled(true)
    self:_RegisterDynamicControl(label)
    self:_SetTooltipHandlers(label, tooltipText)
    return label
end

function LIB:_CreateSpacer(parent, name, x, y, width, height, textureHeight, texturePath, color)
    local spacer = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    local spacerWidth = width or 220
    local spacerHeight = height or 18
    local lineHeight = textureHeight or 2
    local lineOffsetY = zo_floor((spacerHeight - lineHeight) / 2)

    spacer:ClearAnchors()
    spacer:SetAnchor(TOPLEFT, parent, TOPLEFT, x or 0, y or 0)
    spacer:SetDimensions(spacerWidth, spacerHeight)
    spacer:SetMouseEnabled(false)
    self:_RegisterDynamicControl(spacer)

    local line = WINDOW_MANAGER:CreateControl(nil, spacer, CT_TEXTURE)
    line:ClearAnchors()
    line:SetAnchor(TOPLEFT, spacer, TOPLEFT, 0, lineOffsetY)
    line:SetAnchor(TOPRIGHT, spacer, TOPRIGHT, 0, lineOffsetY)
    line:SetHeight(lineHeight)
    line:SetTexture(texturePath or ZO_WHITE_TEXTURE)
    local r, g, b, a = 0.75, 0.75, 0.75, 0.9
    if type(color) == "table" then
        r = tonumber(color[1] or color.r or r) or r
        g = tonumber(color[2] or color.g or g) or g
        b = tonumber(color[3] or color.b or b) or b
        a = tonumber(color[4] or color.a or a) or a
    end
    line:SetColor(r, g, b, a)
    self:_RegisterDynamicControl(line)

    return spacer, line
end

function LIB:_CreateCombo(parent, name, x, y, width)
    local comboControl = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_ComboBox")
    comboControl:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    comboControl:SetDimensions(width or 260, 28)
    comboControl:SetMouseEnabled(true)
    return self:_RegisterDynamicControl(comboControl)
end

function LIB:_ShowTooltip(control, tooltipText)
    if not control or not tooltipText or tooltipText == "" then return end
    InitializeTooltip(InformationTooltip, control, TOP, 0, 0)

    if InformationTooltipTopLevel then
        InformationTooltipTopLevel:SetDrawLayer(DL_OVERLAY)
        InformationTooltipTopLevel:SetDrawTier(DT_HIGH)
        InformationTooltipTopLevel:SetDrawLevel(9999)
        if InformationTooltipTopLevel.BringWindowToTop then
            InformationTooltipTopLevel:BringWindowToTop()
        end
    end

    InformationTooltip:SetDrawLayer(DL_OVERLAY)
    InformationTooltip:SetDrawTier(DT_HIGH)
    InformationTooltip:SetDrawLevel(9999)
    if InformationTooltip.BringWindowToTop then
        InformationTooltip:BringWindowToTop()
    end

    SetTooltipText(InformationTooltip, tooltipText)

    if InformationTooltipTopLevel and InformationTooltipTopLevel.BringWindowToTop then
        InformationTooltipTopLevel:BringWindowToTop()
    end
end

function LIB:_HideTooltip()
    ClearTooltip(InformationTooltip)
end

function LIB:_ResolveTooltipText(tooltipText)
    if tooltipText == nil then return nil end
    if type(tooltipText) == "function" then
        local ok, result = pcall(tooltipText)
        if ok then
            tooltipText = result
        else
            tooltipText = nil
        end
    end
    if tooltipText == nil then return nil end
    tooltipText = tostring(tooltipText)
    if tooltipText == "" then return nil end
    return tooltipText
end

function LIB:_InstallDropdownTooltipHooks()
    if self._dropdownTooltipHooksInstalled then return end
    self._dropdownTooltipHooksInstalled = true

    local function showTooltipForRow(comboBoxRowCtrl)
        if not comboBoxRowCtrl then return end

        local owner = comboBoxRowCtrl.m_owner
        if not owner or not owner.BSCSetupBridgeHasChoiceTooltips then return end

        local tooltipText = comboBoxRowCtrl.BSCSetupBridgeDropdownTooltip
        if tooltipText == nil and comboBoxRowCtrl.m_data then
            tooltipText = comboBoxRowCtrl.m_data.BSCSetupBridgeDropdownTooltip
        end
        if tooltipText == nil then
            tooltipText = comboBoxRowCtrl.tooltip
        end
        if tooltipText == nil and comboBoxRowCtrl.m_data then
            tooltipText = comboBoxRowCtrl.m_data.tooltip
        end

        tooltipText = LIB:_ResolveTooltipText(tooltipText)
        if not tooltipText then return end

        LIB:_ShowTooltip(comboBoxRowCtrl, tooltipText)
        if InformationTooltipTopLevel and InformationTooltipTopLevel.BringWindowToTop then
            InformationTooltipTopLevel:BringWindowToTop()
        end
    end

    local function hideTooltipForRow(comboBoxRowCtrl)
        local owner = comboBoxRowCtrl and comboBoxRowCtrl.m_owner
        if owner and owner.BSCSetupBridgeHasChoiceTooltips then
            LIB:_HideTooltip()
        end
    end

    if ZO_ComboBoxDropdown_Keyboard then
        SecurePostHook(ZO_ComboBoxDropdown_Keyboard, "OnEntryMouseEnter", showTooltipForRow)
        SecurePostHook(ZO_ComboBoxDropdown_Keyboard, "OnEntryMouseExit", hideTooltipForRow)
    else
        if ZO_ComboBox_Entry_OnMouseEnter then
            SecurePostHook("ZO_ComboBox_Entry_OnMouseEnter", showTooltipForRow)
        end
        if ZO_ComboBox_Entry_OnMouseExit then
            SecurePostHook("ZO_ComboBox_Entry_OnMouseExit", hideTooltipForRow)
        end
    end
end

function LIB:_ResolveChoiceText(choice)
    if type(choice) == "table" then
        if choice.name ~= nil then return tostring(choice.name) end
        if choice.label ~= nil then return tostring(choice.label) end
        if choice.text ~= nil then return tostring(choice.text) end
        if choice.value ~= nil then return tostring(choice.value) end
    end
    return tostring(choice)
end

function LIB:_ResolveChoiceValue(choice)
    if type(choice) == "table" and choice.value ~= nil then
        return choice.value
    end
    return choice
end

function LIB:_ResolveChoices(field, context, payload)
    local choices = {}
    if not field then return choices end

    if type(field.choices) == "function" then
        local ok, result = pcall(field.choices, context, payload)
        if ok and type(result) == "table" then
            choices = result
        end
    elseif type(field.choices) == "table" then
        choices = field.choices
    end

    return choices
end

function LIB:_ResolveChoicesTooltips(field, context, payload, choices)
    if not field then return nil end

    if type(field.choicesTooltips) == "function" then
        local ok, result = pcall(field.choicesTooltips, context, payload, choices)
        if ok and type(result) == "table" then
            return result
        end
        return nil
    end

    if type(field.choicesTooltips) == "table" then
        return field.choicesTooltips
    end

    return nil
end

function LIB:_GetChoiceTooltip(choicesTooltips, index)
    if type(choicesTooltips) ~= "table" then return nil end
    return choicesTooltips[index]
end

function LIB:_ResolveFieldReference(field, context, payload, client)
    if not field then return nil end
    local reference = field.reference
    if type(reference) == "function" then
        local ok, result = pcall(reference, context, payload, client)
        if ok then
            reference = result
        else
            reference = nil
        end
    end
    if reference == nil or reference == "" then
        return nil
    end
    return tostring(reference)
end

function LIB:_SetTooltipHandlers(control, tooltipText)
    tooltipText = self:_ResolveTooltipText(tooltipText)
    if not control or not tooltipText or tooltipText == "" then return end
    control:SetHandler("OnMouseEnter", function(self)
        LIB:_ShowTooltip(self, tooltipText)
    end)
    control:SetHandler("OnMouseExit", function()
        LIB:_HideTooltip()
    end)
end

function LIB:_CreateCheckBox(parent, name, labelText, x, y, width, checked, onToggle, tooltipText)
    local cb = CreateControlFromVirtual(name, parent, "ZO_CheckButton")
    cb:ClearAnchors()
    cb:SetAnchor(TOPLEFT, parent, TOPLEFT, x or 0, y or 0)
    cb:SetDrawLayer(DL_OVERLAY)
    cb:SetDrawTier(self:_GetEditorDrawTier())
    cb:SetMouseEnabled(true)

    ZO_CheckButton_SetToggleFunction(cb, function(button, isChecked)
        if onToggle then
            onToggle(button, isChecked)
        end
    end)
    ZO_CheckButton_SetCheckState(cb, checked and true or false)
    self:_RegisterDynamicControl(cb)

    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetText(labelText or "")
    label:SetDimensions(width or 420, 24)
    label:SetAnchor(LEFT, cb, RIGHT, 8, 0)
    label:SetMouseEnabled(true)
    label:SetHandler("OnMouseUp", function(_, button, upInside)
        if cb.BSCSetupBridgeDisabled then return end
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            ZO_CheckButton_OnClicked(cb)
        end
    end)
    self:_RegisterDynamicControl(label)

    self:_SetTooltipHandlers(cb, tooltipText)
    self:_SetTooltipHandlers(label, tooltipText)

    return cb, label
end

function LIB:_CreateButton(parent, name, buttonText, x, y, width, height, onClick, tooltipText)
    local btn = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_DefaultButton")
    btn:ClearAnchors()
    btn:SetAnchor(TOPLEFT, parent, TOPLEFT, x or 0, y or 0)
    btn:SetDimensions(width or 220, height or 26)
    btn:SetText(buttonText or "Button")
    btn:SetMouseEnabled(true)
    btn:SetHandler("OnClicked", function(...)
        if btn.BSCSetupBridgeDisabled then return end
        if type(onClick) == "function" then
            onClick(...)
        end
    end)
    self:_RegisterDynamicControl(btn)
    self:_SetTooltipHandlers(btn, tooltipText)
    return btn
end

function LIB:_ResolveFieldDisplayText(rawText, context, payload, client, field, refData)
    if type(rawText) == "function" then
        local ok, result = pcall(rawText, context, payload, client, field, refData)
        if ok then
            rawText = result
        else
            rawText = ""
        end
    end
    if rawText == nil then
        return ""
    end
    return tostring(rawText)
end

function LIB:_TrackRuntimeRef(refData)
    if not self.editor or type(refData) ~= "table" then return refData end
    self.editor.runtimeRefs = self.editor.runtimeRefs or {}
    self.editor.runtimeRefs[#self.editor.runtimeRefs + 1] = refData
    return refData
end

function LIB:_AttachReferenceHelpers(refData)
    if type(refData) ~= "table" then return refData end

    refData.GetValue = function(self)
        return LIB:GetValue(self)
    end

    refData.SetValue = function(self, value, suppressCallback)
        return LIB:SetValue(self, value, suppressCallback)
    end

    refData.UpdateChoices = function(self, choices, selectedValue, choicesTooltips)
        return LIB:UpdateChoices(self, choices, selectedValue, choicesTooltips)
    end

    refData.IsDisabled = function(self)
        return LIB:IsDisabled(self)
    end

    refData.SetDisabled = function(self, disabled)
        return LIB:SetDisabled(self, disabled)
    end

    refData.UpdateDisabled = function(self)
        return LIB:UpdateDisabled(self)
    end

    return refData
end

function LIB:_RegisterFieldReference(reference, data)
    if not self.editor or not reference or reference == "" then return end
    local key = tostring(reference)
    self.editor.references = self.editor.references or {}
    self.editor.referenceOrder = self.editor.referenceOrder or {}
    if not self.editor.references[key] then
        self.editor.referenceOrder[#self.editor.referenceOrder + 1] = key
    end
    self.editor.references[key] = self:_AttachReferenceHelpers(data)
end

function LIB:GetReference(reference)
    if not self.editor or not self.editor.references or not reference then return nil end
    return self.editor.references[tostring(reference)]
end

function LIB:_InvokeFieldOnValueChanged(refData, newValue, previousValue, extra)
    if not refData or not refData.field then return end
    local field = refData.field
    if type(field.onValueChanged) ~= "function" then return end

    local values = {}
    if self.editor and self.editor.values and refData.clientId then
        values = self.editor.values[refData.clientId] or {}
    end

    pcall(field.onValueChanged, newValue, previousValue, refData.context, values, refData, extra)
end

function LIB:_RunInitialFieldCallbacks()
    if not self.editor or not self.editor.referenceOrder then return end

    for _, key in ipairs(self.editor.referenceOrder) do
        local refData = self.editor.references and self.editor.references[key]
        if refData and refData.type == "dropdown" and refData.field and type(refData.field.onValueChanged) == "function" then
            local values = self.editor.values and self.editor.values[refData.clientId] or nil
            local currentValue = values and values[refData.fieldKey] or nil
            self:_InvokeFieldOnValueChanged(refData, currentValue, nil, { source = "init" })
        end
    end
end

function LIB:GetValue(reference)
    local ref = type(reference) == "table" and reference or self:GetReference(reference)
    if not ref or not self.editor or not self.editor.values then return nil end
    local values = self.editor.values[ref.clientId]
    return values and values[ref.fieldKey] or nil
end

function LIB:SetValue(reference, value, suppressCallback)
    local ref = type(reference) == "table" and reference or self:GetReference(reference)
    if not ref or not self.editor or not self.editor.values then
        return false
    end

    self.editor.values[ref.clientId] = self.editor.values[ref.clientId] or {}
    local previousValue = self.editor.values[ref.clientId][ref.fieldKey]

    if ref.type == "dropdown" then
        local selectedText = ""
        local selectedValue = value
        local found = false

        for _, choice in ipairs(ref.choices or {}) do
            local choiceValue = self:_ResolveChoiceValue(choice)
            if choiceValue == value then
                selectedText = self:_ResolveChoiceText(choice)
                selectedValue = choiceValue
                found = true
                break
            end
        end

        if not found then
            if value == nil and ref.field and ref.field.default ~= nil then
                selectedValue = ref.field.default
                for _, choice in ipairs(ref.choices or {}) do
                    local choiceValue = self:_ResolveChoiceValue(choice)
                    if choiceValue == selectedValue then
                        selectedText = self:_ResolveChoiceText(choice)
                        found = true
                        break
                    end
                end
            end
        end

        self.editor.values[ref.clientId][ref.fieldKey] = selectedValue
        if ref.combo then
            ref.combo:SetSelectedItemText(selectedText or "")
        end

        if not suppressCallback then
            self:_InvokeFieldOnValueChanged(ref, selectedValue, previousValue, { source = "SetValue" })
        end
        self:UpdateAllDisabledStates()
        return true

    elseif ref.type == "checkbox" then
        local checked = value and true or false
        self.editor.values[ref.clientId][ref.fieldKey] = checked
        if ref.control then
            ZO_CheckButton_SetCheckState(ref.control, checked)
        end

        if not suppressCallback then
            self:_InvokeFieldOnValueChanged(ref, checked, previousValue, { source = "SetValue" })
        end
        self:UpdateAllDisabledStates()
        return true
    end

    return false
end

function LIB:_ResolveFieldDisabled(field, context, values, client, refData)
    if type(field) ~= "table" then return false end

    local disabled = field.disabled
    if type(disabled) == "function" then
        local ok, result = pcall(disabled, context, values or {}, client, field, refData)
        if ok then
            disabled = result
        else
            disabled = false
        end
    end

    return disabled == true
end

function LIB:_SetControlEnabledVisual(control, enabled)
    if not control then return end

    if control.SetState then
        control:SetState(enabled and BSTATE_NORMAL or BSTATE_DISABLED, false)
    end

    if control.SetEnabled then
        pcall(function()
            control:SetEnabled(enabled)
        end)
    end

    control:SetAlpha(enabled and 1 or 0.5)
end

function LIB:_ApplyDisabledState(refData, disabled)
    if type(refData) ~= "table" then return false end

    disabled = disabled and true or false
    refData.disabled = disabled

    if refData.type == "dropdown" then
        if refData.comboControl then
            refData.comboControl.BSCSetupBridgeDisabled = disabled
            if disabled then
                if ZO_ComboBox_Disable then
                    pcall(ZO_ComboBox_Disable, refData.comboControl)
                else
                    refData.comboControl:SetMouseEnabled(false)
                    refData.comboControl:SetAlpha(0.5)
                end
            else
                if ZO_ComboBox_Enable then
                    pcall(ZO_ComboBox_Enable, refData.comboControl)
                else
                    refData.comboControl:SetMouseEnabled(true)
                    refData.comboControl:SetAlpha(1)
                end
            end
            if refData.comboControl.SetAlpha then
                refData.comboControl:SetAlpha(disabled and 0.5 or 1)
            end
        end
        if refData.labelControl then
            refData.labelControl:SetAlpha(disabled and 0.5 or 1)
        end
        return true
    elseif refData.type == "checkbox" then
        if refData.control then
            refData.control.BSCSetupBridgeDisabled = disabled
            if ZO_CheckButton_SetEnableState then
                pcall(ZO_CheckButton_SetEnableState, refData.control, not disabled)
            elseif disabled and ZO_CheckButton_Disable then
                pcall(ZO_CheckButton_Disable, refData.control)
            elseif not disabled and ZO_CheckButton_Enable then
                pcall(ZO_CheckButton_Enable, refData.control)
            end
            refData.control:SetAlpha(disabled and 0.5 or 1)
        end
        if refData.label then
            refData.label:SetAlpha(disabled and 0.5 or 1)
        end
        return true
    elseif refData.type == "button" then
        if refData.control then
            refData.control.BSCSetupBridgeDisabled = disabled
            self:_SetControlEnabledVisual(refData.control, not disabled)
        end
        return true
    elseif refData.type == "label" then
        if refData.control then
            refData.control:SetAlpha(disabled and 0.5 or 1)
        end
        return true
    end

    return false
end

function LIB:IsDisabled(reference)
    local ref = type(reference) == "table" and reference or self:GetReference(reference)
    if not ref then return nil end
    return ref.disabled == true
end

function LIB:UpdateDisabled(reference)
    local ref = type(reference) == "table" and reference or self:GetReference(reference)
    if not ref or not ref.field then
        return false
    end

    local values = self.editor and self.editor.values and self.editor.values[ref.clientId] or {}
    local client = self:GetClient(ref.clientId)
    local disabled = self:_ResolveFieldDisabled(ref.field, ref.context, values, client, ref)

    if ref.manualDisabled ~= nil then
        disabled = ref.manualDisabled and true or false
    end

    return self:_ApplyDisabledState(ref, disabled)
end

function LIB:SetDisabled(reference, disabled)
    local ref = type(reference) == "table" and reference or self:GetReference(reference)
    if not ref then
        return false
    end

    if disabled == nil then
        ref.manualDisabled = nil
        return self:UpdateDisabled(ref)
    end

    ref.manualDisabled = disabled and true or false
    return self:_ApplyDisabledState(ref, ref.manualDisabled)
end

function LIB:UpdateAllDisabledStates()
    if not self.editor then return end

    for _, ref in ipairs(self.editor.runtimeRefs or {}) do
        if ref and (ref.type == "dropdown" or ref.type == "checkbox" or ref.type == "button" or ref.type == "label") then
            self:UpdateDisabled(ref)
        end
    end
end

function LIB:_PopulateComboReference(ref, choices, selectedValue, choicesTooltips)
    if not ref or not ref.combo then return false end

    local combo = ref.combo
    local clientId = ref.clientId
    local fieldKey = ref.fieldKey

    combo:ClearItems()

    ref.choices = choices or {}
    ref.choicesTooltips = choicesTooltips

    local hasChoiceTooltips = false
    for _, tooltipText in ipairs(ref.choicesTooltips or {}) do
        if self:_ResolveTooltipText(tooltipText) then
            hasChoiceTooltips = true
            break
        end
    end

    combo.BSCSetupBridgeHasChoiceTooltips = hasChoiceTooltips
    if hasChoiceTooltips then
        self:_InstallDropdownTooltipHooks()
    end

    for index, choice in ipairs(ref.choices) do
        local choiceText = self:_ResolveChoiceText(choice)
        local choiceValue = self:_ResolveChoiceValue(choice)
        local choiceTooltip = self:_ResolveTooltipText(self:_GetChoiceTooltip(ref.choicesTooltips, index))

        local entry = ZO_ComboBox:CreateItemEntry(choiceText, function()
            if ref.disabled then return end
            local previousValue = LIB.editor.values[clientId][fieldKey]
            LIB.editor.values[clientId][fieldKey] = choiceValue
            LIB:_InvokeFieldOnValueChanged(ref, choiceValue, previousValue, { source = "dropdown" })
            LIB:UpdateAllDisabledStates()
        end)

        if choiceTooltip then
            entry.BSCSetupBridgeDropdownTooltip = choiceTooltip
            entry.tooltip = choiceTooltip
        end

        combo:AddItem(entry)
    end

    local finalSelectedValue = selectedValue
    if finalSelectedValue == nil then
        finalSelectedValue = self.editor and self.editor.values and self.editor.values[clientId] and self.editor.values[clientId][fieldKey]
    end
    if finalSelectedValue == nil then
        finalSelectedValue = ref.field and ref.field.default or nil
    end

    local selectedText = nil
    local hasSelectedValue = false
    for _, choice in ipairs(ref.choices) do
        local choiceValue = self:_ResolveChoiceValue(choice)
        if choiceValue == finalSelectedValue then
            selectedText = self:_ResolveChoiceText(choice)
            hasSelectedValue = true
            break
        end
    end

    if not hasSelectedValue then
        if ref.choices[1] ~= nil then
            finalSelectedValue = self:_ResolveChoiceValue(ref.choices[1])
            selectedText = self:_ResolveChoiceText(ref.choices[1])
        else
            finalSelectedValue = nil
            selectedText = ""
        end
    end

    if self.editor and self.editor.values and self.editor.values[clientId] then
        self.editor.values[clientId][fieldKey] = finalSelectedValue
    end

    combo:SetSelectedItemText(selectedText or "")
    return true
end

function LIB:UpdateChoices(reference, choices, selectedValue, choicesTooltips)
    local ref = type(reference) == "table" and reference or self:GetReference(reference)
    if not ref or ref.type ~= "dropdown" then
        return false
    end

    local payload = self.editor and self.editor.values and self.editor.values[ref.clientId] or {}
    local finalChoices = choices
    if finalChoices == nil then
        finalChoices = self:_ResolveChoices(ref.field, ref.context, payload)
    end

    local finalTooltips = choicesTooltips
    if finalTooltips == nil then
        finalTooltips = self:_ResolveChoicesTooltips(ref.field, ref.context, payload, finalChoices)
    end

    local ok = self:_PopulateComboReference(ref, finalChoices or {}, selectedValue, finalTooltips)
    self:UpdateDisabled(ref)
    return ok
end

function LIB:_GetContextText(providerKey, context)
    local provider = self:GetProvider(providerKey)
    if provider and type(provider.getContextText) == "function" then
        local ok, text = pcall(provider.getContextText, context)
        if ok and text then return text end
    end
    return string.format("%s / %s / %s", tostring(context.zoneTag or "?"), tostring(context.pageId or "?"), tostring(context.index or "?"))
end


function LIB:_GetSubtitleHeight()
    local textHeight = self.editor.subtitle:GetTextHeight()
    return zo_max(34, zo_min(70, zo_ceil(textHeight + 6)))
end

function LIB:_NormalizeFieldWidthMode(field)
    if type(field) ~= "table" then return "full" end

    if field.type == "spacer" then
        return "full"
    end

    local width = field.width
    if width == nil then
        return "full"
    end

    if type(width) == "string" then
        local normalized = zo_strlower(width)
        if normalized == "half" then
            return "half"
        end
    end

    return "full"
end

function LIB:_GetFieldRowHeight(field)
    if type(field) ~= "table" then
        return 36
    end

    if field.type == "checkbox" then
        return 30
    end

    if field.type == "spacer" then
        return zo_max(10, tonumber(field.height or field.rowHeight or 18) or 18)
    end

    return 36
end

function LIB:_AccumulateFieldLayoutHeight(currentHeight, pendingHalfRowHeight, field)
    local widthMode = self:_NormalizeFieldWidthMode(field)
    local rowHeight = self:_GetFieldRowHeight(field)

    if widthMode == "half" then
        if pendingHalfRowHeight then
            currentHeight = currentHeight + zo_max(pendingHalfRowHeight, rowHeight)
            pendingHalfRowHeight = nil
        else
            pendingHalfRowHeight = rowHeight
        end
    else
        if pendingHalfRowHeight then
            currentHeight = currentHeight + pendingHalfRowHeight
            pendingHalfRowHeight = nil
        end
        currentHeight = currentHeight + rowHeight
    end

    return currentHeight, pendingHalfRowHeight
end

function LIB:_EstimateContentHeight(providerKey, context)
    local totalHeight = 0
    local sectionGap = 16
    local rowGap = 36
    local checkBoxRowGap = 30

    self:ForEachClient(providerKey, function(client)
        if self:ClientMatchesContextScope(client, context) and type(client.getEditorFields) == "function" then
            local payload = self:GetPayload(client.id, providerKey, context) or {}
            local fields = client.getEditorFields(context, payload) or {}
            local visibleFieldCount = 0

            for _, field in ipairs(fields) do
                local hidden = false
                if type(field.hidden) == "function" then
                    hidden = field.hidden(context, payload) == true
                else
                    hidden = field.hidden == true
                end
                if not hidden then
                    visibleFieldCount = visibleFieldCount + 1
                end
            end

            if visibleFieldCount > 0 then
                totalHeight = totalHeight + 34
                local pendingHalfRowHeight = nil
                for _, field in ipairs(fields) do
                    local hidden = false
                    if type(field.hidden) == "function" then
                        hidden = field.hidden(context, payload) == true
                    else
                        hidden = field.hidden == true
                    end
                    if not hidden then
                        totalHeight, pendingHalfRowHeight = self:_AccumulateFieldLayoutHeight(totalHeight, pendingHalfRowHeight, field)
                    end
                end
                if pendingHalfRowHeight then
                    totalHeight = totalHeight + pendingHalfRowHeight
                end
                totalHeight = totalHeight + sectionGap
            end
        end
    end)

    return totalHeight
end

function LIB:_GetEditorCollapseKey(providerKey, context, options)
    if type(options) == "table" and options.collapseKey ~= nil then
        return tostring(options.collapseKey)
    end

    return string.format("%s:%s", tostring(providerKey or "?"), tostring(self:GetContextScope(context)))
end

function LIB:_ResolveInitialCollapsedState(providerKey, context, options)
    if type(options) ~= "table" or options.collapsible ~= true then
        return false
    end

    local key = self:_GetEditorCollapseKey(providerKey, context, options)
    if key and self._collapsedStateByKey[key] ~= nil then
        return self._collapsedStateByKey[key] == true
    end

    return options.startCollapsed == true
end

function LIB:_ShouldEditorBeCollapsible()
    return self.editor and self.activeOptions and self.activeOptions.collapsible == true
end

function LIB:_IsEditorCollapsed()
    return self.editor and self.editor.isCollapsed == true and self:_ShouldEditorBeCollapsible()
end

function LIB:SetEditorCollapsed(collapsed)
    if not self.editor then return false end

    local canCollapse = self:_ShouldEditorBeCollapsible()
    local finalCollapsed = canCollapse and collapsed == true or false
    self.editor.isCollapsed = finalCollapsed

    if self.editor.collapseKey then
        self._collapsedStateByKey[self.editor.collapseKey] = finalCollapsed
    end

    if self.editor.collapseBtn then
        self.editor.collapseBtn:SetHidden(not canCollapse)
        self.editor.collapseBtn:SetText(finalCollapsed and ">" or "<")
    end

    self:_RelayoutEditor(self.editor.currentContentHeight or 1)
    zo_callLater(function()
        if LIB.editor and LIB.editor.win and not LIB.editor.win:IsHidden() then
            LIB:_RelayoutEditor(LIB.editor.currentContentHeight or 1)
        end
    end, 0)
    return true
end

function LIB:ToggleEditorCollapsed()
    if not self:_ShouldEditorBeCollapsible() then
        return false
    end
    return self:SetEditorCollapsed(not self:_IsEditorCollapsed())
end

function LIB:_GetMatchedAnchorHeight(collapsed)
    if collapsed or not self.activeOptions or self.activeOptions.matchAnchorHeight ~= true then
        return nil
    end

    local anchorControl = self.activeOptions.anchorTo
    if not anchorControl or not anchorControl.GetHeight then
        return nil
    end

    local anchorHeight = tonumber(anchorControl:GetHeight()) or 0
    if anchorHeight <= 0 then
        return nil
    end

    local minHeight = tonumber(self.activeOptions.matchAnchorMinHeight) or 150
    local maxHeight = nil

    if self.activeOptions.matchAnchorMaxHeight then
        maxHeight = tonumber(self.activeOptions.matchAnchorMaxHeight)
    elseif GuiRoot and GuiRoot.GetHeight then
        maxHeight = zo_max(minHeight, (tonumber(GuiRoot:GetHeight()) or anchorHeight) - 20)
    end

    anchorHeight = zo_max(minHeight, anchorHeight)
    if maxHeight and maxHeight > 0 then
        anchorHeight = zo_min(anchorHeight, maxHeight)
    end

    return anchorHeight
end

function LIB:_RelayoutEditor(contentHeight)
    if not self.editor or not self.editor.win then return end

    local collapsed = self:_IsEditorCollapsed()
    local width = collapsed and ((self.activeOptions and self.activeOptions.collapsedWidth) or 190) or self.editorWidth
    local bodyWidth = zo_max(1, width - 36)
    local innerBodyWidth = zo_max(1, bodyWidth - 20)
    local titleWidth = zo_max(1, width - 72)
    local subtitleVisible = not collapsed
    local subtitleHeight = subtitleVisible and self:_GetSubtitleHeight() or 0
    local realContentHeight = zo_max(1, contentHeight or 1)
    local footerVisible = (not collapsed) and (self.editor.showSaveButton or self.editor.showClearButton or self.editor.showCloseButton)
    local bodyTop = 18 + 30
    local matchedWinHeight = self:_GetMatchedAnchorHeight(collapsed)

    self.editor.title:SetDimensions(titleWidth, 30)
    self.editor.subtitle:SetDimensions(bodyWidth, subtitleHeight)
    self.editor.subtitle:SetHidden(not subtitleVisible)

    if subtitleVisible then
        self.editor.subtitle:ClearAnchors()
        self.editor.subtitle:SetAnchor(TOPLEFT, self.editor.title, BOTTOMLEFT, 0, 8)
        bodyTop = bodyTop + 8 + subtitleHeight + 14
    end

    local footerSpace = footerVisible and (14 + 32 + 18) or 18
    local maxBodyHeight = self.editorMaxBodyHeight or 360

    if matchedWinHeight then
        maxBodyHeight = zo_max(1, matchedWinHeight - bodyTop - footerSpace)
    end

    local useScrollBody = (not collapsed) and (matchedWinHeight ~= nil or realContentHeight > maxBodyHeight)
    local visibleBodyHeight

    if matchedWinHeight then
        visibleBodyHeight = maxBodyHeight
    else
        visibleBodyHeight = useScrollBody and maxBodyHeight or realContentHeight
    end

    self.editor.currentContentHeight = realContentHeight
    self.editor.useScrollBody = useScrollBody
    self.editor.body = useScrollBody and self.editor.bodyScrollChild or self.editor.bodyPlain

    if self.editor.bodyPlain then
        self.editor.bodyPlain:ClearAnchors()
        self.editor.bodyPlain:SetAnchor(TOPLEFT, self.editor.win, TOPLEFT, 18, bodyTop)
        self.editor.bodyPlain:SetDimensions(innerBodyWidth, visibleBodyHeight)
        self.editor.bodyPlain:SetHidden(collapsed or useScrollBody)
    end

    if self.editor.bodyScroll then
        self.editor.bodyScroll:ClearAnchors()
        self.editor.bodyScroll:SetAnchor(TOPLEFT, self.editor.win, TOPLEFT, 18, bodyTop)
        self.editor.bodyScroll:SetDimensions(bodyWidth, visibleBodyHeight)
        self.editor.bodyScroll:SetHidden(collapsed or not useScrollBody)
    end

    if self.editor.bodyScrollChild then
        self.editor.bodyScrollChild:ClearAnchors()
        self.editor.bodyScrollChild:SetAnchor(TOPLEFT, self.editor.bodyScroll, TOPLEFT, 0, 0)
        self.editor.bodyScrollChild:SetDimensions(innerBodyWidth, realContentHeight)
    end

    local buttonY = bodyTop + visibleBodyHeight + 14
    local winHeight
    if collapsed then
        winHeight = 66
    elseif matchedWinHeight then
        winHeight = matchedWinHeight
    else
        winHeight = footerVisible and zo_max(190, buttonY + 32 + 18) or zo_max(150, bodyTop + visibleBodyHeight + 18)
    end

    self.editor.saveBtn:SetHidden(collapsed or not self.editor.showSaveButton)
    self.editor.clearBtn:SetHidden(collapsed or not self.editor.showClearButton)
    self.editor.closeBtn:SetHidden(collapsed or not self.editor.showCloseButton)

    if self.editor.collapseBtn then
        self.editor.collapseBtn:SetHidden(not self:_ShouldEditorBeCollapsible())
        self.editor.collapseBtn:ClearAnchors()
        self.editor.collapseBtn:SetAnchor(TOPRIGHT, self.editor.win, TOPRIGHT, -18, 18)
        self.editor.collapseBtn:SetText(collapsed and ">" or "<")
    end

    local rightAnchorTarget = self.editor.win
    local rightRelativePoint = TOPRIGHT
    local rightOffsetX = -18
    local rightOffsetY = buttonY

    local function anchorButton(btn)
        if not btn or btn:IsHidden() then return end
        btn:ClearAnchors()
        btn:SetAnchor(TOPRIGHT, rightAnchorTarget, rightRelativePoint, rightOffsetX, rightOffsetY)
        rightAnchorTarget = btn
        rightRelativePoint = TOPLEFT
        rightOffsetX = -8
        rightOffsetY = 0
    end

    anchorButton(self.editor.saveBtn)
    anchorButton(self.editor.clearBtn)
    anchorButton(self.editor.closeBtn)

    self.editor.win:SetDimensions(width, winHeight)

    if useScrollBody and ZO_Scroll_UpdateScrollBar then
        ZO_Scroll_UpdateScrollBar(self.editor.bodyScroll)
    end
    if useScrollBody and ZO_Scroll_ResetToTop then
        ZO_Scroll_ResetToTop(self.editor.bodyScroll)
    end
end

function LIB:_ApplyComboVisualFix(comboControl)
    if not comboControl then return end
    comboControl:SetDrawLayer(DL_OVERLAY)
    comboControl:SetDrawTier(self:_GetEditorDrawTier())
    local combo = comboControl.m_comboBox
    if combo and combo.m_dropdown then
        combo.m_dropdown:SetDrawLayer(DL_OVERLAY)
        combo.m_dropdown:SetDrawTier(self:_GetEditorDrawTier())
    end
end

function LIB:_AnchorEditorToControl(anchorControl)
    self.editor.win:ClearAnchors()

    if anchorControl and anchorControl.GetWidth and anchorControl:GetWidth() and anchorControl:GetWidth() > 0 then
        self.editor.win:SetAnchor(TOPLEFT, anchorControl, TOPRIGHT, 12, 0)
        return
    end

    self.editor.win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
end


function LIB:OpenEditor(providerKey, context, options)
    if not providerKey or not context then return end
    self:EnsureEditor()
    self:ClearDynamicControls()

    local resolvedOptions = {}
    if type(options) == "table" then
        for key, value in pairs(options) do
            resolvedOptions[key] = value
        end
    end

    self.activeProviderKey = providerKey
    self.activeContext = deepCopy(context)
    self.activeOptions = resolvedOptions
    self.editor.showSaveButton = resolvedOptions.hideSaveButton ~= true
    self.editor.showClearButton = resolvedOptions.hideClearButton ~= true
    self.editor.showCloseButton = resolvedOptions.hideCloseButton ~= true
    if self.editor.saveBtn then self.editor.saveBtn:SetText(self:_GetFooterButtonText("save")) end
    if self.editor.clearBtn then self.editor.clearBtn:SetText(self:_GetFooterButtonText("clear")) end
    if self.editor.closeBtn then self.editor.closeBtn:SetText(self:_GetFooterButtonText("close")) end
    self.editor.collapseKey = self:_ShouldEditorBeCollapsible() and self:_GetEditorCollapseKey(providerKey, context, resolvedOptions) or nil
    self.editor.isCollapsed = self:_ResolveInitialCollapsedState(providerKey, context, resolvedOptions)
    self:_ApplyEditorDrawTier(resolvedOptions.drawTier or DT_HIGH)
    self.editor.title:SetText(resolvedOptions.title or "Setup Links")
    self.editor.subtitle:SetText(self:_GetContextText(providerKey, context))

    local anchorTo = resolvedOptions.anchorTo
    self:_AnchorEditorToControl(anchorTo)

    local estimatedContentHeight = self:_EstimateContentHeight(providerKey, context)
    local useScrollBody = resolvedOptions.matchAnchorHeight == true or estimatedContentHeight > (self.editorMaxBodyHeight or 360)
    self.editor.useScrollBody = useScrollBody
    self.editor.body = useScrollBody and self.editor.bodyScrollChild or self.editor.bodyPlain

    if self.editor.bodyPlain then
        self.editor.bodyPlain:SetHidden(useScrollBody)
    end
    if self.editor.bodyScroll then
        self.editor.bodyScroll:SetHidden(not useScrollBody)
    end

    local currentY = 0
    local sectionGap = 16
    local rowGap = 36
    local checkBoxRowGap = 30
    local labelWidth = 170
    local valueX = 180
    local valueWidth = 280
    local fullFieldWidth = zo_max(300, (self.editorWidth or 540) - 56)
    local halfFieldGap = 12
    local halfFieldWidth = zo_floor((fullFieldWidth - halfFieldGap) / 2)
    local pendingHalfRowHeight = nil
    local pendingHalfRowY = nil
    local pendingHalfRowActive = false
    self.editor.buildSerial = self.editor.buildSerial + 1

    local function reserveFieldSlot(field)
        local widthMode = self:_NormalizeFieldWidthMode(field)
        local rowHeight = self:_GetFieldRowHeight(field)

        if widthMode == "half" then
            if not pendingHalfRowActive then
                pendingHalfRowActive = true
                pendingHalfRowHeight = rowHeight
                pendingHalfRowY = currentY
                return 0, pendingHalfRowY, halfFieldWidth, widthMode, rowHeight
            end

            local y = pendingHalfRowY
            pendingHalfRowHeight = zo_max(pendingHalfRowHeight or rowHeight, rowHeight)
            local x = halfFieldWidth + halfFieldGap
            currentY = pendingHalfRowY + pendingHalfRowHeight
            pendingHalfRowActive = false
            pendingHalfRowHeight = nil
            pendingHalfRowY = nil
            return x, y, halfFieldWidth, widthMode, rowHeight
        end

        if pendingHalfRowActive and pendingHalfRowHeight then
            currentY = pendingHalfRowY + pendingHalfRowHeight
            pendingHalfRowActive = false
            pendingHalfRowHeight = nil
            pendingHalfRowY = nil
        end

        local y = currentY
        currentY = currentY + rowHeight
        return 0, y, fullFieldWidth, widthMode, rowHeight
    end

    local function finishHalfRowIfNeeded()
        if pendingHalfRowActive and pendingHalfRowHeight then
            currentY = pendingHalfRowY + pendingHalfRowHeight
            pendingHalfRowActive = false
            pendingHalfRowHeight = nil
            pendingHalfRowY = nil
        end
    end

    self:ForEachClient(providerKey, function(client)
        if self:ClientMatchesContextScope(client, context) and type(client.getEditorFields) == "function" then
            local payload = self:GetPayload(client.id, providerKey, context) or {}
            self.editor.values[client.id] = deepCopy(payload)

            local fields = client.getEditorFields(context, payload) or {}
            local visibleFieldCount = 0

            for _, field in ipairs(fields) do
                local hidden = false
                if type(field.hidden) == "function" then
                    hidden = field.hidden(context, payload) == true
                else
                    hidden = field.hidden == true
                end
                if not hidden then
                    visibleFieldCount = visibleFieldCount + 1
                end
            end

            if visibleFieldCount > 0 then
                self:_CreateLabel(self.editor.body,
                    string.format("LibBSCWizardBridgeSection_%d_%s", self.editor.buildSerial, client.id),
                    client.displayName or client.id, 0, currentY, fullFieldWidth, "ZoFontWinH2")
                currentY = currentY + 34

                for _, field in ipairs(fields) do
                    local hidden = false
                    if type(field.hidden) == "function" then
                        hidden = field.hidden(context, payload) == true
                    else
                        hidden = field.hidden == true
                    end

                    if not hidden then
                        local tooltip = field.tooltip
                        if type(tooltip) == "function" then
                            local ok, result = pcall(tooltip, context, payload)
                            tooltip = ok and result or nil
                        end

                        if field.type == "dropdown" then
                            local slotX, slotY, slotWidth, widthMode = reserveFieldSlot(field)
                            local localLabelWidth = labelWidth
                            local localValueX = valueX
                            local localValueWidth = zo_max(60, slotWidth - localValueX)
                            if widthMode == "half" then
                                localLabelWidth = 82
                                localValueX = localLabelWidth + 10
                                localValueWidth = zo_max(60, slotWidth - localValueX)
                            end

                            local fieldLabel = self:_CreateLabel(self.editor.body,
                                string.format("LibBSCWizardBridgeFieldLabel_%d_%s_%s", self.editor.buildSerial, client.id, field.key),
                                field.label or field.key, slotX, slotY + 4, localLabelWidth, "ZoFontGame", tooltip)

                            local comboControl = self:_CreateCombo(self.editor.body,
                                string.format("LibBSCWizardBridgeCombo_%d_%s_%s", self.editor.buildSerial, client.id, field.key),
                                slotX + localValueX, slotY, localValueWidth)
                            self:_ApplyComboVisualFix(comboControl)

                            local combo = comboControl.m_comboBox
                            combo:SetSortsItems(false)

                            local choices = self:_ResolveChoices(field, context, payload)
                            local choicesTooltips = self:_ResolveChoicesTooltips(field, context, payload, choices)

                            local selectedValue = self.editor.values[client.id][field.key]
                            if selectedValue == nil or selectedValue == "" then
                                selectedValue = field.default
                            end

                            local reference = self:_ResolveFieldReference(field, context, payload, client)
                            refData = {
                                type = "dropdown",
                                reference = reference,
                                comboControl = comboControl,
                                combo = combo,
                                labelControl = fieldLabel,
                                clientId = client.id,
                                fieldKey = field.key,
                                field = field,
                                context = deepCopy(context),
                                providerKey = providerKey,
                            }
                            self:_TrackRuntimeRef(refData)

                            self:_PopulateComboReference(refData, choices, selectedValue, choicesTooltips)

                            if reference then
                                self:_RegisterFieldReference(reference, refData)
                            end


                        elseif field.type == "checkbox" then
                            local slotX, slotY, slotWidth = reserveFieldSlot(field)
                            local currentValue = self.editor.values[client.id][field.key]
                            if currentValue == nil then
                                currentValue = field.default and true or false
                                self.editor.values[client.id][field.key] = currentValue
                            end

                            local reference = self:_ResolveFieldReference(field, context, payload, client)
                            local checkName = string.format("LibBSCWizardBridgeCheck_%d_%s_%s", self.editor.buildSerial, client.id, field.key)
                            local refData
                            local cb, label = self:_CreateCheckBox(
                                self.editor.body,
                                checkName,
                                field.label or field.key,
                                slotX,
                                slotY + 2,
                                slotWidth - 20,
                                currentValue,
                                function(_, isChecked)
                                    local previousValue = LIB.editor.values[client.id][field.key]
                                    local newValue = isChecked and true or false
                                    LIB.editor.values[client.id][field.key] = newValue
                                    if refData then
                                        LIB:_InvokeFieldOnValueChanged(refData, newValue, previousValue, { source = "checkbox" })
                                    end
                                    LIB:UpdateAllDisabledStates()
                                end,
                                tooltip
                            )

                            refData = {
                                type = "checkbox",
                                reference = reference,
                                control = cb,
                                label = label,
                                clientId = client.id,
                                fieldKey = field.key,
                                field = field,
                                context = deepCopy(context),
                                providerKey = providerKey,
                            }
                            self:_TrackRuntimeRef(refData)

                            if reference then
                                self:_RegisterFieldReference(reference, refData)
                            end


                        elseif field.type == "label" then
                            local slotX, slotY, slotWidth, widthMode = reserveFieldSlot(field)
                            local reference = self:_ResolveFieldReference(field, context, payload, client)
                            local refData = {
                                type = "label",
                                reference = reference,
                                clientId = client.id,
                                fieldKey = field.key,
                                field = field,
                                context = deepCopy(context),
                                providerKey = providerKey,
                            }
                            self:_TrackRuntimeRef(refData)

                            local labelText = self:_ResolveFieldDisplayText(field.text or field.label or "", context, self.editor.values[client.id], client, field, refData)
                            local labelWidthValue = slotWidth
                            if type(field.width) == "number" then
                                labelWidthValue = field.width
                            elseif widthMode == "full" then
                                labelWidthValue = fullFieldWidth
                            end
                            local label = self:_CreateLabel(
                                self.editor.body,
                                string.format("LibBSCWizardBridgeValueLabel_%d_%s_%s", self.editor.buildSerial, client.id, field.key or "label"),
                                labelText,
                                slotX + (field.x or 0),
                                slotY + (field.offsetY or 4),
                                labelWidthValue,
                                field.font or "ZoFontGame",
                                tooltip
                            )

                            refData.control = label
                            refData.label = label

                            if reference then
                                self:_RegisterFieldReference(reference, refData)
                            end


                        elseif field.type == "spacer" then
                            local slotX, slotY, slotWidth = reserveFieldSlot(field)
                            local reference = self:_ResolveFieldReference(field, context, payload, client)
                            local refData = {
                                type = "spacer",
                                reference = reference,
                                clientId = client.id,
                                fieldKey = field.key,
                                field = field,
                                context = deepCopy(context),
                                providerKey = providerKey,
                            }

                            local spacerWidth = slotWidth
                            if type(field.width) == "number" then
                                spacerWidth = field.width
                            end

                            local spacer, line = self:_CreateSpacer(
                                self.editor.body,
                                string.format("LibBSCWizardBridgeSpacer_%d_%s_%s", self.editor.buildSerial, client.id, field.key or "spacer"),
                                slotX + (field.x or 0),
                                slotY + (field.offsetY or 0),
                                spacerWidth,
                                field.height or field.rowHeight or 18,
                                field.textureHeight or field.thickness or 2,
                                field.texture,
                                field.color
                            )

                            refData.control = spacer
                            refData.spacer = spacer
                            refData.texture = line

                            if reference then
                                self:_RegisterFieldReference(reference, refData)
                            end


                        elseif field.type == "button" then
                            local slotX, slotY, slotWidth, widthMode = reserveFieldSlot(field)
                            local reference = self:_ResolveFieldReference(field, context, payload, client)
                            local refData = {
                                type = "button",
                                reference = reference,
                                clientId = client.id,
                                fieldKey = field.key,
                                field = field,
                                context = deepCopy(context),
                                providerKey = providerKey,
                            }
                            self:_TrackRuntimeRef(refData)

                            local buttonText = self:_ResolveFieldDisplayText(field.text or field.label or "Button", context, self.editor.values[client.id], client, field, refData)
                            local buttonWidth = slotWidth
                            if type(field.width) == "number" then
                                buttonWidth = field.width
                            end
                            local button = self:_CreateButton(
                                self.editor.body,
                                string.format("LibBSCWizardBridgeButton_%d_%s_%s", self.editor.buildSerial, client.id, field.key or "button"),
                                buttonText,
                                slotX + (field.x or 0),
                                slotY,
                                buttonWidth,
                                field.height or 26,
                                function(...)
                                    if type(field.onClick) == "function" then
                                        pcall(field.onClick, context, LIB.editor.values[client.id], client, refData, ...)
                                    end
                                end,
                                tooltip
                            )

                            refData.control = button
                            refData.button = button

                            if reference then
                                self:_RegisterFieldReference(reference, refData)
                            end

                        end
                    end
                end

                finishHalfRowIfNeeded()
                currentY = currentY + sectionGap
            end
        end
    end)

    self:_RunInitialFieldCallbacks()
    self:UpdateAllDisabledStates()
    self:_RelayoutEditor(currentY)
    self.editor.win:SetHidden(false)
    zo_callLater(function()
        if LIB.editor and LIB.editor.win and not LIB.editor.win:IsHidden() then
            LIB:_RelayoutEditor(LIB.editor.currentContentHeight or currentY)
        end
    end, 0)
end

function LIB:HideEditorForProvider(providerKey)
    if providerKey and self.activeProviderKey == providerKey then
        self:HideEditor()
    end
end

function LIB:HideEditor()
    if self.editor and self.editor.win then
        self.editor.win:SetHidden(true)
    end
    self.activeProviderKey = nil
    self.activeContext = nil
    self.activeOptions = nil
end

function LIB:SaveActiveEditorPayload()
    if not self.activeProviderKey or not self.activeContext then return nil end

    local providerKey = self.activeProviderKey
    local context = deepCopy(self.activeContext)
    local options = self.activeOptions

    self:ForEachClient(providerKey, function(client)
        if self:ClientMatchesContextScope(client, context) and type(client.getEditorFields) == "function" then
            local payload = deepCopy(self.editor.values[client.id] or {})
            if type(client.normalizePayload) == "function" then
                local ok, normalized = pcall(client.normalizePayload, payload, context)
                if ok then payload = normalized end
            end
            if payload == nil or isPayloadEmpty(payload) then
                self:DeletePayload(client.id, providerKey, context)
            else
                self:SetPayload(client.id, providerKey, context, payload)
            end
        end
    end)

    self.callbackManager:FireCallbacks("OnEditorCommit", providerKey, context)
    return providerKey, context, options
end

function LIB:CommitActiveEditor(keepOpen)
    local providerKey, context, options = self:SaveActiveEditorPayload()
    if not providerKey or not context then return end

    if keepOpen then
        self:OpenEditor(providerKey, context, options)
    else
        self:HideEditor()
    end
end

function LIB:ClearActiveEditor(keepOpen)
    if not self.activeProviderKey or not self.activeContext then return end

    local providerKey = self.activeProviderKey
    local context = deepCopy(self.activeContext)
    local options = self.activeOptions

    self:ForEachClient(providerKey, function(client)
        if self:ClientMatchesContextScope(client, context) then
            self:DeletePayload(client.id, providerKey, context)
        end
    end)

    self.callbackManager:FireCallbacks("OnEditorClear", providerKey, context)

    if keepOpen == nil then keepOpen = true end
    if keepOpen then
        self:OpenEditor(providerKey, context, options)
    else
        self:HideEditor()
    end
end
