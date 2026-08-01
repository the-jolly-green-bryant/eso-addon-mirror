-- CallToArm_Leaderboard.lua
-- Adds a guild-filtered entry to the built-in Journal > Leaderboards > Campaign
local CallToArm = _G.CallToArm or {}
_G.CallToArm = CallToArm
CallToArm.Leaderboard = CallToArm.Leaderboard or {}

local LB = CallToArm.Leaderboard
local EM = EVENT_MANAGER

LB._initDone = LB._initDone or false
LB._memberCache = LB._memberCache or {}
LB._journalGuildCache = LB._journalGuildCache or {}
LB._lastCacheAt = LB._lastCacheAt or 0
LB._hookedCampaignList = LB._hookedCampaignList or false
LB._lastSelectedGuildId = LB._lastSelectedGuildId or 0

LB.CACHE_THROTTLE_SECONDS = 10

local function NormalizeName(name)
    name = tostring(name or "")
    if name == "" then return "" end
    if zo_strlower then return zo_strlower(name) end
    return string.lower(name)
end

local function GetGuildMemberCharacterName(gid, index)
    if GetGuildMemberCharacterInfo then
        local hasCharacter, characterName = GetGuildMemberCharacterInfo(gid, index)
        if hasCharacter and type(characterName) == "string" and characterName ~= "" then
            return characterName
        end
    end
    return nil
end

local function EnsureCacheForGuild(gid)
    if gid == 0 then return end
    if LB._memberCache[gid] == nil then
        LB._memberCache[gid] = { display = {}, character = {}, rankByDisplay = {}, rankByCharacter = {} }
    end
end

function LB.RefreshGuildMemberCache(gid, force)
    gid = gid or CallToArm.Guild.GetSelectedGuildId()
    if not gid or gid == 0 then return end

    local now = GetTimeStamp()
    if not force and (now - (LB._lastCacheAt or 0)) < LB.CACHE_THROTTLE_SECONDS then
        return
    end

    EnsureCacheForGuild(gid)
    local cache = LB._memberCache[gid]
    cache.display = {}
    cache.character = {}
    cache.rankByDisplay = {}
    cache.rankByCharacter = {}

    local num = GetNumGuildMembers(gid)
    for i = 1, num do
        local displayName, _, rankIndex = GetGuildMemberInfo(gid, i)
        if displayName and displayName ~= "" then
            local key = NormalizeName(displayName)
            cache.display[key] = true
            cache.rankByDisplay[key] = tonumber(rankIndex) or 0
        end

        local characterName = GetGuildMemberCharacterName(gid, i)
        if characterName and characterName ~= "" then
            local key = NormalizeName(characterName)
            cache.character[key] = true
            cache.rankByCharacter[key] = tonumber(rankIndex) or 0
        end
    end

    LB._lastCacheAt = now
end

function LB.IsGuildMemberName(name, gid)
    gid = gid or CallToArm.Guild.GetSelectedGuildId()
    if not gid or gid == 0 then return false end
    local cache = LB._memberCache[gid]
    if not cache then return false end
    local key = NormalizeName(name)
    return cache.display[key] == true or cache.character[key] == true
end

local function GetAllianceColorRGB(alliance)
    if GetAllianceColor then
        local c = GetAllianceColor(alliance)
        if c and c.UnpackRGB then
            return c:UnpackRGB()
        end
    end
    if alliance == ALLIANCE_ALDMERI_DOMINION or alliance == 1 then
        return 1.0, 0.9, 0.2
    elseif alliance == ALLIANCE_EBONHEART_PACT or alliance == 2 then
        return 0.95, 0.3, 0.3
    elseif alliance == ALLIANCE_DAGGERFALL_COVENANT or alliance == 3 then
        return 0.3, 0.6, 1.0
    end
    return 1, 1, 1
end

local function FindNameLabel(control)
    if not control then return nil end
    return control.nameLabel
        or control:GetNamedChild("Name")
        or control:GetNamedChild("DisplayName")
        or control:GetNamedChild("PlayerName")
        or control:GetNamedChild("CharacterName")
        or control:GetNamedChild("NameLabel")
end

function LB.ApplyHighlightToRow(control, data)
    if not CallToArm.SV or not CallToArm.SV.ui or CallToArm.SV.ui.highlightGuildies ~= true then return end
    if not data then return end

    local gid = CallToArm.Guild.GetSelectedGuildId()
    if gid == 0 then return end

    local displayName = data.displayName or data.name
    local characterName = data.characterName or data.charName
    if not LB.IsGuildMemberName(displayName, gid) and not LB.IsGuildMemberName(characterName, gid) then
        return
    end

    local alliance = data.alliance or data.allianceId or (CallToArm.Guild.GetSelectedGuildAlliance and CallToArm.Guild.GetSelectedGuildAlliance())
    local r, g, b = GetAllianceColorRGB(tonumber(alliance) or 0)

    -- Gamepad leaderboard rows expose the account/display-name label as Name
    -- and the character label separately. Highlight both when present.
    local nameLabel = (control and control.nameLabel) or (control and control.GetNamedChild and control:GetNamedChild("Name")) or FindNameLabel(control)
    if nameLabel and nameLabel.SetColor then
        nameLabel:SetColor(r, g, b, 1)
    end
    if control and control.characterNameLabel and control.characterNameLabel.SetColor then
        control.characterNameLabel:SetColor(r, g, b, 1)
    end
