--------------------------------------
-- English localization for LPCI --
--------------------------------------

--addon menu
local strings = {
	-- insects
	LPCI_INSECT_BUTTERFLY = "Butterfly", -- Don't change
	LPCI_INSECT_TORCHBUG = "Torchbug", -- Don't change
	LPCI_INSECT_WASP = "Wasp", -- Don't change
	LPCI_INSECT_FLESHFLIES = "Fleshflies", -- Don't change
	LPCI_INSECT_DRAGONFLY = "Dragonfly", -- Don't change
	LPCI_INSECT_NETCHCALF = "Netch Calf", -- Don't change
	LPCI_INSECT_FETCHERFLY = "Fetcherfly", -- Don't change
	LPCI_INSECT_DOVAH = "Seht's Dovah-Fly", -- Don't change
	
	LPCI_INSECT_WINTER = "Winter Moth", -- Don't change
	LPCI_INSECT_ANCESTOR = "Ancestor Moth", -- Don't change
	LPCI_INSECT_DUSKLIGHT = "Dusklight Lunar Moth", -- Don't change
	LPCI_INSECT_MOONS = "Bright Moons Lunar Moth", -- Don't change
	LPCI_INSECT_SPRINGLIGHT = "Springlight Moth", -- Don't change
	LPCI_INSECT_SWAMP_JELLY = "Swamp Jelly", -- Don't change
	LPCI_INSECT_BLACKREACH_JELLY = "Blackreach Jelly", -- Don't change
	LPCI_INSECT_MOON_JELLY = "Moon-Kissed Jelly", -- Don't change	
	
	-- seat
	LPCI_SEAT = "Seat", -- Don't change
	
	-- Cooking Fire
	LPCI_COOKING_FIRE = "Cooking Fire", -- Don't change
	
	-- settings
	LPCI_LONG = "Your Long Press Key",
	LPCI_LONG_TOOLTIP_1 = "The long press key you will use with ",
	LPCI_LONG_TOOLTIP_2 = " to interact with followers and companions",
	LPCI_NO_SEATS = "Disallow seats interaction",
	LPCI_NO_SEATS_TOOLTIP = "Avoid displaying the Seat link",
	LPCI_NO_EMPTY = "Disallow empty containers interaction",
	LPCI_NO_EMPTY_TOOLTIP = "Avoid displaying the Empty link",
	LPCI_NO_KNOWN_BOOKS = "Disallow Known Books interaction",
	LPCI_NO_KNOWN_BOOKS_TOOLTIP = "Avoid displaying the Known Books link (that one may shortly affect FPS)",
	LPCI_NO_INSECTS = "Disallow Insects interaction",
	LPCI_NO_INSECTS_TOOLTIP = "Avoid displaying the Insects link",
	LPCI_COMPANION_RECALL = "Auto summon companion",
	LPCI_COMPANION_RECALL_TOOLTIP = "Auto summon latest companion after first combat without him/her",
	LPCI_NO_INSECTS_WITH_MIRRI = "No Insects interaction with Mirri",
	LPCI_NO_INSECTS_WITH_MIRRI_TOOLTIP = "Auto disallow interaction with insects when Mirri is around",
	LPCI_NO_COOKING_FIRES = "No interaction with cooking fires",
	LPCI_NO_COOKING_FIRES_TOOLTIP = "Disallow interaction with cooking fires outside of town",
	
	-- chat alerts
	LPCI_PRESS = "Press",
	LPCI_TO_INTERACT_WITH = "to interact with",
	
	--dARK bROTHERHOOD
	LPCI_DARK1 = "|c9DFE00<<1>>|r|cFF0000 won't like that!|r",
	LPCI_DARK2 = "Oh no, she won't!",
	
	--OUtlaw's refuge
	LPCI_OUTLAW1 = "|c9DFE00<<1>>|r|cFF0000 won't like that!|r",
	LPCI_OUTLAW2 = "Oh no, she won't!",
	
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
