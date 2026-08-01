local ArcanumGuildHall = _G["ArcanumGuildHall"]

local res = ArcanumGuildHallMediaRes
local LCM = LibCustomMenu

local NOTE_PATTERNS = {
    { pattern = "|cAABANA|r", icon = res.IconBanana },
    { pattern = "|cAATANK|r", icon = res.IconTank },
    { pattern = "|cAAHEAL|r", icon = res.IconHeal },
    { pattern = "|cAADAMA|r", icon = res.IconDD },
}

local NOTE_ICON_MAP = {}
for _, rule in ipairs(NOTE_PATTERNS) do
    NOTE_ICON_MAP[rule.pattern] = rule.icon
end

local GroupNames = {}
local GuildCache = {}
local originalChatHandler = nil

local EVENT_GUILD_CACHE_ADDED = ArcanumGuildHall.name .. "_GuildCacheAdded"
local EVENT_GUILD_CACHE_REMOVED = ArcanumGuildHall.name .. "_GuildCacheRemoved"
local EVENT_GUILD_CACHE_UPDATED = ArcanumGuildHall.name .. "_GuildCacheUpdated"
local EVENT_GUILD_CACHE_NOTE = ArcanumGuildHall.name .. "_GuildCacheNote"

local function ClearTable(tbl)
    for key in pairs(tbl) do
        tbl[key] = nil
    end
end

local function GetChatIconSize()
    return ZO_ChatSystem:GetFontSizeFromSetting() * 1.5
end

local function getAccountName(name)
    if not name or name == "" then
        return nil
    end

    if zo_strsub(name, 1, 1) == "@" then
        return name
    end

    return GroupNames[name]
end

local function GetMemberColor(rankName)
    if not rankName or rankName == "" then
        return "FFFFFF"
    end

    return rankName:match("|c(%x%x%x%x%x%x)") or "FFFFFF"
end

local function GetMemberIcon(memberNote, rankIndex, iconIndex)
    memberNote = memberNote or ""

    local icon
    if rankIndex == 5 then
        icon = res.IconHlp
    else
        for pattern, patternIcon in pairs(NOTE_ICON_MAP) do
            if PlainStringFind(memberNote, pattern) then
                icon = patternIcon
                break
            end
        end

        if not icon or icon == "" then
            icon = GetGuildRankLargeIcon(iconIndex)
        end
    end

    if not icon or icon == "" then
        return ""
    end

    local iconSize = GetChatIconSize()
    return zo_iconFormatInheritColor(icon, iconSize, iconSize)
end

function ArcanumGuildHall:RefreshGuildChatData()
    self:UpdateGuildIndex()
    self:BuildGuildCache()
end

function ArcanumGuildHall:UpdateGroupMembers()
    ClearTable(GroupNames)

    local size = GetGroupSize()
    for i = 1, size do
        local tag = "group" .. i
        local unitName = GetUnitName(tag)
        local displayName = GetUnitDisplayName(tag)

        if unitName and unitName ~= "" and displayName and displayName ~= "" then
            GroupNames[unitName] = displayName
            GroupNames[zo_strformat(SI_UNIT_NAME, unitName)] = displayName
        end
    end
end

function ArcanumGuildHall:IsGuildMember(accountName)
    if not accountName or accountName == "" then
        return false, false
    end

    if GuildCache[accountName:lower()] then
        return true, true
    end

    local arcanumIndex = GetGuildMemberIndexFromDisplayName(self.guildId, accountName)
    if arcanumIndex then
        return true, true
    end

    for index = 1, GetNumGuilds() do
        local guildId = GetGuildId(index)
        local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, accountName)
        if memberIndex then
            return true, false
        end
    end

    return false, false
end

