local Addon = LarvalTearMod
local LTM_UI = Addon.UI
local LTM_UI_STRINGS = Addon.UI.Strings
local LTM_UI_DISPATCH = Addon.UI.Dispatch
local LTM_UI_LAYOUT = Addon.UI.LayoutConstants
local LTM_UI_CARD_LAYOUT = LTM_UI_LAYOUT.Card
local LTM_BUILD_CODEC = Addon.Modules.BuildCodec

local UI_CARD_SPACING = LTM_UI_CARD_LAYOUT.SPACING
local UI_CARD_HEADER_HEIGHT = LTM_UI_CARD_LAYOUT.HEADER_HEIGHT
local UI_CARD_ROLE_ICON_SIZE = LTM_UI_CARD_LAYOUT.ROLE_ICON_SIZE
local UI_CARD_TITLE_LEFT = LTM_UI_CARD_LAYOUT.TITLE_LEFT
local UI_CARD_ORDINAL_WIDTH = LTM_UI_CARD_LAYOUT.ORDINAL_WIDTH
local UI_CARD_ORDINAL_GAP = LTM_UI_CARD_LAYOUT.ORDINAL_GAP
local UI_CARD_TITLE_ROLE_GAP = LTM_UI_CARD_LAYOUT.TITLE_ROLE_GAP
local UI_CARD_EXPANDED_HEIGHT = LTM_UI_CARD_LAYOUT.EXPANDED_HEIGHT
local UI_CARD_LIST_SECTION_HEIGHT = LTM_UI_CARD_LAYOUT.LIST_SECTION_FALLBACK_HEIGHT
local UI_CARD_LIST_CONTAINER_SCROLLBAR_GAP = LTM_UI_CARD_LAYOUT.LIST_CONTAINER_SCROLLBAR_GAP
local CARD_ROLE_ICON_TEXTURES = LTM_UI_LAYOUT.RoleIconTextures
local CARD_ATTRIBUTE_LAYOUTS = LTM_UI_LAYOUT.AttributeLayouts
local PASSIVE_POLICY_OPTIONS = {
    { id = "none", textKey = "card.passive_policy.none" },
    { id = "class_all_purchase", textKey = "card.passive_policy.class_all_purchase" },
    { id = "class_only", textKey = "card.passive_policy.class_only" },
    { id = "all", textKey = "card.passive_policy.all" },
}

local function GetText(key, params)
    if type(LTM_UI_STRINGS) == "table" and type(LTM_UI_STRINGS.GetText) == "function" then
        return LTM_UI_STRINGS:GetText(key, params)
    end

    return key
end

local function SetLabelText(control, text)
    if control and control.SetText then
        control:SetText(text or "")
    end
end

local function BuildOutfitDisplayText(outfitName)
    return string.format("%s: %s", GetText("common.outfit"), outfitName or GetText("common.none"))
end

local function NormalizeLinkId(linkId)
    if type(linkId) ~= "string" or linkId == "" or linkId == "none" then
        return nil
    end

    return linkId
end

local function BuildMissingLinkDisplayName(linkId, fallbackText)
    linkId = NormalizeLinkId(linkId)
    if linkId == nil then
        return fallbackText
    end

    -- NOTE:
    -- Missing-link display intentionally hides raw linkId for now.
    -- Revisit if diagnostic missing-link UI is added.
    return fallbackText
end

local function RefreshArmoryPanelsAfterCardLinkChange()
    LTM_UI:RefreshCardList()
    if LTM_UI.window and not LTM_UI.window:IsHidden() and LTM_UI:IsArmoryStationTabActive() then
        LTM_UI:RefreshRightPanePanel()
    end
end

local function SaveCardQuickSlotLink(cardId, profileId)
    if type(LTM_UI_DISPATCH) ~= "table" or type(LTM_UI_DISPATCH.SetCardQuickslotProfileId) ~= "function" then
        LTM_UI:LogActionError("common.save", "dispatch_unavailable")
        RefreshArmoryPanelsAfterCardLinkChange()
        return
    end

    local _, err = LTM_UI_DISPATCH:SetCardQuickslotProfileId(cardId, NormalizeLinkId(profileId))
    if err ~= nil then
        LTM_UI:LogActionError("common.save", err)
    end
    RefreshArmoryPanelsAfterCardLinkChange()
