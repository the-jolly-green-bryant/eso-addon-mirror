-- ============================================================================
-- AetherChat : Chat Engine (LootLog Sync, Roster Mapping & Reliable Alerts)
-- ============================================================================
AetherChat = AetherChat or {}
AetherChat.ChatEngine = {}
AetherChat.ItemLooters = AetherChat.ItemLooters or {}
AetherChat.PlayerAccountMap = AetherChat.PlayerAccountMap or {}

local ChatEngine = AetherChat.ChatEngine
local History = AetherChat.History
local SoundManager = AetherChat.SoundManager

local CHANNEL_KEYS = {
    [CHAT_CHANNEL_ZONE]            = 'zone',
    [CHAT_CHANNEL_ZONE_LANGUAGE_1] = 'zone',
    [CHAT_CHANNEL_ZONE_LANGUAGE_2] = 'zone',
    [CHAT_CHANNEL_ZONE_LANGUAGE_3] = 'zone',
    [CHAT_CHANNEL_SAY]             = 'say',
    [CHAT_CHANNEL_YELL]            = 'yell',
    [CHAT_CHANNEL_PARTY]           = 'party',
    [CHAT_CHANNEL_GUILD_1]         = 'guild1',
    [CHAT_CHANNEL_GUILD_2]         = 'guild2',
    [CHAT_CHANNEL_GUILD_3]         = 'guild3',
    [CHAT_CHANNEL_GUILD_4]         = 'guild4',
    [CHAT_CHANNEL_GUILD_5]         = 'guild5',
    [CHAT_CHANNEL_OFFICER_1]       = 'officer1',
    [CHAT_CHANNEL_OFFICER_2]       = 'officer2',
    [CHAT_CHANNEL_OFFICER_3]       = 'officer3',
    [CHAT_CHANNEL_OFFICER_4]       = 'officer4',
    [CHAT_CHANNEL_OFFICER_5]       = 'officer5',
}

local function CleanName(rawName)
    if not rawName or rawName == '' then return '' end
    if rawName:sub(1, 1) == '@' then return rawName end
    return zo_strformat("<<1>>", rawName)
end

function AetherChat.UpdateGroupPlayerMap()
    local groupSize = GetGroupSize() or 0
    if groupSize > 0 then
        for i = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag and DoesUnitExist(unitTag) then
                local charName = CleanName(GetUnitName(unitTag))
                local dispName = GetUnitDisplayName(unitTag)
                if charName and charName ~= "" and dispName and dispName ~= "" then
                    if dispName:sub(1, 1) ~= '@' then dispName = '@' .. dispName end
                    AetherChat.PlayerAccountMap[charName:lower()] = dispName
                    AetherChat.PlayerAccountMap[dispName:lower()] = dispName
                end
            end
        end
    end

    -- Add local player
    local myChar = CleanName(GetRawUnitName('player'))
    local myDisp = GetDisplayName()
    if myChar and myDisp then
        if myDisp:sub(1, 1) ~= '@' then myDisp = '@' .. myDisp end
        AetherChat.PlayerAccountMap[myChar:lower()] = myDisp
        AetherChat.PlayerAccountMap[myDisp:lower()] = myDisp
    end
end

function AetherChat.SanitizeTarget(rawTarget)
    if not rawTarget or rawTarget == '' then return nil end
    local clean = tostring(rawTarget):gsub("|c%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H[^|]+|h", ""):gsub("|h", ""):gsub("%^%a+", ""):gsub("%s+", "")
    if clean == "" or clean == "You" or clean == "@Moi" or clean == "Moi" then
        return nil
    end
    return clean
end

function AetherChat.ResolveAccountName(rawName)
    if not rawName or rawName == "" then return nil end
    local clean = AetherChat.SanitizeTarget(rawName)
    if not clean or clean == "" then return nil end

    -- 1. If already starting with @, return directly
    if clean:sub(1, 1) == '@' then
        return clean
    end

    -- 2. Lookup in our dynamic character -> @account mapping
    AetherChat.UpdateGroupPlayerMap()
    local mapped = AetherChat.PlayerAccountMap[clean:lower()]
    if mapped and mapped ~= "" then
        return mapped
    end

    -- 3. Fallback: prepend @ to ensure ESO whisper routes to the player
    return '@' .. clean
end

