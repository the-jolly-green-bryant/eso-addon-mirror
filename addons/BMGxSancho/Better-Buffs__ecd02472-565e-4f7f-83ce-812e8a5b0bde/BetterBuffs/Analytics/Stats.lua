local BB = BetterBuffs
BB.Stats = BB.Stats or {}
local Stats = BB.Stats
local WM = WINDOW_MANAGER
local C = BB.Constants

local PEN_CAP = 18200
local CRIT_DAMAGE_CAP = 125
local CRIT_CHANCE_CAP = 100
local TOLERANCE = 0.05

local function CreateLabel(parent, font)
    local label = WM:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function FormatInteger(value)
    value = zo_round(tonumber(value) or 0)
    if ZO_CommaDelimitNumber then return ZO_CommaDelimitNumber(value) end
    local text = tostring(value)
    while true do
        local nextText, count = string.gsub(text, "^(-?%d+)(%d%d%d)", "%1,%2")
        text = nextText
        if count == 0 then break end
    end
    return text
end

local function MetricColor(value, cap, exact)
    if exact == false then return unpack(C.YELLOW) end
    local lower = cap * (1 - TOLERANCE)
    local upper = cap * (1 + TOLERANCE)
    if value < lower then return unpack(C.YELLOW) end
    if value <= upper then return unpack(C.GREEN) end
    return unpack(C.RED)
end

local function ReadPlayerPenetration()
    if STAT_OFFENSIVE_PENETRATION then
        local value = GetPlayerStat(STAT_OFFENSIVE_PENETRATION, STAT_BONUS_OPTION_APPLY_BONUS)
        if value and value > 0 then return value end
    end
    local physical = STAT_PHYSICAL_PENETRATION and GetPlayerStat(STAT_PHYSICAL_PENETRATION, STAT_BONUS_OPTION_APPLY_BONUS) or 0
    local spell = STAT_SPELL_PENETRATION and GetPlayerStat(STAT_SPELL_PENETRATION, STAT_BONUS_OPTION_APPLY_BONUS) or 0
    return math.max(tonumber(physical) or 0, tonumber(spell) or 0)
end

local function ReadCriticalChance()
    if GetCriticalStrikeChance then
        local weaponRating = STAT_CRITICAL_STRIKE and GetPlayerStat(STAT_CRITICAL_STRIKE, STAT_BONUS_OPTION_APPLY_BONUS) or 0
        local spellRating = STAT_SPELL_CRITICAL and GetPlayerStat(STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS) or 0
        return math.max(tonumber(GetCriticalStrikeChance(weaponRating)) or 0, tonumber(GetCriticalStrikeChance(spellRating)) or 0)
    end
    local _, _, percent = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_CHANCE)
    return tonumber(percent) or 0
end

local function ReadCriticalDamage()
    if not GetAdvancedStatValue or not ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE then return 0 end
    local _, _, percent = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE)
    return tonumber(percent) or 0
end

function Stats:GetSaved()
    return BB.saved and BB.saved.ui and BB.saved.ui.stats
end

function Stats:GetVisibility()
    local saved = self:GetSaved()
    return saved and saved.visibility or "SELF"
end

function Stats:IsSelfVisible()
    return BB.saved and BB.saved.enabled and self:GetVisibility() == "SELF"
end

