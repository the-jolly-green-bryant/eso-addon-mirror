-- Transmute Set Crafter — Quicksaves
--
-- Named snapshots of the current queue. Each quicksave stores a deep copy of
-- the queue's entries. Clicking a row re-adds those entries to the current
-- queue (via TSC.AddToQueue, so derived fields like crystalCost are refreshed
-- to current game state). Saves persist to account-wide savedVars.

local TSC = TransmuteSetCrafter
local ADDON_NAME = TSC.name

local QUICKSAVE_ENTRY      = 1
local QUICKSAVE_ROW_HEIGHT = 26

local nameEditBox = nil

-- ── Helpers ───────────────────────────────────────────────

local function CopyEntry(entry)
    local copy = {}
    for k, v in pairs(entry) do
        copy[k] = v  -- shallow copy: all queue-entry values are primitives
    end
    return copy
end

local function CopyQueue(q)
    local copy = {}
    for _, entry in ipairs(q) do
        table.insert(copy, CopyEntry(entry))
    end
    return copy
end

local function Trim(s)
    return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function GetSaves()
    if not TSC.savedVars.quicksaves then
        TSC.savedVars.quicksaves = {}
    end
    return TSC.savedVars.quicksaves
end

-- ── Public: create / load / delete ────────────────────────

function TSC.CreateQuicksave(name)
    if not name or name == "" then
        TSC.Notify(TSC.NOTIFY_WARN, GetString(SI_TSC_MSG_QUICKSAVE_NEEDS_NAME))
        return
    end
    if #TSC.queue == 0 then
        TSC.Notify(TSC.NOTIFY_INFO, GetString(SI_TSC_MSG_QUICKSAVE_EMPTY))
        return
    end
    local saves = GetSaves()
    table.insert(saves, { name = name, queue = CopyQueue(TSC.queue) })
    TSC.savedVars.quicksaves = saves
    TSC.RefreshQuicksavePanel()
    TSC.NotifyF(TSC.NOTIFY_INFO, SI_TSC_MSG_QUICKSAVE_SAVED, name, #TSC.queue)
end

function TSC.LoadQuicksave(index)
    local saves = GetSaves()
    local save  = saves[index]
    if not save then return end

    local added = 0
    for _, entry in ipairs(save.queue) do
        TSC.AddToQueue(
            entry.pieceId,
            entry.traitType,
            entry.quality,
            entry.enchantment,
            entry.enchantQuality
        )
        added = added + 1
    end
    TSC.NotifyF(TSC.NOTIFY_INFO, SI_TSC_MSG_QUICKSAVE_LOADED, save.name, added)
end

function TSC.DeleteQuicksave(index)
    local saves = GetSaves()
    if not saves[index] then return end
    local name = saves[index].name
    table.remove(saves, index)
    TSC.savedVars.quicksaves = saves
    TSC.RefreshQuicksavePanel()
    TSC.NotifyF(TSC.NOTIFY_INFO, SI_TSC_MSG_QUICKSAVE_DELETED, name)
end

function TSC.CreateQuicksaveFromInput()
    if not nameEditBox then return end
    local name = Trim(nameEditBox:GetText())
    if name == "" then
        TSC.Notify(TSC.NOTIFY_WARN, GetString(SI_TSC_MSG_TYPE_NAME_FIRST))
        return
    end
    TSC.CreateQuicksave(name)
    nameEditBox:SetText("")
end

-- ── Row callbacks (wired from XML) ────────────────────────

function TSC.SetupQuicksaveRow(ctrl, data)
    ctrl.data = data
    local nameLbl = ctrl:GetNamedChild("Name")
    nameLbl:SetText(zo_strformat("<<1>>  (<<2>>)", data.name, data.count))
    ctrl:GetNamedChild("Export"):SetText(GetString(SI_TSC_LABEL_E))
    ctrl:GetNamedChild("Rename"):SetText(GetString(SI_TSC_LABEL_R))

    -- Resize the row to track the scroll list width so Delete stays right-pinned
    local list = TransmuteSetCrafterQuicksaveWindowList
    if list then
        local w = list:GetWidth() - 18
        if w > 120 then ctrl:SetWidth(w) end
    end

    ctrl:GetNamedChild("Highlight"):SetAlpha(0)
end

function TSC.OnQuicksaveRowMouseEnter(ctrl)
    if ctrl.data then
        ctrl:GetNamedChild("Highlight"):SetAlpha(0.2)
    end
end

function TSC.OnQuicksaveRowMouseExit(ctrl)
    if ctrl.data then
        ctrl:GetNamedChild("Highlight"):SetAlpha(0)
    end
end

function TSC.OnQuicksaveRowClick(ctrl, button, upInside)
    if not upInside or not ctrl.data then return end
    if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
    TSC.LoadQuicksave(ctrl.data.index)
end

function TSC.DeleteQuicksaveRow(ctrl)
    if ctrl and ctrl.data then
        TSC.DeleteQuicksave(ctrl.data.index)
    end
end

function TSC.ExportQuicksaveRow(ctrl)
    if ctrl and ctrl.data then
        TSC.ShowExportDialog(ctrl.data.index)
    end
end

function TSC.RenameQuicksaveRow(ctrl)
    if ctrl and ctrl.data then
        TSC.ShowRenameDialog(ctrl.data.index)
    end
end

-- ── Encoded import / export format ────────────────────────
-- Plain-text format (no base64) so users can recognize it. Magic prefix
-- "TSC1" identifies the string; "|" separates the magic, name, and each
-- queue entry; ";" separates fields inside an entry. Names must not contain
-- "|" or ";"; enchant strings (from our curated tables) never do.
--
--   TSC1|<name>|<pieceId>;<traitType>;<quality>;<enchant>;<enchantQuality>|<entry>|...

local EXPORT_MAGIC = "TSC1"
local QS_SEP      = "|"
local FIELD_SEP   = ";"

local function HasReservedChar(s)
    return s:find(QS_SEP, 1, true) ~= nil or s:find(FIELD_SEP, 1, true) ~= nil
end

-- Returns (encodedString) or (nil, errorStringId)
function TSC.EncodeQuicksave(save)
    if not save then return nil, SI_TSC_MSG_IMPORT_NO_NAME end
    if HasReservedChar(save.name or "") then
        return nil, SI_TSC_MSG_EXPORT_BAD_CHAR
    end
    local parts = { EXPORT_MAGIC, save.name }
    for _, entry in ipairs(save.queue or {}) do
        local enchant = entry.enchantment or ""
        if enchant:find(FIELD_SEP, 1, true) then
            return nil, SI_TSC_MSG_EXPORT_BAD_ENCHANT
        end
        parts[#parts + 1] = table.concat({
            tostring(entry.pieceId or 0),
            tostring(entry.traitType or ITEM_TRAIT_TYPE_NONE),
            tostring(entry.quality or ITEM_FUNCTIONAL_QUALITY_NORMAL),
            enchant,
            tostring(entry.enchantQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY),
        }, FIELD_SEP)
    end
    return table.concat(parts, QS_SEP)
