local RPR = RewardPopupsReworked

RPR.ActionWidget = {
    pendingSources = {},
}

local Widget = RPR.ActionWidget

local WIDGET_NAME = "RewardPopupsReworkedActionWidget"
local LEFT_BUTTON = MOUSE_BUTTON_INDEX_LEFT or 1
local RIGHT_BUTTON = MOUSE_BUTTON_INDEX_RIGHT or 2
local DEFAULT_ICON = "/RewardPopupsReworked/textures/action_widget.dds"
local DEFAULT_GLOW = "/RewardPopupsReworked/textures/glow.dds"
local DEFAULT_FRAME = "/RewardPopupsReworked/textures/silver_frame.dds"
local FADE_MS = 180
local GLINT_INTERVAL_MS = 6000
local GLINT_DURATION_MS = 420

function Widget:Initialize()
    -------------------------------------------------
    -- HUD-managed parent
    -------------------------------------------------

    local fragmentControl =
        WINDOW_MANAGER:CreateTopLevelWindow(WIDGET_NAME .. "FragmentControl")

    self.fragmentControl = fragmentControl

    fragmentControl:SetAnchorFill(GuiRoot)
    fragmentControl:SetMouseEnabled(false)
    fragmentControl:SetHidden(true)

    self.fragment =
        ZO_HUDFadeSceneFragment:New(fragmentControl)

    if HUD_SCENE then
        HUD_SCENE:AddFragment(self.fragment)
    end

    if HUD_UI_SCENE then
        HUD_UI_SCENE:AddFragment(self.fragment)
    end

    -------------------------------------------------
    -- Actual widget
    -------------------------------------------------

    local menuScene = SCENE_MANAGER
        and SCENE_MANAGER:GetScene("gameMenuInGame")

    if menuScene and menuScene.RegisterCallback then
        menuScene:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_HIDDEN
                and self.menuPreviewFragmentAdded then

                self:DisableMenuPreview()
            end
        end)
    end

    local control =
        WINDOW_MANAGER:CreateControl(
            WIDGET_NAME,
            fragmentControl,
            CT_CONTROL
        )

    self.control = control

    control:SetDimensions(64, 64)
    control:SetClampedToScreen(true)
    control:SetMouseEnabled(true)
    control:SetMovable(true)
    control:SetHidden(true)

    -------------------------------------------------
    -- Outer Glow (behind everything)
    -------------------------------------------------

    local glowOuter = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    self.glowOuter = glowOuter
    glowOuter:SetAnchor(CENTER, control, CENTER, 0, 0)
    glowOuter:SetDimensions(112, 112)
    glowOuter:SetTexture(DEFAULT_GLOW)
    glowOuter:SetColor(1, 1, 1, 1)
    glowOuter:SetAlpha(0.12)

    if glowOuter.SetBlendMode then
        glowOuter:SetBlendMode(TEX_BLEND_MODE_ADD)
    end

    -------------------------------------------------
    -- Inner Glow
    -------------------------------------------------

    local glow = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    self.glow = glow
    glow:SetAnchor(CENTER, control, CENTER, 0, 0)
    glow:SetDimensions(82, 82)
    glow:SetTexture(DEFAULT_GLOW)
    glow:SetColor(1, 1, 1, 1)
    glow:SetAlpha(0.28)

    if glow.SetBlendMode then
        glow:SetBlendMode(TEX_BLEND_MODE_ADD)
    end

    -------------------------------------------------
    -- Frame
    -------------------------------------------------

    local frame = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    self.frame = frame
    frame:SetAnchor(CENTER, control, CENTER, 0, 0)
    frame:SetDimensions(55, 55)
    frame:SetTexture(DEFAULT_FRAME)

    -------------------------------------------------
    -- Icon
    -------------------------------------------------

    local icon = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    self.icon = icon
    icon:SetAnchor(CENTER, control, CENTER, 0, 0)
    icon:SetDimensions(32, 32)
    icon:SetTexture(DEFAULT_ICON)

    -------------------------------------------------
    -- Glint Overlay
    -------------------------------------------------

    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    self.nextGlintTime = now + 1500
    self.glintStartTime = nil

    -------------------------------------------------
    -- Handlers
    -------------------------------------------------

    control:SetHandler("OnMouseEnter", function() self:ShowTooltip() end)
    control:SetHandler("OnMouseExit", function() self:HideTooltip() end)
    control:SetHandler("OnMouseDown", function(_, button) self:OnMouseDown(button) end)
    control:SetHandler("OnMouseUp", function(_, button) self:OnMouseUp(button) end)
    control:SetHandler("OnMoveStop", function() self:SavePosition() end)

    self:RestorePosition()
    self:RefreshLock()
