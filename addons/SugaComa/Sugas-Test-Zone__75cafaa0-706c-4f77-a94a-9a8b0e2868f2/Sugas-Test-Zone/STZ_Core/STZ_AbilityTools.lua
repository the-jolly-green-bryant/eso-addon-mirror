local STZ = SUGAS_TEST_ZONE
STZ.AbilityTools = STZ.AbilityTools or {}
local AbilityTools = STZ.AbilityTools

local EVENT_NAMESPACE = "Sugas-Test-Zone_AbilityMonitor"
local DUPLICATE_WINDOW_MS = 500
local MAX_CAPTURE_RECORDS = 40
local MAX_EXPORT_URL_BYTES = 1900
local DEFAULT_MONITOR_MODE = "focused"
local DEFAULT_EXPORT_PARAMETER = "data"

local MONITOR_MODE_ITEMS = {
    { name = "Focused - player button presses", data = "focused" },
    { name = "Raw - all player combat events", data = "raw" },
}

local ALLOWED_EXPORT_PREFIXES = {
    "https://script.google.com/macros/s/",
    "https://docs.google.com/forms/d/e/",
}

local function Toast(message, negative)
    local soundId = SOUNDS and negative and SOUNDS.NEGATIVE_CLICK or nil
    if type(ZO_Alert) == "function" then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, soundId, tostring(message or ""))
    else
        STZ:Log("[STZ] " .. tostring(message or ""))
    end
end

local function Report(message, negative)
    Toast(message, negative)
    STZ:Log("[STZ Ability] " .. tostring(message or ""))
end

local function Trim(value)
    return tostring(value or ""):match("^%s*(.-)%s*$") or ""
end

local function NormaliseId(value)
    local abilityId = tonumber(value)
    if abilityId == nil then return nil end
    abilityId = math.floor(abilityId)
    if abilityId <= 0 then return nil end
    return abilityId
end

local function IsTracked(abilityId)
    return type(LibCombatSkills) == "table"
        and type(LibCombatSkills.IsTracked) == "function"
        and LibCombatSkills:IsTracked(abilityId) == true
end

local function GetNowMilliseconds()
    return type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds() or 0
end

local function GetNowTimestamp()
    return type(GetTimeStamp) == "function" and tonumber(GetTimeStamp()) or 0
end

local function GetMonitorModeName(mode)
    for _, item in ipairs(MONITOR_MODE_ITEMS) do
        if item.data == mode then return item.name end
    end
    return MONITOR_MODE_ITEMS[1].name
end

local function ResolveMonitorMode(item, name)
    if type(item) == "table" and item.data ~= nil then
        return tostring(item.data)
    end
    local selectedName = tostring(name or "")
    for _, candidate in ipairs(MONITOR_MODE_ITEMS) do
        if candidate.name == selectedName then return candidate.data end
    end
    return DEFAULT_MONITOR_MODE
end

local function JsonEscape(value)
    local text = tostring(value or "")
    text = text:gsub("\\", "\\\\")
    text = text:gsub('"', '\\"')
    text = text:gsub("\b", "\\b")
    text = text:gsub("\f", "\\f")
    text = text:gsub("\n", "\\n")
    text = text:gsub("\r", "\\r")
    text = text:gsub("\t", "\\t")
    text = text:gsub("[%z\1-\31]", function(character)
        return string.format("\\u%04X", string.byte(character))
    end)
    return text
end

local function UrlEncode(value)
    local encoded = tostring(value or ""):gsub("([^%w%-_%.~])", function(character)
        return string.format("%%%02X", string.byte(character))
    end)
    return encoded
end

