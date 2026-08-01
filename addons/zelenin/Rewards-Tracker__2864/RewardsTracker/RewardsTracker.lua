local addonId = "RewardsTracker"

--local function roundToHour(unixTime)
--    local secondsInHour = 60 * 60
--    local secondsSinceHourStart = unixTime % secondsInHour
--
--    local roundedUnixTime
--    if secondsSinceHourStart < (secondsInHour / 2) then
--        roundedUnixTime = unixTime - secondsSinceHourStart
--    else
--        roundedUnixTime = unixTime + (secondsInHour - secondsSinceHourStart)
--    end
--
--    return roundedUnixTime
--end
--
--local function getNextDailyResetTime()
--    local remainingTime = TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_DAILY)
--
--    local nextResetTime = roundToHour(os.time() + remainingTime)
--
--    return nextResetTime
--end
--
--local daysInSec1 = 1 * ZO_ONE_DAY_IN_SECONDS
--local daysInSec6 = 6 * ZO_ONE_DAY_IN_SECONDS
--local daysInSec7 = 7 * ZO_ONE_DAY_IN_SECONDS
--
--local function getNextWeeklyResetTime()
--    local remainingTime = TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_WEEKLY)
--
--    local delta = (remainingTime >= daysInSec6 and remainingTime < daysInSec7) and - daysInSec6 or daysInSec1
--
--    local nextResetTime = roundToHour(os.time() + remainingTime + delta)
--
--    return nextResetTime
--end

local function getOffset()
    local now = os.time()
    local utcNow = os.time(os.date("!*t", now))

    return now - utcNow
end

local offset = getOffset()

local function getResetHour()
    return GetWorldName() == "EU Megaserver" and 3 or 10
end

local resetHour = getResetHour()

local function getNextDailyResetTime()
    local currentTime = os.time()
    local utcTime = os.date("!%H:%M:%S", currentTime)

    local delta = utcTime > string.format("%02d:00:00", resetHour) and ZO_ONE_DAY_IN_SECONDS or 0

    local nextTime = os.date("!*t", currentTime + delta)

    nextTime.hour = resetHour
    nextTime.min = 0
    nextTime.sec = 0

    return os.time(nextTime) + offset
end

local function getNextWeeklyResetTime()
    local currentTime = os.time()
    local utcTime = os.date("!%H:%M:%S", currentTime)
    local weekDay = tonumber(os.date("!%w", currentTime))

    local delta = ((weekDay > 2) or (weekDay == 2 and utcTime > string.format("%02d:00:00", resetHour))) and (7 - (weekDay - 2)) * ZO_ONE_DAY_IN_SECONDS or -(weekDay - 2) * ZO_ONE_DAY_IN_SECONDS

    local nextTime = os.date("!*t", currentTime + delta)

    nextTime.hour = 3
    nextTime.min = 0
    nextTime.sec = 0

    return os.time(nextTime) + getOffset()
end

local accountRewardSingle = ZO_InitializingObject:Subclass()
function accountRewardSingle:Initialize(itemLink, resetDuration)
    self.itemLink = itemLink
    self.itemId = GetItemLinkItemId(self.itemLink)
    self.resetDuration = resetDuration ~= 0 and resetDuration or 0
end

function accountRewardSingle:GetId()
    return self.itemId
end

function accountRewardSingle:GetName()
    if self.itemName == nil then
        self.itemName = GetItemLinkName(self.itemLink)
    end
    return self.itemName
end

function accountRewardSingle:GetFormattedName()
    if self.formattedItemName == nil then
        self.formattedItemName = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, GetItemLinkDisplayQuality(self.itemLink)))
                                            :Colorize(string.format('|t20:20:%s|t %s', GetItemLinkIcon(self.itemLink), self:GetName()))
    end
    return self.formattedItemName
end

function accountRewardSingle:GetResetTime()
    return self.resetDuration == 0 and getNextDailyResetTime() or (os.time() + self.resetDuration)
end

function accountRewardSingle:IsRewardItem(itemId)
    return self.itemId == itemId
end

