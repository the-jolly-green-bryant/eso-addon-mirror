-- Beltalowda Group Ultimate Display By Roles
-- Phase 2: Uncoupled ultimate tracker organized by role (Damage/Support/Pull)
-- Shows player bars with ultimate icon, name, percentage, and resource bars

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.GroupUltimateDisplayByRoles = Beltalowda.UI.GroupUltimateDisplayByRoles or {}

local GUDBR = Beltalowda.UI.GroupUltimateDisplayByRoles
local GUD = Beltalowda.UI.GroupUltimateDisplay
local wm = WINDOW_MANAGER

-- Constants
GUDBR.PLAYER_BAR_WIDTH = 180
GUDBR.PLAYER_BAR_HEIGHT = 41  -- Total height of player bar (increased for ultimate bar)
GUDBR.ICON_SIZE = 36           -- Scale icon down to match bar height
GUDBR.RESOURCE_BAR_HEIGHT = 5
GUDBR.COMBAT_BORDER_WIDTH = 2
GUDBR.WINDOW_PADDING = 8
GUDBR.HEADER_HEIGHT = 24
GUDBR.HEADER_ICON_SIZE = 18  -- Size of role icon shown in column headers
GUDBR.DEFAULT_ABILITY_NAME = "Unknown"
GUDBR.DEFAULT_ABILITY_ICON = "/esoui/art/icons/ability_default.dds"

-- Role categorization constants
-- Display order: Damage | Shields | Heals | Utility
GUDBR.ROLE_UTILITY = 1
GUDBR.ROLE_DAMAGE = 2
GUDBR.ROLE_HEALS = 3
GUDBR.ROLE_SHIELDS = 4

-- Representative icons for each role category (matches GUD.ROLE_ALL_ICONS)
GUDBR.ROLE_HEADER_ICONS = {
    [GUDBR.ROLE_DAMAGE]  = "esoui/art/icons/powerpellet_health.dds",
    [GUDBR.ROLE_HEALS]   = "esoui/art/icons/powerpellet_stamina.dds",
    [GUDBR.ROLE_SHIELDS]  = "esoui/art/icons/powerpellet_magicka.dds",
    [GUDBR.ROLE_UTILITY] = "esoui/art/icons/procs_001.dds",
}

-- Ultimate ability categorization by role (base ability IDs and morphs)
-- Categories: Damage, Heals, Shields, Utility
GUDBR.ULTIMATE_ROLES = {
    -- Damage Ultimates
    [189791]  = GUDBR.ROLE_DAMAGE,  -- The Unblinking Eye, Arcanist, Herald of the Tome
    [189837]  = GUDBR.ROLE_DAMAGE,  -- The Tide King's Gaze, Arcanist, Herald of the Tome
    [189867]  = GUDBR.ROLE_DAMAGE,  -- The Languid Eye, Arcanist, Herald of the Tome
    [28988]   = GUDBR.ROLE_DAMAGE,  -- Dragonknight Standard, Dragonknight, Ardent Flame
    [32958]   = GUDBR.ROLE_DAMAGE,  -- Shifting Standard, Dragonknight, Ardent Flame
    [32947]   = GUDBR.ROLE_DAMAGE,  -- Standard of Might, Dragonknight, Ardent Flame
    [29012]   = GUDBR.ROLE_DAMAGE,  -- Dragon Leap, Dragonknight, Draconic Power
    [32719]   = GUDBR.ROLE_DAMAGE,  -- Take Flight, Dragonknight, Draconic Power
    [32715]   = GUDBR.ROLE_DAMAGE,  -- Ferocious Leap, Dragonknight, Draconic Power
    [15957]   = GUDBR.ROLE_DAMAGE,  -- Magma Armor, Dragonknight, Earthen Heart
    [17878]   = GUDBR.ROLE_DAMAGE,  -- Corrosive Armor, Dragonknight, Earthen Heart
    [183676]  = GUDBR.ROLE_SHIELDS, -- Gibbering Shield, Arcanist, Soldier of Apocrypha (overridden by gibberingAsDamage setting)
    [192372]  = GUDBR.ROLE_SHIELDS, -- Sanctum of the Abyssal Sea, Arcanist, Soldier of Apocrypha (overridden by gibberingAsDamage setting)
    [122174]  = GUDBR.ROLE_DAMAGE,  -- Frozen Colossus, Necromancer, Grave Lord
    [122395]  = GUDBR.ROLE_DAMAGE,  -- Pestilent Colossus, Necromancer, Grave Lord
    [122388]  = GUDBR.ROLE_DAMAGE,  -- Glacial Colossus, Necromancer, Grave Lord
    [33398]   = GUDBR.ROLE_DAMAGE,  -- Death Stroke, Nightblade, Assassination
    [113105]  = GUDBR.ROLE_DAMAGE,  -- Incapacitating Strike, Nightblade, Assassination
    [36514]   = GUDBR.ROLE_DAMAGE,  -- Soul Harvest, Nightblade, Assassination
    [25091]   = GUDBR.ROLE_DAMAGE,  -- Soul Shred, Nightblade, Siphoning
    [35460]   = GUDBR.ROLE_DAMAGE,  -- Soul Tether, Nightblade, Siphoning
    [23634]   = GUDBR.ROLE_DAMAGE,  -- Summon Storm Atronach, Sorcerer, Daedric Summoning
    [23492]   = GUDBR.ROLE_DAMAGE,  -- Greater Storm Atronach, Sorcerer, Daedric Summoning
    [23495]   = GUDBR.ROLE_DAMAGE,  -- Summon Charged Atronach, Sorcerer, Daedric Summoning
    [24785]   = GUDBR.ROLE_DAMAGE,  -- Overload, Sorcerer, Storm Calling
    [24806]   = GUDBR.ROLE_DAMAGE,  -- Power Overload, Sorcerer, Storm Calling
    [24804]   = GUDBR.ROLE_DAMAGE,  -- Energy Overload, Sorcerer, Storm Calling
    [22138]   = GUDBR.ROLE_DAMAGE,  -- Radial Sweep, Templar, Aedric Spear
    [22144]   = GUDBR.ROLE_DAMAGE,  -- Everlasting Sweep, Templar, Aedric Spear
    [22139]   = GUDBR.ROLE_DAMAGE,  -- Crescent Sweep, Templar, Aedric Spear
    [21752]   = GUDBR.ROLE_DAMAGE,  -- Nova, Templar, Dawn's Wrath
    [21755]   = GUDBR.ROLE_DAMAGE,  -- Solar Prison, Templar, Dawn's Wrath
    [21758]   = GUDBR.ROLE_DAMAGE,  -- Solar Disturbance, Templar, Dawn's Wrath
    [85982]   = GUDBR.ROLE_DAMAGE,  -- Feral Guardian, Warden, Animal Companions
    [85986]   = GUDBR.ROLE_DAMAGE,  -- Eternal Guardian, Warden, Animal Companions
    [85990]   = GUDBR.ROLE_DAMAGE,  -- Wild Guardian, Warden, Animal Companions
    [86109]   = GUDBR.ROLE_DAMAGE,  -- Sleet Storm, Warden, Winter's Embrace
    [86113]   = GUDBR.ROLE_DAMAGE,  -- Northern Storm, Warden, Winter's Embrace
    [86117]   = GUDBR.ROLE_DAMAGE,  -- Permafrost, Warden, Winter's Embrace
    [83465]   = GUDBR.ROLE_DAMAGE,  -- Rapid Fire, Bow
    [85257]   = GUDBR.ROLE_DAMAGE,  -- Toxic Barrage, Bow
    [85451]   = GUDBR.ROLE_DAMAGE,  -- Ballista, Bow

    -- Destruction Staff (base morphs + all element-specific variants)
    [83619]   = GUDBR.ROLE_DAMAGE,  -- Elemental Storm, Destruction Staff
    [83625]   = GUDBR.ROLE_DAMAGE,  -- Fire Storm, Destruction Staff (fire)
    [83628]   = GUDBR.ROLE_DAMAGE,  -- Ice Storm, Destruction Staff (ice)
    [83630]   = GUDBR.ROLE_DAMAGE,  -- Thunder Storm, Destruction Staff (lightning)
    [84434]   = GUDBR.ROLE_DAMAGE,  -- Elemental Rage, Destruction Staff
    [85126]   = GUDBR.ROLE_DAMAGE,  -- Fiery Rage, Destruction Staff (fire)
    [85128]   = GUDBR.ROLE_DAMAGE,  -- Icy Rage, Destruction Staff (ice)
    [85130]   = GUDBR.ROLE_DAMAGE,  -- Thunderous Rage, Destruction Staff (lightning)
    [83642]   = GUDBR.ROLE_DAMAGE,  -- Eye of the Storm, Destruction Staff
    [83682]   = GUDBR.ROLE_DAMAGE,  -- Eye of Flame, Destruction Staff (fire)
    [83684]   = GUDBR.ROLE_DAMAGE,  -- Eye of Frost, Destruction Staff (ice)
    [83686]   = GUDBR.ROLE_DAMAGE,  -- Eye of Lightning, Destruction Staff (lightning)
    
    [83600]   = GUDBR.ROLE_DAMAGE,  -- Lacerate, Dual Wield
    [85179]   = GUDBR.ROLE_DAMAGE,  -- Thrive in Chaos, Dual Wield
    [85187]   = GUDBR.ROLE_DAMAGE,  -- Rend, Dual Wield
    [83216]   = GUDBR.ROLE_DAMAGE,  -- Berserker Strike, 2H
    [83229]   = GUDBR.ROLE_DAMAGE,  -- Onslaught, 2H
    [83238]   = GUDBR.ROLE_DAMAGE,  -- Berserker Rage, 2H
    [35713]   = GUDBR.ROLE_DAMAGE,  -- Dawnbreaker, Fighter's Guild
    [40161]   = GUDBR.ROLE_DAMAGE,  -- Flawless Dawnbreaker, Fighter's Guild
    [40158]   = GUDBR.ROLE_DAMAGE,  -- Dawnbreaker of Smiting, Fighter's Guild
    [16536]   = GUDBR.ROLE_DAMAGE,  -- Meteor, Mage's Guild
    [40489]   = GUDBR.ROLE_DAMAGE,  -- Ice Comet, Mage's Guild
    [40493]   = GUDBR.ROLE_DAMAGE,  -- Shooting Star, Mage's Guild
    [39270]   = GUDBR.ROLE_DAMAGE,  -- Soul Strike, Soul Magic
    [40420]   = GUDBR.ROLE_DAMAGE,  -- Soul Assault, Soul Magic
    [40414]   = GUDBR.ROLE_DAMAGE,  -- Shatter Soul, Soul Magic

    -- Heal Ultimates
    [183709]  = GUDBR.ROLE_HEALS,   -- Vitalizing Glyphic, Arcanist, Curative Runeforms
    [193764]  = GUDBR.ROLE_HEALS,   -- Glyphic of the Tides, Arcanist, Curative Runeforms
    [193558]  = GUDBR.ROLE_HEALS,   -- Resonating Glyphic, Arcanist, Curative Runeforms
    [35508]   = GUDBR.ROLE_HEALS,   -- Soul Siphon, Nightblade, Siphoning
    [22223]   = GUDBR.ROLE_HEALS,   -- Rite of Passage, Templar, Restoring Light
    [22229]   = GUDBR.ROLE_HEALS,   -- Remembrance, Templar, Restoring Light
    [22226]   = GUDBR.ROLE_HEALS,   -- Practiced Incantation, Templar, Restoring Light
    [85532]   = GUDBR.ROLE_HEALS,   -- Secluded Grove, Warden, Green Balance
    [85804]   = GUDBR.ROLE_HEALS,   -- Enchanted Forest, Warden, Green Balance
    [85807]   = GUDBR.ROLE_HEALS,   -- Healing Thicket, Warden, Green Balance
    [83552]   = GUDBR.ROLE_HEALS,   -- Panacea, Healing Staff
    [83850]   = GUDBR.ROLE_HEALS,   -- Life Giver, Healing Staff
    [85132]   = GUDBR.ROLE_HEALS,   -- Light's Champion, Healing Staff
    
    -- Shield Ultimates
    [192380]  = GUDBR.ROLE_SHIELDS, -- Gibbering Shelter, Arcanist, Soldier of Apocrypha
    [17874]   = GUDBR.ROLE_SHIELDS, -- Magma Shell, Dragonknight, Earthen Heart
    [115001]  = GUDBR.ROLE_SHIELDS, -- Bone Goliath Transformation, Necromancer, Bone Tyrant
    [118664]  = GUDBR.ROLE_SHIELDS, -- Pummeling Goliath, Necromancer, Bone Tyrant
    [118279]  = GUDBR.ROLE_SHIELDS, -- Ravenous Goliath, Necromancer, Bone Tyrant
    [38573]   = GUDBR.ROLE_SHIELDS, -- Barrier, Support
    [40237]   = GUDBR.ROLE_SHIELDS, -- Reviving Barrier, Support
    [40239]   = GUDBR.ROLE_SHIELDS, -- Replenishing Barrier, Support

    -- Utility Ultimates
    [115410]  = GUDBR.ROLE_UTILITY, -- Reanimate, Necromancer, Living Death
    [118367]  = GUDBR.ROLE_UTILITY, -- Renewing Animation, Necromancer, Living Death
    [118379]  = GUDBR.ROLE_UTILITY, -- Animate Blastbones, Necromancer, Living Death
    [25411]   = GUDBR.ROLE_UTILITY, -- Consuming Darkness, Nightblade, Shadow
    [36493]   = GUDBR.ROLE_UTILITY, -- Bolstering Darkness, Nightblade, Shadow
    [36485]   = GUDBR.ROLE_UTILITY, -- Veil of Blades, Nightblade, Shadow
    [27706]   = GUDBR.ROLE_UTILITY, -- Negate Magic, Sorcerer, Dark Magic
    [28341]   = GUDBR.ROLE_UTILITY, -- Suppression Field, Sorcerer, Dark Magic
    [28348]   = GUDBR.ROLE_UTILITY, -- Absorption Field, Sorcerer, Dark Magic
    [83272]   = GUDBR.ROLE_UTILITY, -- Shield Wall, 1H & Shield
    [83292]   = GUDBR.ROLE_UTILITY, -- Spell Wall, 1H & Shield
    [83310]   = GUDBR.ROLE_UTILITY, -- Shield Discipline, 1H & Shield
    [103478]  = GUDBR.ROLE_UTILITY, -- Undo, Psijic Order
    [103557]  = GUDBR.ROLE_UTILITY, -- Precognition, Psijic Order
    [103564]  = GUDBR.ROLE_UTILITY, -- Temporal Guard, Psijic Order
    [38563]   = GUDBR.ROLE_UTILITY, -- War Horn
    [40223]   = GUDBR.ROLE_UTILITY, -- Aggressive Horn
    [40220]   = GUDBR.ROLE_UTILITY, -- Sturdy Horn
    [32624]   = GUDBR.ROLE_UTILITY, -- Blood Scion, Vampire
    [38932]   = GUDBR.ROLE_UTILITY, -- Swarming Scion, Vampire
    [38931]   = GUDBR.ROLE_UTILITY, -- Perfect Scion, Vampire
    [32455]   = GUDBR.ROLE_UTILITY, -- Werewolf Transformation, Werewolf
    [39075]   = GUDBR.ROLE_UTILITY, -- Pack Leader, Werewolf
    [39076]   = GUDBR.ROLE_UTILITY, -- Werewolf Berserker, Werewolf
    [195031]  = GUDBR.ROLE_UTILITY, -- Crypt Transfer (Cryptcannon Vestments mythic)

    -- Artifact Ultimates
    [116096]  = GUDBR.ROLE_DAMAGE,  -- Ruinous Cyclone (Volendrung)
}

