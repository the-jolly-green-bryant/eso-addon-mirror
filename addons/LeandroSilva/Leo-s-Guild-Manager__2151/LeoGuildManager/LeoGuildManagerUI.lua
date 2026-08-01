
LeoGuildManager.hidden = true
LeoGuildManager.memberScroll = nil
LeoGuildManager.selectedRank = nil
LeoGuildManager.endangered = {}

local purgeTotal = 0

function LeoGuildManagerUI:OnWindowMoveStop()
    LeoGuildManager.globalData.position = {
        left = LeoGuildManagerWindow:GetLeft(),
        top = LeoGuildManagerWindow:GetTop()
    }
end

function LeoGuildManagerUI:OnHide(control, hidden)
    if hidden then LeoGuildManagerUI.HideUI() end
end

function LeoGuildManagerUI:OnShow(control, hidden)
    if not hidden then LeoGuildManagerUI.ShowUI() end
end

function LeoGuildManagerUI:isHidden()
    return LeoGuildManager.hidden
end

function LeoGuildManagerUI.RestorePosition()
    local position = LeoGuildManager.globalData.position or { left = 200; top = 200; }
    local left = position.left
    local top = position.top

    LeoGuildManagerWindow:ClearAnchors()
    LeoGuildManagerWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    LeoGuildManagerWindow:SetDrawLayer(DL_OVERLAY)
    LeoGuildManagerWindow:SetDrawTier(DT_LOW)
end

function LeoGuildManagerUI.CloseUI()
    SCENE_MANAGER:HideTopLevel(LeoGuildManagerWindow)
end

function LeoGuildManagerUI.ShowUI()
    if not LeoGuildManager.globalData.selectedGuild then
        SCENE_MANAGER:ToggleTopLevel(LeoGuildManagerWindow)
        LeoGuildManager.log("No guild enabled on Settings.")
        DoCommand("/leogmoptions")
        return
    end
    LeoGuildManager.hidden = false;
    LeoGuildManager.ShowTab(LeoGuildManager.globalData.activeTab or LeoGuildManager.TAB_PURGE)
end

function LeoGuildManagerUI.HideUI()
    LeoGuildManager.hidden = true;
end

function LeoGuildManagerUI.ToggleUI()
    SCENE_MANAGER:ToggleTopLevel(LeoGuildManagerWindow)
end

function LeoGuildManager.ShowTab(tab)
    local control
    local hasTab = false
    for _,panel in ipairs(LeoGuildManager.panelList) do
        control = WINDOW_MANAGER:GetControlByName('LeoGuildManagerWindow' .. panel .. 'Panel')
        control:SetHidden(true)
        if tab == panel then hasTab = true end
    end
    if not hasTab then tab = LeoGuildManager.TAB_PURGE end

    if tab == LeoGuildManager.TAB_PURGE then
        local descPurge = LeoGuildManager.CreatePurgeDescription(LeoGuildManager.globalData.selectedGuild)
        LeoGuildManagerWindowPurgePanelPurgeDesc:SetText("|c"..LeoGuildManager.color.hex.yellow..descPurge.."|r")
        --[[if LeoGuildManager.GuildNeedsScan(LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)) then
            LeoGuildManagerWindowPurgePanelScanButton:SetHidden(false)
        else
            LeoGuildManagerWindowPurgePanelScanButton:SetHidden(true)
        end--]]
    end

    LeoGuildManager.globalData.activeTab = tab
    LeoGuildManagerWindowTitle:SetText(LeoGuildManager.displayName .. " v" .. LeoGuildManager.version .. " - " .. tab)
    control = WINDOW_MANAGER:GetControlByName("LeoGuildManagerWindow" .. tab .. "Panel")
    control:SetHidden(false)
end