local accountRewardMultiple = ZO_InitializingObject:Subclass()
function accountRewardMultiple:Initialize(itemLinks, resetDuration, name)
    self.itemId = 0
    self.itemLinks = {}
    for _, itemLink in ipairs(itemLinks) do
        local itemId = GetItemLinkItemId(itemLink)
        if self.itemId == 0 or itemId < self.itemId then
            self.itemId = itemId
        end
        self.itemLinks[itemId] = itemLink
    end

    self.itemLink = self.itemLinks[self.itemId]
    self.itemName = name
    self.resetDuration = resetDuration ~= 0 and resetDuration or 0
end

function accountRewardMultiple:GetId()
    return self.itemId
end

function accountRewardMultiple:GetName()
    if self.itemName == nil then
        self.itemName = GetItemLinkName(self.itemLink)
    end
    return self.itemName
end

function accountRewardMultiple:GetFormattedName()
    if self.formattedItemName == nil then
        self.formattedItemName = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, GetItemLinkDisplayQuality(self.itemLink)))
                                            :Colorize(string.format('|t20:20:%s|t %s', GetItemLinkIcon(self.itemLink), self:GetName()))
    end
    return self.formattedItemName
end

function accountRewardMultiple:GetResetTime()
    return self.resetDuration == 0 and getNextDailyResetTime() or (os.time() + self.resetDuration)
end

function accountRewardMultiple:IsRewardItem(itemId)
    return self.itemLinks[itemId] ~= nil
end

local weeklyTrialReward = ZO_InitializingObject:Subclass()
function weeklyTrialReward:Initialize(itemIds, abbrName, fullName)
    self.itemIds = itemIds
    self.itemIdsSet = ZO_CreateSetFromArguments(unpack(itemIds))
    self.abbrName = abbrName
    self.fullName = fullName
end

function weeklyTrialReward:GetId()
    return self.abbrName
end

function weeklyTrialReward:GetAbbrName()
    return self.abbrName
end

function weeklyTrialReward:GetFullName()
    return self.fullName
end

function weeklyTrialReward:GetResetTime()
    return getNextWeeklyResetTime()
end

function weeklyTrialReward:IsRewardItem(itemId)
    return self.itemIdsSet[itemId] == true
end

local timerReward = ZO_InitializingObject:Subclass()
function timerReward:Initialize(abbrName, fullName)
    self.abbrName = abbrName
    self.fullName = fullName
end

function timerReward:GetId()
    return self.abbrName
end

function timerReward:GetAbbrName()
    return self.abbrName
end

function timerReward:GetFullName()
    return self.fullName
end

function timerReward:GetResetTime()
    return getNextDailyResetTime()
end

function timerReward:IsRewardItem(itemId)
    return false
end

local function getMotifItemLink(itemId)
    return string.format('|H%d:item:%d:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', LINK_STYLE_BRACKETS, itemId)
end

