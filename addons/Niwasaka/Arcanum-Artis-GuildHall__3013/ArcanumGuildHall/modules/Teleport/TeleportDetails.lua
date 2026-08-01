local ArcanumGuildHall = _G["ArcanumGuildHall"]
local UI = ArcanumGuildHallTeleportUI
local Teleport = ArcanumGuildHall.Teleport

UI.TeleportWindow = UI.TeleportWindow or {}
UI.TeleportDetails = UI.TeleportDetails or {}

local Window = UI.TeleportWindow
local Details = UI.TeleportDetails

local FAVORITE_ADD_TOOLTIP = "TELEPORT_ADD_FAVORITE"
local FAVORITE_DEL_TOOLTIP = "TELEPORT_DEL_FAVORITE"
local FAVORITE_FILTER_TOOLTIP = "TELEPORT_SHOW_FAVORITES"

local function getText(value, fallback)
    if value == nil or value == "" then
        return fallback or ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_VALUE_EMPTY")
    end

    return value
end

local function getCategoryLabel(details)
    if not details then
        return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_VALUE_EMPTY")
    end

    return Teleport.GetCategoryDisplayName(details.category)
end

local function setPairHidden(labelControl, valueControl, hidden)
    labelControl:SetHidden(hidden)
    valueControl:SetHidden(hidden)
end

local function getDetailsAnchor()
    if not ArcanumGuildHallTeleportWindow_FilterGrid:IsHidden() then
        return ArcanumGuildHallTeleportWindow_FilterGrid, 10
    end

    if not ArcanumGuildHallTeleportWindow_FilterCategoryLabel:IsHidden() then
        return ArcanumGuildHallTeleportWindow_FilterCategoryLabel, 10
    end

    return ArcanumGuildHallTeleportWindow_DetailsSubtitle, 12
end

local function updateFavoriteBackdrop(button, active)
    if button.isFilterButton and active then
        button.activeBg:SetCenterColor(0.34, 0.48, 0.82, 0.34)
        button.activeBg:SetEdgeColor(0.90, 0.96, 1.00, 0.46)
    else
        button.activeBg:SetCenterColor(0.24, 0.38, 0.62, 0.24)
        button.activeBg:SetEdgeColor(0.78, 0.89, 1.00, 0.28)
    end
end

local function setFavoriteButtonState(button, active, enabled)
    updateFavoriteBackdrop(button, active)

    if button.isFilterButton then
        button:SetAlpha(enabled and 1 or 0.60)

        if enabled then
            button.icon:SetAlpha(active and 1.0 or 0.52)
        else
            button.icon:SetAlpha(0.34)
        end
    else
        button:SetAlpha(enabled and 1 or 0.55)

        if enabled then
            button.icon:SetAlpha(active and 1.0 or 0.38)
        else
            button.icon:SetAlpha(0.28)
        end
    end

    button.icon:SetHidden(false)
    button.activeBg:SetHidden(not active)
    button.hoverBg:SetHidden(true)
end

local function initSingleFavoriteButton(button, tooltipKey, onClick, iconTexture)
    button:SetMouseEnabled(true)

    button.normalBg = WINDOW_MANAGER:CreateControl(nil, button, CT_BACKDROP)
    button.normalBg:SetAnchorFill()
    button.normalBg:SetCenterColor(0.08, 0.08, 0.09, 0.18)
    button.normalBg:SetEdgeColor(0.42, 0.42, 0.46, 0.12)

    button.activeBg = WINDOW_MANAGER:CreateControl(nil, button, CT_BACKDROP)
    button.activeBg:SetAnchorFill()
    button.activeBg:SetCenterColor(0.24, 0.38, 0.62, 0.24)
    button.activeBg:SetEdgeColor(0.78, 0.89, 1.00, 0.28)
    button.activeBg:SetHidden(true)

    button.hoverBg = WINDOW_MANAGER:CreateControl(nil, button, CT_BACKDROP)
    button.hoverBg:SetAnchorFill()
    button.hoverBg:SetCenterColor(1.00, 1.00, 1.00, 0.03)
    button.hoverBg:SetEdgeColor(1.00, 1.00, 1.00, 0.05)
    button.hoverBg:SetHidden(true)

    button.icon = WINDOW_MANAGER:CreateControl(nil, button, CT_TEXTURE)
    button.icon:SetDimensions(18, 18)
    button.icon:SetAnchor(CENTER, button, CENTER, 0, 0)
    button.icon:SetTexture(iconTexture or ArcanumGuildHallMediaRes.IconPortFavorite)

    button.tooltipKey = tooltipKey

    button:SetHandler("OnMouseEnter", function(selfControl)
        if selfControl:IsMouseEnabled() then
            selfControl.hoverBg:SetHidden(false)
        end

        ZO_Tooltips_ShowTextTooltip(
                selfControl,
                BOTTOM,
                ArcanumGuildHall.GetDefaultLocaleString(selfControl.tooltipKey)
        )
    end)

    button:SetHandler("OnMouseExit", function(selfControl)
        ZO_Tooltips_HideTextTooltip()
        selfControl.hoverBg:SetHidden(true)
    end)

    button:SetHandler("OnClicked", onClick)
