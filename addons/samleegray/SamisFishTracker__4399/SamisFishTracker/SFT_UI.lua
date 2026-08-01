local SFT = SamisFishTrackerAddon
local constants = SFT.constants

local function formatIconLabel(iconPath, amount)
  return string.format("|t16:16:%s|t : %d", iconPath, amount)
end

local function formatRoeLabel(amount)
  local roeRate = SFT.savedVariables and SFT.savedVariables.roeRate or constants.roeRate
  return string.format("Est. |t16:16:%s|t : %d", constants.icons.roe, amount * roeRate)
end

local function getCatchHistory()
  if not SFT.averageRateCatchHistory then
    SFT.averageRateCatchHistory = {}
  end

  return SFT.averageRateCatchHistory
end

local function pruneCatchHistory(now, windowSeconds)
  local catchHistory = getCatchHistory()
  local cutoff = now - windowSeconds

  while #catchHistory > 0 and catchHistory[1].timestamp <= cutoff do
    table.remove(catchHistory, 1)
  end

  return catchHistory
end

function SFT.RecordFishCatch(amount)
  local catchHistory = getCatchHistory()
  catchHistory[#catchHistory + 1] = {
    timestamp = os.time(),
    amount = amount or 0,
  }
end

local function formatAverageLabel()
  local useRollingWindow = not SFT.savedVariables or SFT.savedVariables.averageRateUseRollingWindow ~= false

  if useRollingWindow then
    local windowSeconds = (SFT.savedVariables and SFT.savedVariables.averageRateRollingWindowSeconds) or 300
    windowSeconds = math.max(1, math.min(3600, windowSeconds))
    local now = os.time()
    local catchHistory = pruneCatchHistory(now, windowSeconds)
    local fishInWindow = 0

    for i = 1, #catchHistory do
      fishInWindow = fishInWindow + catchHistory[i].amount
    end

    local fishPerHour = (fishInWindow / windowSeconds) * 3600
    return string.format("Avg/hr: %.1f", fishPerHour)
  else
    local sessionStartTime = SFT.sessionStartTime or os.time()
    local elapsedSeconds = math.max(os.time() - sessionStartTime, 1)
    local fishPerHour = (SFT.fishamount / elapsedSeconds) * 3600
    return string.format("Avg/hr: %.1f", fishPerHour)
  end
end

local function isAverageRateEnabled()
  return not SFT.savedVariables or SFT.savedVariables.showAverageRate ~= false
end

function SFT.IsRoeTrackingEnabled()
  return not SFT.savedVariables or SFT.savedVariables.enableRoeTracking ~= false
end

local function resizeFilletWindowToFitStats()
  local control = SamisFilletTrackerControl
  local label = SamisFilletTrackerControlLabelFilletStats

  if not control or not label then
    return
  end

  local horizontalPadding = 20
  local minWidth = constants.filletWindowWidth or 300
  label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
  label:SetWidth(1000)
  local textWidth = select(1, label:GetTextDimensions()) or 0
  local desiredWidth = math.max(minWidth, math.ceil(textWidth) + horizontalPadding)

  control:SetWidth(desiredWidth)
  label:SetWidth(desiredWidth - horizontalPadding)

  if SFT.filletWindowBackground then
    SFT.filletWindowBackground:SetDimensions(desiredWidth, constants.filletWindowHeight)
  end
end

function SFT.ApplyRoeTrackingVisibility()
  local enabled = SFT.IsRoeTrackingEnabled()

  SamisFishTrackerControlLabelRoe:SetHidden(not enabled)
  SamisFishTrackerControlLabelBagRoe:SetHidden(not enabled)
  SamisFishTrackerControlLabelBankRoe:SetHidden(not enabled)
  SamisFilletTrackerControl:SetHidden(not enabled)

  if enabled then
    resizeFilletWindowToFitStats()
  end
end

function SFT.InitializeBackground()
  if not SFT.windowBackground then
    local background = WINDOW_MANAGER:CreateControl(nil, SamisFishTrackerControl, CT_TEXTURE)
    background:SetDimensions(200, constants.windowHeightFull)
    background:SetAnchor(TOPLEFT, SamisFishTrackerControl, TOPLEFT, 0, 0)
    background:SetDrawLevel(-1)
    background:SetColor(0, 0, 0, 0.8)
    SFT.windowBackground = background
  end

  if not SFT.windowSeparatorLine then
    local separatorLine = WINDOW_MANAGER:CreateControl(nil, SamisFishTrackerControl, CT_TEXTURE)
    separatorLine:SetColor(0.80, 0.80, 0.80, 1)
    separatorLine:SetDimensions(170, 1)
    separatorLine:SetAnchor(BOTTOM, SamisFishTrackerControl, BOTTOM, 0, -26)
    SFT.windowSeparatorLine = separatorLine
  end

  if not SFT.filletWindowBackground then
    local filletBg = WINDOW_MANAGER:CreateControl(nil, SamisFilletTrackerControl, CT_TEXTURE)
    filletBg:SetDimensions(constants.filletWindowWidth, constants.filletWindowHeight)
    filletBg:SetAnchor(TOPLEFT, SamisFilletTrackerControl, TOPLEFT, 0, 0)
    filletBg:SetDrawLevel(-1)
    filletBg:SetColor(0, 0, 0, 0.8)
    SFT.filletWindowBackground = filletBg
  end