end

function Widget:RestorePosition()
    local saved = RPR.savedVars and RPR.savedVars.widget or {}
    self.control:ClearAnchors()
    self.control:SetAnchor(CENTER,self.fragmentControl,CENTER,saved.x or 0,saved.y or 0)
end

function Widget:SavePosition()
    if not RPR.savedVars or not RPR.savedVars.widget then return end
    
    local centerX = self.control:GetLeft() + (self.control:GetWidth() / 2)
    local centerY = self.control:GetTop() + (self.control:GetHeight() / 2)
    RPR.savedVars.widget.x = centerX - (GuiRoot:GetWidth() / 2)
    RPR.savedVars.widget.y = centerY - (GuiRoot:GetHeight() / 2)
end

function Widget:RefreshLock()
    local locked = RPR.savedVars and RPR.savedVars.general and RPR.savedVars.general.lockActionWidget
    self.control:SetMovable(not locked)
end

function Widget:SetPendingSources(sources)
    self.pendingSources = sources or {}

    if #self.pendingSources == 0
        and RPR.session
        and RPR.session.widgetPreview then

        self.pendingSources = {
            {
                displayName = "Widget preview",
                id = "preview",
                priority = 0,
                widgetIcon = DEFAULT_ICON,
                widgetGlow = DEFAULT_GLOW,
                widgetGlowColor = { 1, 1, 1, 1 },
                widgetFrame = DEFAULT_FRAME,
            },
        }
    end

    local primarySource = self.pendingSources[1]
    local newSignature = primarySource and primarySource.id or "none"

    if self.currentPendingSignature ~= newSignature then
        self.currentPendingSignature = newSignature
        self:UpdateSourceVisual(true)
    end

    if RPR.Debug then
        RPR:Debug(
            "widget pending sources: "
            .. tostring(#self.pendingSources)
        )
    end

    if #self.pendingSources == 0
        or (RPR.session and RPR.session.widgetHidden) then

        self:Hide()
        return
    end

    self:Show()
end

function Widget:UpdateSourceVisual(force)
    local source = self.pendingSources and self.pendingSources[1]

    local iconTexture = (source and source.widgetIcon) or DEFAULT_ICON
    local glowTexture = (source and source.widgetGlow) or DEFAULT_GLOW
    local glowColor = (source and source.widgetGlowColor) or { 1, 1, 1, 1 }
    local frameTexture = (source and source.widgetFrame) or DEFAULT_FRAME

    if self.frame and (force or self.currentFrameTexture ~= frameTexture) then
        self.frame:SetTexture(frameTexture)
        self.currentFrameTexture = frameTexture
    end

    if self.icon and (force or self.currentIconTexture ~= iconTexture) then
        self.icon:SetTexture(iconTexture)
        self.currentIconTexture = iconTexture
    end

    if force or self.currentGlowTexture ~= glowTexture then
        if self.glow then
            self.glow:SetTexture(glowTexture)
        end

        if self.glowOuter then
            self.glowOuter:SetTexture(glowTexture)
        end

        self.currentGlowTexture = glowTexture
    end

    local r = glowColor[1] or 1
    local g = glowColor[2] or 1
    local b = glowColor[3] or 1
    local a = glowColor[4] or 1

    if self.glow then
        self.glow:SetColor(r, g, b, a)
    end

    if self.glowOuter then
        self.glowOuter:SetColor(r, g, b, a)
    end
end

function Widget:SetPreview(enabled)
    RPR.session.widgetPreview = enabled == true
    RPR.session.widgetHidden = false

    if RPR.session.widgetPreview then
        self:SetPendingSources({})
        RPR:Notify("Action Widget preview shown.", true)
    else
        RPR.RewardManager:Refresh("widget preview")
        RPR:Notify("Action Widget preview hidden.", true)
    end
end

function Widget:EnableMenuPreview()
    if not self.fragment then return end

    local menuScene = SCENE_MANAGER
        and SCENE_MANAGER:GetScene("gameMenuInGame")

    if not menuScene then return end

    if not self.menuPreviewFragmentAdded then
        menuScene:AddFragment(self.fragment)
        self.menuPreviewFragmentAdded = true
    end

    RPR.session.widgetHidden = false
    self:SetPreview(true)
end

function Widget:DisableMenuPreview()
    local menuScene = SCENE_MANAGER
        and SCENE_MANAGER:GetScene("gameMenuInGame")

    if menuScene
        and self.fragment
        and self.menuPreviewFragmentAdded then

        menuScene:RemoveFragment(self.fragment)
        self.menuPreviewFragmentAdded = false
    end

    self:SetPreview(false)
end

function Widget:Show()
    if not self.control:IsHidden() and self.fadeState ~= "out" then
        self:StartAnimation()
        return
    end

    self.fadeState = "in"
    self.fadeStart = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    self.control:SetAlpha(0)
    self.control:SetHidden(false)
    self:StartAnimation()
end

function Widget:Hide()
    if self.control:IsHidden() then
        self:StopAnimation()
        return
    end

    self.fadeState = "out"
    self.fadeStart = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    self:StartAnimation()
    self:HideTooltip()
end

function Widget:StartAnimation()
    if self.animating then return end

    self.animating = true

    EVENT_MANAGER:RegisterForUpdate(
        WIDGET_NAME .. "Animation",
        33,
        function()
            self:Animate()
        end
    )
end

function Widget:StopAnimation()
    if not self.animating then return end

    self.animating = false
    EVENT_MANAGER:UnregisterForUpdate(WIDGET_NAME .. "Animation")
    self.fadeState = nil
    self.control:SetAlpha(1)
    self.control:SetScale(1)
    if self.frame then self.frame:SetScale(1) end
    if self.icon then self.icon:SetScale(1) end
    if self.glow then self.glow:SetAlpha(0) end
    if self.glowOuter then self.glowOuter:SetAlpha(0) end
    if self.frame then
        self.frame:SetColor(1, 1, 1, 1)
    end

    if self.icon then
        self.icon:SetColor(1, 1, 1, 1)
    end

    self.glintStartTime = nil
    self.nextGlintTime = (
        GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    ) + 1500
end

function Widget:Animate()
    local general = RPR.savedVars and RPR.savedVars.general or {}
    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    local wave = (1 - math.cos((now % 3000) / 3000 * math.pi * 2)) / 2

    self:AnimateFade(now)
    self:AnimateGlint(now)

    if general.glowAnimation ~= false then
        if self.glow then
            self.glow:SetAlpha(0.42 + (wave * 0.08))
        end

        if self.glowOuter then
            self.glowOuter:SetAlpha(0.12 + (wave * 0.04))
        end
    else
        if self.glow then
            self.glow:SetAlpha(0)
        end

        if self.glowOuter then
            self.glowOuter:SetAlpha(0)
        end
    end

    self.control:SetScale(1)

    if self.frame and self.icon then
        if general.pulseAnimation ~= false then
            local scale = 1 + (wave * 0.025)
            self.frame:SetScale(scale)
            self.icon:SetScale(scale)
        else
            self.frame:SetScale(1)
            self.icon:SetScale(1)
        end
    end
end

function Widget:AnimateFade(now)
    if not self.fadeState then
        self.control:SetAlpha(1)
        return
    end

    local elapsed = now - (self.fadeStart or now)
    local progress = zo_clamp and zo_clamp(elapsed / FADE_MS, 0, 1) or math.max(0, math.min(elapsed / FADE_MS, 1))

    if self.fadeState == "in" then
        self.control:SetAlpha(progress)
        if progress >= 1 then
            self.fadeState = nil
        end
    elseif self.fadeState == "out" then
        self.control:SetAlpha(1 - progress)
        if progress >= 1 then
            self.control:SetHidden(true)
            self:StopAnimation()
        end
    end
end

function Widget:AnimateGlint(now)
    if not self.frame or not self.icon then return end

    if not self.glintStartTime then
        if now < (self.nextGlintTime or 0) then
            return
        end

        self.glintStartTime = now
    end

    local elapsed = now - self.glintStartTime
    local progress = elapsed / GLINT_DURATION_MS

    if progress >= 1 then
        self.frame:SetColor(1, 1, 1, 1)
        self.icon:SetColor(1, 1, 1, 1)

        self.glintStartTime = nil
        self.nextGlintTime = now + GLINT_INTERVAL_MS
        return
    end

    -- Smooth rise and fall.
    local strength = math.sin(progress * math.pi)

    -- Slightly brighten the actual artwork.
    local brightness = 1 + (strength * 0.18)

    self.frame:SetColor(brightness, brightness, brightness, 1)
    self.icon:SetColor(brightness, brightness, brightness, 1)
end

function Widget:OnMouseDown(button)
    if button == LEFT_BUTTON and not RPR.savedVars.general.lockActionWidget then
        self.control:StartMoving()
    elseif button == RIGHT_BUTTON then
        self:ShowMenu()
    end
end

function Widget:OnMouseUp(button)
    if button == LEFT_BUTTON then
        if not RPR.savedVars.general.lockActionWidget then
            self.control:StopMovingOrResizing()
        end

        local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
        if self.lastLeftClick and now - self.lastLeftClick <= 350 then
            RPR.RewardManager:OpenPrimaryManualSource()
            self.lastLeftClick = nil
        else
            self.lastLeftClick = now
        end
    end
end

function Widget:ShowMenu()
    if not ClearMenu or not AddMenuItem or not ShowMenu then
        RPR:Notify("The Action Widget menu is unavailable.", true)
        return
    end

    ClearMenu()

    local manualSources = RPR.RewardManager and RPR.RewardManager.manualSources or {}

    if #manualSources > 0 then
        AddMenuItem("Open Reward Window", function()
            RPR.RewardManager:OpenPrimaryManualSource()
        end)

        for _, source in ipairs(manualSources) do
            AddMenuItem("Open " .. source.displayName, function()
                RPR.RewardManager:OpenSourceById(source.id)
            end)
        end
    end

    AddMenuItem("Claim Enabled Rewards", function()
        RPR.RewardManager:ClaimVisibleSafeRewards()
    end)

    local locked = RPR.savedVars.general.lockActionWidget
    AddMenuItem(locked and "Unlock Widget Position" or "Lock Widget Position", function()
        RPR.savedVars.general.lockActionWidget = not locked
        self:RefreshLock()
    end)

    AddMenuItem("Hide Widget", function()
        RPR.session.widgetHidden = true
        RPR.session.widgetPreview = false
        self:Hide()
    end)

    AddMenuItem("Open Settings", function()
        RPR.Settings:OpenPanel()
    end)

    ShowMenu(self.control)
end

function Widget:GetTooltipText()
    if #self.pendingSources == 0 then
        return "Reward action waiting."
    end

    local names = {}
    for _, source in ipairs(self.pendingSources) do
        table.insert(names, "* " .. tostring(source.displayName))
    end

    return "Reward action waiting:\n" .. table.concat(names, "\n")
end

function Widget:ShowTooltip()
    local general = RPR.savedVars and RPR.savedVars.general or {}
    if general.tooltips == false or not InformationTooltip then return end

    InitializeTooltip(InformationTooltip, self.control, RIGHT, -8, 0)
    if SetTooltipText then
        SetTooltipText(InformationTooltip, self:GetTooltipText())
    elseif InformationTooltip.AddLine then
        InformationTooltip:AddLine(self:GetTooltipText(), "ZoFontGame")
    end
end

function Widget:HideTooltip()
    if ClearTooltip and InformationTooltip then
        ClearTooltip(InformationTooltip)
    end
end
