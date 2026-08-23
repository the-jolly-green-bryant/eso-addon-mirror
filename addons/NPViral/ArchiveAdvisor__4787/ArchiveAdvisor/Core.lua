ArchiveAdvisor = ArchiveAdvisor or {}
local ADDON = ArchiveAdvisor

ADDON.name = "ArchiveAdvisor"
ADDON.version = "1.0.0"
ADDON.marker = nil
ADDON.whyLabel = nil
ADDON.hookedKeyboard = false
ADDON.hookedGamepad = false
ADDON.emptyRefreshRetryPending = false

local ICON_GOOD = ZO_CHECK_ICON or "EsoUI/Art/Miscellaneous/check_icon_32.dds"

local WHY_SEPARATOR = " • "
local MAX_WHY_BYTES = 24
local DEFAULT_NAME_OFFSET_Y = 10
local RECOMMENDED_NAME_OFFSET_Y = 28
local WHY_OFFSET_Y = 5

local WHY_FLAG_LABELS = {
    HA_SPECIALIST = "Heavy Attack",
    PET_SKILL = "Pet",
    PET_ACTIVE = "Active Pet",
    STATUS = "Status",
    SHIELD = "Shield",
    LIGHTNING = "Lightning",
    AOE = "AoE",
    RANGED = "Ranged",
    WEAPON_ENCHANT = "Enchant",
    WEAKENING_ENCHANT = "Weakening",
    DOT = "DoT",
    MAGICAL = "Magic",
    MARTIAL = "Martial",
    MAGICKA_FOCUS = "Magicka",
    STAMINA_FOCUS = "Stamina",
    POISON = "Poison",
    FIRE = "Fire",
    FROST = "Frost",
}

local WHY_FAMILY_LABELS = {
    CLASS = "Class Skills",
    WEAPON = "Weapon Skill",
    GUILD = "Guild Skill",
    WORLD = "World Skill",
    AVA = "Alliance War",
}

local function AddWhyCandidate(candidates, label, weight)
    if label and label ~= "" and weight and weight > 0 then
        table.insert(candidates, { label = label, weight = weight })
    end
end

local function BuildWhyText(candidates)
    table.sort(candidates, function(a, b)
        if a.weight == b.weight then
            return a.label < b.label
        end
        return a.weight > b.weight
    end)

    local labels = {}
    local seen = {}
    for _, candidate in ipairs(candidates) do
        if not seen[candidate.label] then
            seen[candidate.label] = true
            table.insert(labels, candidate.label)
            if #labels == 2 then
                break
            end
        end
    end

    local first = labels[1] or ""
    local second = labels[2]
    if second then
        local combined = first .. WHY_SEPARATOR .. second
        if #combined <= MAX_WHY_BYTES then
            return combined
        end
    end

    return first
end

function ADDON:CreateRecommendationControls()
    if self.marker then
        return
    end

    local marker = WINDOW_MANAGER:CreateControl("ArchiveAdvisorRecommendationMarker", GuiRoot, CT_TEXTURE)
    marker:SetDimensions(24, 24)
    marker:SetTexture(ICON_GOOD)
    marker:SetColor(0.50, 0.90, 0.50, 0.95)
    marker:SetDrawTier(DT_HIGH)
    marker:SetDrawLayer(DL_OVERLAY)
    marker:SetDrawLevel(102)
    marker:SetHidden(true)

    local whyLabel = WINDOW_MANAGER:CreateControl("ArchiveAdvisorRecommendationWhy", GuiRoot, CT_LABEL)
    whyLabel:SetDimensions(136, 18)
    whyLabel:SetFont("ZoFontGameSmall")
    whyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    whyLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    whyLabel:SetColor(1, 1, 1, 1)
    whyLabel:SetDrawTier(DT_HIGH)
    whyLabel:SetDrawLayer(DL_OVERLAY)
    whyLabel:SetDrawLevel(101)
    whyLabel:SetHidden(true)

    self.marker = marker
    self.whyLabel = whyLabel
end

function ADDON:HideRecommendation()
    if self.marker then
        self.marker:SetHidden(true)
        self.whyLabel:SetHidden(true)
    end
end

