-- ============================================
-- GUILD BOOKKEEPER DASHBOARD (UI/Layout/Scene)
-- ============================================
-- Constants, Data, Commands loaded first. This file retains UI/layout/scene-heavy code.

local BC = NWT.BookkeeperConstants
local GetGuildSettings = NWT.BookkeeperData_GetGuildSettings
local IsGuildEnabled = NWT.BookkeeperData_IsGuildEnabled
local IsGuildFavorite = NWT.BookkeeperData_IsGuildFavorite
local IsRankExempt = NWT.BookkeeperData_IsRankExempt
local IsFreeTraderMode = NWT.BookkeeperData_IsFreeTraderMode
local GetListingTarget = NWT.BookkeeperData_GetListingTarget
local GetDemoSettings = NWT.BookkeeperData_GetDemoSettings
local FormatRafflePeriod = NWT.BookkeeperData_FormatRafflePeriod
local GetRafflePeriodPresets = NWT.BookkeeperData_GetRafflePeriodPresets
local GetRafflePeriodTimes = NWT.BookkeeperData_GetRafflePeriodTimes
local NormalizeDisplayName = NWT.BookkeeperData_NormalizeDisplayName

local QUICK_ACTIONS = BC.QUICK_ACTIONS
local DEMO_MEMBERS = BC.DEMO_MEMBERS
local DEMO_GUILDS = BC.DEMO_GUILDS

-- GetBookkeeperGuildSettings alias for legacy references
local GetBookkeeperGuildSettings = GetGuildSettings

-- [Moved to BookkeeperData/Commands] GetDemoSettings, IsGuildEnabled, ToggleGuildEnabled, IsGuildFavorite,
-- ToggleGuildFavorite, GetDefaultBookkeeperSettings, CleanupPaymentHistory, GetBookkeeperGuildSettings,
-- NormalizeDisplayName, IsFreeTraderMode, GetListingTarget, IsRankExempt, ParseDepositType, GetCurrentTraderFlipStart,
-- GetRafflePeriodPresets, FormatRafflePeriod, GetRafflePeriodTimes, ParseDateString, FormatShortDate,
-- BuildPatternFromTemplate, ParseDueDateFromNote, GetLastNoteUpdate, SetLastNoteUpdate, GetSavedDueDate,
-- SetSavedDueDate, ParsePaymentDateFromNote, NWT.BookkeeperScanPaymentNotes through NWT.RestoreAllDemoted

-- (Data/Commands implementations loaded from BookkeeperData.lua and BookkeeperCommands.lua)

function NWT.UpdateBookkeeperUI()
    local ui = ATK_Bookkeeper_UI
    if not ui then 
NWT.Debug("|cFF0000[Bookkeeper]|r ATK_Bookkeeper_UI not found!")
        return 
    end
    
    local bk = NWT.Bookkeeper
    local guildId, guildName, guildSettings, numGuilds
    
    -- Demo mode uses fake data
    if bk.demoMode then
        numGuilds = #DEMO_GUILDS
        local demoGuild = DEMO_GUILDS[bk.viewingGuildIndex] or DEMO_GUILDS[1]
        guildId = demoGuild.id
        guildName = demoGuild.name
        guildSettings = GetDemoSettings()
        NWT.BuildBookkeeperMemberList_Demo()
    else
        numGuilds = GetNumGuilds()
        if numGuilds == 0 then return end
        guildId = GetGuildId(bk.viewingGuildIndex)
        guildName = GetGuildName(guildId)
        guildSettings = GetBookkeeperGuildSettings(guildId)
        NWT.BuildBookkeeperMemberList(guildId)
    end
    
    local isGuildsFocus = (bk.focusPanel == "guilds")
    local isDuesFocus = (bk.focusPanel == "dues")
    
    -- Use the new UI update function
    NWT.UpdateBookkeeperUI_New(ui, bk, guildId, guildName, guildSettings, isGuildsFocus, isDuesFocus, numGuilds)
end

