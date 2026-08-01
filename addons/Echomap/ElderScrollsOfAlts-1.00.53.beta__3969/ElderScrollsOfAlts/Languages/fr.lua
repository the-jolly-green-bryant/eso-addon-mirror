-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
	SI_ESOA_MESSAGE = " c'est actif!",
  SI_ESOA_SHOW     = "Afficher l'ESOA",
  
	-- Keybindings.
  --
  
  -- Trade Skills
  ESOA_FULL_SMTH = "Forge",
  ESOA_FULL_ALC  = "Alchimie",
  ESOA_FULL_WOOD = "Travail du bois",
  ESOA_FULL_JC   = "Joaillerie",
  ESOA_FULL_ENCH = "Enchantement",
  ESOA_FULL_PROV = "Cuisine",
  ESOA_FULL_CLTH = "Couture",
  -- Skills
  ESOA_FULL_ASSAULT   = "Assaut",
  ESOA_FULL_SUPPORT   = "Soutien",
  ESOA_FULL_LEGER     = "Escroquerie",
  ESOA_FULL_SOUL      = "Magie des âmes",
  ESOA_FULL_WERE      = "x", --ˈloup-garou ??
  ESOA_FULL_VAMP      = "Vampire",--Rituel de sang
  ESOA_FULL_FIGHT     = "Guilde des guerriers",
  ESOA_FULL_MAGE      = "Guilde des mages",
  ESOA_FULL_UNDAUNTED = "Indomptable",
  ESOA_FULL_THIEF     = "Guilde des voleurs",
  ESOA_FULL_DARK      = "Confrérie noire",
  ESOA_FULL_PSIJ      = "Ordre psijique",
  ESOA_FULL_SCRY      = "Sondage",
  ESOA_FULL_EXCAV     = "Excavation",
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
  ESOA_BITE_VAMP_COOLDOWN = "Fed on ally",  --funny ally is saved lowercase --Not his anymore? "Blood Ritual Cooldown"
  --
}

for stringId, stringValue in pairs(localization_strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end