local addon = ZO_InitializingObject:Subclass()
function addon:Initialize(name)
    self.name = name
    self.data = {
        characterRewards = LibSimpleSavedVars:NewCharacterWide(string.format("%sCharacterRewardsData", self.name), 1, {}),
        accountRewards = LibSimpleSavedVars:NewAccountWide(string.format("%sAccountRewardsData", self.name), 1, {}),
    }
    self.addonData = self:getAddonData()

    self.characterRewards = {
        weeklyTrialReward:New({ 81187, 81188, 87705, 87706, 139666, 139667 }, "so", GetString(SI_REWARDS_TRACKER_SO)),
        weeklyTrialReward:New({ 87702, 87707, 139664, 139668 }, "aa", GetString(SI_REWARDS_TRACKER_AA)),
        weeklyTrialReward:New({ 87703, 87708, 139665, 139669 }, "hrc", GetString(SI_REWARDS_TRACKER_HRC)),
        weeklyTrialReward:New({ 94089, 94090, 139670, 139671 }, "mol", GetString(SI_REWARDS_TRACKER_MOL)),
        weeklyTrialReward:New({ 126130, 126131, 139672, 139673 }, "hof", GetString(SI_REWARDS_TRACKER_HOF)),
        weeklyTrialReward:New({ 134585, 134586, 139674, 139675 }, "as", GetString(SI_REWARDS_TRACKER_AS)),
        weeklyTrialReward:New({ 138711, 138712, 141738, 141739 }, "cr", GetString(SI_REWARDS_TRACKER_CR)),
        weeklyTrialReward:New({ 151970, 151971 }, "ss", GetString(SI_REWARDS_TRACKER_SS)),
        weeklyTrialReward:New({ 165421, 165422 }, "ka", GetString(SI_REWARDS_TRACKER_KA)),
        weeklyTrialReward:New({ 176054, 176055 }, "rg", GetString(SI_REWARDS_TRACKER_RG)),
        weeklyTrialReward:New({ 188134, 188139 }, "dr", GetString(SI_REWARDS_TRACKER_DR)),
        weeklyTrialReward:New({ 197827, 197828 }, "se", GetString(SI_REWARDS_TRACKER_SE)),
        weeklyTrialReward:New({ 207944, 207945 }, "lc", GetString(SI_REWARDS_TRACKER_LC)),
        weeklyTrialReward:New({ 217657, 217658 }, "oc", GetString(SI_REWARDS_TRACKER_OC)),
        timerReward:New("rd", GetString(SI_REWARDS_TRACKER_RD)),
        timerReward:New("rb", GetString(SI_REWARDS_TRACKER_RB)),
        timerReward:New("shs", GetString(SI_REWARDS_TRACKER_SHS)),
    }

    local function rangeMotives(a, b)
        local motives = {}
        for i = a, b do
            table.insert(motives, getMotifItemLink(i))
        end
        return motives
    end

    self.accountRewards = {
        -- geode
        accountRewardSingle:New('|H1:item:211304:122:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h'),
        ---- 50 Runebox: Arena Gladiator Costume
        ---- 30 Runebox: Arena Gladiator Emote
        ---- 20 Runebox: Arena Gladiator Helm
        ---- 30 Runebox: Siegestomper Emote
        ---- 40 Runebox: Elinhir Arena Lion Pet
        ---- 40 Random Weapon Style Page: Knight of the Circle
        ---- 20 Random Armor Style Page: Knight of the Circle
        ---- 20 Runebox: Reach-Mage Ceremonial Skullcap
        ---- arena gladiators proof
        accountRewardSingle:New('|H1:item:138783:5:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h'),
        ---- 30 Runebox: Rage of the Reach emote
        ---- 50 Runebox: Timbercrow Wanderer Costume
        ---- 20 Runebox: Siegemaster's Close Helm
        ---- 50 Runebox: Siegemaster's Uniform
        ---- siege of cyrodiil merit
        accountRewardSingle:New('|H1:item:151939:5:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h'),
        -- battlemaster token
        accountRewardSingle:New('|H1:item:212235:5:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h'),
        -- Crafting Motif 80: Shield of Senchal Style
        accountRewardMultiple:New(rangeMotives(156627, 156641), 24 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(156627))),
        -- Crafting Motif 81: New Moon Priest Style
        accountRewardMultiple:New(rangeMotives(156608, 156622), 24 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(156608))),
        -- Crafting Motif 84: Blackreach Vanguard Style
        accountRewardMultiple:New(rangeMotives(160493, 160507), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(160493))),
        -- Crafting Motif 85: Greymoor Style
        accountRewardMultiple:New(rangeMotives(160542, 160556), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(160542))),
        -- Crafting Motif 86: Sea Giant Style
        accountRewardMultiple:New(rangeMotives(160559, 160573), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(160559))),
        -- Crafting Motif 95: Nighthollow Style
        accountRewardMultiple:New(rangeMotives(167943, 167957), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(167943))),
        -- Crafting Motif 96: Arkthzand Armory Style
        accountRewardMultiple:New(rangeMotives(167960, 167974), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(167960))),
        -- Crafting Motif 97: Wayward Guardian Style
        accountRewardMultiple:New(rangeMotives(167977, 167991), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(167977))),
        -- Crafting Motif 98: House Hexos Style
        accountRewardMultiple:New(rangeMotives(170131, 170145), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(170131))),
        -- Crafting Motif 101: Ivory Brigade Style
        accountRewardMultiple:New(rangeMotives(171895, 171909), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(171895))),
        -- Crafting Motif 102: Sul-Xan Style
        accountRewardMultiple:New(rangeMotives(171912, 171926), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(171912))),
        -- Crafting Motif 103: Black Fin Legion Style
        accountRewardMultiple:New(rangeMotives(171878, 171892), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(171878))),
        -- Crafting Motif 107: Annihilarch's Chosen Style
        accountRewardMultiple:New(rangeMotives(178528, 178542), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(178528))),
        -- Crafting Motif 108: Fargrave Guardian Style
        accountRewardMultiple:New(rangeMotives(178706, 178720), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(178706))),
        -- Crafting Motif 112: Syrabanic Marine Style
        accountRewardMultiple:New(rangeMotives(182520, 182534), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(182520))),
        -- Crafting Motif 113: Steadfast Society Style
        accountRewardMultiple:New(rangeMotives(182537, 182551), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(182537))),
        -- Crafting Motif 114: Systres Guardian Style
        accountRewardMultiple:New(rangeMotives(182554, 182568), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(182554))),
        -- Crafting Motif 117: Firesong Style
        accountRewardMultiple:New(rangeMotives(188307, 188321), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(188307))),
        -- Crafting Motif 118: House Mornard Style
        accountRewardMultiple:New(rangeMotives(188324, 188338), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(188324))),
        -- Crafting Motif 122: Dead Keeper Style
        accountRewardMultiple:New(rangeMotives(194513, 194527), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(194513))),
        -- Crafting Motif 123: Kindred's Concord Style
        accountRewardMultiple:New(rangeMotives(194540, 194554), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(194540))),
        -- Crafting Motif 126: Shardborn Style
        accountRewardMultiple:New(rangeMotives(203360, 203374), 20 * ZO_ONE_HOUR_IN_SECONDS, GetItemLinkName(getMotifItemLink(203360))),
    }

    self.settings = rewardsTrackerSettings:New(self)
    self.campaign = rewardsTrackerCampaign:New(self)
    self.opener = rewardsTrackerOpener:New(self)

    self.control = RewardsTrackerContainer

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(eventCode, initial)
        self:updateTimers()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE, function(eventCode)
        self:updateTimers()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_RECEIVED, function(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, isMe, isPickpocketLoot, questItemIcon, itemId, isStolen)
        if isMe == false or lootType ~= LOOT_TYPE_ITEM then
            return
        end

        for _, _characterReward in ipairs(self.characterRewards) do
            if _characterReward:IsRewardItem(itemId) then
                self.data.characterRewards[_characterReward:GetId()] = _characterReward:GetResetTime()
            end
        end

        for _, _accountReward in ipairs(self.accountRewards) do
            if _accountReward:IsRewardItem(itemId) then
                self.data.accountRewards[_accountReward:GetId()] = _accountReward:GetResetTime()
            end
        end
    end)

    self.characterList = self:createCharacterList(self.control:GetNamedChild("Character"))
    self.accountList = self:createAccountList(self.control:GetNamedChild("Account"))
    self.scene = self:createScene(string.format("%sScene", self.name), self.control)

    self:hooks()

    zo_callLater(function()
        self:notifications()
    end, 20000)

    SLASH_COMMANDS["/rewards-tracker"] = function(cmd)
        if cmd == "" then
            self:ToggleUi()
        end
    end
