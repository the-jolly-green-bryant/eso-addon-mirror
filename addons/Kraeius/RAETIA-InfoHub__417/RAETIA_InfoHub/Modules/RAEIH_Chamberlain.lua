local WM = GetWindowManager()
local LMP = RAEIH.LMP
local uTag = "player"
local iconGold = zo_iconFormat("esoui/art/currency/currency_gold.dds", 12, 12)

function RAEIH.CreateChamberlain()
	if RAEIH.SavedVars.EnableChamberlain == true then
		-- Shorten Variables
		local clX = RAEIH.SavedVars.ChamberlainX
		local clY = RAEIH.SavedVars.ChamberlainY
		local clW = RAEIH.SavedVars.ChamberlainW
		local clH = RAEIH.SavedVars.ChamberlainH
		local clBA = RAEIH.SavedVars.ChamberlainBA
		local clIEH = RAEIH.SavedVars.ChamberlainIEH
		-- Main Placeholder
		RAEIH_Chamberlain = WM:CreateTopLevelWindow("RAEIH_Chamberlain")
		RAEIH_Chamberlain:SetDimensions(clW, clH)
		RAEIH_Chamberlain:SetClampedToScreen(true)	
		RAEIH_Chamberlain:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, clX, clY)
		RAEIH_Chamberlain:SetMouseEnabled(true)		
		RAEIH_Chamberlain:SetMovable(true)
		RAEIH_Chamberlain:SetHandler("OnReceiveDrag", RAEIH.StartMovingChamberlain)
		RAEIH_Chamberlain:SetHandler("OnMouseUp", RAEIH.StopMovingChamberlain)
		if RAEIH.SavedVars.ChamberlainUseAHRules == false then	
			RAEIH_Chamberlain:SetHidden(true)
		else
			RAEIH_Chamberlain:SetHidden(false)
		end
		RAEIH_Chamberlain:SetDrawLevel(0)
		RAEIH_Chamberlain:SetDrawLayer(0)
		RAEIH_Chamberlain:SetDrawTier(0)
		-- Top Container
		---- Backdrop
		RAEIH_Chamberlain_TopBD = WM:CreateControl("RAEIH_Chamberlain_TopBD", RAEIH_Chamberlain, CT_BACKDROP)
		RAEIH_Chamberlain_TopBD:SetDimensions(clW, 28)
		RAEIH_Chamberlain_TopBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain, TOPLEFT, 0, 0)
		RAEIH_Chamberlain_TopBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_TopBD:SetEdgeColor(0, 0, 0, 0)
		RAEIH_Chamberlain_TopBD:SetHidden(false)
		---- String
		RAEIH_Chamberlain_TopST = WM:CreateControl("RAEIH_Chamberlain_TopST", RAEIH_Chamberlain, CT_LABEL)
		RAEIH_Chamberlain_TopST:SetAnchor(TOPLEFT, RAEIH_Chamberlain_TopBD, TOPLEFT, 5, 5)
		RAEIH_Chamberlain_TopST:SetHorizontalAlignment(1)
		RAEIH_Chamberlain_TopST:SetVerticalAlignment(1)
		RAEIH_Chamberlain_TopST:SetHidden(false)
		---- MinexUP Button
		RAEIH_Chamberlain_MinexUPButton = WM:CreateControl("RAEIH_Chamberlain_MinexUPButton", RAEIH_Chamberlain, CT_BUTTON)
		RAEIH_Chamberlain_MinexUPButton:SetDimensions(14, 14)		
		RAEIH_Chamberlain_MinexUPButton:SetNormalTexture(RAEIH.Icons.ChamberlainUpArrow)
		RAEIH_Chamberlain_MinexUPButton:SetAnchor(TOPRIGHT, RAEIH_Chamberlain_TopBD, TOPRIGHT, -20, 7)
		RAEIH_Chamberlain_MinexUPButton:SetMouseEnabled(true)
		RAEIH_Chamberlain_MinexUPButton:SetMovable(false)
		if RAEIH.SavedVars.ChamberlainFormat == "Summary" then
			RAEIH_Chamberlain_MinexUPButton:SetHidden(false)
		else
			RAEIH_Chamberlain_MinexUPButton:SetHidden(true)
		end
		RAEIH_Chamberlain_MinexUPButton:SetHandler("OnClicked", function() RAEIH.ChamberlainFormatChange("Extended") end)
		---- MinexDOWN Button
		RAEIH_Chamberlain_MinexDOWNButton = WM:CreateControl("RAEIH_Chamberlain_MinexDOWNButton", RAEIH_Chamberlain, CT_BUTTON)
		RAEIH_Chamberlain_MinexDOWNButton:SetDimensions(14, 14)		
		RAEIH_Chamberlain_MinexDOWNButton:SetNormalTexture(RAEIH.Icons.ChamberlainDownArrow)
		RAEIH_Chamberlain_MinexDOWNButton:SetAnchor(TOPRIGHT, RAEIH_Chamberlain_TopBD, TOPRIGHT, -20, 7)
		RAEIH_Chamberlain_MinexDOWNButton:SetMouseEnabled(true)
		RAEIH_Chamberlain_MinexDOWNButton:SetMovable(false)
		if RAEIH.SavedVars.ChamberlainFormat == "Extended" then
			RAEIH_Chamberlain_MinexDOWNButton:SetHidden(false)
		else
			RAEIH_Chamberlain_MinexDOWNButton:SetHidden(true)
		end
		RAEIH_Chamberlain_MinexDOWNButton:SetHandler("OnClicked", function() RAEIH.ChamberlainFormatChange("Summary") end)
		---- Close Button
		RAEIH_Chamberlain_CloseButton = WM:CreateControl("RAEIH_Chamberlain_CloseButton", RAEIH_Chamberlain, CT_BUTTON)
		RAEIH_Chamberlain_CloseButton:SetDimensions(16, 16)		
		RAEIH_Chamberlain_CloseButton:SetNormalTexture(RAEIH.Icons.ChamberlainClose)
		RAEIH_Chamberlain_CloseButton:SetAnchor(TOPRIGHT, RAEIH_Chamberlain_TopBD, TOPRIGHT, 0, 8)
		RAEIH_Chamberlain_CloseButton:SetMouseEnabled(true)
		RAEIH_Chamberlain_CloseButton:SetMovable(false)
		RAEIH_Chamberlain_CloseButton:SetHidden(false)
		RAEIH_Chamberlain_CloseButton:SetHandler("OnClicked", function() RAEIH.ChamberlainClose() end)
		-- PL Container
		---- Backdrop
		RAEIH_Chamberlain_PLBD = WM:CreateControl("RAEIH_Chamberlain_PLBD", RAEIH_Chamberlain, CT_BACKDROP)
		RAEIH_Chamberlain_PLBD:SetDimensions(clW, 28)
		RAEIH_Chamberlain_PLBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain, TOPLEFT, 0, 30)
		RAEIH_Chamberlain_PLBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_PLBD:SetEdgeColor(0, 0, 0, 0)
		RAEIH_Chamberlain_PLBD:SetHidden(false)
		---- String
		RAEIH_Chamberlain_PLST = WM:CreateControl("RAEIH_Chamberlain_PLST", RAEIH_Chamberlain, CT_LABEL)
		RAEIH_Chamberlain_PLST:SetAnchor(TOPLEFT, RAEIH_Chamberlain_PLBD, TOPLEFT, 5, 5)
		RAEIH_Chamberlain_PLST:SetHorizontalAlignment(1)
		RAEIH_Chamberlain_PLST:SetVerticalAlignment(1)
		RAEIH_Chamberlain_PLST:SetHidden(false)
		-- Income Container
		---- Backdrop
		RAEIH_Chamberlain_IncomeBD = WM:CreateControl("RAEIH_Chamberlain_IncomeBD", RAEIH_Chamberlain, CT_BACKDROP)
		RAEIH_Chamberlain_IncomeBD:SetDimensions((clW / 2) - 1, clIEH)
		RAEIH_Chamberlain_IncomeBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain, TOPLEFT, 0, 60)
		RAEIH_Chamberlain_IncomeBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_IncomeBD:SetEdgeColor(0, 0, 0, 0)
		if RAEIH.SavedVars.ChamberlainFormat == "Extended" then
			RAEIH_Chamberlain_IncomeBD:SetHidden(false)
		else
			RAEIH_Chamberlain_IncomeBD:SetHidden(true)
		end
		---- String
		RAEIH_Chamberlain_IncomeST = WM:CreateControl("RAEIH_Chamberlain_IncomeST", RAEIH_Chamberlain, CT_LABEL)
		RAEIH_Chamberlain_IncomeST:SetAnchor(TOPLEFT, RAEIH_Chamberlain_IncomeBD, TOPLEFT, 5, 5)
		RAEIH_Chamberlain_IncomeST:SetHorizontalAlignment(1)
		RAEIH_Chamberlain_IncomeST:SetVerticalAlignment(1)
		if RAEIH.SavedVars.ChamberlainFormat == "Extended" then
			RAEIH_Chamberlain_IncomeST:SetHidden(false)
		else
			RAEIH_Chamberlain_IncomeST:SetHidden(true)
		end
		-- Expense Container
		---- Backdrop
		RAEIH_Chamberlain_ExpenseBD = WM:CreateControl("RAEIH_Chamberlain_ExpenseBD", RAEIH_Chamberlain, CT_BACKDROP)
		RAEIH_Chamberlain_ExpenseBD:SetDimensions((clW / 2) - 1, clIEH)
		RAEIH_Chamberlain_ExpenseBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain, TOPLEFT, (clW / 2) + 1, 60)
		RAEIH_Chamberlain_ExpenseBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_ExpenseBD:SetEdgeColor(0, 0, 0, 0)
		if RAEIH.SavedVars.ChamberlainFormat == "Extended" then
			RAEIH_Chamberlain_ExpenseBD:SetHidden(false)
		else
			RAEIH_Chamberlain_ExpenseBD:SetHidden(true)
		end
		---- String
		RAEIH_Chamberlain_ExpenseST = WM:CreateControl("RAEIH_Chamberlain_ExpenseST", RAEIH_Chamberlain, CT_LABEL)
		RAEIH_Chamberlain_ExpenseST:SetAnchor(TOPLEFT, RAEIH_Chamberlain_ExpenseBD, TOPLEFT, 5, 5)
		RAEIH_Chamberlain_ExpenseST:SetHorizontalAlignment(1)
		RAEIH_Chamberlain_ExpenseST:SetVerticalAlignment(1)
		if RAEIH.SavedVars.ChamberlainFormat == "Extended" then
			RAEIH_Chamberlain_ExpenseST:SetHidden(false)
		else
			RAEIH_Chamberlain_ExpenseST:SetHidden(true)
		end
		-- Bottom Container	
		---- Backdrop
		RAEIH_Chamberlain_BottomBD = WM:CreateControl("RAEIH_Chamberlain_BottomBD", RAEIH_Chamberlain, CT_BACKDROP)
		RAEIH_Chamberlain_BottomBD:SetDimensions(clW, 28)
		RAEIH_Chamberlain_BottomBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain, TOPLEFT, 0, clIEH + 61)
		RAEIH_Chamberlain_BottomBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_BottomBD:SetEdgeColor(0, 0, 0, 0)
		RAEIH_Chamberlain_BottomBD:SetHidden(false)
		---- String
		RAEIH_Chamberlain_BottomST = WM:CreateControl("RAEIH_Chamberlain_BottomST", RAEIH_Chamberlain, CT_LABEL)
		RAEIH_Chamberlain_BottomST:SetAnchor(TOPLEFT, RAEIH_Chamberlain_BottomBD, TOPLEFT, 5, 5)
		RAEIH_Chamberlain_BottomST:SetHorizontalAlignment(1)
		RAEIH_Chamberlain_BottomST:SetVerticalAlignment(1)
		RAEIH_Chamberlain_BottomST:SetHidden(false)
		---- History Button
		RAEIH_Chamberlain_OldRecButton = WM:CreateControl("RAEIH_Chamberlain_OldRecButton", RAEIH_Chamberlain, CT_BUTTON)
		RAEIH_Chamberlain_OldRecButton:SetDimensions(28, 28)		
		RAEIH_Chamberlain_OldRecButton:SetNormalTexture(RAEIH.Icons.GoldperHour)
		RAEIH_Chamberlain_OldRecButton:SetAnchor(TOPRIGHT, RAEIH_Chamberlain_BottomBD, TOPRIGHT, 0, 0)
		RAEIH_Chamberlain_OldRecButton:SetMouseEnabled(true)
		RAEIH_Chamberlain_OldRecButton:SetMovable(false)

		if RAEIH.SavedVars.ChamberlainFormat == "Extended" then
			RAEIH_Chamberlain_OldRecButton:SetHidden(false)
		else
			RAEIH_Chamberlain_OldRecButton:SetHidden(true)
		end

		RAEIH_Chamberlain_OldRecButton:SetHandler("OnClicked", function() RAEIH.ToggleChamberlainOldRecords() end)
	end
