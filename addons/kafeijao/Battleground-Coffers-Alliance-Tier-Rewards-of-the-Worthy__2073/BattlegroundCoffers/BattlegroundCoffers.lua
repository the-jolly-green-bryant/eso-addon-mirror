-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibAddonMenu2

-------------------------------------
-- Addon data.
-------------------------------------
BattlegroundCoffers = BattlegroundCoffers or {}
BattlegroundCoffers.name = "BattlegroundCoffers"
BattlegroundCoffers.slashComandName = "/bgc"
BattlegroundCoffers.currentCharId = GetCurrentCharacterId()
BattlegroundCoffers.numChars = nil
BattlegroundCoffers.characters = nil

BattlegroundCoffers.collectibleIDs = {
    bgAdornments =          { 12769 },
    bgEmotes =              { 6632, 6633, 6634 },
    bgRunnerArmor =         { 6728, 6729, 6730, 6731, 6732, 6733 },
    bgRunnerWeapons =       { 6782, 6783, 6784, 6785, 6786},
    fangedWormWeapons =     { 5378, 5379, 5380, 5381, 5382, 5383, 5384, 5385, 5386, 5387 },
    fangedWormLArmor =      { 5355, 5356, 5357, 5358, 5359, 5360, 5361, 5362 },
    fangedWormMArmor =      { 5363, 5364, 5365, 5366, 5367, 5368, 5369 },
    fangedWormHArmor =      { 5370, 5371, 5372, 5373, 5374, 5375, 5376 },
    hornedDragonWeapons =   { 5420, 5421, 5422, 5423, 5424, 5425, 5426, 5427, 5428, 5429} ,
    hornedDragonLArmor =    { 5430, 5431, 5432, 5433, 5434, 5435, 5436, 5437 },
    hornedDragonMArmor =    { 5438, 5439, 5440, 5441, 5442, 5443, 5444 },
    hornedDragonHArmor =    { 5445, 5446, 5447, 5448, 5449, 5450, 5451 },
    pitdaemonWeapons =      { 6229, 6230, 6231, 6232, 6233, 6234, 6235, 6236, 6237, 6238 },
    pitdaemonHArmor =       { 5621, 5622, 5623, 5624, 5625, 5626, 5627 },
    pitdaemonLArmor =       { 12543, 12544, 12545, 12546, 12547, 12548, 12549 },
    firedrakeWeapons =      { 6219, 6220, 6221, 6222, 6223, 6224, 6225, 6226, 6227, 6228 },
    firedrakeArmor =        { 5645, 5646, 5647, 5648, 5649, 5650, 5651 },
    stormlordWeapons =      { 6209, 6210, 6211, 6212, 6213, 6214, 6215, 6216, 6217, 6218 },
    stormlordHArmor =       { 5628, 5629, 5630, 5631, 5632, 5633, 5634 },
    stormlordLArmor =       { 12550, 12551, 12552, 12553, 12554, 12555, 12556 },
    galeskirmishArmour =    { 12313, 12314, 12315, 12316, 12317, 12318, 12319 },
    eldAngavarWeapons =     { 12533, 12534, 12535, 12536, 12537, 12538, 12539, 12540, 12541, 12542 }
}
BattlegroundCoffers.collectibleStyleNames = {
    bgAdornments =          "Battleground Adornments",
    bgEmotes =              "Battleground Emotes",
    bgRunnerArmor =         "Battleground Runner Armor",
    bgRunnerWeapons =       "Battleground Runner Weapons",
    fangedWormWeapons =     "Fanged Worm Weapons",
    fangedWormLArmor =      "Fanged Worm Light Armor",
    fangedWormMArmor =      "Fanged Worm Medium Armor",
    fangedWormHArmor =      "Fanged Worm Heavy Armor",
    hornedDragonWeapons =   "Horned Dragon Weapons",
    hornedDragonLArmor =    "Horned Dragon Light Armor",
    hornedDragonMArmor =    "Horned Dragon Medium Armor",
    hornedDragonHArmor =    "Horned Dragon Heavy Armor",
    pitdaemonWeapons =      "Pit Daemon Weapons",
    pitdaemonHArmor =       "Pit Daemon Heavy Armor",
    pitdaemonLArmor =       "Pit Daemon Light Armor",
    firedrakeWeapons =      "Firedrake Weapons",
    firedrakeArmor =        "Firedrake Armor",
    stormlordWeapons =      "Stormlord Weapons",
    stormlordHArmor =       "Stormlord Heavy Armor",
    stormlordLArmor =       "Stormlord Light Armor",
    galeskirmishArmour =    "Galeskirmish Gladiator Armor",
    eldAngavarWeapons =     "Eld Angavar Weapons"
}

