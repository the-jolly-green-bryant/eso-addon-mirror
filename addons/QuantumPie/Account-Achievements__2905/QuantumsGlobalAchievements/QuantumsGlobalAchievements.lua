if QUANTUMPIES_GA == nil then QUANTUMPIES_GA = {} end
local addon = QUANTUMPIES_GA

addon["name"] = "QuantumsGlobalAchievements"
addon["groupCategoryName"] = "QP_GA_GROUP"
addon["varsVersionSettings"] = 10
addon["varsVersionAchievement"] = 10

local defaultSettings = {
    accountProgressBar = { 0.97, 0.87, 0.29, 1 },
    settingServerSeparation = false,
    settingDevMode = false,
    settingsUseVotansWindow = false,
    settingsSolidScore = false,
    settingsSolidName = true,
    settingsSolidDescription = true,
    totalPointsEarned = 0,
    apiVersion = 100033,
}

local defaultAchievements = {
    -- achievements = {
    --     [categoryName] = {
    --         earnedPoints = 100,
    --         categoryIndex = 0,
    --         subCategories = {
    --             [subCategoryName] = {
    --                 [achievementName] = {
    --                     id = 0,
    --                     points = 5,
    --                     lineCount? = 3
    --                     lineProgress? = 2
    --                     characters = {id = characterId, date = "1/12/2014", progress? = "2/3"}
    --                 }
    --             }
    --         }
    --     }
    -- }
    achievements = {},
    charactersLoaded = {},
}

local GENERAL_NAME = QUANTUMPIES_GA_CONSTANTS.generalCategoryName
local em = GetEventManager()
local ACHIEVEMENT_STATUS_BAR_WIDTH = 345
local SUMMARY_CATEGORY_BAR_HEIGHT = 16
local SUMMARY_CATEGORY_PADDING = 50
local SUMMARY_STATUS_BAR_WIDTH = 240
local FORCE_HIDE_PROGRESS_TEXT = true

local function TableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

--  =====================================1
--  |     SUMMARY COMPONENT METHODS     |
--  =====================================
function addon:InitNewSummary()
    self.summaryInset = ZO_AchievementsContents:GetNamedChild("SummaryInset")
    self.summaryProgressBars = self.summaryInset:GetNamedChild("ProgressBars")
    self.summaryProgressBars:SetHidden(true)

    self.newProgressBars = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)QuantumsGAProgressBars", self.summaryInset, 'QuantumsGA_ProgressBars')

    self.summaryProgressBarsScrollChild = self.newProgressBars:GetNamedChild("ScrollChild")

    --  START
    local function InitializeSummaryStatusBar(isTotalBar, statusBar)
        local color = self.svSettings.accountProgressBar
        ZO_StatusBar_SetGradientColor(statusBar, ZO_XP_BAR_GRADIENT_COLORS)
        statusBar.category = statusBar:GetNamedChild("Label")
        statusBar.progress = statusBar:GetNamedChild("Progress")
        statusBar:GetNamedChild("BG"):SetDrawLevel(1)
        statusBar:GetNamedChild("Gloss"):SetDrawLevel(2)
        statusBar:SetWidth(SUMMARY_STATUS_BAR_WIDTH)
        statusBar:SetDrawLevel(1)
        statusBar.character = statusBar:GetNamedChild("Character")
        statusBar.character:SetWidth(SUMMARY_STATUS_BAR_WIDTH)
        if not isTotalBar then
            statusBar.character:SetWidth(SUMMARY_STATUS_BAR_WIDTH)
        else
            statusBar.character:SetWidth(select(1, statusBar:GetDimensions()))
        end
        statusBar.character:SetAnchor(RIGHT, statusBar, nil, 0, 0)
        --ZO_StatusBar_SetGradientColor(statusBar.character, ZO_SKILL_XP_BAR_GRADIENT_COLORS)
        statusBar.character:SetColor(color[1], color[2], color[3], color[4])

        return statusBar
    end

    self.summaryTotal = InitializeSummaryStatusBar(true, self.summaryProgressBarsScrollChild:GetNamedChild("Total"))

    self.summaryStatusBarPool = ZO_ControlPool:New("QuantumsGA_AchievementsStatusBar", self.summaryProgressBarsScrollChild)
    self.summaryStatusBarPool:SetCustomFactoryBehavior( function(statusBarControl)
        InitializeSummaryStatusBar(false, statusBarControl)
    end)
