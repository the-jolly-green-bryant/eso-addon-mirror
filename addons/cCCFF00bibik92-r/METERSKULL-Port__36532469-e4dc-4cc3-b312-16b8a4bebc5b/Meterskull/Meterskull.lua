--------------------------------------------------------------------------------
-- GLOBAL TABLE
--------------------------------------------------------------------------------
Meterskull = {
    name     = "Meterskull",
    version  = "1.5.3",
    modules  = {},
    db       = {},
    defaults = {},
}

-- Shortcut references
local MS = Meterskull
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER

-- Debug function fallback
local function DebugLog(msg)
    if d then
        d(msg)
    else
        if CHAT_ROUTER then
            CHAT_ROUTER:AddSystemMessage(msg)
        end
    end
end

--------------------------------------------------------------------------------
-- REQUIREMENTS
--------------------------------------------------------------------------------
local LAM2 = LibAddonMenu2


local function InitializeMeterskullUI()
    if not _G.UILayoutConfig then
        DebugLog("Meterskull ERROR: UILayoutConfig not available")
        return
    end
    _G.InitializeUI(MS)
end

--------------------------------------------------------------------------------
-- DEFAULT SETTINGS
--------------------------------------------------------------------------------
local defaults = {
    sharedSettings = {
        accountWideSettings  = true,
        uiLocked             = false,
        renderTick           = 1000,   -- ms
        showArmorskull       = true,
        showHybridarmorskull = false,
        showPowerskull       = true,
        showCritskull        = true,
        showCritresiskull    = false,
        showPenskull         = true,
        showHealthskull      = false,
        showMagskull         = false,
        showStamskull        = false,
        animationDuration    = "standard",
    },
    armorskull = {
        location = { x = 100, y = 100 },
        settings = {
            customScale     = 20,
            backgroundColor = { 0, 0, 0, 0.8 },
            levels = {
                physical = {
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                },
                spell = {
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                },
            },
        },
    },
    hybridarmorskull = {
        location = { x = 100, y = 200 },
        settings = {
            customScale     = 20,
            backgroundColor = { 0, 0, 0, 0.8 },
            levels = {
                lowestResist = {
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                },
            },
        },
    },
    powerskull = {
        location = { x = 100, y = 300 },
        settings = {
            customScale     = 20,
            backgroundColor = { 0, 0, 0, 0.8 },
            levels = {
                power = {
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                },
            },
        },
    },
    critskull = {
        location = { x = 100, y = 400 },
        settings = {
            customScale     = 20,
            backgroundColor = { 0, 0, 0, 0.8 },
            levels = {
                critChance = {
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                },
                critDamage = {
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 0, 1, 0, 1 }, level = 125 },
                },
            },
        },
    },
    critresiskull = {
        location = { x = 400, y = 400 },
        settings = {
            customScale     = 20,
            backgroundColor = { 0, 0, 0, 0.8 },
            levels = {
                critResist = {
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                },
            },
        },
    },
    penskull = {
        location = { x = 100, y = 500 },
        settings = {
            customScale     = 20,
            backgroundColor = { 0, 0, 0, 0.8 },
            levels = {
                penetration = {
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 0, 1, 0, 1 }, level = 18200 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                },
            },
        },
    },
    healthskull = {
        location = { x = 400, y = 100 },
        settings = {
            customScale     = 20,
            backgroundColor = { 0, 0, 0, 0.8 },
            levels = {
                recovery = {
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                },
            },
        },
    },
    magskull = {
        location = { x = 400, y = 200 },
        settings = {
            customScale     = 20,
            backgroundColor = { 0, 0, 0, 0.8 },
            levels = {
                recovery = {
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                },
            },
        },
    },
    stamskull = {
        location = { x = 400, y = 300 },
        settings = {
            customScale     = 20,
            backgroundColor = { 0, 0, 0, 0.8 },
            levels = {
                recovery = {
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                    { color = { 1, 1, 1, 1 }, level = 0 },
                },
            },
        },
    },
}
MS.defaults = defaults

--------------------------------------------------------------------------------
-- ANIMATION UTILS
--------------------------------------------------------------------------------
local animationDurations = {
    off      = 0,
    fast     = 150,
    standard = 300,
    slow     = 450,
}

-- Frame update intervals based on chosen duration (optimization)
local frameIntervals = {
    fast     = 8,   -- ~120fps
    standard = 16,  -- ~60fps
    slow     = 33,  -- ~30fps
    off      = 0,
}

local function EaseOutExpo(t, b, c, d)
    return c * (-math.pow(2, -10 * t / d) + 1) + b
end

function MS.AnimateTextTransition(control, startValue, endValue, formatString, animationType)
    formatString = formatString or "%.0f"
    startValue = startValue or 0
    endValue = endValue or 0

    local animName  = control:GetName() .. "Animation"
    local startTime = GetFrameTimeMilliseconds()

    -- Use unified setting; fallback to "standard" if missing/invalid
    local animDurationSetting = MS.db.sharedSettings.animationDuration
    local duration = animationDurations[animDurationSetting] or animationDurations.standard
    local tick     = frameIntervals[animDurationSetting] or frameIntervals.standard

    local endTime    = startTime + duration
    local initialVal = startValue

    local function OnUpdate()
        local now = GetFrameTimeMilliseconds()
        if now >= endTime then
            control:SetText(string.format(formatString, endValue))
            EVENT_MANAGER:UnregisterForUpdate(animName)
            return
        end

        local elapsedTime  = now - startTime
        local progress     = EaseOutExpo(elapsedTime, 0, 1, duration)
        local safeInitial  = initialVal or 0
        local safeEnd      = endValue or 0
        local currentValue = safeInitial + (safeEnd - safeInitial) * progress
        control:SetText(string.format(formatString, currentValue))
    end

    EVENT_MANAGER:UnregisterForUpdate(animName)

    if duration > 0 and tick > 0 then
        EVENT_MANAGER:RegisterForUpdate(animName, tick, OnUpdate)
    else
        control:SetText(string.format(formatString, endValue))
    end
end

--------------------------------------------------------------------------------
-- SHARED UTILS
--------------------------------------------------------------------------------
function MS.GetThresholdColor(thresholds, value)
    local finalColor = { 1, 1, 1, 1 }
    for _, data in ipairs(thresholds) do
        local lvl = tonumber(data.level) or 0
        if lvl ~= 0 and value >= lvl then
            finalColor = data.color
        end
    end
    return finalColor
end

function MS.RegisterModule(moduleTable)
    MS.modules[moduleTable.name] = moduleTable
end



