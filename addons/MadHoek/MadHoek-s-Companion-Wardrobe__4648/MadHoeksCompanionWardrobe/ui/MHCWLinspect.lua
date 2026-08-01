-- ============================================================================
-- Companion Wardrobe
-- Inspect Window - Visual View and Shared Inspect Controls
--
-- Responsibilities:
-- - Create and refresh the inspect window.
-- - Display saved gear and skills in graphical form.
-- - Manage inspect dropdown actions.
-- - Display warning icons and tooltips for inspected loadouts.
-- - Coordinate visual/text inspect view switching.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

MHCWL.GEAR_VISUAL_SLOTS = {
    [EQUIP_SLOT_HEAD] = "head",
    [EQUIP_SLOT_SHOULDERS] = "shoulders",
    [EQUIP_SLOT_CHEST] = "chest",
    [EQUIP_SLOT_HAND] = "hands",
    [EQUIP_SLOT_WAIST] = "waist",
    [EQUIP_SLOT_LEGS] = "legs",
    [EQUIP_SLOT_FEET] = "feet",
    [EQUIP_SLOT_NECK] = "neck",
    [EQUIP_SLOT_RING1] = "ring1",
    [EQUIP_SLOT_RING2] = "ring2",
    [EQUIP_SLOT_MAIN_HAND] = "mainHand",
    [EQUIP_SLOT_OFF_HAND] = "offHand",
}

MHCWL.SKILL_ICON_POSITIONS = {
    [3] = 36,
    [4] = 88,
    [5] = 140,
    [6] = 192,
    [7] = 244,
    [8] = 326,
}

MHCWL.SKILL_FRAME_POSITIONS = {
    [8] = 324,
}

MHCWL.SKILL_SLOT_UNLOCK_LEVELS = {
    [3] = 1,
    [4] = 1,
    [5] = 2,
    [6] = 7,
    [7] = 12,
    [8] = 20,
}

function MHCWL.ShouldShowSlot7InUltimate()
    return MHCWL.saved
        and MHCWL.saved.settings
        and MHCWL.saved.settings.debug
        and MHCWL.saved.settings.debugShowSlot7InUltimate == true
end

function MHCWL.GetAbilityIcon(abilityId)
    if not abilityId or abilityId <= 0 then
        return nil
    end

    return GetAbilityIcon(abilityId)
end

function MHCWL.ConfigureInspectWarningIcon(control)
    control:SetMouseEnabled(true)

    control:SetHandler("OnMouseEnter", function(self)
        if self.tooltipText and self.tooltipText ~= "" then
            InitializeTooltip(InformationTooltip, self, TOPLEFT, 18, -20)
            SetTooltipText(InformationTooltip, self.tooltipText)
        end
    end)

    control:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
end

function MHCWL.ToggleInspectOptionsDropdown()
    if MHCWL.inspectOptionsDropdown
    and not MHCWL.inspectOptionsDropdown:IsHidden() then
        MHCWL.inspectOptionsDropdown:SetHidden(true)
        return
    end

    if not MHCWL.inspectOptionsDropdown then
        MHCWL.CreateInspectOptionsDropdown()
    end

    MHCWL.inspectOptionsDropdown.Refresh()

    MHCWL.inspectDropdownIgnoreMouseUntil = GetFrameTimeMilliseconds() + 250
    MHCWL.inspectOptionsDropdown:SetHidden(false)
end

function MHCWL.CreateInspectOptionsDropdown()
    MHCWL.inspectOptionsDropdown = MHCWL.CreateDropdown({
        name = "MHCWLInspectDropdown",
        anchorPoint = TOPLEFT,
        anchorTo = MHCWL.inspectWindow,
        relativePoint = TOPRIGHT,
        offsetX = 8,

        rows = {
            {
                type = "text",
                label = GetString(MHCWL_WINDOW_INSPECT_DROPDOWN_ACTIVE),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_INSPECT_TOOLTIP_ACTIVE,
                        MHCWL_INSPECT_TOOLTIP_ACTIVE_TUTORIAL
                    )
                end,
                onClick = function()
                    if not MHCWL.inspectIndex then return end

                    MHCWL.SetActiveSetup(MHCWL.inspectIndex)
                    MHCWL.RefreshWindow()
                    MHCWL.RefreshInspectWindow(MHCWL.inspectIndex)
                    MHCWL.LoadAndVerify()
                end,
            },
            {
                type = "text",
                label = GetString(MHCWL_WINDOW_INSPECT_DROPDOWN_ACQUIRE_GEAR),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_INSPECT_TOOLTIP_ACQUIRE_GEAR,
                        MHCWL_INSPECT_TOOLTIP_ACQUIRE_GEAR_TUTORIAL
                    )
                end,

                hidden = function()
                    return not MHCWL.InspectLoadoutHasMissingGear()
                end,

                onClick = function()
                    if not MHCWL.inspectIndex then return end

                    MHCWL.QueueMissingGearFetch(MHCWL.inspectIndex)
                end,
            },
            {
                type = "text",
                label = GetString(MHCWL_WINDOW_INSPECT_DROPDOWN_STORE_GEAR),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_INSPECT_TOOLTIP_STORE_GEAR,
                        MHCWL_INSPECT_TOOLTIP_STORE_GEAR_TUTORIAL
                    )
                end,
                hidden = function()
                    local companionData = MHCWL.GetActiveCompanionSavedData()
                    if not companionData then return true end

                    local index = MHCWL.inspectIndex
                    if not index then return true end

                    local setup = companionData.setups[index]
                    if not setup then return true end

                    if companionData.activeSetup == index then
                        return true
                    end

                    return not MHCWL.HasLoadoutGearInBackpack(index)
                end,
                onClick = function()
                    MHCWL.QueueLoadoutGearStore(MHCWL.inspectIndex)
                end,
            },
            {
                type = "text",
                label = GetString(MHCWL_WINDOW_INSPECT_DROPDOWN_RENAME),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_INSPECT_TOOLTIP_RENAME,
                        MHCWL_INSPECT_TOOLTIP_RENAME_TUTORIAL
                    )
                end,
                onClick = function()
                    if not MHCWL.inspectIndex then return end

                    MHCWL.ShowRenameDialog(MHCWL.inspectIndex)
                end,
            },
            {
                type = "text",
                label = GetString(MHCWL_WINDOW_INSPECT_DROPDOWN_DUPLICATE),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_INSPECT_TOOLTIP_DUPLICATE,
                        MHCWL_INSPECT_TOOLTIP_DUPLICATE_TUTORIAL
                    )
                end,
                onClick = function()
                    if not MHCWL.inspectIndex then return end

                    MHCWL.DuplicateLoadout(MHCWL.inspectIndex)
                end,
            },
            {
                type = "text",
                label = GetString(MHCWL_WINDOW_INSPECT_DROPDOWN_EXPORT),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_INSPECT_TOOLTIP_EXPORT,
                        MHCWL_INSPECT_TOOLTIP_EXPORT_TUTORIAL
                    )
                end,
                onClick = function()
                    if not MHCWL.inspectIndex then return end

                    MHCWL.ShowExportDialog(MHCWL.inspectIndex)
                end,
            },
            {
                type = "text",
                label = GetString(MHCWL_WINDOW_INSPECT_DROPDOWN_IMPORT),
                tooltip = function()
                    return MHCWL.GetTutorialTooltip(
                        MHCWL_INSPECT_TOOLTIP_IMPORT,
                        MHCWL_INSPECT_TOOLTIP_IMPORT_TUTORIAL
                    )
                end,
                onClick = function()
                    if not MHCWL.inspectIndex then return end

                    MHCWL.ShowImportDialog(MHCWL.inspectIndex, true)
                end,
            },
        },
    })
