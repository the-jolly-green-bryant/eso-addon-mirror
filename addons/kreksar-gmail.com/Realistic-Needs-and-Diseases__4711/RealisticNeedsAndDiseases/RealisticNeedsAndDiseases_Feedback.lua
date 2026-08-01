-- RealisticNeedsAndDiseases_Feedback.lua
-- Notifications and emotes, restructured to mirror Frostfall's own
-- architecture for hot/cold feedback (this project's own prior work, reused
-- the same way the inventory-consumption pattern was reused elsewhere):
--   - Band-transition alerts via ZO_Alert, firing only when crossing a
--     threshold (not every tick), instead of CENTER_SCREEN_ANNOUNCE.
--   - Emotes resolved via the real PLAYER_EMOTE_MANAGER enumeration API
--     (display-name lookup with a slash-name fallback), played via the
--     confirmed GetEmoteIndex(emoteId) -> PlayEmoteByIndex(index) two-step,
--     instead of guessed numeric indices or SLASH_COMMANDS hijacking.
--   - A dedicated, deterministic emote tick timer (own interval, separate
--     from the main 5s needs tick), gated on combat/mounted/major-UI-open,
--     instead of a per-tick random chance roll.

RealisticNeeds = RealisticNeeds or {}
local RN = RealisticNeeds

local Feedback = {}
RN.Feedback = Feedback

local PREFIX = "|c88CCFF[Realistic Needs and Diseases]|r "

-- ─────────────────────────────────────────────────────────────────────────────
-- Chat + ZO_Alert notification (replaces CENTER_SCREEN_ANNOUNCE entirely)
-- ZO_Alert(category, soundId, text) is the same mechanism Frostfall uses for
-- its hot/cold threshold messages — a real, confirmed, working call in this
-- project's own code, not a best-effort guess.
--
-- The chat line is now OPT-IN via sv.settings.showChatMessages (default
-- false) — most feedback is meant to be the top-right popup; chat logging
-- of every notification is an extra the person turns on deliberately.
-- ─────────────────────────────────────────────────────────────────────────────
function Feedback.Notify(text, opts)
    opts = opts or {}
    local sv = RN.SavedVars
    -- opts.chatOnly calls have no popup fallback by design, so they always
    -- print regardless of showChatMessages — otherwise they'd produce
    -- literally no feedback at all when the chat toggle is off, which isn't
    -- what either setting is meant to control.
    if opts.chatOnly or (sv and sv.settings.showChatMessages) then
        CHAT_SYSTEM:AddMessage(PREFIX .. text)
    end
    if not opts.chatOnly and sv and sv.settings.showNativeNotifications then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Same top-right ZO_Alert popup as Notify() above, but with NO chat line at
-- all — for /checkneeds, which is meant to be a quiet glance, not a chat
-- log entry. Still respects showNativeNotifications: if that's off, this
-- produces no feedback whatsoever (by design — that setting is the
-- person's own choice to mute native popups, and there's no chat fallback
-- here to fall back to).
-- ─────────────────────────────────────────────────────────────────────────────
function Feedback.NotifyAlertOnly(text)
    local sv = RN.SavedVars
    if sv and sv.settings.showNativeNotifications then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Band-transition tracking — fires Notify() only when a category crosses
-- INTO or OUT OF its "bad" band, not on every tick at that level. Mirrors
-- Frostfall's CheckBandTransition/lastTempBand pattern — extended here to a
-- full 4-band system (closer to Frostfall's actual 8-band design than the
-- earlier binary normal/critical version of this file was).
-- ─────────────────────────────────────────────────────────────────────────────