--------------------------------------------------------------------------------
-- DEFAULT SCALE
--------------------------------------------------------------------------------
local function DefaultScale(self, value)
    local cfg = _G.ModuleUIConfig[self.name]
    if not cfg or not self.uiRefs then return end

    local UIConfig = _G.UILayoutConfig
    local scaleConfig = UIConfig and UIConfig.SCALE_FORMULA
    local scaleFactor
    if scaleConfig then
        local defaultValue = scaleConfig.DEFAULT_VALUE or 20
        if value == defaultValue then
            scaleFactor = 1.0
        elseif value < defaultValue then
            local ratio = value / defaultValue
            scaleFactor = scaleConfig.MIN_SCALE + (1.0 - scaleConfig.MIN_SCALE) * ratio
        else
            local ratio = (value - defaultValue) / (100 - defaultValue)
            scaleFactor = 1.0 + (scaleConfig.MAX_SCALE - 1.0) * ratio
        end
    else
        scaleFactor = 0.5 + (value * 2.5 / 100)
    end

    local big   = tostring(32 * scaleFactor)
    local small = tostring(14 * scaleFactor)

    for _, field in ipairs(cfg.fields) do
        local valueControl = self.uiRefs[field.name]
        local labelControl = self.uiRefs[field.name .. "Label"]

        if valueControl then
            valueControl:SetFont('$(GAMEPAD_BOLD_FONT)|'..big..'|thin-outline')
        end
        if labelControl then
            labelControl:SetFont('$(BOLD_FONT)|'..small..'|thin-outline')
        end
    end

    local w = cfg.baseSize.w * scaleFactor
    local h = cfg.baseSize.h * scaleFactor
    self.uiRefs.main:SetDimensions(w, h)
    self.uiRefs.bg:SetDimensions(w, h)

    if _G.RecalculateModuleLayout then
        _G.RecalculateModuleLayout(self.name, value)
    end
end

--------------------------------------------------------------------------------
-- CREATE MODULE FACTORY
--------------------------------------------------------------------------------
function MS.CreateModule(name, dbKey, uiRefs, namespace, renderFunc, scaleFunc)
    local mod = {
        name           = name,
        dbKey          = dbKey,
        uiRefs         = uiRefs,
        eventNamespace = namespace or name,
        currentData    = {},
        fragment       = nil,
    }

    function mod:Initialize()
        if not self.uiRefs or not self.uiRefs.main then
            DebugLog("Meterskull ERROR: uiRefs not available for " .. self.name)
            return
        end
        self.fragment = ZO_HUDFadeSceneFragment:New(self.uiRefs.main,nil,0)
        SCENE_MANAGER:GetScene("hud"):AddFragment(self.fragment)
        SCENE_MANAGER:GetScene("hudui"):AddFragment(self.fragment)

        EVENT_MANAGER:RegisterForUpdate(
            self.eventNamespace.."Render",
            MS.db.sharedSettings.renderTick,
            function() self:Render() end
        )

        self.uiRefs.bg:SetCenterColor(unpack(MS.db[self.dbKey].settings.backgroundColor))
        self:CustomScale(MS.db[self.dbKey].settings.customScale)

        self.uiRefs.main:ClearAnchors()
        self.uiRefs.main:SetAnchor(
            TOPLEFT, GuiRoot, TOPLEFT,
            MS.db[self.dbKey].location.x,
            MS.db[self.dbKey].location.y
        )
    end

    function mod:Render(initial) if renderFunc then renderFunc(self,initial) end end
    function mod:CustomScale(v)   if scaleFunc  then scaleFunc(self,v)       end end
    function mod:ToggleVisibility(show)
        local showKey = "show"..string.gsub(self.name,"^%l",string.upper)
        MS.db.sharedSettings[showKey] = show
        if not self.uiRefs or not self.uiRefs.main then return end

        local playerIsDead = IsUnitDead("player")
        local shouldShow = show and not playerIsDead

        if shouldShow then
            if not self.fragment then
                self.fragment = ZO_HUDFadeSceneFragment:New(self.uiRefs.main,nil,0)
            end
            SCENE_MANAGER:GetScene("hud"):AddFragment(self.fragment)
            SCENE_MANAGER:GetScene("hudui"):AddFragment(self.fragment)
        else
            if self.fragment then
                SCENE_MANAGER:GetScene("hud"):RemoveFragment(self.fragment)
                SCENE_MANAGER:GetScene("hudui"):RemoveFragment(self.fragment)
                if playerIsDead then
                else
                    self.fragment = nil
                end
            end
        end
    end
    function mod:SaveLocation()
        local left,top = self.uiRefs.main:GetLeft(), self.uiRefs.main:GetTop()
        MS.db[self.dbKey].location.x, MS.db[self.dbKey].location.y = left, top
    end

    return mod
end


--------------------------------------------------------------------------------
-- ARMORSKULL MODULE
--------------------------------------------------------------------------------
local function ArmorskullRender(self, initial)
    local physicalResist = GetPlayerStat(STAT_DAMAGE_RESIST_PHYSICAL)
    local spellResist    = GetPlayerStat(STAT_DAMAGE_RESIST_MAGIC)

    if initial or physicalResist ~= (self.currentData.physicalResist or 0) then
        MS.AnimateTextTransition(
            self.uiRefs.PhysicalResist,
            self.currentData.physicalResist or 0,
            physicalResist,
            "%d",
            self.name
        )
        self.currentData.physicalResist = physicalResist
        self.uiRefs.PhysicalResist:SetColor(unpack(
            MS.GetThresholdColor(
                MS.db.armorskull.settings.levels.physical,
                physicalResist
            )
        ))
    end

    if initial or spellResist ~= (self.currentData.spellResist or 0) then
        MS.AnimateTextTransition(
            self.uiRefs.SpellResist,
            self.currentData.spellResist or 0,
            spellResist,
            "%d",
            self.name
        )
        self.currentData.spellResist = spellResist
        self.uiRefs.SpellResist:SetColor(unpack(
            MS.GetThresholdColor(
                MS.db.armorskull.settings.levels.spell,
                spellResist
            )
        ))
    end
end

local ArmorskullModule = MS.CreateModule(
    "armorskull",
    "armorskull",
    nil,
    "MSArmorskull",
    ArmorskullRender,
    DefaultScale
)
MS.RegisterModule(ArmorskullModule)
_G["ArmorskullModule"] = ArmorskullModule

function MS_ArmorskullUI_SaveLocation()
    ArmorskullModule:SaveLocation()
end

