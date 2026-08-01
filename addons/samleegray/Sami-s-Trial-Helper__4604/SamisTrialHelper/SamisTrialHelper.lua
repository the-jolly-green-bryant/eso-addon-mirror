SamisTrialHelperAddon = SamisTrialHelperAddon or {}

local STH = SamisTrialHelperAddon

STH.name = "SamisTrialHelper"
STH.displayName = "Sami's Trial Helper"
STH.version = "0.0.1"
STH.author = "samihaize"
STH.styledAuthor = "|cf500e2s|r|ceb00e5a|r|ce100e9m|r|cd700edi|r|cce00f0h|r|cc400f4a|r|cba00f8i|r|cb000fbz|r|ca600ffe|r"

local STH = SamisTrialHelperAddon
local SAMID = SamisTrialAddonsDebugHelpers

local function itemsNotCollected(message)
  local links = {}
  ZO_ExtractLinksFromText(message, { [ITEM_LINK_TYPE] = true }, links)

  local uncollected = {}

  for _, originalItemLink in ipairs(links) do
    if IsItemLinkSetCollectionPiece(originalItemLink.link) and not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(originalItemLink.link)) then
      local brackedLink = STH.util.makeBracketLink(originalItemLink.link)

      table.insert(uncollected, brackedLink)
    end
  end

  return uncollected
end

local function handleChatMessage(event, channelType, fromName, messageText, isCustomerService, fromDisplayName)
  if (channelType ~= CHAT_CHANNEL_SAY and channelType ~= CHAT_CHANNEL_PARTY) or
      (channelType == CHAT_CHANNEL_SAY and not STH.settings.listenToSayChannel) or
      (channelType == CHAT_CHANNEL_PARTY and not STH.settings.listenToGroupChannel) or
      GetDisplayName() == fromDisplayName then
    return
  end

  SAMID:Print("Chat Message - Channel: %s, From: %s, Message: %s", channelType, fromName, messageText)

  local uncollectedItems = itemsNotCollected(messageText)
  local uncollectedItemRecord = STH:CreateUncollectedItemRecord(fromDisplayName, fromName, uncollectedItems)

  if #uncollectedItems > 0 then
    local existingRecord = STH.uncollectedItems[uncollectedItemRecord.playerName]
    if existingRecord then
      SAMID:Print("Updating existing record for player %s with %d uncollected items.", uncollectedItemRecord.playerName,
        #uncollectedItems)
      for _, itemLink in ipairs(uncollectedItems) do
        table.insert(existingRecord.itemLinks, itemLink)
      end

      STH.ui.show()
      STH.ui.createPlayerButton(existingRecord)
      return
    end

    STH.uncollectedItems[uncollectedItemRecord.playerName] = uncollectedItemRecord

    SAMID:Print("Found %d uncollected item(s) in the message from %s.", #uncollectedItems,
      uncollectedItemRecord.playerName)
    for _, itemLink in ipairs(uncollectedItemRecord.itemLinks) do
      SAMID:Print("Uncollected Item Link: %s", itemLink)
    end

    -- STH.ui.createPlayerButton(uncollectedItemRecord)
  else
    SAMID:Print("No uncollected items found in the message.")
  end

  STH.ui.createPlayerButtons(STH.uncollectedItems)
end

local function reset()
  STH.uncollectedItems = {}
  STH.lastMessage = nil
  STH.lastRequestRecord = nil
  STH.ui.clearPlayerButtons()
  STH.ui.hide()
end

local function onZoneChanged()
  if STH.settings.clearOnZoneChange then
    reset()
  end
end

local function initialize()
  STH.settings = ZO_SavedVars:NewAccountWide("SamisTrialHelperSavedVariables", 1, nil, STH.defaults)

  EVENT_MANAGER:RegisterForEvent(STH.name .. "ChatMessage", EVENT_CHAT_MESSAGE_CHANNEL, handleChatMessage)
  EVENT_MANAGER:RegisterForEvent(STH.name .. "ZoneChange", EVENT_PLAYER_ACTIVATED, onZoneChanged)

  STH.InitializeSettings()
  STH.ui.init()

  STH.ui.hide()
end

local function onAddOnLoaded(_, addonName)
  if addonName ~= STH.name then
    return
  end

  EVENT_MANAGER:UnregisterForEvent(STH.name, EVENT_ADD_ON_LOADED)
  initialize()
end

EVENT_MANAGER:RegisterForEvent(STH.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
