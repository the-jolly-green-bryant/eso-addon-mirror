function SlashHome()
		RequestJumpToHouse(GetHousingPrimaryHouse())
		d("Heading home...")
end
SLASH_COMMANDS["/home"] = SlashHome