-- Reanimate ability IDs (Necromancer Living Death skill line)
-- Used by smart ult tracking to detect backbar Reanimate
GUDBR.REANIMATE_IDS = {
    [115410] = true,  -- Reanimate
    [118367] = true,  -- Renewing Animation
    [118379] = true,  -- Animate Blastbones
}

-- Cryptcannon Vestments (Crypt Transfer) - mythic item special case (#121)
-- Replaces ultimate with Crypt Transfer which can be cast at any ult > 0.
-- We fake the cost as 500 so the bar fills gradually (0-500 ult range).
GUDBR.CRYPTCANNON_ID = 195031
GUDBR.CRYPTCANNON_FAKE_COST = 500

-- Role window data
GUDBR.roleWindows = {
    [GUDBR.ROLE_UTILITY] = nil,
    [GUDBR.ROLE_DAMAGE] = nil,
    [GUDBR.ROLE_HEALS] = nil,
    [GUDBR.ROLE_SHIELDS] = nil,
}

-- Parent container for coupled mode
GUDBR.coupledContainer = nil

-- Menu visibility state (set by centralized layer handler)
GUDBR.menuHidden = false

-- PvP visibility state (set by centralized PvP zone handler)
GUDBR.pvpHidden = false

-- Settings version
GUDBR.SETTINGS_VERSION = 5  -- Version 5: preventMovement replaces locked, dynamicVisibility

--[[
    Set menu-hidden state (called by centralized layer handler)
]]--
function GUDBR.SetMenuHidden(hidden)
    GUDBR.menuHidden = hidden
    GUDBR.ApplySettings()
    -- When becoming visible again, immediately refresh to apply dynamic
    -- visibility and relayout coupled windows.  Without this, ApplySettings
    -- shows all role windows at their static positions (including empty ones)
    -- and the periodic RefreshDisplay timer can take up to 5 s to correct it.
    if not hidden and (GUDBR.settings.dynamicVisibility or GUDBR.settings.hideEmptyColumns) then
        GUDBR.RefreshDisplay()
    end
end

--[[
    Set PvP-hidden state (called by centralized PvP zone handler)
]]--
function GUDBR.SetPvPHidden(hidden)
    GUDBR.pvpHidden = hidden
    GUDBR.ApplySettings()
    if not hidden and (GUDBR.settings.dynamicVisibility or GUDBR.settings.hideEmptyColumns) then
        GUDBR.RefreshDisplay()
    end
end

-- Settings (will be saved to SavedVariables)
GUDBR.settings = {
    enabled = true,  -- Enabled by default - role-based tracker is the primary view
    
    -- Prevent movement (default OFF = allow free dragging)
    preventMovement = false,
    
    -- Dynamic visibility: auto-hide empty ult categories and squish together
    -- When false, manual showUtility/showDamage/etc toggles are used
    dynamicVisibility = false,
    
    -- UI scale and opacity
    scale = 0.7907,
    opacity = 1.0,
    
    -- Hide category headers to save space
    hideHeaders = false,
    -- Hide empty columns (auto-squish)
    hideEmptyColumns = false,
    
    -- Individual decouple toggles: when false, window is coupled to the main group
    -- When true, window is decoupled and can be positioned independently
    utilityDecoupled = false,
    damageDecoupled = false,
    healsDecoupled = false,
    shieldsDecoupled = false,
    
    -- Coupled container position (used when windows are coupled)
    coupledPositionX = 800,
    coupledPositionY = 400,
    
    -- Gibbering classification
    gibberingAsDamage = false,  -- When true, treat Gibbering Shield + Sanctum of the Abyssal Sea as Damage instead of Shields

    -- Smart ult tracking (#87)
    smartDamageUpgrade = true,   -- Swap damage ult icon to expensive ult when affordable
    ignoreSoulHarvest = true,    -- Exclude Soul Harvest from damage upgrade logic (slotted for passive)
    reanimateTracking = true,    -- Show players in Utility when backbar Reanimate is affordable
    reanimateDisplayMode = "both", -- "both" = show in Damage AND Utility, "switch" = move to Utility
    showOriginalUltAsMain = false, -- When true, keep original ult as main icon, show upgrade in overlay

    -- Window visibility
    showUtility = true,
    showDamage = true,
    showHeals = true,
    showShields = true,
    
    -- Individual window positions (only used when decoupled)
    utilityPositionX = 800,
    utilityPositionY = 300,
    damagePositionX = 800,
    damagePositionY = 450,
    healsPositionX = 800,
    healsPositionY = 600,
    shieldsPositionX = 800,
    shieldsPositionY = 750,
}

-- Player bars by role
GUDBR.playerBars = {
    [GUDBR.ROLE_UTILITY] = {},
    [GUDBR.ROLE_DAMAGE] = {},
    [GUDBR.ROLE_HEALS] = {},
    [GUDBR.ROLE_SHIELDS] = {},
}

-- Cache for playerName to unitTag mapping (updated when group composition changes)
GUDBR.unitTagCache = {}

-- Soul Harvest ability IDs – excluded from damage upgrade logic when ignoreSoulHarvest is on.
-- Soul Harvest is typically slotted for its passive (increased ult gen on kill), not for casting.
GUDBR.SOUL_HARVEST_IDS = {
    [36514] = true,   -- Soul Harvest (morph)
}

-- Track if update event is registered
GUDBR.updateRegistered = false

-- Drag state for coupled container
GUDBR.isDragging = false

-- ============================================================================
-- Smart Ultimate Upgrade Helpers (#87)
-- ============================================================================

--[[
    Derive raw ultimate value from broadcast data.
    Prefers percentage-derived value (freshest from 2s broadcast cycle),
    falls back to LGCS raw value which may be slightly stale.
]]--
function GUDBR.GetRawUltValue(data)
    -- Derive from broadcast percentage + selected ult cost (freshest data)
    if data.ultimatePercent and data.selectedUltimateId and data.selectedUltimateId > 0 then
        -- Cryptcannon Vestments (#121): GetAbilityCost returns 0 for Crypt Transfer,
        -- use fake cost of 500 for the reverse percentage→value calculation
        local cost
        if data.selectedUltimateId == GUDBR.CRYPTCANNON_ID then
            cost = GUDBR.CRYPTCANNON_FAKE_COST
        else
            cost = GetAbilityCost(data.selectedUltimateId)
        end
        if cost and cost > 0 then
            return math.floor((data.ultimatePercent / 100) * cost)
        end
    end

    -- Fall back to LGCS raw value (may be slightly stale)
    if data.currentUlt then
        return data.currentUlt
    end

    return 0
end

--[[
    Check if a damage player's display should upgrade to their expensive ult.
    Returns displayUltId, displayPercent if upgrade scenario exists, nil otherwise.

    When a player has two damage ults with different costs (e.g. Take Flight 118
    + Eye of Frost 235), this shows the expensive ult icon when they can afford
    it and the cheap ult icon when they can't. This lets raid leads see at a
    glance who is ready for their big damage ult.
]]--
function GUDBR.GetDamageUpgradeInfo(data)
    local frontId = data.frontbarUltimateId
    local backId = data.backbarUltimateId

    -- Need both bar IDs
    if not frontId or frontId <= 0 or not backId or backId <= 0 then
        return nil
    end

    -- Both must be damage ults
    if GUDBR.ULTIMATE_ROLES[frontId] ~= GUDBR.ROLE_DAMAGE or GUDBR.ULTIMATE_ROLES[backId] ~= GUDBR.ROLE_DAMAGE then
        return nil
    end

    -- Exclude Soul Harvest from upgrade logic (slotted for passive, not for casting)
    if GUDBR.settings.ignoreSoulHarvest then
        if GUDBR.SOUL_HARVEST_IDS[frontId] or GUDBR.SOUL_HARVEST_IDS[backId] then
            return nil
        end
    end

    -- Same ult on both bars = no upgrade scenario
    if frontId == backId then
        return nil
    end

    -- Get costs
    local frontCost = GetAbilityCost(frontId) or 0
    local backCost = GetAbilityCost(backId) or 0

    -- Need valid costs and they must differ
    if frontCost <= 0 or backCost <= 0 or frontCost == backCost then
        return nil
    end

    -- Determine cheap vs expensive
    local cheapId, cheapCost, expensiveId, expensiveCost
    if frontCost < backCost then
        cheapId, cheapCost = frontId, frontCost
        expensiveId, expensiveCost = backId, backCost
    else
        cheapId, cheapCost = backId, backCost
        expensiveId, expensiveCost = frontId, frontCost
    end

    -- Derive raw ultimate value
    local rawUlt = GUDBR.GetRawUltValue(data)

    -- Show expensive ult when affordable, cheap ult otherwise
    if rawUlt >= expensiveCost then
        local pct = math.min(500, (rawUlt / expensiveCost) * 100)
        return expensiveId, pct
    else
        local pct = math.min(500, (rawUlt / cheapCost) * 100)
        return cheapId, pct
    end
end

--[[
    Check if a player has Reanimate on a bar and can afford it.
    Returns reanimateId, reanimatePct if applicable, nil otherwise.

    Necromancers often run a damage ult on front bar with Reanimate on back.
    When they have enough ult to cast Reanimate, the raid lead needs to see
    this in the Utility window (since Reanimate rezzes 3 dead players).
]]--
function GUDBR.GetReanimateUpgradeInfo(data)
    local frontId = data.frontbarUltimateId
    local backId = data.backbarUltimateId

    -- Need both bar IDs
    if not frontId or frontId <= 0 or not backId or backId <= 0 then
        return nil
    end

    -- Find which bar has Reanimate (must be on exactly one bar, not both)
    local reanimateId = nil

    if GUDBR.REANIMATE_IDS[backId] and not GUDBR.REANIMATE_IDS[frontId] then
        reanimateId = backId
    elseif GUDBR.REANIMATE_IDS[frontId] and not GUDBR.REANIMATE_IDS[backId] then
        reanimateId = frontId
    end

    if not reanimateId then
        return nil
    end

    -- If Reanimate is already the selected (auto-detected) ult, they
    -- already show in Utility normally - no upgrade needed
    if data.selectedUltimateId == reanimateId then
        return nil
    end

    -- Check affordability
    local reanimateCost = GetAbilityCost(reanimateId) or 0
    if reanimateCost <= 0 then
        return nil
    end

    local rawUlt = GUDBR.GetRawUltValue(data)
    if rawUlt < reanimateCost then
        return nil  -- Can't afford Reanimate yet
    end

    -- Affordable: return upgrade info
    local pct = math.min(500, (rawUlt / reanimateCost) * 100)
    return reanimateId, pct
end

--[[
    Initialize the Group Ultimate Display By Roles UI
]]--
function GUDBR.Initialize()
    if GUDBR.initialized then return end
    
    -- Load settings from SavedVariables
    GUDBR.LoadSettings()
    
    -- Create role windows
    GUDBR.CreateRoleWindows()
    
    -- Apply saved settings
    GUDBR.ApplySettings()
    
    -- Register for data updates
    GUDBR.RegisterForUpdates()
    
    GUDBR.initialized = true
    return true
end

--[[
    Load settings from SavedVariables
]]--
function GUDBR.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.groupUltimateDisplayByRoles = BeltalowdaVars.ui.groupUltimateDisplayByRoles or {}
    
    local saved = BeltalowdaVars.ui.groupUltimateDisplayByRoles
    
    -- Load or set defaults (match the initial settings table defaults)
    GUDBR.settings.enabled = (saved.enabled ~= nil) and saved.enabled or true
    
    -- Migrate old 'locked' to 'preventMovement'
    if saved.preventMovement ~= nil then
        GUDBR.settings.preventMovement = saved.preventMovement
    elseif saved.locked ~= nil then
        GUDBR.settings.preventMovement = saved.locked
    else
        GUDBR.settings.preventMovement = false
    end
    
    -- Dynamic visibility (default OFF = manual mode)
    GUDBR.settings.dynamicVisibility = (saved.dynamicVisibility ~= nil) and saved.dynamicVisibility or false
    
    -- UI scale and opacity
    GUDBR.settings.scale = saved.scale or 0.7907
    GUDBR.settings.opacity = saved.opacity or 1.0
    
    -- Hide headers
    GUDBR.settings.hideHeaders = (saved.hideHeaders ~= nil) and saved.hideHeaders or false
    GUDBR.settings.hideEmptyColumns = (saved.hideEmptyColumns ~= nil) and saved.hideEmptyColumns or false
    
    -- Individual decouple toggles
    GUDBR.settings.utilityDecoupled = (saved.utilityDecoupled ~= nil) and saved.utilityDecoupled or false
    GUDBR.settings.damageDecoupled = (saved.damageDecoupled ~= nil) and saved.damageDecoupled or false
    GUDBR.settings.healsDecoupled = (saved.healsDecoupled ~= nil) and saved.healsDecoupled or false
    GUDBR.settings.shieldsDecoupled = (saved.shieldsDecoupled ~= nil) and saved.shieldsDecoupled or false
    
    -- Coupled container position
    GUDBR.settings.coupledPositionX = saved.coupledPositionX or 800
    GUDBR.settings.coupledPositionY = saved.coupledPositionY or 400
    
    -- Gibbering classification
    GUDBR.settings.gibberingAsDamage = (saved.gibberingAsDamage ~= nil) and saved.gibberingAsDamage or false
    GUDBR.ApplyGibberingClassification()

    -- Smart ult tracking (#87)
    GUDBR.settings.smartDamageUpgrade = (saved.smartDamageUpgrade ~= nil) and saved.smartDamageUpgrade or true
    GUDBR.settings.ignoreSoulHarvest = (saved.ignoreSoulHarvest ~= nil) and saved.ignoreSoulHarvest or true
    GUDBR.settings.reanimateTracking = (saved.reanimateTracking ~= nil) and saved.reanimateTracking or true
    GUDBR.settings.reanimateDisplayMode = saved.reanimateDisplayMode or "both"
    GUDBR.settings.showOriginalUltAsMain = (saved.showOriginalUltAsMain ~= nil) and saved.showOriginalUltAsMain or false
    
    -- Window visibility
    GUDBR.settings.showUtility = (saved.showUtility ~= nil) and saved.showUtility or true
    GUDBR.settings.showDamage = (saved.showDamage ~= nil) and saved.showDamage or true
    GUDBR.settings.showHeals = (saved.showHeals ~= nil) and saved.showHeals or true
    GUDBR.settings.showShields = (saved.showShields ~= nil) and saved.showShields or true
    
    -- Individual window positions (used in decoupled mode)
    GUDBR.settings.utilityPositionX = saved.utilityPositionX or 800
    GUDBR.settings.utilityPositionY = saved.utilityPositionY or 300
    GUDBR.settings.damagePositionX = saved.damagePositionX or 800
    GUDBR.settings.damagePositionY = saved.damagePositionY or 450
    GUDBR.settings.healsPositionX = saved.healsPositionX or 800
    GUDBR.settings.healsPositionY = saved.healsPositionY or 600
    GUDBR.settings.shieldsPositionX = saved.shieldsPositionX or 800
    GUDBR.settings.shieldsPositionY = saved.shieldsPositionY or 750
end

--[[
    Save settings to SavedVariables
]]--
function GUDBR.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    
    BeltalowdaVars.ui.groupUltimateDisplayByRoles = {
        version = GUDBR.SETTINGS_VERSION,
        enabled = GUDBR.settings.enabled,
        
        -- Movement prevention
        preventMovement = GUDBR.settings.preventMovement,
        
        -- Dynamic visibility
        dynamicVisibility = GUDBR.settings.dynamicVisibility,
        
        -- UI scale and opacity
        scale = GUDBR.settings.scale,
        opacity = GUDBR.settings.opacity,
        
        -- Hide headers
        hideHeaders = GUDBR.settings.hideHeaders,
        hideEmptyColumns = GUDBR.settings.hideEmptyColumns,
        
        -- Individual decouple toggles
        utilityDecoupled = GUDBR.settings.utilityDecoupled,
        damageDecoupled = GUDBR.settings.damageDecoupled,
        healsDecoupled = GUDBR.settings.healsDecoupled,
        shieldsDecoupled = GUDBR.settings.shieldsDecoupled,
        
        -- Coupled container position
        coupledPositionX = GUDBR.settings.coupledPositionX,
        coupledPositionY = GUDBR.settings.coupledPositionY,
        
        -- Gibbering classification
        gibberingAsDamage = GUDBR.settings.gibberingAsDamage,

        -- Smart ult tracking (#87)
        smartDamageUpgrade = GUDBR.settings.smartDamageUpgrade,
        ignoreSoulHarvest = GUDBR.settings.ignoreSoulHarvest,
        reanimateTracking = GUDBR.settings.reanimateTracking,
        reanimateDisplayMode = GUDBR.settings.reanimateDisplayMode,
        showOriginalUltAsMain = GUDBR.settings.showOriginalUltAsMain,
        
        -- Window visibility
        showUtility = GUDBR.settings.showUtility,
        showDamage = GUDBR.settings.showDamage,
        showHeals = GUDBR.settings.showHeals,
        showShields = GUDBR.settings.showShields,
        
        -- Individual window positions (decoupled mode)
        utilityPositionX = GUDBR.settings.utilityPositionX,
        utilityPositionY = GUDBR.settings.utilityPositionY,
        damagePositionX = GUDBR.settings.damagePositionX,
        damagePositionY = GUDBR.settings.damagePositionY,
        healsPositionX = GUDBR.settings.healsPositionX,
        healsPositionY = GUDBR.settings.healsPositionY,
        shieldsPositionX = GUDBR.settings.shieldsPositionX,
        shieldsPositionY = GUDBR.settings.shieldsPositionY,
    }
end

--[[
    Create coupled container (parent window that holds all four role windows)
]]--
function GUDBR.CreateCoupledContainer()
    local uniqueName = "BeltalowdaUltimateByRoles_CoupledContainer"
    local control = wm:GetControlByName(uniqueName)
    
    if control then
        GUDBR.coupledContainer = {
            control = control,
            backdrop = wm:GetControlByName(uniqueName .. "Backdrop"),
        }
        return GUDBR.coupledContainer
    end
    
    -- Create top level window for the coupled container
    control = wm:CreateTopLevelWindow(uniqueName)
    control:SetClampedToScreen(true)
    control:SetDrawLayer(DL_BACKGROUND)
    control:SetDrawLevel(0)
    control:SetMovable(not GUDBR.settings.preventMovement)
    control:SetMouseEnabled(not GUDBR.settings.preventMovement)
    control:SetHidden(not GUDBR.settings.enabled)
    
    -- Apply UI scale and opacity from own settings
    control:SetScale(GUDBR.settings.scale or 0.7907)
    control:SetAlpha(GUDBR.settings.opacity or 1.0)
    
    -- Initial size (will be calculated based on child windows)
    control:SetDimensions(700, 100)  -- Approximate initial size
    
    -- Position container
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GUDBR.settings.coupledPositionX, GUDBR.settings.coupledPositionY)
    
    -- Save position when moved
    control:SetHandler("OnMoveStop", function()
        GUDBR.isDragging = false
        -- Restore opacity on all role windows
        local opacity = GUDBR.settings.opacity or 1.0
        for _, window in pairs(GUDBR.roleWindows) do
            if window and window.control then
                window.control:SetAlpha(opacity)
            end
        end
        GUDBR.OnCoupledContainerMoved()
    end)
    
    -- Update coupled window positions during dragging (only when actively dragging)
    control:SetHandler("OnUpdate", function()
        if GUDBR.isDragging then
            GUDBR.UpdateCoupledWindowPositions()
        end
    end)
    
    -- Create backdrop for the coupled container (always transparent — no red unlock indicator)
    local backdrop = wm:CreateControl(uniqueName .. "Backdrop", control, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    backdrop:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0)
    backdrop:SetDrawLevel(0)
    backdrop:SetCenterColor(0, 0, 0, 0.0)
    backdrop:SetEdgeColor(0, 0, 0, 0)
    backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)
    backdrop:SetMouseEnabled(not GUDBR.settings.preventMovement)
    
    -- Make backdrop draggable (fallback for any area not covered by role windows)
    backdrop:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            GUDBR.HandleDragStart()
        end
    end)
    backdrop:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            GUDBR.HandleDragStop()
        end
    end)
    
    GUDBR.coupledContainer = {
        control = control,
        backdrop = backdrop,
    }
    
    return GUDBR.coupledContainer
end

--[[
    Create all four role windows
]]--
function GUDBR.CreateRoleWindows()
    -- Create the coupled container first
    GUDBR.CreateCoupledContainer()
    
    -- Create individual role windows (display order: Damage | Shields | Heals | Utility)
    GUDBR.roleWindows[GUDBR.ROLE_DAMAGE] = GUDBR.CreateRoleWindow(GUDBR.ROLE_DAMAGE, "Damage", "damagePositionX", "damagePositionY")
    GUDBR.roleWindows[GUDBR.ROLE_SHIELDS] = GUDBR.CreateRoleWindow(GUDBR.ROLE_SHIELDS, "Shields", "shieldsPositionX", "shieldsPositionY")
    GUDBR.roleWindows[GUDBR.ROLE_HEALS] = GUDBR.CreateRoleWindow(GUDBR.ROLE_HEALS, "Heals", "healsPositionX", "healsPositionY")
    GUDBR.roleWindows[GUDBR.ROLE_UTILITY] = GUDBR.CreateRoleWindow(GUDBR.ROLE_UTILITY, "Utility", "utilityPositionX", "utilityPositionY")
end

--[[
    Create a single role window
]]--
function GUDBR.CreateRoleWindow(roleType, roleName, posXKey, posYKey)
    local window = {}
    window.roleType = roleType
    window.roleName = roleName
    window.posXKey = posXKey
    window.posYKey = posYKey
    
    -- Create top level window
    local uniqueName = "BeltalowdaUltimateByRoles_" .. roleName
    local control = wm:GetControlByName(uniqueName)
    if control then
        window.control = control
        -- Retrieve child controls by name
        window.backdrop = wm:GetControlByName(uniqueName .. "Backdrop")
        window.headerContainer = wm:GetControlByName(uniqueName .. "HeaderContainer")
        window.header = wm:GetControlByName(uniqueName .. "Header")
        window.container = wm:GetControlByName(uniqueName .. "Container")
        
        -- Log warning if any child controls are missing (shouldn't happen in normal operation)
        if not window.backdrop then
            d("[Beltalowda] WARNING: Could not find backdrop for " .. roleName .. " window")
        end
        if not window.header then
            d("[Beltalowda] WARNING: Could not find header for " .. roleName .. " window")
        end
        if not window.container then
            d("[Beltalowda] WARNING: Could not find container for " .. roleName .. " window")
        end
        
        -- Player bars are dynamically managed and don't persist across reloads
        window.playerBars = {}
        return window
    end
    
    control = wm:CreateTopLevelWindow(uniqueName)
    control:SetClampedToScreen(true)
    control:SetDrawLayer(DL_BACKGROUND)
    control:SetDrawLevel(1)  -- Higher than coupled container backdrop (0) to stay on top during drag
    
    -- Use preventMovement setting
    local isPreventMovement = GUDBR.settings.preventMovement
    control:SetMovable(not isPreventMovement)
    control:SetMouseEnabled(true)  -- Always enabled for tooltips and drag forwarding
    control:SetHidden(not GUDBR.settings.enabled)
    
    -- Apply UI scale and opacity from own settings
    control:SetScale(GUDBR.settings.scale or 0.7907)
    control:SetAlpha(GUDBR.settings.opacity or 1.0)
    
    -- Initial size (will resize dynamically based on player count)
    local width = GUDBR.PLAYER_BAR_WIDTH + (GUDBR.WINDOW_PADDING * 2)
    local height = GUDBR.GetEffectiveHeaderHeight() + (GUDBR.WINDOW_PADDING * 2)
    control:SetDimensions(width, height)
    
    -- Position window (will be updated by ApplySettings based on coupled/decoupled state)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GUDBR.settings[posXKey], GUDBR.settings[posYKey])
    
    -- Save position when moved (only for decoupled windows)
    control:SetHandler("OnMoveStop", function()
        GUDBR.OnWindowMoved(window)
    end)
    
    -- Forward mouse events to coupled container for drag (or move self if decoupled)
    control:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not GUDBR.settings.preventMovement then
            if GUDBR.IsRoleCoupled(roleType) then
                GUDBR.HandleDragStart()
            end
            -- If decoupled, the control's native SetMovable(true) handles it
        end
    end)
    control:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            if GUDBR.IsRoleCoupled(roleType) then
                GUDBR.HandleDragStop()
            end
        end
    end)
    
    -- Create backdrop (will be made transparent when coupled)
    local backdrop = wm:CreateControl(uniqueName .. "Backdrop", control, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    backdrop:SetDimensions(width, height)
    backdrop:SetDrawLevel(0)  -- Draw behind all other UI elements
    -- Always transparent - coupled container will show the highlight
    backdrop:SetCenterColor(1, 0, 0, 0.0)
    backdrop:SetEdgeColor(0, 0, 0, 0)
    backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)
    backdrop:SetMouseEnabled(false)  -- Coupled container handles dragging
    
    -- Header container (holds icon + label)
    local headerContainer = wm:CreateControl(uniqueName .. "HeaderContainer", control, CT_CONTROL)
    headerContainer:SetDimensions(GUDBR.PLAYER_BAR_WIDTH, GUDBR.HEADER_HEIGHT)
    headerContainer:SetAnchor(TOP, control, TOP, 0, GUDBR.WINDOW_PADDING)
    
    -- Header label with inline icon (centered as a single unit)
    local header = wm:CreateControl(uniqueName .. "Header", headerContainer, CT_LABEL)
    header:SetAnchor(CENTER, headerContainer, CENTER, 0, 0)
    header:SetFont("ZoFontWinH4")
    local iconPath = GUDBR.ROLE_HEADER_ICONS[roleType]
    if iconPath then
        header:SetText(zo_iconFormat(iconPath, GUDBR.HEADER_ICON_SIZE, GUDBR.HEADER_ICON_SIZE) .. " " .. roleName)
    else
        header:SetText(roleName)
    end
    header:SetColor(1, 1, 1, 1)
    header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    
    -- Container for player bars
    local container = wm:CreateControl(uniqueName .. "Container", control, CT_CONTROL)
    container:SetAnchor(TOPLEFT, control, TOPLEFT, GUDBR.WINDOW_PADDING, GUDBR.GetEffectiveHeaderHeight() + GUDBR.WINDOW_PADDING)
    container:SetDimensions(GUDBR.PLAYER_BAR_WIDTH, 0)
    
    window.control = control
    window.backdrop = backdrop
    window.headerContainer = headerContainer
    window.header = header
    window.container = container
    window.playerBars = {}
    
    return window