-- OLD UI CODE REMOVED - keeping for reference if needed
function NWT.UpdateBookkeeperUI_OLD_UNUSED()
    local ui = nil
    if not ui then return end
    local bk = NWT.Bookkeeper
    local numGuilds = GetNumGuilds()
    local guildId = GetGuildId(bk.viewingGuildIndex)
    local guildName = GetGuildName(guildId)
    local guildSettings = GetBookkeeperGuildSettings(guildId)
    local isSalesFocus = (bk.focusPanel == "sales")
    ui:GetNamedChild("Title"):SetText("|cFFFFFF" .. guildName .. "|r" .. (guildSettings.lastScanTime > 0 and " |c888888(Scanned " .. NWT.FormatTimeAgo(guildSettings.lastScanTime) .. ")|r" or ""))

    -- Build sorted guild list (favorites first)
    local sortedGuilds = {}
    for i = 1, numGuilds do
        local gId = GetGuildId(i)
        if gId and gId > 0 then
            table.insert(sortedGuilds, { index = i, guildId = gId, isFavorite = IsGuildFavorite(gId) })
        end
    end
    table.sort(sortedGuilds, function(a, b)
        if a.isFavorite ~= b.isFavorite then return a.isFavorite end
        return a.index < b.index
    end)
    bk.sortedGuildList = sortedGuilds  -- Store for navigation
    
    -- Update Guild Selection Panel
    local gp = ui:GetNamedChild("StatsPanel")
    if gp then
        gp:GetNamedChild("BG"):SetEdgeColor(isGuildsFocus and 1 or 0.3, isGuildsFocus and 0.8 or 0.3, isGuildsFocus and 0 or 0.3, 1)
        
        -- Position guild selection indicator
        local guildSel = gp:GetNamedChild("Selection")
        if guildSel then
            if isGuildsFocus and #sortedGuilds > 0 then
                local yOffsets = { 53, 88, 123, 158, 193 }
                local yPos = yOffsets[bk.selectedGuildIndex] or 53
                guildSel:ClearAnchors()
                guildSel:SetAnchor(TOPLEFT, gp, TOPLEFT, 15, yPos)
                guildSel:SetEdgeColor(1, 1, 1, 1)
                guildSel:SetHidden(false)
            else
                guildSel:SetHidden(true)
            end
        end
        
        for i = 1, 5 do
            local gLabel = gp:GetNamedChild("Guild" .. i)
            if gLabel then
                local guildData = sortedGuilds[i]
                if guildData then
                    local gId = guildData.guildId
                    local gName = GetGuildName(gId)
                    local isEnabled = IsGuildEnabled(gId)
                    local isFav = guildData.isFavorite
                    local isSelected = (bk.selectedGuildIndex == i)
                    local color = isEnabled and (isSelected and "|cFFD700" or "|cFFFFFF") or "|c888888"
                    local prefix = "  "
                    local starPrefix = isFav and "|cFFD700★|r " or ""
                    local suffix = isEnabled and "" or " |c888888(off)|r"
                    gLabel:SetText(color .. prefix .. starPrefix .. gName .. suffix)
                    gLabel:SetHidden(false)
                else
                    gLabel:SetHidden(true)
                end
            end
        end
    end

    local dp = ui:GetNamedChild("DuesList")
    if dp then
        dp:GetNamedChild("BG"):SetEdgeColor(isDuesFocus and 1 or 0.3, isDuesFocus and 0.8 or 0.3, isDuesFocus and 0 or 0.3, 1)
        for i = 1, bk.maxVisibleMembers do
            local nameLabel = dp:GetNamedChild("Row" .. i .. "Name")
            local monthsLabel = dp:GetNamedChild("Row" .. i .. "Months")
            local lastLabel = dp:GetNamedChild("Row" .. i .. "Last")
            local rankLabel = dp:GetNamedChild("Row" .. i .. "Rank")
            local mIdx = i + bk.memberScrollOffset
            local member = bk.sortedMembers[mIdx]
            
            if member then
                local isSel = (mIdx == bk.selectedMemberIndex)
                local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[member.name]
                local isExempt = member.isExemptRank
                local rank = member.rankIndex and GetGuildRankCustomName(guildId, member.rankIndex) or "Unknown"
                if not rank or rank == "" then rank = "R" .. (member.rankIndex or "?") end
                if #rank > 12 then rank = rank:sub(1,10) .. ".." end
                local displayName = member.name:gsub("^@", "")
                if #displayName > 14 then displayName = displayName:sub(1,12) .. ".." end
                local timeAgo = (member.lastPayment or 0) > 0 and NWT.FormatTimeAgo(member.lastPayment) or "Never"
                
                -- Color name based on status
                local nameColor = "|cFFFFFF"
                if isSel then nameColor = "|cFFD700"
                elseif isLife then nameColor = "|c00FFFF"
                elseif isExempt then nameColor = "|cFF00FF"
                elseif (member.thisWeekDues or 0) > 0 then nameColor = "|c00FF00"
                elseif (member.duesMonths or 0) > 0 then nameColor = "|cFFFF00"
                else nameColor = "|cFF4444" end
                
                local selMark = isSel and "►" or ""
                if nameLabel then nameLabel:SetText(nameColor .. selMark .. displayName .. "|r") nameLabel:SetHidden(false) end
                if monthsLabel then 
                    if isLife then monthsLabel:SetText("|c00FFFFLIFE|r")
                    elseif isExempt then monthsLabel:SetText("|cFF00FFEXMT|r")
                    else 
                        local periodSuffix = "w"
                        if guildSettings.duesPeriod == "monthly" then periodSuffix = "m"
                        elseif guildSettings.duesPeriod == "biweekly" then periodSuffix = "bw" end
                        monthsLabel:SetText(tostring(member.duesMonths) .. periodSuffix) 
                    end
                    monthsLabel:SetHidden(false) 
                end
                if lastLabel then 
                    if isLife or isExempt then lastLabel:SetText("|c888888---|r")
                    else lastLabel:SetText("|c888888" .. timeAgo .. "|r") end
                    lastLabel:SetHidden(false) 
                end
                if rankLabel then rankLabel:SetText("|c888888" .. rank .. "|r") rankLabel:SetHidden(false) end
                
                -- Position selection indicator on selected row
                if isSel then
                    local selection = dp:GetNamedChild("Selection")
                    if selection then
                        local rowY = 62 + (i - 1) * 34
                        selection:ClearAnchors()
                        selection:SetAnchor(TOPLEFT, dp, TOPLEFT, 10, rowY)
                        selection:SetHidden(not isDuesFocus or #bk.sortedMembers == 0)
                    end
                end
            else
                if nameLabel then nameLabel:SetText("") nameLabel:SetHidden(true) end
                if monthsLabel then monthsLabel:SetText("") monthsLabel:SetHidden(true) end
                if lastLabel then lastLabel:SetText("") lastLabel:SetHidden(true) end
                if rankLabel then rankLabel:SetText("") rankLabel:SetHidden(true) end
            end
        end
        -- Hide selection if list is empty
        if #bk.sortedMembers == 0 then
            local selection = dp:GetNamedChild("Selection")
            if selection then selection:SetHidden(true) end
        end
    end
    -- Calculate and display summary stats
    local paidCount, unpaidCount, prepaidCount, lifetimeCount, exemptCount = 0, 0, 0, 0, 0
    local totalDuesCollected, totalRaffleCollected = 0, 0
    local paidLastWeekCount = 0
    
    -- Calculate last week's Tuesday to this Tuesday (flip day)
    local now = GetTimeStamp()
    local currentTime = os.date("*t", now)
    local dayOfWeek = currentTime.wday  -- 1=Sunday, 3=Tuesday
    local daysSinceTuesday = (dayOfWeek - 3) % 7
    local thisTuesdayMidnight = now - (daysSinceTuesday * 86400) - (currentTime.hour * 3600) - (currentTime.min * 60) - currentTime.sec
    local lastTuesdayMidnight = thisTuesdayMidnight - (7 * 86400)
    
    for name, m in pairs(guildSettings.memberPayments or {}) do
        if m.isCurrentMember then
            local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[name]
            local isExempt = IsRankExempt(guildSettings, m.rankIndex, guildId)
            if isLife then lifetimeCount = lifetimeCount + 1
            elseif isExempt then exemptCount = exemptCount + 1
            elseif m.thisWeekDues > 0 then paidCount = paidCount + 1
            elseif m.duesMonths > 0 then prepaidCount = prepaidCount + 1
            elseif m.isPaidViaNote then paidCount = paidCount + 1  -- Note-based paid
            else unpaidCount = unpaidCount + 1 end
            totalDuesCollected = totalDuesCollected + (m.totalDeposited or 0) - (m.raffleTotal or 0) - (m.otherTotal or 0)
            totalRaffleCollected = totalRaffleCollected + (m.raffleTotal or 0)
            
            -- Count paid last week (excluding exempt/lifetime)
            if not isLife and not isExempt and m.deposits then
                for _, dep in ipairs(m.deposits) do
                    if dep.type == "dues" and dep.timestamp >= lastTuesdayMidnight and dep.timestamp < thisTuesdayMidnight then
                        paidLastWeekCount = paidLastWeekCount + 1
                        break  -- Only count each member once
                    end
                end
            end
        end
    end
    
    local summary = dp and dp:GetNamedChild("Summary")
    if summary then
        summary:SetText(string.format("|c00FF00%d|r Paid   |cFFFF00%d|r Pre   |cFF6666%d|r Owe", paidCount, prepaidCount, unpaidCount))
    end
    
    -- Stats panel (left side)
    local statPanel = ui:GetNamedChild("ExtraStatsPanel")
    if statPanel then
        local s1 = statPanel:GetNamedChild("Members")
        local s2 = statPanel:GetNamedChild("Collected")
        local s3 = statPanel:GetNamedChild("Raffle")
        local s4 = statPanel:GetNamedChild("LastWeek")
        if s1 then s1:SetText(string.format("|cFFFFAAMembers:|r %d", GetNumGuildMembers(guildId))) end
        if s2 then s2:SetText(string.format("|cFFFFAADues:|r |c00FF00%sg|r", NWT.FormatGold(totalDuesCollected))) end
        if s3 then s3:SetText(string.format("|cFFFFAARaffle:|r |c00FF00%sg|r", NWT.FormatGold(totalRaffleCollected))) end
        if s4 then s4:SetText(string.format("|cFFFFAAPaid Last Wk:|r |cAAFFAA%d|r", paidLastWeekCount)) end
    end
    
    -- Raffle panel removed - now a separate feature
    local rafflePanel = ui:GetNamedChild("RaffleList")
    if rafflePanel then
        rafflePanel:SetHidden(true) -- Raffle is now separate
    end

    -- Sales Panel
    local salesPanel = ui:GetNamedChild("SalesList")
    if salesPanel then
        salesPanel:GetNamedChild("BG"):SetEdgeColor(isSalesFocus and 1 or 0.3, isSalesFocus and 0.8 or 0.3, isSalesFocus and 0 or 0.3, 1)
        salesPanel:SetHidden(not isSalesFocus)
        
        local salesEntries = {}
        local totalSalesGold = 0
        if guildSettings.salesData then
            for eventId, sale in pairs(guildSettings.salesData) do
                table.insert(salesEntries, sale)
                totalSalesGold = totalSalesGold + (sale.price or 0)
            end
        end
        table.sort(salesEntries, function(a, b) return (a.timestamp or 0) > (b.timestamp or 0) end)
        bk.salesEntriesCount = #salesEntries

        local header = salesPanel:GetNamedChild("Header")
        if header then header:SetText("|c00FFFFRecent Sales|r") end

        for i = 1, bk.maxVisibleSales do
            local nameLabel = salesPanel:GetNamedChild("Row" .. i .. "Name")
            local itemLabel = salesPanel:GetNamedChild("Row" .. i .. "Item")
            local goldLabel = salesPanel:GetNamedChild("Row" .. i .. "Gold")
            
            local entryIdx = i + bk.salesScrollOffset
            local entry = salesEntries[entryIdx]
            if entry then
                local sellerShort = entry.seller:gsub("^@", "")
                if #sellerShort > 10 then sellerShort = sellerShort:sub(1,8) .. ".." end
                
                if nameLabel then nameLabel:SetText("|cFFFFFF" .. sellerShort .. "|r") nameLabel:SetHidden(false) end
                if itemLabel then 
                    local itemLink = entry.itemLink or "Item"
                    itemLabel:SetText(itemLink) 
                    itemLabel:SetHidden(false) 
                end
                if goldLabel then goldLabel:SetText("|c00FF00" .. NWT.FormatGold(entry.price) .. "|r") goldLabel:SetHidden(false) end
            else
                if nameLabel then nameLabel:SetText("") nameLabel:SetHidden(true) end
                if itemLabel then itemLabel:SetText("") itemLabel:SetHidden(true) end
                if goldLabel then goldLabel:SetText("") goldLabel:SetHidden(true) end
            end
        end

        local totalLabel = salesPanel:GetNamedChild("Total")
        if totalLabel then
            totalLabel:SetText(string.format("|cFFFF00%d sales|r |c00FF00%sg|r", #salesEntries, NWT.FormatGold(totalSalesGold)))
        end
    end

    local ctrl = ui:GetNamedChild("Controls")
    if ctrl then 
        local focusHint = ""
        if isGuildsFocus then focusHint = "|cFFFFFFGuilds|r |c888888→ Dues → Sales|r"
        elseif isDuesFocus then focusHint = "|c888888Guilds ←|r |cFFFFFFDues|r |c888888→ Sales|r"
        else focusHint = "|c888888Guilds ← Dues ←|r |cFFFFFFSales|r" end
        ctrl:SetText(string.format("|c888888[LB/RB] Navigate  [A] Select  [RS] Scan|r  %s", focusHint))
    end
    
    -- Show/hide confirmation dialog (dynamically created)
    if bk.confirmDialogOpen and bk.pendingNoteUpdate then
        ShowConfirmDialog(bk.pendingNoteUpdate)
    else
        HideConfirmDialog()
    end
end

-- ============================================
-- NEW UI UPDATE FUNCTION
-- ============================================

function NWT.UpdateBookkeeperUI_New(ui, bk, guildId, guildName, guildSettings, isGuildsFocus, isDuesFocus, numGuilds)
    local freeTraderMode = IsFreeTraderMode(guildSettings)
    local listingTarget = GetListingTarget(guildSettings)
    local function GetCurrentFilterLabel()
        if freeTraderMode then
            if bk.filterMode == 2 then return "No Listings" end
            if bk.filterMode == 3 then return "Has Listings" end
        end
        return bk.filterModes[bk.filterMode] or "All Members"
    end

    -- Header
    local header = ui:GetNamedChild("Header")
    if header then
        local title = header:GetNamedChild("Title")
        local subtitle = header:GetNamedChild("Subtitle")
        if title then title:SetText("|c00FFFFGUILD BOOKKEEPER|r") end
        if subtitle then 
            local scanTime = freeTraderMode and (guildSettings.listingsLastScanTime or 0) or (guildSettings.lastScanTime or 0)
            local scanText = scanTime > 0 and " • Scanned " .. NWT.FormatTimeAgo(scanTime) or ""
            if freeTraderMode and guildSettings.listingsScanInProgress then
                scanText = " • Scanning listings..."
            end
            subtitle:SetText("|cFFFFFF" .. guildName .. "|r" .. scanText)
        end
    end
    
    -- Build sorted guild list (favorites first) - use demo data if in demo mode
    local sortedGuilds = {}
    if bk.demoMode then
        for i, dg in ipairs(DEMO_GUILDS) do
            table.insert(sortedGuilds, { index = i, guildId = dg.id, name = dg.name, isFavorite = dg.isFavorite, memberCount = dg.memberCount })
        end
    else
        for i = 1, numGuilds do
            local gId = GetGuildId(i)
            if gId and gId > 0 then
                table.insert(sortedGuilds, { index = i, guildId = gId, isFavorite = IsGuildFavorite(gId) })
            end
        end
        table.sort(sortedGuilds, function(a, b)
            if a.isFavorite ~= b.isFavorite then return a.isFavorite end
            return a.index < b.index
        end)
    end
    bk.sortedGuildList = sortedGuilds
    
    -- Left Column: Guilds Card
    local leftCol = ui:GetNamedChild("LeftCol")
    if leftCol then
        local gCard = leftCol:GetNamedChild("GuildsCard")
        if gCard then
            local gBG = gCard:GetNamedChild("BG")
            local gFocus = gCard:GetNamedChild("FocusGlow")
            local gPlate = gCard:GetNamedChild("HeaderPlate")
            if isGuildsFocus then
                if gBG then gBG:SetEdgeColor(0, 0.8, 0.8, 1) end
                if gFocus then gFocus:SetHidden(false) end
                if gPlate then gPlate:SetEdgeColor(0, 0.8, 0.8, 1) end
            else
                if gBG then gBG:SetEdgeColor(0.3, 0.3, 0.3, 1) end
                if gFocus then gFocus:SetHidden(true) end
                if gPlate then gPlate:SetEdgeColor(0.3, 0.3, 0.3, 1) end
            end
            
            local gList = gCard:GetNamedChild("List")
            if gList then
                for i = 1, 5 do
                    local gLabel = gList:GetNamedChild("Guild" .. i)
                    if not gLabel then
                        gLabel = WINDOW_MANAGER:CreateControl("$(parent)Guild" .. i, gList, CT_LABEL)
                        gLabel:SetFont("ZoFontGamepad34")
                        gLabel:SetDimensions(320, 45)
                        gLabel:SetAnchor(TOPLEFT, gList, TOPLEFT, 20, (i-1) * 45)
                    end
                    
                    local guildData = sortedGuilds[i]
                    if guildData then
                        local gName = bk.demoMode and guildData.name or GetGuildName(guildData.guildId)
                        local isEnabled = true
                        local isFav = guildData.isFavorite
                        local isSelected = (bk.selectedGuildIndex == i)
                        
                        local color = isEnabled and (isSelected and "|c00FFFF" or "|cFFFFFF") or "|c888888"
                        local starPrefix = isFav and "|cFFD700★|r " or ""
                        local prefix = isSelected and "► " or "  "
                        local suffix = isEnabled and "" or " (off)"
                        gLabel:SetText(color .. prefix .. starPrefix .. gName .. suffix .. "|r")
                        gLabel:SetHidden(false)
                    else
                        gLabel:SetHidden(true)
                    end
                end
                
                -- Guild selection frame
                local gSelFrame = gList:GetNamedChild("SelectionFrame")
                if gSelFrame then
                    if isGuildsFocus and #sortedGuilds > 0 then
                        gSelFrame:ClearAnchors()
                        gSelFrame:SetAnchor(TOPLEFT, gList, TOPLEFT, 5, (bk.selectedGuildIndex - 1) * 45)
                        gSelFrame:SetHidden(false)
                    else
                        gSelFrame:SetHidden(true)
                    end
                end
            end
        end
        
        -- Stats Card
        local sCard = leftCol:GetNamedChild("StatsCard")
        if sCard then
            local paidCount, unpaidCount, prepaidCount, lifetimeCount, exemptCount = 0, 0, 0, 0, 0
            local totalDuesCollected, totalRaffleCollected = 0, 0
            local listedCount, targetMetCount, totalListings = 0, 0, 0

            for name, m in pairs(guildSettings.memberPayments or {}) do
                if m.isCurrentMember then
                    local listingCount = guildSettings.memberListingCounts and (tonumber(guildSettings.memberListingCounts[name]) or 0) or 0
                    if listingCount > 0 then listedCount = listedCount + 1 end
                    if listingCount >= listingTarget then targetMetCount = targetMetCount + 1 end
                    totalListings = totalListings + listingCount

                    local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[name]
                    local isExempt = IsRankExempt(guildSettings, m.rankIndex, guildId)
                    if isLife then lifetimeCount = lifetimeCount + 1
                    elseif isExempt then exemptCount = exemptCount + 1
                    elseif m.thisWeekDues > 0 then paidCount = paidCount + 1
                    elseif m.duesMonths > 0 then prepaidCount = prepaidCount + 1
                    elseif m.isPaidViaNote then paidCount = paidCount + 1
                    else unpaidCount = unpaidCount + 1 end
                    totalDuesCollected = totalDuesCollected + (m.totalDeposited or 0) - (m.raffleTotal or 0) - (m.otherTotal or 0)
                    totalRaffleCollected = totalRaffleCollected + (m.raffleTotal or 0)
                end
            end

            local members = sCard:GetNamedChild("Members")
            local paidLabel = sCard:GetNamedChild("PaidCount")
            local unpaidLabel = sCard:GetNamedChild("UnpaidCount")
            local lifeLabel = sCard:GetNamedChild("LifetimeCount")
            local duesLabel = sCard:GetNamedChild("DuesCollected")
            local raffleLabel = sCard:GetNamedChild("RaffleCollected")
            local duesAmtLabel = sCard:GetNamedChild("DuesAmount")
            local scanLabel = sCard:GetNamedChild("LastScan")
            
            local memberCount = bk.demoMode and (DEMO_GUILDS[bk.viewingGuildIndex] and DEMO_GUILDS[bk.viewingGuildIndex].memberCount or 500) or GetNumGuildMembers(guildId)
            if members then members:SetText(string.format("|c00FFFFMembers:|r  |cFFFFFF%d|r", memberCount)) end
            if freeTraderMode then
                if paidLabel then paidLabel:SetText(string.format("|c00FF00Listed:|r  |cFFFFFF%d|r  |cFFFF00Target:|r  |cFFFFFF%d|r", listedCount, targetMetCount)) end
                if unpaidLabel then unpaidLabel:SetText(string.format("|cFF4444Not Listed:|r  |cFFFFFF%d|r", math.max(0, memberCount - listedCount))) end
                if lifeLabel then lifeLabel:SetText(string.format("|c00FFFFTarget Per Member:|r  |cFFFFFF%d|r", listingTarget)) end
                if duesLabel then duesLabel:SetText(string.format("|c00FFFFTotal Listings:|r  |cFFFFFF%d|r", totalListings)) end
                if raffleLabel then raffleLabel:SetText("|c888888Dues status disabled in Free Trader mode|r") end
                if duesAmtLabel then duesAmtLabel:SetText(string.format("|c00FFFFListings Goal:|r  |cFFFFFF%d|r", listingTarget)) end
            else
                if paidLabel then paidLabel:SetText(string.format("|c00FF00Paid:|r  |cFFFFFF%d|r  |cFFFF00Pre:|r  |cFFFFFF%d|r", paidCount, prepaidCount)) end
                if unpaidLabel then unpaidLabel:SetText(string.format("|cFF4444Unpaid:|r  |cFFFFFF%d|r", unpaidCount)) end
                if lifeLabel then lifeLabel:SetText(string.format("|c00FFFFLifetime:|r  |cFFFFFF%d|r  |c888888Exempt:|r  |cFFFFFF%d|r", lifetimeCount, exemptCount)) end
                if duesLabel then duesLabel:SetText(string.format("|c00FFFFDues Total:|r  |c00FF00%sg|r", NWT.FormatGold(totalDuesCollected))) end
                if raffleLabel then raffleLabel:SetText(string.format("|c00FFFFRaffle Total:|r  |c00FF00%sg|r", NWT.FormatGold(totalRaffleCollected))) end
                if duesAmtLabel then duesAmtLabel:SetText(string.format("|c00FFFFDues Amount:|r  |cFFFFFF%sg|r", NWT.FormatGold(guildSettings.duesAmount or 5000))) end
            end
            if scanLabel then
                local lastScan = freeTraderMode and (guildSettings.listingsLastScanTime or 0) or (guildSettings.lastScanTime or 0)
                local scanText = lastScan > 0 and NWT.FormatTimeAgo(lastScan) or "Not scanned"
                if freeTraderMode and guildSettings.listingsScanInProgress then
                    scanText = "Scanning..."
                end
                local scanPrefix = freeTraderMode and "Listings scan: " or "Last scan: "
                scanLabel:SetText("|c888888" .. scanPrefix .. scanText .. "|r")
            end
        end
    end
    
    -- Members Column
    local membersCol = ui:GetNamedChild("MembersCol")
    if membersCol then
        local mBG = membersCol:GetNamedChild("BG")
        local mFocus = membersCol:GetNamedChild("FocusGlow")
        local mPlate = membersCol:GetNamedChild("HeaderPlate")
        if isDuesFocus then
            if mBG then mBG:SetEdgeColor(0, 0.8, 0.8, 1) end
            if mFocus then mFocus:SetHidden(false) end
            if mPlate then mPlate:SetEdgeColor(0, 0.8, 0.8, 1) end
        else
            if mBG then mBG:SetEdgeColor(0.3, 0.3, 0.3, 1) end
            if mFocus then mFocus:SetHidden(true) end
            if mPlate then mPlate:SetEdgeColor(0.3, 0.3, 0.3, 1) end
        end
        
        local mHeader = membersCol:GetNamedChild("Header")
        if mHeader then
            local searchInfo = ""
            if bk.searchText and bk.searchText ~= "" then
                searchInfo = "  •  Search: |cFFD700" .. bk.searchText .. "|r"
            end
            mHeader:SetText(string.format("|c00FFFF%d MEMBERS|r  •  |cFFFFFF%s|r%s", #bk.sortedMembers, GetCurrentFilterLabel(), searchInfo))
        end

        local colStatus = membersCol:GetNamedChild("ColStatus")
        if colStatus then
            if freeTraderMode then
                colStatus:SetText("|c888888Listings|r")
            else
                colStatus:SetText("|c888888Due In|r")
            end
        end
        
        local list = membersCol:GetNamedChild("List")
        local selectionFrame = list and list:GetNamedChild("SelectionFrame")
        
        for i = 1, 13 do
            local row = list and list:GetNamedChild("Row" .. i)
            if row then
                local mIdx = i + bk.memberScrollOffset
                local member = bk.sortedMembers[mIdx]
                
                if member then
                    local displayName = member.name:gsub("^@", "")
                    if #displayName > 18 then displayName = displayName:sub(1,16) .. ".." end
                    
                    local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[member.name]
                    local isExempt = member.isExemptRank
                    local rank
                    if bk.demoMode then
                        rank = (member.rankIndex and DEMO_RANKS[member.rankIndex] and DEMO_RANKS[member.rankIndex].name) or ("R" .. (member.rankIndex or "?"))
                    else
                        rank = (member.rankIndex and GetGuildRankCustomName(guildId, member.rankIndex)) or ("R" .. (member.rankIndex or "?"))
                    end
                    if #rank > 12 then rank = rank:sub(1,10) .. ".." end
                    
                    -- Status color and text
                    local statusText, statusColor
                    if freeTraderMode then
                        local listingsCount = tonumber(member.listingsCount) or 0
                        statusText = string.format("%d/%d", listingsCount, listingTarget)
                        if listingsCount >= listingTarget then
                            statusColor = "|c00FF00"
                        elseif listingsCount > 0 then
                            statusColor = "|cFFFF00"
                        else
                            statusColor = "|cFF4444"
                        end
                    else
                        if isLife then statusText, statusColor = "LIFE", "|c00FFFF"
                        elseif isExempt then statusText, statusColor = "EXMT", "|cFF00FF"
                        elseif (member.thisWeekDues or 0) > 0 then statusText, statusColor = "PAID", "|c00FF00"
                        elseif (member.duesMonths or 0) > 0 then 
                            local periodSuffix = "w"  -- Default to weeks
                            if guildSettings.duesPeriod == "monthly" then periodSuffix = "m"
                            elseif guildSettings.duesPeriod == "biweekly" then periodSuffix = "bw" end
                            statusText, statusColor = (member.duesMonths or 0) .. periodSuffix, "|cFFFF00"
                        elseif member.isPaidViaNote then 
                            -- Show days until due instead of just "NOTE"
                            local days = member.daysUntilDue or 0
                            if days == 0 then
                                statusText = "DUE"
                            elseif days >= 7 then
                                statusText = math.floor(days / 7) .. "w"
                            else
                                statusText = days .. "d"
                            end
                            statusColor = "|c00FF00"
                        elseif member.daysOverdue and member.daysOverdue > 0 then
                            -- Show how long overdue based on note (add "ago" for clarity)
                            if member.daysOverdue >= 7 then
                                statusText = math.floor(member.daysOverdue / 7) .. "w ago"
                            else
                                statusText = member.daysOverdue .. "d ago"
                            end
                            statusColor = "|cFF6600"  -- Orange for overdue
                        else statusText, statusColor = "OWED", "|cFF4444"
                        end
                    end
                    
                    local isSel = (mIdx == bk.selectedMemberIndex)
                    local nameColor = isSel and "|c00FFFF" or "|cFFFFFF"
                    local timeAgo = (member.lastPayment or 0) > 0 and NWT.FormatTimeAgo(member.lastPayment) or "Never"
                    
                    row:GetNamedChild("Num"):SetText("|c888888" .. mIdx .. "|r")
                    row:GetNamedChild("Name"):SetText(nameColor .. displayName .. "|r")
                    row:GetNamedChild("Status"):SetText(statusColor .. statusText .. "|r")
                    row:GetNamedChild("Rank"):SetText("|c888888" .. rank .. "|r")
                    row:GetNamedChild("LastPay"):SetText("|c888888" .. timeAgo .. "|r")
                    
                    -- Calculate total guild income contribution (deposits + taxes from sales)
                    local deposits = member.totalDeposited or 0
                    local taxes = guildSettings.memberTaxTotals and guildSettings.memberTaxTotals[member.name] or 0
                    local totalIncome = deposits + taxes
                    local incomeLabel = row:GetNamedChild("Income")
                    if incomeLabel then
                        if totalIncome > 0 then
                            incomeLabel:SetText("|c00FF00" .. NWT.FormatGold(totalIncome) .. "|r")
                        else
                            incomeLabel:SetText("|c555555-|r")
                        end
                    end
                    
                    -- Last Online column
                    local lastOnlineLabel = row:GetNamedChild("LastOnline")
                    if lastOnlineLabel then
                        local lastOnline = member.lastOnline or 0
                        if lastOnline > 0 then
                            local onlineAgo = NWT.FormatTimeAgo(lastOnline)
                            -- Color based on how long ago
                            local daysSinceOnline = (GetTimeStamp() - lastOnline) / 86400
                            local onlineColor = "|c00FF00"  -- Green for recent
                            if daysSinceOnline > 30 then onlineColor = "|cFF4444"  -- Red for 30+ days
                            elseif daysSinceOnline > 14 then onlineColor = "|cFF6600"  -- Orange for 14+ days
                            elseif daysSinceOnline > 7 then onlineColor = "|cFFFF00"  -- Yellow for 7+ days
                            end
                            lastOnlineLabel:SetText(onlineColor .. onlineAgo .. "|r")
                        else
                            lastOnlineLabel:SetText("|c555555-|r")
                        end
                    end
                    
                    if isSel and selectionFrame then
                        selectionFrame:ClearAnchors()
                        selectionFrame:SetAnchor(TOPLEFT, row, TOPLEFT, -5, -2)
                        selectionFrame:SetHidden(not isDuesFocus)
                    end
                    
                    row:SetHidden(false)
                else
                    row:SetHidden(true)
                end
            end
        end
        
        if not isDuesFocus and selectionFrame then
            selectionFrame:SetHidden(true)
        end
        
        -- Summary
        local summary = membersCol:GetNamedChild("Summary")
        if summary then
            if freeTraderMode then
                local noListings, listedCount, metTarget = 0, 0, 0
                for _, m in ipairs(bk.sortedMembers) do
                    local listingsCount = tonumber(m.listingsCount) or 0
                    if listingsCount <= 0 then
                        noListings = noListings + 1
                    else
                        listedCount = listedCount + 1
                        if listingsCount >= listingTarget then
                            metTarget = metTarget + 1
                        end
                    end
                end
                summary:SetText(string.format("|c00FF00%d Target|r   |cFFFF00%d Listed|r   |cFF4444%d None|r", metTarget, listedCount, noListings))
            else
                local paidCount, unpaidCount, prepaidCount = 0, 0, 0
                for _, m in ipairs(bk.sortedMembers) do
                    local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[m.name]
                    local isExempt = m.isExemptRank
                    if not isLife and not isExempt then
                        if m.thisWeekDues > 0 then paidCount = paidCount + 1
                        elseif m.duesMonths > 0 then prepaidCount = prepaidCount + 1
                        elseif m.isPaidViaNote then paidCount = paidCount + 1  -- Note-based paid
                        else unpaidCount = unpaidCount + 1 end
                    end
                end
                summary:SetText(string.format("|c00FF00%d Paid|r   |cFFFF00%d Pre|r   |cFF4444%d Owe|r", paidCount, prepaidCount, unpaidCount))
            end
        end
    end
    
    -- Right Column: Filter and Selected Member
    local rightCol = ui:GetNamedChild("RightCol")
    if rightCol then
        -- Filter Card
        local filterCard = rightCol:GetNamedChild("FilterCard")
        if filterCard then
            local currentFilter = filterCard:GetNamedChild("CurrentFilter")
            if currentFilter then
                local filterText = GetCurrentFilterLabel()
                local filterColor = bk.filterMode == 1 and "|cFFFFFF" or (bk.filterMode == 2 and "|cFF6666" or "|c00FF00")
                currentFilter:SetText(filterColor .. filterText .. "|r")
            end
        end
        
        -- Selected Member Card (expanded - no more Actions Card)
        local selCard = rightCol:GetNamedChild("SelectedCard")
        if selCard then
            local member = bk.sortedMembers[bk.selectedMemberIndex]
            if member then
                local displayName = member.name:gsub("^@", "")
                if #displayName > 18 then displayName = displayName:sub(1,16) .. ".." end
                
                -- Get sales data for this member
                local salesData = guildSettings.memberSalesData and guildSettings.memberSalesData[member.name]
                local totalSales = salesData and salesData.totalSales or 0
                local saleCount = salesData and salesData.saleCount or 0
                local taxes = guildSettings.memberTaxTotals and guildSettings.memberTaxTotals[member.name] or 0
                local avgSale = saleCount > 0 and math.floor(totalSales / saleCount) or 0
                
                -- Status calculation
                local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[member.name]
                local isExempt = member.isExemptRank
                local statusText
                if freeTraderMode then
                    local listingsCount = tonumber(member.listingsCount) or 0
                    if listingsCount >= listingTarget then
                        statusText = string.format("|c00FF00LISTINGS: %d/%d|r", listingsCount, listingTarget)
                    elseif listingsCount > 0 then
                        statusText = string.format("|cFFFF00LISTINGS: %d/%d|r", listingsCount, listingTarget)
                    else
                        statusText = string.format("|cFF4444LISTINGS: %d/%d|r", listingsCount, listingTarget)
                    end
                else
                    if isLife then statusText = "|c00FFFFLIFETIME|r"
                    elseif isExempt then statusText = "|cFF00FFEXEMPT|r"
                    elseif (member.thisWeekDues or 0) > 0 then statusText = "|c00FF00PAID|r"
                    elseif (member.duesMonths or 0) > 0 then statusText = "|cFFFF00PRE-PAID|r"
                    elseif member.isPaidViaNote then
                        local days = member.daysUntilDue or 0
                        if days == 0 then statusText = "|c00FF00DUE TODAY|r"
                        elseif days >= 7 then statusText = "|c00FF00" .. math.floor(days / 7) .. "w until due|r"
                        else statusText = "|c00FF00" .. days .. "d until due|r" end
                    else statusText = "|cFF4444UNPAID|r" end
                end
                
                -- Header section
                local nameLabel = selCard:GetNamedChild("Name")
                local statusLabel = selCard:GetNamedChild("Status")
                if nameLabel then nameLabel:SetText("|c00FFFF" .. displayName .. "|r") end
                if statusLabel then statusLabel:SetText(statusText) end
                
                -- Deposits section
                local totalDepLabel = selCard:GetNamedChild("TotalDeposited")
                local duesLabel = selCard:GetNamedChild("DuesPaid")
                local raffleLabel = selCard:GetNamedChild("RafflePaid")
                local otherLabel = selCard:GetNamedChild("OtherDeposits")
                
                local duesTotal = (member.duesTotal or 0)
                if totalDepLabel then totalDepLabel:SetText(string.format("|c888888Total:|r |c00FF00%s|r", NWT.FormatGold(member.totalDeposited or 0))) end
                if duesLabel then
                    if freeTraderMode then
                        duesLabel:SetText(string.format("|c888888Listings:|r |cFFFFFF%d/%d|r", tonumber(member.listingsCount) or 0, listingTarget))
                    else
                        duesLabel:SetText(string.format("|c888888Dues:|r |c00FF00%s|r (%dm)", NWT.FormatGold(duesTotal), member.duesMonths or 0))
                    end
                end
                if raffleLabel then raffleLabel:SetText(string.format("|c888888Raffle:|r |cFFFF00%s|r", NWT.FormatGold(member.raffleTotal or 0))) end
                if otherLabel then otherLabel:SetText(string.format("|c888888Other:|r |c888888%s|r", NWT.FormatGold(member.otherTotal or 0))) end
                
                -- Trading section
                local totalSalesLabel = selCard:GetNamedChild("TotalSales")
                local saleCountLabel = selCard:GetNamedChild("SaleCount")
                local taxesLabel = selCard:GetNamedChild("TaxesPaid")
                local avgSaleLabel = selCard:GetNamedChild("AvgSale")
                
                if totalSalesLabel then totalSalesLabel:SetText(string.format("|c888888Sales:|r |c00FF00%s|r", NWT.FormatGold(totalSales))) end
                if saleCountLabel then saleCountLabel:SetText(string.format("|c888888# Sales:|r |cFFFFFF%d|r", saleCount)) end
                if taxesLabel then taxesLabel:SetText(string.format("|c888888Taxes:|r |cFF6600%s|r", NWT.FormatGold(taxes))) end
                if avgSaleLabel then avgSaleLabel:SetText(string.format("|c888888Avg Sale:|r |cFFFFFF%s|r", NWT.FormatGold(avgSale))) end
                
                -- Activity section
                local totalIncomeLabel = selCard:GetNamedChild("TotalIncome")
                local lastPayLabel = selCard:GetNamedChild("LastPayment")
                local lastOnlineLabel = selCard:GetNamedChild("LastOnline")
                local depositCountLabel = selCard:GetNamedChild("DepositCount")
                
                local totalIncome = (member.totalDeposited or 0) + taxes
                local lastPayStr = (member.lastPayment or 0) > 0 and NWT.FormatTimeAgo(member.lastPayment) or "Never"
                local lastOnlineStr = member.lastOnline and member.lastOnline > 0 and NWT.FormatTimeAgo(member.lastOnline) or "Unknown"
                local depositCount = member.deposits and #member.deposits or 0
                
                if totalIncomeLabel then totalIncomeLabel:SetText(string.format("|c888888Income:|r |c00FF00%s|r", NWT.FormatGold(totalIncome))) end
                if lastPayLabel then lastPayLabel:SetText(string.format("|c888888Last Pay:|r |c888888%s|r", lastPayStr)) end
                if lastOnlineLabel then lastOnlineLabel:SetText(string.format("|c888888Online:|r |c888888%s|r", lastOnlineStr)) end
                if depositCountLabel then depositCountLabel:SetText(string.format("|c888888Deposits:|r |cFFFFFF%d|r", depositCount)) end
            else
                local nameLabel = selCard:GetNamedChild("Name")
                local statusLabel = selCard:GetNamedChild("Status")
                if nameLabel then nameLabel:SetText("|c888888No member selected|r") end
                if statusLabel then statusLabel:SetText("") end
            end
        end
    end
end

function NWT.BookkeeperSwitchPanel(dir)
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen or bk.settingsMenuOpen then return end
    
    -- Only two panels now: guilds and dues (actions panel removed)
    if dir == "right" then
        if bk.focusPanel == "guilds" then bk.focusPanel = "dues" end
    else
        if bk.focusPanel == "dues" then bk.focusPanel = "guilds" end
    end
    
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateBookkeeperUI()
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

function NWT.BookkeeperScrollAction(dir)
    local bk = NWT.Bookkeeper
    local count = #QUICK_ACTIONS
    if count == 0 then return end
    
    if dir == "up" then
        bk.selectedActionIndex = math.max(1, bk.selectedActionIndex - 1)
    else
        bk.selectedActionIndex = math.min(count, bk.selectedActionIndex + 1)
    end
    
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperExecuteAction()
    local bk = NWT.Bookkeeper
    local action = QUICK_ACTIONS[bk.selectedActionIndex]
    if action and action.callback then
        PlaySound(SOUNDS.POSITIVE_CLICK)
        action.callback()
    end
end

function NWT.BookkeeperScrollGuild(dir)
    local bk = NWT.Bookkeeper
    local nG = bk.demoMode and #DEMO_GUILDS or GetNumGuilds()
    if nG == 0 then return end
    
    if dir == "up" then
        bk.selectedGuildIndex = math.max(1, bk.selectedGuildIndex - 1)
    else
        bk.selectedGuildIndex = math.min(nG, bk.selectedGuildIndex + 1)
    end
    
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperScrollMember(dir)
    local bk = NWT.Bookkeeper
    local count = #bk.sortedMembers or 0
    if count == 0 then return end
    
    if dir == "up" then
        bk.selectedMemberIndex = math.max(1, bk.selectedMemberIndex - 1)
    else
        bk.selectedMemberIndex = math.min(count, bk.selectedMemberIndex + 1)
    end
    
    -- Adjust scroll offset to keep selection visible
    if bk.selectedMemberIndex <= bk.memberScrollOffset then
        bk.memberScrollOffset = bk.selectedMemberIndex - 1
    elseif bk.selectedMemberIndex > bk.memberScrollOffset + 12 then
        bk.memberScrollOffset = bk.selectedMemberIndex - 12
    end
    bk.memberScrollOffset = math.max(0, bk.memberScrollOffset)
    
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperPageMember(dir)
    local bk = NWT.Bookkeeper
    local count = #bk.sortedMembers or 0
    if count == 0 then return end
    
    local pageSize = 10  -- Jump by 10 members
    if dir == "up" then
        bk.selectedMemberIndex = math.max(1, bk.selectedMemberIndex - pageSize)
    else
        bk.selectedMemberIndex = math.min(count, bk.selectedMemberIndex + pageSize)
    end
    
    -- Adjust scroll offset to keep selection visible
    if bk.selectedMemberIndex <= bk.memberScrollOffset then
        bk.memberScrollOffset = bk.selectedMemberIndex - 1
    elseif bk.selectedMemberIndex > bk.memberScrollOffset + 12 then
        bk.memberScrollOffset = bk.selectedMemberIndex - 12
    end
    bk.memberScrollOffset = math.max(0, bk.memberScrollOffset)
    
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperScrollSales(dir)
    local bk = NWT.Bookkeeper
    local count = bk.salesEntriesCount or 0
    
    if dir == "up" and bk.salesScrollOffset > 0 then
        bk.salesScrollOffset = bk.salesScrollOffset - 1
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    elseif dir == "down" and bk.salesScrollOffset < math.max(0, count - bk.maxVisibleSales) then
        bk.salesScrollOffset = bk.salesScrollOffset + 1
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    end
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperScrollRaffle(dir)
    local bk = NWT.Bookkeeper
    local count = bk.raffleEntriesCount or 0
    
    if dir == "up" and bk.raffleScrollOffset > 0 then
        bk.raffleScrollOffset = bk.raffleScrollOffset - 1
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    elseif dir == "down" and bk.raffleScrollOffset < math.max(0, count - bk.maxVisibleRaffle) then
        bk.raffleScrollOffset = bk.raffleScrollOffset + 1
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    end
    NWT.UpdateBookkeeperUI()
end

local ATK_HiddenBookkeeperListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenBookkeeperListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenBookkeeperListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, NWT.BookkeeperScene) end
function ATK_HiddenBookkeeperListScreen:PerformUpdate() end
local function GetSelectedGuildId()
    local bk = NWT.Bookkeeper
    if bk.sortedGuildList and bk.sortedGuildList[bk.selectedGuildIndex] then
        return bk.sortedGuildList[bk.selectedGuildIndex].guildId
    end
    return GetGuildId(bk.selectedGuildIndex)
end

function NWT.BookkeeperToggleSelectedGuild()
    local guildId = GetSelectedGuildId()
    if not guildId or guildId == 0 then return end
    ToggleGuildEnabled(guildId)
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperFavoriteSelectedGuild()
    local guildId = GetSelectedGuildId()
    if not guildId or guildId == 0 then return end
    ToggleGuildFavorite(guildId)
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperSelectGuild()
    local bk = NWT.Bookkeeper
    
    -- In demo mode, just use the selected index directly
    if bk.demoMode then
        bk.viewingGuildIndex = bk.selectedGuildIndex
    else
        local guildId = GetSelectedGuildId()
        if not guildId or guildId == 0 then return end
        -- Find the actual guild index for viewingGuildIndex
        local actualIndex = bk.selectedGuildIndex
        if bk.sortedGuildList and bk.sortedGuildList[bk.selectedGuildIndex] then
            actualIndex = bk.sortedGuildList[bk.selectedGuildIndex].index
        end
        bk.viewingGuildIndex = actualIndex
    end
    
    -- Save the last selected guild
    if NWT.savedVars and NWT.savedVars.bookkeeper then
        NWT.savedVars.bookkeeper.lastGuildIndex = bk.selectedGuildIndex
    end
    -- Switch to Dues panel to view the selected guild
    bk.focusPanel = "dues"
    bk.selectedMemberIndex = 1
    bk.memberScrollOffset = 0
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateBookkeeperUI()
    NWT.SyncHiddenBookkeeperList()
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

function ATK_HiddenBookkeeperListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() 
              if NWT.Bookkeeper.raffleWinner then return "Reroll" end 
              if NWT.Bookkeeper.memberDetailsOpen then return "Close" end
              if NWT.Bookkeeper.duesSettingsOpen then return "Change Value" end
              if NWT.Bookkeeper.settingsMenuOpen then return "Change Value" end
              if NWT.Bookkeeper.rankMenuOpen then return "Confirm Rank" end
              if NWT.Bookkeeper.focusPanel == "guilds" then return "Select Guild" end
              if NWT.Bookkeeper.focusPanel == "actions" then return "Execute" end
              return "View Details"
          end, 
          keybind = "UI_SHORTCUT_PRIMARY", 
          callback = function() 
              if NWT.Bookkeeper.raffleWinner then NWT.BookkeeperRerollRaffle() return end
              if NWT.Bookkeeper.memberDetailsOpen then NWT.CloseMemberDetails() return end
              if NWT.Bookkeeper.duesSettingsOpen then NWT.DuesSettingsChangeValue() return end
              if NWT.Bookkeeper.settingsMenuOpen then NWT.BookkeeperChangeSettingValue() return end
              if NWT.Bookkeeper.rankMenuOpen then NWT.BookkeeperConfirmRank() return end
              if NWT.Bookkeeper.focusPanel == "guilds" then NWT.BookkeeperSelectGuild() return end
              if NWT.Bookkeeper.focusPanel == "actions" then NWT.BookkeeperExecuteAction() return end
              if NWT.Bookkeeper.focusPanel == "dues" then NWT.ShowMemberDetails() return end
          end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() 
              if NWT.Bookkeeper.duesSettingsOpen and NWT.DUES_SETTINGS_TABS and NWT.Bookkeeper.duesSettingsTabIndex then 
                  local currentTab = NWT.DUES_SETTINGS_TABS[NWT.Bookkeeper.duesSettingsTabIndex]
                  if currentTab and currentTab.id == "ranks" then
                      return "Period"
                  end
              end
              if NWT.Bookkeeper.focusPanel == "guilds" then return "Favorite" 
              elseif NWT.Bookkeeper.datePickerOpen then return "Switch Field" 
              else return "Filter: " .. (NWT.Bookkeeper.filterModes[NWT.Bookkeeper.filterMode] or "All") end 
          end, 
          keybind = "UI_SHORTCUT_SECONDARY", 
          callback = function() 
              if NWT.Bookkeeper.duesSettingsOpen then 
                  -- X button in dues settings - cycle period on RANKS tab
                  NWT.DuesSettingsCyclePeriod()
                  return 
              end
              if NWT.Bookkeeper.focusPanel == "guilds" then NWT.BookkeeperFavoriteSelectedGuild() 
              elseif NWT.Bookkeeper.datePickerOpen then NWT.BookkeeperCycleDatePickerField() 
              else NWT.BookkeeperCycleFilter() end 
              NWT.UpdateBookkeeperUI() 
              if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end 
          end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() 
              if NWT.Bookkeeper.duesSettingsOpen and NWT.DUES_SETTINGS_TABS and NWT.Bookkeeper.duesSettingsTabIndex then 
                  local currentTab = NWT.DUES_SETTINGS_TABS[NWT.Bookkeeper.duesSettingsTabIndex]
                  if currentTab and currentTab.id == "ranks" then
                      return "Amount"
                  end
              end
              if NWT.Bookkeeper.focusPanel == "guilds" then return "Settings" 
              elseif NWT.Bookkeeper.searchText and NWT.Bookkeeper.searchText ~= "" then return "Clear: " .. NWT.Bookkeeper.searchText
              else return "Search" end 
          end, 
          keybind = "UI_SHORTCUT_TERTIARY", 
          callback = function() 
              if NWT.Bookkeeper.duesSettingsOpen then 
                  -- Y button in dues settings - decrease amount on right column
                  NWT.DuesSettingsDecreaseAmount()
                  return 
              end
              if NWT.Bookkeeper.focusPanel == "guilds" then NWT.BookkeeperShowDuesSettings()
              elseif NWT.Bookkeeper.searchText and NWT.Bookkeeper.searchText ~= "" then NWT.BookkeeperClearSearch()
              else NWT.BookkeeperPromptSearch() end 
          end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function()
              if NWT.Bookkeeper.duesSettingsOpen then return "◄ Tab" end
              return "Navigate Left"
          end, 
          keybind = "UI_SHORTCUT_LEFT_SHOULDER", 
          callback = function() 
              if NWT.Bookkeeper.duesSettingsOpen then 
                  -- On RANKS tab: left column -> prev tab, right column -> left column
                  local currentTab = NWT.DUES_SETTINGS_TABS and NWT.DUES_SETTINGS_TABS[NWT.Bookkeeper.duesSettingsTabIndex]
                  if currentTab and currentTab.id == "ranks" then
                      local col = NWT.Bookkeeper.ranksColumn or "left"
                      if col == "right" then
                          NWT.Bookkeeper.ranksColumn = "left"
                          NWT.UpdateDuesSettingsDialog()
                          PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
                      else
                          NWT.DuesSettingsChangeTab("left")
                      end
                  else
                      NWT.DuesSettingsChangeTab("left")
                  end
                  return 
              end
              NWT.BookkeeperSwitchPanel("left") 
          end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function()
              if NWT.Bookkeeper.duesSettingsOpen then return "Tab ►" end
              return "Navigate Right"
          end, 
          keybind = "UI_SHORTCUT_RIGHT_SHOULDER", 
          callback = function() 
              if NWT.Bookkeeper.duesSettingsOpen then 
                  -- On RANKS tab: left column -> right column, right column -> next tab
                  local currentTab = NWT.DUES_SETTINGS_TABS and NWT.DUES_SETTINGS_TABS[NWT.Bookkeeper.duesSettingsTabIndex]
                  if currentTab and currentTab.id == "ranks" then
                      local col = NWT.Bookkeeper.ranksColumn or "left"
                      if col == "left" then
                          NWT.Bookkeeper.ranksColumn = "right"
                          NWT.UpdateDuesSettingsDialog()
                          PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
                      else
                          NWT.DuesSettingsChangeTab("right")
                      end
                  else
                      NWT.DuesSettingsChangeTab("right")
                  end
                  return 
              end
              NWT.BookkeeperSwitchPanel("right") 
          end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = "Page Up", 
          keybind = "UI_SHORTCUT_LEFT_TRIGGER", 
          ethereal = true,  -- Hide from keybind strip but keep functionality
          callback = function() 
              if NWT.Bookkeeper.focusPanel == "dues" then NWT.BookkeeperPageMember("up") end 
          end, 
          enabled = function() return NWT.Bookkeeper.focusPanel == "dues" and not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen and not NWT.Bookkeeper.duesSettingsOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = "Page Down", 
          keybind = "UI_SHORTCUT_RIGHT_TRIGGER", 
          ethereal = true,  -- Hide from keybind strip but keep functionality
          callback = function() 
              if NWT.Bookkeeper.focusPanel == "dues" then NWT.BookkeeperPageMember("down") end 
          end, 
          enabled = function() return NWT.Bookkeeper.focusPanel == "dues" and not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen and not NWT.Bookkeeper.duesSettingsOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_RIGHT, 
          name = function() if NWT.Bookkeeper.focusPanel == "dues" then return "Update Note" else return "Scan: " .. GetGuildName(GetGuildId(NWT.Bookkeeper.viewingGuildIndex)) end end, 
          keybind = "UI_SHORTCUT_RIGHT_STICK", 
          callback = function() if NWT.Bookkeeper.focusPanel == "dues" then NWT.BookkeeperUpdateMemberNote() else NWT.ScanGuildForBookkeeper(GetGuildId(NWT.Bookkeeper.viewingGuildIndex)) end end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen and not NWT.Bookkeeper.duesSettingsOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_RIGHT, 
          name = function()
              if NWT.Bookkeeper.duesSettingsOpen then return "Close Settings" end
              return "Set Rank"
          end, 
          keybind = "UI_SHORTCUT_QUATERNARY", 
          callback = function() 
              if NWT.Bookkeeper.duesSettingsOpen then 
                  NWT.CloseDuesSettingsDialog()
                  return
              end
              NWT.BookkeeperShowRankMenu() 
          end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_RIGHT, 
          name = function() return "|cFF4444Kick|r" end,
          keybind = "UI_SHORTCUT_LEFT_STICK", 
          callback = function()
              if NWT.Bookkeeper.focusPanel == "dues" then
                  NWT.BookkeeperKickMember()
              end
          end, 
          enabled = function()
              return NWT.Bookkeeper.focusPanel == "dues"
                 and not NWT.Bookkeeper.rankMenuOpen
                 and not NWT.Bookkeeper.settingsMenuOpen
                 and not NWT.Bookkeeper.duesSettingsOpen
          end 
        },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() 
        if NWT.Bookkeeper.memberDetailsOpen then NWT.CloseMemberDetails() return end
        if NWT.Bookkeeper.duesSettingsOpen then NWT.CloseDuesSettingsDialog() return end
        if NWT.Bookkeeper.raffleWinner then NWT.CloseRaffleWinnerDialog() KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor) return end
        if NWT.Bookkeeper.settingsMenuOpen then NWT.CloseSettingsDialog() return end
        if NWT.Bookkeeper.rankMenuOpen then NWT.CloseRankDialog() KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor) return end
        NWT.CloseBookkeeper() 
    end)
