local PriorityRecast  = PriorityRecast

local IsUltimate      = IsAbilityUltimate
local ToCraftedId     = GetAbilityCraftedAbilityId
local FromCraftedId   = GetAbilityIdForCraftedAbilityId
local ProgressionInfo = GetAbilityProgressionXPInfoFromAbilityId
local SkillIndices    = GetSkillAbilityIndicesFromProgressionIndex
local SkillAbilityId  = GetSkillAbilityId

-------------------------------------------------------------------------------
-- Skill ID
-------------------------------------------------------------------------------
-- Skill IDs in ESO are complicated. Skills can have many variants: from
-- elemental types to un/summoned pets and crafted skills. One skill can have
-- many associated IDs. We need a predictable way to compare skills.
--
-- For example, if we want to know where "Power Lash" is slotted, we must first
-- know where the base skill "Lava Whip" is slotted. A better method is to
-- normalize all of our IDs before comparing slots. To do this, we use the
-- skill tree indices. IDs from the skill tree will always be the base skill.
--
-- This eliminates the complexity of variable IDs found in action bar slots.
-------------------------------------------------------------------------------

local function SkillId(id)
	if id == 0 then return nil end

	-- Re-return existing crafted skill ID.
	local craftedId = ToCraftedId(id)
	if craftedId > 0 then return id end

	-- Return skill ID from crafted ability ID.
	local skillId = FromCraftedId(id)
	if skillId > 0 then return skillId end

	-- Return current skill ID from the skill tree.
	local _, progression = ProgressionInfo(id)
	return SkillAbilityId(SkillIndices(progression))
end

-------------------------------------------------------------------------------
-- SKILL CATEGORIES
-------------------------------------------------------------------------------

-- Skills With No Duration ----------------------------------------------------
-- Sadly, there is no obvious way to get this information from the game API.
-- Some skill list no duration in their tooltip but have effects that do have
-- a duration. More so, some healing skills have effects but no timer in the
-- action bar. The most consistent solution is to just keep a table.

