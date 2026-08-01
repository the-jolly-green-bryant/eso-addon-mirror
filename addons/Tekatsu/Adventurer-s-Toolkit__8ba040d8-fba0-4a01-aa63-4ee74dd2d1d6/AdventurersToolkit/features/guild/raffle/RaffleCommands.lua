-- ============================================
-- RAFFLE COMMAND ROUTING
-- ============================================
-- Command implementations extracted from RaffleDashboard.lua.

local DEMO_MEMBERS = NWT.RaffleConstants_DEMO_MEMBERS or {}
local DEMO_RANKS = NWT.RaffleConstants_DEMO_RANKS or {}

local GetDefaultRaffleSettings = NWT.RaffleData_GetDefaultSettings
local GetRaffleGuildSettings = NWT.RaffleData_GetGuildSettings
local GetRafflePeriodTimes = NWT.RaffleData_GetPeriodTimes
local FormatRafflePeriod = NWT.RaffleData_FormatPeriod
local IsMemberExcluded = NWT.RaffleData_IsMemberExcluded
local ToggleRaffleGuildFavorite = NWT.RaffleData_ToggleGuildFavorite
local CalculateTicketsFromDeposit = NWT.RaffleData_CalculateTicketsFromDeposit
local IsDoubleTicketDeposit = NWT.RaffleData_IsDoubleTicketDeposit
local GetRankBonus = NWT.RaffleData_GetRankBonus
local GetActivityBonusTickets = NWT.RaffleData_GetActivityBonusTickets
local GetDemoRankBonus = NWT.RaffleData_GetDemoRankBonus
local GetDemoActivityBonuses = NWT.RaffleData_GetDemoActivityBonuses
local CalculatePrizeDistribution = NWT.RaffleData_CalculatePrizeDistribution
local RecordWinner = NWT.RaffleData_RecordWinner
local UpdateJackpot = NWT.RaffleData_UpdateJackpot
local GetRafflePeriodPresets = NWT.RaffleData_GetPeriodPresets

local SETTINGS_TABS = {
    { id = "tickets", label = "TICKETS" },
    { id = "packs", label = "PACKS" },
    { id = "ranks", label = "RANKS" },
    { id = "bonuses", label = "BONUSES" },
    { id = "prizes", label = "PRIZES" },
    { id = "rules", label = "RULES" },
    { id = "linked", label = "LINKED" },
}
local MULTIPLIER_OPTIONS = {1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 12.0, 15.0, 20.0}
local WINNER_OPTIONS = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
local PERCENTAGE_OPTIONS = {25, 50, 75, 100}

