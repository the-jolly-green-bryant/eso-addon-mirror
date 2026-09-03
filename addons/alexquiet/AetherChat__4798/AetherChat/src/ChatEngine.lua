-- ============================================================================
-- AetherChat : Chat Engine (LootLog Sync, Roster Mapping & Reliable Alerts)
-- ============================================================================
AetherChat = AetherChat or {}
local AetherChat = AetherChat

AetherChat.ChatEngine = {}
AetherChat.ItemLooters = AetherChat.ItemLooters or {}
AetherChat.PlayerAccountMap = AetherChat.PlayerAccountMap or {}

local ChatEngine = AetherChat.ChatEngine
local History = AetherChat.History
local SoundManager = AetherChat.SoundManager

local CHANNEL_KEYS = {}

local function SetChannelKey(channelConst, key)
    if channelConst ~= nil then
        CHANNEL_KEYS[channelConst] = key
    end
end

SetChannelKey(CHAT_CHANNEL_ZONE, 'zone')
SetChannelKey(CHAT_CHANNEL_ZONE_LANGUAGE_1, 'zone')
SetChannelKey(CHAT_CHANNEL_ZONE_LANGUAGE_2, 'zone')
SetChannelKey(CHAT_CHANNEL_ZONE_LANGUAGE_3, 'zone')
SetChannelKey(CHAT_CHANNEL_ZONE_LANGUAGE_4, 'zone')
SetChannelKey(CHAT_CHANNEL_ZONE_LANGUAGE_5, 'zone')
SetChannelKey(CHAT_CHANNEL_ZONE_LANGUAGE_6, 'zone')
SetChannelKey(CHAT_CHANNEL_SAY, 'general')
SetChannelKey(CHAT_CHANNEL_YELL, 'general')
SetChannelKey(CHAT_CHANNEL_EMOTE, 'general')
SetChannelKey(CHAT_CHANNEL_MONSTER_SAY, 'general')
SetChannelKey(CHAT_CHANNEL_MONSTER_YELL, 'general')
SetChannelKey(CHAT_CHANNEL_MONSTER_EMOTE, 'general')
SetChannelKey(CHAT_CHANNEL_MONSTER_WHISPER, 'general')
SetChannelKey(CHAT_CHANNEL_SYSTEM, 'system')
SetChannelKey(CHAT_CHANNEL_PARTY, 'party')
SetChannelKey(CHAT_CHANNEL_INSTANCE_POPULATION, 'party')
SetChannelKey(CHAT_CHANNEL_GUILD_1, 'guild1')
SetChannelKey(CHAT_CHANNEL_GUILD_2, 'guild2')
SetChannelKey(CHAT_CHANNEL_GUILD_3, 'guild3')
SetChannelKey(CHAT_CHANNEL_GUILD_4, 'guild4')
SetChannelKey(CHAT_CHANNEL_GUILD_5, 'guild5')
SetChannelKey(CHAT_CHANNEL_OFFICER_1, 'officer1')
SetChannelKey(CHAT_CHANNEL_OFFICER_2, 'officer2')
SetChannelKey(CHAT_CHANNEL_OFFICER_3, 'officer3')
SetChannelKey(CHAT_CHANNEL_OFFICER_4, 'officer4')
SetChannelKey(CHAT_CHANNEL_OFFICER_5, 'officer5')

local function CleanName(rawName)
    if not rawName or rawName == '' then return '' end
    if rawName:sub(1, 1) == '@' then return rawName end
    return zo_strformat("<<1>>", rawName)
end

function AetherChat.UpdateGroupPlayerMap()
    -- 1. Scan group by index and direct group tags 1..24
    local groupSize = GetGroupSize() or 0
    local maxCheck = math.max(groupSize, 24)
    for i = 1, maxCheck do
        local unitTag = GetGroupUnitTagByIndex and GetGroupUnitTagByIndex(i) or ('group' .. i)
        if not unitTag or not DoesUnitExist(unitTag) then
            unitTag = 'group' .. i
        end
        if unitTag and DoesUnitExist(unitTag) then
            local charName = CleanName(GetUnitName(unitTag))
            local rawCharName = GetRawUnitName(unitTag)
            local dispName = GetUnitDisplayName(unitTag)
            if dispName and dispName ~= "" then
                if dispName:sub(1, 1) ~= '@' then dispName = '@' .. dispName end
                if charName and charName ~= "" then
                    AetherChat.PlayerAccountMap[charName:lower()] = dispName
                    AetherChat.PlayerAccountMap[charName:gsub("%^%a+", ""):lower()] = dispName
                end
                if rawCharName and rawCharName ~= "" then
                    local cleanRaw = CleanName(rawCharName)
                    AetherChat.PlayerAccountMap[rawCharName:lower()] = dispName
                    AetherChat.PlayerAccountMap[cleanRaw:lower()] = dispName
                    AetherChat.PlayerAccountMap[cleanRaw:gsub("%^%a+", ""):lower()] = dispName
                end
                AetherChat.PlayerAccountMap[dispName:lower()] = dispName
                AetherChat.PlayerAccountMap[dispName:gsub("^@", ""):lower()] = dispName
            end
        end
    end

    -- 2. Add local player
    local myChar = CleanName(GetRawUnitName('player'))
    local myDisp = GetDisplayName()
    if myDisp and myDisp ~= "" then
        if myDisp:sub(1, 1) ~= '@' then myDisp = '@' .. myDisp end
        if myChar and myChar ~= "" then
            AetherChat.PlayerAccountMap[myChar:lower()] = myDisp
            AetherChat.PlayerAccountMap[myChar:gsub("%^%a+", ""):lower()] = myDisp
        end
        AetherChat.PlayerAccountMap[myDisp:lower()] = myDisp
        AetherChat.PlayerAccountMap[myDisp:gsub("^@", ""):lower()] = myDisp
    end

    -- 3. Scan LootLog history table if available to populate account mappings
    if LootLog and LootLog.history then
        for _, group in pairs(LootLog.history) do
            if type(group) == 'table' then
                for idx = 1, #group do
                    local entry = LootLog.Unpack and LootLog.Unpack(group[idx])
                    if entry then
                        local userId = entry[4]
                        local charName = entry[5]
                        if userId and userId ~= "" and charName and charName ~= "" then
                            local uDisp = (userId:sub(1, 1) == '@') and userId or ('@' .. userId)
                            local cName = CleanName(charName)
                            AetherChat.PlayerAccountMap[cName:lower()] = uDisp
                            AetherChat.PlayerAccountMap[charName:lower()] = uDisp
                            AetherChat.PlayerAccountMap[cName:gsub("%^%a+", ""):lower()] = uDisp
                        end
                    end
                end
            end
        end
    end
