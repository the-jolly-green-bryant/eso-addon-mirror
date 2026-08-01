Gold = {}
Gold.Name = "Gold!"
Gold.Version = "Alpha 0.6"
Gold.Author = "N1nja2na"
Gold.savedMoneyReasons = {}


--Variables
local goldEarned = 0
local goldLost = 0
local originalGold = 0
local isStarting = true
local totalGold = 0
local hidden = false
local wm = GetWindowManager()



function Gold.IsLarger(diff)
	return diff > 0
end

function Gold.initReasons()
	moneyReasonsLookup =
	{
		[0] = "From Chest",
		[1] = "Bought/Sold From Merchant",
		[2] = "Withdrew/Sent Via Mail",
		[4] = "Recieved Money From Quest",
		[5] = "Paid During Quest",
		[8] = "Upgraded Backpack",
		[13] = "Picked Up Loot",
		[19] = "Teleport Cost",
		[28] = "Upgraded Mount",
		[29] = "Repaired Armor",
		[31] = "Bought From Guild Store",
		[33] = "Fee For Guild Store",
		[51] = "Deposit To Guild Bank",
		[52] = "Withdrawl From Guild Bank",
		[60] = "Launder",
		[62] = "Lockbox Loot",
		[63] = "Sold To Fence"

	}
	moneyReasons =
	{

	}

	for key, value in pairs(moneyReasonsLookup) do
		if key == 1 then
			moneyReasons["Bought From Merchant"] = 0
			moneyReasons["Sold To Merchant"] = 0
		elseif key == 2 then
			moneyReasons["Sent Via Mail"] = 0
			moneyReasons["Withdrew From Mail"] = 0
		else
			moneyReasons[value] = 0
		end
  end
end


function Gold.manageMoneyReasons_Loop(reason, diff)

	local key = ""
	local isLarger = Gold.IsLarger(diff)
	if diff == 0 or reason == 43 or reason == 42 then
		return -1 --No change
	end


	for k, v in pairs(moneyReasonsLookup) do
		if reason == k then

			if k == 1 then
				if isLarger then
					key = "Sold To Merchant"
				else
					key = "Bought From Merchant"
				end
			elseif k == 2 then
				if isLarger then
					key = "Withdrew From Mail"
				else
					key = "Sent Via Mail"
				end
			else
				key = v
			end
		end
	end
	if key == "" then return 0 end
	moneyReasons[key] = moneyReasons[key] + diff --Add the new amount to the particular money reason
	Gold.savedMoneyReasons[key] = Gold.savedMoneyReasons[key] + diff
end


function Gold.SetUpCurrencyText( text, textToDisplay, offsetX, offsetY, AnchorPoint, scale, color) --AnchorPoint is optional param

	if scale == nil then scale = 0.8 end

	if color == nil then color = {1, 1, 1, 1} end


	text:SetColor(color[1], color[2], color[3], color[4])
	text:SetFont("ZoFontAlert")
	text:SetScale(scale)
	text:SetWrapMode(ELLIPSIS)
	text:SetDrawLayer(1)
	text:SetText(textToDisplay)
	if AnchorPoint == nil then
		text:SetAnchor(LEFT, parent, LEFT, (50 + offsetX), (-80 + offsetY))
	else
		text:SetAnchor(AnchorPoint, parent, AnchorPoint, (offsetX), (-80 + offsetY))
	end

	return text
end
function SetToolTip(ctrl, text)
    ctrl:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, TOP, text)
    end)
    ctrl:SetHandler("OnMouseExit", function(self)
        ZO_Tooltips_HideTextTooltip()
    end)
end

function Gold.SetUpSavedText()


	if lblTitle == nil then
		lblTitle = wm:CreateControl("lblTitle", ZO_InventoryWalletListContents, CT_LABEL)
		lblReasons = wm:CreateControl("lblReasons", ZO_InventoryWalletListContents, CT_LABEL)
		lblChange = wm:CreateControl("lblChanges", ZO_InventoryWalletListContents, CT_LABEL)
	end


	--TITLE--
	local title = "********************Gold!********************"
	lblTitle = Gold.SetUpCurrencyText(lblTitle, title, 15, -20, CENTER, 1, {1,1,0,1})
	--*****--

	--REASONS--
	local reasons = Gold.reasonsToString(moneyReasons)
	lblReasons = Gold.SetUpCurrencyText(lblReasons, "", 0, 175, nil, 0.6)
	--*******--
	SetToolTip(gold, "Testing 123")
	--CHANGE--
	if Gold.savedGoldEarned == nil then
		Gold.savedGoldEarned = 0
		Gold.savedTotalGold = 0
		Gold.savedGoldLost = 0
	end
	lblChange = Gold.SetUpCurrencyText(lblChange, "", 240, 25, nil, 0.6)
	--******--

