PotionAlert = {}
PotionAlert.name = "PotionAlert"
PotionAlert.savedVariables = nil
PotionAlert.previewMode = false

--------------------------------------------------
-- State
--------------------------------------------------
local inCombat       = false
local isVisible      = false
local potionReady    = true   -- assume ready until we see a drink
local cooldownEndsAt = 0

--------------------------------------------------
-- Font
--------------------------------------------------
function PotionAlert:GetFont()
    return string.format(
        "%s|%d|%s",
        self.savedVariables.font,
        self.savedVariables.fontSize,
        "outline"
    )
end

function PotionAlert:InvalidateFont()
    if self.label then
        self.label:SetFont(self:GetFont())
    end
    self:RefreshDisplay()
end

--------------------------------------------------
-- Position
--------------------------------------------------
function PotionAlert:ApplyPosition()
    self.panel:ClearAnchors()
    self.panel:SetAnchor(
        CENTER, GuiRoot, CENTER,
        self.savedVariables.posX,
        self.savedVariables.posY
    )
end

--------------------------------------------------
-- Create Panel
--------------------------------------------------
function PotionAlert:CreatePanel()
    self.panel = WINDOW_MANAGER:CreateTopLevelWindow("PotionAlert_Panel")
    self.panel:SetClampedToScreen(true)
    self.panel:SetDrawLayer(DL_OVERLAY)
    self.panel:SetDrawTier(DT_HIGH)
    self.panel:SetDimensions(1200, 120)
    self.panel:SetHidden(true)
    self:ApplyPosition()

    local label = WINDOW_MANAGER:CreateControl("PotionAlert_Label", self.panel, CT_LABEL)
    label:SetAnchor(CENTER, self.panel, CENTER, 0, 0)
    label:SetFont(self:GetFont())
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.label = label
end

--------------------------------------------------
-- Potion Cooldown Tracking
--------------------------------------------------
-- Detection copied from LibGroupPotionCooldowns:
--   EVENT_INVENTORY_ITEM_USED reports a sound category; ITEM_SOUND_CATEGORY_POTION
--   identifies a potion specifically, so food/drink never trigger this.
--   After a drink, GetSlotCooldownInfo briefly reports the GLOBAL cooldown, so we
--   poll until the "global" return goes false before reading the real duration.

function PotionAlert:OnPotionUsed(_, sound)
    if sound ~= ITEM_SOUND_CATEGORY_POTION then return end

    -- Potion is now on cooldown; hide immediately.
    potionReady = false
    self:RefreshDisplay()

    EVENT_MANAGER:RegisterForUpdate(self.name .. "OnDrink", 10, function()
        local slotIndex = GetCurrentQuickslot()
        local remain, duration, global = GetSlotCooldownInfo(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)

        if not global then
            EVENT_MANAGER:UnregisterForUpdate(PotionAlert.name .. "OnDrink")

            remain = remain or 0
            cooldownEndsAt = GetGameTimeMilliseconds() + remain
        end
    end)
end

-- Returns true once the tracked cooldown has elapsed.
function PotionAlert:IsPotionReady()
    if potionReady then return true end

    if cooldownEndsAt > 0 and GetGameTimeMilliseconds() >= cooldownEndsAt then
        potionReady    = true
        cooldownEndsAt = 0
        return true
    end

    return false
end

--------------------------------------------------
-- Resource gates (health / magicka / stamina)
--------------------------------------------------
-- "Always On" bypasses every gate. Otherwise gates are OR'd: if ANY checked
-- gate is at or below its threshold, the alert is allowed through. With
-- Always On off and nothing checked we fall back to showing, so the addon
-- can never end up silently disabled.

-- The POWERTYPE_* constants were renamed to COMBAT_MECHANIC_FLAGS_* in a later
-- API. This addon targets 101048+, where only the new names exist, but we try
-- the old ones too so the code still works on older clients.