end

local function setViewMode(self)
    if self.activeTab == "network" then
        ArcanumGuildHallTeleportWindow_DetailsZoneLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_TARGET"))
        ArcanumGuildHallTeleportWindow_DetailsAccountLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_PLAYER"))
        ArcanumGuildHallTeleportWindow_DetailsSourceLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_SOURCE"))

        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsZoneLabel, ArcanumGuildHallTeleportWindow_DetailsZoneValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsAccountLabel, ArcanumGuildHallTeleportWindow_DetailsAccountValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsSourceLabel, ArcanumGuildHallTeleportWindow_DetailsSourceValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsCostLabel, ArcanumGuildHallTeleportWindow_DetailsCostValue, true)
        return
    end

    if self.activeTab == "wayshrines" then
        ArcanumGuildHallTeleportWindow_DetailsZoneLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_LOCATION"))
        ArcanumGuildHallTeleportWindow_DetailsAccountLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_TYPE"))
        ArcanumGuildHallTeleportWindow_DetailsSourceLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_STATUS"))
        ArcanumGuildHallTeleportWindow_DetailsCostLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_COST"))

        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsZoneLabel, ArcanumGuildHallTeleportWindow_DetailsZoneValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsAccountLabel, ArcanumGuildHallTeleportWindow_DetailsAccountValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsSourceLabel, ArcanumGuildHallTeleportWindow_DetailsSourceValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsCostLabel, ArcanumGuildHallTeleportWindow_DetailsCostValue, false)
        return
    end

    if self.activeTab == "unknown" then
        ArcanumGuildHallTeleportWindow_DetailsZoneLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_LOCATION"))
        ArcanumGuildHallTeleportWindow_DetailsAccountLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_TYPE"))
        ArcanumGuildHallTeleportWindow_DetailsSourceLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_STATUS"))

        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsZoneLabel, ArcanumGuildHallTeleportWindow_DetailsZoneValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsAccountLabel, ArcanumGuildHallTeleportWindow_DetailsAccountValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsSourceLabel, ArcanumGuildHallTeleportWindow_DetailsSourceValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsCostLabel, ArcanumGuildHallTeleportWindow_DetailsCostValue, true)
        return
    end

    if self.activeTab == "houses" then
        ArcanumGuildHallTeleportWindow_DetailsZoneLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_HOUSE"))
        ArcanumGuildHallTeleportWindow_DetailsAccountLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_TYPE"))
        ArcanumGuildHallTeleportWindow_DetailsSourceLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_STATUS"))

        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsZoneLabel, ArcanumGuildHallTeleportWindow_DetailsZoneValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsAccountLabel, ArcanumGuildHallTeleportWindow_DetailsAccountValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsSourceLabel, ArcanumGuildHallTeleportWindow_DetailsSourceValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsCostLabel, ArcanumGuildHallTeleportWindow_DetailsCostValue, true)
        return
    end

    if self.activeTab == "guildhouses" then
        ArcanumGuildHallTeleportWindow_DetailsZoneLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_TARGET"))
        ArcanumGuildHallTeleportWindow_DetailsAccountLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_OWNER"))
        ArcanumGuildHallTeleportWindow_DetailsSourceLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_SOURCE"))
        ArcanumGuildHallTeleportWindow_DetailsCostLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_TYPE"))

        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsZoneLabel, ArcanumGuildHallTeleportWindow_DetailsZoneValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsAccountLabel, ArcanumGuildHallTeleportWindow_DetailsAccountValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsSourceLabel, ArcanumGuildHallTeleportWindow_DetailsSourceValue, false)
        setPairHidden(ArcanumGuildHallTeleportWindow_DetailsCostLabel, ArcanumGuildHallTeleportWindow_DetailsCostValue, false)
        return
    end

    ArcanumGuildHallTeleportWindow_DetailsZoneLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LABEL_TARGET"))

    setPairHidden(ArcanumGuildHallTeleportWindow_DetailsZoneLabel, ArcanumGuildHallTeleportWindow_DetailsZoneValue, false)
    setPairHidden(ArcanumGuildHallTeleportWindow_DetailsAccountLabel, ArcanumGuildHallTeleportWindow_DetailsAccountValue, true)
    setPairHidden(ArcanumGuildHallTeleportWindow_DetailsSourceLabel, ArcanumGuildHallTeleportWindow_DetailsSourceValue, true)
    setPairHidden(ArcanumGuildHallTeleportWindow_DetailsCostLabel, ArcanumGuildHallTeleportWindow_DetailsCostValue, true)
