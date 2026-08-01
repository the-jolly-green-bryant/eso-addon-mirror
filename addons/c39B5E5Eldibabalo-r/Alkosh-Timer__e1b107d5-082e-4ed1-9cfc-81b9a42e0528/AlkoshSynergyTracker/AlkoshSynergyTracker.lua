-- Alkosh Synergy Tracker v1.0.0
-- Roar of Alkosh: 10s debuff on synergy use; rotate synergy types (per-type cooldown).

local ADDON_NAME = "AlkoshSynergyTracker"
local UPDATE_KEY = ADDON_NAME .. "_Update"
local UPDATE_MS = 100

AlkoshSynergyTracker = AlkoshSynergyTracker or {}
local AST = AlkoshSynergyTracker

AST.version = "1.0.9"
AST.HUD_MARGIN_BOTTOM = 220

local DEFAULTS = {
    enabled = true,
    alkoshDurationSec = 10,
    synergyCooldownSec = 20,
    sharedGcdSec = 1,
    warnBeforeExpireSec = 3,
    onlyInCombat = true,
    debug = false,
    offsetX = 0,
    offsetY = 0,
    scale = 1.0,
}

-- Synergy families for cooldown grouping (Shards + Orbs share one timer).
local SYNERGY_RULES = {
    { key = "shards_orb", label = "Shards/Orb", patterns = { "shard", "orb", "splinter", "necrotic", "spear" } },
    { key = "conduit", label = "Conduit", patterns = { "conduit", "lightning" } },
    { key = "blood", label = "Blood", patterns = { "blood", "funnel", "altar" } },
    { key = "combustion", label = "Combustion", patterns = { "combustion", "aggressive" } },
    { key = "bone", label = "Bone", patterns = { "bone", "tomb", "wall", "shield" } },
    { key = "grasping", label = "Vines", patterns = { "grasping", "vines", "nature" } },
    { key = "purge", label = "Purge", patterns = { "purge", "cleans" } },
    { key = "nova", label = "Nova", patterns = { "nova", "dark" } },
    { key = "talisman", label = "Talisman", patterns = { "talisman" } },
}

local COMBAT_UNIT_TYPE_PLAYER = _G["COMBAT_UNIT_TYPE_PLAYER"] or 1
local ACTION_RESULT_BEGIN = _G["ACTION_RESULT_BEGIN"]
local ACTION_RESULT_EFFECT_GAINED = _G["ACTION_RESULT_EFFECT_GAINED"]
local ACTION_RESULT_EFFECT_FADED = _G["ACTION_RESULT_EFFECT_FADED"]

AST.sv = nil
AST.alkoshExpireMs = 0
AST.sharedGcdExpireMs = 0
AST.synergyExpireMs = {}
AST.lastSynergyLabel = nil
AST.promptVisible = false
AST.promptName = nil
AST.promptSinceMs = 0
AST.lastRenderKey = nil

local function NowMs()
    return GetGameTimeMilliseconds()
end

local function SafeLower(s)
    if type(s) ~= "string" then return "" end
    return string.lower(s)
end

local function Debug(msg)
    if AST.sv and AST.sv.debug then
        d("[AST] " .. tostring(msg))
    end
end

local function EnsureSV()
    AlkoshSynergyTrackerSV = AlkoshSynergyTrackerSV or {}
    local sv = AlkoshSynergyTrackerSV
    for k, v in pairs(DEFAULTS) do
        if sv[k] == nil then
            sv[k] = v
        end
    end
    if (sv.configVersion or 0) < 2 then
        sv.onlyInCombat = true
        sv.configVersion = 2
    end
    AST.sv = sv
end

-- HUD layout lives in AlkoshSynergyTrackerHud.lua (CreateHud / ApplyHudTransform).

local function ShouldShowHud()
    if not AST.sv.enabled then return false end
    if AST.sv.onlyInCombat and not IsUnitInCombat("player") then
        if AST_UI and AST_UI.visible then
            return true
        end
        return false
    end
    return true
end

local function ClassifySynergy(name)
    local lower = SafeLower(name)
    if lower == "" then return "other", "Synergy" end
    for _, rule in ipairs(SYNERGY_RULES) do
        for _, pat in ipairs(rule.patterns) do
            if string.find(lower, pat, 1, true) then
                return rule.key, rule.label
            end
        end
    end
    return "other_" .. lower, name
