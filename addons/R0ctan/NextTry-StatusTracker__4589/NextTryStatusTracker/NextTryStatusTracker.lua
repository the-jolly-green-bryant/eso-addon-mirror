NextTryStatusTracker = NextTryStatusTracker or {}
local NTST = NextTryStatusTracker

NTST.name = "NextTryStatusTracker"
NTST.version = "1.2.0"
NTST.savedVariablesName = "NextTryStatusTrackerSavedVariables"
NTST.savedVariablesVersion = 1

local em = EVENT_MANAGER
local EVENT_REFRESH_DELAY_MS = 1000
local FAST_REFRESH_DELAY_MS = 100

NTST.roleKeys = { "tank", "healer", "dd" }
NTST.roleIconPaths = {
    raidlead = "EsoUI/Art/Compass/groupleader.dds",
    tank = "EsoUI/Art/LFG/LFG_icon_tank.dds",
    healer = "EsoUI/Art/LFG/LFG_icon_healer.dds",
    dd = "EsoUI/Art/LFG/LFG_icon_dps.dds",
}
NTST.roleFallbacks = { tank = "[T]", healer = "[H]", dd = "[DD]", raidlead = "[RL]" }
NTST.defaultTagDefinitions = {
    dungeon = { name = "Dungeon", nameKey = "tagDungeon" },
    raid = { name = "Raid", nameKey = "tagRaid" },
    pvp = { name = "PvP", nameKey = "tagPvp" },
    trade = { name = "Trade", nameKey = "tagTrade" },
    crafter = { name = "Crafter", nameKey = "tagCrafter" },
}
NTST.validDisplayRoles = { none = true, tank = true, healer = true, dd = true, raidlead = true }

function NTST.Icon(path, size)
    if type(path) ~= "string" or path == "" then return "" end
    size = tonumber(size) or 18
    if zo_iconFormat then
        local ok, formatted = pcall(function() return zo_iconFormat(path, size, size) end)
        if ok and type(formatted) == "string" and formatted ~= "" then return formatted end
    end
    return string.format("|t%d:%d:%s|t", size, size, path)
end

NTST.roleIcons = {}
for role, path in pairs(NTST.roleIconPaths) do
    NTST.roleIcons[role] = NTST.Icon(path, 18)
end

NTST.allianceIconPaths = {}
if ALLIANCE_ALDMERI_DOMINION then
    NTST.allianceIconPaths[ALLIANCE_ALDMERI_DOMINION] = "EsoUI/Art/MapPins/AvA_flagAldmeri.dds"
end
if ALLIANCE_DAGGERFALL_COVENANT then
    NTST.allianceIconPaths[ALLIANCE_DAGGERFALL_COVENANT] = "EsoUI/Art/MapPins/AvA_flagDaggerfall.dds"
end
if ALLIANCE_EBONHEART_PACT then
    NTST.allianceIconPaths[ALLIANCE_EBONHEART_PACT] = "EsoUI/Art/MapPins/AvA_flagEbonheart.dds"
end

function NTST.CopyColor(c)
    if not c then return { r = 1, g = 1, b = 1, a = 1 } end
    return { r = c.r or 1, g = c.g or 1, b = c.b or 1, a = c.a or 1 }
end

NTST.defaults = {
    enabled = true,
    visible = true,
    uiUnlocked = false,
    settingsPreview = true,
    showInSettings = true,
    layout = "vertical",
    nameMode = "account",
    sortMode = "alphabetical",
    groupByStatus = false,
    showOnlyOnline = false,
    showLocation = true,
    showHoverTooltip = true,
    showNotesTooltip = true,
    showDisplayRoleMarker = false,
    locationRefreshSeconds = 60,
    windowAnchor = "left",
    refreshSeconds = 60,
    statusBlinkEnabled = true,
    blinkCount = 5,
    blinkPhaseMs = 500,
    blinkFontColor = { r = 0, g = 0, b = 0, a = 1 },
    blinkBackgroundColor = { r = 1, g = 0.76, b = 0.50, a = 1 },
    soundEnabled = false,
    statusSound = "QUEST_ACCEPTED",
    selectedFriend = "",
    selectedGuildId = "",
    selectedGuildMember = "",
    selectedGuildMemberCharacter = "",
    manualPlayer = "",
    selectedRemovePlayer = "",
    selectedManagedPlayer = "",
    selectedTagKey = "",
    selectedAddTagKey = "",
    selectedRemoveTagKey = "",
    tagNameInput = "",
    nextTagId = 1,
    tagDefinitionsInitialized = false,
    tagDefinitions = {},
    position = nil,
    players = {},
    playerSources = {},
    display = {
        padding = 0,
        rowGap = 1,
        groupGap = 10,
        backgroundColor = { r = 0, g = 0, b = 0, a = 0 },
        borderColor = { r = 1, g = 1, b = 1, a = 0 },
        unlockedBorderColor = { r = 1, g = 1, b = 1, a = 0.45 },
        borderSize = 0,
    },
    styles = {
        offline = {
            fontSize = 16,
            fontStyle = "normal",
            fontColor = { r = 0.78, g = 0.78, b = 0.78, a = 1 },
            backgroundColor = { r = 0, g = 0, b = 0, a = 0 },
        },
        online = {
            fontSize = 16,
            fontStyle = "normal",
            fontColor = { r = 0, g = 0, b = 0, a = 1 },
            backgroundColor = { r = 155 / 255, g = 255 / 255, b = 129 / 255, a = 1 },
        },
    },
}

local function L(key)
    local id = NTST.Strings and NTST.Strings[key]
    if id and GetString then
        local text = GetString(id)
        if text and text ~= "" then return text end
    end
    return key
end
NTST.L = L

local function msg(text)
    if NextTryShared and NextTryShared.Chat and NextTryShared.Chat.Print then
        NextTryShared.Chat.Print(NTST.name, text, "FFE000")
    end
