Mephisto               = Mephisto or {}
local MP                      = Mephisto
MP.validation                 = MP.validation or {}
local MPV                     = MP.validation
MP.name                       = "Mephisto"
MP.simpleName                 = "Mephisto"
MP.displayName                =
"|ca5cd84M|caca665E|cae7A49P|ca91922H|cc2704DI|cd8b080S|ce1c895T|ce4d09dO|"

local logger                  = LibDebugLogger( MP.name )
local async                   = LibAsync
local validationTask          = async:Create( MP.name .. "Validation" )
local setupName               = ""
local validationDelay         = 1500
local WORKAROUND_INITIAL_CALL = 0
local WORKAROUND_ONE          = 1
local WORKAROUND_TWO          = 2
local WORKAROUND_THREE        = 3
local WORKAROUND_FOUR         = 4



function MPV.CompareItemLinks( linkEquipped, linkSaved, uniqueIdEquipped, uniqueIdSaved )
    -- if unequipEmpty is enabled then empty slots should be checked.
    -- If not then we cant check empty slots since it will always be the previously equipped item
    if not MP.settings.unequipEmpty then
        --If nothing is saved return true and dont check anything for setups which have empty slots (like prebuffs etc)
        if (linkSaved == "" or linkSaved == nil) or (uniqueIdSaved == 0 or uniqueIdSaved == nil)
        then
            logger:Debug( "CompareItemLinks return check: linkSaved: %s, uniqueIdSaved: %s", linkSaved, uniqueIdSaved )
            return true
        end
    end
    local traitEquipped                = GetItemLinkTraitInfo( linkEquipped )
    local traitSaved                   = GetItemLinkTraitInfo( linkSaved )
    local weaponTypeEquipped           = GetItemLinkWeaponType( linkEquipped )
    local weaponTypeSaved              = GetItemLinkWeaponType( linkSaved )
    local _, _, _, _, _, setIdEquipped = GetItemLinkSetInfo( linkEquipped )
    local _, _, _, _, _, setIdSaved    = GetItemLinkSetInfo( linkSaved )

    if MP.settings.comparisonDepth == 1 then -- easy
        if traitEquipped ~= traitSaved or weaponTypeEquipped ~= weaponTypeSaved or setIdEquipped ~= setIdSaved then
            return false
        end
        return true
    end
    local qualityEquipped = GetItemLinkDisplayQuality( linkEquipped )
    local enchantEquipped = GetItemLinkEnchantInfo( linkEquipped )
    local qualitySaved = GetItemLinkDisplayQuality( linkSaved )
    local enchantSaved = GetItemLinkEnchantInfo( linkSaved )

    if MP.settings.comparisonDepth == 2 then -- detailed
        if (traitEquipped ~= traitSaved) or (weaponTypeEquipped ~= weaponTypeSaved) or (setIdEquipped ~= setIdSaved) or (qualityEquipped ~= qualitySaved) then
            return false
        end
        return true
    end


    if MP.settings.comparisonDepth == 3 then -- thorough
        if (traitEquipped ~= traitSaved) or (weaponTypeEquipped ~= weaponTypeSaved) or (setIdEquipped ~= setIdSaved) or (qualityEquipped ~= qualitySaved) or (enchantEquipped ~= enchantSaved) then
            return false
        end
        return true
    end

    if MP.settings.comparisonDepth == 4 then -- strict
        if uniqueIdEquipped ~= uniqueIdSaved then
            return false
        end
        return true
    end
end