LeoGuildManagerMemberList = ZO_SortFilterList:Subclass()
function LeoGuildManagerMemberList:New(control)

    ZO_SortFilterList.InitializeSortFilterList(self, control)

    local sorterKeys =
    {
        ["name"] = {},
        ["deposits"] = { isNumeric = true, tiebreaker = "name"},
        ["sales"] = { isNumeric = true, tiebreaker = "name"},
        ["purchases"] = { isNumeric = true, tiebreaker = "name"},
        ["online"] = { isNumeric = true, tiebreaker = "name"},
        ["joined"] = { isNumeric = true, tiebreaker = "name"},
        ["rankIndex"] = { isNumeric = true, tiebreaker = "name"},
    }

    self.masterList = {}
    ZO_ScrollList_AddDataType(self.list, 1, "LeoGuildManagerMemberListTemplate", 32, function(control, data) self:SetupEntry(control, data) end)

    self.sortFunction = function(listEntry1, listEntry2)
        return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sorterKeys, self.currentSortOrder)
    end
    self:SetAlternateRowBackgrounds(true)

    return self
end

local function updateEndangered()
    LeoGuildManagerWindowPurgePanelListResult:SetText("Selected: " .. #LeoGuildManager.endangered .. " / " .. purgeTotal)
    if #LeoGuildManager.endangered > 0 then
        LeoGuildManagerWindowPurgePanelPromoteButton:SetEnabled(true)
        LeoGuildManagerWindowPurgePanelDemoteButton:SetEnabled(true)
        LeoGuildManagerWindowPurgePanelKickButton:SetEnabled(true)
    else
        LeoGuildManagerWindowPurgePanelPromoteButton:SetEnabled(false)
        LeoGuildManagerWindowPurgePanelDemoteButton:SetEnabled(false)
        LeoGuildManagerWindowPurgePanelKickButton:SetEnabled(false)
    end
end

local function findCheckboxByName(member)
    local content = LeoGuildManagerWindowPurgePanelMemberScrollListContents
    for i = 1, content:GetNumChildren() do
        local row = content:GetChild(i)
        local checkbox = GetControl(row, "Checkbox")
        if member == checkbox.data then return checkbox end
    end
end

local function removeEndangered(member, control)
    LeoGuildManager.SetEndangered(member, false)
    for i, name in ipairs(LeoGuildManager.endangered) do
        if name == member then
            table.remove(LeoGuildManager.endangered, i)
            break
        end
    end
    if control == nil then
        control = findCheckboxByName(member)
    end
    if control ~= nil then
        control:SetTexture('/esoui/art/buttons/checkbox_unchecked.dds')
        control.isEndangered = false
    end
end

local function promoteNext()
    local guildId = LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)
    for i, member in pairs(LeoGuildManager.endangered) do
        LeoGuildManager.log("Promoting " .. member .. " ...")
        GuildPromote(guildId, member)
        table.remove(LeoGuildManager.endangered, i)
        removeEndangered(member)

        LeoGuildManager.UpdateMemberRank(guildId, member)

        LeoGuildManagerMemberList:RefreshData()
        zo_callLater(promoteNext, 2500)
        return
    end
end

local function demoteNext()
    local guildId = LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)
    for i, member in pairs(LeoGuildManager.endangered) do
        LeoGuildManager.log("Demoting " .. member .. " ...")
        GuildDemote(guildId, member)
        table.remove(LeoGuildManager.endangered, i)
        removeEndangered(member)

        LeoGuildManager.UpdateMemberRank(guildId, member)

        LeoGuildManagerMemberList:RefreshData()
        zo_callLater(demoteNext, 2500)
        return
    end
end

local function kickNext()
    local guildId = LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)
    for i, member in pairs(LeoGuildManager.endangered) do
        LeoGuildManager.log("Removing " .. member .. " ...")
        GuildRemove(guildId, member)
        removeEndangered(member)
        LeoGuildManager.RemoveMember(member)

        LeoGuildManagerMemberList:RefreshData()
        zo_callLater(kickNext, 2500)
        return
    end
end

function LeoGuildManager.DemoteAllClick(control, button, upInside)

    local guildId = LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_DEMOTE) then
        LeoGuildManager.log("|cFF2222You don't have permission to demote members of this guild.|r")
        return
    end

    local LAM = LibStub("LibAddonMenu-2.0")
    LAM.util.ShowConfirmationDialog("Confirmation", "Do you really want to demote ALL selected members???", function()
        zo_callLater(demoteNext, 1000)
    end)
end