local NO_DURATION = {
	-- Arcanist
	[183261] = true,  -- Runemend
	[186189] = true,  -- Evolving Runemend
	[186191] = true,  -- Audacious Runemend
	[185794] = true,  -- Runeblades
	[185803] = true,  -- Writhing Runeblades
	[182977] = true,  -- Escalating Runeblades
	-- Dragonknight
	[23806]  = true,  -- Lava Whip
	[20805]  = true,  -- Molten Whip
	[20816]  = true,  -- Flame Lash
	[256798] = true,  -- Volcanic Whip
	[20824]  = true,  -- Power Lash
	-- Necromancer
	[115115] = true,  -- Death Scythe
	[114108] = true,  -- Flame Skull
	[117624] = true,  -- Venom Skull
	[117637] = true,  -- Ricochet Skull
	[114196] = true,  -- Render Flesh
	[117883] = true,  -- Resistant Flesh
	[117888] = true,  -- Blood Sacrifice
	[115307] = true,  -- Expunge
	[117940] = true,  -- Expunge and Modify
	[117919] = true,  -- Hexproof
	[115315] = true,  -- Life amid Death
	[118017] = true,  -- Renewing Undeath
	[118809] = true,  -- Enduring Undeath
	-- Nightblade
	[25255]  = true,  -- Veiled Strike
	[25260]  = true,  -- Surprise Attack
	[25267]  = true,  -- Concealed Weapon
	[33386]  = true,  -- Assassin's Blade
	[34843]  = true,  -- Killer's Blade
	[34851]  = true,  -- Impale
	[61902]  = true,  -- Grim Focus
	[61927]  = true,  -- Relentless Focus
	[61919]  = true,  -- Merciless Resolve
	[33319]  = true,  -- Siphoning Strikes
	[36908]  = true,  -- Leeching Strikes
	[36935]  = true,  -- Siphoning Attacks
	[35445]  = true,  -- Shadow Image Teleport
	-- Sorcerer
	[23304]  = true,  -- Unstable Familiar  (Not Summoned)
	[23319]  = true,  -- Unstable Clannfear (Not Summoned)
	[23316]  = true,  -- Volatile Familiar  (Not Summoned)
	[24613]  = true,  -- Winged Twilight    (Not Summoned)
	[24636]  = true,  -- Twilight Tormentor (Not Summoned)
	[24639]  = true,  -- Twilight Matriarch (Not Summoned)
	[108845] = true,  -- Winged Twilight    (Heal)
	[77369]  = true,  -- Twilight Matriarch (Heal)
	[76076]  = true,  -- Unstable Clannfear (Heal)
	[114716] = true,  -- Crystal Fragments  (Proc)
	[24165]  = true,  -- Bound Armaments
	[18718]  = true,  -- Mages' Fury
	[19123]  = true,  -- Mages' Wrath
	[19109]  = true,  -- Endless Fury
	[23234]  = true,  -- Bolt Escape
	[23236]  = true,  -- Streak
	[23277]  = true,  -- Ball of Lightning
	-- Templar
	[26114]  = true,  -- Puncturing Strikes
	[26792]  = true,  -- Biting Jabs
	[26797]  = true,  -- Puncturing Sweep
	[26158]  = true,  -- Piercing Javelin
	[26800]  = true,  -- Aurora Javelin
	[26804]  = true,  -- Binding Javelin
	[63029]  = true,  -- Radiant Destruction
	[63044]  = true,  -- Radiant Glory
	[63046]  = true,  -- Radiant Oppression
	[22250]  = true,  -- Rushed Ceremony
	[22253]  = true,  -- Honor the Dead
	[22256]  = true,  -- Breath of Life
	[22304]  = true,  -- Healing Ritual
	[22327]  = true,  -- Ritual of Rebirth
	[26821]  = true,  -- Repentance
	-- Warden
	[85995]  = true,  -- Dive
	[85536]  = true,  -- Fungal Growth
	[85863]  = true,  -- Soothing Spores
	[85859]  = true,  -- Bursting Vines
	-- Two-handed
	[28279]  = true,  -- Uppercut
	[38814]  = true,  -- Dizzying Swing
	[28448]  = true,  -- Critical Charge
	[38778]  = true,  -- Critical Rush
	[28302]  = true,  -- Reverse Slash
	[38823]  = true,  -- Reverse Slice
	[38819]  = true,  -- Executioner
	-- Sword and Shield
	[28719]  = true,  -- Shield Charge
	[38405]  = true,  -- Invasion
	[28365]  = true,  -- Power Bash
	[38455]  = true,  -- Reverberating Bash
	[38452]  = true,  -- Power Slam
	-- Dual Wield
	[28607]  = true,  -- Flurry
	[38857]  = true,  -- Rapid Strikes
	[38846]  = true,  -- Bloodthirst
	[28591]  = true,  -- Whirlwind
	[38891]  = true,  -- Whirling Blades
	[38861]  = true,  -- Steel Tornado
	-- Bow
	[28882]  = true,  -- Snipe
	[38687]  = true,  -- Focused Aim
	[28879]  = true,  -- Scatter Shot
	[38672]  = true,  -- Magnum Shot
	[38669]  = true,  -- Draining Shot
	[31271]  = true,  -- Arrow Spray
	[38705]  = true,  -- Bombard
	-- Destruction Staff
	[46340]  = true,  -- Force Shock
	[46348]  = true,  -- Crushing Shock
	[46356]  = true,  -- Force Pulse
	[38984]  = true,  -- Destructive Clench
	[28800]  = true,  -- Impulse
	[39143]  = true,  -- Elemental Ring
	[39161]  = true,  -- Pulsar
	-- Vampire
	[32893]  = true,  -- Eviscerate
	[38949]  = true,  -- Blood for Blood
	[38956]  = true,  -- Arterial Burst
	[132141] = true,  -- Blood Frenzy
	[134160] = true,  -- Simmering Frenzy
	[135841] = true,  -- Sated Fury
	[128709] = true,  -- Mesmerize
	[137861] = true,  -- Hypnosis
	[138097] = true,  -- Stupefy
	[32986]  = true,  -- Mist Form
	[38963]  = true,  -- Elusive Mist
	-- Werewolf
	[58310]  = true,  -- Hircine's Bounty
	[58325]  = true,  -- Hircine's Fortitude
	[58405]  = true,  -- Gnash
	[58798]  = true,  -- Bloody Gnash
	-- Fighters Guild
	[35721]  = true,  -- Silver Bolts
	[40300]  = true,  -- Silver Shards
	-- Mages Guild
	[31642]  = true,  -- Equilibrium
	[103543] = true,  -- Mend Wounds
	[103755] = true,  -- Symbiosis
	-- Psijic Order
	[103492] = true,  -- Meditate
	[103652] = true,  -- Deep Thoughts
	[103665] = true,  -- Introspection
	-- Support
	[38571]  = true,  -- Purge
	[40232]  = true,  -- Efficient Purge
	[40234]  = true,  -- Cleanse
	[61511]  = true,  -- (Inactive) Guard
	[61536]  = true,  -- (Inactive) Mystic Guard
	[61529]  = true,  -- (Inactive) Stalwart Guard
	[78338]  = true,  -- (Active) Guard
	[81415]  = true,  -- (Active) Mystic Guard
	[81420]  = true,  -- (Active) Stalwart Guard
}


-- Reactive Skills ------------------------------------------------------------
-- Some skills are two skills in one. Reactive skills represent a skill state
-- that the player might want to react to, like a proc or dead pet.