end

local function SaveCardFoodLink(cardId, foodCardId)
    if type(LTM_UI_DISPATCH) ~= "table" or type(LTM_UI_DISPATCH.SetCardFoodCardId) ~= "function" then
        LTM_UI:LogActionError("common.save", "dispatch_unavailable")
        RefreshArmoryPanelsAfterCardLinkChange()
        return
    end

    local _, err = LTM_UI_DISPATCH:SetCardFoodCardId(cardId, NormalizeLinkId(foodCardId))
    if err ~= nil then
        LTM_UI:LogActionError("common.save", err)
    end
    RefreshArmoryPanelsAfterCardLinkChange()
end

local function GetPassivePolicyDisplayName(policy)
    policy = LTM_BUILD_CODEC:NormalizePassivePolicy(policy)
    for _, option in ipairs(PASSIVE_POLICY_OPTIONS) do
        if option.id == policy then
            return GetText(option.textKey)
        end
    end
    return GetText("card.passive_policy.class_all_purchase")
end

local function GetPassivePolicyTooltipText()
    return GetText("card.passive_policy.tooltip", {
        none = GetText("card.passive_policy.none"),
        class_all_purchase = GetText("card.passive_policy.class_all_purchase"),
        class_only = GetText("card.passive_policy.class_only"),
        all = GetText("card.passive_policy.all"),
        snapshot_saved = GetText("card.passive_snapshot.saved"),
        overwrite_passives = GetText("dialog.overwrite_card.option.passives"),
        overwrite_all = GetText("dialog.overwrite_card.option.all"),
    })
end

local function SaveCardPassivePolicy(cardId, passivePolicy)
    if type(LTM_UI_DISPATCH) ~= "table" or type(LTM_UI_DISPATCH.SetCardPassivePolicy) ~= "function" then
        LTM_UI:LogActionError("common.save", "dispatch_unavailable")
        RefreshArmoryPanelsAfterCardLinkChange()
        return
    end

    local _, err = LTM_UI_DISPATCH:SetCardPassivePolicy(cardId, LTM_BUILD_CODEC:NormalizePassivePolicy(passivePolicy))
    if err ~= nil then
        LTM_UI:LogActionError("common.save", err)
    end
    RefreshArmoryPanelsAfterCardLinkChange()
end

local function GetPassiveSnapshotDisplayText(summary)
    local state = type(summary) == "table" and summary.passiveSnapshotState or nil
    local captureState = type(summary) == "table" and summary.passiveSnapshotCaptureState or nil

    if captureState == "partial_class_mismatch" then
        return GetText("card.passive_snapshot.partial_class_mismatch")
    end
    if state == "saved" then
        return GetText("card.passive_snapshot.saved")
    end
    if state == "empty" then
        return GetText("card.passive_snapshot.empty")
    end
    if state == "invalid" then
        return GetText("card.passive_snapshot.invalid")
    end
    return GetText("card.passive_snapshot.missing")
end

local function BuildLinkComboOptions(getOptionsFunc)
    if type(LTM_UI_DISPATCH) ~= "table" or type(getOptionsFunc) ~= "function" then
        return {}
    end

    local options = getOptionsFunc(LTM_UI_DISPATCH)
    return type(options) == "table" and options or {}
end

local function BuildOrdinalText(ordinal)
    ordinal = tonumber(ordinal)

    if type(ordinal) ~= "number" or ordinal < 1 then
        return ""
    end

    return string.format("%d.", math.floor(ordinal))
end

local function ResolveRoleIconTexture(roleState)
    local selectedRole = type(roleState) == "table" and tonumber(roleState.selectedRole) or nil
    if selectedRole ~= LFG_ROLE_TANK and selectedRole ~= LFG_ROLE_HEAL and selectedRole ~= LFG_ROLE_DPS then
        return nil
    end

    return CARD_ROLE_ICON_TEXTURES[selectedRole]
end

