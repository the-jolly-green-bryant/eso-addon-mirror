-----------------------------------------------------------
-- ShareUrl
-- Sends export streams to the share site through the only egress consoles
-- have: RequestOpenUnsafeURL. The payload rides in the URL fragment of
-- https://<share host>/u; the page posts it to the API and redirects to the
-- share link.
--
-- Transport facts this module is built on (measured, see url-share-limits):
--   * Xbox caps at 32655 total URL chars and FAILS SILENTLY above - chunk
--     sizes must be clamped client-side.
--   * There is no queue in the open-URL pipeline: bursts lose everything.
--     Only serial user-confirmed stepping works for multi-part payloads.
--   * ZO_Dialogs do not survive the URL confirmation (scene fragment release
--     + cross-environment dialog sync), but the gamepad journal scene DOES -
--     so the stepper lives there as a first-class view
--     (ui/journal/share_stepper.lua) and each part is fired by a real
--     keybind press. No advance gestures.
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

---Fires the next part's browser link. The caller (stepper keybind) invokes
---this once per user press; there is no auto-advance.
function shareUrl.sendNextPart()
    if not chain then
        return
    end
    local seq, total = chain.nextSeq, chain.total
    RequestOpenUnsafeURL(partUrl(seq))
    if seq >= total then
        shareUrl._doneTotal = total
        chain = nil
        setPhase("done")
    else
        chain.nextSeq = seq + 1
        notify()
    end
end

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
