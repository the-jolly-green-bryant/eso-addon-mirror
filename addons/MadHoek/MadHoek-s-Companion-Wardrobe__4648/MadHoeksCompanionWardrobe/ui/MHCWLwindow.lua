-- ============================================================================
-- Companion Wardrobe
-- Main Loadout Window
--
-- Responsibilities:
-- - Create and refresh the main Companion Wardrobe window.
-- - Display paged loadout rows and row actions.
-- - Manage filtering, sorting, warnings, and active loadout display.
-- - Open related windows such as inspect, import, export, and rename.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

local maxLoadoutWidth = 245 - 75 - 36

function MHCWL.CreateWindow()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("MHCWLWindow")
    MHCWL.window = window

    window:SetDimensions(400, 1)
    local windowSettings = MHCWL.saved.settings.window

    if windowSettings.left and windowSettings.top then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, windowSettings.left, windowSettings.top)
    else
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    window:SetMouseEnabled(true)
    window:SetHandler("OnMouseDown", function()
        if MHCWL.dropdownIgnoreMouseUntil
        and GetFrameTimeMilliseconds() < MHCWL.dropdownIgnoreMouseUntil then
            return
        end

        MHCWL.CloseDropdowns()
    end)

    window:SetMovable(MHCWL.saved.settings.window.unlocked)
    window:SetHandler("OnMoveStop", function(self)
        MHCWL.saved.settings.window.left = self:GetLeft()
        MHCWL.saved.settings.window.top = self:GetTop()
        MHCWL.Debug("Saved window position.")
    end)

    window.RefreshMoveState = function()
        local unlocked = MHCWL.saved.settings.window.unlocked
        window:SetMovable(unlocked)

        if window.header then
            if unlocked then
                window.header:SetCenterColor(unpack(MHCWL.UI_COLORS.windowUnlockedHeaderCenter))
                window.header:SetEdgeColor(unpack(MHCWL.UI_COLORS.windowUnlockedHeaderEdge))
            else
                MHCWL.StylePanelBackdrop(window.header)
            end
        end
    end

    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControlFromVirtual("MHCWLWindowBG", window, "ZO_DefaultBackdrop")
    bg:SetAnchorFill(window)
    bg:SetAlpha(0.9)

    local headerHeight = 42
    local header = MHCWL.CreateHeader(window, 397, headerHeight)
    window.header = header
    header:SetMouseEnabled(true)

    window:SetHandler("OnMouseEnter", function()
        if MHCWL.saved.settings.window.unlocked then
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PAN or 12)
        end
    end)

    window:SetHandler("OnMouseExit", function()
        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DEFAULT_CURSOR or 0)
    end)

    local logo = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
    logo:SetDimensions(25, 25)
    logo:SetAnchor(TOPLEFT, window, TOPLEFT, 14, 7)
    logo:SetTexture(MHCWL.TEXTURES.logo)

    local title = WINDOW_MANAGER:CreateControl("MHCWLWindowTitle", window, CT_LABEL)
    title:SetFont(MHCWL.FONTS.header)
    title:SetAnchor(LEFT, logo, RIGHT, 6, 1)
    title:SetText(GetString(MHCWL_WINDOW_MAIN_TITLE))

    local close = MHCWL.CreateIconButton(
        window,
        0,
        0,
        20,
        MHCWL.BUTTONS.close,
        function()
            return MHCWL.GetTutorialTooltip(
                MHCWL_TOOLTIP_CLOSE,
                MHCWL_TOOLTIP_CLOSE_TUTORIAL
            )
        end,
        function()
            MHCWL.CloseDropdowns()
            window:SetHidden(true)
        end,
        MHCWL.ICON_BUTTON_COLORS
    )

    close:ClearAnchors()
    close:SetAnchor(TOPRIGHT, window, TOPRIGHT, -15, 15)

    local settings = MHCWL.CreateIconButton(
        window,
        0,
        0,
        30,
        MHCWL.BUTTONS.settings,
        function()
            return MHCWL.GetTutorialTooltip(
                MHCWL_TOOLTIP_SETTINGS,
                MHCWL_TOOLTIP_SETTINGS_TUTORIAL
            )
        end,
        function()
            MHCWL.ToggleSettingsDropdown()
        end,
        MHCWL.ICON_BUTTON_COLORS
    )

    settings:ClearAnchors()
    settings:SetAnchor(TOPRIGHT, window, TOPRIGHT, -40, 8)

    local sort = MHCWL.CreateIconButton(
        window,
        0,
        0,
        28,
        MHCWL.BUTTONS.sort,
        function()
            local mode = MHCWL.GetCurrentLoadoutSortMode()

            if MHCWL.AreTutorialTooltipsEnabled() then
                return GetString(MHCWL_TOOLTIP_SORT_TUTORIAL)
                    .. "\n\n"
                    .. GetString(MHCWL_TOOLTIP_SORT_CURRENT_MODE)
                    .. " "
                    .. MHCWL.GetLoadoutSortModeLabel(mode)
                    .. "\n\n"
                    .. GetString(MHCWL_TOOLTIP_SORT_CHANGE_TUTORIAL)
            end

            return GetString(MHCWL_SORTING_PREFIX)
                .. MHCWL.GetLoadoutSortModeLabel(mode)
        end,
        function()
            MHCWL.CycleLoadoutSortMode()
        end,
        MHCWL.ICON_BUTTON_COLORS
    )

    sort:ClearAnchors()
    sort:SetAnchor(TOPRIGHT, window, TOPRIGHT, -82, 9)
    window.sortButton = sort

    local showNormal = MHCWL.CreateIconButton(
        window,
        0,
        0,
        24,
        MHCWL.BUTTONS.loadoutFilterNormal,
        function()
            if not MHCWL.AreTooltipsEnabled() then
                return ""
            end

            local enabled = MHCWL.saved.settings.showNormalLoadouts ~= false

            if MHCWL.AreTutorialTooltipsEnabled() then
                return enabled
                    and GetString(MHCWL_TOOLTIP_HIDE_NORMAL_TUTORIAL)
                        .. "\n\n"
                        .. GetString(MHCWL_TOOLTIP_NORMAL_FILTER_TUTORIAL)
                    or GetString(MHCWL_TOOLTIP_SHOW_NORMAL_TUTORIAL)
                        .. "\n\n"
                        .. GetString(MHCWL_TOOLTIP_NORMAL_FILTER_TUTORIAL)
            end

            return enabled
                and GetString(MHCWL_TOOLTIP_HIDE_NORMAL_LOADOUTS)
                or GetString(MHCWL_TOOLTIP_SHOW_NORMAL_LOADOUTS)
        end,
        function()
            local showFavorites = MHCWL.saved.settings.showFavoriteLoadouts ~= false
            local showNormal = MHCWL.saved.settings.showNormalLoadouts ~= false

            if showNormal and not showFavorites then
                MHCWL.saved.settings.showNormalLoadouts = false
                MHCWL.saved.settings.showFavoriteLoadouts = true
            else
                MHCWL.saved.settings.showNormalLoadouts = not showNormal
            end

            MHCWL.CloseDropdowns()
            MHCWL.RebuildWindowContent()
        end,
        function()
            local enabled = MHCWL.saved.settings.showNormalLoadouts ~= false

            return {
                normal = enabled and MHCWL.UI_COLORS.filterEnabled or MHCWL.UI_COLORS.filterDisabled,
                over = MHCWL.FILTER_BUTTON_COLORS.over,
                down = MHCWL.FILTER_BUTTON_COLORS.down,
            }
        end
    )

    local showFavorites = MHCWL.CreateIconButton(
        window,
        0,
        -6,
        35,
        MHCWL.BUTTONS.favorite,
        function()
            if not MHCWL.AreTooltipsEnabled() then
                return ""
            end
            
            local enabled = MHCWL.saved.settings.showFavoriteLoadouts ~= false

            if MHCWL.AreTutorialTooltipsEnabled() then
                return enabled
                    and GetString(MHCWL_TOOLTIP_HIDE_FAVORITES_TUTORIAL)
                        .. "\n\n"
                        .. GetString(MHCWL_TOOLTIP_FAVORITES_FILTER_TUTORIAL)
                    or GetString(MHCWL_TOOLTIP_SHOW_FAVORITES_TUTORIAL)
                        .. "\n\n"
                        .. GetString(MHCWL_TOOLTIP_FAVORITES_FILTER_TUTORIAL)
            end

            return enabled
                and GetString(MHCWL_TOOLTIP_HIDE_FAVORITE_LOADOUTS)
                or GetString(MHCWL_TOOLTIP_SHOW_FAVORITE_LOADOUTS)
        end,
        function()
            local showFavorites = MHCWL.saved.settings.showFavoriteLoadouts ~= false
            local showNormal = MHCWL.saved.settings.showNormalLoadouts ~= false

            if showFavorites and not showNormal then
                MHCWL.saved.settings.showFavoriteLoadouts = false
                MHCWL.saved.settings.showNormalLoadouts = true
            else
                MHCWL.saved.settings.showFavoriteLoadouts = not showFavorites
            end

            MHCWL.CloseDropdowns()
            MHCWL.RebuildWindowContent()
        end,
        function()
            local enabled = MHCWL.saved.settings.showFavoriteLoadouts ~= false

            return {
                normal = enabled and MHCWL.UI_COLORS.filterEnabled or MHCWL.UI_COLORS.filterDisabled,
                over = MHCWL.FILTER_BUTTON_COLORS.over,
                down = MHCWL.FILTER_BUTTON_COLORS.down,
            }
        end
    )

    showNormal:ClearAnchors()
    showNormal:SetAnchor(TOPRIGHT, settings, TOPLEFT, -40, 1)
    window.showNormalButton = showNormal

    showFavorites:ClearAnchors()
    showFavorites:SetAnchor(TOPRIGHT, showNormal, TOPLEFT, 0, -6)
    window.showFavoritesButton = showFavorites

    window:SetHeight(85 + (MHCWL.LOADOUTS_PER_PAGE * 42) + 42 + 24)

    MHCWL.CreateLoadoutRows(window)
    MHCWL.CreatePageFooter(window)
    window.RefreshMoveState()
    MHCWL.RefreshWindow()
