local KD = KyzderpsDerps
local Spud = KD.AntiSpud

---------------------------------------------------------------------
---------------------------------------------------------------------
local shouldCheckOnNextCombatEnd = false
local function OnSetupNeedsChanging()
    if (Spud.IsCurrentStateContentPVE()) then
        if (IsUnitInCombat("player")) then
            shouldCheckOnNextCombatEnd = true
        else
            Spud.Display("Have you changed your setup?", Spud.SETUP)
        end
    end
end

local function OnSetupChanged()
    Spud.Display(nil, Spud.SETUP)
end

local function OnCombatStateChanged(_, inCombat)
    if (inCombat) then
        Spud.Display(nil, Spud.SETUP)
    elseif (shouldCheckOnNextCombatEnd) then
        shouldCheckOnNextCombatEnd = false
        OnSetupNeedsChanging()
    end
end


---------------------------------------------------------------------
---------------------------------------------------------------------
-- EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
local function OnSlotUpdated(_, bagId, slotId)
    -- Ignore costume updates, poison updates
    if (slotId == EQUIP_SLOT_COSTUME or slotId == EQUIP_SLOT_POISON or slotId == EQUIP_SLOT_BACKUP_POISON) then return end
    OnSetupChanged()
end


---------------------------------------------------------------------
-- Boss change
---------------------------------------------------------------------
local function GetUnitNameIfExists(unitTag)
    if (DoesUnitExist(unitTag)) then
        return GetUnitName(unitTag)
    end
end

local prevBosses = ""
local function OnBossesChanged()
    local bossHash = ""

    for i = 1, BOSS_RANK_ITERATION_END do
        local name = GetUnitNameIfExists("boss" .. tostring(i))
        if (name and name ~= "") then
            bossHash = bossHash .. name
        end
    end

    -- Only trigger off bosses truly changing (sometimes the event fires for no apparent reason?)
    if (bossHash ~= prevBosses and (bossHash == "" or prevBosses == "")) then
        KD:dbg("[" .. prevBosses .. "] -> [" .. bossHash .. "]")
        prevBosses = bossHash
        -- TODO: don't do it on wipe (boss respawn)
        OnSetupNeedsChanging()
    end
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local agPrehooked = false
function Spud.InitializeGearSetup()
    KD:dbg("    Initializing AntiSpud Gear Setup...")

    Spud.Display(nil, Spud.SETUP)

    Spud.RegisterStateListener("Setup", OnSpudStateChanged)

    local checkSetup = KD.savedOptions.general.experimental -- TODO

    if (checkSetup and not agPrehooked and AG and AG.LoadSetInternal) then
        ZO_PreHook(AG, "LoadSet", OnSetupChanged)
        agPrehooked = true
    end

    EVENT_MANAGER:UnregisterForEvent(KD.name .. "AntiSpudSetupBossChanged", EVENT_BOSSES_CHANGED)
    if (checkSetup) then
        EVENT_MANAGER:RegisterForEvent(KD.name .. "AntiSpudSetupBossChanged", EVENT_BOSSES_CHANGED, OnBossesChanged)
    end

    -- Listen for combat state to avoid showing warning in combat
    EVENT_MANAGER:UnregisterForEvent(KD.name .. "AntiSpudSetupCombat", EVENT_PLAYER_COMBAT_STATE)
    if (checkSetup) then
        EVENT_MANAGER:RegisterForEvent(KD.name .. "AntiSpudSetupCombat", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    end

    -- Clear message when gear changes
    if (checkSetup) then
        EVENT_MANAGER:RegisterForEvent(KD.name .. "SpudSetupEquipped", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdated)
        EVENT_MANAGER:AddFilterForEvent(KD.name .. "SpudSetupEquipped", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            REGISTER_FILTER_BAG_ID, BAG_WORN,
            REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
    end
end