function LeoGuildManager.PromoteAllClick(control, button, upInside)

    local guildId = LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_PROMOTE) then
        LeoGuildManager.log("|cFF2222You don't have permission to promote members of this guild.|r")
        return
    end

    local LAM = LibStub("LibAddonMenu-2.0")
    LAM.util.ShowConfirmationDialog("Confirmation", "Do you really want to promote ALL selected members???", function()
        zo_callLater(promoteNext, 1000)
    end)
end

function LeoGuildManager.KickAllClick(control, button, upInside)

    local guildId = LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)

    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_DEMOTE) then
        LeoGuildManager.log("|cFF2222You don't have permission to remove members from this guild.|r")
        return
    end

    local LAM = LibStub("LibAddonMenu-2.0")
    LAM.util.ShowConfirmationDialog("Confirmation", "Do you really want to remove ALL selected members from the guild???", function()
        zo_callLater(kickNext, 1000)
    end)
end

function LeoGuildManager.UserClick(control, button, upInside)

    if not upInside or button ~= MOUSE_BUTTON_INDEX_RIGHT then return end

    local player = control.data
    local guildId = LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)
    if type(player) == 'string' then
        ClearMenu()
        AddMenuItem(GetString(SI_SOCIAL_LIST_SEND_MESSAGE), function() StartChatInput(nil, CHAT_CHANNEL_WHISPER, player) end)
        AddMenuItem(GetString(SI_SOCIAL_MENU_SEND_MAIL), function() MAIL_SEND:ComposeMailTo(player) end)
        if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT) then
            -- Soon
            --AddMenuItem(GetString(SI_SOCIAL_MENU_EDIT_NOTE), LeoGuildManager.EditMemberNote(control, player))
        end
        if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_DEMOTE) then
            AddMenuItem(GetString(SI_GUILD_DEMOTE), function() GuildDemote(guildId, player) end)
        end
        if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_REMOVE) then
            AddMenuItem(GetString(SI_GUILD_REMOVE), function() GuildRemove(guildId, player) end)
        end
        ShowMenu(control)
    end
end

function LeoGuildManager.ClearSelected(control, button, upInside)
    local content = LeoGuildManagerWindowPurgePanelMemberScrollListContents
    for i = 1, content:GetNumChildren() do
        local row = content:GetChild(i)
        local checkbox = GetControl(row, "Checkbox")
        if checkbox.isEndangered == true then
            local member = checkbox.data
            removeEndangered(member, checkbox)
        end
    end
    updateEndangered()
end

function LeoGuildManager.CheckboxClick(control, button, upInside)

    if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then return end

    local member = control.data

    if not LeoGuildManager.IsEndangered(member) then
        LeoGuildManager.SetEndangered(member, true)
        table.insert(LeoGuildManager.endangered, member)
        control:SetTexture('/esoui/art/buttons/checkbox_checked.dds')
        control.isEndangered = true
    else
        removeEndangered(member, control)
    end

    updateEndangered()
end

function LeoGuildManagerMemberList:SetupEntry(control, data)

    control.data = data

    local guildId = LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)
    local canScan = LeoGuildManager.CanScanBankHistory(guildId)
    local integrationLoaded = LeoGuildManager.HasIntegrationAddonsLoaded()
    local ATTLoaded = LeoGuildManager.HasIntegrationAddonsLoaded(2)

    control.checkbox = GetControl(control, "Checkbox")
    if data.endangered then
        control.checkbox:SetTexture('/esoui/art/buttons/checkbox_checked.dds')
    else
        control.checkbox:SetTexture('/esoui/art/buttons/checkbox_unchecked.dds')
    end
    control.checkbox.data = data.name

    control.name = GetControl(control, "Name")
    control.name:SetText(data.name)
    control.name.data = data.name

    control.deposits = GetControl(control, "Deposits")
    if canScan then
        control.deposits:SetText(LeoGuildManager.formatNumber(data.deposits))
    else
        control.deposits:SetText("-")
    end

    control.sales = GetControl(control, "Sales")
    if integrationLoaded then
        control.sales:SetText(LeoGuildManager.formatNumber(data.sales))
    else
        control.sales:SetText("-")
    end

    control.purchases = GetControl(control, "Purchases")
    if ATTLoaded then
        control.purchases:SetText(LeoGuildManager.formatNumber(data.purchases))
    else
        control.purchases:SetText("-")
    end

    control.online = GetControl(control, "Online")
    control.online:SetText(LeoGuildManager.GetTime(data.online))

    control.joined = GetControl(control, "Joined")
    if data.joined > 0 then
        control.joined:SetText(LeoGuildManager.FormatTimeAgo(GetTimeStamp() - data.joined))
    else
        control.joined:SetText("")
    end

    local rankName = GetGuildRankCustomName(guildId, data.rankIndex)
    if rankName == "" then
        rankName = GetDefaultGuildRankName(guildId, data.rankIndex)
    end
    control.rank = GetControl(control, "Rank")
    control.rank:SetText(rankName)

    ZO_SortFilterList.SetupRow(self, control, data)