end

function addon:getAddonData()
    for index = 1, GetAddOnManager():GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = GetAddOnManager():GetAddOnInfo(index)
        if name == self.name then
            return {
                name = name,
                title = title,
                author = author,
                version = GetAddOnManager():GetAddOnVersion(index),
                directoryPath = GetAddOnManager():GetAddOnRootDirectoryPath(index)
            }
        end
    end

    return nil
end

function addon:ToggleUi()
    SCENE_MANAGER:Toggle(self.scene:GetName())
end

function addon:createScene(name, control)
    local scene = ZO_Scene:New(name, SCENE_MANAGER)

    scene:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
    scene:AddFragment(CODEX_WINDOW_SOUNDS)
    scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)

    if control then
        scene:AddFragment(ZO_FadeSceneFragment:New(control))
    end

    scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            self.characterList:RefreshData()
            self.accountList:RefreshData()

            local characterRows = #ZO_ScrollList_GetDataList(self.characterList.list)
            if characterRows == 0 then
                characterRows = 1
            end
            local characterHeight = 16 * 2 + 32 + 30 * characterRows

            local accountRows = #ZO_ScrollList_GetDataList(self.accountList.list)
            if accountRows == 0 then
                accountRows = 1
            end
            local accountHeight = 16 * 2 + 30 * accountRows

            self.characterList.control:SetHeight(characterHeight)
            self.accountList.control:SetHeight(accountHeight)

            self.control:SetWidth(self.characterList.control:GetWidth())
        end
    end)

    return scene
