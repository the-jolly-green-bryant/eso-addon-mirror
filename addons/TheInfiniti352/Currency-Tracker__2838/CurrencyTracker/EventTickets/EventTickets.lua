--Event Tickets tracking file
CurrencyTracker.EventTickets = {}

function CurrencyTracker.EventTickets.Initialize()

  if(not CurrencyTracker.savedVariables.eventTickets.tracking) then
    GUI_EventTicketsWarning:SetHidden(true)
    return
  end

  CurrencyTracker.EventTickets.OnAmountThresholdChanged()

  CurrencyTracker.EventTickets.ShowEventTicketsWarning(CurrencyTracker.EventTickets.displayWarning)

  --Event tickets warning restore
  local left = CurrencyTracker.savedVariables.eventTickets.GUILeft
  local top = CurrencyTracker.savedVariables.eventTickets.GUITop

  GUI_EventTicketsWarning:ClearAnchors()
  GUI_EventTicketsWarning:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function CurrencyTracker.EventTickets.OnCurrencyUpdate(currencyLocation, newAmount, oldAmount, reason)
  --Detects if event tickets quantity >= threshold
  CurrencyTracker.EventTickets.displayWarning = (newAmount >= CurrencyTracker.savedVariables.eventTickets.amountThreshold)
  CurrencyTracker.EventTickets.ShowEventTicketsWarning(true)
end

function CurrencyTracker.EventTickets.OnAmountThresholdChanged()
  --Update the message along to the treshold
  CurrencyTracker.EventTickets.displayWarning = (GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT) >= CurrencyTracker.savedVariables.eventTickets.amountThreshold )
end

function CurrencyTracker.EventTickets.ShowEventTicketsWarning(show)
  local display = show and (CurrencyTracker.EventTickets.displayWarning or CurrencyTracker.savedVariables.eventTickets.alwaysDisplay)
  GUI_EventTicketsWarning:SetHidden(not display)
  if(display) then
    GUI_EventTicketsWarningText:SetText(GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT))
  end
end

function CurrencyTracker.EventTickets.OnIndicatorMoveStopEventTicketsWarning()
  CurrencyTracker.savedVariables.eventTickets.GUILeft = GUI_EventTicketsWarning:GetLeft()
  CurrencyTracker.savedVariables.eventTickets.GUITop = GUI_EventTicketsWarning:GetTop()
end
