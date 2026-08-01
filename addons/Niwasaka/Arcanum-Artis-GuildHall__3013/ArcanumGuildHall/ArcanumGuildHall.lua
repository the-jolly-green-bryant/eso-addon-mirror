ArcanumGuildHall = {
    db = nil,
    guildId = 617104,
    name = "ArcanumGuildHall",
    addonName = "Arcanum Artis Guild Hall",
    displayName = "|cea4e49Arcanum|r |cfeee5dArtis|r |c40c0f0Guild Hall|r",
    author = "Niwasaka",
    website = "https://www.esoui.com/downloads/info3013-ArcanumArtisGuildHall.html",
    slashCommand = "/artis",
    version = "1.22.0",
    guildIndex = 0,

    defaults = {
        showChatIcon = true,
        monochromeIcon = false,
        colorizeNames = true,
        noGuildLeave = 0,
        enableReminder = true,
        selectedReminderDay = os.date("%A", 1634018400),
        showReminder = true,
        firstTimeInfoShown = false,
        enableNotChange = false,
        enableTomeAutoClaim = true,
        autoTrackTomes = false,
        showTomeProgressBar = true,
        enableTomeAlert = true,
        locationTomeAlert = 0,
        showTomeIcon = true,
        showTomeIconUI = true,
        tomeColorWeekly = "|c3595de",
        tomeColorSeasonal = "|c3595de",
        showTomeReward = false,
        showSeasonalTomeProgress = false,
        tomeWindowX = nil,
        tomeWindowY = nil,
        tomeWindowVisible = false,
        tomeWindowLastFilter = "weekly",
        tomeWindowCompactMode = false,
        tomeWindowBackgroundAlpha = 100,
        tomeIconUIX = 0,
        tomeIconUIY = 900,
        showClock = true,
        isInCombatClock = true,
        clockDst = true,
        clockFontSize = 20,
        clockFontOutline = "none",
        clockFontColor = "|cffffff",
        clockTextFont = "Univers 67",
        showClockBG = true,
        clockBackground = "ESO Status",
        clockBackgroundColor = "|c3595de",
        clockBackgroundAlpha = 100,
        showInGameTime = false,
        inGameTimeColor = "ffffff",
        inGameTimeDelta = 10,
        showChatTimestamp = true,
        showChatGuildIcon = 1,
        showChatGuildIconColor = true,
        showAnnouncements = true,
        showChatAnnouncements = true,
        showNotifAnnouncements = true,
        showChangelog = true,
        welcomeVersion = 0,
        storeRepairMode = 0,
        verboseStore = true,
        repairThreshold = 15,
        useAnyKit = true,
        verboseKits = true,
        rechargeMode = 0,
        rechargeThreshold = 15,
        useAnyGem = true,
        verboseGems = true,
        lastTeleportTab = "network",
        lastTeleportCategoryFilter = "all",
        lastTeleportHouseFilter = "all",
        challengeDisplayMode = "chat",
        challengesWindowVisible = false,
        challengesWindowLastTab = "pledges",
        challengesWindowX = nil,
        challengesWindowY = nil,
        deconQualityNormal = true,
        deconQualityFine = true,
        deconQualitySuperior = true,
        deconQualityEpic = true,
        deconQualityLegendary = false,
        deconOrnateItems = false,
        deconIntricateItems =false,
        deconResearchableItems = false,
    },

    panel = nil,
    chatIcon = nil
}

function ArcanumGuildHall:UpdateGuildIndex()
    self.guildIndex = self:findGuildIndex()
end