end

function AetherChat.SanitizeTarget(rawTarget)
    if not rawTarget or rawTarget == '' then return nil end
    local clean = tostring(rawTarget):gsub("|c%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H[^|]+|h", ""):gsub("|h", ""):gsub("%^%a+", ""):gsub("%s+", "")
    if clean == "" or clean == "You" or clean == "@Moi" or clean == "Moi" or clean == "Vous" then
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

    local cleanLower = clean:lower()
    local cleanNoGender = clean:gsub("%^%a+", ""):lower()

    -- 2. Lookup in dynamic character -> @account mapping
    AetherChat.UpdateGroupPlayerMap()
    local mapped = AetherChat.PlayerAccountMap[cleanLower] or AetherChat.PlayerAccountMap[cleanNoGender]
    if mapped and mapped ~= "" then
        return mapped
    end

    -- 3. Lookup across active Group unit tags
    for i = 1, 24 do
        local uTag = 'group' .. i
        if DoesUnitExist(uTag) then
            local uChar = CleanName(GetUnitName(uTag)):lower()
            local uRaw = CleanName(GetRawUnitName(uTag)):lower()
            local uDisp = GetUnitDisplayName(uTag)
            if uDisp and uDisp ~= "" then
                if uDisp:sub(1, 1) ~= '@' then uDisp = '@' .. uDisp end
                if uChar == cleanLower or uChar == cleanNoGender or uRaw == cleanLower or uRaw == cleanNoGender then
                    AetherChat.PlayerAccountMap[cleanLower] = uDisp
                    AetherChat.PlayerAccountMap[cleanNoGender] = uDisp
                    return uDisp
                end
            end
        end
    end

    -- 4. Lookup in Friends list
    local numFriends = GetNumFriends and GetNumFriends() or 0
    for i = 1, numFriends do
        local displayName, _, _, _, _, _, _, _, _, hasCharacter, characterName = GetFriendInfo(i)
        if hasCharacter and characterName and characterName ~= "" then
            local cName = CleanName(characterName):lower()
            if cName == cleanLower or cName == cleanNoGender then
                if displayName:sub(1, 1) ~= '@' then displayName = '@' .. displayName end
                AetherChat.PlayerAccountMap[cleanLower] = displayName
                return displayName
            end
        end
    end

    -- 5. Lookup across Player's Guilds
    local numGuilds = GetNumGuilds and GetNumGuilds() or 0
    for g = 1, numGuilds do
        local guildId = GetGuildId(g)
        if guildId and guildId > 0 then
            local numMembers = GetNumGuildMembers(guildId) or 0
            for m = 1, numMembers do
                local name, _, _, _, _, _, _, _, hasCharacter, characterName = GetGuildMemberInfo(guildId, m)
                if hasCharacter and characterName and characterName ~= "" then
                    local cName = CleanName(characterName):lower()
                    if cName == cleanLower or cName == cleanNoGender then
                        if name:sub(1, 1) ~= '@' then name = '@' .. name end
                        AetherChat.PlayerAccountMap[cleanLower] = name
                        return name
                    end
                end
            end
        end
    end

    -- 6. Fallback: strictly enforce @DisplayName format for all player targets
    if clean ~= "Groupe" and clean ~= "Vous" then
        return '@' .. clean:gsub("^@", "")
    end

    return clean
end

