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
--   * There is no queue in the open-URL pipeline: bursts lose everything and
--     paced timers tear down the previous confirmation dialog. Only serial
--     user-confirmed stepping works for multi-part payloads.
--   * A ZO_Dialogs stepper does not survive the URL confirmation (scene
--     fragment release + cross-environment dialog sync); the stepper is an
--     unmanaged TopLevelControl.
--   * Consoles have no addon keybinds and EVENT_GAME_FOCUS_CHANGED does not
--     fire around the browser app-switch, so multi-part advance gestures are:
--     crouch (STEALTH_STATE_NONE -> non-NONE edge only) or opening and
--     closing any menu. Focus regain stays as a PC convenience.
-----------------------------------------------------------

if not SemisPlaygroundCheckAccess() then
    return
end

BattleScrolls = BattleScrolls or {}

---@class BattleScrollsShareUrl
local shareUrl = {}
BattleScrolls.shareUrl = shareUrl

local BASE_URL = "https://bs.sheludchenkov.com/u"
-- Multiple of 4 so every part is independently valid base64; leaves ample
-- headroom for the ~70 chars of scheme/host/fragment params under the 32655
-- Xbox cap
local CHUNK_DATA_CHARS = 32000
local SESSION_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
local WIDGET_AUTOHIDE_MS = 15000
local ADVANCE_DELAY_MS = 2000

---@class ShareChain
---@field parts string[] Base64 data parts
---@field session string Upload session id
---@field nextSeq number
---@field total number

---@type ShareChain|nil
local chain = nil
---@type Fiber|nil
local buildFiber = nil
---True after a part was requested: the next advance gesture fires the next one
local awaitingReturn = false
---True once a non-HUD scene was shown while awaiting; the next HUD show
---counts as the menu open+close gesture
local sawMenuScene = false
local lastStealthState = STEALTH_STATE_NONE
---@type integer[]
local pendingCalls = {}

-- =============================================================================
-- STEPPER WIDGET (unmanaged TopLevelControl, invisible to scene/dialog systems)
-- =============================================================================

---@type TopLevelWindow|nil
local widget
---@type LabelControl|nil
local widgetLabel

---@return LabelControl
local function ensureWidget()
    if widgetLabel then
        return widgetLabel
    end
    widget = WINDOW_MANAGER:CreateTopLevelWindow("BattleScrollsShareStepper")
    widget:SetDimensions(1100, 160)
    widget:SetAnchor(TOP, GuiRoot, TOP, 0, 80)
    widget:SetMouseEnabled(false)
    widget:SetMovable(false)
    widget:SetDrawLayer(DL_OVERLAY)

    local bg = WINDOW_MANAGER:CreateControl("BattleScrollsShareStepperBG", widget, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, widget, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, widget, BOTTOMRIGHT, 0, 0)
    bg:SetCenterColor(0, 0, 0, 0.7)
    bg:SetEdgeColor(0, 0, 0, 0)
    bg:SetEdgeTexture("", 1, 1, 1, 0)

    widgetLabel = WINDOW_MANAGER:CreateControl("BattleScrollsShareStepperLabel", widget, CT_LABEL) --[[@as LabelControl]]
    widgetLabel:SetFont("ZoFontGamepad34")
    widgetLabel:SetColor(1, 1, 1, 1)
    widgetLabel:SetAnchor(TOPLEFT, widget, TOPLEFT, 30, 15)
    widgetLabel:SetAnchor(BOTTOMRIGHT, widget, BOTTOMRIGHT, -30, -15)
    widgetLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    widgetLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return widgetLabel
end

---@param text string
local function showWidget(text)
    ensureWidget():SetText(text)
    widget:SetHidden(false)
end

local function hideWidget()
    if widget then
        widget:SetHidden(true)
    end
end

-- =============================================================================
-- CHAIN STATE
-- =============================================================================

local function clearPendingCalls()
    for _, id in ipairs(pendingCalls) do
        zo_removeCallLater(id)
    end
    ZO_ClearNumericallyIndexedTable(pendingCalls)
