-- ESO Adventurer Suite
-- Group Finder compact-tooltip wrapping/auto-height polish.
-- Loaded after GroupFinderTooltipPositionFix.lua.

local EPC = ESOProgressionCoach
local GF = EPC and EPC.GroupFinderPlus
if not GF or GF._tooltipWrapFix029694 then return end
GF._tooltipWrapFix029694 = true

local baseEnsure = GF.EnsureCompactListingTooltip029693
local baseShow = GF.ShowCompactListingTooltip029693

if type(baseEnsure) == "function" then
    function GF:EnsureCompactListingTooltip029693()
        local tip = baseEnsure(self)
        if not tip then return tip end

        local title = tip.easTitle029693
        local body = tip.easBody029693

        if title then
            if type(title.SetMaxLineCount) == "function" then title:SetMaxLineCount(2) end
            title:SetDimensions(276, 52)
        end

        if body then
            -- ESO labels default to a very small line count in some contexts.
            -- Explicitly allow multi-line wrapping so long owner/category/detail
            -- values do not get clipped into a single ellipsized line.
            if type(body.SetMaxLineCount) == "function" then body:SetMaxLineCount(48) end
            body:SetWidth(276)
        end

        return tip
    end
end

function GF:PositionWrappedListingTooltip029694(anchorControl)
    local tip = self:EnsureCompactListingTooltip029693()
    if not tip or not GuiRoot then return end

    local screenW = tonumber(GuiRoot:GetWidth()) or 1920
    local screenH = tonumber(GuiRoot:GetHeight()) or 1080
    local anchorLeft = anchorControl and tonumber(anchorControl:GetLeft()) or (screenW * 0.68)
    local anchorTop = anchorControl and tonumber(anchorControl:GetTop()) or (screenH * 0.25)

    local width = tonumber(tip:GetWidth()) or 300
    local height = tonumber(tip:GetHeight()) or 410

    -- Keep the right edge beside the Group Finder navigation strip. This leaves
    -- the tabs readable while avoiding an unnecessary shift over the character.
    local rightEdge = anchorLeft - 265
    local left = rightEdge - width
    local characterSafeLeft = screenW * 0.31
    if left < characterSafeLeft then left = characterSafeLeft end
    if left + width > screenW - 20 then left = screenW - width - 20 end

    local top = math.max(78, anchorTop - 105)
    if top + height > screenH - 45 then
        top = math.max(38, screenH - height - 45)
    end

    tip:ClearAnchors()
    tip:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

if type(baseShow) == "function" then
    function GF:ShowCompactListingTooltip029693(anchorControl, data)
        baseShow(self, anchorControl, data)

        local tip = self.compactListingTooltip029693
        if not tip then return end

        local body = tip.easBody029693
        if body then
            if type(body.SetMaxLineCount) == "function" then body:SetMaxLineCount(48) end

            -- GetTextHeight resolves the wrapped label height immediately in ESO.
            local textHeight = type(body.GetTextHeight) == "function" and tonumber(body:GetTextHeight()) or 325
            textHeight = math.max(60, math.min(textHeight or 325, 650))
            body:SetHeight(textHeight)

            -- 11 top + 52 title + 4 divider gap + 1 divider + 8 body gap
            -- + wrapped body + 13 bottom padding.
            tip:SetHeight(89 + textHeight)
        end

        self:PositionWrappedListingTooltip029694(anchorControl)
    end
end

EPC.groupFinderTooltipWrapFix029694 = true
