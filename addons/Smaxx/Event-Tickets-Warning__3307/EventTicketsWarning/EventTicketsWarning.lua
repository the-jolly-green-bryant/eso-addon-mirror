EventTicketsWarning = {}
EventTicketsWarning.Threshold = 12

function EventTicketsWarning.TryGetMaxCurrencyWarningText(self, rewardType, rewardAmount)
  local native = EventTicketsWarning.OriginalHook(self, rewardType, rewardAmount)
  if native then
    return native
  end
  if rewardType == REWARD_TYPE_EVENT_TICKETS then
    if GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT) + rewardAmount > EventTicketsWarning.Threshold then
      return '|cff0000' .. zo_strformat(SI_QUEST_REWARD_MAX_CURRENCY_ERROR, GetCurrencyName(CURT_EVENT_TICKETS)) .. '|r'
    end
  end
end

function EventTicketsWarning.OnAddOnLoaded(event, addonName)
  if addonName == 'EventTicketsWarning' then
    EventTicketsWarning.OriginalHook = ZO_SharedInteraction.TryGetMaxCurrencyWarningText
    ZO_SharedInteraction.TryGetMaxCurrencyWarningText = EventTicketsWarning.TryGetMaxCurrencyWarningText
  end
end

EVENT_MANAGER:RegisterForEvent('EventTicketsWarning', EVENT_ADD_ON_LOADED, EventTicketsWarning.OnAddOnLoaded)