end

--[[
    Extract account name from display name
    GetUnitDisplayName typically returns "@AccountName"
    This helper strips the @ prefix for display purposes
]]--
local function ExtractAccountName(displayName)
    if not displayName or displayName == "" then
        return "Unknown"
    end
    
    if string.sub(displayName, 1, 1) == "@" then
        return string.sub(displayName, 2)
    else
        return displayName
    end
end

--[[
    Create a player bar for the uncoupled tracker
    Layout: [Icon 48x48] [Name & Percentage] [Resource Bars]
    @param parent - Parent control (window.container)
    @param index - Bar index (1-based)
    @param roleType - Role type constant for drag forwarding
]]--
function GUDBR.CreatePlayerBar(parent, index, roleType)
    local bar = {}
    
    -- Container
    local container = wm:CreateControl(nil, parent, CT_CONTROL)
    local yOffset = (GUDBR.PLAYER_BAR_HEIGHT + 2) * (index - 1)
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, yOffset)
    container:SetDimensions(GUDBR.PLAYER_BAR_WIDTH, GUDBR.PLAYER_BAR_HEIGHT)
    container:SetHidden(true)
    
    -- Background
    local backdrop = wm:CreateControl(nil, container, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    backdrop:SetDimensions(GUDBR.PLAYER_BAR_WIDTH, GUDBR.PLAYER_BAR_HEIGHT)
    backdrop:SetCenterColor(0.1, 0.1, 0.1, 0.8)
    backdrop:SetEdgeColor(0, 0, 0, 1)
    backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)
    
    -- Combat border (overlay on backdrop)
    local combatBorder = wm:CreateControl(nil, container, CT_BACKDROP)
    combatBorder:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    combatBorder:SetDimensions(GUDBR.PLAYER_BAR_WIDTH, GUDBR.PLAYER_BAR_HEIGHT)
    combatBorder:SetCenterColor(0, 0, 0, 0)
    combatBorder:SetEdgeColor(0, 0, 0, 1)
    combatBorder:SetEdgeTexture(nil, GUDBR.COMBAT_BORDER_WIDTH, GUDBR.COMBAT_BORDER_WIDTH, GUDBR.COMBAT_BORDER_WIDTH, 0)
    combatBorder:SetDrawLevel(10)
    
    -- Ultimate icon (left side, vertically centered)
    local icon = wm:CreateControl(nil, container, CT_TEXTURE)
    icon:SetAnchor(LEFT, container, LEFT, 2, 0)
    icon:SetDimensions(GUDBR.ICON_SIZE, GUDBR.ICON_SIZE)
    icon:SetTexture(GUDBR.DEFAULT_ABILITY_ICON)
    
    -- Original-ult overlay (bottom-right quadrant of icon)
    -- When a smart upgrade is active, the main icon shows the upgraded ult
    -- and this small overlay shows the original detected ult for reference.
    local overlaySize = math.floor(GUDBR.ICON_SIZE / 2)
    local originalOverlay = wm:CreateControl(nil, container, CT_TEXTURE)
    originalOverlay:SetAnchor(BOTTOMRIGHT, icon, BOTTOMRIGHT, 0, 0)
    originalOverlay:SetDimensions(overlaySize, overlaySize)
    originalOverlay:SetTexture(GUDBR.DEFAULT_ABILITY_ICON)
    originalOverlay:SetDrawLevel(3)
    originalOverlay:SetHidden(true)
    
    -- Resource bar container (below name/percent line, right of icon)
    local resourceX = GUDBR.ICON_SIZE + 6
    local resourceY = 20  -- Moved down from 16px to 20px to avoid overlapping name/percent text
    local resourceWidth = GUDBR.PLAYER_BAR_WIDTH - GUDBR.ICON_SIZE - 10
    
    -- Player name label (green text, centered over ultimate bar area)
    local nameLabel = wm:CreateControl(nil, container, CT_LABEL)
    nameLabel:SetAnchor(TOPLEFT, container, TOPLEFT, resourceX, GUDBR.COMBAT_BORDER_WIDTH + 2)
    nameLabel:SetFont("ZoFontGame")
    nameLabel:SetText("")
    nameLabel:SetDimensions(resourceWidth, 14)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    nameLabel:SetColor(GUD.COLORS.PLAYER_NAME[1], GUD.COLORS.PLAYER_NAME[2], GUD.COLORS.PLAYER_NAME[3], 1)
    nameLabel:SetDrawLevel(5)  -- Above ultimate bar
    local barStep = GUDBR.RESOURCE_BAR_HEIGHT + 1  -- bar height + 1px gap between bars
    
    -- Ultimate bar (tall bar filling from top to above magicka, behind name text)
    local ultBarTop = GUDBR.COMBAT_BORDER_WIDTH + 2  -- Match bottom gap spacing
    local magickaY = resourceY + barStep
    local ultBarHeight = magickaY - ultBarTop - 1  -- 1px gap before magicka bar
    
    local ultimateBar = wm:CreateControl(nil, container, CT_STATUSBAR)
    ultimateBar:SetAnchor(TOPLEFT, container, TOPLEFT, resourceX, ultBarTop)
    ultimateBar:SetDimensions(resourceWidth, ultBarHeight)
    ultimateBar:SetMinMax(0, 100)
    ultimateBar:SetValue(0)
    ultimateBar:SetColor(GUD.COLORS.ULTIMATE_NOT_FULL[1], GUD.COLORS.ULTIMATE_NOT_FULL[2], GUD.COLORS.ULTIMATE_NOT_FULL[3])
    ultimateBar:SetDrawLevel(1)  -- Behind name/percent labels
    
    local ultimateBackdrop = wm:CreateControl(nil, ultimateBar, CT_BACKDROP)
    ultimateBackdrop:SetAnchor(TOPLEFT, ultimateBar, TOPLEFT, 0, 0)
    ultimateBackdrop:SetDimensions(resourceWidth, ultBarHeight)
    ultimateBackdrop:SetCenterColor(0.5, 0.5, 0.5, 0.3)
    ultimateBackdrop:SetEdgeColor(0, 0, 0, 0)
    ultimateBackdrop:SetDrawLevel(0)
    
    -- Magicka bar (below ultimate)
    local magickaBar = wm:CreateControl(nil, container, CT_STATUSBAR)
    magickaBar:SetAnchor(TOPLEFT, container, TOPLEFT, resourceX, resourceY + barStep)
    magickaBar:SetDimensions(resourceWidth, GUDBR.RESOURCE_BAR_HEIGHT)
    magickaBar:SetMinMax(0, 100)
    magickaBar:SetValue(0)
    magickaBar:SetColor(GUD.COLORS.MAGICKA[1], GUD.COLORS.MAGICKA[2], GUD.COLORS.MAGICKA[3])
    
    local magickaBackdrop = wm:CreateControl(nil, magickaBar, CT_BACKDROP)
    magickaBackdrop:SetAnchor(TOPLEFT, magickaBar, TOPLEFT, 0, 0)
    magickaBackdrop:SetDimensions(resourceWidth, GUDBR.RESOURCE_BAR_HEIGHT)
    magickaBackdrop:SetCenterColor(0.5, 0.5, 0.5, 0.3)
    magickaBackdrop:SetEdgeColor(0, 0, 0, 0)
    magickaBackdrop:SetDrawLevel(0)
    
    -- Stamina bar (below magicka)
    local staminaBar = wm:CreateControl(nil, container, CT_STATUSBAR)
    staminaBar:SetAnchor(TOPLEFT, container, TOPLEFT, resourceX, resourceY + barStep * 2)
    staminaBar:SetDimensions(resourceWidth, GUDBR.RESOURCE_BAR_HEIGHT)
    staminaBar:SetMinMax(0, 100)
    staminaBar:SetValue(0)
    staminaBar:SetColor(GUD.COLORS.STAMINA[1], GUD.COLORS.STAMINA[2], GUD.COLORS.STAMINA[3])
    
    local staminaBackdrop = wm:CreateControl(nil, staminaBar, CT_BACKDROP)
    staminaBackdrop:SetAnchor(TOPLEFT, staminaBar, TOPLEFT, 0, 0)
    staminaBackdrop:SetDimensions(resourceWidth, GUDBR.RESOURCE_BAR_HEIGHT)
    staminaBackdrop:SetCenterColor(0.5, 0.5, 0.5, 0.3)
    staminaBackdrop:SetEdgeColor(0, 0, 0, 0)
    staminaBackdrop:SetDrawLevel(0)
    
    -- Orange glow layers for MAX with ult-spending set (Balorgh, Pillager's, etc.)
    -- 3 nested backdrops: outer (faint, wide) → inner (bright, tight)
    local glowLayers = {}
    local glowSpecs = {
        {expand = 8, edgeWidth = 8, alpha = 0.15},  -- Outermost: faint wide glow
        {expand = 4, edgeWidth = 4, alpha = 0.35},  -- Middle layer
        {expand = 2, edgeWidth = 2, alpha = 0.65},  -- Innermost: bright tight glow
    }
    for i, spec in ipairs(glowSpecs) do
        local glow = wm:CreateControl(nil, container, CT_BACKDROP)
        glow:SetAnchor(TOPLEFT, container, TOPLEFT, -spec.expand, -spec.expand)
        glow:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, spec.expand, spec.expand)
        glow:SetCenterColor(0, 0, 0, 0)
        glow:SetEdgeColor(GUD.COLORS.MAX_ULT_WASTED[1], GUD.COLORS.MAX_ULT_WASTED[2], GUD.COLORS.MAX_ULT_WASTED[3], spec.alpha)
        glow:SetEdgeTexture(nil, spec.edgeWidth, spec.edgeWidth, spec.edgeWidth, 0)
        glow:SetDrawLevel(11)  -- Above combat border
        glow:SetHidden(true)
        glowLayers[i] = glow
    end
    
    -- Tooltip
    container:SetMouseEnabled(true)
    container:SetHandler("OnMouseEnter", function(control)
        if bar.unitTag then
            local charName = GetUnitName(bar.unitTag)
            local displayName = GetUnitDisplayName(bar.unitTag)
            local acctName = ExtractAccountName(displayName)
            local ultPercent = bar.ultimatePercent or 0
            local magPercent = bar.magickaPercent or 0
            local stamPercent = bar.staminaPercent or 0
            local combat = bar.inCombat and "In Combat" or "Out of Combat"
            local ultName = bar.abilityName or GUDBR.DEFAULT_ABILITY_NAME
            
            -- Show both original and upgraded ult names when they differ
            local origId = bar.originalAbilityId
            if origId and bar.abilityId and origId ~= bar.abilityId then
                local origName = GetAbilityName(origId) or "Unknown"
                ultName = string.format("%s / %s", origName, ultName)
            end
            
            local rawUlt = bar.currentUlt or 0
            local ultDisplay = (rawUlt >= 500) and "MAX" or tostring(rawUlt)
            
            InitializeTooltip(InformationTooltip, control, RIGHT, 0, 0)
            -- Tooltip always shows both names for identification
            SetTooltipText(InformationTooltip, string.format("%s (@%s)\n%s\n%s\nUltimate: %s\nMagicka: %d%%\nStamina: %d%%", 
                charName, acctName, combat, ultName, ultDisplay, magPercent, stamPercent))
        end
    end)
    container:SetHandler("OnMouseExit", function(control)
        ClearTooltip(InformationTooltip)
    end)
    
    -- Drag forwarding: click-anywhere-to-drag for both coupled and decoupled modes
    container:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not GUDBR.settings.preventMovement then
            if GUDBR.IsRoleCoupled(roleType) then
                GUDBR.HandleDragStart()
            else
                -- Decoupled: start moving the parent role window
                local roleWindow = GUDBR.roleWindows[roleType]
                if roleWindow and roleWindow.control then
                    roleWindow.control:StartMoving()
                end
            end
        end
    end)
    container:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            if GUDBR.IsRoleCoupled(roleType) then
                GUDBR.HandleDragStop()
            else
                local roleWindow = GUDBR.roleWindows[roleType]
                if roleWindow and roleWindow.control then
                    roleWindow.control:StopMovingOrResizing()
                end
            end
        end
    end)
    
    bar.container = container
    bar.backdrop = backdrop
    bar.combatBorder = combatBorder
    bar.icon = icon
    bar.originalOverlay = originalOverlay
    bar.nameLabel = nameLabel
    bar.ultimateBar = ultimateBar
    bar.ultimateBackdrop = ultimateBackdrop
    bar.magickaBar = magickaBar
    bar.magickaBackdrop = magickaBackdrop
    bar.staminaBar = staminaBar
    bar.staminaBackdrop = staminaBackdrop
    bar.glowLayers = glowLayers
    bar.unitTag = nil
    bar.ultimatePercent = 0
    bar.magickaPercent = 0
    bar.staminaPercent = 0
    bar.inCombat = false
    bar.abilityId = nil
    bar.originalAbilityId = nil
    bar.abilityName = nil
    
    return bar
