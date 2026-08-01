--[[

--]]
-------------------------------------------------------------------------------
-- Buffs Data
-------------------------------------------------------------------------------
Buffs = {}

Buffs.TEXTURENAMES = {

  MAJOR_EXPEDITION            = "/esoui/art/icons/ability_buff_major_expedition.dds",
  MINOR_EXPEDITION            = "/esoui/art/icons/ability_buff_minor_expedition.dds",
  MAJOR_GALLOP                = "/esoui/art/icons/ability_buff_major_gallop.dds",
  MAJOR_FORCE                 = "/esoui/art/icons/ability_buff_major_force.dds",
  MINOR_FORCE                 = "/esoui/art/icons/ability_buff_minor_force.dds",
  MAJOR_BERSERK               = "/esoui/art/icons/ability_buff_major_berserk.dds",
  MINOR_BERSERK               = "/esoui/art/icons/ability_buff_minor_berserk.dds",
  MAJOR_MAIM                  = "/esoui/art/icons/ability_debuff_major_maim.dds",
  MINOR_MAIM                  = "/esoui/art/icons/ability_debuff_minor_maim.dds",

--[[
  -- MAJOR/MINOR BUFFS
  MAJOR_BERSERK               = "/esoui/art/icons/ability_buff_major_berserk.dds",
  MAJOR_BRUTALITY             = "/esoui/art/icons/ability_buff_major_brutality.dds",
  MAJOR_EMPOWER               = "/esoui/art/icons/ability_buff_major_empower.dds",
  MAJOR_ENDURANCE             = "/esoui/art/icons/ability_buff_major_endurance.dds",
  MAJOR_EROSION               = "/esoui/art/icons/ability_buff_major_erosion.dds",
  MAJOR_EVASION               = "/esoui/art/icons/ability_buff_major_evasion.dds",
  MAJOR_EXPEDITION            = "/esoui/art/icons/ability_buff_major_expedition.dds",
  MAJOR_FORCE                 = "/esoui/art/icons/ability_buff_major_force.dds",
  MAJOR_FORTITUDE             = "/esoui/art/icons/ability_buff_major_fortitude.dds",
  MAJOR_GALLOP                = "/esoui/art/icons/ability_buff_major_gallop.dds",
  MAJOR_HEROISM               = "/esoui/art/icons/ability_buff_major_heroism.dds",
  MAJOR_INTELLECT             = "/esoui/art/icons/ability_buff_major_intellect.dds",
  MAJOR_LIFESTEAL             = "/esoui/art/icons/ability_buff_major_lifesteal.dds",
  MAJOR_MAGICKASTEAL          = "/esoui/art/icons/ability_buff_major_magickasteal.dds",
  MAJOR_MENDING               = "/esoui/art/icons/ability_buff_major_mending.dds",
  MAJOR_PROPHECY              = "/esoui/art/icons/ability_buff_major_prophecy.dds",
  MAJOR_PROTECTION            = "/esoui/art/icons/ability_buff_major_protection.dds",
  MAJOR_RESOLVE               = "/esoui/art/icons/ability_buff_major_resolve.dds",
  MAJOR_SAVAGERY              = "/esoui/art/icons/ability_buff_major_savagery.dds",
  MAJOR_SORCERY               = "/esoui/art/icons/ability_buff_major_sorcery.dds",
  MAJOR_VITALITY              = "/esoui/art/icons/ability_buff_major_vitality.dds",
  MAJOR_WARD                  = "/esoui/art/icons/ability_buff_major_ward.dds",
  MINOR_BERSERK               = "/esoui/art/icons/ability_buff_minor_berserk.dds",
  MINOR_BRUTALITY             = "/esoui/art/icons/ability_buff_minor_brutality.dds",
  MINOR_EMPOWER               = "/esoui/art/icons/ability_buff_minor_empower.dds",    --NOT USED
  MINOR_ENDURANCE             = "/esoui/art/icons/ability_buff_minor_endurance.dds",
  MINOR_EROSION               = "/esoui/art/icons/ability_buff_minor_erosion.dds",
  MINOR_EVASION               = "/esoui/art/icons/ability_buff_minor_evasion.dds",
  MINOR_EXPEDITION            = "/esoui/art/icons/ability_buff_minor_expedition.dds",
  MINOR_FORCE                 = "/esoui/art/icons/ability_buff_minor_force.dds",
  MINOR_FORTITUDE             = "/esoui/art/icons/ability_buff_minor_fortitude.dds",
  MINOR_GALLOP                = "/esoui/art/icons/ability_buff_minor_gallop.dds",     --NOT USED
  MINOR_HEROISM               = "/esoui/art/icons/ability_buff_minor_heroism.dds",
  MINOR_INTELLECT             = "/esoui/art/icons/ability_buff_minor_intellect.dds",
  MINOR_LIFESTEAL             = "/esoui/art/icons/ability_buff_minor_lifesteal.dds",
  MINOR_MAGICKASTEAL          = "/esoui/art/icons/ability_buff_minor_magickasteal.dds",
  MINOR_MENDING               = "/esoui/art/icons/ability_buff_minor_mending.dds",
  MINOR_PROPHECY              = "/esoui/art/icons/ability_buff_minor_prophecy.dds",
  MINOR_PROTECTION            = "/esoui/art/icons/ability_buff_minor_protection.dds",
  MINOR_RESOLVE               = "/esoui/art/icons/ability_buff_minor_resolve.dds",
  MINOR_SAVAGERY              = "/esoui/art/icons/ability_buff_minor_savagery.dds",
  MINOR_SORCERY               = "/esoui/art/icons/ability_buff_minor_sorcery.dds",
  MINOR_TOUGHNESS             = "/esoui/art/icons/ability_buff_minor_toughness.dds",
  MINOR_VITALITY              = "/esoui/art/icons/ability_buff_minor_vitality.dds",
  MINOR_WARD                  = "/esoui/art/icons/ability_buff_minor_ward.dds",

  -- OTHER BUFFS
  SCUTTLEBLOOM                = "/esoui/art/icons/ability_buff_scuttlebloom.dds",

  -- MAJOR/MINOR DEBUFFS
  MAJOR_BREACH                = "/esoui/art/icons/ability_debuff_major_breach.dds",
  MAJOR_COWARDICE             = "/esoui/art/icons/ability_debuff_major_cowardice.dds",
  MAJOR_DEFILE                = "/esoui/art/icons/ability_debuff_major_defile.dds",
  MAJOR_ENERVATION            = "/esoui/art/icons/ability_debuff_major_enervation.dds",
  MAJOR_FRACTURE              = "/esoui/art/icons/ability_debuff_major_fracture.dds",
  MAJOR_HINDRANCE             = "/esoui/art/icons/ability_debuff_major_hindrance.dds",
  MAJOR_MAIM                  = "/esoui/art/icons/ability_debuff_major_maim.dds",
  MAJOR_MANGLE                = "/esoui/art/icons/ability_debuff_major_mangle.dds",
  MAJOR_UNCERTAINTY           = "/esoui/art/icons/ability_debuff_major_uncertainty.dds",
  MAJOR_VULNERABILITY         = "/esoui/art/icons/ability_debuff_major_vulnerability.dds",
  MINOR_BREACH                = "/esoui/art/icons/ability_debuff_minor_breach.dds",
  MINOR_COWARDICE             = "/esoui/art/icons/ability_debuff_minor_cowardice.dds",
  MINOR_DEFILE                = "/esoui/art/icons/ability_debuff_minor_defile.dds",
  MINOR_ENERVATION            = "/esoui/art/icons/ability_debuff_minor_enervation.dds",
  MINOR_FRACTURE              = "/esoui/art/icons/ability_debuff_minor_fracture.dds",
  MINOR_HINDRANCE             = "/esoui/art/icons/ability_debuff_minor_hindrance.dds",
  MINOR_MAIM                  = "/esoui/art/icons/ability_debuff_minor_maim.dds",
  MINOR_MANGLE                = "/esoui/art/icons/ability_debuff_minor_mangle.dds",
  MINOR_UNCERTAINTY           = "/esoui/art/icons/ability_debuff_minor_uncertainty.dds",
  MINOR_VULNERABILITY         = "/esoui/art/icons/ability_debuff_minor_vulnerability.dds",

  -- OTHER DEBUFFS
  DISORIENT                   = "/esoui/art/icons/ability_debuff_disorient.dds",
  FEAR                        = "/esoui/art/icons/ability_debuff_fear.dds",
  KNOCKBACK                   = "/esoui/art/icons/ability_debuff_knockback.dds",
  LEVITATE                    = "/esoui/art/icons/ability_debuff_levitate.dds",
  OFFBALANCE                  = "/esoui/art/icons/ability_debuff_offbalance.dds",
  REVEAL                      = "/esoui/art/icons/ability_debuff_reveal.dds",
  ROOT                        = "/esoui/art/icons/ability_debuff_root.dds",
  SILENCE                     = "/esoui/art/icons/ability_debuff_silence.dds",
  SNARE                       = "/esoui/art/icons/ability_debuff_snare.dds",
  STAGGER                     = "/esoui/art/icons/ability_debuff_stagger.dds",
  STUN                        = "/esoui/art/icons/ability_debuff_stun.dds",
]]--

  -- MUNDUS BOONS
  BOON_WARRIOR                = "/esoui/art/icons/ability_mundusstones_001.dds",
  BOON_MAGE                   = "/esoui/art/icons/ability_mundusstones_002.dds",
  BOON_SERPENT                = "/esoui/art/icons/ability_mundusstones_003.dds",
  BOON_THIEF                  = "/esoui/art/icons/ability_mundusstones_004.dds",
  BOON_LADY                   = "/esoui/art/icons/ability_mundusstones_005.dds",
  BOON_STEED                  = "/esoui/art/icons/ability_mundusstones_006.dds",
  BOON_LORD                   = "/esoui/art/icons/ability_mundusstones_007.dds",
  BOON_APPRENTICE             = "/esoui/art/icons/ability_mundusstones_008.dds",
  BOON_RITUAL                 = "/esoui/art/icons/ability_mundusstones_009.dds",
  BOON_LOVER                  = "/esoui/art/icons/ability_mundusstones_010.dds",
  BOON_ATRONARCH              = "/esoui/art/icons/ability_mundusstones_011.dds",
  BOON_SHADOW                 = "/esoui/art/icons/ability_mundusstones_012.dds",
  BOON_TOWER                  = "/esoui/art/icons/ability_mundusstones_013.dds",

}


-- /script d(select(6,GetUnitBuffInfo("player",4)))