end

function MHCWL.ToggleWindow()
    if not MHCWL.window then
        MHCWL.CreateWindow()
    end

    MHCWL.RefreshWindow()
    MHCWL.RefreshPageFooter()
    MHCWL.window:SetHidden(not MHCWL.window:IsHidden())
end

function MHCWL.ClearLoadoutRows()
    if MHCWL.loadoutRows then
        for _, row in pairs(MHCWL.loadoutRows) do
            if row then
                if row.activeHighlight then row.activeHighlight:SetHidden(true) end
                if row.favorite then row.favorite:SetHidden(true) end
                if row.lock then row.lock:SetHidden(true) end
                if row.warning then row.warning:SetHidden(true) end
                if row.loadout then row.loadout:SetHidden(true) end
                if row.save then row.save:SetHidden(true) end
                if row.rename then row.rename:SetHidden(true) end
                if row.inspect then row.inspect:SetHidden(true) end
                if row.delete then row.delete:SetHidden(true) end
            end
        end
    end

    if MHCWL.addLoadoutButton then
        MHCWL.addLoadoutButton:SetHidden(true)
    end

    MHCWL.loadoutRows = {}
    MHCWL.addLoadoutButton = nil
end

function MHCWL.RebuildWindowContent()
    if not MHCWL.window then return end

    MHCWL.ClearLoadoutRows()

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return end

    MHCWL.EnsureCompanionSetups(companionData)

    MHCWL.CreateLoadoutRows(MHCWL.window)
    MHCWL.RefreshPageFooter()
    MHCWL.RefreshWindow()