function AetherChat.GetLooterForItem(itemLink)
    if not itemLink or itemLink == '' then return nil end
    local strLink = tostring(itemLink)

    -- 1. Direct table lookup
    if AetherChat.ItemLooters[strLink] then
        local target = AetherChat.ResolveAccountName(AetherChat.ItemLooters[strLink])
        if target and target:sub(1, 1) == '@' then return target end
        if target and target ~= "Groupe" and target ~= "Vous" then return '@' .. target:gsub("^@", "") end
    end

    -- 2. Lookup by item ID
    local itemId = strLink:match("item:(%d+)") or strLink:match("^(%d+)$")
    if itemId and AetherChat.ItemLooters[itemId] then
        local target = AetherChat.ResolveAccountName(AetherChat.ItemLooters[itemId])
        if target and target:sub(1, 1) == '@' then return target end
        if target and target ~= "Groupe" and target ~= "Vous" then return '@' .. target:gsub("^@", "") end
    end

    -- 3. Search recent messages in Loot history
    local messages = History.GetMessages('loot')
    if messages and #messages > 0 then
        for i = #messages, 1, -1 do
            local msg = messages[i]
            local text = msg.text or ''
            if (itemId and text:find("item:" .. itemId)) or (text:find(strLink, 1, true)) then
                local rawLooter = text:match("%->|r%s+(.+)$") or text:match("%->%s+(.+)$") or text:match("→%s+(.+)$")
                if rawLooter then
                    local target = AetherChat.ResolveAccountName(rawLooter)
                    if target then
                        if target:sub(1, 1) ~= '@' and target ~= "Groupe" and target ~= "Vous" then
                            target = '@' .. target:gsub("^@", "")
                        end
                        return target
                    end
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

    local qty = (quantity and quantity > 0) and quantity or 1
    local myAccount = GetDisplayName()
    local isPersonal = isSelf or (myAccount and looterName == myAccount) or looterName == "@Moi" or looterName == "You" or looterName == "Vous"

    -- 1. Currency drop (gold)
    if tonumber(strLink) then
        local goldIcon = zo_iconTextFormat("/esoui/art/currency/currency_gold.dds", 22, 22, "", false)
        local recipient = isPersonal and ((LootLog and LootLog.self and LootLog.self.you) or "|c57F287Vous|r") or string.format("|c38BDF8%s|r", looterName or "Groupe")
        return string.format("|H0:lootlog|h[Loot Log]|h %s%s |c57F287Pièces d'or|r → %s", goldIcon, strLink, recipient)
    end

    -- 2. Indicator (LootLog exact method: uncollectedColor + zo_iconFormatInheritColor)
    local formattedIndicator = ""
    local isUncollected, uncollectedColor, uncollectedIcon = false, nil, nil
    if LootLogMulti and LootLogMulti.ShouldFlagAsUncollected then
        isUncollected, uncollectedColor, uncollectedIcon = LootLogMulti.ShouldFlagAsUncollected(strLink, isPersonal)
    elseif LootLog and LootLog.GetItemLinkCollectionStatus then
        if LootLog.GetItemLinkCollectionStatus(strLink) == 1 then
            isUncollected = true
            uncollectedColor = isPersonal and 0xCC0000 or 0xCCCC00
            uncollectedIcon = "LootLog/art/uncollected.dds"
        end
    elseif IsItemLinkSetCollectionPiece and IsItemSetCollectionPieceUnlocked then
        local itemId = GetItemLinkItemId(strLink)
        if IsItemLinkSetCollectionPiece(strLink) and not IsItemSetCollectionPieceUnlocked(itemId) then
            isUncollected = true
            uncollectedColor = isPersonal and 0xCC0000 or 0xCCCC00
            uncollectedIcon = "LootLog/art/uncollected.dds"
        end
    end

    if isUncollected then
        local uColor = uncollectedColor or (isPersonal and 0xCC0000 or 0xCCCC00)
        local uIcon = uncollectedIcon or "LootLog/art/uncollected.dds"
        formattedIndicator = string.format("|c%06X%s|r", uColor, zo_iconFormatInheritColor(uIcon, 22, 22))
    end

    -- 3. Item Icon (LootLog exact method: zo_iconTextFormat)
    local iconPath = (LootLog and LootLog.GetLinkIcon and LootLog.GetLinkIcon(strLink)) or GetItemLinkInfo(strLink) or GetItemLinkIcon(strLink) or '/esoui/art/icons/icon_missing.dds'
    local formattedIcon = zo_iconTextFormat(iconPath, 22, 22, "", false)

    -- 4. Quantity (LootLog exact method)
    local formattedQuantity = (qty > 1) and string.format("×%d", qty) or ""

    -- 5. Trait (LootLog exact method)
    local traitName = (LootLog and LootLog.GetGearTraitName and LootLog.GetGearTraitName(strLink)) or ""
    if traitName == "" then
        local traitType = GetItemLinkTraitType(strLink)
        if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
            local tStr = GetString("SI_ITEMTRAITTYPE", traitType)
            if tStr and tStr ~= "" then traitName = zo_strformat("<<1>>", tStr) end
        end
    end
    local formattedTrait = (traitName ~= "") and string.format(" |cC5C29E(%s)|r", traitName) or ""

    -- 6. Recipient (Strictly @DisplayName for 100% reliable 1-click Need and whispers)
    local recipient = ""
    if isPersonal then
        recipient = (LootLog and LootLog.self and LootLog.self.you) or "|c57F287Vous|r"
    else
        local resolvedAccount = AetherChat.ResolveAccountName(looterName) or looterName or "Groupe"
        if resolvedAccount ~= "Groupe" and resolvedAccount:sub(1, 1) ~= '@' then
            resolvedAccount = '@' .. resolvedAccount:gsub("^@", "")
        end

        local cleanName = resolvedAccount
        if resolvedAccount ~= "Groupe" then
            cleanName = ZO_LinkHandler_CreateDisplayNameLink(resolvedAccount)
        end
        recipient = string.format("|c38BDF8%s|r", cleanName)
    end
    local formattedRecipient = string.format(" → %s", recipient)

    -- Remember looter for 1-click Need (guaranteed @DisplayName)
    if looterName then
        local resolved = AetherChat.ResolveAccountName(looterName) or looterName
        if resolved and resolved ~= "Groupe" and resolved ~= "Vous" and resolved:sub(1, 1) ~= '@' then
            resolved = '@' .. resolved:gsub("^@", "")
        end
        AetherChat.ItemLooters[strLink] = resolved
        local itemId = strLink:match("item:(%d+)") or strLink:match("^(%d+)$")
        if itemId then AetherChat.ItemLooters[itemId] = resolved end
    end

    local cleanItemLink = (type(strLink) == "string") and strLink:gsub("^|H0", "|H1", 1) or strLink
    return string.format("|H0:lootlog|h[Loot Log]|h %s%s%s%s%s%s", formattedIndicator, formattedIcon, cleanItemLink, formattedQuantity, formattedTrait, formattedRecipient)
end