end

function addon:UpdateSummary()
    local function UpdateStatusBar(statusBar, category, earned, globalEarned, total, numEntries, hidesUnearned, hideProgressText)
        if category then
            statusBar.category:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
            statusBar.category:SetText(category)
            end

        statusBar:SetMinMax(0, zo_max(hidesUnearned and 1 or total, 1))
        statusBar:SetValue(earned)

        statusBar.character:SetMinMax(0, zo_max(hidesUnearned and 1 or total, 1))
        statusBar.character:SetValue(globalEarned)

        if hideProgressText then
            if hidesUnearned then
                if numEntries > 0 then
                    statusBar.progress:SetText(numEntries)
                    else
                    statusBar.progress:SetHidden(true)
                    end
                else
                statusBar.progress:SetText(zo_strformat("<<1>> (<<2>>)/<<3>>", ZO_CommaDelimitNumber(earned), ZO_CommaDelimitNumber(globalEarned), ZO_CommaDelimitNumber(total)))
                end
            else
            statusBar.progress:SetHidden(true)
            end

        statusBar:SetHidden(false)
        end
    self.summaryStatusBarPool:ReleaseAllObjects()

    UpdateStatusBar(self.summaryTotal, nil, GetEarnedAchievementPoints(), self.svSettings.totalPointsEarned, GetTotalAchievementPoints(), 0, nil, FORCE_HIDE_PROGRESS_TEXT)

    local numCategories = GetNumAchievementCategories()
    local yOffset = SUMMARY_CATEGORY_PADDING
    local categoryIndex = 1
    for i = 1, numCategories do
        local name, _, numAchievements, earnedPoints, totalPoints, hidesPoints = GetAchievementCategoryInfo(i)
        if totalPoints > 0 then
            local statusBar = self.summaryStatusBarPool:AcquireObject()
            UpdateStatusBar(statusBar, name, earnedPoints, self.svAchievements.achievements[name].earnedPoints, totalPoints, numAchievements, hidesPoints, FORCE_HIDE_PROGRESS_TEXT)
            statusBar:ClearAnchors()

            if categoryIndex % 2 == 0 then
                statusBar:SetAnchor(TOPRIGHT, self.summaryTotal, BOTTOMRIGHT, 0, yOffset)
                yOffset = yOffset + SUMMARY_CATEGORY_PADDING + SUMMARY_CATEGORY_BAR_HEIGHT
            else
                statusBar:SetAnchor(TOPLEFT, self.summaryTotal, BOTTOMLEFT, 0, yOffset)
            end
            categoryIndex = categoryIndex + 1
        end
    end
end


--  ==========================================
--  |     CONTENT LIST COMPONENT METHODS     |
--  ==========================================
function addon:InitNewContentList()
    self.contentList = ZO_AchievementsContents:GetNamedChild("ContentList")
    --self.contentList:GetNamedChild("Scroll"):SetHidden(true)
    self.contentList:SetAlpha(0)

    self.newContentList = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)QuantumsGAContentList", self.contentList:GetParent(), 'QuantumsGA_ContentList')
    self.contentListScrollChild = self.newContentList:GetNamedChild("ScrollChild")
end

