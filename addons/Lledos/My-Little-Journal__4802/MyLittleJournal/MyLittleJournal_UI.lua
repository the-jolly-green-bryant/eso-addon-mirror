-- My Little Journal — journal window.
--
-- Left page: category tabs, search, and a two-level list (instances, then
-- bosses of the selected instance). Right page: the note editor for the
-- selected boss with char/part counter and send-to-chat controls.

MyLittleJournal = MyLittleJournal or {}
local TJ = MyLittleJournal
local Data = TJ.Data

TJ.UI = {}
local UI = TJ.UI

-- The window is an open book, using the same parchment art and page
-- geometry as the in-game lore reader (loreLibrary_paperBook.dds is a
-- 1024x1024 texture; each page is 375x660, left page 100px from the left
-- edge, right page 95px from the right, both centered 20px above middle).
local WINDOW_WIDTH   = 1024
local WINDOW_HEIGHT  = 740
local PAGE_WIDTH     = 375
local PAGE_HEIGHT    = 660
local PAGE_TOP       = 20
local LEFT_PAGE_X    = 100
local RIGHT_PAGE_X   = 554 -- 1024 - 95 - 375
local ROW_HEIGHT     = 30
local VISIBLE_ROWS   = 16

-- Ink on parchment.
local COLOR_TITLE    = { 0.18, 0.11, 0.06, 1 }    -- heading ink
local COLOR_GOLD     = { 0.45, 0.10, 0.05, 1 }    -- selection: red ink
local COLOR_TEXT     = { 0.20, 0.14, 0.08, 0.95 } -- body ink
local COLOR_DIM      = { 0.42, 0.33, 0.22, 0.9 }  -- faded ink
local COLOR_ACTION   = { 0.16, 0.32, 0.14, 0.95 } -- green ink for "+ Add"

local FONT_TITLE     = "ZoFontBookPaperTitle"
local function proseFont(size) return string.format("$(PROSE_ANTIQUE_FONT)|%d", size) end

local SV

local win
local leftPage, rightPage -- containers holding each page's content
local tabButtons = {}
local searchBox
local rows = {}
local rangeLabel
local breadcrumbLabel, bossTitleLabel
local noteEdit, noteEditBg, noteScroll, noteMeasure, readLabel
local currentNoteText = "" -- note loaded for the selected entry (read-mode revert target)
local countLabel
local channelCombo, channelComboObj
local whisperBox, whisperBg
local sendButton, shareButton, modeButton, hintLine

local inputWin -- small text-input popup for add flows

-- UI state
local selectedCategory = "dungeon"
local listMode = "instances" -- "instances" | "bosses"
local selectedInstanceId = nil
local selectedBossKey = nil
local scrollOffset = 0
local listData = {}
local selectedChannelKey = nil
local suppressNoteSave = false

-- Raw CT_EDITBOX controls have mouse input disabled by default, so clicking
-- them does nothing. Enable the mouse and grab keyboard focus on click; the
-- backdrop behind the box is made clickable too since the edit area is inset.
local function makeFocusable(editControl, backdrop)
    editControl:SetMouseEnabled(true)
    editControl:SetHandler("OnMouseDown", function(self) self:TakeFocus() end)
    if backdrop then
        backdrop:SetMouseEnabled(true)
        backdrop:SetHandler("OnMouseDown", function() editControl:TakeFocus() end)
    end
end

-- =========================
-- Page turning
-- =========================
-- Navigating plays the lore reader's page-turn sound with an instant
-- content swap, exactly like the in-game book reader.
local function turnPage(applyFn)
    PlaySound(SOUNDS.BOOK_PAGE_TURN)
    applyFn()
end

-- Raw edit controls don't reliably support default text, so fake a
-- placeholder with a dim label that hides while typing or focused.
local function addPlaceholder(editControl, text)
    local placeholder = WINDOW_MANAGER:CreateControl(nil, editControl, CT_LABEL)
    placeholder:SetFont(proseFont(18))
    placeholder:SetColor(0.48, 0.40, 0.28, 0.8)
    placeholder:SetAnchor(LEFT, editControl, LEFT, 0, 0)
    placeholder:SetText(text)

    local function refreshPlaceholder()
        local hasText = (editControl:GetText() or "") ~= ""
        placeholder:SetHidden(hasText or editControl:HasFocus())
    end
    ZO_PreHookHandler(editControl, "OnTextChanged", function() zo_callLater(refreshPlaceholder, 0) end)
    editControl:SetHandler("OnFocusGained", refreshPlaceholder)
    ZO_PreHookHandler(editControl, "OnFocusLost", function() zo_callLater(refreshPlaceholder, 0) end)
    refreshPlaceholder()
    return placeholder
end

-- =========================
-- Saved notes helpers
-- =========================
local function getNote(instanceId, bossKey)
    if not (SV and SV.notes and instanceId and bossKey) then return "" end
    local perInstance = SV.notes[instanceId]
    return (perInstance and perInstance[bossKey]) or ""
end

local function setNote(instanceId, bossKey, text)
    if not (SV and instanceId and bossKey) then return end
    if not SV.notes then SV.notes = {} end
    if not SV.notes[instanceId] then SV.notes[instanceId] = {} end
    if text == "" then
        SV.notes[instanceId][bossKey] = nil
    else
        SV.notes[instanceId][bossKey] = text
    end
end

local function hasNote(instanceId, bossKey)
    return getNote(instanceId, bossKey) ~= ""
end

-- =========================
-- Fonts
-- =========================
local function noteFont()
    local size = (SV and tonumber(SV.fontSize)) or 20
    return proseFont(size)
end

-- The note edit box lives inside a ZO_ScrollContainer and is resized to fit
-- its text (measured via a hidden label with the same font/width), so the
-- container provides mouse-wheel scrolling in both edit and read mode.
local function updateNoteHeight()
    if not (noteEdit and noteMeasure and noteScroll) then return end
    local text = noteEdit:GetText() or ""
    noteMeasure:SetText(text ~= "" and text or " ")
    local textHeight = noteMeasure:GetTextHeight() + 40 -- caret/new-line breathing room
    noteEdit:SetHeight(math.max(textHeight, noteScroll:GetHeight(), 100))
end

function UI.RefreshFonts()
    if noteEdit then noteEdit:SetFont(noteFont()) end
    if noteMeasure then noteMeasure:SetFont(noteFont()) end
    if readLabel then readLabel:SetFont(noteFont()) end
    updateNoteHeight()
end

-- =========================
-- Selection helpers
-- =========================
local function currentInstance()
    return selectedInstanceId and Data.GetInstance(SV, selectedInstanceId) or nil
