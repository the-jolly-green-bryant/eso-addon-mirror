-- RareFishTracker Ukrainian Localization
-- Українська локалізація RareFishTracker
-- Автор: DovahMova Team

if GetCVar("language.2") ~= "ua" then
    return
end

-- Переклад клавіатурних прив'язок
SafeAddString(SI_BINDING_NAME_RARE_FISH_TRACKER_TOGGLE, "Показати/Сховати вікно")

-- Типи води
SafeAddString(SI_RARE_FISH_TRACKER_TYPE_FOUL, "Стічна вода")
SafeAddString(SI_RARE_FISH_TRACKER_TYPE_RIVER, "Річка")
SafeAddString(SI_RARE_FISH_TRACKER_TYPE_LAKE, "Озеро")
SafeAddString(SI_RARE_FISH_TRACKER_TYPE_OCEAN, "Морська вода")

-- Меню налаштувань
SafeAddString(SI_RARE_FISH_TRACKER_WINDOW_SETTINGS, "Налаштування вікна")
SafeAddString(SI_RARE_FISH_TRACKER_WINDOW_BACKGROUND_ALPHA, "Прозорість фону вікна")
SafeAddString(SI_RARE_FISH_TRACKER_WINDOW_BACKGROUND_ALPHA_TOOLTIP, "Наскільки прозорим або непрозорим має бути фон вікна?")
SafeAddString(SI_RARE_FISH_TRACKER_SHOW_TITLE, "Показувати назву")
SafeAddString(SI_RARE_FISH_TRACKER_SHOW_TITLE_TOOLTIP, "Відображати назву аддона у вікні.")
SafeAddString(SI_RARE_FISH_TRACKER_SHOW_ZONE, "Показувати назву зони")
SafeAddString(SI_RARE_FISH_TRACKER_SHOW_ZONE_TOOLTIP, "Відображати назву поточної зони у вікні.")
SafeAddString(SI_RARE_FISH_TRACKER_FISH_TO_HIGHLIGHT, "Риба для підсвічування")
SafeAddString(SI_RARE_FISH_TRACKER_FISH_TO_HIGHLIGHT_TOOLTIP, "Підсвічувати рибу, яку ви спіймали, чи рибу, яку вам залишилося спіймати?")
SafeAddString(SI_RARE_FISH_TRACKER_CAUGHT, "Спіймана")
SafeAddString(SI_RARE_FISH_TRACKER_UNCAUGHT, "Не спіймана")

SafeAddString(SI_RARE_FISH_TRACKER_SHOW_MUNGE, "Фон вікна в стилі ESO")
SafeAddString(SI_RARE_FISH_TRACKER_SHOW_MUNGE_TOOLTIP, "Використовувати фонову текстуру в стилі ESO, як у вікні чату.")

SafeAddString(SI_RARE_FISH_TRACKER_WATER_TYPE_BACKGROUND_ALPHA, "Прозорість фону типу води")
SafeAddString(SI_RARE_FISH_TRACKER_WATER_TYPE_BACKGROUND_ALPHA_TOOLTIP, "Наскільки прозорим або непрозорим має бути фон типу води?")

SafeAddString(SI_RARE_FISH_TRACKER_SHOW_HUD, "Показувати на основному екрані")
SafeAddString(SI_RARE_FISH_TRACKER_FISH_SHOW_HUD_TOOLTIP, "Показувати вікно Rare Fish Tracker на основному екрані.")

SafeAddString(SI_RARE_FISH_TRACKER_AUTO_SHOW_HIDE_HUD, "Автоматично показувати/ховати на основному екрані")
SafeAddString(SI_RARE_FISH_TRACKER_AUTO_SHOW_HIDE_HUD_TOOLTIP, "Показувати або приховувати вікно Rare Fish Tracker на основному екрані залежно від досягнень зони.")

SafeAddString(SI_RARE_FISH_TRACKER_SHOW_WORLD_MAP, "Показувати на карті світу")
SafeAddString(SI_RARE_FISH_TRACKER_FISH_SHOW_WORLD_MAP_TOOLTIP, "Показувати вікно Rare Fish Tracker на екрані карти світу.")

SafeAddString(SI_RARE_FISH_TRACKER_USE_DEFAULT_COLORS, "Використовувати кольори ESO")
SafeAddString(SI_RARE_FISH_TRACKER_USE_DEFAULT_COLORS_TOOLTIP, "Використовувати стандартні кольори якості з ESO.")
SafeAddString(SI_RARE_FISH_TRACKER_USE_SYMBOLS, "Використовувати символи")
SafeAddString(SI_RARE_FISH_TRACKER_FISH_USE_SYMBOLS_TOOLTIP, "Використовувати символи для меншого розміру вікна.")

SafeAddString(SI_RARE_FISH_TRACKER_CAPTION_HIGHTLIGHTED_ALPHA, "Прозорість підсвіченого підпису")
SafeAddString(SI_RARE_FISH_TRACKER_CAPTION_HIGHTLIGHTED_ALPHA_TOOLTIP, "Наскільки прозорим або непрозорим має бути підсвічений підпис риби?")
SafeAddString(SI_RARE_FISH_TRACKER_CAPTION_NORMAL_ALPHA, "Прозорість звичайного підпису")
SafeAddString(SI_RARE_FISH_TRACKER_CAPTION_NORMAL_ALPHA_TOOLTIP, "Наскільки прозорим або непрозорим має бути звичайний підпис риби?")

SafeAddString(SI_RARE_FISH_TRACKER_LOCK_POSITION, "Зафіксувати позицію")
SafeAddString(SI_RARE_FISH_TRACKER_LOCK_POSITION_TOOLTIP, "Заборонити переміщення вікна.")

SafeAddString(SI_RARE_FISH_TRACKER_BIGGER_FONT, "Більший шрифт")
SafeAddString(SI_RARE_FISH_TRACKER_BIGGER_FONT_TOOLTIP, "Використовувати більший розмір шрифту та збільшити символи з 32 до 40.")

SafeAddString(SI_RARE_FISH_TRACKER_RELOADUI, "Потрібне перезавантаження інтерфейсу")
SafeAddString(SI_RARE_FISH_TRACKER_ALLOW_PER_CHAR, "Відстежувати для кожного персонажа")
SafeAddString(SI_RARE_FISH_TRACKER_ALLOW_PER_CHAR_TOOLTIP, "Відстежує рибу окремо для кожного персонажа.\nДозволяє почати відстеження заново за допомогою \"/rftzone clear\".\nАбо перенести загальний стан облікового запису за допомогою \"/rftzone\".")

SafeAddString(SI_RARE_FISH_TRACKER_SHOW_IN_SETTINGS, "Показати вікно зараз")
SafeAddString(SI_RARE_FISH_TRACKER_GRID_X, "Позиція - Сітка X (HUD)")
SafeAddString(SI_RARE_FISH_TRACKER_GRID_Y, "Позиція - Сітка Y (HUD)")
SafeAddString(SI_RARE_FISH_TRACKER_GRID_X_WORLD, "Позиція - Сітка X (Карта світу)")
SafeAddString(SI_RARE_FISH_TRACKER_GRID_Y_WORLD, "Позиція - Сітка Y (Карта світу)")
SafeAddString(SI_RARE_FISH_TRACKER_GRID_TOOLTIP, "Позиція в сітці 8x8.")