local REACTIVE = {
	[114716] = true,  -- Crystal Fragments  (Proc)
	[23304]  = true,  -- Unstable Familiar  (Not Summoned)
	[23319]  = true,  -- Unstable Clannfear (Not Summoned)
	[23316]  = true,  -- Volatile Familiar  (Not Summoned)
	[24613]  = true,  -- Winged Twilight    (Not Summoned)
	[24636]  = true,  -- Twilight Tormentor (Not Summoned)
	[24639]  = true,  -- Twilight Matriarch (Not Summoned)
	[256798] = true,  -- Volcanic Whip
	[20824]  = true,  -- Power Lash
	[35445]  = true,  -- Shadow Image Teleport
	[61511]  = true,  -- (Inactive) Guard
	[61536]  = true,  -- (Inactive) Mystic Guard
	[61529]  = true,  -- (Inactive) Stalwart Guard
}


-- Activated Skills -----------------------------------------------------------
-- Skills that that can only, or should only, be cast once they become "active"
-- via some mechanic, like crux. These skills become highlighted in the action
-- bar when ready to cast.

local ACTIVATED = {
	[24165]  = true,  -- Bound Armaments
	[61902]  = true,  -- Grim Focus
	[61927]  = true,  -- Relentless Focus
	[61919]  = true,  -- Merciless Resolve
	[185823] = true,  -- Tentacular Dread
	[185894] = true,  -- Runespite Ward
	[185901] = true,  -- Spiteward of the Lucid Mind
	[183241] = true,  -- Impervious Runeward
	[186477] = true,  -- Unbreakable Fate
	[185805] = true,  -- Fatecarver
	[183122] = true,  -- Exhausting Fatecarver
	[186366] = true,  -- Pragmatic Fatecarver
	[183537] = true,  -- Remedy Cascade
	[186193] = true,  -- Cascading Fortune
	[186200] = true,  -- Curative Surge
	[186209] = true,  -- Tidal Chakram
}


-- Execute Skills -------------------------------------------------------------
-- Skills which cause you to do more damage to enemies below a certain health
-- threshold. See: https://en.uesp.net/wiki/Online:Execute

local EXECUTE = {
	[18718] = 0.20,   -- Mages' Fury
	[19123] = 0.20,   -- Mages' Wrath
	[19109] = 0.20,   -- Endless Fury
	[33386] = 0.25,   -- Assassin's Blade
	[34843] = 0.50,   -- Killer's Blade
	[34851] = 0.25,   -- Impale
	[63029] = 0.33,   -- Radiant Destruction
	[63044] = 0.33,   -- Radiant Glory
	[63046] = 0.40,   -- Radiant Oppression
	[28302] = 0.50,   -- Reverse Slash
	[38823] = 0.50,   -- Reverse Slice
	[38819] = 0.50,   -- Executioner
	[28591] = 0.50,   -- Whirlwind
	[38891] = 0.50,   -- Whirling Blades
	[38861] = 0.50,   -- Steel Tornado
	[38660] = 0.50,   -- Poison Injection
}


-- Alternate Map --------------------------------------------------------------
-- Some skills are two skills in one. These are skills that represent some
-- alternate state like a proc or un/summoned pet from the base skill. This
-- maps from a base skill to it's alternate.

local ALTERNATE_MAP = {
	[46324] = 114716, -- Crystal Fragments  > Crystal Fragments  (Proc)
	[23304] = 108840, -- Unstable Familiar  > Unstable Familiar  (Damage)
	[23319] = 76076,  -- Unstable Clannfear > Unstale Clannfear  (Heal)
	[23316] = 77182,  -- Volatile Familiar  > Volatile Familiar  (Damage)
	[24613] = 108845, -- Winged Twilight    > Winged Twilight    (Heal)
	[24636] = 77140,  -- Twilight Tormentor > Twilight Tormentor (Damage)
	[24639] = 77369,  -- Twilight Matriarch > Twilight Matriarch (Heal)
	[23806] = 256798, -- Lava Whip          > Volcanic Whip
	[20816] = 20824,  -- Flame Lash         > Power Lash
	[35441] = 35445,  -- Shadow Image       > Shadow Image Teleport
}


local function HasDuration(skillId)
	return NO_DURATION[skillId] == nil and not IsUltimate(skillId)
end

local function IsActivated(skillId)
	return ACTIVATED[skillId] ~= nil
end

local function IsReactive(skillId)
	return REACTIVE[skillId] ~= nil
end

local function IsExecute(skillId)
	return EXECUTE[skillId] ~= nil
end

local function ExecuteThreshold(skillId)
	return EXECUTE[skillId] or 0
end

local function AlternateSkill(skillId)
	return ALTERNATE_MAP[skillId]
end

-------------------------------------------------------------------------------
-- EXPORTS
-------------------------------------------------------------------------------

PriorityRecast.HasDuration      = HasDuration
PriorityRecast.IsActivated      = IsActivated
PriorityRecast.IsReactive       = IsReactive
PriorityRecast.IsExecute        = IsExecute
PriorityRecast.ExecuteThreshold = ExecuteThreshold
PriorityRecast.AlternateSkill   = AlternateSkill
PriorityRecast.SkillId          = SkillId
