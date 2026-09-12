MCAT_Abilities = {}

-- TODO : Vengeance abilities

-- #region [Teal] Generic
local HOTBAR_CATEGORIES = { HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP }

function MCAT_Abilities.IsAbilitySlotted(skillIds)
    for _, hotbarCategory in ipairs(HOTBAR_CATEGORIES) do
        for i = 3, 8 do
            local actionType = GetSlotType(i, hotbarCategory)
            if (actionType == ACTION_TYPE_ABILITY) then
                if (skillIds[GetSlotBoundId(i, hotbarCategory)]) then
                    return true
                end
            end
        end
    end
    return false
end
-- #endregion

-- #region[purple] Mechanic definitions
-- skillMap: hotbar-slotted skillId -> the buffId that actually carries the stack count.
-- Crux has no skillMap: any Arcanist class-line ability generates it, not one specific slot.
-- pips: angle (radians) per marker pip, ESO GuiRoot y-down convention. Each pip carries its
-- own texture already rotated for that position (rather than one shared texture rotated at
-- runtime via SetTextureRotation) -- runtime rotation at arbitrary angles visibly softened
-- and clipped these shapes' fine detail.
-- GrimFocus's first 4 are the diagonal group, last 4 the cardinal group —
-- order is load-bearing for Interface's lighting logic, not just display order.
MCAT_Definitions = {
    GrimFocus = {
        label = "Grim Focus",
        color = "9D6FE0",
        pipTexturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike.dds",
        skillMap = {
            [61902] = 122585, -- Grim Focus
            [61919] = 122586, -- Merciless Resolve
            [61927] = 122587, -- Relentless Focus
        },
        -- overflowTexturePath is the same shape with its crossbar/hilt added -- overflow stacks are
        -- shown by swapping which texture is bound, not by re-tinting: diagonal pips gain their
        -- hilt all at once at stack 10, cardinal pips gain theirs one at a time at stacks 6-9.
        pips = {
            { angle = -3 * math.pi / 4, lenRatio = 0.587, texturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_diag_tl.dds", overflowTexturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_diag_tl_hilt.dds" },
            { angle = -math.pi / 4,     lenRatio = 0.587, texturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_diag_tr.dds", overflowTexturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_diag_tr_hilt.dds" },
            { angle = math.pi / 4,      lenRatio = 0.587, texturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_diag_br.dds", overflowTexturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_diag_br_hilt.dds" },
            { angle = 3 * math.pi / 4,  lenRatio = 0.587, texturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_diag_bl.dds", overflowTexturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_diag_bl_hilt.dds" },
            { angle = -math.pi / 2,     lenRatio = 0.72, texturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_card_n_nohilt.dds", overflowTexturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_card_n.dds" },
            { angle = 0,                lenRatio = 0.72, texturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_card_e_nohilt.dds", overflowTexturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_card_e.dds" },
            { angle = math.pi / 2,      lenRatio = 0.72, texturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_card_s_nohilt.dds", overflowTexturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_card_s.dds" },
            { angle = math.pi,          lenRatio = 0.72, texturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_card_w_nohilt.dds", overflowTexturePath = "MultiClassAbilityTracker/art/grimfocus/pip_gf_spike_card_w.dds" },
        },
    },
    BoundArmaments = {
        label = "Bound Armaments",
        color = "4EA1F5",
        -- Sits on GrimFocus's diagonal axis (same 4 angles) rather than its cardinal cross,
        -- just past its diagonal spikes' own tips -- avoids the two mechanics crossing/clashing
        -- when both are active, and reads fine as its own compass alone when GrimFocus isn't.
        pipTexturePath = "MultiClassAbilityTracker/art/boundarmaments/pip_ba_chevron_tl.dds",
        skillMap = {
            [24165] = 203447, -- Bound Armaments
        },
        pips = {
            { angle = -3 * math.pi / 4, texturePath = "MultiClassAbilityTracker/art/boundarmaments/pip_ba_chevron_tl.dds", overflowTexturePath = "MultiClassAbilityTracker/art/boundarmaments/pip_ba_chevron_tl_dual.dds" },
            { angle = -math.pi / 4,     texturePath = "MultiClassAbilityTracker/art/boundarmaments/pip_ba_chevron_tr.dds", overflowTexturePath = "MultiClassAbilityTracker/art/boundarmaments/pip_ba_chevron_tr_dual.dds" },
            { angle = math.pi / 4,      texturePath = "MultiClassAbilityTracker/art/boundarmaments/pip_ba_chevron_br.dds", overflowTexturePath = "MultiClassAbilityTracker/art/boundarmaments/pip_ba_chevron_br_dual.dds" },
            { angle = 3 * math.pi / 4,  texturePath = "MultiClassAbilityTracker/art/boundarmaments/pip_ba_chevron_bl.dds", overflowTexturePath = "MultiClassAbilityTracker/art/boundarmaments/pip_ba_chevron_bl_dual.dds" },
        },
    },
    SeethingFury = {
        label = "Seething Fury",
        color = "F0703A",
        pipTexturePath = "MultiClassAbilityTracker/art/seethingfury/pip_sf_s.dds",
        -- Only Molten Whip carries a stacking buff; Lava Whip (23806) and Flame Lash (20816) don't stack.
        skillMap = {
            [20805] = 122658, -- Molten Whip
        },
        pips = {
            { angle = math.pi / 2, texturePath = "MultiClassAbilityTracker/art/seethingfury/pip_sf_s.dds" },
            { angle = math.pi / 2 - 2 * math.pi / 3, texturePath = "MultiClassAbilityTracker/art/seethingfury/pip_sf_ne.dds" },
            { angle = math.pi / 2 - 4 * math.pi / 3, texturePath = "MultiClassAbilityTracker/art/seethingfury/pip_sf_nw.dds" },
        },
    },
    Crux = {
        label = "Crux",
        color = "3FCFA6",
        pipTexturePath = "MultiClassAbilityTracker/art/crux/pip_crux_n.dds",
        buffId = 184220,
        pips = {
            { angle = -math.pi / 2, texturePath = "MultiClassAbilityTracker/art/crux/pip_crux_n.dds" },
            { angle = -math.pi / 2 + 2 * math.pi / 3, texturePath = "MultiClassAbilityTracker/art/crux/pip_crux_se.dds" },
            { angle = -math.pi / 2 + 4 * math.pi / 3, texturePath = "MultiClassAbilityTracker/art/crux/pip_crux_sw.dds" },
        },
    },
}
-- #endregion

-- #region[green] Arcanist
function MCAT_Abilities.CruxGenerationKnown()
    local ARCANIST_CLASS_ID = 117
    for skillLineIndex = GetNumSkillLines(SKILL_TYPE_CLASS), 1, -1 do
        if select(3, GetSkillLineDynamicInfo(SKILL_TYPE_CLASS, skillLineIndex)) then
            if GetSkillLineClassId(SKILL_TYPE_CLASS, skillLineIndex) == ARCANIST_CLASS_ID then
                return true
            end
        end
    end
    return false
end
-- #endregion


-- #region[purple] REFS

-- FROM : imPDA
-- local function GetSkills()
--     local skills = {}

--     for category = HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP do
--         skills[category] = {}
--         for slot = 3, 8 do
--             local slotBoundId = GetSlotBoundId(slot, category)
--             if GetSlotType(slot, category) == ACTION_TYPE_CRAFTED_ABILITY then
--                 local script1, script2, script3 = GetCraftedAbilityActiveScriptIds(slotBoundId)
--                 skills[category][slot] = {
--                     slotBoundId,
--                     script1,
--                     script2,
--                     script3,
--                 }
--             else
--                 skills[category][slot] = slotBoundId  -- or 0 if no skill in slot
--             end
--         end
--     end

--     return skills
-- end

-- FROM : code65536
-- > LibCombatAlerts Public.lua : DoesPlayerHaveAoePurgeSlotted

-- #endregion
