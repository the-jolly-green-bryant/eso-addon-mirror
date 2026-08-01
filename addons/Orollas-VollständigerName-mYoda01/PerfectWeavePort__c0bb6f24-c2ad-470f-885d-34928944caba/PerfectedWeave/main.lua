-- =============================================================================
-- === PerfectedWeave Core Logic (main.lua)                                    ===
-- =============================================================================
--[[
    AddOn Name:         PerfectedWeave
    Description:        Advanced GCD management system for perfect light attack weaving
    Version:            1.2.0
    Author:             Orollas, VollständigerName, mYoda01
    Dependencies:       LibAddonMenu-2.0
--]]
-- =============================================================================
--[[
    SYSTEM ARCHITECTURE:
    - GCD State Machine Manager
    - Input Validation Engine
    - Combat Rhythm Controller
    - Multi-Layer Safety System
--]]
-- =============================================================================

-- =============================================================================
-- == GLOBAL ADDON DEFINITION & VERSION CONTROL ================================
-- =============================================================================
--[[
    Purpose: Establishes fundamental addon identity and version tracking
    Contains:
    - Addon metadata for ESO client recognition
    - Version control using semantic versioning (SemVer)
    - Localization system placeholder
--]]
PerfectedWeave = PerfectedWeave or {}

PerfectedWeave = {
    -- Internal namespace identifier (must match folder name)
    name = "PerfectedWeave",
    
    -- Semantic version (Major=breaking, Minor=features, Patch=fixes)
    version = "1.2.0",
    
    -- Localization proxy (overridden in localization.lua)
    --L = function() return "" end
}


-- =============================================================================
-- == LOCALIZED ALIASES & RUNTIME REFERENCES ===================================
-- =============================================================================
--[[
    Purpose: Optimize frequent access patterns
    Contains:
    - Localized addon namespace reference
    - Cached event manager reference
    - SavedVariables placeholder initialization
--]]

local PW = PerfectedWeave            -- Local namespace alias
local NAME = PW.name                 -- Immutable addon name
local PWSV                           -- Will hold SavedVariables reference
local EM = EVENT_MANAGER             -- Event system shortcut

-- =============================================================================
-- == LOCAL VARIABLES ==========================================================
-- =============================================================================
--[[
    Purpose: User-configurable block list
--]]

local LFG_ROLE_TANK = 2
local LFG_ROLE_HEAL = 4
local LFG_ROLE_DPS = 1
local weaponTypeToKey = {
    [WEAPONTYPE_NONE] = "none",
    [WEAPONTYPE_AXE] = "axe",
    [WEAPONTYPE_HAMMER] = "hammer",
    [WEAPONTYPE_SWORD] = "sword",
    [WEAPONTYPE_TWO_HANDED_SWORD] = "twoHandedSword",
    [WEAPONTYPE_TWO_HANDED_AXE] = "twoHandedAxe",
    [WEAPONTYPE_TWO_HANDED_HAMMER] = "twoHandedHammer",
    [WEAPONTYPE_BOW] = "bow",
    [WEAPONTYPE_HEALING_STAFF] = "healingStaff",
    [WEAPONTYPE_RUNE] = "rune",
    [WEAPONTYPE_DAGGER] = "dagger",
    [WEAPONTYPE_FIRE_STAFF] = "fireStaff",
    [WEAPONTYPE_FROST_STAFF] = "frostStaff",
    [WEAPONTYPE_SHIELD] = "shield",
    [WEAPONTYPE_LIGHTNING_STAFF] = "lightningStaff"
}

-- =============================================================================
-- == DEFAULT CONFIGURATION SETTINGS ===========================================
-- =============================================================================
--[[
    Purpose: Fallback settings for first-time users
    Structure:
    - Mode: 1=Strict, 2=Intelligent, 3=Disabled, 4=Sequential
    - Technical: Latency compensation values
    - Safety: Input blocking conditions
    - Lists: Custom ability management
--]]