end

function NWT.SyncHiddenBookkeeperList()
    if not NWT.HiddenBookkeeperList then return end
    NWT.HiddenBookkeeperList:Clear()
    for i, m in ipairs(NWT.Bookkeeper.sortedMembers) do
        local ed = ZO_GamepadEntryData:New(m.name)
        ed.index, ed.member = i, m
        NWT.HiddenBookkeeperList:AddEntry("ZO_GamepadItemEntryTemplate", ed)
    end
    NWT.HiddenBookkeeperList:Commit()
    if #NWT.Bookkeeper.sortedMembers > 0 then NWT.HiddenBookkeeperList:SetSelectedIndexWithoutAnimation(NWT.Bookkeeper.selectedMemberIndex) end
end

function NWT.InitBookkeeperScene()
    if NWT.Bookkeeper.sceneInitialized then return end
    local ui = ATK_Bookkeeper_UI
    if not ui then 
NWT.Debug("|cFF0000[Bookkeeper]|r ATK_Bookkeeper_UI not found for scene init!")
        return 
    end
    local hc = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenBookkeeperList", GuiRoot, "ATK_HouseList_Screen")
    hc:SetHidden(true) hc:SetAlpha(0)
    NWT.BookkeeperScene = ZO_Scene:New("bookkeeperScene", SCENE_MANAGER)
    NWT.BookkeeperScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    NWT.BookkeeperScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NWT.BookkeeperScene:AddFragment(ZO_SimpleSceneFragment:New(ui))
    NWT.BookkeeperScene:AddFragment(ZO_SimpleSceneFragment:New(hc))
    NWT.HiddenBookkeeperListScreen = ATK_HiddenBookkeeperListScreen:New(hc)
    NWT.HiddenBookkeeperList = NWT.HiddenBookkeeperListScreen:GetMainList()
    NWT.HiddenBookkeeperList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) local l = c:GetNamedChild("Label") if l then l:SetText(d.name or "") end end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    -- Override list movement to use direct scroll functions (like raffle does)
    NWT.HiddenBookkeeperList.MovePrevious = function(self, ...)
        if NWT.Bookkeeper.duesSettingsOpen then NWT.DuesSettingsCycleRow("up") return end
        if NWT.Bookkeeper.settingsMenuOpen then NWT.BookkeeperCycleSettingsOption("up") return end
        if NWT.Bookkeeper.rankMenuOpen then NWT.BookkeeperCycleRank("up") return end
        if NWT.Bookkeeper.focusPanel == "guilds" then NWT.BookkeeperScrollGuild("up")
        elseif NWT.Bookkeeper.focusPanel == "actions" then NWT.BookkeeperScrollAction("up")
        else NWT.BookkeeperScrollMember("up") end
    end
    NWT.HiddenBookkeeperList.MoveNext = function(self, ...)
        if NWT.Bookkeeper.duesSettingsOpen then NWT.DuesSettingsCycleRow("down") return end
        if NWT.Bookkeeper.settingsMenuOpen then NWT.BookkeeperCycleSettingsOption("down") return end
        if NWT.Bookkeeper.rankMenuOpen then NWT.BookkeeperCycleRank("down") return end
        if NWT.Bookkeeper.focusPanel == "guilds" then NWT.BookkeeperScrollGuild("down")
        elseif NWT.Bookkeeper.focusPanel == "actions" then NWT.BookkeeperScrollAction("down")
        else NWT.BookkeeperScrollMember("down") end
    end
    
    
    NWT.HiddenBookkeeperList:SetOnSelectedDataChangedCallback(function(list, sd)
        if NWT.Bookkeeper.settingsMenuOpen or NWT.Bookkeeper.rankMenuOpen then return end
        if sd and sd.index then
            NWT.Bookkeeper.selectedMemberIndex = sd.index
            if NWT.Bookkeeper.selectedMemberIndex <= NWT.Bookkeeper.memberScrollOffset then NWT.Bookkeeper.memberScrollOffset = NWT.Bookkeeper.selectedMemberIndex - 1
            elseif NWT.Bookkeeper.selectedMemberIndex > NWT.Bookkeeper.memberScrollOffset + 12 then NWT.Bookkeeper.memberScrollOffset = NWT.Bookkeeper.selectedMemberIndex - 12 end
            NWT.UpdateBookkeeperUI()
        end
    end)
    NWT.BookkeeperScene:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then 
            NWT.Bookkeeper.isOpen = true 
            -- Reset to first position (favorites sort to top, so position 1 = first favorite or first guild)
            NWT.Bookkeeper.selectedGuildIndex = 1
            -- Build sorted list first to get actual viewing guild
            NWT.UpdateBookkeeperUI()
            -- Set viewing guild to the first sorted guild (which is the first favorite if any)
            local bk = NWT.Bookkeeper
            if bk.sortedGuildList and bk.sortedGuildList[1] then
                bk.viewingGuildIndex = bk.sortedGuildList[1].index
            else
                bk.viewingGuildIndex = 1
            end
            NWT.Bookkeeper.focusPanel = "dues"
            NWT.UpdateBookkeeperUI() 
            NWT.SyncHiddenBookkeeperList()
        elseif ns == SCENE_SHOWN then
            -- Re-sync and commit the list to ensure it can receive input
            NWT.SyncHiddenBookkeeperList()
            if NWT.HiddenBookkeeperList then
                NWT.HiddenBookkeeperList:Activate()
            end
            if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
                KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
            end
        elseif ns == SCENE_HIDING then
            -- Close all dialogs when scene is hiding (e.g., Start button pressed)
            if NWT.Bookkeeper.duesSettingsOpen then NWT.CloseDuesSettingsDialog() end
            if NWT.Bookkeeper.memberDetailsOpen then NWT.CloseMemberDetails() end
            if NWT.Bookkeeper.rankMenuOpen then NWT.CloseRankDialog() end
            if NWT.Bookkeeper.settingsMenuOpen then NWT.CloseSettingsDialog() end
        elseif ns == SCENE_HIDDEN then 
            NWT.Bookkeeper.isOpen = false 
            if NWT.HiddenBookkeeperList then NWT.HiddenBookkeeperList:Deactivate() end
        end
    end)
    NWT.Bookkeeper.sceneInitialized = true
