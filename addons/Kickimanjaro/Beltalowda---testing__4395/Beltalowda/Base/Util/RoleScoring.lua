-- Beltalowda Role Scoring
-- Bridge module that unifies equipment-based role detection with ultimate-based
-- role categorization to intelligently select the best ultimate in auto-detect mode.
--
-- Solves the taxonomy gap between two role systems:
--   Equipment (SetDatabase):   damage / support / pull
--   Ultimate  (GUDBR):         ROLE_DAMAGE / ROLE_HEALS / ROLE_SHIELDS / ROLE_UTILITY
--
-- Pull role has no ultimate preference — it is determined entirely by sets.
--
-- See: https://github.com/Kickimanjaro/Beltalowda/issues/66

Beltalowda = Beltalowda or {}
Beltalowda.Util = Beltalowda.Util or {}
Beltalowda.Util.RoleScoring = Beltalowda.Util.RoleScoring or {}

local RS = Beltalowda.Util.RoleScoring

-- ============================================================================
-- Constants
-- ============================================================================

-- Role constants (mirrors GUDBR for consistency)
RS.ROLE_UTILITY = 1
RS.ROLE_DAMAGE  = 2
RS.ROLE_HEALS   = 3
RS.ROLE_SHIELDS = 4

-- ============================================================================
-- Bridge Mapping: Equipment Role → Matching Ultimate Roles
--
-- Maps the SetDatabase equipment roles into the GUDBR ultimate-role taxonomy
-- so we can identify which slotted ultimate matches a player's gear role.
-- ============================================================================

RS.EQUIPMENT_TO_ULT_ROLES = {
    -- Equipment "support" → heal / shield / utility ults
    support = { RS.ROLE_HEALS, RS.ROLE_SHIELDS, RS.ROLE_UTILITY },

    -- Equipment "damage" → damage ults
    damage = { RS.ROLE_DAMAGE },

    -- Equipment "pull" → no ult preference; pull role is determined entirely
    -- by sets, not by ultimates. No bridge mapping needed.
    -- pull = nil  (intentionally absent)
}

-- ============================================================================
-- Core Selection Function
-- ============================================================================

-- ============================================================================
-- Destruction Staff Element Variant Resolution
--
-- GetSlotBoundId returns element-specific ability IDs only for the ACTIVE bar.
-- For the inactive bar it returns the base morph ID (e.g. 83619 instead of
-- 83628 for an ice staff). This resolver maps base morph → element variant
-- using the staff type equipped on the target bar.
-- ============================================================================

-- [base morph ID] → { fire = ID, ice = ID, lightning = ID }
RS.DESTRO_ELEMENT_VARIANTS = {
    [83619] = { fire = 83625, ice = 83628, lightning = 83630 },  -- Elemental Storm
    [84434] = { fire = 85126, ice = 85128, lightning = 85130 },  -- Elemental Rage
    [83642] = { fire = 83682, ice = 83684, lightning = 83686 },  -- Eye of the Storm
}

-- Reverse lookup: element-specific variant ID → base morph ID
-- Built once at load from DESTRO_ELEMENT_VARIANTS so we can efficiently
-- detect when the active bar returns a specific variant and cache it.
RS.DESTRO_VARIANT_TO_BASE = {}
for baseMorphId, variants in pairs(RS.DESTRO_ELEMENT_VARIANTS) do
    for _, variantId in pairs(variants) do
        RS.DESTRO_VARIANT_TO_BASE[variantId] = baseMorphId
    end
end

-- Per-bar cache of resolved element variants.
-- Populated when the active bar returns a specific variant directly, or when
-- weapon-type resolution succeeds. Used as fallback when GetItemWeaponType
-- is unreliable for the inactive bar's equipment slot (known ESO API quirk).
-- Key: hotbarCategory (0 = front, 1 = back), Value: resolved ability ID
RS.resolvedVariantCache = {}