end

function MHCWL.ToggleInspectWindow(index)
    if MHCWL.inspectWindow and not MHCWL.inspectWindow:IsHidden() and MHCWL.inspectIndex == index then
        MHCWL.inspectWindow:SetHidden(true)
        return
    end

    MHCWL.inspectIndex = index

    if not MHCWL.inspectWindow then
        MHCWL.CreateInspectWindow()
    end

    MHCWL.RefreshInspectWindow(index)
    MHCWL.inspectWindow:SetHidden(false)
end

function MHCWL.RefreshOpenInspectWindow()
    if MHCWL.inspectWindow
    and not MHCWL.inspectWindow:IsHidden()
    and MHCWL.inspectIndex then
        MHCWL.RefreshInspectWindow(MHCWL.inspectIndex)
    end
end

function MHCWL.CreateInspectWindow()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("MHCWLInspectWindow")
    MHCWL.inspectWindow = window

    local layoutOffsetX = 18
    local layoutOffsetY = 20

    local gearBlockOffsetX = 0
    local gearBlockOffsetY = 0

    local skillsBlockOffsetX = 0
    local skillsBlockOffsetY = 125

    window:SetDimensions(430, 640)
    window:SetAnchor(TOPLEFT, MHCWL.window, TOPRIGHT, 8, 0)
    window:SetMouseEnabled(true)
    window:SetHandler("OnMouseDown", function()
        if MHCWL.dropdownIgnoreMouseUntil
        and GetFrameTimeMilliseconds() < MHCWL.dropdownIgnoreMouseUntil then
            return
        end

        MHCWL.CloseDropdowns()
    end)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControlFromVirtual(nil, window, "ZO_DefaultBackdrop")
    bg:SetAnchorFill(window)
    bg:SetAlpha(0.95)

    local headerHeight = 42

    local header = MHCWL.CreateHeader(window, 427, headerHeight)
    window.header = header

    local title = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    window.title = title
    title:SetFont(MHCWL.FONTS.header)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 16, 12)
    title:SetText(GetString(MHCWL_WINDOW_INSPECT_TITLE))

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
    close:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 12)

    window.optionsButton = MHCWL.CreateIconButton(
        window,
        -38,
        7,
        30,
        MHCWL.BUTTONS.settings,
        function()
            return MHCWL.GetTutorialTooltip(
                MHCWL_TOOLTIP_SETTINGS,
                MHCWL_TOOLTIP_SETTINGS_TUTORIAL
            )
        end,
        function()
            MHCWL.ToggleInspectOptionsDropdown()
        end,
        MHCWL.ICON_BUTTON_COLORS
    )
    window.optionsButton:ClearAnchors()
    window.optionsButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -38, 7)

    window.viewModeButton = MHCWL.CreateIconButton(
        window,
        0,
        0,
        28,
        MHCWL.BUTTONS.view,
        function()
            return MHCWL.GetTutorialTooltip(
                MHCWL_TOOLTIP_INSPECT_SWITCH_VIEW,
                MHCWL_TOOLTIP_INSPECT_SWITCH_VIEW_TUTORIAL
            )
        end,
        function()
            MHCWL.ToggleInspectViewMode()
        end,
        MHCWL.ICON_BUTTON_COLORS
    )

    window.viewModeButton:ClearAnchors()
    window.viewModeButton:SetAnchor(TOPRIGHT, window.optionsButton, TOPLEFT, -6, 0)

    window.textArmorButton = MHCWL.CreateIconButton(
        window, 0, 0, 28,
        MHCWL.BUTTONS.inspectArmor,
        function()
            return MHCWL.GetTutorialTooltip(
                MHCWL_TOOLTIP_INSPECT_ARMOR,
                MHCWL_TOOLTIP_INSPECT_ARMOR_TUTORIAL
            )
        end,
        function()
            MHCWL.inspectTextMode = "armor"
            MHCWL.RefreshInspectWindow(MHCWL.inspectIndex)
        end,
        function()
            return MHCWL.GetInspectTextTabColor("armor")
        end
    )

    window.textWeaponsButton = MHCWL.CreateIconButton(
        window, 0, 0, 28,
        MHCWL.BUTTONS.inspectWeapons,
        function()
            return MHCWL.GetTutorialTooltip(
                MHCWL_TOOLTIP_INSPECT_WEAPONS,
                MHCWL_TOOLTIP_INSPECT_WEAPONS_TUTORIAL
            )
        end,
        function()
            MHCWL.inspectTextMode = "weapons"
            MHCWL.RefreshInspectWindow(MHCWL.inspectIndex)
        end,
        function()
            return MHCWL.GetInspectTextTabColor("weapons")
        end
    )

    window.textSkillsButton = MHCWL.CreateIconButton(
        window, 0, 0, 28,
        MHCWL.BUTTONS.inspectSkills,
        function()
            return MHCWL.GetTutorialTooltip(
                MHCWL_TOOLTIP_INSPECT_SKILLS,
                MHCWL_TOOLTIP_INSPECT_SKILLS_TUTORIAL
            )
        end,
        function()
            MHCWL.inspectTextMode = "skills"
            MHCWL.RefreshInspectWindow(MHCWL.inspectIndex)
        end,
        function()
            return MHCWL.GetInspectTextTabColor("skills")
        end
    )

    window.textSkillsButton:ClearAnchors()
    window.textSkillsButton:SetAnchor(TOPRIGHT, window.viewModeButton, TOPLEFT, -20, 0)

    window.textWeaponsButton:ClearAnchors()
    window.textWeaponsButton:SetAnchor(TOPRIGHT, window.textSkillsButton, TOPLEFT, -4, 0)

    window.textArmorButton:ClearAnchors()
    window.textArmorButton:SetAnchor(TOPRIGHT, window.textWeaponsButton, TOPLEFT, -4, 0)

    window.textArmorButton:SetHidden(true)
    window.textWeaponsButton:SetHidden(true)
    window.textSkillsButton:SetHidden(true)

    window.colorButton = MHCWL.CreateIconButton(
        window,
        0,
        0,
        28,
        MHCWL.BUTTONS.dye,
        function()
            return MHCWL.GetTutorialTooltip(
                MHCWL_TOOLTIP_INSPECT_COLOR,
                MHCWL_TOOLTIP_INSPECT_COLOR_TUTORIAL
            )
        end,
        function()
            MHCWL.ToggleLoadoutColorDropdown()
        end,
        MHCWL.ICON_BUTTON_COLORS
    )

    window.colorButton:ClearAnchors()
    window.colorButton:SetAnchor(TOPLEFT, window, TOPLEFT, 16, 42)

    local name = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    window.nameLabel = name
    name:SetFont(MHCWL.FONTS.gameBold)
    name:SetAnchor(LEFT, window.colorButton, RIGHT, 6, 0)
    name:SetDimensions(1, 24)

    window.lockButton = MHCWL.CreateIconButton(
        window,
        0,
        0,
        18,
        function()
            local companionData = MHCWL.GetActiveCompanionSavedData()
            local setup = companionData and companionData.setups[MHCWL.inspectIndex or 0]
            return setup and setup.locked and MHCWL.BUTTONS.locked or MHCWL.BUTTONS.unlocked
        end,
        function()
            local companionData = MHCWL.GetActiveCompanionSavedData()
            local setup = companionData and companionData.setups[MHCWL.inspectIndex or 0]

            if setup and setup.locked then
                return MHCWL.GetTutorialTooltip(
                    MHCWL_BUTTON_UNLOCK,
                    MHCWL_BUTTON_UNLOCK_TUTORIAL
                )
            end

            return MHCWL.GetTutorialTooltip(
                MHCWL_BUTTON_LOCK,
                MHCWL_BUTTON_LOCK_TUTORIAL
            )
        end,
        function()
            if MHCWL.inspectIndex then
                MHCWL.CloseDropdowns()
                MHCWL.ToggleSetupLock(MHCWL.inspectIndex)
                MHCWL.RefreshWindow()
                MHCWL.RefreshInspectWindow(MHCWL.inspectIndex)
            end
        end,
        function()
            local companionData = MHCWL.GetActiveCompanionSavedData()
            local setup = companionData and companionData.setups[MHCWL.inspectIndex or 0]

            return {
                normal = setup and setup.locked and MHCWL.UI_COLORS.lockedGold or MHCWL.UI_COLORS.unlockedGrey,
                over = MHCWL.UI_COLORS.white,
                down = MHCWL.UI_COLORS.pressedBlue,
            }
        end
    )

    window.lockButton:ClearAnchors()
    window.lockButton:SetAnchor(RIGHT, window.nameLabel, RIGHT, 30, 0)

    window.favoriteButton = MHCWL.CreateIconButton(
        window,
        0,
        0,
        35,
        MHCWL.BUTTONS.favorite,
        function()
            local companionData = MHCWL.GetActiveCompanionSavedData()
            local setup = companionData and companionData.setups[MHCWL.inspectIndex or 0]

            if setup and setup.isFavorite then
                return MHCWL.GetTutorialTooltip(
                    MHCWL_BUTTON_UNFAVORITE,
                    MHCWL_BUTTON_UNFAVORITE_TUTORIAL
                )
            end

            return MHCWL.GetTutorialTooltip(
                MHCWL_BUTTON_FAVORITE,
                MHCWL_BUTTON_FAVORITE_TUTORIAL
            )
        end,
        function()
            if MHCWL.inspectIndex then
                MHCWL.CloseDropdowns()
                MHCWL.ToggleSetupFavorite(MHCWL.inspectIndex)
                MHCWL.RefreshWindow()
                MHCWL.RefreshInspectWindow(MHCWL.inspectIndex)
            end
        end,
        function()
            local companionData = MHCWL.GetActiveCompanionSavedData()
            local setup = companionData and companionData.setups[MHCWL.inspectIndex or 0]

            return {
                normal = setup and setup.isFavorite and MHCWL.UI_COLORS.favoriteGold or MHCWL.UI_COLORS.favoriteInactive,
                over = MHCWL.UI_COLORS.favoriteOver,
                down = MHCWL.UI_COLORS.pressedBlue,
            }
        end
    )

    window.favoriteButton:ClearAnchors()
    window.favoriteButton:SetAnchor(LEFT, window.lockButton, RIGHT, 0, 0)

    local gearHeader = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    window.gearHeader = gearHeader

    gearHeader:SetFont(MHCWL.FONTS.gameBold)
    gearHeader:SetAnchor(TOPLEFT, window, TOPLEFT, 16, 100)
    gearHeader:SetText(GetString(MHCWL_WINDOW_INSPECT_GEAR_HEADER))

    window.gearRows = {}

    window.gearVisual = {}

    local gearCenterX = 185 + layoutOffsetX + gearBlockOffsetX
    local gearTopY = 126 + layoutOffsetY + gearBlockOffsetY
    local slotSize = 38

    local silhouette = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
    window.gearVisual.silhouette = silhouette
    silhouette:SetDimensions(90, 360)
    silhouette:SetAnchor(TOPLEFT, window, TOPLEFT, gearCenterX - 45, gearTopY + 16)
    silhouette:SetTexture(MHCWL.TEXTURES.silhouetteKhajiitFemale)
    silhouette:SetAlpha(0.85)

    local function CreateGearSlot(key, texture, x, y)
        local slot = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
        slot:SetDimensions(slotSize, slotSize)
        slot:SetAnchor(TOPLEFT, window, TOPLEFT, x, y)
        slot:SetTexture(texture)
        slot:SetAlpha(0.9)

        local icon = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
        icon:SetDimensions(slotSize * 1.3, slotSize * 1.3)
        icon:SetAnchor(CENTER, slot, CENTER, 0, 0)
        icon:SetHidden(true)

        local warning = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
        warning:SetDimensions(22, 22)
        warning:SetAnchor(TOPRIGHT, slot, TOPRIGHT, 6, -4)
        warning:SetTexture(MHCWL.BUTTONS.warning.up)
        warning:SetColor(unpack(MHCWL.UI_COLORS.warningGold))
        warning:SetDrawLayer(DL_OVERLAY)
        warning:SetDrawTier(DT_HIGH)
        warning:SetDrawLevel(50)
        warning:SetHidden(true)

        MHCWL.ConfigureInspectWarningIcon(warning)

        local hitbox = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
        hitbox:SetDimensions(slotSize, slotSize)
        hitbox:SetAnchor(TOPLEFT, slot, TOPLEFT, 0, 0)
        hitbox:SetMouseEnabled(true)
        hitbox:SetHandler("OnMouseDown", function()
            MHCWL.CloseDropdowns()
        end)

        hitbox:SetHandler("OnMouseEnter", function(control)
            if control.itemLink and control.itemLink ~= "" then
                InitializeTooltip(ItemTooltip, control, TOPLEFT, 18, -20)
                ItemTooltip:SetLink(control.itemLink)
            elseif control.tooltipText then
                InitializeTooltip(InformationTooltip, control, TOPLEFT, 18, -20)
                SetTooltipText(InformationTooltip, control.tooltipText)
            end
        end)

        hitbox:SetHandler("OnMouseExit", function()
            ClearTooltip(ItemTooltip)
            ClearTooltip(InformationTooltip)
        end)

        window.gearVisual[key] = {
            slot = slot,
            icon = icon,
            hitbox = hitbox,
            warning = warning,
        }
    end

    CreateGearSlot("head", MHCWL.TEXTURES.gearHead, gearCenterX - 19, gearTopY - 35)

    CreateGearSlot("shoulders", MHCWL.TEXTURES.gearShoulders, gearCenterX - 95, gearTopY + 35)
    CreateGearSlot("hands", MHCWL.TEXTURES.gearHands, gearCenterX - 105, gearTopY + 100)
    CreateGearSlot("legs", MHCWL.TEXTURES.gearLegs, gearCenterX - 92, gearTopY + 170)

    CreateGearSlot("chest", MHCWL.TEXTURES.gearChest, gearCenterX + 58, gearTopY + 35)
    CreateGearSlot("waist", MHCWL.TEXTURES.gearWaist, gearCenterX + 68, gearTopY + 100)
    CreateGearSlot("feet", MHCWL.TEXTURES.gearFeet, gearCenterX + 58, gearTopY + 170)

    CreateGearSlot("neck", MHCWL.TEXTURES.gearNeck, gearCenterX - 75, gearTopY + 255)
    CreateGearSlot("ring1", MHCWL.TEXTURES.gearRing, gearCenterX - 19, gearTopY + 255)
    CreateGearSlot("ring2", MHCWL.TEXTURES.gearRing, gearCenterX + 35, gearTopY + 255)

    CreateGearSlot("mainHand", MHCWL.TEXTURES.gearMainHand, gearCenterX - 42, gearTopY + 300)
    CreateGearSlot("offHand", MHCWL.TEXTURES.gearOffHand, gearCenterX + 6, gearTopY + 300)

    local skillsHeaderY = 120 + (#MHCWL.GEARSLOTS * 18) + 18 + layoutOffsetY + skillsBlockOffsetY

    local skillsHeader = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    window.skillsHeader = skillsHeader

    skillsHeader:SetFont(MHCWL.FONTS.gameBold)
    skillsHeader:SetAnchor(TOPLEFT, window, TOPLEFT, 16, skillsHeaderY)
    skillsHeader:SetText(GetString(MHCWL_WINDOW_INSPECT_SKILLS_HEADER))

    window.skillRows = {}

    local skillsHeaderSpacing = 35

    local skillBarY = skillsHeaderY + skillsHeaderSpacing

    local labelStartX = 42 + layoutOffsetX + skillsBlockOffsetX
    local ultimateLabelX = 318 + layoutOffsetX + skillsBlockOffsetX
    local labelSpacing = 52
    local labelY = skillBarY + 56

    local iconSize = 38

    window.skillBarBG = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
    window.skillBarBG:SetDimensions(360, 90)
    window.skillBarBG:SetAnchor(TOPLEFT, window, TOPLEFT, -24 + layoutOffsetX + skillsBlockOffsetX, skillBarY - 18)
    window.skillBarBG:SetTexture(MHCWL.TEXTURES.skillBarBG)

    window.ultimateBG = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
    window.ultimateBG:SetDimensions(80, 80)
    window.ultimateBG:SetAnchor(TOPLEFT, window, TOPLEFT, 302 + layoutOffsetX + skillsBlockOffsetX, skillBarY - 13)
    window.ultimateBG:SetTexture(MHCWL.TEXTURES.ultimateFrameBG)

    for _, slotIndex in ipairs(MHCWL.COMPANION_SKILL_SLOTS) do

        local labelX

        if slotIndex == 8 then
            labelX = ultimateLabelX
        else
            labelX = labelStartX + ((slotIndex - 3) * labelSpacing)
        end

        local iconX = MHCWL.SKILL_ICON_POSITIONS[slotIndex] + layoutOffsetX + skillsBlockOffsetX
        local frameX = (MHCWL.SKILL_FRAME_POSITIONS[slotIndex] or MHCWL.SKILL_ICON_POSITIONS[slotIndex]) + layoutOffsetX + skillsBlockOffsetX

        local row = {}

        row.icon = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
        row.icon:SetDimensions(iconSize, iconSize)
        row.icon:SetAnchor(TOPLEFT, window, TOPLEFT, iconX - 4, skillBarY + 8)

        row.emptyBG = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
        row.emptyBG:SetDimensions(iconSize * 1.65, iconSize * 1.65)
        row.emptyBG:SetAnchor(TOPLEFT, window, TOPLEFT, frameX - 14, skillBarY - 5)
        row.emptyBG:SetTexture(MHCWL.TEXTURES.ultimateLockedBG)
        row.emptyBG:SetHidden(true)

        row.lockedBG = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
        row.lockedBG:SetDimensions(iconSize*1.65, iconSize*1.65)
        row.lockedBG:SetAnchor(TOPLEFT, window, TOPLEFT, frameX - 14, skillBarY - 5)
        row.lockedBG:SetTexture(MHCWL.TEXTURES.ultimateLockedBG)
        row.lockedBG:SetHidden(true)

        row.lockedOverlay = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
        row.lockedOverlay:SetDimensions(iconSize * 0.8, iconSize * 0.8)
        row.lockedOverlay:SetAnchor(CENTER, row.lockedBG, CENTER, 0, 0)
        row.lockedOverlay:SetTexture(MHCWL.TEXTURES.ultimateLockedOverlay)
        row.lockedOverlay:SetHidden(true)

        row.label = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
        row.label:SetFont(MHCWL.FONTS.gameSmall)

        if slotIndex == 8 then
            row.label:SetAnchor(TOPLEFT, window, TOPLEFT, labelX - 10, labelY)
            row.label:SetDimensions(70, 18)
        else
            row.label:SetAnchor(TOPLEFT, window, TOPLEFT, labelX - 15, labelY)
            row.label:SetDimensions(50, 18)
        end

        row.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        row.hitbox = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
        row.hitbox:SetAnchor(TOPLEFT, window, TOPLEFT, iconX - 4, skillBarY + 8)
        row.hitbox:SetDimensions(iconSize, iconSize)
        row.hitbox:SetMouseEnabled(true)
        row.hitbox:SetHandler("OnMouseDown", function()
            MHCWL.CloseDropdowns()
        end)

        row.hitbox:SetHandler("OnMouseEnter", function(control)
            if control.abilityId and control.abilityId > 0 then
                InitializeTooltip(AbilityTooltip, control, TOPLEFT, 18, -20)
                AbilityTooltip:SetAbilityId(control.abilityId)
            elseif control.tooltipText then
                InitializeTooltip(InformationTooltip, control, TOPLEFT, 18, -20)
                SetTooltipText(InformationTooltip, control.tooltipText)
            end
        end)

        row.hitbox:SetHandler("OnMouseExit", function()
            ClearTooltip(AbilityTooltip)
            ClearTooltip(InformationTooltip)
        end)

        row.warning = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
        row.warning:SetDimensions(22, 22)
        row.warning:SetAnchor(TOPRIGHT, row.hitbox, TOPRIGHT, 6, -4)
        row.warning:SetTexture(MHCWL.BUTTONS.warning.up)
        row.warning:SetColor(unpack(MHCWL.UI_COLORS.warningGold))
        row.warning:SetDrawLayer(DL_OVERLAY)
        row.warning:SetDrawTier(DT_HIGH)
        row.warning:SetDrawLevel(50)
        row.warning:SetHidden(true)

        MHCWL.ConfigureInspectWarningIcon(row.warning)

        window.skillRows[slotIndex] = row
    end
    -- Text Inspect View
    local textView = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    window.textView = textView

    textView:SetDimensions(390, 520)
    textView:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 90)
    textView:SetHidden(true)

    local textWarning = WINDOW_MANAGER:CreateControl(nil, textView, CT_TEXTURE)
    window.textWarningIcon = textWarning

    textWarning:SetDimensions(22, 22)
    textWarning:SetAnchor(TOPRIGHT, textView, TOPRIGHT, -4, 4)
    textWarning:SetTexture(MHCWL.BUTTONS.warning.up)
    textWarning:SetColor(unpack(MHCWL.UI_COLORS.warningGold))
    textWarning:SetDrawLayer(DL_OVERLAY)
    textWarning:SetDrawTier(DT_HIGH)
    textWarning:SetDrawLevel(50)
    textWarning:SetHidden(true)

    MHCWL.ConfigureInspectWarningIcon(textWarning)

    local textLabel = WINDOW_MANAGER:CreateControl(nil, textView, CT_LABEL)
    window.textViewLabel = textLabel

    textLabel:SetAnchor(TOPLEFT, textView, TOPLEFT, 8, 8)
    textLabel:SetFont(MHCWL.GetInspectTextFont())
    textLabel:SetWidth(370)
    textLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)

    window.textGearHitboxes = {}

    for i = 1, 7 do
        local hitbox = WINDOW_MANAGER:CreateControl(nil, textView, CT_CONTROL)
        hitbox:SetDimensions(370, 50)
        hitbox:SetAnchor(TOPLEFT, textView, TOPLEFT, 8, 38 + ((i - 1) * 60))
        hitbox:SetMouseEnabled(true)
        hitbox:SetHidden(true)

        hitbox:SetHandler("OnMouseEnter", function(control)
            local data = MHCWL.inspectGearTextTooltips
                and MHCWL.inspectGearTextTooltips[i]

            if data and data.link and data.link ~= "" then
                local anchor = MHCWL.GetMouseTooltipAnchor()

                InitializeTooltip(ItemTooltip, anchor, TOPLEFT, 18, 12)
                ItemTooltip:SetLink(data.link)
            end
        end)

        hitbox:SetHandler("OnMouseExit", function()
            ClearTooltip(ItemTooltip)
        end)

        window.textGearHitboxes[i] = hitbox
    end

    window.textSkillHitboxes = {}

    for _, slotIndex in ipairs(MHCWL.COMPANION_SKILL_SLOTS) do
        local hitbox = WINDOW_MANAGER:CreateControl(nil, textView, CT_CONTROL)
        hitbox:SetDimensions(370, 44)
        hitbox:SetAnchor(TOPLEFT, textView, TOPLEFT, 8, 38 + ((slotIndex - 3) * 66))
        hitbox:SetMouseEnabled(true)
        hitbox:SetHidden(true)

        hitbox:SetHandler("OnMouseEnter", function(control)
            local data = MHCWL.inspectSkillTextTooltips
                and MHCWL.inspectSkillTextTooltips[slotIndex]

            if data and data.abilityId and data.abilityId > 0 then
                local anchor = MHCWL.GetMouseTooltipAnchor()

                InitializeTooltip(AbilityTooltip, anchor, TOPLEFT, 18, 12)
                AbilityTooltip:SetAbilityId(data.abilityId)
            end
        end)

        hitbox:SetHandler("OnMouseExit", function()
            ClearTooltip(AbilityTooltip)
        end)

        window.textSkillHitboxes[slotIndex] = hitbox
    end
