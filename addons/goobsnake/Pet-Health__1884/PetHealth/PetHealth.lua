--Elder Scrolls: Online addon (written in LUA) which adds persistent in-game health bars to all permanent pets.
--Original/base work of this addon was developed by SCOOTWORKS and I was granted permission by him to take over full development and distribution of this addon.
PetHealth                          = PetHealth or {}
--The supported classes for this addon (ClassId from function GetUnitClassId("player"))
PetHealth.supportedClasses         = {
    [1]   = true, -- Dragonknight
    [2]   = true, -- Sorcerer
    [3]   = true, -- Nightblade
    [4]   = true, -- Warden
    [5]   = true, -- Necromancer
    [6]   = true, -- Templar
    [117] = true, -- Archanist
}
local addonName = "PetHealth"
local addon                        = {
    name            = addonName,
    displayName     = addonName,
    version         = "1.14",
    savedVarName    = "PetHealth_Save",
    savedVarVersion = 2,
    lamDisplayName  = "PetHealth",
    lamAuthor       = "Scootworks, Goobsnake, Baertram",
    lamUrl          = "https://www.esoui.com/downloads/info1884-PetHealth.html",
}
PetHealth.addonData                = addon

local default                      = {
    saveMode                 = 1, -- Default for each character setting
    point                    = TOPLEFT,
    relPoint                 = CENTER,
    x                        = 0,
    y                        = 0,
    onlyInCombat             = false,
    showValues               = true,
    showLabels               = true,
    hideInDungeon            = false,
    lockWindow               = false,
    lowHealthAlertSlider     = 0,
    lowShieldAlertSlider     = 0,
    petUnsummonedAlerts      = false,
    onlyInCombatHealthSlider = 0,
    showBackground           = true,
    useZosStyle              = false,
    debug                    = false,
    showCompanion            = true,
    excludedZonesForHide     = {
        [1] = {
            value     = 677, --Maelstrom Arena zoneId
            uniqueKey = 1, --number of the unique key of this list entry. This will not change if the order changes. Will be used to identify the entry uniquely
            text      = "Maelstrom Arena"
        },
    }
}

PetHealth.excludedZonesForHide     = {}

local tos = tostring
local tins = table.insert
local trem = table.remove


local UNIT_PLAYER_PET              = "playerpet"
local UNIT_COMPANION               = "companion"
local UNIT_PLAYER_TAG              = "player"

local base, background, savedVars--, savedVarCopy
local currentPets                  = {}
PetHealth.currentPets = currentPets
local PetHealthWarner
local window                       = {}
PetHealth.window = window
local inCombatAddon                = false
local lang = GetCVar("language.2") 

--local AddOnManager                 = GetAddOnManager()
local hideInDungeon                = false
local LAM
local LSC
local lockWindow                   = false
local lowHealthAlertPercentage     = 0
local lowShieldAlertPercentage     = 0
local onlyInCombatHealthMax        = 0
local onlyInCombatHealthCurrent    = 0
local onlyInCombatHealthPercentage = 0
local onScreenHealthAlerts         = {} -- Dynamic table for health alerts
local onScreenShieldAlerts         = {} -- Dynamic table for shield alerts
local unsummonedAlerts             = false

local WINDOW_MANAGER               = GetWindowManager()
local WINDOW_WIDTH                 = 250
local WINDOW_HEIGHT_PER_PET        = 40 -- Height per pet bar
local WINDOW_HEIGHT_BASE           = 36 -- Base height for no pets
local PET_BAR_FRAGMENT

----------
-- UTIL --
----------
local function OnScreenMessage(message)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
    messageParams:SetText(message)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

local function ChatOutput(message)
    CHAT_SYSTEM:AddMessage(message)
end

--[[
local function CheckAddon(addonName)
    for i = 1, AddOnManager:GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate = AddOnManager:GetAddOnInfo(i)
        if title == addonName and enabled == true and state == 2 then
            return true
        end
    end
end
]]


local validPets = {
	["en"]={
		["eternal guardian"]=true,
		["wild guardian"]=true,
		["twilight tormentor"]=true,
		["familiar"]=true,
		["twilight matriarch"]=true,
		["feral guardian"]=true,
		["winged twilight"]=true,
		["volatile familiar"]=true,
		["clannfear"]=true,
	},
	["de"]={
		["ewiger wächter"]=true,
		["wilder wächter"]=true,
		["zwielichtpeinigerin"]=true,
		["begleiter"]=true,
		["zwielichtmatriarchin"]=true,
		["ungezähmter wächter"]=true,
		["zwielichtschwinge"]=true,
		["explosiver begleiter"]=true,
		["clannbann"]=true,
	},
	["ru"]={
		["вечный страж"]=true,
		["дикий страж"]=true,
		["сумрак-мучитель"]=true,
		["призванный слуга"]=true,
		["сумрак-матриарх"]=true,
		["хищный страж"]=true,
		["крылатый сумрак"]=true,
		["взрывной призванный слуга"]=true,
		["кланфир"]=true,
	},
	["fr"]={
		["gardien éternel"]=true,
		["gardien sauvage"]=true,
		["tourmenteur crépusculaire"]=true,
		["familier"]=true,
		["matriarche crépusculaire"]=true,
		["gardien féroce"]=true,
		["crépuscule ailé"]=true,
		["familier explosif"]=true,
		["faucheclan"]=true,
	},
	["es"]={
		["guardián eterno"]=true,
		["guardián salvaje"]=true,
		["atormentadora crepuscular"]=true,
		["familiar"]=true,
		["matriarca crepuscular"]=true,
		["clannfear"]=true,
		["crepúsculo alado"]=true,
		["familiar volátil"]=true,
		["guardián feroz"]=true,
	},
	["zh"]={
		["永恒守护者"]=true,
		["荒野守护者"]=true,
		["影暮苔魔"]=true,
		["魔宠"]=true,
		["影暮女王"]=true,
		["野蛮守护者"]=true,
		["影暮翼人"]=true,
		["暴烈魔宠"]=true,
		["惊惧兽"]=true,
	},	
}
if not validPets[lang] then lang="en" end
local function IsUnitValidPet(unitTag)
    --[[
    Hier durchsuchen wir die Tabellen oben, ob wir den unitTag wirklich in unsere Tabelle aufnehmen.
    ]]
    local unitName = zo_strformat("<<z:1>>", GetUnitName(unitTag))
    --zo_callLater(function() ChatOutput(unitName) end, 10000)

    return DoesUnitExist(unitTag) and validPets[lang][unitName]