BattlegroundCoffers.campaignRewards = {}
BattlegroundCoffers.campaignRewards[2592000] = 50 -- 30 days campaign reward
BattlegroundCoffers.campaignRewards[604800] =  10 --  7 days campaign reward

BattlegroundCoffers.variableVersion = 3
BattlegroundCoffers.Default = {
    cooldownCofferTimes = {},
    allianceTierInfo = {},
    excludedCharacters = {}
}


-------------------------------------
-- Initialize the addon.
-------------------------------------
function BattlegroundCoffers.OnAddOnLoaded(_, addonName)
    if addonName == BattlegroundCoffers.name then
        BattlegroundCoffers:Initialize()
        EVENT_MANAGER:UnregisterForEvent(BattlegroundCoffers.name, EVENT_ADD_ON_LOADED)
    end
end


-------------------------------------
-- Load saved variables and register the event listeners.
-------------------------------------
function BattlegroundCoffers:Initialize()
    BattlegroundCoffers.savedVariables = ZO_SavedVars:NewAccountWide("BattlegroundCoffersVars", BattlegroundCoffers.variableVersion, nil, BattlegroundCoffers.Default)

    -- Battleground state
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, BattlegroundCoffers.updateSavedVariablesBattlegroundCoffers)

    -- Tier change listeners
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_CAMPAIGN_SCORE_DATA_CHANGED, BattlegroundCoffers.updateSavedVariablesAllianceTier)
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_CAMPAIGN_STATE_INITIALIZED, BattlegroundCoffers.updateSavedVariablesAllianceTier)
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_CAMPAIGN_LEADERBOARD_DATA_CHANGED, BattlegroundCoffers.updateSavedVariablesAllianceTier)
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_CAMPAIGN_ASSIGNMENT_RESULT, BattlegroundCoffers.updateSavedVariablesAllianceTier)
    -- (new events)
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_CAMPAIGN_LEADERBOARD_DATA_RECEIVED, BattlegroundCoffers.updateSavedVariablesAllianceTier)
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_KEEP_ALLIANCE_OWNER_CHANGED, BattlegroundCoffers.updateSavedVariablesAllianceTier)
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_OBJECTIVES_UPDATED, BattlegroundCoffers.updateSavedVariablesAllianceTier)

    -- Collectible Updates
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_COLLECTIBLE_UPDATED, BattlegroundCoffers.updateBGUnlockedPagesData)
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_COLLECTIBLES_UPDATED, BattlegroundCoffers.updateBGUnlockedPagesData)
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_COLLECTIBLE_NOTIFICATION_NEW, BattlegroundCoffers.updateBGUnlockedPagesData)

    -- Received items Updates
    EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, BattlegroundCoffers.onInvetorySingleSlotUpdate)
    EVENT_MANAGER:AddFilterForEvent(BattlegroundCoffers.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    EVENT_MANAGER:AddFilterForEvent(BattlegroundCoffers.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
    EVENT_MANAGER:AddFilterForEvent(BattlegroundCoffers.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)

    BattlegroundCoffers.updateCharacterList()
    BattlegroundCoffers.initiliazeUI()

    BattlegroundCoffers.CreateSettingsWindow()

    ZO_CreateStringId("SI_BINDING_NAME_BGC_TOGGLE", "Show/Hide Window")
    BattlegroundCoffers.initializeSlashCommands()
end


-------------------------------------
-- Populates the character list with the nom-excluded characters.
-------------------------------------
function BattlegroundCoffers.updateCharacterList()
    BattlegroundCoffers.characters = {}
    for charIndex = 1, GetNumCharacters() do
        local name, _, _, _, _, alliance, id, _ = GetCharacterInfo(charIndex)
        if not BattlegroundCoffers.setContains(BattlegroundCoffers.savedVariables.excludedCharacters, zo_strformat("<<1>>", name)) then
            table.insert(BattlegroundCoffers.characters, {id = id, name = zo_strformat("<<1>>", name), alliance = alliance})
        end
    end

    BattlegroundCoffers.numChars = #BattlegroundCoffers.characters
end


-------------------------------------
-- Initializes the styles UI.
-------------------------------------
function BattlegroundCoffers.initiliazeStylesUI()
    BattlegroundCoffers_Style_Window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    local WM = WINDOW_MANAGER
    local pre = 0

    local orderedIndex = __genOrderedIndex(BattlegroundCoffers.collectibleIDs)

    for i = 1, #orderedIndex do
        local style = orderedIndex[i]
        local idValues = BattlegroundCoffers.collectibleIDs[orderedIndex[i]]

        local c = WM:GetControlByName('BattlegroundCoffers_StyleRow' .. pre)
        local p = WM:CreateControl('BattlegroundCoffers_StyleRow' .. style, BattlegroundCoffers_StylePanelScrollChildStyles, CT_CONTROL)
        if c then p:SetAnchor(3,c,6,0,0) else p:SetAnchor(3,nil,3,0,3) end
        p:SetDimensions(750,90)
        local bg = WM:CreateControl('BattlegroundCoffers_StylePanelScrollChildBgLine'..style, p, CT_BACKDROP)
        bg:SetAnchor(3,p,3,0,0)
        bg:SetDimensions(750,37)
        bg:SetCenterColor(0,0,0,0.2)
        bg:SetEdgeColor(1,1,1,0)

        local lbl = WM:CreateControl('BattlegroundCoffers_StylePanelScrollChildName' .. style, p, CT_LABEL)
        lbl:SetAnchor(2,bg,2,10,0)
        lbl:SetDimensions(nil,32)
        lbl:SetFont('ZoFontGameBold')
        lbl:SetText(BattlegroundCoffers.collectibleStyleNames[style])
        lbl:SetColor(0.91,0.78,0.16,1)
        lbl:SetHorizontalAlignment(0)
        lbl:SetVerticalAlignment(1)

        for index = 1, #idValues do
            local pageId = BattlegroundCoffers.collectibleIDs[style][index]

            local _, _, icon, _, unlocked, _, _, _, _, _ = GetCollectibleInfo(pageId)

            local btn = WM:CreateControl('BattlegroundCoffers_StylePanelScrollChild' .. style .. 'Button' .. pageId, p, CT_BUTTON)
            btn:SetAnchor(3,bg,6,4+(index-1)*52,2)
            btn:SetDimensions(52,50)
            --btn:SetText(split(icon, '_')[3])
            btn:SetFont('ZoFontGameMedium')

            btn:SetHandler('OnMouseEnter',function()
                ClearTooltip(ItemTooltip)
                local offsetX = btn:GetParent():GetLeft() - btn:GetLeft() - 5
                InitializeTooltip(ItemTooltip, btn, RIGHT, offsetX, 0, LEFT)
                local SHOW_NICKNAME, SHOW_PURCHASABLE_HINT, SHOW_BLOCK_REASON = true, false, true
                ItemTooltip:SetCollectible(pageId, SHOW_NICKNAME, SHOW_PURCHASABLE_HINT, SHOW_BLOCK_REASON)
                ItemTooltip:SetHidden(false)
            end)

            btn:SetHandler('OnMouseExit',function()
                ClearTooltip(ItemTooltip)
                ItemTooltip:SetHidden(true)
            end)

            local tex = WM:CreateControl('$(parent)Texture', btn, CT_TEXTURE)
            tex:SetAnchor(128,btn,128,0,0)
            tex:SetDimensions(45,45)
            tex:SetTexture(icon)
            if unlocked then
                tex:SetColor(1,1,1,1)
            else
                tex:SetColor(1,0,0,1)
            end
        end

        pre = style
    end
end


-------------------------------------
-- Closes the style pages window.
-------------------------------------
function BattlegroundCoffers.closeStylesWindow()
    BattlegroundCoffers_Style_Window:SetHidden(true)
end


-------------------------------------
-- Opens the style pages window.
-------------------------------------
function BattlegroundCoffers.openStylesWindow()
    BattlegroundCoffers_Style_Window:SetHidden(false)
end


-------------------------------------
-- Initializes the UI.
-------------------------------------
function BattlegroundCoffers.initiliazeUI()

    -- Config the main window
    BattlegroundCoffersWindow:SetHidden(true)
    BattlegroundCoffersWindow:ClearAnchors()
    BattlegroundCoffersWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    BattlegroundCoffersWindow.totalRowHeight = 30

    -- Config bottom (total) row
    BattlegroundCoffersRow_Total.rotw = BattlegroundCoffersRow_Total:GetNamedChild("RotW")
    BattlegroundCoffersRow_Total.pages = BattlegroundCoffersRow_Total:GetNamedChild("Pages")
    BattlegroundCoffersRow_Total.transmutes = BattlegroundCoffersRow_Total:GetNamedChild("Transmutes")
    BattlegroundCoffersRow_Total.pages:EnableMouseButton(2, true)
    BattlegroundCoffersRow_Total.pages:SetNormalFontColor(0.91,0.78,0.16,1)
    BattlegroundCoffersRow_Total.pages:SetMouseOverFontColor(1,1,1,1)
    BattlegroundCoffersRow_Total.pages:SetClickSound('Click')

    -- Config the Style window
    BattlegroundCoffers.initiliazeStylesUI()

    -- Config the List of rows
    BattlegroundCoffers:reloadUI()
end

-------------------------------------
-- Reload the UI.
-------------------------------------
function BattlegroundCoffers.reloadUI()
    BattlegroundCoffers.updateCharacterList()
    BattlegroundCoffersWindow:SetHeight(BattlegroundCoffers.numChars * 24 + BattlegroundCoffersWindow.totalRowHeight + BattlegroundCoffersWindowHeader:GetHeight() + 18)
    BattlegroundCoffers.createListHolder()
    BattlegroundCoffers.updateBGUnlockedPagesData(nil, nil, true)
end


-------------------------------------
-- Updates the battleground coffer timers on the saved variables.
-------------------------------------
function BattlegroundCoffers.updateSavedVariablesBattlegroundCoffers(_, result)
    if result == ACTIVITY_FINDER_STATUS_NONE then
        local cofferCooldownSeconds = GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_BATTLEGROUND_REWARD_GRANTED)
        local secondsSiceEpochCofferCooldown = os.time() + cofferCooldownSeconds

        BattlegroundCoffers.savedVariables.cooldownCofferTimes[BattlegroundCoffers.currentCharId] = secondsSiceEpochCofferCooldown
        BattlegroundCoffers.updateBGCofferData(true)
    end
end


-------------------------------------
-- Updates the alliance tier on the saved variables.
-------------------------------------
function BattlegroundCoffers.updateSavedVariablesAllianceTier(skipUpdateUi)

    local currentTier, _, _ = GetPlayerCampaignRewardTierInfo(GetAssignedCampaignId())
    local secondsUntilCampaignEnds = GetSecondsUntilCampaignEnd(GetAssignedCampaignId())
    local campaignID = GetAssignedCampaignId()
    local campaignDuration = GetCampaignRulesetDurationInSeconds(GetCampaignRulesetId(campaignID))
    local secondsSiceEpochUntilCampaignEnds = os.time() + secondsUntilCampaignEnds

    local previousData = BattlegroundCoffers.savedVariables.allianceTierInfo[BattlegroundCoffers.currentCharId]

    -- Conditions to update values
    local changedCampaign = previousData ~= nil and previousData.campaignID ~= campaignID
    local higherTier = previousData ~= nil and previousData.tier < currentTier

    if previousData == nil or higherTier or changedCampaign then
        BattlegroundCoffers.savedVariables.allianceTierInfo[BattlegroundCoffers.currentCharId] = {tier = currentTier, expireTime = secondsSiceEpochUntilCampaignEnds, campaignID = campaignID, campaignDuration = campaignDuration}
    end

    if not skipUpdateUi then
        BattlegroundCoffers.updateAllianceTierData(true)
    end
end


-------------------------------------
-- Updates the Rewards of the Worthy Gold Geode timer on the saved variables.
-------------------------------------
function BattlegroundCoffers.updateSavedVariablesRotWTimer()
    BattlegroundCoffers.savedVariables.cooldownRotWTime = os.time() + 72000
    BattlegroundCoffers.updateRotWTimerData(true)
end


-------------------------------------
-- Slash commands listeners.
-------------------------------------
function BattlegroundCoffers.initializeSlashCommands()
    SLASH_COMMANDS[BattlegroundCoffers.slashComandName] = BattlegroundCoffers.toggleWindow
end


-------------------------------------
-- Create the list of the characters.
------------------------------------
function BattlegroundCoffers.createListHolder()

    BattlegroundCoffersWindowListHolder.dataLines = {}
    BattlegroundCoffersWindowListHolder.lines = {}

    local predecessor
    for charIndex = 1, BattlegroundCoffers.numChars do
        BattlegroundCoffersWindowListHolder.lines[charIndex] = BattlegroundCoffers.createUILine(charIndex, predecessor)
        predecessor = BattlegroundCoffersWindowListHolder.lines[charIndex]
    end

    -- If there are less characters hide the extra rows
    local rowNum = BattlegroundCoffers.numChars + 1
    while _G["BattlegroundCoffersRow_" .. rowNum] ~= nil do
        _G["BattlegroundCoffersRow_" .. rowNum]:SetHidden(true)
        _G["BattlegroundCoffersRow_" .. rowNum].bgCoffer:SetText("")
        _G["BattlegroundCoffersRow_" .. rowNum].allianceTier:SetText("")
        rowNum = rowNum + 1
    end

    BattlegroundCoffers.updateCharNameData()
    BattlegroundCoffers.updateBGCofferData(false)
    BattlegroundCoffers.updateAllianceTierData(false)
end


-------------------------------------
-- Create the ui lines.
------------------------------------
function BattlegroundCoffers.createUILine(charIndex, predecessor)
    local record = _G["BattlegroundCoffersRow_" .. charIndex]

    if record ~= nil then
        record:SetHidden(false)

    else
        record = CreateControlFromVirtual("BattlegroundCoffersRow_", BattlegroundCoffersWindowListHolder, "BattlegroundCoffersTimerTemplate", charIndex)
    end

    record:ClearAnchors()

    record.name = record:GetNamedChild("Name")
    record.bgCoffer = record:GetNamedChild("BGCoffer")
    record.allianceTier = record:GetNamedChild("AllianceTier")

    if charIndex == 1 then
        record:SetAnchor(TOPLEFT, BattlegroundCoffersWindowListHolder, TOPLEFT, 0, 0)
        record:SetAnchor(TOPRIGHT, BattlegroundCoffersWindowListHolder, TOPRIGHT, 0, 0)
    else
        record:SetAnchor(TOPLEFT, predecessor, BOTTOMLEFT, 0, BattlegroundCoffersWindowListHolder.rowHeight)
        record:SetAnchor(TOPRIGHT, predecessor, BOTTOMRIGHT, 0, BattlegroundCoffersWindowListHolder.rowHeight)
    end

    return record
end


-------------------------------------
-- Update the UI info for character names.
-------------------------------------
function BattlegroundCoffers.updateCharNameData()
    for charIndex = 1, BattlegroundCoffers.numChars do
        local char = BattlegroundCoffers.characters[charIndex]
        local formatedName = GetAllianceColor(char.alliance):Colorize(char.name)
        if BattlegroundCoffers.currentCharId == char.id then formatedName = "|c00b300>|r " .. formatedName .. " |c00b300<|r" end
        local currentLine = BattlegroundCoffersWindowListHolder.lines[charIndex]
        currentLine.name:SetText(formatedName)
    end
end


-------------------------------------
-- Update the UI info for the bg coffers.
-------------------------------------
function BattlegroundCoffers.updateBGCofferData(singleExecute)
    local minSecondsToUpdate = 30

    for charIndex = 1, BattlegroundCoffers.numChars do
        local char = BattlegroundCoffers.characters[charIndex]
        local cooldownTimeSinceEpoch = BattlegroundCoffers.savedVariables.cooldownCofferTimes[char.id]

        local output

        if cooldownTimeSinceEpoch == nil then -- If there is no data from previous
            output = "|cffcc00 - |r"

        else
            local cooldownRemainingSeconds = os.difftime(cooldownTimeSinceEpoch, os.time())

            if cooldownRemainingSeconds <= 0 then -- If the coffer is out of cooldown
                output = "|t22:22:/esoui/art/icons/quest_container_001.dds|t"

            else -- If the coffer is on cooldown
                local timediff, secondsToUpdate = FormatTimeSeconds(cooldownRemainingSeconds, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
                output = timediff
                minSecondsToUpdate = math.min(minSecondsToUpdate, secondsToUpdate)
            end
        end

        local currentLine = BattlegroundCoffersWindowListHolder.lines[charIndex]
        currentLine.bgCoffer:SetText(output)
    end

    if (not singleExecute and not BattlegroundCoffersWindow:IsHidden()) then zo_callLater(function() BattlegroundCoffers.updateBGCofferData(false) end, minSecondsToUpdate * 1000) end
end

-------------------------------------
-- Update the UI info for the alliance tier info.
-------------------------------------
function BattlegroundCoffers.updateAllianceTierData(singleExecute)
    local minSecondsToUpdate = 30

    local numberOfCoffers = 0
    local totalTransmuteStones = 0

    BattlegroundCoffers.updateSavedVariablesAllianceTier(true)

    for charIndex = 1, BattlegroundCoffers.numChars do
        local char = BattlegroundCoffers.characters[charIndex]
        local allianceTierInfo = BattlegroundCoffers.savedVariables.allianceTierInfo[char.id]
        local timeUntilCampaignEnds = ""

        -- Todo: Delete after a while
        if allianceTierInfo == 0 then -- Bug fix for my fuckup
            BattlegroundCoffers.savedVariables.allianceTierInfo[char.id] = nil
        end

        if allianceTierInfo ~= nil then
            local secondsUntilCampaignExpire = os.difftime(allianceTierInfo.expireTime, os.time())
            if secondsUntilCampaignExpire <= 0 then
                BattlegroundCoffers.savedVariables.allianceTierInfo[char.id] = {tier = 0, expireTime = os.time() }

            else
                local timeDiff, secondsToUpdate = FormatTimeSeconds(os.difftime(allianceTierInfo.expireTime, os.time()), TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
                timeUntilCampaignEnds = timeDiff
                minSecondsToUpdate = math.min(minSecondsToUpdate, secondsToUpdate)
            end
        end

        local currentLine = BattlegroundCoffersWindowListHolder.lines[charIndex]
        if allianceTierInfo == nil or allianceTierInfo.tier == nil then
            currentLine.allianceTier:SetText("|cffcc00 - |r")

        elseif allianceTierInfo.tier == 0 then
            if timeUntilCampaignEnds == "" then
                currentLine.allianceTier:SetText("|cb30000 0 |r")
            else
                currentLine.allianceTier:SetText("|cb30000 0 |r " .. timeUntilCampaignEnds)
            end

        else
            --if BattlegroundCoffers.campaignRewards[allianceTierInfo.campaignDuration] == nil then d("Something went wrong with battleground coffers addon, report to the addon author please. Weird duration: " .. tostring(allianceTierInfo.campaignDuration) ) end
            currentLine.allianceTier:SetText("|c00b300 " .. allianceTierInfo.tier .. " |r " .. timeUntilCampaignEnds)
            numberOfCoffers = numberOfCoffers + 1
            totalTransmuteStones = totalTransmuteStones + BattlegroundCoffers.campaignRewards[allianceTierInfo.campaignDuration] or 50
        end
    end

    -- Update last row (total)
    BattlegroundCoffersRow_Total.transmutes:SetText("|cE9C62A" .. numberOfCoffers .. "|r|t23:23:/esoui/art/icons/crafting_runecrafter_potion_sp_001.dds|t (|cF4309F" .. totalTransmuteStones .. "|r |t23:23:/esoui/art/currency/currency_seedcrystals_multi_mipmap.dds|t)")

    if (not singleExecute and not BattlegroundCoffersWindow:IsHidden()) then zo_callLater(function() BattlegroundCoffers.updateAllianceTierData(false) end, minSecondsToUpdate * 1000) end
end


-------------------------------------
-- Updates the UI of the unlocked battlegrounds pages and emotes.
-------------------------------------
function BattlegroundCoffers.updateBGUnlockedPagesData(_, _, justUnlocked)
    if justUnlocked then

        local outfitsUnlocked = 0
        local outfitsTotal = 0

        local emotesUnlocked = 0
        local emotesTotal = 0

        for _, idValues in pairs(BattlegroundCoffers.collectibleIDs) do
            for index = 1, #idValues do
                if GetCollectibleCategoryType(idValues[index]) == COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE then
                    outfitsTotal = outfitsTotal + 1
                elseif GetCollectibleCategoryType(idValues[index]) == COLLECTIBLE_CATEGORY_TYPE_EMOTE then
                    emotesTotal = emotesTotal + 1
                end
                if IsCollectibleUnlocked(idValues[index]) then
                    if GetCollectibleCategoryType(idValues[index]) == COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE then
                        outfitsUnlocked = outfitsUnlocked + 1
                    elseif GetCollectibleCategoryType(idValues[index]) == COLLECTIBLE_CATEGORY_TYPE_EMOTE then
                        emotesUnlocked = emotesUnlocked + 1
                    end

                end
            end
        end

        local unlockedPagesText = outfitsUnlocked .. "/" .. outfitsTotal .. " |t23:23:/esoui/art/icons/quest_summerset_completed_report.dds|t"
        local unlockedEmotes = emotesUnlocked .. "/" .. emotesTotal .. "|t35:35:/esoui/art/treeicons/tutorial_idexicon_emotes_up.dds|t"
        local result = unlockedPagesText .. "   " .. unlockedEmotes
        BattlegroundCoffers_StyleHeaderInfo:SetText(result)
        BattlegroundCoffersRow_Total.pages:SetText(result)
        BattlegroundCoffers.updateStyleKnowledge()
    end
end


-------------------------------------
-- Updates the known and unkown styles.
-------------------------------------
function BattlegroundCoffers.updateStyleKnowledge()
    local orderedIndex = __genOrderedIndex(BattlegroundCoffers.collectibleIDs)
    for i = 1, #orderedIndex do
        local style = orderedIndex[i]
        local idValues = BattlegroundCoffers.collectibleIDs[orderedIndex[i]]

        for index = 1, #idValues do
            local pageId = BattlegroundCoffers.collectibleIDs[style][index]

            local _, _, _, _, unlocked, _, _, _, _, _ = GetCollectibleInfo(pageId)

            local control = WINDOW_MANAGER:GetControlByName('BattlegroundCoffers_StylePanelScrollChild'..style..'Button'..pageId..'Texture')

            if unlocked then
                control:SetColor(1,1,1,1)
            else
                control:SetColor(1,0,0,1)
            end
        end
    end
end


-------------------------------------
-- Check if Reward of the Worthy Geode was received.
-------------------------------------
function BattlegroundCoffers.onInvetorySingleSlotUpdate(_, bagId, slotId)
    -- Event Filters applied:
    -- -- REGISTER_FILTER_BAG_ID == INVENTORY_UPDATE_REASON_DEFAULT
    -- -- REGISTER_FILTER_INVENTORY_UPDATE_REASON == INVENTORY_UPDATE_REASON_DEFAULT
    -- -- REGISTER_FILTER_IS_NEW_ITEM == true

    if GetItemId(bagId, slotId) == 134618 then -- 134618 RotW Geode id
        if BattlegroundCoffers.savedVariables.cooldownRotWTime == nil or BattlegroundCoffers.savedVariables.cooldownRotWTime <= os.time() then
            BattlegroundCoffers.updateSavedVariablesRotWTimer()
        end
    end
end


-------------------------------------
-- Update the UI info for the RotW Gold reward.
-------------------------------------
function BattlegroundCoffers.updateRotWTimerData(singleExecute)
    local minSecondsToUpdate = 30
    local cooldownRotWEpoch = BattlegroundCoffers.savedVariables.cooldownRotWTime

    local output = "|cE9C62ARotW: "

    if cooldownRotWEpoch == nil then -- If there is no data from previous
        output = output .. " |cffcc00-|r"

    else
        local cooldownRemainingSeconds = os.difftime(cooldownRotWEpoch, os.time())

        if cooldownRemainingSeconds <= 0 then -- If the coffer is out of cooldown
            output = output .. " |t23:23:/esoui/art/icons/crafting_runecrafter_potion_sp_001.dds|t"

        else -- If the coffer is on cooldown
            local timediff, secondsToUpdate = FormatTimeSeconds(cooldownRemainingSeconds, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
            output = output .. "|cE9C62A" .. timediff
            minSecondsToUpdate = math.min(minSecondsToUpdate, secondsToUpdate)
        end
    end

    BattlegroundCoffersRow_Total.rotw:SetText(output)

    if (not singleExecute and not BattlegroundCoffersWindow:IsHidden()) then zo_callLater(function() BattlegroundCoffers.updateRotWTimerData(false) end, minSecondsToUpdate * 1000) end
end


-------------------------------------
-- UI Window toggle.
-------------------------------------
function BattlegroundCoffers.toggleWindow()
    BattlegroundCoffersWindow:SetHidden(not BattlegroundCoffersWindow:IsHidden())
    if (not BattlegroundCoffersWindow:IsHidden()) then
        BattlegroundCoffers.updateBGCofferData(false)
        BattlegroundCoffers.updateAllianceTierData(false)
        BattlegroundCoffers.updateRotWTimerData(false)
    else
        BattlegroundCoffers.closeStylesWindow()
    end
end


-------------------------------------------------------------------------------------------------
--  Settings menu creation.
-------------------------------------------------------------------------------------------------
function BattlegroundCoffers.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Battleground Coffers",
        displayName = "Battleground Coffers",
        author = "Kafeijao",
        version = BattlegroundCoffers.version,
        slashCommand = BattlegroundCoffers.slashComandName .. "config",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM2:RegisterAddonPanel("Battleground Coffers", panelData)

    local optionsData = {
        [1] = {
            type = "header",
            name = "General"
        },
        [2] = {
            type = "description",
            text = "Here you can adjust the Battleground Coffers settings."
        },
        [3] = {
            type = "dropdown",
            name = "Tracked Chars",
            tooltip = "Untrack this character.",
            reference = "bgc_tacked_chars",
            choices = BattlegroundCoffers.getCharacterNames(),
            getFunc = function()
                BattlegroundCoffers.charToUntrack = nil
                return ""
            end,
            setFunc = function(newValue)
                BattlegroundCoffers.charToUntrack = newValue
            end,
            width = "half"
        },
        [4] = {
            type = "button",
            name = "Untrack",
            tooltip = "Untrack this character.",
            func = function()
                BattlegroundCoffers.addToSet(BattlegroundCoffers.savedVariables.excludedCharacters, BattlegroundCoffers.charToUntrack)
                BattlegroundCoffers.charToUntrack = nil
                BattlegroundCoffers.reloadUI()
                bgc_tacked_chars:UpdateChoices(BattlegroundCoffers.getCharacterNames())
                bgc_untacked_chars:UpdateChoices(BattlegroundCoffers.getKeySet(BattlegroundCoffers.savedVariables.excludedCharacters))
            end,
            width = "half",
            disabled = false
        },
        [5] = {
            type = "dropdown",
            name = "Untracked Chars",
            tooltip = "Track this character.",
            reference = "bgc_untacked_chars",
            choices = BattlegroundCoffers.getKeySet(BattlegroundCoffers.savedVariables.excludedCharacters),
            getFunc = function()
                BattlegroundCoffers.charToTrack = nil
                return ""
            end,
            setFunc = function(newValue)
                if newValue ~= "" then BattlegroundCoffers.charToTrack = newValue end
            end,
            width = "half"
        },
        [6] = {
            type = "button",
            name = "Track",
            tooltip = "Track this character.",
            func = function()
                if BattlegroundCoffers.charToTrack ~= nil then
                    BattlegroundCoffers.removeFromSet(BattlegroundCoffers.savedVariables.excludedCharacters, BattlegroundCoffers.charToTrack)
                    BattlegroundCoffers.charToTrack = nil
                    BattlegroundCoffers.reloadUI()
                    bgc_tacked_chars:UpdateChoices(BattlegroundCoffers.getCharacterNames())
                    bgc_untacked_chars:UpdateChoices(BattlegroundCoffers.getKeySet(BattlegroundCoffers.savedVariables.excludedCharacters))
                end
            end,
            width = "half",
            disabled = false
        }
    }

    LAM2:RegisterOptionControls("Battleground Coffers", optionsData)
end


-------------------------------------
-- Get a list of all character names.
-------------------------------------
function BattlegroundCoffers.getCharacterNames()
    local charsNames = {}
    for charIndex = 1, BattlegroundCoffers.numChars do
        table.insert(charsNames, BattlegroundCoffers.characters[charIndex].name)
    end
    return charsNames
end


-------------------------------------
-- Get a list of the keys from a table.
-------------------------------------
function BattlegroundCoffers.getKeySet(tab)
    local keyset={}
    local n=0
    for k,_ in pairs(tab) do
        n=n+1
        keyset[n]=k
    end
    return keyset
end


-------------------------------------
-- Set utils.
-------------------------------------
function BattlegroundCoffers.addToSet(set, key)
    set[key] = true
end
function BattlegroundCoffers.removeFromSet(set, key)
    set[key] = nil
end
function BattlegroundCoffers.setContains(set, key)
    return set[key] ~= nil
end
function BattlegroundCoffers.setSize(set)
    local count = 0
    for _ in pairs(set) do count = count + 1 end
    return count
end


-------------------------------------
-- Ordered table iterator, allow to iterate on the natural order of the keys of a table.
-------------------------------------
function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

-------------------------------------
-- Initialization Register.
-------------------------------------
EVENT_MANAGER:RegisterForEvent(BattlegroundCoffers.name, EVENT_ADD_ON_LOADED, BattlegroundCoffers.OnAddOnLoaded)