--TODO: untangle this mess. should prob make a metamethod to compare setups instead of this
function MPV.DidSetupSwapCorrectly( workAround )
    local zone        = MP.selection.zone
    local tag         = zone.tag
    local pageId      = MP.selection.pageId
    local index       = MP.currentIndex
    local setupTable  = Setup:FromStorage( tag, pageId, index )
    local check       = nil
    local t           = {}
    local timeStamp   = GetTimeStamp()
    local inCombat    = IsUnitInCombat( "player" )
    local worldName   = GetWorldName()
    local characterId = GetCurrentCharacterId()
    local pageName    = zone.name
    local zoneName    = GetPlayerActiveZoneName()
    local isBlocking  = IsBlockActive()
    local subZone     = GetPlayerActiveSubzoneName()
    local failedT     = {}
    local db          = MP.settings
    local key         = GetWorldName() .. GetDisplayName() .. GetCurrentCharacterId() .. os.date( "%Y%m%d%H" ) .. index
    if not db.failedSwapLog then db.failedSwapLog = {} end
    db = db.failedSwapLog

    if setupTable and setupTable.gear then
        setupName = setupTable.name
        for _, equipSlot in pairs( MP.GEARSLOTS ) do
            if setupTable.gear[ equipSlot ] then
                local equippedLink = GetItemLink( BAG_WORN, equipSlot, LINK_STYLE_DEFAULT )
                local savedLink    = setupTable.gear[ equipSlot ].link
                local equippedUId  = Id64ToString( GetItemUniqueId( BAG_WORN, equipSlot ) )
                local savedUId     = setupTable.gear[ equipSlot ].id
                local success      = nil
                logger:Debug( " equipSlot: %s, %s // %s", GetString( "SI_EQUIPSLOT", equipSlot ), equippedLink, savedLink )
                if MPV.CompareItemLinks( equippedLink, savedLink, equippedUId, savedUId ) then
                    success = true
                else
                    success = false
                    failedT[ # failedT + 1 ] = GetString( "SI_EQUIPSLOT", equipSlot )
                    logger:Info( "Equipped %s // saved %s", equippedLink, savedLink )
                    if workAround > 0 then
                        if not db[ equipSlot ] then db[ equipSlot ] = {} end
                        --No need to log for each workaround, just log the last
                        EVENT_MANAGER:RegisterForUpdate( MP.name .. "Throttle" .. equipSlot, 5000, function()
                            if not db[ equipSlot ][ key ] then db[ equipSlot ][ key ] = {} end
                            db[ equipSlot ][ key ] = {
                                timeStamp    = timeStamp,
                                inCombat     = inCombat,
                                worldName    = worldName,
                                characterId  = characterId,
                                pageName     = pageName,
                                zone         = zoneName,
                                subzone      = subZone,
                                pageId       = pageId,
                                setupName    = setupName,
                                equippedLink = equippedLink,
                                savedLink    = savedLink,
                                settings     = {
                                    gear   = MP.settings.auto.gear,
                                    skills = MP.settings.auto.skills,
                                    cp     = MP.settings.auto.cp,
                                    food   = MP.settings.auto.food,
                                },
                                workAround   = workAround,
                                isBlocking   = isBlocking

                            }
                            EVENT_MANAGER:UnregisterForUpdate( MP.name .. "Throttle" .. equipSlot )
                        end )
                    end
                end
                t[ equipSlot ] = success
            end

            for eqSlot, success in pairs( t ) do
                if not success then
                    check = false
                    break
                else
                    check = true
                end
            end
        end
    end
    return check, failedT
end

local function failureFunction()
    validationTask:Cancel()
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "Throttle" )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "Throttle2" )
    EVENT_MANAGER:UnregisterForEvent( MP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "ThrottleWorkaroundOne" )
    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "ThrottleWorkaroundTwo" )
    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "ThrottleWorkaroundThree" )
    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundFour", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "ThrottleWorkaroundTFour" )
    MP.Log( GetString( MP_MSG_SWAP_FIX_FAIL ), MP.LOGTYPES.ERROR )
end
local function successFunction()
    -- Cancel everything in case swap worked out sooner than expected to avoid having situations where some function gets called endlessly
    validationTask:Cancel()
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "Throttle" )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "Throttle2" )
    EVENT_MANAGER:UnregisterForEvent( MP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "ThrottleWorkaroundOne" )
    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "ThrottleWorkaroundTwo" )
    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "ThrottleWorkaroundThree" )
    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundFour", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "ThrottleWorkaroundTFour" )
    MP.Log( GetString( MP_MSG_SWAPSUCCESS ), MP.LOGTYPES.NORMAL )
    local middleText = string.format( "|c%s%s|r", MP.LOGTYPES.NORMAL, setupName )
    MephistoPanelBottomLabel:SetText( middleText )
end


--[[ Last ditch effort, I have in all my testing never seen that anything other than weapons got stuck.
 So this should never happen, we still have it in case something odd is happening ]]

