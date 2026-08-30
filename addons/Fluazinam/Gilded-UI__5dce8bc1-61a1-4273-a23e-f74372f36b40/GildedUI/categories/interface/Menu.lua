if not GildedUI then return end

local Addon = GildedUI

Addon:RegisterMenuSection(function(menu, H)
	menu:AddOptions({
		{ type = "header", name = "Interface", align = "leftIndent" },
	})
end)