local defaults = {
    mode = 3,                        -- Operating mode selector
    autoLag = true,                  -- Dynamic latency detection toggle
    inputLag = 20,                   -- Manual latency override (ms)
    block = true,                    -- Global input blocking enabled
    combat = true,                   -- Combat-only restriction
    blockGroundAbilities = true,     -- Ground AOE protection
    checkTarget = true,              -- Target requirement
    neverBlockedAbilityIDs = {},     -- Abilities that should never be blocked under any circumstances

    -- =========================================================================
    -- == NIGHTBLADE CLASS SETTINGS ============================================
    -- =========================================================================
    -- Grim Focus ability tracking and configuration
    grimFocusSkillIds = {
        [61919] = false, -- Merciless
        [61927] = false, -- Relentless
        [61902] = false  -- Grim
    },

    -- -- Buff IDs that indicate Grim Focus stacks are active
    grimFocusStackIds = {
        [122586] = true, -- Merciless
        [122585] = true, -- Grim
        [122587] = true  -- Relentless
    },

    useGrimFocusStacks = false, -- Enable stack-based blocking: Block ability when reaching certain stack count
    grimFocusStacks = 10,       -- How many grim focus stacks

    -- Death Stroke ability configuration
    deathStrokeMorphs = {
                         -- Death Stroke
        [36514] = false  -- Soul Harvest
                         -- Incapacitating Strike
    },
    
    incapacitatingStrikeStacks = 120, -- Stack threshold for Incapacitating Strike morph

    -- =========================================================================
    -- == ARCANIST CLASS SETTINGS ==============================================
    -- =========================================================================
    -- Fatecarver beam ability configurations (both magicka and stamina morphs)
    arcaBeamSkillIds = {
        [185805] = false, -- Base Mag
        [183122] = false, -- Exhausting Fatecarver Mag
        [186366] = false, -- Pragmatic Fatecarver Mag
        [193397] = false, -- Base Stam
        [193398] = false, -- Exhausting Fatecarver Stam
        [193331] = false  -- Pragmatic Fatecarver Stam

    },

    -- Tentacular Dread ability configuration
    tentacularDread = {
        [185823] = false -- Tentacular Dread (that one that consumes Crux)
    },

    -- Cephaliarch's Flail ability configuration
    cephaliarchsFlail = {
        [183006] = false -- Cephaliarch's Flail 
    },
    useCruxStacksCephaliarch = false,  -- Cephaliarch's Flail Crux Check

    deactivateArcaBeamBlockAtHpUnder = 30, -- limit value of HP
    checkHpForArcaBeam = true, -- Check HP before beam

    deactivateArcaBeamBlockAtStamUnder = 20, -- limit value of Stam
    checkStamForArcaBeam = true, -- Check Stam before beam

    cruxId = 184220,        -- Crux buff ID
    useCruxStacks = false,  -- Enable Crux-based blocking for Fatecarver abilities
    cruxStacks = 3,         -- Crux stack threshold for Fatecarver blocking
    usecruxStacksTentacular = false, -- Enable Crux-based blocking for Tentacular Dread
    cruxStacksTentacular = 3, -- Crux stack threshold for Tentacular Dread blocking

    -- =========================================================================
    -- == DRAGONKNIGHT CLASS SETTINGS ==========================================
    -- =========================================================================
    MoltenWhip = {
        [20805] = false -- Molten Whip
    },

    -- =========================================================================
    -- == GUILD SETTINGS =======================================================
    -- =========================================================================
    -- Mages guild
    lightMorphs = {
        [30920] = true, -- Magelight
        [40478] = true, -- Inner light
        [40483] = true  -- Radiant Magelight
    },

    -- Fighters guild
    hunterMorphs = {
        [35762] = true, -- Expert Hunter
        [40195] = true, -- Camouflaged Hunter
        [40194] = true  -- Evil Hunter
    },

    -- Fighters Guild
    dawnbreakerMorphs = {
        [35713] = false, -- Dawnbreaker
        [40161] = false, -- Flawless Dawnbreaker
        [40158] = false  -- Dawnbreaker of Smiting
    },

    -- =========================================================================
    -- == EXECUTE SYSTEM SETTINGS ==============================================
    -- =========================================================================
    useExecuteCheck = false, -- Execute Check Master Toggle: Enable/disable all execute functionality
    executeThreshold = 30,   -- Health Percentage Threshold: Target HP% below which execute abilities are allowed

    executeCheckSpells = {
        [63029] = false, -- Radiant Destruction
        [63044] = false, -- Radiant Glory
        [63046] = false, -- Radiant Oppression
        [34851] = false, -- Impale
        [34843] = false, -- Killer's Blade
        [33386] = false, -- Assassin's Blade
        [19123] = false, -- Mages' Wrath
        [18718] = false, -- Mages' Fury
        [19109] = false, -- Endless Fury
        [28302] = false, -- Reverse Slash
        [38823] = false, -- Reverse Slice
        [38819] = false, -- Executioner
    },

    -- =========================================================================
    -- == GCD SETTINGS =========================================================
    -- =========================================================================
    channelBufferNormal = 50,       -- Standard ability buffer: Extra time (ms) added to non-channeled cast times, Default: 50ms
    channelBufferChanneled = 200,   -- Channeled ability buffer: Extra time (ms) added to channeled abilities, Default: 200ms
    gcdTrackingSlot = 3,            -- Default GCD tracking slot: Action bar slot (3-8) used to monitor GCD state, Default: Slot 3
    autoGcdTrackingSlot = false,    -- Automatic slot selection: Dynamically find active ability slot for GCD tracking
    minGcdThreshold = 10,           -- Minimum GCD detection: Smallest cooldown (ms) recognized as a GCD, Default: 10ms
    baseQueueTime = 1050,           -- Base ability queue window: Time window (ms) for queuing next ability, Default: 1050ms

    -- =========================================================================
    -- == ROLE-BASED DEACTIVATION SETTINGS =====================================
    -- =========================================================================
    disableTank = true, -- Tank role deactivation: Automatically disable addon when in tank role
    disableHeal = true, -- Healer role deactivation: Automatically disable addon when in healer role
    originalMode = 0,   -- Original mode storage

    -- =========================================================================
    -- == RESET BEHAVIOR SETTINGS ==============================================
    -- =========================================================================
    resetOnDodge = true,    -- Reset on dodge: Clear GCD state when player dodges
    resetOnBarswap = true,  -- Reset on bar swap: Clear GCD state when swapping bars
    resetAfterSeconds = 20, -- Inactivity reset timer: Seconds of inactivity before GCD state resets

    -- =========================================================================
    -- == WEAPON DEACTIVATION SETTINGS =========================================
    -- =========================================================================
    -- Backbar deactivation settings
    deactivateOnBackbar = {
        features = false,   -- Deactivating other features on Backbar
        weaveAssist = false -- Deactivate weave Assist on Backbar
    },

    deactivateOnWeaponType = {
        none = false,           -- No weapon equipped, Int. = 0
        axe = false,            -- One-handed axe,     Int. = 1
        hammer = false,         -- One-handed hammer,  Int. = 2
        sword = false,          -- One-handed sword,   Int. = 3
        twoHandedSword = false, -- Two-handed sword,   Int. = 4
        twoHandedAxe = false,   -- Two-handed axe,     Int. = 5
        twoHandedHammer = false,-- Two-handed hammer,  Int. = 6
        reservedWeapon = false, -- Reserved weapon,    Int. = 7
        bow = false,            -- Bow,                Int. = 8
        healingStaff = false,   -- Restoration staff,  Int. = 9
        rune = false,           -- Rune (unused),      Int. = 10
        dagger = false,         -- Dagger,             Int. = 11
        fireStaff = false,      -- Inferno staff,      Int. = 12
        frostStaff = false,     -- Frost staff,        Int. = 13
        shield = false,         -- Shield,             Int. = 14
        lightningStaff = false  -- Lightning staff,    Int. = 15
    },

    -- Weapon-based deactivation toggles
    deactivateOnWeapon = {
        features = false,   -- Deactivating other features 
        weaveAssist = false -- Deactivate weave Assist
    },

    -- PvP area deactivation settings
    deactivateInPvP = {
        features = false,   -- Deactivating other features in PvP areas
        weaveAssist = false -- Deactivate weave Assist in PvP areas
    },

    autoEquipWeapons = false,           -- Automatic weapon equipping: Auto-unsheathe weapons in combat/dungeon situations
    deactivateHunterLightInPvP = true,  -- PvP deactivation: Disable Hunter/Light morph blocking in PvP areas

    -- =========================================================================
    -- == CUSTOM BLOCK LIST SETTINGS ===========================================
    -- =========================================================================
    useCustomBlockList = false,                     -- Master toggle for user-defined block list
    useCustomRecastBlockList = false,               -- Master toggle for user-defined recast block list
    useCustomBlockListHealthCheck = false,          -- Enable health-based exceptions for custom block list
    useCustomRecastBlockListHealthCheck = false,    -- Enable health-based exceptions for custom recast block list
    useCustomBlockListHealthPercent = 30,           -- Health threshold (%) for custom block list exceptions
    useCustomRecastBlockListHealthPercent = 30,     -- Health threshold (%) for custom recast block list exceptions
    recastBlockTime = 3,                            -- Time window (seconds) for recast blocking
    
    -- =========================================================================
    -- == RESOURCE-BASED BLOCK LIST SETTINGS ===================================
    -- =========================================================================
    activateResourceBasedBlockingMenu = true, -- Toggle menu visibility 
    useCustomResourceBlockList = false,
    useCustomResourceRecastBlockList = false,
    useCustomBlockListResourceCheck = false,
    useCustomRecastBlockListResourceCheck = false,
    useCustomBlockListResourcePercent = 20,
    useCustomRecastBlockListResourcePercent = 20,
    recastResourceBlockTime = 3, -- In seconds


    -- =========================================================================
    -- == USER-CONFIGURABLE BLOCK LISTS ========================================
    -- =========================================================================
    -- Immediate blocking list: Blocks abilities as soon as pressed
    customBlockList = { -- Example: [12345] = false/true  -> [SpellID] = bool if active in block list
    -- Example: [12345] = true  -- Blocks ability ID 12345 immediately
    },

    -- Recast blocking list: Blocks abilities if recast within time window
    customRecastBlockList = { -- Example: [12345] = false/true  -> [SpellID] = bool if active in block list
    -- Example: [12345] = true  -- Blocks ability ID 12345 if recast too soon
    },

    -- Resource-based blocking list
    customResourceBlockList = { 
    -- Example: [12345] = {
    --     blocked = false,           -- Complete blocked
    --     magickaCheck = false,      -- If Magicka check is used
    --     magickaBlock = false,      -- Check if the spell is Blocked or usable depending on the Magicka Percentage
    --     magickaPercent = 0,        -- Percentage how many Magicka
    --     staminaCheck = false,      -- If Stamina check is used
    --     staminaBlock = false,      -- Check if the spell is Blocked or usable depending on the Stamina Percentage
    --     staminaPercent = 0,        -- Percentage how many Stamina
    -- }
    },

    -- =========================================================================
    -- == EXPERIMENTAL SETTINGS ================================================
    -- =========================================================================
    blockAoEIfNoTarget = false, -- Experimental: Block ground AoEs when no target is selected

}

-- =============================================================================
-- == DEBUG SYSTEM =============================================================
-- =============================================================================
--[[
    Debug Modes:
    - "block": GCD blocking decisions
    - "condition": Ability condition checks  
    - "info": General state information
--]]

local DEBUG_MODES = {
    block = false,      -- GCD blocking decisions
    condition = false,  -- Ability condition checks
    info = false       -- General state information
}

--------------------------------------------------------------------------------
-- Debug Print Function
-- @param mode: Debug category ("block", "condition", "info")
-- @param ...: Messages to print
--------------------------------------------------------------------------------
local function DebugPrint(mode, ...)
    if DEBUG_MODES[mode] then
        d(...)
    end
end
   
-- =============================================================================
-- == KEYBIND FUNCTIONS ========================================================
-- =============================================================================

local function ToggleMode()
    if not PWSV then return end
    
    -- Cycle through modes: 1->2->3->1
    local currentMode = PWSV.mode or 1
    local newMode = currentMode + 1
    if newMode > 4 then
        newMode = 1
    end
    
    PWSV.mode = newMode
    --PWSV.originalMode = 0
    
    local modeNames = {[1] = "Strict", [2] = "Intelligent", [3] = "Disabled", [4] = "Sequential"}
    d(string.format("|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r: Mode set to |cFFD700%s|r", modeNames[newMode]))
end

local function ToggleCustomBlockList()
    if not PWSV then return end
    
    PWSV.useCustomBlockList = not PWSV.useCustomBlockList
    local status = PWSV.useCustomBlockList and "|c00FF00enabled|r" or "|cFF0000disabled|r"
    d(string.format("|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r: Custom Block List %s", status))
end

local function ToggleCustomRecastBlockList()
    if not PWSV then return end
    
    PWSV.useCustomRecastBlockList = not PWSV.useCustomRecastBlockList
    local status = PWSV.useCustomRecastBlockList and "|c00FF00enabled|r" or "|cFF0000disabled|r"
    d(string.format("|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r: Custom Recast Block List %s", status))
end

local function ToggleBackbarFeatures()
    if not PWSV then return end
    
    PWSV.deactivateOnBackbar.features = not PWSV.deactivateOnBackbar.features
    local status = PWSV.deactivateOnBackbar.features and "|c00FF00enabled|r" or "|cFF0000disabled|r"
    d(string.format("|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r: Backbar Features deactivation %s", status))
