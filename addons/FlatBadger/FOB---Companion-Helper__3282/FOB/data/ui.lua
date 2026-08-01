function FOB.CreateMultiIcon(name, parent, size)
    local logo = CreateControlFromVirtual(name, parent, "ZO_MultiIcon")

    logo:SetAnchor(CENTER)
    logo:SetDimensions(size, size)
    logo:AddIcon(FOB.Logo)
    logo:AddIcon(FOB.LogoBlock)
    logo:SetHandler("OnShow", ZO_MultiIcon_OnShow)
    logo:SetHandler("OnHide", ZO_MultiIcon_OnHide)
    logo:Hide()

    return logo
end

function FOB.ReplaceReticle()
    if (FOB.Vars.UseReticle) then
        --- @diagnostic disable-next-line: undefined-global
        ZO_ReticleContainerReticle:SetAlpha(0)
        FOB.Reticle:SetHidden(false)
        FOB.UsingFOBReticle = true
    else
        FOB.UsingFOBReticle = false
    end
end

function FOB.RestoreReticle()
    if (FOB.UsingFOBReticle) then
        --- @diagnostic disable-next-line: undefined-global
        if (ZO_ReticleContainerReticle) then
            --- @diagnostic disable-next-line: undefined-global
            ZO_ReticleContainerReticle:SetAlpha(1)
        end

        FOB.Reticle:SetHidden(true)
        FOB.UsingFOBReticle = false
    end
end

function FOB.ShowAlert(alert)
    alert:SetAlpha(1)
    alert:SetHidden(false)
    alert.Animation:PlayFromStart()

    PlaySound(SOUNDS.QUEST_ABANDONED)

    zo_callLater(
        function()
            alert.FadeAnimation:PlayFromStart()
        end,
        750
    )
end

function FOB.SetupCheeseAlert()
    local font = {
        font = FOB.Vars.CheeseFont,
        size = FOB.Vars.CheeseFontSize,
        shadow = FOB.Vars.CheeseFontShadow,
        colour = FOB.Vars.CheeseFontColour
    }

    FOB.Alert = FOB.SetupAlert("FOB_Cheese_Alert", FOB.Vars.CheeseIcon, font, FOB_CHEESE_ALERT)
end

function FOB.SetupCoffeeAlert()
    local font = {
        font = FOB.Vars.CoffeeFont,
        size = FOB.Vars.CoffeeFontSize,
        shadow = FOB.Vars.CoffeeFontShadow,
        colour = FOB.Vars.CoffeeFontColour
    }

    FOB.CoffeeAlert = FOB.SetupAlert("FOB_Coffee_Alert", FOB.Vars.CoffeeIcon, font, FOB_COFFEE_ALERT)
end

function FOB.SetupAlert(name, icon, fontInfo, text)
    local alert = CreateTopLevelWindow(name)

    -- main window
    alert:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    alert:SetDimensions(256, 64)
    alert:SetHidden(true)

    -- icon
    alert.Texture = CreateControl(name .. "_Texture", alert, CT_TEXTURE)
    alert.Texture:SetTexture(icon)
    alert.Texture:SetAnchor(LEFT, alert, LEFT)
    alert.Texture:SetDimensions(64, 64)

    -- label
    local font = FOB.GetFont(fontInfo.font, fontInfo.size, fontInfo.shadow)

    alert.Label = CreateControl(name .. "_Label", alert, CT_LABEL)
    alert.Label:SetFont(font)
    alert.Label:SetColor(fontInfo.colour.r, fontInfo.colour.g, fontInfo.colour.b, fontInfo.colour.a)
    alert.Label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    alert.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    alert.Label:SetText(GetString(text))
    alert.Label:SetDimensions(184, 64)
    alert.Label:SetAnchor(LEFT, alert.Texture, RIGHT)
    alert.Label:SetHidden(false)

    -- fade out animation
    local fadeAnimation, fadeTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, alert)

    fadeAnimation:SetAlphaValues(1, 0)
    fadeAnimation:SetDuration(1000)
    fadeAnimation:SetHandler(
        "OnStop",
        function()
            FOB.Alert:SetHidden(true)
        end
    )

    if (fadeTimeline) then
        fadeTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 0)
    end

    alert.FadeAnimation = fadeTimeline

    local animation, timeline = CreateSimpleAnimation(ANIMATION_SCALE, alert)

    -- scaling animation
    animation:SetStartScale(1)
    animation:SetEndScale(3)
    animation:SetDuration(1500)

    if (timeline) then
        timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 0)
    end

    alert.Animation = timeline
    alert.FadeAnimation = fadeTimeline

    return alert