function LTM_UI:ApplyBuildCardHeaderLayout(cardControl, hasRole)
    if cardControl == nil or cardControl.titleLabel == nil or cardControl.roleIcon == nil or cardControl.cardHeader == nil then
        return
    end

    local titleLeft = UI_CARD_TITLE_LEFT + UI_CARD_ORDINAL_WIDTH + UI_CARD_ORDINAL_GAP
    if hasRole then
        titleLeft = titleLeft + UI_CARD_ROLE_ICON_SIZE + UI_CARD_TITLE_ROLE_GAP
    end

    cardControl.titleLabel:ClearAnchors()
    cardControl.titleLabel:SetAnchor(TOPLEFT, cardControl.cardHeader, TOPLEFT, titleLeft, 12)
    cardControl.titleLabel:SetAnchor(TOPRIGHT, cardControl.cardHeader, TOPRIGHT, -112, 12)

    cardControl.roleIcon:ClearAnchors()
    cardControl.roleIcon:SetAnchor(
        LEFT,
        cardControl.cardHeader,
        LEFT,
        UI_CARD_TITLE_LEFT + UI_CARD_ORDINAL_WIDTH + UI_CARD_ORDINAL_GAP,
        0
    )
    cardControl.roleIcon:SetDimensions(UI_CARD_ROLE_ICON_SIZE, UI_CARD_ROLE_ICON_SIZE)
end

local function GetBuildCardHeight(self, isExpanded)
    return UI_CARD_HEADER_HEIGHT + (isExpanded and UI_CARD_EXPANDED_HEIGHT or 0)
end

function LTM_UI:PositionBuildCardInList(cardControl, yOffset, isExpanded)
    local cardHeight = GetBuildCardHeight(self, isExpanded)
    yOffset = tonumber(yOffset) or 0

    if cardControl ~= nil then
        cardControl:ClearAnchors()
        cardControl:SetAnchor(TOPLEFT, self.cardListContainer, TOPLEFT, 0, yOffset)
        cardControl:SetAnchor(TOPRIGHT, self.cardListContainer, TOPRIGHT, 0, yOffset)
        cardControl:SetHeight(cardHeight)
    end

    return cardHeight, yOffset + cardHeight + UI_CARD_SPACING
end

function LTM_UI:ApplyCardListContainerLayout(hasScrollbar, height)
    if self.cardListContainer == nil then
        return
    end

    if type(self.cardListContainer.SetHeight) == "function" then
        self.cardListContainer:SetHeight(height)
    end

    if type(self.cardListContainer.ClearAnchors) ~= "function" or self.cardListScrollContainer == nil then
        return
    end

    self.cardListContainer:ClearAnchors()
    self.cardListContainer:SetAnchor(TOPLEFT, self.cardListScrollContainer, TOPLEFT, 0, 0)
    if hasScrollbar and self.cardListScrollBar ~= nil then
        self.cardListContainer:SetAnchor(
            TOPRIGHT,
            self.cardListScrollBar,
            TOPLEFT,
            -UI_CARD_LIST_CONTAINER_SCROLLBAR_GAP,
            0
        )
    else
        self.cardListContainer:SetAnchor(TOPRIGHT, self.cardListScrollContainer, TOPRIGHT, 0, 0)
    end
end

function LTM_UI:GetBuildDisplayName(cardId, build)
    if type(build) == "table" and type(build.displayName) == "string" and build.displayName ~= "" then
        return build.displayName
    end

    if type(build) == "table" and type(build.name) == "string" and build.name ~= "" then
        return build.name
    end

    return tostring(cardId)
end

local function FindCardEntryById(cardEntries, cardId)
    if type(cardId) ~= "string" or cardId == "" then
        return nil
    end

    for _, entry in ipairs(cardEntries or {}) do
        if type(entry) == "table" and entry.buildId == cardId then
            return entry
        end
    end

    return nil
end

local RefreshCardLinkControls

local function SetIconButtonTexturePrefix(button, texturePrefix)
    if button == nil or type(texturePrefix) ~= "string" or texturePrefix == "" then
        return
    end

    if button.ltmTexturePrefix == texturePrefix then
        return
    end

    button.ltmTexturePrefix = texturePrefix
    button:SetNormalTexture(texturePrefix .. "_up.dds")
    button:SetMouseOverTexture(texturePrefix .. "_over.dds")
    button:SetPressedTexture(texturePrefix .. "_down.dds")
    button:SetDisabledTexture(texturePrefix .. "_disabled.dds")