local RESOURCE_GATES = {
    { label = "health",  enable = "useHealthGate",  threshold = "healthThreshold",
      consts = { "COMBAT_MECHANIC_FLAGS_HEALTH",  "POWERTYPE_HEALTH"  } },
    { label = "magicka", enable = "useMagickaGate", threshold = "magickaThreshold",
      consts = { "COMBAT_MECHANIC_FLAGS_MAGICKA", "POWERTYPE_MAGICKA" } },
    { label = "stamina", enable = "useStaminaGate", threshold = "staminaThreshold",
      consts = { "COMBAT_MECHANIC_FLAGS_STAMINA", "POWERTYPE_STAMINA" } },
}

-- Percentages are cached from EVENT_POWER_UPDATE rather than polled. Seeded at
-- 100 ("assume full") so a resource we have not heard about yet can never
-- trigger the alert.
local powerPct = {}

function PotionAlert:ResolvePowerTypes()
    for _, gate in ipairs(RESOURCE_GATES) do
        gate.power = nil

        for _, name in ipairs(gate.consts) do
            local value = _G[name]
            if type(value) == "number" then
                gate.power = value
                break
            end
        end

        if gate.power then
            powerPct[gate.power] = 100
        end
    end
end

function PotionAlert.OnPowerUpdate(_, unitTag, _, powerType, powerValue, powerMax)
    if unitTag ~= "player" then return end
    if powerType == nil or powerPct[powerType] == nil then return end
    if not powerMax or powerMax <= 0 then return end

    powerPct[powerType] = (powerValue / powerMax) * 100

    PotionAlert:RefreshDisplay()
end

function PotionAlert:ResourceGatesPassed()
    local sv = self.savedVariables

    if sv.alwaysOn then return true end

    for _, gate in ipairs(RESOURCE_GATES) do
        if sv[gate.enable] then
            local pct = powerPct[gate.power] or 100
            if pct <= sv[gate.threshold] then
                return true
            end
        end
    end

    -- Always On off with nothing checked means nothing to trigger on.
    return false
end

--------------------------------------------------
-- Death State
--------------------------------------------------
-- Dying is not enough on its own to clear the alert: the game does not always
-- drop combat state the instant you go down, and a corpse reads as 0% health,
-- which passes the health gate. So death is checked directly instead of being
-- inferred. Reincarnating covers the window between accepting a revive and
-- actually standing back up.

function PotionAlert:IsPlayerDead()
    if type(IsUnitDead) == "function" and IsUnitDead("player") then
        return true
    end

    if type(IsUnitReincarnating) == "function" and IsUnitReincarnating("player") then
        return true
    end

    return false
end

function PotionAlert:OnPlayerDead()
    inCombat  = false
    isVisible = false
    self.panel:SetHidden(true)
    self:RefreshDisplay()
end

function PotionAlert:OnPlayerAlive()
    -- Resync rather than assume: you can revive straight back into combat.
    inCombat = IsUnitInCombat("player")
    self:RefreshDisplay()
end

--------------------------------------------------
-- Should the alert be showing?
--------------------------------------------------
function PotionAlert:ShouldShow()
    if self.previewMode then return true end
    if not self.savedVariables.enabled then return false end
    if self:IsPlayerDead() then return false end
    if not inCombat then return false end
    if not self:IsPotionReady() then return false end
    if not self:ResourceGatesPassed() then return false end

    return true
end

--------------------------------------------------
-- Refresh Display
--------------------------------------------------
function PotionAlert:RefreshDisplay()
    local sv = self.savedVariables
    local show = self:ShouldShow()

    if not show then
        if isVisible then
            isVisible = false
        end
        self.panel:SetHidden(true)
        return
    end

    if not isVisible then
        isVisible = true
    end

    self.label:SetText(sv.messageText)

    local c = sv.textColor
    local r, g, b = 1, 1, 1
    if type(c) == "table" then
        r, g, b = c.r or 1, c.g or 1, c.b or 1
    end

    -- Pulsate alpha
    local alpha = 1
    if sv.pulsate then
        local t = GetGameTimeSeconds() * sv.pulseSpeed
        alpha = 0.45 + (0.55 * math.abs(math.sin(t * math.pi)))
    end

    self.label:SetColor(r, g, b, alpha)
    self.panel:SetHidden(false)