function NWT.RaffleCommands_BuildEntries(guildId)
    local rf = NWT.Raffle
    local gs
    if guildId == 0 then
        gs = GetRaffleGuildSettings(0)
    else
        gs = GetRaffleGuildSettings(guildId)
    end
    local startTime, endTime = GetRafflePeriodTimes(gs)

    rf.sortedEntries = {}
    local totalTickets = 0
    local totalGold = 0

    local guildsToProcess = { { guildId = guildId, gs = gs } }
    if gs.linkedGuilds then
        for linkedGuildId, isLinked in pairs(gs.linkedGuilds) do
            if isLinked and linkedGuildId ~= guildId then
                local linkedGs = GetRaffleGuildSettings(linkedGuildId)
                table.insert(guildsToProcess, { guildId = linkedGuildId, gs = linkedGs })
            end
        end
    end

    local combinedEntries = {}
    for _, guildData in ipairs(guildsToProcess) do
        local processGuildId = guildData.guildId
        local processGs = guildData.gs
        local guildName = processGuildId > 0 and GetGuildName(processGuildId) or "Test Guild"

        for name, m in pairs(processGs.memberPayments or {}) do
            if m.isCurrentMember and m.deposits then
                if not IsMemberExcluded(processGuildId, name, processGs) then
                    local memberRaffle = 0
                    local depositCount = 0
                    local lastDeposit = 0
                    local ticketsFromDeposits = 0
                    local normalGold, doubleGold = 0, 0
                    local normalTickets, doubleTickets = 0, 0
                    local depositHistory = {}

                    for _, dep in ipairs(m.deposits) do
                        if dep.type == "raffle" and dep.timestamp >= startTime and dep.timestamp <= endTime then
                            memberRaffle = memberRaffle + dep.amount
                            depositCount = depositCount + 1
                            if dep.timestamp > lastDeposit then lastDeposit = dep.timestamp end

                            local depTickets = CalculateTicketsFromDeposit(dep.amount, processGs, dep.timestamp)
                            ticketsFromDeposits = ticketsFromDeposits + depTickets

                            local isDouble = IsDoubleTicketDeposit(dep.timestamp, processGs)
                            if isDouble then
                                doubleGold = doubleGold + dep.amount
                                doubleTickets = doubleTickets + depTickets
                            else
                                normalGold = normalGold + dep.amount
                                normalTickets = normalTickets + depTickets
                            end

                            table.insert(depositHistory, {
                                amount = dep.amount,
                                tickets = depTickets,
                                timestamp = dep.timestamp,
                                isDouble = isDouble,
                                guildName = guildName,
                            })
                        end
                    end

                    local freeTickets, multiplier, weeklyAllowance = GetRankBonus(processGuildId, name, processGs)
                    local weeksInPeriod = math.max(1, math.floor((endTime - startTime) / (7 * 86400)))
                    local weeklyAllowanceTickets = weeklyAllowance * weeksInPeriod
                    local rankBonusTickets = math.floor(ticketsFromDeposits * (multiplier - 1)) + freeTickets + weeklyAllowanceTickets
                    local activityBonusTickets = GetActivityBonusTickets(processGuildId, name, processGs)
                    local finalTickets = math.floor(ticketsFromDeposits * multiplier) + freeTickets + weeklyAllowanceTickets + activityBonusTickets

                    if finalTickets > 0 or memberRaffle > 0 then
                        if combinedEntries[name] then
                            local e = combinedEntries[name]
                            e.amount = e.amount + memberRaffle
                            e.tickets = e.tickets + finalTickets
                            e.baseTickets = e.baseTickets + ticketsFromDeposits
                            e.rankBonusTickets = e.rankBonusTickets + rankBonusTickets
                            e.activityBonusTickets = e.activityBonusTickets + activityBonusTickets
                            e.depositCount = e.depositCount + depositCount
                            e.normalGold = (e.normalGold or 0) + normalGold
                            e.doubleGold = (e.doubleGold or 0) + doubleGold
                            e.normalTickets = (e.normalTickets or 0) + normalTickets
                            e.doubleTickets = (e.doubleTickets or 0) + doubleTickets
                            e.freeTickets = (e.freeTickets or 0) + freeTickets
                            e.weeklyAllowanceTickets = (e.weeklyAllowanceTickets or 0) + weeklyAllowanceTickets
                            if lastDeposit > e.lastDeposit then e.lastDeposit = lastDeposit end
                            for _, dh in ipairs(depositHistory) do table.insert(e.depositHistory, dh) end
                            e.guildBreakdown[guildName] = {
                                gold = memberRaffle,
                                tickets = finalTickets,
                                baseTickets = ticketsFromDeposits,
                                rankBonus = rankBonusTickets,
                                activityBonus = activityBonusTickets,
                            }
                        else
                            combinedEntries[name] = {
                                name = name,
                                amount = memberRaffle,
                                tickets = finalTickets,
                                baseTickets = ticketsFromDeposits,
                                rankBonusTickets = rankBonusTickets,
                                activityBonusTickets = activityBonusTickets,
                                multiplier = multiplier,
                                depositCount = depositCount,
                                lastDeposit = lastDeposit,
                                normalGold = normalGold,
                                doubleGold = doubleGold,
                                normalTickets = normalTickets,
                                doubleTickets = doubleTickets,
                                freeTickets = freeTickets,
                                weeklyAllowanceTickets = weeklyAllowanceTickets,
                                depositHistory = depositHistory,
                                guildBreakdown = {
                                    [guildName] = {
                                        gold = memberRaffle,
                                        tickets = finalTickets,
                                        baseTickets = ticketsFromDeposits,
                                        rankBonus = rankBonusTickets,
                                        activityBonus = activityBonusTickets,
                                    }
                                },
                            }
                        end
                    end
                end
            end
        end
    end

    for _, entry in pairs(combinedEntries) do
        local finalTickets = entry.tickets
        if gs.entryRules and gs.entryRules.maxTickets > 0 then
            finalTickets = math.min(finalTickets, gs.entryRules.maxTickets)
        end
        local minTickets = (gs.entryRules and gs.entryRules.minTickets) or 0
        if finalTickets >= minTickets and finalTickets > 0 then
            entry.tickets = finalTickets
            table.insert(rf.sortedEntries, entry)
            totalTickets = totalTickets + finalTickets
            totalGold = totalGold + entry.amount
        end
    end

    if #rf.sortedEntries == 0 and guildId == 0 then
        local ticketPrice = gs.simpleTicketPrice or 1000
        for _, member in ipairs(DEMO_MEMBERS) do
            local baseTickets = math.floor(member.baseDeposit / ticketPrice)
            local freeTickets, multiplier, weeklyAllowance = GetDemoRankBonus(member, gs)
            local weeksInPeriod = math.max(1, math.floor((endTime - startTime) / (7 * 86400)))
            local weeklyAllowanceTickets = weeklyAllowance * weeksInPeriod
            local rankBonusTickets = math.floor(baseTickets * (multiplier - 1)) + freeTickets + weeklyAllowanceTickets
            local activityBonusTickets = GetDemoActivityBonuses(member, gs)
            local finalTickets = math.floor(baseTickets * multiplier) + freeTickets + weeklyAllowanceTickets + activityBonusTickets

            if gs.entryRules and gs.entryRules.maxTickets > 0 then
                finalTickets = math.min(finalTickets, gs.entryRules.maxTickets)
            end
            local minTickets = (gs.entryRules and gs.entryRules.minTickets) or 0

            local isOnCooldown = false
            if gs.entryRules and gs.entryRules.winnerCooldown > 0 and gs.pastWinners then
                local cooldownSeconds = gs.entryRules.winnerCooldown * 7 * 86400
                for _, w in ipairs(gs.pastWinners) do
                    if w.name == member.name and (GetTimeStamp() - w.timestamp) < cooldownSeconds then
                        isOnCooldown = true
                        break
                    end
                end
            end

            if finalTickets >= minTickets and finalTickets > 0 and not isOnCooldown then
                table.insert(rf.sortedEntries, {
                    name = member.name,
                    amount = member.baseDeposit,
                    tickets = finalTickets,
                    baseTickets = baseTickets,
                    rankBonusTickets = rankBonusTickets,
                    activityBonusTickets = activityBonusTickets,
                    multiplier = multiplier,
                    rankIndex = member.rankIndex,
                    rankName = DEMO_RANKS[member.rankIndex] or "Member",
                    depositCount = math.random(1, math.max(1, baseTickets)),
                    lastDeposit = GetTimeStamp() - math.random(0, 604800),
                })
                totalTickets = totalTickets + finalTickets
                totalGold = totalGold + member.baseDeposit
            end
        end
    end

    table.sort(rf.sortedEntries, function(a, b)
        if a.tickets ~= b.tickets then return a.tickets > b.tickets end
        return a.name < b.name
    end)

    rf.raffleEntriesCount = #rf.sortedEntries
    rf.totalTickets = totalTickets
    rf.totalGold = totalGold

    rf.guildStats = {}
    for _, entry in ipairs(rf.sortedEntries) do
        if entry.guildBreakdown then
            for guildName, data in pairs(entry.guildBreakdown) do
                if not rf.guildStats[guildName] then
                    rf.guildStats[guildName] = {
                        name = guildName,
                        participants = 0,
                        gold = 0,
                        tickets = 0,
                        baseTickets = 0,
                        rankBonus = 0,
                        activityBonus = 0,
                        doubleGold = 0,
                        doubleTickets = 0,
                    }
                end
                local gstats = rf.guildStats[guildName]
                gstats.participants = gstats.participants + 1
                gstats.gold = gstats.gold + (data.gold or 0)
                gstats.tickets = gstats.tickets + (data.tickets or 0)
                gstats.baseTickets = gstats.baseTickets + (data.baseTickets or 0)
                gstats.rankBonus = gstats.rankBonus + (data.rankBonus or 0)
                gstats.activityBonus = gstats.activityBonus + (data.activityBonus or 0)
            end
        end
        if entry.doubleGold and entry.doubleGold > 0 and entry.guildBreakdown then
            for guildName, _ in pairs(entry.guildBreakdown) do
                if rf.guildStats[guildName] then
                    rf.guildStats[guildName].doubleGold = rf.guildStats[guildName].doubleGold + (entry.doubleGold or 0)
                    rf.guildStats[guildName].doubleTickets = rf.guildStats[guildName].doubleTickets + (entry.doubleTickets or 0)
                end
                break
            end
        end
    end
