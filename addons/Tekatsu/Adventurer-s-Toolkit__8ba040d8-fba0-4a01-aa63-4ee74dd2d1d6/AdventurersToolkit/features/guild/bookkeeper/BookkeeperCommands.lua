-- ============================================
-- BOOKKEEPER COMMAND AND ACTION HANDLERS
-- ============================================
-- Scan, note, history, listings, demotion, export. Uses NWT.BookkeeperData_* for data access.

local GetGuildSettings = NWT.BookkeeperData_GetGuildSettings
local IsGuildEnabled = NWT.BookkeeperData_IsGuildEnabled
local IsGuildFavorite = NWT.BookkeeperData_IsGuildFavorite
local IsRankExempt = NWT.BookkeeperData_IsRankExempt
local IsFreeTraderMode = NWT.BookkeeperData_IsFreeTraderMode
local GetListingTarget = NWT.BookkeeperData_GetListingTarget
local GetDemoSettings = NWT.BookkeeperData_GetDemoSettings
local GetCurrentTraderFlipStart = NWT.BookkeeperData_GetCurrentTraderFlipStart
local NormalizeDisplayName = NWT.BookkeeperData_NormalizeDisplayName
local ParseDepositType = NWT.BookkeeperData_ParseDepositType
local ParseDueDateFromNote = NWT.BookkeeperData_ParseDueDateFromNote
local ParsePaymentDateFromNote = NWT.BookkeeperData_ParsePaymentDateFromNote
local GetLastNoteUpdate = NWT.BookkeeperData_GetLastNoteUpdate
local SetLastNoteUpdate = NWT.BookkeeperData_SetLastNoteUpdate
local GetSavedDueDate = NWT.BookkeeperData_GetSavedDueDate
local SetSavedDueDate = NWT.BookkeeperData_SetSavedDueDate
local GetDepositsSince = NWT.BookkeeperData_GetDepositsSince
local CalculateNewDueDate = NWT.BookkeeperData_CalculateNewDueDate
local FormatDuesNote = NWT.BookkeeperData_FormatDuesNote

local BC = NWT.BookkeeperConstants
local DEMO_GUILDS = BC and BC.DEMO_GUILDS or {}

local BOOKKEEPER_LISTINGS_SCAN_EVENT = "ATK_BOOKKEEPER_LISTINGS_SCAN_EVENT"
local BOOKKEEPER_TRADER_OPEN_EVENT = "ATK_BOOKKEEPER_TRADER_OPEN_EVENT"
local BOOKKEEPER_TRADER_CLOSE_EVENT = "ATK_BOOKKEEPER_TRADER_CLOSE_EVENT"
local BOOKKEEPER_TRADER_GUILD_CHANGE_EVENT = "ATK_BOOKKEEPER_TRADER_GUILD_CHANGE_EVENT"
local LISTINGS_PAGE_DELAY_MS = 300
local LISTINGS_SCAN_COOLDOWN_SEC = 60
local LISTINGS_FAILURE_BACKOFF_SEC = 30

local FinalizeBookkeeperListingsScan

local function UpdateBookkeeperTradingHouseKeybind()
    if not KEYBIND_STRIP or not NWT.BookkeeperTradingHouseKeybindGroup then return end
    KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.BookkeeperTradingHouseKeybindGroup)
end

local function RemoveBookkeeperTradingHouseKeybinds()
    if NWT.bookkeeperTradingHouseKeybindsAdded and KEYBIND_STRIP and NWT.BookkeeperTradingHouseKeybindGroup then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.BookkeeperTradingHouseKeybindGroup)
    end
    NWT.bookkeeperTradingHouseKeybindsAdded = false
end

local function AddBookkeeperTradingHouseKeybinds()
    if not KEYBIND_STRIP then return end
    if NWT.bookkeeperTradingHouseKeybindsAdded then
        UpdateBookkeeperTradingHouseKeybind()
        return
    end
    if not NWT.BookkeeperTradingHouseKeybindGroup then
        NWT.BookkeeperTradingHouseKeybindGroup = {
            {
                alignment = KEYBIND_STRIP_ALIGN_LEFT,
                name = function()
                    local guildId = GetSelectedTradingHouseGuildId and GetSelectedTradingHouseGuildId() or 0
                    if guildId <= 0 then return "Scan Listings" end
                    local gs = GetGuildSettings(guildId)
                    if gs.listingsScanInProgress then return "Scanning..." end
                    if gs.freeTraderMode then return "Scan Listings" end
                    return "Free Trader Off"
                end,
                keybind = "UI_SHORTCUT_LEFT_STICK",
                callback = function()
                    local guildId = GetSelectedTradingHouseGuildId and GetSelectedTradingHouseGuildId() or 0
                    if guildId <= 0 then PlaySound(SOUNDS.NEGATIVE_CLICK); return end
                    local gs = GetGuildSettings(guildId)
                    if not gs.freeTraderMode then
                        NWT.Debug("|cFFFF00[Bookkeeper]|r Free Trader mode is off for " .. (GetGuildName(guildId) or ("Guild " .. tostring(guildId))) .. ".")
                        PlaySound(SOUNDS.NEGATIVE_CLICK)
                        UpdateBookkeeperTradingHouseKeybind()
                        return
                    end
                    NWT.BookkeeperScanGuildListings(guildId)
                    UpdateBookkeeperTradingHouseKeybind()
                end,
                enabled = function()
                    if not GetInteractionType or not INTERACTION_TRADINGHOUSE then return false end
                    return GetInteractionType() == INTERACTION_TRADINGHOUSE
                end,
            },
        }
    end
    KEYBIND_STRIP:AddKeybindButtonGroup(NWT.BookkeeperTradingHouseKeybindGroup)
    NWT.bookkeeperTradingHouseKeybindsAdded = true
    UpdateBookkeeperTradingHouseKeybind()
end

function NWT.BookkeeperScanPaymentNotes(guildId)
    local gs = GetGuildSettings(guildId)
    local guildName = GetGuildName(guildId) or ("Guild " .. guildId)
    local numMembers = GetNumGuildMembers(guildId)
    local paymentHistory = {}
    local foundCount = 0
    local currentTime = GetTimeStamp()
    local currentDate = GetDate()
    local currentYear = tonumber(tostring(currentDate):sub(1, 4)) or 2026
    local batchSize = 10
    local timeBudgetMs = 12
    local index = 1

    local function processBatch()
        local startTime = GetFrameTimeMilliseconds()
        for _ = 1, batchSize do
            if index > numMembers then break end
            local name, note, rankIndex = GetGuildMemberInfo(guildId, index)
            index = index + 1
            if name and note and note ~= "" then
                local parsed = ParsePaymentDateFromNote(note)
                if parsed then
                    foundCount = foundCount + 1
                    if not paymentHistory[name] then
                        paymentHistory[name] = { payments = {}, rankIndex = rankIndex, isLifetime = false }
                    end
                    if parsed.isLifetime then
                        paymentHistory[name].isLifetime = true
                        if not gs.lifetimeMembers then gs.lifetimeMembers = {} end
                        gs.lifetimeMembers[name] = true
                    end
                    local record = { scanTime = currentTime, rawNote = note }
                    if parsed.paidDate then
                        record.paidMonth = parsed.paidDate.month
                        record.paidDay = parsed.paidDate.day
                        record.paidYear = parsed.paidDate.year or currentYear
                    end
                    if parsed.dueDate then
                        record.dueMonth = parsed.dueDate.month
                        record.dueDay = parsed.dueDate.day
                        record.dueYear = parsed.dueDate.year or currentYear
                    end
                    local isDuplicate = false
                    for _, existing in ipairs(paymentHistory[name].payments) do
                        if existing.paidMonth == record.paidMonth and existing.paidDay == record.paidDay and existing.dueMonth == record.dueMonth and existing.dueDay == record.dueDay then
                            isDuplicate = true
                            break
                        end
                    end
                    if not isDuplicate and (record.paidMonth or record.dueMonth) then
                        table.insert(paymentHistory[name].payments, record)
                    end
                end
            end
            if (GetFrameTimeMilliseconds() - startTime) >= timeBudgetMs then break end
        end
        if index <= numMembers then
            zo_callLater(processBatch, 10)
        else
            if gs.paymentHistory then
                for name, data in pairs(gs.paymentHistory) do
                    if not paymentHistory[name] then paymentHistory[name] = data
                    else
                        for _, oldRecord in ipairs(data.payments or {}) do
                            local isDuplicate = false
                            for _, newRecord in ipairs(paymentHistory[name].payments) do
                                if oldRecord.paidMonth == newRecord.paidMonth and oldRecord.paidDay == newRecord.paidDay and oldRecord.dueMonth == newRecord.dueMonth and oldRecord.dueDay == newRecord.dueDay then
                                    isDuplicate = true
                                    break
                                end
                            end
                            if not isDuplicate then table.insert(paymentHistory[name].payments, oldRecord) end
                        end
                    end
                end
            end
            gs.paymentHistory = paymentHistory
            gs.lastNotesScan = currentTime
            PlaySound(SOUNDS.POSITIVE_CLICK)
            if NWT.Bookkeeper.duesSettingsOpen then NWT.UpdateDuesSettingsDialog()
            elseif NWT.Bookkeeper.settingsMenuOpen then NWT.UpdateSettingsDialog()
            end
            NWT.BuildBookkeeperMemberList(guildId)
            NWT.UpdateBookkeeperUI()
            NWT.SyncHiddenBookkeeperList()
        end
    end
    processBatch()