end

--------------------------------------------------
-- Combat State
--------------------------------------------------
function PotionAlert:OnCombatState(eventCode, combatState)
    inCombat = combatState

    if not inCombat then
        isVisible = false
        self.panel:SetHidden(true)
    else
        -- Entering combat: if a tracked cooldown already lapsed while we were
        -- out of combat, settle readiness now rather than waiting on the tick.
        self:IsPotionReady()
    end

    self:RefreshDisplay()
end

--------------------------------------------------
-- Scene Handling
--------------------------------------------------
function PotionAlert:InitializeSceneHiding()

    local function OnSceneStateChange(oldState, newState)
        if newState == SCENE_SHOWING then
            PotionAlert.panel:SetHidden(true)
        elseif newState == SCENE_HIDDEN then
            PotionAlert:RefreshDisplay()
        end
    end

    local scenes = { "worldMap", "gameMenuInGame", "inventory", "gamepad_inventory_root" }
    for _, sceneName in ipairs(scenes) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            scene:RegisterCallback("StateChange", OnSceneStateChange)
        end
    end

end

--------------------------------------------------
-- Settings
--------------------------------------------------
function PotionAlert:CreateSettings()
    local LAM = LibAddonMenu2

    local panelData = {
        type               = "panel",
        name               = "Potion Alert",
        displayName        = "Potion Alert",
        author             = "user562",
        version            = "1.1",
        registerForRefresh = true,
    }

    LAM:RegisterAddonPanel("PotionAlert_Settings", panelData)

    local options = {

        {
            type    = "checkbox",
            name    = "Preview",
            getFunc = function() return self.previewMode end,
            setFunc = function(val)
                self.previewMode = val
                self:RefreshDisplay()
            end,
        },
        {
            type    = "slider",
            name    = "Horizontal Position",
            min     = -1200, max = 1200, step = 5,
            getFunc = function() return self.savedVariables.posX end,
            setFunc = function(val)
                self.savedVariables.posX = val
                self:ApplyPosition()
            end,
        },
        {
            type    = "slider",
            name    = "Vertical Position",
            min     = -800, max = 800, step = 5,
            getFunc = function() return self.savedVariables.posY end,
            setFunc = function(val)
                self.savedVariables.posY = val
                self:ApplyPosition()
            end,
        },

        { type = "divider" },

        {
            type    = "checkbox",
            name    = "Enable",
            getFunc = function() return self.savedVariables.enabled end,
            setFunc = function(val)
                self.savedVariables.enabled = val
                self:RefreshDisplay()
            end,
        },
        {
            type    = "checkbox",
            name    = "Always On",
            tooltip = "Show the alert whenever you are in combat with a potion ready, ignoring the resource options below.",
            getFunc = function() return self.savedVariables.alwaysOn end,
            setFunc = function(val)
                self.savedVariables.alwaysOn = val
                self:RefreshDisplay()
            end,
        },

        {
            type     = "checkbox",
            name     = "|cCC2222Health|r",
            tooltip  = "Show the alert when you are in combat with a potion ready and your health has dropped to or below the threshold.",
            disabled = function() return self.savedVariables.alwaysOn end,
            getFunc  = function() return self.savedVariables.useHealthGate end,
            setFunc  = function(val)
                self.savedVariables.useHealthGate = val
                self:RefreshDisplay()
            end,
        },
        {
            type     = "slider",
            name     = "|cCC2222Health|r Threshold",
            disabled = function()
                return self.savedVariables.alwaysOn or not self.savedVariables.useHealthGate
            end,
            min      = 10, max = 100, step = 5,
            getFunc  = function() return self.savedVariables.healthThreshold end,
            setFunc  = function(val)
                self.savedVariables.healthThreshold = val
                self:RefreshDisplay()
            end,
        },

        {
            type     = "checkbox",
            name     = "|c2A6FFFMagicka|r",
            tooltip  = "Show the alert when you are in combat with a potion ready and your magicka has dropped to or below the threshold.",
            disabled = function() return self.savedVariables.alwaysOn end,
            getFunc  = function() return self.savedVariables.useMagickaGate end,
            setFunc  = function(val)
                self.savedVariables.useMagickaGate = val
                self:RefreshDisplay()
            end,
        },
        {
            type     = "slider",
            name     = "|c2A6FFFMagicka|r Threshold",
            disabled = function()
                return self.savedVariables.alwaysOn or not self.savedVariables.useMagickaGate
            end,
            min      = 10, max = 100, step = 5,
            getFunc  = function() return self.savedVariables.magickaThreshold end,
            setFunc  = function(val)
                self.savedVariables.magickaThreshold = val
                self:RefreshDisplay()
            end,
        },

        {
            type     = "checkbox",
            name     = "|c00CC44Stamina|r",
            tooltip  = "Show the alert when you are in combat with a potion ready and your stamina has dropped to or below the threshold.",
            disabled = function() return self.savedVariables.alwaysOn end,
            getFunc  = function() return self.savedVariables.useStaminaGate end,
            setFunc  = function(val)
                self.savedVariables.useStaminaGate = val
                self:RefreshDisplay()
            end,
        },
        {
            type     = "slider",
            name     = "|c00CC44Stamina|r Threshold",
            disabled = function()
                return self.savedVariables.alwaysOn or not self.savedVariables.useStaminaGate
            end,
            min      = 10, max = 100, step = 5,
            getFunc  = function() return self.savedVariables.staminaThreshold end,
            setFunc  = function(val)
                self.savedVariables.staminaThreshold = val
                self:RefreshDisplay()
            end,
        },

        { type = "divider" },
        { type = "description",
          title = "Message",
          text  = "" },

        {
            type    = "editbox",
            name    = "",
            getFunc = function() return self.savedVariables.messageText end,
            setFunc = function(val)
                if val == nil or val == "" then val = "USE POTION NOW!" end
                self.savedVariables.messageText = val
                self:RefreshDisplay()
            end,
        },
        {
            type    = "slider",
            name    = "Size",
            min     = 25, max = 90, step = 1,
            getFunc = function() return self.savedVariables.fontSize end,
            setFunc = function(val)
                self.savedVariables.fontSize = val
                self:InvalidateFont()
            end,
        },
        {
            type    = "dropdown",
            name    = "Font",
            choices = {
                "Gamepad Medium",
                "Gamepad Bold",
                "Gamepad Light",
                "Univers Regular",
                "Univers Bold",
                "Prose Antique",
                "Trajan Pro",
                "Handwritten",
            },
            choicesValues = {
                "EsoUI/Common/Fonts/FTN57.otf",
                "EsoUI/Common/Fonts/FTN87.otf",
                "EsoUI/Common/Fonts/FTN47.otf",
                "EsoUI/Common/Fonts/Univers57.otf",
                "EsoUI/Common/Fonts/univers67.otf",
                "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
                "EsoUI/Common/Fonts/TrajanPro-Regular.otf",
                "EsoUI/Common/Fonts/Handwritten_Bold.otf",
            },
            getFunc = function() return self.savedVariables.font end,
            setFunc = function(val)
                self.savedVariables.font = val
                self:InvalidateFont()
            end,
        },
        {
            type    = "colorpicker",
            name    = "Color",
            default = { r = 1, g = 0.2, b = 0.2, a = 1 },
            getFunc = function()
                local c = self.savedVariables.textColor
                if type(c) == "table" then
                    return c.r or 1, c.g or 1, c.b or 1, 1
                end
                return 1, 1, 1, 1
            end,
            setFunc = function(r, g, b, a)
                self.savedVariables.textColor = { r = r, g = g, b = b, a = a }
                self:RefreshDisplay()
            end,
        },
        {
            type    = "checkbox",
            name    = "Pulsate",
            getFunc = function() return self.savedVariables.pulsate end,
            setFunc = function(val)
                self.savedVariables.pulsate = val
                self:RefreshDisplay()
            end,
        },
        {
            type     = "slider",
            name     = "Pulse Speed",
            disabled = function() return not self.savedVariables.pulsate end,
            min      = 1, max = 10, step = 1,
            getFunc  = function() return self.savedVariables.pulseSpeed end,
            setFunc  = function(val) self.savedVariables.pulseSpeed = val end,
        },
    }

    LAM:RegisterOptionControls("PotionAlert_Settings", options)
