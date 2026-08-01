---------------------------------------------------------------------------
-- Thresholds - threshold string parsing and LibAddonMenu-2.0 panel
---------------------------------------------------------------------------

local THR = Thresholds

---------------------------------------------------------------------------
-- PARSING / FORMATTING
---------------------------------------------------------------------------
-- "90,70 50;25" -> { 90, 70, 50, 25 }. Accepts space/comma/semicolon
-- separators, keeps 0 < value < 100 (one decimal), dedupes, sorts
-- descending. Returns nil when no valid value is found.
function THR.ParseThresholdString(text)
    if type(text) ~= "string" then return nil end
    local values, known = {}, {}
    for token in string.gmatch(text, "[^%s,;]+") do
        local value = tonumber(token)
        if value and value > 0 and value < 100 then
            value = math.floor(value * 10 + 0.5) / 10
            if not known[value] then
                known[value] = true
                values[#values + 1] = value
            end
        end
    end
    if #values == 0 then return nil end
    table.sort(values, function(a, b) return a > b end)
    return values
end

-- List helpers shared with the import/export module (THR_Share.lua loads
-- before this file, see the manifest).
local EntryPct = THR.Share.EntryPct
local CompactEntry = THR.Share.CompactEntry

-- Accepts mixed lists (numbers and alert entry tables).
function THR.FormatThresholds(thresholds)
    if not thresholds or #thresholds == 0 then return "" end
    local parts = {}
    for i = 1, #thresholds do
        parts[i] = THR.FormatPercentValue(EntryPct(thresholds[i]))
    end
    return table.concat(parts, " ")
end

local STYLE_KEYS = {
    "color", "sound", "soundRepeat", "fontSize", "duration",
    "noText", "noSound", "x", "y",
}

local function HasStyle(entry)
    if type(entry) ~= "table" then return false end
    for i = 1, #STYLE_KEYS do
        if entry[STYLE_KEYS[i]] ~= nil then return true end
    end
    return false
end

-- Quick-entry save over an existing (possibly styled) list: percents that
-- persist keep their stored entry verbatim (styling survives), new percents
-- become plain numbers, absent ones are dropped. pcts must be the sorted
-- output of THR.ParseThresholdString.
function THR.MergeThresholdPcts(existingList, pcts)
    local byPct = {}
    if existingList then
        for i = 1, #existingList do
            local entry = existingList[i]
            local pct = EntryPct(entry)
            if byPct[pct] == nil then
                byPct[pct] = entry
            end
        end
    end
    local out = {}
    for i = 1, #pcts do
        local existing = byPct[pcts[i]]
        if existing ~= nil then
            out[i] = existing
        else
            out[i] = pcts[i]
        end
    end
    return out
end

---------------------------------------------------------------------------
-- ZONE CONFIG HELPERS
---------------------------------------------------------------------------
function THR.GetZoneConfig(zoneId, createIfMissing)
    local zone = THR.SV.zones[zoneId]
    if not zone and createIfMissing then
        zone = { name = THR.GetCleanName(GetZoneNameById(zoneId)) }
        THR.SV.zones[zoneId] = zone
    end
    return zone
end

function THR.PruneZoneConfig(zoneId)
    local zone = THR.SV.zones[zoneId]
    if zone and not zone.thresholds and (not zone.bosses or next(zone.bosses) == nil) then
        THR.SV.zones[zoneId] = nil
    end
end

---------------------------------------------------------------------------
-- LAM PANEL
---------------------------------------------------------------------------
local menuBossName = ""
local menuBossThresholdText = ""

local shareExportScope = "ZONE"
local shareExportText = ""
local shareImportText = ""
local copySourceZoneId = nil
local MAX_SHARE_CHARS = 30000

local function GetBossChoices()
    local choices, known = {}, {}
    for i = 1, #THR.BOSS_TAGS do
        local tag = THR.BOSS_TAGS[i]
        if DoesUnitExist(tag) then
            local name = THR.GetCleanName(GetUnitName(tag))
            if name ~= "" and not known[name] then
                known[name] = true
                choices[#choices + 1] = name
            end
        end
    end
    local zone = THR.SV.zones[THR.currentZoneId]
    if zone and zone.bosses then
        for name in pairs(zone.bosses) do
            if not known[name] then
                known[name] = true
                choices[#choices + 1] = name
            end
        end
    end
    -- Shipped boss names are English; skip them on other client languages so
    -- the dropdown never offers a name that can't match GetUnitName().
    local shipped = THR.BossData and THR.BossData[THR.currentZoneId]
    if shipped and shipped.bosses and THR.UsesEnglishNames() then
        for name in pairs(shipped.bosses) do
            if not known[name] then
                known[name] = true
                choices[#choices + 1] = name
            end
        end
    end
    table.sort(choices)
    return choices
end

local function RefreshBossDropdown()
    local dropdown = Thresholds_BossOverrideDropdown -- LAM control created via "reference"
    if dropdown then
        dropdown:UpdateChoices(GetBossChoices())
    end
end

-- Zones that have their own zone thresholds, excluding the current zone.
local function GetZoneCopyChoices()
    local entries = {}
    for zoneId, zone in pairs(THR.SV.zones) do
        if zone.thresholds and zoneId ~= THR.currentZoneId then
            entries[#entries + 1] = {
                label = string.format("%s (%d)", zone.name or "?", zoneId),
                id = zoneId,
            }
        end
    end
    table.sort(entries, function(a, b) return a.label < b.label end)
    local labels, ids = {}, {}
    for i = 1, #entries do
        labels[i] = entries[i].label
        ids[i] = entries[i].id
    end
    return labels, ids
end

local function RefreshZoneCopyDropdown()
    if copySourceZoneId then
        local zone = THR.SV.zones[copySourceZoneId]
        if not zone or not zone.thresholds or copySourceZoneId == THR.currentZoneId then
            copySourceZoneId = nil -- selection went stale
        end
    end
    local dropdown = Thresholds_ZoneCopyDropdown -- LAM control created via "reference"
    if dropdown then
        dropdown:UpdateChoices(GetZoneCopyChoices())
    end
end

-- Percent list with quoted custom texts; * marks entries with own styling.
local function FormatOverrideSummary(override)
    local parts = {}
    for i = 1, #override do
        local entry = override[i]
        local part = THR.FormatPercentValue(EntryPct(entry))
        if type(entry) == "table" then
            if entry.text then
                part = part .. string.format(" \"%s\"", entry.text)
            end
            if HasStyle(entry) then
                part = part .. "*"
            end
        end
        parts[i] = part
    end
    return table.concat(parts, ", ")
end

local function GetOverrideSummary()
    local zone = THR.SV.zones[THR.currentZoneId]
    if not zone or not zone.bosses or next(zone.bosses) == nil then
        return "No per-boss overrides configured for this zone."
    end
    local names = {}
    for name in pairs(zone.bosses) do
        names[#names + 1] = name
    end
    table.sort(names)
    local lines = {}
    for i = 1, #names do
        lines[i] = string.format("|cFFD700%s|r: %s", names[i],
            FormatOverrideSummary(zone.bosses[names[i]]))
    end
    return table.concat(lines, "\n")
end

---------------------------------------------------------------------------
-- ALERT EDITOR
---------------------------------------------------------------------------
local NEW_ALERT_VALUE = "__new"
local editorRefreshers = {}

local function RefreshAlertEditors()
    for i = 1, #editorRefreshers do
        editorRefreshers[i]()
    end
end

-- Builds the editor controls for one config level and returns
-- (controls, resetFunc). level = {
--     id = "Global"|"Zone"|"Boss",       -- unique, used for control names
--     GetList = function() -> stored threshold list or nil,
--     SetList = function(list),          -- write back (may return false to
--                                        -- abort, e.g. no boss selected)
--     GetPreviewName = function() -> subject name for the preview alert,
-- }
local function BuildAlertEditor(level)
    local st = {
        selected = nil, -- pct of the loaded stored entry; nil = <New alert>
        pctText = "",
        text = "",
        useColor = false,
        color = { 1, 1, 1 },
        sound = "", -- "" = inherit the global alert sound
        soundRepeat = 1,
        useFontSize = false,
        fontSize = 32,
        useDuration = false,
        duration = 3,
        usePosition = false,
        x = nil, -- captured by dragging in positioning mode
        y = nil,
        showText = true,
        playSound = true,
    }

    local function FindEntry(pct)
        local list = level.GetList()
        if not list then return nil end
        for i = 1, #list do
            if EntryPct(list[i]) == pct then
                return list[i]
            end
        end
    end

    local function LoadEntry(pct)
        local entry = pct and FindEntry(pct)
        local t = type(entry) == "table" and entry or {}
        st.selected = entry ~= nil and pct or nil
        st.pctText = entry ~= nil and THR.FormatPercentValue(pct) or ""
        st.text = t.text or ""
        st.useColor = t.color ~= nil
        st.color = t.color and { t.color[1], t.color[2], t.color[3] } or { 1, 1, 1 }
        st.sound = t.sound or ""
        st.soundRepeat = t.soundRepeat or 1
        st.useFontSize = t.fontSize ~= nil
        st.fontSize = t.fontSize or THR.SV.alerts.textFontSize
        st.useDuration = t.duration ~= nil
        st.duration = t.duration or THR.SV.alerts.textDuration
        st.usePosition = t.x ~= nil
        st.x = t.x
        st.y = t.y
        st.showText = not t.noText
        st.playSound = not t.noSound
    end

    -- Sparse stored entry from the editor fields, or nil for a bad percent.
    local function BuildEntryFromState()
        local pct = tonumber(st.pctText)
        if not pct or pct <= 0 or pct >= 100 then return nil end
        pct = math.floor(pct * 10 + 0.5) / 10
        local entry = { pct = pct }
        if st.text ~= "" then entry.text = st.text end
        if st.useColor then entry.color = { st.color[1], st.color[2], st.color[3] } end
        if st.sound ~= "" then entry.sound = st.sound end
        if st.playSound and st.soundRepeat > 1 then entry.soundRepeat = st.soundRepeat end
        if st.useFontSize then entry.fontSize = st.fontSize end
        if st.useDuration then entry.duration = st.duration end
        if st.usePosition and st.x and st.y then
            entry.x = math.floor(st.x + 0.5)
            entry.y = math.floor(st.y + 0.5)
        end
        if not st.showText then entry.noText = true end
        if not st.playSound then entry.noSound = true end
        return CompactEntry(entry)
    end

    local function GetAlertChoices()
        local choices, values = { "<New alert>" }, { NEW_ALERT_VALUE }
        local list = level.GetList()
        if list then
            local pcts = {}
            for i = 1, #list do
                pcts[#pcts + 1] = EntryPct(list[i])
            end
            table.sort(pcts, function(a, b) return a > b end)
            for i = 1, #pcts do
                local pctStr = THR.FormatPercentValue(pcts[i])
                local entry = FindEntry(pcts[i])
                local label = pctStr .. "%"
                if type(entry) == "table" and entry.text then
                    label = label .. " - " .. entry.text
                end
                if HasStyle(entry) then
                    label = label .. " *"
                end
                choices[#choices + 1] = label
                values[#values + 1] = pctStr
            end
        end
        return choices, values
    end

    local dropdownRef = "Thresholds_AlertEditor" .. level.id .. "Dropdown"

    editorRefreshers[#editorRefreshers + 1] = function()
        local dropdown = _G[dropdownRef]
        if dropdown then
            local choices, values = GetAlertChoices()
            dropdown:UpdateChoices(choices, values)
        end
        if st.selected and not FindEntry(st.selected) then
            LoadEntry(nil)
        end
    end

    local function SaveAlert()
        THR.EndAlertPositioning()
        local entry = BuildEntryFromState()
        if not entry then
            d("|c66CCFFThresholds:|r enter a percent value between 0 and 100.")
            return
        end
        local newPct = EntryPct(entry)
        -- Save replaces the originally selected entry and any entry that
        -- already sits on the new percent, keeping the list dupe-free.
        local out = {}
        local list = level.GetList()
        if list then
            for i = 1, #list do
                local pct = EntryPct(list[i])
                if pct ~= newPct and pct ~= st.selected then
                    out[#out + 1] = list[i]
                end
            end
        end
        out[#out + 1] = entry
        table.sort(out, function(a, b) return EntryPct(a) > EntryPct(b) end)
        if level.SetList(out) == false then return end
        LoadEntry(newPct)
        THR.ReapplyThresholds()
        RefreshAlertEditors()
    end

    local function DeleteAlert()
        THR.EndAlertPositioning()
        if st.selected == nil then return end
        local out = {}
        local list = level.GetList()
        if list then
            for i = 1, #list do
                if EntryPct(list[i]) ~= st.selected then
                    out[#out + 1] = list[i]
                end
            end
        end
        if level.SetList(out) == false then return end
        LoadEntry(nil)
        THR.ReapplyThresholds()
        RefreshAlertEditors()
    end

    local function PreviewAlert()
        THR.EndAlertPositioning()
        local entry = BuildEntryFromState()
        if not entry then
            d("|c66CCFFThresholds:|r enter a percent value between 0 and 100.")
            return
        end
        local normalized
        if type(entry) == "table" then
            normalized = entry
            normalized.value = entry.pct
        else
            normalized = { value = entry }
        end
        THR.FireAlert(level.GetPreviewName(), normalized)
    end

    local controls = {
        {
            type = "dropdown",
            name = "Alert",
            tooltip = "Pick an alert to edit, or <New alert> to add one. Changes apply on Save.",
            choices = { "<New alert>" },
            choicesValues = { NEW_ALERT_VALUE },
            scrollable = true,
            getFunc = function()
                return st.selected and THR.FormatPercentValue(st.selected) or NEW_ALERT_VALUE
            end,
            setFunc = function(value)
                THR.EndAlertPositioning()
                if value == NEW_ALERT_VALUE then
                    LoadEntry(nil)
                else
                    LoadEntry(tonumber(value))
                end
            end,
            reference = dropdownRef,
        },
        {
            type = "editbox",
            name = "Percent",
            tooltip = "HP percentage that triggers this alert (0-100, one decimal).",
            getFunc = function() return st.pctText end,
            setFunc = function(text) st.pctText = text end,
            isMultiline = false,
            width = "half",
        },
        {
            type = "editbox",
            name = "Alert text",
            tooltip = "Leave empty for the default \"Boss Name  70%\".",
            getFunc = function() return st.text end,
            setFunc = function(text) st.text = text end,
            isMultiline = false,
        },
        {
            type = "checkbox",
            name = "Custom color",
            getFunc = function() return st.useColor end,
            setFunc = function(value) st.useColor = value end,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Text color",
            getFunc = function() return st.color[1], st.color[2], st.color[3] end,
            setFunc = function(r, g, b) st.color = { r, g, b } end,
            disabled = function() return not st.useColor end,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Sound",
            choices = (function()
                local pretty = { "Use default" }
                for i = 1, #THR.SOUND_CHOICES do
                    pretty[i + 1] = THR.GetSoundDisplayName(THR.SOUND_CHOICES[i])
                end
                return pretty
            end)(),
            choicesValues = (function()
                local keys = { "" }
                for i = 1, #THR.SOUND_CHOICES do
                    keys[i + 1] = THR.SOUND_CHOICES[i]
                end
                return keys
            end)(),
            scrollable = true,
            getFunc = function() return st.sound end,
            setFunc = function(value) st.sound = value end,
            disabled = function() return not st.playSound end,
            width = "half",
        },
        {
            type = "button",
            name = "Preview sound",
            func = function()
                THR.PlayAlertSound(st.sound ~= "" and st.sound or nil, st.soundRepeat)
            end,
            disabled = function() return not st.playSound end,
            width = "half",
        },
        {
            type = "slider",
            name = "Sound repeat",
            tooltip = "How many times the sound plays in quick succession.",
            min = 1,
            max = 3,
            step = 1,
            getFunc = function() return st.soundRepeat end,
            setFunc = function(value) st.soundRepeat = value end,
            disabled = function() return not st.playSound end,
        },
        {
            type = "checkbox",
            name = "Custom font size",
            getFunc = function() return st.useFontSize end,
            setFunc = function(value) st.useFontSize = value end,
            width = "half",
        },
        {
            type = "slider",
            name = "Font size",
            min = 24,
            max = 48,
            step = 1,
            getFunc = function() return st.fontSize end,
            setFunc = function(value) st.fontSize = value end,
            disabled = function() return not st.useFontSize end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Custom duration",
            getFunc = function() return st.useDuration end,
            setFunc = function(value) st.useDuration = value end,
            width = "half",
        },
        {
            type = "slider",
            name = "Duration (seconds)",
            min = 1,
            max = 10,
            step = 1,
            getFunc = function() return st.duration end,
            setFunc = function(value) st.duration = value end,
            disabled = function() return not st.useDuration end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Custom position",
            tooltip = "Give this alert its own screen position. Press \"Move alert\", drag the text where you want it, then Save.",
            getFunc = function() return st.usePosition end,
            setFunc = function(value)
                st.usePosition = value
                if not value then
                    st.x, st.y = nil, nil
                    THR.EndAlertPositioning()
                end
            end,
            width = "half",
        },
        {
            type = "button",
            name = function()
                return THR.IsAlertPositioning() and "Done moving" or "Move alert"
            end,
            tooltip = "Shows this alert on screen and lets you drag it. The position is kept when you press Save alert.",
            func = function()
                if THR.IsAlertPositioning() then
                    THR.EndAlertPositioning()
                    return
                end
                local text = st.text
                if text == "" then
                    text = THR.BuildDefaultAlertText(level.GetPreviewName(),
                        tonumber(st.pctText) or 70)
                end
                THR.BeginAlertPositioning(text, {
                    color = st.useColor and st.color or nil,
                    fontSize = st.useFontSize and st.fontSize or nil,
                    x = st.x,
                    y = st.y,
                }, function(x, y)
                    st.x = x
                    st.y = y
                end)
            end,
            disabled = function() return not st.usePosition end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Show text alert",
            tooltip = "Uncheck for a sound-only alert. The master alert toggles still apply.",
            getFunc = function() return st.showText end,
            setFunc = function(value) st.showText = value end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Play sound",
            tooltip = "Uncheck for a text-only alert. The master alert toggles still apply.",
            getFunc = function() return st.playSound end,
            setFunc = function(value) st.playSound = value end,
            width = "half",
        },
        {
            type = "button",
            name = "Preview alert",
            tooltip = "Fires this alert exactly as configured (master toggles apply).",
            func = PreviewAlert,
        },
        {
            type = "button",
            name = "Save alert",
            func = SaveAlert,
            width = "half",
        },
        {
            type = "button",
            name = "Delete alert",
            func = DeleteAlert,
            disabled = function() return st.selected == nil end,
            width = "half",
        },
    }

    local function Reset()
        THR.EndAlertPositioning()
        LoadEntry(nil)
    end

    return controls, Reset
end

---------------------------------------------------------------------------
-- IMPORT / EXPORT
---------------------------------------------------------------------------
local function ApplyImport(payload, mode)
    local summary = THR.Share.Apply(payload, mode)
    if menuBossName ~= "" then
        -- resync the per-boss quick-entry state; the import may have
        -- changed the override of the currently selected boss
        local name = THR.GetCleanName(menuBossName)
        local zone = THR.SV.zones[THR.currentZoneId]
        menuBossThresholdText = THR.FormatThresholds(zone and zone.bosses and zone.bosses[name])
    end
    THR.ReapplyThresholds()
    RefreshBossDropdown()
    RefreshAlertEditors()
    RefreshZoneCopyDropdown()
    -- dialog callbacks run outside any LAM setFunc, so registerForRefresh
    -- does not repaint by itself
    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", THR.menuPanel)
    d(string.format("|c66CCFFThresholds:|r imported %d alerts into %d lists (%s).",
        summary.entries, summary.lists, mode))
end

ESO_Dialogs["THRESHOLDS_IMPORT"] = {
    canQueue = false,
    title = { text = "Thresholds - Import" },
    mainText = { text = "" }, -- assigned right before each show
    buttons = {
        {
            text = "Replace",
            keybind = "DIALOG_PRIMARY",
            callback = function(dialog) ApplyImport(dialog.data.payload, "replace") end,
        },
        {
            -- Deliberately not DIALOG_NEGATIVE: ESC activates that keybind,
            -- and ESC must abort instead of merging.
            text = "Merge",
            keybind = "DIALOG_SECONDARY",
            callback = function(dialog) ApplyImport(dialog.data.payload, "merge") end,
        },
    },
    noChoiceCallback = function() end, -- ESC = abort
}

local function GenerateExport()
    local str, err
    if shareExportScope == "ZONE" then
        str, err = THR.Share.ExportZone(THR.currentZoneId)
    elseif shareExportScope == "BOSS" then
        local name = THR.GetCleanName(menuBossName or "")
        if name == "" then
            err = "select a boss in the per-boss submenu first."
        else
            str, err = THR.Share.ExportBoss(THR.currentZoneId, name)
        end
    elseif shareExportScope == "GLOBAL" then
        str = THR.Share.ExportGlobal()
    else
        str = THR.Share.ExportAll()
    end
    if not str then
        d("|c66CCFFThresholds:|r " .. (err or "nothing to export."))
        return
    end
    if #str > MAX_SHARE_CHARS then
        d(string.format("|c66CCFFThresholds:|r the export is %d characters - too long for the text box.", #str))
        return
    end
    shareExportText = str
    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", THR.menuPanel)
end

local function DoImport()
    -- Read the control directly - LAM only commits editbox text on focus
    -- loss, which may not have happened when the button is clicked.
    local text = shareImportText
    if Thresholds_ShareImportBox and Thresholds_ShareImportBox.editbox then
        text = Thresholds_ShareImportBox.editbox:GetText()
    end
    if not string.match(text or "", "%S") then
        d("|c66CCFFThresholds:|r paste an export string first.")
        return
    end
    shareImportText = text
    local payload, err, stats = THR.Share.Deserialize(text,
        { validSounds = THR.Share.GetValidSounds() })
    if not payload then
        d("|c66CCFFThresholds:|r import failed: " .. err)
        return
    end
    ESO_Dialogs["THRESHOLDS_IMPORT"].mainText.text = THR.Share.DescribePayload(payload, stats)
    ZO_Dialogs_ShowDialog("THRESHOLDS_IMPORT", { payload = payload })
end

---------------------------------------------------------------------------
-- PANEL ASSEMBLY
---------------------------------------------------------------------------
function THR.CreateSettingsMenu()
    local LAM2 = LibAddonMenu2
    if not LAM2 then return end

    local panelName = THR.name .. "Options"

    local panelData = {
        type = "panel",
        name = THR.displayName,
        displayName = "|c66CCFF" .. THR.displayName .. "|r",
        author = THR.author,
        version = THR.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local globalEditorControls = BuildAlertEditor({
        id = "Global",
        GetList = function() return THR.SV.globalThresholds end,
        SetList = function(list) THR.SV.globalThresholds = list end,
        GetPreviewName = function() return "Boss Name" end,
    })

    local zoneEditorControls = BuildAlertEditor({
        id = "Zone",
        GetList = function()
            local zone = THR.SV.zones[THR.currentZoneId]
            return zone and zone.thresholds
        end,
        SetList = function(list)
            if #list == 0 then
                local zone = THR.SV.zones[THR.currentZoneId]
                if zone then zone.thresholds = nil end
                THR.PruneZoneConfig(THR.currentZoneId)
            else
                THR.GetZoneConfig(THR.currentZoneId, true).thresholds = list
            end
        end,
        GetPreviewName = function() return "Boss Name" end,
    })

    local bossEditorControls, ResetBossEditor = BuildAlertEditor({
        id = "Boss",
        GetList = function()
            local name = THR.GetCleanName(menuBossName or "")
            local zone = THR.SV.zones[THR.currentZoneId]
            return zone and zone.bosses and zone.bosses[name]
        end,
        SetList = function(list)
            local name = THR.GetCleanName(menuBossName or "")
            if name == "" then
                d("|c66CCFFThresholds:|r select or enter a boss name first.")
                return false
            end
            if #list == 0 then
                local zone = THR.SV.zones[THR.currentZoneId]
                if zone and zone.bosses then
                    zone.bosses[name] = nil
                    if next(zone.bosses) == nil then zone.bosses = nil end
                    THR.PruneZoneConfig(THR.currentZoneId)
                end
            else
                local zone = THR.GetZoneConfig(THR.currentZoneId, true)
                zone.bosses = zone.bosses or {}
                zone.bosses[name] = list
            end
            RefreshBossDropdown()
        end,
        GetPreviewName = function()
            local name = THR.GetCleanName(menuBossName or "")
            return name ~= "" and name or "Boss Name"
        end,
    })

    local optionsData = {
        {
            type = "checkbox",
            name = "Enable Thresholds",
            tooltip = "Master switch for all boss threshold tracking.",
            getFunc = function() return THR.SV.enabled end,
            setFunc = function(value)
                THR.SV.enabled = value
                if value then THR.Enable() else THR.Disable() end
            end,
            default = THR.default.enabled,
        },
        {
            type = "checkbox",
            name = "Lock frames",
            tooltip = "Unlock to drag the tracker frame and the alert text; also toggled by /thr.",
            getFunc = function() return THR.SV.frame.locked end,
            setFunc = function(value) THR.SetFrameLocked(value) end,
            default = THR.default.frame.locked,
        },

        { type = "header", name = "Alerts" },
        {
            type = "checkbox",
            name = "Prominent text alert",
            tooltip = "Show a large text alert on screen when a threshold is crossed.",
            getFunc = function() return THR.SV.alerts.text end,
            setFunc = function(value) THR.SV.alerts.text = value end,
            default = THR.default.alerts.text,
        },
        {
            type = "slider",
            name = "Alert font size",
            tooltip = "Default font size; individual alerts can override it.",
            min = 24,
            max = 48,
            step = 1,
            getFunc = function() return THR.SV.alerts.textFontSize end,
            setFunc = function(value)
                THR.SV.alerts.textFontSize = value
                THR.UpdateAlertFont()
                THR.ShowExampleAlert()
            end,
            disabled = function() return not THR.SV.alerts.text end,
            default = THR.default.alerts.textFontSize,
            width = "half",
        },
        {
            type = "slider",
            name = "Alert duration (seconds)",
            tooltip = "Default display duration; individual alerts can override it.",
            min = 1,
            max = 10,
            step = 1,
            getFunc = function() return THR.SV.alerts.textDuration end,
            setFunc = function(value)
                THR.SV.alerts.textDuration = value
                THR.ShowExampleAlert()
            end,
            disabled = function() return not THR.SV.alerts.text end,
            default = THR.default.alerts.textDuration,
            width = "half",
        },
        {
            type = "button",
            name = "Reset alert position",
            tooltip = "Move the alert text back to its default spot above the screen center.",
            func = function() THR.ResetAlertPosition() end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Sound cue",
            getFunc = function() return THR.SV.alerts.sound end,
            setFunc = function(value) THR.SV.alerts.sound = value end,
            default = THR.default.alerts.sound,
        },
        {
            type = "dropdown",
            name = "Alert sound",
            tooltip = "Default sound; individual alerts can override it.",
            choices = (function()
                local pretty = {}
                for i = 1, #THR.SOUND_CHOICES do
                    pretty[i] = THR.GetSoundDisplayName(THR.SOUND_CHOICES[i])
                end
                return pretty
            end)(),
            choicesValues = THR.SOUND_CHOICES,
            getFunc = function() return THR.SV.alerts.soundName end,
            setFunc = function(value)
                THR.SV.alerts.soundName = value
                THR.PlayAlertSound()
            end,
            disabled = function() return not THR.SV.alerts.sound end,
            default = THR.default.alerts.soundName,
            width = "half",
        },
        {
            type = "button",
            name = "Preview sound",
            func = function() THR.PlayAlertSound() end,
            disabled = function() return not THR.SV.alerts.sound end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Tracker frame",
            tooltip = "Show a movable frame with live boss HP and the next threshold.",
            getFunc = function() return THR.SV.alerts.frame end,
            setFunc = function(value)
                THR.SV.alerts.frame = value
                THR.RefreshDisplayVisibility()
            end,
            default = THR.default.alerts.frame,
        },
        {
            type = "checkbox",
            name = "Show tracker out of combat",
            getFunc = function() return THR.SV.frame.showOutOfCombat end,
            setFunc = function(value)
                THR.SV.frame.showOutOfCombat = value
                THR.RefreshDisplayVisibility()
            end,
            disabled = function() return not THR.SV.alerts.frame end,
            default = THR.default.frame.showOutOfCombat,
        },
        {
            type = "slider",
            name = "Tracker font size",
            min = 14,
            max = 32,
            step = 1,
            getFunc = function() return THR.SV.frame.fontSize end,
            setFunc = function(value)
                THR.SV.frame.fontSize = value
                THR.UpdateDisplayFonts()
            end,
            default = THR.default.frame.fontSize,
        },
        {
            type = "button",
            name = "Reset tracker position",
            func = function() THR.ResetFramePosition() end,
        },

        { type = "header", name = "Global default thresholds" },
        {
            type = "description",
            text = "Space or comma separated percent values, e.g. \"90 70 50 25\". Merged into every zone and boss; when a zone or boss defines the same percent, the more specific one wins. Leave empty for no global alerts.",
        },
        {
            type = "editbox",
            name = "Thresholds",
            tooltip = "Existing customized alerts keep their styling when their percent stays in the list.",
            getFunc = function() return THR.FormatThresholds(THR.SV.globalThresholds) end,
            setFunc = function(text)
                local values = THR.ParseThresholdString(text)
                if values then
                    THR.SV.globalThresholds = THR.MergeThresholdPcts(THR.SV.globalThresholds, values)
                elseif not string.match(text or "", "%S") then
                    -- Emptied on purpose: no global defaults. Input with
                    -- content but no valid value (a typo) is ignored.
                    THR.SV.globalThresholds = {}
                else
                    return
                end
                THR.ReapplyThresholds()
                RefreshAlertEditors()
            end,
            isMultiline = false,
            default = THR.FormatThresholds(THR.DEFAULT_GLOBAL_THRESHOLDS),
        },
        {
            type = "submenu",
            name = "Customize alerts (global)",
            controls = globalEditorControls,
        },

        { type = "header", name = "Current zone" },
        {
            type = "description",
            text = function()
                return string.format("Zone: |cFFD700%s|r  (id %d)",
                    THR.GetCleanName(GetZoneNameById(THR.currentZoneId)),
                    THR.currentZoneId)
            end,
        },
        {
            type = "editbox",
            name = "Zone thresholds",
            tooltip = "Extra thresholds for every boss in this zone, merged with the global defaults (the zone wins when both define the same percent). Leave empty to remove them. Existing customized alerts keep their styling when their percent stays in the list.",
            getFunc = function()
                local zone = THR.SV.zones[THR.currentZoneId]
                return THR.FormatThresholds(zone and zone.thresholds)
            end,
            setFunc = function(text)
                local values = THR.ParseThresholdString(text)
                if values then
                    local zone = THR.SV.zones[THR.currentZoneId]
                    THR.GetZoneConfig(THR.currentZoneId, true).thresholds =
                        THR.MergeThresholdPcts(zone and zone.thresholds, values)
                else
                    local zone = THR.SV.zones[THR.currentZoneId]
                    if zone then zone.thresholds = nil end
                    THR.PruneZoneConfig(THR.currentZoneId)
                end
                THR.ReapplyThresholds()
                RefreshAlertEditors()
            end,
            isMultiline = false,
            default = "",
        },
        {
            type = "submenu",
            name = "Customize alerts (this zone)",
            controls = zoneEditorControls,
        },
        {
            type = "dropdown",
            name = "Copy zone thresholds from",
            tooltip = "Only zones with their own zone thresholds are listed. Boss overrides are not copied.",
            choices = {},
            choicesValues = {},
            scrollable = true,
            getFunc = function() return copySourceZoneId end,
            setFunc = function(value) copySourceZoneId = value end,
            reference = "Thresholds_ZoneCopyDropdown",
            width = "half",
        },
        {
            type = "button",
            name = "Copy to this zone",
            tooltip = "Overwrites this zone's own thresholds with the selected zone's (styling included).",
            func = function()
                if not copySourceZoneId then return end
                if THR.Share.CopyZoneThresholds(copySourceZoneId, THR.currentZoneId) then
                    THR.ReapplyThresholds()
                    RefreshAlertEditors()
                    RefreshZoneCopyDropdown()
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", THR.menuPanel)
                end
            end,
            isDangerous = true,
            disabled = function() return copySourceZoneId == nil end,
            width = "half",
        },
        {
            type = "button",
            name = "Clear zone configuration",
            tooltip = "Remove the zone thresholds and all per-boss overrides for this zone.",
            func = function()
                THR.SV.zones[THR.currentZoneId] = nil
                THR.ReapplyThresholds()
                RefreshBossDropdown()
                RefreshAlertEditors()
            end,
            isDangerous = true,
        },
    }

    local perBossControls = {
                {
                    type = "description",
                    text = function() return GetOverrideSummary() end,
                },
                {
                    type = "dropdown",
                    name = "Boss",
                    tooltip = "Bosses currently present in the zone, known bosses of this trial, plus existing overrides.",
                    choices = {},
                    getFunc = function() return menuBossName end,
                    setFunc = function(value)
                        menuBossName = value
                        local zone = THR.SV.zones[THR.currentZoneId]
                        local override = zone and zone.bosses and zone.bosses[value]
                        menuBossThresholdText = THR.FormatThresholds(override)
                        ResetBossEditor()
                        RefreshAlertEditors()
                    end,
                    reference = "Thresholds_BossOverrideDropdown",
                },
                {
                    type = "editbox",
                    name = "Boss name",
                    tooltip = "Type a name manually to configure a boss you are not standing next to.",
                    getFunc = function() return menuBossName end,
                    setFunc = function(text)
                        menuBossName = text
                        ResetBossEditor()
                        RefreshAlertEditors()
                    end,
                    isMultiline = false,
                },
                {
                    type = "editbox",
                    name = "Thresholds for this boss",
                    tooltip = "Existing customized alerts keep their styling when their percent stays in the list.",
                    getFunc = function() return menuBossThresholdText end,
                    setFunc = function(text) menuBossThresholdText = text end,
                    isMultiline = false,
                },
                {
                    type = "button",
                    name = "Add / Update",
                    func = function()
                        local name = THR.GetCleanName(menuBossName or "")
                        local values = THR.ParseThresholdString(menuBossThresholdText)
                        if name == "" or not values then
                            d("|c66CCFFThresholds:|r enter a boss name and at least one percent value between 0 and 100.")
                            return
                        end
                        local zone = THR.GetZoneConfig(THR.currentZoneId, true)
                        zone.bosses = zone.bosses or {}
                        zone.bosses[name] = THR.MergeThresholdPcts(zone.bosses[name], values)
                        menuBossName = name
                        menuBossThresholdText = THR.FormatThresholds(zone.bosses[name])
                        THR.ReapplyThresholds()
                        RefreshBossDropdown()
                        RefreshAlertEditors()
                    end,
                    width = "half",
                },
                {
                    type = "button",
                    name = "Remove",
                    func = function()
                        local name = THR.GetCleanName(menuBossName or "")
                        local zone = THR.SV.zones[THR.currentZoneId]
                        if zone and zone.bosses and zone.bosses[name] then
                            zone.bosses[name] = nil
                            if next(zone.bosses) == nil then zone.bosses = nil end
                            THR.PruneZoneConfig(THR.currentZoneId)
                            THR.ReapplyThresholds()
                            RefreshBossDropdown()
                        end
                        menuBossThresholdText = ""
                        ResetBossEditor()
                        RefreshAlertEditors()
                    end,
                    width = "half",
                },

                { type = "divider" },
                {
                    type = "description",
                    text = "Customize the selected boss's individual alerts:",
                },
    }
    for i = 1, #bossEditorControls do
        perBossControls[#perBossControls + 1] = bossEditorControls[i]
    end
    optionsData[#optionsData + 1] = {
        type = "submenu",
        name = "Per-boss overrides (this zone)",
        controls = perBossControls,
    }

    optionsData[#optionsData + 1] = {
        type = "submenu",
        name = "Import / Export",
        controls = {
            {
                type = "description",
                text = "Share threshold setups as text strings. Generate a string and copy it with Ctrl+C, or paste a received string below and press Import. Boss names are language-specific: strings made on another client language will not match your bosses.",
            },
            {
                type = "dropdown",
                name = "Export scope",
                choices = { "Current zone", "Selected boss (per-boss submenu)", "Global defaults", "Full profile" },
                choicesValues = { "ZONE", "BOSS", "GLOBAL", "ALL" },
                getFunc = function() return shareExportScope end,
                setFunc = function(value) shareExportScope = value end,
                width = "half",
            },
            {
                type = "button",
                name = "Generate export string",
                func = GenerateExport,
                width = "half",
            },
            {
                type = "editbox",
                name = "Export string",
                tooltip = "Select the text (Ctrl+A) and copy it (Ctrl+C).",
                isMultiline = true,
                isExtraWide = true,
                getFunc = function() return shareExportText end,
                setFunc = function(text) shareExportText = text end,
                reference = "Thresholds_ShareExportBox",
            },
            { type = "divider" },
            {
                type = "editbox",
                name = "Import string",
                tooltip = "Paste an export string here, then press Import.",
                isMultiline = true,
                isExtraWide = true,
                getFunc = function() return shareImportText end,
                setFunc = function(text) shareImportText = text end,
                reference = "Thresholds_ShareImportBox",
            },
            {
                type = "button",
                name = "Import...",
                func = DoImport,
            },
        },
    }

    THR.menuPanel = LAM2:RegisterAddonPanel(panelName, panelData)
    LAM2:RegisterOptionControls(panelName, optionsData)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
        if panel ~= THR.menuPanel then return end
        -- Editboxes default to a low input limit; export strings are long.
        if Thresholds_ShareExportBox and Thresholds_ShareExportBox.editbox then
            Thresholds_ShareExportBox.editbox:SetMaxInputChars(MAX_SHARE_CHARS)
        end
        if Thresholds_ShareImportBox and Thresholds_ShareImportBox.editbox then
            Thresholds_ShareImportBox.editbox:SetMaxInputChars(MAX_SHARE_CHARS)
        end
    end)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel ~= THR.menuPanel then return end
        THR.previewMode = true
        RefreshBossDropdown()
        RefreshAlertEditors()
        RefreshZoneCopyDropdown()
        THR.RefreshDisplay()
    end)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel ~= THR.menuPanel then return end
        THR.previewMode = false
        THR.EndAlertPositioning()
        THR.RefreshDisplay()
    end)
end
