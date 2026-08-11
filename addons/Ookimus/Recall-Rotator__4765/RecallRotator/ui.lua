-- On-screen reroll button: a small movable icon, sized to match the action
-- bar, that shows the currently active recall style and rerolls it on click.

local RecallRotator = RecallRotator

local DEFAULT_ICON = "esoui/art/icons/poi/poi_wayshrine_complete.dds"
local MIN_BUTTON_SIZE = 32
local MAX_BUTTON_SIZE = 96
local COOLDOWN_LABEL_UPDATE_MS = 200
local COOLDOWN_UPDATE_HANDLE = "RecallRotatorButtonCooldown"

function RecallRotator:GetButtonIconTexture()
    local pool = self:GetRecallCollectibles()
    local activeId = self:GetActiveRecallId(pool)
    if activeId then
        local icon = GetCollectibleIcon(activeId)
        if icon and icon ~= "" then
            return icon
        end
    end
    return DEFAULT_ICON
end

function RecallRotator:RefreshButtonIcon()
    if self.buttonIcon then
        self.buttonIcon:SetTexture(self:GetButtonIconTexture())
    end
end

function RecallRotator:ApplyButtonLockState()
    if not self.buttonControl then
        return
    end
    local locked = self.savedVars.buttonLocked
    self.buttonControl:SetMovable(not locked)
    if self.buttonBackdrop then
        if locked then
            self.buttonBackdrop:SetEdgeColor(0, 0, 0, 1)
        else
            self.buttonBackdrop:SetEdgeColor(1, 0.65, 0, 1)
        end
    end
end

function RecallRotator:ApplyButtonSize()
    if not self.buttonControl then
        return
    end
    local size = zo_clamp(self.savedVars.buttonSize or 64, MIN_BUTTON_SIZE, MAX_BUTTON_SIZE)
    self.buttonControl:SetDimensions(size, size)
end

function RecallRotator:SaveButtonPosition()
    if not self.buttonControl then
        return
    end
    self.savedVars.buttonPos = self.savedVars.buttonPos or {}
    self.savedVars.buttonPos.x = self.buttonControl:GetLeft()
    self.savedVars.buttonPos.y = self.buttonControl:GetTop()
end

function RecallRotator:ApplyButtonPosition()
    local control = self.buttonControl
    if not control then
        return
    end
    local pos = self.savedVars.buttonPos
    control:ClearAnchors()
    if pos and pos.x and pos.y then
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.x, pos.y)
    else
        -- Default spot: just right of where the action bar normally sits.
        control:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 220, -110)
    end
end

-- Radial swipe + a live countdown number over the button while a swap is
-- pending, so it's obvious the button isn't ready for another click yet.
function RecallRotator:StartButtonCooldown(durationMs)
    if not self.buttonControl then
        return
    end

    self.cooldownEndTime = GetGameTimeMilliseconds() + durationMs

    self.buttonCooldown:SetHidden(false)
    self.buttonCooldown:StartCooldown(durationMs, durationMs, CD_TYPE_RADIAL, nil, false)

    self.buttonCooldownLabel:SetHidden(false)
    self.buttonIcon:SetAlpha(0.4)

    self:UpdateButtonCooldownLabel()
    EVENT_MANAGER:RegisterForUpdate(COOLDOWN_UPDATE_HANDLE, COOLDOWN_LABEL_UPDATE_MS, function()
        self:UpdateButtonCooldownLabel()
    end)
end

function RecallRotator:UpdateButtonCooldownLabel()
    local remainingMs = (self.cooldownEndTime or 0) - GetGameTimeMilliseconds()
    if remainingMs <= 0 then
        self:StopButtonCooldown()
        return
    end
    self.buttonCooldownLabel:SetText(tostring(zo_ceil(remainingMs / 1000)))
end

function RecallRotator:StopButtonCooldown()
    EVENT_MANAGER:UnregisterForUpdate(COOLDOWN_UPDATE_HANDLE)
    self.cooldownEndTime = nil

    if self.buttonCooldown then
        self.buttonCooldown:ResetCooldown()
        self.buttonCooldown:SetHidden(true)
    end
    if self.buttonCooldownLabel then
        self.buttonCooldownLabel:SetHidden(true)
    end
    if self.buttonIcon then
        self.buttonIcon:SetAlpha(1)
    end
end

-- True while the plain in-world HUD is showing. False whenever any menu or
-- settings screen (inventory, map, collections, character, crafting, the
-- options menu, etc.) is the active scene.
local function IsHudSceneActive()
    local scene = SCENE_MANAGER:GetCurrentScene()
    return scene == HUD_SCENE or scene == HUD_UI_SCENE
end

-- Single place that decides the button's hidden state, combining the user's
-- "Show on-screen button" setting with whether a menu is currently covering
-- the screen. Kept as one function so the two conditions can't fight each
-- other by both calling SetHidden independently.
function RecallRotator:UpdateButtonVisibility()
    if not self.buttonControl then
        return
    end
    local hidden = (not self.savedVars.showButton) or (not IsHudSceneActive())
    self.buttonControl:SetHidden(hidden)
end

function RecallRotator:CreateButton()
    if self.buttonControl then
        return
    end

    local button = WINDOW_MANAGER:CreateTopLevelWindow("RecallRotatorButton")
    button:SetMouseEnabled(true)
    button:SetClampedToScreen(true)

    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual("RecallRotatorButtonBG", button, "ZO_DefaultBackdrop")
    backdrop:SetAnchorFill(button)
    backdrop:SetCenterColor(0, 0, 0, 0.4)
    self.buttonBackdrop = backdrop

    local icon = button:CreateControl("RecallRotatorButtonIcon", CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, button, TOPLEFT, 3, 3)
    icon:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -3, -3)
    icon:SetTexture(DEFAULT_ICON)
    self.buttonIcon = icon

    -- Same radial swipe control the action bar uses for ability cooldowns.
    local cooldown = button:CreateControl("RecallRotatorButtonCooldown", CT_COOLDOWN)
    cooldown:SetAnchor(TOPLEFT, icon, TOPLEFT, 0, 0)
    cooldown:SetAnchor(BOTTOMRIGHT, icon, BOTTOMRIGHT, 0, 0)
    cooldown:SetRadialCooldownClockwise(true)
    cooldown:SetHidden(true)
    self.buttonCooldown = cooldown

    local cooldownLabel = button:CreateControl("RecallRotatorButtonCooldownLabel", CT_LABEL)
    cooldownLabel:SetAnchorFill(button)
    cooldownLabel:SetFont("ZoFontGameBold")
    cooldownLabel:SetColor(1, 1, 1, 1)
    cooldownLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    cooldownLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    cooldownLabel:SetDrawLayer(DL_TEXT)
    cooldownLabel:SetHidden(true)
    self.buttonCooldownLabel = cooldownLabel

    button:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT and upInside then
            RecallRotator:Reroll()
        end
    end)

    button:SetHandler("OnMouseEnter", function(control)
        ZO_Tooltips_ShowTextTooltip(control, TOP, "Recall Rotator\nClick to reroll your recall style.")
    end)
    button:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    button:SetHandler("OnMoveStop", function()
        RecallRotator:SaveButtonPosition()
    end)

    self.buttonControl = button

    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
        self:UpdateButtonVisibility()
    end)

    self:ApplyButtonSize()
    self:ApplyButtonPosition()
    self:ApplyButtonLockState()
    self:RefreshButtonIcon()
    self:UpdateButtonVisibility()
end
