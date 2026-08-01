-------------------------------------------------------------------------------
-- Currency Tracker Module
-- Tracks daily currency gains and displays them in the inventory wallet.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Localized Globals
-------------------------------------------------------------------------------
local ZO_CurrencyControl_FormatAndLocalizeCurrency = ZO_CurrencyControl_FormatAndLocalizeCurrency
local CURRENCY_CHANGE_REASON_PLAYER_INIT = CURRENCY_CHANGE_REASON_PLAYER_INIT
local CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL = CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL
local CURRENCY_CHANGE_REASON_BANK_DEPOSIT = CURRENCY_CHANGE_REASON_BANK_DEPOSIT
local RIGHT = RIGHT

local GAFE = GroupActivityFinderExtensions

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local CURRENCY_LABEL_WIDTH = 70
local CURRENCY_LABEL_HEIGHT = 20
local CURRENCY_LABEL_X_OFFSET = -6
local CURRENCY_LABEL_Y_OFFSET = 17
local CURRENCY_POSITIVE_COLOR = "|c32CD32"
local CURRENCY_NEGATIVE_COLOR = "|cB21818"
local CURRENCY_COLOR_END = "|r"

-------------------------------------------------------------------------------
-- Module Declaration
-------------------------------------------------------------------------------
local CurrencyTracker = {}

-------------------------------------------------------------------------------
-- Private Functions
-------------------------------------------------------------------------------

--- Checks if daily reset occurred and resets tracker if needed.
local function CheckDailyReset()
  local today = LibPanicida.Utils.GetDailyResetDay()
  local tracker = GAFE.SavedVars.currencyTracker

  if tracker.day ~= today then
    tracker.day = today
    tracker.currencies = {}
  end
end

-------------------------------------------------------------------------------
-- Public Functions
-------------------------------------------------------------------------------

--- Initializes the currency tracker (hooks wallet UI).
function CurrencyTracker.Init()
  CheckDailyReset()

  local baseSetUpEntry = INVENTORY_WALLET.SetUpEntry
  INVENTORY_WALLET.SetUpEntry = function(self, control, data)
    baseSetUpEntry(self, control, data)

    local value = GAFE.SavedVars.currencyTracker.currencies[data.currencyType] or 0
    local text = ZO_CurrencyControl_FormatAndLocalizeCurrency(value)

    if value > 0 then
      text = CURRENCY_POSITIVE_COLOR .. text .. CURRENCY_COLOR_END
    elseif value < 0 then
      text = CURRENCY_NEGATIVE_COLOR .. text .. CURRENCY_COLOR_END
    end

    local labelName = control:GetName() .. "_GAFE_CurrencyTracker_" .. data.currencyType
    LibPanicida.Controls.Label(
      labelName,
      control,
      { CURRENCY_LABEL_WIDTH, CURRENCY_LABEL_HEIGHT },
      { RIGHT, control, RIGHT, CURRENCY_LABEL_X_OFFSET, CURRENCY_LABEL_Y_OFFSET },
      "ZoFontGameSmall",
      nil,
      { 2, 2 },
      text
    )
  end
end

--- Called when currency changes.
--- @param currencyType number The type of currency that changed
--- @param newAmount number The new currency amount
--- @param oldAmount number The previous currency amount
--- @param reason number The reason for the currency change
function CurrencyTracker.OnCurrencyUpdate(currencyType, newAmount, oldAmount, reason)
  local netIncome = newAmount - oldAmount

  if netIncome <= 0
      or reason == CURRENCY_CHANGE_REASON_PLAYER_INIT
      or reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL
      or reason == CURRENCY_CHANGE_REASON_BANK_DEPOSIT
  then
    return
  end

  local currencies = GAFE.SavedVars.currencyTracker.currencies
  currencies[currencyType] = (currencies[currencyType] or 0) + netIncome
end

-------------------------------------------------------------------------------
-- Module Registration
-------------------------------------------------------------------------------
GAFE.CurrencyTracker = CurrencyTracker