end

function NWT.OpenBookkeeper()
    if NWT.Bookkeeper.isOpen then return end
    if not NWT.BookkeeperScene then NWT.InitBookkeeperScene() end
    SCENE_MANAGER:Push("bookkeeperScene")
end

function NWT.CloseBookkeeper() if NWT.BookkeeperScene then SCENE_MANAGER:Hide("bookkeeperScene") end end

-- ============================================
-- BOOKKEEPER DIALOGS & SETTINGS
-- ============================================

function NWT.BookkeeperShowRankMenu()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen then return end
    local member = bk.sortedMembers[bk.selectedMemberIndex]
    if not member then return end
    local guildId = GetGuildId(bk.selectedGuildIndex)
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_PROMOTE) and not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_DEMOTE) then NWT.Debug("|cFF0000[Bookkeeper]|r No permission to change ranks") return end
    
    local numRanks = GetNumGuildRanks(guildId)
    local rankNames = {}
    for i = 1, numRanks do
        if not IsGuildRankGuildMaster(guildId, i) then table.insert(rankNames, {index = i, name = GetGuildRankCustomName(guildId, i) or ("Rank " .. i)}) end
    end
    bk.rankMenuOpen, bk.rankMenuMember, bk.rankOptions, bk.rankSelectedIndex = true, member.name, rankNames, 1
    if member.rankIndex then for i, r in ipairs(rankNames) do if r.index == member.rankIndex then bk.rankSelectedIndex = i break end end end
    NWT.UpdateRankDialog() ATK_RankDialog:SetHidden(false) PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.UpdateRankDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_RankDialog
    if not dialog then return end
    local ml = dialog:GetNamedChild("MemberName") if ml then ml:SetText("|cFFFFFF" .. (bk.rankMenuMember or "") .. "|r") end
    for i = 1, 8 do
        local row = dialog:GetNamedChild("Rank" .. i)
        if row then
            local rank = bk.rankOptions and bk.rankOptions[i]
            if rank then row:SetText(i == bk.rankSelectedIndex and "|cFFFF00► " .. rank.name .. "|r" or "|cFFFFFF  " .. rank.name .. "|r") row:SetHidden(false)
            else row:SetText("") row:SetHidden(true) end
        end
    end
