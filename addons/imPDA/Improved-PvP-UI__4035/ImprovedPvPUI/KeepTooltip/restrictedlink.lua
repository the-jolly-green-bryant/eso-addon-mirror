local LKT = LibKeepTooltip
local BORDER = 8

local originalCreator = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_RESTRICTED_LINK_ALDMERI_DOMINION].creator
local function newCreator(pin)
    local tooltip = ZO_WorldMap_GetTooltipForMode(ZO_MAP_TOOLTIP_MODE.KEEP)
    tooltip:Reset()

    local alliance = pin:GetRestrictedAlliance()
    local allianceName = GetAllianceName(alliance)

    tooltip.keepName = zo_strformat(SI_TOOLTIP_ALLIANCE_RESTRICTED_LINK, allianceName)
    tooltip.alliance = alliance

    LKT.callbacks[LKT.INGRIDIENTS.HEADER](tooltip)

    tooltip.width = tooltip.width + BORDER * 2
    tooltip.height = tooltip.height + BORDER * 2

    tooltip:SetDimensions(tooltip.width, tooltip.height)
end


ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_RESTRICTED_LINK_ALDMERI_DOMINION].creator = newCreator
ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_RESTRICTED_LINK_ALDMERI_DOMINION].tooltip = ZO_MAP_TOOLTIP_MODE.KEEP
ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_RESTRICTED_LINK_EBONHEART_PACT].creator = newCreator
ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_RESTRICTED_LINK_EBONHEART_PACT].tooltip = ZO_MAP_TOOLTIP_MODE.KEEP
ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_RESTRICTED_LINK_DAGGERFALL_COVENANT].creator = newCreator
ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_RESTRICTED_LINK_DAGGERFALL_COVENANT].tooltip = ZO_MAP_TOOLTIP_MODE.KEEP
