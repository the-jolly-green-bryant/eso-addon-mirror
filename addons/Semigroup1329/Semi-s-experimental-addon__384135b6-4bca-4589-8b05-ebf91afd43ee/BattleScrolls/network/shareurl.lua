-----------------------------------------------------------
-- ShareUrl
-- Sends export streams to the share site through the only egress consoles
-- have: RequestOpenUnsafeURL. The payload rides in the URL fragment of
-- https://<share host>/u; the page posts it to the API and redirects to the
-- share link.
--
-- Transport facts this module is built on (measured + esoui source):
--   * Xbox caps at 32655 total URL chars and FAILS SILENTLY above - chunk
--     sizes must be clamped client-side.
--   * There is no queue in the open-URL pipeline: bursts lose everything.
--     Only serial user-confirmed stepping works for multi-part payloads.
--   * The "Confirm Open URL" dialog (CONFIRM_UNSAFE_URL) lives in the
--     internalingame GUI environment. Nothing in this environment sees it
--     through ZO_Dialogs (ZO_Dialogs_IsShowingDialog() stays false); the
--     one cross-environment window is ZO_DIALOG_SYNC_OBJECT, a
--     SynchronizingObject shared by name between the GUI environments.
--   * Cancelling that dialog with B makes internalingame request the base
--     scene (ZO_Dialogs_CloseKeybindPressed -> RequestShowLeaderBaseScene),
--     which tears down whatever gamepad scene is open here. Observable via
--     EVENT_REMOTE_SCENE_REQUEST; doubles as decline evidence. Confirming,
--     or declining via the "No" button, leaves the scene alone - so the
--     journal scene survives the normal round-trip and hosts the stepper
--     as a first-class view (ui/journal/share_stepper.lua), each part
--     fired by a real keybind press.
--   * Closing the console browser with B delivers that same B to our
--     keybind strip as the game resumes (the app-switcher return path
--     delivers nothing) - stepper presses landing right after a suspend
--     gap are discarded (browser-exit leak guard in ui/journal/keybinds.lua).
--
-- Because RequestOpenUnsafeURL reports nothing back, a fired part is held
-- "in flight" and only counted as sent once its confirm dialog has come and
-- gone without decline evidence. Declining via the "No" button is
-- indistinguishable from confirming (both just close the dialog); that
-- residual gap surfaces as a missing part on the upload page.
--
-- This module is presentation-free: it owns the chain state machine and
-- notifies an observer (the journal) on every transition.
-----------------------------------------------------------

if not SemisPlaygroundCheckAccess() then
    return
end

BattleScrolls = BattleScrolls or {}

---@class BattleScrollsShareUrl
---@field _doneTotal number|nil Part count of the last completed chain
local shareUrl = {}
BattleScrolls.shareUrl = shareUrl

local BASE_URL = "https://bs.sheludchenkov.com/u"
-- Multiple of 4 so every part is independently valid base64; leaves ample
-- headroom for the ~70 chars of scheme/host/fragment params under the 32655
-- Xbox cap
local CHUNK_DATA_CHARS = 32000
local SESSION_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

---@alias SharePhase "idle"|"building"|"sending"|"done"|"failed"