end

function LeoGuildManagerMemberList:BuildMasterList()
    self.masterList = {}
    local list = LeoGuildManager.members
    if list then
        for k, v in ipairs(list) do
            local data = v
            table.insert(self.masterList, data)
        end
    end
end

function LeoGuildManagerMemberList:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end

function LeoGuildManagerMemberList:ColorRow(control, data, mouseIsOver)

    local guildData = LeoGuildManager.globalData.settings.guilds[LeoGuildManager.globalData.selectedGuild]
    local guildId = LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)
    local canScan = LeoGuildManager.CanScanBankHistory(guildId)
    local integrationLoaded = LeoGuildManager.HasIntegrationAddonsLoaded()
    local ATTLoaded = LeoGuildManager.HasIntegrationAddonsLoaded(2)
    local purchases = LeoGuildManager.GetPurgePurchases(LeoGuildManager.globalData.selectedGuild)

    local ticketsThreshold = guildData.tickets * 1000
    local salesThreshold = guildData.sales * 1000
    local purchasesThreshold = purchases * 1000
    local offlineThreshold = guildData.inactivity * LeoGuildManager.SECONDS_IN_DAY

    local child = GetControl(control, "Name")
    child:SetColor(1,1,1)

    child = GetControl(control, "Deposits")
    if canScan then
        child:SetColor(0,1,0)
        if ticketsThreshold > 0 and data.deposits < ticketsThreshold then
            child:SetColor(1,0,0)
        end
    else
        child:SetColor(1,1,1)
    end

    child = GetControl(control, "Sales")
    if integrationLoaded then
        child:SetColor(0,1,0)
        if salesThreshold > 0 and data.sales < salesThreshold then
            child:SetColor(1,0,0)
        end
    else
        child:SetColor(1,1,1)
    end

    child = GetControl(control, "Purchases")
    child:SetColor(1,1,1)
    if ATTLoaded then
        if purchasesThreshold > 0 then
            if data.purchases < purchasesThreshold then
                child:SetColor(1,0,0)
            else
                child:SetColor(0,1,0)
            end
        end
    else
        child:SetColor(1,1,1)
    end

    child = GetControl(control, "Online")
    child:SetColor(0,1,0)
    if offlineThreshold > 0 and data.online > 0 and data.online > offlineThreshold then
        child:SetColor(1,0,0)
    end
end

