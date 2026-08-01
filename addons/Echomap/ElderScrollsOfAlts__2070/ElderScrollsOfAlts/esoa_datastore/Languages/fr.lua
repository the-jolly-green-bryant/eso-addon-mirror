-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
  --
  -- Sub Skills
  ESOA_FULL_SUB_SOLV    = "Maîtrise des solvants",
  ESOA_FULL_SUB_METAL   = "Travail du métal",
  ESOA_FULL_SUB_TAIL    = "Expertise en tanins",
  ESOA_FULL_SUB_ASPIMP  = "Amélioration d'aspect",
  ESOA_FULL_SUB_RECQUA  = "Qualité des recettes",
  ESOA_FULL_SUB_RECIMPR = "Chef",
  ESOA_FULL_SUB_WOOD    = "Expertise en résines",
  ESOA_FULL_SUB_ENGRAV  = "Amélioration d'aspect",
  ESOA_FULL_SUB_POTIMPR = "Amélioration d'aspect",
  --
  ESOA_BITE_WERE_ABILITY  = "Bloodmoon",
  ESOA_BITE_WERE_COOLDOWN = "Bit an ally", --funny ally is saved lowercase
  ESOA_BITE_VAMP_ABILITY  = "Rituel de sang",
  ESOA_BITE_VAMP_COOLDOWN = "Fed on ally",  --funny ally is saved lowercase --Not this anymore? "Blood Ritual Cooldown"
  --
  --
}

for stringId, stringValue in pairs(localization_strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end