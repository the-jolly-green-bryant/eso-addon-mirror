-- strings.lua
-- Registers SI_OSF_* string IDs using ZO_CreateStringId.
-- ZO_CreateStringId auto-allocates a numeric ID from ESO's custom-string pool
-- and sets the English default value — no hardcoded numbers required.
-- Locale-specific overrides live in lang/<locale>.lua (SafeAddString, version 1).

ZO_CreateStringId("SI_OSF_SHOW_FAVORITES",  "Show Favorites")
ZO_CreateStringId("SI_OSF_ADD_FAVORITE",    "Add to Favorites")
ZO_CreateStringId("SI_OSF_REMOVE_FAVORITE", "Remove from Favorites")
