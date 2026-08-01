ZO_CreateStringId("LOOTSANITIZER_NAME"                            , "LootSanitizer")
ZO_CreateStringId("LOOTSANITIZER_ACTION"                          , "уничтожил")
ZO_CreateStringId("LOOTSANITIZER_BINDACTION"                      , "привязал")

ZO_CreateStringId("LOOTSANITIZER_LCMACTION_JUNK_ON"               , "|t30:30:esoui/art/inventory/inventory_tabIcon_junk_up.dds|t Отмечать как хлам")
ZO_CreateStringId("LOOTSANITIZER_LCMACTION_JUNK_OFF"              , "|t30:30:esoui/art/inventory/inventory_tabIcon_junk_up.dds|t Отменить автоперенос")
ZO_CreateStringId("LOOTSANITIZER_LCMACTION_BURN_ON"               , "|t30:30:esoui/art/inventory/inventory_tabIcon_trash_up.dds|t |cff0000Уничтожать|r всегда")
ZO_CreateStringId("LOOTSANITIZER_LCMACTION_BURN_OFF"              , "|t30:30:esoui/art/inventory/inventory_tabIcon_trash_up.dds|t Отменить автоуничтожение")

ZO_CreateStringId("LOOTSANITIZER_WARNING"                         , "|cff0000Внимание!|r |cc5c29eУдалённые предметы нельзя вернуть. Зажмите Shift перед подбором предметов, чтобы аддон их не уничтожил.|r")

ZO_CreateStringId("LOOTSANITIZER_MESSAGE_DESTROY_SUCCESS"         , "[<<1>>] уничтожил <<2>>.") -- 1:addonName 2:itemLink
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_BIND_SUCCESS"            , "[<<1>>] привязал <<2>>.") -- 1:addonName 2:itemLink
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_JUNK_SELL_SUCCESS"       , "[<<1>>] продал <<2>> предеметов из вкладки «Хлам» на сумму <<3>> золотых.") -- 1:addonName 2:selledItemCount 3:selleditemPrice
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_RECIPE_LEARN_SUCCESS"    , "[<<1>>] выучил рецепт <<2>>!") -- 1:addonName 2:itemLink
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_RECIPE_LEARN_FAILURE"    , "[<<1>>] не смог изучить <<2>> автоматически.") -- 1:addonName 2:itemLink
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_SHIFT_STOP_DESTROY"      , "[<<1>>] не стал удалять <<2>> из-за удерживания клавиши Shift.") -- 1:addonName 2:itemLink
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_ADDON_STOP_DESTROY"      , "[<<1>>] не стал удалять <<2>> из-за отслеживания аддоном MRL.") -- 1:addonName 2:itemLink

ZO_CreateStringId("LOOTSANITIZER_WORKMODE_CONTROL"                , "Режим удаления предметов")
ZO_CreateStringId("LOOTSANITIZER_WORKMODE_CONTROL_NO"             , "Отключено")
ZO_CreateStringId("LOOTSANITIZER_WORKMODE_CONTROL_AUTOLOOT"       , "Только при автосборе")
ZO_CreateStringId("LOOTSANITIZER_WORKMODE_CONTROL_ALWAYS"         , "Всегда")

ZO_CreateStringId("LOOTSANITIZER_CHAT_NOTIFY"                     , "Уведомления в чате")
ZO_CreateStringId("LOOTSANITIZER_CHAT_NOTIFY_NO"                  , "Отключены")
ZO_CreateStringId("LOOTSANITIZER_CHAT_NOTIFY_DELETE"              , "Только о удалении")
ZO_CreateStringId("LOOTSANITIZER_CHAT_NOTIFY_DEV"                 , "Режим разработчика")

ZO_CreateStringId("LOOTSANITIZER_SOUND_CONTROL"                   , "Звуковые оповещения")

ZO_CreateStringId("LOOTSANITIZER_EQUIPMENT_HEADER"                , "Экипировка")
ZO_CreateStringId("LOOTSANITIZER_EQUIPMENT_CONTROL"               , "Удаление простой экипировки")
ZO_CreateStringId("LOOTSANITIZER_EQUIPMENT_CONTROL_COST"          , "Максимальная стоимость удаляемых предметов")
ZO_CreateStringId("LOOTSANITIZER_SIMPLECLOTHES_CONTROL"           , "Удаление серой одежды")
ZO_CreateStringId("LOOTSANITIZER_EQUIPMENT_DESCRIPTION"           , "Простая экипировка — это экипировка без ремесленных особеностей и стоимостью <<1>>.") -- 1:itemPrice
ZO_CreateStringId("LOOTSANITIZER_SIMPLECLOTHES_DESCRIPTION"       , "Одежда – экипировка без статов и бонусов набора. Обычно используется для ролеплея и стоит около <<1>>. Пример: <<2>>") -- 1:itemPrice 2:itemLink example

