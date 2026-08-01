local strings = {
	DUR_HEADING1 = "Equipped Items",
	DUR_HEADING2 = "Weapon Charges",
	DUR_HEADING3 = "Other",
	DUR_SHOW_DURABILITY = "Show durability percentage",
	DUR_SHOW_DURABILITY_TT = "Show the durability percentage on the bottom right corner of the item",
	DUR_SHOW_ALWAYS = "Always show percentage",
	DUR_SHOW_ALWAYS_TT = "Show the durability percentage no matter what the durability is",
	DUR_SHOW_CHARGE_ALWAYS_TT = "Show the charges percentage no matter what the charges are",
	DUR_SHOW_HIGHLIGHT = "Show highlight",
	DUR_SHOW_HIGHLIGHT_TT = "Show the coloured highlight when the item reaches the durability threshold",
	DUR_COLOUR = "Highlight colour",
	DUR_COLOUR_TT = "Colour of the durability warning highlight",
	DUR_THRESHOLD = "Threshold",
	DUR_THRESHOLD_TT = "The percentage when you want the durability warning to appear",
	DUR_REPAIR = "Repair prompt when visiting a vendor",
	DUR_REPAIR_PER = "Repair prompt percentage",
	DUR_REPAIR_PER_TT = "Only prompt to repair when the worst piece of gear is at this level or below",
}

if GetString(DUR_HEADING1):len() == 0 then
	for key,value in pairs(strings) do
		SafeAddVersion(key, 1)
		ZO_CreateStringId(key, value)
	end
end