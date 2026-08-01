-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
  --
  -- Sub Skills
  ESOA_FULL_SUB_SOLV    = "Solvent Proficiency",
  ESOA_FULL_SUB_METAL   = "Metalworking",
  ESOA_FULL_SUB_TAIL    = "Tailoring",
  ESOA_FULL_SUB_ASPIMP  = "Aspect Improvement",
  ESOA_FULL_SUB_RECQUA  = "Recipe Quality",
  ESOA_FULL_SUB_WOOD    = "Woodworking",
  ESOA_FULL_SUB_ENGRAV  = "Engraver",
  ESOA_FULL_SUB_POTIMPR = "Potency Improvement",
  ESOA_FULL_SUB_RECIMPR = "Recipe Improvement",
  --
  
  ESOA_INFAMY_DISREPUTABLE = "Dispreputable",
  ESOA_INFAMY_FUGITIVE     = "Fugitive",
  ESOA_INFAMY_NOTORIOUS    = "Notorious",
  ESOA_INFAMY_UPSTANDING   = "Upstanding",

  ESOA_BITE_WERE_ABILITY  = "Bloodmoon",
  ESOA_BITE_WERE_COOLDOWN = "Bloodmoon Cooldown",
  ESOA_BITE_VAMP_ABILITY  = "Blood Ritual",
  ESOA_BITE_VAMP_COOLDOWN = "Blood Ritual Cooldown",
  --
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
