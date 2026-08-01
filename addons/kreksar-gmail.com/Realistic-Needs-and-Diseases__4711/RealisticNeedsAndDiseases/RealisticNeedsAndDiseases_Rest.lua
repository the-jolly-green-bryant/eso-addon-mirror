-- RealisticNeedsAndDiseases_Rest.lua
-- Three ways to recover fatigue, addressing the gap noted in earlier
-- versions (fatigue previously had no restore action at all):
--   1. Standing still, out of combat, for several minutes — slow passive regen.
--   2. Sitting (any /sit variant, /sitchair, or a real in-world chair/bench),
--      out of combat, for about a minute — faster regen than just standing still.
--   3. Holding a sleep/meditate/faint pose for a while — full restore.
--
-- All three gate on: out of combat, and not moving (own position only — see
-- the position-reading note below, which is allowed; the API restriction is
-- on OTHER units' positions, not your own).
--
-- There is no RND-specific command to start sitting or sleeping — mechanics
-- 2 and 3 are triggered purely by detecting the player doing the real thing,
-- via two independent detection paths that both funnel into the same
-- OnSitTriggered/OnSleepTriggered:
--   a. Native /sit-/sleep-family slash commands are HOOKED (original handler
--      preserved and still called) rather than polled via some "is player
--      sleeping" state query, since I don't have confident knowledge of such
--      a query existing. This is confirmed reliable, not just a guess: the
--      current ESOUI source shows ZOS's own PLAYER_EMOTE_MANAGER registers
--      every native emote — including /sit, /sleep, /sitchair, etc. — into
--      this exact same addon-visible SLASH_COMMANDS table itself
--      (ZO_PlayerEmote_Manager:AddOrRemoveEmoteSlashCommand in
--      playeremotemanager.lua), so hooking it is on solid ground.
--   b. Interacting with a real in-world object whose reticle prompt reads
--      "Sit" (a placeable chair, a bench, etc.) doesn't go through those
--      slash commands at all, so it needs its own detection path — see the
--      "World-object interaction detection" section below for how this is
--      done and a note on an earlier, incorrect attempt at it.

RealisticNeeds = RealisticNeeds or {}
local RN = RealisticNeeds

local Rest = {}
RN.Rest = Rest

local POSITION_EPSILON = 5  -- world-unit movement tolerance per tick before counting as "moved", for mechanic 1 (standing-still regen) only
-- ROOT CAUSE OF THE PERSISTENT SLEEP/SIT-POSE INTERRUPT BUG: a separate,
-- far more lenient tolerance for canceling an ALREADY-ACTIVE seated/
-- sleeping pose. POSITION_EPSILON=5 is fine for detecting "did the player
-- get up and walk off" while idle-standing, but a sit/sleep/faint/pray
-- pose's own settle-into-position animation (and any subsequent idle sway)
-- very plausibly shifts the tracked root position by more than 5 world
-- units within a single 5-second tick on its own — which, with the single
-- shared epsilon this used to have, was flipping _isSeated/_isSleeping back
-- to false within one tick of being set, re-opening CanPlayEmotesNow's
-- gate and letting a status emote fire (and visibly cancel the pose) only
-- seconds after a sit/sleep pose started. That's the actual fix here
-- — not the emote-gating logic itself (which was already correct), but
-- this false-positive "moved" detection undermining it from underneath.
-- This value is a deliberately generous guess, NOT confirmed against real
-- in-client position deltas during a sleep/sit pose — if interruptions
-- still happen after this, the right next step is logging the actual
-- per-tick distSq while seated/sleeping (e.g. via a temporary
-- /rnd debug-style print) and raising this further to match.
local REST_POSITION_EPSILON = 150
local _lastPosition = nil
local _stationarySeconds = 0
local _seatedSeconds = 0
local _sleepSeconds = 0
local _isSeated = false
local _isSleeping = false

-- ─────────────────────────────────────────────────────────────────────────────
-- Movement tracking (own position only — reading your own coordinates is
-- allowed; only reading OTHER units' positions is restricted)
-- ─────────────────────────────────────────────────────────────────────────────
-- maxDistance lets the seated/sleeping check use REST_POSITION_EPSILON
-- instead of the tighter POSITION_EPSILON, since the two mechanics need
-- very different movement tolerances (see the comment above).
local function HasPlayerMoved(maxDistance)
    maxDistance = maxDistance or POSITION_EPSILON
    local x, y, z = GetUnitWorldPosition("player")
    if not x then return true end  -- if the API fails for any reason, assume moved (fail safe, don't grant free regen)

    if not _lastPosition then
        _lastPosition = { x = x, y = y, z = z }
        return false
    end

    local dx, dy, dz = x - _lastPosition.x, y - _lastPosition.y, z - _lastPosition.z
    local distSq = dx * dx + dy * dy + dz * dz
    _lastPosition = { x = x, y = y, z = z }

    return distSq > (maxDistance * maxDistance)
end

local function IsEligibleForRest()
    return not IsUnitInCombat("player")
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Hooking the sit/sleep/meditate slash commands
-- ─────────────────────────────────────────────────────────────────────────────
-- "Meditate" has no literal emote on UESP's list — /pray and /kneelpray are
-- the closest thematic substitutes (kneeling, hands together in prayer),
-- used here as a stand-in. Flagged honestly rather than implying ESO has an
-- actual meditate animation.
local SIT_COMMANDS   = { "/sit", "/sit2", "/sit3", "/sit4", "/sit5", "/sit6", "/sitchair" }
local SLEEP_COMMANDS = { "/sleep", "/sleep2", "/faint", "/pray", "/kneelpray" }  -- "meditate" stand-ins: /pray, /kneelpray

local function HookCommand(commandString, onTriggered)
    local original = SLASH_COMMANDS[commandString]
    if not original then return end  -- command not available in this client; nothing to hook
    SLASH_COMMANDS[commandString] = function(args)
        original(args)
        onTriggered()
    end
end

local function OnSitTriggered()
    local alreadySeated = _isSeated
    _isSeated = true
    _seatedSeconds = 0
    _isSleeping = false  -- sitting cancels any in-progress sleep tracking
    _sleepSeconds = 0
    -- Re-baseline rather than comparing against a pre-pose position — the
    -- act of sitting down itself shifts the tracked root position, and
    -- without this reset that shift alone could immediately read as
    -- "moved" on the very next tick.
    _lastPosition = nil
    -- Only announce on the actual transition into sitting, not on every
    -- re-trigger while already seated (e.g. the world-interaction hook
    -- firing again from a repeated interact keypress) — otherwise this
    -- could spam chat.
    if not alreadySeated then
        RN.Feedback.Notify("You take a seat to rest.", { chatOnly = true })
    end
end

local function OnSleepTriggered()
    local alreadySleeping = _isSleeping
    _isSleeping = true
    _sleepSeconds = 0
    _isSeated = false
    _seatedSeconds = 0
    -- Same re-baselining as OnSitTriggered above, for the same reason.
    _lastPosition = nil
    -- Same anti-spam guard as OnSitTriggered above.
    if not alreadySleeping then
        RN.Feedback.Notify("You settle in to sleep.", { chatOnly = true })
    end
end

-- Exposed so Feedback.lua can suppress status emotes (hunger/thirst/fatigue/
-- drunkenness/disease) while the player is already holding a sit or sleep
-- pose — whether started via a native /sit-/sleep-family command or by
-- interacting with a real chair/bench (see HookWorldInteractionDetection
-- below). Without this, a status emote firing mid-pose cancels the
-- animation the player just started.
function Rest.IsResting()
    return _isSeated or _isSleeping
end

-- ─────────────────────────────────────────────────────────────────────────────
-- World-object interaction detection ("Sit" prompts on real in-world chairs,
-- benches, etc.)
-- ─────────────────────────────────────────────────────────────────────────────
-- History of getting this hook right, kept here because it explains why the
-- code below looks the way it does:
--   v0.18.1: reassigned FISHING_MANAGER.StartInteraction, following
--       NoInteract's example directly. Broke on load with "attempt to index
--       a nil value" — ZOS has removed the standalone FishingManager class
--       from the current client, so that global doesn't exist at all
--       anymore. It was also never actually correct even before that
--       removal: FISHING_MANAGER:StartInteraction() only ever dispatched to
--       the fishing radial-wheel UI, so it would never have fired for a
--       chair's "Sit" prompt regardless.
--   v0.18.2: switched to reassigning the bare global GameCameraInteractStart,
--       reasoning that it was the function bindings.xml's GAME_CAMERA_INTERACT
--       keybind calls. Broke on load with "Attempt to access a private
--       function 'GameCameraInteractStart' from insecure code" —
--       GameCameraInteractStart is a genuinely protected engine function;
--       no addon can even read it, let alone override it.
--   v0.18.3 (this version): pulling the actual current ESOUI source
--       (github.com/esoui/esoui) shows the real keybind chain is:
--         <Down>if not INTERACTIVE_WHEEL_MANAGER:StartInteraction(ZO_INTERACTIVE_WHEEL_TYPE_FISHING)
--             then GameCameraInteractStart() end</Down>
--       INTERACTIVE_WHEEL_MANAGER is a plain, unprotected Lua object (a
--       ZO_InteractiveWheel_Manager instance) — the direct modern successor
--       to FISHING_MANAGER, which it replaced entirely. Its :StartInteraction
--       method is called UNCONDITIONALLY on every single interact keypress,
--       before the engine ever decides whether to fall through to the
--       protected GameCameraInteractStart. That makes it the actual current
--       equivalent of what NoInteract's FISHING_MANAGER hook was reaching
--       for — same pattern (reassign the method, preserve and always call
--       the original), just pointed at the object that exists today.
--
-- Two hooks, both confirmed against the current ESOUI source:
--   1. ZO_PreHook on RETICLE:TryHandlingInteraction, reading the current
--      interaction prompt text via GetGameCameraInteractableActionInfo().
--      Same technique NoInteract uses to read reticle state; never blocks
--      anything here (always returns false).
--   2. Reassigning INTERACTIVE_WHEEL_MANAGER.StartInteraction (original
--      preserved and always called) as the "the interact key was just
--      pressed" trigger point.
--
-- Matching is done on whole words (splitting the prompt text on whitespace)
-- rather than a substring search, so prompts like "Deposit" or "Visit" can
-- never false-positive against "sit". The action verb ("Sit") and the
-- interactable's own name ("Wooden Chair", "Tavern Bench", etc.) are both
-- checked against the same word list, concatenated together — most of these
-- words are realistically going to show up in the object's name rather than
-- the verb, while "Sit"/"Seat" could plausibly appear in either, so checking
-- both fields against the full list covers all of that without needing to
-- track which word came from which field.
--
-- Only "Sit" (as the action verb) and "Chair" (as an object name) have
-- actually been observed in-game here. The rest of this list is
-- speculative/defensive, the same way "Sleep" already was — plausible
-- names for other real-world sittable furniture (a pew in a temple, a
-- stool at a bar, a couch in a house) that simply haven't been confirmed
-- against an actual in-game object yet. If a word here never matches
-- anything, that branch just never fires, which is harmless; if RND turns
-- out to be missing a real one, it's easy to add.
local SIT_INTERACTION_WORDS = {
    "sit", "seat", "chair", "bench", "stool", "pew", "throne",
    "couch", "sofa", "settee", "loveseat", "ottoman", "stump", "log",
}
local SLEEP_INTERACTION_WORDS = { "sleep" }

local function InteractionMatchesAnyWord(text, words)
    if not text then return false end
    for token in text:gmatch("%a+") do
        local lowerToken = token:lower()
        for _, word in ipairs(words) do
            if lowerToken == word then
                return true
            end
        end
    end
    return false
end

local _lastInteractionText = nil

local function HookWorldInteractionDetection()
    -- Hook 1: observe the reticle's current interaction ACTION VERB (e.g.
    -- "Sit", "Loot", "Talk to") together with the interactable's own name
    -- (e.g. "Wooden Chair") — GetGameCameraInteractableActionInfo()'s first
    -- and second return values respectively. Confirmed against the current
    -- ESOUI source: reticle.lua destructures it as
    -- "local action, interactableName, ... = GetGameCameraInteractableActionInfo()"
    -- and displays "action" on the keybind button ("Sit", etc.) while
    -- interactableName is separate context text. Both are concatenated into
    -- one string here so InteractionMatchesAnyWord can check both fields at
    -- once (see that function's comment above for why both matter).
    --
    -- BUG FIXED (0.18.4): this previously did "local _, text = ...",
    -- discarding "action" and keeping only "interactableName" — copied
    -- directly from NoInteract's own destructuring without noticing
    -- NoInteract wants interactableName for its own purpose (matching NPC/
    -- object names against a blacklist), which on its own missed the action
    -- verb "Sit" entirely. Now capturing both fields together.
    --
    -- Returning false (never true) means this hook never blocks the
    -- interaction — it only ever records what the current prompt says.
    ZO_PreHook(RETICLE, "TryHandlingInteraction", function(interactionPossible)
        if interactionPossible then
            local action, interactableName = GetGameCameraInteractableActionInfo()
            _lastInteractionText = (action or "") .. " " .. (interactableName or "")
        end
        return false
    end)

    -- Hook 2: fires on every interact keypress (see the section comment
    -- above for why INTERACTIVE_WHEEL_MANAGER.StartInteraction is the right
    -- — and safely unprotected — place to catch this).
    if INTERACTIVE_WHEEL_MANAGER then
        local originalWheelStartInteraction = INTERACTIVE_WHEEL_MANAGER.StartInteraction
        INTERACTIVE_WHEEL_MANAGER.StartInteraction = function(...)
            if InteractionMatchesAnyWord(_lastInteractionText, SIT_INTERACTION_WORDS) then
                OnSitTriggered()
            elseif InteractionMatchesAnyWord(_lastInteractionText, SLEEP_INTERACTION_WORDS) then
                OnSleepTriggered()
            end
            return originalWheelStartInteraction(...)
        end
    end
    -- If INTERACTIVE_WHEEL_MANAGER doesn't exist (future API change), this
    -- silently skips the world-interaction path rather than erroring — the
    -- native /sit-/sleep-family slash-command hooks above still work
    -- independently of this.
end

function Rest.Initialize()
    for _, cmd in ipairs(SIT_COMMANDS) do
        HookCommand(cmd, OnSitTriggered)
    end
    for _, cmd in ipairs(SLEEP_COMMANDS) do
        HookCommand(cmd, OnSleepTriggered)
    end
    HookWorldInteractionDetection()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Main per-tick evaluation
-- ─────────────────────────────────────────────────────────────────────────────
local function ApplyRestingDrunkennessDecay(sv, tickSeconds)
    -- Drunkenness mechanic (#1): resting accelerates sobering up, on top of
    -- the baseline decay already applied every tick in the core file's OnTick.
    local extraDecay = sv.settings.drunkennessBaselineDecayPerSecond
                       * (sv.settings.drunkennessRestMultiplier - 1) * tickSeconds
    sv.needs.drunkenness = math.max(0, sv.needs.drunkenness - extraDecay)
end

function Rest.OnTick(sv, tickSeconds)
    -- Use the far more lenient tolerance while an explicit sit/sleep pose is
    -- already active — see REST_POSITION_EPSILON's comment above for why.
    local moved = HasPlayerMoved((_isSeated or _isSleeping) and REST_POSITION_EPSILON or POSITION_EPSILON)
    local eligible = IsEligibleForRest()

    if moved or not eligible then
        _stationarySeconds = 0
        _seatedSeconds = 0
        _sleepSeconds = 0
        if moved then
            _isSeated = false
            _isSleeping = false
        end
        return
    end

    -- Mechanic 1: standing still (not seated, not sleeping), out of combat
    if not _isSeated and not _isSleeping then
        _stationarySeconds = _stationarySeconds + tickSeconds
        if _stationarySeconds >= sv.settings.restStationaryThresholdSeconds then
            local restored = sv.settings.restStationaryRegenPerSecond * tickSeconds
            sv.needs.fatigue = math.min(100, sv.needs.fatigue + restored)
            ApplyRestingDrunkennessDecay(sv, tickSeconds)
        end
    end

    -- Mechanic 2: seated
    if _isSeated then
        _seatedSeconds = _seatedSeconds + tickSeconds
        if _seatedSeconds >= sv.settings.restSeatedThresholdSeconds then
            local restored = sv.settings.restSeatedRegenPerSecond * tickSeconds
            sv.needs.fatigue = math.min(100, sv.needs.fatigue + restored)
            ApplyRestingDrunkennessDecay(sv, tickSeconds)
        end
    end

    -- Mechanic 3: sleeping/meditating — full restore, once
    if _isSleeping then
        _sleepSeconds = _sleepSeconds + tickSeconds
        ApplyRestingDrunkennessDecay(sv, tickSeconds)  -- sobering up happens throughout, not just at the end
        if _sleepSeconds >= sv.settings.restSleepThresholdSeconds then
            _isSleeping = false
            _sleepSeconds = 0
            sv.needs.fatigue = 100
            RN.Feedback.Notify("You feel fully rested.")
        end
    end
end