--------------------------------------------------------------------------------
-- HYBRIDARMORSKULL MODULE
--------------------------------------------------------------------------------
local function HybridArmorskullRender(self, initial)
    local physicalResist = GetPlayerStat(STAT_DAMAGE_RESIST_PHYSICAL)
    local spellResist    = GetPlayerStat(STAT_DAMAGE_RESIST_MAGIC)

    local lowestResist  = math.min(physicalResist, spellResist)
    local isPhysicalLow = (physicalResist <= spellResist)

    local oldVal        = self.currentData.resistLevel   or 0
    local oldIsPhysical = self.currentData.isPhysicalLow

    if initial or lowestResist ~= oldVal or isPhysicalLow ~= oldIsPhysical then
        self.currentData.resistLevel   = lowestResist
        self.currentData.isPhysicalLow = isPhysicalLow

        MS.AnimateTextTransition(
            self.uiRefs.Resist, oldVal, lowestResist, "%d", self.name
        )
        self.uiRefs.Resist:SetColor(unpack(
            MS.GetThresholdColor(
                MS.db.hybridarmorskull.settings.levels.lowestResist,
                lowestResist
            )
        ))

        self.uiRefs.ResistLabel:SetText(isPhysicalLow and "PR" or "SR")
    end
end

local HybridArmorskullModule = MS.CreateModule(
    "hybridarmorskull",
    "hybridarmorskull",
    nil,
    "MSHybridArmorskull",
    HybridArmorskullRender,
    DefaultScale
)
MS.RegisterModule(HybridArmorskullModule)
_G["HybridArmorskullModule"] = HybridArmorskullModule

function MS_HybridarmorskullUI_SaveLocation()
    HybridArmorskullModule:SaveLocation()
end

--------------------------------------------------------------------------------
-- POWERSKULL MODULE
--------------------------------------------------------------------------------
local function PowerskullRender(self, initial)
    local power  = math.max(
        GetPlayerStat(STAT_POWER),
        GetPlayerStat(STAT_SPELL_POWER)
    )

    local oldVal = self.currentData.powerLevel or 0

    if initial or power ~= oldVal then
        self.currentData.powerLevel = power

        MS.AnimateTextTransition(self.uiRefs.Power, oldVal, power, "%d", self.name)
        self.uiRefs.Power:SetColor(unpack(
            MS.GetThresholdColor(MS.db.powerskull.settings.levels.power, power)
        ))

        self.uiRefs.PowerLabel:SetText("PWR")
    end
end

local PowerskullModule = MS.CreateModule(
    "powerskull",
    "powerskull",
    nil,
    "MSPowerskull",
    PowerskullRender,
    DefaultScale
)
MS.RegisterModule(PowerskullModule)
_G["PowerskullModule"] = PowerskullModule

function MS_PowerskullUI_SaveLocation()
    PowerskullModule:SaveLocation()
end

--------------------------------------------------------------------------------
-- CRITSKULL MODULE
--------------------------------------------------------------------------------
local targetDebuffs = {
    [142610] = 5,   -- Flame Weakness
    [142652] = 5,   -- Frost Weakness
    [142653] = 5,   -- Shock Weakness
    [181606] = 15,  -- Elemental Catalyst (Target Dummy)
    [145975] = 10,  -- Minor Brittle
    [145977] = 20,  -- Major Brittle
}

local cpCritMod     = 0
local debuffCritMod = 0
local advCritDamage = 0

local function UpdateCritDamage()
    _, _, advCritDamage = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE)
end

local function UpdateTargetDebuffs()
    debuffCritMod = 0
    if DoesUnitExist("reticleover") and not IsUnitPlayer("reticleover") then
        for i = 1, GetNumBuffs("reticleover") do
            local _, _, _, _, _, _, _, _, _, _, abilityId =
                GetUnitBuffInfo("reticleover", i)
            if targetDebuffs[abilityId] then
                debuffCritMod = debuffCritMod + targetDebuffs[abilityId]
            end
        end
    end
end

local function UpdateCPMod()
    cpCritMod = 0
    for disciplineIndex = 4, 8 do
        local championSkillId = GetSlotBoundId(disciplineIndex, HOTBAR_CATEGORY_CHAMPION)
        if championSkillId == 31 then            -- Backstabber CP
            cpCritMod = cpCritMod + 10
        end
    end
end

local function CalculateTotalCritDamage()
    return 50 + advCritDamage + cpCritMod + debuffCritMod
end

local function CritskullRender(self, initial)
    UpdateCritDamage()
    UpdateTargetDebuffs()
    UpdateCPMod()

    local critChance = math.max(
        GetPlayerStat(STAT_SPELL_CRITICAL),
        GetPlayerStat(STAT_CRITICAL_STRIKE)
    ) / 219.12
    local critDamage = CalculateTotalCritDamage()

    local oldChance = self.currentData.critChance or 0
    if initial or critChance ~= oldChance then
        self.currentData.critChance = critChance
        MS.AnimateTextTransition(self.uiRefs.CritChance, oldChance, critChance, "%.1f%%", self.name)
        self.uiRefs.CritChance:SetColor(unpack(
            MS.GetThresholdColor(MS.db.critskull.settings.levels.critChance, critChance)
        ))
    end

    local oldDamage = self.currentData.critDamage or 0
    if initial or critDamage ~= oldDamage then
        self.currentData.critDamage = critDamage
        MS.AnimateTextTransition(self.uiRefs.CritDamage, oldDamage, critDamage, "%d%%", self.name)
        self.uiRefs.CritDamage:SetColor(unpack(
            MS.GetThresholdColor(MS.db.critskull.settings.levels.critDamage, critDamage)
        ))
    end
end

local CritskullModule = MS.CreateModule(
    "critskull",
    "critskull",
    nil,
    "MSCritskull",
    CritskullRender,
    DefaultScale
)
MS.RegisterModule(CritskullModule)
_G["CritskullModule"] = CritskullModule

function MS_CritskullUI_SaveLocation()
    CritskullModule:SaveLocation()
end

--------------------------------------------------------------------------------
-- CRITRESISKULL MODULE 
--------------------------------------------------------------------------------
local function CritresiskullRender(self, initial)
    local critResist = GetPlayerStat(STAT_CRITICAL_RESISTANCE)
    local oldVal     = self.currentData.critResistLevel or 0
    local percent    = math.floor(-critResist / 66)

    if initial or critResist ~= oldVal then
        self.currentData.critResistLevel = critResist
        -- Numeric value (left)
        MS.AnimateTextTransition(self.uiRefs.CritResistValue, oldVal, critResist, "%d", self.name)
        self.uiRefs.CritResistValue:SetColor(unpack(
            MS.GetThresholdColor(MS.db.critresiskull.settings.levels.critResist, critResist)
        ))
        -- Percentage value (right)
        local oldPercent = self.currentData.critResistPercent or 0
        self.currentData.critResistPercent = percent
        MS.AnimateTextTransition(self.uiRefs.CritResistPercent, oldPercent, percent, "%d%%", self.name)
        self.uiRefs.CritResistPercent:SetColor(unpack(
            MS.GetThresholdColor(MS.db.critresiskull.settings.levels.critResist, critResist)
        ))
    end
