local strings = {
    mod_title                           = "ScuttleBuddy",
    map_pin_texture_text                = "Select map pin icons",
    map_pin_texture_desc                = "Select map pin icons.",
    digsite_texture_text                = "Select 3D-Pin Scuttlebloom icons",
    digsite_texture_desc                = "Select 3D-Pin Scuttlebloom icons.",
    pin_size                            = "Pin size",
    pin_size_desc                       = "Set the size of the map pins.",
    pin_layer                           = "Pin layer",
    pin_layer_desc                      = "Set the layer of the map pins so they overlap others at the same location.",
    show_digsites_on_compas             = "Show Scuttlebloom on the compass",
    show_digsites_on_compas_desc        = "Show/hide icons for Scuttlebloom on the compass.",
    compass_max_dist                    = "Max pin distance",
    compass_max_dist_desc               = "The maximum distance for pins to appear on the compass.",
    spike_pincolor                      = "Color for lower 3D pin",
    spike_pincolor_desc                 = "The color of the lower section of the 3D pin.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