function ADDON:CollectChoices(selector)
    local choices = {}

    if not selector or not selector.buffControls then
        return choices
    end

    for _, buffControl in ipairs(selector.buffControls) do
        local abilityId = buffControl.abilityId
        if abilityId and abilityId > 0 and not buffControl:IsHidden() then
            local buffType, isAvatarVision = GetAbilityEndlessDungeonBuffType(abilityId)
            table.insert(choices, {
                abilityId = abilityId,
                bucketType = buffControl.bucketType,
                buffType = buffType,
                isAvatarVision = isAvatarVision,
                control = buffControl,
            })
        end
    end

    return choices
end

function ADDON:GetAvatarProgress(choice, snapshot)
    local avatarSetName = self.Data.AVATAR_SET_BY_ABILITY[choice.abilityId]
    if not avatarSetName then
        return nil
    end

    local ownedUnique = 0
    for _, memberAbilityId in ipairs(self.Data.AVATAR_SETS[avatarSetName]) do
        if (snapshot.run.visionStacks[memberAbilityId] or 0) > 0 then
            ownedUnique = ownedUnique + 1
        end
    end

    local alreadyOwned = (snapshot.run.visionStacks[choice.abilityId] or 0) > 0
    local resultingUnique = alreadyOwned and ownedUnique or math.min(ownedUnique + 1, 3)

    return resultingUnique, ownedUnique, avatarSetName
end

function ADDON:GetOrCreateAvatarTag(buffControl)
    if buffControl.archiveAdvisorAvatarTag then
        return buffControl.archiveAdvisorAvatarTag
    end

    local tagName = string.format("%sArchiveAdvisorAvatarTag", buffControl:GetName())
    local label = WINDOW_MANAGER:CreateControl(tagName, buffControl, CT_LABEL)
    label:SetDimensions(44, 24)
    label:SetFont("ZoFontGameBold")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(1, 0.82, 0.32, 1)
    label:SetDrawTier(DT_HIGH)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawLevel(99)
    label:SetHidden(true)

    buffControl.archiveAdvisorAvatarTag = label
    return label
end

function ADDON:UpdateAvatarTags(selector, choices, snapshot)
    if selector and selector.buffControls then
        for _, buffControl in ipairs(selector.buffControls) do
            local existingTag = buffControl.archiveAdvisorAvatarTag
            if existingTag then
                existingTag:SetHidden(true)
            end
        end
    end

    if ADDON.savedVariables and not ADDON.savedVariables.showAvatarProgress then
        return
    end

    for _, choice in ipairs(choices) do
        if choice.isAvatarVision and choice.control and choice.control.iconTexture then
            local resultingUnique = self:GetAvatarProgress(choice, snapshot)
            if resultingUnique then
                local tag = self:GetOrCreateAvatarTag(choice.control)
                tag:ClearAnchors()
                tag:SetAnchor(TOPLEFT, choice.control.iconTexture, TOPLEFT, -5, -5)
                tag:SetText(string.format("%d/3", resultingUnique))
                tag:SetHidden(false)
            end
        end
    end
end