end

local function GetKeyWithData(unitTag)
    for k, v in pairs(currentPets) do
        if v.unitTag == unitTag then return k end
    end
    return nil
end

local function GetAlphaFromControl(savedVariable)
    return (not savedVariable and 0) or 1
end

local function GetCombatState()
    return not inCombatAddon and savedVars.onlyInCombat
end

local function SetPetWindowHidden(hidden, combatState)
    local setToHidden = hidden
    if combatState then
        setToHidden = true
    end
    PET_BAR_FRAGMENT:SetHiddenForReason("NoPetOrOnlyInCombat", setToHidden)
    -- debug
    --ChatOutput(string.format("SetPetWindowHidden() setToHidden: %s, onlyInCombat: %s", tos(setToHidden), tos(onlyInCombat)))
end

local function PetUnSummonedAlerts(unitTag)
    if unsummonedAlerts then
        local i = GetKeyWithData(unitTag)
        if i == nil then
            return
        end
        local petName  = currentPets[i].unitName
        local swimming = IsUnitSwimming(UNIT_PLAYER_TAG)
        local inCombat = IsUnitInCombat(UNIT_PLAYER_TAG)
        if swimming then
            OnScreenMessage(string.format(GetString(SI_PET_HEALTH_UNSUMMONED_SWIMMING_MSG)))
        elseif inCombat then
            OnScreenMessage(zo_strformat("<<1>> <<2>>", petName, GetString(SI_PET_HEALTH_UNSUMMONED_MSG)))
        end
    end
end

