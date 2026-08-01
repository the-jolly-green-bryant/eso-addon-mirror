local ShowMotifs = _G['ShowMotifs']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
	L.GENERAL					= "General"
	L.ICON_THEME				= "Icons Theme"
	L.ICON_THEME_TOOLTIP		= "Choose Theme for icons.\n\nNote for Inventory Grid View add-on users: Icons are not displayed in 'grid' mode"
	L.ICON_SIZE					= "Racial Motif icon Size"
	L.ICON_SIZE_TOOLTIP			= "Set the size for Racial Motif icons"
	L.ARMOR_ICON_SIZE			= "Armor Type icon Size"
	L.ARMOR_ICON_SIZE_TOOLTIP	= "Set the size for Armor Type icons"
	L.II_POSITION				= "Inventory Icon Position"
	L.II_POSITION_TOOLTIP		= "Set the Position for icons relative to left edge of inventory list"
	L.GSS_POSITION				= "Guild Store Icon Position"
	L.GSS_POSITION_TOOLTIP		= "Set the Position for icons relative to left edge of guild store search result list"
	L.GSL_POSITION				= "Guild Listing Icon Position"
	L.GSL_POSITION_TOOLTIP		= "Set the Position for icons relative to left edge of guild store listing panel"
	L.RACIAL					= "Show Racial Motif icon"
	L.RACIAL_TOOLTIP			= "Show Racial Motif icon.\n\nNote for Inventory Grid View add-on users: Icons are not displayed in 'grid' mode"
	L.ARMOR						= "Show Armor Type icon"
	L.ARMOR_TOOLTIP				= "Show Armor Type icon.\n\nNote for Inventory Grid View add-on users: Icons are not displayed in 'grid' mode"
	L.LETTER					= "Use Letters"
	L.LETTER_TOOLTIP			= "Show letter instead of graphic symbols for Armor Type.\n\n(L)ight  -  light armor\n(M)edium  -  medium armor\n(H)eavy  -  heavy armor"
	L.COLOR						= "Use Quality Color"
	L.COLOR_TOOLTIP				= "Set the color for icons according to item quality"
	L.TOOLTIP					= "Show tooltips"
	L.TOOLTIP_TOOLTIP			= "Show tooltips for icons on mouse hover.\n\nNote for Inventory Grid View add-on users: Icons are not displayed in 'grid' mode"

-- Temporary database of names, because ZOS hasn't localized non-English motif names yet. (Phinix)
ShowMotifs.Names = {
	[0]		= "Monster Set",
	[1]		= "Breton",
	[2]		= "Redguard",
	[3]		= "Orc",
	[4]		= "Dark Elf",
	[5]		= "Nord",
	[6]		= "Argonian",
	[7]		= "High Elf",
	[8]		= "Wood Elf",
	[9]		= "Khajiit",
	[10]	= "Unique",
	[11]	= "Thieves Guild",
	[12]	= "Dark Brotherhood",
	[13]	= "Malacath",
	[14]	= "Dwemer",
	[15]	= "Ancient Elf",
	[16]	= "Order of the Hour",
	[17]	= "Barbaric",
	[18]	= "Bandit",
	[19]	= "Primal",
	[20]	= "Daedric",
	[21]	= "Trinimac",
	[22]	= "Ancient Orc",
	[23]	= "Daggerfall Covenant",
	[24]	= "Ebonheart Pact",
	[25]	= "Aldmeri Dominion",
	[26]	= "Mercenary",
	[27]	= "Celestial",
	[28]	= "Glass",
	[29]	= "Xivkyn",
	[30]	= "Soul Shriven",
	[31]	= "Draugr",
	[32]	= "Maormer",
	[33]	= "Akaviri",
	[34]	= "Imperial",
	[35]	= "Yokudan",
	[36]	= "Universal",
	[37]	= "Reach Winter",
	[38]	= "Tsaesci",
	[39]	= "Minotaur",
	[40]	= "Ebony",
	[41]	= "Abah's Watch",
	[42]	= "Skinchanger",
	[43]	= "Morag Tong",
	[44]	= "Ra Gada",
	[45]	= "Dro-m'Athra",
	[46]	= "Assassins League",
	[47]	= "Outlaw",
	[48]	= "Redoran",
	[49]	= "Hlaalu",
	[50]	= "Militant Ordinator",
	[51]	= "Telvanni",
	[52]	= "Buoyant Armiger",
	[53]	= "Frostcaster",
	[54]	= "Ashlander",
	[55]	= "Worm Cult",
	[56]	= "Silken Ring",
	[57]	= "Mazzatun",
	[58]	= "Grim Harlequin",
	[59]	= "Hollowjack",
	[60]	= "Clockwork",
	[61]	= "Bloodroot",
	[62]	= "Falkreath",
	[65]	= "Apostle",
	[66]	= "Ebonshadow",
	[69]	= "Fang Lair",
	[70]	= "Scalecaller",
	[71]	= "Psijic",
	[72]	= "Sapiarch",
	[73]	= "Welkynar",
	[74]	= "Dremora",
	[75]	= "Pyandonean",
	[77]	= "Huntsman",
	[78]	= "Silver Dawn",
	[79]	= "Dead-Water",
	[80]	= "Honor Guard",
	[81]	= "Elder Argonian",
}

------------------------------------------------------------------------------------------------------------------

function ShowMotifs:GetLanguage() -- default language, will be the return unless overwritten
	return L
end
