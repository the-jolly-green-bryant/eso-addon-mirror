------------------------------------------------
-- English localization for IsJustaFavoriteCollectibles
------------------------------------------------

--IJA_FURNITURE_THEME_TYPE_FAVORITES = FURNITURE_THEME_TYPE_MAX_VALUE + 1
--FURNITURE_THEME_TYPE_MAX_VALUE = IJA_FURNITURE_THEME_TYPE_FAVORITES

local strings = {
	SI_IJA_FC_ACCOUNT			= "Account wide settings",
	SI_IJA_FC_ACCOUNT_TIP		= "On: Use Account wide settings and favorites\nOff: Use Account wide settings and per character favorites",

	SI_IJA_FC_FAVES				= "Favorites",
	--SI_IJA_FC_ADD				= "Add Favorite",
	--SI_IJA_FC_REMOVE			= "Remove Favorite",

	SI_IJA_FC_FILTER			= "Usable Only",
	SI_IJA_FC_FILTER_TIP		= "Enabled: filters out items that cannot be used by the current character (example: if the current character is a female and the items is for a male, the item will not show in the favorites, but remain where it would normally be).",
	
	SI_IJA_FC_FURNITURE			= "Favorite Furniture",
	SI_IJA_FC_FURNITURE_TIP		= "Enabled: allows collectible furniture items to be sorted by \"Favorite Collectibles\" theme in the Housing Editor\n\nThis applies only to Keyboard mode.",
	
	SI_IJA_FC_USETHEME			= "Use Current Theme",
	SI_IJA_FC_USETHEME_TIP		= "Enabled: if a theme is selected in keyboard mode for Place or Retrieve, the theme will carry over to gamepad mode.\n\nNote:you will need to go back to keyboard mode to change the theme.",
	
	SI_IJA_FC_COPY_SAVES_TIP	= "This will import selected saved favorites and overwrite the current ones.",
	SI_IJA_FC_COPY_SAVES_WARN	= "This will overwrite all current favorites with the favorites of <<1>>.",
	
	SI_IJA_FC_COPY_SAVES_TITLE	= "Copy or Import Favorites",
	SI_IJA_FC_COPY_SAVES_TEXT	= "Are you sure you want to copy favorites from |cFFFFFF<<1>>|r to |cFFFFFF<<2>>|r?",
	
	SI_IJA_FC_COPY_SAVES_TO1	= "Current Character",
	SI_IJA_FC_COPY_SAVES_TO2	= "Integrated favorites",
	SI_IJA_FC_COPY_SAVES_TO3	= "Import",
	
	SI_IJA_FC_ICON_TOOLTIP		= "Right-Click <<1>>",
	
	SI_IJA_FC_IMPORTING_HEADER	= "Importing favorites.",
	
	SI_IJA_FC_IMPORTING1		= "Importing favorites started.",
	SI_IJA_FC_IMPORTING2		= "Importing favorites completed.",
	
	SI_IJA_FC_SORT0				= "Sort By Collectible Name",
	SI_IJA_FC_SORT_TIP0			= "Enabled: sorts Favorites collectible names.",
	
	
	SI_IJA_FC_SORT1				= "Sort By Subcategory Name",
	SI_IJA_FC_SORT_TIP1			= "Enabled: sorts Favorites subcategories by original subcategory names.",
	
	
	SI_IJA_FC_SORT2				= "Sort By Subcategory Index",
	SI_IJA_FC_SORT_TIP2			= "Enabled: sorts Favorites subcategories by original subcategory index.",
	
	
	SI_IJA_FC_HIDE_ICON			= "Hide Random Mount HUD Icon",
	SI_IJA_FC_HIDE_ICON_TIP		= "Enabled: The random munt HUD icon will be always hidden. It will still show on HUDUI to allow moving.",
	
	
	SI_BINDING_NAME_IJA_FavoriteCollectibles_ToggleMount = "Toggle Random Mount",
}

--strings['SI_FURNITURETHEMETYPE' .. IJA_FURNITURE_THEME_TYPE_FAVORITES] = 'Favorite Collectibles'

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