end

local function currentBossEntry()
    if not (selectedInstanceId and selectedBossKey) then return nil end
    for _, entry in ipairs(Data.GetBossEntries(SV, selectedInstanceId)) do
        if entry.key == selectedBossKey then return entry end
    end
    return nil
end

-- Boss name used in the chat prefix; Overview sends under the instance name.
local function prefixBossName()
    local entry = currentBossEntry()
    if not entry or entry.key == Data.OVERVIEW_KEY then return nil end
    return entry.name
end

-- =========================
-- Right page refresh
-- =========================
local function refreshCountLabel()
    if not countLabel then return end
    local inst = currentInstance()
    if not (inst and selectedBossKey) then
        countLabel:SetText("")
        return
    end
    local text = noteEdit:GetText() or ""
    local chars = #text
    if chars == 0 then
        countLabel:SetText("|c6B5A42No notes yet — write your tactics above.|r")
        return
    end
    local prefixFn = TJ.BuildPrefixFn(inst.name, prefixBossName())
    local parts = TJ.Chat.CountParts(prefixFn, text)
    local partWord = (parts == 1) and "1 chat message" or (parts .. " chat messages")
    countLabel:SetText(string.format("|c6B5A42%d characters — sends as %s|r", chars, partWord))
end

-- Read mode keeps the same edit box (identical wrapping, and text stays
-- selectable for copying) but hides the frame and reverts any modification.
local function applyReadMode()
    local reading = SV and SV.readMode == true
    if noteEditBg then
        noteEditBg:SetHidden(reading)
    end
    if noteEdit and reading then
        noteEdit:LoseFocus()
    end
    if readLabel then
        local empty = not noteEdit or (noteEdit:GetText() or "") == ""
        readLabel:SetHidden(not (reading and empty))
    end
    if modeButton then
        modeButton:SetText(reading and "Edit Notes" or "Reading Mode")
    end
end

local function refreshRightPage()
    local inst = currentInstance()

    if not inst then
        breadcrumbLabel:SetText(Data.GetCategoryName(selectedCategory))
        bossTitleLabel:SetText("|c6B5A42Pick a place from the left page.|r")
        currentNoteText = ""
        suppressNoteSave = true
        noteEdit:SetText("")
        suppressNoteSave = false
        updateNoteHeight()
        readLabel:SetHidden(true)
        countLabel:SetText("")
        sendButton:SetHidden(true)
        shareButton:SetHidden(true)
        modeButton:SetHidden(true)
        return
    end

    sendButton:SetHidden(false)
    shareButton:SetHidden(false)
    modeButton:SetHidden(false)

    breadcrumbLabel:SetText(string.format("%s  »  %s", Data.GetCategoryName(inst.category), inst.name))

    local entry = currentBossEntry()
    bossTitleLabel:SetText(entry and entry.name or "")

    local text = (entry and getNote(selectedInstanceId, entry.key)) or ""
    currentNoteText = text
    suppressNoteSave = true
    noteEdit:SetText(text)
    suppressNoteSave = false
    updateNoteHeight()
    ZO_Scroll_ResetToTop(noteScroll)

    applyReadMode()
    refreshCountLabel()
end

-- =========================
-- Left page list
-- =========================
local function matchesSearch(name)
    local needle = zo_strlower(zo_strtrim(searchBox and searchBox:GetText() or ""))
    if needle == "" then return true end
    return zo_strlower(name):find(needle, 1, true) ~= nil
end