function LeoGuildManagerMemberList:FilterScrollList()

    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local guildData = LeoGuildManager.globalData.settings.guilds[LeoGuildManager.globalData.selectedGuild]
    local purchases = LeoGuildManager.GetPurgePurchases(LeoGuildManager.globalData.selectedGuild)

    local ticketsThreshold = guildData.tickets * 1000
    local salesThreshold = guildData.sales * 1000
    local purchasesThreshold = purchases * 1000
    local offlineThreshold = guildData.inactivity * LeoGuildManager.SECONDS_IN_DAY
    local ignoreRank = guildData.ignoreRank
    local ignoreNew = guildData.ignoreNew * LeoGuildManager.SECONDS_IN_DAY
    local now = GetTimeStamp()
    local guildId = LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)
    local canScan = LeoGuildManager.CanScanBankHistory(guildId)
    local integrationLoaded = LeoGuildManager.HasIntegrationAddonsLoaded()

    for i = 1, #self.masterList do
        local data = self.masterList[i]
        local canAdd = true
        if integrationLoaded and salesThreshold > 0 and data.sales >= salesThreshold then
            canAdd = false
        end
        if canAdd and canScan and ticketsThreshold > 0 and data.deposits >= ticketsThreshold then
            canAdd = false
        end
        if canAdd and canScan and purchasesThreshold > 0 and data.purchases >= purchasesThreshold then
            canAdd = false
        end

        --Add even if sold a lot??
        if not canAdd and offlineThreshold > 0 and data.online > 0 and data.online > offlineThreshold then
            canAdd = true
        end
        --[[ -- Dont add even if dont sell??
        if canAdd and offlineThreshold > 0 and data.secsSinceLogoff <= offlineThreshold then
            canAdd = false
        end]]
        if canAdd and ignoreNew > 0 and data.joined > 0 and now - data.joined <= ignoreNew then
            canAdd = false
        end
        if canAdd and ignoreRank and ignoreRank > 0 and data.rankIndex <= ignoreRank then
            canAdd = false
        end
        if canAdd then
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
        end
    end
    purgeTotal = #scrollData
    LeoGuildManagerWindowPurgePanelListResult:SetText("Selected: 0 / " .. purgeTotal)
end

local function getStartOfDay(relativeDay)
    relativeDay = relativeDay or 0

    local timeStamp = GetTimeStamp()
    local days = math.floor(timeStamp / LeoGuildManager.SECONDS_IN_DAY)

    timeStamp = days * LeoGuildManager.SECONDS_IN_DAY
    timeStamp = timeStamp + relativeDay * LeoGuildManager.SECONDS_IN_DAY

    return timeStamp
end

local function getStartOfWeek(relativeWeek, useTradeWeek)
    relativeWeek = relativeWeek or 0

    local currentTimeStamp = GetTimeStamp()
    local days = math.floor(currentTimeStamp / LeoGuildManager.SECONDS_IN_DAY)
    local today = days % 7

    local result = days * LeoGuildManager.SECONDS_IN_DAY

    local past = {}
    past[0] = 3 * LeoGuildManager.SECONDS_IN_DAY -- Thursday
    past[1] = 4 * LeoGuildManager.SECONDS_IN_DAY -- Friday
    past[2] = 5 * LeoGuildManager.SECONDS_IN_DAY -- Saturday
    past[3] = 6 * LeoGuildManager.SECONDS_IN_DAY -- Sunday
    past[4] = 0                  -- Monday
    past[5] = 1 * LeoGuildManager.SECONDS_IN_DAY -- Tuesday
    past[6] = 2 * LeoGuildManager.SECONDS_IN_DAY -- Wednesday

    -- Monday midnight --
    result = result - past[today]
    result = result + relativeWeek * LeoGuildManager.SECONDS_IN_WEEK

    if (useTradeWeek) then
        -- Adjust to server locations
        if (GetWorldName() == "EU Megaserver") then
            -- EU - Sundays 19:00 pm UTC
            local secondsLeftThisWeek = getStartOfWeek(1) - currentTimeStamp
            local hoursLeftThisWeek = math.floor(secondsLeftThisWeek / LeoGuildManager.SECONDS_IN_HOUR)

            if (hoursLeftThisWeek < 5) then
                result = result + LeoGuildManager.SECONDS_IN_WEEK
            end

            result = result - 5 * LeoGuildManager.SECONDS_IN_HOUR
        else
            -- NA/PTS - Mondays 01:00 am UTC
            local secondsGoneThisWeek = currentTimeStamp - getStartOfWeek(0)
            local hoursGoneThisWeek = math.floor(secondsGoneThisWeek / LeoGuildManager.SECONDS_IN_HOUR)

            if (hoursGoneThisWeek < 1) then
                result = result - LeoGuildManager.SECONDS_IN_WEEK
            end

            result = result + 1 * LeoGuildManager.SECONDS_IN_HOUR
        end
    end

    return result
end