end

--[[
    Get effective header height (0 when headers are hidden)
]]--
function GUDBR.GetEffectiveHeaderHeight()
    if GUDBR.settings.hideHeaders then
        return 0
    end
    return GUDBR.HEADER_HEIGHT
end

--[[
    Apply the Gibbering classification setting to ULTIMATE_ROLES.
    When gibberingAsDamage is true, Gibbering Shield (183676) and Sanctum of
    the Abyssal Sea (192372) are categorised as ROLE_DAMAGE.
    When false (default), they are categorised as ROLE_SHIELDS.
]]--
function GUDBR.ApplyGibberingClassification()
    local role = GUDBR.settings.gibberingAsDamage and GUDBR.ROLE_DAMAGE or GUDBR.ROLE_SHIELDS
    GUDBR.ULTIMATE_ROLES[183676] = role   -- Gibbering Shield (base)
    GUDBR.ULTIMATE_ROLES[192372] = role   -- Sanctum of the Abyssal Sea (morph)
end

--[[
    Apply settings to UI
]]--
function GUDBR.ApplySettings()
    if not GUDBR.settings.enabled or GUDBR.menuHidden or GUDBR.pvpHidden then
        -- Hide all windows if disabled, menu is open, or not in PvP zone
        if GUDBR.coupledContainer and GUDBR.coupledContainer.control then
            GUDBR.coupledContainer.control:SetHidden(true)
        end
        for roleType, window in pairs(GUDBR.roleWindows) do
            if window and window.control then
                window.control:SetHidden(true)
            end
        end
        return
    end
    
    -- Get scale and opacity from own settings
    local globalScale = GUDBR.settings.scale or 0.7907
    local globalOpacity = GUDBR.settings.opacity or 1.0
    local preventMovement = GUDBR.settings.preventMovement
    
    -- Determine which windows are coupled
    local utilityCoupled = not GUDBR.settings.utilityDecoupled
    local damageCoupled = not GUDBR.settings.damageDecoupled
    local healsCoupled = not GUDBR.settings.healsDecoupled
    local shieldsCoupled = not GUDBR.settings.shieldsDecoupled
    local anyCoupled = utilityCoupled or damageCoupled or healsCoupled or shieldsCoupled
    
    -- Show/hide coupled container based on whether any windows are coupled
    if GUDBR.coupledContainer and GUDBR.coupledContainer.control then
        GUDBR.coupledContainer.control:SetHidden(not anyCoupled)
        GUDBR.coupledContainer.control:SetMovable(not preventMovement)
        GUDBR.coupledContainer.control:SetMouseEnabled(not preventMovement)
        GUDBR.coupledContainer.control:SetScale(globalScale)
        GUDBR.coupledContainer.control:SetAlpha(globalOpacity)
        
        -- Backdrop always transparent (no red unlock indicator)
        if GUDBR.coupledContainer.backdrop then
            GUDBR.coupledContainer.backdrop:SetMouseEnabled(not preventMovement)
            GUDBR.coupledContainer.backdrop:SetCenterColor(0, 0, 0, 0.0)
            GUDBR.coupledContainer.backdrop:SetEdgeColor(0, 0, 0, 0)
        end
    end
    
    -- Get coupled container position for anchoring coupled windows
    local coupledX = GUDBR.settings.coupledPositionX
    local coupledY = GUDBR.settings.coupledPositionY
    local coupledXOffset = 0
    
    -- Helper to configure a role window
    local function configureRoleWindow(window, isCoupled, showSetting, posXKey, posYKey)
        if not window or not window.control then return end
        
        window.control:SetScale(globalScale)
        window.control:SetAlpha(globalOpacity)
        window.control:ClearAnchors()
        
        if isCoupled and GUDBR.coupledContainer then
            -- Coupled: anchor to GuiRoot at coupled container position + offset
            window.control:SetHidden(not showSetting)
            window.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, coupledX + coupledXOffset, coupledY)
            window.control:SetMovable(false)
            window.control:SetMouseEnabled(true)  -- Always enabled for drag forwarding and tooltips
            
            if showSetting then
                coupledXOffset = coupledXOffset + window.control:GetWidth() + 4  -- 4px spacing
            end
        else
            -- Decoupled: anchor to GuiRoot at individual position
            window.control:SetHidden(not showSetting)
            window.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GUDBR.settings[posXKey], GUDBR.settings[posYKey])
            window.control:SetMovable(not preventMovement)
            window.control:SetMouseEnabled(true)  -- Always enabled for tooltips
            
            -- Enable backdrop dragging when decoupled and movement allowed
            if window.backdrop then
                window.backdrop:SetMouseEnabled(not preventMovement)
            end
        end
    end
    
    -- Position windows in display order: Damage | Shields | Heals | Utility
    configureRoleWindow(GUDBR.roleWindows[GUDBR.ROLE_DAMAGE], damageCoupled,
        GUDBR.settings.showDamage, "damagePositionX", "damagePositionY")
    configureRoleWindow(GUDBR.roleWindows[GUDBR.ROLE_SHIELDS], shieldsCoupled,
        GUDBR.settings.showShields, "shieldsPositionX", "shieldsPositionY")
    configureRoleWindow(GUDBR.roleWindows[GUDBR.ROLE_HEALS], healsCoupled,
        GUDBR.settings.showHeals, "healsPositionX", "healsPositionY")
    configureRoleWindow(GUDBR.roleWindows[GUDBR.ROLE_UTILITY], utilityCoupled,
        GUDBR.settings.showUtility, "utilityPositionX", "utilityPositionY")
    
    -- Resize coupled container to fit its children
    GUDBR.ResizeCoupledContainer()

    -- Apply header visibility and reposition containers
    local headerHeight = GUDBR.GetEffectiveHeaderHeight()
    for _, window in pairs(GUDBR.roleWindows) do
        if window then
            -- Hide/show both the header container (icon+label) and the label itself
            if window.headerContainer then
                window.headerContainer:SetHidden(GUDBR.settings.hideHeaders)
            end
            if window.header then
                window.header:SetHidden(GUDBR.settings.hideHeaders)
            end
            if window.container then
                window.container:ClearAnchors()
                window.container:SetAnchor(TOPLEFT, window.control, TOPLEFT,
                    GUDBR.WINDOW_PADDING, headerHeight + GUDBR.WINDOW_PADDING)
            end
        end
    end