end

function MHCWL.CreateLoadoutRows(parent)
    MHCWL.loadoutRows = {}

    local iconButtonSize = 28
    local favoriteX = 9
    local lockX = 43
    local warningX = 65
    local loadoutX = 75
    local saveX = 245
    local renameX = 280
    local inspectX = 315
    local deleteX = 355

    local addButtonSize = 25
    local addGapFromLastRow = 8

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return end
    MHCWL.EnsureCompanionSetups(companionData)

    local setupCount, totalPages, activePage, visibleIndexes = MHCWL.GetPageInfo(companionData)

    local startIndex = ((activePage - 1) * MHCWL.LOADOUTS_PER_PAGE) + 1
    local endIndex = math.min(startIndex + MHCWL.LOADOUTS_PER_PAGE - 1, setupCount)

    for visibleSlot = startIndex, endIndex do
        local i = visibleIndexes[visibleSlot]

        if not i then
            break
        end

        local row = {}
        local visibleIndex = visibleSlot - startIndex + 1
        local rowY = 65 + ((visibleIndex - 1) * 42)

        local setup = companionData.setups[i]
        local lockIcons = setup.locked and MHCWL.BUTTONS.locked or MHCWL.BUTTONS.unlocked
        local lockTooltip = setup.locked and MHCWL.GetTutorialTooltip(MHCWL_BUTTON_UNLOCK, MHCWL_BUTTON_UNLOCK_TUTORIAL)
            or MHCWL.GetTutorialTooltip(MHCWL_BUTTON_LOCK, MHCWL_BUTTON_LOCK_TUTORIAL)

        row.favorite = MHCWL.CreateIconButton(parent, favoriteX, rowY - 6, iconButtonSize * 1.2, MHCWL.BUTTONS.favorite,
            setup.isFavorite and MHCWL.GetTutorialTooltip(MHCWL_BUTTON_UNFAVORITE, MHCWL_BUTTON_UNFAVORITE_TUTORIAL)
            or MHCWL.GetTutorialTooltip(MHCWL_BUTTON_FAVORITE, MHCWL_BUTTON_FAVORITE_TUTORIAL),
            function()
                MHCWL.CloseDropdowns()
                MHCWL.ToggleSetupFavorite(i)
            end,
            {
                normal = setup.isFavorite and MHCWL.UI_COLORS.favoriteGold or MHCWL.UI_COLORS.favoriteInactive,
                over = MHCWL.UI_COLORS.favoriteOver,
                down = MHCWL.UI_COLORS.pressedBlue,
            }
        )

        row.lock = MHCWL.CreateIconButton(parent, lockX, rowY + 4, iconButtonSize * 0.55, lockIcons, lockTooltip,
            function()
                MHCWL.CloseDropdowns()
                MHCWL.ToggleSetupLock(i)
            end, 
            {
                normal = setup.locked and MHCWL.UI_COLORS.lockedGold or MHCWL.UI_COLORS.unlockedGrey,
                over = MHCWL.UI_COLORS.white,
                down = MHCWL.UI_COLORS.pressedBlue,
            }
        )

        row.activeHighlight = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
        row.activeHighlight:SetTexture(MHCWL.TEXTURES.listActive)
        row.activeHighlight:SetMouseEnabled(false)
        row.activeHighlight:SetDrawLayer(DL_CONTROLS)
        row.activeHighlight:SetDrawTier(DT_LOW)
        row.activeHighlight:SetHidden(true)

        row.loadout = MHCWL.CreateTextButton(
            parent,
            loadoutX,
            rowY,
            190,
            30,
            GetString(MHCWL_LOADOUT) .. tostring(i),
            function()
                MHCWL.CloseDropdowns()
                MHCWL.SetActiveSetup(i)
                MHCWL.RefreshWindow()
                MHCWL.LoadAndVerify()
            end
        )

        row.activeHighlight:ClearAnchors()
        row.activeHighlight:SetAnchor(TOPLEFT, row.loadout, TOPLEFT, -20, -1)
        row.activeHighlight:SetAnchor(BOTTOMRIGHT, row.loadout, BOTTOMRIGHT, 20, 7)
        row.activeHighlight:SetColor(MHCWL.GetActiveHighlightColor())

        row.loadout:SetDrawTier(DT_HIGH)
        row.loadout:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        row.loadout:SetHandler("OnMouseEnter", function(control)
            local fullText = control.fullTooltipText or ""

            if not MHCWL.AreTooltipsEnabled() then
                return
            end

            local text = fullText

            if MHCWL.AreTutorialTooltipsEnabled() then
                local companionData = MHCWL.GetActiveCompanionSavedData()
                if not companionData then return end

                local isActive = companionData.activeSetup == i
                local actionText = isActive
                    and GetString(MHCWL_TOOLTIP_ACTIVE)
                    or GetString(MHCWL_TOOLTIP_SELECT)

                text =
                    fullText ~= ""
                    and (fullText .. "\n\n" .. actionText)
                    or actionText
            end

            if not text or text == "" then
                return
            end

            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
            SetTooltipText(InformationTooltip, text)
        end)

        row.loadout:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)

        local warnings = MHCWL.GetSetupWarnings(setup)

        row.warning = MHCWL.CreateIconButton(parent, loadoutX, rowY - 4, iconButtonSize, MHCWL.BUTTONS.warning, function() return row.warning.tooltipText or "" end, function()
            if row.warning.canFetchGear then
                MHCWL.QueueMissingGearFetch(i)
            end
        end, {
            normal = MHCWL.UI_COLORS.warningGold,
            over = MHCWL.UI_COLORS.warningGoldOver,
            down = MHCWL.UI_COLORS.warningGoldDown,
        })

        row.warning:SetHidden(not MHCWL.HasWarnings(warnings))

        row.save = MHCWL.CreateIconButton(parent, saveX, rowY, iconButtonSize, MHCWL.BUTTONS.save, function()
            return MHCWL.GetTutorialTooltip(MHCWL_TOOLTIP_SAVE, MHCWL_TOOLTIP_SAVE_TUTORIAL)
        end,
        function()
            MHCWL.CloseDropdowns()
            MHCWL.SetActiveSetup(i)
            MHCWL.SaveCurrent()
            MHCWL.RefreshWindow()
        end, MHCWL.STANDARD_BUTTON_COLORS)

        row.rename = MHCWL.CreateIconButton(parent, renameX, rowY - 8, iconButtonSize * 1.35, MHCWL.BUTTONS.rename, function()
            return MHCWL.GetTutorialTooltip(MHCWL_TOOLTIP_RENAME, MHCWL_TOOLTIP_RENAME_TUTORIAL)
        end,
        function()
            MHCWL.CloseDropdowns()
            MHCWL.SetActiveSetup(i)
            MHCWL.RefreshWindow()
            MHCWL.ShowRenameDialog(i)
        end, MHCWL.STANDARD_BUTTON_COLORS)

        row.inspect = MHCWL.CreateIconButton(parent, inspectX, rowY - 3, iconButtonSize * 1.25, MHCWL.BUTTONS.inspect, function()
            return MHCWL.GetTutorialTooltip(MHCWL_TOOLTIP_INSPECT, MHCWL_TOOLTIP_INSPECT_TUTORIAL)
        end,
        function()
            MHCWL.CloseDropdowns()
            MHCWL.ToggleInspectWindow(i)
        end, MHCWL.STANDARD_BUTTON_COLORS)

        row.delete = MHCWL.CreateIconButton(parent, deleteX, rowY + 5, iconButtonSize * 0.65, MHCWL.BUTTONS.delete, function()
            return MHCWL.GetTutorialTooltip(MHCWL_TOOLTIP_DELETE, MHCWL_TOOLTIP_DELETE_TUTORIAL)
        end,
        function()
            MHCWL.CloseDropdowns()
            MHCWL.DeleteLoadout(i)
        end, {
            normal = MHCWL.UI_COLORS.deleteRed,
            over = MHCWL.UI_COLORS.deleteRedOver,
            down = MHCWL.UI_COLORS.deleteRedDown,
        })

        MHCWL.loadoutRows[i] = row
    end

    local visibleCount = math.max(0, math.min(endIndex, setupCount) - startIndex + 1)

    local rowBlockBottomY = 65 + (visibleCount * 42)
    local addY = rowBlockBottomY + addGapFromLastRow
    local addX = (parent:GetWidth() - addButtonSize) * 0.5

    MHCWL.addLoadoutButton = MHCWL.CreateIconButton(parent, addX, addY, addButtonSize, MHCWL.BUTTONS.add, function()
        return MHCWL.GetTutorialTooltip(MHCWL_TOOLTIP_ADD, MHCWL_TOOLTIP_ADD_TUTORIAL)
    end,
    function()
        MHCWL.CloseDropdowns()
        MHCWL.AddLoadout()
    end, MHCWL.STANDARD_BUTTON_COLORS)

    local isLastPage = activePage >= totalPages
    local totalSetupCount = MHCWL.GetSetupCount(companionData)
    local maxReached = totalSetupCount >= MHCWL.MAX_SETUP_SLOTS

    MHCWL.addLoadoutButton:SetHidden(not isLastPage or maxReached)
