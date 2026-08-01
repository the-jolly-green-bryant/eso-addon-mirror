local CS = ClearSight

local function MakeBar(name, parent, layer)
    local control = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    control:SetDrawLayer(layer or DL_OVERLAY)
    control:SetCenterColor(1, 1, 1, 1)
    control:SetEdgeColor(0, 0, 0, 0)
    return control
end

local function SetColor(control, color)
    control:SetCenterColor(color[1], color[2], color[3], color[4] or 1)
end

function CS:InitializeReticle()
    local root = WINDOW_MANAGER:CreateTopLevelWindow("ClearSightReticle")
    root:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    root:SetDimensions(140, 140)
    root:SetMouseEnabled(false)
    root:SetClampedToScreen(true)
    root:SetDrawTier(DT_HIGH)

    self.reticleRoot = root
    self.reticleBars = {}
    self.reticleOutlineBars = {}
    self.reticleBrackets = {}

    local names = { "Left", "Right", "Top", "Bottom" }
    for _, n in ipairs(names) do
        self.reticleOutlineBars[n] = MakeBar("ClearSightReticleOutline" .. n, root, DL_BACKGROUND)
        self.reticleBars[n] = MakeBar("ClearSightReticle" .. n, root, DL_OVERLAY)
    end

    for i = 1, 8 do
        self.reticleBrackets[i] = MakeBar("ClearSightReticleBracket" .. i, root, DL_OVERLAY)
    end

    EVENT_MANAGER:RegisterForEvent(self.name .. "_ReticleHidden", EVENT_RETICLE_HIDDEN_UPDATE, function()
        self:UpdateReticle()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "_ReticleTarget", EVENT_RETICLE_TARGET_CHANGED, function()
        self:UpdateReticle()
    end)

    -- Update immediately when the unit under the reticle changes death state.
    -- The existing visual update loop remains responsible for normal reticle tracking;
    -- this event simply avoids waiting for the next visual tick on a confirmed death.
    if EVENT_UNIT_DEATH_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_ReticleDeath", EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag)
            if unitTag == "reticleover" then
                self:UpdateReticle()
            end
        end)
    end

    self:LayoutReticle()
end

function CS:LayoutReticle()
    if not self.reticleRoot then return end

    local s = self.saved.reticle
    local size = s.size
    local thickness = s.thickness
    local gap = s.gap
    local outline = s.outline

    local half = math.floor(size / 2)

    local function layoutPair(bars, extra)
        local t = thickness + extra * 2
        local g = math.max(0, gap - extra)

        bars.Left:ClearAnchors()
        bars.Left:SetDimensions(half - g, t)
        bars.Left:SetAnchor(RIGHT, self.reticleRoot, CENTER, -g, 0)

        bars.Right:ClearAnchors()
        bars.Right:SetDimensions(half - g, t)
        bars.Right:SetAnchor(LEFT, self.reticleRoot, CENTER, g, 0)

        bars.Top:ClearAnchors()
        bars.Top:SetDimensions(t, half - g)
        bars.Top:SetAnchor(BOTTOM, self.reticleRoot, CENTER, 0, -g)

        bars.Bottom:ClearAnchors()
        bars.Bottom:SetDimensions(t, half - g)
        bars.Bottom:SetAnchor(TOP, self.reticleRoot, CENTER, 0, g)
    end

    layoutPair(self.reticleOutlineBars, outline)
    layoutPair(self.reticleBars, 0)

    for _, bar in pairs(self.reticleOutlineBars) do
        SetColor(bar, {0, 0, 0, 0.92})
    end

    -- "Target acquired" corner brackets. These sit just outside the normal reticle.
    local r = half + 8
    local len = 14
    local bt = math.max(3, thickness)

    local bracketLayouts = {
        {1, len, bt, CENTER, -r, -r, TOPLEFT},
        {2, bt, len, CENTER, -r, -r, TOPLEFT},
        {3, len, bt, CENTER,  r, -r, TOPRIGHT},
        {4, bt, len, CENTER,  r, -r, TOPRIGHT},
        {5, len, bt, CENTER, -r,  r, BOTTOMLEFT},
        {6, bt, len, CENTER, -r,  r, BOTTOMLEFT},
        {7, len, bt, CENTER,  r,  r, BOTTOMRIGHT},
        {8, bt, len, CENTER,  r,  r, BOTTOMRIGHT},
    }

    for _, v in ipairs(bracketLayouts) do
        local bar = self.reticleBrackets[v[1]]
        bar:ClearAnchors()
        bar:SetDimensions(v[2], v[3])
        bar:SetAnchor(v[7], self.reticleRoot, v[4], v[5], v[6])
    end
