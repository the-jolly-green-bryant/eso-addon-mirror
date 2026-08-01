local default = "По умолчанию: "
local on, off = "Включено", "Выключено"

local lang    = {
  ExecutionPanel                 = "Казнь",
  ExecutionThreshold             = "Порог казни",
  ExecutionThresholdDesc         = "Задает процент перехода на стадию казни. \nУстановка в нулевое значение отключает оповещения. \n" .. default .. BUIE.Defaults.ExecutionThreshold,
  ExecutionIcon                  = "Иконка казни",
  ExecutionIconDesc              = "Показывать иконку под здоровьем цели на стадии казни. \n" .. default .. (BUIE.Defaults.ExecutionIcon and on or off),
  ExecutionTargetHeader          = "Панель здоровья цели",
  ExecutionChangeTargetColor     = "Менять панель",
  ExecutionChangeTargetColorDesc = "Менять панель здоровья у цели на стадии казни. \n" .. default .. (BUIE.Defaults.ExecutionChangeTargetColor and on or off),
  ExecutionTargetColor           = "Цвет панели",
  ExecutionTargetColorDesc       = "Цвет панели здоровья у цели на стадии казни. \n" .. default .. BUI.TranslateColor(BUIE.Defaults.ExecutionTargetColor),
  ExecutionSoundHeader           = "Звуковое оповещение",
  ExecutionSound                 = "Воспроизводить звук",
  ExecutionSoundDesc             = "Воспроизводить звук когда начинается стадия казни. \n" .. default .. (BUIE.Defaults.ExecutionSound and on or off),
  ExecutionSoundType             = "Звук казни",
  ExecutionSoundTypeDesc         = "Звук который воспроизведется в начале стадии казни. \n" .. default .. BUIE.Defaults.ExecutionSoundType,
  ExecutionReset                 = "Сброс",
  ExecutionResetDesc             = "Сбросить до стандартных настоек казни?",
}
BUI:JoinTables(BUI.Localization.en, lang)