ZO_CreateStringId("LOOTSANITIZER_SETS_HEADER"                     , GetString(SI_ITEM_SETS_BOOK_TITLE))
ZO_CreateStringId("LOOTSANITIZER_SETS_CONTROL"                    , "Автоматическая привязка")
ZO_CreateStringId("LOOTSANITIZER_SETS_CONTROL_NO"                 , "Отключено")
ZO_CreateStringId("LOOTSANITIZER_SETS_CONTROL_GREEN"              , "Только <<1>> качество") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_SETS_CONTROL_BLUE"               , "<<1>> и ниже") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_SETS_CONTROL_PURPLE"             , "<<1>> и ниже") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_SETS_DESCRIPTION"                , "Автоматически привязывать новую экипировку выбранного качества для добавления в коллекцию. Не влияет на BoP-предметы.")

ZO_CreateStringId("LOOTSANITIZER_COMPANION_HEADER"                , GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION))
ZO_CreateStringId("LOOTSANITIZER_COMPANION_CONTROL"               , "Удаление предметов спутников")
ZO_CreateStringId("LOOTSANITIZER_COMPANION_CONTROL_NO"            , "Отключено")
ZO_CreateStringId("LOOTSANITIZER_COMPANION_CONTROL_WHITE"         , "Только <<1>> качество") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_COMPANION_CONTROL_GREEN"         , "<<1>> и ниже") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_COMPANION_CONTROL_BLUE"          , "<<1>> и ниже") -- 1:itemQuality

ZO_CreateStringId("LOOTSANITIZER_MATERIALMOTIF_HEADER"            , "Материалы стилей и мотивы")
ZO_CreateStringId("LOOTSANITIZER_MATERIAL_CONTROL"                , "Удаление материалов стилей")
ZO_CreateStringId("LOOTSANITIZER_MATERIAL_CONTROL_NO"             , "Отключено")
ZO_CreateStringId("LOOTSANITIZER_MATERIAL_CONTROL_COMMON"         , "Только стандартные")
ZO_CreateStringId("LOOTSANITIZER_MATERIAL_CONTROL_RARE"           , "Включая редкие")
ZO_CreateStringId("LOOTSANITIZER_MOTIF_CONTROL"                   , "Удаление ремесленных мотивов")
ZO_CreateStringId("LOOTSANITIZER_MOTIF_CONTROL_NO"                , "Отключено")
ZO_CreateStringId("LOOTSANITIZER_MOTIF_CONTROL_COMMON"            , "Только стандартные")
ZO_CreateStringId("LOOTSANITIZER_MOTIF_CONTROL_RARE"              , "Включая редкие")
ZO_CreateStringId("LOOTSANITIZER_MOTIFLEARN_CONTROL"              , "Автоматически учить выбранные мотивы")
ZO_CreateStringId("LOOTSANITIZER_MOTIFLEARN_CONTROL_TOOLTIP"      , "Выбранные ремесленные мотивы, если они неизвестны текущему персонажу, будут автоматически выучены.")
ZO_CreateStringId("LOOTSANITIZER_MATERIALMOTIF_DESCRIPTION"       , "Стандартными считаются стили 9-ти стандартных рас, доступных игрокам. Редкими – Варварский, Древнеэльфийский, Даэдрический и Первобытный.")
ZO_CreateStringId("LOOTSANITIZER_MATERIALSTOP_DESCRIPTION"        , "Вы можете предотвратить удаление материалов стилей с помощью режима отслеживания, используя аддон «ESO Master Recipe List».")

ZO_CreateStringId("LOOTSANITIZER_TRAIT_HEADER"                    , "Материалы особенностей")
ZO_CreateStringId("LOOTSANITIZER_TRAIT_CONTROL"                   , "Удаление материалов особенностей")
ZO_CreateStringId("LOOTSANITIZER_TRAIT_CONTROL_TOOLTIP"           , "Будут удаляться только материалы особенностей для доспехов и оружия, за исключением Нирна.")
ZO_CreateStringId("LOOTSANITIZER_TRAIT_DESCRIPTION"               , "Удаление обычных материалов особенностей для доспехов и оружия. Особенности «Сила Нирна» не удаляются.")

ZO_CreateStringId("LOOTSANITIZER_INGREDIENT_HEADER"               , "Ингредиенты")
ZO_CreateStringId("LOOTSANITIZER_INGREDIENT_CONTROL"              , "Удаление ингредиентов")
ZO_CreateStringId("LOOTSANITIZER_INGREDIENT_CONTROL_TOOLTIP"      , "Удаление ингредиентов обычной редкости.")
ZO_CreateStringId("LOOTSANITIZER_INGREDIENT_DESCRIPTION"          , "Вы можете предотвратить удаление ингридиентов с помощью режима отслеживания, используя аддон «ESO Master Recipe List».")

