-- Looted list control to display list of loot during the farming run for the specified player

LootList = ZO_SortFilterList:Subclass()
LootList.defaults = {}

-- set namespace for control
FFFLootedListControl = {}
FFFLootedListControl.DEFAULT_TEXT = ZO_ColorDef:New(0.9,0.8,0.7,1)

FFFLootedListControl.LootList = nil
FFFLootedListControl.items = {}

function LootList:New()
	local items = ZO_SortFilterList.New(self) -- need to define a window here or something
	
	return items
end