function AetherChat.GetLooterForItem(itemLink)
    if not itemLink or itemLink == '' then return nil end
    local strLink = tostring(itemLink)

    -- 1. Direct table lookup
    if AetherChat.ItemLooters[strLink] then
        local target = AetherChat.ResolveAccountName(AetherChat.ItemLooters[strLink])
        if target then return target end
    end

    -- 2. Lookup by item ID
    local itemId = strLink:match("item:(%d+)") or strLink:match("^(%d+)$")
    if itemId and AetherChat.ItemLooters[itemId] then
        local target = AetherChat.ResolveAccountName(AetherChat.ItemLooters[itemId])
        if target then return target end
    end

    -- 3. Search recent messages in Loot history
    local messages = History.GetMessages('loot')
    if messages and #messages > 0 then
        for i = #messages, 1, -1 do
            local msg = messages[i]
            local text = msg.text or ''
            if (itemId and text:find("item:" .. itemId)) or (text:find(strLink, 1, true)) then
                local rawLooter = text:match("%->|r%s+(.+)$") or text:match("%->%s+(.+)$")
                if rawLooter then
                    local target = AetherChat.ResolveAccountName(rawLooter)
                    if target then return target end
                end
            end
        end
    end

    return nil
end

function AetherChat.FormatItemLink(itemLink)
    if not itemLink or itemLink == '' then return '' end
    local strLink = tostring(itemLink)

    local icon = GetItemLinkInfo(strLink) or GetItemLinkIcon(strLink) or '/esoui/art/icons/icon_missing.dds'
    local iconTag = string.format('|t22:22:%s:inheritcolor|t ', icon)

    local traitType = GetItemLinkTraitType(strLink)
    local traitTag = ""
    if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
        local tStr = GetString("SI_ITEMTRAITTYPE", traitType)
        if tStr and tStr ~= "" then
            traitTag = string.format(" |cC5C29E(%s)|r", zo_strformat("<<1>>", tStr))
        end
    end

    local notableTag = GetItemLinkSetInfo(strLink) and " |cFFCC00!!!|r" or ""

    return string.format("%s%s%s%s", iconTag, strLink, traitTag, notableTag)
end

function AetherChat.FormatLootLogLine(itemLink, quantity, looterName, isSelf)
    if not itemLink then return '' end
    local strLink = tostring(itemLink)
    if strLink == '' then return '' end

    local icon = GetItemLinkInfo(strLink) or GetItemLinkIcon(strLink) or '/esoui/art/icons/icon_missing.dds'
    local iconTag = string.format('|t22:22:%s:inheritcolor|t ', icon)

    -- Category (Jewelry, Light, Medium, Heavy, Weapon, etc.)
    local armorType = GetItemLinkArmorType(strLink)
    local weaponType = GetItemLinkWeaponType(strLink)
    local equipType = GetItemLinkEquipType(strLink)
    local category = ""
    if equipType == EQUIP_TYPE_RING or equipType == EQUIP_TYPE_NECK then
        category = "Jewelry"
    elseif armorType == ARMORTYPE_LIGHT then
        category = "Light"
    elseif armorType == ARMORTYPE_MEDIUM then
        category = "Medium"
    elseif armorType == ARMORTYPE_HEAVY then
        category = "Heavy"
    elseif weaponType ~= WEAPONTYPE_NONE then
        category = "Weapon"
    end
    local catTag = (category ~= "") and string.format("|cE0E0E0%s|r ", category) or ""

    -- Quantity
    local qty = (quantity and quantity > 1) and string.format(" x%d", quantity) or ""

    -- Trait
    local traitType = GetItemLinkTraitType(strLink)
    local traitName = ""
    if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
        local tStr = GetString("SI_ITEMTRAITTYPE", traitType)
        if tStr and tStr ~= "" then
            traitName = zo_strformat("<<1>>", tStr)
        end
    end
    local traitTag = (traitName ~= "") and string.format(" |cC5C29E(%s)|r", traitName) or ""

    -- Notable / Set indicator
    local hasSet = GetItemLinkSetInfo(strLink)
    local notableTag = hasSet and " |cFFCC00!!!|r" or ""

    -- Recipient (@AccountName Resolution)
    local myAccount = GetDisplayName()
    local recipient = ""
    if isSelf or (myAccount and looterName == myAccount) or looterName == "@Moi" or looterName == "You" then
        recipient = "|c57F287You|r"
    else
        local resolvedAccount = AetherChat.ResolveAccountName(looterName) or (looterName or "Groupe")
        local cleanName = resolvedAccount
        if cleanName:sub(1, 1) == '@' then
            cleanName = ZO_LinkHandler_CreateDisplayNameLink(cleanName)
        else
            cleanName = ZO_LinkHandler_CreateCharacterLink(cleanName)
        end
        recipient = string.format("|c38BDF8%s|r", cleanName)
    end

    -- Remember who looted this item for 1-click whisper Need
    if looterName then
        local resolved = AetherChat.ResolveAccountName(looterName) or looterName
        AetherChat.ItemLooters[strLink] = resolved
        local itemId = strLink:match("item:(%d+)") or strLink:match("^(%d+)$")
        if itemId then
            AetherChat.ItemLooters[itemId] = resolved
        end
    end

    return string.format("|cFFFF00Loot:|r %s%s%s%s%s%s |c888888->|r %s", iconTag, catTag, strLink, qty, traitTag, notableTag, recipient)