local function IsAllowedExportUrl(url)
    local lowerUrl = string.lower(tostring(url or ""))
    if lowerUrl:find("#", 1, true) then return false end

    local endpointPath = lowerUrl:match("^([^?]+)") or ""
    if lowerUrl:sub(1, #ALLOWED_EXPORT_PREFIXES[1]) == ALLOWED_EXPORT_PREFIXES[1] then
        return endpointPath:sub(-5) == "/exec"
    end
    if lowerUrl:sub(1, #ALLOWED_EXPORT_PREFIXES[2]) == ALLOWED_EXPORT_PREFIXES[2] then
        return endpointPath:sub(-13) == "/formresponse"
    end
    return false
end

local function AppendQueryParameter(endpoint, parameterName, payload)
    local separator = "?"
    local finalCharacter = endpoint:sub(-1)
    if finalCharacter == "?" or finalCharacter == "&" then
        separator = ""
    elseif endpoint:find("?", 1, true) then
        separator = "&"
    end
    return endpoint .. separator .. UrlEncode(parameterName) .. "=" .. UrlEncode(payload)
end

function AbilityTools:SetLookupId(value)
    local text = tostring(value or ""):gsub("[^0-9]", "")
    self.lookupId = text
    if STZ.sv then STZ.sv.abilityLookupId = text end
end

function AbilityTools:SetExportUrl(value)
    self.exportUrl = Trim(value)
    if STZ.sv then STZ.sv.abilityExportUrl = self.exportUrl end
end

function AbilityTools:SetExportParameter(value)
    local text = Trim(value):gsub("[^%w%._%-]", "")
    if text == "" then text = DEFAULT_EXPORT_PARAMETER end
    self.exportParameter = text
    if STZ.sv then STZ.sv.abilityExportParameter = text end
end

function AbilityTools:AddCaptureRecord(kind, abilityId, abilityName, source, actionSlotIndex, actionResult)
    local record = {
        kind = tostring(kind or "trace"),
        abilityId = abilityId,
        abilityName = tostring(abilityName or ""),
        tracked = IsTracked(abilityId),
        source = tostring(source or self.monitorMode or DEFAULT_MONITOR_MODE),
        capturedAt = GetNowTimestamp(),
        actionSlotIndex = tonumber(actionSlotIndex),
        actionResult = tonumber(actionResult),
    }

    if #self.captureRecords >= MAX_CAPTURE_RECORDS then
        table.remove(self.captureRecords, 1)
    end
    self.captureRecords[#self.captureRecords + 1] = record
end

function AbilityTools:ClearCapture(silent)
    self.captureRecords = {}
    self.lastPrintedAtById = {}
    self.printedCount = 0
    self.suppressedCount = 0
    if not silent then Report("Captured ability results cleared.", false) end
end

function AbilityTools:Lookup(value)
    local abilityId = NormaliseId(value or self.lookupId)
    if abilityId == nil then
        Report("Enter an ability ID first.", true)
        return false
    end

    self:SetLookupId(abilityId)
    local name = type(GetAbilityName) == "function" and tostring(GetAbilityName(abilityId) or "") or ""
    if name == "" then
        Report(string.format("No ability found for ID %d.", abilityId), true)
        return false
    end

    local libraryText = "LibCombatSkills: not loaded"
    if type(LibCombatSkills) == "table" and type(LibCombatSkills.IsTracked) == "function" then
        if IsTracked(abilityId) then
            libraryText = string.format(
                "LibCombatSkills: tracked as %s (%.1fs)",
                tostring(LibCombatSkills:GetName(abilityId) or name),
                tonumber(LibCombatSkills:GetDuration(abilityId)) or 0
            )
        else
            libraryText = "LibCombatSkills: not tracked"
        end
    end

    self:AddCaptureRecord("lookup", abilityId, name, "lookup")
    Report(string.format("%s | ID %d | %s", name, abilityId, libraryText), false)
    return true
end

function AbilityTools:ShouldSuppressDuplicate(abilityId)
    local now = GetNowMilliseconds()
    local lastPrintedAt = self.lastPrintedAtById[abilityId]
    if lastPrintedAt ~= nil and now - lastPrintedAt < DUPLICATE_WINDOW_MS then
        return true
    end
    self.lastPrintedAtById[abilityId] = now
    return false
end

function AbilityTools:PublishTrace(abilityId, abilityName, source, actionSlotIndex, actionResult)
    if self:ShouldSuppressDuplicate(abilityId) then
        self.suppressedCount = self.suppressedCount + 1
        return
    end

    local tracked = IsTracked(abilityId)
    self.printedCount = self.printedCount + 1
    self:AddCaptureRecord("trace", abilityId, abilityName, source, actionSlotIndex, actionResult)
    STZ:Log(string.format(
        "[STZ Ability] %s | ID %d | %s | %s",
        abilityName,
        abilityId,
        tracked and "tracked" or "not tracked",
        source
    ))
end

function AbilityTools:OnActionSlotAbilityUsed(_, actionSlotIndex)
    if not self.monitorEnabled or self.monitorMode ~= "focused" then return end
    if type(GetSlotBoundId) ~= "function" then return end

    local actionId = NormaliseId(GetSlotBoundId(actionSlotIndex))
    if actionId == nil then return end

    local abilityId = actionId
    if type(GetSlotType) == "function"
        and GetSlotType(actionSlotIndex) == ACTION_TYPE_CRAFTED_ABILITY
        and type(GetAbilityIdForCraftedAbilityId) == "function"
    then
        abilityId = NormaliseId(GetAbilityIdForCraftedAbilityId(actionId))
    end
    if abilityId == nil then return end

    local name = type(GetSlotName) == "function" and tostring(GetSlotName(actionSlotIndex) or "") or ""
    if name == "" and type(GetAbilityName) == "function" then
        name = tostring(GetAbilityName(abilityId) or "")
    end
    if name == "" then return end

    self:PublishTrace(abilityId, name, "focused", actionSlotIndex, nil)
end

function AbilityTools:OnCombatEvent(_, actionResult, isError, abilityName, _, _, _, sourceType, _, _, _, _, _, _, _, _, abilityId)
    if not self.monitorEnabled or self.monitorMode ~= "raw" then return end
    if isError or sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    local id = NormaliseId(abilityId)
    local name = tostring(abilityName or "")
    if id == nil or name == "" then return end

    self:PublishTrace(id, name, "raw", nil, actionResult)
end

function AbilityTools:UnregisterMonitorEvents()
    if EVENT_MANAGER == nil or type(EVENT_MANAGER.UnregisterForEvent) ~= "function" then return end
    if EVENT_ACTION_SLOT_ABILITY_USED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_SLOT_ABILITY_USED)
    end
    if EVENT_COMBAT_EVENT ~= nil then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_COMBAT_EVENT)
    end
end

function AbilityTools:RegisterMonitorEvent()
    self:UnregisterMonitorEvents()
    if not self.monitorEnabled then return true end
    if EVENT_MANAGER == nil or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then return false end

    if self.monitorMode == "focused" then
        if EVENT_ACTION_SLOT_ABILITY_USED == nil then return false end
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_SLOT_ABILITY_USED, function(...)
            self:OnActionSlotAbilityUsed(...)
        end)
        return true
    end

    if EVENT_COMBAT_EVENT == nil then return false end
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_COMBAT_EVENT, function(...)
        self:OnCombatEvent(...)
    end)
    if type(EVENT_MANAGER.AddFilterForEvent) == "function" then
        EVENT_MANAGER:AddFilterForEvent(
            EVENT_NAMESPACE,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )
    end
    return true