end

local function BuildGuildJournalEntries(gid, campaignId, alliance)
    local entries = {}
    if not campaignId or campaignId == 0 then return entries end
    LB.RefreshGuildMemberCache(gid, true)

    if alliance and alliance ~= ALLIANCE_NONE then
        if not GetNumCampaignAllianceLeaderboardEntries or not GetCampaignAllianceLeaderboardEntryInfo then
            return entries
        end
        local num = GetNumCampaignAllianceLeaderboardEntries(campaignId, alliance) or 0
        for i = 1, num do
            local isPlayer, rank, name, points, class, displayName = GetCampaignAllianceLeaderboardEntryInfo(campaignId, alliance, i)
            local display = displayName or name
            if LB.IsGuildMemberName(display, gid) or LB.IsGuildMemberName(name, gid) then
                entries[#entries + 1] = {
                    rank = rank,
                    name = name,
                    points = points,
                    class = class,
                    alliance = alliance,
                    displayName = displayName,
                    isPlayer = isPlayer,
                }
            end
        end
        return entries
    end

    if not GetNumCampaignLeaderboardEntries or not GetCampaignLeaderboardEntryInfo then
        return entries
    end
    local num = GetNumCampaignLeaderboardEntries(campaignId) or 0
    for i = 1, num do
        local isPlayer, rank, name, points, class, allianceId, displayName = GetCampaignLeaderboardEntryInfo(campaignId, i)
        local display = displayName or name
        if LB.IsGuildMemberName(display, gid) or LB.IsGuildMemberName(name, gid) then
            entries[#entries + 1] = {
                rank = rank,
                name = name,
                points = points,
                class = class,
                alliance = allianceId,
                displayName = displayName,
                isPlayer = isPlayer,
            }
        end
    end
    return entries
end

local function GetGuildJournalCache(gid, campaignId, alliance)
    LB._journalGuildCache[gid] = LB._journalGuildCache[gid] or {}
    local key = tostring(campaignId) .. ":" .. tostring(alliance or 0)
    local cache = LB._journalGuildCache[gid][key]
    local now = GetTimeStamp and GetTimeStamp() or 0
    if not cache or (now - (cache.at or 0)) > 5 then
        local entries = BuildGuildJournalEntries(gid, campaignId, alliance)
        cache = { at = now, entries = entries }
        LB._journalGuildCache[gid][key] = cache
    end
    return cache.entries
end

local function TryHookCampaignLeaderboardList()
    if LB._hookedCampaignList or not ZO_PostHook then return true end

    -- API 101050 gamepad leaderboards render player rows through the shared
    -- GAMEPAD_LEADERBOARD_LIST instance. Hook the actual row setup method so
    -- highlights are applied after ESO restores its normal recycled-row colours.
    if GAMEPAD_LEADERBOARD_LIST and GAMEPAD_LEADERBOARD_LIST.SetupLeaderboardPlayerEntry then
        ZO_PostHook(GAMEPAD_LEADERBOARD_LIST, "SetupLeaderboardPlayerEntry", function(self, control, data)
            LB.ApplyHighlightToRow(control, data)
        end)
        LB._hookedCampaignList = true
        if EM then
            EM:UnregisterForUpdate("CALLTOARM_LEADERBOARD_HOOK_RETRY")
        end
        return true
    end

    return false
end