end

local function ToggleBackbarWeaveAssist()
    if not PWSV then return end
    
    PWSV.deactivateOnBackbar.weaveAssist = not PWSV.deactivateOnBackbar.weaveAssist
    local status = PWSV.deactivateOnBackbar.weaveAssist and "|c00FF00enabled|r" or "|cFF0000disabled|r"
    d(string.format("|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r: Backbar Weave Assist deactivation %s", status))
end

local function ToggleExecuteCheck()
    if not PWSV then return end
    
    PWSV.useExecuteCheck = not PWSV.useExecuteCheck
    local status = PWSV.useExecuteCheck and "|c00FF00enabled|r" or "|cFF0000disabled|r"
    d(string.format("|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r: Execute Check %s", status))
end

-- =============================================================================
-- === TO GLOBAL FOR KEYBIND FUNCTIONS =========================================
-- =============================================================================

PerfectedWeave.ToggleMode = ToggleMode
PerfectedWeave.ToggleCustomBlockList = ToggleCustomBlockList
PerfectedWeave.ToggleCustomRecastBlockList = ToggleCustomRecastBlockList
PerfectedWeave.ToggleBackbarFeatures = ToggleBackbarFeatures
PerfectedWeave.ToggleBackbarWeaveAssist = ToggleBackbarWeaveAssist
PerfectedWeave.ToggleExecuteCheck = ToggleExecuteCheck

-- =============================================================================
-- == AUTOMATIC GCD TRACKING SLOT SELECTION ====================================
-- =============================================================================
--[[
Function: AutoSelectGcdTrackingSlot
    Purpose:
      Automatically selects the best GCD tracking slot by checking slots 3-8
      for active cooldowns. Cycles through slots until one with valid cooldown
      data is found.

    Process Flow:
      1. Start from current slot + 1 (or 3 if at the end)
      2. Check each slot in sequence (3-8)
      3. If a slot has valid cooldown data (cd and duration not 0/nil), use it
      4. If no valid slot found after full cycle, default to slot 3
--]]

local function AutoSelectGcdTrackingSlot()
    if not PWSV.autoGcdTrackingSlot then
        return  -- Feature not enabled
    end
    
    local currentSlot = PWSV.gcdTrackingSlot
    local newSlot = nil
    
    -- Go through all slots from 3 to 8, starting with the next slot.
    for i = 1, 6 do  -- 6 Slot: 3 to 8
        local testSlot = (currentSlot - 3 + i) % 6 + 3
        local cd, duration, global, globalSlotType = GetSlotCooldownInfo(testSlot)
        
        DebugPrint("info", string.format("Testing slot %d: cd=%s, duration=%s", testSlot, tostring(cd), tostring(duration)))
        
        -- Check whether the slot has valid cooldown data
        if cd and cd > 0 and duration and duration > 0 then
            newSlot = testSlot
            DebugPrint("info", string.format("Selected slot %d for GCD tracking", newSlot))
            break
        end
    end
    
    -- Fallback to slot 3 if no valid slot was found
    if not newSlot then
        newSlot = 3
        DebugPrint("info", "No valid slot found, defaulting to slot 3")
    end
    
    PWSV.gcdTrackingSlot = newSlot
end

-- =============================================================================
-- == AUTOMATIC WEAPON EQUIPPING ===============================================
-- =============================================================================
--[[
    Function: EquipWeaponsStateChange
    Purpose: Automatically unsheathe weapons when leaving various UI states
    Events: Combat, crafting, chatting, shopping, etc.
--]]

local function EquipWeaponsStateChange()
    if not PWSV.autoEquipWeapons then return end
    
    if ArePlayerWeaponsSheathed() and (IsPlayerInRaid() or IsUnitInDungeon('player') or IsUnitInCombat('player'))  then
        DebugPrint("info", "Draw weapon")
        TogglePlayerWield()
    end
end

-- =============================================================================
-- == DEACTIVATE BASED ON WEAPON ===============================================
-- =============================================================================
--[[
Function: deactivateBasedOnWeapon
    Purpose:
      Determines whether addon features should be deactivated based on the currently
      equipped weapon types. Checks both main hand and off-hand weapons (or backup
      weapons) against the user's configured weapon type blocklist.

    Process Flow:
      1. Identify active weapon pair (main bar or backbar)
      2. Select corresponding equipment slots for checking
      3. Iterate through each weapon slot in the active pair
      4. Retrieve weapon type and map to configuration key
      5. Check if weapon type is in user's deactivation list
      6. Return true if any weapon matches deactivation criteria

    Weapon Handling:
      - Main Bar: EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND
      - Backbar: EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF
      - Uses weaponTypeToKey mapping table for configuration lookup
--]]

--------------------------------------------------------------------------------
-- Weapon-Based Deactivation Check
-- @return: Boolean indicating if features should be deactivated for current weapons
--------------------------------------------------------------------------------
local function deactivateBasedOnWeapon()
    local ActiveWeaponPair, _ = GetActiveWeaponPairInfo()
    local slots
    
    if ActiveWeaponPair == 1 then
        -- Main Hand
        slots = {EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND}
    else
        -- Backbar
        slots = {EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF}
    end
    
    for _, slot in ipairs(slots) do
        local weaponType = GetItemWeaponType(BAG_WORN, slot)
        local key = weaponTypeToKey[weaponType]
        if key and PWSV.deactivateOnWeaponType[key] then
            return true
        end
    end
    
    return false
end

-- =============================================================================
-- == EXECUTE CHECK SYSTEM =====================================================
-- =============================================================================
--[[
Function: checkExecuteReady
    Purpose:
      Evaluates the current target health to determine whether
      an ability should remain active or be blocked. Specifically, if the target health
      is below the specified threshold (PWSV.executeThreshold),
      the ability is allowed (active = true).

    Process Flow:
      1. Check if target exists and is not dead
      2. Get current and maximum health of target
      3. Calculate health percentage
      4. Check if health percentage is below threshold
      5. Return true if ability should be allowed, false if blocked
--]]

--------------------------------------------------------------------------------
-- Execute Check Function
-- @param id: Ability ID being checked
-- @return: Boolean indicating if ability should be allowed
--------------------------------------------------------------------------------
local function checkExecuteReady(id)
    local active = false  -- Default: block the ability
    
    -- Check if target exists and is not dead
    if not DoesUnitExist('reticleover') or IsUnitDead('reticleover') then
        DebugPrint("condition", "Execute Check: Target does not exist or is dead")
        return active
    end
    
    -- Get current and maximum health values of target
    local currentHealth, maxHealth = GetUnitPower('reticleover', POWERTYPE_HEALTH)
    DebugPrint("condition", string.format("Execute Check: Target Health - Current: %d, Maximum: %d", currentHealth, maxHealth))
    
    -- Validate health values to avoid division by zero
    if currentHealth == 0 or maxHealth == 0 then
        DebugPrint("condition", "Execute Check: Invalid health values")
        return active
    end
    
    -- Calculate health percentage
    local percentHP = (currentHealth / maxHealth) * 100
    DebugPrint("condition", string.format("Execute Check: Health Percentage: %.1f%%, Threshold: %.1f%%", percentHP, PWSV.executeThreshold))
    
    -- Check if health is below execute threshold
    if percentHP <= PWSV.executeThreshold then
        active = true  -- Allow ability in execute phase
        DebugPrint("condition", "Execute Check: EXECUTE PHASE ACTIVE - Ability allowed")
    else
        DebugPrint("condition", "Execute Check: Target not in execute phase - Ability blocked")
    end
    
    return active
end

-- =============================================================================
-- == ABILITY VALIDATION SUBSYSTEM =============================================
-- =============================================================================
--[[
    Function: IsBlockedNeverAbilityID
    Purpose: Check against hardcoded blocklist
    Logic:
    1. Iterate through BlockedAbilityIDs table
    2. Return true on first match
    3. Fallback to false if no match
    - Bypasses all configuration settings
--]]

--------------------------------------------------------------------------------
-- Hardcoded Ability Blocklist Check
-- @param id: AbilityID to validate
-- @return: Boolean blocking status
--------------------------------------------------------------------------------
local function IsBlockedNeverAbilityID(id)
    return PWSV.neverBlockedAbilityIDs and PWSV.neverBlockedAbilityIDs[id] or false
end

-- =============================================================================
-- == ROLE VALIDATION SUBSYSTEM ================================================
-- =============================================================================
--[[
Function: CheckRoleOverride
    Purpose:
      Manages automatic mode switching based on the player's selected role.
      Disables the addon for Tank and Healer roles when configured, while
      preserving the original mode for DPS roles.

    Process Flow:
      1. Retrieve the player's currently selected LFG role
      2. Check if role is Tank/Healer with corresponding disable setting active:
            - If conditions met, save current mode and set addon to disabled (mode 3)
      3. For DPS roles or when restrictions are inactive:
            - Restore the previously saved mode if available
      4. Maintains state tracking to seamlessly transition between role changes

    State Management:
      - originalMode: Stores the previous mode when switching to Tank/Healer
      - mode: Current operational mode (1=Hard, 2=Soft, 3=Disabled)
--]]

