local IE = InventoryExtensions
local EM = EVENT_MANAGER

IE.MoneyTracker = {}

local function UpdateMoneyControlText()
    local incomeControl = IE.UI.Controls.IncomeLabel
    local value = IE.SavedVars.dialyGoldIncome
    incomeControl:SetText("|c008000"..value.."|r |t19:19:esoui/art/currency/currency_gold_32.dds|t")
end

local function OnMoneyUpdate(eventCode, newMoney, oldMoney, reason)
    -- Only record incomes
    if reason ~= CURRENCY_CHANGE_REASON_BUYBACK and (newMoney < oldMoney) or reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL or reason == CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL then return end

    local newIncome = newMoney - oldMoney

    IE.SavedVars.dialyGoldIncome = newIncome + IE.SavedVars.dialyGoldIncome
    UpdateMoneyControlText()
end

local function InitDialyGoldIncome()
    -- Check if we need to reset
    local vars = IE.SavedVars
	local day=math.floor(GetDiffBetweenTimeStamps(GetTimeStamp(),1517464800)/86400)
    if (vars.lastDialyGoldIncomeDay ~= day) then
        IE.SavedVars.lastDialyGoldIncomeDay = day
        IE.SavedVars.dialyGoldIncome = 0
    end

    -- Initialize the UI
    local money = ZO_PlayerInventoryInfoBarMoney
    local width = money:GetWidth()
    local height = money:GetHeight()
    local va = money:GetVerticalAlignment()
    local ha = money:GetHorizontalAlignment()

    IE.UI.Controls.IncomeLabel = IE.UI.Label(IE.name.."_PlayerInventoryInfoBarIncome", ZO_PlayerInventoryInfoBarMoney, {width, height}, {TOPRIGHT,BOTTOMRIGHT,0,0}, "ZoFontGameLarge", nil, {ha,va}, "0")
    UpdateMoneyControlText()

    -- Register for gold income event
    EM:RegisterForEvent(IE.name .. "MoneyUpdate_Event", EVENT_MONEY_UPDATE, OnMoneyUpdate)
    -- TODO: Fix money tracker shown in bank deposit view
end

function IE.MoneyTracker.Init()
    InitDialyGoldIncome()
end
