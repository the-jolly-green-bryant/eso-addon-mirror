-- ============================================
-- GOLD LEDGER DASHBOARD (Separate Scene)
-- ============================================

-- Gold Ledger List Screen for d-pad navigation - must be defined before InitGoldLedgerDashboardScene
local ATK_GoldLedgerListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_GoldLedgerListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_GoldLedgerListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, GOLD_LEDGER_DASHBOARD_SCENE) end
function ATK_GoldLedgerListScreen:PerformUpdate() end
function ATK_GoldLedgerListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Refresh", keybind = "UI_SHORTCUT_SECONDARY", callback = function() NWT.UpdateGoldLedgerDashboard() PlaySound(SOUNDS.POSITIVE_CLICK) end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Net Worth", keybind = "UI_SHORTCUT_LEFT_SHOULDER", callback = function() NWT.OpenNetWorthDashboard() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Net Worth", keybind = "UI_SHORTCUT_RIGHT_SHOULDER", callback = function() NWT.OpenNetWorthDashboard() end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.CloseGoldLedgerDashboard() end)
end

function NWT.InitGoldLedgerDashboardScene()
    if NWT.GoldLedgerDashboard.sceneInitialized then return end
    local ui = ATK_GoldLedger_UI
    if not ui then return end
    
    -- Create hidden list for d-pad navigation
    local hiddenControl = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenGoldLedgerList", GuiRoot, "ATK_HouseList_Screen")
    hiddenControl:SetHidden(true)
    hiddenControl:SetAlpha(0)
    
    local fragment = ZO_SimpleSceneFragment:New(ui)
    local hiddenFragment = ZO_SimpleSceneFragment:New(hiddenControl)
    
    GOLD_LEDGER_DASHBOARD_SCENE = ZO_Scene:New("goldLedgerDashboardScene", SCENE_MANAGER)
    GOLD_LEDGER_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    GOLD_LEDGER_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    GOLD_LEDGER_DASHBOARD_SCENE:AddFragment(fragment)
    GOLD_LEDGER_DASHBOARD_SCENE:AddFragment(hiddenFragment)
    
    NWT.HiddenGoldLedgerListScreen = ATK_GoldLedgerListScreen:New(hiddenControl)
    NWT.HiddenGoldLedgerList = NWT.HiddenGoldLedgerListScreen:GetMainList()
    NWT.HiddenGoldLedgerList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    -- Override MovePrevious/MoveNext for transaction navigation
    NWT.HiddenGoldLedgerList.MovePrevious = function(self, ...)
        NWT.GoldLedgerScrollTransaction("up")
    end
    NWT.HiddenGoldLedgerList.MoveNext = function(self, ...)
        NWT.GoldLedgerScrollTransaction("down")
    end
    
    GOLD_LEDGER_DASHBOARD_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            if NWT.HiddenGoldLedgerListScreen then 
                KEYBIND_STRIP:AddKeybindButtonGroup(NWT.HiddenGoldLedgerListScreen.keybindStripDescriptor) 
            end
            NWT.GoldLedgerDashboard.isOpen = true
            NWT.GoldLedgerDashboard.selectedIndex = 1
            NWT.GoldLedgerDashboard.scrollOffset = 0
        elseif newState == SCENE_SHOWN then
            if NWT.HiddenGoldLedgerList then NWT.HiddenGoldLedgerList:Activate() end
        elseif newState == SCENE_HIDDEN then
            if NWT.HiddenGoldLedgerListScreen then 
                KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.HiddenGoldLedgerListScreen.keybindStripDescriptor) 
            end
            if NWT.HiddenGoldLedgerList then NWT.HiddenGoldLedgerList:Deactivate() end
            NWT.GoldLedgerDashboard.isOpen = false
        end
    end)
    
    NWT.GoldLedgerDashboard.sceneInitialized = true
end