function addon:InitCustomAchievementPool()
    self.achievementsById = {}

    local sharedCheckPool = ZO_ControlPool:New("ZO_AchievementCheckbox", self.contentListScrollChild)
    sharedCheckPool:SetCustomFactoryBehavior(   function(checkControl)
        checkControl.label = checkControl:GetNamedChild("Label")
    end)

    local sharedStatusBarPool = ZO_ControlPool:New("ZO_AchievementsStatusBar", self.contentListScrollChild)
    sharedStatusBarPool:SetCustomFactoryBehavior(   function(statusBarControl)
        statusBarControl:SetWidth(ACHIEVEMENT_STATUS_BAR_WIDTH)
        statusBarControl.label = statusBarControl:GetNamedChild("Label")
        statusBarControl.progress = statusBarControl:GetNamedChild("Progress")
        ZO_StatusBar_SetGradientColor(statusBarControl, ZO_XP_BAR_GRADIENT_COLORS)

        statusBarControl:GetNamedChild("BGLeft"):SetDrawLevel(2)
        statusBarControl:GetNamedChild("BGRight"):SetDrawLevel(2)
        statusBarControl:GetNamedChild("BGMiddle"):SetDrawLevel(2)
    end)

    local sharedRewardLabelPool = ZO_ControlPool:New("ZO_AchievementRewardLabel", self.contentListScrollChild)

    local sharedRewardIconPool = ZO_ControlPool:New("ZO_AchievementRewardItem", self.contentListScrollChild)
    sharedRewardIconPool:SetCustomFactoryBehavior(  function(rewardIconControl)
        rewardIconControl.label = rewardIconControl:GetNamedChild("Label")
        rewardIconControl.icon = rewardIconControl:GetNamedChild("Icon")
    end)

    local sharedLineThumbPool = ZO_ControlPool:New("ZO_AchievementLineThumb", self.contentListScrollChild)
    sharedLineThumbPool:SetCustomFactoryBehavior(  function(thumbControl)
        thumbControl.label = thumbControl:GetNamedChild("Label")
        thumbControl.icon = thumbControl:GetNamedChild("Icon")
    end)

    local sharedDyeSwatchPool = ZO_ControlPool:New("ZO_AchievementDyeSwatch", self.contentListScrollChild)

    local sharedCharacterEarnedPool = ZO_ControlPool:New("QuantumsGA_AchievementCharacterEarned", self.contentListScrollChild)
    sharedCharacterEarnedPool:SetCustomFactoryBehavior(   function(characterControl)
        characterControl.classIcon = characterControl:GetNamedChild("ClassIcon")
        characterControl.characterNameLabel = characterControl:GetNamedChild("CharacterNameLabel")
        characterControl.dateEarnedLabel = characterControl:GetNamedChild("DateEarnedLabel")
        characterControl.progressLabel = characterControl:GetNamedChild("ProgressLabel")
    end)

    local function CreateAchievement(objectPool)
        --local achievement = ZO_ObjectPool_CreateControl("ZO_Achievement", objectPool, self.contentListScrollChild)
        local achievement = ZO_ObjectPool_CreateNamedControl("QuantumsGA_Achievement", "ZO_Achievement", objectPool, self.contentListScrollChild)
        return QUANTUMPIES_GA_ACHIEVEMENT:New(achievement, sharedCheckPool, sharedStatusBarPool, sharedRewardLabelPool, sharedRewardIconPool, sharedLineThumbPool, sharedDyeSwatchPool, sharedCharacterEarnedPool)
    end

    local function ResetAchievement(achievement)
        achievement:Reset()
    end

    self.achievementPool = ZO_ObjectPool:New(CreateAchievement, ResetAchievement)

    -- ZO_AchievementPopup.owner = self
    -- self.popup = PopupAchievement:New(ZO_AchievementPopup, sharedCheckPool, sharedStatusBarPool, sharedRewardLabelPool, sharedRewardIconPool, sharedLineThumbPool, sharedDyeSwatchPool)
    -- 
    -- ZO_AchievementTooltip.owner = self
    -- self.tooltip = AchievementContainer:New(ZO_AchievementTooltip, sharedCheckPool, sharedStatusBarPool, sharedRewardLabelPool, sharedRewardIconPool, sharedLineThumbPool, sharedDyeSwatchPool)
end


