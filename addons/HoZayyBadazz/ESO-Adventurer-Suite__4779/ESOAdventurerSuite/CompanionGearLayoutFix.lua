-- ESO Adventurer Suite
-- v0.29.481 - companion gear ring geometry correction
-- Keeps the companion on a dedicated left-side canvas and places every gear
-- slot around that canvas instead of allowing the right column to cross the
-- companion model or ESO's native right-side information panel.

local EPC = ESOProgressionCoach
if not EPC or not EPC.CharacterGearScreen then return end

local G = EPC.CharacterGearScreen

local function Clamp029481(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

-- Dedicated companion canvas. Player Character geometry is left untouched.
if type(G.BuildAdaptiveLayout) == "function" and not G._companionLeftCanvas029481 then
    local BuildAdaptiveLayoutBase029481 = G.BuildAdaptiveLayout
    function G:BuildAdaptiveLayout(isCompanion)
        local layout = BuildAdaptiveLayoutBase029481(self, isCompanion)
        if not isCompanion or type(layout) ~= "table" then return layout end

        local w = tonumber(layout.w) or 1920
        local h = tonumber(layout.h) or 1080
        local scale = tonumber(layout.scale) or 1

        -- The model + gear ring owns the left half only. The visual center is
        -- deliberately left of screen center because ESO's Companion details,
        -- Equipment and Rapport content occupy the right half.
        layout.centerX = w * 0.25
        layout.centerY = h * 0.50
        layout.safeLeft = math.max(18, w * 0.025)
        layout.safeRight = math.min(w * 0.515, w - 24)
        layout.available = math.max(680 * scale, layout.safeRight - layout.safeLeft)

        -- The old ~200px spread put Necklace/Cuirass/Girdle directly over the
        -- companion. Use a true outer ring at normal 16:9 resolutions.
        layout.spread = Clamp029481(w * 0.155, 225 * scale, 285 * scale)
        layout.labelWidth = Clamp029481(190 * math.max(scale, 0.90), 165, 205)

        -- Five armor/jewelry rows stay vertically wrapped around the model.
        layout.rowStep = Clamp029481(132 * scale, 104, 145)
        layout.topY = -(2 * layout.rowStep) - (92 * scale)

        -- Main/off hand form a compact row below the companion, not inside the
        -- native right-side panel.
        layout.weaponY = Clamp029481(h * 0.315, 292, 352)
        return layout
    end
    G._companionLeftCanvas029481 = true
end

-- Explicitly re-anchor Companion slots after the legacy renderer runs. This is
-- intentional: CharacterGearScreen.lua still contains an older companion-only
-- right-column -34px correction that was correct for the previous layout but
-- now pulls the gear back onto the model. These final anchors are canonical.
if type(G.ApplySlotLayout) == "function" and not G._companionSlotRing029481 then
    local ApplySlotLayoutBase029481 = G.ApplySlotLayout
    function G:ApplySlotLayout(slotData, slotSize, scale, isCompanion)
        if not isCompanion or type(slotData) ~= "table" then
            return ApplySlotLayoutBase029481(self, slotData, slotSize, scale, isCompanion)
        end

        local result = ApplySlotLayoutBase029481(self, slotData, slotSize, scale, true)
        local control = slotData.control and rawget(_G, slotData.control) or nil
        local layout = self.currentLayout or (self.BuildAdaptiveLayout and self:BuildAdaptiveLayout(true))
        if not control or not layout then return result end

        local x, y
        if slotData.weaponCol ~= nil then
            local slotPx = (tonumber(slotSize) or 68) * (tonumber(scale) or 1)
            local gap = slotPx + math.max(36, 48 * (tonumber(scale) or 1))
            x = layout.centerX + (tonumber(slotData.weaponCol) or 0) * gap * 0.70
            y = layout.centerY + layout.weaponY
        else
            local rowBySlot = {
                [EQUIP_SLOT_HEAD]=0, [EQUIP_SLOT_NECK]=0,
                [EQUIP_SLOT_SHOULDERS]=1, [EQUIP_SLOT_CHEST]=1,
                [EQUIP_SLOT_HAND]=2, [EQUIP_SLOT_WAIST]=2,
                [EQUIP_SLOT_RING1]=3, [EQUIP_SLOT_RING2]=3,
                [EQUIP_SLOT_LEGS]=4, [EQUIP_SLOT_FEET]=4,
            }
            local row = rowBySlot[slotData.slot] or 2
            local sideSign = (tonumber(slotData.x) or 0) < 0 and -1 or 1
            x = layout.centerX + sideSign * layout.spread
            y = layout.centerY + layout.topY + row * layout.rowStep
        end

        if control.SetScale then control:SetScale(1) end
        if control.ClearAnchors then control:ClearAnchors() end
        if control.SetAnchor then control:SetAnchor(CENTER, GuiRoot, TOPLEFT, x, y) end
        if control.SetDimensions then
            local px = (tonumber(slotSize) or 68) * (tonumber(scale) or 1)
            control:SetDimensions(px, px)
        end
        if control.SetHidden then control:SetHidden(false) end

        -- Refresh labels after the final anchor so all external text follows the
        -- corrected slot position without stale coordinates from the old ring.
        if self.RefreshSlot then self:RefreshSlot(slotData, true) end
        return result
    end
    G._companionSlotRing029481 = true
end

if G.IsCompanionSceneShowing and G:IsCompanionSceneShowing() and G.RequestRefresh then
    G:RequestRefresh(0)
end
