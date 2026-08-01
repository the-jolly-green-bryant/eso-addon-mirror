ElderTurks = {}

ElderTurks.name = "ElderTurks"
ElderTurks.guildID = 580494
ElderTurks.guildIndex = 0
ElderTurks.update = false
ElderTurks.notice = true;

function ElderTurks:Initialize()
    self.savedVariables = ZO_SavedVars:NewAccountWide("ElderTurksVars", 1, nil, {})

    if not IsPlayerInGuild(ElderTurks.guildID) then
        return
    end
    ElderTurks.setGuildIndex()
    ZO_GuildHomeKeep:SetAnchor(3, ZO_GuildHome, 3, 20, 70)
    ZO_GuildHomeTrader:SetAnchor(TOP, ZO_GuildHomeKeepCampaignName, BOTTOM, 0, 10)

    local fragment = ZO_SimpleSceneFragment:New(ElderTurksGuildHome)
    GUILD_HOME_SCENE:AddFragment(fragment)
    ElderTurksGuildHome:SetHidden(true)
    ElderTurks.members = {}
    ElderTurks.FetchMembers()
    ElderTurks.createOfficersTable()
    ElderTurks.createSlashCommands()
    ElderTurks.TranslateUI()
end

function ElderTurks.OnAddOnLoaded(event, addonName)
    if addonName == ElderTurks.name then
        ElderTurks:Initialize()
    end
end

function ElderTurks.OnPlayerActivated()
    ElderTurks.RepetitiveTranslateUI()
    if not ElderTurks.notice then
        return
    end
    if ElderTurks.guildIndex > 0 then
        d('|c339FFBElder Turks aktif!|r')
    else
        d('|c339FFBElder Turks pasif, lonca uyesi değilsin!|r')
    end
    ElderTurks.notice = false
end

function ElderTurks.FetchMembers()
    local members = GetNumGuildMembers(ElderTurks.guildID)
    for member = 1, members, 1 do
        local player, note, rank, status, activelast = GetGuildMemberInfo(ElderTurks.guildID, member)
        ElderTurks.members[player] = {}
        ElderTurks.members[player].character = player
    end
end

function ElderTurks.OnTargetChange(eventCode)
    local unitTag = "reticleover"
    local type = GetUnitType(unitTag)
    local player = GetUnitDisplayName(unitTag)
    local name = GetUnitName(unitTag)
    if name == nil or name == "" then
        return
    end

    if type == UNIT_TYPE_PLAYER then
        local inguild = ElderTurks.IsUnitInGuild(player)
        if (inguild == true) then
            ElderTurks.update = true
        end
    end
end

function ElderTurks.UpdateUnitFrame()
    if (ElderTurks.update == true) then
        local name = ZO_TargetUnitFramereticleoverName:GetText()
        local uid = GetUnitDisplayName("reticleover")
        local nameStr = ""
        if uid == "@SamaelHQ" or uid == "@aliakgul" then
            nameStr = "|cCC0000Elder|r " .. name .. " |cCC0000(ET)|r"
        elseif ElderTurks.officers[uid] ~= nil then
            nameStr = "|c0000eeMuhafız|r " .. name .. " |cCC0000(ET)|r"
        else
            nameStr = name .. " |cCC0000(ET)|r"
        end
        ZO_TargetUnitFramereticleoverName:SetText(nameStr)
        ElderTurks.update = false
    end
end

function ElderTurks.IsUnitInGuild(player)
    local inguild = player and ElderTurks.members[player] ~= nil and ElderTurks.members[player].character == player
    return inguild
end

function ElderTurks.GuildMemberAdded(eventCode, guildId, displayName)
    if guildId == ElderTurks.guildID then
        ElderTurks.clearGuildTable()
        ElderTurks.FetchMembers()
    end
end

function ElderTurks.GuildMemberRemoved(eventCode, guildId, displayName, characterName)
    if guildId == ElderTurks.guildID then
        ElderTurks.clearGuildTable()
        ElderTurks.FetchMembers()
    end
end

function ElderTurks.clearGuildTable()
    ElderTurks.members = {}
end

function ElderTurks.TeleportToGuildHouse()
    d("Lonca evine ışınlanıyorsunuz, lütfen bekleyin...")
    if GetDisplayName() == "@SamaelHQ" then
        RequestJumpToHouse(GetHousingPrimaryHouse())
    else
        JumpToHouse('@SamaelHQ')
    end
end

function ElderTurks.setGuildIndex()
    if GetGuildId(1) == ElderTurks.guildID then
        ElderTurks.guildIndex = 1
    elseif GetGuildId(2) == ElderTurks.guildID then
        ElderTurks.guildIndex = 2
    elseif GetGuildId(3) == ElderTurks.guildID then
        ElderTurks.guildIndex = 3
    elseif GetGuildId(4) == ElderTurks.guildID then
        ElderTurks.guildIndex = 4
    else
        ElderTurks.guildIndex = 5
    end
