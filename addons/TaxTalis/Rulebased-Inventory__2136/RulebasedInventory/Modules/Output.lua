-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Output.lua
-- File Description: This file contains string helper function the functions to
--                   create and print feedback for the user about actions a task took
-- Load Order Requirements: before Task
-- 
-----------------------------------------------------------------------------------

local RbI = RulebasedInventory

-- imports
local utils = RbI.utils
local execEnv = RbI.Import(RbI.executionEnv)

local messages = {}	-- 1: TestRun, 2: Amount, 3: ItemLink, 4: Price, 5: ItemData
messages.Junk = 		"<<1>> Junked <<2>>x <<3>>"
messages.UnJunk = 		"<<1>> UnJunked <<2>>x <<3>>"
messages.Launder = 		"<<1>> Laundered <<2>>x <<3>>"
messages.Destroy = 		"<<1>> Destroyed <<2>>x <<3>>"
messages.Deconstruct = 	"<<1>> Deconstructed <<2>>x <<3>>"
messages.Extract = 		"<<1>> Extracted <<2>>x <<3>>"
messages.Refine = 		"<<1>> Refined <<2>>x <<3>>"
messages.BagToBank = 	"<<1>> Stored <<2>>x <<3>> <<5>>"
messages.BankToBag = 	"<<1>> Received <<2>>x <<3>> <<5>>"
messages.Notify = 		"<<1>> Found <<2>>x <<3>> <<5>>"
messages.Sell = 		"<<1>> Sold <<2>>x <<3>> for <<4>>"
messages.Buy =  		"<<1>> Bought <<2>>x <<3>>"
messages.Fence = 		"<<1>> Fenced <<2>>x <<3>> for <<4>>"
messages.CraftToBag = 	"<<1>> Fetched <<2>>x <<3>>"
messages.Use   = 		"<<1>> Used <<3>>"
local fcoisMark = "FCOISMark"
messages.FCOISMark =   "<<1>> Marked <<3>> <<6>>"
local fcoisUnmark = "FCOISUnmark"
messages.FCOISUnmark =   "<<1>> Unmarked <<3>> <<6>>"

messages.RuleTest = 	"<<1>> Rule applies to <<3>>"

messages.Summary = 		"<<1>> Total: <<2>> items for <<4>>"
messages.Final = 		"<<1>> <<2>> <<3>>"
messages.Start = 		"<<1>> <<2>> <<3>>"

for postFixName in pairs(RbI.data.getHomeBanks()) do
	messages['BagToHomebank'..postFixName] = messages['BagToBank']
	messages['Homebank'..postFixName..'ToBag'] = messages['BankToBag']
end

