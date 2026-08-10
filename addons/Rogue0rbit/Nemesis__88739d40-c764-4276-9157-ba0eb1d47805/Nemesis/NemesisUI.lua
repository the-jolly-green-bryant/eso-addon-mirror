--[[
    Nemesis - UI
    Reticle dossier popup + banner announcements.
    Reticle-driven by design: zero keybinds required (console rule).
]]

Nemesis = Nemesis or {}
local N = Nemesis
N.UI = {}
local UI = N.UI

local EM = EVENT_MANAGER
local SV

local dossier, banner
local currentKey = nil
local bannerQueue = {}
local bannerBusy = false
local bannerTimeline

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

local function TopAbilities(rec, count)
    local list = {}
    for abilityId, seen in pairs(rec.ab or {}) do
        list[#list + 1] = { id = abilityId, seen = seen }
    end
    table.sort(list, function(a, b) return a.seen > b.seen end)
    local names = {}
    for i = 1, zo_min(count, #list) do
        local name = zo_strformat("<<1>>", GetAbilityName(list[i].id))
        if name and name ~= "" then names[#names + 1] = name end
    end
    return names
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

-- Dossier ------------------------------------------------------------------------

local function SetTierAppearance(tier)
    local color = N.TIER_COLORS[tier] or N.TIER_COLORS[0]
    dossier.tierLabel:SetColor(color[1], color[2], color[3], 1)
    dossier.bg:SetEdgeColor(color[1], color[2], color[3], 0.9)
    dossier.tierLabel:SetText(tier > 0 and N.TIER_NAMES[tier] or "TRACKED")
end

local function ApplyVisibility()
    dossier.infoLabel:SetHidden(not SV.showDossierInfo)
    dossier.hpLabel:SetHidden(not SV.showDossierHP)
    dossier.kdLabel:SetHidden(not SV.showDossierKD)
    dossier.winLabel:SetHidden(not SV.showDossierWin)
    dossier.movesLabel:SetHidden(not SV.showDossierMoves)
    dossier.setsLabel:SetHidden(not SV.showDossierSets)
    dossier.lastLabel:SetHidden(not SV.showDossierFooter)
end

local function UpdateHP(unitTag)
    local current, max = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
    if current and max and max > 0 then
        local pct = current / max
        local r = pct < 0.35 and 1 or 0.7
        local g = pct < 0.35 and 0.25 or 0.9
        dossier.hpLabel:SetText(Colorize(string.format("HP %d%%", pct * 100), r, g, 0.3))
    else
        dossier.hpLabel:SetText("")
    end
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
    dossier.infoLabel:SetText(table.concat(bits, "  ·  "))

    UpdateHP(unitTag)

    -- head-to-head
    local k, d = rec.k or 0, rec.d or 0
    local duels = (rec.dw or 0) + (rec.dl or 0)
    local kdText = string.format("You killed them %s · They killed you %s",
        Colorize(tostring(k) .. "x", 0.4, 1, 0.4), Colorize(tostring(d) .. "x", 1, 0.4, 0.4))
    if duels > 0 then
        kdText = kdText .. string.format(" · Duels %d-%d", rec.dw or 0, rec.dl or 0)
    end
    dossier.kdLabel:SetText(kdText)

    -- win chance
    local pct = N.WinChance(rec) * 100
    local wr, wg = 0.4, 1
    if pct < 40 then wr, wg = 1, 0.35 elseif pct < 60 then wr, wg = 1, 0.85 end
    dossier.winLabel:SetText(Colorize(string.format("Win chance ~%d%%", pct), wr, wg, 0.3)
        .. Colorize("  (est.)", 0.5, 0.5, 0.5))

    -- known moves & sets
    local moves = TopAbilities(rec, 4)
    dossier.movesLabel:SetText(#moves > 0 and ("Watch for: " .. table.concat(moves, ", ")) or "No combat data yet - survive one fight to learn their moves.")
    local sets = KnownSets(rec, 3)
    dossier.setsLabel:SetText(#sets > 0 and ("Detected sets: " .. table.concat(sets, ", ")) or "")

    -- footer
    local footer = {}
    if rec.streak and rec.streak >= 2 then
        footer[#footer + 1] = Colorize(string.format("On a %d-kill streak against you!", rec.streak), 1, 0.3, 0.3)
    end
    if rec.loc and rec.loc ~= "" then footer[#footer + 1] = "Last clash: " .. rec.loc end
    footer[#footer + 1] = "Seen " .. TimeAgo(rec.last)
    dossier.lastLabel:SetText(table.concat(footer, " · "))

    ApplyVisibility()
    dossier.control:SetHidden(false)
    N.CheckSpotted(key, rec)
end

local function ShowAllyBuild(unitTag)
    local displayName = GetUnitDisplayName(unitTag)
    local build = N.Scrim.GetBuildFor(displayName)
    if not build then return end
    currentKey = displayName

    dossier.tierLabel:SetText("GROUPMATE")
    dossier.tierLabel:SetColor(0.4, 0.8, 1, 1)
    dossier.bg:SetEdgeColor(0.4, 0.8, 1, 0.9)
    dossier.nameLabel:SetText(Colorize(displayName, 0.6, 0.9, 1))

    local bits = {}
    if build.classId and build.classId > 0 then
        bits[#bits + 1] = zo_strformat("<<1>>", GetClassName(GENDER_MALE, build.classId))
    end
    if build.cp and build.cp > 0 then bits[#bits + 1] = string.format("CP %d", build.cp) end
    dossier.infoLabel:SetText(table.concat(bits, "  ·  "))
    UpdateHP(unitTag)
    dossier.kdLabel:SetText("Shared build (Nemesis scrim link)")
    dossier.winLabel:SetText("")

    local function BarText(label, bar)
        local names = {}
        for _, abilityId in ipairs(bar or {}) do
            if abilityId and abilityId > 0 then
                local name = zo_strformat("<<1>>", GetAbilityName(abilityId))
                if name ~= "" then names[#names + 1] = name end
            end
        end
        if #names == 0 then return nil end
        return label .. table.concat(names, ", ")
    end
    local front = BarText("Front: ", build.front)
    local back = BarText("Back: ", build.back)
    dossier.movesLabel:SetText(table.concat({ front or "", back or "" }, "\n"))

    local setNames = {}
    for _, setId in ipairs(build.sets or {}) do
        if setId and setId > 0 then
            local name = GetItemSetName(setId)
            if name and name ~= "" then setNames[#setNames + 1] = zo_strformat("<<1>>", name) end
        end
    end
    dossier.setsLabel:SetText(#setNames > 0 and ("Sets: " .. table.concat(setNames, ", ")) or "")
    dossier.lastLabel:SetText("Shared " .. TimeAgo(build.at))

    ApplyVisibility()
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
    -- keep the clamped area matching the scaled size so it can reach screen edges
    local w, h = dossier.control:GetDimensions()
    local s = SV.dossierScale
    dossier.control:SetClampedToScreenInsets(-w * s / 2, -w * s / 2, -h * s / 2, -h * s / 2)
    dossier.control:SetScale(s)
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

    banner.titleLabel:SetText(entry.title)
    banner.titleLabel:SetColor(entry.color[1], entry.color[2], entry.color[3], 1)
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

function UI.Init(savedVars)
    SV = savedVars

    local d = NemesisDossier
    dossier = {
        control = d,
        bg = d:GetNamedChild("BG"),
        tierLabel = d:GetNamedChild("Tier"),
        nameLabel = d:GetNamedChild("Name"),
        infoLabel = d:GetNamedChild("Info"),
        hpLabel = d:GetNamedChild("HP"),
        kdLabel = d:GetNamedChild("KD"),
        winLabel = d:GetNamedChild("Win"),
        movesLabel = d:GetNamedChild("Moves"),
        setsLabel = d:GetNamedChild("Sets"),
        lastLabel = d:GetNamedChild("Last"),
    }
    dossier.bg:SetCenterColor(0.05, 0.05, 0.05, 0.85)

    -- default size (matches XML)
    dossier.control:SetDimensions(440, 540)
    UI.ApplyPositionAndScale()

    local b = NemesisBanner
    banner = {
        control = b,
        titleLabel = b:GetNamedChild("Title"),
        subLabel = b:GetNamedChild("Sub"),
    }

    bannerTimeline = ANIMATION_MANAGER:CreateTimeline()
    local fadeIn = bannerTimeline:InsertAnimation(ANIMATION_ALPHA, banner.control, 0)
    fadeIn:SetAlphaValues(0, 1)
    fadeIn:SetDuration(250)
    local fadeOut = bannerTimeline:InsertAnimation(ANIMATION_ALPHA, banner.control, 3250)
    fadeOut:SetAlphaValues(1, 0)
    fadeOut:SetDuration(600)
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

UI.ApplyVisibility = ApplyVisibility
UI.HideDossier = HideDossier