local function getSalesData(memberName, cycle, start, finish)
    local guildName = LeoGuildManager.globalData.selectedGuild

    if LeoGuildManager.globalData.settings.integration == LeoGuildManager.integrations[1] then
        if MasterMerchant and
                MasterMerchant.guildSales and MasterMerchant.guildSales[guildName] and
                MasterMerchant.guildSales[guildName].sellers and MasterMerchant.guildSales[guildName].sellers[memberName] and
                MasterMerchant.guildSales[guildName].sellers[memberName].sales[cycle] then
            return 0, MasterMerchant.guildSales[guildName].sellers[memberName].sales[cycle]
        end
    elseif LeoGuildManager.globalData.settings.integration == LeoGuildManager.integrations[2] then
        return ArkadiusTradeTools.Modules.Sales:GetPurchasesAndSalesVolumes(guildName, memberName, start, finish)
    end

    return 0, 0
end

local function getStartFinishFromCycle(cycle)

    if cycle == 3 then return getStartOfWeek(0), GetTimeStamp() -- this week
    elseif cycle == 4 then return getStartOfWeek(-1), getStartOfWeek(0) -- Last week
    elseif cycle == 5 then return getStartOfWeek(-2), getStartOfWeek(-1) -- Prior week
    elseif cycle == 8 then return getStartOfDay(-7), GetTimeStamp() -- Last 7 days
    elseif cycle == 6 then return getStartOfDay(-10), GetTimeStamp() -- Last 10 days
    elseif cycle == 14 then return getStartOfDay(-14), GetTimeStamp() -- Last 14 days
    elseif cycle == 7 then return getStartOfDay(-30), GetTimeStamp() -- Last 30 days
    end

    return nil, nil
end

function LeoGuildManager.ClearList()
    LeoGuildManager.members = {}
    LeoGuildManagerMemberList:RefreshData()
    LeoGuildManagerWindowPurgePanelPromoteButton:SetEnabled(false)
    LeoGuildManagerWindowPurgePanelDemoteButton:SetEnabled(false)
    LeoGuildManagerWindowPurgePanelKickButton:SetEnabled(false)
end

function LeoGuildManager.ListPurge()
    local guildId = LeoGuildManager.GetGuildId(LeoGuildManager.globalData.selectedGuild)
    local guildName = LeoGuildManager.globalData.selectedGuild

    LeoGuildManager.GetGuildMembers(guildId)

    --[[if not LeoGuildManager.CanScanBankHistory(guildId) then
        LeoGuildManager.log("|cFF2222You don't have permission to scan guild gold deposits.|r")
    end]]

    if LeoGuildManager.globalData.settings.integration == LeoGuildManager.integrations[1] and (MasterMerchant == nil or
        MasterMerchant.guildSales == nil or
        MasterMerchant.guildSales[guildName] == nil or
        MasterMerchant.guildSales[guildName].sellers == nil)
    then
        LeoGuildManager.log("|cFF2222MasterMerchant sales data not found for this guild.|r Try again in a few moments if it is still initializing.")
    end

    if LeoGuildManager.globalData.settings.integration == LeoGuildManager.integrations[2] and (ArkadiusTradeTools == nil or
            ArkadiusTradeTools.Modules == nil or
            ArkadiusTradeTools.Modules.Sales == nil)
    then
        LeoGuildManager.log("|cFF2222ArkadiusTradeTools sales not found for this guild.|r Try again in a few moments if it is still initializing.")
    end

    local canScan = LeoGuildManager.CanScanBankHistory(guildId)
    local integrationLoaded = LeoGuildManager.HasIntegrationAddonsLoaded()

    local cycle = LeoGuildManager.globalData.settings.guilds[guildName].cycle
    local start, finish = getStartFinishFromCycle(cycle)
    if (start == nil or finish == nil) and (canScan == true or integrationLoaded == true) then
        LeoGuildManager.log("Error fetching time frame settings. Did you configure the guild in the Settings?")
        return
    end

    if canScan then
        if LeoGuildManager.scanData[guildName] == nil or LeoGuildManager.scanData[guildName][GUILD_HISTORY_BANK] == nil then return end

        for _, event in pairs(LeoGuildManager.scanData[guildName][GUILD_HISTORY_BANK].events) do
            if event.type == GUILD_EVENT_BANKGOLD_ADDED and event.timeStamp >= start and event.timeStamp <= finish then
                LeoGuildManager.AddDeposit(event.member, event.gold, event.timeStamp)
            end
        end
    end

    for i = 1, #LeoGuildManager.members do
        local name = LeoGuildManager.members[i].name
        if LeoGuildManager.UseTooltipRoster(guildName) and LeoGuildManager.scanData[guildName].members[name] ~= nil and
                LeoGuildManager.scanData[guildName].members[name].joined ~= nil then
            LeoGuildManager.SetJoined(name, LeoGuildManager.scanData[guildName].members[name].joined)
        end
    end

    if integrationLoaded then
        for i = 1, #LeoGuildManager.members do
            local name = LeoGuildManager.members[i].name
            local purchase, sale = getSalesData(name, cycle, start, finish)
            if sale ~= nil and sale > 0 then
                LeoGuildManager.AddSale(name, sale)
            end
            if purchase > 0 then
                LeoGuildManager.AddPurchase(name, purchase)
            end
        end
    end

    LeoGuildManagerMemberList:RefreshData()