end

function NWT.BookkeeperRepairNotes(guildId)
    local gs = GetGuildSettings(guildId)
    if not gs or not gs.memberPayments then return end
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT) then return end
    local numMembers = GetNumGuildMembers(guildId)
    local now = GetTimeStamp()
    local thirtyDaysAgo = now - (30 * 24 * 60 * 60)
    for i = 1, numMembers do
        local displayName, currentNote, rankIndex = GetGuildMemberInfo(guildId, i)
        if displayName and currentNote and currentNote ~= "" then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            local parsedNote = ParseDueDateFromNote(currentNote, gs)
            if parsedNote and parsedNote.startDate and parsedNote.startDate < thirtyDaysAgo then
                local memberData = gs.memberPayments[displayName]
                if memberData and memberData.deposits and #memberData.deposits > 0 then
                    local earliestDeposit = now
                    for _, dep in ipairs(memberData.deposits) do
                        if dep.timestamp and dep.timestamp > 0 and dep.timestamp < earliestDeposit then earliestDeposit = dep.timestamp end
                    end
                    if earliestDeposit < now and earliestDeposit > thirtyDaysAgo then
                        local newNote = FormatDuesNote(earliestDeposit, parsedNote.endDate, currentNote, gs)
                        if newNote ~= currentNote then
                            SetGuildMemberNote(guildId, i, newNote)
                            SetSavedDueDate(guildId, displayName, parsedNote.endDate)
                        end
                    end
                end
            end
        end
    end
end

function NWT.BookkeeperShowNoteFormatInput(guildId)
    local gs = GetGuildSettings(guildId)
    if not gs then return end
    NWT.Bookkeeper.noteFormatGuildId = guildId
    if not NWT.Bookkeeper.noteFormatInputControl then
        local control = WINDOW_MANAGER:CreateTopLevelWindow("ATK_NoteFormatInput")
        control:SetDimensions(600, 300)
        control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        control:SetHidden(true)
        control:SetMouseEnabled(true)
        control:SetMovable(false)
        local bg = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
        bg:SetAnchorFill()
        bg:SetCenterColor(0, 0, 0, 0.9)
        bg:SetEdgeColor(0.6, 0.6, 0.4, 1)
        bg:SetEdgeTexture("", 2, 2, 2, 0)
        local title = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        title:SetFont("ZoFontGamepadBold27")
        title:SetColor(1, 0.84, 0, 1)
        title:SetAnchor(TOP, control, TOP, 0, 20)
        title:SetText("CUSTOM NOTE FORMAT")
        local help = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        help:SetFont("ZoFontGamepad22")
        help:SetColor(0.8, 0.8, 0.8, 1)
        help:SetAnchor(TOP, title, BOTTOM, 0, 10)
        help:SetText("Use placeholders: {START} {END} {UPD}")
        control.helpLabel = help
        local editBg = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_EditBackdrop")
        editBg:SetDimensions(500, 40)
        editBg:SetAnchor(TOP, help, BOTTOM, 0, 20)
        local editbox = WINDOW_MANAGER:CreateControlFromVirtual(nil, editBg, "ZO_DefaultEditForBackdrop")
        editbox:SetAnchor(TOPLEFT, editBg, TOPLEFT, 4, 4)
        editbox:SetAnchor(BOTTOMRIGHT, editBg, BOTTOMRIGHT, -4, -4)
        editbox:SetFont("ZoFontGamepad27")
        editbox:SetMaxInputChars(100)
        editbox:SetVirtualKeyboardType(VIRTUAL_KEYBOARD_TYPE_DEFAULT)
        editbox:SetHandler("OnEnter", function(self)
            local text = self:GetText()
            local gid = NWT.Bookkeeper.noteFormatGuildId
            local settings = GetGuildSettings(gid)
            if settings and text and text ~= "" then settings.customNoteFormat = text; settings.noteFormat = "custom" end
            control:SetHidden(true)
            NWT.UpdateDuesSettingsDialog()
            PlaySound(SOUNDS.POSITIVE_CLICK)
        end)
        local hints = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        hints:SetFont("ZoFontGamepad18")
        hints:SetColor(0.5, 0.5, 0.5, 1)
        hints:SetAnchor(BOTTOM, control, BOTTOM, 0, -50)
        hints:SetText("[Enter] Save  |  [Esc] Cancel")
        control:SetHandler("OnKeyDown", function(self, key)
            if key == KEY_ESCAPE then self:SetHidden(true); PlaySound(SOUNDS.NEGATIVE_CLICK) end
        end)
        NWT.Bookkeeper.noteFormatInputControl = control
    end
    local control = NWT.Bookkeeper.noteFormatInputControl
    control.editbox:SetText(gs.customNoteFormat or "{START}-{END} Upd:{UPD}")
    control:SetHidden(false)
    control.editbox:TakeFocus()
end

function NWT.BookkeeperReformatAllNotes(guildId)
    local gs = GetGuildSettings(guildId)
    if not gs then return end
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT) then return end
    local numMembers = GetNumGuildMembers(guildId)
    local daysPerPeriod = 7
    if gs.duesPeriod == "biweekly" then daysPerPeriod = 14
    elseif gs.duesPeriod == "monthly" then daysPerPeriod = 30
    elseif gs.duesPeriod == "custom" then daysPerPeriod = gs.customDaysPeriod or 7 end
    for i = 1, numMembers do
        local displayName, currentNote, rankIndex = GetGuildMemberInfo(guildId, i)
        if displayName then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            local member = gs.memberPayments and gs.memberPayments[displayName]
            local parsedNote = ParseDueDateFromNote(currentNote or "", gs)
            local startDate, endDate
            if member and (member.duesMonths or 0) > 0 then
                startDate = (parsedNote and parsedNote.startDate) or GetTimeStamp()
                local paidPeriods = member.duesMonths or 0
                endDate = startDate + (paidPeriods * daysPerPeriod * 86400)
            elseif parsedNote and parsedNote.startDate and parsedNote.endDate then
                startDate = parsedNote.startDate
                endDate = parsedNote.endDate
            end
            if startDate and endDate then
                local newNote = FormatDuesNote(startDate, endDate, currentNote or "", gs)
                if newNote ~= currentNote then
                    SetGuildMemberNote(guildId, i, newNote)
                    SetSavedDueDate(guildId, displayName, endDate)
                end
            end
        end
    end
    PlaySound(SOUNDS.POSITIVE_CLICK)
end

local function InitNoteConfirmDialog()
    if ESO_Dialogs["ATK_NOTE_CONFIRM_DIALOG"] then return end
    ESO_Dialogs["ATK_NOTE_CONFIRM_DIALOG"] = {
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
        canQueue = true,
        title = { text = "Update Member Note?" },
        mainText = { text = "<<1>>\n\nCurrent: <<2>>\nNew: <<3>>\n\n<<4>>" },
        buttons = {
            { text = "Confirm", keybind = "DIALOG_PRIMARY", callback = function() NWT.BookkeeperConfirmNoteUpdate() end },
            { text = "Cancel", keybind = "DIALOG_NEGATIVE", callback = function() NWT.BookkeeperCancelNoteUpdate() end },
        },
    }
end