end

-- companion summoning frame
function FOB.CreateCompanionSummoningFrame()
    local name = FOB.Name .. "_CompanionSummoningFrame"

    FOB.SummoningFrame = _G[name] or CreateTopLevelWindow(name)
    FOB.SummoningFrame:SetDimensions(GuiRoot:GetWidth() / 3, 30)
    FOB.SummoningFrame:SetAnchor(CENTER, GuiRoot, CENTER)
    FOB.SummoningFrame:SetDrawTier(DT_HIGH)

    --- @diagnostic disable: inject-field
    FOB.SummoningFrame.Message = CreateControl(name .. "_Message", FOB.SummoningFrame, CT_LABEL)
    FOB.SummoningFrame.Message:SetDimensions(400, 30)
    FOB.SummoningFrame.Message:SetAnchor(CENTER, FOB.SummoningFrame, CENTER, 0, (GuiRoot:GetHeight() / 4) * -1)
    FOB.SummoningFrame.Message:SetFont(FOB.GetFont("ESO Bold", 28, true))
    FOB.SummoningFrame.Message:SetHorizontalAlignment(CENTER)
    FOB.SummoningFrame.Message:SetVerticalAlignment(CENTER)
    FOB.SummoningFrame.Message:SetColor(157 / 255, 132 / 255, 13 / 255, 1)
    --- @diagnostic enable: inject-field
end

local function createFobInfoControl()
    local name = "FOB_INFO"
    local control = CreateTopLevelWindow(name)

    control:SetAnchorFill()

    --- @diagnostic disable: inject-field
    control.container = WINDOW_MANAGER:CreateControl(name .. "Container", control, CT_CONTROL)
    control.container:SetResizeToFitDescendents(true)
    control.container:SetResizeToFitPadding(10, nil)
    control.container:SetAnchor(BOTTOM, control, BOTTOM, 0, ZO_COMMON_INFO_DEFAULT_KEYBOARD_BOTTOM_OFFSET_Y)

    control.icon = FOB.CreateMultiIcon(name .. "Icon", control.container, 50)
    control.icon:ClearAnchors()
    control.icon:SetAnchor(LEFT)

    control.frame = WINDOW_MANAGER:CreateControl(name .. "Frame", control.icon, CT_TEXTURE)
    control.frame:SetTexture("esoui/art/actionbar/abilityFrame64_up.dds")
    control.frame:SetDrawLayer(DL_CONTROLS)

    control.action = WINDOW_MANAGER:CreateControl(name .. "Action", control.container, CT_LABEL)
    control.action:SetFont("ZoInteractionPrompt")
    control.action:SetHorizontalAlignment(CENTER)
    control.action:SetAnchor(LEFT, control.icon, RIGHT, 15, 0)
    control.action:SetText(FOB.BladeOfWoeFormatted)
    --- @diagnostic enable: inject-field

    return control
end

