local ACHIEVEMENT_PADDING = 0
local ACHIEVEMENT_WIDTH = 550
local ACHIEVEMENT_COLLAPSED_HEIGHT = 88
local ACHIEVEMENT_DESC_COLLAPSED_HEIGHT = 45
local ACHIEVEMENT_DESC_WIDTH = 380
local ACHIEVEMENT_INITIAL_CRITERIA_OFFSET = 10
local ACHIEVEMENT_LINE_PADDING = 5
local ACHIEVEMENT_LINE_PADDING_VERTICAL = 8
local ACHIEVEMENT_CRITERIA_PADDING = 10
local ACHIEVEMENT_REWARD_PADDING = 5
local ACHIEVEMENT_LINE_THUMB_WIDTH = 45
local ACHIEVEMENT_LINE_THUMB_HEIGHT = 68
local ACHIEVEMENT_STATUS_BAR_HEIGHT = 20
local ACHIEVEMENT_REWARD_LABEL_WIDTH = 230
local ACHIEVEMENT_REWARD_LABEL_HEIGHT = 20
local ACHIEVEMENT_REWARD_ICON_HEIGHT = 45

local ACHIEVEMENT_DATE_LABEL_EXPECTED_WIDTH = 60

local PREFIX_LABEL = 1
local HEADER_LABEL = 2

local function TableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

--[[ Achievement ]]--
local Achievement = ZO_Object:Subclass()

function Achievement:New(...)
    local achievement = ZO_Object.New(self)
    achievement:Initialize(...)

    return achievement
end

function Achievement:Initialize(control, checkPool, statusBarPool, rewardLabelPool, rewardIconPool, lineThumbPool, dyeSwatchPool, characterEarnedPool)
    control.achievement = self
    self.control = control
    ZO_InventorySlot_SetType(self.control, SLOT_TYPE_ACHIEVEMENT_REWARD)
    self.checkPool = checkPool
    self.statusBarPool = statusBarPool
    self.rewardLabelPool = rewardLabelPool
    self.rewardIconPool = rewardIconPool
    self.lineThumbPool = lineThumbPool
    self.dyeSwatchPool = dyeSwatchPool
    self.characterEarnedPool = characterEarnedPool

    self.checkBoxes = {}
    self.progressBars = {}
    self.rewardIcons = {}
    self.rewardLabels = {}
    self.headerLabels = {}
    self.lineThumbs = {}
    self.dyeSwatches = {}
    self.characterEarned = {}
    self.collapsed = true

    self.title = control:GetNamedChild("Title")
    self.highlight = control:GetNamedChild("Highlight")
    self.description = control:GetNamedChild("Description")
    self.icon = control:GetNamedChild("Icon")
    self.points = control:GetNamedChild("Points")
    self.date = control:GetNamedChild("Date")
    self.rewardThumb = control:GetNamedChild("RewardThumb")
    self.expandedStateIcon = control:GetNamedChild("ExpandedState")

    self.anchoredToAchievement = nil
    self.dependentAnchoredAchievement = nil

    if self.highlight then
        self.highlight:SetHeight(ACHIEVEMENT_COLLAPSED_HEIGHT)
    end
end

function Achievement:GetId()
    return self.achievementId
end

function Achievement:GetAchievementInfo(achievementId)
    return GetAchievementInfo(achievementId)
end

function Achievement:GetIndex()
    return self.index
end

function Achievement:SetIndex(index)
    self.index = index
end

