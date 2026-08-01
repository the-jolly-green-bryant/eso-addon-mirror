local TBoxAddon = _G['TBoxAddon']
function TBoxAddon.TColor(color, text) -- Wraps the color tags with the passed color around the given text.
	local cText = "|c"..tostring(color)..tostring(text).."|r"
	return cText
end
local pTC = TBoxAddon.TColor
TBoxAddon.DB = {}
TBoxAddon.AT = {}
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

-- General
	L.TBoxAddon_SEARCHBOX				= "Search for treasure by name."
	L.TBoxAddon_CLOSE					= "Close Treasure Box"
	L.TBoxAddon_TITLE					= "Treasure Box"
	L.TBoxAddon_RECENT					= "Recently Found:"
	L.TBoxAddon_FAVZONE					= "Top Zone:"
	L.TBoxAddon_UPDATE1					= "[TBox]: Treasure Box database updated."
	L.TBoxAddon_UPDATE2					= "[TBox]: Please /reloadui to complete."
	L.TBoxAddon_UPDATE3					= "[TBox]: Please stand by..."
	L.TBoxAddon_NOCATEGORY				= "Uncategorized"
	L.TBoxAddon_RESETSEARCH				= "Click button to reset text search.\n\n"..pTC("FFFFFF", "NOTE: ").."Other filters are maintained."
	L.TBoxAddon_TFOUNDOFF				= pTC("00FF00", "Show Only Found").." is"..pTC("FFFFFF", " ON").."\n\nClick to toggle showing ALL treasures whether you have found them or not."
	L.TBoxAddon_TFOUNDON				= pTC("00FF00", "Show Only Found").." is"..pTC("FFFFFF", " OFF").."\n\nClick to show only treasures you have found on one of your characters."
	L.TBoxAddon_RESETFILTER				= "Reset Filters"
	L.TBoxAddon_RQUALITYS1				= "Only show "
	L.TBoxAddon_RQUALITYS2				= " and higher quality items in the Recently Found list."
	L.TBoxAddon_UPDATING				= "[TBox]: Treasure Box database updating, please do not restart..."

-- Navigation
	L.TBoxAddon_TFOUND					= "Treasure Found:"
	L.TBoxAddon_QUALITYHEAD				= "Treasure Quality:"
	L.TBoxAddon_TIMEHEAD				= "Time Found:"
	L.TBoxAddon_TIMEDAYS1				= "Past"
	L.TBoxAddon_TIMEDAYS2				= "Days"
	L.TBoxAddon_ANY						= "Any"
	L.TBoxAddon_ALLTYPES				= "Category: Any"
	L.TBoxAddon_ALLZONES				= "Found In: Any"
	L.TBoxAddon_ANYFOUND				= "Found By: Any"
	L.TBoxAddon_QUALITYS				= "Show Quality: "
	L.TBoxAddon_QUALITY1				= "Normal"
	L.TBoxAddon_QUALITY2				= "Fine"
	L.TBoxAddon_QUALITY3				= "Superior"
	L.TBoxAddon_QUALITY4				= "Epic"
	L.TBoxAddon_QUALITY5				= "Legendary"
	L.TBoxAddon_FINZONES				= "Found In Zones:"
	L.TBoxAddon_LFOUNDIN				= "Last Found In: "
	L.TBoxAddon_LFOUNDBY				= "Last Found By: "
	L.TBoxAddon_FOUNDON					= "Last Found On: "
	L.TBoxAddon_TOTALF					= "Total Found: "
	L.TBoxAddon_NEVER					= "Never"
	L.TBoxAddon_NONE					= "None"
	L.TBoxAddon_UNKNOWN					= "Unknown"
	L.TBoxAddon_SALPHA					= "Sort Alphabetically"
	L.TBoxAddon_SFOUND					= "Sort By Number Found"

-- Settings
	L.TBoxAddon_GOPTS					= "General Options"
	L.TBoxAddon_CHARALPHA				= "Sort Character List"
	L.TBoxAddon_CHARALPHAT				= "Enabled shows the list of characters alphabetically. Otherwise it uses the game's character select order.\n\n"..pTC("FFFFFF", "NOTE: ").."The game returns character CREATION order only. It does not track manually re-ordered characters."
	L.TBoxAddon_USTIME					= "12 Hour Time"
	L.TBoxAddon_USTIMET					= "When enabled timestamps for previously found treasures will be shown in 12 hour time with am/pm after the time. Turn off to show in 24 hour (military) time."
	

function TBoxAddon:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
