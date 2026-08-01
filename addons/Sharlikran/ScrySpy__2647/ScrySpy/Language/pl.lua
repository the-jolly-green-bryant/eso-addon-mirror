local strings = {
  mod_title = "ScrySpy",
  map_pin_texture_text = "Wybierz ikonę punktów na mapie",
  map_pin_texture_desc = "Wybiera ikonę punktów na mapie.",
  digsite_texture_text = "Wybierz ikonę punktu 3D wykopaliska",
  digsite_texture_desc = "Wybiera ikonę punktu 3D wykopaliska.",
  pin_size = "Wielkość punktów",
  pin_size_desc = "Ustawia wielkość punktu na mapie.",
  pin_layer = "Warstwa punktu",
  pin_layer_desc = "Ustaw warstwę punktów mapy tak, aby zachodziły na inne w tym samym miejscu.",
  show_digsites_on_compas = "Pokaż wykopaliska na kompasie",
  show_digsites_on_compas_desc = "Pokazuje/ukrywa ikonę wykopalisk na kompasie.",
  compass_max_dist = "Maksymalna odległość punktów",
  compass_max_dist_desc = "Maksymalna odległość, w jakiej punkty pojawiają się na kompasie.",
  spike_pincolor = "Kolor dla dolnej części punktu 3D",
  spike_pincolor_desc = "Kolor dolnej części punktu 3D.",
}

for stringId, stringValue in pairs(strings) do
  SafeAddString(_G[stringId], stringValue, 1)
end