end

function AetherChat.SyncFromLootLog()
    if not LootLog or not LootLog.history then return end

    for key, group in pairs(LootLog.history) do
        if type(group) == 'table' then
            for i = 1, #group do
                local entry = LootLog.Unpack(group[i])
                if entry and entry[2] then
                    local timestamp = entry[1]
                    local itemLink = entry[2]
                    local count = entry[3] or 1
                    local userId = entry[4]
                    local charName = entry[5]
                    local looter = (userId and userId ~= "") and userId or charName
                    local isSelf = (LootLog.self and userId == LootLog.self.userId) or (LootLog.self and charName == LootLog.self.name)

                    local formattedLine = AetherChat.FormatLootLogLine(itemLink, count, looter, isSelf)
                    local timeStr = GetTimeString():sub(1, 5)

                    History.AddMessage('loot', '|cFFFF00Loot|r', formattedLine, timeStr, 0, isSelf, false)
                end
            end
        end
    end
end

function ChatEngine.Initialize()
    EVENT_MANAGER:RegisterForEvent('AetherChat_Engine', EVENT_CHAT_MESSAGE_CHANNEL, ChatEngine.OnChatMessage)
    EVENT_MANAGER:RegisterForEvent('AetherChat_Loot', EVENT_LOOT_RECEIVED, ChatEngine.OnLootReceived)

    -- Track group changes to map character names -> @AccountName
    EVENT_MANAGER:RegisterForEvent('AetherChat_GroupJoin', EVENT_GROUP_MEMBER_JOINED, AetherChat.UpdateGroupPlayerMap)
    EVENT_MANAGER:RegisterForEvent('AetherChat_GroupLeft', EVENT_GROUP_MEMBER_LEFT, AetherChat.UpdateGroupPlayerMap)
    EVENT_MANAGER:RegisterForEvent('AetherChat_PlayerAct', EVENT_PLAYER_ACTIVATED, AetherChat.UpdateGroupPlayerMap)

    AetherChat.UpdateGroupPlayerMap()

    -- Hook directly into LootLog if available
    if LootLog and LootLog.LogItem then
        local originalLogItem = LootLog.LogItem
        LootLog.LogItem = function(itemLink, quantity, notable, receivedBy)
            originalLogItem(itemLink, quantity, notable, receivedBy)

            local isSelf = not receivedBy
            local looter = receivedBy
            if isSelf and LootLog.self then
                looter = LootLog.self.name
            end

            local formattedLine = AetherChat.FormatLootLogLine(itemLink, quantity or 1, looter, isSelf)
            local timeStr = GetTimeString():sub(1, 5)

            History.AddMessage('loot', '|cFFFF00Loot|r', formattedLine, timeStr, 0, isSelf, false)

            if AetherChat.Messenger and AetherChat.Messenger.OnMessageReceived then
                AetherChat.Messenger.OnMessageReceived('loot', '|cFFFF00Loot|r', formattedLine, isSelf, false)
            end
        end
    end

    -- Initial sync from LootLog
    zo_callLater(function()
        AetherChat.SyncFromLootLog()
    end, 1000)
end

