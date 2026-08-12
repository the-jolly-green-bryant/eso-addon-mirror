--[[
    Nemesis - UI
    Reticle dossier popup + banner announcements.
    Reticle-driven by design: zero keybinds required (console rule).

    The dossier stacks its rows at runtime (Layout), so sections that are
    disabled in settings or have no data collapse instead of leaving gaps,
    and the frame auto-sizes to its content.
]]

Nemesis = Nemesis or {}
local N = Nemesis
N.UI = {}
local UI = N.UI

local EM = EVENT_MANAGER
local SV

local dossier, banner
local rows            -- ordered row descriptors for layout
local currentKey = nil
local bannerQueue = {}
local bannerBusy = false
local bannerTimeline

local PAD_X = 24
local PAD_TOP = 18
local PAD_BOTTOM = 18
local HP_TRACK_WIDTH = 316

local GROUP_COLOR = { 0.40, 0.80, 1.00 }

-- Formatting helpers -----------------------------------------------------------

local function Colorize(text, r, g, b)
    return string.format("|c%02X%02X%02X%s|r", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), text)
end

local function TimeAgo(ts)
    if not ts then return "" end
    local diff = GetTimeStamp() - ts
    if diff < 60 then return "just now" end
    if diff < 3600 then return string.format("%dm ago", math.floor(diff / 60)) end
    if diff < 86400 then return string.format("%dh ago", math.floor(diff / 3600)) end
    return string.format("%dd ago", math.floor(diff / 86400))
end

local function AbilityLine(abilityId, seen)
    local name = zo_strformat("<<1>>", GetAbilityName(abilityId))
    if not name or name == "" then return nil end
    local icon = GetAbilityIcon(abilityId)
    local line = icon and icon ~= "" and string.format("|t24:24:%s|t %s", icon, name) or name
    if seen and seen > 1 then
        line = line .. Colorize(string.format("  x%d", seen), 0.45, 0.45, 0.45)
    end
    return line
end