local function buildListData()
    listData = {}
    if listMode == "instances" then
        for _, inst in ipairs(Data.GetInstanceList(SV, selectedCategory)) do
            if matchesSearch(inst.name) then
                listData[#listData + 1] = { type = "instance", id = inst.id, name = inst.name, custom = inst.custom, auto = inst.auto }
            end
        end
        listData[#listData + 1] = { type = "addinstance", name = "+ Add custom entry..." }
    else
        listData[#listData + 1] = { type = "back", name = "« Back to " .. Data.GetCategoryName(selectedCategory) }
        for _, entry in ipairs(Data.GetBossEntries(SV, selectedInstanceId)) do
            if matchesSearch(entry.name) then
                listData[#listData + 1] = { type = "boss", key = entry.key, name = entry.name, custom = entry.custom, auto = entry.auto }
            end
        end
        listData[#listData + 1] = { type = "addboss", name = "+ Add boss entry..." }
    end
end

local function maxScrollOffset()
    return math.max(0, #listData - VISIBLE_ROWS)
end

local function rowDisplayText(item)
    -- Auto-discovered entries (from the Activity Finder or boss encounters)
    -- are shown untagged, like shipped catalog entries.
    if item.type == "instance" then
        local text = item.name
        if item.custom and not item.auto then text = text .. " |c8A7A5A(custom)|r" end
        return text
    elseif item.type == "boss" then
        local marker = hasNote(selectedInstanceId, item.key) and "|c2E5A22•|r " or "|cBCA987•|r "
        local text = marker .. item.name
        if item.custom and not item.auto then text = text .. " |c8A7A5A(custom)|r" end
        return "  " .. text
    end
    return item.name
end

local function rowIsSelected(item)
    if item.type == "instance" then
        return listMode == "instances" and item.id == selectedInstanceId
    elseif item.type == "boss" then
        return item.key == selectedBossKey
    end
    return false
end

local forwardDeclaredRefreshList

local function onRowClicked(item)
    if not item then return end
    if item.type == "addinstance" then
        UI.PromptAddInstance()
        return
    elseif item.type == "addboss" then
        UI.PromptAddBoss()
        return
    end
    turnPage(function()
        if item.type == "instance" then
            selectedInstanceId = item.id
            selectedBossKey = Data.OVERVIEW_KEY
            listMode = "bosses"
            scrollOffset = 0
            searchBox:SetText("")
        elseif item.type == "boss" then
            selectedBossKey = item.key
        elseif item.type == "back" then
            listMode = "instances"
            scrollOffset = 0
            searchBox:SetText("")
        end
        forwardDeclaredRefreshList()
        refreshRightPage()
    end)
end

-- Right-click delete for custom entries
local function onRowRightClicked(item)
    if not item or not item.custom then return end
    ClearMenu()
    if item.type == "instance" then
        AddMenuItem("Delete \"" .. item.name .. "\"", function()
            UI.ConfirmDeleteCustomInstance(item.id, item.name)
        end)
    elseif item.type == "boss" then
        AddMenuItem("Delete \"" .. item.name .. "\"", function()
            UI.ConfirmDeleteCustomBoss(selectedInstanceId, item.key, item.name)
        end)
    end
    ShowMenu()
end

local function refreshList()
    buildListData()
    scrollOffset = math.min(scrollOffset, maxScrollOffset())

    for i = 1, VISIBLE_ROWS do
        local row = rows[i]
        local item = listData[scrollOffset + i]
        row.item = item
        if item then
            row:SetHidden(false)
            row.label:SetText(rowDisplayText(item))

            if rowIsSelected(item) then
                row.label:SetColor(unpack(COLOR_GOLD))
                row.selectBg:SetHidden(false)
            else
                row.selectBg:SetHidden(true)
                if item.type == "addinstance" or item.type == "addboss" then
                    row.label:SetColor(unpack(COLOR_ACTION))
                elseif item.type == "back" then
                    row.label:SetColor(unpack(COLOR_DIM))
                else
                    row.label:SetColor(unpack(COLOR_TEXT))
                end
            end
        else
            row:SetHidden(true)
        end
    end

    if #listData > VISIBLE_ROWS then
        rangeLabel:SetText(string.format("%d–%d of %d (mouse wheel to scroll)",
            scrollOffset + 1, math.min(scrollOffset + VISIBLE_ROWS, #listData), #listData))
    else
        rangeLabel:SetText("")
    end
end
forwardDeclaredRefreshList = refreshList

-- =========================
-- Drag-to-reorder bosses
-- =========================
-- Hold left mouse on a boss row and drag it to a new spot. A small movement
-- threshold distinguishes a drag from an ordinary click. The resulting order
-- is stored per instance in SV.bossOrder as an array of boss keys.
local listAreaCtrl -- assigned in createWindow
local dragState
local DRAG_THRESHOLD_PX = 6

local function dragTargetIndex()
    local _, mouseY = GetUIMousePosition()
    local rowIdx = math.floor((mouseY - listAreaCtrl:GetTop()) / ROW_HEIGHT) + 1
    rowIdx = math.max(1, math.min(VISIBLE_ROWS, rowIdx))
    return math.min(scrollOffset + rowIdx, #listData)
end

local function endDrag()
    dragState = nil
    if listAreaCtrl then listAreaCtrl:SetHandler("OnUpdate", nil) end
    for i = 1, VISIBLE_ROWS do rows[i].hoverBg:SetHidden(true) end
end

local function startDrag(item, listIndex)
    local mouseX, mouseY = GetUIMousePosition()
    dragState = { key = item.key, fromIndex = listIndex, startX = mouseX, startY = mouseY, moved = false }
    listAreaCtrl:SetHandler("OnUpdate", function()
        if not dragState then return end
        if not dragState.moved then
            local x, y = GetUIMousePosition()
            if math.abs(x - dragState.startX) + math.abs(y - dragState.startY) >= DRAG_THRESHOLD_PX then
                dragState.moved = true
            end
        end
        if dragState.moved then
            local target = dragTargetIndex()
            for i = 1, VISIBLE_ROWS do
                rows[i].hoverBg:SetHidden(scrollOffset + i ~= target)
            end
        end
    end)
end

local function dropDraggedBoss()
    local draggedKey = dragState.key
    local fromIndex = dragState.fromIndex
    local targetIndex = dragTargetIndex()
    endDrag()
    if targetIndex == fromIndex then
        refreshList()
        return
    end

    -- Rebuild the full boss order (Overview excluded) with the dragged key
    -- moved next to the drop target. Works with an active search filter too,
    -- since positions come from keys rather than visible row indices.
    local orderKeys = {}
    for _, entry in ipairs(Data.GetBossEntries(SV, selectedInstanceId)) do
        if entry.key ~= Data.OVERVIEW_KEY then orderKeys[#orderKeys + 1] = entry.key end
    end
    for i, key in ipairs(orderKeys) do
        if key == draggedKey then table.remove(orderKeys, i) break end
    end

    local targetItem = listData[targetIndex]
    local insertPos
    if targetItem and targetItem.type == "boss" and targetItem.key ~= Data.OVERVIEW_KEY and targetItem.key ~= draggedKey then
        for i, key in ipairs(orderKeys) do
            if key == targetItem.key then insertPos = i break end
        end
        -- Dragging downward lands below the target row, upward lands above.
        if insertPos and targetIndex > fromIndex then insertPos = insertPos + 1 end
    end
    if not insertPos then
        -- Dropped above the first boss (Overview/back row) or below the last
        -- one ("+ Add boss" row).
        insertPos = (targetIndex < fromIndex) and 1 or (#orderKeys + 1)
    end
    table.insert(orderKeys, insertPos, draggedKey)

    SV.bossOrder = SV.bossOrder or {}
    SV.bossOrder[selectedInstanceId] = orderKeys
    PlaySound(SOUNDS.BOOK_PAGE_TURN)
    refreshList()
end

local function onListWheel(delta)
    scrollOffset = math.max(0, math.min(maxScrollOffset(), scrollOffset - delta * 3))
    refreshList()
end

local function updateTabHighlight()
    for key, button in pairs(tabButtons) do
        if key == selectedCategory then
            button.label:SetColor(unpack(COLOR_GOLD))
            button.underline:SetHidden(false)
        else
            button.label:SetColor(unpack(COLOR_DIM))
            button.underline:SetHidden(true)
        end
    end
end

local function selectCategory(categoryKey)
    selectedCategory = categoryKey
    listMode = "instances"
    scrollOffset = 0
    updateTabHighlight()
    refreshList()
    refreshRightPage()
end

-- If the player is standing inside a dungeon/trial/arena the journal knows,
-- jump straight to that instance's boss list when the window opens.
local function autoSelectCurrentLocation()
    local Discovery = TJ.Discovery
    if not (Discovery and Discovery.GetCurrentInstanceId) then return end

    local instanceId = Discovery.GetCurrentInstanceId()
    if not instanceId then return end
    if instanceId == selectedInstanceId and listMode == "bosses" then return end

    local inst = Data.GetInstance(SV, instanceId)
    if not inst then return end

    selectedCategory = inst.category or selectedCategory
    selectedInstanceId = instanceId
    selectedBossKey = Data.OVERVIEW_KEY
    listMode = "bosses"
    scrollOffset = 0
    if searchBox then searchBox:SetText("") end
    updateTabHighlight()
end

-- =========================
-- Add / delete custom entries
-- =========================
local function ensureInputPopup()
    if inputWin then return end

    inputWin = WINDOW_MANAGER:CreateControl("MyLittleJournalInput", GuiRoot, CT_TOPLEVELCONTROL)
    inputWin:SetDimensions(430, 150)
    inputWin:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
    inputWin:SetDrawLayer(DL_OVERLAY)
    inputWin:SetDrawTier(DT_HIGH)
    inputWin:SetDrawLevel(10)
    inputWin:SetMouseEnabled(true)
    inputWin:SetMovable(true)
    inputWin:SetClampedToScreen(true)
    inputWin:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl(nil, inputWin, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.06, 0.05, 0.03, 0.97)
    bg:SetEdgeColor(0.55, 0.45, 0.25, 1)
    bg:SetEdgeTexture("", 128, 2)

    -- The popup keeps a dark backdrop, so it needs light text (the shared
    -- COLOR_* constants are dark ink for the parchment window).
    inputWin.title = WINDOW_MANAGER:CreateControl(nil, inputWin, CT_LABEL)
    inputWin.title:SetFont("ZoFontWinH3")
    inputWin.title:SetColor(0.93, 0.82, 0.56, 1)
    inputWin.title:SetAnchor(TOPLEFT, inputWin, TOPLEFT, 16, 12)
    inputWin.title:SetAnchor(TOPRIGHT, inputWin, TOPRIGHT, -16, 12)
    inputWin.title:SetHeight(32)
    inputWin.title:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    inputWin.title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    local editBg = WINDOW_MANAGER:CreateControl(nil, inputWin, CT_BACKDROP)
    editBg:SetAnchor(TOPLEFT, inputWin, TOPLEFT, 16, 52)
    editBg:SetAnchor(TOPRIGHT, inputWin, TOPRIGHT, -16, 52)
    editBg:SetHeight(30)
    editBg:SetCenterColor(0.10, 0.09, 0.06, 1)
    editBg:SetEdgeColor(0.4, 0.35, 0.22, 1)
    editBg:SetEdgeTexture("", 128, 1)

    inputWin.edit = WINDOW_MANAGER:CreateControl(nil, inputWin, CT_EDITBOX)
    inputWin.edit:SetAnchor(TOPLEFT, editBg, TOPLEFT, 8, 5)
    inputWin.edit:SetAnchor(BOTTOMRIGHT, editBg, BOTTOMRIGHT, -8, -5)
    inputWin.edit:SetFont("ZoFontGame")
    inputWin.edit:SetColor(0.92, 0.90, 0.85, 1)
    inputWin.edit:SetMaxInputChars(80)
    inputWin.edit:SetHandler("OnEscape", function() inputWin:SetHidden(true) end)
    inputWin.edit:SetHandler("OnEnter", function()
        if inputWin.onAccept then inputWin.onAccept() end
    end)
    makeFocusable(inputWin.edit, editBg)

    local okButton = WINDOW_MANAGER:CreateControlFromVirtual("MyLittleJournalInputOK", inputWin, "ZO_DefaultButton")
    okButton:SetWidth(140)
    okButton:SetAnchor(BOTTOMLEFT, inputWin, BOTTOMLEFT, 40, -12)
    okButton:SetText("Add")
    okButton:SetHandler("OnClicked", function()
        if inputWin.onAccept then inputWin.onAccept() end
    end)

    local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual("MyLittleJournalInputCancel", inputWin, "ZO_DefaultButton")
    cancelButton:SetWidth(140)
    cancelButton:SetAnchor(BOTTOMRIGHT, inputWin, BOTTOMRIGHT, -40, -12)
    cancelButton:SetText("Cancel")
    cancelButton:SetHandler("OnClicked", function() inputWin:SetHidden(true) end)
end

local function showInputPopup(title, acceptFn)
    ensureInputPopup()
    inputWin.title:SetText(title)
    inputWin.edit:SetText("")
    inputWin.onAccept = function()
        local text = zo_strtrim(inputWin.edit:GetText() or "")
        if text == "" then return end
        inputWin:SetHidden(true)
        acceptFn(text)
    end
    inputWin:SetHidden(false)
    inputWin.edit:TakeFocus()
end

function UI.PromptAddInstance()
    local categoryName = Data.GetCategoryName(selectedCategory)
    showInputPopup("Add to " .. categoryName, function(name)
        if not SV.customInstances then SV.customInstances = {} end
        local id = "ci_" .. GetTimeStamp() .. "_" .. math.random(1000, 9999)
        table.insert(SV.customInstances, { id = id, name = name, category = selectedCategory })
        selectedInstanceId = id
        selectedBossKey = Data.OVERVIEW_KEY
        listMode = "bosses"
        scrollOffset = 0
        refreshList()
        refreshRightPage()
    end)
end

function UI.PromptAddBoss()
    if not selectedInstanceId then return end
    local inst = currentInstance()
    showInputPopup("Add boss to " .. (inst and inst.name or "instance"), function(name)
        if not SV.customBosses then SV.customBosses = {} end
        if not SV.customBosses[selectedInstanceId] then SV.customBosses[selectedInstanceId] = {} end
        local key = "cb_" .. GetTimeStamp() .. "_" .. math.random(1000, 9999)
        table.insert(SV.customBosses[selectedInstanceId], { key = key, name = name })
        selectedBossKey = key
        refreshList()
        refreshRightPage()
    end)
end

local function registerConfirmDialog()
    if ESO_Dialogs["MLJ_CONFIRM_DELETE"] then return end
    ESO_Dialogs["MLJ_CONFIRM_DELETE"] = {
        canQueue = true,
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
        title = { text = "Delete journal entry?" },
        mainText = { text = "This deletes <<1>> and any notes written for it. This cannot be undone." },
        buttons = {
            {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    local cb = dialog.data and dialog.data.onConfirm
                    if cb then cb() end
                end,
            },
            { text = SI_DIALOG_CANCEL },
        },
    }
end

local function showConfirmDelete(displayName, onConfirm)
    registerConfirmDialog()
    ZO_Dialogs_ShowPlatformDialog("MLJ_CONFIRM_DELETE", { onConfirm = onConfirm }, { mainTextParams = { displayName } })
end

function UI.ConfirmDeleteCustomInstance(instanceId, displayName)
    showConfirmDelete(displayName, function()
        if SV.customInstances then
            for i, inst in ipairs(SV.customInstances) do
                if inst.id == instanceId then
                    table.remove(SV.customInstances, i)
                    break
                end
            end
        end
        if SV.notes then SV.notes[instanceId] = nil end
        if SV.customBosses then SV.customBosses[instanceId] = nil end
        if SV.bossOrder then SV.bossOrder[instanceId] = nil end
        if selectedInstanceId == instanceId then
            selectedInstanceId = nil
            selectedBossKey = nil
            listMode = "instances"
        end
        refreshList()
        refreshRightPage()
    end)
end

function UI.ConfirmDeleteCustomBoss(instanceId, bossKey, displayName)
    showConfirmDelete(displayName, function()
        local list = SV.customBosses and SV.customBosses[instanceId]
        if list then
            for i, boss in ipairs(list) do
                if boss.key == bossKey then
                    table.remove(list, i)
                    break
                end
            end
        end
        if SV.notes and SV.notes[instanceId] then
            SV.notes[instanceId][bossKey] = nil
        end
        if selectedBossKey == bossKey then
            selectedBossKey = Data.OVERVIEW_KEY
        end
        refreshList()
        refreshRightPage()
    end)
end

-- =========================
-- Send to chat
-- =========================
local function onSendClicked()
    local inst = currentInstance()
    if not (inst and selectedBossKey) then return end

    local choice = TJ.Chat.FindChannelChoice(selectedChannelKey or (SV and SV.defaultChannel) or "party")
    local prefixFn = TJ.BuildPrefixFn(inst.name, prefixBossName())
    local ok, err = TJ.Chat.SendNote(prefixFn, noteEdit:GetText(), choice, whisperBox:GetText())
    if not ok and err then
        d("|c88CCFF[Journal]|r |cFF6666" .. err .. "|r")
    end
end

local function shareFeedback(ok, err)
    if not ok and err then
        d("|c88CCFF[Journal]|r |cFF6666" .. err .. "|r")
    end
end

local function onShareClicked()
    local inst = currentInstance()
    if not (inst and selectedBossKey) then return end
    local entry = currentBossEntry()

    ClearMenu()

    -- Group broadcast: silent, no chat messages, any size. Always listed so
    -- the options are discoverable; clicking while unavailable explains why
    -- (not grouped / LibGroupBroadcast missing).
    AddMenuItem("Send this page to group (silent)", function()
        shareFeedback(TJ.Share.SendToGroup(inst, {
            { name = entry and entry.name or nil, note = noteEdit:GetText() },
        }))
    end)
    AddMenuItem(string.format("Send ALL notes for %s to group (silent)", inst.name), function()
        shareFeedback(TJ.Share.SendInstanceToGroup(inst))
    end)

    AddMenuItem("Send this page as chat links", function()
        local choice = TJ.Chat.FindChannelChoice(selectedChannelKey or (SV and SV.defaultChannel) or "party")
        shareFeedback(TJ.Share.Send(inst, entry and entry.name or nil, noteEdit:GetText(), choice, whisperBox:GetText()))
    end)

    ShowMenu(shareButton)
end

local function refreshWhisperVisibility()
    local choice = TJ.Chat.FindChannelChoice(selectedChannelKey or (SV and SV.defaultChannel) or "party")
    local showWhisper = choice and choice.isWhisper == true
    whisperBox:SetHidden(not showWhisper)
    whisperBg:SetHidden(not showWhisper)
end

local function populateChannelDropdown()
    if not channelComboObj then return end
    channelComboObj:ClearItems()

    local wantedKey = selectedChannelKey or (SV and SV.defaultChannel) or "party"
    local selectedEntry, firstEntry, firstKey
    for _, choice in ipairs(TJ.Chat.GetChannelChoices()) do
        local entry = channelComboObj:CreateItemEntry(choice.label, function()
            selectedChannelKey = choice.key
            refreshWhisperVisibility()
        end)
        channelComboObj:AddItem(entry)
        if not firstEntry then
            firstEntry, firstKey = entry, choice.key
        end
        if choice.key == wantedKey then
            selectedEntry = entry
            selectedChannelKey = choice.key
        end
    end
    if not selectedEntry then
        selectedEntry = firstEntry
        selectedChannelKey = firstKey
    end
    if selectedEntry then
        channelComboObj:SelectItem(selectedEntry, true)
    end
    refreshWhisperVisibility()
end

-- =========================
-- Window construction
-- =========================
local function savePosition()
    if not (SV and win) then return end
    SV.winLeft = win:GetLeft()
    SV.winTop = win:GetTop()
end

local function applyPosition()
    win:ClearAnchors()
    local left = SV and tonumber(SV.winLeft)
    local top = SV and tonumber(SV.winTop)
    if left and top then
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        win:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
    end
end

local function createWindow()
    if win then return end

    win = WINDOW_MANAGER:CreateControl("MyLittleJournalWindow", GuiRoot, CT_TOPLEVELCONTROL)
    win:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win:SetHandler("OnMoveStop", savePosition)

    -- Open-book parchment, the same art the in-game lore reader uses.
    local bookBg = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
    bookBg:SetTexture("/esoui/art/lorelibrary/lorelibrary_paperbook.dds")
    bookBg:SetDimensions(1024, 1024)
    bookBg:SetAnchor(CENTER, win, CENTER, 0, 0)
    bookBg:SetDrawLayer(DL_BACKGROUND)

    -- The close X sits on the parchment itself (the book cover art to the
    -- right of the page hid it). The visual is a texture so it can be
    -- tinted ink-dark for the light paper; a plain invisible button on top
    -- takes the clicks, raised above everything else on the page.
    local closeIcon = WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
    closeIcon:SetDimensions(26, 26)
    closeIcon:SetAnchor(TOPRIGHT, win, TOPLEFT, RIGHT_PAGE_X + PAGE_WIDTH + 8, PAGE_TOP + 4)
    closeIcon:SetTexture("/esoui/art/buttons/closebutton_up.dds")
    closeIcon:SetColor(0.20, 0.12, 0.07, 0.9)
    closeIcon:SetDrawLevel(20)

    local closeButton = WINDOW_MANAGER:CreateControl(nil, win, CT_BUTTON)
    closeButton:SetDimensions(34, 34) -- a bit larger than the icon: easier to hit
    closeButton:SetAnchor(CENTER, closeIcon, CENTER, 0, 0)
    closeButton:SetDrawLevel(21)
    closeButton:SetHandler("OnMouseEnter", function() closeIcon:SetColor(0.55, 0.10, 0.05, 1) end)
    closeButton:SetHandler("OnMouseExit", function() closeIcon:SetColor(0.20, 0.12, 0.07, 0.9) end)
    closeButton:SetHandler("OnClicked", function() UI.Hide() end)

    -- Page containers: everything on a page lives inside one of these so a
    -- page turn can fade the whole page at once.
    leftPage = WINDOW_MANAGER:CreateControl(nil, win, CT_CONTROL)
    leftPage:SetAnchor(TOPLEFT, win, TOPLEFT, LEFT_PAGE_X, PAGE_TOP)
    leftPage:SetDimensions(PAGE_WIDTH, PAGE_HEIGHT)

    rightPage = WINDOW_MANAGER:CreateControl(nil, win, CT_CONTROL)
    rightPage:SetAnchor(TOPLEFT, win, TOPLEFT, RIGHT_PAGE_X, PAGE_TOP)
    rightPage:SetDimensions(PAGE_WIDTH, PAGE_HEIGHT)

    -- ===== Left page =====
    local title = WINDOW_MANAGER:CreateControl(nil, leftPage, CT_LABEL)
    title:SetFont(FONT_TITLE)
    title:SetColor(unpack(COLOR_TITLE))
    title:SetAnchor(TOP, leftPage, TOP, 0, 6)
    title:SetText("My Little Journal")

    local tabWidth = math.floor(PAGE_WIDTH / #Data.CATEGORIES)
    local tabX = 0
    for _, cat in ipairs(Data.CATEGORIES) do
        local tab = WINDOW_MANAGER:CreateControl(nil, leftPage, CT_CONTROL)
        tab:SetDimensions(tabWidth, 30)
        tab:SetAnchor(TOPLEFT, leftPage, TOPLEFT, tabX, 58)
        tab:SetMouseEnabled(true)

        tab.label = WINDOW_MANAGER:CreateControl(nil, tab, CT_LABEL)
        tab.label:SetFont(proseFont(22))
        tab.label:SetAnchor(CENTER, tab, CENTER, 0, 0)
        tab.label:SetText(cat.name)
        tab.label:SetColor(unpack(COLOR_DIM))

        tab.underline = WINDOW_MANAGER:CreateControl(nil, tab, CT_TEXTURE)
        tab.underline:SetTexture("/esoui/art/miscellaneous/horizontaldivider.dds")
        tab.underline:SetColor(unpack(COLOR_GOLD))
        tab.underline:SetAnchor(BOTTOMLEFT, tab, BOTTOMLEFT, 14, 2)
        tab.underline:SetAnchor(BOTTOMRIGHT, tab, BOTTOMRIGHT, -14, 2)
        tab.underline:SetHeight(3)
        tab.underline:SetHidden(true)

        tab:SetHandler("OnMouseUp", function(_, button, upInside)
            if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
                if cat.key == selectedCategory and listMode == "instances" then return end
                turnPage(function()
                    searchBox:SetText("")
                    selectCategory(cat.key)
                end)
            end
        end)

        tabButtons[cat.key] = tab
        tabX = tabX + tabWidth
    end

    -- Search box: a faint ruled field on the parchment
    local searchBg = WINDOW_MANAGER:CreateControl(nil, leftPage, CT_BACKDROP)
    searchBg:SetAnchor(TOPLEFT, leftPage, TOPLEFT, 4, 96)
    searchBg:SetDimensions(PAGE_WIDTH - 8, 28)
    searchBg:SetCenterColor(0.30, 0.22, 0.12, 0.07)
    searchBg:SetEdgeColor(0.38, 0.28, 0.16, 0.45)
    searchBg:SetEdgeTexture("", 128, 1)

    searchBox = WINDOW_MANAGER:CreateControl(nil, leftPage, CT_EDITBOX)
    searchBox:SetAnchor(TOPLEFT, searchBg, TOPLEFT, 8, 5)
    searchBox:SetAnchor(BOTTOMRIGHT, searchBg, BOTTOMRIGHT, -8, -5)
    searchBox:SetFont(proseFont(18))
    searchBox:SetColor(unpack(COLOR_TEXT))
    searchBox:SetMaxInputChars(40)
    searchBox:SetHandler("OnEscape", function(box) box:SetText("") box:LoseFocus() end)
    searchBox:SetHandler("OnTextChanged", function()
        scrollOffset = 0
        refreshList()
    end)
    makeFocusable(searchBox, searchBg)
    addPlaceholder(searchBox, "Search...")

    -- List rows
    local listArea = WINDOW_MANAGER:CreateControl(nil, leftPage, CT_CONTROL)
    listArea:SetAnchor(TOPLEFT, leftPage, TOPLEFT, 0, 134)
    listArea:SetDimensions(PAGE_WIDTH, VISIBLE_ROWS * ROW_HEIGHT)
    listArea:SetMouseEnabled(true)
    listArea:SetHandler("OnMouseWheel", function(_, delta) onListWheel(delta) end)
    listAreaCtrl = listArea

    for i = 1, VISIBLE_ROWS do
        local row = WINDOW_MANAGER:CreateControl(nil, listArea, CT_CONTROL)
        row:SetDimensions(PAGE_WIDTH, ROW_HEIGHT)
        row:SetAnchor(TOPLEFT, listArea, TOPLEFT, 0, (i - 1) * ROW_HEIGHT)
        row:SetMouseEnabled(true)

        row.selectBg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        row.selectBg:SetAnchorFill()
        row.selectBg:SetCenterColor(0.45, 0.15, 0.08, 0.13)
        row.selectBg:SetEdgeColor(0, 0, 0, 0)
        row.selectBg:SetEdgeTexture("", 128, 1)
        row.selectBg:SetHidden(true)

        row.hoverBg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        row.hoverBg:SetAnchorFill()
        row.hoverBg:SetCenterColor(0.30, 0.20, 0.10, 0.09)
        row.hoverBg:SetEdgeColor(0, 0, 0, 0)
        row.hoverBg:SetEdgeTexture("", 128, 1)
        row.hoverBg:SetHidden(true)

        -- Fill the row (fixed height) so ellipsis truncation kicks in
        -- instead of wrapping onto the row below.
        row.label = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
        row.label:SetFont(proseFont(20))
        row.label:SetAnchor(TOPLEFT, row, TOPLEFT, 6, 0)
        row.label:SetAnchor(BOTTOMRIGHT, row, BOTTOMRIGHT, -6, 0)
        row.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        row.label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

        row:SetHandler("OnMouseEnter", function() row.hoverBg:SetHidden(false) end)
        row:SetHandler("OnMouseExit", function()
            if not (dragState and dragState.moved) then row.hoverBg:SetHidden(true) end
        end)
        row:SetHandler("OnMouseWheel", function(_, delta) onListWheel(delta) end)
        row:SetHandler("OnMouseDown", function(_, button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            local item = row.item
            -- Only boss rows reorder; Overview stays pinned at the top.
            if listMode == "bosses" and item and item.type == "boss" and item.key ~= Data.OVERVIEW_KEY then
                startDrag(item, scrollOffset + i)
            end
        end)
        row:SetHandler("OnMouseUp", function(_, button, upInside)
            if button == MOUSE_BUTTON_INDEX_LEFT and dragState then
                if dragState.moved then
                    dropDraggedBoss()
                    return
                end
                endDrag()
            end
            if not upInside then return end
            if button == MOUSE_BUTTON_INDEX_LEFT then
                onRowClicked(row.item)
            elseif button == MOUSE_BUTTON_INDEX_RIGHT then
                onRowRightClicked(row.item)
            end
        end)

        rows[i] = row
    end

    rangeLabel = WINDOW_MANAGER:CreateControl(nil, leftPage, CT_LABEL)
    rangeLabel:SetFont(proseFont(14))
    rangeLabel:SetColor(unpack(COLOR_DIM))
    rangeLabel:SetAnchor(TOPLEFT, listArea, BOTTOMLEFT, 6, 4)
    rangeLabel:SetDimensions(PAGE_WIDTH - 12, 18)
    rangeLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    rangeLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    -- ===== Right page =====
    -- Labels get fixed dimensions: an unconstrained-height label wraps onto
    -- extra lines and overlaps the controls anchored below it.
    breadcrumbLabel = WINDOW_MANAGER:CreateControl(nil, rightPage, CT_LABEL)
    breadcrumbLabel:SetFont(proseFont(16))
    breadcrumbLabel:SetColor(unpack(COLOR_DIM))
    breadcrumbLabel:SetAnchor(TOPLEFT, rightPage, TOPLEFT, 0, 8)
    breadcrumbLabel:SetDimensions(PAGE_WIDTH, 20)
    breadcrumbLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    breadcrumbLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    bossTitleLabel = WINDOW_MANAGER:CreateControl(nil, rightPage, CT_LABEL)
    bossTitleLabel:SetFont(FONT_TITLE)
    bossTitleLabel:SetColor(unpack(COLOR_TITLE))
    bossTitleLabel:SetAnchor(TOPLEFT, rightPage, TOPLEFT, 0, 30)
    bossTitleLabel:SetDimensions(PAGE_WIDTH, 46)
    bossTitleLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    bossTitleLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    bossTitleLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)

    -- Note editor: nearly invisible on the page, just a whisper of an edge
    noteEditBg = WINDOW_MANAGER:CreateControl(nil, rightPage, CT_BACKDROP)
    noteEditBg:SetAnchor(TOPLEFT, rightPage, TOPLEFT, 0, 78)
    noteEditBg:SetAnchor(BOTTOMRIGHT, rightPage, BOTTOMRIGHT, 0, -152)
    noteEditBg:SetCenterColor(0.30, 0.20, 0.10, 0.05)
    noteEditBg:SetEdgeColor(0.38, 0.28, 0.16, 0.30)
    noteEditBg:SetEdgeTexture("", 128, 1)

    -- Scroll container makes the note area mouse-wheel scrollable; the edit
    -- box inside it is resized to fit its text (see updateNoteHeight).
    -- Generous padding keeps the text away from the edges, giving the mouse
    -- room to start/end drag selections precisely.
    local NOTE_PAD_X, NOTE_PAD_Y = 16, 12
    noteScroll = WINDOW_MANAGER:CreateControlFromVirtual("MyLittleJournalNoteScroll", rightPage, "ZO_ScrollContainer")
    noteScroll:SetAnchor(TOPLEFT, noteEditBg, TOPLEFT, NOTE_PAD_X, NOTE_PAD_Y)
    noteScroll:SetAnchor(BOTTOMRIGHT, noteEditBg, BOTTOMRIGHT, -NOTE_PAD_X, -NOTE_PAD_Y)
    local noteScrollChild = noteScroll:GetNamedChild("ScrollChild")

    local NOTE_TEXT_WIDTH = PAGE_WIDTH - (NOTE_PAD_X * 2) - 20 -- padding + scrollbar clearance

    noteEdit = WINDOW_MANAGER:CreateControl(nil, noteScrollChild, CT_EDITBOX)
    noteEdit:SetAnchor(TOPLEFT, noteScrollChild, TOPLEFT, 0, 0)
    noteEdit:SetWidth(NOTE_TEXT_WIDTH)
    noteEdit:SetHeight(100)
    if noteEdit.SetMultiLine then noteEdit:SetMultiLine(true) end
    if noteEdit.SetNewLineEnabled then noteEdit:SetNewLineEnabled(true) end
    noteEdit:SetMaxInputChars(4000)
    noteEdit:SetFont(noteFont())
    noteEdit:SetColor(unpack(COLOR_TEXT))
    noteEdit:SetHandler("OnEscape", function(box) box:LoseFocus() end)
    noteEdit:SetHandler("OnMouseWheel", function(_, delta)
        ZO_Scroll_OnMouseWheel(noteScroll, delta)
    end)
    noteEdit:SetHandler("OnTextChanged", function(box)
        if suppressNoteSave then return end

        -- Read mode: the box is kept for identical wrapping and text
        -- selection, but any modification is reverted.
        if SV and SV.readMode then
            suppressNoteSave = true
            box:SetText(currentNoteText or "")
            suppressNoteSave = false
            updateNoteHeight()
            return
        end

        local entry = currentBossEntry()
        if entry and selectedInstanceId then
            currentNoteText = box:GetText() or ""
            setNote(selectedInstanceId, entry.key, currentNoteText)
        end
        updateNoteHeight()

        -- Typing at the end of a long note: keep the caret in view.
        local text = box:GetText() or ""
        local cursor = box.GetCursorPosition and box:GetCursorPosition()
        if box:HasFocus() and cursor and cursor >= #text and noteScroll.scroll then
            local _, extents = noteScroll.scroll:GetScrollExtents()
            if extents and extents > 0 then
                ZO_Scroll_ScrollAbsoluteInstantly(noteScroll, extents)
            end
        end

        refreshCountLabel()
        refreshList() -- keep the green "has notes" dots current
    end)
    makeFocusable(noteEdit, noteEditBg)

    -- Hidden twin label used to measure how tall the note text renders.
    noteMeasure = WINDOW_MANAGER:CreateControl(nil, rightPage, CT_LABEL)
    noteMeasure:SetFont(noteFont())
    noteMeasure:SetWidth(NOTE_TEXT_WIDTH)
    noteMeasure:SetHidden(true)

    -- Empty-page hint, only shown in read mode when nothing is written.
    readLabel = WINDOW_MANAGER:CreateControl(nil, rightPage, CT_LABEL)
    readLabel:SetAnchor(TOPLEFT, noteEditBg, TOPLEFT, NOTE_PAD_X, NOTE_PAD_Y)
    readLabel:SetAnchor(BOTTOMRIGHT, noteEditBg, BOTTOMRIGHT, -NOTE_PAD_X, -NOTE_PAD_Y)
    readLabel:SetFont(noteFont())
    readLabel:SetColor(unpack(COLOR_TEXT))
    readLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    readLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    readLabel:SetText("|c6B5A42Nothing written for this entry yet. Switch to Edit Notes to start.|r")
    readLabel:SetHidden(true)

    countLabel = WINDOW_MANAGER:CreateControl(nil, rightPage, CT_LABEL)
    countLabel:SetFont(proseFont(14))
    countLabel:SetAnchor(TOPLEFT, noteEditBg, BOTTOMLEFT, 2, 4)
    countLabel:SetDimensions(PAGE_WIDTH - 4, 18)
    countLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    countLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    -- Channel dropdown + whisper target + buttons, tucked on the page bottom
    channelCombo = WINDOW_MANAGER:CreateControlFromVirtual("MyLittleJournalChannelCombo", rightPage, "ZO_ComboBox")
    channelCombo:SetDimensions(200, 32)
    channelCombo:SetAnchor(TOPLEFT, rightPage, TOPLEFT, 0, PAGE_HEIGHT - 122)
    channelComboObj = ZO_ComboBox_ObjectFromContainer(channelCombo)
    channelComboObj:SetSortsItems(false)

    whisperBg = WINDOW_MANAGER:CreateControl(nil, rightPage, CT_BACKDROP)
    whisperBg:SetDimensions(PAGE_WIDTH - 210, 28)
    whisperBg:SetAnchor(LEFT, channelCombo, RIGHT, 10, 0)
    whisperBg:SetCenterColor(0.30, 0.22, 0.12, 0.07)
    whisperBg:SetEdgeColor(0.38, 0.28, 0.16, 0.45)
    whisperBg:SetEdgeTexture("", 128, 1)
    whisperBg:SetHidden(true)

    whisperBox = WINDOW_MANAGER:CreateControl(nil, rightPage, CT_EDITBOX)
    whisperBox:SetAnchor(TOPLEFT, whisperBg, TOPLEFT, 8, 5)
    whisperBox:SetAnchor(BOTTOMRIGHT, whisperBg, BOTTOMRIGHT, -8, -5)
    whisperBox:SetFont(proseFont(18))
    whisperBox:SetColor(unpack(COLOR_TEXT))
    whisperBox:SetMaxInputChars(60)
    whisperBox:SetHandler("OnEscape", function(box) box:LoseFocus() end)
    whisperBox:SetHidden(true)
    makeFocusable(whisperBox, whisperBg)
    addPlaceholder(whisperBox, "@name to whisper")

    sendButton = WINDOW_MANAGER:CreateControlFromVirtual("MyLittleJournalSendButton", rightPage, "ZO_DefaultButton")
    sendButton:SetWidth(140)
    sendButton:SetAnchor(TOPLEFT, rightPage, TOPLEFT, -5, PAGE_HEIGHT - 78)
    sendButton:SetText("Send to Chat")
    sendButton:SetHandler("OnClicked", onSendClicked)

    -- Sends in a machine-readable format that other My Little Journal users
    -- can import with one click (see MyLittleJournal_Share.lua).
    shareButton = WINDOW_MANAGER:CreateControlFromVirtual("MyLittleJournalShareButton", rightPage, "ZO_DefaultButton")
    shareButton:SetWidth(95)
    shareButton:SetAnchor(LEFT, sendButton, RIGHT, 5, 0)
    shareButton:SetText("Share")
    shareButton:SetHandler("OnClicked", onShareClicked)

    modeButton = WINDOW_MANAGER:CreateControlFromVirtual("MyLittleJournalModeButton", rightPage, "ZO_DefaultButton")
    modeButton:SetWidth(135)
    modeButton:SetAnchor(LEFT, shareButton, RIGHT, 5, 0)
    modeButton:SetText("Reading Mode")
    modeButton:SetHandler("OnClicked", function()
        SV.readMode = not (SV and SV.readMode == true)
        applyReadMode()
        refreshRightPage()
    end)

    hintLine = WINDOW_MANAGER:CreateControl(nil, rightPage, CT_LABEL)
    hintLine:SetFont(proseFont(14))
    hintLine:SetColor(unpack(COLOR_DIM))
    hintLine:SetAnchor(BOTTOM, rightPage, BOTTOM, 0, -18)
    hintLine:SetText("Drag bosses to reorder · Right-click custom entries to delete")

    applyPosition()

    if SCENE_MANAGER and SCENE_MANAGER.RegisterTopLevel then
        SCENE_MANAGER:RegisterTopLevel(win, false)
    end

    selectCategory(selectedCategory)
    populateChannelDropdown()
    refreshRightPage()
end

-- =========================
-- Show / hide
-- =========================
function UI.Show()
    createWindow()
    autoSelectCurrentLocation()
    populateChannelDropdown()
    refreshList()
    refreshRightPage()
    PlaySound(SOUNDS.BOOK_OPEN)
    if SCENE_MANAGER and SCENE_MANAGER.ShowTopLevel then
        SCENE_MANAGER:ShowTopLevel(win)
    else
        win:SetHidden(false)
    end
end

function UI.Hide()
    if not win then return end
    if win:IsHidden() then return end
    PlaySound(SOUNDS.BOOK_CLOSE)
    if SCENE_MANAGER and SCENE_MANAGER.HideTopLevel then
        SCENE_MANAGER:HideTopLevel(win)
    else
        win:SetHidden(true)
    end
end

function UI.Toggle()
    createWindow()
    if win:IsHidden() then
        UI.Show()
    else
        UI.Hide()
    end
end

function UI.Init(savedVars)
    SV = savedVars
end

-- Called by the discovery module when new instances/bosses are recorded,
-- so an open journal reflects them immediately. Only the list is rebuilt;
-- the note editor is left alone in case the user is typing.
function UI.NotifyDataChanged()
    if win and not win:IsHidden() then
        refreshList()
    end
end

-- Called by the share module after an import, so the note text on screen
-- reflects the newly imported content (notes save per keystroke, so
-- reloading from saved vars never discards anything).
function UI.RefreshCurrentEntry()
    if win and not win:IsHidden() then
        refreshRightPage()
    end
end

-- Global for Bindings.xml
function MyLittleJournal_ToggleUI()
    UI.Toggle()
end