ZO_CreateStringId("LOOTSANITIZER_LOCKPICK_HEADER"                 , "Отмычки")
ZO_CreateStringId("LOOTSANITIZER_LOCKPICK_CONTROL"                , "Удаление лишних отмычек")
ZO_CreateStringId("LOOTSANITIZER_LOCKPICK_SLIDER"                 , "Сохраняемый запас отмычек")
ZO_CreateStringId("LOOTSANITIZER_LOCKPICK_SLIDER_TOOLTIP"         , "Указываются стаки (x200).")
ZO_CreateStringId("LOOTSANITIZER_LOCKPICK_DESCRIPTION"            , "Новые отмычки будут удаляться, после того как в инвентаре наберётся указанное количество стаков.")

ZO_CreateStringId("LOOTSANITIZER_BAIT_HEADER"                     , "Наживки")
ZO_CreateStringId("LOOTSANITIZER_BAIT_CONTROL"                    , "Удаление лишних наживок")
ZO_CreateStringId("LOOTSANITIZER_BAIT_SLIDER"                     , "Сохраняемый запас наживок")
ZO_CreateStringId("LOOTSANITIZER_BAIT_SLIDER_TOOLTIP"             , "Указываются стаки (x200).")
ZO_CreateStringId("LOOTSANITIZER_BAIT_DESCRIPTION"                , "Новые наживки будут удаляться, после того как в инвентаре наберётся указанное количество стаков.")

ZO_CreateStringId("LOOTSANITIZER_GLYPH_HEADER"                    , "Глифы")
ZO_CreateStringId("LOOTSANITIZER_GLYPH_CONTROL"                   , "Удаление глифов")
ZO_CreateStringId("LOOTSANITIZER_GLYPH_DESCRIPTION"               , "Удаление доспешных, оружейных и ювелирных глифов обычной редкости. Предметы созданные игроками удаляться не будут.")

ZO_CreateStringId("LOOTSANITIZER_RUNE_HEADER"                     , "Руны")
ZO_CreateStringId("LOOTSANITIZER_RUNE_POTENCY_CONTROL"            , "Удаление рун силы")
ZO_CreateStringId("LOOTSANITIZER_RUNE_ESSENCE_CONTROL"            , "Удаление рун сущности")
ZO_CreateStringId("LOOTSANITIZER_RUNE_DAILY_CONTROL"              , "Сохранять руны для дейликов")
ZO_CreateStringId("LOOTSANITIZER_RUNE_DESCRIPTION"                , "Удаляются все квадратные руны силы ниже 10 уровня. Треугольные руны сущности <<1>>, <<2>> и <<3>> удаляться не будут. Для ежедневных ремесленных заданий будут сохраняться руны сущности <<4>>, <<5>> и <<6>>.")

ZO_CreateStringId("LOOTSANITIZER_TRASH_HEADER"                    , "Мусор")
ZO_CreateStringId("LOOTSANITIZER_TRASH_CONTROL"                   , "Удаление дешевого мусора")
ZO_CreateStringId("LOOTSANITIZER_TRASH_DESCRIPTION"               , "Удаление предметов из категории «Мусор», которые стоят <<1>>. К примеру, <<2>>.") -- 1:itemPrice 2:itemLink example