end

local function RecordSynergyUse(synergyName, sourceTag)
    local key, label = ClassifySynergy(synergyName)
    local now = NowMs()
    local cdMs = math.max(1, AST.sv.synergyCooldownSec) * 1000
    local gcdMs = math.max(0, AST.sv.sharedGcdSec) * 1000
    local alkMs = math.max(1, AST.sv.alkoshDurationSec) * 1000

    AST.alkoshExpireMs = now + alkMs
    AST.sharedGcdExpireMs = now + gcdMs
    AST.synergyExpireMs[key] = now + cdMs
    AST.lastSynergyLabel = label

    Debug(string.format("Synergy used (%s): %s -> key %s", sourceTag or "?", synergyName or "?", key))
end

local function OnSynergyUsedFromPrompt()
    if AST.promptName and AST.promptName ~= "" then
        RecordSynergyUse(AST.promptName, "prompt-clear")
    end
end

local function OnCombatEvent(_, result, isError, abilityName, _, _, sourceName, sourceType, _, _, _, _, _, _, sourceUnitId, _, abilityId)
    if isError then return end
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and sourceUnitId ~= "player" then return end

    if result ~= ACTION_RESULT_BEGIN and result ~= ACTION_RESULT_EFFECT_GAINED then
        return
    end

    local name = abilityName
    if (not name or name == "") and type(abilityId) == "number" and abilityId > 0 and type(GetAbilityName) == "function" then
        name = GetAbilityName(abilityId)
    end
    if not name or name == "" then return end

    local lower = SafeLower(name)
    if not string.find(lower, "synerg", 1, true)
        and not string.find(lower, "shard", 1, true)
        and not string.find(lower, "orb", 1, true)
        and not string.find(lower, "conduit", 1, true)
        and not string.find(lower, "blood", 1, true)
        and not string.find(lower, "combustion", 1, true)
        and not string.find(lower, "bone", 1, true)
        and not string.find(lower, "grasping", 1, true)
        and not string.find(lower, "purge", 1, true)
        and not string.find(lower, "nova", 1, true)
        and not string.find(lower, "talisman", 1, true) then
        return
    end

    RecordSynergyUse(name, "combat")
end

local function OnSynergyAbilityChanged()
    if type(GetCurrentSynergyInfo) ~= "function" then return end

    local hasSynergy, synergyName = GetCurrentSynergyInfo()
    local now = NowMs()

    if hasSynergy then
        if not AST.promptVisible then
            AST.promptSinceMs = now
        elseif AST.promptName ~= synergyName then
            -- Switched to a different synergy prompt; previous one may have been consumed.
            if AST.promptName and (now - AST.promptSinceMs) < 2500 and IsUnitInCombat("player") then
                RecordSynergyUse(AST.promptName, "prompt-switch")
            end
            AST.promptSinceMs = now
        end
        AST.promptVisible = true
        AST.promptName = synergyName or ""
    else
        if AST.promptVisible and AST.promptName and AST.promptName ~= "" then
            local visibleFor = now - AST.promptSinceMs
            if visibleFor >= 200 and visibleFor <= 2500 and IsUnitInCombat("player") then
                OnSynergyUsedFromPrompt()
            end
        end
        AST.promptVisible = false
        AST.promptName = nil
        AST.promptSinceMs = 0
    end
end

local function GetAlkoshRemainingSec()
    local remainMs = AST.alkoshExpireMs - NowMs()
    if remainMs <= 0 then return 0 end
    return remainMs / 1000
end

local function GetCooldownRemainingSec(key)
    local expire = AST.synergyExpireMs[key]
    if not expire then return 0 end
    local remainMs = expire - NowMs()
    if remainMs <= 0 then return 0 end
    return remainMs / 1000
end

local function GetReadySynergyLabels()
    local ready = {}
    local seen = {}
    for _, rule in ipairs(SYNERGY_RULES) do
        if not seen[rule.key] then
            seen[rule.key] = true
            if GetCooldownRemainingSec(rule.key) <= 0 then
                table.insert(ready, rule.label)
            end
        end
    end
    return ready
end

local function GetNextCooldownLabel()
    local bestKey, bestLabel, bestSec = nil, nil, nil
    for _, rule in ipairs(SYNERGY_RULES) do
        local sec = GetCooldownRemainingSec(rule.key)
        if sec > 0 and (not bestSec or sec < bestSec) then
            bestSec = sec
            bestKey = rule.key
            bestLabel = rule.label
        end
    end
    return bestLabel, bestSec