function ArcanumGuildHall:InitializeChatMenu()
    LCM:RegisterPlayerContextMenu(function(playerName, rawName)
        local accountName = getAccountName(playerName) or getAccountName(rawName)

        if not accountName and rawName and zo_strsub(rawName, 1, 1) == "@" then
            accountName = rawName
        end

        if not accountName and playerName and zo_strsub(playerName, 1, 1) == "@" then
            accountName = playerName
        end

        if not accountName then
            return
        end

        local isGuildMember, isArcanumMember = self:IsGuildMember(accountName)

        if isArcanumMember then
            local cacheData = GuildCache[accountName:lower()]
            local lookupName = cacheData and cacheData.displayName or accountName
            local arcanumIndex = GetGuildMemberIndexFromDisplayName(self.guildId, lookupName)
            if arcanumIndex then
                local _, _, rankIndex = GetGuildMemberInfo(self.guildId, arcanumIndex)
                local rankName = GetGuildRankCustomName(self.guildId, rankIndex) or ""

                AddCustomMenuItem("-", function()
                end)
                AddCustomMenuItem(res.IconAA .. " " .. accountName .. ": " .. rankName, function()
                end)
            end
        end

        if not isArcanumMember and DoesPlayerHaveGuildPermission(self.guildId, GUILD_PERMISSION_INVITE) then
            AddCustomMenuItem(
                    ArcanumGuildHall.GetDefaultLocaleString("CHAT_NEW_INVITE") .. " " .. GetGuildName(self.guildId),
                    function()
                        GuildInvite(self.guildId, accountName)
                    end
            )
        end

        AddCustomMenuItem(
                ArcanumGuildHall.GetDefaultLocaleString("CHAT_NEW_MESSAGE"),
                function()
                    if MAIL_SEND:IsHidden() then
                        MAIL_SEND:ComposeMailTo(accountName)
                    else
                        MAIL_SEND:SetReply(accountName)
                    end
                end
        )

        if IsPlayerInGroup(accountName) then
            AddCustomMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function()
                JumpToGroupMember(accountName)
            end)
        elseif IsFriend(accountName) then
            AddCustomMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function()
                JumpToFriend(accountName)
            end)
        elseif isGuildMember then
            AddCustomMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function()
                JumpToGuildMember(accountName)
            end)
        end

        AddCustomMenuItem(GetString(SI_SOCIAL_MENU_VISIT_HOUSE), function()
            JumpToHouse(accountName)
        end)
        AddCustomMenuItem("-", function()
        end)
    end, LCM.CATEGORY_LATE)
end

function ArcanumGuildHall:findGuildIndex()
    for i = 1, GetNumGuilds() do
        if GetGuildId(i) == self.guildId then
            return i
        end
    end
    return 0
end

function ArcanumGuildHall:getTime()
    if self.db.showChatTimestamp then
        return "[" .. self:GetTimeString() .. "] "
    end
    return ""
end

function ArcanumGuildHall:isGuildChannel(channelType)
    local index = self.guildIndex
    if not index or index == 0 then
        return false
    end

    return channelType == _G["CHAT_CHANNEL_GUILD_" .. index]
            or channelType == _G["CHAT_CHANNEL_OFFICER_" .. index]
end

function ArcanumGuildHall:SetTextColor(channelType, fromDisplay)
    if not self.db.showChatGuildIconColor or not self:isGuildChannel(channelType) then
        return ""
    end

    if not fromDisplay or fromDisplay == "" then
        return ""
    end

    if not GuildCache[fromDisplay:lower()] then
        self:UpdateGuildCacheMember(fromDisplay)
    end

    local data = GuildCache[fromDisplay:lower()]
    if not data then
        return ""
    end

    return data.color
end

function ArcanumGuildHall:UpdateGuildCacheMember(displayName)
    if not displayName or displayName == "" then
        return
    end

    local cacheKey = displayName:lower()

    local memberIndex = GetGuildMemberIndexFromDisplayName(self.guildId, displayName)
    if not memberIndex then
        GuildCache[cacheKey] = nil
        return
    end

    local _, memberNote, rankIndex = GetGuildMemberInfo(self.guildId, memberIndex)
    rankIndex = rankIndex or 0

    local rankName = GetGuildRankCustomName(self.guildId, rankIndex) or ""
    local iconIndex = GetGuildRankIconIndex(self.guildId, rankIndex)

    local color = GetMemberColor(rankName)
    local icon = GetMemberIcon(memberNote, rankIndex, iconIndex)

    local iconTag = icon

    if self.db.showChatGuildIcon == 0 then
        iconTag = ""
    elseif self.db.showChatGuildIcon == 2 and rankIndex < 6 then
        iconTag = ""
    elseif iconTag ~= "" and self.db.showChatGuildIconColor then
        iconTag = "|c" .. color .. iconTag .. "|r"
    end

    GuildCache[cacheKey] = {
        displayName = displayName,
        rankIndex = rankIndex,
        rankName = rankName,
        color = color,
        icon = icon,
        iconTag = iconTag,
        memberNote = memberNote,
    }