end

function LTM_UI:GetCardList()
    if type(LTM_UI_DISPATCH) == "table" and type(LTM_UI_DISPATCH.GetBuildList) == "function" then
        return LTM_UI_DISPATCH:GetBuildList()
    end

    return {}
end

function LTM_UI:GetCardEntries()
    if type(LTM_UI_DISPATCH) == "table" and type(LTM_UI_DISPATCH.GetBuildEntries) == "function" then
        return LTM_UI_DISPATCH:GetBuildEntries()
    end

    return {}
end

function LTM_UI:GetBuildIdByOrdinalForSelectedPage(ordinal)
    if type(LTM_UI_DISPATCH) == "table"
        and type(LTM_UI_DISPATCH.GetBuildIdByOrdinalForSelectedPage) == "function" then
        return LTM_UI_DISPATCH:GetBuildIdByOrdinalForSelectedPage(ordinal)
    end

    return nil
end

function LTM_UI:SelectCard(cardId, suppressRightPaneRefresh)
    if type(cardId) ~= "string" or cardId == "" then
        return
    end

    if type(LTM_UI_DISPATCH) ~= "table"
        or type(LTM_UI_DISPATCH.IsBuildInSelectedPage) ~= "function"
        or LTM_UI_DISPATCH:IsBuildInSelectedPage(cardId) ~= true then
        return
    end

    self.selectedBuildId = cardId
    self.selectedCardId = cardId
    self.openActionMenuCardId = nil
    self.openPageActionMenu = false
    local selectedPageId = self:GetSelectedPageId()
    if type(selectedPageId) == "string"
        and type(LTM_UI_DISPATCH) == "table"
        and type(LTM_UI_DISPATCH.SetSelectedBuildIdForPage) == "function" then
        LTM_UI_DISPATCH:SetSelectedBuildIdForPage(selectedPageId, cardId)
    end
    self:RefreshSelectionState()

    if suppressRightPaneRefresh ~= true and self:GetRightPaneMode() == "target" then
        self:RefreshRightPanePanel()
    end
end

function LTM_UI:ToggleCardExpanded(cardId)
    if type(cardId) ~= "string" or cardId == "" then
        return
    end

    if self.expandedCardId == cardId then
        self.expandedCardId = nil
    else
        self.expandedCardId = cardId
    end

    self:SelectCard(cardId, true)
    self:RefreshCardList()
end

function LTM_UI:ToggleActionMenu(cardId)
    if type(cardId) ~= "string" or cardId == "" then
        return
    end

    if self.openActionMenuCardId == cardId then
        self.openActionMenuCardId = nil
    else
        self.openActionMenuCardId = cardId
    end
    self.openPageActionMenu = false

    self:RefreshSelectionState()
end

function LTM_UI:EnsureCardSelection(cardEntries)
    cardEntries = type(cardEntries) == "table" and cardEntries or self:GetCardEntries()
    local selectedPageId = self:GetSelectedPageId()
    local persistedSelectedBuildId = type(selectedPageId) == "string"
        and type(LTM_UI_DISPATCH) == "table"
        and type(LTM_UI_DISPATCH.GetSelectedBuildIdForPage) == "function"
        and LTM_UI_DISPATCH:GetSelectedBuildIdForPage(selectedPageId)
        or nil

    if #cardEntries == 0 then
        self.selectedCardId = nil
        self.selectedBuildId = nil
        self.expandedCardId = nil
        self.openActionMenuCardId = nil
        self.openPageActionMenu = false
        return
    end

    if type(FindCardEntryById(cardEntries, persistedSelectedBuildId)) == "table" then
        self.selectedBuildId = persistedSelectedBuildId
    end

    if type(FindCardEntryById(cardEntries, self.selectedBuildId)) ~= "table" then
        self.selectedBuildId = cardEntries[1].buildId
    end

    if self.expandedCardId ~= nil and type(FindCardEntryById(cardEntries, self.expandedCardId)) ~= "table" then
        self.expandedCardId = nil
    end

    if self.openActionMenuCardId ~= nil and type(FindCardEntryById(cardEntries, self.openActionMenuCardId)) ~= "table" then
        self.openActionMenuCardId = nil
    end

    self.selectedCardId = self.selectedBuildId
