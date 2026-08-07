-- EsoCombatLock - post-combat companion auto-resummon

local ECL = EsoCombatLock
ECL.Recovery = ECL.Recovery or {}
local Recovery = ECL.Recovery

local UPDATE_NAME = ECL.NAME .. "_Recovery"
local RETRY_MS = 500
local MAX_ATTEMPTS = 20 -- ~10 seconds

local pendingCollectibleId = nil
local attempts = 0
local running = false

local function stop()
    if running then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        running = false
    end
    pendingCollectibleId = nil
    attempts = 0
end

local function tryResummon()
    attempts = attempts + 1

    if not pendingCollectibleId then
        stop()
        return
    end

    -- Already back out — done.
    if HasActiveCompanion and HasActiveCompanion() then
        ECL.Debug("Recovery: companion already active")
        stop()
        return
    end

    -- Still in combat somehow — wait.
    if IsUnitInCombat and IsUnitInCombat("player") then
        ECL.Debug("Recovery: still in combat, waiting")
        if attempts >= MAX_ATTEMPTS then
            ECL.Chat("Could not resummon companion (still in combat)")
            stop()
        end
        return
    end

    local reason = GetCollectibleBlockReason(pendingCollectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    if reason ~= COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
        ECL.Debug(string.format("Recovery: blocked reason=%s attempt=%d", tostring(reason), attempts))
        if attempts >= MAX_ATTEMPTS then
            ECL.Chat("Could not resummon companion (blocked/cooldown)")
            stop()
        end
        return
    end

    UseCollectible(pendingCollectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    ECL.Debug("Recovery: UseCollectible(" .. tostring(pendingCollectibleId) .. ")")

    -- Give the game a moment, then confirm.
    zo_callLater(function()
        if HasActiveCompanion and HasActiveCompanion() then
            local name = GetCollectibleName and GetCollectibleName(pendingCollectibleId) or "companion"
            ECL.Chat("Resummoned " .. tostring(name))
            stop()
        elseif attempts >= MAX_ATTEMPTS then
            ECL.Chat("Companion resummon failed after retries")
            stop()
        end
    end, 250)
end

function Recovery.Start(collectibleId)
    if not ECL.IsResummonEnabled() then
        return
    end
    if not collectibleId or collectibleId == 0 then
        return
    end

    stop()
    pendingCollectibleId = collectibleId
    attempts = 0
    running = true
    ECL.Debug("Recovery started for collectible " .. tostring(collectibleId))
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, RETRY_MS, tryResummon)
end
