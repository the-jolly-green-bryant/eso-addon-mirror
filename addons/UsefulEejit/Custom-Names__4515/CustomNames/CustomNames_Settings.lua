-- CustomNames_Settings.lua
-- Single LAM panel with a hand-built tab bar (Azurah-style).
-- Static controls (enable, note, reload) live in the LAM options table.
-- Dynamic tab content is built manually using LAMCreateControl so it can
-- be fully rebuilt at any time without LAM's optionsState caching blocking us.

local CN = CustomNames
local LAM = LibAddonMenu2

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local function SortedKeys(t)
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys)
    return keys
end

local function DirtyBlobs()
    if WORLD_MAP_MANAGER then WORLD_MAP_MANAGER.blobNamesDirty = true end
end

------------------------------------------------------------------------
-- Tab state
------------------------------------------------------------------------

local WM              = WINDOW_MANAGER
local controlPanel    = nil   -- the LAM panel control
local panelWidth      = nil   -- usable content width
local tabBarCtrl      = nil   -- the custom control holding tab buttons
local tabPanels       = {}    -- [i] = CT_CONTROL outer panel (stays fixed)
local tabInners       = {}    -- [i] = current inner CT_CONTROL (replaced each rebuild)
local tabButtons      = {}    -- [i] = LAM button widget
local activeTab       = 1

-- Tab definitions: name + function that returns an array of widgetData tables
local TABS = {}   -- populated below after content functions are defined

------------------------------------------------------------------------
-- Show a tab by index
------------------------------------------------------------------------

local function ShowTab(index)
    activeTab = index
    for i, panel in ipairs(tabPanels) do
        panel:SetHidden(i ~= index)
    end
    for i, btn in ipairs(tabButtons) do
        if btn and btn.button then
            if i == index then
                btn.button:SetState(BSTATE_PRESSED, true)
            else
                btn.button:SetState(BSTATE_NORMAL, false)
            end
        end
    end
end

------------------------------------------------------------------------
-- Build content into a fresh inner container
-- Each call creates a new CT_CONTROL child of the outer panel and hides
-- the previous one. This guarantees no control layering between rebuilds.
------------------------------------------------------------------------

local function BuildContent(outerPanel, widgetDataList)
    -- Hide the previous inner container (all its children go with it)
    local prev = tabInners[outerPanel]
    if prev then prev:SetHidden(true) end

    -- Fresh inner container anchored to the outer panel's top
    local inner = WM:CreateControl(nil, outerPanel, CT_CONTROL)
    inner.panel = controlPanel
    inner:SetWidth(outerPanel:GetWidth())
    inner:SetAnchor(TOPLEFT)
    tabInners[outerPanel] = inner

    local lastCtrl = nil
    for _, data in ipairs(widgetDataList) do
        local wtype = data.type
        if LAMCreateControl[wtype] then
            local ok, widget = pcall(function()
                return LAMCreateControl[wtype](inner, data)
            end)
            if ok and widget then
                if lastCtrl then
                    widget:SetAnchor(TOPLEFT, lastCtrl, BOTTOMLEFT, 0, 15)
                else
                    widget:SetAnchor(TOPLEFT)
                end
                lastCtrl = widget
            end
        end
    end
end

------------------------------------------------------------------------
-- Remove dialog — lists all entries as clickable buttons
------------------------------------------------------------------------

local _removeWin
local _removeBtnPool = {}
local _removeCloseBtn

