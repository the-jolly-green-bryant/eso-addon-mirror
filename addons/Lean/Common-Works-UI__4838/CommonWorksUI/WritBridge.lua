-- Common Works -- master writ turn-in bridge
--
-- Opens crafted master writs from the backpack; WritWorthy identifies them and
-- DolgubonsLazyWritCreator handles Rolis Hlaalu. Both add-ons are required.
--
-- ESO has no Lua call to start world interaction. Accept one quest per crafting type
-- (~7 per batch), then wait for the player's interact keypress.
--
-- A manual turn-in arms the run: IDLE / ACCEPTING (chained on EVENT_QUEST_ADDED) /
-- WAITING_NPC. Each turn-in starts another batch until the backpack is empty.
-- Close only Rolis's merchant window, after EVENT_OPEN_STORE, never his conversation.
-- Moving, Esc or a stalled step (WATCHDOG) stops the run.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local EM = EVENT_MANAGER

-- NS_ARM stays registered while enabled to maintain the journal snapshot between runs.
-- The two updaters are per-run.
local NS_ARM  = CW.name .. "WritBridgeArm"
local NS_MOVE = CW.name .. "WritBridgeMotion"
local NS_DOG  = CW.name .. "WritBridgeWatchdog"
-- Separate close poller: it outlives a step and has its own deadline.
local NS_CLOSE = CW.name .. "WritBridgeClose"

local STATE_IDLE        = "IDLE"
local STATE_ACCEPTING   = "ACCEPTING"
local STATE_WAITING_NPC = "WAITING_NPC"

-- Server pacing; the quest is already in the journal when EVENT_QUEST_ADDED fires.
local STEP_DELAY_MS = 350

-- Dolgubon can veto AcceptOfferedQuest; missing events can also stall ACCEPTING.
local WATCHDOG_MS = 4000

-- Banked writs cannot be opened.
local BAG = BAG_BACKPACK

local state = STATE_IDLE
-- Scheduled callbacks capture this generation; a mismatch cancels them.
local token = 0
local armed = false
local batchCount = 0
local motionX, motionY = 0, 0