-- start/final: testrun, task/ruleName, message
function RbI.PrintMessage(message, testrun, amount, itemLink, price, itemData, additional)
	local test = ''
	if(testrun) then 
		test = 'TEST: '
	end
	if(price ~= nil) then
		price = ZO_Currency_FormatPlatform(CURT_MONEY, price, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
	end
	RbI.out.msg(message
		,test
		,amount
		,itemLink
		,price
		,itemData
		,additional)
end

local output = {}
local function getBaseMessageName(messageName)
	if(utils.startsWith(messageName, fcoisMark)) then
		messageName = fcoisMark
	elseif(utils.startsWith(messageName, fcoisUnmark)) then
		messageName = fcoisUnmark
	end
	return messageName
end
local function getQueue(queueName, messageName, testrun)
	if(messageName) then
		messageName = getBaseMessageName(messageName)
		local queue = output[queueName] or {}
		output[queueName] = queue
		queue.messageName = messageName
		queue.testrun = testrun
	end
	return output[queueName]
end

function RbI.AddMessageToQueueStart(queueName, messageName, testrun, message)
	local queue = getQueue(queueName, messageName, testrun)
	if(not queue.start) then
		queue.start = true
		if((testrun or RbI.account.settings.taskStartOutput) and RbI.allowAction["StartMessage"]) then
			RbI.PrintMessage(messages.Start, testrun, queueName, 'started...')
		end
	end
end
function RbI.AddMessageToQueue(queueName, messageName, testrun, itemLink, amount, haveToVerify)
	local queue = getQueue(queueName, messageName, testrun)
	local msgList
	if(haveToVerify) then
		msgList = queue.messageListToVerify or {}
		queue.messageListToVerify = msgList
	else
		msgList = queue.messageList or {}
		queue.messageList = msgList
	end
	if(amount ~= nil) then
		msgList[itemLink] = (msgList[itemLink] or 0) + amount
	else
		msgList[itemLink] = true
	end
end
function RbI.VerifyAllPriorMessages(queueName)
	local queue = getQueue(queueName)
	if(queue) then
		local messageList = queue.messageList or {}
		queue.messageList = messageList
		for itemLink, amount in pairs(queue.messageListToVerify or {}) do
			messageList[itemLink] = (messageList[itemLink] or 0) + amount
		end
		queue.messageListToVerify = nil
	end
end
function RbI.AddMessageToQueueFinal(queueName, messageName, testrun, message, dismissVerifiedMessages, success)
	local queue = getQueue(queueName, messageName, testrun)
	queue.final = message
	queue.success = success
	if(dismissVerifiedMessages) then
		queue.messageListToVerify = nil
	end
end

local function getPrice(itemLink)
	return execEnv.price(itemLink, false, true)
end

function RbI.PrintQueue(queueName)
	local queue = output[queueName]
	if(queue ~= nil) then
		local testrun = queue.testrun
		local finalMessage = queue.final
		local finalSuccess = queue.success
		local messageName = queue.messageName
		local messageList = queue.messageList or {}
		queue.final = nil
		queue.start = nil
		queue.testrun = nil
		queue.messageName = nil
		queue.messageList = nil

		local sold = 0 -- sum of value
		local total = 0 -- sum of amount
		for itemLink, amount in pairs(messageList) do
			local sum = 0
			if(messageName ~= 'RuleTest') then
				sum = GetItemLinkValue(itemLink) * amount
			end
			if((RbI.account.settings.taskActionOutput or testrun) and RbI.allowAction["ActionMessage"]) then
				local itemData = ""
				if(messageName ~= 'RuleTest') then
					local fontsize = CHAT_SYSTEM.GetFontSizeFromSetting()
					-- show vouchers on all messages which are designed to show additional data
					local vouchers = execEnv.vouchers(itemLink)
					if(vouchers > 0) then
						if(itemData ~= "") then
							itemData = itemData ..", "
						end
						itemData = itemData .. ZO_Currency_FormatPlatform(CURT_WRIT_VOUCHERS, vouchers, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
					end

					local backpack, bank, craftbag = GetItemLinkStacks(itemLink)
					if(craftbag > 0) then
						if(itemData ~= "") then
							itemData = itemData ..", "
						end
						itemData = itemData .. craftbag .. zo_iconTextFormat("EsoUI/Art/Tooltips/icon_craft_bag.dds", fontsize, fontsize)
					end
					if(bank > 0) then
						if(itemData ~= "") then
							itemData = itemData ..", "
						end
						itemData = itemData .. bank .. zo_iconTextFormat("EsoUI/Art/Tooltips/icon_bank.dds", fontsize, fontsize)
					end
					if(backpack > 0) then
						if(itemData ~= "") then
							itemData = itemData ..", "
						end
						itemData = itemData .. backpack .. zo_iconTextFormat("EsoUI/Art/Tooltips/icon_bag.dds", fontsize, fontsize)
					end

					-- show extendet data only on notify message
					if(messageName == "Notify") then
						local price = getPrice(itemLink)
						if(price > 0) then
							if(itemData ~= "") then
								itemData = itemData ..", "
							end
							local UNIT_PRICE_PRECISION = 0.01
							itemData = itemData .. ZO_Currency_FormatPlatform(CURT_MONEY, zo_roundToNearest(price, UNIT_PRICE_PRECISION), ZO_CURRENCY_FORMAT_AMOUNT_ICON)
						end
					end

					if(itemData ~= "") then
						itemData = "(" .. itemData ..")"
					end
				end
				local additional = ""
				if(utils.startsWith(messageName, fcoisMark) or utils.startsWith(messageName, fcoisUnmark)) then
					local iconId = queueName:sub(queueName:find(":")+1)
					additional = " with "..RbI.fcois.getNameById(iconId)
				end
				local message = messages[messageName]
				if(message == nil) then error("Message for '"..messageName.."' can't be found!") end
				RbI.PrintMessage(message, testrun, amount, itemLink, sum, itemData, additional)
			end
			if(messageName ~= 'RuleTest') then
				total = total + amount
				sold = sold + sum
			end
		end

		if(RbI.account.settings.taskSummaryOutput and (messageName == 'Sell' or messageName == 'Fence') and total > 0 and RbI.allowAction["SummaryMessage"]) then
			RbI.PrintMessage(messages.Summary, testrun, total, nil, sold)
		end

		if((testrun or RbI.account.settings.taskFinishOutput or finalSuccess==false) and finalMessage ~= nil and RbI.allowAction["FinalMessage"]) then
			RbI.PrintMessage(messages.Final, testrun, queueName, finalMessage)
		end

		output[queueName] = nil
	end
end

RbI.out = {
	msg = function(msg, ...)
		local colorTag = "|c"..RbI.account.settings.outputcolor
		msg = "[RbI] "..zo_strformat(msg, ...)
		msg = msg:gsub("|c", "|#|c"):gsub("|r", "|r"..colorTag):gsub("|#", "|r")
		CHAT_ROUTER:AddSystemMessage(colorTag..msg.."|r")
	end,
	notify = function(amount, itemLink)
		local price = getPrice(itemLink)
		local itemData = ""
		if(price > 0) then
			if(itemData ~= "") then
				itemData = itemData ..", "
			end
			itemData = itemData .. ZO_Currency_FormatPlatform(CURT_MONEY, price, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
		end
		if(itemData ~= "") then
			itemData = "(" .. itemData ..")"
		end
		RbI.PrintMessage(messages.Notify, false, amount, itemLink, price, itemData)
	end
}

local function getErrorTable(rule, err)
	local m = {}
	if(err.ruleName ~= nil) then
		if(err.taskName) then
			m[#m + 1] = 'An error occured in rule ' .. err.ruleName .. ' (within task: '..err.taskName..'):'
		else
			m[#m + 1] = 'An error occured in rule ' .. err.ruleName .. ':'
		end
	end
	if (err.message == nil) then -- this includes type(err) == 'string'
		m[#m + 1] = '>>> Unexpected RbI error in version '..RbI.addonVersion..' <<< If it\'s a RbI-related error please report this to:\n'..RbI.websiteComments..' or\n'..RbI.discord
		if(type(err) == 'string') then
			m[#m + 1] = ''
			m[#m + 1] = err
		end
	else
		m[#m + 1] = '|cff0000'..err.message..'|r'
	end
	if(err.ruleContent ~= nil) then
		m[#m + 1] = '\nContent:'
		m[#m + 1] = err.ruleContent
	end
	if(err.stackTrace ~= nil and #err.stackTrace>0) then
		m[#m + 1] = "\nStacktrace:"
		if(rule ~= nil) then
			m[#m + 1] = "Rule: "..rule.GetName() -- initiator
		end
		for _, trace in pairs(err.stackTrace) do
			-- unpack table argument like 'defaultchars'
			local traceArguments = trace[2]
			if(#traceArguments>0 and type(traceArguments[1])=="table") then
				traceArguments = traceArguments[1]
			end
			m[#m + 1] = "=> "..trace[1].."("..RbI.utils.ArrayValuesToString(traceArguments)..")"
		end
	end
	if (err.addition) then
		m[#m + 1] = "\n"..err.addition
	end
	m[#m + 1] = "\n".."Settings:"
	m[#m + 1] = "CaseSensitivity: "..tostring(RbI.account.settings.casesensitiverules)
	m[#m + 1] = "HomebankingMode: "..tostring(RbI.account.settings.homebankingMode)
	m[#m + 1] = "StartupItemcheck: "..tostring(RbI.account.settings.startupitemcheck)
	return m
end

function RbI.ConstantErrorHandler(err)
	local errorTable
	if(type(err) == "string") then
		RbI.PrintToClipBoard(err, 'Constant Inspector')
	else -- should be table
		RbI.PrintToClipBoard(getErrorTable(nil, err), 'Constant Inspector')
	end
end

-- Default error handling
function RbI.RuleErrorHandler(rule, err)
	RbI.PrintToClipBoard(getErrorTable(rule, err), 'Rule Inspector')
end

-- static key
function RbI.dataKeyFixed(str)
	if(str == nil) then return end
	return "|c03f8fc"..str.."|r"
end

-- language dependent data key
function RbI.dataKeyLD(str)
	if(str == nil) then return end
	return "|cfcba03"..str.."|r"
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Clipboard -----------------------------------------------------------------
------------------------------------------------------------------------------

local clipBoardWindow
local clipBoardTextBox
local clipBoardTitle
local clipBoardFooter

function RbI.InitializeOutput()
    clipBoardWindow = RulebasedInventory_Clipboard
	clipBoardTitle = RulebasedInventory_ClipboardTitle
	clipBoardFooter = RulebasedInventory_ClipboardFooter
    clipBoardTextBox = RulebasedInventory_ClipboardOutputBox
    clipBoardTextBox:SetMaxInputChars(100000)
	clipBoardTextBox:SetAllowMarkupType(ALLOW_MARKUP_TYPE_COLOR_ONLY) -- ALLOW_MARKUP_TYPE_COLOR_ONLY, ALLOW_MARKUP_TYPE_NONE
    clipBoardTextBox:SetHandler("OnFocusLost", function()
        clipBoardWindow:SetHidden(true)
    end)
end

local lpad = function(str, len, char)
	return str .. '\n' .. string.rep(char or ' ', len - #str - 1)
end

function RbI.PrintToClipBoard(text, title, footer)
	if(type(text) == "table") then text = table.concat(text, '\n') end
	-- sometimes the clipboard will not show any content, when using ALLOW_MARKUP_TYPE_ALL
    -- with enough normal characters
	clipBoardTitle:SetText(title or "")
	clipBoardFooter:SetText(footer or "(To close: Press Escape or click outside the window)")
	clipBoardTextBox:SetText(lpad(text, text:len()+1000))
	clipBoardWindow:SetHidden(false)
	clipBoardTextBox:SetCursorPosition(0) -- scroll to top
    clipBoardTextBox:TakeFocus()
end
