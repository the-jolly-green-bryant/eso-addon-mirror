-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
  --
  -- Sub Skills
  ESOA_FULL_SUB_SOLV    = "Знание растворителей",
  ESOA_FULL_SUB_METAL   = "Обработка металла",
  ESOA_FULL_SUB_TAIL    = "Шитье",
  ESOA_FULL_SUB_ASPIMP  = "Улучшение аспекта",
  ESOA_FULL_SUB_RECQUA  = "Качество рецепта",
  ESOA_FULL_SUB_WOOD    = "Столярное дело",
  ESOA_FULL_SUB_ENGRAV  = "Гравер",
  ESOA_FULL_SUB_POTIMPR = "Улучшение силы",
  ESOA_FULL_SUB_RECIMPR = "Улучшение рецепта",
  --
  ESOA_BITE_WERE_ABILITY  = "Bloodmoon",
  ESOA_BITE_WERE_COOLDOWN = "Bit an ally", --funny ally is saved lowercase
  ESOA_BITE_VAMP_ABILITY  = "Кровавый ритуал",
  ESOA_BITE_VAMP_COOLDOWN = "Fed on ally",  --funny ally is saved lowercase --Not this anymore? "Blood Ritual Cooldown"
  --
  --
}

for stringId, stringValue in pairs(localization_strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end