end

function MHCWL.GetPageInfo(companionData)
    local visibleIndexes = MHCWL.GetVisibleSortedLoadoutIndexes(companionData)
    local visibleCount = #visibleIndexes

    local totalPages = math.max(1, math.ceil(visibleCount / MHCWL.LOADOUTS_PER_PAGE))

    companionData.activePage = zo_clamp(companionData.activePage or 1, 1, totalPages)

    return visibleCount, totalPages, companionData.activePage, visibleIndexes
end

function MHCWL.CreatePageFooter(parent)
    local footerHeight = 34
    local footerY = parent:GetHeight() - footerHeight

    MHCWL.pageFooter = MHCWL.CreateFooter(parent, 397, footerHeight, TOPLEFT, TOPLEFT, 0, footerY)

    MHCWL.pagePrevButton = MHCWL.CreateIconButton(parent, 120, footerY + 5, 24, MHCWL.BUTTONS.pageLeft, function()
        return MHCWL.GetTutorialTooltip(MHCWL_TOOLTIP_PAGE_PREVIOUS, MHCWL_TOOLTIP_PAGE_PREVIOUS_TUTORIAL)
    end,
    function()
        local companionData = MHCWL.GetActiveCompanionSavedData()
        if not companionData then return end

        companionData.activePage = math.max(1, (companionData.activePage or 1) - 1)
        MHCWL.CloseDropdowns()
        MHCWL.RebuildWindowContent()
    end, MHCWL.STANDARD_BUTTON_COLORS)

    MHCWL.pageLabel = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    MHCWL.pageLabel:SetFont(MHCWL.FONTS.gameSmall)
    MHCWL.pageLabel:SetDimensions(80, 24)
    MHCWL.pageLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 160, footerY + 7)
    MHCWL.pageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    MHCWL.pageNextButton = MHCWL.CreateIconButton(parent, 245, footerY + 5, 24, MHCWL.BUTTONS.pageRight, function()
        return MHCWL.GetTutorialTooltip(MHCWL_TOOLTIP_PAGE_NEXT, MHCWL_TOOLTIP_PAGE_NEXT_TUTORIAL)
    end,
    function()
        local companionData = MHCWL.GetActiveCompanionSavedData()
        if not companionData then return end

        local _, totalPages = MHCWL.GetPageInfo(companionData)

        companionData.activePage = math.min(totalPages, (companionData.activePage or 1) + 1)
        MHCWL.CloseDropdowns()
        MHCWL.RebuildWindowContent()
    end, MHCWL.STANDARD_BUTTON_COLORS)

    MHCWL.RefreshPageFooter()