end

--[[
    Get visibility setting for a role
]]--
function GUDBR.GetRoleVisibilitySetting(roleType)
    if roleType == GUDBR.ROLE_UTILITY then
        return GUDBR.settings.showUtility
    elseif roleType == GUDBR.ROLE_DAMAGE then
        return GUDBR.settings.showDamage
    elseif roleType == GUDBR.ROLE_HEALS then
        return GUDBR.settings.showHeals
    elseif roleType == GUDBR.ROLE_SHIELDS then
        return GUDBR.settings.showShields
    end
    return false
end

--[[
    Set individual window decouple state
]]--
function GUDBR.SetRoleDecoupled(roleType, value)
    if roleType == GUDBR.ROLE_UTILITY then
        GUDBR.settings.utilityDecoupled = value
    elseif roleType == GUDBR.ROLE_DAMAGE then
        GUDBR.settings.damageDecoupled = value
    elseif roleType == GUDBR.ROLE_HEALS then
        GUDBR.settings.healsDecoupled = value
    elseif roleType == GUDBR.ROLE_SHIELDS then
        GUDBR.settings.shieldsDecoupled = value
    end
    GUDBR.SaveSettings()
    GUDBR.ApplySettings()
    GUDBR.RefreshDisplay()
end

--[[
    Set prevent movement state for all windows
]]--
function GUDBR.SetPreventMovement(value)
    GUDBR.settings.preventMovement = value
    GUDBR.SaveSettings()
    GUDBR.ApplySettings()
end

--[[
    Set visibility mode (dynamic vs manual)
]]--
function GUDBR.SetVisibilityMode(mode)
    GUDBR.settings.dynamicVisibility = (mode == "dynamic")
    GUDBR.SaveSettings()
    GUDBR.ApplySettings()
    GUDBR.RefreshDisplay()
end

--[[
    Check if a role window is currently coupled (not decoupled)
]]--
function GUDBR.IsRoleCoupled(roleType)
    if roleType == GUDBR.ROLE_UTILITY then return not GUDBR.settings.utilityDecoupled end
    if roleType == GUDBR.ROLE_DAMAGE then return not GUDBR.settings.damageDecoupled end
    if roleType == GUDBR.ROLE_HEALS then return not GUDBR.settings.healsDecoupled end
    if roleType == GUDBR.ROLE_SHIELDS then return not GUDBR.settings.shieldsDecoupled end
    return false
end

--[[
    Start dragging the coupled container (called from role windows / player bars)
]]--
function GUDBR.HandleDragStart()
    if GUDBR.settings.preventMovement then return end
    if not GUDBR.coupledContainer or not GUDBR.coupledContainer.control then return end
    if GUDBR.isDragging then return end
    GUDBR.isDragging = true
    -- Subtle drag feedback on all coupled role windows
    for roleType, window in pairs(GUDBR.roleWindows) do
        if window and window.control and GUDBR.IsRoleCoupled(roleType) then
            window.control:SetAlpha(0.7)
        end
    end
    GUDBR.coupledContainer.control:StartMoving()
end

--[[
    Stop dragging the coupled container
]]--
function GUDBR.HandleDragStop()
    if not GUDBR.isDragging then return end
    if not GUDBR.coupledContainer or not GUDBR.coupledContainer.control then return end
    GUDBR.coupledContainer.control:StopMovingOrResizing()
    -- OnMoveStop handler handles isDragging=false, alpha restore, and position save
