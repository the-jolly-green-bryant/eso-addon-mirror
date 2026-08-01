LibSprint = {}
local LibSprint = LibSprint
 
local addonName = "LibSprint"
LibSprint.name = addonName
local playerUnit = "player"
 
function LibSprint.go() 
    if (not IsPlayerMoving()) or IsUnitSwimming(playerUnit) or IsUnitFalling(playerUnit) or IsUnitDeadOrReincarnating(playerUnit) or LibSprint.isPlayerRollDodging then 
        
        --[[
        if LibSprint.isPlayerSprinting then
             d("not sprinting")
            -- fire event false
        end
        ]]
        LibSprint.isPlayerSprinting = false
        return 
    end
    
    local hotbarCategory = (GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN and HOTBAR_CATEGORY_PRIMARY) or HOTBAR_CATEGORY_BACKUP
 
    for i = 3, 8 do --ACTION_BAR_FIRST_NORMAL_SLOT_INDEX , ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, ACTION_BAR_SLOTS_PER_PAGE  ... ?
        local slotHighlighted = not ActionSlotHasNonCostStateFailure(i, hotbarCategory)
        if slotHighlighted then
            --[[
            if LibSprint.isPlayerSprinting then
             d("not sprinting")
            -- fire event false
           end
           ]]
           LibSprint.isPlayerSprinting = false
           return
        end    
    end 
 
    
    --[[
    if not LibSprint.isPlayerSprinting then
         d("sprinting") 
        -- fire event true
    end
    ]]
    LibSprint.isPlayerSprinting = true
 
end
local LibSprint_go = LibSprint.go
 
 
function LibSprint.onOff(_, result)
    if result == ACTION_RESULT_EFFECT_GAINED then
        LibSprint.isPlayerRollDodging = true
        LibSprint.isPlayerSprinting = false
    elseif result == ACTION_RESULT_EFFECT_FADED then
        LibSprint.isPlayerRollDodging = false
    end
end
local LibSprint_onOff = LibSprint.onOff
 
local function onSprintCheck(_, ...)
   zo_callLater(LibSprint_go, 100)
end 
 
local function OnAddOnLoaded(eventId, otherAddOnName)
    if otherAddOnName ~= addonName then return end
    EVENT_MANAGER:UnregisterForEvent(addonName , EVENT_ADD_ON_LOADED)
 
    EVENT_MANAGER:RegisterForEvent(addonName , EVENT_COMBAT_EVENT, LibSprint_onOff)
    EVENT_MANAGER:AddFilterForEvent(addonName , EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_ABILITY_ID, 28549)
    
    EVENT_MANAGER:RegisterForEvent(addonName , EVENT_ACTION_SLOT_STATE_UPDATED, onSprintCheck)
    EVENT_MANAGER:RegisterForEvent(addonName , EVENT_PLAYER_COMBAT_STATE, onSprintCheck)
 end
 EVENT_MANAGER:RegisterForEvent(addonName , EVENT_ADD_ON_LOADED, OnAddOnLoaded)

