local strings = {
    SI_HAA_PANEL_NAME               = "Heavy Attack Alerter",
    SI_HAA_COMBAT_ONLY_NAME         = "Показывать только в бою",
    SI_HAA_COMBAT_ONLY_TIP          = "Скрывает щит, пока персонаж находится вне боя.",
    SI_HAA_SOUND_NAME               = "Звук тревоги",
    SI_HAA_SOUND_TIP                = "Звуковой сигнал при начале замаха врага.",
    SI_HAA_SOUND_CHAMPION           = "Звон (Очки героя)",
    SI_HAA_SOUND_DUEL               = "Дуэль (Начало дуэли)",
    SI_HAA_SOUND_QUEST              = "Победа (Квест завершен)",
    SI_HAA_SOUND_NONE               = "Без звука",
    SI_HAA_ALPHA_NAME               = "Прозрачность зеленого щита (%)",
    SI_HAA_ALPHA_TIP                = "Насколько прозрачен щит в спокойном состоянии.",
    SI_HAA_ALERT_ALPHA_NAME         = "Прозрачность красного щита (%)",
    SI_HAA_ALERT_ALPHA_TIP          = "Насколько прозрачен щит в момент тревоги.",
    SI_HAA_SIZE_NAME                = "Размер иконки (px)",
    SI_HAA_OFFSET_X_NAME            = "Смещение по горизонтали (X)",
    SI_HAA_OFFSET_Y_NAME            = "Смещение по вертикали (Y)",
    SI_HAA_TEST_BUTTON_NAME         = "Проверить сигнал (Тест)",
    SI_HAA_TEST_BUTTON_TIP          = "Запускает тестовое предупреждение на 1.5 сек со звуком для проверки настроек.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end