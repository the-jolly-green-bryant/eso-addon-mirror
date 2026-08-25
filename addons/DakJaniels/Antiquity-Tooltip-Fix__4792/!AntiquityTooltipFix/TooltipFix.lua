-- Temporary workaround until ZOS ships DynamicAnchorLayout fix in EsoUI/Libraries/ZO_Templates/Tooltip.lua.
-- Replaces the local comparison-anchor table, UpdateComparisonDynamicAnchors, and
-- ZO_Tooltips_SetupDynamicTooltipAnchors so the 0ms update and StartWatching share one table.
-- U51 (101051) is expected to include the game fix.

if GetAPIVersion() > 101050 then
    return
end

local QUAD_TOPLEFT = 1
local QUAD_TOPRIGHT = 2
local QUAD_BOTTOMRIGHT = 3
local QUAD_BOTTOMLEFT = 4

local OFFSET_FROM_OWNER = 4
local BETWEEN_TOOLTIP_OFFSET_X = 20

local function CalculateQuandrant(ownerMiddleX, ownerMiddleY, middleScreenX, middleScreenY)
    if ownerMiddleX >= middleScreenX and ownerMiddleY < middleScreenY then
        return QUAD_TOPRIGHT
    elseif ownerMiddleX >= middleScreenX and ownerMiddleY >= middleScreenY then
        return QUAD_BOTTOMRIGHT
    elseif ownerMiddleX < middleScreenX and ownerMiddleY >= middleScreenY then
        return QUAD_BOTTOMLEFT
    end

    return QUAD_TOPLEFT
end

local function ValidateComparativeTooltip(comparativeTooltip)
    if comparativeTooltip and not comparativeTooltip:IsHidden() then
        return comparativeTooltip
    end
    return nil
end

local StartWatchingComparisonDynamicAnchor
do
    local g_comparisonDynamicAnchors = {}

    local function DynamicAnchorLayout(tooltip, owner, quadrant, comparativeTooltip1, comparativeTooltip2, relativeAnchorsUsed)
        local isValid, point, relativeTo, relativePoint, offsetX, offsetY = tooltip:GetAnchor()
        local anchorTooltipsLeftward = (relativeAnchorsUsed and isValid and ZO_FlagHelpers.MaskHasFlag(point, RIGHT)) or
                                     (not relativeAnchorsUsed and quadrant and (quadrant == QUAD_TOPRIGHT or quadrant == QUAD_BOTTOMRIGHT))
    
        if comparativeTooltip1 and comparativeTooltip2 then
            if anchorTooltipsLeftward then
                comparativeTooltip1:SetOwner(tooltip, TOPRIGHT, -BETWEEN_TOOLTIP_OFFSET_X, 0)
                comparativeTooltip2:SetOwner(comparativeTooltip1, TOPRIGHT, -BETWEEN_TOOLTIP_OFFSET_X, 0, TOPLEFT)
            else
                comparativeTooltip1:SetOwner(tooltip, TOPLEFT, BETWEEN_TOOLTIP_OFFSET_X, 0)
                comparativeTooltip2:SetOwner(comparativeTooltip1, TOPLEFT, BETWEEN_TOOLTIP_OFFSET_X, 0, TOPRIGHT)
            end
    
            comparativeTooltip1:SetClampedToScreenInsets(0, comparativeTooltip1.topClampedToScreenInset, 0, 0)
            comparativeTooltip2:SetClampedToScreenInsets(0, comparativeTooltip2.topClampedToScreenInset, 0, 0)
        elseif comparativeTooltip1 then
            if anchorTooltipsLeftward then
                comparativeTooltip1:SetOwner(tooltip, TOPRIGHT, -BETWEEN_TOOLTIP_OFFSET_X, 0)
            else
                comparativeTooltip1:SetOwner(tooltip, TOPLEFT, BETWEEN_TOOLTIP_OFFSET_X, 0)
            end
            comparativeTooltip1:SetClampedToScreenInsets(0, comparativeTooltip1.topClampedToScreenInset, 0, 0)
        end
    end    

    local function UpdateComparisonDynamicAnchors()
        for tooltip, anchorInfo in pairs(g_comparisonDynamicAnchors) do
            if tooltip:IsControlHidden() then
                g_comparisonDynamicAnchors[tooltip] = nil
            else
                DynamicAnchorLayout(tooltip, unpack(anchorInfo))
            end
        end
    end
    EVENT_MANAGER:RegisterForUpdate("UpdateComparisonDynamicAnchors", 0, UpdateComparisonDynamicAnchors)

    function StartWatchingComparisonDynamicAnchor(tooltip, owner, quadrant, comparativeTooltip1, comparativeTooltip2, relativeAnchorsUsed)
        if comparativeTooltip1 then
            g_comparisonDynamicAnchors[tooltip] = { owner, quadrant, comparativeTooltip1, comparativeTooltip2, relativeAnchorsUsed }
        else
            g_comparisonDynamicAnchors[tooltip] = nil
        end
    end
end

ZO_PreHook("ZO_Tooltips_SetupDynamicTooltipAnchors", function(tooltip, owner, comparativeTooltip1, comparativeTooltip2, useRelativeAnchors)
    if tooltip and owner then
        local quadrant = nil
        local relativeAnchorsUsed = false
        if useRelativeAnchors then
            local isValid, point, relativeTo, relativePoint, offsetX, offsetY = tooltip:GetAnchor()
            if isValid then
                tooltip:ClearAnchors()
                tooltip:SetOwner(owner, point, offsetX, offsetY, relativePoint)
                relativeAnchorsUsed = true
            end
        end

        if not relativeAnchorsUsed then
            local left, top, right, bottom = owner:GetScreenRect()
            local ownerScale = owner:GetScale()
            local ownerMiddleX = (left + right) / (2 * ownerScale)
            local ownerMiddleY = (top + bottom) / (2 * ownerScale)

            local screenWidth, screenHeight = GuiRoot:GetDimensions()
            local middleScreenX = screenWidth / 2
            local middleScreenY = screenHeight / 2

            quadrant = CalculateQuandrant(ownerMiddleX, ownerMiddleY, middleScreenX, middleScreenY)

            tooltip:ClearAnchors()
            if quadrant == QUAD_TOPLEFT or quadrant == QUAD_BOTTOMLEFT then
                tooltip:SetOwner(owner, LEFT, OFFSET_FROM_OWNER, 0)
            else
                tooltip:SetOwner(owner, RIGHT, -OFFSET_FROM_OWNER, 0)
            end
        end

        comparativeTooltip1 = ValidateComparativeTooltip(comparativeTooltip1)
        comparativeTooltip2 = ValidateComparativeTooltip(comparativeTooltip2)

        if comparativeTooltip2 and not comparativeTooltip1 then
            comparativeTooltip1 = comparativeTooltip2
            comparativeTooltip2 = nil
        end

        StartWatchingComparisonDynamicAnchor(tooltip, owner, quadrant, comparativeTooltip1, comparativeTooltip2, relativeAnchorsUsed)
    end
    return true
end)