end

function Details.InitHintBox()
    if UI.hintBox and UI.hintLabel then
        return UI.hintBox, UI.hintLabel
    end

    local style = Window.STYLE.hint

    local hintBox = WINDOW_MANAGER:CreateControl(
            "ArcanumGuildHallTeleportWindowHintBox",
            ArcanumGuildHallTeleportWindow,
            CT_BACKDROP
    )
    hintBox:SetDimensions(10, style.height)
    hintBox:SetCenterColor(style.bgCenter[1], style.bgCenter[2], style.bgCenter[3], style.bgCenter[4])
    hintBox:SetEdgeColor(style.bgEdge[1], style.bgEdge[2], style.bgEdge[3], style.bgEdge[4])
    hintBox:SetHidden(true)

    local hintLabel = WINDOW_MANAGER:CreateControl(
            "ArcanumGuildHallTeleportWindowHintLabel",
            hintBox,
            CT_LABEL
    )
    hintLabel:ClearAnchors()
    hintLabel:SetAnchor(TOPLEFT, hintBox, TOPLEFT, 0, -5)
    hintLabel:SetAnchor(BOTTOMRIGHT, hintBox, BOTTOMRIGHT, -8, -3)
    hintLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    hintLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    hintLabel:SetFont(Window.FONT_HINT)
    hintLabel:SetColor(style.text[1], style.text[2], style.text[3], style.text[4])

    UI.hintBox = hintBox
    UI.hintLabel = hintLabel

    return hintBox, hintLabel
end

function Details.InitFavoriteButtons()
    if UI.favoriteToggleButton and UI.favoriteFilterButton then
        return
    end

    local parent = ArcanumGuildHallTeleportWindow_DetailsBg
    if not parent then
        return
    end

    local favoriteFilterButton = WINDOW_MANAGER:CreateControl(
            "ArcanumGuildHallTeleportWindowFavoriteFilterButton",
            parent,
            CT_BUTTON
    )
    favoriteFilterButton:SetDimensions(24, 24)
    favoriteFilterButton:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -10, 9)
    favoriteFilterButton.isFilterButton = true

    initSingleFavoriteButton(
            favoriteFilterButton,
            FAVORITE_FILTER_TOOLTIP,
            function()
                UI.filters.favoriteOnly = not UI.filters.favoriteOnly

                if ArcanumGuildHall.db then
                    ArcanumGuildHall.db.lastTeleportFavoriteOnly = UI.filters.favoriteOnly
                end

                UI.TeleportList.RefreshList(UI)
                Details.UpdateFavorites(UI)
            end,
            ArcanumGuildHallMediaRes.IconPortFavoriteAll
    )

    local favoriteToggleButton = WINDOW_MANAGER:CreateControl(
            "ArcanumGuildHallTeleportWindowFavoriteToggleButton",
            parent,
            CT_BUTTON
    )
    favoriteToggleButton:SetDimensions(24, 24)
    favoriteToggleButton:SetAnchor(RIGHT, favoriteFilterButton, LEFT, -4, 0)
    favoriteToggleButton.isFilterButton = false

    initSingleFavoriteButton(
            favoriteToggleButton,
            FAVORITE_ADD_TOOLTIP,
            function()
                local entry = UI.selectedData
                if not entry or entry.entryType ~= "action" then
                    return
                end

                Teleport.ToggleFavorite(entry)
                UI.TeleportList.RefreshList(UI)
                Details.UpdateFavorites(UI)
            end,
            ArcanumGuildHallMediaRes.IconPortFavorite
    )

    UI.favoriteFilterButton = favoriteFilterButton
    UI.favoriteToggleButton = favoriteToggleButton
