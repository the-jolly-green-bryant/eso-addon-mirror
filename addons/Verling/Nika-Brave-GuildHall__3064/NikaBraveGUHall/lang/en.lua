-- English Version

local local_strings = {
	
        MH_text_0  = "House",
        MH_text_1  = "Primary House",
        MH_text_02 = "The Rosy Lion",
        MH_text_03 = "The Ebony Flask Inn Room",
        MH_text_06 = "Flaming Nix Deluxe Garret",
        MH_text_13 = "Snugpod",
        MH_text_25 = "Cyrodilic Jungle House",
        MH_text_31 = "Hammerdeath Bungalow",
        MH_text_32 = "Mournoth Keep",
        MH_text_42 = "Saint Delyn Penthouse",
        MH_text_47 = "Coldharbour Surreal Estate",
        MH_text_58 = "Golden Gryphon Garret Summerset",
        MH_text_62 = "Grand Psijic Villa",
        MH_text_63 = "Enchanted Snow Globe Home",
        MH_text_70 = "Hall of the Lunar Champion",
        MH_text_80 = "Stillwaters Retreat",
        MH_text_90 = "Doomchar Plateau",
        MH_text_95 = "Ancient Anchor BerthSummerset",

        MH_text_in  = "IN",
        MH_text_out = "OUT",

          }
    
for stringId, stringValue in pairs(local_strings) do
	ZO_CreateStringId(stringId, stringValue)
        SafeAddVersion(stringId, 1)
end
