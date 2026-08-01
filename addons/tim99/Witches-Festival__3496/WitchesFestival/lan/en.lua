--en
local strings = {
	--tooltips
    TIM99_WITCH_DELVE  = "Delve",
	TIM99_WITCH_ANKER  = "Anchor",
	TIM99_WITCH_WORLD  = "World",
	TIM99_WITCH_PUBLIC = "Public",
	TIM99_WITCH_GROUP  = "Dungeon",
	TIM99_WITCH_ARENA  = "Arena",
	TIM99_WITCH_TRIAL  = "Trial",
	TIM99_WITCH_CROW   = "Crow",
	TIM99_WITCH_JACK   = "Jack",
	TIM99_WITCH_ARCHIV = "Archiv",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
