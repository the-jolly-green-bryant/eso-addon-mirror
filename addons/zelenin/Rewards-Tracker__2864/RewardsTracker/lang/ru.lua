local localization_strings = {
    SI_BINDING_NAME_REWARDS_TRACKER_TOGGLE = "Открыть Rewards Tracker",
    SI_REWARDS_TRACKER_SO = "Санктум-Офидия",
    SI_REWARDS_TRACKER_AA = "Этерианский архив",
    SI_REWARDS_TRACKER_HRC = "Цитадель Хель-Ра",
    SI_REWARDS_TRACKER_MOL = "Пасть Лоркаджа",
    SI_REWARDS_TRACKER_HOF = "Залы фабрикации",
    SI_REWARDS_TRACKER_AS = "Изоляционный санктуарий",
    SI_REWARDS_TRACKER_CR = "Клаудрест",
    SI_REWARDS_TRACKER_SS = "Солнечный Шпиль",
    SI_REWARDS_TRACKER_KA = "Эгида Кин",
    SI_REWARDS_TRACKER_RG = "Каменная Роща",
    SI_REWARDS_TRACKER_DR = "Риф Зловещих Парусов",
    SI_REWARDS_TRACKER_SE = "Грань Безумия",
    SI_REWARDS_TRACKER_LC = "Цитадель Люцентов",
    SI_REWARDS_TRACKER_OC = "Костяная Клетка",
    SI_REWARDS_TRACKER_RD = "Случайное подземелье",
    SI_REWARDS_TRACKER_RB = "Любое поле сражения",
    SI_REWARDS_TRACKER_SHS = "Теневой поставщик",
}

for stringId, stringValue in pairs(localization_strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