end

local function SetCardVisuals(self, cardControl, isSelected)
    if cardControl == nil then
        return
    end

    if isSelected then
        cardControl:SetCenterColor(0.14, 0.23, 0.32, 0.97)
        cardControl:SetEdgeColor(0.76, 0.86, 0.95, 1.0)
        if cardControl.titleLabel then
            cardControl.titleLabel:SetColor(1.0, 1.0, 1.0, 1.0)
        end
        if cardControl.ordinalLabel then
            cardControl.ordinalLabel:SetColor(0.86, 0.92, 1.0, 1.0)
        end
    else
        cardControl:SetCenterColor(0.08, 0.08, 0.10, 0.94)
        cardControl:SetEdgeColor(0.30, 0.32, 0.36, 1.0)
        if cardControl.titleLabel then
            cardControl.titleLabel:SetColor(0.90, 0.90, 0.94, 1.0)
        end
        if cardControl.ordinalLabel then
            cardControl.ordinalLabel:SetColor(0.72, 0.80, 0.88, 1.0)
        end
    end
end

function LTM_UI:RefreshSelectionState()
    local selectedCardId = self.selectedBuildId

    self:RefreshPageHeader()

    if type(self.cardControls) == "table" then
        for cardId, cardControl in pairs(self.cardControls) do
            SetCardVisuals(self, cardControl, cardId == selectedCardId)
            if cardControl.toggleButton then
                local isExpanded = self.expandedCardId == cardId
                cardControl.toggleButton.ltmTooltipText = GetText(isExpanded and "card.collapse" or "card.expand")
                SetIconButtonTexturePrefix(
                    cardControl.toggleButton,
                    isExpanded and "/esoui/art/worldmap/mapnav_uparrow" or "/esoui/art/buttons/scrollbox_downarrow"
                )
            end
            if cardControl.actionMenu then
                cardControl.actionMenu:SetHidden(self.openActionMenuCardId ~= cardId)
            end
            if cardControl.cardBody then
                cardControl.cardBody:SetHidden(self.expandedCardId ~= cardId)
            end
        end
    end

    self:RefreshActionMenuDismissLayer()

    if self.applyButton then
        self.applyButton:SetEnabled(selectedCardId ~= nil)
    end
    if self.partialAttributeButton then
        self.partialAttributeButton:SetEnabled(selectedCardId ~= nil)
    end
    if self.partialSkillsButton then
        self.partialSkillsButton:SetEnabled(selectedCardId ~= nil)
    end
    if self.partialEquipmentButton then
        self.partialEquipmentButton:SetEnabled(selectedCardId ~= nil)
    end
    if self.partialCpButton then
        self.partialCpButton:SetEnabled(selectedCardId ~= nil)
    end
    if type(self.RefreshForceChampionRespecControl) == "function" then
        self:RefreshForceChampionRespecControl()
    end
end

local function GetCardListViewportHeight(self)
    if self.cardListScrollContainer and type(self.cardListScrollContainer.GetHeight) == "function" then
        return self.cardListScrollContainer:GetHeight() or 0
    end

    if self.cardListSection and type(self.cardListSection.GetHeight) == "function" then
        return self.cardListSection:GetHeight() or 0
    end

    return UI_CARD_LIST_SECTION_HEIGHT
end

function LTM_UI:SetCardListScrollOffset(offsetY)
    local scrollbar = self.cardListScrollBar
    if scrollbar == nil or type(scrollbar.SetValue) ~= "function" then
        return
    end

    local maxOffset = tonumber(self.cardListMaxScroll) or 0
    if maxOffset <= 0 then
        scrollbar:SetValue(0)
        return
    end

    local clampedOffset = math.min(math.max(tonumber(offsetY) or 0, 0), maxOffset)
    scrollbar:SetValue(clampedOffset)
end

