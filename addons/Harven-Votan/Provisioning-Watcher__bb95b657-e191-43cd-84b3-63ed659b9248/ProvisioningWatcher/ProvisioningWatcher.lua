ProvisioningWatcher = {}
ProvisioningWatcher.name = "ProvisioningWatcher"
ProvisioningWatcher.displayName = "Provisioning Watcher"
ProvisioningWatcher.version = "1.2.1"

ProvisioningWatcher.defaults = {
    fontSize = 32,
    posX = 0,
    posY = -220,
    showInSettings = false,
    soundEnabled = true,
    displayMode = "always", -- always | five | one | nobuff
}

ProvisioningWatcher.sv = nil
ProvisioningWatcher.ui = nil
ProvisioningWatcher.label = nil
ProvisioningWatcher.settingsPanel = nil

ProvisioningWatcher.hasProvisioningBuff = false
ProvisioningWatcher.currentBuffName = nil
ProvisioningWatcher.currentBuffEnd = 0
ProvisioningWatcher.lastSoundTime = 0

local UPDATE_INTERVAL_MS = 200
local FLASH_INTERVAL_MS = 500
local SOUND_INTERVAL_SECONDS = 30

local COLOR_GREEN  = ZO_ColorDef:New(0.10, 0.90, 0.10, 1.00)
local COLOR_RED    = ZO_ColorDef:New(1.00, 0.15, 0.15, 1.00)
local COLOR_YELLOW = ZO_ColorDef:New(1.00, 0.90, 0.10, 1.00)

-- From working food/drink addon patterns: explicit food/drink ability ID checks.
ProvisioningWatcher.DRINK_BUFF_ABILITIES = {
    61322, 61325, 61328, 61335, 61340, 61345, 61350,
    66125, 66132, 66137, 66141,
    66586, 66590, 66594,
    68416,
    72816, 72965, 72968, 72971,
    84700, 84704, 84720, 84731, 84732, 84733, 84735,
    85497,
    86559, 86560,
    86673, 86674, 86677, 86678,
    86746, 86747, 86791,
    89957,
    92433, 92476,
    100488,
    127531,
}

ProvisioningWatcher.FOOD_BUFF_ABILITIES = {
    17407, 17577, 17581, 17608, 17614,
    61218, 61255, 61257, 61259, 61260, 61261, 61294,
    66128, 66130,
    66551, 66568, 66576,
    68411,
    72819, 72822, 72824,
    72956, 72959, 72961,
    84678, 84681,
    84709, 84725, 84736,
    85484,
    86749, 86787, 86789,
    89955, 89971,
    92435, 92437, 92474, 92477,
    100498, 100502,
    107748, 107789,
    127537, 127572, 127578, 127596, 127619, 127736,
}

local function SafeRound(n)
    return math.floor((n or 0) + 0.5)
end

local function FormatTime(secondsRemaining)
    secondsRemaining = math.max(0, SafeRound(secondsRemaining))
    local hours = math.floor(secondsRemaining / 3600)
    local minutes = math.floor((secondsRemaining % 3600) / 60)
    local seconds = secondsRemaining % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function InArray(tab, val)
    for i = 1, #tab do
        if tab[i] == val then
            return true
        end
    end
    return false
end

function ProvisioningWatcher:IsFoodOrDrinkAbility(abilityId)
    if not abilityId or abilityId == 0 then
        return false
    end

    return InArray(self.DRINK_BUFF_ABILITIES, abilityId) or InArray(self.FOOD_BUFF_ABILITIES, abilityId)
end

function ProvisioningWatcher:GetCurrentSceneName()
    local scene = SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene()
    if scene and scene.GetName then
        return scene:GetName() or ""
    end
    return ""
end

function ProvisioningWatcher:IsHudScene(sceneName)
    return sceneName == "hud" or sceneName == "hudui"
end

function ProvisioningWatcher:IsSettingsScene(sceneName)
    if not sceneName or sceneName == "" then
        return false
    end

    sceneName = string.lower(sceneName)

    if sceneName == "gamemenuingame" then
        return true
    end

    if string.find(sceneName, "settings", 1, true) then
        return true
    end

    if string.find(sceneName, "options", 1, true) then
        return true
    end

    if string.find(sceneName, "addon", 1, true) then
        return true
    end

    if string.find(sceneName, "menu", 1, true) then
        return true
    end

    return false
end

