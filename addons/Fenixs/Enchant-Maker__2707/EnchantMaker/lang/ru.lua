-------------------------------------------
-- Russian localization for Enchant Maker --
-------------------------------------------

SafeAddString(ENCHANTMAKER_MADE_WITH, "Создаётся из: ", 1)
SafeAddString(ENCHANTMAKER_CHECK_ALL, "Выделить всё", 1)
SafeAddString(ENCHANTMAKER_UNCHECK_ALL, "Снять всё", 1)
SafeAddString(ENCHANTMAKER_SEARCH, "Поиск", 1)
SafeAddString(ENCHANTMAKER_SEARCH_AGAIN, "Повотрный поиск", 1)
SafeAddString(ENCHANTMAKER_POTENCY_HAVE, "Сила:", 1)
SafeAddString(ENCHANTMAKER_ESSENCE_HAVE, "Сущность:", 1)
SafeAddString(ENCHANTMAKER_ASPECT_HAVE, "Аспект:", 1)
SafeAddString(ENCHANTMAKER_SEARCH_RESULTS, "Результаты поиска", 1)
SafeAddString(ENCHANTMAKER_SHOW, "Показать", 1)
SafeAddString(ENCHANTMAKER_NEXXT, "Следующее", 1)
SafeAddString(ENCHANTMAKER_PREVIOUS, "Предыдущее", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_SHORT, "Включить отсутствующие рунные камни", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_LONG, "Отметьте это, чтобы искать чары, использующие рунные камни, которых у вас нет.", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_WARNING, "Включение этого параметра отключает автоматическое добавление рунических камней на стол!", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_SKILL_SHORT,"Включить неизученные умения.", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_SKILL_LONG,"Отметьте это, чтобы найти чары, для которых вам не хватает умения.", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_SHORT, "Включить неизвестные переводы в поиски", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_LONG, "Отметьте это, чтобы включить неизвестные переводы в поиск.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_SHORT, "Только неизвестные переводы", 1)
SafeAddString(ENCHANTMAKER_TRAINING_LONG, "Только зачарования, которые позволят узнать перевод неизвестных рун.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_WARNING, "Скрыть все результаты, которые не приводят к изучению нового перевода!", 1)
SafeAddString(ENCHANTMAKER_SAME_WINDOW_COORDS_SHORT, "Окна в одинаковых позициях", 1)
SafeAddString(ENCHANTMAKER_SAME_WINDOW_COORDS_LONG, "Установите этот флажок, чтобы окно результатов отображалось в той же позиции, что и окно поиска.", 1)
SafeAddString(ENCHANTMAKER_REQUIRES_POTENCY,"Требуется Улучшение силы",1)
SafeAddString(ENCHANTMAKER_REQUIRES_ASPECT,"Требуется Улучшение аспекта",1)
SafeAddString(ENCHANTMAKER_USE_TOP_POTENCY_RUNES,"Использовать только высокоуровневые руны силы",1)
SafeAddString(ENCHANTMAKER_FOR_LEVL,"для уровня",1)
SafeAddString(ENCHANTMAKER_TRANSLATION_US,"переводится как",1)

EnchMaker.runes = {
    potency = {
        additive = {
            ["Джора"]   = {translation = "Развитие", prefix = "Простой", skillRequirement = 1, minLevel = 1},
            ["Пораде"] = {translation = "Добавление", prefix = "Низший", skillRequirement = 1, minLevel = 5},
            ["Джера"]   = {translation = "Увеличение", prefix = "Слабый", skillRequirement = 2, minLevel = 10},
            ["Джеджора"] = {translation = "Повышение", prefix = "Небольшой", skillRequirement = 2, minLevel = 15},
            ["Одра"]   = {translation = "Прирост", prefix = "Малый", skillRequirement = 3, minLevel = 20},
            ["Поджора"] = {translation = "Пополнение", prefix = "Маленький", skillRequirement = 3, minLevel = 25},
            ["Эдора"]  = {translation = "Приумножение", prefix = "Умеренный", skillRequirement = 4, minLevel = 30},
            ["Джейра"]  = {translation = "Продвижение", prefix = "Средний", skillRequirement = 4, minLevel = 35},
            ["Пора"]   = {translation = "Augmenter", prefix = "Fort", skillRequirement = 5, minLevel = 40},
            ["Денара"] = {translation = "Renforcer", prefix = "Bon", skillRequirement = 5, minLevel = 60},
            ["Рера"]   = {translation = "Exagérer", prefix = "Majeur", skillRequirement = 6, minLevel = 80},
            ["Дерадо"] = {translation = "Dynamiser", prefix = "Grandiose", skillRequirement = 7, minLevel = 100},
            ["Рекура"] = {translation = "Magnifier", prefix = "Splendide", skillRequirement = 8, minLevel = 120},
            ["Кура"]   = {translation = "Intensifier", prefix = "Monumental", skillRequirement = 9, minLevel = 150},
            ["Реджера"] = {translation = "Amplify", prefix = "Superb", skillRequirement = 10, minLevel = 200},
            ["Репора"] = {translation = "Reinforce", prefix = "Vraiment Supurb", skillRequirement = 10, minLevel = 210},
        },

        subtractive = {
            ["Джоде"]   = {translation = "Уменьшение", prefix = "Простой", skillRequirement = 1, minLevel = 1},
            ["Нотаде"] = {translation = "Вычитание", prefix = "Низший", skillRequirement = 1, minLevel = 5},
            ["Оде"]    = {translation = "Сокращение", prefix = "Слабый", skillRequirement = 2, minLevel = 10},
			["Таде"]   = {translation = "Понижение", prefix = "Небольшой", skillRequirement = 2, minLevel = 15},
            ["Джайде"]  = {translation = "Убавление", prefix = "Малый", skillRequirement = 3, minLevel = 20},
            ["Эдоде"]  = {translation = "Опускание", prefix = "Маленький", skillRequirement = 3, minLevel = 25},
            ["Поджоде"] = {translation = "Разукрупнение", prefix = "Умеренный", skillRequirement = 4, minLevel = 30},
            ["Рекуде"] = {translation = "Ослабление", prefix = "Средний", skillRequirement = 4, minLevel = 35},
            ["Хаде"]   = {translation = "Amoundrir", prefix = "Fort", skillRequirement = 5, minLevel = 40},
            ["Идоде"]  = {translation = "Entraver", prefix = "Bon", skillRequirement = 5, minLevel = 60},
            ["Поде"]   = {translation = "Rerirer", prefix = "Majeur", skillRequirement = 6, minLevel = 80},
            ["Кедеко"] = {translation = "Drainer", prefix = "Grandiose", skillRequirement = 7, minLevel = 100},
            ["Реде"]   = {translation = "Priver", prefix = "Splendide", skillRequirement = 8, minLevel = 120},
            ["Куде"]   = {translation = "Annuler", prefix = "Monumental", skillRequirement = 9, minLevel = 150},
            ["Джехаде"] = {translation = "Divest", prefix = "Superb", skillRequirement = 10, minLevel = 200},
            ["Итаде"]  = {translation = "Plunder", prefix = "Vraiment Supurb", skillRequirement = 10, minLevel = 210},
        },
    },

    essence = {
        ["Декейпа"] = {translation = "Холод"},
        ["Дени"]    = {translation = "Запас сил"},
        ["Денима"]  = {translation = "Востановлениt запаса сил"},
        ["Детери"]  = {translation = "Броня"},
	["Хакейджо"] = {translation = "Призма"}, 
        ["Хаоко"]   = {translation = "Болезнь"},
        ["Кадери"]  = {translation = "Щит"},
        ["Куоко"]   = {translation = "Яд"},
        ["Макко"]   = {translation = "Магия"},
        ["Маккома"] = {translation = "Востановление магии"},
        ["Макдери"] = {translation = "Сила заклинаний"},
        ["Мейп"]    = {translation = "Электричество"},
        ["Око"]     = {translation = "Здоровье"},
        ["Окома"]   = {translation = "Востановление здоровья"},
        ["Окори"]   = {translation = "Сила"},
        ["Ору"]     = {translation = "Алхимия"},
        ["Ракейпа"] = {translation = "Огонь"},
        ["Тадери"]  = {translation = "Сила оружия"},
        ["Индеко"]  = {translation = "Prismatic"},
	},

    aspect = {
        ["Та"]     = {translation = "Обычный", quality = ITEM_QUALITY_NORMAL, skillRequirement = 1},
        ["Джеджота"] = {translation = "Хороший", quality = ITEM_QUALITY_MAGIC, skillRequirement = 1},
        ["Дената"] = {translation = "Превосходный", quality = ITEM_QUALITY_ARCANE, skillRequirement = 2},
        ["Рекута"] = {translation = "Эпический", quality = ITEM_QUALITY_ARTIFACT, skillRequirement = 3},
        ["Кута"]   = {translation = "Легендарный", quality = ITEM_QUALITY_LEGENDARY, skillRequirement = 4},
    },
}

EnchMaker.enchants = {
    additivePotency = {
        ["Декейпа"] = "Холода",
        ["Дени"]    = "Запаса сил",
        ["Денима"]  = "Востановления запаса сил",
        ["Детери"]  = "Закалки",
	["Хакейджо"] = "Prismatic Defence",
        ["Хаоко"]   = "Скверны",
        ["Кадери"]  = "Сокрушения",
        ["Куоко"]   = "Яда",
        ["Макко"]   = "Магии",
        ["Маккома"] = "Востановления магии",
        ["Макдери"] = "Маг. урона",
        ["Мейп"]    = "Электричества",
        ["Око"]     = "Здоровья",
        ["Окома"]   = "Востановления здоровья",
        ["Окори"]   = "Силы оружия",
        ["Ору"]     = "Усиления зелий",
        ["Ракейпа"] = "Пламени",
        ["Тадери"]  = "Увеличения физ.урона",
        ["Индеко"]  = "Призматического восстановления",
    },
    subtractivePotency = {
        ["Декейпа"] = "Сопротивления холоду",
        ["Дени"]    = "Поглощения запаса сил",
        ["Денима"]  = "Удешевления способностей",
        ["Детери"]  = "Пробивания",
        ["Хакейджо"] = "Prismatic Onslaught",
        ["Хаоко"]   = "Сопротивления болезни",
        ["Кадери"]  = "Охраны",
        ["Куоко"]   = "Сопротивления яду",
        ["Макко"]   = "Поглощения магии",
        ["Маккома"] = "Удешевления заклинаний",
        ["Макдери"] = "Снижения маг. урона",
        ["Мейп"]    = "Сопротивления электричеству",
        ["Око"]     = "Поглощения здоровья",
        ["Окома"]   = "Уменьшения здоровья",
        ["Окори"]   = "Слабости",
        ["Ору"]     = "Ускорения зелий",
        ["Ракейпа"] = "Сопротивления огню",
        ["Тадери"]  = "Снижения физ.урона",
        ["Индеко"]  = "Удешевления способностей",
    }
}

------------------------------------------------------------------------
-- Column Positions in the dialog
------------------------------------------------------------------------
EnchMaker.Dialog = {
    Width = 800,
    Potency = 20,
    Essence = 250,
    Aspect = 540,
}

------------------------------------------------------------------------
-- Construct the Glyph name for the specific language
------------------------------------------------------------------------
function EnchMaker.LangGlyphName(prefix,essence)
	return string.format("%s глиф %s",prefix,essence)
end