end

function CS:GetReticleState()
    local unitTag = "reticleover"
    local hasReticleUnit = DoesUnitExist and DoesUnitExist(unitTag)

    if not hasReticleUnit then
        return "normal"
    end

    -- Death must win over reaction. A corpse can briefly retain the reaction it
    -- had while alive, so checking this first prevents a dead enemy staying red.
    if IsUnitDead and IsUnitDead(unitTag) then
        return "dead"
    end

    local reaction = GetUnitReaction and GetUnitReaction(unitTag) or nil

    if reaction == UNIT_REACTION_HOSTILE then
        return "hostile"
    elseif reaction == UNIT_REACTION_FRIENDLY
        or reaction == UNIT_REACTION_NPC_ALLY
        or reaction == UNIT_REACTION_PLAYER_ALLY
        or reaction == UNIT_REACTION_COMPANION then
        return "friendly"
    end

    -- Neutral units, attackable-but-not-hostile units, interactables and empty
    -- reticle space all use the normal white accessibility state.
    return "normal"
end

function CS:UpdateReticle()
    if not self.reticleRoot then return end

    local s = self.saved.reticle
    local hidden = (not s.enabled) or (IsReticleHidden and IsReticleHidden())
    self.reticleRoot:SetHidden(hidden)
    if hidden then return end

    local state = self:GetReticleState()
    local color = s.normalColor
    if state == "dead" then
        color = s.deadColor
    elseif state == "hostile" then
        color = s.hostileColor
    elseif state == "friendly" then
        color = s.friendlyColor
    end

    for _, bar in pairs(self.reticleBars) do
        SetColor(bar, color)
        bar:SetHidden(false)
    end

    for _, bar in pairs(self.reticleOutlineBars) do
        bar:SetHidden(false)
    end

    if state == "normal" then
        -- NORMAL / PASSIVE RETICLE:
        -- Leave a square opening in the centre for ESO's own reticle and
        -- stealth eye. The active/acquired and hostile layouts remain the
        -- original full cross.
        local size = s.size
        local thickness = s.thickness
        local outline = s.outline

        -- Wider than the standard centre gap so the game's native reticle can
        -- sit cleanly inside ClearSight without being covered.
        local normalGap = math.max(s.gap + 8, thickness * 3)
        local half = math.floor(size / 2)

        local function layoutNormal(bars, extra)
            local t = thickness + extra * 2
            local g = math.max(0, normalGap - extra)

            bars.Left:ClearAnchors()
            bars.Left:SetDimensions(math.max(1, half - g), t)
            bars.Left:SetAnchor(RIGHT, self.reticleRoot, CENTER, -g, 0)

            bars.Right:ClearAnchors()
            bars.Right:SetDimensions(math.max(1, half - g), t)
            bars.Right:SetAnchor(LEFT, self.reticleRoot, CENTER, g, 0)

            -- Remove the top bar entirely in the passive state.
            bars.Top:SetHidden(true)

            -- Drop the bottom bar by the same centre-gap distance used by
            -- the left/right bars, producing an open square around the eye.
            bars.Bottom:ClearAnchors()
            bars.Bottom:SetDimensions(t, math.max(1, half - g))
            bars.Bottom:SetAnchor(TOP, self.reticleRoot, CENTER, 0, g)
        end

        layoutNormal(self.reticleOutlineBars, outline)
        layoutNormal(self.reticleBars, 0)
    else
        -- FRIENDLY / HOSTILE / DEAD:
        -- Restore the original full-cross layout exactly as before.
        self:LayoutReticle()
        for _, bar in pairs(self.reticleBars) do
            SetColor(bar, color)
            bar:SetHidden(false)
        end
        for _, bar in pairs(self.reticleOutlineBars) do
            bar:SetHidden(false)
        end
    end

    local showBrackets = s.showAcquiredBrackets and state ~= "normal"
    for _, bar in ipairs(self.reticleBrackets) do
        bar:SetHidden(not showBrackets)
        if showBrackets then
            SetColor(bar, color)
        end
    end
end