AetherChat.RecentLootCache = AetherChat.RecentLootCache or {}

function AetherChat.IsLootDuplicate(itemLink, quantity, looter)
    if not itemLink or itemLink == '' then return true end
    local strLink = tostring(itemLink)
    local qty = tostring(quantity or 1)
    local looterStr = tostring(looter or "")
    local key = string.format("%s_%s_%s", strLink, qty, looterStr)
    local now = GetGameTimeMilliseconds()

    if AetherChat.RecentLootCache[key] and (now - AetherChat.RecentLootCache[key] < 3000) then
        return true
    end

    AetherChat.RecentLootCache[key] = now

    -- Cleanup cache if needed
    for k, timestamp in pairs(AetherChat.RecentLootCache) do
        if (now - timestamp) > 15000 then
            AetherChat.RecentLootCache[k] = nil
        end
    end

    return false
end

function AetherChat.SyncFromLootLog()
    if not LootLog or not LootLog.history then return end

    local existing = History.GetMessages('loot')
    if existing and #existing > 0 then
        return
    end

    -- Populate PlayerAccountMap from group and LootLog
    AetherChat.UpdateGroupPlayerMap()

    local sortedKeys = {}
    for k in pairs(LootLog.history) do
        table.insert(sortedKeys, k)
    end
    table.sort(sortedKeys)

    for _, key in ipairs(sortedKeys) do
        local group = LootLog.history[key]
        if type(group) == 'table' then
            for i = 1, #group do
                local entry = LootLog.Unpack and LootLog.Unpack(group[i])
                if entry and entry[2] then
                    local timestamp = entry[1]
                    local itemLink = entry[2]
                    local count = entry[3] or 1
                    local userId = entry[4]
                    local charName = entry[5]
                    local looter = (userId and userId ~= "") and userId or charName

                    if looter and looter ~= "" then
                        local resolved = AetherChat.ResolveAccountName(looter)
                        if resolved then
                            looter = resolved
                        elseif looter:sub(1, 1) ~= '@' then
                            looter = '@' .. looter
                        end
                    end

                    local isSelf = (LootLog.self and userId == LootLog.self.userId) or (LootLog.self and charName == LootLog.self.name)

                    if not AetherChat.IsLootDuplicate(itemLink, count, looter) then
                        local formattedLine = AetherChat.FormatLootLogLine(itemLink, count, looter, isSelf)
                        local timeStr = GetTimeString():sub(1, 5)
                        History.AddMessage('loot', '|cFFFF00Loot Log|r', formattedLine, timeStr, 0, isSelf, false)
                    end
                end
            end
        end
    end

    if AetherChat.Messenger and AetherChat.Messenger.RefreshChannelList then
        AetherChat.Messenger.RefreshChannelList()
    end
end

-- IDs already processed during this session (reset on reloadui is fine - we save processed state)
local processedSalesMails = {}

-- Initialize processedSalesMails from saved vars so we don't double-fire after reloadui
local function InitProcessedSalesMails()
    if AetherChat.savedVars and AetherChat.savedVars.processedSalesMails then
        processedSalesMails = AetherChat.savedVars.processedSalesMails
    else
        if AetherChat.savedVars then
            AetherChat.savedVars.processedSalesMails = processedSalesMails
        end
    end
end

local pendingSalesMails = {}

local function ExtractSoldItemFromMail(body, subject)
    -- 1. Try from Mail Body if available
    if body and body ~= "" then
        -- Direct ItemLink (|H0:item:...|h[Nom]|h or |H1:item:...)
        local link = body:match("(|H%d+:item:[^|]+|h[^|]*|h)")
        if link then return link end

        -- Quotes [Nom] or « Nom » or "Nom"
        local quoted = body:match("«%s*([^»]+)%s*»") or body:match("%[([^%]]+)%]") or body:match('"([^"]+)"') or body:match("“([^”]+)”")
        if quoted and quoted ~= "" and not quoted:find("^%d+$") then
            return quoted
        end

        -- Regex Patterns FR / EN / DE / ES
        local name = body:match("vente%s+de%s+l'objet%s+([^\n\r,]+)")
                  or body:match("objet%s+([^\n\r,]+)%s+a%s+été%s+vendu")
                  or body:match("vendu%s+([^\n\r,]+)%s+pour")
                  or body:match("sale%s+of%s+([^\n\r,]+)%s+to")
                  or body:match("item%s+([^\n\r,]+)%s+was%s+sold")
                  or body:match("sold%s+([^\n\r,]+)%s+for")
                  or body:match("Gegenstand%s+([^\n\r,]+)%s+wurde")
        if name and name ~= "" then
            name = name:gsub("%s+à%s*$", ""):gsub("%s+to%s*$", ""):gsub("%s+für%s*$", ""):gsub("%s+pour%s*$", "")
            return name:match("^%s*(.-)%s*$")
        end
    end

    -- 2. Extract from Mail Subject Header (Instantly available anywhere in Tamriel without opening mail!)
    if subject and subject ~= "" then
        local link = subject:match("(|H%d+:item:[^|]+|h[^|]*|h)")
        if link then return link end

        local quoted = subject:match("%[([^%]]+)%]") or subject:match("«%s*([^»]+)%s*»") or subject:match('"([^"]+)"')
        if quoted and quoted ~= "" and not quoted:find("^%d+$") then
            return quoted
        end

        local afterColon = subject:match(":%s*(.+)$")
        if afterColon and afterColon ~= "" then
            return afterColon:match("^%s*(.-)%s*$")
        end

        local afterDash = subject:match("%-%s*(.+)$")
        if afterDash and afterDash ~= "" then
            return afterDash:match("^%s*(.-)%s*$")
        end
    end

    return nil
end

