local OSF = OutfitStylesFavorites

-- Highlight.lua
-- Renders a gold-star badge on favorited style cells when "Show Favorites" is OFF.
-- Uses a dedicated CT_TEXTURE control anchored to TOPRIGHT so it never conflicts
-- with the ESO statusMultiIcon (eye, lock, etc.) that lives at TOPLEFT.
--
-- Hook: ZO_PostHook on RefreshGridEntryMultiIcon.
-- Controls are pooled → badge is created once per control and shown/hidden each refresh.

local FAVORITE_ICON  = "EsoUI/Art/Collections/Favorite_StarOnly.dds"
local BADGE_SIZE     = 24   -- matches visual weight of statusMultiIcon (24px)
local BADGE_INSET_X  = 3    -- mirrors statusMultiIcon's 3px inset from its corner
local BADGE_INSET_Y  = 3    -- aligns badge center (5+10=15) with eye icon center (3+12=15)

local function GetOrCreateFavoriteBadge(control)
    if control.osfFavoriteBadge then
        return control.osfFavoriteBadge
    end

    local badge = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    badge:SetDimensions(BADGE_SIZE, BADGE_SIZE)
    badge:SetTexture(FAVORITE_ICON)
    badge:SetDrawLayer(DL_OVERLAY)
    badge:SetMouseEnabled(false)
    badge:SetAnchor(TOPRIGHT, control, TOPRIGHT, -BADGE_INSET_X, BADGE_INSET_Y)
    badge:SetHidden(true)

    control.osfFavoriteBadge = badge
    return badge
end

function OSF:RefreshFavoriteBadge(control, data)
    local badge = GetOrCreateFavoriteBadge(control)

    if OSF.showFavorites or data.isEmptyCell or data.clearAction then
        badge:SetHidden(true)
        return
    end

    badge:SetHidden(not OSF:IsFavorite(data:GetId()))
end

function OSF:InitializeHighlight()
    ZO_PostHook(ZO_OUTFIT_STYLES_PANEL_KEYBOARD, "RefreshGridEntryMultiIcon",
        function(_, control, data)
            OSF:RefreshFavoriteBadge(control, data)
        end
    )
end
