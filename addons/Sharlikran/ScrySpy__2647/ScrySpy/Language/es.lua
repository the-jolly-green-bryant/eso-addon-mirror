local strings = {
  mod_title = "ScrySpy",
  map_pin_texture_text = "Ícono en el mapa",
  map_pin_texture_desc = "Define el ícono del marcador que aparecerá en el mapa.",
  digsite_texture_text = "Marcador de yacimiento 3D",
  digsite_texture_desc = "Define el marcador 3D que aparecerá en los yacimientos.",
  pin_size = "Tamaño del marcador",
  pin_size_desc = "Selecciona el tamaño de los íconos en el mapa.",
  pin_layer = "Nivel del marcador",
  pin_layer_desc = "Define el nivel de los marcadores en el mapa para que aparezcan sobre o por debajo de otros marcadores en la misma ubicación.",
  show_digsites_on_compas = "Mostrar yacimientos en la brújula",
  show_digsites_on_compas_desc = "Muestra u oculta los marcadores de los yacimientos en la brújula.",
  compass_max_dist = "Distancia máxima del marcador",
  compass_max_dist_desc = "La distancia máxima en el que los marcadores aparecerán en la brújula",
  spike_pincolor = "Color inferior de marcador 3D",
  spike_pincolor_desc = "El color de la sección inferior del marcador 3D.",
}

for stringId, stringValue in pairs(strings) do
  SafeAddString(_G[stringId], stringValue, 1)
end