ZO_CreateStringId("LOOTSANITIZER_JUNK_HEADER"                     , GetString("SI_ITEMTYPEDISPLAYCATEGORY", ITEM_TYPE_DISPLAY_CATEGORY_JUNK))
ZO_CreateStringId("LOOTSANITIZER_JUNK_DESCRIPTION"                , "Автоматический перенос предметов во вкладку «Хлам».")

ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL"             , "Простая экипировка")
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_OFF"         , "Отключено")
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_NORMAL"      , "Только <<1>> качество") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_UNCOMMON"    , "<<1>> и ниже") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_RARE"        , "<<1>> и ниже") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_EPIC"        , "<<1>> и ниже") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_TOOLTIP"     , "Экипировка без бонусов набора (сета) с известной особенностью.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_ORNATE_CONTROL"             , "Экипировка на продажу")
ZO_CreateStringId("LOOTSANITIZER_JUNK_ORNATE_CONTROL_TOOLTIP"     , "Экипировка с особенностью «Ценность», предназначенная для продажи торговцам.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_MIDDLE_CONTROL"             , "Сырье и материалы средних уровней")
ZO_CreateStringId("LOOTSANITIZER_JUNK_MIDDLE_CONTROL_TOOLTIP"     , "Сырье и материалы не минимального и не максимального уровня.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_NOCRPT_CONTROL"             , "Некрафтовые зелья")
ZO_CreateStringId("LOOTSANITIZER_JUNK_NOCRPS_CONTROL"             , "Некрафтовые яды")
ZO_CreateStringId("LOOTSANITIZER_JUNK_NOCRFD_CONTROL"             , "Некрафтовые блюда")
ZO_CreateStringId("LOOTSANITIZER_JUNK_NOCRDR_CONTROL"             , "Некрафтовые напитки")
ZO_CreateStringId("LOOTSANITIZER_JUNK_SLVNPT_CONTROL"             , "Растворители для зелий")
ZO_CreateStringId("LOOTSANITIZER_JUNK_SLVNPT_CONTROL_TOOLTIP"     , "Растворители для зелий любого уровня.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_SLVNPS_CONTROL"             , "Растворители для ядов")
ZO_CreateStringId("LOOTSANITIZER_JUNK_SLVNPS_CONTROL_TOOLTIP"     , "Растворители для ядов любого уровня.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TRASH_CONTROL"              , "Мусор")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TRASH_CONTROL_TOOLTIP"      , "Предметы из категории «Мусор», предназначенные для продажи торговцам.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TROVE_CONTROL"              , "Сокровища")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TROVE_CONTROL_TOOLTIP"      , "Предметы из категории «Сокровище», предназначенные для продажи торговцам (в том числе и краденные!!).")
ZO_CreateStringId("LOOTSANITIZER_JUNK_RFISH_CONTROL"              , "Редкая рыба")
ZO_CreateStringId("LOOTSANITIZER_JUNK_RFISH_CONTROL_TOOLTIP"      , "Предметы из категории «Редкая рыба», предназначенные для продажи торговцам.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_BAIT_CONTROL"               , "Наживка")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TROPHY_CONTROL"             , "Трофей с монстров")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TROPHY_CONTROL_TOOLTIP"     , "Предметы из категории «Трофей с монстров», предназначенные для продажи торговцам.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_EXCESS_REPAIRKIT_CONTROL"   , "Лишние ремонтные наборы")
ZO_CreateStringId("LOOTSANITIZER_JUNK_EXCESS_REPAIRKIT_TOOLTIP"   , "Лишними ремонтными наборами считаются полученные после сбора 1 полного стака.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_EXCESS_SOULGEM_CONTROL"     , "Лишние камни душ")
ZO_CreateStringId("LOOTSANITIZER_JUNK_EXCESS_SOULGEM_TOOLTIP"     , "Лишними камнями душ считаются полученные после сбора 1 полного стака.")

ZO_CreateStringId("LOOTSANITIZER_JUNK_AUTO_DESCRIPTION"           , "Автоматизация действий с предметами из вкладки «Хлам».")
ZO_CreateStringId("LOOTSANITIZER_JUNK_AUTOSELL_CONTROL"           , "Автоматическая продажа")
ZO_CreateStringId("LOOTSANITIZER_JUNK_AUTOSELL_TOOLTIP"           , "Автоматическая продажа предметов из вкладки «Хлам» торговцу.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_RECIPE_AUTOLEARN_CONTROL"   , "Автоматическое изучение рецептов")
ZO_CreateStringId("LOOTSANITIZER_JUNK_RECIPE_AUTOLEARN_TOOLTIP"   , "Автоматическое изучение рецептов, которые аддон помечает как «Хлам».")

ZO_CreateStringId("LOOTSANITIZER_AUTOBURN_HEADER"                 , "Автоматическое удаление")
ZO_CreateStringId("LOOTSANITIZER_DISPLAY_AUTOBURN_ACTION_CONTROL" , "Показать опцию авто-удаления")
ZO_CreateStringId("LOOTSANITIZER_DISPLAY_AUTOBURN_ACTION_TOOLTIP" , "Отображение опции автоматического удаления предметов в выпадающем меню предметов.")

ZO_CreateStringId("LOOTSANITIZER_COMMAND_HEADER"                  , "Команды")
ZO_CreateStringId("LOOTSANITIZER_COMMAND_DESCRIPTION"             , "Команды для чата, которые помогут вам взаимодействовать с аддоном.")
ZO_CreateStringId("LOOTSANITIZER_COMMAND_SETTINGS"                , "Открыть окно настроек.")
ZO_CreateStringId("LOOTSANITIZER_COMMAND_SETTINGS_ALT"            , "Открыть окно настроек (запасной вариант).")
ZO_CreateStringId("LOOTSANITIZER_COMMAND_STATISTICS"              , "Вывести в чат результаты работы аддона.")
