local OSF = OutfitStylesFavorites

-- Checkbox.lua
-- Creates the "Show Favorites" checkbox in the outfit styles panel header,
-- placed on the same row as the existing "Show Locked" checkbox.
--
-- Layout strategy
-- ---------------
-- ShowLocked is a 16×16 ZO_CheckButton whose LEFT is anchored to the panel's left
-- edge (constrains X) and whose Y is anchored to TypeFilter (constrains Y).
-- Its label extends to the right of the button.
--
-- ShowFavorites is initially anchored LEFT to ShowLocked RIGHT + ANCHOR_OFFSET as a
-- placeholder.  On the panel's first show (SCENE_FRAGMENT_SHOWING), the placeholder is
-- replaced with an offset computed from the actual virtual-pixel width of the localized
-- "Show Locked" string, and both label wraps are set geometrically.

-- Initial placeholder offset (px) from ShowLocked button's right to ShowFavorites left.
-- This is replaced at first show with a value derived from the live label width.
local ANCHOR_OFFSET = 130

-- Gap between a ZO_CheckButton's right edge and the start of its label
-- (matches the hard-coded offset in ZO_CheckButton_SetLabelText).
local LABEL_GAP = 5
-- Visual breathing room between ShowLocked's label end and ShowFavorites button.
local VISUAL_GAP = 10

function OSF:InitializeCheckbox()
    local panel      = ZO_OUTFIT_STYLES_PANEL_KEYBOARD
    local showLocked = panel.showLockedCheckBox
    local typeFilter = panel.typeFilterControl

    -- 1. Create the checkbox from the base-game ZO_CheckButton virtual template.
    local checkBox = CreateControlFromVirtual("OutfitStylesFavorites_ShowFavorites", panel.control, "ZO_CheckButton")
    checkBox:ClearAnchors()
    -- Placeholder anchor; corrected to a measured offset on first show.
    -- Y inherits showLocked's vertical center so both sit on the same baseline.
    checkBox:SetAnchor(LEFT, showLocked, RIGHT, ANCHOR_OFFSET, 0)

    -- 2. Wire the toggle: flip OSF.showFavorites and rebuild the grid.
    ZO_CheckButton_SetToggleFunction(checkBox, function(_, checked)
        OSF.showFavorites = checked
        panel:RefreshVisible()
    end)

    -- 3. Label and initial state.
    ZO_CheckButton_SetLabelText(checkBox, GetString(SI_OSF_SHOW_FAVORITES))
    ZO_CheckButton_SetCheckState(checkBox, false)

    -- 4. Conservative initial wrap for ShowLocked (avoids visual overflow before first show).
    ZO_CheckButton_SetLabelWrapMode(showLocked, TEXT_WRAP_MODE_ELLIPSIS, ANCHOR_OFFSET - LABEL_GAP - VISUAL_GAP)

    -- 5. Recalculate both label wraps once real screen coordinates are available.
    local adjusted = false
    KEYBOARD_OUTFIT_STYLES_PANEL_FRAGMENT:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_FRAGMENT_SHOWING and not adjusted then
            adjusted = true

            -- GetStringWidthScaled measures the natural (untruncated) width of the
            -- localized string at the checkbox label font (ZoFontGameBold, from
            -- buttontemplates.xml), in virtual pixels (scale=1, SPACE_INTERFACE).
            -- GetTextWidth() would return the width of the already-ellipsized text set
            -- by the conservative step-4 wrap, producing a too-narrow offset for long
            -- localized strings (e.g. Russian "Показывать заблокированное").
            local lockedTextWidth = GetStringWidthScaled(ZoFontGameBold, GetString(SI_RESTYLE_SHOW_LOCKED), 1, SPACE_INTERFACE)
            local offset = LABEL_GAP + lockedTextWidth + VISUAL_GAP

            checkBox:ClearAnchors()
            checkBox:SetAnchor(LEFT, showLocked, RIGHT, offset, 0)

            -- ShowLocked label: space between its button right and ShowFavorites left.
            local lockedLabelWidth = checkBox:GetLeft() - showLocked:GetRight() - LABEL_GAP
            if lockedLabelWidth > 0 then
                ZO_CheckButton_SetLabelWrapMode(showLocked, TEXT_WRAP_MODE_ELLIPSIS, lockedLabelWidth)
            end

            -- ShowFavorites label: from its button right to TypeFilter left, minus gaps.
            local favLabelWidth = typeFilter:GetLeft() - checkBox:GetRight() - LABEL_GAP - VISUAL_GAP
            if favLabelWidth > 0 then
                ZO_CheckButton_SetLabelWrapMode(checkBox, TEXT_WRAP_MODE_ELLIPSIS, favLabelWidth)
            end
        end
    end)

    OSF.showFavoritesCheckBox = checkBox
end