end

--[[
    Update coupled window positions during container movement
    This ensures windows move in real-time with the container backdrop
]]--
function GUDBR.UpdateCoupledWindowPositions()
    if not GUDBR.coupledContainer or not GUDBR.coupledContainer.control then return end
    if not GUDBR.settings.enabled then return end
    
    -- Get current coupled container position
    local coupledX = GUDBR.coupledContainer.control:GetLeft()
    local coupledY = GUDBR.coupledContainer.control:GetTop()
    
    if not coupledX or not coupledY then return end
    
    -- Determine which windows are coupled
    local utilityCoupled = not GUDBR.settings.utilityDecoupled
    local damageCoupled = not GUDBR.settings.damageDecoupled
    local healsCoupled = not GUDBR.settings.healsDecoupled
    local shieldsCoupled = not GUDBR.settings.shieldsDecoupled
    
    local coupledXOffset = 0
    
    -- Display order: Damage | Shields | Heals | Utility
    -- Damage is the stable left anchor; columns extend rightward as detected
    local roleOrder = {
        { role = GUDBR.ROLE_DAMAGE, coupled = damageCoupled },
        { role = GUDBR.ROLE_SHIELDS, coupled = shieldsCoupled },
        { role = GUDBR.ROLE_HEALS, coupled = healsCoupled },
        { role = GUDBR.ROLE_UTILITY, coupled = utilityCoupled },
    }
    
    for _, entry in ipairs(roleOrder) do
        local window = GUDBR.roleWindows[entry.role]
        if entry.coupled and window and window.control and not window.control:IsHidden() then
            window.control:ClearAnchors()
            window.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, coupledX + coupledXOffset, coupledY)
            coupledXOffset = coupledXOffset + window.control:GetWidth() + 4
        end
    end
end

--[[
    Handle coupled container movement - save position
]]--
function GUDBR.OnCoupledContainerMoved()
    if not GUDBR.coupledContainer or not GUDBR.coupledContainer.control then return end
    
    -- Only save when movement is allowed
    if GUDBR.settings.preventMovement then return end
    
    -- Get position (with nil checks)
    local left = GUDBR.coupledContainer.control:GetLeft()
    local top = GUDBR.coupledContainer.control:GetTop()
    
    if left and top then
        GUDBR.settings.coupledPositionX = left
        GUDBR.settings.coupledPositionY = top
        GUDBR.SaveSettings()
    end
end

--[[
    Handle individual window movement - save position (only for decoupled windows)
]]--
function GUDBR.OnWindowMoved(window)
    if not window or not window.control then return end
    
    -- Only save when movement is allowed
    if GUDBR.settings.preventMovement then return end
    
    -- Only save if this window is decoupled
    local isDecoupled = false
    if window.roleType == GUDBR.ROLE_UTILITY then
        isDecoupled = GUDBR.settings.utilityDecoupled
    elseif window.roleType == GUDBR.ROLE_DAMAGE then
        isDecoupled = GUDBR.settings.damageDecoupled
    elseif window.roleType == GUDBR.ROLE_HEALS then
        isDecoupled = GUDBR.settings.healsDecoupled
    elseif window.roleType == GUDBR.ROLE_SHIELDS then
        isDecoupled = GUDBR.settings.shieldsDecoupled
    end
    
    if not isDecoupled then return end
    
    -- Get position (with nil checks)
    local left = window.control:GetLeft()
    local top = window.control:GetTop()
    
    if left and top then
        GUDBR.settings[window.posXKey] = left
        GUDBR.settings[window.posYKey] = top
        GUDBR.SaveSettings()
    end
end

--[[
    Resize coupled container to fit all visible coupled children.
    Called from ApplySettings and RelayoutCoupledWindows.
]]--
function GUDBR.ResizeCoupledContainer()
    if not GUDBR.coupledContainer or not GUDBR.coupledContainer.control then return end
    
    local utilityCoupled = not GUDBR.settings.utilityDecoupled
    local damageCoupled = not GUDBR.settings.damageDecoupled
    local healsCoupled = not GUDBR.settings.healsDecoupled
    local shieldsCoupled = not GUDBR.settings.shieldsDecoupled
    local anyCoupled = utilityCoupled or damageCoupled or healsCoupled or shieldsCoupled
    
    if not anyCoupled then return end
    
    local totalWidth = 0
    local maxHeight = 0
    
    -- Check each role window in display order: Damage | Shields | Heals | Utility
    local roleOrder = {
        { role = GUDBR.ROLE_DAMAGE, coupled = damageCoupled },
        { role = GUDBR.ROLE_SHIELDS, coupled = shieldsCoupled },
        { role = GUDBR.ROLE_HEALS, coupled = healsCoupled },
        { role = GUDBR.ROLE_UTILITY, coupled = utilityCoupled },
    }
    
    for _, entry in ipairs(roleOrder) do
        local window = GUDBR.roleWindows[entry.role]
        if entry.coupled and window and window.control and not window.control:IsHidden() then
            totalWidth = totalWidth + window.control:GetWidth() + 4
            maxHeight = math.max(maxHeight, window.control:GetHeight())
        end
    end
    
    if totalWidth > 4 then totalWidth = totalWidth - 4 end  -- Remove trailing spacing
    if totalWidth > 0 and maxHeight > 0 then
        GUDBR.coupledContainer.control:SetDimensions(totalWidth, maxHeight)
    end
end

--[[
    Relayout coupled windows after dynamic visibility changes.
    Repositions only visible coupled windows side-by-side (squish logic)
    so there are no gaps from hidden categories.
]]--
function GUDBR.RelayoutCoupledWindows()
    if not GUDBR.coupledContainer or not GUDBR.coupledContainer.control then return end
    if not GUDBR.settings.enabled then return end
    
    local coupledX = GUDBR.settings.coupledPositionX
    local coupledY = GUDBR.settings.coupledPositionY
    local coupledXOffset = 0
    
    -- Display order: Damage | Shields | Heals | Utility
    local roleOrder = {
        { role = GUDBR.ROLE_DAMAGE, coupled = not GUDBR.settings.damageDecoupled },
        { role = GUDBR.ROLE_SHIELDS, coupled = not GUDBR.settings.shieldsDecoupled },
        { role = GUDBR.ROLE_HEALS, coupled = not GUDBR.settings.healsDecoupled },
        { role = GUDBR.ROLE_UTILITY, coupled = not GUDBR.settings.utilityDecoupled },
    }
    
    for _, entry in ipairs(roleOrder) do
        local window = GUDBR.roleWindows[entry.role]
        if entry.coupled and window and window.control and not window.control:IsHidden() then
            window.control:ClearAnchors()
            window.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, coupledX + coupledXOffset, coupledY)
            coupledXOffset = coupledXOffset + window.control:GetWidth() + 4
        end
    end
    
    -- Resize the coupled container to match the new layout
    GUDBR.ResizeCoupledContainer()
end

--[[
    Register for data updates
    Note: Using polling approach (5s interval) to match GroupUltimateDisplay pattern.
    
    Why polling instead of event-driven:
    - GroupUltimateDisplay already polls at 5s intervals for consistency
    - Network broadcasts may arrive at unpredictable times (async)
    - Polling ensures both trackers update in sync, avoiding UI flicker
    - EVENT_UNIT_ATTRIBUTE_VISUAL_* events fire too frequently for UI updates
    - GROUP_MEMBER_JOINED/LEFT events don't cover all ultimate changes
    - Keeps code simple and avoids complex event handling logic
    
    Note: Update event is only registered when tracker is enabled to avoid
    unnecessary processing when disabled.
]]--
function GUDBR.RegisterForUpdates()
    -- Only register if enabled
    if GUDBR.settings.enabled then
        EVENT_MANAGER:RegisterForUpdate("BeltalowdaGroupUltimateDisplayByRoles", 5000, function()
            GUDBR.RefreshDisplay()
        end)
        GUDBR.updateRegistered = true
    end
end

--[[
    Refresh the entire display
]]--
function GUDBR.RefreshDisplay()
    if not GUDBR.settings.enabled or GUDBR.menuHidden or GUDBR.pvpHidden then return end
    
    -- Clear all player bars
    for roleType, bars in pairs(GUDBR.playerBars) do
        for _, bar in ipairs(bars) do
            bar.container:SetHidden(true)
            bar.unitTag = nil
        end
    end
    
    -- Reorganize players by their ultimate roles
    GUDBR.UpdateRoleWindows()
end