-- init
do
    FOB.Fonts = FOB.LC.GetFontNamesAndStyles(true)
    FOB.CompanionNames = {}

    for _, defId in pairs(FOB.DefIds) do
        local cid = GetCompanionCollectibleId(defId)
        local name = ZO_CachedStrFormat("<<C:1>>", FOB.LC.GetFirstWord(GetCollectibleInfo(cid)))

        FOB.CompanionNames[name] = true

        -- handle a spelling mistake in the French client
        if (GetCVar("language.2") == "fr") then
            if (zo_strfind(name, "é")) then
                name = zo_strgsub(name, "é", "e") or ""

                FOB.CompanionNames[name] = true
            end
        end
    end

    if (SLASH_COMMANDS["/rl"] == nil) then
        SLASH_COMMANDS["/rl"] = function()
            ReloadUI()
        end
    end

    --- @diagnostic disable-next-line: undefined-global
    FOB.Reticle = FOB.CreateMultiIcon(nil, ZO_ReticleContainer, 64)
    FOB.BladeOfWoeFormatted = ZO_CachedStrFormat("<<C:1>>", FOB.BladeOfWoe)

    -- setup FOB information area
    local fobControl = createFobInfoControl()
    --- @class FobInfo
    local fobInfo = ZO_Object:Subclass()

    function fobInfo:New(control)
        local fi = ZO_Object.New(self)

        --- @diagnostic disable-next-line: undefined-field
        fi:Initialise(control)

        return self
    end

    function fobInfo:Initialise(control)
        local priority = 4 -- SYNERGY_PRIORITY
        local category = 4 -- next category (made need updating in future patches or for addon compatibility)

        self.control = control

        local function onSynergyAbilityChanged()
            self:OnSynergyAbilityChanged()
        end

        self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onSynergyAbilityChanged)
        self.control:RegisterForEvent(EVENT_SYNERGY_ABILITY_CHANGED, onSynergyAbilityChanged)

        ---@diagnostic disable-next-line: undefined-field
        SHARED_INFORMATION_AREA.prioritizedVisibility:Add(self, priority, category, "FobInfo")

        self.container = self.control.container
        self.action = self.control.action
        self.icon = self.control.icon
        self.frame = self.control.frame

        ZO_PlatformStyle:New(
            function(constants)
                self:ApplyTextStyle(constants)
            end,
            ---@diagnostic disable-next-line: redundant-parameter
            {
                FONT = "ZoInteractionPrompt",
                TEMPLATE = "ZO_KeybindButton_Keyboard_Template",
                OFFSET_Y = ZO_COMMON_INFO_DEFAULT_KEYBOARD_BOTTOM_OFFSET_Y,
                FRAME_TEXTURE = "esoui/art/actionbar/abilityframe64_up.dds"
            },
            ---@diagnostic disable-next-line: redundant-parameter
            {
                FONT = "ZoFontGamepad42",
                TEMPLATE = "ZO_KeybindButton_Gamepad_Template",
                OFFSET_Y = ZO_COMMON_INFO_DEFAULT_GAMEPAD_BOTTOM_OFFSET_Y,
                FRAME_TEXTURE = "esoui/art/actionbar/gamepad/gp_abilityframe64.dds"
            }
        )
    end

    function fobInfo:ApplyTextStyle(constants)
        self.frame:SetTexture(constants.FRAME_TEXTURE)
        self.action:SetFont(constants.FONT)

        ---@diagnostic disable-next-line: undefined-field
        ApplyTemplateToControl(self.key, constants.TEMPLATE)
        self.container:ClearAnchors()
        self.container:SetAnchor(BOTTOM, nil, BOTTOM, 0, constants.OFFSET_Y)
    end

    function fobInfo:ShowInfo()
        SHARED_INFORMATION_AREA:SetCategoriesSuppressed(
            true,
            ZO_SHARED_INFORMATION_AREA_SUPPRESSION_CATEGORIES.HAS_KEYBINDS,
            "Synergy"
        )

        self.lastSynergyName = FOB.BladeOfWoe

        --- @diagnostic disable-next-line: undefined-field
        if (SHARED_INFORMATION_AREA.prioritizedVisibility:GetObjectInfo(self)) then
            SHARED_INFORMATION_AREA:SetHidden(self, false)
        end
    end

    function fobInfo:HideInfo()
        SHARED_INFORMATION_AREA:SetCategoriesSuppressed(
            false,
            ZO_SHARED_INFORMATION_AREA_SUPPRESSION_CATEGORIES.HAS_KEYBINDS,
            "Synergy"
        )

        self.lastSynergyName = nil

        if (self:IsVisible()) then
            SHARED_INFORMATION_AREA:SetHidden(self, true)
        end
    end

    function fobInfo:OnSynergyAbilityChanged()
        if (FOB.Enabled) then
            if (FOB.Vars.BoWCompanions[FOB.ActiveCompanionDefId]) then
                local hasSynergy, synergyName = GetCurrentSynergyInfo()

                if (hasSynergy) then
                    if (self.lastSynergyName ~= FOB.BladeOfWoe) then
                        if (synergyName == FOB.BladeOfWoe) then
                            self:ShowInfo()
                        else
                            self:HideInfo()
                        end
                    end
                else
                    self:HideInfo()
                end
            end
        else
            self:HideInfo()
        end
    end

    function fobInfo:SetHidden(hidden)
        self.control:SetHidden(hidden)
    end

    function fobInfo:IsVisible()
        return not SHARED_INFORMATION_AREA:IsHidden(self) and not SHARED_INFORMATION_AREA:IsSuppressed()
    end

    FOB.FobInfo = fobInfo:New(fobControl)
end
