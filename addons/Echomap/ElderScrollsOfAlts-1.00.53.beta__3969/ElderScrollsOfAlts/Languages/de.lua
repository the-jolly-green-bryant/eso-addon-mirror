-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
  --
	SI_ESOA_MESSAGE = " ist aktiv!",
  SI_ESOA_SHOW     = "Zeigen Sie das ESOA an",
  
	-- Keybindings.
  --
  
  -- Trade Skills
  ESOA_FULL_SMTH = "Schmiedekunst",
  ESOA_FULL_ALC  = "Alchemie",
  ESOA_FULL_WOOD = "Schreinerei",
  ESOA_FULL_JC   = "Schmuckhandwerk",
  ESOA_FULL_ENCH = "Verzaubern",
  ESOA_FULL_PROV = "Versorgen",
  ESOA_FULL_CLTH = "Schneiderei",
  -- Skills
  ESOA_FULL_ASSAULT   = "Sturmangriff",
  ESOA_FULL_SUPPORT   = "Unterstützung",
  ESOA_FULL_LEGER     = "Lug und Trug",
  ESOA_FULL_SOUL      = "Seelenmagie",
  ESOA_FULL_WERE      = "Werewolf",
  ESOA_FULL_VAMP      = "Vampire",
  ESOA_FULL_FIGHT     = "die Kriegergilde",
  ESOA_FULL_MAGE      = "die Magiergilde",
  ESOA_FULL_UNDAUNTED = "die Unerschrockenen",
  ESOA_FULL_THIEF     = "die Diebesgilde",
  ESOA_FULL_DARK      = "die Dunkle Bruderschaft",
  ESOA_FULL_PSIJ      = "der Psijik-Orden",
  ESOA_FULL_SCRY      = "Spähen",
  ESOA_FULL_EXCAV     = "Ausgrabung",
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
  ESOA_BITE_VAMP_COOLDOWN = "Fed on ally",  --funny ally is saved lowercase --Not his anymore? "Blood Ritual Cooldown"
  --
}

for stringId, stringValue in pairs(localization_strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end