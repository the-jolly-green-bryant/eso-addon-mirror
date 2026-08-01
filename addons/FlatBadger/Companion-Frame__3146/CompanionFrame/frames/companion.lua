local Drawing = CF.Drawing

local function Refresh(hidden)
    CF.CompanionFrame:SetHidden(hidden)
end

local function GetCompanionButtonSize()
    
    if (CF.Vars.CompanionButtonSize == Drawing.ButtonProperties.Small) then
        return 32
    elseif (CF.Vars.CompanionButtonSize == Drawing.ButtonProperties.Medium) then
        return 48
    else
        return 64
    end
end

local function GetCompanionButtonSpacing()
    
    local buttonSize = GetCompanionButtonSize()

    if (CF.Vars.CompanionButtonSpacing == Drawing.ButtonProperties.Small) then
        return (buttonSize / 8 - 2) * -4
    elseif (CF.Vars.CompanionButtonSpacing == Drawing.ButtonProperties.Medium) then
        return (buttonSize / 8 - 4) * -4
    else
        return 2
    end

end

function CF.SetHiddenForReason(reason, hidden)
    if (CF.CompanionFrame ~= nil) then
        if (CF.CompanionFrame.hiddenReasons:SetHiddenForReason(reason, hidden)) then
            Refresh(hidden)
        end
    end
end

function CF.DisableCompanionFrame()
    if (CF.CompanionFrame) then
        CF.SetHiddenForReason("disabled", true)
        CF.RemoveFragment()
    end
end

function CF.EnableCompanionFrame()
    if not HasActiveCompanion() and not HasPendingCompanion() then
        return
    end
    CF.SetHiddenForReason("disabled", false)
    CF.AddFragment()
end

local function SaveAnchor(frame, isButtonFrame)
    local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = frame:GetAnchor()

    if (isValidAnchor) then
        if (isButtonFrame) then
            CF.Vars.ButtonPosition = {point, relativeTo, relativePoint, offsetX, offsetY}
        else
            CF.Vars.Position = {point, relativeTo, relativePoint, offsetX, offsetY}
        end
    end
end