local function workaroundFour()
    logger:Info( "workaround four got called" )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "ThrottleWorkaroundThree" )
    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )

    -- Redundancy in case everything is stuck and no event triggers. This will hopefully always be unregistered before it actually gets called
    EVENT_MANAGER:RegisterForUpdate( MP.name .. "Throttle2", 5000,
                                     function()
                                         failureFunction() -- If all swaps have failed.
                                     end )

    if not MPV.DidSetupSwapCorrectly( WORKAROUND_FOUR ) then
        validationTask:Call( function()
            MP.Undress()
        end ):WaitUntil( function() -- Wait until every worn item is in the bag
            local isNotEmpty = nil
            for _, equipSlot in pairs( MP.GEARSLOTS ) do
                if Id64ToString( GetItemUniqueId( BAG_WORN, equipSlot ) ) ~= "0" then
                    isNotEmpty = true
                elseif Id64ToString( GetItemUniqueId( BAG_WORN, equipSlot ) ) == "0" and not isNotEmpty then
                    isNotEmpty = false
                end
            end
            return not isNotEmpty
        end ):Then( function()
            MP.LoadSetupAdjacent( 0 ) -- reload current setup
        end ):Call( function()
            EVENT_MANAGER:RegisterForEvent( MP.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
                EVENT_MANAGER:RegisterForUpdate( MP.name .. "Throttle", validationDelay / 2, function()
                    if MPV.DidSetupSwapCorrectly( WORKAROUND_FOUR ) then
                        successFunction()
                    else
                        failureFunction()
                    end
                    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
                    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "Throttle" )
                end )
            end )
        end )
    else
        successFunction()
    end
end

-- Unequip weapons and reload setup
local function workaroundThree()
    logger:Info( "workaround three got called" )
    local t = {
        EQUIP_SLOT_MAIN_HAND,
        EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_BACKUP_MAIN,
        EQUIP_SLOT_BACKUP_OFF
    }


    Setup:GetData()
    local moveTask = async:Create( MP.name .. "Move" )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "ThrottleWorkaroundTwo" )
    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    EVENT_MANAGER:RegisterForEvent( MP.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                    function()
                                        moveTask:Resume() -- continue loop
                                        EVENT_MANAGER:RegisterForUpdate( MP.name .. "ThrottleWorkaroundThree",
                                                                         validationDelay / 2,
                                                                         function()
                                                                             workaroundFour()
                                                                         end )
                                    end )
    EVENT_MANAGER:AddFilterForEvent( MP.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_BAG_ID,
                                     BAG_WORN )

    EVENT_MANAGER:AddFilterForEvent( MP.name .. "workaroundThree", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_INVENTORY_UPDATE_REASON,
                                     INVENTORY_UPDATE_REASON_DEFAULT )



    moveTask:Call( function()
        if not MPV.DidSetupSwapCorrectly( WORKAROUND_THREE ) then
            moveTask:For( 1, #t ):Do( function( index )
                local emptySlot = FindFirstEmptySlotInBag( BAG_BACKPACK )
                local equipSlot = t[ index ]
                local weaponType = GetItemWeaponType( BAG_WORN, equipSlot )
                local link = GetItemLink( BAG_WORN, equipSlot, LINK_STYLE_DEFAULT )

                if weaponType ~= WEAPONTYPE_NONE then
                    CallSecureProtected( "RequestMoveItem", BAG_WORN, equipSlot, BAG_BACKPACK, emptySlot, 1 )
                    moveTask:Suspend() -- Suspend loop until item has actually moved
                end
            end ):Then( function() MP.LoadSetupAdjacent( 0 ) end )
        else
            successFunction()
        end
    end )
    EVENT_MANAGER:RegisterForUpdate( MP.name .. "ThrottleWorkaroundThree", validationDelay, workaroundFour ) -- If no item moved, move on to workaround four
end

