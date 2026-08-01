SamisTrialHelperAddon = SamisTrialHelperAddon or {}

local STH = SamisTrialHelperAddon

STH.settings = {}

STH.defaults = {
  enableDebug = false,
  clearOnZoneChange = true,
  offsetX = 100,
  offsetY = 200,
  timeoutDuration = 8,
  warningDuration = 60,
  alertDuration = 15,
  warningColour = "FFAA00",
  alertColour = "FF0000",
  defaultTextColour = "FFFFFF",
  wipeOnZoneChange = false,
  debug = false,
  backgroundColor = "000000",
  backgroundOpacity = 0.8,
  showTitle = true,
  listenToSayChannel = false,
  listenToGroupChannel = true,
  whisperPlayer = false,
}

STH.uncollectedItems = {}
STH.lastMessage = nil
STH.lastRequestRecord = nil
STH.pendingMessages = {}

function STH:RemoveUncollectedItemRecord(record)
  if not record then return end

  STH.uncollectedItems[record.playerName] = nil
end

function STH:CreateUncollectedItemRecord(fromDisplayName, fromName, itemLinks)
  return {
    playerName = fromDisplayName or fromName,
    itemLinks = itemLinks,
    requested = false,
  }
end

local function buildMessageChunks(uncollectedItems, fromDisplayName)
  local MAX_LENGTH = 350
  local suffix = ""

  if STH.settings.whisperPlayer then
    prefix = string.format("/w %s ", fromDisplayName)
    suffix = string.format(". [SamisTrialHelper]")
    chatChannel = CHAT_CHANNEL_WHISPER
  else
    prefix = "/g "
    suffix = string.format(" from %s. [SamisTrialHelper]", fromDisplayName)
    chatChannel = CHAT_CHANNEL_PARTY
  end

  local available = MAX_LENGTH - #"I need these items: " - #suffix

  local chunks = {}
  local currentItems = {}
  local currentLen = 0

  for _, link in ipairs(uncollectedItems) do
    local addLen = (#currentItems > 0 and 2 or 0) + #link
    if currentLen + addLen <= available then
      table.insert(currentItems, link)
      currentLen = currentLen + addLen
    else
      table.insert(chunks, table.concat(currentItems, ", "))
      currentItems = { link }
      currentLen = #link
    end
  end

  if #currentItems > 0 then
    table.insert(chunks, table.concat(currentItems, ", "))
  end

  local messages = {}
  for _, itemStr in ipairs(chunks) do
    table.insert(messages, string.format("%s%s%s", prefix,
      itemStr, suffix))
  end

  return messages
end

local function onChannelMessageSent(_, _, _, _, _, fromDisplayName)
  if fromDisplayName ~= GetDisplayName() then return end
  if #STH.pendingMessages == 0 then
    EVENT_MANAGER:UnregisterForEvent("SamisTrialHelper_MessageQueue", EVENT_CHAT_MESSAGE_CHANNEL)
    return
  end

  local next = table.remove(STH.pendingMessages, 1)
  CHAT_SYSTEM:StartTextEntry(next.text, next.channel)

  if #STH.pendingMessages == 0 then
    EVENT_MANAGER:UnregisterForEvent("SamisTrialHelper_MessageQueue", EVENT_CHAT_MESSAGE_CHANNEL)
  end
end

function STH:SendGroupMessage(record)
  if not record.requested then
    local fromDisplayName = record.playerName
    local uncollectedItems = record.itemLinks

    local messages = buildMessageChunks(uncollectedItems, fromDisplayName)

    STH.lastMessage = messages[1]
    STH.lastRequestRecord = record

    local chatChannel
    if STH.settings.whisperPlayer then
      chatChannel = CHAT_CHANNEL_WHISPER
    else
      chatChannel = CHAT_CHANNEL_PARTY
    end

    STH.pendingMessages = {}
    for i = 2, #messages do
      table.insert(STH.pendingMessages, {
        text = string.format("%s", messages[i]),
        channel = chatChannel,
      })
    end

    if #STH.pendingMessages > 0 then
      EVENT_MANAGER:RegisterForEvent("SamisTrialHelper_MessageQueue", EVENT_CHAT_MESSAGE_CHANNEL, onChannelMessageSent)
    end

    CHAT_SYSTEM:StartTextEntry(string.format("%s", messages[1]), chatChannel)
  end
end