local function StartCompanionCooldown()
    local remaining, duration = GetCollectibleCooldownAndDuration(CF.ActiveCompanionCollectibleId)

    CF.CompanionFrame.Toggle.Cooldown:StartCooldown(remaining, duration, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
    CF.CompanionFrame.Toggle.Cooldown:SetHidden(false)
end

local function DismissCompanion()
    UseCollectible(CF.ActiveCompanionCollectibleId)
end

local function ToggleCompanion()
    local BASTIAN = GetCompanionCollectibleId(1)
    local MIRRI = GetCompanionCollectibleId(2)
    local EMBER = GetCompanionCollectibleId(5)
    local ISOBEL = GetCompanionCollectibleId(6)
    local SHARPASNIGHT = GetCompanionCollectibleId(8)
    local AZANDER = GetCompanionCollectibleId(9)
    local TANLORIN = GetCompanionCollectibleId(12)
    local ZERITHVAR = GetCompanionCollectibleId(13)
    local otherCompanion

    if (CF.ActiveCompanionCollectibleId == BASTIAN) then
        otherCompanion = MIRRI
    elseif (CF.ActiveCompanionCollectibleId == MIRRI) then
        otherCompanion = EMBER
    elseif (CF.ActiveCompanionCollectibleId == EMBER) then
        otherCompanion = ISOBEL
    elseif (CF.ActiveCompanionCollectibleId == ISOBEL) then
        otherCompanion = SHARPASNIGHT
    elseif (CF.ActiveCompanionCollectibleId == SHARPASNIGHT) then
        otherCompanion = AZANDER
    elseif (CF.ActiveCompanionCollectibleId == AZANDER) then
        otherCompanion = TANLORIN
    elseif (CF.ActiveCompanionCollectibleId == TANLORIN) then
        otherCompanion = ZERITHVAR
    elseif (CF.ActiveCompanionCollectibleId == ZERITHVAR) then
        otherCompanion = BASTIAN
    end

    -- don't check if the companion is usuable as we want the default game message to show to the player
    UseCollectible(otherCompanion)
end

function CF.CreateCompanionSummoningFrame()
    local name = CF.Name .. "_CompanionSummoningFrame"

    CF.SummoningFrame = Drawing.Window(name, GuiRoot:GetWidth() / 3, 30, {CENTER, GuiRoot, CENTER, 0, 0}, false)
    CF.SummoningFrame:SetDrawTier(DT_HIGH)

    CF.SummoningFrame.Message =
        Drawing.Label(
        name .. "_Message",
        CF.SummoningFrame,
        400,
        30,
        {CENTER, CF.SummoningFrame, CENTER, 0, (GuiRoot:GetHeight() / 4) * -1},
        Drawing.GetFont(CF.Vars.FrameFont, 28, true),
        CF.Vars.SummoningColour,
        0,
        1,
        "Companion Name. Summoning...",
        true
    )
end

function CF.ToggleButtonLock()
    CF.ButtonFrame:SetMovable(CF.Vars.ButtonLockPosition)
    CF.Vars.ButtonLockPosition = not CF.Vars.ButtonLockPosition
    CF.SetLockState(CF.ButtonFrame, CF.Vars.ButtonLockPosition)
end

function CF.AddButtonFragment()
    CF.ButtonFrame.Fragment = ZO_HUDFadeSceneFragment:New(CF.ButtonFrame)

    SCENE_MANAGER:GetScene("hud"):AddFragment(CF.ButtonFrame.Fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(CF.ButtonFrame.Fragment)
    SCENE_MANAGER:GetScene("siegeBar"):AddFragment(CF.ButtonFrame.Fragment)
end

function CF.RemoveButtonFragment()
    SCENE_MANAGER:GetScene("hud"):RemoveFragment(CF.ButtonFrame.Fragment)
    SCENE_MANAGER:GetScene("hudui"):RemoveFragment(CF.ButtonFrame.Fragment)
    SCENE_MANAGER:GetScene("siegeBar"):RemoveFragment(CF.ButtonFrame.Fragment)
end

local function AddCompanion(name, companionName, ancestor)
    
    local buttonSize = GetCompanionButtonSize()
    local buttonSpacing = GetCompanionButtonSpacing()

    local x = companionName == "Mirri" and 0 or buttonSpacing
    local y = companionName == "Mirri" and 16 or 0
    local anchor = companionName == "Mirri" and TOPLEFT or TOPRIGHT

    CF.ButtonFrame[companionName] =
        Drawing.Button(
        name .. "_" .. companionName .. "Button",
        CF.ButtonFrame,
        buttonSize,
        buttonSize,
        {TOPLEFT, ancestor, anchor, x, y},
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        true
    )

    CF.ButtonFrame[companionName]:SetNormalTexture(CF[companionName:upper()].Icon)
    CF.ButtonFrame[companionName]:SetPressedTexture(CF[companionName:upper()].Icon)
    CF.ButtonFrame[companionName]:SetHandler(
        "OnMouseUp",
        function()
            UseCollectible(CF[companionName:upper()].CollectibleId)
        end
    )
    CF.ButtonFrame[companionName]:SetHandler(
        "OnMouseEnter",
        function()
            ZO_Tooltips_ShowTextTooltip(CF.ButtonFrame[companionName], TOP, CF[companionName:upper()].Name)
        end
    )
    CF.ButtonFrame[companionName]:SetHandler(
        "OnMouseExit",
        function()
            ZO_Tooltips_HideTextTooltip()
        end
    )
end

function CF.CreateCompanionButtonFrame()
    local name = CF.Name .. "_CompanionButtonFrame"
    local position = CF.Vars.ButtonPosition

    if (position == nil) then
        position = {CENTER, GuiRoot, CENTER, 0, 0}

        CF.Vars.ButtonPosition = position
    end

    -- the first time the frame is moved we change the relative point
    CF.Vars.ButtonPosition[2] = CF.Vars.ButtonPosition[2] or GuiRoot

    CF.ButtonFrame = Drawing.Window(name, 390, 80, CF.Vars.ButtonPosition, CF.Vars.ShowButtons)
    CF.AddButtonFragment()

    AddCompanion(name, "Mirri", CF.ButtonFrame)
    AddCompanion(name, "Bastian", CF.ButtonFrame.Mirri)
    AddCompanion(name, "Ember", CF.ButtonFrame.Bastian)
    AddCompanion(name, "Isobel", CF.ButtonFrame.Ember)

    if (CF.Necrom) then
        AddCompanion(name, "SharpAsNight", CF.ButtonFrame.Isobel)
        AddCompanion(name, "Azander", CF.ButtonFrame.SharpAsNight)
        
        AddCompanion(name, "Tanlorin", CF.ButtonFrame.Azander)
    else
        AddCompanion(name, "Tanlorin", CF.ButtonFrame.Isobel)
    end

    AddCompanion(name, "ZerithVar", CF.ButtonFrame.Tanlorin)

    CF.ButtonFrame.LockUnlockButton =
        Drawing.Button(
        CF.Name .. "_ButtonLockUnlockButton",
        CF.ButtonFrame,
        16,
        16,
        {TOPLEFT, CF.ButtonFrame, TOPLEFT, 0, 0},
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        false
    )

    CF.ButtonFrame.LockUnlockButton:SetHandler("OnMouseUp", CF.ToggleButtonLock)

    CF.ButtonFrame.LockUnlockButton:SetHandler(
        "OnMouseEnter",
        function()
            CF.ButtonFrame.LockUnlockButton:SetHidden(false)
        end
    )

    CF.ButtonFrame.LockUnlockButton:SetHandler(
        "OnMouseExit",
        function()
            CF.ButtonFrame.LockUnlockButton:SetHidden(true)
        end
    )

    CF.ButtonFrame:SetHandler(
        "OnMouseEnter",
        function()
            CF.ButtonFrame.LockUnlockButton:SetHidden(false)
        end
    )

    CF.ButtonFrame:SetHandler(
        "OnMouseExit",
        function()
            CF.ButtonFrame.LockUnlockButton:SetHidden(true)
        end
    )

    CF.SetLockState(CF.ButtonFrame, CF.Vars.ButtonLockPosition)
    CF.ButtonFrame:SetMouseEnabled(true)
    CF.ButtonFrame:SetMovable(not CF.Vars.ButtonLockPosition)

    CF.ButtonFrame:SetHandler(
        "OnMouseUp",
        function()
            SaveAnchor(CF.ButtonFrame, true)
            -- this works, but doesn't feel right
            -- without it, moving the frame seems to remove it from the scene
            CF.RemoveFragment()
            CF.AddFragment()
        end
    )

    CF.ButtonFrame.Fragment:SetHiddenForReason("disabled", not CF.Vars.ShowButtons)
end

function CF.AdjustAnchors()
    CF.CompanionFrame.Rapport:SetHidden(not CF.Vars.ShowRapport)
    CF.CompanionFrame.Experience:SetHidden(not CF.Vars.ShowExperience)

    local xpAnchor = CF.CompanionFrame.Health

    if (CF.Vars.ShowRapport) then
        xpAnchor = CF.CompanionFrame.Rapport
    end

    CF.CompanionFrame.Experience:SetAnchor(TOP, xpAnchor, BOTTOM, 0, 0)
end

function CF.AddFragment()
    CF.CompanionFrame.Fragment = ZO_HUDFadeSceneFragment:New(CF.CompanionFrame)
    CF.CompanionFrame.Fragment:SetHiddenForReason(
        "noCompanion",
        not (DoesUnitExist("companion") and (HasActiveCompanion() or HasPendingCompanion()))
    )

    SCENE_MANAGER:GetScene("hud"):AddFragment(CF.CompanionFrame.Fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(CF.CompanionFrame.Fragment)
    SCENE_MANAGER:GetScene("siegeBar"):AddFragment(CF.CompanionFrame.Fragment)
end

function CF.RemoveFragment()
    SCENE_MANAGER:GetScene("hud"):RemoveFragment(CF.CompanionFrame.Fragment)
    SCENE_MANAGER:GetScene("hudui"):RemoveFragment(CF.CompanionFrame.Fragment)
    SCENE_MANAGER:GetScene("siegeBar"):RemoveFragment(CF.CompanionFrame.Fragment)
end

function CF.ToggleLock()
    CF.CompanionFrame:SetMovable(CF.Vars.LockPosition)
    CF.Vars.LockPosition = not CF.Vars.LockPosition
    CF.SetLockState(CF.CompanionFrame, CF.Vars.LockPosition)
end

function CF.SetLockState(frame, lock)
    local lockNormal = "esoui/art/miscellaneous/unlocked_up.dds"
    local lockPressed = "esoui/art/miscellaneous/unlocked_down.dds"
    local lockMouseOver = "esoui/art/miscellaneous/unlocked_over.dds"

    if (lock) then
        lockNormal = "esoui/art/miscellaneous/locked_up.dds"
        lockPressed = "esoui/art/miscellaneous/locked_down.dds"
        lockMouseOver = "esoui/art/miscellaneous/locked_over.dds"
    end

    frame.LockUnlockButton:SetNormalTexture(lockNormal)
    frame.LockUnlockButton:SetPressedTexture(lockPressed)
    frame.LockUnlockButton:SetMouseOverTexture(lockMouseOver)
end

function CF.CreateCompanionFrame()
    CF.CreateCompanionSummoningFrame()
    CF.CreateCompanionButtonFrame()

    local name = CF.Name .. "_CompanionFrame"

    local position = CF.Vars.Position

    if (position == nil) then
        position = {
            TOPLEFT,
            ZO_SmallGroupAnchorFrame,
            TOPLEFT,
            0,
            0
        }

        CF.Vars.Position = position
    end

    -- the first time the frame is moved we change the relative point
    CF.Vars.Position[2] = CF.Vars.Position[2] or GuiRoot

    CF.CompanionFrame = Drawing.Window(name, CF.Vars.FrameWidth, CF.Vars.FrameHeight, CF.Vars.Position, false)

    CF.CompanionFrame:SetMovable(not CF.Vars.LockPosition)
    CF.CompanionFrame:SetMouseEnabled(true)
    CF.CompanionFrame:SetHandler(
        "OnMouseUp",
        function()
            SaveAnchor(CF.CompanionFrame, false)
            -- this works, but doesn't feel right
            -- without it, moving the frame seems to remove it from the scene
            CF.RemoveFragment()
            CF.AddFragment()
        end
    )

    CF.CompanionFrame.hiddenReasons = ZO_HiddenReasons:New()

    CF.CompanionFrame.LockUnlockButton =
        Drawing.Button(
        CF.Name .. "LockUnlockButton",
        CF.CompanionFrame,
        16,
        16,
        {TOPLEFT, CF.CompanionFrame, TOPLEFT, 5, -6},
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        false
    )

    CF.CompanionFrame.LockUnlockButton:SetHandler("OnMouseUp", CF.ToggleLock)
    CF.CompanionFrame.LockUnlockButton:SetHandler(
        "OnMouseEnter",
        function()
            CF.CompanionFrame.LockUnlockButton:SetHidden(false)
        end
    )
    CF.CompanionFrame.LockUnlockButton:SetHandler(
        "OnMouseExit",
        function()
            CF.CompanionFrame.LockUnlockButton:SetHidden(true)
        end
    )

    CF.SetLockState(CF.CompanionFrame, CF.Vars.LockPosition)

    CF.CompanionFrame:SetHandler(
        "OnMouseEnter",
        function()
            CF.CompanionFrame.LockUnlockButton:SetHidden(false)
        end
    )
    CF.CompanionFrame:SetHandler(
        "OnMouseExit",
        function()
            CF.CompanionFrame.LockUnlockButton:SetHidden(true)
        end
    )

    CF.CompanionFrame.Nameplate =
        Drawing.Control(
        name .. "_NamePlate",
        CF.CompanionFrame,
        CF.CompanionFrame:GetWidth(),
        CF.CompanionFrame:GetHeight() / 5,
        {TOP, CF.CompanionFrame, TOP, 0, 0},
        true
    )

    CF.CompanionFrame.Nameplate.Name =
        Drawing.Label(
        name .. "_CompanionName",
        CF.CompanionFrame.Nameplate,
        CF.CompanionFrame.Nameplate:GetWidth() - 42,
        30,
        {BOTTOMLEFT, CF.CompanionFrame.Nameplate, BOTTOMLEFT, 6, 0},
        Drawing.GetFont(CF.Vars.FrameFont, CF.Vars.FrameFontSize + 2, true),
        nil,
        0,
        1,
        "Companion Name (Level)",
        true
    )

    CF.CompanionFrame.Dismiss =
        Drawing.Button(
        name .. "_Dismiss",
        CF.CompanionFrame,
        30,
        30,
        {RIGHT, CF.CompanionFrame.Nameplate, RIGHT, 0, 0},
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        CF.Vars.ShowDismiss
    )

    CF.CompanionFrame.Dismiss:SetNormalTexture("/esoui/art/buttons/clearslot_up.dds")
    CF.CompanionFrame.Dismiss:SetPressedTexture("/esoui/art/buttons/clearslot_down.dds")
    CF.CompanionFrame.Dismiss:SetDisabledTexture("/esoui/art/buttons/clearslot_disabled.dds")
    CF.CompanionFrame.Dismiss:SetHandler("OnMouseUp", DismissCompanion)

    CF.CompanionFrame.Toggle =
        Drawing.Button(
        name .. "_Toggle",
        CF.CompanionFrame,
        30,
        30,
        {RIGHT, CF.CompanionFrame.Dismiss, LEFT, -4, 0},
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        CF.Vars.ShowDismiss
    )

    CF.CompanionFrame.Toggle:SetNormalTexture("/esoui/art/buttons/switch_up.dds")
    CF.CompanionFrame.Toggle:SetPressedTexture("/esoui/art/buttons/switch_down.dds")
    CF.CompanionFrame.Toggle:SetDisabledTexture("/esoui/art/buttons/switch_disabled.dds")
    CF.CompanionFrame.Toggle:SetHandler("OnMouseUp", ToggleCompanion)

    CF.CompanionFrame.Toggle.Cooldown =
        Drawing.Cooldown(
        name .. "_ToggleCooldown",
        CF.CompanionFrame.Toggle,
        CF.CompanionFrame.Toggle:GetWidth(),
        CF.CompanionFrame.Toggle:GetHeight(),
        {CENTER, CF.CompanionFrame.Toggle, CENTER, 0, 0},
        {0, 0.1, 0.1, 0.6},
        true
    )

    CF.CompanionFrame.Health =
        Drawing.Control(
        name .. "_Health",
        CF.CompanionFrame,
        CF.CompanionFrame:GetWidth(),
        CF.CompanionFrame:GetHeight() / 3,
        {TOP, CF.CompanionFrame.Nameplate, BOTTOM, 0, 0},
        true
    )

    local healthR, healthG, healthB =
        CF.Vars.FrameHealthColour[1],
        CF.Vars.FrameHealthColour[2],
        CF.Vars.FrameHealthColour[3]

    CF.CompanionFrame.Health.Background =
        Drawing.Background(
        name .. "_HealthBackground",
        CF.CompanionFrame.Health,
        CF.CompanionFrame.Health:GetWidth(),
        CF.CompanionFrame.Health:GetHeight(),
        {TOP, CF.CompanionFrame.Nameplate, BOTTOM, 0, 0},
        {healthR / 5, healthG / 5, healthB / 5, 0.6},
        {0, 0, 0, 1},
        nil,
        true
    )

    CF.CompanionFrame.Health.Bar =
        Drawing.Statusbar(
        name .. "_HealthStatusBar",
        CF.CompanionFrame.Health,
        CF.CompanionFrame.Health:GetWidth() - 4,
        CF.CompanionFrame.Health:GetHeight() - 4,
        {TOPLEFT, CF.CompanionFrame.Health, TOPLEFT, 2, 2},
        {healthR, healthG, healthB, 0.6},
        Drawing.Textures.status,
        true
    )

    CF.CompanionFrame.Health.Current =
        Drawing.Label(
        name .. "_HealthCurrent",
        CF.CompanionFrame.Health,
        CF.CompanionFrame.Health:GetWidth() * 2 / 3,
        CF.CompanionFrame.Health:GetHeight(),
        {LEFT, CF.CompanionFrame.Health, LEFT, 12, -2},
        Drawing.GetFont(CF.Vars.FrameFont, CF.Vars.FrameFontSize + 2, true),
        nil,
        0,
        1,
        "Health",
        true
    )

    CF.CompanionFrame.Health.Percent =
        Drawing.Label(
        name .. "_HealthPercent",
        CF.CompanionFrame.Health,
        CF.CompanionFrame.Health:GetWidth() * 1 / 3,
        CF.CompanionFrame.Health:GetHeight(),
        {RIGHT, CF.CompanionFrame.Health, RIGHT, -12, -2},
        Drawing.GetFont(CF.Vars.FrameFont, CF.Vars.FrameFontSize + 2, true),
        nil,
        2,
        1,
        "Percent%",
        true
    )

    CF.CompanionFrame.Health.Hot =
        Drawing.Texture(
        name .. "_HealthHoT",
        CF.CompanionFrame.Health,
        CF.CompanionFrame.Health.Bar:GetWidth() / 6,
        CF.CompanionFrame.Health.Bar:GetWidth() / 12,
        {LEFT, CF.CompanionFrame.Health, CENTER, 6, 0},
        Drawing.Textures.regenLarge,
        false
    )

    CF.CompanionFrame.Health.Dot =
        Drawing.Texture(
        name .. "_HealthDoT",
        CF.CompanionFrame.Health,
        CF.CompanionFrame.Health.Bar:GetWidth() / 6,
        CF.CompanionFrame.Health.Bar:GetWidth() / 12,
        {RIGHT, CF.CompanionFrame.Health, CENTER, 0, 0},
        Drawing.Textures.regenLarge,
        false
    )

    CF.CompanionFrame.Health.Dot:SetTextureRotation(math.pi)

    CF.CompanionFrame.Rapport =
        Drawing.Control(
        name .. "_Rapport",
        CF.CompanionFrame,
        CF.CompanionFrame:GetWidth(),
        CF.CompanionFrame:GetHeight() / 6,
        {TOP, CF.CompanionFrame.Health, BOTTOM, 0, 0},
        true
    )

    CF.CompanionFrame.Rapport.Background =
        Drawing.Background(
        name .. "_RapportBackground",
        CF.CompanionFrame.Rapport,
        CF.CompanionFrame.Rapport:GetWidth(),
        CF.CompanionFrame.Rapport:GetHeight(),
        {TOP, CF.CompanionFrame.Health, BOTTOM, 0, 0},
        {0, 0.1, 0.1, 0.6},
        {0, 0, 0, 1},
        nil,
        true
    )

    CF.CompanionFrame.Rapport.Bar =
        Drawing.Statusbar(
        name .. "_RapportBar",
        CF.CompanionFrame.Rapport,
        CF.CompanionFrame.Rapport:GetWidth() - 4,
        CF.CompanionFrame.Rapport:GetHeight() - 4,
        {TOPLEFT, CF.CompanionFrame.Rapport, TOPLEFT, 2, 2},
        {0, 1, 1, 0.6},
        Drawing.Textures.status,
        true
    )

    CF.CompanionFrame.Rapport.Current =
        Drawing.Label(
        name .. "_RapportCurrent",
        CF.CompanionFrame.Rapport,
        CF.CompanionFrame.Rapport:GetWidth() * 1 / 3,
        CF.CompanionFrame.Rapport:GetHeight(),
        {RIGHT, CF.CompanionFrame.Rapport, RIGHT, 25, -2},
        Drawing.GetFont(CF.Vars.FrameFont, CF.Vars.FrameFontSize + 2, true),
        nil,
        0,
        1,
        "Rapport",
        true
    )

    CF.CompanionFrame.Rapport.Icon =
        Drawing.Texture(
        name .. "_RapportIcon",
        CF.CompanionFrame.Rapport,
        30,
        30,
        {LEFT, CF.CompanionFrame.Rapport, LEFT, 4, 0},
        "/esoui/art/hud/loothistory_icon_rapportincrease.dds",
        CF.Vars.ShowRapportIcon
    )

    local experienceR, experienceG, experienceB =
        CF.Vars.FrameExperienceColour[1],
        CF.Vars.FrameExperienceColour[2],
        CF.Vars.FrameExperienceColour[3]

    CF.CompanionFrame.Experience =
        Drawing.Control(
        name .. "_Experience",
        CF.CompanionFrame,
        CF.CompanionFrame:GetWidth(),
        CF.CompanionFrame:GetHeight() / 24,
        {TOP, CF.CompanionFrame.Rapport, BOTTOM, 0, 0},
        true
    )

    CF.CompanionFrame.Experience.Background =
        Drawing.Background(
        name .. "_ExperienceBackground",
        CF.CompanionFrame.Experience,
        CF.CompanionFrame.Experience:GetWidth(),
        CF.CompanionFrame.Experience:GetHeight(),
        {TOP, CF.CompanionFrame.Rapport, BOTTOM, 0, 0},
        {experienceR / 5, experienceG / 5, experienceB / 5, 0.6},
        {0, 0, 0, 1},
        nil,
        true
    )

    CF.CompanionFrame.Experience.Bar =
        Drawing.Statusbar(
        name .. "_ExperienceBar",
        CF.CompanionFrame.Experience,
        CF.CompanionFrame.Experience:GetWidth() - 4,
        CF.CompanionFrame.Experience:GetHeight() - 4,
        {TOPLEFT, CF.CompanionFrame.Experience, TOPLEFT, 2, 2},
        {experienceR, experienceG, experienceB, 0.6},
        nil,
        true
    )

    CF.AdjustAnchors()

    if (CF.Vars.HideWhenGrouped) then
        CF.SetHiddenForReason("grouped", IsUnitGrouped("player"))
    end
end

function CF.CompanionActivated()
    CF.HideDefaultCompanionFrame()

    if (not HasActiveCompanion() and not HasPendingCompanion()) then
        CF.DisableCompanionFrame()
        return
    end

    CF.UpdateCompanionNameAndLevel()
    CF.SetHiddenForReason("disabled", false)

    CF.OnCompanionRapportUpdate()
    CF.OnCompanionExperienceUpdate()

    CF.EnableCompanionFrame()
    StartCompanionCooldown()

    zo_callLater(
        function()
            local companionDefId = GetActiveCompanionDefId()
            local collectibleId = GetCompanionCollectibleId(companionDefId)
            CF.ActiveCompanionCollectibleId = collectibleId
        end,
        1000
    )
end

function CF.CompanionDeactivated()
    CF.DisableCompanionFrame()
end