end
NTST.Msg = msg

function NTST.CleanPlayerText(name)
    if type(name) ~= "string" then return nil end
    if zo_strformat then
        name = zo_strformat("<<1>>", name)
    end
    name = string.gsub(name, "%^%a+", "")
    name = zo_strtrim(name)
    if name == "" then return nil end
    return name
end

function NTST.NormalizeName(name)
    name = NTST.CleanPlayerText(name)
    if not name then return nil end
    return zo_strlower(name)
end

function NTST.NormalizeDisplayName(name)
    name = NTST.CleanPlayerText(name)
    if not name or name == L("none") then return nil end
    if not string.match(name, "^@") then return nil end
    return name
end

function NTST:BuildClassIconMap()
    if self.classIconsById then return self.classIconsById end
    self.classIconsById = {}
    if not (GetNumClasses and GetClassInfo) then return self.classIconsById end
    local okCount, classCount = pcall(function() return GetNumClasses() end)
    local count = okCount and tonumber(classCount) or 0
    for index = 1, count do
        local ok, classId, _, _, _, _, _, ingameIcon = pcall(function() return GetClassInfo(index) end)
        if ok and type(classId) == "number" and type(ingameIcon) == "string" and ingameIcon ~= "" then
            self.classIconsById[classId] = ingameIcon
        end
    end
    return self.classIconsById
end

function NTST:GetClassDisplayText(classId)
    if type(classId) ~= "number" then return nil end
    local name
    if GetClassName and GENDER_MALE then
        local ok, value = pcall(function() return GetClassName(GENDER_MALE, classId) end)
        if ok then name = self.CleanPlayerText(value) end
    end
    return name
end

function NTST:GetAllianceDisplayText(alliance)
    if type(alliance) ~= "number" then return nil end
    local name
    if GetAllianceName then
        local ok, value = pcall(function() return GetAllianceName(alliance) end)
        if ok then name = self.CleanPlayerText(value) end
    end
    return name
end

local function ensurePlayerBoolTable(value, keys)
    if type(value) ~= "table" then value = {} end
    for _, key in ipairs(keys) do
        if type(value[key]) ~= "boolean" then value[key] = false end
    end
    return value
end