end

function ElderTurks.createSlashCommands()
    SLASH_COMMANDS["/discord"] = ElderTurks.CommandDiscord
    SLASH_COMMANDS["/oylama"] = ElderTurks.CommandVote
end

function ElderTurks.CommandDiscord()
    ZO_ChatWindowTextEntryEditBox:SetText("https://discord.gg/tN5kfPM")
    d("ElderTurks Discord Davet Linki: " .. "https://discord.gg/tN5kfPM")
end

function ElderTurks.CommandVote(extra)
    if IsPlayerInGroup(GetDisplayName()) then
        ElderTurks.VoteText = extra
        BeginGroupElection(GROUP_ELECTION_TYPE_GENERIC_SIMPLEMAJORITY, extra, nil)
    else
        d("Oylama başlatmak için bir grupta olmalısın!")
    end
end

function ElderTurks.ElectionResult(eventCode, electionResult, descriptor)
    if ElderTurks.VoteText ~= nil and ElderTurks.VoteText == descriptor then
        if electionResult == GROUP_ELECTION_RESULT_ELECTION_WON then
            d("Oylama kabul edildi!")
        else
            d("Oylama reddedildi!")
        end
        ElderTurks.VoteText = nil
    end
end

function ElderTurks.createOfficersTable()
    ElderTurks.officers = {}
    ElderTurks.officers["@Thevealiath"] = "@Thevealiath"
    ElderTurks.officers["@AdigePsase"] = "@AdigePsase"
    ElderTurks.officers["@DeathswiT"] = "@DeathswiT"
    ElderTurks.officers["@Shandrot"] = "@Shandrot"
end

function ElderTurks.TranslateUI()
    -- Guild
    ZO_GuildSharedInfoCountLabel:SetText("Çevrimiçi Üyeler:")
    ZO_GuildHomeGuildMasterLabel:SetText("Lonca Lideri:")
    ZO_GuildHomeFoundedLabel:SetText("Kuruluş:")

    ZO_GuildHomeInfoUpdatesHeader:SetText("HABERLER")
    ZO_GuildHomeInfoMotDHeader:SetText("Günün mesajı")
    ZO_GuildHomeInfoBackgroundHeader:SetText("LONCA BİLGİLERİ")
    ZO_GuildHomeInfoDescriptionHeader:SetText("Hakkımızda")

    ZO_GuildHomeKeepOwnership:SetText("ALLIANCE WAR\nMÜLKİYETİ")
    ZO_GuildHomeTraderOwnership:SetText("LONCA PAZARI")
    ElderTurksGuildHomeTitle:SetText("ELDER TURKS\nLONCA EVİ")

    ZO_GuildRosterHideOfflineLabel:SetText("Çevrimdışı Üyeleri Gizle")
    ZO_GuildRosterSearchBoxText:SetText("Karakter adı veya UserID girin")
    ZO_GuildRosterSearchLabel:SetText("Filtrele:")
    ZO_GuildRosterHeadersZoneName:SetText("KONUM")
    ZO_GuildRanksListHeader:SetText("RÜTBELER")

    ZO_GuildHistoryCategoriesZO_IconHeader1Text:SetText("LONCA ")
    ZO_GuildHistoryCategoriesZO_IconHeader2Text:SetText("BANKA")
    ZO_GuildHistoryCategoriesZO_IconHeader3Text:SetText("SATIŞLAR")
    -- Group
    ZO_GroupMenu_KeyboardPreferredRolesLabel:SetText("ROL")
    ZO_GroupListNoGroupRowMessage:SetText(
        "Bir gruba katılmak için herhangi bir oyuncuyu davet edin veya aktivite bulucuyu kullanın.")
    ZO_GroupListVeteranDifficultySettingsText:SetText("Zindan Modu:")
    ZO_GroupListHeadersCharacterName:SetText("KARAKTER ADI")
    ZO_GroupListHeadersZone:SetText("KONUM")
    ZO_GroupListHeadersClass:SetText("SINIF")
    ZO_GroupListHeadersLevel:SetText("SVY")
    ZO_GroupListHeadersRole:SetText("ROL")

end