-- Reload setup
local function workaroundTwo()
    logger:Info( "workaroundTwo got called" )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "ThrottleWorkaroundOne" )
    EVENT_MANAGER:UnregisterForEvent( MP.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    validationTask:Call( function()
        EVENT_MANAGER:RegisterForEvent( MP.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
            if MPV.DidSetupSwapCorrectly( WORKAROUND_TWO ) then
                successFunction()
            else
                EVENT_MANAGER:RegisterForUpdate( MP.name .. "ThrottleWorkaroundTwo", validationDelay / 2, workaroundThree )
            end
        end )
        EVENT_MANAGER:AddFilterForEvent( MP.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                         REGISTER_FILTER_BAG_ID,
                                         BAG_WORN )

        EVENT_MANAGER:AddFilterForEvent( MP.name .. "workaroundTwo", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                         REGISTER_FILTER_INVENTORY_UPDATE_REASON,
                                         INVENTORY_UPDATE_REASON_DEFAULT )
        if not MPV.DidSetupSwapCorrectly( WORKAROUND_TWO ) then
            MP.LoadSetupAdjacent( 0 )
        else
            successFunction()
        end
        EVENT_MANAGER:RegisterForUpdate( MP.name .. "ThrottleWorkaroundTwo", validationDelay, workaroundThree ) -- wait for the gear swap event, if it doesnt happen then try workaround three
    end )
end

-- Sheathe weapons and see if it fixes itself
local function workaroundOne()
    validationDelay = MP.settings.validationDelay
    logger:Info( "workaround one got called" )
    EVENT_MANAGER:RegisterForEvent( MP.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
        if MPV.DidSetupSwapCorrectly( WORKAROUND_ONE ) then
            successFunction()
        else
            EVENT_MANAGER:RegisterForUpdate( MP.name .. "ThrottleWorkaroundOne", validationDelay / 2, workaroundTwo ) -- throttle to call workaround after the last event
        end
    end )
    EVENT_MANAGER:AddFilterForEvent( MP.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_BAG_ID, BAG_WORN )

    EVENT_MANAGER:AddFilterForEvent( MP.name .. "workaroundOne", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_INVENTORY_UPDATE_REASON,
                                     INVENTORY_UPDATE_REASON_DEFAULT )
    validationTask:Call( function()
        if not MPV.DidSetupSwapCorrectly( WORKAROUND_ONE ) then
            if not ArePlayerWeaponsSheathed() then
                TogglePlayerWield()
            end
            EVENT_MANAGER:RegisterForUpdate( MP.name .. "ThrottleWorkaroundOne", validationDelay, workaroundTwo ) -- we wait for the gear swap event, if it does not happen we try workaround two
        else
            successFunction()
        end
    end )
end
-- Make function accessible via keybind
MPV.WorkAroundOne = workaroundOne

local function handleSettings()
    logger:Info( "handle settings has been called" )

    EVENT_MANAGER:UnregisterForUpdate( MP.name .. "Throttle" )
    EVENT_MANAGER:UnregisterForEvent( MP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE )

    validationTask:Call( function()
        local success, failedT = MPV.DidSetupSwapCorrectly( WORKAROUND_INITIAL_CALL )

        local failedSlotNames = table.concat( failedT, ", " )
        if success then
            successFunction()
        else
            -- Warn user regardless of the setting
            local middleText = string.format( "|c%s%s|r", MP.LOGTYPES.ERROR, setupName )
            MephistoPanelBottomLabel:SetText( middleText )
            if MP.settings.fixGearSwap then
                MP.Log( GetString( MP_MSG_SWAPFAIL ), MP.LOGTYPES.ERROR, "FFFFFF", failedSlotNames )
                if IsUnitInCombat( "player" ) then
                    validationTask:WaitUntil( function() return not IsUnitInCombat( "player" ) end ):Then( workaroundOne )
                else
                    validationTask:Call( workaroundOne )
                end
            else
                MP.Log( GetString( MP_MSG_SWAPFAIL_DISABLED ), MP.LOGTYPES.ERROR, "FFFFFF", failedSlotNames )
            end
        end
    end )
end
-- Function gets called once on setup swap
function MPV.SetupFailWorkaround()
    validationDelay = MP.settings.validationDelay
    local function throttle()
        -- throttle continously while swapping takes place until its done, so we don't have to call the workaround for every piece of gear we swap
        EVENT_MANAGER:RegisterForUpdate( MP.name .. "Throttle", validationDelay, handleSettings )
    end

    EVENT_MANAGER:RegisterForEvent( MP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, throttle )
    EVENT_MANAGER:AddFilterForEvent( MP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_BAG_ID, BAG_WORN )

    EVENT_MANAGER:AddFilterForEvent( MP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                                     REGISTER_FILTER_INVENTORY_UPDATE_REASON,
                                     INVENTORY_UPDATE_REASON_DEFAULT )
end

-- Suspend all tasks when in combat and resume once we are out
local function combatFunction( _, inCombat )
    if inCombat then
        validationTask:Suspend()
    else
        validationTask:Resume()
    end
end


EVENT_MANAGER:RegisterForEvent( MP.name, EVENT_PLAYER_COMBAT_STATE, function( _, inCombat ) combatFunction( _, inCombat ) end )
