-- CombatMetrics Ukrainian Integration - Comprehensive Translation
-- This file provides complete Ukrainian localization for CombatMetrics addon

-- Check if we're in Ukrainian language mode
if GetCVar("language.2") ~= "ua" then
    return
end

-- Wait for both addons to load
local function InitializeCombatMetricsUA()
    -- Check if CombatMetrics is loaded
    if not CMX then
        return
    end
    

    
    -- Language identifier
    SafeAddString(SI_COMBAT_METRICS_LANG, "ua", 1)
    SafeAddString(SI_COMBAT_METRICS_ENCHANTMENT_TRIM, " Зачарування", 1)
    
    -- Main UI strings
    SafeAddString(SI_COMBAT_METRICS_CALC, "Обчислення...", 1)
    SafeAddString(SI_COMBAT_METRICS_LOADING, "Завантаження...", 1)
    SafeAddString(SI_COMBAT_METRICS_FINALIZING, "Завершення...", 1)
    SafeAddString(SI_COMBAT_METRICS_GROUP, "Група", 1)
    SafeAddString(SI_COMBAT_METRICS_SELECTION, "Вибір", 1)
    
    -- Base stats
    SafeAddString(SI_COMBAT_METRICS_BASE_REG, "Базова регенерація", 1)
    SafeAddString(SI_COMBAT_METRICS_DRAIN, "Витрата", 1)
    SafeAddString(SI_COMBAT_METRICS_UNKNOWN, "Невідомо", 1)
    
    -- Combat stats
    SafeAddString(SI_COMBAT_METRICS_BLOCKS, "Блоки", 1)
    SafeAddString(SI_COMBAT_METRICS_CRITS, "Криті", 1)
    
    -- Damage
    SafeAddString(SI_COMBAT_METRICS_DAMAGE, "Шкода", 1)
    SafeAddString(SI_COMBAT_METRICS_DAMAGEC, "Шкода: ", 1)
    SafeAddString(SI_COMBAT_METRICS_HIT, "Удар", 1)
    SafeAddString(SI_COMBAT_METRICS_DPS, "ШВС", 1)
    SafeAddString(SI_COMBAT_METRICS_INCOMING_DPS, "Вхідна ШВС", 1)
    
    -- Healing
    SafeAddString(SI_COMBAT_METRICS_HEALING, "Лікування", 1)
    SafeAddString(SI_COMBAT_METRICS_HEALS, "Лікування", 1)
    SafeAddString(SI_COMBAT_METRICS_HPS, "ЛВС", 1)
    SafeAddString(SI_COMBAT_METRICS_HPSA, "ЛВС + Надлікування", 1)
    SafeAddString(SI_COMBAT_METRICS_INCOMING_HPS, "Вхідне ЛВС", 1)
    
    -- Edit title
    SafeAddString(SI_COMBAT_METRICS_EDIT_TITLE, "Подвійний клік для редагування назви бою", 1)
    
    -- Damage/Healing categories
    SafeAddString(SI_COMBAT_METRICS_DAMAGE_CAUSED, "Завдана шкода", 1)
    SafeAddString(SI_COMBAT_METRICS_DAMAGE_RECEIVED, "Отримана шкода", 1)
    SafeAddString(SI_COMBAT_METRICS_HEALING_DONE, "Виконане лікування", 1)
    SafeAddString(SI_COMBAT_METRICS_HEALING_RECEIVED, "Отримане лікування", 1)
    
    -- UI tabs
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_FIGHTSTATS, "Статистика бою", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_COMBAT_LOG, "Журнал бою", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_GRAPH, "Графік", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_INFO, "Інформація", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_SETTINGS, "Налаштування", 1)
    
    -- Sigil warning
    SafeAddString(SI_COMBAT_METRICS_SIGIL_WARNING, "Ця іконка вказує, що було використано печатку.", 1)
    
    -- Options menu
    SafeAddString(SI_COMBAT_METRICS_SHOWIDS, "Показати ID", 1)
    SafeAddString(SI_COMBAT_METRICS_HIDEIDS, "Приховати ID", 1)
    SafeAddString(SI_COMBAT_METRICS_SHOWOVERHEAL, "Показати надлікування", 1)
    SafeAddString(SI_COMBAT_METRICS_HIDEOVERHEAL, "Приховати надлікування", 1)
    
    -- Post DPS options
    SafeAddString(SI_COMBAT_METRICS_POSTDPS, "Опублікувати ШВС/ЛВС", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTSINGLEDPS, "Опублікувати ШВС по одній цілі", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTSMARTDPS, "Опублікувати ШВС по босу", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTMULTIDPS, "Опублікувати загальну ШВС", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTALLDPS, "Опублікувати одиночну та загальну ШВС", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTHPS, "Опублікувати ЛВС", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTUNITDPS, "Опублікувати ШВС по цій одиниці", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTUNITNAMEDPS, "Опублікувати ШВС по одиницях '<<tm:1>>'", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTSELECTIONDPS, "Опублікувати ШВС по вибраних одиницях", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTSELECTIONHPS, "Опублікувати ЛВС по вибраних одиницях", 1)
    
    -- Boss DPS
    SafeAddString(SI_COMBAT_METRICS_BOSS_DPS, "ШВС по босу", 1)
    
    -- Format strings for DPS posting
    SafeAddString(SI_COMBAT_METRICS_POSTDPS_FORMAT, "<<1>> - ШВС: <<2>> (<<3>> за <<4>>)", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTSMARTDPS_FORMAT, "<<1>><<2>> - ШВС по босу: <<3>> (<<4>> за <<5>>)", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTMULTIDPS_FORMAT, "<<1>> (+<<2>>) - ШВС: <<3>> (<<4>> за <<5>>)", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTALLDPS_FORMAT_A, "<<1>> - Загальна ШВС (+<<2>>): <<3>> (<<4>> за <<5>>)", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTALLDPS_FORMAT_B, "<<1>>: <<2>> (<<3>> за <<4>>)", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTSELECTIONDPS_FORMAT, "<<1>><<2>> - ШВС по вибору: <<3>> (<<4>> за <<5>>)", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTHPS_FORMAT, "<<1>> - ЛВС: <<2>> (<<3>> за <<4>>)", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTSELECTIONHPS_FORMAT, "<<1>> - ЛВС по вибору (x<<2>>): <<3>> (<<4>> за <<5>>)", 1)
    
    -- Buff posting
    SafeAddString(SI_COMBAT_METRICS_POSTBUFF, "Опублікувати час дії бафів", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTBUFF_BOSS, "Опублікувати час дії бафів на босах", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTBUFF_GROUP, "Опублікувати час дії бафів на членах групи", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTBUFF_FORMAT, "<<1>> - Час дії: <<2>> (<<3>><<4[/ на $d/ на $d одиниць]>>)", 1)
    SafeAddString(SI_COMBAT_METRICS_POSTBUFF_FORMAT_GROUP, "<<1>> - Час дії: <<2>>/<<5>> (<<3>>/<<6>><<4[/ на $d/ на $d одиниць]>>)", 1)
    
    -- Settings
    SafeAddString(SI_COMBAT_METRICS_SETTINGS, "Налаштування аддона", 1)
    
    -- Graph controls
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_CURSOR, "Перемкнути для показу курсору та підказки значень", 1)
    SafeAddString(SI_COMBAT_METRICS_GRAPH_BUFF_GROUP_SELECTOR, "Перемкнути для показу часу дії групи", 1)
    SafeAddString(SI_COMBAT_METRICS_RECALCULATE, "Перерахувати бій", 1)
    SafeAddString(SI_COMBAT_METRICS_SMOOTHED, "Згладжено", 1)
    SafeAddString(SI_COMBAT_METRICS_TOTAL, "Загалом", 1)
    SafeAddString(SI_COMBAT_METRICS_ABSOLUTE, "Абсолютний %", 1)
    SafeAddString(SI_COMBAT_METRICS_SMOOTH_LABEL, "Згладжування: %d с", 1)
    SafeAddString(SI_COMBAT_METRICS_NONE, "Немає", 1)
    SafeAddString(SI_COMBAT_METRICS_BOSS_HP, "Здоров'я боса", 1)
    SafeAddString(SI_COMBAT_METRICS_ENLARGE, "Збільшити", 1)
    SafeAddString(SI_COMBAT_METRICS_SHRINK, "Зменшити", 1)
    
    -- Feedback
    SafeAddString(SI_COMBAT_METRICS_FEEDBACK, "Зворотний зв'язок", 1)
    SafeAddString(SI_COMBAT_METRICS_FEEDBACK_SEND, "Надіслати відгук", 1)
    SafeAddString(SI_COMBAT_METRICS_FEEDBACK_EUONLY_FORMAT, "<<1>> (тільки EU)", 1)
    SafeAddString(SI_COMBAT_METRICS_FEEDBACK_MAIL, "Пошта в грі", 1)
    SafeAddString(SI_COMBAT_METRICS_FEEDBACK_MAIL_HEADER, "Відгук: Combat Metrics %s", 1)
    SafeAddString(SI_COMBAT_METRICS_FEEDBACK_ESOUI, "Сторінка ESOUI", 1)
    SafeAddString(SI_COMBAT_METRICS_FEEDBACK_GITHUB, "Репозиторій GitHub", 1)
    SafeAddString(SI_COMBAT_METRICS_FEEDBACK_DISCORD, "Discord", 1)
    
    -- Donations
    SafeAddString(SI_COMBAT_METRICS_DONATE, "Пожертвувати", 1)
    SafeAddString(SI_COMBAT_METRICS_DONATE_GOLD, "Золото", 1)
    SafeAddString(SI_COMBAT_METRICS_DONATE_GOLD_HEADER, "Пожертвування: Combat Metrics %s", 1)
    SafeAddString(SI_COMBAT_METRICS_DONATE_CROWNS, "Корони", 1)
    SafeAddString(SI_COMBAT_METRICS_DONATE_CROWNS_TEXT, "Якщо ви хочете подарувати щось з крон-магазину, я буду радий отримати крон-скрині або витратні предмети. \nВи також можете зв'язатися зі мною, якщо хочете подарувати щось інше.", 1)
    SafeAddString(SI_COMBAT_METRICS_DONATE_CROWNS_ACCOUNT, "Мій акаунт:", 1)
    SafeAddString(SI_COMBAT_METRICS_DONATE_ESOUI, "Сторінка пожертвувань", 1)
    
    SafeAddString(SI_COMBAT_METRICS_OK, "OK", 1)
    
    -- Storage messages
    SafeAddString(SI_COMBAT_METRICS_SAVEDFIGHTS_FULL, "Ви перевищили максимальну кількість збережених боїв. Видаліть <<1[бій/бій/$d боїв]>> або збільште дозволену кількість в налаштуваннях!", 1)
    
    -- Fight control buttons
    SafeAddString(SI_COMBAT_METRICS_PREVIOUS_FIGHT, "Попередній бій", 1)
    SafeAddString(SI_COMBAT_METRICS_NEXT_FIGHT, "Наступний бій", 1)
    SafeAddString(SI_COMBAT_METRICS_MOST_RECENT_FIGHT, "Останній бій", 1)
    SafeAddString(SI_COMBAT_METRICS_LOAD_FIGHT, "Завантажити бій", 1)
    SafeAddString(SI_COMBAT_METRICS_SAVE_FIGHT, "Клік: Зберегти бій", 1)
    SafeAddString(SI_COMBAT_METRICS_SAVE_FIGHT2, "Shift+Клік: Зберегти бій з журналом", 1)
    SafeAddString(SI_COMBAT_METRICS_DELETE_COMBAT_LOG, "Видалити журнал бою", 1)
    SafeAddString(SI_COMBAT_METRICS_DELETE_FIGHT, "Видалити бій", 1)
    
    -- Fight list
    SafeAddString(SI_COMBAT_METRICS_RECENT_FIGHT, "Останні бої", 1)
    SafeAddString(SI_COMBAT_METRICS_DURATION, "Тривалість", 1)
    SafeAddString(SI_COMBAT_METRICS_CHARACTER, "Персонаж", 1)
    SafeAddString(SI_COMBAT_METRICS_ZONE, "Зона", 1)
    SafeAddString(SI_COMBAT_METRICS_TIME, "Час", 1)
    SafeAddString(SI_COMBAT_METRICS_TIME2, "Час", 1)
    SafeAddString(SI_COMBAT_METRICS_TIMEC, "Час: ", 1)
    SafeAddString(SI_COMBAT_METRICS_SHOW, "Показати", 1)
    SafeAddString(SI_COMBAT_METRICS_DELETE, "Видалити", 1)
    SafeAddString(SI_COMBAT_METRICS_SAVED_FIGHTS, "Збережені бої", 1)
    
    -- More UI strings
    SafeAddString(SI_COMBAT_METRICS_ACTIVE_TIME, "Активний час: ", 1)
    SafeAddString(SI_COMBAT_METRICS_ZERO_SEC, "0 с", 1)
    SafeAddString(SI_COMBAT_METRICS_IN_COMBAT, "У бою: ", 1)
    SafeAddString(SI_COMBAT_METRICS_PLAYER, "Гравець", 1)
    
    -- Stats details
    SafeAddString(SI_COMBAT_METRICS_TOTALC, " Загалом: ", 1)
    SafeAddString(SI_COMBAT_METRICS_NORMAL, "Звичайне: ", 1)
    SafeAddString(SI_COMBAT_METRICS_CRITICAL, "Критичне: ", 1)
    SafeAddString(SI_COMBAT_METRICS_BLOCKED, "Заблоковано: ", 1)
    SafeAddString(SI_COMBAT_METRICS_SHIELDED, "Поглинуто щитом: ", 1)
    SafeAddString(SI_COMBAT_METRICS_ABSOLUTEC, "Абсолютне: ", 1)
    SafeAddString(SI_COMBAT_METRICS_OVERHEAL, "Надлікування: ", 1)
    
    SafeAddString(SI_COMBAT_METRICS_HITS, "Удари", 1)
    SafeAddString(SI_COMBAT_METRICS_NORM, "Звич", 1)
    SafeAddString(SI_COMBAT_METRICS_RESOURCES, "Ресурси", 1)
    
    -- Stats labels
    SafeAddString(SI_COMBAT_METRICS_STATS, "Статистика", 1)
    SafeAddString(SI_COMBAT_METRICS_AVE, "Сер", 1)
    SafeAddString(SI_COMBAT_METRICS_AVE_N, "Сер З", 1)
    SafeAddString(SI_COMBAT_METRICS_AVE_C, "Сер К", 1)
    SafeAddString(SI_COMBAT_METRICS_AVERAGE, "Середнє", 1)
    SafeAddString(SI_COMBAT_METRICS_NORMAL_HITS, "Звичайні удари", 1)
    SafeAddString(SI_COMBAT_METRICS_MAX, "Макс", 1)
    SafeAddString(SI_COMBAT_METRICS_MIN, "Мін", 1)
    
    -- Combat log
    SafeAddString(SI_COMBAT_METRICS_COMBAT_LOG, "Журнал бою", 1)
    SafeAddString(SI_COMBAT_METRICS_GOTO_PREVIOUS, "Перейти до попередньої сторінки", 1)
    SafeAddString(SI_COMBAT_METRICS_PAGE, "Перейти до сторінки <<1>>", 1)
    SafeAddString(SI_COMBAT_METRICS_GOTO_NEXT, "Перейти до наступної сторінки", 1)
    
    -- Toggle options
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_HEAL, "Перемкнути події отриманого лікування", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_DAMAGE, "Перемкнути події отриманої шкоди", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_YOUR_HEAL, "Перемкнути ваші події лікування", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_YOUR_DAMAGE, "Перемкнути ваші події шкоди", 1)
    
    -- Buff events
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_BUFFIN_EVENTS, "Перемкнути вхідні події бафів", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_BUFFOUT_EVENTS, "Перемкнути вихідні події бафів", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_GROUPBUFFIN_EVENTS, "Перемкнути вхідні події групових бафів", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_GROUPBUFFOUT_EVENTS, "Перемкнути вихідні події групових бафів", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_RESOURCE_EVENTS, "Перемкнути події ресурсів", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_STATS_CHANGE_EVENTS, "Перемкнути події зміни характеристик", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_MESSAGE_CHANGE_EVENTS, "Перемкнути інформаційні події (напр. зміна зброї)", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_SKILL_USE_EVENTS, "Перемкнути події використання навичок", 1)
    
    -- Resource labels with line breaks
    SafeAddString(SI_COMBAT_METRICS_DEBUFF_IN, "(Де-)Бафи\nВхід", 1)
    SafeAddString(SI_COMBAT_METRICS_DEBUFF_OUT, "(Де-)Бафи\nВихід", 1)
    SafeAddString(SI_COMBAT_METRICS_MAGICKA_PM, "Магія\n +/-", 1)
    SafeAddString(SI_COMBAT_METRICS_STAMINA_PM, "Витривалість\n +/-", 1)
    SafeAddString(SI_COMBAT_METRICS_RESOURCES_PM, "Ресурси\n +/-", 1)
    
    -- Buffs and debuffs
    SafeAddString(SI_COMBAT_METRICS_BUFF, "Баф", 1)
    SafeAddString(SI_COMBAT_METRICS_BUFFS, "Бафи", 1)
    SafeAddString(SI_COMBAT_METRICS_DEBUFFS, "Дебафи", 1)
    SafeAddString(SI_COMBAT_METRICS_SHARP, "#", 1)
    SafeAddString(SI_COMBAT_METRICS_BUFFCOUNT_TT, "Гравець / Загалом", 1)
    SafeAddString(SI_COMBAT_METRICS_UPTIME, "Час дії %", 1)
    SafeAddString(SI_COMBAT_METRICS_UPTIME_TT, "Гравець % / Загалом %", 1)
    
    -- Resource management
    SafeAddString(SI_COMBAT_METRICS_REGENERATION, "Регенерація", 1)
    SafeAddString(SI_COMBAT_METRICS_CONSUMPTION, "Споживання", 1)
    SafeAddString(SI_COMBAT_METRICS_PM_SEC, "±/с", 1)
    SafeAddString(SI_COMBAT_METRICS_TARGET, "Ціль", 1)
    SafeAddString(SI_COMBAT_METRICS_PERCENT, "%", 1)
    SafeAddString(SI_COMBAT_METRICS_UNITDPS_TT, "Реальна ШВС, напр. шкода в секунду між вашим першим та останнім ударом по цій цілі", 1)
    
    -- Abilities
    SafeAddString(SI_COMBAT_METRICS_ABILITY, "Здібність", 1)
    SafeAddString(SI_COMBAT_METRICS_PER_HITS, "/Удари", 1)
    SafeAddString(SI_COMBAT_METRICS_CRITS_PER, "Крит %", 1)
    SafeAddString(SI_COMBAT_METRICS_FAVOURITE_ADD, "Додати до улюблених", 1)
    SafeAddString(SI_COMBAT_METRICS_FAVOURITE_REMOVE, "Видалити з улюблених", 1)
    SafeAddString(SI_COMBAT_METRICS_SKILL, "Навичка", 1)
    
    -- Skill bars
    SafeAddString(SI_COMBAT_METRICS_BAR, "Панель ", 1)
    SafeAddString(SI_COMBAT_METRICS_AVERAGEC, "Середнє: ", 1)
    SafeAddString(SI_COMBAT_METRICS_SKILLTIME_LABEL2, "< З / Н", 1) -- Зброя / Навичка
    SafeAddString(SI_COMBAT_METRICS_SKILLTIME_LABEL3, "З / Н >", 1)
    
    -- Skill timing tooltips
    SafeAddString(SI_COMBAT_METRICS_SKILLTIME_TT1, "Кількість використань цієї навички", 1)
    SafeAddString(SI_COMBAT_METRICS_SKILLTIME_TT2, "Час від останньої активації зброї/навички до активації здібності.", 1)
    SafeAddString(SI_COMBAT_METRICS_SKILLTIME_TT3, "Час між активацією здібності та наступною активацією зброї/навички.", 1)
    SafeAddString(SI_COMBAT_METRICS_SKILLTIME_TT4, "Середній час між послідовними активаціями цієї навички", 1)
    
    SafeAddString(SI_COMBAT_METRICS_SAVED_DATA, "Збережені дані", 1)
    
    -- Missing strings from comprehensive review
    SafeAddString(SI_COMBAT_METRICS_LOADING, "Завантаження...", 1)
    SafeAddString(SI_COMBAT_METRICS_NORM, "Звич", 1)
    SafeAddString(SI_COMBAT_METRICS_OH, "НЛ", 1) -- Надлікування
    SafeAddString(SI_COMBAT_METRICS_AVE_B, "Сер Б", 1) -- Середнє Блоковане
    SafeAddString(SI_COMBAT_METRICS_EFFECTIVE, "Ефективне", 1)
    
    -- Detailed stats
    SafeAddString(SI_COMBAT_METRICS_STATS_MAGICKA1, "Макс магія", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_MAGICKA2, "Сила заклинань", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_MAGICKA3, "Крит заклинань", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_MAGICKA4, "Критична шкода", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_MAGICKA5, "Проникнення заклинань", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_MAGICKA6, "Надпроникнення", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_MAGICKA7, "Проки статус ефектів", 1)
    
    SafeAddString(SI_COMBAT_METRICS_STATS_STAMINA1, "Макс витривалість", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_STAMINA2, "Сила зброї", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_STAMINA3, "Крит зброї", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_STAMINA4, "Критична шкода", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_STAMINA5, "Фіз. проникнення", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_STAMINA6, "Надпроникнення", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_STAMINA7, "Проки статус ефектів", 1)
    
    SafeAddString(SI_COMBAT_METRICS_STATS_HEALTH1, "Макс здоров'я", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_HEALTH2, "Фізичний опір", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_HEALTH3, "Опір заклинанням", 1)
    SafeAddString(SI_COMBAT_METRICS_STATS_HEALTH4, "Опір критам", 1)
    
    -- Performance
    SafeAddString(SI_COMBAT_METRICS_PERFORMANCE, "Продуктивність", 1)
    SafeAddString(SI_COMBAT_METRICS_PERFORMANCE_FPSAVG, "Середній FPS", 1)
    SafeAddString(SI_COMBAT_METRICS_PERFORMANCE_FPSMIN, "Мінімальний FPS", 1)
    SafeAddString(SI_COMBAT_METRICS_PERFORMANCE_FPSMAX, "Максимальний FPS", 1)
    SafeAddString(SI_COMBAT_METRICS_PERFORMANCE_FPSPING, "Пінг", 1)
    SafeAddString(SI_COMBAT_METRICS_PERFORMANCE_DESYNC, "Десинхронізація навичок", 1)
    
    -- Tooltips
    SafeAddString(SI_COMBAT_METRICS_PENETRATION_TT, "Проникнення проти шкоди", 1)
    SafeAddString(SI_COMBAT_METRICS_CRITBONUS_TT, "Крит проти шкоди", 1)
    SafeAddString(SI_COMBAT_METRICS_BACKSTABBER_TT, "*Backstabber включено так, ніби всі цілі завжди з флангу", 1)
    
    -- Copy paste
    SafeAddString(SI_COMBAT_METRICS_COPY_PASTE, "Перемкнути режим копіювання журналу бою", 1)
    SafeAddString(SI_COMBAT_METRICS_TOGGLE_PERFORMANCE_EVENTS, "Перемкнути інформацію про продуктивність", 1)
    
    -- Collapse/expand
    SafeAddString(SI_COMBAT_METRICS_UNCOLLAPSE, "Показати деталі", 1)
    SafeAddString(SI_COMBAT_METRICS_COLLAPSE, "Згорнути", 1)
    
    -- Weaving
    SafeAddString(SI_COMBAT_METRICS_SKILLTIME_LABEL2, "плетіння", 1)
    SafeAddString(SI_COMBAT_METRICS_SKILLTIME_LABEL3, "помилка", 1)
    SafeAddString(SI_COMBAT_METRICS_SKILLTIME_TT2, "Час плетіння\n\nСередній втрачений час до наступного каста навички.", 1)
    SafeAddString(SI_COMBAT_METRICS_SKILLTIME_TT3, "Помилки плетіння\n\nКількість разів, коли активація навички не супроводжувалась атакою зброї або навпаки", 1)
    SafeAddString(SI_COMBAT_METRICS_SKILLTIME_WEAVING, "Середнє плетіння: ", 1)
    SafeAddString(SI_COMBAT_METRICS_SKILLAVG_TT, "Середній втрачений час між двома кастами навичок", 1)
    SafeAddString(SI_COMBAT_METRICS_SKILLTOTAL_TT, "Загальний втрачений час між кастами навичок", 1)
    
    -- Weapon attacks and skills
    SafeAddString(SI_COMBAT_METRICS_TOTALWA, "Атаки зброї: ", 1)
    SafeAddString(SI_COMBAT_METRICS_TOTALWA_TT, "Загальна кількість легких та важких атак", 1)
    SafeAddString(SI_COMBAT_METRICS_TOTALSKILLS, "Навички: ", 1)
    SafeAddString(SI_COMBAT_METRICS_TOTALSKILLS_TT, "Загальна кількість використаних навичок", 1)
    
    -- Live report
    SafeAddString(SI_COMBAT_METRICS_SHOW_XPS, "<<1>> / <<2>> (<<3>>%)", 1)
    
    -- Settings menu - comprehensive
    SafeAddString(SI_COMBAT_METRICS_MENU_PROFILES, "Профілі", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_AC_NAME, "Використовувати налаштування акаунта", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_AC_TOOLTIP, "Якщо увімкнено, всі персонажі акаунта будуть ділитися налаштуваннями", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_GS_NAME, "Загальні налаштування", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_FH_NAME, "Історія боїв", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_FH_TOOLTIP, "Кількість останніх боїв для збереження", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_MAXSAVEDFIGHTS_NAME, "Збережені бої", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_MAXSAVEDFIGHTS_TOOLTIP, "Максимальна кількість боїв, які можна зберегти", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_MAXSAVEDFIGHTS_WARNING, "Збереження занадто багатьох боїв може збільшити час завантаження.", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_BOSSFIGHTS_NAME, "Зберігати бої з босами", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_BOSSFIGHTS_TOOLTIP, "Видаляти звичайні бої перед боями з босами при досягненні ліміту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_MG_NAME, "Моніторити шкоду групи", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_MG_TOOLTIP, "Моніторити події всієї групи", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_STACKS_NAME, "Показувати стаки бафів", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_STACKS_TOOLTIP, "Показувати окремі стаки в панелі бафів", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_GL_NAME, "Моніторити шкоду у великих групах", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_GL_TOOLTIP, "Моніторити шкоду групи у великих групах (більше 4 учасників)", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_LM_NAME, "Легкий режим", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_LM_TOOLTIP, "У легкому режимі Combat Metrics буде обчислювати тільки ШВС/ЛВС у вікні живого звіту. Статистика не обчислюватиметься, а вікно звіту бою буде вимкнено", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_NOPVP_NAME, "Вимкнути у PvP", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_NOPVP_TOOLTIP, "Вимикає всі записи боїв у Сіродіїлі та на полях битв", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_LMPVP_NAME, "Легкий режим у PvP", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_LMPVP_TOOLTIP, "Перемикає на легкий режим у Сіродіїлі та на полях битв. У легкому режимі Combat Metrics буде обчислювати тільки ШВС/ЛВС у вікні живого звіту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_ASCC_NAME, "Автовибір каналу", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_ASCC_TOOLTIP, "Автоматично вибирати канал при публікації ШВС/ЛВС у чат. У групі використовується /group, інакше /say", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_AS_NAME, "Автоскріншот", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_AS_TOOLTIP, "Автоматично робити скріншот при відкритті вікна звіту бою", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_ML_NAME, "Мінімальна тривалість бою для скріншоту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_ML_TOOLTIP, "Мінімальна тривалість бою в секундах для автоскріншоту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SF_NAME, "Масштаб вікна звіту бою", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SF_TOOLTIP, "Регулює розмір всіх елементів вікна звіту бою", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_DISPLAYNAMES_NAME, "Показувати імена акаунтів", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_DISPLAYNAMES_TOOLTIP, "Показує імена акаунтів (@Ім'я) замість імен персонажів для членів групи", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOWPETS_NAME, "Показувати петів", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_HIDEPETS, "Приховати петів", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOWPETS_TOOLTIP, "Показує петів у вікні звіту бою", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_NOTIFICATIONS, "Дозволити сповіщення", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_NOTIFICATIONS_TOOLTIP, "Час від часу я можу додавати сповіщення до вікна звіту, наприклад для збору даних або набору людей до рейду. Вимкніть це, якщо не хочете таких сповіщень.", 1)
    
    -- Resistance and penetration settings
    SafeAddString(SI_COMBAT_METRICS_MENU_RESPEN_NAME, "Опір та проникнення", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CRUSHER, "Crusher", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CRUSHER_TOOLTIP, "Зниження опору від дебафу гліфу Crusher. \nДля CP160 золотого гліфу: \nстандартний: 1622 \nнасичений: 2108 \nнасичений + Torug's: 2740", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_ALKOSH, "Alkosh", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_ALKOSH_TOOLTIP, "Зниження опору від дебафу Roar of Alkosh. \nВизначається більшим з урону зброї або заклинань кастера, до максимуму 6000.", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_TREMORSCALE, "Tremorscale", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_TREMORSCALE_TOOLTIP, "Зниження опору від дебафу Tremorscale. \nВизначається більшим з фізичного або магічного опору кастера, помноженим на 0.08.", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_MOBRESISTANCE, "Опір цілі", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_MOBRESISTANCE_TOOLTIP, "Опір цілі, що використовується для розрахунку надпроникнення", 1)
    
    -- Live report window settings
    SafeAddString(SI_COMBAT_METRICS_MENU_LR_NAME, "Вікно живого звіту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_ENABLE_NAME, "Увімкнути", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_ENABLE_TOOLTIP, "Увімкнути вікно живого звіту, яке показує ШВС та ЛВС під час бою", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_LR_LOCK, "Заблокувати", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_LR_LOCK_TOOLTIP, "Заблокувати вікно живого звіту, щоб його не можна було переміщувати", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_LR_ALIGNMENT, "Використовувати ліве вирівнювання чисел", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_LR_ALIGNMENT_TOOLTIP, "Встановлює позиціювання чисел шкоди/лікування тощо для вікна живого звіту по лівому краю", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_LAYOUT_NAME, "Макет", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_LAYOUT_TOOLTIP, "Вибрати макет вікна живого звіту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SCALE_NAME, "Масштаб", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SCALE_TOOLTIP, "Масштаб вікна живого звіту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_BGALPHA_NAME, "Прозорість фону", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_BGALPHA_TOOLTIP, "Встановити прозорість фону", 1)
    
    -- Show options for live report
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_DPS_NAME, "Показувати ШВС", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_DPS_TOOLTIP, "Показувати ШВС, яку ви завдаєте, у вікні живого звіту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_SDPS_NAME, "Показувати ШВС по одній цілі", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_SDPS_TOOLTIP, "Показувати ШВС по одній цілі, яку ви завдаєте, у вікні живого звіту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_HPS_NAME, "Показувати ЛВС", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_HPS_TOOLTIP, "Показувати ЛВС, яке ви здійснюєте, у вікні живого звіту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_HPSA_NAME, "Показувати ЛВС + надлікування", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_HPSA_TOOLTIP, "Показувати ЛВС включно з надлікуванням, яке ви здійснюєте, у вікні живого звіту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_INC_DPS_NAME, "Показувати вхідну ШВС", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_INC_DPS_TOOLTIP, "Показувати ШВС, яку ви отримуєте, у вікні живого звіту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_INC_HPS_NAME, "Показувати вхідне ЛВС", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_INC_HPS_TOOLTIP, "Показувати ЛВС, яке ви отримуєте, у вікні живого звіту", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_TIME_NAME, "Показувати час", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_SHOW_TIME_TOOLTIP, "Показувати час, протягом якого ви завдавали шкоду, у вікні живого звіту", 1)
    
    -- Chat streaming
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_TITLE, "Транслювати журнал бою в чат", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_WARNING, "Використовуйте обережно! Створення текстових рядків потребує багато роботи від процесора. Краще вимкнути це, якщо очікуються важкі бої (випробування, Сіродіїл)", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_DH_TOOLTIP, "Транслює події шкоди та лікування у вікно чату", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_TITLE_NAME, "Заголовок журналу чату", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_TITLE_TOOLTIP, "Показувати шкоду, яку ви завдаєте, у трансляції чату", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_SD_NAME, "Показувати шкоду", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_SD_TOOLTIP, "Показувати шкоду, яку ви завдаєте, у трансляції чату", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_SH_NAME, "Показувати лікування", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_SH_TOOLTIP, "Показувати лікування, яке ви здійснюєте, у трансляції чату", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_SID_NAME, "Показувати вхідну шкоду", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_SID_TOOLTIP, "Показувати шкоду, яку ви отримуєте, у трансляції чату", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_SIH_NAME, "Показувати вхідне лікування", 1)
    SafeAddString(SI_COMBAT_METRICS_MENU_CHAT_SIH_TOOLTIP, "Показувати лікування, яке ви отримуєте, у трансляції чату", 1)
    
    -- Live report tooltips
    SafeAddString(SI_COMBAT_METRICS_LIVEREPORT_GROUP_TOOLTIP, "Гравець / Група", 1)
    SafeAddString(SI_COMBAT_METRICS_LIVEREPORT_DPSSINGLE_TOOLTIP, "ШВС по одній цілі", 1)
    SafeAddString(SI_COMBAT_METRICS_LIVEREPORT_DPSBOSS_TOOLTIP, "ШВС по босу", 1)
    SafeAddString(SI_COMBAT_METRICS_LIVEREPORT_DPSMULTI_TOOLTIP, "ШВС по кількох цілях", 1)
    SafeAddString(SI_COMBAT_METRICS_LIVEREPORT_HPSOUT_TOOLTIP, "ЛВС", 1)
    SafeAddString(SI_COMBAT_METRICS_LIVEREPORT_HPSRAW_TOOLTIP, "Сире ЛВС (вкл. надлікування)", 1)
    SafeAddString(SI_COMBAT_METRICS_LIVEREPORT_DPSINC_TOOLTIP, "Вхідна ШВС", 1)
    SafeAddString(SI_COMBAT_METRICS_LIVEREPORT_HPSINC_TOOLTIP, "Вхідне ЛВС", 1)
    SafeAddString(SI_COMBAT_METRICS_LIVEREPORT_TIME_TOOLTIP, "Тривалість бою", 1)
    
    -- Keybindings
    SafeAddString(SI_BINDING_NAME_CMX_REPORT_TOGGLE, "Перемкнути звіт бою", 1)
    SafeAddString(SI_BINDING_NAME_CMX_LIVEREPORT_TOGGLE, "Перемкнути живий звіт", 1)
    SafeAddString(SI_BINDING_NAME_CMX_POST_DPS_SMART, "Опублікувати ШВС по босу або загальну", 1)
    SafeAddString(SI_COMBAT_METRICS_POST_DPS_SINGLE, "Опублікувати ШВС по одній цілі", 1)
    SafeAddString(SI_BINDING_NAME_CMX_POST_DPS_MULTI, "Опублікувати ШВС по кількох цілях", 1)
    SafeAddString(SI_BINDING_NAME_CMX_POST_DPS, "Опублікувати ШВС по одній + кількох цілях", 1)
    SafeAddString(SI_BINDING_NAME_CMX_POST_HPS, "Опублікувати лікування в чат", 1)
    SafeAddString(SI_BINDING_NAME_CMX_RESET_FIGHT, "Вручну скинути бій", 1)
    
    -- Database conversion
    SafeAddString(SI_COMBAT_METRICS_CONVERT_DB_TITLE, "COMBAT METRICS", 1)
    SafeAddString(SI_COMBAT_METRICS_CONVERT_DB_TEXT, "Ця версія має новий спосіб збереження боїв. Він займає менше місця та зменшує час завантаження UI, навіть з набагато більшою кількістю збережених боїв. \n\nЩоб скористатися цим та дозволити збереження нових боїв, всі збережені бої потрібно конвертувати. \n\nЦей процес може зайняти до кількох хвилин.", 1)
    SafeAddString(SI_COMBAT_METRICS_CONVERT_DB_BUTTON1_TEXT, "Конвертувати", 1)
    SafeAddString(SI_COMBAT_METRICS_CONVERT_DB_BUTTON2_TEXT, "Скасувати", 1)
    SafeAddString(SI_COMBAT_METRICS_CONVERSION_TITLE_TEXT, "Конвертація бою <<1>>/<<2>> ...", 1)
    SafeAddString(SI_COMBAT_METRICS_CONVERSION_FINISHED_TEXT, "Конвертація завершена!", 1)
    
    -- Notification strings (keeping original for specific guild reference)
    SafeAddString(SI_COMBAT_METRICS_NOTIFICATION_ACCEPT, "Повідомлення прочитано", 1)
    SafeAddString(SI_COMBAT_METRICS_NOTIFICATION_DISCARD, "Вимкнути сповіщення", 1)
    

    
    -- Register with DovahMova integration system
    -- Create integrations table if it doesn't exist
    if DovahMova then
        if not DovahMova.integrations then
            DovahMova.integrations = {}
        end
        
        DovahMova.integrations["CombatMetrics"] = {
            name = "CombatMetrics",
            version = "1.0",
            loaded = true,
            strings_loaded = true,
            total_strings = 250 -- comprehensive count
        }

    end
end

-- Initialize when both addons are ready
local function OnAddOnLoaded(eventCode, addonName)
    if addonName == "DovahMova" or addonName == "CombatMetrics" then
        -- Use a small delay to ensure both addons are fully loaded
        zo_callLater(function()
            InitializeCombatMetricsUA()
        end, 200)
    end
end

EVENT_MANAGER:RegisterForEvent("CombatMetricsUA_Comprehensive", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
