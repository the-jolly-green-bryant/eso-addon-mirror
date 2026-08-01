ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuTeleporter"] = {  
  TELE   =       "Телепорт",
  RND   =        "Случайно",
  REFRESH  =     "Обновить",
  GRP =          "Лидер группы",
  HOUSE  =       "Основной дом",
  LEGEND1  =     "Легенда",
  LEGEND2  =     "Друг",
  LEGEND3 =      "Игрок группы",

  TITLE =         "Teleporter",
  INFO =          "Информация",
  DESC =          "Откройте окно телепортера комбинацией клавиш по вашему выбору, которую вы установили в КОНТРОЛЬНОЙ ПАНЕЛИ. " ..
                  "Также в правом окне можно найти телепорт зон на карте мира.",
                  
  DESC2 =         "Кроме того, доступны следующие команды чата:\n\n"..
                  "|cff7d77/teleport|ceeeeee "..
                  "или " ..
                  "|cff7d77/tele|ceeeeee - "  ..
                  "Показать/скрыть окно телепортатора" .. 
                  "\n|cff7d77/rndteleport|ceeeeee - " ..
                  "или " ..
                  "|cff7d77/rndtele|ceeeeee - " ..
                  "Выполнить случайный телепорт",

  DESC3 =         "Телепортируйтесь в другую ЗОНУ каждые |cff7d77x|ceeeeee секунд и размещайте ваше объявление, которое вы выбрали ниже. Вы просто должны подтвердить объявление в чате в окне чата (ENTER).",
  TELE_ADVERT =   "Телепортативная реклама",
  TELEIN =        "Телепорт через Х секунд",
  ADVERTISING =   "Реклама",

  STANDARD =      "Стандартный порт",
  STANDARD_SET =  "Сначала установите место по умолчанию в настройках. Спасибо.",
  STANDARD_NOPOS ="В гильдиях не найдено подходящих игроков для телепортации на: %1 %2.",
  STANDARD_DESC = "Всегда телепортируйтесь в указанную здесь зону. \nPerform телепорт с |cff7d77/standardtele|cffffff или сочетание клавиш по вашему выбору.",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_teleportToogle", "Teleporter")
ZO_CreateStringId("SI_BINDING_NAME_SSC_teleportStandard", "Стандартный порт")