end

local CritresiskullModule = MS.CreateModule(
    "critresiskull",
    "critresiskull",
    nil,
    "MSCritresiskull",
    CritresiskullRender,
    DefaultScale
)
MS.RegisterModule(CritresiskullModule)
_G["CritresiskullModule"] = CritresiskullModule

function MS_CritresiskullUI_SaveLocation()
    CritresiskullModule:SaveLocation()
end

--------------------------------------------------------------------------------
-- PENSKULL MODULE
--------------------------------------------------------------------------------
local targetPenDebuffs = {
    [61742]  = 2974,  -- Minor Breach
    [61743]  = 5948,  -- Major Breach
    [120007] = 2108,  -- Infused Crusher Dummy
    [17906]  = 2108,  -- Infused Crusher
    [120018] = 6000,  -- Alkosh Dummy
    [76667]  = 6000,  -- Alkosh
    [159288] = 3541,  -- Crimson Oath
    [143808] = 1000,  -- Crystal Weapon
    [187742] = 2200,  -- Runic Sunder
}

local targetDebuffsFoN = {
    [18084]  = 660,   -- Burning
    [21929]  = 660,   -- Poisoned
    [148801] = 660,   -- Hemorrhaging
    [88401]  = 660,   -- Minor Magickasteal (work-around)
    [145875] = 660,   -- Minor Brittle  (work-around)
    [79717]  = 660,   -- Minor Vulnerability (work-around)
    [61742]  = 660,   -- Minor Breach (work-around)
    [61726]  = 660,   -- Minor Defile (work-around)
}

local forceOfNature           = false
local playerPenetrationBuff   = 0
local targetPenetrationDebuff = 0

local function IsChampionPointFoNEquipped()
    forceOfNature = false
    for disciplineIndex = 4, 8 do
        if GetSlotBoundId(disciplineIndex, HOTBAR_CATEGORY_CHAMPION) == 276 then
            forceOfNature = true
        end
    end
    return forceOfNature
end

local function GetAdditionalPenetrationFromStatusEffects()
    local additional = 0
    if DoesUnitExist("reticleover") then
        for i = 1, GetNumBuffs("reticleover") do
            local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("reticleover", i)
            if targetDebuffsFoN[abilityId] and forceOfNature then
                additional = additional + targetDebuffsFoN[abilityId]
            end
        end
    end
    return additional
end

local function UpdatePenetrationBuffs()
    playerPenetrationBuff = 0
    if IsChampionPointFoNEquipped() then
        playerPenetrationBuff = playerPenetrationBuff + GetAdditionalPenetrationFromStatusEffects()
    end
end

local function UpdateTargetPenDebuffs()
    targetPenetrationDebuff = 0
    if DoesUnitExist("reticleover") and not IsUnitPlayer("reticleover") then
        for i = 1, GetNumBuffs("reticleover") do
            local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("reticleover", i)
            if targetPenDebuffs[abilityId] then
                targetPenetrationDebuff = targetPenetrationDebuff + targetPenDebuffs[abilityId]
            end
        end
    end
end

local function CalculateTotalPenetration()
    return playerPenetrationBuff + targetPenetrationDebuff
end

local function PenskullRender(self, initial)
    UpdatePenetrationBuffs()
    UpdateTargetPenDebuffs()

    local totalPen    = CalculateTotalPenetration()
    local physicalPen = GetPlayerStat(STAT_PHYSICAL_PENETRATION) + totalPen
    local spellPen    = GetPlayerStat(STAT_SPELL_PENETRATION)    + totalPen
    local maxPen      = math.max(physicalPen, spellPen)

    local oldVal = self.currentData.penetrationLevel or 0
    if initial or maxPen ~= oldVal then
        self.currentData.penetrationLevel = maxPen
        MS.AnimateTextTransition(self.uiRefs.Penetration, oldVal, maxPen, "%d", self.name)
        self.uiRefs.Penetration:SetColor(unpack(
            MS.GetThresholdColor(MS.db.penskull.settings.levels.penetration, maxPen)
        ))
    end
end

local PenskullModule = MS.CreateModule(
    "penskull",
    "penskull",
    nil,
    "MSPenskull",
    PenskullRender,
    DefaultScale
)
MS.RegisterModule(PenskullModule)
_G["PenskullModule"] = PenskullModule

function MS_PenskullUI_SaveLocation()
    PenskullModule:SaveLocation()
end

--------------------------------------------------------------------------------
-- HEALTHSKULL MODULE
--------------------------------------------------------------------------------
local function HealthskullRender(self, initial)
    local healthRecovery = GetPlayerStat(STAT_HEALTH_REGEN_COMBAT)
    local oldVal         = self.currentData.recoveryLevel or 0

    if initial or healthRecovery ~= oldVal then
        self.currentData.recoveryLevel = healthRecovery
        MS.AnimateTextTransition(self.uiRefs.Recovery, oldVal, healthRecovery, "%.0f", self.name)
        self.uiRefs.Recovery:SetColor(unpack(
            MS.GetThresholdColor(MS.db.healthskull.settings.levels.recovery, healthRecovery)
        ))
        self.uiRefs.RecoveryLabel:SetText("HR")
        self.uiRefs.RecoveryLabel:SetColor(1, 0.3, 0.3, 0.75)
    end
end

local HealthskullModule = MS.CreateModule(
    "healthskull",
    "healthskull",
    nil,
    "MSHealthskull",
    HealthskullRender,
    DefaultScale
)
MS.RegisterModule(HealthskullModule)
_G["HealthskullModule"] = HealthskullModule

function MS_HealthskullUI_SaveLocation()
    HealthskullModule:SaveLocation()
end


--------------------------------------------------------------------------------
-- MAGSKULL MODULE 
--------------------------------------------------------------------------------
local function MagskullRender(self, initial)
    local magRecovery = GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT)
    local oldVal      = self.currentData.recoveryLevel or 0

    if initial or magRecovery ~= oldVal then
        self.currentData.recoveryLevel = magRecovery
        MS.AnimateTextTransition(self.uiRefs.Recovery, oldVal, magRecovery, "%.0f", self.name)
        self.uiRefs.Recovery:SetColor(unpack(
            MS.GetThresholdColor(MS.db.magskull.settings.levels.recovery, magRecovery)
        ))
        self.uiRefs.RecoveryLabel:SetText("MR")
        self.uiRefs.RecoveryLabel:SetColor(0.12, 0.49, 1, 0.75)
    end