end

local lastIndex = nil
local shownIndex = nil

function RAEIH.SetOldChamberlain()

	local timeStamp = GetTimeStamp()
	local dateString = GetDateStringFromTimestamp(timeStamp)
				
	for i, slot in pairs(RAEIH.SavedVars.ChamberlainLedger) do
		if RAEIH.SavedVars.ChamberlainLedger[i]["Date"] == dateString then
			lastIndex = i
			if shownIndex == nil then shownIndex = lastIndex - 1 end
		end
	end

	if lastIndex >= 2 and (shownIndex ~= 0 or nil) and shownIndex < lastIndex then

		-- Fill Data

		local clrDft = "|c" .. RAEIH.SavedVars.ChamberlainDefaultColour
		local clrA = "|c" .. RAEIH.SavedVars.ChamberlainAlertColour
		local clrW = "|c" .. RAEIH.SavedVars.ChamberlainWarningColour
		local clrN = "|c" .. RAEIH.SavedVars.ChamberlainNormalColour
		local clrD = "|c" .. RAEIH.SavedVars.ChamberlainDailyColour
		local clr = clrDft
		local clrBTR = clrDft
		local clrGBTR = clrDft

		local character = GetUnitName(uTag)

		RAEIH_Chamberlain_OldTopST:SetText("|c3A5FCDChamberlain|r History » " .. character .. " (" .. RAEIH.SavedVars.ChamberlainLedger[shownIndex]["Date"] .. ")")

		if RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeFencing"] == nil then RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeFencing"] = 0 end
		if RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseLaundry"] == nil then RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseLaundry"] = 0 end

		RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalIncome"] = RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeLoot"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeVendor"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeMail"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeCloseTrade"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeQuest"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeOther"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeCoD"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeFencing"]		

		RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalExpense"] = RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseVendor"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseMail"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseCloseTrade"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseOther"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseCoD"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRepair"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseTPurchase"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseTListing"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseBTGuard"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseLaundry"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseBTConf"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRSkills"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRAtt"] + RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRMorphs"]

		if RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalIncome"] > RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalExpense"] then
			clr = clrN
		elseif RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalIncome"] < RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalExpense"] then
			clr = clrA
		else
			clr = clrW
		end

		if RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankDeposit"] > RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankWithdrawal"] then
			clrBTR = clrN
		elseif RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankDeposit"] < RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankWithdrawal"] then
			clrBTR = clrA
		else
			clrBTR = clrW
		end

		if RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankDeposit"] > RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankWithdrawal"] then
			clrGBTR = clrN
		elseif RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankDeposit"] < RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankWithdrawal"] then
			clrGBTR = clrA
		else
			clrGBTR = clrW
		end

		local lootNum = nil
		local vendorSaleNum = nil			
		local questNum = nil
		local storeNMailNum = nil
		local fencingNum = nil
		local closeTradeTakeNum = nil
		local otherTakeNum = nil
		local totalIncomeNum = nil
		local totalExpenseNum = nil
		local profitLossNum = nil

		local vendorBuyNum = nil
		local repairNum = nil
		local tPurchaseNum = nil
		local tListingNum = nil
		local closeTradeGiveNum = nil
		local mailGiveNum = nil
		local laundryNum = nil
		local btGuardNum = nil
		local btConfNum = nil
		local rAttNum = nil
		local rMorphsNum = nil
		local rSkillsNum = nil
		local otherGiveNum = nil

		local bWithdrawalNum = nil
		local bDepositNum = nil
		local bChangeNum = nil
		local gbWithdrawalNum = nil
		local gbDepositNum = nil
		local gbChangeNum = nil

		if RAEIH.SavedVars.TSFormat == "Point (.)" then
			lootNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeLoot"])
			vendorSaleNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeVendor"])			
			questNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeQuest"])
			storeNMailNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeMail"])
			fencingNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeFencing"])
			closeTradeTakeNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeCloseTrade"])
			otherTakeNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeOther"])
			totalIncomeNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalIncome"])
			totalExpenseNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalExpense"])
			profitLossNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalIncome"] - RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalExpense"])

			vendorBuyNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseVendor"])
			repairNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRepair"])
			tPurchaseNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseTPurchase"]) 
			tListingNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseTListing"])
			closeTradeGiveNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseCloseTrade"]) 
			mailGiveNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseMail"]) 
			laundryNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseLaundry"])
			btGuardNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseBTGuard"])
			btConfNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseBTConf"])
			rAttNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRAtt"])
			rMorphsNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRMorphs"])
			rSkillsNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRSkills"])
			otherGiveNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseOther"])

			bWithdrawalNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankWithdrawal"])
			bDepositNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankDeposit"])
			gbWithdrawalNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankWithdrawal"])
			gbDepositNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankDeposit"])

			bChangeNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankDeposit"] - RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankWithdrawal"])
			gbChangeNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankDeposit"] - RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankWithdrawal"])
		else
			lootNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeLoot"])
			vendorSaleNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeVendor"])
			questNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeQuest"])
			storeNMailNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeMail"])
			fencingNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeFencing"])
			closeTradeTakeNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeCloseTrade"])
			otherTakeNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["IncomeOther"])
			totalIncomeNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalIncome"])
			totalExpenseNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalExpense"])
			profitLossNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalIncome"] - RAEIH.SavedVars.ChamberlainLedger[shownIndex]["TotalExpense"])

			vendorBuyNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseVendor"])
			repairNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRepair"])
			tPurchaseNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseTPurchase"]) 
			tListingNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseTListing"])
			closeTradeGiveNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseCloseTrade"])
			mailGiveNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseMail"])
			fencingNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseLaundry"])
			btGuardNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseBTGuard"])
			btConfNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseBTConf"])
			rAttNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRAtt"])
			rMorphsNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRMorphs"])
			rSkillsNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseRSkills"])
			otherGiveNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["ExpenseOther"])

			bWithdrawalNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankWithdrawal"])
			bDepositNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankDeposit"])
			gbWithdrawalNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankWithdrawal"])
			gbDepositNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankDeposit"])

			bChangeNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankDeposit"] - RAEIH.SavedVars.ChamberlainLedger[shownIndex]["BankWithdrawal"])
			gbChangeNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankDeposit"] - RAEIH.SavedVars.ChamberlainLedger[shownIndex]["GBankWithdrawal"])
		end

		-- PL String

		local titlePL = RAEIH.SavedVars.ChamberlainLedger[shownIndex]["Date"] .. " Profit/Loss: " .. clr .. tostring(profitLossNum) .. " " .. iconGold .. clrDft .. " » Total Income: " .. clrW .. tostring(totalIncomeNum) .. " " .. iconGold .. clrDft .. " / Total Expense: " .. clrW .. tostring(totalExpenseNum) .. iconGold .. " " .. clrDft

		-- Income String

		local titleIncome = clrN .. "INCOME" .. clrDft
		local loot = "\nLoot : " .. clrW .. tostring(lootNum) .. iconGold .. " " .. clrDft
		local vendorSale = "\nVendor: " .. clrW .. tostring(vendorSaleNum) .. iconGold .. " " .. clrDft
		local quest = "\nQuest:	" .. clrW .. tostring(questNum) .. iconGold .. " " .. clrDft
		local fencing = "\nFencing: " .. clrW .. tostring(fencingNum) .. iconGold .. " " .. clrDft
		local storeNMail = "\n\nGuild Store/Mail/CoD: " .. clrW .. tostring(storeNMailNum) .. iconGold .. " " .. clrDft
		local closeTradeTake = "\nClose Trade: " .. clrW .. tostring(closeTradeTakeNum) .. iconGold .. " " .. clrDft
		local otherTake = "\nOther: " .. clrW .. tostring(otherTakeNum) .. iconGold .. " " .. clrDft

		-- Bank String

		local titleBank = clrN .. "\n\nBANK TRANSACTIONS" .. clrDft
		local bankWith = "\nBank Withdrawal: " .. clrW .. tostring(bWithdrawalNum) .. iconGold .. " " .. clrDft
		local bankDep = "\nBank Deposit: " .. clrW .. tostring(bDepositNum) .. iconGold .. " " .. clrDft
		local bankChange = "\nBank Change: " .. clrBTR .. tostring(bChangeNum) .. iconGold .. " " .. clrDft
		local gbWith = "\n\nGuild Bank Withdrawal: " .. clrW .. tostring(gbDepositNum) .. iconGold .. " " .. clrDft
		local gbDep = "\nGuild Bank Deposit: " .. clrW .. tostring(gbDepositNum) .. iconGold .. " " .. clrDft
		local gbChange = "\nGuild Bank Change: " .. clrGBTR .. tostring(gbChangeNum) .. iconGold .. " " .. clrDft

		-- Expense String

		local titleExpense = clrA .. "EXPENSES" .. clrDft
		local vendorBuy = "\nVendor: " .. clrW .. tostring(vendorBuyNum) .. iconGold .. " " .. clrDft
		local repair = "\nRepair: " .. clrW .. tostring(repairNum) .. iconGold .. " " .. clrDft
		local tPurchase = "\n\nStore/Kiosk(Trade): " .. clrW .. tostring(tPurchaseNum) .. iconGold .. " " .. clrDft
		local tListing = "\nListing(Trade): " .. clrW .. tostring(tListingNum) .. iconGold .. " " .. clrDft
		local closeTradeGive = "\nClose Trade: " .. clrW .. tostring(closeTradeGiveNum) .. iconGold .. " " .. clrDft
		local mailGive = "\n\nMail/CoD: " .. clrW .. tostring(mailGiveNum) .. iconGold .. " " .. clrDft
		local laundry = "\n\nLaundry: " .. clrW .. tostring(laundryNum) .. iconGold .. " " .. clrDft
		local btGuard = "\nBounty(Guard): " .. clrW .. tostring(btGuardNum) .. iconGold .. " " .. clrDft
		local btConf = "\nBounty(Fence): " .. clrW .. tostring(btConfNum) .. iconGold .. " " .. clrDft
		local rAtt = "\n\nRespec(Att.): " .. clrW .. tostring(rAttNum) .. iconGold .. " " .. clrDft
		local rMorphs = "\nRespec(Morphs): " .. clrW .. tostring(rMorphsNum) .. iconGold .. " " .. clrDft
		local rSkills = "\nRespec(Skills): " .. clrW .. tostring(rSkillsNum) .. iconGold .. " " .. clrDft
		local otherGive = "\nOther: " .. clrW .. tostring(otherGiveNum) .. iconGold .. " " .. clrDft

		RAEIH_Chamberlain_OldPLST:SetText(titlePL)

		RAEIH_Chamberlain_OldIncomeST:SetText(titleIncome .. loot .. vendorSale .. quest .. fencing .. storeNMail .. closeTradeTake .. otherTake .. titleBank .. bankWith .. bankDep .. bankChange .. gbWith .. gbDep .. gbChange)		

		RAEIH_Chamberlain_OldExpenseST:SetText(titleExpense .. vendorBuy .. repair .. tPurchase .. tListing .. closeTradeGive .. mailGive .. laundry .. btGuard .. btConf .. rAtt .. rMorphs .. rSkills .. otherGive)

		RAEIH_Chamberlain_OldBottomST:SetText("Current |c3A5FCDChamberlain|r History Record: " .. clrD .. shownIndex)

	else
	
		if shownIndex == 0 then shownIndex = 1
		elseif shownIndex >= lastIndex then shownIndex = shownIndex - 1
		end	

	end
