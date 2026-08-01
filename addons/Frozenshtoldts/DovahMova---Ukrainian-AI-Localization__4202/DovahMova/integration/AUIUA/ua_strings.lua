-- Ukrainian translations for AUI (Advanced UI) - COMPLETE VERSION
-- Українська локалiзацiя для AUI (Advanced UI) - ПОВНА ВЕРСiЯ
-- Автор: DovahMova Team

-- Перевiряємо, чи поточна мова - українська
if GetCVar("language.2") ~= "ua" then
    return
end

-- Створюємо таблицю з українськими перекладами для AUI (всi 414 рядкiв)
AUIUA_Strings = {
    -- Основнi налаштування
    ["aui"] = "AUI",
    ["general"] = "Загальнi",
    ["acount_wide"] = "На акаунт",
    ["acount_wide_tooltip"] = "Зберiгає налаштування для всiх персонажiв.",
    ["preview"] = "Попереднiй перегляд",
    ["preview_tooltip"] = "Показує зразок попереднього перегляду обраного модуля.",
    ["preview_warning"] = "|c8B1E1EПопереднiй перегляд має бути вимкнений вручну.",
    ["reset_to_default_position"] = "Скинути позицiю",
    ["reset_to_default_position_tooltip"] = "Скидає позицiю до налаштувань за замовчуванням.",
    ["accept_settings"] = "Застосувати",
    ["accept_settings_tooltip"] = "Застосовує всi змiни та перезавантажує користувацький iнтерфейс.",
    ["reloadui_manual_warning_tooltip"] = "|c8B1E1EПiсля змiни|cffffff Застосувати |c8B1E1Eпотрiбно натиснути.",
    ["reloadui_warning_tooltip"] = "|c8B1E1EЗмiна цього параметра перезавантажить користувацький iнтерфейс.",

    -- Розмiри та параметри
    ["width"] = "Ширина",
    ["width_tooltip"] = "Встановлює ширину до вказаного значення.",
    ["height"] = "Висота",
    ["height_tooltip"] = "Встановлює висоту до вказаного значення.",
    ["show_icons"] = "Показати iконки",

    -- Анiмацiя
    ["animation_art"] = "Анiмацiя: Стиль",
    ["animation_art_tooltip"] = "Встановлює стиль анiмацii.",
    ["animation_mode"] = "Анiмацiя: Режим",
    ["animation_mode_tooltip"] = "Встановлює напрямок анiмацiї.",
    ["animation_duration"] = "Анiмацiя: Тривалiсть",
    ["animation_duration_tooltip"] = "Встановлює тривалiсть вiдображення анiмацiї.",

    -- Бiй та пошкодження
    ["damage"] = "Шкода",
    ["healing"] = "Зцiлення",
    ["critical_damage"] = "Критична шкода",
    ["critical_healing"] = "Критичне зцiлення",
    ["size"] = "Розмiр",
    ["size_tooltip"] = "Встановлює розмiр до вказаного значення.",

    -- Шрифти
    ["font_art"] = "Шрифт: Тип",
    ["font_art_tooltip"] = "Встановлює тип шрифта.",
    ["font_size"] = "Шрифт: Розмiр",
    ["font_size_tooltip"] = "Встановлює розмiр шрифта.",
    ["font_color"] = "Шрифт: Колiр",
    ["font_color_tooltip"] = "Встановлює колiр шрифта.",
    ["font_style"] = "Шрифт: Стиль",
    ["font_style_tooltip"] = "Встановлює стиль шрифта.",
    ["text_position"] = "Позицiя тексту",
    ["text_position_tooltip"] = "Встановлює позицiю тексту.",

    -- Кольори
    ["color"] = "Колiр",
    ["color_tooltip"] = "Встановлює колiр.",
    ["colors"] = "Кольори",
    ["show"] = "Показати",
    ["show_tooltip"] = "Показати/приховати цей кадр.",

    -- Стилi
    ["style"] = "Стиль",
    ["style_tooltip"] = "Встановлює стиль цього кадру.",

    -- Позицiї
    ["top"] = "Вгорi",
    ["bottom"] = "Внизу",
    ["reverse"] = "Зворотно",
    ["center"] = "По центру",
    ["vertical"] = "Вертикально",
    ["vertical_reverse"] = "Вертикально: Зворотно",
    ["horizontal"] = "Горизонтально",
    ["horizontal_reverse"] = "Горизонтально: Зворотно",
    ["eclipse"] = "Затемнення",
    ["small_to_large"] = "Вiд малого до великого",
    ["large_to_small"] = "Вiд великого до малого",
    ["backward"] = "Назад",
    ["normal"] = "Нормально",
    ["normal_reverse"] = "Нормально: Зворотно",
    ["backward_reverse"] = "Назад: Зворотно",

    -- Типи
    ["default"] = "За замовчуванням",
    ["modern"] = "Сучасний",
    ["eso"] = "ESO",
    ["custom"] = "Користувацький",
    ["simple"] = "Простий",
    ["box"] = "Коробка",
    ["bevelled"] = "Скошений",
    ["arrow"] = "Стрiлка",

    -- Координати та локацiї
    ["show_player_coords_tooltip"] = "Показує координати гравця.",
    ["location_name"] = "Назва локацiї",
    ["coords"] = "Координати",

    -- Група та рейд
    ["group"] = "Група",
    ["raid"] = "Рейд",
    ["show_group_member_status"] = "Показати статус учасникiв групи",
    ["show_group_member_status_tooltip"] = "Показує, чи учасник групи в бою або мертвий.",

    -- Ульти та зiлля
    ["ultimate_ready"] = "Ультимативна готова",
    ["potions"] = "Зiлля",
    ["potion_ready"] = "Зiлля готове",
    ["combat_start"] = "Бiй: Початок",
    ["combat_end"] = "Бiй: Кiнець",

    -- Стилi шрифтiв
    ["font_style_normal"] = "Звичайний",
    ["font_style_outline"] = "Контур",
    ["font_style_outline_thick"] = "Контур (товстий)",
    ["font_style_shadow"] = "Тiнь",
    ["font_style_shadow_thick"] = "Тiнь (товста)",
    ["font_style_shadow_thin"] = "Тiнь (тонка)",

    -- Масштабування
    ["zoom"] = "Масштаб",
    ["group_leader"] = "Лiдер групи",
    ["group_members"] = "Учасники групи",

    -- Квести
    ["quest"] = "Квест",
    ["quests"] = "Квести",
    ["pin_colors"] = "Кольори мiток",
    ["text"] = "Текст",
    ["combat"] = "Бiй",
    ["dead"] = "Мертвий",
    ["friend"] = "Друг",
    ["mainstory"] = "Основна iсторiя",
    ["daily"] = "Щоденний",
    ["repeatable"] = "Повторюваний",
    ["icons"] = "Символи",
    ["offline"] = "Не в мережi",

    -- Слоти
    ["slot_count"] = "Кiлькiсть слотiв",
    ["slot_count_tooltip"] = "Збiльшує/зменшує кiлькiсть показаних слотiв.",
    ["show_text"] = "Показати текст",
    ["show_text_tooltip"] = "Показує/приховує текст.",

    -- Налаштування ультимативної
    ["allow_more_than_100%"] = "Дозволити бiльше 100%",
    ["allow_more_than_100%_tooltip"] = "Налаштування дозволяє тексту ультимативної показувати значення вище 100%.",
    ["lock_window"] = "Заблокувати кадр",
    ["lock_window_tooltip"] = "Встановлює, чи кадри залишаються на мiсцi або можуть бути перемiщенi.",
    ["template"] = "Шаблон",
    ["template_tooltip"] = "Змiнює дизайн обраного модуля.",

    -- Характеристики
    ["health"] = "Здоров'я",
    ["magicka"] = "Магiя",
    ["stamina"] = "Витривалiсть",
    ["stamina_mount"] = "Витривалiсть (кiнь)",
    ["siege"] = "Облога",
    ["shield"] = "Щит",
    ["werewolf"] = "Перевертень",

    -- Ефекти
    ["regeneration"] = "Вiдновлення",
    ["degeneration"] = "Виродження",
    ["friendly"] = "Дружнiй",
    ["allied"] = "Союзний",
    ["npc"] = "НПС",
    ["player"] = "Гравець",
    ["target"] = "Цiль",
    ["neutral"] = "Нейтральний",
    ["guard"] = "Охоронець",

    -- Вiдображення чисел
    ["show_thousand_seperator"] = "Показати роздiлювач тисяч",
    ["show_thousand_seperator_tooltip"] = "Вмикає/вимикає роздiлювач тисяч та групування цифр.",

    -- Ефекти регенерацiї
    ["show_regeneration_color"] = "Показати колiр вiдновлення",
    ["show_regeneration_color_tooltip"] = "Вмикає/вимикає забарвлення смуги життя при додаваннi зцiлення з часом.",
    ["show_degeneration_color"] = "Показати колiр виродження",
    ["show_degeneration_color_tooltip"] = "Вмикає/вимикає забарвлення смуги життя при додаваннi пошкодження з часом.",
    ["show_regeneration_effect"] = "Показати ефект вiдновлення",
    ["show_regeneration_effect_tooltip"] = "Вмикає/вимикає вiзуальний ефект вiдновлення смуги життя при зцiленнi з часом.",
    ["show_degeneration_effect"] = "Показати ефект виродження",
    ["show_degeneration_effect_tooltip"] = "Вмикає/вимикає вiзуальний ефект виродження смуги життя при зцiленнi з часом.",

    -- Ефекти бронi
    ["show_increase_armor_effect"] = "Показати ефект бронi (збiльшення)",
    ["show_increase_armor_effect_tooltip"] = "Вмикає/вимикає вiзуальний ефект пiдвищеної бронi смуги життя.",
    ["show_decrease_armor_effect"] = "Показати ефект бронi (зменшення)",
    ["show_decrease_armor_effect_tooltip"] = "Вмикає/вимикає вiзуальний ефект зниженої бронi смуги життя.",

    -- Ефекти сили
    ["show_increase_power_effect"] = "Показати ефект шкоди (збiльшення)",
    ["show_increase_power_effect_tooltip"] = "Вмикає/вимикає вiзуальний ефект зниженої шкоди смуги життя.",
    ["show_decrease_power_effect"] = "Показати ефект шкоди (зменшення)",
    ["show_decrease_power_effect_tooltip"] = "Вмикає/вимикає вiзуальний ефект зниженої шкоди смуги життя.",

    -- Щити
    ["show_shields"] = "Показати щити",
    ["show_shields_tooltip"] = "Встановлює, чи активний щит буде показаний вiзуально.",

    -- Прозорiсть та вiдстанi
    ["opacity"] = "Непрозорiсть",
    ["opacity_tooltip"] = "Збiльшує/зменшує непрозорiсть цього кадру.",
    ["row_distance"] = "Вiдстань мiж рядками",
    ["row_distance_tooltip"] = "Встановлює вiдстань мiж рядками цих кадрiв.",
    ["distance"] = "Вiдстань",
    ["distance_tooltip"] = "Встановлює вiдстань мiж цими кадрами.",
    ["column_distance"] = "Вiдстань мiж стовпцями",
    ["column_distance_tooltip"] = "Встановлює вiдстань мiж стовпцями цих кадрiв.",
    ["row_count"] = "Кiлькiсть рядкiв",
    ["row_count_tooltip"] = "Збiльшує/зменшує кiлькiсть окремих рядкiв.",

    -- Постiйне вiдображення
    ["always_show"] = "Завжди показувати",
    ["always_show_tooltip"] = "Показує цей кадр постiйно.",

    -- Ефекти баффiв
    ["show_buff_glow_effect"] = "Показати ефект свiчення для баффiв",
    ["show_buff_glow_effect_tooltip"] = "Показує ефект навколо цього кадру, якщо, наприклад, здоров'я, магiя або витривалiсть збiльшенi.",

    -- Вирiвнювання панелей
    ["bar_alignment"] = "Панель характеристик: Вирiвнювання",
    ["bar_alignment_tooltip"] = "Змiнює вирiвнювання нульової точки на кадрi.",
    ["alignment"] = "Вирiвнювання",
    ["alignment_tooltip"] = "Змiнює напрямок руху.",

    -- Обертання
    ["reverse_vertical"] = "Перевернути вертикально",
    ["reverse_vertical_tooltip"] = "Повертає кадр на 180°.",

    -- Прозорiсть поза зоною дiї
    ["unit_out_of_range_opacity"] = "Непрозорiсть (поза зоною дiї)",
    ["unit_out_of_range_opacity_tooltip"] = "Збiльшує/зменшує непрозорiсть цих кадрiв, якщо об'єкт поза зоною дiї гравця.",

    -- Сортування
    ["sorting"] = "Сортування",
    ["sorting_tooltip"] = "Встановлює порядок сортування.",
    ["sorting_buff_tooltip"] = "Сортує iконки за тривалiстю.",

    -- Рiзне
    ["cooldown"] = "Перезарядження",
    ["edge"] = "Контур",
    ["rotate"] = "Обертання",

    -- Автомасштабування карти
    ["auto_zoom_out"] = "Автоматично зменшувати масштаб",
    ["worldmap_auto_zoom_out_tooltip"] = "Карта свiту автоматично зменшує масштаб при вiдкриттi.",

    -- Зони
    ["zone"] = "Зона",
    ["zoom_zone_tooltip"] = "Змiнює рiвень масштабування зон.",
    ["subzone"] = "Пiдзона (наприклад, мiста)",
    ["zoom_subzone_tooltip"] = "Змiнює рiвень масштабування всiх пiдзон, наприклад мiст або сiл.",
    ["dungeon"] = "Пiдземелля",
    ["zoom_dungeon_tooltip"] = "Змiнює рiвень масштабування пiдземель.",
    ["arena_pvp"] = "Арена (ПвП)",
    ["zoom_arena_pvp_tooltip"] = "Змiнює рiвень масштабування в аренi ПвП.",

    -- Назви локацiй
    ["show_location_name_tooltip"] = "Показує/приховує назви локацiй.",

    -- Перемикання
    ["toggle"] = "Перемикати вкл/викл",
    ["zoom_in"] = "Збiльшити масштаб",
    ["zoom_out"] = "Зменшити масштаб",

    -- Швидкi слоти
    ["quickslot_1"] = "Швидкий слот 1",
    ["quickslot_2"] = "Швидкий слот 2",
    ["quickslot_3"] = "Швидкий слот 3",
    ["quickslot_4"] = "Швидкий слот 4",
    ["quickslot_5"] = "Швидкий слот 5",
    ["quickslot_6"] = "Швидкий слот 6",
    ["quickslot_7"] = "Швидкий слот 7",
    ["quickslot_8"] = "Швидкий слот 8",
    ["quickslot_select_next"] = "Вибрати наступний слот",
    ["quickslot_select_previous"] = "Вибрати попереднiй слот",

    -- Бойова статистика
    ["show_combat_statistic"] = "Показати бойову статистику",
    ["hide_combat_statistic"] = "Приховати бойову статистику",
    ["post_all_combat_statistic"] = "Опублiкувати бойову статистику (всi цiлi) в чат",
    ["post_highest_target_combat_statistic"] = "Опублiкувати бойову статистику (найвища цiль) в чат",
    ["post_all"] = "Чат: Всi цiлi",
    ["post_highest_target"] = "Чат: Найвища цiль",

    -- Показники бою
    ["damage_per_second"] = "Шкода за секунду",
    ["total_damage"] = "Загальна шкода",
    ["healing_per_second"] = "Зцiлення за секунду",
    ["total_healing"] = "Загальне зцiлення",
    ["combat_time"] = "Тривалiсть бою",

    -- Команди
    ["reloadui"] = "Перезавантажити iнтерфейс",
    ["regroup"] = "Перегрупувати",

    -- Баффи та дебаффи
    ["buffs"] = "Баффи",
    ["debuffs"] = "Дебаффи",
    ["mode"] = "Режим",

    -- Здiбностi
    ["abilities"] = "Здiбностi",
    ["name"] = "iм'я",
    ["total"] = "Загалом",
    ["crit"] = "Критичний",
    ["hits"] = "Влучання",

    -- Керування модулями
    ["module_management"] = "Керування модулями",
    ["minimap_module_name"] = "Мiнiмапа",
    ["attributes_module_name"] = "Кадри одиниць",
    ["combat_module_name"] = "Бiй",
    ["actionbar_module_name"] = "Панель дiй",
    ["buffs_module_name"] = "Баффи",
    ["quest_tracker_module_name"] = "Вiдстежувач квестiв",
    ["frame_mover_module_name"] = "Перемiщувач кадрiв",

    -- Елементи вiдображення
    ["display_elements"] = "iндикаторнi елементи",
    ["minimeter"] = "Мiнiлiчильник",
    ["weapon_charge_warner"] = "Попередження заряду зброї",
    ["show_background"] = "Показати фон",

    -- Вхiдна та вихiдна шкода
    ["outgoing"] = "Вихiдна",
    ["incoming"] = "Вхiдна",
    ["show_dps"] = "Показати ШЗС",
    ["show_hps"] = "Показати ЗЗС",
    ["show_total_damage"] = "Показати загальну шкоду",
    ["show_total_heal"] = "Показати загальне зцiлення",
    ["show_combat_time"] = "Показати тривалiсть бою",

    -- Повiдомлення бою
    ["scrolling_text"] = "Повiдомлення бою",
    ["show_damage"] = "Показати шкоду",
    ["show_heal"] = "Показати зцiлення",

    -- Складання значень
    ["assembling_value"] = "Додавати значення",
    ["assembling_value_tooltip"] = "Додає значення однакового типу.",
    ["show_max_value"] = "Показати максимальне значення",
    ["show_max_value_tooltip"] = "Показує максимальне значення поряд з поточним значенням.",

    -- Постiйнi та тимчасовi баффи
    ["show_permanent_buffs"] = "Показати постiйнi баффи",
    ["show_permanent_buffs_tooltip"] = "Показує всi баффи, що є постiйними.",
    ["show_time_limit_buffs"] = "Показати обмеженi за часом баффи",
    ["show_time_limit_buffs_tooltip"] = "Показує всi баффи, що обмеженi за часом.",
    ["show_debuffs"] = "Показати дебаффи",
    ["show_debuffs_tooltip"] = "Встановлює, чи показувати дебаффи чи нi.",

    -- Розмiри мiток мiнiмапи
    ["pin_size"] = "Розмiр мiтки",
    ["pin_size_tooltip"] = "Змiнює розмiр мiток на мiнiмапi.",
    ["player_pin_size"] = "Розмiр мiтки (гравець)",
    ["player_pin_size_tooltip"] = "Змiнює розмiр мiтки гравця на мiнiмапi.",
    ["group_leader_pin_size"] = "Розмiр мiтки (лiдер групи)",
    ["group_leader_pin_size_tooltip"] = "Змiнює розмiр мiтки лiдера групи на мiнiмапi.",
    ["group_member_pin_size"] = "Розмiр мiтки (учасники групи)",
    ["group_member_pin_size_tooltip"] = "Змiнює розмiр мiток учасникiв групи на мiнiмапi.",

    -- Кольори мiток
    ["player_pin_color"] = "Колiр: мiтка гравця",
    ["player_pin_color_tooltip"] = "Змiнює колiр мiтки гравця.",
    ["minimap_rotate_tooltip"] = "Обертає мiнiмапу замiсть мiтки гравця.",

    -- Невiдкритi мiтки
    ["show_unknown_pins"] = "Показати невiдкритi мiтки",
    ["minimap_show_unknown_pins_tooltip"] = "Показує всi мiтки невiдкритих локацiй на мiнiмапi.",

    -- Приховування в бою
    ["hide_in_combat"] = "Приховати пiд час бою",
    ["minimap_hide_in_combat_tooltip"] = "Вимикає мiнiмапу пiд час бою.",

    -- iконки на картi свiту
    ["use_icons_in_worldmap"] = "Показати мiтки на картi свiту",
    ["use_icons_in_worldmap_tooltip"] = "Показує всi мiтки з мiнiмапи на картi свiту.",

    -- Кадр цiлi за замовчуванням
    ["show_default_target_frame"] = "Показати кадр цiлi за замовчуванням",
    ["show_default_target_frame_tooltip"] = "Показує/приховує кадр цiлi за замовчуванням.",

    -- Статистика та чат
    ["meter_statistic"] = "Бойова статистика",
    ["post_in_chat"] = "Опублiкувати в чат",
    ["all"] = "Все",
    ["unknown"] = "Невiдомо",
    ["aui-compact"] = "AUI Компактний",
    ["dps"] = "ШЗС",
    ["hps"] = "ЗЗС",

    -- Швидкi слоти
    ["quick_slots"] = "Швидкi слоти",

    -- Ефекти здiбностей
    ["show_ability_proc_effect"] = "Показати ефект",
    ["show_ability_proc_effect_tooltip"] = "Вiдображає додатковi ефекти здiбностей, що активнi певний час.",

    -- Груповi дiї
    ["whisper"] = "Пошепки",
    ["leave_group"] = "Покинути групу",
    ["travel_to_player"] = "Подорожувати до гравця",
    ["disband_group"] = "Розпустити групу",
    ["re_group"] = "Перегрупувати",
    ["promote_to_leader"] = "Пiдвищити до лiдера",
    ["kick_from_group"] = "Виганяти з групи",

    -- Подiї та досвiд
    ["events"] = "Подiї",
    ["experience"] = "Досвiд",
    ["champion_experience"] = "Досвiд (чемпiон)",
    ["alliance_points"] = "Очки альянсу",

    -- Спрацювання здiбностей
    ["ability_procs"] = "Спрацювання здiбностей",
    ["ability_proc_name"] = "Спрацювання здiбностi",

    -- Валюти
    ["stones"] = "Каменi",
    ["telvar"] = "Тел'Вар",

    -- Скидання та час
    ["reset"] = "Скинути",
    ["show_buff_remain_time"] = "Показати час, що залишився",
    ["show_buff_remain_time_tooltip"] = "Показує час, що залишився для баффiв або дебаффiв.",

    -- Здiбностi
    ["ability"] = "Здiбнiсть",
    ["damage_meter"] = "Лiчильник шкоди",
    ["show_only_in_group"] = "Показати тiльки в групi",

    -- Пiдтримка
    ["currently_not_supported"] = "Наразi не пiдтримується",

    -- Попередження
    ["minimap_rotate_warning"] = "При активацiї велика кiлькiсть мiток може призвести до значної втрати FPS!",

    -- Джерело та тип
    ["source"] = "Джерело",
    ["type"] = "Тип",
    ["keyboard"] = "Клавiатура",
    ["gamepad"] = "Геймпад",
    ["primary"] = "Основний",
    ["secondary"] = "Вторинний",
    ["boss"] = "Бос",

    -- Звук
    ["play_sound"] = "Вiдтворити звук",
    ["play_sound_tooltip"] = "Програється тон, коли здiбнiсть отримує спецiальний ефект.",

    -- Подiї
    ["event"] = "Подiї",

    -- Регенерацiя характеристик
    ["health_reg"] = "Вiдновлення (здоров'я)",
    ["magicka_reg"] = "Вiдновлення (магiя)",
    ["stamina_reg"] = "Вiдновлення (витривалiсть)",
    ["health_dereg"] = "Виродження (здоров'я)",
    ["mana_dereg"] = "Виродження (магiя)",
    ["stamina_dereg"] = "Виродження (витривалiсть)",

    -- Низькi показники
    ["health_low"] = "Низьке здоров'я",
    ["magicka_low"] = "Низька магiя",
    ["stamina_low"] = "Низька витривалiсть",

    -- Панелi
    ["panel"] = "Панель",
    ["panel_tooltip"] = "Вказує вiкно, в якому вiдображається вiдповiдний елемент.",
    ["left"] = "Лiворуч",
    ["middle"] = "Посерединi",
    ["right"] = "Праворуч",

    -- Повiдомлення
    ["messages"] = "Повiдомлення",
    ["no_records_available"] = "Записи недоступнi.",
    ["value"] = "Значення",
    ["measuring_time"] = "Час вимiрювання",
    ["waiting_for_combat_end"] = "Очiкування завершення бою.",

    -- Записи
    ["show_start_message"] = "Показати стартове повiдомлення",
    ["next_record"] = "Наступний запис",
    ["previous_record"] = "Попереднiй запис",
    ["load"] = "Завантажити",
    ["records"] = "Записи",
    ["date"] = "Дата",
    ["delete"] = "Видалити",
    ["load_record"] = "Завантажити запис",
    ["save_record"] = "Зберегти запис",
    ["remove_record"] = "Видалити запис",

    -- Попередження донату
    ["zero_donate_warning"] = "Будь ласка, введiть мiнiмальне значення 1000. \nнапр.: '/aui donate 1000'",

    -- iмена акаунтiв
    ["show_account_name"] = "Показати iм'я акаунта",
    ["show_account_name_tooltip"] = "Показує iм'я акаунта замiсть iменi персонажа.",

    -- Висота та час
    ["max_height"] = "Макс. висота",
    ["show_time"] = "Показати годинник",
    ["clock_suffix"] = "",
    ["time_remaining"] = "Час, що залишився",
    ["time_precision_twelfe_hour"] = "Використовувати 12-годинний формат часу",

    -- Вiкна
    ["show_windows"] = "Показати вiкна",

    -- Порiг видимостi
    ["threshold_visibility_percent"] = "Порiг у вiдсотках для видимостi",
    ["threshold_visibility_percent_tooltip"] = "Встановлює порогове значення у вiдсотках для видимостi дисплея.",

    -- Святковi подiї
    ["holiday"] = "Святковi подiї",

    -- Успiшне збереження
    ["save_record_successful"] = "Запис було успiшно збережено.",
    ["save_record_has_no_data"] = "Немає доступних записiв, якi можна зберегти.",

    -- Групова шкода та зцiлення
    ["show_group_damage"] = "Показати групову шкоду",
    ["show_group_heal"] = "Показати групове зцiлення",

    -- Питомцi та анонiмнiсть
    ["pet"] = "Питомець",
    ["anonymous"] = "Анонiмний",

    -- Заголовки та iмена
    ["show_title"] = "Показати титул",
    ["show_character_name"] = "Показати iм'я персонажа",
    ["caption"] = "Пiдпис",
    ["title"] = "Титул",
    ["character_name"] = "iм'я персонажа",
    ["account_name"] = "iм'я акаунта",

    -- Теми
    ["themes"] = "Теми",
    ["theme"] = "Тема",
    ["display"] = "Вiдображення",

    -- Пороги
    ["threshold"] = "Порiг",
    ["threshold_percent"] = "Порiг %",
    ["threshold_colorize_tooltip"] = "Визначає, з якої секунди текст забарвлюється для часу, що залишився.",
    ["threshold_animation_tooltip"] = "Визначає, з якої секунди запускається анiмацiя.",

    -- Час, що залишився
    ["remaining_time"] = "Час, що залишився",
    ["remaining_time_info"] = "Це налаштування пов'язане з налаштуванням гри в областi 'Налаштування => Бiй => Таймери панелi здiбностей', тому AUI може читати данi з таймерiв здiбностей. Коли це налаштування увiмкнено, налаштування гри також тимчасово перемикається на увiмкнене.",
    ["show_remaining_time"] = "Показати час, що залишився",
    ["show_remaining_time_tooltip"] = "При увiмкненнi показує час, що залишився, як довго здiбнiсть активна.",

    -- Анiмованi iконки
    ["show_animated_icons"] = "Показати анiмованi iконки.",
    ["show_threshold_animated_icons_tooltip"] = "Змушує iконку блимати, коли досягається порiг.",

    -- Низький рiвень
    ["low"] = "Низький",
    ["quick_slots"] = "Швидкi слоти",
    ["ability_cooldowns"] = "Перезарядження",

    -- Переднiй та заднiй план
    ["foreground"] = "Переднiй план",
    ["background"] = "Заднiй план",
    ["animation"] = "Анiмацiя",
    ["time"] = "Час",

    -- Типи пошкоджень
    ["critical"] = "Критичний",
    ["blocked"] = "Заблокований",
    ["shielded"] = "Захищений щитом",
    ["overheal"] = "Надлишкове зцiлення",
    ["absolute"] = "Абсолютний",

    -- Лiмiт записiв
    ["record_limit"] = "Лiмiт записiв",
    ["record_limit_reached"] = "Не можу зберегти запис. Досягнуто кiлькостi записiв.",

    -- Персонаж
    ["character"] = "Персонаж",

    -- Кадр перезарядження
    ["show_cooldown_frame"] = "Показати часовий кадр",
    ["show_cooldown_frame_tooltip"] = "Показує часовий кадр навколо кожної здiбностi на панелi дiй.",

    -- Дозволити тiльки власнi
    ["allow_only_own"] = "Дозволити тiльки власнi",

    -- Кiлькiсть стакiв
    ["show_stack_count"] = "Показати кiлькiсть стакiв",
    ["stack_count"] = "Кiлькiсть стакiв",

    -- Всерединi та зовнi
    ["inside"] = "Всерединi",
    ["outside"] = "Зовнi",

    -- Позицiя за замовчуванням
    ["use_default_position"] = "Використовувати позицiю за замовчуванням",
    ["use_default_position_tooltip"] = "Показує ультимативну здiбнiсть супутника на позицiї за замовчуванням.",

    -- Ультимативна та супутник
    ["ultimate"] = "Ультимативна",
    ["companion"] = "Супутник",

    -- Фон клавiш
    ["show_keybind_bg_tooltip"] = "Показує фон в областi прив'язок клавiш."
}