end

function addon:notifications()
    local function message(title, content)
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINTS_COMMITTED)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        messageParams:SetText(string.format("%s: %s", title, content))
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    local function check()
        local now = os.time()

        for _, _accountReward in ipairs(self.accountRewards) do
            if self.settings.data.notifications[_accountReward:GetId()] == true then
                local time = self.data.accountRewards[_accountReward:GetId()]
                if time == nil or time < now then
                    message(self:getAddonData().title, _accountReward:GetName())
                end
            end
        end
    end

    check()
    EVENT_MANAGER:RegisterForUpdate(self.name .. "Notifications", 1 * ZO_ONE_HOUR_IN_SECONDS * 1000, check)
end

function addon:updateTimers()
    self.data.characterRewards.rd = os.time() + GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_DUNGEON_REWARD_GRANTED)
    self.data.characterRewards.rb = os.time() + GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_BATTLEGROUND_REWARD_GRANTED)
    self.data.characterRewards.shs = os.time() + GetTimeToShadowyConnectionsResetInSeconds()
end

local REWARDS_TRACKER_CHARACTER_DATA_TYPE = 18
local REWARDS_TRACKER_ACCOUNT_DATA_TYPE = 19

function addon:createCharacterList(control)
    local headers = control:GetNamedChild("Headers")
    local nameHeader = headers:GetNamedChild("Name")
    local previousHeader = nameHeader
    local colWidth = 80
    local rewardsCount = 0
    for _, _characterReward in ipairs(self.characterRewards) do
        if headers:GetNamedChild(_characterReward:GetId()) == nil and self.settings.data.timers[_characterReward:GetId()] == true then
            local header = GetWindowManager()
                :CreateControlFromVirtual(string.format("$(parent)%s", _characterReward:GetId()), headers, "RewardsTrackerListHeader")
            header:SetDimensions(200, 32)
            header:SetAnchor(TOPLEFT, nameHeader, BOTTOMRIGHT, -20 + colWidth * rewardsCount, -80)

            header:GetNamedChild("Name"):SetText(_characterReward:GetFullName())
            header:GetNamedChild("Name"):SetHorizontalAlignment(TEXT_ALIGN_LEFT)

            header:SetTransformRotationZ(math.rad(30))

            previousHeader = header
            rewardsCount = rewardsCount + 1
        end
    end

    control:SetWidth(16 + 300 + colWidth * rewardsCount + 16)

    local list = ZO_SortFilterList:New(control)

    list.owner = self

    ZO_ScrollList_EnableHighlight(list.list, "ZO_ThinListHighlight")

    list:SetAlternateRowBackgrounds(true)
    list:SetEmptyText("No data")

    list.currentSortKey = "name"
    list.currentSortOrder = ZO_SORT_ORDER_UP

    list.sortFunction = function(row1, row2)
        return ZO_TableOrderingFunction(
            row1.data, row2.data,
            list.currentSortKey,
            {
                ["name"] = {},
            }, list.currentSortOrder
        )
    end

    local colorText = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_VALUE))
    ZO_ScrollList_AddDataType(list.list, REWARDS_TRACKER_CHARACTER_DATA_TYPE, "RewardsTrackerListRow", 30, function(row, data)
        list:SetupRow(row, data)

        row:SetWidth(colWidth * rewardsCount + 300)

        local previousCell = row:GetNamedChild("Name")
        for _, _characterReward in ipairs(self.characterRewards) do
            if row:GetNamedChild(_characterReward:GetId()) == nil and list.owner.settings.data.timers[_characterReward:GetId()] == true then
                local cell = GetWindowManager()
                    :CreateControlFromVirtual(string.format("$(parent)%s", _characterReward:GetId()), row, "RewardsTrackerListRowTimer")
                cell:SetDimensions(colWidth, 30)
                cell:SetAnchor(TOPLEFT, previousCell, TOPRIGHT, 0, 0)
                previousCell = cell
            end
        end

        row.data = data

        row.name = row:GetNamedChild("Name")
        row.name:SetText(data.formattedName)

        for _, _characterReward in ipairs(self.characterRewards) do
            if list.owner.settings.data.timers[_characterReward:GetId()] == true then
                row:GetNamedChild(_characterReward:GetId()):SetText(row.data[_characterReward:GetId()])
            end
        end

        for i = 1, row:GetNumChildren() do
            local child = row:GetChild(i)
            if child and child:GetType() == CT_LABEL then
                child.normalColor = colorText
            end
        end
    end)

    list.masterList = {}
    function list:BuildMasterList()
    end

    function list:FilterScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(scrollData)

        for characterId, characterData in pairs(LibSimpleSavedVars:GetAccountData(string.format("%sCharacterRewardsData", self.owner.name))) do
            if LibCharacter:Exists(characterId) then
                if self.owner.settings.data.characters[characterId] == true then
                    local character = LibCharacter:GetCharacter(characterId)
                    local rowData = {
                        name = character.name,
                        formattedName = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, character.alliance)):Colorize(string.format('|t24:24:%s|t %s', GetClassIcon(character.classId), character.name)),
                    }

                    for _, _characterReward in ipairs(self.owner.characterRewards) do
                        if self.owner.settings.data.timers[_characterReward:GetId()] == true then
                            rowData[_characterReward:GetId()] = self.owner:formatTime(characterData[_characterReward:GetId()])
                        end
                    end

                    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(REWARDS_TRACKER_CHARACTER_DATA_TYPE, rowData))
                end
            end
        end
    end

    function list:SortScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        table.sort(scrollData, self.sortFunction)
    end

    return list