function NTST:GetSortedTagDefinitions()
    local definitions = self.sv and self.sv.tagDefinitions or {}
    local sorted = {}
    for key, definition in pairs(definitions) do
        local name = type(definition) == "table" and self.CleanPlayerText(definition.name)
        if type(key) == "string" and name then
            sorted[#sorted + 1] = { key = key, name = name }
        end
    end
    table.sort(sorted, function(a, b) return zo_strlower(a.name) < zo_strlower(b.name) end)
    return sorted
end

function NTST:BuildTagChoices()
    local choices, values = { L("none") }, { "" }
    for _, definition in ipairs(self:GetSortedTagDefinitions()) do
        choices[#choices + 1] = definition.name
        values[#values + 1] = definition.key
    end
    return choices, values
end

function NTST:BuildPlayerTagChoices(playerName, assigned)
    local choices, values = {}, {}
    local profile = playerName and self:GetPlayerProfile(playerName)
    if not profile then return choices, values end
    for _, definition in ipairs(self:GetSortedTagDefinitions()) do
        local isAssigned = profile.tags[definition.key] == true
        if isAssigned == assigned then
            choices[#choices + 1] = definition.name
            values[#values + 1] = definition.key
        end
    end
    return choices, values
end

function NTST:GetPlayerTagNames(playerName)
    local names = {}
    local profile = playerName and self:GetPlayerProfile(playerName)
    if not profile then return names end
    for _, definition in ipairs(self:GetSortedTagDefinitions()) do
        if profile.tags[definition.key] then names[#names + 1] = definition.name end
    end
    return names
end

function NTST:SetPlayerTagAssigned(playerName, tagKey, assigned)
    local profile = playerName and self:GetPlayerProfile(playerName)
    if not profile or not self:GetTagDefinition(tagKey) then return false end
    profile.tags[tagKey] = assigned and true or nil
    return true
end

function NTST:GetTagDefinition(tagKey)
    local definitions = self.sv and self.sv.tagDefinitions
    local definition = definitions and definitions[tagKey]
    return type(definition) == "table" and definition or nil
end

function NTST:FindTagKeyByName(name)
    name = self.CleanPlayerText(name)
    if not name then return nil end
    local normalized = zo_strlower(name)
    for _, definition in ipairs(self:GetSortedTagDefinitions()) do
        if zo_strlower(definition.name) == normalized then return definition.key end
    end
    return nil
end

function NTST:AddTagDefinition(name)
    name = self.CleanPlayerText(name)
    if not name or self:FindTagKeyByName(name) then return nil end
    local tagKey
    repeat
        tagKey = "custom" .. tostring(self.sv.nextTagId)
        self.sv.nextTagId = self.sv.nextTagId + 1
    until not self.sv.tagDefinitions[tagKey]
    self.sv.tagDefinitions[tagKey] = { name = name }
    self.sv.selectedTagKey = tagKey
    self.sv.tagNameInput = name
    return tagKey
end

function NTST:RenameTagDefinition(tagKey, name)
    local definition = self:GetTagDefinition(tagKey)
    name = self.CleanPlayerText(name)
    local duplicateKey = name and self:FindTagKeyByName(name)
    if not definition or not name or (duplicateKey and duplicateKey ~= tagKey) then return false end
    definition.name = name
    self.sv.tagNameInput = name
    return true
end

function NTST:DeleteTagDefinition(tagKey)
    if not self:GetTagDefinition(tagKey) then return false end
    self.sv.tagDefinitions[tagKey] = nil
    for _, profile in pairs(self.sv.playerSources or {}) do
        if type(profile) == "table" and type(profile.tags) == "table" then
            profile.tags[tagKey] = nil
        end
    end
    if self.sv.selectedTagKey == tagKey then
        self.sv.selectedTagKey = ""
        self.sv.tagNameInput = ""
    end
    if self.sv.selectedAddTagKey == tagKey then self.sv.selectedAddTagKey = "" end
    if self.sv.selectedRemoveTagKey == tagKey then self.sv.selectedRemoveTagKey = "" end
    return true
end

function NTST:EnsurePlayerProfile(playerName)
    if not self.sv then return nil end
    if type(self.sv.playerSources) ~= "table" then self.sv.playerSources = {} end

    local key = self.NormalizeName(playerName)
    if not key then return nil end

    local profile = self.sv.playerSources[key]
    if type(profile) ~= "table" then
        profile = { source = "manual" }
        self.sv.playerSources[key] = profile
    end

    if type(profile.source) ~= "string" or profile.source == "" then profile.source = "manual" end
    if type(profile.customNote) ~= "string" then profile.customNote = "" end
    if type(profile.notificationEnabled) ~= "boolean" then profile.notificationEnabled = true end
    if type(profile.lastSeenAt) ~= "number" then profile.lastSeenAt = nil end
    if type(profile.lastKnownZone) ~= "string" then profile.lastKnownZone = "" end
    if type(profile.lastKnownCharacterName) ~= "string" then profile.lastKnownCharacterName = "" end
    if type(profile.lastKnownClassId) ~= "number" then profile.lastKnownClassId = nil end
    if type(profile.lastKnownAlliance) ~= "number" then profile.lastKnownAlliance = nil end

    if profile.lastKnownCharacterName == "" then
        profile.lastKnownCharacterName = self.CleanPlayerText(profile.characterName) or ""
    end
    if profile.lastKnownZone == "" then
        profile.lastKnownZone = self.CleanPlayerText(profile.zoneName) or ""
    end
    if not profile.lastKnownClassId then profile.lastKnownClassId = tonumber(profile.classId) end
    if not profile.lastKnownAlliance then profile.lastKnownAlliance = tonumber(profile.alliance) end

    profile.roles = ensurePlayerBoolTable(profile.roles, self.roleKeys)
    if type(profile.tags) ~= "table" then profile.tags = {} end
    if not self.validDisplayRoles[profile.displayRole] then profile.displayRole = "none" end

    return profile
end

function NTST:GetPlayerProfile(playerName)
    return self:EnsurePlayerProfile(playerName)
end

function NTST:FormatLastSeen(lastSeenAt)
    if type(lastSeenAt) ~= "number" or not GetTimeStamp then return L("lastSeenUnknown") end

    local elapsed = math.max(0, GetTimeStamp() - lastSeenAt)
    if elapsed < 60 then return L("lastSeenNow") end
    if elapsed < 3600 then
        local minutes = math.max(1, zo_floor(elapsed / 60))
        return string.format(L(minutes == 1 and "lastSeenMinute" or "lastSeenMinutes"), minutes)
    end
    if elapsed < 86400 then
        local hours = math.max(1, zo_floor(elapsed / 3600))
        return string.format(L(hours == 1 and "lastSeenHour" or "lastSeenHours"), hours)
    end

    local days = math.max(1, zo_floor(elapsed / 86400))
    return string.format(L(days == 1 and "lastSeenDay" or "lastSeenDays"), days)
end

function NTST:UpdateLastKnownPlayerData(playerName, playerData, isOnline)
    local profile = self:EnsurePlayerProfile(playerName)
    if not profile then return end

    local characterName = playerData and self.CleanPlayerText(playerData.characterName)
    local zoneName = playerData and self.CleanPlayerText(playerData.zoneName)
    local classId = playerData and tonumber(playerData.classId)
    local alliance = playerData and tonumber(playerData.alliance)
    local secsSinceLogoff = playerData and tonumber(playerData.secsSinceLogoff)
    if characterName then profile.lastKnownCharacterName = characterName end
    if zoneName then profile.lastKnownZone = zoneName end
    if classId and classId > 0 then profile.lastKnownClassId = classId end
    if alliance and alliance > 0 then profile.lastKnownAlliance = alliance end
    if GetTimeStamp then
        if isOnline then
            profile.lastSeenAt = GetTimeStamp()
        elseif secsSinceLogoff and secsSinceLogoff >= 0 then
            profile.lastSeenAt = math.max(0, GetTimeStamp() - secsSinceLogoff)
        end
    end
end

function NTST:SetPlayerNotificationEnabled(playerName, enabled)
    local profile = self:EnsurePlayerProfile(playerName)
    if not profile then return end
    profile.notificationEnabled = enabled and true or false
end

function NTST:SetPlayerCustomNote(playerName, note)
    local profile = self:EnsurePlayerProfile(playerName)
    if not profile then return end
    profile.customNote = type(note) == "string" and zo_strtrim(note) or ""
end

function NTST:ResetPlayerRolesAndTags(playerName)
    local profile = self:EnsurePlayerProfile(playerName)
    if not profile then return end
    for _, key in ipairs(self.roleKeys) do profile.roles[key] = false end
    for key in pairs(profile.tags) do profile.tags[key] = nil end
    profile.displayRole = "none"
end

function NTST:ResetPlayerLastKnownData(playerName)
    local profile = self:EnsurePlayerProfile(playerName)
    if not profile then return end
    profile.lastSeenAt = nil
    profile.lastKnownCharacterName = ""
    profile.lastKnownZone = ""
    profile.lastKnownClassId = nil
    profile.lastKnownAlliance = nil
end

function NTST:GetRoleMarkerIconSize(state)
    state = state == "online" and "online" or "offline"
    local style = self.sv and self.sv.styles and self.sv.styles[state]
    local fontSize = style and tonumber(style.fontSize) or 16
    return zo_clamp(zo_floor((fontSize * 1.1) + 0.5), 14, 30)
end

function NTST:GetDisplayRoleMarker(playerName, size)
    if not (self.sv and self.sv.showDisplayRoleMarker) then return nil end
    local profile = self:EnsurePlayerProfile(playerName)
    if not (profile and profile.displayRole and profile.displayRole ~= "none") then return nil end
    local icon = self.Icon(self.roleIconPaths[profile.displayRole], size or 18)
    if icon ~= "" then return icon end
    return self.roleFallbacks[profile.displayRole]
end

function NTST:FindPlayerIndex(name)
    local normalized = self.NormalizeName(name)
    if not normalized or not self.sv or not self.sv.players then return nil end
    for i, playerName in ipairs(self.sv.players) do
        if self.NormalizeName(playerName) == normalized then return i end
    end
    return nil
end

local function sortCaseInsensitive(list, key)
    table.sort(list, function(a, b)
        local av = key and key(a) or a
        local bv = key and key(b) or b
        return zo_strlower(av or "") < zo_strlower(bv or "")
    end)
end

function NTST:SortTrackedPlayers()
    if self.sv and self.sv.players then
        sortCaseInsensitive(self.sv.players)
    end
end

function NTST:GetTrackedPlayers()
    local players = {}
    if self.sv and self.sv.players then
        for _, playerName in ipairs(self.sv.players) do
            players[#players + 1] = playerName
        end
    end
    return players
end

function NTST:GetFriendListData()
    local friends = {}
    local byDisplayName = {}

    local function addOrMerge(data)
        if not data or not data.displayName then return end
        local key = self.NormalizeName(data.displayName)
        if not key then return end

        local existing = byDisplayName[key]
        if existing then
            existing.characterName = existing.characterName or data.characterName
            existing.zoneName = existing.zoneName or data.zoneName
            existing.classId = existing.classId or data.classId
            existing.alliance = existing.alliance or data.alliance
            existing.secsSinceLogoff = existing.secsSinceLogoff or data.secsSinceLogoff
            existing.note = existing.note or data.note
            if existing.status == nil and data.status ~= nil then existing.status = data.status end
            if existing.online == nil and data.online ~= nil then existing.online = data.online end
            return
        end

        if data.online == nil then data.online = false end
        byDisplayName[key] = data
        friends[#friends + 1] = data
    end

    -- Prefer the direct friend API because GetFriendCharacterInfo reliably exposes zoneName.
    if GetNumFriends and GetFriendInfo then
        for i = 1, GetNumFriends() do
            local displayName, note, status, secsSinceLogoff = GetFriendInfo(i)
            local hasCharacter, characterName, zoneName, classId, alliance
            if GetFriendCharacterInfo then
                local ok, a, b, c, d, e = pcall(function() return GetFriendCharacterInfo(i) end)
                if ok then hasCharacter, characterName, zoneName, classId, alliance = a, b, c, d, e end
            end

            displayName = self.CleanPlayerText(displayName)
            characterName = self.CleanPlayerText(characterName)
            zoneName = self.CleanPlayerText(zoneName)
            note = self.CleanPlayerText(note)
            if displayName then
                addOrMerge({
                    displayName = displayName,
                    characterName = hasCharacter and characterName or nil,
                    zoneName = hasCharacter and zoneName or nil,
                    classId = hasCharacter and tonumber(classId) or nil,
                    alliance = hasCharacter and tonumber(alliance) or nil,
                    secsSinceLogoff = tonumber(secsSinceLogoff),
                    note = note,
                    friendNote = note,
                    status = status,
                    online = status and status ~= PLAYER_STATUS_OFFLINE or false,
                    source = "friend",
                })
            end
        end
    end

    sortCaseInsensitive(friends, function(item) return item.displayName end)
    return friends, byDisplayName
end

function NTST:BuildFriendChoices()
    local choices = { L("none") }
    local values = { "" }
    local friends = self:GetFriendListData()
    for _, friend in ipairs(friends) do
        choices[#choices + 1] = friend.displayName
        values[#values + 1] = friend.displayName
    end
    return choices, values
end

function NTST:BuildTrackedChoices()
    local choices = { L("none") }
    local values = { "" }
    local players = self:GetTrackedPlayers()
    sortCaseInsensitive(players)
    for _, playerName in ipairs(players) do
        choices[#choices + 1] = playerName
        values[#values + 1] = playerName
    end
    return choices, values
end

function NTST:BuildGuildChoices()
    local choices = { L("none") }
    local values = { "" }
    if not GetNumGuilds or not GetGuildId or not GetGuildName then return choices, values end

    local guilds = {}
    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        local guildName = guildId and GetGuildName(guildId)
        if guildId and guildName and guildName ~= "" then
            guilds[#guilds + 1] = { name = guildName, id = guildId }
        end
    end
    sortCaseInsensitive(guilds, function(item) return item.name end)
    for _, guild in ipairs(guilds) do
        choices[#choices + 1] = guild.name
        values[#values + 1] = guild.id
    end
    return choices, values
end

function NTST:GetGuildMemberData(guildId, memberIndex)
    if not guildId or not memberIndex or not GetGuildMemberInfo then return nil end

    local ok, displayName, note, rankIndex, status, secsSinceLogoff = pcall(function()
        return GetGuildMemberInfo(guildId, memberIndex)
    end)
    if not ok then return nil end

    displayName = self.CleanPlayerText(displayName)
    note = self.CleanPlayerText(note)
    if not displayName then return nil end

    local characterName, zoneName, classId, alliance
    if GetGuildMemberCharacterInfo then
        local okChar, hasCharacter, charName, zone, classType, allianceId = pcall(function()
            return GetGuildMemberCharacterInfo(guildId, memberIndex)
        end)
        if okChar and hasCharacter then
            characterName = self.CleanPlayerText(charName)
            zoneName = self.CleanPlayerText(zone)
            classId = tonumber(classType)
            alliance = tonumber(allianceId)
        end
    end

    return {
        displayName = displayName,
        characterName = characterName,
        zoneName = zoneName,
        classId = classId,
        alliance = alliance,
        secsSinceLogoff = tonumber(secsSinceLogoff),
        note = note,
        guildNote = note,
        status = status,
        online = status and status ~= PLAYER_STATUS_OFFLINE or false,
        source = "guild",
        guildId = guildId,
        guildName = GetGuildName and GetGuildName(guildId) or nil,
    }
end

function NTST:GetGuildMemberList(guildId)
    local members = {}
    if not guildId or guildId == "" or not GetNumGuildMembers then return members end
    local ok, count = pcall(function() return GetNumGuildMembers(guildId) end)
    if not ok or type(count) ~= "number" then return members end

    for memberIndex = 1, count do
        local data = self:GetGuildMemberData(guildId, memberIndex)
        if data then members[#members + 1] = data end
    end
    sortCaseInsensitive(members, function(item) return item.displayName end)
    return members
end

function NTST:BuildGuildMemberChoices(guildId)
    local choices = { L("none") }
    local values = { "" }
    self.guildMemberSelectionCache = {}
    local members = self:GetGuildMemberList(guildId)
    for _, member in ipairs(members) do
        local label = member.displayName
        if member.characterName and member.characterName ~= "" then
            label = label .. "  (" .. member.characterName .. ")"
        end
        choices[#choices + 1] = label
        values[#values + 1] = member.displayName
        self.guildMemberSelectionCache[self.NormalizeName(member.displayName)] = member
    end
    return choices, values
end

function NTST:GetRelevantGuildIds()
    local relevant = {}
    local sources = self.sv and self.sv.playerSources or {}
    for _, playerName in ipairs(self:GetTrackedPlayers()) do
        local source = sources[self.NormalizeName(playerName)]
        local guildId = source and source.source == "guild" and tonumber(source.guildId)
        if guildId then
            relevant[guildId] = guildId
        end
    end
    return relevant
end

function NTST:BuildGuildStatusMap()
    local map = {}
    local wantedByGuild = {}
    local remainingByGuild = {}
    local sources = self.sv and self.sv.playerSources or {}

    for _, playerName in ipairs(self:GetTrackedPlayers()) do
        local key = self.NormalizeName(playerName)
        local source = key and sources[key]
        if source and source.source == "guild" and source.guildId then
            local guildId = tonumber(source.guildId)
            if guildId then
                wantedByGuild[guildId] = wantedByGuild[guildId] or {}
                if not wantedByGuild[guildId][key] then
---@diagnostic disable-next-line: need-check-nil
                    wantedByGuild[guildId][key] = true
                    remainingByGuild[guildId] = (remainingByGuild[guildId] or 0) + 1
                end
            end
        end
    end

    for guildId, wanted in pairs(wantedByGuild) do
        local ok, count = pcall(function() return GetNumGuildMembers and GetNumGuildMembers(guildId) or 0 end)
        if ok and type(count) == "number" then
            for memberIndex = 1, count do
                if (remainingByGuild[guildId] or 0) <= 0 then break end
                local member = self:GetGuildMemberData(guildId, memberIndex)
                local key = member and self.NormalizeName(member.displayName)
                if key and wanted[key] then
                    map[key] = member
                    wanted[key] = nil
                    remainingByGuild[guildId] = remainingByGuild[guildId] - 1
                end
            end
        end
    end

    return map
end

function NTST:GetDisplayNameForPlayer(playerName, playerData)
    local accountName = playerName or ""
    local characterName = playerData and playerData.characterName
    if characterName == "" then characterName = nil end

    local displayName
    if self.sv.nameMode == "character" then
        displayName = characterName or accountName
    elseif self.sv.nameMode == "accountCharacter" then
        displayName = characterName and (accountName .. " " .. characterName) or accountName
    elseif self.sv.nameMode == "characterAccount" then
        displayName = characterName and (characterName .. " " .. accountName) or accountName
    else
        displayName = accountName
    end

    local zoneName = playerData and playerData.online and self.sv.showLocation and self.CleanPlayerText(playerData.zoneName)
    if zoneName then
        displayName = displayName .. " (" .. zoneName .. ")"
    end

    return displayName
end

function NTST:GetDisplayEntries(includeFiltered)
    local _, friendMap = self:GetFriendListData()
    local guildMap = self:BuildGuildStatusMap()
    self.displayEntries = self.displayEntries or {}
    if ZO_ClearTable then
        ZO_ClearTable(self.displayEntries)
    else
        for key in pairs(self.displayEntries) do self.displayEntries[key] = nil end
    end
    local entries = self.displayEntries

    for _, playerName in ipairs(self:GetTrackedPlayers()) do
        local key = self.NormalizeName(playerName)
        local sourceData = self:EnsurePlayerProfile(playerName)
        local friendData = friendMap[key]
        local guildData = guildMap[key]
        local playerData = friendData or guildData
        if friendData and guildData then
            if not playerData.characterName and guildData.characterName then playerData.characterName = guildData.characterName end
            if not playerData.zoneName and guildData.zoneName then playerData.zoneName = guildData.zoneName end
            if not playerData.classId and guildData.classId then playerData.classId = guildData.classId end
            if not playerData.alliance and guildData.alliance then playerData.alliance = guildData.alliance end
            if playerData.secsSinceLogoff == nil and guildData.secsSinceLogoff ~= nil then playerData.secsSinceLogoff = guildData.secsSinceLogoff end
            if guildData.guildNote and not playerData.guildNote then playerData.guildNote = guildData.guildNote end
            if not playerData.note and guildData.note then playerData.note = guildData.note end
        end
        if not playerData and sourceData then
            playerData = {
                characterName = self.CleanPlayerText(sourceData.lastKnownCharacterName) or sourceData.characterName,
                zoneName = self.CleanPlayerText(sourceData.lastKnownZone) or sourceData.zoneName,
                classId = sourceData.lastKnownClassId or tonumber(sourceData.classId),
                alliance = sourceData.lastKnownAlliance or tonumber(sourceData.alliance),
                note = sourceData.note,
                friendNote = sourceData.friendNote,
                guildNote = sourceData.guildNote,
                online = false,
                source = sourceData.source,
                guildId = sourceData.guildId,
            }
        elseif playerData and sourceData then
            if not playerData.characterName and sourceData.characterName then playerData.characterName = sourceData.characterName end
            if not playerData.zoneName and sourceData.zoneName then playerData.zoneName = sourceData.zoneName end
            if not playerData.classId and sourceData.lastKnownClassId then playerData.classId = sourceData.lastKnownClassId end
            if not playerData.alliance and sourceData.lastKnownAlliance then playerData.alliance = sourceData.lastKnownAlliance end
            if not playerData.note and sourceData.note then playerData.note = sourceData.note end
            if not playerData.friendNote and sourceData.friendNote then playerData.friendNote = sourceData.friendNote end
            if not playerData.guildNote and sourceData.guildNote then playerData.guildNote = sourceData.guildNote end
            if not playerData.guildId and sourceData.guildId then playerData.guildId = sourceData.guildId end
        end
        local isOnline = playerData and playerData.online or false
        self:UpdateLastKnownPlayerData(playerName, playerData, isOnline)
        local filteredOut = self.sv.showOnlyOnline and not isOnline
        if includeFiltered or not filteredOut then
            entries[#entries + 1] = {
                playerName = playerName,
                playerData = playerData,
                isOnline = isOnline,
                displayName = self:GetDisplayNameForPlayer(playerName, playerData),
                filteredOut = filteredOut,
                profile = sourceData,
                roleMarker = self:GetDisplayRoleMarker(playerName),
            }
        end
    end

    local function alpha(a, b)
        local ad = zo_strlower(a.displayName or "")
        local bd = zo_strlower(b.displayName or "")
        if ad ~= bd then return ad < bd end
        local ap = zo_strlower(a.playerName or "")
        local bp = zo_strlower(b.playerName or "")
        if ap ~= bp then return ap < bp end
        return false
    end

    local sortMode = self.sv.sortMode
    local groupByStatus = self.sv.groupByStatus
    table.sort(entries, function(a, b)
        if a.isOnline ~= b.isOnline then
            if sortMode == "offlineFirst" then
                return not a.isOnline
            elseif groupByStatus or sortMode == "onlineFirst" then
                return a.isOnline
            end
        end
        return alpha(a, b)
    end)

    if self.sv.groupByStatus then
        local previousStatus
        for i, entry in ipairs(entries) do
            entry.groupBreakBefore = i > 1 and previousStatus ~= entry.isOnline
            previousStatus = entry.isOnline
        end
    end

    return entries
end

function NTST:ResolvePlayerSource(name, allowGuildSearch)
    local normalizedName = self.NormalizeName(name)
    if not normalizedName then return { source = "manual" } end

    local _, friendMap = self:GetFriendListData()
    local friend = friendMap and friendMap[normalizedName]
    if friend then
        return {
            source = "friend",
            characterName = friend.characterName,
            zoneName = friend.zoneName,
            note = friend.note,
            friendNote = friend.friendNote or friend.note,
        }
    end

    if allowGuildSearch and GetNumGuilds and GetGuildId and GetNumGuildMembers then
        for guildIndex = 1, GetNumGuilds() do
            local guildId = GetGuildId(guildIndex)
            local ok, count = pcall(function() return GetNumGuildMembers(guildId) end)
            if guildId and ok and type(count) == "number" then
                for memberIndex = 1, count do
                    local member = self:GetGuildMemberData(guildId, memberIndex)
                    if member and self.NormalizeName(member.displayName) == normalizedName then
                        return {
                            source = "guild",
                            guildId = guildId,
                            guildName = member.guildName,
                            characterName = member.characterName,
                            zoneName = member.zoneName,
                            note = member.note,
                            guildNote = member.guildNote or member.note,
                        }
                    end
                end
            end
        end
    end

    return { source = "manual" }
end

function NTST:AddPlayer(name, sourceData)
    name = self.CleanPlayerText(name)
    if name and name ~= L("none") and not string.match(name, "^@") then
        name = "@" .. name
    end
    name = self.NormalizeDisplayName(name)
    if not name then
        msg(L("invalidName"))
        return
    end
    if self:FindPlayerIndex(name) then
        msg(name .. " " .. L("alreadyTracked"))
        return
    end

    sourceData = sourceData or self:ResolvePlayerSource(name, true)
    self.sv.players[#self.sv.players + 1] = name
    self.sv.playerSources[self.NormalizeName(name)] = sourceData
    self:EnsurePlayerProfile(name)
    self:SortTrackedPlayers()
    self.sv.selectedRemovePlayer = ""
    msg(name .. " " .. L("added"))
    self:Refresh()
    self:RefreshSettingsDropdowns()
end

function NTST:AddSelectedFriend()
    local friendName = self.sv.selectedFriend
    if not friendName or friendName == "" then
        msg(L("invalidName"))
        return
    end
    self:AddPlayer(friendName, self:ResolvePlayerSource(friendName, false))
    self.sv.selectedFriend = ""
end

function NTST:AddSelectedGuildMember()
    local memberName = self.sv.selectedGuildMember
    local guildId = tonumber(self.sv.selectedGuildId) or self.sv.selectedGuildId
    if not memberName or memberName == "" or not guildId or guildId == "" then
        msg(L("invalidName"))
        return
    end
    local cacheKey = self.NormalizeName(memberName)
    local cached = cacheKey and self.guildMemberSelectionCache and self.guildMemberSelectionCache[cacheKey]
    self:AddPlayer(memberName, {
        source = "guild",
        guildId = guildId,
        guildName = GetGuildName and GetGuildName(guildId) or nil,
        characterName = cached and cached.characterName or self.sv.selectedGuildMemberCharacter,
        zoneName = cached and cached.zoneName or nil,
        note = cached and cached.note or nil,
        guildNote = cached and (cached.guildNote or cached.note) or nil,
    })
    self.sv.selectedGuildMember = ""
    self.sv.selectedGuildMemberCharacter = ""
end

function NTST:RemovePlayer(name)
    local index = self:FindPlayerIndex(name)
    if not index then return end
    local removed = table.remove(self.sv.players, index)
    if self.sv.playerSources then self.sv.playerSources[self.NormalizeName(removed)] = nil end
    self.sv.selectedRemovePlayer = ""
    if self.NormalizeName(self.sv.selectedManagedPlayer) == self.NormalizeName(removed) then
        self.sv.selectedManagedPlayer = ""
    end
    msg(removed .. " " .. L("removed"))
    self:Refresh()
    self:RefreshSettingsDropdowns()
end

function NTST:SetEnabled(_enabled)
    -- _enabled is intentionally ignored for SavedVariables/backwards compatibility.
    -- NextTry StatusTracker is visual only, so the settings UI exposes only the
    -- window visibility toggle and the addon remains logically enabled.
    self.sv.enabled = true
    self:ApplyVisibility()
    self:Refresh(true)
end

function NTST:SetVisible(visible)
    self.sv.visible = not not visible
    self:ApplyVisibility()
    if self.sv.visible then self:Refresh(true) end
end

function NTST:ToggleVisible()
    self:SetVisible(not self.sv.visible)
end

function NextTryStatusTracker_ToggleWindow()
    if NextTryStatusTracker and NextTryStatusTracker.ToggleVisible then
        NextTryStatusTracker:ToggleVisible()
    end
end

function NTST:PlayStatusSoundKey(soundKey)
    if not soundKey or soundKey == "" then return end
    if SOUNDS and SOUNDS[soundKey] and PlaySound then
        pcall(function() PlaySound(SOUNDS[soundKey]) end)
    end
end

function NTST:PlayStatusSound()
    if not self.sv.soundEnabled then return end
    self:PlayStatusSoundKey(self.sv.statusSound)
end

function NTST:TestStatusSound()
    self:PlayStatusSoundKey(self.sv.statusSound)
end

local function ensureTable(parent, key, default)
    if type(parent[key]) ~= "table" then parent[key] = NTST.CopyColor(default) end
end

local function ensureNumber(parent, key, default)
    if type(parent[key]) ~= "number" then parent[key] = default end
end

local function ensureString(parent, key, default)
    if type(parent[key]) ~= "string" then parent[key] = default end
end

local function ensureBool(parent, key, default)
    if type(parent[key]) ~= "boolean" then parent[key] = default end
end

function NTST:ApplyMigrations()
    local sv = self.sv
    local d = self.defaults

    sv.enabled = true
    ensureBool(sv, "visible", d.visible)
    ensureBool(sv, "uiUnlocked", d.uiUnlocked)
    ensureBool(sv, "settingsPreview", d.settingsPreview)
    if type(sv.showInSettings) ~= "boolean" then sv.showInSettings = sv.settingsPreview end
    sv.settingsPreview = sv.showInSettings
    ensureString(sv, "layout", d.layout)
    ensureString(sv, "nameMode", d.nameMode)
    ensureString(sv, "sortMode", d.sortMode)
    ensureBool(sv, "groupByStatus", d.groupByStatus)
    ensureBool(sv, "showOnlyOnline", d.showOnlyOnline)
    ensureBool(sv, "showLocation", d.showLocation)
    ensureBool(sv, "showHoverTooltip", d.showHoverTooltip)
    ensureBool(sv, "showNotesTooltip", d.showNotesTooltip)
    ensureBool(sv, "showDisplayRoleMarker", d.showDisplayRoleMarker)
    ensureNumber(sv, "locationRefreshSeconds", d.locationRefreshSeconds)
    ensureString(sv, "windowAnchor", d.windowAnchor)
    ensureNumber(sv, "refreshSeconds", d.refreshSeconds)
    ensureBool(sv, "statusBlinkEnabled", d.statusBlinkEnabled)
    ensureNumber(sv, "blinkCount", d.blinkCount)
    ensureNumber(sv, "blinkPhaseMs", d.blinkPhaseMs)
    ensureTable(sv, "blinkFontColor", d.blinkFontColor)
    ensureTable(sv, "blinkBackgroundColor", d.blinkBackgroundColor)
    ensureBool(sv, "soundEnabled", d.soundEnabled)
    ensureString(sv, "statusSound", d.statusSound)
    if sv.statusSound == "NEW_NOTIFICATION" then sv.statusSound = d.statusSound end
    if sv.selectedGuildId ~= "" then
        sv.selectedGuildId = tonumber(sv.selectedGuildId) or ""
    end
    ensureString(sv, "selectedGuildMember", d.selectedGuildMember)
    ensureString(sv, "selectedGuildMemberCharacter", d.selectedGuildMemberCharacter)
    ensureString(sv, "selectedManagedPlayer", d.selectedManagedPlayer)
    ensureString(sv, "selectedTagKey", d.selectedTagKey)
    ensureString(sv, "selectedAddTagKey", d.selectedAddTagKey)
    ensureString(sv, "selectedRemoveTagKey", d.selectedRemoveTagKey)
    ensureString(sv, "tagNameInput", d.tagNameInput)
    ensureNumber(sv, "nextTagId", d.nextTagId)

    if type(sv.tagDefinitions) ~= "table" then sv.tagDefinitions = {} end
    if sv.tagDefinitionsInitialized ~= true then
        for key, definition in pairs(self.defaultTagDefinitions) do
            if not sv.tagDefinitions[key] then
                local name = definition.name
                if definition.nameKey then
                    local localizedName = L(definition.nameKey)
                    if localizedName and localizedName ~= definition.nameKey then name = localizedName end
                end
                sv.tagDefinitions[key] = { name = self.CleanPlayerText(name) or definition.name }
            end
        end
        sv.tagDefinitionsInitialized = true
    end
    for key, definition in pairs(sv.tagDefinitions) do
        if type(key) ~= "string" or type(definition) ~= "table" or not self.CleanPlayerText(definition.name) then
            sv.tagDefinitions[key] = nil
        end
    end
    if sv.selectedTagKey ~= "" and not sv.tagDefinitions[sv.selectedTagKey] then
        sv.selectedTagKey = ""
        sv.tagNameInput = ""
    end

    if type(sv.players) ~= "table" then sv.players = {} end
    if type(sv.playerSources) ~= "table" then sv.playerSources = {} end
    for _, playerName in ipairs(sv.players) do
        local key = self.NormalizeName(playerName)
        if key and type(sv.playerSources[key]) ~= "table" then
            sv.playerSources[key] = { source = "manual" }
        end
        self:EnsurePlayerProfile(playerName)
    end
    if type(sv.position) == "table" and (type(sv.position.x) ~= "number" or type(sv.position.y) ~= "number") then
        sv.position = nil
    elseif type(sv.position) == "table" then
        if sv.position.anchor ~= "left" and sv.position.anchor ~= "center" and sv.position.anchor ~= "right" then
            sv.position.anchor = "left"
        end
    end

    if type(sv.display) ~= "table" then sv.display = {} end
    ensureNumber(sv.display, "padding", d.display.padding)
    ensureNumber(sv.display, "rowGap", d.display.rowGap)
    ensureNumber(sv.display, "groupGap", d.display.groupGap)
    ensureNumber(sv.display, "borderSize", d.display.borderSize)
    ensureTable(sv.display, "backgroundColor", d.display.backgroundColor)
    ensureTable(sv.display, "borderColor", d.display.borderColor)
    ensureTable(sv.display, "unlockedBorderColor", d.display.unlockedBorderColor)

    if type(sv.styles) ~= "table" then sv.styles = {} end
    for _, state in ipairs({ "offline", "online" }) do
        if type(sv.styles[state]) ~= "table" then sv.styles[state] = {} end
        ensureNumber(sv.styles[state], "fontSize", d.styles[state].fontSize)
        ensureString(sv.styles[state], "fontStyle", d.styles[state].fontStyle)
        if sv.styles[state].fontStyle ~= "normal" and sv.styles[state].fontStyle ~= "bold" then
            sv.styles[state].fontStyle = d.styles[state].fontStyle
        end
        ensureTable(sv.styles[state], "fontColor", d.styles[state].fontColor)
        ensureTable(sv.styles[state], "backgroundColor", d.styles[state].backgroundColor)
    end

    if sv.nameMode ~= "account" and sv.nameMode ~= "character" and sv.nameMode ~= "accountCharacter" and sv.nameMode ~= "characterAccount" then
        sv.nameMode = d.nameMode
    end
    if sv.sortMode ~= "alphabetical" and sv.sortMode ~= "onlineFirst" and sv.sortMode ~= "offlineFirst" then
        sv.sortMode = d.sortMode
    end
    if sv.windowAnchor ~= "left" and sv.windowAnchor ~= "center" and sv.windowAnchor ~= "right" then
        sv.windowAnchor = d.windowAnchor
    end

    sv.dataVersion = 10200
end

function NTST:ScheduleRefresh(delayMs, initial)
    self.pendingRefreshInitial = self.pendingRefreshInitial or initial
    if self.refreshScheduled then return end
    self.refreshScheduled = true
    zo_callLater(function()
        self.refreshScheduled = false
        local useInitial = self.pendingRefreshInitial
        self.pendingRefreshInitial = nil
        self:Refresh(useInitial)
    end, delayMs or EVENT_REFRESH_DELAY_MS)
end

function NTST:RegisterEvents()
    local function schedule() self:ScheduleRefresh(EVENT_REFRESH_DELAY_MS, false) end

    em:RegisterForEvent(self.name, EVENT_FRIEND_PLAYER_STATUS_CHANGED, schedule)
    em:RegisterForEvent(self.name, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, schedule)

    self:UpdateRefreshInterval()
    self:UpdateLocationRefreshInterval()
end

function NTST:UpdateRefreshInterval()
    em:UnregisterForUpdate(self.name .. "Refresh")
    em:RegisterForUpdate(self.name .. "Refresh", self.sv.refreshSeconds * 1000, function()
        self:ScheduleRefresh(FAST_REFRESH_DELAY_MS, false)
    end)
end

function NTST:UpdateLocationRefreshInterval()
    em:UnregisterForUpdate(self.name .. "LocationRefresh")
    if not self.sv or not self.sv.showLocation then return end
    local seconds = math.max(30, tonumber(self.sv.locationRefreshSeconds) or self.defaults.locationRefreshSeconds)
    em:RegisterForUpdate(self.name .. "LocationRefresh", seconds * 1000, function()
        self:ScheduleRefresh(FAST_REFRESH_DELAY_MS, false)
    end)
end

function NTST:Initialize()
    local worldName = GetWorldName and GetWorldName() or "UnknownWorld"
    self.worldName = worldName
    self.sv = ZO_SavedVars:NewAccountWide(self.savedVariablesName, self.savedVariablesVersion, "Settings", self.defaults, worldName)
    self:ApplyMigrations()
    self:CreateUI()
    self:RegisterSceneVisibilityCallbacks()
    self:SetUnlocked(self.sv.uiUnlocked)
    self:CreateSettings()
    self:RegisterEvents()
    zo_callLater(function() self:Refresh(true) end, 1000)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= NTST.name then return end
    em:UnregisterForEvent(NTST.name, EVENT_ADD_ON_LOADED)
    NTST:Initialize()
end

em:RegisterForEvent(NTST.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