--[[
    Resolve a Destruction Staff ultimate to its element-specific variant.

    When reading the inactive bar, GetSlotBoundId returns the base morph ID
    regardless of staff type. This function checks what staff is equipped on
    the given bar and returns the correct element variant.

    Uses a per-bar cache as fallback: when the active bar returns a specific
    element variant (e.g. Eye of Frost 83684), that variant is cached. On bar
    swap, if weapon-type resolution fails for the now-inactive bar, the cached
    variant is returned instead of the generic base morph.

    Safe to call on any ability ID — returns it unchanged if not a destro ult
    or if the staff type doesn't match a known variant.

    @param abilityId       number  The ability ID from GetSlotBoundId
    @param hotbarCategory  number  0 = front bar, 1 = back bar
    @return number  The element-specific ability ID, or abilityId unchanged
]]--
function RS.ResolveDestroVariant(abilityId, hotbarCategory)
    -- Case 1: abilityId is an element-specific variant (returned by active bar).
    -- Cache it and return unchanged.
    local baseMorphId = RS.DESTRO_VARIANT_TO_BASE[abilityId]
    if baseMorphId then
        RS.resolvedVariantCache[hotbarCategory] = abilityId
        return abilityId
    end

    -- Case 2: abilityId is a base morph (returned by inactive bar).
    -- Try weapon-type resolution, fall back to cache.
    local variants = RS.DESTRO_ELEMENT_VARIANTS[abilityId]
    if not variants then return abilityId end

    -- Determine which equipment slot holds the main-hand weapon for this bar
    local equipSlot
    if hotbarCategory == 0 then
        equipSlot = EQUIP_SLOT_MAIN_HAND     -- front bar
    else
        equipSlot = EQUIP_SLOT_BACKUP_MAIN   -- back bar
    end

    local weaponType = GetItemWeaponType(BAG_WORN, equipSlot)

    local resolved = nil
    if weaponType == WEAPONTYPE_FIRE_STAFF then
        resolved = variants.fire
    elseif weaponType == WEAPONTYPE_FROST_STAFF then
        resolved = variants.ice
    elseif weaponType == WEAPONTYPE_LIGHTNING_STAFF then
        resolved = variants.lightning
    end

    if resolved then
        RS.resolvedVariantCache[hotbarCategory] = resolved
        return resolved
    end

    -- Weapon-type resolution failed (GetItemWeaponType unreliable for inactive
    -- bar equipment slot). Fall back to cached variant from when this bar was
    -- active and returned the element-specific ID directly.
    local cached = RS.resolvedVariantCache[hotbarCategory]
    if cached then
        -- Verify the cached variant belongs to this base morph
        if RS.DESTRO_VARIANT_TO_BASE[cached] == abilityId then
            return cached
        end
        -- Cached variant is for a different base morph (player changed morphs)
        RS.resolvedVariantCache[hotbarCategory] = nil
    end

    return abilityId  -- not a staff weapon or unknown variant
end

--[[
    Select the best ultimate for a player based on equipment role.

    Only called when auto-detect is active (selectedUltimateId == 0) and the
    player has two different ultimates slotted across front/back bars.

    Logic:
    - Find which slotted ult matches the player's gear role
    - If exactly one matches, pick it
    - If both match or neither matches, pick front bar

    Examples:
    - Damage player with Dawnbreaker (front) + Barrier (back) → Dawnbreaker
      (Dawnbreaker is a damage ult, Barrier is not)
    - Support player with Colossus (front) + Barrier (back) → Barrier
      (Barrier is a support ult, Colossus is not)
    - Damage player with Dawnbreaker (front) + Meteor (back) → Dawnbreaker
      (both are damage, front bar wins)

    @param frontUltId     number   Ability ID on front bar slot 8
    @param backUltId      number   Ability ID on back bar slot 8
    @param equipmentRole  string   Role from SetDatabase.DetectRole()
                                   ("damage", "support", or "pull")
    @return number  The ability ID that matches the player's gear role
]]--
function RS.SelectBestUltimate(frontUltId, backUltId, equipmentRole)
    -- Guard: if either bar is empty or both are the same, nothing to decide
    if not frontUltId or frontUltId <= 0 then return backUltId or 0 end
    if not backUltId  or backUltId  <= 0 then return frontUltId end
    if frontUltId == backUltId then return frontUltId end

    -- Look up the GUDBR ultimate role for each bar
    local GUDBR = Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplayByRoles
    if not GUDBR or not GUDBR.ULTIMATE_ROLES then
        return frontUltId
    end

    -- Determine which ult roles match this equipment role
    local preferredRoles = RS.EQUIPMENT_TO_ULT_ROLES[equipmentRole]
    if not preferredRoles then
        return frontUltId
    end

    local frontRole = GUDBR.ULTIMATE_ROLES[frontUltId]
    local backRole  = GUDBR.ULTIMATE_ROLES[backUltId]

    local frontMatches = frontRole and RS.TableContains(preferredRoles, frontRole)
    local backMatches  = backRole  and RS.TableContains(preferredRoles, backRole)

    -- If exactly one matches the role, pick it
    if frontMatches and not backMatches then return frontUltId end
    if backMatches and not frontMatches then return backUltId end

    -- Both match or neither matches — front bar wins
    return frontUltId