function Stats:CreateDisplay()
    local control = WM:CreateTopLevelWindow("BetterBuffsStatsModule")
    control:SetHidden(true)
    control:SetDimensions(292, 94)
    control:SetClampedToScreen(true)
    control:SetMouseEnabled(false)
    control:SetMovable(false)

    local bg = WM:CreateControl(nil, control, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.02, 0.025, 0.05, 0.34)
    bg:SetEdgeColor(0.8, 0.62, 0.18, 0.70)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 1, 1, 2)

    local rows = {}
    local labels = { "CURRENT PEN", "CRIT CHANCE", "CRIT DAMAGE" }
    for i, text in ipairs(labels) do
        local y = 8 + (i - 1) * 27
        local name = CreateLabel(control, "$(BOLD_FONT)|18|outline")
        name:SetAnchor(TOPLEFT, control, TOPLEFT, 12, y)
        name:SetDimensions(160, 24)
        name:SetColor(unpack(C.WHITE))
        name:SetText(text)

        local value = CreateLabel(control, "$(BOLD_FONT)|20|outline")
        value:SetAnchor(TOPRIGHT, control, TOPRIGHT, -12, y)
        value:SetDimensions(108, 24)
        value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        rows[i] = value
    end

    local fragment = ZO_HUDFadeSceneFragment:New(control, nil, 0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    fragment:SetHiddenForReason("BetterBuffsStats", true, 0, 0)

    self.display = { control=control, bg=bg, rows=rows, fragment=fragment, previewScene=nil }
end

function Stats:Initialize()
    self:CreateDisplay()
    self:ApplySettings()

    EVENT_MANAGER:RegisterForEvent("BetterBuffsStats", EVENT_STATS_UPDATED, function(_, unitTag)
        if unitTag == "player" then Stats:Refresh() end
    end)
    EVENT_MANAGER:AddFilterForEvent("BetterBuffsStats", EVENT_STATS_UPDATED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent("BetterBuffsStatsCombat", EVENT_PLAYER_COMBAT_STATE, function() Stats:Refresh() end)
    EVENT_MANAGER:RegisterForEvent("BetterBuffsStatsActivated", EVENT_PLAYER_ACTIVATED, function() Stats:Refresh() end)
    self:Refresh()
end

function Stats:ApplySettings()
    if not self.display then return end
    local saved = self:GetSaved()
    if not saved then return end
    self.display.control:ClearAnchors()
    self.display.control:SetAnchor(CENTER, GuiRoot, CENTER, saved.offsetX or 0, saved.offsetY or 120)
    self.display.control:SetScale(saved.scale or 1)
    self.display.bg:SetCenterColor(0.02, 0.025, 0.05, saved.opacity or 0.34)
    self:Refresh()
end

function Stats:GetBossPenetrationBonus()
    if not BB.Context or not BB.Context:HasActiveBoss() or not BB.Runtime then return 0, true end
    local bonus = 0
    local exact = true
    for _, definition in ipairs(BB.Registry.definitions or {}) do
        if definition.effectType == "DEBUFF" and definition.affectsPenetration then
            local snapshot = BB.Runtime:GetSnapshot(definition.key)
            if snapshot and snapshot.active then
                if definition.resistanceReduction then
                    bonus = bonus + definition.resistanceReduction
                else
                    exact = false
                end
            end
        end
    end
    return bonus, exact
end

function Stats:GetBossCriticalDamageBonus()
    if not BB.Context or not BB.Context:HasActiveBoss() or not BB.Runtime then return 0 end
    local bonus = 0
    for _, definition in ipairs(BB.Registry.definitions or {}) do
        if definition.effectType == "DEBUFF" and (definition.criticalDamageTaken or definition.criticalDamagePerStack) then
            local snapshot = BB.Runtime:GetSnapshot(definition.key)
            if snapshot and snapshot.active then
                bonus = bonus + (definition.criticalDamageTaken or 0)
                if definition.criticalDamagePerStack then bonus = bonus + (definition.criticalDamagePerStack * (tonumber(snapshot.stackCount) or 0)) end
            end
        end
    end
    return bonus
end

function Stats:GetSnapshot()
    local personalPen = ReadPlayerPenetration()
    local bossBonus, exact = self:GetBossPenetrationBonus()
    local hasBoss = BB.Context and BB.Context:HasActiveBoss() or false
    local personalCritDamage = ReadCriticalDamage()
    local bossCritDamage = hasBoss and self:GetBossCriticalDamageBonus() or 0
    return {
        personalPen = personalPen,
        currentPen = personalPen + (hasBoss and bossBonus or 0),
        penExact = not hasBoss or exact,
        critChance = ReadCriticalChance(),
        critDamage = personalCritDamage + bossCritDamage,
        personalCritDamage = personalCritDamage,
        bossActive = hasBoss,
    }
end

function Stats:Refresh()
    if not self.display then return end
    local visible = self:IsSelfVisible()
    self.display.fragment:SetHiddenForReason("BetterBuffsStats", not visible, 0, 0)
    self.display.control:SetHidden(not visible)
    if not visible then return end

    local state = self:GetSnapshot()
    local penText = FormatInteger(state.currentPen)
    if state.penExact == false then penText = penText .. "*" end
    self.display.rows[1]:SetText(penText)
    self.display.rows[2]:SetText(string.format("%.1f%%", state.critChance))
    self.display.rows[3]:SetText(string.format("%.1f%%", state.critDamage))
    self.display.rows[1]:SetColor(MetricColor(state.currentPen, PEN_CAP, state.penExact))
    self.display.rows[2]:SetColor(MetricColor(state.critChance, CRIT_CHANCE_CAP, true))
    self.display.rows[3]:SetColor(MetricColor(state.critDamage, CRIT_DAMAGE_CAP, true))
end

function Stats:SetVisibility(mode)
    local saved = self:GetSaved()
    if not saved then return end
    if mode ~= "SELF" and mode ~= "GROUP" and mode ~= "HIDDEN" then return end
    saved.visibility = mode
    self:Refresh()
end

function Stats:AttachToCurrentSettingsScene()
    if not self.display then return end
    local currentScene = SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() or nil
    local previous = self.display.previewScene
    if previous and previous ~= currentScene and previous ~= HUD_SCENE and previous ~= HUD_UI_SCENE then
        previous:RemoveFragment(self.display.fragment)
        self.display.previewScene = nil
    end
    if currentScene and currentScene ~= HUD_SCENE and currentScene ~= HUD_UI_SCENE and self.display.previewScene ~= currentScene then
        currentScene:AddFragment(self.display.fragment)
        self.display.previewScene = currentScene
    end
end

function Stats:ShowPreview()
    if not self.display then return end
    self:AttachToCurrentSettingsScene()
    self:ApplySettings()
    self.display.control:SetHidden(false)
    self.display.fragment:SetHiddenForReason("BetterBuffsStats", false, 0, 0)
    local state = self:GetSnapshot()
    local penText = FormatInteger(state.currentPen) .. (state.penExact == false and "*" or "")
    self.display.rows[1]:SetText(penText)
    self.display.rows[2]:SetText(string.format("%.1f%%", state.critChance))
    self.display.rows[3]:SetText(string.format("%.1f%%", state.critDamage))
    self.display.rows[1]:SetColor(MetricColor(state.currentPen, PEN_CAP, state.penExact))
    self.display.rows[2]:SetColor(MetricColor(state.critChance, CRIT_CHANCE_CAP, true))
    self.display.rows[3]:SetColor(MetricColor(state.critDamage, CRIT_DAMAGE_CAP, true))
end

function Stats:HidePreview()
    if not self.display then return end
    local scene = self.display.previewScene
    self.display.previewScene = nil
    if scene and scene ~= HUD_SCENE and scene ~= HUD_UI_SCENE then scene:RemoveFragment(self.display.fragment) end
    self:Refresh()
end

function Stats:Nudge(dx, dy)
    local saved = self:GetSaved()
    saved.offsetX = zo_clamp((saved.offsetX or 0) + dx, -1600, 1600)
    saved.offsetY = zo_clamp((saved.offsetY or 120) + dy, -900, 900)
    self:ShowPreview()
end

function Stats:ResetPosition()
    local saved = self:GetSaved()
    saved.offsetX = 0
    saved.offsetY = 120
    self:ShowPreview()
end

function Stats:SetScale(value)
    local saved = self:GetSaved()
    saved.scale = value
    self:ShowPreview()
end

function Stats:SetOpacity(value)
    local saved = self:GetSaved()
    saved.opacity = value
    self:ShowPreview()
end