local function GetTableSize(tbl)
    --[[
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
    ]]
    return (tbl ~= nil and #tbl) or 0
end

local function RefreshPetWindow()
    --GetSlotBoundId values 3 thru 8 to obtain the slotbar's abiltiyId's (8 is ultimate)
    -- d(GetSlotBoundId(3))
    -- d(GetPetNameLower(GetSlotBoundId(3)))
    -- d(GetAbilityName(23319))
    local countPets   = GetTableSize(currentPets)
    local combatState = GetCombatState()
    if PET_BAR_FRAGMENT:IsHidden() and countPets == 0 and combatState then
        return
    end

    local height      = WINDOW_HEIGHT_BASE + (countPets * WINDOW_HEIGHT_PER_PET)
    local setToHidden = true
    if countPets > 0 then
        for i = 1, MAX_PET_UNIT_TAGS do
            local currentPetWindow = window[i]
            if currentPetWindow ~= nil then
                currentPetWindow:SetHidden(i > countPets and true or false)
            end
        end
        setToHidden = false
    end
    if not combatState and savedVars.onlyInCombat == true then
        if onlyInCombatHealthPercentage == 0 then
            setToHidden = false
        elseif onlyInCombatHealthCurrent > (onlyInCombatHealthMax * .01 * onlyInCombatHealthPercentage) then
            setToHidden = true
        end
    end
    if savedVars.hideInDungeon == true then
        local inDungeon      = IsUnitInDungeon(UNIT_PLAYER_TAG)
        local zoneDifficulty = GetCurrentZoneDungeonDifficulty()
        --zoneDifficulty 0 is for all overland/non-dungeon content, 1 = normal dungeon/arena/trial, 2 = veteran dungeon/arena/trial
        if inDungeon == true and zoneDifficulty > 0 then
            --local currentZone = GetUnitZone(UNIT_PLAYER_TAG)
            local currentZoneId = GetZoneId(GetUnitZoneIndex(UNIT_PLAYER_TAG))
            if not PetHealth.excludedZonesForHide[currentZoneId] then
                setToHidden = true
            end
        end
    end
    base:SetHeight(height)
    background:SetHeight(height)
    -- set hidden state
    SetPetWindowHidden(setToHidden, combatState)
    -- debug
    --ChatOutput(string.format("RefreshPetWindow() countPets: %d", countPets))
end

------------
-- SHIELD --
------------
local function OnShieldUpdate(handler, unitTag, value, maxValue, initial, doDebug)
    local i = GetKeyWithData(unitTag)
--d("[PetHealth]OnShieldUpdate - i: " ..tos(i))
    if i == nil then
        if doDebug then d("<[ERROR]OnShieldUpdate - i is nil") end
        return
    end
    local petName = currentPets[i].unitName
    if lowShieldAlertPercentage > 1 and value ~= 0 and value < (maxValue * .01 * lowShieldAlertPercentage) then
        if not onScreenShieldAlerts then
            OnScreenMessage(zo_strformat("|c000099<<1>>\'s <<2>>|r", petName, GetString(SI_PET_HEALTH_LOW_SHIELD_WARNING_MSG)))
            onScreenShieldAlerts = true
        end
    else
        onScreenShieldAlerts = false
    end

    local currentPetWindow = window[i]
    if currentPetWindow == nil then return end

    local ctrl, ctrlr
    if not savedVars.useZosStyle then
        ctrl = currentPetWindow.shield
    else
        ctrl  = currentPetWindow.shieldleft
        ctrlr = currentPetWindow.shieldright
    end
    if handler ~= nil then
        if not ctrl:IsHidden() or value == 0 then
            ctrl:SetHidden(true)
            if savedVars.useZosStyle then
                ctrlr:SetHidden(true)
            end
        end
    else
        if ctrl:IsHidden() then
            ctrl:SetHidden(false)
            if savedVars.useZosStyle then
                ctrlr:SetHidden(false)
            end
        end
    end
    if maxValue > 0 then
        if doDebug then d("[PetHealth]OnShieldUpdate - unitTag: " .. tos(unitTag) ..", value: " .. tos(value) ..", maxValue: " .. tos(maxValue)) end
        if savedVars.useZosStyle then
            value    = value / 2
            maxValue = maxValue / 2
            ZO_StatusBar_SmoothTransition(currentPetWindow.shieldleft, value, maxValue, (initial == "true" and true or false))
            ZO_StatusBar_SmoothTransition(currentPetWindow.shieldright, value, maxValue, (initial == "true" and true or false))
        else
            ZO_StatusBar_SmoothTransition(currentPetWindow.shield, value, maxValue, (initial == "true" and true or false))
        end
    end
end

local function GetShield(unitTag, doDebug)
    local value, maxValue = GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
    if value == nil then
        value    = 0
        maxValue = 0
    end
    if doDebug then d("[PetHealth]GetShield - shield: " ..tos(value) .. "/" .. tos(maxValue)) end
    OnShieldUpdate(_, unitTag, value, maxValue, "true", doDebug)
end

------------
-- HEALTH --
------------
local function OnHealthUpdate(_, unitTag, _, _, powerValue, powerMax, initial, doDebug)
    if onlyInCombatHealthPercentage > 1 and savedVars.onlyInCombat == true then
        onlyInCombatHealthMax     = powerMax
        onlyInCombatHealthCurrent = powerValue
        RefreshPetWindow()
    end
    local i = GetKeyWithData(unitTag)
--d("[PetHealth]OnHealthUpdate - i: " ..tos(i))
    if i == nil then
        if doDebug then d("<[ERROR]OnHealthUpdate - i is nil") end
        return
    end
    local currentPetWindow = window[i]
    if currentPetWindow == nil then return end

    local petName = currentPets[i].unitName
    if lowHealthAlertPercentage > 1 and powerValue ~= 0 and powerValue < (powerMax * .01 * lowHealthAlertPercentage) then
        if not onScreenHealthAlerts then
            OnScreenMessage(zo_strformat("|cff0000<<1>> <<2>>|r", petName, GetString(SI_PET_HEALTH_LOW_HEALTH_WARNING_MSG)))
            onScreenHealthAlerts = true
        end
    else
        onScreenHealthAlerts = false
    end
    if doDebug then d("[PetHealth]OnHealthUpdate - name: " ..tos(petName) .. " - health: " ..tos(powerValue) .. "/" .. tos(powerMax) .. " -> Text: " .. tos(ZO_FormatResourceBarCurrentAndMax(powerValue, powerMax))) end

    currentPetWindow.values:SetText(ZO_FormatResourceBarCurrentAndMax(powerValue, powerMax))
    if savedVars.useZosStyle then
        local halfValue = powerValue / 2
        local halfMax   = powerMax / 2
        ZO_StatusBar_SmoothTransition(currentPetWindow.barleft, halfValue, halfMax, (initial == "true" and true or false))
        ZO_StatusBar_SmoothTransition(currentPetWindow.barright, halfValue, halfMax, (initial == "true" and true or false))
        currentPetWindow.warner:OnHealthUpdate(powerValue, powerMax)
    else
        ZO_StatusBar_SmoothTransition(currentPetWindow.healthbar, powerValue, powerMax, (initial == "true" and true or false))
    end
end

local function GetHealth(unitTag, doDebug)
    local powerValue, powerMax = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
    if doDebug then d("[PetHealth]GetHealth - health: " ..tos(powerValue) .. "/" .. tos(powerMax)) end
    OnHealthUpdate(_, unitTag, _, _, powerValue, powerMax, "true", doDebug)
end

-----------
-- STATS --
-----------
local function GetControlText(control)
    local controlText = control:GetText()
    if controlText ~= nil then return controlText end
    return ""
end

local function UpdatePetStats(unitTag)
    local doDebug = false
    --[[
    if unitTag == UNIT_COMPANION then
        doDebug = true
        d("[PetHealth]UpdatePetStats - Companion")
    end
    ]]
    local i = GetKeyWithData(unitTag)
    if i == nil then
        if doDebug then d("<[ERROR]i is nil!") end
        return
    end

    local name    = currentPets[i].unitName
    local control = window[i].label
    if GetControlText(control) ~= name then
        control:SetText(name)
    end
    GetHealth(unitTag, doDebug)
    GetShield(unitTag, doDebug)
    -- debug
    --ChatOutput(string.format("UpdatePetStats() unitTag: %s, name: %s", unitTag, name))
end

local function GetActivePets()
    --[[
    Hier werden alle Begleiter des Spielers ausgelesen und in die Begleitertabelle geschrieben.
    ]]
    currentPets = {}
    for i = 1, MAX_PET_UNIT_TAGS do
        local unitTag = UNIT_PLAYER_PET .. i
        if IsUnitValidPet(unitTag) then
            tins(currentPets, { unitTag = unitTag, unitName = zo_strformat("<<z:1>>", GetUnitName(unitTag)) })
            UpdatePetStats(unitTag)
        end
    end

    if savedVars.showCompanion and HasActiveCompanion() and DoesUnitExist(UNIT_COMPANION) then
        tins(currentPets, { unitTag = UNIT_COMPANION, unitName = zo_strformat("<<1>>", GetCompanionName(GetActiveCompanionDefId())) })
        UpdatePetStats(UNIT_COMPANION)
    end

    -- update
    zo_callLater(function() RefreshPetWindow() end, 300)
end

-----------
-- COMBAT --
-----------
local function OnPlayerCombatState(_, inCombat)
    --[[
    Setzt den Kampfstatus: in Kampf oder ausserhalb Kampf.
    ]]

    inCombatAddon = inCombat
    -- debug
    --ChatOutput(string.format("OnPlayerCombatState() inCombat: %s, inCombatAddon: %s", tos(inCombat), tos(inCombatAddon)))
    -- refresh
    RefreshPetWindow()
end

local function CreateWarner()
    if savedVars.useZosStyle then
        local HEALTH_ALPHA_PULSE_THRESHOLD = 0.25

        local RESOURCE_WARNER_FLASH_TIME   = 300

        PetHealthWarner                    = ZO_Object:Subclass()

        function PetHealthWarner:New(...)
            local warner = ZO_Object.New(self)
            warner:Initialize(...)
            return warner
        end

        function PetHealthWarner:Initialize(parent)
            self.warning       = GetControl(parent, "Warner")

            self.OnPowerUpdate = function(_, unitTag, powerIndex, powerType, health, maxHealth)
                self:OnHealthUpdate(health, maxHealth)
            end
            local function OnPlayerActivated()
                local current, max = GetUnitPower(self.unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
                self:OnHealthUpdate(current, max)
            end

            self.warning:RegisterForEvent(EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

            self.warnAnimation = ZO_AlphaAnimation:New(self.warning)
            self.statusBar     = parent
            self.paused        = false
        end

        function PetHealthWarner:SetPaused(paused)
            if self.paused ~= paused then
                self.paused = paused
                if paused then
                    if self.warnAnimation:IsPlaying() then
                        self.warnAnimation:Stop()
                    end
                else
                    local current, max = GetUnitPower(UNIT_PLAYER_TAG, COMBAT_MECHANIC_FLAGS_HEALTH)
                    self.warning:SetAlpha(0)
                    self:UpdateAlphaPulse(current / max)
                end
            end
        end

        function PetHealthWarner:UpdateAlphaPulse(healthPerc)
            if healthPerc <= HEALTH_ALPHA_PULSE_THRESHOLD then
                if not self.warnAnimation:IsPlaying() then
                    self.warnAnimation:PingPong(0, 1, RESOURCE_WARNER_FLASH_TIME)
                end
            else
                if self.warnAnimation:IsPlaying() then
                    self.warnAnimation:Stop()
                    self.warning:SetAlpha(0)
                end
            end
        end

        function PetHealthWarner:OnHealthUpdate(health, maxHealth)
            if not self.paused then
                local healthPerc = health / maxHealth
                self:UpdateAlphaPulse(healthPerc)
            end
        end
    end
end

--------------
-- CONTROLS --
--------------
local petHealthControlNamePrefix = addon.name .. "_"
local petHealthControlNameCounter = 0
local function CreateControls()
    -----------------
    -- ADD CONTROL --
    -----------------
    local function AddControl(parent, cType, level)
        petHealthControlNameCounter = petHealthControlNameCounter + 1
        local c = WINDOW_MANAGER:CreateControl(petHealthControlNamePrefix .. tos(petHealthControlNameCounter), parent, cType)
        c:SetDrawLayer(DL_OVERLAY)
        c:SetDrawLevel(level)
        return c, c
    end

    ---------------
    -- TOP LAYER --
    ---------------
    base = WINDOW_MANAGER:CreateTopLevelWindow(addon.name .. "_TopLevel")
    base:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT_BASE)
    base:SetAnchor(savedVars.point, GuiRoot, savedVars.relPoint, savedVars.x, savedVars.y)
    base:SetMouseEnabled(true)
    if savedVars.lockWindow == true then
        base:SetMovable(false)
    else
        base:SetMovable(true)
    end
    base:SetDrawLayer(DL_OVERLAY)
    base:SetDrawLevel(0)
    base:SetHandler("OnMouseUp", function()
        local a, b
        a, savedVars.point, b, savedVars.relPoint, savedVars.x, savedVars.y = base:GetAnchor(0)
    end)
    base:SetHidden(true)

    ----------------
    -- BACKGROUND --
    ----------------
    local INSET_BACKGROUND = 32
    local baseWidth        = base:GetWidth()
    local baseHeight       = base:GetHeight()
    local ctrl

    background, ctrl       = AddControl(base, CT_BACKDROP, 1)
    ctrl:SetEdgeTexture("esoui/art/chatwindow/chat_bg_edge.dds", 256, 128, INSET_BACKGROUND)
    ctrl:SetCenterTexture("esoui/art/chatwindow/chat_bg_center.dds")
    ctrl:SetInsets(INSET_BACKGROUND, INSET_BACKGROUND, -INSET_BACKGROUND, -INSET_BACKGROUND)
    ctrl:SetCenterColor(1, 1, 1, 0.8)
    ctrl:SetEdgeColor(1, 1, 1, 0.8)
    ctrl:SetDimensions(baseWidth, baseHeight)
    ctrl:SetAnchor(TOPLEFT)
    ctrl:SetAlpha(GetAlphaFromControl(savedVars.showBackground))

    --------------
    -- PET BARS --
    --------------
    if (not savedVars.useZosStyle) then
        for i = 1, MAX_PET_UNIT_TAGS do
            -- frame
            local currentPetWindow
            currentPetWindow, ctrl = AddControl(base, CT_BACKDROP, 5)
            window[i] = currentPetWindow
            ctrl:SetDimensions(baseWidth * 0.8, 36)
            ctrl:SetCenterColor(1, 0, 1, 0)
            ctrl:SetEdgeColor(1, 0, 1, 0)
            ctrl:SetAnchor(CENTER, base)

            -- label
            local windowHeight    = currentPetWindow:GetHeight()
            currentPetWindow.label, ctrl = AddControl(currentPetWindow, CT_LABEL, 10)
            ctrl:SetFont("$(BOLD_FONT)|$(KB_16)|soft-shadow-thin")
            ctrl:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
            ctrl:SetDimensions(baseWidth, windowHeight * 0.4)
            ctrl:SetAnchor(TOPLEFT, currentPetWindow)
            ctrl:SetAlpha(GetAlphaFromControl(savedVars.showLabels))

            -- border and background
            currentPetWindow.border, ctrl = AddControl(currentPetWindow, CT_BACKDROP, 20)
            ctrl:SetDimensions(currentPetWindow:GetWidth(), windowHeight * 0.45)
            ctrl:SetCenterColor(0, 0, 0, .6)
            ctrl:SetEdgeColor(1, 1, 1, 0.4)
            ctrl:SetEdgeTexture("", 1, 1, 1)
            ctrl:SetAnchor(BOTTOM, currentPetWindow)

            -- healthbar
            local borderWidth         = currentPetWindow.border:GetWidth()
            local borderHeight        = currentPetWindow.border:GetHeight()
            currentPetWindow.healthbar, ctrl = AddControl(currentPetWindow.border, CT_STATUSBAR, 30)
            ctrl:SetColor(1, 1, 1, 0.5)
            ctrl:SetGradientColors(.45, .13, .13, 1, .85, .19, .19, 1)
            ctrl:SetDimensions(borderWidth - 2, borderHeight - 2)
            ctrl:SetAnchor(CENTER, currentPetWindow.border)

            -- shield
            currentPetWindow.shield, ctrl = AddControl(currentPetWindow.healthbar, CT_STATUSBAR, 40)
            ctrl:SetColor(1, 1, 1, 0.5)
            ctrl:SetGradientColors(.5, .5, 1, .3, .25, .25, .5, .5)
            ctrl:SetDimensions(borderWidth - 2, borderHeight - 2)
            ctrl:SetAnchor(CENTER, currentPetWindow.healthbar)
            ctrl:SetValue(0)
            ctrl:SetMinMax(0, 1)

            -- values
            currentPetWindow.values, ctrl = AddControl(currentPetWindow.healthbar, CT_LABEL, 50)
            ctrl:SetFont("$(BOLD_FONT)|$(KB_14)|soft-shadow-thin")
            ctrl:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
            ctrl:SetAnchor(CENTER, currentPetWindow.healthbar)
            ctrl:SetAlpha(GetAlphaFromControl(savedVars.showValues))
            -- ctrl:SetHidden(not savedVars.showValues or false)

            -- clear anchors to reset it
            currentPetWindow:ClearAnchors()
            if i == 1 then
                currentPetWindow:SetAnchor(TOP, base, TOP, 0, 18)
            else
                --window[2]:SetAnchor(TOP, window[1], BOTTOM, 0, 2)
                --window[3]:SetAnchor(TOP, window[2], BOTTOM, 0, 2)
                currentPetWindow:SetAnchor(TOP, window[i - 1], BOTTOM, 0, 2)
            end
        end
    else
        local CHILD_DIRECTIONS = { "Left", "Right", "Center" }

        local function SetColors(self)
            local powerType = self.powerType
            local gradient  = ZO_POWER_BAR_GRADIENT_COLORS[powerType]
            for i, control in ipairs(self.barControls) do
                ZO_StatusBar_SetGradientColor(control, gradient)
                control:SetFadeOutLossColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_FADE_OUT, powerType))
                control:SetFadeOutGainColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_FADE_IN, powerType))
            end
        end

        local PAB_TEMPLATES = {
            [COMBAT_MECHANIC_FLAGS_HEALTH]   = {
                background = {
                    Left   = "ZO_PlayerAttributeBgLeftArrow",
                    Right  = "ZO_PlayerAttributeBgRightArrow",
                    Center = "ZO_PlayerAttributeBgCenter",
                },
                frame      = {
                    Left   = "ZO_PlayerAttributeFrameLeftArrow",
                    Right  = "ZO_PlayerAttributeFrameRightArrow",
                    Center = "ZO_PlayerAttributeFrameCenter",
                },
                warner     = {
                    texture = "ZO_PlayerAttributeHealthWarnerTexture",
                    Left    = "ZO_PlayerAttributeWarnerLeftArrow",
                    Right   = "ZO_PlayerAttributeWarnerRightArrow",
                    Center  = "ZO_PlayerAttributeWarnerCenter",
                },
                anchors    = {
                    "ZO_PlayerAttributeHealthBarAnchorLeft",
                    "ZO_PlayerAttributeHealthBarAnchorRight",
                },
            },
            statusBar            = "ZO_PlayerAttributeStatusBar",
            statusBarGloss       = "ZO_PlayerAttributeStatusBarGloss",
            resourceNumbersLabel = "ZO_PlayerAttributeResourceNumbers",
        }

        local function ApplyStyle(bar)
            local powerTypeTemplates  = PAB_TEMPLATES[bar.powerType]
            local backgroundTemplates = powerTypeTemplates.background
            local frameTemplates      = powerTypeTemplates.frame

            local warnerControl       = bar:GetNamedChild("Warner")
            local bgControl           = bar:GetNamedChild("BgContainer")

            local warnerTemplates     = powerTypeTemplates.warner

            for _, direction in pairs(CHILD_DIRECTIONS) do
                local bgChild = bgControl:GetNamedChild("Bg" .. direction)
                ApplyTemplateToControl(bgChild, ZO_GetPlatformTemplate(backgroundTemplates[direction]))

                local frameControl = bar:GetNamedChild("Frame" .. direction)
                ApplyTemplateToControl(frameControl, ZO_GetPlatformTemplate(frameTemplates[direction]))

                local warnerChild = warnerControl:GetNamedChild(direction)
                ApplyTemplateToControl(warnerChild, ZO_GetPlatformTemplate(warnerTemplates.texture))
                ApplyTemplateToControl(warnerChild, ZO_GetPlatformTemplate(warnerTemplates[direction]))
            end

            for i, subBar in pairs(bar.barControls) do
                ApplyTemplateToControl(subBar, ZO_GetPlatformTemplate(PAB_TEMPLATES.statusBar))

                local gloss = subBar:GetNamedChild("Gloss")
                ApplyTemplateToControl(gloss, ZO_GetPlatformTemplate(PAB_TEMPLATES.statusBarGloss))

                local anchorTemplates = powerTypeTemplates.anchors
                if anchorTemplates then
                    subBar:ClearAnchors()
                    ApplyTemplateToControl(subBar, ZO_GetPlatformTemplate(anchorTemplates[i]))
                else
                    ApplyTemplateToControl(subBar, ZO_GetPlatformTemplate(PAB_TEMPLATES.anchor))
                end
            end

            local resourceNumbersLabel = bar:GetNamedChild("ResourceNumbers")
            if resourceNumbersLabel then
                ApplyTemplateToControl(resourceNumbersLabel, ZO_GetPlatformTemplate(PAB_TEMPLATES.resourceNumbersLabel))
            end
        end

        for i = 1, MAX_PET_UNIT_TAGS do

            local currentPetWindow             = WINDOW_MANAGER:CreateControlFromVirtual("PetHealth" .. i, base, "PetHealth_ZOSStyleBar")
            window[i] = currentPetWindow

            -- label
            local windowHeight    = currentPetWindow:GetHeight()
            currentPetWindow.label, ctrl = AddControl(currentPetWindow, CT_LABEL, 10)
            ctrl:SetFont("$(BOLD_FONT)|$(KB_16)|soft-shadow-thin")
            ctrl:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
            ctrl:SetDimensions(baseWidth, windowHeight * 0.4)
            ctrl:SetAnchor(BOTTOMLEFT, currentPetWindow, TOPLEFT, 0, -10.5)
            ctrl:SetAlpha(GetAlphaFromControl(savedVars.showLabels))

            -- bars
            currentPetWindow.barleft     = currentPetWindow:GetNamedChild("BarLeft")
            currentPetWindow.barright    = currentPetWindow:GetNamedChild("BarRight")

            currentPetWindow.barControls = { currentPetWindow.barleft, currentPetWindow.barright }
            currentPetWindow.powerType   = COMBAT_MECHANIC_FLAGS_HEALTH

            SetColors(currentPetWindow)
            ApplyStyle(currentPetWindow)

            -- shield
            currentPetWindow.shieldleft  = currentPetWindow:GetNamedChild("ShieldLeft")
            currentPetWindow.shieldright = currentPetWindow:GetNamedChild("ShieldRight")

            -- values
            currentPetWindow.values      = currentPetWindow:GetNamedChild("ResourceNumbers")
            currentPetWindow.values:SetAlpha(GetAlphaFromControl(savedVars.showValues))
            -- ctrl:SetHidden(not savedVars.showValues or false)

            currentPetWindow.warner = PetHealthWarner:New(currentPetWindow)

            if i == 1 then
                currentPetWindow:SetAnchor(TOP, base, TOP, 0, 18)
            else
                currentPetWindow:SetAnchor(TOP, window[i - 1], BOTTOM, 0, 20)
            end
        end

        --[[
        window[1]:SetAnchor(TOP, base, TOP, 0, 18)
        window[2]:SetAnchor(TOP, window[1], BOTTOM, 0, 20)
        window[3]:SetAnchor(TOP, window[2], BOTTOM, 0, 20)
        ]]
    end

    -----------
    -- SCENE --
    -----------
    PET_BAR_FRAGMENT = ZO_HUDFadeSceneFragment:New(base)
    HUD_SCENE:AddFragment(PET_BAR_FRAGMENT)
    HUD_UI_SCENE:AddFragment(PET_BAR_FRAGMENT)
    PET_BAR_FRAGMENT:SetHiddenForReason("NoPetOrOnlyInCombat", true)