end

function LeoGuildManagerWindow.OnBlacklistChanged(guildId, guild, text)
    LeoGuildManager.globalData.settings.guilds[guild].blacklist = {}
    for line in string.gmatch( text, "[^\r\n]+" ) do
        if line ~= nil and line:len() > 1 then
            table.insert(LeoGuildManager.globalData.settings.guilds[guild].blacklist, line)
        end
    end
    local label = WINDOW_MANAGER:GetControlByName("LeoGuildManagerSettingsBlacklistLabel" .. guildId)
    label.data.text = "Members: " .. table.concat(LeoGuildManager.globalData.settings.guilds[guild].blacklist, ", ")
    label:UpdateValue()
end

function LeoGuildManagerUI.InitializeUI()
    LeoGuildManagerWindowTitle:SetText(LeoGuildManager.displayName .. " v" .. LeoGuildManager.version)

    local LeoGuildManagerWindowGuildDropdown = CreateControlFromVirtual('LeoGuildManagerWindowGuildDropdown', LeoGuildManagerWindow, 'LeoGuildManagerWindowDropdown')
    LeoGuildManagerWindowGuildDropdown:SetDimensions(200,35)
    LeoGuildManagerWindowGuildDropdown:SetAnchor(LEFT, LeoGuildManagerWindowHeaderBG, RIGHT, -204, 0)
    LeoGuildManagerWindowGuildDropdown.m_comboBox:SetSortsItems(false)
    local guildDropdown = ZO_ComboBox_ObjectFromContainer(LeoGuildManagerWindowGuildDropdown)
    guildDropdown:ClearItems()

    local defaultItem
    local initializing = true
    for _, guildName in pairs(LeoGuildManager.guilds) do
        if LeoGuildManager.globalData.settings.guilds[guildName].enabled == true then
            local guildEntry = guildDropdown:CreateItemEntry(guildName, function()
                LeoGuildManager.globalData.selectedGuild = guildName
                if LeoGuildManager.globalData.activeTab == LeoGuildManager.TAB_PURGE then
                    local descPurge = LeoGuildManager.CreatePurgeDescription(guildName)
                    LeoGuildManagerWindowPurgePanelPurgeDesc:SetText("|c"..LeoGuildManager.color.hex.yellow..descPurge.."|r")
                end
                if not initializing then
                    LeoGuildManager.ClearList()
                end
                --[[if LeoGuildManager.GuildNeedsScan(LeoGuildManager.GetGuildId(guildName)) then
                    LeoGuildManagerWindowPurgePanelScanButton:SetHidden(false)
                else
                    LeoGuildManagerWindowPurgePanelScanButton:SetHidden(true)
                end--]]
            end)
            if not LeoGuildManager.globalData.selectedGuild then
                LeoGuildManager.globalData.selectedGuild = guildName
            end
            if LeoGuildManager.globalData.selectedGuild and LeoGuildManager.globalData.selectedGuild == guildName then
                defaultItem = guildEntry
            end
            guildDropdown:AddItem(guildEntry)
        end
    end

    if defaultItem ~= nil then
        guildDropdown:SelectItem(defaultItem)
    end
    initializing = false

    LeoGuildManager.memberScroll = LeoGuildManagerMemberList:New(LeoGuildManagerWindowPurgePanelMemberScroll)

    local descPurge = LeoGuildManager.CreatePurgeDescription(LeoGuildManager.globalData.selectedGuild)
    if descPurge ~= nil then
        LeoGuildManagerWindowPurgePanelPurgeDesc:SetText("|c"..LeoGuildManager.color.hex.yellow..descPurge.."|r")
    end

    LeoGuildManagerWindowPurgePanelLoadingIcon.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual('LoadIconAnimation', LeoGuildManagerWindowPurgePanelLoadingIcon)