end

function NWT.BookkeeperConfirmRank()
    local bk = NWT.Bookkeeper
    if not bk.rankMenuOpen then return end
    local gId = GetGuildId(bk.selectedGuildIndex)
    local disp = bk.rankMenuMember
    if not disp:find("^@") then disp = "@" .. disp end
    local selRank = bk.rankOptions[bk.rankSelectedIndex]
    local member = bk.sortedMembers[bk.selectedMemberIndex]
    if selRank and member then
        local mIdx = GetGuildMemberIndexFromDisplayName(gId, disp)
        if not mIdx then NWT.CloseRankDialog() return end
        local _, _, curRank = GetGuildMemberInfo(gId, mIdx)
        local target = selRank.index
        if curRank == target then NWT.Debug("|cFFFF00[Bookkeeper]|r Already at that rank")
        elseif target > curRank then
            local steps = target - curRank
            for i = 1, steps do zo_callLater(function() GuildDemote(gId, disp) end, (i-1)*500) end
        else
            local steps = curRank - target
            for i = 1, steps do zo_callLater(function() GuildPromote(gId, disp) end, (i-1)*500) end
        end
        member.rankIndex = target PlaySound(SOUNDS.GUILD_ROSTER_DEMOTE)
    end
    NWT.CloseRankDialog() KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
end

function NWT.CloseRankDialog()
    local bk = NWT.Bookkeeper
    bk.rankMenuOpen, bk.rankMenuMember, bk.rankOptions = false, nil, nil
    if ATK_RankDialog then ATK_RankDialog:SetHidden(true) end
end

function NWT.BookkeeperCycleRank(dir)
    local bk = NWT.Bookkeeper
    if not bk.rankMenuOpen or not bk.rankOptions then return end
    local nO = #bk.rankOptions
    if nO == 0 then return end
    bk.rankSelectedIndex = (dir == "up") and (bk.rankSelectedIndex == 1 and nO or bk.rankSelectedIndex - 1) or (bk.rankSelectedIndex == nO and 1 or bk.rankSelectedIndex + 1)
    NWT.UpdateRankDialog() PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

local SETTINGS_OPTIONS = { {id = "trackGuild", label = "Track This Guild"}, {id = "dues", label = "Weekly Dues"}, {id = "raffle", label = "Raffle Ends In"}, {id = "ticketPrice", label = "Ticket Price"}, {id = "rafflePeriod", label = "Raffle Period"}, {id = "rafflePicker", label = "Pick Winners"}, {id = "exempt", label = "Exempt Ranks"}, {id = "scanNotes", label = "Scan Payment Notes"}, }
local DUES_OPTIONS = {5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000}
local TICKET_OPTIONS = {500, 1000, 2000, 2500, 5000, 10000, 25000, 50000}
local RAFFLE_PRESETS = { {suffixes = {1}, label = "01"}, {suffixes = {2}, label = "02"}, {suffixes = {3}, label = "03"}, {suffixes = {4}, label = "04"}, {suffixes = {5}, label = "05"}, {suffixes = {6}, label = "06"}, {suffixes = {7}, label = "07"}, {suffixes = {8}, label = "08"}, {suffixes = {9}, label = "09"}, }

function NWT.BookkeeperShowSettings()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen or bk.settingsMenuOpen then return end
    -- Use viewing guild (the one shown in Dues panel) for settings
    bk.settingsMenuOpen, bk.settingsSelectedIndex, bk.settingsGuildId = true, 1, GetGuildId(bk.viewingGuildIndex)
    NWT.UpdateSettingsDialog() ATK_BookkeeperSettingsDialog:SetHidden(false) PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
end

function NWT.UpdateSettingsDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_BookkeeperSettingsDialog
    if not dialog then return end
    local gs = GetBookkeeperGuildSettings(bk.settingsGuildId)
    local gn = GetGuildName(bk.settingsGuildId)
    dialog:GetNamedChild("GuildName"):SetText("|cFFFFFF" .. gn .. "|r")
    
    -- Build exempt ranks display string
    local exemptNames = {}
    local numRanks = GetNumGuildRanks(bk.settingsGuildId)
    for i = 1, numRanks do
        if gs.exemptRanks and gs.exemptRanks[i] then
            local rankName = GetGuildRankCustomName(bk.settingsGuildId, i) or ("Rank " .. i)
            table.insert(exemptNames, rankName)
        end
    end
    local exemptStr = #exemptNames > 0 and table.concat(exemptNames, ", ") or "None"
    if #exemptStr > 25 then exemptStr = #exemptNames .. " ranks" end
    
    local isTracked = IsGuildEnabled(bk.settingsGuildId)
    local notesScanCount = gs.paymentHistory and gs.lastNotesScan and #(gs.paymentHistory or {}) or 0
    local notesScanStatus = gs.lastNotesScan and (notesScanCount .. " found") or "Not scanned"
    local vals = { 
        {id = "trackGuild", value = isTracked and "|c00FF00ON|r" or "|cFF4444OFF|r"},
        {id = "dues", value = NWT.FormatGold(gs.duesAmount or 5000) .. "g"}, 
        {id = "raffle", value = table.concat(gs.raffleSuffixes or {1, 5}, ", ")}, 
        {id = "ticketPrice", value = NWT.FormatGold(gs.ticketPrice or 1000) .. "g"},
        {id = "rafflePeriod", value = FormatRafflePeriod(gs)},
        {id = "rafflePicker", value = "→"},
        {id = "exempt", value = exemptStr},
        {id = "scanNotes", value = notesScanStatus},
    }
    if vals[3].value == "" then vals[3].value = "None" end
    for i = 1, 8 do
        local row = dialog:GetNamedChild("Option" .. i)
        if row then
            local opt, val = SETTINGS_OPTIONS[i], vals[i]
            if opt and val then row:SetText(i == bk.settingsSelectedIndex and "|cFFFF00► " .. opt.label .. ": |cFFD700" .. val.value .. "|r" or "|cFFFFFF  " .. opt.label .. ": |c888888" .. val.value .. "|r") row:SetHidden(false)
            else row:SetText("") row:SetHidden(true) end
        end
    end
end

