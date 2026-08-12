--[[
    BlockPooky Block Detection Module
    
    This module provides "Am I Blocking?" awareness by detecting when the player
    is actively blocking and showing a visual indicator.
    
    Detection Logic:
    - Uses IsBlockActive() to check block state
    - Validates stamina/magicka regeneration is 0 (blocking drains resources)
    - Excludes running while holding block (not true blocking)
    - Shows/hides indicator based on actual blocking state
    
    Features:
    - Real-time block state monitoring via update loop
    - Movable UI indicator with position persistence
    - Callback system for other modules to react to blocking state changes
--]]

--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky

--[[ blocking detection implementation ------------------------------------------------------------------------------]]

-- Previous blocking state for change detection
local BlockPooky_old_is_block_active = false

---Updates the blocking detection state and UI indicator
---This function is called every 100ms to monitor blocking state in real-time
---@param gameTimeMs number current game time in milliseconds
function BlockPooky.UpdateBlocking(gameTimeMs)
    local is_block_active = false
    -- Check if player is running (shift + movement) - this isn't true blocking
    local isRunning = IsShiftKeyDown() and IsPlayerMoving()
    local inCombat = IsUnitInCombat("player")
    local stamReg = 0
    local magReg = 0
    
    -- Get appropriate regeneration stats based on combat state
    if inCombat then
        stamReg = GetPlayerStat(STAT_STAMINA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS)
        magReg = GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS)
    else
        stamReg = GetPlayerStat(STAT_STAMINA_REGEN_IDLE, STAT_BONUS_OPTION_APPLY_BONUS)
        magReg = GetPlayerStat(STAT_MAGICKA_REGEN_IDLE, STAT_BONUS_OPTION_APPLY_BONUS)
    end
    
    -- True blocking: block active, not running, and resource regen is 0
    if IsBlockActive() and not isRunning and (stamReg == 0 or magReg == 0) then
        is_block_active = true
    end
    BlockingPookyIndicator:SetHidden(not (BlockPooky.config.lockedUI or is_block_active))
    if BlockPooky_old_is_block_active ~= is_block_active then
        BlockPooky.CallbackManager:FireCallbacks(BlockPooky.name .. "BLOCKING_STATE_CHANGE", is_block_active)
        BlockPooky_old_is_block_active = is_block_active
    end
    if not BlockPooky.config.lockedUI and is_block_active then
        BlockPooky.StopBlockPooky(gameTimeMs)
    end
end

function BlockPooky.SetUseBlocking()
    if BlockPooky.config.blocking.show then
        if not BlockPooky.blockingregistered then
            EVENT_MANAGER:RegisterForUpdate(BlockPooky.name.."BlockingTickUpdate", 100, function(gameTimeMs)
                BlockPooky.UpdateBlocking(gameTimeMs)
            end)
        end
        BlockPooky.config.blocking.registered = true
    else
        if BlockPooky.config.blocking.registered then
            EVENT_MANAGER:UnregisterForUpdate(BlockPooky.name.."BlockingTickUpdate")
            BlockPooky.blockingregistered = false
        end
    end
end

function BlockPooky.OnBlockingIndicatorMoveStop()
    BlockPooky.config.blocking.left = BlockingPookyIndicator:GetLeft()
    BlockPooky.config.blocking.top = BlockingPookyIndicator:GetTop()
end