function LTM_UI:RefreshCardListScrollState(contentHeight)
    local viewportHeight = GetCardListViewportHeight(self)
    local totalHeight = math.max(tonumber(contentHeight) or 0, viewportHeight, 1)
    local maxOffset = math.max(0, totalHeight - viewportHeight)
    local hasOverflow = maxOffset > 0
    self.cardListMaxScroll = maxOffset

    self:ApplyCardListContainerLayout(self.cardListScrollBar ~= nil, totalHeight)

    if self.cardListScrollContainer and type(self.cardListScrollContainer.UpdateScrollbars) == "function" then
        self.cardListScrollContainer:UpdateScrollbars()
    end

    local scrollbar = self.cardListScrollBar
    if scrollbar ~= nil then
        if type(scrollbar.SetHidden) == "function" then
            scrollbar:SetHidden(not hasOverflow)
        end

        if type(scrollbar.GetValue) == "function" then
            self:SetCardListScrollOffset(scrollbar:GetValue() or 0)
        else
            self:SetCardListScrollOffset(0)
        end

        if not hasOverflow
            and type(ZO_VerticalScrollbarBase_OnMouseExit) == "function" then
            ZO_VerticalScrollbarBase_OnMouseExit(scrollbar)
        end
    end
end

function LTM_UI:QueueCardListScroll(cardId, scrollMode)
    if type(cardId) ~= "string" or cardId == "" then
        self.pendingCardListScroll = nil
        return
    end

    self.pendingCardListScroll = {
        cardId = cardId,
        mode = scrollMode or "visible",
    }
end

function LTM_UI:ApplyPendingCardListScroll()
    local pendingScroll = self.pendingCardListScroll
    if type(pendingScroll) ~= "table" then
        return
    end

    self.pendingCardListScroll = nil

    local layout = type(self.cardLayoutById) == "table" and self.cardLayoutById[pendingScroll.cardId] or nil
    local viewportHeight = GetCardListViewportHeight(self)
    local maxOffset = tonumber(self.cardListMaxScroll) or 0
    if type(layout) ~= "table" or viewportHeight <= 0 or maxOffset <= 0 then
        return
    end

    local topOffset = tonumber(layout.top) or 0
    local bottomOffset = tonumber(layout.bottom) or topOffset
    local cardHeight = math.max(tonumber(layout.height) or 0, 0)
    local targetOffset = nil

    if pendingScroll.mode == "center" then
        targetOffset = topOffset - math.max((viewportHeight - cardHeight) / 2, 0)
    else
        local currentOffset = 0
        if self.cardListScrollBar and type(self.cardListScrollBar.GetValue) == "function" then
            currentOffset = self.cardListScrollBar:GetValue() or 0
        end
        local visibleBottom = currentOffset + viewportHeight

        if topOffset < currentOffset then
            targetOffset = topOffset
        elseif bottomOffset > visibleBottom then
            targetOffset = bottomOffset - viewportHeight
        end
    end

    if targetOffset ~= nil then
        self:SetCardListScrollOffset(targetOffset)
    end
end