end

function NWT.RaffleCommands_SwitchPanelCore(dir)
    local rf = NWT.Raffle
    if rf.settingsMenuOpen or rf.rafflePickerOpen then return end
    if dir == "right" then
        if rf.focusPanel == "guilds" then rf.focusPanel = "entries" end
    else
        if rf.focusPanel == "entries" then rf.focusPanel = "guilds" end
    end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateRaffleUI()
end

function NWT.RaffleCommands_ScrollGuildCore(dir)
    local rf = NWT.Raffle
    local nG = GetNumGuilds()
    if nG == 0 then return end
    if dir == "up" then
        rf.selectedGuildIndex = math.max(1, rf.selectedGuildIndex - 1)
    else
        rf.selectedGuildIndex = math.min(nG, rf.selectedGuildIndex + 1)
    end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateRaffleUI()
end

function NWT.RaffleCommands_ScrollEntriesCore(dir)
    local rf = NWT.Raffle
    local count = rf.raffleEntriesCount or 0
    if dir == "up" then
        if rf.selectedEntryIndex and rf.selectedEntryIndex > 1 then
            rf.selectedEntryIndex = rf.selectedEntryIndex - 1
            if rf.selectedEntryIndex <= rf.raffleScrollOffset then
                rf.raffleScrollOffset = math.max(0, rf.raffleScrollOffset - 1)
            end
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
    elseif dir == "down" then
        if rf.selectedEntryIndex and rf.selectedEntryIndex < count then
            rf.selectedEntryIndex = rf.selectedEntryIndex + 1
            if rf.selectedEntryIndex > rf.raffleScrollOffset + 12 then
                rf.raffleScrollOffset = math.min(math.max(0, count - 12), rf.raffleScrollOffset + 1)
            end
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        elseif not rf.selectedEntryIndex and count > 0 then
            rf.selectedEntryIndex = 1
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
    end
    NWT.UpdateRaffleUI()
end

function NWT.RaffleCommands_SelectGuildCore()
    local rf = NWT.Raffle
    if rf.sortedGuildList and rf.sortedGuildList[rf.selectedGuildIndex] then
        rf.viewingGuildIndex = rf.sortedGuildList[rf.selectedGuildIndex].index
    else
        rf.viewingGuildIndex = rf.selectedGuildIndex
    end
    rf.focusPanel = "entries"
    rf.raffleScrollOffset = 0
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateRaffleUI()
end

function NWT.RaffleCommands_FavoriteSelectedGuildCore()
    local rf = NWT.Raffle
    if not rf.sortedGuildList or not rf.sortedGuildList[rf.selectedGuildIndex] then return end
    local guildId = rf.sortedGuildList[rf.selectedGuildIndex].guildId
    if not guildId or guildId <= 0 then return end
    ToggleRaffleGuildFavorite(guildId)
    rf.sortedGuildList = nil
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateRaffleUI()
end

function NWT.RaffleCommands_ShowPickerCore()
    local rf = NWT.Raffle
    rf.rafflePickerOpen = true
    rf.raffleWinnerCount = 1
    NWT.UpdateRafflePickerDialog()
    if ATK_RafflePickerDialog then ATK_RafflePickerDialog:SetHidden(false) end
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor)
    end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.RaffleCommands_UpdatePickerDialogCore()
    local rf = NWT.Raffle
    local dialog = ATK_RafflePickerDialog
    if not dialog then return end
    local guildId = GetGuildId(rf.viewingGuildIndex)
    local gs = GetRaffleGuildSettings(guildId)
    local periodLabel = dialog:GetNamedChild("Period")
    local statsLabel = dialog:GetNamedChild("Stats")
    local countLabel = dialog:GetNamedChild("WinnerCount")
    if periodLabel then periodLabel:SetText(string.format("|cFFFFAAPeriod:|r %s", FormatRafflePeriod(gs))) end
    if statsLabel then statsLabel:SetText(string.format("|c00FFFF%d participants|r  |cFFFF00%d tickets|r", rf.raffleEntriesCount or 0, rf.totalTickets or 0)) end
    if countLabel then countLabel:SetText(string.format("|cFFFFFF# Winners:|r |cFFD700◄ %d ►|r", rf.raffleWinnerCount or 1)) end
end