end

function RAEIH.ToggleChamberlainOldRecords()
	if RAEIH_Chamberlain_Old == nil then
		-- Shorten Variables
		local clX = 5
		local clY = 0
		local clW = RAEIH.SavedVars.ChamberlainW
		local clH = RAEIH.SavedVars.ChamberlainH
		local clBA = RAEIH.SavedVars.ChamberlainBA
		local clIEH = RAEIH.SavedVars.ChamberlainIEH
		-- Main Placeholder
		RAEIH_Chamberlain_Old = WM:CreateTopLevelWindow("RAEIH_Chamberlain_Old")
		RAEIH_Chamberlain_Old:SetDimensions(clW, clH)
		RAEIH_Chamberlain_Old:SetClampedToScreen(true)	
		RAEIH_Chamberlain_Old:SetAnchor(TOPLEFT, RAEIH_Chamberlain, TOPRIGHT, clX, clY)
		RAEIH_Chamberlain_Old:SetMouseEnabled(true)		
		RAEIH_Chamberlain_Old:SetMovable(false)
		RAEIH_Chamberlain_Old:SetHidden(false)
		RAEIH_Chamberlain_Old:SetDrawLevel(0)
		RAEIH_Chamberlain_Old:SetDrawLayer(0)
		RAEIH_Chamberlain_Old:SetDrawTier(0)
		-- Top Container
		---- Backdrop
		RAEIH_Chamberlain_OldTopBD = WM:CreateControl("RAEIH_Chamberlain_OldTopBD", RAEIH_Chamberlain_Old, CT_BACKDROP)
		RAEIH_Chamberlain_OldTopBD:SetDimensions(clW, 28)
		RAEIH_Chamberlain_OldTopBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain_Old, TOPLEFT, 0, 0)
		RAEIH_Chamberlain_OldTopBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_OldTopBD:SetEdgeColor(0, 0, 0, 0)
		RAEIH_Chamberlain_OldTopBD:SetHidden(false)
		---- String
		RAEIH_Chamberlain_OldTopST = WM:CreateControl("RAEIH_Chamberlain_OldTopST", RAEIH_Chamberlain_Old, CT_LABEL)
		RAEIH_Chamberlain_OldTopST:SetAnchor(TOPLEFT, RAEIH_Chamberlain_OldTopBD, TOPLEFT, 5, 5)
		RAEIH_Chamberlain_OldTopST:SetHorizontalAlignment(1)
		RAEIH_Chamberlain_OldTopST:SetVerticalAlignment(1)
		RAEIH_Chamberlain_OldTopST:SetHidden(false)
		---- Back Button
		RAEIH_Chamberlain_OldBackButton = WM:CreateControl("RAEIH_Chamberlain_OldBackButton", RAEIH_Chamberlain_Old, CT_BUTTON)
		RAEIH_Chamberlain_OldBackButton:SetDimensions(16, 16)		
		RAEIH_Chamberlain_OldBackButton:SetNormalTexture(RAEIH.Icons.ChamberlainLeftArrow)
		RAEIH_Chamberlain_OldBackButton:SetAnchor(TOPRIGHT, RAEIH_Chamberlain_OldTopBD, TOPRIGHT, -20, 6)
		RAEIH_Chamberlain_OldBackButton:SetMouseEnabled(true)
		RAEIH_Chamberlain_OldBackButton:SetMovable(false)
		RAEIH_Chamberlain_OldBackButton:SetHandler("OnClicked", function() shownIndex = shownIndex - 1 RAEIH.SetOldChamberlain() end)
		---- Forward Button
		RAEIH_Chamberlain_OldForwardButton = WM:CreateControl("RAEIH_Chamberlain_OldForwardButton", RAEIH_Chamberlain_Old, CT_BUTTON)
		RAEIH_Chamberlain_OldForwardButton:SetDimensions(16, 16)		
		RAEIH_Chamberlain_OldForwardButton:SetNormalTexture(RAEIH.Icons.ChamberlainRightArrow)
		RAEIH_Chamberlain_OldForwardButton:SetAnchor(TOPRIGHT, RAEIH_Chamberlain_OldTopBD, TOPRIGHT, -5, 6)
		RAEIH_Chamberlain_OldForwardButton:SetMouseEnabled(true)
		RAEIH_Chamberlain_OldForwardButton:SetMovable(false)
		RAEIH_Chamberlain_OldForwardButton:SetHidden(false)
		RAEIH_Chamberlain_OldForwardButton:SetHandler("OnClicked", function() shownIndex = shownIndex + 1 RAEIH.SetOldChamberlain() end)
		-- PL Container
		---- Backdrop
		RAEIH_Chamberlain_OldPLBD = WM:CreateControl("RAEIH_Chamberlain_OldPLBD", RAEIH_Chamberlain_Old, CT_BACKDROP)
		RAEIH_Chamberlain_OldPLBD:SetDimensions(clW, 28)
		RAEIH_Chamberlain_OldPLBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain_Old, TOPLEFT, 0, 30)
		RAEIH_Chamberlain_OldPLBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_OldPLBD:SetEdgeColor(0, 0, 0, 0)
		RAEIH_Chamberlain_OldPLBD:SetHidden(false)
		---- String
		RAEIH_Chamberlain_OldPLST = WM:CreateControl("RAEIH_Chamberlain_OldPLST", RAEIH_Chamberlain_Old, CT_LABEL)
		RAEIH_Chamberlain_OldPLST:SetAnchor(TOPLEFT, RAEIH_Chamberlain_OldPLBD, TOPLEFT, 5, 5)
		RAEIH_Chamberlain_OldPLST:SetHorizontalAlignment(1)
		RAEIH_Chamberlain_OldPLST:SetVerticalAlignment(1)
		RAEIH_Chamberlain_OldPLST:SetHidden(false)
		-- Income Container
		---- Backdrop
		RAEIH_Chamberlain_OldIncomeBD = WM:CreateControl("RAEIH_Chamberlain_OldIncomeBD", RAEIH_Chamberlain_Old, CT_BACKDROP)
		RAEIH_Chamberlain_OldIncomeBD:SetDimensions((clW / 2) - 1, clIEH)
		RAEIH_Chamberlain_OldIncomeBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain_Old, TOPLEFT, 0, 60)
		RAEIH_Chamberlain_OldIncomeBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_OldIncomeBD:SetEdgeColor(0, 0, 0, 0)
		---- String
		RAEIH_Chamberlain_OldIncomeST = WM:CreateControl("RAEIH_Chamberlain_OldIncomeST", RAEIH_Chamberlain_Old, CT_LABEL)
		RAEIH_Chamberlain_OldIncomeST:SetAnchor(TOPLEFT, RAEIH_Chamberlain_OldIncomeBD, TOPLEFT, 5, 5)
		RAEIH_Chamberlain_OldIncomeST:SetHorizontalAlignment(1)
		RAEIH_Chamberlain_OldIncomeST:SetVerticalAlignment(1)
		-- Expense Container
		---- Backdrop
		RAEIH_Chamberlain_OldExpenseBD = WM:CreateControl("RAEIH_Chamberlain_OldExpenseBD", RAEIH_Chamberlain_Old, CT_BACKDROP)
		RAEIH_Chamberlain_OldExpenseBD:SetDimensions((clW / 2) - 1, clIEH)
		RAEIH_Chamberlain_OldExpenseBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain_Old, TOPLEFT, (clW / 2) + 1, 60)
		RAEIH_Chamberlain_OldExpenseBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_OldExpenseBD:SetEdgeColor(0, 0, 0, 0)
		---- String
		RAEIH_Chamberlain_OldExpenseST = WM:CreateControl("RAEIH_Chamberlain_OldExpenseST", RAEIH_Chamberlain_Old, CT_LABEL)
		RAEIH_Chamberlain_OldExpenseST:SetAnchor(TOPLEFT, RAEIH_Chamberlain_OldExpenseBD, TOPLEFT, 5, 5)
		RAEIH_Chamberlain_OldExpenseST:SetHorizontalAlignment(1)
		RAEIH_Chamberlain_OldExpenseST:SetVerticalAlignment(1)
		-- Bottom Container	
		---- Backdrop
		RAEIH_Chamberlain_OldBottomBD = WM:CreateControl("RAEIH_Chamberlain_OldBottomBD", RAEIH_Chamberlain_Old, CT_BACKDROP)
		RAEIH_Chamberlain_OldBottomBD:SetDimensions(clW, 28)
		RAEIH_Chamberlain_OldBottomBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain_Old, TOPLEFT, 0, clIEH + 61)
		RAEIH_Chamberlain_OldBottomBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_OldBottomBD:SetEdgeColor(0, 0, 0, 0)
		RAEIH_Chamberlain_OldBottomBD:SetHidden(false)
		---- String
		RAEIH_Chamberlain_OldBottomST = WM:CreateControl("RAEIH_Chamberlain_OldBottomST", RAEIH_Chamberlain_Old, CT_LABEL)
		RAEIH_Chamberlain_OldBottomST:SetAnchor(TOPLEFT, RAEIH_Chamberlain_OldBottomBD, TOPLEFT, 5, 5)
		RAEIH_Chamberlain_OldBottomST:SetHorizontalAlignment(1)
		RAEIH_Chamberlain_OldBottomST:SetVerticalAlignment(1)
		RAEIH_Chamberlain_OldBottomST:SetHidden(false)

		RAEIH.SetOldChamberlain()
		RAEIH.FormatChamberlain()
		RAEIH.OrganizeChamberlain()

	elseif RAEIH_Chamberlain_Old ~= nil and RAEIH_Chamberlain_Old:IsHidden() == true then
		RAEIH_Chamberlain_Old:SetHidden(false)
		RAEIH.SetOldChamberlain()
		RAEIH.FormatChamberlain()
		RAEIH.OrganizeChamberlain()
	elseif RAEIH_Chamberlain_Old ~= nil and RAEIH_Chamberlain_Old:IsHidden() == false then
		RAEIH_Chamberlain_Old:SetHidden(true)
		RAEIH.SetOldChamberlain()
		RAEIH.FormatChamberlain()
		RAEIH.OrganizeChamberlain()
	end
