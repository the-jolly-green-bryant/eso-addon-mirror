-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
  --
  -- Sub Skills
  ESOA_FULL_SUB_SOLV    = "Lösungsmittelkenntnis",
  ESOA_FULL_SUB_METAL   = "Schmiedehandwerk",
  ESOA_FULL_SUB_TAIL    = "Schneiderei",
  ESOA_FULL_SUB_ASPIMP  = "Aspektverbesserung",
  ESOA_FULL_SUB_RECQUA  = "Rezeptqualität",
  ESOA_FULL_SUB_RECIMPR = "Rezeptverbesserung",
  ESOA_FULL_SUB_WOOD    = "Schreinerhandwerk",
  ESOA_FULL_SUB_ENGRAV  = "Graveur",
  ESOA_FULL_SUB_POTIMPR = "Machtverbesserung",
  --
  ESOA_BITE_WERE_ABILITY  = "Bloodmoon",
  ESOA_BITE_WERE_COOLDOWN = "Bit an ally", --funny ally is saved lowercase
  ESOA_BITE_VAMP_ABILITY  = "Blood Ritual",
  ESOA_BITE_VAMP_COOLDOWN = "Fed on ally",  --funny ally is saved lowercase --Not this anymore? "Blood Ritual Cooldown"
  --
  --
}

for stringId, stringValue in pairs(localization_strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end