function ElderTurks.DelayedTranslateUI()
    if ZO_StatsPanelPaneScrollChildHeader1 == nil then
        return
    end
    EVENT_MANAGER:UnregisterForUpdate("charscrntrans")
    -- Character
    ZO_StatsPanelTitleSectionAllianceIcon:SetColor(0.6, 0.04, 0.1, 0.9)

    local raceclass = ZO_StatsPanelTitleSectionRaceClass:GetText()
    raceclass = "Irk / Sınıf: " .. raceclass
    ZO_StatsPanelTitleSectionRaceClass:SetText(raceclass)
    ZO_StatsPanelTitleSectionEquipmentBonusHeader:SetText("Ekipman Bonusu")

    ZO_StatsPanelPaneScrollChildHeader1:SetText("DETAYLAR")
    ZO_StatsPanelPaneScrollChildDropdownRow1Name:SetText("Ünvan")
    ZO_StatsPanelPaneScrollChildDropdownRow2Name:SetText("Kıyafet")
    ZO_StatsPanelPaneScrollChildIconRow1Name:SetText("Alliance Seviyesi")
    ZO_StatsPanelPaneScrollChildBountyRow1Name:SetText("Başına Konan Ödül")
    ZO_StatsPanelPaneScrollChildHeader2AttributePointsLabel:SetText("Attribute Puanları: ")

    ZO_StatsPanelAttributesPointerBoxContents:SetText(
        "Kullanılmamış attribute puanların var. Bunları kullanarak magicka ve stamina ve sağlığını arttırabilirsin.")
    ZO_StatsPanelPaneScrollChildAttributesRow1HealthName:SetText("Sağlık")

    ZO_StatsPanelPaneScrollChildStatsRow1Stat1Name:SetText("Maksimum Magicka")
    ZO_StatsPanelPaneScrollChildStatsRow2Stat1Name:SetText("Maksimum Sağlık")
    ZO_StatsPanelPaneScrollChildStatsRow3Stat1Name:SetText("Maksimum Stamina")
    ZO_StatsPanelPaneScrollChildStatsRow1Stat2Name:SetText("Magicka Yenilenmesi")
    ZO_StatsPanelPaneScrollChildStatsRow2Stat2Name:SetText("Sağlık Yenilenmesi")
    ZO_StatsPanelPaneScrollChildStatsRow3Stat2Name:SetText("Stamina Yenilenmesi")

    ZO_StatsPanelPaneScrollChildHeader3:SetText("SÜRÜŞ YETENEĞİ")

    ZO_StatsPanelPaneScrollChildStableRow1SpeedInfo:SetWidth(120)
    local m_speed = ZO_StatsPanelPaneScrollChildStableRow1SpeedInfoStat:GetText()
    m_speed = "H: " .. m_speed
    ZO_StatsPanelPaneScrollChildStableRow1SpeedInfoStat:SetText(m_speed)

    ZO_StatsPanelPaneScrollChildStableRow1StaminaInfo:SetWidth(120)
    local m_stamina = ZO_StatsPanelPaneScrollChildStableRow1StaminaInfoStat:GetText()
    m_stamina = "D: " .. m_stamina
    ZO_StatsPanelPaneScrollChildStableRow1StaminaInfoStat:SetText(m_stamina)

    ZO_StatsPanelPaneScrollChildStableRow1CarryInfo:SetWidth(120)
    local m_carry = ZO_StatsPanelPaneScrollChildStableRow1CarryInfoStat:GetText()
    m_carry = "K: " .. m_carry
    ZO_StatsPanelPaneScrollChildStableRow1CarryInfoStat:SetText(m_carry)

    ZO_StatsPanelPaneScrollChildHeader4:SetText("AKTİF ETKİLER")
end

function ElderTurks.RepetitiveTranslateUI()
    -- GROUP
    ZO_GroupMenu_KeyboardCategoriesScrollChildZO_GroupMenuKeyboard_StatusIconChildlessHeader1Text:SetText("GRUP")
    ZO_GroupMenu_KeyboardCategoriesScrollChildZO_GroupMenuKeyboard_StatusIconChildlessHeader2Text:SetText("BÖLGE REHBERİ")
    ZO_GroupMenu_KeyboardCategoriesScrollChildZO_GroupMenuKeyboard_StatusIconChildlessHeader3Text:SetText("ZİNDAN ARA")
    ZO_GroupMenu_KeyboardCategoriesScrollChildZO_GroupMenuKeyboard_StatusIconChildlessHeader4Text:SetText("SAVAŞ ALANLARI")
end

function ElderTurks.TranslateCollections()

    -- Collections
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelSearchLabel)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelSearchBoxText)

    ElderTurks.CheckAndTranslate(
        ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_StatusIconChildlessHeader1Text)
    ElderTurks.CheckAndTranslate(
        ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_StatusIconHeader1Text)
    ElderTurks.CheckAndTranslate(
        ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_StatusIconHeader2Text)
    ElderTurks.CheckAndTranslate(
        ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_StatusIconHeader3Text)
    ElderTurks.CheckAndTranslate(
        ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_StatusIconChildlessHeader2Text)
    ElderTurks.CheckAndTranslate(
        ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_StatusIconChildlessHeader3Text)
    ElderTurks.CheckAndTranslate(
        ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_StatusIconChildlessHeader4Text)
    ElderTurks.CheckAndTranslate(
        ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_StatusIconHeader4Text)
    ElderTurks.CheckAndTranslate(
        ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_StatusIconChildlessHeader5Text)
    ElderTurks.CheckAndTranslate(
        ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_StatusIconHeader5Text)

    -- Appearance
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory1)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory2)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory3)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory4)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory5)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory6)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory7)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory8)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory9)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory10)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory11)

    -- Furnishings
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory12)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory13)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory14)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory15)
    ElderTurks.CheckAndTranslate(ZO_CollectionsBook_TopLevelCategoriesScrollChildZO_CollectionsBook_SubCategory16)