-- Navigate transaction list
function NWT.GoldLedgerScrollTransaction(direction)
    local transactions = NWT.savedVars.goldLedger.transactions or {}
    local numTrans = #transactions
    if numTrans == 0 then return end
    
    local gl = NWT.GoldLedgerDashboard
    local maxVisible = 15
    
    if direction == "up" then
        gl.selectedIndex = gl.selectedIndex - 1
        if gl.selectedIndex < 1 then gl.selectedIndex = 1 end
        -- Scroll up if needed
        if gl.selectedIndex <= gl.scrollOffset then
            gl.scrollOffset = math.max(0, gl.selectedIndex - 1)
        end
    else
        gl.selectedIndex = gl.selectedIndex + 1
        if gl.selectedIndex > numTrans then gl.selectedIndex = numTrans end
        -- Scroll down if needed
        if gl.selectedIndex > gl.scrollOffset + maxVisible then
            gl.scrollOffset = gl.selectedIndex - maxVisible
        end
    end
    
    NWT.UpdateGoldLedgerDashboard()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.UpdateGoldLedgerDashboard()
    local ui = ATK_GoldLedger_UI
    if not ui then return end
    if NWT.CheckGoldLedgerDailyReset then NWT.CheckGoldLedgerDailyReset() end
    
    local colors = NWT.GetColors()
    local today = NWT.savedVars.goldLedger.today
    
    -- Calculate totals
    local tInc, tExp = 0, 0
    for _, v in pairs(today.income) do tInc = tInc + v end
    for _, v in pairs(today.expenses) do tExp = tExp + v end
    local net = tInc - tExp
    local nCol = net >= 0 and colors.positive or colors.negative
    
    -- Header
    local header = ui:GetNamedChild("Header")
    if header then
        local title = header:GetNamedChild("Title")
        if title then title:SetText(string.format("|cFFD700GOLD LEDGER|r  |c%s%s%sg|r", nCol, net >= 0 and "+" or "", NWT.FormatGoldLedger(net))) end
        local subtitle = header:GetNamedChild("Subtitle")
        if subtitle then subtitle:SetText("|c888888Resets daily at 5:00 AM EST  •  v" .. (NWT.goldLedgerVersion or "?") .. "|r") end
    end
    
    -- Left Column - Transaction History (with scrolling and selection)
    local leftCol = ui:GetNamedChild("LeftCol")
    if leftCol then
        local transCard = leftCol:GetNamedChild("TransactionsCard")
        if transCard then
            local list = transCard:GetNamedChild("List")
            if list then
                local transactions = NWT.savedVars.goldLedger.transactions or {}
                local gl = NWT.GoldLedgerDashboard
                local scrollOffset = gl.scrollOffset or 0
                local selectedIndex = gl.selectedIndex or 1
                
                for i = 1, 15 do
                    local transIndex = i + scrollOffset
                    local trans = transactions[transIndex]
                    local timeCell = list:GetNamedChild("R" .. i .. "Time")
                    local typeCell = list:GetNamedChild("R" .. i .. "Type")
                    local amountCell = list:GetNamedChild("R" .. i .. "Amount")
                    local balanceCell = list:GetNamedChild("R" .. i .. "Balance")
                    
                    if trans then
                        local isSelected = (transIndex == selectedIndex)
                        local amtColor = trans.amount >= 0 and "00FF00" or "FF6666"
                        local typeDisplay = trans.typeName or "Unknown"
                        if trans.itemName and trans.itemName ~= "" then
                            typeDisplay = typeDisplay .. ": " .. trans.itemName
                        end
                        
                        -- Selection highlighting
                        local timeColor = isSelected and "FFD700" or "888888"
                        local typeColor = isSelected and "FFFF00" or "FFFFFF"
                        local prefix = isSelected and "► " or "  "
                        
                        if timeCell then timeCell:SetText(string.format("|c%s%s|r", timeColor, NWT.FormatTransactionTime(trans.time))) end
                        if typeCell then typeCell:SetText(string.format("|c%s%s%s|r", typeColor, prefix, typeDisplay)) end
                        if amountCell then amountCell:SetText(string.format("|c%s%s%sg|r", amtColor, trans.amount >= 0 and "+" or "", NWT.FormatGoldLedger(trans.amount))) end
                        if balanceCell then balanceCell:SetText("|cFFD700" .. NWT.FormatGoldLedger(trans.balance) .. "g|r") end
                    else
                        if timeCell then timeCell:SetText("") end
                        if typeCell then typeCell:SetText("") end
                        if amountCell then amountCell:SetText("") end
                        if balanceCell then balanceCell:SetText("") end
                    end
                end
            end
            
            local transactions = NWT.savedVars.goldLedger.transactions or {}
            local transCount = #transactions
            local gl = NWT.GoldLedgerDashboard
            local pageInfo = transCard:GetNamedChild("PageInfo")
            if pageInfo then 
                if transCount > 0 then
                    local startIdx = gl.scrollOffset + 1
                    local endIdx = math.min(gl.scrollOffset + 15, transCount)
                    pageInfo:SetText(string.format("|c888888[D-pad] Navigate  •  %d-%d of %d|r", startIdx, endIdx, transCount))
                else
                    pageInfo:SetText("|c888888No transactions recorded yet|r")
                end
            end
        end
    end
    
    -- Right Column - Balance Card
    local rightCol = ui:GetNamedChild("RightCol")
    if rightCol then
        local balanceCard = rightCol:GetNamedChild("BalanceCard")
        if balanceCard then
            local amount = balanceCard:GetNamedChild("Amount")
            if amount then amount:SetText("|c00FF00" .. NWT.FormatGold(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) + GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)) .. "g|r") end
            local change = balanceCard:GetNamedChild("Change")
            if change then change:SetText(string.format("|c%sToday: %s%sg|r", nCol, net >= 0 and "+" or "", NWT.FormatGoldLedger(net))) end
        end
        
        -- Period Card
        local periodCard = rightCol:GetNamedChild("PeriodCard")
        if periodCard then
            local period = periodCard:GetNamedChild("Period")
            if period then period:SetText("|c00FFFFToday's Activity|r") end
            local income = periodCard:GetNamedChild("Income")
            if income then income:SetText(string.format("|c00FF00Income:|r +%sg", NWT.FormatGoldLedger(tInc))) end
            local expenses = periodCard:GetNamedChild("Expenses")
            if expenses then expenses:SetText(string.format("|cFF6666Expenses:|r -%sg", NWT.FormatGoldLedger(tExp))) end
            local netChange = periodCard:GetNamedChild("NetChange")
            if netChange then netChange:SetText(string.format("|c%sNet:|r %s%sg", nCol, net >= 0 and "+" or "", NWT.FormatGoldLedger(net))) end
        end
        
        -- Breakdown Card - Income types
        local breakdownCard = rightCol:GetNamedChild("BreakdownCard")
        if breakdownCard then
            local type1 = breakdownCard:GetNamedChild("Type1")
            if type1 then type1:SetText(string.format("|c00FF00Guild Sales:|r +%sg", NWT.FormatGoldLedger(today.income.guildSales))) end
            local type2 = breakdownCard:GetNamedChild("Type2")
            if type2 then type2:SetText(string.format("|c00FF00Vendor Sales:|r +%sg", NWT.FormatGoldLedger(today.income.vendorSales))) end
            local type3 = breakdownCard:GetNamedChild("Type3")
            if type3 then type3:SetText(string.format("|c00FF00Loot:|r +%sg", NWT.FormatGoldLedger(today.income.loot))) end
            local type4 = breakdownCard:GetNamedChild("Type4")
            if type4 then type4:SetText(string.format("|c00FF00Mail:|r +%sg", NWT.FormatGoldLedger(today.income.mail))) end
            -- Expenses
            local type5 = breakdownCard:GetNamedChild("Type5")
            if type5 then type5:SetText(string.format("|cFF6666Purchases:|r -%sg", NWT.FormatGoldLedger(today.expenses.guildPurchases + today.expenses.vendorPurchases))) end
            local type6 = breakdownCard:GetNamedChild("Type6")
            if type6 then type6:SetText(string.format("|cFF6666Repairs:|r -%sg", NWT.FormatGoldLedger(today.expenses.repairs))) end
            local type7 = breakdownCard:GetNamedChild("Type7")
            if type7 then type7:SetText(string.format("|cFF6666Listing Fees:|r -%sg", NWT.FormatGoldLedger(today.expenses.guildListingFee))) end
            local type8 = breakdownCard:GetNamedChild("Type8")
            if type8 then type8:SetText(string.format("|cFF6666Other:|r -%sg", NWT.FormatGoldLedger(today.expenses.travel + today.expenses.mail + today.expenses.other))) end
        end
    end
    
    -- Footer
    local footer = ui:GetNamedChild("Footer")
    if footer then footer:SetText("|c888888[LB/RB] Net Worth  [B] Back  [Y] Refresh|r") end
end

function NWT.OpenGoldLedgerDashboard()
    if NWT.GoldLedgerDashboard.isOpen then return end
    -- If another dashboard is open, close it first to maintain proper scene stack
    if NWT.NetWorthDashboard.isOpen then SCENE_MANAGER:Hide("netWorthDashboardScene") end
    NWT.InitGoldLedgerDashboardScene()
    if not GOLD_LEDGER_DASHBOARD_SCENE then return end
    NWT.UpdateGoldLedgerDashboard()
    SCENE_MANAGER:Push("goldLedgerDashboardScene")
end

function NWT.CloseGoldLedgerDashboard() if GOLD_LEDGER_DASHBOARD_SCENE then SCENE_MANAGER:Hide("goldLedgerDashboardScene") end end
