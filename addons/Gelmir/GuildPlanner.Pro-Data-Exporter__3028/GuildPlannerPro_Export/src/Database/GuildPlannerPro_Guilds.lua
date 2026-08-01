GuildPlannerPro_Guilds = {}

function GuildPlannerPro_Guilds:GetGuilds()
    local guilds = {}
    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        local numMembers, _, leaderName, _ = GetGuildInfo(guildId)
        local isPlayerGuildMaster = IsPlayerGuildMaster(guildId)

        guilds[guildId] = {
            Id = guildId,
            Name = GetGuildName(guildId),
            LeaderName = leaderName,
            IsPlayerGuildMaster = isPlayerGuildMaster,
            Description = GetGuildDescription(guildId),
            Motd = GetGuildMotD(guildId),
            Link = GetGuildRecruitmentLink(guildId, LINK_STYLE_BRACKETS),
            FoundedAt = GetGuildFoundedDate(guildId),
            FactionId = GetGuildAlliance(guildId),
            NumMembers = numMembers,
            Language = GetGuildLanguageAttribute(guildId),
        }

        local claimedKeepId, claimedKeepCampaignId = GetGuildClaimedKeep(guildId)
        guilds[guildId].ClaimedKeepId = claimedKeepId
        guilds[guildId].ClaimedKeepCampaignId = claimedKeepCampaignId

        guilds[guildId].OwnedKioskName = GetGuildOwnedKioskInfo(guildId)

        local recruitmentMessage,headerMessage, recruitmentStatus, primaryFocus, secondaryFocus, personality, language, minimumCP = GetGuildRecruitmentInfo(guildId)
        guilds[guildId].RecruitmentMessage = recruitmentMessage
        guilds[guildId].HeaderMessage = headerMessage
        guilds[guildId].RecruitmentStatus = recruitmentStatus -- @todo @deprecated
        guilds[guildId].IsRecruiting = recruitmentStatus == GUILD_RECRUITMENT_STATUS_ATTRIBUTE_VALUE_LISTED
        guilds[guildId].RecruitmentStartTime = GetGuildRecruitmentStartTime(guildId)
        guilds[guildId].RecruitmentEndTime = GetGuildRecruitmentEndTime(guildId)
        guilds[guildId].PrimaryFocus = GuildPlannerPro_Const.GuildFocusAttributeValue[primaryFocus]
        guilds[guildId].SecondaryFocus = GuildPlannerPro_Const.GuildFocusAttributeValue[secondaryFocus]
        guilds[guildId].Personality = personality
        guilds[guildId].Language = GuildPlannerPro_Const.GuildLanguageAttributeValue[language]
        guilds[guildId].MinimumCP = minimumCP

        if isPlayerGuildMaster then
            guilds[guildId].Privileges = {
                [GuildPlannerPro_Const.GuildPrivilege[GUILD_PRIVILEGE_BANK_DEPOSIT]] = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_BANK_DEPOSIT),
                [GuildPlannerPro_Const.GuildPrivilege[GUILD_PRIVILEGE_TRADING_HOUSE]] = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_TRADING_HOUSE),
                [GuildPlannerPro_Const.GuildPrivilege[GUILD_PRIVILEGE_HERALDRY]] = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_HERALDRY),
            }

            local backgroundCategoryIndex, backgroundStyleIndex, backgroundPrimaryColorIndex, backgroundSecondaryColorIndex, crestCategoryIndex, crestStyleIndex, crestColorIndex = GetGuildHeraldryAttribute(guildId)
            guilds[guildId].Heraldry = {
                BackgroundIcon = GuildPlannerPro_Const.HeraldryBackgrounds[backgroundCategoryIndex][backgroundStyleIndex],
                BackgroundPrimaryColor = GuildPlannerPro_Const.HeraldryColors[backgroundPrimaryColorIndex],
                BackgroundSecondaryColor = GuildPlannerPro_Const.HeraldryColors[backgroundSecondaryColorIndex],
                CrestIcon = GuildPlannerPro_Const.HeraldryCrests[crestCategoryIndex][crestStyleIndex],
                CrestColor = GuildPlannerPro_Const.HeraldryColors[crestColorIndex],
            }

            local ranks = {}
            local numGuildRanks = GetNumGuildRanks(guildId)
            for guildRankIndex = 1, numGuildRanks do
                rankPermissions = {}
                for permission = GUILD_PERMISSION_ITERATION_BEGIN, GUILD_PERMISSION_ITERATION_END do
                    rankPermissions[permission] = {
                        Permission = permission,
                        Value = DoesGuildRankHavePermission(guildId, guildRankIndex, permission),
                    }
                end
                ranks[guildRankIndex] = {
                    Id = GetGuildRankId(guildId, guildRankIndex),
                    Name = GetGuildRankCustomName(guildId, guildRankIndex),
                    Index = guildRankIndex,
                    Icon = GetGuildRankSmallIcon(GetGuildRankIconIndex(guildId, guildRankIndex)),
                    IsGuildMaster = IsGuildRankGuildMaster(guildId, guildRankIndex),
                    Permissions = rankPermissions,
                }
            end
            guilds[guildId].Ranks = ranks

            local members = {}
            for memberIndex = 1, numMembers do
                local name, note, rankIndex, _, secsSinceLogoff = GetGuildMemberInfo(guildId, memberIndex)
                members[memberIndex] = {
                    Name = name,
                    IsGuildMaster = leaderName == name,
                    Note = note,
                    RankIndex = rankIndex,
                    SecsSinceLogoff = secsSinceLogoff,
                }
            end
            guilds[guildId].Members = members

            local applications = {}
            local numApplications = GetGuildFinderNumGuildApplications(guildId)
            for applicationIndex = 1, numApplications do
                local level, championPoints, alliance, classId, accountName, characterName, achievementPoints, applicationMessage = GetGuildFinderGuildApplicationInfoAt(guildId, applicationIndex)
                applications[applicationIndex] = {
                    Account = accountName,
                    Character = characterName,
                    ClassId = classId,
                    Alliance = alliance,
                    AchievementPoints = achievementPoints,
                    TimeRemaining = GetGuildFinderGuildApplicationDuration(guildId, applicationIndex),
                    ApplicationMessage = applicationMessage,
                    Level = level,
                    ChampionPoints = championPoints,
                }
            end
            guilds[guildId].Applications = applications

            local blacklist = {}
            local numBlacklistEntries = GetNumGuildBlacklistEntries(guildId)
            for blacklistIndex = 1, numBlacklistEntries do
                local accountName, note = GetGuildBlacklistInfoAt(guildId, blacklistIndex)
                blacklist[blacklistIndex] = {
                    Account = accountName,
                    Note = note,
                }
            end
            guilds[guildId].Blacklist = blacklist
        end
    end

    return guilds
end

function GuildPlannerPro_Guilds:GetSelectedGuildBankedGold()
    if IsGuildBankOpen() then
        local guildId = GetSelectedGuildBankId()
        local amount = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_GUILD_BANK)
        if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_VIEW_GOLD) then
            return amount
        end
    end

    return nil
end