end

function Details.UpdateFavorites(self)
    local showButtons = Window.SupportsFavorites()

    UI.favoriteToggleButton:SetHidden(not showButtons)
    UI.favoriteFilterButton:SetHidden(not showButtons)

    if not showButtons then
        return
    end

    local selectedEntry = self.selectedData
    local canToggleFavorite = selectedEntry and Teleport.CanFavoriteEntry(selectedEntry) or false
    local isFavorite = canToggleFavorite and Teleport.IsFavorite(selectedEntry) or false
    local favoriteFilterActive = self.filters.favoriteOnly

    setFavoriteButtonState(UI.favoriteToggleButton, isFavorite, canToggleFavorite)
    setFavoriteButtonState(UI.favoriteFilterButton, favoriteFilterActive, true)

    UI.favoriteToggleButton.tooltipKey = isFavorite and FAVORITE_DEL_TOOLTIP or FAVORITE_ADD_TOOLTIP
    UI.favoriteFilterButton.tooltipKey = FAVORITE_FILTER_TOOLTIP
end

function Details.RefreshHint()
    local hintBox, hintLabel = Details.InitHintBox()
    local loadingLabel = ArcanumGuildHallTeleportWindow_LoadingLabel
    local detailsBg = ArcanumGuildHallTeleportWindow_DetailsBg

    hintBox:ClearAnchors()
    hintBox:SetAnchor(TOPLEFT, loadingLabel, BOTTOMLEFT, 0, 4)
    hintBox:SetAnchor(TOPRIGHT, detailsBg, BOTTOMRIGHT, 0, 34)
    hintBox:SetHeight(Window.STYLE.hint.height)

    hintLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_HINT_LIST_ACTION"))
    hintBox:SetHidden(UI.activeTab == nil)
end

function Details.ApplyFonts()
    ArcanumGuildHallTeleportWindow_DetailsTitle:SetFont(Window.FONT_TITLE)
    ArcanumGuildHallTeleportWindow_DetailsSubtitle:SetFont(Window.FONT_SUBTITLE)
    ArcanumGuildHallTeleportWindow_FilterCategoryLabel:SetFont(Window.FONT_SECTION)

    ArcanumGuildHallTeleportWindow_DetailsZoneLabel:SetFont(Window.FONT_LABEL)
    ArcanumGuildHallTeleportWindow_DetailsAccountLabel:SetFont(Window.FONT_LABEL)
    ArcanumGuildHallTeleportWindow_DetailsSourceLabel:SetFont(Window.FONT_LABEL)
    ArcanumGuildHallTeleportWindow_DetailsCostLabel:SetFont(Window.FONT_LABEL)

    ArcanumGuildHallTeleportWindow_DetailsZoneValue:SetFont(Window.FONT_PRIMARY)
    ArcanumGuildHallTeleportWindow_DetailsAccountValue:SetFont(Window.FONT_VALUE)
    ArcanumGuildHallTeleportWindow_DetailsSourceValue:SetFont(Window.FONT_VALUE)
    ArcanumGuildHallTeleportWindow_DetailsCostValue:SetFont(Window.FONT_VALUE)
    ArcanumGuildHallTeleportWindow_LoadingLabel:SetFont(Window.FONT_LOADING)

    if UI.hintLabel then
        UI.hintLabel:SetFont(Window.FONT_HINT)
    end

    Window.GetFilter("all").label:SetFont(Window.FONT_FILTER)
    Window.GetFilter("zone").label:SetFont(Window.FONT_FILTER)
    Window.GetFilter("dungeon").label:SetFont(Window.FONT_FILTER)
    Window.GetFilter("trial").label:SetFont(Window.FONT_FILTER)
    Window.GetFilter("arena").label:SetFont(Window.FONT_FILTER)

    Window.CenterFilterText("all")
    Window.CenterFilterText("zone")
    Window.CenterFilterText("dungeon")
    Window.CenterFilterText("trial")
    Window.CenterFilterText("arena")