end

-- ============================================================================
-- Remote Player Role Determination (for GUDBR role column placement)
-- ============================================================================

--[[
    Determine the correct role column for a remote player.

    Uses the same role-matching logic as SelectBestUltimate: if the player's
    tracked ultimate doesn't match their gear role but the other bar does,
    return the role of the better-matching ultimate.

    When equipment data is NOT available, falls through to the standard
    ULTIMATE_ROLES lookup — no behavior change from today.

    @param selectedUltimateId  number   The tracked ultimate ability ID
    @param frontUltId          number   Front-bar ultimate (from broadcast, may be nil)
    @param backUltId           number   Back-bar ultimate (from broadcast, may be nil)
    @param equipmentRole       string   Equipment role from broadcast (may be nil)
    @return number|nil  GUDBR role constant, or nil if unknown
]]--
function RS.DetermineRoleForDisplay(selectedUltimateId, frontUltId, backUltId, equipmentRole)
    local GUDBR = Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplayByRoles
    if not GUDBR or not GUDBR.ULTIMATE_ROLES then return nil end

    -- If no equipment data, just return the standard role (current behavior)
    if not equipmentRole then
        if selectedUltimateId and selectedUltimateId > 0 then
            return GUDBR.ULTIMATE_ROLES[selectedUltimateId]
        end
        return nil
    end

    -- Use SelectBestUltimate to find which ult matches the role, then return
    -- that ult's role constant for column placement
    if frontUltId and frontUltId > 0 and backUltId and backUltId > 0 then
        local bestUltId = RS.SelectBestUltimate(frontUltId, backUltId, equipmentRole)
        local bestRole = GUDBR.ULTIMATE_ROLES[bestUltId]
        if bestRole then
            return bestRole
        end
    end

    -- Fallback: standard lookup on the tracked ult
    if selectedUltimateId and selectedUltimateId > 0 then
        return GUDBR.ULTIMATE_ROLES[selectedUltimateId]
    end
    return nil
end

-- ============================================================================
-- Local Player Equipment Role Accessor
-- ============================================================================

--[[
    Get the local player's equipment role from the network layer's groupData.
    Falls back to live LibSetDetection query if groupData isn't populated yet.

    @return string  "damage", "support", or "pull" (never nil)
]]--
function RS.GetLocalPlayerEquipmentRole()
    -- Try groupData first (already computed by BroadcastEquipmentAndRole)
    local BN = Beltalowda.network
    if BN and BN.groupData then
        -- Find local player's unitTag
        local playerTag = nil
        for i = 1, GetGroupSize() do
            local tag = GetGroupUnitTagByIndex(i)
            if tag and AreUnitsEqual(tag, "player") then
                playerTag = tag
                break
            end
        end

        if playerTag and BN.groupData[playerTag]
            and BN.groupData[playerTag].equipment
            and BN.groupData[playerTag].equipment.role then
            return BN.groupData[playerTag].equipment.role
        end
    end

    -- Fallback: query LibSetDetection directly
    if LibSetDetection then
        local setData = LibSetDetection.GetUnitSetData("player")
        if setData and Beltalowda.SetDatabase and Beltalowda.SetDatabase.DetectRole then
            return Beltalowda.SetDatabase.DetectRole(setData)
        end
    end

    return "damage"  -- safe default
end

--[[
    Get a remote player's equipment role from the network layer's groupData.

    @param unitTag  string  The group unitTag (e.g. "group1")
    @return string|nil  Role string or nil if no equipment data available
]]--
function RS.GetRemotePlayerEquipmentRole(unitTag)
    local BN = Beltalowda.network
    if not BN or not BN.groupData then return nil end
    if not unitTag then return nil end

    local data = BN.groupData[unitTag]
    if data and data.equipment and data.equipment.role then
        return data.equipment.role
    end

    return nil
end

-- ============================================================================
-- Utility
-- ============================================================================

--[[
    Check if a value exists in a table (array-style).
    @param tbl    table   Array to search
    @param value  any     Value to find
    @return boolean
]]--
function RS.TableContains(tbl, value)
    if not tbl then return false end
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

return RS