--  ===============================================
--  |     CATEGORY PROGRESS COMPONENT METHODS     |
--  ===============================================
function addon:InitNewCategoryProgress()
    self.categoryProgress = ZO_Achievements:GetNamedChild("CategoryProgress")
    self.categoryProgress:SetDrawLevel(1)
    self.categoryProgress:GetNamedChild("Gloss"):SetDrawLevel(2)
    self.categoryProgressGlobal = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Global", self.categoryProgress, "ZO_ArrowStatusBar")
    self.categoryProgressGlobal:SetAnchor(TOPLEFT, self.categoryProgress, TOPLEFT, 0, 0)
    ZO_StatusBar_SetGradientColor(self.categoryProgressGlobal, ZO_SKILL_XP_BAR_GRADIENT_COLORS)
end

--  =================
--  |     HOOKS     |
--  =================

local function HookLayoutAchievements(self, achievements)
    addon.achievementPool:ReleaseAllObjects()
    ZO_ClearTable(self.achievementsById)
    ZO_Scroll_ResetToTop(addon.contentList)

    local previous
    for i = 1, #achievements do
        local id = achievements[i]
        if ZO_ShouldShowAchievement(self.categoryFilter.filterType, id) then
            local achievement = addon.achievementPool:AcquireObject()
            local baseAchievementId = self:GetBaseAchievementId(id)
            self.achievementsById[baseAchievementId] = achievement
            --  i here is the same as the achievementIndex for the achievement
            achievement:SetIndex(i)

            achievement:Show(ZO_GetNextInProgressAchievementInLine(id))

            achievement:SetAnchoredToAchievement(previous)
            previous = achievement
        end
    end
end