end


function Gold.isTextHidden()

end

SLASH_COMMANDS["/ih"] = Gold.isTextHidden

--Functions
function Gold.updateMoney(eventCode, newMoney, oldMoney, reason)

	local diff = newMoney - oldMoney --Get the change

	local isReasonOkay = Gold.manageMoneyReasons_Loop(reason, diff) --is this a reason we want to do things with?
	if isReasonOkay == -1 then return end --no? Then return
	--*****************************************
	-- DEBUG PRINT FOR ANY NEW REASON I FIND
				if isReasonOkay == 0 then d(string.format("Transaction Code: %s", reason))end
	--*****************************************



 	if diff > 0 then --Is the change positive?
		goldEarned = goldEarned + diff --You've gained
	end
	if diff < 0 then --Is the change negative?
		goldLost = goldLost - diff --You've lost
	end
	totalGold = totalGold + diff --sum the total with the difference
	Gold.updateSavedMoney(diff)
	Gold.updateText() --Update the ui
end

function Gold.updateSavedMoney(diff)

	if diff > 0 then
		Gold.savedGoldEarned = Gold.savedGoldEarned + diff
	elseif diff < 0 then
		Gold.savedGoldLost = Gold.savedGoldLost - diff

	end
	Gold.savedTotalGold = Gold.savedTotalGold + diff
end


function Gold.reasonsToString(T)
	local details = ""

	--Print out the details
	for key, value in pairs(T) do
		details = details .. string.format("%s: %s\n", key, comma_value(value) )
	end
	return details

end

function Gold.basicInfoToString(earned, lost, original, total, gain_loss)
	return string.format("Gold Earned: %s -- Gold Lost: %s\nOriginal Gold: %s -- New Total: %s\nProfit/Loss: %s", comma_value(earned), comma_value(lost), comma_value(original), comma_value(total), comma_value(gain_loss))
end
function Gold.updateText()

	--Set the scale for the gold window
	gold:SetScale(0.6)
	--Set the gold window text
	--gold:SetText(string.format("Gold Earned: %s -- Gold Lost: %s\nOriginal Gold: %s -- New Total: %s\nProfit/Loss: %s", comma_value(goldEarned), comma_value(goldLost), comma_value(originalGold), comma_value(originalGold + totalGold), comma_value(totalGold)))
	gold:SetText(Gold.basicInfoToString(goldEarned, goldLost, originalGold, originalGold + totalGold, totalGold))
	--Set the scale for the details text
	goldDetails:SetScale(0.6)
	--Calculate the height of the details window
	local height = TableLength(moneyReasons) * 24.25
	--Set the details window height
	GoldDetailedTracker:SetHeight(height)

	--Details variable
	local details = Gold.reasonsToString(moneyReasons)
	local savedDetails = Gold.reasonsToString(Gold.savedMoneyReasons)
	local savedBasic = Gold.basicInfoToString(Gold.savedGoldEarned, Gold.savedGoldLost, Gold.savedOriginalGold, Gold.savedOriginalGold + Gold.savedTotalGold, Gold.savedTotalGold)


	--Set Text
	goldDetails:SetText(details)
	lblReasons:SetText(savedDetails)
	lblChange:SetText(savedBasic)
	--Save Details
	Gold.Save()
end

function TableLength(t)
	local length = 0
	for i in pairs(t) do length = length + 1 end
	return length
end



function Gold.SetAlpha(number, control)
	local bg = control:GetChild(1)
	local hideButton = control:GetChild(2)
	bg:SetAlpha(number)
end

function OnAddOnLoaded(eventCode, addOnName)

	if( addOnName == "Gold") then

		EVENT_MANAGER:UnregisterForEvent("Gold!", EVENT_ADD_ON_LOADED)
		zo_callLater(function()Gold.beginInit()end, 2000)


	end
end

function Gold.StopMoving(control)
	Gold.accountVariables["left"] = control:GetLeft()
	Gold.accountVariables["top"] = control:GetTop()

d(control:GetLeft())
d(control:GetRight())

end

function Gold.Save()
	Gold.savedVariables["originalGold"] = Gold.savedOriginalGold
	Gold.savedVariables["moneyReasons"] = Gold.savedMoneyReasons
	Gold.savedVariables["goldEarned"] = Gold.savedGoldEarned
	Gold.savedVariables["goldLost"] = Gold.savedGoldLost
	Gold.savedVariables["totalGold"] = Gold.savedTotalGold