end

function MHCWL.RefreshPageFooter()
    if not MHCWL.pageLabel then return end

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return end

    local _, totalPages, activePage = MHCWL.GetPageInfo(companionData)

    MHCWL.pageLabel:SetText(zo_strformat(GetString(MHCWL_PAGE_LABEL), activePage, totalPages))

    if MHCWL.pagePrevButton then
        MHCWL.pagePrevButton:SetHidden(activePage <= 1)
    end

    if MHCWL.pageNextButton then
        MHCWL.pageNextButton:SetHidden(activePage >= totalPages)
    end
end

function MHCWL.IsSetupEmpty(setup)
    if not setup then return true end

    if setup.gear then
        for _, gear in pairs(setup.gear) do
            if gear
            and (
                (gear.id and gear.id ~= "0")
                or (gear.link and gear.link ~= "")
            ) then
                return false
            end
        end
    end

    if setup.skills then
        for _, abilityId in pairs(setup.skills) do
            if abilityId and abilityId > 0 then
                return false
            end
        end
    end

    return true
end

function MHCWL.RefreshWindow()
    if not MHCWL.window or not MHCWL.loadoutRows then return end

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return end

    MHCWL.EnsureCompanionSetups(companionData)

    if MHCWL.window.showFavoritesButton then
        MHCWL.window.showFavoritesButton.RefreshIcon()
    end

    if MHCWL.window.showNormalButton then
        MHCWL.window.showNormalButton.RefreshIcon()
    end

    for i, row in pairs(MHCWL.loadoutRows) do
        local setup = companionData.setups[i]
        local isActive = companionData.activeSetup == i

        local emptyMarker = MHCWL.IsSetupEmpty(setup) and GetString(MHCWL_EMPTY_MARKER) or ""
        local loadoutText = tostring(setup.name) .. emptyMarker
        local displayText = MHCWL.TruncateTextToWidth(loadoutText, MHCWL.FONTS.game, maxLoadoutWidth)

        row.loadout:SetWidth(maxLoadoutWidth)
        row.loadout:SetText(displayText)
        row.loadout.fullTooltipText = loadoutText

        local warnings = MHCWL.GetSetupWarnings(setup)
        local tooltipText = MHCWL.GetWarningTooltip(warnings)

        row.warning.canFetchGear =
            warnings.missingGear
            and #warnings.missingGear > 0

        if row.warning.canFetchGear
        and MHCWL.AreTutorialTooltipsEnabled() then
            tooltipText = tooltipText
                .. "\n\n"
                .. "|cFFAA00"
                .. GetString(MHCWL_TOOLTIP_QUEUE_MISSING_GEAR_FETCH)
                .. "|r"
        end

        row.warning.tooltipText = tooltipText

        row.warning:ClearAnchors()
        row.warning:SetAnchor(LEFT, row.loadout, RIGHT, 4, -4)
        row.warning:SetHidden(not MHCWL.HasWarnings(warnings))

        local r, g, b, a = MHCWL.GetLoadoutListColor(setup, isActive)
        row.loadout:SetNormalFontColor(r, g, b, a)

        if row.activeHighlight then
            row.activeHighlight:SetColor(MHCWL.GetActiveHighlightColor())
            row.activeHighlight:SetHidden(not isActive)
        end
    end