end

---Cancels any build or send in progress.
---@return boolean hadWork
function shareUrl.stop()
    local hadWork = chain ~= nil or buildFiber ~= nil
    if buildFiber then
        buildFiber:Cancel()
        buildFiber = nil
    end
    clearPendingCalls()
    chain = nil
    awaitingReturn = false
    sawMenuScene = false
    hideWidget()
    return hadWork
end

---@return boolean
function shareUrl.isBusy()
    return chain ~= nil or buildFiber ~= nil
end

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
    return string.format("%s#s=%s&i=%d&n=%d&d=%s",
        BASE_URL, chain.session, seq, chain.total, chain.parts[seq])
end

local function sendNext()
    if not chain then
        hideWidget()
        return
    end
    local seq, total = chain.nextSeq, chain.total
    RequestOpenUnsafeURL(partUrl(seq))
    if seq >= total then
        chain = nil
        awaitingReturn = false
        if total == 1 then
            showWidget(GetString(BATTLESCROLLS_SHARE_SINGLE))
        else
            showWidget(zo_strformat(GetString(BATTLESCROLLS_SHARE_DONE), total))
        end
        table.insert(pendingCalls, zo_callLater(hideWidget, WIDGET_AUTOHIDE_MS))
    else
        chain.nextSeq = seq + 1
        awaitingReturn = true
        sawMenuScene = false
        showWidget(zo_strformat(GetString(BATTLESCROLLS_SHARE_STEP_WAIT), seq, total))
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
        nextSeq = 1,
        total = #parts,
    }
    lastStealthState = GetUnitStealthState("player")
    sendNext()
end

-- =============================================================================
-- ADVANCE GESTURES
-- =============================================================================

local function tryAutoAdvance()
    if not (chain and awaitingReturn) then
        return
    end
    awaitingReturn = false
    showWidget(zo_strformat(GetString(BATTLESCROLLS_SHARE_STEP_FIRING), chain.nextSeq, chain.total))
    table.insert(pendingCalls, zo_callLater(sendNext, ADVANCE_DELAY_MS))
end

EVENT_MANAGER:RegisterForEvent("BattleScrollsShare_Focus", EVENT_GAME_FOCUS_CHANGED, function(_, hasFocus)
    if chain and awaitingReturn and hasFocus then
        tryAutoAdvance()
    end
end)

EVENT_MANAGER:RegisterForEvent("BattleScrollsShare_Stealth", EVENT_STEALTH_STATE_CHANGED, function(_, _, stealthState)
    local previous = lastStealthState
    lastStealthState = stealthState
    if chain and awaitingReturn
        and previous == STEALTH_STATE_NONE and stealthState ~= STEALTH_STATE_NONE then
        tryAutoAdvance()
    end
end)
EVENT_MANAGER:AddFilterForEvent("BattleScrollsShare_Stealth", EVENT_STEALTH_STATE_CHANGED,
    REGISTER_FILTER_UNIT_TAG, "player")

SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, _, newState)
    if not (chain and awaitingReturn) or newState ~= SCENE_SHOWN then
        return
    end
    local name = scene:GetName()
    if name == "hud" or name == "hudui" then
        if sawMenuScene then
            sawMenuScene = false
            tryAutoAdvance()
        end
    else
        sawMenuScene = true
    end
end)

-- =============================================================================
-- PUBLIC ENTRY POINTS
-- =============================================================================

---@param buildEffect Effect Effect resolving to ExportResult
local function runShare(buildEffect)
    if shareUrl.isBusy() then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, GetString(BATTLESCROLLS_SHARE_BUSY))
        return
    end
    showWidget(GetString(BATTLESCROLLS_SHARE_PREPARING))
    buildFiber = BattleScrolls.Effect.Async(function()
        local result = buildEffect:Await()
        startChain(result)
    end):Recover(function()
        chain = nil
        showWidget(GetString(BATTLESCROLLS_SHARE_FAILED))
        table.insert(pendingCalls, zo_callLater(hideWidget, WIDGET_AUTOHIDE_MS))
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