local function ShowConfirmDialog(pending)
    if not NWT.Bookkeeper.confirmShown then
        NWT.Bookkeeper.confirmShown = true
        local CSA = CENTER_SCREEN_ANNOUNCE
        if CSA and CSA.CreateMessageParams then
            local params = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.DIALOG_SHOW)
            params:SetText(string.format("|cFFD700UPDATE NOTE?|r\n%s\n|c888888%s|r → |c00FF00%s|r\n|cFFFF00%sg = %d week(s)|r\n|c00FF00[A] Confirm|r  |cFF0000[B] Cancel|r",
                pending.memberName, pending.currentNote or "(empty)", pending.newNote,
                NWT.FormatGold(pending.duesDeposited), pending.periodsCovered))
            params:SetLifespanMS(10000)
            CSA:DisplayMessage(params)
        end
    end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
    end
end

local function HideConfirmDialog()
    NWT.Bookkeeper.confirmShown = false
end

function NWT.BookkeeperConfirmNoteUpdate()
    local pending = NWT.Bookkeeper.pendingNoteUpdate
    if not pending then return end
    SetGuildMemberNote(pending.guildId, pending.memberIndex, pending.newNote)
    SetLastNoteUpdate(pending.guildId, pending.memberName, GetTimeStamp())
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.Bookkeeper.pendingNoteUpdate = nil
    NWT.Bookkeeper.confirmDialogOpen = false
    HideConfirmDialog()
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperCancelNoteUpdate()
    NWT.Bookkeeper.pendingNoteUpdate = nil
    NWT.Bookkeeper.confirmDialogOpen = false
    HideConfirmDialog()
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperAutoUpdateNotes(guildId)
    local guildSettings = GetGuildSettings(guildId)
    if not guildSettings.autoUpdateNotes then return end
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT) then return end
    local numMembers = GetNumGuildMembers(guildId)
    local duesAmount = guildSettings.duesAmount or 5000
    for i = 1, numMembers do
        local displayName, currentNote, rankIndex = GetGuildMemberInfo(guildId, i)
        if displayName then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            local member = guildSettings.memberPayments and guildSettings.memberPayments[displayName]
            if member and (member.duesTotal or 0) > 0 then
                local parsedNote = ParseDueDateFromNote(currentNote, guildSettings)
                local savedUpdate = GetLastNoteUpdate(guildId, displayName)
                local savedDueDate = GetSavedDueDate(guildId, displayName)
                local hasExistingDate = (parsedNote and (parsedNote.endDate or parsedNote.lastUpdate)) or savedUpdate or savedDueDate
                if hasExistingDate then
                    local noteIsMissing = not parsedNote or not parsedNote.endDate
                    local needsRestoration = noteIsMissing and savedDueDate
                    if needsRestoration then
                        local newStartDate = GetTimeStamp()
                        local newNote = FormatDuesNote(newStartDate, savedDueDate, currentNote, guildSettings)
                        SetGuildMemberNote(guildId, i, newNote)
                        SetLastNoteUpdate(guildId, displayName, GetTimeStamp())
                    else
                        local noteLastUpdate = parsedNote and parsedNote.lastUpdate or 0
                        local savedTs = savedUpdate or 0
                        local countFromTimestamp = math.max(noteLastUpdate, savedTs)
                        local duesDeposited, depositCount = GetDepositsSince(member, countFromTimestamp, guildSettings)
                        if duesDeposited >= duesAmount then
                            local currentEndDate = parsedNote and parsedNote.endDate
                            local newEndDate = CalculateNewDueDate(currentEndDate, duesDeposited, guildSettings)
                            local newStartDate = (parsedNote and parsedNote.startDate) or GetTimeStamp()
                            local newNote = FormatDuesNote(newStartDate, newEndDate, currentNote, guildSettings)
                            SetGuildMemberNote(guildId, i, newNote)
                            SetLastNoteUpdate(guildId, displayName, GetTimeStamp())
                            SetSavedDueDate(guildId, displayName, newEndDate)
                        end
                    end
                end
            end
        end
    end
end

function NWT.BookkeeperUpdateMemberNote()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen or bk.settingsMenuOpen or bk.confirmDialogOpen then return end
    if bk.focusPanel ~= "dues" then return end
    local member = bk.sortedMembers[bk.selectedMemberIndex]
    if not member then return end
    local guildId = GetGuildId(bk.viewingGuildIndex)
    local guildSettings = GetGuildSettings(guildId)
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT) then return end
    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, member.name)
    if not memberIndex then return end
    local _, currentNote = GetGuildMemberInfo(guildId, memberIndex)
    local parsedNote = ParseDueDateFromNote(currentNote, guildSettings)
    local savedDueDate = GetSavedDueDate(guildId, member.name)
    local noteIsMissing = not parsedNote or not parsedNote.endDate
    local needsRestoration = noteIsMissing and savedDueDate
    local newNote
    if needsRestoration then
        local newStartDate = GetTimeStamp()
        newNote = FormatDuesNote(newStartDate, savedDueDate, currentNote, guildSettings)
        SetGuildMemberNote(guildId, memberIndex, newNote)
        SetLastNoteUpdate(guildId, member.name, GetTimeStamp())
    else
        local noteLastUpdate = parsedNote and parsedNote.lastUpdate or 0
        local savedUpdate = GetLastNoteUpdate(guildId, member.name) or 0
        local countFromTimestamp = math.max(noteLastUpdate, savedUpdate)
        local duesDeposited, depositCount = GetDepositsSince(member, countFromTimestamp, guildSettings)
        if duesDeposited <= 0 then return end
        local currentEndDate = parsedNote and parsedNote.endDate
        local newEndDate = CalculateNewDueDate(currentEndDate, duesDeposited, guildSettings)
        local newStartDate = (parsedNote and parsedNote.startDate) or GetTimeStamp()
        newNote = FormatDuesNote(newStartDate, newEndDate, currentNote, guildSettings)
        SetGuildMemberNote(guildId, memberIndex, newNote)
        SetLastNoteUpdate(guildId, member.name, GetTimeStamp())
        SetSavedDueDate(guildId, member.name, newEndDate)
    end
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.BuildBookkeeperMemberList(guildId)
    NWT.UpdateBookkeeperUI()
end

function NWT.ScanAllGuildTraderHistory()
    if NWT.Bookkeeper.isHistoryScanning then return end
    local enabledGuilds = {}
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        if guildId and IsGuildEnabled(guildId) then table.insert(enabledGuilds, guildId) end
    end
    if #enabledGuilds == 0 then return end
    NWT.Bookkeeper.isHistoryScanning = true
    NWT.Bookkeeper.historyScanQueue = enabledGuilds
    NWT.ProcessNextHistoryScan()
end

function NWT.ProcessNextHistoryScan()
    if #NWT.Bookkeeper.historyScanQueue == 0 then
        NWT.Bookkeeper.isHistoryScanning = false
        return
    end
    local guildId = table.remove(NWT.Bookkeeper.historyScanQueue, 1)
    NWT.Bookkeeper.historyScanGuildId = guildId
    local now = GetTimeStamp()
    local sevenDaysAgo = now - (7 * 24 * 60 * 60)
    local requestId = CreateGuildHistoryRequest(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER, now, sevenDaysAgo)
    if requestId then
        RequestMoreGuildHistoryEvents(requestId)
    else
        NWT.ProcessNextHistoryScan()
    end
end

local function OnGuildHistoryUpdated(eventCode, guildId, category, flags)
    if not NWT.Bookkeeper.isHistoryScanning then return end
    if guildId ~= NWT.Bookkeeper.historyScanGuildId then return end
    if category ~= GUILD_HISTORY_EVENT_CATEGORY_TRADER then return end
    if BitAnd(flags, GUILD_HISTORY_CATEGORY_UPDATE_FLAG_COMPLETE) ~= 0 then
        local numEvents = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)
        local salesFound = 0
        local guildSettings = GetGuildSettings(guildId)
        if not guildSettings.salesData then guildSettings.salesData = {} end
        for i = 1, numEvents do
            local eventId, ts, redacted, type, seller, buyer, itemLink, qty, price, tax = GetGuildHistoryTraderEventInfo(guildId, i)
            if eventId and not redacted and type == GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD then
                local saleKey = tostring(eventId)
                if not guildSettings.salesData[saleKey] then
                    guildSettings.salesData[saleKey] = {
                        timestamp = ts, seller = seller, buyer = buyer, itemLink = itemLink,
                        quantity = qty, price = price, tax = tax
                    }
                    salesFound = salesFound + 1
                end
            end
        end
        NWT.ProcessNextHistoryScan()
    end
end