function ADDON:ScoreChoice(choice, snapshot)
    local rule = self.Data.EVALUATOR[choice.abilityId]
    if not rule then
        return nil, nil
    end

    local score = rule.base or 0
    local whyCandidates = {}
    AddWhyCandidate(whyCandidates, rule.why, math.max(score, 1))

    if rule.requiresFamily and snapshot.skillFamilyCounts then
        local familyCount = snapshot.skillFamilyCounts[rule.requiresFamily] or 0
        if familyCount == 0 then
            return 0, rule.why
        end
    end

    if rule.requiresFlag and not snapshot.flags[rule.requiresFlag] then
        return 0, rule.why
    end

    local recommendationStyle = ADDON.savedVariables and ADDON.savedVariables.recommendationStyle or "Balanced"
    local styleMatchesBucket =
        (recommendationStyle == "Damage" and choice.bucketType == ENDLESS_DUNGEON_BUFF_BUCKET_TYPE_OFFENSE) or
        (recommendationStyle == "Survival" and choice.bucketType == ENDLESS_DUNGEON_BUFF_BUCKET_TYPE_DEFENSE)
    if styleMatchesBucket then
        local styleBonus = self.Data.STYLE_BONUS or 0
        score = score + styleBonus
        AddWhyCandidate(whyCandidates, recommendationStyle .. " Style", styleBonus)
    end

    if rule.flagBonuses then
        for flagName, bonus in pairs(rule.flagBonuses) do
            if snapshot.flags[flagName] then
                score = score + bonus
                AddWhyCandidate(whyCandidates, WHY_FLAG_LABELS[flagName], bonus)
            end
        end
    end

    if rule.flagPenalties then
        for flagName, penalty in pairs(rule.flagPenalties) do
            if snapshot.flags[flagName] then
                score = score - penalty
            end
        end
    end

    if rule.familyBonus and snapshot.skillFamilyCounts then
        local family = rule.familyBonus.family
        local count = snapshot.skillFamilyCounts[family] or 0
        if count > 0 then
            local bonus = math.min(count * rule.familyBonus.perSlot, rule.familyBonus.max)
            score = score + bonus
            AddWhyCandidate(whyCandidates, WHY_FAMILY_LABELS[family], bonus)
        end
    end

    local arcBonus = rule.arcBonus
    if arcBonus and snapshot.run.arc >= arcBonus.startArc then
        local bonus = math.min((snapshot.run.arc - arcBonus.startArc + 1) * arcBonus.perArc, arcBonus.max)
        score = score + bonus
        AddWhyCandidate(whyCandidates, "Deep Run", bonus)
    end

    local attemptsBonus = rule.attemptsBonus
    if attemptsBonus then
        local attemptsRemaining = snapshot.run.attemptsRemaining or 0
        local bonus = attemptsBonus[attemptsRemaining]
        if bonus and bonus > 0 then
            score = score + bonus
            AddWhyCandidate(whyCandidates, "Low Threads", bonus)
        end
    end

    local stackCount = 0
    if choice.buffType == ENDLESS_DUNGEON_BUFF_TYPE_VISION then
        stackCount = snapshot.run.visionStacks[choice.abilityId] or 0
    elseif choice.buffType == ENDLESS_DUNGEON_BUFF_TYPE_VERSE then
        stackCount = snapshot.run.verseStacks[choice.abilityId] or 0
    end

    if rule.stackGoal then
        if stackCount < rule.stackGoal and rule.belowGoalBonus then
            score = score + rule.belowGoalBonus
            AddWhyCandidate(whyCandidates, "Stacking Value", rule.belowGoalBonus)
        elseif stackCount >= rule.stackGoal and rule.afterGoalPenalty then
            score = score - rule.afterGoalPenalty
        end
    end

    local resultingUnique, ownedUnique, avatarSetName = self:GetAvatarProgress(choice, snapshot)
    if avatarSetName and stackCount == 0 then
        local progressBonus = 0
        if ownedUnique == 0 then
            progressBonus = 3
        elseif ownedUnique == 1 then
            progressBonus = 8
        elseif ownedUnique >= 2 then
            progressBonus = 18
        end

        if snapshot.flags.HA_SPECIALIST and (avatarSetName == "CRYSTALLINE" or avatarSetName == "SCORCHING") then
            progressBonus = progressBonus + 8
        end

        if progressBonus > 0 then
            score = score + progressBonus
        end
    end

    return score, BuildWhyText(whyCandidates)
end

function ADDON:ChooseBest(choices, snapshot)
    local bestChoice = nil
    local bestScore = nil
    local bestWhy = nil
    local hasUnknown = false

    for _, choice in ipairs(choices) do
        local score, whyText = self:ScoreChoice(choice, snapshot)

        if score == nil then
            hasUnknown = true
        elseif not bestChoice or score > bestScore then
            bestChoice = choice
            bestScore = score
            bestWhy = whyText
        end
    end

    if hasUnknown then
        return nil, true, nil
    end

    return bestChoice, false, bestWhy
end

function ADDON:SetChoiceNameOffset(selector, offsetY)
    if not selector or not selector.buffControls then
        return
    end

    for _, buffControl in ipairs(selector.buffControls) do
        if buffControl.nameLabel and buffControl.iconTexture then
            buffControl.nameLabel:ClearAnchors()
            buffControl.nameLabel:SetAnchor(TOP, buffControl.iconTexture, BOTTOM, 0, offsetY)
        end
    end