--------------------------------------------------------------------------------
-- Role-Based Mode Management
-- @return: None (modifies PWSV state directly)
--------------------------------------------------------------------------------
local function CheckRoleOverride()
    local role = GetSelectedLFGRole()

    if (role == LFG_ROLE_TANK and PWSV.disableTank) or
       (role == LFG_ROLE_HEAL and PWSV.disableHeal) then
        -- Just note when we were in DD and not yet saved
        if PWSV.mode ~= 3 and PWSV.originalMode == 0 then
            PWSV.originalMode = PWSV.mode
        end
        -- Tank or Healer on Mode set to None
        PWSV.mode = 3

    else
        -- DD or disabled restriction -> restore saved mode
        if PWSV.originalMode ~= 0 then
            PWSV.mode = PWSV.originalMode
        end
    end
end

PW.CheckRoleOverride = CheckRoleOverride

-- =============================================================================
-- == CHECK IF GRIM FOCUS STATUS ===============================================
-- =============================================================================
--[[
     Function: checkGrimFocus
    Purpose:
      Determines whether an ability should be blocked based on the current Grim Focus
      stacks. Specifically:
        - For "Relentless Focus": completely blocks the ability when conditions are met.
        - For "Merciless" and "Grim": blocks the ability once the defined number of Grim Focus
          stacks has been reached.
          
    Process Flow:
      1. Initialization:
         - Sets the default 'active' value to false, meaning the ability is blocked by default.
         - Establishes the stack limit (stackLimit) from configuration; if Grim Focus stacks are not in use,
           it falls back to a default value of 10.
          
      2. Iteration Through Buffs:
         - Loops over all active buffs on the player.
         - Retrieves key parameters for each buff (e.g., end time, stack count, abilityId) for evaluation.
          
      3. Buff Condition Evaluation:
         A. For the buff corresponding to the Grim Focus skill at index 2 (used for a specific Grim Focus morph)
            and identified as a relevant Grim Focus stack:
               - If using Grim Focus stacks and the current stack count is equal to or exceeds the stack limit,
                 while ensuring that buff ID 61927 is not active, then the ability remains blocked (active = false).
               - Otherwise, the block is lifted (active = true) and the loop exits.
               
         B. For buffs matching the other Grim Focus morphs (grimFocusSkillIds at index 1 or 3) and qualifying as
            a Grim Focus stack:
               - If either Grim Focus stacking is enabled or the respective skill is active, and the stack count 
                 meets or exceeds the threshold, then the ability is blocked (active = false).
               - Otherwise, the block is not applied (active = true).
          
      4. Return:
         - Returns the 'active' state which indicates whether the ability should be allowed (true) or blocked (false).
--]]

--------------------------------------------------------------------------------
-- Input Validation Master Function
-- @return: Boolean input permission
--------------------------------------------------------------------------------
local function checkGrimFocus(id)
    local active = false -- Initialization of default for block of grim focus
    local stackLimit = PWSV.grimFocusStacks

    if not PWSV.useGrimFocusStacks then
        stackLimit = 1,10
    end

    for buffIndex = 1, GetNumBuffs('player') do
        local _, _, timeEnding, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', buffIndex)
        if 61927 == id and PWSV.grimFocusStackIds[abilityId] then
           if PWSV.useGrimFocusStacks and stackCount >= stackLimit and not PWSV.grimFocusSkillIds[61927] then
                active = false
            else 
                active = true
                break
            end

        elseif PWSV.grimFocusStackIds[abilityId] then
            if (PWSV.useGrimFocusStacks or PWSV.grimFocusSkillIds[id]) and stackCount >= stackLimit then
                active = false
            else 
                active = true
            end
        end
    end
    return active
end

-- =============================================================================
-- == CHECK CRUX STACK STATUS ==================================================
-- =============================================================================
--[[
Function: checkCruxStacks
    Purpose:
      Evaluates the current Crux buff status on the player to determine whether
      an ability should remain active or be blocked. Specifically, if the number of
      Crux stacks reaches or exceeds the specified threshold (PWSV.cruxStacks),
      the ability is blocked (active = false).

    Process Flow:
      1. Iterate through all active buffs on the player.
      2. Identify the buff that matches the Crux ability by comparing the buff's abilityId
         with the configured PWSV.cruxId.
      3. Check the stack count of the identified Crux buff:
            - If the stack count is equal to or greater than the defined threshold (PWSV.cruxStacks),
              set 'active' to false (i.e., block the ability) and exit the loop.
            - Otherwise, set 'active' to true and exit the loop.
      4. Return the final status, where 'true' indicates the ability is allowed and 'false'
         indicates it is blocked.
--]]

--------------------------------------------------------------------------------
-- Input Validation Master Function
-- @return: Boolean input permission
--------------------------------------------------------------------------------
local function checkCruxStacks(id)
    local active = true 
    DebugPrint("condition", "Check Crux stacks block in checkCruxStacks(")
    DebugPrint("condition", "PWSV.cruxId ".. tostring(PWSV.cruxId))
    local currentHealth, maxHealth, effHealth = GetUnitPower('player', COMBAT_MECHANIC_FLAGS_HEALTH)
    local pecentHealth = currentHealth / effHealth * 100
    DebugPrint("info", string.format("HP: current: %d / max.: %d / eff. max. %d / Percent %d ", currentHealth, maxHealth, effHealth, pecentHealth))

    local currentStam, maxStam, effStam = GetUnitPower('player', COMBAT_MECHANIC_FLAGS_STAMINA)
    local pecentStam = currentStam / effStam * 100
    DebugPrint("info", string.format("Stamina: current: %d / max.: %d / eff. max. %d / Percent %d ", currentStam, maxStam, effStam, pecentStam))

    if (PWSV.checkHpForArcaBeam and pecentHealth <= PWSV.deactivateArcaBeamBlockAtHpUnder) or (PWSV.checkStamForArcaBeam and pecentStam <= PWSV.deactivateArcaBeamBlockAtStamUnder) then
        active = false
        DebugPrint("condition", "active = false")
    else    
        for buffIndex = 1, GetNumBuffs('player') do
            local _, _, timeEnding, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', buffIndex)
            DebugPrint("condition", "Buff"..abilityId)
            if PWSV.cruxId == abilityId then
                DebugPrint("condition", "Check Crux stacks block in PWSV.cruxId == abilityId")
                if stackCount >= PWSV.cruxStacks then
                    active = false
                    DebugPrint("condition", "active = false")
                    break
                else 
                    active = true
                    DebugPrint("condition", "active = true")
                    break
                end
            end
        end    
    end
    return active
end

-- =============================================================================
-- == CHECK CRUX STACK STATUS FOR CEPHALIARCH'S FLAIL ==========================
-- =============================================================================
--[[
Function: checkCruxStacksCephaliarch
    Purpose:
      Evaluates the current Crux buff status on the player to determine whether
      Cephaliarch's Flail should be allowed or blocked. Specifically, if the number of
      Crux stacks reaches or exceeds 3, the ability is allowed (active = true).

    Process Flow:
      1. Iterate through all active buffs on the player.
      2. Identify the buff that matches the Crux ability by comparing the buff's abilityId
         with the configured PWSV.cruxId.
      3. Check the stack count of the identified Crux buff:
            - If the stack count is equal to or greater than 3,
              set 'active' to true (i.e., allow the ability) and exit the loop.
            - Otherwise, set 'active' to false and exit the loop.
      4. Return the final status, where 'true' indicates the ability is allowed and 'false'
         indicates it is blocked.
--]]

--------------------------------------------------------------------------------
-- Crux Stack Validation for Cephaliarch's Flail
-- @param id: Ability ID being checked
-- @return: Boolean indicating if ability should be allowed
--------------------------------------------------------------------------------
local function checkCruxStacksCephaliarch(id)
    local active = false 
    DebugPrint("condition", "Check Crux stacks block in checkCruxStacksCephaliarch")
    DebugPrint("condition", "PWSV.cruxId ".. tostring(PWSV.cruxId))
    
    for buffIndex = 1, GetNumBuffs('player') do
        local _, _, timeEnding, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', buffIndex)
        DebugPrint("condition", "Buff "..abilityId)
        if PWSV.cruxId == abilityId then
            DebugPrint("condition", "Check Crux stacks block in PWSV.cruxId == abilityId")
            if stackCount >= 3 then  -- Always block at 3 stacks
                active = true
                DebugPrint("condition", "active = true due to 3+ Crux stacks")
                break
            else 
                active = false
                DebugPrint("condition", "active = false - less than 3 Crux stacks")
                break
            end
        end
    end    
    return active