local function BuildContentList(self, data, keepExpanded)
    local categoryIndex, subCategoryIndex = self:GetCategoryIndicesFromData(data)
    if (type(categoryIndex) ~= "number") or (categoryIndex <= GetNumAchievementCategories()) then return false end
    local function SaveExpandedAchievements(achievements)
        local expandedAchievements
        for achievementId, achievement in pairs(achievements) do
            if not achievement.collapsed then
                if not expandedAchievements then
                    expandedAchievements = {}
                end
                expandedAchievements[#expandedAchievements + 1] = achievementId
            end
        end
        return expandedAchievements
    end

    local expandedAchievements = keepExpanded and SaveExpandedAchievements(self.achievementsById)

    self:LayoutAchievements(QUANTUMPIES_GA_CATEGORIES[subCategoryIndex].ids)

    if expandedAchievements then
        ExpandAchievements(self.achievementsById, expandedAchievements)
    end
end

local function HookInitializeFilters(self, filterData)
    local comboBox = ZO_ComboBox_ObjectFromContainer(self.categoryFilter)
    comboBox:ClearItems()
    comboBox:SetSortsItems(false)
    comboBox:SetFont("ZoFontWinT1")
    comboBox:SetSpacing(4)

    local function OnFilterChanged(comboBox, entryText, entry)
        self.categoryFilter.filterType = entry.filterType
        self:RefreshVisibleCategoryFilter()
    end

    for i, stringId in ipairs(filterData) do
        local entry = comboBox:CreateItemEntry(GetString(stringId), OnFilterChanged)
        entry.filterType = stringId
        comboBox:AddItem(entry)
    end

    local entry = comboBox:CreateItemEntry("Show Global Earned", OnFilterChanged)
    entry.filterType = "Show Global Earned"
    comboBox:AddItem(entry)

    local entry = comboBox:CreateItemEntry("Show Global Unearned", OnFilterChanged)
    entry.filterType = "Show Global Unearned"
    comboBox:AddItem(entry)

    comboBox:SelectFirstItem()
end

function addon:Hook()
    ZO_PreHook(ACHIEVEMENTS, "UpdateSummary", function() return self:UpdateSummary() end)

    ZO_PreHook(ACHIEVEMENTS, "ShowSummary", function()
        self.newContentList:SetHidden(true)
    end)

    ZO_PreHook(ACHIEVEMENTS, "HideSummary", function()
        self.newContentList:SetHidden(false)
    end)

    ZO_PreHook(ACHIEVEMENTS, "LayoutAchievements", HookLayoutAchievements)

    ZO_PostHook(ACHIEVEMENTS, "BuildContentList", BuildContentList)

    ZO_PostHook(ACHIEVEMENTS, "InitializeFilters", HookInitializeFilters)
    local filterData =
    {
        SI_ACHIEVEMENT_FILTER_SHOW_ALL,
        SI_ACHIEVEMENT_FILTER_SHOW_EARNED,
        SI_ACHIEVEMENT_FILTER_SHOW_UNEARNED,
    }
    ACHIEVEMENTS:InitializeFilters(filterData)

    local orgAddTopLevelCategory = ACHIEVEMENTS.AddTopLevelCategory
    function ACHIEVEMENTS.AddTopLevelCategory(...)
        local self, name = ...
        if name then return orgAddTopLevelCategory(...) end

        local result = orgAddTopLevelCategory(...)
        local lookup, tree = self.nodeLookupData, self.categoryTree

        local parentNode = self:AddCategory(lookup, tree, "ZO_IconHeader", nil, addon.groupCategoryName, "Groups", false, "/esoui/art/treeicons/achievements_indexicon_general_up.dds", "/esoui/art/treeicons/achievements_indexicon_general_down.dds", "/esoui/art/treeicons/achievements_indexicon_general_over.dds", false)
        for subCategoryIndex = 1, #QUANTUMPIES_GA_CATEGORIES do
            self:AddCategory(lookup, tree, "ZO_TreeLabelSubCategory", parentNode, subCategoryIndex, QUANTUMPIES_GA_CATEGORIES[subCategoryIndex].name, false)
        end

        --if QUANTUMPIES_GA_COMPATIBILITY_VOTANS_FAV then QUANTUMPIES_GA_COMPATIBILITY_VOTANS_FAV:AddTopLevelCategory(self) end

        return result
    end
    ACHIEVEMENTS.refreshGroups:RefreshAll("FullUpdate")

    local orgGetCategoryInfoFromData = ACHIEVEMENTS.GetCategoryInfoFromData
    function ACHIEVEMENTS.GetCategoryInfoFromData(...)
        local ACHIEVEMENTS, data, parentData = ...
        if data.parentData and data.parentData.categoryIndex == addon.groupCategoryName then
            local achievementTable = QUANTUMPIES_GA_CATEGORIES[data.categoryIndex]
            local numAchievements = #achievementTable.ids
            local earnedPoints, totalPoints
            local points, completed
            for i=1, #achievementTable do
                points, _, completed = select(3, GetAchievementInfo(achievementTable[i]))
                totalPoints = totalPoints + points
                if completed then earnedPoints = earnedPoints + points end
            end
            local hidesPoints = totalPoints == 0
            return numAchievements, earnedPoints, totalPoints, hidesPoints
        elseif QUANTUMPIES_GA_COMPATIBILITY_VOTANS_FAV and data.categoryIndex == QUANTUMPIES_GA_COMPATIBILITY_VOTANS_FAV.VotansFavorites then
            return QUANTUMPIES_GA_COMPATIBILITY_VOTANS_FAV:GetCategoryInfoFromData(ACHIEVEMENTS, data, parentData)
        else
            return orgGetCategoryInfoFromData(...)
        end
    end

    local orgZO_GetAchievementIds = ZO_GetAchievementIds
    function ZO_GetAchievementIds(...)
        local categoryIndex, subcategoryIndex, numAchievements, considerSearchResults = ...
        if categoryIndex == addon.groupCategoryName then
            addon.debug1 = QUANTUMPIES_GA_CATEGORIES[subcategoryIndex]
            return QUANTUMPIES_GA_CATEGORIES[subcategoryIndex].ids
        elseif QUANTUMPIES_GA_COMPATIBILITY_VOTANS_FAV and categoryIndex == QUANTUMPIES_GA_COMPATIBILITY_VOTANS_FAV.VotansFavorites then
            return QUANTUMPIES_GA_COMPATIBILITY_VOTANS_FAV:ZO_GetAchievementIds(categoryIndex, subcategoryIndex, numAchievements, considerSearchResults)
        else
            return orgZO_GetAchievementIds(...)
        end
    end

    local orgZO_ShouldShowAchievement = ZO_ShouldShowAchievement
    function ZO_ShouldShowAchievement(...)
        local filterType, id = ...
        if (type(filterType) == "string") then
            if (filterType == "Show Global Earned") then
                if (TableLength(QUANTUMPIES_GA:QueryAchievementByID(id)["characters"]) > 0) then
                    return true
                end
            end
            if (filterType == "Show Global Unearned") then
                if (TableLength(QUANTUMPIES_GA:QueryAchievementByID(id)["characters"]) == 0) then
                    return true
                end
            end
            return false
        else
            return orgZO_ShouldShowAchievement(...)
        end
    end
end

--  ==================
--  |     EVENTS     |
--  ==================
local function EventAchievementAwarded(eventCode, name, points, id, link)
    local achievementData = addon:QueryAchievementByID(id)["characters"]
    local playerName = GetUnitName("player")
    local playerId = addon:GetCharacterIdFromName(playerName)
    achievementData[playerId] = {id = playerId, date = os.date("%x")}
end

--  ========================
--  |     Character Id     |
--  ========================
function addon:InitCharacterIds()
    for i = 1, GetNumCharacters() do
        local name, _, _, class, _, alliance, id, _ = GetCharacterInfo(i)
        local nonLocalizedName = zo_strformat("<<1>>", name)
        local data = {name = nonLocalizedName, class = class, alliance = alliance, id = id}
        self.characterInfo[nonLocalizedName] = data
        self.characterInfo[id] = data
    end
end

function addon:GetCharacterIdFromName(name)
    return self.characterInfo[name].id
end

function addon:GetCharacterNameFromId(id)
    return self.characterInfo[id].name
end

--  ================
--  |     INIT     |
--  ================

function addon:Initialize()
    self.svSettings = ZO_SavedVars:NewAccountWide("QuantumPiesGlobalAchievementsSV", self.varsVersionSettings, "Settings", QUANTUMPIES_GA_CONSTANTS.defaultSettings)
    self.svAchievements = nil
    if (self.svSettings.settingServerSeparation == true) then
        self.svAchievements = ZO_SavedVars:NewAccountWide("QuantumPiesGlobalAchievementsSV", self.varsVersionAchievement, "Achievements", QUANTUMPIES_GA_CONSTANTS.defaultAchievements, GetWorldName())
    else
        self.svAchievements = ZO_SavedVars:NewAccountWide("QuantumPiesGlobalAchievementsSV", self.varsVersionAchievement, "Achievements", QUANTUMPIES_GA_CONSTANTS.defaultAchievements)
    end

    self.characterInfo = {}
    self:InitCharacterIds()
    self:InitNewSummary()
    self:InitNewContentList()
    self:InitCustomAchievementPool()

    local playerName = GetUnitName("player")
    if (self.svAchievements.charactersLoaded[self:GetCharacterIdFromName(playerName)] == nil) then
        self.svAchievements.charactersLoaded[self:GetCharacterIdFromName(playerName)] = true
        self:InitializeDB()
    elseif (GetAPIVersion() > self.svSettings.apiVersion) then
        self:CheckForNewCategories()
        self.svSettings.apiVersion = GetAPIVersion()
    end
    self:Hook()
    ACHIEVEMENTS:ShowSummary()

    em:RegisterForEvent(addon.name, EVENT_ACHIEVEMENT_AWARDED, EventAchievementAwarded)

    if QUANTUMPIES_GA_COMPATIBILITY_VOTANS then QUANTUMPIES_GA_COMPATIBILITY_VOTANS:HideSummary() end

    self:UpdateSummary()
    self:InitSettingsPanel()
end

local function OnAddOnLoaded(event, addonName)
    if addonName == addon.name then
        em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
        addon:Initialize()
    end
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

QUANTUMPIES_GA = addon