local function FireGuildStoreSaleAlert(mailIdStr, attachedMoney, soldItem)
    processedSalesMails[mailIdStr] = true
    pendingSalesMails[mailIdStr] = nil

    local notifySales = AetherChat.Settings and AetherChat.Settings.Get
                        and AetherChat.Settings.Get('notifySales', true)
    if notifySales == false then return end

    local L = AetherChat.L
    local goldFormatted = ZO_Currency_FormatPlatform(CURT_MONEY, attachedMoney, ZO_CURRENCY_FORMAT_AMOUNT_ICON)

    local msgText = ""
    local csaText = ""
    if soldItem and soldItem ~= "" then
        msgText = L('SALES_MSG_FORMAT', soldItem, goldFormatted)
        csaText = string.format("%s (+%s)", soldItem, goldFormatted)
    else
        msgText = L('SALES_MSG_FORMAT_NO_ITEM', goldFormatted)
        csaText = string.format("%s (+%s)", L('SALES_ALERT_TITLE'), goldFormatted)
    end

    -- 1. Center Screen Announcement (CSA) + Sound
    if CENTER_SCREEN_ANNOUNCE then
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.TRADING_HOUSE_SEARCH_SUCCESS)
        params:SetText('|c57F287[Vente] |r' .. csaText)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    else
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.TRADING_HOUSE_SEARCH_SUCCESS, csaText)
    end

    -- 2. Post in General & Sales channel
    local timeStr = GetTimeString():sub(1, 5)
    local author = 'Boutique'
    History.AddMessage('general', author, msgText, timeStr, 0, false, false, nil)

    if AetherChat.Messenger and AetherChat.Messenger.OnMessageReceived then
        AetherChat.Messenger.OnMessageReceived('general', author, msgText, false, false, nil)
    end
end

function ChatEngine.OnMailReadable(eventCode, mailId)
    if not mailId then return end
    local mailIdStr = Id64ToString(mailId)
    local pending = pendingSalesMails[mailIdStr]
    if not pending or processedSalesMails[mailIdStr] then return end

    local body = ReadMail and ReadMail(mailId)
    local soldItem = ExtractSoldItemFromMail(body, pending.subject)
    FireGuildStoreSaleAlert(mailIdStr, pending.attachedMoney, soldItem)
end

function ChatEngine.CheckGuildStoreSales()
    if not GetNextMailId or not GetMailItemInfo then return end

    -- Try to init persistence link
    if AetherChat.savedVars and not AetherChat.savedVars.processedSalesMails then
        AetherChat.savedVars.processedSalesMails = processedSalesMails
    elseif AetherChat.savedVars and AetherChat.savedVars.processedSalesMails ~= processedSalesMails then
        processedSalesMails = AetherChat.savedVars.processedSalesMails
    end

    local mailId = GetNextMailId()
    while mailId do
        local mailIdStr = Id64ToString(mailId)
        if not processedSalesMails[mailIdStr] then
            local senderDisplayName, senderCharacterName, subject, icon, unread,
                  fromSystem, fromCS, returned, numAttachments, attachedMoney,
                  codAmount, numBodyCharacters, timeUntilExpiration, isInvoice = GetMailItemInfo(mailId)

            -- A Guild Store sale mail has: fromSystem=true, isInvoice=true, attachedMoney > 0
            local isSaleMail = fromSystem and (isInvoice == true or isInvoice == 1)
                               and attachedMoney and attachedMoney > 0

            if isSaleMail then
                local body = nil
                if IsReadMailInfoReady and IsReadMailInfoReady(mailId) and ReadMail then
                    body = ReadMail(mailId)
                end
                local soldItem = ExtractSoldItemFromMail(body, subject)
                FireGuildStoreSaleAlert(mailIdStr, attachedMoney, soldItem)
            end
        end
        mailId = GetNextMailId(mailId)
    end
end

-- ============================================================================
-- REAL-TIME GUILD HISTORY SALES SCANNER (Works anywhere: in combat & dungeons!)
-- ============================================================================

local processedHistorySales = {}

local function InitProcessedHistorySales()
    if AetherChat.savedVars and AetherChat.savedVars.processedHistorySales then
        processedHistorySales = AetherChat.savedVars.processedHistorySales
    else
        if AetherChat.savedVars then
            AetherChat.savedVars.processedHistorySales = processedHistorySales
        end
    end
end

function ChatEngine.ScanGuildHistorySales(targetGuildId)
    if not GetDisplayName or not GetNumGuilds then return end
    local myDisplayName = GetDisplayName()
    if not myDisplayName or myDisplayName == '' then return end
    myDisplayName = myDisplayName:lower()

    local minGuild = targetGuildId or 1
    local maxGuild = targetGuildId or GetNumGuilds()

    for g = minGuild, maxGuild do
        local guildId = targetGuildId or GetGuildId(g)
        if guildId and guildId > 0 then
            local category = GUILD_HISTORY_STORE or GUILD_HISTORY_EVENT_CATEGORY_TRADING or 3
            local numEvents = GetNumGuildEvents and GetNumGuildEvents(guildId, category) or 0

            -- Check the most recent 25 events
            local checkCount = math.min(numEvents, 25)
            for e = 1, checkCount do
                local eventType, secsSinceEvent, seller, buyer, itemQuantity, itemLink, price, tax, eventId = GetGuildEventInfo(guildId, category, e)
                if eventType == GUILD_EVENT_STORE_ITEM_SOLD or eventType == GUILD_HISTORY_EVENT_ITEM_SOLD or eventType == 14 then
                    local eventKey = string.format("gh:%s:%s:%s", tostring(guildId), tostring(eventId or (tostring(secsSinceEvent) .. ":" .. tostring(price))), tostring(itemLink))
                    if not processedHistorySales[eventKey] then
                        processedHistorySales[eventKey] = true

                        -- Check if seller is the player
                        local sName = seller and seller:lower() or ''
                        if sName == myDisplayName or sName == ('@' .. myDisplayName) or ('@' .. sName) == myDisplayName then
                            -- Only notify if recent (within 10 minutes)
                            if not secsSinceEvent or secsSinceEvent < 600 then
                                FireGuildStoreSaleAlert(eventKey, price or 0, itemLink)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ============================================================================