end

-- Returns (quicksaveTable {name=, queue=}) or (nil, errorStringId, errorArg)
function TSC.DecodeQuicksave(str)
    if not str or str == "" then return nil, SI_TSC_MSG_IMPORT_EMPTY end
    str = str:gsub("^%s+", ""):gsub("%s+$", "")
    -- Splitting by | manually so empty trailing fields parse cleanly.
    local parts = {}
    local prev = 1
    for i = 1, #str do
        if str:sub(i, i) == QS_SEP then
            parts[#parts + 1] = str:sub(prev, i - 1)
            prev = i + 1
        end
    end
    parts[#parts + 1] = str:sub(prev)

    if parts[1] ~= EXPORT_MAGIC then return nil, SI_TSC_MSG_IMPORT_NOT_TSC end
    if not parts[2] or parts[2] == "" then return nil, SI_TSC_MSG_IMPORT_NO_NAME end

    local name = parts[2]
    local queue = {}
    for i = 3, #parts do
        local fields = {}
        local p2 = 1
        for k = 1, #parts[i] do
            if parts[i]:sub(k, k) == FIELD_SEP then
                fields[#fields + 1] = parts[i]:sub(p2, k - 1)
                p2 = k + 1
            end
        end
        fields[#fields + 1] = parts[i]:sub(p2)
        if #fields < 5 then return nil, SI_TSC_MSG_IMPORT_MALFORMED, i - 2 end
        queue[#queue + 1] = {
            pieceId        = tonumber(fields[1]),
            traitType      = tonumber(fields[2]),
            quality        = tonumber(fields[3]),
            enchantment    = fields[4],
            enchantQuality = tonumber(fields[5]),
        }
    end
    return { name = name, queue = queue }
end

-- ── Port dialog (Import / Export popup) ──────────────────

local portDialogMode = nil   -- "export", "import", or "rename"
local portDialogRenameIndex = nil  -- index of the save being renamed

-- The EditBox's maxInputCharacters is set in XML (currently 8000), large
-- enough for far more than the documented worst case (20-entry queue +
-- long name ≈ 750 chars). SetText is the authoritative limit.

local function GetPortDialogControls()
    local dlg = TransmuteSetCrafterPortDialog
    if not dlg then return end
    return dlg,
           dlg:GetNamedChild("Title"),
           dlg:GetNamedChild("EditBox"),
           dlg:GetNamedChild("Hint"),
           dlg:GetNamedChild("ActionButton")
end

function TSC.ShowExportDialog(index)
    local saves = GetSaves()
    local save  = saves[index]
    if not save then return end
    local encoded, errId = TSC.EncodeQuicksave(save)
    if not encoded then
        TSC.Notify(TSC.NOTIFY_WARN, GetString(errId))
        return
    end
    local dlg, title, edit, hint, btn = GetPortDialogControls()
    if not dlg then return end
    portDialogMode = "export"
    title:SetText(zo_strformat(SI_TSC_EXPORT_DIALOG_TITLE, save.name))
    edit:SetText(encoded)
    edit:SetEditEnabled(false)  -- read-only display
    hint:SetText(GetString(SI_TSC_EXPORT_HINT))
    btn:SetHidden(true)
    dlg:SetHidden(false)
    dlg:BringWindowToTop()
    edit:TakeFocus()
end

function TSC.ShowImportDialog()
    local dlg, title, edit, hint, btn = GetPortDialogControls()
    if not dlg then return end
    portDialogMode = "import"
    portDialogRenameIndex = nil
    title:SetText(GetString(SI_TSC_IMPORT_DIALOG_TITLE))
    edit:SetText("")
    edit:SetEditEnabled(true)
    hint:SetText(GetString(SI_TSC_IMPORT_HINT))
    btn:SetText(GetString(SI_TSC_LABEL_IMPORT))
    btn:SetHidden(false)
    dlg:SetHidden(false)
    dlg:BringWindowToTop()
    edit:TakeFocus()
end

function TSC.ShowRenameDialog(index)
    local save = GetSaves()[index]
    if not save then return end
    local dlg, title, edit, hint, btn = GetPortDialogControls()
    if not dlg then return end
    portDialogMode = "rename"
    portDialogRenameIndex = index
    title:SetText(zo_strformat(SI_TSC_RENAME_DIALOG_TITLE, save.name))
    edit:SetText(save.name)
    edit:SetEditEnabled(true)
    hint:SetText(GetString(SI_TSC_RENAME_HINT))
    btn:SetText(GetString(SI_TSC_LABEL_RENAME))
    btn:SetHidden(false)
    dlg:SetHidden(false)
    dlg:BringWindowToTop()
    edit:TakeFocus()
end

function TSC.ClosePortDialog()
    local dlg = TransmuteSetCrafterPortDialog
    if dlg then dlg:SetHidden(true) end
    portDialogMode = nil
end

function TSC.OnPortDialogAction()
    local _, _, edit = GetPortDialogControls()
    if not edit then return end

    if portDialogMode == "rename" then
        local newName = Trim(edit:GetText())
        if newName == "" then
            TSC.Notify(TSC.NOTIFY_WARN, GetString(SI_TSC_MSG_QUICKSAVE_NEEDS_NAME))
            return
        end
        local saves = GetSaves()
        local save  = saves[portDialogRenameIndex]
        if save then
            save.name = newName
            TSC.savedVars.quicksaves = saves
            TSC.RefreshQuicksavePanel()
            TSC.NotifyF(TSC.NOTIFY_INFO, SI_TSC_MSG_QUICKSAVE_RENAMED, newName)
        end
        TSC.ClosePortDialog()
        return
    end

    if portDialogMode == "import" then
        local decoded, errId, errArg = TSC.DecodeQuicksave(edit:GetText())
        if not decoded then
            if errArg then
                TSC.NotifyF(TSC.NOTIFY_WARN, errId, errArg)
            else
                TSC.Notify(TSC.NOTIFY_WARN, GetString(errId))
            end
            return
        end
        local saves = GetSaves()
        table.insert(saves, decoded)
        TSC.savedVars.quicksaves = saves
        TSC.RefreshQuicksavePanel()
        TSC.NotifyF(TSC.NOTIFY_INFO, SI_TSC_MSG_IMPORT_OK, decoded.name, #decoded.queue)
        TSC.ClosePortDialog()
    end
end

-- ── Panel refresh ─────────────────────────────────────────

function TSC.RefreshQuicksavePanel()
    local list = TransmuteSetCrafterQuicksaveWindowList
    if not list then return end
    ZO_ScrollList_Clear(list)
    local dataList = ZO_ScrollList_GetDataList(list)

    for i, save in ipairs(GetSaves()) do
        table.insert(dataList, ZO_ScrollList_CreateDataEntry(QUICKSAVE_ENTRY, {
            index = i,
            name  = save.name,
            count = save.queue and #save.queue or 0,
        }))
    end
    ZO_ScrollList_Commit(list)
end

-- ── Setup, called by UI.lua SetupUI ───────────────────────

function TSC.SetupQuicksavePanel()
    local win = TransmuteSetCrafterQuicksaveWindow
    if not win then return end

    -- Restore saved dimensions and position, enable corner-grip resize.
    -- If no saved position, keep the XML default (docked to cost window).
    if TSC.savedVars.quicksaveWindowWidth and TSC.savedVars.quicksaveWindowHeight then
        win:SetDimensions(TSC.savedVars.quicksaveWindowWidth, TSC.savedVars.quicksaveWindowHeight)
    end
    if TSC.savedVars.quicksaveXPos and TSC.savedVars.quicksaveYPos then
        win:ClearAnchors()
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                      TSC.savedVars.quicksaveXPos, TSC.savedVars.quicksaveYPos)
    end
    win:SetResizeHandleSize(8)

    -- Wire scroll list data type
    local list = TransmuteSetCrafterQuicksaveWindowList
    if list then
        ZO_ScrollList_AddDataType(list, QUICKSAVE_ENTRY, "TSC_QuicksaveRow",
                                  QUICKSAVE_ROW_HEIGHT,
                                  function(ctrl, data) TSC.SetupQuicksaveRow(ctrl, data) end)
    end

    -- Labels and the name editbox
    TransmuteSetCrafterQuicksaveWindowTitle:SetText(GetString(SI_TSC_LABEL_QUICKSAVES))
    TransmuteSetCrafterQuicksaveWindowSaveButton:SetText(GetString(SI_TSC_LABEL_SAVE))
    TransmuteSetCrafterQuicksaveWindowImportButton:SetText(GetString(SI_TSC_LABEL_IMPORT))

    nameEditBox = TransmuteSetCrafterQuicksaveWindowNameBox
    if nameEditBox then
        nameEditBox:SetDefaultText("Quicksave name...")
        -- Save on Enter
        nameEditBox:SetHandler("OnEnter", function()
            TSC.CreateQuicksaveFromInput()
        end)
    end

    TSC.RefreshQuicksavePanel()
end