end

-- =============================================================================
-- == CHECK CRUX STACK STATUS FOR TENTACULAR DREAD =============================
-- =============================================================================
--[[
Function: checkCruxStacksTentacular
    Purpose:
      Evaluates the current Crux buff status on the player to determine whether
      an ability should remain active or be blocked. Specifically, if the number of
      Crux stacks reaches or exceeds the specified threshold (PWSV.cruxStacks),
      the ability is blocked (active = false).

    Process Flow:
      1. Iterate through all active buffs on the player.
      2. Identify the buff that matches the Crux ability by comparing the buff's abilityId
         with the configured PWSV.cruxId.
      3. Check the stack count of the identified Crux buff:
            - If the stack count is equal to or greater than the defined threshold (PWSV.cruxStacks),
              set 'active' to false (i.e., block the ability) and exit the loop.
            - Otherwise, set 'active' to true and exit the loop.
      4. Return the final status, where 'true' indicates the ability is allowed and 'false'
         indicates it is blocked.
--]]

--------------------------------------------------------------------------------
-- Input Validation Master Function
-- @return: Boolean input permission
--------------------------------------------------------------------------------
local function checkcruxStacksTentacular(id)
    local active = true 
    DebugPrint("condition", "Check Crux stacks block in checkcruxStacks(")
    DebugPrint("condition", "PWSV.cruxId ".. tostring(PWSV.cruxId))
    
    for buffIndex = 1, GetNumBuffs('player') do
        local _, _, timeEnding, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', buffIndex)
        DebugPrint("condition", "Buff"..abilityId)
        if PWSV.cruxId == abilityId then
            DebugPrint("condition", "Check Crux stacks block in PWSV.cruxId == abilityId")
            if stackCount >= PWSV.cruxStacksTentacular then
                active = false
                DebugPrint("condition", "active = false")
                break
            else 
                active = true
                DebugPrint("condition", "active = true")
                break
            end
        end    
    end
    return active
end


-- =============================================================================
-- == GROUND ABILITY DETECTION SYSTEM ==========================================
-- =============================================================================
--[[
    Function: CheckGroundAbility
    Purpose: Identify ground-targeted abilities with caching
    Features:
    - Uses ESO's localized string comparison
    - Implements memoization pattern
    - Auto-detects ground AOEs dynamically
--]]

-- Cache localized ground target description
local groundString = GetString(SI_ABILITY_TOOLTIP_TARGET_TYPE_GROUND)
local groundAbilities = {}  -- AbilityID:isGround cache

--------------------------------------------------------------------------------
-- Ground Ability Detection with Memoization
-- @param id: AbilityID to check
-- @return: Boolean ground-target status
--------------------------------------------------------------------------------
local function CheckGroundAbility(id)
    -- Cache miss handling
    if groundAbilities[id] == nil then
        -- Execute string comparison once per ability
        groundAbilities[id] = (GetAbilityTargetDescription(id) == groundString)
    end
    return groundAbilities[id]  -- Return cached value
end

-- =============================================================================
-- == COMBAT STATE MANAGEMENT ==================================================
-- =============================================================================
--[[
    State Machine Definition:
    0 = Inactive: No GCD restrictions
    1 = Locked: GCD active, no inputs
    2 = QueueWindow: Valid LA window
    3 = LAQueued: Light Attack pending
    4 = SkillQueued: Ability queued
--]]

local GCD_STAGE = 0  -- Current state machine position
local CHANNEL = 0    -- Channel expiration timestamp
local LAST_ABILITY = 0  -- Last used ability ID tracker
local timeSinceLastCast = 0  -- Time of last cast in milliseconds

-- =============================================================================
-- == RESET GCD ================================================================
-- =============================================================================
--[[
    Function: ResetGCDOnDodge / ResetGCDOnBarswap / ResetGCD / OnPlayerStunned
    Purpose: Reset state 
    Features:
    - Full state reset on stun
    - Channel cancellation
    - Memory clearing
--]]

local function ResetGCDOnDodge()
    if PWSV.resetOnDodge  then
        GCD_STAGE = 0
        CHANNEL = 0
        LAST_ABILITY = 0
        timeSinceLastCast = 0
        DebugPrint("block", "Reset because of Dodge")
    end   
end

local function ResetGCDOnBarswap()
    if PWSV.resetOnBarswap  then
        GCD_STAGE = 0
        CHANNEL = 0
        LAST_ABILITY = 0
        timeSinceLastCast = 0
        DebugPrint("block", "Reset because of Barswap")
    end   
end

local function ResetGCD()
    GCD_STAGE = 0
    CHANNEL = 0
    LAST_ABILITY = 0
    timeSinceLastCast = 0
    DebugPrint("block", "Reset because everything else")
end

local function OnPlayerStunned()
    GCD_STAGE = 0    -- Reset state machine
    CHANNEL = 0      -- Cancel active channels
    LAST_ABILITY = 0 -- Clear ability memory
    timeSinceLastCast = 0
    DebugPrint("block", "Stunned/Silenced etc.")
end

local function CastCanceled() -- Check if 
    if IsBlockActive() then
        DebugPrint("block", "Block")
        GCD_STAGE = 0    -- Reset state machine
        CHANNEL = 0      -- Cancel active channels
        LAST_ABILITY = 0 -- Clear ability memory
        timeSinceLastCast = 0
    end
end    

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST CHECK ==========================================
-- =============================================================================
--[[
Function: CheckResourceBlockList
    Purpose:
      Evaluates all conditions for a spell in the customResourceBlockList
      and determines if it should be blocked.
    
    Structure of spellData:
      spellData = {
          blocked = false,           -- Complete blocked
          magickaCheck = false,      -- If Magicka check is used
          magickaBlock = false,      -- Check if the spell is Blocked or usable depending on the Magicka Percentage
          magickaPercent = 0,        -- Percentage how many Magicka
          staminaCheck = false,      -- If Stamina check is used
          staminaBlock = false,      -- Check if the spell is Blocked or usable depending on the Stamina Percentage
          staminaPercent = 0,        -- Percentage how many Stamina
          recastBlock = false,       -- Recast Block is used
          recastTime = 0             -- Recast Block time in seconds
      }
    
    Process Flow:
      1. Check if spell is completely blocked
      2. Check Magicka conditions if enabled
      3. Check Stamina conditions if enabled
      4. Check Recast conditions if enabled
      5. Return true if any condition triggers blocking, false otherwise
--]]

local function CheckResourceBlockList(spellId)
   
    -- Get spell data
    local spellData = PWSV.customResourceBlockList[spellId]
    if not spellData then
        return false  -- Spell not in resource block list
    end
    
    DebugPrint("condition", string.format("Checking resource block for spell ID %d", spellId))
    
    -- 1. Check if spell block is active
    if not spellData.blocked then
        DebugPrint("condition", "Resource Block: Spell is active")
        return false
    end
    
    -- 2. Magicka check
    if spellData.magickaCheck then
        local currentMagicka, maxMagicka, effMagicka = GetUnitPower('player', COMBAT_MECHANIC_FLAGS_MAGICKA)
        local percentMagicka = (effMagicka > 0) and (currentMagicka / effMagicka * 100) or 0
        
        DebugPrint("condition", string.format("Magicka Check: Current: %.1f%%, Threshold: %.1f%%, Mode: %s", 
            percentMagicka, spellData.magickaPercent, 
            spellData.magickaBlock and "Block when below" or "Allow only when below"))
        
        if spellData.magickaBlock then
            -- Block when magicka is below threshold
            if percentMagicka <= spellData.magickaPercent then
                DebugPrint("condition", "Resource Block: Magicka below threshold - Blocking")
                return true
            end
        else
            -- Allow only when magicka is below threshold (block when above)
            if percentMagicka > spellData.magickaPercent then
                DebugPrint("condition", "Resource Block: Magicka above threshold - Blocking")
                return true
            end
        end
    end
    
    -- 3. Stamina check
    if spellData.staminaCheck then
        local currentStamina, maxStamina, effStamina = GetUnitPower('player', COMBAT_MECHANIC_FLAGS_STAMINA)
        local percentStamina = (effStamina > 0) and (currentStamina / effStamina * 100) or 0
        
        DebugPrint("condition", string.format("Stamina Check: Current: %.1f%%, Threshold: %.1f%%, Mode: %s", 
            percentStamina, spellData.staminaPercent, 
            spellData.staminaBlock and "Block when below" or "Allow only when below"))
        
        if spellData.staminaBlock then
            -- Block when stamina is below threshold
            if percentStamina <= spellData.staminaPercent then
                DebugPrint("condition", "Resource Block: Stamina below threshold - Blocking")
                return true
            end
        else
            -- Allow only when stamina is below threshold (block when above)
            if percentStamina > spellData.staminaPercent then
                DebugPrint("condition", "Resource Block: Stamina above threshold - Blocking")
                return true
            end
        end
    end
        
    DebugPrint("condition", "Resource Block: No blocking conditions met")
    return false