function NWT.BookkeeperCycleSettingsOption(dir)
    local bk = NWT.Bookkeeper
    if bk.rafflePickerOpen then
        NWT.BookkeeperAdjustWinnerCount(dir)
        return
    end
    if bk.datePickerOpen then
        NWT.BookkeeperAdjustDatePickerValue(dir)
        return
    end
    if bk.exemptMenuOpen then
        NWT.BookkeeperCycleExemptRank(dir)
        return
    end
    if not bk.settingsMenuOpen then return end
    local nO = #SETTINGS_OPTIONS
    bk.settingsSelectedIndex = (dir == "up") and (bk.settingsSelectedIndex == 1 and nO or bk.settingsSelectedIndex - 1) or (bk.settingsSelectedIndex == nO and 1 or bk.settingsSelectedIndex + 1)
    NWT.UpdateSettingsDialog() PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.BookkeeperChangeSettingValue()
    local bk = NWT.Bookkeeper
    if bk.rafflePickerOpen then
        NWT.BookkeeperRunRafflePicker()
        return
    end
    if bk.datePickerOpen then
        NWT.BookkeeperConfirmDatePicker()
        return
    end
    if bk.exemptMenuOpen then
        NWT.BookkeeperToggleExemptRank()
        return
    end
    if not bk.settingsMenuOpen then return end
    local gs = GetBookkeeperGuildSettings(bk.settingsGuildId)
    local opt = SETTINGS_OPTIONS[bk.settingsSelectedIndex]
    if not opt then return end
    if opt.id == "trackGuild" then
        ToggleGuildEnabled(bk.settingsGuildId)
    elseif opt.id == "dues" then
        local cur, nextIdx = gs.duesAmount or 5000, 1
        for i, amt in ipairs(DUES_OPTIONS) do if cur == amt then nextIdx = (i % #DUES_OPTIONS) + 1 break elseif cur < amt then nextIdx = i break end end
        gs.duesAmount = DUES_OPTIONS[nextIdx]
    elseif opt.id == "raffle" then
        local cur, nextIdx = table.concat(gs.raffleSuffixes or {1, 5}, ", "), 1
        for i, p in ipairs(RAFFLE_PRESETS) do if table.concat(p.suffixes, ", ") == cur then nextIdx = (i % #RAFFLE_PRESETS) + 1 break end end
        gs.raffleSuffixes = RAFFLE_PRESETS[nextIdx].suffixes
    elseif opt.id == "ticketPrice" then
        local cur, nextIdx = gs.ticketPrice or 1000, 1
        for i, amt in ipairs(TICKET_OPTIONS) do if cur == amt then nextIdx = (i % #TICKET_OPTIONS) + 1 break elseif cur < amt then nextIdx = i break end end
        gs.ticketPrice = TICKET_OPTIONS[nextIdx]
    elseif opt.id == "rafflePeriod" then
        local presets = GetRafflePeriodPresets()
        local curIdx = 1
        local curId = gs.rafflePeriodId or "all"
        for i, p in ipairs(presets) do
            if p.id == curId then curIdx = i break end
        end
        local nextIdx = (curIdx % #presets) + 1
        gs.rafflePeriodId = presets[nextIdx].id
        -- If custom selected, open date picker
        if gs.rafflePeriodId == "custom" then
            NWT.BookkeeperShowDatePicker()
            return
        end
    elseif opt.id == "rafflePicker" then
        -- Open raffle picker UI
        NWT.BookkeeperShowRafflePicker()
        return
    elseif opt.id == "exempt" then
        -- Open exempt ranks sub-menu
        NWT.BookkeeperShowExemptRanksMenu()
        return
    elseif opt.id == "scanNotes" then
        -- Scan all member notes for payment dates
        NWT.BookkeeperScanPaymentNotes(bk.settingsGuildId)
        return
    end
    PlaySound(SOUNDS.POSITIVE_CLICK) NWT.UpdateSettingsDialog() NWT.UpdateBookkeeperUI()
end

-- Random Raffle Picker
function NWT.BookkeeperShowRafflePicker()
    local bk = NWT.Bookkeeper
    bk.rafflePickerOpen = true
    bk.raffleWinnerCount = 1
    -- Hide settings dialog
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(true) end
    NWT.UpdateRafflePickerDialog()
    if ATK_RafflePickerDialog then ATK_RafflePickerDialog:SetHidden(false) end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.UpdateRafflePickerDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_RafflePickerDialog
    if not dialog then return end
    
    local guildId = GetGuildId(bk.selectedGuildIndex)
    local gs = GetBookkeeperGuildSettings(guildId)
    local startTime, endTime = GetRafflePeriodTimes(gs)
    local ticketPrice = gs.ticketPrice or 1000
    
    -- Count entries and tickets
    local entryCount, totalTickets = 0, 0
    for _, m in pairs(gs.memberPayments or {}) do
        if m.isCurrentMember and m.deposits then
            local memberRaffle = 0
            for _, dep in ipairs(m.deposits) do
                if dep.type == "raffle" and dep.timestamp >= startTime and dep.timestamp <= endTime then
                    memberRaffle = memberRaffle + dep.amount
                end
            end
            if memberRaffle > 0 then
                local tickets = math.floor(memberRaffle / ticketPrice)
                if tickets > 0 then entryCount = entryCount + 1 totalTickets = totalTickets + tickets end
            end
        end
    end
    
    local periodLabel = dialog:GetNamedChild("Period")
    local statsLabel = dialog:GetNamedChild("Stats")
    local countLabel = dialog:GetNamedChild("WinnerCount")
    
    if periodLabel then periodLabel:SetText(string.format("|cFFFFAAPeriod:|r %s", FormatRafflePeriod(gs))) end
    if statsLabel then statsLabel:SetText(string.format("|c00FFFF%d participants|r  |cFFFF00%d tickets|r", entryCount, totalTickets)) end
    if countLabel then countLabel:SetText(string.format("|cFFFFFF# Winners:|r |cFFD700◄ %d ►|r", bk.raffleWinnerCount)) end
end

function NWT.BookkeeperAdjustWinnerCount(dir)
    local bk = NWT.Bookkeeper
    if not bk.rafflePickerOpen then return end
    if dir == "up" or dir == "right" then
        bk.raffleWinnerCount = math.min(10, bk.raffleWinnerCount + 1)
    else
        bk.raffleWinnerCount = math.max(1, bk.raffleWinnerCount - 1)
    end
    NWT.UpdateRafflePickerDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.BookkeeperRunRafflePicker()
    local bk = NWT.Bookkeeper
    local guildId = GetGuildId(bk.selectedGuildIndex)
    local gs = GetBookkeeperGuildSettings(guildId)
    local startTime, endTime = GetRafflePeriodTimes(gs)
    local ticketPrice = gs.ticketPrice or 1000
    
    -- Build weighted pool
    local pool = {}
    local totalTickets = 0
    for _, m in pairs(gs.memberPayments or {}) do
        if m.isCurrentMember and m.deposits then
            local memberRaffle = 0
            for _, dep in ipairs(m.deposits) do
                if dep.type == "raffle" and dep.timestamp >= startTime and dep.timestamp <= endTime then
                    memberRaffle = memberRaffle + dep.amount
                end
            end
            if memberRaffle > 0 then
                local tickets = math.floor(memberRaffle / ticketPrice)
                if tickets > 0 then
                    table.insert(pool, { name = m.name, tickets = tickets })
                    totalTickets = totalTickets + tickets
                end
            end
        end
    end
    
    if #pool == 0 then
NWT.Debug("|cFFFF00[Bookkeeper]|r No raffle entries for this period!")
        return
    end
    
    -- Pick winners
    local winners = {}
    local winnerCount = math.min(bk.raffleWinnerCount, #pool)
    
    for w = 1, winnerCount do
        local winningTicket = math.random(1, totalTickets)
        local runningTotal = 0
        for i, entry in ipairs(pool) do
            runningTotal = runningTotal + entry.tickets
            if winningTicket <= runningTotal then
                table.insert(winners, { name = entry.name, tickets = entry.tickets, place = w })
                -- Remove winner from pool for next draw
                totalTickets = totalTickets - entry.tickets
                table.remove(pool, i)
                break
            end
        end
    end
    
    bk.raffleWinners = winners
    bk.raffleTotalTickets = totalTickets
    bk.raffleEntryCount = #pool + #winners
    
    -- Close picker, show results
    if ATK_RafflePickerDialog then ATK_RafflePickerDialog:SetHidden(true) end
    NWT.ShowRaffleWinnerDialog()
end

function NWT.CloseRafflePickerDialog()
    local bk = NWT.Bookkeeper
    bk.rafflePickerOpen = false
    if ATK_RafflePickerDialog then ATK_RafflePickerDialog:SetHidden(true) end
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(false) end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    NWT.UpdateSettingsDialog()
end

function NWT.ShowRaffleWinnerDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_RaffleWinnerDialog
    if not dialog then return end
    
    local winners = bk.raffleWinners
    if not winners or #winners == 0 then return end
    
    -- Build winner display
    local winnerText = ""
    for i, w in ipairs(winners) do
        local displayName = w.name:gsub("^@", "")
        if i == 1 then
            winnerText = string.format("|cFFD700#%d: %s|r (%d tickets)", i, displayName, w.tickets)
        else
            winnerText = winnerText .. string.format("\n|cFFFFAA#%d: %s|r (%d)", i, displayName, w.tickets)
        end
    end
    
    local nameLabel = dialog:GetNamedChild("WinnerName")
    local statsLabel = dialog:GetNamedChild("Stats")
    
    if nameLabel then nameLabel:SetText(winnerText) end
    if statsLabel then statsLabel:SetText(string.format("|c888888%d participants in draw|r", bk.raffleEntryCount)) end
    
    bk.raffleWinner = true -- Flag that dialog is open
    dialog:SetHidden(false)
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    PlaySound(SOUNDS.TELVAR_GAINED)
end

function NWT.CloseRaffleWinnerDialog()
    if ATK_RaffleWinnerDialog then ATK_RaffleWinnerDialog:SetHidden(true) end
    NWT.Bookkeeper.raffleWinner = nil
    NWT.Bookkeeper.raffleWinners = nil
    -- Show settings again
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(false) end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    NWT.UpdateSettingsDialog()
end

function NWT.BookkeeperRerollRaffle()
    NWT.CloseRaffleWinnerDialog()
    -- Go back to picker
    NWT.BookkeeperShowRafflePicker()
end

-- Date Picker for Custom Raffle Period
function NWT.BookkeeperShowDatePicker()
    local bk = NWT.Bookkeeper
    bk.datePickerOpen = true
    bk.datePickerField = "start" -- "start" or "end"
    bk.datePickerDaysAgo = {start = 7, ["end"] = 0} -- Default: last 7 days
    -- Hide settings dialog while date picker is open
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(true) end
    NWT.UpdateDatePickerDialog()
    if ATK_DatePickerDialog then ATK_DatePickerDialog:SetHidden(false) end
    -- Update keybind strip to show "Switch Field" for Y button
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.UpdateDatePickerDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_DatePickerDialog
    if not dialog then return end
    
    local now = GetTimeStamp()
    local startDays = bk.datePickerDaysAgo.start
    local endDays = bk.datePickerDaysAgo["end"]
    local startDate = os.date("%m/%d/%Y", now - (startDays * 86400))
    local endDate = os.date("%m/%d/%Y", now - (endDays * 86400))
    
    local startLabel = dialog:GetNamedChild("StartValue")
    local endLabel = dialog:GetNamedChild("EndValue")
    local startSel = bk.datePickerField == "start"
    
    if startLabel then
        startLabel:SetText(startSel and string.format("|cFFD700► %s ◄|r (%d days ago)", startDate, startDays) or string.format("|c888888  %s|r (%d days ago)", startDate, startDays))
    end
    if endLabel then
        endLabel:SetText(not startSel and string.format("|cFFD700► %s ◄|r (%d days ago)", endDate, endDays) or string.format("|c888888  %s|r (%d days ago)", endDate, endDays))
    end
    
    local hint = dialog:GetNamedChild("Hint")
    if hint then hint:SetText("|c888888[A] Confirm  [B] Cancel  [X] Switch Field  [D-pad] Adjust Days|r") end
end

function NWT.BookkeeperCycleDatePickerField()
    local bk = NWT.Bookkeeper
    if not bk.datePickerOpen then return end
    bk.datePickerField = (bk.datePickerField == "start") and "end" or "start"
    NWT.UpdateDatePickerDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.BookkeeperAdjustDatePickerValue(dir)
    local bk = NWT.Bookkeeper
    if not bk.datePickerOpen then return end
    local field = bk.datePickerField
    local current = bk.datePickerDaysAgo[field]
    if dir == "up" then
        bk.datePickerDaysAgo[field] = math.max(0, current - 1)
    else
        bk.datePickerDaysAgo[field] = math.min(90, current + 1)
    end
    NWT.UpdateDatePickerDialog()
end

function NWT.BookkeeperConfirmDatePicker()
    local bk = NWT.Bookkeeper
    if not bk.datePickerOpen then return end
    local gs = GetBookkeeperGuildSettings(bk.settingsGuildId)
    local now = GetTimeStamp()
    gs.customRaffleStart = now - (bk.datePickerDaysAgo.start * 86400)
    gs.customRaffleEnd = now - (bk.datePickerDaysAgo["end"] * 86400)
    gs.rafflePeriodId = "custom"
    NWT.CloseDatePickerDialog()
    PlaySound(SOUNDS.POSITIVE_CLICK)
end

function NWT.CloseDatePickerDialog()
    local bk = NWT.Bookkeeper
    bk.datePickerOpen = false
    if ATK_DatePickerDialog then ATK_DatePickerDialog:SetHidden(true) end
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(false) end
    -- Update keybind strip to restore normal keybinds
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    NWT.UpdateSettingsDialog()
    NWT.UpdateBookkeeperUI()
end

-- Exempt Ranks Sub-Menu
function NWT.BookkeeperShowExemptRanksMenu()
    local bk = NWT.Bookkeeper
    bk.exemptMenuOpen = true
    bk.exemptRankIndex = 2 -- Start at 2 since 1 is usually Guild Master
    -- Hide settings dialog while exempt dialog is open
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(true) end
    NWT.UpdateExemptRanksDialog()
    if ATK_ExemptRanksDialog then ATK_ExemptRanksDialog:SetHidden(false) end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.UpdateExemptRanksDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_ExemptRanksDialog
    if not dialog then return end
    local gs = GetBookkeeperGuildSettings(bk.settingsGuildId)
    local gn = GetGuildName(bk.settingsGuildId)
    local header = dialog:GetNamedChild("Header")
    if header then header:SetText("|cFFD700Exempt Ranks - " .. gn .. "|r") end
    
    local numRanks = GetNumGuildRanks(bk.settingsGuildId)
    for i = 1, 10 do
        local row = dialog:GetNamedChild("Rank" .. i)
        if row then
            if i <= numRanks and not IsGuildRankGuildMaster(bk.settingsGuildId, i) then
                local rankName = GetGuildRankCustomName(bk.settingsGuildId, i) or ("Rank " .. i)
                local isExempt = gs.exemptRanks and gs.exemptRanks[i]
                local checkbox = isExempt and "|c00FF00[✓]|r" or "|cFF6666[ ]|r"
                local isSel = (i == bk.exemptRankIndex)
                if isSel then
                    row:SetText(string.format("|cFFD700►►|r %s |cFFFFFF%s|r |cFFD700◄◄|r", checkbox, rankName))
                else
                    row:SetText(string.format("   %s |c888888%s|r", checkbox, rankName))
                end
                row:SetHidden(false)
            else
                row:SetText("")
                row:SetHidden(true)
            end
        end
    end
    local hint = dialog:GetNamedChild("Hint")
    if hint then hint:SetText("|c888888[A] Toggle  [B] Done|r") end
end

function NWT.BookkeeperCycleExemptRank(dir)
    local bk = NWT.Bookkeeper
    if not bk.exemptMenuOpen then return end
    local numRanks = GetNumGuildRanks(bk.settingsGuildId)
    local validRanks = {}
    for i = 1, numRanks do
        if not IsGuildRankGuildMaster(bk.settingsGuildId, i) then table.insert(validRanks, i) end
    end
    if #validRanks == 0 then return end
    local curPos = 1
    for i, r in ipairs(validRanks) do if r == bk.exemptRankIndex then curPos = i break end end
    if dir == "up" then curPos = curPos == 1 and #validRanks or curPos - 1
    else curPos = curPos == #validRanks and 1 or curPos + 1 end
    bk.exemptRankIndex = validRanks[curPos]
    NWT.UpdateExemptRanksDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.BookkeeperToggleExemptRank()
    local bk = NWT.Bookkeeper
    if not bk.exemptMenuOpen then return end
    local gs = GetBookkeeperGuildSettings(bk.settingsGuildId)
    local idx = bk.exemptRankIndex
    if gs.exemptRanks[idx] then gs.exemptRanks[idx] = nil
    else gs.exemptRanks[idx] = true end
    NWT.UpdateExemptRanksDialog()
    PlaySound(SOUNDS.POSITIVE_CLICK)
end

function NWT.CloseExemptRanksDialog()
    local bk = NWT.Bookkeeper
    bk.exemptMenuOpen = false
    if ATK_ExemptRanksDialog then ATK_ExemptRanksDialog:SetHidden(true) end
    -- Show settings dialog again
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(false) end
    NWT.UpdateSettingsDialog()
    NWT.BuildBookkeeperMemberList(bk.settingsGuildId)
    NWT.UpdateBookkeeperUI()
end

function NWT.CloseSettingsDialog()
    local bk = NWT.Bookkeeper
    if bk.rafflePickerOpen then
        NWT.CloseRafflePickerDialog()
        return
    end
    if bk.datePickerOpen then
        NWT.CloseDatePickerDialog()
        return
    end
    if bk.exemptMenuOpen then
        NWT.CloseExemptRanksDialog()
        return
    end
    bk.settingsMenuOpen, bk.settingsGuildId = false, nil
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(true) end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
end

function NWT.BookkeeperToggleLifetime()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen then return end
    local m = bk.sortedMembers[bk.selectedMemberIndex]
    if not m then return end
    local gs = GetBookkeeperGuildSettings(GetGuildId(bk.selectedGuildIndex))
    if gs.lifetimeMembers[m.name] then gs.lifetimeMembers[m.name] = nil
    else gs.lifetimeMembers[m.name] = true end
    PlaySound(SOUNDS.POSITIVE_CLICK) NWT.UpdateBookkeeperUI()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
end

function NWT.BookkeeperKickMember()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen then return end
    local m = bk.sortedMembers[bk.selectedMemberIndex]
    if not m then return end
    local gId = GetGuildId(bk.selectedGuildIndex)
    if not DoesPlayerHaveGuildPermission(gId, GUILD_PERMISSION_REMOVE) then NWT.Debug("|cFF0000[Bookkeeper]|r No permission to remove members") return end
    bk.pendingKickMember, bk.pendingKickGuildId, bk.pendingKickMemberData = m.name:find("^@") and m.name or "@" .. m.name, gId, m
    if not ESO_Dialogs["ATK_KICK_MEMBER_DIALOG"] then
        ESO_Dialogs["ATK_KICK_MEMBER_DIALOG"] = {
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC }, canQueue = true,
            title = { text = "KICK MEMBER?" }, mainText = { text = "Are you sure you want to kick <<1>> from the guild?" },
            buttons = {
                { text = "Kick", keybind = "DIALOG_PRIMARY", callback = function() local b = NWT.Bookkeeper if b.pendingKickMember and b.pendingKickGuildId then GuildRemove(b.pendingKickGuildId, b.pendingKickMember) b.pendingKickMemberData.isCurrentMember = false NWT.BuildBookkeeperMemberList(b.pendingKickGuildId) NWT.UpdateBookkeeperUI() NWT.SyncHiddenBookkeeperList() end b.pendingKickMember, b.pendingKickGuildId, b.pendingKickMemberData = nil, nil, nil end },
                { text = "Cancel", keybind = "DIALOG_NEGATIVE", callback = function() local b = NWT.Bookkeeper b.pendingKickMember, b.pendingKickGuildId, b.pendingKickMemberData = nil, nil, nil end },
            },
        }
    end
    if IsInGamepadPreferredMode() then ZO_Dialogs_ShowGamepadDialog("ATK_KICK_MEMBER_DIALOG", nil, {mainTextParams = {m.name}})
    else ZO_Dialogs_ShowDialog("ATK_KICK_MEMBER_DIALOG", nil, {mainTextParams = {m.name}}) end
end

-- ============================================
-- COMPREHENSIVE DUES SETTINGS SYSTEM
-- ============================================

NWT.DUES_SETTINGS_TABS = {
    { id = "dues", label = "DUES" },
    { id = "periods", label = "PERIODS" },
    { id = "ranks", label = "RANKS" },
    { id = "enforce", label = "ENFORCE" },
    { id = "notes", label = "NOTES" },
    { id = "actions", label = "ACTIONS" },
}
local DUES_SETTINGS_TABS = NWT.DUES_SETTINGS_TABS

local DUES_AMOUNT_OPTIONS = {1000, 2000, 2500, 5000, 7500, 10000, 15000, 20000, 25000, 30000, 50000, 100000}
local PERIOD_OPTIONS = {"weekly", "biweekly", "monthly", "custom"}
local GRACE_PERIOD_OPTIONS = {0, 1, 2, 3, 5, 7, 14}
local NOTE_FORMAT_OPTIONS = {"range", "due", "paid", "custom"}
local SORT_OPTIONS = {"status", "name", "rank", "lastPaid", "amount"}

-- Smart amount increments based on current value (for up to 20m)
local function GetAmountIncrement(currentAmount, direction)
    local amount = currentAmount or 0
    if amount < 50000 then return 1000 * direction
    elseif amount < 100000 then return 5000 * direction
    elseif amount < 500000 then return 10000 * direction
    elseif amount < 1000000 then return 50000 * direction
    elseif amount < 5000000 then return 100000 * direction
    elseif amount < 10000000 then return 500000 * direction
    else return 1000000 * direction end
end

-- Period options for per-rank dues
local RANK_PERIOD_OPTIONS = {"weekly", "biweekly", "monthly", "yearly"}
local RANK_PERIOD_LABELS = {weekly = "Weekly", biweekly = "Bi-Weekly", monthly = "Monthly", yearly = "Yearly"}
local RANK_PERIOD_SHORT = {weekly = "wk", biweekly = "bw", monthly = "mo", yearly = "yr"}

-- GetEffectiveDuesForRank moved to BookkeeperData.lua

-- Format rank dues for display
local function FormatRankDues(guildSettings, rankIndex)
    local exemptType = guildSettings.exemptRanks and guildSettings.exemptRanks[rankIndex]
    if exemptType then
        if exemptType == "gm" then return "|cFFD700GM|r"
        elseif exemptType == "officer" then return "|c00FFFFOFFICE|r"
        elseif exemptType == "lifetime" then return "|c00FF00LIFE|r"
        else return "|c00FFFFEXEMPT|r" end
    end
    
    local override = guildSettings.rankDuesOverride and guildSettings.rankDuesOverride[rankIndex]
    if override and type(override) == "table" then
        local amt = override.amount or 0
        local per = override.period or "weekly"
        local perShort = per == "weekly" and "wk" or (per == "monthly" and "mo" or (per == "yearly" and "yr" or "bw"))
        return "|c00FF00" .. NWT.FormatGold(amt) .. "/" .. perShort .. "|r"
    elseif override and type(override) == "number" then
        return NWT.FormatGold(override) .. "g"
    end
    
    return "Default"
end

local function FormatDuesPeriod(gs)
    local period = gs.duesPeriod or "weekly"
    if period == "weekly" then return "Weekly (7 days)"
    elseif period == "biweekly" then return "Bi-Weekly (14 days)"
    elseif period == "monthly" then return "Monthly (30 days)"
    elseif period == "custom" then return "Custom (" .. (gs.customDaysPeriod or 7) .. " days)"
    end
    return period
end

local function GetDuesSettingsForTab(tabId, gs, guildId)
    if tabId == "dues" then
        return {
            { id = "duesAmount", label = "Dues Amount", value = NWT.FormatGold(gs.duesAmount or 5000) .. "g", type = "cycle", options = DUES_AMOUNT_OPTIONS },
            { id = "duesSuffix", label = "Dues Deposit Suffix", value = tostring(gs.duesSuffix), type = "number" },
            { id = "freeTraderMode", label = "Free Trader Mode", value = gs.freeTraderMode and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "freeTraderHelp", label = "How To Scan", value = "At banker: open Guild Trader, select this guild, then press L3.", type = "info" },
        }
    elseif tabId == "periods" then
        return {
            { id = "duesPeriod", label = "Dues Period", value = FormatDuesPeriod(gs), type = "cycle", options = PERIOD_OPTIONS },
            { id = "customDaysPeriod", label = "Custom Period Days", value = tostring(gs.customDaysPeriod or 7) .. " days", type = "number" },
            { id = "traderFlipDay", label = "Trader Flip Day", value = ({"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"})[gs.traderFlipDay or 3], type = "cycle" },
            { id = "gracePeriodDays", label = "Grace Period", value = (gs.gracePeriodDays or 3) .. " days", type = "cycle", options = GRACE_PERIOD_OPTIONS },
            { id = "lateFeeEnabled", label = "Late Fee", value = gs.lateFeeEnabled and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "lateFeeAmount", label = "Late Fee Amount", value = NWT.FormatGold(gs.lateFeeAmount or 0) .. "g", type = "number" },
        }
    elseif tabId == "ranks" then
        local rankSettings = {}
        if guildId > 0 then
            -- Add instructions header
            table.insert(rankSettings, { id = "rankHelp", label = "|c888888A=Amount  X=Period  Y=Exempt|r", value = "", type = "info" })
            
            for i = 1, GetNumGuildRanks(guildId) do
                if not IsGuildRankGuildMaster(guildId, i) then
                    local rankName = GetGuildRankCustomName(guildId, i) or ("Rank " .. i)
                    local exemptType = gs.exemptRanks and gs.exemptRanks[i]
                    local override = gs.rankDuesOverride and gs.rankDuesOverride[i]
                    
                    local amountText, periodText
                    if exemptType then
                        amountText = "|c00FFFFEXEMPT|r"
                        periodText = ""
                    elseif override and type(override) == "table" then
                        local amt = override.amount or 0
                        local per = override.period or "weekly"
                        amountText = "|c00FF00" .. NWT.FormatGold(amt) .. "g|r"
                        periodText = "|cFFFF00" .. (RANK_PERIOD_SHORT[per] or per) .. "|r"
                    else
                        amountText = "Default"
                        periodText = ""
                    end
                    
                    local displayValue = amountText
                    if periodText ~= "" then displayValue = amountText .. "/" .. periodText end
                    
                    table.insert(rankSettings, { 
                        id = "rank_" .. i, 
                        label = rankName, 
                        value = displayValue, 
                        type = "rank_config", 
                        rankIndex = i 
                    })
                end
            end
        else
            table.insert(rankSettings, { id = "noGuild", label = "|c888888(Select a guild to configure ranks)|r", value = "", type = "info" })
        end
        return rankSettings
    elseif tabId == "enforce" then
        -- Build rank list for demotion rank selection
        local demotionRankName = "Not Set"
        if gs.demotionRank and guildId > 0 then
            demotionRankName = GetGuildRankCustomName(guildId, gs.demotionRank) or ("Rank " .. gs.demotionRank)
        end
        local demotedCount = 0
        for _ in pairs(gs.demotedMembers or {}) do demotedCount = demotedCount + 1 end
        
        return {
            { id = "autoDemoteEnabled", label = "Full Auto Mode", value = gs.autoDemoteEnabled and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "demotionRank", label = "Demotion Rank", value = demotionRankName, type = "rank_select" },
            { id = "daysBeforeDemotion", label = "Days Before Demote", value = (gs.daysBeforeDemotion or 7) .. " days", type = "cycle", options = {3, 5, 7, 10, 14, 21, 30} },
            { id = "demotedCount", label = "|cFFAAAACurrently Demoted|r", value = "|cFFFF00" .. demotedCount .. " members|r", type = "info" },
            { id = "previewDemotions", label = "|c00FFFF► Preview Demotions|r", value = "", type = "action" },
            { id = "runDemotions", label = "|cFF6600► Run Demotions Now|r", value = "", type = "action" },
            { id = "restoreAll", label = "|c00FF00► Restore All Demoted|r", value = "", type = "action" },
        }
    elseif tabId == "notes" then
        -- Format display names
        local formatDisplayNames = {
            range = "Range (1/1-2/1)",
            due = "Due: 2/1",
            paid = "Paid thru 2/1",
            custom = "Custom Template",
        }
        local currentFormat = gs.noteFormat or "range"
        local formatDisplay = formatDisplayNames[currentFormat] or "Range (1/1-2/1)"
        
        -- Get template preview
        local templatePreview = ""
        if currentFormat == "custom" then
            templatePreview = gs.customNoteFormat or "{START}-{END} Upd:{UPD}"
        else
            templatePreview = NOTE_FORMAT_TEMPLATES[currentFormat] or NOTE_FORMAT_TEMPLATES.range
        end
        
        return {
            { id = "autoUpdateNotes", label = "Auto-Update Notes", value = gs.autoUpdateNotes and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "noteFormat", label = "Note Format", value = formatDisplay, type = "cycle", options = {"range", "due", "paid", "custom"} },
            { id = "customNoteFormat", label = "Custom Template", value = gs.customNoteFormat or "{START}-{END} Upd:{UPD}", type = "text_input" },
            { id = "templateHelp", label = "|c888888Placeholders: {START} {END} {UPD}|r", value = "", type = "info" },
            { id = "reformatNotes", label = "|c00FFFF► Reformat All Notes|r", value = "", type = "action" },
            { id = "scanNotes", label = "|c00FFFF► Scan All Member Notes|r", value = "", type = "action" },
        }
    elseif tabId == "alerts" then
        return {
            { id = "alertOnLogin", label = "Show Unpaid on Login", value = gs.alertOnLogin and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "alertUnpaidCount", label = "Alert if Unpaid >", value = gs.alertUnpaidCount == 0 and "Disabled" or tostring(gs.alertUnpaidCount), type = "number" },
            { id = "highlightOverdue", label = "Highlight Overdue Members", value = gs.highlightOverdue and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "showOfflineStatus", label = "Show Last Online", value = gs.showOfflineStatus and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
        }
    elseif tabId == "actions" then
        return {
            { id = "scanGuild", label = "|c00FFFF► Scan Guild (Deposits + Sales)|r", value = "", type = "action" },
            { id = "exportUnpaid", label = "|cFFFFAA► Export Unpaid List|r", value = "", type = "action" },
            { id = "clearData", label = "|cFF6666► Clear All Data|r", value = "", type = "action" },
            { id = "sortBy", label = "Sort Members By", value = gs.sortBy or "status", type = "cycle", options = SORT_OPTIONS },
        }
    end
    return {}
end

function NWT.BookkeeperShowDuesSettings()
    local bk = NWT.Bookkeeper
    local guildId = GetGuildId(bk.viewingGuildIndex)
    
    bk.duesSettingsOpen = true
    bk.duesSettingsGuildId = guildId
    bk.duesSettingsTabIndex = 1
    bk.duesSettingsRowIndex = 1
    
    NWT.UpdateDuesSettingsDialog()
    if ATK_DuesSettingsDialog then ATK_DuesSettingsDialog:SetHidden(false) end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

function NWT.UpdateDuesSettingsDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_DuesSettingsDialog
    if not dialog then return end
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local gn = bk.duesSettingsGuildId and bk.duesSettingsGuildId > 0 and GetGuildName(bk.duesSettingsGuildId) or "No Guild"
    dialog:GetNamedChild("GuildName"):SetText("|cFFFFFF" .. gn .. "|r")
    
    -- Update tab highlights
    local tabBar = dialog:GetNamedChild("TabBar")
    for i = 1, 6 do
        local tab = tabBar:GetNamedChild("Tab" .. i)
        if tab then
            if i == bk.duesSettingsTabIndex then
                tab:SetColor(1, 0.84, 0, 1)
            else
                tab:SetColor(0.6, 0.6, 0.6, 1)
            end
        end
    end
    
    -- Get settings for current tab
    local currentTab = DUES_SETTINGS_TABS[bk.duesSettingsTabIndex]
    local content = dialog:GetNamedChild("Content")
    local selectionBG = content:GetNamedChild("SelectionBG")
    local ranksLayout = content:GetNamedChild("RanksLayout")
    
    -- Check if this is the RANKS tab (uses two-column layout)
    local isRanksTab = (currentTab.id == "ranks")
    
    -- Hide standard rows for RANKS tab, show for others
    for i = 1, 10 do
        local row = content:GetNamedChild("Row" .. i)
        if row then row:SetHidden(isRanksTab) end
    end
    
    if isRanksTab then
        -- === TWO-COLUMN RANKS LAYOUT ===
        if ranksLayout then ranksLayout:SetHidden(false) end
        if selectionBG then selectionBG:SetHidden(true) end
        
        -- Initialize column tracking
        if not bk.ranksColumn then bk.ranksColumn = "left" end
        
        -- Get guild ranks data
        local guildId = bk.duesSettingsGuildId or 0
        local rankRows = {}
        if guildId > 0 then
            for i = 1, GetNumGuildRanks(guildId) do
                if not IsGuildRankGuildMaster(guildId, i) then
                    local rankName = GetGuildRankCustomName(guildId, i) or ("Rank " .. i)
                    if #rankName > 16 then rankName = rankName:sub(1,14) .. ".." end
                    
                    -- Exempt status
                    local exemptType = gs.exemptRanks and gs.exemptRanks[i]
                    local exemptText
                    if exemptType == "gm" then exemptText = "|cFFD700GM|r"
                    elseif exemptType == "officer" then exemptText = "|c00FFFFOFFICER|r"
                    elseif exemptType == "lifetime" then exemptText = "|c00FF00LIFETIME|r"
                    elseif exemptType then exemptText = "|c00FFFFEXEMPT|r"
                    else exemptText = "|c888888None|r" end
                    
                    -- Dues override
                    local override = gs.rankDuesOverride and gs.rankDuesOverride[i]
                    local duesText
                    if exemptType then
                        duesText = "|c888888--|r"
                    elseif override and type(override) == "table" then
                        local amt = override.amount or 0
                        local per = override.period or "weekly"
                        local perShort = RANK_PERIOD_SHORT[per] or per
                        duesText = "|c00FF00" .. NWT.FormatGold(amt) .. "|r |cFFFF00/" .. perShort .. "|r"
                    else
                        duesText = "|c888888Default|r"
                    end
                    
                    table.insert(rankRows, { rankIndex = i, name = rankName, exempt = exemptText, dues = duesText })
                end
            end
        end
        bk.ranksData = rankRows
        
        -- Populate left and right columns
        local leftSelBG = ranksLayout:GetNamedChild("LeftSelBG")
        local rightSelBG = ranksLayout:GetNamedChild("RightSelBG")
        
        for i = 1, 10 do
            local leftRow = ranksLayout:GetNamedChild("LeftRow" .. i)
            local rightRow = ranksLayout:GetNamedChild("RightRow" .. i)
            local rData = rankRows[i]
            
            if leftRow then
                if rData then
                    local isLeftSel = (i == bk.duesSettingsRowIndex and bk.ranksColumn == "left")
                    local prefix = isLeftSel and "|cFFFF00► " or "|cFFFFFF  "
                    leftRow:SetText(prefix .. rData.name .. "|r  " .. rData.exempt)
                    leftRow:SetHidden(false)
                else
                    leftRow:SetHidden(true)
                end
            end
            if rightRow then
                if rData then
                    local isRightSel = (i == bk.duesSettingsRowIndex and bk.ranksColumn == "right")
                    local prefix = isRightSel and "|cFFD700► " or ""
                    rightRow:SetText(prefix .. rData.dues)
                    rightRow:SetHidden(false)
                else
                    rightRow:SetHidden(true)
                end
            end
        end
        
        -- Update selection backgrounds
        local rowY = 35 + (bk.duesSettingsRowIndex - 1) * 36
        if leftSelBG then
            leftSelBG:ClearAnchors()
            leftSelBG:SetAnchor(TOPLEFT, ranksLayout, TOPLEFT, 20, rowY - 2)
            leftSelBG:SetHidden(bk.ranksColumn ~= "left")
        end
        if rightSelBG then
            rightSelBG:ClearAnchors()
            rightSelBG:SetAnchor(TOPRIGHT, ranksLayout, TOPRIGHT, -20, rowY - 2)
            rightSelBG:SetHidden(bk.ranksColumn ~= "right")
        end
        
        -- Store for handlers
        bk.currentDuesTabSettings = rankRows
        
        -- Update page info
        local pageInfo = dialog:GetNamedChild("PageInfo")
        if pageInfo then
            local colName = bk.ranksColumn == "left" and "Exempt" or "Dues"
            pageInfo:SetText(string.format("|c888888Column: %s  •  Rank %d of %d|r", colName, bk.duesSettingsRowIndex, #rankRows))
        end
    else
        -- === STANDARD SINGLE-COLUMN LAYOUT ===
        if ranksLayout then ranksLayout:SetHidden(true) end
        
        local settings = GetDuesSettingsForTab(currentTab.id, gs, bk.duesSettingsGuildId or 0)
        bk.currentDuesTabSettings = settings
        
        for i = 1, 10 do
            local row = content:GetNamedChild("Row" .. i)
            if row then
                local setting = settings[i]
                if setting then
                    local isSelected = (i == bk.duesSettingsRowIndex)
                    local labelColor = isSelected and "|cFFFF00" or "|cFFFFFF"
                    local valueColor = isSelected and "|cFFD700" or "|c888888"
                    local prefix = isSelected and "► " or "  "
                    row:SetText(string.format("%s%s%s:|r %s%s|r", labelColor, prefix, setting.label, valueColor, setting.value))
                    row:SetHidden(false)
                else
                    row:SetText("")
                    row:SetHidden(true)
                end
            end
        end
        
        -- Update selection highlight
        if selectionBG and bk.duesSettingsRowIndex <= #settings then
            selectionBG:ClearAnchors()
            selectionBG:SetAnchor(TOPLEFT, content, TOPLEFT, 15, 10 + (bk.duesSettingsRowIndex - 1) * 45)
            selectionBG:SetHidden(false)
        else
            selectionBG:SetHidden(true)
        end
        
        -- Update page info
        local pageInfo = dialog:GetNamedChild("PageInfo")
        if pageInfo then
            pageInfo:SetText(string.format("|c888888Tab %d of %d  •  Item %d of %d|r", bk.duesSettingsTabIndex, #DUES_SETTINGS_TABS, bk.duesSettingsRowIndex, #settings))
        end
    end
end

function NWT.DuesSettingsChangeTab(direction)
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    if direction == "left" then
        bk.duesSettingsTabIndex = bk.duesSettingsTabIndex > 1 and bk.duesSettingsTabIndex - 1 or #DUES_SETTINGS_TABS
    else
        bk.duesSettingsTabIndex = bk.duesSettingsTabIndex < #DUES_SETTINGS_TABS and bk.duesSettingsTabIndex + 1 or 1
    end
    bk.duesSettingsRowIndex = 1
    bk.ranksColumn = "left"  -- Reset to left column on tab change
    NWT.UpdateDuesSettingsDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

-- Switch between left/right columns on RANKS tab
function NWT.DuesSettingsSwitchColumn()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local currentTab = DUES_SETTINGS_TABS[bk.duesSettingsTabIndex]
    if currentTab.id ~= "ranks" then return end
    
    bk.ranksColumn = bk.ranksColumn == "left" and "right" or "left"
    NWT.UpdateDuesSettingsDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.DuesSettingsCycleRow(direction)
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local settings = bk.currentDuesTabSettings or {}
    local numSettings = #settings
    if numSettings == 0 then return end
    
    if direction == "up" then
        bk.duesSettingsRowIndex = bk.duesSettingsRowIndex > 1 and bk.duesSettingsRowIndex - 1 or numSettings
    else
        bk.duesSettingsRowIndex = bk.duesSettingsRowIndex < numSettings and bk.duesSettingsRowIndex + 1 or 1
    end
    NWT.UpdateDuesSettingsDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.DuesSettingsChangeValue()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local settings = bk.currentDuesTabSettings or {}
    local setting = settings[bk.duesSettingsRowIndex]
    if not setting then return end
    
    if setting.type == "toggle" then
        if setting.id == "lateFeeEnabled" then gs.lateFeeEnabled = not gs.lateFeeEnabled
        elseif setting.id == "autoUpdateNotes" then
            gs.autoUpdateNotes = not gs.autoUpdateNotes
            local guildName = GetGuildName(bk.duesSettingsGuildId) or ("Guild " .. (bk.duesSettingsGuildId or 0))
            NWT.Debug("|cFFD700[Bookkeeper]|r " .. guildName .. " - autoUpdateNotes toggled to: " .. tostring(gs.autoUpdateNotes))
        elseif setting.id == "includeUpdateTimestamp" then gs.includeUpdateTimestamp = not gs.includeUpdateTimestamp
        elseif setting.id == "alertOnLogin" then gs.alertOnLogin = not gs.alertOnLogin
        elseif setting.id == "highlightOverdue" then gs.highlightOverdue = not gs.highlightOverdue
        elseif setting.id == "showOfflineStatus" then gs.showOfflineStatus = not gs.showOfflineStatus
        elseif setting.id == "autoDemoteEnabled" then gs.autoDemoteEnabled = not gs.autoDemoteEnabled
        elseif setting.id == "freeTraderMode" then gs.freeTraderMode = not gs.freeTraderMode
        end
    elseif setting.type == "cycle" then
        if setting.id == "duesAmount" then
            local curIdx = 1
            for i, v in ipairs(DUES_AMOUNT_OPTIONS) do if gs.duesAmount == v then curIdx = i break end end
            gs.duesAmount = DUES_AMOUNT_OPTIONS[(curIdx % #DUES_AMOUNT_OPTIONS) + 1]
        elseif setting.id == "ticketPrice" then
            local curIdx = 1
            for i, v in ipairs(DUES_AMOUNT_OPTIONS) do if gs.ticketPrice == v then curIdx = i break end end
            gs.ticketPrice = DUES_AMOUNT_OPTIONS[(curIdx % #DUES_AMOUNT_OPTIONS) + 1]
        elseif setting.id == "duesPeriod" then
            local curIdx = 1
            for i, v in ipairs(PERIOD_OPTIONS) do if gs.duesPeriod == v then curIdx = i break end end
            gs.duesPeriod = PERIOD_OPTIONS[(curIdx % #PERIOD_OPTIONS) + 1]
        elseif setting.id == "gracePeriodDays" then
            local opts = setting.options or GRACE_PERIOD_OPTIONS
            local curIdx = 1
            for i, v in ipairs(opts) do if gs.gracePeriodDays == v then curIdx = i break end end
            gs.gracePeriodDays = opts[(curIdx % #opts) + 1]
        elseif setting.id == "daysBeforeDemotion" then
            local opts = {3, 5, 7, 10, 14, 21, 30}
            local curIdx = 1
            for i, v in ipairs(opts) do if gs.daysBeforeDemotion == v then curIdx = i break end end
            gs.daysBeforeDemotion = opts[(curIdx % #opts) + 1]
        elseif setting.id == "traderFlipDay" then
            gs.traderFlipDay = (gs.traderFlipDay % 7) + 1
        elseif setting.id == "sortBy" then
            local curIdx = 1
            for i, v in ipairs(SORT_OPTIONS) do if gs.sortBy == v then curIdx = i break end end
            gs.sortBy = SORT_OPTIONS[(curIdx % #SORT_OPTIONS) + 1]
        elseif setting.id == "noteFormat" then
            local opts = {"range", "due", "paid", "custom"}
            local curIdx = 1
            for i, v in ipairs(opts) do if gs.noteFormat == v then curIdx = i break end end
            gs.noteFormat = opts[(curIdx % #opts) + 1]
        end
    elseif setting.type == "number" then
        if setting.id == "duesSuffix" then gs.duesSuffix = (gs.duesSuffix + 1) % 11
        elseif setting.id == "customDaysPeriod" then gs.customDaysPeriod = ((gs.customDaysPeriod or 7) % 60) + 1
        elseif setting.id == "lateFeeAmount" then gs.lateFeeAmount = ((gs.lateFeeAmount or 0) + 1000) % 51000
        elseif setting.id == "alertUnpaidCount" then gs.alertUnpaidCount = ((gs.alertUnpaidCount or 0) + 5) % 105
        end
    elseif setting.type == "rank_select" then
        -- Cycle through available ranks for demotion rank
        local guildId = bk.duesSettingsGuildId
        if guildId and guildId > 0 then
            local numRanks = GetNumGuildRanks(guildId)
            local current = gs.demotionRank or 0
            current = current + 1
            if current > numRanks then current = 0 end  -- 0 = not set
            gs.demotionRank = current > 0 and current or nil
        end
    elseif setting.type == "text_input" then
        -- Open text input dialog
        if setting.id == "customNoteFormat" then
            NWT.BookkeeperShowNoteFormatInput(bk.duesSettingsGuildId)
        end
        return  -- Don't play sound or update yet
    elseif setting.type == "action" then
        if setting.id == "scanGuild" then NWT.ScanGuildForBookkeeper(bk.duesSettingsGuildId)
        elseif setting.id == "scanNotes" then NWT.BookkeeperScanPaymentNotes(bk.duesSettingsGuildId)
        elseif setting.id == "reformatNotes" then NWT.BookkeeperReformatAllNotes(bk.duesSettingsGuildId)
        elseif setting.id == "exportUnpaid" then NWT.BookkeeperExportUnpaid(bk.duesSettingsGuildId)
        elseif setting.id == "previewDemotions" then NWT.PreviewDemotions(bk.duesSettingsGuildId)
        elseif setting.id == "runDemotions" then NWT.RunDemotions(bk.duesSettingsGuildId)
        elseif setting.id == "restoreAll" then NWT.RestoreAllDemoted(bk.duesSettingsGuildId)
        elseif setting.id == "clearData" then
            gs.memberPayments = {}
            gs.salesData = {}
            gs.demotedMembers = {}
            gs.paymentHistory = {}
            gs.lastScanTime = 0
            -- Also clear noteUpdates for this guild (stored separately)
            local sv = NWT.savedVars
            if type(sv.bookkeeper) == "table" and type(sv.bookkeeper.noteUpdates) == "table" then
                sv.bookkeeper.noteUpdates[bk.duesSettingsGuildId] = nil
            end
NWT.Debug("|cFFFF00[Bookkeeper]|r Data cleared for " .. GetGuildName(bk.duesSettingsGuildId))
        end
    elseif setting.rankIndex then
        -- Two-column RANKS tab handling
        local rankIdx = setting.rankIndex
        
        if bk.ranksColumn == "left" then
            -- LEFT COLUMN: Cycle exempt status (None -> GM -> Officer -> Lifetime -> None)
            if not gs.exemptRanks then gs.exemptRanks = {} end
            local current = gs.exemptRanks[rankIdx]
            
            if not current then
                gs.exemptRanks[rankIdx] = "gm"
            elseif current == "gm" then
                gs.exemptRanks[rankIdx] = "officer"
            elseif current == "officer" then
                gs.exemptRanks[rankIdx] = "lifetime"
            else
                gs.exemptRanks[rankIdx] = nil
                -- Also clear dues override when removing exempt
            end
        else
            -- RIGHT COLUMN: Increase dues amount with smart increments
            local isExempt = gs.exemptRanks and gs.exemptRanks[rankIdx]
            if isExempt then return end  -- Can't edit dues for exempt ranks
            
            if not gs.rankDuesOverride then gs.rankDuesOverride = {} end
            local override = gs.rankDuesOverride[rankIdx]
            
            if not override or type(override) ~= "table" then
                -- Initialize with guild defaults
                gs.rankDuesOverride[rankIdx] = { amount = gs.duesAmount or 5000, period = gs.duesPeriod or "weekly" }
            else
                -- Increase amount with smart increment
                local currentAmount = override.amount or 0
                local increment = GetAmountIncrement(currentAmount, 1)
                local newAmount = currentAmount + increment
                if newAmount > 20000000 then newAmount = 0 end  -- Wrap to 0 (back to default)
                if newAmount == 0 then
                    gs.rankDuesOverride[rankIdx] = nil
                else
                    override.amount = newAmount
                end
            end
        end
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateDuesSettingsDialog()
    NWT.UpdateBookkeeperUI()
end

-- X button: Cycle period for selected rank (only works on right column)
function NWT.DuesSettingsCyclePeriod()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local currentTab = DUES_SETTINGS_TABS[bk.duesSettingsTabIndex]
    if currentTab.id ~= "ranks" then return end
    if bk.ranksColumn ~= "right" then return end  -- Only on right column
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local rankData = bk.ranksData and bk.ranksData[bk.duesSettingsRowIndex]
    if not rankData then return end
    
    local rankIdx = rankData.rankIndex
    local isExempt = gs.exemptRanks and gs.exemptRanks[rankIdx]
    if isExempt then return end  -- Can't change period on exempt rank
    
    if not gs.rankDuesOverride then gs.rankDuesOverride = {} end
    local override = gs.rankDuesOverride[rankIdx]
    
    if not override or type(override) ~= "table" then
        -- Initialize with guild defaults, then cycle period
        gs.rankDuesOverride[rankIdx] = { amount = gs.duesAmount or 5000, period = "biweekly" }
    else
        -- Cycle to next period
        local currentPeriod = override.period or "weekly"
        local currentIdx = 1
        for i, p in ipairs(RANK_PERIOD_OPTIONS) do
            if p == currentPeriod then currentIdx = i break end
        end
        override.period = RANK_PERIOD_OPTIONS[(currentIdx % #RANK_PERIOD_OPTIONS) + 1]
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateDuesSettingsDialog()
end

-- Y button: Toggle exempt for selected rank
function NWT.DuesSettingsToggleExempt()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local settings = bk.currentDuesTabSettings or {}
    local setting = settings[bk.duesSettingsRowIndex]
    if not setting or setting.type ~= "rank_config" then return end
    
    if not gs.exemptRanks then gs.exemptRanks = {} end
    
    local isExempt = gs.exemptRanks[setting.rankIndex]
    if isExempt then
        -- Clear exempt
        gs.exemptRanks[setting.rankIndex] = nil
    else
        -- Set exempt and clear any dues override
        gs.exemptRanks[setting.rankIndex] = true
        if gs.rankDuesOverride then gs.rankDuesOverride[setting.rankIndex] = nil end
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateDuesSettingsDialog()
end

-- Increase amount (for X button on RANKS tab)
function NWT.DuesSettingsIncreaseAmount()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local currentTab = DUES_SETTINGS_TABS and DUES_SETTINGS_TABS[bk.duesSettingsTabIndex]
    if not currentTab or currentTab.id ~= "ranks" then return end
    if bk.ranksColumn ~= "right" then return end  -- Only on right column
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local rankData = bk.ranksData and bk.ranksData[bk.duesSettingsRowIndex]
    if not rankData then return end
    
    local rankIdx = rankData.rankIndex
    local isExempt = gs.exemptRanks and gs.exemptRanks[rankIdx]
    if isExempt then return end
    
    if not gs.rankDuesOverride then gs.rankDuesOverride = {} end
    local override = gs.rankDuesOverride[rankIdx]
    
    if not override or type(override) ~= "table" then
        -- Initialize with guild default + first increment
        local baseAmount = gs.duesAmount or 5000
        gs.rankDuesOverride[rankIdx] = { amount = baseAmount + GetAmountIncrement(baseAmount, 1), period = gs.duesPeriod or "weekly" }
    else
        local currentAmount = override.amount or 0
        local increment = GetAmountIncrement(currentAmount, 1)
        local newAmount = currentAmount + increment
        if newAmount > 20000000 then newAmount = 20000000 end
        override.amount = newAmount
    end
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateDuesSettingsDialog()
end

-- Decrease amount (for Y button on RANKS tab)
function NWT.DuesSettingsDecreaseAmount()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local currentTab = DUES_SETTINGS_TABS and DUES_SETTINGS_TABS[bk.duesSettingsTabIndex]
    if not currentTab or currentTab.id ~= "ranks" then return end
    if bk.ranksColumn ~= "right" then return end  -- Only on right column
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local rankData = bk.ranksData and bk.ranksData[bk.duesSettingsRowIndex]
    if not rankData then return end
    
    local rankIdx = rankData.rankIndex
    local isExempt = gs.exemptRanks and gs.exemptRanks[rankIdx]
    if isExempt then return end
    
    if not gs.rankDuesOverride then gs.rankDuesOverride = {} end
    local override = gs.rankDuesOverride[rankIdx]
    
    if not override or type(override) ~= "table" then
        -- No override (default) - wrap to 20m
        gs.rankDuesOverride[rankIdx] = { amount = 20000000, period = gs.duesPeriod or "weekly" }
    else
        local currentAmount = override.amount or 0
        local decrement = GetAmountIncrement(currentAmount, -1)
        local newAmount = currentAmount + decrement  -- decrement is negative
        if newAmount < 1000 then
            gs.rankDuesOverride[rankIdx] = nil  -- Back to default
        else
            override.amount = newAmount
        end
    end
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateDuesSettingsDialog()
end

function NWT.CloseDuesSettingsDialog()
    local bk = NWT.Bookkeeper
    bk.duesSettingsOpen = false
    bk.duesSettingsGuildId = nil
    bk.duesSettingsTabIndex = 1
    bk.duesSettingsRowIndex = 1
    bk.currentDuesTabSettings = nil
    if ATK_DuesSettingsDialog then ATK_DuesSettingsDialog:SetHidden(true) end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

-- Export/member-details/demotion implementations moved to BookkeeperCommands.lua