end

function ElderTurks.CheckAndSet(item, text)
    if item == nil then
        return;
    end
    if (item:GetText() == text) then
        return
    end
    item:SetText(text)
end

function ElderTurks.CheckAndTranslate(item)
    if item == nil then
        return;
    end
    local value = ElderTurks.GetTranslation(item:GetText())
    ElderTurks.CheckAndSet(item, value)
end

function ElderTurks.GetTranslation(text)
    local value = ElderTurks.Translations[text]
    if value == nil then
        return text
    else
        return value
    end
end

ElderTurks.Translations = {}

ElderTurks.Translations["Filter By"] = "Filtrele"
ElderTurks.Translations["Search"] = "Ara"
ElderTurks.Translations["UPGRADE"] = "YÜKSELTMELER"
ElderTurks.Translations["APPEARANCE"] = "GÖRÜNÜM"
ElderTurks.Translations["FURNISHINGS"] = "EV EŞYALARI"
ElderTurks.Translations["FRAGMENTS"] = "FRAGMENTLER"
ElderTurks.Translations["ASSISTANTS"] = "ASİSTANLAR"
ElderTurks.Translations["MEMENTOS"] = "MEMENTOLAR"
ElderTurks.Translations["TOOLS"] = "ALETLER"
ElderTurks.Translations["MOUNTS"] = "BİNEKLER"
ElderTurks.Translations["NON-COMBAT PETS"] = "SÜS PETLER"
ElderTurks.Translations["EMOTES"] = "İFADELER"
ElderTurks.Translations["Hats"] = "Şapkalar"
ElderTurks.Translations["Hair Styles"] = "Saç Stilleri"
ElderTurks.Translations["Head Markings"] = "Makyaj"
ElderTurks.Translations["Facial Hair"] = "Sakallar"
ElderTurks.Translations["Major Adornments"] = "Aksesuarlar"
ElderTurks.Translations["Minor Adornments"] = "Takılar"
ElderTurks.Translations["Costumes"] = "Kostümler"
ElderTurks.Translations["Body Markings"] = "Dövmeler"
ElderTurks.Translations["Skins"] = "Ciltler"
ElderTurks.Translations["Personalities"] = "Tavırlar"
ElderTurks.Translations["Polymorphs"] = "Polimorflar"
ElderTurks.Translations["General"] = "Genel"
ElderTurks.Translations["Storage"] = "Depo"
ElderTurks.Translations["Undaunted Busts"] = "Undaunted Büstleri"
ElderTurks.Translations["Undaunted Trophies"] = "Undaunted Avları"
ElderTurks.Translations["Houseguests"] = "Ev Misafirleri"

--[[ FOR DEBUGGING
function ElderTurks.countMembers()
    local count = 0
    for _ in pairs(ElderTurks.members) do
        count = count + 1
    end
    d("c:" .. count)
end
]]--

EVENT_MANAGER:RegisterForEvent(ElderTurks.name, EVENT_ADD_ON_LOADED, ElderTurks.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ElderTurks.name, EVENT_PLAYER_ACTIVATED, ElderTurks.OnPlayerActivated)
EVENT_MANAGER:RegisterForEvent(ElderTurks.name, EVENT_RETICLE_TARGET_CHANGED, ElderTurks.OnTargetChange)
EVENT_MANAGER:RegisterForEvent(ElderTurks.name, EVENT_GUILD_MEMBER_ADDED, ElderTurks.GuildMemberAdded)
EVENT_MANAGER:RegisterForEvent(ElderTurks.name, EVENT_GUILD_MEMBER_REMOVED, ElderTurks.GuildMemberRemoved)
EVENT_MANAGER:RegisterForEvent(ElderTurks.name, EVENT_GUILD_MEMBER_CHARACTER_UPDATED, ElderTurks.GuildMemberAdded)
EVENT_MANAGER:RegisterForEvent(ElderTurks.name, EVENT_GROUP_ELECTION_RESULT, ElderTurks.ElectionResult)
EVENT_MANAGER:RegisterForUpdate("charscrntrans", 5000, ElderTurks.DelayedTranslateUI)
EVENT_MANAGER:RegisterForUpdate("collectionstrans", 5000, ElderTurks.TranslateCollections)