end

function Gold.Load()
	Gold.savedOriginalGold = 0
	Gold.savedGoldEarned = 0
	Gold.savedGoldLost = 0
	Gold.savedTotalGold = 0

	--Get the saved data
	Gold.savedVariables = ZO_SavedVars:New("GoldData", 0.41, nil, nil)
	Gold.accountVariables = ZO_SavedVars:NewAccountWide("GoldData", 1)
	--Is there any saved data?
	if not( Gold.savedVariables["moneyReasons"] == nil) then
		--Set the reasons to the saved reasons
		Gold.savedMoneyReasons = Gold.savedVariables["moneyReasons"]
	else
		Gold.savedMoneyReasons = moneyReasons
	end

	if not( Gold.savedVariables["originalGold"] == nil) then
		Gold.savedOriginalGold = Gold.savedVariables["originalGold"]
		Gold.savedGoldEarned = Gold.savedVariables["goldEarned"]
		Gold.savedGoldLost = Gold.savedVariables["goldLost"]
		Gold.savedTotalGold = Gold.savedVariables["totalGold"]
	else
		Gold.savedOriginalGold = originalGold
	end

	--Restore Gold positon
	local left = 0
	local top = 0

	if( Gold.accountVariables["left"] == nil) then
		Gold.StopMoving(gold)
	end

	left = Gold.accountVariables["left"]
	top = Gold.accountVariables["top"]

	--gold:ClearAnchors()
	GoldTracker:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)


end


function Gold.beginInit()
	--[[**********************************************************
		-Sets up everything required for Gold! to work correctly
	************************************************************]]


	--Hide the details view
	GoldDetailedTracker:SetHidden(true)
	--Set the orginal gold
	originalGold = Gold.getGold()
	--Set up default values for the reasons
	Gold.initReasons()
	--Load the saved data if any
	Gold.Load()
	Gold.SetUpSavedText()
	--Update the text
	Gold.updateText()
	--Set up Slash Commands
	Gold.initCommands()

	--Register for Money Update event
	EVENT_MANAGER:RegisterForEvent("Gold!", EVENT_MONEY_UPDATE, Gold.updateMoney ) --Anytime the gold amount changes, update it

	--Display welcome messaage
	d("***********************\nWelcome to Gold!\nFor help, type /goldhelp\n***********************")


end


function Gold.ReloadUIShortHand()
	StartChatInput("/reloadui")
	CHAT_SYSTEM:SubmitTextEntry()
end

function Gold.Test1()
	d(moneyReasonsTest)
end

SLASH_COMMANDS["/test1"] = Gold.Test1
SLASH_COMMANDS["/rr"] = Gold.ReloadUIShortHand
SLASH_COMMANDS["/wallettest"] = Gold.WalletPieceTest


function Gold.toggleGoldWindow() --Toggles the ui
	hidden = not hidden --false = true; true = false
	GoldTracker:SetHidden(hidden) --Set hidden to whichever
end

function Gold.toggleGoldDetailsWindow()
	GoldDetailedTracker:SetHidden(not GoldDetailedTracker:IsHidden())
end


function Gold.getGold() --Get the current gold
	return GetCurrentMoney()
end

function comma_value(amount) --found at http://lua-users.org/wiki/FormattingNumbers
	  local formatted = amount
	  while true do
	    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
	    if (k==0) then
	      break
	    end
	  end
	  return formatted
end

--Bindings
ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_UI", "Toggle UI")
ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_DETAILS", "Toggle Detailed UI")


--Events

EVENT_MANAGER:RegisterForEvent("Gold!", EVENT_ADD_ON_LOADED, OnAddOnLoaded ) --On start




function Gold.initCommands()
	goldCommands = {}
	goldCommands["/gold.save"] = Gold.Save
	goldCommands["/gold.load"] = Gold.Load
	goldCommands["/gold.toggleui"] = Gold.toggleGoldWindow
	goldCommands["/gold.toggledetails"] = Gold.toggleGoldDetailsWindow
	goldCommands["/gold.reinit"] = Gold.beginInit
	goldCommands["/goldhelp"] = Gold.displayCommands



	for k,v in pairs(goldCommands) do
		SLASH_COMMANDS[k] = v
	end
end

function Gold.displayCommands()
	d("Gold! Commands")
	d("-----------------")
	for key, value in pairs(goldCommands) do d(key) end
	d("-----------------")
end
