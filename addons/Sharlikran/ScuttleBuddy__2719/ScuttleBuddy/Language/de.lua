local strings = {
  mod_title = "ScuttleBuddy",
  map_pin_texture_text = "Wähle Karten Pin Symbole",
  map_pin_texture_desc = "Wähle Karten Pin Symbole.",
  digsite_texture_text = "Wähle 3D-Pin Ausgrabungs-Symbole",
  digsite_texture_desc = "Wähle 3D-Pin Ausgrabungsstaätten Symbole.",
  pin_size = "Pin Größe",
  pin_size_desc = "Setze die Größe der Karten Pins.",
  pin_layer = "Pin Darstellungsebene",
  pin_layer_desc = "Setze die Darstellungsebene der Karten Pins damit diese andere Pins an derselben Position überlagern können.",
  show_digsites_on_compas = "Zeige Ausgabungsstätte am Kompass",
  show_digsites_on_compas_desc = "Zeige/Verstecke Symbole für Ausgrabungsstätten auf dem Kompass.",
  compass_max_dist = "Max Pin Entfernung",
  compass_max_dist_desc = "Die maximale Entfernung in welcher Pins auf dem Kompass erscheinen.",
  spike_pincolor = "Farbe unterer 3D pin Bereich",
  spike_pincolor_desc = "Die Farbe für den unteren Bereich der 3D Pins.",
}

for stringId, stringValue in pairs(strings) do
  SafeAddString(_G[stringId], stringValue, 1)
end