end

function Details.Clear(self)
    setViewMode(self)

    ArcanumGuildHallTeleportWindow_DetailsZoneValue:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_VALUE_EMPTY"))
    ArcanumGuildHallTeleportWindow_DetailsAccountValue:SetText("")
    ArcanumGuildHallTeleportWindow_DetailsSourceValue:SetText("")
    ArcanumGuildHallTeleportWindow_DetailsCostValue:SetText("")

    Details.RefreshDetails(self)
    Details.UpdateFavorites(self)
end

function Details.RefreshDetails(self)
    local detailsBg = ArcanumGuildHallTeleportWindow_DetailsBg
    local primaryBg = ArcanumGuildHallTeleportWindow_DetailsPrimaryBg
    local zoneLabel = ArcanumGuildHallTeleportWindow_DetailsZoneLabel
    local zoneValue = ArcanumGuildHallTeleportWindow_DetailsZoneValue
    local accountLabel = ArcanumGuildHallTeleportWindow_DetailsAccountLabel
    local accountValue = ArcanumGuildHallTeleportWindow_DetailsAccountValue
    local sourceLabel = ArcanumGuildHallTeleportWindow_DetailsSourceLabel
    local sourceValue = ArcanumGuildHallTeleportWindow_DetailsSourceValue
    local costLabel = ArcanumGuildHallTeleportWindow_DetailsCostLabel
    local costValue = ArcanumGuildHallTeleportWindow_DetailsCostValue
    local loadingLabel = ArcanumGuildHallTeleportWindow_LoadingLabel

    local anchorControl, yOffset = getDetailsAnchor()

    primaryBg:ClearAnchors()
    primaryBg:SetAnchor(TOPLEFT, anchorControl, BOTTOMLEFT, 0, yOffset)
    primaryBg:SetHidden(zoneLabel:IsHidden() or zoneValue:IsHidden())

    zoneLabel:ClearAnchors()
    zoneLabel:SetAnchor(TOPLEFT, primaryBg, TOPLEFT, 10, 8)

    zoneValue:ClearAnchors()
    zoneValue:SetAnchor(TOPLEFT, zoneLabel, BOTTOMLEFT, 0, 4)

    local showAccount = not accountLabel:IsHidden() and not accountValue:IsHidden()
    local showSource = not sourceLabel:IsHidden() and not sourceValue:IsHidden()
    local showCost = not costLabel:IsHidden() and not costValue:IsHidden()

    if showAccount then
        accountLabel:ClearAnchors()
        accountLabel:SetAnchor(TOPLEFT, primaryBg, BOTTOMLEFT, 0, 10)

        accountValue:ClearAnchors()
        accountValue:SetAnchor(TOPLEFT, accountLabel, BOTTOMLEFT, 0, 2)
    end

    if showSource then
        sourceLabel:ClearAnchors()

        if showAccount then
            sourceLabel:SetAnchor(TOPLEFT, primaryBg, BOTTOMLEFT, 150, 10)
        else
            sourceLabel:SetAnchor(TOPLEFT, primaryBg, BOTTOMLEFT, 0, 10)
        end

        sourceValue:ClearAnchors()
        sourceValue:SetAnchor(TOPLEFT, sourceLabel, BOTTOMLEFT, 0, 2)
    end

    if showCost then
        costLabel:ClearAnchors()

        if showAccount then
            costLabel:SetAnchor(TOPLEFT, accountValue, BOTTOMLEFT, 0, 10)
        elseif showSource then
            costLabel:SetAnchor(TOPLEFT, sourceValue, BOTTOMLEFT, 0, 10)
        else
            costLabel:SetAnchor(TOPLEFT, primaryBg, BOTTOMLEFT, 0, 10)
        end

        costValue:ClearAnchors()
        costValue:SetAnchor(TOPLEFT, costLabel, BOTTOMLEFT, 0, 2)
    end

    loadingLabel:ClearAnchors()
    loadingLabel:SetAnchor(TOPLEFT, detailsBg, BOTTOMLEFT, 0, 8)