function NWT.RaffleCommands_AdjustWinnerCountCore(dir)
    local rf = NWT.Raffle
    if not rf.rafflePickerOpen then return end
    if dir == "up" or dir == "right" then
        rf.raffleWinnerCount = math.min(10, (rf.raffleWinnerCount or 1) + 1)
    else
        rf.raffleWinnerCount = math.max(1, (rf.raffleWinnerCount or 1) - 1)
    end
    NWT.UpdateRafflePickerDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.RaffleCommands_RunPickerCore()
    local rf = NWT.Raffle
    local guildId = GetGuildId(rf.viewingGuildIndex)
    local gs
    if guildId == 0 then
        gs = GetDefaultRaffleSettings()
    else
        gs = GetRaffleGuildSettings(guildId)
    end

    NWT.BuildRaffleEntries(guildId)
    local pool = {}
    local totalTickets = 0
    for _, entry in ipairs(rf.sortedEntries) do
        table.insert(pool, { name = entry.name, tickets = entry.tickets, amount = entry.amount })
        totalTickets = totalTickets + entry.tickets
    end
    if #pool == 0 then
        NWT.Debug("|cFFFF00[Raffle]|r No entries for this period!")
        return
    end

    local pc = gs.prizeConfig or {}
    local configuredWinners = pc.numWinners or 1
    local winnerCount = math.min(rf.raffleWinnerCount or configuredWinners, #pool)
    local prizes, prizePool = CalculatePrizeDistribution(rf.totalGold, gs)

    local winners = {}
    local poolCopy = {}
    for i, v in ipairs(pool) do poolCopy[i] = { name = v.name, tickets = v.tickets, amount = v.amount } end
    local tempTotalTickets = totalTickets

    for w = 1, winnerCount do
        if tempTotalTickets <= 0 or #poolCopy == 0 then break end
        local winningTicket = math.random(1, tempTotalTickets)
        local runningTotal = 0
        for i, entry in ipairs(poolCopy) do
            runningTotal = runningTotal + entry.tickets
            if winningTicket <= runningTotal then
                local prize = prizes[w] or 0
                table.insert(winners, { name = entry.name, tickets = entry.tickets, place = w, prize = prize })
                if guildId > 0 then RecordWinner(gs, entry.name) end
                tempTotalTickets = tempTotalTickets - entry.tickets
                table.remove(poolCopy, i)
                break
            end
        end
    end

    local jackpotWon = 0
    if #winners > 0 and guildId > 0 then
        jackpotWon = UpdateJackpot(gs, true, rf.totalGold)
        if jackpotWon > 0 then
            winners[1].prize = (winners[1].prize or 0) + jackpotWon
            winners[1].jackpotWon = jackpotWon
        end
    end

    rf.raffleWinners = winners
    rf.raffleEntryCount = #pool
    rf.rafflePrizePool = prizePool

    if ATK_RafflePickerDialog then ATK_RafflePickerDialog:SetHidden(true) end
    if ATK_RaffleWinnerDialog then
        ATK_RaffleWinnerDialog:SetHidden(false)
        local winnerLabel = ATK_RaffleWinnerDialog:GetNamedChild("WinnerName")
        local statsLabel = ATK_RaffleWinnerDialog:GetNamedChild("Stats")
        statsLabel:SetText("|c888888Drawing winners...|r")

        local rollCount = 0
        local maxRolls = 20
        EVENT_MANAGER:RegisterForUpdate("ATK_Raffle_Rolling", 100, function()
            rollCount = rollCount + 1
            if rollCount < maxRolls then
                local randomIdx = math.random(1, #pool)
                winnerLabel:SetText("|c888888" .. pool[randomIdx].name:gsub("^@", "") .. "|r")
                PlaySound(SOUNDS.ROLL_DICE)
            else
                EVENT_MANAGER:UnregisterForUpdate("ATK_Raffle_Rolling")
                NWT.ShowRaffleWinnerDialog()
            end
        end)
    end
end

function NWT.RaffleCommands_ShowWinnerDialogCore()
    local rf = NWT.Raffle
    local dialog = ATK_RaffleWinnerDialog
    if not dialog then return end
    local winners = rf.raffleWinners
    if not winners or #winners == 0 then return end

    local winnerText = ""
    for i, w in ipairs(winners) do
        local displayName = w.name:gsub("^@", "")
        local prizeText = ""
        if w.prize and w.prize > 0 then
            prizeText = " - |c00FF00" .. NWT.FormatGold(w.prize) .. "g|r"
            if w.jackpotWon and w.jackpotWon > 0 then
                prizeText = prizeText .. " |cFF00FF(+JACKPOT!)|r"
            end
        end
        if i == 1 then
            winnerText = string.format("|cFFD700#%d: %s|r (%d tickets)%s", i, displayName, w.tickets, prizeText)
        else
            winnerText = winnerText .. string.format("\n|cFFFFAA#%d: %s|r (%d tickets)%s", i, displayName, w.tickets, prizeText)
        end
    end

    local nameLabel = dialog:GetNamedChild("WinnerName")
    local statsLabel = dialog:GetNamedChild("Stats")
    if nameLabel then nameLabel:SetText(winnerText) end
    if statsLabel then
        statsLabel:SetText(string.format("|c888888%d participants  •  Prize Pool: %sg|r", rf.raffleEntryCount or 0, NWT.FormatGold(rf.rafflePrizePool or 0)))
    end

    rf.raffleWinnerDialogOpen = true
    dialog:SetHidden(false)
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor)
    end
    PlaySound(SOUNDS.TELVAR_GAINED)
end

function NWT.RaffleCommands_CloseWinnerDialogCore()
    if ATK_RaffleWinnerDialog then ATK_RaffleWinnerDialog:SetHidden(true) end
    NWT.Raffle.raffleWinnerDialogOpen = nil
    NWT.Raffle.raffleWinners = nil
    NWT.Raffle.rafflePickerOpen = false
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor)
    end
end

function NWT.RaffleCommands_RerollCore()
    NWT.CloseRaffleWinnerDialog()
    NWT.RaffleShowPicker()
end

