local ffc_strings = {
	FFC_FAVOURITES = "Favorites",
	FFC_MARK = "Add to favorites",
	FFC_UNMARK = "Remove from favorites"
}


if GetString(FFC_FAVOURITES):len() == 0 then
	for key,value in pairs(ffc_strings) do
		SafeAddVersion(key, 1)
		ZO_CreateStringId(key, value)
	end
end