end

function LeoGuildManager.GetTime(seconds)
    if seconds and seconds > 0 then
        local ss = seconds % 60
        local mm = math.floor(seconds / 60)
        local hh = math.floor(mm / 60)
        mm = mm % 60
        local dn = math.floor(hh / 24)
        local result = ''
        if dn > 0 then result = tostring(dn) .. "d " .. tostring (hh - (dn*24)) .. "h"
        elseif hh > 0 then result = tostring (hh) .. "h " .. tostring (mm) .. "m"
        elseif mm > 0 then result = mm .. "m " .. ss .. "s"
        end
        return result
    else return 'online' end
end

local function addLine(tooltip, text, color)
    if not color then color = ZO_TOOLTIP_DEFAULT_COLOR end
    local r, g, b = color:UnpackRGB()
    tooltip:AddLine(text, "", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
end

local function addLineTitle(tooltip, text, color)
    if not color then color = ZO_SELECTED_TEXT end
    local r, g, b = color:UnpackRGB()
    tooltip:AddLine(text, "ZoFontHeader3", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

function LeoGuildManagerUI.TooltipSales(control, visible)

    if visible then
        if not parent then parent = control end

        local name = control:GetParent().data.name
        if LeoGuildManager.HasIntegrationAddonsLoaded() then
            local cycle = LeoGuildManager.cycleMM
            if LeoGuildManager.globalData.settings.integration == "Arkadiu's Trade Tools" then
                cycle = LeoGuildManager.cycleATT
            end

            InitializeTooltip(InformationTooltip, control, LEFT, 5, 0)
            addLineTitle(InformationTooltip, "Sales")
            for _, cycleData in pairs(cycle) do
                local cycleId = cycleData.id
                local start, finish = getStartFinishFromCycle(cycleId)

                if start ~= nil and finish ~= nil then
                    local _, sale = getSalesData(name, cycleId, start, finish)
                    if sale ~= nil and sale > 0 then
                        addLine(InformationTooltip, cycleData.name .. ": |c"..LeoGuildManager.color.hex.white.. LeoGuildManager.formatNumber(sale).."|r")
                    end
                end
            end
            InformationTooltip:SetHidden(false)
            InformationTooltipTopLevel:BringWindowToTop()
        end

    else
        ClearTooltip(InformationTooltip)
        InformationTooltip:SetHidden(true)
    end
end

function LeoGuildManagerUI.TooltipDeposits(control, visible)

    if visible then
        if not parent then parent = control end

        local guildName = LeoGuildManager.globalData.selectedGuild
        local guildId = LeoGuildManager.GetGuildId(guildName)
        local name = control:GetParent().data.name
        if LeoGuildManager.CanScanBankHistory(guildId) then
            InitializeTooltip(InformationTooltip, control, LEFT, 5, 0)
            addLineTitle(InformationTooltip, "Deposits")
            local member = LeoGuildManager.GetGuildMember(name)
            for _, deposit in pairs(member.depositEvents) do
                addLine(InformationTooltip, LeoGuildManager.TimeAgo(deposit.timestamp) .. ": |c"..LeoGuildManager.color.hex.white.. LeoGuildManager.formatNumber(deposit.value).."|r")
            end
            InformationTooltip:SetHidden(false)
            InformationTooltipTopLevel:BringWindowToTop()
        end

    else
        ClearTooltip(InformationTooltip)
        InformationTooltip:SetHidden(true)
    end
end

ZO_CreateStringId('SI_BINDING_NAME_LEOGM_TOGGLE_WINDOW', "Show/Hide Main Window")

local keystripDef = {
    name = function() return "Register as Raffle" end,
    keybind = "AR_CRAFT",
    callback = function() PressCraft() end,
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    visible = function() return IsShowingRefinement() end,
}
