-- ESO Adventurer Suite
-- v0.29.481 - independent Character/Companion stats positions plus corrected
-- companion interaction-camera framing for the dedicated left-side gear ring.

local EPC = ESOProgressionCoach
if not EPC or not EPC.CharacterGearScreen then return end

local G = EPC.CharacterGearScreen

local function RootDimensions029481()
    local w, h = 1920, 1080
    if GuiRoot and GuiRoot.GetDimensions then
        local ok, rw, rh = pcall(GuiRoot.GetDimensions, GuiRoot)
        if ok and tonumber(rw) and tonumber(rh) and rw > 0 and rh > 0 then
            w, h = rw, rh
        end
    end
    return w, h
end

local function SaveStatsCardPosition029481(panel)
    if not panel or not EPC.saved then return end
    local left = panel.GetLeft and tonumber(panel:GetLeft()) or nil
    local top = panel.GetTop and tonumber(panel:GetTop()) or nil
    if not left or not top then return end

    if panel.easIsCompanion029480 == true then
        EPC.saved.characterGearCompanionStatsX029480 = left
        EPC.saved.characterGearCompanionStatsY029480 = top
        EPC.saved.characterGearCompanionStatsMoved029480 = true
    else
        EPC.saved.characterGearStatsX029355 = left
        EPC.saved.characterGearStatsY029355 = top
        EPC.saved.characterGearStatsMoved029355 = true
    end
end

local function InstallIndependentStatsDrag029481(panel)
    if not panel or panel._easIndependentStatsDrag029481 then return end
    panel._easIndependentStatsDrag029481 = true

    panel:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and control.StartMoving then control:StartMoving() end
    end)
    panel:SetHandler("OnMouseUp", function(control, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if control.StopMovingOrResizing then control:StopMovingOrResizing() end
        SaveStatsCardPosition029481(control)
    end)
end

local function ReanchorStatsCard029481(panel, isCompanion)
    if not panel or not EPC.saved then return end
    panel.easIsCompanion029480 = isCompanion == true
    InstallIndependentStatsDrag029481(panel)

    local w, h = RootDimensions029481()
    local cardH = panel.GetHeight and tonumber(panel:GetHeight()) or 540
    local moved, x, y
    if isCompanion then
        moved = EPC.saved.characterGearCompanionStatsMoved029480 == true
        x = moved and tonumber(EPC.saved.characterGearCompanionStatsX029480) or nil
        y = moved and tonumber(EPC.saved.characterGearCompanionStatsY029480) or nil
    else
        moved = EPC.saved.characterGearStatsMoved029355 == true
        x = moved and tonumber(EPC.saved.characterGearStatsX029355) or nil
        y = moved and tonumber(EPC.saved.characterGearStatsY029355) or nil
    end

    panel:ClearAnchors()
    if x and y then
        panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    else
        -- Character keeps the historic far-left default. Companion gets its own
        -- safe default near the center divider but outside the gear/model ring.
        local defaultX = isCompanion and math.floor(w * 0.505) or 22
        local defaultY = isCompanion and math.max(150, h * 0.36) or math.max(56, (h-cardH)*0.46 - 22)
        panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, defaultX, defaultY)
    end
end

if type(G.RefreshGearStatsCard) == "function" and not G._independentStatsPosition029481 then
    local RefreshGearStatsCardBase029481 = G.RefreshGearStatsCard
    function G:RefreshGearStatsCard(isCompanion, ...)
        local result = RefreshGearStatsCardBase029481(self, isCompanion, ...)
        if self.gearStatsCard then ReanchorStatsCard029481(self.gearStatsCard, isCompanion == true) end
        return result
    end
    G._independentStatsPosition029481 = true
end