function NWT.RaffleCommands_ShowParticipantDetailsCore()
    local rf = NWT.Raffle
    if rf.focusPanel ~= "entries" then return end
    local entryIdx = rf.selectedEntryIndex or 1
    local entry = rf.sortedEntries[entryIdx]
    if not entry then return end

    local dialog = ATK_ParticipantDetailsDialog
    if not dialog then return end
    local displayName = entry.name:gsub("^@", "")
    local title = dialog:GetNamedChild("Title")
    if title then title:SetText("|cFFD700" .. displayName .. "|r") end

    local function SetRow(num, text)
        local row = dialog:GetNamedChild("Row" .. num)
        if row then row:SetText(text) end
    end

    local rowNum = 1
    SetRow(rowNum, string.format("|cFFFFAAFinal Tickets:|r  |cFFFF00%d|r", entry.tickets)) rowNum = rowNum + 1
    SetRow(rowNum, string.format("|cFFFFAATotal Deposited:|r  |c00FF00%sg|r", NWT.FormatGold(entry.amount or 0))) rowNum = rowNum + 1

    local normalGold = entry.normalGold or entry.amount or 0
    local normalTickets = entry.normalTickets or entry.baseTickets or 0
    SetRow(rowNum, string.format("|cFFFFAANormal:|r  %sg → |cFFFFFF%d tickets|r", NWT.FormatGold(normalGold), normalTickets)) rowNum = rowNum + 1

    local doubleGold = entry.doubleGold or 0
    local doubleTickets = entry.doubleTickets or 0
    if doubleGold > 0 or doubleTickets > 0 then
        SetRow(rowNum, string.format("|cFFFFAADouble Tickets:|r  %sg → |c00FF00%d tickets|r", NWT.FormatGold(doubleGold), doubleTickets))
    else
        SetRow(rowNum, "|cFFFFAADouble Tickets:|r  |c888888None|r")
    end
    rowNum = rowNum + 1

    local freeTickets = entry.freeTickets or 0
    local weeklyTickets = entry.weeklyAllowanceTickets or 0
    local totalFree = freeTickets + weeklyTickets
    if totalFree > 0 then
        SetRow(rowNum, string.format("|cFFFFAAFree Tickets:|r  |c00FF00+%d|r  (rank bonus)", totalFree))
    else
        SetRow(rowNum, "|cFFFFAAFree Tickets:|r  |c888888None|r")
    end
    rowNum = rowNum + 1

    local multiplier = entry.multiplier or 1.0
    if multiplier > 1.0 then
        SetRow(rowNum, string.format("|cFFFFAARank Multiplier:|r  |c00FF00%.2fx|r", multiplier))
    else
        SetRow(rowNum, "|cFFFFAARank Multiplier:|r  |c888888None|r")
    end
    rowNum = rowNum + 1

    local activityBonus = entry.activityBonusTickets or 0
    if activityBonus > 0 then
        SetRow(rowNum, string.format("|cFFFFAAActivity Bonus:|r  |c00FF00+%d|r", activityBonus))
    else
        SetRow(rowNum, "|cFFFFAAActivity Bonus:|r  |c888888None|r")
    end
    rowNum = rowNum + 1

    local row8 = dialog:GetNamedChild("Row" .. rowNum)
    if row8 then row8:SetText("|cFFD700--- Deposit History ---|r") rowNum = rowNum + 1 end

    local depositHistory = entry.depositHistory or {}
    if #depositHistory > 0 then
        table.sort(depositHistory, function(a, b) return a.timestamp > b.timestamp end)
        local maxDeposits = math.min(4, #depositHistory)
        for i = 1, maxDeposits do
            local dep = depositHistory[i]
            local row = dialog:GetNamedChild("Row" .. rowNum)
            if dep and row then
                local dateStr = os.date("%m/%d %H:%M", dep.timestamp)
                local doubleTag = dep.isDouble and " |cFF00FF(2x)|r" or ""
                local guildTag = dep.guildName and (" |c888888[" .. dep.guildName:sub(1, 8) .. "]|r") or ""
                row:SetText(string.format("  |c888888%s|r  %sg → %d tix%s%s", dateStr, NWT.FormatGold(dep.amount), dep.tickets, doubleTag, guildTag))
                rowNum = rowNum + 1
            end
        end
    end
    for i = rowNum, 12 do
        local row = dialog:GetNamedChild("Row" .. i)
        if row then row:SetText("") end
    end

    rf.participantDetailsOpen = true
    dialog:SetHidden(false)
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor)
    end
end

function NWT.RaffleCommands_CloseParticipantDetailsCore()
    if ATK_ParticipantDetailsDialog then ATK_ParticipantDetailsDialog:SetHidden(true) end
    NWT.Raffle.participantDetailsOpen = nil
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor)
    end
end

function NWT.RaffleCommands_ShowSettingsCore()
    local rf = NWT.Raffle
    if rf.settingsMenuOpen then return end
    rf.settingsMenuOpen = true
    rf.settingsTabIndex = 1
    rf.settingsRowIndex = 1
    rf.settingsScrollOffset = 0
    rf.settingsGuildId = GetGuildId(rf.viewingGuildIndex)
    if rf.settingsGuildId == 0 then rf.settingsGuildId = 0 end
    NWT.UpdateRaffleSettingsDialog()
    if ATK_RaffleSettingsDialog then ATK_RaffleSettingsDialog:SetHidden(false) end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor)
    end
end