end

function AbilityTools:SetMonitorMode(mode)
    local wantedMode = tostring(mode or DEFAULT_MONITOR_MODE)
    if wantedMode ~= "focused" and wantedMode ~= "raw" then
        wantedMode = DEFAULT_MONITOR_MODE
    end

    self.monitorMode = wantedMode
    if STZ.sv then STZ.sv.abilityMonitorMode = wantedMode end

    if self.monitorEnabled then
        if not self:RegisterMonitorEvent() then
            self.monitorEnabled = false
            if STZ.sv then STZ.sv.abilityMonitorEnabled = false end
            Report("The selected monitor event is unavailable on this API version.", true)
            return false
        end
        STZ:Log(string.format("[STZ Ability] Monitor mode changed to %s.", wantedMode))
    end
    return true
end

function AbilityTools:SetMonitorEnabled(enabled)
    self.monitorEnabled = enabled == true
    if STZ.sv then STZ.sv.abilityMonitorEnabled = self.monitorEnabled end

    if not self:RegisterMonitorEvent() then
        self.monitorEnabled = false
        if STZ.sv then STZ.sv.abilityMonitorEnabled = false end
        Report("Ability monitoring is unavailable on this API version.", true)
        return false
    end

    if self.monitorEnabled then
        if self.monitorMode == "focused" then
            STZ:Log("[STZ Ability] Monitor ON (focused). Only direct player ability activations are printed.")
        else
            STZ:Log("[STZ Ability] Monitor ON (raw). All player combat events may be printed.")
        end
    else
        STZ:Log(string.format(
            "[STZ Ability] Monitor OFF. Printed %d; duplicate events suppressed %d.",
            self.printedCount,
            self.suppressedCount
        ))
    end
    return true