end

function MHCWL.ToggleSettingsDropdown()
    if MHCWL.settingsDropdown and not MHCWL.settingsDropdown:IsHidden() then
        MHCWL.settingsDropdown:SetHidden(true)
        return
    end

    if not MHCWL.settingsDropdown then
        MHCWL.CreateSettingsDropdown()
    end

    MHCWL.RefreshSettingsDropdown()
    MHCWL.dropdownIgnoreMouseUntil = GetFrameTimeMilliseconds() + 250
    MHCWL.settingsDropdown:SetHidden(false)
end

function MHCWL.CreateSettingsDropdown()
    MHCWL.settingsRows = {}

    MHCWL.settingsDropdown = MHCWL.CreateDropdown({
        name = "MHCWLSettingsDropdown",
        anchorPoint = TOPLEFT,
        anchorTo = MHCWL.window,
        relativePoint = TOPRIGHT,
        offsetX = 8,

        rows = {
            {
                type = "checkbox",
                label = GetString(MHCWL_WINDOW_OPTIONS_SAVE_GEAR),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_WINDOW_OPTIONS_SAVE_GEAR_TOOLTIP,
                        MHCWL_WINDOW_OPTIONS_SAVE_GEAR_TOOLTIP_TUTORIAL
                    )
                end,
                get = function()
                    return MHCWL.saved.settings.saveGear
                end,
                set = function(enabled)
                    MHCWL.saved.settings.saveGear = enabled

                    if not MHCWL.saved.settings.saveGear
                    and not MHCWL.saved.settings.saveSkills then
                        MHCWL.saved.settings.saveSkills = true
                    end

                    MHCWL.RefreshSettingsDropdown()
                end,
            },
            {
                type = "checkbox",
                label = GetString(MHCWL_WINDOW_OPTIONS_SAVE_SKILLS),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_WINDOW_OPTIONS_SAVE_SKILLS_TOOLTIP,
                        MHCWL_WINDOW_OPTIONS_SAVE_SKILLS_TOOLTIP_TUTORIAL
                    )
                end,
                get = function()
                    return MHCWL.saved.settings.saveSkills
                end,
                set = function(enabled)
                    MHCWL.saved.settings.saveSkills = enabled

                    if not MHCWL.saved.settings.saveGear
                    and not MHCWL.saved.settings.saveSkills then
                        MHCWL.saved.settings.saveGear = true
                    end

                    MHCWL.RefreshSettingsDropdown()
                end,
            },
            {
                type = "checkbox",
                label = GetString(MHCWL_WINDOW_OPTIONS_LOAD_GEAR),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_WINDOW_OPTIONS_LOAD_GEAR_TOOLTIP,
                        MHCWL_WINDOW_OPTIONS_LOAD_GEAR_TOOLTIP_TUTORIAL
                    )
                end,
                gapBefore = 8,
                get = function()
                    return MHCWL.saved.settings.loadGear
                end,
                set = function(enabled)
                    MHCWL.saved.settings.loadGear = enabled

                    if not MHCWL.saved.settings.loadGear
                    and not MHCWL.saved.settings.loadSkills then
                        MHCWL.saved.settings.loadSkills = true
                    end

                    MHCWL.RefreshSettingsDropdown()
                end,
            },
            {
                type = "checkbox",
                label = GetString(MHCWL_WINDOW_OPTIONS_LOAD_SKILLS),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_WINDOW_OPTIONS_LOAD_SKILLS_TOOLTIP,
                        MHCWL_WINDOW_OPTIONS_LOAD_SKILLS_TOOLTIP_TUTORIAL
                    )
                end,
                get = function()
                    return MHCWL.saved.settings.loadSkills
                end,
                set = function(enabled)
                    MHCWL.saved.settings.loadSkills = enabled

                    if not MHCWL.saved.settings.loadGear
                    and not MHCWL.saved.settings.loadSkills then
                        MHCWL.saved.settings.loadGear = true
                    end

                    MHCWL.RefreshSettingsDropdown()
                end,
            },
            {
                type = "text",
                label = GetString(MHCWL_WINDOW_OPTIONS_IMPORT),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_WINDOW_OPTIONS_IMPORT_TOOLTIP,
                        MHCWL_WINDOW_OPTIONS_IMPORT_TOOLTIP_TUTORIAL
                    )
                end,
                gapBefore = 20,
                onClick = function()
                    MHCWL.ShowImportDialog(nil, false)
                end,
            },
        },
    })
end

function MHCWL.RefreshSettingsDropdown()
    if MHCWL.settingsDropdown
    and MHCWL.settingsDropdown.Refresh then
        MHCWL.settingsDropdown.Refresh()
    end
end