end

local function FormatSec(sec)
    if sec <= 0 then return "0.0" end
    return string.format("%.1f", sec)
end

local function SetLabelColor(label, r, g, b)
    if label and label.SetColor then
        label:SetColor(r, g, b, 1)
    end
end

function AST:RefreshHud()
    if not self.hudReady then
        self:CreateHud()
    end
    local hud = AST_Hud
    if not hud then return end

    self:ApplyHudTransform()

    if not ShouldShowHud() then
        hud:SetHidden(true)
        return
    end
    hud:SetHidden(false)

    local alkSec = GetAlkoshRemainingSec()
    local alkDur = math.max(1, AST.sv.alkoshDurationSec)
    local pct = math.min(1, math.max(0, alkSec / alkDur))

    local statusText, sr, sg, sb
    if alkSec <= 0 then
        statusText = "DOWN"
        sr, sg, sb = 1, 0.35, 0.35
    elseif alkSec <= AST.sv.warnBeforeExpireSec then
        statusText = "TAKE NOW"
        sr, sg, sb = 1, 0.85, 0.2
    else
        statusText = "ACTIVE"
        sr, sg, sb = 0.2, 1, 0.4
    end

    local timerText
    if alkSec > 0 then
        timerText = FormatSec(alkSec) .. "s"
    else
        timerText = "no proc"
    end

    local promptText = ""
    if AST.promptVisible and AST.promptName and AST.promptName ~= "" then
        if alkSec <= 0 or alkSec <= AST.sv.warnBeforeExpireSec then
            promptText = "SYNERGY UP: " .. AST.promptName
            SetLabelColor(AST_HudPrompt, 1, 0.9, 0.2)
        else
            promptText = "Hold — Alkosh " .. FormatSec(alkSec) .. "s left"
            SetLabelColor(AST_HudPrompt, 0.75, 0.75, 0.75)
        end
    elseif alkSec <= 0 then
        local ready = GetReadySynergyLabels()
        if #ready > 0 then
            promptText = "Need synergy — ready: " .. table.concat(ready, ", ")
        else
            local nextLabel, nextSec = GetNextCooldownLabel()
            if nextLabel then
                promptText = "Need synergy — next " .. nextLabel .. " in " .. FormatSec(nextSec) .. "s"
            else
                promptText = "Need synergy — wait for prompt"
            end
        end
        SetLabelColor(AST_HudPrompt, 1, 0.55, 0.55)
    else
        local nextLabel, nextSec = GetNextCooldownLabel()
        if nextLabel and nextSec > 0 then
            promptText = "Next CD: " .. nextLabel .. " " .. FormatSec(nextSec) .. "s"
        else
            promptText = "Rotate synergies before " .. FormatSec(alkSec) .. "s"
        end
        SetLabelColor(AST_HudPrompt, 0.85, 0.85, 0.85)
    end

    local cdParts = {}
    for _, rule in ipairs(SYNERGY_RULES) do
        local sec = GetCooldownRemainingSec(rule.key)
        if sec > 0 then
            table.insert(cdParts, rule.label .. " " .. FormatSec(sec) .. "s")
        end
    end
    local cdText = ""
    if #cdParts > 0 then
        cdText = table.concat(cdParts, "  |  ")
    elseif AST.lastSynergyLabel then
        cdText = "Last: " .. AST.lastSynergyLabel
    end

    local renderKey = statusText .. "|" .. timerText .. "|" .. promptText .. "|" .. cdText .. "|" .. tostring(pct)
    local transformKey = string.format("%d:%d:%.2f",
        math.floor(tonumber(self.sv.offsetX) or 0),
        math.floor(tonumber(self.sv.offsetY) or 0),
        tonumber(self.sv.scale) or 1.0)
    if renderKey == AST.lastRenderKey and transformKey == AST.lastRenderTransformKey then
        if AST_HudBarFill then
            AST_HudBarFill:SetWidth(math.floor(396 * pct))
        end
        return
    end
    AST.lastRenderKey = renderKey
    AST.lastRenderTransformKey = transformKey

    if AST_HudStatus then AST_HudStatus:SetText(statusText) end
    SetLabelColor(AST_HudStatus, sr, sg, sb)
    if AST_HudTimer then AST_HudTimer:SetText(timerText) end
    if AST_HudPrompt then AST_HudPrompt:SetText(promptText) end
    if AST_HudCooldowns then AST_HudCooldowns:SetText(cdText) end
    if AST_HudBarFill then
        AST_HudBarFill:SetWidth(math.max(0, math.floor(396 * pct)))
        if alkSec <= 0 then
            AST_HudBarFill:SetColor(0.55, 0.15, 0.15, 1)
        elseif alkSec <= AST.sv.warnBeforeExpireSec then
            AST_HudBarFill:SetColor(0.95, 0.75, 0.15, 1)
        else
            AST_HudBarFill:SetColor(0.15, 0.75, 0.35, 1)
        end
    end