-- KEYWORD & URL DETECTION ENGINE
-- ============================================================================

-- Compiled table of lowercase keyword patterns for fast matching
-- Exposed as ChatEngine.keywordTable so external code can inspect it
ChatEngine.keywordTable = {}
local keywordTable = ChatEngine.keywordTable

function ChatEngine.RebuildKeywordTable()
    -- Reset and re-link the shared reference
    local newTable = {}
    local rawList = AetherChat.Settings and AetherChat.Settings.Get and AetherChat.Settings.Get('keywordList', '') or ''
    if rawList ~= '' then
        for kw in rawList:gmatch('[^,]+') do
            local trimmed = kw:match('^%s*(.-)%s*$')
            if trimmed and trimmed ~= '' then
                table.insert(newTable, trimmed:lower())
            end
        end
    end
    -- Update in-place so existing references (keywordTable local) stay valid
    while #keywordTable > 0 do table.remove(keywordTable) end
    for _, v in ipairs(newTable) do table.insert(keywordTable, v) end
    ChatEngine.keywordTable = keywordTable
end

-- Returns: highlighted text with custom color badge [KEYWORD], true if any keyword matched, and the hexColor
-- Uses Lua character class [aA] trick for true case-insensitive matching
function ChatEngine.ApplyKeywordHighlight(text)
    if not text or text == '' then return text, false, nil end
    if not AetherChat.Settings or not AetherChat.Settings.Get then return text, false, nil end
    if not AetherChat.Settings.Get('keywordEnable', true) then return text, false, nil end
    if #keywordTable == 0 then return text, false, nil end

    local hexColor = AetherChat.Settings.Get('keywordColor', 'FFD700') or 'FFD700'

    -- Clean any existing highlight tags to prevent nesting
    local result = text
    local lowerText = result:lower()
    local matched = false

    for _, kw in ipairs(keywordTable) do
        if kw ~= '' and lowerText:find(kw, 1, true) then
            matched = true
            -- Build a case-insensitive pattern using [aA] character classes for each letter
            local ciPattern = kw:gsub('(.)', function(c)
                local lo = c:lower()
                local hi = c:upper()
                if lo ~= hi then
                    return '[' .. lo .. hi .. ']'
                else
                    local specials = { ['%'] = '%%', ['.'] = '%.', ['+'] = '%+',
                                       ['-'] = '%-', ['*'] = '%*', ['?'] = '%?',
                                       ['['] = '%[', [']'] = '%]', ['^'] = '%^',
                                       ['$'] = '%$', ['('] = '%(', [')'] = '%)' }
                    return specials[c] or c
                end
            end)

            -- Clean previous tags around the word if already formatted
            result = result:gsub('|c%x%x%x%x%x%x%[?(' .. ciPattern .. ')%]?|r', '%1')

            -- Format as clean, distinct bracketed badge with selected accent color: [WTS]
            result = result:gsub('(' .. ciPattern .. ')', '|c' .. hexColor .. '[%1]|r')
        end
    end

    return result, matched, hexColor
end

-- Detects URLs/Discord links in text and returns a list of found links
function ChatEngine.ExtractURLs(text)
    if not text or text == '' then return {} end
    local urls = {}
    -- Match common URL patterns: http(s)://, discord.gg/, www.
    for url in text:gmatch('https?://[%w%.%-%_/%?%=%&%%%#%+:@!~]+') do
        table.insert(urls, url)
    end
    for url in text:gmatch('discord%.gg/[%w%-_]+') do
        local full = 'https://' .. url
        -- Avoid duplicates
        local dup = false
        for _, u in ipairs(urls) do if u == full or u:find(url, 1, true) then dup = true break end end
        if not dup then table.insert(urls, 'https://' .. url) end
    end
    for url in text:gmatch('www%.[%w%.%-%_/%?%=%&%%%#%+:@!~]+') do
        local full = 'https://' .. url
        local dup = false
        for _, u in ipairs(urls) do if u == full or u:find(url:gsub('%.', '%%.'), 1, false) then dup = true break end end
        if not dup then table.insert(urls, 'https://' .. url) end
    end
    return urls
end

-- Returns text with URL highlights in sky-blue color
function ChatEngine.HighlightURLs(text)
    if not text or text == '' then return text end
    local result = text
    result = result:gsub('(https?://[%w%.%-%_/%?%=%&%%%#%+:@!~]+)', '|c38BDF8[🔗 %1]|r')
    result = result:gsub('(discord%.gg/[%w%-_]+)', '|c38BDF8[🔗 discord.gg/%1]|r')  -- already covered but safe
    return result
end

