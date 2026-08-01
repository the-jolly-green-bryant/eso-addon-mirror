LykeionsHomeSweetHome = {}

LykeionsHomeSweetHome.name = "LykeionsHomeSweetHome"

function LykeionsHomeSweetHome_Jump()
	RequestJumpToHouse(68,true)
end

function LykeionsHomeSweetHome:Initialize()
	SLASH_COMMANDS["/hsh"] = function(keyWord, argument)
		LykeionsHomeSweetHome_Jump()
	end

	if LibRadialMenu then
		LibRadialMenu:RegisterAddon("HSH", "Lyekion's Home Sweeet Home")
		LibRadialMenu:RegisterEntry("HSH", GetString(SI_BINDING_NAME_HSH_JUMP), 1, "/esoui/art/icons/crafting_poisonmaking_reagent_moon_sugar.dds", LykeionsHomeSweetHome_Jump, GetString(SI_BINDING_NAME_HSH_JUMP))
	end
end

function LykeionsHomeSweetHome.OnAddOnLoaded(event, addonName)
  if addonName == LykeionsHomeSweetHome.name then
	LykeionsHomeSweetHome:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(LykeionsHomeSweetHome.name, EVENT_ADD_ON_LOADED, LykeionsHomeSweetHome.OnAddOnLoaded)