local function ApplyCompanionInteractionFraming029481(layout)
    if type(SetFrameInteractionTarget) ~= "function" or type(NormalizeUICanvasPoint) ~= "function" then return false end

    local w, h = RootDimensions029481()
    layout = layout or G.currentLayout or (G.BuildAdaptiveLayout and G:BuildAdaptiveLayout(true))
    if not layout then return false end

    local targetX = tonumber(layout.centerX) or (w * 0.25)
    local targetY = tonumber(layout.centerY) or (h * 0.50)
    targetY = targetY + math.max(4, h * 0.012)

    local okDesired, desiredX, desiredY = pcall(NormalizeUICanvasPoint, targetX, targetY)
    if not okDesired or desiredX == nil or desiredY == nil then return false end

    -- IMPORTANT: ESO's Companion Character scene uses
    -- FRAME_INTERACTION_STANDARD_RIGHT_PANEL_MEDIUM_LEFT_PANEL_FRAGMENT.
    -- The previous patch incorrectly used the plain standard-right-panel
    -- baseline, leaving the companion model offset even though the gear moved.
    local baseX, baseY = 0.5, 0.5
    local mediumLeft = rawget(_G, "ZO_SharedMediumLeftPanelBackground")
    local rightBg = rawget(_G, "ZO_SharedRightBackground")
    local topBg = rawget(_G, "ZO_TopBarBackground")
    local keybindBg = rawget(_G, "ZO_KeybindStripMungeBackgroundTexture")

    if mediumLeft and rightBg and topBg and keybindBg
        and mediumLeft.GetRight and rightBg.GetLeft and topBg.GetBottom and keybindBg.GetTop then
        local okBase, normalizedBaseX, normalizedBaseY = pcall(function()
            local bx = zo_lerp(mediumLeft:GetRight(), rightBg:GetLeft(), 0.45)
            local by = zo_lerp(topBg:GetBottom(), keybindBg:GetTop(), 0.55)
            return NormalizeUICanvasPoint(bx, by)
        end)
        if okBase and normalizedBaseX ~= nil and normalizedBaseY ~= nil then
            baseX, baseY = normalizedBaseX, normalizedBaseY
        end
    end

    -- Same conversion used by ESO's ZO_InteractionFramingFragment, now against
    -- the correct Companion scene baseline.
    local frameX = 0.5 - baseX + desiredX
    local frameY = 0.5 - baseY + desiredY
    pcall(SetFrameInteractionTarget, frameX, frameY)
    return true
end

function G:ApplyCompanionCamera029481(layout)
    local applied = ApplyCompanionInteractionFraming029481(layout)
    if applied and type(zo_callLater) == "function" then
        local expectedLayout = layout
        for _, delay in ipairs({0, 35, 90}) do
            zo_callLater(function()
                if G and G.IsCompanionSceneShowing and G:IsCompanionSceneShowing() then
                    ApplyCompanionInteractionFraming029481(expectedLayout or G.currentLayout)
                end
            end, delay)
        end
    end
end

if type(G.ApplyCompanionLayout) == "function" and not G._companionCameraCenter029481 then
    local ApplyCompanionLayoutBase029481 = G.ApplyCompanionLayout
    function G:ApplyCompanionLayout(...)
        local result = ApplyCompanionLayoutBase029481(self, ...)
        self:ApplyCompanionCamera029481(self.currentLayout)
        return result
    end
    G._companionCameraCenter029481 = true
end

if type(G.CleanupCompanionScene) == "function" and not G._companionCameraCleanup029481 then
    local CleanupCompanionSceneBase029481 = G.CleanupCompanionScene
    function G:CleanupCompanionScene(...)
        local result = CleanupCompanionSceneBase029481(self, ...)
        if type(SetFrameInteractionTarget) == "function" then pcall(SetFrameInteractionTarget, 0.5, 0.5) end
        return result
    end
    G._companionCameraCleanup029481 = true
end

if type(G.ResetDefaults) == "function" and not G._companionStatsReset029481 then
    local ResetDefaultsBase029481 = G.ResetDefaults
    function G:ResetDefaults(...)
        local result = ResetDefaultsBase029481(self, ...)
        if EPC.saved then
            EPC.saved.characterGearCompanionStatsX029480 = nil
            EPC.saved.characterGearCompanionStatsY029480 = nil
            EPC.saved.characterGearCompanionStatsMoved029480 = nil
        end
        return result
    end
    G._companionStatsReset029481 = true
end