function ChatEngine.OnLootReceived(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen)
    if not itemName or itemName == '' then return end

    local qty = (quantity and quantity > 0) and quantity or 1
    local timeStr = GetTimeString():sub(1, 5)
    local isSelf = self and true or false
    local rawLooter = isSelf and GetDisplayName() or ((receivedBy and receivedBy ~= '') and CleanName(receivedBy) or "Groupe")
    local looter = AetherChat.ResolveAccountName(rawLooter) or rawLooter

    local formattedLine = AetherChat.FormatLootLogLine(itemName, qty, looter, isSelf)

    -- Save to Loot channel history
    History.AddMessage('loot', '|cFFFF00Loot|r', formattedLine, timeStr, 0, isSelf, false)

    if AetherChat.Messenger and AetherChat.Messenger.OnMessageReceived then
        AetherChat.Messenger.OnMessageReceived('loot', '|cFFFF00Loot|r', formattedLine, isSelf, false)
    end
end

function ChatEngine.OnChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
    local myAccount = GetDisplayName()
    local myCharName = CleanName(GetRawUnitName('player'))

    local isWhisperSent = (channelType == CHAT_CHANNEL_WHISPER_SENT)
    local isWhisperRecv = (channelType == CHAT_CHANNEL_WHISPER)
    local isWhisper = isWhisperSent or isWhisperRecv

    -- Precise isSelf calculation (avoiding any false positive)
    local isSelf = isWhisperSent
    if not isSelf and fromDisplayName and fromDisplayName ~= "" and myAccount and myAccount ~= "" then
        local d1 = fromDisplayName:gsub("^@", ""):lower()
        local d2 = myAccount:gsub("^@", ""):lower()
        if d1 == d2 then isSelf = true end
    end
    if not isSelf and fromName and fromName ~= "" and myCharName and myCharName ~= "" then
        local c1 = CleanName(fromName):lower()
        local c2 = myCharName:lower()
        if c1 == c2 then isSelf = true end
    end

    local author = nil
    local channelKey = nil

    if isWhisper then
        local otherPlayer = (fromDisplayName and fromDisplayName ~= '') and fromDisplayName or CleanName(fromName)
        channelKey = 'dm:' .. otherPlayer

        if isSelf then
            author = (myAccount and myAccount ~= '') and myAccount or myCharName
        else
            author = otherPlayer
        end
    else
        channelKey = CHANNEL_KEYS[channelType] or 'zone'
        if isSelf then
            author = (myAccount and myAccount ~= '') and myAccount or myCharName
        else
            author = (fromDisplayName and fromDisplayName ~= '') and fromDisplayName or CleanName(fromName)
        end
    end

    -- Remember any item looter from whispers/chat
    if text:find("|H") and text:find(":item:") then
        for itemLink in text:gmatch("(|H.-:item:.-|h.-|h)") do
            if author and author ~= '' then
                local resolved = AetherChat.ResolveAccountName(author) or author
                AetherChat.ItemLooters[itemLink] = resolved
                local itemId = itemLink:match("item:(%d+)") or itemLink:match("^(%d+)$")
                if itemId then
                    AetherChat.ItemLooters[itemId] = resolved
                end
            end
        end
    end

    local timeStr = GetTimeString():sub(1, 5)
    History.AddMessage(channelKey, author, text, timeStr, 0, isSelf, isWhisper)

    -- Play customizable high-audibility alert on incoming message
    if not isSelf then
        SoundManager.PlayIncomingAlert(channelKey)
    end

    if AetherChat.Messenger and AetherChat.Messenger.OnMessageReceived then
        AetherChat.Messenger.OnMessageReceived(channelKey, author, text, isSelf, isWhisper)
    end
end

function ChatEngine.SendMessage(text, channelKey)
    if not text or text == '' then return end

    local cmd = '/z '
    if channelKey == 'zone' then
        cmd = '/z '
    elseif channelKey == 'say' then
        cmd = '/s '
    elseif channelKey == 'yell' then
        cmd = '/y '
    elseif channelKey == 'party' or channelKey == 'loot' then
        cmd = '/p '
    elseif channelKey:find('^guild') then
        local gIdx = channelKey:sub(6)
        cmd = '/g' .. gIdx .. ' '
    elseif channelKey:find('^officer') then
        local oIdx = channelKey:sub(8)
        cmd = '/o' .. oIdx .. ' '
    elseif channelKey:find('^dm:') then
        local contact = channelKey:sub(4)
        cmd = '/tell ' .. contact .. ' '
    end

    local fullMessage = cmd .. text

    if CHAT_SYSTEM then
        CHAT_SYSTEM:StartTextEntry(fullMessage)
        if ZO_ChatWindowTextEntryEditBox then
            ZO_ChatWindowTextEntryEditBox:TakeFocus()
        end
    end

    SoundManager.PlayMessageSent()
end
