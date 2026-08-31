if not GildedUI then return end

local Addon = GildedUI

Addon:RegisterMenuSection(function(menu, H)
	menu:AddOptions({
		{ type = "section", name = "Interface", align = "leftIndent", options = {} },
	})
end)