local function AddGuildCategory(self)
    local gid = CallToArm.Guild.GetSelectedGuildId()
    if not gid or gid == 0 then return end
    if CallToArm.SV and CallToArm.SV.ui and CallToArm.SV.ui.guildLeaderboardEnabled ~= true then
        return
    end

    local header = self.leaderboardSystem:AddCategory(
        GetString(SI_CAMPAIGN_LEADERBOARDS_CATEGORIES_HEADER),
        "EsoUI/Art/Journal/leaderboard_indexIcon_ava_up.dds",
        "EsoUI/Art/Journal/leaderboard_indexIcon_ava_down.dds",
        "EsoUI/Art/Journal/leaderboard_indexIcon_ava_over.dds"
    )

    local function GetMaxRank()
        return GetCampaignLeaderboardMaxRank(self.campaignId)
    end

    local function GetGuildCount()
        local entries = GetGuildJournalCache(gid, self.campaignId, ALLIANCE_NONE)
        return #entries
    end

    local function GetGuildInfo(entryIndex)
        local entries = GetGuildJournalCache(gid, self.campaignId, ALLIANCE_NONE)
        local e = entries[entryIndex]
        if not e then return end
        if e.isPlayer then
            self:UpdatePlayerInfo(e.points, entryIndex)
        end
        return e.rank, e.name, e.points, e.class, e.alliance, e.displayName
    end

    local function GetGuildTitle()
        local name = GetGuildName(gid) or "Guild"
        return string.format("%s Leaderboard", name)
    end

    local function GetGuildLeaderboardIcon()
        if GetGuildHeraldryAttribute and GetHeraldryGuildFinderCrestStyleIcon then
            local _, _, _, _, crestCategoryIndex, crestStyleIndex = GetGuildHeraldryAttribute(gid)
            if crestCategoryIndex then
                local crest = GetHeraldryGuildFinderCrestStyleIcon(crestCategoryIndex, crestStyleIndex)
                if crest and crest ~= "" then
                    return crest
                end
            end
        end
        return "EsoUI/Art/Guild/guildHeraldry_background_default.dds"
    end

    local function UpdateGuildPlayerInfo()
        local entries = GetGuildJournalCache(gid, self.campaignId, ALLIANCE_NONE)
        local playerPoints = nil
        local playerGuildRank = nil
        for i = 1, #entries do
            local e = entries[i]
            if e and e.isPlayer then
                playerPoints = e.points
                playerGuildRank = i
                break
            end
        end

        self:UpdatePlayerInfo(playerPoints, playerGuildRank)

        if GAMEPAD_LEADERBOARD_LIST and GAMEPAD_LEADERBOARD_LIST.GetContentHeaderData and ZO_GamepadGenericHeader_RefreshData then
            local headerData = GAMEPAD_LEADERBOARD_LIST:GetContentHeaderData()
            if headerData then
                local guildName = GetGuildName(gid) or "Guild"
                headerData.titleText = string.format("%s Leaderboard", guildName)
                headerData.data1HeaderText = GetString(SI_GAMEPAD_CAMPAIGN_LEADERBOARDS_CURRENT_POINTS_LABEL)
                headerData.data1Text = playerPoints or 0
                headerData.data2HeaderText = "Guild Rank"
                headerData.data2Text = playerGuildRank or GetString(SI_LEADERBOARDS_NOT_RANKED)
                ZO_GamepadGenericHeader_RefreshData(GAMEPAD_LEADERBOARD_LIST.contentHeader, headerData)
            end
        end
    end

    local NO_POINTS_FORMAT_FUNCTION = nil
    local NO_POINTS_HEADER_STRING = nil
    self.leaderboardSystem:AddEntry(
        self,
        "Guild Leaderboard",
        GetGuildTitle,
        header,
        ALLIANCE_NONE,
        GetGuildCount,
        GetMaxRank,
        GetGuildInfo,
        NO_POINTS_FORMAT_FUNCTION,
        NO_POINTS_HEADER_STRING,
        nil,
        GetGuildLeaderboardIcon(),
        LEADERBOARD_TYPE_OVERALL,
        UpdateGuildPlayerInfo
    )
end

function LB.Init()
    if LB._initDone then return end
    LB._initDone = true

    if ZO_PostHook and ZO_CampaignLeaderboardsManager_Shared then
        ZO_PostHook(ZO_CampaignLeaderboardsManager_Shared, "AddCategoriesToParentSystem", function(self)
            AddGuildCategory(self)
        end)
    end

    if not TryHookCampaignLeaderboardList() and EM then
        -- The Journal leaderboard object can be created after addon load.
        -- Retry briefly until the shared gamepad list exists, then unregister.
        EM:RegisterForUpdate("CALLTOARM_LEADERBOARD_HOOK_RETRY", 1000, TryHookCampaignLeaderboardList)
    end

    if EM then
        EM:RegisterForEvent("CALLTOARM_GUILD_ADD", EVENT_GUILD_MEMBER_ADDED, function() LB.RefreshGuildMemberCache(nil, true) end)
        EM:RegisterForEvent("CALLTOARM_GUILD_REM", EVENT_GUILD_MEMBER_REMOVED, function() LB.RefreshGuildMemberCache(nil, true) end)
        EM:RegisterForEvent("CALLTOARM_GUILD_RANK", EVENT_GUILD_MEMBER_RANK_CHANGED, function() LB.RefreshGuildMemberCache(nil, true) end)
        EM:RegisterForEvent("CALLTOARM_GUILD_SELF", EVENT_GUILD_SELF_JOINED_GUILD, function() LB.RefreshGuildMemberCache(nil, true) end)
    end
end