local function ShowRemoveDialog(tableKey, isArray)
    local t = CN.savedVars[tableKey]
    if not t then return end

    -- Build display labels showing "Original  ->  Custom"
    local keys = {}
    if isArray then
        for i, entry in ipairs(t) do
            local lbl = entry.label or entry.original or tostring(i)
            -- For quest renames show both original and custom
            if entry.original and entry.custom then
                lbl = entry.original .. "  ->  " .. entry.custom
            end
            keys[#keys + 1] = { label = lbl, index = i }
        end
    else
        -- For keyed tables, look up the custom value for display
        for k, v in pairs(t) do
            local lbl = k
            if type(v) == "string" and v ~= "" then
                lbl = k .. "  ->  " .. v
            elseif type(v) == "number" then
                -- zoneBlobScales etc — not shown here
                lbl = k
            end
            keys[#keys + 1] = { label = lbl, key = k }
        end
        table.sort(keys, function(a, b) return a.label < b.label end)
    end

    if #keys == 0 then
        CHAT_SYSTEM:AddMessage("|c88aaff[CustomNames]|r No entries to remove.")
        return
    end

    if not _removeWin then
        _removeWin = WM:CreateTopLevelWindow("CustomNames_RemoveWin")
        _removeWin:SetAnchor(CENTER, GuiRoot, CENTER, 220, 0)
        _removeWin:SetMovable(true); _removeWin:SetMouseEnabled(true)
        _removeWin:SetClampedToScreen(true); _removeWin:SetDrawLayer(DL_OVERLAY)
        local bg = WM:CreateControl(nil, _removeWin, CT_BACKDROP)
        bg:SetAnchorFill(_removeWin); bg:SetCenterColor(0.08, 0.08, 0.12, 0.97)
        bg:SetEdgeColor(0.7, 0.3, 0.3, 1); bg:SetEdgeTexture("", 1, 1, 2)
        local title = WM:CreateControl(nil, _removeWin, CT_LABEL)
        title:SetFont("ZoFontWinH4"); title:SetColor(1, 0.4, 0.4, 1); title:SetText("Remove Entry")
        title:SetAnchor(TOP, _removeWin, TOP, 0, 14); title:SetDimensions(420, 22)
        title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        -- Close button — always at index 0, created once
        _removeCloseBtn = WM:CreateControlFromVirtual(nil, _removeWin, "ZO_DefaultButton")
        _removeCloseBtn:SetText("None / Close")
        _removeCloseBtn:SetHandler("OnClicked", function() _removeWin:SetHidden(true) end)
    end

    for _, b in ipairs(_removeBtnPool) do b:SetHidden(true) end

    local W, rowH, topPad = 440, 32, 46
    -- +1 row for the Close button
    _removeWin:SetDimensions(W, topPad + (#keys + 1) * rowH + 14)

    -- Close button at top
    _removeCloseBtn:SetDimensions(W - 20, 26)
    _removeCloseBtn:SetAnchor(TOP, _removeWin, TOP, 0, topPad)
    _removeCloseBtn:SetHidden(false)

    -- Entry buttons below it
    for i, entry in ipairs(keys) do
        local btn = _removeBtnPool[i]
        if not btn then
            btn = WM:CreateControlFromVirtual(nil, _removeWin, "ZO_DefaultButton")
            _removeBtnPool[i] = btn
        end
        btn:SetText(entry.label)
        btn:SetDimensions(W - 20, 26)
        btn:SetAnchor(TOP, _removeWin, TOP, 0, topPad + i * rowH)
        btn:SetHidden(false)
        local capturedEntry = entry
        local capturedKey   = tableKey
        local capturedArray = isArray
        btn:SetHandler("OnClicked", function()
            _removeWin:SetHidden(true)
            CN.ShowConfirm("Remove \"" .. capturedEntry.label .. "\"?", function()
                if capturedArray then
                    table.remove(CN.savedVars[capturedKey], capturedEntry.index)
                else
                    CN.savedVars[capturedKey][capturedEntry.key] = nil
                end
                CHAT_SYSTEM:AddMessage("|c88aaff[CustomNames]|r Removed: " .. capturedEntry.label)
                CN.RebuildSettings()
            end)
        end)
    end

    _removeWin:SetHidden(false)
end

------------------------------------------------------------------------
-- Rebuild the currently visible tab (can be called any time)
------------------------------------------------------------------------

function CN.RebuildSettings()
    if not controlPanel or #tabPanels == 0 then return end
    local tab = TABS[activeTab]
    if tab then
        BuildContent(tabPanels[activeTab], tab.fn())
    end
end

------------------------------------------------------------------------
-- Content builders — return array of LAM widgetData tables
------------------------------------------------------------------------

local function ContentZones()
    local t = {}
    t[#t + 1] = {
        type = "button", name = "Add Zone",
        func = function() CN.ShowZoneAddDialog(CN.GetCurrentZoneName()) end,
    }
    t[#t + 1] = {
        type = "button", name = "Remove Zone",
        func = function() ShowRemoveDialog("zoneNames", false) end,
    }
    t[#t + 1] = {
        type = "description",
        text = function() return "Current zone: " .. (CN.GetCurrentZoneName() or "Unknown") end,
    }
    t[#t + 1] = {
        type = "description",
        text = "Use /cnzone in-game to get a zone's exact name. "
            .. "Add <br> in a custom name for a line break on the map blob label.",
    }
    t[#t + 1] = { type = "divider" }

    local keys = SortedKeys(CN.savedVars.zoneNames or {})
    if #keys == 0 then
        t[#t + 1] = { type = "description", text = "|c888888(no entries yet)|r" }
    else
        for _, orig in ipairs(keys) do
            local cap = orig
            local v   = CN.savedVars.zoneNames[orig]
            local disp = (v and v ~= "") and ("|cffd700" .. v .. "|r") or "|cff4444(hidden)|r"
            t[#t + 1] = { type = "description", title = orig .. "  ->  " .. disp }
            t[#t + 1] = {
                type = "description",
                text = function()
                    local def = CN.blobDefaultScales and CN.blobDefaultScales[cap]
                    local cur = CN.savedVars.zoneBlobScales and CN.savedVars.zoneBlobScales[cap]
                    local defStr = def and tostring(math.floor(def * 100 + 0.5)) or "|c888888unknown — open the map first|r"
                    local curStr = cur and tostring(math.floor(cur * 100 + 0.5)) or "|c888888default|r"
                    return "  Blob scale — Default: " .. defStr .. "   Current: " .. curStr
                end,
            }
            t[#t + 1] = {
                type = "slider", name = " ",
                tooltip = "Blob label scale for \"" .. orig .. "\". "
                       .. "Open the world map first to capture the default value. "
                       .. "Set identical values across zones to make them consistent.",
                min = 0, max = 200, step = 1,
                getFunc = function()
                    local s = CN.savedVars.zoneBlobScales and CN.savedVars.zoneBlobScales[cap]
                    if s then return math.floor(s * 100 + 0.5) end
                    local def = CN.blobDefaultScales and CN.blobDefaultScales[cap]
                    return def and math.floor(def * 100 + 0.5) or 0
                end,
                setFunc = function(val)
                    if not CN.savedVars.zoneBlobScales then CN.savedVars.zoneBlobScales = {} end
                    local def = CN.blobDefaultScales and CN.blobDefaultScales[cap]
                    local defInt = def and math.floor(def * 100 + 0.5) or 0
                    CN.savedVars.zoneBlobScales[cap] = (val == defInt or val == 0) and nil or val / 100
                    DirtyBlobs()
                end,
                valueFormat = "%d",
            }
            t[#t + 1] = {
                type = "button", name = "Edit",
                func = function()
                    CN.ShowZoneAddDialog(cap, CN.savedVars.zoneNames[cap] or "")
                end,
            }
            t[#t + 1] = {
                type = "button", name = "Remove",
                func = function()
                    CN.ShowConfirm("Remove zone entry for \"" .. cap .. "\"?", function()
                        CN.savedVars.zoneNames[cap] = nil
                        if CN.savedVars.zoneBlobScales then
                            CN.savedVars.zoneBlobScales[cap] = nil
                        end
                        CN.RebuildSettings()
                    end)
                end,
            }
        end
    end
    return t
end

local function ContentLocations()
    local t = {}
    t[#t + 1] = {
        type = "button", name = "Add Location",
        func = function() CN.ShowAddDialog("locationNames", CN.GetCurrentZoneName()) end,
    }
    t[#t + 1] = {
        type = "button", name = "Remove Location",
        func = function() ShowRemoveDialog("locationNames", false) end,
    }
    t[#t + 1] = {
        type = "description",
        text = "POI pins, fast travel nodes, subzone alerts, mouseover text.",
    }
    t[#t + 1] = { type = "divider" }

    local keys = SortedKeys(CN.savedVars.locationNames or {})
    if #keys == 0 then
        t[#t + 1] = { type = "description", text = "|c888888(no entries yet)|r" }
    else
        for _, orig in ipairs(keys) do
            local cap  = orig
            local v    = CN.savedVars.locationNames[orig]
            local disp = (v and v ~= "") and ("|cffd700" .. v .. "|r") or "|cff4444(hidden)|r"
            t[#t + 1] = { type = "description", title = orig .. "  ->  " .. disp }
            t[#t + 1] = {
                type = "button", name = "Edit",
                func = function()
                    CN.ShowAddDialog("locationNames", cap, CN.savedVars.locationNames[cap] or "")
                end,
            }
            t[#t + 1] = {
                type = "button", name = "Remove",
                func = function()
                    CN.ShowConfirm("Remove location \"" .. cap .. "\"?", function()
                        CN.savedVars.locationNames[cap] = nil
                        CN.RebuildSettings()
                    end)
                end,
            }
        end
    end
    return t
end

local function ContentNPCs()
    local t = {}
    t[#t + 1] = {
        type = "button", name = "Add NPC",
        func = function() CN.ShowAddDialog("npcNames", CN.GetTargetNPCName()) end,
    }
    t[#t + 1] = {
        type = "button", name = "Remove NPC",
        func = function() ShowRemoveDialog("npcNames", false) end,
    }
    t[#t + 1] = {
        type = "description",
        text = function() return "Current target: " .. (CN.GetTargetNPCName() or "(none)") end,
    }
    t[#t + 1] = {
        type = "description",
        text = "Nameplate text above NPCs. Target an NPC then click Add.",
    }
    t[#t + 1] = { type = "divider" }

    local keys = SortedKeys(CN.savedVars.npcNames or {})
    if #keys == 0 then
        t[#t + 1] = { type = "description", text = "|c888888(no entries yet)|r" }
    else
        for _, orig in ipairs(keys) do
            local cap  = orig
            local v    = CN.savedVars.npcNames[orig]
            local disp = (v and v ~= "") and ("|cffd700" .. v .. "|r") or "|cff4444(hidden)|r"
            t[#t + 1] = { type = "description", title = orig .. "  ->  " .. disp }
            t[#t + 1] = {
                type = "button", name = "Edit",
                func = function()
                    CN.ShowAddDialog("npcNames", cap, CN.savedVars.npcNames[cap] or "")
                end,
            }
            t[#t + 1] = {
                type = "button", name = "Remove",
                func = function()
                    CN.ShowConfirm("Remove NPC \"" .. cap .. "\"?", function()
                        CN.savedVars.npcNames[cap] = nil
                        CN.RebuildSettings()
                    end)
                end,
            }
        end
    end

    t[#t + 1] = { type = "divider" }
    t[#t + 1] = { type = "header", name = "Quest-Conditional Renames" }
    t[#t + 1] = {
        type = "button", name = "Add Quest Rename",
        func = function() CN.ShowQuestNPCDialog(nil, CN.GetTargetNPCName(), nil, nil) end,
    }
    t[#t + 1] = {
        type = "button", name = "Remove Quest Rename",
        func = function() ShowRemoveDialog("npcQuestNames", true) end,
    }
    t[#t + 1] = {
        type = "description",
        text = "Rename an NPC only after a specific quest is complete. "
            .. "Find quest IDs on UESP or with addons like Destinations.",
    }
    t[#t + 1] = { type = "divider" }

    local qlist = CN.savedVars.npcQuestNames or {}
    if #qlist == 0 then
        t[#t + 1] = { type = "description", text = "|c888888(no entries yet)|r" }
    else
        for i, entry in ipairs(qlist) do
            local ci = i
            local status = IsQuestComplete(entry.questId or 0)
                           and "|c44ff44complete|r" or "|cff4444incomplete|r"
            t[#t + 1] = {
                type = "description",
                title = entry.original .. "  ->  |cffd700" .. (entry.custom or "") .. "|r"
                     .. "  (quest " .. tostring(entry.questId or "?") .. ": " .. status .. ")",
            }
            t[#t + 1] = {
                type = "button", name = "Edit",
                func = function()
                    local e = CN.savedVars.npcQuestNames[ci]
                    if e then CN.ShowQuestNPCDialog(ci, e.original, e.questId, e.custom) end
                end,
            }
            t[#t + 1] = {
                type = "button", name = "Remove",
                func = function()
                    CN.ShowConfirm("Remove quest rename #" .. ci .. "?", function()
                        table.remove(CN.savedVars.npcQuestNames, ci)
                        CN.RebuildSettings()
                    end)
                end,
            }
        end
    end
    return t
end

local function ContentCellDoors()
    local t = {}
    t[#t + 1] = {
        type = "button", name = "Add Selectable",
        func = function() CN.ShowDoorDialog(nil, nil) end,
    }
    t[#t + 1] = {
        type = "button", name = "Remove Selectable",
        func = function() ShowRemoveDialog("doorNames", false) end,
    }
    t[#t + 1] = {
        type = "description",
        text = function()
            local id, name = CN.GetTargetDoorID()
            if id then
                return "Looking at: |cffd700" .. (name or "") .. "|r  |c888888(" .. id .. ")|r"
            end
            return "|c888888Look at a cell load door to detect it.|r"
        end,
    }
    t[#t + 1] = {
        type = "description",
        text = "Rename any named interactable object — cell load doors, chairs, "
            .. "containers, and more. Look at the object so the interact "
            .. "prompt is visible, then click Add.",
    }
    t[#t + 1] = { type = "divider" }

    local keys = SortedKeys(CN.savedVars.doorNames or {})
    if #keys == 0 then
        t[#t + 1] = { type = "description", text = "|c888888(no entries yet)|r" }
    else
        for _, id in ipairs(keys) do
            local cid    = id
            local custom = CN.savedVars.doorNames[id]
            t[#t + 1] = {
                type = "description",
                title = id .. "  ->  |cffd700" .. (custom or "") .. "|r",
            }
            t[#t + 1] = {
                type = "button", name = "Edit",
                func = function()
                    CN.ShowDoorDialog(cid, CN.savedVars.doorNames[cid] or "")
                end,
            }
            t[#t + 1] = {
                type = "button", name = "Remove",
                func = function()
                    CN.ShowConfirm("Remove door entry \"" .. cid .. "\"?", function()
                        CN.savedVars.doorNames[cid] = nil
                        CN.RebuildSettings()
                    end)
                end,
            }
        end
    end
    return t
end

-- Now populate TABS (after content functions are defined)
TABS = {
    { name = "Zones",            fn = ContentZones      },
    { name = "Locations",        fn = ContentLocations  },
    { name = "NPCs",             fn = ContentNPCs       },
    { name = "Selectables",      fn = ContentCellDoors  },
}

------------------------------------------------------------------------
-- Build the tab UI — called from LAM-PanelControlsCreated
------------------------------------------------------------------------

local function OnPanelControlsCreated(panel)
    if panel ~= controlPanel then return end

    tabBarCtrl = _G["CustomNames_TabBar"]
    if not tabBarCtrl then return end

    panelWidth = controlPanel:GetWidth() - 60
    local btnW = math.floor(panelWidth / #TABS) - 2

    -- Create tab buttons inside the tab bar custom control
    for i, tab in ipairs(TABS) do
        local btn = LAMCreateControl.button(tabBarCtrl, {
            type = "button",
            name = tab.name,
            func = function() ShowTab(i) end,
        })
        btn:SetWidth(btnW)
        btn.button:SetWidth(btnW)
        btn:SetAnchor(TOPLEFT, tabBarCtrl, TOPLEFT, (btnW + 2) * (i - 1), 0)
        tabButtons[i] = btn
    end

    -- Create one content panel per tab, all anchored below the tab bar
    for i, tab in ipairs(TABS) do
        local cp = WM:CreateControl(nil, controlPanel.scroll, CT_CONTROL)
        cp.panel  = controlPanel
        cp:SetWidth(panelWidth)
        cp:SetAnchor(TOPLEFT, tabBarCtrl, BOTTOMLEFT, 0, 10)
        tabPanels[i] = cp
        BuildContent(cp, tab.fn())
    end

    ShowTab(1)
end

------------------------------------------------------------------------
-- Dialogs
------------------------------------------------------------------------

-- Generic Add/Edit (locations, NPCs)
local _win, _origEdit, _custEdit, _currentKey

local function EnsureWindow()
    if _win then return end
    local W, H = 420, 220
    _win = WM:CreateTopLevelWindow("CustomNames_EntryWin")
    _win:SetDimensions(W, H); _win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    _win:SetMovable(true); _win:SetMouseEnabled(true)
    _win:SetClampedToScreen(true); _win:SetDrawLayer(DL_OVERLAY); _win:SetHidden(true)
    local bg = WM:CreateControl(nil, _win, CT_BACKDROP)
    bg:SetAnchorFill(_win); bg:SetCenterColor(0.08, 0.08, 0.12, 0.97)
    bg:SetEdgeColor(0.5, 0.5, 0.6, 1); bg:SetEdgeTexture("", 1, 1, 2)
    local title = WM:CreateControl(nil, _win, CT_LABEL)
    title:SetFont("ZoFontWinH4"); title:SetColor(1, 0.84, 0, 1); title:SetText("Add / Edit Entry")
    title:SetAnchor(TOP, _win, TOP, 0, 14); title:SetDimensions(W - 20, 22)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local lbl1 = WM:CreateControl(nil, _win, CT_LABEL)
    lbl1:SetFont("ZoFontGame"); lbl1:SetColor(0.9, 0.9, 0.9, 1); lbl1:SetText("Original Name")
    lbl1:SetAnchor(TOPLEFT, _win, TOPLEFT, 18, 50)
    _origEdit = WM:CreateControlFromVirtual("CustomNames_EntryWin_Orig", _win, "ZO_DefaultEditForBackdrop")
    _origEdit:SetAnchor(TOPLEFT, _win, TOPLEFT, 18, 72); _origEdit:SetDimensions(W-36, 28); _origEdit:SetMaxInputChars(128)
    local lbl2 = WM:CreateControl(nil, _win, CT_LABEL)
    lbl2:SetFont("ZoFontGame"); lbl2:SetColor(0.9, 0.9, 0.9, 1); lbl2:SetText("Custom Name  (leave blank to hide)")
    lbl2:SetAnchor(TOPLEFT, _win, TOPLEFT, 18, 108)
    _custEdit = WM:CreateControlFromVirtual("CustomNames_EntryWin_Cust", _win, "ZO_DefaultEditForBackdrop")
    _custEdit:SetAnchor(TOPLEFT, _win, TOPLEFT, 18, 130); _custEdit:SetDimensions(W-36, 28); _custEdit:SetMaxInputChars(128)
    local btnSave = WM:CreateControlFromVirtual(nil, _win, "ZO_DefaultButton")
    btnSave:SetText("Save"); btnSave:SetDimensions(110, 28)
    btnSave:SetAnchor(BOTTOMRIGHT, _win, BOTTOMRIGHT, -18, -14)
    btnSave:SetHandler("OnClicked", function()
        local orig = _origEdit:GetText(); local cust = _custEdit:GetText()
        if orig ~= "" then CN.savedVars[_currentKey][orig] = cust; CN.RebuildSettings(); CN.RefreshAll() end
        _win:SetHidden(true)
    end)
    local btnCancel = WM:CreateControlFromVirtual(nil, _win, "ZO_DefaultButton")
    btnCancel:SetText("Cancel"); btnCancel:SetDimensions(110, 28)
    btnCancel:SetAnchor(BOTTOMRIGHT, _win, BOTTOMRIGHT, -142, -14)
    btnCancel:SetHandler("OnClicked", function() _win:SetHidden(true) end)
end

function CN.ShowAddDialog(dataKey, prefill, existingCustom)
    EnsureWindow(); _currentKey = dataKey
    _origEdit:SetText(prefill or ""); _custEdit:SetText(existingCustom or "")
    _win:SetHidden(false); _origEdit:TakeFocus()
end

-- Zone Add/Edit
local _zwin, _zOrigEdit, _zCustEdit

local function EnsureZoneWindow()
    if _zwin then return end
    local W, H = 420, 220
    _zwin = WM:CreateTopLevelWindow("CustomNames_ZoneWin")
    _zwin:SetDimensions(W, H); _zwin:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    _zwin:SetMovable(true); _zwin:SetMouseEnabled(true)
    _zwin:SetClampedToScreen(true); _zwin:SetDrawLayer(DL_OVERLAY); _zwin:SetHidden(true)
    local bg = WM:CreateControl(nil, _zwin, CT_BACKDROP)
    bg:SetAnchorFill(_zwin); bg:SetCenterColor(0.08, 0.08, 0.12, 0.97)
    bg:SetEdgeColor(0.5, 0.5, 0.6, 1); bg:SetEdgeTexture("", 1, 1, 2)
    local title = WM:CreateControl(nil, _zwin, CT_LABEL)
    title:SetFont("ZoFontWinH4"); title:SetColor(1, 0.84, 0, 1); title:SetText("Add Zone Entry")
    title:SetAnchor(TOP, _zwin, TOP, 0, 14); title:SetDimensions(W-20, 22); title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local hint = WM:CreateControl(nil, _zwin, CT_LABEL)
    hint:SetFont("ZoFontGameSmall"); hint:SetColor(0.6, 0.6, 0.6, 1)
    hint:SetText("Blob scale can be adjusted per-entry in the settings panel after adding.")
    hint:SetAnchor(TOPLEFT, _zwin, TOPLEFT, 18, 40); hint:SetDimensions(W-36, 28)
    local lbl1 = WM:CreateControl(nil, _zwin, CT_LABEL)
    lbl1:SetFont("ZoFontGame"); lbl1:SetColor(0.9, 0.9, 0.9, 1); lbl1:SetText("Original Name")
    lbl1:SetAnchor(TOPLEFT, _zwin, TOPLEFT, 18, 72)
    _zOrigEdit = WM:CreateControlFromVirtual("CustomNames_ZoneWin_Orig", _zwin, "ZO_DefaultEditForBackdrop")
    _zOrigEdit:SetAnchor(TOPLEFT, _zwin, TOPLEFT, 18, 94); _zOrigEdit:SetDimensions(W-36, 28); _zOrigEdit:SetMaxInputChars(128)
    local lbl2 = WM:CreateControl(nil, _zwin, CT_LABEL)
    lbl2:SetFont("ZoFontGame"); lbl2:SetColor(0.9, 0.9, 0.9, 1); lbl2:SetText("Custom Name  (leave blank to hide)")
    lbl2:SetAnchor(TOPLEFT, _zwin, TOPLEFT, 18, 130)
    _zCustEdit = WM:CreateControlFromVirtual("CustomNames_ZoneWin_Cust", _zwin, "ZO_DefaultEditForBackdrop")
    _zCustEdit:SetAnchor(TOPLEFT, _zwin, TOPLEFT, 18, 152); _zCustEdit:SetDimensions(W-36, 28); _zCustEdit:SetMaxInputChars(128)
    local btnSave = WM:CreateControlFromVirtual(nil, _zwin, "ZO_DefaultButton")
    btnSave:SetText("Save"); btnSave:SetDimensions(110, 28)
    btnSave:SetAnchor(BOTTOMRIGHT, _zwin, BOTTOMRIGHT, -18, -14)
    btnSave:SetHandler("OnClicked", function()
        local orig = _zOrigEdit:GetText(); local cust = _zCustEdit:GetText()
        if orig ~= "" then CN.savedVars.zoneNames[orig] = cust; CN.RebuildSettings(); CN.RefreshAll() end
        _zwin:SetHidden(true)
    end)
    local btnCancel = WM:CreateControlFromVirtual(nil, _zwin, "ZO_DefaultButton")
    btnCancel:SetText("Cancel"); btnCancel:SetDimensions(110, 28)
    btnCancel:SetAnchor(BOTTOMRIGHT, _zwin, BOTTOMRIGHT, -142, -14)
    btnCancel:SetHandler("OnClicked", function() _zwin:SetHidden(true) end)
end

function CN.ShowZoneAddDialog(prefill, existingCustom)
    EnsureZoneWindow()
    _zOrigEdit:SetText(prefill or ""); _zCustEdit:SetText(existingCustom or "")
    _zwin:SetHidden(false); _zOrigEdit:TakeFocus()
end

-- Quest-conditional NPC
local _qwin, _qOrigEdit, _qQuestEdit, _qCustEdit, _qIndex

local function EnsureQuestWindow()
    if _qwin then return end
    local W, H = 420, 260
    _qwin = WM:CreateTopLevelWindow("CustomNames_QuestWin")
    _qwin:SetDimensions(W, H); _qwin:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    _qwin:SetMovable(true); _qwin:SetMouseEnabled(true)
    _qwin:SetClampedToScreen(true); _qwin:SetDrawLayer(DL_OVERLAY); _qwin:SetHidden(true)
    local bg = WM:CreateControl(nil, _qwin, CT_BACKDROP)
    bg:SetAnchorFill(_qwin); bg:SetCenterColor(0.08, 0.08, 0.12, 0.97)
    bg:SetEdgeColor(0.5, 0.5, 0.6, 1); bg:SetEdgeTexture("", 1, 1, 2)
    local title = WM:CreateControl(nil, _qwin, CT_LABEL)
    title:SetFont("ZoFontWinH4"); title:SetColor(1, 0.84, 0, 1); title:SetText("Quest-Conditional NPC Rename")
    title:SetAnchor(TOP, _qwin, TOP, 0, 14); title:SetDimensions(W-20, 22); title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local function ML(txt, y) local l = WM:CreateControl(nil, _qwin, CT_LABEL); l:SetFont("ZoFontGame"); l:SetColor(0.9,0.9,0.9,1); l:SetText(txt); l:SetAnchor(TOPLEFT, _qwin, TOPLEFT, 18, y) end
    local function ME(n, y) local e = WM:CreateControlFromVirtual(n, _qwin, "ZO_DefaultEditForBackdrop"); e:SetAnchor(TOPLEFT, _qwin, TOPLEFT, 18, y); e:SetDimensions(W-36, 28); e:SetMaxInputChars(128); return e end
    ML("Original NPC Name", 48); _qOrigEdit  = ME("CustomNames_QuestWin_Orig", 68)
    ML("Quest ID (number)", 106); _qQuestEdit = ME("CustomNames_QuestWin_Quest", 126)
    ML("Custom Name after quest complete", 164); _qCustEdit = ME("CustomNames_QuestWin_Cust", 184)
    local btnSave = WM:CreateControlFromVirtual(nil, _qwin, "ZO_DefaultButton")
    btnSave:SetText("Save"); btnSave:SetDimensions(110, 28)
    btnSave:SetAnchor(BOTTOMRIGHT, _qwin, BOTTOMRIGHT, -18, -14)
    btnSave:SetHandler("OnClicked", function()
        local orig = _qOrigEdit:GetText(); local qid = tonumber(_qQuestEdit:GetText()); local cust = _qCustEdit:GetText()
        if orig ~= "" and qid then
            local entry = { original = orig, questId = qid, custom = cust }
            local ql = CN.savedVars.npcQuestNames
            if _qIndex then ql[_qIndex] = entry else ql[#ql+1] = entry end
            CN.RebuildSettings()
        end
        _qwin:SetHidden(true)
    end)
    local btnCancel = WM:CreateControlFromVirtual(nil, _qwin, "ZO_DefaultButton")
    btnCancel:SetText("Cancel"); btnCancel:SetDimensions(110, 28)
    btnCancel:SetAnchor(BOTTOMRIGHT, _qwin, BOTTOMRIGHT, -142, -14)
    btnCancel:SetHandler("OnClicked", function() _qwin:SetHidden(true) end)
end

function CN.ShowQuestNPCDialog(index, prefillOrig, prefillQuestId, prefillCustom)
    EnsureQuestWindow(); _qIndex = index
    _qOrigEdit:SetText(prefillOrig or "")
    _qQuestEdit:SetText(prefillQuestId and tostring(prefillQuestId) or "")
    _qCustEdit:SetText(prefillCustom or "")
    _qwin:SetHidden(false); _qOrigEdit:TakeFocus()
end

-- Cell door Add/Edit
local _dwin, _dIdLabel, _dCustomEdit, _dCurrentId

local function EnsureDoorWindow()
    if _dwin then return end
    local W, H = 420, 200
    _dwin = WM:CreateTopLevelWindow("CustomNames_DoorWin")
    _dwin:SetDimensions(W, H); _dwin:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    _dwin:SetMovable(true); _dwin:SetMouseEnabled(true)
    _dwin:SetClampedToScreen(true); _dwin:SetDrawLayer(DL_OVERLAY); _dwin:SetHidden(true)
    local bg = WM:CreateControl(nil, _dwin, CT_BACKDROP)
    bg:SetAnchorFill(_dwin); bg:SetCenterColor(0.08, 0.08, 0.12, 0.97)
    bg:SetEdgeColor(0.5, 0.5, 0.6, 1); bg:SetEdgeTexture("", 1, 1, 2)
    local title = WM:CreateControl(nil, _dwin, CT_LABEL)
    title:SetFont("ZoFontWinH4"); title:SetColor(1, 0.84, 0, 1); title:SetText("Add / Edit Selectable Name")
    title:SetAnchor(TOP, _dwin, TOP, 0, 14); title:SetDimensions(W-20, 22); title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local lblId = WM:CreateControl(nil, _dwin, CT_LABEL)
    lblId:SetFont("ZoFontGame"); lblId:SetColor(0.9,0.9,0.9,1); lblId:SetText("Door ID")
    lblId:SetAnchor(TOPLEFT, _dwin, TOPLEFT, 18, 50)
    _dIdLabel = WM:CreateControl(nil, _dwin, CT_LABEL)
    _dIdLabel:SetFont("ZoFontGameSmall"); _dIdLabel:SetColor(0.6, 0.8, 1, 1)
    _dIdLabel:SetAnchor(TOPLEFT, _dwin, TOPLEFT, 18, 70); _dIdLabel:SetDimensions(W-36, 22)
    local lblC = WM:CreateControl(nil, _dwin, CT_LABEL)
    lblC:SetFont("ZoFontGame"); lblC:SetColor(0.9,0.9,0.9,1); lblC:SetText("Custom Name")
    lblC:SetAnchor(TOPLEFT, _dwin, TOPLEFT, 18, 100)
    _dCustomEdit = WM:CreateControlFromVirtual("CustomNames_DoorWin_Custom", _dwin, "ZO_DefaultEditForBackdrop")
    _dCustomEdit:SetAnchor(TOPLEFT, _dwin, TOPLEFT, 18, 122); _dCustomEdit:SetDimensions(W-36, 28); _dCustomEdit:SetMaxInputChars(128)
    local btnSave = WM:CreateControlFromVirtual(nil, _dwin, "ZO_DefaultButton")
    btnSave:SetText("Save"); btnSave:SetDimensions(110, 28)
    btnSave:SetAnchor(BOTTOMRIGHT, _dwin, BOTTOMRIGHT, -18, -14)
    btnSave:SetHandler("OnClicked", function()
        local custom = _dCustomEdit:GetText()
        if _dCurrentId and _dCurrentId ~= "" then
            CN.savedVars.doorNames[_dCurrentId] = custom ~= "" and custom or nil
            CN.RebuildSettings()
        end
        _dwin:SetHidden(true)
    end)
    local btnCancel = WM:CreateControlFromVirtual(nil, _dwin, "ZO_DefaultButton")
    btnCancel:SetText("Cancel"); btnCancel:SetDimensions(110, 28)
    btnCancel:SetAnchor(BOTTOMRIGHT, _dwin, BOTTOMRIGHT, -142, -14)
    btnCancel:SetHandler("OnClicked", function() _dwin:SetHidden(true) end)
end

function CN.ShowDoorDialog(existingId, existingCustom)
    EnsureDoorWindow()
    if existingId then
        _dCurrentId = existingId; _dIdLabel:SetText(existingId)
        _dCustomEdit:SetText(existingCustom or "")
    else
        local id = CN.GetTargetDoorID()
        if not id then
            CHAT_SYSTEM:AddMessage("|c88aaff[CustomNames]|r Look at a cell load door first.")
            return
        end
        _dCurrentId = id; _dIdLabel:SetText(id)
        _dCustomEdit:SetText(CN.savedVars.doorNames[id] or "")
    end
    _dwin:SetHidden(false); _dCustomEdit:TakeFocus()
end

-- Location trigger

------------------------------------------------------------------------
-- Confirm dialog
local _confirmWin, _confirmLabel, _confirmCallback

local function EnsureConfirmWindow()
    if _confirmWin then return end
    local W, H = 380, 120
    _confirmWin = WM:CreateTopLevelWindow("CustomNames_ConfirmWin")
    _confirmWin:SetDimensions(W, H); _confirmWin:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    _confirmWin:SetMovable(true); _confirmWin:SetMouseEnabled(true)
    _confirmWin:SetClampedToScreen(true); _confirmWin:SetDrawLayer(DL_OVERLAY); _confirmWin:SetHidden(true)
    local bg = WM:CreateControl(nil, _confirmWin, CT_BACKDROP)
    bg:SetAnchorFill(_confirmWin); bg:SetCenterColor(0.08, 0.08, 0.12, 0.97)
    bg:SetEdgeColor(0.7, 0.3, 0.3, 1); bg:SetEdgeTexture("", 1, 1, 2)
    _confirmLabel = WM:CreateControl(nil, _confirmWin, CT_LABEL)
    _confirmLabel:SetFont("ZoFontGame"); _confirmLabel:SetColor(1, 1, 1, 1)
    _confirmLabel:SetAnchor(TOP, _confirmWin, TOP, 0, 18); _confirmLabel:SetDimensions(W-36, 48)
    _confirmLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local btnYes = WM:CreateControlFromVirtual(nil, _confirmWin, "ZO_DefaultButton")
    btnYes:SetText("Yes"); btnYes:SetDimensions(100, 28)
    btnYes:SetAnchor(BOTTOMRIGHT, _confirmWin, BOTTOMRIGHT, -18, -14)
    btnYes:SetHandler("OnClicked", function()
        _confirmWin:SetHidden(true)
        if _confirmCallback then _confirmCallback() end; _confirmCallback = nil
    end)
    local btnNo = WM:CreateControlFromVirtual(nil, _confirmWin, "ZO_DefaultButton")
    btnNo:SetText("No"); btnNo:SetDimensions(100, 28)
    btnNo:SetAnchor(BOTTOMRIGHT, _confirmWin, BOTTOMRIGHT, -130, -14)
    btnNo:SetHandler("OnClicked", function() _confirmWin:SetHidden(true); _confirmCallback = nil end)
end

function CN.ShowConfirm(message, onYes)
    EnsureConfirmWindow(); _confirmCallback = onYes
    _confirmLabel:SetText(message); _confirmWin:SetHidden(false)
end

------------------------------------------------------------------------
-- Build settings panel
------------------------------------------------------------------------

function CN.BuildSettingsPanel()
    if not LAM then
        CHAT_SYSTEM:AddMessage("[CustomNames] ERROR: LibAddonMenu2 not found.")
        return
    end

    local panelData = {
        type        = "panel",
        name        = "Custom Names",
        displayName = "Custom Names",
        author      = "UsefulEejit",
        version     = CN.VERSION,
    }

    controlPanel = LAM:RegisterAddonPanel("CustomNamesPanel", panelData)

    -- Static controls that stay visible regardless of active tab,
    -- plus the custom placeholder for the tab bar.
    local optionsData = {
        {
            type = "description",
            text = "|caaaaaa Note: changes to this settings list will not display here "
                .. "until a UI reload — however all name changes take effect in-game "
                .. "immediately without reloading.|r",
        },
        {
            type    = "button",
            name    = "Reload UI",
            tooltip = "Reload the UI to apply all name changes.",
            func    = function() ReloadUI("ingame") end,
            warning = "This will reload the entire game UI.",
        },
        { type = "divider" },
        -- Tab bar placeholder — OnPanelControlsCreated fills this with buttons.
        {
            type      = "custom",
            reference = "CustomNames_TabBar",
        },
    }

    LAM:RegisterOptionControls("CustomNamesPanel", optionsData)

    -- Build the tab UI once LAM has rendered the panel controls.
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", OnPanelControlsCreated)

    SLASH_COMMANDS["/cn"] = function()
        LAM:OpenToPanel(controlPanel)
    end
end