function NWT.RaffleCommands_SettingsChangeTabCore(dir)
    local rf = NWT.Raffle
    if not rf.settingsMenuOpen then return end
    if dir == "left" then
        rf.settingsTabIndex = rf.settingsTabIndex > 1 and rf.settingsTabIndex - 1 or #SETTINGS_TABS
    else
        rf.settingsTabIndex = rf.settingsTabIndex < #SETTINGS_TABS and rf.settingsTabIndex + 1 or 1
    end
    rf.settingsRowIndex = 1
    rf.settingsScrollOffset = 0
    NWT.UpdateRaffleSettingsDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.RaffleCommands_CycleSettingsOptionCore(dir)
    local rf = NWT.Raffle
    if not rf.settingsMenuOpen then return end
    local settings = rf.currentTabSettings or {}
    local numSettings = #settings
    if numSettings == 0 then return end
    local maxVisible = 10
    rf.settingsScrollOffset = rf.settingsScrollOffset or 0
    if dir == "up" then
        if rf.settingsRowIndex > 1 then
            rf.settingsRowIndex = rf.settingsRowIndex - 1
            if rf.settingsRowIndex <= rf.settingsScrollOffset then
                rf.settingsScrollOffset = rf.settingsRowIndex - 1
            end
        else
            rf.settingsRowIndex = numSettings
            rf.settingsScrollOffset = math.max(0, numSettings - maxVisible)
        end
    else
        if rf.settingsRowIndex < numSettings then
            rf.settingsRowIndex = rf.settingsRowIndex + 1
            if rf.settingsRowIndex > rf.settingsScrollOffset + maxVisible then
                rf.settingsScrollOffset = rf.settingsRowIndex - maxVisible
            end
        else
            rf.settingsRowIndex = 1
            rf.settingsScrollOffset = 0
        end
    end
    NWT.UpdateRaffleSettingsDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.RaffleCommands_ChangeSettingValueCore(direction)
    local rf = NWT.Raffle
    if not rf.settingsMenuOpen then return end
    direction = direction or 1
    local gs = GetRaffleGuildSettings(rf.settingsGuildId)
    local settings = rf.currentTabSettings or {}
    local setting = settings[rf.settingsRowIndex]
    if not setting then return end
    local currentTab = SETTINGS_TABS[rf.settingsTabIndex]
    if setting.type == "toggle" then
        NWT.RaffleToggleSetting(gs, setting.id, currentTab.id)
    elseif setting.type == "cycle" then
        NWT.RaffleCycleSetting(gs, setting.id, currentTab.id, setting.options, direction)
    elseif setting.type == "number" then
        NWT.RaffleIncrementSetting(gs, setting.id, currentTab.id, direction)
    elseif setting.type == "action" then
        NWT.RaffleDoAction(gs, setting.id, currentTab.id)
    elseif setting.type == "pack_price" then
        NWT.RaffleEditPackPrice(gs, setting.packIndex, direction)
    elseif setting.type == "pack_tickets" then
        NWT.RaffleEditPackTickets(gs, setting.packIndex, direction)
    elseif setting.type == "pack_suffix" then
        NWT.RaffleEditPackSuffix(gs, setting.packIndex, direction)
    elseif setting.type == "rank_free" then
        NWT.RaffleEditRankFree(gs, setting.rankIndex, direction)
    elseif setting.type == "rank_mult" then
        NWT.RaffleEditRankMult(gs, setting.rankIndex, direction)
    elseif setting.type == "rank_weekly" then
        NWT.RaffleEditRankWeekly(gs, setting.rankIndex, direction)
    elseif setting.type == "rank_exempt" then
        NWT.RaffleToggleRankExempt(gs, setting.rankIndex)
    end
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateRaffleSettingsDialog()
    NWT.UpdateRaffleUI()
end

function NWT.RaffleCommands_ToggleSettingCore(gs, settingId, tabId)
    if settingId == "useTicketPacks" then
        gs.useTicketPacks = not gs.useTicketPacks
    elseif settingId == "rankBonusEnabled" then
        if not gs.rankBonuses then gs.rankBonuses = { enabled = false, ranks = {} } end
        gs.rankBonuses.enabled = not gs.rankBonuses.enabled
    elseif settingId == "activityEnabled" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        gs.activityBonuses.enabled = not gs.activityBonuses.enabled
    elseif settingId == "progressiveJackpot" then
        if not gs.prizeConfig then gs.prizeConfig = {} end
        gs.prizeConfig.progressiveJackpot = not gs.prizeConfig.progressiveJackpot
    elseif settingId == "mustBeOnline" then
        if not gs.entryRules then gs.entryRules = {} end
        gs.entryRules.mustBeOnline = not gs.entryRules.mustBeOnline
    elseif settingId == "traderSalesBonus" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        gs.activityBonuses.traderSalesBonus = not gs.activityBonuses.traderSalesBonus
    elseif string.find(settingId, "^linkGuild_") then
        local linkedGuildId = tonumber(string.match(settingId, "linkGuild_(%d+)"))
        if linkedGuildId then
            if not gs.linkedGuilds then gs.linkedGuilds = {} end
            gs.linkedGuilds[linkedGuildId] = not gs.linkedGuilds[linkedGuildId]
        end
    end
end