end


-- =============================================================================
-- == ACTION SLOT PROCESSING ===================================================
-- =============================================================================
--[[
    Function: GetActionSlot
    Purpose: Extract slot from debug stack
    Methodology:
    - Parses debug.traceback() output
    - Matches ACTION_BUTTON_X pattern
    - Converts to numeric slot ID
--]]

--------------------------------------------------------------------------------
-- Debug-Based Slot Detection
-- @return: Action slot number (0-8)
--------------------------------------------------------------------------------

local function GetActionSlot()
    -- Extract slot from call stack trace
    --d('ActionButton Traceback'..debug.traceback():match('keybind = \".*ACTION_BUTTON_(%d)'))
    return tonumber(debug.traceback():match('keybind = \".*ACTION_BUTTON_(%d)')) or 0
end

-- =============================================================================
-- == CORE INPUT VALIDATION LOGIC ==============================================
-- =============================================================================
--[[
    Function: CanUseActionSlots
    Purpose: Main decision gatekeeper
    Process Flow:
    1. Check global blocking conditions
    2. Validate ability type
    3. Calculate latency compensationr
    4. Update state machine
    5. Make final allow/block decision
--]]

--------------------------------------------------------------------------------
-- Input Validation Master Function
-- @return: Boolean input permission
--------------------------------------------------------------------------------

local function CanUseActionSlots()

    AutoSelectGcdTrackingSlot()

    -- check for inactivity
    if timeSinceLastCast > 0 and (timeSinceLastCast + (PWSV.resetAfterSeconds * 1000)) < GetGameTimeMilliseconds() then
        ResetGCD()
        DebugPrint("block", "Reset due to inactivity after " .. PWSV.resetAfterSeconds .. " seconds")
    end

    -- Global block conditions
    local ignore = (PWSV.block and IsBlockActive()) or 
                (PWSV.combat and not IsUnitInCombat('player')) or 
                (PWSV.checkTarget and not IsUnitAttackable('reticleover'))
    
    -- Extract action details
    local slot = GetActionSlot()
    local id = GetSlotBoundId(slot)
    local isGround = CheckGroundAbility(id)
    local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', buffIndex)
    
    DebugPrint("info", "Buff"..abilityId)
    DebugPrint("info", "id "..id)

    -- Hard block exit
    if ignore and not PWSV.blockGroundAbilities then
        return false
    end

    -- if PWSV.blockAoEIfNoTarget and isGround and not DoesUnitExist('reticleover') then -- Dosen´t work!, will fix it later (Wish from kalitva) =================================================== 
    --     DebugPrint("condition", "Target check for AoE, Block AoE") 
    --     return true -- Block
    -- end

    -- Resource-Based Block List Check
    if PWSV.useCustomResourceBlockList and CheckResourceBlockList(id) then
        DebugPrint("condition", "Spell blocked by resource block list")
        return true
    end

    -- Custom Block List Check
    if PWSV.useCustomBlockList and PWSV.customBlockList[id] then
        DebugPrint("condition", "Custom Block List: Spell found in custom block list")
        
        -- Health check for Custom Block List
        if PWSV.useCustomBlockListHealthCheck then
            local currentHealth, maxHealth, effHealth = GetUnitPower('player', COMBAT_MECHANIC_FLAGS_HEALTH)
            local pecentHealth = currentHealth / effHealth * 100
            DebugPrint("condition", string.format("Custom Block List Health Check: HP Percent = %.1f%%, Threshold = %d%%", pecentHealth, PWSV.useCustomBlockListHealthPercent))
            
            if pecentHealth <= PWSV.useCustomBlockListHealthPercent then
                DebugPrint("condition", "Custom Block List: Health below threshold, NOT blocking")
                return false
            end
        end
        
        DebugPrint("condition", "Custom Block List: Spell blocked by custom block list")
        return true
    end


    -- Custom Recast Block List Check
    if PWSV.useCustomRecastBlockList and PWSV.customRecastBlockList[id] then
        DebugPrint("condition", "Custom Recast Block List: Spell found in custom recast block list")
        
        -- Health check for Custom Recast Block List
        if PWSV.useCustomRecastBlockListHealthCheck then
            local currentHealth, maxHealth, effHealth = GetUnitPower('player', COMBAT_MECHANIC_FLAGS_HEALTH)
            local pecentHealth = currentHealth / effHealth * 100
            DebugPrint("condition", string.format("Custom Recast Block List Health Check: HP Percent = %.1f%%, Threshold = %d%%", pecentHealth, PWSV.useCustomRecastBlockListHealthPercent))
            
            if pecentHealth <= PWSV.useCustomRecastBlockListHealthPercent then
                DebugPrint("condition", "Custom Recast Block List: Health below threshold, NOT blocking")
                return false
            end
        end
        
        local timeRemainingMS = GetActionSlotEffectTimeRemaining(slot)
        DebugPrint("condition", string.format("Custom Recast Block: timeRemainingMS = %d, threshold = %d", timeRemainingMS, PWSV.recastBlockTime * 1000))
        if timeRemainingMS > (PWSV.recastBlockTime * 1000) then
            DebugPrint("condition", "Custom Recast Block: Spell blocked by custom recast block list")
            return true
        end
    end

    -- PvP Deactivation Check
    local inPvPWorld = IsPlayerInAvAWorld() or IsActiveWorldBattleground()
    if PWSV.deactivateInPvP.features and inPvPWorld then
        DebugPrint("block", "disable features in PvP")
        return false
    end

    -- disable on backbar
    local ActiveWeaponPair, _ = GetActiveWeaponPairInfo()
    if (PWSV.deactivateOnBackbar.features  and (ActiveWeaponPair == 2)) or (PWSV.deactivateOnWeapon.features  and deactivateBasedOnWeapon()) then
        DebugPrint("block", "disable features")
        return false
    end

    -- Grim Focus block
    if (PWSV.grimFocusSkillIds[id] or PWSV.useGrimFocusStacks) and checkGrimFocus(id) then
        DebugPrint("condition", "Grim Focus block in CanUseActionSlots")
        return true
    end 

    -- Arca Beam
    -- d(PWSV.arcaBeamSkillIds[id] )
    -- Check Crux stacks
    if PWSV.arcaBeamSkillIds[id] and PWSV.useCruxStacks and checkCruxStacks(id) then
        DebugPrint("condition", "Check Crux stacks block in CanUseActionSlots")
        return true
    end 

    -- Cephaliarch's Flail
    if PWSV.cephaliarchsFlail[id] and PWSV.useCruxStacksCephaliarch and checkCruxStacksCephaliarch(id) then
        DebugPrint("condition", "Cephaliarch's Flail block in CanUseActionSlots")
        return true
    end

    -- Tentacular Dread
    if PWSV.tentacularDread[id] and PWSV.usecruxStacksTentacular and checkcruxStacksTentacular(id) then
        DebugPrint("condition", "Check Crux stacks block in CanUseActionSlots")
        return true
    end 

    -- Execute Check: Block spell until execute phase is reached
    if PWSV.useExecuteCheck and PWSV.executeCheckSpells[id] then
        DebugPrint("condition", string.format("Execute Check: Checking spell ID %d", id))
        if checkExecuteReady(id) then
            DebugPrint("condition", "Execute Check: Spell blocked by Execute Check")
            return false
        else
            DebugPrint("condition", "Execute Check: Spell permitted by Execute Check")
            return true
        end
    end

    -- Light Morphs & Hunter Morphs block in non-PvP areas
    if not (PWSV.deactivateHunterLightInPvP and inPvPWorld) then
        -- Mages Guild Light morphs block
        if PWSV.lightMorphs[id] or PWSV.hunterMorphs[id] then
            DebugPrint("condition", "Light/Hunter block")
            -- ResetGCD()
            return true
        end
    end

    if PWSV.MoltenWhip[id] then
        DebugPrint("condition", "MoltenWhip block")
        return true
    end
    
    if PWSV.mode == 4 and GCD_STAGE > 0 and not(GCD_STAGE == 3) and slot >= 3 and slot <= 8 then
        DebugPrint("condition", "GCD_STAGE block")
        return true
    end    

    -- Special case blocking
    if (ignore and not isGround) or IsBlockedNeverAbilityID(id) then
        return false
    end

    -- Latency calculations
    local cd, duration, global, globalSlotType = GetSlotCooldownInfo(PWSV.gcdTrackingSlot)
    DebugPrint("info", string.format(" remain %i , duration %i , global %s , globalSlotType %s", cd, duration, tostring(global), globalSlotType))
    local inputLag = PWSV.autoLag and zo_min(GetLatency() / 2 - 1, 300) or PWSV.inputLag
    local currentTime = GetGameTimeMilliseconds()

    -- State machine transitions
    if cd <= inputLag and currentTime > CHANNEL - inputLag then
        GCD_STAGE = (cd < 1 or GCD_STAGE < 4) and 0 or GCD_STAGE
    elseif cd > 0 and GCD_STAGE == 0 then
        GCD_STAGE = 1
    end

    -- Final decision matrix
    local allow = GCD_STAGE > 0 and 
                slot >= 3 and slot <= 8 and 
                (isGround or (not IsBlockedNeverAbilityID(id))) and 
                (GCD_STAGE >= 3 or PWSV.mode == 1 or isGround)
    

    -- Hard mode queuing
    if not allow and cd > 0 and (PWSV.mode == 1 or PWSV.mode == 4) then
        GCD_STAGE = 4
    end
    
    return allow