local function TopAbilityLines(rec, count)
    local list = {}
    for abilityId, seen in pairs(rec.ab or {}) do
        list[#list + 1] = { id = abilityId, seen = seen }
    end
    table.sort(list, function(a, b) return a.seen > b.seen end)
    local lines = {}
    for i = 1, zo_min(count, #list) do
        local line = AbilityLine(list[i].id, list[i].seen)
        if line then lines[#lines + 1] = line end
    end
    return lines
end

local function KnownSets(rec, count)
    local list = {}
    for setId, lastSeen in pairs(rec.sets or {}) do
        list[#list + 1] = { id = setId, last = lastSeen }
    end
    table.sort(list, function(a, b) return a.last > b.last end)
    local names = {}
    for i = 1, zo_min(count, #list) do
        local name = GetItemSetName(list[i].id)
        if name and name ~= "" then names[#names + 1] = zo_strformat("<<1>>", name) end
    end
    return names
end

-- Layout engine ------------------------------------------------------------------
-- Each row: control, optional second control (header chip), fixed height or
-- dynamic (text height), a settings key gating it, and a content flag set
-- during render. Layout() stacks whatever is visible and resizes the frame.

local function Layout()
    if not rows then return end
    local y = PAD_TOP
    for i = 1, #rows do
        local row = rows[i]
        local show = row.content ~= false and (not row.setting or SV[row.setting])
        row.ctrl:SetHidden(not show)
        if row.side then row.side:SetHidden(not show) end
        if show then
            y = y + (row.gap or 4)
            row.ctrl:ClearAnchors()
            row.ctrl:SetAnchor(TOPLEFT, dossier.control, TOPLEFT, PAD_X, y)
            if row.side then
                row.side:ClearAnchors()
                row.side:SetAnchor(TOPRIGHT, dossier.control, TOPRIGHT, -PAD_X, y)
            end
            local h = row.h
            if not h then
                h = row.ctrl:GetTextHeight()
                row.ctrl:SetHeight(h)
            end
            y = y + h
        end
    end
    dossier.control:SetHeight(y + PAD_BOTTOM)
end

local function SetRowText(row, label, text)
    label:SetText(text or "")
    row.content = text ~= nil and text ~= ""
end

-- Dossier ------------------------------------------------------------------------

local function SetAccentColor(r, g, b)
    dossier.tierLabel:SetColor(r, g, b, 1)
    dossier.bg:SetEdgeColor(r, g, b, 0.9)
    dossier.divider:SetCenterColor(r, g, b, 0.8)
end

local function SetTierAppearance(tier)
    local color = N.TIER_COLORS[tier] or N.TIER_COLORS[0]
    SetAccentColor(color[1], color[2], color[3])
    dossier.tierLabel:SetText(tier > 0 and N.TIER_NAMES[tier] or "TRACKED")
end

local function SetRecordChip(rec)
    local k, d = rec and (rec.k or 0) or 0, rec and (rec.d or 0) or 0
    if k + d > 0 then
        dossier.recordLabel:SetText(Colorize(k .. "W", 0.45, 0.90, 0.45)
            .. Colorize(" - ", 0.5, 0.5, 0.5) .. Colorize(d .. "L", 0.95, 0.40, 0.40))
    else
        dossier.recordLabel:SetText("")
    end
end

local function UpdateHP(unitTag)
    local current, max = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
    if current and max and max > 0 then
        local pct = current / max
        local r, g, b = 0.30, 0.85, 0.35
        if pct < 0.25 then r, g, b = 0.95, 0.30, 0.25
        elseif pct < 0.50 then r, g, b = 0.95, 0.85, 0.30 end
        dossier.hpFill:SetCenterColor(r, g, b, 1)
        dossier.hpFill:SetWidth(zo_max(1, HP_TRACK_WIDTH * pct))
        dossier.hpPct:SetText(string.format("%d%%", pct * 100))
        return true
    end
    dossier.hpPct:SetText("")
    return false
end

local function ShowEnemyDossier(unitTag)
    local charName = zo_strformat("<<1>>", GetUnitName(unitTag))
    local displayName = GetUnitDisplayName(unitTag)
    local key = N.KeyFor(displayName, charName)
    if not key then return end

    local rec = N.Touch(key, charName)
    N.EnrichFromUnit(rec, unitTag)
    currentKey = key

    local tier = N.GetTier(rec)
    SetTierAppearance(tier)
    SetRecordChip(rec)

    -- name, colored by alliance if known
    local nameText = key
    if charName ~= "" and charName ~= key then
        nameText = charName .. "  " .. key
    end
    local ac = N.ALLIANCE_COLORS[rec.alli]
    dossier.nameLabel:SetText(ac and Colorize(nameText, ac[1], ac[2], ac[3]) or nameText)

    -- class / race / cp / rank line
    local bits = {}
    if rec.class and rec.class ~= "" then bits[#bits + 1] = rec.class end
    if rec.race and rec.race ~= "" then bits[#bits + 1] = rec.race end
    if rec.cp and rec.cp > 0 then bits[#bits + 1] = string.format("CP %d", rec.cp) end
    if rec.rank and rec.rank > 0 then
        local rankName = zo_strformat("<<1>>", GetAvARankName(GENDER_MALE, rec.rank))
        if rankName ~= "" then bits[#bits + 1] = rankName end
    end
    SetRowText(dossier.rowInfo, dossier.infoLabel, table.concat(bits, "  -  "))

    dossier.rowHP.content = UpdateHP(unitTag)

    -- head-to-head
    local k, d = rec.k or 0, rec.d or 0
    local duels = (rec.dw or 0) + (rec.dl or 0)
    local kdText = string.format("You killed them %s - they killed you %s",
        Colorize(tostring(k) .. "x", 0.4, 1, 0.4), Colorize(tostring(d) .. "x", 1, 0.4, 0.4))
    if duels > 0 then
        kdText = kdText .. string.format(" - duels %d-%d", rec.dw or 0, rec.dl or 0)
    end
    SetRowText(dossier.rowKD, dossier.kdLabel, kdText)

    -- win chance
    local pct = N.WinChance(rec) * 100
    local wr, wg = 0.4, 1
    if pct < 40 then wr, wg = 1, 0.35 elseif pct < 60 then wr, wg = 1, 0.85 end
    SetRowText(dossier.rowWin, dossier.winLabel,
        Colorize(string.format("Win chance ~%d%%", pct), wr, wg, 0.3) .. Colorize("  (est.)", 0.5, 0.5, 0.5))

    -- known moves & sets
    local moveLines = TopAbilityLines(rec, 4)
    if #moveLines > 0 then
        SetRowText(dossier.rowMoves, dossier.movesLabel,
            Colorize("WATCH FOR", 0.60, 0.60, 0.60) .. "\n" .. table.concat(moveLines, "\n"))
    else
        SetRowText(dossier.rowMoves, dossier.movesLabel,
            Colorize("No combat data yet - survive one fight to learn their moves.", 0.55, 0.55, 0.55))
    end
    local sets = KnownSets(rec, 3)
    SetRowText(dossier.rowSets, dossier.setsLabel,
        #sets > 0 and ("Detected sets: " .. table.concat(sets, ", ")) or nil)

    -- footer
    local footer = {}
    if rec.streak and rec.streak >= 2 then
        footer[#footer + 1] = Colorize(string.format("On a %d-kill streak against you!", rec.streak), 1, 0.3, 0.3)
    end
    if rec.loc and rec.loc ~= "" then footer[#footer + 1] = "Last clash: " .. rec.loc end
    footer[#footer + 1] = "Seen " .. TimeAgo(rec.last)
    SetRowText(dossier.rowLast, dossier.lastLabel, table.concat(footer, "  -  "))
    dossier.rowFootDiv.content = dossier.rowLast.content

    Layout()
    dossier.control:SetHidden(false)
    N.CheckSpotted(key, rec)
end

local function ShowAllyBuild(unitTag)
    local displayName = GetUnitDisplayName(unitTag)
    local build = N.Scrim.GetBuildFor(displayName)
    if not build then return end
    currentKey = displayName

    SetAccentColor(GROUP_COLOR[1], GROUP_COLOR[2], GROUP_COLOR[3])
    dossier.tierLabel:SetText("GROUPMATE")
    dossier.recordLabel:SetText("")
    dossier.nameLabel:SetText(Colorize(displayName, 0.6, 0.9, 1))

    local bits = {}
    if build.classId and build.classId > 0 then
        bits[#bits + 1] = zo_strformat("<<1>>", GetClassName(GENDER_MALE, build.classId))
    end
    if build.cp and build.cp > 0 then bits[#bits + 1] = string.format("CP %d", build.cp) end
    SetRowText(dossier.rowInfo, dossier.infoLabel, table.concat(bits, "  -  "))

    dossier.rowHP.content = UpdateHP(unitTag)
    SetRowText(dossier.rowKD, dossier.kdLabel, Colorize("Shared build (Nemesis scrim link)", 0.6, 0.75, 0.85))
    dossier.rowWin.content = false

    local function BarLine(label, bar)
        local icons = {}
        for _, abilityId in ipairs(bar or {}) do
            if abilityId and abilityId > 0 then
                local icon = GetAbilityIcon(abilityId)
                if icon and icon ~= "" then icons[#icons + 1] = string.format("|t26:26:%s|t", icon) end
            end
        end
        if #icons == 0 then return nil end
        return Colorize(label, 0.60, 0.60, 0.60) .. " " .. table.concat(icons, " ")
    end
    local barLines = {}
    barLines[#barLines + 1] = BarLine("FRONT", build.front)
    barLines[#barLines + 1] = BarLine("BACK ", build.back)
    SetRowText(dossier.rowMoves, dossier.movesLabel, table.concat(barLines, "\n"))

    local setNames = {}
    for _, setId in ipairs(build.sets or {}) do
        if setId and setId > 0 then
            local name = GetItemSetName(setId)
            if name and name ~= "" then setNames[#setNames + 1] = zo_strformat("<<1>>", name) end
        end
    end
    SetRowText(dossier.rowSets, dossier.setsLabel,
        #setNames > 0 and ("Sets: " .. table.concat(setNames, ", ")) or nil)

    SetRowText(dossier.rowLast, dossier.lastLabel, "Shared " .. TimeAgo(build.at))
    dossier.rowFootDiv.content = dossier.rowLast.content

    Layout()
    dossier.control:SetHidden(false)
end

local function HideDossier()
    currentKey = nil
    dossier.control:SetHidden(true)
end

local function OnReticleTargetChanged()
    if not SV.showDossier then
        HideDossier()
        return
    end
    local unitTag = "reticleover"
    if IsUnitPlayer(unitTag) then
        if IsUnitAttackable(unitTag) and GetUnitReaction(unitTag) == UNIT_REACTION_HOSTILE then
            ShowEnemyDossier(unitTag)
            return
        end
        local displayName = GetUnitDisplayName(unitTag)
        if displayName and displayName ~= "" and IsPlayerInGroup(displayName) then
            ShowAllyBuild(unitTag)
            return
        end
        -- duel opponent (may not be flagged hostile until countdown ends)
        local duelState, duelChar = GetDuelInfo()
        if duelState ~= DUEL_STATE_IDLE and zo_strformat("<<1>>", duelChar or "") == zo_strformat("<<1>>", GetUnitName(unitTag)) then
            ShowEnemyDossier(unitTag)
            return
        end
    end
    HideDossier()
end

local function OnReticleHealthUpdate(_, unitTag)
    if currentKey and not dossier.control:IsHidden() then
        UpdateHP(unitTag)
    end
end

-- Called by core when a record changes while displayed.
function UI.RefreshIfShowing(key)
    if key == currentKey then
        OnReticleTargetChanged()
    end
end

-- Dossier position / scale -----------------------------------------------------

function UI.ApplyPositionAndScale()
    if not dossier or not dossier.control then return end
    dossier.control:ClearAnchors()
    dossier.control:SetAnchor(CENTER, nil, CENTER, SV.dossierX, SV.dossierY)
    dossier.control:SetScale(SV.dossierScale or 1)
end

function UI.OnDossierMoveStop(control)
    if not SV then return end
    local isValid, _, _, _, offsetX, offsetY = control:GetAnchor(0)
    if isValid then
        SV.dossierX = offsetX
        SV.dossierY = offsetY
    end
end

function UI.ResetPosition()
    SV.dossierX = 230
    SV.dossierY = 20
    SV.dossierScale = 1.0
    UI.ApplyPositionAndScale()
end

-- Banners ----------------------------------------------------------------------

local function ProcessBannerQueue()
    if bannerBusy then return end
    local entry = table.remove(bannerQueue, 1)
    if not entry then return end
    bannerBusy = true

    local r, g, b = entry.color[1], entry.color[2], entry.color[3]
    banner.titleLabel:SetText(entry.title)
    banner.titleLabel:SetColor(r, g, b, 1)
    local accentWidth = zo_min(banner.titleLabel:GetTextWidth() + 80, 900)
    banner.accentTop:SetCenterColor(r, g, b, 0.9)
    banner.accentTop:SetWidth(accentWidth)
    banner.accentBottom:SetCenterColor(r, g, b, 0.9)
    banner.accentBottom:SetWidth(accentWidth)
    banner.subLabel:SetText(entry.sub or "")
    banner.control:SetAlpha(0)
    banner.control:SetHidden(false)
    if SV.sounds and entry.sound then
        PlaySound(entry.sound)
    end
    bannerTimeline:PlayFromStart()
end

local function QueueBanner(title, sub, color, sound)
    if not SV.banners then return end
    if #bannerQueue >= 4 then return end
    bannerQueue[#bannerQueue + 1] = { title = title, sub = sub, color = color, sound = sound }
    ProcessBannerQueue()
end

function UI.ShowSpotted(key, rec, tier)
    QueueBanner(
        N.TIER_NAMES[tier] .. " SPOTTED",
        string.format("%s - killed you %dx", key, rec.d or 0),
        N.TIER_COLORS[tier],
        SOUNDS.DUEL_START)
end

function UI.ShowVengeance(key, rec, tier)
    QueueBanner(
        "VENGEANCE",
        string.format("%s eliminated - they had killed you %dx", key, rec.d or 0),
        { 0.4, 1, 0.4 },
        SOUNDS.DUEL_WON)
end

function UI.ShowPromotion(key, rec, tier)
    QueueBanner(
        "NEW " .. N.TIER_NAMES[tier],
        string.format("%s has killed you %dx", key, rec.d or 0),
        N.TIER_COLORS[tier],
        SOUNDS.DEATH_RECAP_KILLING_BLOW_SHOWN)
end

function UI.ShowDeathNote(key, rec)
    local tier = N.GetTier(rec)
    if tier < N.TIER_RIVAL then return end
    QueueBanner(
        N.TIER_NAMES[tier] .. " STRIKES AGAIN",
        string.format("Death #%d to %s", rec.d or 0, key),
        N.TIER_COLORS[tier],
        nil)
end

-- Init ---------------------------------------------------------------------------

local function SolidRect(bd, r, g, b, a)
    bd:SetCenterColor(r, g, b, a)
    bd:SetEdgeColor(0, 0, 0, 0)
end

function UI.Init(savedVars)
    SV = savedVars

    local d = NemesisDossier
    dossier = {
        control = d,
        bg = d:GetNamedChild("BG"),
        tierLabel = d:GetNamedChild("Tier"),
        recordLabel = d:GetNamedChild("Record"),
        nameLabel = d:GetNamedChild("Name"),
        divider = d:GetNamedChild("Divider"),
        infoLabel = d:GetNamedChild("Info"),
        hpRow = d:GetNamedChild("HPRow"),
        kdLabel = d:GetNamedChild("KD"),
        winLabel = d:GetNamedChild("Win"),
        movesLabel = d:GetNamedChild("Moves"),
        setsLabel = d:GetNamedChild("Sets"),
        footDivider = d:GetNamedChild("FootDivider"),
        lastLabel = d:GetNamedChild("Last"),
    }
    dossier.hpTrack = dossier.hpRow:GetNamedChild("Track")
    dossier.hpFill = dossier.hpRow:GetNamedChild("Fill")
    dossier.hpPct = dossier.hpRow:GetNamedChild("Pct")

    dossier.bg:SetCenterColor(0.05, 0.05, 0.05, 0.85)
    SolidRect(dossier.divider, 1, 1, 1, 0.8)
    SolidRect(dossier.footDivider, 0.35, 0.35, 0.35, 0.5)
    SolidRect(dossier.hpTrack, 0.10, 0.10, 0.10, 0.9)
    SolidRect(dossier.hpFill, 0.30, 0.85, 0.35, 1)
    dossier.hpFill:SetWidth(1)

    -- layout order: settings-gated rows collapse when disabled or empty
    dossier.rowInfo = { ctrl = dossier.infoLabel, h = 26, setting = "showDossierInfo", gap = 8 }
    dossier.rowHP = { ctrl = dossier.hpRow, h = 18, setting = "showDossierHP", gap = 6 }
    dossier.rowKD = { ctrl = dossier.kdLabel, h = 26, setting = "showDossierKD", gap = 6 }
    dossier.rowWin = { ctrl = dossier.winLabel, h = 40, setting = "showDossierWin", gap = 2 }
    dossier.rowMoves = { ctrl = dossier.movesLabel, setting = "showDossierMoves", gap = 14 }
    dossier.rowSets = { ctrl = dossier.setsLabel, setting = "showDossierSets", gap = 8 }
    dossier.rowFootDiv = { ctrl = dossier.footDivider, h = 1, setting = "showDossierFooter", gap = 14 }
    dossier.rowLast = { ctrl = dossier.lastLabel, setting = "showDossierFooter", gap = 8 }
    rows = {
        { ctrl = dossier.tierLabel, side = dossier.recordLabel, h = 30 },
        { ctrl = dossier.nameLabel, h = 42, gap = 0 },
        { ctrl = dossier.divider, h = 2, gap = 6 },
        dossier.rowInfo,
        dossier.rowHP,
        dossier.rowKD,
        dossier.rowWin,
        dossier.rowMoves,
        dossier.rowSets,
        dossier.rowFootDiv,
        dossier.rowLast,
    }

    UI.ApplyPositionAndScale()

    local b = NemesisBanner
    banner = {
        control = b,
        titleLabel = b:GetNamedChild("Title"),
        subLabel = b:GetNamedChild("Sub"),
        accentTop = b:GetNamedChild("AccentTop"),
        accentBottom = b:GetNamedChild("AccentBottom"),
    }
    SolidRect(banner.accentTop, 1, 1, 1, 0.9)
    SolidRect(banner.accentBottom, 1, 1, 1, 0.9)

    bannerTimeline = ANIMATION_MANAGER:CreateTimeline()
    local fadeIn = bannerTimeline:InsertAnimation(ANIMATION_ALPHA, banner.control, 0)
    fadeIn:SetAlphaValues(0, 1)
    fadeIn:SetDuration(250)
    local fadeOut = bannerTimeline:InsertAnimation(ANIMATION_ALPHA, banner.control, 3400)
    fadeOut:SetAlphaValues(1, 0)
    fadeOut:SetDuration(550)
    bannerTimeline:SetHandler("OnStop", function()
        banner.control:SetHidden(true)
        bannerBusy = false
        ProcessBannerQueue()
    end)

    EM:RegisterForEvent(N.name .. "Reticle", EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)

    EM:RegisterForEvent(N.name .. "ReticleHP", EVENT_POWER_UPDATE, OnReticleHealthUpdate)
    EM:AddFilterForEvent(N.name .. "ReticleHP", EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG, "reticleover",
        REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
end

UI.ApplyVisibility = Layout
UI.HideDossier = HideDossier