--[[
    Update role windows with current player data
]]--
function GUDBR.UpdateRoleWindows()
    if not GUD or not GUD.playerData then return end
    
    -- Refresh unitTag cache for efficient lookups
    GUDBR.RefreshUnitTagCache()
    
    -- Organize players by role
    local playersByRole = {
        [GUDBR.ROLE_UTILITY] = {},
        [GUDBR.ROLE_DAMAGE] = {},
        [GUDBR.ROLE_HEALS] = {},
        [GUDBR.ROLE_SHIELDS] = {},
    }
    
    -- Iterate through all tracked players
    -- Use RoleScoring to factor in equipment data when available (#66)
    local RS = Beltalowda.Util and Beltalowda.Util.RoleScoring
    
    for playerName, data in pairs(GUD.playerData) do
        if data.selectedUltimateId and data.selectedUltimateId > 0 then
            local role = nil
            
            -- Try equipment-aware role determination via RoleScoring
            if RS and RS.DetermineRoleForDisplay then
                local unitTag = GUDBR.FindUnitTagForPlayer(playerName)
                local equipRole = unitTag and RS.GetRemotePlayerEquipmentRole(unitTag) or nil
                role = RS.DetermineRoleForDisplay(
                    data.selectedUltimateId,
                    data.frontbarUltimateId,
                    data.backbarUltimateId,
                    equipRole
                )
            end
            
            -- Fall back to standard ultimate-only lookup
            if not role then
                role = GUDBR.ULTIMATE_ROLES[data.selectedUltimateId]
            end
            
            if role then
                table.insert(playersByRole[role], {
                    playerName = playerName,
                    data = data,
                })
            end
        end
    end
    
    -- ========== Smart Ult Upgrade: Damage (#87) ==========
    -- When enabled, override the displayed ult to show the expensive damage ult
    -- when affordable, or the cheap one when not.
    if GUDBR.settings.smartDamageUpgrade then
        for i, playerInfo in ipairs(playersByRole[GUDBR.ROLE_DAMAGE]) do
            -- Skip upgrade logic for Volendrung players (#125)
            -- Volendrung replaces all skills; the player can only cast Ruinous Cyclone
            if not playerInfo.data.hasVolendrung then
                local upgradeUltId, upgradePct = GUDBR.GetDamageUpgradeInfo(playerInfo.data)
                if upgradeUltId then
                    playerInfo.displayUltId = upgradeUltId
                    playerInfo.displayPercent = upgradePct
                end
            end
        end
    end
    
    -- ========== Smart Ult Upgrade: Reanimate Tracking (#87) ==========
    -- When enabled, add players with affordable backbar Reanimate to the
    -- Utility window. In "switch" mode, remove them from their original role.
    if GUDBR.settings.reanimateTracking then
        local reanimateEntries = {}
        local switchIndices = {} -- roleType -> {indices to remove}
        
        for roleType, players in pairs(playersByRole) do
            if roleType ~= GUDBR.ROLE_UTILITY then
                for i, playerInfo in ipairs(players) do
                    local reanimateId, reanimatePct = GUDBR.GetReanimateUpgradeInfo(playerInfo.data)
                    if reanimateId then
                        table.insert(reanimateEntries, {
                            playerName = playerInfo.playerName,
                            data = playerInfo.data,
                            displayUltId = reanimateId,
                            displayPercent = reanimatePct,
                        })
                        
                        if GUDBR.settings.reanimateDisplayMode == "switch" then
                            switchIndices[roleType] = switchIndices[roleType] or {}
                            table.insert(switchIndices[roleType], i)
                        end
                    end
                end
            end
        end
        
        -- Add Reanimate entries to Utility window
        for _, entry in ipairs(reanimateEntries) do
            table.insert(playersByRole[GUDBR.ROLE_UTILITY], entry)
        end
        
        -- In switch mode, remove players from their original role window
        if GUDBR.settings.reanimateDisplayMode == "switch" then
            for roleType, indices in pairs(switchIndices) do
                -- Remove in reverse order to keep indices valid
                table.sort(indices, function(a, b) return a > b end)
                for _, idx in ipairs(indices) do
                    table.remove(playersByRole[roleType], idx)
                end
            end
        end
    end
    
    -- Sort players within each role by ultimate readiness (descending), then by name
    -- Use display override percentage when available (smart ult upgrade)
    for roleType, players in pairs(playersByRole) do
        table.sort(players, function(a, b)
            local aPercent = a.displayPercent or a.data.ultimatePercent or 0
            local bPercent = b.displayPercent or b.data.ultimatePercent or 0
            
            -- Primary sort: ultimate percentage (higher first)
            if aPercent ~= bPercent then
                return aPercent > bPercent
            end
            
            -- Secondary sort: player name (alphabetical)
            return a.playerName < b.playerName
        end)
    end
    
    -- Update each role window
    for roleType, players in pairs(playersByRole) do
        GUDBR.UpdateRoleWindow(roleType, players)
    end
    
    -- After all role windows are updated, relayout coupled windows once
    -- This must happen after all visibility/sizing is resolved to avoid flicker
    if GUDBR.settings.dynamicVisibility or GUDBR.settings.hideEmptyColumns then
        GUDBR.RelayoutCoupledWindows()
    end
end

--[[
    Update a single role window with its players
]]--
function GUDBR.UpdateRoleWindow(roleType, players)
    local window = GUDBR.roleWindows[roleType]
    if not window then return end
    
    local playerCount = #players
    
    -- Determine visibility
    -- Manual mode: always show if the role setting is on
    -- Dynamic/hideEmptyColumns: hide windows with 0 players (auto-squish)
    local manualVisible = GUDBR.settings.enabled and GUDBR.GetRoleVisibilitySetting(roleType) and not GUDBR.menuHidden and not GUDBR.pvpHidden
    local visible = manualVisible
    if visible and (GUDBR.settings.dynamicVisibility or GUDBR.settings.hideEmptyColumns) and playerCount == 0 then
        visible = false
    end
    window.control:SetHidden(not visible)
    if not visible then return end
    
    -- Ensure we have enough player bars
    while #GUDBR.playerBars[roleType] < playerCount do
        local bar = GUDBR.CreatePlayerBar(window.container, #GUDBR.playerBars[roleType] + 1, roleType)
        table.insert(GUDBR.playerBars[roleType], bar)
    end
    
    -- Update each player bar
    for i, playerInfo in ipairs(players) do
        GUDBR.UpdatePlayerBar(GUDBR.playerBars[roleType][i], playerInfo.playerName, playerInfo.data, playerInfo.displayUltId, playerInfo.displayPercent)
    end
    
    -- Hide unused bars
    for i = playerCount + 1, #GUDBR.playerBars[roleType] do
        local playerBar = GUDBR.playerBars[roleType][i]
        if playerBar and playerBar.container then
            playerBar.container:SetHidden(true)
        end
    end
    
    -- Resize window to fit players (or just header if no players)
    local width = GUDBR.PLAYER_BAR_WIDTH + (GUDBR.WINDOW_PADDING * 2)
    local height = GUDBR.GetEffectiveHeaderHeight() + (GUDBR.WINDOW_PADDING * 2) + (playerCount * (GUDBR.PLAYER_BAR_HEIGHT + 2))
    window.control:SetDimensions(width, height)
    if window.backdrop then
        window.backdrop:SetDimensions(width, height)
    end
    window.container:SetDimensions(GUDBR.PLAYER_BAR_WIDTH, playerCount * (GUDBR.PLAYER_BAR_HEIGHT + 2))
end

--[[
    Update a single player bar with data
    @param bar - The player bar UI control
    @param playerName - Character name
    @param data - Player data from broadcast (selectedUltimateId, ultimatePercent, etc.)
    @param displayUltId - (optional) Override ability ID for display (smart ult upgrade)
    @param displayPercent - (optional) Override percentage for display (smart ult upgrade)
]]--
function GUDBR.UpdatePlayerBar(bar, playerName, data, displayUltId, displayPercent)
    if not bar or not data then return end
    
    local UT = Beltalowda.Data.UltimateTracker
    
    -- Find unit tag for this player
    local unitTag = GUDBR.FindUnitTagForPlayer(playerName)
    if not unitTag then return end
    
    bar.unitTag = unitTag
    bar.container:SetHidden(false)
    
    -- Use display override if provided (smart ult upgrade), otherwise use selected ult
    local ultId = displayUltId or data.selectedUltimateId
    local ultPercent = displayPercent or data.ultimatePercent or 0
    
    -- Update ultimate icon
    bar.abilityId = ultId
    bar.originalAbilityId = data.selectedUltimateId
    bar.abilityName = GetAbilityName(ultId) or GUDBR.DEFAULT_ABILITY_NAME
    local iconPath = GetAbilityIcon(ultId)
    if iconPath and iconPath ~= "" then
        bar.icon:SetTexture(iconPath)
    else
        bar.icon:SetTexture(GUDBR.DEFAULT_ABILITY_ICON)
    end
    
    -- Show original-ult overlay when smart upgrade is active
    -- (displayUltId differs from the player's actual selected ult)
    -- Volendrung (#125): always hide overlay — this is a replaced case, not an upgrade
    if bar.originalOverlay then
        if data.hasVolendrung then
            -- Volendrung replaces all skills; show full Ruinous Cyclone icon, no overlay
            bar.originalOverlay:SetHidden(true)
        elseif displayUltId and displayUltId ~= data.selectedUltimateId then
            if GUDBR.settings.showOriginalUltAsMain then
                -- User wants original ult as main icon, upgrade in overlay
                local originalPath = GetAbilityIcon(data.selectedUltimateId)
                if originalPath and originalPath ~= "" then
                    bar.icon:SetTexture(originalPath)
                end
                local upgradePath = GetAbilityIcon(displayUltId)
                if upgradePath and upgradePath ~= "" then
                    bar.originalOverlay:SetTexture(upgradePath)
                else
                    bar.originalOverlay:SetTexture(GUDBR.DEFAULT_ABILITY_ICON)
                end
            else
                -- Default: upgrade as main icon, original in overlay
                local originalPath = GetAbilityIcon(data.selectedUltimateId)
                if originalPath and originalPath ~= "" then
                    bar.originalOverlay:SetTexture(originalPath)
                else
                    bar.originalOverlay:SetTexture(GUDBR.DEFAULT_ABILITY_ICON)
                end
            end
            bar.originalOverlay:SetHidden(false)
        else
            bar.originalOverlay:SetHidden(true)
        end
    end
    
    -- Register this ultimate with the tracker
    UT.RegisterUltimate(ultId)
    
    -- Update player name
    local characterName = Beltalowda.GetDisplayName(unitTag)
    bar.nameLabel:SetText(characterName)
    
    -- Update ultimate percentage (using override if provided)
    bar.ultimatePercent = ultPercent
    bar.currentUlt = GUDBR.GetRawUltValue(data)
    
    -- Update ultimate resource bar
    bar.ultimateBar:SetValue(math.min(bar.ultimatePercent, 100))
    
    -- Bar color: light blue while charging, bright green when ready (≥100%)
    if bar.ultimatePercent >= 100 then
        bar.ultimateBar:SetColor(GUD.COLORS.ULTIMATE_FULL[1], GUD.COLORS.ULTIMATE_FULL[2], GUD.COLORS.ULTIMATE_FULL[3])
    else
        bar.ultimateBar:SetColor(GUD.COLORS.ULTIMATE_NOT_FULL[1], GUD.COLORS.ULTIMATE_NOT_FULL[2], GUD.COLORS.ULTIMATE_NOT_FULL[3])
    end
    
    -- Orange glow: visible when at MAX (500 ult) with an ult-spending set,
    -- OR when Volendrung player has enough ult to cast Ruinous Cyclone (#125)
    local hasMaxUlt = data.currentUlt and data.currentUlt >= 500
    local showGlow = false
    if data.hasVolendrung and ultPercent >= 100 then
        -- Volendrung: glow when Ruinous Cyclone is castable (replaced case)
        showGlow = true
    elseif hasMaxUlt then
        local SetDB = Beltalowda.SetDatabase
        if SetDB and SetDB.HasUltSpendingSet and bar.unitTag then
            local equipData = Beltalowda.network and Beltalowda.network.groupData
                and Beltalowda.network.groupData[bar.unitTag]
                and Beltalowda.network.groupData[bar.unitTag].equipment
                and Beltalowda.network.groupData[bar.unitTag].equipment.rawData
            if equipData then
                showGlow = SetDB.HasUltSpendingSet(equipData)
            end
        end
    end
    for _, glow in ipairs(bar.glowLayers) do
        glow:SetHidden(not showGlow)
    end
    
    -- Update resource bars
    bar.magickaPercent = data.magickaPercent or 0
    bar.staminaPercent = data.staminaPercent or 0
    bar.magickaBar:SetValue(bar.magickaPercent)
    bar.staminaBar:SetValue(bar.staminaPercent)
    
    -- Update combat state border
    bar.inCombat = data.inCombat or false
    if bar.inCombat then
        bar.combatBorder:SetEdgeColor(GUD.COLORS.IN_COMBAT[1], GUD.COLORS.IN_COMBAT[2], GUD.COLORS.IN_COMBAT[3], 1)
    else
        bar.combatBorder:SetEdgeColor(GUD.COLORS.OUT_OF_COMBAT[1], GUD.COLORS.OUT_OF_COMBAT[2], GUD.COLORS.OUT_OF_COMBAT[3], 1)
    end
end

--[[
    Refresh the unitTag cache for efficient player lookups
]]--
function GUDBR.RefreshUnitTagCache()
    GUDBR.unitTagCache = {}
    
    -- Cache player
    local playerName = GetUnitName("player")
    if playerName then
        GUDBR.unitTagCache[playerName] = "player"
    end
    
    -- Cache group members
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local name = GetUnitName(unitTag)
            if name then
                GUDBR.unitTagCache[name] = unitTag
            end
        end
    end
end

--[[
    Find unit tag for a player name (using cache)
]]--
function GUDBR.FindUnitTagForPlayer(playerName)
    return GUDBR.unitTagCache[playerName]
end

--[[
    Toggle enabled state
]]--
function GUDBR.SetEnabled(enabled)
    GUDBR.settings.enabled = enabled
    GUDBR.SaveSettings()
    GUDBR.ApplySettings()
    
    -- Register or unregister update events based on enabled state
    if enabled then
        -- Register update event if not already registered
        if not GUDBR.updateRegistered then
            EVENT_MANAGER:RegisterForUpdate("BeltalowdaGroupUltimateDisplayByRoles", 5000, function()
                GUDBR.RefreshDisplay()
            end)
            GUDBR.updateRegistered = true
        end
        GUDBR.RefreshDisplay()
    else
        -- Unregister update event when disabled to avoid unnecessary processing
        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaGroupUltimateDisplayByRoles")
        GUDBR.updateRegistered = false
    end
end



-- ============================================================================
-- Settings Panel Controls (called from BeltalowdaSettings.lua)
-- ============================================================================

function GUDBR.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFUltimate Tracker|r |t24:24:esoui/art/icons/powerpellet_health.dds|t|t24:24:esoui/art/icons/powerpellet_magicka.dds|t|t24:24:esoui/art/icons/powerpellet_stamina.dds|t|t24:24:esoui/art/icons/procs_001.dds|t",
            tooltip = "Track ultimates organized by role (Pull/Damage/Support)",
            controls = {
                {
                    type = "description",
                    text = "Tracks reported ultimates across your group and stacks them in columns based on role. Columns only appear when there is something to track. Coupled windows display in order: Damage | Shields | Heals | Utility (left to right). Individual windows can be decoupled and repositioned independently.",
                    width = "full",
                },
                -- Enable Role-Based Tracker
                {
                    type = "checkbox",
                    name = "Enable Role-Based Tracker",
                    tooltip = "Show role-based ultimate tracker (this is the primary ultimate tracking system)",
                    getFunc = function() return GUDBR.settings.enabled end,
                    setFunc = function(value) GUDBR.SetEnabled(value) end,
                    width = "full",
                    default = true,
                },
                -- Prevent Movement toggle
                {
                    type = "checkbox",
                    name = "Prevent Movement",
                    tooltip = "When enabled, windows cannot be dragged. When disabled, click and drag anywhere on the tracker to reposition it.",
                    getFunc = function() return GUDBR.settings.preventMovement end,
                    setFunc = function(value) GUDBR.SetPreventMovement(value) end,
                    width = "full",
                    default = false,
                },
                -- Visibility Mode dropdown
                {
                    type = "dropdown",
                    name = "Visibility Mode",
                    tooltip = "Dynamic: auto-hides empty role categories and squishes remaining columns together. Manual: always shows role categories based on the Show toggles below.",
                    choices = {"Dynamic", "Manual"},
                    choicesValues = {"dynamic", "manual"},
                    getFunc = function()
                        return GUDBR.settings.dynamicVisibility and "dynamic" or "manual"
                    end,
                    setFunc = function(value) GUDBR.SetVisibilityMode(value) end,
                    width = "full",
                    default = "dynamic",
                },
                -- UI Scale slider
                {
                    type = "slider",
                    name = "UI Scale",
                    tooltip = "Scale of the ultimate tracker windows",
                    min = 0.3,
                    max = 1.0,
                    step = 0.01,
                    decimals = 2,
                    getFunc = function() return GUDBR.settings.scale end,
                    setFunc = function(value)
                        GUDBR.settings.scale = value
                        GUDBR.ApplySettings()
                        GUDBR.SaveSettings()
                    end,
                    width = "full",
                    default = 0.7907,
                },
                -- UI Opacity slider
                {
                    type = "slider",
                    name = "UI Opacity",
                    tooltip = "Transparency of the ultimate tracker windows (0 = invisible, 1 = opaque)",
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    getFunc = function() return GUDBR.settings.opacity end,
                    setFunc = function(value)
                        GUDBR.settings.opacity = value
                        GUDBR.ApplySettings()
                        GUDBR.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
                -- Hide Headers
                {
                    type = "checkbox",
                    name = "Hide Headers",
                    tooltip = "Hide the role category headers (Utility/Damage/Heals/Shields) to save space",
                    getFunc = function() return GUDBR.settings.hideHeaders end,
                    setFunc = function(value)
                        GUDBR.settings.hideHeaders = value
                        GUDBR.SaveSettings()
                        GUDBR.ApplySettings()
                        GUDBR.RefreshDisplay()
                    end,
                    width = "full",
                    default = false,
                },
                -- Hide Empty Columns
                {
                    type = "checkbox",
                    name = "Hide Empty Columns",
                    tooltip = "Automatically hide role columns that have no players and squish remaining columns together",
                    getFunc = function() return GUDBR.settings.hideEmptyColumns end,
                    setFunc = function(value)
                        GUDBR.settings.hideEmptyColumns = value
                        GUDBR.SaveSettings()
                        GUDBR.ApplySettings()
                        GUDBR.RefreshDisplay()
                    end,
                    width = "full",
                    default = true,
                },
                -- Decouple Utility Window
                {
                    type = "checkbox",
                    name = "Decouple Utility Window",
                    tooltip = "When enabled, Utility window can be positioned independently. When disabled, it's part of the coupled group (Damage | Shields | Heals | Utility).",
                    getFunc = function() return GUDBR.settings.utilityDecoupled end,
                    setFunc = function(value) GUDBR.SetRoleDecoupled(GUDBR.ROLE_UTILITY, value) end,
                    width = "half",
                    default = false,
                },
                -- Decouple Damage Window
                {
                    type = "checkbox",
                    name = "Decouple Damage Window",
                    tooltip = "When enabled, Damage window can be positioned independently. When disabled, it's part of the coupled group (Damage | Shields | Heals | Utility).",
                    getFunc = function() return GUDBR.settings.damageDecoupled end,
                    setFunc = function(value) GUDBR.SetRoleDecoupled(GUDBR.ROLE_DAMAGE, value) end,
                    width = "half",
                    default = false,
                },
                -- Decouple Heals Window
                {
                    type = "checkbox",
                    name = "Decouple Heals Window",
                    tooltip = "When enabled, Heals window can be positioned independently. When disabled, it's part of the coupled group (Damage | Shields | Heals | Utility).",
                    getFunc = function() return GUDBR.settings.healsDecoupled end,
                    setFunc = function(value) GUDBR.SetRoleDecoupled(GUDBR.ROLE_HEALS, value) end,
                    width = "half",
                    default = false,
                },
                -- Decouple Shields Window
                {
                    type = "checkbox",
                    name = "Decouple Shields Window",
                    tooltip = "When enabled, Shields window can be positioned independently. When disabled, it's part of the coupled group (Damage | Shields | Heals | Utility).",
                    getFunc = function() return GUDBR.settings.shieldsDecoupled end,
                    setFunc = function(value) GUDBR.SetRoleDecoupled(GUDBR.ROLE_SHIELDS, value) end,
                    width = "half",
                    default = false,
                },
                -- Show Utility Window
                {
                    type = "checkbox",
                    name = "Show Utility Window",
                    tooltip = "Show the Utility role window (War Horn, Werewolf Transformation, etc.). Only used in Manual visibility mode.",
                    getFunc = function() return GUDBR.settings.showUtility end,
                    setFunc = function(value)
                        GUDBR.settings.showUtility = value
                        GUDBR.SaveSettings()
                        GUDBR.ApplySettings()
                        GUDBR.RefreshDisplay()
                    end,
                    width = "half",
                    default = true,
                    disabled = function() return GUDBR.settings.dynamicVisibility end,
                },
                -- Show Damage Window
                {
                    type = "checkbox",
                    name = "Show Damage Window",
                    tooltip = "Show the Damage role window (Meteor, Dawnbreaker, Eye of the Storm, etc.). Only used in Manual visibility mode.",
                    getFunc = function() return GUDBR.settings.showDamage end,
                    setFunc = function(value)
                        GUDBR.settings.showDamage = value
                        GUDBR.SaveSettings()
                        GUDBR.ApplySettings()
                        GUDBR.RefreshDisplay()
                    end,
                    width = "half",
                    default = true,
                    disabled = function() return GUDBR.settings.dynamicVisibility end,
                },
                -- Show Heals Window
                {
                    type = "checkbox",
                    name = "Show Heals Window",
                    tooltip = "Show the Heals role window (Panacea, Life Giver, Light's Champion, etc.). Only used in Manual visibility mode.",
                    getFunc = function() return GUDBR.settings.showHeals end,
                    setFunc = function(value)
                        GUDBR.settings.showHeals = value
                        GUDBR.SaveSettings()
                        GUDBR.ApplySettings()
                        GUDBR.RefreshDisplay()
                    end,
                    width = "half",
                    default = true,
                    disabled = function() return GUDBR.settings.dynamicVisibility end,
                },
                -- Show Shields Window
                {
                    type = "checkbox",
                    name = "Show Shields Window",
                    tooltip = "Show the Shields role window (Barrier, Gibbering Shelter, etc.). Only used in Manual visibility mode.",
                    getFunc = function() return GUDBR.settings.showShields end,
                    setFunc = function(value)
                        GUDBR.settings.showShields = value
                        GUDBR.SaveSettings()
                        GUDBR.ApplySettings()
                        GUDBR.RefreshDisplay()
                    end,
                    width = "half",
                    default = true,
                    disabled = function() return GUDBR.settings.dynamicVisibility end,
                },
                -- ===== Smart Ult Tracking (#87) =====
                {
                    type = "header",
                    name = "|cFFD700Smart Ult Tracking|r",
                    width = "full",
                },
                {
                    type = "description",
                    text = "Modifies the reported ultimate shared with group members to indicate special cases.",
                    width = "full",
                },
                -- ── Damage Upgrade ──
                {
                    type = "description",
                    text = "|cFFD700Damage Upgrade|r: If a damage player has a cheap primary ult and an expensive secondary ult, only the cheap one is reported until the expensive one is ready to cast — then both are shown. This gives the group leader visibility into what damage options are available at any given time.\n\nVolendrung is a special case: it replaces all skills, so the player's base ult is always upgraded to Ruinous Cyclone regardless of other settings.",
                    width = "full",
                },
                -- Smart Damage Upgrade
                {
                    type = "checkbox",
                    name = "Damage Upgrade",
                    tooltip = "When a player has two damage ults with different costs (e.g. Take Flight + Eye of Frost), show the expensive ult icon when they can afford it and the cheap ult icon when they can't.",
                    getFunc = function() return GUDBR.settings.smartDamageUpgrade end,
                    setFunc = function(value)
                        GUDBR.settings.smartDamageUpgrade = value
                        GUDBR.SaveSettings()
                        GUDBR.RefreshDisplay()
                    end,
                    width = "full",
                    default = true,
                },
                -- Ignore Soul Harvest
                {
                    type = "checkbox",
                    name = "Ignore Soul Harvest",
                    tooltip = "Exclude Soul Harvest from the damage upgrade logic. Soul Harvest is typically slotted for its passive (increased ult gen on kill) rather than being cast, so it should not trigger the cheap/expensive ult swap.",
                    getFunc = function() return GUDBR.settings.ignoreSoulHarvest end,
                    setFunc = function(value)
                        GUDBR.settings.ignoreSoulHarvest = value
                        GUDBR.SaveSettings()
                        GUDBR.RefreshDisplay()
                    end,
                    width = "full",
                    default = true,
                    disabled = function() return not GUDBR.settings.smartDamageUpgrade end,
                },
                -- Show Original Ult as Main Icon
                {
                    type = "checkbox",
                    name = "Show Original Ult as Main Icon",
                    tooltip = "When a damage upgrade is available, show the original ult as the main icon and the upgrade in the small overlay. When off, the upgrade is shown as the main icon.",
                    getFunc = function() return GUDBR.settings.showOriginalUltAsMain end,
                    setFunc = function(value)
                        GUDBR.settings.showOriginalUltAsMain = value
                        GUDBR.SaveSettings()
                        GUDBR.RefreshDisplay()
                    end,
                    width = "full",
                    default = false,
                    disabled = function() return not GUDBR.settings.smartDamageUpgrade end,
                },
                -- ── Reanimate ──
                {
                    type = "description",
                    text = "|cFFD700Reanimate|r: A support player can run any primary support ult with Reanimate as their secondary. When Reanimate is ready to cast it appears in the Utility column. You can configure whether the player is shown in both their original category (Heals or Shields) and Utility, or moved to Utility only. This gives the group leader visibility into when the rez ult is ready.",
                    width = "full",
                },
                -- Reanimate Tracking
                {
                    type = "checkbox",
                    name = "Reanimate Tracking",
                    tooltip = "Show Necromancers in the Utility window when their backbar Reanimate is affordable (cost 200). This lets raid leads see who can mass-rez 3 dead players.",
                    getFunc = function() return GUDBR.settings.reanimateTracking end,
                    setFunc = function(value)
                        GUDBR.settings.reanimateTracking = value
                        GUDBR.SaveSettings()
                        GUDBR.RefreshDisplay()
                    end,
                    width = "full",
                    default = true,
                },
                -- Reanimate Display Mode
                {
                    type = "dropdown",
                    name = "Reanimate Display Mode",
                    tooltip = "How to display players with affordable Reanimate. 'Both' shows them in their original role AND the Utility window. 'Switch' moves them from their original role to Utility only.",
                    choices = {"Both Windows", "Switch to Utility"},
                    choicesValues = {"both", "switch"},
                    getFunc = function() return GUDBR.settings.reanimateDisplayMode end,
                    setFunc = function(value)
                        GUDBR.settings.reanimateDisplayMode = value
                        GUDBR.SaveSettings()
                        GUDBR.RefreshDisplay()
                    end,
                    width = "full",
                    default = "both",
                    disabled = function() return not GUDBR.settings.reanimateTracking end,
                },
                -- ===== Client Ultimate Selector =====
                {
                    type = "header",
                    name = "|cFFD700Client Ultimate Selector|r",
                    width = "full",
                },
                {
                    type = "description",
                    text = "A clickable button that lets you override the dynamically detected ultimate or simply see which ultimate is currently being reported to your group. Click the icon on-screen to choose a different ultimate.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Client Ultimate Selector",
                    tooltip = "Show the client ultimate selector button on-screen",
                    getFunc = function()
                        local CUS = Beltalowda.UI and Beltalowda.UI.ClientUltimateSelector
                        return CUS and CUS.settings and CUS.settings.enabled or false
                    end,
                    setFunc = function(value)
                        local CUS = Beltalowda.UI and Beltalowda.UI.ClientUltimateSelector
                        if CUS then
                            CUS.settings.enabled = value
                            CUS.ApplySettings()
                            CUS.SaveSettings()
                        end
                    end,
                    width = "full",
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Lock Selector Position",
                    tooltip = "Lock the client ultimate selector in place (prevents accidental movement)",
                    getFunc = function()
                        local CUS = Beltalowda.UI and Beltalowda.UI.ClientUltimateSelector
                        return CUS and CUS.settings and CUS.settings.locked or false
                    end,
                    setFunc = function(value)
                        local CUS = Beltalowda.UI and Beltalowda.UI.ClientUltimateSelector
                        if CUS then
                            CUS.settings.locked = value
                            CUS.ApplySettings()
                            CUS.SaveSettings()
                        end
                    end,
                    width = "full",
                    default = false,
                },
                {
                    type = "slider",
                    name = "Selector Scale",
                    tooltip = "Scale of the client ultimate selector",
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    getFunc = function()
                        local CUS = Beltalowda.UI and Beltalowda.UI.ClientUltimateSelector
                        return CUS and CUS.settings and CUS.settings.scale or 1.0
                    end,
                    setFunc = function(value)
                        local CUS = Beltalowda.UI and Beltalowda.UI.ClientUltimateSelector
                        if CUS then
                            CUS.settings.scale = value
                            CUS.ApplySettings()
                            CUS.SaveSettings()
                        end
                    end,
                    width = "full",
                    default = 1.0,
                },
                {
                    type = "slider",
                    name = "Selector Opacity",
                    tooltip = "Transparency of the client ultimate selector (0 = invisible, 1 = opaque)",
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    getFunc = function()
                        local CUS = Beltalowda.UI and Beltalowda.UI.ClientUltimateSelector
                        return CUS and CUS.settings and CUS.settings.opacity or 1.0
                    end,
                    setFunc = function(value)
                        local CUS = Beltalowda.UI and Beltalowda.UI.ClientUltimateSelector
                        if CUS then
                            CUS.settings.opacity = value
                            CUS.ApplySettings()
                            CUS.SaveSettings()
                        end
                    end,
                    width = "full",
                    default = 1.0,
                },
            },
        },
    }
end