function ChatEngine.Initialize()
    ChatEngine.RebuildKeywordTable()

    EVENT_MANAGER:RegisterForEvent('AetherChat_Engine', EVENT_CHAT_MESSAGE_CHANNEL, ChatEngine.OnChatMessage)
    EVENT_MANAGER:RegisterForEvent('AetherChat_Loot', EVENT_LOOT_RECEIVED, ChatEngine.OnLootReceived)

    -- Track group changes to map character names -> @AccountName
    EVENT_MANAGER:RegisterForEvent('AetherChat_GroupJoin', EVENT_GROUP_MEMBER_JOINED, AetherChat.UpdateGroupPlayerMap)
    EVENT_MANAGER:RegisterForEvent('AetherChat_GroupLeft', EVENT_GROUP_MEMBER_LEFT, AetherChat.UpdateGroupPlayerMap)
    EVENT_MANAGER:RegisterForEvent('AetherChat_PlayerAct', EVENT_PLAYER_ACTIVATED, function()
        AetherChat.UpdateGroupPlayerMap()
        ChatEngine.CheckGuildStoreSales()
    end)

    -- Real-time Guild Store Sales tracking & notifications
    -- EVENT_MAIL_NUM_UNREAD_CHANGED : fires when unread count changes (new mail arrives)
    EVENT_MANAGER:RegisterForEvent('AetherChat_Sales_Mail', EVENT_MAIL_NUM_UNREAD_CHANGED, function()
        -- No guard on numUnread - scan always, processed table prevents double-fire
        ChatEngine.CheckGuildStoreSales()
    end)
    -- EVENT_MAIL_READABLE : fires when a mail becomes readable/opened with loaded body
    EVENT_MANAGER:RegisterForEvent('AetherChat_Sales_Readable', EVENT_MAIL_READABLE, ChatEngine.OnMailReadable)
    -- EVENT_MAIL_INBOX_UPDATE : most reliable - fires when the inbox list changes
    if EVENT_MAIL_INBOX_UPDATE then
        EVENT_MANAGER:RegisterForEvent('AetherChat_Sales_Inbox', EVENT_MAIL_INBOX_UPDATE, function()
            ChatEngine.CheckGuildStoreSales()
        end)
    end

    -- Real-time Guild History sales events (Fires anywhere: in dungeons, trials, combat!)
    if EVENT_GUILD_HISTORY_CATEGORY_UPDATED then
        EVENT_MANAGER:RegisterForEvent('AetherChat_GuildHistCat', EVENT_GUILD_HISTORY_CATEGORY_UPDATED, function(_, guildId, category)
            ChatEngine.ScanGuildHistorySales(guildId)
        end)
    end
    if EVENT_GUILD_HISTORY_REFRESHED then
        EVENT_MANAGER:RegisterForEvent('AetherChat_GuildHistRef', EVENT_GUILD_HISTORY_REFRESHED, function()
            ChatEngine.ScanGuildHistorySales()
        end)
    end
    if EVENT_GUILD_HISTORY_ENTRY_ADDED then
        EVENT_MANAGER:RegisterForEvent('AetherChat_GuildHistEntry', EVENT_GUILD_HISTORY_ENTRY_ADDED, function(_, guildId, category, eventIndex)
            ChatEngine.ScanGuildHistorySales(guildId)
        end)
    end

    -- Initialize processedSalesMails & processedHistorySales persistence
    zo_callLater(function()
        InitProcessedSalesMails()
        InitProcessedHistorySales()
        ChatEngine.ScanGuildHistorySales()
    end, 500)

    AetherChat.UpdateGroupPlayerMap()
    ChatEngine.CheckGuildStoreSales()
    ChatEngine.ScanGuildHistorySales()

    -- Hook directly into LootLog.LogItem so EVERY drop (personal/group) is captured cleanly
    if LootLog and LootLog.LogItem then
        local originalLogItem = LootLog.LogItem
        LootLog.LogItem = function(itemLink, quantity, notable, receivedBy)
            originalLogItem(itemLink, quantity, notable, receivedBy)

            local isSelf = not receivedBy
            local looter = receivedBy
            if isSelf and LootLog.self then
                looter = LootLog.self.userId or LootLog.self.name or GetDisplayName()
            end

            if looter and looter ~= "" then
                local resolved = AetherChat.ResolveAccountName(looter)
                if resolved then
                    looter = resolved
                elseif looter:sub(1, 1) ~= '@' and not isSelf then
                    looter = '@' .. looter
                end
            end

            if not AetherChat.IsLootDuplicate(itemLink, quantity or 1, looter) then
                local formattedLine = AetherChat.FormatLootLogLine(itemLink, quantity or 1, looter, isSelf)
                local timeStr = GetTimeString():sub(1, 5)

                History.AddMessage('loot', '|cFFFF00Loot Log|r', formattedLine, timeStr, 0, isSelf, false)

                if AetherChat.Messenger and AetherChat.Messenger.OnMessageReceived then
                    AetherChat.Messenger.OnMessageReceived('loot', '|cFFFF00Loot Log|r', formattedLine, isSelf, false)
                end
            end
        end
    end

    -- Initial sync from LootLog if loot tab history is empty
    zo_callLater(function()
        AetherChat.SyncFromLootLog()
    end, 1000)

    -- Hook CHAT_SYSTEM:AddMessage to route native game system messages into 'system' channel
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        ZO_PreHook(CHAT_SYSTEM, "AddMessage", function(self, messageText)
            if not messageText or messageText == "" then return end
            -- Avoid capturing internal AetherChat messages or noisy library debug logs
            if messageText:find("AetherChat") then return end
            if messageText:find("^%[LibDebugLogger%]") or messageText:find("^%[DEBUG%]") then return end

            local cleanMsg = messageText:gsub("[\r\n]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
            if cleanMsg == "" then return end

            local timeStr = GetTimeString():sub(1, 5)
            local author = AetherChat.L('CH_SYSTEM') or "Système"

            History.AddMessage('system', author, cleanMsg, timeStr, 0, false, false, nil)

            if AetherChat.Messenger and AetherChat.Messenger.OnMessageReceived then
                AetherChat.Messenger.OnMessageReceived('system', author, cleanMsg, false, false, nil)
            end
        end)
    end

    -- Capture system broadcasts & server announcements
    if EVENT_BROADCAST then
        EVENT_MANAGER:RegisterForEvent('AetherChat_Broadcast', EVENT_BROADCAST, function(_, messageText)
            if not messageText or messageText == "" then return end
            local cleanMsg = messageText:gsub("[\r\n]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
            if cleanMsg == "" then return end

            local timeStr = GetTimeString():sub(1, 5)
            local author = "Annonce"

            History.AddMessage('system', author, cleanMsg, timeStr, 0, false, false, nil)

            if AetherChat.Messenger and AetherChat.Messenger.OnMessageReceived then
                AetherChat.Messenger.OnMessageReceived('system', author, cleanMsg, false, false, nil)
            end
        end)
    end
end

function ChatEngine.OnLootReceived(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen)
    -- If LootLog is installed, LootLog.LogItem handles 100% of drops
    if LootLog and LootLog.LogItem then
        return
    end

    if not itemName or itemName == '' then return end

    local qty = (quantity and quantity > 0) and quantity or 1
    local isSelf = self and true or false
    local rawLooter = isSelf and GetDisplayName() or ((receivedBy and receivedBy ~= '') and CleanName(receivedBy) or "Groupe")
    local looter = AetherChat.ResolveAccountName(rawLooter) or rawLooter

    -- Prevent duplicate if another event handler already logged this loot
    if AetherChat.IsLootDuplicate(itemName, qty, looter) then
        return
    end

    local timeStr = GetTimeString():sub(1, 5)
    local formattedLine = AetherChat.FormatLootLogLine(itemName, qty, looter, isSelf)

    -- Save to Loot channel history
    History.AddMessage('loot', '|cFFFF00Loot Log|r', formattedLine, timeStr, 0, isSelf, false)

    if AetherChat.Messenger and AetherChat.Messenger.OnMessageReceived then
        AetherChat.Messenger.OnMessageReceived('loot', '|cFFFF00Loot Log|r', formattedLine, isSelf, false)
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
    local msgText = text

    if isWhisper then
        local otherPlayer = nil
        if fromDisplayName and fromDisplayName ~= "" then
            otherPlayer = fromDisplayName
            if otherPlayer:sub(1, 1) ~= '@' then otherPlayer = '@' .. otherPlayer end
        else
            local cleanChar = CleanName(fromName)
            otherPlayer = AetherChat.ResolveAccountName(cleanChar) or cleanChar
        end

        channelKey = 'dm:' .. otherPlayer

        if isSelf then
            author = (myAccount and myAccount ~= '') and myAccount or myCharName
        else
            author = otherPlayer
        end

        -- Auto-register whisper contact in sidebar
        if AetherChat.Messenger and AetherChat.Messenger.RegisterWhisperContact then
            AetherChat.Messenger.RegisterWhisperContact(otherPlayer)
        end
    else
        channelKey = CHANNEL_KEYS[channelType] or 'zone'
        if isSelf then
            author = (myAccount and myAccount ~= '') and myAccount or myCharName
        else
            author = (fromDisplayName and fromDisplayName ~= '') and fromDisplayName or CleanName(fromName)
        end

        local zoneLang = nil
        -- Add clean language tag for zone channels
        if channelType == CHAT_CHANNEL_ZONE_LANGUAGE_2 then
            msgText = "|c38BDF8[FR]|r " .. text
            zoneLang = 'fr'
        elseif channelType == CHAT_CHANNEL_ZONE_LANGUAGE_1 then
            msgText = "|c57F287[EN]|r " .. text
            zoneLang = 'en'
        elseif channelType == CHAT_CHANNEL_ZONE_LANGUAGE_3 then
            msgText = "|cE5B558[DE]|r " .. text
            zoneLang = 'de'
        elseif channelType == CHAT_CHANNEL_ZONE_LANGUAGE_6 then
            msgText = "|cF23F43[ES]|r " .. text
            zoneLang = 'es'
        elseif channelType == CHAT_CHANNEL_ZONE then
            msgText = "|c888888[Global]|r " .. text
            zoneLang = 'global'
        end

        -- Enhance Guild Store sale notifications
        if channelKey == 'general' and (text:find("vendu") or text:find("sold") or text:find("verkauft") or text:find("Guilde") or text:find("Guild")) then
            if not author or author == "" or author:lower() == "system" then
                author = AetherChat.L('SALES_STORE_AUTHOR')
            end
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

    -- ========= URL HIGHLIGHT =========
    local detectedURLs = ChatEngine.ExtractURLs(msgText)
    if #detectedURLs > 0 then
        msgText = ChatEngine.HighlightURLs(msgText)
    end

    -- ========= KEYWORD SOUND ALERT CHECK =========
    local _, keywordMatched = ChatEngine.ApplyKeywordHighlight(msgText)

    History.AddMessage(channelKey, author, msgText, timeStr, 0, isSelf, isWhisper, zoneLang)

    -- Play keyword alert sound if matched (only for messages from others)
    if keywordMatched and not isSelf then
        local kwSound = AetherChat.Settings and AetherChat.Settings.Get and AetherChat.Settings.Get('keywordSound', 'champion') or 'champion'
        if AetherChat.SoundManager and AetherChat.SoundManager.PlaySoundPreview then
            AetherChat.SoundManager.PlaySoundPreview(kwSound)
        end
    end

    -- Play customizable high-audibility alert on incoming message
    if not isSelf then
        SoundManager.PlayIncomingAlert(channelKey)
    end

    if AetherChat.Messenger and AetherChat.Messenger.OnMessageReceived then
        AetherChat.Messenger.OnMessageReceived(channelKey, author, msgText, isSelf, isWhisper, zoneLang)
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