-- Check entry points for partially loaded hosts; each failure has a named reason.
-- WritWorthyInventoryList is intentionally unused (see CraftingTypeOf).
local function AvailabilityFaults()
    local faults = {}
    if type(WritWorthy) ~= "table" then
        faults[#faults + 1] = "WritWorthy missing"
    else
        if type(WritWorthy.savedChariables) ~= "table" then
            faults[#faults + 1] = "WritWorthy.savedChariables missing"
        elseif type(WritWorthy.savedChariables.writ_unique_id) ~= "table" then
            faults[#faults + 1] = "WritWorthy.savedChariables.writ_unique_id missing"
        end
        if type(WritWorthy.UniqueID) ~= "function" then
            faults[#faults + 1] = "WritWorthy.UniqueID missing"
        end
    end
    if type(WritCreater) ~= "table" then
        faults[#faults + 1] = "WritCreater missing"
    else
        if type(WritCreater.GetSettings) ~= "function" then
            faults[#faults + 1] = "WritCreater:GetSettings missing"
        end
        if type(WritCreater.sealedWritNames) ~= "table" then
            faults[#faults + 1] = "WritCreater.sealedWritNames missing"
        end
    end
    return faults
end

function CW.WritBridgeAvailable()
    return #AvailabilityFaults() == 0
end

local function Say(key, prefix)
    d(CW.BRAND .. ": " .. (prefix or "") .. CW.L[key])
end

-- Dolgubon's accessor follows account/character profile changes; false until loaded.
local function DolgubonSettings()
    local settings = WritCreater:GetSettings()
    return type(settings) == "table" and settings or nil
end

-- Reading the world

-- Master writ details exist only on step 1 / condition 1, as Lazy Writ Crafter reads them.
-- A nil first return means no master writ.
local function MasterWritCraftingType(questIndex)
    local itemId, _, craftingType = GetQuestConditionMasterWritInfo(questIndex, 1, 1)
    if itemId == nil then return nil end
    if craftingType == 0 then return nil end
    return craftingType
end

-- Snapshot journal index -> master writ crafting type; removed quests cannot be inspected.
local writQuestIndex = {}

local function RefreshWritQuests()
    writQuestIndex = {}
    for questIndex in CW.JournalQuests() do
        local craftingType = MasterWritCraftingType(questIndex)
        if craftingType then writQuestIndex[questIndex] = craftingType end
    end
end

-- Rebuild each iteration so the just-accepted writ blocks its type.
local function OccupiedCraftingTypes()
    local occupied = {}
    for questIndex in CW.JournalQuests() do
        local craftingType = MasterWritCraftingType(questIndex)
        if craftingType then occupied[craftingType] = true end
    end
    return occupied
end

-- WritWorthy's own uid derivation, and the key both addons' stores use.
local function SlotUniqueId(slot)
    local uid = WritWorthy.UniqueID(BAG, slot)
    if uid then return uid end
    local itemId = GetItemUniqueId(BAG, slot)
    return itemId and Id64ToString(itemId)
end

-- Accept either store's crafted flag, as Dolgubon's inventory icon does:
-- WritWorthy is per-character; Dolgubon is account-wide.
local function IsCrafted(uniqueId)
    if not uniqueId then return false end
    local ww = WritWorthy.savedChariables.writ_unique_id[uniqueId]
    if ww and ww.state == "completed" then return true end
    local dlwc = WritCreater.savedVarsAccountWide
    if dlwc and dlwc.craftedMasterWrits and dlwc.craftedMasterWrits[uniqueId] then return true end
    return false
end

-- Dolgubon's table also lists the event writs (Witches, New Life, Deepwinter,
-- Imperial), which are handed in elsewhere.
local TURN_IN_CRAFTING_TYPES = {
    [CRAFTING_TYPE_BLACKSMITHING] = true, [CRAFTING_TYPE_CLOTHIER] = true,
    [CRAFTING_TYPE_WOODWORKING] = true, [CRAFTING_TYPE_JEWELRYCRAFTING] = true,
    [CRAFTING_TYPE_ALCHEMY] = true, [CRAFTING_TYPE_ENCHANTING] = true,
    [CRAFTING_TYPE_PROVISIONING] = true,
}

-- nil means this bridge does not turn in the writ.
-- Dolgubon's sealedWritNames maps GetItemLinkName to the CRAFTING_TYPE_* returned by
-- GetQuestConditionMasterWritInfo, in every client language.
-- WritWorthyInventoryList's uid map refreshes only at load and when its window opens,
-- so it misses writs crafted or looted since then.
local function CraftingTypeOf(slot)
    local link = GetItemLink(BAG, slot, LINK_STYLE_DEFAULT)
    if link == "" then return nil end
    local craftingType = WritCreater.sealedWritNames[GetItemLinkName(link)]
    return TURN_IN_CRAFTING_TYPES[craftingType] and craftingType or nil
end

-- nil means the batch is full or the backpack is out; the caller treats both alike.
function CW.FindNextReadyWrit()
    if not CW.WritBridgeAvailable() then return nil end
    local occupied = OccupiedCraftingTypes()
    for slot = 0, GetBagSize(BAG) do
        local craftingType = CraftingTypeOf(slot)
        if craftingType and not occupied[craftingType] then
            if IsCrafted(SlotUniqueId(slot)) then
                return slot, craftingType, SlotUniqueId(slot)
            end
        end
    end
    return nil
end

-- Run control

local Stop, StartBatch, AcceptNext

-- Bumping the token first is what makes this safe to call from a scheduled callback.
Stop = function(messageKey)
    token = token + 1
    state = STATE_IDLE
    armed = false
    batchCount = 0
    EM:UnregisterForUpdate(NS_MOVE)
    EM:UnregisterForUpdate(NS_DOG)
    -- Unregister now instead of leaving the 50ms poll to notice the token change.
    EM:UnregisterForUpdate(NS_CLOSE)
    if messageKey then Say(messageKey) end
end

local function ArmWatchdog()
    local myToken = token
    EM:UnregisterForUpdate(NS_DOG)
    EM:RegisterForUpdate(NS_DOG, WATCHDOG_MS, function()
        if myToken ~= token then return end
        -- Only ACCEPTING is watched: WAITING_NPC waits on the player, with no deadline.
        if state == STATE_ACCEPTING then
            Stop("WRITBRIDGE_ABORTED")
        end
    end)
end

-- Polled because ESO has no "player moved" event: a 100ms position delta.
local function StartMotionWatch()
    motionX, motionY = GetMapPlayerPosition("player")
    local myToken = token
    EM:UnregisterForUpdate(NS_MOVE)
    EM:RegisterForUpdate(NS_MOVE, 100, function()
        if myToken ~= token then return end
        local x, y = GetMapPlayerPosition("player")
        if x ~= motionX or y ~= motionY then
            Stop("WRITBRIDGE_ABORTED")
        end
    end)
end

-- Returns false and a reason for the caller to report.
local function CanRun()
    if not CW.SavedVars.autoWritTurnIn then
        return false, "setting off"
    end
    local faults = AvailabilityFaults()
    if #faults > 0 then return false, table.concat(faults, ", ") end

    local settings = DolgubonSettings()
    if not settings then return false, "Lazy Writ Crafter settings unavailable" end
    -- Dolgubon's autoAccept gates both quest acceptance and turn-in.
    if settings.autoAccept ~= true then
        Say("WRITBRIDGE_NEED_AUTOACCEPT")
        return false, "Lazy Writ Crafter autoAccept is off"
    end
    if settings.preventMasterWritAccept then
        return false, "Lazy Writ Crafter preventMasterWritAccept is on"
    end

    if IsUnitInCombat("player") then return false, "in combat" end
    if IsUnitDead("player") then return false, "dead" end
    return true
end

-- Report the first failure once per run to avoid chat spam.
local spoke = false
local function Bail(reason)
    if spoke then return end
    spoke = true
    d(CW.BRAND .. ": writ bridge stopped - " .. tostring(reason))
end

-- Report a waiting state without calling the run stopped.
local notified = false
local function Notify(text)
    if notified then return end
    notified = true
    d(CW.BRAND .. ": writ bridge - " .. tostring(text))
end

-- The accept loop

AcceptNext = function(myToken)
    if myToken ~= token or state ~= STATE_ACCEPTING then return end

    local slot, craftingType = CW.FindNextReadyWrit()
    if not slot then
        -- Batch full; wait for the player's interact keypress.
        if batchCount > 0 then
            state = STATE_WAITING_NPC
            EM:UnregisterForUpdate(NS_DOG)
            EM:UnregisterForUpdate(NS_MOVE)
            Say("WRITBRIDGE_TALK_TO_ROLIS", tostring(batchCount) .. " ")
        else
            Stop("WRITBRIDGE_DONE")
        end
        return
    end

    ArmWatchdog()
    -- CallSecureProtected permits UseItem without a hardware event;
    -- Dolgubon opens reward containers this way from a timer.
    CallSecureProtected("UseItem", BAG, slot)
end

-- Sealed writs offer quests without EVENT_CHATTER_BEGIN.
local function OnQuestOffered()
    if state ~= STATE_ACCEPTING then return end
    local myToken = token
    zo_callLater(function()
        if myToken ~= token or state ~= STATE_ACCEPTING then return end
        -- Dolgubon pre-hooks AcceptOfferedQuest and may refuse; then EVENT_QUEST_ADDED
        -- never arrives and the watchdog ends the run.
        AcceptOfferedQuest()
        ResetChatter()
    end, STEP_DELAY_MS)
end

local function OnQuestAdded(_, questIndex)
    -- Snapshot every added quest before removal, even if accepted outside this module.
    local craftingType = MasterWritCraftingType(questIndex)
    if craftingType then writQuestIndex[questIndex] = craftingType end
    if state ~= STATE_ACCEPTING then return end
    batchCount = batchCount + 1
    local myToken = token
    zo_callLater(function() AcceptNext(myToken) end, STEP_DELAY_MS)
end

-- Rolis's store opens after the turn-in conversation ends; only then may it be closed.
-- Ending the conversation itself cuts turn-ins short.
-- A completed master writ still in the journal means Dolgubon has another to hand in.
local function PendingWritTurnIns()
    local pending = 0
    for questIndex in pairs(writQuestIndex) do
        if GetJournalQuestIsComplete(questIndex) then pending = pending + 1 end
    end
    return pending
end

-- Backstop for a completable writ Dolgubon will not hand in: one for a different NPC,
-- or autoAccept switched off mid-run.
local STALL_MS = 5000
local lastWritRemoval = 0
-- Short, because it is only a backstop: EVENT_QUEST_REMOVED normally gets here first.
local POLL_MS = 250
-- Close immediately; the 350ms delay paces writ opening only.
local CLOSE_DELAY_MS = 50

-- EVENT_OPEN_STORE is the earliest reliable signal that the store exists.
local storeOpen = false

-- AGS polls at 50ms for the same job.
local CLOSE_TICK_MS = 50
-- Interaction type can be empty for a few frames between conversation and store.
-- Wait out that gap before opening more writs.
local SETTLE_MS = 600

local function Now()
    return GetGameTimeMilliseconds()
end

local closing = false

local function StopClosing()
    closing = false
    EM:UnregisterForUpdate(NS_CLOSE)
end

-- Every batch waits out the post-conversation gap, even with nothing open.
-- EndInteraction needs EVENT_OPEN_STORE and INTERACTION_VENDOR (storewindow_shared.lua:14-18);
-- transient types can match no INTERACTION_* constant and strand the backpack in merchant mode
-- (AwesomeGuildStore util/InteractionHelper.lua:66-72).
-- The close deadline pauses during turn-in conversation; call onClosed once settled.
local function CloseWhenSafe(onClosed)
    if closing then return end

    -- A setting because it guesses at Lazy Writ Crafter's timing; ZO_SavedVars fills the default.
    local timeout = CW.SavedVars.writCloseTimeoutMs
    if timeout <= 0 then
        Notify("close the window to continue")
        return
    end

    closing = true
    local myToken = token
    local deadline = Now() + timeout
    -- AGS's hasWaited debounce (InteractionHelper.lua:154-164): the type can read
    -- correct a tick before the window settles, so require it twice running.
    local seenStore = false
    local ended = false
    local emptySince = nil

    EM:UnregisterForUpdate(NS_CLOSE)
    EM:RegisterForUpdate(NS_CLOSE, CLOSE_TICK_MS, function()
        if myToken ~= token then StopClosing() return end

        local interaction = GetInteractionType()

        if interaction == INTERACTION_NONE then
            emptySince = emptySince or Now()
            -- No settle needed once we closed it ourselves.
            if ended or (Now() - emptySince) >= SETTLE_MS then
                StopClosing()
                onClosed()
            end
            return
        end
        emptySince = nil

        if not ended then
            if interaction == INTERACTION_CONVERSATION then
                -- Pause the deadline while the turn-in conversation is open.
                seenStore = false
                deadline = Now() + timeout
                return
            end

            if storeOpen and interaction == INTERACTION_VENDOR then
                if seenStore then
                    ended = true
                    EndInteraction(INTERACTION_VENDOR)
                    return
                end
                seenStore = true
                return
            end
            seenStore = false
        end

        if Now() >= deadline then
            StopClosing()
            -- Run still live; the next CHATTER_END or CLOSE_STORE retries.
            Notify("close the window to continue")
        end
    end)
end

-- After turn-in, the first CHATTER_END, OPEN_STORE or CLOSE_STORE wins;
-- INTERACTION_CONVERSATION may already be gone.
local pendingStart = false

local function RequestBatch()
    if pendingStart then return end
    -- Multiple triggers must not start parallel AcceptNext chains.
    if state == STATE_ACCEPTING then
        return
    end
    if state ~= STATE_WAITING_NPC and not armed then
        return
    end
    pendingStart = true
    local myToken = token
    zo_callLater(function()
        pendingStart = false
        if myToken ~= token then return end
        if state == STATE_ACCEPTING then return end
        if state ~= STATE_WAITING_NPC and not armed then return end

        -- Completed writs remain, but arriving removals mean turn-ins are progressing.
        local pending = PendingWritTurnIns()
        if pending > 0 and (Now() - lastWritRemoval) < STALL_MS then
            zo_callLater(RequestBatch, POLL_MS)
            return
        end
        CloseWhenSafe(function()
            if myToken ~= token then return end
            if state == STATE_ACCEPTING then return end
            if state ~= STATE_WAITING_NPC and not armed then return end
            StartBatch()
        end)
    end, CLOSE_DELAY_MS)
end

-- Rolis's store opens only after the conversation ends. Every close waits for this flag.
local function OnOpenStore()
    storeOpen = true
    RequestBatch()
end

local function OnCloseStore()
    storeOpen = false
    RequestBatch()
end

StartBatch = function()
    local ok, reason = CanRun()
    if not ok then
        Bail(reason)
        Stop()
        return
    end
    -- A run that gets going earns a fresh right to speak.
    spoke = false
    notified = false
    armed = false
    batchCount = 0
    state = STATE_ACCEPTING
    StartMotionWatch()
    AcceptNext(token)
end

-- Arming
--
-- A manual turn-in arms the run. Two triggers cover the race with Dolgubon.
local function Arm()
    if state ~= STATE_IDLE then return end
    if armed then return end
    -- Report failure immediately after the manual turn-in that should start the chain.
    spoke = false
    local ok, reason = CanRun()
    if not ok then
        Bail(reason)
        return
    end
    armed = true
end

-- A completed master writ's removal signals turn-in; its type survives in the snapshot.
-- EVENT_QUEST_COMPLETE_DIALOG races Dolgubon's CompleteQuest() by registration order.
local function OnQuestRemoved(_, isCompleted, questIndex)
    local craftingType = writQuestIndex[questIndex]
    writQuestIndex[questIndex] = nil
    if not (isCompleted and craftingType) then return end

    -- Timestamped, so the batch continuation can tell "still working" from "finished".
    lastWritRemoval = GetGameTimeMilliseconds()

    if state == STATE_WAITING_NPC or armed then
        -- Dolgubon leaves the window open, so no interaction-end event drives the next batch.
        RequestBatch()
    else
        Arm()
        -- The arming turn-in may be this conversation's last event.
        if armed then RequestBatch() end
    end
end

-- Arms before removal if the quest is still readable; removal covers the race otherwise.
local function OnQuestCompleteDialog(_, questIndex)
    local craftingType = MasterWritCraftingType(questIndex)
    if craftingType then
        writQuestIndex[questIndex] = craftingType
        Arm()
    end
end

-- CW.inGameplay would abort every batch: Rolis's conversation also hides HUD_SCENE.
local function OnGameMenuStateChange(_, newState)
    if (newState == SCENE_SHOWING or newState == SCENE_SHOWN)
        and (state ~= STATE_IDLE or armed) then
        Stop("WRITBRIDGE_ABORTED")
    end
end

-- Registered while enabled, keeping the journal snapshot current between runs.
local BRIDGE_EVENTS = {
    [EVENT_QUEST_COMPLETE_DIALOG] = OnQuestCompleteDialog,
    [EVENT_QUEST_REMOVED]         = OnQuestRemoved,
    [EVENT_QUEST_ADDED]           = OnQuestAdded,
    [EVENT_QUEST_OFFERED]         = OnQuestOffered,
    [EVENT_QUEST_LIST_UPDATED]    = RefreshWritQuests,
    -- Snapshot before Dolgubon starts removing completed quests.
    [EVENT_CHATTER_BEGIN]         = RefreshWritQuests,
    [EVENT_CHATTER_END]           = RequestBatch,
    [EVENT_OPEN_STORE]            = OnOpenStore,
    [EVENT_CLOSE_STORE]           = OnCloseStore,
}

-- Called from the setting and from OnPlayerActivated, since the other addons' tables
-- may be empty at load.
function CW.UpdateWritBridge()
    for event in pairs(BRIDGE_EVENTS) do EM:UnregisterForEvent(NS_ARM, event) end
    GAME_MENU_SCENE:UnregisterCallback("StateChange", OnGameMenuStateChange)

    local enabled = CW.SavedVars.autoWritTurnIn
    if not (enabled and CW.WritBridgeAvailable()) then
        Stop()
        return
    end

    for event, handler in pairs(BRIDGE_EVENTS) do EM:RegisterForEvent(NS_ARM, event, handler) end
    GAME_MENU_SCENE:RegisterCallback("StateChange", OnGameMenuStateChange)
    RefreshWritQuests()
end