end

local function OnUnitDestroyed(eventCode, unitTag)
    local doDebug = false
    --[[
    if unitTag == UNIT_COMPANION then
        doDebug = true
    end
    ]]

    PetUnSummonedAlerts(unitTag)
    local key = GetKeyWithData(unitTag)
    if key ~= nil then
        trem(currentPets, key)
        -- debug
        --ChatOutput(string.format("%s destroyed", unitTag))
        -- refresh
        local countPets = GetTableSize(currentPets)
        if countPets > 0 then
            for i = 1, countPets do
                local currentPetData = currentPets[i]
                local currentPetWindow = window[i]
                if currentPetWindow ~= nil then
                    local name    = currentPetData.unitName
                    if doDebug then d("[PetHealth]OnUnitDestroyed - name: " ..tos(name)) end

                    local control = currentPetWindow.label
                    unitTag       = currentPetData.unitTag
                    if GetControlText(control) ~= name then
                        control:SetText(name)
                    end
                    GetHealth(unitTag, doDebug)
                    GetShield(unitTag, doDebug)
                end
            end
        end
        RefreshPetWindow()
    end
end

local function OnUnitCreated(eventCode, unitTag)
    if unitTag == UNIT_COMPANION or IsUnitValidPet(unitTag) then
        GetActivePets()
    end