EVENT_MANAGER:RegisterForEvent("ATK_Bookkeeper_HistoryUpdate", EVENT_GUILD_HISTORY_CATEGORY_UPDATED, OnGuildHistoryUpdated)

function NWT.BookkeeperRequestScanWithReload(guildId)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    sv.bookkeeper.pendingScanGuildId = guildId
    sv.bookkeeper.pendingScanTime = GetTimeStamp()
    zo_callLater(function() ReloadUI("ingame") end, 500)
end

function NWT.CheckPendingBookkeeperScan()
    local sv = NWT.savedVars
    if type(sv.bookkeeper) == "table" and sv.bookkeeper.pendingScanGuildId then
        local guildId = sv.bookkeeper.pendingScanGuildId
        local scanTime = sv.bookkeeper.pendingScanTime or 0
        sv.bookkeeper.pendingScanGuildId = nil
        sv.bookkeeper.pendingScanTime = nil
        if (GetTimeStamp() - scanTime) < 60 then
            zo_callLater(function() NWT.ScanGuildForBookkeeper(guildId) end, 2000)
        end
    end
end

function NWT.ScanGuildForBookkeeper(guildId)
    if NWT.Bookkeeper.isScanning then return end
    local guildSettings = GetGuildSettings(guildId)
    local numMembers = GetNumGuildMembers(guildId)
    NWT.Bookkeeper.isScanning = true
    local memberPayments = guildSettings.memberPayments or {}
    local lastScanTime = guildSettings.lastScanTime or 0

    for i = 1, numMembers do
        local displayName, note, rankIndex, status, secsSinceLogoff = GetGuildMemberInfo(guildId, i)
        if displayName then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            local lastOnline = 0
            if status == PLAYER_STATUS_ONLINE or status == PLAYER_STATUS_AWAY or status == PLAYER_STATUS_DO_NOT_DISTURB then
                lastOnline = GetTimeStamp()
            elseif secsSinceLogoff and secsSinceLogoff > 0 then
                lastOnline = GetTimeStamp() - secsSinceLogoff
            end
            if not memberPayments[displayName] then
                memberPayments[displayName] = {
                    name = displayName, totalDeposited = 0, duesTotal = 0, duesMonths = 0, raffleTotal = 0, otherTotal = 0,
                    lastPayment = 0, thisWeekDuesTotal = 0, thisWeekDues = 0, thisWeekRaffle = 0,
                    rankIndex = rankIndex, note = note, isCurrentMember = true, lastOnline = lastOnline,
                }
            else
                memberPayments[displayName].rankIndex = rankIndex
                memberPayments[displayName].note = note
                memberPayments[displayName].isCurrentMember = true
                memberPayments[displayName].lastOnline = lastOnline
            end
        end
    end

    local now = GetTimeStamp()
    local thirtyDaysAgo = now - (30 * 24 * 60 * 60)
    local bankRequestId = CreateGuildHistoryRequest(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY, now, thirtyDaysAgo)
    if bankRequestId then RequestMoreGuildHistoryEvents(bankRequestId, true, nil, nil) end

    local waitCount = 0
    EVENT_MANAGER:RegisterForUpdate("ATK_BookkeeperWait_" .. guildId, 1000, function()
        waitCount = waitCount + 1
        local numBankEvents = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY)
        if waitCount >= 10 or numBankEvents > 0 then
            EVENT_MANAGER:UnregisterForUpdate("ATK_BookkeeperWait_" .. guildId)
            if bankRequestId then pcall(function() DestroyGuildHistoryRequest(bankRequestId) end) end

            local flipTimestamp = GetCurrentTraderFlipStart()
            for _, m in pairs(memberPayments) do
                m.thisWeekDuesTotal = 0
                m.thisWeekRaffle = 0
                m.deposits = {}
            end

            for i = 1, numBankEvents do
                local eventId, ts, redacted, type, disp, _, amt = GetGuildHistoryBankedCurrencyEventInfo(guildId, i)
                if eventId and not redacted and type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED and amt and amt > 0 and disp then
                    if not disp:find("^@") then disp = "@" .. disp end
                    if not memberPayments[disp] then
                        memberPayments[disp] = {
                            name = disp, totalDeposited = 0, duesTotal = 0, duesMonths = 0, raffleTotal = 0, otherTotal = 0,
                            lastPayment = 0, thisWeekDuesTotal = 0, thisWeekDues = 0, thisWeekRaffle = 0, deposits = {},
                            isCurrentMember = false
                        }
                    end
                    local m = memberPayments[disp]
                    local dType, _ = ParseDepositType(amt, guildSettings)
                    table.insert(m.deposits, { amount = amt, timestamp = ts, type = dType })
                    if ts > lastScanTime then
                        m.totalDeposited = m.totalDeposited + amt
                        if ts > m.lastPayment then m.lastPayment = ts end
                        if dType == "dues" then m.duesTotal = (m.duesTotal or 0) + amt
                        elseif dType == "raffle" then m.raffleTotal = m.raffleTotal + amt
                        else m.otherTotal = m.otherTotal + amt end
                    end
                    if ts >= flipTimestamp then
                        if dType == "dues" then m.thisWeekDuesTotal = m.thisWeekDuesTotal + amt
                        elseif dType == "raffle" then m.thisWeekRaffle = m.thisWeekRaffle + amt end
                    end
                end
            end

            for _, m in pairs(memberPayments) do
                local rankDuesAmount, rankPeriod = NWT.GetEffectiveDuesForRank(guildSettings, m.rankIndex)
                m.effectiveDuesAmount = rankDuesAmount
                m.effectivePeriod = rankPeriod
                if rankDuesAmount > 0 then
                    m.duesMonths = math.floor((m.duesTotal or 0) / rankDuesAmount)
                    m.thisWeekDues = math.floor((m.thisWeekDuesTotal or 0) / rankDuesAmount)
                else
                    m.duesMonths = 0
                    m.thisWeekDues = 0
                end
            end
            guildSettings.memberPayments = memberPayments
            guildSettings.lastScanTime = now

            local traderRequestId = CreateGuildHistoryRequest(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER, now, thirtyDaysAgo)
            if traderRequestId then RequestMoreGuildHistoryEvents(traderRequestId, true, nil, nil) end

            local traderWaitCount = 0
            EVENT_MANAGER:RegisterForUpdate("ATK_BookkeeperTraderWait_" .. guildId, 1000, function()
                traderWaitCount = traderWaitCount + 1
                local numTraderEvents = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)
                if traderWaitCount >= 10 or numTraderEvents > 0 then
                    EVENT_MANAGER:UnregisterForUpdate("ATK_BookkeeperTraderWait_" .. guildId)
                    if traderRequestId then pcall(function() DestroyGuildHistoryRequest(traderRequestId) end) end

                    local memberTaxes = {}
                    local memberSalesData = {}
                    for i = 1, numTraderEvents do
                        local eventId, ts, redacted, evType, seller, buyer, itemLink, qty, price, tax = GetGuildHistoryTraderEventInfo(guildId, i)
                        if eventId and not redacted and evType == GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD and seller then
                            if not seller:find("^@") then seller = "@" .. seller end
                            if not memberSalesData[seller] then
                                memberSalesData[seller] = { totalSales = 0, saleCount = 0, totalTax = 0, lastSale = 0 }
                            end
                            local sd = memberSalesData[seller]
                            sd.totalSales = sd.totalSales + (price or 0)
                            sd.saleCount = sd.saleCount + 1
                            sd.totalTax = sd.totalTax + (tax or 0)
                            if ts > sd.lastSale then sd.lastSale = ts end
                            memberTaxes[seller] = (memberTaxes[seller] or 0) + (tax or 0)
                        end
                    end
                    guildSettings.memberSalesData = memberSalesData
                    guildSettings.memberTaxTotals = memberTaxes
                    local sellerCount = 0
                    for _ in pairs(memberTaxes) do sellerCount = sellerCount + 1 end

                    NWT.Bookkeeper.isScanning = false
                    NWT.BookkeeperScanPaymentNotes(guildId)
                    if guildSettings.autoUpdateNotes then
                        NWT.BookkeeperRepairNotes(guildId)
                        NWT.BookkeeperReformatAllNotes(guildId)
                        NWT.BookkeeperAutoUpdateNotes(guildId)
                    end
                    NWT.UpdateBookkeeperUI()
                    NWT.ShowBookkeeperReloadDialog(numBankEvents, numTraderEvents, sellerCount)
                end
            end)
        end
    end)
