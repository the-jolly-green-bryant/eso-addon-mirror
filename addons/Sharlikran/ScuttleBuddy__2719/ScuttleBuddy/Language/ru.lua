local strings = {
  mod_title = "ScuttleBuddy",
  map_pin_texture_text = "Иконка метки на карте",
  map_pin_texture_desc = "Выбор иконки для метки на карте.",
  digsite_texture_text = "Иконка 3D значков мест раскопок",
  digsite_texture_desc = "Выбор иконки для 3D значков мест раскопок.",
  pin_size = "Размер метки",
  pin_size_desc = "Выбор размера меток на карте.",
  pin_layer = "Слой метки",
  pin_layer_desc = "Установка слоя меток на карте. Чем выше слой тем больше других меток они будут перекрывать если находятся на одной позиции.",
  show_digsites_on_compas = "Показывать места раскопок на компасе",
  show_digsites_on_compas_desc = "Показать/скрыть метки мест раскопок на компасе.",
  compass_max_dist = "Максимальная дальность прорисовки меток",
  compass_max_dist_desc = "Максимальная дистанция при которой метки будут отображаться на компасе.",
  spike_pincolor = "Цвет нижней части 3D значка",
  spike_pincolor_desc = "Цвет нижней части 3D значка места раскопок.",
}

for stringId, stringValue in pairs(strings) do
  SafeAddString(_G[stringId], stringValue, 1)
end