end

function AbilityTools:BuildExportPayload(recordCount)
    local firstRecord = #self.captureRecords - recordCount + 1
    local parts = {
        '{"schema":"stz-ability-trace/1"',
        ',"addonVersion":"', JsonEscape(STZ.Config and STZ.Config.version or "unknown"), '"',
        ',"monitorMode":"', JsonEscape(self.monitorMode), '"',
        ',"recordCount":', tostring(recordCount),
        ',"records":[',
    }

    for index = firstRecord, #self.captureRecords do
        local record = self.captureRecords[index]
        if index > firstRecord then parts[#parts + 1] = "," end
        parts[#parts + 1] = '{"kind":"'
        parts[#parts + 1] = JsonEscape(record.kind)
        parts[#parts + 1] = '","abilityId":'
        parts[#parts + 1] = tostring(record.abilityId)
        parts[#parts + 1] = ',"abilityName":"'
        parts[#parts + 1] = JsonEscape(record.abilityName)
        parts[#parts + 1] = '","tracked":'
        parts[#parts + 1] = record.tracked and "true" or "false"
        parts[#parts + 1] = ',"source":"'
        parts[#parts + 1] = JsonEscape(record.source)
        parts[#parts + 1] = '","capturedAt":'
        parts[#parts + 1] = tostring(record.capturedAt or 0)
        if record.actionSlotIndex ~= nil then
            parts[#parts + 1] = ',"actionSlotIndex":'
            parts[#parts + 1] = tostring(record.actionSlotIndex)
        end
        if record.actionResult ~= nil then
            parts[#parts + 1] = ',"actionResult":'
            parts[#parts + 1] = tostring(record.actionResult)
        end
        parts[#parts + 1] = "}"
    end

    parts[#parts + 1] = "]}"
    return table.concat(parts)
end

function AbilityTools:ExportCapture()
    if #self.captureRecords == 0 then
        Report("No captured ability results to export.", true)
        return false
    end
    if type(RequestOpenUnsafeURL) ~= "function" then
        Report("RequestOpenUnsafeURL is unavailable on this client.", true)
        return false
    end

    local endpoint = Trim(self.exportUrl)
    if not IsAllowedExportUrl(endpoint) then
        Report("Enter a Google Apps Script /exec or Google Forms /formResponse HTTPS URL.", true)
        return false
    end

    local parameterName = Trim(self.exportParameter)
    if parameterName == "" then parameterName = DEFAULT_EXPORT_PARAMETER end

    local totalRecords = #self.captureRecords
    for recordCount = totalRecords, 1, -1 do
        local payload = self:BuildExportPayload(recordCount)
        local url = AppendQueryParameter(endpoint, parameterName, payload)
        if #url <= MAX_EXPORT_URL_BYTES then
            Report(string.format(
                "Opening export for %d of %d captured result%s%s",
                recordCount,
                totalRecords,
                totalRecords == 1 and "" or "s",
                recordCount < totalRecords and " (oldest omitted to fit URL limit)." or "."
            ), false)
            RequestOpenUnsafeURL(url)
            return true
        end
    end

    Report("The endpoint and one result exceed the safe 1900-byte URL limit.", true)
    return false
end

function AbilityTools:AddSettings(settings, lib)
    if lib.ST_SECTION then
        settings:AddSetting({ type = lib.ST_SECTION, label = "Ability tools" })
    end

    settings:AddSetting({
        type = lib.ST_CHECKBOX,
        label = "Print used ability IDs",
        tooltip = "Focused mode prints direct player button activations only. Duplicate activations within 0.5 seconds are suppressed.",
        default = false,
        getFunction = function() return self.monitorEnabled == true end,
        setFunction = function(value) self:SetMonitorEnabled(value) end,
    })

    if lib.ST_DROPDOWN then
        settings:AddSetting({
            type = lib.ST_DROPDOWN,
            label = "Ability monitor mode",
            tooltip = "Focused suppresses buffs, debuffs, passives and procs by listening only for direct action-slot activations. Raw restores the broad combat-event diagnostic feed.",
            items = MONITOR_MODE_ITEMS,
            getFunction = function() return GetMonitorModeName(self.monitorMode) end,
            setFunction = function(_, name, item)
                self:SetMonitorMode(ResolveMonitorMode(item, name))
            end,
        })
    end

    if lib.ST_EDIT then
        settings:AddSetting({
            type = lib.ST_EDIT,
            label = "Ability ID",
            tooltip = "Enter a numeric ability ID, then select Run ability check underneath.",
            getFunction = function() return tostring(self.lookupId or "") end,
            setFunction = function(value) self:SetLookupId(value) end,
        })
    end

    settings:AddSetting({
        type = lib.ST_BUTTON,
        label = "Run ability check",
        buttonText = "Run",
        tooltip = "Looks up the entered ID. The result appears as a toast, is retained in chat and is added to the export capture.",
        clickHandler = function()
            self:Lookup()
        end,
    })

    if lib.ST_EDIT then
        settings:AddSetting({
            type = lib.ST_EDIT,
            label = "Google export URL",
            tooltip = "Google Apps Script /exec or Google Forms /formResponse endpoint. STZ never opens it automatically.",
            getFunction = function() return tostring(self.exportUrl or "") end,
            setFunction = function(value) self:SetExportUrl(value) end,
        })

        settings:AddSetting({
            type = lib.ST_EDIT,
            label = "Export parameter",
            tooltip = "Use data for the Apps Script prototype, or entry.NUMBER for a Google Form short-answer field.",
            getFunction = function() return tostring(self.exportParameter or DEFAULT_EXPORT_PARAMETER) end,
            setFunction = function(value) self:SetExportParameter(value) end,
        })
    end

    settings:AddSetting({
        type = lib.ST_BUTTON,
        label = "Export captured ability data",
        buttonText = "Export",
        tooltip = "User-triggered only. Opens a confirmation URL containing the newest captured results that fit the 1900-byte safety limit.",
        clickHandler = function()
            self:ExportCapture()
        end,
    })

    settings:AddSetting({
        type = lib.ST_BUTTON,
        label = "Clear captured ability data",
        buttonText = "Clear",
        tooltip = "Clears the in-memory trace and lookup export buffer.",
        clickHandler = function()
            self:ClearCapture(false)
        end,
    })
end

function AbilityTools:Initialize()
    self.lookupId = tostring(STZ.sv and STZ.sv.abilityLookupId or "")
    self.exportUrl = tostring(STZ.sv and STZ.sv.abilityExportUrl or "")
    self.exportParameter = tostring(STZ.sv and STZ.sv.abilityExportParameter or DEFAULT_EXPORT_PARAMETER)
    self.monitorMode = tostring(STZ.sv and STZ.sv.abilityMonitorMode or DEFAULT_MONITOR_MODE)
    if self.monitorMode ~= "focused" and self.monitorMode ~= "raw" then
        self.monitorMode = DEFAULT_MONITOR_MODE
    end
    self.monitorEnabled = false
    self:ClearCapture(true)

    if type(SLASH_COMMANDS) == "table" then
        SLASH_COMMANDS["/stzability"] = function(argument)
            self:Lookup(argument)
        end
        SLASH_COMMANDS["/stzabilitymonitor"] = function(argument)
            local value = string.lower(tostring(argument or ""))
            self:SetMonitorEnabled(value == "on" or value == "1" or value == "true")
        end
        SLASH_COMMANDS["/stzabilitymode"] = function(argument)
            self:SetMonitorMode(string.lower(Trim(argument)))
        end
        SLASH_COMMANDS["/stzabilityexport"] = function()
            self:ExportCapture()
        end
        SLASH_COMMANDS["/stzabilityclear"] = function()
            self:ClearCapture(false)
        end
    end

    if STZ.sv and STZ.sv.abilityMonitorEnabled == true then
        self:SetMonitorEnabled(true)
    end
end