end

function ArcanumGuildHall:BuildGuildCache()
    ClearTable(GuildCache)

    if not self.guildId or self.guildId == 0 then
        return
    end

    local memberCount = GetNumGuildMembers(self.guildId)
    if not memberCount or memberCount <= 0 then
        return
    end

    for i = 1, memberCount do
        local displayName = select(1, GetGuildMemberInfo(self.guildId, i))
        if displayName and displayName ~= "" then
            self:UpdateGuildCacheMember(displayName)
        end
    end
end

function ArcanumGuildHall:RegisterGuildCacheEvents()
    local function UpdateCache(_, guildId, displayName)
        if guildId ~= self.guildId then
            return
        end

        if displayName and displayName ~= "" then
            self:UpdateGuildCacheMember(displayName)
        else
            self:BuildGuildCache()
        end
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_GUILD_CACHE_ADDED, EVENT_GUILD_MEMBER_ADDED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_GUILD_CACHE_REMOVED, EVENT_GUILD_MEMBER_REMOVED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_GUILD_CACHE_UPDATED, EVENT_GUILD_MEMBER_RANK_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_GUILD_CACHE_NOTE, EVENT_GUILD_MEMBER_NOTE_CHANGED)

    EVENT_MANAGER:RegisterForEvent(EVENT_GUILD_CACHE_ADDED, EVENT_GUILD_MEMBER_ADDED, UpdateCache)
    EVENT_MANAGER:RegisterForEvent(EVENT_GUILD_CACHE_REMOVED, EVENT_GUILD_MEMBER_REMOVED, UpdateCache)
    EVENT_MANAGER:RegisterForEvent(EVENT_GUILD_CACHE_UPDATED, EVENT_GUILD_MEMBER_RANK_CHANGED, UpdateCache)
    EVENT_MANAGER:RegisterForEvent(EVENT_GUILD_CACHE_NOTE, EVENT_GUILD_MEMBER_NOTE_CHANGED, UpdateCache)
end

function ArcanumGuildHall:GetIcon(channelType, fromDisplay)
    if not fromDisplay or fromDisplay == "" then
        return ""
    end

    if not self:isGuildChannel(channelType) then
        return ""
    end

    if not GuildCache[fromDisplay:lower()] then
        self:UpdateGuildCacheMember(fromDisplay)
    end

    local data = GuildCache[fromDisplay:lower()]
    if not data then
        return ""
    end

    return data.iconTag or ""
end

function ArcanumGuildHall:RegisterChatFormatter()
    if self.chatHandlerRegistered then
        return
    end

    local handlers = ZO_ChatSystem_GetEventHandlers()
    local previousHandler = handlers and handlers[EVENT_CHAT_MESSAGE_CHANNEL]
    if type(previousHandler) ~= "function" then
        return
    end

    ZO_ChatSystem_AddEventHandler(EVENT_CHAT_MESSAGE_CHANNEL, function(channelType, fromName, messageText, isCustomerService, fromDisplay, ...)
        local formattedMessage = previousHandler(channelType, fromName, messageText, isCustomerService, fromDisplay, ...)
        if type(formattedMessage) ~= "string" then
            return formattedMessage
        end

        local timestamp = ArcanumGuildHall:getTime()
        local icon = ArcanumGuildHall:GetIcon(channelType, fromDisplay)

        return timestamp .. icon .. formattedMessage
    end)

    self.chatHandlerRegistered = true
end

function ArcanumGuildHall:InitializeChatSystem()
    self:RefreshGuildChatData()
    self:RegisterGuildCacheEvents()
    self:RegisterChatFormatter()
end