function Achievement:Show(achievementId)
    self.achievementId = achievementId
    local name, description, points, icon, completed, date, time = self:GetAchievementInfo(achievementId)

    -- Determine if the achievement has been earned on other characters
    local achievementInfo = QUANTUMPIES_GA:QueryAchievementByID(achievementId)
    local timesEarned = TableLength(achievementInfo["characters"])
    local globalEarned = QUANTUMPIES_GA ~= nil
            and timesEarned > 0
            or false

    if timesEarned > 0 then
        self.title:SetText(zo_strformat("(<<1>>) <<2>>", timesEarned, name))
    else
        self.title:SetText(zo_strformat(name))
    end

    self.description:SetText(zo_strformat(description))
    self.icon:SetTexture(icon)

    self.points:SetHidden(points == ACHIEVEMENT_POINT_LEGENDARY_DEED)
    self.points:SetText(tostring(points))

    ZO_Achievements_ApplyTextColorToLabel(self.points, completed or (QUANTUMPIES_GA.svSettings.settingsSolidScore and globalEarned), ZO_SELECTED_TEXT)
    --ZO_Achievements_ApplyTextColorToLabel(self.title, completed, ZO_SELECTED_TEXT)
    ZO_Achievements_ApplyTextColorToLabel(self.title, completed or (QUANTUMPIES_GA.svSettings.settingsSolidName and globalEarned), ZO_SELECTED_TEXT)
    --ZO_Achievements_ApplyTextColorToLabel(self.description, completed)
    ZO_Achievements_ApplyTextColorToLabel(self.description, completed or (QUANTUMPIES_GA.svSettings.settingsSolidDescription and globalEarned), ZO_SELECTED_TEXT)

    if self.highlight then
        local highlightColor
        if completed or globalEarned then
            highlightColor = ZO_DEFAULT_ENABLED_COLOR
        else
            highlightColor = ZO_ACHIEVEMENT_DISABLED_COLOR
        end
        self.highlight:GetNamedChild("Top"):SetColor(highlightColor:UnpackRGBA())
        self.highlight:GetNamedChild("Middle"):SetColor(highlightColor:UnpackRGBA())
        self.highlight:GetNamedChild("Bottom"):SetColor(highlightColor:UnpackRGBA())
    end

    self.completed = completed
    self.globalEarned = globalEarned

    if QUANTUMPIES_GA.svSettings.settingDevMode then
        self.date:SetHidden(false)
        self.date:SetText(achievementId)
        self.icon:SetDesaturation(0)
    elseif completed then
        self.date:SetHidden(false)
        self.date:SetText(date)
        self.icon:SetDesaturation(0)
    --elseif achievementInfo.lineProgress ~= nil and achievementInfo.lineCount ~= nil then
    --    self.date:SetHidden(false)
    --    self.date:SetText(achievementInfo.lineProgress .. "/" .. achievementInfo.lineCount)
    --    self.icon:SetDesaturation(0)
    elseif globalEarned then
        self.date:SetHidden(false)
        self.date:SetText("Earned")
        self.icon:SetDesaturation(0)
    else
        self.date:SetHidden(true)
        self.icon:SetDesaturation(ZO_ACHIEVEMENT_DISABLED_DESATURATION)
    end

    -- Date strings might overlap the description, so apply dimension constraints after setting the completion date
    self:ApplyCollapsedDescriptionConstraints()

    --Whether we need to expand partly depends on if the description will be truncated in collapsed mode which depends on its constraints being set above.
    self.isExpandable = self:IsExpandable()

    self:SetRewardThumb(achievementId)
    self:UpdateExpandedStateIcon()

    self.control:SetHidden(false)
end

function Achievement:SetRewardThumb(achievementId)
    local hasReward, completedReward = self:HasTangibleReward() -- achievements always award points, account for that
    local hasRewardTitle, _ = GetAchievementRewardTitle(achievementId)

    self.rewardThumb:SetHidden(not hasReward)
    if(hasReward) then
        if(completedReward or (self.globalEarned and not hasRewardTitle)) then
            self.rewardThumb:SetTexture("EsoUI/Art/Achievements/achievements_reward_earned.dds")
        else
            self.rewardThumb:SetTexture("EsoUI/Art/Achievements/achievements_reward_unearned.dds")
        end
    end
end

