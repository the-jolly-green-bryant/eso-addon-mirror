-- RealisticNeedsAndDiseases_StatusIconsTransparency.lua
-- Icon-based status display — transparency instead of color indicates
-- severity. Fully transparent (alpha 0) = need satisfied / no disease.
-- Fully opaque (alpha 1) = need completely empty / disease at Severe. No
-- color tint, no border, no pips — just one icon per need/disease, always
-- in the same fixed position, with only its opacity changing.
--
-- Layout: all 9 icons (4 needs + 5 diseases) occupy a FIXED position from
-- the moment the window is created and never move or get hidden/shown
-- individually — the only thing Refresh() ever changes is each icon's
-- alpha. No dynamic pooling, no anchor recalculation, no active/inactive
-- branching.
--
-- HONEST TRADE-OFF: a need at 100 (fully satisfied) or a disease you don't
-- have renders as alpha 0 — genuinely invisible, not just faint. That's
-- what "fully transparent" was asked for, but it does mean there's nothing
-- to see (or easily mouse over for a tooltip) at a healthy baseline; you'd
-- only notice an icon once something starts going wrong and it starts
-- fading in.

RealisticNeeds = RealisticNeeds or {}
local RN = RealisticNeeds

local StatusIconsTransparency = {}
RN.StatusIconsTransparency = StatusIconsTransparency

-- ============================================================
-- ICON PATHS — bundled with the addon under textures/icons/. AI-generated
-- art (see README.md's "Status icon art credit" section); no longer the
-- generic ThiefsBane.dds-overlay-copy placeholders used through 0.19.22.
-- ============================================================
local ICON_FOLDER = "RealisticNeedsAndDiseases/textures/icons/"

RN.STATUS_ICON_PATHS = {
    hunger        = ICON_FOLDER .. "Hunger.dds",
    thirst        = ICON_FOLDER .. "Thirst.dds",
    fatigue       = ICON_FOLDER .. "Fatigue.dds",
    drunkenness   = ICON_FOLDER .. "Drunkenness.dds",
    frostbite     = ICON_FOLDER .. "Frostbite.dds",
    heatstroke    = ICON_FOLDER .. "Heatstroke.dds",
    mageBane      = ICON_FOLDER .. "MagesBane.dds",
    fightersBane  = ICON_FOLDER .. "FightersBane.dds",
    thiefsBane    = ICON_FOLDER .. "ThiefsBane.dds",
}

-- ============================================================
-- LAYOUT CONSTANTS
-- ============================================================
local ICON_SIZE = 32
local ICON_GAP  = 4
local PAD       = 8

local NEEDS_ORDER = { "hunger", "thirst", "fatigue", "drunkenness" }
local ICON_ORDER = {}  -- needs + RN.DISEASE_ORDER, filled in Initialize()

-- ============================================================
-- TOP-LEVEL WINDOW (file scope, created before Initialize)
-- ============================================================
local window = WINDOW_MANAGER:CreateTopLevelWindow("RealisticNeeds_StatusIconsTransparencyWindow")

-- Slots, keyed by need name / diseaseId: { texture, tooltipText }. Fixed
-- position for the control's lifetime — only .texture's alpha changes.
local slots = {}

local function CreateSlot(key, offsetX)
    local texture = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
    texture:SetDimensions(ICON_SIZE, ICON_SIZE)
    texture:SetAnchor(TOPLEFT, window, TOPLEFT, offsetX, PAD)
    texture:SetTexture(RN.STATUS_ICON_PATHS[key] or (ICON_FOLDER .. "ThiefsBane.dds"))
    texture:SetAlpha(0)

    texture:SetMouseEnabled(true)
    texture:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(ZO_Tooltip, self, TOPLEFT, 0, ICON_SIZE + 4)
        local text = slots[key] and slots[key].tooltipText
        ZO_Tooltip:AddLine(text or "", "", 1, 1, 1)
    end)
    texture:SetHandler("OnMouseExit", function()
        ClearTooltip(ZO_Tooltip)
    end)

    return { texture = texture, tooltipText = "" }
end

function StatusIconsTransparency.Initialize()
    local sv = RN.SavedVars
    sv.settings.statusIconsTransparencyPosition = sv.settings.statusIconsTransparencyPosition or { x = 16, y = 340 }

    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.settings.statusIconsTransparencyPosition.x, sv.settings.statusIconsTransparencyPosition.y)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHandler("OnMoveStop", function()
        sv.settings.statusIconsTransparencyPosition.x = window:GetLeft()
        sv.settings.statusIconsTransparencyPosition.y = window:GetTop()
    end)
    window:SetHidden(true)

    for _, needName in ipairs(NEEDS_ORDER) do
        table.insert(ICON_ORDER, needName)
    end
    for _, diseaseId in ipairs(RN.DISEASE_ORDER) do
        table.insert(ICON_ORDER, diseaseId)
    end

    local offsetX = PAD
    for _, key in ipairs(ICON_ORDER) do
        slots[key] = CreateSlot(key, offsetX)
        offsetX = offsetX + ICON_SIZE + ICON_GAP
    end

    -- Fixed-width window — every icon always occupies its slot regardless
    -- of alpha, so (unlike both sibling displays) the width never changes.
    window:SetDimensions(offsetX - ICON_GAP + PAD, ICON_SIZE + PAD * 2)

    StatusIconsTransparency._initialized = true
end

function StatusIconsTransparency.Refresh(sv)
    if not StatusIconsTransparency._initialized then return end
    if not sv.settings.statusIconsTransparencyEnabled then return end

    for _, needName in ipairs(NEEDS_ORDER) do
        local slot = slots[needName]
        local value = sv.needs[needName]
        -- Drunkenness is a buildup stat (high = bad), the opposite direction
        -- from hunger/thirst/fatigue (low = bad) — same inversion StatusBar.lua
        -- uses for its color ramp, applied here to alpha instead.
        local badness = (needName == "drunkenness") and value or (100 - value)
        local alpha = math.max(0, math.min(1, badness / 100))
        slot.texture:SetAlpha(alpha)
        slot.tooltipText = string.format(
            "%s: %d\n%s",
            needName:sub(1, 1):upper() .. needName:sub(2), math.floor(value), RN.Feedback.GetBandMessage(needName, value)
        )
    end

    for _, diseaseId in ipairs(RN.DISEASE_ORDER) do
        local slot = slots[diseaseId]
        local state = sv.diseaseState[diseaseId]
        if state then
            -- Only 3 discrete severities exist (no continuous value like
            -- needs have), so this steps 0.33/0.67/1.0 rather than a smooth
            -- ramp — still reads as "getting more opaque as it worsens."
            slot.texture:SetAlpha(state.severity / RN.SEVERITY_SEVERE)
            local def = RN.Diseases[diseaseId]
            local severityName = ({ "Mild", "Moderate", "Severe" })[state.severity] or "?"
            local hint = RN.Feedback.GetCureHintText(diseaseId, state.severity)
            slot.tooltipText = string.format(
                "%s (%s)%s",
                def and def.name or diseaseId, severityName, hint and ("\n" .. hint) or ""
            )
        else
            slot.texture:SetAlpha(0)
            slot.tooltipText = ""
        end
    end
end

function StatusIconsTransparency.SetShown(shown)
    if not StatusIconsTransparency._initialized then return end
    window:SetHidden(not shown)
end