end

function NWT.ShowBookkeeperReloadDialog(depositCount, saleCount, sellerCount)
    if not ESO_Dialogs["ATK_BOOKKEEPER_RELOAD_DIALOG"] then
        ESO_Dialogs["ATK_BOOKKEEPER_RELOAD_DIALOG"] = {
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
            canQueue = true,
            title = { text = "BOOKKEEPER SCAN COMPLETE" },
            mainText = { text = "Scan complete!\n\nDeposits: <<1>>\nSales: <<2>> from <<3>> sellers\n\nReload UI now to scan other guilds with fresh history data?" },
            buttons = {
                { text = "Reload UI", keybind = "DIALOG_PRIMARY", callback = function() ReloadUI("ingame") end },
                { text = "Later", keybind = "DIALOG_NEGATIVE" },
            },
        }
    end
    if IsInGamepadPreferredMode() then
        ZO_Dialogs_ShowGamepadDialog("ATK_BOOKKEEPER_RELOAD_DIALOG", nil, { mainTextParams = { depositCount or 0, saleCount or 0, sellerCount or 0 } })
    else
        ZO_Dialogs_ShowDialog("ATK_BOOKKEEPER_RELOAD_DIALOG", nil, { mainTextParams = { depositCount or 0, saleCount or 0, sellerCount or 0 } })
    end
end

function NWT.BookkeeperIsFreeTraderGuild(guildId)
    if not guildId or guildId <= 0 then return false end
    return IsFreeTraderMode(GetGuildSettings(guildId))
end

function NWT.SetupBookkeeperTradingHouseKeybinds()
    if NWT.bookkeeperTradingHouseKeybindsInitialized then return end
    NWT.bookkeeperTradingHouseKeybindsInitialized = true
    EVENT_MANAGER:RegisterForEvent(BOOKKEEPER_TRADER_OPEN_EVENT, EVENT_OPEN_TRADING_HOUSE, function()
        zo_callLater(AddBookkeeperTradingHouseKeybinds, 100)
    end)
    EVENT_MANAGER:RegisterForEvent(BOOKKEEPER_TRADER_CLOSE_EVENT, EVENT_CLOSE_TRADING_HOUSE, function()
        RemoveBookkeeperTradingHouseKeybinds()
        local bk = NWT.Bookkeeper
        if bk and bk.listingsScanState and bk.listingsScanState.guildId then
            FinalizeBookkeeperListingsScan(
                bk.listingsScanState.guildId,
                bk.listingsScanState.sellerCounts or {},
                false,
                "trader_closed"
            )
        end
    end)
    EVENT_MANAGER:RegisterForEvent(BOOKKEEPER_TRADER_GUILD_CHANGE_EVENT, EVENT_TRADING_HOUSE_SELECTED_GUILD_CHANGED, function()
        UpdateBookkeeperTradingHouseKeybind()
    end)
    if GetInteractionType and INTERACTION_TRADINGHOUSE and GetInteractionType() == INTERACTION_TRADINGHOUSE then
        zo_callLater(AddBookkeeperTradingHouseKeybinds, 100)
    end
end

FinalizeBookkeeperListingsScan = function(guildId, sellerCounts, wasSuccessful, errorReason)
    local gs = GetGuildSettings(guildId)
    local bk = NWT.Bookkeeper
    EVENT_MANAGER:UnregisterForEvent(BOOKKEEPER_LISTINGS_SCAN_EVENT, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
    gs.listingsScanInProgress = false
    if bk then
        bk.listingsScanActiveGuildId = nil
        bk.listingsScanState = nil
    end
    if not wasSuccessful then
        gs.listingsLastFailureTime = GetTimeStamp()
        if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
        end
        return
    end
    gs.listingsLastFailureTime = 0
    if not gs.memberPayments then gs.memberPayments = {} end
    if not gs.memberListingCounts then gs.memberListingCounts = {} end
    for _, memberData in pairs(gs.memberPayments) do
        memberData.isCurrentMember = false
    end
    local totalListings = 0
    local listedMembers = 0
    local memberListingCounts = {}
    local numMembers = GetNumGuildMembers(guildId)
    for i = 1, numMembers do
        local memberName, note, rankIndex, memberStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, i)
        memberName = NormalizeDisplayName(memberName)
        if memberName then
            local listingCount = sellerCounts[memberName] or 0
            memberListingCounts[memberName] = listingCount
            totalListings = totalListings + listingCount
            if listingCount > 0 then listedMembers = listedMembers + 1 end
            local data = gs.memberPayments[memberName]
            if not data then
                data = {
                    name = memberName, totalDeposited = 0, duesTotal = 0, duesMonths = 0, raffleTotal = 0, otherTotal = 0,
                    lastPayment = 0, deposits = {}, thisWeekDues = 0, thisWeekDuesTotal = 0, thisWeekRaffle = 0,
                    thisWeekDuesPeriods = 0, noteDetected = false,
                }
                gs.memberPayments[memberName] = data
            end
            local lastOnline = 0
            if memberStatus ~= PLAYER_STATUS_ONLINE then
                lastOnline = GetTimeStamp() - (secsSinceLogoff or 0)
            end
            data.name = memberName
            data.note = note or ""
            data.rankIndex = rankIndex
            data.isCurrentMember = true
            data.lastOnline = lastOnline
            data.listingsCount = listingCount
        end
    end
    gs.memberListingCounts = memberListingCounts
    gs.listingsLastScanTime = GetTimeStamp()
    if NWT.Bookkeeper and NWT.Bookkeeper.viewingGuildIndex and GetGuildId(NWT.Bookkeeper.viewingGuildIndex) == guildId then
        NWT.BuildBookkeeperMemberList(guildId)
        NWT.UpdateBookkeeperUI()
        NWT.SyncHiddenBookkeeperList()
    end
    UpdateBookkeeperTradingHouseKeybind()
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
    end
end