end

function Details.UpdateView(self)
    local entry = self.selectedData
    local details = entry and entry.details or nil

    setViewMode(self)

    if not entry or entry.entryType ~= "action" or not details then
        Details.Clear(self)
        return
    end

    if self.activeTab == "network" then
        ArcanumGuildHallTeleportWindow_DetailsZoneValue:SetText(getText(details.target or entry.text))
        ArcanumGuildHallTeleportWindow_DetailsAccountValue:SetText(getText(details.displayName, ""))
        ArcanumGuildHallTeleportWindow_DetailsSourceValue:SetText(getText(details.source, ""))
        ArcanumGuildHallTeleportWindow_DetailsCostValue:SetText("")

    elseif self.activeTab == "wayshrines" then
        local costText = getText(details.cost, "")
        if details.nodeId and details.nodeId > 0 then
            costText = Teleport.GetCostText(details.nodeId)
        end

        ArcanumGuildHallTeleportWindow_DetailsZoneValue:SetText(getText(details.target or entry.text))
        ArcanumGuildHallTeleportWindow_DetailsAccountValue:SetText(getCategoryLabel(details))
        ArcanumGuildHallTeleportWindow_DetailsSourceValue:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_VALUE_KNOWN"))
        ArcanumGuildHallTeleportWindow_DetailsCostValue:SetText(costText)

    elseif self.activeTab == "unknown" then
        ArcanumGuildHallTeleportWindow_DetailsZoneValue:SetText(getText(details.target or entry.text))
        ArcanumGuildHallTeleportWindow_DetailsAccountValue:SetText(getCategoryLabel(details))
        ArcanumGuildHallTeleportWindow_DetailsSourceValue:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_VALUE_UNDISCOVERED"))
        ArcanumGuildHallTeleportWindow_DetailsCostValue:SetText("")

    elseif self.activeTab == "houses" then
        ArcanumGuildHallTeleportWindow_DetailsZoneValue:SetText(getText(details.target or entry.text))
        ArcanumGuildHallTeleportWindow_DetailsAccountValue:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_VALUE_HOUSE"))

        if details.isOwnedHouse == false then
            ArcanumGuildHallTeleportWindow_DetailsSourceValue:SetText(
                    ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_VALUE_UNOWNED")
            )
        else
            ArcanumGuildHallTeleportWindow_DetailsSourceValue:SetText(
                    ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_VALUE_OWNED")
            )
        end

        ArcanumGuildHallTeleportWindow_DetailsCostValue:SetText("")

    elseif self.activeTab == "guildhouses" then
        ArcanumGuildHallTeleportWindow_DetailsZoneValue:SetText(getText(details.target or entry.text))
        ArcanumGuildHallTeleportWindow_DetailsAccountValue:SetText(getText(details.zone, ""))
        ArcanumGuildHallTeleportWindow_DetailsSourceValue:SetText(getText(details.source, ""))
        ArcanumGuildHallTeleportWindow_DetailsCostValue:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_VALUE_GUILD_HOUSE"))

    else
        ArcanumGuildHallTeleportWindow_DetailsZoneValue:SetText(getText(details.target or entry.text))
        ArcanumGuildHallTeleportWindow_DetailsAccountValue:SetText("")
        ArcanumGuildHallTeleportWindow_DetailsSourceValue:SetText("")
        ArcanumGuildHallTeleportWindow_DetailsCostValue:SetText("")
    end

    Details.RefreshDetails(self)
    Details.UpdateFavorites(self)
end

function Details.UpdateLoading(self)
    local loadingLabel = ArcanumGuildHallTeleportWindow_LoadingLabel
    local showLoading = self.activeTab == "network" and UI.cache.playerBuildState ~= nil

    loadingLabel:SetHidden(not showLoading)

    if showLoading then
        loadingLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LOADING_PLAYERS"))
    else
        loadingLabel:SetText("")
    end

    Details.RefreshHint()
    Details.RefreshDetails(self)
end

function Details.Update(self, entry)
    self.selectedData = entry
    Details.UpdateView(self)
end