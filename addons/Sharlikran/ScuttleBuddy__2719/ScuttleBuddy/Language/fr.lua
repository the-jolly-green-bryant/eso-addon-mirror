local strings = {
  mod_title = "ScuttleBuddy",
  map_pin_texture_text = "Apparence du marqueur sur la carte",
  map_pin_texture_desc = "Permet de choisir une icône pour le marqueur sur la carte",
  digsite_texture_text = "Apparence pour le site de fouille",
  digsite_texture_desc = "Permet de choisir une icône 3D pour le site de fouille dans le paysage",
  pin_size = "Taille du marqueur sur la carte",
  pin_size_desc = "Choisir la taille du marqueur sur la carte",
  pin_layer = "Priorité du marqueur",
  pin_layer_desc = "Choisir une priorité pour le marqueur afin qu'il soit visible au-dessus d'autres marqueurs présents au même endroit.",
  show_digsites_on_compas = "Afficher les sites de fouille sur le compas",
  show_digsites_on_compas_desc = "Permet d'afficher d'afficher ou cacher l'icône des sites de fouille sur le compas",
  compass_max_dist = "Distance max pour afficher le marqueur",
  compass_max_dist_desc = "Permet de définir la distance maximale pour faire apparaitre les icônes sur le compas.",
  spike_pincolor = "Couleur de la partie basse du marqueur 3D",
  spike_pincolor_desc = "Permet de choisir la couleur de la partie basse du marqueur 3D.",
}

for stringId, stringValue in pairs(strings) do
  SafeAddString(_G[stringId], stringValue, 1)
end