do
    local function LayoutLineSection(controls, yOffset, parent, controlWidth, controlHeight)
        local numControls = #controls
        if numControls > 0 then
            local previous
            for i = 1, numControls do
                if previous then
                    controls[i]:SetAnchor(LEFT, previous, RIGHT, ACHIEVEMENT_LINE_PADDING, 0)
                else
                    local totalLineWidth = (numControls * (controlWidth + ACHIEVEMENT_LINE_PADDING)) - ACHIEVEMENT_LINE_PADDING
                    local startX = (ACHIEVEMENT_WIDTH - totalLineWidth) / 2
                    controls[i]:SetAnchor(TOPLEFT, parent, TOPLEFT, startX, yOffset)
                end
                previous = controls[i]
            end

            yOffset = yOffset + controlHeight + ACHIEVEMENT_LINE_PADDING_VERTICAL
        end

        return yOffset
    end

    local function LayoutCriteriaSection(controls, yOffset, parent, controlHeight, xOffset)
        local useFunctionToGetHeight = type(controlHeight) == "function"
        local numControls = #controls
        if numControls > 0 then
            for i, control in ipairs(controls) do
                yOffset = yOffset + (control.additionalVerticalPadding or 0)
                control:SetAnchor(TOPLEFT, parent, TOPLEFT, xOffset, yOffset)

                local currentHeight = controlHeight

                if(useFunctionToGetHeight) then
                    currentHeight = currentHeight(control)
                end

                yOffset = yOffset + ACHIEVEMENT_CRITERIA_PADDING + currentHeight
            end
        end

        return yOffset
    end

    local function LayoutRewardSection(controls, yOffset, parent, controlHeight)
        local numControls = #controls
        if numControls > 0 then
            local numRewards = 0
            for i, control in ipairs(controls) do
                if not control.isHeader then
                    if control.prefix then
                        control:SetAnchor(LEFT, control.prefix, RIGHT, 5, 0)
                    else
                        numRewards = numRewards + 1
                        local padding = 0
                        if numRewards > 1 then
                            padding = ACHIEVEMENT_REWARD_PADDING
                        end
                        control:SetAnchor(TOPLEFT, parent, TOPLEFT, 90, yOffset + padding)
                        yOffset = yOffset + padding + controlHeight
                    end
                end
            end

            yOffset = yOffset + ACHIEVEMENT_REWARD_PADDING
        end

        return yOffset
    end

    local function AddSectionPadding(controls, yOffset, padAmount)
        if(#controls > 0) then
            return yOffset + padAmount
        end

        return yOffset
    end

    local function GetCriteriaHeightCheckBox(control)
        local labelHeight = select(2, control.label:GetTextDimensions())
        return zo_max(control:GetHeight(), labelHeight)
    end

    function Achievement:HasAnyVisibleCriteriaOrRewards()
        return (#self.lineThumbs + #self.progressBars + #self.checkBoxes + #self.rewardLabels + #self.rewardIcons + #self.dyeSwatches) > 0
    end

    function Achievement:PerformExpandedLayout()
        local controlTop = self.control:GetTop()
        local yOffset = self.description:GetBottom() - controlTop -- always try to start right after the bottom of the description
        local footerPad = self.title:GetTop() - controlTop

        if(self:HasAnyVisibleCriteriaOrRewards()) then
            -- If you have other things in the expanded view, pad out a little after the description
            yOffset = yOffset + ACHIEVEMENT_INITIAL_CRITERIA_OFFSET
        else
            -- If you don't have anything else to show, at least show the full description, but if the full description
            -- fits in the collapsed view, don't expand the window at all.
            yOffset = zo_max(ACHIEVEMENT_COLLAPSED_HEIGHT, yOffset + footerPad)
        end

        yOffset = LayoutCriteriaSection(self.progressBars, yOffset, self.control, ACHIEVEMENT_STATUS_BAR_HEIGHT, 90)
        yOffset = AddSectionPadding(self.progressBars, yOffset, ACHIEVEMENT_CRITERIA_PADDING)
        yOffset = LayoutCriteriaSection(self.checkBoxes, yOffset, self.control, GetCriteriaHeightCheckBox, 90)
        yOffset = LayoutLineSection(self.lineThumbs, yOffset, self.control, ACHIEVEMENT_LINE_THUMB_WIDTH, ACHIEVEMENT_LINE_THUMB_HEIGHT)

        local hasRewards = (#self.rewardLabels > 0 or #self.rewardIcons > 0 or #self.dyeSwatches > 0)

        if hasRewards then
            yOffset = yOffset + 15 -- push down a little from the criteria
            self.yOffsetWhereRewardsStart = yOffset
            yOffset = LayoutRewardSection(self.rewardLabels, yOffset, self.control, ACHIEVEMENT_REWARD_LABEL_HEIGHT)
            yOffset = LayoutRewardSection(self.rewardIcons, yOffset, self.control, ACHIEVEMENT_REWARD_ICON_HEIGHT)
            yOffset = LayoutRewardSection(self.dyeSwatches, yOffset, self.control, ACHIEVEMENT_REWARD_ICON_HEIGHT)
        end

        if hasRewards then
            yOffset = LayoutCriteriaSection(self.characterEarned, yOffset, self.control, 20, 80)
        else
            yOffset = LayoutCriteriaSection(self.characterEarned, yOffset, self.control, 20, 90)
            yOffset = AddSectionPadding(self.characterEarned, yOffset, ACHIEVEMENT_CRITERIA_PADDING)
        end

        footerPad = hasRewards and footerPad or 0
        self.control:SetHeight(yOffset + footerPad)
    end
end

function Achievement:AddProgressBar(description, numCompleted, numRequired, showBarDescription)
    local bar, key = self.statusBarPool:AcquireObject()
    bar.key = key

    bar.label:SetText(showBarDescription and zo_strformat(SI_ACHIEVEMENT_CRITERION_FORMAT, description) or "")
    ZO_Achievements_ApplyTextColorToLabel(bar.label, numCompleted == numRequired, ZO_SELECTED_TEXT)

    local numCompletedAsString = ZO_CommaDelimitNumber(numCompleted)
    local numRequiredAsString = ZO_CommaDelimitNumber(numRequired)

    bar.additionalVerticalPadding = select(2, bar.label:GetTextDimensions()) + 4 -- add for for the anchor offset of the label from the bar
    bar.progress:SetText(zo_strformat(SI_JOURNAL_PROGRESS_BAR_PROGRESS, numCompletedAsString, numRequiredAsString))
    bar:SetMinMax(0, numRequired)
    bar:SetValue(numCompleted)
    bar:SetParent(self.control)

    bar:SetHidden(false)

    self.progressBars[#self.progressBars + 1] = bar
end

function Achievement:AddCheckBox(description, checked)
    local check, key = self.checkPool:AcquireObject()
    check.key = key

    ZO_Achievements_ApplyTextColorToLabel(check.label, checked, ZO_SELECTED_TEXT)
    check.label:SetText(zo_strformat(SI_ACHIEVEMENT_CRITERION_FORMAT, description))
    check:SetParent(self.control)
    check:SetAlpha(checked and 1 or 0)
    check:SetHidden(false)

    self.checkBoxes[#self.checkBoxes + 1] = check
end

function Achievement:AddCharacterEarned(characterClassIcon, characterName, dateEarned, progress)
    local info, key = self.characterEarnedPool:AcquireObject()
    info.key = key

    info.classIcon:SetTexture(characterClassIcon)

    info.characterNameLabel:SetText(characterName)
    ZO_Achievements_ApplyTextColorToLabel(info.characterNameLabel, true)

    info.dateEarnedLabel:SetText(dateEarned)
    ZO_Achievements_ApplyTextColorToLabel(info.dateEarnedLabel, true)

    if (progress ~= nil) then
        info.progressLabel:SetText(progress)
        info.progressLabel:SetHidden(false)
        ZO_Achievements_ApplyTextColorToLabel(info.progressLabel, true)
    else
        info.progressLabel:SetHidden(true)
    end

    info:SetParent(self.control)
    info:SetHidden(false)

    self.characterEarned[#self.characterEarned + 1] = info
end

function Achievement:AddIconReward(name, icon, displayQuality, rewardIndex)
    local iconControl, key = self.rewardIconPool:AcquireObject()
    iconControl.key = key
    iconControl.icon:SetTexture(icon)
    iconControl:SetHidden(false)
    iconControl.rewardIndex = rewardIndex
    iconControl.owner = self
    iconControl:SetParent(self.control)

    ZO_Inventory_BindSlot(iconControl, SLOT_TYPE_ACHIEVEMENT_REWARD, rewardIndex, self.achievementId)
    iconControl.label:SetText(name) -- Already localized
    iconControl.label:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, displayQuality))

    self.rewardIcons[#self.rewardIcons + 1] = iconControl
end

function Achievement:GetPooledLabel(labelType, completed)
    local label, key = self.rewardLabelPool:AcquireObject()
    label.key = key
    label:SetParent(self.control)

    label:SetDimensions(ACHIEVEMENT_REWARD_LABEL_WIDTH, ACHIEVEMENT_REWARD_LABEL_HEIGHT)
    if labelType == PREFIX_LABEL then
        label:SetDimensions(0, ACHIEVEMENT_REWARD_LABEL_HEIGHT)
    end

    ZO_Achievements_ApplyTextColorToLabel(label, completed)

    label.prefix = nil
    label.isHeader = labelType == HEADER_LABEL
    label:SetMouseEnabled(false)
    label:SetHidden(false)
    self.rewardLabels[#self.rewardLabels + 1] = label
    return label
end

function Achievement:AddTitleReward(name, completed)
    local title = self:GetPooledLabel(nil, completed)
    title:SetText(name) -- already localized

    local titlePrefix = self:GetPooledLabel(PREFIX_LABEL, completed)
    titlePrefix:SetText(GetString(SI_ACHIEVEMENTS_TITLE))
    title.prefix = titlePrefix
end

function Achievement:AddDyeReward(dyeId, completed)
    local dyeName, known, rarity, hueCategory, achievementId, r, g, b, sortKey = GetDyeInfoById(dyeId)

    local dyeSwatch, key = self.dyeSwatchPool:AcquireObject()
    dyeSwatch.key = key

    dyeSwatch.icon:SetColor(1, r, g, b)

    local dyeNamePrefix = self:GetPooledLabel(PREFIX_LABEL, completed)
    dyeNamePrefix:SetText(GetString(SI_ACHIEVEMENTS_DYE))
    dyeSwatch.prefix = dyeNamePrefix

    dyeSwatch:SetHidden(false)
    dyeSwatch.owner = self
    dyeSwatch:SetParent(self.control)

    dyeSwatch.label:SetText(zo_strformat(SI_DYEING_SWATCH_TOOLTIP_TITLE, dyeName))
    ZO_Achievements_ApplyTextColorToLabel(dyeSwatch.label, completed)

    self.dyeSwatches[#self.dyeSwatches + 1] = dyeSwatch
end

function Achievement:AddCollectibleReward(collectibleId, completed)
    local collectibleNameLabel = self:GetPooledLabel(nil, completed)

    local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)

    collectibleNameLabel:SetText(collectibleData:GetFormattedName())

    local collectiblePrefixLabel = self:GetPooledLabel(PREFIX_LABEL, completed)
    collectiblePrefixLabel:SetText(zo_strformat(SI_ACHIEVEMENTS_COLLECTIBLE_CATEGORY, collectibleData:GetCategoryTypeDisplayName()))
    collectibleNameLabel.prefix = collectiblePrefixLabel
end

do
    local ORDER_PREFIX = 1
    local ORDER_POSTFIX = 2

    local function AddAchievementLineThumb(owner, achievementId, lineThumbPool, lineThumbs, queryFunction, order)
        if achievementId == 0 then return end

        if(order == ORDER_PREFIX) then
            AddAchievementLineThumb(owner, queryFunction(achievementId), lineThumbPool, lineThumbs, queryFunction, order)
        end

        local points, icon, completed = select(3, GetAchievementInfo(achievementId))

        local lineThumb, key = lineThumbPool:AcquireObject()
        lineThumb.key = key

        lineThumb.icon:SetTexture(icon)
        lineThumb.label:SetText(points)
        lineThumb.achievementId = achievementId
        lineThumb.owner = owner

        if(completed) then
            lineThumb.icon:SetDesaturation(0)
            lineThumb.label:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        else
            lineThumb.icon:SetDesaturation(ZO_ACHIEVEMENT_DISABLED_DESATURATION)
            lineThumb.label:SetColor(ZO_ACHIEVEMENT_DISABLED_COLOR:UnpackRGBA())
        end

        lineThumb:SetHidden(false)

        lineThumbs[#lineThumbs + 1] = lineThumb

        if(order == ORDER_POSTFIX) then
            AddAchievementLineThumb(owner, queryFunction(achievementId), lineThumbPool, lineThumbs, queryFunction, order)
        end
    end

    function Achievement:RefreshExpandedLineView()
        local lineThumbPool = self.lineThumbPool
        local lineThumbs = self.lineThumbs
        local achievementId = self.achievementId
        local previousInLine = GetPreviousAchievementInLine(achievementId)
        local nextInLine = GetNextAchievementInLine(achievementId)
        local shouldAddSelfAsLine = (previousInLine ~= 0) or (nextInLine ~= 0)

        AddAchievementLineThumb(self, previousInLine, lineThumbPool, lineThumbs, GetPreviousAchievementInLine, ORDER_PREFIX)

        if(shouldAddSelfAsLine) then
            AddAchievementLineThumb(self, achievementId, lineThumbPool, lineThumbs)
        end

        AddAchievementLineThumb(self, nextInLine, lineThumbPool, lineThumbs, GetNextAchievementInLine, ORDER_POSTFIX)
    end
end

function Achievement:WouldShowLines()
    local achievementId = self.achievementId
    return GetPreviousAchievementInLine(achievementId) ~= 0 or GetNextAchievementInLine(achievementId) ~= 0
end

function Achievement:WouldHaveVisibleCriteria()
    local numCriteria = GetAchievementNumCriteria(self.achievementId)
    if(numCriteria > 1) then return true end
    if(numCriteria == 0) then return false end

    local _, _, numRequired = GetAchievementCriterion(self.achievementId, 1)
    if(numRequired == 1) then return false end -- This would be the only checkbox, it doesn't count as a visible criteria

    return true
end

function Achievement:HasTangibleReward()
    local hasReward = GetAchievementNumRewards(self.achievementId) > 1
    local hasCompleted = self.completed

    local prevAchievement = GetPreviousAchievementInLine(self.achievementId)
    while prevAchievement ~= 0 do
        hasReward = hasReward or GetAchievementNumRewards(prevAchievement) > 1
        hasCompleted = hasCompleted or select(5, GetAchievementInfo(prevAchievement))
        prevAchievement = GetPreviousAchievementInLine(prevAchievement)
    end

    local nextAchievement = GetNextAchievementInLine(self.achievementId)
    while nextAchievement ~= 0 do
        hasReward = hasReward or GetAchievementNumRewards(nextAchievement) > 1
        hasCompleted = hasCompleted or select(5, GetAchievementInfo(nextAchievement))
        nextAchievement = GetNextAchievementInLine(nextAchievement)
    end

    return hasReward, hasCompleted
end

function Achievement:IsExpandable()
    return self.description:WasTruncated() or self:WouldHaveVisibleCriteria() or self:HasTangibleReward() or self:WouldShowLines()
end

function Achievement:RefreshExpandedCriteria()
    local numCriteria = GetAchievementNumCriteria(self.achievementId)
    local hasMultipleCriteria = (numCriteria > 1)
    local showProgressBarDescriptions = hasMultipleCriteria
    for i = 1, numCriteria do
        local description, numCompleted, numRequired = GetAchievementCriterion(self.achievementId, i)

        if(numRequired > 1) then
            self:AddProgressBar(description, numCompleted, numRequired, showProgressBarDescriptions)
        elseif(hasMultipleCriteria and (numRequired == 1)) then
            self:AddCheckBox(description, numCompleted == 1)
        end
    end
end

function Achievement:RefreshExpandedCharacterEarned()
    -- Returns if the inner loop was reached at least once
    local function AddCharacterLine(characters)
        for id, character in pairs(characters) do
            local dateEarned = character.date
            local progress = character.progress -- could be nil
            local characterName = QUANTUMPIES_GA:GetCharacterNameFromId(id)
            local characterClassId = QUANTUMPIES_GA.characterInfo[id].class
            local classIcon = QUANTUMPIES_GA_CONSTANTS.classIdToIcon[characterClassId]
            self:AddCharacterEarned(classIcon, characterName, dateEarned, progress)
        end
    end


    local lineId = GetFirstAchievementInLine(self.achievementId)
    if (lineId ~= 0) then
        AddCharacterLine(QUANTUMPIES_GA:QueryFirstAchievementInLine(self.achievementId)["characters"])
    else
        AddCharacterLine(QUANTUMPIES_GA:QueryAchievementByID(self.achievementId)["characters"])
    end
end

local function AddRewards(self, achievementId)
    local completed = select(5, GetAchievementInfo(achievementId))

    -- get item reward
    local hasRewardItem, itemName, iconTextureName, displayQuality = GetAchievementRewardItem(achievementId)
    if hasRewardItem then
        self:AddIconReward(itemName, iconTextureName, displayQuality, 1)
    end

    -- get title reward
    local hasRewardTitle, titleName = GetAchievementRewardTitle(achievementId)
    if hasRewardTitle then
        -- TODO if there is a title and another reward, add a partially filled reward icon
        self:AddTitleReward(titleName, completed)
    end

    -- get dye reward
    local hasRewardDye, dyeId = GetAchievementRewardDye(achievementId)
    if hasRewardDye then
        self:AddDyeReward(dyeId, completed or self.globalEarned)
    end

    -- get collectible reward
    local hasRewardCollectible, collectibleId = GetAchievementRewardCollectible(achievementId)
    if hasRewardCollectible then
        self:AddCollectibleReward(collectibleId, completed or self.globalEarned)
    end
end

function Achievement:RefreshExpandedRewards()
    local numLineThumbs = #self.lineThumbs

    if numLineThumbs > 0 then
        for _, lineThumb in ipairs(self.lineThumbs) do
            local achievementId = lineThumb.achievementId
            AddRewards(self, lineThumb.achievementId)
        end
    else
        AddRewards(self, self.achievementId)
    end
end

function Achievement:RefreshRewardThumb()
    if(self.rewardThumb and self.yOffsetWhereRewardsStart) then
        self.rewardThumb:ClearAnchors()
        self.rewardThumb:SetAnchor(TOPLEFT, self.control, TOPLEFT, 42, self.yOffsetWhereRewardsStart - 6)
    end
end
-- HERE to extend UI with more info
function Achievement:RefreshExpandedView()
    if self.collapsed then return end
    self:ReleaseSharedControls()

    self:RefreshExpandedCriteria()
    self:RefreshExpandedLineView()
    self:RefreshExpandedRewards()
    self:RefreshExpandedCharacterEarned()

    self:PerformExpandedLayout()
    self:RefreshRewardThumb()
end

function Achievement:PlayExpandCollapseSound()
    if(not self.isExpandable) then return end

    if(self.collapsed) then
        PlaySound(SOUNDS.ACHIEVEMENT_COLLAPSED)
    else
        PlaySound(SOUNDS.ACHIEVEMENT_EXPANDED)
    end
end

function Achievement:UpdateExpandedStateIcon()
    if(self.expandedStateIcon) then
        if self.isExpandable then
            if(self.collapsed) then
                ZO_ToggleButton_SetState(self.expandedStateIcon, TOGGLE_BUTTON_CLOSED)
            else
                ZO_ToggleButton_SetState(self.expandedStateIcon, TOGGLE_BUTTON_OPEN)
            end
        else
            self.expandedStateIcon:SetHidden(true)
        end
    end
end

function Achievement:CalculateDescriptionWidth()
    local descriptionWidth = ACHIEVEMENT_DESC_WIDTH

    if self.completed then
        local widthModifier = zo_max(0, self.date:GetWidth() - ACHIEVEMENT_DATE_LABEL_EXPECTED_WIDTH)

        if widthModifier ~= 0 then
            descriptionWidth = descriptionWidth - widthModifier
        end
    end

    return descriptionWidth
end

function Achievement:Expand()
    if self.collapsed then
        self.collapsed = false

        self:RemoveCollapsedDescriptionConstraints()
        self:RefreshExpandedView()
        self:UpdateExpandedStateIcon()
        self:PlayExpandCollapseSound()
    end
end

function Achievement:ApplyCollapsedDescriptionConstraints()
    if self.title:DidLineWrap() then
        self.description:SetDimensionConstraints(0, 0, self:CalculateDescriptionWidth(), ACHIEVEMENT_DESC_COLLAPSED_HEIGHT / 2)
    else
        self.description:SetDimensionConstraints(0, 0, self:CalculateDescriptionWidth(), ACHIEVEMENT_DESC_COLLAPSED_HEIGHT)
    end
end

function Achievement:RemoveCollapsedDescriptionConstraints()
    self.description:SetDimensionConstraints(0, 0, self:CalculateDescriptionWidth(), 0)
end

function Achievement:Collapse()
    if not self.collapsed then
        self.collapsed = true

        if self.rewardThumb then
            self.rewardThumb:ClearAnchors()
            self.rewardThumb:SetAnchor(TOPLEFT, self.control, TOPLEFT, 42, 58)
        end

        self:ApplyCollapsedDescriptionConstraints()
        self.control:SetHeight(ACHIEVEMENT_COLLAPSED_HEIGHT)
        self:UpdateExpandedStateIcon()
        self:PlayExpandCollapseSound()
        self:ReleaseSharedControls()
    end
end

do
    local function ReleaseControls(pool, controls)
        for i = #controls, 1, -1 do
            pool:ReleaseObject(controls[i].key)
            controls[i] = nil
        end
    end
    function Achievement:ReleaseSharedControls()
        ReleaseControls(self.checkPool, self.checkBoxes)
        ReleaseControls(self.statusBarPool, self.progressBars)
        ReleaseControls(self.rewardIconPool, self.rewardIcons)
        ReleaseControls(self.rewardLabelPool, self.rewardLabels)
        ReleaseControls(self.lineThumbPool, self.lineThumbs)
        ReleaseControls(self.dyeSwatchPool, self.dyeSwatches)
        ReleaseControls(self.characterEarnedPool, self.characterEarned)

        self.rewardLabel = nil
    end
end

function Achievement:SetAnchoredToAchievement(previous)
    self.control:ClearAnchors()

    -- This ensures that we can't have orphans, but it also means that we must do things in the proper order
    -- So whenever moving an achievement in the list, you must move the achievement to its new spot BEFORE closing the gap
    if self.anchoredToAchievement then
        self.anchoredToAchievement:SetDependentAnchoredAchievement(nil)
        self.anchoredToAchievement = nil
    end

    if previous then
        self.control:SetAnchor(TOP, previous:GetControl(), BOTTOM, 0, ACHIEVEMENT_PADDING)
        previous:SetDependentAnchoredAchievement(self)
        self.anchoredToAchievement = previous
    else
        self.control:SetAnchor(TOPLEFT, nil, TOPLEFT)
    end
end

function Achievement:GetAnchoredToAchievement()
    return self.anchoredToAchievement
end

function Achievement:SetDependentAnchoredAchievement(dependentAchievement)
    self.dependentAnchoredAchievement = dependentAchievement
end

function Achievement:GetDependentAnchoredAchievement()
    return self.dependentAnchoredAchievement
end

function Achievement:GetControl()
    return self.control
end

function Achievement:ToggleCollapse()
    if self.collapsed then
        self:Expand()
    else
        self:Collapse()
    end
end

function Achievement:Reset()
    self.control:SetHidden(true)
    self:SetHighlightHidden(true)
    self:Collapse()
    self.rewardLabel = nil
    self:SetIndex(nil)

    self.anchoredToAchievement = nil
    self:SetDependentAnchoredAchievement(nil)
end

function Achievement:SetHighlightHidden(hidden)
    if self.highlight then
        self.highlight:SetHidden(false) -- let alpha take care of the actual hiding

        if not self.highlightAnimation then
            self.highlightAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("AchievementHighlightAnimation_Keyboard", self.highlight)
        end

        if(hidden) then
            self.highlightAnimation:PlayBackward()
        else
            self.highlightAnimation:PlayForward()
        end
    end
end

function Achievement:OnMouseEnter()
    self:SetHighlightHidden(false)
end

function Achievement:OnMouseExit()
    self:SetHighlightHidden(true)
end

function Achievement:OnClicked(button)
    if(button == MOUSE_BUTTON_INDEX_LEFT) then
        self:ToggleCollapse()
    elseif(button == MOUSE_BUTTON_INDEX_RIGHT and IsChatSystemAvailableForCurrentPlatform()) then
        ClearMenu()
        AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, self:GetId())) end)
        ShowMenu(self.control)
    end
end

QUANTUMPIES_GA_ACHIEVEMENT = Achievement