function NWT.BookkeeperScanGuildListings(guildId)
    local bk = NWT.Bookkeeper
    if not bk or bk.demoMode then return end
    guildId = tonumber(guildId) or 0
    if guildId <= 0 then return end
    local gs = GetGuildSettings(guildId)
    if gs.listingsScanInProgress then return end
    if bk.listingsScanActiveGuildId and bk.listingsScanActiveGuildId ~= guildId then
        PlaySound(SOUNDS.NEGATIVE_CLICK)
        return
    end
    local now = GetTimeStamp()
    local lastScan = tonumber(gs.listingsLastScanTime) or 0
    local elapsedSinceScan = now - lastScan
    if lastScan > 0 and elapsedSinceScan < LISTINGS_SCAN_COOLDOWN_SEC then
        PlaySound(SOUNDS.NEGATIVE_CLICK)
        return
    end
    local lastFailure = tonumber(gs.listingsLastFailureTime) or 0
    local elapsedSinceFailure = now - lastFailure
    if lastFailure > 0 and elapsedSinceFailure < LISTINGS_FAILURE_BACKOFF_SEC then
        PlaySound(SOUNDS.NEGATIVE_CLICK)
        return
    end
    if GetInteractionType and INTERACTION_TRADINGHOUSE and GetInteractionType() ~= INTERACTION_TRADINGHOUSE then
        PlaySound(SOUNDS.NEGATIVE_CLICK)
        return
    end
    local selectedGuildId = GetSelectedTradingHouseGuildId and GetSelectedTradingHouseGuildId() or 0
    local switchedGuild = false
    if selectedGuildId ~= guildId then
        if not SelectTradingHouseGuildId or not SelectTradingHouseGuildId(guildId) then
            PlaySound(SOUNDS.NEGATIVE_CLICK)
            return
        end
        switchedGuild = true
    end
    gs.listingsScanInProgress = true
    bk.listingsScanActiveGuildId = guildId
    local scanPasses = { { filterType = nil, filterValues = nil } }
    bk.listingsScanState = {
        guildId = guildId, sellerCounts = {}, pagesScanned = 0, totalRowsRead = 0, processedPages = {},
        searchRequestPending = false, pendingPage = nil, queuedPage = nil, queuedUseLastExecutedSearchFilters = false,
        nextRequestEarliestAtMs = 0, queueDrainScheduled = false, pageMismatchCount = 0, requestedPageRetries = {},
        scanPasses = scanPasses, scanPassIndex = 1, segmentedMode = false,
    }

    local function ResetPassPagingState(state)
        state.processedPages = {}
        state.searchRequestPending = false
        state.pendingPage = nil
        state.queuedPage = nil
        state.queuedUseLastExecutedSearchFilters = false
        state.nextRequestEarliestAtMs = 0
        state.queueDrainScheduled = false
        state.pageMismatchCount = 0
    end

    local function RequestListingsPage(page, useLastExecutedSearchFilters)
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return false end
        if state.searchRequestPending then return false end
        state.searchRequestPending = true
        state.pendingPage = page
        ExecuteTradingHouseSearch(page, TRADING_HOUSE_SORT_EXPIRY_TIME, true, useLastExecutedSearchFilters)
        return true
    end

    local function DrainQueuedListingsSearch()
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return end
        if state.queuedPage == nil then return end
        if state.searchRequestPending then return end
        local nowMs = GetFrameTimeMilliseconds()
        local earliestMs = tonumber(state.nextRequestEarliestAtMs) or 0
        if nowMs < earliestMs then return end
        local page = state.queuedPage
        local useLast = state.queuedUseLastExecutedSearchFilters
        if RequestListingsPage(page, useLast) then
            state.queuedPage = nil
            state.queuedUseLastExecutedSearchFilters = false
            state.nextRequestEarliestAtMs = 0
        end
    end

    local function ScheduleQueuedListingsSearchDrain(delayMs)
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return end
        if state.queueDrainScheduled then return end
        state.queueDrainScheduled = true
        zo_callLater(function()
            local currentState = bk.listingsScanState
            if not currentState or currentState.guildId ~= guildId then return end
            currentState.queueDrainScheduled = false
            DrainQueuedListingsSearch()
            if currentState.queuedPage ~= nil then ScheduleQueuedListingsSearchDrain(50) end
        end, delayMs or 0)
    end

    local function QueueListingsPage(page, useLastExecutedSearchFilters, minDelayMs)
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return end
        state.queuedPage = page
        state.queuedUseLastExecutedSearchFilters = useLastExecutedSearchFilters and true or false
        local nowMs = GetFrameTimeMilliseconds()
        local delay = tonumber(minDelayMs) or 0
        local targetMs = nowMs + math.max(0, delay)
        if targetMs > (state.nextRequestEarliestAtMs or 0) then state.nextRequestEarliestAtMs = targetMs end
        ScheduleQueuedListingsSearchDrain(delay > 0 and delay or 0)
    end

    local function StartCurrentScanPass()
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return end
        local pass = state.scanPasses[state.scanPassIndex]
        if not pass then
            FinalizeBookkeeperListingsScan(guildId, state.sellerCounts, true)
            return
        end
        ResetPassPagingState(state)
        ClearAllTradingHouseSearchTerms()
        if pass.filterType and pass.filterValues then SetTradingHouseFilter(pass.filterType, pass.filterValues) end
        QueueListingsPage(0, false, 0)
    end

    EVENT_MANAGER:UnregisterForEvent(BOOKKEEPER_LISTINGS_SCAN_EVENT, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
    EVENT_MANAGER:RegisterForEvent(BOOKKEEPER_LISTINGS_SCAN_EVENT, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(_, responseType, result)
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return end
        if responseType ~= TRADING_HOUSE_RESULT_SEARCH_PENDING then return end
        local requestedPage = state.pendingPage
        if result ~= TRADING_HOUSE_RESULT_SUCCESS then
            state.searchRequestPending = false
            state.pendingPage = nil
            FinalizeBookkeeperListingsScan(guildId, state.sellerCounts, false, result)
            return
        end
        local numItemsOnPage, currentPage, hasMorePages = GetTradingHouseSearchResultsInfo()
        currentPage = currentPage or 0
        state.searchRequestPending = false
        state.pendingPage = nil
        if requestedPage ~= nil and currentPage ~= requestedPage then
            state.pageMismatchCount = (state.pageMismatchCount or 0) + 1
            state.requestedPageRetries[requestedPage] = (state.requestedPageRetries[requestedPage] or 0) + 1
            if state.pageMismatchCount >= 20 or state.requestedPageRetries[requestedPage] >= 12 then
                FinalizeBookkeeperListingsScan(guildId, state.sellerCounts, false, "page_mismatch_stall_" .. tostring(requestedPage))
                return
            end
            QueueListingsPage(requestedPage, true, LISTINGS_PAGE_DELAY_MS + 500)
            return
        end
        state.pageMismatchCount = 0
        if requestedPage ~= nil then state.requestedPageRetries[requestedPage] = nil end
        local isDuplicatePage = state.processedPages[currentPage] == true
        if not isDuplicatePage then
            state.processedPages[currentPage] = true
            state.pagesScanned = (state.pagesScanned or 0) + 1
            state.totalRowsRead = (state.totalRowsRead or 0) + (numItemsOnPage or 0)
            for i = 1, (numItemsOnPage or 0) do
                local _, _, _, _, sellerName = GetTradingHouseSearchResultItemInfo(i)
                sellerName = NormalizeDisplayName(sellerName)
                if sellerName then state.sellerCounts[sellerName] = (state.sellerCounts[sellerName] or 0) + 1 end
            end
        end
        if hasMorePages then
            QueueListingsPage(currentPage + 1, true, LISTINGS_PAGE_DELAY_MS)
        else
            if state.scanPassIndex < #state.scanPasses then
                state.scanPassIndex = state.scanPassIndex + 1
                zo_callLater(StartCurrentScanPass, LISTINGS_PAGE_DELAY_MS)
            else
                FinalizeBookkeeperListingsScan(guildId, state.sellerCounts, true)
            end
        end
    end)

    local kickoffDelay = switchedGuild and 250 or 50
    zo_callLater(StartCurrentScanPass, kickoffDelay)
    PlaySound(SOUNDS.POSITIVE_CLICK)
    UpdateBookkeeperTradingHouseKeybind()
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
    end
end

function NWT.BuildBookkeeperMemberList(guildId)
    local bk = NWT.Bookkeeper
    local guildSettings = GetGuildSettings(guildId)
    local freeTraderMode = IsFreeTraderMode(guildSettings)
    local listingTarget = GetListingTarget(guildSettings)
    bk.sortedMembers = {}
    local searchLower = bk.searchText and bk.searchText:lower() or ""
    local now = GetTimeStamp()
    local currentDate = GetDate()
    local currentYear = tonumber(tostring(currentDate):sub(1, 4)) or 2026
    local currentMonth = tonumber(tostring(currentDate):sub(5, 6)) or 1
    local currentDay = tonumber(tostring(currentDate):sub(7, 8)) or 1

    if guildSettings.memberPayments then
        for name, data in pairs(guildSettings.memberPayments) do
            if data.isCurrentMember then
                local isLifetime = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[name]
                local isExemptRank = IsRankExempt(guildSettings, data.rankIndex, guildId)
                local hasBankPaid = ((data.thisWeekDues or 0) > 0) or ((data.duesMonths or 0) > 0)
                local isPaidViaNote = false
                local daysOverdue = 0
                local daysUntilDue = 0
                if not hasBankPaid and guildSettings.paymentHistory and guildSettings.paymentHistory[name] then
                    local ph = guildSettings.paymentHistory[name]
                    if ph.payments and #ph.payments > 0 then
                        local latest = ph.payments[#ph.payments]
                        local dueMonth = tonumber(latest.dueMonth) or 0
                        local dueDay = tonumber(latest.dueDay) or 0
                        local dueYear = tonumber(latest.dueYear) or currentYear
                        if dueMonth >= 1 and dueMonth <= 12 and dueDay >= 1 and dueDay <= 31 and dueYear > 2000 then
                            local success, dueTimestamp = pcall(os.time, {year = dueYear, month = dueMonth, day = dueDay, hour = 0, min = 0, sec = 0})
                            if success and dueTimestamp then
                                local nowTimestamp = os.time({year = currentYear, month = currentMonth, day = currentDay, hour = 0, min = 0, sec = 0})
                                if dueTimestamp >= nowTimestamp then
                                    isPaidViaNote = true
                                    daysUntilDue = math.floor((dueTimestamp - nowTimestamp) / 86400)
                                else
                                    daysOverdue = math.floor((nowTimestamp - dueTimestamp) / 86400)
                                end
                            end
                        end
                    end
                end
                data.isPaidViaNote = isPaidViaNote
                data.daysOverdue = daysOverdue
                data.daysUntilDue = daysUntilDue
                local listingCount = 0
                if guildSettings.memberListingCounts then listingCount = tonumber(guildSettings.memberListingCounts[name]) or 0 end
                data.listingsCount = listingCount
                data.listingTarget = listingTarget
                local isPaidUp
                if freeTraderMode then isPaidUp = listingCount >= listingTarget
                else isPaidUp = ((data.thisWeekDues or 0) > 0) or ((data.duesMonths or 0) > 0) or isLifetime or isExemptRank or isPaidViaNote end
                data.isExemptRank = isExemptRank
                local include = true
                if bk.filterMode == 2 then
                    if freeTraderMode then include = listingCount == 0 else include = not isPaidUp end
                elseif bk.filterMode == 3 then
                    if freeTraderMode then include = listingCount > 0 else include = isPaidUp end
                end
                if include and searchLower ~= "" then include = name:lower():find(searchLower, 1, true) ~= nil end
                if include then table.insert(bk.sortedMembers, data) end
            end
        end
    end

    if bk.filterMode == 4 then
        table.sort(bk.sortedMembers, function(a, b) return a.name:lower() < b.name:lower() end)
    elseif bk.filterMode == 5 then
        table.sort(bk.sortedMembers, function(a, b) return a.name:lower() > b.name:lower() end)
    elseif bk.filterMode == 6 then
        table.sort(bk.sortedMembers, function(a, b) return (a.lastPayment or 0) > (b.lastPayment or 0) end)
    else
        if freeTraderMode then
            table.sort(bk.sortedMembers, function(a, b)
                if (a.listingsCount or 0) ~= (b.listingsCount or 0) then return (a.listingsCount or 0) > (b.listingsCount or 0) end
                return a.name < b.name
            end)
        else
            table.sort(bk.sortedMembers, function(a, b)
                if (a.duesMonths or 0) ~= (b.duesMonths or 0) then return (a.duesMonths or 0) > (b.duesMonths or 0) end
                return a.name < b.name
            end)
        end
    end
    if bk.selectedMemberIndex > #bk.sortedMembers then bk.selectedMemberIndex = math.max(1, #bk.sortedMembers) end
end

function NWT.BuildBookkeeperMemberList_Demo()
    local bk = NWT.Bookkeeper
    local gs = GetDemoSettings()
    local freeTraderMode = IsFreeTraderMode(gs)
    local listingTarget = GetListingTarget(gs)
    bk.sortedMembers = {}
    local searchLower = bk.searchText and bk.searchText:lower() or ""
    for name, data in pairs(gs.memberPayments) do
        local isLifetime = gs.lifetimeMembers and gs.lifetimeMembers[name]
        local isExemptRank = IsRankExempt(gs, data.rankIndex, 0)
        local listingCount = gs.memberListingCounts and (tonumber(gs.memberListingCounts[name]) or 0) or 0
        data.listingsCount = listingCount
        data.listingTarget = listingTarget
        local isPaidUp
        if freeTraderMode then isPaidUp = listingCount >= listingTarget
        else isPaidUp = ((data.thisWeekDues or 0) > 0) or ((data.duesMonths or 0) > 0) or isLifetime or isExemptRank end
        data.isExemptRank = isExemptRank
        local include = true
        if bk.filterMode == 2 then
            if freeTraderMode then include = listingCount == 0 else include = not isPaidUp end
        elseif bk.filterMode == 3 then
            if freeTraderMode then include = listingCount > 0 else include = isPaidUp end
        end
        if include and searchLower ~= "" then include = name:lower():find(searchLower, 1, true) ~= nil end
        if include then table.insert(bk.sortedMembers, data) end
    end
    if bk.filterMode == 4 then
        table.sort(bk.sortedMembers, function(a, b) return a.name:lower() < b.name:lower() end)
    elseif bk.filterMode == 5 then
        table.sort(bk.sortedMembers, function(a, b) return a.name:lower() > b.name:lower() end)
    elseif bk.filterMode == 6 then
        table.sort(bk.sortedMembers, function(a, b) return (a.lastPayment or 0) > (b.lastPayment or 0) end)
    else
        if freeTraderMode then
            table.sort(bk.sortedMembers, function(a, b)
                if (a.listingsCount or 0) ~= (b.listingsCount or 0) then return (a.listingsCount or 0) > (b.listingsCount or 0) end
                return a.name < b.name
            end)
        else
            table.sort(bk.sortedMembers, function(a, b)
                local aLife = gs.lifetimeMembers and gs.lifetimeMembers[a.name]
                local bLife = gs.lifetimeMembers and gs.lifetimeMembers[b.name]
                local aExempt = a.isExemptRank
                local bExempt = b.isExemptRank
                local aPaid = (a.thisWeekDues or 0) > 0
                local bPaid = (b.thisWeekDues or 0) > 0
                local aPre = (a.duesMonths or 0) > 0
                local bPre = (b.duesMonths or 0) > 0
                if aLife ~= bLife then return aLife end
                if aExempt ~= bExempt then return aExempt end
                if aPaid ~= bPaid then return aPaid end
                if aPre ~= bPre then return aPre end
                if (a.duesMonths or 0) ~= (b.duesMonths or 0) then return (a.duesMonths or 0) > (b.duesMonths or 0) end
                return a.name < b.name
            end)
        end
    end
    if bk.selectedMemberIndex > #bk.sortedMembers then bk.selectedMemberIndex = math.max(1, #bk.sortedMembers) end
end

function NWT.BookkeeperCycleFilter()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen then return end
    bk.filterMode = (bk.filterMode % 6) + 1
    bk.selectedMemberIndex, bk.memberScrollOffset = 1, 0
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateBookkeeperUI()
    NWT.SyncHiddenBookkeeperList()
end

function NWT.BookkeeperClearSearch()
    local bk = NWT.Bookkeeper
    bk.searchText = ""
    bk.selectedMemberIndex, bk.memberScrollOffset = 1, 0
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateBookkeeperUI()
    NWT.SyncHiddenBookkeeperList()
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
    end
end

function NWT.BookkeeperExportUnpaid(guildId)
    local gs = GetGuildSettings(guildId)
    local unpaidList = {}
    for name, m in pairs(gs.memberPayments or {}) do
        if m.isCurrentMember then
            local isLife = gs.lifetimeMembers and gs.lifetimeMembers[name]
            local isExempt = IsRankExempt(gs, m.rankIndex, guildId)
            if not isLife and not isExempt and m.thisWeekDues == 0 and m.duesMonths == 0 then
                table.insert(unpaidList, name)
            end
        end
    end
    table.sort(unpaidList)
    for _, name in ipairs(unpaidList) do
        NWT.Debug("  • " .. name)
    end
end

function NWT.ShowMemberDetails()
    local bk = NWT.Bookkeeper
    if bk.focusPanel ~= "dues" then return end
    local member = bk.sortedMembers[bk.selectedMemberIndex]
    if not member then return end
    local dialog = ATK_MemberDetailsDialog
    if not dialog then return end

    local guildId = GetGuildId(bk.viewingGuildIndex)
    local gs = GetGuildSettings(guildId)
    local displayName = member.name:gsub("^@", "")
    dialog:GetNamedChild("Title"):SetText("|cFFD700" .. displayName .. "|r")

    local rank = (member.rankIndex and GetGuildRankCustomName(guildId, member.rankIndex)) or ("Rank " .. (member.rankIndex or "?"))
    dialog:GetNamedChild("Row1"):SetText(string.format("|cFFFFAARank:|r  |cFFFFFF%s|r", rank))

    local isLife = gs.lifetimeMembers and gs.lifetimeMembers[member.name]
    local isExempt = member.isExemptRank
    local totalCycles = (member.thisWeekDues or 0) + (member.duesMonths or 0)
    local statusText
    if isLife then statusText = "|c00FFFFLIFETIME|r"
    elseif isExempt then statusText = "|cFF00FFEXEMPT|r"
    elseif totalCycles > 1 then statusText = "|c00FF00+" .. totalCycles .. " cycles prepaid|r"
    elseif totalCycles == 1 then statusText = "|c00FF00PAID (current cycle)|r"
    elseif member.isPaidViaNote then statusText = "|c00FF00PAID (via note)|r"
    else statusText = "|cFF4444UNPAID|r" end
    dialog:GetNamedChild("Row2"):SetText(string.format("|cFFFFAAStatus:|r  %s", statusText))

    dialog:GetNamedChild("Row3"):SetText(string.format("|cFFFFAATotal Deposited:|r  |c00FF00%sg|r", NWT.FormatGold(member.totalDeposited or 0)))
    local duesTotal = (member.totalDeposited or 0) - (member.raffleTotal or 0) - (member.otherTotal or 0)
    dialog:GetNamedChild("Row4"):SetText(string.format("|cFFFFAADues Paid:|r  |c00FF00%sg|r  (%d periods)", NWT.FormatGold(duesTotal), member.duesMonths or 0))
    dialog:GetNamedChild("Row5"):SetText(string.format("|cFFFFAARaffle Entries:|r  |cFFFF00%sg|r", NWT.FormatGold(member.raffleTotal or 0)))

    local taxes = gs.memberTaxTotals and gs.memberTaxTotals[member.name] or 0
    dialog:GetNamedChild("Row6"):SetText(string.format("|cFFFFAASales Taxes:|r  |cFF6600%sg|r", NWT.FormatGold(taxes)))
    local totalIncome = (member.totalDeposited or 0) + taxes
    dialog:GetNamedChild("Row7"):SetText(string.format("|cFFFFAATotal Income:|r  |c00FF00%sg|r", NWT.FormatGold(totalIncome)))

    local lastPayStr = (member.lastPayment or 0) > 0 and NWT.FormatTimeAgo(member.lastPayment) or "Never"
    dialog:GetNamedChild("Row8"):SetText(string.format("|cFFFFAALast Payment:|r  |c888888%s|r", lastPayStr))
    local lastOnlineStr = member.lastOnline and member.lastOnline > 0 and NWT.FormatTimeAgo(member.lastOnline) or "Unknown"
    dialog:GetNamedChild("Row9"):SetText(string.format("|cFFFFAALast Online:|r  |c888888%s|r", lastOnlineStr))

    bk.memberDetailsOpen = true
    dialog:SetHidden(false)
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
    end
end

function NWT.CloseMemberDetails()
    if ATK_MemberDetailsDialog then ATK_MemberDetailsDialog:SetHidden(true) end
    NWT.Bookkeeper.memberDetailsOpen = nil
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
    end
end

local function CalculateAmountOwed(memberData, guildSettings)
    local rankDuesAmount, rankPeriod = NWT.GetEffectiveDuesForRank(guildSettings, memberData.rankIndex)
    if rankDuesAmount <= 0 then return 0 end
    local duesDeposited = memberData.duesTotal or 0
    local periodsPaid = math.floor(duesDeposited / rankDuesAmount)
    if (memberData.thisWeekDues or 0) <= 0 and periodsPaid <= 0 then
        local owed = rankDuesAmount
        if guildSettings.lateFeeEnabled and (guildSettings.lateFeeAmount or 0) > 0 then
            owed = owed + guildSettings.lateFeeAmount
        end
        return owed
    end
    return 0
end

function NWT.GetDemotionCandidates(guildId)
    local gs = GetGuildSettings(guildId)
    if not gs.demotionRank then return {} end
    local candidates = {}
    local now = GetTimeStamp()
    local daysThreshold = gs.daysBeforeDemotion or 7
    local secondsThreshold = daysThreshold * 86400
    for name, m in pairs(gs.memberPayments or {}) do
        if m.isCurrentMember then
            local isLifetime = gs.lifetimeMembers and gs.lifetimeMembers[name]
            local isExempt = gs.exemptRanks and gs.exemptRanks[m.rankIndex]
            local alreadyDemoted = gs.demotedMembers and gs.demotedMembers[name]
            if not isLifetime and not isExempt and not alreadyDemoted then
                local isPaid = (m.thisWeekDues or 0) > 0 or (m.duesMonths or 0) > 0 or m.isPaidViaNote
                if not isPaid then
                    local lastPayment = m.lastPayment or 0
                    local daysSincePayment = lastPayment > 0 and math.floor((now - lastPayment) / 86400) or 999
                    if daysSincePayment >= daysThreshold then
                        local amountOwed = CalculateAmountOwed(m, gs)
                        if amountOwed > 0 then
                            table.insert(candidates, {
                                name = name, rankIndex = m.rankIndex,
                                rankName = GetGuildRankCustomName(guildId, m.rankIndex) or ("Rank " .. m.rankIndex),
                                amountOwed = amountOwed, daysSincePayment = daysSincePayment, memberIndex = m.memberIndex,
                            })
                        end
                    end
                end
            end
        end
    end
    table.sort(candidates, function(a, b) return a.daysSincePayment > b.daysSincePayment end)
    return candidates
end

function NWT.PreviewDemotions(guildId)
    local candidates = NWT.GetDemotionCandidates(guildId)
    local gs = GetGuildSettings(guildId)
    if #candidates == 0 then return end
    NWT.Bookkeeper.demotionPreview = candidates
    NWT.Bookkeeper.demotionPreviewIndex = 1
    NWT.Bookkeeper.demotionPreviewGuildId = guildId
    NWT.ShowDemotionPreview()
end

function NWT.ShowDemotionPreview()
    local bk = NWT.Bookkeeper
    local candidates = bk.demotionPreview
    if not candidates or #candidates == 0 then return end
    local idx = bk.demotionPreviewIndex or 1
    local c = candidates[idx]
    if not c then return end
    NWT.Debug(string.format("|cFFFF00[%d/%d]|r %s - |cFF6600%s|r overdue, owes |cFF0000%sg|r (was %s)",
        idx, #candidates, c.name, c.daysSincePayment .. "d", NWT.FormatGold(c.amountOwed), c.rankName))
end

function NWT.DemoteMember(guildId, memberName, memberData)
    local gs = GetGuildSettings(guildId)
    if not gs.demotionRank then return false end
    local memberIndex = nil
    local currentRank = nil
    for i = 1, GetNumGuildMembers(guildId) do
        local displayName = GetGuildMemberInfo(guildId, i)
        if displayName then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            if displayName == memberName then
                memberIndex = i
                local _, _, rankIndex = GetGuildMemberInfo(guildId, i)
                currentRank = rankIndex
                break
            end
        end
    end
    if not memberIndex or not currentRank then return false end
    if currentRank == gs.demotionRank then return false end
    if not gs.demotedMembers then gs.demotedMembers = {} end
    gs.demotedMembers[memberName] = {
        originalRank = currentRank,
        amountOwed = memberData.amountOwed or 0,
        demotedAt = GetTimeStamp(),
    }
    local success = pcall(function() SetGuildMemberRank(guildId, memberIndex, gs.demotionRank) end)
    if success then
        local currentNote = select(2, GetGuildMemberInfo(guildId, memberIndex)) or ""
        local originalRankName = GetGuildRankCustomName(guildId, currentRank) or ("R" .. currentRank)
        local newNote = "Owe: " .. NWT.FormatGold(memberData.amountOwed) .. "g (was " .. originalRankName .. ")"
        pcall(function() SetGuildMemberNote(guildId, memberIndex, newNote) end)
        return true
    end
    return false
end

function NWT.RunDemotions(guildId)
    local candidates = NWT.GetDemotionCandidates(guildId)
    local gs = GetGuildSettings(guildId)
    if #candidates == 0 then return end
    if not gs.demotionRank then return end
    local demoted = 0
    for _, c in ipairs(candidates) do
        if NWT.DemoteMember(guildId, c.name, c) then demoted = demoted + 1 end
    end
    NWT.UpdateDuesSettingsDialog()
    NWT.UpdateBookkeeperUI()
end

function NWT.RestoreMember(guildId, memberName)
    local gs = GetGuildSettings(guildId)
    local demotedInfo = gs.demotedMembers and gs.demotedMembers[memberName]
    if not demotedInfo then return false end
    local memberIndex = nil
    for i = 1, GetNumGuildMembers(guildId) do
        local displayName = GetGuildMemberInfo(guildId, i)
        if displayName then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            if displayName == memberName then memberIndex = i; break end
        end
    end
    if not memberIndex then return false end
    local success = pcall(function() SetGuildMemberRank(guildId, memberIndex, demotedInfo.originalRank) end)
    if success then
        gs.demotedMembers[memberName] = nil
        return true
    end
    return false
end

function NWT.RestoreAllDemoted(guildId)
    local gs = GetGuildSettings(guildId)
    if not gs.demotedMembers then return end
    local restored = 0
    local total = 0
    for name, _ in pairs(gs.demotedMembers) do
        total = total + 1
        if NWT.RestoreMember(guildId, name) then restored = restored + 1 end
    end
    NWT.UpdateDuesSettingsDialog()
    NWT.UpdateBookkeeperUI()
end
