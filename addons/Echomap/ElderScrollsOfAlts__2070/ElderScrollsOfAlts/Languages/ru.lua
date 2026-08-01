-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
  --
  SI_ESOA_MESSAGE  = " аддон загружен",
  SI_ESOA_SHOW     = "Показать ESOA",
  
  
  -- Keybindings.
  --
  
  -- Trade Skills
  ESOA_FULL_SMTH = "Кузнечное дело",
  ESOA_FULL_ALC  = "Алхимия",
  ESOA_FULL_WOOD = "Столярное дело",
  ESOA_FULL_JC   = "Ювелирное дело",
  ESOA_FULL_ENCH = "Зачарование",
  ESOA_FULL_PROV = "Снабжение",
  ESOA_FULL_CLTH = "Портняжное дело",
  -- Skills
  ESOA_FULL_ASSAULT   = "Штурм",
  ESOA_FULL_SUPPORT   = "Поддержка",
  ESOA_FULL_LEGER     = "Ловкость рук",
  ESOA_FULL_SOUL      = "Магия душ",
  ESOA_FULL_WERE      = "x",
  ESOA_FULL_VAMP      = "Вампир", --Кровавый ритуал
  ESOA_FULL_FIGHT     = "Гильдия бойцов",
  ESOA_FULL_MAGE      = "Гильдия магов",
  ESOA_FULL_UNDAUNTED = "Неустрашимые",
  ESOA_FULL_THIEF     = "Гильдия воров",
  ESOA_FULL_DARK      = "Темное Братство",
  ESOA_FULL_PSIJ      = "Орден Псиджиков",
  ESOA_FULL_SCRY      = "Лоцирование",
  ESOA_FULL_EXCAV     = "Раскопки",
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
}

for stringId, stringValue in pairs(localization_strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end