function ProvisioningWatcher:CreateUI()
    if self.ui then
        return
    end

    local ui = WINDOW_MANAGER:CreateTopLevelWindow("ProvisioningWatcherControl")
    ui:SetDimensions(900, 80)
    ui:SetMovable(false)
    ui:SetMouseEnabled(false)
    ui:SetClampedToScreen(true)
    ui:SetDrawLayer(DL_OVERLAY)
    ui:SetDrawTier(DT_HIGH)
    ui:ClearAnchors()
    ui:SetAnchor(CENTER, GuiRoot, CENTER, self.sv.posX, self.sv.posY)
    ui:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl("ProvisioningWatcherControlLabel", ui, CT_LABEL)
    label:SetAnchor(CENTER, ui, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", self.sv.fontSize))
    label:SetText("")

    self.ui = ui
    self.label = label
end

function ProvisioningWatcher:ApplyPosition()
    if not self.ui then
        return
    end

    self.ui:ClearAnchors()
    self.ui:SetAnchor(CENTER, GuiRoot, CENTER, self.sv.posX, self.sv.posY)
end

function ProvisioningWatcher:ApplyFont()
    if not self.label then
        return
    end

    self.label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", self.sv.fontSize))
end

function ProvisioningWatcher:GetGameSecondsRemaining()
    if not self.hasProvisioningBuff or not self.currentBuffEnd then
        return 0
    end

    local remaining = self.currentBuffEnd - GetGameTimeSeconds()
    return math.max(0, remaining)
end

function ProvisioningWatcher:GetFlashColor()
    local flashOn = (math.floor(GetFrameTimeMilliseconds() / FLASH_INTERVAL_MS) % 2) == 0
    if flashOn then
        return COLOR_RED
    end
    return COLOR_YELLOW
end

function ProvisioningWatcher:FindProvisioningBuff()
    self.hasProvisioningBuff = false
    self.currentBuffName = nil
    self.currentBuffEnd = 0

    local numBuffs = GetNumBuffs("player")
    local now = GetGameTimeSeconds()

    local bestName = nil
    local bestEnd = 0
    local bestRemaining = 0

    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId =
            GetUnitBuffInfo("player", i)

        if buffName and timeEnding and timeEnding > now then
            local remaining = timeEnding - now
            local duration = 0
            if timeStarted and timeEnding and timeEnding > timeStarted then
                duration = timeEnding - timeStarted
            end

            -- Primary: exact food/drink ability ID match.
            if abilityId and self:IsFoodOrDrinkAbility(abilityId) then
                self.hasProvisioningBuff = true
                self.currentBuffName = buffName
                self.currentBuffEnd = timeEnding
                return
            end

            -- Secondary: if the API reports a food/drink ability type.
            if abilityType == ABILITY_TYPE_FOOD or abilityType == ABILITY_TYPE_DRINK then
                self.hasProvisioningBuff = true
                self.currentBuffName = buffName
                self.currentBuffEnd = timeEnding
                return
            end

            -- Fallback: pick the longest long-duration buff so we still catch provisioning on console.
            if duration >= 30 * 60 and duration <= 4 * 60 * 60 then
                if remaining > bestRemaining then
                    bestRemaining = remaining
                    bestName = buffName
                    bestEnd = timeEnding
                end
            end
        end
    end

    if bestName then
        self.hasProvisioningBuff = true
        self.currentBuffName = bestName
        self.currentBuffEnd = bestEnd
    end
end

function ProvisioningWatcher:ShouldShow()
    local sceneName = self:GetCurrentSceneName()
    local inHud = self:IsHudScene(sceneName)
    local inSettings = self.sv.showInSettings and self:IsSettingsScene(sceneName)

    if not inHud and not inSettings then
        return false
    end

    -- Always show "No Provisioning Buff" when the buff is gone, regardless of mode.
    if not self.hasProvisioningBuff then
        return true
    end

    local remaining = self:GetGameSecondsRemaining()
    local mode = self.sv.displayMode

    if mode == "always" then
        return true
    elseif mode == "five" then
        return remaining <= 300
    elseif mode == "one" then
        return remaining <= 60
    elseif mode == "nobuff" then
        return false
    end

    return true
end

function ProvisioningWatcher:PlayMissingBuffSoundIfNeeded()
    if self.hasProvisioningBuff then
        self.lastSoundTime = 0
        return
    end

    if not self.sv.soundEnabled then
        return
    end

    local nowSeconds = GetGameTimeSeconds()
    if self.lastSoundTime == 0 or (nowSeconds - self.lastSoundTime) >= SOUND_INTERVAL_SECONDS then
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        self.lastSoundTime = nowSeconds
    end
end

function ProvisioningWatcher:UpdateDisplay()
    if not self.ui or not self.label or not self.sv then
        return
    end

    self:FindProvisioningBuff()

    local shouldShow = self:ShouldShow()
    self.ui:SetHidden(not shouldShow)

    if not shouldShow then
        return
    end

    if not self.hasProvisioningBuff then
        self.label:SetText("No Provisioning Buff")
        self.label:SetColor(self:GetFlashColor():UnpackRGBA())
        self:PlayMissingBuffSoundIfNeeded()
        return
    end

    self.lastSoundTime = 0

    local remaining = self:GetGameSecondsRemaining()
    self.label:SetText(string.format("%s - %s", self.currentBuffName or "Provisioning", FormatTime(remaining)))

    if remaining <= 60 then
        self.label:SetColor(self:GetFlashColor():UnpackRGBA())
    elseif remaining <= 300 then
        self.label:SetColor(COLOR_RED:UnpackRGBA())
    else
        self.label:SetColor(COLOR_GREEN:UnpackRGBA())
    end
end

function ProvisioningWatcher:BuildSettingsMenu()
    local LAM2 = LibAddonMenu2
    if not LAM2 then
        return
    end

    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "PatientX_81",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.settingsPanel = LAM2:RegisterAddonPanel(self.name .. "_Options", panelData)

    local options = {
        {
            type = "checkbox",
            name = "Show text during addon settings",
            tooltip = "Allows you to preview the provisioning text while inside settings menus.",
            getFunc = function()
                return self.sv.showInSettings
            end,
            setFunc = function(value)
                self.sv.showInSettings = value
                self:UpdateDisplay()
            end,
            default = self.defaults.showInSettings,
            width = "full",
        },
        {
            type = "slider",
            name = "Text size",
            tooltip = "Change the provisioning text size.",
            min = 16,
            max = 64,
            step = 1,
            getFunc = function()
                return self.sv.fontSize
            end,
            setFunc = function(value)
                self.sv.fontSize = value
                self:ApplyFont()
                self:UpdateDisplay()
            end,
            default = self.defaults.fontSize,
            width = "full",
        },
        {
            type = "slider",
            name = "X position",
            tooltip = "Move the text box left or right.",
            min = -1200,
            max = 1200,
            step = 1,
            getFunc = function()
                return self.sv.posX
            end,
            setFunc = function(value)
                self.sv.posX = value
                self:ApplyPosition()
                self:UpdateDisplay()
            end,
            default = self.defaults.posX,
            width = "full",
        },
        {
            type = "slider",
            name = "Y position",
            tooltip = "Move the text box up or down.",
            min = -800,
            max = 800,
            step = 1,
            getFunc = function()
                return self.sv.posY
            end,
            setFunc = function(value)
                self.sv.posY = value
                self:ApplyPosition()
                self:UpdateDisplay()
            end,
            default = self.defaults.posY,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable sound",
            tooltip = "Play a sound every 30 seconds when no provisioning buff is active.",
            getFunc = function()
                return self.sv.soundEnabled
            end,
            setFunc = function(value)
                self.sv.soundEnabled = value
            end,
            default = self.defaults.soundEnabled,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Display Mode",
            tooltip = "Choose when the provisioning timer appears while a buff is active.",
            choices = {
                "Always see provisioning timer",
                "At 5-minutes",
                "At 1-minute",
                "Only when no buff",
            },
            choicesValues = {
                "always",
                "five",
                "one",
                "nobuff",
            },
            getFunc = function()
                return self.sv.displayMode
            end,
            setFunc = function(value)
                self.sv.displayMode = value
                self:UpdateDisplay()
            end,
            default = self.defaults.displayMode,
            width = "full",
        },
    }

    LAM2:RegisterOptionControls(self.name .. "_Options", options)
end

function ProvisioningWatcher:RegisterUpdateLoop()
    EVENT_MANAGER:RegisterForUpdate(self.name .. "_Update", UPDATE_INTERVAL_MS, function()
        self:UpdateDisplay()
    end)
end

function ProvisioningWatcher:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("ProvisioningWatcher_SavedVariables", 1, nil, self.defaults)

    self:CreateUI()
    self:ApplyPosition()
    self:ApplyFont()
    self:BuildSettingsMenu()
    self:RegisterUpdateLoop()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function()
        self:UpdateDisplay()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED, function(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
        if unitTag == "player" and (abilityType == ABILITY_TYPE_FOOD or abilityType == ABILITY_TYPE_DRINK) then
            self:UpdateDisplay()
        end
    end)

    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    self:UpdateDisplay()
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= ProvisioningWatcher.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ProvisioningWatcher.name, EVENT_ADD_ON_LOADED)
    ProvisioningWatcher:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ProvisioningWatcher.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)