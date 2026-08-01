local ffc_strings = {
	FFC_FAVOURITES = "Favoritos",
	FFC_MARK = "A\195\177adir a favoritos",
	FFC_UNMARK = "Eliminar de favoritos"
}


if GetString(FFC_FAVOURITES):len() == 0 then
	for key,value in pairs(ffc_strings) do
		SafeAddVersion(key, 1)
		ZO_CreateStringId(key, value)
	end
end