end

function RAEIH.ChamberlainFormatChange(value)
	if RAEIH.SavedVars.ChamberlainFormat == "Extended" and value == "Summary" then
		RAEIH_Chamberlain_IncomeBD:SetHidden(true)
		RAEIH_Chamberlain_IncomeST:SetHidden(true)
		RAEIH_Chamberlain_ExpenseBD:SetHidden(true)
		RAEIH_Chamberlain_ExpenseST:SetHidden(true)
		if RAEIH_Chamberlain_Old ~= nil then
			RAEIH_Chamberlain_OldIncomeBD:SetHidden(true)
			RAEIH_Chamberlain_OldIncomeST:SetHidden(true)
			RAEIH_Chamberlain_OldExpenseBD:SetHidden(true)
			RAEIH_Chamberlain_OldExpenseST:SetHidden(true)
		end
		RAEIH_Chamberlain_MinexDOWNButton:SetHidden(true)
		RAEIH_Chamberlain_MinexUPButton:SetHidden(false)
		RAEIH.SavedVars.ChamberlainH = RAEIH.SavedVars.ChamberlainH - 375
		RAEIH_Chamberlain:SetDimensions(RAEIH.SavedVars.ChamberlainW, RAEIH.SavedVars.ChamberlainH)
		RAEIH.SavedVars.ChamberlainIEH = 0
		RAEIH.SavedVars.ChamberlainFormat = value
		RAEIH.SetChamberlain()
		RAEIH.FormatChamberlain()
		RAEIH.OrganizeChamberlain()
	elseif RAEIH.SavedVars.ChamberlainFormat == "Summary" and value == "Extended" then
		RAEIH_Chamberlain_IncomeBD:SetHidden(false)
		RAEIH_Chamberlain_IncomeST:SetHidden(false)
		RAEIH_Chamberlain_ExpenseBD:SetHidden(false)
		RAEIH_Chamberlain_ExpenseST:SetHidden(false)
		if RAEIH_Chamberlain_Old ~= nil then
			RAEIH_Chamberlain_OldIncomeBD:SetHidden(false)
			RAEIH_Chamberlain_OldIncomeST:SetHidden(false)
			RAEIH_Chamberlain_OldExpenseBD:SetHidden(false)
			RAEIH_Chamberlain_OldExpenseST:SetHidden(false)
		end
		RAEIH_Chamberlain_MinexUPButton:SetHidden(true)
		RAEIH_Chamberlain_MinexDOWNButton:SetHidden(false)
		RAEIH.SavedVars.ChamberlainH = RAEIH.SavedVars.ChamberlainH + 375
		RAEIH_Chamberlain:SetDimensions(RAEIH.SavedVars.ChamberlainW, RAEIH.SavedVars.ChamberlainH)
		RAEIH.SavedVars.ChamberlainIEH = 375
		RAEIH.SavedVars.ChamberlainFormat = value
		RAEIH.SetChamberlain()
		RAEIH.FormatChamberlain()
		RAEIH.OrganizeChamberlain()
	end