end

--------------------------------------------------
-- Load
--------------------------------------------------
local function OnAddonLoaded(event, addonName)
    if addonName == PotionAlert.name then

        PotionAlert.savedVariables = ZO_SavedVars:NewAccountWide(
            "PotionAlert_SavedVars",
            2,
            nil,
            {
                enabled          = false,
                messageText      = "USE POTION NOW!",
                posX             = 0,
                posY             = -220,
                fontSize         = 45,
                font             = "EsoUI/Common/Fonts/univers67.otf",
                textColor        = { r = 1, g = 0.2, b = 0.2, a = 1 },
                pulsate          = false,
                pulseSpeed       = 3,
                alwaysOn         = false,
                useHealthGate    = false,
                healthThreshold  = 60,
                useMagickaGate   = false,
                magickaThreshold = 60,
                useStaminaGate   = false,
                staminaThreshold = 60,
            }
        )

        PotionAlert:ResolvePowerTypes()
        PotionAlert:CreatePanel()
        PotionAlert:CreateSettings()
        PotionAlert:InitializeSceneHiding()

        EVENT_MANAGER:RegisterForEvent(
            PotionAlert.name .. "OnDrink",
            EVENT_INVENTORY_ITEM_USED,
            function(...) PotionAlert:OnPotionUsed(...) end
        )

        if EVENT_POWER_UPDATE ~= nil then
            EVENT_MANAGER:RegisterForEvent(
                PotionAlert.name .. "OnPower",
                EVENT_POWER_UPDATE,
                PotionAlert.OnPowerUpdate
            )

            EVENT_MANAGER:AddFilterForEvent(
                PotionAlert.name .. "OnPower",
                EVENT_POWER_UPDATE,
                REGISTER_FILTER_UNIT_TAG, "player"
            )
        end

        EVENT_MANAGER:RegisterForEvent(
            PotionAlert.name,
            EVENT_PLAYER_COMBAT_STATE,
            function(...) PotionAlert:OnCombatState(...) end
        )

        if EVENT_PLAYER_DEAD ~= nil then
            EVENT_MANAGER:RegisterForEvent(
                PotionAlert.name .. "OnDead",
                EVENT_PLAYER_DEAD,
                function() PotionAlert:OnPlayerDead() end
            )
        end

        if EVENT_PLAYER_ALIVE ~= nil then
            EVENT_MANAGER:RegisterForEvent(
                PotionAlert.name .. "OnAlive",
                EVENT_PLAYER_ALIVE,
                function() PotionAlert:OnPlayerAlive() end
            )
        end

        EVENT_MANAGER:RegisterForUpdate(
            PotionAlert.name,
            100,
            function() PotionAlert:RefreshDisplay() end
        )

        EVENT_MANAGER:RegisterForEvent(
            PotionAlert.name,
            EVENT_PLAYER_ACTIVATED,
            function()
                inCombat = IsUnitInCombat("player")
                PotionAlert:RefreshDisplay()
            end
        )

        EVENT_MANAGER:UnregisterForEvent(PotionAlert.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(PotionAlert.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