end

local INACTIVE_COMPANION_STATES = {
    [COMPANION_STATE_INACTIVE]          = true,
    [COMPANION_STATE_BLOCKED_PERMANENT] = true,
    [COMPANION_STATE_BLOCKED_TEMPORARY] = true,
    [COMPANION_STATE_HIDDEN]            = true,
    [COMPANION_STATE_INITIALIZING]      = true,
}

local PENDING_COMPANION_STATES  = {
    [COMPANION_STATE_PENDING]             = true,
    [COMPANION_STATE_INITIALIZED_PENDING] = true,
}

local ACTIVE_COMPANION_STATES   = {
    [COMPANION_STATE_ACTIVE] = true,
}

local function OnCompanionStateChanged(eventCode, newState, oldState)

    local showCompanion = savedVars.showCompanion

    if INACTIVE_COMPANION_STATES[newState] then
        OnUnitDestroyed(eventCode, UNIT_COMPANION)
    elseif PENDING_COMPANION_STATES[newState] then
        -- Could display pending...
        --if not showCompanion then return end
    elseif ACTIVE_COMPANION_STATES[newState] then
        if not showCompanion then return end
        OnUnitCreated(eventCode, UNIT_COMPANION)
    else
        --internalassert(false, "Unhandled companion state")
    end