end

local MagskullModule = MS.CreateModule(
    "magskull",
    "magskull",
    nil,
    "MSMagskull",
    MagskullRender,
    DefaultScale
)
MS.RegisterModule(MagskullModule)
_G["MagskullModule"] = MagskullModule

function MS_MagskullUI_SaveLocation()
    MagskullModule:SaveLocation()
end


--------------------------------------------------------------------------------
-- STAMSKULL MODULE 
--------------------------------------------------------------------------------
local function StamskullRender(self, initial)
    local stamRecovery = GetPlayerStat(STAT_STAMINA_REGEN_COMBAT)
    local oldVal       = self.currentData.recoveryLevel or 0

    if initial or stamRecovery ~= oldVal then
        self.currentData.recoveryLevel = stamRecovery
        MS.AnimateTextTransition(self.uiRefs.Recovery, oldVal, stamRecovery, "%.0f", self.name)
        self.uiRefs.Recovery:SetColor(unpack(
            MS.GetThresholdColor(MS.db.stamskull.settings.levels.recovery, stamRecovery)
        ))
        self.uiRefs.RecoveryLabel:SetText("SR")
        self.uiRefs.RecoveryLabel:SetColor(0, 0.7, 0, 0.75)
    end
end

local StamskullModule = MS.CreateModule(
    "stamskull",
    "stamskull",
    nil,
    "MSStamskull",
    StamskullRender,
    DefaultScale
)
MS.RegisterModule(StamskullModule)
_G["StamskullModule"] = StamskullModule

function MS_StamskullUI_SaveLocation()
    StamskullModule:SaveLocation()
end

--------------------------------------------------------------------------------
-- EVENTS: PLAYER_ACTIVATED, ACTION_SLOT_UPDATED, RETICLE_TARGET_CHANGED, IsBlockActive()
--------------------------------------------------------------------------------
local function RenderAllModules(initial)
    for _, mod in pairs(MS.modules) do
        mod:Render(initial)
    end
end

local renderTickDisabledPen = false
local renderTickDisabled    = false
local targetCooldownDuration = 1000
local barSwapCooldownDuration = 450

local function DisableRenderTickForPen()
    renderTickDisabledPen = true
    EVENT_MANAGER:UnregisterForUpdate(PenskullModule.eventNamespace .. "Render")
    zo_callLater(function()
        renderTickDisabledPen = false
        EVENT_MANAGER:RegisterForUpdate(
            PenskullModule.eventNamespace .. "Render",
            MS.db.sharedSettings.renderTick,
            function() MS.modules.penskull:Render() end
        )
    end, targetCooldownDuration)
end

local function OnPlayerActivated(_eventCode)
    EVENT_MANAGER:UnregisterForEvent(MS.name, EVENT_PLAYER_ACTIVATED)

    InitializeMeterskullUI()

    _G.PopulateUIRefs()

    for _, mod in pairs(MS.modules) do
        mod:Initialize()
        mod:Render(true)
    end

    for _, mod in pairs(MS.modules) do
        local showKey = "show"..string.gsub(mod.name,"^%l",string.upper)
        mod:ToggleVisibility(MS.db.sharedSettings[showKey])
    end
    _G.UpdateUILockState()

    local function CheckPlayerDeathStatus()
        local playerIsDead = IsUnitDead("player")
        for _, mod in pairs(MS.modules) do
            local showKey = "show"..string.gsub(mod.name,"^%l",string.upper)
            local shouldShow = MS.db.sharedSettings[showKey]
            mod:ToggleVisibility(shouldShow)
        end
    end

    EVENT_MANAGER:RegisterForEvent(MS.name .. "DeathCheck", EVENT_PLAYER_ALIVE, CheckPlayerDeathStatus)
    EVENT_MANAGER:RegisterForEvent(MS.name .. "DeathCheck", EVENT_PLAYER_DEAD, CheckPlayerDeathStatus)

    EVENT_MANAGER:RegisterForEvent(MS.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
        RenderAllModules(true)
    end)

    EVENT_MANAGER:RegisterForEvent(MS.name, EVENT_RETICLE_TARGET_CHANGED, function()
        MS.modules.critskull:Render()
        if (not DoesUnitExist('reticleover') or IsUnitPlayer('reticleover')) and IsUnitInCombat('player') then
            DisableRenderTickForPen()
        else
            if renderTickDisabledPen and IsUnitInCombat('player') then
                renderTickDisabledPen = false
                EVENT_MANAGER:RegisterForUpdate(
                    PenskullModule.eventNamespace .. "Render",
                    MS.db.sharedSettings.renderTick,
                    function() MS.modules.penskull:Render() end
                )
            end
            MS.modules.penskull:Render()
        end
    end)

    local wasBlocking = IsBlockActive()
    local blockCheckInterval = MS.db.sharedSettings.renderTick
    EVENT_MANAGER:RegisterForUpdate(MS.name .. "BlockCheck", 250, function()
        local nowBlocking = IsBlockActive()
        if nowBlocking ~= wasBlocking then
            MS.modules.magskull:Render()
            MS.modules.stamskull:Render()
            MS.modules.critresiskull:Render()
        end
        wasBlocking = nowBlocking
    end)

    _G.UpdateUIVisibility()
end

function MS.OnAddOnLoaded(event, addOnName)
    if addOnName ~= MS.name then return end
    MS.accountDb = ZO_SavedVars:NewAccountWide("MeterskullSettings", 1, nil, defaults, GetWorldName())
    if MS.accountDb.sharedSettings.accountWideSettings then
        MS.db = MS.accountDb
    else
        MS.db = ZO_SavedVars:NewCharacterIdSettings("MeterskullSettings", 1, nil, defaults, GetWorldName())
    end

    _G.UpdateUILockState()
    MS.BuildMenu()
    EVENT_MANAGER:RegisterForEvent(MS.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

--------------------------------------------------------------------------------
-- MENU (LIBADDONMENU)
--------------------------------------------------------------------------------
function MS.BuildMenu()
    local optionsData = {}

    optionsData[#optionsData + 1] = {
        type = "description",
        text = "|cd9d9d9Meterskull is an advanced real-time UI meter for Armor, Power Damage, Critical Chance/Damage/Resistance, Penetration and Recoveries.|r"
    }

    optionsData[#optionsData + 1] = {
        type    = "checkbox",
        name    = "Account-wide Settings",
        tooltip = "Use the same settings for all characters on this megaserver. Reload required.",
        getFunc = function()
            return MS.accountDb.sharedSettings.accountWideSettings
        end,
        setFunc = function(value)
            if value == MS.accountDb.sharedSettings.accountWideSettings then
                return
            end
            MS.accountDb.sharedSettings.accountWideSettings = value
            if value then
                MS.db = MS.accountDb
            else
                MS.db = ZO_SavedVars:NewCharacterIdSettings("MeterskullSettings", 1, nil, defaults, GetWorldName())
            end
            ReloadUI()
        end,
        default = MS.defaults.sharedSettings.accountWideSettings,
    }


    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "UI Locked",
        tooltip = "Lock or unlock the UI elements.",
        getFunc = function() return MS.db.sharedSettings.uiLocked end,
        setFunc = function(value)
            MS.db.sharedSettings.uiLocked = value
        end,
        default = MS.defaults.sharedSettings.uiLocked,
    }

optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "|ceea92cModules|r",
    controls = {
        { type = "checkbox", name = "Show Armor UI", getFunc = function() return MS.db.sharedSettings.showArmorskull end, setFunc = function(value) MS.modules.armorskull:ToggleVisibility(value); if MS_ArmorskullUI then MS_ArmorskullUI:SetHidden(not value) end end, default = MS.defaults.sharedSettings.showArmorskull },
        { type = "checkbox", name = "Show Hybrid Armor UI", getFunc = function() return MS.db.sharedSettings.showHybridarmorskull end, setFunc = function(value) MS.modules.hybridarmorskull:ToggleVisibility(value); if MS_HybridarmorskullUI then MS_HybridarmorskullUI:SetHidden(not value) end end, default = MS.defaults.sharedSettings.showHybridarmorskull },
        { type = "checkbox", name = "Show Power UI", getFunc = function() return MS.db.sharedSettings.showPowerskull end, setFunc = function(value) MS.modules.powerskull:ToggleVisibility(value); if MS_PowerskullUI then MS_PowerskullUI:SetHidden(not value) end end, default = MS.defaults.sharedSettings.showPowerskull },
        { type = "checkbox", name = "Show Criticals UI", getFunc = function() return MS.db.sharedSettings.showCritskull end, setFunc = function(value) MS.modules.critskull:ToggleVisibility(value); if MS_CritskullUI then MS_CritskullUI:SetHidden(not value) end end, default = MS.defaults.sharedSettings.showCritskull },
        { type = "checkbox", name = "Show Critical Resistance UI", getFunc = function() return MS.db.sharedSettings.showCritresiskull end, setFunc = function(value) MS.modules.critresiskull:ToggleVisibility(value); if MS_CritresiskullUI then MS_CritresiskullUI:SetHidden(not value) end end, default = MS.defaults.sharedSettings.showCritresiskull },
        { type = "checkbox", name = "Show Penetration UI", getFunc = function() return MS.db.sharedSettings.showPenskull end, setFunc = function(value) MS.modules.penskull:ToggleVisibility(value); if MS_PenskullUI then MS_PenskullUI:SetHidden(not value) end end, default = MS.defaults.sharedSettings.showPenskull },
        { type = "checkbox", name = "Show Health Recovery UI", getFunc = function() return MS.db.sharedSettings.showHealthskull end, setFunc = function(value) MS.modules.healthskull:ToggleVisibility(value); if MS_HealthskullUI then MS_HealthskullUI:SetHidden(not value) end end, default = MS.defaults.sharedSettings.showHealthskull },
        { type = "checkbox", name = "Show Magicka Recovery UI", getFunc = function() return MS.db.sharedSettings.showMagskull end, setFunc = function(value) MS.modules.magskull:ToggleVisibility(value); if MS_MagskullUI then MS_MagskullUI:SetHidden(not value) end end, default = MS.defaults.sharedSettings.showMagskull },
        { type = "checkbox", name = "Show Stamina Recovery UI", getFunc = function() return MS.db.sharedSettings.showStamskull end, setFunc = function(value) MS.modules.stamskull:ToggleVisibility(value); if MS_StamskullUI then MS_StamskullUI:SetHidden(not value) end end, default = MS.defaults.sharedSettings.showStamskull },
    },
}

    -- Extra Settings
    optionsData[#optionsData + 1] = { type = "header", name = "|c40e080Settings|r" }

    optionsData[#optionsData + 1] = {
        type = "dropdown",
        name = "Animation Duration",
        tooltip = "Set the speed of animations for all modules",
        choices = { "Fast", "Standard", "Slow", "Off" },
        choicesValues = { "fast", "standard", "slow", "off" },
        getFunc = function()
            return MS.db.sharedSettings.animationDuration
        end,
        setFunc = function(value)
            MS.db.sharedSettings.animationDuration = value
        end,
        default = "standard",
    }

-- Background Colors
optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Background Colors",
    controls = {
        { type = "description", text = [[|cd9d9d9Configure the background color and transparency for each UI module.|r ]] },
        { type = "colorpicker", name = "Armor UI Color", getFunc = function() return unpack(MS.db.armorskull.settings.backgroundColor) end, setFunc = function(r,g,b,a) MS.db.armorskull.settings.backgroundColor={r,g,b,a}; if MS.modules.armorskull.uiRefs then MS.modules.armorskull.uiRefs.bg:SetCenterColor(r,g,b,a) end end, default={unpack(MS.defaults.armorskull.settings.backgroundColor)} },
        { type = "colorpicker", name = "Hybrid Armor UI Color", getFunc = function() return unpack(MS.db.hybridarmorskull.settings.backgroundColor) end, setFunc = function(r,g,b,a) MS.db.hybridarmorskull.settings.backgroundColor={r,g,b,a}; if MS.modules.hybridarmorskull.uiRefs then MS.modules.hybridarmorskull.uiRefs.bg:SetCenterColor(r,g,b,a) end end, default={unpack(MS.defaults.hybridarmorskull.settings.backgroundColor)} },
        { type = "colorpicker", name = "Power UI Color", getFunc = function() return unpack(MS.db.powerskull.settings.backgroundColor) end, setFunc = function(r,g,b,a) MS.db.powerskull.settings.backgroundColor={r,g,b,a}; if MS.modules.powerskull.uiRefs then MS.modules.powerskull.uiRefs.bg:SetCenterColor(r,g,b,a) end end, default={unpack(MS.defaults.powerskull.settings.backgroundColor)} },
        { type = "colorpicker", name = "Criticals UI Color", getFunc = function() return unpack(MS.db.critskull.settings.backgroundColor) end, setFunc = function(r,g,b,a) MS.db.critskull.settings.backgroundColor={r,g,b,a}; if MS.modules.critskull.uiRefs then MS.modules.critskull.uiRefs.bg:SetCenterColor(r,g,b,a) end end, default={unpack(MS.defaults.critskull.settings.backgroundColor)} },
        { type = "colorpicker", name = "Critical Resistance UI Color", getFunc = function() return unpack(MS.db.critresiskull.settings.backgroundColor) end, setFunc = function(r,g,b,a) MS.db.critresiskull.settings.backgroundColor={r,g,b,a}; if MS.modules.critresiskull.uiRefs then MS.modules.critresiskull.uiRefs.bg:SetCenterColor(r,g,b,a) end end, default={unpack(MS.defaults.critresiskull.settings.backgroundColor)} },
        { type = "colorpicker", name = "Penetration UI Color", getFunc = function() return unpack(MS.db.penskull.settings.backgroundColor) end, setFunc = function(r,g,b,a) MS.db.penskull.settings.backgroundColor={r,g,b,a}; if MS.modules.penskull.uiRefs then MS.modules.penskull.uiRefs.bg:SetCenterColor(r,g,b,a) end end, default={unpack(MS.defaults.penskull.settings.backgroundColor)} },
        { type = "colorpicker", name = "Health Recovery UI Color", getFunc = function() return unpack(MS.db.healthskull.settings.backgroundColor) end, setFunc = function(r,g,b,a) MS.db.healthskull.settings.backgroundColor={r,g,b,a}; if MS.modules.healthskull.uiRefs then MS.modules.healthskull.uiRefs.bg:SetCenterColor(r,g,b,a) end end, default={unpack(MS.defaults.healthskull.settings.backgroundColor)} },
        { type = "colorpicker", name = "Magicka Recovery UI Color", getFunc = function() return unpack(MS.db.magskull.settings.backgroundColor) end, setFunc = function(r,g,b,a) MS.db.magskull.settings.backgroundColor={r,g,b,a}; if MS.modules.magskull.uiRefs then MS.modules.magskull.uiRefs.bg:SetCenterColor(r,g,b,a) end end, default={unpack(MS.defaults.magskull.settings.backgroundColor)} },
        { type = "colorpicker", name = "Stamina Recovery UI Color", getFunc = function() return unpack(MS.db.stamskull.settings.backgroundColor) end, setFunc = function(r,g,b,a) MS.db.stamskull.settings.backgroundColor={r,g,b,a}; if MS.modules.stamskull.uiRefs then MS.modules.stamskull.uiRefs.bg:SetCenterColor(r,g,b,a) end end, default={unpack(MS.defaults.stamskull.settings.backgroundColor)} },
    },
}


 -- Custom Scales
optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Custom Scales",
    controls = {
        {
            type = "description",
            text = [[|cd9d9d9Adjust the display size of each UI module by setting a custom scale percentage (Default = 20%).|r]]
        },
        { type = "slider", name = "Armor UI Scale", min = 0, max = 100, step = 1,
          getFunc = function() return MS.db.armorskull.settings.customScale end,
          setFunc = function(v) MS.db.armorskull.settings.customScale = v; if MS.modules.armorskull then MS.modules.armorskull:CustomScale(v) end end,
          default = MS.defaults.armorskull.settings.customScale },
        { type = "slider", name = "Hybrid Armor UI Scale", min = 0, max = 100, step = 1,
          getFunc = function() return MS.db.hybridarmorskull.settings.customScale end,
          setFunc = function(v) MS.db.hybridarmorskull.settings.customScale = v; if MS.modules.hybridarmorskull then MS.modules.hybridarmorskull:CustomScale(v) end end,
          default = MS.defaults.hybridarmorskull.settings.customScale },
        { type = "slider", name = "Power UI Scale", min = 0, max = 100, step = 1,
          getFunc = function() return MS.db.powerskull.settings.customScale end,
          setFunc = function(v) MS.db.powerskull.settings.customScale = v; if MS.modules.powerskull then MS.modules.powerskull:CustomScale(v) end end,
          default = MS.defaults.powerskull.settings.customScale },
        { type = "slider", name = "Criticals UI Scale", min = 0, max = 100, step = 1,
          getFunc = function() return MS.db.critskull.settings.customScale end,
          setFunc = function(v) MS.db.critskull.settings.customScale = v; if MS.modules.critskull then MS.modules.critskull:CustomScale(v) end end,
          default = MS.defaults.critskull.settings.customScale },
        { type = "slider", name = "Critical Resistance UI Scale", min = 0, max = 100, step = 1,
          getFunc = function() return MS.db.critresiskull.settings.customScale end,
          setFunc = function(v) MS.db.critresiskull.settings.customScale = v; if MS.modules.critresiskull then MS.modules.critresiskull:CustomScale(v) end end,
          default = MS.defaults.critresiskull.settings.customScale },
        { type = "slider", name = "Penetration UI Scale", min = 0, max = 100, step = 1,
          getFunc = function() return MS.db.penskull.settings.customScale end,
          setFunc = function(v) MS.db.penskull.settings.customScale = v; if MS.modules.penskull then MS.modules.penskull:CustomScale(v) end end,
          default = MS.defaults.penskull.settings.customScale },
        { type = "slider", name = "Health Recovery UI Scale", min = 0, max = 100, step = 1,
          getFunc = function() return MS.db.healthskull.settings.customScale end,
          setFunc = function(v) MS.db.healthskull.settings.customScale = v; if MS.modules.healthskull then MS.modules.healthskull:CustomScale(v) end end,
          default = MS.defaults.healthskull.settings.customScale },
        { type = "slider", name = "Magicka Recovery UI Scale", min = 0, max = 100, step = 1,
          getFunc = function() return MS.db.magskull.settings.customScale end,
          setFunc = function(v) MS.db.magskull.settings.customScale = v; if MS.modules.magskull then MS.modules.magskull:CustomScale(v) end end,
          default = MS.defaults.magskull.settings.customScale },
        { type = "slider", name = "Stamina Recovery UI Scale", min = 0, max = 100, step = 1,
          getFunc = function() return MS.db.stamskull.settings.customScale end,
          setFunc = function(v) MS.db.stamskull.settings.customScale = v; if MS.modules.stamskull then MS.modules.stamskull:CustomScale(v) end end,
          default = MS.defaults.stamskull.settings.customScale },
    },
}

    -- Color Alert Notifications
    optionsData[#optionsData + 1] = { type = "header", name = "|c40e080Color Alert Notifications|r" }
    optionsData[#optionsData + 1] = {
        type = "description",
        text = [[|cd9d9d9Set a threshold and color for Resistances, Power, Criticals, Penetration, Recoveries. If your stat meets or exceeds the threshold, the color applies.|r]]
    }

    local function MakeAlertsSubmenu(prefix, tableRef, defaultRef)
        local controls = {}
        for i = 1, #defaultRef do
            controls[#controls + 1] = {
                type = "editbox",
                name = prefix .. " Level #" .. i,
                tooltip = prefix .. " level for threshold #" .. i,
                getFunc = function() return tostring(tableRef[i].level) end,
                setFunc = function(value)
                    local numericValue = tonumber(value) or 0
                    tableRef[i].level = numericValue
                end,
                default = tostring(defaultRef[i].level),
                width = "half",
            }
            controls[#controls + 1] = {
                type = "colorpicker",
                name = prefix .. " Color #" .. i,
                tooltip = "Color for threshold #" .. i,
                getFunc = function() return unpack(tableRef[i].color) end,
                setFunc = function(r, g, b, a) tableRef[i].color = { r, g, b, a } end,
                default = { unpack(defaultRef[i].color) },
                width = "half",
            }
        end
        return controls
    end

optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Color Alert Settings",
    controls = {
        { type = "submenu", name = "Physical Resist (|cB2B2B2Armor UI|r)", reference="Physical_Resistance_Options_Submenu", controls = MakeAlertsSubmenu("Physical Resist", MS.db.armorskull.settings.levels.physical, MS.defaults.armorskull.settings.levels.physical) },
        { type = "submenu", name = "Spell Resist (|cB2B2B2Armor UI|r)",    reference="Spell_Resistance_Options_Submenu",  controls = MakeAlertsSubmenu("Spell Resist",    MS.db.armorskull.settings.levels.spell,    MS.defaults.armorskull.settings.levels.spell) },
        { type = "submenu", name = "Lowest Resist (|cB2B2B2Hybrid Armor UI|r)", reference="Hybrid_Resist_Options_Submenu", controls = MakeAlertsSubmenu("Lowest Resist", MS.db.hybridarmorskull.settings.levels.lowestResist, MS.defaults.hybridarmorskull.settings.levels.lowestResist) },
        { type = "submenu", name = "Power (|cB2B2B2Power UI|r)",           reference="Power_Options_Submenu",           controls = MakeAlertsSubmenu("Power",           MS.db.powerskull.settings.levels.power,           MS.defaults.powerskull.settings.levels.power) },
        { type = "submenu", name = "Critical Chance (|cB2B2B2Criticals UI|r)", reference="Crit_Chance_Options_Submenu", controls = MakeAlertsSubmenu("Crit Chance", MS.db.critskull.settings.levels.critChance, MS.defaults.critskull.settings.levels.critChance) },
        { type = "submenu", name = "Critical Damage (|cB2B2B2Criticals UI|r)", reference="Crit_Damage_Options_Submenu", controls = MakeAlertsSubmenu("Crit Damage", MS.db.critskull.settings.levels.critDamage, MS.defaults.critskull.settings.levels.critDamage) },
        { type = "submenu", name = "Critical Resistance (|cB2B2B2Critical Resistance UI|r)",reference="Crit_Resistance_Options_Submenu", controls = MakeAlertsSubmenu("Critical Resistance", MS.db.critresiskull.settings.levels.critResist, MS.defaults.critresiskull.settings.levels.critResist) },
        { type = "submenu", name = "Penetration (|cB2B2B2Penetration UI|r)", reference="Penetration_Options_Submenu", controls = MakeAlertsSubmenu("Penetration", MS.db.penskull.settings.levels.penetration, MS.defaults.penskull.settings.levels.penetration) },
        { type = "submenu", name = "Health Recovery (|cB2B2B2Health UI|r)",  reference="Health_Recovery_Options_Submenu",  controls = MakeAlertsSubmenu("Health Recovery", MS.db.healthskull.settings.levels.recovery, MS.defaults.healthskull.settings.levels.recovery) },
        { type = "submenu", name = "Magicka Recovery (|cB2B2B2Magicka UI|r)",reference="Magicka_Recovery_Options_Submenu", controls = MakeAlertsSubmenu("Magicka Recovery", MS.db.magskull.settings.levels.recovery, MS.defaults.magskull.settings.levels.recovery) },
        { type = "submenu", name = "Stamina Recovery (|cB2B2B2Stamina UI|r)",reference="Stamina_Recovery_Options_Submenu", controls = MakeAlertsSubmenu("Stamina Recovery", MS.db.stamskull.settings.levels.recovery, MS.defaults.stamskull.settings.levels.recovery) },
    },
}

    optionsData[#optionsData + 1] = { type = "header", name = "|c40e080Performance|r" }
    optionsData[#optionsData + 1] = {
        type = "description",
        text = [[|cd9d9d9Milliseconds for the loop that re-renders the meter values. Larger is less frequent updates.|r]]
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Render Interval (Default: 1000ms)",
        min = 500, max = 2000, step = 50,
        getFunc = function() return MS.db.sharedSettings.renderTick end,
        setFunc = function(value)
            MS.db.sharedSettings.renderTick = value
            for _, mod in pairs(MS.modules) do
                EVENT_MANAGER:UnregisterForUpdate(mod.eventNamespace .. "Render")
                EVENT_MANAGER:RegisterForUpdate(
                    mod.eventNamespace .. "Render",
                    value,
                    function() mod:Render() end
                )
            end
        end,
        default = MS.defaults.sharedSettings.renderTick,
    }

    local panelData = {
        type    = "panel",
        name    = "Meter|cB2B2B2skull|r",
        author  = "|cCCFF00bibik92|r",
        version = MS.version,
    }
    local myPanel = LAM2:RegisterAddonPanel("MeterskullOptions", panelData)
    LAM2:RegisterOptionControls("MeterskullOptions", optionsData)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel == myPanel then
            _G.OnLAMPanelOpened()
        else
            if MS_ArmorskullUI then MS_ArmorskullUI:SetHidden(true) end
            if MS_HybridarmorskullUI then MS_HybridarmorskullUI:SetHidden(true) end
            if MS_PowerskullUI then MS_PowerskullUI:SetHidden(true) end
            if MS_CritskullUI then MS_CritskullUI:SetHidden(true) end
            if MS_PenskullUI then MS_PenskullUI:SetHidden(true) end
            if MS_HealthskullUI then MS_HealthskullUI:SetHidden(true) end
            if MS_MagskullUI then MS_MagskullUI:SetHidden(true) end
            if MS_StamskullUI then MS_StamskullUI:SetHidden(true) end
            if MS_CritresiskullUI then MS_CritresiskullUI:SetHidden(true) end
        end
    end)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == myPanel then
            _G.OnLAMPanelClosed()
            zo_callLater(function()
                if _G.UpdateUIVisibility then
                    _G.UpdateUIVisibility()
                end
            end, 100)
        end
    end)
end

--------------------------------------------------------------------------------
-- FINALE: EVENT REGISTRATION
--------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(MS.name, EVENT_ADD_ON_LOADED, MS.OnAddOnLoaded)