function ArcanumGuildHall:Initialize()
    self.db = ZO_SavedVars:NewAccountWide("ArcanumArtisSavedVars", 1, nil, self.defaults)

    self:InitializeMenu()
    self:InitializeTeleportModule()
    self:InitializeChatIcon()
    self:InitializeNames()
    self:InitializeNoGuildLeave()
    self:InitializeChallengesWindow()
    self:ShowFirstTimeInfo()
    self:ShowNotification()
    self:InitializeTomeAlerts()
    self:InitializeTomeWindow()
    self:InitializeTomeIcon()
    self:InitializeChatMenu()
    self:InitClock()
    self:InitializeChatSystem()
    self:ShowChatIcon(self.db.showChatIcon)
    self:SetChatIconTexture(self.db.monochromeIcon)
    self:UpdateGuildIndex()
    self:IsPlayerInCombat()
    self:UpdateGroupMembers()
    self:SetChatHook()
    self:ChangelogScreen()
    self:ShowInventoryContextMenu()
    self:ShowWelcomeText()
    self:SetupDeconSelectAll()

    EVENT_MANAGER:UnregisterForEvent(ArcanumGuildHall.name, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(ArcanumGuildHall.name, EVENT_GUILD_MEMBER_NOTE_CHANGED, ArcanumGuildHall.OnGuildDescChanged)
    if self.db.storeRepairMode == 0 or self.db.storeRepairMode == 1 then
        EVENT_MANAGER:RegisterForEvent(ArcanumGuildHall.name, EVENT_OPEN_STORE, ArcanumGuildHall.OnOpenStore)
    else
        EVENT_MANAGER:UnregisterForEvent(ArcanumGuildHall.name, EVENT_OPEN_STORE)
    end
    if self.db.rechargeMode == 0 or self.db.rechargeMode == 1 then
        EVENT_MANAGER:RegisterForEvent(ArcanumGuildHall.name, EVENT_PLAYER_ALIVE, ArcanumGuildHall.OnPlayerAlive)
        EVENT_MANAGER:RegisterForEvent(ArcanumGuildHall.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ArcanumGuildHall.OnInventorySingleSlotUpdate)
        EVENT_MANAGER:AddFilterForEvent(ArcanumGuildHall.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    else
        EVENT_MANAGER:UnregisterForEvent(ArcanumGuildHall.name, EVENT_PLAYER_ALIVE)
        EVENT_MANAGER:UnregisterForEvent(ArcanumGuildHall.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    end
    EVENT_MANAGER:RegisterForEvent(ArcanumGuildHall.name, EVENT_GUILD_SELF_JOINED_GUILD, function()
        self:RefreshGuildChatData()
    end)

    EVENT_MANAGER:RegisterForEvent(ArcanumGuildHall.name, EVENT_GUILD_SELF_LEFT_GUILD, function()
        self:RefreshGuildChatData()
    end)

    EVENT_MANAGER:RegisterForEvent(ArcanumGuildHall.name, EVENT_GUILD_DESCRIPTION_CHANGED, function(_, guildId)
        if guildId == ArcanumGuildHall.guildId then
            ArcanumGuildHall.guildHouseDataCache = nil
        end
    end)

    EVENT_MANAGER:RegisterForEvent(ArcanumGuildHall.name, EVENT_PLAYER_COMBAT_STATE, function(...)
        self:IsPlayerInCombat(...)
    end)

    EVENT_MANAGER:RegisterForEvent(ArcanumGuildHall.name, EVENT_GROUP_MEMBER_JOINED, function()
        self:UpdateGroupMembers()
    end)
    EVENT_MANAGER:RegisterForEvent(ArcanumGuildHall.name, EVENT_GROUP_MEMBER_LEFT, function()
        self:UpdateGroupMembers()
    end)

    SLASH_COMMANDS["/repair"] = ArcanumGuildHall.RepairItemsWithKits
    SLASH_COMMANDS["/recharge"] = ArcanumGuildHall.RechargeItemsWithGems
    SLASH_COMMANDS["/rnr"] = ArcanumGuildHall.RepairRecharge
    SLASH_COMMANDS["/tomes"] = function()
        ArcanumGuildHall:ToggleTomeWindow()
    end
end

function ArcanumGuildHall.OnAddOnLoaded(_, addon)
    if addon == ArcanumGuildHall.name then
        ArcanumGuildHall:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(ArcanumGuildHall.name, EVENT_ADD_ON_LOADED, ArcanumGuildHall.OnAddOnLoaded)