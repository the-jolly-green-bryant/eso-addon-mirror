BuffTimers.debug = false

function BuffTimers:DebugColor(color, text)
  return ZO_ColorDef:New(color):Colorize(text)
end

function BuffTimers:DebugColorWhite(text)
  return self:DebugColor('ffffff', text)
end

function BuffTimers:DebugEvent(changeType, effectName, beginTime, endTime, abilityId)
  if BuffTimers.debug then
    local message
    if     changeType == EFFECT_RESULT_GAINED       then
      message = self:DebugColorWhite('[Gained]   ')
    elseif changeType == EFFECT_RESULT_FADED        then
      message = self:DebugColorWhite('[Faded]    ')
    elseif changeType == EFFECT_RESULT_UPDATED      then
      message = self:DebugColorWhite('[Updated]  ')
    elseif changeType == EFFECT_RESULT_FULL_REFRESH then
      message = self:DebugColorWhite('[Refresh]  ')
    elseif changeType == EFFECT_RESULT_TRANSFER     then
      message = self:DebugColorWhite('[Transfer] ')
    else
      message = self:DebugColorWhite('[UNKNOWN]  ')
    end
    message = message .. effectName .. self:DebugColorWhite(' abilityId: ') .. abilityId
    if beginTime and endTime then
      local duration = endTime - beginTime
      if duration > 0 then
        message = message .. self:DebugColorWhite(' duration: ') .. duration
      end
    end
    d(message)
  end
end