-- 4 bands, divided equally across the 0-100 range (value/25, not tied to any
-- configurable threshold setting — "using the current value as the
-- variable" per the request). Band 1 = best, Band 4 = worst, for ALL four
-- categories — including drunkenness, where "worst" means most drunk (low
-- value), the opposite direction from the other three (low value = worst).
local BAND_MESSAGES = {
    hunger = {
        [1] = "I'm stuffed!",
        [2] = "I could use a snack.",
        [3] = "I'm hungry.",
        [4] = "I'm starving!",
    },
    thirst = {
        [1] = "My thirst is quenched!",
        [2] = "I'm a bit thirsty.",
        [3] = "I need a drink.",
        [4] = "I'm dehydrated!",
    },
    fatigue = {
        [1] = "I'm well rested!",
        [2] = "I could use a break.",
        [3] = "I'm tired, I should find a place to sleep.",
        [4] = "I'm exhausted! I might pass out soon!",
    },
    drunkenness = {
        [1] = "I'm completely sober.",
        [2] = "I'm-*hic*-a bit tipsy.",
        [3] = "I'm-*hic*-nah' drunk, you-*hic*-you're drunk!",
        [4] = "WOOOOOO! I-*hic*-cannaht-*hic*-feel ma facsh!",
    },
}

local _lastBand = { hunger = 1, thirst = 1, fatigue = 1, drunkenness = 1 }

-- Returns 1 (best) through 4 (worst) for the given category/value.
function Feedback.GetBand(category, value)
    value = math.max(0, math.min(100, value))
    if category == "drunkenness" then
        -- low value = best (sober) = band 1; high value = worst = band 4
        if value < 25 then return 1
        elseif value < 50 then return 2
        elseif value < 75 then return 3
        else return 4 end
    else
        -- hunger/thirst/fatigue: high value = best = band 1; low value = worst = band 4
        if value >= 75 then return 1
        elseif value >= 50 then return 2
        elseif value >= 25 then return 3
        else return 4 end
    end
end

-- Returns the status message text for the given category at its CURRENT
-- value — used by both notifications and the status window display.
function Feedback.GetBandMessage(category, value)
    local band = Feedback.GetBand(category, value)
    return BAND_MESSAGES[category][band]
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Returns a short, lore-friendly cure hint for a disease at a given
-- severity — e.g. "A dose of Mudcrab Chitin would ease this." or, when
-- multiple ingredients work at that tier, "...Vile Coagulant or Powdered
-- Mother of Pearl..." Used by both the contraction/worsening notifications
-- and /checkneeds's disease lines. Returns nil if the disease/tier has no
-- ingredients on file (shouldn't currently happen — all 7 diseases have at
-- least a tier-1 entry — but kept defensive in case that changes).
-- ─────────────────────────────────────────────────────────────────────────────
function Feedback.GetCureHintText(diseaseId, severity)
    local def = RN.Diseases[diseaseId]
    if not def then return nil end

    -- The cheapest ingredient that would actually cure at this severity is
    -- the tier exactly matching it (any higher tier also works, but there's
    -- no reason to suggest the rarer one when the matching tier is enough).
    local entries = def.remedyIngredients[severity]
    if not entries or #entries == 0 then return nil end

    local names = {}
    for _, entry in ipairs(entries) do
        table.insert(names, entry.name)
    end
    local ingredientList = table.concat(names, " or ")

    return string.format(
        "A dose of %s (%s) would ease this.",
        ingredientList, def.curativeTraitName
    )
end

-- Shared per-category emote cooldown tracking. Declared here (rather than
-- down near the periodic-retrigger logic) so CheckBandTransition below can
-- record an immediate fire without a forward-reference ordering problem.
local _lastEmoteTime = { hunger = 0, thirst = 0, fatigue = 0, drunkenness = 0, disease = 0 }
local EMOTE_TRIGGER_MIN_BAND = 3  -- worst two bands (3, 4) — bands 1-2 never play an emote

-- Forward declaration: CanPlayEmotesNow is defined further down (it needs
-- MAX/MIN interval constants and IsAnyMajorUIOpen, declared in that section),
-- but CheckBandTransition above the periodic-retrigger section also needs to
-- gate its immediate on-entry emote fire through the same checks (combat,
-- mounted, major UI, and now sit/sleep pose state) rather than firing
-- unconditionally.
local CanPlayEmotesNow

-- Called once per main 5s tick per category (from RealisticNeedsAndDiseases.lua).
-- Notifies on EVERY band transition (worsening or improving) per request —
-- not just entering/leaving a single critical threshold like the previous
-- binary design. Also fires the configured emote IMMEDIATELY the moment a
-- category first crosses into band 3+ from a better band (rather than
-- waiting for the next periodic check) — see Feedback.EmoteTick for the
-- ongoing periodic re-trigger while it remains bad.
function Feedback.CheckBandTransition(sv, category, value)
    local newBand = Feedback.GetBand(category, value)
    local oldBand = _lastBand[category]
    if newBand ~= oldBand then
        Feedback.Notify(BAND_MESSAGES[category][newBand])
        if newBand >= EMOTE_TRIGGER_MIN_BAND and oldBand < EMOTE_TRIGGER_MIN_BAND and CanPlayEmotesNow(sv) then
            Feedback.PlayCategoryEmote(sv, category)
            _lastEmoteTime[category] = GetTimeStamp()
        end
        _lastBand[category] = newBand
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- EMOTE RESOLUTION — real PLAYER_EMOTE_MANAGER enumeration, mirroring
-- Frostfall's FindEmoteIdByDisplayName/BuildEmoteChoices/ResolveEmoteDefaults.
-- ─────────────────────────────────────────────────────────────────────────────
local EMOTE_SEARCH_CATEGORIES = {
    EMOTE_CATEGORY_PHYSICAL,
    EMOTE_CATEGORY_EMOTION,
    EMOTE_CATEGORY_SOCIAL,
    EMOTE_CATEGORY_CHEERS_AND_JEERS,
    EMOTE_CATEGORY_ENTERTAINMENT,
    EMOTE_CATEGORY_CEREMONIAL,
    EMOTE_CATEGORY_FOOD_AND_DRINK,
    EMOTE_CATEGORY_GIVE_DIRECTIONS,
    EMOTE_CATEGORY_POSES_AND_FIDGETS,
    EMOTE_CATEGORY_PROP,
}

-- Real, UESP-confirmed emote names/slash-fallbacks per category. Hunger and
-- thirst have no literal match in ESO's emote list, so these are the closest
-- thematic analogues — flagged honestly, not implied as official "hungry"/
-- "thirsty" animations. Fatigue and disease have exact matches. Drunkenness
-- has an exact match too (there's a real "/drunk" emote).
Feedback.EMOTE_DISPLAY_DEFAULTS = {
    hunger      = "Angry",
    thirst      = "Breathless",
    fatigue     = "Yawn",
    disease     = "Sickened",
    drunkenness = "Drunk",
}
Feedback.EMOTE_SLASH_FALLBACKS = {
    hunger      = "angry",
    thirst      = "breathless",
    fatigue     = "yawn",
    disease     = "sick",
    drunkenness = "drunk",
}

-- Resolved emoteIds, populated by ResolveEmoteDefaults() at load time.
-- sleepPose/sitPose used to live here for /rnd sleep and /rnd sit, which
-- picked a configurable emote to play. Those commands are gone now that
-- sitting/sleeping is detected directly (native /sit-/sleep-family commands
-- and real chair/bench interactions — see Rest.lua), so there's no longer
-- any code path that plays a "configured" sit/sleep emote; whatever the
-- player actually did IS the emote.
Feedback.EmoteIds = { hunger = 0, thirst = 0, fatigue = 0, disease = 0, drunkenness = 0 }

local function FindEmoteIdBySlash(slashName)
    for _, cat in ipairs(EMOTE_SEARCH_CATEGORIES) do
        local emoteIds = PLAYER_EMOTE_MANAGER:GetEmoteListForType(cat) or {}
        for _, emoteId in ipairs(emoteIds) do
            local info = PLAYER_EMOTE_MANAGER:GetEmoteItemInfo(emoteId)
            if info and info.slashName and info.slashName:lower() == slashName:lower() then
                return emoteId
            end
        end
    end
    return 0
end

local function FindEmoteIdByDisplayName(exactName, fallbackSlash)
    local needle = exactName:lower()
    for _, cat in ipairs(EMOTE_SEARCH_CATEGORIES) do
        local emoteIds = PLAYER_EMOTE_MANAGER:GetEmoteListForType(cat) or {}
        for _, emoteId in ipairs(emoteIds) do
            local info = PLAYER_EMOTE_MANAGER:GetEmoteItemInfo(emoteId)
            if info and info.displayName and info.displayName:lower() == needle then
                return emoteId
            end
        end
    end
    return fallbackSlash and FindEmoteIdBySlash(fallbackSlash) or 0
end

-- Resolves all 5 category defaults, applying to saved settings only where
-- the player hasn't already chosen something (emoteId 0 = unresolved/unset).
function Feedback.ResolveEmoteDefaults(sv)
    for category, displayName in pairs(Feedback.EMOTE_DISPLAY_DEFAULTS) do
        local resolved = FindEmoteIdByDisplayName(displayName, Feedback.EMOTE_SLASH_FALLBACKS[category])
        Feedback.EmoteIds[category] = resolved
        if sv.settings.emoteChoiceId[category] == 0 then
            sv.settings.emoteChoiceId[category] = resolved
        end
    end
end

-- Builds label/value lists for Settings dropdowns, covering every emote the
-- player currently owns (including personality-overridden variants) — the
-- same enumeration Frostfall uses for its own emote dropdowns. This is the
-- real "use the game's API to look up available options" mechanism.
function Feedback.BuildEmoteChoices()
    local labels, values = {}, {}
    local seen = {}
    for _, cat in ipairs(EMOTE_SEARCH_CATEGORIES) do
        local emoteIds = PLAYER_EMOTE_MANAGER:GetEmoteListForType(cat) or {}
        for _, emoteId in ipairs(emoteIds) do
            if not seen[emoteId] then
                seen[emoteId] = true
                local info = PLAYER_EMOTE_MANAGER:GetEmoteItemInfo(emoteId)
                if info and info.displayName and info.displayName ~= "" then
                    local slash = info.slashName and ("/" .. info.slashName) or ""
                    table.insert(labels, string.format("%s  %s", info.displayName, slash))
                    table.insert(values, emoteId)
                end
            end
        end
    end
    table.insert(labels, "None (disabled)")
    table.insert(values, 0)
    return labels, values
end

-- Plays emoteId via the confirmed two-step pattern.
local function PlayEmoteId(emoteId)
    if not emoteId or emoteId == 0 then return false end
    local emoteIndex = GetEmoteIndex(emoteId)
    if not emoteIndex then return false end
    PlayEmoteByIndex(emoteIndex)
    return true
end

function Feedback.PlayCategoryEmote(sv, category)
    local emoteId = sv.settings.emoteChoiceId[category]
    return PlayEmoteId(emoteId)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Per-category emote firing — bands 3-4 only. Immediate-on-entry firing is
-- handled inline in CheckBandTransition above (sharing the same
-- _lastEmoteTime table declared there). This section handles the ONGOING
-- periodic re-trigger while a category remains in band 3-4, at a frequency
-- that scales continuously with how deep into the bad range the value is:
-- slowest right at the band-3 boundary, fastest at the extreme (0 for needs,
-- 100 for drunkenness). Independent per-category timers, so e.g. hunger and
-- thirst being bad simultaneously doesn't starve one of them out the way a
-- single shared check used to.
-- ─────────────────────────────────────────────────────────────────────────────
local MAX_EMOTE_INTERVAL_SECONDS = 25  -- at the boundary into band 3
local MIN_EMOTE_INTERVAL_SECONDS = 5   -- at the absolute extreme (0, or 100 for drunkenness)

local function IsAnyMajorUIOpen()
    return not SCENE_MANAGER:IsShowing("hud")
end

-- 0 at the band-3 boundary (value=50), 1 at the extreme (0, or 100 for drunkenness).
local function GetSeverityFraction(category, value)
    if category == "drunkenness" then
        return math.max(0, math.min(1, (value - 50) / 50))
    else
        return math.max(0, math.min(1, (50 - value) / 50))
    end
end

local function GetEmoteIntervalSeconds(category, value)
    local fraction = GetSeverityFraction(category, value)
    return MAX_EMOTE_INTERVAL_SECONDS - fraction * (MAX_EMOTE_INTERVAL_SECONDS - MIN_EMOTE_INTERVAL_SECONDS)
end

function CanPlayEmotesNow(sv)
    if not sv.settings.enableEmotes then return false end
    if IsUnitInCombat("player") then return false end
    if IsMounted() then return false end
    if IsAnyMajorUIOpen() then return false end
    -- Don't let a status emote (hunger/thirst/fatigue/drunkenness/disease)
    -- cancel a sit or sleep pose already in progress — whether that pose
    -- came from a native /sit-/sleep-family command or from interacting
    -- with a real chair/bench (see Rest.lua's hooked SIT_COMMANDS/
    -- SLEEP_COMMANDS, HookWorldInteractionDetection, and Rest.IsResting()).
    if RN.Rest and RN.Rest.IsResting() then return false end
    return true
end
Feedback.CanPlayEmotesNow = CanPlayEmotesNow

local function MaybeRetriggerBandEmote(sv, category, value)
    if Feedback.GetBand(category, value) < EMOTE_TRIGGER_MIN_BAND then return end
    if not CanPlayEmotesNow(sv) then return end

    local interval = GetEmoteIntervalSeconds(category, value)
    local now = GetTimeStamp()
    if now - (_lastEmoteTime[category] or 0) >= interval then
        Feedback.PlayCategoryEmote(sv, category)
        _lastEmoteTime[category] = now
    end
end

-- Called once per main 5s tick (from RealisticNeedsAndDiseases.lua's OnTick)
-- for the ongoing periodic re-trigger across all 4 banded categories.
function Feedback.EmoteTick(sv)
    MaybeRetriggerBandEmote(sv, "hunger", sv.needs.hunger)
    MaybeRetriggerBandEmote(sv, "thirst", sv.needs.thirst)
    MaybeRetriggerBandEmote(sv, "fatigue", sv.needs.fatigue)
    MaybeRetriggerBandEmote(sv, "drunkenness", sv.needs.drunkenness)
    Feedback.MaybeFireDiseaseEmote(sv)
end

-- Disease doesn't have a 0-100 "value" to scale frequency against, so it
-- keeps a simpler fixed-interval re-trigger once active, but still fires
-- immediately on contraction/escalation via Disease.OnDiseaseChanged calling
-- Feedback.PlayCategoryEmote directly (see Disease.lua).
local DISEASE_EMOTE_INTERVAL_SECONDS = 30

function Feedback.MaybeFireDiseaseEmote(sv)
    if next(sv.diseaseState) == nil then return end
    if not CanPlayEmotesNow(sv) then return end
    local now = GetTimeStamp()
    if now - (_lastEmoteTime.disease or 0) >= DISEASE_EMOTE_INTERVAL_SECONDS then
        Feedback.PlayCategoryEmote(sv, "disease")
        _lastEmoteTime.disease = now
    end
end

function Feedback.NoteImmediateEmote(category)
    _lastEmoteTime[category] = GetTimeStamp()
end

-- No-op as of this version — the dedicated fixed-interval emote timer was
-- replaced by Feedback.EmoteTick(sv), called once per main 5s tick from
-- RealisticNeedsAndDiseases.lua's OnTick. Kept as an empty function so the
-- existing call site at addon load doesn't need to change.
function Feedback.Initialize()
end
