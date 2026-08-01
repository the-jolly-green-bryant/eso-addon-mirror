OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator

OON.MARKER_TEXTURES = OON.MARKER_TEXTURES or {}
OON.MARKER_TEXTURES.lamp = "OpulentOrdealNavigator/assets/shape/lamp.dds"

-- First-pass imports from the decoded M0RMarkers saved variables export.
-- These are intentionally conservative: stable landmarks and shared anchors first,
-- then we can add full breadcrumb chains as we verify them in-game.
OON.M0R_IMPORTED_MARKERS = {
    center_middle = {
        x = 49853,
        y = 36854,
        z = 57349,
        renderLabel = "Middle",
        source = "Preset: Opulent Ordeal General#3",
    },

    red_pickup_west = {
        x = 50131,
        y = 35004,
        z = 44956,
        source = "Pickup red to orange#1",
    },
    red_pickup_east = {
        x = 50060,
        y = 35004,
        z = 45008,
        source = "Pick red to purple#1",
    },
    red_join = {
        x = 53896,
        y = 35234,
        z = 41529,
        source = "Shared red anchor: Pick red to purple#7 / Pickup red to orange#3",
    },
    red_drop_north = {
        x = 46202,
        y = 35168,
        z = 41728,
        source = "Shared red anchor: Pickup red to orange#10",
    },

    orange_join = {
        x = 45731,
        y = 35520,
        z = 52100,
        renderLabel = "Orange join",
        source = "Preset: Opulent Ordeal General#5",
    },
    purple_join = {
        x = 53522,
        y = 35354,
        z = 52460,
        renderLabel = "Purple join",
        source = "Preset: Opulent Ordeal General#6",
    },

    purple_lamp_1 = {
        room = "purple",
        kind = "lamp",
        label = "Purple lamp 1",
        renderLabel = "Lamp",
        texture = OON.MARKER_TEXTURES.lamp,
        x = 52773,
        y = 35275,
        z = 52806,
        source = "Lamps in purple#1",
    },
    purple_lamp_2 = {
        room = "purple",
        kind = "lamp",
        label = "Purple lamp 2",
        renderLabel = "Lamp",
        texture = OON.MARKER_TEXTURES.lamp,
        x = 53683,
        y = 35275,
        z = 51605,
        source = "Lamps in purple#2",
    },
    purple_lamp_3 = {
        room = "purple",
        kind = "lamp",
        label = "Purple lamp 3",
        renderLabel = "Lamp",
        texture = OON.MARKER_TEXTURES.lamp,
        x = 56990,
        y = 35104,
        z = 53205,
        source = "Lamps in purple#3",
    },
    purple_lamp_4 = {
        room = "purple",
        kind = "lamp",
        label = "Purple lamp 4",
        renderLabel = "Lamp",
        texture = OON.MARKER_TEXTURES.lamp,
        x = 57491,
        y = 35046,
        z = 48430,
        source = "Lamps in purple#4",
    },
    purple_lamp_5 = {
        room = "purple",
        kind = "lamp",
        label = "Purple lamp 5",
        renderLabel = "Lamp",
        texture = OON.MARKER_TEXTURES.lamp,
        x = 56720,
        y = 34951,
        z = 59314,
        source = "Lamps in purple#5",
    },
    purple_lamp_6 = {
        room = "purple",
        kind = "lamp",
        label = "Purple lamp 6",
        renderLabel = "Lamp",
        texture = OON.MARKER_TEXTURES.lamp,
        x = 51014,
        y = 35181,
        z = 56877,
        source = "Lamps in purple#6",
    },
}

OON.PERSISTENT_MARKER_GROUPS = OON.PERSISTENT_MARKER_GROUPS or {}
OON.PERSISTENT_MARKER_GROUPS.purple = OON.PERSISTENT_MARKER_GROUPS.purple or {}
for index = 1, 6 do
    OON.PERSISTENT_MARKER_GROUPS.purple[#OON.PERSISTENT_MARKER_GROUPS.purple + 1] = "purple_lamp_" .. index
end

for markerId, imported in pairs(OON.M0R_IMPORTED_MARKERS) do
    OON.MARKERS[markerId] = OON.MARKERS[markerId] or {}
    for key, value in pairs(imported) do
        OON.MARKERS[markerId][key] = value
    end
end