function NWT.RaffleCommands_CycleSettingCore(gs, settingId, tabId, options)
    if settingId == "raffleSuffix" then
        local cur = (gs.raffleSuffixes and gs.raffleSuffixes[1]) or 1
        gs.raffleSuffixes = { (cur % 10) }
    elseif settingId == "rafflePeriod" then
        local presets = GetRafflePeriodPresets()
        local curId = gs.rafflePeriodId or "all"
        local curIdx = 1
        for i, p in ipairs(presets) do if p.id == curId then curIdx = i break end end
        gs.rafflePeriodId = presets[(curIdx % #presets) + 1].id
    elseif settingId == "numWinners" then
        if not gs.prizeConfig then gs.prizeConfig = {} end
        local cur = gs.prizeConfig.numWinners or 1
        local nextIdx = 1
        for i, v in ipairs(WINNER_OPTIONS) do if cur == v then nextIdx = (i % #WINNER_OPTIONS) + 1 break end end
        gs.prizeConfig.numWinners = WINNER_OPTIONS[nextIdx]
    elseif settingId == "poolPercentage" then
        if not gs.prizeConfig then gs.prizeConfig = {} end
        local cur = gs.prizeConfig.poolPercentage or 100
        local nextIdx = 1
        for i, v in ipairs(PERCENTAGE_OPTIONS) do if cur == v then nextIdx = (i % #PERCENTAGE_OPTIONS) + 1 break end end
        gs.prizeConfig.poolPercentage = PERCENTAGE_OPTIONS[nextIdx]
    elseif settingId == "distribution" then
        if not gs.prizeConfig then gs.prizeConfig = {} end
        local opts = {"equal", "tiered", "custom"}
        local cur = gs.prizeConfig.distribution or "equal"
        local curIdx = 1
        for i, v in ipairs(opts) do if cur == v then curIdx = i break end end
        gs.prizeConfig.distribution = opts[(curIdx % #opts) + 1]
    elseif settingId == "raffleType" then
        local opts = {"gold", "5050"}
        local cur = gs.raffleType or "gold"
        local curIdx = 1
        for i, v in ipairs(opts) do if cur == v then curIdx = i break end end
        gs.raffleType = opts[(curIdx % #opts) + 1]
    elseif settingId == "traderSalesPer" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        local opts = {10000, 25000, 50000, 100000, 250000, 500000}
        local cur = gs.activityBonuses.traderSalesPer or 100000
        local curIdx = 1
        for i, v in ipairs(opts) do if cur == v then curIdx = i break end end
        gs.activityBonuses.traderSalesPer = opts[(curIdx % #opts) + 1]
    end
end

function NWT.RaffleCommands_IncrementSettingCore(gs, settingId, tabId, direction)
    direction = direction or 1
    if settingId == "maxTickets" then
        if not gs.entryRules then gs.entryRules = {} end
        local cur = (gs.entryRules.maxTickets or 0) + (10 * direction)
        if cur > 100 then cur = 0 elseif cur < 0 then cur = 100 end
        gs.entryRules.maxTickets = cur
    elseif settingId == "minTickets" then
        if not gs.entryRules then gs.entryRules = {} end
        local cur = (gs.entryRules.minTickets or 0) + direction
        if cur > 10 then cur = 0 elseif cur < 0 then cur = 10 end
        gs.entryRules.minTickets = cur
    elseif settingId == "winnerCooldown" then
        if not gs.entryRules then gs.entryRules = {} end
        local cur = (gs.entryRules.winnerCooldown or 0) + direction
        if cur > 4 then cur = 0 elseif cur < 0 then cur = 4 end
        gs.entryRules.winnerCooldown = cur
    elseif settingId == "onlineThresholdDays" then
        if not gs.entryRules then gs.entryRules = {} end
        local opts = {7, 14, 30, 60, 90}
        local cur = gs.entryRules.onlineThresholdDays or 7
        local curIdx = 1
        for i, v in ipairs(opts) do if cur == v then curIdx = i break end end
        curIdx = curIdx + direction
        if curIdx > #opts then curIdx = 1 elseif curIdx < 1 then curIdx = #opts end
        gs.entryRules.onlineThresholdDays = opts[curIdx]
    elseif settingId == "recruitmentBonus" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        local cur = (gs.activityBonuses.recruitmentBonus or 0) + direction
        if cur > 20 then cur = 0 elseif cur < 0 then cur = 20 end
        gs.activityBonuses.recruitmentBonus = cur
    elseif settingId == "newMemberBonus" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        local cur = (gs.activityBonuses.newMemberBonus or 0) + direction
        if cur > 20 then cur = 0 elseif cur < 0 then cur = 20 end
        gs.activityBonuses.newMemberBonus = cur
    elseif settingId == "longevityBonus" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        local cur = (gs.activityBonuses.longevityBonus or 0) + direction
        if cur > 10 then cur = 0 elseif cur < 0 then cur = 10 end
        gs.activityBonuses.longevityBonus = cur
    elseif settingId == "simpleTicketPrice" then
        local cur = (gs.simpleTicketPrice or 1000) + (500 * direction)
        if cur > 100000 then cur = 500 elseif cur < 500 then cur = 100000 end
        gs.simpleTicketPrice = cur
    elseif settingId == "doubleTicketDuration" then
        local cur = (gs.doubleTicketDuration or 30) + (5 * direction)
        if cur > 120 then cur = 5 elseif cur < 5 then cur = 120 end
        gs.doubleTicketDuration = cur
    elseif settingId == "jackpotAmount" then
        if not gs.prizeConfig then gs.prizeConfig = {} end
        local cur = (gs.prizeConfig.jackpotAmount or 0) + (50000 * direction)
        if cur < 0 then cur = 0 end
        if cur > 50000000 then cur = 50000000 end
        gs.prizeConfig.jackpotAmount = cur
    elseif settingId == "customStartMonth" then
        local cur = (gs.customStartMonth or 1) + direction
        if cur > 12 then cur = 1 elseif cur < 1 then cur = 12 end
        gs.customStartMonth = cur
    elseif settingId == "customStartDay" then
        local cur = (gs.customStartDay or 1) + direction
        if cur > 31 then cur = 1 elseif cur < 1 then cur = 31 end
        gs.customStartDay = cur
    elseif settingId == "customEndMonth" then
        local cur = (gs.customEndMonth or 12) + direction
        if cur > 12 then cur = 1 elseif cur < 1 then cur = 12 end
        gs.customEndMonth = cur
    elseif settingId == "customEndDay" then
        local cur = (gs.customEndDay or 31) + direction
        if cur > 31 then cur = 1 elseif cur < 1 then cur = 31 end
        gs.customEndDay = cur
    end
end

function NWT.RaffleCommands_DoActionCore(gs, actionId, tabId)
    if actionId == "addPack" then
        if not gs.ticketPacks then gs.ticketPacks = {} end
        local suffix = #gs.ticketPacks + 1
        if suffix > 9 then suffix = 1 end
        table.insert(gs.ticketPacks, { price = 1001, tickets = 1, suffix = suffix })
    elseif actionId == "removePack" then
        if gs.ticketPacks and #gs.ticketPacks > 0 then table.remove(gs.ticketPacks) end
    elseif actionId == "startDoubleTickets" then
        local isActive = gs.doubleTicketEndTime and gs.doubleTicketEndTime > GetTimeStamp()
        if isActive then
            gs.doubleTicketEndTime = GetTimeStamp()
            PlaySound(SOUNDS.NEGATIVE_CLICK)
        else
            local duration = (gs.doubleTicketDuration or 30) * 60
            gs.doubleTicketStartTime = GetTimeStamp()
            gs.doubleTicketEndTime = GetTimeStamp() + duration
            PlaySound(SOUNDS.TELVAR_GAINED)
        end
    elseif actionId == "applyCustomDates" then
        local currentYear = tonumber(os.date("%Y"))
        local startMonth, startDay = gs.customStartMonth or 1, gs.customStartDay or 1
        local endMonth, endDay = gs.customEndMonth or 12, gs.customEndDay or 31
        local success1, startTs = pcall(os.time, { year = currentYear, month = startMonth, day = startDay, hour = 0, min = 0, sec = 0 })
        local success2, endTs = pcall(os.time, { year = currentYear, month = endMonth, day = endDay, hour = 23, min = 59, sec = 59 })
        if success1 and success2 and startTs and endTs then
            gs.customRaffleStart = startTs
            gs.customRaffleEnd = endTs
            PlaySound(SOUNDS.POSITIVE_CLICK)
        else
            PlaySound(SOUNDS.NEGATIVE_CLICK)
        end
    end
end

function NWT.RaffleCommands_EditPackPriceCore(gs, packIndex)
    local pack = gs.ticketPacks and gs.ticketPacks[packIndex]
    if not pack then return end
    local priceOpts = {500, 1000, 2000, 3000, 5000, 10000, 15000, 20000, 25000, 50000}
    local curIdx = 1
    for i, v in ipairs(priceOpts) do
        if pack.price >= v and pack.price < (priceOpts[i + 1] or 999999) then curIdx = i break end
    end
    local basePrice = priceOpts[(curIdx % #priceOpts) + 1]
    pack.price = basePrice + pack.suffix
end

function NWT.RaffleCommands_EditPackTicketsCore(gs, packIndex)
    local pack = gs.ticketPacks and gs.ticketPacks[packIndex]
    if not pack then return end
    local ticketOpts = {1, 2, 3, 5, 10, 15, 20, 25, 50}
    local curIdx = 1
    for i, v in ipairs(ticketOpts) do if pack.tickets == v then curIdx = i break end end
    pack.tickets = ticketOpts[(curIdx % #ticketOpts) + 1]
end

function NWT.RaffleCommands_EditPackSuffixCore(gs, packIndex)
    local pack = gs.ticketPacks and gs.ticketPacks[packIndex]
    if not pack then return end
    pack.suffix = (pack.suffix + 1) % 10
    local basePrice = math.floor(pack.price / 10) * 10
    pack.price = basePrice + pack.suffix
end

local function CleanupRankBonus(gs, rankIndex)
    if not gs.rankBonuses or not gs.rankBonuses.ranks then return end
    local rb = gs.rankBonuses.ranks[rankIndex]
    if rb and rb.freeTickets == 0 and rb.multiplier == 1.0 and (rb.weeklyAllowance or 0) == 0 then
        gs.rankBonuses.ranks[rankIndex] = nil
    end
end

function NWT.RaffleCommands_EditRankFreeCore(gs, rankIndex)
    if not gs.rankBonuses then gs.rankBonuses = { enabled = false, ranks = {} } end
    if not gs.rankBonuses.ranks then gs.rankBonuses.ranks = {} end
    if not gs.rankBonuses.ranks[rankIndex] then
        gs.rankBonuses.ranks[rankIndex] = { freeTickets = 0, multiplier = 1.0, weeklyAllowance = 0 }
    end
    local rb = gs.rankBonuses.ranks[rankIndex]
    local freeOpts = {0, 1, 2, 3, 5, 10, 15, 20, 25, 50}
    local curIdx = 1
    for i, v in ipairs(freeOpts) do if rb.freeTickets == v then curIdx = i break end end
    rb.freeTickets = freeOpts[(curIdx % #freeOpts) + 1]
    CleanupRankBonus(gs, rankIndex)
end

function NWT.RaffleCommands_EditRankMultCore(gs, rankIndex, direction)
    if not gs.rankBonuses then gs.rankBonuses = { enabled = false, ranks = {} } end
    if not gs.rankBonuses.ranks then gs.rankBonuses.ranks = {} end
    if not gs.rankBonuses.ranks[rankIndex] then
        gs.rankBonuses.ranks[rankIndex] = { freeTickets = 0, multiplier = 1.0, weeklyAllowance = 0 }
    end
    local rb = gs.rankBonuses.ranks[rankIndex]
    local curIdx = 1
    for i, v in ipairs(MULTIPLIER_OPTIONS) do if rb.multiplier == v then curIdx = i break end end
    if direction == -1 then
        curIdx = curIdx - 1
        if curIdx < 1 then curIdx = #MULTIPLIER_OPTIONS end
    else
        curIdx = curIdx + 1
        if curIdx > #MULTIPLIER_OPTIONS then curIdx = 1 end
    end
    rb.multiplier = MULTIPLIER_OPTIONS[curIdx]
    CleanupRankBonus(gs, rankIndex)
end

function NWT.RaffleCommands_EditRankWeeklyCore(gs, rankIndex)
    if not gs.rankBonuses then gs.rankBonuses = { enabled = false, ranks = {} } end
    if not gs.rankBonuses.ranks then gs.rankBonuses.ranks = {} end
    if not gs.rankBonuses.ranks[rankIndex] then
        gs.rankBonuses.ranks[rankIndex] = { freeTickets = 0, multiplier = 1.0, weeklyAllowance = 0 }
    end
    local rb = gs.rankBonuses.ranks[rankIndex]
    local weeklyOpts = {0, 10, 25, 50, 100, 150, 200, 250, 300, 500}
    local curIdx = 1
    for i, v in ipairs(weeklyOpts) do if rb.weeklyAllowance == v then curIdx = i break end end
    rb.weeklyAllowance = weeklyOpts[(curIdx % #weeklyOpts) + 1]
    CleanupRankBonus(gs, rankIndex)
end

function NWT.RaffleCommands_ToggleRankExemptCore(gs, rankIndex)
    if not gs.raffleExemptRanks then gs.raffleExemptRanks = {} end
    gs.raffleExemptRanks[rankIndex] = not gs.raffleExemptRanks[rankIndex]
end

function NWT.RaffleCommands_CloseSettingsCore()
    local rf = NWT.Raffle
    rf.settingsMenuOpen = false
    rf.settingsGuildId = nil
    rf.settingsTabIndex = 1
    rf.settingsRowIndex = 1
    rf.currentTabSettings = nil
    if ATK_RaffleSettingsDialog then ATK_RaffleSettingsDialog:SetHidden(true) end
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor)
    end
end