end

----------
-- INIT --
----------
local function LoadEvents()
    -- events
    local addonName = addon.name
    local companionEventName = addonName .. UNIT_COMPANION

    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ACTIVE_COMPANION_STATE_CHANGED, OnCompanionStateChanged)

    --pet
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_POWER_UPDATE, OnHealthUpdate)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_UNIT_CREATED, OnUnitCreated)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_UNIT_DESTROYED, OnUnitDestroyed)

    EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, UNIT_PLAYER_PET, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
    EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_UNIT_CREATED, REGISTER_FILTER_UNIT_TAG_PREFIX, UNIT_PLAYER_PET)
    EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_UNIT_DESTROYED, REGISTER_FILTER_UNIT_TAG_PREFIX, UNIT_PLAYER_PET)

    EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, UNIT_PLAYER_PET)
    EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, UNIT_PLAYER_PET)
    EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, UNIT_PLAYER_PET)

    --companion
    EVENT_MANAGER:RegisterForEvent(companionEventName, EVENT_POWER_UPDATE, OnHealthUpdate)
    EVENT_MANAGER:RegisterForEvent(companionEventName, EVENT_UNIT_CREATED, OnUnitCreated)
    EVENT_MANAGER:RegisterForEvent(companionEventName, EVENT_UNIT_DESTROYED, OnUnitDestroyed)

    EVENT_MANAGER:AddFilterForEvent(companionEventName, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, UNIT_COMPANION, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
    EVENT_MANAGER:AddFilterForEvent(companionEventName, EVENT_UNIT_CREATED, REGISTER_FILTER_UNIT_TAG_PREFIX, UNIT_COMPANION)
    EVENT_MANAGER:AddFilterForEvent(companionEventName, EVENT_UNIT_DESTROYED, REGISTER_FILTER_UNIT_TAG_PREFIX, UNIT_COMPANION)

    EVENT_MANAGER:AddFilterForEvent(companionEventName, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, UNIT_COMPANION)
    EVENT_MANAGER:AddFilterForEvent(companionEventName, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, UNIT_COMPANION)
    EVENT_MANAGER:AddFilterForEvent(companionEventName, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, UNIT_COMPANION)

    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_DEAD, GetActivePets)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_UNIT_DEATH_STATE_CHANGE, GetActivePets)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ACTION_SLOT_ABILITY_SLOTTED, GetActivePets)

    EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_PLAYER_DEAD, REGISTER_FILTER_UNIT_TAG, UNIT_PLAYER_TAG)
    EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_UNIT_DEATH_STATE_CHANGE, REGISTER_FILTER_UNIT_TAG, UNIT_PLAYER_TAG)
    -- shield
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(_, unitTag, unitAttributeVisual, _, _, _, value, maxValue)
        if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
            OnShieldUpdate(nil, unitTag, value, maxValue, "true")
        end
    end)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(_, unitTag, unitAttributeVisual, _, _, _, value, maxValue)
        if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
            OnShieldUpdate("removed", unitTag, value, maxValue, "false")
        end
    end)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function(_, unitTag, unitAttributeVisual, _, _, _, _, newValue, _, newMaxValue)
        if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
            OnShieldUpdate(nil, unitTag, newValue, newMaxValue, "false")
        end
    end)


    -- for changes the style of the values
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_INTERFACE_SETTING_CHANGED, GetActivePets)
    EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_INTERFACE_SETTING_CHANGED, REGISTER_FILTER_SETTING_SYSTEM_TYPE, SETTING_TYPE_UI)
    -- handles the in combat stuff
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
    OnPlayerCombatState(_, IsUnitInCombat(UNIT_PLAYER_TAG))
    -- zone changes
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, function() zo_callLater(function() GetActivePets() end, 75) end)
end