end

function ADDON:RestoreChoiceNameLayout(selector)
    self:SetChoiceNameOffset(selector, DEFAULT_NAME_OFFSET_Y)
end

function ADDON:MarkChoice(choice, whyText)
    if not choice or not choice.control or not choice.control.iconTexture then
        self:HideRecommendation()
        return
    end

    self:CreateRecommendationControls()
    local iconTexture = choice.control.iconTexture

    self.marker:SetParent(choice.control)
    self.marker:ClearAnchors()
    self.marker:SetAnchor(TOPRIGHT, iconTexture, TOPRIGHT, 3, -5)
    self.marker:SetHidden(false)

    self.whyLabel:SetParent(choice.control)
    self.whyLabel:ClearAnchors()
    self.whyLabel:SetAnchor(TOP, iconTexture, BOTTOM, 0, WHY_OFFSET_Y)
    self.whyLabel:SetText(whyText or "")
    self.whyLabel:SetHidden(false)
end

function ADDON:OnSelectorRefreshed(selector, isRetry)
    self:RestoreChoiceNameLayout(selector)
    local choices = self:CollectChoices(selector)
    if #choices == 0 then
        self:HideRecommendation()

        if not isRetry and not self.emptyRefreshRetryPending then
            self.emptyRefreshRetryPending = true
            zo_callLater(function()
                ADDON.emptyRefreshRetryPending = false
                ADDON:OnSelectorRefreshed(selector, true)
            end, 300)
        end
        return
    end

    local snapshot = self.Build:Snapshot()
    local bestChoice, _, bestWhy = self:ChooseBest(choices, snapshot)

    self:UpdateAvatarTags(selector, choices, snapshot)
    if ADDON.savedVariables and not ADDON.savedVariables.recommendationsEnabled then
        self:MarkChoice(nil)
    elseif bestChoice then
        self:SetChoiceNameOffset(selector, RECOMMENDED_NAME_OFFSET_Y)
        self:MarkChoice(bestChoice, bestWhy)
    else
        self:MarkChoice(nil)
    end
end

function ADDON:RefreshVisibleSelector()
    local selectors = {
        ENDLESS_DUNGEON_BUFF_SELECTOR_KEYBOARD,
        ENDLESS_DUNGEON_BUFF_SELECTOR_GAMEPAD,
    }

    for _, selector in ipairs(selectors) do
        if selector and type(selector.IsShowing) == "function" and selector:IsShowing() then
            self:OnSelectorRefreshed(selector)
            return true
        end
    end

    return false
end

function ADDON:InstallSelectorHooks()
    local keyboardSelector = ENDLESS_DUNGEON_BUFF_SELECTOR_KEYBOARD
    if not self.hookedKeyboard
        and keyboardSelector
        and type(keyboardSelector.RefreshBuffs) == "function" then
        ZO_PostHook(keyboardSelector, "RefreshBuffs", function(selector)
            ADDON:OnSelectorRefreshed(selector)
        end)
        self.hookedKeyboard = true
    end

    local gamepadSelector = ENDLESS_DUNGEON_BUFF_SELECTOR_GAMEPAD
    if not self.hookedGamepad
        and gamepadSelector
        and type(gamepadSelector.RefreshBuffs) == "function" then
        ZO_PostHook(gamepadSelector, "RefreshBuffs", function(selector)
            ADDON:OnSelectorRefreshed(selector)
        end)
        self.hookedGamepad = true
    end
end

function ADDON:OnAddOnLoaded(_, addonName)
    if addonName ~= self.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    self.Settings:Initialize()
    self:InstallSelectorHooks()

    if not (self.hookedKeyboard and self.hookedGamepad) then
        local activationEventName = self.name .. "Activated"
        EVENT_MANAGER:RegisterForEvent(activationEventName, EVENT_PLAYER_ACTIVATED, function()
            ADDON:InstallSelectorHooks()
            if ADDON.hookedKeyboard and ADDON.hookedGamepad then
                EVENT_MANAGER:UnregisterForEvent(activationEventName, EVENT_PLAYER_ACTIVATED)
            end
        end)
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED, function(...)
    ADDON:OnAddOnLoaded(...)
end)