end

function addon:createAccountList(control)
    local list = ZO_SortFilterList:New(control)

    list.owner = self

    ZO_ScrollList_EnableHighlight(list.list, "ZO_ThinListHighlight")

    list:SetAlternateRowBackgrounds(true)
    list:SetEmptyText("No data")

    list.currentSortKey = "name"
    list.currentSortOrder = ZO_SORT_ORDER_UP

    list.sortFunction = function(row1, row2)
        return ZO_TableOrderingFunction(
            row1.data, row2.data,
            list.currentSortKey,
            {
                ["name"] = {},
            }, list.currentSortOrder
        )
    end

    local colorText = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_VALUE))
    ZO_ScrollList_AddDataType(list.list, REWARDS_TRACKER_ACCOUNT_DATA_TYPE, "RewardsTrackerListRow", 30, function(row, data, listControl)
        list:SetupRow(row, data)

        if row:GetNamedChild("Timer") == nil then
            GetWindowManager()
                :CreateControlFromVirtual("$(parent)Timer", row, "RewardsTrackerListRowTimer")
                :SetAnchor(TOPLEFT, row:GetNamedChild("Name"), TOPRIGHT, 0, 0)
        end

        row.data = data

        row.name = row:GetNamedChild("Name")
        row.timer = row:GetNamedChild("Timer")

        row.name:SetWidth(330)

        row.name:SetText(data.formattedName)
        row.timer:SetText(data.timer)

        for i = 1, row:GetNumChildren() do
            local child = row:GetChild(i)
            if child and child:GetType() == CT_LABEL then
                child.normalColor = colorText
            end
        end
    end)

    list.masterList = {}
    function list:BuildMasterList()
    end

    function list:FilterScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(scrollData)

        for _, _accountReward in ipairs(self.owner.accountRewards) do
            if self.owner.settings.data.timers[_accountReward:GetId()] == true then
                table.insert(scrollData, ZO_ScrollList_CreateDataEntry(REWARDS_TRACKER_ACCOUNT_DATA_TYPE, {
                    name = _accountReward:GetName(),
                    formattedName = _accountReward:GetFormattedName(),
                    timer = self.owner:formatTime(self.owner.data.accountRewards[_accountReward:GetId()])
                }))
            end
        end
    end

    function list:SortScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        table.sort(scrollData, self.sortFunction)
    end

    return list