function PetHealth.changeCombatState()
    OnPlayerCombatState(_, IsUnitInCombat(UNIT_PLAYER_TAG))
end

function PetHealth.hideInDungeon(toValue)
    hideInDungeon = toValue
    RefreshPetWindow()
end

function PetHealth.changeBackground(toValue)
    background:SetAlpha(GetAlphaFromControl(toValue))
end

function PetHealth.changeValues(toValue)
    for i = 1, MAX_PET_UNIT_TAGS do
        -- local alpha = GetAlphaFromControl(savedVars.showValues)
        -- d(alpha)
        window[i].values:SetAlpha(GetAlphaFromControl(toValue))
    end
end

function PetHealth.changeLabels(toValue)
    for i = 1, MAX_PET_UNIT_TAGS do
        window[i].label:SetAlpha(GetAlphaFromControl(toValue))
    end
end

function PetHealth.changeCompanion(toValue)
    savedVars.showCompanion = toValue
    GetActivePets()
end

function PetHealth.lockPetWindow(toValue)
    lockWindow = toValue
end

function PetHealth.lowHealthAlertPercentage(toValue)
    lowHealthAlertPercentage = toValue
end

function PetHealth.lowShieldAlertPercentage(toValue)
    lowShieldAlertPercentage = toValue
end

function PetHealth.unsummonedAlerts(toValue)
    unsummonedAlerts = toValue
end

function PetHealth.onlyInCombatHealthPercentage(toValue)
    onlyInCombatHealthPercentage = toValue
end