end

-- =============================================================================
-- == ABILITY USAGE HANDLER ====================================================
-- =============================================================================
--[[
    Function: AbilityUsed
    Purpose: Track ability activations
    Features:
    - Light Attack detection
    - Channel time calculation
    - Ability queuing states
--]]

--------------------------------------------------------------------------------
-- Ability Activation Handler
-- @param _: Unused event parameter
-- @param slot: Activated action slot
--------------------------------------------------------------------------------
local function AbilityUsed(_, slot)

    if PWSV.mode == 3 then 
        return
    end

    -- PvP Deactivation Check
    local inPvPWorld = IsPlayerInAvAWorld() or IsActiveWorldBattleground()
    if PWSV.deactivateInPvP.weaveAssist and inPvPWorld then
        DebugPrint("block", "disable Weave Assist in PvP")
        return
    end

    local ActiveWeaponPair, _ = GetActiveWeaponPairInfo()
    if (PWSV.deactivateOnBackbar.weaveAssist and (ActiveWeaponPair == 2)) or (PWSV.deactivateOnWeapon.weaveAssist and deactivateBasedOnWeapon()) then
        DebugPrint("block", "disable Weave Assist")
        return
    end

    -- Light Attack handling
    if slot == 1 then
        GCD_STAGE = 3  -- Set LA queued state
    -- Skill slot handling (3-8)
    elseif slot >= 3 and slot <= 8 then
        --local cd = GetSlotCooldownInfo(PWSV.gcdTrackingSlot)
        local cd, duration, global, globalSlotType = GetSlotCooldownInfo(PWSV.gcdTrackingSlot)
        DebugPrint("info", string.format(" remain %i , duration %i , global %s , globalSlotType %s", cd, duration, tostring(global), globalSlotType))
        GCD_STAGE = (cd < (PWSV.minGcdThreshold)) and 2 or 1
        
        local id = GetSlotBoundId(slot)
        local isChanneled, castTime = GetAbilityCastInfo(id)
        
        -- Channel time calculation
        if isChanneled or castTime > 0 then
            local buffer = isChanneled and PWSV.channelBufferChanneled 
                          or PWSV.channelBufferNormal
            CHANNEL = GetGameTimeMilliseconds() + 
                     zo_max(PWSV.baseQueueTime, castTime + buffer)
        else
            CHANNEL = 0  -- No channel time
        end
        
        LAST_ABILITY = id  -- Update ability memory
    end
    timeSinceLastCast = GetGameTimeMilliseconds()
end

-- =============================================================================
-- == ABILITY ADDITION TO LISTS FUNCTIONS ======================================
-- =============================================================================

--------------------------------------------------------------------------------
-- Add Ability to Block List
-- @param abilityId: The ID of the ability to add
-- @param abilityName: The name of the ability (for display)
--------------------------------------------------------------------------------
local function AddToBlockList(abilityId, abilityName)
    if not PWSV then return end
    
    PWSV.customBlockList[abilityId] = true
    d(string.format(
        '|c6D6D6D[Op|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve]|r |cFFFFFFAdded to Block List: |c00FF00%d|r|cFFFFFF - %s ("/reloadui" is required)|r', 
        abilityId, 
        abilityName
    ))
end

--------------------------------------------------------------------------------
-- Add Ability to Recast Block List
-- @param abilityId: The ID of the ability to add
-- @param abilityName: The name of the ability (for display)
--------------------------------------------------------------------------------
local function AddToRecastBlockList(abilityId, abilityName)
    if not PWSV then return end
    
    PWSV.customRecastBlockList[abilityId] = true
    d(string.format(
        '|c6D6D6D[Op|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve]|r |cFFFFFFAdded to Recast Block List: |c00FF00%d|r|cFFFFFF - %s ("/reloadui" is required)|r', 
        abilityId, 
        abilityName
    ))
end

--------------------------------------------------------------------------------
-- Add Ability to Resource Block List
-- @param abilityId: The ID of the ability to add
-- @param abilityName: The name of the ability (for display)
--------------------------------------------------------------------------------
local function AddToResourceBlockList(abilityId, abilityName)
    if not PWSV then return end
    
    -- Check if spell already exists in resource block list
    if PWSV.customResourceBlockList[abilityId] ~= nil then
        d(string.format(
            '|c6D6D6D[Op|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve]|r |cFFFFFFSpell already in Resource Block List: |c00FF00%d|r|cFFFFFF - %s|r', 
            abilityId, 
            abilityName
        ))
        return
    end
    
    -- Add Spell to resource block list with default structure
    PWSV.customResourceBlockList[abilityId] = {
        blocked = false,           -- Complete blocked
        magickaCheck = false,      -- If Magicka check is used
        magickaBlock = false,      -- Block when magicka below threshold (true=block, false=allow only)
        magickaPercent = 0,        -- Magicka percentage threshold
        staminaCheck = false,      -- If Stamina check is used
        staminaBlock = false,      -- Block when stamina below threshold (true=block, false=allow only)
        staminaPercent = 0,        -- Stamina percentage threshold
    }
    
    d(string.format(
        '|c6D6D6D[Op|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve]|r |cFFFFFFAdded to Resource Block List: |c00FF00%d|r|cFFFFFF - %s (configure resource checks in settings then "/reloadui")|r', 
        abilityId, 
        abilityName
    ))
end

-- =============================================================================
-- == ABILITY ID DISPLAY HOOKS =================================================
-- =============================================================================
--[[
    Function: SetupAbilityIDHooks
    Purpose:  Provides right-click context menu on action bar and assignable skill
              slots to display the underlying ability ID for debugging and configuration.
    Features: - Action bar slot right-click detection
              - Assignable skill slot menu integration
              - Formatted debug output with addon branding
              - Ability to add skills to block lists
--]]

--------------------------------------------------------------------------------
-- Action Bar Right-Click Hook
-- @description: Intercepts right-click events on action bar slots to display
--               ability ID in a context menu for debugging purposes
-- @features:   - Validates slot type and usage state
--              - Creates formatted debug output with colored addon name
--              - Integrates with ESO's custom menu system
--              - Allows adding abilities to block lists
--------------------------------------------------------------------------------
local function HookActionBarRightClick()
    ZO_PreHook("ZO_AbilitySlot_OnSlotClicked", function(abilitySlot, buttonId)
        if buttonId == MOUSE_BUTTON_INDEX_RIGHT then
            local button = ZO_ActionBar_GetButton(abilitySlot.slotNum)
            if button then
                local slotNum = button:GetSlot()
                if GetSlotType(slotNum) == ACTION_TYPE_ABILITY and 
                   IsSlotUsed(slotNum) and 
                   not IsSlotLocked(slotNum) then
                    
                    local abilityId = GetSlotBoundId(slotNum)
                    local abilityName = zo_strformat("<<1>>", GetAbilityName(abilityId))
                    
                    ClearMenu()
                    
                    local entries = {
                        {
                            label = "Show Ability ID",
                            callback = function()
                                d(string.format(
                                    "|c6D6D6D[Op|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve]|r |cFFFFFFAbility ID: |c00FF00%d|r|cFFFFFF - %s|r", 
                                    abilityId, 
                                    abilityName
                                ))
                            end
                        },
                        {
                            label = "Add to Block List",
                            callback = function()
                                AddToBlockList(abilityId, abilityName)
                            end
                        },
                        {
                            label = "Add to Recast Block List",
                            callback = function()
                                AddToRecastBlockList(abilityId, abilityName)
                            end
                        },
                        {
                            label = "Add to Resource Block List",
                            callback = function()
                                AddToResourceBlockList(abilityId, abilityName)
                            end
                        }
                    }
                    
                    AddCustomSubMenuItem("|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r", entries)
                    --AddCustomMenuTooltip("A sub-menu with ability options")
                    
                    ShowMenu(abilitySlot)
                    
                    return true
                end
            end
        end
    end)