end

function addon:formatTime(time)
    local now = os.time()

    -- time = os.time() + 2*60*60*24

    if time == nil then
        return "-"
    end

    if time < now then
        return "-"
    end

    local diff = time - now

    return ZO_FormatTime(diff, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
end

function addon:hooks()
    local function createTimerControl(parent)
        local control = WINDOW_MANAGER:CreateControl("$(parent)Timer", parent:GetParent(), CT_LABEL)
        control:SetAnchor(TOPLEFT, parent, BOTTOMLEFT, 0, 32)
        control:SetDimensions(200, 30)
        control:SetFont("$(BOLD_FONT)|21|soft-shadow-thick")
        control:SetText("")
        control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        control:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        return control
    end

    local enabledColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_ENABLED)
    local warningColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_WARNING)

    local dungeonTimerControl = createTimerControl(DUNGEON_FINDER_MANAGER.keyboardObject.rewardsSection)
    local bgTimerControl = createTimerControl(BATTLEGROUND_FINDER_MANAGER.keyboardObject.rewardsSection)

    local function setText()
        local dungeonCooldown = GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_DUNGEON_REWARD_GRANTED)
        local bgCooldown = GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_BATTLEGROUND_REWARD_GRANTED)

        local now = os.time()
        if dungeonCooldown > 0 then
            dungeonTimerControl:SetText(string.format("|c%s%s|r |c%s%s|r", enabledColor:ToHex(), GetString(SI_HOOK_POINT_STORE_REMAINING), warningColor:ToHex(), self:formatTime(now + dungeonCooldown)))
        else
            dungeonTimerControl:SetText("")
        end
        if bgCooldown > 0 then
            bgTimerControl:SetText(string.format("|c%s%s|r |c%s%s|r", enabledColor:ToHex(), GetString(SI_HOOK_POINT_STORE_REMAINING), warningColor:ToHex(), self:formatTime(now + bgCooldown)))
        else
            bgTimerControl:SetText("")
        end
    end

    KEYBOARD_GROUP_MENU_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            setText()
            EVENT_MANAGER:UnregisterForUpdate(string.format("%s-rewards-timer", self.name))
            EVENT_MANAGER:RegisterForUpdate(string.format("%s-rewards-timer", self.name), 1000, setText)
        end
        if newState == SCENE_HIDING then
            EVENT_MANAGER:UnregisterForUpdate(string.format("%s-rewards-timer", self.name))
        end
    end)
end

local announcementsColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_ANNOUNCEMENTS)
local succeededColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SUCCEEDED)
local failedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_FAILED)
local selectedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)
local hintColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HINT)

function addon:Log(message)
    if self.settings.data.log ~= true then
        return
    end

    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r %s", announcementsColor:ToHex(), self.addonData.name, message))
end

function addon:Error(message)
    if self.settings.data.log ~= true then
        return
    end

    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r |c%s%s|r", announcementsColor:ToHex(), self.addonData.name, failedColor:ToHex(), message))
end

function addon:Debug(message)
    if GetDisplayName() ~= "@zelenin" then
        return
    end

    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r |c%s%s|r", announcementsColor:ToHex(), self.addonData.name, failedColor:ToHex(), message))
end

EVENT_MANAGER:RegisterForEvent(addonId, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName ~= addonId then
        return
    end
    assert(not _G[addonId], string.format("'%s' has already been loaded", addonId))
    _G[addonId] = addon:New(addonId)
    EVENT_MANAGER:UnregisterForEvent(addonId, EVENT_ADD_ON_LOADED)
end)