end

function RAEIH.ChamberlainClose()
	if RAEIH_Chamberlain:IsHidden() == false then 
		RAEIH_Chamberlain:SetHidden(true) 
		if RAEIH_Chamberlain_Old ~= nil then RAEIH_Chamberlain_Old:SetHidden(true) end 
	end
end

function RAEIH.SetChamberlain(eventCode, newMoney, oldMoney, reason)
	local foundIndex = nil
	local foundRec = false
	local recordNumByChar = 0
	local clrDft = "|c" .. RAEIH.SavedVars.ChamberlainDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.ChamberlainAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.ChamberlainWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.ChamberlainNormalColour
	local clrD = "|c" .. RAEIH.SavedVars.ChamberlainDailyColour
	local clr = clrDft
	local clrBTR = clrDft
	local clrGBTR = clrDft
	
	if RAEIH_Chamberlain ~= nil and RAEIH.SavedVars.EnableChamberlain == true then

		local character = GetUnitName(uTag)
		local timeStamp = GetTimeStamp()
		local dateString = GetDateStringFromTimestamp(timeStamp)
		local timePlayed = RAEIH.Round(GetGameTimeMilliseconds() / 60000)

		RAEIH_Chamberlain_TopST:SetText("|c3A5FCDRAETIA|r InfoHub - |c3A5FCDChamberlain|r » " .. character .. " (" .. dateString .. ")")
					
		for i, slot in pairs(RAEIH.SavedVars.ChamberlainLedger) do
			if RAEIH.SavedVars.ChamberlainLedger[i]["Date"] == dateString then
				foundRec = true
				foundIndex = i
				lastIndex = i
			end
			if RAEIH.SavedVars.ChamberlainLedger[i]["Character"] == character then
				recordNumByChar = recordNumByChar + 1
			end
		end

		if foundRec == false then
			-- 1.83kb
			local fReport = {}

			fReport["Character"] = GetUnitName(uTag)
			fReport["Date"] = dateString

			fReport["IncomeLoot"] = 0
			fReport["IncomeVendor"] = 0
			fReport["IncomeFencing"] = 0
			fReport["IncomeMail"] =	0
			fReport["IncomeCloseTrade"] = 0
			fReport["IncomeQuest"] = 0
			fReport["IncomeOther"] = 0
			fReport["IncomeCoD"] =	0
			fReport["IncomeGuildStore"] = 0				
			
			fReport["ExpenseVendor"] =	0
			fReport["ExpenseMail"] = 0
			fReport["ExpenseCloseTrade"] = 0
			fReport["ExpenseOther"] = 0
			fReport["ExpenseCoD"] =	0
			fReport["ExpenseRepair"] =	0
			fReport["ExpenseTPurchase"] = 0
			fReport["ExpenseTRefund"] = 0
			fReport["ExpenseTListing"] = 0
			fReport["ExpenseBTGuard"] = 0
			fReport["ExpenseLaundry"] = 0
			fReport["ExpenseBTConf"] = 0
			fReport["ExpenseRSkills"] = 0
			fReport["ExpenseRAtt"] = 0
			fReport["ExpenseRMorphs"] = 0

			fReport["TotalIncome"] = 0
			fReport["TotalExpense"] = 0

			fReport["BankDeposit"] = 0
			fReport["BankWithdrawal"] = 0
			fReport["GBankDeposit"] = 0
			fReport["GBankWithdrawal"] = 0

			table.insert(RAEIH.SavedVars.ChamberlainLedger, fReport)

			RAEIH_Chamberlain_PLST:SetText("|cFF3030Waiting for a transaction to update stats...")
			RAEIH_Chamberlain_IncomeST:SetText("")
			RAEIH_Chamberlain_ExpenseST:SetText("")

		elseif foundRec == true and reason ~= nil then
			local moneyChange = newMoney - oldMoney
			
			-- Reason Code Legend
			-- 13 = Looted gold from DLC bodies?
			-- 62 = Safebox gold
			-- 56 = Gold paid to fence for clearing bounty
			
			-- Income
			if moneyChange > 0 then
				if reason == 0 or reason == 13 or reason == 62 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeLoot"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeLoot"] + moneyChange						
				elseif reason == 1 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeVendor"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeVendor"] + moneyChange										
				elseif reason == 2 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeMail"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeMail"] + moneyChange										
				elseif reason == 3 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeCloseTrade"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeCloseTrade"] + moneyChange						
				elseif reason == 4 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeQuest"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeQuest"] + moneyChange						
				elseif reason == 5 or reason == 32 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeOther"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeOther"] + moneyChange						
				elseif reason == 20 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeCoD"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeCoD"] + moneyChange
				-- Withdrawals	
				elseif reason == 43 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankWithdrawal"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankWithdrawal"] + moneyChange
				elseif reason == 52 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankWithdrawal"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankWithdrawal"] + moneyChange
				elseif reason == 63 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeFencing"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeFencing"] + moneyChange					
				end
							
			-- Expenses	
			elseif moneyChange < 0 then
				moneyChange = oldMoney - newMoney
				if reason == 1 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseVendor"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseVendor"] + moneyChange						
				elseif reason == 2 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseMail"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseMail"] + moneyChange						
				elseif reason == 3 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseCloseTrade"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseCloseTrade"] + moneyChange						
				elseif reason == 4 or reason == 5 or reason == 8 or reason == 9 or reason == 28 or reason == 19 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseOther"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseOther"] + moneyChange										
				elseif reason == 20 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseCoD"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseCoD"] + moneyChange						
				elseif reason == 29 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRepair"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRepair"] + moneyChange						
				elseif reason == 31 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseTPurchase"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseTPurchase"] + moneyChange								
				elseif reason == 33 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseTListing"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseTListing"] + moneyChange						
				elseif reason == 47 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseBTGuard"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseBTGuard"] + moneyChange										
				elseif reason == 57 or reason == 56 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseBTConf"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseBTConf"] + moneyChange						
				elseif reason == 44 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRSkills"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRSkills"] + moneyChange						
				elseif reason == 45 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRAtt"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRAtt"] + moneyChange						
				elseif reason == 55 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRMorphs"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRMorphs"] + moneyChange
				-- Deposits	
				elseif reason == 42 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankDeposit"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankDeposit"] + moneyChange
				elseif reason == 51 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankDeposit"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankDeposit"] + moneyChange
				elseif reason == 60 then
					RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseLaundry"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseLaundry"] + moneyChange					
				end
			end																		
		end		
	end

	if foundIndex ~= nil then

		if RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeFencing"] == nil then RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeFencing"] = 0 end
		if RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseLaundry"] == nil then RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseLaundry"] = 0 end

		local yesterdayIndex = foundIndex - 1

		RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalIncome"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeLoot"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeVendor"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeMail"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeCloseTrade"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeQuest"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeOther"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeCoD"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeFencing"]		

		RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalExpense"] = RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseVendor"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseMail"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseCloseTrade"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseOther"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseCoD"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRepair"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseTPurchase"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseTListing"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseBTGuard"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseLaundry"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseBTConf"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRSkills"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRAtt"] + RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRMorphs"]		

		if RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalIncome"] > RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalExpense"] then
			clr = clrN
		elseif RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalIncome"] < RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalExpense"] then
			clr = clrA
		else
			clr = clrW
		end

		if RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankDeposit"] > RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankWithdrawal"] then
			clrBTR = clrN
		elseif RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankDeposit"] < RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankWithdrawal"] then
			clrBTR = clrA
		else
			clrBTR = clrW
		end

		if RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankDeposit"] > RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankWithdrawal"] then
			clrGBTR = clrN
		elseif RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankDeposit"] < RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankWithdrawal"] then
			clrGBTR = clrA
		else
			clrGBTR = clrW
		end

		local lootNum = nil
		local vendorSaleNum = nil			
		local questNum = nil
		local storeNMailNum = nil
		local fencingNum = nil
		local closeTradeTakeNum = nil
		local otherTakeNum = nil
		local totalIncomeNum = nil
		local totalExpenseNum = nil
		local profitLossNum = nil

		local vendorBuyNum = nil
		local repairNum = nil
		local tPurchaseNum = nil
		local tListingNum = nil
		local closeTradeGiveNum = nil
		local mailGiveNum = nil
		local laundryNum = nil
		local btGuardNum = nil
		local btConfNum = nil
		local rAttNum = nil
		local rMorphsNum = nil
		local rSkillsNum = nil
		local otherGiveNum = nil

		local bWithdrawalNum = nil
		local bDepositNum = nil
		local bChangeNum = nil
		local gbWithdrawalNum = nil
		local gbDepositNum = nil
		local gbChangeNum = nil

		if RAEIH.SavedVars.TSFormat == "Point (.)" then
			lootNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeLoot"])
			vendorSaleNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeVendor"])			
			questNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeQuest"])
			storeNMailNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeMail"])
			fencingNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeFencing"])
			closeTradeTakeNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeCloseTrade"])
			otherTakeNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeOther"])
			totalIncomeNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalIncome"])
			totalExpenseNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalExpense"])
			profitLossNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalIncome"] - RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalExpense"])

			vendorBuyNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseVendor"])
			repairNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRepair"])
			tPurchaseNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseTPurchase"]) 
			tListingNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseTListing"])
			closeTradeGiveNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseCloseTrade"]) 
			mailGiveNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseMail"]) 
			laundryNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseLaundry"])
			btGuardNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseBTGuard"])
			btConfNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseBTConf"])
			rAttNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRAtt"])
			rMorphsNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRMorphs"])
			rSkillsNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRSkills"])
			otherGiveNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseOther"])

			bWithdrawalNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankWithdrawal"])
			bDepositNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankDeposit"])
			gbWithdrawalNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankWithdrawal"])
			gbDepositNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankDeposit"])

			bChangeNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankDeposit"] - RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankWithdrawal"])
			gbChangeNum = RAEIH.ThousandsSeparatorPoint(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankDeposit"] - RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankWithdrawal"])
		else
			lootNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeLoot"])
			vendorSaleNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeVendor"])
			questNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeQuest"])
			storeNMailNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeMail"])
			fencingNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeFencing"])
			closeTradeTakeNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeCloseTrade"])
			otherTakeNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["IncomeOther"])
			totalIncomeNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalIncome"])
			totalExpenseNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalExpense"])
			profitLossNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalIncome"] - RAEIH.SavedVars.ChamberlainLedger[foundIndex]["TotalExpense"])

			vendorBuyNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseVendor"])
			repairNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRepair"])
			tPurchaseNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseTPurchase"]) 
			tListingNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseTListing"])
			closeTradeGiveNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseCloseTrade"])
			mailGiveNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseMail"])
			laundryNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseLaundry"])
			btGuardNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseBTGuard"])
			btConfNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseBTConf"])
			rAttNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRAtt"])
			rMorphsNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRMorphs"])
			rSkillsNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseRSkills"])
			otherGiveNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["ExpenseOther"])

			bWithdrawalNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankWithdrawal"])
			bDepositNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankDeposit"])
			gbWithdrawalNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankWithdrawal"])
			gbDepositNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankDeposit"])

			bChangeNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankDeposit"] - RAEIH.SavedVars.ChamberlainLedger[foundIndex]["BankWithdrawal"])
			gbChangeNum = RAEIH.ThousandsSeparatorComma(RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankDeposit"] - RAEIH.SavedVars.ChamberlainLedger[foundIndex]["GBankWithdrawal"])
		end

		-- PL String

		local titlePL = "Today's Profit/Loss: " .. clr .. tostring(profitLossNum) .. " " .. iconGold .. clrDft .. " » Total Income: " .. clrW .. tostring(totalIncomeNum) .. " " .. iconGold .. clrDft .. " / Total Expense: " .. clrW .. tostring(totalExpenseNum) .. iconGold .. " " .. clrDft

		-- Income String

		local titleIncome = clrN .. "INCOME" .. clrDft
		local loot = "\nLoot : " .. clrW .. tostring(lootNum) .. iconGold .. " " .. clrDft
		local vendorSale = "\nVendor: " .. clrW .. tostring(vendorSaleNum) .. iconGold .. " " .. clrDft
		local quest = "\nQuest:	" .. clrW .. tostring(questNum) .. iconGold .. " " .. clrDft
		local fencing = "\nFencing: " .. clrW .. tostring(fencingNum) .. iconGold .. " " .. clrDft
		local storeNMail = "\n\nGuild Store/Mail/CoD: " .. clrW .. tostring(storeNMailNum) .. iconGold .. " " .. clrDft
		local closeTradeTake = "\nClose Trade: " .. clrW .. tostring(closeTradeTakeNum) .. iconGold .. " " .. clrDft
		local otherTake = "\nOther: " .. clrW .. tostring(otherTakeNum) .. iconGold .. " " .. clrDft

		-- Bank String

		local titleBank = clrN .. "\n\nBANK TRANSACTIONS" .. clrDft
		local bankWith = "\nBank Withdrawal: " .. clrW .. tostring(bWithdrawalNum) .. iconGold .. " " .. clrDft
		local bankDep = "\nBank Deposit: " .. clrW .. tostring(bDepositNum) .. iconGold .. " " .. clrDft
		local bankChange = "\nBank Change: " .. clrBTR .. tostring(bChangeNum) .. iconGold .. " " .. clrDft
		local gbWith = "\n\nGuild Bank Withdrawal: " .. clrW .. tostring(gbWithdrawalNum) .. iconGold .. " " .. clrDft
		local gbDep = "\nGuild Bank Deposit: " .. clrW .. tostring(gbDepositNum) .. iconGold .. " " .. clrDft
		local gbChange = "\nGuild Bank Change: " .. clrGBTR .. tostring(gbChangeNum) .. iconGold .. " " .. clrDft

		-- Expense String

		local titleExpense = clrA .. "EXPENSES" .. clrDft
		local vendorBuy = "\nVendor: " .. clrW .. tostring(vendorBuyNum) .. iconGold .. " " .. clrDft
		local repair = "\nRepair: " .. clrW .. tostring(repairNum) .. iconGold .. " " .. clrDft
		local tPurchase = "\n\nStore/Kiosk(Trade): " .. clrW .. tostring(tPurchaseNum) .. iconGold .. " " .. clrDft
		local tListing = "\nListing(Trade): " .. clrW .. tostring(tListingNum) .. iconGold .. " " .. clrDft
		local closeTradeGive = "\nClose Trade: " .. clrW .. tostring(closeTradeGiveNum) .. iconGold .. " " .. clrDft
		local mailGive = "\n\nMail/CoD: " .. clrW .. tostring(mailGiveNum) .. iconGold .. " " .. clrDft
		local laundry = "\n\nLaundry: " .. clrW .. tostring(laundryNum) .. iconGold .. " " .. clrDft
		local btGuard = "\nBounty(Guard): " .. clrW .. tostring(btGuardNum) .. iconGold .. " " .. clrDft
		local btConf = "\nBounty(Fence): " .. clrW .. tostring(btConfNum) .. iconGold .. " " .. clrDft
		local rAtt = "\n\nRespec(Att.): " .. clrW .. tostring(rAttNum) .. iconGold .. " " .. clrDft
		local rMorphs = "\nRespec(Morphs): " .. clrW .. tostring(rMorphsNum) .. iconGold .. " " .. clrDft
		local rSkills = "\nRespec(Skills): " .. clrW .. tostring(rSkillsNum) .. iconGold .. " " .. clrDft
		local otherGive = "\nOther: " .. clrW .. tostring(otherGiveNum) .. iconGold .. " " .. clrDft

		-- Bottom String

		local titleBT = "Total Records: " .. recordNumByChar

		if recordNumByChar >= 2 then

			local totalRecordedBalance = 0

			for i, slot in pairs(RAEIH.SavedVars.ChamberlainLedger) do
				totalRecordedBalance = totalRecordedBalance + (RAEIH.SavedVars.ChamberlainLedger[i]["TotalIncome"] - RAEIH.SavedVars.ChamberlainLedger[i]["TotalExpense"])
			end

			local dailyChange = RAEIH.Round(totalRecordedBalance / recordNumByChar)
			local yPL = RAEIH.SavedVars.ChamberlainLedger[foundIndex - 1]["TotalIncome"] - RAEIH.SavedVars.ChamberlainLedger[foundIndex - 1]["TotalExpense"]

			local clrDC = nil
			local clrYPL = nil

			if dailyChange > 0 then
				clrDC = clrN
			elseif dailyChange < 0 then
				clrDC = clrA
			else
				clrDC = clrW
			end

			if yPL > 0 then
				clrYPL = clrN
			elseif yPL < 0 then
				clrYPL = clrA
			else
				clrYPL = clrW
			end

			local dcNum = nil
			local yPLNum = nil

			if RAEIH.SavedVars.TSFormat == "Point (.)" then
				dcNum = RAEIH.ThousandsSeparatorPoint(dailyChange)
				yPLNum = RAEIH.ThousandsSeparatorPoint(yPL)
			else
				dcNum = RAEIH.ThousandsSeparatorComma(dailyChange)
				yPLNum = RAEIH.ThousandsSeparatorComma(yPL)
			end

			titleBT = "Total Records: " .. clrD .. recordNumByChar .. clrDft .. " (SV Usage: " .. tostring(RAEIH.Round(recordNumByChar * 1.85)) .. "kb) || Daily Average: " .. clrDC .. tostring(dcNum) .. " " .. iconGold .. clrDft .. " || Yesterday's P/L: " .. clrYPL .. tostring(yPLNum) .. " " .. iconGold .. clrDft
		end				

		RAEIH_Chamberlain_PLST:SetText(titlePL)

		RAEIH_Chamberlain_IncomeST:SetText(titleIncome .. loot .. vendorSale .. quest .. fencing .. storeNMail .. closeTradeTake .. otherTake .. titleBank .. bankWith .. bankDep .. bankChange .. gbWith .. gbDep .. gbChange)		

		RAEIH_Chamberlain_ExpenseST:SetText(titleExpense .. vendorBuy .. repair .. tPurchase .. tListing .. closeTradeGive .. mailGive .. laundry .. btGuard .. btConf .. rAtt .. rMorphs .. rSkills .. otherGive)

		RAEIH_Chamberlain_BottomST:SetText(titleBT)

	elseif foundIndex == nil and RAEIH_Chamberlain ~= nil then
		RAEIH_Chamberlain_PLST:SetText("|cFF3030Waiting for a transaction to update stats...")
		RAEIH_Chamberlain_IncomeST:SetText("")
		RAEIH_Chamberlain_ExpenseST:SetText("")
	end
end

function RAEIH.FormatChamberlain()
	if RAEIH_Chamberlain ~= nil and RAEIH.SavedVars.EnableChamberlain == true then
		local font = LMP:Fetch('font', RAEIH.SavedVars.ChamberlainFont)
		local size = RAEIH.SavedVars.ChamberlainFontSize
		local style = RAEIH.FontStyles[RAEIH.SavedVars.ChamberlainFontStyle]

		local fontFormat = font .. "|" .. size .. "|" .. style

		RAEIH_Chamberlain_TopST:SetFont(fontFormat)
		RAEIH_Chamberlain_PLST:SetFont(fontFormat)
		RAEIH_Chamberlain_IncomeST:SetFont(fontFormat)
		RAEIH_Chamberlain_ExpenseST:SetFont(fontFormat)
		RAEIH_Chamberlain_BottomST:SetFont(fontFormat)

		if RAEIH_Chamberlain_Old ~= nil then
			RAEIH_Chamberlain_OldTopST:SetFont(fontFormat)
			RAEIH_Chamberlain_OldPLST:SetFont(fontFormat)
			RAEIH_Chamberlain_OldIncomeST:SetFont(fontFormat)
			RAEIH_Chamberlain_OldExpenseST:SetFont(fontFormat)
			RAEIH_Chamberlain_OldBottomST:SetFont(fontFormat)
		end
	end
end

function RAEIH.OrganizeChamberlain()
	if RAEIH_Chamberlain ~= nil and RAEIH.SavedVars.EnableChamberlain == true then
		-- Shorten Variables
		local clX = RAEIH.SavedVars.ChamberlainX
		local clY = RAEIH.SavedVars.ChamberlainY
		local clW = RAEIH.SavedVars.ChamberlainW
		local clH = RAEIH.SavedVars.ChamberlainH
		local clBA = RAEIH.SavedVars.ChamberlainBA
		local clIEH = RAEIH.SavedVars.ChamberlainIEH
		-- Work
		RAEIH_Chamberlain:SetDimensions(clW, clH)
		RAEIH_Chamberlain_TopBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_PLBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_IncomeBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_ExpenseBD:SetCenterColor(0, 0, 0, clBA)
		RAEIH_Chamberlain_BottomBD:SetCenterColor(0, 0, 0, clBA)

		if RAEIH_Chamberlain_Old ~= nil then
			RAEIH_Chamberlain_Old:SetDimensions(clW, clH)
			RAEIH_Chamberlain_OldTopBD:SetCenterColor(0, 0, 0, clBA)
			RAEIH_Chamberlain_OldPLBD:SetCenterColor(0, 0, 0, clBA)
			RAEIH_Chamberlain_OldIncomeBD:SetCenterColor(0, 0, 0, clBA)
			RAEIH_Chamberlain_OldExpenseBD:SetCenterColor(0, 0, 0, clBA)
			RAEIH_Chamberlain_OldBottomBD:SetCenterColor(0, 0, 0, clBA)
		end

		RAEIH_Chamberlain_TopBD:SetDimensions(clW, 28)
		RAEIH_Chamberlain_PLBD:SetDimensions(clW, 28)
		RAEIH_Chamberlain_IncomeBD:SetDimensions((clW / 2) - 1, clIEH)
		RAEIH_Chamberlain_ExpenseBD:SetDimensions((clW / 2) - 1, clIEH)
		RAEIH_Chamberlain_BottomBD:SetDimensions(clW, 28)
		if clIEH == 0 then
			RAEIH_Chamberlain_BottomBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain, TOPLEFT, 0, clIEH + 61)
		else
			RAEIH_Chamberlain_BottomBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain, TOPLEFT, 0, clIEH + 62)
		end
		RAEIH_Chamberlain_ExpenseBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain, TOPLEFT, (clW / 2) + 1, 60)

		if RAEIH_Chamberlain_Old ~= nil then
			RAEIH_Chamberlain_OldTopBD:SetDimensions(clW, 28)
			RAEIH_Chamberlain_OldPLBD:SetDimensions(clW, 28)
			RAEIH_Chamberlain_OldIncomeBD:SetDimensions((clW / 2) - 1, clIEH)
			RAEIH_Chamberlain_OldExpenseBD:SetDimensions((clW / 2) - 1, clIEH)
			RAEIH_Chamberlain_OldBottomBD:SetDimensions(clW, 28)
			if clIEH == 0 then
				RAEIH_Chamberlain_OldBottomBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain_Old, TOPLEFT, 0, clIEH + 61)
			else
				RAEIH_Chamberlain_OldBottomBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain_Old, TOPLEFT, 0, clIEH + 62)
			end
			RAEIH_Chamberlain_OldExpenseBD:SetAnchor(TOPLEFT, RAEIH_Chamberlain_Old, TOPLEFT, (clW / 2) + 1, 60)
		end
	end
end

function RAEIH.StartMovingChamberlain()
	RAEIH_Chamberlain:StartMoving()
end

function RAEIH.StopMovingChamberlain()
	RAEIH_Chamberlain:StopMovingOrResizing()
	RAEIH.SavedVars.ChamberlainX = RAEIH_Chamberlain:GetLeft()
	RAEIH.SavedVars.ChamberlainY = RAEIH_Chamberlain:GetTop()
end