local function SlashCommands()
	local function slash_pethealthdebug()
	 	savedVars.debug = not savedVars.debug
     	savedVars.debug = savedVars.debug
     	if savedVars.debug then
     		d(string.format("%s %s!", GetString(SI_SETTINGSYSTEMPANEL6), GetString(SI_ADDONLOADSTATE2)))
     	else
     		d(string.format("%s %s!", GetString(SI_SETTINGSYSTEMPANEL6), GetString(SI_ADDONLOADSTATE3)))
     	end
	end
	local function slash_pethealthcombat()
		savedVars.onlyInCombat = not savedVars.onlyInCombat
        if savedVars.onlyInCombat then
            d(GetString(SI_PET_HEALTH_COMBAT_ACTIVATED))
        else
            d(GetString(SI_PET_HEALTH_COMBAT_DEACTIVATED))
        end
        PetHealth.changeCombatState()
	end
	local function slash_pethealthhideindungeon()
		savedVars.hideInDungeon = not savedVars.hideInDungeon
        if savedVars.hideInDungeon then
            d(GetString(SI_PET_HEALTH_HIDE_IN_DUNGEON_ACTIVATED))
        else
            d(GetString(SI_PET_HEALTH_HIDE_IN_DUNGEON_DEACTIVATED))
        end
        PetHealth.hideInDungeon()
	end
	local function slash_pethealthvalues()
        savedVars.showValues = not savedVars.showValues
        if savedVars.showValues then
            d(GetString(SI_PET_HEALTH_VALUES_ACTIVATED))
        else
            d(GetString(SI_PET_HEALTH_VALUES_DEACTIVATED))
        end
        PetHealth.changeValues(savedVars.showValues)	
	end
	local function slash_pethealthlabels()
        savedVars.showLabels = not savedVars.showLabels
        if savedVars.showLabels then
            d(GetString(SI_PET_HEALTH_LABELS_ACTIVATED))
        else
            d(GetString(SI_PET_HEALTH_LABELS_DEACTIVATED))
        end
        PetHealth.changeLabels(savedVars.showLabels)	
	end
	local function slash_pethealthbackground()
            savedVars.showBackground = not savedVars.showBackground
            if savedVars.showBackground then
                d(GetString(SI_PET_HEALTH_BACKGROUND_ACTIVATED))
            else
                d(GetString(SI_PET_HEALTH_BACKGROUND_DEACTIVATED))
            end
            PetHealth.changeBackground(savedVars.showBackground)	
	end
	local function slash_pethealthunsummonedalerts() 
		savedVars.petUnsummonedAlerts = not savedVars.petUnsummonedAlerts
        if savedVars.petUnsummonedAlerts then
            d(GetString(SI_PET_HEALTH_UNSUMMONEDALERTS_ACTIVATED))
        else
            d(GetString(SI_PET_HEALTH_UNSUMMONEDALERTS_DEACTIVATED))
        end
        PetHealth.unsummonedAlerts(savedVars.petUnsummonedAlerts)
	
	end
	local function slash_pethealthwarnhealth(healthValuePercent)
		if healthValuePercent == nil or healthValuePercent == "" then
            d(GetString(SI_PET_HEALTH_LAM_LOW_HEALTH_WARN) .. ": " .. tos(savedVars.lowHealthAlertSlider))
        else
            local healthValuePercentNumber = tonumber(healthValuePercent)
            if type(healthValuePercentNumber) == "number" then
                if healthValuePercentNumber <= 0 then healthValuePercentNumber = 0 end
                if healthValuePercentNumber >= 100 then healthValuePercentNumber = 99 end
                savedVars.lowHealthAlertSlider = healthValuePercentNumber
                PetHealth.lowHealthAlertPercentage(healthValuePercentNumber)
                d(GetString(SI_PET_HEALTH_LAM_LOW_HEALTH_WARN) .. ": " .. tos(healthValuePercentNumber))
            end
        end
	end
	local function slash_pethealthwarnshield(shieldValuePercent)
	    if shieldValuePercent == nil or shieldValuePercent == "" then
            d(GetString(SI_PET_HEALTH_LAM_LOW_SHIELD_WARN) .. ": " .. tos(savedVars.lowShieldAlertSlider))
        else
            local shieldValuePercentNumber = tonumber(shieldValuePercent)
            if type(shieldValuePercentNumber) == "number" then
                if shieldValuePercentNumber <= 0 then shieldValuePercentNumber = 0 end
                if shieldValuePercentNumber >= 100 then shieldValuePercentNumber = 99 end
                savedVars.lowShieldAlertSlider = shieldValuePercentNumber
                PetHealth.lowShieldAlertPercentage(shieldValuePercentNumber)
                d(GetString(SI_PET_HEALTH_LAM_LOW_SHIELD_WARN) .. ": " .. tos(shieldValuePercentNumber))
            end
        end
	end
	local function slash_pethealthcombathealth(combatHealthValuePercent)
		if combatHealthValuePercent == nil or combatHealthValuePercent == "" then
            d(GetString(SI_PET_HEALTH_LAM_ONLY_IN_COMBAT_HEALTH) .. ": " .. tos(savedVars.onlyInCombatHealthSlider))
        else
            local combatHealthPercentNumber = tonumber(combatHealthValuePercent)
            if type(combatHealthPercentNumber) == "number" then
                if combatHealthPercentNumber <= 0 then combatHealthPercentNumber = 0 end
                if combatHealthPercentNumber >= 100 then combatHealthPercentNumber = 99 end
                savedVars.onlyInCombatHealthSlider = combatHealthPercentNumber
                PetHealth.onlyInCombatHealthPercentage(combatHealthPercentNumber)
                d(GetString(SI_PET_HEALTH_LAM_ONLY_IN_COMBAT_HEALTH) .. ": " .. tos(combatHealthPercentNumber))
            end
        end
	end	
	if LSC then
		-- LSC:Register("/pethealthdebug", function() slash_pethealthdebug() end, GetString(SI_PET_HEALTH_LSC_DEBUG))
		LSC:Register("/pethealthcombat", function() slash_pethealthcombat() end, GetString(SI_PET_HEALTH_LSC_COMBAT))
		LSC:Register("/pethealthhideindungeon", function() slash_pethealthhideindungeon() end, GetString(SI_PET_HEALTH_LSC_DUNGEON))
		LSC:Register("/pethealthvalues", function() slash_pethealthvalues() end, GetString(SI_PET_HEALTH_LSC_VALUES))
		LSC:Register("/pethealthlabels", function() slash_pethealthlabels() end, GetString(SI_PET_HEALTH_LSC_LABELS))
		if not savedVars.useZosStyle then LSC:Register("/pethealthbackground", function() slash_pethealthbackground() end, GetString(SI_PET_HEALTH_LSC_BACKGROUND))
		else
			-- Forcing show background to off for anyone that may have accidentally enabled this when ZOS style frames are enabled
			showBackground           = false
			savedVars.showBackground = false
		end
		LSC:Register("/pethealthunsummonedalerts", function() slash_pethealthunsummonedalerts() end, GetString(SI_PET_HEALTH_LSC_UNSUMMONEDALERTS))
		LSC:Register("/pethealthwarnhealth", function(healthValuePercent) slash_pethealthwarnhealth(healthValuePercent) end, GetString(SI_PET_HEALTH_LSC_WARN_HEALTH))
		LSC:Register("/pethealthwarnshield", function(shieldValuePercent) slash_pethealthwarnshield(shieldValuePercent) end, GetString(SI_PET_HEALTH_LSC_WARN_SHIELD))
		LSC:Register("/pethealthcombathealth", function(combatHealthValuePercent) slash_pethealthcombathealth(combatHealthValuePercent) end, GetString(SI_PET_HEALTH_LSC_COMBAT_HEALTH))
	else
	--  SLASH_COMMANDS["/pethealthdebug"]=function() slash_pethealthdebug() end
		SLASH_COMMANDS["/pethealthcombat"]=function() slash_pethealthcombat() end
		SLASH_COMMANDS["/pethealthhideindungeon"]=function() slash_pethealthhideindungeon() end
		SLASH_COMMANDS["/pethealthvalues"]=function() slash_pethealthvalues() end
		SLASH_COMMANDS["/pethealthlabels"]=function() slash_pethealthlabels() end
		if not savedVars.useZosStyle then SLASH_COMMANDS["/pethealthbackground"]=function() slash_pethealthbackground() end
		else
			-- Forcing show background to off for anyone that may have accidentally enabled this when ZOS style frames are enabled
			showBackground           = false
			savedVars.showBackground = false
		end
		SLASH_COMMANDS["/pethealthunsummonedalerts"]=function() slash_pethealthunsummonedalerts() end
		SLASH_COMMANDS["/pethealthwarnhealth"]=function(healthValuePercent) slash_pethealthwarnhealth(healthValuePercent) end
		SLASH_COMMANDS["/pethealthwarnshield"]=function(shieldValuePercent) slash_pethealthwarnshield(shieldValuePercent) end
		SLASH_COMMANDS["/pethealthcombathealth"]=function(combatHealthValuePercent) slash_pethealthcombathealth(combatHealthValuePercent) end
		
	end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= addon.name then return end
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

    savedVars = ZO_SavedVars:NewAccountWide(addon.savedVarName, addon.savedVarVersion, nil, default, GetWorldName())
    if savedVars.saveMode == 1 then
        savedVars = ZO_SavedVars:NewCharacterIdSettings(addon.savedVarName, addon.savedVarVersion, nil, default, GetWorldName())
    end

    --savedVarCopy = savedVars -- during playing, it takes only the local savedVars settings instead picking the savedVars
    PetHealth.savedVars          = savedVars
    PetHealth.savedVarsDefault   = default
    lowHealthAlertPercentage     = savedVars.lowHealthAlertSlider
    lowShieldAlertPercentage     = savedVars.lowShieldAlertSlider
    unsummonedAlerts             = savedVars.petUnsummonedAlerts
    onlyInCombatHealthPercentage = savedVars.onlyInCombatHealthSlider

    -- Addon is only enabled for the classIds which are given with the value true in the table PetHealth.supportedClasses
    local getUnitClassId         = GetUnitClassId(UNIT_PLAYER_TAG)
    local supportedClasses       = PetHealth.supportedClasses
    local supportedClass         = supportedClasses[getUnitClassId] or savedVars.showCompanion
    if not supportedClass then
        -- debug
        ChatOutput("[PetHealth] " .. GetString(SI_PET_HEALTH_CLASS))
        return
    end

    PetHealth.updateExcludedZonesForHide()

    --Makes libs completely optional
    --If users want to change default values or expanded funcitonality, they will need to install applicable libs
    LAM = LibAddonMenu2
    LSC = LibSlashCommander

    if LAM then
        --Build the LAM addon menu if the library LibAddonMenu-2.0 was found loaded properly
        PetHealth.LAM = LAM
        PetHealth.buildLAMAddonMenu()
    end

    
    --Build the slash commands if the library LibSlashCommander was found loaded properly
    SlashCommands()
    

    -- create ui
    CreateWarner()
    CreateControls()
    -- do stuff
    --GetActivePets()
    LoadEvents()

    -- debug
    --ChatOutput("loaded")
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)