end

function MHCWL.RefreshInspectWindow(index)
    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return end

    MHCWL.EnsureCompanionSetups(companionData)

    local setup = companionData.setups[index]
    if not setup then return end

    local warnings = MHCWL.GetSetupWarnings(setup)

    MHCWL.inspectWindow.title:SetText(GetString(MHCWL_WINDOW_INSPECT_TITLE))

    local nameLabel = MHCWL.inspectWindow.nameLabel
    local rawName = tostring(setup.name or "")
    local maxWidth = MHCWL.inspectWindow:GetWidth() * 0.75

    nameLabel:SetDimensions(maxWidth, 24)
    nameLabel:SetText(rawName)
    nameLabel:SetColor(MHCWL.GetLoadoutNameColor(setup))

    local textWidth, textHeight = nameLabel:GetTextDimensions()
    local finalWidth = math.min(textWidth or maxWidth, maxWidth)

    nameLabel:SetDimensions(finalWidth, 24)

    MHCWL.inspectWindow.lockButton.RefreshIcon()

    MHCWL.inspectWindow.favoriteButton.RefreshIcon()

    local textMode = MHCWL.inspectViewMode == "text"

    local gearTextMode =
        textMode
        and (
            MHCWL.inspectTextMode == "armor"
            or MHCWL.inspectTextMode == "weapons"
        )

    for _, hitbox in pairs(MHCWL.inspectWindow.textGearHitboxes or {}) do
        hitbox:SetHidden(not gearTextMode)
        hitbox:SetMouseEnabled(gearTextMode)
    end

    local skillTextMode =
        textMode
        and MHCWL.inspectTextMode == "skills"

    for _, hitbox in pairs(MHCWL.inspectWindow.textSkillHitboxes or {}) do
        hitbox:SetHidden(not skillTextMode)
        hitbox:SetMouseEnabled(skillTextMode)
    end

    local showTextTabs = textMode

    MHCWL.RefreshInspectTextTabs()

    if MHCWL.inspectWindow.textArmorButton then
        MHCWL.inspectWindow.textArmorButton:SetHidden(not showTextTabs)
        MHCWL.inspectWindow.textWeaponsButton:SetHidden(not showTextTabs)
        MHCWL.inspectWindow.textSkillsButton:SetHidden(not showTextTabs)
    end

    local hidden = textMode

    if MHCWL.inspectWindow.gearHeader then
        MHCWL.inspectWindow.gearHeader:SetHidden(hidden)
    end

    if MHCWL.inspectWindow.skillsHeader then
        MHCWL.inspectWindow.skillsHeader:SetHidden(hidden)
    end

    if MHCWL.inspectWindow.gearVisual then
        if MHCWL.inspectWindow.gearVisual.silhouette then
            MHCWL.inspectWindow.gearVisual.silhouette:SetHidden(hidden)
        end

        for _, visual in pairs(MHCWL.inspectWindow.gearVisual) do
            if visual.slot then
                visual.slot:SetHidden(hidden)
            end

            if visual.icon then
                visual.icon:SetHidden(hidden)
            end

            if visual.warning then
                visual.warning:SetHidden(hidden)
            end
            if visual.hitbox then
                visual.hitbox:SetHidden(hidden)
                visual.hitbox:SetMouseEnabled(not hidden)
            end
        end
    end

    if MHCWL.inspectWindow.skillBarBG then
        MHCWL.inspectWindow.skillBarBG:SetHidden(hidden)
    end

    if MHCWL.inspectWindow.ultimateBG then
        MHCWL.inspectWindow.ultimateBG:SetHidden(hidden)
    end

    for _, row in pairs(MHCWL.inspectWindow.skillRows or {}) do
        row.icon:SetHidden(hidden)
        row.emptyBG:SetHidden(hidden)
        row.lockedBG:SetHidden(hidden)
        row.lockedOverlay:SetHidden(hidden)
        row.label:SetHidden(hidden)

        if row.warning then
            row.warning:SetHidden(hidden)
        end
        if row.hitbox then
            row.hitbox:SetHidden(hidden)
            row.hitbox:SetMouseEnabled(not hidden)
        end
    end

    if MHCWL.inspectWindow.textView then
        MHCWL.inspectWindow.textView:SetHidden(not textMode)
    end

    if MHCWL.inspectWindow.textWarningIcon then
        MHCWL.inspectWindow.textWarningIcon:SetHidden(true)
        MHCWL.inspectWindow.textWarningIcon.tooltipText = nil
    end

    if textMode then
        if MHCWL.inspectWindow.textWarningIcon then
            local warningTooltip = MHCWL.GetWarningTooltip(warnings)
            local hasWarnings = MHCWL.HasWarnings(warnings)

            MHCWL.inspectWindow.textWarningIcon.tooltipText = warningTooltip
            MHCWL.inspectWindow.textWarningIcon:SetHidden(not hasWarnings)
        end

        if MHCWL.inspectWindow.textViewLabel then
            MHCWL.inspectWindow.textViewLabel:SetText(
                MHCWL.BuildInspectText(index)
            )
        end

        return
    end

    local companionDefId = GetActiveCompanionDefId and GetActiveCompanionDefId()

    if companionDefId then
        local silhouetteTexture = MHCWL.GetCompanionSilhouetteTexture(companionDefId)

        if silhouetteTexture then
            MHCWL.inspectWindow.gearVisual.silhouette:SetTexture(silhouetteTexture)
        end
    end

    for equipSlot, visualKey in pairs(MHCWL.GEAR_VISUAL_SLOTS) do
        local visual = MHCWL.inspectWindow.gearVisual[visualKey]
        local gear = setup.gear and setup.gear[equipSlot]
        local link = gear and gear.link

        if visual then
            if link and link ~= "" then
                visual.slot:SetHidden(true)
                visual.icon:SetTexture(GetItemLinkIcon(link))
                visual.icon:SetColor(unpack(MHCWL.UI_COLORS.white)) -- reset tint
                visual.icon:SetHidden(false)

                visual.hitbox.itemLink = link
                visual.hitbox.tooltipText = nil
            else
                visual.slot:SetHidden(false)
                visual.icon:SetHidden(true)

                visual.hitbox.itemLink = nil
                visual.hitbox.tooltipText = GetString(MHCWL_TOOLTIP_EMPTY_GEAR)
            end
        end
        if visual and visual.warning then
            local hasWarning = false

            for _, warningSlot in ipairs(warnings.missingGear) do
                if warningSlot == equipSlot then
                    hasWarning = true
                    break
                end
            end

            local tooltipLines = {}

            local function AddSectionHeader(text)
                if #tooltipLines > 0 then
                    table.insert(tooltipLines, "")
                end

                table.insert(tooltipLines, text)
            end

            if hasWarning then
                if MHCWL.AreTutorialTooltipsEnabled() then
                    table.insert(
                        tooltipLines,
                        "|cFFFF66" .. GetString(MHCWL_WARNING_TOOLTIP_TITLE) .. "|r"
                    )
                    table.insert(tooltipLines, "")
                end

                table.insert(tooltipLines, GetString(MHCWL_WARNING_MISSING_GEAR))
                table.insert(tooltipLines, "- " .. MHCWL.SlotName(equipSlot))
            end

            visual.warning.tooltipText =
                hasWarning and table.concat(tooltipLines, "\n") or nil

            visual.warning:SetHidden(not hasWarning)
        end
    end

    local mainGear = setup.gear and setup.gear[EQUIP_SLOT_MAIN_HAND]
    local offGear = setup.gear and setup.gear[EQUIP_SLOT_OFF_HAND]

    local mainLink = mainGear and mainGear.link
    local offLink = offGear and offGear.link

    if mainLink and mainLink ~= "" and (not offLink or offLink == "") then
        if MHCWL.IsTwoHandedWeaponLink(mainLink) then
            local visual = MHCWL.inspectWindow.gearVisual.offHand

            local mainWeaponType = GetItemLinkWeaponType(mainLink)
            local mainWeaponName =
                mainWeaponType
                and MHCWL.CleanEsoName(GetString("SI_WEAPONTYPE", mainWeaponType))
                or GetString(MHCWL_INSPECT_TEXT_TWO_HANDED_WEAPON)

            visual.slot:SetHidden(true)
            visual.icon:SetTexture(GetItemLinkIcon(mainLink))
            visual.icon:SetColor(unpack(MHCWL.UI_COLORS.blockedSlotRed))
            visual.icon:SetHidden(false)

            visual.hitbox.itemLink = nil
            visual.hitbox.tooltipText =
                GetString(MHCWL_INSPECT_TEXT_BLOCKED)
                .. tostring(mainWeaponName)
        end
    end

    local companionLevel = 0

    if GetActiveCompanionLevelInfo then
        companionLevel = select(1, GetActiveCompanionLevelInfo()) or 0
    end

    for _, slotIndex in ipairs(MHCWL.COMPANION_SKILL_SLOTS) do
        local abilityId = setup.skills and setup.skills[slotIndex] or 0

        if MHCWL.ShouldShowSlot7InUltimate() and slotIndex == 8 then
            abilityId = setup.skills and setup.skills[7] or 0
        end

        local row = MHCWL.inspectWindow.skillRows[slotIndex]

        local unlockLevel = MHCWL.SKILL_SLOT_UNLOCK_LEVELS[slotIndex] or 1

        local slotLocked =
            companionLevel < unlockLevel
            and not (MHCWL.ShouldShowSlot7InUltimate() and slotIndex == 8)

        if slotLocked then
            row.icon:SetHidden(true)
            row.emptyBG:SetHidden(true)
            row.lockedBG:SetHidden(false)
            row.lockedOverlay:SetHidden(false)

            row.hitbox.abilityId = nil
            row.hitbox.tooltipText = zo_strformat(
                                        GetString(MHCWL_TOOLTIP_LOCKED_LEVEL),
                                        unlockLevel
                                    )
        elseif abilityId and abilityId > 0 then
            row.icon:SetTexture(GetAbilityIcon(abilityId))
            row.icon:SetHidden(false)
            row.emptyBG:SetHidden(true)
            row.lockedBG:SetHidden(true)
            row.lockedOverlay:SetHidden(true)

            row.hitbox.abilityId = abilityId
            row.hitbox.tooltipText = nil
        else
            row.icon:SetHidden(true)
            row.emptyBG:SetHidden(false)
            row.lockedBG:SetHidden(true)
            row.lockedOverlay:SetHidden(true)

            row.hitbox.abilityId = nil
            row.hitbox.tooltipText = GetString(MHCWL_TOOLTIP_EMPTY_SKILL)
        end

        row.label:SetText(MHCWL.GetDisplaySkillSlotName(slotIndex))
        if row.warning then
            local hasWarning = false

            for _, warningSlot in ipairs(warnings.lockedSkillSlots) do
                if warningSlot == slotIndex then
                    hasWarning = true
                    break
                end
            end

            if warnings.invalidSkillsBySlot[slotIndex]
            or warnings.lockedSkillLinesBySlot[slotIndex] then
                hasWarning = true
            end

            local tooltipLines = {}

            local function AddSectionHeader(text)
                if #tooltipLines > 0 then
                    table.insert(tooltipLines, "")
                end

                table.insert(tooltipLines, text)
            end

            if hasWarning then
                if MHCWL.AreTutorialTooltipsEnabled() then
                    table.insert(
                        tooltipLines,
                        "|cFFFF66" .. GetString(MHCWL_WARNING_TOOLTIP_TITLE) .. "|r"
                    )
                end

                for _, warningSlot in ipairs(warnings.lockedSkillSlots) do
                    if warningSlot == slotIndex then
                        AddSectionHeader(GetString(MHCWL_WARNING_LOCKED_SKILL_SLOTS))
                        table.insert(tooltipLines, "- " .. MHCWL.GetDisplaySkillSlotName(slotIndex))
                        break
                    end
                end

                local invalidAbilityId = warnings.invalidSkillsBySlot[slotIndex]
                if invalidAbilityId then
                    AddSectionHeader(GetString(MHCWL_WARNING_INVALID_SKILLS))
                    table.insert(tooltipLines, "- " .. tostring(invalidAbilityId))
                end

                local lockedAbilityId = warnings.lockedSkillLinesBySlot[slotIndex]
                if lockedAbilityId then
                    local info = MHCWL.GetCompanionSkillLineInfo(lockedAbilityId)

                    AddSectionHeader(GetString(MHCWL_WARNING_LOCKED_SKILL_LINES))

                    if info then
                        table.insert(tooltipLines, "- " .. tostring(info.skillLine) .. ":")
                        table.insert(tooltipLines, "    " .. tostring(info.ability))
                    else
                        table.insert(tooltipLines, "- " .. tostring(lockedAbilityId))
                    end
                end
            end

            row.warning.tooltipText = hasWarning and table.concat(tooltipLines, "\n") or nil

            row.warning:SetHidden(not hasWarning)
        end
    end
end

function MHCWL.InspectLoadoutHasMissingGear()
    if not MHCWL.inspectIndex then return false end

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return false end

    local setup = companionData.setups[MHCWL.inspectIndex]
    if not setup then return false end

    local warnings = MHCWL.GetSetupWarnings(setup)

    return warnings.missingGear
        and #warnings.missingGear > 0
end