CombatCloudLocalization = {
---------------------------------------------------------------------------------------------------------------------------------------
    --//PANEL TITLES//--
---------------------------------------------------------------------------------------------------------------------------------------
    panelTitles = {
        CombatCloud_Outgoing                = "Исходящий",
        CombatCloud_Incoming                = "Входящий",
        CombatCloud_Point                   = "Очки",
        CombatCloud_Alert                   = "Предупреждения",
        CombatCloud_Resource                = "Ресурсы"
    },
---------------------------------------------------------------------------------------------------------------------------------------
    --//MAIN//--
---------------------------------------------------------------------------------------------------------------------------------------
        combatCloudOptions                  = "Настройки Combat Cloud",
        unlock                              = "Разблокировать",
        unlockTooltip                       = "Разблокировать панель для перемещения.",
---------------------------------------------------------------------------------------------------------------------------------------
    --//TOGGLE OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
    --Headers
        buttonToggleIncoming                = "Входящий урон",
        buttonToggleOutgoing                = "Исходящий урон",
        buttonToggleNotification            = "Сообщения",
        headerToggleIncomingDamageHealing   = "Входящий урон и лечение",
        headerToggleIncomingMitigation      = "Поглощение входящего урона",
        headerToggleIncomingCrowdControl    = "Входящие эффекты контроля",
        headerToggleOutgoingDamageHealing   = "Исходящий урон и лечение",
        headerToggleOutgoingMitigation      = "Поглощение исходящего урона",
        headerToggleOutgoingCrowdControl    = "Исходящие эффекты контроля",
        headerToggleCombatState             = "Статус боя",
        headerToggleAlert                   = "Предупреждения в бою",
        headerTogglePoint                   = "Очки",
        headerToggleResource                = "Ресурсы",
        descriptionAlert                    = "Включает отображение предупреждений во время боя",
    --General
        inCombatOnly                        = "Только в бою",
    --Combat State
        combatState                         = "Статьус боя",
        inCombat                            = "В бою",
        outCombat                           = "не в бою",
    --Damage & Healing
        damage                              = "Урон",
        healing                             = "Лечение",
        energize                            = "Восстановление",
        ultimateEnergize                    = "Накопление очков способности",
        drain                               = "Истощение",
        tick                                = "DoT и HoT",
        dot                                 = "Урон за время",
        hot                                 = "Лечение за время",
        critical                            = "Крит.",
    --Mitigation
        mitigation                          = "Урон снижен",
        miss                                = "Промах",
        immune                              = "Иммунитет",
        parried                             = "Парирование",
        reflected                           = "Отражение",
        damageShield                        = "Защита",
        dodged                              = "Уклонение",
        blocked                             = "Блок",
        interrupted                         = "Прерывание",
    --Crowd Control
        crowdControl                        = "Эффекты контроля",
        disoriented                         = "Дезориентирован",
        feared                              = "Испуган",
        offBalanced                         = "Потерял равновесие",
        silenced                            = "Обезмолвлен",
        stunned                             = "Оглушён",
    --Alerts
        alert                               = "Предупреждения в бою",
        alertCleanse                        = "Очистись",
        alertBlock                          = "Блокируй",
        alertExploit                        = "Используй",
        alertInterrupt                      = "Прерви",
        alertDodge                          = "Уклонись",
        alertExecute                        = "Добей",
        executeThreshold                    = "Уровень срабатывания подсказки [Добей!]",
        executeFrequency                    = "Период срабатывания подсказки [Добей!]",
        ingameTips                          = "Скрыть игровые подсказки",
    --Points
        point                               = "Очки AP, XP и CP",
        pointsAlliance                      = "Очки Альянса",
        pointsExperience                    = "Очки опыта",
        pointsChampion                      = "Чемпионские очки",
    --Resources
        resource                            = "Ресурсы",
        formatResource                      = "Мало ресурса",
        lowHealth                           = "Мало здоровья",
        lowMagicka                          = "Мало запаса магии",
        lowStamina                          = "Мало запаса сил",
        ultimateReady                       = "Доступна особая способность", -- RuESO style
        potionReady                         = "Доступен быстрый доступ",
        warningSound                        = "Звук предупреждения",
        warningThresholdHealth              = "Уровень предупреждения (здоровья)",
        warningThresholdMagicka             = "Уровень предупреждения (магии)",
        warningThresholdStamina             = "Уровень предупреждения (силы)",
    --Tooltips General
        tooltipInCombatOnly                 = "Включает отображение входящих и исходящих эффектов только во время боя",
    --Tooltips Incoming
        --Damage & Healing
        tooltipIncomingDamage               = "Включает отображение входящего урона",
        tooltipIncomingHealing              = "Включает отображение входящего эффекта лечения",
        tooltipIncomingEnergize             = "Включает отображение входящего эффекта восстановления запаса магии/силы",
        tooltipIncomingUltimateEnergize     = "Включает отображение входящего эффекта накопления очков особой способности",
        tooltipIncomingDrain                = "Включает отображение входящего эффекта истощения запаса магии/силы",
        tooltipIncomingDot                  = "Включает отображение входящего урона за время",
        tooltipIncomingHot                  = "Включает отображение входящего эффекта лечения за время",
        --Mitigation
        tooltipIncomingMiss                 = "Включает отображение [Промах] противника по вам",
        tooltipIncomingImmune               = "Включает отображение ваш [Иммунитет] к атаке противника",
        tooltipIncomingParried              = "Включает отображение ваше [Парирование] атаки",
        tooltipIncomingReflected            = "Включает отображение ваше [Отражение] атаки (только входящие)",
        tooltipIncomingDamageShield         = "Включает отображение вашу [Защита] от атаки",
        tooltipIncomingDodge                = "Включает отображение ваше [Уклонение] от атаки",
        tooltipIncomingBlocked              = "Включает отображение ваше [Блокирование] атаки",
        tooltipIncomingInterrupted          = "Включает отображение ваше [Прерывание] атаки",
        --Crowd Control
        tooltipIncomingDisoriented          = "Включает отображение когда вы [Дезориентированы]",
        tooltipIncomingFeared               = "Включает отображение когда вы [Испуганы]",
        tooltipIncomingOffBalanced          = "Включает отображение когда вы [потеряли равновесие]",
        tooltipIncomingSilenced             = "Включает отображение когда вы [Обезмолвлены]",
        tooltipIncomingStunned              = "Включает отображение когда вы [Оглушены]",
    --Tooltips Outgoing
        --Damage & Healing
        tooltipOutgoingDamage               = "Включает отображение исходящего урона",
        tooltipOutgoingHealing              = "Включает отображение исходящего эффекта лечения",
        tooltipOutgoingEnergize             = "Включает отображение исходящего эффекта восстановления запаса магии/силы",
        tooltipOutgoingUltimateEnergize     = "Включает отображение исходящего эффекта накопления очков особой способности",
        tooltipOutgoingDrain                = "Включает отображение исходящего эффекта истощения запаса магии/силы",
        tooltipOutgoingDot                  = "Включает отображение исходящего урона за время",
        tooltipOutgoingHot                  = "Включает отображение исходящего эффекта лечения за время",
        --Mitigation
        tooltipOutgoingMiss                 = "Включает отображение ваш [Промах] по противнику",
        tooltipOutgoingImmune               = "Включает отображение [Иммунитет] противника к вашим атакам",
        tooltipOutgoingParried              = "Включает отображение [Парирование] вашей атаки противником",
        tooltipOutgoingReflected            = "Включает отображение [Отражение] вашей атаки противником",
        tooltipOutgoingDamageShield         = "Включает отображение [Защита] от вашей атаки противником",
        tooltipOutgoingDodge                = "Включает отображение [Уклонения] от вашей атаки противником",
        tooltipOutgoingBlocked              = "Включает отображение [Блокирование] вашей атаки противником",
        tooltipOutgoingInterrupted          = "Включает отображение [Прерывание] вашей атаки противником",
        --Crowd Control
        tooltipOutgoingDisoriented          = "Включает отображение когда противник [Дезориентирован]",
        tooltipOutgoingFeared               = "Включает отображение когда противник [Испуган]",
        tooltipOutgoingOffBalanced          = "Включает отображение когда противник [Потерял равновесие]",
        tooltipOutgoingSilenced             = "Включает отображение когда противник [Обезмолвлен]",
        tooltipOutgoingStunned              = "Включает отображение когда противник [Оглушен]",
    --Tooltips Combat State
        tooltipInCombat                     = "Включает отображение когда бой начался",
        tooltipOutCombat                    = "Включает отображение когда бой закончился",
    --Tooltips Alerts
        tooltipAlertsCleanse                = "Включает отображение подсказки [Очиститься]",
        tooltipAlertsBlock                  = "Включает отображение подсказки [Блокировать] атаку",
        tooltipAlertsExploit                = "Включает отображение подсказки [Воспользоваться] ситуацией (например, использовать силовую/заряженую атаку, когда противник оглушен)",
        tooltipAlertsInterrupt              = "Включает отображение подсказки [Прервать] атаку",
        tooltipAlertsDodge                  = "Включает отображение подсказки [Уклониться] от атаки",
        tooltipAlertsExecute                = "Включает отображение подсказки [Добить] противника",
        tooltipExecuteThreshold             = "Порог здоровья противника для сработки предупреждения [Добей]. (По умолчанию 20%)",
        tooltipExecuteFrequency             = "Период времени сработки предупреждения [Добей]. (По умолчанию 8 секунд)",
        tooltipIngameTips                   = "Скрывает отображение всех игровых подсказок в бою",
    --Tooltips Points
        tooltipPointsAlliance               = "Включает отображение полученных очков альянса",
        tooltipPointsExperience             = "Включает отображение полученных очков опыта",
        tooltipPointsChampion               = "Включает отображение полученных чемпионских очков",
    --Tooltips Resources
        tooltipLowHealth                    = "Включает отображение предупреждения что уровень здоровья меньше указанного порога",
        tooltipLowMagicka                   = "Включает отображение предупреждения что уровень запаса магии меньше указанного порога",
        tooltipLowStamina                   = "Включает отображение предупреждения что уровень запаса силы меньше указанного порога",
        tooltipUltimateReady                = "Включает отображение предупреждения что можно использовать особую способность", -- RuESO style
        tooltipPotionReady                  = "Включает отображение предупреждения что можно использовать предмет в ячейке быстрого доступа",
        tooltipWarningSound                 = "Включает проигрывание звука когда ресурс ниже указанного уровня",
        tooltipWarningThresholdHealth       = "Порог уровня для срабатывания предупреждения. (По умолчанию - 35%)",
        tooltipWarningThresholdMagicka      = "Порог уровня для срабатывания предупреждения. (По умолчанию - 35%)",
        tooltipWarningThresholdStamina      = "Порог уровня для срабатывания предупреждения. (По умолчанию - 35%)",
---------------------------------------------------------------------------------------------------------------------------------------
    --//FONT OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
    --Headers
        buttonFont                          = "Настройки шрифта",
        buttonFontCombat                    = "Размер шрифта [Боевые сообщения]",
        buttonFontNotification              = "Размер шрифта [Предупреждения]",
    --General Fonts
        fontFace                            = "Шрифт",
        fontOutline                         = "Обводка шрифта",
        fontTest                            = "Тестовое сообщение",
        gainLoss                            = "Восстановление и истощение магии/сил",
    --Tooltips Fonts
        tooltipFontFace                     = "Подобрать шрифт",
        tooltipFontOutline                  = "Подобрать обводку шрифта",
        tooltipFontTest                     = "Генерирует случайные числа для теста выбранного шрифта",
    --Tooltips Fonts Combat
        tooltipFontDamage                   = "Размер шрифта урона (По умолчанию 26)",
        tooltipFontHealing                  = "Размер шрифта лечения (По умолчанию 26)",
        tooltipFontGainLoss                 = "Размер шрифта восстановления и истощения запаса магии/силы (По умолчанию  18)",
        tooltipFontTick                     = "Размер шрифта DoTs и HoTs (По умолчанию 18)",
        tooltipFontCritical                 = "Размер шрифта крит. ударов (По умолчанию 36)",
        tooltipFontMitigation               = "Размер шрифта поглощения урона (По умолчанию 30)",
        tooltipFontCrowdControl             = "Размер шрифта предупреждения об эффектах контроля (По умолчанию 36)",
    --Tooltips Fonts Combat State, Alerts, Points, Resources
        tooltipFontCombatState              = "Размер шрифта сообщений, когда вы входите в бой или выходите из него (по умолчанию 32)",
        tooltipFontAlert                    = "Размер шрифта предупреждений в бою (По умолчанию 48)",
        tooltipFontPoint                    = "Размер шрифта очков (По умолчанию 32)",
        tooltipFontResource                 = "Размер шрифта предупреждений об уровне ресурсов (По умолчанию 48)",
---------------------------------------------------------------------------------------------------------------------------------------
    --//COLOR OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
    --Headers
        buttonColorCombat                   = "Настройка цвета [Боевые сообщения]",
        buttonColorNotification             = "Настройка цвета [Предупреждения]",
        headerColorDamageHealing            = "Настройка цвета урона и лечения",
        headerColorMitigation               = "Настройка цвета снижения урона",
        headerColorCrowdControl             = "Настройка цвета эффектов контроля",
        headerColorCombatState              = "Настройка цвета статуса боя",
        headerColorAlert                    = "Настройка цвета предупреждений",
        headerColorPoint                    = "Настройка цвета накопления очков",
        headerColorResource                 = "Настройка цвета состояния ресурсов",
    --Damage & Healing
        energizeMagicka                     = "Восстановление (Магии)",
        energizeStamina                     = "Восстановление (Силы)",
        energizeUltimate                    = "Накопление (Очков способности)",
        drainMagicka                        = "Истощение (Магии)",
        drainStamina                        = "Истощение (Силы)",
        colorCriticalDamage                 = "Цвет критического урона",
        colorCriticalHealing                = "Цвет критического лечения",
        damageType = {
            [DAMAGE_TYPE_NONE]              = "Без типа",
            [DAMAGE_TYPE_GENERIC]           = "Общий",
            [DAMAGE_TYPE_PHYSICAL]          = "Физический",
            [DAMAGE_TYPE_FIRE]              = "Oгненный",
            [DAMAGE_TYPE_SHOCK]             = "Электрический",
            [DAMAGE_TYPE_OBLIVION]          = "Обливиона",
            [DAMAGE_TYPE_COLD]              = "Морозный",
            [DAMAGE_TYPE_EARTH]             = "Земляной",
            [DAMAGE_TYPE_MAGIC]             = "Магический",
            [DAMAGE_TYPE_DROWN]             = "Утопления",
            [DAMAGE_TYPE_DISEASE]           = "Болезненный",
            [DAMAGE_TYPE_POISON]            = "Ядовитый",
        },
    --Tooltips damage & healing
        tooltipColorHealing                 = "Установить цвет текста лечения",
        tooltipColorEnergizeMagicka         = "Установить цвет текста восстановления запаса магии",
        tooltipColorEnergizeStamina         = "Установить цвет текста восстановления запаса сил",
        tooltipColorEnergizeUltimate        = "Установить цвет текста накопления очков особой способности",
        tooltipColorDrainMagicka            = "Установить цвет текста истощения запаса магии",
        tooltipColorDrainStamina            = "Установить цвет текста истощения запаса сил",
        tooltipColorCriticalDamage          = "Переопределить цвет текста критического урона. (тип урона не имеет значения)",
        tooltipColorCriticalHealing         = "Переопределить цвет текста критического лечения",
        tooltipCriticalDamageOverride       = "Показать переопределенный цвет текста критического урона",
        tooltipCriticalHealingOverride      = "Показать переопределенный цвет текста критического лечения",
        tooltipDamageType = {
            [DAMAGE_TYPE_NONE]              = "Установить цвет текста урона без типа",
            [DAMAGE_TYPE_GENERIC]           = "Установить цвет текста общего урона",
            [DAMAGE_TYPE_PHYSICAL]          = "Установить цвет текста физического урона",
            [DAMAGE_TYPE_FIRE]              = "Установить цвет текста огненного урона",
            [DAMAGE_TYPE_SHOCK]             = "Установить цвет текста электрического урона",
            [DAMAGE_TYPE_OBLIVION]          = "Установить цвет текста урона обливиона",
            [DAMAGE_TYPE_COLD]              = "Установить цвет текста морозного урона",
            [DAMAGE_TYPE_EARTH]             = "Установить цвет текста земляного урона",
            [DAMAGE_TYPE_MAGIC]             = "Установить цвет текста магического урона",
            [DAMAGE_TYPE_DROWN]             = "Установить цвет текста урона от утопления",
            [DAMAGE_TYPE_DISEASE]           = "Установить цвет текста урона от болезни",
            [DAMAGE_TYPE_POISON]            = "Установить цвет текста ядовитого урона",
        },
    --Tooltips Mitigation
        tooltipColorMiss                    = "Установить цвет текста промаха",
        tooltipColorImmune                  = "Установить цвет текста иммунитета",
        tooltipColorParried                 = "Установить цвет текста парирования",
        tooltipColorReflected               = "Установить цвет текста отражения",
        tooltipColorDamageShield            = "Установить цвет текста защиты",
        tooltipColorDodge                   = "Установить цвет текста уклонения",
        tooltipColorBlocked                 = "Установить цвет текста блока",
        tooltipColorInterrupted             = "Установить цвет текста прерывания",
    --Tooltips Crowd Control
        tooltipColorDisoriented             = "Установить цвет текста уведомления о дизориентации",
        tooltipColorFeared                  = "Установить цвет текста уведомления о испуге",
        tooltipColorOffBalanced             = "Установить цвет текста уведомления о потери равновесия",
        tooltipColorSilenced                = "Установить цвет текста уведомления об обезмолвии",
        tooltipColorStunned                 = "Установить цвет текста уведомления об оглушении",
    --Tooltips Alerts
        tooltipColorAlertsCleanse           = "Установить цвет текста предупреждений о возможности очиститься",
        tooltipColorAlertsBlock             = "Установить цвет текста предупреждений о возможности блокировать атаку",
        tooltipColorAlertsExploit           = "Установить цвет текста предупреждений о возможности воспользоваться ситуацией",
        tooltipColorAlertsInterrupt         = "Установить цвет текста предупреждений о возможности прервать атаку",
        tooltipColorAlertsDodge             = "Установить цвет текста предупреждений о возможности уклониться от атаки",
        tooltipColorAlertsExecute           = "Установить цвет текста предупреждений о возможности добить противника",
    --Tooltips Points
        tooltipColorPointsAlliance          = "Установить цвет текста накопления очков альянса",
        tooltipColorPointsExperience        = "Установить цвет текста накопления очков опыта",
        tooltipColorPointsChampion          = "Установить цвет текста накопления чемпионских очков",
    --Tooltips Resources
        tooltipColorLowHealth               = "Установить цвет текста предупреждения о низком уровне здоровья",
        tooltipColorLowMagicka              = "Установить цвет текста предупреждения о низком уровне запаса магии",
        tooltipColorLowStamina              = "Установить цвет текста предупреждения о низком уровне запаса сил",
        tooltipColorUltimateReady           = "Установить цвет текста предупреждения о возможности использовать особую способность", -- RuESO style
        tooltipColorPotionReady             = "Установить цвет текста предупреждения о возможности использовать предмет в ячейке быстрого доступа",
    --Tooltips Combat State
        tooltipColorInCombat                = "Цвет текста сообщения о начале боя",
        tooltipColorOutCombat               = "Цвет текста сообщения об окончании боя",
---------------------------------------------------------------------------------------------------------------------------------------
    --//FORMAT OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
    --Headers
        descriptionFormat                   = "Позволяет изменить вывод текста. Напишите текст, который хотите видеть или введите специальные переменные вывода:\n %t - название способности,  локализованное\n %a - количество,  значение\n %r - тип урона,  ресурс",
        buttonFormatCombat                  = "Настройка формата текста [Боевые сообщения]",
        buttonFormatNotification            = "Настройка формата текста [Предупреждения]",
        headerFormatDamageHealing           = "Настройка формата текста урона и лечения",
        headerFormatMitigation              = "Настройка формата текста снижения урона",
        headerFormatCrowdControl            = "Настройка формата текста эффектов контроля",
        headerFormatCombatState             = "Настройка формата текста статуса боя",
        headerFormatAlert                   = "Настройка формата текста предупреждений",
        headerFormatPoint                   = "Настройка формата текста накопления очков",
        headerFormatResource                = "Настройка формата текста состояний ресурсов",
    --Tooltips Damage & Healing
        tooltipFormatDamage                 = "Настроить формат текста урона",
        tooltipFormatHealing                = "Настроить формат текста лечения",
        tooltipFormatEnergize               = "Настроить формат текста восстановления запаса магии/сил",
        tooltipFormatUltimateEnergize       = "Настроить формат текста накопления очков особой способности",
        tooltipFormatDrain                  = "Настроить формат текста истощения запаса магии/сил",
        tooltipFormatDot                    = "Настроить формат текста урона за время",
        tooltipFormatHot                    = "Настроить формат текста лечения за время",
        tooltipFormatCritical               = "Настроить формат текста критического урона",
    --Tooltips Mitigation
        tooltipFormatMiss                   = "Настроить формат текста промаха",
        tooltipFormatImmune                 = "Настроить формат текста иммунитета",
        tooltipFormatParried                = "Настроить формат текста парирования",
        tooltipFormatReflected              = "Настроить формат текста отражения",
        tooltipFormatDamageShield           = "Настроить формат текста защиты",
        tooltipFormatDodged                 = "Настроить формат текста уклонения",
        tooltipFormatBlocked                = "Настроить формат текста блока",
        tooltipFormatInterrupted            = "Настроить формат текста прерывания",
    --Tooltips Crowd Control
        tooltipFormatDisoriented            = "Настроить формат текста предупреждений о дизориентации",
        tooltipFormatFeared                 = "Настроить формат текста предупреждений о испуге",
        tooltipFormatOffBalanced            = "Настроить формат текста предупреждений о потери равновесия",
        tooltipFormatSilenced               = "Настроить формат текста предупреждений об обезмолвии",
        tooltipFormatStunned                = "Настроить формат текста предупреждений об оглушении",
    --Tooltips Alerts
        tooltipFormatAlertsCleanse          = "Настроить формат текста предупреждений о возможности очиститься",
        tooltipFormatAlertsBlock            = "Настроить формат текста предупреждений о возможности блокировать атаку",
        tooltipFormatAlertsExploit          = "Настроить формат текста предупреждений о возможности воспользоваться ситуацией",
        tooltipFormatAlertsInterrupt        = "Настроить формат текста предупреждений о возможности прервать атаку",
        tooltipFormatAlertsDodge            = "Настроить формат текста предупреждений о возможности уклониться от атаки",
        tooltipFormatAlertsExecute          = "Настроить формат текста предупреждений о возможности добить противника",
    --Tooltips Points
        tooltipFormatPointsAlliance         = "Настроить формат текста накопления очков альянса",
        tooltipFormatPointsExperience       = "Настроить формат текста накопления очков опыта",
        tooltipFormatPointsChampion         = "Настроить формат текста накопления чемпионских очков",
    --Tooltips Resources
        tooltipFormatResource               = "Настроить формат текста предупреждений о низком уровне ресурса",
        tooltipFormatUltimateReady          = "Настроить формат текста предупреждений o возможности использовать особую способность", -- RuESO style
        tooltipFormatPotionReady            = "Настроить формат текста предупреждений o возможности использовать предмет в ячейке быстрого доступа",
    --Tooltips Combat State
        tooltipFormatInCombat               = "Настроить формат текста сообщения о начале боя",
        tooltipFormatOutCombat              = "Настроить формат текста сообщения об окончании боя",
---------------------------------------------------------------------------------------------------------------------------------------
    --//ANIMATION OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
    --Headers
        buttonAnimation                     = "Настройка анимации",
    --General
        animationType                       = "Тип анимации",
        outgoingDirection                   = "Направление исходящих эффектов",
        incomingDirection                   = "Направление входящих эффектов",
        animationTest                       = "Пример анимации",
        outgoingIcon                        = "Иконка исходящих эффектов",
        incomingIcon                        = "Иконка входящих эффектов",
    --Tooltips
        tooltipAnimationType                = "Выберите тип анимации",
        tooltipAnimationIncomingDirection   = "Задает направление анимации входящих эффектов",
        tooltipAnimationOutgoingDirection   = "Задает направление анимации исходящих эффектов",
        tooltipAnimationTest                = "Тест анимации входящих и исходящих эффектов",
        tooltipAnimationOutgoingIcon        = "Задает положение иконки для исходящих эффектов",
        tooltipAnimationIncomingIcon        = "Задает положение иконки для входящих эффектов",
---------------------------------------------------------------------------------------------------------------------------------------
    --//THROTTLE OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
    --Headers
        buttonThrottle                      = "Настройки слияния",
    --General
        descriptionThrottle                 = "Суммирует значение эффекта в один результат. Используйте ползунок, чтобы задать время в миллисекундах, за которое будет суммироваться значение эффекта. Критические эффекты не суммируются.\n",
        showThrottleTrailer                 = "Показать слияние",
    --Tooltips
        tooltipThrottleDamage               = "Установить слияние для урона",
        tooltipThrottleHealing              = "Установить слияние для лечения",
        tooltipThrottleDot                  = "Установить слияние для урона за время",
        tooltipThrottleHot                  = "Установить слияние для лечения за время",
        tooltipThrottleTrailer              = "Показывает возможное слияние эффектов",
        tooltipThrottleCritical             = "Включает обьединение для критических эффектов",
}