end

--------------------------------------------------------------------------------
-- Assignable Skills Menu Hook
-- @description: Extends assignable skill slot context menus with ability ID
--               display functionality
-- @features:   - Integrates with ESO's skill assignment system
--              - Validates slot data existence and non-empty state
--              - Maintains original menu functionality while adding ID display
--              - Allows adding abilities to block lists
--------------------------------------------------------------------------------
local function HookAssignableSkillsMenu()
    ZO_PreHook(ZO_GamepadAssignableActionBarButton, "ShowActionMenu", function(self)
        local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbar()
        local slotData = hotbar:GetSlotData(self.slotId)
        
        if slotData and not slotData:IsEmpty() then
            local abilityId = GetSlotBoundId(self.slotId)
            local abilityName = zo_strformat("<<1>>", GetAbilityName(abilityId))
            
            ClearMenu()
            
            -- Alle Menüpunkte in ein Sub-Menü packen
            local entries = {
                {
                    label = "Show Ability ID",
                    callback = function()
                        d(string.format(
                            "|c6D6D6D[Op|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve]|r |cFFFFFFAbility ID: |c00FF00%d|r|cFFFFFF - %s|r", 
                            abilityId, 
                            abilityName
                        ))
                    end
                },
                {
                    label = "Add to Block List",
                    callback = function()
                        AddToBlockList(abilityId, abilityName)
                    end
                },
                {
                    label = "Add to Recast Block List",
                    callback = function()
                        AddToRecastBlockList(abilityId, abilityName)
                    end
                },
                {
                    label = "Add to Resource Block List",
                    callback = function()
                        AddToResourceBlockList(abilityId, abilityName)
                    end
                }
            }
            
            AddCustomSubMenuItem("|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r", entries)
            --AddCustomMenuTooltip("A sub-menu with ability options")
            
            ShowMenu(self.button)
            
            return true
        end
        return false
    end)
end

--------------------------------------------------------------------------------
-- Ability ID Display System Initialization
-- @function: SetupAbilityIDHooks
-- @description: Activates both action bar and assignable skill hooks
--               for unified ability ID debugging functionality
-- @calls:      HookActionBarRightClick(), HookAssignableSkillsMenu()
--------------------------------------------------------------------------------
local function SetupAbilityIDHooks()
    HookActionBarRightClick()
    HookAssignableSkillsMenu()
end


-- =============================================================================
-- == SYSTEM INITIALIZATION ====================================================
-- =============================================================================
--[[
    Function: Initialize
    Purpose: Addon bootstrap process
    Execution Flow:
    1. Load SavedVariables
    2. Register event handlers
    3. Hook into action system
    4. Build configuration menu
--]]

--------------------------------------------------------------------------------
-- Addon Initialization Routine
--------------------------------------------------------------------------------
local function Initialize()
    -- Load persistent settings
    PWSV = ZO_SavedVars:NewAccountWide('PerfectedWeaveSV', 1, nil, defaults)

    PW.TEMP_SPELL_ID = PW.TEMP_SPELL_ID or ""
    PW.TEMP_RECAST_SPELL_ID = PW.TEMP_RECAST_SPELL_ID or ""
    PW.TEMP_RESOURCE_SPELL_ID = PW.TEMP_RESOURCE_SPELL_ID or ""

    SetupAbilityIDHooks()

    -- Reset tracking
	EM:RegisterForEvent(NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, ResetGCDOnBarswap) 

    EM:RegisterForEvent(NAME, EVENT_COMBAT_EVENT, ResetGCDOnDodge)
    EM:AddFilterForEvent(NAME, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EM:AddFilterForEvent(NAME, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 28549) -- https://esoitem.uesp.net/viewSkillCoef.php

    EM:RegisterForEvent(NAME, EVENT_PLAYER_SWIMMING, ResetGCD)
    EM:RegisterForEvent(NAME, EVENT_PLAYER_DEAD, ResetGCD)
    EM:RegisterForEvent(NAME .."BLOCK", EVENT_COMBAT_EVENT, CastCanceled)

    -- Combat state tracking
    EM:RegisterForEvent(NAME .. "_INTERRUPT", EVENT_COMBAT_EVENT, OnPlayerStunned)
    EM:AddFilterForEvent(NAME .. "_INTERRUPT", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_INTERRUPT)
    EM:AddFilterForEvent(NAME .. "_INTERRUPT", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TAG, COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(NAME .. "_STUNNED", EVENT_COMBAT_EVENT, OnPlayerStunned)
    EM:AddFilterForEvent(NAME .. "_STUNNED", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_STUNNED)
    EM:AddFilterForEvent(NAME .. "_STUNNED", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TAG, COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(NAME .. "_FEARED", EVENT_COMBAT_EVENT, OnPlayerStunned)
    EM:AddFilterForEvent(NAME .. "_FEARED", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_FEARED)
    EM:AddFilterForEvent(NAME .. "_FEARED", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TAG, COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(NAME .. "_SILENCED", EVENT_COMBAT_EVENT, OnPlayerStunned)
    EM:AddFilterForEvent(NAME .. "_SILENCED", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_SILENCED)
    EM:AddFilterForEvent(NAME .. "_SILENCED", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TAG, COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(NAME .. "_KNOCKBACK", EVENT_COMBAT_EVENT, OnPlayerStunned)
    EM:AddFilterForEvent(NAME .. "_KNOCKBACK", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KNOCKBACK)
    EM:AddFilterForEvent(NAME .. "_KNOCKBACK", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TAG, COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(NAME .. "_OFFBALANCE", EVENT_COMBAT_EVENT, OnPlayerStunned)
    EM:AddFilterForEvent(NAME .. "_OFFBALANCE", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_OFFBALANCE)
    EM:AddFilterForEvent(NAME .. "_OFFBALANCE", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TAG, COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(NAME .. "_CHARMED", EVENT_COMBAT_EVENT, OnPlayerStunned)
    EM:AddFilterForEvent(NAME .. "_CHARMED", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_CHARMED)
    EM:AddFilterForEvent(NAME .. "_CHARMED", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TAG, COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(NAME .. "_SPRINTING", EVENT_COMBAT_EVENT, ResetGCD)
    EM:AddFilterForEvent(NAME .. "_SPRINTING", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_SPRINTING)
    EM:AddFilterForEvent(NAME .. "_SPRINTING", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TAG, COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, CheckRoleOverride)

    if PWSV.autoEquipWeapons then
        EM:RegisterForEvent(NAME .. "_EquipCombat", EVENT_PLAYER_COMBAT_STATE, EquipWeaponsStateChange)
        EM:RegisterForEvent(NAME .. "_EquipBook", EVENT_HIDE_BOOK, EquipWeaponsStateChange)
        EM:RegisterForEvent(NAME .. "_EquipCrafting", EVENT_END_CRAFTING_STATION_INTERACT, EquipWeaponsStateChange)
        EM:RegisterForEvent(NAME .. "_EquipChat", EVENT_CHATTER_END, EquipWeaponsStateChange)
        EM:RegisterForEvent(NAME .. "_EquipStore", EVENT_CLOSE_STORE, EquipWeaponsStateChange)
        EM:RegisterForEvent(NAME .. "_EquipAlive", EVENT_PLAYER_ALIVE, EquipWeaponsStateChange)
        EM:RegisterForEvent(NAME .. "_EquipLoot", EVENT_LOOT_CLOSED, EquipWeaponsStateChange)
        EM:RegisterForEvent(NAME .. "_EquipActivated", EVENT_PLAYER_ACTIVATED, EquipWeaponsStateChange)
        EM:RegisterForEvent(NAME .. "_EquipSwimming", EVENT_PLAYER_NOT_SWIMMING, EquipWeaponsStateChange)
        EM:RegisterForEvent(NAME .. "_EquipInteraction", EVENT_INTERACTION_ENDED, EquipWeaponsStateChange)
    end    

    -- Action system integration
    EM:RegisterForEvent(NAME, EVENT_ACTION_SLOT_ABILITY_USED, AbilityUsed)
    ZO_PreHook("ZO_ActionBar_CanUseActionSlots", CanUseActionSlots)
    -- Menu system initialization
    PW.BuildMenu(PWSV, defaults)
   
end

-- =============================================================================
-- == EVENT REGISTRATION & BOOTSTRAPPING =======================================
-- =============================================================================
--[[
    Event: EVENT_ADD_ON_LOADED
    Purpose: Safe addon initialization
    Features:
    - Self-unregistering after load
    - Namespace validation
--]]
EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, function(event, addonName)
    -- Validate addon load
    if addonName == NAME then
        EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        Initialize()  -- Start addon
    end
end)

-- =============================================================================
-- === END OF PERFECTEDWEAVE CORE ================================================
-- =============================================================================