end

function AST:Reset()
    self.alkoshExpireMs = 0
    self.sharedGcdExpireMs = 0
    self.synergyExpireMs = {}
    self.lastSynergyLabel = nil
    self.promptVisible = false
    self.promptName = nil
    self.promptSinceMs = 0
    self.lastRenderKey = nil
    self:RefreshHud()
end

function AST:Toggle()
    EnsureSV()
    self.sv.enabled = not self.sv.enabled
    AST:RefreshHud()
    d("[AST] HUD " .. (self.sv.enabled and "shown" or "hidden"))
end

function AST:ToggleCombatOnly()
    EnsureSV()
    self.sv.onlyInCombat = not self.sv.onlyInCombat
    self:RefreshHud()
    d("[AST] Combat-only HUD: " .. (self.sv.onlyInCombat and "on" or "off"))
end

function AST:ToggleDebug()
    EnsureSV()
    self.sv.debug = not self.sv.debug
    d("[AST] Debug " .. (self.sv.debug and "on" or "off"))
end

function AlkoshSynergyTracker_Toggle()
    AST:Toggle()
end

local function RegisterSlash()
  local function Handler(arg)
        EnsureSV()
        arg = SafeLower(arg or "")
        if arg == "reset" then
            AST:Reset()
            d("[AST] Timers reset.")
        elseif arg == "settings" or arg == "menu" or arg == "move" then
            if AST_UI then AST_UI:ToggleSettings() end
        elseif arg == "hudreset" then
            if AST_UI then AST_UI:ResetAll() end
        elseif arg == "combat" then
            AST:ToggleCombatOnly()
        elseif arg == "debug" then
            AST:ToggleDebug()
        elseif arg == "on" then
            AST.sv.enabled = true
            AST:RefreshHud()
        elseif arg == "off" then
            AST.sv.enabled = false
            AST:RefreshHud()
        else
            AST:Toggle()
        end
    end
    SLASH_COMMANDS["/alkosh"] = Handler
    SLASH_COMMANDS["/ast"] = Handler
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    EnsureSV()
    AST:CreateHud()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Synergy", EVENT_SYNERGY_ABILITY_CHANGED, OnSynergyAbilityChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Combat", EVENT_COMBAT_EVENT, OnCombatEvent)

    if type(EVENT_PLAYER_COMBAT_STATE) == "number" then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_CombatState", EVENT_PLAYER_COMBAT_STATE, function()
            AST:RefreshHud()
        end)
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        AST.lastTransformKey = nil
        AST:ApplyHudTransform()
        AST:RefreshHud()
    end)

    EVENT_MANAGER:RegisterForUpdate(UPDATE_KEY, UPDATE_MS, function()
        AST:RefreshHud()
    end)
    RegisterSlash()

    ZO_CreateStringId("SI_BINDING_NAME_ALKOSH_SYNERGY_TOGGLE", "Toggle Alkosh Synergy HUD")
    ZO_CreateStringId("SI_BINDING_NAME_ALKOSH_SYNERGY_SETTINGS", "Alkosh Synergy Settings / Move HUD")

    if AST_UI and AST_UI.Initialize then
        AST_UI:Initialize()
    end

    zo_callLater(function()
        if AST_UI and AST_UI.LateInit then
            AST_UI:LateInit()
        end
    end, 2000)

    AST:ApplyHudTransform()
    AST:RefreshHud()
    d("[AST] v" .. AST.version .. " loaded. /alkosh settings = move HUD (L1/R1/L2/R2, Square/Triangle scale).")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