---@class ShareChain
---@field parts string[] Base64 data parts
---@field session string Upload session id
---@field lang string Game client language (drives the upload page's texts)
---@field nextSeq number Next part to fire (1-based)
---@field total number

---@class ShareState
---@field phase SharePhase
---@field sentCount number Parts already fired
---@field total number Part count (0 while building)

---@type ShareChain|nil
local chain = nil
---@type Fiber|nil
local buildFiber = nil
---@type SharePhase
local phase = "idle"

-- In-flight part settlement (see header): the fired part whose confirm
-- dialog has not resolved yet, plus the evidence gathered while watching it
local WATCH_NAMESPACE = "BattleScrollsShareUrlInFlight"
local WATCH_INTERVAL_MS = 300
local NO_DIALOG_TIMEOUT_MS = 4000
local SETTLE_GRACE_MS = 400
---@type number|nil
local inFlightSeq = nil
local confirmDialogSeen = false
local declineSeen = false
local firedAtMs = 0
---@type number|nil
local settleAtMs = nil

local function clearInFlight()
    EVENT_MANAGER:UnregisterForUpdate(WATCH_NAMESPACE)
    inFlightSeq = nil
    confirmDialogSeen = false
    declineSeen = false
    firedAtMs = 0
    settleAtMs = nil
end

---Observer for state transitions (the journal's stepper view). Called with
---no arguments after every phase/progress change.
---@type fun()|nil
shareUrl.onStateChanged = nil

local function notify()
    if shareUrl.onStateChanged then
        shareUrl.onStateChanged()
    end
end

---@param newPhase SharePhase
local function setPhase(newPhase)
    phase = newPhase
    notify()
end

-- =============================================================================
-- STATE
-- =============================================================================

---Snapshot for the stepper view.
---@return ShareState
function shareUrl.getState()
    return {
        phase = phase,
        sentCount = chain and (chain.nextSeq - 1) or (phase == "done" and shareUrl._doneTotal or 0),
        total = chain and chain.total or (phase == "done" and shareUrl._doneTotal or 0),
    }
end

---True while a build or an unfinished chain is active ("done"/"failed" are
---resting states, not busy).
---@return boolean
function shareUrl.isBusy()
    return chain ~= nil or buildFiber ~= nil
end

---Cancels any build or send in progress.
---@return boolean hadWork
function shareUrl.stop()
    local hadWork = chain ~= nil or buildFiber ~= nil
    if buildFiber then
        buildFiber:Cancel()
        buildFiber = nil
    end
    chain = nil
    clearInFlight()
    setPhase("idle")
    return hadWork
end

-- =============================================================================
-- CHAIN
-- =============================================================================

---@return string
local function newSessionId()
    local out = {}
    for i = 1, 8 do
        local idx = math.random(1, #SESSION_ALPHABET)
        out[i] = SESSION_ALPHABET:sub(idx, idx)
    end
    return table.concat(out)
end

---@param seq number
---@return string
local function partUrl(seq)
    return string.format("%s#s=%s&i=%d&n=%d&l=%s&d=%s",
        BASE_URL, chain.session, seq, chain.total, chain.lang, chain.parts[seq])
end

---Counts the in-flight part as sent (or leaves it pending if declined) and
---moves the chain forward. Runs a beat after the confirm dialog goes away.
local function settleInFlight()
    local seq = inFlightSeq
    local wasDeclined = declineSeen
    clearInFlight()
    if not chain or not seq then
        return
    end
    if wasDeclined then
        -- The part never reached the browser: leave it pending so the next
        -- press fires the same part again
        notify()
    elseif seq >= chain.total then
        shareUrl._doneTotal = chain.total
        chain = nil
        setPhase("done")
    else
        chain.nextSeq = seq + 1
        notify()
    end
end

---Watches the cross-environment dialog state while a part is in flight.
local function watchInFlight()
    if not inFlightSeq then
        clearInFlight()
        return
    end
    if ZO_DIALOG_SYNC_OBJECT:IsShown()
        and ZO_DIALOG_SYNC_OBJECT:GetState() == "CONFIRM_UNSAFE_URL" then
        confirmDialogSeen = true
        settleAtMs = nil
        return
    end
    local nowMs = GetGameTimeMilliseconds()
    if confirmDialogSeen then
        -- Dialog came and went; give decline evidence (the remote
        -- base-scene request) a beat to arrive before settling
        settleAtMs = settleAtMs or (nowMs + SETTLE_GRACE_MS)
        if nowMs >= settleAtMs then
            settleInFlight()
        end
    elseif nowMs - firedAtMs >= NO_DIALOG_TIMEOUT_MS then
        -- No confirm dialog ever appeared - count the part as not sent
        -- rather than pretend it was
        declineSeen = true
        settleInFlight()
    end
end

---Fires the next pending part's browser link. The caller (stepper keybind)
---invokes this once per user press; the part stays pending until its confirm
---dialog resolves without decline evidence.
function shareUrl.sendNextPart()
    if not chain or inFlightSeq then
        return
    end
    local seq = chain.nextSeq
    RequestOpenUnsafeURL(partUrl(seq))
    inFlightSeq = seq
    confirmDialogSeen = false
    declineSeen = false
    firedAtMs = GetGameTimeMilliseconds()
    settleAtMs = nil
    EVENT_MANAGER:RegisterForUpdate(WATCH_NAMESPACE, WATCH_INTERVAL_MS, watchInFlight)
    notify()
end

---True while the stepper must not fire another URL: a part's confirmation
---round-trip has not settled, or a dialog (any GUI environment) owns input.
---@return boolean
function shareUrl.isSendBlocked()
    return inFlightSeq ~= nil or ZO_DIALOG_SYNC_OBJECT:IsShown()
end

-- Decline evidence: cancelling the confirm dialog with B makes the internal
-- environment kick the ingame scene manager to the base scene
EVENT_MANAGER:RegisterForEvent("BattleScrollsShareUrlDecline", EVENT_REMOTE_SCENE_REQUEST,
    function(_, messageOrigin, requestType)
        if inFlightSeq
            and messageOrigin == SCENE_MANAGER_MESSAGE_ORIGIN_INTERNAL
            and requestType == REMOTE_SCENE_REQUEST_TYPE_SHOW_BASE_SCENE then
            declineSeen = true
        end
    end)

---@param exportResult ExportResult
local function startChain(exportResult)
    local b64 = BattleScrolls.export.bytesToBase64(exportResult.bytes)
    local parts = {}
    for start = 1, #b64, CHUNK_DATA_CHARS do
        parts[#parts + 1] = b64:sub(start, start + CHUNK_DATA_CHARS - 1)
    end
    chain = {
        parts = parts,
        session = newSessionId(),
        lang = GetCVar("Language.2") or "en",
        nextSeq = 1,
        total = #parts,
    }
    setPhase("sending")
end

-- =============================================================================
-- PUBLIC ENTRY POINTS
-- =============================================================================

---@param buildEffect Effect Effect resolving to ExportResult
local function runShare(buildEffect)
    if shareUrl.isBusy() then
        return
    end
    setPhase("building")
    buildFiber = BattleScrolls.Effect.Async(function()
        local result = buildEffect:Await()
        startChain(result)
    end):Recover(function()
        chain = nil
        setPhase("failed")
        return nil
    end):Ensure(function()
        buildFiber = nil
    end):Run()
end

---Shares one encounter (view profile) via the browser.
---@param instance InstanceStorage
---@param encounter CompactEncounter
function shareUrl.shareEncounter(instance, encounter)
    runShare(BattleScrolls.export.buildEncounterShareAsync(instance, encounter))
end

---Uploads a whole instance (archive profile, full fidelity) via the browser.
---@param instance InstanceStorage
function shareUrl.uploadInstance(instance)
    runShare(BattleScrolls.export.buildInstanceArchiveAsync(instance))
end

SLASH_COMMANDS["/bsshare"] = function(args)
    if args:match("^%s*stop%s*$") then
        if shareUrl.stop() then
            d("[" .. GetString(BATTLESCROLLS_UI_NAME) .. "] " .. GetString(BATTLESCROLLS_SHARE_CANCELLED))
        end
    end
end