end

function SFT.UpdateAverageRateLabel(forceUpdate)
  local isEnabled = isAverageRateEnabled()
  SamisFishTrackerControlLabelAverage:SetHidden(not isEnabled)

  if not isEnabled then
    return
  end

  local autoUpdateEnabled = not SFT.savedVariables or SFT.savedVariables.averageRateAutoUpdateEnabled ~= false
  if not autoUpdateEnabled and not forceUpdate then
    return
  end

  SamisFishTrackerControlLabelAverage:SetText(formatAverageLabel())
end

function SFT.UpdateFilletStatsLabel()
  if not SFT.IsRoeTrackingEnabled() then
    return
  end

  local sinceRoe = SFT.filletsSinceRoe or 0
  local lastFillets = SFT.lastRoeFillets or 0
  local observedPercent = SFT.lastRoeRatePercent or 0
  SamisFilletTrackerControlLabelFilletStats:SetText(string.format("Fillets since Roe: %d (Last: %d, Obs: %.2f%%)",
    sinceRoe,
    lastFillets, observedPercent))
  resizeFilletWindowToFitStats()
end

function SFT.ResizeWindow()
  local bankHidden = SamisFishTrackerControlLabelBankFish:IsHidden()
  local newHeight = bankHidden and constants.windowHeightCollapsed or constants.windowHeightFull

  if not isAverageRateEnabled() then
    newHeight = newHeight - 15
  end

  SamisFishTrackerControl:SetHeight(newHeight)
  if SFT.windowBackground then
    SFT.windowBackground:SetDimensions(200, newHeight)
  end
end

function SFT.UpdateBankDisplay()
  local roeEnabled = SFT.IsRoeTrackingEnabled()

  if SFT.total_bank <= 0 then
    SamisFishTrackerControlLabelBankFish:SetHidden(true)
    SamisFishTrackerControlLabelBankRoe:SetHidden(true)
  else
    SamisFishTrackerControlLabelBankFish:SetHidden(false)
    SamisFishTrackerControlLabelBankRoe:SetHidden(not roeEnabled)
    SamisFishTrackerControlLabelBankFish:SetText(formatIconLabel(constants.icons.bank, SFT.total_bank))
    if roeEnabled then
      SamisFishTrackerControlLabelBankRoe:SetText(formatRoeLabel(SFT.total_bank))
    end
  end

  SFT.ResizeWindow()
end

function SFT.RefreshStorageLabels()
  local roeEnabled = SFT.IsRoeTrackingEnabled()

  SFT.ApplyRoeTrackingVisibility()
  SamisFishTrackerControlLabelBagFish:SetText(formatIconLabel(constants.icons.bag, SFT.total_bag))
  if roeEnabled then
    SamisFishTrackerControlLabelBagRoe:SetText(formatRoeLabel(SFT.total_bag))
  end
  if roeEnabled then
    SFT.UpdateFilletStatsLabel()
  end
  SFT.UpdateAverageRateLabel()
  SFT.UpdateBankDisplay()
end

function SFT.UpdateFishCount(count)
  SFT.fishamount = count or 0
  SamisFishTrackerControlLabelFish:SetText(formatIconLabel(constants.icons.fish, SFT.fishamount))
  if SFT.IsRoeTrackingEnabled() then
    SamisFishTrackerControlLabelRoe:SetText(formatRoeLabel(SFT.fishamount))
  end
  SFT.UpdateAverageRateLabel()
end

function SFT.UpdateFishAmount(amount)
  local increment = amount or 0
  SFT.UpdateFishCount(SFT.fishamount + increment)
  SFT.total_bag = SFT.total_bag + increment
  SFT.RefreshStorageLabels()
end

function SFT.ResetFishAmount()
  SFT.sessionStartTime = os.time()
  SFT.averageRateCatchHistory = {}
  SFT.UpdateFishCount(0)
  SFT.savedVariables.amount = 0
  SFT.UpdateAverageRateLabel()
end