function LTM_UI:RefreshCardList(forceSnapshot)
    if not self:IsArmoryStationTabActive() then
        return
    end

    local cardEntries = self:GetCardEntries()

    self:EnsureCardSelection(cardEntries)

    self.cardControls = self.cardControls or {}
    self.cardLayoutById = {}
    local activeCardIds = {}

    if self.emptyStateControl then
        self.emptyStateControl:SetHidden(#cardEntries > 0)
    end

    local currentYOffset = 0
    for index, entry in ipairs(cardEntries) do
        local cardId = entry.buildId
        activeCardIds[cardId] = true
        local cardControl = self.cardControls[cardId]
        if cardControl == nil then
            cardControl = self:CreateCardControl(index, cardId)
            self.cardControls[cardId] = cardControl
        end

        local build = entry.build
        local summary = type(LTM_UI_DISPATCH) == "table"
            and type(LTM_UI_DISPATCH.GetCardSummary) == "function"
            and LTM_UI_DISPATCH:GetCardSummary(cardId)
            or nil

        local detailState = type(LTM_UI_DISPATCH) == "table"
            and type(LTM_UI_DISPATCH.GetCardDetailState) == "function"
            and LTM_UI_DISPATCH:GetCardDetailState(cardId)
            or nil

        local cardTop = currentYOffset
        local cardHeight = nil
        cardHeight, currentYOffset = self:PositionBuildCardInList(
            cardControl,
            currentYOffset,
            self.expandedCardId == cardId
        )

        cardControl:SetHidden(false)

        SetLabelText(
            cardControl.titleLabel,
            entry.displayName or self:GetBuildDisplayName(cardId, build)
        )
        SetLabelText(cardControl.ordinalLabel, BuildOrdinalText(entry.ordinal or index))
        self:RefreshCardRoleIcon(cardControl, summary)
        self:RefreshTransformIcons(
            cardControl.transformIcons,
            type(summary) == "table" and summary.transformEntries or nil,
            "target",
            cardId
        )
        local subclassSummaryText = detailState and detailState.subclassSummary or GetText("common.none")
        SetLabelText(cardControl.subclassValue, subclassSummaryText)
        if cardControl.subclassValue then
            cardControl.subclassValue.ltmTooltipText = ""
        end
        local outfitDisplayText = BuildOutfitDisplayText(detailState and detailState.outfitName or GetText("common.none"))
        SetLabelText(cardControl.outfitValue, outfitDisplayText)
        if cardControl.outfitValue then
            cardControl.outfitValue.ltmTooltipText = ""
        end
        self:RefreshCardPassivePolicyControl(cardControl, detailState)
        RefreshCardLinkControls(self, cardControl, detailState)
        self:RefreshCardAttributeList(cardControl, detailState)

        self:RefreshSkillBarSlots(cardControl.frontBarSlots, detailState and detailState.skillBars and detailState.skillBars.front)
        self:RefreshSkillBarSlots(cardControl.backBarSlots, detailState and detailState.skillBars and detailState.skillBars.back)

        self.cardLayoutById[cardId] = {
            top = cardTop,
            height = cardHeight,
            bottom = cardTop + cardHeight,
        }
    end

    for cardId, cardControl in pairs(self.cardControls) do
        if activeCardIds[cardId] ~= true then
            cardControl:SetHidden(true)
        end
    end

    self:RefreshCardListScrollState(math.max(currentYOffset - UI_CARD_SPACING, 0))
    self:RefreshSelectionState()

    self:ApplyPendingCardListScroll()

    self:RefreshCurrentStatePanel(forceSnapshot == true)
end

function LTM_UI:RefreshCardAttributeList(cardControl, summary)
    if cardControl == nil or type(cardControl.attributeRows) ~= "table" then
        return
    end

    local attributes = type(summary) == "table" and summary.attributes or {}

    for index, layout in ipairs(CARD_ATTRIBUTE_LAYOUTS) do
        local row = cardControl.attributeRows[index]
        if row ~= nil then
            local color = layout.color
            row.dotTexture:SetColor(color[1], color[2], color[3], color[4])
            row.nameLabel:SetColor(color[1] * 0.92, color[2] * 0.92, color[3] * 0.92, 1.0)
            row.nameLabel:SetText(GetText(layout.shortLabelKey))
            row.nameLabel:SetHidden(false)
            row.valueLabel:SetText(tostring(attributes[layout.id] or 0))
        end
    end
end

function LTM_UI:RefreshCardPassivePolicyControl(cardControl, summary)
    if cardControl == nil or cardControl.passivePolicyComboBox == nil then
        return
    end

    local cardId = type(summary) == "table" and summary.cardId or nil
    local comboBox = cardControl.passivePolicyComboBox
    local passivePolicy = LTM_BUILD_CODEC:NormalizePassivePolicy(type(summary) == "table" and summary.passivePolicy or nil)

    comboBox:SetSortsItems(false)
    comboBox:ClearItems()
    for _, option in ipairs(PASSIVE_POLICY_OPTIONS) do
        local policy = option.id
        comboBox:AddItem(comboBox:CreateItemEntry(GetText(option.textKey), function()
            if type(cardId) == "string" and cardId ~= "" then
                SaveCardPassivePolicy(cardId, policy)
            end
        end))
    end
    comboBox:SetSelectedItemText(GetPassivePolicyDisplayName(passivePolicy))

    local snapshotText = GetPassiveSnapshotDisplayText(summary)
    if cardControl.passiveSnapshotLabel ~= nil then
        SetLabelText(cardControl.passiveSnapshotLabel, snapshotText)
        cardControl.passiveSnapshotLabel.ltmTooltipText = ""
    end
    if cardControl.passivePolicyDropdown ~= nil then
        cardControl.passivePolicyDropdown.ltmTooltipText = GetPassivePolicyTooltipText()
    end
end

local function RefreshCardLinkComboBox(self, comboBox, selectedId, placeholderText, options, saveCallback, missingDisplayName)
    if comboBox == nil then
        return
    end

    selectedId = NormalizeLinkId(selectedId)
    comboBox:SetSortsItems(false)
    comboBox:ClearItems()
    comboBox:AddItem(comboBox:CreateItemEntry(placeholderText, function()
        saveCallback(nil)
    end))

    local selectedDisplayName = selectedId == nil and placeholderText or missingDisplayName
    for _, option in ipairs(options or {}) do
        local optionId = NormalizeLinkId(type(option) == "table" and option.id or nil)
        if optionId ~= nil then
            local displayName = type(option.displayName) == "string" and option.displayName ~= "" and option.displayName or optionId
            local capturedOptionId = optionId
            comboBox:AddItem(comboBox:CreateItemEntry(displayName, function()
                saveCallback(capturedOptionId)
            end))
            if selectedId == optionId then
                selectedDisplayName = displayName
            end
        end
    end

    comboBox:SetSelectedItemText(selectedDisplayName or placeholderText)
end

RefreshCardLinkControls = function(self, cardControl, summary)
    if cardControl == nil then
        return
    end

    local cardId = type(summary) == "table" and summary.cardId or nil
    if type(cardId) ~= "string" or cardId == "" then
        return
    end

    local quickSlotProfileId = NormalizeLinkId(type(summary) == "table" and summary.quickslotProfileId or nil)
    local foodCardId = NormalizeLinkId(type(summary) == "table" and summary.foodCardId or nil)

    RefreshCardLinkComboBox(
        self,
        cardControl.quickSlotLinkComboBox,
        quickSlotProfileId,
        GetText("card.link.quickslot"),
        BuildLinkComboOptions(LTM_UI_DISPATCH.GetQuickSlotLinkOptions),
        function(profileId)
            SaveCardQuickSlotLink(cardId, profileId)
        end,
        type(LTM_UI_DISPATCH) == "table"
            and type(LTM_UI_DISPATCH.GetQuickSlotProfileDisplayName) == "function"
            and LTM_UI_DISPATCH:GetQuickSlotProfileDisplayName(quickSlotProfileId)
            or BuildMissingLinkDisplayName(quickSlotProfileId, GetText("card.link.quickslot"))
    )

    RefreshCardLinkComboBox(
        self,
        cardControl.foodLinkComboBox,
        foodCardId,
        GetText("card.link.food"),
        BuildLinkComboOptions(LTM_UI_DISPATCH.GetFoodLinkOptions),
        function(cardIdToSave)
            SaveCardFoodLink(cardId, cardIdToSave)
        end,
        type(LTM_UI_DISPATCH) == "table"
            and type(LTM_UI_DISPATCH.GetFoodCardDisplayName) == "function"
            and LTM_UI_DISPATCH:GetFoodCardDisplayName(foodCardId)
            or BuildMissingLinkDisplayName(foodCardId, GetText("card.link.food"))
    )
end

function LTM_UI:RefreshCardRoleIcon(cardControl, summary)
    if cardControl == nil or cardControl.titleLabel == nil or cardControl.roleIcon == nil then
        return
    end

    local roleIconTexture = ResolveRoleIconTexture(type(summary) == "table" and summary.role or nil)
    local hasRole = type(roleIconTexture) == "string" and roleIconTexture ~= ""
    self:ApplyBuildCardHeaderLayout(cardControl, hasRole)

    if hasRole then
        cardControl.roleIcon:SetTexture(roleIconTexture)
        cardControl.roleIcon:SetHidden(false)
    else
        cardControl.roleIcon:SetHidden(true)
    end
end
