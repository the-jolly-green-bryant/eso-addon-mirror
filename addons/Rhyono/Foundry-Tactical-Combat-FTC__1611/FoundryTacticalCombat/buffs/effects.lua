--[[----------------------------------------------------------
    ADDITIONAL EFFECTS
  ]]----------------------------------------------------------

--[[
 * Tracks Toggled Abilities
 * --------------------------------
 * Called by FTC:FilterBuffInfo()
 * --------------------------------
 ]]--
function FTC.Buffs:IsToggle(name)
  local Toggles = {
    23617, -- Unstable Familiar
    23644, -- Unstable Clannfear
    23641, -- Volatile Familiar
    24613, -- Summon Winged Twilight
    24636, -- Summon Twilight Tormentor
    24639, -- Summon Twilight Matriarch
    24158, -- Bound Armor
    24165, -- Bound Armaments
    24163, -- Bound Aegis
    33319, -- Siphoning Strikes
    36908, -- Leeching Strikes
    30920, -- Magelight
    40478, -- Inner Light
    40483, -- Radiant Magelight
    25954, -- Inferno
    23853, -- Flames of Oblivion
    32881, -- Cauterize
    61511, -- Guard
    61536, -- Mystic Guard
    61529, -- Stalwart Guard
  }
  for i = 1, #Toggles do
    if (name == GetAbilityName(Toggles[i])) then return true end
  end
  return false
end

--[[
 * Clears Damage Shield Buffs
 * --------------------------------
 * Called by FTC.OnVisualRemoved()
 * --------------------------------
 ]]--
function FTC.Buffs:ClearShields()

  -- Manually maintain a list of shields
  local Shields = {

    -- Dragonknight
    29071, -- Obsidian Shield
    29224, -- Igneous Shield
    32673, -- Fragmented Shield

    -- Sorcerer
    28418, -- Conjured Ward
    29489, -- Hardened Ward
    29482, -- Regenerative Ward

    -- Templar
    22178, -- Sun Shield
    22182, -- Radiant Ward
    22180, -- Blazing Shield

    -- Arcanist
    178448, -- Runespite Ward
    183241, -- Impervious Runeward
    185901, -- Spiteward of the Lucid Mind
    178449, -- Gibbering Shield

    -- Weapons
    5798, -- Brawler
    38401, -- Shielded Assault
    40130, -- Ward Ally
    40126, -- Healing Ward
    37232, -- Steadfast Ward

    -- AvA
    38573, -- Barrier
    40237, -- Reviving Barrier
    40239, -- Replenishing Barrier

    -- Guilds
    29338, -- Annulment
    39186, -- Dampen Magic
    39182, -- Harness Magicka
    39369, -- Bone Shield
    42176, -- Bone Surge
    42138, -- Spiked Bone Shield
  }

  -- Compare each shield ability with the current buffs for purging
  for i = 1, #Shields do

    -- Does the named buff exist?
    local name = GetAbilityName(Shields[i])
    if (FTC.Buffs.Player[name] ~= nil) then
      local id = FTC.Buffs.Player[name].control.id
      FTC.Buffs.Player[name] = nil
      FTC.Buffs.Pool:ReleaseObject(id)
    end
  end
end

--[[
 * Identify Taunt Abilities
 * --------------------------------
 * Called by: None, Unused
 * --------------------------------
 ]]--
function FTC.Buffs:IsTaunt(name)
  local Taunts = {
    28306, -- Puncture
    38256, -- Ransack
    38250, -- Pierce Armor
    39475, -- Inner Fire
    42056, -- Inner Rage
    42060, -- Inner Beast

    -- Fighters Guild
    40336, -- Silver Leash

    -- Destruction Staff
    38989, -- Frost Clench

    -- Arcanist
    178447, -- Runic Jolt
    186531, -- Runic Embrace
    183430, -- Runic Sunder
  }
  for i = 1, #Taunts do
    if (name == GetAbilityName(Taunts[i])) then return true end
  end
end

--[[
 * Filter Valid Buff Effects
 * --------------------------------
 * Called by FTC.Buffs:GetBuffs()
 * Called by FTC.Buffs:EffectChanged()
 * --------------------------------
 ]]--
function FTC:FilterBuffInfo(unitTag, abilityId, effectName)

  -- Default to no isType
  local isType = nil
  local isValid = true

  -- Toggles
  if (FTC.Buffs:IsToggle(effectName)) then
    isType = "T"
    return isValid, isType
  end

  -- Boons
  local Boons = {
    13940, -- Boon: The Warrior
    13943, -- Boon: The Mage
    13974, -- Boon: The Serpent
    13975, -- Boon: The Thief
    13976, -- Boon: The Lady
    13977, -- Boon: The Steed
    13978, -- Boon: The Lord
    13979, -- Boon: The Apprentice
    13980, -- Boon: The Ritual
    13981, -- Boon: The Lover
    13982, -- Boon: The Atronach
    13984, -- Boon: The Shadow
    13985, -- Boon: The Tower
  }
  for i = 1, #Boons do
    if (abilityId == Boons[i]) then
      isValid = (unitTag == 'player')
      isType = "P"
      return isValid, isType
    end
  end

  -- Vampirism
  local Vamp = {
    35771, -- Stage 1 Vampirism
    35773, -- Stage 2 Vampirism
    35780, -- Stage 3 Vampirism
    35786, -- Stage 4 Vampirism
  }
  for i = 1, #Vamp do
    if (abilityId == Vamp[i]) then
      isValid = true
      isType = "V" .. i
      return isValid, isType
    end
  end

  -- Lycanthropy
  if (abilityId == 35658) then
    isValid = true
    isType = "W"
    return isValid, isType
  end

  -- AvA Bonuses
  local AvA = {
    15058, -- Offensive Scroll Bonus I
    16348, -- Offensive Scroll Bonus II
    15060, -- Defensive Scroll Bonus I
    16350, -- Defensive Scroll Bonus I
    39671, -- Emperorship Alliance Bonus
  }
  for i = 1, #AvA do
    if (abilityId == AvA[i]) then
      isValid = (unitTag == 'player')
      isType = "P"
      return isValid, isType
    end
  end

  -- Ignored Effects
  local Ignored = {
    29667, -- Concentration
    40359, -- Fed on ally
    39472, -- Vampirism
    45569, -- Medicinal Use
    62760, -- Spell Shield
    63601, -- ESO Plus Member
    64160, -- Crystal Fragments Passive (non-timed)
  }
  for i = 1, #Ignored do
    if (abilityId == Ignored[i]) then
      isValid = false
      return isValid, isType
    end
  end

  -- Return other buffs
  return isValid, isType
end
